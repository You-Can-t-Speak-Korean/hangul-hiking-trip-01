extends Node
## Needs a display (not headless). Walks the player around the foraging map
## and saves tests/shots/{start,left_near,right_far,middle}.png, plus the
## terrain shots {zone_lower_forest,zone_mid_slope,zone_alpine}.png, and
## {tree_fade,tooltip_shown,tooltip_faded,letters_lower_forest,letters_alpine,
## fruits_meoru_butsunnamu,fruit_deulchuk,hud_empty,hud_ma_meoru,hud_all_six,
## letters_decoys_targets,spread_topdown}.png.

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
		await _frames(3)
		_save("tooltip_shown")
		map.update_hover(at, 2.6)  # past the 2 s + 0.5 s
		await _frames(3)
		_save("tooltip_faded")
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
	get_tree().quit()


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
