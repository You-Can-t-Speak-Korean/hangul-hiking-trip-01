extends Node3D
## A placeholder healing bottle lying on the map: a small upright cylinder that bobs gently,
## with the item's Korean name in a label above it. No collision; the scene's Picking takes it.

const Traveler := preload("res://scenes/foraging/traveler.gd")
const NAME_FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var item_id := ""
var body: MeshInstance3D
var label: Label3D
var bob_amplitude := 0.06
var bob_speed := 2.0
var _rest := 0.0
var _phase := 0.0


## `item` is the items.json entry, `look` is animals.heal_pickups.look.
func setup(item: Dictionary, look: Dictionary, phase: float) -> void:
	item_id = String(item["id"])
	name = "Pickup_%s" % item_id
	_phase = phase
	bob_amplitude = float(look["bob_m"])
	bob_speed = float(look["bob_hz"])
	var mesh := CylinderMesh.new()
	mesh.top_radius = float(look["radius"])
	mesh.bottom_radius = float(look["radius"])
	mesh.height = float(look["height"])
	var c: Array = look["color"]
	body = Traveler.gray_mesh(mesh, Color(c[0], c[1], c[2]))
	body.name = "Bottle"
	_rest = float(look["lift"]) + mesh.height / 2.0
	body.position.y = _rest
	add_child(body)
	label = Label3D.new()
	label.name = "Name"
	label.text = String(item["name_ko"])
	label.font = NAME_FONT
	label.font_size = int(look["label_font_size"])
	label.pixel_size = float(look["label_pixel_size"])
	label.outline_size = int(look["label_outline_size"])
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.no_depth_test = true
	label.position.y = float(look["lift"]) + mesh.height + float(look["label_lift"])
	add_child(label)


## The bottle's height over its resting place at `time` seconds.
func bob(time: float) -> void:
	body.position.y = _rest + bob_amplitude * sin(TAU * bob_speed * time + _phase) * 0.5 + bob_amplitude * 0.5
