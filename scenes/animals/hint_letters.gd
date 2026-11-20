extends RefCounted
## The hint letters of the animal scene, with no nodes (data: animals.hint_letters; the content
## is docs/production/hallasan-hint-letters-v0.1.md). After `idle_s` seconds of play with no
## progress, the letter of the OLDEST discovered, unfinished word need that has not had its
## letter yet is due. Progress is a grab of a letter an unfinished word need still lacks, or a
## finished syllable. Each need gets its letter at most once per run; item needs have none.
##
## The clock only moves while `tick()` is told the scene is playing (not paused, not in a menu,
## the spelling view, the death beat or a monster run). The scene decides when it is clear to
## open a due letter and then calls `mark_given()` and `reset()`.

const EPSILON := 0.0001  # seconds: float sums of small steps may fall just short

var idle_s := 60.0
## Seconds of play since the last progress (or the last letter).
var clock := 0.0
## Need word -> {"format", "lines", "_en"} (lines: Strings, or [label, price] receipt rows).
var letters: Dictionary = {}
## Format id -> style (see animals.hint_letters.formats).
var formats: Dictionary = {}
## The needs that have had their letter this run (word -> true).
var given: Dictionary = {}

var _solved_seen := 0


## `config` is animals.hint_letters.
func _init(config: Dictionary) -> void:
	idle_s = float(config["idle_s"])
	letters = config["letters"]
	formats = config["formats"]


## Advances the clock by `delta` if the scene is playing.
func tick(delta: float, playing: bool) -> void:
	if playing:
		clock += delta


## True once the clock has reached idle_s.
func due() -> bool:
	return clock >= idle_s - EPSILON


func reset() -> void:
	clock = 0.0


## A letter was grabbed (by hand or tool). `missing` is Needs.missing_letters() as it was BEFORE
## the grab. True (and the clock restarts) if an unfinished word need still lacked that letter.
func note_grab(letter: String, missing: Dictionary) -> bool:
	if not missing.has(letter):
		return false
	reset()
	return true


## The number of syllables solved so far over all words. A rise restarts the clock.
func note_solved(total: int) -> bool:
	var rose := total > _solved_seen
	_solved_seen = total
	if rose:
		reset()
	return rose


## The id of the need whose letter is next: the first of `entries` (Needs.entries, in discovery
## order) that is a word, unfinished, has a letter in the data and has not had it. "" if none.
## `spelling` holds the words.
func next_id(entries: Array, spelling) -> String:
	for entry in entries:
		var id := String(entry["id"])
		if entry["kind"] != "word" or given.has(id) or not letters.has(id):
			continue
		if not spelling.has_word(id) or spelling.is_done(id):
			continue
		return id
	return ""


func mark_given(id: String) -> void:
	given[id] = true


func letter_of(id: String) -> Dictionary:
	return letters.get(id, {})


## The style of a letter's format ({} if unknown).
func format_of(id: String) -> Dictionary:
	return formats.get(String(letter_of(id).get("format", "")), {})


## True if a line of a letter is a receipt row ([label, price]).
static func is_row(line) -> bool:
	return line is Array and line.size() == 2
