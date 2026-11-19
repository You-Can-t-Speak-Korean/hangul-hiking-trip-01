extends RefCounted
## The breakable tools the travelers carry (items.json kind "tool"), with no nodes. Unlike the
## counted items of Inventory every tool is its own instance with its own uses left, so two
## 집게 wear out separately. One tool is equipped at a time, or none ("Hands").
##
##   add(item_id) -> int            the new instance's uid (> 0), 0 for an id that is not a tool
##   remove(uid) -> bool            a removed equipped tool leaves Hands equipped
##   count(item_id) -> int
##   tools() -> Array               [{uid, id, uses}] in the order they were added (copies)
##   get_tool(uid) -> Dictionary    {} if there is none
##   equip(uid) -> bool             uid 0 = Hands; false for a uid that is not held (or broken)
##   equipped() -> Dictionary       the equipped instance, {} for Hands
##   cycle() -> int                 Hands -> each held tool in order -> Hands ...; returns the new uid
##   spend(uid, n) -> Dictionary    {"left", "broke", "id"}; at 0 the tool is removed
##   snapshot() / restore(snap)     what GameState keeps for a scene restart and the next scene
##   signal changed                 after every change

signal changed

var _tools: Array[Dictionary] = []
var _next_uid := 1
var _equipped_uid := 0


func add(item_id: String) -> int:
	var def: Dictionary = Content.item(item_id)
	if def.is_empty() or def.get("kind", "") != "tool":
		return 0
	var uid := _next_uid
	_next_uid += 1
	_tools.append({"uid": uid, "id": item_id, "uses": int(def["uses"])})
	changed.emit()
	return uid


func remove(uid: int) -> bool:
	var at := _index_of(uid)
	if at < 0:
		return false
	_tools.remove_at(at)
	if _equipped_uid == uid:
		_equipped_uid = 0
	changed.emit()
	return true


func count(item_id: String) -> int:
	var n := 0
	for entry in _tools:
		if entry["id"] == item_id:
			n += 1
	return n


func is_empty() -> bool:
	return _tools.is_empty()


func tools() -> Array:
	var list: Array = []
	for entry in _tools:
		list.append(entry.duplicate())
	return list


func get_tool(uid: int) -> Dictionary:
	var at := _index_of(uid)
	return _tools[at].duplicate() if at >= 0 else {}


func equipped_uid() -> int:
	return _equipped_uid


func equipped() -> Dictionary:
	return get_tool(_equipped_uid) if _equipped_uid > 0 else {}


func equip(uid: int) -> bool:
	if uid != 0:
		var at := _index_of(uid)
		if at < 0 or int(_tools[at]["uses"]) <= 0:
			return false
	if uid == _equipped_uid:
		return true
	_equipped_uid = uid
	changed.emit()
	return true


## The next stop of Hands, tool 1, tool 2, ... (a tool with no uses left is skipped). With no
## tool held it stays on Hands. Returns the uid now equipped (0 = Hands).
func cycle() -> int:
	var stops: Array[int] = [0]
	for entry in _tools:
		if int(entry["uses"]) > 0:
			stops.append(int(entry["uid"]))
	var at := stops.find(_equipped_uid)
	var next: int = stops[(at + 1) % stops.size()] if at >= 0 else 0
	equip(next)
	return next


## Takes `n` uses off a tool (at least 1). At 0 it is removed. {} for a uid that is not held.
func spend(uid: int, n := 1) -> Dictionary:
	var at := _index_of(uid)
	if at < 0:
		return {}
	var id := String(_tools[at]["id"])
	var left := maxi(int(_tools[at]["uses"]) - maxi(n, 1), 0)
	_tools[at]["uses"] = left
	if left <= 0:
		remove(uid)
		return {"left": 0, "broke": true, "id": id}
	changed.emit()
	return {"left": left, "broke": false, "id": id}


func snapshot() -> Dictionary:
	return {"tools": tools(), "equipped": _equipped_uid, "next": _next_uid}


## Puts back what snapshot() returned. An invalid snapshot changes nothing (false).
func restore(snap: Dictionary) -> bool:
	var list: Array[Dictionary] = []
	var top := 0
	for entry in snap.get("tools", []):
		if not entry is Dictionary or not Content.has_item(String(entry.get("id", ""))) or int(entry.get("uses", 0)) < 1:
			return false
		list.append({"uid": int(entry["uid"]), "id": String(entry["id"]), "uses": int(entry["uses"])})
		top = maxi(top, int(entry["uid"]))
	_tools = list
	_next_uid = maxi(int(snap.get("next", 1)), top + 1)
	_equipped_uid = int(snap.get("equipped", 0))
	if _equipped_uid > 0 and _index_of(_equipped_uid) < 0:
		_equipped_uid = 0
	changed.emit()
	return true


func clear() -> void:
	_tools.clear()
	_equipped_uid = 0
	changed.emit()


func _index_of(uid: int) -> int:
	for i in _tools.size():
		if int(_tools[i]["uid"]) == uid:
			return i
	return -1
