extends Node3D
## A placeholder tool lying on the map: a bar of the tool's colour, bobbing gently, with the
## tool's Korean name above it. The 등산스틱 spot (`pole`) also has a brown poop mound and a
## green 막걸리 bottle beside the pole, with no letters (placeholders). No collision; the scene's
## Picking takes it as it takes a bottle (it is one of its piles).

const Traveler := preload("res://scenes/foraging/traveler.gd")
const NAME_FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")

var item_id := ""
var body: MeshInstance3D
var label: Label3D
## The poop mound and the bottle of the 등산스틱 spot (null elsewhere).
var mound: MeshInstance3D
var bottle: MeshInstance3D
var bottle_label: Label3D
var bob_amplitude := 0.06
var bob_speed := 0.6
var _rest := 0.0
var _phase := 0.0


## `item` is the items.json entry, `look` is animals.tool_pickups.look, `pole` marks the
## 등산스틱 spot, whose extras `spot_config` (animals.tool_pickups.pole_spot) describes.
func setup(item: Dictionary, look: Dictionary, phase: float, pole := false, spot_config: Dictionary = {}) -> void:
	item_id = String(item["id"])
	name = "ToolPickup_%s" % item_id
	_phase = phase
	bob_amplitude = float(look["bob_m"])
	bob_speed = float(look["bob_hz"])
	var mesh := BoxMesh.new()
	mesh.size = Vector3(float(look["length"]), float(look["thickness"]), float(look["thickness"]))
	var c: Array = look["color"]
	body = Traveler.gray_mesh(mesh, Color(c[0], c[1], c[2]))
	body.name = "Tool"
	_rest = float(look["lift"]) + mesh.size.y / 2.0
	body.position.y = _rest
	body.rotation.y = 0.5 * phase
	add_child(body)
	label = _label("Name", String(item["name_ko"]), look)
	label.position.y = float(look["lift"]) + float(look["label_lift"])
	add_child(label)
	if pole and not spot_config.is_empty():
		_build_extras(spot_config, look)


func _build_extras(spot_config: Dictionary, look: Dictionary) -> void:
	var sphere := SphereMesh.new()
	var radius := float(spot_config["mound_radius"])
	sphere.radius = radius
	sphere.height = radius * 1.2
	var m: Array = spot_config["mound_color"]
	mound = Traveler.gray_mesh(sphere, Color(m[0], m[1], m[2]))
	mound.name = "Mound"
	var at: Array = spot_config["mound_offset"]
	mound.position = Vector3(float(at[0]), radius * 0.6 * 0.5, float(at[1]))
	add_child(mound)
	var glass := CylinderMesh.new()
	glass.top_radius = 0.07
	glass.bottom_radius = 0.09
	glass.height = 0.38
	var g: Array = spot_config["bottle_color"]
	bottle = Traveler.gray_mesh(glass, Color(g[0], g[1], g[2]))
	bottle.name = "Bottle"
	var bat: Array = spot_config["bottle_offset"]
	bottle.position = Vector3(float(bat[0]), glass.height / 2.0, float(bat[1]))
	add_child(bottle)
	bottle_label = _label("BottleName", String(spot_config["bottle_label"]), look)
	bottle_label.position = bottle.position + Vector3(0.0, glass.height / 2.0 + float(look["label_lift"]) * 0.6, 0.0)
	add_child(bottle_label)


func _label(label_name: String, text: String, look: Dictionary) -> Label3D:
	var l := Label3D.new()
	l.name = label_name
	l.text = text
	l.font = NAME_FONT
	l.font_size = int(look["label_font_size"])
	l.pixel_size = float(look["label_pixel_size"])
	l.outline_size = int(look["label_outline_size"])
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.shaded = false
	l.no_depth_test = true
	return l


## The tool's height over its resting place at `time` seconds.
func bob(time: float) -> void:
	body.position.y = _rest + bob_amplitude * sin(TAU * bob_speed * time + _phase) * 0.5 + bob_amplitude * 0.5
