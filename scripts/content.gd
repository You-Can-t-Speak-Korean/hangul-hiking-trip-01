extends Node
## Loads the series data files. Every mountain is data, not code:
## a new game = a new data/mountains/<id>.json plus art and audio.

const CURRICULUM_PATH := "res://data/series/curriculum.json"
const RULES_PATH := "res://data/series/rules.json"
const MOUNTAIN_DIR := "res://data/mountains/"

var curriculum: Dictionary = {}
var rules: Dictionary = {}
var _mountains: Dictionary = {}


func _ready() -> void:
	curriculum = load_json(CURRICULUM_PATH)
	rules = load_json(RULES_PATH)


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
