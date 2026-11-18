extends Control
## The thought bubble over an animal that has shown a need (data: animals.bubble): a rounded
## white panel holding the need's picture, with two small circles trailing toward the
## animal's head. The control's bottom-centre is the point it hangs from. It is fully
## visible for show_s seconds, then fades out over fade_s and is finished (`expired()`).

const NeedPicture := preload("res://scenes/animals/need_picture.gd")

var need_id := ""
var walker_id := 0
var age := 0.0
var show_s := 4.0
var fade_s := 1.0
var picture: Control

var _panel := Vector2(92, 80)
var _corner := 18
var _fill := Color.WHITE
var _border := Color(0.25, 0.25, 0.25)
var _border_px := 2
var _trail: Array = []


## `config` is animals.bubble; `picture_id` is a NeedPicture id.
func setup(config: Dictionary, id: String, walker: int, picture_id: String) -> void:
	name = "Bubble_%s" % id
	need_id = id
	walker_id = walker
	show_s = float(config["show_s"])
	fade_s = float(config["fade_s"])
	_panel = Vector2(float(config["panel"][0]), float(config["panel"][1]))
	_corner = int(config["corner"])
	_fill = _color(config["color"])
	_border = _color(config["border"])
	_border_px = int(config["border_px"])
	_trail = config["trail"]
	var below := 0.0
	for circle in _trail:
		below = maxf(below, float(circle[1]) + float(circle[0]))
	custom_minimum_size = Vector2(_panel.x, _panel.y + below)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var px := float(config["pic_px"])
	picture = NeedPicture.new()
	picture.setup(picture_id, px)
	picture.position = (_panel - Vector2(px, px)) / 2.0
	add_child(picture)


## The opacity at an age: 1 until show_s, then down to 0 over fade_s.
static func alpha_at(at: float, shown: float, fade: float) -> float:
	if at <= shown:
		return 1.0
	return clampf(1.0 - (at - shown) / maxf(fade, 0.001), 0.0, 1.0)


func alpha() -> float:
	return alpha_at(age, show_s, fade_s)


func expired() -> bool:
	return age >= show_s + fade_s


## Ages the bubble and sets its opacity.
func advance(delta: float) -> void:
	age += delta
	modulate.a = alpha()


## Hangs the bubble's bottom-centre from a screen point.
func hang_from(screen: Vector2) -> void:
	position = screen - Vector2(size.x / 2.0, size.y)


func _draw() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = _fill
	box.set_corner_radius_all(_corner)
	box.set_border_width_all(_border_px)
	box.border_color = _border
	draw_style_box(box, Rect2(Vector2.ZERO, _panel))
	for circle in _trail:
		var centre := Vector2(size.x / 2.0, _panel.y + float(circle[1]))
		draw_circle(centre, float(circle[0]) + _border_px, _border)
		draw_circle(centre, float(circle[0]), _fill)


static func _color(channels: Array) -> Color:
	return Color(float(channels[0]), float(channels[1]), float(channels[2]))
