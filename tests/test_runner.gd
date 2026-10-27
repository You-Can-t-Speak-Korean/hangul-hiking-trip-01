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
]

## The run fails if fewer checks than this ran. After adding tests, raise it to
## the printed total minus a small margin (currently 5).
const MIN_CHECKS := 933


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
	check(decisions.size() == 1 and decisions[0]["word_id"] == "ma" and not decisions[0]["spawn"] and decisions[0]["reason"] == "no deficit", "step 1: no deficit, so 마 earns no spare")
	check(map.spare_plants.is_empty() and map.plants.size() == 36 and map.picking.plant_count() == 36, "step 1: nothing was spawned")

	# Step 2: a failed block destroys ㄹ and ㅜ. A failure completes no word.
	map.open_spelling("meoru")
	map.spelling_hud.apply(map.spelling.place("ㄹ", 0, 0))
	map.spelling_hud.apply(map.spelling.place("ㅜ", 0, 1))
	map.spelling_hud.tick(1.0)
	check(not map.spelling_hud.is_open() and map.spares.decisions.size() == 1 and map.spare_plants.is_empty(), "step 2: a failed block and a closed view spawn nothing")
	var solved := {}
	for id in map.spares.word_ids():
		solved[id] = map.spelling.solved(id).size()
	var expect: Dictionary = map.spares.choose(solved, map._available_letters())
	print("  scripted run, step 2 (ㄹ and ㅜ destroyed): deficit logic would now say %s" % str(expect))
	check(expect["letter"] == "ㄹ" and expect["deficit"] == 1, "step 2: ㄹ and ㅜ are each short by one; the tie goes to 머루's ㄹ (it comes before ㅜ)")

	# Step 3: 고비 completes. The spawn waits for the view to close.
	check(map.open_spelling("gobi"), "고비 opens")
	var gobi_letters := _word_letters("고비")
	var last := {}
	for b in 2:
		for slot in 2:
			last = map.spelling.place(gobi_letters[b][slot], b, slot)
	check(last["result"] == "complete" and map.spelling.is_done("gobi"), "고비 is judged complete")
	check(map.spare_plants.is_empty() and map.spares.has_pending() and map.spelling_hud.is_open(), "the spare waits: the view is still open")
	map.spelling_hud.apply(last)
	check(not map.spelling_hud.is_open() and map.spare_plants.size() == 1 and not map.spares.has_pending(), "once the view has closed, the spare appears")
	print("  scripted run, step 3 (고비 done): %s" % str(map.spares.decisions[1]))
	var spare: Node3D = map.spare_plants[0]
	solved["gobi"] = 2
	var needed_now: Array = map.spares.needed(solved)
	check(spare.letter == "ㄹ" and needed_now.has(spare.letter), "step 3: the spare carries ㄹ, which an unfinished word still needs")
	check(map.spares.decisions[1]["spawn"] and map.spares.decisions[1]["reason"] == "short of ㄹ by 1", "step 3: the decision says why")
	check(spare.kind_id == "gobi" and spare.hover_name == "royal fern" and spare.kind == "target", "the spare is a plant of the word just finished (고비, royal fern)")
	check(Vector2(spare.position.x, spare.position.z) == map.spares.slots["gobi"] and is_equal_approx(spare.position.y, map.terrain.height_at(spare.position.x)), "it stands at the word's slot, on the ground")
	check(map.plants.size() == 37 and map.picking.plant_count() == 37 and map.plants[36] == spare, "it is the 37th plant, in step with the picking state")
	var after: Dictionary = map.spares.choose(solved, map._available_letters())
	print("  scripted run, step 4 (with the spare on the map): deficit logic says %s" % str(after))
	check(after["letter"] == "ㅜ", "with the spare on the map, ㅜ is what is still short (%s)" % str(after))

	# Grow-in: not pickable until it ends.
	var normal := _normal_plant(map, "gobi")
	check(spare.scale.x < 0.05 and not map.picking.is_pickable(36) and map.picking.has_letter(36), "at spawn the spare is tiny, has its letter, and is locked")
	_stand_near(map, spare)
	map.update_camera(0.0, true)
	map.step(Vector2.ZERO, 0.0)
	var basket_before: int = map.picking.basket.size()
	check(map._tip_plant == spare and map._tooltip_label.text == "royal fern", "walking up to the spare flashes its name, as for any plant")
	check(map.picking.nearest_pickable(Vector2(map.player.global_position.x, map.player.global_position.z)) == -1 and not map.pick_nearest(), "Space does not pick a growing spare")
	check(not map.picking.start_walk(36) and not map._ring.visible, "nor can it be walked to, and the ring is not on it")
	map.step(Vector2.ZERO, 0.25)
	check(spare.scale.x > 0.5 and spare.scale.x < 1.0 and not map.pick_nearest() and map.picking.basket.size() == basket_before, "halfway through the grow-in it is partly grown and still not pickable (scale %.2f)" % spare.scale.x)
	map.step(Vector2.ZERO, 0.3)
	check(spare.scale.is_equal_approx(Vector3.ONE) and map.picking.is_pickable(36), "after grow_seconds it is full size and pickable")
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
	check(map.click(screen) and map.picking.walk_target == 36, "clicking the spare starts a walk to it")
	map.picking.cancel_walk()
	var discovered_before: int = map.discovery.entries.size()
	check(map.pick_nearest() and map.picking.basket.size() == basket_before + 1 and map.picking.basket.back() == "ㄹ" and spare.letter == "", "Space picks it: its ㄹ joins the basket")
	check(not map.pick_nearest() and not map.picking.has_letter(36) and map.spares.spawned.size() == 1, "a picked spare stays letterless and does not respawn")
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
