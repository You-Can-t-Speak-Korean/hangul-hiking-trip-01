extends RefCounted
## Chaos DDEOK piles, with no nodes: small pickups lying around the map. At every
## scene start `roll()` draws how many piles appear (count_table, 0 allowed), puts
## them on that many candidate slots chosen uniformly (slots too near a plant,
## a start or another pile are skipped) and draws each pile's DDEOK amount
## (amount_table). The random source is passed in: anything with `randi_range`.
## A bad config or table makes `problem` non-empty and `roll()` return no piles.
##
##   new(config, targets, fixed, decoy_slots, scenery, starts, zones, half_depth, items)
##   roll(rng, plants, starts) -> Array[Dictionary]   [{"spot": Vector2, "amount": int}]
##   table_problem(entries, key, lowest) -> String    why a weighted table is bad, or ""

## Metres and counts (data: foraging.chaos_piles).
var min_plant := 2.0
var min_start := 6.0
var min_pile := 2.0
var edge_margin := 1.0
var off_path_distance := 8.0
var off_path_min_slots := 4
var item_id := "ddeok"
var problem := ""
var slots: Array[Vector2] = []

var _count_table: Array = []
var _amount_table: Array = []


## `config` is foraging.chaos_piles. `targets` are the target plants, `fixed` every point
## a pile keeps `min_plant` from that does not move (targets, spare slots), `decoy_slots`
## every candidate slot of every decoy pool (so any decoy layout is clear), `scenery`
## the trees, `starts` the travelers' starts, `zones` foraging.zones, `items` Content.items.
func _init(config: Dictionary, targets: Array[Vector2], fixed: Array[Vector2], decoy_slots: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], zones: Array, half_depth: float, items: Dictionary) -> void:
	if config.is_empty():
		problem = "No chaos_piles data"
		return
	min_plant = float(config.get("min_plant", min_plant))
	min_start = float(config.get("min_start", min_start))
	min_pile = float(config.get("min_pile", min_pile))
	edge_margin = float(config.get("edge_margin", edge_margin))
	item_id = String(config.get("item", item_id))
	var off: Dictionary = config.get("off_path", {})
	off_path_distance = float(off.get("distance", off_path_distance))
	off_path_min_slots = int(off.get("min_slots", off_path_min_slots))
	_count_table = config.get("count_table", []) if config.get("count_table") is Array else []
	_amount_table = config.get("amount_table", []) if config.get("amount_table") is Array else []
	problem = table_problem(_count_table, "count", 0)
	if problem == "":
		problem = table_problem(_amount_table, "amount", 1)
	if problem == "" and not items.has(item_id):
		problem = "Chaos pile item '%s' is unknown" % item_id
	if problem == "":
		problem = _slot_problem(config.get("slots"), targets, fixed, decoy_slots, scenery, starts, zones, half_depth)
	if problem == "":
		var most := 0
		for entry in _count_table:
			most = maxi(most, int(entry["count"]))
		if slots.size() < most:
			problem = "Chaos piles have %d slots but a roll can ask for %d" % [slots.size(), most]


func is_valid() -> bool:
	return problem == ""


## Why `entries` can't be a weighted table of {key, weight}: nonempty dictionaries
## whose weight is a whole number above 0 and whose `key` is a whole number of at least `lowest`.
static func table_problem(entries: Variant, key: String, lowest: int) -> String:
	if not entries is Array or entries.is_empty():
		return "The %s table is empty" % key
	for i in entries.size():
		var entry: Variant = entries[i]
		if not entry is Dictionary:
			return "The %s table entry %d is not a dictionary" % [key, i]
		if not _is_whole(entry.get("weight")) or int(entry["weight"]) <= 0:
			return "The %s table entry %d needs a whole weight above 0, not %s" % [key, i, str(entry.get("weight"))]
		if not _is_whole(entry.get(key)) or int(entry[key]) < lowest:
			return "The %s table entry %d needs a whole %s of at least %d, not %s" % [key, i, key, lowest, str(entry.get(key))]
	return ""


static func _is_whole(value: Variant) -> bool:
	return (value is int) or (value is float and value == floorf(value))


func _slot_problem(raw: Variant, targets: Array[Vector2], fixed: Array[Vector2], decoy_slots: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], zones: Array, half_depth: float) -> String:
	if not raw is Array or raw.is_empty():
		return "Chaos piles have no slots"
	var in_zone := {}
	var off_path := 0
	for i in raw.size():
		var entry: Variant = raw[i]
		if not entry is Array or entry.size() != 2 or not (entry[0] is float or entry[0] is int) or not (entry[1] is float or entry[1] is int):
			return "Chaos pile slot %d is not [x, z]" % i
		var spot := Vector2(float(entry[0]), float(entry[1]))
		if slots.has(spot):
			return "Chaos pile slot %d appears twice" % i
		slots.append(spot)
		var zone := _zone_of(spot.x, zones)
		if zone.is_empty() or spot.x < float(zones[0]["x"][0]) + edge_margin or spot.x > float(zones[zones.size() - 1]["x"][1]) - edge_margin:
			return "Chaos pile slot %d is off the map" % i
		in_zone[zone["id"]] = true
		if absf(spot.y) > half_depth - edge_margin:
			return "Chaos pile slot %d is off the stage" % i
		for point in fixed + decoy_slots:
			if spot.distance_to(point) < min_plant:
				return "Chaos pile slot %d is within %.1f m of a plant, spare slot or decoy slot" % [i, min_plant]
		for point in scenery:
			if spot.distance_to(point) < min_plant + 0.5:
				return "Chaos pile slot %d is within %.1f m of a tree" % [i, min_plant + 0.5]
		for point in starts:
			if spot.distance_to(point) < min_start:
				return "Chaos pile slot %d is within %.1f m of a start" % [i, min_start]
		var far := true
		for point in targets:
			if spot.distance_to(point) < off_path_distance:
				far = false
		if far:
			off_path += 1
	for zone in zones:
		if not in_zone.has(zone["id"]):
			return "Chaos piles have no slot in zone %s" % zone["id"]
	if off_path < off_path_min_slots:
		return "Only %d chaos pile slots are %.0f m from every target, %d wanted" % [off_path, off_path_distance, off_path_min_slots]
	return ""


func _zone_of(x: float, zones: Array) -> Dictionary:
	for zone in zones:
		if x < float(zone["x"][1]):
			return zone
	return zones[zones.size() - 1] if not zones.is_empty() else {}


## The piles of one scene start: [{"spot", "amount"}]. `plants` are every plant's
## (x, z) as it stands now (decoys included), `starts` the travelers' starts. Draws only
## from `rng`: first the count, then the slots, then one amount per pile. If fewer
## slots are clear than the count asked for, fewer piles appear.
func roll(rng: Object, plants: Array[Vector2], starts: Array[Vector2]) -> Array[Dictionary]:
	var piles: Array[Dictionary] = []
	if problem != "":
		return piles
	var wanted := _weighted(_count_table, "count", rng)
	var open: Array[Vector2] = []
	for spot in slots:
		var clear := true
		for point in plants:
			clear = clear and spot.distance_to(point) >= min_plant
		for point in starts:
			clear = clear and spot.distance_to(point) >= min_start
		if clear:
			open.append(spot)
	while piles.size() < wanted and not open.is_empty():
		var i: int = rng.randi_range(0, open.size() - 1)
		var spot := open[i]
		open.remove_at(i)
		var apart := true
		for pile in piles:
			apart = apart and spot.distance_to(pile["spot"]) >= min_pile
		if apart:
			piles.append({"spot": spot, "amount": 0})
	for pile in piles:
		pile["amount"] = _weighted(_amount_table, "amount", rng)
	return piles


## One weighted draw: the `key` of the entry r falls in, r uniform in 1..total weight.
func _weighted(entries: Array, key: String, rng: Object) -> int:
	var total := 0
	for entry in entries:
		total += int(entry["weight"])
	var r: int = rng.randi_range(1, total)
	for entry in entries:
		r -= int(entry["weight"])
		if r <= 0:
			return int(entry[key])
	return int(entries[entries.size() - 1][key])
