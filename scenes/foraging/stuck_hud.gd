extends CanvasLayer
## The stuck countdown's look: a small faint seconds number at the top centre and
## a dark vignette on the screen edges that grows as the time runs out. Drawn in
## code (a generated radial gradient), no art files. It sits under the other HUDs
## (their layers are higher) and neither of its controls takes the mouse.

const FONT_SIZE := 34

var number_alpha := 0.35
var vignette_strength := 0.85
var vignette_growth := 1.6

var _number: Label
var _vignette: TextureRect


## `config` is foraging.stuck.
func setup(config: Dictionary) -> void:
	layer = 3
	name = "StuckHud"
	process_mode = Node.PROCESS_MODE_ALWAYS
	number_alpha = float(config["number_alpha"])
	vignette_strength = float(config["vignette_strength"])
	vignette_growth = float(config["vignette_growth"])
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	fade.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0, 0, 0, 1)])
	var texture := GradientTexture2D.new()
	texture.gradient = fade
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)  # radius to the middle of each edge; the corners clamp to black
	texture.width = 256
	texture.height = 256
	_vignette = TextureRect.new()
	_vignette.name = "Vignette"
	_vignette.texture = texture
	_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.visible = false
	add_child(_vignette)
	_number = Label.new()
	_number.name = "Number"
	_number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_number.add_theme_font_size_override("font_size", FONT_SIZE)
	_number.add_theme_constant_override("outline_size", 6)
	_number.add_theme_color_override("font_outline_color", Color(0, 0, 0, number_alpha))
	_number.add_theme_color_override("font_color", Color(1, 1, 1, number_alpha))
	_number.anchor_left = 0.5
	_number.anchor_right = 0.5
	_number.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_number.offset_top = float(config["number_margin"])
	_number.visible = false
	add_child(_number)


## `clock` is the Countdown. Shows the number and vignette while it runs. The
## spelling view covers the top centre, so `view_open` hides the number then (the
## clock stands still while the view is open anyway).
func refresh(clock, view_open: bool = false) -> void:
	var on: bool = clock.running
	_number.visible = on and not view_open
	_vignette.visible = on
	if not on:
		return
	_number.text = str(clock.shown_seconds())
	_vignette.modulate.a = clock.vignette_alpha(clock.fraction(), vignette_strength, vignette_growth)


func number_rect() -> Rect2:
	return _number.get_global_rect()


func vignette_rect() -> Rect2:
	return _vignette.get_global_rect()
