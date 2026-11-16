extends RefCounted
## The animal scene's scenery props (data: animals.props). Visual only: no collision, so
## nobody is blocked. place() is node-free (tests check it); build() makes one MultiMesh per
## prop type. Trees and reeds fade (dithered) where they would hide a traveler.

const Ground := preload("res://scenes/animals/ground.gd")

const TYPES: Array[String] = ["tree", "tuft", "reed", "rock"]
const FADE_SHADER := """
shader_type spatial;
uniform vec3 traveler_a = vec3(0.0, -1000.0, 0.0);
uniform vec3 traveler_b = vec3(0.0, -1000.0, 0.0);
uniform vec2 pitch_sin_cos = vec2(0.47, 0.88);
uniform float radius = 1.8;
uniform float amount = 0.85;
uniform float light_scale = 1.0;
uniform float shade_fill = 0.2;
varying vec3 world_pos;

float cover(vec3 p, vec3 t) {
	float dz = p.z - t.z;  // > 0: nearer the camera than the traveler
	float up = (p.y - t.y) * pitch_sin_cos.y - dz * pitch_sin_cos.x;  // screen height above the traveler's feet
	float across = 1.0 - smoothstep(radius * 0.6, radius, abs(p.x - t.x));
	float tall = smoothstep(-0.6, 0.0, up) * (1.0 - smoothstep(1.4, 2.2, up));
	return across * tall * step(-0.3, dz);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float f = max(cover(world_pos, traveler_a), cover(world_pos, traveler_b)) * amount;
	float n = fract(52.9829189 * fract(dot(FRAGCOORD.xy, vec2(0.06711056, 0.00583715))));
	if (n < f) {
		discard;
	}
	vec3 base = COLOR.rgb;  // (the instance colour arrives already linear)
	ALBEDO = base * light_scale;
	EMISSION = base * shade_fill;  // the sides turned from the sun are not black
	ROUGHNESS = 1.0;
}
"""

## The shared fade material of the last build() (the scene feeds it the travelers' places).
var fade_material: ShaderMaterial
## type -> MultiMeshInstance3D
var instances := {}


## Every prop of a seed: type -> Array of {"pos": Vector2, "zone", "size": Vector3 (x/z width,
## y height), "yaw", "color": Color}. `cfg` is the animals section.
static func place(cfg: Dictionary, seed_value: int) -> Dictionary:
	var props: Dictionary = cfg["props"]
	var width := float(cfg["stage"]["width"])
	var depth := float(cfg["stage"]["depth"])
	var lake: Dictionary = cfg["lake"]
	var lake_center := Vector2(float(lake["center"][0]), float(lake["center"][1]))
	var lake_radius := float(lake["radius"])
	var band := float(cfg["habitats"]["shore"]["band_frac"]) * depth
	var forest_end := -depth / 2.0 + float(cfg["habitats"]["forest"]["top_frac"]) * depth
	var edge := float(props["edge_margin_m"])
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("props:%d" % seed_value)
	var starts: Array[Vector2] = []
	for id in cfg["start"]:
		starts.append(Vector2(float(cfg["start"][id][0]), float(cfg["start"][id][1])))
	var out := {}
	for type in TYPES:
		out[type] = []
	var curve: Array = props["tree_density"]
	var curve_max := 0.0
	for point in curve:
		curve_max = maxf(curve_max, float(point[1]))
	for zone in props["counts"]:
		for type in props["counts"][zone]:
			var wanted := int(props["counts"][zone][type])
			var tries := 0
			var made := 0
			while made < wanted and tries < wanted * 400:
				tries += 1
				var spot := Vector2.ZERO
				match zone:
					"forest":
						spot = Vector2(rng.randf_range(edge, width - edge), rng.randf_range(-depth / 2.0 + edge, forest_end - 0.5))
						if type == "tree":
							var t := (spot.y + depth / 2.0) / (forest_end + depth / 2.0)
							if rng.randf() * curve_max > _curve_at(curve, t):
								continue
					"grass":
						spot = Vector2(rng.randf_range(edge, width - edge), rng.randf_range(forest_end + 0.5, depth / 2.0 - edge))
						if spot.y <= lake_center.y and spot.distance_to(lake_center) < lake_radius + band + 0.5:
							continue
					"shore":
						var r0 := lake_radius + float(props["lake_margin_m"])
						var r := sqrt(rng.randf_range(r0 * r0, (lake_radius + band) * (lake_radius + band)))
						var a := rng.randf_range(0.0, PI)
						spot = lake_center + Vector2(cos(a), -sin(a)) * r
						if spot.x < edge or spot.x > width - edge:
							continue
				var near_start := false
				for s in starts:
					near_start = near_start or spot.distance_to(s) < float(props["start_clear_m"])
				if near_start:
					continue
				out[type].append(_make(type, zone, spot, props, cfg, rng))
				made += 1
	return out


static func _curve_at(curve: Array, t: float) -> float:
	if t <= float(curve[0][0]):
		return float(curve[0][1])
	for i in range(1, curve.size()):
		var a: Array = curve[i - 1]
		var b: Array = curve[i]
		if t <= float(b[0]):
			return lerpf(float(a[1]), float(b[1]), (t - float(a[0])) / (float(b[0]) - float(a[0])))
	return float(curve[curve.size() - 1][1])


static func _make(type: String, zone: String, spot: Vector2, props: Dictionary, cfg: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var size := Vector3.ONE
	match type:
		"tree":
			var r := rng.randf_range(float(props["tree_radius"][0]), float(props["tree_radius"][1]))
			size = Vector3(r, rng.randf_range(float(props["tree_min_h"]), float(props["tree_max_h"])), r)
		"tuft":
			var w := rng.randf_range(float(props["tuft"]["width"][0]), float(props["tuft"]["width"][1]))
			size = Vector3(w, float(props["tuft"]["height"]), w)
		"reed":
			size = Vector3(1.0, rng.randf_range(float(props["reed"]["height"][0]), float(props["reed"]["height"][1])), 1.0)
		"rock":
			var s := rng.randf_range(float(props["rock"]["size"][0]), float(props["rock"]["size"][1]))
			size = Vector3(s * rng.randf_range(0.8, 1.25), s * float(props["rock"]["squash"]), s * rng.randf_range(0.8, 1.25))
	var base: Color
	if type == "rock" and zone == "shore":
		base = Color.html(String(props["basalt"]))
	else:
		var palette := Ground.palette(zone, cfg)
		var total := 0.0
		for weight in palette["weights"]:
			total += weight
		var pick := rng.randf() * total
		var index := 0
		while index < palette["weights"].size() - 1 and pick >= palette["weights"][index]:
			pick -= palette["weights"][index]
			index += 1
		base = palette["colors"][index]
	var shade := 1.0 + rng.randf_range(-1.0, 1.0) * float(props["tint_range"])
	return {"pos": spot, "zone": zone, "size": size, "yaw": rng.randf_range(0.0, TAU),
			"color": Color(clampf(base.r * shade, 0.0, 1.0), clampf(base.g * shade, 0.0, 1.0), clampf(base.b * shade, 0.0, 1.0))}


## Builds the MultiMesh nodes under `parent`. `height_at` is a Callable(x) -> ground height.
func build(parent: Node3D, cfg: Dictionary, seed_value: int, height_at: Callable) -> void:
	var props: Dictionary = cfg["props"]
	var placed := place(cfg, seed_value)
	var shader := Shader.new()
	shader.code = FADE_SHADER
	fade_material = ShaderMaterial.new()
	fade_material.shader = shader
	fade_material.set_shader_parameter("radius", float(props["fade_radius_m"]))
	fade_material.set_shader_parameter("amount", float(props["fade_amount"]))
	var light := float(cfg["ground"]["light_scale"])
	fade_material.set_shader_parameter("light_scale", light)
	fade_material.set_shader_parameter("shade_fill", float(props["shade_fill"]))
	var solid := StandardMaterial3D.new()
	solid.albedo_color = Color(light, light, light).linear_to_srgb()  # (albedo_color is sRGB, the factor is linear)
	solid.vertex_color_use_as_albedo = true
	solid.vertex_color_is_srgb = true
	solid.roughness = 1.0
	var trunk_color := Color.html(String(props["trunk_color"]))
	var trunk_material := StandardMaterial3D.new()
	var trunk_linear := trunk_color.srgb_to_linear()
	trunk_material.albedo_color = Color(trunk_linear.r * light, trunk_linear.g * light, trunk_linear.b * light).linear_to_srgb()
	trunk_material.roughness = 1.0
	var trunk_frac := float(props["trunk_frac"])
	var trees: Array = placed["tree"]
	# Trees: a canopy (a cone, tinted) and a trunk (a thin cylinder) per tree.
	var canopy_mesh := CylinderMesh.new()
	canopy_mesh.top_radius = 0.0
	canopy_mesh.bottom_radius = 1.0
	canopy_mesh.height = 1.0
	canopy_mesh.radial_segments = 8
	canopy_mesh.rings = 1
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.09
	trunk_mesh.bottom_radius = 0.12
	trunk_mesh.height = 1.0
	trunk_mesh.radial_segments = 6
	trunk_mesh.rings = 1
	var canopy := _multimesh("TreeCanopies", canopy_mesh, fade_material, trees.size(), true)
	var trunks := _multimesh("TreeTrunks", trunk_mesh, trunk_material, trees.size(), false)
	for i in trees.size():
		var t: Dictionary = trees[i]
		var ground: float = height_at.call(t["pos"].x)
		var h: float = t["size"].y
		var trunk_h := h * trunk_frac
		var canopy_h := h - trunk_h * 0.8
		var rot := Basis(Vector3.UP, t["yaw"])
		trunks.multimesh.set_instance_transform(i, Transform3D(rot * Basis.from_scale(Vector3(1.0, trunk_h, 1.0)), Vector3(t["pos"].x, ground + trunk_h * 0.5, t["pos"].y)))
		canopy.multimesh.set_instance_transform(i, Transform3D(rot * Basis.from_scale(Vector3(t["size"].x, canopy_h, t["size"].x)), Vector3(t["pos"].x, ground + h - canopy_h * 0.5, t["pos"].y)))
		canopy.multimesh.set_instance_color(i, t["color"])
	parent.add_child(canopy)
	parent.add_child(trunks)
	instances["tree"] = canopy
	instances["tree_trunk"] = trunks
	# Tufts: squashed low-poly blobs.
	var blob := SphereMesh.new()
	blob.radius = 0.5
	blob.height = 1.0
	blob.radial_segments = 6
	blob.rings = 3
	_add_simple(parent, "tuft", blob, solid, placed["tuft"], height_at, 0.2)
	# Reeds: thin tall boxes (they fade like trees).
	var reed_mesh := BoxMesh.new()
	reed_mesh.size = Vector3(0.07, 1.0, 0.07)
	_add_simple(parent, "reed", reed_mesh, fade_material, placed["reed"], height_at, 0.5)
	# Rocks: squashed low-poly spheres.
	var rock_mesh := SphereMesh.new()
	rock_mesh.radius = 0.5
	rock_mesh.height = 1.0
	rock_mesh.radial_segments = 7
	rock_mesh.rings = 4
	_add_simple(parent, "rock", rock_mesh, solid, placed["rock"], height_at, 0.25)


func _add_simple(parent: Node3D, type: String, mesh: Mesh, material: Material, list: Array, height_at: Callable, lift: float) -> void:
	var node := _multimesh(type.capitalize() + "s", mesh, material, list.size(), true)
	for i in list.size():
		var p: Dictionary = list[i]
		var basis := Basis(Vector3.UP, p["yaw"]) * Basis.from_scale(Vector3(p["size"].x, p["size"].y, p["size"].z))
		node.multimesh.set_instance_transform(i, Transform3D(basis, Vector3(p["pos"].x, float(height_at.call(p["pos"].x)) + p["size"].y * lift, p["pos"].y)))
		node.multimesh.set_instance_color(i, p["color"])
	parent.add_child(node)
	instances[type] = node


func _multimesh(node_name: String, mesh: Mesh, material: Material, count: int, colors: bool) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = colors
	multi.mesh = mesh
	multi.instance_count = count
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = multi
	node.material_override = material
	return node


## Feeds the fade shader the travelers' ground positions and the camera pitch.
func set_travelers(a: Vector3, b: Vector3, pitch_deg: float) -> void:
	if fade_material == null:
		return
	fade_material.set_shader_parameter("traveler_a", a)
	fade_material.set_shader_parameter("traveler_b", b)
	fade_material.set_shader_parameter("pitch_sin_cos", Vector2(sin(deg_to_rad(pitch_deg)), cos(deg_to_rad(pitch_deg))))
