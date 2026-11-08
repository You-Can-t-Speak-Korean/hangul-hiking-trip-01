extends CanvasLayer
## The black of the scene's end: a full-screen black that fades in, and a small debug
## line at the bottom left when the next scene is not built. It sits at layer 14, over
## every HUD and under the pause menu (15), so Esc opens the menu over the black.
## It ignores the mouse and never pauses; the map sets the alpha every tick.

var _black: ColorRect
var _line: Label


func setup(config: Dictionary) -> void:
	name = "EndingHud"
	layer = 14
	_black = ColorRect.new()
	_black.name = "Black"
	_black.color = Color(0.0, 0.0, 0.0, 0.0)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black.visible = false
	add_child(_black)
	_line = Label.new()
	_line.name = "DebugLine"
	_line.visible = false
	_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_line.add_theme_font_size_override("font_size", int(config["hold_font_size"]))
	var c: Array = config["hold_color"]
	_line.add_theme_color_override("font_color", Color(c[0], c[1], c[2]))
	_line.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_line.position += Vector2(16.0, -16.0 - float(config["hold_font_size"]) * 1.6)
	add_child(_line)


## 0 clear .. 1 black.
func set_alpha(alpha: float) -> void:
	_black.color.a = clampf(alpha, 0.0, 1.0)
	_black.visible = alpha > 0.0


func alpha() -> float:
	return _black.color.a if _black.visible else 0.0


func show_line(text: String) -> void:
	_line.text = text
	_line.visible = true


func hide_line() -> void:
	_line.visible = false


func line_text() -> String:
	return _line.text if _line.visible else ""
