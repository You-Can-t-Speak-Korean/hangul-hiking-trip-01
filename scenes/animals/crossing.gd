extends RefCounted
## The animals' visits, with no nodes (data: animals). It decides when an animal appears,
## which kind (by weight), which habitat of that kind it uses, where it enters and leaves,
## and walks it along its route at its own speed. Ground animals walk entry -> a target
## inside their habitat -> linger -> a different edge, steering round the lake (they never
## enter it). Ducks fly in from off screen, land on the lake, swim to a few waypoints
## inside it, linger, take off and fly out. Flyers cross a straight line over everything.
## Everybody spawns just outside the camera's footprint (`view`, set by the scene each tick;
## the whole map until it is): `offscreen_m` (or more, see outside_m) beyond it, on a side
## whose ground is the kind's habitat, inside the map where that is possible. Nobody
## despawns inside the footprint: an animal that has reached its exit while the camera
## has come to show it walks on to the nearest way out. How many may be on the map at once
## is a curve over the run (cap()). It knows nothing of travelers or props. The scene owns
## the nodes and asks this where each animal is.
##
## Every random draw comes from one seeded RandomNumberGenerator, in a fixed order per
## spawn, so one seed gives one sequence. `seed_from_args` reads the --seed=N argument.

const SEED_ARG := "--seed="
const EDGE_EPSILON := 0.001
const ZONE_EPSILON := 0.001
## The sides of the camera's footprint an animal may come in or go out by.
const SIDES := ["west", "east", "far", "near"]
const VIEW_EPSILON := 0.0001

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
	## The jamo it carries ("" once taken). The scene sets it when the animal spawns.
	var letter := ""
	## 1 normally; more once it flees (a grab).
	var speed_scale := 1.0
	var fled := false

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
			travelled = minf(travelled + float(kind["speed"]) * speed_scale * left, limit)
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
var start_cap := 4
var peak_cap := 10
var ramp_seconds := 240.0
var min_cap := 3
var target_samples := 24
## The ground the camera shows (x, z): animals enter and leave outside it. Until the scene
## sets it, it is the map rectangle.
var view := Rect2()
## Seconds of the run, and needs met so far: they set the cap.
var elapsed := 0.0
var met := 0
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
	start_cap = int(spawn_config["start_cap"])
	peak_cap = int(spawn_config["peak_cap"])
	ramp_seconds = float(spawn_config["ramp_seconds"])
	min_cap = int(spawn_config["min_cap"])
	target_samples = int(spawn_config.get("target_samples", 24))
	view = Rect2(0.0, -depth / 2.0, width, depth)
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


## How far outside the footprint's side `edge` an animal of `walker` enters and leaves:
## offscreen_m, plus on the near side the height of its top (flyer height, box, label) over
## tan(pitch), because the camera sees something that high as if it stood that much
## farther up the map.
func outside_m(walker: Walker, edge: String) -> float:
	if edge != "near":
		return offscreen
	var top := walker.fly_height + float(walker.kind["size"][1]) + label_top
	return offscreen + top / pitch_tan


## True if `point` is outside the footprint by offscreen_m (more on the near side): where an
## animal may appear and vanish.
func outside_view(point: Vector2, walker: Walker) -> bool:
	return point.x <= view.position.x - offscreen + VIEW_EPSILON \
			or point.x >= view.end.x + offscreen - VIEW_EPSILON \
			or point.y <= view.position.y - offscreen + VIEW_EPSILON \
			or point.y >= view.end.y + outside_m(walker, "near") - VIEW_EPSILON


## How many animals may be on the map after `seconds` of the run with `met_needs` needs
## met: start_cap rising linearly to peak_cap over ramp_seconds, less one per need met,
## never below min_cap.
func cap_at(seconds: float, met_needs: int) -> int:
	var ramp := clampf(seconds / maxf(ramp_seconds, 0.001), 0.0, 1.0)
	var base := floori(float(start_cap) + float(peak_cap - start_cap) * ramp + 0.000001)
	return maxi(min_cap, base - met_needs)


func cap() -> int:
	return cap_at(elapsed, met)


func _in_map(point: Vector2) -> bool:
	return point.x >= 0.0 and point.x <= width and point.y >= -depth / 2.0 and point.y <= depth / 2.0


func _clamped(point: Vector2) -> Vector2:
	return Vector2(clampf(point.x, 0.0, width), clampf(point.y, -depth / 2.0, depth / 2.0))


## A point on a side of the footprint, `t` (0..1) of the way along it, `offscreen` out.
func _side_point(side: String, walker: Walker, t: float) -> Vector2:
	match side:
		"west":
			return Vector2(view.position.x - offscreen, lerpf(view.position.y, view.end.y, t))
		"east":
			return Vector2(view.end.x + offscreen, lerpf(view.position.y, view.end.y, t))
		"far":
			return Vector2(lerpf(view.position.x, view.end.x, t), view.position.y - offscreen)
	return Vector2(lerpf(view.position.x, view.end.x, t), view.end.y + outside_m(walker, "near"))


## The point on a side nearest `here`.
func _side_nearest(side: String, walker: Walker, here: Vector2) -> Vector2:
	var far_z := view.position.y - offscreen
	var near_z := view.end.y + outside_m(walker, "near")
	var west_x := view.position.x - offscreen
	var east_x := view.end.x + offscreen
	match side:
		"west":
			return Vector2(west_x, clampf(here.y, far_z, near_z))
		"east":
			return Vector2(east_x, clampf(here.y, far_z, near_z))
		"far":
			return Vector2(clampf(here.x, west_x, east_x), far_z)
	return Vector2(clampf(here.x, west_x, east_x), near_z)


## A place a ground animal may come in or go out by: outside the lake's steering ring, and
## not on the far side of the lake's flat edge (below the half disc, where a route round it
## has no good way).
func _usable_ground(point: Vector2) -> bool:
	if point.y > lake_center.y and absf(point.x - lake_center.x) < _steer_radius() + 6.0:
		return false
	return point.distance_to(lake_center) >= _steer_radius()


## Where an animal comes in: a random point on a random one of `sides` of the footprint whose
## ground lies in `habitat` ("air": anywhere), inside the map if that can be found (the
## second half of the tries lets it be outside), and for a ground animal outside the lake's
## steering ring. {"side", "point"}. When no side has such ground, the point of the habitat
## nearest the footprint (still outside it by offscreen_m).
func _pick_entry(walker: Walker, habitat: String, sides: Array) -> Dictionary:
	var ground := habitat != "air"
	var tries := 40
	for attempt in tries:
		var side := String(sides[rng.randi_range(0, sides.size() - 1)])
		var point := _side_point(side, walker, rng.randf())
		if attempt < tries / 2 and not _in_map(point):
			continue
		if ground and (not _usable_ground(point) or not zone_contains(habitat, _clamped(point))):
			continue
		return {"side": side, "point": point}
	if ground:
		var best := {}
		var best_gap := INF
		for i in target_samples:
			var point := _target_in(habitat)
			var gap := _gap_to_view(point)
			if outside_view(point, walker) and gap < best_gap and _usable_ground(point):
				best_gap = gap
				best = {"side": _nearest_side_name(point), "point": point}
		if not best.is_empty():
			return best
	return {"side": "west", "point": _side_point("west", walker, 0.5)}


## Where an animal goes out: a random point on a random side other than `avoid` (when there
## is another), inside the map if it can be found, outside the lake's steering ring for a
## ground animal.
func _pick_exit(walker: Walker, avoid: String, sides: Array, ground: bool) -> Dictionary:
	var choices: Array = sides.filter(func(e): return e != avoid)
	if choices.is_empty():
		choices = sides
	var tries := 40
	for attempt in tries:
		var side := String(choices[rng.randi_range(0, choices.size() - 1)])
		var point := _side_point(side, walker, rng.randf())
		if attempt < tries / 2 and not _in_map(point):
			continue
		if ground and not _usable_ground(point):
			continue
		return {"side": side, "point": point}
	return {"side": "west", "point": _side_point("west", walker, 0.5)}


## The side of the footprint a point is nearest to.
func _nearest_side_name(point: Vector2) -> String:
	var distances := {
		"west": absf(point.x - view.position.x), "east": absf(point.x - view.end.x),
		"far": absf(point.y - view.position.y), "near": absf(point.y - view.end.y)}
	var best := "west"
	for side in SIDES:
		if distances[side] < distances[best]:
			best = side
	return best


## How far a point is from the footprint (0 inside it).
func _gap_to_view(point: Vector2) -> float:
	var dx := maxf(maxf(view.position.x - point.x, point.x - view.end.x), 0.0)
	var dy := maxf(maxf(view.position.y - point.y, point.y - view.end.y), 0.0)
	return Vector2(dx, dy).length()


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


## The place a ground animal lingers at: of `target_samples` random places in its habitat,
## the one nearest the middle of the footprint (so it ends up where the travelers can see it,
## or as near as its habitat comes).
func _target_near_view(habitat: String) -> Vector2:
	var centre := view.get_center()
	var best := Vector2.ZERO
	var best_d := INF
	for i in target_samples:
		var point := _target_in(habitat)
		var d := point.distance_to(centre)
		if d < best_d:
			best_d = d
			best = point
	return best


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
	elapsed += delta
	for walker in alive.duplicate():
		walker.advance(delta)
		if walker.is_done():
			if outside_view(walker.position(), walker):
				alive.erase(walker)
				exited += 1
				events.append({"event": EXIT, "walker": walker})
			else:  # the camera has come to show its exit: on to the nearest way out
				_head_out(walker)
	_until_spawn -= delta
	if _until_spawn <= 0.0 and alive.size() < cap():
		var walker := spawn()
		_until_spawn = rng.randf_range(interval_min, interval_max)
		events.append({"event": SPAWN, "walker": walker})
	return events


## Puts a new animal on the map. Null if the map is full (cap()).
func spawn() -> Walker:
	if alive.size() >= cap():
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


## The animal runs for the nearest way out of the footprint: a new route from where it is
## now (bending round the lake), no linger, no wobble, `speed_scale` times its speed. Does
## nothing twice. It draws no random numbers.
func flee(walker: Walker, speed_scale: float) -> void:
	if walker.fled:
		return
	walker.fled = true
	walker.speed_scale = speed_scale
	_head_out(walker)


## Replans the animal's way out from where it is: to the nearest point outside the footprint
## (outside by offscreen_m), straight for a flyer or a duck, round the lake for the rest.
func _head_out(walker: Walker) -> void:
	var here := walker.position()
	var out_point := Vector2.ZERO
	var out_side := "west"
	var best := INF
	for side in SIDES:
		var point := _side_nearest(side, walker, here)
		if walker.keep_out_radius > 0.0 and not _usable_ground(point):
			continue
		var d := here.distance_to(point)
		if d < best:
			best = d
			out_point = point
			out_side = side
	if best == INF:  # (nothing usable: a west point, as a last resort)
		out_point = _side_point("west", walker, 0.5)
	var route: Array[Vector2] = [here]
	if walker.keep_out_radius > 0.0:
		route.append_array(_detour(here, out_point))
	else:
		route.append(out_point)
	walker.exit = {"id": out_side, "edge": out_side, "x": out_point.x, "z": out_point.y}
	walker.route = route
	walker.travelled = 0.0
	walker.stop_dist = -1.0
	walker.linger = 0.0
	walker.lingered = 0.0
	walker.amplitude = 0.0
	walker.land_at = -1.0
	walker.takeoff_at = -1.0
	walker.finalize()


## Footprint side to footprint side: a flyer in a straight line, a ground animal by way of a
## target near the camera.
func _plan_walk(walker: Walker) -> void:
	var flies := bool(walker.kind["flies"])
	var entry := _pick_entry(walker, "air" if flies else walker.habitat, SIDES)
	var entry_point: Vector2 = entry["point"]
	var exit := _pick_exit(walker, String(entry["side"]), SIDES, not flies)
	var exit_point: Vector2 = exit["point"]
	walker.entry = {"id": entry["side"], "edge": entry["side"], "x": entry_point.x, "z": entry_point.y}
	walker.exit = {"id": exit["side"], "edge": exit["side"], "x": exit_point.x, "z": exit_point.y}
	walker.route.append(entry_point)
	if flies:
		walker.route.append(exit_point)
		return
	var target := _target_near_view(walker.habitat)
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
	var entry := _pick_entry(walker, "air", edges)
	var entry_edge := String(entry["side"])
	var entry_point: Vector2 = entry["point"]
	var exit := _pick_exit(walker, entry_edge, edges, false)
	var exit_edge := String(exit["side"])
	var exit_point: Vector2 = exit["point"]
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
