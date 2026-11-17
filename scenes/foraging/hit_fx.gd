extends RefCounted
## The placeholder hit and death effects both scenes use (data: foraging.gore_placeholder, the
## `gore` dictionary below): the blood burst and red flash on a traveler, the staggered hit on
## both, and the dim layer of the death beat. Static helpers with no state of their own.

const Traveler := preload("res://scenes/foraging/traveler.gd")


static func color(gore: Dictionary, key: String) -> Color:
	var c: Array = gore[key]
	return Color(c[0], c[1], c[2])


## A short spray of dark red droplets at a world position; `strength` scales how many there
## are and how hard they fly (1 is the placeholder gore of 6b). Added under `host`.
static func blood(host: Node3D, gore: Dictionary, at: Vector3, strength: float = 1.0) -> CPUParticles3D:
	var spray := CPUParticles3D.new()
	spray.name = "Blood"
	spray.one_shot = true
	spray.emitting = true
	spray.amount = roundi(40.0 * strength)
	spray.lifetime = float(gore["burst_duration"])
	spray.explosiveness = 0.9
	spray.direction = Vector3.UP
	spray.spread = 75.0
	spray.initial_velocity_min = 2.0 * sqrt(strength)
	spray.initial_velocity_max = 4.5 * sqrt(strength)
	spray.gravity = Vector3(0.0, -9.0, 0.0)
	var drop := SphereMesh.new()
	drop.radius = 0.07
	drop.height = 0.14
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color(gore, "blood_color")
	drop.material = material
	spray.mesh = drop
	var cleanup := Timer.new()
	cleanup.wait_time = float(gore["burst_duration"]) * 2.0
	cleanup.one_shot = true
	cleanup.autostart = true
	cleanup.timeout.connect(spray.queue_free)
	spray.add_child(cleanup)
	host.add_child(spray)
	spray.global_position = at
	return spray


## One traveler is hit: a red flash and a blood burst at the chest.
static func hit(host: Node3D, traveler: Node3D, gore: Dictionary, strength: float = 1.0, tint_time: float = -1.0) -> void:
	traveler.flash(color(gore, "tint_color"), float(gore["tint_duration"]) if tint_time < 0.0 else tint_time)
	blood(host, gore, traveler.global_position + Vector3(0.0, Traveler.HEIGHT * 0.65, 0.0), strength)


## Both travelers (a Dictionary of id -> traveler, in hit order): the second one's hit
## starts gore.stagger seconds after the first. `hit_one` is called as hit_one(id) for each.
static func play_hits(host: Node, ids: Array, gore: Dictionary, hit_one: Callable) -> void:
	var delay := 0.0
	for id in ids:
		if delay <= 0.0:
			hit_one.call(id)
		else:
			host.get_tree().create_timer(delay).timeout.connect(hit_one.bind(id))
		delay += float(gore["stagger"])


## The dim of the death beat: a full-screen transparent black rectangle on its own layer
## (added under `host`). The caller raises its alpha with dim_alpha().
static func make_dim(host: Node) -> ColorRect:
	var layer := CanvasLayer.new()
	layer.layer = 20
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	host.add_child(layer)
	return dim


## The dim's alpha with `left` seconds of the death beat to go.
static func dim_alpha(gore: Dictionary, left: float) -> float:
	var total := maxf(float(gore["death_beat"]), 0.001)
	return float(gore["death_dim_alpha"]) * clampf(1.0 - left / total, 0.0, 1.0)
