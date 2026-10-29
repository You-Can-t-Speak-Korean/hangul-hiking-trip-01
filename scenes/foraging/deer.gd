extends Node3D
## A white deer built from primitives: body, legs, neck, head, ears, tail and
## antlers. Original placeholder shapes, no art files. It faces -z (like the
## travelers' noses); the map turns it. `config` is foraging.monster.

const Traveler := preload("res://scenes/foraging/traveler.gd")


func setup(config: Dictionary) -> void:
	name = "Deer"
	var body_color := _color(config["body_color"])
	var antler_color := _color(config["antler_color"])
	var eye_color := _color(config["eye_color"])
	_part(BoxMesh.new(), Vector3(0.5, 0.55, 1.3), Vector3(0.0, 1.0, 0.0), body_color)
	for x in [-0.17, 0.17]:
		for z in [-0.5, 0.5]:
			var leg := CylinderMesh.new()
			leg.top_radius = 0.06
			leg.bottom_radius = 0.04
			leg.height = 0.8
			var mesh := Traveler.gray_mesh(leg, body_color.darkened(0.08))
			mesh.position = Vector3(x, 0.4, z)
			add_child(mesh)
	var neck := _part(BoxMesh.new(), Vector3(0.22, 0.7, 0.24), Vector3(0.0, 1.45, -0.62), body_color)
	neck.rotation.x = deg_to_rad(-25.0)  # leans forward
	var head := _part(BoxMesh.new(), Vector3(0.24, 0.24, 0.42), Vector3(0.0, 1.85, -0.85), body_color)
	head.rotation.x = deg_to_rad(12.0)
	_part(BoxMesh.new(), Vector3(0.14, 0.14, 0.2), Vector3(0.0, 1.8, -1.12), body_color.darkened(0.1))
	for x in [-0.09, 0.09]:
		_part(SphereMesh.new(), Vector3(0.06, 0.06, 0.06), Vector3(x * 1.35, 1.9, -1.0), eye_color)
		var ear := _part(BoxMesh.new(), Vector3(0.05, 0.2, 0.1), Vector3(x * 1.7, 2.0, -0.72), body_color)
		ear.rotation.z = deg_to_rad(-30.0 if x > 0.0 else 30.0)
		_antler(x, antler_color)
	_part(BoxMesh.new(), Vector3(0.1, 0.12, 0.18), Vector3(0.0, 1.2, 0.72), body_color)  # tail
	scale = Vector3.ONE * float(config["scale"])


## One antler: a beam leaning out and back, with three tines. `side` is -1 or 1 (x).
func _antler(side: float, color: Color) -> void:
	var dir := 1.0 if side > 0.0 else -1.0
	var root := Node3D.new()
	root.position = Vector3(dir * 0.1, 2.0, -0.8)
	add_child(root)
	root.rotation = Vector3(deg_to_rad(20.0), 0.0, deg_to_rad(-28.0) * dir)
	_stick(root, Vector3.ZERO, 0.75, 0.0, color)
	for i in 3:
		var tine := _stick(root, Vector3(0.0, 0.25 + 0.2 * i, 0.0), 0.32 - 0.05 * i, deg_to_rad(55.0) * dir, color)
		tine.rotation.x = deg_to_rad(-25.0)


## A thin cylinder standing on `at` inside `parent`, tilted about z by `lean`.
func _stick(parent: Node3D, at: Vector3, length: float, lean: float, color: Color) -> MeshInstance3D:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.012
	cylinder.bottom_radius = 0.028
	cylinder.height = length
	var mesh := Traveler.gray_mesh(cylinder, color)
	mesh.position = at + Vector3(0.0, length / 2.0, 0.0).rotated(Vector3.BACK, lean)
	mesh.rotation.z = lean
	parent.add_child(mesh)
	return mesh


func _part(mesh: Mesh, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	if mesh is BoxMesh:
		(mesh as BoxMesh).size = size
	elif mesh is SphereMesh:
		(mesh as SphereMesh).radius = size.x
		(mesh as SphereMesh).height = size.x * 2.0
	var instance := Traveler.gray_mesh(mesh, color)
	instance.position = at
	add_child(instance)
	return instance


func _color(c: Array) -> Color:
	return Color(c[0], c[1], c[2])
