extends Node3D
## The look of one gore beat (see DecoyGore), placeholder shapes built in code.
## It is a child of the map, not of the traveler, and puts the traveler back
## exactly as it found it when `finish()` runs. Every number comes from the
## foraging.decoy_gore entry.
##
## face_swell_pop: a head blob swells and reddens, then pops into blood and chunks.
## convulse_eyes_pop: the traveler jitters, then two eyes with red tails fly out.
## deer_ears_rip: two furry ears grow out of the head, twitch and swivel, tear off in
##   blood and hop away toward the nearest edge of the map.
## deulssuk_drunk: the traveler wobbles round a small circle and hiccups, then a
##   purple fountain arcs out of the mouth and lands in a puddle.

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")
const HOP_SPREAD_DEGREES := 15.0   # how far apart the two ears hop (off the edge direction)
const STAGGER_SAMPLES := 48        # points of the circle checked against props and walk limits
const STAGGER_SHRINKS := [1.0, 0.6, 0.35]
const PUDDLE_GROW := 0.3           # seconds the puddle takes to spread

var traveler: Node3D
var gore_id := ""
var cfg: Dictionary = {}
var popped := false

var _base_position := Vector3.ZERO
var _base_transform := Transform3D.IDENTITY  # restored whole: setting Euler angles back drifts the scale by a hair
var _time := 0.0
var _pop_time := 0.0
var _blood: Callable           # (at: Vector3, strength: float) -> CPUParticles3D
var _tint := Color.RED
var _world: Dictionary = {}    # optional: "bounds" Rect2, "walkable" Callable(Vector2) -> bool, "ground" Callable(float) -> float
var _sprays: Array[Node3D] = []
var _head: MeshInstance3D
var _head_material: StandardMaterial3D
var _eyes: Array[Dictionary] = []  # {"node", "velocity"}
var _ears: Array[Dictionary] = []  # {"node", "side", "velocity"}
var _hop_dir := Vector3(0.0, 0.0, -1.0)
var _caption: Label3D
var _stagger_start := Vector2.ZERO
var _stagger_dir := Vector2.ZERO
var _stagger_radius := 0.0
var _fountain: CPUParticles3D
var _puddle: MeshInstance3D
var _puddle_material: StandardMaterial3D
var _puddle_delay := 0.0


static func _color(c: Array) -> Color:
	return Color(c[0], c[1], c[2])


## `blood` makes a blood burst at a world position and strength; `tint` is the
## red a hit flashes a body. `extras` (all optional): "caption" (text shown above the
## picker) with "caption_style", "bounds" (the walkable Rect2), "walkable" and
## "ground" callables. Call after the node is in the tree.
func setup(who: Node3D, id: String, entry: Dictionary, blood: Callable, tint: Color, extras: Dictionary = {}) -> void:
	name = "DecoyGoreFx"
	traveler = who
	gore_id = id
	cfg = entry
	_blood = blood
	_tint = tint
	_world = extras
	_base_position = who.global_position
	_base_transform = who.global_transform
	if String(extras.get("caption", "")) != "":
		_build_caption(String(extras["caption"]), extras.get("caption_style", {}))
	match id:
		"face_swell_pop":
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
		"deer_ears_rip":
			_hop_dir = _nearest_edge_direction()
			for side in [-1.0, 1.0]:
				_ears.append(_build_ear(side))
		"deulssuk_drunk":
			_plan_stagger()


func _head_spot() -> Vector3:
	return _base_position + Vector3(0.0, float(cfg.get("head_height", 1.45)), 0.0)


func _ground_at(x: float) -> float:
	var ground: Variant = _world.get("ground")
	return float(ground.call(x)) if ground is Callable and (ground as Callable).is_valid() else _base_position.y


## The caption: Noto Sans KR, billboarded, never hidden by the steam or the particles.
func _build_caption(text: String, style: Dictionary) -> void:
	_caption = Label3D.new()
	_caption.name = "GoreCaption"
	_caption.text = text
	_caption.font = FONT
	_caption.font_size = int(style.get("font_size", 56))
	_caption.pixel_size = float(style.get("pixel_size", 0.012))
	_caption.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_caption.shaded = false
	_caption.no_depth_test = true
	_caption.render_priority = int(style.get("render_priority", 20))
	_caption.outline_render_priority = _caption.render_priority - 1
	_caption.outline_size = 16
	_caption.outline_modulate = Color(0.08, 0.06, 0.1)
	_caption.modulate = _color(style["color"]) if style.has("color") else Color(1.0, 0.95, 0.75)
	add_child(_caption)
	_caption.global_position = _base_position + Vector3(0.0, float(style.get("height", 2.6)), 0.0)


# ---- deer_ears_rip ----

## The horizontal direction toward the nearest edge of the walkable map (far, near, left
## or right), or into the scene (-z) when the map's bounds are not known.
func _nearest_edge_direction() -> Vector3:
	var bounds: Variant = _world.get("bounds")
	if not bounds is Rect2 or (bounds as Rect2).size == Vector2.ZERO:
		return Vector3(0.0, 0.0, -1.0)
	var rect: Rect2 = bounds
	var edges := [
		[_base_position.x - rect.position.x, Vector3(-1.0, 0.0, 0.0)],
		[rect.end.x - _base_position.x, Vector3(1.0, 0.0, 0.0)],
		[_base_position.z - rect.position.y, Vector3(0.0, 0.0, -1.0)],
		[rect.end.y - _base_position.z, Vector3(0.0, 0.0, 1.0)],
	]
	var best: Array = edges[0]
	for edge in edges:
		if edge[0] < best[0]:
			best = edge
	return best[1]


## An ear: a pointed brown cone with a lighter inner cone on its front, standing at the
## side of the head. It starts tiny.
func _build_ear(side: float) -> Dictionary:
	var node := Node3D.new()
	node.name = "EarLeft" if side < 0.0 else "EarRight"
	var length := float(cfg["ear_length"])
	var width := float(cfg["ear_width"])
	var outer := CylinderMesh.new()
	outer.top_radius = 0.0
	outer.bottom_radius = width
	outer.height = length
	outer.material = _flat(_color(cfg["ear_color"]))
	var fur := MeshInstance3D.new()
	fur.name = "Fur"
	fur.mesh = outer
	fur.position.y = length / 2.0
	node.add_child(fur)
	var inner := CylinderMesh.new()
	inner.top_radius = 0.0
	inner.bottom_radius = width * 0.55
	inner.height = length * 0.8
	inner.material = _flat(_color(cfg["ear_inner_color"]))
	var lining := MeshInstance3D.new()
	lining.name = "Lining"
	lining.mesh = inner
	lining.position = Vector3(0.0, length * 0.4, width * 0.35)
	node.add_child(lining)
	add_child(node)
	node.global_position = _head_spot() + Vector3(side * float(cfg["head_radius"]), 0.0, 0.0)
	node.scale = Vector3.ONE * 0.05
	return {"node": node, "side": side, "velocity": Vector3.ZERO}


func _flat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material


# ---- deulssuk_drunk ----

## The circle the traveler staggers round: it passes through where it stands (so it
## ends where it began) and every sampled point must be walkable (inside the walk limits, clear of
## props). The largest of a few radii and eight headings that fits; none if nothing does.
func _plan_stagger() -> void:
	_stagger_start = Vector2(_base_position.x, _base_position.z)
	var walkable: Variant = _world.get("walkable")
	if not walkable is Callable:
		return
	var radius := float(cfg.get("stagger_radius", 0.0))
	for shrink in STAGGER_SHRINKS:
		for n in 8:
			var dir := Vector2.from_angle(TAU * n / 8.0)
			if _circle_fits(dir, radius * shrink, walkable):
				_stagger_dir = dir
				_stagger_radius = radius * shrink
				return


func _circle_fits(dir: Vector2, radius: float, walkable: Callable) -> bool:
	if radius <= 0.0:
		return false
	for i in STAGGER_SAMPLES:
		if not walkable.call(_circle_point(dir, radius, TAU * i / STAGGER_SAMPLES)):
			return false
	return true


## A point `theta` radians round the circle of `radius` that passes through the start
## and has its centre `radius` metres from it toward `dir`; theta 0 and TAU are the start.
func _circle_point(dir: Vector2, radius: float, theta: float) -> Vector2:
	return _stagger_start + dir * radius + (-dir * radius).rotated(theta)


## One tick: `build_up` is 0 at the start of the beat and 1 at the pop.
func advance(delta: float, build_up: float) -> void:
	_time += delta
	if popped:
		match gore_id:
			"convulse_eyes_pop":
				_advance_eyes(delta)
			"deer_ears_rip":
				_advance_ears(delta)
			"deulssuk_drunk":
				_advance_vomit()
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
		"deer_ears_rip":
			_grow_ears(build_up)
		"deulssuk_drunk":
			_stagger(build_up)


## The ears grow in the first grow_fraction of the build-up, lean outward, twitch, and
## swivel toward something offscreen over the rest.
func _grow_ears(build_up: float) -> void:
	var grow_end := maxf(float(cfg["grow_fraction"]), 0.001)
	var grown := clampf(build_up / grow_end, 0.0, 1.0)
	var swivel := clampf((build_up - grow_end) / maxf(1.0 - grow_end, 0.001), 0.0, 1.0)
	for ear in _ears:
		var node: Node3D = ear["node"]
		var side: float = ear["side"]
		node.scale = Vector3.ONE * lerpf(0.05, 1.0, grown)
		var twitch := sin(_time * float(cfg["twitch_hz"]) * TAU) * deg_to_rad(float(cfg["twitch_degrees"])) * grown
		node.rotation = Vector3(0.0, -deg_to_rad(float(cfg["swivel_degrees"])) * swivel, -side * deg_to_rad(float(cfg["ear_tilt_degrees"])) + twitch)


## The wobble, the stagger round the circle (once, ending at the start by the pop) and
## the hiccup bobs.
func _stagger(build_up: float) -> void:
	var spot := _stagger_start
	if _stagger_radius > 0.0:
		spot = _circle_point(_stagger_dir, _stagger_radius, TAU * build_up)
	var bob := 0.0
	var hiccups := int(cfg["hiccups"])
	for i in hiccups:
		var begins := float(cfg["pop_seconds"]) * (0.5 + 0.45 * float(i) / maxf(float(hiccups), 1.0))
		var local := (_time - begins) / maxf(float(cfg["hiccup_seconds"]), 0.001)
		if local >= 0.0 and local <= 1.0:
			bob += float(cfg["hiccup_height"]) * sin(PI * local)
	traveler.global_position = Vector3(spot.x, _ground_at(spot.x) + bob, spot.y)
	traveler.rotation.z = _base_transform.basis.get_euler().z + sin(_time * float(cfg["wobble_hz"]) * TAU) * deg_to_rad(float(cfg["wobble_degrees"]))


## The pop: the swelling head bursts, the eyes fly out, the ears tear off, or the
## fountain starts.
func pop() -> void:
	if popped:
		return
	popped = true
	_pop_time = _time
	var at := _head_spot()
	match gore_id:
		"face_swell_pop":
			_sprays.append(_blood.call(at, float(cfg["pop_blood_strength"])))
			_head.visible = false
			_sprays.append(_chunks(at))
		"convulse_eyes_pop":
			_sprays.append(_blood.call(at, float(cfg["pop_blood_strength"])))
			traveler.global_transform = _base_transform  # the jitter stops with the pop
			traveler.flash(_tint, 0.3)
			for side in [-1.0, 1.0]:
				_eyes.append(_eye(at, side))
		"deer_ears_rip":
			traveler.flash(_tint, 0.3)
			for ear in _ears:
				var node: Node3D = ear["node"]
				_sprays.append(_blood.call(node.global_position, float(cfg["pop_blood_strength"])))
				var away := _hop_dir.rotated(Vector3.UP, deg_to_rad(HOP_SPREAD_DEGREES) * float(ear["side"]))
				ear["velocity"] = away * float(cfg["hop_speed"])  # it falls from the head, then hops
		"deulssuk_drunk":
			traveler.global_position = _base_position  # the stagger ends where it began
			_start_fountain()


func _hop_up_speed() -> float:
	return sqrt(2.0 * float(cfg["gravity"]) * float(cfg["hop_height"]))


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


## The torn-off ears fly, land and hop away in small arcs, then shrink to nothing
## `hop_seconds` after the pop.
func _advance_ears(delta: float) -> void:
	var since := _time - _pop_time
	var hop_seconds := maxf(float(cfg["hop_seconds"]), 0.001)
	for ear in _ears:
		var node: Node3D = ear["node"]
		var velocity: Vector3 = ear["velocity"]
		velocity.y -= float(cfg["gravity"]) * delta
		node.global_position += velocity * delta
		var floor_y := _ground_at(node.global_position.x) + float(cfg["ear_width"]) * 0.5
		if node.global_position.y <= floor_y:
			node.global_position.y = floor_y
			velocity.y = _hop_up_speed()
		ear["velocity"] = velocity
		node.rotation.z += float(ear["side"]) * 6.0 * delta
		if since >= hop_seconds:
			node.visible = false
		elif since > hop_seconds * 0.75:
			node.scale = Vector3.ONE * (1.0 - (since - hop_seconds * 0.75) / (hop_seconds * 0.25))


## The purple fountain: droplets arc out of the mouth (toward the camera) under gravity for
## fountain_seconds; where they land a puddle spreads.
func _start_fountain() -> void:
	var speed := float(cfg["fountain_speed"])
	var aim := Vector2(float(cfg["fountain_lift"]), float(cfg["fountain_forward"])).normalized()
	var gravity := float(cfg["gravity"])
	var mouth := _head_spot() + Vector3(0.0, -0.05, 0.25)
	var above := mouth.y - _ground_at(mouth.x)
	var up := speed * aim.x
	var flight := (up + sqrt(up * up + 2.0 * gravity * maxf(above, 0.0))) / gravity
	_fountain = CPUParticles3D.new()
	_fountain.name = "Fountain"
	_fountain.one_shot = false
	_fountain.emitting = true
	_fountain.amount = int(cfg["fountain_particles"])
	_fountain.lifetime = flight
	_fountain.explosiveness = 0.0
	_fountain.direction = Vector3(0.0, aim.x, aim.y)
	_fountain.spread = 10.0
	_fountain.initial_velocity_min = speed * 0.9
	_fountain.initial_velocity_max = speed
	_fountain.gravity = Vector3(0.0, -gravity, 0.0)
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	fade.add_point(0.85, Color(1, 1, 1, 1))  # solid until it lands, then gone
	_fountain.color = _color(cfg["fountain_color"])
	_fountain.color_ramp = fade
	var drop := SphereMesh.new()
	drop.radius = float(cfg["fountain_size"]) / 2.0
	drop.height = float(cfg["fountain_size"])
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	drop.material = material
	_fountain.mesh = drop
	add_child(_fountain)
	_fountain.global_position = mouth
	_sprays.append(_fountain)
	# The puddle lies where the middle of the arc comes down.
	var reach := speed * aim.y * flight
	_puddle_material = StandardMaterial3D.new()
	_puddle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_puddle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_puddle_material.albedo_color = _color(cfg["puddle_color"])
	var disc := CylinderMesh.new()
	disc.top_radius = float(cfg["puddle_radius"])
	disc.bottom_radius = float(cfg["puddle_radius"])
	disc.height = 0.02
	disc.material = _puddle_material
	_puddle = MeshInstance3D.new()
	_puddle.name = "Puddle"
	_puddle.mesh = disc
	_puddle.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_puddle.scale = Vector3(0.001, 1.0, 0.001)
	add_child(_puddle)
	var land := Vector3(mouth.x, 0.0, mouth.z + reach * 0.85)
	land.y = _ground_at(land.x) + 0.03
	_puddle.global_position = land
	_puddle_delay = flight * 0.6


func _advance_vomit() -> void:
	var since := _time - _pop_time
	traveler.rotation.z = _base_transform.basis.get_euler().z + sin(_time * float(cfg["wobble_hz"]) * TAU) * deg_to_rad(float(cfg["wobble_degrees"]))
	if _fountain != null and since >= float(cfg["fountain_seconds"]):
		_fountain.emitting = false
	if _puddle != null:
		var spread := clampf((since - _puddle_delay) / PUDDLE_GROW, 0.001, 1.0)
		_puddle.scale = Vector3(spread, 1.0, spread)
		var left := float(cfg["duration"]) - _time
		_puddle_material.albedo_color.a = clampf(left / maxf(float(cfg["puddle_fade"]), 0.001), 0.0, 1.0)


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
