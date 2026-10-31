extends CanvasLayer
## Fernanda's backpack: a panel titled "Fernanda's backpack" with one row per item
## in GameState.inventory (Korean name, English name, ×count, and the description
## in smaller text), or "Empty". Placed and sized from foraging.backpack_hud. It
## runs while the tree is paused (process mode ALWAYS). The panel swallows clicks;
## the layer's root does not. The rows are not selectable yet.
## Keys: while it is open, either backpack key, Esc and the Close button ask the
## map to close it; while it is closed, a backpack key asks the map to open it
## through `open_handler` (and is only taken if the map did). This runs in
## _input, ahead of the GUI's own Tab focus navigation, so Tab can't be
## swallowed first; a Tab the map turns down is left alone.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

## The panel should close (key, Esc or the Close button). The map unpauses on this.
signal close_requested

## Called when a backpack key is pressed while the panel is closed. Returns true
## if the map opened it. Set by the map.
var open_handler := Callable()

var _backpack
var _inventory
var _config: Dictionary = {}
var _root: Control
var _panel: PanelContainer
var _title: Label
var _close_button: Button
var _empty: Label
var _scroll: ScrollContainer
var _rows: VBoxContainer


## `backpack` is the Backpack, `inventory` the Inventory to list, `config` is
## foraging.backpack_hud.
func setup(backpack, inventory, config: Dictionary) -> void:
	layer = 12  # over the hover name (10), under the pause menu (15) and the death beat's dim (20)
	name = "BackpackHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_backpack = backpack
	_inventory = inventory
	_config = config
	var text_color := _color(config["text_color"])
	_root = Control.new()
	_root.name = "Root"
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE  # only the panel swallows clicks
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	var top_left := _vec(config["position"])
	var panel_size := _vec(config["size"])
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.position = top_left
	_panel.size = panel_size
	_panel.custom_minimum_size = panel_size
	var back := StyleBoxFlat.new()
	back.bg_color = Color(_color(config["panel_color"]), float(config["panel_alpha"]))
	back.set_corner_radius_all(10)
	back.set_content_margin_all(16.0)
	_panel.add_theme_stylebox_override("panel", back)
	_root.add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(header)
	_title = _label("Title", int(config["title_font_size"]), text_color)
	_title.text = str(config["title"])
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title)
	_close_button = Button.new()
	_close_button.name = "Close"
	_close_button.text = str(config["close_text"])
	_close_button.focus_mode = Control.FOCUS_NONE
	_close_button.add_theme_font_size_override("font_size", int(config["button_font_size"]))
	_close_button.pressed.connect(close_requested.emit)
	header.add_child(_close_button)
	_scroll = ScrollContainer.new()
	_scroll.name = "Scroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.name = "Rows"
	_rows.add_theme_constant_override("separation", 8)
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scroll.add_child(_rows)
	_empty = _label("Empty", int(config["empty_font_size"]), _color(config["muted_text_color"]))
	_empty.text = str(config["empty_text"])
	_empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_empty)
	_inventory.changed.connect(refresh)
	refresh()


func _exit_tree() -> void:
	if _inventory != null and _inventory.changed.is_connected(refresh):
		_inventory.changed.disconnect(refresh)


## Shows or hides the panel to match the Backpack, and redraws the rows.
func refresh() -> void:
	_root.visible = _backpack.is_open
	for row in _rows.get_children():
		_rows.remove_child(row)
		row.queue_free()
	var items: Array = _inventory.items()
	for entry in items:
		_rows.add_child(_make_row(entry["id"], int(entry["count"])))
	_empty.visible = items.is_empty()
	_scroll.visible = not items.is_empty()


## Backpack keys and Esc. The map is paused while it is open, so its own
## _unhandled_input is not reached: this is where the keys are read.
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if _backpack.is_open:
		if event.keycode == KEY_ESCAPE or is_backpack_key(event):
			get_viewport().set_input_as_handled()
			close_requested.emit()
	elif is_backpack_key(event) and open_handler.is_valid() and open_handler.call():
		get_viewport().set_input_as_handled()


## True for a press of either player's backpack key.
static func is_backpack_key(event: InputEvent) -> bool:
	return event.is_action_pressed("backpack_p1") or event.is_action_pressed("backpack_p2")


func panel_rect() -> Rect2:
	return _panel.get_global_rect()


func close_button_rect() -> Rect2:
	return _close_button.get_global_rect()


func panel_visible() -> bool:
	return _root.visible


func row_count() -> int:
	return _rows.get_child_count()


## A row's labels by node name: "NameKo" (absent for an item without a Korean
## name), "NameEn", "Count", "Description".
func row_label(index: int, label_name: String) -> Label:
	return _rows.get_child(index).find_child(label_name, true, false) as Label


func row_rect(index: int) -> Rect2:
	return (_rows.get_child(index) as Control).get_global_rect()


func empty_visible() -> bool:
	return _empty.visible


func empty_text() -> String:
	return _empty.text


## id of the item a row shows (tests).
func row_id(index: int) -> String:
	return String(_rows.get_child(index).get_meta("item_id"))


func _make_row(id: String, count: int) -> PanelContainer:
	var item: Dictionary = Content.item(id)
	var row := PanelContainer.new()
	row.name = "Row_" + id
	row.set_meta("item_id", id)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = _color(_config["row_color"])
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10.0)
	row.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(top)
	var text_color := _color(_config["text_color"])
	var name_size := int(_config["name_font_size"])
	if String(item.get("name_ko", "")) != "":
		var ko := _label("NameKo", name_size, text_color)
		ko.text = String(item["name_ko"])
		ko.add_theme_font_override("font", FONT)
		top.add_child(ko)
	var en := _label("NameEn", name_size, text_color)
	en.text = String(item.get("name_en", id))
	en.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(en)
	var amount := _label("Count", int(_config["count_font_size"]), _color(_config["count_color"]))
	amount.text = "×%d" % count
	top.add_child(amount)
	var description := _label("Description", int(_config["description_font_size"]), _color(_config["muted_text_color"]))
	description.text = String(item.get("description_en", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(description)
	return row


func _label(label_name: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = label_name
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _vec(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))


func _color(value: Array) -> Color:
	return Color(float(value[0]), float(value[1]), float(value[2]))
