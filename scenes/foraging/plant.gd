extends Node3D
## One forageable plant (look only). Built from a plant kind in the mountain
## JSON. Targets carry the letters of their name as Label3Ds; decoys show the
## same letter_style (fruit, sprouts, fiddleheads, tiles) but blank, so only
## the letters tell them apart. The origin is on the ground.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const PICK_LAYER := 2          # physics layer for the hover Area3D
const DECOY_SLOTS := 3         # blank fruit / sprouts / tiles on a decoy
const SLOT_SPACING := 0.85
const ROW_SPACING := 0.95
const LETTER_PIXEL_SIZE := 0.0125
const LETTER_FONT_SIZE := 64

var kind_id := ""
var plant_name := ""
var hover_name := ""
var kind := ""
var zone := ""
var letter_style := ""
var letters: Array[String] = []

var _color := Color.WHITE
var _fruit_color := Color.WHITE


func setup(data: Dictionary, tiles: Array[String]) -> void:
	kind_id = data["id"]
	plant_name = data["name"]
	hover_name = data["hover_name"]
	kind = data["kind"]
	zone = data["zone"]
	letter_style = data["letter_style"]
	letters = tiles
	var c: Array = data["color"]
	_color = Color(c[0], c[1], c[2])
	_fruit_color = fruit_color(data)
	name = "%s_%s" % [kind_id, get_instance_id()]
	var slots := letters.size() if not letters.is_empty() else DECOY_SLOTS
	_build_mound()
	var extent := _build_style(slots)
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


## (column, row) slot centres, reading left to right then top to bottom.
func _slot_position(i: int, count: int) -> Vector2:
	var cols := count if count <= 3 else ceili(count / 2.0)
	var rows := ceili(float(count) / cols)
	var col := i % cols
	var row := i / cols
	var in_row := mini(cols, count - row * cols)
	return Vector2((col - (in_row - 1) / 2.0) * SLOT_SPACING, (rows - 1 - row) * ROW_SPACING)


func _build_style(count: int) -> Vector3:
	var cols := count if count <= 3 else ceili(count / 2.0)
	var top := 0.0
	for i in count:
		var slot := _slot_position(i, count)
		var letter := letters[i] if i < letters.size() else ""
		match letter_style:
			"hanging":
				top = maxf(top, _hanging(slot, letter))
			"sprouting":
				top = maxf(top, _sprouting(slot, letter))
			"unfurling":
				top = maxf(top, _unfurling(slot, letter))
			_:
				top = maxf(top, _on_top(slot, letter))
	if letter_style == "hanging":  # the branch the fruit hangs from
		var rod := CylinderMesh.new()
		rod.top_radius = 0.06
		rod.bottom_radius = 0.06
		rod.height = cols * SLOT_SPACING + 0.4
		_mesh(rod, Color(0.35, 0.26, 0.18), Vector3(0, top + 0.1, 0), Vector3(0, 0, 90))
	return Vector3(cols * SLOT_SPACING + 0.6, top + 0.8, 1.6)


func _label(text: String, pos: Vector3) -> void:
	if text.is_empty():
		return
	var label := Label3D.new()
	label.text = text
	label.font = FONT
	label.font_size = LETTER_FONT_SIZE
	label.pixel_size = LETTER_PIXEL_SIZE
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.outline_size = 14
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0.08, 0.06, 0.1)
	label.position = pos
	add_child(label)


## Fruit on strings under a branch; the letter is printed on the fruit.
func _hanging(slot: Vector2, letter: String) -> float:
	var branch_y := 2.0 + slot.y + 0.6
	var fruit_y := branch_y - 0.6
	var string := CylinderMesh.new()
	string.top_radius = 0.025
	string.bottom_radius = 0.025
	string.height = 0.5
	_mesh(string, Color(0.3, 0.4, 0.2), Vector3(slot.x, branch_y - 0.25, 0))
	var fruit := SphereMesh.new()
	fruit.radius = 0.4
	fruit.height = 0.8
	_mesh(fruit, _fruit_color, Vector3(slot.x, fruit_y, 0))
	_label(letter, Vector3(slot.x, fruit_y, 0.45))
	return branch_y


## A stem pushing up out of the ground with the letter on its tip.
func _sprouting(slot: Vector2, letter: String) -> float:
	var height := 1.1 + slot.y * 0.9 + 0.15 * (int(absf(slot.x) * 10.0) % 3)
	var stem := CylinderMesh.new()
	stem.top_radius = 0.05
	stem.bottom_radius = 0.09
	stem.height = height
	_mesh(stem, _color.darkened(0.15), Vector3(slot.x, height / 2.0, 0))
	var leaf := CylinderMesh.new()
	leaf.top_radius = 0.0
	leaf.bottom_radius = 0.22
	leaf.height = 0.4
	_mesh(leaf, _color.lightened(0.15), Vector3(slot.x - 0.2, height * 0.55, 0), Vector3(0, 0, 55))
	_mesh(leaf, _color.lightened(0.15), Vector3(slot.x + 0.2, height * 0.4, 0), Vector3(0, 0, -55))
	var bud := SphereMesh.new()
	bud.radius = 0.15
	bud.height = 0.3
	_mesh(bud, _color.lightened(0.25), Vector3(slot.x, height + 0.05, 0))
	_label(letter, Vector3(slot.x, height + 0.55, 0.1))
	return height + 0.9


## A fern stem ending in a curled fiddlehead ring that frames the letter.
func _unfurling(slot: Vector2, letter: String) -> float:
	var height := 0.9 + slot.y * 0.9
	var stem := CylinderMesh.new()
	stem.top_radius = 0.05
	stem.bottom_radius = 0.08
	stem.height = height
	_mesh(stem, _color.darkened(0.1), Vector3(slot.x, height / 2.0, 0))
	var ring := TorusMesh.new()
	ring.inner_radius = 0.34
	ring.outer_radius = 0.48
	_mesh(ring, _color.lightened(0.2), Vector3(slot.x, height + 0.5, 0), Vector3(90, 0, 0))
	var curl := SphereMesh.new()  # the tight end of the curl
	curl.radius = 0.12
	curl.height = 0.24
	_mesh(curl, _color.lightened(0.3), Vector3(slot.x + 0.4, height + 0.2, 0))
	_label(letter, Vector3(slot.x, height + 0.5, 0.1))
	return height + 1.0


## Letters on cards leaning on the plant's leafy cushion.
func _on_top(slot: Vector2, letter: String) -> float:
	var cushion := SphereMesh.new()
	cushion.radius = 0.6
	cushion.height = 0.6
	_mesh(cushion, _color.lightened(0.1), Vector3(slot.x, 0.45 + slot.y * 0.5, -0.1))
	var y := 1.35 + slot.y * 0.5
	var card := BoxMesh.new()
	card.size = Vector3(0.75, 0.75, 0.08)
	_mesh(card, Color(0.27, 0.23, 0.2), Vector3(slot.x, y, 0.0), Vector3(-28, 0, 0))
	_label(letter, Vector3(slot.x, y, 0.1))
	return y + 0.5


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
