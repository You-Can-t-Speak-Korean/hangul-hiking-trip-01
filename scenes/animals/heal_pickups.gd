extends RefCounted
## Where the healing bottles lie on the map, with no nodes (data: animals.heal_pickups).
## Seeded: at scene start `count_min`..`count_max` of them, each item rolled by weight, each
## at a random walkable land point that is not in the lake, at least `min_spacing_m` from the
## travelers' starts and from the other bottles.


## [{"item", "spot"}]. `bounds` is where a traveler's feet may stand (x, z); the lake is a
## half disc (centre, radius, clearance) that nothing is put in or beside; `starts` are the
## travelers' start spots.
static func place(config: Dictionary, seed_value: int, bounds: Rect2, lake_center: Vector2, lake_radius: float, clearance: float, starts: Array) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var spacing := float(config["min_spacing_m"])
	var items: Array = config["weights"].keys()
	var weights := PackedFloat32Array()
	for item in items:
		weights.append(float(config["weights"][item]))
	var count := rng.randi_range(int(config["count_min"]), int(config["count_max"]))
	var placed: Array[Dictionary] = []
	for n in count:
		var item := String(items[rng.rand_weighted(weights)])
		for attempt in 400:
			var spot := Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
			if spot.distance_to(lake_center) < lake_radius + clearance and spot.y <= lake_center.y + clearance:
				continue
			var clear := true
			for start in starts:
				clear = clear and spot.distance_to(start) >= spacing
			for other in placed:
				clear = clear and spot.distance_to(other["spot"]) >= spacing
			if clear:
				placed.append({"item": item, "spot": spot})
				break
	return placed
