extends Node
## Needs a display (not headless). Walks the player around the foraging map
## and saves tests/shots/{start,left_near,right_far,middle}.png.

const SHOT_DIR := "res://tests/shots/"
const DELTA := 1.0 / 60.0
const STEPS_PER_FRAME := 4  # walking the whole map in real time takes too long


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var map: Node3D = load("res://scenes/foraging/foraging.tscn").instantiate()
	map.set_physics_process(false)  # this script drives the map
	add_child(map)
	var half_depth: float = map.stage_depth / 2.0
	await _frames(5)
	_save("start")
	await _walk_to(map, Vector3(0.0, 0.0, half_depth))
	await _frames(90)
	_save("left_near")
	await _walk_to(map, Vector3(map.stage_width, 0.0, -half_depth))
	await _frames(90)
	_save("right_far")
	await _walk_to(map, Vector3(map.stage_width / 2.0, 0.0, 0.0))
	await _frames(90)
	_save("middle")
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
