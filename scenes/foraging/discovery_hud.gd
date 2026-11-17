extends CanvasLayer
## Draws a Discovery at the top left: for each entry its English name and one
## empty outlined block per syllable. Shows no Korean text and no letters until
## the player spells some: a block judged correct shows its syllable, and a
## finished word gets a check mark and a tint. Clicking an unfinished entry
## emits entry_pressed (the map opens the spelling view).

## The id of the entry clicked.
signal entry_pressed(id: String)

const WordSelect := preload("res://scripts/word_select.gd")
const SELECT_BORDER := Color(1.0, 0.88, 0.4)

## Keyboard word selection (E opens it). `open_gate` is asked before it opens and
## returns false while the map may not (a menu is up, restarting, dead, ...).
var word_select := WordSelect.new()
var open_gate: Callable

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

const NAME_FONT_SIZE := 24
const BLOCK_SIZE := 34.0
const MARGIN := 16.0

var _discovery
var _spelling
var _box: VBoxContainer
var _rows: Dictionary = {}  # entry id -> PanelContainer


func setup(discovery, spelling = null) -> void:
	layer = 5
	name = "DiscoveryHud"
	process_mode = Node.PROCESS_MODE_ALWAYS  # the list keeps working while the spelling view pauses the map
	_discovery = discovery
	_spelling = spelling
	_box = VBoxContainer.new()
	_box.position = Vector2(MARGIN, MARGIN)
	_box.add_theme_constant_override("separation", 8)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)


## The discovered words that are not finished, in list order.
func spellable_ids() -> Array[String]:
	var ids: Array[String] = []
	if _spelling == null:
		return ids
	for entry in _discovery.entries:
		if not _spelling.is_done(entry["id"]):
			ids.append(entry["id"])
	return ids


## E: opens word selection on the first spellable word. False (nothing happens)
## if the gate refuses, or no word can be spelled.
func open_word_select() -> bool:
	if word_select.is_open() or (open_gate.is_valid() and not open_gate.call()):
		return false
	if not word_select.open(spellable_ids()):
		return false
	refresh()
	return true


func close_word_select() -> void:
	if word_select.is_open():
		word_select.close()
		refresh()


## Applies one action from WordSelect.action_for. True if the key was used.
func word_action(action: String) -> bool:
	if word_select.is_open():
		match action:
			"up", "down", "left", "right":
				word_select.move(action)
			"confirm":
				var id := word_select.confirm()
				refresh()
				entry_pressed.emit(id)
			"cancel", "open":
				close_word_select()
			_:
				return false
		refresh()
		return true
	if action == "open":
		return open_word_select()
	return false


## While selection is open every selection key is taken here (before the map's
## unhandled input), so none also walks, picks or opens a menu.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close_word_select()  # the mouse took over; the click itself goes on
		return
	if not event is InputEventKey or not event.pressed:
		return
	var action := WordSelect.action_for(event)
	if action == "" or (event.echo and action in ["confirm", "cancel", "open"]):
		return
	if word_action(action):
		get_viewport().set_input_as_handled()


## Adds a row for each new entry and sets every row's fade. Call after each
## Discovery.update().
func refresh() -> void:
	for entry in _discovery.entries:
		if not _rows.has(entry["id"]):
			var row := _make_row(entry)
			_rows[entry["id"]] = row
			_box.add_child(row)
		_rows[entry["id"]].modulate.a = _discovery.opacity(entry)
		if _discovery.has_method("hint_alpha"):  # the animal scene's English hint fades for good
			_rows[entry["id"]].find_child("Name", true, false).modulate.a = _discovery.hint_alpha(entry)
		if _spelling != null:
			_show_progress(_rows[entry["id"]], entry["id"])
		_show_highlight(_rows[entry["id"]], word_select.highlighted() == entry["id"])


func _show_highlight(row: PanelContainer, on: bool) -> void:
	var back: StyleBoxFlat = row.get_theme_stylebox("panel")
	back.set_border_width_all(3 if on else 0)
	back.border_color = SELECT_BORDER


func _make_row(entry: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_STOP  # the panel swallows clicks; its children ignore them
	row.gui_input.connect(_on_row_input.bind(entry["id"]))
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.05, 0.07, 0.06, 0.7)
	back.set_corner_radius_all(6)
	back.set_content_margin_all(10.0)
	row.add_theme_stylebox_override("panel", back)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)
	var label := Label.new()
	label.name = "Name"
	label.text = entry["hover_name"]
	label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	column.add_child(label)
	var blocks := HBoxContainer.new()
	blocks.name = "Blocks"
	blocks.add_theme_constant_override("separation", 6)
	blocks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(blocks)
	for i in int(entry["syllables"]):
		blocks.add_child(_make_block())
	return row


## An empty square with a light outline.
func _make_block() -> Panel:
	var block := Panel.new()
	block.custom_minimum_size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.set_border_width_all(3)
	style.border_color = Color(0.92, 0.92, 0.88)
	block.add_theme_stylebox_override("panel", style)
	return block


func _on_row_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT 			and _spelling != null and not _spelling.is_done(id):
		entry_pressed.emit(id)


## Fills the blocks of the syllables judged correct and, once the word is done,
## adds the check mark and tints the row.
func _show_progress(row: PanelContainer, id: String) -> void:
	var blocks: HBoxContainer = row.find_child("Blocks", true, false)
	var solved: Array[String] = _spelling.solved(id)
	for i in solved.size():
		var block: Control = blocks.get_child(i)
		if block.get_child_count() == 0:
			var label := Label.new()
			label.text = solved[i]
			label.add_theme_font_override("font", FONT)
			label.add_theme_font_size_override("font_size", int(BLOCK_SIZE * 0.7))
			label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			block.add_child(label)
	if _spelling.is_done(id) and blocks.find_child("Done", false, false) == null:
		var c: Array = _spelling.config["done_color"]
		var done := Color(c[0], c[1], c[2])
		var mark := CheckMark.new()
		mark.name = "Done"
		mark.color = done
		mark.custom_minimum_size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blocks.add_child(mark)
		for block in blocks.get_children():
			if block is Panel:
				block.get_theme_stylebox("panel").border_color = done
		var back: StyleBoxFlat = row.get_theme_stylebox("panel")
		back.bg_color = back.bg_color.lerp(done.darkened(0.6), 0.5)


## A check mark drawn in code (no font needed).
class CheckMark extends Control:
	var color := Color.WHITE

	func _draw() -> void:
		var w := size.x
		var h := size.y
		draw_polyline(PackedVector2Array([Vector2(w * 0.18, h * 0.55), Vector2(w * 0.42, h * 0.78), Vector2(w * 0.84, h * 0.24)]), color, 4.0, true)
