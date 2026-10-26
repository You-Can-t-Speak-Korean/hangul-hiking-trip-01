extends RefCounted
## The picking logic, with no nodes: which plants still hold their letter, what
## is in the basket (망태기), and the bookkeeping of a click-to-walk. A plant is
## named by its index in foraging.plants.placed. A target's letter goes into the
## basket; a decoy's letter is gone and nothing is kept. A letter is picked once.
## A new Picking (a scene restart) has every letter back and an empty basket.

## Metres, seconds and steam look (data: foraging.picking).
var pick_radius := 1.3
var stuck_timeout := 1.0
var steam_duration := 0.8
var steam_color := Color(0.86, 0.88, 0.9)
## The jamo picked from targets, in pick order.
var basket: Array[String] = []
## The plant being walked to, or -1.
var walk_target := -1

## The reach ring (data: foraging.reach_ring). The same for every plant.
var ring_color := Color(0.95, 0.95, 0.85)
var ring_alpha := 0.3
var ring_radius_offset := -0.6
var ring_width := 0.07
var ring_pulse_speed := 0.6
var ring_pulse_depth := 0.4

const PROGRESS := 0.02  # metres closer that count as moving toward the target

var _slots: Array[Dictionary] = []  # per plant: {"letter", "decoy", "spot"}
var _best_distance := INF
var _stalled := 0.0
var _inside := {}  # plant index -> true, while the walker is within pick_radius


## `config` is foraging.picking, `plants_data` is foraging.plants, `ring` is
## foraging.reach_ring (optional; the defaults above are used without it).
func _init(config: Dictionary, plants_data: Dictionary, ring: Dictionary = {}) -> void:
	pick_radius = float(config["pick_radius"])
	stuck_timeout = float(config["walk_stuck_timeout"])
	steam_duration = float(config["steam_duration"])
	var c: Array = config["steam_color"]
	steam_color = Color(c[0], c[1], c[2])
	if not ring.is_empty():
		var rc: Array = ring["color"]
		ring_color = Color(rc[0], rc[1], rc[2])
		ring_alpha = float(ring["alpha"])
		ring_radius_offset = float(ring["radius_offset"])
		ring_width = float(ring["width"])
		ring_pulse_speed = float(ring["pulse_speed"])
		ring_pulse_depth = float(ring["pulse_depth"])
	var decoy := {}
	for kind in plants_data["kinds"]:
		decoy[kind["id"]] = kind["kind"] != "target"
	for entry in plants_data["placed"]:
		_slots.append({"letter": String(entry.get("letter", "")), "decoy": decoy[entry["kind"]],
				"spot": Vector2(float(entry["x"]), float(entry["z"]))})


func plant_count() -> int:
	return _slots.size()


func has_letter(index: int) -> bool:
	return index >= 0 and index < _slots.size() and _slots[index]["letter"] != ""


func letters_left() -> int:
	var count := 0
	for i in _slots.size():
		if has_letter(i):
			count += 1
	return count


## Takes the plant's letter. Returns {"result": "basket" | "steam" | "none", "letter"}:
## "none" if the letter is already gone or `allowed` is false (dead, restarting).
func pick(index: int, allowed: bool = true) -> Dictionary:
	if not allowed or not has_letter(index):
		return {"result": "none", "letter": ""}
	var slot: Dictionary = _slots[index]
	var letter: String = slot["letter"]
	slot["letter"] = ""
	if slot["decoy"]:
		return {"result": "steam", "letter": letter}
	basket.append(letter)
	return {"result": "basket", "letter": letter}


## Starts (or changes) the walk to a plant. False if its letter is gone.
func start_walk(index: int) -> bool:
	if not has_letter(index):
		return false
	walk_target = index
	_best_distance = INF
	_stalled = 0.0
	return true


func cancel_walk() -> void:
	walk_target = -1


## One tick of the walk, given the horizontal distance to the target.
## Returns "arrived" (within pick_radius), "stuck" (no progress for
## stuck_timeout seconds) or "walking". Arriving and getting stuck end the walk.
func walk_update(distance: float, delta: float) -> String:
	if walk_target < 0:
		return "idle"
	if distance <= pick_radius:
		cancel_walk()
		return "arrived"
	if distance < _best_distance - PROGRESS:
		_best_distance = distance
		_stalled = 0.0
	else:
		_stalled += delta
		if _stalled >= stuck_timeout:
			cancel_walk()
			return "stuck"
	return "walking"


## The plant that still has its letter and is nearest to `spot` (x, z) within
## pick_radius, or -1. Decoys and targets are treated alike.
func nearest_pickable(spot: Vector2) -> int:
	var best := -1
	var best_distance := INF
	for i in _slots.size():
		var distance := spot.distance_to(_slots[i]["spot"])
		if has_letter(i) and distance <= pick_radius and distance < best_distance:
			best = i
			best_distance = distance
	return best


## Call once per tick with the walker's (x, z). Returns the plants (any, with or
## without a letter) it has just come within pick_radius of, nearest last. A
## plant is reported again only after the walker has left its radius.
func entered_reach(spot: Vector2) -> Array[int]:
	var entered: Array[int] = []
	for i in _slots.size():
		var distance := spot.distance_to(_slots[i]["spot"])
		if distance <= pick_radius:
			if not _inside.has(i):
				_inside[i] = true
				entered.append(i)
		else:
			_inside.erase(i)
	entered.sort_custom(func(a: int, b: int) -> bool:
		return spot.distance_to(_slots[a]["spot"]) > spot.distance_to(_slots[b]["spot"]))
	return entered


## The ring's outer radius, and its alpha at `time` seconds (pulses between
## ring_alpha and ring_alpha * (1 - ring_pulse_depth)).
func ring_radius() -> float:
	return maxf(pick_radius + ring_radius_offset, ring_width)


func ring_alpha_at(time: float) -> float:
	var wave := 0.5 + 0.5 * cos(TAU * ring_pulse_speed * time)
	return ring_alpha * (1.0 - ring_pulse_depth * (1.0 - wave))
