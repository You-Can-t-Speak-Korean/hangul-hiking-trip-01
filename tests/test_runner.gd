extends Node
## Headless tests. Run:
##   godot --headless --path . res://tests/test_runner.tscn
## Exits with code 0 if everything passes, 1 otherwise.

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
]

## The run fails if fewer checks than this ran. After adding tests, raise it to
## the printed total minus a small margin (currently 5).
const MIN_CHECKS := 530


func check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
	else:
		failed += 1
		print("  FAIL: ", label)


func _section_done(section: String) -> void:
	finished.append(section)


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
	_section_done("test_game_state")


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
		check(["target", "decoy_harm", "decoy_reward"].has(kind["kind"]), "%s has a valid kind" % kind["name"])
		check(["hanging", "sprouting", "unfurling", "on_top"].has(kind["letter_style"]), "%s has a letter_style" % kind["name"])
		if kind["kind"] == "decoy_harm":
			kind_ok = kind_ok and kind.has("injury") and not kind.has("reward")
		if kind["kind"] == "decoy_reward":
			kind_ok = kind_ok and kind.has("reward") and not kind.has("injury")
		check(_zone_range(kind["zone"]).size() == 2, "%s names a real zone" % kind["name"])
		if kind["kind"] == "target":
			var unknown := Hangul.unknown_letters(kind["name"], known)
			check(unknown.size() <= 2, "%s needs at most 2 unknown letters" % kind["name"])
	check(kind_ok, "decoy_harm have an injury id, decoy_reward a reward id")

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
			if placed[i]["kind"] == placed[j]["kind"] and a.distance_to(b) < 4.0:
				same_ok = false
	check(same_ok, "two plants of the same kind are at least 4 m apart")
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
		map.update_hover(on_plant, 0.4)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "solid at 0.4 s")
		var saw_visible := false
		var saw_hidden := false
		for step in 8:  # 0.5 s to 0.9 s, sampled mid-step
			map.update_hover(on_plant, 0.15 if step == 0 else 0.05)
			map.update_hover(on_plant, 0.05)
			if tip.visible:
				saw_visible = true
			else:
				saw_hidden = true
		check(saw_visible and saw_hidden, "flickers between 0.5 s and 0.9 s (visible %s, hidden %s)" % [saw_visible, saw_hidden])
		map.update_hover(on_plant, 0.1)
		check(not tip.visible, "gone at 1.0 s")
		map.update_hover(on_plant, 5.0)
		map.update_hover(on_plant, 0.0)
		check(not tip.visible, "it does not return while the mouse stays on the same plant")
		map.update_hover(empty_point, 0.1)
		check(not tip.visible, "leaving the plant hides it")
		map.update_hover(on_plant, 0.0)
		check(tip.visible and is_equal_approx(tip.modulate.a, 1.0), "it shows again after the mouse leaves and re-enters the plant")
		map.update_hover(on_plant, 1.1)
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
	var differ := per_kind.size() == 4
	var seen := {}
	for id in per_kind:
		differ = differ and per_kind[id].size() == 2 and per_kind[id][0] != per_kind[id][1]
		for letter in per_kind[id]:
			seen[letter] = true
	check(differ, "the two plants of a decoy kind carry different letters")
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
	check(is_equal_approx(float(config["tooltip"]["steady_time"]), 0.5) and is_equal_approx(float(config["tooltip"]["flicker_time"]), 0.4) and is_equal_approx(float(config["tooltip"]["flicker_rate"]), 10.0) and not config["tooltip"].has("show_time") and not config["tooltip"].has("fade_time"), "tooltip steady, flicker time and rate are in the data; the old show/fade values are gone")
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


## Ticks the map until the walk ends (or 10 s pass). Returns the ticks used.
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
