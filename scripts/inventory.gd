class_name Inventory
extends RefCounted
## A bag of items: item id -> count. No nodes, no scene knowledge. This is the
## storage interface: the in-memory bag here and a future on-chain store must
## offer the same methods and the same signal, so keep it small.
##
##   add(item_id, count := 1) -> bool      false for an unknown id or count < 1
##   remove(item_id, count := 1) -> bool  false (and nothing changes) if fewer are held
##   count(item_id) -> int
##   items() -> Array                     [{id, count}], in the order the items were first added
##   is_empty() -> bool
##   snapshot() -> Dictionary             a copy of the contents, order included
##   restore(snap) -> bool                replaces the contents exactly; false (nothing changes) if snap is invalid
##   clear()
##   signal changed                       after add, remove, restore and clear
##
## Ids are checked against Content.items. There is no per-item cap. An item that
## drops to 0 is forgotten: adding it again puts it at the end of the order.
## `last_error` holds the reason the latest call returned false ("" otherwise); an
## unknown id passed to add() is also reported with push_error.

signal changed

var last_error := ""

var _counts: Dictionary = {}  # item id -> count (> 0), in insertion order


@warning_ignore("shadowed_variable")
func add(item_id: String, count := 1) -> bool:
	last_error = ""
	if not Content.has_item(item_id):
		return _fail("Unknown item id '%s'" % item_id, true)
	if count < 1:
		return _fail("Can't add %d of '%s'" % [count, item_id])
	_counts[item_id] = int(_counts.get(item_id, 0)) + count
	changed.emit()
	return true


@warning_ignore("shadowed_variable")
func remove(item_id: String, count := 1) -> bool:
	last_error = ""
	if count < 1:
		return _fail("Can't remove %d of '%s'" % [count, item_id])
	var held := self.count(item_id)
	if held < count:
		return _fail("Can't remove %d of '%s', only %d held" % [count, item_id, held])
	if held == count:
		_counts.erase(item_id)
	else:
		_counts[item_id] = held - count
	changed.emit()
	return true


func count(item_id: String) -> int:
	return int(_counts.get(item_id, 0))


func items() -> Array:
	var list: Array = []
	for id in _counts:
		list.append({"id": id, "count": _counts[id]})
	return list


func is_empty() -> bool:
	return _counts.is_empty()


func snapshot() -> Dictionary:
	return _counts.duplicate()


## `snap` is what snapshot() returned: item id -> count. Every id must be a known
## item and every count a whole number of at least 1, else nothing is restored.
func restore(snap: Dictionary) -> bool:
	last_error = ""
	var counts := {}
	for id in snap:
		if not id is String or not Content.has_item(id):
			return _fail("Can't restore unknown item id '%s'" % str(id))
		if not snap[id] is int or snap[id] < 1:
			return _fail("Can't restore %s of '%s'" % [str(snap[id]), id])
		counts[id] = snap[id]
	_counts = counts
	changed.emit()
	return true


func clear() -> void:
	if _counts.is_empty():
		return
	_counts.clear()
	changed.emit()


func _fail(reason: String, report := false) -> bool:
	last_error = reason
	if report:
		push_error("Inventory: " + reason)
	return false
