extends Node
## Everything that survives between scenes: hearts, ddeok, choices.
##
## Rules (Hallasan Roadmap §0, §6):
## - 5 hearts each, full only at the start of the hike. No refills.
## - If one traveler hits 0, both die (the monster eats the survivor).
## - Death restarts the current scene with the hearts held at its start.
## - DDEOK (the currency) carries over to the next game.

signal hearts_changed(traveler: String, hearts: int)
signal ddeok_changed(ddeok: int)
signal travelers_died(dead: String, survivor: String, injury: String)

const TRAVELERS: Array[String] = ["nestor", "fernanda"]
const MAX_DDEOK := (1 << 24) - 1

var game_id: String = "hallasan"
var difficulty: String = "soso"
var controlled: String = "fernanda"  # who the solo player controls
var two_player: bool = false

var hearts: Dictionary = {}
var ddeok: int = 0
var current_scene: String = ""

var _scene_start_hearts: Dictionary = {}
var _scene_start_ddeok: int = 0


func _ready() -> void:
	new_hike()


func max_hearts() -> int:
	return int(Content.rules.get("hearts_per_traveler", 5))


func partner_of(traveler: String) -> String:
	return "fernanda" if traveler == "nestor" else "nestor"


## Start of the hike: the only time hearts are full.
func new_hike(starting_ddeok: int = -1) -> void:
	for t in TRAVELERS:
		hearts[t] = max_hearts()
	if starting_ddeok >= 0:
		ddeok = starting_ddeok
	else:
		ddeok = int(Content.rules.get("starting_ddeok_without_save", 0))
	current_scene = ""
	begin_scene("")


## Snapshots hearts and ddeok so restart_scene() can restore them.
func begin_scene(scene_id: String) -> void:
	current_scene = scene_id
	_scene_start_hearts = hearts.duplicate()
	_scene_start_ddeok = ddeok
	# Saving goes here later (progress save per scene).


## Death → restart the current scene with what they had when it began.
func restart_scene() -> void:
	hearts = _scene_start_hearts.duplicate()
	ddeok = _scene_start_ddeok
	for t in TRAVELERS:
		hearts_changed.emit(t, hearts[t])
	ddeok_changed.emit(ddeok)


## A wrong or too-slow answer. Returns true if this hit killed them both.
func damage(traveler: String, injury: String) -> bool:
	if not is_alive(traveler):
		return true  # already dead: the death signal fired once, don't repeat it
	hearts[traveler] = max(0, int(hearts[traveler]) - 1)
	hearts_changed.emit(traveler, hearts[traveler])
	if hearts[traveler] == 0:
		travelers_died.emit(traveler, partner_of(traveler), injury)
		return true
	return false


func is_alive(traveler: String) -> bool:
	return int(hearts.get(traveler, 0)) > 0


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
