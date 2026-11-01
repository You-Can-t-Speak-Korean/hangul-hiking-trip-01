extends Node3D
## The look of one gore beat (see DecoyGore), placeholder shapes built in code.
## It is a child of the map, not of the traveler, and puts the traveler back
## exactly as it found it when `finish()` runs. Every number comes from the
## foraging.decoy_gore entry.
##
## face_swell_pop: a head blob swells and reddens, then pops into blood and chunks.
## convulse_eyes_pop: the traveler jitters, then two eyes with red tails fly out.

var traveler: Node3D
var gore_id := ""
var cfg: Dictionary = {}
var popped := false

var _base_position := Vector3.ZERO
var _base_transform := Transform3D.IDENTITY  # restored whole: setting Euler angles back drifts the scale by a hair
var _time := 0.0
var _blood: Callable           # (at: Vector3, strength: float) -> CPUParticles3D
var _tint := Color.RED
var _sprays: Array[Node3D] = []
var _head: MeshInstance3D
var _head_material: StandardMaterial3D
var _eyes: Array[Dictionary] = []  # {"node", "velocity"}


static func _color(c: Array) -> Color:
	return Color(c[0], c[1], c[2])


## `blood` makes a blood burst at a world position and strength; `tint` is the
## red a hit flashes a body. Call after the node is in the tree.
func setup(who: Node3D, id: String, entry: Dictionary, blood: Callable, tint: Color) -> void:
	name = "DecoyGoreFx"
	traveler = who
	gore_id = id
	cfg = entry
	_blood = blood
	_tint = tint
	_base_position = who.global_position
	_base_transform = who.global_transform
	if id == "face_swell_pop":
		_head = MeshInstance3D.new()
		_head.name = "SwellingHead"
		var ball := SphereMesh.new()
		ball.radius = float(entry["head_radius"])
		ball.height = float(entry["head_radius"]) * 2.0
		_head_material = StandardMaterial3D.new()
		_head_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_head_material.albedo_color = _color(entry["head_color"])
		ball.material = _head_material
		_head.mesh = ball
		add_child(_head)
		_head.global_position = _head_spot()


func _head_spot() -> Vector3:
	return _base_position + Vector3(0.0, float(cfg.get("head_height", 1.45)), 0.0)


## One tick: `build_up` is 0 at the start of the beat and 1 at the pop.
func advance(delta: float, build_up: float) -> void:
	_time += delta
	if popped:
		_advance_eyes(delta)
		return
	match gore_id:
		"face_swell_pop":
			var eased := build_up * build_up  # slow at first, then fast
			var s := lerpf(1.0, float(cfg["swell_scale"]), eased)
			_head.scale = Vector3.ONE * s
			_head_material.albedo_color = _color(cfg["head_color"]).lerp(_color(cfg["swollen_color"]), eased)
			var shake := float(cfg["shake_amplitude"]) * eased
			_head.global_position = _head_spot() + Vector3(sin(_time * float(cfg["shake_hz"]) * TAU), 0.0, cos(_time * float(cfg["shake_hz"]) * 0.7 * TAU)) * shake
		"convulse_eyes_pop":
			var amp := float(cfg["jitter_amplitude"])
			var hz := float(cfg["jitter_hz"])
			traveler.global_position = _base_position + Vector3(sin(_time * hz * TAU), absf(sin(_time * hz * 0.6 * TAU)) * 0.5, sin(_time * hz * 1.7 * TAU)) * amp
			traveler.rotation.z = _base_transform.basis.get_euler().z + sin(_time * hz * 1.3 * TAU) * deg_to_rad(float(cfg["tilt_degrees"]))


## The pop: the swelling head bursts, or the eyes fly out.
func pop() -> void:
	if popped:
		return
	popped = true
	var at := _head_spot()
	_sprays.append(_blood.call(at, float(cfg["pop_blood_strength"])))
	match gore_id:
		"face_swell_pop":
			_head.visible = false
			_sprays.append(_chunks(at))
		"convulse_eyes_pop":
			traveler.global_transform = _base_transform  # the jitter stops with the pop
			traveler.flash(_tint, 0.3)
			for side in [-1.0, 1.0]:
				_eyes.append(_eye(at, side))


func _chunks(at: Vector3) -> CPUParticles3D:
	var chunks := CPUParticles3D.new()
	chunks.name = "Chunks"
	chunks.one_shot = true
	chunks.emitting = true
	chunks.amount = int(cfg["pop_chunks"])
	chunks.lifetime = 0.7
	chunks.explosiveness = 1.0
	chunks.direction = Vector3.UP
	chunks.spread = 90.0
	chunks.initial_velocity_min = 3.0
	chunks.initial_velocity_max = 6.0
	chunks.gravity = Vector3(0.0, -12.0, 0.0)
	var piece := BoxMesh.new()
	piece.size = Vector3.ONE * 0.12
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = _color(cfg["swollen_color"]).darkened(0.2)
	piece.material = material
	chunks.mesh = piece
	add_child(chunks)
	chunks.global_position = at
	return chunks


## An eye: a white ball with a red tail trailing behind it (+Z of the node, which
## looks along its velocity).
func _eye(at: Vector3, side: float) -> Dictionary:
	var node := Node3D.new()
	node.name = "Eye" + ("Left" if side < 0.0 else "Right")
	var ball := SphereMesh.new()
	var radius := float(cfg["eye_radius"])
	ball.radius = radius
	ball.height = radius * 2.0
	var white := StandardMaterial3D.new()
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	white.albedo_color = _color(cfg["eye_color"])
	ball.material = white
	var eyeball := MeshInstance3D.new()
	eyeball.mesh = ball
	node.add_child(eyeball)
	var cord := CapsuleMesh.new()
	var length := float(cfg["tail_length"])
	cord.radius = radius * 0.45
	cord.height = length
	var red := StandardMaterial3D.new()
	red.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	red.albedo_color = _color(cfg["tail_color"])
	cord.material = red
	var tail := MeshInstance3D.new()
	tail.mesh = cord
	tail.rotation_degrees.x = 90.0  # a capsule stands along Y; lay it along Z
	tail.position.z = radius + length * 0.4
	node.add_child(tail)
	add_child(node)
	node.global_position = at + Vector3(side * 0.12, 0.0, 0.0)
	var velocity := Vector3(side * float(cfg["eye_speed_side"]), float(cfg["eye_speed_up"]), float(cfg["eye_speed_toward"]))
	return {"node": node, "velocity": velocity, "radius": radius}


func _advance_eyes(delta: float) -> void:
	for eye in _eyes:
		var node: Node3D = eye["node"]
		var velocity: Vector3 = eye["velocity"]
		var floor_y := _base_position.y + float(eye["radius"])
		if node.global_position.y > floor_y or velocity.y > 0.0:
			velocity.y -= float(cfg["gravity"]) * delta
			node.global_position += velocity * delta
			if node.global_position.y <= floor_y:
				node.global_position.y = floor_y
				velocity = Vector3.ZERO
			elif velocity.length() > 0.01:
				node.look_at(node.global_position + velocity, Vector3.UP)
			eye["velocity"] = velocity


## The end (or an abandoned beat): the traveler is exactly as it was, every spray
## and shape is gone. Safe to call twice.
func finish() -> void:
	if is_instance_valid(traveler):
		traveler.global_transform = _base_transform
		traveler.reset_flash()
	for spray in _sprays:
		if is_instance_valid(spray):
			if spray.get_parent() != null:
				spray.get_parent().remove_child(spray)  # gone now, not at the end of the frame
			spray.queue_free()
	_sprays.clear()
	if is_inside_tree():
		get_parent().remove_child(self)
	queue_free()
