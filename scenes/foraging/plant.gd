extends Node3D
## One forageable plant (look only). Built from a plant kind in the mountain
## JSON. A target carries exactly one letter of its name as a Label3D; a decoy
## shows the same letter_style (fruit, sprout, fiddlehead, cushion) but blank,
## so only the letter tells them apart. The origin is on the ground.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const PICK_LAYER := 2          # physics layer for the hover Area3D
const EXTENT_WIDTH := 1.5      # hover box width and depth, in metres
const LETTER_PIXEL_SIZE := 0.017
const LETTER_FONT_SIZE := 64

var kind_id := ""
var plant_name := ""
var hover_name := ""
var kind := ""
var zone := ""
var letter_style := ""
var letter := ""  # the one letter this plant carries; empty on a decoy

var _color := Color.WHITE
var _fruit_color := Color.WHITE


func setup(data: Dictionary, plant_letter: String) -> void:
	kind_id = data["id"]
	plant_name = data["name"]
	hover_name = data["hover_name"]
	kind = data["kind"]
	zone = data["zone"]
	letter_style = data["letter_style"]
	letter = plant_letter
	var c: Array = data["color"]
	_color = Color(c[0], c[1], c[2])
	_fruit_color = fruit_color(data)
	name = "%s_%s" % [kind_id, get_instance_id()]
	_build_mound()
	var extent := _build_style()
	_build_pick_area(extent)


## The colour of a hanging plant's fruit: "fruit_color" in the data, else the
## body colour tinted purple.
static func fruit_color(data: Dictionary) -> Color:
	if data.has("fruit_color"):
		var f: Array = data["fruit_color"]
		return Color(f[0], f[1], f[2])
	var c: Array = data["color"]
	return Color(c[0], c[1], c[2]).lerp(Color(0.45, 0.1, 0.5), 0.6)


## What the hover tooltip says: the real name for a target, "???" for a decoy.
func tooltip_text() -> String:
	return hover_name if kind == "target" else "???"


func _mesh(mesh: Mesh, color: Color, pos: Vector3, rot_deg := Vector3.ZERO) -> MeshInstance3D:
	var instance := _gray(mesh, color)
	instance.position = pos
	instance.rotation_degrees = rot_deg
	add_child(instance)
	return instance


static func _gray(mesh: Mesh, color: Color) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	return instance


## A low leafy mound of cones: the plant body, tinted by kind.
func _build_mound() -> void:
	for i in 5:
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.38
		cone.height = 0.75 + 0.1 * (i % 3)
		var angle := TAU * i / 5.0
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * (0.45 if i > 0 else 0.0)
		_mesh(cone, _color.lightened(0.06 * (i % 2)), offset + Vector3(0, cone.height / 2.0, 0))


func _build_style() -> Vector3:
	var top := 0.0
	match letter_style:
		"hanging":
			top = _hanging()
		"sprouting":
			top = _sprouting()
		"unfurling":
			top = _unfurling()
		_:
			top = _on_top()
	return Vector3(EXTENT_WIDTH, top + 0.8, EXTENT_WIDTH)


func _label(pos: Vector3) -> void:
	if letter.is_empty():
		return
	var label := Label3D.new()
	label.text = letter
	label.font = FONT
	label.font_size = LETTER_FONT_SIZE
	label.pixel_size = LETTER_PIXEL_SIZE
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.outline_size = 16
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0.08, 0.06, 0.1)
	label.position = pos
	add_child(label)


## One fruit on a string under a branch; the letter is printed on the fruit.
func _hanging() -> float:
	var branch_y := 3.0
	var fruit_y := 2.2
	var trunk := CylinderMesh.new()  # the vine the branch grows from
	trunk.top_radius = 0.06
	trunk.bottom_radius = 0.09
	trunk.height = branch_y
	_mesh(trunk, Color(0.35, 0.26, 0.18), Vector3(0, branch_y / 2.0, -0.1))
	var rod := CylinderMesh.new()
	rod.top_radius = 0.06
	rod.bottom_radius = 0.06
	rod.height = 1.2
	_mesh(rod, Color(0.35, 0.26, 0.18), Vector3(0, branch_y, -0.1), Vector3(0, 0, 90))
	var string := CylinderMesh.new()
	string.top_radius = 0.025
	string.bottom_radius = 0.025
	string.height = 0.45
	_mesh(string, Color(0.3, 0.4, 0.2), Vector3(0, branch_y - 0.225, 0))
	var fruit := SphereMesh.new()
	fruit.radius = 0.55
	fruit.height = 1.1
	_mesh(fruit, _fruit_color, Vector3(0, fruit_y, 0))
	_label(Vector3(0, fruit_y, 0.6))
	return branch_y


## A stem pushing up out of the ground with the letter above its tip.
func _sprouting() -> float:
	var height := 1.1
	var stem := CylinderMesh.new()
	stem.top_radius = 0.05
	stem.bottom_radius = 0.09
	stem.height = height
	_mesh(stem, _color.darkened(0.15), Vector3(0, height / 2.0, 0))
	var leaf := CylinderMesh.new()
	leaf.top_radius = 0.0
	leaf.bottom_radius = 0.22
	leaf.height = 0.4
	_mesh(leaf, _color.lightened(0.15), Vector3(-0.2, height * 0.55, 0), Vector3(0, 0, 55))
	_mesh(leaf, _color.lightened(0.15), Vector3(0.2, height * 0.4, 0), Vector3(0, 0, -55))
	var bud := SphereMesh.new()
	bud.radius = 0.15
	bud.height = 0.3
	_mesh(bud, _color.lightened(0.25), Vector3(0, height + 0.05, 0))
	_label(Vector3(0, height + 0.85, 0.1))
	return height + 1.4


## A fern stem ending in a curled fiddlehead ring that frames the letter.
func _unfurling() -> float:
	var height := 0.9
	var stem := CylinderMesh.new()
	stem.top_radius = 0.05
	stem.bottom_radius = 0.08
	stem.height = height
	_mesh(stem, _color.darkened(0.1), Vector3(0, height / 2.0, 0))
	var ring := TorusMesh.new()
	ring.inner_radius = 0.62
	ring.outer_radius = 0.78
	_mesh(ring, _color.lightened(0.2), Vector3(0, height + 0.7, -0.05), Vector3(90, 0, 0))
	var curl := SphereMesh.new()  # the tight end of the curl
	curl.radius = 0.14
	curl.height = 0.28
	_mesh(curl, _color.lightened(0.3), Vector3(0.7, height + 0.3, -0.05))
	_label(Vector3(0, height + 0.7, 0.1))
	return height + 1.5


## The letter floats over a leafy cushion, with no card behind it.
func _on_top() -> float:
	var cushion := SphereMesh.new()
	cushion.radius = 0.6
	cushion.height = 0.6
	_mesh(cushion, _color.lightened(0.1), Vector3(0, 0.45, -0.1))
	_label(Vector3(0, 1.75, 0.2))
	return 2.3


func _build_pick_area(extent: Vector3) -> void:
	var area := Area3D.new()
	area.name = "PickArea"
	area.collision_layer = 1 << (PICK_LAYER - 1)
	area.collision_mask = 0
	var shape := BoxShape3D.new()
	shape.size = extent
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = extent.y / 2.0
	area.add_child(collision)
	add_child(area)
