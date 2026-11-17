extends RefCounted
## What grabbing a letter off an animal with a bare hand costs, with no nodes (data: the
## `grab` block of each animals.kinds entry). Costs are in half-hearts and fall on Fernanda
## alone.
##   {"hand": false, ...}                           flyers and ducks: not by hand (tools come later)
##   {"hand": true, "units": n}                     a fixed cost
##   {"hand": true, "max_units": m, "death_chance": p}   a predator: with chance p both travelers
##                                                  die, otherwise 1..m (drawn from the seeded rng)


## True if a bare hand can take this kind's letter.
static func by_hand(kind: Dictionary) -> bool:
	return bool(kind.get("grab", {}).get("hand", false))


## The cost of one grab: {"units": half-hearts (0 for a death), "death": true if both die}.
## Draws from `rng` only for a predator (one draw for the death roll, one more if it
## survives), so a seed fixes the sequence.
static func cost(kind: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var grab: Dictionary = kind["grab"]
	if grab.has("units"):
		return {"units": int(grab["units"]), "death": false}
	if rng.randf() < float(grab["death_chance"]):
		return {"units": 0, "death": true}
	return {"units": rng.randi_range(1, int(grab["max_units"])), "death": false}
