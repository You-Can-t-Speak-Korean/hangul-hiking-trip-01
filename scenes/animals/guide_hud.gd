extends CanvasLayer
## Draws a Guide's current prompt in a small panel at the top centre: one line of English,
## faded as the Guide says. Hidden while there is no prompt.

var panel: PanelContainer
var label: Label
var _guide


func setup(guide, config: Dictionary) -> void:
	name = "GuideHud"
	layer = 9
	_guide = guide
	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.05, 0.07, 0.06, 0.75)
	back.set_corner_radius_all(8)
	back.content_margin_left = 16.0
	back.content_margin_right = 16.0
	back.content_margin_top = 8.0
	back.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", back)
	label = Label.new()
	label.name = "Text"
	label.add_theme_font_size_override("font_size", int(config["font_size"]))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	panel.offset_top = float(config["top_px"])
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.visible = false
	add_child(panel)


## Shows the Guide's prompt as it is now (call after Guide.update()).
func refresh() -> void:
	var alpha: float = _guide.alpha()
	panel.visible = alpha > 0.0
	if not panel.visible:
		return
	if label.text != _guide.text():
		label.text = _guide.text()
		panel.reset_size()
	panel.modulate.a = alpha
