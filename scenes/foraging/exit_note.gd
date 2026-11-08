extends Node3D
## The exit note lying on the ground or fluttering in (look only). Placeholder: a small
## cream paper quad, unshaded and two-sided, with a few darker lines drawn on it as
## text. No glow, no name. The origin is the middle of the paper. The map sets
## `global_position` and `rotation` from Ending.pose() every tick.

const LINE_COUNT := 4

var size := Vector2(0.45, 0.6)


## `paper` is ending.note: its size and color.
func setup(paper: Dictionary) -> void:
	name = "ExitNote"
	size = Vector2(float(paper["size"][0]), float(paper["size"][1]))
	var c: Array = paper["color"]
	var quad := QuadMesh.new()
	quad.size = size
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(c[0], c[1], c[2])
	var sheet := MeshInstance3D.new()
	sheet.name = "Paper"
	sheet.mesh = quad
	sheet.material_override = material
	sheet.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(sheet)
	var ink := StandardMaterial3D.new()
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.cull_mode = BaseMaterial3D.CULL_DISABLED
	ink.albedo_color = Color(c[0], c[1], c[2]).darkened(0.45)
	for i in LINE_COUNT:  # scribbled lines, so it reads as a note from the camera
		var line := QuadMesh.new()
		line.size = Vector2(size.x * 0.7, size.y * 0.05)
		var stroke := MeshInstance3D.new()
		stroke.name = "Line%d" % i
		stroke.mesh = line
		stroke.material_override = ink
		stroke.position = Vector3(0.0, size.y * (0.3 - 0.2 * i), 0.002)
		stroke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(stroke)
