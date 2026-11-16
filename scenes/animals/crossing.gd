extends RefCounted
## The animals' visits, with no nodes (data: animals). It decides when an animal appears,
## which kind (by weight), which habitat of that kind it uses, where it enters and leaves,
## and walks it along its route at its own speed. Ground animals walk entry -> a target
## inside their habitat -> linger -> a different edge, steering round the lake (they never
## enter it). Ducks fly in from off screen, land on the lake, swim to a few waypoints
## inside it, linger, take off and fly out. Flyers cross a straight line over everything.
## Everybody spawns and despawns `offscreen_m` (or more, see outside_m) outside the map
## rectangle, where the camera never looks. It knows nothing of travelers or props. The
## scene owns the nodes and asks this where each animal is.
##
## Every random draw comes from one seeded RandomNumberGenerator, in a fixed order per
## spawn, so one seed gives one sequence. `seed_from_args` reads the --seed=N argument.

const SEED_ARG := "--seed="
const EDGE_EPSILON := 0.001
const ZONE_EPSILON := 0.001

## What happened in a tick: {"event": "spawn" or "exit", "walker": Walker}.
const SPAWN := "spawn"
const EXIT := "exit"


## One animal on its way along `route`. `travelled` is the metres walked along it (lingering
## does not change it).
class Walker extends RefCounted:
	var id := 0
	var kind: Dictionary = {}
	var habitat := ""
	var entry: Dictionary = {}
	var exit: Dictionary = {}
	var route: Array[Vector2] = []
	var cumulative: Array[float] = []
	var from := Vector2.ZERO
	var to := Vector2.ZERO
	var target := Vector2.ZERO  ## the place it lingers at (ground animals and ducks)
	var length := 0.0
	var travelled := 0.0
	var stop_dist := -1.0
	var linger := 0.0
	var lingered := 0.0
	var phase := 0.0
	var altitude := 0.0
	var amplitude := 0.0
	var wavelength := 1.0
	var lake_center := Vector2.ZERO
	var keep_out_radius := 0.0  ## > 0: never closer than this to lake_center
	## Ducks only (land_at >= 0): they fly in, touch down `land_at` metres along the route
	## (coming down over `descent_len`), swim, and take off at `takeoff_at` (climbing over
	## `climb_len`). Everyone else keeps `altitude` for the whole route.
	var fly_height := 0.0
	var land_at := -1.0
	var descent_len := 1.0
	var takeoff_at := -1.0
	var climb_len := 1.0

	## Call once `route` is filled in.
	func finalize() -> void:
		cumulative = [0.0]
		for i in range(1, route.size()):
			cumulative.append(cumulative[i - 1] + route[i - 1].distance_to(route[i]))
		length = cumulative[cumulative.size() - 1]
		from = route[0]
		to = route[route.size() - 1]
		altitude = altitude_at(travelled)

	## The height above the floor after `distance` metres along the route.
	func altitude_at(distance: float) -> float:
		if land_at < 0.0:
			return altitude
		if distance >= takeoff_at:
			return fly_height * clampf((distance - takeoff_at) / climb_len, 0.0, 1.0)
		return fly_height * clampf((land_at - distance) / descent_len, 0.0, 1.0)

	## Moves it for `delta` seconds: lingers first if it stands at its stop.
	func advance(delta: float) -> void:
		var left := delta
		var stopped := stop_dist >= 0.0 and lingered < linger
		if stopped and travelled >= stop_dist:
			var used := minf(left, linger - lingered)
			lingered += used
			left -= used
		if left > 0.0:
			var limit := stop_dist if (stop_dist >= 0.0 and lingered < linger) else length
			travelled = minf(travelled + float(kind["speed"]) * left, limit)
		altitude = altitude_at(travelled)

	func _segment() -> int:
		var last := route.size() - 2
		for i in range(0, last + 1):
			if cumulative[i + 1] - cumulative[i] > 0.000001 and travelled <= cumulative[i + 1]:
				return i
		return last

	func direction() -> Vector2:
		var i := _segment()
		return (route[i + 1] - route[i]).normalized()

	## Where it is now over (x, z): on the route plus the sideways wobble (zero at both
	## ends); pushed out of the lake if the wobble would enter it.
	func position() -> Vector2:
		var i := _segment()
		var line := direction()
		var side := Vector2(-line.y, line.x)
		var ramp := clampf(minf(travelled, length - travelled) / wavelength, 0.0, 1.0)
		var spot := route[i] + line * (travelled - cumulative[i]) + side * amplitude * sin(TAU * travelled / wavelength + phase) * ramp
		if keep_out_radius > 0.0:
			var offset := spot - lake_center
			if offset.length() < keep_out_radius:
				spot = lake_center + (offset.normalized() if offset.length() > 0.000001 else Vector2(0.0, -1.0)) * keep_out_radius
		return spot

	## The way it faces: along its route (the wobble is too gentle to turn it).
	func heading() -> Vector2:
		return direction()

	func is_done() -> bool:
		return travelled >= length


var config: Dictionary = {}
var kinds: Array = []
var width := 0.0
var depth := 0.0
var lake_center := Vector2.ZERO
var lake_radius := 0.0
var lake_clearance := 0.3
var offscreen := 3.0  ## metres outside the map rectangle where animals spawn and despawn
var pitch_tan := 0.5  ## tan of the camera's pitch: a point `h` up looks like ground h / pitch_tan farther
var label_top := 1.0  ## the name label's height over the animal's box
var duck_glide := 8.0
var shore_band := 0.0
var shore_inset := 0.5
var forest_end := 0.0  ## z where the forest (the top of the map) ends
var interval_min := 4.0
var interval_max := 9.0
var max_alive := 5
var wobble_amplitude := 0.8
var wobble_wavelength := 10.0
var fly_height := 4.0
var linger_min := 4.0
var linger_max := 8.0
var rng := RandomNumberGenerator.new()
## The animals on the map now, in the order they came.
var alive: Array[Walker] = []
## How many have been spawned, and how many have left.
var spawned := 0
var exited := 0

var _weights := PackedFloat32Array()
var _until_spawn := 0.0
var _next_id := 1


## `config` is the animals section; `seed_value` fixes every random draw.
func _init(animals_config: Dictionary, seed_value: int) -> void:
	config = animals_config
	kinds = config["kinds"]
	width = float(config["stage"]["width"])
	depth = float(config["stage"]["depth"])
	var lake: Dictionary = config["lake"]
	lake_center = Vector2(float(lake["center"][0]), float(lake["center"][1]))
	lake_radius = float(lake["radius"])
	lake_clearance = float(lake["clearance_m"])
	duck_glide = float(lake["duck_glide_m"])
	offscreen = float(config.get("offscreen_m", 3.0))
	pitch_tan = tan(deg_to_rad(float(config["camera"]["pitch_deg"])))
	var label: Dictionary = config["label"]
	label_top = float(label["lift"]) + float(label["font_size"]) * float(label["pixel_size"])
	var habitats: Dictionary = config["habitats"]
	shore_band = float(habitats["shore"]["band_frac"]) * depth
	shore_inset = float(habitats["shore"]["inset_m"])
	forest_end = -depth / 2.0 + float(habitats["forest"]["top_frac"]) * depth
	var spawn_config: Dictionary = config["spawn"]
	interval_min = float(spawn_config["interval_min_s"])
	interval_max = float(spawn_config["interval_max_s"])
	max_alive = int(spawn_config["max_alive"])
	var path: Dictionary = config["path"]
	wobble_amplitude = float(path["wobble_amplitude_m"])
	wobble_wavelength = float(path["wobble_wavelength_m"])
	fly_height = float(path["fly_height"])
	linger_min = float(config["linger"]["min_s"])
	linger_max = float(config["linger"]["max_s"])
	for kind in kinds:
		_weights.append(float(kind["weight"]))
	rng.seed = seed_value
	_until_spawn = float(spawn_config["first_spawn_s"])


## {"found", "seed", "problem"}: the --seed=N user argument. Not found is not a problem;
## a value that is not a whole number is, and then nothing is found.
static func seed_from_args(args: PackedStringArray) -> Dictionary:
	for arg in args:
		if arg.begins_with(SEED_ARG):
			var text := arg.substr(SEED_ARG.length())
			if text.is_valid_int():
				return {"found": true, "seed": text.to_int(), "problem": ""}
			return {"found": false, "seed": 0, "problem": "'%s' is not a whole number" % text}
	return {"found": false, "seed": 0, "problem": ""}


## The stage edge a point lies on: "west", "east", "far" or "near" ("" if none). `width`
## and `depth` are the stage's, z runs -depth/2 .. +depth/2.
static func edge_of(point: Vector2, width: float, depth: float) -> String:
	if absf(point.x) <= EDGE_EPSILON:
		return "west"
	if absf(point.x - width) <= EDGE_EPSILON:
		return "east"
	if absf(point.y + depth / 2.0) <= EDGE_EPSILON:
		return "far"
	if absf(point.y - depth / 2.0) <= EDGE_EPSILON:
		return "near"
	return ""


# ---- Zones ----

## Whether `point` lies in the named habitat zone (lake, shore, forest, grass, air).
func zone_contains(habitat: String, point: Vector2) -> bool:
	if point.x < -ZONE_EPSILON or point.x > width + ZONE_EPSILON or point.y < -depth / 2.0 - ZONE_EPSILON or point.y > depth / 2.0 + ZONE_EPSILON:
		return false
	var distance := point.distance_to(lake_center)
	match habitat:
		"air":
			return true
		"lake":
			return distance <= lake_radius + ZONE_EPSILON and point.y <= lake_center.y + ZONE_EPSILON
		"shore":
			return distance >= lake_radius - ZONE_EPSILON and distance <= lake_radius + shore_band + ZONE_EPSILON and point.y <= lake_center.y + ZONE_EPSILON
		"forest":
			return point.y <= forest_end + ZONE_EPSILON
		"grass":
			return point.y >= forest_end - ZONE_EPSILON and (distance >= lake_radius + shore_band - ZONE_EPSILON or point.y > lake_center.y + ZONE_EPSILON)
	return false


func in_lake(point: Vector2) -> bool:
	return point.distance_to(lake_center) < lake_radius and point.y <= lake_center.y


## z range of a habitat along the west and east edges.
func _side_range(habitat: String) -> Vector2:
	match habitat:
		"forest":
			return Vector2(-depth / 2.0, forest_end)
		"grass":
			return Vector2(forest_end, depth / 2.0)
		"shore":
			return Vector2(lake_center.y - (lake_radius + shore_band), lake_center.y)
	return Vector2(-depth / 2.0, depth / 2.0)


## How far outside the stage edge `edge` an animal of `walker` enters and leaves: offscreen_m,
## plus on the near edge the height of its top (flyer height, box, label) over tan(pitch),
## because the camera sees something that high as if it stood that much farther up the map.
func outside_m(walker: Walker, edge: String) -> float:
	if edge != "near":
		return offscreen
	var top := walker.fly_height + float(walker.kind["size"][1]) + label_top
	return offscreen + top / pitch_tan


## A random point on the stage edge, then moved out of the map by outside_m().
func _edge_point(habitat: String, edge: String, walker: Walker) -> Vector2:
	var out := outside_m(walker, edge)
	match edge:
		"west":
			var r := _side_range(habitat)
			return Vector2(-out, rng.randf_range(r.x, r.y))
		"east":
			var r2 := _side_range(habitat)
			return Vector2(width + out, rng.randf_range(r2.x, r2.y))
		"far":
			return Vector2(rng.randf_range(0.0, width), -depth / 2.0 - out)
	return Vector2(rng.randf_range(0.0, width), depth / 2.0 + out)  # near


## A random place inside the habitat's zone, away from its edges (ground animals only).
func _target_in(habitat: String) -> Vector2:
	var hab: Dictionary = config["habitats"][habitat] if config["habitats"].has(habitat) else {}
	var margin := float(hab.get("margin_m", 0.0))
	match habitat:
		"forest":
			return Vector2(rng.randf_range(margin, width - margin), rng.randf_range(-depth / 2.0 + margin, forest_end - margin))
		"shore":
			var r := rng.randf_range(lake_radius + shore_inset, lake_radius + shore_band)
			var a := rng.randf_range(0.0, PI)
			return lake_center + Vector2(cos(a), -sin(a)) * r
	# grass: the rest of the map, outside the shore band
	for i in 200:
		var p := Vector2(rng.randf_range(margin, width - margin), rng.randf_range(forest_end + margin, depth / 2.0 - margin))
		if zone_contains("grass", p) and p.distance_to(lake_center) >= lake_radius + shore_band:
			return p
	return Vector2(margin, depth / 2.0 - margin)


## A random point in the lake's half disc, `inset` metres from the water's edge.
func _lake_point(inset: float) -> Vector2:
	var r := sqrt(rng.randf()) * (lake_radius - inset)
	var a := rng.randf_range(0.0, PI)
	return lake_center + Vector2(cos(a), -sin(a)) * r


# ---- Steering ----

func _steer_radius() -> float:
	return lake_radius + lake_clearance


func _hits_lake(a: Vector2, b: Vector2) -> bool:
	var closest := Geometry2D.get_closest_point_to_segment(lake_center, a, b)
	return closest.distance_to(lake_center) < _steer_radius() - 0.0001


## The points after `a` up to and including `b`, bending round the lake where the straight
## line would cross it.
func _detour(a: Vector2, b: Vector2, level: int = 0) -> Array[Vector2]:
	if level > 6 or not _hits_lake(a, b):
		return [b]
	var closest := Geometry2D.get_closest_point_to_segment(lake_center, a, b)
	var normal := closest - lake_center
	if normal.length() < 0.000001 or normal.y > -0.3 * normal.length():
		normal = Vector2(0.0, -1.0)  # over the top of the lake
	var bend := lake_center + normal.normalized() * _steer_radius() * 1.25
	var points: Array[Vector2] = []
	points.append_array(_detour(a, bend, level + 1))
	points.append_array(_detour(bend, b, level + 1))
	return points


# ---- Ticking and spawning ----

## Advances every animal by `delta` seconds and the spawn clock; returns what happened,
## in order: the exits first, then at most one spawn.
func tick(delta: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for walker in alive.duplicate():
		walker.advance(delta)
		if walker.is_done():
			alive.erase(walker)
			exited += 1
			events.append({"event": EXIT, "walker": walker})
	_until_spawn -= delta
	if _until_spawn <= 0.0 and alive.size() < max_alive:
		var walker := spawn()
		_until_spawn = rng.randf_range(interval_min, interval_max)
		events.append({"event": SPAWN, "walker": walker})
	return events


## Puts a new animal on the map. Null if the map is full.
func spawn() -> Walker:
	if alive.size() >= max_alive:
		return null
	var walker := Walker.new()
	walker.id = _next_id
	_next_id += 1
	walker.kind = kinds[rng.rand_weighted(_weights)]
	var habitats: Array = walker.kind["habitat"]
	walker.habitat = String(habitats[rng.randi_range(0, habitats.size() - 1)])
	walker.fly_height = fly_height if (bool(walker.kind["flies"]) or walker.habitat == "lake") else 0.0
	walker.altitude = fly_height if bool(walker.kind["flies"]) else 0.0
	walker.amplitude = wobble_amplitude
	walker.wavelength = wobble_wavelength
	walker.lake_center = lake_center
	if walker.habitat == "lake":
		_plan_duck(walker)
	else:
		_plan_walk(walker)
	walker.phase = rng.randf_range(0.0, TAU)
	walker.finalize()
	if walker.stop_dist < 0.0 and walker.linger > 0.0:
		walker.stop_dist = walker.length
	alive.append(walker)
	spawned += 1
	return walker


## Edge to edge: a flyer in a straight line, a ground animal by way of a target.
func _plan_walk(walker: Walker) -> void:
	var edges: Array = config["habitats"][walker.habitat]["edges"]
	var entry_edge := String(edges[rng.randi_range(0, edges.size() - 1)])
	var entry_point := _edge_point(walker.habitat, entry_edge, walker)
	var others: Array = edges.filter(func(e): return e != entry_edge)
	var exit_edge := String(others[rng.randi_range(0, others.size() - 1)])
	var exit_point := _edge_point(walker.habitat, exit_edge, walker)
	walker.entry = {"id": entry_edge, "edge": entry_edge, "x": entry_point.x, "z": entry_point.y}
	walker.exit = {"id": exit_edge, "edge": exit_edge, "x": exit_point.x, "z": exit_point.y}
	walker.route.append(entry_point)
	if bool(walker.kind["flies"]):
		walker.route.append(exit_point)
		return
	var target := _target_in(walker.habitat)
	walker.target = target
	walker.keep_out_radius = _steer_radius()
	walker.route.append_array(_detour(entry_point, target))
	var target_index := walker.route.size() - 1
	walker.route.append_array(_detour(target, exit_point))
	walker.linger = rng.randf_range(linger_min, linger_max)
	# finalize() has not run yet: the stop distance is the route length up to the target
	var travelled := 0.0
	for i in range(1, target_index + 1):
		travelled += walker.route[i - 1].distance_to(walker.route[i])
	walker.stop_dist = travelled


## A duck: flies in at fly_height from outside the map, comes down onto the lake at its
## first waypoint, swims to 1-2 more, lingers at the last, takes off and flies out.
func _plan_duck(walker: Walker) -> void:
	var lake: Dictionary = config["lake"]
	var wp_inset := float(lake["duck_waypoint_inset_m"])
	var edges: Array = config["habitats"]["lake"]["edges"]
	var entry_edge := String(edges[rng.randi_range(0, edges.size() - 1)])
	var entry_point := _edge_point("air", entry_edge, walker)
	var others: Array = edges.filter(func(e): return e != entry_edge)
	var exit_edge := String(others[rng.randi_range(0, others.size() - 1)])
	var exit_point := _edge_point("air", exit_edge, walker)
	walker.route.append(entry_point)
	var count := rng.randi_range(int(config["linger"]["duck_waypoints_min"]), int(config["linger"]["duck_waypoints_max"]))
	var last := entry_point
	for i in count:
		last = _lake_point(wp_inset)
		walker.route.append(last)
	var stop_index := walker.route.size() - 1
	walker.route.append(exit_point)
	walker.target = last
	walker.amplitude = 0.0  # a straight swim stays inside the (convex) half disc
	walker.entry = {"id": entry_edge, "edge": entry_edge, "x": entry_point.x, "z": entry_point.y}
	walker.exit = {"id": exit_edge, "edge": exit_edge, "x": exit_point.x, "z": exit_point.y}
	walker.linger = rng.randf_range(linger_min, linger_max)
	var legs: Array[float] = []  # route length up to each point
	var travelled := 0.0
	legs.append(0.0)
	for i in range(1, walker.route.size()):
		travelled += walker.route[i - 1].distance_to(walker.route[i])
		legs.append(travelled)
	walker.stop_dist = legs[stop_index]
	walker.land_at = legs[1]
	walker.descent_len = maxf(minf(duck_glide, legs[1]), 0.001)
	walker.takeoff_at = legs[stop_index]
	walker.climb_len = maxf(minf(duck_glide, legs[legs.size() - 1] - legs[stop_index]), 0.001)
