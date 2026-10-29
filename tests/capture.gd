extends Node
## Needs a display (not headless). Walks the player around the foraging map
## and saves tests/shots/{start,left_near,right_far,middle}.png, plus the
## terrain shots {zone_lower_forest,zone_mid_slope,zone_alpine}.png, and
## {tree_fade,tooltip_0_2s,tooltip_0_65s_flicker_visible,
## tooltip_0_7s_flicker_hidden,tooltip_1_2s_gone,letters_lower_forest,letters_alpine,
## fruits_meoru_butsunnamu,fruit_deulchuk,hud_empty,hud_ma_meoru,hud_all_six,
## letters_decoys_targets,spread_topdown}.png, and the picking shots
## {pick_walking,pick_target_basket,pick_decoy_steam}.png, the reach shots
## {reach_ring_target,reach_ring_decoy,walk_up_flash}.png, and the basket shots
## {basket_empty,basket_1_tile,basket_28_tiles,hud_discovery_two_entries}.png, and the
## spelling shots {spelling_open_3_blocks,spelling_block_locked,spelling_half_filled,
## spelling_failure_flash,spelling_entry_done}.png, and the hearts shots
## {hearts_full,hearts_4_5,hearts_low,blood_burst,death_beat_dim}.png, and the walk-limit
## shots {walk_limit_x0,walk_limit_x32,walk_limit_x64,walk_limit_x32_before}.png. Pass
## `-- --hearts-only` to take only the hearts shots, `-- --walk-limit-only` for the walk-limit shots,
## `-- --stuck-only` for the stuck-countdown and monster shots (they play the placeholder music).

const SHOT_DIR := "res://tests/shots/"
const DELTA := 1.0 / 60.0
const STEPS_PER_FRAME := 4  # walking the whole map in real time takes too long
## Debug marker colour per plant kind for the top-down spread shot.
const MARKER_COLORS := {
	"ma": Color(1.0, 0.2, 0.2), "meoru": Color(0.6, 0.2, 1.0), "minari": Color(0.1, 0.6, 1.0),
	"gosari": Color(1.0, 0.8, 0.1), "gobi": Color(0.1, 0.9, 0.3), "simiro": Color(1.0, 0.45, 0.0),
	"keuncheonnamseong": Color(0.4, 0.4, 0.4), "butsunnamu": Color(0.55, 0.3, 0.1),
	"norugui": Color(1.0, 0.5, 0.8), "deulchuknamu": Color(0.1, 0.1, 0.5),
}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	if "--hearts-only" in OS.get_cmdline_user_args():
		await _hearts_shots()
		get_tree().quit()
		return
	if "--walk-limit-only" in OS.get_cmdline_user_args():
		await _walk_limit_shots()
		get_tree().quit()
		return
	if "--spares-only" in OS.get_cmdline_user_args():
		await _spare_shots()
		get_tree().quit()
		return
	if "--keyboard-only" in OS.get_cmdline_user_args():
		await _keyboard_shots()
		get_tree().quit()
		return
	if "--stuck-only" in OS.get_cmdline_user_args():
		await _stuck_shots()
		get_tree().quit()
		return
	if "--credits-only" in OS.get_cmdline_user_args():
		await _credit_shots()
		get_tree().quit()
		return
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)  # this script drives the map
	map.set_process(false)  # and the hover, so the real mouse can't hide the tooltip
	var half_depth: float = map.stage_depth / 2.0
	await _frames(5)
	_save("start")
	_save("hud_empty")
	_save("zone_lower_forest")
	await _walk_to(map, Vector3(0.0, 0.0, half_depth))
	await _frames(90)
	_save("left_near")
	await _walk_to(map, Vector3(map.stage_width, 0.0, -half_depth))
	await _frames(90)
	_save("right_far")
	await _walk_to(map, Vector3(map.stage_width / 2.0, 0.0, 0.0))
	await _frames(90)
	_save("middle")
	await _walk_to(map, Vector3(36.0, 0.0, 0.0))
	await _frames(90)
	_save("zone_mid_slope")
	await _walk_to(map, Vector3(54.0, 0.0, 0.0))
	await _frames(90)
	_save("zone_alpine")
	# A tree fading over a traveler: the player stands just behind a tree.
	var tree: Node3D = null
	for prop in map.get_node("Props").get_children():
		if prop.get_child_count() == 2 and prop.position.x > 12.0 and prop.position.x < 24.0 and absf(prop.position.z) < 5.0:
			tree = prop
			break
	if tree:
		await _walk_to(map, Vector3(tree.position.x, 0.0, tree.position.z - 2.0))
		for frame in 40:  # let the fade finish (0.2 s)
			map.step(Vector2.ZERO, DELTA)
			await get_tree().process_frame
		print("tree alpha %.2f" % tree.alpha)
		_save("tree_fade")
	# Hover: the tooltip over the nearest target plant in view, just shown and after it has faded.
	await _walk_to(map, Vector3(14.0, 0.0, 0.0))
	await _frames(30)
	var best: Node3D = null
	for plant in map.plants:
		var screen: Vector2 = map.camera.unproject_position(plant.global_position + Vector3(0, 0.5, 0))
		if plant.kind == "target" and get_viewport().get_visible_rect().has_point(screen) and (best == null or plant.global_position.distance_to(map.player.global_position) < best.global_position.distance_to(map.player.global_position)):
			best = plant
	if best:
		var at: Vector2 = map.camera.unproject_position(best.global_position + Vector3(0, 0.5, 0))
		map.update_hover(Vector2.ZERO, 0.0)
		map.update_hover(at, 0.0)
		map.update_hover(at, 0.2)
		await _frames(3)
		_save("tooltip_0_2s")
		map.update_hover(at, 0.45)  # 0.65 s: flicker, visible phase
		await _frames(3)
		_save("tooltip_0_65s_flicker_visible")
		map.update_hover(at, 0.05)  # 0.7 s: flicker, hidden phase
		await _frames(3)
		_save("tooltip_0_7s_flicker_hidden")
		map.update_hover(at, 0.5)  # 1.2 s: gone
		await _frames(3)
		_save("tooltip_1_2s_gone")
	# Several single-letter plants of different kinds in the lower forest, then the alpine 시로미.
	await _walk_to(map, Vector3(16.0, 0.0, 1.0))
	await _frames(60)
	_save("letters_lower_forest")
	await _walk_to(map, Vector3(52.0, 0.0, 0.0))
	await _frames(90)
	_save("letters_alpine")
	# 머루 (purple, 19.5, 0.5) and 붓순나무 (brown-orange, 15, 1.5) are 4.5 m apart: one view.
	await _walk_to(map, Vector3(17.5, 0.0, 3.5))
	await _frames(60)
	_save("fruits_meoru_butsunnamu")
	await _walk_to(map, Vector3(48.0, 0.0, 0.0))
	await _frames(90)
	_save("fruit_deulchuk")
	# The discovery HUD, on a fresh map so the walk above has not filled the list.
	map.free()
	map = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	await _teleport(map, _clean_spot(map, "ma"))
	await _teleport(map, _clean_spot(map, "meoru"))
	await _frames(5)
	_save("hud_ma_meoru")
	for id in ["minari", "gosari", "gobi", "simiro"]:
		await _teleport(map, _clean_spot(map, id))
	await _frames(5)
	_save("hud_all_six")
	# Decoys and targets side by side: 붓순나무 (15, 1.5), 큰천남성 (13, 4), 머루 and 고비 nearby.
	await _teleport(map, Vector2(16.0, 1.0))
	await _frames(5)
	_save("letters_decoys_targets")
	await _topdown(map)
	map.free()  # its plants' pick areas would answer the picking shots' clicks
	for child in get_children():  # and the top-down legend would cover the HUD
		if child is CanvasLayer:
			child.queue_free()
	await _picking_shots()
	await _reach_shots()
	await _basket_shots()
	await _spelling_shots()
	await _hearts_shots()
	await _spare_shots()
	await _credit_shots()
	await _walk_limit_shots()
	await _keyboard_shots()
	get_tree().quit()


## The keyboard cursor in the spelling view, driven only by real key events
## pushed into the viewport: {keyboard_cursor_first_tile,
## keyboard_cursor_later_row_28_tiles, keyboard_highlight_consonant,
## keyboard_highlight_vowel, keyboard_half_filled_word}.png. 미나리 is open with
## all 28 target letters in the basket; the half-filled word is ㅁㅣ (locked) and
## ㄴ in block 2, each placed with Space.
func _keyboard_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	var spots := {}
	for entry in Content.mountain("hallasan")["foraging"]["plants"]["placed"]:
		spots[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for kind in Content.mountain("hallasan")["foraging"]["plants"]["kinds"]:
		if kind["kind"] == "target":
			map.discovery.update([spots[kind["id"]]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	map.open_spelling("minari")
	await _frames(5)
	var cursor = map.spelling_hud.cursor
	_tap(KEY_D)  # the first press shows the cursor on tile 0
	await _frames(5)
	_save("keyboard_cursor_first_tile")
	for i in 3:
		_tap(KEY_S)
	await _frames(5)
	print("later-row cursor on tile %d of %d" % [cursor.index, map.basket_hud.letters().size()])
	_save("keyboard_cursor_later_row_28_tiles")
	for want_vowel in [false, true]:
		for i in 40:
			if Hangul.is_vowel(map.basket_hud.letters()[cursor.index]) == want_vowel:
				break
			_tap(KEY_D)
		await _frames(5)
		_save("keyboard_highlight_vowel" if want_vowel else "keyboard_highlight_consonant")
	for letter in ["ㅁ", "ㅣ", "ㄴ"]:
		for i in 40:
			if map.basket_hud.letters()[cursor.index] == letter:
				break
			_tap(KEY_D)
		_tap(KEY_SPACE)
	await _frames(5)
	_save("keyboard_half_filled_word")
	map.free()
	get_tree().paused = false
	GameState.new_hike()


## A real key press and release, pushed through the viewport's input pipeline.
func _tap(keycode: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = keycode
		event.physical_keycode = keycode
		event.pressed = pressed
		get_viewport().push_input(event)


## The spelling view on a fresh map, through the real code paths: every target
## discovered and picked, 미나리 opened by open_spelling, letters placed with the
## same call a drop makes (spelling.place -> spelling_hud.apply).
func _spelling_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	var spots := {}
	for entry in Content.mountain("hallasan")["foraging"]["plants"]["placed"]:
		spots[entry["kind"]] = Vector2(float(entry["x"]), float(entry["z"]))
	for kind in Content.mountain("hallasan")["foraging"]["plants"]["kinds"]:
		if kind["kind"] == "target":
			map.discovery.update([spots[kind["id"]]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	map.open_spelling("minari")
	await _frames(5)
	_save("spelling_open_3_blocks")
	var hud: CanvasLayer = map.spelling_hud
	for letter in ["ㅁ", "ㅣ"]:  # 미: right
		hud.apply(map.spelling.place(letter, 0, 0 if letter == "ㅁ" else 1))
	await _frames(5)
	_save("spelling_block_locked")
	hud.apply(map.spelling.place("ㄴ", 1, 0))  # half of 나
	await _frames(5)
	_save("spelling_half_filled")
	hud.apply(map.spelling.place("ㅓ", 1, 1))  # 너, not 나: fails
	hud.tick(0.1)
	await _frames(5)
	_save("spelling_failure_flash")
	hud.tick(1.0)
	map.open_spelling("ma")
	hud.apply(map.spelling.place("ㅁ", 0, 0))
	hud.apply(map.spelling.place("ㅏ", 0, 1))
	await _frames(5)
	_save("spelling_entry_done")
	map.free()
	get_tree().paused = false


## The heart readout, blood and the death beat, through the real paths: a
## failed syllable (syllable_failed, then the view closing) hurts both travelers.
func _hearts_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	_save("hearts_full")
	map.spelling.syllable_failed.emit("ma", 0, ["ㅁ", "ㅓ"])
	map.spelling_hud.closed.emit()  # 10 -> 9 units each, with blood on both
	await get_tree().create_timer(0.22).timeout  # real time: both bursts are in the air
	_save("blood_burst")
	await _frames(60)
	_save("hearts_4_5")
	GameState.heart_units["nestor"] = 3
	GameState.heart_units["fernanda"] = 1
	map.hearts_hud.refresh()
	await _frames(5)
	_save("hearts_low")
	map.spelling.syllable_failed.emit("ma", 0, ["ㅁ", "ㅓ"])
	map.spelling_hud.closed.emit()  # nestor 3 -> 2, fernanda 1 -> 0: the death beat
	await _frames(20)
	map.tick_beat(1.0)
	await _frames(3)
	_save("death_beat_dim")
	map.free()
	GameState.new_hike()


## Spare plants, through the real spawn path: every target letter is taken off
## the map (so a deficit exists), the words complete (word_completed) and the
## view closes. {spare_grow_in, spare_next_to_normal, spares_map}.png. The spare
## is 머루's; the normal 머루 plant beside it still carries its letter.
func _spare_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	map.partner.global_position = Vector3(40.0, map.terrain.height_at(40.0), 0.0)
	var normal: Node3D = null
	for plant in map.plants:
		if plant.kind_id == "meoru" and plant.position.x > 19.0 and plant.position.x < 20.0:
			normal = plant
		elif plant.kind == "target" and plant.kind_id != "meoru":
			plant.take_letter()
	for plant in map.plants:
		if plant.kind_id == "meoru" and plant != normal:
			plant.take_letter()
	map.spelling.word_completed.emit("meoru")
	map.spelling_hud.closed.emit()
	var spare: Node3D = map.spare_plants[0]
	var slot: Vector2 = map.spares.slots["meoru"]
	var at := Vector3(slot.x + 3.5, 0.0, slot.y + 2.5)
	map.player.global_position = Vector3(at.x, map.terrain.height_at(at.x), at.z)
	map.update_camera(0.0, true)
	for i in 15:  # 0.25 s into the 0.5 s grow-in
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	await _frames(3)
	print("spare scale %.2f" % spare.scale.x)
	_save("spare_grow_in")
	for i in 40:  # grown, and the props that cover the travelers have faded
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	print("spare scale %.2f" % spare.scale.x)
	_save("spare_next_to_normal")
	# Several spares at once: the other four lower-forest words complete too.
	for id in ["ma", "gosari", "gobi", "minari"]:
		map.spelling.word_completed.emit(id)
	map.spelling_hud.closed.emit()
	map.player.global_position = Vector3(17.0, map.terrain.height_at(17.0), 0.5)
	map.update_camera(0.0, true)
	for i in 70:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	print("%d spares" % map.spare_plants.size())
	_save("spares_map")
	map.free()
	GameState.new_hike()


## The playtest through the real paths: every target letter picked, five words
## spelled cleanly (five credits banked, no spare), then 시로미's first block
## fails with ㅣ and ㅅ. The view closes and the two oldest credits (마, 머루)
## become spares. credits_after_failure.png.
func _credit_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	map.partner.global_position = Vector3(40.0, map.terrain.height_at(40.0), 0.0)
	var spots := {}
	for plant in map.plants:
		if plant.kind == "target":
			spots[plant.kind_id] = Vector2(plant.position.x, plant.position.z)
			map.pick_plant(plant)
	for id in spots:
		map.discovery.update([spots[id]], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for id in ["ma", "meoru", "minari", "gosari", "gobi"]:
		map.open_spelling(id)
		for b in map.spelling.block_count(id):
			var parts := Hangul.decompose(map.spelling.target_syllable(id, b))
			for slot in 2:
				map.spelling_hud.apply(map.spelling.place(parts[slot], b, slot))
	print("credits banked: %s, spares: %d" % [str(map.spares.credits), map.spare_plants.size()])
	map.open_spelling("simiro")
	map.spelling_hud.apply(map.spelling.place("ㅣ", 0, 0))
	map.spelling_hud.apply(map.spelling.place("ㅅ", 0, 1))
	map.spelling_hud.tick(1.0)
	print("after the failure: credits %s, spares %d" % [str(map.spares.credits), map.spare_plants.size()])
	map.player.global_position = Vector3(15.0, map.terrain.height_at(15.0), -4.5)
	map.update_camera(0.0, true)
	for i in 70:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("credits_after_failure")
	map.free()
	GameState.new_hike()


## A traveler walked down (S) to the bottom limit at x = 0, 32 and 64, and once
## more at x = 32 with the old stage-edge limit put back, to show where it used to stop.
func _walk_limit_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	for entry in [0.0, 32.0, 64.0, -32.0]:
		var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
		add_child(map)
		map.set_physics_process(false)
		map.set_process(false)
		await _frames(5)
		var old: bool = entry < 0.0
		var lane: float = absf(entry)
		var bounds: Rect2 = map.walk_bounds()
		if old:  # the limit as it was: the stage edge, camera free to follow
			for traveler in map.travelers.values():
				traveler.near_limit = Callable()
				traveler.bounds = Rect2(Vector2(map.TRAVELER_MARGIN, -map.stage_depth / 2.0 + map.TRAVELER_MARGIN),
						Vector2(map.stage_width - 2.0 * map.TRAVELER_MARGIN, map.stage_depth - 2.0 * map.TRAVELER_MARGIN))
		var column := clampf(lane, bounds.position.x, bounds.end.x)
		map.partner.global_position = Vector3(clampf(column + 3.0, bounds.position.x, bounds.end.x - 1.0), map.terrain.height_at(column), 0.0)
		map.player.global_position = Vector3(column, map.terrain.height_at(column), 0.0)
		map.update_camera(0.0, true)
		for i in 120:
			for j in STEPS_PER_FRAME:
				map.step(Vector2(0.0, 1.0), DELTA)
			await get_tree().process_frame
		await _frames(30)
		var screen: Vector2 = map.camera.unproject_position(map.player.global_position)
		print("x=%.1f%s: feet z %.2f, screen y %.1f of %.0f" % [column, " (old limit)" if old else "", map.player.global_position.z, screen.y, get_viewport().get_visible_rect().size.y])
		_save("walk_limit_x%d%s" % [int(lane), "_before" if old else ""])
		map.free()
	GameState.new_hike()


## A point 2.4 m from a plant of the kind with no other target kind within the
## discovery radius, so a traveler standing there discovers only this kind.
func _clean_spot(map: Node3D, kind_id: String) -> Vector2:
	var radius: float = map.discovery.radius
	for plant in map.plants:
		if plant.kind_id != kind_id:
			continue
		for degrees in range(0, 360, 15):
			var point := Vector2(plant.position.x, plant.position.z) + Vector2.from_angle(deg_to_rad(degrees)) * 2.4
			var clear: bool = point.x > 1.0 and point.x < map.stage_width - 1.0 and absf(point.y) < map.stage_depth / 2.0 - 1.0
			for other in map.plants:
				if other.kind == "target" and other.kind_id != kind_id and Vector2(other.position.x, other.position.z).distance_to(point) <= radius + 1.5:
					clear = false
			if clear:
				return point
	push_error("no clean spot for " + kind_id)
	return Vector2.ZERO


## Puts both travelers at a spot, ticks the map, and lets the HUD fade in.
func _teleport(map: Node3D, spot: Vector2) -> void:
	var ids: Array = map.travelers.keys()
	for i in ids.size():
		var x: float = spot.x + 0.8 * i
		map.travelers[ids[i]].global_position = Vector3(x, map.terrain.height_at(x), spot.y)
	map.update_camera(0.0, true)
	for frame in 40:  # 0.4 s fade-in is 24 ticks
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame


## Debug only: a straight-down view of the whole map with one coloured marker
## per plant (same kind, same colour), the letter beside it, and a legend.
func _topdown(map: Node3D) -> void:
	map.get_node("Props").visible = false
	map.get_node("Plants").visible = false
	map.get_node("Scenery").visible = false
	map.get_node("Travelers").visible = false
	map.get_node("Sun").visible = false  # no leftover shadows to mistake for markers
	var markers := Node3D.new()
	map.add_child(markers)
	var ids: Array = []
	for plant in map.plants:
		var color: Color = MARKER_COLORS[plant.kind_id]
		if not ids.has(plant.kind_id):
			ids.append(plant.kind_id)
		var disc := CylinderMesh.new()
		disc.top_radius = 0.7
		disc.bottom_radius = 0.7
		disc.height = 0.1
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var marker := MeshInstance3D.new()
		marker.mesh = disc
		marker.material_override = material
		marker.position = Vector3(plant.position.x, 30.0, plant.position.z)
		markers.add_child(marker)
		if plant.letter != "":
			var label := Label3D.new()
			label.text = plant.letter
			label.font = load("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
			label.font_size = 64
			label.pixel_size = 0.02
			label.shaded = false
			label.outline_size = 12
			label.rotation_degrees = Vector3(-90, 0, 0)
			label.position = Vector3(plant.position.x + 1.8, 30.2, plant.position.z)
			markers.add_child(label)
	var top := Camera3D.new()
	top.projection = Camera3D.PROJECTION_ORTHOGONAL
	top.keep_aspect = Camera3D.KEEP_WIDTH
	top.size = 80.0
	top.rotation_degrees = Vector3(-90, 0, 0)
	top.position = Vector3(map.stage_width / 2.0, 50.0, 0.0)
	top.far = 120.0
	map.add_child(top)
	top.current = true
	var layer := CanvasLayer.new()
	var legend := VBoxContainer.new()
	legend.position = Vector2(12, 12)
	for id in ids:
		var row := Label.new()
		row.text = "■ " + id
		row.add_theme_color_override("font_color", MARKER_COLORS[id])
		row.add_theme_color_override("font_outline_color", Color.BLACK)
		row.add_theme_constant_override("outline_size", 6)
		legend.add_child(row)
	layer.add_child(legend)
	add_child(layer)
	await _frames(10)
	_save("spread_topdown")


func _walk_to(map: Node3D, target: Vector3) -> void:
	for frame in 3000:
		var to: Vector3 = target - map.player.global_position
		if Vector2(to.x, to.z).length() < 0.8:  # the body margin keeps the player off the exact corner
			return
		for i in STEPS_PER_FRAME:
			map.step(Vector2(to.x, to.z), DELTA)
		await get_tree().process_frame


func _frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame


func _save(label: String) -> void:
	var path := ProjectSettings.globalize_path(SHOT_DIR + label + ".png")
	var err := get_viewport().get_texture().get_image().save_png(path)
	print("%s -> %s (%s)" % [label, path, "ok" if err == OK else "error %d" % err])


## Picking, on a fresh map: click a target (mid-walk, then picked with a tile in
## the basket), then click a decoy and catch its steam puff.
func _picking_shots() -> void:
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	map.partner.global_position = Vector3(60.0, map.terrain.height_at(60.0), 0.0)
	map.player.global_position = Vector3(14.0, map.terrain.height_at(14.0), 0.0)
	map.update_camera(0.0, true)
	await _frames(5)
	for i in 5:
		await get_tree().physics_frame
	var target: Node3D = _on_screen(map, true, 3.5)
	if target == null:
		push_error("no target plant on screen")
		map.free()
		return
	map.click(map.camera.unproject_position(target.global_position + Vector3(0, 0.5, 0)))
	for i in 30:  # about half a second of walking
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("pick_walking")
	while map.picking.walk_target >= 0:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	for i in 20:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("pick_target_basket")
	for i in 5:
		await get_tree().physics_frame
	var decoy: Node3D = _on_screen(map, false, 0.0)
	if decoy == null:
		push_error("no decoy plant on screen")
		map.free()
		return
	map.click(map.camera.unproject_position(decoy.global_position + Vector3(0, 0.5, 0)))
	while map.picking.walk_target >= 0:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	for i in 18:  # 0.3 s into the puff
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("pick_decoy_steam")
	map.free()


## The reach ring on a target and on a decoy (same code path, to show they
## match), and the name that flashes when the player walks up to a plant.
func _reach_shots() -> void:
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	map.partner.global_position = Vector3(69.0, map.terrain.height_at(69.0), 0.0)
	var spots := {}
	for want_target in [true, false]:
		for plant in map.plants:
			if (plant.kind == "target") != want_target or plant.letter == "" or plant.global_position.x < 8.0:
				continue
			var alone := true
			for other in map.plants:
				alone = alone and (other == plant or other.global_position.distance_to(plant.global_position) > 4.0)
			if alone:
				spots[want_target] = plant
				break
	for want_target in [true, false]:
		var plant: Node3D = spots[want_target]
		var at := plant.global_position + Vector3(0.9, 0.0, 0.4)
		map.player.global_position = Vector3(at.x, map.terrain.height_at(at.x), at.z)
		map.step(Vector2.ZERO, 0.0)
		map.update_camera(0.0, true)
		for i in 20:  # props covering the player fade out (0.2 s)
			map.step(Vector2.ZERO, DELTA)
			await get_tree().process_frame
		map._ring_time = 0.0  # the same point of the pulse for both shots
		map.step(Vector2.ZERO, 0.0)
		map._tip_plant = null  # the walk-up name has its own shot
		map.update_hover(Vector2(-10.0, -10.0), 0.0)
		await _frames(3)
		_save("reach_ring_target" if want_target else "reach_ring_decoy")
	# Walk up: from outside the radius to inside it, then 0.1 s into the flash.
	var plant: Node3D = spots[true]
	map.player.global_position = plant.global_position + Vector3(4.0, 0.0, 0.0)
	map.step(Vector2.ZERO, 0.0)
	map.player.global_position = plant.global_position + Vector3(0.9, 0.0, 0.4)
	map.step(Vector2.ZERO, 0.0)
	map.update_camera(0.0, true)
	await _frames(3)
	map.update_hover(Vector2(-10.0, -10.0), 0.1)
	await _frames(3)
	_save("walk_up_flash")
	map.free()


## The nearest plant on screen (target or decoy) at least `min_distance` from the player.
func _on_screen(map: Node3D, want_target: bool, min_distance: float) -> Node3D:
	var best: Node3D = null
	for plant in map.plants:
		var screen: Vector2 = map.camera.unproject_position(plant.global_position + Vector3(0, 0.5, 0))
		var distance: float = plant.global_position.distance_to(map.player.global_position)
		if (plant.kind == "target") == want_target and plant.letter != "" and distance >= min_distance \
				and get_viewport().get_visible_rect().grow(-40.0).has_point(screen) \
				and (best == null or distance < best.global_position.distance_to(map.player.global_position)) \
				and map.plant_at(screen) == plant:
			best = plant
	return best


## The basket HUD on a fresh map, filled by the real pick path (pick_plant) for
## every target plant, plus the discovery list with two entries.
func _basket_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	_save("basket_empty")
	var targets: Array[Node3D] = []
	for plant in map.plants:
		if plant.kind == "target":
			targets.append(plant)
	map.pick_plant(targets[0])
	await _teleport(map, _clean_spot(map, "ma"))
	_save("basket_1_tile")
	await _teleport(map, _clean_spot(map, "meoru"))
	_save("hud_discovery_two_entries")
	for plant in targets:
		map.pick_plant(plant)
	for id in ["minari", "gosari", "gobi", "simiro"]:  # the full list, to show the basket clears it
		await _teleport(map, _clean_spot(map, id))
	await _frames(20)
	_save("basket_28_tiles")
	map.free()


## The stuck countdown and the monster, through the real paths: every target
## letter is picked, then syllables are failed through the Spelling and the view
## until the scene is stuck. The countdown is set to 10 s and 3 s by hand (not
## waited for), then run out and the deer's kill stepped through.
## {stuck_40s,stuck_10s,stuck_3s,monster_leap,monster_first_hit,monster_both_down}.png.
## This plays the placeholder music through the speakers.
func _stuck_shots() -> void:
	for child in get_children():
		if child is CanvasLayer:
			child.queue_free()
	GameState.new_hike()
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)
	map.set_process(false)
	await _frames(5)
	for plant in map.plants:
		if plant.kind == "target":
			map.discovery.update([Vector2(plant.global_position.x, plant.global_position.z)], 0.0)
	map.discovery.update([], 1.0)
	map.discovery_hud.refresh()
	for plant in map.plants:
		if plant.kind == "target":
			map.pick_plant(plant)
	map.basket_hud.refresh(1.0)
	var failures := 0
	while not map.stuck_verdict["stuck"] and failures < 8:
		failures += 1
		_fail_block(map)
	print("stuck after %d failures: %s" % [failures, map.stuck_verdict["reason"]])
	await get_tree().create_timer(1.5).timeout  # the failures' blood settles
	map.step(Vector2.ZERO, DELTA)
	await _frames(3)
	_save("stuck_40s")
	map.countdown.left = 10.0
	map.step(Vector2.ZERO, DELTA)
	await _frames(3)
	_save("stuck_10s")
	map.countdown.left = 3.0
	map.step(Vector2.ZERO, DELTA)
	await _frames(3)
	_save("stuck_3s")
	while map.kill == null:
		map.step(Vector2.ZERO, 0.05)
	await _frames(1)
	while map.kill.time < float(map.monster["leap_seconds"]) * 0.5:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("monster_leap")
	while map.kill.time < float(map.monster["leap_seconds"]) + 0.12:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("monster_first_hit")
	while map.kill.time < map.kill.hit_time(1) + 0.3:
		map.step(Vector2.ZERO, DELTA)
		await get_tree().process_frame
	_save("monster_both_down")
	map.free()
	GameState.new_hike()


## Fails the first unfinished word's block with two basket letters that cannot make it.
func _fail_block(map: Node3D) -> void:
	for id in map.spares.word_ids():
		if map.spelling.is_done(id) or not map.open_spelling(id):
			continue
		var basket: Array = map.picking.basket
		var block: int = map.spelling.current_block()
		for i in basket.size():
			for j in basket.size():
				if i != j and not map.spelling.judge(id, block, [basket[i], basket[j]]):
					var pair := [basket[i], basket[j]]
					map.spelling_hud.apply(map.spelling.place(pair[0], block, 0))
					map.spelling_hud.apply(map.spelling.place(pair[1], block, 1))
					map.spelling_hud.tick(1.0)
					return
		return
