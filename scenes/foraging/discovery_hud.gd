extends CanvasLayer
## Draws a Discovery at the top left: for each entry its English name and one
## empty outlined block per syllable. Shows no Korean text and no letters until
## the player spells some: a block judged correct shows its syllable, and a
## finished word gets a check mark and a tint. Clicking an unfinished entry
## emits entry_pressed (the map opens the spelling view).

## The id of the entry clicked.
signal entry_pressed(id: String)

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


## Adds a row for each new entry and sets every row's fade. Call after each
## Discovery.update().
func refresh() -> void:
	for entry in _discovery.entries:
		if not _rows.has(entry["id"]):
			var row := _make_row(entry)
			_rows[entry["id"]] = row
			_box.add_child(row)
		_rows[entry["id"]].modulate.a = _discovery.opacity(entry)
		if _spelling != null:
			_show_progress(_rows[entry["id"]], entry["id"])


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
