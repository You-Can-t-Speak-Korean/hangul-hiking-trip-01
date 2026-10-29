extends CharacterBody3D
## A placeholder traveler: a capsule and a nose box that
## shows which way it faces. The origin is at its feet.

const HEIGHT := 1.7
const RADIUS := 0.35
const GRAVITY := 20.0
const FLOOR_SNAP := 0.3          # stays glued to the ground going downhill
const FLOOR_MAX_ANGLE := 35.0    # steeper than this is a wall, not floor

var speed: float = 4.5
## Where the origin may stand, as a Rect2 over (x, z).
var bounds := Rect2()
## Optional: x -> the largest z the origin may have there (the view's bottom edge
## moves with the slope). Applied on top of `bounds`.
var near_limit := Callable()
var on_floor := false
var _floor_normal := Vector3.UP
var _fall_speed := 0.0
var _body_material: StandardMaterial3D
var _body_color := Color.WHITE
var _flash: Tween


static func gray_mesh(mesh: Mesh, color: Color) -> MeshInstance3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	return instance


func setup(display_name: String, color: Color) -> void:
	name = display_name
	var capsule := CapsuleMesh.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	var body := gray_mesh(capsule, color)
	_body_material = body.material_override
	_body_color = color
	body.position.y = HEIGHT / 2.0
	add_child(body)

	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.2, 0.2, 0.3)
	var nose := gray_mesh(nose_mesh, color.darkened(0.45))
	nose.position = Vector3(0.0, HEIGHT * 0.8, -RADIUS)
	add_child(nose)

	var shape := CapsuleShape3D.new()
	shape.radius = RADIUS
	shape.height = HEIGHT
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = HEIGHT / 2.0
	add_child(collision)


## Placeholder hit feedback: the body flashes `tint` and fades back to its own
## colour over `time` seconds.
func flash(tint: Color, time: float) -> void:
	if _flash != null and _flash.is_valid():
		_flash.kill()
	_body_material.albedo_color = tint
	_flash = create_tween()
	_flash.tween_property(_body_material, "albedo_color", _body_color, time)


## Placeholder kill: the traveler is thrown `away` (a world offset) and falls on
## its side over `time` seconds. It stays down; nothing drives it afterwards.
func knock_down(away: Vector3, time: float, tilt_degrees: float = 90.0) -> void:
	var side := -1.0 if away.x >= 0.0 else 1.0  # falls away from where it is thrown
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", global_position + away, time)
	tween.tween_property(self, "rotation:z", side * deg_to_rad(tilt_degrees), time)


## The body's current colour, so tests can see the flash.
func body_color() -> Color:
	return _body_material.albedo_color


## Walks with an input vector: x = along the stage, y = depth (up = into the
## scene, so y < 0 is away from the camera). Same speed in every direction.
func drive(input: Vector2, delta: float) -> void:
	var dir := input.limit_length(1.0)
	if dir.is_zero_approx():
		_settle(delta)
		return
	_move(Vector3(dir.x, 0.0, dir.y) * speed * delta, delta)
	_face(dir)


## Placeholder AI: walks toward `target` and stops `stop_distance` short of it.
func follow(target: Vector3, stop_distance: float, delta: float) -> void:
	var to := target - global_position
	to.y = 0.0
	var distance := to.length()
	if distance <= stop_distance:
		_settle(delta)
		return
	var dir := to / distance
	_move(dir * minf(speed * delta, distance - stop_distance), delta)
	_face(Vector2(dir.x, dir.z))


## `motion` is the horizontal step. On a slope it is tilted along the ground,
## so uphill and downhill cover the same distance along x and z.
func _move(motion: Vector3, delta: float) -> void:
	var step := motion
	if on_floor:
		step.y = -(_floor_normal.x * motion.x + _floor_normal.z * motion.z) / _floor_normal.y
	var hit := move_and_collide(step)
	if hit:
		move_and_collide(hit.get_remainder().slide(hit.get_normal()))
	var p := global_position
	p.x = clampf(p.x, bounds.position.x, bounds.end.x)
	p.z = clampf(p.z, bounds.position.y, bounds.end.y)
	if near_limit.is_valid():
		p.z = minf(p.z, float(near_limit.call(p.x)))
	global_position = p
	_settle(delta)


## Gravity and floor snapping, once per tick whether or not the traveler walked.
func _settle(delta: float) -> void:
	var min_up := cos(deg_to_rad(FLOOR_MAX_ANGLE))
	var hit: KinematicCollision3D
	if on_floor:
		_fall_speed = 0.0
		hit = move_and_collide(Vector3(0.0, -FLOOR_SNAP, 0.0))
	else:
		_fall_speed += GRAVITY * delta
		hit = move_and_collide(Vector3(0.0, -_fall_speed * delta, 0.0))
	on_floor = hit != null and hit.get_normal().y >= min_up
	if on_floor:
		_floor_normal = hit.get_normal()
		_fall_speed = 0.0


func _face(dir: Vector2) -> void:
	rotation.y = atan2(-dir.x, -dir.y)
