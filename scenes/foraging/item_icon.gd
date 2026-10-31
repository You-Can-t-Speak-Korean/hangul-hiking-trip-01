extends Control
## A placeholder item icon drawn in code (items.json "icon"). Replaced by real
## art later. "baekseolgi": a plain steamed white rice cake (백설기), a soft white
## rounded square with faint grey shading and a few tiny pores.

const KNOWN: Array[String] = ["baekseolgi"]

var icon_id := ""


static func is_known(id: String) -> bool:
	return KNOWN.has(id)


func setup(id: String, icon_size: float) -> void:
	name = "Icon"
	icon_id = id
	custom_minimum_size = Vector2(icon_size, icon_size)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if icon_id == "baekseolgi":
		_draw_baekseolgi()


func _draw_baekseolgi() -> void:
	var s := minf(size.x, size.y)
	var pad := s * 0.08
	var body := Rect2(Vector2(pad, pad), Vector2(s, s) - Vector2(pad, pad) * 2.0)
	var radius := int(s * 0.22)
	var shade := StyleBoxFlat.new()  # the faint grey underside, offset down and right
	shade.bg_color = Color(0.78, 0.79, 0.8)
	shade.set_corner_radius_all(radius)
	draw_style_box(shade, Rect2(body.position + Vector2(s, s) * 0.03, body.size))
	var cake := StyleBoxFlat.new()
	cake.bg_color = Color(0.97, 0.97, 0.95)
	cake.set_corner_radius_all(radius)
	draw_style_box(cake, Rect2(body.position, body.size - Vector2(s, s) * 0.03))
	var pore := Color(0.82, 0.83, 0.82)
	for p: Vector2 in [Vector2(0.32, 0.3), Vector2(0.62, 0.26), Vector2(0.48, 0.5), Vector2(0.72, 0.55), Vector2(0.3, 0.66), Vector2(0.55, 0.74)]:
		draw_circle(p * s, maxf(1.0, s * 0.028), pore)
