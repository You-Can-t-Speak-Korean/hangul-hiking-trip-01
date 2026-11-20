extends Node3D
## The placeholder giant brown bear (빌레못동굴 bear) of the animal scene: a big dark-brown
## capsule body with a smaller head box, about 2.5x a traveler's height (data: animals.bear).
## It is a reusable node: the scene calls hunt(target) and ticks it; the downed countdown sends it
## at 0 (Prompt 9c-ii) and the scene timer will (9e). It faces -z (like the travelers' noses).
##
## hunt(target): the bear appears `entry_offscreen_m` outside the camera's footprint on the side
## nearest the target (the near side adds the body's height over tan(pitch), because height
## shifts it up the screen), runs straight at them at speed_mps and stops `reach_m` away.
## tick(delta) returns the events, each once per hunt:
##   "kill"  it has reached the target (the scene does the gore and the damage)
##   "done"  kill_beat_s later (the scene starts the death beat)
## The scene re-hunts (hunt(other, true)) if somebody still stands after the kill.

const Traveler := preload("res://scenes/foraging/traveler.gd")

enum State { IDLE, RUNNING, MAULING, DONE }

var state := State.IDLE
var target: Node3D
var size := Vector3(1.4, 4.25, 2.6)
var speed_mps := 11.0
var entry_offscreen_m := 3.0
var reach_m := 1.6
var burst_strength := 5.0
var kill_beat_s := 0.8

var _view: Callable        # () -> Rect2: the ground the camera shows, over (x, z)
var _height_at: Callable   # (x) -> the ground height there
var _pitch := deg_to_rad(28.0)
var _beat_left := 0.0
var _color := Color(0.28, 0.17, 0.09)


## `config` is animals.bear. `view` returns the camera's footprint as a Rect2 over (x, z),
## `height_at` is the terrain's height along x, `pitch_deg` the camera pitch.
func setup(config: Dictionary, view: Callable, height_at: Callable, pitch_deg: float) -> void:
	name = "Bear"
	var s: Array = config["size"]
	size = Vector3(float(s[0]), float(s[1]), float(s[2]))
	var c: Array = config["color"]
	_color = Color(c[0], c[1], c[2])
	speed_mps = float(config["speed_mps"])
	entry_offscreen_m = float(config["entry_offscreen_m"])
	reach_m = float(config.get("reach_m", reach_m))
	burst_strength = float(config.get("burst_strength", burst_strength))
	kill_beat_s = float(config["kill_beat_s"])
	_view = view
	_height_at = height_at
	_pitch = deg_to_rad(pitch_deg)
	visible = false
	var body := CapsuleMesh.new()
	body.radius = size.x / 2.0
	body.height = size.y * 0.8
	var trunk := Traveler.gray_mesh(body, _color)
	trunk.name = "Body"
	trunk.position = Vector3(0.0, size.y * 0.4, 0.0)
	trunk.rotation.x = deg_to_rad(-12.0)  # leans into the run
	add_child(trunk)
	var skull := BoxMesh.new()
	skull.size = Vector3(size.x * 0.62, size.y * 0.2, size.z * 0.34)
	var head := Traveler.gray_mesh(skull, _color.darkened(0.15))
	head.name = "Head"
	head.position = Vector3(0.0, size.y * 0.86, -size.z * 0.32)
	add_child(head)


func is_active() -> bool:
	return state == State.RUNNING or state == State.MAULING


## Sends the bear for `target`. From off screen (the default), or, with `from_here`, from where
## it stands now (a second target after a kill). False if it is running or mauling already.
func hunt(new_target: Node3D, from_here: bool = false) -> bool:
	if state == State.RUNNING or (state == State.MAULING and not from_here):
		return false
	target = new_target
	if not from_here or not visible:
		global_position = entry_point(target.global_position)
	visible = true
	state = State.RUNNING
	_face()
	return true


## Where the bear enters: just outside the camera's footprint, on the side of it nearest the
## target (west, east, far, near; ties in that order).
func entry_point(at: Vector3) -> Vector3:
	var view: Rect2 = _view.call()
	var gaps := {
		"west": at.x - view.position.x, "east": view.end.x - at.x,
		"far": at.z - view.position.y, "near": view.end.y - at.z,
	}
	var side := "west"
	for key in ["east", "far", "near"]:
		if float(gaps[key]) < float(gaps[side]):
			side = key
	var spot := Vector3(at.x, 0.0, at.z)
	match side:
		"west":
			spot.x = view.position.x - entry_offscreen_m
		"east":
			spot.x = view.end.x + entry_offscreen_m
		"far":
			spot.z = view.position.y - entry_offscreen_m
		"near":
			spot.z = view.end.y + entry_offscreen_m + size.y / tan(_pitch)
	spot.y = _height_at.call(spot.x)
	return spot


## The side name an entry point lies on (for tests): "west", "east", "far" or "near".
func entry_side(at: Vector3) -> String:
	var view: Rect2 = _view.call()
	var spot := entry_point(at)
	if spot.x < view.position.x:
		return "west"
	if spot.x > view.end.x:
		return "east"
	return "far" if spot.z < view.position.y else "near"


## One tick. Returns the events that fell inside it.
func tick(delta: float) -> Array[String]:
	var events: Array[String] = []
	match state:
		State.RUNNING:
			var flat := Vector3(target.global_position.x - global_position.x, 0.0, target.global_position.z - global_position.z)
			var gap := flat.length()
			var step := speed_mps * delta
			if gap - step <= reach_m:
				if gap > reach_m:
					global_position += flat.normalized() * (gap - reach_m)
				global_position.y = _height_at.call(global_position.x)
				state = State.MAULING
				_beat_left = kill_beat_s
				_face()
				events.append("kill")
			else:
				global_position += flat.normalized() * step
				global_position.y = _height_at.call(global_position.x)
				_face()
		State.MAULING:
			_beat_left -= delta
			if _beat_left <= 0.0:
				state = State.DONE
				events.append("done")
	return events


func _face() -> void:
	var heading := target.global_position - global_position
	if Vector2(heading.x, heading.z).length() > 0.001:
		rotation.y = atan2(-heading.x, -heading.z)
