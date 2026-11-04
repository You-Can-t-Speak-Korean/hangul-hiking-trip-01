extends RefCounted
## The decoy plants of one scene start, with no nodes. At every scene start `choose()`
## rolls, in this order: how many decoys there are (uniform over count_min..count_max),
## which distinct slots of the ONE shared slot list they stand on (uniform), and then
## for each decoy its kind (kind_weights), its outcome (outcome_weights: harm or
## reward, independent of the kind) and its letter (uniform over the jamo of the
## target words). Slots are validated at load, so every pick is valid by construction;
## a pick that still breaks the spacing is retried (bounded by `max_retries`) and
## then replaced by the fallback: the decoys' own kinds, letters and x, z in
## foraging.plants.placed, which never fails (their outcomes are still rolled).
## The random source is passed in: anything with `randi_range(from, to)`.
##
##   new(config, kinds, placed, fixed, scenery, starts, half_depth, stage_width, letters)   `problem` holds the reason if the data is bad
##   choose(rng) -> {"decoys", "source", "attempts"}   decoys: Array of {"kind", "spot", "outcome", "letter"}
##   layout_problem(decoys) -> String                  why a layout breaks the spacing rules, or ""
##   apply(plants_data, decoys) -> Dictionary          a copy of foraging.plants with the decoys in place
##   fallback_decoys(outcomes) -> Array                the fallback layout with the given kind -> outcome
##   target_jamo(kinds) -> Array[String]               the jamo of the target words (static)
##   seed_from_args(args) -> {"found", "seed", "problem"}  the --placement-seed=N user argument
##   blocked_by_prop(...)                                  whether a prop stands on or in front of a spot

const SEED_ARG := "--placement-seed="
const OUTCOMES: Array[String] = ["harm", "reward"]

## Metres and counts (data: foraging.decoy_placement).
var any_min := 2.0
var start_min := 6.0
var scenery_min := 2.5
var edge_margin := 1.0
var max_retries := 50
var count_min := 2
var count_max := 16
## Half-units one harm outcome costs the picker (1 = half a heart).
var damage_units := 1
## Why the data is bad; "" if it is usable. Bad data always chooses the fallback.
var problem := ""
## The shared candidate slots as Vector2 (x, z).
var slots: Array[Vector2] = []
## The jamo a decoy's letter is drawn from.
var letters: Array[String] = []
## Decoy kind ids in data order, and their weights as whole numbers.
var kind_order: Array[String] = []
var kind_weights: Dictionary = {}
var outcome_weights: Dictionary = {"harm": 1, "reward": 1}
## The decoys foraging.plants.placed has: {"kind", "spot", "letter"}.
var fallback: Array[Dictionary] = []


## `config` is foraging.decoy_placement, `kinds` and `placed` are from foraging.plants.
## `fixed` are the points a decoy keeps `any_min` from (target plants, spare slots),
## `scenery` the ones it keeps `scenery_min` from, `starts` the travelers' starts.
## `half_depth` is half the stage depth, `stage_width` its width, `letters` the jamo
## to draw from (see target_jamo()).
func _init(config: Dictionary, kinds: Array, placed: Array, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float, stage_width: float, jamo: Array[String]) -> void:
	any_min = float(config.get("any_min", any_min))
	start_min = float(config.get("start_min", start_min))
	scenery_min = float(config.get("scenery_min", scenery_min))
	edge_margin = float(config.get("edge_margin", edge_margin))
	max_retries = int(config.get("max_retries", max_retries))
	count_min = int(config.get("count_min", count_min))
	count_max = int(config.get("count_max", count_max))
	damage_units = int(config.get("damage_units", damage_units))
	letters = jamo.duplicate()
	var decoy_ids := {}
	for kind in kinds:
		if kind["kind"] == "decoy":
			kind_order.append(String(kind["id"]))
			decoy_ids[kind["id"]] = true
	for entry in placed:
		if decoy_ids.has(entry["kind"]):
			fallback.append({"kind": String(entry["kind"]), "spot": Vector2(float(entry["x"]), float(entry["z"])), "letter": String(entry.get("letter", ""))})
	problem = _data_problem(config, fixed, scenery, starts, half_depth, stage_width)


func is_valid() -> bool:
	return problem == ""


func _data_problem(config: Dictionary, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float, stage_width: float) -> String:
	if config.is_empty():
		return "No decoy placement data"
	if kind_order.is_empty():
		return "There are no decoy kinds"
	if letters.is_empty():
		return "The target words have no jamo for a decoy letter"
	var why := _slots_problem(config.get("slots"), fixed, scenery, starts, half_depth, stage_width)
	if why != "":
		return why
	if not _is_whole(config.get("count_min")) or not _is_whole(config.get("count_max")) or count_min < 1 or count_max < count_min:
		return "The decoy count range %s..%s is not 1 <= count_min <= count_max" % [str(config.get("count_min")), str(config.get("count_max"))]
	if count_max > slots.size():
		return "count_max %d is more than the %d slots" % [count_max, slots.size()]
	var raw: Variant = config.get("kind_weights")
	if not raw is Dictionary:
		return "Decoy placement has no kind_weights"
	for id in raw:
		if not kind_order.has(id):
			return "kind_weights names '%s', which is not a decoy kind" % id
	for id in kind_order:
		if not raw.has(id):
			return "kind_weights has no weight for decoy kind '%s'" % id
		if not _is_whole(raw[id]) or int(raw[id]) < 1:
			return "kind_weights '%s' needs a whole weight of at least 1, not %s" % [id, str(raw[id])]
		kind_weights[id] = int(raw[id])
	var outcomes: Variant = config.get("outcome_weights")
	if not outcomes is Dictionary:
		return "Decoy placement has no outcome_weights"
	for id in outcomes:
		if not OUTCOMES.has(id):
			return "outcome_weights names '%s', which is not harm or reward" % id
	for id in OUTCOMES:
		if not outcomes.has(id) or not _is_whole(outcomes[id]) or int(outcomes[id]) < 1:
			return "outcome_weights '%s' needs a whole weight of at least 1, not %s" % [id, str(outcomes.get(id))]
		outcome_weights[id] = int(outcomes[id])
	if not _is_whole(config.get("damage_units")) or damage_units < 1:
		return "damage_units needs a whole number of at least 1, not %s" % str(config.get("damage_units"))
	return ""


static func _is_whole(value: Variant) -> bool:
	return (value is int) or (value is float and value == floorf(value))


func _slots_problem(raw: Variant, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float, stage_width: float) -> String:
	if not raw is Array or raw.is_empty():
		return "Decoy placement has no slots"
	for i in raw.size():
		var entry: Variant = raw[i]
		if not entry is Array or entry.size() != 2 or not (entry[0] is float or entry[0] is int) or not (entry[1] is float or entry[1] is int):
			return "Slot %d is not [x, z]" % i
		var spot := Vector2(float(entry[0]), float(entry[1]))
		if slots.has(spot):
			return "Slot %d appears twice" % i
		var why := _slot_problem(spot, fixed, scenery, starts, half_depth, stage_width)
		if why != "":
			return "Slot %d %s" % [i, why]
		for j in slots.size():
			if spot.distance_to(slots[j]) < any_min:
				return "Slot %d is within %.1f m of slot %d" % [i, any_min, j]
		slots.append(spot)
	return ""


## Why a spot can't be a decoy slot, or "". Zones play no part.
func _slot_problem(spot: Vector2, fixed: Array[Vector2], scenery: Array[Vector2], starts: Array[Vector2], half_depth: float, stage_width: float) -> String:
	if spot.x < edge_margin or spot.x > stage_width - edge_margin or absf(spot.y) > half_depth - edge_margin:
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


## Why `decoys` (Array of {"spot", ...}) break the spacing between decoys, or "":
## any two need `any_min`. (Two of one kind may stand side by side.)
func layout_problem(decoys: Array) -> String:
	for i in decoys.size():
		for j in range(i + 1, decoys.size()):
			var d: float = decoys[i]["spot"].distance_to(decoys[j]["spot"])
			if d < any_min:
				return "%s and %s are %.2f m apart" % [decoys[i]["kind"], decoys[j]["kind"], d]
	return ""


## One layout: {"decoys", "source" ("random" | "fallback" | "bad pools"), "attempts"}.
## Draws only from `rng`, tries at most `max_retries` layouts, never fails.
func choose(rng: Object) -> Dictionary:
	if problem != "":
		return {"decoys": fallback_decoys({}, rng), "source": "bad pools", "attempts": 0}
	for attempt in max_retries:
		var count: int = rng.randi_range(count_min, count_max)
		var spots := _sample(slots, count, rng)
		var decoys: Array[Dictionary] = []
		for spot in spots:
			var kind := _weighted(kind_weights, kind_order, rng)
			var outcome := _weighted(outcome_weights, OUTCOMES, rng)
			var letter: String = letters[rng.randi_range(0, letters.size() - 1)]
			decoys.append({"kind": kind, "spot": spot, "outcome": outcome, "letter": letter})
		if layout_problem(decoys) == "":
			return {"decoys": decoys, "source": "random", "attempts": attempt + 1}
	return {"decoys": fallback_decoys({}, rng), "source": "fallback", "attempts": max_retries}


## `count` distinct entries of `from`, uniformly (a partial shuffle).
func _sample(from: Array, count: int, rng: Object) -> Array[Vector2]:
	var rest := from.duplicate()
	var out: Array[Vector2] = []
	for n in count:
		var i: int = rng.randi_range(0, rest.size() - 1)
		out.append(rest[i])
		rest.remove_at(i)
	return out


## One weighted draw: the key of `order` that r falls in, r uniform in 1..total weight.
func _weighted(weights: Dictionary, order: Array, rng: Object) -> String:
	var total := 0
	for id in order:
		total += int(weights[id])
	var r: int = rng.randi_range(1, total)
	for id in order:
		r -= int(weights[id])
		if r <= 0:
			return String(id)
	return String(order[order.size() - 1])


## The fallback layout: the decoys of foraging.plants.placed. Each outcome is
## `outcomes[kind]` where given (the older tests' fixed roles), else rolled from `rng`
## by outcome_weights (1:1 until the data has set them).
func fallback_decoys(outcomes: Dictionary, rng: Object = null) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry in fallback:
		var outcome: String = String(outcomes.get(entry["kind"], ""))
		if outcome == "":
			outcome = _weighted(outcome_weights, OUTCOMES, rng) if rng != null else OUTCOMES[1]
		out.append({"kind": entry["kind"], "spot": entry["spot"], "outcome": outcome, "letter": entry["letter"]})
	return out


## A deep copy of foraging.plants whose decoy entries are `decoys` ({"kind", "spot",
## "outcome", "letter"}): they fill the data's decoy entries in order, extra ones
## are added at the end, missing ones leave the data's entry out. Targets are untouched.
func apply(plants_data: Dictionary, decoys: Array) -> Dictionary:
	var copy: Dictionary = plants_data.duplicate(true)
	var is_decoy := {}
	for kind in copy["kinds"]:
		is_decoy[kind["id"]] = kind["kind"] == "decoy"
	var placed: Array = []
	var next := 0
	for entry in copy["placed"]:
		if not is_decoy.get(entry["kind"], false):
			placed.append(entry)
		elif next < decoys.size():
			placed.append(_entry_of(decoys[next]))
			next += 1
	while next < decoys.size():
		placed.append(_entry_of(decoys[next]))
		next += 1
	copy["placed"] = placed
	return copy


func _entry_of(decoy: Dictionary) -> Dictionary:
	var spot: Vector2 = decoy["spot"]
	return {"kind": decoy["kind"], "x": spot.x, "z": spot.y, "letter": decoy["letter"], "outcome": decoy["outcome"]}


## The jamo the target words are made of, in order of first appearance (so
## the set is derived from the word data, never listed).
static func target_jamo(kinds: Array) -> Array[String]:
	var found: Array[String] = []
	for kind in kinds:
		if kind["kind"] == "target":
			for tile in Hangul.tiles_for(String(kind["name"])):
				if not found.has(tile):
					found.append(tile)
	return found


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
