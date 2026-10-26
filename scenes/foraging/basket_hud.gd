extends CanvasLayer
## Draws a Picking's basket at the bottom right (the discovery list can run down
## the left side): a "망태기" label and one tile per
## letter, in pick order. Each new tile pops in over POP_TIME seconds. Consonant
## and vowel tiles have different colours.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const MARGIN := 16.0
const TILE_SIZE := 60.0
const LABEL_FONT_SIZE := 24
const TILE_FONT_SIZE := 38
const POP_TIME := 0.2
const CONSONANT_COLOR := Color(0.78, 0.46, 0.18)
const VOWEL_COLOR := Color(0.24, 0.5, 0.74)

var _picking
var _panel: PanelContainer
var _tiles_box: HBoxContainer
var _ages: Array[float] = []


func setup(picking) -> void:
	layer = 5
	name = "BasketHud"
	_picking = picking
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Anchored to the bottom right; grows upward and to the left.
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_right = -MARGIN
	_panel.offset_bottom = -MARGIN
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.05, 0.07, 0.06, 0.7)
	back.set_corner_radius_all(6)
	back.set_content_margin_all(10.0)
	_panel.add_theme_stylebox_override("panel", back)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	var title := Label.new()
	title.text = "망태기"
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	column.add_child(title)
	_tiles_box = HBoxContainer.new()
	_tiles_box.name = "Tiles"
	_tiles_box.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)  # keeps the empty basket's height
	_tiles_box.add_theme_constant_override("separation", 6)
	_tiles_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_tiles_box)
	add_child(_panel)


## Adds a tile for each new letter in the basket and advances the pop-ins.
## Call after each tick.
func refresh(delta: float) -> void:
	while _tiles_box.get_child_count() < _picking.basket.size():
		_tiles_box.add_child(_make_tile(_picking.basket[_tiles_box.get_child_count()]))
		_ages.append(0.0)
	for i in _ages.size():
		_ages[i] += delta
		_tiles_box.get_child(i).scale = Vector2.ONE * pop_scale(_ages[i])


## 0..1: how far a tile of this age has popped in.
func pop_scale(age: float) -> float:
	return clampf(age / maxf(POP_TIME, 0.001), 0.0, 1.0)


func _make_tile(letter: String) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.custom_minimum_size = Vector2(TILE_SIZE, TILE_SIZE)
	tile.pivot_offset = Vector2(TILE_SIZE, TILE_SIZE) / 2.0
	tile.scale = Vector2.ZERO
	var style := StyleBoxFlat.new()
	style.bg_color = VOWEL_COLOR if Hangul.is_vowel(letter) else CONSONANT_COLOR
	style.set_corner_radius_all(8)
	style.set_border_width_all(3)
	style.border_color = Color(0.95, 0.94, 0.88)
	tile.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = letter
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", TILE_FONT_SIZE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(label)
	return tile
