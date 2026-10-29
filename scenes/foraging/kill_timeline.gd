extends RefCounted
## When things happen in the monster's attack, with no nodes. It leaps in over
## `leap` seconds and hits the first traveler as it lands; `hit_gap` seconds
## later it hits the second; `aftermath` seconds after that the sequence is done
## and the scene hands over to the death beat. tick() returns the events that
## fell inside the tick, in order: "hit_0", "hit_1", "done".

var leap := 0.3
var hit_gap := 0.35
var aftermath := 0.5
var time := 0.0
var started := false

var _fired: Array[String] = []


## `config` is foraging.monster.
func _init(config: Dictionary) -> void:
	leap = float(config["leap_seconds"])
	hit_gap = float(config["hit_gap_seconds"])
	aftermath = float(config["aftermath_seconds"])


## False if it has started before.
func start() -> bool:
	if started:
		return false
	started = true
	time = 0.0
	return true


func hit_time(index: int) -> float:
	return leap + hit_gap * index


func end_time() -> float:
	return hit_time(1) + aftermath


func is_done() -> bool:
	return _fired.has("done")


## 0..1 across the leap.
func leap_progress() -> float:
	return clampf(time / maxf(leap, 0.001), 0.0, 1.0)


## 0..1 across the gap between the two hits (0 before the first hit).
func gap_progress() -> float:
	return clampf((time - hit_time(0)) / maxf(hit_gap, 0.001), 0.0, 1.0)


func tick(delta: float) -> Array[String]:
	var events: Array[String] = []
	if not started or is_done():
		return events
	time += delta
	for event in [["hit_0", hit_time(0)], ["hit_1", hit_time(1)], ["done", end_time()]]:
		if time >= float(event[1]) and not _fired.has(event[0]):
			_fired.append(event[0])
			events.append(event[0])
	return events
