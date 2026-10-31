extends RefCounted
## A random source that always answers `value` (clamped into the asked range), so
## the capture scene can force a reward roll. Anything with randi_range works.

var value := 1


func randi_range(from: int, to: int) -> int:
	return clampi(value, from, to)
