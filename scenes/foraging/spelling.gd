extends RefCounted
## The spelling view's logic, with no nodes. A discovered target word is spelled
## one syllable block at a time, left to right: the player puts letters from the
## basket into the current block's slots, and a block is judged the moment its
## last slot is filled. Judging is strict: the block is CORRECT only if the
## Hangul engine composes exactly the target's syllable at that position;
## anything else (a different real syllable, two consonants, two vowels) is a
## FAILURE that destroys both letters.
##
## A letter put into a slot leaves the basket at once and goes back to it if the
## block is taken back or the view is closed unjudged. The basket array is the
## Picking's own (shared, never replaced). A new Spelling (a scene restart) has
## no progress and no done words.

## 6b hooks the damage onto this: the word's id, the failed block's index and
## the letters that were destroyed, in slot order.
signal syllable_failed(word_id: String, block_index: int, letters: Array)
## The last block of a word was judged correct.
signal word_completed(word_id: String)

## Colours and sizes of the view (data: foraging.spelling_view); the logic does
## not use them, the HUDs do.
var config: Dictionary = {}
## The word being spelled, or "" while the view is closed.
var open_id := ""
## Letters in the current block's slots, "" for an empty slot.
var placed: Array[String] = []

var _basket: Array[String]  # shared with the Picking
var _words: Dictionary = {}  # target kind id -> {"name": Korean, "solved": Array[String]}


## `config` is foraging.spelling_view, `plants_data` is foraging.plants, `basket`
## is the Picking's basket.
func _init(spelling_config: Dictionary, plants_data: Dictionary, basket: Array[String]) -> void:
	config = spelling_config
	_basket = basket
	for kind in plants_data["kinds"]:
		if kind["kind"] == "target":
			var solved: Array[String] = []
			_words[kind["id"]] = {"name": String(kind["name"]), "hover_name": String(kind["hover_name"]), "solved": solved}


## The slots of a syllable block, in order. Hallasan has no 받침, so a block is
## an initial and a medial; a syllable with a final gets a third slot, which
## the view does not draw yet.
func slots_for(syllable: String) -> Array[String]:
	var slots: Array[String] = ["initial", "medial"]
	var parts := Hangul.decompose(syllable)
	if parts.size() == 3 and parts[2] != "":
		slots.append("final")
	return slots


func has_word(id: String) -> bool:
	return _words.has(id)


## The word's Korean name (the answer). Empty for an unknown id.
func word_name(id: String) -> String:
	return _words[id]["name"] if _words.has(id) else ""


## The word's English name, as the discovery list shows it.
func hover_name(id: String) -> String:
	return _words[id]["hover_name"] if _words.has(id) else ""


func block_count(id: String) -> int:
	return Hangul.syllable_count(word_name(id))


## The target syllable at a block position, or "".
func target_syllable(id: String, block: int) -> String:
	var name := word_name(id)
	return name[block] if block >= 0 and block < name.length() else ""


## Syllables judged correct so far, in order.
func solved(id: String) -> Array[String]:
	return _words[id]["solved"] if _words.has(id) else []


func is_done(id: String) -> bool:
	return _words.has(id) and solved(id).size() == block_count(id)


func is_open() -> bool:
	return open_id != ""


## The block being spelled in the open word (the first not judged correct).
func current_block() -> int:
	return solved(open_id).size() if is_open() else -1


## Opens a word. False if `allowed` is false (restarting, dead), the id is not a
## target, the word is done, or a word is open already.
func open(id: String, allowed: bool = true) -> bool:
	if not allowed or is_open() or not _words.has(id) or is_done(id):
		return false
	open_id = id
	_clear_placed()
	return true


## Closes the view. Letters in the unjudged block go back to the basket; judged
## blocks stay. Returns the letters that went back.
func close() -> Array[String]:
	var returned: Array[String] = []
	for letter in placed:
		if letter != "":
			returned.append(letter)
			_basket.append(letter)
	open_id = ""
	_clear_placed()
	return returned


## True if `letter` could be put into this slot now: the word is open, the block
## is the current one, the slot is empty and the basket holds the letter. The
## kind of slot does not matter; judging decides.
func can_place(letter: String, block: int, slot: int) -> bool:
	return is_open() and block == current_block() and slot >= 0 and slot < placed.size() \
			and placed[slot] == "" and _basket.has(letter)


## Puts a basket letter into a slot. Returns {"result", "block", "letters"}:
## "rejected" (nothing changed), "placed" (the block is not full yet), "correct"
## (judged right, locked), "complete" (that was the last block; the word is done
## and closed) or "failed" (both letters destroyed, the view closed, and
## syllable_failed emitted). "letters" is the block's letters for the last three.
func place(letter: String, block: int, slot: int) -> Dictionary:
	if not can_place(letter, block, slot):
		return {"result": "rejected", "block": block, "letters": []}
	_basket.erase(letter)  # one copy
	placed[slot] = letter
	if placed.has(""):
		return {"result": "placed", "block": block, "letters": []}
	var letters: Array = placed.duplicate()
	var id := open_id
	if judge(id, block, letters):
		solved(id).append(target_syllable(id, block))
		if is_done(id):
			open_id = ""
		_clear_placed()
		if not is_open():
			word_completed.emit(id)
			return {"result": "complete", "block": block, "letters": letters}
		return {"result": "correct", "block": block, "letters": letters}
	open_id = ""
	_clear_placed()
	syllable_failed.emit(id, block, letters)
	return {"result": "failed", "block": block, "letters": letters}


## True if `letters` (one per slot) compose the target syllable of the word at
## `block`. Pure: no state changes.
func judge(id: String, block: int, letters: Array) -> bool:
	var target := target_syllable(id, block)
	if target == "" or letters.size() < 2 or letters.size() > 3:
		return false
	var final: String = letters[2] if letters.size() == 3 else ""
	return Hangul.compose(letters[0], letters[1], final) == target


## Takes a letter out of an unjudged slot back to the basket. False if there is
## nothing to take (wrong block, empty slot, view closed).
func take_back(block: int, slot: int) -> bool:
	if not is_open() or block != current_block() or slot < 0 or slot >= placed.size() or placed[slot] == "":
		return false
	_basket.append(placed[slot])
	placed[slot] = ""
	return true


func _clear_placed() -> void:
	placed.clear()
	if is_open():
		for slot in slots_for(target_syllable(open_id, current_block())):
			placed.append("")
