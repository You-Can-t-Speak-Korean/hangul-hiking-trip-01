extends Node3D
## Gray-box foraging map. Stage size and start positions come from
## data/mountains/<game>.json ("foraging"). Coordinates: x = along the stage
## (0..width), z = depth (-depth/2 far .. +depth/2 near the camera), 1 unit = 1 m.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const Terrain := preload("res://scenes/foraging/terrain.gd")
const Plant := preload("res://scenes/foraging/plant.gd")

const CAMERA_PITCH_DEG := 28.0  # angled down, like a 90s beat-em-up
const CAMERA_DISTANCE := 30.0   # orthographic: only needs to clear the stage
const CAMERA_FOLLOW_RATE := 6.0
const CAMERA_LEAD := 4.0        # aims this far ahead (into the scene) of the player
const PARTNER_STOP_DISTANCE := 1.6
const TRAVELER_MARGIN := 0.4    # keeps a traveler's body inside the stage
const BACKDROP_DEPTH := 4.0     # how far the ridge reaches behind the far apron
const RIDGE_HEIGHT := 2.5

const GROUND_STEP := 1.0        # metres between ground mesh vertices along x
const KEEP_OUT := 1.8           # props are pushed this far from plants, trees and starts
const TOOLTIP_OFFSET := Vector2(16.0, 18.0)

const NESTOR_COLOR := Color(0.36, 0.45, 0.65)    # slate blue
const FERNANDA_COLOR := Color(0.95, 0.55, 0.70)  # pink

var stage_width: float = 0.0
var stage_depth: float = 0.0
## Everything drawn as ground (walkable stage + apron), and the ridge footprint
## behind it, as Rect2s over (x, z).
var ground_rect := Rect2()
var backdrop_rect := Rect2()
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

var _aim_height := 0.0
var _tooltip: PanelContainer
var _tooltip_label: Label

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
	backdrop_rect = Rect2(
		Vector2(ground_rect.position.x, ground_rect.position.y - BACKDROP_DEPTH),
		Vector2(ground_rect.size.x, BACKDROP_DEPTH))
	terrain = Terrain.new(config["terrain"]["points"])
	zones = config["zones"]
	for id in GameState.TRAVELERS:
		keep_out.append(Vector2(float(config["start"][id][0]), float(config["start"][id][1])))
	_build_plants(config["plants"]["kinds"])
	_build_scenery(config["scenery"])
	_build_ground()
	_build_backdrop()
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


func _process(_delta: float) -> void:
	if DisplayServer.get_name() != "headless":
		update_hover(get_viewport().get_mouse_position())


func _physics_process(delta: float) -> void:
	step(Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down"), delta)


## One tick of the map. Public so tests and the capture scene can drive it
## without a keyboard.
func step(input: Vector2, delta: float) -> void:
	player.drive(input, delta)
	partner.follow(player.global_position, PARTNER_STOP_DISTANCE, delta)
	update_camera(delta)


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


## The 20 plants: positions come from the data, height from the terrain.
## Targets carry the letters of their own name.
func _build_plants(kinds: Array) -> void:
	for kind in kinds:
		var tiles: Array[String] = []
		if kind["kind"] == "target":
			tiles = Hangul.tiles_for(kind["name"])
		for pos in kind["positions"]:
			var plant := Plant.new()
			plant.setup(kind, tiles)
			plant.position = Vector3(float(pos[0]), terrain.height_at(float(pos[0])), float(pos[1]))
			$Plants.add_child(plant)
			plants.append(plant)
			keep_out.append(Vector2(float(pos[0]), float(pos[1])))


## 구상나무 (Korean fir): scenery only, no letters, nothing to forage.
func _build_scenery(scenery: Dictionary) -> void:
	for pos in scenery["gusangnamu"]["positions"]:
		var tree := Node3D.new()
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


## Shows the tooltip for the plant under `screen_pos`, hides it over nothing.
func update_hover(screen_pos: Vector2) -> void:
	var plant := plant_at(screen_pos)
	_tooltip.visible = plant != null
	if plant == null:
		return
	_tooltip_label.text = plant.tooltip_text()
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


## A basalt ridge behind the far edge, topped with simple hills.
func _build_backdrop() -> void:
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(backdrop_rect.size.x, RIDGE_HEIGHT, backdrop_rect.size.y)
	var slab := Traveler.gray_mesh(slab_mesh, Color(0.22, 0.22, 0.23))
	var center := backdrop_rect.get_center()
	slab.position = Vector3(center.x, RIDGE_HEIGHT / 2.0, center.y)
	$Backdrop.add_child(slab)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var hill_count := int(backdrop_rect.size.x / 4.0)
	for i in hill_count:
		var x := backdrop_rect.position.x + (i + 0.5) * backdrop_rect.size.x / hill_count + rng.randf_range(-1.0, 1.0)
		var height := rng.randf_range(1.0, 2.0)
		var hill: MeshInstance3D
		var reach: float  # how far it extends in z, so it stays on the slab
		if i % 2 == 0:
			var cone := CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = rng.randf_range(1.2, 1.8)
			cone.height = height
			reach = cone.bottom_radius
			hill = Traveler.gray_mesh(cone, Color(0.2, 0.3, 0.24))
		else:
			var block := BoxMesh.new()
			block.size = Vector3(rng.randf_range(2.0, 3.0), height, rng.randf_range(1.5, 3.0))
			reach = block.size.z / 2.0
			hill = Traveler.gray_mesh(block, Color(0.27, 0.27, 0.29))
		var z := backdrop_rect.end.y - reach - rng.randf_range(0.0, BACKDROP_DEPTH - 2.0 * reach)
		hill.scale.x = 2.5  # wide, low mounds
		hill.position = Vector3(x, RIDGE_HEIGHT + height / 2.0 - 0.1, z)
		$Backdrop.add_child(hill)


## Pushes a prop out of the way of plants, scenery and the travelers' starts,
## so the count (and every random draw) stays the same.
func _clear_of_keep_out(spot: Vector2) -> Vector2:
	for pass_index in 2:
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
		var prop := Node3D.new()
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
