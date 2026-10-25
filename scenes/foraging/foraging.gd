extends Node3D
## Gray-box foraging map. Stage size and start positions come from
## data/mountains/<game>.json ("foraging"). Coordinates: x = along the stage
## (0..width), z = depth (-depth/2 far .. +depth/2 near the camera), 1 unit = 1 m.

const Traveler := preload("res://scenes/foraging/traveler.gd")

const CAMERA_PITCH_DEG := 28.0  # angled down, like a 90s beat-em-up
const CAMERA_DISTANCE := 30.0   # orthographic: only needs to clear the stage
const CAMERA_FOLLOW_RATE := 6.0
const CAMERA_LEAD := 4.0        # aims this far ahead (into the scene) of the player
const PARTNER_STOP_DISTANCE := 1.6
const TRAVELER_MARGIN := 0.4    # keeps a traveler's body inside the stage
const BACKDROP_DEPTH := 4.0     # how far the ridge reaches behind the far apron
const RIDGE_HEIGHT := 2.5

const NESTOR_COLOR := Color(0.36, 0.45, 0.65)    # slate blue
const FERNANDA_COLOR := Color(0.95, 0.55, 0.70)  # pink

var stage_width: float = 0.0
var stage_depth: float = 0.0
## Everything drawn as ground (walkable stage + apron), and the ridge footprint
## behind it, as Rect2s over (x, z).
var ground_rect := Rect2()
var backdrop_rect := Rect2()
var travelers: Dictionary = {}
var player: CharacterBody3D
var partner: CharacterBody3D

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
	_build_ground()
	_build_backdrop()
	_build_props(config["props"])
	var colors := {"nestor": NESTOR_COLOR, "fernanda": FERNANDA_COLOR}
	for id in GameState.TRAVELERS:
		var traveler := Traveler.new()
		$Travelers.add_child(traveler)
		traveler.setup(id.capitalize(), colors[id])
		traveler.bounds = Rect2(
			Vector2(TRAVELER_MARGIN, -stage_depth / 2.0 + TRAVELER_MARGIN),
			Vector2(stage_width - 2.0 * TRAVELER_MARGIN, stage_depth - 2.0 * TRAVELER_MARGIN))
		var start: Array = config["start"][id]
		traveler.global_position = Vector3(float(start[0]), 0.0, float(start[1]))
		travelers[id] = traveler
	player = travelers[GameState.controlled]
	partner = travelers[GameState.partner_of(GameState.controlled)]
	camera.rotation_degrees = Vector3(-CAMERA_PITCH_DEG, 0.0, 0.0)
	update_camera(0.0, true)


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


## Follows the player in x and z. The camera aims at a point on the ground;
## clamp_aim() keeps the view over ground (or backdrop, at the far edge).
func update_camera(delta: float, snap: bool = false) -> void:
	var pitch := deg_to_rad(CAMERA_PITCH_DEG)
	var aim := Vector2(camera.global_position.x, camera.global_position.z - CAMERA_DISTANCE * cos(pitch))
	var target := Vector2(player.global_position.x, player.global_position.z - CAMERA_LEAD)
	aim = target if snap else aim.lerp(target, 1.0 - exp(-CAMERA_FOLLOW_RATE * delta))
	aim = clamp_aim(aim)
	camera.global_position = Vector3(aim.x, CAMERA_DISTANCE * sin(pitch), aim.y + CAMERA_DISTANCE * cos(pitch))


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


func _build_ground() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(ground_rect.size.x, 0.2, ground_rect.size.y)
	var ground := Traveler.gray_mesh(mesh, Color(0.17, 0.18, 0.19))  # dark basalt
	var center := ground_rect.get_center()
	ground.position = Vector3(center.x, -0.1, center.y)
	$Ground.add_child(ground)


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


## Rocks and trees scattered over the whole ground at the data's density.
## Placeholder dressing: no collision.
func _build_props(props: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(props["seed"])
	var count := roundi(float(props["density_per_100m2"]) * ground_rect.get_area() / 100.0)
	var area := ground_rect.grow(-1.0)
	for i in count:
		var x := rng.randf_range(area.position.x, area.end.x)
		var z := rng.randf_range(area.position.y, area.end.y)
		var prop := Node3D.new()
		prop.position = Vector3(x, 0.0, z)
		prop.rotation.y = rng.randf_range(0.0, TAU)
		match i % 3:
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
