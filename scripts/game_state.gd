extends Node
## Everything that survives between scenes: hearts, ddeok, choices.
##
## Rules (Hallasan Roadmap §0, §6):
## - Hearts are stored in half-units (rules.json half_units_per_heart; 1 heart = 2 units),
##   so half-heart damage and healing are exact integers. Display only converts to hearts.
## - Full hearts only at the start of the hike. Healing exists only through items that
##   decoy plants can give (half a heart or a whole heart); those items are not built yet.
##   The scene-start snapshot rule still applies.
## - A traveler at 0 hearts is DOWNED, not dead; a downed traveler can be revived with a
##   healing item (scenes/foraging/revive.gd). The scene ends only when BOTH are downed
##   (travelers_died), or when the stuck-countdown monster kills both outright.
## - Death restarts the current scene with the hearts held at its start.
## - DDEOK (the currency) carries over to the next game.
## - Fernanda's backpack (`inventory`) is restored with the hearts: a death or a
##   restart puts back exactly what it held when the scene began. A new hike starts
##   it with the starting kit (rules.json starting_kit: the 수첩).

const InventoryScript := preload("res://scripts/inventory.gd")
const ToolBeltScript := preload("res://scripts/tool_belt.gd")

## `units` is the traveler's new total in half-units, not hearts.
signal hearts_changed(traveler: String, units: int)
signal ddeok_changed(ddeok: int)
## A traveler just reached 0 hearts (still alive in the story: they can be revived).
signal traveler_downed(traveler: String, injury: String)
## A downed traveler stood up again with `units` half-units.
signal traveler_revived(traveler: String, units: int)
## Both travelers are downed: the scene is over. `dead` is the one that went down last.
signal travelers_died(dead: String, survivor: String, injury: String)

const TRAVELERS: Array[String] = ["nestor", "fernanda"]
const MAX_DDEOK := (1 << 24) - 1

var game_id: String = "hallasan"
var difficulty: String = "soso"
var controlled: String = "fernanda"  # who the solo player controls
var two_player: bool = false

var heart_units: Dictionary = {}  # traveler -> half-units
var ddeok: int = 0
var current_scene: String = ""
## Fernanda's backpack. One instance for the whole run (HUDs stay connected to it).
var inventory := InventoryScript.new()
## The breakable tools (Prompt 9c), each its own instance; kept and restored with the backpack.
var tools := ToolBeltScript.new()
## Scenes whose starting tools were already handed out this hike (scene id -> true), so a
## Restart scene does not hand them out twice. A new hike clears it.
var kits_given: Dictionary = {}

## One-time guide prompts already shown (prompt id -> true). Survives a scene restart; a new
## hike clears it.
var guide_seen: Dictionary = {}

var _scene_start_units: Dictionary = {}
var _scene_start_ddeok: int = 0
var _scene_start_controlled: String = "fernanda"
var _scene_start_inventory: Dictionary = {}
var _scene_start_tools: Dictionary = {}
## The bank handed to the next scene: {"units", "ddeok", "inventory", "target"}, or {}.
## Stored when a scene ends (store_pending_bank) and applied by the next scene's
## begin_scene(), which makes it that scene's start snapshot. Until then the current
## scene's own start snapshot is untouched, so a Restart scene still returns to it.
var pending_bank: Dictionary = {}


func _ready() -> void:
	new_hike()


## Whole hearts a traveler starts with.
func max_hearts() -> int:
	return int(Content.rules.get("hearts_per_traveler", 5))


func units_per_heart() -> int:
	return int(Content.rules.get("half_units_per_heart", 2))


func max_units() -> int:
	return max_hearts() * units_per_heart()


## Whole hearts left (rounded down); pair with has_half() for display.
@warning_ignore("integer_division")
func whole_hearts(traveler: String) -> int:
	return int(heart_units.get(traveler, 0)) / units_per_heart()


## True when the remainder after whole hearts is a partial heart.
func has_half(traveler: String) -> bool:
	return int(heart_units.get(traveler, 0)) % units_per_heart() != 0


## Hearts as a float, for display only. Never use it for rules.
func hearts_for_display(traveler: String) -> float:
	return float(heart_units.get(traveler, 0)) / float(units_per_heart())


func partner_of(traveler: String) -> String:
	return "fernanda" if traveler == "nestor" else "nestor"


## Start of the hike: the only time hearts are full.
func new_hike(starting_ddeok: int = -1) -> void:
	for t in TRAVELERS:
		heart_units[t] = max_units()
	if starting_ddeok >= 0:
		ddeok = starting_ddeok
	else:
		ddeok = int(Content.rules.get("starting_ddeok_without_save", 0))
	inventory.clear()
	tools.clear()
	kits_given.clear()
	guide_seen.clear()
	for entry in Content.starting_kit():  # the 수첩: in every scene-start snapshot, so never lost
		inventory.add(entry["item"], entry["count"])
	current_scene = ""
	pending_bank = {}
	begin_scene("")


## Snapshots hearts, ddeok and the backpack so restart_scene() can restore them.
## If a pending bank is waiting for exactly this scene, it is applied first, so it
## becomes the scene's start snapshot.
func begin_scene(scene_id: String) -> void:
	if not pending_bank.is_empty() and scene_id == String(pending_bank["target"]):
		_apply_pending_bank()
	current_scene = scene_id
	_scene_start_units = heart_units.duplicate()
	_scene_start_ddeok = ddeok
	_scene_start_controlled = controlled
	_scene_start_inventory = inventory.snapshot()
	_scene_start_tools = tools.snapshot()
	# Saving goes here later (progress save per scene).


## The current scene is ending: keeps what the travelers carry out, for `target_id`
## (the next scene's id). Nothing live changes.
func store_pending_bank(target_id: String) -> void:
	pending_bank = {"units": heart_units.duplicate(), "ddeok": ddeok, "inventory": inventory.snapshot(), "tools": tools.snapshot(), "target": target_id}


func has_pending_bank() -> bool:
	return not pending_bank.is_empty()


## Throws the pending bank away (Restart scene from the end of a scene).
func discard_pending_bank() -> void:
	pending_bank = {}


func _apply_pending_bank() -> void:
	var bank := pending_bank
	pending_bank = {}
	heart_units = bank["units"].duplicate()
	inventory.restore(bank["inventory"])
	if bank.has("tools"):
		tools.restore(bank["tools"])
	ddeok = int(bank["ddeok"])
	for t in TRAVELERS:
		hearts_changed.emit(t, heart_units[t])
	ddeok_changed.emit(ddeok)


## Re-takes the tool part of the scene-start snapshot (a scene that hands out starting tools
## after begin_scene() calls this, so a restart gives them back).
func snapshot_tools_start() -> void:
	_scene_start_tools = tools.snapshot()


## Death → restart the current scene with what they had when it began.
func restart_scene() -> void:
	heart_units = _scene_start_units.duplicate()
	ddeok = _scene_start_ddeok
	controlled = _scene_start_controlled  # a revive may have handed control to the partner
	inventory.restore(_scene_start_inventory)
	tools.restore(_scene_start_tools)
	for t in TRAVELERS:
		hearts_changed.emit(t, heart_units[t])
	ddeok_changed.emit(ddeok)


## A wrong or too-slow answer: exactly one whole heart. Returns true if this hit killed them both.
func damage(traveler: String, injury: String) -> bool:
	return damage_units(traveler, units_per_heart(), injury)


## Lowers a traveler by `units` half-units (floor 0). A traveler reaching 0 is downed
## (traveler_downed); when that downs both, travelers_died fires once. A downed traveler takes
## no further damage. Returns true if both travelers are downed afterwards (the scene is over).
func damage_units(traveler: String, units: int, injury: String = "") -> bool:
	if is_downed(traveler):
		return all_downed()  # nothing more to take; the end was announced once
	heart_units[traveler] = max(0, int(heart_units[traveler]) - units)
	hearts_changed.emit(traveler, heart_units[traveler])
	if heart_units[traveler] == 0:
		traveler_downed.emit(traveler, injury)
		if all_downed():
			travelers_died.emit(traveler, partner_of(traveler), injury)
	return all_downed()


## Raises a traveler by `units` half-units, capped at max. The downed can't be healed this
## way (revive() stands them up).
func heal(traveler: String, units: int) -> void:
	if is_downed(traveler):
		return
	heart_units[traveler] = min(max_units(), int(heart_units[traveler]) + units)
	hearts_changed.emit(traveler, heart_units[traveler])


## Stands a downed traveler up with `units` half-units (at least 1, at most max). False if
## they were not downed.
func revive(traveler: String, units: int) -> bool:
	if not is_downed(traveler):
		return false
	heart_units[traveler] = clampi(units, 1, max_units())
	hearts_changed.emit(traveler, heart_units[traveler])
	traveler_revived.emit(traveler, heart_units[traveler])
	return true


## Hearts above 0.
func is_alive(traveler: String) -> bool:
	return int(heart_units.get(traveler, 0)) > 0


## At 0 hearts: lying down, waiting for a revive.
func is_downed(traveler: String) -> bool:
	return int(heart_units.get(traveler, 0)) <= 0


func all_downed() -> bool:
	for t in TRAVELERS:
		if not is_downed(t):
			return false
	return true


func add_ddeok(amount: int) -> void:
	ddeok = clampi(ddeok + amount, 0, MAX_DDEOK)
	ddeok_changed.emit(ddeok)


## Ddeok for an answer. Review vs bonus is decided by the curriculum.
func score_word(word: String, is_monster: bool = false) -> int:
	var s: Dictionary = Content.rules.get("scoring", {})
	var known := Content.known_letters(Content.game_index(game_id))
	var value: int
	if is_monster:
		value = int(s.get("monster_capture", 100))
	elif Hangul.is_readable(word, known):
		value = int(s.get("review_word", 10))
	else:
		value = int(s.get("bonus_guess", 30))
	add_ddeok(value)
	return value


func time_limit(word: String) -> float:
	var d: Dictionary = Content.rules["difficulty"][difficulty]
	var base := float(Content.rules.get("base_seconds_per_syllable", 6.0))
	return base * word.length() * float(d["time_scale"])


# Saving (progress, series save, carry-over code) is not built yet.
