extends Control
## A placeholder picture of an animal need, drawn in code (no image files), in the style of
## the foraging item_icon.gd. The picture id comes from animals.needs.pictures (need id ->
## picture id), so art can replace a picture without touching the needs. Everything is drawn
## in a unit square scaled to the smaller side of the control.

## The picture ids, each with a _draw_<id> function.
const IDS: Array[String] = ["sweet_potato", "tree", "pen", "meat", "roe_deer", "water_deer", "duck", "spider", "cucumber", "meoru", "minari"]

var picture_id := ""
## How many times the picture has been drawn (tests).
var draws := 0
var _s := 1.0


static func is_known(id: String) -> bool:
	return IDS.has(id)


func setup(id: String, px: float) -> void:
	name = "Picture"
	picture_id = id
	custom_minimum_size = Vector2(px, px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	draws += 1
	_s = minf(size.x, size.y)
	if is_known(picture_id):
		call("_draw_%s" % picture_id)


func _p(x: float, y: float) -> Vector2:
	return Vector2(x, y) * _s


func _poly(points: Array, color: Color) -> void:
	var packed := PackedVector2Array()
	for point: Vector2 in points:
		packed.append(_p(point.x, point.y))
	draw_colored_polygon(packed, color)


func _ellipse(centre: Vector2, radii: Vector2, color: Color, angle := 0.0, steps := 28) -> void:
	var packed := PackedVector2Array()
	for i in steps:
		var t := TAU * float(i) / float(steps)
		var local := Vector2(cos(t) * radii.x, sin(t) * radii.y).rotated(angle)
		packed.append(_p(centre.x + local.x, centre.y + local.y))
	draw_colored_polygon(packed, color)


func _line(a: Vector2, b: Vector2, color: Color, width: float) -> void:
	draw_line(_p(a.x, a.y), _p(b.x, b.y), color, maxf(1.0, width * _s))


## Purple-red oval, slightly curved, with a tuft at one end.
func _draw_sweet_potato() -> void:
	var skin := Color(0.58, 0.18, 0.3)
	for i in 16:  # the curved body: an arc of overlapping ovals along a bend
		var t := float(i) / 15.0
		var centre := Vector2(0.2 + 0.6 * t, 0.62 - 0.12 * sin(t * PI))
		_ellipse(centre, Vector2(0.17, 0.2 * (1.0 - 0.35 * absf(t - 0.5) * 2.0)), skin)
	_ellipse(Vector2(0.4, 0.55), Vector2(0.06, 0.03), Color(0.74, 0.34, 0.45), -0.3)  # a highlight
	_line(Vector2(0.2, 0.62), Vector2(0.1, 0.5), Color(0.35, 0.5, 0.2), 0.05)  # the tuft
	_line(Vector2(0.2, 0.62), Vector2(0.08, 0.6), Color(0.35, 0.5, 0.2), 0.05)
	_line(Vector2(0.2, 0.62), Vector2(0.12, 0.42), Color(0.35, 0.5, 0.2), 0.04)


## Green cone on a brown trunk.
func _draw_tree() -> void:
	draw_rect(Rect2(_p(0.43, 0.7), Vector2(0.14, 0.24) * _s), Color(0.45, 0.3, 0.17))
	_poly([Vector2(0.5, 0.06), Vector2(0.84, 0.76), Vector2(0.16, 0.76)], Color(0.2, 0.55, 0.25))


## A square fence: 5 brown posts and 2 rails.
func _draw_pen() -> void:
	var wood := Color(0.5, 0.33, 0.18)
	_line(Vector2(0.1, 0.4), Vector2(0.9, 0.4), wood, 0.06)
	_line(Vector2(0.1, 0.64), Vector2(0.9, 0.64), wood, 0.06)
	for i in 5:
		var x := 0.12 + 0.19 * i
		draw_rect(Rect2(_p(x - 0.04, 0.22), Vector2(0.08, 0.6) * _s), wood.darkened(0.12))


## A red steak with a white bone.
func _draw_meat() -> void:
	_ellipse(Vector2(0.46, 0.5), Vector2(0.34, 0.26), Color(0.75, 0.15, 0.17), 0.3)
	_ellipse(Vector2(0.42, 0.46), Vector2(0.2, 0.13), Color(0.86, 0.3, 0.3), 0.3)
	_line(Vector2(0.42, 0.62), Vector2(0.8, 0.28), Color.WHITE, 0.07)  # the bone and its knobs
	draw_circle(_p(0.82, 0.24), 0.06 * _s, Color.WHITE)
	draw_circle(_p(0.85, 0.32), 0.06 * _s, Color.WHITE)


## A deer's side silhouette: body, four legs, neck, head. Shared by both deer.
func _deer(color: Color) -> void:
	_ellipse(Vector2(0.45, 0.5), Vector2(0.27, 0.15), color)
	for x in [0.28, 0.36, 0.55, 0.63]:
		_line(Vector2(x, 0.55), Vector2(x - 0.01, 0.86), color, 0.05)
	_line(Vector2(0.65, 0.45), Vector2(0.78, 0.28), color, 0.08)  # the neck
	_ellipse(Vector2(0.82, 0.26), Vector2(0.09, 0.06), color, 0.35)
	draw_circle(_p(0.84, 0.24), 0.012 * _s + 0.5, Color.BLACK)  # the eye


## Brown deer with small antlers.
func _draw_roe_deer() -> void:
	_deer(Color(0.62, 0.4, 0.2))
	var horn := Color(0.88, 0.8, 0.62)
	_line(Vector2(0.78, 0.2), Vector2(0.74, 0.07), horn, 0.025)
	_line(Vector2(0.76, 0.14), Vector2(0.69, 0.11), horn, 0.02)
	_line(Vector2(0.82, 0.2), Vector2(0.86, 0.07), horn, 0.025)
	_line(Vector2(0.84, 0.14), Vector2(0.91, 0.11), horn, 0.02)


## Tan deer with no antlers and two small white fangs.
func _draw_water_deer() -> void:
	_deer(Color(0.78, 0.62, 0.38))
	_poly([Vector2(0.86, 0.3), Vector2(0.88, 0.4), Vector2(0.9, 0.3)], Color.WHITE)
	_poly([Vector2(0.92, 0.3), Vector2(0.94, 0.4), Vector2(0.96, 0.3)], Color.WHITE)


## A duck from the side: green head, brown body, orange beak.
func _draw_duck() -> void:
	_poly([Vector2(0.14, 0.5), Vector2(0.04, 0.36), Vector2(0.3, 0.46)], Color(0.45, 0.3, 0.16))  # the tail
	_ellipse(Vector2(0.45, 0.58), Vector2(0.3, 0.2), Color(0.55, 0.36, 0.18))
	_ellipse(Vector2(0.45, 0.6), Vector2(0.17, 0.09), Color(0.42, 0.27, 0.13), -0.2)  # the wing
	draw_circle(_p(0.72, 0.32), 0.14 * _s, Color(0.12, 0.55, 0.28))
	_poly([Vector2(0.84, 0.3), Vector2(0.98, 0.35), Vector2(0.84, 0.4)], Color(0.97, 0.6, 0.12))
	draw_circle(_p(0.74, 0.28), 0.02 * _s + 0.5, Color.BLACK)


## A black round body with eight bent legs.
func _draw_spider() -> void:
	var black := Color(0.08, 0.08, 0.1)
	for side in [-1.0, 1.0]:
		for i in 4:
			var y := 0.4 + 0.07 * i
			var knee := Vector2(0.5 + side * (0.3 + 0.04 * (i % 2)), y - 0.17)
			var foot := Vector2(0.5 + side * (0.42 - 0.02 * i), y + 0.18 + 0.03 * i)
			_line(Vector2(0.5 + side * 0.08, y + 0.04), knee, black, 0.035)
			_line(knee, foot, black, 0.035)
	draw_circle(_p(0.5, 0.55), 0.17 * _s, black)
	draw_circle(_p(0.5, 0.38), 0.1 * _s, black)
	draw_circle(_p(0.46, 0.36), 0.02 * _s + 0.5, Color(0.9, 0.2, 0.2))
	draw_circle(_p(0.54, 0.36), 0.02 * _s + 0.5, Color(0.9, 0.2, 0.2))


## A long green rounded bar with a few light dots.
func _draw_cucumber() -> void:
	var green := Color(0.2, 0.5, 0.2)
	draw_rect(Rect2(_p(0.2, 0.38), Vector2(0.6, 0.24) * _s), green)
	draw_circle(_p(0.2, 0.5), 0.12 * _s, green)
	draw_circle(_p(0.8, 0.5), 0.12 * _s, green)
	for p: Vector2 in [Vector2(0.3, 0.44), Vector2(0.44, 0.56), Vector2(0.56, 0.43), Vector2(0.68, 0.55), Vector2(0.8, 0.46)]:
		draw_circle(_p(p.x, p.y), 0.02 * _s + 0.5, Color(0.7, 0.88, 0.6))


## A cluster of small dark-purple circles with a leaf.
func _draw_meoru() -> void:
	_ellipse(Vector2(0.7, 0.2), Vector2(0.17, 0.08), Color(0.25, 0.6, 0.25), -0.5)
	_line(Vector2(0.5, 0.3), Vector2(0.52, 0.18), Color(0.3, 0.45, 0.2), 0.03)
	var grapes: Array[Vector2] = [Vector2(0.38, 0.38), Vector2(0.52, 0.38), Vector2(0.64, 0.4), Vector2(0.44, 0.52), Vector2(0.58, 0.54), Vector2(0.36, 0.6), Vector2(0.5, 0.68), Vector2(0.65, 0.68), Vector2(0.5, 0.82)]
	for grape in grapes:
		draw_circle(_p(grape.x, grape.y), 0.085 * _s, Color(0.22, 0.1, 0.34))
		draw_circle(_p(grape.x - 0.025, grape.y - 0.025), 0.02 * _s, Color(0.45, 0.3, 0.6))


## Three thin green stalks with leaf sprigs.
func _draw_minari() -> void:
	var stalk := Color(0.25, 0.55, 0.22)
	for stem in [[0.3, 0.16], [0.5, 0.06], [0.7, -0.14]]:
		var x: float = stem[0]
		var lean: float = stem[1]
		_line(Vector2(x, 0.92), Vector2(x + lean, 0.3), stalk, 0.035)
		for t in [0.45, 0.7, 1.0]:
			var at := Vector2(x + lean * t * 0.85, 0.92 - 0.62 * t * 0.9)
			_ellipse(at + Vector2(-0.06, -0.03), Vector2(0.07, 0.03), Color(0.35, 0.68, 0.3), -0.5)
			_ellipse(at + Vector2(0.06, -0.03), Vector2(0.07, 0.03), Color(0.35, 0.68, 0.3), 0.5)
