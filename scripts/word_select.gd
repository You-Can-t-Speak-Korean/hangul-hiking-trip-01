extends RefCounted
## Keyboard word selection, with no nodes (shared by the foraging notebook list
## and, later, the animal scene). The caller hands over the ids of the words that
## can be spelled, in the order they are laid out; this keeps a highlight on one
## of them. Up/down move one row and left/right one word within the row, both
## wrapping. Confirm returns the highlighted id, cancel closes and returns "".
##
## Keys are named Input Map actions only: spell_open, select_up, select_down,
## select_left, select_right, select_confirm, select_cancel.

## Words per row of the layout (1 = a single column, as the foraging list is).
var columns := 1
## The words that can be chosen, in layout order, while open.
var words: Array[String] = []
## The highlighted position in `words`.
var index := 0

var _open := false


func is_open() -> bool:
	return _open


## Opens on the first of `spellable`. False (and nothing changes) if it is empty
## or the selection is open already.
func open(spellable: Array) -> bool:
	if _open or spellable.is_empty():
		return false
	words.clear()
	for id in spellable:
		words.append(String(id))
	index = 0
	_open = true
	return true


## Closes without choosing.
func close() -> void:
	_open = false
	words.clear()
	index = 0


## The highlighted word, "" while closed.
func highlighted() -> String:
	return words[index] if _open and index < words.size() else ""


## Moves the highlight: "up", "down", "left" or "right". False if closed.
func move(direction: String) -> bool:
	if not _open:
		return false
	index = stepped(index, direction, words.size())
	return true


## Where `direction` leads from `from` among `count` words. Up/down keep the
## column and wrap over the rows (the last word if the next row is shorter);
## left/right wrap inside the row.
func stepped(from: int, direction: String, count: int) -> int:
	if count <= 0:
		return 0
	var cols := maxi(columns, 1)
	var row := floori(float(from) / cols)
	match direction:
		"up", "down":
			var rows := ceili(float(count) / cols)
			var target := posmod(row + (1 if direction == "down" else -1), rows)
			return mini(target * cols + from % cols, count - 1)
		"left", "right":
			var start := row * cols
			var width := mini(cols, count - start)
			return start + posmod(from - start + (1 if direction == "right" else -1), width)
	return from


## Chooses the highlighted word: closes and returns its id ("" if closed).
func confirm() -> String:
	var id := highlighted()
	if _open:
		close()
	return id


## Closes, returning "" (nothing chosen).
func cancel() -> String:
	close()
	return ""


## What a key press means to word selection: "open", "up", "down", "left",
## "right", "confirm", "cancel", or "" for anything else. Movement repeats while
## held; the others do not.
static func action_for(event: InputEvent) -> String:
	for direction in ["up", "down", "left", "right"]:
		if event.is_action_pressed("select_" + direction, true):
			return direction
	if event.is_action_pressed("select_confirm"):
		return "confirm"
	if event.is_action_pressed("select_cancel"):
		return "cancel"
	if event.is_action_pressed("spell_open"):
		return "open"
	return ""
