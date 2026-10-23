extends Node
## Headless tests. Run:
##   godot --headless --path . res://tests/test_runner.tscn
## Exits with code 0 if everything passes, 1 otherwise.

var passed := 0
var failed := 0


func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		print("  FAIL: ", label)


func _ready() -> void:
	print("== Hangul engine ==")
	test_compose()
	print("== Curriculum ==")
	test_curriculum()
	print("== Hallasan words ==")
	test_hallasan_words()
	print("== Game state ==")
	test_game_state()
	print("== Settings ==")
	test_settings()
	print("\n%d passed, %d failed" % [passed, failed])
	get_tree().quit(0 if failed == 0 else 1)


func test_compose() -> void:
	check(Hangul.compose("ㅁ", "ㅓ") == "머", "ㅁ+ㅓ = 머")
	check(Hangul.compose("ㄹ", "ㅜ") == "루", "ㄹ+ㅜ = 루")
	check(Hangul.compose("ㅎ", "ㅏ", "ㄴ") == "한", "ㅎ+ㅏ+ㄴ = 한")
	check(Hangul.compose("ㄱ", "ㄴ") == "", "two consonants make no block")
	check(Hangul.compose("ㅏ", "ㅏ") == "", "a vowel can't be an initial")
	check(Hangul.compose("ㄱ", "ㅏ", "ㅏ") == "", "a vowel can't be a final")
	check(Hangul.compose("ㄱ", "ㅏ", "ㄸ") == "", "ㄸ can't be a final")
	check(Hangul.compose("", "ㅏ") == "", "empty initial makes no block")
	check(Hangul.decompose("산") == ["ㅅ", "ㅏ", "ㄴ"], "산 decomposes")
	check(Hangul.decompose("a").is_empty(), "non-Hangul decomposes to nothing")
	check(Hangul.tokens_of("물") == ["ㅁ", "ㅜ", "-ㄹ"], "물 tokens mark the 받침")
	check(Hangul.tiles_for("물") == ["ㅁ", "ㅜ", "ㄹ"], "물 tiles drop the marker")
	check(Hangul.vowel_shape("ㅏ") == "vertical", "ㅏ sits to the right")
	check(Hangul.vowel_shape("ㅜ") == "horizontal", "ㅜ sits underneath")
	check(Hangul.vowel_shape("ㅘ") == "mixed", "ㅘ wraps")
	# Every syllable in the Unicode block round-trips.
	var ok := true
	for code in range(Hangul.SYLLABLE_BASE, Hangul.SYLLABLE_LAST + 1):
		var ch := String.chr(code)
		var p := Hangul.decompose(ch)
		if p.size() != 3 or Hangul.compose(p[0], p[1], p[2]) != ch:
			ok = false
			break
	check(ok, "compose(decompose(x)) == x across the block")


func test_curriculum() -> void:
	var all := Content.known_letters(12)
	for j in Hangul.INITIALS:
		check(all.has(j), "%s taught by 백두산" % j)
	for j in Hangul.MEDIALS:
		check(all.has(j), "%s taught by 백두산" % j)
	for f in Hangul.FINALS:
		if f != "":
			check(all.has("-" + f), "받침 %s taught by 백두산" % f)
	# Hallasan teaches exactly these 10 letters.
	var known := Content.known_letters(1)
	var expected := ["ㅏ", "ㅓ", "ㅗ", "ㅜ", "ㅣ", "ㅇ", "ㄱ", "ㄴ", "ㄹ", "ㅁ"]
	check(known.size() == 10, "Hallasan teaches 10 letters")
	for t in expected:
		check(known.has(t), "%s is taught on Hallasan" % t)
	check(not known.has("ㅡ"), "ㅡ is not taught on Hallasan")
	check(Content.new_letters(2).has("ㅡ"), "ㅡ is taught on Jirisan")
	# Hoped-for word match: the first game each word is readable.
	print("  Readable-from report:")
	var hopes := {
		"머루": 1, "미나리": 1, "고사리": 2, "도라지": 2, "여우": 3,
		"더덕": 4, "참나물": 5, "얼레지": 6, "눈사태": 6, "금강초롱꽃": 7,
		"취나물": 8, "버섯": 9, "칡": 10, "만병초": 11, "들쭉": 12, "한라산": 4,
	}
	for word in hopes:
		var from := Content.readable_from(word)
		var note := ""
		if from < 0 or from > int(hopes[word]):
			note = "  <-- later than hoped"
		print("    %s: hoped %d, readable from %d%s" % [word, hopes[word], from, note])


func test_hallasan_words() -> void:
	var known := Content.known_letters(1)
	var review := ["머루", "미나리", "나무", "노루", "오리", "거미", "모기", "머리",
			"이마", "이", "아이", "오이", "고기", "고구마", "어머니", "누나", "이모",
			"우리", "나이", "거리", "고리", "구리"]
	var bonus := ["고사리", "시로미", "구상나무", "물", "불", "돌", "다리"]
	for w in review:
		check(Hangul.is_readable(w, known), "%s is a review word" % w)
	for w in bonus:
		check(not Hangul.is_readable(w, known), "%s is a bonus guess" % w)


func test_game_state() -> void:
	GameState.game_id = "hallasan"
	GameState.new_hike(0)
	check(GameState.hearts["nestor"] == 5 and GameState.hearts["fernanda"] == 5, "5 hearts at the start of the hike")
	GameState.begin_scene("foraging")
	check(not GameState.damage("nestor", "eye_branch"), "first hit doesn't kill")
	check(GameState.hearts["nestor"] == 4, "damage removes exactly one heart")
	check(GameState.hearts["fernanda"] == 5, "the other traveler is untouched")
	check(GameState.score_word("머루") == 10 and GameState.ddeok == 10, "review word scores the review value")
	GameState.begin_scene("animals")
	check(GameState.hearts["nestor"] == 4, "no refill between scenes")
	check(GameState.score_word("고사리") == 30 and GameState.ddeok == 40, "bonus guess scores the bonus value")
	check(GameState.score_word("노루", true) == 100, "monster capture scores its value")
	GameState.ddeok = 40
	GameState.begin_scene("monster")
	var deaths := []
	var on_death := func(dead, survivor, injury): deaths.append([dead, survivor, injury])
	GameState.travelers_died.connect(on_death)
	GameState.hearts["nestor"] = 1
	var died := GameState.damage("nestor", "antler_skewer")
	check(died, "1 heart to 0 kills")
	check(deaths.size() == 1, "death signal emitted once")
	check(deaths[0] == ["nestor", "fernanda", "antler_skewer"], "signal names dead, survivor and injury")
	GameState.damage("nestor", "antler_skewer")
	check(GameState.hearts["nestor"] == 0, "hearts never go below 0")
	check(deaths.size() == 1, "hitting the dead doesn't re-emit the signal")
	GameState.travelers_died.disconnect(on_death)
	GameState.add_ddeok(100)
	GameState.restart_scene()
	check(GameState.hearts["nestor"] == 4 and GameState.hearts["fernanda"] == 5, "restart restores both travelers' hearts")
	check(GameState.ddeok == 40, "restart restores ddeok from the scene's start")
	GameState.difficulty = "easy"
	var easy := GameState.time_limit("머리")
	GameState.difficulty = "diffi"
	check(GameState.time_limit("머리") < easy, "diffi is faster than easy")
	GameState.difficulty = "soso"


func test_settings() -> void:
	var test_path := "user://test_settings.cfg"
	var real_path: String = Settings.path
	Settings.path = test_path
	Settings.load_settings()
	check(not Settings.romanization and not Settings.english_subtitles, "settings default to off")
	var events := []
	var on_change := func(key, value): events.append([key, value])
	Settings.setting_changed.connect(on_change)
	Settings.set_romanization(true)
	check(events == [["romanization", true]], "changing a setting emits a signal")
	Settings.set_romanization(true)
	check(events.size() == 1, "setting the same value emits nothing")
	Settings.setting_changed.disconnect(on_change)
	Settings.romanization = false  # wipe in-memory state, then reload from disk
	Settings.load_settings()
	check(Settings.romanization and not Settings.english_subtitles, "a changed setting survives save + load")
	DirAccess.remove_absolute(test_path)
	check(not FileAccess.file_exists(test_path), "test settings file deleted")
	Settings.path = real_path
	Settings.load_settings()
