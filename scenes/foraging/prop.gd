extends Node3D
## A rock or tree. Fades out while it stands between the camera and a traveler.
## Plants are not props and never fade.

## Current opacity, 1.0 = solid.
var alpha := 1.0
## World-space box around the whole prop, set once it is in the tree.
var bounds := AABB()

var _materials: Array[StandardMaterial3D] = []


## Call once the prop and its meshes are in the tree and in place.
func finish() -> void:
	var first := true
	for node in find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		var box := instance.global_transform * instance.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
		var material := instance.material_override as StandardMaterial3D
		if material:
			_materials.append(material)


func set_alpha(value: float) -> void:
	if is_equal_approx(value, alpha):
		return
	alpha = value
	# Solid props stay in the opaque pass; only a fading one is blended.
	var mode := BaseMaterial3D.TRANSPARENCY_DISABLED if alpha >= 1.0 else BaseMaterial3D.TRANSPARENCY_ALPHA
	for material in _materials:
		material.transparency = mode
		var color := material.albedo_color
		color.a = alpha
		material.albedo_color = color
