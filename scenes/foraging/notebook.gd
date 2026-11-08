extends RefCounted
## The pages of the 수첩, with no nodes. One page per note held in the backpack,
## in the order the notes were gained (the order of Inventory.items(), which a
## snapshot and a restore keep). The notebook opens on the newest page; "previous"
## flips back to an older one and "next" forward again.
##
##   open(items)                the newest page is shown
##   flip(direction, items)     -1 previous (older), +1 next (newer); false at either end
##   has_previous / has_next    whether a page exists that way
##   current_id(items)          the note on the page, "" if there are no notes
##   page_text(items)           that note's text, exactly as in data/notes/*.json
##   note_ids(items)            the held notes, oldest first
##
## `items` is Inventory.items(): [{id, count}]. Notes are the items whose kind is
## "note"; a note never takes a backpack row. Nothing here knows the key bindings.

## The user argument that puts every note of data/notes/*.json into the backpack
## at scene start (a debugging aid).
const DEBUG_ARG := "--debug-notes"

## Index into note_ids(): 0 is the oldest note.
var page := 0


## True if the user arguments contain --debug-notes.
static func debug_notes_from_args(args: PackedStringArray) -> bool:
	return args.has(DEBUG_ARG)


## True for an item id that is a note.
static func is_note(item_id: String) -> bool:
	return Content.has_item(item_id) and String(Content.item(item_id).get("kind", "")) == "note"


## The held notes, oldest first.
static func note_ids(items: Array) -> Array[String]:
	var ids: Array[String] = []
	for entry in items:
		if is_note(String(entry["id"])):
			ids.append(String(entry["id"]))
	return ids


## Shows the newest page.
func open(items: Array) -> void:
	page = maxi(note_ids(items).size() - 1, 0)


## Keeps the page valid after the backpack changed (a lost note moves it to the newest).
func sync(items: Array) -> void:
	page = clampi(page, 0, maxi(note_ids(items).size() - 1, 0))


## Moves to an older (-1) or newer (+1) page. False (nothing changes) at the end.
func flip(direction: int, items: Array) -> bool:
	var target := page + signi(direction)
	if direction == 0 or target < 0 or target >= note_ids(items).size():
		return false
	page = target
	return true


func has_previous(items: Array) -> bool:
	return page > 0 and page < note_ids(items).size()


func has_next(items: Array) -> bool:
	return page + 1 < note_ids(items).size()


## The note on the shown page, or "" if the backpack holds no notes. A page that
## no longer exists (a note was lost) falls back to the newest one.
func current_id(items: Array) -> String:
	var ids := note_ids(items)
	if ids.is_empty():
		return ""
	return ids[clampi(page, 0, ids.size() - 1)]


## The text of the shown page, "" if there is none.
func page_text(items: Array) -> String:
	var id := current_id(items)
	return String(Content.notes[id]["text"]) if Content.notes.has(id) else ""
