extends RefCounted
## What meeting a need drops, with no nodes (data: animals.need_rewards): per tier of the
## animal kind the need was discovered from, each item has its own chance, rolled one after
## the other. Seeded: one seed gives one sequence.


## The items won by one roll on `tier` (a name in `table`: {tier: {item: chance}}), in the
## table's order. One random number is drawn per item, whatever the outcome.
static func roll(table: Dictionary, tier: String, rng: RandomNumberGenerator) -> Array[String]:
	var won: Array[String] = []
	var chances: Dictionary = table.get(tier, {})
	for item in chances:
		if rng.randf() < float(chances[item]):
			won.append(String(item))
	return won
