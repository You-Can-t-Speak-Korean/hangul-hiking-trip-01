extends CanvasLayer
## A hint letter on screen (data: animals.hint_letters). `open()` starts it floating in over the
## map: the exit note's own flight (Ending's flutter and ExitNote's paper, with float_s as the
## flight time) from off the right edge of the view; when it has landed it is swapped for a paper
## panel in the middle of the screen showing the Korean only, styled by the letter's format.
## Space, Enter, Esc, E or a left click closes it for good (`closed` is emitted); a close during
## the flight skips the rest. The layer runs in always mode, since the scene is paused while it is
## open, and the dim behind the paper takes the mouse.
##
## `advance(delta)` moves the flight (the layer's _process calls it); tests call it directly.

const Ending := preload("res://scenes/foraging/ending.gd")
const ExitNote := preload("res://scenes/foraging/exit_note.gd")
const HintLetters := preload("res://scenes/animals/hint_letters.gd")
const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

const CLOSE_KEYS: Array[Key] = [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_ESCAPE, KEY_E]

## Emitted when the letter has been closed.
signal closed

var config: Dictionary = {}
var ending_config: Dictionary = {}
## The panel (null until a letter has landed), and the id of the letter on screen.
var panel: PanelContainer
var letter_id := ""

var _world: Node3D
var _ending
var _note: Node3D
var _dim: ColorRect
var _center: CenterContainer
var _open := false
var _landed := false
var _bold: FontVariation


## `hint_config` is animals.hint_letters; `ending_cfg` the foraging section's ending (the exit
## note's flight and paper); `world` is the node the floating paper is added to.
func setup(hint_config: Dictionary, ending_cfg: Dictionary, world: Node3D) -> void:
	name = "HintLetterHud"
	layer = 13  # over the HUDs, under the ending's black (14) and the pause menu (15)
	process_mode = Node.PROCESS_MODE_ALWAYS
	config = hint_config
	ending_config = ending_cfg
	_world = world
	_bold = FontVariation.new()
	_bold.base_font = FONT
	_bold.variation_embolden = 0.7
	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.color = Color(0.0, 0.0, 0.0, float(hint_config["dim"]))
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.visible = false
	add_child(_dim)
	_center = CenterContainer.new()
	_center.name = "Center"
	_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_center.visible = false
	add_child(_center)


func is_open() -> bool:
	return _open


## True once the paper has landed and the panel shows.
func is_landed() -> bool:
	return _open and _landed


## Starts a letter floating in: `letter` is its data ({"format", "lines"}), `format` the style,
## `from` and `to` the flight's ends in the world. False if one is open already.
func open(id: String, letter: Dictionary, format: Dictionary, from: Vector3, to: Vector3) -> bool:
	if _open:
		return false
	_open = true
	_landed = false
	letter_id = id
	var cfg: Dictionary = ending_config.duplicate(true)
	cfg["flight_s"] = float(config["float_s"])
	var paper: Dictionary = cfg["note"]
	paper["color"] = format["bg"]
	_ending = Ending.new(cfg)
	_note = ExitNote.new()
	_note.setup(paper)
	_world.add_child(_note)
	_ending.begin_flight(from, to, Vector2(to.x, to.z), 0.0)
	_pose_note()
	_build_panel(letter, format)
	_dim.visible = true
	_center.visible = false
	return true


func _process(delta: float) -> void:
	advance(delta)


## One tick of the flight; when it is flown the paper lands as the panel.
func advance(delta: float) -> void:
	if not _open or _landed:
		return
	var ended: bool = _ending.tick_flight(delta)
	_pose_note()
	if ended:
		_ending.land()
		_landed = true
		_drop_note()
		_center.visible = true


## Closes the letter for good. False if none was open.
func close() -> bool:
	if not _open:
		return false
	_open = false
	_landed = false
	_drop_note()
	_dim.visible = false
	_center.visible = false
	if panel != null:
		panel.queue_free()
		panel = null
	letter_id = ""
	closed.emit()
	return true


## Space, Enter, Esc, E and a left click close it; every other key is left alone.
func _input(event: InputEvent) -> void:
	if not _open:
		return
	var closing := false
	if event is InputEventKey and event.pressed and not event.echo:
		closing = CLOSE_KEYS.has(event.keycode)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		closing = true
	if closing:
		get_viewport().set_input_as_handled()
		close()


func _pose_note() -> void:
	if _note == null:
		return
	var pose: Dictionary = _ending.pose()
	_note.global_position = pose["position"]
	_note.rotation = pose["rotation"]


func _drop_note() -> void:
	if _note != null and is_instance_valid(_note):
		_note.get_parent().remove_child(_note)
		_note.queue_free()
	_note = null


# ---- The paper ----

static func _rgb(channels: Array) -> Color:
	return Color(float(channels[0]), float(channels[1]), float(channels[2]))


## The panel of a letter: the first header_lines lines as a header, the rest as body lines, a
## [label, price] pair as a two-column row with the price right-aligned. Hidden until it lands.
func _build_panel(letter: Dictionary, format: Dictionary) -> void:
	if panel != null:
		panel.queue_free()
	panel = PanelContainer.new()
	panel.name = "Paper"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := StyleBoxFlat.new()
	back.bg_color = _rgb(format["bg"])
	back.border_color = _rgb(format["border"])
	back.set_border_width_all(int(format["border_px"]))
	var margin := float(format["margin"])
	back.content_margin_left = margin
	back.content_margin_right = margin
	back.content_margin_top = margin
	back.content_margin_bottom = margin
	panel.add_theme_stylebox_override("panel", back)
	var column := VBoxContainer.new()
	column.name = "Lines"
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.custom_minimum_size.x = float(format["width"]) - 2.0 * margin
	panel.add_child(column)
	var ink := _rgb(format["ink"])
	var size := int(format["font_size"])
	var header_count := int(format.get("header_lines", 0))
	var header_box: VBoxContainer = null
	var lines: Array = letter["lines"]
	for i in lines.size():
		var line = lines[i]
		if i < header_count and not HintLetters.is_row(line):
			if header_box == null:
				header_box = _make_header_box(column, format)
			header_box.add_child(_header_label(String(line), format, ink))
		elif HintLetters.is_row(line):
			column.add_child(_row(String(line[0]), String(line[1]), size, ink))
		else:
			column.add_child(_label(String(line), size, ink, HORIZONTAL_ALIGNMENT_LEFT, false))
	_center.add_child(panel)


## The container the header lines go into: inside a coloured strip if the format has one.
func _make_header_box(column: VBoxContainer, format: Dictionary) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.name = "Header"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if format.has("header_bg"):
		var strip := PanelContainer.new()
		strip.name = "HeaderStrip"
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var strip_back := StyleBoxFlat.new()
		strip_back.bg_color = _rgb(format["header_bg"])
		strip_back.set_content_margin_all(10.0)
		strip.add_theme_stylebox_override("panel", strip_back)
		strip.add_child(box)
		column.add_child(strip)
	else:
		column.add_child(box)
	return box


func _header_label(text: String, format: Dictionary, ink: Color) -> Label:
	var color := _rgb(format["header_color"]) if format.has("header_color") else ink
	var align := HORIZONTAL_ALIGNMENT_CENTER if String(format.get("header_align", "left")) == "center" else HORIZONTAL_ALIGNMENT_LEFT
	return _label(text, int(format.get("header_size", format["font_size"])), color, align, bool(format.get("header_bold", false)))


func _label(text: String, size: int, color: Color, align: HorizontalAlignment, bold: bool) -> Label:
	var label := Label.new()
	label.text = text if text != "" else " "  # a blank line keeps its height
	label.add_theme_font_override("font", _bold if bold else FONT)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


## A receipt row: the label takes the width, the price sits flush right, so prices line up in
## any font.
func _row(label_text: String, price_text: String, size: int, ink: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "Row"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var left := _label(label_text, size, ink, HORIZONTAL_ALIGNMENT_LEFT, false)
	left.name = "Label"
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.autowrap_mode = TextServer.AUTOWRAP_OFF
	var right := _label(price_text, size, ink, HORIZONTAL_ALIGNMENT_RIGHT, false)
	right.name = "Price"
	right.autowrap_mode = TextServer.AUTOWRAP_OFF  # a wrapping label has no minimum width and would be squeezed
	right.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(left)
	row.add_child(right)
	return row
