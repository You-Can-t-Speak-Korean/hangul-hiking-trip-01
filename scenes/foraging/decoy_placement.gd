extends RefCounted
## Where the decoy plants stand, with no nodes. Each decoy kind has a pool of
## candidate slots in the data (foraging.decoy_placement.pools); at every scene
## start `choose()` picks as many slots per kind as that kind has plants, uniformly
## at random, and rejects a pick that breaks the spacing rules. Tries are bounded
## (`max_retries`); when they run out, or when the pools are bad, the answer is the
## fallback: the decoys' own x, z in foraging.plants.placed, which never fails.
## The random source is passed in: anything with `randi_range(from, to)`.
##
##   new(config, kinds, placed, zones, fixed, scenery, starts, half_depth)   `problem` holds the reason if the pools are bad
##   choose(rng) -> {"positions", "source", "attempts"}   positions: kind id -> Array[Vector2], in placed order
##   layout_problem(positions) -> String                  why a layout breaks the spacing rules, or ""
##   apply(plants_data, positions) -> Dictionary          a copy of foraging.plants with the decoys moved
##   seed_from_args(args) -> {"found", "seed", "problem"}  the --placement-seed=N user argument
##   blocked_by_prop(...)                                  whether a prop stands on or in front of a spot

const SEED_ARG := "--placement-seed="

## Metres (data: foraging.decoy_placement).
var same_kind_min := 4.0
var any_min := 2.0
var start_min := 6.0
var scenery_min := 2.5
var edge_margin := 1.0
var max_retries := 50
## Why the pools are bad; "" if they are usable. Bad pools always choose the fallback.
var problem := ""
## Decoy kind id -> candidate slots, and -> the fallback positions, both as Vector2 (x, z).
var pools: Dictionary = {}
var fallback: Dictionary = {}
## Decoy kind id -> how many plants it has, and the kinds in data order.
var counts: Dictionary = {}
var kind_order: Array[String] = []


## `config` is foraging.decoy_placement, `kinds` and `placed` are from foraging.plants,
## `zones` is foraging.zones. `fixed` are the points a decoy keeps `any_min` from (target
## plants, spare slots), `scenery` the ones it keeps `scenery_min` from, `starts` the
## travelers' starts. `half_depth` is half the stage depth.
func _init(config: Dictionary, kinds: Array, placed: Array, zones: Array, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float) -> void:
	same_kind_min = float(config.get("same_kind_min", same_kind_min))
	any_min = float(config.get("any_min", any_min))
	start_min = float(config.get("start_min", start_min))
	scenery_min = float(config.get("scenery_min", scenery_min))
	edge_margin = float(config.get("edge_margin", edge_margin))
	max_retries = int(config.get("max_retries", max_retries))
	var zone_of := {}
	for kind in kinds:
		if kind["kind"] != "target":
			kind_order.append(String(kind["id"]))
			zone_of[kind["id"]] = String(kind["zone"])
			counts[kind["id"]] = 0
			fallback[kind["id"]] = [] as Array[Vector2]
	for entry in placed:
		if counts.has(entry["kind"]):
			counts[entry["kind"]] += 1
			fallback[entry["kind"]].append(Vector2(float(entry["x"]), float(entry["z"])))
	problem = _pool_problem(config, zone_of, zones, fixed, scenery, starts, half_depth)


func is_valid() -> bool:
	return problem == ""


func _pool_problem(config: Dictionary, zone_of: Dictionary, zones: Array, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float) -> String:
	var raw: Variant = config.get("pools")
	if not raw is Dictionary:
		return "Decoy placement has no pools"
	for id in raw:
		if not zone_of.has(id):
			return "Pool '%s' is not a decoy kind" % id
	for id in kind_order:
		if not raw.has(id) or not raw[id] is Array:
			return "Decoy kind '%s' has no pool" % id
		var zone := {}
		for z in zones:
			if z["id"] == zone_of[id]:
				zone = z
		if zone.is_empty():
			return "Decoy kind '%s' names an unknown zone" % id
		var slots: Array[Vector2] = []
		for i in raw[id].size():
			var entry: Variant = raw[id][i]
			if not entry is Array or entry.size() != 2 or not (entry[0] is float or entry[0] is int) or not (entry[1] is float or entry[1] is int):
				return "Pool '%s' slot %d is not [x, z]" % [id, i]
			var spot := Vector2(float(entry[0]), float(entry[1]))
			if slots.has(spot):
				return "Pool '%s' has slot %d twice" % [id, i]
			slots.append(spot)
			var why := _slot_problem(spot, zone, fixed, scenery, starts, half_depth)
			if why != "":
				return "Pool '%s' slot %d %s" % [id, i, why]
		if slots.size() < int(counts[id]):
			return "Pool '%s' has %d slots for %d plants" % [id, slots.size(), counts[id]]
		pools[id] = slots
	return ""


## Why a spot can't be a decoy slot in `zone` (a zone entry), or "".
func _slot_problem(spot: Vector2, zone: Dictionary, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float) -> String:
	if spot.x < float(zone["x"][0]) + edge_margin or spot.x > float(zone["x"][1]) - edge_margin:
		return "is outside zone %s" % zone["id"]
	if absf(spot.y) > half_depth - edge_margin:
		return "is off the stage"
	for point in fixed:
		if spot.distance_to(point) < any_min:
			return "is within %.1f m of a plant or spare slot" % any_min
	for point in scenery:
		if spot.distance_to(point) < scenery_min:
			return "is within %.1f m of a tree" % scenery_min
	for point in starts:
		if spot.distance_to(point) < start_min:
			return "is within %.1f m of a start" % start_min
	return ""


## Why `positions` (kind id -> Array[Vector2]) breaks the spacing between decoys, or "":
## two of one kind need `same_kind_min`, any two need `any_min`.
func layout_problem(positions: Dictionary) -> String:
	var all: Array[Dictionary] = []
	for id in positions:
		for spot in positions[id]:
			all.append({"kind": id, "spot": spot})
	for i in all.size():
		for j in range(i + 1, all.size()):
			var d: float = all[i]["spot"].distance_to(all[j]["spot"])
			if d < any_min:
				return "%s and %s are %.2f m apart" % [all[i]["kind"], all[j]["kind"], d]
			if all[i]["kind"] == all[j]["kind"] and d < same_kind_min:
				return "two %s are %.2f m apart" % [all[i]["kind"], d]
	return ""


## One layout: {"positions", "source" ("random" | "fallback" | "bad pools"), "attempts"}.
## Draws only from `rng`, tries at most `max_retries` layouts, never fails.
func choose(rng: Object) -> Dictionary:
	if problem != "":
		return {"positions": _fallback_copy(), "source": "bad pools", "attempts": 0}
	for attempt in max_retries:
		var picked := {}
		for id in kind_order:
			picked[id] = _sample(pools[id], int(counts[id]), rng)
		if layout_problem(picked) == "":
			return {"positions": picked, "source": "random", "attempts": attempt + 1}
	return {"positions": _fallback_copy(), "source": "fallback", "attempts": max_retries}


## `count` distinct entries of `slots`, uniformly (a partial shuffle).
func _sample(slots: Array, count: int, rng: Object) -> Array[Vector2]:
	var rest := slots.duplicate()
	var out: Array[Vector2] = []
	for n in count:
		var i: int = rng.randi_range(0, rest.size() - 1)
		out.append(rest[i])
		rest.remove_at(i)
	return out


func _fallback_copy() -> Dictionary:
	var copy := {}
	for id in fallback:
		copy[id] = (fallback[id] as Array[Vector2]).duplicate()
	return copy


## A deep copy of foraging.plants whose decoy entries stand at `positions`
## (kind id -> spots, in placed order). Letters, order and everything else are kept.
func apply(plants_data: Dictionary, positions: Dictionary) -> Dictionary:
	var copy: Dictionary = plants_data.duplicate(true)
	var used := {}
	for entry in copy["placed"]:
		var id: String = entry["kind"]
		if not positions.has(id):
			continue
		var n: int = used.get(id, 0)
		used[id] = n + 1
		var spot: Vector2 = positions[id][n]
		entry["x"] = spot.x
		entry["z"] = spot.y
	return copy


## The user argument --placement-seed=N: {"found", "seed", "problem"}. N is a whole
## number (a randomized seed can be negative: the printed one works as it is);
## anything else is a problem (and not found).
static func seed_from_args(args: PackedStringArray) -> Dictionary:
	for arg in args:
		if arg.begins_with(SEED_ARG):
			var text := arg.substr(SEED_ARG.length())
			if text.is_valid_int():
				return {"found": true, "seed": text.to_int(), "problem": ""}
			return {"found": false, "seed": 0, "problem": "'%s' is not a whole number" % text}
	return {"found": false, "seed": 0, "problem": ""}


## A second seed fixed by the first (the piles use one, so one seed fixes both).
static func derive_seed(seed_value: int, salt: int) -> int:
	return seed_value * 2654435761 + salt * 40503 + 12345


## True if a prop stands on a spot or in front of it. `props` are the props'
## world boxes. A plant's footprint is `footprint` m around the spot; the plant is
## hidden if a prop box blocks the view from the camera to a point `letter_height`
## m above the ground (the camera looks along (0, sin pitch, cos pitch) toward the
## scene, `reach` m is as far as a prop can matter).
static func blocked_by_prop(spot: Vector2, ground_y: float, props: Array, pitch_deg: float, footprint: float, letter_height: float, reach: float) -> bool:
	var toward := Vector3(0.0, sin(deg_to_rad(pitch_deg)), cos(deg_to_rad(pitch_deg)))
	var from := Vector3(spot.x, ground_y + letter_height, spot.y)
	for box: AABB in props:
		var area := Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(footprint)
		if area.has_point(spot):
			return true
		if box.grow(footprint * 0.5).intersects_segment(from, from + toward * reach) != null:
			return true
	return false
