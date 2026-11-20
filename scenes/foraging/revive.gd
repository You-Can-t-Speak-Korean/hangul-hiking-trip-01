extends RefCounted
## Downed travelers and reviving them, with no nodes, shared by the foraging and animal scenes
## (data: rules.json `revive`). A traveler at 0 hearts is downed (GameState.is_downed). The
## standing traveler within radius_m presses pick, which starts a channel_s seconds channel; it
## uses one healing item (the first held of the elixirs in items.json order: 쌍화탕, then
## 공진단) and stands the downed traveler up with that item's heal_units. Leaving the radius,
## or taking damage, cancels the channel. With bleed_out_s > 0 a traveler downed that long
## without a revive counts as dead and the scene ends (0 = off).
##
## Positions are passed in as {traveler id: Vector2 over (x, z)}; the scene does the pose,
## the labels and the control switch from the events tick() returns:
##   {"event": "revived", "id", "item", "units"}
##   {"event": "cancelled", "id", "why": "range" | "damage" | "gone" | "no_item"}
##   {"event": "bled_out", "id"}

var radius_m := 1.2
var channel_s := 1.5
var bleed_out_s := 0.0
var note_s := 2.0
var leave_note_format := "Revive %s before you leave."

## The downed traveler being revived ("" = none) and who is doing it.
var target := ""
var rescuer := ""
var channel_left := 0.0
## The one-line note ("No 쌍화탕 or 공진단 to revive.") and the seconds it has left.
var note := ""
var note_left := 0.0

var _units_at_start := 0
var _down_time: Dictionary = {}  # traveler id -> seconds downed
var _bled: Dictionary = {}       # traveler id -> true once bled_out was reported


func _init(config: Dictionary = {}) -> void:
	radius_m = float(config.get("radius_m", radius_m))
	channel_s = float(config.get("channel_s", channel_s))
	bleed_out_s = float(config.get("bleed_out_s", bleed_out_s))
	note_s = float(config.get("note_s", note_s))
	leave_note_format = String(config.get("leave_note", leave_note_format))


## The exit gate (both scenes): scene exits may not fire while any traveler is downed.
static func can_leave() -> bool:
	for id in GameState.TRAVELERS:
		if GameState.is_downed(id):
			return false
	return true


## The first downed traveler's id ("" if nobody is downed).
static func first_downed() -> String:
	for id in GameState.TRAVELERS:
		if GameState.is_downed(id):
			return id
	return ""


## An exit was tried: if someone is downed, shows "Revive Nestor before you leave." for note_s
## seconds and returns true (the exit must not fire); false if the way is clear.
func block_leave() -> bool:
	var id := first_downed()
	if id == "":
		return false
	note = leave_note_format % id.capitalize()
	note_left = note_s
	return true


## The healing items in the order they are used (items.json order), by id.
static func healing_items() -> Array[String]:
	var list: Array[String] = []
	for id in Content.items:
		var entry: Dictionary = Content.items[id]
		if String(entry.get("kind", "")) == "elixir" and int(entry.get("heal_units", 0)) > 0:
			list.append(String(id))
	return list


## The item a revive would use now (the backpack's first healing item), or "" if it holds none.
static func next_item() -> String:
	for id in healing_items():
		if GameState.inventory.count(id) > 0:
			return id
	return ""


## "No 쌍화탕 or 공진단 to revive."
static func no_item_text() -> String:
	var names: Array[String] = []
	for id in healing_items():
		names.append(String(Content.item(id)["name_ko"]))
	return "No %s to revive." % " or ".join(names)


## The nearest downed traveler within radius_m of `rescuer_id`, or "" (also "" if the rescuer
## is downed themselves).
func downed_near(rescuer_id: String, positions: Dictionary) -> String:
	if rescuer_id == "" or GameState.is_downed(rescuer_id) or not positions.has(rescuer_id):
		return ""
	var best := ""
	var best_distance := INF
	for id in GameState.TRAVELERS:
		if id == rescuer_id or not GameState.is_downed(id) or not positions.has(id):
			continue
		var distance: float = (positions[rescuer_id] as Vector2).distance_to(positions[id])
		if distance <= radius_m and distance < best_distance:
			best = id
			best_distance = distance
	return best


func is_channeling() -> bool:
	return target != ""


## 0..1 through the channel (0 when none).
func progress() -> float:
	if target == "" or channel_s <= 0.0:
		return 0.0
	return clampf(1.0 - channel_left / channel_s, 0.0, 1.0)


## Seconds a traveler has been downed (0 if standing).
func downed_for(id: String) -> float:
	return float(_down_time.get(id, 0.0))


## The pick action. "none" = nobody downed within range (the scene picks or grabs as usual);
## "busy" = a channel is running already; "no_item" = the note is up and nothing else happened;
## "started" = the channel runs.
func press(rescuer_id: String, positions: Dictionary) -> String:
	var near := downed_near(rescuer_id, positions)
	if near == "":
		return "none"
	if target != "":
		return "busy"
	if next_item() == "":
		note = no_item_text()
		note_left = note_s
		return "no_item"
	target = near
	rescuer = rescuer_id
	channel_left = channel_s
	_units_at_start = int(GameState.heart_units[rescuer_id])
	return "started"


## Stops the channel (no event).
func cancel() -> void:
	target = ""
	rescuer = ""
	channel_left = 0.0


## One tick: the bleed-out clocks, the note, the channel. `rescuer_id` is who is standing and
## in control now. Returns the events (see above).
func tick(delta: float, rescuer_id: String, positions: Dictionary) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if note_left > 0.0:
		note_left = maxf(note_left - delta, 0.0)
		if note_left == 0.0:
			note = ""
	for id in GameState.TRAVELERS:
		if not GameState.is_downed(id):
			_down_time.erase(id)
			_bled.erase(id)
			continue
		_down_time[id] = float(_down_time.get(id, 0.0)) + delta
		if bleed_out_s > 0.0 and float(_down_time[id]) >= bleed_out_s and not _bled.has(id):
			_bled[id] = true
			events.append({"event": "bled_out", "id": id})
	if target == "":
		return events
	var down := target
	var why := ""
	if not GameState.is_downed(down):
		why = "gone"
	elif GameState.is_downed(rescuer) or int(GameState.heart_units[rescuer]) < _units_at_start:
		why = "damage"
	elif rescuer_id != rescuer or not positions.has(rescuer) or not positions.has(down) \
			or (positions[rescuer] as Vector2).distance_to(positions[down]) > radius_m:
		why = "range"
	if why != "":
		cancel()
		events.append({"event": "cancelled", "id": down, "why": why})
		return events
	channel_left -= delta
	if channel_left > 0.0:
		return events
	var item := next_item()
	if item == "":  # the last bottle went while the channel ran
		cancel()
		events.append({"event": "cancelled", "id": down, "why": "no_item"})
		return events
	var units := int(Content.item(item)["heal_units"])
	GameState.inventory.remove(item)
	GameState.revive(down, units)
	cancel()
	events.append({"event": "revived", "id": down, "item": item, "units": units})
	return events


## Who the solo player controls now: the controlled traveler, or their partner if the
## controlled one is downed and the partner is not. (Both downed: unchanged.)
static func controller() -> String:
	var who: String = GameState.controlled
	if GameState.is_downed(who) and not GameState.is_downed(GameState.partner_of(who)):
		return GameState.partner_of(who)
	return who
