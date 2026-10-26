extends CanvasLayer
## The heart readout at the top right: a row per traveler with their name and
## their hearts. A whole heart is filled, a half heart is half filled, an empty
## one is an outline. It reads GameState.heart_units (half-units) and redraws on
## hearts_changed. The panel swallows clicks; this layer's root does not.

const NAME_FONT_SIZE := 20
const HEART_STEPS := 16  # points per half of the heart outline

var heart_size := 26.0
var heart_gap := 4.0
var margin := 16.0
var fill_color := Color(0.85, 0.12, 0.18)
var outline_color := Color(0.95, 0.9, 0.9)

var _panel: PanelContainer
var _hearts: Dictionary = {}  # traveler -> Array of Heart


## One heart: state 0 = empty, 1 = half, 2 = full.
class Heart extends Control:
	var state := 0:
		set(value):
			state = value
			queue_redraw()
	var fill := Color.RED
	var outline := Color.WHITE

	## The classic parametric heart fitted into `box` (the curve spans x -16..16, y -12..17, tip down).
	static func heart_polygon(box: Vector2) -> PackedVector2Array:
		var out := PackedVector2Array()
		var count := HEART_STEPS * 2
		var inset := 2.0
		for i in count:
			var t := TAU * i / count
			var x := 16.0 * pow(sin(t), 3.0)
			var y := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
			out.append(Vector2(
					inset + (x + 16.0) / 32.0 * (box.x - 2.0 * inset),
					inset + (y + 12.0) / 29.0 * (box.y - 2.0 * inset)))
		return out

	func _draw() -> void:
		var shape: PackedVector2Array = heart_polygon(size)
		if state == 2:
			draw_colored_polygon(shape, fill)
		elif state == 1:
			var left := PackedVector2Array([Vector2.ZERO, Vector2(size.x / 2.0, 0.0), Vector2(size.x / 2.0, size.y), Vector2(0.0, size.y)])
			for piece in Geometry2D.intersect_polygons(shape, left):
				draw_colored_polygon(piece, fill)
		var ring: PackedVector2Array = shape.duplicate()
		ring.append(shape[0])
		draw_polyline(ring, outline, 2.0, true)


## `config` is foraging.hearts_hud.
func setup(config: Dictionary) -> void:
	layer = 4
	name = "HeartsHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	heart_size = float(config["heart_size"])
	heart_gap = float(config["gap"])
	margin = float(config["margin"])
	fill_color = _color(config["fill_color"])
	outline_color = _color(config["outline_color"])
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.offset_right = -margin
	_panel.offset_top = margin
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.05, 0.07, 0.06, 0.7)
	back.set_corner_radius_all(6)
	back.set_content_margin_all(10.0)
	_panel.add_theme_stylebox_override("panel", back)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(column)
	for id in GameState.TRAVELERS:
		var row := HBoxContainer.new()
		row.name = id.capitalize()
		row.add_theme_constant_override("separation", 10)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var label := Label.new()
		label.text = id.capitalize()
		label.custom_minimum_size.x = 90.0
		label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(label)
		var box := HBoxContainer.new()
		box.name = "Hearts"
		box.add_theme_constant_override("separation", int(heart_gap))
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var hearts := []
		for i in GameState.max_hearts():
			var heart := Heart.new()
			heart.custom_minimum_size = Vector2(heart_size, heart_size)
			heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
			heart.fill = fill_color
			heart.outline = outline_color
			box.add_child(heart)
			hearts.append(heart)
		_hearts[id] = hearts
		row.add_child(box)
		column.add_child(row)
	add_child(_panel)
	GameState.hearts_changed.connect(_on_hearts_changed)
	refresh()


func _exit_tree() -> void:
	if GameState.hearts_changed.is_connected(_on_hearts_changed):
		GameState.hearts_changed.disconnect(_on_hearts_changed)


func _on_hearts_changed(_traveler: String, _units: int) -> void:
	refresh()


## Redraws every heart from GameState.
func refresh() -> void:
	for id in GameState.TRAVELERS:
		var states := states_for(int(GameState.heart_units.get(id, 0)))
		for i in states.size():
			_hearts[id][i].state = states[i]


## The state of each heart (0 empty, 1 half, 2 full) for a unit count.
func states_for(units: int) -> Array[int]:
	var upp := GameState.units_per_heart()
	var states: Array[int] = []
	for i in GameState.max_hearts():
		var left := units - i * upp
		states.append(2 if left >= upp else (1 if left > 0 else 0))
	return states


## The states currently drawn for a traveler.
func drawn_states(traveler: String) -> Array[int]:
	var states: Array[int] = []
	for heart in _hearts[traveler]:
		states.append(heart.state)
	return states


## The on-screen rectangle of the panel.
func panel_rect() -> Rect2:
	return _panel.get_global_rect()


static func _color(channels: Array) -> Color:
	return Color(channels[0], channels[1], channels[2])
