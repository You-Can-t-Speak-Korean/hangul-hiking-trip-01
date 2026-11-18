extends RefCounted
## What a failed spelling syllable costs, with no nodes. The map queues each
## failure as it happens and settles them when the spelling view has closed, so
## the damage lands on the map. Every failure hurts both travelers by
## failure_damage_units half-units (a downed traveler takes none). The down rule lives in
## GameState: a traveler at 0 is downed, and the scene ends when both are, so the rest of the
## damage is dropped then and the end is announced once.

## Half-units each traveler loses per failure (data: foraging.damage).
var failure_units := 1
## Failures seen but not yet applied.
var pending := 0


func _init(config: Dictionary) -> void:
	failure_units = int(config["failure_damage_units"])


func queue_failure() -> void:
	pending += 1


## Applies the queued failures to every traveler still standing (a downed traveler takes none).
## Returns {"failures": how many were applied, "died": true if this settle downed both
## travelers, which ends the scene}.
func settle() -> Dictionary:
	var applied := 0
	var died := false
	if GameState.all_downed():  # the end was announced already
		pending = 0
		return {"failures": 0, "died": false}
	while pending > 0:
		pending -= 1
		if died:
			continue
		applied += 1
		for id in GameState.TRAVELERS:
			if not GameState.is_downed(id) and GameState.damage_units(id, failure_units, "spelling"):
				died = true
				break
	return {"failures": applied, "died": died}
