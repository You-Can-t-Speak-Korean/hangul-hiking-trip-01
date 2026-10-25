extends Node3D
## Gray-box foraging map. Stage size and start positions come from
## data/mountains/<game>.json ("foraging"). Coordinates: x = along the stage
## (0..width), z = depth (-depth/2 far .. +depth/2 near the camera), 1 unit = 1 m.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const Terrain := preload("res://scenes/foraging/terrain.gd")
const Plant := preload("res://scenes/foraging/plant.gd")
const Prop := preload("res://scenes/foraging/prop.gd")

const CAMERA_PITCH_DEG := 28.0  # angled down, like a 90s beat-em-up
const CAMERA_DISTANCE := 30.0   # orthographic: only needs to clear the stage
const CAMERA_FOLLOW_RATE := 6.0
const CAMERA_LEAD := 4.0        # aims this far ahead (into the scene) of the player
const PARTNER_STOP_DISTANCE := 1.6
const TRAVELER_MARGIN := 0.4    # keeps a traveler's body inside the stage
const FADE_REACH := 14.0        # how far toward the camera a prop can still cover a traveler
const FADE_CELL := 4.0          # props are bucketed by x so only those near a traveler are checked
const FADE_SAMPLE_HEIGHTS := [0.3, 0.85, 1.5]  # feet, waist and head of a traveler

const GROUND_STEP := 1.0        # metres between ground mesh vertices along x
const KEEP_OUT := 1.8           # props are pushed this far from plants, trees and starts
const NUDGE_PASSES := 12         # a pushed prop can land near another point, so repeat
const TOOLTIP_OFFSET := Vector2(16.0, 18.0)

const NESTOR_COLOR := Color(0.36, 0.45, 0.65)    # slate blue
const FERNANDA_COLOR := Color(0.95, 0.55, 0.70)  # pink

var stage_width: float = 0.0
var stage_depth: float = 0.0
## Everything drawn as ground (walkable stage + apron), and the ridge footprint
## behind it, as Rect2s over (x, z).
var ground_rect := Rect2()
var backdrop_rect := Rect2()
## Every backdrop piece as {"data", "base", "top", "aabb"}: base and top are
## world heights, aabb is the piece's world-space box.
var backdrop_pieces: Array[Dictionary] = []
## Height of the ground as a function of x, and the zones along it.
var terrain: Terrain
var zones: Array = []
## Every plant on the map, and the keep-out points (plants, scenery, starts)
## as Vector2s over (x, z).
var plants: Array[Node3D] = []
var keep_out: Array[Vector2] = []
var travelers: Dictionary = {}
var player: CharacterBody3D
var partner: CharacterBody3D

var fade_opacity := 1.0   # opacity of a prop covering a traveler (data: prop_fade)
var fade_time := 0.2      # seconds to fade in or out (data: prop_fade)
var tooltip_show_time := 2.0  # seconds the hover name stays solid (data: tooltip)
var tooltip_fade_time := 0.5  # seconds it then takes to fade out (data: tooltip)

var _aim_height := 0.0
var _tooltip: PanelContainer
var _tooltip_label: Label
var _hover_plant: Node3D
var _hover_time := 0.0
var _props_by_cell: Dictionary = {}  # int cell of x -> Array of Prop
var _fading: Dictionary = {}         # Prop -> true, while its opacity is not 1.0

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	var config: Dictionary = Content.mountain(GameState.game_id).get("foraging", {})
	if config.is_empty():
		push_error("No foraging data for %s" % GameState.game_id)
		return
	stage_width = float(config["stage"]["width"])
	stage_depth = float(config["stage"]["depth"])
	var apron: Dictionary = config["apron"]
	var side := float(apron["sides"])
	var far := float(apron["far"])
	ground_rect = Rect2(
		Vector2(-side, -stage_depth / 2.0 - far),
		Vector2(stage_width + 2.0 * side, stage_depth + far + side))
	var backdrop_depth := float(config["backdrop"]["depth"])
	backdrop_rect = Rect2(
		Vector2(ground_rect.position.x, ground_rect.position.y - backdrop_depth),
		Vector2(ground_rect.size.x, backdrop_depth))
	fade_opacity = float(config["prop_fade"]["opacity"])
	fade_time = float(config["prop_fade"]["time"])
	tooltip_show_time = float(config["tooltip"]["show_time"])
	tooltip_fade_time = float(config["tooltip"]["fade_time"])
	terrain = Terrain.new(config["terrain"]["points"])
	zones = config["zones"]
	for id in GameState.TRAVELERS:
		keep_out.append(Vector2(float(config["start"][id][0]), float(config["start"][id][1])))
	_build_plants(config["plants"])
	_build_scenery(config["scenery"])
	_build_ground()
	_build_backdrop(config["backdrop"]["pieces"])
	_build_props(config["props"])
	_build_tooltip()
	var colors := {"nestor": NESTOR_COLOR, "fernanda": FERNANDA_COLOR}
	for id in GameState.TRAVELERS:
		var traveler := Traveler.new()
		$Travelers.add_child(traveler)
		traveler.setup(id.capitalize(), colors[id])
		traveler.bounds = Rect2(
			Vector2(TRAVELER_MARGIN, -stage_depth / 2.0 + TRAVELER_MARGIN),
			Vector2(stage_width - 2.0 * TRAVELER_MARGIN, stage_depth - 2.0 * TRAVELER_MARGIN))
		var start: Array = config["start"][id]
		traveler.global_position = Vector3(float(start[0]), terrain.height_at(float(start[0])), float(start[1]))
		travelers[id] = traveler
	player = travelers[GameState.controlled]
	partner = travelers[GameState.partner_of(GameState.controlled)]
	camera.rotation_degrees = Vector3(-CAMERA_PITCH_DEG, 0.0, 0.0)
	update_camera(0.0, true)
	for t in travelers.values():  # settle onto the ground before the first frame
		for i in 10:
			t.drive(Vector2.ZERO, 1.0 / 60.0)


func _process(delta: float) -> void:
	if DisplayServer.get_name() != "headless":
		update_hover(get_viewport().get_mouse_position(), delta)


func _physics_process(delta: float) -> void:
	step(Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down"), delta)


## One tick of the map. Public so tests and the capture scene can drive it
## without a keyboard.
func step(input: Vector2, delta: float) -> void:
	player.drive(input, delta)
	partner.follow(player.global_position, PARTNER_STOP_DISTANCE, delta)
	update_camera(delta)
	update_prop_fade(delta)


## Half the width, in metres, the orthographic camera shows.
func camera_half_width() -> float:
	var size := get_viewport().get_visible_rect().size
	return camera.size * (size.x / size.y) / 2.0


## Half the depth, in metres of ground, the tilted camera shows.
func camera_half_depth() -> float:
	return camera.size / (2.0 * sin(deg_to_rad(CAMERA_PITCH_DEG)))


## Follows the player in x, z and height. The camera aims at a point on the ground;
## clamp_aim() keeps the view over ground (or backdrop, at the far edge).
func update_camera(delta: float, snap: bool = false) -> void:
	var pitch := deg_to_rad(CAMERA_PITCH_DEG)
	var aim := Vector2(camera.global_position.x, camera.global_position.z - CAMERA_DISTANCE * cos(pitch))
	var target := Vector2(player.global_position.x, player.global_position.z - CAMERA_LEAD)
	aim = target if snap else aim.lerp(target, 1.0 - exp(-CAMERA_FOLLOW_RATE * delta))
	aim = clamp_aim(aim)
	var height := player.global_position.y
	_aim_height = height if snap else lerpf(_aim_height, height, 1.0 - exp(-CAMERA_FOLLOW_RATE * delta))
	camera.global_position = Vector3(aim.x, _aim_height + CAMERA_DISTANCE * sin(pitch), aim.y + CAMERA_DISTANCE * cos(pitch))


## The view must not pass the ground's left, right and near edges. The far
## end is open on purpose: the backdrop ridge stands against the sky there.
func clamp_aim(aim: Vector2) -> Vector2:
	var half := Vector2(camera_half_width(), camera_half_depth())
	return Vector2(
		_clamp_axis(aim.x, ground_rect.position.x + half.x, ground_rect.end.x - half.x),
		_clamp_axis(aim.y, -INF, ground_rect.end.y - half.y))


## Clamps, or centres if the range is empty (the view is bigger than the ground).
func _clamp_axis(value: float, low: float, high: float) -> float:
	return (low + high) / 2.0 if low > high else clampf(value, low, high)


## The zone a given x is in (the first or last zone for the apron beyond).
func zone_at(x: float) -> Dictionary:
	for zone in zones:
		if x < float(zone["x"][1]):
			return zone
	return zones[zones.size() - 1]


func _zone_color(zone: Dictionary) -> Color:
	var t: Array = zone["tint"]
	return Color(t[0], t[1], t[2])


## The ground as strips along x, flat across z. Vertices are not shared so
## each strip takes its zone's tint; normals come from the height curve so the
## shading is smooth across the strips.
func _build_ground() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var z_near := ground_rect.end.y
	var z_far := ground_rect.position.y
	var count := ceili(ground_rect.size.x / GROUND_STEP)
	var step := ground_rect.size.x / count
	for i in count:
		var x0 := ground_rect.position.x + i * step
		var x1 := x0 + step
		var color := _zone_color(zone_at((x0 + x1) / 2.0))
		var corners := [Vector3(x0, terrain.height_at(x0), z_far), Vector3(x1, terrain.height_at(x1), z_far),
				Vector3(x1, terrain.height_at(x1), z_near), Vector3(x0, terrain.height_at(x0), z_near)]
		for index in [0, 1, 2, 0, 2, 3]:
			var corner: Vector3 = corners[index]
			surface.set_color(color)
			surface.set_normal(Vector3(-terrain.slope_at(corner.x), 1.0, 0.0).normalized())
			surface.add_vertex(corner)
	var mesh := surface.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	var ground := MeshInstance3D.new()
	ground.mesh = mesh
	ground.material_override = material
	$Ground.add_child(ground)
	# A height map collides much more cleanly with a capsule than the mesh's
	# long skinny triangles would. Same grid as the mesh along x.
	var columns := count + 1
	var rows := ceili(ground_rect.size.y / GROUND_STEP) + 1
	var heights := PackedFloat32Array()
	heights.resize(columns * rows)
	for column in columns:
		var h := terrain.height_at(ground_rect.position.x + column * step)
		for row in rows:
			heights[row * columns + column] = h
	var height_map := HeightMapShape3D.new()
	height_map.map_width = columns
	height_map.map_depth = rows
	height_map.map_data = heights
	var shape := CollisionShape3D.new()
	shape.shape = height_map
	# The shape has one unit between samples; scale it to the real spacing.
	shape.scale = Vector3(step, 1.0, ground_rect.size.y / (rows - 1))
	var centre := ground_rect.get_center()
	shape.position = Vector3(centre.x, 0.0, centre.y)
	var body := StaticBody3D.new()
	body.add_child(shape)
	$Ground.add_child(body)


## The plants: each entry of "placed" is one plant at a fixed position (height
## from the terrain). A target carries one letter of its name, a decoy none.
func _build_plants(plants_data: Dictionary) -> void:
	var kinds := {}
	for kind in plants_data["kinds"]:
		kinds[kind["id"]] = kind
	for entry in plants_data["placed"]:
		var plant := Plant.new()
		plant.setup(kinds[entry["kind"]], String(entry.get("letter", "")))
		var x := float(entry["x"])
		var z := float(entry["z"])
		plant.position = Vector3(x, terrain.height_at(x), z)
		$Plants.add_child(plant)
		plants.append(plant)
		keep_out.append(Vector2(x, z))


## 구상나무 (Korean fir): scenery only, no letters, nothing to forage.
func _build_scenery(scenery: Dictionary) -> void:
	for pos in scenery["gusangnamu"]["positions"]:
		var tree := Prop.new()
		tree.name = "Gusangnamu"
		tree.position = Vector3(float(pos[0]), terrain.height_at(float(pos[0])), float(pos[1]))
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.16
		trunk_mesh.bottom_radius = 0.22
		trunk_mesh.height = 1.0
		var trunk := Traveler.gray_mesh(trunk_mesh, Color(0.3, 0.22, 0.17))
		trunk.position.y = 0.5
		tree.add_child(trunk)
		for tier in 3:  # three stacked cones, narrowing upward
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 1.3 - 0.35 * tier
			cone.height = 1.7
			var layer := Traveler.gray_mesh(cone, Color(0.12, 0.27, 0.24).lightened(0.05 * tier))
			layer.position.y = 1.5 + 1.0 * tier
			tree.add_child(layer)
		$Scenery.add_child(tree)
		_register_prop(tree)
		keep_out.append(Vector2(float(pos[0]), float(pos[1])))


## The plant under a screen point, or null. Casts a ray from the camera at the
## plants' pick areas only.
func plant_at(screen_pos: Vector2) -> Node3D:
	var origin := camera.project_ray_origin(screen_pos)
	var end := origin + camera.project_ray_normal(screen_pos) * (CAMERA_DISTANCE * 3.0)
	var query := PhysicsRayQueryParameters3D.create(origin, end, 1 << (Plant.PICK_LAYER - 1))
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return (hit["collider"] as Node).get_parent() as Node3D


## Drives the hover tooltip. `delta` is the time since the last call, so tests
## can use simulated time. The name appears when the mouse moves onto a plant,
## stays tooltip_show_time seconds, then fades over tooltip_fade_time. It comes
## back only after the mouse has left the plant and entered a plant again; moving
## straight from one plant onto another starts the new tooltip at once.
func update_hover(screen_pos: Vector2, delta: float = 0.0) -> void:
	var plant := plant_at(screen_pos)
	if plant != _hover_plant:
		_hover_plant = plant
		_hover_time = 0.0
		if plant != null:
			_tooltip_label.text = plant.tooltip_text()
	elif plant != null:
		_hover_time += delta
	var opacity := 0.0
	if plant != null:
		var fading := _hover_time - tooltip_show_time
		opacity = 1.0 if fading <= 0.0 else 1.0 - fading / maxf(tooltip_fade_time, 0.001)
	_tooltip.visible = opacity > 0.0
	if not _tooltip.visible:
		return
	_tooltip.modulate.a = opacity
	_tooltip.reset_size()
	var room := get_viewport().get_visible_rect().size - _tooltip.size
	_tooltip.position = (screen_pos + TOOLTIP_OFFSET).clamp(Vector2.ZERO, room.max(Vector2.ZERO))


func _build_tooltip() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	_tooltip = PanelContainer.new()
	_tooltip.visible = false
	_tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_label = Label.new()
	_tooltip_label.add_theme_font_size_override("font_size", 20)
	_tooltip.add_child(_tooltip_label)
	layer.add_child(_tooltip)
	add_child(layer)


## The ridge and hills behind the far edge, from the data. Each piece's base
## height is the terrain height at its x plus the piece's offset, so it always
## stands on the ground at that x. A box may sink below its base so the slope
## never shows a gap under it.
func _build_backdrop(pieces: Array) -> void:
	for piece in pieces:
		var x := float(piece["x"])
		var z := float(piece["z"])
		var size: Array = piece["size"]
		var c: Array = piece["color"]
		var color := Color(c[0], c[1], c[2])
		var base := terrain.height_at(x) + float(piece["offset"])
		var stretch := float(piece.get("stretch_x", 1.0))
		var instance: MeshInstance3D
		var top: float
		var extent: Vector3  # half-size of the world-space box
		var middle: float    # world height of the box's centre
		if piece["shape"] == "cone":
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = float(size[0])
			cone.height = float(size[1])
			instance = Traveler.gray_mesh(cone, color)
			top = base + cone.height
			middle = base + cone.height / 2.0
			extent = Vector3(cone.bottom_radius * stretch, cone.height / 2.0, cone.bottom_radius)
		else:
			var box := BoxMesh.new()
			var sink := float(piece.get("sink", 0.0))
			box.size = Vector3(float(size[0]), float(size[1]) + sink, float(size[2]))
			instance = Traveler.gray_mesh(box, color)
			top = base + float(size[1])
			middle = top - box.size.y / 2.0
			extent = Vector3(box.size.x * stretch, box.size.y, box.size.z) / 2.0
		instance.scale.x = stretch
		instance.position = Vector3(x, middle, z)
		$Backdrop.add_child(instance)
		backdrop_pieces.append({
			"data": piece, "base": base, "top": top,
			"aabb": AABB(Vector3(x, middle, z) - extent, extent * 2.0),
		})


func _register_prop(prop: Node3D) -> void:
	prop.finish()
	var cell := floori(prop.bounds.get_center().x / FADE_CELL)
	if not _props_by_cell.has(cell):
		_props_by_cell[cell] = []
	_props_by_cell[cell].append(prop)


## True if `prop` stands between the camera and any sampled height of `traveler`.
## Orthographic camera: every view ray runs along the camera's own z axis.
func _covers(prop: Node3D, traveler: Node3D) -> bool:
	var toward: Vector3 = camera.global_transform.basis.z
	var box: AABB = prop.bounds.grow(Traveler.RADIUS)
	for height in FADE_SAMPLE_HEIGHTS:
		var from: Vector3 = traveler.global_position + Vector3(0.0, height, 0.0)
		if box.intersects_segment(from, from + toward * FADE_REACH) != null:
			return true
	return false


## Props covering a traveler fade to fade_opacity over fade_time seconds, and
## back to solid when they no longer do. Only the props in the x cells around
## each traveler are checked, and only props not yet solid are updated.
func update_prop_fade(delta: float) -> void:
	var covering := {}
	for traveler in travelers.values():
		var cell := floori(traveler.global_position.x / FADE_CELL)
		for neighbour in range(cell - 1, cell + 2):
			for prop in _props_by_cell.get(neighbour, []):
				if not covering.has(prop) and _covers(prop, traveler):
					covering[prop] = true
	for prop in covering:
		_fading[prop] = true
	var step := (1.0 - fade_opacity) / maxf(fade_time, 0.001) * delta
	for prop in _fading.keys():
		var covered: bool = covering.has(prop)
		prop.set_alpha(move_toward(prop.alpha, fade_opacity if covered else 1.0, step))
		if not covered and prop.alpha >= 1.0:
			_fading.erase(prop)


## Pushes a prop out of the way of plants, scenery and the travelers' starts,
## so the count (and every random draw) stays the same.
func _clear_of_keep_out(spot: Vector2) -> Vector2:
	for pass_index in NUDGE_PASSES:
		for point in keep_out:
			var away := spot - point
			if away.length() < KEEP_OUT:
				spot = point + (away.normalized() if away.length() > 0.001 else Vector2.RIGHT) * KEEP_OUT
	return spot


## Rocks and trees scattered over the whole ground at the data's density.
## Placeholder dressing: no collision.
func _build_props(props: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(props["seed"])
	var count := roundi(float(props["density_per_100m2"]) * ground_rect.get_area() / 100.0)
	var area := ground_rect.grow(-1.0)
	for i in count:
		var spot := Vector2(rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y))
		spot = _clear_of_keep_out(spot)
		var prop := Prop.new()
		prop.position = Vector3(spot.x, terrain.height_at(spot.x), spot.y)
		prop.rotation.y = rng.randf_range(0.0, TAU)
		# The alpine grassland has no forest: its trees are the 구상나무 scenery.
		var kind := i % 3
		if kind == 2 and zone_at(spot.x)["id"] == "alpine":
			kind = 0
		match kind:
			0:
				var box := BoxMesh.new()
				box.size = Vector3(rng.randf_range(0.8, 1.6), rng.randf_range(0.5, 1.1), rng.randf_range(0.8, 1.4))
				var rock := Traveler.gray_mesh(box, Color(0.38, 0.38, 0.4))
				rock.position.y = box.size.y / 2.0
				prop.add_child(rock)
			1:
				var cyl := CylinderMesh.new()
				cyl.top_radius = rng.randf_range(0.3, 0.5)
				cyl.bottom_radius = cyl.top_radius + 0.2
				cyl.height = rng.randf_range(0.5, 1.0)
				var rock := Traveler.gray_mesh(cyl, Color(0.45, 0.44, 0.43))
				rock.position.y = cyl.height / 2.0
				prop.add_child(rock)
			2:
				var trunk_mesh := CylinderMesh.new()
				trunk_mesh.top_radius = 0.22
				trunk_mesh.bottom_radius = 0.28
				trunk_mesh.height = 2.2
				var trunk := Traveler.gray_mesh(trunk_mesh, Color(0.34, 0.27, 0.2))
				trunk.position.y = 1.1
				prop.add_child(trunk)
				var crown_mesh := CylinderMesh.new()
				crown_mesh.top_radius = 0.0
				crown_mesh.bottom_radius = 1.2
				crown_mesh.height = 2.6
				var crown := Traveler.gray_mesh(crown_mesh, Color(0.2, 0.33, 0.24))
				crown.position.y = 3.2
				prop.add_child(crown)
		$Props.add_child(prop)
		_register_prop(prop)
