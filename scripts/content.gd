extends Node
## Loads the series data files. Every mountain is data, not code:
## a new game = a new data/mountains/<id>.json plus art and audio.

const CURRICULUM_PATH := "res://data/series/curriculum.json"
const RULES_PATH := "res://data/series/rules.json"
const ITEMS_PATH := "res://data/series/items.json"
const MOUNTAIN_DIR := "res://data/mountains/"
const NOTES_DIR := "res://data/notes/"
const NOTE_WRITERS_PATH := "res://data/series/note_writers.json"
const NOTEBOOK_PATH := "res://data/series/notebook.json"
const ITEM_KINDS: Array[String] = ["elixir", "charm", "hint", "note", "currency", "plant", "notebook"]

var curriculum: Dictionary = {}
var rules: Dictionary = {}
## Item id -> its definition, in file order (see items.json).
var items: Dictionary = {}
## Note id -> {id, writer, text}, in file order (data/notes/*.json, files by name).
## Every note is also an item of kind "note" in `items`, after the items.json ones.
var notes: Dictionary = {}
## Writer id -> {id, name_ko, note} (data/series/note_writers.json). Not shown in game yet.
var note_writers: Dictionary = {}
## The 수첩 view's look (data/series/notebook.json).
var notebook: Dictionary = {}
var _mountains: Dictionary = {}


func _ready() -> void:
	curriculum = load_json(CURRICULUM_PATH)
	rules = load_json(RULES_PATH)
	_load_items()
	note_writers = _load_writers()
	_load_notes()
	notebook = load_json(NOTEBOOK_PATH)


## Reads items.json. An entry that item_problem() rejects is reported and skipped.
func _load_items() -> void:
	items.clear()
	for entry in load_json(ITEMS_PATH).get("items", []):
		var problem := item_problem(entry, items)
		if problem != "":
			push_error("%s in %s" % [problem, ITEMS_PATH])
		else:
			items[entry["id"]] = entry


## Reads note_writers.json: writer id -> definition. An entry without an id, or a repeated id, is reported and skipped.
func _load_writers() -> Dictionary:
	var found := {}
	for entry in load_json(NOTE_WRITERS_PATH).get("writers", []):
		if not entry is Dictionary or String(entry.get("id", "")) == "" or found.has(entry["id"]):
			push_error("Bad or repeated writer in %s" % NOTE_WRITERS_PATH)
		else:
			found[entry["id"]] = entry
	return found


## Reads every data/notes/*.json (by file name) and registers each valid note as
## an item of kind "note". A note that note_problem() rejects is reported and skipped.
func _load_notes() -> void:
	notes.clear()
	var files := Array(DirAccess.get_files_at(NOTES_DIR))
	files.sort()
	for file_name: String in files:
		if not file_name.ends_with(".json"):
			continue
		for entry in load_json(NOTES_DIR + file_name).get("notes", []):
			var problem := note_problem(entry, notes, items, note_writers)
			if problem != "":
				push_error("%s in %s%s" % [problem, NOTES_DIR, file_name])
				continue
			notes[entry["id"]] = {"id": entry["id"], "writer": entry["writer"], "text": entry["text"]}
			items[entry["id"]] = {"id": entry["id"], "kind": "note", "name_ko": "", "name_en": "Note", "description_en": ""}


## Why `entry` can't be a note next to the `known` notes and the `taken` item ids,
## with the `writers` that exist, or "" if it can: a dictionary with an id no note
## or item uses, a writer id from note_writers.json, and some text.
static func note_problem(entry: Variant, known: Dictionary, taken: Dictionary, writers: Dictionary) -> String:
	if not entry is Dictionary or String(entry.get("id", "")) == "":
		return "Note without an id"
	var id := String(entry["id"])
	if known.has(id) or taken.has(id):
		return "Note id '%s' is already used by a note or an item" % id
	if not writers.has(String(entry.get("writer", ""))):
		return "Note '%s' has unknown writer '%s'" % [id, str(entry.get("writer", ""))]
	if not entry.get("text") is String or String(entry["text"]).strip_edges() == "":
		return "Note '%s' has no text" % id
	return ""


## What a new hike puts in the backpack: [{item, count}] from rules.json starting_kit.
## An entry whose item does not exist, or whose count is below 1, is reported and left out.
func starting_kit() -> Array:
	var kit: Array = []
	for entry in rules.get("starting_kit", []):
		if entry is Dictionary and has_item(String(entry.get("item", ""))) and int(entry.get("count", 0)) >= 1:
			kit.append({"item": String(entry["item"]), "count": int(entry["count"])})
		else:
			push_error("Bad starting_kit entry %s in rules.json" % str(entry))
	return kit


## Why `entry` can't be an item next to the `known` ones (id -> definition), or ""
## if it can: it must be a dictionary with a new id and a kind from ITEM_KINDS,
## and an elixir needs heal_units of at least 1. An icon is optional.
static func item_problem(entry: Variant, known: Dictionary) -> String:
	if not entry is Dictionary or String(entry.get("id", "")) == "":
		return "Item without an id"
	var id := String(entry["id"])
	if known.has(id):
		return "Item id '%s' appears twice" % id
	var kind := String(entry.get("kind", ""))
	if not ITEM_KINDS.has(kind):
		return "Item '%s' has unknown kind '%s' (want one of %s)" % [id, kind, ITEM_KINDS]
	if kind == "elixir" and int(entry.get("heal_units", 0)) < 1:
		return "Elixir '%s' needs heal_units of at least 1" % id
	if entry.has("icon") and (not entry["icon"] is String or entry["icon"] == ""):
		return "Item '%s' has an icon that is not a name" % id
	return ""


## The definition of item `id`, or {} if there is no such item.
func item(id: String) -> Dictionary:
	return items.get(id, {})


func has_item(id: String) -> bool:
	return items.has(id)


func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Can't open %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("Bad JSON in %s" % path)
	return {}


func mountain(id: String) -> Dictionary:
	if not _mountains.has(id):
		_mountains[id] = load_json(MOUNTAIN_DIR + id + ".json")
	return _mountains[id]


func game_index(id: String) -> int:
	for g in curriculum.get("games", []):
		if g["id"] == id:
			return int(g["index"])
	return -1


func game_id(index: int) -> String:
	for g in curriculum.get("games", []):
		if int(g["index"]) == index:
			return g["id"]
	return ""


## Every letter token taught up to and including game `index`.
func known_letters(index: int) -> Array[String]:
	var known: Array[String] = []
	for g in curriculum.get("games", []):
		if int(g["index"]) > index:
			continue
		for t in g["new"]:
			if not known.has(t):
				known.append(t)
	return known


## Letters introduced by game `index` only.
func new_letters(index: int) -> Array[String]:
	var letters: Array[String] = []
	for g in curriculum.get("games", []):
		if int(g["index"]) == index:
			for t in g["new"]:
				letters.append(t)
	return letters


## The first game whose letters make `word` fully readable. -1 if never.
func readable_from(word: String) -> int:
	for g in curriculum.get("games", []):
		if Hangul.is_readable(word, known_letters(int(g["index"]))):
			return int(g["index"])
	return -1


func scene(mountain_id: String, scene_id: String) -> Dictionary:
	for s in mountain(mountain_id).get("scenes", []):
		if s["id"] == scene_id:
			return s
	return {}
