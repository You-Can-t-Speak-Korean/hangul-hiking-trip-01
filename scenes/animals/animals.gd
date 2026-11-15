extends Node3D
## The animal sightseeing scene, skeleton (data: animals in data/mountains/<game>.json).
## Fernanda and Nestor walk a flat gray-box map beside a placeholder 백록담 while
## placeholder animals cross it. The scene is thin: the travelers, the terrain, the HUDs
## and the menus are the foraging scene's scripts, and the crossings are Crossing's.
## Coordinates as in foraging: x along the stage (0..width), z depth, 1 unit = 1 m.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const Terrain := preload("res://scenes/foraging/terrain.gd")
const HeartsHud := preload("res://scenes/foraging/hearts_hud.gd")
const PauseMenu := preload("res://scenes/foraging/pause_menu.gd")
const PauseMenuHud := preload("res://scenes/foraging/pause_menu_hud.gd")
const Backpack := preload("res://scenes/foraging/backpack.gd")
const BackpackHud := preload("res://scenes/foraging/backpack_hud.gd")
const Crossing := preload("res://scenes/animals/crossing.gd")
const Animal := preload("res://scenes/animals/animal.gd")

const GROUND_STEP := 1.0   # metres between ground mesh vertices along x

## Set by tests (and nothing else) before a scene is built: >= 0 fixes the crossing seed
## (a --seed=N user argument does the same when this is -1).
static var seed_override := -1

var config: Dictionary = {}
var stage_width := 0.0
var stage_depth := 0.0
## Everything drawn as ground (stage + apron), as a Rect2 over (x, z).
var ground_rect := Rect2()
var terrain: Terrain
## The 백록담: a half disc on the bottom edge (centre, radius over (x, z)); nobody walks into it.
var lake_center := Vector2.ZERO
var lake_radius := 0.0
var travelers: Dictionary = {}
var player: CharacterBody3D
var partner: CharacterBody3D
var crossing
var crossing_seed := 0
## Walker -> the Animal node that shows it.
var animal_nodes: Dictionary = {}
var pause_menu
var pause_hud: CanvasLayer
var backpack
var backpack_hud: CanvasLayer
var hearts_hud: CanvasLayer

## Restart scene was chosen: the scene-start snapshot is back (the scene then reloads).
signal restarted

var _aim_height := 0.0

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	config = Content.mountain(GameState.game_id).get("animals", {})
	if config.is_empty():
		push_error("No animals data for %s" % GameState.game_id)
		return
	var ui: Dictionary = Content.mountain(GameState.game_id)[String(config["ui_from"])]
	stage_width = float(config["stage"]["width"])
	stage_depth = float(config["stage"]["depth"])
	var apron: Dictionary = config["apron"]
	var side := float(apron["sides"])
	var far := float(apron["far"])
	ground_rect = Rect2(
		Vector2(-side, -stage_depth / 2.0 - far),
		Vector2(stage_width + 2.0 * side, stage_depth + far + side))
	terrain = Terrain.new(config["terrain"]["points"])
	var cam: Dictionary = config["camera"]
	camera.size = float(cam["size"])
	camera.rotation_degrees = Vector3(-float(cam["pitch_deg"]), 0.0, 0.0)
	$WorldEnvironment.environment.background_color = _color(config["backdrop_color"])
	GameState.begin_scene(String(config["begin_id"]))  # a pending bank for this scene is applied here
	_build_ground()
	_build_lake()
	_build_travelers()
	hearts_hud = HeartsHud.new()
	add_child(hearts_hud)
	hearts_hud.setup(ui["hearts_hud"])
	pause_menu = PauseMenu.new()
	pause_hud = PauseMenuHud.new()
	add_child(pause_hud)
	pause_hud.setup(pause_menu, ui["pause_menu"])
	pause_hud.chosen.connect(_on_pause_chosen)
	backpack = Backpack.new()
	backpack_hud = BackpackHud.new()
	add_child(backpack_hud)
	backpack_hud.setup(backpack, GameState.inventory, ui["backpack_hud"])
	backpack_hud.open_handler = open_backpack
	backpack_hud.notebook_open_handler = open_notebook
	backpack_hud.close_requested.connect(close_backpack)
	_choose_seed()
	crossing = Crossing.new(config, crossing_seed)
	update_camera(0.0, true)


func _exit_tree() -> void:
	if (pause_menu != null and pause_menu.is_open) or (backpack != null and backpack.is_open):  # never leave the tree paused behind
		get_tree().paused = false


func _physics_process(delta: float) -> void:
	step(Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down"), delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		open_pause_menu()
		get_viewport().set_input_as_handled()


## One tick of the map. Public so tests can drive it without a keyboard. While the pause
## menu or the backpack is open nobody walks and no animal moves.
func step(input: Vector2, delta: float) -> void:
	if not pause_menu.is_open and not backpack.is_open:
		player.drive(input, delta)
		partner.follow(player.global_position, float(config["partner_stop_distance"]), delta)
		for t in travelers.values():
			_push_out_of_lake(t)
		_tick_animals(delta)
	update_camera(delta)


# ---- Animals ----

## The crossing seed of this scene start: `seed_override` (tests), else the --seed=N user
## argument, else a new random one. Prints it in one line.
func _choose_seed() -> void:
	var found := false
	if seed_override >= 0:
		crossing_seed = seed_override
		found = true
	else:
		var arg := Crossing.seed_from_args(OS.get_cmdline_user_args())
		if arg["problem"] != "":
			push_error("%s: --seed ignored, the animals are random" % arg["problem"])
		if arg["found"]:
			crossing_seed = arg["seed"]
			found = true
	if not found:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		crossing_seed = rng.seed
	print("animals_seed=%d" % crossing_seed)


func _tick_animals(delta: float) -> void:
	for event in crossing.tick(delta):
		if event["event"] == Crossing.SPAWN:
			_add_animal(event["walker"])
		else:
			_remove_animal(event["walker"])
	for walker in animal_nodes:
		_pose(walker)


func _add_animal(walker) -> void:
	var node := Animal.new()
	node.setup(walker.kind, config["label"])
	$Animals.add_child(node)
	animal_nodes[walker] = node
	_pose(walker)


func _remove_animal(walker) -> void:
	var node: Node3D = animal_nodes[walker]
	animal_nodes.erase(walker)
	node.get_parent().remove_child(node)
	node.queue_free()


func _pose(walker) -> void:
	var spot: Vector2 = walker.position()
	animal_nodes[walker].pose(spot, terrain.height_at(spot.x), walker.altitude, walker.heading())


# ---- Menus (the foraging scene's, with the same keys) ----

## Esc: opens the pause menu and pauses the map. False while the backpack is open or the
## menu is open already.
func open_pause_menu() -> bool:
	if backpack.is_open or not pause_menu.open(true):
		return false
	pause_hud.refresh()
	get_tree().paused = true
	return true


## A backpack key with the panel closed (the HUD calls this). False while the pause menu is
## open (or a restart was asked for) or the panel is open already.
func open_backpack() -> bool:
	if not _panel_allowed() or not backpack.open(true):
		return false
	_pause_for_panel()
	return true


## A notebook quick key (`action` is "notebook_p1" or "notebook_p2"): the panel opens on the
## 수첩, under the rules of open_backpack().
func open_notebook(action: String) -> bool:
	if not _panel_allowed() or not backpack.open_notebook_quick(true, action, GameState.inventory.items()):
		return false
	_pause_for_panel()
	return true


func _panel_allowed() -> bool:
	return not pause_menu.is_open and pause_menu.restart_requests == 0


func _pause_for_panel() -> void:
	backpack_hud.refresh()
	get_tree().paused = true


## Closes the backpack and lets the map go on in place. False if it was not open.
func close_backpack() -> bool:
	if not backpack.close():
		return false
	get_tree().paused = false
	backpack_hud.refresh()
	return true


## The menu said what was chosen ("ask" and "back" only change what it shows).
func _on_pause_chosen(result: String) -> void:
	if result == "resume" or result == "restart":
		get_tree().paused = false
	if result == "restart":
		_restart()


## Restart scene: the hearts, DDEOK and backpack go back to what the scene began with, and
## the scene is reloaded. (A scene that is not the current one, as in the tests, only
## restores GameState and announces `restarted`.)
func _restart() -> void:
	GameState.restart_scene()
	backpack.reset()
	backpack_hud.refresh()
	restarted.emit()
	if get_tree().current_scene == self:
		get_tree().reload_current_scene()


# ---- Walking and the camera ----

## The box a traveler's feet may stand in over (x, z): the stage, inset by the data margin.
func walk_bounds() -> Rect2:
	var m := float(config["walk_limit"]["margin"])
	return Rect2(Vector2(m, -stage_depth / 2.0 + m), Vector2(stage_width - 2.0 * m, stage_depth - 2.0 * m))


## Half the width, in metres, the orthographic camera shows.
func camera_half_width() -> float:
	var size := get_viewport().get_visible_rect().size
	return camera.size * (size.x / size.y) / 2.0


## Half the depth, in metres of ground, the tilted camera shows.
func camera_half_depth() -> float:
	return camera.size / (2.0 * sin(deg_to_rad(float(config["camera"]["pitch_deg"]))))


## Follows the player in x, z and height; clamp_aim() keeps the view over the ground.
func update_camera(delta: float, snap: bool = false) -> void:
	var cam: Dictionary = config["camera"]
	var pitch := deg_to_rad(float(cam["pitch_deg"]))
	var distance := float(cam["distance"])
	var rate := float(cam["follow_rate"])
	var aim := Vector2(camera.global_position.x, camera.global_position.z - distance * cos(pitch))
	var target := Vector2(player.global_position.x, player.global_position.z - float(cam["lead"]))
	aim = target if snap else aim.lerp(target, 1.0 - exp(-rate * delta))
	var height := player.global_position.y
	_aim_height = height if snap else lerpf(_aim_height, height, 1.0 - exp(-rate * delta))
	aim = clamp_aim(aim)
	camera.global_position = Vector3(aim.x, _aim_height + distance * sin(pitch), aim.y + distance * cos(pitch))


## The view must not pass the ground's left, right and near edges. The far end is open on
## purpose (the sky is the backdrop there).
func clamp_aim(aim: Vector2) -> Vector2:
	var half := Vector2(camera_half_width(), camera_half_depth())
	return Vector2(
		_clamp_axis(aim.x, ground_rect.position.x + half.x, ground_rect.end.x - half.x),
		_clamp_axis(aim.y, -INF, ground_rect.end.y - half.y))


## Clamps, or centres if the range is empty (the view is bigger than the ground).
func _clamp_axis(value: float, low: float, high: float) -> float:
	return (low + high) / 2.0 if low > high else clampf(value, low, high)


# ---- Building ----

func _build_travelers() -> void:
	var colors: Dictionary = config["traveler_colors"]
	for id in GameState.TRAVELERS:
		var traveler := Traveler.new()
		$Travelers.add_child(traveler)
		traveler.setup(id.capitalize(), _color(colors[id]))
		traveler.bounds = walk_bounds()
		var start: Array = config["start"][id]
		traveler.global_position = Vector3(float(start[0]), terrain.height_at(float(start[0])), float(start[1]))
		travelers[id] = traveler
	player = travelers[GameState.controlled]
	partner = travelers[GameState.partner_of(GameState.controlled)]
	for t in travelers.values():  # settle onto the ground before the first frame
		for i in 10:
			t.drive(Vector2.ZERO, 1.0 / 60.0)


## The ground as strips along x, flat across z, with a height-map collider (as in foraging).
func _build_ground() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var color := _color(config["ground_color"])
	var z_near := ground_rect.end.y
	var z_far := ground_rect.position.y
	var count := ceili(ground_rect.size.x / GROUND_STEP)
	var step := ground_rect.size.x / count
	for i in count:
		var x0 := ground_rect.position.x + i * step
		var x1 := x0 + step
		var corners := [Vector3(x0, terrain.height_at(x0), z_far), Vector3(x1, terrain.height_at(x1), z_far),
				Vector3(x1, terrain.height_at(x1), z_near), Vector3(x0, terrain.height_at(x0), z_near)]
		for index in [0, 1, 2, 0, 2, 3]:
			var corner: Vector3 = corners[index]
			surface.set_color(color)
			surface.set_normal(Vector3(-terrain.slope_at(corner.x), 1.0, 0.0).normalized())
			surface.add_vertex(corner)
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	var ground := MeshInstance3D.new()
	ground.mesh = surface.commit()
	ground.material_override = material
	$Ground.add_child(ground)
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
	shape.scale = Vector3(step, 1.0, ground_rect.size.y / (rows - 1))  # one unit between samples, scaled to the real spacing
	var centre := ground_rect.get_center()
	shape.position = Vector3(centre.x, 0.0, centre.y)
	var body := StaticBody3D.new()
	body.add_child(shape)
	$Ground.add_child(body)


## The 백록담: a filled half disc on the ground (the part of the circle on the map) and an
## invisible round wall on the same circle.
func _build_lake() -> void:
	var lake: Dictionary = config["lake"]
	lake_center = Vector2(float(lake["center"][0]), float(lake["center"][1]))
	lake_radius = float(lake["radius"])
	var lift := float(lake["height"])
	var steps := int(lake["arc_steps"])
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre := Vector3(lake_center.x, terrain.height_at(lake_center.x) + lift, lake_center.y)
	for i in steps:
		var a0 := PI * float(i) / steps
		var a1 := PI * float(i + 1) / steps
		var p0 := Vector2(lake_center.x + cos(a0) * lake_radius, lake_center.y - sin(a0) * lake_radius)
		var p1 := Vector2(lake_center.x + cos(a1) * lake_radius, lake_center.y - sin(a1) * lake_radius)
		for corner in [centre, Vector3(p1.x, terrain.height_at(p1.x) + lift, p1.y), Vector3(p0.x, terrain.height_at(p0.x) + lift, p0.y)]:
			surface.set_normal(Vector3.UP)
			surface.add_vertex(corner)
	var water := Traveler.gray_mesh(surface.commit(), _color(lake["color"]))
	(water.material_override as StandardMaterial3D).cull_mode = BaseMaterial3D.CULL_DISABLED
	water.name = "Water"
	$Pond.add_child(water)
	var wall := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	var wall_height := float(lake["wall_height"])
	cylinder.radius = lake_radius
	cylinder.height = wall_height
	wall.shape = cylinder
	wall.position = Vector3(lake_center.x, terrain.height_at(lake_center.x) + wall_height / 2.0 - 0.5, lake_center.y)
	var body := StaticBody3D.new()
	body.name = "Wall"
	body.add_child(wall)
	$Pond.add_child(body)


## Whether a point over (x, z) is in the water.
func in_lake(point: Vector2) -> bool:
	return point.distance_to(lake_center) < lake_radius and point.y <= lake_center.y


## Safety net behind the wall: a traveler found in the water is set on the shore.
func _push_out_of_lake(traveler: Node3D) -> void:
	var spot := Vector2(traveler.global_position.x, traveler.global_position.z)
	if not in_lake(spot):
		return
	var offset := spot - lake_center
	var direction := offset.normalized() if offset.length() > 0.000001 else Vector2(0.0, -1.0)
	var out := lake_center + direction * (lake_radius + 0.05)
	traveler.global_position = Vector3(out.x, traveler.global_position.y, out.y)


static func _color(channels: Array) -> Color:
	return Color(float(channels[0]), float(channels[1]), float(channels[2]))
