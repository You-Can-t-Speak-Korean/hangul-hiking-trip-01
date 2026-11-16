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
const Ground := preload("res://scenes/animals/ground.gd")
const Props := preload("res://scenes/animals/props.gd")
const Water := preload("res://scenes/animals/water.gd")

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
## The generated ground (Prompt 9a-iii): its image, and how long making it took.
var ground_image: Image
var ground_ms := 0
var props
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
	_choose_seed()  # the ground and the props are seeded too
	_build_ground()
	_build_lake()
	_build_travelers()
	_build_props()
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
	props.set_travelers(player.global_position, partner.global_position, float(config["camera"]["pitch_deg"]))


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
	var floor_y := terrain.height_at(spot.x)
	if walker.habitat == "lake":
		floor_y += float(config["lake"]["water_y"])  # ducks float on the surface
	animal_nodes[walker].pose(spot, floor_y, walker.altitude, walker.heading())


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

## The box a traveler's feet may stand in over (x, z): the stage, less the body radius.
func walk_bounds() -> Rect2:
	var r := Traveler.RADIUS
	return Rect2(Vector2(r, -stage_depth / 2.0 + r), Vector2(stage_width - 2.0 * r, stage_depth - 2.0 * r))


## Half the width, in metres, the orthographic camera shows.
func camera_half_width() -> float:
	var size := get_viewport().get_visible_rect().size
	return camera.size * (size.x / size.y) / 2.0


## Where the ray through a screen point meets the terrain, over (x, z). Numerical: the ray
## is cut with the terrain height under its last hit, a few times over.
func ground_hit(screen: Vector2) -> Vector2:
	var origin := camera.project_ray_origin(screen)
	var direction := camera.project_ray_normal(screen)
	var hit := origin
	var y := terrain.height_at(origin.x)
	for i in 6:
		hit = origin + direction * ((y - origin.y) / direction.y)
		y = terrain.height_at(hit.x)
	return Vector2(hit.x, hit.z)


## The ground the camera shows, as the hits of the four screen corners (top left, top right,
## bottom right, bottom left).
func camera_footprint() -> Array[Vector2]:
	var size := get_viewport().get_visible_rect().size
	return [ground_hit(Vector2(0.0, 0.0)), ground_hit(Vector2(size.x, 0.0)), ground_hit(size), ground_hit(Vector2(0.0, size.y))]


## Follows the player in x, z and height; then fit_camera() keeps the view over the map.
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
	camera.global_position = Vector3(aim.x, _aim_height + distance * sin(pitch), aim.y + distance * cos(pitch))
	fit_camera()


## Slides the camera so that the screen's bottom edge is no farther than the map's near edge,
## its left and right edges (at the player's screen row) no farther than the map's sides, and
## its top edge no farther than `camera.far_overshoot_m` past the far edge. It measures the
## real footprint (ground_hit), so the slope and the tilt are included.
func fit_camera() -> void:
	for i in 4:
		var shift := _fit_shift()
		if shift == Vector2.ZERO:
			return
		camera.global_position += Vector3(shift.x, 0.0, shift.y)


func _fit_shift() -> Vector2:
	var view := get_viewport().get_visible_rect().size
	var row := clampf(camera.unproject_position(player.global_position).y, 0.0, view.y)
	var left := ground_hit(Vector2(0.0, row)).x
	var right := ground_hit(Vector2(view.x, row)).x
	var top := ground_hit(Vector2(view.x / 2.0, 0.0)).y
	var bottom := ground_hit(Vector2(view.x / 2.0, view.y)).y
	var far_limit := -stage_depth / 2.0 - float(config["camera"]["far_overshoot_m"])
	var near_limit := stage_depth / 2.0
	var shift := Vector2.ZERO
	if right - left >= stage_width:  # the view is wider than the map: centre it
		shift.x = stage_width / 2.0 - (left + right) / 2.0
	elif left < 0.0:
		shift.x = -left
	elif right > stage_width:
		shift.x = stage_width - right
	if bottom - top >= near_limit - far_limit:
		shift.y = (near_limit + far_limit) / 2.0 - (top + bottom) / 2.0
	elif bottom > near_limit:
		shift.y = near_limit - bottom
	elif top < far_limit:
		shift.y = far_limit - top
	return shift if shift.length() > 0.0005 else Vector2.ZERO


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
	var started := Time.get_ticks_msec()
	ground_image = Ground.image(config, crossing_seed)
	ground_ms = Time.get_ticks_msec() - started
	var texture := ImageTexture.create_from_image(ground_image)
	var color := Color.WHITE  # the texture carries the colour
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
			surface.set_uv(Vector2((corner.x - ground_rect.position.x) / ground_rect.size.x, (corner.z - ground_rect.position.y) / ground_rect.size.y))
			surface.set_normal(Vector3(-terrain.slope_at(corner.x), 1.0, 0.0).normalized())
			surface.add_vertex(corner)
	var material := StandardMaterial3D.new()
	var light := float(config["ground"]["light_scale"])
	material.albedo_color = Color(light, light, light).linear_to_srgb()  # (albedo_color is sRGB, the factor is linear)
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
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


## The 백록담: the water surface (a half disc on the ground, Water) and an invisible round
## wall on the same circle.
func _build_lake() -> void:
	var lake: Dictionary = config["lake"]
	lake_center = Vector2(float(lake["center"][0]), float(lake["center"][1]))
	lake_radius = float(lake["radius"])
	var water := Water.build(config, terrain)  # the surface; the ground under it is plain
	add_child(water)
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


## The scenery (visual only), as MultiMeshes under $Props.
func _build_props() -> void:
	var holder := Node3D.new()
	holder.name = "Props"
	add_child(holder)
	props = Props.new()
	props.build(holder, config, crossing_seed, terrain.height_at)
	props.set_travelers(player.global_position, partner.global_position, float(config["camera"]["pitch_deg"]))


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
