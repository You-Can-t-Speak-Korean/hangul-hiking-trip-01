extends RefCounted
## The animal scene's water surface (data: animals.lake in data/mountains/<game>.json).
## A half-disc mesh on the lake circle, `water_y` above the ground, with one opaque shader:
## a radial deep -> rim gradient, a rippling normal map and a low roughness. No collision
## (the lake's invisible wall is the scene's). Coordinates as in the animal scene.

## Opaque on purpose: no ALPHA, no blend mode, no screen or depth reads (Compatibility-safe).
const SHADER_CODE := """shader_type spatial;
render_mode cull_disabled;

uniform vec3 deep_color : source_color;
uniform vec3 rim_color : source_color;
uniform float light_scale = 0.37;
uniform float lake_radius = 12.0;
uniform float water_roughness = 0.15;
uniform sampler2D ripple_map : filter_linear_mipmap, repeat_enable;
uniform float scale_a = 0.25;
uniform float scale_b = 0.4;
uniform vec2 speed_a = vec2(0.012, 0.006);
uniform vec2 speed_b = vec2(-0.007, 0.011);
uniform float ripple_strength = 0.6;

varying vec2 v_local;
varying vec2 v_world;

void vertex() {
	v_local = VERTEX.xz;
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	float r = clamp(length(v_local) / lake_radius, 0.0, 1.0);
	float t = r * r * (3.0 - 2.0 * r);
	ALBEDO = mix(deep_color, rim_color, t) * light_scale;
	ROUGHNESS = water_roughness;
	METALLIC = 0.0;
	vec3 na = texture(ripple_map, v_world * scale_a + TIME * speed_a).xyz * 2.0 - 1.0;
	vec3 nb = texture(ripple_map, v_world * scale_b + TIME * speed_b).xyz * 2.0 - 1.0;
	vec3 n = normalize(vec3(na.xy + nb.xy, na.z * nb.z));
	NORMAL_MAP = n * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = ripple_strength;
}
"""


## The node: a MeshInstance3D named "Water" at the lake centre, hugging the terrain.
## `terrain` is the scene's Terrain (height_at / slope_at over x).
static func build(cfg: Dictionary, terrain) -> MeshInstance3D:
	var lake: Dictionary = cfg["lake"]
	var center := Vector2(float(lake["center"][0]), float(lake["center"][1]))
	var radius := float(lake["radius"])
	var node := MeshInstance3D.new()
	node.name = "Water"
	node.position = Vector3(center.x, 0.0, center.y)
	node.mesh = mesh(center, radius, float(lake["water_y"]), int(lake["segments"]), int(lake["rings"]), terrain)
	node.material_override = material(cfg)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## The half disc (z <= centre z) in rings and segments; vertices relative to the centre.
static func mesh(center: Vector2, radius: float, water_y: float, segments: int, rings: int, terrain) -> ArrayMesh:
	segments = maxi(segments, 8)
	rings = maxi(rings, 1)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for ring in rings:
		var r0 := radius * ring / rings
		var r1 := radius * (ring + 1) / rings
		for i in segments:
			var a0 := PI * i / segments
			var a1 := PI * (i + 1) / segments
			var p00 := _vertex(center, r0, a0, water_y, terrain)
			var p01 := _vertex(center, r0, a1, water_y, terrain)
			var p10 := _vertex(center, r1, a0, water_y, terrain)
			var p11 := _vertex(center, r1, a1, water_y, terrain)
			if ring > 0:
				_triangle(surface, p00, p10, p01, terrain, center.x)
			_triangle(surface, p01, p10, p11, terrain, center.x)
	return surface.commit()


static func _vertex(center: Vector2, r: float, angle: float, water_y: float, terrain) -> Vector3:
	var x := center.x + cos(angle) * r
	return Vector3(cos(angle) * r, terrain.height_at(x) + water_y, -sin(angle) * r)


## Adds a triangle facing up (clockwise seen from above, like the ground) with the ground's
## normal and a tangent along x.
static func _triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, terrain, origin_x: float) -> void:
	var corners := [a, b, c]
	if (b.z - a.z) * (c.x - a.x) - (b.x - a.x) * (c.z - a.z) > 0.0:
		corners = [a, c, b]
	for corner in corners:
		var slope: float = terrain.slope_at(corner.x + origin_x)
		surface.set_normal(Vector3(-slope, 1.0, 0.0).normalized())
		surface.set_tangent(Plane(Vector3(1.0, slope, 0.0).normalized(), 1.0))
		surface.add_vertex(corner)


static func material(cfg: Dictionary) -> ShaderMaterial:
	var lake: Dictionary = cfg["lake"]
	var ripple: Dictionary = lake["ripple"]
	var shader := Shader.new()
	shader.code = SHADER_CODE
	var m := ShaderMaterial.new()
	m.shader = shader
	m.set_shader_parameter("deep_color", Color.html(String(lake["deep"])))
	m.set_shader_parameter("rim_color", Color.html(String(lake["rim"])))
	m.set_shader_parameter("light_scale", float(cfg["ground"]["light_scale"]))
	m.set_shader_parameter("lake_radius", float(lake["radius"]))
	m.set_shader_parameter("water_roughness", float(lake["roughness"]))
	m.set_shader_parameter("ripple_map", ripple_texture(ripple))
	m.set_shader_parameter("scale_a", float(ripple["scale"]))
	m.set_shader_parameter("scale_b", float(ripple["scale_b"]))
	m.set_shader_parameter("speed_a", Vector2(float(ripple["speed_a"][0]), float(ripple["speed_a"][1])))
	m.set_shader_parameter("speed_b", Vector2(float(ripple["speed_b"][0]), float(ripple["speed_b"][1])))
	m.set_shader_parameter("ripple_strength", float(ripple["strength"]))
	return m


## A seamless normal map baked from seamless simplex noise (wrapped differences).
static func ripple_texture(ripple: Dictionary) -> ImageTexture:
	var size := int(ripple["texture_px"])
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = int(ripple["seed"])
	noise.frequency = float(ripple["noise_frequency"])
	var height := noise.get_seamless_image(size, size)
	var bump := float(ripple["bump"])
	var bytes := PackedByteArray()
	bytes.resize(size * size * 3)
	var at := 0
	for y in size:
		for x in size:
			var dx := height.get_pixel((x + 1) % size, y).r - height.get_pixel((x - 1 + size) % size, y).r
			var dy := height.get_pixel(x, (y + 1) % size).r - height.get_pixel(x, (y - 1 + size) % size).r
			var n := Vector3(-dx * bump, -dy * bump, 1.0).normalized()
			bytes[at] = roundi((n.x * 0.5 + 0.5) * 255.0)
			bytes[at + 1] = roundi((n.y * 0.5 + 0.5) * 255.0)
			bytes[at + 2] = roundi((n.z * 0.5 + 0.5) * 255.0)
			at += 3
	var image := Image.create_from_data(size, size, false, Image.FORMAT_RGB8, bytes)
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
