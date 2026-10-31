extends Node
## Loads the series data files. Every mountain is data, not code:
## a new game = a new data/mountains/<id>.json plus art and audio.

const CURRICULUM_PATH := "res://data/series/curriculum.json"
const RULES_PATH := "res://data/series/rules.json"
const ITEMS_PATH := "res://data/series/items.json"
const MOUNTAIN_DIR := "res://data/mountains/"
const ITEM_KINDS: Array[String] = ["elixir", "charm", "hint", "note"]

var curriculum: Dictionary = {}
var rules: Dictionary = {}
## Item id -> its definition, in file order (see items.json).
var items: Dictionary = {}
var _mountains: Dictionary = {}


func _ready() -> void:
	curriculum = load_json(CURRICULUM_PATH)
	rules = load_json(RULES_PATH)
	_load_items()


## Reads items.json. An entry that item_problem() rejects is reported and skipped.
func _load_items() -> void:
	items.clear()
	for entry in load_json(ITEMS_PATH).get("items", []):
		var problem := item_problem(entry, items)
		if problem != "":
			push_error("%s in %s" % [problem, ITEMS_PATH])
		else:
			items[entry["id"]] = entry


## Why `entry` can't be an item next to the `known` ones (id -> definition), or ""
## if it can: it must be a dictionary with a new id and a kind from ITEM_KINDS,
## and an elixir needs heal_units of at least 1.
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
