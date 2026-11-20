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
const Picking := preload("res://scenes/foraging/picking.gd")
const DiscoveryHud := preload("res://scenes/foraging/discovery_hud.gd")
const BasketHud := preload("res://scenes/foraging/basket_hud.gd")
const Spelling := preload("res://scenes/foraging/spelling.gd")
const SpellingHud := preload("res://scenes/foraging/spelling_hud.gd")
const Damage := preload("res://scenes/foraging/damage.gd")
const HitFx := preload("res://scenes/foraging/hit_fx.gd")
const ReachRing := preload("res://scenes/foraging/reach_ring.gd")
const DecoyPlacement := preload("res://scenes/foraging/decoy_placement.gd")
const Needs := preload("res://scenes/animals/needs.gd")
const LetterSupply := preload("res://scenes/animals/letter_supply.gd")
const Grab := preload("res://scenes/animals/grab.gd")
const NeedRewards := preload("res://scenes/animals/need_rewards.gd")
const HealPickups := preload("res://scenes/animals/heal_pickups.gd")
const HealPickup := preload("res://scenes/animals/heal_pickup.gd")
const FloatLabel := preload("res://scenes/foraging/float_label.gd")
const Revive := preload("res://scenes/foraging/revive.gd")
const ReviveView := preload("res://scenes/foraging/revive_view.gd")
const Bear := preload("res://scenes/animals/bear.gd")
const CountdownMusic := preload("res://scenes/foraging/countdown_music.gd")
const DownedCountdown := preload("res://scenes/foraging/downed_countdown.gd")
const StuckHud := preload("res://scenes/foraging/stuck_hud.gd")
const ThoughtBubble := preload("res://scenes/animals/thought_bubble.gd")
const NeedPicture := preload("res://scenes/animals/need_picture.gd")
const Guide := preload("res://scenes/animals/guide.gd")
const GuideHud := preload("res://scenes/animals/guide_hud.gd")
const ToolUse := preload("res://scenes/animals/tool_use.gd")
const ToolPickups := preload("res://scenes/animals/tool_pickups.gd")
const ToolPickup := preload("res://scenes/animals/tool_pickup.gd")
const ToolHud := preload("res://scenes/animals/tool_hud.gd")
const HintLetters := preload("res://scenes/animals/hint_letters.gd")
const HintLetterHud := preload("res://scenes/animals/hint_letter_hud.gd")
const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

## A bare-hand grab hurts (and is made by) the traveler being controlled: Fernanda until she is
## downed, then Nestor (Prompt 9b-iv).
## Salts of the seeds derived from the crossing seed (the crossing's own draws are untouched).
const SALT_LETTERS := 1
const SALT_GRAB := 2
const SALT_NEEDS := 3
const SALT_PICKUPS := 4
const SALT_REWARDS := 5
const SALT_TOOLS := 6          # where the tools lie (Prompt 9c)
const SALT_TOOL_REWARDS := 7   # the tool a met need drops

const GROUND_STEP := 1.0   # metres between ground mesh vertices along x

## Set by tests (and nothing else) before a scene is built: >= 0 fixes the crossing seed
## (a --seed=N user argument does the same when this is -1).
static var seed_override := -1
## Set by tests only: false leaves the tools out of the scene (no starting skewer, no tool
## pickups, no tool rewards), as before Prompt 9c.
static var tools_enabled := true
## Set by tests only: false stops the hint letters from ever opening (the clock never runs), as
## before Prompt 9c-iii; the long-running older sections would otherwise be paused by one.
static var hints_enabled := true

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
## Prompt 9b. The basket (a foraging Picking: one slot per hand-grabbable animal, its spot
## following the animal), the needs and their discovery list, the spelling view, the
## damage of a failed syllable, the seeded letter supply and grab roll.
var picking
var basket_hud: CanvasLayer
var needs
var discovery_hud: CanvasLayer
var spelling
var spelling_hud: CanvasLayer
var damage
var supply
var grab_rng := RandomNumberGenerator.new()
var gore: Dictionary = {}
var complete_hud: CanvasLayer
## Picking slot -> Walker, and the reverse.
var slot_walker: Dictionary = {}
var walker_slot: Dictionary = {}
## Prompt 9b-ii. The healing bottles: Picking pile index -> the item id and the node; the
## roll of what meeting a need drops; the picture thought bubbles over the animals (Prompt
## 9b-iii; need id -> bubble); the one-time guide prompts; the style of the floating "+1 ..."
## label and how high it starts over the traveler.
var pickup_items: Dictionary = {}
var pickup_nodes: Dictionary = {}
var reward_rng := RandomNumberGenerator.new()
var bubbles: Dictionary = {}
var guide
var guide_hud: CanvasLayer
var float_label_config: Dictionary = {}
## Prompt 9c-iii. The hint letters: the idle clock and the picks (a HintLetters), how a letter is
## drawn (a HintLetterHud), and the foraging ending config the paper floats in with.
var hint
var hint_hud: CanvasLayer
var hint_ending: Dictionary = {}
## Prompt 9c. The tool HUD (bottom left), the roll of the tool a met need drops, the tool grab
## in its wind-up ({} when none: {walker, left, def}) and how the last one ended.
var tool_hud: CanvasLayer
var tool_rng := RandomNumberGenerator.new()
var tool_pending: Dictionary = {}
var last_tool_result: Dictionary = {}
## Prompt 9b-iv. Downed travelers and reviving them (shared with foraging): the logic, how it
## is drawn, and rules.json `revive`.
var revive
var revive_view: Node3D
var revive_config: Dictionary = {}
## Prompt 9c-ii. The downed countdown (a DownedCountdown, shown by the foraging stuck HUD and
## its music), the giant bear it sends at 0, and `hunt_lock`: set from the countdown's last
## second until the death beat, when inputs are locked (`restarting`) but the animals go on.
var downed_countdown
var stuck_hud: CanvasLayer
var bear: Node3D
var hunt_lock := false
var float_label_height := 2.3
var _music: Node  # CountdownMusic
var _bubble_layer: CanvasLayer
var _pickup_time := 0.0
## From the moment both travelers die until the scene restarts: no grabs, walks or menus.
var restarting := false

## Restart scene was chosen: the scene-start snapshot is back (the scene then reloads).
signal restarted
## The last of the needs is finished (emitted once).
signal needs_complete
## A need joined the discovery list (its id).
signal need_discovered(id: String)
## A tool grab ended: {"result": "hit" | "miss", "letter"}.
signal tool_grab_done(result: Dictionary)

var _aim_height := 0.0
var _beat_left := -1.0
var _dim: ColorRect
var _ring: MeshInstance3D
var _ring_material: StandardMaterial3D
var _ring_time := 0.0

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
	_give_start_tools()
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
	backpack_hud.set_tools(GameState.tools)
	backpack_hud.open_handler = open_backpack
	backpack_hud.notebook_open_handler = open_notebook
	backpack_hud.close_requested.connect(close_backpack)
	crossing = Crossing.new(config, crossing_seed)
	_build_needs(ui)
	tool_hud = ToolHud.new()
	add_child(tool_hud)
	tool_hud.setup(GameState.tools, config["tools"])
	revive_config = Content.rules["revive"]
	revive = Revive.new(revive_config)
	revive_view = ReviveView.new()
	add_child(revive_view)
	revive_view.setup(revive_config)
	GameState.traveler_downed.connect(_on_traveler_downed)
	_music = CountdownMusic.new()
	add_child(_music)
	_music.setup(ui["stuck_music"])
	downed_countdown = DownedCountdown.new(revive_config, ui["stuck"])
	stuck_hud = StuckHud.new()
	add_child(stuck_hud)
	stuck_hud.setup(ui["stuck"])
	bear = Bear.new()
	add_child(bear)
	bear.setup(config["bear"], view_rect, terrain.height_at, float(cam["pitch_deg"]))
	_sync_downed()  # the hearts may already hold a downed traveler (a pending bank)
	update_camera(0.0, true)


func _exit_tree() -> void:
	if GameState.traveler_downed.is_connected(_on_traveler_downed):
		GameState.traveler_downed.disconnect(_on_traveler_downed)
	if (pause_menu != null and pause_menu.is_open) or (backpack != null and backpack.is_open) or (spelling_hud != null and spelling_hud.is_open()) or (hint_hud != null and hint_hud.is_open()):  # never leave the tree paused behind
		get_tree().paused = false


func _process(delta: float) -> void:
	tick_beat(delta)


func _physics_process(delta: float) -> void:
	step(Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down"), delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		open_pause_menu()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click(event.position)
	elif event.is_action_pressed("p1_pick"):  # no echo: holding Space grabs once
		pick_nearest()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tool_next"):
		cycle_tool()
		get_viewport().set_input_as_handled()


## One tick of the map. Public so tests can drive it without a keyboard. While the pause
## menu or the backpack is open nobody walks and no animal moves.
func step(input: Vector2, delta: float) -> void:
	var walk := input
	if discovery_hud.word_select.is_open():
		if picks_allowed():
			walk = Vector2.ZERO  # the movement keys only move the highlight
			picking.cancel_walk()
		else:
			discovery_hud.close_word_select()  # a death or a menu took over
	if not input.is_zero_approx() or not picks_allowed():
		picking.cancel_walk()  # the keys take over
	elif picking.is_walking():
		walk = _walk_step(delta)
	var menus_closed: bool = not pause_menu.is_open and not backpack.is_open and not hint_hud.is_open()
	var running: bool = not restarting and menus_closed
	if running:
		if not discovery_hud.word_select.is_open():
			if not GameState.is_downed(GameState.controlled):
				player.drive(walk, delta)
			if not GameState.is_downed(GameState.partner_of(GameState.controlled)):
				partner.follow(player.global_position, float(config["partner_stop_distance"]), delta)
		_tick_revive(delta)
		_tick_tool(delta)
		for t in travelers.values():
			_push_out_of_lake(t)
	if menus_closed and (not restarting or hunt_lock):  # the animals go on while the bear runs
		_tick_animals(delta)
		_watch_animals(delta)
	_tick_downed(delta)
	_sync_downed()
	update_camera(delta)
	props.set_travelers(player.global_position, partner.global_position, float(config["camera"]["pitch_deg"]))
	_update_reach(delta)
	revive_view.refresh(revive, GameState.controlled, _world_positions(), terrain.height_at)
	needs.update(delta)
	_update_bubbles(delta)
	_update_guide(delta)
	_update_hint(delta)
	_update_pickups(delta)
	discovery_hud.set_header(needs.counter_text())
	discovery_hud.refresh()
	basket_hud.refresh(delta)


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
	crossing.view = view_rect()
	crossing.met = needs.done.size()
	for event in crossing.tick(delta):
		if event["event"] == Crossing.SPAWN:
			_add_animal(event["walker"])
		else:
			_remove_animal(event["walker"])
	for walker in animal_nodes:
		_pose(walker)
		if walker_slot.has(walker):
			picking.set_spot(walker_slot[walker], walker.position())


func _add_animal(walker) -> void:
	var node := Animal.new()
	node.setup(walker.kind, config["label"], config["letters"]["tile"], config["watch"]["ring"])
	$Animals.add_child(node)
	animal_nodes[walker] = node
	var by_hand: bool = Grab.by_hand(walker.kind)
	walker.letter = supply.draw(by_hand, needs.missing_letters(spelling, picking.basket))
	node.set_letter(walker.letter)
	if by_hand:  # its letter is a slot of the basket's Picking, following the animal
		var slot: int = picking.add_plant(walker.letter, false, walker.position())
		walker_slot[walker] = slot
		slot_walker[slot] = walker
	_pose(walker)


func _remove_animal(walker) -> void:
	if walker_slot.has(walker):  # the letter leaves with it: it is back in the pool
		var slot: int = walker_slot[walker]
		picking.discard_letter(slot)
		if picking.walk_target == slot:
			picking.cancel_walk()
		slot_walker.erase(slot)
		walker_slot.erase(walker)
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


# ---- Letters, grabs, needs (Prompt 9b) ----

## The basket, the discovery list, the spelling view and the rest, all the foraging scene's
## own scripts, configured from the section `ui_from` names; plus the animals' own logic.
func _build_needs(ui: Dictionary) -> void:
	gore = ui["gore_placeholder"]
	picking = Picking.new(ui["picking"], {"kinds": [], "placed": []}, ui["reach_ring"])
	picking.pick_radius = float(config["grab_radius"])
	needs = Needs.new(config, DecoyPlacement.derive_seed(crossing_seed, SALT_NEEDS), func(id: String) -> bool: return GameState.inventory.count(id) > 0)
	var review := LetterSupply.need_weights(config["kinds"], config["needs"]["table"], config["letters"]["set"])
	supply = LetterSupply.new(config["letters"], DecoyPlacement.derive_seed(crossing_seed, SALT_LETTERS), review)
	reward_rng.seed = DecoyPlacement.derive_seed(crossing_seed, SALT_REWARDS)
	tool_rng.seed = DecoyPlacement.derive_seed(crossing_seed, SALT_TOOL_REWARDS)
	float_label_config = ui["decoy_rewards"]["floating_label"]
	float_label_height = float(ui["word_rewards"]["label_height"])
	grab_rng.seed = DecoyPlacement.derive_seed(crossing_seed, SALT_GRAB)
	spelling = Spelling.new(ui["spelling_view"], {"kinds": []}, picking.basket)
	discovery_hud = DiscoveryHud.new()
	add_child(discovery_hud)
	discovery_hud.setup(needs, spelling)
	discovery_hud.set_header(needs.counter_text())
	discovery_hud.entry_pressed.connect(open_spelling)
	discovery_hud.picture_maker = _list_picture
	discovery_hud.open_gate = _word_select_allowed
	basket_hud = BasketHud.new()
	add_child(basket_hud)
	basket_hud.setup(picking, ui["basket_hud"])
	spelling_hud = SpellingHud.new()
	add_child(spelling_hud)
	spelling_hud.setup(spelling, basket_hud, ui["keyboard_select"])
	spelling_hud.changed.connect(_on_spelling_changed)
	spelling_hud.closed.connect(_on_spelling_closed)
	damage = Damage.new(ui["damage"])
	spelling.syllable_failed.connect(_on_syllable_failed)
	spelling.word_completed.connect(_on_word_completed)
	var made: Array = ReachRing.make(picking)
	_ring = made[0]
	_ring_material = made[1]
	add_child(_ring)
	complete_hud = CanvasLayer.new()
	complete_hud.name = "NeedsCompleteHud"
	complete_hud.layer = 7
	complete_hud.visible = false
	var line := Label.new()
	line.name = "Line"
	line.text = String(config["needs"]["complete_text"])
	line.add_theme_font_override("font", FONT)
	line.add_theme_font_size_override("font_size", 44)
	line.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	line.offset_top = 12.0
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	complete_hud.add_child(line)
	add_child(complete_hud)
	_bubble_layer = CanvasLayer.new()
	_bubble_layer.name = "BubbleLayer"
	_bubble_layer.layer = 10
	add_child(_bubble_layer)
	guide = Guide.new(config["guide"], GameState.guide_seen)
	guide_hud = GuideHud.new()
	add_child(guide_hud)
	guide_hud.setup(guide, config["guide"])
	hint = HintLetters.new(config["hint_letters"])
	hint_ending = ui["ending"]
	hint_hud = HintLetterHud.new()
	add_child(hint_hud)
	hint_hud.setup(config["hint_letters"], hint_ending, self)
	hint_hud.closed.connect(_on_hint_closed)
	_build_pickups()


## False while restarting, while a menu or the backpack is open, or when the traveler being
## controlled is downed (a downed one cannot pick, grab, spell or open the backpack).
func picks_allowed() -> bool:
	if restarting or pause_menu.is_open or backpack.is_open or hint_hud.is_open():
		return false
	return not GameState.is_downed(GameState.controlled)


## True if E may open word selection now (nothing is paused or open over the map).
func _word_select_allowed() -> bool:
	return not get_tree().paused and not spelling_hud.is_open() and not pause_menu.is_open \
			and not backpack.is_open and picks_allowed() and _dim == null


## A traveler within the watch radius of an animal long enough shows one of its needs.
func _watch_animals(delta: float) -> void:
	var spots: Array = []
	for id in travelers:
		if not GameState.is_downed(id):  # animals take no notice of a downed traveler
			spots.append(Vector2(travelers[id].global_position.x, travelers[id].global_position.z))
	var seen: Array = []
	for walker in crossing.alive:
		seen.append({"id": walker.id, "kind": String(walker.kind["id"]), "spot": walker.position()})
	for entry in needs.watch(spots, seen, delta):
		_on_need_discovered(entry)
	for walker in animal_nodes:
		animal_nodes[walker].set_watch(needs.progress_of(walker.id))


## A need joined the list: its word goes into the spelling with its English (as foraging's
## words do), a picture bubble pops over the animal, and the guide may speak.
func _on_need_discovered(entry: Dictionary) -> void:
	spelling.add_word(String(entry["id"]), String(entry["name_ko"]), String(entry["hover_name"]))
	_start_bubble(entry)
	guide.trigger("grab")
	discovery_hud.refresh()
	need_discovered.emit(String(entry["id"]))


## The small picture at the left of a need's entry in the discovery list (or null).
func _list_picture(entry: Dictionary) -> Control:
	var picture_id: String = needs.picture_of(String(entry["id"]))
	if not NeedPicture.is_known(picture_id):
		return null
	var picture := NeedPicture.new()
	picture.setup(picture_id, float(config["needs"]["list_picture_px"]))
	return picture


## The thought bubble of a new need hangs over the animal that showed it (ThoughtBubble).
func _start_bubble(entry: Dictionary) -> void:
	var id := String(entry["id"])
	var picture_id: String = needs.picture_of(id)
	if not NeedPicture.is_known(picture_id):
		return
	var bubble := ThoughtBubble.new()
	bubble.setup(config["bubble"], id, int(entry["walker"]), picture_id)
	_bubble_layer.add_child(bubble)
	bubbles[id] = bubble
	_place_bubble(bubble)


func _walker_by_id(walker_id: int):
	for walker in animal_nodes:
		if walker.id == walker_id:
			return walker
	return null


## Ages every bubble (the map is running: the same clock as the animals) and keeps it over
## its animal. It goes when its time is up or its animal has left the map.
func _update_bubbles(delta: float) -> void:
	for id in bubbles.keys():
		var bubble: Control = bubbles[id]
		bubble.advance(delta)
		if bubble.expired() or _walker_by_id(bubble.walker_id) == null:
			bubble.queue_free()
			bubbles.erase(id)
			continue
		_place_bubble(bubble)


## Hangs a bubble from a point above its animal's name label (it may be off screen: it then
## simply is, as the animal is).
func _place_bubble(bubble: Control) -> void:
	var walker = _walker_by_id(bubble.walker_id)
	if walker == null:
		return
	var node: Node3D = animal_nodes[walker]
	var up := float(walker.kind["size"][1]) + float(config["label"]["lift"]) + float(config["bubble"]["lift_m"])
	bubble.hang_from(camera.unproject_position(node.global_position + Vector3(0.0, up, 0.0)))


## The guide: its clock runs with the map; "spell" fires the first time the basket holds every
## letter of an unfinished word need, "give" the first time an unfinished item need's item is
## in the backpack.
func _update_guide(delta: float) -> void:
	if not guide.has_seen("spell"):
		for entry in needs.entries:
			if needs.word_ready(spelling, String(entry["id"]), picking.basket):
				guide.trigger("spell")
				break
	if not guide.has_seen("give"):
		for entry in needs.entries:
			if entry["kind"] == Needs.ITEM and not spelling.is_done(String(entry["id"])) and GameState.inventory.count(String(entry["item"])) > 0:
				guide.trigger("give")
				break
	guide.update(delta)
	guide_hud.refresh()


## A discovery-list entry was chosen (click or E): a word opens the spelling view and pauses
## the map; an item is handed over if the backpack holds it. False if nothing happened.
func open_spelling(id: String) -> bool:
	discovery_hud.close_word_select()  # a click or a confirm both end keyboard selection
	if needs.is_item(id):
		return give_item(id)
	if spelling_hud.is_open() or hint_hud.is_open() or not spelling.open(id, picks_allowed()):
		return false
	picking.cancel_walk()
	basket_hud.refresh(basket_hud.POP_TIME)  # tiles still popping in finish, as the map stops
	spelling_hud.show_word(id)
	get_tree().paused = true
	return true


## Hands over the item of an item need: one is removed from the backpack and the need is
## finished, through the spelling's own completion. Nothing happens without the item.
func give_item(id: String) -> bool:
	if not picks_allowed() or spelling_hud.is_open() or not needs.is_item(id) or spelling.is_done(id):
		return false
	var item := String(needs.entry_of(id)["item"])
	if GameState.inventory.count(item) < 1 or not GameState.inventory.remove(item):
		return false
	spelling.complete_word(id)
	return true


func _on_spelling_changed() -> void:
	basket_hud.refresh(0.0)
	discovery_hud.refresh()


## The view went away (closed, finished, or the failure flash ended): play on, and settle
## what the failed syllables cost, as the foraging scene does.
func _on_spelling_closed() -> void:
	get_tree().paused = false
	var result: Dictionary = damage.settle()
	if result["failures"] > 0:
		_play_hits()
		if result["died"]:
			begin_death_beat()


func _on_syllable_failed(_word_id: String, _block_index: int, _letters: Array) -> void:
	damage.queue_failure()


## A word need was finished (spelled, or an item handed over).
func _on_word_completed(id: String) -> void:
	discovery_hud.refresh()
	var met_before: int = needs.done.size()
	var last: bool = needs.mark_done(id)
	if needs.done.size() > met_before:
		_reward_need(id)
	discovery_hud.set_header(needs.counter_text())
	if last:
		complete_hud.visible = true
		needs_complete.emit()


## Meeting a need rolls the reward of the tier of the kind it was shown by; what is won goes
## into the backpack, each with a floating "+1 쌍화탕" over the traveler. Returns the items.
func _reward_need(id: String) -> Array[String]:
	var entry: Dictionary = needs.entry_of(id)
	var tier := ""
	for kind in config["kinds"]:
		if kind["id"] == entry["from_kind"]:
			tier = String(kind["tier"])
	var won := NeedRewards.roll(config["need_rewards"], tier, reward_rng)
	var given: Array[String] = []
	for item_id in won:
		if GameState.inventory.add(item_id):
			var at: Vector3 = player.global_position + Vector3(0.0, float_label_height + 0.5 * given.size(), 0.0)
			FloatLabel.make(self, "+1 %s" % String(Content.item(item_id)["name_ko"]), at, float_label_config)
			given.append(item_id)
	if tools_enabled:  # Prompt 9c: one more roll, for a tool (its own rng, so the rolls above are untouched)
		var tool_id := NeedRewards.roll_tool(config["tool_rewards"], tier, config["tool_pickups"]["weights"], tool_rng)
		if tool_id != "" and GameState.tools.add(tool_id) > 0:
			var tool_at: Vector3 = player.global_position + Vector3(0.0, float_label_height + 0.5 * given.size(), 0.0)
			FloatLabel.make(self, "+1 %s" % String(Content.item(tool_id)["name_ko"]), tool_at, float_label_config)
			given.append(tool_id)
	return given


## A red flash and blood on both travelers (the second a moment later).
func _play_hits() -> void:
	HitFx.play_hits(self, GameState.TRAVELERS, gore, _hit_traveler)


func _hit_traveler(id: String) -> void:
	HitFx.hit(self, travelers[id], gore)


## Both travelers are dead: the screen dims and the scene restarts when the beat ends.
func begin_death_beat() -> void:
	if _dim != null:
		return
	restarting = true
	hunt_lock = false
	_abandon_downed()
	picking.cancel_walk()
	tool_pending = {}
	_beat_left = float(gore["death_beat"])
	_dim = HitFx.make_dim(self)


func is_death_beat_playing() -> bool:
	return _beat_left >= 0.0


## Advances the death beat (a no-op otherwise); public so tests can drive it.
func tick_beat(delta: float) -> void:
	if _beat_left < 0.0:
		return
	_beat_left -= delta
	_dim.color.a = HitFx.dim_alpha(gore, _beat_left)
	if _beat_left <= 0.0:
		_beat_left = -1.0
		_restart()


## A left click at a screen point: if it is on an animal a hand can grab, the player walks
## after it and grabs it on arrival. True if a walk started.
func click(screen_pos: Vector2) -> bool:
	if not picks_allowed():
		return false
	if not equipped_tool_def().is_empty():  # a tool fires at once at an animal already in reach
		var target = animal_at(screen_pos, true)
		return target != null and not grab_with_tool(target).is_empty()
	var walker = animal_at(screen_pos)
	if walker != null:
		return picking.start_walk(walker_slot[walker])
	var pile := pickup_at(screen_pos)
	return pile >= 0 and picking.start_walk_pile(pile)


## The grabbable animal (that still has its letter) under a screen point, or null (with
## `any_letter`, every animal that still has its letter, flyers and ducks too): the ray
## against the animal's box, grown by grab.click_pad_m and up over its letter tile.
func animal_at(screen_pos: Vector2, any_letter := false):
	var origin := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)
	var pad := float(config["grab"]["click_pad_m"])
	var tile: Dictionary = config["letters"]["tile"]
	var best = null
	var best_distance := INF
	for walker in animal_nodes:
		if any_letter:  # a tool takes any animal that still carries its letter
			if walker.letter == "":
				continue
		elif not walker_slot.has(walker) or not picking.is_pickable(walker_slot[walker]):
			continue
		var size: Array = walker.kind["size"]
		var half := maxf(float(size[0]), float(size[2])) / 2.0 + pad
		var height := float(size[1]) + float(tile["lift"]) + float(tile["size"]) / 2.0 + pad
		var base: Vector3 = animal_nodes[walker].global_position
		var hit = AABB(base + Vector3(-half, -pad, -half), Vector3(2.0 * half, height + pad, 2.0 * half)).intersects_ray(origin, direction)
		if hit != null and origin.distance_to(hit) < best_distance:
			best_distance = origin.distance_to(hit)
			best = walker
	return best


## The healing bottle (a Picking pile index) under a screen point, or -1: the ray against
## a box round the bottle, grown by grab.click_pad_m.
func pickup_at(screen_pos: Vector2) -> int:
	var origin := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)
	var pad := float(config["grab"]["click_pad_m"])
	var look: Dictionary = config["heal_pickups"]["look"]
	var best := -1
	var best_distance := INF
	for index in pickup_nodes:
		if not picking.is_pile_pickable(index):
			continue
		var half := float(look["radius"]) + pad
		var height := float(look["lift"]) + float(look["height"]) + pad
		var base: Vector3 = pickup_nodes[index].global_position
		var hit = AABB(base + Vector3(-half, -pad, -half), Vector3(2.0 * half, height + pad, 2.0 * half)).intersects_ray(origin, direction)
		if hit != null and origin.distance_to(hit) < best_distance:
			best_distance = origin.distance_to(hit)
			best = int(index)
	return best


## Space: takes what is nearest within reach at once (an animal's letter, or a healing
## bottle), and drops any click-walk. True if something was taken.
func pick_nearest() -> bool:
	picking.cancel_walk()
	if not picks_allowed():
		return false
	if press_revive() != "none":  # a downed traveler in range comes first
		return true
	if not equipped_tool_def().is_empty():  # a tool in hand: a pickup under it first, else the tool grab
		var near_pile: int = picking.nearest_pile(_flat_of(player))
		if near_pile >= 0:
			return not collect_pickup(near_pile).is_empty()
		return not grab_with_tool().is_empty()
	var target: Dictionary = picking.nearest_target(Vector2(player.global_position.x, player.global_position.z))
	if target["type"] == "pile":
		return not collect_pickup(int(target["index"])).is_empty()
	if target["type"] != "plant":
		return false
	var walker = slot_walker.get(int(target["index"]))
	return walker != null and not grab_animal(walker).is_empty()


## The scene's healing bottles (Prompt 9b-ii): seeded places, a node each, a Picking pile each.
func _build_pickups() -> void:
	var cfg: Dictionary = config["heal_pickups"]
	var holder := Node3D.new()
	holder.name = "Pickups"
	add_child(holder)
	var starts: Array = []
	for id in config["start"]:
		starts.append(Vector2(float(config["start"][id][0]), float(config["start"][id][1])))
	var placed := HealPickups.place(cfg, DecoyPlacement.derive_seed(crossing_seed, SALT_PICKUPS), walk_bounds(), lake_center, lake_radius, float(config["lake"]["clearance_m"]), starts)
	for entry in placed:
		var spot: Vector2 = entry["spot"]
		var node := HealPickup.new()
		node.setup(Content.item(String(entry["item"])), cfg["look"], float(pickup_nodes.size()) * 1.7)
		holder.add_child(node)
		node.global_position = Vector3(spot.x, terrain.height_at(spot.x), spot.y)
		var index: int = picking.add_pile(spot, 1)
		pickup_items[index] = String(entry["item"])
		pickup_nodes[index] = node
	if tools_enabled:
		_build_tool_pickups(starts, placed)


## The tools lying on the map (Prompt 9c): the 등산스틱 spot and the seeded rolls, each a
## node and a pile of the basket's picking like a bottle, apart from the bottles' holder.
func _build_tool_pickups(starts: Array, bottles: Array[Dictionary]) -> void:
	var cfg: Dictionary = config["tool_pickups"]
	var holder := Node3D.new()
	holder.name = "ToolPickups"
	add_child(holder)
	var avoid: Array = []
	for entry in bottles:
		avoid.append(entry["spot"])
	var placed := ToolPickups.place(cfg, DecoyPlacement.derive_seed(crossing_seed, SALT_TOOLS), walk_bounds(), lake_center, lake_radius, float(config["lake"]["clearance_m"]), starts, avoid)
	for entry in placed:
		var spot: Vector2 = entry["spot"]
		var node := ToolPickup.new()
		node.setup(Content.item(String(entry["item"])), cfg["look"], float(pickup_nodes.size()) * 1.7, bool(entry["pole"]), cfg["pole_spot"])
		holder.add_child(node)
		node.global_position = Vector3(spot.x, terrain.height_at(spot.x), spot.y)
		var index: int = picking.add_pile(spot, 1)
		pickup_items[index] = String(entry["item"])
		pickup_nodes[index] = node


## A healing bottle goes into the backpack with a floating "+1 쌍화탕". {} if it is gone or
## picks are not allowed now; otherwise {"item"}.
func collect_pickup(index: int) -> Dictionary:
	if not picks_allowed() or not pickup_items.has(index):
		return {}
	if picking.pick_pile(index, true)["result"] != "pile":
		return {}
	var item_id: String = pickup_items[index]
	var node: Node3D = pickup_nodes[index]
	node.visible = false
	if String(Content.item(item_id).get("kind", "")) == "tool":
		GameState.tools.add(item_id)
	else:
		GameState.inventory.add(item_id)
	FloatLabel.make(self, "+1 %s" % String(Content.item(item_id)["name_ko"]), node.global_position + Vector3(0.0, float_label_height - 1.0, 0.0), float_label_config)
	return {"item": item_id}


func _update_pickups(delta: float) -> void:
	_pickup_time += delta
	for index in pickup_nodes:
		pickup_nodes[index].bob(_pickup_time)


## One tick of a click-walk: the direction to walk (after the animal), the grab on arrival.
func _walk_step(delta: float) -> Vector2:
	var pile: int = picking.walk_pile
	var walker = slot_walker.get(picking.walk_target)
	var goal := Vector2.ZERO
	if pile >= 0:
		if not picking.is_pile_pickable(pile):
			picking.cancel_walk()
			return Vector2.ZERO
		goal = picking.pile_spot(pile)
	elif walker != null:
		goal = walker.position()
	else:
		picking.cancel_walk()
		return Vector2.ZERO
	var to: Vector2 = goal - Vector2(player.global_position.x, player.global_position.z)
	match picking.walk_update(to.length(), delta):
		"arrived":
			if pile >= 0:
				collect_pickup(pile)
			else:
				grab_animal(walker)
		"walking":
			return to.normalized()
	return Vector2.ZERO


## Takes the letter off an animal with a bare hand: it goes into the basket, the animal runs
## for its exit and bites Fernanda (the kind's cost; a predator may kill them both). {} if
## nothing was taken: the kind cannot be grabbed by hand, its letter is gone, or grabs are
## not allowed now. Otherwise {"letter", "units", "death"}.
func grab_animal(walker) -> Dictionary:
	if not picks_allowed() or not Grab.by_hand(walker.kind) or not walker_slot.has(walker) or not animal_nodes.has(walker):
		return {}
	var missing_before: Dictionary = needs.missing_letters(spelling, picking.basket)  # as it was before the letter joins the basket
	var result: Dictionary = picking.pick(walker_slot[walker], true)
	if result["result"] == "none":
		return {}
	var letter := String(result["letter"])
	hint.note_grab(letter, missing_before)
	var node: Node3D = animal_nodes[walker]
	walker.letter = ""
	node.set_letter("")
	basket_hud.refresh(0.0)
	_fly_letter(letter, node.global_position + Vector3(0.0, node.tile.position.y, 0.0))
	var cost: Dictionary
	var glove: Dictionary = equipped_gloves()
	if glove.is_empty():
		cost = Grab.cost(walker.kind, grab_rng)
	else:  # Prompt 9c: gloves on a harmless animal never bite and cost a use; a predator shreds them
		var through := ToolUse.glove_grab(walker.kind)
		if through["shredded"]:
			_lose_tool(glove, "shredded!", true)
			cost = Grab.cost(walker.kind, grab_rng)
		else:
			_lose_tool(glove, "broke!", false)
			cost = {"units": 0, "death": false, "bite": false}
	crossing.flee(walker, float(config["grab"]["flee_speed_scale"]))
	if not cost["bite"]:  # it only ran: the grab cost nothing
		return {"letter": letter, "units": 0, "death": false, "bite": false}
	var grabber := GameState.controlled
	var units: int = int(GameState.heart_units[grabber]) if cost["death"] else int(cost["units"])
	var lethal := GameState.damage_units(grabber, units, "animal_bite")
	HitFx.hit(self, travelers[grabber], gore)
	if lethal:
		begin_death_beat()
	return {"letter": letter, "units": units, "death": cost["death"], "bite": true}


## The letter flies from the animal to the basket: a label on its own layer that is gone
## after grab.fly_s seconds (the basket's tile pops in at once).
func _fly_letter(letter: String, from_world: Vector3) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 8
	var label := Label.new()
	label.text = letter
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", int(config["grab"]["fly_font_size"]))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(label)
	add_child(layer)
	var from := camera.unproject_position(from_world)
	var view := get_viewport().get_visible_rect().size
	var to := view - Vector2(basket_hud.margin + 70.0, basket_hud.margin + 70.0)
	label.position = from
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position", to, float(config["grab"]["fly_s"]))
	tween.tween_property(label, "modulate:a", 0.4, float(config["grab"]["fly_s"]))
	tween.chain().tween_callback(layer.queue_free)


## The reach ring sits on the nearest animal in grab range.
func _update_reach(delta: float) -> void:
	_ring_time += delta
	if revive.downed_near(GameState.controlled, _flat_positions()) != "":  # the revive ring takes over
		_ring.visible = false
		return
	var walker = null
	var bottle = null
	var outer: float = picking.ring_radius()
	var tool_def := equipped_tool_def()
	if not tool_def.is_empty():  # a tool in hand: the ring marks the animal it would take, sized by its reach
		var pile: int = picking.nearest_pile(_flat_of(player))
		if pile >= 0:
			bottle = pickup_nodes.get(pile)
		else:
			walker = _tool_target(tool_def, _flat_of(player))["walker"]
			outer = maxf(ToolUse.reach(tool_def, picking.pick_radius) + picking.ring_radius_offset, picking.ring_width)
	else:
		var target: Dictionary = picking.nearest_target(Vector2(player.global_position.x, player.global_position.z))
		walker = slot_walker.get(int(target["index"])) if target["type"] == "plant" else null
		bottle = pickup_nodes.get(int(target["index"])) if target["type"] == "pile" else null
	_ring.visible = (walker != null and animal_nodes.has(walker)) or bottle != null
	if not _ring.visible:
		return
	var at: Vector3 = bottle.global_position if bottle != null else animal_nodes[walker].global_position
	_ring.global_position = at
	_ring.mesh = ReachRing.mesh(outer, maxf(outer - picking.ring_width, 0.0), at, terrain.height_at)
	_ring_material.albedo_color.a = picking.ring_alpha_at(_ring_time)


# ---- Hint letters (Prompt 9c-iii) ----

## True while the scene is really playing: not paused, no menu, backpack, spelling view or
## letter open, not in the death beat or a monster run. The hint clock only runs then.
func _hint_playing() -> bool:
	return not get_tree().paused and not restarting and _dim == null and not pause_menu.is_open \
			and not backpack.is_open and not spelling_hud.is_open() and not discovery_hud.word_select.is_open() \
			and not hint_hud.is_open()


## True if a due letter may open now: the scene is playing and no guide prompt is up or waiting.
func _hint_clear() -> bool:
	return _hint_playing() and guide.current == "" and guide.queued().is_empty()


## Ticks the hint clock (a finished syllable restarts it) and opens the letter when it is due
## and the way is clear. A due clock with no letter left to give is simply restarted.
func _update_hint(delta: float) -> void:
	var solved := 0
	for entry in needs.entries:
		var word_id := String(entry["id"])
		if entry["kind"] == Needs.WORD and spelling.has_word(word_id):
			solved += spelling.solved(word_id).size()
	hint.note_solved(solved)
	if hint_hud.is_open() or not hints_enabled:
		return
	hint.tick(delta, _hint_playing())
	if not hint.due():
		return
	var id: String = hint.next_id(needs.entries, spelling)
	if id == "":
		hint.reset()
	elif _hint_clear():
		open_hint(id)


## Floats the letter of the word need `id` in and pauses the scene. False if one is on screen
## or the need has no letter. The need has had its letter from now on, and the clock restarts.
func open_hint(id: String) -> bool:
	if hint_hud.is_open() or hint.letter_of(id).is_empty():
		return false
	hint.mark_given(id)
	hint.reset()
	picking.cancel_walk()
	var paper: Dictionary = hint_ending["note"]
	var centre := ground_hit(get_viewport().get_visible_rect().size / 2.0)
	var to := Vector3(centre.x, terrain.height_at(centre.x), centre.y)
	var from := to
	from.x = maxf(camera.global_position.x + camera_half_width() + float(paper["start_margin"]), to.x + float(paper["start_margin"]))
	from.y += float(paper["start_height"])
	hint_hud.open(id, hint.letter_of(id), hint.format_of(id), from, to)
	get_tree().paused = true
	return true


func _on_hint_closed() -> void:
	get_tree().paused = false


# ---- Tools (Prompt 9c) ----

func _flat_of(node: Node3D) -> Vector2:
	return Vector2(node.global_position.x, node.global_position.z)


## At scene start (once per hike): animals.tools.start goes into the belt and the first is
## equipped; a restart gives them back through the belt's scene-start snapshot.
func _give_start_tools() -> void:
	var scene_id := String(config["begin_id"])
	if not tools_enabled or GameState.kits_given.has(scene_id):
		return
	GameState.kits_given[scene_id] = true
	var first := 0
	for entry in config["tools"]["start"]:
		for n in int(entry["count"]):
			var uid := GameState.tools.add(String(entry["item"]))
			first = first if first > 0 else uid
	if first > 0:
		GameState.tools.equip(first)
	GameState.snapshot_tools_start()


## The definition of the equipped tool that grabs through the map (not Hands, not the gloves,
## which work through bare-hand grabs); {} otherwise.
func equipped_tool_def() -> Dictionary:
	var held: Dictionary = GameState.tools.equipped()
	if held.is_empty():
		return {}
	var def: Dictionary = Content.item(String(held["id"]))
	return {} if ToolUse.is_gloves(def) else def


## The equipped instance if it is the gloves, else {}.
func equipped_gloves() -> Dictionary:
	var held: Dictionary = GameState.tools.equipped()
	if held.is_empty() or not ToolUse.is_gloves(Content.item(String(held["id"]))):
		return {}
	return held


## R: the next of Hands and the tools in the backpack (not while a menu is up or a traveler is
## down). Returns the uid now equipped (0 = Hands), or -1 if nothing was done.
func cycle_tool() -> int:
	if not picks_allowed():
		return -1
	return GameState.tools.cycle()


## Takes uses off the instance `held` (all of them if `all`); when none are left it is gone, with a
## floating "<name> <word>" over the traveler.
func _lose_tool(held: Dictionary, word: String, all: bool) -> void:
	_spend_tool(held, int(held["uses"]) if all else 1, word)


## Spends `uses` of the instance `held`; one that runs out is removed, with the floating label.
func _spend_tool(held: Dictionary, uses: int, word: String) -> void:
	var result: Dictionary = GameState.tools.spend(int(held["uid"]), uses)
	if not result.is_empty() and result["broke"]:
		var at: Vector3 = player.global_position + Vector3(0.0, float_label_height, 0.0)
		FloatLabel.make(self, "%s %s" % [Content.item(String(result["id"]))["name_ko"], word], at, float_label_config)


## The animals a tool may take now, as {"walker": the nearest within reach that the tool works
## on (or null), "wrong": the nearest within reach that it does not work on (or null)}. Only
## animals that still carry their letter count; `only` limits it to one animal.
func _tool_target(def: Dictionary, me: Vector2, only = null) -> Dictionary:
	var reach := ToolUse.reach(def, picking.pick_radius)
	var best = null
	var best_distance := INF
	var wrong = null
	var wrong_distance := INF
	for walker in crossing.alive:
		if walker.letter == "" or not animal_nodes.has(walker) or (only != null and walker != only):
			continue
		var distance: float = walker.position().distance_to(me)
		if distance > reach:
			continue
		if ToolUse.works_on(def, walker.kind):
			if distance < best_distance:
				best = walker
				best_distance = distance
		elif distance < wrong_distance:
			wrong = walker
			wrong_distance = distance
	return {"walker": best, "wrong": wrong}


## Space (or a click on an animal in reach) with a tool in hand: takes the letter of the nearest
## animal within its reach that it works on (`only`: that animal alone). Costs the tool's uses
## (the quirks of items.json) and never hearts; the animal flees. With a wind-up the grab lands
## that many seconds later (tool_pending, ticked by the map) and misses if the animal is out of
## reach by then, the uses spent all the same. On a wrong target the HUD shows a note and nothing
## is spent. {} if nothing was spent; else {"result": "hit" | "miss" | "windup", "uses", "letter"}.
func grab_with_tool(only = null) -> Dictionary:
	var held: Dictionary = GameState.tools.equipped()
	var def := equipped_tool_def()
	if def.is_empty() or not picks_allowed() or not tool_pending.is_empty():
		return {}
	var found := _tool_target(def, _flat_of(player), only)
	if found["walker"] == null:
		if found["wrong"] != null:
			tool_hud.show_note(ToolUse.wrong_target_note(def))
		return {}
	var walker = found["walker"]
	var uses: int = ToolUse.cost(def, walker.kind, int(held["uses"]))
	_spend_tool(held, uses, "broke!")
	tool_pending = {"walker": walker, "left": ToolUse.windup(def), "def": def, "uses": uses}
	if ToolUse.windup(def) <= 0.0:
		return _land_tool()
	return {"result": "windup", "uses": uses, "letter": ""}


## The wind-up ticks while the map runs; the grab lands when it is over.
func _tick_tool(delta: float) -> void:
	if tool_pending.is_empty():
		return
	tool_pending["left"] = float(tool_pending["left"]) - delta
	if float(tool_pending["left"]) <= 0.0:
		_land_tool()


## The pending tool grab lands: the letter if the animal is still on the map with its letter and
## within the tool's reach of the traveler, else a miss.
func _land_tool() -> Dictionary:
	var pending := tool_pending
	tool_pending = {}
	var walker = pending["walker"]
	var uses: int = int(pending["uses"])
	var result := {"result": "miss", "uses": uses, "letter": ""}
	if animal_nodes.has(walker) and walker.letter != "" and ToolUse.in_reach(pending["def"], walker.position().distance_to(_flat_of(player)), picking.pick_radius):
		result = {"result": "hit", "uses": uses, "letter": _take_letter(walker)}
		crossing.flee(walker, float(config["grab"]["flee_speed_scale"]))
	last_tool_result = result
	tool_grab_done.emit(result)
	return result


## The animal's letter goes into the basket (through its slot if it has one: only the hand-grabbable
## kinds do), off its tile, and flies to the basket. Returns the letter.
func _take_letter(walker) -> String:
	var letter: String = walker.letter
	hint.note_grab(letter, needs.missing_letters(spelling, picking.basket))
	if walker_slot.has(walker):
		picking.pick(walker_slot[walker], true)
	else:
		picking.basket.append(letter)
	var node: Node3D = animal_nodes[walker]
	walker.letter = ""
	node.set_letter("")
	basket_hud.refresh(0.0)
	_fly_letter(letter, node.global_position + Vector3(0.0, node.tile.position.y, 0.0))
	return letter


# ---- Downed travelers and reviving them (Prompt 9b-iv) ----

func _flat_positions() -> Dictionary:
	var flat := {}
	for id in travelers:
		flat[id] = Vector2(travelers[id].global_position.x, travelers[id].global_position.z)
	return flat


func _world_positions() -> Dictionary:
	var world := {}
	for id in travelers:
		world[id] = travelers[id].global_position
	return world


func _on_traveler_downed(_id: String, _injury: String) -> void:
	_sync_downed()


## Puts every body in the pose its hearts say (lying at 0, upright above), and hands control
## to the partner when the controlled traveler is downed and the partner is not.
func _sync_downed() -> void:
	for id in travelers:
		ReviveView.pose(travelers[id], GameState.is_downed(id), revive_config)
	var who := Revive.controller()
	if who != GameState.controlled:
		GameState.controlled = who
		player = travelers[who]
		partner = travelers[GameState.partner_of(who)]
		picking.cancel_walk()


## The pick action with a downed traveler in range: starts the revive channel, or shows the
## no-item note. "none" if nobody downed is in range (nothing was done).
func press_revive() -> String:
	return revive.press(GameState.controlled, _flat_positions())


## One tick of the revive channel and the bleed-out clocks (only while the map runs).
func _tick_revive(delta: float) -> void:
	for event in revive.tick(delta, GameState.controlled, _flat_positions()):
		match event["event"]:
			"revived":
				ReviveView.pose(travelers[event["id"]], false, revive_config)
				var item_name := String(Content.item(String(event["item"]))["name_ko"])
				FloatLabel.make(self, "-1 %s" % item_name, travelers[event["id"]].global_position + Vector3(0.0, float_label_height, 0.0), float_label_config)
			"bled_out":
				begin_death_beat()


# ---- The downed countdown and the bear (Prompt 9c-ii) ----

## True if the scene may be left: nobody is downed. The animal scene's exit (9e) asks this (or
## try_leave()) before it fires.
func can_leave() -> bool:
	return Revive.can_leave()


## An exit was reached: false (and the "Revive Nestor before you leave." note shows) while
## anyone is downed; true if the way is clear.
func try_leave() -> bool:
	return not revive.block_leave()


## One tick of the downed countdown, its music and HUD, and the bear.
func _tick_downed(delta: float) -> void:
	downed_countdown.clock.paused = pause_menu.is_open or backpack.is_open or spelling_hud.is_open() or hint_hud.is_open()
	match downed_countdown.update(not restarting and _dim == null and not bear.is_active()):
		"started":
			_music.start()
		"cancelled":
			_music.stop()
	if downed_countdown.clock.tick(delta) and not GameState.all_downed():
		send_bear()
	elif downed_countdown.clock.is_locked() and not restarting:  # the last seconds: no more inputs
		restarting = true
		hunt_lock = true
		picking.cancel_walk()
		tool_pending = {}
	_tick_bear(delta)
	stuck_hud.refresh(downed_countdown.clock, spelling_hud.is_open())


## Sends the giant bear for the traveler still standing (the controlled one if both stand).
## Inputs lock; the animals go on. False if it is on its way already, the scene is dying or
## nobody stands. 9e calls this too when the scene timer runs out.
func send_bear() -> bool:
	var who := DownedCountdown.standing()
	if who == "" and not GameState.all_downed():
		who = GameState.controlled
	if who == "" or bear.is_active() or _dim != null:
		return false
	restarting = true
	hunt_lock = true
	picking.cancel_walk()
	tool_pending = {}
	_abandon_downed()
	return bear.hunt(travelers[who])


func _tick_bear(delta: float) -> void:
	for event in bear.tick(delta):
		match event:
			"kill":
				_bear_kill()
			"done":
				begin_death_beat()


## The bear reaches its target: a big blood burst and a red flash, every heart gone. If someone
## still stands (a revive in the last seconds saved nobody), it goes for them next.
func _bear_kill() -> void:
	var id := String(travelers.find_key(bear.target))
	HitFx.hit(self, travelers[id], gore, bear.burst_strength, float(gore["tint_duration"]) * 2.0)
	GameState.damage_units(id, GameState.max_units(), "bear")
	for other in GameState.TRAVELERS:
		if not GameState.is_downed(other):
			bear.hunt(travelers[other], true)
			return


## No countdown, no vignette, no music.
func _abandon_downed() -> void:
	downed_countdown.clock.abandon()
	_music.stop()
	stuck_hud.refresh(downed_countdown.clock, false)


# ---- Menus (the foraging scene's, with the same keys) ----

## Esc: opens the pause menu and pauses the map. False while the backpack is open or the
## menu is open already.
func open_pause_menu() -> bool:
	if backpack.is_open or restarting or spelling_hud.is_open() or hint_hud.is_open() or discovery_hud.word_select.is_open() or not pause_menu.open(true):
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
	return not GameState.is_downed(GameState.controlled) and not pause_menu.is_open and pause_menu.restart_requests == 0 and not restarting and not spelling_hud.is_open() and not hint_hud.is_open() and not discovery_hud.word_select.is_open()


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
	_abandon_downed()
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


## The ground the camera shows as a rectangle over (x, z): the box round the footprint's
## corners (animals enter and leave outside it).
func view_rect() -> Rect2:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for corner in camera_footprint():
		low = Vector2(minf(low.x, corner.x), minf(low.y, corner.y))
		high = Vector2(maxf(high.x, corner.x), maxf(high.y, corner.y))
	return Rect2(low, high - low)


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
