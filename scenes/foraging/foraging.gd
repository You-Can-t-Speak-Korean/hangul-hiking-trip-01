extends Node3D
## Gray-box foraging map. Stage size and start positions come from
## data/mountains/<game>.json ("foraging"). Coordinates: x = along the stage
## (0..width), z = depth (-depth/2 far .. +depth/2 near the camera), 1 unit = 1 m.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const Terrain := preload("res://scenes/foraging/terrain.gd")
const Plant := preload("res://scenes/foraging/plant.gd")
const Prop := preload("res://scenes/foraging/prop.gd")
const Discovery := preload("res://scenes/foraging/discovery.gd")
const DiscoveryHud := preload("res://scenes/foraging/discovery_hud.gd")
const Picking := preload("res://scenes/foraging/picking.gd")
const BasketHud := preload("res://scenes/foraging/basket_hud.gd")
const Spelling := preload("res://scenes/foraging/spelling.gd")
const SpellingHud := preload("res://scenes/foraging/spelling_hud.gd")
const SteamSound := preload("res://scenes/foraging/steam_sound.gd")
const Damage := preload("res://scenes/foraging/damage.gd")
const Spares := preload("res://scenes/foraging/spares.gd")
const HeartsHud := preload("res://scenes/foraging/hearts_hud.gd")
const Stuck := preload("res://scenes/foraging/stuck.gd")
const Countdown := preload("res://scenes/foraging/countdown.gd")
const KillTimeline := preload("res://scenes/foraging/kill_timeline.gd")
const StuckHud := preload("res://scenes/foraging/stuck_hud.gd")
const StuckMusic := preload("res://scenes/foraging/stuck_music.gd")
const Deer := preload("res://scenes/foraging/deer.gd")

const CAMERA_PITCH_DEG := 28.0  # angled down, like a 90s beat-em-up
const CAMERA_DISTANCE := 30.0   # orthographic: only needs to clear the stage
const CAMERA_FOLLOW_RATE := 6.0
const CAMERA_LEAD := 4.0        # aims this far ahead (into the scene) of the player
const PARTNER_STOP_DISTANCE := 1.6
const TRAVELER_MARGIN := 0.4    # keeps a traveler's body inside the stage
const FADE_REACH := 14.0        # how far toward the camera a prop can still cover a traveler
const FADE_CELL := 4.0          # props are bucketed by x so only those near a traveler are checked
const FADE_SAMPLE_HEIGHTS := [0.3, 0.85, 1.5]  # feet, waist and head of a traveler

const NEAR_SAMPLES := 8        # heights sampled across the view when finding how far the near edge must pull back
const GROUND_STEP := 1.0       # metres between ground mesh vertices along x
const KEEP_OUT := 1.8           # props are pushed this far from plants, trees and starts
const NUDGE_PASSES := 12         # a pushed prop can land near another point, so repeat
const TOOLTIP_OFFSET := Vector2(16.0, 18.0)
const WALK_UP_TIP_LIFT := 1.2   # metres above a plant where its walk-up name is anchored
const RING_SEGMENTS := 48
const RING_LIFT := 0.04         # metres above the ground, so the ring never z-fights
const GROW_MIN_SCALE := 0.001   # a spare starts here, not at 0, which a transform cannot hold

const NESTOR_COLOR := Color(0.36, 0.45, 0.65)    # slate blue
const FERNANDA_COLOR := Color(0.95, 0.55, 0.70)  # pink

var stage_width: float = 0.0
var stage_depth: float = 0.0
## Everything drawn as ground (walkable stage + apron), and the ridge footprint
## behind it, as Rect2s over (x, z).
var ground_rect := Rect2()
var backdrop_rect := Rect2()
var near_margin := 0.3    # feet stop this far (m, along z) above the bottom of the screen (data: walk_limit)
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
## Which target kinds the travelers have walked up to, and the HUD that lists them.
var discovery
var discovery_hud: CanvasLayer
## Which letters are still on their plants and what is in the basket, and the basket's HUD.
var picking
var basket_hud: CanvasLayer
## What has been spelled, and the spelling view. Opening the view pauses the
## tree; the HUDs run while paused (process mode ALWAYS), the map does not.
var spelling
var spelling_hud: CanvasLayer
## What a failed syllable costs, applied when the spelling view has closed.
var damage
var hearts_hud: CanvasLayer
## Spare plants: which words earned one, and the spares themselves (they are in
## `plants` too, after the placed ones).
var spares
var spare_plants: Array[Node3D] = []
## Set from the moment both travelers die (begin_death_beat), or from the last
## second of the stuck countdown (_tick_stuck), until the scene is restarted:
## picks, walks, hover names and opening the spelling view are ignored.
var restarting := false
## Data: foraging.stuck_music.
var music_config: Dictionary = {}
## The stuck countdown (see Stuck, Countdown), its HUD and the verdict of the
## latest evaluation: {"stuck", "reason", "plan"}. `stuck_log` keeps every
## evaluation: {"event", "stuck", "reason"}.
var countdown
var stuck_hud: CanvasLayer
var stuck_verdict: Dictionary = {"stuck": false, "reason": "not evaluated", "plan": []}
var stuck_log: Array[Dictionary] = []
## The monster (data: foraging.monster): its kill timeline once the countdown ran
## out, the deer node, and the travelers in the order it hits them.
var monster: Dictionary = {}
var kill
var deer: Node3D
var kill_order: Array[String] = []
## The placeholder countdown music: whether it is meant to be playing, how many
## times it started and stopped, and how many calls reached the audio player
## (always 0 headless, where nothing is played).
var music_playing := false
var music_starts := 0
var music_stops := 0
var audio_calls := 0
## Placeholder gore and the death beat (data: foraging.gore_placeholder).
var gore: Dictionary = {}
var travelers: Dictionary = {}
var player: CharacterBody3D
var partner: CharacterBody3D

var fade_opacity := 1.0   # opacity of a prop covering a traveler (data: prop_fade)
var fade_time := 0.2      # seconds to fade in or out (data: prop_fade)
var tooltip_steady_time := 0.5   # seconds the hover name stays solid (data: tooltip)
var tooltip_flicker_time := 0.4  # seconds it then flickers before it is gone (data: tooltip)
var tooltip_flicker_rate := 10.0  # visible/hidden changes per second while flickering (data: tooltip)

## Both travelers have died: the death beat starts (the screen dims) and the
## scene restarts when it ends.
signal death_beat_started
signal restarted

var _aim_height := 0.0
var _beat_left := -1.0  # seconds of death beat left; -1 when none is playing
var _dim: ColorRect
var _steam_stream: AudioStreamWAV
var _music_stream: AudioStreamWAV
var _music_player: AudioStreamPlayer
var _music_tween: Tween
var _deer_start := Vector3.ZERO  # just off the left edge of the screen, where the deer leaps from
var _tooltip: PanelContainer
var _tooltip_label: Label
var _hover_plant: Node3D   # the plant under the mouse
var _tip_plant: Node3D     # the plant whose name is up (hover or walk-up; the latest wins)
var _tip_by_mouse := false
var _hover_time := 0.0
var _ring: MeshInstance3D
var _ring_material: StandardMaterial3D
var _ring_time := 0.0
var _ring_plant: Node3D
var _props_by_cell: Dictionary = {}  # int cell of x -> Array of Prop
var _fading: Dictionary = {}         # Prop -> true, while its opacity is not 1.0
var _kinds: Dictionary = {}          # plant kind id -> its data
var _growing: Array[Dictionary] = [] # spares growing in: {"plant", "index", "left"}

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
	near_margin = float(config["walk_limit"]["near_margin"])
	var backdrop_depth := float(config["backdrop"]["depth"])
	backdrop_rect = Rect2(
		Vector2(ground_rect.position.x, ground_rect.position.y - backdrop_depth),
		Vector2(ground_rect.size.x, backdrop_depth))
	fade_opacity = float(config["prop_fade"]["opacity"])
	fade_time = float(config["prop_fade"]["time"])
	tooltip_steady_time = float(config["tooltip"]["steady_time"])
	tooltip_flicker_time = float(config["tooltip"]["flicker_time"])
	tooltip_flicker_rate = float(config["tooltip"]["flicker_rate"])
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
	discovery = Discovery.new(config["discovery"], config["plants"])
	discovery_hud = DiscoveryHud.new()
	add_child(discovery_hud)
	picking = Picking.new(config["picking"], config["plants"], config["reach_ring"])
	spelling = Spelling.new(config["spelling_view"], config["plants"], picking.basket)
	discovery_hud.setup(discovery, spelling)
	discovery_hud.entry_pressed.connect(open_spelling)
	_build_ring()
	basket_hud = BasketHud.new()
	add_child(basket_hud)
	basket_hud.setup(picking, config["basket_hud"])
	spelling_hud = SpellingHud.new()
	add_child(spelling_hud)
	spelling_hud.setup(spelling, basket_hud, config["keyboard_select"])
	spelling_hud.changed.connect(_on_spelling_changed)
	spelling_hud.closed.connect(_on_spelling_closed)
	damage = Damage.new(config["damage"])
	gore = config["gore_placeholder"]
	spelling.syllable_failed.connect(_on_syllable_failed)
	spares = Spares.new(config["spares"], config["plants"])
	spelling.word_completed.connect(spares.queue)
	hearts_hud = HeartsHud.new()
	add_child(hearts_hud)
	hearts_hud.setup(config["hearts_hud"])
	countdown = Countdown.new(config["stuck"])
	stuck_hud = StuckHud.new()
	add_child(stuck_hud)
	stuck_hud.setup(config["stuck"])
	monster = config["monster"]
	music_config = config["stuck_music"]
	GameState.begin_scene("foraging")  # a death restores the hearts held now
	var colors := {"nestor": NESTOR_COLOR, "fernanda": FERNANDA_COLOR}
	for id in GameState.TRAVELERS:
		var traveler := Traveler.new()
		$Travelers.add_child(traveler)
		traveler.setup(id.capitalize(), colors[id])
		traveler.bounds = walk_bounds()
		traveler.near_limit = near_limit_at
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
	evaluate_stuck("scene start")


func _exit_tree() -> void:
	if spelling_hud != null and spelling_hud.is_open():  # never leave the tree paused behind
		get_tree().paused = false


func _process(delta: float) -> void:
	tick_beat(delta)
	if DisplayServer.get_name() != "headless":
		update_hover(get_viewport().get_mouse_position(), delta)


func _physics_process(delta: float) -> void:
	step(Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down"), delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click(event.position)
	elif event.is_action_pressed("p1_pick"):  # no echo: holding Space picks once
		pick_nearest()
		get_viewport().set_input_as_handled()


## One tick of the map. Public so tests and the capture scene can drive it
## without a keyboard.
func step(input: Vector2, delta: float) -> void:
	var walk := input
	if not input.is_zero_approx() or not picks_allowed():
		picking.cancel_walk()  # the keys take over
	elif picking.walk_target >= 0:
		walk = _walk_step(delta)
	if not restarting:  # the last second, the kill and the death beat: nobody walks
		player.drive(walk, delta)
		partner.follow(player.global_position, PARTNER_STOP_DISTANCE, delta)
	update_camera(delta)
	update_prop_fade(delta)
	_grow_spares(delta)
	_update_reach(delta)
	var spots: Array[Vector2] = []
	for traveler in travelers.values():
		spots.append(Vector2(traveler.global_position.x, traveler.global_position.z))
	discovery.update(spots, delta)
	discovery_hud.refresh()
	basket_hud.refresh(delta)
	_tick_stuck(delta)


## False while restarting or once the travelers are dead (no one can pick).
func picks_allowed() -> bool:
	if restarting:
		return false
	for id in GameState.TRAVELERS:
		if not GameState.is_alive(id):
			return false
	return true


## Opens the spelling view for a discovered word and pauses the map. False if
## the word cannot be opened: restarting, a traveler is dead, the view is up
## already (or showing a failure), the word is done or not a target.
func open_spelling(id: String) -> bool:
	if spelling_hud.is_open() or not spelling.open(id, picks_allowed()):
		return false
	picking.cancel_walk()
	basket_hud.refresh(basket_hud.POP_TIME)  # tiles still popping in finish, as the map stops
	_tip_plant = null  # a hover name would stay frozen on screen
	_tooltip.visible = false
	spelling_hud.show_word(id)
	stuck_hud.refresh(countdown, true)  # the view covers the number
	get_tree().paused = true
	return true


func _on_spelling_changed() -> void:
	basket_hud.refresh(0.0)
	discovery_hud.refresh()


## The view went away (closed, finished, or the failure flash ended): play on.
func _on_spelling_closed() -> void:
	get_tree().paused = false
	_spawn_spares()
	var result: Dictionary = damage.settle()
	if result["failures"] > 0:
		_play_hits()
		if result["died"]:
			begin_death_beat()
	evaluate_stuck("spelling closed")  # after the spares and the damage have settled


## A syllable failed: the damage waits until the view has closed.
func _on_syllable_failed(_word_id: String, _block_index: int, _letters: Array) -> void:
	damage.queue_failure()
	spares.queue_failure()


## Placeholder gore on both travelers: a blood burst and a red flash, the
## second traveler's about gore.stagger seconds after the first.
func _play_hits() -> void:
	var delay := 0.0
	for id in GameState.TRAVELERS:
		if delay <= 0.0:
			_hit(id)
		else:
			get_tree().create_timer(delay).timeout.connect(_hit.bind(id))
		delay += float(gore["stagger"])


func _hit(id: String, strength: float = 1.0, tint_time: float = -1.0) -> void:
	var traveler: Node3D = travelers[id]
	traveler.flash(_gore_color("tint_color"), float(gore["tint_duration"]) if tint_time < 0.0 else tint_time)
	_blood(traveler.global_position + Vector3(0.0, Traveler.HEIGHT * 0.65, 0.0), strength)


func _gore_color(key: String) -> Color:
	var c: Array = gore[key]
	return Color(c[0], c[1], c[2])


## A short spray of dark red droplets at a world position; `strength` scales
## how many there are and how hard they fly (1 is the placeholder gore of 6b).
func _blood(at: Vector3, strength: float = 1.0) -> CPUParticles3D:
	var spray := CPUParticles3D.new()
	spray.name = "Blood"
	spray.one_shot = true
	spray.emitting = true
	spray.amount = roundi(40.0 * strength)
	spray.lifetime = float(gore["burst_duration"])
	spray.explosiveness = 0.9
	spray.direction = Vector3.UP
	spray.spread = 75.0
	spray.initial_velocity_min = 2.0 * sqrt(strength)
	spray.initial_velocity_max = 4.5 * sqrt(strength)
	spray.gravity = Vector3(0.0, -9.0, 0.0)
	var drop := SphereMesh.new()
	drop.radius = 0.07
	drop.height = 0.14
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = _gore_color("blood_color")
	drop.material = material
	spray.mesh = drop
	var cleanup := Timer.new()
	cleanup.wait_time = float(gore["burst_duration"]) * 2.0
	cleanup.one_shot = true
	cleanup.autostart = true
	cleanup.timeout.connect(spray.queue_free)
	spray.add_child(cleanup)
	add_child(spray)
	spray.global_position = at
	return spray


## Both travelers are dead: from now on nothing can be picked, walked to or
## opened, the screen dims, and when gore.death_beat seconds have passed the
## scene restarts. Does nothing if the beat is already playing.
func begin_death_beat() -> void:
	if _dim != null:  # the beat has begun (restarting may be set before, by the monster)
		return
	restarting = true
	_abandon_stuck()
	_beat_left = float(gore["death_beat"])
	picking.cancel_walk()
	var layer := CanvasLayer.new()
	layer.layer = 20
	_dim = ColorRect.new()
	_dim.color = Color(0.0, 0.0, 0.0, 0.0)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_dim)
	add_child(layer)
	death_beat_started.emit()


func is_death_beat_playing() -> bool:
	return _beat_left >= 0.0


## Advances the death beat (a no-op otherwise). Public so tests and the capture
## scene can drive it without waiting.
func tick_beat(delta: float) -> void:
	if _beat_left < 0.0:
		return
	_beat_left -= delta
	var total := maxf(float(gore["death_beat"]), 0.001)
	_dim.color.a = float(gore["death_dim_alpha"]) * clampf(1.0 - _beat_left / total, 0.0, 1.0)
	if _beat_left <= 0.0:
		_beat_left = -1.0
		_restart()


## The end of the beat: the hearts and DDEOK go back to what the scene began
## with, and the scene is reloaded, which clears the basket, the discovery list
## and the spelling progress. (A map that is not the current scene, as in the
## tests, only restores GameState and announces `restarted`.)
func _restart() -> void:
	_abandon_stuck()
	GameState.restart_scene()
	restarted.emit()
	if get_tree().current_scene == self:
		get_tree().reload_current_scene()


## A left click at a screen point. If it is on a plant that still has its
## letter, the player walks to it (a later click retargets). Uses the hover's
## plant_at(). Returns true if a walk started.
func click(screen_pos: Vector2) -> bool:
	if not picks_allowed():
		return false
	var plant := plant_at(screen_pos)
	return plant != null and picking.start_walk(plants.find(plant))


## Space: picks the nearest plant in reach that still has its letter, at once,
## and cancels any click-walk. Returns true if something was picked.
func pick_nearest() -> bool:
	picking.cancel_walk()
	if not picks_allowed():
		return false
	var index: int = picking.nearest_pickable(Vector2(player.global_position.x, player.global_position.z))
	if index < 0:
		return false
	pick_plant(plants[index])
	return true


## The player's reach: flashes the name of each plant it walks up to (the
## partner never does) and keeps the ring on the nearest pickable plant.
func _update_reach(delta: float) -> void:
	var spot := Vector2(player.global_position.x, player.global_position.z)
	var entered: Array[int] = picking.entered_reach(spot)
	if not entered.is_empty():
		_start_tooltip(plants[entered[entered.size() - 1]], false)
	_ring_time += delta
	var index: int = picking.nearest_pickable(spot)
	_ring.visible = index >= 0
	if index >= 0:
		var plant := plants[index]
		if plant != _ring_plant:
			_ring_plant = plant
			_ring.mesh = _ring_mesh(plant.global_position)
		_ring.global_position = plant.global_position
		_ring_material.albedo_color.a = picking.ring_alpha_at(_ring_time)


## The ring's mesh: an annulus of the same size for every plant, its height
## following the ground along x so a slope never hides part of it.
func _ring_mesh(centre: Vector3) -> ArrayMesh:
	var outer: float = picking.ring_radius()
	var inner := maxf(outer - picking.ring_width, 0.0)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in RING_SEGMENTS:
		var dir0 := Vector2.from_angle(TAU * i / RING_SEGMENTS)
		var dir1 := Vector2.from_angle(TAU * (i + 1) / RING_SEGMENTS)
		var quad: Array[Vector3] = []
		for c: Vector2 in [dir0 * inner, dir0 * outer, dir1 * outer, dir1 * inner]:
			quad.append(Vector3(c.x, terrain.height_at(centre.x + c.x) - centre.y + RING_LIFT, c.y))
		for index in [0, 1, 2, 0, 2, 3]:
			surface.add_vertex(quad[index])
	return surface.commit()


func _build_ring() -> void:
	_ring = MeshInstance3D.new()
	_ring.name = "ReachRing"
	_ring_material = StandardMaterial3D.new()
	_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_ring_material.albedo_color = Color(picking.ring_color, picking.ring_alpha)
	_ring.material_override = _ring_material
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.visible = false
	add_child(_ring)


## One tick of a click-to-walk: the direction to walk, and the pick on arrival.
func _walk_step(delta: float) -> Vector2:
	var plant := plants[picking.walk_target]
	var to := Vector2(plant.global_position.x - player.global_position.x, plant.global_position.z - player.global_position.z)
	match picking.walk_update(to.length(), delta):
		"arrived":
			pick_plant(plant)
		"walking":
			return to.normalized()
	return Vector2.ZERO


## Takes a plant's letter: a target's goes to the basket, a decoy's vanishes in
## steam. Does nothing if it is gone already or picks are not allowed.
func pick_plant(plant: Node3D) -> void:
	var result: Dictionary = picking.pick(plants.find(plant), picks_allowed())
	if result["result"] == "none":
		return
	var at: Vector3 = plant.letter_position()
	plant.take_letter()
	if result["result"] == "basket":
		basket_hud.refresh(0.0)
		evaluate_stuck("pick")
	else:
		_puff(at)
		_play_tsss()


## A one-shot puff of grey-white steam at a world position.
func _puff(at: Vector3) -> CPUParticles3D:
	var steam := CPUParticles3D.new()
	steam.one_shot = true
	steam.emitting = true
	steam.amount = 24
	steam.lifetime = picking.steam_duration
	steam.explosiveness = 0.6
	steam.direction = Vector3.UP
	steam.spread = 35.0
	steam.initial_velocity_min = 0.6
	steam.initial_velocity_max = 1.4
	steam.gravity = Vector3(0.0, 0.4, 0.0)  # steam rises
	steam.scale_amount_min = 1.0
	steam.scale_amount_max = 1.9
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0.9))
	fade.set_color(1, Color(1, 1, 1, 0.0))
	steam.color = picking.steam_color
	steam.color_ramp = fade
	var ball := SphereMesh.new()
	ball.radius = 0.22
	ball.height = 0.44
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	ball.material = material
	steam.mesh = ball
	var cleanup := Timer.new()  # frees the puff once its particles are gone
	cleanup.wait_time = picking.steam_duration * 2.0
	cleanup.one_shot = true
	cleanup.autostart = true
	cleanup.timeout.connect(steam.queue_free)
	steam.add_child(cleanup)
	add_child(steam)
	steam.global_position = at
	return steam


## The placeholder "tsss". Skipped when there is no audio output (headless).
func _play_tsss() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if _steam_stream == null:
		_steam_stream = SteamSound.make()
	var player_node := AudioStreamPlayer.new()
	player_node.stream = _steam_stream
	player_node.finished.connect(player_node.queue_free)
	add_child(player_node)
	player_node.play()


## The outer box a traveler's feet may stand in, over (x, z): the stage along x
## and at the far end, and the whole near apron toward the camera. How far toward
## the camera depends on x, see near_limit_at().
func walk_bounds() -> Rect2:
	var far := -stage_depth / 2.0 + TRAVELER_MARGIN
	return Rect2(Vector2(TRAVELER_MARGIN, far), Vector2(stage_width - 2.0 * TRAVELER_MARGIN, ground_rect.end.y - far))


## The z of the bottom edge of the screen at the player's column when the player
## stands at x and the camera has settled: the ground's near edge, pulled back by
## the camera's clamp (see _near_shift()).
func near_edge_at(x: float) -> float:
	var half_width := camera_half_width()
	var aim_x := _clamp_axis(x, ground_rect.position.x + half_width, ground_rect.end.x - half_width)
	return ground_rect.end.y - _near_shift(aim_x, terrain.height_at(x))


## The farthest toward the camera a traveler's feet may stand at x: the bottom
## edge of the screen less the data margin (walk_limit.near_margin).
func near_limit_at(x: float) -> float:
	return near_edge_at(x) - near_margin


## How far the camera must stop short of the ground's near edge. The screen's
## bottom row meets ground that is higher than the aim's further toward the camera
## (by the rise over tan(pitch)), so on a slope the view's bottom corner would
## otherwise run past the edge into the sky.
func _near_shift(aim_x: float, aim_height: float) -> float:
	var half_width := camera_half_width()
	var rise := 0.0
	for i in NEAR_SAMPLES + 1:
		var x := aim_x - half_width + 2.0 * half_width * i / NEAR_SAMPLES
		rise = maxf(rise, terrain.height_at(x) - aim_height)
	return rise / tan(deg_to_rad(CAMERA_PITCH_DEG))


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
	var height := player.global_position.y
	_aim_height = height if snap else lerpf(_aim_height, height, 1.0 - exp(-CAMERA_FOLLOW_RATE * delta))
	aim = clamp_aim(aim)
	camera.global_position = Vector3(aim.x, _aim_height + CAMERA_DISTANCE * sin(pitch), aim.y + CAMERA_DISTANCE * cos(pitch))


## The view must not pass the ground's left, right and near edges. The far
## end is open on purpose: the backdrop ridge stands against the sky there. Uses
## the camera's current aim height, so call it after updating that.
func clamp_aim(aim: Vector2) -> Vector2:
	var half := Vector2(camera_half_width(), camera_half_depth())
	var x := _clamp_axis(aim.x, ground_rect.position.x + half.x, ground_rect.end.x - half.x)
	return Vector2(x, _clamp_axis(aim.y, -INF, ground_rect.end.y - half.y - _near_shift(x, _aim_height)))


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
	for kind in plants_data["kinds"]:
		_kinds[kind["id"]] = kind
	for entry in plants_data["placed"]:
		var x := float(entry["x"])
		var z := float(entry["z"])
		_add_plant(_kinds[entry["kind"]], String(entry.get("letter", "")), x, z)
		keep_out.append(Vector2(x, z))


## One plant of a kind at (x, z), on the ground; also used for the spares.
func _add_plant(kind: Dictionary, letter: String, x: float, z: float) -> Node3D:
	var plant := Plant.new()
	plant.setup(kind, letter)
	plant.position = Vector3(x, terrain.height_at(x), z)
	$Plants.add_child(plant)
	plants.append(plant)
	return plant


## Every jamo the player can still get: the basket and the letters still on
## target plants (spares included, growing or not). Decoy letters vanish when
## picked, so they never count.
func _available_letters() -> Array:
	var letters: Array = picking.basket.duplicate()
	for plant in plants:
		if plant.kind == "target" and plant.letter != "":
			letters.append(plant.letter)
	return letters


## Settles the words completed and the syllables failed since the view last
## closed: credits are banked or spent on spares of their words' kinds at their
## slots (see Spares).
func _spawn_spares() -> void:
	if not spares.has_pending():
		return
	var solved := {}
	for id in spares.word_ids():
		solved[id] = spelling.solved(id).size()
	for order in spares.settle(solved, _available_letters()):
		var spot: Vector2 = order["spot"]
		var plant := _add_plant(_kinds[order["word_id"]], order["letter"], spot.x, spot.y)
		plant.scale = Vector3.ONE * GROW_MIN_SCALE
		var index: int = picking.add_plant(order["letter"], false, spot, true)
		spare_plants.append(plant)
		_growing.append({"plant": plant, "index": index, "left": spares.grow_seconds})


## Grows each new spare from nothing to full size, then lets it be picked.
func _grow_spares(delta: float) -> void:
	for grow in _growing.duplicate():
		grow["left"] = float(grow["left"]) - delta
		var t := clampf(1.0 - float(grow["left"]) / maxf(spares.grow_seconds, 0.001), 0.0, 1.0)
		var plant: Node3D = grow["plant"]
		plant.scale = Vector3.ONE * maxf(1.0 - (1.0 - t) * (1.0 - t), GROW_MIN_SCALE)
		if t >= 1.0:
			picking.unlock(int(grow["index"]))
			_growing.erase(grow)


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


## Drives the tooltip. `delta` is the time since the last call, so tests can use
## simulated time. A name appears when the mouse moves onto a plant (or the
## player walks into reach of one, see _start_tooltip), stays tooltip_steady_time
## seconds, then flickers (starting hidden) for tooltip_flicker_time seconds and
## is gone. The mouse brings it back only after it has left the plant and entered
## a plant again; moving straight from one plant onto another starts the new
## tooltip at once. Only one is up at a time: the latest trigger wins.
func update_hover(screen_pos: Vector2, delta: float = 0.0) -> void:
	if restarting:  # no names in the last second, the kill or the death beat
		_hover_plant = null
		_tip_plant = null
		_tooltip.visible = false
		return
	var plant := plant_at(screen_pos)
	if plant != _hover_plant:
		_hover_plant = plant
		if plant != null:
			_start_tooltip(plant, true)
		elif _tip_by_mouse:
			_tip_plant = null
	elif _tip_plant != null:
		_hover_time += delta
	var opacity := 0.0
	if _tip_plant != null:
		var flicker := _hover_time - tooltip_steady_time
		if flicker <= 0.0:
			opacity = 1.0
		elif flicker < tooltip_flicker_time:
			opacity = 1.0 if int(flicker * tooltip_flicker_rate) % 2 == 1 else 0.0
	_tooltip.visible = opacity > 0.0
	if not _tooltip.visible:
		return
	_tooltip.modulate.a = opacity
	_tooltip.reset_size()
	var anchor := screen_pos + TOOLTIP_OFFSET
	if not _tip_by_mouse:
		anchor = camera.unproject_position(_tip_plant.global_position + Vector3(0.0, WALK_UP_TIP_LIFT, 0.0)) + TOOLTIP_OFFSET
	var room := get_viewport().get_visible_rect().size - _tooltip.size
	_tooltip.position = anchor.clamp(Vector2.ZERO, room.max(Vector2.ZERO))


## Puts a plant's name up from the start of its timings, replacing any other.
func _start_tooltip(plant: Node3D, by_mouse: bool) -> void:
	_tip_plant = plant
	_tip_by_mouse = by_mouse
	_hover_time = 0.0
	_tooltip_label.text = plant.tooltip_text()
	if not by_mouse:  # shown now, not at the next update_hover
		_tooltip.visible = true
		_tooltip.modulate.a = 1.0


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


## Asks Stuck whether the scene can still be finished and feeds the verdict to the
## countdown. Called after a pick and after the spelling view has closed (when
## the spares and the damage have settled); waits while the view is open or
## spare events are unsettled. Logs the verdict and its reason. Returns the verdict.
func evaluate_stuck(event: String) -> Dictionary:
	if spelling_hud.is_open() or spares.has_pending():
		_log_stuck(event, stuck_verdict, "deferred, the view is open or spares are unsettled")
		return stuck_verdict
	var solved := {}
	for id in spares.word_ids():
		solved[id] = spelling.solved(id).size()
	stuck_verdict = Stuck.analyze(spares, solved, _available_letters())
	_log_stuck(event, stuck_verdict, "")
	match countdown.verdict(stuck_verdict["stuck"], picks_allowed()):
		"started":
			_start_music()
		"cancelled":
			_stop_music()
	stuck_hud.refresh(countdown, spelling_hud.is_open())
	return stuck_verdict


func _log_stuck(event: String, verdict: Dictionary, note: String) -> void:
	var reason: String = (note + ": " if note != "" else "") + String(verdict["reason"])
	stuck_log.append({"event": event, "stuck": verdict["stuck"], "reason": reason})
	if DisplayServer.get_name() != "headless":
		print("stuck check (%s): %s, %s" % [event, "STUCK" if verdict["stuck"] else "not stuck", reason])


## One tick of the countdown and the kill. The clock stands still while the
## spelling view is open. In its last lockout seconds `restarting` is set (the
## one place besides begin_death_beat), so picks, walks, hover names and the
## spelling view are rejected through the checks that flag already has.
func _tick_stuck(delta: float) -> void:
	countdown.paused = spelling_hud.is_open()
	if countdown.tick(delta):
		_begin_monster()  # the kill's clock starts at the next tick, not with what is left of this one
	else:
		if countdown.is_locked() and not restarting:
			restarting = true
			picking.cancel_walk()
		_tick_monster(delta)
	stuck_hud.refresh(countdown, spelling_hud.is_open())


## The countdown reached 0: stop the music, bring in the deer and start the kill.
func _begin_monster() -> void:
	if kill != null:
		return
	restarting = true
	picking.cancel_walk()
	_stop_music()
	kill = KillTimeline.new(monster)
	kill.start()
	for id in GameState.TRAVELERS:
		kill_order.append(id)
	kill_order.sort_custom(func(a: String, b: String) -> bool: return travelers[a].global_position.x < travelers[b].global_position.x)
	var first := _deer_landing(kill_order[0])
	_deer_start = Vector3(camera.global_position.x - camera_half_width() - float(monster["enter_margin"]), 0.0, first.z)
	_deer_start.y = terrain.height_at(_deer_start.x)
	deer = Deer.new()
	deer.setup(monster)
	add_child(deer)
	_place_deer()


## The deer's spot beside a traveler: `standoff` metres toward the side it came from.
func _deer_landing(id: String) -> Vector3:
	var spot: Vector3 = travelers[id].global_position + Vector3(-float(monster["standoff"]), 0.0, 0.0)
	spot.y = terrain.height_at(spot.x)
	return spot


## Puts the deer where the kill timeline says: a leap from just off the left edge
## of the screen onto the first traveler, then a hop to the second.
func _place_deer() -> void:
	var first := _deer_landing(kill_order[0])
	var arc := float(monster["arc_height"])
	var from := _deer_start
	var to := first
	var progress: float = kill.leap_progress()
	var lift := 4.0 * progress * (1.0 - progress) * arc
	if kill.time >= kill.hit_time(0):
		from = first
		to = _deer_landing(kill_order[1])
		progress = kill.gap_progress()
		lift = 4.0 * progress * (1.0 - progress) * arc * 0.5
	deer.global_position = from.lerp(to, progress) + Vector3(0.0, lift, 0.0)
	var heading := to - from
	deer.rotation.y = atan2(-heading.x, -heading.z)


func _tick_monster(delta: float) -> void:
	if kill == null:
		return
	for event in kill.tick(delta):
		match event:
			"hit_0":
				_monster_hit(0)
			"hit_1":
				_monster_hit(1)
			"done":
				begin_death_beat()
	_place_deer()


## The deer hits one traveler: a big blood burst, a red flash, the traveler thrown
## away and tipped over, and every heart gone (the first hit already kills both,
## by the both-die rule; the second traveler is brought down with it, in order).
func _monster_hit(index: int) -> void:
	var id := kill_order[index]
	var traveler: Node3D = travelers[id]
	var away: Vector3 = traveler.global_position - deer.global_position
	away.y = 0.0
	away = away.normalized() if away.length() > 0.001 else Vector3.RIGHT
	_hit(id, float(monster["burst_strength"]), float(monster["tint_seconds"]))
	var toss: Vector3 = away * float(monster["knock_distance"])
	# It lands on the ground where it stops, lying on its side (a body's radius up).
	toss.y = terrain.height_at(traveler.global_position.x + toss.x) + Traveler.RADIUS - traveler.global_position.y
	traveler.knock_down(toss, float(monster["knock_seconds"]), float(monster["knock_tilt_degrees"]))
	GameState.damage_units(id, GameState.max_units(), "monster")


## The scene is dying or restarting: no countdown, no vignette, no music.
func _abandon_stuck() -> void:
	countdown.abandon()
	_stop_music()
	stuck_hud.refresh(countdown, spelling_hud.is_open())


## Starts the placeholder music: at stuck_music.volume_db, faded in over
## fade_seconds. The stream (a looping AudioStreamWAV) is built on first use. The
## calls to the audio player are skipped headless; the counters still count.
func _start_music() -> void:
	if music_playing:
		return
	music_playing = true
	music_starts += 1
	if DisplayServer.get_name() == "headless":
		return
	if _music_stream == null:
		_music_stream = StuckMusic.make(music_config)
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = _music_stream
	_music_player.volume_db = -80.0
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS  # it plays under the spelling view
	add_child(_music_player)
	_music_player.play()
	_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_property(_music_player, "volume_db", float(music_config["volume_db"]), float(music_config["fade_seconds"]))
	audio_calls += 1


func _stop_music() -> void:
	if not music_playing:
		return
	music_playing = false
	music_stops += 1
	if _music_player == null:
		return
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_player.stop()
	_music_player.queue_free()
	_music_player = null
	audio_calls += 1
