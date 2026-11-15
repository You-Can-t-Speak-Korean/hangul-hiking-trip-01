extends Node3D
## A placeholder animal: a coloured box of its kind's size, standing on its origin, with
## its Korean name in a small label above it. It has no collision. The scene poses it
## each tick from the Crossing.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const NAME_FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var kind: Dictionary = {}
var box: MeshInstance3D
var label: Label3D


## `kind_data` is one entry of animals.kinds, `label_config` is animals.label.
func setup(kind_data: Dictionary, label_config: Dictionary) -> void:
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


## Stands at (x, z) on ground of height `ground_y`, `altitude` metres up, facing along
## `heading` (over x, z; forward is -z, like the travelers).
func pose(spot: Vector2, ground_y: float, altitude: float, heading: Vector2) -> void:
	global_position = Vector3(spot.x, ground_y + altitude, spot.y)
	rotation.y = atan2(-heading.x, -heading.y)
