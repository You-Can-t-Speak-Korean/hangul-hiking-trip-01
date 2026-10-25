extends RefCounted
## Ground height as a function of x, from the mountain JSON ("terrain").
## A monotone cubic through [x, height] points: smooth (no steps, no kinks),
## never overshooting between points, and flat at both ends. Beyond the first
## and last point the ground stays flat at that point's height.

var xs: Array[float] = []
var hs: Array[float] = []
var _tangents: Array[float] = []


func _init(points: Array) -> void:
	for p in points:
		xs.append(float(p[0]))
		hs.append(float(p[1]))
	var n := xs.size()
	_tangents.resize(n)
	_tangents.fill(0.0)
	for k in range(1, n - 1):
		var left := (hs[k] - hs[k - 1]) / (xs[k] - xs[k - 1])
		var right := (hs[k + 1] - hs[k]) / (xs[k + 1] - xs[k])
		_tangents[k] = 0.0 if left * right <= 0.0 else (left + right) / 2.0
	# Fritsch-Carlson limiter keeps each segment monotone.
	for k in n - 1:
		var secant := (hs[k + 1] - hs[k]) / (xs[k + 1] - xs[k])
		if is_zero_approx(secant):
			_tangents[k] = 0.0
			_tangents[k + 1] = 0.0
			continue
		var a := _tangents[k] / secant
		var b := _tangents[k + 1] / secant
		var mag := sqrt(a * a + b * b)
		if mag > 3.0:
			_tangents[k] = 3.0 * a / mag * secant
			_tangents[k + 1] = 3.0 * b / mag * secant


func min_x() -> float:
	return xs[0]


func max_x() -> float:
	return xs[xs.size() - 1]


func height_at(x: float) -> float:
	if x <= xs[0]:
		return hs[0]
	if x >= xs[xs.size() - 1]:
		return hs[hs.size() - 1]
	var k := _segment(x)
	var width := xs[k + 1] - xs[k]
	var t := (x - xs[k]) / width
	var t2 := t * t
	var t3 := t2 * t
	return (2.0 * t3 - 3.0 * t2 + 1.0) * hs[k] \
		+ (t3 - 2.0 * t2 + t) * width * _tangents[k] \
		+ (-2.0 * t3 + 3.0 * t2) * hs[k + 1] \
		+ (t3 - t2) * width * _tangents[k + 1]


## dh/dx (rise over run).
func slope_at(x: float) -> float:
	if x <= xs[0] or x >= xs[xs.size() - 1]:
		return 0.0
	var k := _segment(x)
	var width := xs[k + 1] - xs[k]
	var t := (x - xs[k]) / width
	var t2 := t * t
	return ((6.0 * t2 - 6.0 * t) * hs[k] \
		+ (3.0 * t2 - 4.0 * t + 1.0) * width * _tangents[k] \
		+ (-6.0 * t2 + 6.0 * t) * hs[k + 1] \
		+ (3.0 * t2 - 2.0 * t) * width * _tangents[k + 1]) / width


func _segment(x: float) -> int:
	var k := 0
	while k < xs.size() - 2 and x > xs[k + 1]:
		k += 1
	return k
