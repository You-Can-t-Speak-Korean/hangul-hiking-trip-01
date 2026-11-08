extends RefCounted
## The scene ending's rules, with no nodes (data: foraging.ending). The map owns the
## nodes (the note, the 고사목, the black) and asks this for the timings and the maths.
##
## The exit note: once the sixth word is done, `begin_wait()` starts a pause of
## note_delay_s. When it has run out (`tick_wait` returns true) the map picks a landing
## spot with `choose_spot()` and calls `begin_flight()`. The note flies for flight_s
## seconds along an eased line from its start to the spot, fluttering round that line
## (sway, spin, bob, tilt) with an envelope that dies away as it lands, so it comes to
## rest flat on the ground. If the human traveler walks out of the 1.5-3 m range while
## it flies, the map re-aims it with `retarget()`: the flight goes on from where the
## note is, so it never jumps, and still ends at about the same time.
##
## Phases: "idle" (not started), "waiting", "flying", "landed", "taken", "gone".
## The fade: `begin_fade()` / `tick_fade()` / `fade_alpha()` run the black.

const IDLE := "idle"
const WAITING := "waiting"
const FLYING := "flying"
const LANDED := "landed"
const TAKEN := "taken"
const GONE := "gone"

## How many times the random draws may fail before choose_spot() scans the ring.
const SCAN_ANGLES := 72
const SCAN_RINGS := 7
const RANGE_SLACK := 0.001

var config: Dictionary = {}
var note: Dictionary = {}
var phase := IDLE
var wait_left := 0.0
## Seconds flown so far, over the whole flight (re-aims do not reset it).
var elapsed := 0.0
## The line being flown: from, to, seconds on it and how long it lasts.
var seg_from := Vector3.ZERO
var seg_to := Vector3.ZERO
var seg_time := 0.0
var seg_length := 1.0
## Where the note will lie (x, z).
var spot := Vector2.ZERO
var retargets := 0
## The note's resting turn about the vertical, drawn once per scene start.
var rest_yaw := 0.0

var _fade_left := -1.0


func _init(ending_config: Dictionary) -> void:
	config = ending_config
	note = ending_config["note"]


# ---- Numbers from the data ----

func note_delay() -> float:
	return float(config["note_delay_s"])


func flight_seconds() -> float:
	return float(config["flight_s"])


func fade_seconds() -> float:
	return float(config["fade_s"])


func range_min() -> float:
	return float(note["range_min"])


func range_max() -> float:
	return float(note["range_max"])


## The exit's target scene id (data: ending.next).
func next_id() -> String:
	return String(config["next"])


## The 고사목's (x, z).
func tree_position() -> Vector2:
	var t: Array = config["dead_tree"]["position"]
	return Vector2(float(t[0]), float(t[1]))


func gap_width() -> float:
	return float(config["dead_tree"]["gap_width"])


## The strip a traveler may walk once the gap is open, over (x, z): it runs from the
## tree to ending.exit.walk_to_x, as wide as the gap.
func gap_rect() -> Rect2:
	var tree := tree_position()
	var end_x := float(config["exit"]["walk_to_x"])
	return Rect2(Vector2(tree.x - 1.0, tree.y - gap_width() / 2.0), Vector2(end_x - tree.x + 1.0, gap_width()))


## The exit trigger, over (x, z): just beyond the tree.
func trigger_rect() -> Rect2:
	var tree := tree_position()
	var x0 := float(config["exit"]["trigger_from_x"])
	var x1 := float(config["exit"]["walk_to_x"])
	return Rect2(Vector2(x0, tree.y - gap_width() / 2.0), Vector2(x1 - x0, gap_width()))


## The scene path of an exit target id, "" if it is not built (data: ending.scene_paths).
func scene_path(id: String) -> String:
	var path := String(config.get("scene_paths", {}).get(id, ""))
	return path if path != "" and ResourceLoader.exists(path) else ""


## The debug line shown on the black when the target has no scene.
func hold_text(id: String) -> String:
	return String(config["hold_text"]) % id


# ---- The note's timeline ----

## Starts the pause before the note flies in. Only from "idle".
func begin_wait() -> void:
	if phase != IDLE:
		return
	phase = WAITING
	wait_left = note_delay()


## One tick of the pause. True once, when it has run out; the map then starts the flight.
func tick_wait(delta: float) -> bool:
	if phase != WAITING:
		return false
	wait_left = maxf(wait_left - delta, 0.0)
	return wait_left <= 0.0


func begin_flight(from: Vector3, to: Vector3, landing: Vector2, yaw: float) -> void:
	phase = FLYING
	elapsed = 0.0
	seg_from = from
	seg_to = to
	seg_time = 0.0
	seg_length = maxf(flight_seconds(), 0.001)
	spot = landing
	rest_yaw = yaw
	retargets = 0


## Re-aims the flight at a new spot, from where the note is now. The new line takes the
## flight's remaining time, at least retarget_min_s.
func retarget(to: Vector3, landing: Vector2) -> void:
	seg_from = base_position()
	seg_to = to
	seg_time = 0.0
	seg_length = maxf(flight_seconds() - elapsed, float(note["retarget_min_s"]))
	spot = landing
	retargets += 1


## One tick of the flight. True when the line has been flown to its end.
func tick_flight(delta: float) -> bool:
	if phase != FLYING:
		return false
	elapsed += delta
	seg_time = minf(seg_time + delta, seg_length)
	return seg_time >= seg_length


func land() -> void:
	if phase == FLYING:
		phase = LANDED


func take() -> void:
	if phase == LANDED:
		phase = TAKEN


## The note is lost (a death, Restart scene): nothing of it is left.
func clear() -> void:
	phase = GONE if phase != IDLE else IDLE
	wait_left = 0.0


## 0..1 along the current line.
func line_progress() -> float:
	return clampf(seg_time / maxf(seg_length, 0.001), 0.0, 1.0)


## 0..1 over the whole flight.
func flight_progress() -> float:
	return clampf(elapsed / maxf(flight_seconds(), 0.001), 0.0, 1.0)


## The note without its flutter: an ease-out line, quick at first and slowing as it lands.
func base_position() -> Vector3:
	var u := line_progress()
	return seg_from.lerp(seg_to, 1.0 - pow(1.0 - u, 3.0))


## How strongly the flutter shows: 1 at the start, 0 at the end of the flight.
func envelope() -> float:
	return 1.0 - flight_progress()


## Where the note is and how it is turned, fluttering. At the end of the flight the
## flutter is gone and it lies flat on the ground (rotation.x = -90 degrees turns the
## quad's face up) at `rest_lift` above it.
func pose() -> Dictionary:
	var env := envelope()
	var base := base_position()
	var line := seg_to - seg_from
	line.y = 0.0
	var side := Vector3(-line.z, 0.0, line.x)
	side = side.normalized() if side.length() > 0.001 else Vector3.BACK
	var position := base + side * float(note["sway"]) * sin(TAU * float(note["sway_hz"]) * elapsed) * env
	position.y += float(note["bob"]) * sin(TAU * float(note["bob_hz"]) * elapsed) * env + float(note["rest_lift"]) * (1.0 - env)
	var u := flight_progress()
	var spin := deg_to_rad(float(note["spin_deg_s"])) * flight_seconds() * (u - u * u / 2.0)
	var flutter := deg_to_rad(float(note["flutter_deg"]))
	var rotation := Vector3(
		-PI / 2.0 + flutter * sin(TAU * 0.7 * elapsed + 1.0) * env,
		rest_yaw + spin,
		flutter * 0.6 * sin(TAU * 1.3 * elapsed + 2.0) * env)
	return {"position": position, "rotation": rotation}


## True if a spot is 1.5-3 m (the data's range) from the human traveler.
func in_range(from: Vector2, to: Vector2) -> bool:
	var distance := from.distance_to(to)
	return distance >= range_min() - RANGE_SLACK and distance <= range_max() + RANGE_SLACK


## A landing spot 1.5-3 m from `origin` that `valid` (Callable(Vector2) -> bool) accepts.
## `tries` random draws first (angle and distance uniform), then a scan of the whole
## ring from a random angle, so a spot is found whenever one exists. If none does the
## ring point with the greatest distance from an invalid spot is not searched for: the
## mid-range point towards +z is returned with source "none valid" (the map reports it).
## Returns {"spot", "source": "random" | "scan" | "none valid", "tries"}.
func choose_spot(rng: RandomNumberGenerator, origin: Vector2, valid: Callable) -> Dictionary:
	var tries := int(note["tries"])
	for i in tries:
		var candidate := origin + Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(range_min(), range_max())
		if valid.call(candidate):
			return {"spot": candidate, "source": "random", "tries": i + 1}
	var start := rng.randf_range(0.0, TAU)
	for ring in SCAN_RINGS:
		var distance := lerpf(range_min(), range_max(), float(ring) / float(SCAN_RINGS - 1))
		for step in SCAN_ANGLES:
			var candidate := origin + Vector2.from_angle(start + TAU * step / SCAN_ANGLES) * distance
			if valid.call(candidate):
				return {"spot": candidate, "source": "scan", "tries": tries}
	return {"spot": origin + Vector2(0.0, (range_min() + range_max()) / 2.0), "source": "none valid", "tries": tries}


# ---- The fade to black ----

func begin_fade() -> void:
	_fade_left = fade_seconds()


func is_fading() -> bool:
	return _fade_left >= 0.0


## One tick of the fade. True once, when it has reached black.
func tick_fade(delta: float) -> bool:
	if _fade_left < 0.0:
		return false
	_fade_left -= delta
	if _fade_left <= 0.0:
		_fade_left = -1.0
		return true
	return false


## 0 (clear) to 1 (black) while fading; the map holds 1 afterwards.
func fade_alpha() -> float:
	if _fade_left < 0.0:
		return 0.0
	return clampf(1.0 - _fade_left / maxf(fade_seconds(), 0.001), 0.0, 1.0)


func stop_fade() -> void:
	_fade_left = -1.0
