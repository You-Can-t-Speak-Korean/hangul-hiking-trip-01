extends Node3D
## What a revive looks like, shared by the foraging and animal scenes (data: rules.json
## `revive`): the range ring on a downed traveler the standing one could revive, the small
## progress ring that fills while the channel runs, and the one-line note when there is no
## healing item. The logic is Revive's; this node only draws it. Call refresh() every tick.

const ReachRing := preload("res://scenes/foraging/reach_ring.gd")
const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var range_ring: MeshInstance3D
var progress_ring: MeshInstance3D
var note_label: Label

var _config: Dictionary = {}
var _range_for := ""


func setup(config: Dictionary) -> void:
	_config = config
	name = "ReviveView"
	range_ring = _make_ring("RangeRing", config["range_ring"])
	progress_ring = _make_ring("ProgressRing", config["progress_ring"])
	var layer := CanvasLayer.new()
	layer.layer = 9
	add_child(layer)
	note_label = Label.new()
	note_label.name = "Note"
	note_label.add_theme_font_override("font", FONT)
	note_label.add_theme_font_size_override("font_size", int(config["note_font_size"]))
	var c: Array = config["note_color"]
	note_label.add_theme_color_override("font_color", Color(c[0], c[1], c[2]))
	note_label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.08))
	note_label.add_theme_constant_override("outline_size", 8)
	note_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	note_label.offset_top = -160.0
	note_label.offset_left = -400.0
	note_label.offset_right = 400.0
	note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note_label.visible = false
	layer.add_child(note_label)


func _make_ring(ring_name: String, look: Dictionary) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = ring_name
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var c: Array = look["color"]
	material.albedo_color = Color(c[0], c[1], c[2], float(look["alpha"]))
	ring.material_override = material
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = false
	add_child(ring)
	return ring


## `world` maps traveler id -> world position; `height_at` is the ground height along x.
func refresh(revive, rescuer_id: String, world: Dictionary, height_at: Callable) -> void:
	var flat := {}
	for id in world:
		flat[id] = Vector2(world[id].x, world[id].z)
	var near: String = revive.target if revive.is_channeling() else revive.downed_near(rescuer_id, flat)
	range_ring.visible = near != ""
	if near != "":
		var at: Vector3 = world[near]
		range_ring.global_position = at
		if _range_for != near:
			_range_for = near
			var outer: float = revive.radius_m
			range_ring.mesh = ReachRing.mesh(outer, maxf(outer - float(_config["range_ring"]["width_m"]), 0.0), at, height_at)
	else:
		_range_for = ""
	progress_ring.visible = revive.is_channeling()
	if progress_ring.visible:
		var at: Vector3 = world[revive.target]
		progress_ring.global_position = at
		var outer := float(_config["progress_ring"]["outer_m"])
		progress_ring.mesh = ReachRing.mesh(outer, maxf(outer - float(_config["progress_ring"]["width_m"]), 0.0), at, height_at, revive.progress())
	note_label.text = revive.note
	note_label.visible = revive.note != ""


## Puts a traveler's body in or out of the downed pose to match `down` (data: rules.json revive).
static func pose(traveler: Node3D, down: bool, config: Dictionary) -> void:
	if down and not traveler.downed:
		var c: Array = config["down_tint"]
		traveler.lie_down(Color(c[0], c[1], c[2]), String(config["down_label"]), float(config["label_height"]), FONT, float(config["lie_seconds"]))
	elif not down and traveler.downed:
		traveler.stand_up()
