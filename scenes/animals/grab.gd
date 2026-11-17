extends RefCounted
## What grabbing a letter off an animal with a bare hand costs, with no nodes (data: the
## `grab` block of each animals.kinds entry). Costs are in half-hearts and fall on Fernanda
## alone.
##   {"hand": false, ...}                           flyers and ducks: not by hand (tools come later)
##   {"hand": true, "units": n, "bite_chance": p}   with chance p it bites for n (always without bite_chance)
##   {"hand": true, "max_units": m, "death_chance": p}   a predator: with chance p both travelers
##                                                  die, otherwise 1..m (drawn from the seeded rng)


## True if a bare hand can take this kind's letter.
static func by_hand(kind: Dictionary) -> bool:
	return bool(kind.get("grab", {}).get("hand", false))


## The cost of one grab: {"units": half-hearts (0 for a death or a grab that did not bite),
## "death": true if both die, "bite": true if the animal bit}. Draws from `rng` for a kind
## with a bite_chance (one draw) and for a predator (one draw for the death roll, one more if
## it survives), so a seed fixes the sequence.
static func cost(kind: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var grab: Dictionary = kind["grab"]
	if grab.has("units"):
		if grab.has("bite_chance") and rng.randf() >= float(grab["bite_chance"]):
			return {"units": 0, "death": false, "bite": false}
		return {"units": int(grab["units"]), "death": false, "bite": true}
	if rng.randf() < float(grab["death_chance"]):
		return {"units": 0, "death": true, "bite": true}
	return {"units": rng.randi_range(1, int(grab["max_units"])), "death": false, "bite": true}
