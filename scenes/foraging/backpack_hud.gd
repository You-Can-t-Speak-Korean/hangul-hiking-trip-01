extends CanvasLayer
## Fernanda's backpack: a panel titled "Fernanda's backpack" with one row per item
## in GameState.inventory (Korean name, English name, ×count, and the description
## in smaller text), or "Empty". Placed and sized from foraging.backpack_hud. It
## runs while the tree is paused (process mode ALWAYS). The panel swallows clicks;
## the layer's root does not. Elixir rows can be selected (a click, or the
## players' movement keys and Space / Enter); selecting one asks who drinks it, and
## the answer drinks it (see Backpack). A row whose item has an icon (items.json) draws it on the left, `icon_size` pixels square.
## Keys: while it is open, either backpack key, Esc and the Close button ask the
## map to close it; while it is closed, a backpack key asks the map to open it
## through `open_handler` (and is only taken if the map did). This runs in
## _input, ahead of the GUI's own Tab focus navigation, so Tab can't be
## swallowed first; a Tab the map turns down is left alone.
##
## The 수첩 (notebook) row is selectable too: choosing it (Space / Enter or a
## click) shows the notebook view in the panel in place of the list: one cream page
## with the newest note's text only (look: data/series/notebook.json), ◀ ▶ outside
## the page edge when a page exists that way, and a scroll when the text does not
## fit. Flip with A / D or Left / Right, scroll with W / S or Up / Down. Esc (or
## the Back button) returns to the list. A notebook quick key (Q, /) opens the same
## view with no list behind it through `notebook_open_handler`; then Esc or the
## same quick key closes the panel, and the backpack keys do nothing.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const ItemIcon := preload("res://scenes/foraging/item_icon.gd")
const BackpackLogic := preload("res://scenes/foraging/backpack.gd")
const BookLogic := preload("res://scenes/foraging/notebook.gd")

## The panel should close (key, Esc or the Close button). The map unpauses on this.
signal close_requested

## Called when a backpack key is pressed while the panel is closed. Returns true
## if the map opened it. Set by the map.
var open_handler := Callable()
## Called with the input action ("notebook_p1" or "notebook_p2") of a notebook quick
## key pressed while the panel is closed. Returns true if the map opened it.
var notebook_open_handler := Callable()

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
var _choice: PanelContainer
var _choice_prompt: Label
var _choice_buttons: Array[Button] = []
var _message: Label
var _book: HBoxContainer
var _book_previous: Label
var _book_next: Label
var _book_page: PanelContainer
var _book_scroll: ScrollContainer
var _book_text: Label
var _book_empty: Label
var _book_config: Dictionary = {}
var _book_shown := "<closed>"  # the note id on the page (or "" for the empty state) the last time it was drawn


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
	_close_button.pressed.connect(_on_close_pressed)
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
	_build_choice(column)
	_build_book(column)
	_message = _label("Message", int(config["message_font_size"]), _color(config["message_color"]))
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.visible = false
	column.add_child(_message)
	_inventory.changed.connect(refresh)
	GameState.hearts_changed.connect(_on_hearts_changed)
	refresh()


func _exit_tree() -> void:
	if _inventory != null and _inventory.changed.is_connected(refresh):
		_inventory.changed.disconnect(refresh)
	if GameState.hearts_changed.is_connected(_on_hearts_changed):
		GameState.hearts_changed.disconnect(_on_hearts_changed)


func _process(delta: float) -> void:
	if _backpack.message != "":
		_backpack.tick(delta)
		_update_message()


## Shows or hides the panel to match the Backpack, and redraws the rows.
func refresh() -> void:
	_root.visible = _backpack.is_open
	_backpack.sync(_inventory.items())
	for row in _rows.get_children():
		_rows.remove_child(row)
		row.queue_free()
	var items: Array = _inventory.items()
	for entry in items:
		var id := String(entry["id"])
		if BookLogic.is_note(id):
			continue  # notes live in the 수첩 only, never as a row
		_rows.add_child(_make_row(id, int(entry["count"])))
	var in_book: bool = _backpack.notebook_open
	_empty.visible = _rows.get_child_count() == 0 and not in_book
	_scroll.visible = _rows.get_child_count() > 0 and not in_book
	_update_book(items)
	_update_choice()
	_update_message()


## Backpack keys, Esc and the selection keys. The map is paused while it is open,
## so its own _unhandled_input is not reached: this is where the keys are read.
## One Esc does one thing: with the question up it cancels the question only.
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if _backpack.is_open:
		if _backpack.notebook_open:
			_book_input(event)
			return
		var action := BackpackLogic.action_for(event)
		if action != "":
			if _on_key_action(action):
				get_viewport().set_input_as_handled()
			return
		if event.echo:
			return
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			if _backpack.choosing:
				_backpack.escape()
				refresh()
			else:
				close_requested.emit()
		elif is_backpack_key(event):
			get_viewport().set_input_as_handled()
			close_requested.emit()
		return
	if event.echo:
		return
	if is_backpack_key(event) and open_handler.is_valid() and open_handler.call():
		get_viewport().set_input_as_handled()
		return
	var quick := notebook_action(event)
	if quick != "" and notebook_open_handler.is_valid() and notebook_open_handler.call(quick):
		get_viewport().set_input_as_handled()


## Keys while the notebook shows. The movement keys of both players are the
## notebook's: left / right flip (one page per press), up / down scroll (they
## repeat while held), place does nothing. Esc goes back to the list, or closes the
## panel over a quick-key notebook; so does the quick key that opened it. The
## backpack keys close the panel when the notebook came from the list and do
## nothing when it came from a quick key.
func _book_input(event: InputEvent) -> void:
	var action := BackpackLogic.action_for(event)
	if action != "":
		get_viewport().set_input_as_handled()
		if action == "up" or action == "down":
			scroll_notebook(1 if action == "down" else -1)
		elif (action == "left" or action == "right") and not event.echo:
			flip_notebook(1 if action == "right" else -1)
		return
	if event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_escape_book()
	elif notebook_action(event) != "":
		get_viewport().set_input_as_handled()
		if _backpack.notebook_quick and event.is_action_pressed(_backpack.notebook_key):
			close_requested.emit()
	elif is_backpack_key(event):
		get_viewport().set_input_as_handled()
		if not _backpack.notebook_quick:
			close_requested.emit()


## Esc (or Back / Close) over the notebook: back to the list, or out of the panel.
func _escape_book() -> void:
	if _backpack.notebook_open and not _backpack.notebook_quick:
		_backpack.escape()  # back to the list
		refresh()
	else:
		close_requested.emit()  # the map closes the panel (and resumes) through close_backpack()


func _on_close_pressed() -> void:
	if _backpack.notebook_open:
		_escape_book()
	else:
		close_requested.emit()


## Flips the notebook one page: -1 to an older note, +1 to a newer one. False at the end.
func flip_notebook(direction: int) -> bool:
	if not _backpack.notebook_open or not _backpack.book.flip(direction, _inventory.items()):
		return false
	refresh()
	return true


## Scrolls the shown page by `direction` steps (-1 up, +1 down) of notebook.json
## scroll_step pixels, within the page. False if it did not move.
func scroll_notebook(direction: int) -> bool:
	if not _backpack.notebook_open:
		return false
	var before := _book_scroll.scroll_vertical
	_book_scroll.scroll_vertical = clampi(before + direction * int(_book_config["scroll_step"]), 0, notebook_scroll_max())
	return _book_scroll.scroll_vertical != before


## A movement or place key of either player while the panel is open. True if it
## did something (an empty or elixir-free backpack leaves the key alone).
func _on_key_action(action: String) -> bool:
	var result: String = _backpack.key(action, _inventory.items())
	if result == "":
		return false
	if result == "ask":
		_ask()
	elif result == "drink":
		drink_chosen()
	elif result == "notebook":
		_backpack.show_notebook(_inventory.items())
	refresh()
	return true


## Opens the "who drinks" question for the selected row, with the traveler who has
## fewer hearts picked.
func _ask() -> void:
	_backpack.open_choice(int(GameState.heart_units["nestor"]), int(GameState.heart_units["fernanda"]))


## Drinks the selected elixir for the traveler the question has picked, and shows
## the result line.
func drink_chosen() -> Dictionary:
	var result: Dictionary = _backpack.drink(_inventory, BackpackLogic.CHOICES[_backpack.choice])
	if result["ok"]:
		var words: Dictionary = _config["messages"]
		_backpack.set_message(BackpackLogic.message_for(result, words), float(_config["message_seconds"]), int(result["healed"]) == 0)
	refresh()
	return result


func _on_hearts_changed(_traveler: String, _units: int) -> void:
	_update_choice()


func _on_row_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _backpack.select(id, _inventory.items()):
			if BackpackLogic.is_notebook(id):
				_backpack.show_notebook(_inventory.items())
			else:
				_ask()
			refresh()
		get_viewport().set_input_as_handled()


func _on_choice_pressed(index: int) -> void:
	_backpack.choice = index
	drink_chosen()


## The question: its prompt, one button per traveler with their hearts, and the
## highlighted button. Hidden unless the question is up.
func _update_choice() -> void:
	_choice.visible = _backpack.is_open and _backpack.choosing
	if not _backpack.choosing:
		return
	var item: Dictionary = Content.item(_backpack.selected)
	var item_name := String(item.get("name_ko", "")) if String(item.get("name_ko", "")) != "" else String(item.get("name_en", _backpack.selected))
	_choice_prompt.text = String(_config["choice_prompt"]).format({"item": item_name})
	for i in BackpackLogic.CHOICES.size():
		var who: String = BackpackLogic.CHOICES[i]
		var hearts := String(_config["hearts_text"]).format({
			"hearts": BackpackLogic.hearts_number(GameState.hearts_for_display(who)),
			"max": str(GameState.max_hearts())})
		_choice_buttons[i].text = String(_config["choice_button_text"]).format({"name": who.capitalize(), "hearts": hearts})
		_style_choice_button(_choice_buttons[i], i == _backpack.choice)


func _update_message() -> void:
	_message.visible = _backpack.message != ""
	_message.text = _backpack.message
	_message.add_theme_color_override("font_color", _color(_config["message_wasted_color" if _backpack.message_wasted else "message_color"]))


func _build_choice(column: VBoxContainer) -> void:
	_choice = PanelContainer.new()
	_choice.name = "Choice"
	_choice.visible = false
	_choice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := StyleBoxFlat.new()
	back.bg_color = _color(_config["choice_color"])
	back.set_corner_radius_all(8)
	back.set_content_margin_all(float(_config["choice_padding"]))
	_choice.add_theme_stylebox_override("panel", back)
	column.add_child(_choice)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_choice.add_child(box)
	_choice_prompt = _label("Prompt", int(_config["choice_prompt_font_size"]), _color(_config["text_color"]))
	_choice_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_choice_prompt)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(buttons)
	for i in BackpackLogic.CHOICES.size():
		var button := Button.new()
		button.name = "Choice_" + BackpackLogic.CHOICES[i]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = _vec(_config["choice_button_size"])
		button.add_theme_font_size_override("font_size", int(_config["button_font_size"]))
		button.pressed.connect(_on_choice_pressed.bind(i))
		buttons.add_child(button)
		_choice_buttons.append(button)


func _style_choice_button(button: Button, highlighted: bool) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = _color(_config["choice_selected_color" if highlighted else "choice_button_color"])
	style.set_corner_radius_all(8)
	if highlighted:
		style.set_border_width_all(int(_config["choice_selected_border_width"]))
		style.border_color = _color(_config["choice_selected_border_color"])
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)


## The input action ("notebook_p1" or "notebook_p2") of a press of a notebook quick
## key, "" for anything else.
static func notebook_action(event: InputEvent) -> String:
	for action in ["notebook_p1", "notebook_p2"]:
		if event.is_action_pressed(action):
			return action
	return ""


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


## Whether a row is drawn as the selected one (tests).
func row_selected(index: int) -> bool:
	return _rows.get_child(index).get_meta("item_id") == _backpack.selected and _backpack.selected != ""


func choice_visible() -> bool:
	return _choice.visible


func choice_prompt_text() -> String:
	return _choice_prompt.text


func choice_button(index: int) -> Button:
	return _choice_buttons[index]


func message_text() -> String:
	return _message.text if _message.visible else ""


func empty_visible() -> bool:
	return _empty.visible


func empty_text() -> String:
	return _empty.text


## Whether the notebook view is showing (tests).
func notebook_visible() -> bool:
	return _book.visible and _root.visible


## The text on the shown page ("" for the empty state).
func notebook_text() -> String:
	return _book_text.text if _book_scroll.visible else ""


## The empty-state line, "" while a page is shown.
func notebook_empty_text() -> String:
	return _book_empty.text if _book_empty.visible else ""


## Whether the flip indicator that way (-1 previous, +1 next) is drawn.
func notebook_arrow_visible(direction: int) -> bool:
	return (_book_next if direction > 0 else _book_previous).visible


func notebook_arrow_text(direction: int) -> String:
	return (_book_next if direction > 0 else _book_previous).text


## How far the shown page can scroll, in pixels (0 if its text fits).
func notebook_scroll_max() -> int:
	var bar := _book_scroll.get_v_scroll_bar()
	return maxi(int(ceil(bar.max_value - bar.page)), 0)


func notebook_scroll() -> int:
	return _book_scroll.scroll_vertical


func notebook_page_rect() -> Rect2:
	return _book_page.get_global_rect()


func notebook_text_label() -> Label:
	return _book_text


func notebook_scroll_container() -> ScrollContainer:
	return _book_scroll


func title_text() -> String:
	return _title.text


func close_text() -> String:
	return _close_button.text


## id of the item a row shows (tests).
func row_id(index: int) -> String:
	return String(_rows.get_child(index).get_meta("item_id"))


## The notebook view: a flip indicator, one cream page (the text scrolls inside it
## when it does not fit), a flip indicator. Hidden until the Backpack says the
## notebook is open. Look: data/series/notebook.json.
func _build_book(column: VBoxContainer) -> void:
	_book_config = Content.notebook
	var nb := _book_config
	_book = HBoxContainer.new()
	_book.name = "Notebook"
	_book.visible = false
	_book.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_book.add_theme_constant_override("separation", 4)
	_book.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_book)
	_book_previous = _book_arrow("Previous", str(nb["arrow_previous"]))
	_book_page = PanelContainer.new()
	_book_page.name = "Page"
	_book_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_book_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var paper := StyleBoxFlat.new()
	paper.bg_color = _color(nb["page_color"])
	paper.set_corner_radius_all(int(nb["page_corner_radius"]))
	paper.set_content_margin_all(float(nb["page_margin"]))
	_book_page.add_theme_stylebox_override("panel", paper)
	_book.add_child(_book_page)
	_book_scroll = ScrollContainer.new()
	_book_scroll.name = "PageScroll"
	_book_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_book_page.add_child(_book_scroll)
	_book_text = _label("PageText", int(nb["font_size"]), _color(nb["page_text_color"]))
	_book_text.add_theme_font_override("font", FONT)
	_book_text.add_theme_constant_override("line_spacing", int(nb["line_spacing"]))
	_book_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_book_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_book_scroll.add_child(_book_text)
	_book_empty = _label("PageEmpty", int(nb["empty_font_size"]), _color(nb["page_empty_text_color"]))
	_book_empty.add_theme_font_override("font", FONT)
	_book_empty.text = str(nb["empty_text"])
	_book_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_book_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_book_empty.visible = false
	_book_page.add_child(_book_empty)
	_book_next = _book_arrow("Next", str(nb["arrow_next"]))
	_book.move_child(_book_previous.get_parent(), 0)


## A flip indicator: a label in a fixed-width cell added to the notebook row, so the
## page does not shift when the indicator hides.
func _book_arrow(label_name: String, glyph: String) -> Label:
	var cell := Control.new()
	cell.name = label_name + "Cell"
	cell.custom_minimum_size = Vector2(float(_book_config["arrow_width"]), 0.0)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book.add_child(cell)
	var arrow := _label(label_name, int(_book_config["arrow_font_size"]), _color(_book_config["arrow_color"]))
	arrow.add_theme_font_override("font", FONT)
	arrow.text = glyph
	arrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(arrow)
	return arrow


## Shows or hides the notebook view to match the Backpack and fills in the shown page.
func _update_book(items: Array) -> void:
	var open: bool = _backpack.notebook_open
	_book.visible = open
	if not open:
		_title.text = str(_config["title"])
		_close_button.text = str(_config["close_text"])
		_book_shown = "<closed>"
		return
	_title.text = str(_book_config["title"])
	_close_button.text = str(_book_config["close_text" if _backpack.notebook_quick else "back_text"])
	var id: String = _backpack.book.current_id(items)
	var text: String = _backpack.book.page_text(items)
	if id != _book_shown:  # a new page starts at its top
		_book_shown = id
		_book_scroll.scroll_vertical = 0
	_book_text.text = text
	_book_scroll.visible = text != ""
	_book_empty.visible = text == ""
	_book_previous.visible = _backpack.book.has_previous(items)
	_book_next.visible = _backpack.book.has_next(items)


func _make_row(id: String, count: int) -> PanelContainer:
	var item: Dictionary = Content.item(id)
	var row := PanelContainer.new()
	row.name = "Row_" + id
	row.set_meta("item_id", id)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	var chosen: bool = id == _backpack.selected
	style.bg_color = _color(_config["selected_row_color" if chosen else "row_color"])
	style.set_corner_radius_all(8)
	style.set_content_margin_all(float(_config["row_padding"]))
	if chosen:
		style.set_border_width_all(int(_config["selected_border_width"]))
		style.border_color = _color(_config["selected_border_color"])
	row.add_theme_stylebox_override("panel", style)
	if BackpackLogic.is_selectable(id):
		row.mouse_filter = Control.MOUSE_FILTER_STOP  # only elixir rows take clicks
		row.gui_input.connect(_on_row_input.bind(id))
	var icon_id := String(item.get("icon", ""))
	var beside: Node = row
	if icon_id != "":
		if ItemIcon.is_known(icon_id):
			var line := HBoxContainer.new()  # the icon, then the usual row text
			line.add_theme_constant_override("separation", 12)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(line)
			var icon := ItemIcon.new()
			var icon_size := float(_config.get("icon_size", 56.0))
			icon.setup(icon_id, icon_size)
			icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line.add_child(icon)
			beside = line
		else:
			push_warning("Item '%s' has unknown icon '%s'" % [id, icon_id])
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	beside.add_child(column)
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
