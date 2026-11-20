extends RefCounted
## The downed countdown, shared by the foraging and animal scenes (data: rules.json
## revive.downed_countdown_s; the lockout is foraging.stuck.lockout_seconds). It is a Countdown
## (the stuck countdown's clock, HUD and music are reused) that runs while exactly one traveler
## is downed: it starts when they go down, a revive cancels it (not in the last lockout seconds),
## and at 0 the scene sends its monster for the one still standing. With both downed the scene
## is over and nothing runs.

const Countdown := preload("res://scenes/foraging/countdown.gd")

var clock


## `revive_config` is rules.json revive, `stuck_config` is foraging.stuck.
func _init(revive_config: Dictionary, stuck_config: Dictionary) -> void:
	clock = Countdown.new({
		"countdown_seconds": float(revive_config["downed_countdown_s"]),
		"lockout_seconds": float(stuck_config["lockout_seconds"]),
	})


## Exactly one traveler is downed.
static func one_downed() -> bool:
	var count := 0
	for id in GameState.TRAVELERS:
		if GameState.is_downed(id):
			count += 1
	return count == 1


## Feeds the hearts to the clock (call every tick). `allowed` is false while the scene is dying:
## then no run starts. Returns "started", "cancelled" or "".
func update(allowed: bool = true) -> String:
	return clock.verdict(one_downed(), allowed)


## The traveler still standing when exactly one is downed, else "".
static func standing() -> String:
	if not one_downed():
		return ""
	for id in GameState.TRAVELERS:
		if not GameState.is_downed(id):
			return id
	return ""
