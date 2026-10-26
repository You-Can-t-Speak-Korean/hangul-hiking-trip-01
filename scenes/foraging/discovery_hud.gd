extends CanvasLayer
## Draws a Discovery at the top left: for each entry its English name and one
## empty outlined block per syllable. Shows no Korean text and no letters.

const NAME_FONT_SIZE := 24
const BLOCK_SIZE := 34.0
const MARGIN := 16.0

var _discovery
var _box: VBoxContainer
var _rows: Dictionary = {}  # entry id -> PanelContainer


func setup(discovery) -> void:
	layer = 5
	name = "DiscoveryHud"
	_discovery = discovery
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


func _make_row(entry: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
