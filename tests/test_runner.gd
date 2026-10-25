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
	print("== Foraging map ==")
	test_foraging()
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


func test_foraging() -> void:
	for action in ["p1_left", "p1_right", "p1_up", "p1_down", "p2_left", "p2_right", "p2_up", "p2_down", "p2_pick"]:
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
	var home := Vector3(map.stage_width / 2.0, 0.0, 0.0)
	p.global_position = home
	p.drive(Vector2.RIGHT, 0.1)
	var straight := p.global_position - home
	check(straight.x > 0.0 and is_zero_approx(straight.z), "input right moves the player right")
	check((-p.global_transform.basis.z).x > 0.9, "the player faces the way it walks")
	p.global_position = home
	p.drive(Vector2.LEFT, 0.1)
	check(p.global_position.x < home.x, "input left moves the player left")
	p.global_position = home
	p.drive(Vector2(0, -1), 0.1)
	check(p.global_position.z < home.z and is_equal_approx(p.global_position.x, home.x), "W moves into the scene")
	p.global_position = home
	p.drive(Vector2(0, 1), 0.1)
	check(p.global_position.z > home.z, "S moves out of the scene")
	p.global_position = home
	p.drive(Vector2(1, 1), 0.1)
	var diagonal := p.global_position - home
	check(is_equal_approx(diagonal.length(), straight.length()), "diagonal speed equals straight speed")

	# Bounds: push into every wall for far longer than it takes to hit it.
	var bounds_ok := true
	for dir in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2(1, 1), Vector2(-1, -1)]:
		p.global_position = home
		for i in 400:
			p.drive(dir, 0.1)
		var q := p.global_position
		if q.x < 0.0 or q.x > map.stage_width or absf(q.z) > map.stage_depth / 2.0:
			bounds_ok = false
	check(bounds_ok, "the player can't leave the stage in any direction")

	# Camera follows in depth as well as along the stage.
	p.global_position = home
	map.update_camera(0.0, true)
	var cam_start: Vector3 = map.camera.global_position
	for i in 40:
		map.step(Vector2(0, -1), 0.05)
	check(map.camera.global_position.z < cam_start.z - 3.0, "walking into the scene moves the camera in depth")
	check(is_equal_approx(map.camera.global_position.y, cam_start.y), "the camera keeps its height")
	var cam_far_z: float = map.camera.global_position.z
	for i in 40:
		map.step(Vector2(0, 1), 0.05)
	check(map.camera.global_position.z > cam_far_z + 3.0, "walking out of the scene moves the camera back")
	p.global_position = Vector3(0.5, 0.0, 0.0)
	map.update_camera(0.0, true)
	var cam_left_x: float = map.camera.global_position.x
	for i in 100:
		map.step(Vector2.RIGHT, 0.05)
	check(map.camera.global_position.x > cam_left_x + 5.0, "the camera follows the player to the right")

	# The view stays over ground or backdrop at all four corners, snapped and
	# while walking there (smoothing must never let the camera slip).
	var half_d: float = map.stage_depth / 2.0
	var corners := [Vector3(0, 0, half_d), Vector3(map.stage_width, 0, half_d),
			Vector3(0, 0, -half_d), Vector3(map.stage_width, 0, -half_d)]
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
	map.player.global_position = Vector3(3.0, 0.0, 0.0)
	map.partner.global_position = Vector3(3.0, 0.0, 1.0)
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


## True if every sampled screen point looks at ground or backdrop: no sky
## below or beside the ground. A ray must hit the ground plane over the ground
## or backdrop footprint, or hit the ridge slab. The top row may look past the
## backdrop (sky above the ridge), but not past its sides.
func _view_over_land(map: Node3D) -> bool:
	var size: Vector2 = map.get_viewport().get_visible_rect().size
	var floor_plane := Plane(Vector3.UP, 0.0)
	var land: Rect2 = map.ground_rect.merge(map.backdrop_rect).grow(0.01)
	var back: Rect2 = map.backdrop_rect
	var ridge := AABB(Vector3(back.position.x, 0.0, back.position.y), Vector3(back.size.x, map.RIDGE_HEIGHT, back.size.y))
	for i in 5:
		for j in 5:
			var point := Vector2(size.x * i / 4.0, size.y * j / 4.0)
			var origin: Vector3 = map.camera.project_ray_origin(point)
			var dir: Vector3 = map.camera.project_ray_normal(point)
			var hit: Variant = floor_plane.intersects_ray(origin, dir)
			if hit == null:
				return false
			var spot := Vector2(hit.x, hit.z)
			if j == 0:
				if spot.x < land.position.x or spot.x > land.end.x:
					return false
			elif not land.has_point(spot) and ridge.intersects_ray(origin, dir) == null:
				return false
	return true
