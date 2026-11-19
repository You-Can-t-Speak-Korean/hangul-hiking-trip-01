extends CanvasLayer
## The equipped tool at the bottom left of the animal scene: its Korean name and one pip per
## use (a filled one for each use left, an empty one for each spent), or "손 Hands". Above it a
## one-line note (a wrong target) for a moment. Data: animals.tools.hud, animals.tools.note_s.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var _belt
var _config: Dictionary = {}
var _panel: PanelContainer
var _line: Label
var _note: Label
var _note_left := 0.0


## `belt` is GameState.tools; `config` is animals.tools.
func setup(belt, config: Dictionary) -> void:
	layer = 6
	name = "ToolHud"
	_belt = belt
	_config = config
	var hud: Dictionary = config["hud"]
	var margin := float(hud["margin"])
	var root := Control.new()
	root.name = "Root"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var column := VBoxContainer.new()
	column.name = "Column"
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 6)
	column.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	column.offset_left = margin
	column.offset_bottom = -margin
	column.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(column)
	_note = Label.new()
	_note.name = "Note"
	_note.add_theme_font_override("font", FONT)
	_note.add_theme_font_size_override("font_size", int(hud["note_font_size"]))
	_note.add_theme_color_override("font_color", _color(hud["note_color"]))
	_note.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.07))
	_note.add_theme_constant_override("outline_size", 6)
	_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note.visible = false
	column.add_child(_note)
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := StyleBoxFlat.new()
	back.bg_color = Color(_color(hud["back_color"]), float(hud["back_alpha"]))
	back.set_corner_radius_all(8)
	back.set_content_margin_all(float(hud["padding"]))
	_panel.add_theme_stylebox_override("panel", back)
	column.add_child(_panel)
	_line = Label.new()
	_line.name = "Line"
	_line.add_theme_font_override("font", FONT)
	_line.add_theme_font_size_override("font_size", int(hud["font_size"]))
	_line.add_theme_color_override("font_color", _color(hud["color"]))
	_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_line)
	_belt.changed.connect(refresh)
	refresh()


func _exit_tree() -> void:
	if _belt != null and _belt.changed.is_connected(refresh):
		_belt.changed.disconnect(refresh)


## The HUD text for the equipped tool (or Hands).
func line_text() -> String:
	return _line.text


func note_text() -> String:
	return _note.text if _note.visible else ""


## Shows `text` for animals.tools.note_s seconds.
func show_note(text: String) -> void:
	_note.text = text
	_note.visible = true
	_note_left = float(_config["note_s"])


func _process(delta: float) -> void:
	if _note_left > 0.0:
		_note_left -= delta
		if _note_left <= 0.0:
			_note.visible = false


## The line for an equipped instance ({} = Hands): the name and its pips.
static func text_for(equipped: Dictionary, hud: Dictionary) -> String:
	if equipped.is_empty():
		return String(hud["hands_text"])
	var def: Dictionary = Content.item(String(equipped["id"]))
	var on := int(equipped["uses"])
	var total := maxi(int(def["uses"]), on)
	return "%s %s%s" % [def["name_ko"], String(hud["pip_on"]).repeat(on), String(hud["pip_off"]).repeat(total - on)]


func refresh() -> void:
	_line.text = text_for(_belt.equipped(), _config["hud"])


static func _color(c: Array) -> Color:
	return Color(float(c[0]), float(c[1]), float(c[2]))
