extends Node
## Everything that survives between scenes: hearts, ddeok, choices.
##
## Rules (Hallasan Roadmap §0, §6):
## - Hearts are stored in half-units (rules.json half_units_per_heart; 1 heart = 2 units),
##   so half-heart damage and healing are exact integers. Display only converts to hearts.
## - Full hearts only at the start of the hike. Healing exists only through items that
##   decoy plants can give (half a heart or a whole heart); those items are not built yet.
##   The scene-start snapshot rule still applies.
## - If one traveler hits 0, both die (the monster eats the survivor).
## - Death restarts the current scene with the hearts held at its start.
## - DDEOK (the currency) carries over to the next game.

## `units` is the traveler's new total in half-units, not hearts.
signal hearts_changed(traveler: String, units: int)
signal ddeok_changed(ddeok: int)
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

var _scene_start_units: Dictionary = {}
var _scene_start_ddeok: int = 0


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
	current_scene = ""
	begin_scene("")


## Snapshots hearts and ddeok so restart_scene() can restore them.
func begin_scene(scene_id: String) -> void:
	current_scene = scene_id
	_scene_start_units = heart_units.duplicate()
	_scene_start_ddeok = ddeok
	# Saving goes here later (progress save per scene).


## Death → restart the current scene with what they had when it began.
func restart_scene() -> void:
	heart_units = _scene_start_units.duplicate()
	ddeok = _scene_start_ddeok
	for t in TRAVELERS:
		hearts_changed.emit(t, heart_units[t])
	ddeok_changed.emit(ddeok)


## A wrong or too-slow answer: exactly one whole heart. Returns true if this hit killed them both.
func damage(traveler: String, injury: String) -> bool:
	return damage_units(traveler, units_per_heart(), injury)


## Lowers a traveler by `units` half-units (floor 0). Returns true if they are dead afterwards.
func damage_units(traveler: String, units: int, injury: String = "") -> bool:
	if not is_alive(traveler):
		return true  # already dead: the death signal fired once, don't repeat it
	heart_units[traveler] = max(0, int(heart_units[traveler]) - units)
	hearts_changed.emit(traveler, heart_units[traveler])
	if heart_units[traveler] == 0:
		travelers_died.emit(traveler, partner_of(traveler), injury)
		return true
	return false


## Raises a traveler by `units` half-units, capped at max. The dead can't be healed.
func heal(traveler: String, units: int) -> void:
	if not is_alive(traveler):
		return
	heart_units[traveler] = min(max_units(), int(heart_units[traveler]) + units)
	hearts_changed.emit(traveler, heart_units[traveler])


func is_alive(traveler: String) -> bool:
	return int(heart_units.get(traveler, 0)) > 0


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
