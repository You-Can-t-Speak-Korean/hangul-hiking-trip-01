extends CharacterBody3D
## A placeholder traveler: a capsule and a nose box that
## shows which way it faces. The origin is at its feet.

const HEIGHT := 1.7
const RADIUS := 0.35

var speed: float = 4.5
## Where the origin may stand, as a Rect2 over (x, z).
var bounds := Rect2()


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


## Walks with an input vector: x = along the stage, y = depth (up = into the
## scene, so y < 0 is away from the camera). Same speed in every direction.
func drive(input: Vector2, delta: float) -> void:
	var dir := input.limit_length(1.0)
	if dir.is_zero_approx():
		return
	_move(Vector3(dir.x, 0.0, dir.y) * speed * delta)
	_face(dir)


## Placeholder AI: walks toward `target` and stops `stop_distance` short of it.
func follow(target: Vector3, stop_distance: float, delta: float) -> void:
	var to := target - global_position
	to.y = 0.0
	var distance := to.length()
	if distance <= stop_distance:
		return
	var dir := to / distance
	_move(dir * minf(speed * delta, distance - stop_distance))
	_face(Vector2(dir.x, dir.z))


func _move(motion: Vector3) -> void:
	var hit := move_and_collide(motion)
	if hit:
		move_and_collide(hit.get_remainder().slide(hit.get_normal()))
	var p := global_position
	p.x = clampf(p.x, bounds.position.x, bounds.end.x)
	p.z = clampf(p.z, bounds.position.y, bounds.end.y)
	global_position = p


func _face(dir: Vector2) -> void:
	rotation.y = atan2(-dir.x, -dir.y)
