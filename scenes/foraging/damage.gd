extends RefCounted
## What a failed spelling syllable costs, with no nodes. The map queues each
## failure as it happens and settles them when the spelling view has closed, so
## the damage lands on the map. Every failure hurts both travelers by
## failure_damage_units half-units. The both-die rule lives in GameState: as soon
## as a hit kills one traveler both are dead, so the rest of the damage is dropped
## and the death is announced once.

## Half-units each traveler loses per failure (data: foraging.damage).
var failure_units := 1
## Failures seen but not yet applied.
var pending := 0


func _init(config: Dictionary) -> void:
	failure_units = int(config["failure_damage_units"])


func queue_failure() -> void:
	pending += 1


## Applies the queued failures. Returns {"failures": how many were applied,
## "died": true if this settle killed the travelers}.
func settle() -> Dictionary:
	var applied := 0
	var died := false
	for id in GameState.TRAVELERS:
		if not GameState.is_alive(id):  # already dead: that death was announced
			pending = 0
			return {"failures": 0, "died": false}
	while pending > 0:
		pending -= 1
		if died:
			continue
		applied += 1
		for id in GameState.TRAVELERS:
			if GameState.damage_units(id, failure_units, "spelling"):
				died = true
				break
	return {"failures": applied, "died": died}
