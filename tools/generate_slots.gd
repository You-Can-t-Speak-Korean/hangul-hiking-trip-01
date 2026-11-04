extends Node
## Generates (and checks) the candidate decoy slots of foraging.decoy_placement.slots.
## It builds the REAL foraging scene (so it needs the scene tree and the autoloads: it is a
## scene, not a -s script), reads the real prop boxes, tree positions, target plants, spare
## slots, travelers' starts, walk limits and camera clamp, and
##   1. checks the slots that are in the data now against every rule (the validity check:
##      the exit code is 0 if they are all valid, 1 if not);
##   2. generates a fresh list by deterministic farthest-point sampling over a grid of
##      valid spots, with a small safety margin over each data rule, and checks that too.
## It prints the result as JSON and writes NOTHING to the data unless given --write.
##
## Run (from the project folder, headless):
##   godot --headless --path . res://tools/generate_slots.tscn -- [--seed=N] [--step=M] [--count=N] [--write] [--data=PATH]
## where
##   --seed=N    the seed of the first (random) pick of the sampling   (default 1)
##   --step=M    the grid step in metres                                (default 0.5)
##   --count=N   how many slots to generate                             (default 24)
##   --write     replace "slots" in foraging.decoy_placement of the data file by the
##               generated list (the rest of the file is left as it is)
##   --data=PATH the data file --write changes                          (default res://data/mountains/hallasan.json)
## The same seed, step and count always give the same list.

const DecoyPlacement := preload("res://scenes/foraging/decoy_placement.gd")

const FORAGING_SCENE := "res://scenes/foraging/foraging.tscn"
const DEFAULT_DATA := "res://data/mountains/hallasan.json"
const DEFAULT_SEED := 1
const DEFAULT_STEP := 0.5
const DEFAULT_COUNT := 24
## Metres by which generated slots beat the data rules (the data rules are what a slot must pass).
const MARGIN_PLANT := 0.2
const MARGIN_TREE := 0.2
const MARGIN_START := 0.5
const MARGIN_SLOT := 0.2
const PROP_FOOTPRINT := 0.6     # clear ground a slot keeps from a prop's box
const LETTER_HEIGHT := 1.5      # the height the camera must see a decoy's letter at
const WALK_MARGIN := 0.5        # metres a slot stays inside the near walk limit
const MAX_PROBLEMS := 30        # problems listed per check
const WRITE_ROW := 6            # slots per line when writing

## Set by the scene file: the tool runs by itself and quits. Tests leave it off and call run().
var autorun := false


func _ready() -> void:
	if not autorun:
		return
	var report := run(OS.get_cmdline_user_args())
	print(JSON.stringify(report, "  "))
	get_tree().quit(0 if report["current"]["valid"] else 1)


## Does everything the header says. `args` are the command-line user arguments.
## Returns {"seed", "step", "count", "candidates": [[x, z]], "candidate_check", "current", "written"};
## each check is {"valid": bool, "count": int, "problems": [String]}; "written" is the
## path written, or "" (nothing is written without --write).
func run(args: PackedStringArray) -> Dictionary:
	var seed_value := int(_argument(args, "--seed=", str(DEFAULT_SEED)))
	var step := maxf(float(_argument(args, "--step=", str(DEFAULT_STEP))), 0.05)
	var count := int(_argument(args, "--count=", str(DEFAULT_COUNT)))
	var data_path := _argument(args, "--data=", DEFAULT_DATA)
	var write := args.has("--write")
	var map: Node3D = load(FORAGING_SCENE).instantiate()
	add_child(map)
	var context := _context(map)
	var current: Array[Vector2] = []
	for slot in context["config"].get("slots", []):
		current.append(Vector2(float(slot[0]), float(slot[1])))
	var candidates := _generate(context, seed_value, step, count)
	var report := {
		"seed": seed_value, "step": step, "count": count,
		"candidates": candidates.map(func(spot: Vector2) -> Array: return [spot.x, spot.y]),
		"candidate_check": check_slots(candidates, context, true),
		"current": check_slots(current, context, false),
		"written": "",
	}
	if write:
		var problem := _write_slots(data_path, candidates)
		if problem == "":
			report["written"] = data_path
		else:
			report["write_error"] = problem
	map.free()
	return report


static func _argument(args: PackedStringArray, prefix: String, fallback: String) -> String:
	for arg in args:
		if arg.begins_with(prefix):
			return arg.substr(prefix.length())
	return fallback


## Everything the rules need, read from the live scene and its data.
func _context(map: Node3D) -> Dictionary:
	var foraging: Dictionary = Content.mountain(GameState.game_id)["foraging"]
	var trees: Array[Vector2] = []
	for pos in foraging["scenery"]["gusangnamu"]["positions"]:
		trees.append(Vector2(float(pos[0]), float(pos[1])))
	var starts: Array[Vector2] = []
	for id in foraging["start"]:
		starts.append(Vector2(float(foraging["start"][id][0]), float(foraging["start"][id][1])))
	var targets: Array[Vector2] = []
	var by_id := {}
	for kind in foraging["plants"]["kinds"]:
		by_id[kind["id"]] = kind
	for entry in foraging["plants"]["placed"]:
		if by_id[entry["kind"]]["kind"] == "target":
			targets.append(Vector2(float(entry["x"]), float(entry["z"])))
	for id in foraging["spares"]["slots"]:
		targets.append(Vector2(float(foraging["spares"]["slots"][id][0]), float(foraging["spares"]["slots"][id][1])))
	var boxes: Array = []
	for holder in ["Props", "Scenery"]:
		for node in map.get_node(holder).get_children():
			boxes.append(node.bounds)
	return {
		"map": map, "config": foraging["decoy_placement"], "fixed": targets, "trees": trees, "starts": starts, "boxes": boxes,
		"width": float(foraging["stage"]["width"]), "half_depth": float(foraging["stage"]["depth"]) / 2.0,
		"bounds": map.walk_bounds(),
	}


## Why `spot` can't be a slot, or "": the rules of foraging.decoy_placement plus the live scene.
## `margin` makes each rule that much stricter (for generating, never for checking the data).
func spot_problem(spot: Vector2, context: Dictionary, margin: bool) -> String:
	var config: Dictionary = context["config"]
	var map: Node3D = context["map"]
	var edge := float(config.get("edge_margin", 1.0))
	var any_min := float(config.get("any_min", 2.0)) + (MARGIN_PLANT if margin else 0.0)
	var scenery_min := float(config.get("scenery_min", 2.5)) + (MARGIN_TREE if margin else 0.0)
	var start_min := float(config.get("start_min", 6.0)) + (MARGIN_START if margin else 0.0)
	if spot.x < edge or spot.x > float(context["width"]) - edge or absf(spot.y) > float(context["half_depth"]) - edge:
		return "is off the stage"
	var bounds: Rect2 = context["bounds"]
	if not bounds.has_point(spot) or spot.y > map.near_limit_at(spot.x) - WALK_MARGIN:
		return "is outside the walk limits or the camera clamp"
	for point: Vector2 in context["fixed"]:
		if spot.distance_to(point) < any_min:
			return "is within %.1f m of a target plant or spare slot" % any_min
	for point: Vector2 in context["trees"]:
		if spot.distance_to(point) < scenery_min:
			return "is within %.1f m of a tree" % scenery_min
	for point: Vector2 in context["starts"]:
		if spot.distance_to(point) < start_min:
			return "is within %.1f m of a start" % start_min
	for box: AABB in context["boxes"]:
		if Rect2(box.position.x, box.position.z, box.size.x, box.size.z).grow(PROP_FOOTPRINT).has_point(spot):
			return "is inside or under a prop"
	if DecoyPlacement.blocked_by_prop(spot, map.terrain.height_at(spot.x), context["boxes"], map.CAMERA_PITCH_DEG, PROP_FOOTPRINT, LETTER_HEIGHT, map.FADE_REACH):
		return "has a prop between it and the camera"
	return ""


## The validity check: every slot against every rule, and every pair against any_min.
func check_slots(slots: Array[Vector2], context: Dictionary, margin: bool) -> Dictionary:
	var config: Dictionary = context["config"]
	var apart := float(config.get("any_min", 2.0)) + (MARGIN_SLOT if margin else 0.0)
	var problems: Array[String] = []
	for i in slots.size():
		var why := spot_problem(slots[i], context, margin)
		if why != "" and problems.size() < MAX_PROBLEMS:
			problems.append("slot %d (%s, %s) %s" % [i, slots[i].x, slots[i].y, why])
		for j in range(i + 1, slots.size()):
			if slots[i].distance_to(slots[j]) < apart and problems.size() < MAX_PROBLEMS:
				problems.append("slots %d and %d are %.2f m apart, less than %.1f m" % [i, j, slots[i].distance_to(slots[j]), apart])
	return {"valid": problems.is_empty() and not slots.is_empty(), "count": slots.size(), "problems": problems}


## Deterministic farthest-point sampling over the grid of valid spots: a seeded random first
## pick, then each time the spot farthest from all picked ones (the first such in grid order).
## Stops early when no spot is `any_min` (plus the margin) from every pick.
func _generate(context: Dictionary, seed_value: int, step: float, count: int) -> Array[Vector2]:
	var config: Dictionary = context["config"]
	var edge := float(config.get("edge_margin", 1.0))
	var pool: Array[Vector2] = []
	var x := edge
	while x <= float(context["width"]) - edge + 0.0001:
		var z := -(float(context["half_depth"]) - edge)
		while z <= float(context["half_depth"]) - edge + 0.0001:
			var spot := Vector2(snappedf(x, 0.01), snappedf(z, 0.01))
			if spot_problem(spot, context, true) == "":
				pool.append(spot)
			z += step
		x += step
	var picked: Array[Vector2] = []
	if pool.is_empty() or count < 1:
		return picked
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	picked.append(pool[rng.randi_range(0, pool.size() - 1)])
	var nearest := PackedFloat32Array()
	nearest.resize(pool.size())
	for i in pool.size():
		nearest[i] = pool[i].distance_to(picked[0])
	var apart := float(config.get("any_min", 2.0)) + MARGIN_SLOT
	while picked.size() < count:
		var best := -1
		var best_distance := -1.0
		for i in pool.size():
			if nearest[i] > best_distance + 0.000001:
				best = i
				best_distance = nearest[i]
		if best < 0 or best_distance < apart:
			break
		picked.append(pool[best])
		for i in pool.size():
			nearest[i] = minf(nearest[i], pool[i].distance_to(pool[best]))
	for i in picked.size():  # one decimal, as the data is written
		picked[i] = Vector2(snappedf(picked[i].x, 0.1), snappedf(picked[i].y, 0.1))
	return picked


## Replaces the "slots" array of "decoy_placement" in the data file `path` by `slots`, leaving
## the rest of the text as it is. Returns "" or what went wrong. Only --write calls this.
func _write_slots(path: String, slots: Array[Vector2]) -> String:
	if slots.is_empty():
		return "no slots were generated"
	if not FileAccess.file_exists(path):
		return "%s does not exist" % path
	var text := FileAccess.get_file_as_string(path)
	var block := text.find("\"decoy_placement\"")
	var key := text.find("\"slots\":", block) if block >= 0 else -1
	var open := text.find("[", key) if key >= 0 else -1
	if open < 0:
		return "%s has no decoy_placement.slots" % path
	var depth := 0
	var close := -1
	for i in range(open, text.length()):
		if text[i] == "[":
			depth += 1
		elif text[i] == "]":
			depth -= 1
			if depth == 0:
				close = i
				break
	if close < 0:
		return "the slots array in %s never closes" % path
	var rows: Array[String] = []
	for first in range(0, slots.size(), WRITE_ROW):
		var cells: Array[String] = []
		for i in range(first, mini(first + WRITE_ROW, slots.size())):
			cells.append("[%s, %s]" % [String.num(slots[i].x, 1), String.num(slots[i].y, 1)])
		rows.append("        " + ", ".join(cells))
	var written := text.substr(0, open) + "[\n" + ",\n".join(rows) + "\n      ]" + text.substr(close + 1)
	if JSON.parse_string(written) == null:
		return "the result would not be valid JSON, nothing written"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return "cannot open %s for writing (error %d)" % [path, FileAccess.get_open_error()]
	file.store_string(written)
	file.close()
	return ""
