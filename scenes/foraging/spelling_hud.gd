extends CanvasLayer
## The spelling view: a centred panel at the top of the screen with the word's
## English name and one syllable block per syllable, left to right. The current
## block has a slot per letter (a consonant slot and a vowel slot); letters are
## dragged into them from the basket, which stays usable below. Judged-correct
## blocks show their syllable and are locked; blocks after the current one are
## dimmed. All rules live in Spelling; this only draws its state and passes the
## drops on. It keeps working while the tree is paused (process mode ALWAYS).
## The keyboard works here too: the active player's keys move a SpellingCursor
## over the basket's tiles and put the highlighted letter into the next empty
## slot, through the same drop() a mouse drag ends in.

## The view went away (closed, finished or failed). The map unpauses on this.
signal closed
## The basket or progress changed; the other HUDs redraw on this.
signal changed

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const BasketHud := preload("res://scenes/foraging/basket_hud.gd")
const SpellingCursor := preload("res://scenes/foraging/spelling_cursor.gd")
const TITLE_FONT_SIZE := 28
const BG := Color(0.05, 0.07, 0.06, 0.88)
const SLOT_BG := Color(0.0, 0.0, 0.0, 0.35)
const OUTLINE := Color(0.92, 0.92, 0.88)
const CURRENT_OUTLINE := Color(1.0, 0.88, 0.4)

var panel_size := Vector2(640.0, 330.0)
var panel_top := 24.0
var block_size := Vector2(160.0, 150.0)
var block_gap := 20.0
var slot_gap := 10.0
var flash_color := Color(0.85, 0.15, 0.15)
var flash_time := 0.6
var correct_color := Color(0.3, 0.6, 0.35)

## The keyboard cursor (its active_player has the setter); the basket HUD draws it.
var cursor

var _spelling
var _basket_hud: CanvasLayer
var _panel: PanelContainer
var _title: Label
var _blocks: HBoxContainer
var _view_id := ""
var _flash_left := 0.0
var _flash_block := -1
var _flash_letters: Array = []


## A slot of a block: takes drops and lets a placed letter be dragged out.
class Slot extends Panel:
	var hud
	var block := 0
	var index := 0

	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		return hud.can_drop(block, index, data)

	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		hud.drop(block, index, data)

	func _get_drag_data(_at_position: Vector2) -> Variant:
		var letter: String = hud.slot_letter(block, index)
		if letter == "" or hud.is_flashing():
			return null
		hud.mouse_used()
		set_drag_preview(hud.drag_preview(letter))
		return {"letter": letter, "from_slot": [block, index]}


## `spelling` is the Spelling (its config is foraging.spelling_view);
## `keyboard_config` is foraging.keyboard_select, the look of the highlight.
func setup(spelling, basket_hud: CanvasLayer, keyboard_config: Dictionary) -> void:
	layer = 6
	name = "SpellingHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_spelling = spelling
	_basket_hud = basket_hud
	cursor = SpellingCursor.new()
	basket_hud.set_cursor(cursor, keyboard_config)
	var config: Dictionary = spelling.config
	panel_size = _vec(config["panel_size"])
	panel_top = float(config["panel_top"])
	block_size = _vec(config["block_size"])
	block_gap = float(config["block_gap"])
	slot_gap = float(config["slot_gap"])
	flash_color = _color(config["failure_flash_color"])
	flash_time = float(config["failure_flash_time"])
	correct_color = _color(config["correct_color"])
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.offset_left = -panel_size.x / 2.0
	_panel.offset_right = panel_size.x / 2.0
	_panel.offset_top = panel_top
	_panel.offset_bottom = panel_top + panel_size.y
	var back := StyleBoxFlat.new()
	back.bg_color = BG
	back.set_corner_radius_all(10)
	back.set_content_margin_all(16.0)
	_panel.add_theme_stylebox_override("panel", back)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(header)
	_title = Label.new()
	_title.name = "Title"
	_title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(_title)
	var close_button := Button.new()
	close_button.name = "Close"
	close_button.text = "Close"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(close)
	header.add_child(close_button)
	var middle := CenterContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(middle)
	_blocks = HBoxContainer.new()
	_blocks.name = "Blocks"
	_blocks.add_theme_constant_override("separation", int(block_gap))
	_blocks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	middle.add_child(_blocks)
	add_child(_panel)


func _process(delta: float) -> void:
	tick(delta)


## Advances the failure flash; the view closes when it ends. Public so tests
## and the capture scene can drive it without waiting.
func tick(delta: float) -> void:
	if _flash_left > 0.0:
		_flash_left -= delta
		if _flash_left <= 0.0:
			_flash_block = -1
			_hide()


## Esc closes the view. While it is open every player key is taken here, so none
## reaches the map's _unhandled_input (the map is paused as well); only the
## active player's keys do anything.
func _input(event: InputEvent) -> void:
	if not is_open():
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
	elif SpellingCursor.is_player_key(event):
		get_viewport().set_input_as_handled()
		press(cursor.action_for(event))


## A key of the active player: "left", "right", "up", "down" or "place" ("" does
## nothing). The first press only shows the cursor on the first tile.
func press(action: String) -> void:
	if not is_open() or is_flashing():
		return
	var count: int = _basket_hud.letters().size()
	if cursor.press(action, count) == "place":
		_place_highlighted()


## Puts the highlighted basket letter into the next empty slot of the current
## block, the way a drop does. Nothing if the block has no empty slot.
func _place_highlighted() -> void:
	var slot: int = _spelling.placed.find("")
	if slot < 0:
		return
	var letter: String = _basket_hud.letters()[cursor.index]
	drop(_spelling.current_block(), slot, {"letter": letter})


## The mouse took over (a drag started): the keyboard highlight hides.
func mouse_used() -> void:
	cursor.hide_cursor()


func _clamp_cursor() -> void:
	cursor.clamp_to(_basket_hud.letters().size())


func is_open() -> bool:
	return _panel != null and _panel.visible


func is_flashing() -> bool:
	return _flash_left > 0.0


## Shows the view for a word the Spelling has just opened.
func show_word(id: String) -> void:
	_view_id = id
	_flash_left = 0.0
	_flash_block = -1
	_title.text = _spelling.hover_name(id)
	cursor.hide_cursor()  # back on the first key press
	_panel.visible = true
	_basket_hud.drag_enabled = true
	_basket_hud.take_back_handler = _take_back
	rebuild()


## The close button and Esc. Unjudged letters go back to the basket.
func close() -> void:
	if not is_open():
		return
	_spelling.close()
	_flash_left = 0.0
	_flash_block = -1
	_hide()


func _hide() -> void:
	_panel.visible = false
	_basket_hud.drag_enabled = false
	_view_id = ""
	_clamp_cursor()  # letters came back, or went for good
	changed.emit()
	closed.emit()


## The letter shown in a slot: the current block's, or the failed block's during the flash.
func slot_letter(block: int, slot: int) -> String:
	if is_flashing() and block == _flash_block:
		return String(_flash_letters[slot]) if slot < _flash_letters.size() else ""
	if _spelling.is_open() and block == _spelling.current_block() and slot < _spelling.placed.size():
		return _spelling.placed[slot]
	return ""


func can_drop(block: int, slot: int, data: Variant) -> bool:
	return data is Dictionary and data.has("letter") and not data.has("from_slot") \
			and _spelling.can_place(String(data["letter"]), block, slot)


## A letter dropped on a slot: judged if it fills the block.
func drop(block: int, slot: int, data: Variant) -> void:
	if can_drop(block, slot, data):
		apply(_spelling.place(String(data["letter"]), block, slot))


## Shows what Spelling.place returned.
func apply(result: Dictionary) -> void:
	if result["result"] != "rejected":
		_clamp_cursor()  # the placed letters left the basket
	match result["result"]:
		"rejected":
			return
		"failed":  # the letters are gone; flash the block, then the view closes
			_flash_block = int(result["block"])
			_flash_letters = result["letters"]
			_flash_left = flash_time
			rebuild()
			changed.emit()
		"complete":
			_hide()
		_:
			rebuild()
			changed.emit()


func _take_back(data: Dictionary) -> void:
	var from: Array = data["from_slot"]
	if _spelling.take_back(int(from[0]), int(from[1])):
		rebuild()
		changed.emit()


func drag_preview(letter: String) -> Control:
	return _basket_hud.drag_preview(letter)


## Redraws every block from the Spelling's state.
func rebuild() -> void:
	for block in _blocks.get_children():
		_blocks.remove_child(block)
		block.queue_free()
	var solved: Array[String] = _spelling.solved(_view_id)
	for i in _spelling.block_count(_view_id):
		_blocks.add_child(_make_block(i, solved))


func _make_block(index: int, solved: Array[String]) -> PanelContainer:
	var block := PanelContainer.new()
	block.name = "Block%d" % index
	block.custom_minimum_size = block_size
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var current: bool = _spelling.is_open() and index == _spelling.current_block()
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(4)
	style.set_content_margin_all(slot_gap)
	style.border_color = CURRENT_OUTLINE if current else OUTLINE
	style.bg_color = Color(0.1, 0.12, 0.11, 0.9)
	block.add_theme_stylebox_override("panel", style)
	if index < solved.size():  # judged correct: the syllable, locked
		style.bg_color = correct_color
		block.add_child(_syllable_label(solved[index]))
		return block
	if is_flashing() and index == _flash_block:
		style.bg_color = flash_color
	elif not current:
		block.modulate = Color(1, 1, 1, 0.45)  # locked until the blocks before it are right
	var slots := HBoxContainer.new()
	slots.add_theme_constant_override("separation", int(slot_gap))
	slots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_child(slots)
	var names: Array[String] = _spelling.slots_for(_spelling.target_syllable(_view_id, index))
	var slot_width := (block_size.x - slot_gap * (names.size() + 1)) / names.size()
	for s in names.size():
		slots.add_child(_make_slot(index, s, Vector2(slot_width, block_size.y - 2.0 * slot_gap)))
	return block


func _make_slot(block: int, index: int, size: Vector2) -> Slot:
	var slot := Slot.new()
	slot.name = "Slot%d_%d" % [block, index]
	slot.hud = self
	slot.block = block
	slot.index = index
	slot.custom_minimum_size = size
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var letter := slot_letter(block, index)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(3)
	style.border_color = OUTLINE
	style.bg_color = SLOT_BG
	if letter != "":
		style.bg_color = BasketHud.VOWEL_COLOR if Hangul.is_vowel(letter) else BasketHud.CONSONANT_COLOR
		var label := _syllable_label(letter)
		label.add_theme_font_size_override("font_size", int(size.x * 0.7))
		slot.add_child(label)
	slot.add_theme_stylebox_override("panel", style)
	return slot


func _syllable_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", int(block_size.y * 0.6))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


static func _vec(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


static func _color(channels: Array) -> Color:
	return Color(channels[0], channels[1], channels[2])
