extends CanvasLayer
## Draws a Picking's basket at the bottom right (the discovery list can run down
## the left side) as a woven forager's bag, 망태기: a rope handle, a dark rim and
## a straw body with weave lines. Its "망태기" label sits on the rim and the letter
## tiles in the mouth, in rows of at most max_columns that stack upward. Each
## new tile pops in over POP_TIME seconds; consonant and vowel tiles differ in colour.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const LABEL_FONT_SIZE := 24
const POP_TIME := 0.2
const CONSONANT_COLOR := Color(0.78, 0.46, 0.18)
const VOWEL_COLOR := Color(0.24, 0.5, 0.74)
const LABEL_COLOR := Color(0.95, 0.9, 0.78)  # on the dark rim
const HANDLE_HEIGHT := 28.0
const RIM_HEIGHT := 34.0     # the rim band, which holds the label
const SIDE_PADDING := 24.0
const BOTTOM_PADDING := 26.0
const CORNER := 14.0
const EMPTY_COLUMNS := 3     # an empty bag is this many tiles wide

var max_columns := 7
var tile_size := 52.0
var tile_gap := 6.0
var margin := 16.0
var body_color := Color.WHITE
var weave_color := Color.WHITE
var rim_color := Color.WHITE
var rope_color := Color.WHITE

var _picking
var _panel: Bag
var _tiles_box: GridContainer
var _ages: Array[float] = []


## The bag: a container that draws itself behind its content and stops clicks.
class Bag extends MarginContainer:
	var hud
	var mouth: Control  # the tiles' grid, so the bag can draw its opening

	func _draw() -> void:
		var body := Rect2(0.0, HANDLE_HEIGHT, size.x, size.y - HANDLE_HEIGHT)
		# Rope handle: a loop over the top.
		var loop := PackedVector2Array()
		var rx := size.x * 0.28
		var ry := HANDLE_HEIGHT - 3.0
		for i in 25:
			var a := PI * i / 24.0
			loop.append(Vector2(size.x / 2.0 - cos(a) * rx, HANDLE_HEIGHT + 2.0 - sin(a) * ry))
		draw_polyline(loop, hud.rope_color, 5.0, true)
		draw_polyline(loop, hud.rope_color.darkened(0.3), 1.5, true)
		# Body, then weave lines: horizontal strands with staggered upright ticks.
		var style := StyleBoxFlat.new()
		style.bg_color = hud.body_color
		style.set_corner_radius_all(int(CORNER))
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		draw_style_box(style, body)
		var y := body.position.y + RIM_HEIGHT + 8.0
		var row := 0
		while y < body.end.y - 8.0:
			draw_line(Vector2(10.0, y), Vector2(size.x - 10.0, y), hud.weave_color, 2.0)
			var x := 22.0 + (14.0 if row % 2 == 1 else 0.0)
			while x < size.x - 14.0:
				draw_line(Vector2(x, y), Vector2(x, minf(y + 11.0, body.end.y - 6.0)), hud.weave_color, 2.0)
				x += 28.0
			y += 11.0
			row += 1
		# The mouth: a darker opening the tiles sit in.
		if mouth != null:
			var inner := Rect2(mouth.global_position - global_position, mouth.size).grow(6.0)
			var hole := StyleBoxFlat.new()
			hole.bg_color = hud.weave_color.darkened(0.35)
			hole.set_corner_radius_all(10)
			draw_style_box(hole, inner)
		# Dark rim over the top of the body.
		var rim := StyleBoxFlat.new()
		rim.bg_color = hud.rim_color
		rim.corner_radius_top_left = 6
		rim.corner_radius_top_right = 6
		draw_style_box(rim, Rect2(body.position, Vector2(size.x, RIM_HEIGHT)))


## `config` is foraging.basket_hud.
func setup(picking, config: Dictionary) -> void:
	layer = 5
	name = "BasketHud"
	_picking = picking
	max_columns = int(config["max_columns"])
	tile_size = float(config["tile_size"])
	tile_gap = float(config["tile_gap"])
	margin = float(config["margin"])
	body_color = _color(config["bag_body_color"])
	weave_color = _color(config["bag_weave_color"])
	rim_color = _color(config["bag_rim_color"])
	rope_color = _color(config["rope_color"])
	_panel = Bag.new()
	_panel.hud = self
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP  # the bag swallows clicks
	# Anchored to the bottom right; grows upward and to the left.
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_right = -margin
	_panel.offset_bottom = -margin
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.add_theme_constant_override("margin_left", int(SIDE_PADDING))
	_panel.add_theme_constant_override("margin_right", int(SIDE_PADDING))
	_panel.add_theme_constant_override("margin_top", int(HANDLE_HEIGHT))
	_panel.add_theme_constant_override("margin_bottom", int(BOTTOM_PADDING))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	var title := Label.new()
	title.text = "망태기"
	title.custom_minimum_size.y = RIM_HEIGHT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FONT)
	title.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	title.add_theme_color_override("font_color", LABEL_COLOR)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	_tiles_box = GridContainer.new()
	_tiles_box.name = "Tiles"
	_tiles_box.columns = max_columns
	_tiles_box.custom_minimum_size = Vector2(tile_size * EMPTY_COLUMNS + tile_gap * (EMPTY_COLUMNS - 1), tile_size)  # an empty bag still has a mouth
	_tiles_box.add_theme_constant_override("h_separation", int(tile_gap))
	_tiles_box.add_theme_constant_override("v_separation", int(tile_gap))
	_tiles_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_tiles_box)
	_panel.mouth = _tiles_box
	for node in [_panel, _tiles_box]:
		node.resized.connect(_panel.queue_redraw)
	_tiles_box.item_rect_changed.connect(_panel.queue_redraw)
	add_child(_panel)


static func _color(channels: Array) -> Color:
	return Color(channels[0], channels[1], channels[2])


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
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE  # the bag behind it stops the click
	tile.custom_minimum_size = Vector2(tile_size, tile_size)
	tile.pivot_offset = Vector2(tile_size, tile_size) / 2.0
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
	label.add_theme_font_size_override("font_size", int(tile_size * 0.63))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(label)
	return tile
