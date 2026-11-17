extends RefCounted
## The reach ring (data: foraging.reach_ring) both scenes show: the node and material, and the
## annulus mesh that follows the ground along x. Static helpers.

const SEGMENTS := 48
const LIFT := 0.04   # metres above the ground, so the ring never z-fights


## The ring node (hidden, unshaded, translucent) and its material, as [node, material].
static func make(picking) -> Array:
	var ring := MeshInstance3D.new()
	ring.name = "ReachRing"
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(picking.ring_color, picking.ring_alpha)
	ring.material_override = material
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.visible = false
	return [ring, material]


## An annulus around `centre` between `inner` and `outer` metres, each vertex's height
## following `height_at(x)`. `fraction` (0..1) keeps only that share of the circle, from the
## top (-z) clockwise on screen: the watch-progress ring uses it.
static func mesh(outer: float, inner: float, centre: Vector3, height_at: Callable, fraction: float = 1.0) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := maxi(ceili(SEGMENTS * clampf(fraction, 0.0, 1.0)), 0)
	for i in count:
		var a0 := TAU * i / SEGMENTS
		var a1 := minf(TAU * (i + 1) / SEGMENTS, TAU * fraction)
		var dir0 := Vector2.from_angle(a0 - PI / 2.0)
		var dir1 := Vector2.from_angle(a1 - PI / 2.0)
		var quad: Array[Vector3] = []
		for c: Vector2 in [dir0 * inner, dir0 * outer, dir1 * outer, dir1 * inner]:
			quad.append(Vector3(c.x, float(height_at.call(centre.x + c.x)) - centre.y + LIFT, c.y))
		for index in [0, 1, 2, 0, 2, 3]:
			surface.add_vertex(quad[index])
	return surface.commit() if count > 0 else ArrayMesh.new()
