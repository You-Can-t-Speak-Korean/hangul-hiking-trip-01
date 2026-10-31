extends RefCounted
## What a reward decoy gives: a weighted table of {item, weight, count}, with no
## nodes. The random source is passed in, so a test can pin a seed or force an
## outcome: anything with `randi_range(from, to)` (inclusive) works, such as a
## RandomNumberGenerator.
##
##   problem_with(entries, items) -> String   why the table is bad, or ""
##   new(entries, items)                            `problem` holds the reason if it is bad
##   roll(rng) -> Dictionary                         {item, count}; {} if the table is bad

## Why the table is bad; "" if it is usable. A bad table rolls nothing.
var problem := ""

var _entries: Array = []
var _total := 0


## `items` is the known items, id -> definition (Content.items).
@warning_ignore("shadowed_variable")
func _init(entries: Variant, items: Dictionary) -> void:
	problem = problem_with(entries, items)
	if problem != "":
		return
	_entries = entries
	for entry in _entries:
		_total += int(entry["weight"])


## Why `entries` can't be a reward table over the known `items`, or "" if it can:
## a non-empty array of dictionaries whose item exists, whose weight is a whole
## number above 0 and whose count is a whole number of at least 1.
static func problem_with(entries: Variant, items: Dictionary) -> String:
	if not entries is Array or entries.is_empty():
		return "Reward table is empty"
	for i in entries.size():
		var entry: Variant = entries[i]
		if not entry is Dictionary:
			return "Reward entry %d is not a dictionary" % i
		var id := String(entry.get("item", ""))
		if not items.has(id):
			return "Reward entry %d has unknown item '%s'" % [i, id]
		if not _is_whole(entry.get("weight")) or int(entry["weight"]) <= 0:
			return "Reward entry %d ('%s') needs a whole weight above 0, not %s" % [i, id, str(entry.get("weight"))]
		if not _is_whole(entry.get("count")) or int(entry["count"]) < 1:
			return "Reward entry %d ('%s') needs a whole count of at least 1, not %s" % [i, id, str(entry.get("count"))]
	return ""


static func _is_whole(value: Variant) -> bool:
	return (value is int) or (value is float and value == floorf(value))


func is_valid() -> bool:
	return problem == ""


func total_weight() -> int:
	return _total


## One weighted pick: {"item", "count"}. {} for a bad table.
func roll(rng: Object) -> Dictionary:
	if problem != "":
		return {}
	var r: int = rng.randi_range(1, _total)
	for entry in _entries:
		r -= int(entry["weight"])
		if r <= 0:
			return {"item": String(entry["item"]), "count": int(entry["count"])}
	var last: Dictionary = _entries[_entries.size() - 1]  # an rng outside 1.._total
	return {"item": String(last["item"]), "count": int(last["count"])}
