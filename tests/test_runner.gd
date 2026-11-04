extends Node
## Headless tests. Run:
##   godot --headless --path . res://tests/test_runner.tscn
## Exits with code 0 if everything passes, 1 otherwise.

const Foraging := preload("res://scenes/foraging/foraging.gd")

var passed := 0
var failed := 0
## Each test section ends with _section_done("<its name>"). A script error stops a
## section before that line, so the section is missing from the list below.
var finished: Array[String] = []

## Every section _ready() runs. Add a new section's name here when adding it.
const EXPECTED_SECTIONS: Array[String] = [
	"test_compose",
	"test_curriculum",
	"test_hallasan_words",
	"test_game_state",
	"test_heart_units",
	"test_settings",
	"test_foraging",
	"test_terrain_data",
	"test_zones_data",
	"test_plants_data",
	"test_backdrop_data",
	"test_fade_and_tooltip_data",
	"test_names_and_colors_data",
	"test_decoy_letters",
	"test_discovery_logic",
	"test_terrain_scene",
	"test_discovery_scene",
	"test_backdrop_scene",
	"test_prop_fade",
	"test_picking_data",
	"test_picking_logic",
	"test_steam_sound",
	"test_picking_scene",
	"test_basket_hud_data",
	"test_hud_clicks_and_layout",
	"test_reach_data",
	"test_reach_logic",
	"test_reach_scene",
	"test_spelling_data",
	"test_spelling_logic",
	"test_spelling_scene",
	"test_damage_data",
	"test_damage_logic",
	"test_hearts_scene",
	"test_spares_data",
	"test_spares_logic",
	"test_spares_scene",
	"test_spares_real_events",
	"test_credits_logic",
	"test_credits_scene",
	"test_credits_real_events",
	"test_walk_limit_data",
	"test_walk_limit_scene",
	"test_keyboard_data",
	"test_cursor_logic",
	"test_keyboard_scene",
	"test_stuck_data",
	"test_stuck_logic",
	"test_stuck_brute_force",
	"test_countdown_logic",
	"test_kill_timeline",
	"test_stuck_music",
	"test_stuck_playtest",
	"test_stuck_scene",
	"test_stuck_monster",
	"test_stuck_real_events",
	"test_pause_menu_data",
	"test_pause_menu_logic",
	"test_pause_menu_scene",
	"test_pause_menu_ignored",
	"test_pause_menu_input",
	"test_pause_menu_restart",
	"test_items_data",
	"test_inventory_logic",
	"test_inventory_game_state",
	"test_backpack_data",
	"test_backpack_logic",
	"test_backpack_scene",
	"test_backpack_ignored",
	"test_backpack_restart",
	"test_backpack_input",
	"test_ddeok_item",
	"test_reward_table",
	"test_reward_pick",
	"test_harm_pick",
	"test_backpack_icons",
	"test_decoy_gore_data",
	"test_decoy_gore_logic",
	"test_decoy_gore_scene",
	"test_decoy_gore_gating",
	"test_decoy_gore_countdown",
	"test_decoy_gore_lethal",
	"test_decoy_gore_restart",
	"test_drink_data",
	"test_drink_logic",
	"test_drink_scene",
	"test_drink_input",
	"test_drink_restart",
	"test_placement_data",
	"test_placement_logic",
	"test_chaos_piles_logic",
	"test_decoy_roll_stats",
	"test_placement_timing",
	"test_legacy_default",
	"test_decoys_at_any_position",
	"test_decoy_outcome_picks",
	"test_new_gore_data",
	"test_new_gore_scene",
	"test_new_gore_flow",
	"test_gore_captions",
	"test_hidden_outcome",
	"test_slot_generator",
	"test_pile_pickup",
	"test_pile_restart",
]

## The run fails if fewer checks than this ran. After adding tests, raise it to
## the printed total minus a small margin (currently 5).
const MIN_CHECKS := 2712


func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		print("  FAIL: ", label)


func _section_done(section: String) -> void:
	finished.append(section)


func _ready() -> void:
	# The sections written before random decoys and chaos piles (Prompt 7d) expect the
	# decoys at the fixed positions of the data and no piles; they run in the legacy
	# layout. The 7d sections switch it off and build maps with pinned seeds.
	Foraging.legacy_layout = true
	print("== Hangul engine ==")
	test_compose()
	print("== Curriculum ==")
	test_curriculum()
	print("== Hallasan words ==")
	test_hallasan_words()
	print("== Game state ==")
	test_game_state()
	test_heart_units()
	print("== Settings ==")
	test_settings()
	print("== Foraging map ==")
	test_foraging()
	print("== Terrain, zones and plants (data) ==")
	test_terrain_data()
	test_zones_data()
	test_plants_data()
	test_backdrop_data()
	test_fade_and_tooltip_data()
	test_names_and_colors_data()
	print("== Decoy letters and discovery (data) ==")
	test_decoy_letters()
	test_discovery_logic()
	print("== Terrain, plants and hover (scene) ==")
	await test_terrain_scene()
	print("== Discovery list (scene) ==")
	test_discovery_scene()
	print("== Backdrop and prop fade (scene) ==")
	test_backdrop_scene()
	test_prop_fade()
	print("== Picking ==")
	test_picking_data()
	test_picking_logic()
	test_steam_sound()
	await test_picking_scene()
	print("== HUD clicks and basket layout ==")
	test_basket_hud_data()
	await test_hud_clicks_and_layout()
	print("== Keyboard picking, walk-up names, reach ring ==")
	test_reach_data()
	test_reach_logic()
	await test_reach_scene()
	print("== Spelling view ==")
	test_spelling_data()
	test_spelling_logic()
	await test_spelling_scene()
	print("== Spelling failure damage, gore, hearts, death ==")
	test_damage_data()
	test_damage_logic()
	await test_hearts_scene()
	print("== Spare plants ==")
	test_spares_data()
	test_spares_logic()
	await test_spares_scene()
	await test_spares_real_events()
	print("== Spare credits ==")
	test_credits_logic()
	await test_credits_scene()
	await test_credits_real_events()
	print("== Walk limit toward the camera ==")
	test_walk_limit_data()
	await test_walk_limit_scene()
	print("== Keyboard control in the spelling view ==")
	test_keyboard_data()
	test_cursor_logic()
	await test_keyboard_scene()
	print("== Stuck check, countdown, music and monster ==")
	test_stuck_data()
	test_stuck_logic()
	test_stuck_brute_force()
	test_countdown_logic()
	test_kill_timeline()
	test_stuck_music()
	await test_stuck_playtest()
	await test_stuck_scene()
	await test_stuck_monster()
	await test_stuck_real_events()
	print("== Pause menu ==")
	test_pause_menu_data()
	test_pause_menu_logic()
	await test_pause_menu_scene()
	await test_pause_menu_ignored()
	await test_pause_menu_input()
	await test_pause_menu_restart()
	print("== Items and Fernanda's backpack ==")
	test_items_data()
	test_inventory_logic()
	test_inventory_game_state()
	test_backpack_data()
	test_backpack_logic()
	await test_backpack_scene()
	await test_backpack_ignored()
	await test_backpack_restart()
	test_backpack_input()
	test_ddeok_item()
	test_reward_table()
	await test_reward_pick()
	await test_harm_pick()
	await test_backpack_icons()
	print("== Harm decoy gore beats ==")
	test_decoy_gore_data()
	test_decoy_gore_logic()
	await test_decoy_gore_scene()
	await test_decoy_gore_gating()
	await test_decoy_gore_countdown()
	await test_decoy_gore_lethal()
	await test_decoy_gore_restart()
	print("== Drinking elixirs ==")
	test_drink_data()
	test_drink_logic()
	await test_drink_scene()
	await test_drink_input()
	await test_drink_restart()
	print("== Random decoys and chaos DDEOK piles ==")
	Foraging.legacy_layout = false
	await test_placement_data()
	test_placement_logic()
	test_chaos_piles_logic()
	test_decoy_roll_stats()
	await test_placement_timing()
	await test_legacy_default()
	await test_decoys_at_any_position()
	print("== Full chaos decoys: outcomes, new gore beats, captions ==")
	await test_decoy_outcome_picks()
	test_new_gore_data()
	await test_new_gore_scene()
	await test_new_gore_flow()
	await test_gore_captions()
	await test_hidden_outcome()
	await test_slot_generator()
	await test_pile_pickup()
	await test_pile_restart()
	for section in EXPECTED_SECTIONS:
		if not finished.has(section):
			check(false, "section did not run to its end: " + section)
	check(passed + failed >= MIN_CHECKS, "at least %d checks ran (%d)" % [MIN_CHECKS, passed + failed])
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
	_section_done("test_compose")


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
	_section_done("test_curriculum")


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
	_section_done("test_hallasan_words")


func test_game_state() -> void:
	GameState.game_id = "hallasan"
	GameState.new_hike(0)
	check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "5 hearts (10 units) at the start of the hike")
	GameState.begin_scene("foraging")
	check(not GameState.damage("nestor", "eye_branch"), "first hit doesn't kill")
	check(GameState.heart_units["nestor"] == 8, "damage removes exactly one heart")
	check(GameState.heart_units["fernanda"] == 10, "the other traveler is untouched")
	check(GameState.score_word("머루") == 10 and GameState.ddeok == 10, "review word scores the review value")
	GameState.begin_scene("animals")
	check(GameState.heart_units["nestor"] == 8, "no refill between scenes")
	check(GameState.score_word("고사리") == 30 and GameState.ddeok == 40, "bonus guess scores the bonus value")
	check(GameState.score_word("노루", true) == 100, "monster capture scores its value")
	GameState.ddeok = 40
	GameState.begin_scene("monster")
	var deaths := []
	var on_death := func(dead, survivor, injury): deaths.append([dead, survivor, injury])
	GameState.travelers_died.connect(on_death)
	GameState.heart_units["nestor"] = 2
	var died := GameState.damage("nestor", "antler_skewer")
	check(died, "1 heart to 0 kills")
	check(deaths.size() == 1, "death signal emitted once")
	check(deaths[0] == ["nestor", "fernanda", "antler_skewer"], "signal names dead, survivor and injury")
	GameState.damage("nestor", "antler_skewer")
	check(GameState.heart_units["nestor"] == 0, "hearts never go below 0")
	check(deaths.size() == 1, "hitting the dead doesn't re-emit the signal")
	GameState.travelers_died.disconnect(on_death)
	GameState.add_ddeok(100)
	GameState.restart_scene()
	check(GameState.heart_units["nestor"] == 8 and GameState.heart_units["fernanda"] == 10, "restart restores both travelers' hearts")
	check(GameState.ddeok == 40, "restart restores ddeok from the scene's start")
	GameState.difficulty = "easy"
	var easy := GameState.time_limit("머리")
	GameState.difficulty = "diffi"
	check(GameState.time_limit("머리") < easy, "diffi is faster than easy")
	GameState.difficulty = "soso"
	_section_done("test_game_state")


func test_heart_units() -> void:
	var upu = Content.rules.get("half_units_per_heart")
	check(typeof(upu) == TYPE_FLOAT and upu == floorf(upu) and upu > 0, "rules half_units_per_heart is a positive integer")
	check(GameState.units_per_heart() == 2 and GameState.max_units() == 10, "Hallasan: 5 hearts are 10 units")
	var changes := []
	var on_change := func(t, units): changes.append([t, units])
	GameState.hearts_changed.connect(on_change)
	var deaths := []
	var on_death := func(dead, survivor, injury): deaths.append(dead)
	GameState.travelers_died.connect(on_death)

	GameState.new_hike(0)
	check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "hike start: everyone at max units")
	GameState.begin_scene("units")
	check(not GameState.damage_units("nestor", 1), "a half hit doesn't kill")
	check(GameState.heart_units["nestor"] == 9, "1 unit leaves 9")
	check(GameState.whole_hearts("nestor") == 4 and GameState.has_half("nestor"), "9 units is 4 hearts and a half")
	check(is_equal_approx(GameState.hearts_for_display("nestor"), 4.5), "9 units displays as 4.5 hearts")
	check(changes.back() == ["nestor", 9], "hearts_changed carries units on damage")
	GameState.damage_units("nestor", 1)
	check(GameState.heart_units["nestor"] == 8 and not GameState.has_half("nestor"), "two half hits equal one whole heart")
	GameState.new_hike(0)
	GameState.damage("fernanda", "test")
	check(GameState.heart_units["fernanda"] == 8, "the whole-heart damage call takes exactly 2 units")

	# Heal: caps, no-op on the dead, exact round trip.
	GameState.new_hike(0)
	GameState.heal("nestor", 1)
	check(GameState.heart_units["nestor"] == 10, "heal caps at max")
	GameState.damage_units("nestor", 3)
	changes.clear()
	GameState.heal("nestor", 3)
	check(GameState.heart_units["nestor"] == 10 and changes.back() == ["nestor", 10], "heal then damage round-trips; signal carries units")
	GameState.damage_units("nestor", 3)
	GameState.heal("nestor", 1)
	check(GameState.heart_units["nestor"] == 8, "heal raises by exactly the units given")

	# Floor and death.
	GameState.new_hike(0)
	deaths.clear()
	GameState.heart_units["nestor"] = 1
	check(GameState.damage_units("nestor", 5, "x"), "damage past 0 kills")
	check(GameState.heart_units["nestor"] == 0 and deaths == ["nestor"], "units floor at 0 and the death fires once")
	changes.clear()
	GameState.heal("nestor", 4)
	check(GameState.heart_units["nestor"] == 0 and changes.is_empty(), "healing the dead does nothing")
	check(GameState.damage_units("nestor", 1) and deaths.size() == 1, "hitting the dead doesn't re-emit death")

	# Restart restores an odd unit count exactly.
	GameState.new_hike(0)
	GameState.damage_units("fernanda", 3)
	GameState.begin_scene("odd")
	GameState.damage_units("fernanda", 4)
	GameState.heal("nestor", 1)
	changes.clear()
	GameState.restart_scene()
	check(GameState.heart_units["fernanda"] == 7 and GameState.heart_units["nestor"] == 10, "restart restores the snapshot exactly, odd units included")
	check(changes.has(["fernanda", 7]) and changes.has(["nestor", 10]), "restart emits hearts_changed in units")

	GameState.hearts_changed.disconnect(on_change)
	GameState.travelers_died.disconnect(on_death)
	GameState.new_hike(0)
	_section_done("test_heart_units")


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
	_section_done("test_settings")


func test_foraging() -> void:
	for action in ["p1_left", "p1_right", "p1_up", "p1_down", "p2_left", "p2_right", "p2_up", "p2_down", "p1_pick", "p2_pick"]:
		check(InputMap.has_action(action), "input action %s exists" % action)
	var data := Content.mountain("hallasan")
	check(data.get("name") == "한라산", "hallasan.json loads")
	var config: Dictionary = data["foraging"]

	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)  # the tests drive the map
	check(is_equal_approx(map.stage_width, float(config["stage"]["width"])), "stage width comes from hallasan.json")
	check(is_equal_approx(map.stage_depth, float(config["stage"]["depth"])), "stage depth comes from hallasan.json")
	for id in GameState.TRAVELERS:
		var start: Array = config["start"][id]
		var pos: Vector3 = map.travelers[id].global_position
		check(is_equal_approx(pos.x, float(start[0])) and is_equal_approx(pos.z, float(start[1])), "%s starts where hallasan.json says" % id)
	check(map.player == map.travelers["fernanda"], "the controlled traveler is the player")
	check(map.partner == map.travelers["nestor"], "the other traveler is the partner")
	check(is_equal_approx(map.stage_width, 64.0) and is_equal_approx(map.stage_depth, 24.0), "the stage is 64 x 24 m")
	var density := float(config["props"]["density_per_100m2"])
	var expected := roundi(density * map.ground_rect.get_area() / 100.0)
	check(map.get_node("Props").get_child_count() == expected, "prop count follows the density value (%d)" % expected)
	for t in map.travelers.values():
		check(t.find_children("*", "Label3D", true, false).is_empty(), "%s has no name label" % t.name)

	# Walking. Driven directly on the player so the partner can't get in the way.
	var p: CharacterBody3D = map.player
	var home := _ground_point(map, map.stage_width / 2.0, 0.0)
	p.global_position = home
	p.drive(Vector2.RIGHT, 0.1)
	var straight := p.global_position - home
	check(straight.x > 0.0 and absf(straight.z) < 0.01, "input right moves the player right")
	check((-p.global_transform.basis.z).x > 0.9, "the player faces the way it walks")
	p.global_position = home
	p.drive(Vector2.LEFT, 0.1)
	check(p.global_position.x < home.x, "input left moves the player left")
	p.global_position = home
	p.drive(Vector2(0, -1), 0.1)
	check(p.global_position.z < home.z and absf(p.global_position.x - home.x) < 0.01, "W moves into the scene")
	p.global_position = home
	p.drive(Vector2(0, 1), 0.1)
	check(p.global_position.z > home.z, "S moves out of the scene")
	p.global_position = home
	p.drive(Vector2(1, 1), 0.1)
	var diagonal := p.global_position - home
	check(absf(Vector2(diagonal.x, diagonal.z).length() - Vector2(straight.x, straight.z).length()) < 0.02, "diagonal speed equals straight speed (along the ground plan)")

	# Bounds: push into every wall for far longer than it takes to hit it.
	var bounds_ok := true
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2(1, 1), Vector2(-1, -1)]:
		p.global_position = home
		for i in 400:
			p.drive(dir, 0.1)
		var q := p.global_position
		if q.x < 0.0 or q.x > map.stage_width or q.z < -map.stage_depth / 2.0 or q.z > map.near_limit_at(q.x) + 0.0001:
			bounds_ok = false
	check(bounds_ok, "the player can't leave the walkable area (stage, plus the near strip down to the screen edge) in any direction")

	# Camera follows in depth as well as along the stage.
	p.global_position = home
	map.update_camera(0.0, true)
	var cam_start: Vector3 = map.camera.global_position
	for i in 40:
		map.step(Vector2(0, -1), 0.05)
	check(map.camera.global_position.z < cam_start.z - 3.0, "walking into the scene moves the camera in depth")
	check(absf(map.camera.global_position.y - cam_start.y) < 0.1, "the camera keeps its height on level ground")
	var cam_far_z: float = map.camera.global_position.z
	for i in 40:
		map.step(Vector2(0, 1), 0.05)
	check(map.camera.global_position.z > cam_far_z + 3.0, "walking out of the scene moves the camera back")
	p.global_position = _ground_point(map, 0.5, 0.0)
	map.update_camera(0.0, true)
	var cam_left_x: float = map.camera.global_position.x
	for i in 100:
		map.step(Vector2.RIGHT, 0.05)
	check(map.camera.global_position.x > cam_left_x + 5.0, "the camera follows the player to the right")

	# The view stays over ground or backdrop at all four corners, snapped and
	# while walking there (smoothing must never let the camera slip).
	var half_d: float = map.stage_depth / 2.0
	var corners := [_ground_point(map, 0, half_d), _ground_point(map, map.stage_width, half_d),
			_ground_point(map, 0, -half_d), _ground_point(map, map.stage_width, -half_d)]
	var corners_ok := true
	var walking_ok := true
	for corner in corners:
		p.global_position = corner
		map.update_camera(0.0, true)
		if not _view_over_land(map):
			corners_ok = false
		p.global_position = home
		map.update_camera(0.0, true)
		for i in 700:
			map.step(Vector2(corner.x - p.global_position.x, corner.z - p.global_position.z), 0.05)
			if not _view_over_land(map):
				walking_ok = false
	check(corners_ok, "at all four corners the view is entirely ground or backdrop")
	check(walking_ok, "walking to each corner never shows empty sky")

	# Partner: the player walks away, then stops; the partner catches up.
	map.player.global_position = _ground_point(map, 3.0, 0.0)
	map.partner.global_position = _ground_point(map, 3.0, 1.0)
	for i in 120:
		map.step(Vector2.RIGHT, 0.05)
	for i in 200:
		map.step(Vector2.ZERO, 0.05)
	var gap: Vector3 = map.partner.global_position - map.player.global_position
	gap.y = 0.0
	check(map.player.global_position.x > 20.0, "the player walked away")
	check(gap.length() <= map.PARTNER_STOP_DISTANCE + 0.1, "the partner ends up near the player")
	check(gap.length() > 2.0 * map.Traveler.RADIUS, "the partner doesn't overlap the player")

	var map_area: float = map.ground_rect.get_area()
	map.free()

	# Doubling the density doubles the props (config is cached, so restore it).
	var original: float = config["props"]["density_per_100m2"]
	config["props"]["density_per_100m2"] = original * 2.0
	var dense: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(dense)
	dense.set_physics_process(false)
	check(dense.get_node("Props").get_child_count() == roundi(original * 2.0 * map_area / 100.0), "doubling the density doubles the props")
	config["props"]["density_per_100m2"] = original
	dense.free()
	_section_done("test_foraging")


## True if every sampled screen point looks at ground or backdrop: no sky
## below or beside the ground. A ray must hit the ground (which rises with x)
## inside the ground footprint (walkable stage + apron), or hit a backdrop box.
## Only the top row may look past the backdrop (sky above the ridge); its left
## and right sides must still be over land. The left, right, near and far edges
## are all checked on every other row.
func _view_over_land(map: Node3D) -> bool:
	var size: Vector2 = map.get_viewport().get_visible_rect().size
	var ground: Rect2 = map.ground_rect.grow(0.01)
	var land: Rect2 = map.ground_rect.merge(map.backdrop_rect).grow(0.01)
	var boxes: Array[AABB] = []
	for piece in map.backdrop_pieces:
		if piece["data"]["shape"] == "box":
			boxes.append(piece["aabb"])
	for i in 5:
		for j in 5:
			var point := Vector2(size.x * i / 4.0, size.y * j / 4.0)
			var origin: Vector3 = map.camera.project_ray_origin(point)
			var dir: Vector3 = map.camera.project_ray_normal(point)
			var hit: Variant = null
			var level := 0.0  # find where the ray meets the rising ground
			for iteration in 6:
				hit = Plane(Vector3.UP, level).intersects_ray(origin, dir)
				if hit == null:
					return false
				level = map.terrain.height_at(hit.x)
			var spot := Vector2(hit.x, hit.z)
			if j == 0:
				if spot.x < land.position.x or spot.x > land.end.x:
					return false
			elif not ground.has_point(spot):
				var behind := false
				for box in boxes:
					if box.intersects_ray(origin, dir) != null:
						behind = true
						break
				if not behind:
					return false
	return true


## A point standing on the ground at (x, z).
func _ground_point(map: Node3D, x: float, z: float) -> Vector3:
	return Vector3(x, map.terrain.height_at(x), z)


func _hangul_plants() -> Array:
	return Content.mountain("hallasan")["foraging"]["plants"]["kinds"]


func test_terrain_data() -> void:
	var config: Dictionary = Content.mountain("hallasan")["foraging"]
	check(config.has("terrain") and config.has("zones") and config.has("plants"), "hallasan.json parses with terrain, zones and plants")
	var terrain = load("res://scenes/foraging/terrain.gd").new(config["terrain"]["points"])
	var width := float(config["stage"]["width"])
	check(is_zero_approx(terrain.height_at(0.0)), "the ground starts at height 0 on the left edge")
	var rise: float = terrain.height_at(width) - terrain.height_at(0.0)
	check(absf(rise - 10.0) < 0.5, "the ground rises about 10 m left to right (%.2f)" % rise)
	var max_slope := 0.0
	var smooth := true
	var rising := true
	var previous: float = terrain.height_at(-12.0)
	var previous_slope := 0.0
	var x := -12.0
	while x <= width + 12.0:
		var h: float = terrain.height_at(x)
		max_slope = maxf(max_slope, absf(rad_to_deg(atan(terrain.slope_at(x)))))
		if h < previous - 0.0001:
			rising = false
		# slope is continuous: no steps or kinks
		var s: float = terrain.slope_at(x)
		if absf(s - previous_slope) > 0.05:
			smooth = false
		previous = h
		previous_slope = s
		x += 0.1
	check(max_slope < 30.0, "max slope is under 30 degrees (%.1f)" % max_slope)
	check(rising, "the ground never dips on the way up")
	check(smooth, "the slope changes smoothly (no steps)")
	# The numeric slope agrees with the analytic one.
	var numeric: float = (terrain.height_at(30.01) - terrain.height_at(29.99)) / 0.02
	check(absf(numeric - terrain.slope_at(30.0)) < 0.001, "slope_at matches height_at")
	_section_done("test_terrain_data")


func test_zones_data() -> void:
	var config: Dictionary = Content.mountain("hallasan")["foraging"]
	var zones: Array = config["zones"]
	check(zones.size() == 3, "three zones")
	var edge := 0.0
	var contiguous := true
	for zone in zones:
		if not is_equal_approx(float(zone["x"][0]), edge):
			contiguous = false
		edge = float(zone["x"][1])
	check(contiguous and is_equal_approx(edge, float(config["stage"]["width"])), "zones cover x 0-64 with no gaps or overlaps")
	check(zones[0]["id"] == "lower_forest" and zones[1]["id"] == "mid_slope" and zones[2]["id"] == "alpine", "zones are lower forest, mid slope, alpine")
	check(float(zones[1]["x"][0]) == 28.0 and float(zones[2]["x"][0]) == 44.0, "zone edges at 28 and 44")
	check(zones[0]["tint"] != zones[1]["tint"] and zones[1]["tint"] != zones[2]["tint"], "zones have different tints")
	_section_done("test_zones_data")


func _zone_range(zone_id: String) -> Array:
	for zone in Content.mountain("hallasan")["foraging"]["zones"]:
		if zone["id"] == zone_id:
			return zone["x"]
	return []


func _placed() -> Array:
	return Content.mountain("hallasan")["foraging"]["plants"]["placed"]


## How many plants each kind must have: one per letter token of a target's
## name (repeats count), 2 per decoy.
func _expected_counts() -> Dictionary:
	var counts := {}
	for kind in _hangul_plants():
		counts[kind["id"]] = Hangul.tiles_for(kind["name"]).size() if kind["kind"] == "target" else 2
	return counts


## The letters of the given placed entries, left to right.
func _x_order(entries: Array) -> Array:
	var sorted := entries.duplicate()
	sorted.sort_custom(func(a, b): return float(a["x"]) < float(b["x"]))
	return sorted.map(func(e): return e["letter"])


func test_plants_data() -> void:
	var config: Dictionary = Content.mountain("hallasan")["foraging"]
	var kinds := _hangul_plants()
	var placed := _placed()
	check(kinds.size() == 10, "10 plant kinds")
	var known := Content.known_letters(1)
	var kind_ok := true
	var by_id := {}
	for kind in kinds:
		by_id[kind["id"]] = kind
		check(not kind.has("count") and not kind.has("required") and not kind.has("positions"), "%s has no count/required/positions (plants are in 'placed')" % kind["name"])
		check(["target", "decoy"].has(kind["kind"]), "%s has a valid kind (target or decoy; a decoy's harm or reward is rolled)" % kind["name"])
		check(["hanging", "sprouting", "unfurling", "on_top"].has(kind["letter_style"]), "%s has a letter_style" % kind["name"])
		if kind["kind"] == "decoy":
			kind_ok = kind_ok and kind.has("injury") and kind.has("gore") and not kind.has("reward") and not kind.has("charm") and not kind.has("hint") and not kind.has("damage_units")
		else:
			kind_ok = kind_ok and not kind.has("injury") and not kind.has("gore") and not kind.has("damage_units")
		check(_zone_range(kind["zone"]).size() == 2, "%s names a real zone" % kind["name"])
		if kind["kind"] == "target":
			var unknown := Hangul.unknown_letters(kind["name"], known)
			check(unknown.size() <= 2, "%s needs at most 2 unknown letters" % kind["name"])
	check(kind_ok, "a decoy kind has an injury id and a gore id and no per-kind damage_units or old reward field; a target has none of them")

	# Counts: one plant per letter token for a target, 2 for a decoy, 36 in all.
	var expected := {"ma": 2, "meoru": 4, "minari": 6, "gosari": 6, "gobi": 4, "simiro": 6,
			"keuncheonnamseong": 2, "butsunnamu": 2, "norugui": 2, "deulchuknamu": 2}
	check(_expected_counts() == expected, "the letter-token counts are 마 2, 머루 4, 미나리 6, 고사리 6, 고비 4, 시로미 6, decoys 2")
	check(placed.size() == 36, "exactly 36 plants (%d)" % placed.size())
	var target_letter_plants := 0
	var letter_plants := 0
	for entry in placed:
		if entry.has("letter"):
			letter_plants += 1
			if by_id[entry["kind"]]["kind"] == "target":
				target_letter_plants += 1
	check(target_letter_plants == 28, "28 target letter plants (%d)" % target_letter_plants)
	check(letter_plants == 36, "every one of the 36 plants carries a letter (%d)" % letter_plants)
	var targets := []
	for kind in kinds:
		if kind["kind"] == "target":
			targets.append(kind["name"])
	check(targets == ["마", "머루", "미나리", "고사리", "고비", "시로미"], "the targets are the six named in the brief")

	var half_depth := float(config["stage"]["depth"]) / 2.0
	var starts: Array[Vector2] = []
	for id in config["start"]:
		starts.append(Vector2(float(config["start"][id][0]), float(config["start"][id][1])))
	var by_kind := {}
	for entry in placed:
		check(by_id.has(entry["kind"]), "a placed plant names a real kind (%s)" % entry["kind"])
		if not by_id.has(entry["kind"]):
			continue
		if not by_kind.has(entry["kind"]):
			by_kind[entry["kind"]] = []
		by_kind[entry["kind"]].append(entry)
	for id in expected:
		check(by_kind.get(id, []).size() == int(expected[id]), "%s has %d plants" % [by_id[id]["name"], expected[id]])

	var font_path := "res://art/fonts/NotoSansKR-VariableFont_wght.ttf"
	var font: Font = load(font_path)
	var zone_ok := true
	var stage_ok := true
	var letters_ok := true
	var glyphs_ok := true
	for id in by_kind:
		var kind: Dictionary = by_id[id]
		var zone_x := _zone_range(kind["zone"])
		for entry in by_kind[id]:
			var x := float(entry["x"])
			var z := float(entry["z"])
			zone_ok = zone_ok and x >= float(zone_x[0]) + 1.0 and x <= float(zone_x[1]) - 1.0
			stage_ok = stage_ok and absf(z) <= half_depth - 1.0
			var letter := String(entry.get("letter", ""))
			letters_ok = letters_ok and letter.length() == 1
			glyphs_ok = glyphs_ok and font != null and letter.length() == 1 and font.has_char(letter.unicode_at(0))
	check(zone_ok, "every plant is inside its kind's zone (1 m from the edges)")
	check(stage_ok, "every plant is on the stage")
	check(letters_ok, "every plant, target or decoy, carries exactly one letter")
	check(glyphs_ok, "the font has every letter the plants carry")
	check(FileAccess.file_exists(font_path) and font is FontFile, "the font file exists and loads as a FontFile")

	# The letters of each target kind are exactly the tokens of its name.
	var multiset_ok := true
	for id in by_kind:
		if by_id[id]["kind"] != "target":
			continue
		var carried := []
		for entry in by_kind[id]:
			carried.append(String(entry["letter"]))
		carried.sort()
		var wanted: Array = Array(Hangul.tiles_for(by_id[id]["name"]))
		wanted.sort()
		if carried != wanted:
			multiset_ok = false
			print("  letters of %s: %s, wanted %s" % [id, carried, wanted])
	check(multiset_ok, "each target's plants carry exactly the letters of its name (repeats included)")

	# Placement rules.
	var same_ok := true
	var all_ok := true
	var start_ok := true
	for i in placed.size():
		var a := Vector2(float(placed[i]["x"]), float(placed[i]["z"]))
		for start in starts:
			if a.distance_to(start) < 6.0:
				start_ok = false
		for j in range(i + 1, placed.size()):
			var b := Vector2(float(placed[j]["x"]), float(placed[j]["z"]))
			if a.distance_to(b) < 2.0:
				all_ok = false
			if placed[i]["kind"] == placed[j]["kind"] and by_id[placed[i]["kind"]]["kind"] == "target" and a.distance_to(b) < 4.0:
				same_ok = false
	check(same_ok, "two target plants of the same kind are at least 4 m apart (decoys may stand side by side)")
	check(all_ok, "no two plants are closer than 2 m")
	check(start_ok, "no plant is within 6 m of a traveler's start")
	var spread_ok := true
	var order_ok := true
	for id in by_kind:
		if by_id[id]["kind"] != "target":
			continue
		var zone_x := _zone_range(by_id[id]["zone"])
		var low := INF
		var high := -INF
		for entry in by_kind[id]:
			low = minf(low, float(entry["x"]))
			high = maxf(high, float(entry["x"]))
		if high - low < 0.6 * (float(zone_x[1]) - float(zone_x[0])):
			spread_ok = false
			print("  %s spans only %.1f m" % [id, high - low])
		if _x_order(by_kind[id]) == Array(Hangul.tiles_for(by_id[id]["name"])):
			order_ok = false
			print("  %s letters run in word order along x" % id)
	check(spread_ok, "each target kind's plants span at least 60% of its zone's width")
	check(order_ok, "no word's letters run in word order from left to right")

	# Scenery sits in the alpine zone and keeps clear of the plants.
	var alpine := _zone_range("alpine")
	var trees_ok := true
	for pos in config["scenery"]["gusangnamu"]["positions"]:
		var tree := Vector2(float(pos[0]), float(pos[1]))
		if tree.x < float(alpine[0]) or tree.x > float(alpine[1]):
			trees_ok = false
		for entry in placed:
			if tree.distance_to(Vector2(float(entry["x"]), float(entry["z"]))) < 2.5:
				trees_ok = false
	check(trees_ok, "구상나무 stand only in the alpine zone, clear of the plants")
	_section_done("test_plants_data")


func test_terrain_scene() -> void:
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var terrain = map.terrain

	# Travelers stand on the ground at their start.
	for t in map.travelers.values():
		check(absf(t.global_position.y - terrain.height_at(t.global_position.x)) < 0.12, "%s starts standing on the ground" % t.name)

	# Walking the whole map left to right: the traveler follows the hill.
	var p: CharacterBody3D = map.player
	p.global_position = _ground_point(map, 1.0, 0.0)
	var follows := true
	var worst := 0.0
	for i in 2000:
		p.drive(Vector2.RIGHT, 1.0 / 60.0)
		worst = maxf(worst, absf(p.global_position.y - terrain.height_at(p.global_position.x)))
		if worst > 0.2:
			follows = false
			break
	check(follows, "walking right keeps the player on the ground (worst error %.3f)" % worst)
	check(p.global_position.x > 40.0, "the player climbs well past the mid slope (x=%.1f)" % p.global_position.x)
	check(p.global_position.y > 6.0, "the player ends up high on the hill (y=%.1f)" % p.global_position.y)
	var top_x := p.global_position.x
	for i in 600:
		p.drive(Vector2.LEFT, 1.0 / 60.0)
		worst = maxf(worst, absf(p.global_position.y - terrain.height_at(p.global_position.x)))
	check(worst < 0.2 and p.global_position.x < top_x - 10.0, "walking back down sticks to the ground (worst error %.3f)" % worst)

	# Uphill and downhill cover the same distance in x.
	p.global_position = _ground_point(map, 34.0, 0.0)
	for i in 5:
		p.drive(Vector2.ZERO, 1.0 / 60.0)
	var x0 := p.global_position.x
	for i in 30:
		p.drive(Vector2.RIGHT, 1.0 / 60.0)
	var uphill := p.global_position.x - x0
	check(absf(uphill - 4.5 * 0.5) < 0.1, "walking uphill keeps full speed along x (%.2f m in 0.5 s)" % uphill)

	# The camera follows the player's height.
	p.global_position = _ground_point(map, 3.0, 0.0)
	map.update_camera(0.0, true)
	var low_cam: float = map.camera.global_position.y
	p.global_position = _ground_point(map, 55.0, 0.0)
	await get_tree().physics_frame
	map.update_camera(0.0, true)
	check(map.camera.global_position.y > low_cam + 5.0, "the camera rises with the player")

	# Plants.
	check(map.plants.size() == 36, "36 plants are built")
	check(map.get_node("Plants").get_child_count() == 36, "36 plants are in the Plants node")
	var letters_ok := true
	var labels_total := 0
	var heights_ok := true
	var font_ok := true
	var boxes_ok := true
	var big_ok := true
	var carried := {}  # kind id -> letters shown
	for plant in map.plants:
		heights_ok = heights_ok and is_equal_approx(plant.position.y, terrain.height_at(plant.position.x))
		var labels: Array = plant.find_children("*", "Label3D", true, false)
		labels_total += labels.size()
		for mesh in plant.find_children("*", "MeshInstance3D", true, false):
			boxes_ok = boxes_ok and not (mesh.mesh is BoxMesh)
		letters_ok = letters_ok and labels.size() == 1 and labels[0].text == plant.letter and plant.letter.length() == 1
		for l in labels:
			font_ok = font_ok and l.font != null and l.font.resource_path.ends_with("NotoSansKR-VariableFont_wght.ttf")
			big_ok = big_ok and l.pixel_size * l.font_size >= 1.0
			if plant.kind == "target":
				if not carried.has(plant.kind_id):
					carried[plant.kind_id] = []
				carried[plant.kind_id].append(l.text)
	check(letters_ok, "every plant, target or decoy, shows exactly one letter")
	var words_ok := true
	for kind in _hangul_plants():
		if kind["kind"] == "target":
			var shown: Array = carried.get(kind["id"], [])
			shown.sort()
			var wanted: Array = Array(Hangul.tiles_for(kind["name"]))
			wanted.sort()
			words_ok = words_ok and shown == wanted
	check(words_ok, "the letters shown on each target's plants are the letters of its name")
	check(labels_total == 36, "36 letter labels, one per plant (%d)" % labels_total)
	check(heights_ok, "every plant sits at terrain height")
	check(font_ok, "every letter uses the Noto Sans KR font")
	check(big_ok, "every letter is about a metre tall")
	check(boxes_ok, "no plant has a box (backing card) behind its letter")
	var styles := {}
	for plant in map.plants:
		styles[plant.letter_style] = true
	check(styles.size() == 4, "all four letter styles are in use")

	# Scenery and props.
	check(map.get_node("Scenery").get_child_count() == 12, "12 구상나무 as scenery")
	var scenery_clean := map.get_node("Scenery").find_children("*", "Label3D", true, false).is_empty()
	check(scenery_clean, "the trees carry no letters")
	var props_clear := true
	var alpine_trees := false
	for prop in map.get_node("Props").get_children():
		var spot := Vector2(prop.position.x, prop.position.z)
		for point in map.keep_out:
			if spot.distance_to(point) < map.KEEP_OUT - 0.01:
				props_clear = false
		if map.zone_at(prop.position.x)["id"] == "alpine" and prop.get_child_count() == 2:
			alpine_trees = true
	check(props_clear, "props keep clear of plants, trees and the starts")
	check(not alpine_trees, "no random forest props in the alpine zone")

	# Hover tooltip. Needs the physics server to know the pick areas.
	await get_tree().physics_frame
	await get_tree().physics_frame
	p.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	var shown_for := {}
	var hover_points: Array[Vector2] = []  # one screen point per plant that can be found
	var hover_plants: Array[Node3D] = []
	var size: Vector2 = map.get_viewport().get_visible_rect().size
	for plant in map.plants:
		var screen: Vector2 = map.camera.unproject_position(plant.global_position + Vector3(0, 0.5, 0))
		if screen.x < 0 or screen.y < 0 or screen.x > size.x or screen.y > size.y:
			continue
		var found = map.plant_at(screen)
		if found != null:
			map.update_hover(screen)
			shown_for[found.plant_name] = [map._tooltip.visible, map._tooltip_label.text]
			if not hover_plants.has(found):
				hover_plants.append(found)
				hover_points.append(screen)
	check(not shown_for.is_empty(), "plants can be found under the mouse")
	var tips_ok := true
	for found_name in shown_for:
		var expected := "???"
		for kind in _hangul_plants():
			if kind["name"] == found_name and kind["kind"] == "target":
				expected = kind["hover_name"]
		if not (shown_for[found_name][0] and shown_for[found_name][1] == expected):
			tips_ok = false
	check(tips_ok, "tooltip shows the English name for targets and ??? for decoys (%s)" % str(shown_for.keys()))
	# Over nothing: the tooltip that was showing goes away.
	check(map._tooltip.visible, "a tooltip is showing before the mouse moves off the plant")
	var empty_found := false
	var empty_point := Vector2.ZERO
	for gx in 9:
		for gy in 9:
			var point := Vector2(size.x * (gx + 0.5) / 9.0, size.y * (gy + 0.5) / 9.0)
			if not empty_found and map.plant_at(point) == null:
				map.update_hover(point)
				empty_point = point
				empty_found = true
	check(empty_found and not map._tooltip.visible, "no tooltip over nothing")

	# Tooltip timing, driven by simulated time (the second argument is the time
	# since the last call).
	check(hover_points.size() >= 2, "two plants can be found under the mouse (%d)" % hover_points.size())
	if hover_points.size() >= 2:
		var on_plant: Vector2 = hover_points[0]
		var other_plant: Vector2 = hover_points[1]
		var tip: PanelContainer = map._tooltip
		map.update_hover(empty_point, 0.0)
		map.update_hover(on_plant, 0.0)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "the tooltip shows when the mouse enters a plant")
		map.update_hover(on_plant, 0.2)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "solid at 0.2 s")
		var saw_visible := false
		var saw_hidden := false
		for step in 8:  # 0.25 s to 0.45 s, sampled mid-step
			map.update_hover(on_plant, 0.075 if step == 0 else 0.025)
			map.update_hover(on_plant, 0.025)
			if tip.visible:
				saw_visible = true
			else:
				saw_hidden = true
		check(saw_visible and saw_hidden, "flickers between 0.25 s and 0.45 s (visible %s, hidden %s)" % [saw_visible, saw_hidden])
		map.update_hover(on_plant, 0.05)
		check(not tip.visible, "gone at 0.5 s")
		map.update_hover(on_plant, 5.0)
		map.update_hover(on_plant, 0.0)
		check(not tip.visible, "it does not return while the mouse stays on the same plant")
		map.update_hover(empty_point, 0.05)
		check(not tip.visible, "leaving the plant hides it")
		map.update_hover(on_plant, 0.0)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "it shows again after the mouse leaves and re-enters the plant")
		map.update_hover(on_plant, 0.55)
		check(not tip.visible, "the re-entered tooltip also goes away")
		map.update_hover(other_plant, 0.0)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "moving straight onto another plant starts a new tooltip at once")
	map.free()
	_section_done("test_terrain_scene")


func _config() -> Dictionary:
	return Content.mountain("hallasan")["foraging"]


## The letters used by the six target words.
func _allowed_letters() -> Array[String]:
	var allowed: Array[String] = []
	for kind in _hangul_plants():
		if kind["kind"] == "target":
			for tile in Hangul.tiles_for(kind["name"]):
				if not allowed.has(tile):
					allowed.append(tile)
	return allowed


func test_decoy_letters() -> void:
	var allowed := _allowed_letters()
	check(allowed.size() == 11, "the target words use 11 different letters (%d)" % allowed.size())
	var by_id := {}
	for kind in _hangul_plants():
		by_id[kind["id"]] = kind
	var per_kind := {}
	var decoys := 0
	var one_each := true
	for entry in _placed():
		if by_id[entry["kind"]]["kind"] == "target":
			continue
		decoys += 1
		var letter := String(entry.get("letter", ""))
		one_each = one_each and letter.length() == 1 and allowed.has(letter)
		if not per_kind.has(entry["kind"]):
			per_kind[entry["kind"]] = []
		per_kind[entry["kind"]].append(letter)
	check(decoys == 8, "8 decoy plants (%d)" % decoys)
	check(one_each, "each decoy has exactly one letter, from the target words' letters")
	var seen := {}
	for id in per_kind:
		for letter in per_kind[id]:
			seen[letter] = true
	check(seen.size() >= 6, "the decoys do not all repeat one letter (%d different)" % seen.size())
	_section_done("test_decoy_letters")


## A point `dist` metres from `spot` (over x, z) on the stage, at which no
## target plant of a kind other than `own` is within the discovery radius, and,
## when `own` is empty, no target plant at all. Vector2.INF if there is none.
func _probe(spot: Vector2, dist: float, own: String) -> Vector2:
	var config := _config()
	var radius := float(config["discovery"]["radius"])
	var half_depth := float(config["stage"]["depth"]) / 2.0
	var by_id := {}
	for kind in _hangul_plants():
		by_id[kind["id"]] = kind
	for degrees in range(0, 360, 15):
		var point := spot + Vector2.from_angle(deg_to_rad(degrees)) * dist
		if point.x < 1.0 or point.x > float(config["stage"]["width"]) - 1.0 or absf(point.y) > half_depth - 1.0:
			continue
		var clear := true
		for entry in _placed():
			if by_id[entry["kind"]]["kind"] != "target" or entry["kind"] == own:
				continue
			if point.distance_to(Vector2(float(entry["x"]), float(entry["z"]))) <= radius + 0.05:
				clear = false
		if clear:
			return point
	return Vector2.INF


## First placed plant of a kind, as (x, z).
func _spot_of(kind_id: String, index: int = 0) -> Vector2:
	var found := 0
	for entry in _placed():
		if entry["kind"] == kind_id:
			if found == index:
				return Vector2(float(entry["x"]), float(entry["z"]))
			found += 1
	return Vector2.INF


func _new_discovery():
	return load("res://scenes/foraging/discovery.gd").new(_config()["discovery"], _config()["plants"])


## Some point `dist` m from one of a kind's plants where no other target is near. Returns Vector2.INF if neither plant has one.
func _near_kind(kind_id: String, dist: float) -> Vector2:
	for index in 2:
		var point := _probe(_spot_of(kind_id, index), dist, kind_id)
		if point != Vector2.INF:
			return point
	return Vector2.INF


func test_discovery_logic() -> void:
	var config := _config()
	check(is_equal_approx(float(config["discovery"]["radius"]), 3.0), "the discovery radius is 3.0 m in the data")
	check(is_equal_approx(float(config["discovery"]["fade_time"]), 0.4), "the discovery fade time is 0.4 s in the data")
	var d = _new_discovery()
	check(is_equal_approx(d.radius, 3.0) and is_equal_approx(d.fade_time, 0.4), "Discovery reads the radius and fade time from the data")
	check(d.entries.is_empty(), "the list is empty at the start")
	var starts: Array[Vector2] = []
	for id in config["start"]:
		starts.append(Vector2(float(config["start"][id][0]), float(config["start"][id][1])))
	d.update(starts, 0.1)
	check(d.entries.is_empty(), "no target is within the radius of either start position")

	# Syllable blocks, counted from the Korean names.
	var expected := {"ma": 1, "meoru": 2, "minari": 3, "gosari": 3, "gobi": 2, "simiro": 3}
	var all = _new_discovery()
	var every: Array[Vector2] = []
	for entry in _placed():
		every.append(Vector2(float(entry["x"]), float(entry["z"])))
	all.update(every, 0.0)
	var counts := {}
	var no_korean := true
	for entry in all.entries:
		counts[entry["id"]] = entry["syllables"]
		for key in entry:
			for ch in str(entry[key]):
				if ch.unicode_at(0) >= 0x1100:
					no_korean = false
	check(counts == expected, "syllable counts are 마 1, 머루 2, 미나리 3, 고사리 3, 고비 2, 시로미 3 (%s)" % str(counts))
	check(no_korean, "no list entry holds Korean text or a letter")
	check(all.entries.size() == 6, "walking up to everything discovers exactly the six targets (%d)" % all.entries.size())

	# One kind at a time.
	var near_ma := _near_kind("ma", 2.5)
	check(near_ma != Vector2.INF, "there is a spot 2.5 m from a 마 with no other target near")
	var outside := _near_kind("ma", 3.3)
	check(outside != Vector2.INF, "there is a spot 3.3 m from a 마 with no other target near")
	if near_ma == Vector2.INF or outside == Vector2.INF:
		return
	var far: Vector2 = Vector2(float(config["stage"]["width"]) - 1.0, 0.0)
	d = _new_discovery()
	d.update([far, outside], 0.1)
	check(d.entries.is_empty(), "3.3 m from a 마 plant discovers nothing")
	var found: Array[String] = d.update([far, near_ma], 0.1)
	check(found == ["ma"] and d.discovered_ids() == ["ma"], "the second traveler within the radius discovers 마, and only 마")
	d = _new_discovery()
	d.update([near_ma, far], 0.1)
	check(d.discovered_ids() == ["ma"], "the first traveler can discover too")
	d.update([far, far], 0.1)
	check(d.is_discovered("ma") and d.entries.size() == 1, "a discovered kind stays discovered")
	d.update([near_ma, far], 0.1)
	check(d.entries.size() == 1, "walking back up to it adds nothing twice")

	# Order of discovery is kept.
	var near_meoru := _near_kind("meoru", 2.5)
	var near_simiro := _near_kind("simiro", 2.5)
	check(near_meoru != Vector2.INF and near_simiro != Vector2.INF, "there are clean spots near 머루 and 시로미")
	d = _new_discovery()
	d.update([near_simiro, far], 0.1)
	d.update([near_meoru, far], 0.1)
	d.update([near_ma, far], 0.1)
	check(d.discovered_ids() == ["simiro", "meoru", "ma"], "entries keep the order they were discovered in (%s)" % str(d.discovered_ids()))

	# Decoys discover nothing.
	var decoy_ok := true
	var decoys_tried := 0
	var by_id := {}
	for kind in _hangul_plants():
		by_id[kind["id"]] = kind
	for entry in _placed():
		if by_id[entry["kind"]]["kind"] == "target":
			continue
		var point := _probe(Vector2(float(entry["x"]), float(entry["z"])), 2.0, "")
		if point == Vector2.INF:
			continue
		decoys_tried += 1
		var fresh = _new_discovery()
		fresh.update([point, point], 0.1)
		decoy_ok = decoy_ok and fresh.entries.is_empty()
	check(decoys_tried > 0 and decoy_ok, "standing next to a decoy discovers nothing (%d tried)" % decoys_tried)

	# A new Discovery (a scene restart) starts empty.
	check(_new_discovery().entries.is_empty(), "a new Discovery starts empty")

	# Fade-in.
	d = _new_discovery()
	d.update([near_ma, far], 0.1)
	check(is_zero_approx(d.opacity(d.entries[0])), "a new entry starts invisible")
	d.update([far, far], 0.2)
	check(d.opacity(d.entries[0]) > 0.0 and d.opacity(d.entries[0]) < 1.0, "it is part way after 0.2 s")
	d.update([far, far], 0.3)
	check(is_equal_approx(d.opacity(d.entries[0]), 1.0), "it is solid after 0.4 s")
	_section_done("test_discovery_logic")


func test_discovery_scene() -> void:
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	var hud: CanvasLayer = map.discovery_hud
	check(hud != null and hud is CanvasLayer, "the foraging scene has a discovery HUD (CanvasLayer)")
	check(map.discovery.entries.is_empty() and hud.find_children("*", "Label", true, false).is_empty(), "the list is empty when the scene starts")
	map.step(Vector2.ZERO, 0.1)
	check(map.discovery.entries.is_empty(), "standing at the start discovers nothing")
	var near_ma := _near_kind("ma", 2.5)
	var near_meoru := _near_kind("meoru", 2.5)
	check(near_ma != Vector2.INF and near_meoru != Vector2.INF, "clean spots exist for 마 and 머루")
	if near_ma == Vector2.INF or near_meoru == Vector2.INF:
		map.free()
		return
	# Put both travelers on a spot and tick.
	for spot in [near_ma, near_meoru]:
		for id in map.travelers:
			map.travelers[id].global_position = _ground_point(map, spot.x, spot.y)
		map.step(Vector2.ZERO, 0.1)
	check(map.discovery.discovered_ids() == ["ma", "meoru"], "walking up to 마 then 머루 lists them in that order")
	for i in 10:
		map.step(Vector2.ZERO, 0.1)
	var labels: Array = hud.find_children("*", "Label", true, false)
	var texts: Array = labels.map(func(l): return l.text)
	check(texts == ["Korean yam", "wild grape"], "the HUD shows the English names (%s)" % str(texts))
	var rows: Array = hud.find_children("Blocks", "HBoxContainer", true, false)
	var blocks: Array = rows.map(func(r): return r.get_child_count())
	check(blocks == [1, 2], "마 shows 1 block and 머루 2 (%s)" % str(blocks))
	var plain := true
	for row in rows:
		for block in row.get_children():
			plain = plain and block is Panel and block.find_children("*", "Label", true, false).is_empty()
	check(plain, "the blocks are empty squares with no text in them")
	var korean := false
	for l in labels:
		for ch in str(l.text):
			if ch.unicode_at(0) >= 0x1100:
				korean = true
	check(not korean, "no Korean text or letters are shown in the list")
	var big := true
	for l in labels:
		big = big and l.get_theme_font_size("font_size") >= 20
	check(big, "the names use a readable font size")
	# The HUD sits at the top left.
	var top_left := true
	for child in hud.get_children():
		top_left = top_left and child is Control and child.position.x < 40.0 and child.position.y < 40.0
	check(top_left, "the list is at the top left")
	# A new scene starts with an empty list.
	map.free()
	var again: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(again)
	again.set_physics_process(false)
	check(again.discovery.entries.is_empty(), "a restarted scene starts with an empty list")
	again.free()
	_section_done("test_discovery_scene")


func test_backdrop_data() -> void:
	var config := _config()
	var backdrop: Dictionary = config["backdrop"]
	var pieces: Array = backdrop["pieces"]
	check(pieces.size() > 0 and float(backdrop["depth"]) > 0.0, "the backdrop is in hallasan.json")
	var terrain = load("res://scenes/foraging/terrain.gd").new(config["terrain"]["points"])
	var fields_ok := true
	var above_ok := true
	var left := INF
	var right := -INF
	for piece in pieces:
		for field in ["shape", "x", "z", "size", "offset", "color"]:
			fields_ok = fields_ok and piece.has(field)
		if not fields_ok:
			break
		var x := float(piece["x"])
		var half := float(piece["size"][0]) * float(piece.get("stretch_x", 1.0)) / (1.0 if piece["shape"] == "cone" else 2.0)
		var base: float = terrain.height_at(x) + float(piece["offset"])
		var top: float = base + float(piece["size"][1])
		above_ok = above_ok and float(piece["offset"]) >= 0.0 and base >= terrain.height_at(x)
		above_ok = above_ok and top >= terrain.height_at(x - half) and top >= terrain.height_at(x + half)
		if piece["shape"] == "box":
			left = minf(left, x - half)
			right = maxf(right, x + half)
	check(fields_ok, "every backdrop piece has shape, x, z, size, offset and color")
	check(above_ok, "every backdrop piece sits above the terrain at its x (and across its width)")
	var ground_x0 := -float(config["apron"]["sides"])
	var ground_x1 := float(config["stage"]["width"]) + float(config["apron"]["sides"])
	check(left <= ground_x0 and right >= ground_x1, "the ridge boxes cover the ground's full width (%.0f to %.0f)" % [left, right])
	_section_done("test_backdrop_data")


func test_fade_and_tooltip_data() -> void:
	var config := _config()
	check(is_equal_approx(float(config["prop_fade"]["opacity"]), 0.25) and is_equal_approx(float(config["prop_fade"]["time"]), 0.2), "prop fade opacity and time are in the data")
	check(is_equal_approx(float(config["tooltip"]["steady_time"]), 0.25) and is_equal_approx(float(config["tooltip"]["flicker_time"]), 0.2) and is_equal_approx(float(config["tooltip"]["flicker_rate"]), 20.0) and not config["tooltip"].has("show_time") and not config["tooltip"].has("fade_time"), "tooltip steady (halved), flicker time (halved) and rate (doubled) are in the data; the old show/fade values are gone")
	_section_done("test_fade_and_tooltip_data")


func test_names_and_colors_data() -> void:
	var kinds := _hangul_plants()
	var banned := ["Chinese", "Japanese", "Indian", "Siberian", "European", "American", "Mongolian", "Russian", "Himalayan"]
	var names_ok := true
	for kind in kinds:
		for field in ["hover_name", "description"]:
			var text := String(kind.get(field, ""))
			for word in banned:
				if text.containsn(word):
					names_ok = false
					print("  nationality in %s %s: %s" % [kind["id"], field, text])
	check(names_ok, "no hover name or plant description names a nationality other than Korean")
	var by_id := {}
	for kind in kinds:
		by_id[kind["id"]] = kind
	check(by_id["ma"]["hover_name"] == "Korean yam", "마 hovers as Korean yam")
	check(by_id["butsunnamu"]["hover_name"] == "Korean star anise", "붓순나무 hovers as Korean star anise")
	# Every plant kind has its own colour; hanging kinds also have their own fruit colour.
	var seen := {}
	var distinct := true
	for kind in kinds:
		var key := str(kind["color"])
		if seen.has(key):
			distinct = false
			print("  colour shared by %s and %s" % [seen[key], kind["id"]])
		seen[key] = kind["id"]
	check(distinct, "no two plant kinds share the same colour")
	var Plant = load("res://scenes/foraging/plant.gd")
	var fruits := {}
	var fruits_distinct := true
	for kind in kinds:
		if kind["letter_style"] != "hanging":
			continue
		var fruit: Color = Plant.fruit_color(kind)
		var key := fruit.to_html(false)
		if fruits.has(key):
			fruits_distinct = false
		fruits[key] = kind["id"]
	check(fruits_distinct, "no two hanging kinds share the same fruit colour")
	var meoru: Color = Plant.fruit_color(by_id["meoru"])
	var deulchuk: Color = Plant.fruit_color(by_id["deulchuknamu"])
	check(meoru.r > meoru.g and meoru.b > meoru.g, "머루 fruit is purple")
	check(deulchuk.b > deulchuk.r and deulchuk.b > deulchuk.g and maxf(deulchuk.r, maxf(deulchuk.g, deulchuk.b)) < 0.4, "들쭉나무 fruit is blue-black")
	check(absf(meoru.r - deulchuk.r) + absf(meoru.g - deulchuk.g) + absf(meoru.b - deulchuk.b) > 0.4, "들쭉나무 fruit looks clearly different from 머루")
	var butsun: Color = Plant.fruit_color(by_id["butsunnamu"])
	check(butsun.r > 0.6 and butsun.r > butsun.g and butsun.g > butsun.b and butsun.b < 0.3, "붓순나무 fruit is a warm brown-orange")
	var far_apart := true
	var hanging: Array[Color] = []
	for kind in kinds:
		if kind["letter_style"] == "hanging":
			hanging.append(Plant.fruit_color(kind))
	check(hanging.size() == 3, "three hanging kinds: 머루, 붓순나무, 들쭉나무")
	for i in hanging.size():
		for j in range(i + 1, hanging.size()):
			var d := absf(hanging[i].r - hanging[j].r) + absf(hanging[i].g - hanging[j].g) + absf(hanging[i].b - hanging[j].b)
			if d <= 0.4:
				far_apart = false
	check(far_apart, "every pair of hanging fruit colours is clearly different")
	_section_done("test_names_and_colors_data")


func test_backdrop_scene() -> void:
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	var pieces: Array = _config()["backdrop"]["pieces"]
	check(map.backdrop_pieces.size() == pieces.size() and map.get_node("Backdrop").get_child_count() == pieces.size(), "one backdrop node per piece in the data (%d)" % pieces.size())
	var above := true
	for piece in map.backdrop_pieces:
		above = above and piece["base"] >= map.terrain.height_at(piece["data"]["x"]) and piece["top"] > piece["base"]
		above = above and piece["aabb"].end.y >= piece["top"] - 0.001
	check(above, "every backdrop node sits above the terrain at its x")
	# Camera at every position along the map: left to right, far wall, middle, near wall.
	var half_d: float = map.stage_depth / 2.0
	var failures: Array[String] = []
	var x := 0.0
	while x <= map.stage_width + 0.001:
		for z in [-half_d, 0.0, half_d]:
			map.player.global_position = _ground_point(map, x, z)
			map.update_camera(0.0, true)
			if not _view_over_land(map):
				failures.append("(%.0f, %.0f)" % [x, z])
		x += 2.0
	check(failures.is_empty(), "no sky below the far, near, left or right edge from any camera position %s" % str(failures))
	map.free()
	_section_done("test_backdrop_scene")


func test_prop_fade() -> void:
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	var config := _config()
	var opacity := float(config["prop_fade"]["opacity"])
	check(is_equal_approx(map.fade_opacity, opacity) and is_equal_approx(map.fade_time, float(config["prop_fade"]["time"])), "the map reads the fade values from the data")
	# A tree in the lower forest, well clear of the stage edges.
	var tree: Node3D = null
	for prop in map.get_node("Props").get_children():
		if prop.get_child_count() == 2 and prop.position.x > 8.0 and prop.position.x < 24.0 and absf(prop.position.z) < 6.0:
			tree = prop
			break
	check(tree != null, "there is a tree to test with")
	if tree == null:
		map.free()
		return
	var tree_xz := Vector2(tree.position.x, tree.position.z)
	var away := _ground_point(map, 60.0, 0.0)
	map.partner.global_position = away
	map.player.global_position = _ground_point(map, tree_xz.x, tree_xz.y - 2.0)  # behind the tree, seen from the camera
	map.update_prop_fade(0.0)
	check(is_equal_approx(tree.alpha, 1.0), "a prop has not started to fade at time 0")
	map.update_prop_fade(0.1)
	check(tree.alpha < 1.0 and tree.alpha > opacity, "halfway through the fade the tree is part way (%.2f)" % tree.alpha)
	map.update_prop_fade(0.1)
	check(is_equal_approx(tree.alpha, opacity), "a tree covering a traveler drops to the data opacity (%.2f)" % tree.alpha)
	var meshes := tree.find_children("*", "MeshInstance3D", true, false)
	var tinted := true
	for mesh in meshes:
		tinted = tinted and is_equal_approx(mesh.material_override.albedo_color.a, opacity)
	check(tinted, "every part of the tree is at that opacity")
	map.update_prop_fade(1.0)
	check(is_equal_approx(tree.alpha, opacity), "it stays there while it keeps covering")
	# The partner is covered too.
	map.player.global_position = away
	map.partner.global_position = _ground_point(map, tree_xz.x, tree_xz.y - 2.0)
	map.update_prop_fade(0.1)
	check(is_equal_approx(tree.alpha, opacity), "a tree covering the partner fades as well")
	# Moving out from behind it brings it back.
	map.partner.global_position = _ground_point(map, tree_xz.x + 8.0, tree_xz.y - 2.0)
	map.update_prop_fade(0.1)
	check(tree.alpha > opacity and tree.alpha < 1.0, "it fades back gradually (%.2f)" % tree.alpha)
	map.update_prop_fade(0.1)
	check(is_equal_approx(tree.alpha, 1.0), "it is fully solid again once it no longer covers anyone")
	var solid := true
	for mesh in meshes:
		solid = solid and mesh.material_override.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED
	check(solid, "a solid tree is back in the opaque pass")
	# A tree in front of the camera's view of nobody: a traveler standing nearer the camera does not fade it.
	map.player.global_position = _ground_point(map, tree_xz.x, tree_xz.y + 3.0)
	map.update_prop_fade(0.5)
	check(is_equal_approx(tree.alpha, 1.0), "a tree behind a traveler does not fade")

	# Plants never fade, even with a traveler right behind one and time passing.
	var plant: Node3D = map.plants[0]
	map.player.global_position = _ground_point(map, plant.position.x, plant.position.z - 2.0)
	for i in 10:
		map.update_prop_fade(0.1)
	var plants_solid := true
	for each in map.plants:
		for mesh in each.find_children("*", "MeshInstance3D", true, false):
			plants_solid = plants_solid and mesh.material_override.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED and is_equal_approx(mesh.material_override.albedo_color.a, 1.0)
		for label in each.find_children("*", "Label3D", true, false):
			plants_solid = plants_solid and is_equal_approx(label.modulate.a, 1.0)
	check(plants_solid, "plants and their letter labels never fade")
	check(not ("alpha" in plant), "a plant is not a fading prop")
	map.free()
	_section_done("test_prop_fade")


const PickingScript := preload("res://scenes/foraging/picking.gd")


func _new_picking():
	var config := _config()
	return PickingScript.new(config["picking"], config["plants"])


func test_picking_data() -> void:
	var block: Dictionary = _config().get("picking", {})
	check(not block.is_empty(), "hallasan.json has a picking block")
	for key in ["pick_radius", "walk_stuck_timeout", "steam_duration"]:
		check(block.get(key) is float and float(block[key]) > 0.0, "picking.%s is a positive number" % key)
	var color = block.get("steam_color")
	check(color is Array and color.size() == 3, "picking.steam_color is present with three channels")
	if color is Array and color.size() == 3:
		var in_range := true
		for channel in color:
			in_range = in_range and channel is float and channel >= 0.0 and channel <= 1.0
		check(in_range, "picking.steam_color channels are in 0..1")
	var p = _new_picking()
	check(is_equal_approx(p.pick_radius, float(block["pick_radius"])) and is_equal_approx(p.stuck_timeout, float(block["walk_stuck_timeout"])), "Picking reads the radius and stuck timeout from the data")
	check(is_equal_approx(p.steam_duration, float(block["steam_duration"])) and p.steam_color == Color(color[0], color[1], color[2]), "Picking reads the steam values from the data")
	_section_done("test_picking_data")


func test_picking_logic() -> void:
	var placed: Array = _config()["plants"]["placed"]
	var kinds := {}
	for kind in _config()["plants"]["kinds"]:
		kinds[kind["id"]] = kind["kind"]
	var p = _new_picking()
	check(p.plant_count() == 36 and p.letters_left() == 36, "36 plants start with their letters")
	check(p.basket.is_empty(), "the basket starts empty")
	# Every target letter, in pick order (the order is shuffled so it is not placement order).
	var order: Array[int] = []
	for i in placed.size():
		if kinds[placed[i]["kind"]] == "target":
			order.append(i)
	check(order.size() == 28, "there are 28 target plants")
	order.reverse()
	var expected: Array[String] = []
	var in_order := true
	for i in order:
		var result: Dictionary = p.pick(i)
		expected.append(placed[i]["letter"])
		in_order = in_order and result["result"] == "basket" and result["letter"] == placed[i]["letter"] and p.basket == expected
	check(in_order, "picking each of the 28 target letters adds exactly that letter, in pick order")
	check(p.basket.size() == 28 and p.letters_left() == 8, "28 in the basket, the 8 decoy letters left")
	# Decoys: nothing in the basket, the letter is gone.
	var decoys_ok := true
	for i in placed.size():
		if kinds[placed[i]["kind"]] == "target":
			continue
		var before: Array = p.basket.duplicate()
		var result: Dictionary = p.pick(i)
		decoys_ok = decoys_ok and result["result"] == "steam" and result["letter"] == placed[i]["letter"] and p.basket == before and not p.has_letter(i)
	check(decoys_ok, "picking a decoy adds nothing and marks its letter gone")
	check(p.letters_left() == 0 and p.basket.size() == 28, "all letters gone, basket unchanged by decoys")
	# Double pick.
	check(p.pick(order[0])["result"] == "none" and p.basket.size() == 28, "a letter can't be picked twice")
	check(not p.start_walk(order[0]), "a letterless plant is not a walk target")
	# Dead or restarting.
	var q = _new_picking()
	check(q.pick(0, false)["result"] == "none" and q.basket.is_empty() and q.has_letter(0), "a disallowed pick takes nothing")
	check(q.pick(-1)["result"] == "none" and q.pick(99)["result"] == "none", "out-of-range plants can't be picked")
	# A new Picking (a scene restart) is full again with an empty basket.
	check(_new_picking().letters_left() == 36 and _new_picking().basket.is_empty(), "a new Picking has all 36 letters and an empty basket")
	# Walking.
	var w = _new_picking()
	check(w.walk_update(5.0, 0.1) == "idle", "no walk, no update")
	check(w.start_walk(0) and w.walk_target == 0, "a click starts a walk")
	check(w.start_walk(3) and w.walk_target == 3, "another click retargets")
	check(w.walk_update(5.0, 0.1) == "walking" and w.walk_update(4.0, 0.1) == "walking", "closing in keeps walking")
	check(w.walk_update(w.pick_radius, 0.1) == "arrived" and w.walk_target == -1, "within the pick radius the walk ends as arrived")
	w.start_walk(0)
	var state := ""
	var ticks := 0
	while state != "stuck" and ticks < 100:
		state = w.walk_update(4.0, 0.1)
		ticks += 1
	check(state == "stuck" and w.walk_target == -1, "no progress ends the walk as stuck")
	check(absf(ticks * 0.1 - (w.stuck_timeout + 0.1)) < 0.15, "stuck fires after about the stuck timeout (%d ticks)" % ticks)
	w.start_walk(0)
	var moved := true
	for i in 50:  # a slow but steady approach is never stuck
		moved = moved and w.walk_update(20.0 - 0.1 * i, 0.1) == "walking"
	check(moved, "steady progress is never stuck")
	w.cancel_walk()
	check(w.walk_target == -1, "cancel_walk ends the walk")
	_section_done("test_picking_logic")


func test_steam_sound() -> void:
	var stream: AudioStreamWAV = load("res://scenes/foraging/steam_sound.gd").make()
	check(stream.format == AudioStreamWAV.FORMAT_16_BITS and not stream.stereo, "the tsss is 16-bit mono")
	var samples := stream.data.size() / 2
	var length := float(samples) / stream.mix_rate
	check(length > 0.2 and length < 1.0, "the tsss is a short burst (%.2f s)" % length)
	var peak_early := 0
	var peak_late := 0
	for i in samples:
		var v := absi(stream.data.decode_s16(i * 2))
		if i < samples / 4:
			peak_early = maxi(peak_early, v)
		elif i > samples * 3 / 4:
			peak_late = maxi(peak_late, v)
	check(peak_early > 1000 and peak_late < peak_early / 4, "it is audible and dies away (%d -> %d)" % [peak_early, peak_late])
	_section_done("test_steam_sound")


## The first plant on screen, nearest the player, that `wanted` accepts and the
## hover ray finds. Returns {"plant", "screen"} or {}.
func _visible_plant(map: Node3D, wanted: Callable) -> Dictionary:
	var size: Vector2 = map.get_viewport().get_visible_rect().size
	var best := {}
	var best_distance := INF
	for plant in map.plants:
		var screen: Vector2 = map.camera.unproject_position(plant.global_position + Vector3(0, 0.5, 0))
		if screen.x < 0 or screen.y < 0 or screen.x > size.x or screen.y > size.y or not wanted.call(plant):
			continue
		var distance: float = plant.global_position.distance_to(map.player.global_position)
		if map.plant_at(screen) == plant and distance < best_distance and plant.letter != "":
			best = {"plant": plant, "screen": screen}
			best_distance = distance
	return best


func _click_event(at: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = at
	return event


func _release_event(at: Vector2) -> InputEventMouseButton:
	var event := _click_event(at)
	event.pressed = false
	return event


## Ticks the map until the walk ends (or 10 s pass). Returns the ticks used.
## Runs a gore beat that is playing to its end (not the death that may follow it).
func _finish_gore(map: Node3D) -> void:
	var ticks := 0
	while map.decoy_gore.active and ticks < 1000:
		map.tick_gore(1.0 / 60.0)
		ticks += 1


func _walk_until_done(map: Node3D) -> int:
	var ticks := 0
	while map.picking.walk_target >= 0 and ticks < 600:
		map.step(Vector2.ZERO, 1.0 / 60.0)
		ticks += 1
	return ticks


func test_picking_scene() -> void:
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(map.picking != null and map.basket_hud is CanvasLayer, "the map has a picking state and a basket HUD")
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.partner.global_position = _ground_point(map, 60.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame

	# Basket HUD at rest.
	var texts: Array = map.basket_hud.find_children("*", "Label", true, false).map(func(l): return l.text)
	check(texts == ["망태기"], "the empty basket shows only its label (%s)" % str(texts))
	check(map.basket_hud._panel.anchor_top == 1.0 and map.basket_hud._panel.anchor_left == 1.0, "the basket is anchored at the bottom right, clear of the discovery list down the left")

	# A target: click it (a synthetic mouse event), the player walks over and picks it.
	var target := _visible_plant(map, func(p): return p.kind == "target")
	check(not target.is_empty(), "a target plant is on screen to click")
	var decoy := _visible_plant(map, func(p): return p.kind != "target")
	check(not decoy.is_empty(), "a decoy plant is on screen to click")
	if target.is_empty() or decoy.is_empty():
		map.free()
		return
	var plant: Node3D = target["plant"]
	var letter: String = plant.letter
	var labels_before := plant.find_children("*", "Label3D", true, false).size()
	var start: Vector3 = map.player.global_position
	map._unhandled_input(_click_event(target["screen"]))
	check(map.picking.walk_target == map.plants.find(plant), "left-clicking a plant starts a walk to it")
	map.step(Vector2.ZERO, 1.0 / 60.0)
	for i in 5:
		map.step(Vector2.ZERO, 1.0 / 60.0)
	var to_plant := Vector2(plant.global_position.x - start.x, plant.global_position.z - start.z)
	var moved := Vector2(map.player.global_position.x - start.x, map.player.global_position.z - start.z)
	check(moved.length() > 0.1 and moved.normalized().dot(to_plant.normalized()) > 0.99, "the player walks straight toward it")
	check(is_equal_approx(moved.length(), map.player.speed * 6.0 / 60.0) or moved.length() <= map.player.speed * 6.0 / 60.0 + 0.01, "at the normal walk speed")
	_walk_until_done(map)
	var gap := Vector2(plant.global_position.x - map.player.global_position.x, plant.global_position.z - map.player.global_position.z).length()
	check(gap <= map.picking.pick_radius + 0.01, "it stops within the pick radius (%.2f m)" % gap)
	check(map.picking.basket == [letter], "the letter is in the basket (%s)" % str(map.picking.basket))
	check(plant.letter == "" and not map.picking.has_letter(map.plants.find(plant)), "the plant is letterless afterwards")
	await get_tree().process_frame  # queue_free of the label
	check(plant.find_children("*", "Label3D", true, false).size() == labels_before - 1, "its letter label is gone, the plant stays")
	check(plant.is_inside_tree() and plant.get_node("PickArea") != null, "the plant stays in the world with its pick area")
	check(map.plant_at(target["screen"]) == plant and plant.tooltip_text() != "", "hover names still work on a letterless plant")
	for i in 20:
		map.step(Vector2.ZERO, 1.0 / 60.0)
	var tiles: Array = map.basket_hud.find_child("Tiles", true, false).get_children()
	check(tiles.size() == 1 and tiles[0].find_children("*", "Label", true, false)[0].text == letter, "the basket HUD shows a tile with that letter")
	check(is_equal_approx(tiles[0].scale.x, 1.0), "the tile has popped in to full size")
	check(map.find_children("*", "CPUParticles3D", false, false).is_empty(), "a target pick makes no steam")
	# Clicking the letterless plant does nothing.
	check(not map.click(target["screen"]) and map.picking.walk_target == -1, "clicking a letterless plant does nothing")
	check(map.picking.basket == [letter], "and the basket is unchanged")

	# A decoy: letter gone in steam, nothing in the basket.
	var decoy_plant: Node3D = decoy["plant"]
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var decoy_screen: Vector2 = map.camera.unproject_position(decoy_plant.global_position + Vector3(0, 0.5, 0))
	check(map.plant_at(decoy_screen) == decoy_plant, "the decoy can still be found under the mouse")
	map._unhandled_input(_click_event(decoy_screen))
	check(map.picking.walk_target == map.plants.find(decoy_plant), "clicking a decoy starts a walk too")
	_walk_until_done(map)
	_finish_gore(map)  # (a harm decoy plays its gore beat, which blocks clicks until it ends)
	check(map.picking.basket == [letter], "a decoy's letter never enters the basket")
	check(decoy_plant.letter == "" and not map.picking.has_letter(map.plants.find(decoy_plant)), "the decoy's letter is gone")
	var puffs := map.find_children("*", "CPUParticles3D", false, false)
	check(puffs.size() == 1, "a steam puff plays")
	if puffs.size() == 1:
		var puff: CPUParticles3D = puffs[0]
		check(puff.one_shot and puff.emitting and is_equal_approx(puff.lifetime, map.picking.steam_duration), "it is a one-shot puff of the data's duration")
		check(puff.color == map.picking.steam_color, "it has the data's steam colour")
		check(puff.global_position.distance_to(decoy_plant.letter_position()) < 0.01, "it is at the vanished letter")
	check(map.basket_hud.find_child("Tiles", true, false).get_child_count() == 1, "the basket HUD gained no tile")
	check(map.picking.letters_left() == 34, "34 letters remain")

	# WASD cancels a walk; a second click retargets.
	var second := _visible_plant(map, func(p): return p.kind == "target")
	if not second.is_empty():
		map.player.global_position = _ground_point(map, 14.0, 0.0)
		map.click(second["screen"])
		var first_target: int = map.picking.walk_target
		check(first_target >= 0, "a walk is under way")
		var other := _visible_plant(map, func(p): return p != second["plant"] and p.kind == "target")
		if not other.is_empty():
			map.click(other["screen"])
			check(map.picking.walk_target == map.plants.find(other["plant"]) and map.picking.walk_target != first_target, "clicking another plant retargets")
		map.step(Vector2.RIGHT, 1.0 / 60.0)
		check(map.picking.walk_target == -1, "any WASD input cancels the walk")
		var before: Vector3 = map.player.global_position
		map.step(Vector2.ZERO, 0.1)
		var drift: Vector3 = map.player.global_position - before
		check(Vector2(drift.x, drift.z).length() < 0.001, "and the player then stands still")
	map.free()

	# Dead or restarting: clicks and picks are ignored.
	var gated: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(gated)
	gated.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	gated.player.global_position = _ground_point(gated, 14.0, 0.0)
	gated.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var near := _visible_plant(gated, func(p): return p.kind == "target")
	check(gated.picks_allowed(), "picks are allowed in a live scene")
	gated.restarting = true
	check(not gated.picks_allowed() and not gated.click(near["screen"]) and gated.picking.walk_target == -1, "a click while restarting is ignored")
	gated.pick_plant(near["plant"])
	check(gated.picking.basket.is_empty() and near["plant"].letter != "", "a pick while restarting takes nothing")
	gated.restarting = false
	while GameState.is_alive("fernanda") and GameState.is_alive("nestor"):
		GameState.damage("fernanda", "test")
	check(not gated.picks_allowed() and not gated.click(near["screen"]), "a click with the travelers dead is ignored")
	gated.pick_plant(near["plant"])
	check(gated.picking.basket.is_empty() and near["plant"].letter != "", "a pick with the travelers dead takes nothing")
	GameState.new_hike()
	check(gated.picks_allowed() and gated.click(near["screen"]), "after the hike restarts a click works again")
	gated.step(Vector2.ZERO, 0.0)
	while GameState.is_alive("nestor"):  # they die mid-walk
		GameState.damage("nestor", "test")
	gated.step(Vector2.ZERO, 0.1)
	check(gated.picking.walk_target == -1, "a walk in progress is dropped when the travelers die")
	GameState.new_hike()
	gated.free()

	# A restarted scene: the basket is empty and all 36 letters are back.
	var again: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(again)
	again.set_physics_process(false)
	check(again.picking.basket.is_empty() and again.picking.letters_left() == 36, "a restarted scene has an empty basket and 36 letters")
	var back := true
	for plant_node in again.plants:
		back = back and plant_node.letter != "" and plant_node.find_children("*", "Label3D", true, false).size() == 1
	check(back, "every plant shows its letter again")
	check(again.basket_hud.find_child("Tiles", true, false).get_child_count() == 0, "the basket HUD is empty again")
	again.free()
	GameState.new_hike()
	_section_done("test_picking_scene")


func test_basket_hud_data() -> void:
	var block: Dictionary = _config().get("basket_hud", {})
	check(not block.is_empty(), "hallasan.json has a basket_hud block")
	check(block.get("max_columns") is float and float(block["max_columns"]) >= 1.0 and float(block["max_columns"]) == floorf(float(block["max_columns"])), "basket_hud.max_columns is a positive whole number")
	for key in ["tile_size", "tile_gap", "margin"]:
		check(block.get(key) is float and float(block[key]) > 0.0, "basket_hud.%s is a positive number" % key)
	for key in ["bag_body_color", "bag_weave_color", "bag_rim_color", "rope_color"]:
		var color = block.get(key)
		var ok: bool = color is Array and color.size() == 3
		if ok:
			for channel in color:
				ok = ok and channel is float and channel >= 0.0 and channel <= 1.0
		check(ok, "basket_hud.%s is present with three channels in 0..1" % key)
	_section_done("test_basket_hud_data")


## Lets the container layout settle after the HUD changed.
func _settle_layout() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func test_hud_clicks_and_layout() -> void:
	# The headless window is tiny; the layout is checked at the game's 1280x720.
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.partner.global_position = _ground_point(map, 60.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var screen: Vector2 = map.get_viewport().get_visible_rect().size
	var viewport_rect := Rect2(Vector2.ZERO, screen)
	var block: Dictionary = _config()["basket_hud"]
	var max_columns := int(block["max_columns"])
	var bag: Control = map.basket_hud._panel
	var tiles_box: Control = map.basket_hud.find_child("Tiles", true, false)

	# Discovery list with all six entries (the tallest it gets).
	var by_kind := {}
	for entry in _config()["plants"]["placed"]:
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for kind in _config()["plants"]["kinds"]:
		if kind["kind"] == "target":
			map.discovery.update([by_kind[kind["id"]]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	await _settle_layout()
	var list: Control = map.discovery_hud.get_child(0)
	var list_rect := list.get_global_rect()
	check(map.discovery.entries.size() == 6 and list.get_child_count() == 6, "the discovery list has its six entries")

	# Layout with 0, 1, 10 and 28 tiles, filled by real picks.
	var order: Array[int] = []
	for i in map.plants.size():
		if map.plants[i].kind == "target":
			order.append(i)
	var picked := 0
	var layout_ok := true
	for want in [0, 1, 10, 28]:
		while picked < want:
			map.pick_plant(map.plants[order[picked]])
			picked += 1
		map.basket_hud.refresh(1.0)
		await _settle_layout()
		var rect := bag.get_global_rect()
		var inside := viewport_rect.encloses(rect)
		var clear := not rect.intersects(list_rect)
		var widths := {}
		for tile in tiles_box.get_children():
			widths[snappedf(tile.position.y, 0.5)] = int(widths.get(snappedf(tile.position.y, 0.5), 0)) + 1
		var widest := 0
		for count in widths.values():
			widest = maxi(widest, count)
		check(tiles_box.get_child_count() == want and map.picking.basket.size() == want, "%d tiles in the basket" % want)
		check(inside, "%d tiles: the basket %s is inside the viewport" % [want, str(rect)])
		check(clear, "%d tiles: the basket does not overlap the discovery list" % want)
		check(widest <= max_columns, "%d tiles: rows are at most %d wide (%d)" % [want, max_columns, widest])
		check(widths.size() == ceili(want / float(max_columns)), "%d tiles make %d rows" % [want, ceili(want / float(max_columns))])
		layout_ok = layout_ok and rect.end.x <= screen.x and rect.end.y <= screen.y
	check(layout_ok and bag.get_global_rect().end.is_equal_approx(screen - Vector2(float(block["margin"]), float(block["margin"]))), "the bag stays anchored at the bottom right margin as it grows")
	check(bag.get_global_rect().size.y > 160.0, "a full bag has grown upward")

	# Mouse filters: the panels stop clicks, the layer roots and inner nodes do not.
	check(bag.mouse_filter == Control.MOUSE_FILTER_STOP, "the bag stops mouse clicks")
	check(list.get_child(0).mouse_filter == Control.MOUSE_FILTER_STOP, "each discovery panel stops mouse clicks")
	check(list.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the discovery list's column box does not block")
	check(tiles_box.mouse_filter == Control.MOUSE_FILTER_IGNORE and tiles_box.get_child(0).mouse_filter == Control.MOUSE_FILTER_IGNORE, "the tiles let clicks fall through to the bag")

	# Synthetic clicks through the viewport's GUI, so panels get the chance to swallow them.
	map.picking.cancel_walk()
	var over_bag := bag.get_global_rect().get_center()
	var over_list: Vector2 = list.get_child(0).get_global_rect().get_center()
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var clickable := _visible_plant(map, func(p): return p.kind != "target" and not bag.get_global_rect().has_point(map.camera.unproject_position(p.global_position + Vector3(0, 0.5, 0))) and not list_rect.has_point(map.camera.unproject_position(p.global_position + Vector3(0, 0.5, 0))))
	check(not clickable.is_empty(), "a plant outside both panels is on screen")
	var walked_before: int = map.picking.walk_target
	for point in [over_bag, over_list]:
		map.get_viewport().push_input(_click_event(point))
		check(map.picking.walk_target == walked_before and map.picking.walk_target == -1, "a click over a panel starts no walk (%s)" % str(point))
		map.get_viewport().push_input(_release_event(point))  # a real click ends; the viewport holds a press until then
	check(map.spelling_hud.is_open() and get_tree().paused, "(the click over the list entry opened the spelling view, which is meant)")
	map.spelling_hud.close()
	check(not get_tree().paused, "closing it unpauses")
	check(map.picking.letters_left() == 36 - 28, "and takes no letter (the 28 picks above are the only ones)")
	# Outside the panels everything works as before.
	if not clickable.is_empty():
		map.get_viewport().push_input(_click_event(clickable["screen"]))
		check(map.picking.walk_target == map.plants.find(clickable["plant"]), "a click on a plant outside the panels still starts its walk")
	map.picking.cancel_walk()
	# A plant behind a panel: slide the bag over a visible plant and click there.
	var behind := _visible_plant(map, func(p): return p.kind != "target" and p != clickable.get("plant"))
	if not behind.is_empty():
		var sp: Vector2 = behind["screen"]
		bag.global_position = sp - bag.size / 2.0
		await _settle_layout()
		bag.global_position = sp - bag.size / 2.0
		map.get_viewport().push_input(_click_event(sp))
		check(map.picking.walk_target == -1, "a click on a plant that is behind the basket starts no walk")
		var plain := _click_event(sp)
		map._unhandled_input(plain)
		check(map.picking.walk_target >= 0, "(control) the same click reaching the map would have started one")
		map.picking.cancel_walk()
		# The same for the discovery list: slide its first panel over the plant.
		bag.global_position = Vector2(screen.x - 300.0, 0.0)
		var row: Control = list.get_child(0)
		list.global_position += sp - row.get_global_rect().get_center()
		map.get_viewport().push_input(_click_event(sp))
		check(map.picking.walk_target == -1, "a click on a plant that is behind a discovery panel starts no walk")
	map.free()
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_hud_clicks_and_layout")


# ---- Keyboard picking, walk-up names and the reach ring ----

func _key_event(keycode: Key, pressed := true, echo := false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.keycode = keycode
	event.pressed = pressed
	event.echo = echo
	return event


func _bound_keys(action: String) -> Array:
	return InputMap.action_get_events(action).map(func(e): return [e.physical_keycode, e.location])


func test_reach_data() -> void:
	var config := _config()
	var tip: Dictionary = config["tooltip"]
	var total := float(tip["steady_time"]) + float(tip["flicker_time"])
	check(is_equal_approx(float(tip["steady_time"]), 0.25) and is_equal_approx(float(tip["flicker_time"]), 0.2) and is_equal_approx(float(tip["flicker_rate"]), 20.0), "tooltip timings are halved and the flicker rate doubled")
	check(is_equal_approx(total, 0.45), "a hover name is up for 0.45 s in all (was 0.9 s)")
	check(_bound_keys("p1_pick") == [[KEY_SPACE, 0]], "p1_pick is bound to Space only")
	check(_bound_keys("p2_pick") == [[KEY_ENTER, 0], [KEY_KP_ENTER, 2]], "p2_pick is bound to Enter and the keypad Enter")
	var moves := {"p1_left": KEY_A, "p1_right": KEY_D, "p1_up": KEY_W, "p1_down": KEY_S,
			"p2_left": KEY_LEFT, "p2_right": KEY_RIGHT, "p2_up": KEY_UP, "p2_down": KEY_DOWN}
	var moves_ok := true
	for action in moves:
		moves_ok = moves_ok and _bound_keys(action) == [[moves[action], 0]]
	check(moves_ok, "P1 moves on WASD and P2 on the arrow keys, unchanged")
	var ring: Dictionary = config.get("reach_ring", {})
	check(not ring.is_empty(), "hallasan.json has a reach_ring block")
	var rc = ring.get("color")
	check(rc is Array and rc.size() == 3 and rc.all(func(c): return c is float and c >= 0.0 and c <= 1.0), "reach_ring.color has three channels in 0..1")
	check(ring.get("alpha") is float and ring["alpha"] > 0.0 and ring["alpha"] <= 0.5, "reach_ring.alpha is low (0..0.5]")
	check(ring.get("radius_offset") is float and config["picking"]["pick_radius"] + ring["radius_offset"] > ring.get("width", 0.0), "reach_ring.radius_offset keeps the ring inside the reach and wider than its line")
	check(ring.get("width") is float and ring["width"] > 0.0 and ring.get("pulse_speed") is float and ring["pulse_speed"] >= 0.0, "reach_ring.width is positive and pulse_speed is not negative")
	check(ring.get("pulse_depth") is float and ring["pulse_depth"] >= 0.0 and ring["pulse_depth"] <= 1.0, "reach_ring.pulse_depth is in 0..1")
	var p = PickingScript.new(config["picking"], config["plants"], ring)
	check(p.ring_color == Color(rc[0], rc[1], rc[2]) and is_equal_approx(p.ring_alpha, float(ring["alpha"])) and is_equal_approx(p.ring_radius(), float(config["picking"]["pick_radius"]) + float(ring["radius_offset"])), "Picking reads the ring values from the data")
	_section_done("test_reach_data")


func _close_pair_data() -> Dictionary:
	return {
		"kinds": [{"id": "t", "kind": "target"}, {"id": "d", "kind": "decoy"}],
		"placed": [
			{"kind": "t", "x": 10.0, "z": 0.0, "letter": "ㄱ"},
			{"kind": "d", "x": 11.0, "z": 0.0, "letter": "ㄴ"},
			{"kind": "t", "x": 30.0, "z": 0.0},
		]}


func test_reach_logic() -> void:
	var config := _config()
	var p = PickingScript.new(config["picking"], _close_pair_data(), config["reach_ring"])
	var r: float = p.pick_radius
	check(p.nearest_pickable(Vector2(10.4, 0.0)) == 0, "with two letters in reach the nearer one is chosen (first)")
	check(p.nearest_pickable(Vector2(10.6, 0.0)) == 1, "with two letters in reach the nearer one is chosen (second)")
	check(p.nearest_pickable(Vector2(10.0 - r - 0.01, 0.0)) == -1, "nothing just outside the radius")
	check(p.nearest_pickable(Vector2(10.0 - r + 0.01, 0.0)) == 0, "something just inside the radius")
	check(p.nearest_pickable(Vector2(30.0, 0.0)) == -1, "a letterless plant is never pickable")
	check(p.entered_reach(Vector2(0.0, 0.0)).is_empty(), "far away nothing is entered")
	check(Array(p.entered_reach(Vector2(10.4, 0.0))) == [1, 0], "entering reports both plants, nearest last")
	check(p.entered_reach(Vector2(10.45, 0.0)).is_empty(), "staying inside reports nothing again")
	check(p.entered_reach(Vector2(14.0, 0.0)).is_empty(), "leaving reports nothing")
	check(Array(p.entered_reach(Vector2(10.4, 0.0))) == [1, 0], "re-entering reports the plants again")
	var p2 = PickingScript.new(config["picking"], _close_pair_data(), config["reach_ring"])
	check(Array(p2.entered_reach(Vector2(30.5, 0.0))) == [2], "a letterless plant is entered too")
	p2.pick(0)
	check(p2.nearest_pickable(Vector2(10.0, 0.0)) == 1, "after a pick the nearest pickable is the next one")
	var lo: float = p.ring_alpha_at(0.0)
	var alphas: Array[float] = []
	for i in 40:
		alphas.append(p.ring_alpha_at(i * 0.1))
	check(is_equal_approx(lo, p.ring_alpha) and alphas.min() >= p.ring_alpha * (1.0 - p.ring_pulse_depth) - 0.0001 and alphas.max() <= p.ring_alpha + 0.0001, "the ring alpha pulses between its bounds")
	_section_done("test_reach_logic")


## The two closest plants with letters. The real layout keeps plants about 3 m
## apart, more than twice the pick radius, so tests widen the radius to put both in reach.
func _close_pair(map: Node3D) -> Array:
	for i in map.plants.size():
		for j in range(i + 1, map.plants.size()):
			var a: Node3D = map.plants[i]
			var b: Node3D = map.plants[j]
			if a.letter != "" and b.letter != "" and a.global_position.distance_to(b.global_position) < 3.2:
				return [a, b]
	return []


## A plant with a letter and no other plant within 3 x pick_radius.
func _lone_plant(map: Node3D, wanted_kind: String) -> Node3D:
	for plant in map.plants:
		if (plant.kind == "target") != (wanted_kind == "target") or plant.letter == "":
			continue
		var alone := true
		for other in map.plants:
			if other != plant and other.global_position.distance_to(plant.global_position) < 3.0 * map.picking.pick_radius:
				alone = false
		if alone:
			return plant
	return null


func _stand_near(map: Node3D, plant: Node3D, offset := Vector2(0.4, 0.2)) -> void:
	map.player.global_position = _ground_point(map, plant.global_position.x + offset.x, plant.global_position.z + offset.y)


func _fresh_reach_map() -> Node3D:
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	map.partner.global_position = _ground_point(map, 69.0, 0.0)
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	return map


func test_reach_scene() -> void:
	var map: Node3D = await _fresh_reach_map()
	var target := _lone_plant(map, "target")
	var decoy := _lone_plant(map, "decoy")
	check(target != null and decoy != null, "an isolated target and an isolated decoy exist")
	if target == null or decoy == null:
		map.free()
		return

	# Space picks.
	_stand_near(map, target)
	var letter: String = target.letter
	var handled: bool = map.pick_nearest()
	check(handled and map.picking.basket == [letter] and target.letter == "", "Space picks the target in reach into the basket")
	_stand_near(map, decoy)
	var tiles_before: int = map.basket_hud.find_child("Tiles", true, false).get_child_count()
	map._unhandled_input(_key_event(KEY_SPACE))
	check(decoy.letter == "" and map.picking.basket == [letter], "a synthetic Space event picks the decoy and the basket is unchanged")
	check(map.find_children("*", "CPUParticles3D", false, false).size() == 1, "the decoy pick makes steam")
	check(map.basket_hud.find_child("Tiles", true, false).get_child_count() == tiles_before, "and no tile")
	map._unhandled_input(_key_event(KEY_SPACE))
	check(map.find_children("*", "CPUParticles3D", false, false).size() == 1 and map.picking.basket == [letter], "Space on a letterless plant does nothing")
	map._unhandled_input(_key_event(KEY_SPACE, true, true))
	map._unhandled_input(_key_event(KEY_SPACE, false))
	check(map.picking.basket == [letter], "an echo or a key release does nothing")
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	var nothing: bool = map.picking.nearest_pickable(Vector2(map.player.global_position.x, map.player.global_position.z)) == -1
	check(nothing and not map.pick_nearest() and map.picking.basket == [letter], "Space does nothing with no plant in reach")
	map.free()

	# Two in reach: the nearest.
	map = await _fresh_reach_map()
	var pair := _close_pair(map)
	check(not pair.is_empty(), "two letter-bearing plants lie close together")
	if not pair.is_empty():
		var a: Node3D = pair[0]
		var b: Node3D = pair[1]
		var toward: Vector3 = (b.global_position - a.global_position)
		toward.y = 0.0
		var mid := a.global_position + toward * 0.65  # nearer b
		map.picking.pick_radius = 2.5
		map.player.global_position = _ground_point(map, mid.x, mid.z)
		check(map.picking.nearest_pickable(Vector2(mid.x, mid.z)) == map.plants.find(b), "the second plant is the nearer one")
		var a_in: bool = Vector2(mid.x - a.global_position.x, mid.z - a.global_position.z).length() <= map.picking.pick_radius
		check(a_in, "both plants are in reach")
		map.pick_nearest()
		check(b.letter == "" and a.letter != "", "Space picked the nearest, not the other")
	map.free()

	# Gating: dead and restarting.
	map = await _fresh_reach_map()
	target = _lone_plant(map, "target")
	_stand_near(map, target)
	map.restarting = true
	map._unhandled_input(_key_event(KEY_SPACE))
	check(target.letter != "" and map.picking.basket.is_empty(), "Space while restarting takes nothing")
	map.restarting = false
	while GameState.is_alive("fernanda") and GameState.is_alive("nestor"):
		GameState.damage("fernanda", "test")
	map._unhandled_input(_key_event(KEY_SPACE))
	check(target.letter != "" and map.picking.basket.is_empty(), "Space with the travelers dead takes nothing")
	map.free()

	# Space cancels a click-walk.
	map = await _fresh_reach_map()
	target = _lone_plant(map, "target")
	var far := _lone_plant(map, "decoy")
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	check(map.picking.start_walk(map.plants.find(far)) and map.picking.walk_target >= 0, "a walk is under way")
	map._unhandled_input(_key_event(KEY_SPACE))
	check(map.picking.walk_target == -1, "Space cancels the click-walk")
	map.free()

	# Walk-up flash.
	map = await _fresh_reach_map()
	target = _lone_plant(map, "target")
	decoy = _lone_plant(map, "decoy")
	map.partner.global_position = _ground_point(map, decoy.global_position.x + 0.3, decoy.global_position.z)
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == null, "the partner standing next to a plant triggers no name")
	_stand_near(map, target)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == target and map._tooltip.visible and map._tooltip_label.text == target.tooltip_text() and target.tooltip_text() != "???", "walking up to a target flashes its English name")
	map._tip_plant = null
	map.step(Vector2.ZERO, 1.0 / 60.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == null, "it does not re-trigger while the player stays in reach")
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	_stand_near(map, target)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == target, "it triggers again after leaving the radius and re-entering")
	check(map.picking.has_letter(map.plants.find(target)), "(the target still has its letter)")
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	_stand_near(map, decoy)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == decoy and map._tooltip_label.text == "???", "a decoy flashes ??? the same way")
	map._start_tooltip(target, true)
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	_stand_near(map, decoy)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._tip_plant == decoy and not map._tip_by_mouse, "a walk-up replaces a mouse tooltip: the latest trigger wins")
	# Timings come from the same data: steady, then gone after the flicker.
	map._hover_time = 0.0
	map.update_hover(Vector2(-10.0, -10.0), 0.0)
	map.update_hover(Vector2(-10.0, -10.0), 0.2)
	check(map._tooltip.visible, "a walk-up name is still solid at 0.2 s")
	map.update_hover(Vector2(-10.0, -10.0), 0.3)
	check(not map._tooltip.visible, "and gone after 0.5 s (steady + flicker)")
	# Letterless plants flash too.
	_stand_near(map, target)
	map.pick_nearest()
	map.player.global_position = _ground_point(map, 0.5, 0.0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	map._tip_plant = null
	_stand_near(map, target)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(target.letter == "" and map._tip_plant == target, "a letterless plant flashes its name on walk-up")
	map.free()

	# The ring.
	map = await _fresh_reach_map()
	target = _lone_plant(map, "target")
	decoy = _lone_plant(map, "decoy")
	check(not map._ring.visible, "no ring when nothing is in reach")
	_stand_near(map, target)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	var ring_a: MeshInstance3D = map._ring
	check(ring_a.visible and map._ring_plant == target and ring_a.global_position.is_equal_approx(target.global_position), "the ring sits on the target in reach")
	var color_a: Color = map._ring_material.albedo_color
	var size_a: Vector3 = ring_a.mesh.get_aabb().size
	var time_a: float = map._ring_time
	_stand_near(map, decoy)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map._ring.visible and map._ring_plant == decoy and map._ring.global_position.is_equal_approx(decoy.global_position), "the ring moves to the decoy in reach")
	var size_b: Vector3 = map._ring.mesh.get_aabb().size
	var color_b: Color = map._ring_material.albedo_color
	check(is_equal_approx(size_a.x, size_b.x) and is_equal_approx(size_a.z, size_b.z), "the ring is the same size on a target and a decoy")
	var expected_alpha: float = map.picking.ring_alpha_at(map._ring_time)
	check(color_a.r == color_b.r and color_a.g == color_b.g and color_a.b == color_b.b and is_equal_approx(color_b.a, expected_alpha) and is_equal_approx(color_a.a, map.picking.ring_alpha_at(time_a)), "the ring has the same colour and the same alpha curve on both")
	check(map.find_children("ReachRing", "MeshInstance3D", true, false).size() == 1, "there is only ever one ring")
	map.pick_nearest()
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(not map._ring.visible, "a letterless plant gets no ring")
	var pair2 := _close_pair(map)
	if not pair2.is_empty():
		var a2: Node3D = pair2[0]
		var b2: Node3D = pair2[1]
		var dir: Vector3 = b2.global_position - a2.global_position
		dir.y = 0.0
		var spot := a2.global_position + dir * 0.65
		map.picking.pick_radius = 2.5
		map.player.global_position = _ground_point(map, spot.x, spot.z)
		map.step(Vector2.ZERO, 1.0 / 60.0)
		check(map._ring.visible and map._ring_plant == b2 and map.find_children("ReachRing", "MeshInstance3D", true, false).size() == 1, "with two in reach the ring marks only the nearest")
	map.free()
	_section_done("test_reach_scene")


# ---- Spelling view ----

const SpellingScript := preload("res://scenes/foraging/spelling.gd")


func test_spelling_data() -> void:
	var block: Dictionary = _config().get("spelling_view", {})
	check(not block.is_empty(), "hallasan.json has a spelling_view block")
	for key in ["panel_size", "block_size"]:
		var pair = block.get(key)
		check(pair is Array and pair.size() == 2 and pair[0] is float and pair[1] is float and pair[0] > 0.0 and pair[1] > 0.0, "spelling_view.%s is two positive numbers" % key)
	for key in ["panel_top", "block_gap", "slot_gap", "failure_flash_time"]:
		check(block.get(key) is float and float(block[key]) > 0.0, "spelling_view.%s is a positive number" % key)
	for key in ["failure_flash_color", "correct_color", "done_color"]:
		var color = block.get(key)
		var ok: bool = color is Array and color.size() == 3
		if ok:
			for channel in color:
				ok = ok and channel is float and channel >= 0.0 and channel <= 1.0
		check(ok, "spelling_view.%s has three channels in 0..1" % key)
	if block.get("panel_size") is Array and block.get("block_size") is Array:
		var panel: Array = block["panel_size"]
		var cell: Array = block["block_size"]
		var most := 0
		for kind in _config()["plants"]["kinds"]:
			if kind["kind"] == "target":
				most = maxi(most, Hangul.syllable_count(kind["name"]))
		var margins := 32.0  # the panel's content margin on both sides
		check(most * float(cell[0]) + (most - 1) * float(block["block_gap"]) + margins <= float(panel[0]), "the longest word (%d blocks) fits across the panel" % most)
		check(float(cell[1]) + 100.0 <= float(panel[1]), "a block fits under the header")
		check(float(cell[0]) - 3.0 * float(block["slot_gap"]) > 0.0, "a block has room for two slots")
	_section_done("test_spelling_data")


func _new_spelling(basket: Array[String]):
	return SpellingScript.new(_config()["spelling_view"], _config()["plants"], basket)


func _target_words() -> Dictionary:
	var words := {}
	for kind in _config()["plants"]["kinds"]:
		if kind["kind"] == "target":
			words[kind["id"]] = String(kind["name"])
	return words


## [initial, medial] of each syllable of a word.
func _word_letters(word: String) -> Array:
	var blocks := []
	for ch in word:
		var parts := Hangul.decompose(ch)
		blocks.append([parts[0], parts[1]])
	return blocks


## The syllable_failed emissions of a Spelling, as [word, block, letters].
func _watch_failures(spelling) -> Array:
	var seen := []
	spelling.syllable_failed.connect(func(word_id: String, block: int, letters: Array) -> void: seen.append([word_id, block, letters]))
	return seen


func test_spelling_logic() -> void:
	var words := _target_words()
	check(words.size() == 6, "six target words")
	# Every word, spelled right, completes; the extra letters in the basket are untouched.
	for id in words:
		var basket: Array[String] = ["ㅍ", "ㅌ"]
		var blocks := _word_letters(words[id])
		for pair in blocks:
			basket.append_array(pair)
		var spelling = _new_spelling(basket)
		var done_ids := []
		spelling.word_completed.connect(func(w: String) -> void: done_ids.append(w))
		check(spelling.open(id) and spelling.open_id == id and spelling.block_count(id) == blocks.size(), "%s opens with %d blocks" % [words[id], blocks.size()])
		var results := []
		for b in blocks.size():
			for slot in 2:
				results.append(spelling.place(blocks[b][slot], b, slot)["result"])
		var expected := []
		for b in blocks.size():
			expected.append_array(["placed", "complete" if b == blocks.size() - 1 else "correct"])
		check(results == expected, "%s: the right letters in order give %s" % [words[id], str(expected)])
		check(spelling.is_done(id) and not spelling.is_open() and done_ids == [id], "%s is done, closed, and announced once" % words[id])
		check("".join(spelling.solved(id)) == words[id], "%s: the judged syllables spell it" % words[id])
		check(basket == ["ㅍ", "ㅌ"], "%s: its letters are consumed, the others stay" % words[id])
		check(not spelling.open(id), "%s: a done word does not reopen" % words[id])

	# Failures: a real syllable that is not the target's, two consonants, two vowels.
	var wrong := {"a real wrong syllable (머 for 미)": ["ㅁ", "ㅓ"], "two consonants": ["ㅁ", "ㄴ"], "two vowels": ["ㅏ", "ㅣ"], "swapped order (ㅣㅁ)": ["ㅣ", "ㅁ"]}
	for label in wrong:
		var pair: Array = wrong[label]
		var basket: Array[String] = ["ㅅ", "ㅗ"]
		basket.append_array(pair)
		var spelling = _new_spelling(basket)
		var seen := _watch_failures(spelling)
		spelling.open("minari")  # 미나리: the first block is 미
		var first: String = spelling.place(pair[0], 0, 0)["result"]
		var second: Dictionary = spelling.place(pair[1], 0, 1)
		check(first == "placed" and second["result"] == "failed", "%s fails" % label)
		check(basket == ["ㅅ", "ㅗ"], "%s: exactly its two letters leave the basket" % label)
		check(seen == [["minari", 0, pair]], "%s: syllable_failed says word, block and letters (%s)" % [label, str(seen)])
		check(not spelling.is_open() and spelling.solved("minari").is_empty() and not spelling.is_done("minari"), "%s: the view closes and nothing is solved" % label)
		check(spelling.open("minari"), "%s: the word can be opened again" % label)
	# Strict: the engine does compose 머, so it is a real syllable, and still wrong.
	check(Hangul.compose("ㅁ", "ㅓ") == "머" and Hangul.compose("ㅁ", "ㅣ") == "미", "(control) 머 and 미 are both real syllables")
	var judge_only = _new_spelling([])
	check(judge_only.judge("minari", 0, ["ㅁ", "ㅣ"]) and not judge_only.judge("minari", 0, ["ㅁ", "ㅓ"]) and not judge_only.judge("minari", 1, ["ㅁ", "ㅣ"]), "judge accepts only the target syllable at that position")

	# Out of order, a letter not in the basket, a filled slot.
	var basket: Array[String] = ["ㅁ", "ㅓ", "ㄹ", "ㅜ", "ㅁ"]
	var spelling = _new_spelling(basket)
	spelling.open("meoru")  # 머루
	check(spelling.place("ㄹ", 1, 0)["result"] == "rejected" and basket.size() == 5, "block 2 cannot be filled before block 1 is right")
	check(spelling.place("ㅏ", 0, 0)["result"] == "rejected" and basket.size() == 5, "a letter that is not in the basket cannot be placed")
	check(spelling.place("ㅁ", 0, 0)["result"] == "placed" and basket == ["ㅓ", "ㄹ", "ㅜ", "ㅁ"], "a placed letter leaves the basket (one copy)")
	check(spelling.place("ㅁ", 0, 0)["result"] == "rejected" and basket.size() == 4, "a filled slot takes no second letter")
	check(spelling.place("ㅁ", 0, 5)["result"] == "rejected" and spelling.place("ㅁ", 3, 0)["result"] == "rejected", "slots and blocks out of range are rejected")
	# Taking back from an unjudged block.
	check(spelling.take_back(0, 0) and basket == ["ㅓ", "ㄹ", "ㅜ", "ㅁ", "ㅁ"] and spelling.placed == ["", ""], "a letter in an unjudged block goes back to the basket")
	check(not spelling.take_back(0, 0), "an empty slot gives nothing back")
	spelling.place("ㅁ", 0, 0)
	spelling.place("ㅓ", 0, 1)
	check(spelling.solved("meoru") == ["머"] and spelling.current_block() == 1, "머 is right and locks; block 2 is current")
	check(not spelling.take_back(0, 0) and not spelling.take_back(0, 1) and spelling.solved("meoru") == ["머"], "a judged block is locked")
	check(spelling.place("ㅁ", 0, 0)["result"] == "rejected", "a judged block takes no more letters")
	# Closing early.
	spelling.place("ㄹ", 1, 0)
	check(basket == ["ㅜ", "ㅁ"], "a letter sits in block 2 (basket %s)" % str(basket))
	var returned: Array[String] = spelling.close()
	check(returned == ["ㄹ"] and basket == ["ㅜ", "ㅁ", "ㄹ"] and not spelling.is_open(), "closing early returns the unjudged letter")
	check(spelling.solved("meoru") == ["머"], "closing keeps the judged block")
	check(spelling.open("meoru") and spelling.current_block() == 1 and spelling.placed == ["", ""], "reopening resumes at block 2")
	check(spelling.place("ㄹ", 1, 0)["result"] == "placed" and spelling.place("ㅜ", 1, 1)["result"] == "complete", "finishing 머루 completes it")
	check(basket == ["ㅁ"] and spelling.is_done("meoru") and not spelling.open("meoru"), "the word is done and cannot be reopened")
	# Gating and unknown ids.
	var gated = _new_spelling([])
	check(not gated.open("ma", false) and not gated.is_open(), "opening is refused when not allowed")
	check(not gated.open("no_such_word") and not gated.open("keuncheonnamseong"), "unknown ids and decoys cannot be opened")
	check(gated.open("ma") and not gated.open("gobi"), "only one word is open at a time")
	# Slot layout is a function of the syllable.
	check(gated.slots_for("마") == ["initial", "medial"] and gated.slots_for("한") == ["initial", "medial", "final"], "slots_for: two slots, plus a final one for a 받침 syllable")
	check(gated.close().is_empty() and not gated.is_open(), "closing an empty view returns nothing")
	_section_done("test_spelling_logic")


## Moves the mouse from `from` to `to` with the left button held, then releases.
func _drag(viewport: Viewport, from: Vector2, to: Vector2) -> void:
	var move := InputEventMouseMotion.new()
	move.position = from
	move.global_position = from
	viewport.push_input(move)
	viewport.push_input(_click_event(from))
	await get_tree().process_frame
	var steps := 6
	var here := from
	for i in steps:
		var next := from.lerp(to, (i + 1.0) / steps)
		var motion := InputEventMouseMotion.new()
		motion.position = next
		motion.global_position = next
		motion.relative = next - here
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		viewport.push_input(motion)
		here = next
		await get_tree().process_frame
	viewport.push_input(_release_event(to))
	await get_tree().process_frame
	await get_tree().process_frame


func _tile_center(map: Node3D, letter: String) -> Vector2:
	var index: int = map.basket_hud._letters.find(letter)
	return map.basket_hud._tiles_box.get_child(index).get_global_rect().get_center()


func _slot_center(map: Node3D, block: int, slot: int) -> Vector2:
	return map.spelling_hud.find_child("Slot%d_%d" % [block, slot], true, false).get_global_rect().get_center()


func test_spelling_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var viewport := map.get_viewport()
	check(map.spelling_hud is CanvasLayer and not map.spelling_hud.is_open() and not get_tree().paused, "the map has a closed spelling view and is not paused")
	# Everything discovered and every target letter picked, by the real paths.
	var by_kind := {}
	for entry in _config()["plants"]["placed"]:
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for id in _target_words():
		map.discovery.update([by_kind[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	await _settle_layout()
	var basket_size: int = map.picking.basket.size()
	check(basket_size == 28, "28 letters in the basket to spell with (%d)" % basket_size)

	# Opening is refused while restarting or dead.
	map.restarting = true
	check(not map.open_spelling("ma") and not get_tree().paused and not map.spelling.is_open(), "opening is refused while restarting")
	map.restarting = false
	for i in 5:
		GameState.damage("nestor", "test")
	check(not GameState.is_alive("nestor") and not map.open_spelling("ma") and not get_tree().paused, "opening is refused when a traveler is dead")
	GameState.new_hike()
	GameState.controlled = "fernanda"

	# A real click on the list entry opens it and pauses.
	var row: Control = map.discovery_hud._rows["ma"]
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(map.spelling_hud.is_open() and map.spelling.open_id == "ma", "clicking the 마 entry opens the spelling view")
	check(get_tree().paused and not map.can_process(), "opening pauses the map")
	check(map.spelling_hud.can_process() and map.basket_hud.can_process() and map.discovery_hud.can_process(), "the view, basket and list keep running while paused")
	await _settle_layout()
	var title: Label = map.spelling_hud.find_child("Title", true, false)
	check(title.text == "Korean yam", "the view shows the English name")
	var blocks: Control = map.spelling_hud.find_child("Blocks", true, false)
	check(blocks.get_child_count() == 1, "마 has one block")
	var panel: Rect2 = map.spelling_hud._panel.get_global_rect()
	check(is_equal_approx(panel.get_center().x, 640.0) and Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(panel), "the panel is centred and on screen (%s)" % str(panel))
	check(not panel.intersects(map.basket_hud._panel.get_global_rect()) and not panel.intersects(map.discovery_hud.get_child(0).get_global_rect()), "the panel overlaps neither the full basket nor the full list")
	check(map.spelling_hud.find_child("Slot0_0", true, false).get_global_rect().size.x >= 60.0, "a slot is big enough to drop into")
	check(not map.open_spelling("meoru") and map.spelling.open_id == "ma", "a second entry cannot open over the first")

	# Real drags. Letters outside a slot snap back; in a slot they stay.
	var before: Array = map.picking.basket.duplicate()
	await _drag(viewport, _tile_center(map, "ㅁ"), Vector2(100.0, 650.0))
	check(map.picking.basket == before and map.spelling.placed == ["", ""], "a letter dropped outside any slot stays in the basket")
	await _drag(viewport, _tile_center(map, "ㅁ"), _slot_center(map, 0, 0))
	check(map.spelling.placed == ["ㅁ", ""] and map.picking.basket.size() == basket_size - 1, "dragging ㅁ into the consonant slot places it (%s)" % str(map.spelling.placed))
	await _settle_layout()
	await _drag(viewport, _slot_center(map, 0, 0), map.basket_hud._panel.get_global_rect().get_center())
	check(map.spelling.placed == ["", ""] and map.picking.basket.size() == basket_size, "dragging it back to the basket takes it back")
	await _settle_layout()
	await _drag(viewport, _tile_center(map, "ㅁ"), _slot_center(map, 0, 0))
	await _settle_layout()
	await _drag(viewport, _tile_center(map, "ㅏ"), _slot_center(map, 0, 1))
	check(map.spelling.is_done("ma") and not map.spelling.is_open(), "ㅁ then ㅏ spells 마 and completes it")
	check(not map.spelling_hud.is_open() and not get_tree().paused, "the view closed and the map is unpaused")
	check(map.picking.basket.size() == basket_size - 2, "the two letters were consumed")
	map.discovery_hud.refresh()
	var done_row: Control = map.discovery_hud._rows["ma"]
	check(done_row.find_child("Done", true, false) != null, "the 마 entry shows a done mark")
	var filled: Array = done_row.find_children("*", "Label", true, false).map(func(l): return l.text)
	check(filled.has("마"), "the 마 entry shows the Korean word (%s)" % str(filled))
	viewport.push_input(_click_event(done_row.get_global_rect().get_center()))
	viewport.push_input(_release_event(done_row.get_global_rect().get_center()))
	check(not map.spelling_hud.is_open() and not get_tree().paused, "a done entry opens nothing")

	# A wrong block by real drags: ㅁ+ㅏ is 마, but 머루 wants 머. Both letters are destroyed.
	var count_before: int = map.picking.basket.size()
	var failed_seen := _watch_failures(map.spelling)
	check(map.open_spelling("meoru"), "머루 opens")
	await _settle_layout()
	var spare: bool = map.picking.basket.has("ㅁ") and map.picking.basket.has("ㅏ")
	check(spare, "the basket still holds a ㅁ and a spare ㅏ")
	if spare:
		await _drag(viewport, _tile_center(map, "ㅁ"), _slot_center(map, 0, 0))
		await _settle_layout()
		await _drag(viewport, _tile_center(map, "ㅏ"), _slot_center(map, 0, 1))
		check(failed_seen.size() == 1 and failed_seen[0][0] == "meoru" and failed_seen[0][1] == 0 and failed_seen[0][2] == ["ㅁ", "ㅏ"], "syllable_failed fired for the block (%s)" % str(failed_seen))
		check(map.spelling_hud.is_open() and map.spelling_hud.is_flashing() and get_tree().paused, "the failed block flashes while the view is still up")
		check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "no damage yet while the failure flash plays")
		check(map.picking.basket.size() == count_before - 2, "both letters left the basket for good")
		map.spelling_hud.tick(0.3)
		check(map.spelling_hud.is_open(), "still flashing at 0.3 s")
		map.spelling_hud.tick(0.4)
		check(not map.spelling_hud.is_open() and not get_tree().paused and not map.spelling.is_open(), "after the flash the view closes and the map is unpaused")
		check(GameState.heart_units["nestor"] == 9 and GameState.heart_units["fernanda"] == 9, "once the view has closed, a real failed drag costs both travelers half a heart")
		check(not map.spelling.is_done("meoru") and map.spelling.solved("meoru").is_empty(), "a failure solves nothing")

	# Esc closes the view; unjudged letters go back, judged blocks stay.
	var space_count: int = map.picking.basket.size()
	check(map.open_spelling("gobi"), "고비 opens")
	await _settle_layout()
	var gobi: Array = _word_letters("고비")
	map.spelling_hud.apply(map.spelling.place(gobi[0][0], 0, 0))
	map.spelling_hud.apply(map.spelling.place(gobi[0][1], 0, 1))
	check(map.spelling.solved("gobi") == ["고"] and map.spelling.current_block() == 1, "고 is judged right")
	map.spelling_hud.apply(map.spelling.place(gobi[1][0], 1, 0))
	check(map.picking.basket.size() == space_count - 3, "one more letter sits in block 2")
	viewport.push_input(_key_event(KEY_ESCAPE))
	check(not map.spelling_hud.is_open() and not get_tree().paused, "Esc closes the view and unpauses")
	check(map.picking.basket.size() == space_count - 2 and map.spelling.solved("gobi") == ["고"], "the unjudged letter is back; the judged 고 stays")
	check(map.open_spelling("gobi") and map.spelling.current_block() == 1, "reopened, 고비 resumes at block 2")
	map.spelling_hud.find_child("Close", true, false).pressed.emit()
	check(not map.spelling_hud.is_open() and not get_tree().paused, "the close button closes it too")
	map.discovery_hud.refresh()
	check(map.discovery_hud._rows["gobi"].find_children("*", "Label", true, false).any(func(l): return l.text == "고"), "the entry shows the judged 고 as progress")
	check(map.discovery_hud._rows["gobi"].find_child("Done", true, false) == null, "but is not marked done")

	# Restart: a fresh map has no progress, no letters, no marks.
	map.free()
	check(not get_tree().paused, "freeing the map never leaves the tree paused")
	var again: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(again)
	again.set_physics_process(false)
	check(not again.spelling.is_done("ma") and again.spelling.solved("ma").is_empty() and again.spelling.solved("gobi").is_empty(), "a restarted scene has no spelling progress")
	check(again.picking.basket.is_empty() and again.discovery.entries.is_empty() and not again.spelling_hud.is_open(), "and an empty basket, list and view")
	again.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_spelling_scene")


# ---- Failure damage, placeholder gore, the heart readout and death ----

const DamageScript := preload("res://scenes/foraging/damage.gd")


func _colors_ok(block: Dictionary, key: String) -> bool:
	var color = block.get(key)
	var ok: bool = color is Array and color.size() == 3
	if ok:
		for channel in color:
			ok = ok and channel is float and channel >= 0.0 and channel <= 1.0
	return ok


func test_damage_data() -> void:
	var damage: Dictionary = _config().get("damage", {})
	check(not damage.is_empty(), "hallasan.json has a damage block")
	var units = damage.get("failure_damage_units")
	check(units is float and units == floorf(units) and units > 0.0, "damage.failure_damage_units is a positive whole number")
	check(units is float and int(units) == 1, "(Hallasan) a failure costs one half-unit, half a heart")
	var gore: Dictionary = _config().get("gore_placeholder", {})
	check(not gore.is_empty(), "hallasan.json has a gore_placeholder block")
	for key in ["burst_duration", "stagger", "tint_duration", "death_beat", "death_dim_alpha"]:
		check(gore.get(key) is float and float(gore[key]) > 0.0, "gore_placeholder.%s is a positive number" % key)
	check(gore.get("death_dim_alpha") is float and float(gore["death_dim_alpha"]) <= 1.0, "gore_placeholder.death_dim_alpha is at most 1")
	for key in ["blood_color", "tint_color"]:
		check(_colors_ok(gore, key), "gore_placeholder.%s has three channels in 0..1" % key)
	var hud: Dictionary = _config().get("hearts_hud", {})
	check(not hud.is_empty(), "hallasan.json has a hearts_hud block")
	for key in ["heart_size", "gap", "margin"]:
		check(hud.get(key) is float and float(hud[key]) > 0.0, "hearts_hud.%s is a positive number" % key)
	for key in ["fill_color", "outline_color"]:
		check(_colors_ok(hud, key), "hearts_hud.%s has three channels in 0..1" % key)
	_section_done("test_damage_data")


func test_damage_logic() -> void:
	var config: Dictionary = _config()["damage"]
	var step := int(config["failure_damage_units"])
	var damage = DamageScript.new(config)
	var deaths := []
	var on_death := func(dead, survivor, injury): deaths.append([dead, survivor, injury])
	GameState.travelers_died.connect(on_death)
	GameState.new_hike(0)
	check(damage.settle() == {"failures": 0, "died": false} and GameState.heart_units["nestor"] == 10, "settling with nothing queued changes nothing")
	damage.queue_failure()
	check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "queuing a failure costs nothing yet")
	var result: Dictionary = damage.settle()
	check(result == {"failures": 1, "died": false}, "settling applies one failure (%s)" % str(result))
	check(GameState.heart_units["nestor"] == 10 - step and GameState.heart_units["fernanda"] == 10 - step and GameState.heart_units["nestor"] == 9, "a failure lowers BOTH travelers by failure_damage_units (10 -> 9)")
	check(damage.settle()["failures"] == 0, "a failure is applied once")
	# Ten in a row, settled one at a time: the tenth kills, once.
	GameState.new_hike(0)
	deaths.clear()
	var died_at := []
	for i in 10:
		damage.queue_failure()
		if damage.settle()["died"]:
			died_at.append(i + 1)
	check(died_at == [10], "ten failures kill on the tenth, and only then (%s)" % str(died_at))
	check(deaths == [["nestor", "fernanda", "spelling"]], "the death was announced exactly once, with the injury 'spelling'")
	check(GameState.heart_units["nestor"] == 0 and GameState.heart_units["fernanda"] == 1, "nestor reached 0 first; the survivor's units are left as they were when the rule fired")
	damage.queue_failure()
	check(damage.settle() == {"failures": 0, "died": false} and deaths.size() == 1, "failures after the death do nothing and announce nothing")
	# Ten queued at once and twelve queued at once.
	for count in [10, 12]:
		GameState.new_hike(0)
		deaths.clear()
		for i in count:
			damage.queue_failure()
		result = damage.settle()
		check(result["died"] and deaths.size() == 1 and damage.pending == 0, "%d queued at once: one death, nothing left over" % count)
		check(result["failures"] == 10, "%d queued at once: only the 10 that happened are applied (%d)" % [count, result["failures"]])
	# The old whole-heart call still works.
	GameState.new_hike(0)
	GameState.damage("nestor", "test")
	check(GameState.heart_units["nestor"] == 8, "the old damage() still takes exactly one whole heart")
	# Nothing in the foraging scripts heals.
	var heals := 0
	for path in ["foraging", "damage", "hearts_hud", "spelling", "spelling_hud", "traveler"]:
		heals += FileAccess.get_file_as_string("res://scenes/foraging/%s.gd" % path).count("heal(")
	check(heals == 0, "nothing in the foraging scripts calls heal()")
	GameState.travelers_died.disconnect(on_death)
	GameState.new_hike(0)
	_section_done("test_damage_logic")


func _new_hearts_map() -> Node3D:
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)  # the tests tick the death beat themselves
	return map


## Emits a failed syllable the way the Spelling does, then the view closing.
func _fail_and_close(map: Node3D) -> void:
	map.spelling.syllable_failed.emit("ma", 0, ["ㅁ", "ㅓ"])
	map.spelling_hud.closed.emit()


func test_hearts_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	GameState.new_hike()
	var map := _new_hearts_map()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var screen: Vector2 = map.get_viewport().get_visible_rect().size
	var hud = map.hearts_hud
	var gore: Dictionary = _config()["gore_placeholder"]
	var tint := Color(gore["tint_color"][0], gore["tint_color"][1], gore["tint_color"][2])

	# The readout at the start of the hike.
	check(hud is CanvasLayer and hud.get_child_count() == 1, "the readout is a layer with a single panel")
	check(hud.drawn_states("nestor") == [2, 2, 2, 2, 2] and hud.drawn_states("fernanda") == [2, 2, 2, 2, 2], "5 full hearts each at the start")
	check(hud.states_for(9) == [2, 2, 2, 2, 1] and hud.states_for(0) == [0, 0, 0, 0, 0] and hud.states_for(3) == [2, 1, 0, 0, 0], "states_for: 4.5 hearts is 4 full + 1 half, 0 is all outlines, 1.5 is full + half")
	var names: Array = hud.find_children("*", "Label", true, false).map(func(l): return l.text)
	check(names == ["Nestor", "Fernanda"], "one row per traveler, named (%s)" % str(names))

	# It follows GameState through hearts_changed.
	GameState.damage_units("nestor", 1)
	check(hud.drawn_states("nestor") == [2, 2, 2, 2, 1] and hud.drawn_states("fernanda") == [2, 2, 2, 2, 2], "9 units draws 4 full + 1 half, and only for that traveler")
	GameState.damage_units("nestor", 9)
	check(hud.drawn_states("nestor") == [0, 0, 0, 0, 0], "0 units draws all outlines")
	GameState.new_hike()
	hud.refresh()

	# Layout at 1280x720 against the discovery list, the basket and the spelling view.
	var by_kind := {}
	for entry in _config()["plants"]["placed"]:
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for id in _target_words():
		map.discovery.update([by_kind[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	await _settle_layout()
	var panel: Rect2 = hud.panel_rect()
	var margin := float(_config()["hearts_hud"]["margin"])
	var list_rect: Rect2 = map.discovery_hud.get_child(0).get_global_rect()
	var bag_rect: Rect2 = map.basket_hud._panel.get_global_rect()
	check(Rect2(Vector2.ZERO, screen).encloses(panel), "the readout is inside the viewport (%s)" % str(panel))
	check(is_equal_approx(panel.end.x, screen.x - margin) and is_equal_approx(panel.position.y, margin), "it sits at the top right margin")
	check(not panel.intersects(list_rect), "it does not overlap the full discovery list")
	check(not panel.intersects(bag_rect), "it does not overlap the full basket")
	check(map.open_spelling("ma"), "the spelling view opens")
	await _settle_layout()
	check(not panel.intersects(map.spelling_hud._panel.get_global_rect()), "it does not overlap the spelling view")
	map.spelling_hud.close()
	var contents_ok := true
	for node in hud._panel.find_children("*", "Control", true, false):
		contents_ok = contents_ok and hud._panel.get_global_rect().encloses(node.get_global_rect())
	check(contents_ok, "every name and heart stays inside the panel")

	# Mouse filters and a real click.
	check(hud._panel.mouse_filter == Control.MOUSE_FILTER_STOP, "the readout panel stops mouse clicks")
	var inner_ok := true
	for node in hud._panel.find_children("*", "Control", true, false):
		inner_ok = inner_ok and node.mouse_filter == Control.MOUSE_FILTER_IGNORE
	check(inner_ok, "its rows, names and hearts let clicks fall through to the panel")
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var clickable := _visible_plant(map, func(p): return p.kind != "target" and not panel.has_point(map.camera.unproject_position(p.global_position + Vector3(0, 0.5, 0))))
	check(not clickable.is_empty(), "a plant outside the readout is on screen")
	if not clickable.is_empty():
		var sp: Vector2 = clickable["screen"]
		hud._panel.global_position = sp - hud._panel.size / 2.0
		await _settle_layout()
		hud._panel.global_position = sp - hud._panel.size / 2.0
		map.get_viewport().push_input(_click_event(sp))
		check(map.picking.walk_target == -1, "a click on a plant that is behind the readout starts no walk")
		map.get_viewport().push_input(_release_event(sp))
		map._unhandled_input(_click_event(sp))
		check(map.picking.walk_target >= 0, "(control) the same click reaching the map would have started one")
		map.picking.cancel_walk()
	map.free()

	# Damage after the view closes; gore on both travelers, staggered.
	GameState.new_hike()
	map = _new_hearts_map()
	await get_tree().physics_frame
	hud = map.hearts_hud
	var beats := []
	map.death_beat_started.connect(func(): beats.append(true))
	map.spelling.syllable_failed.emit("ma", 0, ["ㅁ", "ㅓ"])
	check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "a failure alone costs nothing: the damage waits for the view to close")
	var blood := func() -> Array: return map.get_children().filter(func(n): return n is CPUParticles3D)
	check(blood.call().is_empty(), "and no blood is shed yet")
	map.spelling_hud.closed.emit()
	check(GameState.heart_units["nestor"] == 9 and GameState.heart_units["fernanda"] == 9, "when the view closes both travelers lose a half heart (10 -> 9)")
	check(hud.drawn_states("nestor") == [2, 2, 2, 2, 1] and hud.drawn_states("fernanda") == [2, 2, 2, 2, 1], "the readout shows 4.5 hearts for both")
	check(blood.call().size() == 1, "the first traveler's blood burst starts at once")
	check(map.travelers["nestor"].body_color().is_equal_approx(tint), "that traveler's body flashes the tint colour")
	var burst: CPUParticles3D = blood.call()[0]
	check(burst.one_shot and burst.emitting and is_equal_approx(burst.lifetime, float(gore["burst_duration"])), "the burst is a one-shot of the data's duration")
	check(burst.global_position.distance_to(map.travelers["nestor"].global_position) < 2.0, "and it is at the first traveler")
	await get_tree().create_timer(float(gore["stagger"]) + 0.15).timeout
	check(blood.call().size() == 2, "the second traveler's burst follows after the stagger")
	var near := 0
	for b in blood.call():
		for id in GameState.TRAVELERS:
			if b.global_position.distance_to(map.travelers[id].global_position) < 2.0:
				near += 1
	check(near >= 2, "the two bursts are at the two travelers")
	check(beats.is_empty() and not map.restarting, "no death beat for a survivable failure")
	map.spelling_hud.closed.emit()
	check(GameState.heart_units["nestor"] == 9, "a view that closes without a failure costs nothing")

	# Ten failures: the tenth kills, once, and starts one death beat.
	GameState.new_hike()
	map.free()
	map = _new_hearts_map()
	await get_tree().physics_frame
	hud = map.hearts_hud
	beats.clear()
	map.death_beat_started.connect(func(): beats.append(true))
	var deaths := []
	var on_death := func(dead, _survivor, _injury): deaths.append(dead)
	GameState.travelers_died.connect(on_death)
	for i in 9:
		_fail_and_close(map)
	check(GameState.heart_units["nestor"] == 1 and GameState.is_alive("nestor") and beats.is_empty() and not map.restarting, "nine failures leave both on half a heart, no beat")
	_fail_and_close(map)
	check(GameState.heart_units["nestor"] == 0 and deaths == ["nestor"], "the tenth kills (one traveler at 0 first, the rule kills both), announced once")
	check(beats.size() == 1 and map.restarting and map.is_death_beat_playing(), "and the death beat starts once")
	check(hud.drawn_states("nestor") == [0, 0, 0, 0, 0], "the readout shows the traveler at 0 as outlines")
	GameState.travelers_died.disconnect(on_death)

	# During the beat: nothing can be picked, walked to or opened.
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	var letters_before: int = map.picking.letters_left()
	check(not map.pick_nearest() and map.picking.letters_left() == letters_before, "Space picks nothing during the beat")
	check(not map.click(Vector2(640.0, 360.0)) and map.picking.walk_target == -1, "a click starts no walk during the beat")
	check(not map.open_spelling("ma") and not map.spelling.is_open() and not get_tree().paused, "the spelling view cannot open during the beat")
	var dim: ColorRect = map._dim
	check(dim.color.a == 0.0, "the screen has not dimmed at the first instant")
	map.tick_beat(float(gore["death_beat"]) / 2.0)
	check(is_equal_approx(dim.color.a, float(gore["death_dim_alpha"]) / 2.0) and map.is_death_beat_playing(), "halfway through the beat the screen is half dimmed")
	map.free()
	GameState.new_hike()

	# The beat on a living pair isolates the restarting flag.
	map = _new_hearts_map()
	await get_tree().physics_frame
	beats.clear()
	map.death_beat_started.connect(func(): beats.append(true))
	map.begin_death_beat()
	map.begin_death_beat()
	check(beats.size() == 1 and map.restarting, "begin_death_beat sets restarting, and only starts one beat")
	check(not map.picks_allowed() and not map.pick_nearest() and not map.open_spelling("ma"), "restarting alone rejects picks and the spelling view")
	map.free()
	GameState.new_hike()

	# Restart: hearts back to the scene-start snapshot, the scene fresh. The map
	# becomes the current scene so the real reload path runs.
	var original_scene := get_tree().current_scene
	GameState.new_hike()
	GameState.heart_units["nestor"] = 7  # an odd count carried into the scene
	GameState.heart_units["fernanda"] = 9
	var doomed := _new_hearts_map()
	remove_child(doomed)
	get_tree().root.add_child(doomed)
	get_tree().current_scene = doomed
	await get_tree().physics_frame
	var started := []
	doomed.restarted.connect(func(): started.append(true))
	for plant in doomed.plants:
		if plant.kind == "target":
			doomed.pick_plant(plant)
			break
	doomed.discovery.update([by_kind["ma"]], 0.0)
	check(doomed.picking.basket.size() == 1 and not doomed.discovery.entries.is_empty(), "(before the death the scene holds a letter and a list entry)")
	for i in 7:
		_fail_and_close(doomed)
	check(not GameState.is_alive("nestor") and doomed.restarting, "seven half-heart failures kill the one at 3.5 hearts")
	doomed.tick_beat(0.5)
	check(started.is_empty(), "the scene has not restarted mid-beat")
	doomed.tick_beat(float(gore["death_beat"]))
	check(started.size() == 1, "the scene restarts when the beat ends")
	check(GameState.heart_units["nestor"] == 7 and GameState.heart_units["fernanda"] == 9, "hearts are exactly the scene-start snapshot, odd units included")
	for i in 4:
		await get_tree().process_frame
	var fresh: Node = get_tree().current_scene
	check(fresh != doomed and not is_instance_valid(doomed), "the scene was reloaded")
	if fresh != doomed and is_instance_valid(fresh) and fresh.has_method("picks_allowed"):
		check(fresh.picking.basket.is_empty() and fresh.discovery.entries.is_empty() and fresh.spelling.solved("ma").is_empty() and not fresh.spelling_hud.is_open(), "the reloaded scene has an empty basket, list and spelling progress")
		check(not fresh.restarting and fresh.picks_allowed(), "and play is allowed again")
		check(fresh.hearts_hud.drawn_states("nestor") == [2, 2, 2, 1, 0] and fresh.hearts_hud.drawn_states("fernanda") == [2, 2, 2, 2, 1], "the readout shows the restored hearts (3.5 and 4.5)")
		fresh.set_process(false)
		fresh.free()
	get_tree().current_scene = original_scene
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_hearts_scene")


# ---- Spare plants ----

const SparesScript := preload("res://scenes/foraging/spares.gd")


func _new_spares(cap := -1):
	var block: Dictionary = _config()["spares"].duplicate()
	if cap >= 0:
		block["cap"] = float(cap)
	return SparesScript.new(block, _config()["plants"])


## Every letter the 28 target plants carry.
func _target_letters() -> Array:
	var kinds := {}
	for kind in _hangul_plants():
		kinds[kind["id"]] = kind["kind"]
	var letters := []
	for entry in _placed():
		if kinds[entry["kind"]] == "target":
			letters.append(entry["letter"])
	return letters


## `letters` without one copy of each of `gone`.
func _without(letters: Array, gone: Array) -> Array:
	var rest := letters.duplicate()
	for letter in gone:
		rest.erase(letter)
	return rest


## A progress map with these words fully judged.
func _solved_words(ids: Array) -> Dictionary:
	var solved := {}
	for id in ids:
		solved[id] = Hangul.syllable_count(_target_words()[id])
	return solved


func test_spares_data() -> void:
	var block: Dictionary = _config().get("spares", {})
	check(not block.is_empty(), "hallasan.json has a spares block")
	var cap = block.get("cap")
	check(cap is float and cap == floorf(cap) and cap > 0.0, "spares.cap is a positive whole number")
	check(cap is float and int(cap) == 6, "(Hallasan) at most 6 spares")
	check(block.get("grow_seconds") is float and float(block["grow_seconds"]) > 0.0, "spares.grow_seconds is positive")
	var slots: Dictionary = block.get("slots", {})
	var words := _target_words()
	var ids_match := slots.size() == words.size()
	for id in words:
		ids_match = ids_match and slots.has(id)
	check(ids_match, "one slot per target word (%d)" % slots.size())
	var half_depth := float(_config()["stage"]["depth"]) / 2.0
	var starts: Array[Vector2] = []
	for id in _config()["start"]:
		starts.append(Vector2(float(_config()["start"][id][0]), float(_config()["start"][id][1])))
	var by_id := {}
	for kind in _hangul_plants():
		by_id[kind["id"]] = kind
	var spacing_ok := true
	var same_ok := true
	var start_ok := true
	var stage_ok := true
	for id in words:
		var pair = slots.get(id)
		var well_formed: bool = pair is Array and pair.size() == 2 and pair[0] is float and pair[1] is float
		check(well_formed, "%s's slot is [x, z]" % words[id])
		if not well_formed:
			continue
		var spot := Vector2(float(pair[0]), float(pair[1]))
		var zone_x := _zone_range(by_id[id]["zone"])
		check(spot.x >= float(zone_x[0]) + 1.0 and spot.x <= float(zone_x[1]) - 1.0, "%s's slot is inside its own zone (1 m from the edges)" % words[id])
		stage_ok = stage_ok and absf(spot.y) <= half_depth - 1.0
		for start in starts:
			start_ok = start_ok and spot.distance_to(start) >= 6.0
		for entry in _placed():
			var other := Vector2(float(entry["x"]), float(entry["z"]))
			spacing_ok = spacing_ok and spot.distance_to(other) >= 2.0
			same_ok = same_ok and (entry["kind"] != id or spot.distance_to(other) >= 4.0)
		for other_id in words:
			var other_pair = slots.get(other_id)
			if other_id != id and other_pair is Array and other_pair.size() == 2:
				spacing_ok = spacing_ok and spot.distance_to(Vector2(float(other_pair[0]), float(other_pair[1]))) >= 2.0
	check(stage_ok, "every slot is on the stage")
	check(spacing_ok, "every slot is at least 2 m from every plant and every other slot")
	check(same_ok, "every slot is at least 4 m from the placed plants of its own kind")
	check(start_ok, "no slot is within 6 m of a traveler's start")
	_section_done("test_spares_data")


func test_spares_logic() -> void:
	var all := _target_letters()
	var spares = _new_spares()
	check(all.size() == 28 and spares.needed({}).size() == 28, "28 jamo are needed to spell all six words")
	var sorted_needed: Array = spares.needed({})
	sorted_needed.sort()
	var sorted_all := all.duplicate()
	sorted_all.sort()
	check(sorted_needed == sorted_all, "the jamo needed are exactly the jamo on the target plants")
	check(spares.needed(_solved_words(["ma", "meoru", "minari", "gosari", "simiro"])) == ["ㄱ", "ㅗ", "ㅂ", "ㅣ"], "a word's needs are all its jamo, repeats included")
	var half_done := _solved_words(["ma", "meoru", "minari", "gosari", "simiro"])
	half_done["gobi"] = 1
	check(spares.needed(half_done) == ["ㅂ", "ㅣ"], "judged blocks need nothing more (고 judged, 비 left)")

	# No deficit.
	var choice: Dictionary = spares.choose({}, all)
	check(choice["letter"] == "" and choice["deficit"] == 0 and choice["reason"] == "no deficit", "every jamo available: no deficit, nothing to spawn")
	check(spares.choose({}, all + ["ㅍ", "ㅍ", "ㅏ"])["letter"] == "", "surplus jamo never make a deficit")
	check(_new_spares().choose(_solved_words(["ma"]), _without(all, ["ㅁ", "ㅏ"]))["letter"] == "", "a finished word's jamo are not needed any more")
	# One missing jamo.
	choice = spares.choose({}, _without(all, ["ㅂ"]))
	check(choice["letter"] == "ㅂ" and choice["deficit"] == 1 and choice["reason"] == "short of ㅂ by 1", "one missing jamo is the one chosen (%s)" % str(choice))
	# The largest deficit wins, even over an earlier jamo.
	choice = spares.choose({}, _without(all, ["ㅁ", "ㅣ", "ㅣ"]))
	check(choice["letter"] == "ㅣ" and choice["deficit"] == 2, "the largest deficit wins (ㅣ short by 2 beats ㅁ short by 1): %s" % str(choice))
	# A deficit counts repeats: two ㅣ needed by 미나리, one is left.
	choice = spares.choose({}, _without(all, ["ㅣ"]))
	check(choice["letter"] == "ㅣ" and choice["deficit"] == 1, "a repeated jamo is short by one when one copy is missing")
	# Ties: the earliest unfinished word, then the first position in it.
	choice = spares.choose({}, _without(all, ["ㅂ", "ㅁ"]))
	check(choice["letter"] == "ㅁ", "a tie goes to the earliest word's jamo (ㅁ in 마, before ㅂ in 고비)")
	var late := _solved_words(["ma", "meoru", "minari"])
	var late_have := _without(spares.needed(late), ["ㅂ", "ㅁ"])
	check(spares.choose(late, late_have)["letter"] == "ㅂ", "ma, meoru, minari done: 고비 comes before 시로미, so ㅂ beats ㅁ")
	var only_gobi := _solved_words(["ma", "meoru", "minari", "gosari", "simiro"])
	check(spares.choose(only_gobi, _without(spares.needed(only_gobi), ["ㅂ", "ㄱ"]))["letter"] == "ㄱ", "within one word, the jamo first in the word wins a tie (ㄱ before ㅂ in 고비)")
	# Decoys never count: the caller passes only the basket and target letters, so
	# a spare's own letter is what makes a deficit go away.
	choice = spares.choose({}, _without(all, ["ㅂ"]))
	check(spares.choose({}, _without(all, ["ㅂ"]) + [choice["letter"]])["letter"] == "", "a spare already on the map counts as available")

	# settle: the queue, the pool, the cap.
	var sp = _new_spares()
	check(sp.queue("ma") and not sp.queue("ma") and not sp.queue("no_such_word") and sp.has_pending(), "a word queues once; unknown ids do not queue")
	check(sp.queue("meoru"), "a second word queues")
	var orders: Array[Dictionary] = sp.settle({}, _without(all, ["ㅂ"]))
	check(orders.size() == 1 and orders[0]["word_id"] == "ma" and orders[0]["letter"] == "ㅂ" and orders[0]["spot"] == sp.slots["ma"], "two words, one shortage: only the first spawns, at its own slot")
	check(sp.decisions.size() == 2 and sp.decisions[1]["reason"] == "no deficit" and not sp.decisions[1]["spawn"], "the first spare counts as available for the second word")
	check(not sp.has_pending() and not sp.queue("ma") and sp.settle({}, []).is_empty(), "settling empties the queue; a settled word never queues again")
	var capped = _new_spares(2)
	for id in _target_words():
		capped.queue(id)
	orders = capped.settle({}, [])
	check(orders.size() == 2 and capped.spawned.size() == 2, "with cap 2, two spares spawn out of six words")
	var reasons: Array = capped.decisions.map(func(d): return d["reason"])
	check(reasons.count("cap reached") == 4, "the other four are refused for the cap (%s)" % str(reasons))
	var full = _new_spares()
	for id in _target_words():
		full.queue(id)
	orders = full.settle({}, [])
	var distinct := {}
	for order in orders:
		distinct[order["word_id"]] = true
	check(orders.size() == 6 and full.spawned.size() <= full.cap and distinct.size() == 6, "six completed words, nothing available: six spares, one per word, within the cap")
	for id in _target_words():
		check(not full.queue(id), "%s cannot spawn a second time" % id)
	_section_done("test_spares_logic")


## A fresh map with every target discovered and every target letter in the basket.
func _spares_map(pick_everything := true) -> Node3D:
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var by_kind := {}
	for entry in _placed():
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for id in _target_words():
		map.discovery.update([by_kind[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	if pick_everything:
		for plant in map.plants:
			if plant.kind == "target":
				map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	return map


## Spells a word with the right letters through the HUD's own path. Returns the last result.
func _spell(map: Node3D, id: String) -> Dictionary:
	var result := {}
	map.open_spelling(id)
	var blocks := _word_letters(_target_words()[id])
	for b in blocks.size():
		for slot in 2:
			result = map.spelling.place(blocks[b][slot], b, slot)
			map.spelling_hud.apply(result)
	return result


func _normal_plant(map: Node3D, kind_id: String) -> Node3D:
	for plant in map.plants:
		if plant.kind_id == kind_id and not map.spare_plants.has(plant):
			return plant
	return null


func test_spares_scene() -> void:
	var map: Node3D = await _spares_map()
	check(map.spares != null and map.spare_plants.is_empty() and map.plants.size() == 36, "a fresh map has 36 plants and no spares")
	check(map.picking.basket.size() == 28, "28 letters picked")
	var available: Array = map._available_letters()
	var sorted_available := available.duplicate()
	sorted_available.sort()
	var sorted_all := _target_letters()
	sorted_all.sort()
	check(sorted_available == sorted_all, "available = the basket's 28 letters; the decoys' letters are not in it")

	# Slots stay clear of props and trees on the real map.
	var props_ok := true
	var trees_ok := true
	for id in _target_words():
		var spot: Vector2 = map.spares.slots[id]
		for group in ["Props", "Scenery"]:
			for prop in map.get_node(group).get_children():
				var b: AABB = prop.bounds
				if Rect2(b.position.x, b.position.z, b.size.x, b.size.z).has_point(spot):
					props_ok = false
		for pos in _config()["scenery"]["gusangnamu"]["positions"]:
			trees_ok = trees_ok and spot.distance_to(Vector2(float(pos[0]), float(pos[1]))) >= 2.5
	check(props_ok, "no slot is inside a rock, tree or 구상나무")
	check(trees_ok, "every slot is at least 2.5 m from the 구상나무")

	# Scripted run, step 1: 마 completes with every letter picked; nothing is short.
	var result := _spell(map, "ma")
	check(result["result"] == "complete" and map.spelling.is_done("ma") and not get_tree().paused, "마 is spelled and the view has closed")
	var decisions: Array = map.spares.decisions
	print("  scripted run, step 1 (마 done, all 28 picked): %s" % str(decisions))
	check(decisions.size() == 1 and decisions[0]["word_id"] == "ma" and not decisions[0]["spawn"] and decisions[0]["reason"] == "no deficit" and decisions[0]["action"] == "credit banked" and map.spares.credits == ["ma"], "step 1: no deficit, so 마 spawns nothing and banks its credit")
	check(map.spare_plants.is_empty() and map.plants.size() == 36 and map.picking.plant_count() == 36, "step 1: nothing was spawned")

	# Step 2: a failed block destroys ㄹ and ㅜ. 마's banked credit is spent on ㄹ.
	map.open_spelling("meoru")
	map.spelling_hud.apply(map.spelling.place("ㄹ", 0, 0))
	map.spelling_hud.apply(map.spelling.place("ㅜ", 0, 1))
	check(map.spare_plants.is_empty() and map.spelling_hud.is_open(), "step 2: the spare waits while the failure flash is up")
	map.spelling_hud.tick(1.0)
	check(not map.spelling_hud.is_open() and map.spares.decisions.size() == 3 and map.spare_plants.size() == 1 and map.spares.credits.is_empty(), "step 2: the closed view spawns one spare from 마's credit, then logs ㅜ uncovered (no credit left)")
	check(map.spares.decisions[2]["action"] == "shortage left uncovered" and map.spares.decisions[2]["letter"] == "ㅜ", "step 2: the uncovered shortage is logged")
	print("  scripted run, step 2 (ㄹ and ㅜ destroyed): %s" % str(map.spares.decisions.slice(1)))
	var solved := {}
	for id in map.spares.word_ids():
		solved[id] = map.spelling.solved(id).size()
	check(map.spare_plants[0].kind_id == "ma" and map.spare_plants[0].letter == "ㄹ" and map.spares.decisions[1]["action"] == "credit spent on failure", "step 2: a 마 spare carrying ㄹ (the tie goes to 머루's ㄹ, before ㅜ)")
	var expect: Dictionary = map.spares.choose(solved, map._available_letters())
	check(expect["letter"] == "ㅜ" and expect["deficit"] == 1, "step 2: ㅜ is still short (%s)" % str(expect))

	# Step 3: 고비 completes with ㅜ short: its own credit is spent. The spawn waits for the view to close.
	check(map.open_spelling("gobi"), "고비 opens")
	var gobi_letters := _word_letters("고비")
	var last := {}
	for b in 2:
		for slot in 2:
			last = map.spelling.place(gobi_letters[b][slot], b, slot)
	check(last["result"] == "complete" and map.spelling.is_done("gobi"), "고비 is judged complete")
	check(map.spare_plants.size() == 1 and map.spares.has_pending() and map.spelling_hud.is_open(), "the spare waits: the view is still open")
	map.spelling_hud.apply(last)
	check(not map.spelling_hud.is_open() and map.spare_plants.size() == 2 and not map.spares.has_pending(), "once the view has closed, the spare appears")
	print("  scripted run, step 3 (고비 done): %s" % str(map.spares.decisions[3]))
	var spare: Node3D = map.spare_plants[1]
	solved["gobi"] = 2
	var needed_now: Array = map.spares.needed(solved)
	check(spare.letter == "ㅜ" and needed_now.has(spare.letter), "step 3: the spare carries ㅜ, which an unfinished word still needs")
	check(map.spares.decisions[3]["spawn"] and map.spares.decisions[3]["reason"] == "short of ㅜ by 1" and map.spares.decisions[3]["action"] == "credit spent on completion", "step 3: the decision says why")
	check(spare.kind_id == "gobi" and spare.hover_name == "royal fern" and spare.kind == "target", "the spare is a plant of the word just finished (고비, royal fern)")
	check(Vector2(spare.position.x, spare.position.z) == map.spares.slots["gobi"] and is_equal_approx(spare.position.y, map.terrain.height_at(spare.position.x)), "it stands at the word's slot, on the ground")
	check(map.plants.size() == 38 and map.picking.plant_count() == 38 and map.plants[37] == spare, "it is the 38th plant, in step with the picking state")
	var after: Dictionary = map.spares.choose(solved, map._available_letters())
	print("  scripted run, step 4 (with both spares on the map): deficit logic says %s" % str(after))
	check(after["letter"] == "", "with both spares on the map nothing is short (%s)" % str(after))

	# Grow-in: not pickable until it ends.
	var normal := _normal_plant(map, "gobi")
	check(spare.scale.x < 0.05 and not map.picking.is_pickable(37) and map.picking.has_letter(37), "at spawn the spare is tiny, has its letter, and is locked")
	_stand_near(map, spare)
	map.update_camera(0.0, true)
	map.step(Vector2.ZERO, 0.0)
	var basket_before: int = map.picking.basket.size()
	check(map._tip_plant == spare and map._tooltip_label.text == "royal fern", "walking up to the spare flashes its name, as for any plant")
	check(map.picking.nearest_pickable(Vector2(map.player.global_position.x, map.player.global_position.z)) == -1 and not map.pick_nearest(), "Space does not pick a growing spare")
	check(not map.picking.start_walk(37) and not map._ring.visible, "nor can it be walked to, and the ring is not on it")
	map.step(Vector2.ZERO, 0.25)
	check(spare.scale.x > 0.5 and spare.scale.x < 1.0 and not map.pick_nearest() and map.picking.basket.size() == basket_before, "halfway through the grow-in it is partly grown and still not pickable (scale %.2f)" % spare.scale.x)
	map.step(Vector2.ZERO, 0.3)
	check(spare.scale.is_equal_approx(Vector3.ONE) and map.picking.is_pickable(37), "after grow_seconds it is full size and pickable")
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Behaves exactly like a normal plant of its kind.
	var body_parts := func(plant: Node3D) -> int:  # the letter's label is gone from a plant that was picked
		return plant.get_children().filter(func(c): return not c is Label3D).size()
	check(body_parts.call(spare) == body_parts.call(normal) and spare.letter_style == normal.letter_style and spare.tooltip_text() == normal.tooltip_text(), "same look (child count, letter style) and tooltip as a normal 고비 plant")
	check(map._ring.visible and map._ring_plant == spare and map._ring.global_position.is_equal_approx(spare.global_position), "the reach ring is on the grown spare")
	var spare_ring: Vector3 = map._ring.mesh.get_aabb().size
	var normal_ring: Vector3 = map._ring_mesh(normal.global_position).get_aabb().size
	check(is_equal_approx(spare_ring.x, normal_ring.x) and is_equal_approx(spare_ring.z, normal_ring.z), "the ring is the same size as a normal plant's")
	var screen: Vector2 = map.camera.unproject_position(spare.global_position + Vector3(0, 0.5, 0))
	check(map.plant_at(screen) == spare, "hovering the spare finds it")
	check(map.click(screen) and map.picking.walk_target == 37, "clicking the spare starts a walk to it")
	map.picking.cancel_walk()
	var discovered_before: int = map.discovery.entries.size()
	check(map.pick_nearest() and map.picking.basket.size() == basket_before + 1 and map.picking.basket.back() == "ㅜ" and spare.letter == "", "Space picks it: its ㅜ joins the basket")
	check(not map.pick_nearest() and not map.picking.has_letter(37) and map.spares.spawned.size() == 2, "a picked spare stays letterless and does not respawn")
	check(map.discovery.entries.size() == discovered_before, "the spare changed nothing in the discovery list")
	map.free()

	# The cap and one spare per word, on a map where every letter is gone.
	map = await _spares_map(false)
	for plant in map.plants:
		if plant.kind == "target":
			plant.take_letter()
	var kinds_seen := []
	for id in _target_words():
		map.spelling.word_completed.emit(id)
	map.spelling_hud.closed.emit()
	check(map.spare_plants.size() == 6 and map.spares.spawned.size() == 6, "six words completed, nothing available: six spares")
	for plant in map.spare_plants:
		kinds_seen.append(plant.kind_id)
		check(Vector2(plant.position.x, plant.position.z) == map.spares.slots[plant.kind_id], "%s's spare is at its slot" % plant.kind_id)
	kinds_seen.sort()
	var expected_kinds := _target_words().keys()
	expected_kinds.sort()
	check(kinds_seen == expected_kinds, "one spare per word, each of its own kind")
	for id in _target_words():
		map.spelling.word_completed.emit(id)
	map.spelling_hud.closed.emit()
	check(map.spare_plants.size() == 6 and map.plants.size() == 42, "a word cannot spawn twice: still six spares")
	map.free()
	map = await _spares_map(false)
	for plant in map.plants:
		if plant.kind == "target":
			plant.take_letter()
	map.spares.cap = 3
	for id in _target_words():
		map.spelling.word_completed.emit(id)
	map.spelling_hud.closed.emit()
	check(map.spare_plants.size() == 3, "the cap stops the spares (cap 3: %d spawned)" % map.spare_plants.size())
	# Closing a view with no completed word spawns nothing.
	map.spelling_hud.closed.emit()
	check(map.spare_plants.size() == 3, "closing the view again spawns nothing more")
	map.free()

	# Restart: a rebuilt scene has none and the bookkeeping is clear.
	var again: Node3D = await _spares_map(false)
	check(again.spare_plants.is_empty() and again.spares.spawned.is_empty() and again.spares.decisions.is_empty() and not again.spares.has_pending(), "a rebuilt scene has no spares and no bookkeeping")
	check(again.plants.size() == 36 and again.picking.plant_count() == 36 and again._growing.is_empty(), "and the 36 placed plants only")
	for plant in again.plants:
		if plant.kind == "target":
			plant.take_letter()
	again.spelling.word_completed.emit("ma")
	again.spelling_hud.closed.emit()
	check(again.spare_plants.size() == 1, "the same word can earn a spare again in the new scene")
	again.free()
	GameState.new_hike()
	_section_done("test_spares_scene")


func test_spares_real_events() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _spares_map()
	var viewport := map.get_viewport()
	# One ㅅ is lost (both 고사리 and 시로미 need one), so spelling 마 leaves a shortage.
	map.picking.basket.erase("ㅅ")
	map.basket_hud.refresh(1.0)
	await _settle_layout()
	var row: Control = map.discovery_hud._rows["ma"]
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(map.spelling_hud.is_open() and map.spelling.open_id == "ma", "a real click on the 마 entry opens the view")
	await _settle_layout()
	await _drag(viewport, _tile_center(map, "ㅁ"), _slot_center(map, 0, 0))
	await _settle_layout()
	check(map.spare_plants.is_empty(), "after one real drag nothing has spawned")
	await _drag(viewport, _tile_center(map, "ㅏ"), _slot_center(map, 0, 1))
	check(map.spelling.is_done("ma") and not map.spelling_hud.is_open() and not get_tree().paused, "two real drags spell 마 and the view closes")
	check(map.spare_plants.size() == 1, "a spare appeared")
	if map.spare_plants.size() == 1:
		var spare: Node3D = map.spare_plants[0]
		check(spare.kind_id == "ma" and spare.hover_name == "Korean yam" and spare.letter == "ㅅ", "it is a 마 plant carrying the missing ㅅ (%s, %s)" % [spare.kind_id, spare.letter])
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_spares_real_events")


## Every decision's action, for messages and checks.
func _actions(sp) -> Array:
	return sp.decisions.map(func(d): return d["action"])


## A Spares with these words already completed cleanly (credits banked, nothing short).
func _banked(ids: Array, cap := -1):
	var sp = _new_spares(cap)
	var solved := _solved_words(ids)
	for id in ids:
		sp.queue(id)
	sp.settle(solved, sp.needed(solved))
	return sp


func test_credits_logic() -> void:
	var all := _target_letters()
	var four := ["ma", "meoru", "minari", "gosari"]
	var left := _solved_words(four)  # 고비 and 시로미 are still to spell

	# A clean completion banks a credit and spawns nothing.
	var sp = _new_spares()
	sp.queue("ma")
	var orders: Array[Dictionary] = sp.settle(_solved_words(["ma"]), _without(all, ["ㅁ", "ㅏ"]))
	check(orders.is_empty() and sp.credits == ["ma"] and sp.spawned.is_empty(), "마 completes with no shortage: nothing spawns, one credit is banked")
	check(sp.decisions[0]["action"] == "credit banked" and sp.decisions[0]["reason"] == "no deficit" and sp.credit_total() == 1, "the decision says the credit was banked")

	# Several credits banked, then a failure destroys two needed letters.
	sp = _banked(four)
	check(sp.credits == four and sp.spawned.is_empty(), "four clean words bank four credits, oldest first (%s)" % str(sp.credits))
	sp.queue_failure()
	orders = sp.settle(left, _without(sp.needed(left), ["ㅂ", "ㅁ"]))  # the failure destroyed ㅂ and ㅁ
	check(orders.size() == 2 and orders[0]["word_id"] == "ma" and orders[1]["word_id"] == "meoru", "two letters destroyed: the two oldest credits (마, 머루) are spent")
	check(orders[0]["letter"] == "ㅂ" and orders[1]["letter"] == "ㅁ", "each carries the largest remaining deficit (tie: 고비's ㅂ before 시로미's ㅁ)")
	check(orders[0]["spot"] == sp.slots["ma"] and orders[1]["spot"] == sp.slots["meoru"], "each spawns at its own word's slot")
	check(sp.credits == ["minari", "gosari"] and sp.credit_total() == 4, "the leftover credits stay banked (%s)" % str(sp.credits))
	check(_actions(sp).slice(-2) == ["credit spent on failure", "credit spent on failure"], "both spends are logged as spent on failure")

	# The deficit is recomputed after each spawn: ㅣ short by 2 first, then ㅂ, then ㅣ again.
	sp = _banked(four)
	sp.queue_failure()
	orders = sp.settle(left, _without(sp.needed(left), ["ㅣ", "ㅣ", "ㅂ"]))
	var letters: Array = orders.map(func(o): return o["letter"])
	check(letters == ["ㅣ", "ㅂ", "ㅣ"], "largest deficit first, recomputed after each spawn (%s)" % str(letters))
	check(sp.credits == ["gosari"] and sp.spawned.size() == 3, "the shortage is covered by three spares; one credit is left")

	# No banked credit: the shortage stays uncovered and is logged.
	sp = _new_spares()
	sp.queue_failure()
	orders = sp.settle({}, _without(all, ["ㅂ"]))
	check(orders.is_empty() and sp.spawned.is_empty(), "a failure with no credits spawns nothing")
	check(sp.decisions.size() == 1 and sp.decisions[0]["action"] == "shortage left uncovered" and sp.decisions[0]["reason"] == "short of ㅂ by 1", "and logs the uncovered shortage (%s)" % str(sp.decisions))
	# Credits run out partway: the rest of the shortage is logged.
	sp = _banked(["ma"])
	var one := _solved_words(["ma"])
	sp.queue_failure()
	orders = sp.settle(one, _without(sp.needed(one), ["ㅂ", "ㅁ"]))
	check(orders.size() == 1 and sp.credits.is_empty() and _actions(sp).slice(-2) == ["credit spent on failure", "shortage left uncovered"], "one credit covers one of two letters; the other is logged uncovered (%s)" % str(_actions(sp)))

	# A failure with no shortage (extra copies exist) spends nothing.
	sp = _banked(["ma"])
	sp.queue_failure()
	orders = sp.settle(one, sp.needed(one) + ["ㅂ", "ㅁ"])
	check(orders.is_empty() and sp.credits == ["ma"] and sp.decisions[-1]["action"] == "no shortage, no credit spent", "extra copies exist: the failure spends no credit")

	# Completion with a shortage spends its own credit at once, not an older one.
	sp = _banked(["ma"])
	sp.queue("gobi")
	var two := _solved_words(["ma", "gobi"])
	orders = sp.settle(two, _without(sp.needed(two), ["ㅁ"]))
	check(orders.size() == 1 and orders[0]["word_id"] == "gobi" and orders[0]["letter"] == "ㅁ" and sp.credits == ["ma"], "completion with a shortage spends the word's own credit, leaving 마's banked")
	check(sp.decisions[-1]["action"] == "credit spent on completion", "and logs it")

	# The cap: banked + spawned never passes it.
	var every := _target_words().keys()
	sp = _banked(every)
	check(sp.credits.size() == 6 and sp.credit_total() == 6, "six words completed: six credits")
	var fresh := _solved_words([])
	for i in 4:  # several failures, each short of a letter
		sp.queue_failure()
		sp.settle(fresh, _without(all, ["ㅂ", "ㅁ"]))
		check(sp.credit_total() <= sp.cap, "after failure %d: %d banked + %d spawned within the cap" % [i + 1, sp.credits.size(), sp.spawned.size()])
	var slots_used := {}
	var twice := false
	for order in sp.spawned:
		twice = twice or slots_used.has(order["word_id"])
		slots_used[order["word_id"]] = true
	check(not twice and sp.spawned.size() == 6 and sp.credits.is_empty(), "failures spend the credits two at a time until none are left (6 spawned), and no slot was used twice")
	for id in every:
		check(not sp.queue(id), "%s cannot earn a second credit" % id)
	var small = _new_spares(2)
	var done := _solved_words(every)
	for id in ["ma", "meoru", "minari", "gosari"]:
		small.queue(id)
	small.settle(done, [])
	check(small.credits == ["ma", "meoru"] and _actions(small).count("no credit (cap reached)") == 2, "with cap 2, only the first two completions earn a credit")
	small.queue_failure()
	small.settle(fresh, _without(all, ["ㅂ", "ㅁ", "ㅏ"]))
	check(small.credit_total() == 2 and small.spawned.size() == 2 and small.credits.is_empty(), "spending credits keeps banked + spawned at the cap")
	_section_done("test_credits_logic")


func test_credits_scene() -> void:
	var map: Node3D = await _spares_map()
	var hearts_seen := []
	var on_hearts := func(_who: String, _units: int) -> void: hearts_seen.append(map.spare_plants.size())
	GameState.hearts_changed.connect(on_hearts)
	# The playtest: five words spelled cleanly, then the sixth fails.
	var five := ["ma", "meoru", "minari", "gosari", "gobi"]
	for n in five.size():
		var result := _spell(map, five[n])
		check(result["result"] == "complete" and map.spare_plants.is_empty(), "%s spelled cleanly: no spare" % five[n])
		check(map.spares.credits.size() == n + 1, "after %s: %d credits banked" % [five[n], n + 1])
	print("  scripted run, five clean words: credits %s, actions %s" % [str(map.spares.credits), str(_actions(map.spares))])
	check(map.spares.credits == five and map.spares.spawned.is_empty() and map.plants.size() == 36, "five credits banked, nothing spawned, still 36 plants")
	var hearts_before := GameState.hearts_for_display("nestor")
	map.open_spelling("simiro")
	map.spelling_hud.apply(map.spelling.place("ㅣ", 0, 0))
	map.spelling_hud.apply(map.spelling.place("ㅅ", 0, 1))
	check(map.spelling_hud.is_open() and map.spare_plants.is_empty() and map.spares.has_pending(), "the failure's spares wait for the view to close")
	check(is_equal_approx(GameState.hearts_for_display("nestor"), hearts_before), "and so does the damage")
	map.spelling_hud.tick(1.0)
	check(not map.spelling_hud.is_open() and map.spare_plants.size() == 2, "the view closed: two spares appeared")
	check(not hearts_seen.is_empty() and hearts_seen[0] == 2, "the spares were on the map before the damage was applied (%s)" % str(hearts_seen))
	check(GameState.hearts_for_display("nestor") < hearts_before, "the damage was applied")
	GameState.hearts_changed.disconnect(on_hearts)
	print("  scripted run, sixth word fails (ㅣ, ㅅ destroyed): credits %s, decisions %s" % [str(map.spares.credits), str(map.spares.decisions.slice(5))])
	check(map.spare_plants[0].kind_id == "ma" and map.spare_plants[0].letter == "ㅅ", "the oldest credit (마) became a spare carrying ㅅ")
	check(map.spare_plants[1].kind_id == "meoru" and map.spare_plants[1].letter == "ㅣ", "the next (머루) became a spare carrying ㅣ")
	check(map.spares.credits == ["minari", "gosari", "gobi"] and map.spares.credit_total() == 5, "three credits stay banked")
	var solved := {}
	for id in map.spares.word_ids():
		solved[id] = map.spelling.solved(id).size()
	check(map.spares.choose(solved, map._available_letters())["letter"] == "", "the shortage is covered")
	for spare in map.spare_plants:
		check(Vector2(spare.position.x, spare.position.z) == map.spares.slots[spare.kind_id], "%s's spare stands at its own slot" % spare.kind_id)
	check(map.plants.size() == 38 and map.picking.plant_count() == 38 and map.plants[36] == map.spare_plants[0], "the spares are plants 37 and 38, in step with picking")
	map.step(Vector2.ZERO, 0.6)
	check(map.picking.is_pickable(36) and map.picking.is_pickable(37) and map.spare_plants[0].scale.is_equal_approx(Vector3.ONE), "after the grow-in both are full size and pickable")
	map.free()

	# A failure with no banked credit spawns nothing and logs it.
	map = await _spares_map()
	map.open_spelling("ma")
	map.spelling_hud.apply(map.spelling.place("ㅏ", 0, 0))
	map.spelling_hud.apply(map.spelling.place("ㅁ", 0, 1))
	map.spelling_hud.tick(1.0)
	check(map.spare_plants.is_empty() and map.spares.decisions.size() == 1 and map.spares.decisions[0]["action"] == "shortage left uncovered", "a failure with no credits: nothing spawns, the uncovered shortage is logged")
	map.free()

	# The cap with all six words completed and several failures.
	map = await _spares_map(false)
	for plant in map.plants:
		if plant.kind == "target":
			plant.take_letter()
	for id in _target_words():
		map.spelling.word_completed.emit(id)
	map.spelling_hud.closed.emit()
	check(map.spares.credit_total() == 6, "six completions with every letter gone: banked + spawned is the cap")
	for i in 3:
		map.spelling.syllable_failed.emit("ma", 0, ["ㅁ", "ㅏ"])
		map.spelling_hud.closed.emit()
		check(map.spares.credit_total() <= map.spares.cap and map.spare_plants.size() == map.spares.spawned.size(), "failure %d: still within the cap" % (i + 1))
	var kinds: Array = map.spare_plants.map(func(p): return p.kind_id)
	var once := true
	for id in _target_words():
		once = once and kinds.count(id) <= 1
	check(once, "no word's slot was used twice")
	map.free()

	# Restart: credits and spares are gone.
	var again: Node3D = await _spares_map(false)
	check(again.spares.credits.is_empty() and again.spares.spawned.is_empty() and again.spares.decisions.is_empty() and again.spare_plants.is_empty(), "a rebuilt scene has no credits and no spares")
	for plant in again.plants:
		if plant.kind == "target":
			plant.take_letter()
	again.spelling.word_completed.emit("ma")
	again.spelling_hud.closed.emit()
	check(again.spare_plants.size() == 1, "the same word can earn again in the new scene")
	again.free()
	GameState.new_hike()
	_section_done("test_credits_scene")


func test_credits_real_events() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _spares_map()
	var viewport := map.get_viewport()
	for id in ["ma", "meoru", "minari", "gosari", "gobi"]:
		_spell(map, id)
	check(map.spares.credits.size() == 5 and map.spare_plants.is_empty(), "five words banked five credits")
	await _settle_layout()
	var row: Control = map.discovery_hud._rows["simiro"]
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(map.spelling_hud.is_open() and map.spelling.open_id == "simiro", "a real click on the 시로미 entry opens the view")
	await _settle_layout()
	await _drag(viewport, _tile_center(map, "ㅣ"), _slot_center(map, 0, 0))
	await _settle_layout()
	await _drag(viewport, _tile_center(map, "ㅅ"), _slot_center(map, 0, 1))
	check(map.spelling.solved("simiro").is_empty() and map.spelling_hud.is_open() and map.spare_plants.is_empty(), "two real drags (ㅣ, ㅅ) fail the block; the failure flash is up and nothing has spawned yet")
	map.spelling_hud.tick(1.0)  # the flash length is the HUD's own timer; ended by hand
	check(not map.spelling_hud.is_open() and map.spare_plants.size() == 2, "after the flash the view closes and two spares appear")
	if map.spare_plants.size() == 2:
		check(map.spare_plants[0].kind_id == "ma" and map.spare_plants[0].letter == "ㅅ" and map.spare_plants[1].kind_id == "meoru" and map.spare_plants[1].letter == "ㅣ", "마's spare carries ㅅ and 머루's carries ㅣ")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_credits_real_events")


## The first 36 plants as [x, z] in file order, and the six spare slots, as they
## were before the walk limit: Prompt 5e must not move any of them.
const FROZEN_PLANTS: Array[float] = [
	2.0, -9.0, 25.0, 4.0, 2.0, 10.0, 11.0, -8.0, 19.5, 0.5, 25.5, -7.5,
	5.0, 9.5, 11.0, 9.0, 13.0, -4.0, 18.5, 5.0, 23.0, -1.5, 26.0, 7.0,
	5.0, -8.5, 8.0, 8.5, 14.5, 9.0, 19.0, -9.0, 22.0, 5.5, 26.0, -3.0,
	1.5, 7.0, 8.0, -8.0, 17.0, -4.0, 25.0, 10.0, 13.0, 4.0, 20.0, -5.0,
	15.0, 1.5, 21.5, 9.5, 36.5, 5.5, 34.5, -3.0, 47.0, 5.5, 50.5, -3.5,
	52.5, 3.5, 55.0, -8.0, 59.5, -1.5, 62.0, 6.0, 46.0, 2.5, 49.5, -6.5,
]
const FROZEN_SLOTS := {
	"ma": [15.0, -8.5], "meoru": [13.0, -1.0], "minari": [22.5, -10.0],
	"gosari": [16.5, -1.0], "gobi": [12.0, 6.5], "simiro": [57.5, 10.0],
}


func test_walk_limit_data() -> void:
	var config := _config()
	var limit: Dictionary = config.get("walk_limit", {})
	check(limit.get("near_margin") is float, "walk_limit.near_margin is in hallasan.json and is a number")
	var margin := float(limit.get("near_margin", -1.0))
	check(margin > 0.0 and margin <= 1.0, "the near margin is a small positive distance (%.2f m)" % margin)
	var half_depth := float(config["stage"]["depth"]) / 2.0
	var near_edge: float = half_depth + float(config["apron"]["sides"])  # the ground's near edge
	check(margin < float(config["apron"]["sides"]), "the margin is smaller than the near apron")
	check(near_edge - margin > half_depth, "the walk limit (before the slope pulls it back) lies beyond the stage's near edge, on the apron")
	var placed := _placed()
	check(placed.size() == 36 and FROZEN_PLANTS.size() == 72, "36 placed plants")
	var same := placed.size() == 36
	for i in mini(placed.size(), 36):
		same = same and is_equal_approx(float(placed[i]["x"]), FROZEN_PLANTS[2 * i]) and is_equal_approx(float(placed[i]["z"]), FROZEN_PLANTS[2 * i + 1])
	check(same, "the 36 placed plants are exactly where they were")
	var slots: Dictionary = config["spares"]["slots"]
	var slots_same := slots.size() == FROZEN_SLOTS.size()
	for id in FROZEN_SLOTS:
		slots_same = slots_same and slots.has(id) and is_equal_approx(float(slots[id][0]), FROZEN_SLOTS[id][0]) and is_equal_approx(float(slots[id][1]), FROZEN_SLOTS[id][1])
	check(slots_same, "the six spare slots are exactly where they were")
	check(is_equal_approx(float(config["stage"]["width"]), 64.0) and is_equal_approx(float(config["stage"]["depth"]), 24.0), "the stage, and with it the ground, props and backdrop, is unchanged")
	check(config["start"]["nestor"] == [6.0, 1.5] and config["start"]["fernanda"] == [4.0, -1.5], "the starts are unchanged")
	_section_done("test_walk_limit_data")


## Metres of ground (along z) between a traveler's feet and the bottom edge of the
## screen. Negative means the feet are below the screen.
func _feet_gap(map: Node3D, traveler: Node3D) -> float:
	var height: float = map.get_viewport().get_visible_rect().size.y
	var screen: Vector2 = map.camera.unproject_position(traveler.global_position)
	return (height - screen.y) * (map.camera.size / height) / sin(deg_to_rad(map.CAMERA_PITCH_DEG))


func test_walk_limit_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)  # the game's own 16:9 view; headless starts square
	await get_tree().process_frame
	var config := _config()
	var map: Node3D = await _fresh_reach_map()
	check(is_equal_approx(map.get_viewport().get_visible_rect().size.aspect(), 16.0 / 9.0), "the test view is 16:9")
	var bounds: Rect2 = map.walk_bounds()
	var margin := float(config["walk_limit"]["near_margin"])
	var half_depth: float = map.stage_depth / 2.0
	var old_limit: float = half_depth - map.TRAVELER_MARGIN
	check(is_equal_approx(map.near_limit_at(64.0), map.ground_rect.end.y - margin), "on the flat ground at the right end the limit is the ground's near edge minus the margin (%.2f)" % map.near_limit_at(64.0))
	var limits_ok := true
	var shortest := INF
	for at_x in range(0, 65, 2):
		var l: float = map.near_limit_at(clampf(at_x, bounds.position.x, bounds.end.x))
		shortest = minf(shortest, l)
		limits_ok = limits_ok and l > old_limit + 5.0 and l <= map.ground_rect.end.y - margin + 0.0001
	check(limits_ok, "at every x the limit is well past the old stop and never past the ground (shortest %.2f)" % shortest)
	print("  near limit z at x = 0: %.2f, 32: %.2f, 64: %.2f (old stop %.1f)" % [map.near_limit_at(0.4), map.near_limit_at(32.0), map.near_limit_at(63.6), old_limit])
	check(is_equal_approx(bounds.position.y, -half_depth + map.TRAVELER_MARGIN), "the far limit is unchanged")
	check(is_equal_approx(bounds.position.x, map.TRAVELER_MARGIN) and is_equal_approx(bounds.end.x, map.stage_width - map.TRAVELER_MARGIN), "the left and right limits are unchanged")
	var same_bounds := true
	for traveler in map.travelers.values():
		same_bounds = same_bounds and traveler.bounds == bounds
	check(same_bounds, "both travelers use the walk bounds")

	# Walk down at x = 0, 32 and 64 (the travelers' own x margin applies at the ends).
	var dt := 1.0 / 60.0
	for x in [0.0, 32.0, 64.0]:
		var lane := clampf(x, bounds.position.x, bounds.end.x)
		var limit: float = map.near_limit_at(lane)
		map.partner.global_position = _ground_point(map, clampf(lane + 3.0, bounds.position.x, bounds.end.x - 1.0), 0.0)
		map.player.global_position = _ground_point(map, lane, 0.0)
		map.update_camera(0.0, true)
		var lowest := INF
		var crossed_old := false
		for i in 480:
			map.step(Vector2(0.0, 1.0), dt)
			lowest = minf(lowest, _feet_gap(map, map.player))
			crossed_old = crossed_old or map.player.global_position.z > old_limit + 1.0
		var z: float = map.player.global_position.z
		check(crossed_old, "x = %.0f: S walks past the old stop (z %.1f)" % [x, old_limit])
		limit = map.near_limit_at(map.player.global_position.x)  # the partner may have nudged the player a little along x
		check(absf(z - limit) < 0.01, "x = %.0f: S stops at the new limit, not before (z %.3f, limit %.3f)" % [x, z, limit])
		var gap := _feet_gap(map, map.player)
		check(absf(gap - margin) < 0.02, "x = %.0f: the feet are the margin above the bottom edge of the screen (%.3f m, margin %.2f)" % [x, gap, margin])
		check(lowest > 0.0, "x = %.0f: on the way down the feet never leave the screen (lowest gap %.3f m)" % [x, lowest])
		var zs: Array[float] = []
		var ys: Array[float] = []
		for i in 30:
			map.step(Vector2(0.0, 1.0), dt)
			zs.append(map.player.global_position.z)
			ys.append(map.player.global_position.y)
		check(zs.max() - zs.min() < 0.0001 and ys.max() - ys.min() < 0.002, "x = %.0f: it stays put against the limit, no jitter or sliding" % x)
		check(map.player.on_floor, "x = %.0f: and stands on the ground there" % x)
		check(_view_over_land(map), "x = %.0f: the view at the limit is all ground or backdrop" % x)

	# Along the bottom of the climb: the camera's height smoothing lags behind the
	# slope, so walking along the limit must still keep the feet on screen.
	map.partner.global_position = _ground_point(map, 30.0, 0.0)
	map.player.global_position = _ground_point(map, bounds.position.x, map.near_limit_at(bounds.position.x))
	map.update_camera(0.0, true)
	var worst := INF
	var worst_x := 0.0
	var view_ok := true
	for pass_index in 2:
		var dir := Vector2(1.0, 1.0) if pass_index == 0 else Vector2(-1.0, 1.0)
		for i in 900:
			map.step(dir, dt)
			var g := _feet_gap(map, map.player)
			if g < worst:
				worst = g
				worst_x = map.player.global_position.x
			if i % 30 == 0:
				view_ok = view_ok and _view_over_land(map)
	print("  lowest feet gap walking along the limit: %.3f m at x = %.1f (margin %.2f)" % [worst, worst_x, margin])
	check(worst > 0.0, "walking along the limit, up and down the slope, the feet stay on screen (lowest %.3f m)" % worst)
	check(view_ok, "and the view stays over ground the whole way")

	# The far end is unchanged: W stops at the stage edge.
	map.player.global_position = _ground_point(map, 32.0, 0.0)
	for i in 480:
		map.step(Vector2(0.0, -1.0), dt)
	check(absf(map.player.global_position.z - bounds.position.y) < 0.01, "W still stops at the far limit (z %.2f)" % map.player.global_position.z)

	# The partner follows without leaving the new bounds, however it is pulled.
	var partner_limit: float = map.near_limit_at(20.0)
	map.player.global_position = _ground_point(map, 20.0, partner_limit)
	map.partner.global_position = _ground_point(map, 10.0, 0.0)
	var inside := true
	for i in 600:
		map.step(Vector2.ZERO, dt)
		var p: Vector3 = map.partner.global_position
		inside = inside and bounds.grow(0.001).has_point(Vector2(p.x, p.z)) and p.z <= map.near_limit_at(p.x) + 0.001
	var gap_vector: Vector3 = map.partner.global_position - map.player.global_position
	gap_vector.y = 0.0
	check(inside, "the partner never leaves the walk bounds")
	check(gap_vector.length() <= map.PARTNER_STOP_DISTANCE + 0.1 and map.partner.global_position.z > old_limit - 1.0, "the partner followed the player down onto the near strip")
	for i in 300:
		map.partner.follow(Vector3(20.0, 0.0, partner_limit + 10.0), 0.1, dt)  # a target below the limit
	check(absf(map.partner.global_position.z - map.near_limit_at(map.partner.global_position.x)) < 0.01, "a follow target below the limit leaves the partner at the limit")

	# Click-to-walk: a plant whose position is below the limit is walked to as far
	# as the limit, and the walk then ends instead of pushing for ever.
	var target := _lone_plant(map, "target")
	var index: int = map.plants.find(target)
	var home: Vector3 = target.position
	var column: float = clampf(home.x, 2.0, 60.0)
	var column_limit: float = map.near_limit_at(column)
	target.position = _ground_point(map, column, column_limit + 6.0)
	map.partner.global_position = _ground_point(map, column + 3.0, column_limit - 8.0)
	map.player.global_position = _ground_point(map, column, column_limit - 6.0)
	map.update_camera(0.0, true)
	check(map.picking.start_walk(index), "a walk to a plant below the limit starts")
	var deepest := 0.0
	var ticks := 0
	while map.picking.walk_target >= 0 and ticks < 600:
		map.step(Vector2.ZERO, dt)
		deepest = maxf(deepest, map.player.global_position.z)
		ticks += 1
	check(map.picking.walk_target < 0 and ticks < 600, "the walk ends by itself (%d ticks)" % ticks)
	check(deepest <= column_limit + 0.0001 and absf(map.player.global_position.z - column_limit) < 0.05, "the player went to the nearest valid point, the limit, and no further (z %.3f)" % map.player.global_position.z)
	check(absf(map.player.global_position.x - column) < 0.1, "at the plant's own x")
	check(target.letter != "", "and the unreachable plant keeps its letter")
	target.position = home
	map.free()

	# A plant on the near strip, 0.8 m above the limit: reach, ring, hover, click and Space.
	map = await _fresh_reach_map()
	var kind: Dictionary = map._kinds["meoru"]
	var spots := [Vector2(30.0, map.near_limit_at(30.0) - 0.8), Vector2(24.0, map.near_limit_at(24.0) - 0.8)]
	var made: Array[Node3D] = []
	for spot in spots:
		var plant: Node3D = map._add_plant(kind, "ㅓ", spot.x, spot.y)
		var slot: int = map.picking.add_plant("ㅓ", false, spot)
		check(slot == map.plants.size() - 1, "the extra plant has the same index in the plants and in picking")
		made.append(plant)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var first := made[0]
	map.player.global_position = _ground_point(map, 30.0, map.near_limit_at(30.0) - 5.0)
	map.step(Vector2.ZERO, dt)
	check(map._tip_plant != first and not map._ring.visible, "away from it there is no name and no ring")
	map.player.global_position = _ground_point(map, 30.4, map.near_limit_at(30.4))
	map.update_camera(0.0, true)
	map.step(Vector2.ZERO, dt)
	check(map._tip_plant == first and map._tooltip.visible, "walking into reach at the limit flashes its name")
	check(map._ring.visible and map._ring_plant == first and map._ring.global_position.is_equal_approx(first.global_position), "the reach ring is on it")
	var screen: Vector2 = map.camera.unproject_position(first.global_position + Vector3(0, 0.5, 0))
	check(get_viewport().get_visible_rect().has_point(screen), "it is on screen")
	check(map.plant_at(screen) == first, "hovering it finds it")
	map._tip_plant = null
	map._hover_plant = null
	map.update_hover(Vector2(-10.0, -10.0), 0.0)
	map.update_hover(screen, 0.0)
	check(map._tip_plant == first and map._tooltip.visible, "hover shows its name")
	check(map.pick_nearest() and map.picking.basket == ["ㅓ"] and first.letter == "", "Space picks it at the limit")
	var second := made[1]
	map.player.global_position = _ground_point(map, 24.0, map.near_limit_at(24.0) - 4.0)
	map.update_camera(0.0, true)
	for i in 5:
		await get_tree().physics_frame
	var second_screen: Vector2 = map.camera.unproject_position(second.global_position + Vector3(0, 0.5, 0))
	check(map.click(second_screen), "a click on it starts the walk")
	ticks = 0
	while map.picking.walk_target >= 0 and ticks < 600:
		map.step(Vector2.ZERO, dt)
		ticks += 1
	check(map.picking.basket == ["ㅓ", "ㅓ"] and second.letter == "", "the walk ends in a pick")
	map.free()

	# Props between the camera and a traveler on the near strip still fade.
	map = await _fresh_reach_map()
	var tree: Node3D = null
	for prop in map.get_node("Props").get_children():
		if prop.get_child_count() == 2 and prop.position.x > 4.0 and prop.position.x < 60.0 and prop.position.z > old_limit + 2.0 and prop.position.z < map.near_limit_at(prop.position.x) - 2.5:
			tree = prop
			break
	check(tree != null, "there is a tree on the near strip")
	if tree != null:
		map.player.global_position = _ground_point(map, tree.position.x, tree.position.z - 2.0)
		map.update_camera(0.0, true)
		map.update_prop_fade(0.3)
		check(is_equal_approx(tree.alpha, map.fade_opacity), "a tree on the near strip fades over a traveler behind it (%.2f)" % tree.alpha)
		map.player.global_position = _ground_point(map, tree.position.x + 8.0, tree.position.z - 2.0)
		map.update_prop_fade(0.3)
		check(is_equal_approx(tree.alpha, 1.0), "and comes back")
	# No sky from any x at the limit, or in any corner of the walkable area.
	var failures: Array[String] = []
	for at_x in range(0, 65, 4):
		for at_z in [bounds.position.y, 0.0, map.near_limit_at(clampf(at_x, bounds.position.x, bounds.end.x))]:
			map.player.global_position = _ground_point(map, clampf(at_x, bounds.position.x, bounds.end.x), at_z)
			map.update_camera(0.0, true)
			if not _view_over_land(map):
				failures.append("(%d, %.1f)" % [at_x, at_z])
	check(failures.is_empty(), "no sky or void from any spot of the walkable area %s" % str(failures))
	map.free()
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_walk_limit_scene")


# ---- Keyboard control in the spelling view ----

const SpellingCursorScript := preload("res://scenes/foraging/spelling_cursor.gd")


## Counts key presses that reach the unhandled stage, where the map listens.
class KeyProbe extends Node:
	var seen := 0

	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed:
			seen += 1


func test_keyboard_data() -> void:
	var block: Dictionary = _config().get("keyboard_select", {})
	check(not block.is_empty(), "hallasan.json has a keyboard_select block")
	for key in ["outline_color", "halo_color"]:
		var color = block.get(key)
		var ok: bool = color is Array and color.size() == 4
		if ok:
			for channel in color:
				ok = ok and channel is float and channel >= 0.0 and channel <= 1.0
		check(ok, "keyboard_select.%s has four channels in 0..1" % key)
	for key in ["outline_width", "halo_width", "pulse_speed", "pulse_depth"]:
		check(block.get(key) is float and float(block[key]) > 0.0, "keyboard_select.%s is a positive number" % key)
	check(block.get("pulse_depth") is float and float(block["pulse_depth"]) <= 1.0, "keyboard_select.pulse_depth is at most 1")
	check(block.get("halo_width") is float and block.get("outline_width") is float and float(block["halo_width"]) > float(block["outline_width"]), "the halo is wider than the outline")
	check(block.get("halo_color") is Array and block.get("outline_color") is Array and float(block["halo_color"][3]) < float(block["outline_color"][3]), "the halo is fainter than the outline")
	_section_done("test_keyboard_data")


func _new_cursor(columns := 7):
	var cursor = SpellingCursorScript.new()
	cursor.columns = columns
	return cursor


func test_cursor_logic() -> void:
	# An empty basket has no cursor and the keys do nothing.
	var cursor = _new_cursor()
	for action in ["left", "right", "up", "down", "place"]:
		check(cursor.press(action, 0) == "" and not cursor.shown and not cursor.is_visible_over(0), "0 tiles: %s does nothing" % action)
	check(cursor.press("", 5) == "" and not cursor.shown, "no action does nothing")
	# One tile.
	cursor = _new_cursor()
	check(not cursor.shown, "the cursor is hidden at the start")
	check(cursor.press("right", 1) == "shown" and cursor.shown and cursor.index == 0, "1 tile: the first key press shows the cursor on tile 0")
	for action in ["left", "right", "up", "down"]:
		cursor.press(action, 1)
		check(cursor.index == 0, "1 tile: %s stays on tile 0" % action)
	check(cursor.press("place", 1) == "place", "1 tile: place is reported")
	# The first press only shows it, whatever the key.
	for action in ["left", "up", "down", "place"]:
		cursor = _new_cursor()
		check(cursor.press(action, 7) == "shown" and cursor.index == 0, "the first press (%s) only shows the cursor on tile 0" % action)
	# Seven tiles: one full row. Left/right wrap; up/down have nowhere else to go.
	cursor = _new_cursor()
	check(cursor.stepped(0, "left", 7) == 6 and cursor.stepped(6, "right", 7) == 0 and cursor.stepped(3, "right", 7) == 4 and cursor.stepped(3, "left", 7) == 2, "7 tiles: left/right step one and wrap")
	check(cursor.stepped(3, "up", 7) == 3 and cursor.stepped(3, "down", 7) == 3 and cursor.stepped(0, "up", 7) == 0, "7 tiles: one row, up/down stay put")
	# Eight tiles: the second row has one tile.
	check(cursor.stepped(7, "right", 8) == 0 and cursor.stepped(0, "left", 8) == 7, "8 tiles: left/right wrap across both rows")
	check(cursor.stepped(0, "down", 8) == 7 and cursor.stepped(3, "down", 8) == 7, "8 tiles: down into the short row lands on its last tile")
	check(cursor.stepped(7, "up", 8) == 0 and cursor.stepped(7, "down", 8) == 0, "8 tiles: from the lone tile, up and down wrap to column 0")
	check(cursor.stepped(0, "up", 8) == 7 and cursor.stepped(5, "up", 8) == 7, "8 tiles: up from the first row wraps to the last row, clamped to its last tile")
	# Twenty-eight tiles: four full rows.
	check(cursor.stepped(3, "down", 28) == 10 and cursor.stepped(10, "up", 28) == 3, "28 tiles: down/up keep the column")
	check(cursor.stepped(24, "down", 28) == 3 and cursor.stepped(3, "up", 28) == 24, "28 tiles: down from the last row wraps to the first, and back")
	check(cursor.stepped(27, "right", 28) == 0 and cursor.stepped(0, "left", 28) == 27 and cursor.stepped(6, "right", 28) == 7, "28 tiles: right/left run through the rows and wrap")
	# Narrower baskets use their own column count.
	var narrow = _new_cursor(4)
	check(narrow.stepped(5, "down", 10) == 9 and narrow.stepped(9, "down", 10) == 1 and narrow.stepped(1, "up", 10) == 9, "4 columns, 10 tiles: 3 rows, the last holds 2 (down from 5 -> 9, wrap -> 1)")
	# A walk through press().
	cursor = _new_cursor()
	cursor.press("right", 28)
	cursor.press("down", 28)
	cursor.press("right", 28)
	check(cursor.index == 8, "press: shown at 0, down to 7, right to 8 (%d)" % cursor.index)
	# Clamping.
	cursor.index = 27
	cursor.clamp_to(20)
	check(cursor.index == 19, "clamping to a smaller basket lands on its last tile")
	cursor.clamp_to(0)
	check(cursor.index == 0 and cursor.shown and not cursor.is_visible_over(0) and cursor.is_visible_over(3), "an empty basket clamps to 0 and draws nothing")
	cursor.hide_cursor()
	check(not cursor.shown and not cursor.is_visible_over(3), "hiding the cursor hides it")

	# Only the active player's keys act.
	cursor = _new_cursor()
	check(cursor.active_player == 1, "player 1 is active by default")
	var p1 := {KEY_A: "left", KEY_D: "right", KEY_W: "up", KEY_S: "down", KEY_SPACE: "place"}
	var p2 := {KEY_LEFT: "left", KEY_RIGHT: "right", KEY_UP: "up", KEY_DOWN: "down", KEY_ENTER: "place"}
	for key in p1:
		check(cursor.action_for(_key_event(key)) == p1[key], "P1 active: %s is %s" % [OS.get_keycode_string(key), p1[key]])
	for key in p2:
		check(cursor.action_for(_key_event(key)) == "", "P1 active: %s does nothing" % OS.get_keycode_string(key))
	cursor.set_active_player(2)
	check(cursor.active_player == 2, "the setter switches to player 2")
	for key in p2:
		check(cursor.action_for(_key_event(key)) == p2[key], "P2 active: %s is %s" % [OS.get_keycode_string(key), p2[key]])
	var keypad := _key_event(KEY_KP_ENTER)
	keypad.location = KEY_LOCATION_RIGHT
	check(cursor.action_for(keypad) == "place", "P2 active: keypad Enter places")
	for key in p1:
		check(cursor.action_for(_key_event(key)) == "", "P2 active: %s does nothing" % OS.get_keycode_string(key))
	cursor.active_player = 3
	check(cursor.active_player == 2, "only players 1 and 2 are accepted")
	cursor.active_player = 1
	check(cursor.active_player == 1, "assigning the variable goes through the setter")
	check(cursor.action_for(_key_event(KEY_D, false)) == "", "a key release is nothing")
	check(cursor.action_for(_key_event(KEY_D, true, true)) == "right", "a held movement key repeats")
	check(cursor.action_for(_key_event(KEY_SPACE, true, true)) == "", "a held place key does not repeat")
	check(cursor.action_for(_key_event(KEY_ESCAPE)) == "" and cursor.action_for(_key_event(KEY_Q)) == "", "other keys are nothing")
	check(SpellingCursorScript.is_player_key(_key_event(KEY_ENTER)) and SpellingCursorScript.is_player_key(_key_event(KEY_A)) and not SpellingCursorScript.is_player_key(_key_event(KEY_Q)), "is_player_key sees both players' keys")
	_section_done("test_cursor_logic")


func _tap(viewport: Viewport, keycode: Key, location := KEY_LOCATION_UNSPECIFIED) -> void:
	for pressed in [true, false]:
		var event := _key_event(keycode, pressed)
		event.location = location
		viewport.push_input(event)


## Taps `key` until the cursor sits on a tile holding `letter`. False after 40 taps.
func _tap_to_letter(map: Node3D, viewport: Viewport, letter: String, key := KEY_D) -> bool:
	var cursor = map.spelling_hud.cursor
	for i in 40:
		var letters: Array[String] = map.basket_hud.letters()
		if cursor.shown and cursor.index < letters.size() and letters[cursor.index] == letter:
			return true
		_tap(viewport, key)
	return false


## Puts each letter in with the keyboard alone: move to it, then place.
func _spell_by_keys(map: Node3D, viewport: Viewport, letters: Array) -> bool:
	for letter in letters:
		if not _tap_to_letter(map, viewport, letter):
			return false
		_tap(viewport, KEY_SPACE)
	return true


func test_keyboard_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var viewport := map.get_viewport()
	var by_kind := {}
	for entry in _config()["plants"]["placed"]:
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for id in _target_words():
		map.discovery.update([by_kind[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	await _settle_layout()
	var hud = map.spelling_hud
	var cursor = hud.cursor
	var total: int = map.picking.basket.size()
	check(total == 28 and cursor.columns == 7, "28 letters in the basket, 7 per row")

	# While open, no key reaches the map's unhandled-input stage; closed, it does (the control).
	var probe := KeyProbe.new()
	probe.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(probe)
	check(map.open_spelling("ma"), "마 opens")
	await _settle_layout()
	check(not cursor.shown, "the cursor is hidden when the view opens")
	for key in [KEY_SPACE, KEY_ENTER, KEY_D, KEY_RIGHT, KEY_W, KEY_UP]:
		_tap(viewport, key)
	check(probe.seen == 0, "no player key reached the unhandled stage while the view was open (%d)" % probe.seen)
	check(get_tree().paused and not map.can_process() and map.picking.basket.size() == total, "the map stayed paused and nothing was picked")
	viewport.push_input(_key_event(KEY_ESCAPE))
	check(not hud.is_open() and not get_tree().paused, "Esc closes 마")
	cursor.hide_cursor()
	_tap(viewport, KEY_SPACE)
	check(probe.seen == 1 and not cursor.shown, "(control) with the view closed the same key reaches the map and the cursor ignores it (%d)" % probe.seen)
	probe.queue_free()
	total = map.picking.basket.size()  # the pick above may have taken a letter if one was in reach
	await _settle_layout()

	# The highlight stays inside the basket at 28 tiles, on 1280x720.
	if total == 28:
		check(map.open_spelling("ma"), "마 opens again")
		await _settle_layout()
		_tap(viewport, KEY_D)
		check(cursor.shown and cursor.index == 0 and map.basket_hud.highlight_visible(), "the first key press shows the cursor on tile 0")
		var bag: Rect2 = map.basket_hud._panel.get_global_rect()
		var screen := Rect2(Vector2.ZERO, Vector2(1280, 720))
		var inside := 0
		var tiles_ok := 0
		for i in 28:
			cursor.index = i
			var tile: Rect2 = map.basket_hud.cursor_tile_rect()
			var extent: Rect2 = map.basket_hud.cursor_extent()
			tiles_ok += 1 if tile.size.x > 40.0 and bag.encloses(tile) else 0
			inside += 1 if bag.encloses(extent) and screen.encloses(extent) else 0
		check(tiles_ok == 28, "all 28 tiles are inside the bag (%d)" % tiles_ok)
		check(inside == 28, "the outline and halo stay inside the bag and the screen for all 28 tiles (%d)" % inside)
		cursor.index = 0
		viewport.push_input(_key_event(KEY_ESCAPE))

	# A whole word with the keyboard alone: 미나리.
	var before_basket: Array = map.picking.basket.duplicate()
	check(map.open_spelling("minari") and not cursor.shown, "미나리 opens with the cursor hidden")
	await _settle_layout()
	_tap(viewport, KEY_D)
	check(cursor.shown and cursor.index == 0, "the first key shows the cursor on tile 0")
	_tap(viewport, KEY_SPACE)
	check(map.spelling.placed == [before_basket[0], ""] and map.picking.basket.size() == before_basket.size() - 1, "Space puts the highlighted letter in the first empty slot (initial), leaving the second empty")
	map.spelling.take_back(0, 0)  # start over cleanly, through the Spelling's own take-back
	map.basket_hud.refresh(0.0)
	check(map.spelling.placed == ["", ""], "(setup) the letter went back")
	var flat := []
	for pair in _word_letters("미나리"):
		flat.append_array(pair)
	var done_ids := []
	map.spelling.word_completed.connect(func(w: String) -> void: done_ids.append(w))
	var half: bool = _spell_by_keys(map, viewport, flat.slice(0, 2))
	check(half and map.spelling.solved("minari") == ["미"] and map.spelling.current_block() == 1, "ㅁ then ㅣ by keys judge 미 right and lock it")
	check(map.picking.basket.size() == before_basket.size() - 2, "exactly the two letters left the basket")
	half = _spell_by_keys(map, viewport, [flat[2]])
	check(half and map.spelling.placed == [flat[2], ""], "ㄴ goes in the initial slot of block 2 (%s)" % str(map.spelling.placed))
	await _settle_layout()
	check(cursor.shown and cursor.index < map.picking.basket.size() and map.basket_hud.highlight_visible(), "the cursor is still valid and shown after placements")
	var rest: bool = _spell_by_keys(map, viewport, flat.slice(3))
	check(rest and map.spelling.is_done("minari") and done_ids == ["minari"], "the whole word, by keys alone, completes 미나리")
	check(not hud.is_open() and not get_tree().paused and map.picking.basket.size() == before_basket.size() - 6, "the view closed, the map is running, six letters were used")
	map.discovery_hud.refresh()
	check(map.discovery_hud._rows["minari"].find_child("Done", true, false) != null, "the entry is marked done")

	# A wrong block by keys: ㅁ + ㅏ is 마, 머루 wants 머.
	var failed_seen := _watch_failures(map.spelling)
	var basket_before: Array = map.picking.basket.duplicate()
	check(map.open_spelling("meoru"), "머루 opens")
	await _settle_layout()
	check(_spell_by_keys(map, viewport, ["ㅁ", "ㅏ"]), "the keys reached ㅁ and ㅏ")
	check(failed_seen == [["meoru", 0, ["ㅁ", "ㅏ"]]], "syllable_failed fired for exactly the two letters (%s)" % str(failed_seen))
	check(map.picking.basket.size() == basket_before.size() - 2 and map.picking.basket.count("ㅁ") == basket_before.count("ㅁ") - 1 and map.picking.basket.count("ㅏ") == basket_before.count("ㅏ") - 1, "exactly those two letters are gone from the basket")
	check(hud.is_open() and hud.is_flashing() and get_tree().paused, "the block flashes while the view is up")
	check(map.damage.pending == 1 and GameState.heart_units["nestor"] == 10, "damage is queued, not applied yet")
	var cursor_before: int = cursor.index
	_tap(viewport, KEY_D)
	_tap(viewport, KEY_SPACE)
	check(cursor.index == cursor_before and map.picking.basket.size() == basket_before.size() - 2, "keys during the flash do nothing")
	hud.tick(1.0)
	check(not hud.is_open() and not get_tree().paused and GameState.heart_units["nestor"] == 9 and GameState.heart_units["fernanda"] == 9, "after the flash it closes and costs both travelers half a heart, as a mouse failure does")
	check(not map.spelling.is_done("meoru") and map.spelling.solved("meoru").is_empty(), "nothing is solved")

	# Player 2 only: arrows and Enter act, WASD and Space do not (and the reverse for player 1).
	check(map.open_spelling("gosari"), "고사리 opens")
	await _settle_layout()
	var open_basket: Array = map.picking.basket.duplicate()
	for key in [KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_ENTER]:
		_tap(viewport, key)
	_tap(viewport, KEY_KP_ENTER, KEY_LOCATION_RIGHT)
	check(not cursor.shown and map.picking.basket == open_basket and map.spelling.placed == ["", ""], "player 1 active: arrows and Enter do nothing")
	cursor.set_active_player(2)
	for key in [KEY_A, KEY_D, KEY_W, KEY_S, KEY_SPACE]:
		_tap(viewport, key)
	check(not cursor.shown and map.picking.basket == open_basket and map.spelling.placed == ["", ""], "player 2 active: WASD and Space do nothing")
	_tap(viewport, KEY_RIGHT)
	check(cursor.shown and cursor.index == 0, "player 2: an arrow shows the cursor on tile 0")
	_tap(viewport, KEY_RIGHT)
	check(cursor.index == 1, "player 2: Right moves one tile")
	_tap(viewport, KEY_DOWN)
	check(cursor.index == 8, "player 2: Down moves one row")
	_tap(viewport, KEY_UP)
	_tap(viewport, KEY_LEFT)
	check(cursor.index == 0, "player 2: Up and Left move back")
	_tap(viewport, KEY_LEFT)
	var count: int = open_basket.size()
	check(cursor.index == count - 1, "player 2: Left from the first tile wraps to the last")
	var last: String = open_basket[count - 1]
	_tap(viewport, KEY_ENTER)
	check(map.spelling.placed == [last, ""] and map.picking.basket.size() == count - 1, "player 2: Enter places the highlighted letter")
	check(cursor.index == count - 2, "the cursor clamps to the new last tile (%d)" % cursor.index)
	_tap(viewport, KEY_SPACE)
	_tap(viewport, KEY_D)
	check(map.spelling.placed == [last, ""] and cursor.index == count - 2, "player 2 active: Space and D still do nothing")
	# A full block takes no more.
	map.spelling.placed[1] = last
	var size_full: int = map.picking.basket.size()
	_tap(viewport, KEY_ENTER)
	check(map.picking.basket.size() == size_full and map.spelling.placed == [last, last], "Enter with every slot full does nothing")
	map.spelling.placed[1] = ""
	# Esc closes, the letter returns, the cursor stays on the basket.
	viewport.push_input(_key_event(KEY_ESCAPE))
	check(not hud.is_open() and not get_tree().paused and map.picking.basket.size() == count and cursor.index == count - 2, "Esc closes the view, the letter is back and the cursor is valid")
	cursor.index = 99
	check(map.open_spelling("gosari") and not cursor.shown, "reopening hides the cursor until the next key")
	hud.close()
	check(cursor.index == count - 1, "closing re-clamps the cursor to the basket (%d)" % cursor.index)
	cursor.set_active_player(1)

	# Mixing the mouse in: clicking a tile and dragging both hide the highlight.
	check(map.open_spelling("gobi"), "고비 opens")
	await _settle_layout()
	_tap(viewport, KEY_D)
	check(cursor.shown, "(setup) the cursor is shown")
	var click_at := _tile_center(map, "ㄱ")
	viewport.push_input(_click_event(click_at))
	viewport.push_input(_release_event(click_at))
	check(not cursor.shown and not map.basket_hud.highlight_visible(), "clicking a tile hides the highlight")
	_tap(viewport, KEY_D)
	check(cursor.shown, "(setup) shown again")
	await _drag(viewport, _tile_center(map, "ㄱ"), _slot_center(map, 0, 0))
	check(map.spelling.placed == ["ㄱ", ""] and not cursor.shown, "a mouse drag still places the letter, and hides the highlight")
	await _settle_layout()
	_tap(viewport, KEY_D)
	check(cursor.shown and cursor.index == 0 and map.spelling.placed == ["ㄱ", ""], "after the mouse the next key shows the cursor on tile 0 and places nothing")
	check(_spell_by_keys(map, viewport, ["ㅗ"]) and map.spelling.solved("gobi") == ["고"], "keys finish the block the mouse started: 고")
	check(hud.is_open(), "고비 is still open for block 2")
	viewport.push_input(_key_event(KEY_ESCAPE))
	check(not hud.is_open(), "Esc closes it")

	# Placement uses the mouse drop's own path.
	var source := FileAccess.get_file_as_string("res://scenes/foraging/spelling_hud.gd")
	check(source.contains("drop(_spelling.current_block(), slot, {\"letter\": letter})"), "the keyboard placement calls the same drop() a mouse drop ends in")
	map.free()
	check(not get_tree().paused, "freeing the map never leaves the tree paused")
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_keyboard_scene")


# ---- Stuck countdown, music and monster ----

const StuckScript := preload("res://scenes/foraging/stuck.gd")
const CountdownScript := preload("res://scenes/foraging/countdown.gd")
const KillTimelineScript := preload("res://scenes/foraging/kill_timeline.gd")
const StuckMusicScript := preload("res://scenes/foraging/stuck_music.gd")


func _is_color(value) -> bool:
	if not (value is Array) or value.size() != 3:
		return false
	for part in value:
		if not (part is float or part is int) or float(part) < 0.0 or float(part) > 1.0:
			return false
	return true


func test_stuck_data() -> void:
	var stuck: Dictionary = _config()["stuck"]
	check(float(stuck["countdown_seconds"]) == 40.0, "the countdown is 40 seconds")
	for key in ["countdown_seconds", "lockout_seconds", "number_alpha", "number_margin", "vignette_strength", "vignette_growth"]:
		check(stuck.has(key) and float(stuck[key]) > 0.0, "stuck.%s is a positive number" % key)
	check(float(stuck["lockout_seconds"]) <= 2.0 and float(stuck["number_alpha"]) <= 1.0 and float(stuck["vignette_strength"]) <= 1.0, "the lockout is short, the alpha and vignette strength are at most 1")
	var music: Dictionary = _config()["stuck_music"]
	check(float(music["volume_db"]) < 0.0 and float(music["volume_db"]) >= -60.0, "the music volume is a quiet negative dB (%s)" % str(music["volume_db"]))
	for key in ["fade_seconds", "loop_seconds", "drone_level", "hit_hz", "hit_volume", "hit_interval_min", "hit_interval_max"]:
		check(music.has(key) and float(music[key]) > 0.0, "stuck_music.%s is a positive number" % key)
	check(music["drone_hz"] is Array and music["drone_hz"].size() == 2 and float(music["drone_hz"][0]) > 0.0 and float(music["drone_hz"][1]) > 0.0 and music["drone_hz"][0] != music["drone_hz"][1], "two different positive drone frequencies")
	check(float(music["hit_interval_min"]) < float(music["hit_interval_max"]) and float(music["hit_interval_max"]) < float(music["loop_seconds"]), "the hit gap range is ordered and fits in the loop")
	var monster: Dictionary = _config()["monster"]
	check(monster["id"] is String and monster["id"] != "" and monster["name"] is String and monster["name"] != "", "the monster has an id and a name")
	for key in ["body_color", "antler_color", "eye_color"]:
		check(_is_color(monster.get(key)), "monster.%s is an r, g, b colour" % key)
	for key in ["scale", "enter_margin", "arc_height", "standoff", "leap_seconds", "hit_gap_seconds", "aftermath_seconds", "burst_strength", "tint_seconds", "knock_distance", "knock_seconds", "knock_tilt_degrees"]:
		check(monster.has(key) and float(monster[key]) > 0.0, "monster.%s is a positive number" % key)
	check(float(monster["leap_seconds"]) <= 0.5 and float(monster["hit_gap_seconds"]) >= 0.2 and float(monster["hit_gap_seconds"]) <= 0.5, "it leaps in within about 0.3 s and hits again about 0.35 s later")
	check(float(monster["burst_strength"]) > 1.0, "its blood burst is bigger than the placeholder gore's")
	_section_done("test_stuck_data")


func test_stuck_logic() -> void:
	var sp = _new_spares()
	var all := _target_letters()
	var verdict: Dictionary = StuckScript.analyze(sp, {}, all)
	check(not verdict["stuck"] and verdict["plan"].size() == 6, "a fresh scene is not stuck (%s)" % verdict["reason"])
	var solved := _solved_words(["ma", "meoru"])
	verdict = StuckScript.analyze(sp, solved, sp.needed(solved))
	check(not verdict["stuck"], "with every letter the rest needs, a half-done scene is not stuck")
	verdict = StuckScript.analyze(sp, {}, _without(all, ["ㅂ"]))
	check(not verdict["stuck"] and verdict["plan"].size() == 6 and verdict["plan"].find("gobi") > 0, "one jamo gone from a fresh scene is not stuck: another word's credit spawns it (%s)" % verdict["reason"])
	var five := _solved_words(["ma", "meoru", "minari", "gosari", "simiro"])
	var only_gobi: Array = _without(sp.needed(five), ["ㅂ"])
	verdict = StuckScript.analyze(sp, five, only_gobi)
	check(verdict["stuck"] and verdict["reason"].contains("ㅂ"), "one needed jamo gone with nothing left to cover it is stuck, and the reason names it (%s)" % verdict["reason"])
	# Two jamo gone, but only one other word left to complete: its single credit covers one.
	var four := _solved_words(["ma", "meoru", "minari", "simiro"])
	verdict = StuckScript.analyze(sp, four, _without(sp.needed(four), ["ㅂ", "ㄱ"]))
	check(verdict["stuck"], "two jamo gone with one word left to earn a spare is stuck (%s)" % verdict["reason"])
	# A banked credit. One credit cannot pay for a failure's own two lost letters...
	var one = _banked(["ma"])
	verdict = StuckScript.analyze(one, five, only_gobi)
	check(verdict["stuck"], "one banked credit does not rescue it: a failure destroys two needed letters and the credit replaces one")
	# ...three can: fail ㄱ+ㅗ, and the three credits cover ㄱ, ㅗ and ㅂ.
	var three = _banked(["ma", "meoru", "minari"])
	verdict = StuckScript.analyze(three, five, only_gobi)
	check(not verdict["stuck"] and str(verdict["plan"]).contains("fail"), "three banked credits do (a deliberate failure is part of the plan: %s)" % verdict["reason"])
	check(StuckScript.analyze(three, five, only_gobi, "none")["stuck"], "but not by completions alone")
	# Two surplus letters in the pool let one banked credit pay for a failure.
	verdict = StuckScript.analyze(one, five, only_gobi + ["ㅏ", "ㅏ"])
	check(not verdict["stuck"] and str(verdict["plan"]).contains("fail ㅏ+ㅏ"), "one banked credit and two surplus letters is not stuck: fail the surplus, spawn ㅂ (%s)" % verdict["reason"])
	# The cap: with no credit allowed, a completion cannot cover a gap.
	verdict = StuckScript.analyze(_new_spares(0), {}, _without(all, ["ㅂ"]))
	check(verdict["stuck"], "with the cap reached no completion earns a credit, so one jamo gone is stuck")
	# Every word finished, or none unfinished.
	var done := _solved_words(_target_words().keys())
	for pool in [[], ["ㅂ"], all]:
		verdict = StuckScript.analyze(sp, done, pool)
		check(not verdict["stuck"] and verdict["reason"] == "no unfinished word", "a scene with every word finished is never stuck (pool %d letters)" % pool.size())
	# A partly judged word counts only its unjudged blocks.
	var half := _solved_words(["ma", "minari", "gosari", "gobi", "simiro"])
	half["meoru"] = 1
	verdict = StuckScript.analyze(sp, half, ["ㄹ", "ㅜ"])
	check(not verdict["stuck"], "a half-judged word needs only its remaining blocks' letters")
	verdict = StuckScript.analyze(sp, half, ["ㄹ"])
	check(verdict["stuck"], "and is stuck without them")
	# The search leaves the live Spares alone.
	var before := [sp.credits.size(), sp.spawned.size(), sp.decisions.size()]
	StuckScript.analyze(sp, {}, _without(all, ["ㅂ", "ㄱ"]))
	check([sp.credits.size(), sp.spawned.size(), sp.decisions.size()] == before, "analysing changes nothing in the live Spares")
	_section_done("test_stuck_logic")


## Every state reachable by completing words and failing syllables, from a fresh
## scene of these words, with the invariants and the verdicts compared.
func _explore_states(words: Array, cap: int) -> Dictionary:
	var kinds := []
	var slots := {}
	for word in words:
		kinds.append({"id": word[0], "name": word[1], "kind": "target"})
		slots[word[0]] = [0.0, 0.0]
	var sp0 = SparesScript.new({"cap": cap, "grow_seconds": 0.5, "slots": slots}, {"kinds": kinds})
	var pool0: Array = sp0.needed({})
	var frontier := [{"spares": sp0, "solved": {}, "pool": pool0}]
	var seen := {StuckScript.state_key(sp0, {}, pool0): true}
	var report := {"states": 0, "stuck": 0, "mismatches": [], "invariant_breaks": 0, "inconclusive": 0}
	while not frontier.is_empty():
		var state: Dictionary = frontier.pop_back()
		report["states"] += 1
		var sp = state["spares"]
		var pool: Array = state["pool"]
		# The invariants: no jamo in the pool beyond what is needed; a credit means no shortage.
		var counts := {}
		for jamo in sp.needed(state["solved"]):
			counts[jamo] = int(counts.get(jamo, 0)) + 1
		for jamo in pool:
			counts[jamo] = int(counts.get(jamo, 0)) - 1
		for jamo in counts:
			if int(counts[jamo]) < 0:
				report["invariant_breaks"] += 1
		if not sp.credits.is_empty() and sp.choose(state["solved"], pool)["letter"] != "":
			report["invariant_breaks"] += 1
		var verdicts := {}
		for mode in ["none", "useful", "all"]:
			verdicts[mode] = StuckScript.analyze(sp, state["solved"], pool, mode)
			if str(verdicts[mode]["reason"]).begins_with("search budget"):
				report["inconclusive"] += 1
		if verdicts["none"]["stuck"] != verdicts["useful"]["stuck"] or verdicts["none"]["stuck"] != verdicts["all"]["stuck"]:
			report["mismatches"].append(str(pool))
		if verdicts["none"]["stuck"]:
			report["stuck"] += 1
		for move in StuckScript.moves(sp, state["solved"], pool, "all"):
			var key := StuckScript.state_key(move["spares"], move["solved"], move["pool"])
			if not seen.has(key):
				seen[key] = true
				frontier.append(move)
	return report


func test_stuck_brute_force() -> void:
	var cases := [
		[[["a", "마"], ["b", "머"]], 6],
		[[["a", "마"], ["b", "머"]], 1],
		[[["a", "마"], ["b", "미"], ["c", "머"]], 6],
		[[["a", "마"], ["b", "미"], ["c", "머"]], 2],
		[[["a", "마"], ["b", "미나"]], 6],
	]
	var total := 0
	var total_stuck := 0
	for case in cases:
		var report := _explore_states(case[0], case[1])
		total += report["states"]
		total_stuck += report["stuck"]
		check(report["mismatches"].is_empty(), "failing on purpose never changes the verdict in a reachable state (words %s, cap %d: %d states, %d stuck, first mismatch %s)" % [str(case[0].map(func(w): return w[1])), case[1], report["states"], report["stuck"], str(report["mismatches"].slice(0, 1))])
		check(report["invariant_breaks"] == 0, "no reachable state holds a surplus jamo or a credit beside a shortage (%d breaks)" % report["invariant_breaks"])
		check(report["inconclusive"] == 0, "no search ran out of budget")
	print("  brute force: %d reachable states over %d cases, %d stuck, no verdict changed by failing on purpose" % [total, cases.size(), total_stuck])
	check(total > 100 and total_stuck > 0, "the brute force covered %d states, %d of them stuck" % [total, total_stuck])
	# The assumption is false outside the reachable states: three credits, one jamo short.
	var sp = _banked(["ma", "meoru", "minari"])
	var five := _solved_words(["ma", "meoru", "minari", "gosari", "simiro"])
	var pool: Array = _without(sp.needed(five), ["ㅂ"])
	check(StuckScript.analyze(sp, five, pool, "none")["stuck"] and not StuckScript.analyze(sp, five, pool, "useful")["stuck"], "counterexample: a failure helps with three banked credits and one jamo short")
	check(not sp.credits.is_empty() and sp.choose(five, pool)["letter"] != "", "and that state has a credit beside a shortage, which the game never reaches")
	_section_done("test_stuck_brute_force")


func test_countdown_logic() -> void:
	var config: Dictionary = _config()["stuck"]
	var clock = CountdownScript.new(config)
	check(not clock.running and clock.shown_seconds() == 0 and clock.fraction() == 0.0, "a new clock is not running")
	check(clock.verdict(false) == "" and not clock.running, "a verdict that is not stuck starts nothing")
	check(clock.verdict(true, false) == "" and not clock.running and clock.starts == 0, "a stuck verdict while the scene is dying starts nothing")
	check(clock.verdict(true) == "started" and clock.running and clock.left == 40.0 and clock.starts == 1 and clock.shown_seconds() == 40, "the first stuck verdict starts 40 s")
	check(clock.verdict(true) == "" and clock.verdict(true) == "" and clock.starts == 1 and clock.left == 40.0, "more stuck verdicts in the same episode start nothing")
	check(not clock.tick(10.0) and clock.left == 30.0 and clock.shown_seconds() == 30, "ticking counts down")
	clock.paused = true
	clock.tick(5.0)
	check(clock.left == 30.0, "a paused clock stands still")
	clock.paused = false
	clock.tick(0.4)
	check(clock.shown_seconds() == 30 and is_equal_approx(clock.fraction(), 1.0 - 29.6 / 40.0), "the number shows whole seconds, rounded up")
	check(clock.verdict(false) == "cancelled" and not clock.running and clock.shown_seconds() == 0, "a verdict that is not stuck cancels it")
	check(clock.verdict(true) == "started" and clock.starts == 2 and clock.left == 40.0, "the next episode starts a new run")
	clock.tick(38.5)
	check(is_equal_approx(clock.left, 1.5) and not clock.is_locked(), "1.5 s left is not locked")
	clock.tick(0.5)
	check(clock.is_locked() and clock.verdict(false) == "" and clock.running, "in the last second a verdict that is not stuck can no longer cancel")
	check(clock.tick(1.0) and clock.expired and not clock.running, "it expires at 0, and says so")
	check(not clock.tick(1.0) and clock.verdict(true) == "" and clock.starts == 2, "once only: later ticks and verdicts start nothing")
	var other = CountdownScript.new(config)
	other.verdict(true)
	other.abandon()
	check(not other.running and other.verdict(true) == "" and other.starts == 1, "an abandoned run stays abandoned for the episode")
	var a: float = CountdownScript.vignette_alpha(0.0, 0.8, 1.5)
	var b: float = CountdownScript.vignette_alpha(0.5, 0.8, 1.5)
	var c: float = CountdownScript.vignette_alpha(1.0, 0.8, 1.5)
	check(a == 0.0 and b > a and c > b and is_equal_approx(c, 0.8) and b < 0.4, "the vignette starts clear, grows slowly and reaches its strength at 0")
	_section_done("test_countdown_logic")


func test_kill_timeline() -> void:
	var config: Dictionary = _config()["monster"]
	var line = KillTimelineScript.new(config)
	check(line.tick(1.0).is_empty() and not line.started, "nothing happens before it starts")
	check(line.start() and not line.start(), "it starts once")
	var events: Array = []
	var leap := float(config["leap_seconds"])
	var gap := float(config["hit_gap_seconds"])
	events.append_array(line.tick(leap - 0.01))
	check(events.is_empty() and line.leap_progress() < 1.0, "no hit before the leap has landed")
	events.append_array(line.tick(0.02))
	check(events == ["hit_0"] and is_equal_approx(line.leap_progress(), 1.0), "the first hit lands with the leap")
	events.append_array(line.tick(gap - 0.03))
	check(events == ["hit_0"] and line.gap_progress() < 1.0, "the second hit waits for the gap")
	events.append_array(line.tick(0.02))
	check(events == ["hit_0", "hit_1"], "the second hit follows, in order")
	events.append_array(line.tick(float(config["aftermath_seconds"]) + 0.1))
	check(events == ["hit_0", "hit_1", "done"] and line.is_done(), "then it is done")
	check(line.tick(5.0).is_empty(), "and nothing fires twice")
	var fast = KillTimelineScript.new(config)
	fast.start()
	check(fast.tick(10.0) == ["hit_0", "hit_1", "done"], "one long tick still fires every event once, in order")
	_section_done("test_kill_timeline")


func test_stuck_music() -> void:
	var config: Dictionary = _config()["stuck_music"]
	var stream: AudioStreamWAV = StuckMusicScript.make(config)
	var count: int = StuckMusicScript.sample_count(config)
	check(count == roundi(float(config["loop_seconds"]) * StuckMusicScript.MIX_RATE), "the loop has loop_seconds of samples (%d)" % count)
	check(stream.format == AudioStreamWAV.FORMAT_16_BITS and not stream.stereo and stream.mix_rate == StuckMusicScript.MIX_RATE and stream.data.size() == count * 2, "16-bit mono at the mix rate, one loop long")
	check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0 and stream.loop_end == count, "it loops forward over the whole length")
	var peak := 0
	for i in count:
		peak = maxi(peak, absi(stream.data.decode_s16(i * 2)))
	check(peak > 3000 and peak <= 32767 * 0.81, "it is not silent and does not clip (peak %d)" % peak)
	var seam := absi(stream.data.decode_s16(0) - stream.data.decode_s16((count - 1) * 2))
	check(seam < 1500, "the loop's end meets its start without a jump (%d of 32767)" % seam)
	var loop := float(config["loop_seconds"])
	for hz in config["drone_hz"]:
		var snapped: float = StuckMusicScript.snapped_hz(float(hz), loop)
		check(is_equal_approx(snapped * loop, roundf(snapped * loop)) and absf(snapped - float(hz)) < 1.0 / loop, "drone %.1f Hz is snapped to %.4f, a whole number of cycles per loop" % [float(hz), snapped])
	var times: Array[float] = StuckMusicScript.hit_times(config)
	var gaps_ok := true
	for i in range(1, times.size()):
		gaps_ok = gaps_ok and times[i] - times[i - 1] >= float(config["hit_interval_min"]) - 0.001 and times[i] - times[i - 1] <= float(config["hit_interval_max"]) + 0.001
	check(times.size() >= 2 and times.size() <= 8 and gaps_ok and times[times.size() - 1] < loop, "a few sparse hits (%d) with gaps inside the data's range" % times.size())
	var distinct := {}
	for i in range(1, times.size()):
		distinct[snappedf(times[i] - times[i - 1], 0.01)] = true
	check(distinct.size() >= 2 and times == StuckMusicScript.hit_times(config), "the gaps are irregular, and the same every run")
	check(StuckMusicScript.make(config).data == stream.data, "the stream is the same every time")
	_section_done("test_stuck_music")


## A scene with all six words found and, unless `pick_all` is false, every target
## letter in the basket. `units` sets the hearts the scene starts with.
func _stuck_map(units := {}, pick_all := true) -> Node3D:
	GameState.new_hike()
	for id in units:
		GameState.heart_units[id] = units[id]
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)  # the tests tick the clock, the kill and the beat themselves
	await get_tree().physics_frame
	await get_tree().physics_frame
	var by_kind := {}
	for entry in _placed():
		by_kind[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for id in _target_words():
		map.discovery.update([by_kind[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	if pick_all:
		for plant in map.plants:
			if plant.kind == "target":
				map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	return map


## Fails one syllable of the first unfinished word through the real Spelling and
## view, with the first two basket letters that cannot make the block. Returns
## the two letters destroyed, or [] if nothing could be done.
func _fail_block(map: Node3D) -> Array:
	var id := ""
	for word_id in map.spares.word_ids():
		if not map.spelling.is_done(word_id):
			id = word_id
			break
	if id == "" or not map.open_spelling(id):
		return []
	var basket: Array = map.picking.basket
	var block: int = map.spelling.current_block()
	for i in basket.size():
		for j in basket.size():
			if i != j and not map.spelling.judge(id, block, [basket[i], basket[j]]):
				var pair := [basket[i], basket[j]]
				map.spelling_hud.apply(map.spelling.place(pair[0], block, 0))
				map.spelling_hud.apply(map.spelling.place(pair[1], block, 1))
				map.spelling_hud.tick(1.0)  # the failure flash ends and the view closes
				return pair
	map.spelling_hud.close()
	return []


## Fails syllables until the scene is stuck (at most `limit` times). Returns how many it took, or -1.
func _fail_until_stuck(map: Node3D, limit := 8) -> int:
	for n in range(1, limit + 1):
		if _fail_block(map).is_empty():
			return -1
		if map.stuck_verdict["stuck"]:
			return n
	return -1


func _run(map: Node3D, seconds: float, delta := 1.0 / 60.0) -> void:
	var ticks := roundi(seconds / delta)
	for i in ticks:
		map.step(Vector2.ZERO, delta)


func test_stuck_playtest() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	print("  scripted playtest: run out of letters")
	print("    start: not stuck? ", map.stuck_log[map.stuck_log.size() - 1])
	check(not map.stuck_verdict["stuck"] and not map.countdown.running, "after picking everything the scene is not stuck")
	var steps := 0
	var stuck_at := -1
	while steps < 8 and stuck_at < 0:
		steps += 1
		var gone := _fail_block(map)
		var last: Dictionary = map.stuck_log[map.stuck_log.size() - 1]
		print("    failure %d destroys %s: %s, %s | hearts %d/%d, basket %d letters, credits %d, countdown %s" % [steps, str(gone), "STUCK" if last["stuck"] else "not stuck", last["reason"], GameState.heart_units["nestor"], GameState.heart_units["fernanda"], map.picking.basket.size(), map.spares.credits.size(), "running" if map.countdown.running else "off"])
		check(not gone.is_empty() and last["event"] == "spelling closed", "failure %d ends with a verdict logged after the view closed" % steps)
		if last["stuck"]:
			stuck_at = steps
	check(stuck_at > 0, "running out of letters ends stuck (after %d failures)" % stuck_at)
	check(GameState.is_alive("nestor") and GameState.is_alive("fernanda") and not map.restarting, "and both travelers are still alive")
	check(map.countdown.running and map.countdown.left == 40.0 and map.countdown.starts == 1, "the countdown started at 40 s, once")
	check(map.music_playing and map.music_starts == 1, "and the music with it")
	check(map.stuck_log.all(func(e): return e.has("event") and e.has("stuck") and e.has("reason") and e["reason"] != ""), "every evaluation was logged with its event, verdict and reason")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_stuck_playtest")


func test_stuck_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map({}, false)
	var screen: Vector2 = map.get_viewport().get_visible_rect().size
	var hud = map.stuck_hud
	# A fresh scene: nothing running; a pick is a logged event.
	check(map.stuck_log.size() == 1 and map.stuck_log[0]["event"] == "scene start" and not map.stuck_log[0]["stuck"], "the scene start is evaluated and logged: not stuck")
	check(not map.countdown.running and not map.music_playing and map.countdown.starts == 0, "a fresh scene has no countdown and no music")
	check(not hud._number.visible and not hud._vignette.visible, "and no number or vignette")
	var target_plant: Node3D = null
	for plant in map.plants:
		if plant.kind == "target":
			target_plant = plant
			break
	map.pick_plant(target_plant)
	check(map.stuck_log[map.stuck_log.size() - 1]["event"] == "pick" and not map.stuck_verdict["stuck"], "a pick is evaluated and logged: not stuck")
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	# Decoy letters never count.
	var decoy_letters := 0
	for plant in map.plants:
		if plant.kind != "target" and plant.letter != "":
			decoy_letters += 1
	check(decoy_letters > 0 and map._available_letters().size() == 28 and map._available_letters().size() == map.picking.basket.size(), "decoy letters are on the map (%d) but never in the pool: 28 target letters" % decoy_letters)

	# Fail syllables until stuck: the countdown starts at 40 s, once.
	var failures := _fail_until_stuck(map)
	check(failures > 0 and map.stuck_verdict["stuck"], "failing syllables ends stuck (after %d)" % failures)
	check(map.countdown.running and map.countdown.left == 40.0 and map.countdown.starts == 1 and not map.restarting, "the countdown starts at 40 s, once, and the scene is not restarting")
	check(map.music_playing and map.music_starts == 1 and map.music_stops == 0, "the music starts with it")
	check(map.audio_calls == 0 and map._music_player == null and map._music_stream == null, "headless: no call reaches the audio player and no stream is built")
	await _settle_layout()
	check(hud._number.visible and hud._number.text == "40" and hud._vignette.visible and hud._vignette.modulate.a == 0.0, "the number reads 40 and the vignette is still clear")
	map.evaluate_stuck("again")
	map.evaluate_stuck("and again")
	check(map.countdown.starts == 1 and map.music_starts == 1 and map.countdown.left == 40.0, "more stuck verdicts in the same episode start nothing new")

	# It counts down in step(), and the vignette grows.
	var stuck_cfg: Dictionary = _config()["stuck"]
	_run(map, 10.0)
	check(absf(map.countdown.left - 30.0) < 0.05 and hud._number.text == "30", "10 s later it reads 30 (%s)" % hud._number.text)
	var expected: float = CountdownScript.vignette_alpha(0.25, float(stuck_cfg["vignette_strength"]), float(stuck_cfg["vignette_growth"]))
	check(absf(hud._vignette.modulate.a - expected) < 0.01 and hud._vignette.modulate.a > 0.0, "the vignette has grown to %.3f" % hud._vignette.modulate.a)
	_run(map, 20.0, 0.05)
	var darker: float = hud._vignette.modulate.a
	check(absf(map.countdown.left - 10.0) < 0.1 and darker > expected, "at 10 s it is darker (%.3f)" % darker)

	# HUD layout at 1280x720.
	var number: Rect2 = hud.number_rect()
	check(Rect2(Vector2.ZERO, screen).encloses(number), "the number is inside the viewport (%s)" % str(number))
	check(absf(number.get_center().x - screen.x / 2.0) < 2.0 and number.position.y < 40.0, "it sits at the top centre")
	check(number.size.y >= 24.0 and hud._number.get_theme_font_size("font_size") >= 28 and hud._number.get_theme_color("font_color").a < 0.5, "it is large enough to read and faint")
	map.discovery_hud.refresh()
	await _settle_layout()
	var rivals := {
		"the heart readout": map.hearts_hud.panel_rect(),
		"the discovery list": map.discovery_hud.get_child(0).get_global_rect(),
		"the basket": map.basket_hud._panel.get_global_rect(),
	}
	for label in rivals:
		check(not number.intersects(rivals[label]), "the number does not overlap %s" % label)
	check(hud.vignette_rect() == Rect2(Vector2.ZERO, screen), "the vignette covers exactly the viewport")
	check(map.open_spelling("ma"), "the spelling view opens while the countdown runs")
	await _settle_layout()
	check(map.spelling_hud._panel.get_global_rect().intersects(number), "(the spelling view does cover the number's spot)")
	check(map.countdown.running and not hud._number.visible and hud._vignette.visible, "so the number hides while the view is open, and the vignette stays")
	# It stands still while the view is open, and the verdict is re-evaluated on close.
	var left_open: float = map.countdown.left
	var log_size: int = map.stuck_log.size()
	map.step(Vector2.ZERO, 1.0)
	map.step(Vector2.ZERO, 1.0)
	check(map.countdown.paused and map.countdown.left == left_open, "the clock stands still while the spelling view is open")
	map.spelling_hud.close()
	check(hud._number.visible, "the number is back once the view closes")
	check(map.stuck_log.size() == log_size + 1 and map.stuck_log[map.stuck_log.size() - 1]["event"] == "spelling closed", "closing the view re-evaluates the verdict")
	map.step(Vector2.ZERO, 1.0)
	check(not map.countdown.paused and is_equal_approx(map.countdown.left, left_open - 1.0), "and the clock runs again")

	# Mouse filters, and a real click through the vignette.
	check(hud._vignette.mouse_filter == Control.MOUSE_FILTER_IGNORE and hud._number.mouse_filter == Control.MOUSE_FILTER_IGNORE, "neither the number nor the vignette takes the mouse")
	check(hud is CanvasLayer and hud.layer < map.hearts_hud.layer and hud.layer < map.basket_hud.layer and hud.layer < map.spelling_hud.layer, "the layer sits under the other HUDs")
	map.picking.basket.clear()  # (the clicked plant must be a plant with a letter: decoys qualify)
	var decoy: Node3D = null
	for plant in map.plants:
		if plant.kind != "target" and plant.letter != "":
			decoy = plant
			break
	map.player.global_position = _ground_point(map, decoy.global_position.x, decoy.global_position.z + 2.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var middle := Rect2(300.0, 150.0, 680.0, 400.0)
	var clickable := _visible_plant(map, func(p): return p.kind != "target" and middle.has_point(map.camera.unproject_position(p.global_position + Vector3(0, 0.5, 0))))
	check(not clickable.is_empty(), "a plant is on screen under the vignette")
	if not clickable.is_empty():
		var sp: Vector2 = clickable["screen"]
		map.get_viewport().push_input(_click_event(sp))
		check(map.picking.walk_target >= 0, "a real click on it reaches the map and starts a walk")
		map.get_viewport().push_input(_release_event(sp))
		map.picking.cancel_walk()

	# A verdict that is not stuck cancels it, and the next stuck verdict starts a new run.
	var kept: Array = map.picking.basket.duplicate()
	var solved := {}
	for id in map.spares.word_ids():
		solved[id] = map.spelling.solved(id).size()
	map.picking.basket.append_array(map.spares.needed(solved))
	map.evaluate_stuck("letters found")
	check(not map.stuck_verdict["stuck"] and not map.countdown.running and not map.music_playing and map.music_stops == 1, "letters back: the countdown is cancelled and the music stops")
	check(not hud._number.visible and not hud._vignette.visible, "the number and vignette go")
	map.picking.basket.clear()
	map.picking.basket.append_array(kept)
	map.evaluate_stuck("letters lost again")
	check(map.countdown.running and map.countdown.left == 40.0 and map.countdown.starts == 2 and map.music_starts == 2, "stuck again: a new episode, a new run at 40 s")

	# Nothing starts while a traveler is dead.
	map.free()
	get_tree().paused = false
	map = await _stuck_map()
	GameState.damage_units("nestor", 99, "test")
	map.picking.basket.clear()
	var verdict: Dictionary = map.evaluate_stuck("test")
	check(verdict["stuck"] and not map.countdown.running and map.countdown.starts == 0 and not map.music_playing, "stuck with a traveler dead: no countdown, no music")
	map.free()
	# Nothing starts while the scene is restarting, and a run is abandoned when the beat begins.
	map = await _stuck_map()
	map.begin_death_beat()
	map.picking.basket.clear()
	map.evaluate_stuck("test")
	check(map.stuck_verdict["stuck"] and not map.countdown.running and map.countdown.starts == 0, "stuck while restarting: no countdown")
	map.free()
	map = await _stuck_map()
	check(_fail_until_stuck(map) > 0 and map.countdown.running and map.music_playing, "(a second scene is stuck with a countdown running)")
	map.begin_death_beat()
	check(not map.countdown.running and not map.music_playing and map.music_stops == 1 and not map.stuck_hud._number.visible and not map.stuck_hud._vignette.visible, "a death beat abandons the countdown, the music, the number and the vignette")
	_run(map, 3.0)
	check(map.kill == null and map.deer == null, "and no monster comes")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_stuck_scene")


func test_stuck_monster() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var original_scene := get_tree().current_scene
	var deaths: Array = []
	var on_death := func(dead: String, survivor: String, injury: String) -> void: deaths.append([dead, survivor, injury])
	var gore: Dictionary = _config()["gore_placeholder"]
	var monster: Dictionary = _config()["monster"]
	var map: Node3D = await _stuck_map({"nestor": 9, "fernanda": 7})
	remove_child(map)  # the real reload path runs for the current scene
	get_tree().root.add_child(map)
	get_tree().current_scene = map
	await get_tree().physics_frame
	var beats := []
	var restarts := []
	map.death_beat_started.connect(func(): beats.append(true))
	map.restarted.connect(func(): restarts.append(true))
	check(_fail_until_stuck(map) > 0 and map.countdown.running, "the scene is stuck with the countdown running")
	var snapshot_n := 9
	var snapshot_f := 7
	GameState.travelers_died.connect(on_death)
	# Count down to the last seconds in steps.
	_run(map, 30.0, 0.05)
	check(absf(map.countdown.left - 10.0) < 0.1 and not map.restarting, "at 10 s left the scene still plays")
	_run(map, 8.5, 0.05)
	check(absf(map.countdown.left - 1.5) < 0.1 and not map.restarting and not map.countdown.is_locked(), "at 1.5 s left it is not locked yet")
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	var hover_probe := Vector2(640.0, 360.0)
	var before_x: float = map.player.global_position.x
	var partner_x: float = map.partner.global_position.x
	_run(map, 0.55, 0.05)
	check(map.countdown.is_locked() and map.restarting and map.music_playing and map.kill == null, "inside the last second: locked, restarting set, music still on, no monster yet (%.2f s left)" % map.countdown.left)
	# Inputs are rejected in the last second.
	check(not map.picks_allowed() and not map.pick_nearest() and not map.click(hover_probe) and not map.open_spelling("ma") and not map.spelling.is_open(), "Space, a click and the spelling view are rejected")
	map.step(Vector2(1.0, 0.0), 0.2)
	check(is_equal_approx(map.player.global_position.x, before_x) and is_equal_approx(map.partner.global_position.x, partner_x), "walking is rejected: neither traveler moves")
	map.update_hover(hover_probe, 0.0)
	check(not map._tooltip.visible and map._tip_plant == null, "hover shows no name")
	var basket_before: int = map.picking.basket.size()
	map.picking.basket.append("ㅂ")
	map.evaluate_stuck("late letters")
	map.picking.basket.erase("ㅂ")
	check(map.countdown.running or map.kill != null, "a verdict that is not stuck cannot cancel it any more")
	check(map.picking.basket.size() == basket_before, "(the probe letter is removed again)")

	# The countdown reaches 0: the deer, the hits, the death beat, once each.
	var tinted := Color(gore["tint_color"][0], gore["tint_color"][1], gore["tint_color"][2])
	var left: float = map.countdown.left
	map.step(Vector2.ZERO, left + 0.001)
	check(map.kill != null and map.kill.started and map.deer is Node3D and map.countdown.expired and not map.countdown.running, "at 0 the monster sequence starts")
	check(not map.music_playing and map.music_stops == map.music_starts, "the music stops at the monster's arrival")
	check(not map.stuck_hud._number.visible and not map.stuck_hud._vignette.visible, "the number and vignette go")
	var order: Array[String] = map.kill_order
	check(order.size() == 2 and map.travelers[order[0]].global_position.x <= map.travelers[order[1]].global_position.x, "the deer takes the leftmost traveler first (%s, then %s)" % [order[0], order[1]])
	var edge: float = map.camera.global_position.x - map.camera_half_width()
	check(map.deer.global_position.x < edge, "it starts just off the left edge of the screen (%.1f < %.1f)" % [map.deer.global_position.x, edge])
	check(GameState.is_alive(order[0]) and GameState.is_alive(order[1]) and deaths.is_empty(), "nobody is hit yet")
	var first_before: Vector3 = map.travelers[order[0]].global_position
	# Step to just before and just after the first hit.
	_run(map, float(monster["leap_seconds"]) / 2.0, 0.01)
	var mid: float = map.deer.global_position.y
	check(map.deer.global_position.x > edge - 3.5 and mid > map.terrain.height_at(map.deer.global_position.x) + 0.1, "mid-leap the deer is in the air and coming in")
	_run(map, float(monster["leap_seconds"]) / 2.0 + 0.02, 0.01)
	check(not GameState.is_alive(order[0]) and GameState.is_alive(order[1]) and deaths.size() == 1 and deaths[0][0] == order[0] and deaths[0][2] == "monster", "the first hit kills the first traveler")
	check(map.deer.global_position.distance_to(first_before) <= float(monster["standoff"]) + 0.5, "the deer stands beside it")
	var big := roundi(40.0 * float(monster["burst_strength"]))
	var blood: Array = map.get_children().filter(func(n): return n is CPUParticles3D and n.amount == big)
	check(blood.size() == 1 and big > 40, "with a blood burst bigger than the placeholder's (%d droplets instead of 40)" % big)
	check(map.travelers[order[0]].body_color().is_equal_approx(tinted) or map.travelers[order[0]].body_color().r > 0.5, "and a red tint flash")
	_run(map, float(monster["hit_gap_seconds"]), 0.01)
	check(not GameState.is_alive(order[1]) and deaths.size() == 2 and deaths[1][0] == order[1], "about 0.35 s later the second traveler is down, in order")
	blood = map.get_children().filter(func(n): return n is CPUParticles3D and n.amount == big)
	check(blood.size() == 2, "with a second burst")
	check(beats.is_empty() and not map.is_death_beat_playing(), "the death beat has not begun while the deer is still there")
	await get_tree().create_timer(0.6).timeout
	check(absf(map.travelers[order[0]].rotation.z) > 1.0 and map.travelers[order[0]].global_position.distance_to(first_before) > 2.0, "the first traveler was thrown away and knocked flat")
	var lying: Vector3 = map.travelers[order[0]].global_position
	check(absf(lying.y - (map.terrain.height_at(lying.x) + 0.35)) < 0.02, "and it lies on the ground, not in it (feet %.2f, ground %.2f)" % [lying.y, map.terrain.height_at(lying.x)])
	_run(map, float(monster["aftermath_seconds"]) + 0.3, 0.01)
	check(beats.size() == 1 and map.is_death_beat_playing() and map.restarting, "then the existing death beat starts, once")
	_run(map, 3.0, 0.05)
	check(beats.size() == 1 and deaths.size() == 2 and map.get_children().filter(func(n): return n is CPUParticles3D and n.amount == big).size() <= 2, "and nothing repeats")
	check(map.music_starts == 1 and map.music_stops == 1 and map.audio_calls == 0, "the music started once and stopped once, with no audio call headless")
	check(map.deer.get_child_count() >= 12, "the deer is built from parts (%d)" % map.deer.get_child_count())
	var dim: ColorRect = map._dim
	check(dim != null and dim.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the dim layer is the existing one")
	# The restart: hearts back to the snapshot, the scene fresh.
	map.tick_beat(float(gore["death_beat"]) / 2.0)
	check(restarts.is_empty(), "the scene has not restarted mid-beat")
	map.tick_beat(float(gore["death_beat"]))
	check(restarts.size() == 1 and not map.countdown.running and not map.music_playing, "the scene restarts when the beat ends, with the countdown and music off")
	check(GameState.heart_units["nestor"] == snapshot_n and GameState.heart_units["fernanda"] == snapshot_f and GameState.is_alive("nestor"), "hearts are exactly the scene-start snapshot")
	GameState.travelers_died.disconnect(on_death)
	for i in 4:
		await get_tree().process_frame
	var fresh: Node = get_tree().current_scene
	check(fresh != map and not is_instance_valid(map), "the scene was reloaded")
	if fresh != map and is_instance_valid(fresh) and fresh.has_method("picks_allowed"):
		check(fresh.picking.basket.is_empty() and fresh.discovery.entries.is_empty() and fresh.spelling.solved("ma").is_empty() and fresh.spares.credits.is_empty() and fresh.spare_plants.is_empty(), "the new scene has an empty basket, list, spelling progress, credits and spares")
		check(not fresh.countdown.running and fresh.countdown.starts == 0 and not fresh.countdown.expired and fresh.kill == null and fresh.deer == null and not fresh.music_playing and not fresh.stuck_hud._number.visible and not fresh.stuck_hud._vignette.visible, "and no countdown, monster, music, number or vignette")
		check(not fresh.restarting and fresh.picks_allowed() and not fresh.stuck_verdict["stuck"], "play is allowed again, and it is not stuck")
		fresh.set_process(false)
		fresh.free()
	get_tree().current_scene = original_scene
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_stuck_monster")


func test_stuck_real_events() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	var viewport := map.get_viewport()
	await _settle_layout()
	var failures := 0
	while failures < 8 and not map.stuck_verdict["stuck"]:
		var id := ""
		for word_id in map.spares.word_ids():
			if not map.spelling.is_done(word_id):
				id = word_id
				break
		var row: Control = map.discovery_hud._rows[id]
		viewport.push_input(_click_event(row.get_global_rect().get_center()))
		viewport.push_input(_release_event(row.get_global_rect().get_center()))
		check(map.spelling_hud.is_open() and map.spelling.open_id == id, "failure %d: a real click on the %s entry opens the view" % [failures + 1, id])
		await _settle_layout()
		var basket: Array = map.picking.basket
		var block: int = map.spelling.current_block()
		var pair := []
		for i in basket.size():
			for j in basket.size():
				if pair.is_empty() and i != j and not map.spelling.judge(id, block, [basket[i], basket[j]]):
					pair = [basket[i], basket[j]]
		await _drag(viewport, _tile_center(map, pair[0]), _slot_center(map, block, 0))
		await _settle_layout()
		await _drag(viewport, _tile_center(map, pair[1]), _slot_center(map, block, 1))
		map.spelling_hud.tick(1.0)
		failures += 1
		var last: Dictionary = map.stuck_log[map.stuck_log.size() - 1]
		print("    real mouse failure %d (%s + %s): %s, %s" % [failures, pair[0], pair[1], "STUCK" if last["stuck"] else "not stuck", last["reason"]])
	check(map.stuck_verdict["stuck"] and map.countdown.running and map.countdown.starts == 1 and map.music_playing, "real clicks and drags failed %d syllables until the scene was stuck, and the countdown is running" % failures)
	check(not map.spelling_hud.is_open() and not get_tree().paused, "the view is closed and the tree is running")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_stuck_real_events")


# ---- Pause menu ----

const PauseMenuScript := preload("res://scenes/foraging/pause_menu.gd")


func test_pause_menu_data() -> void:
	var block: Dictionary = _config().get("pause_menu", {})
	check(not block.is_empty(), "hallasan.json has a pause_menu block")
	for key in ["panel_size", "button_size"]:
		var size = block.get(key)
		check(size is Array and size.size() == 2 and float(size[0]) > 0.0 and float(size[1]) > 0.0, "pause_menu.%s is two positive numbers" % key)
	check(float(block.get("button_gap", 0.0)) > 0.0, "pause_menu.button_gap is a positive number")
	check(float(block.get("dim_alpha", 0.0)) > 0.0 and float(block.get("dim_alpha", 1.0)) <= 0.6, "the dim is a light positive alpha (%s)" % str(block.get("dim_alpha")))
	for key in ["panel_color", "button_color", "outline_color", "text_color"]:
		check(_is_color(block.get(key)), "pause_menu.%s is an r, g, b colour" % key)
	for key in ["title", "resume_text", "restart_text", "confirm_text", "yes_text", "no_text"]:
		check(block.get(key) is String and block[key] != "", "pause_menu.%s is a non-empty string" % key)
	check(block["title"].contains("Paused") and block["resume_text"] == "Resume" and block["restart_text"] == "Restart scene", "the title and the two buttons are named as briefed")
	check(block["confirm_text"] == "Restart? Progress in this scene is lost." and block["yes_text"] == "Yes" and block["no_text"] == "No", "the confirmation reads as briefed")
	var panel := Vector2(float(block["panel_size"][0]), float(block["panel_size"][1]))
	var button := Vector2(float(block["button_size"][0]), float(block["button_size"][1]))
	check(panel.x <= 1280.0 and panel.y <= 720.0, "the panel fits in 1280x720")
	check(button.x + 40.0 <= panel.x and 2.0 * button.y + float(block["button_gap"]) + 40.0 < panel.y, "both buttons fit inside the panel with room for the title")
	_section_done("test_pause_menu_data")


func test_pause_menu_logic() -> void:
	var menu = PauseMenuScript.new()
	check(not menu.is_open and not menu.confirming and menu.restart_requests == 0, "a new menu is closed")
	check(menu.activate() == "" and menu.escape(false) == "" and not menu.close(), "closed: pressing, Esc (not allowed) and closing do nothing")
	menu.move(1)
	menu.focus_on(1)
	check(menu.focus == 0, "closed: the focus does not move")
	check(not menu.open(false) and not menu.is_open, "it does not open when the map says no")
	check(menu.open(true) and menu.is_open and menu.focus == PauseMenuScript.RESUME and not menu.confirming, "it opens from closed, on Resume")
	check(not menu.open(true), "opening an open menu does nothing")
	check(menu.close() and not menu.is_open, "close() closes it")
	check(menu.escape(true) == "open" and menu.is_open, "Esc opens it when allowed")
	check(menu.escape(false) == "resume" and not menu.is_open, "Esc closes it, allowed or not")
	menu.open(true)
	check(menu.activate() == "resume" and not menu.is_open, "Resume closes it")
	menu.open(true)
	menu.move(1)
	check(menu.focus == 1, "down moves to Restart scene")
	menu.move(1)
	check(menu.focus == 0, "down from the last wraps to the first")
	menu.move(-1)
	check(menu.focus == 1, "up from the first wraps to the last")
	menu.move(-1)
	menu.move(-1)
	check(menu.focus == 1, "two ups wrap and come back")
	menu.focus_on(0)
	menu.focus_on(7)
	menu.focus_on(-1)
	check(menu.focus == 0, "focus_on ignores a choice that does not exist")
	menu.focus_on(1)
	check(menu.activate() == "ask" and menu.is_open and menu.confirming and menu.restart_requests == 0, "Restart scene asks first: nothing is requested yet")
	check(menu.focus == PauseMenuScript.NO, "the confirmation starts on No")
	check(menu.activate() == "back" and menu.is_open and not menu.confirming and menu.focus == PauseMenuScript.RESTART and menu.restart_requests == 0, "No returns to the menu, on Restart scene")
	menu.activate()
	check(menu.escape(false) == "back" and menu.is_open and not menu.confirming and menu.restart_requests == 0, "Esc on the confirmation is No")
	menu.activate()
	menu.move(1)
	check(menu.confirming and menu.focus == PauseMenuScript.YES, "the confirmation's focus moves too")
	check(menu.activate() == "restart" and menu.restart_requests == 1 and not menu.is_open, "Yes requests one restart and closes the menu")
	check(menu.activate() == "" and menu.escape(true) == "" and not menu.open(true) and menu.restart_requests == 1, "after Yes nothing asks again: exactly one request")
	_section_done("test_pause_menu_logic")


## The first on-screen decoy plant clear of the HUD panels, with the player standing near x = 14.
func _menu_decoy(map: Node3D) -> Dictionary:
	map.player.global_position = _ground_point(map, 14.0, 0.0)
	map.update_camera(0.0, true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var rects := [map.hearts_hud.panel_rect(), map.discovery_hud.get_child(0).get_global_rect(), map.basket_hud._panel.get_global_rect()]
	return _visible_plant(map, func(p):
		var at: Vector2 = map.camera.unproject_position(p.global_position + Vector3(0, 0.5, 0))
		return p.kind != "target" and not rects.any(func(r): return r.has_point(at)))


func _fake_music(map: Node3D) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = StuckMusicScript.make(_config()["stuck_music"])
	map.add_child(player)
	player.play()
	map._music_player = player
	map._music_tween = map.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	map._music_tween.tween_property(player, "volume_db", -30.0, 4.0)
	return player


func test_pause_menu_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	var viewport := map.get_viewport()
	var hud = map.pause_hud
	var menu = map.pause_menu
	var config: Dictionary = _config()["pause_menu"]
	var screen: Vector2 = viewport.get_visible_rect().size
	await _settle_layout()

	# Closed: nothing is drawn, nothing is paused, and a click reaches the map.
	check(not menu.is_open and not hud.root_visible() and not hud._panel.is_visible_in_tree() and not get_tree().paused, "closed: the menu draws nothing and the tree runs")
	check(hud.layer == 15 and hud.process_mode == Node.PROCESS_MODE_ALWAYS, "its layer runs in always mode, over the hover name and under the death dim")
	var decoy: Dictionary = await _menu_decoy(map)
	check(not decoy.is_empty(), "a decoy plant is on screen outside the HUD panels")
	viewport.push_input(_click_event(decoy["screen"]))
	viewport.push_input(_release_event(decoy["screen"]))
	check(map.picking.walk_target == map.plants.find(decoy["plant"]), "closed: a real click on the plant reaches the map (the layer blocks nothing)")
	map.picking.cancel_walk()

	# Esc is shared with the spelling view: it takes the Esc when it is open, the map when it is closed.
	check(map.open_spelling("ma") and get_tree().paused, "(setup) the spelling view is open")
	_tap(viewport, KEY_ESCAPE)
	check(not map.spelling_hud.is_open() and not menu.is_open and not hud.root_visible() and not get_tree().paused, "Esc in the spelling view closes the view and does not open the menu")
	_tap(viewport, KEY_ESCAPE)
	check(menu.is_open and hud.root_visible() and get_tree().paused and not map.spelling_hud.is_open(), "Esc with the view closed opens the menu and pauses the tree")
	check(not map.open_spelling("ma") and not map.spelling.is_open() and not map.spelling_hud.is_open(), "the spelling view cannot open over the menu")
	_tap(viewport, KEY_ESCAPE)
	check(not menu.is_open and not hud.root_visible() and not get_tree().paused, "Esc on the open menu resumes it, and the same Esc does not open it again")
	map.open_spelling("ma")
	_tap(viewport, KEY_ESCAPE)
	await get_tree().process_frame
	check(not menu.is_open and not map.spelling_hud.is_open(), "one Esc event never does both: after a frame the view is closed and the menu is not open")

	# The countdown, the vignette and the music while the menu is open.
	var failures := _fail_until_stuck(map)
	check(failures > 0 and map.countdown.running and map.music_playing, "(setup) stuck: the countdown runs and the music is on")
	_run(map, 5.0)
	var player := _fake_music(map)
	var before := {"left": map.countdown.left, "alpha": map.stuck_hud._vignette.modulate.a, "number": map.stuck_hud._number.text, "starts": map.music_starts, "stops": map.music_stops, "volume": player.volume_db}
	check(absf(map.countdown.left - 35.0) < 0.05 and before["alpha"] > 0.0, "(setup) 5 s in: %.2f s left, the vignette is up (%.4f)" % [map.countdown.left, before["alpha"]])
	_tap(viewport, KEY_ESCAPE)
	await _settle_layout()
	check(menu.is_open and get_tree().paused and not map.can_process(), "opened during the countdown: the tree and the map are paused")
	check(map.countdown.paused and map.music_silenced and map.music_playing, "the countdown is held and the music is silenced, not stopped")
	check(player.stream_paused and not map._music_tween.is_running(), "the audio player is paused (position kept) and its fade is held")
	_run(map, 3.0)
	check(map.countdown.left == before["left"], "3 s of ticks while open do not move the clock (%.3f)" % map.countdown.left)
	check(map.stuck_hud._vignette.modulate.a == before["alpha"] and map.stuck_hud._number.text == before["number"], "the vignette and the number do not change")
	check(map.hearts_hud.panel_rect().size.x > 0.0 and map.stuck_hud._vignette.visible, "the vignette stays drawn under the dim")

	# The layout, centred and inside the viewport.
	var panel: Rect2 = hud.panel_rect()
	var size := Vector2(float(config["panel_size"][0]), float(config["panel_size"][1]))
	check(Rect2(Vector2.ZERO, screen).encloses(panel), "the panel is inside the 1280x720 viewport (%s)" % str(panel))
	check(panel.get_center().distance_to(screen / 2.0) < 1.5 and panel.size.is_equal_approx(size), "the panel is centred and as big as the data says (%s)" % str(panel))
	var r0: Rect2 = hud.button_rect(0)
	var r1: Rect2 = hud.button_rect(1)
	var button := Vector2(float(config["button_size"][0]), float(config["button_size"][1]))
	check(panel.encloses(r0) and panel.encloses(r1) and not r0.intersects(r1), "both buttons are inside the panel and do not overlap")
	check(r0.size.x >= button.x - 0.5 and r0.size.y >= button.y - 0.5 and r1.size.x >= button.x - 0.5 and r1.size.y >= button.y - 0.5, "each is at least the data's button size")
	check(hud._dim.get_global_rect() == Rect2(Vector2.ZERO, screen) and absf(hud._dim.color.a - float(config["dim_alpha"])) < 0.001, "the dim covers the screen at the data's alpha")
	check(hud._root.mouse_filter == Control.MOUSE_FILTER_STOP and hud._dim.mouse_filter == Control.MOUSE_FILTER_IGNORE, "open, the root swallows the clicks")
	check(hud.focused_style_on(0) and not hud.focused_style_on(1) and hud._buttons[0].text == "Resume" and hud._buttons[1].text == "Restart scene", "the focus is outlined on Resume; the buttons read Resume and Restart scene")

	# Everything behind the menu is locked.
	var basket_before: Array = map.picking.basket.duplicate()
	var player_x: float = map.player.global_position.x
	var partner_x: float = map.partner.global_position.x
	check(not map.picks_allowed() and not map.restarting, "picks are not allowed, and `restarting` is not what blocks them")
	map.player.global_position = _ground_point(map, decoy["plant"].global_position.x + 0.4, decoy["plant"].global_position.z + 0.2)
	player_x = map.player.global_position.x
	check(map.picking.nearest_pickable(Vector2(map.player.global_position.x, map.player.global_position.z)) >= 0, "(setup) a plant is in reach")
	check(not map.pick_nearest() and map.picking.basket == basket_before, "Space-picking is rejected with a plant in reach")
	check(not map.click(decoy["screen"]) and map.picking.walk_target == -1, "a click on a plant starts no walk")
	viewport.push_input(_click_event(decoy["screen"]))
	viewport.push_input(_release_event(decoy["screen"]))
	check(map.picking.walk_target == -1, "(real click) the root swallows it")
	map.step(Vector2(1.0, 0.0), 0.2)
	check(is_equal_approx(map.player.global_position.x, player_x) and is_equal_approx(map.partner.global_position.x, partner_x), "walking is rejected: neither traveler moves")
	map.update_hover(decoy["screen"], 0.1)
	check(map._tip_plant == null and not map._tooltip.visible, "hover shows no name")
	check(not map.open_spelling("minari"), "the spelling view cannot be opened by code")
	var row: Control = map.discovery_hud._rows["ma"]
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(not map.spelling_hud.is_open(), "(real click) a click on a discovery entry opens nothing")
	check(map.picking.basket == basket_before, "no letter left the basket")

	# Resume restores everything where it was.
	hud.choose(0)
	check(not menu.is_open and not hud.root_visible() and not get_tree().paused and not map.countdown.paused, "Resume: closed, unpaused, the clock released")
	check(not map.music_silenced and map.music_playing and not player.stream_paused and map._music_tween.is_running(), "the music is back on, its fade running again")
	check(map.countdown.left == before["left"] and map.stuck_hud._vignette.modulate.a == before["alpha"] and map.stuck_hud._number.text == before["number"], "the countdown value, the vignette and the number are exactly as before")
	check(map.music_starts == before["starts"] and map.music_stops == before["stops"] and map.countdown.starts == 1, "no music or countdown started or stopped in between")
	_run(map, 1.0)
	check(absf(map.countdown.left - (before["left"] - 1.0)) < 0.05, "and the clock runs on from there")
	map.update_camera(0.0, true)
	var seen_at: Vector2 = map.camera.unproject_position(decoy["plant"].global_position + Vector3(0, 0.5, 0))
	map.update_hover(seen_at, 0.1)
	check(map._tip_plant == decoy["plant"], "(control) hover shows names again")
	map.player.global_position = _ground_point(map, player_x + 1.0, map.player.global_position.z)
	var moved: float = map.player.global_position.x
	map.step(Vector2(1.0, 0.0), 0.2)
	check(map.player.global_position.x > moved, "(control) walking works again")
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(map.spelling_hud.is_open(), "(control) the same click on the entry opens the view")
	map.spelling_hud.close()
	map._stop_music()
	check(player.is_queued_for_deletion() or not is_instance_valid(player), "(cleanup) stopping the music frees the fake player")
	map.free()
	check(not get_tree().paused, "freeing the map never leaves the tree paused")
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_pause_menu_scene")


func test_pause_menu_ignored() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	var viewport := map.get_viewport()
	check(_fail_until_stuck(map) > 0 and map.countdown.running, "(setup) stuck, the countdown runs")
	_run(map, 39.2, 0.05)
	check(map.countdown.is_locked() and map.restarting and map.kill == null, "(setup) the last second: locked, restarting set (%.2f s left)" % map.countdown.left)
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused and not map.pause_hud.root_visible(), "Esc in the last second is ignored")
	check(not map.open_pause_menu(), "and so is a call to open it")
	_run(map, 1.0, 0.05)
	check(map.kill != null and map.deer != null and not map.is_death_beat_playing(), "(setup) the monster sequence is running")
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused, "Esc during the monster sequence is ignored")
	var guard := 0
	while not map.is_death_beat_playing() and guard < 100:
		_run(map, 0.1, 0.05)
		guard += 1
	check(map.is_death_beat_playing(), "(setup) the death beat is playing")
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused and not map.pause_hud.root_visible(), "Esc during the death beat is ignored")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_pause_menu_ignored")


func test_pause_menu_input() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map({}, false)
	var viewport := map.get_viewport()
	var menu = map.pause_menu
	var hud = map.pause_hud
	await _settle_layout()

	_tap(viewport, KEY_ESCAPE)
	await _settle_layout()
	check(menu.is_open and menu.focus == 0 and hud.focused_style_on(0), "Esc opens the menu with the focus on Resume")
	# Player 1: W/S move the highlight and wrap; Space presses.
	_tap(viewport, KEY_S)
	check(menu.focus == 1 and hud.focused_style_on(1) and not hud.focused_style_on(0), "P1: S moves the highlight to Restart scene")
	_tap(viewport, KEY_W)
	check(menu.focus == 0, "P1: W moves it back")
	_tap(viewport, KEY_W)
	check(menu.focus == 1, "P1: W from the first wraps to the last")
	_tap(viewport, KEY_S)
	check(menu.focus == 0, "P1: S from the last wraps to the first")
	# Player 2: Up/Down move, Enter and KP Enter press.
	_tap(viewport, KEY_DOWN)
	check(menu.focus == 1, "P2: Down moves the highlight")
	_tap(viewport, KEY_UP)
	_tap(viewport, KEY_UP)
	check(menu.focus == 1, "P2: Up twice wraps")
	_tap(viewport, KEY_DOWN)
	check(menu.focus == 0, "P2: Down wraps")
	_tap(viewport, KEY_SPACE)
	check(not menu.is_open and not get_tree().paused, "P1: Space on Resume resumes")
	_tap(viewport, KEY_ESCAPE)
	_tap(viewport, KEY_ENTER)
	check(not menu.is_open and not get_tree().paused, "P2: Enter on Resume resumes")
	_tap(viewport, KEY_ESCAPE)
	_tap(viewport, KEY_KP_ENTER, KEY_LOCATION_RIGHT)
	check(not menu.is_open, "P2: KP Enter on Resume resumes")
	# Restart needs a confirmation; both players can answer it.
	_tap(viewport, KEY_ESCAPE)
	_tap(viewport, KEY_S)
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(menu.is_open and menu.confirming and menu.focus == 1 and menu.restart_requests == 0, "P1: Space on Restart scene asks for confirmation, on No")
	check(hud._message.visible and not hud._title.visible and hud._buttons[0].text == "Yes" and hud._buttons[1].text == "No" and hud._message.text == "Restart? Progress in this scene is lost.", "the panel shows the question with Yes and No")
	check(hud.panel_rect().encloses(hud._message.get_global_rect()) and hud.panel_rect().encloses(hud.button_rect(0)) and hud.panel_rect().encloses(hud.button_rect(1)), "the question and both answers are inside the panel")
	_tap(viewport, KEY_ENTER)
	check(menu.is_open and not menu.confirming and menu.focus == 1 and menu.restart_requests == 0, "P2: Enter on No goes back to the menu")
	check(hud._title.visible and not hud._message.visible and hud._buttons[0].text == "Resume", "the menu is drawn again")
	_tap(viewport, KEY_SPACE)
	_tap(viewport, KEY_ESCAPE)
	check(menu.is_open and not menu.confirming, "Esc on the question is No")
	_tap(viewport, KEY_ESCAPE)
	check(not menu.is_open, "Esc then resumes")

	# No key reaches the map while open (the probe listens where the map does); a control after.
	_tap(viewport, KEY_ESCAPE)
	var probe := KeyProbe.new()
	probe.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(probe)
	var keys: Array = [KEY_W, KEY_S, KEY_A, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
	for key in keys:
		_tap(viewport, key)
	check(probe.seen == 0 and menu.is_open, "none of 8 movement keys reached the map while open (%d)" % probe.seen)
	for key in [KEY_S, KEY_SPACE, KEY_ENTER]:  # Restart scene, ask, back: the pick keys are taken as well
		_tap(viewport, key)
	_tap(viewport, KEY_KP_ENTER, KEY_LOCATION_RIGHT)
	check(probe.seen == 0 and menu.is_open and menu.confirming, "Space, Enter and KP Enter did not reach the map either (%d)" % probe.seen)
	_tap(viewport, KEY_ESCAPE)
	_tap(viewport, KEY_ESCAPE)
	check(probe.seen == 0 and not menu.is_open, "nor did the two Esc that answered No and closed it")
	_tap(viewport, KEY_D)
	check(probe.seen == 1, "(control) with the menu closed the same kind of key reaches the map (%d)" % probe.seen)
	probe.queue_free()

	# The mouse: both buttons, hover and the answers.
	_tap(viewport, KEY_ESCAPE)
	await _settle_layout()
	var motion := InputEventMouseMotion.new()
	var over: Vector2 = hud.button_rect(1).get_center()
	motion.position = over
	motion.global_position = over
	viewport.push_input(motion)
	await get_tree().process_frame
	check(menu.focus == 1 and hud.focused_style_on(1), "the mouse moving onto Restart scene moves the highlight there")
	viewport.push_input(_click_event(over))
	viewport.push_input(_release_event(over))
	await _settle_layout()
	check(menu.confirming and menu.is_open, "a real click on Restart scene asks for confirmation")
	var no_at: Vector2 = hud.button_rect(1).get_center()
	viewport.push_input(_click_event(no_at))
	viewport.push_input(_release_event(no_at))
	await _settle_layout()
	check(menu.is_open and not menu.confirming and menu.restart_requests == 0, "a real click on No returns to the menu")
	var resume_at: Vector2 = hud.button_rect(0).get_center()
	viewport.push_input(_click_event(resume_at))
	viewport.push_input(_release_event(resume_at))
	check(not menu.is_open and not get_tree().paused and not hud.root_visible(), "a real click on Resume resumes")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_pause_menu_input")


func test_pause_menu_restart() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var original_scene := get_tree().current_scene
	var map: Node3D = await _stuck_map({"nestor": 9, "fernanda": 7})
	remove_child(map)  # the real reload path runs for the current scene
	get_tree().root.add_child(map)
	get_tree().current_scene = map
	await get_tree().physics_frame
	var viewport := map.get_viewport()
	var beats := []
	var restarts := []
	map.death_beat_started.connect(func(): beats.append(true))
	map.restarted.connect(func(): restarts.append(true))
	check(_fail_until_stuck(map) > 0 and map.countdown.running and map.music_playing, "(setup) stuck with the countdown running and the music on")
	check(GameState.heart_units["nestor"] < 9 or GameState.heart_units["fernanda"] < 7, "(setup) the failures cost hearts")
	_run(map, 12.0, 0.05)
	await _settle_layout()
	_tap(viewport, KEY_ESCAPE)
	await _settle_layout()
	check(map.pause_menu.is_open and get_tree().paused, "(setup) the menu is open during the countdown")
	var hud = map.pause_hud
	var restart_at: Vector2 = hud.button_rect(1).get_center()
	viewport.push_input(_click_event(restart_at))
	viewport.push_input(_release_event(restart_at))
	await _settle_layout()
	check(map.pause_menu.confirming and restarts.is_empty(), "Restart scene asks first; nothing has restarted")
	var no_at: Vector2 = hud.button_rect(1).get_center()
	viewport.push_input(_click_event(no_at))
	viewport.push_input(_release_event(no_at))
	await _settle_layout()
	check(map.pause_menu.is_open and not map.pause_menu.confirming and restarts.is_empty() and map.countdown.running and map.countdown.paused, "No: back in the menu, still paused, the countdown untouched")
	viewport.push_input(_click_event(restart_at))
	viewport.push_input(_release_event(restart_at))
	await _settle_layout()
	var yes_at: Vector2 = hud.button_rect(0).get_center()
	viewport.push_input(_click_event(yes_at))
	viewport.push_input(_release_event(yes_at))
	check(restarts.size() == 1 and map.pause_menu.restart_requests == 1, "Yes restarts exactly once, through the existing path")
	check(beats.is_empty() and not map.is_death_beat_playing() and map._dim == null and map.kill == null and map.deer == null, "no death beat, no dim, no monster")
	check(GameState.heart_units["nestor"] == 9 and GameState.heart_units["fernanda"] == 7, "hearts are exactly the scene-start snapshot: no extra penalty")
	check(not map.countdown.running and not map.music_playing and not get_tree().paused, "the countdown and the music are cancelled and the tree is running")
	for i in 4:
		await get_tree().process_frame
	var fresh: Node = get_tree().current_scene
	check(fresh != map and not is_instance_valid(map), "the scene was reloaded")
	if fresh != map and is_instance_valid(fresh) and fresh.has_method("picks_allowed"):
		check(fresh.picking.basket.is_empty() and fresh.discovery.entries.is_empty() and fresh.spelling.solved("ma").is_empty() and fresh.spares.credits.is_empty() and fresh.spare_plants.is_empty(), "the new scene has an empty basket, list, spelling progress, credits and spares")
		check(not fresh.countdown.running and fresh.countdown.starts == 0 and not fresh.music_playing and fresh.kill == null and fresh.deer == null and fresh._dim == null and not fresh.stuck_hud._number.visible and not fresh.stuck_hud._vignette.visible, "and no countdown, music, monster, death beat, number or vignette")
		check(not fresh.pause_menu.is_open and not fresh.pause_hud.root_visible() and not fresh.restarting and fresh.picks_allowed(), "the menu is closed and play is allowed")
		check(GameState.heart_units["nestor"] == 9 and GameState.heart_units["fernanda"] == 7, "the new scene starts with the snapshot hearts")
		fresh.set_process(false)
		fresh.free()
	get_tree().current_scene = original_scene
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_pause_menu_restart")



# ---- Items and Fernanda's backpack ----

const InventoryScript := preload("res://scripts/inventory.gd")
const BackpackScript := preload("res://scenes/foraging/backpack.gd")
const BackpackHudScript := preload("res://scenes/foraging/backpack_hud.gd")
const KO_FONT_FILE := "NotoSansKR-VariableFont_wght.ttf"


func test_items_data() -> void:
	var file: Array = Content.load_json(Content.ITEMS_PATH).get("items", [])
	check(file.size() == 5 and Content.items.size() == 5, "items.json lists five items and all five loaded")
	check(Content.items.keys() == ["ssanghwatang", "gongjindan", "spelling_hint", "slow_time_charm", "ddeok"], "the ids load in file order")
	for id in Content.items:
		var item: Dictionary = Content.item(id)
		check(item["id"] == id and Content.ITEM_KINDS.has(item["kind"]), "%s has its id and a valid kind" % id)
		check(item["name_en"] is String and item["name_en"] != "" and item["description_en"] is String and item["description_en"] != "", "%s has an English name and description" % id)
		check(item["name_ko"] is String, "%s has a name_ko (possibly empty)" % id)
	check(Content.ITEM_KINDS == ["elixir", "charm", "hint", "note", "currency"], "the kinds are elixir, charm, hint, note and currency")
	var a: Dictionary = Content.item("ssanghwatang")
	check(a["kind"] == "elixir" and a["name_ko"] == "쌍화탕" and a["name_en"] == "Ssanghwatang" and a["description_en"] == "Herbal tonic. Restores half a heart." and a["heal_units"] == 1, "ssanghwatang is as briefed")
	var b: Dictionary = Content.item("gongjindan")
	check(b["kind"] == "elixir" and b["name_ko"] == "공진단" and b["name_en"] == "Gongjindan" and b["description_en"] == "Herbal pill. Restores one heart." and b["heal_units"] == 2, "gongjindan is as briefed")
	var c: Dictionary = Content.item("spelling_hint")
	check(c["kind"] == "hint" and c["name_ko"] == "" and c["name_en"] == "Spelling hint" and c["description_en"] == "Shows one correct letter for 2 seconds." and c["usable"] == false, "spelling_hint is as briefed")
	var d: Dictionary = Content.item("slow_time_charm")
	check(d["kind"] == "charm" and d["name_ko"] == "" and d["name_en"] == "Slow-time charm" and d["description_en"] == "Slows time." and d["usable"] == false, "slow_time_charm is as briefed")
	check(a["heal_units"] * 2 == b["heal_units"], "gongjindan heals twice what ssanghwatang does")
	check(b["heal_units"] == GameState.units_per_heart(), "gongjindan heals exactly one heart")
	check(Content.item("nope").is_empty() and not Content.has_item("nope") and Content.has_item("gongjindan"), "an unknown id has no definition")
	# The loader's rules, on made-up entries (nothing is added to Content).
	var known := {"x": {}}
	check(Content.item_problem({"id": "n", "kind": "note", "name_ko": "", "name_en": "Note", "description_en": "A note."}, known) == "", "a note item is valid")
	check(Content.item_problem({"id": "e", "kind": "elixir", "heal_units": 1}, known) == "", "an elixir with heal_units is valid")
	check(Content.item_problem({"id": "e", "kind": "elixir"}, known).contains("heal_units"), "an elixir without heal_units is rejected, and the reason says so")
	check(Content.item_problem({"id": "w", "kind": "weapon"}, known).contains("unknown kind 'weapon'"), "an unknown kind is rejected with a clear reason")
	check(Content.item_problem({"id": "x", "kind": "note"}, known).contains("twice"), "a repeated id is rejected")
	check(Content.item_problem({"kind": "note"}, known) != "" and Content.item_problem("text", known) != "", "an entry without an id, or not a dictionary, is rejected")
	_section_done("test_items_data")


func test_inventory_logic() -> void:
	var inv = InventoryScript.new()
	var fired := [0]
	inv.changed.connect(func(): fired[0] += 1)
	check(inv.is_empty() and inv.items() == [] and inv.count("ssanghwatang") == 0 and inv.snapshot() == {}, "a new inventory is empty")
	check(not inv.add("bogus") and inv.last_error == "Unknown item id 'bogus'", "an unknown id is rejected with a clear error (%s)" % inv.last_error)
	check(not inv.add("ssanghwatang", 0) and not inv.add("ssanghwatang", -2) and inv.last_error != "", "a count below 1 is rejected")
	check(inv.is_empty() and fired[0] == 0, "rejected adds change nothing and announce nothing")
	check(inv.add("ssanghwatang") and inv.last_error == "" and inv.count("ssanghwatang") == 1 and fired[0] == 1, "add puts one in and announces it")
	check(inv.add("gongjindan", 2) and inv.add("spelling_hint") and inv.add("ssanghwatang") and fired[0] == 4, "more adds, each announced")
	check(inv.items() == [{"id": "ssanghwatang", "count": 2}, {"id": "gongjindan", "count": 2}, {"id": "spelling_hint", "count": 1}], "items() is in the order first added, with counts")
	check(not inv.is_empty() and inv.count("gongjindan") == 2 and inv.count("slow_time_charm") == 0, "count() reads one item")
	var before: Dictionary = inv.snapshot()
	fired[0] = 0
	check(not inv.remove("gongjindan", 3) and inv.last_error.contains("only 2 held"), "removing more than held fails (%s)" % inv.last_error)
	check(not inv.remove("slow_time_charm") and not inv.remove("gongjindan", 0) and not inv.remove("gongjindan", -1), "removing what isn't held, or a count below 1, fails")
	check(inv.snapshot() == before and fired[0] == 0, "failed removals change nothing and announce nothing")
	check(inv.remove("gongjindan") and inv.count("gongjindan") == 1 and fired[0] == 1, "remove takes one out and announces it")
	check(inv.remove("ssanghwatang", 2) and inv.count("ssanghwatang") == 0 and fired[0] == 2, "removing them all works")
	check(inv.items() == [{"id": "gongjindan", "count": 1}, {"id": "spelling_hint", "count": 1}], "zero-count items are dropped from items()")
	inv.add("ssanghwatang")
	check(inv.items()[2]["id"] == "ssanghwatang", "an item added again after it was gone goes to the end")
	# Snapshot and restore.
	var snap: Dictionary = inv.snapshot()
	inv.add("slow_time_charm", 5)
	inv.remove("gongjindan")
	check(snap == {"gongjindan": 1, "spelling_hint": 1, "ssanghwatang": 1}, "the snapshot was a copy: later changes did not touch it")
	fired[0] = 0
	check(inv.restore(snap) and fired[0] == 1, "restore succeeds and announces once")
	check(inv.items() == [{"id": "gongjindan", "count": 1}, {"id": "spelling_hint", "count": 1}, {"id": "ssanghwatang", "count": 1}] and inv.snapshot() == snap, "restore puts back the contents exactly, in the same order")
	inv.restore({"slow_time_charm": 1, "gongjindan": 3})
	check(inv.items() == [{"id": "slow_time_charm", "count": 1}, {"id": "gongjindan", "count": 3}], "restore takes the order of the snapshot it is given")
	inv.restore(snap)
	snap["gongjindan"] = 99
	check(inv.count("gongjindan") == 1, "changing the snapshot afterwards doesn't change the inventory")
	var held: Dictionary = inv.snapshot()
	fired[0] = 0
	check(not inv.restore({"ssanghwatang": 1, "bogus": 1}) and not inv.restore({"ssanghwatang": 0}) and not inv.restore({"ssanghwatang": 1.5}), "a snapshot with an unknown id, a zero count or a fractional count is rejected")
	check(inv.snapshot() == held and fired[0] == 0, "and nothing changed, nothing announced")
	check(inv.restore({}) and inv.is_empty() and fired[0] == 1, "restoring an empty snapshot empties it")
	inv.add("spelling_hint")
	fired[0] = 0
	inv.clear()
	check(inv.is_empty() and inv.items() == [] and fired[0] == 1, "clear empties it and announces it")
	inv.clear()
	check(fired[0] == 1, "clearing an empty inventory announces nothing")
	check(inv.add("gongjindan", 1000) and inv.count("gongjindan") == 1000, "there is no cap per item")
	_section_done("test_inventory_logic")


func test_inventory_game_state() -> void:
	GameState.new_hike(0)
	var inv = GameState.inventory
	check(inv.is_empty(), "a new hike starts with an empty backpack")
	inv.add("ssanghwatang")
	inv.add("gongjindan", 2)
	GameState.begin_scene("foraging")
	inv.add("gongjindan")
	inv.add("spelling_hint")
	inv.remove("ssanghwatang")
	GameState.damage("nestor", "eye_branch")
	var fired := [0]
	var count_changes := func(): fired[0] += 1
	inv.changed.connect(count_changes)
	GameState.restart_scene()
	inv.changed.disconnect(count_changes)
	check(inv.items() == [{"id": "ssanghwatang", "count": 1}, {"id": "gongjindan", "count": 2}], "a restart puts the backpack back as the scene began: later items gone, an item used is back")
	check(inv.count("spelling_hint") == 0 and fired[0] == 1, "the item found during the scene is gone, and the restore was announced")
	check(GameState.heart_units["nestor"] == 10 and GameState.heart_units["fernanda"] == 10, "hearts are restored as before")
	check(GameState.inventory == inv, "it is the same Inventory object throughout (HUDs stay connected)")
	inv.add("slow_time_charm")
	GameState.restart_scene()
	check(inv.count("slow_time_charm") == 0 and inv.count("gongjindan") == 2, "a second restart restores the same scene-start backpack")
	inv.add("slow_time_charm")
	GameState.begin_scene("animals")
	inv.clear()
	GameState.restart_scene()
	check(inv.items() == [{"id": "ssanghwatang", "count": 1}, {"id": "gongjindan", "count": 2}, {"id": "slow_time_charm", "count": 1}], "the next scene's snapshot is its own start: what was held when it began, the earlier items included")
	GameState.new_hike()
	check(GameState.inventory.is_empty(), "a new hike empties the backpack")
	GameState.restart_scene()
	check(GameState.inventory.is_empty(), "and its scene-start snapshot is empty too")
	_section_done("test_inventory_game_state")


func test_backpack_data() -> void:
	var block: Dictionary = _config().get("backpack_hud", {})
	check(not block.is_empty(), "hallasan.json has a backpack_hud block")
	for key in ["position", "size"]:
		var pair = block.get(key)
		check(pair is Array and pair.size() == 2, "backpack_hud.%s is two numbers" % key)
	check(float(block["size"][0]) > 0.0 and float(block["size"][1]) > 0.0, "backpack_hud.size is positive")
	check(float(block["position"][0]) >= 0.0 and float(block["position"][1]) >= 0.0 and float(block["position"][0]) + float(block["size"][0]) <= 1280.0 and float(block["position"][1]) + float(block["size"][1]) <= 720.0, "the panel fits in 1280x720")
	for key in ["panel_color", "row_color", "text_color", "muted_text_color", "count_color"]:
		check(_is_color(block.get(key)), "backpack_hud.%s is an r, g, b colour" % key)
	check(float(block.get("panel_alpha", 0.0)) > 0.0 and float(block.get("panel_alpha", 2.0)) <= 1.0, "panel_alpha is in (0, 1]")
	for key in ["title_font_size", "name_font_size", "count_font_size", "description_font_size", "empty_font_size", "button_font_size"]:
		check(int(block.get(key, 0)) > 0, "backpack_hud.%s is a positive size" % key)
	check(int(block["description_font_size"]) < int(block["name_font_size"]), "the description is in smaller text than the name")
	check(block["title"] == "Fernanda's backpack" and block["empty_text"] == "Empty" and block["close_text"] == "Close", "the title, the empty text and the Close button read as briefed")
	_section_done("test_backpack_data")


func test_backpack_logic() -> void:
	var pack = BackpackScript.new()
	check(not pack.is_open, "a new backpack is closed")
	check(pack.escape() == "" and not pack.close() and pack.toggle(false) == "", "closed: Esc, close and a key that isn't allowed do nothing")
	check(not pack.open(false) and not pack.is_open, "it does not open when the map says no")
	check(pack.open(true) and pack.is_open, "it opens when allowed")
	check(not pack.open(true), "opening an open backpack does nothing")
	check(pack.close() and not pack.is_open, "close() closes it")
	check(pack.toggle(true) == "open" and pack.is_open, "a key opens it when allowed")
	check(pack.toggle(false) == "close" and not pack.is_open, "a key closes it, allowed or not")
	pack.open(true)
	check(pack.escape() == "close" and not pack.is_open, "Esc closes it")
	check(pack.escape() == "", "and Esc then does nothing: the pause menu is the map's business")
	_section_done("test_backpack_logic")


## A map with the backpack's starting contents already in the bag when the scene begins.
func _backpack_map(held := {}) -> Node3D:
	GameState.new_hike()
	for id in held:
		GameState.inventory.add(id, held[id])
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return map


func _row_texts(hud, index: int) -> Array:
	var ko = hud.row_label(index, "NameKo")
	return [ko.text if ko != null else "", hud.row_label(index, "NameEn").text, hud.row_label(index, "Count").text, hud.row_label(index, "Description").text]



func test_backpack_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	var viewport := map.get_viewport()
	var hud = map.backpack_hud
	var pack = map.backpack
	var config: Dictionary = _config()["backpack_hud"]
	var screen: Vector2 = viewport.get_visible_rect().size
	GameState.inventory.add("ssanghwatang")
	GameState.inventory.add("gongjindan", 2)
	GameState.inventory.add("spelling_hint")
	var held: Dictionary = GameState.inventory.snapshot()
	await _settle_layout()

	check(not pack.is_open and not hud.panel_visible() and not get_tree().paused, "closed: nothing is drawn and the tree runs")
	check(hud.layer == 12 and hud.process_mode == Node.PROCESS_MODE_ALWAYS, "its layer runs in always mode, over the hover name and under the pause menu")
	check(hud._root.mouse_filter == Control.MOUSE_FILTER_IGNORE and hud._panel.mouse_filter == Control.MOUSE_FILTER_STOP, "the panel swallows clicks; the layer's root does not")
	check(map.open_backpack() and pack.is_open and get_tree().paused, "(setup) code can open it")
	check(map.close_backpack() and not pack.is_open and not get_tree().paused and not map.close_backpack(), "(setup) and close it; closing a closed one does nothing")

	# Stuck, with the countdown running: the same freeze as the pause menu.
	check(_fail_until_stuck(map) > 0 and map.countdown.running and map.music_playing, "(setup) stuck: the countdown runs and the music is on")
	_run(map, 5.0)
	var player := _fake_music(map)
	var before := {"left": map.countdown.left, "alpha": map.stuck_hud._vignette.modulate.a, "number": map.stuck_hud._number.text, "starts": map.music_starts, "stops": map.music_stops}
	check(absf(map.countdown.left - 35.0) < 0.05 and before["alpha"] > 0.0, "(setup) 5 s in: %.2f s left, the vignette is up" % map.countdown.left)
	var decoy: Dictionary = await _menu_decoy(map)
	check(not decoy.is_empty(), "(setup) a decoy plant is on screen outside the HUD panels")

	_tap(viewport, KEY_TAB)
	await _settle_layout()
	check(pack.is_open and hud.panel_visible() and get_tree().paused and not map.can_process(), "Tab opens the backpack and pauses the tree and the map")
	check(map.countdown.paused and map.music_silenced and map.music_playing, "the countdown is held and the music is silenced, not stopped")
	check(player.stream_paused and not map._music_tween.is_running(), "the audio player is paused (position kept) and its fade is held")
	check(not map.restarting and not map.pause_menu.is_open, "`restarting` is not what blocks the map, and the pause menu is closed")
	_run(map, 3.0)
	check(map.countdown.left == before["left"], "3 s of ticks while open do not move the clock (%.3f)" % map.countdown.left)
	check(map.stuck_hud._vignette.modulate.a == before["alpha"] and map.stuck_hud._number.text == before["number"], "the vignette and the number do not change")
	check(GameState.inventory.snapshot() == held, "opening it and pausing never change the inventory")

	# The panel: title, one row per item, layout.
	check(hud._title.text == "Fernanda's backpack" and hud.row_count() == 3 and not hud.empty_visible(), "the title reads Fernanda's backpack and there is one row per item")
	check(_row_texts(hud, 0) == ["쌍화탕", "Ssanghwatang", "×1", "Herbal tonic. Restores half a heart."], "row 1: Korean name, English name, ×count, description (%s)" % str(_row_texts(hud, 0)))
	check(_row_texts(hud, 1) == ["공진단", "Gongjindan", "×2", "Herbal pill. Restores one heart."], "row 2 shows ×2 (%s)" % str(_row_texts(hud, 1)))
	check(_row_texts(hud, 2) == ["", "Spelling hint", "×1", "Shows one correct letter for 2 seconds."] and hud.row_label(2, "NameKo") == null, "an item without a Korean name has no Korean label (%s)" % str(_row_texts(hud, 2)))
	check(hud.row_label(0, "NameKo").get_theme_font("font").resource_path.ends_with(KO_FONT_FILE), "the Korean name is in Noto Sans KR")
	check(hud.row_label(0, "Description").get_theme_font_size("font_size") == int(config["description_font_size"]) and hud.row_label(0, "NameEn").get_theme_font_size("font_size") == int(config["name_font_size"]), "the description and the name use the data's font sizes")
	var panel: Rect2 = hud.panel_rect()
	var wanted := Rect2(Vector2(float(config["position"][0]), float(config["position"][1])), Vector2(float(config["size"][0]), float(config["size"][1])))
	check(panel.position.is_equal_approx(wanted.position) and panel.size.is_equal_approx(wanted.size), "the panel is where the data puts it, at the data's size (%s)" % str(panel))
	check(Rect2(Vector2.ZERO, screen).encloses(panel), "the panel is inside the 1280x720 viewport")
	var rows_ok := true
	for i in hud.row_count():
		rows_ok = rows_ok and panel.encloses(hud.row_rect(i)) and (i == 0 or hud.row_rect(i).position.y >= hud.row_rect(i - 1).end.y)
	check(rows_ok and panel.encloses(hud.close_button_rect()), "the rows are inside the panel, one under the other, and so is the Close button")

	# Everything behind the panel is locked.
	var basket_before: Array = map.picking.basket.duplicate()
	check(not map.picks_allowed(), "picks are not allowed")
	map.player.global_position = _ground_point(map, decoy["plant"].global_position.x + 0.4, decoy["plant"].global_position.z + 0.2)
	var player_x: float = map.player.global_position.x
	var partner_x: float = map.partner.global_position.x
	check(map.picking.nearest_pickable(Vector2(map.player.global_position.x, map.player.global_position.z)) >= 0, "(setup) a plant is in reach")
	check(not map.pick_nearest() and map.picking.basket == basket_before, "Space-picking is rejected with a plant in reach")
	check(not map.click(decoy["screen"]) and map.picking.walk_target == -1, "a click on a plant starts no walk")
	map.step(Vector2(1.0, 0.0), 0.2)
	check(is_equal_approx(map.player.global_position.x, player_x) and is_equal_approx(map.partner.global_position.x, partner_x), "walking is rejected: neither traveler moves")
	map.update_hover(decoy["screen"], 0.1)
	check(map._tip_plant == null and not map._tooltip.visible, "hover shows no name")
	check(not map.open_spelling("minari") and not map.spelling_hud.is_open(), "the spelling view cannot be opened by code")
	var row: Control = map.discovery_hud._rows["ma"]
	check(not panel.intersects(row.get_global_rect()), "(setup) the discovery entry is not under the panel")
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(not map.spelling_hud.is_open(), "(real click) a click on a discovery entry opens nothing")
	check(not map.open_pause_menu() and not map.pause_menu.is_open, "the pause menu cannot open over the backpack")
	check(map.picking.basket == basket_before, "no letter left the basket")

	# Live updates while it is open.
	GameState.inventory.add("slow_time_charm")
	check(hud.row_count() == 4 and _row_texts(hud, 3)[1] == "Slow-time charm", "adding an item while open adds its row at once")
	GameState.inventory.add("ssanghwatang", 2)
	check(hud.row_count() == 4 and hud.row_label(0, "Count").text == "×3", "adding more of one updates its count")
	GameState.inventory.remove("gongjindan", 2)
	check(hud.row_count() == 3 and hud.row_id(1) == "spelling_hint", "removing every one of an item takes its row away")
	GameState.inventory.restore(held)
	check(hud.row_count() == 3 and hud.row_label(1, "Count").text == "×2", "a restore redraws the rows")
	GameState.inventory.clear()
	check(hud.row_count() == 0 and hud.empty_visible() and hud.empty_text() == "Empty", "an empty backpack says Empty")
	GameState.inventory.restore(held)

	# Close with the Close button (a real click), Tab and the P2 keys; the left keys do nothing.
	var close_at: Vector2 = hud.close_button_rect().get_center()
	viewport.push_input(_click_event(close_at))
	viewport.push_input(_release_event(close_at))
	check(not pack.is_open and not hud.panel_visible() and not get_tree().paused, "(real click) the Close button closes it")
	for closer in [[KEY_TAB, 0, "Tab"], [KEY_SHIFT, 2, "right Shift"], [KEY_CTRL, 2, "right Ctrl"]]:
		_tap(viewport, KEY_TAB)
		_tap(viewport, closer[0], closer[1])
		check(not pack.is_open and not get_tree().paused, "%s closes it" % closer[2])
	for opener in [[KEY_SHIFT, 2, "right Shift"], [KEY_CTRL, 2, "right Ctrl"]]:
		_tap(viewport, opener[0], opener[1])
		check(pack.is_open and get_tree().paused and hud.panel_visible(), "%s opens it" % opener[2])
		_tap(viewport, KEY_SHIFT, KEY_LOCATION_LEFT)
		_tap(viewport, KEY_CTRL, KEY_LOCATION_LEFT)
		check(pack.is_open, "(open) left Shift and left Ctrl don't close it")
		_tap(viewport, KEY_TAB)
		check(not pack.is_open, "(open) Tab closes it")
	_tap(viewport, KEY_SHIFT, KEY_LOCATION_LEFT)
	_tap(viewport, KEY_CTRL, KEY_LOCATION_LEFT)
	check(not pack.is_open and not get_tree().paused, "(closed) left Shift and left Ctrl don't open it")
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_ESCAPE)
	await get_tree().process_frame
	check(not pack.is_open and not map.pause_menu.is_open and not get_tree().paused and not map.pause_hud.root_visible(), "one Esc closes the backpack only: after a frame the pause menu is not open")
	_tap(viewport, KEY_ESCAPE)
	check(map.pause_menu.is_open and not pack.is_open and get_tree().paused, "the next Esc, with the backpack closed, opens the pause menu as before")
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused, "and the one after resumes")

	# Closing resumes everything in place.
	_tap(viewport, KEY_TAB)
	_run(map, 2.0)
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not hud.panel_visible() and not get_tree().paused and not map.countdown.paused, "closed: unpaused, the clock released")
	check(not map.music_silenced and map.music_playing and not player.stream_paused and map._music_tween.is_running(), "the music is back on, its fade running again")
	check(map.countdown.left == before["left"] and map.stuck_hud._vignette.modulate.a == before["alpha"] and map.stuck_hud._number.text == before["number"], "the countdown value, the vignette and the number are exactly as before")
	check(map.music_starts == before["starts"] and map.music_stops == before["stops"] and map.countdown.starts == 1, "no music or countdown started or stopped in between")
	_run(map, 1.0)
	check(absf(map.countdown.left - (before["left"] - 1.0)) < 0.05, "and the clock runs on from there")
	check(GameState.inventory.snapshot() == held, "the inventory is what it was before the backpack was ever opened")
	map.update_camera(0.0, true)
	map.update_hover(map.camera.unproject_position(decoy["plant"].global_position + Vector3(0, 0.5, 0)), 0.1)
	check(map._tip_plant == decoy["plant"], "(control) hover shows names again")
	map.player.global_position = _ground_point(map, player_x + 1.0, map.player.global_position.z)
	var moved: float = map.player.global_position.x
	map.step(Vector2(1.0, 0.0), 0.2)
	check(map.player.global_position.x > moved, "(control) walking works again")
	viewport.push_input(_click_event(row.get_global_rect().get_center()))
	viewport.push_input(_release_event(row.get_global_rect().get_center()))
	check(map.spelling_hud.is_open(), "(control) the same click on the entry opens the view")
	map.spelling_hud.close()
	map._stop_music()
	map.free()
	check(not get_tree().paused, "freeing the map never leaves the tree paused")
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_backpack_scene")


func test_backpack_ignored() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _stuck_map()
	var viewport := map.get_viewport()
	var pack = map.backpack
	GameState.inventory.add("gongjindan")
	# The spelling view.
	check(map.open_spelling("ma") and get_tree().paused, "(setup) the spelling view is open")
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_SHIFT, KEY_LOCATION_RIGHT)
	_tap(viewport, KEY_CTRL, KEY_LOCATION_RIGHT)
	check(not pack.is_open and not map.backpack_hud.panel_visible() and map.spelling_hud.is_open() and not map.open_backpack(), "Tab, right Shift and right Ctrl don't open it over the spelling view")
	map.spelling_hud.close()
	check(not get_tree().paused, "(setup) the view is closed")
	# The pause menu, on both screens.
	_tap(viewport, KEY_ESCAPE)
	check(map.pause_menu.is_open and map.pause_menu.focus == 0, "(setup) the pause menu is open, on Resume")
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_SHIFT, KEY_LOCATION_RIGHT)
	_tap(viewport, KEY_CTRL, KEY_LOCATION_RIGHT)
	check(not pack.is_open and map.pause_menu.is_open and not map.pause_menu.confirming and map.pause_menu.focus == 0 and map.pause_menu.restart_requests == 0, "Tab and the P2 keys don't open it over the pause menu, and the menu's focus is untouched")
	check(not map.open_backpack() and get_tree().paused, "nor does a call from code")
	_tap(viewport, KEY_S)
	_tap(viewport, KEY_SPACE)
	check(map.pause_menu.confirming and map.pause_menu.focus == PauseMenuScript.NO, "(setup) Restart scene asks, with the focus on No")
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_CTRL, KEY_LOCATION_RIGHT)
	check(not pack.is_open and map.pause_menu.is_open and map.pause_menu.confirming and map.pause_menu.focus == PauseMenuScript.NO and map.pause_menu.restart_requests == 0, "on the question Tab changes nothing: still on No, nothing restarted")
	_tap(viewport, KEY_ESCAPE)
	check(map.pause_menu.is_open and not map.pause_menu.confirming and map.pause_menu.focus == PauseMenuScript.RESTART, "Esc is still No")
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused and not pack.is_open, "and Esc then resumes; the backpack never opened")
	# Restarting, a restart asked for, a dead traveler.
	map.restarting = true
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not map.open_backpack() and not get_tree().paused, "while `restarting` Tab does nothing")
	map.restarting = false
	map.pause_menu.restart_requests = 1
	check(not map.open_backpack() and not pack.is_open, "once a restart has been asked for it can't open")
	map.pause_menu.restart_requests = 0
	GameState.heart_units["nestor"] = 0
	check(not map.open_backpack() and not pack.is_open, "with a traveler dead it can't open")
	GameState.heart_units["nestor"] = GameState.max_units()
	_tap(viewport, KEY_TAB)
	check(pack.is_open, "(control) with all of that cleared the same key opens it")
	_tap(viewport, KEY_TAB)
	# The last second, the monster, the death beat.
	check(_fail_until_stuck(map) > 0 and map.countdown.running, "(setup) stuck, the countdown runs")
	_run(map, 39.2, 0.05)
	check(map.countdown.is_locked() and map.restarting and map.kill == null, "(setup) the last second: locked, restarting set")
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not get_tree().paused and not map.open_backpack(), "Tab in the last second is ignored")
	_run(map, 1.0, 0.05)
	check(map.kill != null and map.deer != null and not map.is_death_beat_playing(), "(setup) the monster sequence is running")
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_CTRL, KEY_LOCATION_RIGHT)
	check(not pack.is_open and not get_tree().paused and not map.open_backpack(), "Tab during the monster sequence is ignored")
	var guard := 0
	while not map.is_death_beat_playing() and guard < 100:
		_run(map, 0.1, 0.05)
		guard += 1
	check(map.is_death_beat_playing(), "(setup) the death beat is playing")
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not get_tree().paused and not map.backpack_hud.panel_visible() and not map.open_backpack(), "Tab during the death beat is ignored")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_backpack_ignored")


func test_backpack_restart() -> void:
	# The pause menu's Restart scene.
	var map: Node3D = await _backpack_map({"ssanghwatang": 1, "gongjindan": 2})
	var held: Dictionary = GameState.inventory.snapshot()
	check(held == {"ssanghwatang": 1, "gongjindan": 2}, "(setup) the scene begins with two kinds held")
	GameState.inventory.add("spelling_hint")
	GameState.inventory.remove("gongjindan")
	check(map.open_backpack() and GameState.inventory.snapshot() != held, "(setup) the backpack is open with a changed bag")
	check(map.close_backpack() and GameState.inventory.count("spelling_hint") == 1 and GameState.inventory.count("gongjindan") == 1, "opening and closing never change the bag")
	check(map.open_pause_menu(), "(setup) the pause menu is open")
	map.pause_hud.choose(1)
	map.pause_hud.choose(0)
	check(map.pause_menu.restart_requests == 1, "(setup) Restart scene was confirmed")
	check(GameState.inventory.snapshot() == held and GameState.inventory.count("spelling_hint") == 0, "Restart scene returns the backpack to what the scene began with")
	check(not map.open_backpack(), "after the restart was asked for the backpack can't open")
	map.free()
	get_tree().paused = false
	# A death.
	map = await _backpack_map({"slow_time_charm": 1})
	held = GameState.inventory.snapshot()
	GameState.inventory.add("gongjindan", 3)
	map.begin_death_beat()
	map.tick_beat(100.0)
	check(GameState.inventory.snapshot() == held, "a death returns the backpack to what the scene began with")
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_backpack_restart")


func test_backpack_input() -> void:
	check(_bound_keys("backpack_p1") == [[KEY_TAB, 0]], "backpack_p1 is bound to Tab only")
	check(_bound_keys("backpack_p2") == [[KEY_SHIFT, KEY_LOCATION_RIGHT], [KEY_CTRL, KEY_LOCATION_RIGHT]], "backpack_p2 is bound to right Shift and right Ctrl")
	var cases := [
		["Tab", KEY_TAB, KEY_LOCATION_UNSPECIFIED, true, false],
		["right Shift", KEY_SHIFT, KEY_LOCATION_RIGHT, false, true],
		["right Ctrl", KEY_CTRL, KEY_LOCATION_RIGHT, false, true],
		["left Shift", KEY_SHIFT, KEY_LOCATION_LEFT, false, false],
		["left Ctrl", KEY_CTRL, KEY_LOCATION_LEFT, false, false],
		["Space", KEY_SPACE, KEY_LOCATION_UNSPECIFIED, false, false],
		["Esc", KEY_ESCAPE, KEY_LOCATION_UNSPECIFIED, false, false],
	]
	for c in cases:
		var event := _key_event(c[1])
		event.location = c[2]
		check(InputMap.event_is_action(event, "backpack_p1") == c[3] and event.is_action_pressed("backpack_p1") == c[3], "%s %s backpack_p1" % [c[0], "matches" if c[3] else "does not match"])
		check(InputMap.event_is_action(event, "backpack_p2") == c[4] and event.is_action_pressed("backpack_p2") == c[4], "%s %s backpack_p2" % [c[0], "matches" if c[4] else "does not match"])
		check(BackpackHudScript.is_backpack_key(event) == (c[3] or c[4]), "%s %s a backpack key" % [c[0], "is" if c[3] or c[4] else "is not"])
	var release := _key_event(KEY_TAB, false)
	check(not release.is_action_pressed("backpack_p1") and not BackpackHudScript.is_backpack_key(release), "a release is not a press")
	# Nothing else on the map reacts to the new keys.
	var tab := _key_event(KEY_TAB)
	for action in ["p1_left", "p1_right", "p1_up", "p1_down", "p1_pick", "p2_left", "p2_right", "p2_up", "p2_down", "p2_pick"]:
		check(not InputMap.event_is_action(tab, action), "Tab is not %s" % action)
	var shift := _key_event(KEY_SHIFT)
	shift.location = KEY_LOCATION_RIGHT
	check(not SpellingCursorScript.is_player_key(shift) and not SpellingCursorScript.is_player_key(tab), "Tab and right Shift are not spelling-view player keys")
	_section_done("test_backpack_input")


# ---- Prompt 7b: DDEOK, reward rolls, harm decoys ----

const RewardTableScript := preload("res://scripts/reward_table.gd")


## A stand-in random source: always returns `value` (clamped into the range asked for).
class ForcedRng:
	extends RefCounted
	var value := 1

	func randi_range(from: int, to: int) -> int:
		return clampi(value, from, to)


func test_ddeok_item() -> void:
	var d: Dictionary = Content.item("ddeok")
	check(d["kind"] == "currency" and d["name_ko"] == "DDEOK" and d["name_en"] == "DDEOK" and d["description_en"] == "Virtual rice-cake token. A precursor of the in-game currency." and d["usable"] == false, "ddeok is as briefed")
	check(d["icon"] == "baekseolgi", "ddeok has the baekseolgi icon")
	check(Content.item_problem({"id": "c", "kind": "currency"}, {}) == "", "kind currency is valid")
	check(Content.item_problem({"id": "w", "kind": "coin"}, {}).contains("unknown kind 'coin'"), "an unknown kind is still rejected")
	check(Content.item_problem({"id": "n", "kind": "note"}, {}) == "" and Content.item_problem({"id": "n", "kind": "note", "icon": "baekseolgi"}, {}) == "", "the icon field is optional")
	check(Content.item_problem({"id": "n", "kind": "note", "icon": ""}, {}) != "" and Content.item_problem({"id": "n", "kind": "note", "icon": 3}, {}) != "", "an icon that is not a name is rejected")
	check(not Content.item("ssanghwatang").has("icon"), "the other items have no icon")
	GameState.new_hike(0)
	check(GameState.inventory.add("ddeok", 1000) and GameState.inventory.count("ddeok") == 1000, "ddeok stacks with no cap")
	GameState.new_hike()
	_section_done("test_ddeok_item")


func test_reward_table() -> void:
	var block: Dictionary = _config().get("decoy_rewards", {})
	var table: Array = block.get("table", [])
	var shape: Array = []
	for entry in table:
		shape.append([entry["item"], int(entry["weight"]), int(entry["count"])])
	check(shape == [["ssanghwatang", 3, 1], ["gongjindan", 1, 1], ["ddeok", 4, 1]], "the data table is the placeholder 3 : 1 : 4, count 1 each")
	var label = block.get("floating_label")
	check(label is Dictionary and _is_color(label.get("color")) and float(label.get("rise", 0)) > 0.0 and float(label.get("seconds", 0)) > 0.0, "the floating label has a rise, a duration and a colour")
	var good := RewardTableScript.new(table, Content.items)
	check(good.is_valid() and good.problem == "" and good.total_weight() == 8, "the data table is valid, total weight 8")
	var items := Content.items
	var bad := {
		"an unknown item": [{"item": "bogus", "weight": 1, "count": 1}],
		"a zero weight": [{"item": "ddeok", "weight": 0, "count": 1}],
		"a negative weight": [{"item": "ddeok", "weight": -2, "count": 1}],
		"a count of 0": [{"item": "ddeok", "weight": 1, "count": 0}],
		"a missing count": [{"item": "ddeok", "weight": 1}],
		"a fractional weight": [{"item": "ddeok", "weight": 1.5, "count": 1}],
		"an entry that is not a dictionary": ["ddeok"],
		"no entries": [],
	}
	for what in bad:
		var t := RewardTableScript.new(bad[what], items)
		check(not t.is_valid() and t.problem != "" and t.roll(ForcedRng.new()).is_empty(), "a table with %s is an error with a message, and rolls nothing (%s)" % [what, t.problem])
	check(not RewardTableScript.new(null, items).is_valid(), "a table that is not an array is an error")
	check(RewardTableScript.new(bad["an unknown item"], items).problem.contains("'bogus'"), "the message names the unknown item")
	# Forced rolls: 1..3 ssanghwatang, 4 gongjindan, 5..8 ddeok.
	var rng := ForcedRng.new()
	var expected := ["ssanghwatang", "ssanghwatang", "ssanghwatang", "gongjindan", "ddeok", "ddeok", "ddeok", "ddeok"]
	var forced_ok := true
	for i in 8:
		rng.value = i + 1
		var won: Dictionary = good.roll(rng)
		forced_ok = forced_ok and won == {"item": expected[i], "count": 1}
	check(forced_ok, "a forced roll of 1..8 returns each entry by its weight")
	var multi := RewardTableScript.new([{"item": "ddeok", "weight": 1, "count": 5}], items)
	check(multi.roll(rng) == {"item": "ddeok", "count": 5}, "an entry's count is returned")
	# Pinned seed: repeatable.
	var a := RandomNumberGenerator.new()
	var b := RandomNumberGenerator.new()
	a.seed = 12345
	b.seed = 12345
	var seq_a: Array = []
	var seq_b: Array = []
	for i in 50:
		seq_a.append(good.roll(a)["item"])
		seq_b.append(good.roll(b)["item"])
	check(seq_a == seq_b, "the same seed gives the same sequence")
	# Proportions: 8000 rolls, each share within 3 percentage points of 3/8, 1/8, 4/8.
	var n := 8000
	var tally := {"ssanghwatang": 0, "gongjindan": 0, "ddeok": 0}
	var big := RandomNumberGenerator.new()
	big.seed = 20261031
	for i in n:
		tally[good.roll(big)["item"]] += 1
	var want := {"ssanghwatang": 3.0 / 8.0, "gongjindan": 1.0 / 8.0, "ddeok": 4.0 / 8.0}
	for id in tally:
		var share: float = float(tally[id]) / n
		check(absf(share - want[id]) <= 0.03, "over %d rolls %s came up %.3f of the time, within 0.03 of %.3f" % [n, id, share, want[id]])
	_section_done("test_reward_table")


## A map for the decoy tests, built with the backpack holding `held` and `controlled` picking.
func _decoy_map(controlled := "fernanda", held := {}) -> Node3D:
	GameState.new_hike()
	for id in held:
		GameState.inventory.add(id, held[id])
	GameState.controlled = controlled
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return map


func _plant_of(map: Node3D, kind: String, nth := 0) -> Node3D:
	var seen := 0
	for plant in map.plants:
		if plant.kind == kind:
			if seen == nth:
				return plant
			seen += 1
	return null


func test_reward_pick() -> void:
	var map: Node3D = await _decoy_map()
	check(map.reward_table.is_valid(), "(setup) the map's reward table is valid")
	var rng := ForcedRng.new()
	map.reward_rng = rng
	var plant := _plant_of(map, "decoy_reward", 0)
	var basket_before: Array = map.picking.basket.duplicate()
	var hearts_before: Dictionary = GameState.heart_units.duplicate()
	rng.value = 5  # ddeok
	map.pick_plant(plant)
	check(GameState.inventory.snapshot() == {"ddeok": 1}, "a reward pick adds exactly the rolled item and count to the backpack")
	check(map.picking.basket == basket_before and plant.letter == "" and not map.picking.has_letter(map.plants.find(plant)), "the letter handling is unchanged: gone from the plant, not in the basket")
	check(map.find_children("*", "CPUParticles3D", false, false).size() == 1, "the steam puff still plays")
	check(GameState.heart_units == hearts_before, "a reward decoy costs no hearts")
	var float_label := map.find_child("FloatingLabel", false, false) as Label3D
	check(float_label != null and float_label.text == "+1 DDEOK", "a floating '+1 DDEOK' label appears")
	check(float_label != null and float_label.global_position.distance_to(plant.letter_position()) < 0.01, "it starts at the picked plant's letter")
	var second := _plant_of(map, "decoy_reward", 1)
	rng.value = 1  # ssanghwatang
	map.pick_plant(second)
	check(GameState.inventory.snapshot() == {"ddeok": 1, "ssanghwatang": 1}, "a second pick adds the next roll")
	var labels := map.find_children("*", "Label3D", false, false)
	var texts: Array = labels.map(func(l): return l.text)
	check(texts.has("+1 Ssanghwatang 쌍화탕"), "its label reads name_en then name_ko")
	rng.value = 4  # gongjindan
	map.pick_plant(_plant_of(map, "decoy_reward", 2))
	check(GameState.inventory.count("gongjindan") == 1, "a third roll gives gongjindan")
	map.pick_plant(second)  # already picked
	check(GameState.inventory.count("ssanghwatang") == 1, "a picked plant gives nothing twice")
	var label_count := map.find_children("*", "Label3D", false, false).size()
	await get_tree().create_timer(float(map.reward_label_config["seconds"]) + 0.3).timeout
	check(label_count == 3 and map.find_children("*", "Label3D", false, false).size() == 0, "the labels rise, fade and free themselves")
	# A restart (death) removes what was found.
	map.begin_death_beat()
	map.tick_beat(100.0)
	check(GameState.inventory.is_empty(), "a death restores the backpack to the scene start: the finds are gone")
	map.free()
	get_tree().paused = false
	# The real random source: randomized, rolls something valid.
	map = await _decoy_map()
	check(map.reward_rng is RandomNumberGenerator, "the game rolls with a RandomNumberGenerator")
	map.pick_plant(_plant_of(map, "decoy_reward", 0))
	var got: Array = GameState.inventory.items()
	check(got.size() == 1 and ["ssanghwatang", "gongjindan", "ddeok"].has(got[0]["id"]) and got[0]["count"] == 1, "a real pick gives one of the table's items")
	map.free()
	# A bad table: no crash, no item, steam still plays.
	map = await _decoy_map()
	map.reward_table = RewardTableScript.new([], Content.items)
	map.pick_plant(_plant_of(map, "decoy_reward", 0))
	check(GameState.inventory.is_empty() and map.find_children("*", "CPUParticles3D", false, false).size() == 1, "a bad table gives nothing but the steam still plays")
	map.free()
	GameState.new_hike()
	_section_done("test_reward_pick")


func test_harm_pick() -> void:
	for controlled in ["fernanda", "nestor"]:
		var other: String = GameState.partner_of(controlled)
		var map: Node3D = await _decoy_map(controlled, {"ddeok": 2})
		var start := GameState.max_units()
		var cost := 0
		for kind_id in ["keuncheonnamseong", "butsunnamu"]:
			var units := int(_config()["decoy_placement"]["damage_units"])
			var plant: Node3D
			for p in map.plants:
				if p.kind_id == kind_id:
					plant = p
					break
			var puffs_before := map.find_children("*", "CPUParticles3D", false, false).size()
			map.pick_plant(plant)
			cost += units
			check(units == 1 and GameState.heart_units[controlled] == start - cost, "%s: picking %s costs the picker %d half-unit(s)" % [controlled, kind_id, units])
			check(GameState.heart_units[other] == start, "%s: the other traveler's hearts are unchanged" % controlled)
			check(map.find_children("*", "CPUParticles3D", false, false).size() == puffs_before + 1, "%s: the steam still plays for %s" % [controlled, kind_id])
			check(plant.letter == "" and map.picking.basket.is_empty(), "%s: the harm decoy's letter is gone and not in the basket" % controlled)
			_finish_gore(map)  # the gore beat blocks the next pick until it ends
		check(GameState.inventory.snapshot() == {"ddeok": 2} and not map.is_death_beat_playing(), "%s: no item change and no death from non-lethal picks" % controlled)
		map.free()
		get_tree().paused = false
	# Lethal: the picker is at half a heart.
	var map: Node3D = await _decoy_map("fernanda", {"ddeok": 1})
	GameState.inventory.add("gongjindan")
	GameState.heart_units["fernanda"] = 1
	var deaths: Array = []
	var on_death := func(dead, survivor, injury): deaths.append([dead, survivor, injury])
	GameState.travelers_died.connect(on_death)
	var restarts := [0]
	map.restarted.connect(func(): restarts[0] += 1)
	map.pick_plant(_plant_of(map, "decoy_harm", 0))
	check(deaths.size() == 1 and deaths[0][0] == "fernanda" and deaths[0][1] == "nestor", "the lethal pick announces the death once (%s)" % str(deaths))
	check(not GameState.is_alive("fernanda") and not map.is_death_beat_playing() and map.is_gore_playing() and not map.picks_allowed(), "the death waits: the gore beat plays first and nothing can be picked")
	map.pick_plant(_plant_of(map, "decoy_harm", 1))
	check(deaths.size() == 1, "a further pick in the beat does not repeat the death")
	_finish_gore(map)
	map.tick_beat(100.0)
	check(not map.is_death_beat_playing(), "the death beat has not started when the gore ends (it waits one tick)")
	map.tick_gore(1.0 / 60.0)
	check(map.is_death_beat_playing() and map.restarting, "the death beat starts on the next tick")
	map.tick_beat(100.0)
	GameState.travelers_died.disconnect(on_death)
	check(restarts[0] == 1 and not map.is_death_beat_playing(), "the scene restarts once")
	check(GameState.heart_units["fernanda"] == GameState.max_units() and GameState.heart_units["nestor"] == GameState.max_units(), "hearts are restored to the scene start")
	check(GameState.inventory.snapshot() == {"ddeok": 1}, "the backpack is restored to the scene-start contents")
	map.free()
	GameState.new_hike()
	_section_done("test_harm_pick")


func test_backpack_icons() -> void:
	var map: Node3D = await _backpack_map({"ddeok": 3, "ssanghwatang": 1, "gongjindan": 1})
	check(map.open_backpack(), "(setup) the backpack opens")
	await _settle_layout()
	var hud = map.backpack_hud
	var size := float(_config()["backpack_hud"]["icon_size"])
	check(hud.row_count() == 3 and hud.row_id(0) == "ddeok", "(setup) three rows, ddeok first")
	check(_row_texts(hud, 0) == ["DDEOK", "DDEOK", "×3", "Virtual rice-cake token. A precursor of the in-game currency."], "the DDEOK row reads as data says (%s)" % str(_row_texts(hud, 0)))
	var icon := hud._rows.get_child(0).find_child("Icon", true, false) as Control
	check(icon != null and icon.size == Vector2(size, size) and icon.is_visible_in_tree(), "the DDEOK row has an icon of the data's size")
	check(icon != null and hud.row_rect(0).encloses(icon.get_global_rect()), "the icon is inside its row")
	check(icon != null and icon.get_global_rect().end.x <= hud.row_label(0, "NameEn").get_global_rect().position.x, "the icon sits beside the text, to its left")
	check(hud._rows.get_child(1).find_child("Icon", true, false) == null and hud._rows.get_child(2).find_child("Icon", true, false) == null, "rows without an icon have none")
	check(_row_texts(hud, 1) == ["쌍화탕", "Ssanghwatang", "×1", "Herbal tonic. Restores half a heart."], "an icon-less row reads as before")
	check(hud._rows.get_child(1).get_child(0) is VBoxContainer, "an icon-less row keeps its old layout: the text column is the row's only child")
	map.close_backpack()
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_backpack_icons")


# ---- Harm decoy gore beats ----

const DecoyGoreScript := preload("res://scenes/foraging/decoy_gore.gd")
const GORE_PAIRS := [["keuncheonnamseong", "face_swell_pop"], ["butsunnamu", "convulse_eyes_pop"]]


func _kinds_copy() -> Array:
	return _config()["plants"]["kinds"].duplicate(true)


func _table_copy() -> Dictionary:
	return _config()["decoy_gore"].duplicate(true)


func _kind_in(kinds: Array, id: String) -> Dictionary:
	for k in kinds:
		if k["id"] == id:
			return k
	return {}


func test_decoy_gore_data() -> void:
	var table: Dictionary = _config()["decoy_gore"]
	var kinds: Array = _config()["plants"]["kinds"]
	check(table.has("face_swell_pop") and table.has("convulse_eyes_pop"), "the decoy_gore table has both gore ids")
	for id in ["face_swell_pop", "convulse_eyes_pop"]:
		check(float(table[id]["duration"]) > 0.0 and float(table[id]["pop_seconds"]) > 0.0 and float(table[id]["pop_seconds"]) <= float(table[id]["duration"]), "%s has a positive duration and a pop inside it" % id)
	for pair in GORE_PAIRS:
		check(_kind_in(kinds, pair[0]).get("gore", "") == pair[1], "%s carries gore id %s" % [pair[0], pair[1]])
		check(not _kind_in(kinds, pair[0]).has("damage_units") and int(_config()["decoy_placement"]["damage_units"]) == 1, "%s still costs 1 half-unit, now one value (decoy_placement.damage_units) for every harm outcome" % pair[0])
	for k in kinds:
		check((k["kind"] == "decoy") == k.has("gore"), "%s: only decoy kinds have a gore field" % k["id"])
	check(DecoyGoreScript.problem_with(kinds, table) == "", "the shipped data validates")
	check(int(_config()["decoy_rewards"]["floating_label"]["render_priority"]) > 0, "the floating label has a render priority above the steam's 0")
	# Bad data is a clear message, never a crash.
	var bad := _kinds_copy()
	_kind_in(bad, "butsunnamu")["gore"] = "no_such_gore"
	var msg: String = DecoyGoreScript.problem_with(bad, table)
	check(msg.contains("butsunnamu") and msg.contains("no_such_gore"), "an unknown gore id is rejected, naming plant and id (%s)" % msg)
	bad = _kinds_copy()
	_kind_in(bad, "keuncheonnamseong").erase("gore")
	msg = DecoyGoreScript.problem_with(bad, table)
	check(msg.contains("keuncheonnamseong") and msg.contains("no gore id"), "a missing gore id is rejected (%s)" % msg)
	bad = _kinds_copy()
	_kind_in(bad, "keuncheonnamseong")["gore"] = ""
	check(DecoyGoreScript.problem_with(bad, table).contains("no gore id"), "an empty gore id is rejected")
	for value in [0.0, -1.5]:
		var t := _table_copy()
		t["face_swell_pop"]["duration"] = value
		msg = DecoyGoreScript.problem_with(_kinds_copy(), t)
		check(msg.contains("face_swell_pop") and msg.contains("duration"), "a duration of %s is rejected (%s)" % [str(value), msg])
	var t2 := _table_copy()
	t2["convulse_eyes_pop"].erase("duration")
	check(DecoyGoreScript.problem_with(_kinds_copy(), t2).contains("duration"), "a missing duration is rejected")
	t2 = _table_copy()
	t2["convulse_eyes_pop"]["pop_seconds"] = 9.0
	check(DecoyGoreScript.problem_with(_kinds_copy(), t2).contains("pop_seconds"), "a pop after the end is rejected")
	bad = _kinds_copy()
	_kind_in(bad, "norugui").erase("gore")
	msg = DecoyGoreScript.problem_with(bad, table)
	check(msg.contains("norugui") and msg.contains("no gore id"), "a decoy kind without a gore id is rejected, whatever its outcome rolls (%s)" % msg)
	bad = _kinds_copy()
	_kind_in(bad, "ma")["gore"] = "face_swell_pop"
	check(DecoyGoreScript.problem_with(bad, table).contains("gore field"), "a gore field on a target is rejected too")
	check(DecoyGoreScript.problem_with(_kinds_copy(), null).contains("decoy_gore") and DecoyGoreScript.problem_with(_kinds_copy(), []).contains("decoy_gore"), "a missing or non-table decoy_gore is rejected")
	_section_done("test_decoy_gore_data")


func test_decoy_gore_logic() -> void:
	var table: Dictionary = _config()["decoy_gore"]
	var entry: Dictionary = table["face_swell_pop"]
	var g = DecoyGoreScript.new()
	check(not g.active and g.tick(1.0).is_empty() and g.fraction() == 0.0, "idle: nothing happens")
	check(g.start("face_swell_pop", "fernanda", entry) and g.active and g.who == "fernanda", "it starts on a harm pick")
	check(not g.start("face_swell_pop", "nestor", entry) and g.who == "fernanda", "a second start while one runs is refused")
	var pop_at := float(entry["pop_seconds"])
	var dur := float(entry["duration"])
	check(g.tick(pop_at - 0.05).is_empty() and g.active, "nothing fires before the pop")
	check(g.build_up() < 1.0 and g.build_up() > 0.9, "the build-up is nearly full just before the pop")
	check(g.tick(0.1) == ["pop"] and g.popped, "the pop fires once, when its time comes")
	check(g.tick(0.1).is_empty() and g.build_up() == 1.0, "and not again")
	check(g.tick(dur) == ["done"] and not g.active and g.finishes == 1, "it ends after its duration, once")
	check(g.tick(1.0).is_empty(), "an ended beat ticks to nothing")
	check(g.start("x", "nestor", {"duration": 0.0, "pop_seconds": 0.0}) == false, "a non-positive duration never starts")
	g.start("convulse_eyes_pop", "nestor", table["convulse_eyes_pop"])
	check(g.tick(100.0) == ["pop", "done"], "one long tick gives the pop then the end")
	g.start("face_swell_pop", "nestor", entry)
	g.tick(0.3)
	g.cancel()
	check(not g.active and g.who == "" and g.tick(5.0).is_empty() and g.finishes == 2, "cancel drops the beat without finishing it")
	_section_done("test_decoy_gore_logic")


## Picks the first harm decoy of `kind_id` on `map` and returns it.
func _pick_harm(map: Node3D, kind_id: String) -> Node3D:
	var plant: Node3D
	for p in map.plants:
		if p.kind_id == kind_id:
			plant = p
			break
	map.pick_plant(plant)
	return plant


func _particle_count(map: Node3D) -> int:
	return map.find_children("*", "CPUParticles3D", false, false).size()


func test_decoy_gore_scene() -> void:
	for pair in GORE_PAIRS:
		var kind_id: String = pair[0]
		var gore_id: String = pair[1]
		var map: Node3D = await _decoy_map("fernanda", {"ddeok": 2})
		var picker: Node3D = map.travelers["fernanda"]
		var other: Node3D = map.travelers["nestor"]
		var start := GameState.max_units()
		var base_pos: Vector3 = picker.global_position
		var base_rot: Vector3 = picker.rotation
		var base_color: Color = picker.body_color()
		var other_pos: Vector3 = other.global_position
		var other_rot: Vector3 = other.rotation
		var other_color: Color = other.body_color()
		var entry: Dictionary = _config()["decoy_gore"][gore_id]
		var plant := _pick_harm(map, kind_id)
		var tag := kind_id + ": "
		check(GameState.heart_units["fernanda"] == start - 1, tag + "the half-heart damage lands at the start of the beat")
		check(map.decoy_gore.active and map.decoy_gore.gore_id == gore_id and map.decoy_gore.who == "fernanda", tag + "the beat starts on the picker with its gore id")
		check(_particle_count(map) == 1, tag + "the steam plays and nothing else yet")
		check(not map.is_death_beat_playing() and not map.restarting, tag + "no death beat and `restarting` is not used")
		var fx := map.find_child("DecoyGoreFx", false, false) as Node3D
		check(fx != null, tag + "the shapes exist")
		var max_shift := 0.0
		while map.decoy_gore.elapsed < float(entry["pop_seconds"]) * 0.5:
			map.tick_gore(1.0 / 60.0)
			max_shift = maxf(max_shift, picker.global_position.distance_to(base_pos))
		if gore_id == "face_swell_pop":
			var head: MeshInstance3D = fx._head
			check(head.visible and head.scale.x > 1.3, tag + "halfway to the pop the head has swelled (scale %.2f)" % head.scale.x)
			var c: Color = fx._head_material.albedo_color
			var skin := Color(entry["head_color"][0], entry["head_color"][1], entry["head_color"][2])
			check(c.r - c.g > skin.r - skin.g, tag + "and reddened")
			check(head.global_position.distance_to(base_pos + Vector3(0, float(entry["head_height"]), 0)) < 0.2, tag + "it sits at the picker's head")
		else:
			check(max_shift > 0.01 and max_shift <= float(entry["jitter_amplitude"]) * 3.0, tag + "the picker jitters, within the data's amplitude (max %.3f)" % max_shift)
		check(other.global_position == other_pos and other.rotation == other_rot and other.body_color() == other_color, tag + "the other traveler is untouched during the build-up")
		var particles_before := _particle_count(map)
		while not map.decoy_gore.popped:
			map.tick_gore(1.0 / 60.0)
		check(_particle_count(map) > particles_before, tag + "the pop sprays blood")
		if gore_id == "face_swell_pop":
			check(not fx._head.visible, tag + "the head is gone after the pop")
		else:
			var eyes := fx.find_children("Eye*", "Node3D", false, false)
			check(eyes.size() == 2, tag + "two eyes fly out")
			var eye_x: Array = eyes.map(func(e): return e.global_position.x)
			for i in 40:
				map.tick_gore(1.0 / 60.0)
			var y_after: Array = eyes.map(func(e): return e.global_position.y)
			check(eyes[0].global_position.x < eye_x[0] and eyes[1].global_position.x > eye_x[1], tag + "one flies left and one right")
			check(y_after[0] >= base_pos.y and y_after[1] >= base_pos.y, tag + "they stay above the ground")
			check(picker.global_position == base_pos, tag + "the jitter has stopped at the pop")
		check(other.global_position == other_pos and other.rotation == other_rot and other.body_color() == other_color, tag + "the other traveler is untouched after the pop")
		_finish_gore(map)
		check(not map.decoy_gore.active and not map.is_gore_playing(), tag + "the beat ends")
		check(map.find_child("DecoyGoreFx", false, false) == null, tag + "its shapes are gone")
		check(_particle_count(map) == 1, tag + "no blood, chunks or other particles are left (only the steam)")
		check(picker.global_position == base_pos and picker.rotation == base_rot and picker.scale == Vector3.ONE and picker.body_color() == base_color, tag + "the picker is exactly as before: position, rotation, scale, tint")
		check(other.global_position == other_pos and other.rotation == other_rot and other.body_color() == other_color, tag + "the other traveler is untouched")
		check(plant.letter == "" and plant.is_inside_tree() and plant.scale == Vector3.ONE, tag + "the plant is not changed by the gore")
		check(map.picks_allowed() and not map.restarting, tag + "play resumes")
		check(GameState.heart_units["fernanda"] == start - 1 and GameState.heart_units["nestor"] == start, tag + "no further damage")
		map.free()
		get_tree().paused = false
	# A reward pick is unchanged: no gore, and the label sorts above the steam.
	var map: Node3D = await _decoy_map()
	var rng := ForcedRng.new()
	rng.value = 5
	map.reward_rng = rng
	map.pick_plant(_plant_of(map, "decoy_reward", 0))
	var label := map.find_child("FloatingLabel", false, false) as Label3D
	check(not map.decoy_gore.active and not map.is_gore_playing() and map.picks_allowed(), "a reward pick plays no gore and blocks nothing")
	check(label != null and label.text == "+1 DDEOK" and label.no_depth_test and label.billboard == BaseMaterial3D.BILLBOARD_ENABLED, "the label still reads '+1 DDEOK', billboarded, with no depth test")
	check(label != null and label.render_priority == int(_config()["decoy_rewards"]["floating_label"]["render_priority"]) and label.render_priority > 0 and label.outline_render_priority < label.render_priority, "the label sorts in front of the steam; its outline stays behind its text")
	map.free()
	GameState.new_hike()
	_section_done("test_decoy_gore_scene")


func test_decoy_gore_gating() -> void:
	for pair in GORE_PAIRS:
		var map: Node3D = await _decoy_map("fernanda", {"ddeok": 1})
		var tag: String = pair[0] + ": "
		_pick_harm(map, pair[0])
		var live := _plant_of(map, "target", 0)
		var player_pos: Vector3 = map.player.global_position
		var partner_pos: Vector3 = map.partner.global_position
		check(not map.picks_allowed() and not map.pick_nearest(), tag + "no pick during the beat")
		map.pick_plant(live)
		check(live.letter != "" and map.picking.basket.is_empty(), tag + "pick_plant takes nothing")
		check(not map.click(Vector2(640, 360)), tag + "a click starts no walk")
		check(not map.open_spelling("ma") and not map.spelling_hud.is_open(), tag + "the spelling view does not open")
		check(not map.open_pause_menu() and not map.pause_menu.is_open and not get_tree().paused, tag + "the pause menu does not open")
		check(not map.open_backpack() and not map.backpack.is_open, tag + "the backpack does not open")
		map.step(Vector2.RIGHT, 0.5)
		map.step(Vector2(0.0, 1.0), 0.5)
		check(map.player.global_position == player_pos and map.partner.global_position == partner_pos, tag + "nobody walks (neither traveler moved)")
		_finish_gore(map)
		check(map.picks_allowed(), tag + "picks are allowed again")
		check(map.open_backpack() and map.close_backpack(), tag + "the backpack opens and closes again")
		check(map.open_pause_menu() and map.pause_menu.is_open, tag + "the pause menu opens again")
		map.pause_menu.close()
		get_tree().paused = false
		var x_before: float = map.player.global_position.x
		for i in 30:
			map.step(Vector2.RIGHT, 1.0 / 60.0)
		check(map.player.global_position.x > x_before + 0.5, tag + "walking works again")
		map.pick_plant(live)
		check(map.picking.basket.size() == 1, tag + "and a pick works again")
		map.free()
		get_tree().paused = false
	GameState.new_hike()
	_section_done("test_decoy_gore_gating")


func test_decoy_gore_countdown() -> void:
	var map: Node3D = await _stuck_map({"nestor": 9, "fernanda": 7})
	check(_fail_until_stuck(map) > 0 and map.countdown.running, "(setup) the scene is stuck with the countdown running")
	var left: float = map.countdown.left
	_run(map, 2.0)
	check(absf(map.countdown.left - (left - 2.0)) < 0.05, "(setup) the countdown runs between beats")
	_pick_harm(map, "keuncheonnamseong")
	check(map.decoy_gore.active and map.countdown.running, "(setup) the beat plays with the countdown still running")
	left = map.countdown.left
	var vignette: float = map.stuck_hud._vignette.modulate.a
	_run(map, 0.5)  # the map's own tick; the beat's tick is separate
	check(map.countdown.paused and map.countdown.left == left, "the countdown stands still during the beat")
	check(map.music_playing and map.music_silenced, "the countdown music is held, not stopped")
	check(map.stuck_hud._vignette.modulate.a == vignette, "the vignette does not grow")
	_finish_gore(map)
	check(not map.countdown.paused and map.countdown.running and map.countdown.left == left and not map.music_silenced, "after the beat the countdown and music resume where they were")
	_run(map, 1.0)
	check(absf(map.countdown.left - (left - 1.0)) < 0.05, "and the clock goes on from there")
	check(map.music_playing and map.music_stops == 0, "the music never stopped")
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_decoy_gore_countdown")


func test_decoy_gore_lethal() -> void:
	for pair in GORE_PAIRS:
		var map: Node3D = await _decoy_map("fernanda", {"ddeok": 1})
		var tag: String = pair[0] + ": "
		GameState.inventory.add("gongjindan")
		GameState.heart_units["fernanda"] = 1
		var deaths: Array = []
		var on_death := func(dead, _survivor, _injury): deaths.append(dead)
		GameState.travelers_died.connect(on_death)
		var beats := [0]
		var restarts := [0]
		map.death_beat_started.connect(func(): beats[0] += 1)
		map.restarted.connect(func(): restarts[0] += 1)
		_pick_harm(map, pair[0])
		check(deaths == ["fernanda"] and GameState.heart_units["fernanda"] == 0, tag + "the damage is applied at the pick and the death announced once")
		check(map.decoy_gore.active and beats[0] == 0 and not map.is_death_beat_playing(), tag + "the gore starts first, the death sequence has not")
		var tick_gore_end := -1
		var tick_death := -1
		var overlap := false
		var n := 0
		while tick_death < 0 and n < 1000:
			n += 1
			map.tick_gore(1.0 / 60.0)
			if map.decoy_gore.active and map.is_death_beat_playing():
				overlap = true
			if tick_gore_end < 0 and not map.decoy_gore.active:
				tick_gore_end = n
				check(not map.is_death_beat_playing() and beats[0] == 0 and map.find_child("DecoyGoreFx", false, false) == null, tag + "on the tick the gore ends its shapes are gone and the death has not begun")
			if map.is_death_beat_playing():
				tick_death = n
		check(not overlap, tag + "gore and death never overlap")
		check(tick_gore_end > 0 and tick_death == tick_gore_end + 1, tag + "the death begins exactly one tick after the gore ends (gore ended tick %d, death tick %d)" % [tick_gore_end, tick_death])
		var gore_seconds := float(_config()["decoy_gore"][pair[1]]["duration"])
		check(absf((tick_gore_end / 60.0) - gore_seconds) < 0.05, tag + "the gore ran its full duration first (%.2f s)" % (tick_gore_end / 60.0))
		for i in 30:
			map.tick_gore(1.0 / 60.0)
		check(beats[0] == 1 and map.restarting and map.is_death_beat_playing(), tag + "the death sequence began exactly once")
		check(deaths == ["fernanda"] and not GameState.is_alive("fernanda"), tag + "no second death announcement")
		map.tick_beat(100.0)
		GameState.travelers_died.disconnect(on_death)
		check(restarts[0] == 1 and not map.is_death_beat_playing() and not map.is_gore_playing(), tag + "the scene restarts once, nothing pending")
		check(GameState.heart_units["fernanda"] == GameState.max_units() and GameState.heart_units["nestor"] == GameState.max_units(), tag + "both hearts are back (both died, restart rules unchanged)")
		check(GameState.inventory.snapshot() == {"ddeok": 1}, tag + "the backpack is restored to its scene-start contents")
		map.free()
		get_tree().paused = false
	# Bad gore data: the death starts at once, as before the gore existed.
	var map: Node3D = await _decoy_map()
	map.gore_table = {}
	GameState.heart_units["fernanda"] = 1
	_pick_harm(map, "butsunnamu")
	check(not map.decoy_gore.active and map.is_death_beat_playing(), "without a usable gore table a lethal pick starts the death at once")
	map.free()
	map = await _decoy_map()
	map.gore_table = {}
	_pick_harm(map, "butsunnamu")
	check(not map.decoy_gore.active and GameState.heart_units["fernanda"] == GameState.max_units() - 1 and map.picks_allowed(), "without a gore table a harm pick only costs the half heart")
	map.free()
	GameState.new_hike()
	_section_done("test_decoy_gore_lethal")


func test_decoy_gore_restart() -> void:
	for pair in GORE_PAIRS:
		var tag: String = pair[0] + ": "
		# A scene restart in the middle of a beat.
		var map: Node3D = await _decoy_map("fernanda", {"ddeok": 1})
		var picker: Node3D = map.travelers["fernanda"]
		var base_pos: Vector3 = picker.global_position
		var base_color: Color = picker.body_color()
		_pick_harm(map, pair[0])
		for i in 60:  # past the pop for the convulsion (0.9 s), mid-swell for the face
			map.tick_gore(1.0 / 60.0)
		check(map.decoy_gore.active, tag + "(setup) a beat is mid-way")
		map._restart()
		check(not map.decoy_gore.active and not map.is_gore_playing() and map.find_child("DecoyGoreFx", false, false) == null, tag + "a restart mid-beat leaves no beat and no shapes")
		check(_particle_count(map) == 1, tag + "and no blood (only the steam)")
		check(picker.global_position == base_pos and picker.scale == Vector3.ONE and picker.body_color() == base_color, tag + "the picker is as before")
		check(GameState.heart_units["fernanda"] == GameState.max_units() and GameState.inventory.snapshot() == {"ddeok": 1}, tag + "hearts and backpack are the scene-start ones")
		map.tick_gore(1.0)
		check(not map.is_death_beat_playing() and map.picks_allowed() and not map.countdown.paused, tag + "nothing starts later on its own")
		map.free()
		# A death sequence begun in the middle of a beat drops the gore.
		map = await _decoy_map("fernanda", {})
		picker = map.travelers["fernanda"]
		base_pos = picker.global_position
		base_color = picker.body_color()
		_pick_harm(map, pair[0])
		for i in 60:
			map.tick_gore(1.0 / 60.0)
		map.begin_death_beat()
		check(not map.decoy_gore.active and map.find_child("DecoyGoreFx", false, false) == null and map.is_death_beat_playing(), tag + "a death in the middle of a beat drops the gore, and the death begins")
		check(picker.global_position == base_pos and picker.body_color() == base_color, tag + "the picker is reset")
		map.tick_gore(1.0)
		check(map.is_death_beat_playing(), tag + "the death beat goes on once")
		map.tick_beat(100.0)
		check(not map.is_death_beat_playing() and GameState.heart_units["fernanda"] == GameState.max_units(), tag + "it restarts normally")
		map.free()
		get_tree().paused = false
	GameState.new_hike()
	_section_done("test_decoy_gore_restart")


# ---- Drinking elixirs from the backpack ----

## A map whose scene begins with `held` in the bag and the travelers on `nestor_units` and `fernanda_units` (half-units).
func _drink_map(held: Dictionary, nestor_units := 10, fernanda_units := 10) -> Node3D:
	GameState.new_hike()
	GameState.heart_units["nestor"] = nestor_units
	GameState.heart_units["fernanda"] = fernanda_units
	for id in held:
		GameState.inventory.add(id, held[id])
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return map


func _click_at(viewport: Viewport, at: Vector2) -> void:
	viewport.push_input(_click_event(at))
	viewport.push_input(_release_event(at))


## True if the hearts HUD draws both travelers' current hearts.
func _hearts_drawn_ok(map: Node3D) -> bool:
	for id in GameState.TRAVELERS:
		if map.hearts_hud.drawn_states(id) != map.hearts_hud.states_for(int(GameState.heart_units[id])):
			return false
	return true


func _data_color(value: Array) -> Color:
	return Color(value[0], value[1], value[2])


func test_drink_data() -> void:
	var block: Dictionary = _config()["backpack_hud"]
	for key in ["selected_row_color", "selected_border_color", "choice_color", "choice_button_color", "choice_selected_color", "choice_selected_border_color", "message_color", "message_wasted_color"]:
		check(_is_color(block.get(key)), "backpack_hud.%s is an r, g, b colour" % key)
	for key in ["row_padding", "selected_border_width", "choice_padding", "choice_prompt_font_size", "choice_selected_border_width", "message_font_size"]:
		check(float(block.get(key, 0)) > 0.0, "backpack_hud.%s is positive" % key)
	check(block["choice_button_size"] is Array and block["choice_button_size"].size() == 2 and float(block["choice_button_size"][0]) > 0.0, "backpack_hud.choice_button_size is two positive numbers")
	check(float(block["message_seconds"]) > 0.0, "the message stays a positive number of seconds")
	for key in ["choice_prompt", "choice_button_text", "hearts_text"]:
		check(block[key] is String and block[key] != "", "backpack_hud.%s is text" % key)
	var words: Dictionary = block["messages"]
	for key in ["drank", "partial", "wasted", "heart", "hearts", "half_glyph"]:
		check(words.get(key) is String and words[key] != "", "backpack_hud.messages.%s is text" % key)
	check("{healed}" in words["drank"] and "{healed}" in words["partial"] and "{wasted}" in words["partial"], "the drank and partial texts have their amount slots")
	var panel := Rect2(Vector2(float(block["position"][0]), float(block["position"][1])), Vector2(float(block["size"][0]), float(block["size"][1])))
	check(Rect2(Vector2.ZERO, Vector2(1280, 720)).encloses(panel), "the panel still fits the 1280x720 viewport")
	_section_done("test_drink_data")


func test_drink_logic() -> void:
	var inv = InventoryScript.new()
	inv.add("ssanghwatang")
	inv.add("spelling_hint")
	inv.add("gongjindan", 2)
	inv.add("ddeok", 5)
	inv.add("slow_time_charm")
	var items: Array = inv.items()
	var words: Dictionary = _config()["backpack_hud"]["messages"]

	# Selectability.
	check(BackpackScript.is_selectable("ssanghwatang") and BackpackScript.is_selectable("gongjindan"), "both elixirs are selectable")
	for id in ["ddeok", "spelling_hint", "slow_time_charm", "bogus_item", ""]:
		check(not BackpackScript.is_selectable(id), "'%s' is not selectable" % id)
	check(BackpackScript.selectable_ids(items) == ["ssanghwatang", "gongjindan"], "the selectable rows are the elixir rows, in row order")
	var pack = BackpackScript.new()
	check(not pack.select("ddeok", items) and not pack.select("spelling_hint", items) and not pack.select("slow_time_charm", items) and pack.selected == "", "currency, hint and charm rows can't be selected")
	check(not pack.select("ssanghwatang", []), "an elixir that is not in the bag can't be selected")
	check(pack.select("gongjindan", items) and pack.selected == "gongjindan", "an elixir row can be selected")
	check(pack.open_choice(10, 10) and pack.choosing, "the question opens for a selected elixir")
	pack.reset()
	check(pack.selected == "" and not pack.choosing and pack.message == "", "reset forgets the selection, the question and the message")
	check(not pack.open_choice(10, 10) and not pack.choosing, "with nothing selected the question can't open")

	# Nothing to select: unchanged.
	var plain: Array = [{"id": "ddeok", "count": 2}, {"id": "spelling_hint", "count": 1}]
	for action in ["left", "right", "up", "down", "place"]:
		check(pack.key(action, plain) == "" and pack.selected == "", "'%s' with no elixirs does nothing" % action)
		check(pack.key(action, []) == "" and pack.selected == "", "'%s' with an empty bag does nothing" % action)

	# Keyboard cursor over the list: the first press shows it, then it steps with wrap.
	check(pack.key("down", items) == "selected" and pack.selected == "ssanghwatang", "the first key shows the cursor on the first elixir row")
	check(pack.key("down", items) == "moved" and pack.selected == "gongjindan", "down steps to the next elixir row, skipping the hint")
	check(pack.key("right", items) == "moved" and pack.selected == "ssanghwatang", "and wraps around")
	check(pack.key("left", items) == "moved" and pack.selected == "gongjindan", "left steps back, wrapping")
	check(pack.key("up", items) == "moved" and pack.selected == "ssanghwatang", "up steps back")
	check(pack.key("", items) == "", "no action, nothing happens")
	check(pack.key("place", items) == "ask" and pack.selected == "ssanghwatang", "place asks (the HUD opens the question)")

	# Preselection.
	var table := [[10, 10, 0], [4, 7, 0], [7, 4, 1], [7, 6, 1], [6, 7, 0], [1, 2, 0], [2, 1, 1], [0, 5, 0], [9, 10, 0], [10, 9, 1], [9, 9, 0], [1, 1, 0]]
	for row in table:
		check(BackpackScript.preselect(row[0], row[1]) == row[2], "Nestor %s / Fernanda %s hearts preselect %s" % [row[0] / 2.0, row[1] / 2.0, BackpackScript.CHOICES[row[2]]])
	check(pack.open_choice(8, 3) and pack.choosing and pack.choice == 1, "the question opens on the traveler with fewer hearts")
	check(pack.select("gongjindan", items) == false and pack.selected == "ssanghwatang", "while the question is up the selection can't move")
	check(pack.key("left", items) == "moved" and pack.choice == 0 and pack.key("left", items) == "moved" and pack.choice == 1, "in the question left/right switch buttons, wrapping")
	check(pack.key("down", items) == "moved" and pack.choice == 0 and pack.key("up", items) == "moved" and pack.choice == 1, "and up/down do too")
	check(pack.key("place", items) == "drink", "place in the question says drink")
	check(pack.escape() == "cancel_choice" and not pack.choosing and pack.selected == "ssanghwatang" and not pack.is_open, "Esc cancels the question and keeps the selection")
	check(pack.escape() == "", "Esc with the backpack closed does nothing")
	pack.open(true)
	pack.open_choice(10, 10)
	check(pack.escape() == "cancel_choice" and pack.is_open, "the first Esc only cancels the question")
	check(pack.escape() == "close" and not pack.is_open and pack.selected == "" and not pack.choosing, "the next Esc closes, and the selection is forgotten")
	check(BackpackScript.hearts_number(3.5) == "3.5" and BackpackScript.hearts_number(5.0) == "5" and BackpackScript.hearts_number(0.5) == "0.5", "hearts read 3.5, 5 and 0.5")

	# sync: the selection follows when its row goes.
	var bag = InventoryScript.new()
	bag.add("ssanghwatang")
	bag.add("spelling_hint")
	bag.add("gongjindan")
	pack.select("ssanghwatang", bag.items())
	bag.remove("ssanghwatang")
	pack.sync(bag.items())
	check(pack.selected == "gongjindan", "the first elixir gone: the selection moves to the next elixir")
	bag.add("ssanghwatang")
	pack.select("gongjindan", bag.items())
	bag.remove("gongjindan")
	pack.sync(bag.items())
	check(pack.selected == "ssanghwatang", "the last elixir gone: it moves to the nearest one before it")
	pack.open_choice(10, 10)
	bag.remove("ssanghwatang")
	pack.sync(bag.items())
	check(pack.selected == "" and not pack.choosing, "no elixir left: nothing selected and no question")
	pack.sync(bag.items())

	# Healing, node-free, against the real GameState.
	var cases := [
		# [item, start units, healed, wasted, message]
		["ssanghwatang", 1, 1, 0, "Fernanda drank 쌍화탕: +½ heart"],
		["ssanghwatang", 8, 1, 0, "Fernanda drank 쌍화탕: +½ heart"],
		["ssanghwatang", 9, 1, 0, "Fernanda drank 쌍화탕: +½ heart"],
		["ssanghwatang", 10, 0, 1, "Fernanda drank 쌍화탕: wasted (already full)"],
		["gongjindan", 1, 2, 0, "Fernanda drank 공진단: +1 heart"],
		["gongjindan", 8, 2, 0, "Fernanda drank 공진단: +1 heart"],
		["gongjindan", 9, 1, 1, "Fernanda drank 공진단: +½ heart (½ heart wasted)"],
		["gongjindan", 10, 0, 2, "Fernanda drank 공진단: wasted (already full)"],
	]
	for c in cases:
		GameState.new_hike()
		GameState.heart_units["fernanda"] = c[1]
		var held = InventoryScript.new()
		held.add(c[0], 3)
		var drinker = BackpackScript.new()
		drinker.select(c[0], held.items())
		var seen: Array = []
		var listener := func(who, units): seen.append([who, units])
		GameState.hearts_changed.connect(listener)
		var r: Dictionary = drinker.drink(held, "fernanda")
		GameState.hearts_changed.disconnect(listener)
		var label := "%s at %s hearts" % [c[0], c[1] / 2.0]
		check(r["ok"] and r["healed"] == c[2] and r["wasted"] == c[3] and r["nominal"] == c[2] + c[3], "%s: healed %d, wasted %d" % [label, c[2], c[3]])
		check(GameState.heart_units["fernanda"] == c[1] + c[2] and GameState.heart_units["nestor"] == 10, "%s: only Fernanda's hearts moved, to %d" % [label, c[1] + c[2]])
		check(held.count(c[0]) == 2, "%s: exactly one is consumed (even when wasted)" % label)
		check(BackpackScript.message_for(r, words) == c[4], "%s: the message reads '%s' (%s)" % [label, c[4], BackpackScript.message_for(r, words)])
		check(not drinker.choosing, "%s: the question is closed" % label)
		check(seen.size() == 1 and seen[0][0] == "fernanda", "%s: GameState.heal() announced one change" % label)
	GameState.new_hike()
	GameState.heart_units["nestor"] = 3
	var many = InventoryScript.new()
	many.add("gongjindan", 2)
	var again = BackpackScript.new()
	again.select("gongjindan", many.items())
	var first: Dictionary = again.drink(many, "nestor")
	var second: Dictionary = again.drink(many, "nestor")
	check(first["ok"] and second["ok"] and first["healed"] == 2 and second["healed"] == 2 and many.is_empty() and GameState.heart_units["nestor"] == 7, "Nestor can drink too, as often as there are elixirs (3 + 2 + 2 half-hearts)")
	var gone: Dictionary = again.drink(many, "nestor")
	check(not gone["ok"] and GameState.heart_units["nestor"] == 7, "with none left nothing is drunk")
	var held = InventoryScript.new()
	held.add("ssanghwatang")
	GameState.heart_units["nestor"] = 0
	again.reset()
	again.select("ssanghwatang", held.items())
	check(not again.drink(held, "nestor")["ok"] and held.count("ssanghwatang") == 1 and GameState.heart_units["nestor"] == 0, "a dead traveler can't drink: nothing is consumed")
	var unselected = BackpackScript.new()
	check(not unselected.drink(held, "fernanda")["ok"] and held.count("ssanghwatang") == 1, "with no selection nothing is drunk")
	var cur = BackpackScript.new()
	held.add("ddeok")
	check(not cur.select("ddeok", held.items()) and not cur.drink(held, "fernanda")["ok"] and held.count("ddeok") == 1, "DDEOK can't be drunk")
	again.select("ssanghwatang", held.items())
	check(not again.drink(held, "stranger")["ok"] and held.count("ssanghwatang") == 1, "an unknown traveler can't drink")
	GameState.new_hike()

	# Amounts and the message timer.
	check(BackpackScript.amount_text(1, words) == "½ heart" and BackpackScript.amount_text(2, words) == "1 heart" and BackpackScript.amount_text(3, words) == "1½ hearts" and BackpackScript.amount_text(4, words) == "2 hearts", "amounts read ½ heart, 1 heart, 1½ hearts, 2 hearts")
	var timed = BackpackScript.new()
	timed.set_message("hello", 4.0)
	timed.tick(3.9)
	check(timed.message == "hello", "the message is still there before its time")
	timed.tick(0.2)
	check(timed.message == "" and timed.message_left == 0.0, "and gone after it")
	timed.tick(1.0)
	_section_done("test_drink_logic")


func test_drink_scene() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _drink_map({"ssanghwatang": 2, "gongjindan": 1, "spelling_hint": 1, "ddeok": 3}, 10, 6)
	var viewport := map.get_viewport()
	var hud = map.backpack_hud
	var pack = map.backpack
	var config: Dictionary = _config()["backpack_hud"]
	var held: Dictionary = GameState.inventory.snapshot()
	_tap(viewport, KEY_TAB)
	await _settle_layout()
	check(pack.is_open and hud.row_count() == 4 and hud.row_id(0) == "ssanghwatang" and hud.row_id(2) == "spelling_hint", "(setup) four rows are on screen")
	var none_selected := true
	for i in 4:
		none_selected = none_selected and not hud.row_selected(i)
	check(none_selected and not hud.choice_visible() and hud.message_text() == "", "at first nothing is highlighted, no question, no message")

	# Rows that are not elixirs ignore clicks.
	for i in [2, 3]:
		_click_at(viewport, hud.row_rect(i).get_center())
		await _settle_layout()
	check(pack.selected == "" and not pack.choosing and not hud.choice_visible() and not hud.row_selected(2) and not hud.row_selected(3), "clicking the hint or DDEOK row selects nothing and shows no highlight")
	check(hud._rows.get_child(2).mouse_filter == Control.MOUSE_FILTER_IGNORE and hud._rows.get_child(0).mouse_filter == Control.MOUSE_FILTER_STOP, "only elixir rows take mouse clicks")

	# A click selects and asks, with the weaker traveler picked.
	_click_at(viewport, hud.row_rect(0).get_center())
	await _settle_layout()
	check(pack.selected == "ssanghwatang" and hud.row_selected(0) and not hud.row_selected(1), "a click on an elixir row selects it and highlights it")
	var style: StyleBoxFlat = hud._rows.get_child(0).get_theme_stylebox("panel")
	check(style.bg_color.is_equal_approx(_data_color(config["selected_row_color"])) and style.border_width_left == int(config["selected_border_width"]) and style.border_color.is_equal_approx(_data_color(config["selected_border_color"])), "the highlight uses the data's colours and border width")
	var plain: StyleBoxFlat = hud._rows.get_child(1).get_theme_stylebox("panel")
	check(plain.border_width_left == 0 and plain.content_margin_left == float(config["row_padding"]), "other rows have no border and the data's padding")
	check(pack.choosing and hud.choice_visible() and hud.choice_prompt_text() == "Who drinks 쌍화탕?", "and opens the question (%s)" % hud.choice_prompt_text())
	check(hud.choice_button(0).text == "Nestor  5 / 5" and hud.choice_button(1).text == "Fernanda  3 / 5", "the buttons show each traveler's hearts (%s | %s)" % [hud.choice_button(0).text, hud.choice_button(1).text])
	check(pack.choice == 1, "Fernanda (fewer hearts) is preselected")
	var hi: StyleBoxFlat = hud.choice_button(1).get_theme_stylebox("normal")
	var lo: StyleBoxFlat = hud.choice_button(0).get_theme_stylebox("normal")
	check(hi.border_width_left > 0 and lo.border_width_left == 0 and hi.bg_color != lo.bg_color, "the preselected button looks different")
	check(hud.panel_rect().encloses(hud.choice_button(0).get_global_rect()) and hud.panel_rect().encloses(hud.choice_button(1).get_global_rect()), "the question is inside the backpack panel")
	check(not map.open_pause_menu() and not map.pause_menu.is_open, "the pause menu can't open over the question")
	check(GameState.inventory.snapshot() == held, "asking drinks nothing")

	# Esc layering: one Esc, one thing.
	_tap(viewport, KEY_ESCAPE)
	await get_tree().process_frame
	check(not pack.choosing and not hud.choice_visible() and pack.selected == "ssanghwatang" and hud.row_selected(0), "the first Esc cancels the question and keeps the selection")
	check(pack.is_open and get_tree().paused and not map.pause_menu.is_open, "and the backpack is still open, the pause menu still shut")
	_tap(viewport, KEY_ESCAPE)
	await get_tree().process_frame
	check(not pack.is_open and not get_tree().paused and not map.pause_menu.is_open, "the second Esc closes the backpack and nothing else")
	_tap(viewport, KEY_ESCAPE)
	check(map.pause_menu.is_open, "the third Esc opens the pause menu as before")
	_tap(viewport, KEY_ESCAPE)
	check(not map.pause_menu.is_open and not get_tree().paused, "(setup) and the next one resumes")
	check(GameState.inventory.snapshot() == held and GameState.heart_units["fernanda"] == 6, "none of it drank anything")

	# A real click on a button drinks.
	_tap(viewport, KEY_TAB)
	await _settle_layout()
	check(pack.selected == "" and not hud.row_selected(0), "reopened: the selection did not survive the close")
	_click_at(viewport, hud.row_rect(0).get_center())
	await _settle_layout()
	var labels_before: int = map.find_children("*", "Label3D", true, false).size()
	_click_at(viewport, hud.choice_button(1).get_global_rect().get_center())
	await _settle_layout()
	check(GameState.heart_units["fernanda"] == 7 and GameState.heart_units["nestor"] == 10, "(real click) the Fernanda button heals Fernanda by half a heart")
	check(GameState.inventory.count("ssanghwatang") == 1 and GameState.inventory.count("gongjindan") == 1, "exactly one 쌍화탕 is gone")
	check(hud.message_text() == "Fernanda drank 쌍화탕: +½ heart", "the panel says so (%s)" % hud.message_text())
	check(pack.is_open and hud.panel_visible() and not hud.choice_visible() and not pack.choosing, "the panel stays open and the question closes")
	check(hud.row_label(0, "Count").text == "×1", "the row shows the new count")
	check(_hearts_drawn_ok(map), "the hearts HUD shows the new hearts while the backpack is open")
	check(pack.selected == "ssanghwatang" and hud.row_selected(0), "the drunk row stays selected while any are left")
	check(map.find_children("*", "Label3D", true, false).size() == labels_before, "no floating label is added to the world")

	# Wasted on a full traveler; the last one in the row disappears.
	_click_at(viewport, hud.row_rect(0).get_center())
	await _settle_layout()
	check(hud.choice_button(1).text == "Fernanda  3.5 / 5" and pack.choice == 1, "the question shows 3.5 / 5 and still prefers the weaker traveler")
	_click_at(viewport, hud.choice_button(0).get_global_rect().get_center())
	await _settle_layout()
	check(hud.message_text() == "Nestor drank 쌍화탕: wasted (already full)" and GameState.heart_units["nestor"] == 10, "(real click) Nestor at full hearts: wasted, and the message says so")
	check(GameState.inventory.count("ssanghwatang") == 0 and hud.row_count() == 3 and hud.row_id(0) == "gongjindan", "the row at count 0 is gone")
	check(pack.selected == "gongjindan" and hud.row_selected(0), "and the selection moved to the nearest elixir row")
	check(hud._message.get_theme_color("font_color").is_equal_approx(_data_color(config["message_wasted_color"])), "a wasted message uses the wasted colour")
	pack.tick(float(config["message_seconds"]) - 0.1)
	hud.refresh()
	check(hud.message_text() != "", "the message is still visible just before its time")
	pack.tick(0.2)
	hud.refresh()
	check(hud.message_text() == "", "and gone after message_seconds")

	# The last elixir leaves nothing selected.
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(pack.choosing, "(keyboard) Space on the selected row asks")
	_tap(viewport, KEY_D)
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(GameState.inventory.count("gongjindan") == 0 and hud.row_count() == 2 and pack.selected == "" and not pack.choosing, "the last elixir drunk: its row goes, nothing is selected, no question")
	check(hud.message_text().begins_with("Nestor drank 공진단") or hud.message_text().begins_with("Fernanda drank 공진단"), "with a message (%s)" % hud.message_text())
	var snapshot_left: Dictionary = GameState.inventory.snapshot()
	_tap(viewport, KEY_S)
	_tap(viewport, KEY_SPACE)
	check(pack.selected == "" and not pack.choosing and GameState.inventory.snapshot() == snapshot_left, "with no elixirs the keys do nothing: the panel behaves as before")
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not get_tree().paused and _hearts_drawn_ok(map), "closed: the hearts HUD still shows the hearts")
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_drink_scene")


func test_drink_input() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var map: Node3D = await _drink_map({"ssanghwatang": 2, "spelling_hint": 1, "gongjindan": 2, "ddeok": 1}, 10, 8)
	var viewport := map.get_viewport()
	var hud = map.backpack_hud
	var pack = map.backpack
	_tap(viewport, KEY_TAB)
	await _settle_layout()
	# Player 1: W A S D and Space.
	_tap(viewport, KEY_S)
	check(pack.selected == "ssanghwatang" and hud.row_selected(0) and not pack.choosing, "P1: the first S shows the cursor on the first elixir row")
	_tap(viewport, KEY_S)
	check(pack.selected == "gongjindan" and hud.row_selected(2), "P1: S moves to the next elixir row, past the hint")
	_tap(viewport, KEY_W)
	check(pack.selected == "ssanghwatang", "P1: W moves back")
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(pack.choosing and pack.choice == 1 and hud.choice_visible(), "P1: Space opens the question, Fernanda (4 / 5) preselected")
	_tap(viewport, KEY_A)
	check(pack.choice == 0, "P1: A moves to Nestor")
	_tap(viewport, KEY_D)
	check(pack.choice == 1, "P1: D moves to Fernanda")
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(GameState.heart_units["fernanda"] == 9 and GameState.inventory.count("ssanghwatang") == 1 and not pack.choosing, "P1: Space drinks: Fernanda 4 -> 4.5 hearts, one 쌍화탕 gone")
	check(hud.message_text() == "Fernanda drank 쌍화탕: +½ heart", "P1: the message shows (%s)" % hud.message_text())
	# Player 2: arrows and Enter, on the same panel.
	_tap(viewport, KEY_DOWN)
	check(pack.selected == "gongjindan", "P2: Down moves the cursor")
	_tap(viewport, KEY_UP)
	check(pack.selected == "ssanghwatang", "P2: Up moves the cursor")
	_tap(viewport, KEY_DOWN)
	_tap(viewport, KEY_ENTER)
	await _settle_layout()
	check(pack.choosing and pack.selected == "gongjindan" and pack.choice == 1, "P2: Enter opens the question on 공진단")
	_tap(viewport, KEY_LEFT)
	check(pack.choice == 0, "P2: Left moves to Nestor")
	_tap(viewport, KEY_RIGHT)
	check(pack.choice == 1, "P2: Right moves to Fernanda")
	_tap(viewport, KEY_LEFT)
	_tap(viewport, KEY_ENTER)
	await _settle_layout()
	check(GameState.heart_units["nestor"] == 10 and GameState.inventory.count("gongjindan") == 1, "P2: Enter drinks for Nestor, who is full: the 공진단 is wasted but gone")
	check(hud.message_text() == "Nestor drank 공진단: wasted (already full)", "P2: the wasted message shows (%s)" % hud.message_text())
	# Esc layering by keyboard, and the toggle keys.
	_tap(viewport, KEY_SPACE)
	await _settle_layout()
	check(pack.choosing, "(setup) the question is up again")
	_tap(viewport, KEY_ESCAPE)
	check(not pack.choosing and pack.is_open and pack.selected == "gongjindan", "Esc: question gone, backpack open, selection kept")
	_tap(viewport, KEY_SPACE)
	_tap(viewport, KEY_TAB)
	check(not pack.is_open and not pack.choosing and pack.selected == "" and not get_tree().paused, "Tab with the question up closes the backpack and clears the state")
	for opener in [[KEY_TAB, 0, "Tab"], [KEY_SHIFT, 2, "right Shift"], [KEY_CTRL, 2, "right Ctrl"]]:
		_tap(viewport, opener[0], opener[1])
		check(pack.is_open and get_tree().paused, "%s still opens the backpack" % opener[2])
		_tap(viewport, KEY_S)
		_tap(viewport, KEY_SPACE)
		check(pack.choosing, "(setup) %s: the question is up" % opener[2])
		_tap(viewport, opener[0], opener[1])
		check(not pack.is_open and not get_tree().paused and not pack.choosing and pack.selected == "", "%s still closes it, even with the question up" % opener[2])
	_tap(viewport, KEY_ESCAPE)
	check(map.pause_menu.is_open and not pack.is_open, "with the backpack closed Esc opens the pause menu")
	_tap(viewport, KEY_ESCAPE)
	# An elixir-free backpack: the movement keys are not taken.
	GameState.inventory.clear()
	GameState.inventory.add("ddeok", 2)
	_tap(viewport, KEY_TAB)
	_tap(viewport, KEY_S)
	_tap(viewport, KEY_DOWN)
	_tap(viewport, KEY_SPACE)
	_tap(viewport, KEY_ENTER)
	check(pack.is_open and pack.selected == "" and not pack.choosing and GameState.inventory.count("ddeok") == 2, "with only DDEOK nothing can be selected or drunk")
	_tap(viewport, KEY_TAB)
	map.free()
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_drink_input")


func test_drink_restart() -> void:
	# Restart scene.
	var map: Node3D = await _drink_map({"ssanghwatang": 2, "gongjindan": 1}, 10, 6)
	var held: Dictionary = GameState.inventory.snapshot()
	check(map.open_backpack(), "(setup) the backpack is open")
	map.backpack.select("ssanghwatang", GameState.inventory.items())
	map.backpack_hud._ask()
	map.backpack_hud.drink_chosen()
	check(GameState.heart_units["fernanda"] == 7 and GameState.inventory.count("ssanghwatang") == 1 and map.backpack_hud.message_text() != "", "(setup) a drink: Fernanda 3.5 hearts, one 쌍화탕 left, a message up")
	map.backpack.select("gongjindan", GameState.inventory.items())
	map.backpack_hud._ask()
	check(map.backpack.choosing and map.backpack.selected == "gongjindan", "(setup) and a question is pending")
	check(map.close_backpack() and not map.backpack.choosing and map.backpack.selected == "" and map.backpack.message == "", "closing clears the selection, the question and the message")
	check(map.open_pause_menu(), "(setup) the pause menu is open")
	map.pause_hud.choose(1)
	map.pause_hud.choose(0)
	check(map.pause_menu.restart_requests == 1, "(setup) Restart scene was confirmed")
	check(GameState.heart_units["fernanda"] == 6 and GameState.heart_units["nestor"] == 10 and GameState.inventory.snapshot() == held, "Restart scene: hearts and backpack are the scene-start values")
	check(map.backpack.selected == "" and not map.backpack.choosing and map.backpack.message == "" and not map.backpack_hud.choice_visible() and map.backpack_hud.message_text() == "", "no selection, question or message is left")
	map.free()
	get_tree().paused = false
	# A death with a question pending.
	map = await _drink_map({"ssanghwatang": 2, "gongjindan": 1}, 10, 6)
	held = GameState.inventory.snapshot()
	check(map.open_backpack(), "(setup) the backpack is open again")
	map.backpack.select("gongjindan", GameState.inventory.items())
	map.backpack_hud._ask()
	map.backpack_hud.drink_chosen()
	map.backpack.select("ssanghwatang", GameState.inventory.items())
	map.backpack_hud._ask()
	check(GameState.heart_units["fernanda"] == 8 and map.backpack.choosing and map.backpack.message != "", "(setup) 공진단 drunk (Fernanda 4 hearts) and a new question is pending")
	map.begin_death_beat()
	map.tick_beat(100.0)
	check(GameState.heart_units["fernanda"] == 6 and GameState.heart_units["nestor"] == 10 and GameState.inventory.snapshot() == held, "death: hearts and backpack are the scene-start values")
	check(map.backpack.selected == "" and not map.backpack.choosing and map.backpack.message == "" and not map.backpack_hud.choice_visible() and map.backpack_hud.message_text() == "", "death: no selection, question or message is left")
	check(_hearts_drawn_ok(map), "the hearts HUD shows the restored hearts")
	map.free()
	get_tree().paused = false
	# A second scene starts clean.
	map = await _drink_map({"gongjindan": 1}, 10, 6)
	check(map.backpack.selected == "" and not map.backpack.choosing and map.backpack.message == "", "a new scene starts with no selection, question or message")
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_drink_restart")


# ---- Prompt 7d: random decoy placement and chaos DDEOK piles ----

const DecoyPlacementScript := preload("res://scenes/foraging/decoy_placement.gd")
const ChaosPilesScript := preload("res://scenes/foraging/chaos_piles.gd")
const DECOY_KIND_IDS: Array[String] = ["keuncheonnamseong", "butsunnamu", "norugui", "deulchuknamu"]
const LAYOUT_SEEDS := 1500       # pinned seeds the layout tests run over
const PROP_FOOTPRINT := 0.6      # metres of clear ground a plant or pile keeps from a prop's box
const LETTER_HEIGHT := 1.5       # the height the camera must see a plant's letter at
const SAMPLE_STARTS := 20000     # scene starts the proportion tests roll
const PROPORTION_TOLERANCE := 0.015  # absolute, on a probability (about 4 standard deviations at this sample size)


func _vec(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


func _target_spots() -> Array[Vector2]:
	var targets := {}
	for kind in _hangul_plants():
		if kind["kind"] == "target":
			targets[kind["id"]] = true
	var spots: Array[Vector2] = []
	for entry in _placed():
		if targets.has(entry["kind"]):
			spots.append(Vector2(float(entry["x"]), float(entry["z"])))
	return spots


func _spare_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = []
	for id in _config()["spares"]["slots"]:
		spots.append(_vec(_config()["spares"]["slots"][id]))
	return spots


func _tree_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = []
	for pos in _config()["scenery"]["gusangnamu"]["positions"]:
		spots.append(_vec(pos))
	return spots


func _start_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = []
	for id in _config()["start"]:
		spots.append(_vec(_config()["start"][id]))
	return spots


func _fixed_spots() -> Array[Vector2]:
	var spots := _target_spots()
	spots.append_array(_spare_spots())
	return spots


func _new_placement(config: Dictionary = {}) -> RefCounted:
	var cfg := _config()
	return DecoyPlacementScript.new(cfg["decoy_placement"] if config.is_empty() else config, cfg["plants"]["kinds"], cfg["plants"]["placed"], _fixed_spots(), _tree_spots(), _start_spots(), float(cfg["stage"]["depth"]) / 2.0, float(cfg["stage"]["width"]), _allowed_letters())


func _new_piles(config: Dictionary = {}, placement: RefCounted = null) -> RefCounted:
	var cfg := _config()
	var source: RefCounted = _new_placement() if placement == null else placement
	return ChaosPilesScript.new(cfg["chaos_piles"] if config.is_empty() else config, _target_spots(), _fixed_spots(), source.slots, _tree_spots(), _start_spots(), cfg["zones"], float(cfg["stage"]["depth"]) / 2.0, Content.items)


## What a scene start with this seed rolls, worked out without a scene: the decoy layout, foraging.plants
## with the decoys in place, every plant's (x, z) and the piles.
func _offline_roll(seed_value: int, placement: RefCounted, piles: RefCounted) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var layout: Dictionary = placement.choose(rng)
	var pile_rng := RandomNumberGenerator.new()
	pile_rng.seed = DecoyPlacementScript.derive_seed(seed_value, 1)
	var resolved: Dictionary = placement.apply(_config()["plants"], layout["decoys"])
	var spots: Array[Vector2] = []
	for entry in resolved["placed"]:
		spots.append(Vector2(float(entry["x"]), float(entry["z"])))
	return {"layout": layout, "resolved": resolved, "spots": spots, "piles": piles.roll(pile_rng, spots, _start_spots())}


## The decoys of a layout as one comparable value: kind, spot, outcome and letter, in order.
func _layout_key(decoys: Array) -> String:
	var parts: Array[String] = []
	for d in decoys:
		parts.append("%s@%.2f,%.2f:%s:%s" % [d["kind"], d["spot"].x, d["spot"].y, d["outcome"], d["letter"]])
	return "|".join(parts)


## A map built with a pinned placement seed (the 7d sections run with the legacy layout off).
func _seeded_map(seed_value: int, held := {}, controlled := "fernanda") -> Node3D:
	GameState.new_hike()
	for id in held:
		GameState.inventory.add(id, held[id])
	GameState.controlled = controlled
	Foraging.legacy_layout = false
	Foraging.seed_override = seed_value
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	Foraging.seed_override = -1
	map.set_physics_process(false)
	map.set_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return map


func _prop_boxes(map: Node3D) -> Array:
	var boxes := []
	for holder in ["Props", "Scenery"]:
		for node in map.get_node(holder).get_children():
			boxes.append(node.bounds)
	return boxes


func _footprint_hit(spot: Vector2, boxes: Array) -> bool:
	for box: AABB in boxes:
		if Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(PROP_FOOTPRINT).has_point(spot):
			return true
	return false


func _nearest_distance(spot: Vector2, others: Array) -> float:
	var best := INF
	for other: Vector2 in others:
		best = minf(best, spot.distance_to(other))
	return best


## The first plant of `kind_id` whose rolled outcome is `outcome`, or null.
func _decoy_of(map: Node3D, kind_id: String, outcome: String) -> Node3D:
	for plant in map.plants:
		if plant.kind_id == kind_id and plant.outcome == outcome:
			return plant
	return null


## The first seed whose roll has a decoy of `kind_id` with `outcome`, or -1.
func _seed_with_decoy(kind_id: String, outcome: String) -> int:
	var placement := _new_placement()
	var rng := RandomNumberGenerator.new()
	for seed_value in range(1, 3000):
		rng.seed = seed_value
		for d in placement.choose(rng)["decoys"]:
			if d["kind"] == kind_id and d["outcome"] == outcome:
				return seed_value
	return -1


func test_placement_data() -> void:
	var cfg := _config()
	var place: Dictionary = cfg.get("decoy_placement", {})
	var chaos: Dictionary = cfg.get("chaos_piles", {})
	check(not place.is_empty() and not chaos.is_empty(), "hallasan.json has decoy_placement and chaos_piles")
	var placement := _new_placement()
	check(placement.is_valid(), "the decoy placement data passes its own validation (%s)" % placement.problem)
	check(not place.has("pools") and not place.has("same_kind_min"), "the per-kind pools and the same-kind spacing rule are gone from the data")
	check(place["any_min"] == 2.0 and place["start_min"] == 6.0 and place["scenery_min"] == 2.5, "the spacing rules: 2 m from any plant or decoy, 6 m from the starts, 2.5 m from trees")
	check(place["slots"].size() == 24 and placement.slots.size() == 24, "one shared pool of 24 slots (the four old pools of 6, merged)")
	check(int(place["count_min"]) == 2 and int(place["count_max"]) == 16 and int(place["count_max"]) <= place["slots"].size(), "count_min 2, count_max 16, and not more than the slots")
	check(place["kind_weights"].size() == 4 and DECOY_KIND_IDS.all(func(id): return int(place["kind_weights"].get(id, 0)) == 1), "kind_weights: 1 for each of the four decoy kinds, and no other")
	check(place["outcome_weights"].size() == 2 and int(place["outcome_weights"]["harm"]) == 1 and int(place["outcome_weights"]["reward"]) == 1, "outcome_weights: harm 1, reward 1")
	check(int(place["damage_units"]) == 1, "one damage_units value for every harm outcome: 1 (half a heart)")
	# The decoy kinds: one role, one gore id each, no per-kind damage.
	var gore_of := {"keuncheonnamseong": "face_swell_pop", "butsunnamu": "convulse_eyes_pop", "norugui": "deer_ears_rip", "deulchuknamu": "deulssuk_drunk"}
	var kinds_ok := true
	for kind in _hangul_plants():
		if gore_of.has(kind["id"]):
			kinds_ok = kinds_ok and kind["kind"] == "decoy" and kind["gore"] == gore_of[kind["id"]] and kind.has("injury") and not kind.has("damage_units")
	check(kinds_ok, "the four decoy kinds are kind 'decoy' with their own gore id and no fixed harm or reward role")
	check(cfg["zones"].size() == 3 and _hangul_plants().all(func(k): return k["kind"] != "decoy" or k.has("zone")), "the zone data is kept (and the decoy kinds' zone fields), though placement reads none of it")
	# Every pair of slots in the merged pool is at least 2 m apart.
	var spots: Array[Vector2] = []
	for slot in place["slots"]:
		spots.append(_vec(slot))
	var closest := INF
	var distinct := {}
	for i in spots.size():
		distinct[spots[i]] = true
		for j in range(i + 1, spots.size()):
			closest = minf(closest, spots[i].distance_to(spots[j]))
	print("  closest pair of the %d merged slots: %.2f m, none dropped" % [spots.size(), closest])
	check(distinct.size() == spots.size(), "no slot appears twice")
	check(closest >= 2.0, "every pair of slots is at least 2 m apart (the closest pair is %.2f m)" % closest)
	# Every slot against the live scene.
	var map: Node3D = await _seeded_map(1)
	var boxes := _prop_boxes(map)
	var half_depth: float = map.stage_depth / 2.0
	var bounds: Rect2 = map.walk_bounds()
	var on_stage := true
	var walkable := true
	var clear := true
	var far := true
	var props_ok := true
	var seen_ok := true
	var hidden := []
	var low := INF
	var high := -INF
	var in_zone := {}
	for spot in spots:
		on_stage = on_stage and spot.x >= 1.0 and spot.x <= map.stage_width - 1.0 and absf(spot.y) <= half_depth - 1.0
		walkable = walkable and bounds.has_point(spot) and spot.y <= map.near_limit_at(spot.x) - 0.5
		clear = clear and _nearest_distance(spot, _fixed_spots()) >= 2.0 and _nearest_distance(spot, _tree_spots()) >= 2.5
		far = far and _nearest_distance(spot, _start_spots()) >= 6.0
		props_ok = props_ok and not _footprint_hit(spot, boxes)
		if DecoyPlacementScript.blocked_by_prop(spot, map.terrain.height_at(spot.x), boxes, map.CAMERA_PITCH_DEG, PROP_FOOTPRINT, LETTER_HEIGHT, map.FADE_REACH):
			seen_ok = false
			hidden.append(spot)
		low = minf(low, spot.x)
		high = maxf(high, spot.x)
		var zone_id: String = map.zone_at(spot.x)["id"]
		in_zone[zone_id] = int(in_zone.get(zone_id, 0)) + 1
	check(on_stage, "every slot is on the stage, 1 m from its edges")
	check(walkable, "every slot is on walkable ground, inside the walk limits and the camera clamp")
	check(clear, "every slot is 2 m from every target plant and spare slot and 2.5 m from every tree")
	check(far, "every slot is 6 m from the starts")
	check(props_ok, "no slot is inside or under a prop (box plus %.1f m)" % PROP_FOOTPRINT)
	check(seen_ok, "no prop box stands between the camera and a slot's letter %s" % str(hidden))
	check(high - low >= 0.6 * map.stage_width, "the shared pool is spread over the stage (%.1f m across)" % (high - low))
	print("  slots per old zone: %s" % str(in_zone))
	check(in_zone.size() == 3 and in_zone.values().all(func(n): return n >= 6), "all three zones have at least 6 slots, so any kind can stand anywhere")
	# The fallback (the decoys' own kinds, letters and x, z in 'placed') is itself a valid layout.
	var fallback: Array = placement.fallback_decoys({}, ForcedRng.new())
	check(fallback.size() == 8 and placement.layout_problem(fallback) == "", "the fallback layout (8 decoys) obeys the spacing rules (%s)" % placement.layout_problem(fallback))
	var fallback_ok := true
	for d in fallback:
		fallback_ok = fallback_ok and _nearest_distance(d["spot"], _fixed_spots()) >= 2.0 and _nearest_distance(d["spot"], _start_spots()) >= 6.0
	check(fallback_ok, "the fallback positions are clear of the fixed plants, spare slots and starts")

	# Chaos pile slots (their own 12, unchanged), now against the merged decoy slots.
	var piles := _new_piles()
	check(piles.is_valid(), "the chaos pile data passes its own validation (%s)" % piles.problem)
	var pile_slots: Array[Vector2] = []
	for slot in chaos["slots"]:
		pile_slots.append(_vec(slot))
	check(pile_slots.size() == 12, "12 candidate pile slots")
	var zone_hit := {}
	var pile_walkable := true
	var pile_clear := true
	var pile_props := true
	var pile_seen := true
	var pile_hidden := []
	var off_path := 0
	for spot in pile_slots:
		zone_hit[map.zone_at(spot.x)["id"]] = true
		pile_walkable = pile_walkable and bounds.has_point(spot) and spot.y <= map.near_limit_at(spot.x) - 0.5 and absf(spot.y) <= half_depth - 1.0
		pile_clear = pile_clear and _nearest_distance(spot, _fixed_spots()) >= 2.0 and _nearest_distance(spot, spots) >= 2.0 and _nearest_distance(spot, _start_spots()) >= 6.0 and _nearest_distance(spot, _tree_spots()) >= 2.5
		pile_props = pile_props and not _footprint_hit(spot, boxes)
		if DecoyPlacementScript.blocked_by_prop(spot, map.terrain.height_at(spot.x), boxes, map.CAMERA_PITCH_DEG, PROP_FOOTPRINT, LETTER_HEIGHT, map.FADE_REACH):
			pile_seen = false
			pile_hidden.append(spot)
		if _nearest_distance(spot, _target_spots()) >= 8.0:
			off_path += 1
	check(zone_hit.size() == 3, "the pile slots cover all three zones (%s)" % str(zone_hit.keys()))
	check(pile_walkable, "every pile slot is on walkable ground inside the walk limits and the camera clamp")
	check(pile_clear, "every pile slot is 2 m from every target, spare slot and (merged) decoy slot, 6 m from the starts and 2.5 m from trees")
	check(pile_props, "no pile slot is inside or under a prop (box plus %.1f m)" % PROP_FOOTPRINT)
	check(pile_seen, "no prop box stands between the camera and a pile slot %s" % str(pile_hidden))
	check(off_path >= 4, "at least 4 pile slots are 8 m from every target plant (%d)" % off_path)
	var apart_ok := true
	for i in pile_slots.size():
		for j in range(i + 1, pile_slots.size()):
			apart_ok = apart_ok and pile_slots[i].distance_to(pile_slots[j]) >= 2.0
	check(apart_ok, "pile slots are at least 2 m apart")
	var counts_got: Array = chaos["count_table"].map(func(e): return [int(e["count"]), int(e["weight"])])
	var amounts_got: Array = chaos["amount_table"].map(func(e): return [int(e["amount"]), int(e["weight"])])
	check(counts_got == [[0, 3], [1, 4], [2, 2], [3, 1]], "count_table is 0:3, 1:4, 2:2, 3:1")
	check(amounts_got == [[1, 10], [2, 4], [3, 2], [10, 1]], "amount_table is 1:10, 2:4, 3:2, 10:1")
	check(chaos["item"] == "ddeok" and Content.has_item("ddeok"), "piles hold the ddeok item")
	map.free()
	GameState.new_hike()
	_section_done("test_placement_data")


func test_placement_logic() -> void:
	var placement := _new_placement()
	var piles := _new_piles()
	check(placement.is_valid() and piles.is_valid(), "(setup) the data is valid")
	var jamo := _allowed_letters()
	var all_ok := true
	var count_ok := true
	var in_pool_ok := true
	var source_ok := true
	var fields_ok := true
	var piles_clear := true
	var distinct := {}
	var repeat_ok := true
	var starts := _start_spots()
	for seed_value in LAYOUT_SEEDS:
		var roll := _offline_roll(seed_value, placement, piles)
		var layout: Dictionary = roll["layout"]
		var decoys: Array = layout["decoys"]
		source_ok = source_ok and layout["source"] == "random"
		all_ok = all_ok and placement.layout_problem(decoys) == ""
		count_ok = count_ok and decoys.size() >= 2 and decoys.size() <= 16
		for d in decoys:
			in_pool_ok = in_pool_ok and placement.slots.has(d["spot"]) and _nearest_distance(d["spot"], starts) >= 6.0 and _nearest_distance(d["spot"], _fixed_spots()) >= 2.0
			fields_ok = fields_ok and DECOY_KIND_IDS.has(d["kind"]) and ["harm", "reward"].has(d["outcome"]) and jamo.has(d["letter"])
		for pile in roll["piles"]:
			piles_clear = piles_clear and _nearest_distance(pile["spot"], roll["spots"]) >= 2.0
		distinct[_layout_key(decoys)] = true
		var again := _offline_roll(seed_value, placement, piles)
		repeat_ok = repeat_ok and _layout_key(again["layout"]["decoys"]) == _layout_key(decoys) and str(again["piles"]) == str(roll["piles"])
	check(all_ok, "%d pinned seeds: every layout obeys the spacing rules" % LAYOUT_SEEDS)
	check(count_ok and in_pool_ok and source_ok, "%d pinned seeds: 2 to 16 decoys, on distinct shared slots, clear of fixed plants and starts, without the fallback" % LAYOUT_SEEDS)
	check(fields_ok, "%d pinned seeds: every decoy has a decoy kind, an outcome of harm or reward and a letter from the target words" % LAYOUT_SEEDS)
	check(piles_clear, "%d pinned seeds: every pile keeps 2 m from every chosen decoy" % LAYOUT_SEEDS)
	check(repeat_ok, "the same seed gives the same count, kinds, slots, outcomes, letters and piles")
	print("  %d distinct decoy layouts in %d pinned seeds" % [distinct.size(), LAYOUT_SEEDS])
	check(distinct.size() >= int(LAYOUT_SEEDS * 0.9), "different seeds give different layouts (%d distinct of %d)" % [distinct.size(), LAYOUT_SEEDS])
	var uses := {}
	var rng := RandomNumberGenerator.new()
	for seed_value in 400:
		rng.seed = seed_value
		for d in placement.choose(rng)["decoys"]:
			uses[d["spot"]] = true
	check(uses.size() == 24, "every one of the 24 shared slots gets used (%d)" % uses.size())

	# The assembled plants: targets exactly as the data has them, decoys filling the data's decoy entries in order.
	var kinds := {}
	for kind in _hangul_plants():
		kinds[kind["id"]] = kind
	var data_placed: Array = _placed()
	var data_targets: Array = data_placed.filter(func(e): return kinds[e["kind"]]["kind"] == "target")
	var decoy_index: Array = []
	for i in data_placed.size():
		if kinds[data_placed[i]["kind"]]["kind"] == "decoy":
			decoy_index.append(i)
	check(data_targets.size() == 28 and decoy_index.size() == 8, "(setup) the data has 28 targets and 8 fallback decoys")
	var some: Array = _offline_roll(7, placement, piles)["layout"]["decoys"]
	for n in [3, 8, 11]:
		var decoys: Array = some.slice(0, n) if n <= some.size() else some + some.slice(0, n - some.size())
		var resolved: Dictionary = placement.apply(_config()["plants"], decoys)
		var got_targets: Array = resolved["placed"].filter(func(e): return kinds[e["kind"]]["kind"] == "target")
		var got_decoys: Array = resolved["placed"].filter(func(e): return kinds[e["kind"]]["kind"] == "decoy")
		var shape_ok: bool = got_targets == data_targets and got_decoys.size() == n and resolved["placed"].size() == 28 + n
		for i in n:
			shape_ok = shape_ok and got_decoys[i]["kind"] == decoys[i]["kind"] and got_decoys[i]["letter"] == decoys[i]["letter"] and got_decoys[i]["outcome"] == decoys[i]["outcome"] and is_equal_approx(got_decoys[i]["x"], decoys[i]["spot"].x)
		check(shape_ok, "apply() with %d decoys: the 28 targets are untouched and in order, and the %d decoys are there with their rolled kind, letter, outcome and place" % [n, n])
		if n <= 8:
			var in_order := true
			for i in n:
				in_order = in_order and resolved["placed"][decoy_index[i]]["outcome"] == decoys[i]["outcome"]
			check(in_order, "apply() with %d decoys: they fill the data's decoy entries in order" % n)
	check(_placed().size() == 36 and _placed()[22]["kind"] == "keuncheonnamseong" and _placed()[22]["x"] == 13.0 and not _placed()[22].has("outcome"), "the data itself is not changed by apply()")

	# The fallback.
	var forced_layout: Dictionary = placement.choose(ForcedRng.new())
	check(forced_layout["source"] == "random" and placement.layout_problem(forced_layout["decoys"]) == "" and forced_layout["decoys"].size() == 2, "a source that always answers 1 still gives a valid pick (the smallest count)")
	var stubborn := _new_placement()
	stubborn.any_min = 500.0  # no layout of two or more decoys can pass
	stubborn.max_retries = 7
	var stuck_layout: Dictionary = stubborn.choose(RandomNumberGenerator.new())
	var fallback_key := func(decoys: Array) -> String:
		return "|".join(decoys.map(func(d): return "%s@%.2f,%.2f:%s" % [d["kind"], d["spot"].x, d["spot"].y, d["letter"]]))
	check(stubborn.is_valid() and stuck_layout["source"] == "fallback" and stuck_layout["attempts"] == 7, "when no pick passes, it stops after max_retries tries (%d) and answers with the fallback" % stuck_layout["attempts"])
	check(fallback_key.call(stuck_layout["decoys"]) == fallback_key.call(placement.fallback_decoys({})) and stuck_layout["decoys"].all(func(d): return ["harm", "reward"].has(d["outcome"])), "the fallback is the data's 8 decoys (kind, place, letter) with their outcomes rolled")
	var legacy: Array = placement.fallback_decoys(Foraging.LEGACY_OUTCOMES)
	check(legacy.size() == 8 and legacy[0]["outcome"] == "harm" and legacy[7]["outcome"] == "reward", "the test-only legacy outcomes give the older fixed roles")

	# Bad data: an error and the fallback, never a crash.
	var base: Dictionary = _config()["decoy_placement"]
	var bads := {}
	var bad: Dictionary
	var edits := {
		"count_max above the slots": func(b): b["count_max"] = 25,
		"count_min above count_max": func(b): b["count_min"] = 17,
		"count_min of 0": func(b): b["count_min"] = 0,
		"a duplicate slot": func(b): b["slots"][1] = b["slots"][0],
		"a slot off the stage": func(b): b["slots"][2] = [70.0, 0.0],
		"a slot on a target plant": func(b): b["slots"][3] = [_target_spots()[22].x + 0.5, _target_spots()[22].y],
		"a slot at a traveler's start": func(b): b["slots"][0] = [_start_spots()[0].x + 1.0, _start_spots()[0].y],
		"two slots 1 m apart": func(b): b["slots"][4] = [b["slots"][5][0] + 1.0, b["slots"][5][1]],
		"a slot that is not [x, z]": func(b): b["slots"][6] = "x",
		"no slots": func(b): b["slots"] = [],
		"the old pools instead of slots": func(b): b.erase("slots"),
		"a missing kind weight": func(b): b["kind_weights"].erase("norugui"),
		"a zero kind weight": func(b): b["kind_weights"]["butsunnamu"] = 0,
		"a fractional kind weight": func(b): b["kind_weights"]["norugui"] = 1.5,
		"a kind weight for a non-decoy": func(b): b["kind_weights"]["ma"] = 1,
		"no kind_weights": func(b): b.erase("kind_weights"),
		"a missing outcome weight": func(b): b["outcome_weights"].erase("reward"),
		"an outcome weight of 0": func(b): b["outcome_weights"]["harm"] = 0,
		"an unknown outcome": func(b): b["outcome_weights"]["maybe"] = 1,
		"damage_units of 0": func(b): b["damage_units"] = 0,
		"damage_units missing": func(b): b.erase("damage_units"),
	}
	for label in edits:
		bad = base.duplicate(true)
		edits[label].call(bad)
		bads[label] = bad
	for label in bads:
		var broken := _new_placement(bads[label])
		var got: Dictionary = broken.choose(RandomNumberGenerator.new())
		check(not broken.is_valid() and broken.problem != "" and got["source"] == "bad pools" and fallback_key.call(got["decoys"]) == fallback_key.call(placement.fallback_decoys({})), "%s: an error (%s) and the fixed decoys" % [label, broken.problem])
	var fine := base.duplicate(true)
	fine["count_max"] = 24
	fine["count_min"] = 1
	check(_new_placement(fine).is_valid(), "a count range of 1..24 (all the slots) is valid")
	var empty := _new_placement({"slots": 5})
	check(not empty.is_valid() and empty.choose(RandomNumberGenerator.new())["source"] == "bad pools", "slots that are not an array are an error too")
	var missing := DecoyPlacementScript.new({}, _config()["plants"]["kinds"], _placed(), _fixed_spots(), _tree_spots(), _start_spots(), 12.0, 64.0, jamo)
	check(not missing.is_valid() and missing.choose(RandomNumberGenerator.new())["source"] == "bad pools", "missing decoy_placement data is an error and the fallback")

	# The command-line seed.
	var found: Dictionary = DecoyPlacementScript.seed_from_args(PackedStringArray(["--other", "--placement-seed=123", "x"]))
	check(found["found"] and found["seed"] == 123 and found["problem"] == "", "--placement-seed=123 is read")
	found = DecoyPlacementScript.seed_from_args(PackedStringArray(["--placement-seed=-4318887386563497403"]))
	check(found["found"] and found["seed"] == -4318887386563497403, "a negative seed (the randomized ones can be) is read as printed")
	check(not DecoyPlacementScript.seed_from_args(PackedStringArray())["found"], "no argument, no seed")
	found = DecoyPlacementScript.seed_from_args(PackedStringArray(["--placement-seed=abc"]))
	check(not found["found"] and found["problem"] != "", "a bad seed is reported and ignored")
	var rng_a := RandomNumberGenerator.new()
	rng_a.randomize()
	var printed := rng_a.seed
	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = printed
	check(rng_a.randi_range(0, 1000000) == rng_b.randi_range(0, 1000000), "a randomized generator's printed seed reproduces its draws")
	_section_done("test_placement_logic")


const DECOY_SAMPLE := 20000        # scene starts the decoy distribution tests roll
const COUNT_TOLERANCE := 0.01      # absolute, on each count's share (1/15 = 0.0667; about 5.7 standard deviations at this sample size)
const KIND_TOLERANCE := 0.01       # on each kind's share of all decoys (about 180000 decoys, 10 standard deviations)
const OUTCOME_TOLERANCE := 0.01    # on the harm share of all decoys
const OUTCOME_KIND_TOLERANCE := 0.015  # on the harm share within one kind (about 45000 decoys each, 6 standard deviations)
const LETTER_TOLERANCE := 0.01     # on each jamo's share of all decoys
const SLOT_TOLERANCE := 0.02       # on how often each slot is used (0.375 expected; 5.9 standard deviations)


func test_decoy_roll_stats() -> void:
	var placement := _new_placement()
	var jamo := _allowed_letters()
	var derived := DecoyPlacementScript.target_jamo(_hangul_plants())
	var same := derived.size() == jamo.size() and jamo.all(func(j): return derived.has(j))
	print("  jamo of the target words (%d): %s" % [derived.size(), "".join(derived)])
	check(same and derived.size() == 11 and placement.letters == derived, "the decoy letters are the %d jamo of the six target words, derived from the word data" % derived.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = 987654321
	var counts := {}
	var kinds := {}
	var by_kind := {}
	var harm_by_kind := {}
	var harm := 0
	var letters := {}
	var slot_uses := {}
	var kind_at_slot := {}
	var lone := {}      # kind -> the most decoys in one scene made only of that kind
	var total := 0
	var in_range := true
	for n in DECOY_SAMPLE:
		var decoys: Array = placement.choose(rng)["decoys"]
		counts[decoys.size()] = int(counts.get(decoys.size(), 0)) + 1
		in_range = in_range and decoys.size() >= 2 and decoys.size() <= 16
		var seen_kinds := {}
		for d in decoys:
			total += 1
			kinds[d["kind"]] = int(kinds.get(d["kind"], 0)) + 1
			by_kind[d["kind"]] = int(by_kind.get(d["kind"], 0)) + 1
			seen_kinds[d["kind"]] = true
			if d["outcome"] == "harm":
				harm += 1
				harm_by_kind[d["kind"]] = int(harm_by_kind.get(d["kind"], 0)) + 1
			letters[d["letter"]] = int(letters.get(d["letter"], 0)) + 1
			slot_uses[d["spot"]] = int(slot_uses.get(d["spot"], 0)) + 1
			kind_at_slot["%s@%s" % [d["kind"], d["spot"]]] = true
		if seen_kinds.size() == 1:
			var only: String = seen_kinds.keys()[0]
			lone[only] = maxi(int(lone.get(only, 0)), decoys.size())
	check(in_range and counts.size() == 15, "over %d scene starts every decoy count from 2 to 16 appears and none outside (%d different)" % [DECOY_SAMPLE, counts.size()])
	var worst := 0.0
	for c in range(2, 17):
		worst = maxf(worst, absf(float(counts.get(c, 0)) / DECOY_SAMPLE - 1.0 / 15.0))
	print("  count: worst share gap %.4f (tolerance %.3f)" % [worst, COUNT_TOLERANCE])
	check(worst <= COUNT_TOLERANCE, "the count is uniform over 2..16: every share within %.3f of 1/15 (worst %.4f, %d starts)" % [COUNT_TOLERANCE, worst, DECOY_SAMPLE])
	worst = 0.0
	for id in DECOY_KIND_IDS:
		worst = maxf(worst, absf(float(kinds.get(id, 0)) / total - 0.25))
	print("  kind: worst share gap %.4f (tolerance %.3f), %d decoys" % [worst, KIND_TOLERANCE, total])
	check(worst <= KIND_TOLERANCE, "each kind is about 25%% of the decoys: within %.3f (worst %.4f, %d decoys)" % [KIND_TOLERANCE, worst, total])
	check(kind_at_slot.size() == 24 * 4, "every kind appears in every one of the 24 slots at least once (%d of 96 combinations)" % kind_at_slot.size())
	print("  most decoys in one scene made of one kind: %s" % str(lone))
	check(DECOY_KIND_IDS.all(func(id): return int(lone.get(id, 0)) >= 4), "scenes where every decoy is one kind are possible, for each kind (at least 4 decoys of one kind alone; the sample has %s)" % str(lone))
	var harm_share := float(harm) / total
	print("  outcome: harm %.4f (tolerance %.3f)" % [harm_share, OUTCOME_TOLERANCE])
	check(absf(harm_share - 0.5) <= OUTCOME_TOLERANCE, "harm and reward are each about 50%%: harm %.4f within %.3f of 0.5 (%d decoys)" % [harm_share, OUTCOME_TOLERANCE, total])
	for id in DECOY_KIND_IDS:
		var share := float(harm_by_kind.get(id, 0)) / int(by_kind[id])
		print("  outcome within %s: harm %.4f" % [id, share])
		check(absf(share - 0.5) <= OUTCOME_KIND_TOLERANCE, "%s: harm %.4f within %.3f of 0.5, so the outcome does not depend on the kind (%d decoys)" % [id, share, OUTCOME_KIND_TOLERANCE, by_kind[id]])
	worst = 0.0
	var letters_ok := letters.keys().all(func(l): return jamo.has(l))
	for letter in jamo:
		worst = maxf(worst, absf(float(letters.get(letter, 0)) / total - 1.0 / jamo.size()))
	check(letters_ok and letters.size() == jamo.size() and worst <= LETTER_TOLERANCE, "every decoy letter is one of the %d target jamo, each used about 1/%d of the time (worst gap %.4f, tolerance %.3f)" % [jamo.size(), jamo.size(), worst, LETTER_TOLERANCE])
	worst = 0.0
	for slot in placement.slots:
		worst = maxf(worst, absf(float(slot_uses.get(slot, 0)) / DECOY_SAMPLE - 9.0 / 24.0))
	print("  slot use: worst gap %.4f (tolerance %.3f)" % [worst, SLOT_TOLERANCE])
	check(slot_uses.size() == 24 and worst <= SLOT_TOLERANCE, "each slot is used in about 9/24 of the scenes (worst gap %.4f, tolerance %.3f)" % [worst, SLOT_TOLERANCE])
	# A seed fixes everything, different seeds differ in count, kinds, outcomes or letters.
	var a := RandomNumberGenerator.new()
	var b := RandomNumberGenerator.new()
	var keys := {}
	var same_ok := true
	for seed_value in 500:
		a.seed = seed_value
		b.seed = seed_value
		var first: Array = placement.choose(a)["decoys"]
		same_ok = same_ok and _layout_key(first) == _layout_key(placement.choose(b)["decoys"])
		keys[_layout_key(first)] = true
	check(same_ok, "the same seed reproduces the count, kinds, slots, outcomes and letters exactly")
	check(keys.size() >= 495, "different seeds differ (%d distinct layouts of 500)" % keys.size())
	_section_done("test_decoy_roll_stats")


func test_chaos_piles_logic() -> void:
	var cfg: Dictionary = _config()["chaos_piles"]
	var placement := _new_placement()
	var good := _new_piles()
	check(good.is_valid() and good.slots.size() == 12, "(setup) the real table is valid with 12 slots")
	# Validation: every bad table is an error and no piles, never a crash.
	var variants := {}
	var v: Dictionary = cfg.duplicate(true)
	v["count_table"] = []
	variants["an empty count table"] = v
	v = cfg.duplicate(true)
	v["amount_table"] = []
	variants["an empty amount table"] = v
	v = cfg.duplicate(true)
	v["count_table"][1]["weight"] = 0
	variants["a count weight of 0"] = v
	v = cfg.duplicate(true)
	v["amount_table"][0]["weight"] = -2
	variants["a negative amount weight"] = v
	v = cfg.duplicate(true)
	v["amount_table"][2]["weight"] = 1.5
	variants["a fractional weight"] = v
	v = cfg.duplicate(true)
	v["amount_table"][1]["amount"] = 0
	variants["an amount of 0"] = v
	v = cfg.duplicate(true)
	v["count_table"][0]["count"] = -1
	variants["a count below 0"] = v
	v = cfg.duplicate(true)
	v["count_table"][2]["count"] = "two"
	variants["a count that is not a number"] = v
	v = cfg.duplicate(true)
	v["slots"] = [v["slots"][0], v["slots"][1]]
	variants["too few slots for the largest count"] = v
	v = cfg.duplicate(true)
	v["slots"] = []
	variants["no slots"] = v
	v = cfg.duplicate(true)
	v["slots"][3] = v["slots"][2]
	variants["a duplicate slot"] = v
	v = cfg.duplicate(true)
	v["slots"][0] = [_start_spots()[0].x + 1.0, _start_spots()[0].y]
	variants["a slot at a traveler's start"] = v
	v = cfg.duplicate(true)
	v["slots"][0] = [_target_spots()[0].x + 0.5, _target_spots()[0].y]
	variants["a slot on a target plant"] = v
	v = cfg.duplicate(true)
	v["off_path"]["min_slots"] = 12
	variants["too few slots far from every target"] = v
	v = cfg.duplicate(true)
	v["item"] = "no_such_item"
	variants["an unknown item"] = v
	v = cfg.duplicate(true)
	v["count_table"] = "nope"
	variants["a table that is not an array"] = v
	for label in variants:
		var bad := _new_piles(variants[label], placement)
		var drawn: Array = bad.roll(RandomNumberGenerator.new(), _target_spots(), _start_spots())
		check(not bad.is_valid() and bad.problem != "" and drawn.is_empty(), "%s: an error (%s) and no piles" % [label, bad.problem])
	check(_new_piles({"item": "ddeok"}, placement).problem != "", "chaos_piles data without tables or slots is an error")
	v = cfg.duplicate(true)
	v["count_table"] = [{"count": 0, "weight": 1}]
	check(_new_piles(v, placement).is_valid(), "a table that only ever rolls 0 is valid")

	# Proportions over many scene starts.
	var count_hits := {0: 0, 1: 0, 2: 0, 3: 0}
	var amount_hits := {1: 0, 2: 0, 3: 0, 10: 0}
	var piles_total := 0
	var spacing_ok := true
	var start_ok := true
	var apart_ok := true
	var slot_ok := true
	var counts_ok := true
	for seed_value in SAMPLE_STARTS:
		var roll := _offline_roll(seed_value, placement, good)
		var drawn: Array = roll["piles"]
		counts_ok = counts_ok and drawn.size() <= 3
		count_hits[drawn.size()] = int(count_hits.get(drawn.size(), 0)) + 1
		for i in drawn.size():
			var spot: Vector2 = drawn[i]["spot"]
			amount_hits[drawn[i]["amount"]] = int(amount_hits.get(drawn[i]["amount"], 0)) + 1
			piles_total += 1
			slot_ok = slot_ok and good.slots.has(spot)
			spacing_ok = spacing_ok and _nearest_distance(spot, roll["spots"]) >= 2.0
			start_ok = start_ok and _nearest_distance(spot, _start_spots()) >= 6.0
			for j in range(i + 1, drawn.size()):
				apart_ok = apart_ok and spot.distance_to(drawn[j]["spot"]) >= 2.0 and spot != drawn[j]["spot"]
	check(counts_ok and slot_ok, "%d scene starts: at most 3 piles, each on a data slot" % SAMPLE_STARTS)
	check(spacing_ok, "%d scene starts: every pile is 2 m from every plant and decoy" % SAMPLE_STARTS)
	check(start_ok and apart_ok, "%d scene starts: every pile is 6 m from the starts, and piles are 2 m apart" % SAMPLE_STARTS)
	var want_counts := {0: 0.3, 1: 0.4, 2: 0.2, 3: 0.1}
	for n in want_counts:
		var got := float(count_hits[n]) / SAMPLE_STARTS
		print("  piles per start = %d: %.4f (want %.2f)" % [n, got, want_counts[n]])
		check(absf(got - want_counts[n]) <= PROPORTION_TOLERANCE, "%d piles per start: %.4f within %.3f of %.2f (sample %d starts)" % [n, got, PROPORTION_TOLERANCE, want_counts[n], SAMPLE_STARTS])
	var want_amounts := {1: 10.0 / 17.0, 2: 4.0 / 17.0, 3: 2.0 / 17.0, 10: 1.0 / 17.0}
	for n in want_amounts:
		var got := float(amount_hits[n]) / piles_total
		print("  pile amount %d: %.4f (want %.4f)" % [n, got, want_amounts[n]])
		check(absf(got - want_amounts[n]) <= PROPORTION_TOLERANCE, "amount %d: %.4f within %.3f of %.4f (sample %d piles)" % [n, got, PROPORTION_TOLERANCE, want_amounts[n], piles_total])
	# Blocked slots only thin the piles out; a roll never loops or fails.
	var crowded: Array[Vector2] = []
	for spot in good.slots:
		crowded.append(spot)
	var forced := ForcedRng.new()
	forced.value = 100000  # the largest count and amount
	check(good.roll(forced, crowded, _start_spots()).is_empty(), "with every slot taken by a plant, a roll gives no piles and ends")
	check(good.roll(forced, _target_spots(), _start_spots()).size() <= 3, "a forced largest roll gives at most 3 piles")
	_section_done("test_chaos_piles_logic")


## Where every plant and pile stands, as one comparable value.
func _world_snapshot(map: Node3D) -> String:
	var parts: Array[String] = []
	for plant in map.plants:
		parts.append("%s@%.3f,%.3f:%s:%s" % [plant.kind_id, plant.position.x, plant.position.z, plant.outcome, plant.letter])
	for pile in map.piles:
		parts.append("pile@%.3f,%.3f" % [pile.position.x, pile.position.z] if pile != null else "pile-gone")
	return ";".join(parts)


## A map reloaded the way a restart does it: the map becomes the current scene.
func _current_map(seed_value: int) -> Node3D:
	GameState.new_hike()
	GameState.controlled = "fernanda"
	Foraging.legacy_layout = false
	Foraging.seed_override = seed_value
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	get_tree().root.add_child(map)
	get_tree().current_scene = map
	Foraging.seed_override = -1
	await get_tree().physics_frame
	return map


func test_placement_timing() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var placement := _new_placement()
	var piles := _new_piles()
	# The scene's roll is the offline roll of its seed.
	var map: Node3D = await _seeded_map(31337)
	var roll := _offline_roll(31337, placement, piles)
	check(map.placement_seed == 31337 and map.placement_rolls == 1, "the seed override fixes the seed and the roll happens once")
	check(_layout_key(map.layout["decoys"]) == _layout_key(roll["layout"]["decoys"]) and map.layout["source"] == "random", "the scene's decoy layout is the roll of its seed")
	check(str(map.pile_roll) == str(roll["piles"]), "the scene's piles are the roll of its seed")
	var spots_ok := true
	for i in map.plants.size():
		var plant: Node3D = map.plants[i]
		spots_ok = spots_ok and Vector2(plant.position.x, plant.position.z).is_equal_approx(roll["spots"][i])
	check(spots_ok, "every plant node stands where the roll says (targets where the data says)")
	var snapshot := _world_snapshot(map)
	# Pause, resume, the backpack, walking and a pick never roll again.
	check(map.open_pause_menu() and map.pause_menu.is_open, "(setup) the pause menu opens")
	map.pause_menu.close()
	map._on_pause_chosen("resume")
	check(map.open_backpack(), "(setup) the backpack opens")
	map.close_backpack()
	for i in 120:
		map.step(Vector2.RIGHT if i < 60 else Vector2.LEFT, 1.0 / 60.0)
	check(map.placement_rolls == 1 and map.placement_seed == 31337, "pausing, resuming, the backpack and walking do not roll again")
	check(_world_snapshot(map) == snapshot, "and nothing moved: decoys and piles stand as they did")
	map.free()
	get_tree().paused = false

	# Without an override every scene start picks its own seed.
	GameState.new_hike()
	Foraging.legacy_layout = false
	var seeds := {}
	for n in 6:
		var m: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
		add_child(m)
		seeds[m.placement_seed] = true
		var expected := _offline_roll(m.placement_seed, placement, piles)
		check(_layout_key(m.layout["decoys"]) == _layout_key(expected["layout"]["decoys"]) and str(m.pile_roll) == str(expected["piles"]), "random start %d: the layout is the roll of the seed it printed (%d)" % [n, m.placement_seed])
		m.free()
	check(seeds.size() == 6, "six scene starts without an override used six different seeds")

	# Death restart and Restart scene reload the scene, and the new scene rolls anew.
	var original_scene := get_tree().current_scene
	for path in ["death", "menu"]:
		var doomed: Node3D = await _current_map(-1)
		var first_seed: int = doomed.placement_seed
		var restarts := []
		doomed.restarted.connect(func(): restarts.append(true))
		if path == "death":
			doomed.begin_death_beat()
			doomed.tick_beat(100.0)
		else:
			check(doomed.open_pause_menu(), "(setup) the menu opens")
			doomed.pause_menu.close()
			doomed._on_pause_chosen("restart")
		check(restarts.size() == 1, "%s: the scene restarts once" % path)
		for i in 4:
			await get_tree().process_frame
		var fresh: Node = get_tree().current_scene
		check(fresh != doomed and not is_instance_valid(doomed), "%s: the scene was reloaded" % path)
		if fresh != doomed and is_instance_valid(fresh) and fresh.has_method("picks_allowed"):
			check(fresh.placement_rolls == 1 and fresh.placement_seed != first_seed, "%s: the new scene rolled once, with a new seed" % path)
			var again := _offline_roll(fresh.placement_seed, placement, piles)
			check(_layout_key(fresh.layout["decoys"]) == _layout_key(again["layout"]["decoys"]) and str(fresh.pile_roll) == str(again["piles"]), "%s: and its layout is the roll of that seed" % path)
			fresh.set_process(false)
			fresh.free()
		get_tree().current_scene = original_scene
		get_tree().paused = false

	# With an override, every start (restarts included) is the same.
	for path in ["death", "menu"]:
		Foraging.legacy_layout = false
		Foraging.seed_override = 2024
		var doomed: Node3D = await _current_map(2024)
		var first_key := _layout_key(doomed.layout["decoys"])
		var first_piles := str(doomed.pile_roll)
		check(doomed.placement_seed == 2024, "(setup) %s: the override is in force" % path)
		Foraging.seed_override = 2024  # a reload reads it again
		if path == "death":
			doomed.begin_death_beat()
			doomed.tick_beat(100.0)
		else:
			doomed.open_pause_menu()
			doomed.pause_menu.close()
			doomed._on_pause_chosen("restart")
		for i in 4:
			await get_tree().process_frame
		Foraging.seed_override = -1
		var fresh: Node = get_tree().current_scene
		check(fresh != doomed and fresh.has_method("picks_allowed"), "(setup) %s: reloaded with the override on" % path)
		if fresh != doomed and fresh.has_method("picks_allowed"):
			check(fresh.placement_seed == 2024 and _layout_key(fresh.layout["decoys"]) == first_key and str(fresh.pile_roll) == first_piles, "%s: with --placement-seed the restarted scene has the same layout and piles" % path)
			fresh.set_process(false)
			fresh.free()
		get_tree().current_scene = original_scene
		get_tree().paused = false

	# Bad data in the scene: an error and the old fixed positions, no crash, no piles.
	var live: Dictionary = Content.mountain("hallasan")["foraging"]
	var saved_place = live["decoy_placement"]
	var saved_chaos = live["chaos_piles"]
	live["decoy_placement"] = {"slots": []}
	live["chaos_piles"] = {"slots": []}
	var broken: Node3D = await _seeded_map(5)
	var same := true
	for i in broken.plants.size():
		same = same and Vector2(broken.plants[i].position.x, broken.plants[i].position.z).is_equal_approx(Vector2(float(_placed()[i]["x"]), float(_placed()[i]["z"])))
	check(same and broken.layout["source"] == "bad pools", "bad pools in the scene: every plant stands at its data position")
	check(broken.piles.is_empty() and broken.pile_roll.is_empty(), "bad pile data in the scene: no piles, no crash")
	broken.free()
	live["decoy_placement"] = saved_place
	live["chaos_piles"] = saved_chaos
	get_tree().current_scene = original_scene
	get_tree().paused = false
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_placement_timing")


func test_legacy_default() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/foraging/foraging.gd")
	check(source.contains("static var legacy_layout := false"), "legacy_layout is false by default in the game's code")
	var setters := _scripts_containing("legacy_layout = true", ["res://scenes", "res://scripts"])
	check(setters.is_empty(), "nothing in the game's scenes or scripts sets legacy_layout (%s)" % str(setters))
	# The scene, loaded normally (no seed, the flag as the 7d sections leave it): the random layout.
	Foraging.legacy_layout = false
	Foraging.seed_override = -1
	GameState.new_hike()
	GameState.controlled = "fernanda"
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	var n: int = map.layout["decoys"].size()
	check(not Foraging.legacy_layout and map.layout["source"] == "random", "a normal scene load runs with legacy_layout false: the layout is rolled, not the legacy one (source '%s')" % map.layout["source"])
	check(n >= 2 and n <= 16 and map.plants.size() == 28 + n, "and it has 2 to 16 decoys (%d) on top of the 28 targets" % n)
	check(map.decoy_placement.is_valid() and map.placement_rolls == 1 and map.pile_roll.size() == map.piles.size(), "and rolled once, with piles from the chaos pile roll")
	map.free()
	GameState.new_hike()
	_section_done("test_legacy_default")


## The .gd files under `roots` whose text contains `needle`.
func _scripts_containing(needle: String, roots: Array) -> Array[String]:
	var found: Array[String] = []
	var todo: Array = roots.duplicate()
	while not todo.is_empty():
		var dir_path: String = todo.pop_back()
		var dir := DirAccess.open(dir_path)
		if dir == null:
			continue
		for sub in dir.get_directories():
			todo.append(dir_path + "/" + sub)
		for file in dir.get_files():
			if file.ends_with(".gd") and FileAccess.get_file_as_string(dir_path + "/" + file).contains(needle):
				found.append(dir_path + "/" + file)
	return found


func test_decoys_at_any_position() -> void:
	var data_placed: Array = _placed()
	var kinds := {}
	for kind in _hangul_plants():
		kinds[kind["id"]] = kind
	var data_targets: Array = data_placed.filter(func(e): return kinds[e["kind"]]["kind"] == "target")
	var placement := _new_placement()
	var piles := _new_piles()
	for seed_value in [3, 11, 4242]:
		var decoys: Array = _offline_roll(seed_value, placement, piles)["layout"]["decoys"]
		var map: Node3D = await _seeded_map(seed_value, {"ddeok": 1})
		var tag := "seed %d: " % seed_value
		check(map.plants.size() == 28 + decoys.size() and map.picking.plant_count() == 28 + decoys.size() and map.picking.letters_left() == 28 + decoys.size(), tag + "28 targets and the %d rolled decoys, every one with a letter in Picking" % decoys.size())
		var target_plants: Array = map.plants.filter(func(p): return p.kind == "target")
		var decoy_plants: Array = map.plants.filter(func(p): return p.kind != "target")
		var targets_ok: bool = target_plants.size() == data_targets.size()
		for i in target_plants.size():
			var plant: Node3D = target_plants[i]
			targets_ok = targets_ok and plant.kind_id == data_targets[i]["kind"] and plant.letter == data_targets[i]["letter"] and Vector2(plant.position.x, plant.position.z).is_equal_approx(Vector2(float(data_targets[i]["x"]), float(data_targets[i]["z"]))) and plant.tooltip_text() == kinds[plant.kind_id]["hover_name"]
		check(targets_ok, tag + "the targets keep their kind, letter, data position and hover name")
		var decoys_ok: bool = decoy_plants.size() == decoys.size()
		for i in decoy_plants.size():
			var plant: Node3D = decoy_plants[i]
			decoys_ok = decoys_ok and plant.kind_id == decoys[i]["kind"] and plant.letter == decoys[i]["letter"] and plant.outcome == decoys[i]["outcome"] and plant.kind == "decoy_" + decoys[i]["outcome"] and Vector2(plant.position.x, plant.position.z).is_equal_approx(decoys[i]["spot"]) and plant.tooltip_text() == "???"
			decoys_ok = decoys_ok and map.picking.nearest_pickable(decoys[i]["spot"]) >= 0
		check(decoys_ok, tag + "each decoy has its rolled kind, letter, outcome and slot, hovers as ???, and Picking knows it")
		# Reward outcome: the weighted roll, the backpack, the label, the steam.
		var rng := ForcedRng.new()
		rng.value = 4  # gongjindan
		map.reward_rng = rng
		var reward := _first_decoy_with(map, "reward")
		var puffs := _particle_count(map)
		check(reward != null, tag + "(setup) the roll has a reward decoy")
		if reward != null:
			map.pick_plant(reward)
			check(GameState.inventory.snapshot() == {"ddeok": 1, "gongjindan": 1} and reward.letter == "" and _particle_count(map) == puffs + 1 and not map.is_gore_playing(), tag + "a reward decoy gives its rolled item, loses its letter and steams, with no gore")
			check((map.find_child("FloatingLabel", false, false) as Label3D) != null and map.picking.basket.is_empty(), tag + "with its floating label and nothing in the basket")
		# Harm outcome: half a heart off the picker, the kind's gore beat, the steam.
		var hearts: int = GameState.heart_units["fernanda"]
		var harm := _first_decoy_with(map, "harm")
		check(harm != null, tag + "(setup) the roll has a harm decoy")
		if harm != null:
			puffs = _particle_count(map)
			map.pick_plant(harm)
			check(GameState.heart_units["fernanda"] == hearts - 1 and GameState.heart_units["nestor"] == hearts, tag + "a harm decoy costs the picker half a heart")
			check(map.is_gore_playing() and map.decoy_gore.gore_id == kinds[harm.kind_id]["gore"] and _particle_count(map) == puffs + 1 and harm.letter == "", tag + "and plays its kind's gore and steam")
			_finish_gore(map)
		map.free()
		get_tree().paused = false
	GameState.new_hike()
	_section_done("test_decoys_at_any_position")


func _first_decoy_with(map: Node3D, outcome: String) -> Node3D:
	for plant in map.plants:
		if plant.outcome == outcome:
			return plant
	return null


const GORE_OF := {"keuncheonnamseong": "face_swell_pop", "butsunnamu": "convulse_eyes_pop", "norugui": "deer_ears_rip", "deulchuknamu": "deulssuk_drunk"}


## Every kind with either outcome: a reward pick gives an item and no damage, a harm pick damages the picker only and plays that kind's gore.
func test_decoy_outcome_picks() -> void:
	for kind_id in DECOY_KIND_IDS:
		var seed_reward := _seed_with_decoy(kind_id, "reward")
		var seed_harm := _seed_with_decoy(kind_id, "harm")
		check(seed_reward > 0 and seed_harm > 0, "(setup) %s: seeds with a reward and a harm decoy of it exist (%d, %d)" % [kind_id, seed_reward, seed_harm])
		var map: Node3D = await _seeded_map(seed_reward, {"ddeok": 2})
		var plant := _decoy_of(map, kind_id, "reward")
		var rng := ForcedRng.new()
		rng.value = 4  # gongjindan
		map.reward_rng = rng
		var hearts: Dictionary = GameState.heart_units.duplicate()
		var puffs := _particle_count(map)
		map.pick_plant(plant)
		var label := map.find_child("FloatingLabel", false, false) as Label3D
		check(GameState.inventory.snapshot() == {"ddeok": 2, "gongjindan": 1} and GameState.heart_units == hearts, "%s, reward outcome: an item in the backpack and no damage" % kind_id)
		check(not map.decoy_gore.active and not map.is_gore_playing() and map.picks_allowed() and _particle_count(map) == puffs + 1 and plant.letter == "", "%s, reward outcome: the steam, no gore, nothing blocked, the letter gone" % kind_id)
		check(label != null and label.text.begins_with("+1 "), "%s, reward outcome: a floating '+1 ...' label" % kind_id)
		map.free()
		get_tree().paused = false
		for controlled in ["fernanda", "nestor"]:
			var other: String = GameState.partner_of(controlled)
			map = await _seeded_map(seed_harm, {"ddeok": 2}, controlled)
			plant = _decoy_of(map, kind_id, "harm")
			var start := GameState.max_units()
			puffs = _particle_count(map)
			var floats := map.find_children("*", "Label3D", false, false).size()
			map.pick_plant(plant)
			var tag := "%s, harm outcome, %s picks: " % [kind_id, controlled]
			check(GameState.heart_units[controlled] == start - 1 and GameState.heart_units[other] == start, tag + "half a heart off the picker and nothing off the other")
			check(map.decoy_gore.active and map.decoy_gore.gore_id == GORE_OF[kind_id] and map.decoy_gore.who == controlled, tag + "the kind's own gore (%s) plays on the picker" % GORE_OF[kind_id])
			check(_particle_count(map) == puffs + 1 and plant.letter == "" and GameState.inventory.snapshot() == {"ddeok": 2} and map.find_children("*", "Label3D", false, false).size() == floats, tag + "the steam, the letter gone, no item and no reward label")
			_finish_gore(map)
			map.free()
			get_tree().paused = false
	GameState.new_hike()
	_section_done("test_decoy_outcome_picks")


const DecoyGoreFxScript := preload("res://scenes/foraging/decoy_gore_fx.gd")
const NEW_GORE := [["norugui", "deer_ears_rip", "노루 귀"], ["deulchuknamu", "deulssuk_drunk", "들쭉술"]]


func test_new_gore_data() -> void:
	var cfg := _config()
	var table: Dictionary = cfg["decoy_gore"]
	var kinds: Array = cfg["plants"]["kinds"]
	check(DecoyGoreScript.problem_with(kinds, table) == "", "the shipped decoy_gore data validates with all four gore ids")
	var ids := {}
	for kind in kinds:
		if kind["kind"] == "decoy":
			ids[kind["gore"]] = true
			check(table.has(kind["gore"]) and kind["gore"] == GORE_OF[kind["id"]], "%s has exactly one gore id, %s, and it exists" % [kind["id"], kind["gore"]])
	check(ids.size() == 4, "the four decoy kinds have four different gore ids")
	for pair in NEW_GORE:
		var entry: Dictionary = table[pair[1]]
		check(float(entry["duration"]) > 0.0 and float(entry["pop_seconds"]) > 0.0 and float(entry["pop_seconds"]) <= float(entry["duration"]), "%s has a positive duration and a pop inside it" % pair[1])
		check(absf(float(entry["duration"]) - 1.6) <= 0.6, "%s lasts about the existing 1.6 s (%.1f s)" % [pair[1], float(entry["duration"])])
		check(entry["caption_ko"] == pair[2], "%s has the caption '%s'" % [pair[1], pair[2]])
	for id in ["deer_ears_rip"]:
		var all_there := true
		for key in ["head_height", "head_radius", "ear_length", "ear_width", "ear_color", "ear_inner_color", "grow_fraction", "ear_tilt_degrees", "twitch_degrees", "twitch_hz", "swivel_degrees", "pop_blood_strength", "hop_speed", "hop_height", "hop_seconds", "gravity"]:
			all_there = all_there and table[id].has(key)
		check(all_there, "deer_ears_rip has every number its look needs, in data")
	var drunk_there := true
	for key in ["head_height", "stagger_radius", "wobble_degrees", "wobble_hz", "hiccups", "hiccup_height", "hiccup_seconds", "fountain_particles", "fountain_color", "fountain_size", "fountain_speed", "fountain_lift", "fountain_forward", "fountain_seconds", "gravity", "puddle_radius", "puddle_color", "puddle_fade"]:
		drunk_there = drunk_there and table["deulssuk_drunk"].has(key)
	check(drunk_there, "deulssuk_drunk has every number its look needs, in data")
	check(not table["face_swell_pop"].has("caption_ko") and not table["convulse_eyes_pop"].has("caption_ko"), "the two existing gores have no caption")
	check(table["show_captions"] == true, "foraging.decoy_gore.show_captions is true")
	check(DecoyGoreScript.caption(table, "deer_ears_rip") == "노루 귀" and DecoyGoreScript.caption(table, "deulssuk_drunk") == "들쭉술" and DecoyGoreScript.caption(table, "face_swell_pop") == "" and DecoyGoreScript.caption(table, "convulse_eyes_pop") == "", "caption() gives the two new captions and none for the old ones")
	var off := _table_copy()
	off["show_captions"] = false
	check(["deer_ears_rip", "deulssuk_drunk", "face_swell_pop", "convulse_eyes_pop", "nothing"].all(func(id): return DecoyGoreScript.caption(off, id) == ""), "with show_captions false there is no caption at all")
	check(DecoyGoreScript.problem_with(kinds, off) == "", "and that table is valid")
	# Bad data is a clear message.
	var bad := _table_copy()
	bad["deer_ears_rip"]["caption_ko"] = ""
	var msg: String = DecoyGoreScript.problem_with(kinds, bad)
	check(msg.contains("deer_ears_rip") and msg.contains("caption_ko"), "an empty caption_ko is rejected (%s)" % msg)
	bad = _table_copy()
	bad["deulssuk_drunk"]["caption_ko"] = 5
	check(DecoyGoreScript.problem_with(kinds, bad).contains("caption_ko"), "a caption_ko that is not a string is rejected")
	bad = _table_copy()
	bad["show_captions"] = "yes"
	check(DecoyGoreScript.problem_with(kinds, bad).contains("show_captions"), "a show_captions that is not true or false is rejected")
	bad = _table_copy()
	bad["caption_style"] = 3
	check(DecoyGoreScript.problem_with(kinds, bad).contains("caption_style"), "a caption_style that is not a dictionary is rejected")
	var bad_kinds := _kinds_copy()
	_kind_in(bad_kinds, "deulchuknamu").erase("gore")
	msg = DecoyGoreScript.problem_with(bad_kinds, table)
	check(msg.contains("deulchuknamu") and msg.contains("no gore id"), "a decoy kind without a gore id is rejected (%s)" % msg)
	bad_kinds = _kinds_copy()
	_kind_in(bad_kinds, "norugui")["gore"] = "missing_gore"
	check(DecoyGoreScript.problem_with(bad_kinds, table).contains("missing_gore"), "an unknown gore id on a new kind is rejected")
	bad_kinds = _kinds_copy()
	_kind_in(bad_kinds, "ma")["gore"] = "deer_ears_rip"
	check(DecoyGoreScript.problem_with(bad_kinds, table).contains("gore field"), "a gore field on a target is rejected")
	bad = _table_copy()
	bad["deulssuk_drunk"]["pop_seconds"] = 9.0
	check(DecoyGoreScript.problem_with(kinds, bad).contains("pop_seconds"), "a pop after the end of a new beat is rejected")
	bad = _table_copy()
	bad["deer_ears_rip"].erase("duration")
	check(DecoyGoreScript.problem_with(kinds, bad).contains("duration"), "a new beat without a duration is rejected")
	_section_done("test_new_gore_data")


## The unit vector (over x, z) from `spot` toward the nearest edge of the walkable map.
func _edge_direction(map: Node3D, spot: Vector3) -> Vector3:
	var rect: Rect2 = map.walk_bounds()
	var edges := [[spot.x - rect.position.x, Vector3(-1, 0, 0)], [rect.end.x - spot.x, Vector3(1, 0, 0)], [spot.z - rect.position.y, Vector3(0, 0, -1)], [rect.end.y - spot.z, Vector3(0, 0, 1)]]
	var best: Array = edges[0]
	for edge in edges:
		if edge[0] < best[0]:
			best = edge
	return best[1]


func _drive_gore_until(map: Node3D, seconds: float) -> void:
	var ticks := 0
	while map.decoy_gore.active and map.decoy_gore.elapsed < seconds and ticks < 2000:
		map.tick_gore(1.0 / 60.0)
		ticks += 1


func test_new_gore_scene() -> void:
	var table: Dictionary = _config()["decoy_gore"]
	# ---- deer_ears_rip ----
	var entry: Dictionary = table["deer_ears_rip"]
	var tag := "deer_ears_rip: "
	var map: Node3D = await _seeded_map(_seed_with_decoy("norugui", "harm"), {"ddeok": 1})
	var picker: Node3D = map.travelers["fernanda"]
	var other: Node3D = map.travelers["nestor"]
	picker.global_position = _ground_point(map, 30.0, 0.0)
	map.update_camera(0.0, true)
	var base_pos: Vector3 = picker.global_position
	var base_xform: Transform3D = picker.global_transform
	var base_color: Color = picker.body_color()
	var other_xform: Transform3D = other.global_transform
	var plant := _decoy_of(map, "norugui", "harm")
	var start := GameState.max_units()
	map.pick_plant(plant)
	check(GameState.heart_units["fernanda"] == start - 1 and GameState.heart_units["nestor"] == start, tag + "half a heart off the picker only")
	check(map.decoy_gore.active and map.decoy_gore.gore_id == "deer_ears_rip" and map.decoy_gore.who == "fernanda" and _particle_count(map) == 1, tag + "the beat starts on the picker, with only the steam so far")
	var fx := map.find_child("DecoyGoreFx", false, false) as Node3D
	var left := fx.find_child("EarLeft", false, false) as Node3D
	var right := fx.find_child("EarRight", false, false) as Node3D
	check(left != null and right != null and fx.find_children("Ear*", "Node3D", false, false).size() == 2, tag + "two ears")
	var fur := left.find_child("Fur", false, false) as MeshInstance3D
	var lining := left.find_child("Lining", false, false) as MeshInstance3D
	var fur_mesh := fur.mesh as CylinderMesh
	check(fur_mesh.top_radius == 0.0 and fur_mesh.height >= 1.5 * fur_mesh.bottom_radius * 2.0, tag + "each ear is elongated and pointed (%.2f m long, %.2f m wide)" % [fur_mesh.height, fur_mesh.bottom_radius * 2.0])
	var fur_color: Color = fur_mesh.material.albedo_color
	var lining_color: Color = (lining.mesh as CylinderMesh).material.albedo_color
	check(fur_color.r > fur_color.b and lining_color.get_luminance() > fur_color.get_luminance(), tag + "brown fur with a lighter inner colour")
	_drive_gore_until(map, float(entry["pop_seconds"]) * 0.1)
	var small: float = left.scale.x
	_drive_gore_until(map, float(entry["pop_seconds"]) * 0.5)
	check(small < 0.6 and left.scale.x > 0.99 and right.scale.x > 0.99, tag + "the ears grow out of the head (scale %.2f, then %.2f)" % [small, left.scale.x])
	var head_y := base_pos.y + float(entry["head_height"])
	check(absf(left.global_position.x - (base_pos.x - float(entry["head_radius"]))) < 0.01 and absf(right.global_position.x - (base_pos.x + float(entry["head_radius"]))) < 0.01 and absf(left.global_position.y - head_y) < 0.01 and absf(left.global_position.z - base_pos.z) < 0.01, tag + "one on each side of the head")
	check(left.rotation.z > 0.1 and right.rotation.z < -0.1, tag + "leaning outward")
	var lowest := INF
	var highest := -INF
	for i in 15:
		map.tick_gore(1.0 / 60.0)
		lowest = minf(lowest, left.rotation.z)
		highest = maxf(highest, left.rotation.z)
	check(highest - lowest > 0.04, tag + "the ears twitch (%.3f rad of movement)" % (highest - lowest))
	var swivel := deg_to_rad(float(entry["swivel_degrees"]))
	var before_swivel: float = absf(left.rotation.y)
	while map.decoy_gore.build_up() < 0.97:
		map.tick_gore(1.0 / 60.0)
	check(absf(left.rotation.y) > 0.8 * swivel and absf(left.rotation.y) > before_swivel and is_equal_approx(left.rotation.y, right.rotation.y), tag + "and swivel toward something offscreen (%.0f degrees of %.0f)" % [rad_to_deg(absf(left.rotation.y)), float(entry["swivel_degrees"])])
	check(_particle_count(map) == 1 and picker.global_position == base_pos, tag + "no blood yet, the picker is where it was")
	var dir := _edge_direction(map, base_pos)
	while not map.decoy_gore.popped:
		map.tick_gore(1.0 / 60.0)
	var bursts := map.find_children("*", "CPUParticles3D", false, false)
	check(bursts.size() == 3, tag + "the pop adds a blood burst for each ear (%d particle nodes with the steam)" % bursts.size())
	var xs: Array = bursts.slice(1).map(func(b): return b.global_position.x)
	check(xs.size() == 2 and minf(xs[0], xs[1]) < base_pos.x - 0.1 and maxf(xs[0], xs[1]) > base_pos.x + 0.1, tag + "from both sides of the head")
	var popped_at: Array = [left.global_position, right.global_position]
	var floor_of := func(ear: Node3D) -> float: return map.terrain.height_at(ear.global_position.x) + float(entry["ear_width"]) * 0.5
	var touched := [false, false]
	var rose_again := [false, false]
	var lowest_y := INF
	var ears := [left, right]
	while map.decoy_gore.active and map.decoy_gore.elapsed < float(entry["pop_seconds"]) + float(entry["hop_seconds"]) - 0.05:
		map.tick_gore(1.0 / 60.0)
		for i in 2:
			var y: float = ears[i].global_position.y
			var floor_y: float = floor_of.call(ears[i])
			lowest_y = minf(lowest_y, y - floor_y)
			if y <= floor_y + 0.01:
				touched[i] = true
			elif touched[i] and y > floor_y + 0.05:
				rose_again[i] = true
	check(lowest_y >= -0.001, tag + "the ears never go through the ground")
	check(touched[0] and touched[1] and rose_again[0] and rose_again[1], tag + "they land and hop away in small arcs")
	var moved_ok := true
	for i in 2:
		moved_ok = moved_ok and (ears[i].global_position - popped_at[i]).dot(dir) > 0.3
	check(moved_ok, tag + "toward the nearest edge of the map (direction %s)" % str(dir))
	_drive_gore_until(map, float(entry["pop_seconds"]) + float(entry["hop_seconds"]) + 0.02)
	check(map.decoy_gore.active and not left.visible and not right.visible, tag + "and vanish")
	check(other.global_transform == other_xform, tag + "the other traveler is untouched")
	_finish_gore(map)
	check(not map.decoy_gore.active and map.find_child("DecoyGoreFx", false, false) == null and _particle_count(map) == 1, tag + "the beat ends: no ears, no blood, only the steam")
	check(picker.global_transform == base_xform and picker.body_color() == base_color and picker.scale == Vector3.ONE, tag + "the picker's head is as before: no leftover ears, same place, rotation, scale and tint")
	check(map.picks_allowed() and plant.letter == "" and plant.scale == Vector3.ONE, tag + "play resumes, the plant is unchanged")
	map.free()
	get_tree().paused = false

	# ---- deulssuk_drunk ----
	entry = table["deulssuk_drunk"]
	tag = "deulssuk_drunk: "
	var spots := {"mid": Vector2(30.0, 0.0), "far left corner": Vector2(0.6, -11.4), "near right": Vector2(62.5, 10.0)}
	for label in spots:
		map = await _seeded_map(_seed_with_decoy("deulchuknamu", "harm"), {"ddeok": 1})
		picker = map.travelers["fernanda"]
		other = map.travelers["nestor"]
		var spot: Vector2 = spots[label]
		picker.global_position = _ground_point(map, spot.x, minf(spot.y, map.near_limit_at(spot.x) - 0.1))
		map.update_camera(0.0, true)
		base_pos = picker.global_position
		base_xform = picker.global_transform
		base_color = picker.body_color()
		other_xform = other.global_transform
		plant = _decoy_of(map, "deulchuknamu", "harm")
		var t: String = tag + label + ": "
		var boxes := _prop_boxes(map)
		map.pick_plant(plant)
		check(GameState.heart_units["fernanda"] == GameState.max_units() - 1 and map.decoy_gore.active and map.decoy_gore.gore_id == "deulssuk_drunk", t + "half a heart off the picker and the beat starts")
		fx = map.find_child("DecoyGoreFx", false, false) as Node3D
		var radius: float = fx._stagger_radius
		if label == "mid":
			check(radius > 0.3, t + "there is room to stagger round a circle (radius %.2f m)" % radius)
		var all_walkable := true
		var clear_of_props := true
		var farthest := 0.0
		var bobs := 0
		var in_bob := false
		var wobble := 0.0
		var base_z := base_xform.basis.get_euler().z
		while not map.decoy_gore.popped:
			map.tick_gore(1.0 / 60.0)
			var here := Vector2(picker.global_position.x, picker.global_position.z)
			var at_start := here.is_equal_approx(Vector2(base_pos.x, base_pos.z))  # (props have no collision: the picker may start inside one)
			all_walkable = all_walkable and (map._gore_walkable(here) or (radius == 0.0 and at_start))
			for box: AABB in boxes:
				clear_of_props = clear_of_props and (radius == 0.0 or not Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(0.35).has_point(here))
			farthest = maxf(farthest, here.distance_to(Vector2(base_pos.x, base_pos.z)))
			var bob: float = picker.global_position.y - map.terrain.height_at(picker.global_position.x)
			if bob > 0.03 and not in_bob:
				bobs += 1
			in_bob = bob > 0.03
			wobble = maxf(wobble, absf(picker.rotation.z - base_z))
		check(all_walkable and clear_of_props, t + "the stagger stays inside the walk limits and off every prop")
		check((radius == 0.0 and farthest < 0.01) or (radius > 0.0 and absf(farthest - 2.0 * radius) < 0.05), t + "the picker staggers round the circle (%.2f m from the start at most, radius %.2f)" % [farthest, radius])
		check(bobs == int(entry["hiccups"]), t + "it hiccups %d times (%d bobs)" % [int(entry["hiccups"]), bobs])
		check(wobble > 0.05, t + "and wobbles (%.2f rad)" % wobble)
		check(picker.global_position.is_equal_approx(base_pos), t + "the picker is back at its start position at the pop")
		var fountain := fx.find_child("Fountain", false, false) as CPUParticles3D
		var puddle := fx.find_child("Puddle", false, false) as MeshInstance3D
		check(fountain != null and fountain.emitting and fountain.amount == int(entry["fountain_particles"]), t + "a fountain starts at the pop")
		if fountain != null:
			var color: Color = fountain.color
			check(color.r > color.g and color.b > color.g, t + "it is purple")
			check(fountain.direction.y > 0.0 and fountain.direction.z > 0.0 and fountain.gravity.y < 0.0, t + "it arcs up and toward the camera, then falls under gravity")
			check(fountain.global_position.y > base_pos.y + 1.0, t + "out of the mouth, not the feet")
		_drive_gore_until(map, float(entry["pop_seconds"]) + float(entry["fountain_seconds"]) + 0.05)
		check(fountain != null and not fountain.emitting, t + "the fountain stops after fountain_seconds")
		var ground_y: float = map.terrain.height_at(puddle.global_position.x)
		check(puddle != null and absf(puddle.global_position.y - (ground_y + 0.03)) < 0.01 and puddle.global_position.z > base_pos.z + 0.5, t + "a puddle lies on the ground where the arc lands, toward the camera")
		_drive_gore_until(map, float(entry["pop_seconds"]) + 0.9)
		check(puddle.scale.x > 0.99, t + "it has spread")
		while map.decoy_gore.active and map.decoy_gore.elapsed < float(entry["duration"]) - 0.02:
			map.tick_gore(1.0 / 60.0)
		check(((puddle.mesh as CylinderMesh).material as StandardMaterial3D).albedo_color.a < 0.1 , t + "and fades by the end")
		check(picker.global_position.is_equal_approx(base_pos), t + "the picker ends the beat where it started")
		check(other.global_transform == other_xform, t + "the other traveler is untouched")
		_finish_gore(map)
		check(map.find_child("DecoyGoreFx", false, false) == null and _particle_count(map) == 1, t + "nothing is left: no fountain, no puddle, only the steam")
		check(picker.global_transform == base_xform and picker.body_color() == base_color and picker.scale == Vector3.ONE and map.picks_allowed(), t + "the picker is exactly as before")
		map.free()
		get_tree().paused = false
	# With no walkable room at all the picker wobbles on the spot.
	map = await _seeded_map(_seed_with_decoy("deulchuknamu", "harm"), {})
	picker = map.travelers["fernanda"]
	base_pos = picker.global_position
	var solo := DecoyGoreFxScript.new()
	map.add_child(solo)
	solo.setup(picker, "deulssuk_drunk", entry, map._blood, Color.RED, {"walkable": func(_p): return false})
	var stayed := true
	for i in 40:
		solo.advance(1.0 / 60.0, float(i) / 40.0)
		stayed = stayed and Vector2(picker.global_position.x, picker.global_position.z).is_equal_approx(Vector2(base_pos.x, base_pos.z))
	check(solo._stagger_radius == 0.0 and stayed, tag + "where no circle fits the picker stays on the spot instead of walking into a prop or off the map")
	solo.finish()
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_new_gore_scene")


func _pick_new_harm(map: Node3D, kind_id: String) -> Node3D:
	var plant := _decoy_of(map, kind_id, "harm")
	map.pick_plant(plant)
	return plant


## The two new beats go through the same gating, lethal ordering and restart cleanup as the old ones.
func test_new_gore_flow() -> void:
	for pair in NEW_GORE:
		var kind_id: String = pair[0]
		var seed_value := _seed_with_decoy(kind_id, "harm")
		var tag: String = pair[1] + ": "
		# Gating while the beat plays.
		var map: Node3D = await _seeded_map(seed_value, {"ddeok": 1})
		_pick_new_harm(map, kind_id)
		var live := _plant_of(map, "target", 0)
		var player_pos: Vector3 = map.player.global_position
		check(not map.picks_allowed() and not map.pick_nearest(), tag + "no pick during the beat")
		map.pick_plant(live)
		check(live.letter != "" and map.picking.basket.is_empty(), tag + "pick_plant takes nothing")
		check(not map.click(Vector2(640, 360)) and not map.open_spelling("ma") and not map.open_pause_menu() and not map.open_backpack() and not get_tree().paused, tag + "no click-walk, spelling view, pause menu or backpack")
		map.step(Vector2.RIGHT, 0.5)
		check(map.player.global_position == player_pos, tag + "nobody walks")
		var countdown_left: float = map.countdown.left
		map.countdown.paused = false
		map.step(Vector2.ZERO, 1.0 / 60.0)
		check(map.countdown.paused and map.countdown.left == countdown_left, tag + "the stuck countdown stands still")
		_finish_gore(map)
		check(map.picks_allowed() and map.open_backpack() and map.close_backpack(), tag + "after the beat everything works again")
		map.free()
		get_tree().paused = false
		# A lethal pick: gore first, death one tick after.
		map = await _seeded_map(seed_value, {"ddeok": 1})
		GameState.heart_units["fernanda"] = 1
		var deaths: Array = []
		var on_death := func(dead, _survivor, _injury): deaths.append(dead)
		GameState.travelers_died.connect(on_death)
		var beats := [0]
		var restarts := [0]
		map.death_beat_started.connect(func(): beats[0] += 1)
		map.restarted.connect(func(): restarts[0] += 1)
		_pick_new_harm(map, kind_id)
		check(deaths == ["fernanda"] and GameState.heart_units["fernanda"] == 0 and map.decoy_gore.active and beats[0] == 0, tag + "the damage is applied at the pick and the death announced once, the gore starts first")
		var gore_end := -1
		var death_tick := -1
		var overlap := false
		var n := 0
		while death_tick < 0 and n < 1000:
			n += 1
			map.tick_gore(1.0 / 60.0)
			overlap = overlap or (map.decoy_gore.active and map.is_death_beat_playing())
			if gore_end < 0 and not map.decoy_gore.active:
				gore_end = n
				check(not map.is_death_beat_playing() and map.find_child("DecoyGoreFx", false, false) == null, tag + "when the gore ends its shapes are gone and the death has not begun")
			if map.is_death_beat_playing():
				death_tick = n
		check(not overlap and gore_end > 0 and death_tick == gore_end + 1, tag + "gore and death never overlap: the death begins one tick after the gore (gore %d, death %d)" % [gore_end, death_tick])
		var seconds := float(_config()["decoy_gore"][pair[1]]["duration"])
		check(absf(gore_end / 60.0 - seconds) < 0.05, tag + "the gore ran its full duration first (%.2f s)" % (gore_end / 60.0))
		map.tick_beat(100.0)
		GameState.travelers_died.disconnect(on_death)
		check(beats[0] == 1 and restarts[0] == 1 and deaths == ["fernanda"] and not map.is_gore_playing(), tag + "one death sequence, one restart, no second death")
		check(GameState.heart_units["fernanda"] == GameState.max_units() and GameState.inventory.snapshot() == {"ddeok": 1}, tag + "hearts and backpack are the scene-start ones")
		map.free()
		get_tree().paused = false
		# A restart in the middle of the beat leaves nothing behind.
		map = await _seeded_map(seed_value, {"ddeok": 1})
		var picker: Node3D = map.travelers["fernanda"]
		var base_xform: Transform3D = picker.global_transform
		var base_color: Color = picker.body_color()
		_pick_new_harm(map, kind_id)
		_drive_gore_until(map, float(_config()["decoy_gore"][pair[1]]["pop_seconds"]) + 0.15)
		check(map.decoy_gore.active and map.decoy_gore.popped, tag + "(setup) the beat is past its pop")
		map._restart()
		check(not map.decoy_gore.active and not map.is_gore_playing() and map.find_child("DecoyGoreFx", false, false) == null and _particle_count(map) == 1, tag + "a restart mid-beat leaves no beat, no shapes and no blood (only the steam)")
		check(picker.global_transform == base_xform and picker.body_color() == base_color and GameState.heart_units["fernanda"] == GameState.max_units(), tag + "the picker and the hearts are as at the scene start")
		map.tick_gore(1.0)
		check(not map.is_death_beat_playing() and map.picks_allowed() and not map.countdown.paused, tag + "nothing starts later on its own")
		map.free()
		# A death sequence begun in the middle of the beat drops the gore.
		map = await _seeded_map(seed_value, {})
		picker = map.travelers["fernanda"]
		base_xform = picker.global_transform
		_pick_new_harm(map, kind_id)
		_drive_gore_until(map, 0.4)
		map.begin_death_beat()
		check(not map.decoy_gore.active and map.find_child("DecoyGoreFx", false, false) == null and map.is_death_beat_playing() and picker.global_transform == base_xform, tag + "a death in the middle of the beat drops the gore and resets the picker")
		map.tick_beat(100.0)
		map.free()
		get_tree().paused = false
	GameState.new_hike()
	_section_done("test_new_gore_flow")


func test_gore_captions() -> void:
	var style: Dictionary = _config()["decoy_gore"]["caption_style"]
	var all_kinds := [["keuncheonnamseong", "face_swell_pop", ""], ["butsunnamu", "convulse_eyes_pop", ""], ["norugui", "deer_ears_rip", "노루 귀"], ["deulchuknamu", "deulssuk_drunk", "들쭉술"]]
	for row in all_kinds:
		var map: Node3D = await _seeded_map(_seed_with_decoy(row[0], "harm"), {})
		var picker: Node3D = map.travelers["fernanda"]
		var base_pos: Vector3 = picker.global_position
		var tag: String = row[1] + ": "
		_pick_new_harm(map, row[0])
		var fx := map.find_child("DecoyGoreFx", false, false) as Node3D
		var caption := fx.find_child("GoreCaption", false, false) as Label3D
		if row[2] == "":
			check(caption == null, tag + "no caption")
		else:
			check(caption != null and caption.text == row[2], tag + "the caption reads '%s'" % row[2])
			if caption != null:
				check(caption.font.resource_path.ends_with("NotoSansKR-VariableFont_wght.ttf"), tag + "in Noto Sans KR")
				check(caption.font_size * caption.pixel_size >= 0.4 and caption.billboard == BaseMaterial3D.BILLBOARD_ENABLED and not caption.shaded, tag + "readable: %.2f m tall, billboarded, unshaded" % (caption.font_size * caption.pixel_size))
				check(caption.no_depth_test and caption.render_priority == int(style["render_priority"]) and caption.render_priority > int(map.reward_label_config["render_priority"]) and caption.outline_render_priority < caption.render_priority, tag + "in front of steam, particles and the reward label, its outline behind its text")
				check(absf(caption.global_position.x - base_pos.x) < 0.01 and caption.global_position.y >= base_pos.y + 2.0, tag + "above the picker (%.1f m up)" % (caption.global_position.y - base_pos.y))
				_drive_gore_until(map, float(map.decoy_gore.duration) - 0.05)
				check(map.decoy_gore.active and caption.is_inside_tree(), tag + "it stays up for the whole beat")
		_finish_gore(map)
		check(map.find_child("GoreCaption", true, false) == null, tag + "and is gone when the beat ends")
		map.free()
		get_tree().paused = false
		# show_captions false turns all of them off.
		map = await _seeded_map(_seed_with_decoy(row[0], "harm"), {})
		map.gore_table = map.gore_table.duplicate(true)
		map.gore_table["show_captions"] = false
		_pick_new_harm(map, row[0])
		check(map.decoy_gore.active and map.find_child("GoreCaption", true, false) == null, tag + "with show_captions false there is no caption, and the beat still plays")
		_finish_gore(map)
		map.free()
		get_tree().paused = false
	GameState.new_hike()
	_section_done("test_gore_captions")


## Everything drawn, as one string: every built-in property of a node or resource and of its children (script variables, such as a plant's
## outcome, and node names are left out: they are not what the player sees).
func _dump(thing: Object) -> String:
	var parts: Array[String] = [thing.get_class()]
	for p in thing.get_property_list():
		if (int(p["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0 or (int(p["usage"]) & PROPERTY_USAGE_STORAGE) == 0 or p["name"] == "name" or p["name"] == "script":
			continue
		var value: Variant = thing.get(p["name"])
		if value is Node:
			continue
		if value is Object and value != null:
			parts.append("%s=%s" % [p["name"], _dump(value)])
		else:
			parts.append("%s=%s" % [p["name"], str(value)])
	if thing is Node:
		for child in thing.get_children():
			parts.append(_dump(child))
	return "{" + ",".join(parts) + "}"


const PlantScript := preload("res://scenes/foraging/plant.gd")


func test_hidden_outcome() -> void:
	for kind in _hangul_plants():
		if kind["kind"] != "decoy":
			continue
		var harm := PlantScript.new()
		harm.setup(kind, "ㅏ", "harm")
		var reward := PlantScript.new()
		reward.setup(kind, "ㅏ", "reward")
		var tag: String = kind["id"] + ": "
		check(harm.outcome != reward.outcome and harm.kind != reward.kind, tag + "(setup) the two plants differ in the rolled outcome only")
		check(harm.tooltip_text() == "???" and reward.tooltip_text() == "???", tag + "the hover name is ??? for both")
		check(_dump(harm) == _dump(reward), tag + "everything drawn is identical: transform, scale, meshes, colours, materials, letter label, pick area")
		check(not harm.name.contains("harm") and not reward.name.contains("reward") and not harm.name.contains("reward"), tag + "and no node name gives the outcome away")
		check(harm.letter == reward.letter and harm.scale == reward.scale and harm.get_child_count() == reward.get_child_count(), tag + "same letter, scale and parts")
		harm.free()
		reward.free()
	# In a scene: the hover name, the reach ring and the pick area behave the same.
	var seed_value := -1
	var placement := _new_placement()
	var rng := RandomNumberGenerator.new()
	for s in range(1, 400):
		rng.seed = s
		var by_kind := {}
		for d in placement.choose(rng)["decoys"]:
			by_kind[d["kind"]] = by_kind.get(d["kind"], {})
			by_kind[d["kind"]][d["outcome"]] = true
		for kind_id in by_kind:
			if by_kind[kind_id].size() == 2 and seed_value < 0:
				seed_value = s
	check(seed_value > 0, "(setup) a scene with both outcomes of one kind exists (seed %d)" % seed_value)
	var map: Node3D = await _seeded_map(seed_value)
	var kind_id := ""
	for plant in map.plants:
		if plant.outcome != "" and _decoy_of(map, plant.kind_id, "harm") != null and _decoy_of(map, plant.kind_id, "reward") != null:
			kind_id = plant.kind_id
	check(kind_id != "", "(setup) the scene has a harm and a reward decoy of one kind (%s)" % kind_id)
	if kind_id != "":
		var rings := []
		var texts := []
		var hits := []
		for outcome in ["harm", "reward"]:
			var plant := _decoy_of(map, kind_id, outcome)
			_stand_near(map, plant)
			map.update_camera(0.0, true)
			map.step(Vector2.ZERO, 1.0 / 60.0)
			var target: Dictionary = map.picking.nearest_target(Vector2(map.player.global_position.x, map.player.global_position.z))
			var ring_size: Vector3 = map._ring.mesh.get_aabb().size
			var ring_color: Color = map._ring_material.albedo_color
			rings.append([Vector2(ring_size.x, ring_size.z), Color(ring_color.r, ring_color.g, ring_color.b), map._ring.visible])
			var screen: Vector2 = map.camera.unproject_position(plant.global_position + Vector3(0.0, 0.8, 0.0))
			map.update_hover(screen, 0.0)
			texts.append([map._tooltip_label.text, map._tooltip.visible])
			hits.append([map.plant_at(screen) == plant, target["type"]])
		check(rings[0] == rings[1], "the reach ring is the same size, colour and visibility for a harm and a reward decoy of one kind")
		check(texts[0] == texts[1] and texts[0][0] == "???", "the hover name is ??? for both, shown the same way")
		check(hits[0] == hits[1] and hits[0][0], "and both are found by the pointer and by Space the same way")
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_hidden_outcome")


func test_slot_generator() -> void:
	var data_path := "res://data/mountains/hallasan.json"
	var before := FileAccess.get_md5(data_path)
	var tool = load("res://tools/generate_slots.gd").new()
	check(not tool.autorun, "(setup) the tool does not run by itself when it is only loaded")
	add_child(tool)
	var report: Dictionary = tool.run(PackedStringArray())
	check(report["current"]["valid"] and report["current"]["count"] == 24 and report["current"]["problems"].is_empty(), "the validity check reports the 24 current slots valid against the real scene (%s)" % str(report["current"]["problems"]))
	check(report["candidate_check"]["valid"] and report["candidates"].size() == 24, "it also generates 24 candidate slots, valid with their margins (%s)" % str(report["candidate_check"]["problems"]))
	check(report["written"] == "" and FileAccess.get_md5(data_path) == before, "without --write nothing is written: the data file is byte for byte as it was")
	check(report["seed"] == 1 and report["step"] == 0.5 and report["count"] == 24, "the defaults are seed 1, step 0.5 m, 24 slots")
	check(not JSON.stringify(report).is_empty() and JSON.parse_string(JSON.stringify(report)) is Dictionary, "the report is JSON")
	var again: Dictionary = tool.run(PackedStringArray())
	check(str(again["candidates"]) == str(report["candidates"]), "the same arguments give the same candidates (deterministic)")
	var other: Dictionary = tool.run(PackedStringArray(["--seed=2", "--step=1.0", "--count=10"]))
	check(other["seed"] == 2 and other["step"] == 1.0 and other["candidates"].size() == 10 and other["candidate_check"]["valid"] and str(other["candidates"]) != str(report["candidates"]), "another seed, step and count give another valid list of 10")
	# A slot that breaks a rule is reported.
	var live: Dictionary = Content.mountain("hallasan")["foraging"]
	var saved: Array = live["decoy_placement"]["slots"].duplicate(true)
	live["decoy_placement"]["slots"][0] = [_target_spots()[3].x + 0.5, _target_spots()[3].y]
	var broken: Dictionary = tool.run(PackedStringArray())
	live["decoy_placement"]["slots"] = saved
	check(not broken["current"]["valid"] and not broken["current"]["problems"].is_empty() and str(broken["current"]["problems"]).contains("target plant"), "a slot on a target plant makes the validity check fail and say why (%s)" % str(broken["current"]["problems"]))
	check(FileAccess.get_md5(data_path) == before, "still nothing written")
	# --write changes only the slots, and only the file it is told to.
	var copy_path := "user://slots_test.json"
	var copy := FileAccess.open(copy_path, FileAccess.WRITE)
	copy.store_string(FileAccess.get_file_as_string(data_path))
	copy.close()
	var wrote: Dictionary = tool.run(PackedStringArray(["--write", "--data=" + copy_path, "--seed=3", "--count=12"]))
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(copy_path))
	check(wrote["written"] == copy_path and parsed is Dictionary, "--write with --data writes the file it is told to, still valid JSON")
	if parsed is Dictionary:
		var slots: Array = parsed["foraging"]["decoy_placement"]["slots"]
		var same_slots: bool = slots.size() == 12 and wrote["candidates"].size() == 12
		for i in mini(slots.size(), 12):
			same_slots = same_slots and absf(float(slots[i][0]) - float(wrote["candidates"][i][0])) < 0.001 and absf(float(slots[i][1]) - float(wrote["candidates"][i][1])) < 0.001
		check(same_slots, "the 12 generated slots are in the file")
		var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(data_path))
		parsed["foraging"]["decoy_placement"]["slots"] = original["foraging"]["decoy_placement"]["slots"]
		check(str(parsed) == str(original), "and nothing else in the file changed")
	check(FileAccess.get_md5(data_path) == before, "the real data file was not touched by --write to a copy")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(copy_path))
	tool.free()
	GameState.new_hike()
	_section_done("test_slot_generator")


## The first seed whose roll has at least `least` piles, or -1.
func _seed_with_piles(least: int, need_harm := false) -> int:
	var placement := _new_placement()
	var piles := _new_piles()
	for seed_value in range(1, 5000):
		var roll := _offline_roll(seed_value, placement, piles)
		if roll["piles"].size() >= least and (not need_harm or roll["layout"]["decoys"].any(func(d): return d["outcome"] == "harm")):
			return seed_value
	return -1


func _stand_by_pile(map: Node3D, index: int, offset := Vector2(0.4, 0.2)) -> void:
	var spot: Vector2 = map.picking.pile_spot(index) + offset
	map.player.global_position = Vector3(spot.x, map.terrain.height_at(spot.x), spot.y)
	map.update_camera(0.0, true)


## What a pile pick must not touch, at a glance. `with_discovery` is left out where walking changes it.
func _bookkeeping(map: Node3D, with_discovery := true) -> Array:
	var state := [map.picking.basket.duplicate(), map.picking.letters_left(), map.spares.credit_total(), map.spare_plants.size(), map.stuck_log.size(), map.stuck_verdict["stuck"], map.stuck_verdict["reason"], map.spelling.solved("ma").size(), map.countdown.running, GameState.heart_units.duplicate()]
	if with_discovery:
		state.append(map.discovery.entries.size())
	return state


func test_pile_pickup() -> void:
	var seed_value := _seed_with_piles(2, true)
	check(seed_value > 0, "(setup) a seed with two or more piles exists (%d)" % seed_value)
	var map: Node3D = await _seeded_map(seed_value)
	var roll := _offline_roll(seed_value, _new_placement(), _new_piles())
	check(map.piles.size() == roll["piles"].size() and map.picking.pile_count() == map.piles.size() and map.picking.piles_left() == map.piles.size(), "(setup) the map has the rolled piles (%d)" % map.piles.size())
	var pile: Node3D = map.piles[0]
	var amount: int = map.picking.pile_amount(0)
	check(amount == roll["piles"][0]["amount"] and pile.amount == amount, "the pile holds the rolled amount (%d)" % amount)
	check(Vector2(pile.position.x, pile.position.z).is_equal_approx(roll["piles"][0]["spot"]) and is_equal_approx(pile.position.y, map.terrain.height_at(pile.position.x)), "it lies on the ground at its slot")
	# Looks: the icon, small, no letter or name, no glint.
	check(pile.find_children("*", "Label3D", true, false).is_empty(), "a pile has no letter and no label")
	check(pile.find_children("*", "Light3D", true, false).is_empty() and pile.find_children("*", "CPUParticles3D", true, false).is_empty() and pile.find_children("*", "GPUParticles3D", true, false).is_empty(), "no light, glint or particles on it")
	var sprite := pile.find_child("Sprite", true, false) as Sprite3D
	check(sprite != null and not sprite.shaded and sprite.texture is ViewportTexture, "it shows the code-drawn icon on an unshaded sprite")
	check(sprite != null and sprite.texture.get_size().x * sprite.pixel_size <= 0.7, "the icon is small (%.2f m)" % (sprite.texture.get_size().x * sprite.pixel_size))
	var drawn := pile.find_children("*", "Control", true, false)
	check(drawn.size() == 1 and drawn[0].icon_id == "baekseolgi", "the picture is the baekseolgi icon of items.json")
	check(not pile.has_method("tooltip_text") and not pile.has_method("take_letter"), "a pile is not a plant")
	check(not map.plants.has(pile) and map.plants.size() == 28 + roll["layout"]["decoys"].size(), "it is not among the plants")
	# The ring: identical for a pile and for a plant.
	_stand_by_pile(map, 0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	var pile_ring: Vector3 = map._ring.mesh.get_aabb().size
	check(map._ring.visible and map._ring.global_position.is_equal_approx(pile.global_position), "standing in reach of a pile shows the reach ring on it")
	check(not map._tooltip.visible and map._tip_plant == null, "and no name appears")
	var lone := _lone_plant(map, "target")
	if lone == null:
		lone = map.plants[0]
	_stand_near(map, lone)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	var plant_ring: Vector3 = map._ring.mesh.get_aabb().size
	check(map._ring.visible and map._ring.global_position.is_equal_approx(lone.global_position), "(control) the ring shows on a plant in reach")
	check(is_equal_approx(pile_ring.x, plant_ring.x) and is_equal_approx(pile_ring.z, plant_ring.z), "the ring around a pile is the same size as around a plant")
	_stand_by_pile(map, 0)
	map.step(Vector2.ZERO, 1.0 / 60.0)
	check(is_equal_approx(map._ring_material.albedo_color.a, map.picking.ring_alpha_at(map._ring_time)), "and pulses the same way")
	# Space picks it.
	var before := _bookkeeping(map)
	var puffs := _particle_count(map)
	var labels := map.find_children("*", "Label3D", false, false).size()
	check(map.pick_nearest(), "Space picks the pile")
	check(GameState.inventory.snapshot() == {"ddeok": amount}, "the backpack gains exactly the pile's amount (%d)" % amount)
	check(map.piles[0] == null and (pile.is_queued_for_deletion() or pile.get_parent() == null), "the pile is removed from the world")
	check(map.picking.piles_left() == map.piles.size() - 1 and map.picking.nearest_pile(map.picking.pile_spot(0)) < 0, "and from Picking: it cannot be picked again")
	var floating := map.find_children("*", "Label3D", false, false)
	check(floating.size() == labels + 1 and floating[floating.size() - 1].text == "+%d DDEOK" % amount, "a '+%d DDEOK' label appears" % amount)
	check(floating[floating.size() - 1].render_priority == int(_config()["decoy_rewards"]["floating_label"]["render_priority"]), "drawn in front, with the existing label's render priority")
	check(_particle_count(map) == puffs, "no steam")
	check(_bookkeeping(map) == before, "nothing else changed: no hearts, basket, letters, discovery, spares, stuck check or spelling")
	check(not map.pick_nearest(), "a second Space finds nothing")
	await get_tree().create_timer(float(map.reward_label_config["seconds"]) + 0.3).timeout
	check(map.find_children("*", "Label3D", false, false).size() == labels, "the label rises, fades and frees itself")

	# The partner never picks.
	var second: Node3D = map.piles[1]
	var second_amount: int = map.picking.pile_amount(1)
	var start: Vector2 = _start_spots()[0]  # 6 m from every plant and pile
	map.player.global_position = Vector3(start.x, map.terrain.height_at(start.x), start.y)
	map.partner.global_position = Vector3(second.position.x + 0.3, second.position.y, second.position.z)
	map.update_camera(0.0, true)
	check(not map.pick_nearest(), "with only the partner beside the pile, Space picks nothing")
	check(map.picking.nearest_pile(Vector2(map.partner.global_position.x, map.partner.global_position.z)) == 1 and GameState.inventory.snapshot() == {"ddeok": amount}, "(the pile is within the partner's reach; the backpack is as it was)")
	for i in 5:
		map.step(Vector2.ZERO, 1.0 / 60.0)
	check(map.piles[1] == second and map.picking.piles_left() == 1, "the partner walking by never takes it")

	# Blocked states.
	_stand_by_pile(map, 1)
	var held := GameState.inventory.snapshot()
	var blocked := func(label: String) -> void:
		var screen_at: Vector2 = map.camera.unproject_position(second.global_position + Vector3(0.0, 0.3, 0.0))
		check(not map.pick_nearest() and not map.click(screen_at) and map.piles[1] == second and GameState.inventory.snapshot() == held, "%s: Space and a click take nothing" % label)
	check(map.open_pause_menu(), "(setup) the pause menu opens")
	blocked.call("pause menu")
	map.pause_menu.close()
	map._on_pause_chosen("resume")
	check(map.open_backpack(), "(setup) the backpack opens")
	blocked.call("backpack")
	map.close_backpack()
	map.restarting = true
	blocked.call("restarting")
	map.restarting = false
	map.pick_plant(_plant_of(map, "decoy_harm", 0))
	check(map.is_gore_playing(), "(setup) a gore beat plays")
	blocked.call("gore beat")
	_finish_gore(map)
	_stand_by_pile(map, 1)
	check(map.pick_nearest(), "(control) after the beat the pile can be picked")
	check(GameState.inventory.snapshot() == {"ddeok": amount + second_amount}, "(control) and it adds its amount (%d + %d)" % [amount, second_amount])
	map.free()
	get_tree().paused = false

	# Dead travelers, the death beat, the monster, the spelling view.
	for state in ["a dead traveler", "the death beat", "the monster", "the spelling view"]:
		var m: Node3D = await _seeded_map(seed_value)
		var target: Node3D = m.piles[0]
		_stand_by_pile(m, 0)
		var screen_at: Vector2 = m.camera.unproject_position(target.global_position + Vector3(0.0, 0.3, 0.0))
		match state:
			"a dead traveler":
				GameState.heart_units["nestor"] = 0
			"the death beat":
				m.begin_death_beat()
			"the monster":
				m._begin_monster()
			"the spelling view":
				m.discovery.update([_spot_of("ma")], 0.0)
				m.discovery_hud.refresh()
				check(m.open_spelling("ma") and get_tree().paused, "(setup) the spelling view opens")
				Input.parse_input_event(_key_event(KEY_SPACE))
				Input.parse_input_event(_key_event(KEY_SPACE, false))
				await get_tree().process_frame
		var refused := true
		if state != "the spelling view":  # the open view stops the map, so only the key can reach it
			refused = not m.pick_nearest() and not m.click(screen_at)
		check(refused and m.piles[0] == target and GameState.inventory.is_empty() and m.picking.piles_left() == m.piles.size(), "%s: a pile cannot be picked" % state)
		m.free()
		get_tree().paused = false
		GameState.new_hike()

	# A click walks the human traveler to the pile and picks it on arrival.
	map = await _seeded_map(seed_value)
	var goal: Node3D = map.piles[0]
	amount = map.picking.pile_amount(0)
	var spot := Vector2(goal.position.x, goal.position.z)
	var from := Vector2(clampf(spot.x - 4.0, 1.0, 62.0), clampf(spot.y, -9.0, 9.0))
	map.player.global_position = Vector3(from.x, map.terrain.height_at(from.x), from.y)
	map.partner.global_position = map.player.global_position + Vector3(-1.0, 0.0, 0.0)
	map.update_camera(0.0, true)
	var screen: Vector2 = map.camera.unproject_position(goal.global_position + Vector3(0.0, 0.3, 0.0))
	check(map.pile_at(screen) == goal and map.plant_at(screen) == null, "the hover ray finds the pile on its own layer, not as a plant")
	var before_walk := _bookkeeping(map, false)
	check(map.click(screen) and map.picking.walk_pile == 0 and map.picking.walk_target == -1, "a left click on a pile starts a walk to it")
	var ticks := 0
	while map.picking.is_walking() and ticks < 900:
		map.step(Vector2.ZERO, 1.0 / 60.0)
		ticks += 1
	check(GameState.inventory.snapshot() == {"ddeok": amount} and map.piles[0] == null, "the walk ends with the pile picked (%d DDEOK, %d ticks)" % [amount, ticks])
	check(_bookkeeping(map, false) == before_walk, "walking to and picking a pile changed no letters, spares, hearts or stuck state")
	map.free()
	get_tree().paused = false
	GameState.new_hike()

	# Piles change neither the word flow nor the stuck verdict.
	map = await _seeded_map(seed_value)
	var verdict_before: Dictionary = map.evaluate_stuck("before piles")
	var total := 0
	for i in map.piles.size():
		_stand_by_pile(map, i)
		check(map.pick_nearest(), "(setup) pile %d is picked" % i)
		total += map.picking.pile_amount(i)
	var verdict_after: Dictionary = map.evaluate_stuck("after piles")
	check(verdict_before["stuck"] == verdict_after["stuck"] and verdict_before["reason"] == verdict_after["reason"], "the stuck verdict is the same with every pile taken")
	check(map.spares.credit_total() == 0 and map.spare_plants.is_empty() and map.picking.basket.is_empty() and map.picking.letters_left() == map.plants.size(), "no spares, credits or basket letters came from piles")
	check(map._available_letters().size() == 28, "the letters still to find are only the 28 target letters")
	check(GameState.inventory.count("ddeok") == total and total > 0, "all piles together gave exactly their amounts (%d)" % total)
	map.free()
	get_tree().paused = false
	GameState.new_hike()
	_section_done("test_pile_pickup")


func test_pile_restart() -> void:
	var window_before := get_window().size
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var seed_value := _seed_with_piles(1)
	var original_scene := get_tree().current_scene
	for path in ["death", "menu"]:
		var doomed: Node3D = await _current_map(seed_value)
		GameState.inventory.add("ddeok", 4)  # held at the scene start, as if carried in
		GameState.begin_scene("foraging")
		_stand_by_pile(doomed, 0)
		var gained: int = doomed.picking.pile_amount(0)
		check(doomed.pick_nearest() and GameState.inventory.count("ddeok") == 4 + gained, "%s: the pile's DDEOK is in the backpack (4 + %d)" % [path, gained])
		Foraging.seed_override = seed_value  # a reload reads it again
		if path == "death":
			doomed.begin_death_beat()
			doomed.tick_beat(100.0)
		else:
			doomed.open_pause_menu()
			doomed.pause_menu.close()
			doomed._on_pause_chosen("restart")
		check(GameState.inventory.count("ddeok") == 4, "%s: after the restart the backpack is its scene-start contents: the pile's DDEOK is gone" % path)
		for i in 4:
			await get_tree().process_frame
		Foraging.seed_override = -1
		var fresh: Node = get_tree().current_scene
		check(fresh != doomed and fresh.has_method("picks_allowed"), "(setup) %s: reloaded" % path)
		if fresh != doomed and fresh.has_method("picks_allowed"):
			check(fresh.piles.size() == fresh.pile_roll.size() and fresh.piles.size() >= 1 and fresh.piles[0] != null, "%s: the new scene has its piles back, the picked one too" % path)
			fresh.set_process(false)
			fresh.free()
		get_tree().current_scene = original_scene
		get_tree().paused = false
	# Piles re-roll at every scene start: random starts do not all lay the same piles.
	var keys := {}
	var placement := _new_placement()
	var piles := _new_piles()
	GameState.new_hike()
	Foraging.legacy_layout = false
	for n in 8:
		var m: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
		add_child(m)
		keys[str(m.pile_roll)] = true
		check(str(m.pile_roll) == str(_offline_roll(m.placement_seed, placement, piles)["piles"]), "random start %d: the piles are the roll of its seed" % n)
		m.free()
	print("  %d distinct pile layouts in 8 random scene starts" % keys.size())
	check(keys.size() >= 3, "piles re-roll at every scene start (%d distinct of 8)" % keys.size())
	get_window().size = window_before
	GameState.new_hike()
	_section_done("test_pile_restart")
