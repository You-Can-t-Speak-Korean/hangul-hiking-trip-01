extends RefCounted
## The discovery list's logic, with no drawing. A target kind is discovered when
## a traveler comes within `radius` metres (horizontal) of any plant of that
## kind; decoys never make an entry. Discovered kinds stay for the life of this
## object, so a new Discovery (a scene restart) starts empty.

## Metres a traveler must be within, and seconds a new entry takes to fade in
## (data: foraging.discovery).
var radius := 3.0
var fade_time := 0.4
## Entries in the order discovered: {"id", "hover_name", "syllables", "age"}.
## They hold no Korean text and no letters.
var entries: Array[Dictionary] = []

var _kinds: Array[Dictionary] = []  # target kinds still to find: {"id", "hover_name", "syllables", "spots"}


## `config` is foraging.discovery, `plants_data` is foraging.plants.
func _init(config: Dictionary, plants_data: Dictionary) -> void:
	radius = float(config["radius"])
	fade_time = float(config["fade_time"])
	for kind in plants_data["kinds"]:
		if kind["kind"] != "target":
			continue
		var spots: Array[Vector2] = []
		for entry in plants_data["placed"]:
			if entry["kind"] == kind["id"]:
				spots.append(Vector2(float(entry["x"]), float(entry["z"])))
		_kinds.append({
			"id": kind["id"],
			"hover_name": kind["hover_name"],
			"syllables": Hangul.syllable_count(kind["name"]),
			"spots": spots,
		})


## One tick. `travelers` are the travelers' positions as Vector2s over (x, z).
## Returns the ids discovered this tick.
func update(travelers: Array, delta: float) -> Array[String]:
	for entry in entries:
		entry["age"] += delta
	var found: Array[String] = []
	for kind in _kinds.duplicate():
		if _is_near(kind["spots"], travelers):
			found.append(kind["id"])
			entries.append({"id": kind["id"], "hover_name": kind["hover_name"], "syllables": kind["syllables"], "age": 0.0})
			_kinds.erase(kind)
	return found


func _is_near(spots: Array, travelers: Array) -> bool:
	for spot in spots:
		for traveler in travelers:
			if spot.distance_to(traveler) <= radius:
				return true
	return false


func is_discovered(id: String) -> bool:
	return discovered_ids().has(id)


func discovered_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry in entries:
		ids.append(entry["id"])
	return ids


## 0..1: how far an entry has faded in.
func opacity(entry: Dictionary) -> float:
	return clampf(float(entry["age"]) / maxf(fade_time, 0.001), 0.0, 1.0)
