extends CanvasLayer
## The pause menu's look: a centred panel with a title and two buttons, over a
## light dim of the map. Drawn in code, no art files. It runs while the tree is
## paused (process mode ALWAYS). Closed, its root is hidden and takes no clicks;
## open, the root covers the screen and swallows them. The keys act through
## PauseMenu; like the spelling view, it takes every player key while open, so
## none reaches the map.

const PauseMenu := preload("res://scenes/foraging/pause_menu.gd")
const SpellingCursor := preload("res://scenes/foraging/spelling_cursor.gd")

signal chosen(result: String)  ## what PauseMenu.activate() or escape() returned: "resume", "ask", "restart", "back"

const TITLE_FONT_SIZE := 30
const BUTTON_FONT_SIZE := 24
const MESSAGE_FONT_SIZE := 20
const OUTLINE_WIDTH := 4

var panel_size := Vector2(460, 330)
var button_size := Vector2(280, 58)
var button_gap := 16.0

var _menu
var _config: Dictionary = {}
var _root: Control
var _dim: ColorRect
var _panel: PanelContainer
var _title: Label
var _message: Label
var _buttons: Array[Button] = []
var _plain: StyleBoxFlat
var _focused: StyleBoxFlat


## `menu` is the PauseMenu, `config` is foraging.pause_menu.
func setup(menu, config: Dictionary) -> void:
	layer = 15  # over the hover name (10), under the death beat's dim (20)
	name = "PauseMenuHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_menu = menu
	_config = config
	panel_size = _vec(config["panel_size"])
	button_size = _vec(config["button_size"])
	button_gap = float(config["button_gap"])
	var text_color := _color(config["text_color"])
	_root = Control.new()
	_root.name = "Root"
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	_dim = ColorRect.new()
	_dim.name = "Dim"
	_dim.color = Color(0.0, 0.0, 0.0, float(config["dim_alpha"]))
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_dim)
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -panel_size.x / 2.0
	_panel.offset_right = panel_size.x / 2.0
	_panel.offset_top = -panel_size.y / 2.0
	_panel.offset_bottom = panel_size.y / 2.0
	var back := StyleBoxFlat.new()
	back.bg_color = _color(config["panel_color"])
	back.set_corner_radius_all(10)
	back.set_content_margin_all(20.0)
	_panel.add_theme_stylebox_override("panel", back)
	_root.add_child(_panel)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", int(button_gap))
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	_title = _label("Title", TITLE_FONT_SIZE, text_color)
	_title.text = str(config["title"])
	column.add_child(_title)
	_message = _label("Message", MESSAGE_FONT_SIZE, text_color)
	_message.text = str(config["confirm_text"])
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.custom_minimum_size = Vector2(panel_size.x - 40.0, 0.0)
	column.add_child(_message)
	_plain = _button_style(_color(config["button_color"]), Color(0, 0, 0, 0), 0)
	_focused = _button_style(_color(config["button_color"]), _color(config["outline_color"]), OUTLINE_WIDTH)
	for i in PauseMenu.COUNT:
		var button := Button.new()
		button.name = "Button%d" % i
		button.custom_minimum_size = button_size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.focus_mode = Control.FOCUS_NONE  # the focus is PauseMenu's, drawn by the outline
		button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
		for key in ["font_color", "font_hover_color", "font_pressed_color"]:
			button.add_theme_color_override(key, text_color)
		button.pressed.connect(choose.bind(i))
		button.mouse_entered.connect(_menu.focus_on.bind(i))
		button.mouse_entered.connect(refresh)
		column.add_child(button)
		_buttons.append(button)
	refresh()


## Shows or hides the menu to match PauseMenu, and draws the focus.
func refresh() -> void:
	var open: bool = _menu.is_open
	_root.visible = open
	if not open:
		return
	var confirming: bool = _menu.confirming
	_title.visible = not confirming
	_message.visible = confirming
	var texts: Array = [_config["yes_text"], _config["no_text"]] if confirming else [_config["resume_text"], _config["restart_text"]]
	for i in _buttons.size():
		_buttons[i].text = str(texts[i])
		var style := _focused if i == _menu.focus else _plain
		for state in ["normal", "hover", "pressed", "focus"]:
			_buttons[i].add_theme_stylebox_override(state, style)


## A press of choice `index` (the mouse): the focus moves there, then it is pressed.
func choose(index: int) -> void:
	_menu.focus_on(index)
	chosen.emit(_menu.activate())
	refresh()


## Esc, W/S and Up/Down move or press; every player key is taken while open.
func _input(event: InputEvent) -> void:
	if not _menu.is_open:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		var result: String = _menu.escape(false)
		chosen.emit(result)
		refresh()
	elif SpellingCursor.is_player_key(event):
		get_viewport().set_input_as_handled()
		var action := _action_for(event)
		if action == "up" or action == "down":
			_menu.move(-1 if action == "up" else 1)
		elif action == "pick":
			chosen.emit(_menu.activate())
		refresh()


## "up" (W, Up), "down" (S, Down) or "pick" (Space, Enter, KP Enter) for a press of
## either player's key; the menu is shared, so both act. Otherwise "".
func _action_for(event: InputEvent) -> String:
	for player in [1, 2]:
		for action in ["up", "down"]:
			if event.is_action_pressed("p%d_%s" % [player, action], true):
				return action
		if event.is_action_pressed("p%d_pick" % player):
			return "pick"
	return ""


## Where a button is on the screen (tests click its centre).
func button_rect(index: int) -> Rect2:
	return _buttons[index].get_global_rect()


func panel_rect() -> Rect2:
	return _panel.get_global_rect()


func root_visible() -> bool:
	return _root.visible


func focused_style_on(index: int) -> bool:
	return _buttons[index].get_theme_stylebox("normal") == _focused


func _label(label_name: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = label_name
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button_style(fill: Color, outline: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = outline
	style.set_border_width_all(width)
	style.set_corner_radius_all(8)
	return style


func _vec(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))


func _color(value: Array) -> Color:
	return Color(float(value[0]), float(value[1]), float(value[2]))
