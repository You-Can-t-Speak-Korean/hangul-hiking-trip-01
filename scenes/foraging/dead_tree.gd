extends "res://scenes/foraging/prop.gd"
## The 구상나무 고사목: a pale grey-white dead fir, twisty, at the far right (uphill)
## edge. Placeholder, from primitives. Two trunks stand either side of a gap
## `gap_width` wide (along z), leaning over it; a gnarled `Barrier` branch lies across
## the gap until the scene is finished, and `open()` takes it away. The origin is on the
## ground in the middle of the gap, so the gap runs along z from -gap_width/2 to +gap_width/2.
## It is a Prop, so it fades like one when it covers a traveler.

const TRUNK_COLOR := Color(0.83, 0.81, 0.74)
const BARK_SHADOW := Color(0.62, 0.6, 0.55)
const SEGMENTS := 5
const TravelerScript := preload("res://scenes/foraging/traveler.gd")

var is_open := false
var barrier: Node3D
var gap_width := 2.2
var _tween: Tween


## `tree` is ending.dead_tree: height, trunk_radius, gap_width.
func setup(tree: Dictionary) -> void:
	name = "DeadTree"
	gap_width = float(tree["gap_width"])
	var height := float(tree["height"])
	var radius := float(tree["trunk_radius"])
	for side in [-1.0, 1.0]:
		_add_trunk(side, height, radius)
	barrier = Node3D.new()
	barrier.name = "Barrier"
	var log_mesh := CylinderMesh.new()
	log_mesh.top_radius = radius * 0.45
	log_mesh.bottom_radius = radius * 0.55
	log_mesh.height = gap_width + radius * 1.6
	var beam := TravelerScript.gray_mesh(log_mesh, TRUNK_COLOR.darkened(0.08))
	beam.rotation.x = PI / 2.0  # lies along z, across the gap
	beam.position.y = 0.9
	barrier.add_child(beam)
	var spur_mesh := CylinderMesh.new()
	spur_mesh.top_radius = 0.03
	spur_mesh.bottom_radius = 0.09
	spur_mesh.height = 1.1
	for i in 2:  # two broken branches stick up from it
		var spur := TravelerScript.gray_mesh(spur_mesh, BARK_SHADOW)
		spur.position = Vector3(0.0, 1.35, (-0.4 + 0.8 * i) * gap_width / 2.0)
		spur.rotation = Vector3(0.0, 0.0, 0.5 - 1.0 * i)
		barrier.add_child(spur)
	add_child(barrier)


## One twisty trunk: a stack of slightly tilted cylinders that narrows upward and leans
## toward the gap, with a few bare branches. `side` is -1 or +1 along z.
func _add_trunk(side: float, height: float, radius: float) -> void:
	var trunk := Node3D.new()
	trunk.name = "Trunk%s" % ("Near" if side > 0.0 else "Far")
	var base_z := side * (gap_width / 2.0 + radius * 1.1)
	var piece_height := height / SEGMENTS
	var cursor := Vector3(0.0, 0.0, base_z)
	for i in SEGMENTS:
		var taper := 1.0 - 0.14 * i
		var mesh := CylinderMesh.new()
		mesh.top_radius = radius * (taper - 0.14)
		mesh.bottom_radius = radius * taper
		mesh.height = piece_height * 1.1
		var segment := TravelerScript.gray_mesh(mesh, TRUNK_COLOR.darkened(0.04 * (i % 2)))
		var lean := -side * 0.2 * (i + 1) / SEGMENTS  # toward the gap, more with height
		segment.rotation = Vector3(lean + 0.12 * cos(2.3 * i + side), 0.0, 0.22 * sin(1.7 * i + side))
		segment.position = cursor + Vector3(0.0, piece_height / 2.0, 0.0)
		trunk.add_child(segment)
		cursor += Vector3(0.0, piece_height * 0.95, -side * piece_height * 0.12 * (i + 1) / SEGMENTS * 2.0)
		if i >= 1:  # a bare branch from every piece but the lowest
			var branch_mesh := CylinderMesh.new()
			branch_mesh.top_radius = 0.02
			branch_mesh.bottom_radius = radius * 0.22
			branch_mesh.height = 1.4 - 0.15 * i
			var branch := TravelerScript.gray_mesh(branch_mesh, BARK_SHADOW.lightened(0.1 * (i % 2)))
			var away := side if i % 2 == 0 else -side
			branch.position = cursor
			branch.rotation = Vector3(away * 1.0, 0.0, 0.5 * sin(i + side))
			trunk.add_child(branch)
	add_child(trunk)


## Takes the barrier away: it tips over and sinks, then goes. The gap is open from this call on.
func open(seconds: float) -> void:
	if is_open:
		return
	is_open = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not is_inside_tree() or seconds <= 0.0:
		barrier.visible = false
		return
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(barrier, "rotation:z", 0.9, seconds)
	_tween.tween_property(barrier, "position:y", -1.2, seconds)
	_tween.chain().tween_callback(func() -> void: barrier.visible = false)


## Puts the barrier back at once (a map that is restarted without being reloaded).
func close() -> void:
	is_open = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	barrier.visible = true
	barrier.rotation = Vector3.ZERO
	barrier.position = Vector3.ZERO
