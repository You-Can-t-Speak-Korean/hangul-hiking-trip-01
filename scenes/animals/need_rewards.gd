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


## The tool one roll on `tier` wins (Prompt 9c), or "": `chances` is animals.tool_rewards
## ({tier: chance}) and `weights` animals.tool_pickups.weights ({tool id: weight}). One random
## number is drawn for the chance and, on a win, one more for which tool.
static func roll_tool(chances: Dictionary, tier: String, weights: Dictionary, rng: RandomNumberGenerator) -> String:
	if rng.randf() >= float(chances.get(tier, 0.0)):
		return ""
	var ids: Array = weights.keys()
	var w := PackedFloat32Array()
	for id in ids:
		w.append(float(weights[id]))
	return String(ids[rng.rand_weighted(w)])
