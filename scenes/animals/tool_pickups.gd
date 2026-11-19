extends RefCounted
## Where the tools lie on the map, with no nodes (data: animals.tool_pickups). Seeded: at scene
## start the 등산스틱 spot (always one, placed first) and `count_min`..`count_max` tools, each
## rolled by weight, each at a random walkable land point outside the lake, at least
## `min_spacing_m` from the travelers' starts, from the bottles (`avoid`) and from each other.
## A 뜰채 lies within `shore_m` of the lake shore.


## [{"item", "spot", "pole": bool}]. `bounds` is where a traveler's feet may stand (x, z); the
## lake is a half disc (centre, radius, clearance) that nothing is put in or beside; `starts`
## are the travelers' start spots and `avoid` any other spots to keep clear (the bottles).
static func place(config: Dictionary, seed_value: int, bounds: Rect2, lake_center: Vector2, lake_radius: float, clearance: float, starts: Array, avoid: Array = []) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var spacing := float(config["min_spacing_m"])
	var items: Array = config["weights"].keys()
	var weights := PackedFloat32Array()
	for item in items:
		weights.append(float(config["weights"][item]))
	var count := rng.randi_range(int(config["count_min"]), int(config["count_max"]))
	var keep: Array = starts.duplicate()
	keep.append_array(avoid)
	var placed: Array[Dictionary] = []
	var wanted: Array[Dictionary] = [{"item": String(config["pole_spot"]["item"]), "pole": true}]
	for n in count:
		wanted.append({"item": String(items[rng.rand_weighted(weights)]), "pole": false})
	for want in wanted:
		var near_shore: bool = want["item"] == "tteulchae"
		for attempt in 600:
			var spot := Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
			if spot.distance_to(lake_center) < lake_radius + clearance and spot.y <= lake_center.y + clearance:
				continue
			if near_shore and spot.distance_to(lake_center) - lake_radius > float(config["shore_m"]):
				continue
			var clear := true
			for other in keep:
				clear = clear and spot.distance_to(other) >= spacing
			for other in placed:
				clear = clear and spot.distance_to(other["spot"]) >= spacing
			if clear:
				placed.append({"item": want["item"], "spot": spot, "pole": want["pole"]})
				break
	return placed
