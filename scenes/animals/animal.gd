extends Node3D
## A placeholder animal: a coloured box of its kind's size, standing on its origin, with
## its Korean name in a small label above it, the jamo it carries on a letter tile floating
## above its back, and a ring on the ground that fills while a traveler watches it. It has
## no collision. The scene poses it each tick from the Crossing.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const BasketHud := preload("res://scenes/foraging/basket_hud.gd")
const ReachRing := preload("res://scenes/foraging/reach_ring.gd")
const NAME_FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var kind: Dictionary = {}
var box: MeshInstance3D
var label: Label3D
## The letter tile: a coloured billboard square with the jamo on it (hidden when the animal
## carries none).
var tile: Node3D
var tile_back: MeshInstance3D
var tile_label: Label3D
## The watch-progress ring (hidden at 0).
var watch_ring: MeshInstance3D
var letter := ""

var _watch_material: StandardMaterial3D
var _watch_outer := 1.0
var _watch_width := 0.1
var _watch_steps := -1


## `kind_data` is one entry of animals.kinds, `label_config` is animals.label, `tile_config`
## is animals.letters.tile and `ring_config` is animals.watch.ring (both optional).
func setup(kind_data: Dictionary, label_config: Dictionary, tile_config: Dictionary = {}, ring_config: Dictionary = {}) -> void:
	kind = kind_data
	name = String(kind_data["id"])
	var size: Array = kind_data["size"]
	var mesh := BoxMesh.new()
	mesh.size = Vector3(float(size[0]), float(size[1]), float(size[2]))
	var c: Array = kind_data["color"]
	box = Traveler.gray_mesh(mesh, Color(c[0], c[1], c[2]))
	box.name = "Box"
	box.position.y = mesh.size.y / 2.0
	add_child(box)
	label = Label3D.new()
	label.name = "Name"
	label.text = String(kind_data["name_ko"])
	label.font = NAME_FONT
	label.font_size = int(label_config["font_size"])
	label.pixel_size = float(label_config["pixel_size"])
	label.outline_size = int(label_config["outline_size"])
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.no_depth_test = true
	var t: Array = label_config["color"]
	label.modulate = Color(t[0], t[1], t[2])
	label.position.y = mesh.size.y + float(label_config["lift"])
	add_child(label)
	if not tile_config.is_empty():
		_build_tile(tile_config, mesh.size.y)
	if not ring_config.is_empty():
		_build_ring(ring_config, mesh.size)


func _build_tile(config: Dictionary, back_height: float) -> void:
	var edge := float(config["size"])
	tile = Node3D.new()
	tile.name = "Letter"
	tile.position.y = back_height + float(config["lift"])
	tile.visible = false
	var quad := QuadMesh.new()
	quad.size = Vector2(edge, edge)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.no_depth_test = true
	material.render_priority = 1
	tile_back = MeshInstance3D.new()
	tile_back.name = "Back"
	tile_back.mesh = quad
	tile_back.material_override = material
	tile_back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tile.add_child(tile_back)
	tile_label = Label3D.new()
	tile_label.name = "Jamo"
	tile_label.font = NAME_FONT
	tile_label.font_size = int(config["font_size"])
	tile_label.pixel_size = float(config["pixel_size"])
	tile_label.outline_size = int(config["outline_size"])
	tile_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tile_label.shaded = false
	tile_label.no_depth_test = true
	tile_label.render_priority = 2
	tile_label.outline_render_priority = 1
	tile_label.modulate = Color(0.98, 0.97, 0.92)
	tile.add_child(tile_label)
	add_child(tile)


## Puts a jamo on the tile ("" takes it away).
func set_letter(jamo: String) -> void:
	letter = jamo
	if tile == null:
		return
	tile.visible = jamo != ""
	tile_label.text = jamo
	if jamo != "":
		(tile_back.material_override as StandardMaterial3D).albedo_color = BasketHud.VOWEL_COLOR if Hangul.is_vowel(jamo) else BasketHud.CONSONANT_COLOR


func _build_ring(config: Dictionary, box_size: Vector3) -> void:
	_watch_outer = maxf(box_size.x, box_size.z) / 2.0 + float(config["pad_m"])
	_watch_width = float(config["width_m"])
	_watch_material = StandardMaterial3D.new()
	_watch_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_watch_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_watch_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var rc: Array = config["color"]
	_watch_material.albedo_color = Color(rc[0], rc[1], rc[2], float(config["alpha"]))
	watch_ring = MeshInstance3D.new()
	watch_ring.name = "WatchRing"
	watch_ring.material_override = _watch_material
	watch_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	watch_ring.visible = false
	add_child(watch_ring)


## Shows how far the watch has got (0..1; 0 hides the ring): that share of the ring is drawn.
func set_watch(progress: float) -> void:
	if watch_ring == null:
		return
	var steps := ceili(clampf(progress, 0.0, 1.0) * ReachRing.SEGMENTS)
	watch_ring.visible = steps > 0
	if steps != _watch_steps:
		_watch_steps = steps
		watch_ring.mesh = ReachRing.mesh(_watch_outer, maxf(_watch_outer - _watch_width, 0.0), Vector3.ZERO, func(_x: float) -> float: return 0.0, float(steps) / ReachRing.SEGMENTS)


## Stands at (x, z) on ground of height `ground_y`, `altitude` metres up, facing along
## `heading` (over x, z; forward is -z, like the travelers).
func pose(spot: Vector2, ground_y: float, altitude: float, heading: Vector2) -> void:
	global_position = Vector3(spot.x, ground_y + altitude, spot.y)
	rotation.y = atan2(-heading.x, -heading.y)
