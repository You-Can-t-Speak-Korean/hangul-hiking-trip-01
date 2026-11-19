extends RefCounted
## The rules of grabbing a letter with a tool, with no nodes (data: items.json kind "tool",
## animals.kinds[].class, animals.tools). A tool grab never costs hearts: it has no bite and no
## death roll; the scene only asks these functions what the tool may do.


## The animal class of a kind ("ground", "small", "flyer" or "water"; "" if it has none).
static func class_of(kind: Dictionary) -> String:
	return String(kind.get("class", ""))


## True if the tool works on the kind's class.
static func works_on(tool_def: Dictionary, kind: Dictionary) -> bool:
	return (tool_def.get("targets", []) as Array).has(class_of(kind))


## Metres the tool reaches over the ground; a reach of 0 (the gloves) is the bare hand's.
static func reach(tool_def: Dictionary, hand_reach: float) -> float:
	var metres := float(tool_def.get("reach_m", 0.0))
	return metres if metres > 0.0 else hand_reach


static func windup(tool_def: Dictionary) -> float:
	return float(tool_def.get("windup_s", 0.0))


static func is_gloves(tool_def: Dictionary) -> bool:
	return bool((tool_def.get("quirk", {}) as Dictionary).get("gloves", false))


## True if a landing grab at `distance` metres (over the ground) is still in reach.
static func in_reach(tool_def: Dictionary, distance: float, hand_reach: float) -> bool:
	return distance <= reach(tool_def, hand_reach)


## Uses one grab attempt on `kind` costs, with `uses_left` on the tool: 1, or the tool's quirk
## for that kind (a cost, or breaking at once = every use left).
static func cost(tool_def: Dictionary, kind: Dictionary, uses_left: int) -> int:
	var quirk: Dictionary = tool_def.get("quirk", {})
	if quirk.has("kind") and String(quirk["kind"]) == String(kind.get("id", "")):
		if bool(quirk.get("breaks", false)):
			return maxi(uses_left, 1)
		return maxi(int(quirk.get("cost", 1)), 1)
	return 1


## The note of a wrong target, e.g. "뜰채: water only" or "집게: small or ground only".
static func wrong_target_note(tool_def: Dictionary) -> String:
	return "%s: %s only" % [String(tool_def["name_ko"]), " or ".join(PackedStringArray(tool_def["targets"]))]


## The one use of the gloves on a bare-hand grab of `kind`: {"shredded": true} for a predator
## (they are gone at once, the normal predator rules follow), else {"shredded": false,
## "cost": 1} (no bite).
static func glove_grab(kind: Dictionary) -> Dictionary:
	return {"shredded": true} if bool(kind.get("predator", false)) else {"shredded": false, "cost": 1}
