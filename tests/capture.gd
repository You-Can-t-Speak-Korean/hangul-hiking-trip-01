extends Node
## Needs a display (not headless). Walks the player around the foraging map
## and saves tests/shots/{start,left_near,right_far,middle}.png, plus the
## terrain shots {zone_lower_forest,zone_mid_slope,zone_alpine}.png, and
## {tree_fade,tooltip_shown,tooltip_faded,fruit_meoru,fruit_deulchuk}.png.

const SHOT_DIR := "res://tests/shots/"
const DELTA := 1.0 / 60.0
const STEPS_PER_FRAME := 4  # walking the whole map in real time takes too long


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	add_child(map)
	map.set_physics_process(false)  # this script drives the map
	map.set_process(false)  # and the hover, so the real mouse can't hide the tooltip
	var half_depth: float = map.stage_depth / 2.0
	await _frames(5)
	_save("start")
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
		await _frames(3)
		_save("tooltip_shown")
		map.update_hover(at, 2.6)  # past the 2 s + 0.5 s
		await _frames(3)
		_save("tooltip_faded")
	# The two hanging-fruit plants: 머루 (purple) and 들쭉나무 (blue-black).
	await _walk_to(map, Vector3(12.0, 0.0, 6.0))
	await _frames(60)
	_save("fruit_meoru")
	await _walk_to(map, Vector3(54.0, 0.0, -3.0))
	await _frames(90)
	_save("fruit_deulchuk")
	get_tree().quit()


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
