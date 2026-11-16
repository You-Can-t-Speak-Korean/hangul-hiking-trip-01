extends RefCounted
## The animal scene's generated ground (data: animals.ground in data/mountains/<game>.json).
## Node-free: tests sample zone_weights() and color_at() without a scene, and image() builds
## the texture the scene puts on the floor. Everything is seeded, so one seed is one ground.
## Coordinates as in the animal scene: x along the stage, z depth, 1 unit = 1 m.

const LAKE := 0
const SHORE := 1
const FOREST := 2
const GRASS := 3
const ZONES: Array[String] = ["lake", "shore", "forest", "grass"]

static var _fields := {}  # seed -> {"cfg": Dictionary, "field": Field}


## The share of each zone at a point: {"lake", "shore", "forest", "grass"} -> weight, summing
## to 1. Borders blend over `ground.blend_m`. `cfg` is the animals section.
static func zone_weights(x: float, z: float, cfg: Dictionary) -> Dictionary:
	var w := _field(cfg, 0).weights(x, z)
	return {"lake": w[LAKE], "shore": w[SHORE], "forest": w[FOREST], "grass": w[GRASS]}


## The ground colour at a point for a seed.
static func color_at(x: float, z: float, cfg: Dictionary, seed_value: int) -> Color:
	return _field(cfg, seed_value).color(x, z)


## Whether the point lies in the zone (the hard zones of the crossing: a border has no blend).
static func zone_contains(zone: String, point: Vector2, cfg: Dictionary) -> bool:
	var f := _field(cfg, 0)
	var distance := point.distance_to(f.lake_center)
	if point.x < 0.0 or point.x > f.width or point.y < -f.depth / 2.0 or point.y > f.depth / 2.0:
		return false
	match zone:
		"lake":
			return distance <= f.lake_radius and point.y <= f.lake_center.y
		"shore":
			return distance >= f.lake_radius and distance <= f.lake_radius + f.shore_band and point.y <= f.lake_center.y
		"forest":
			return point.y <= f.forest_end
		"grass":
			return point.y >= f.forest_end and (distance >= f.lake_radius + f.shore_band or point.y > f.lake_center.y)
	return false


## The palette colours of a zone, in data order, and their weights.
static func palette(zone: String, cfg: Dictionary) -> Dictionary:
	var f := _field(cfg, 0)
	return {"colors": f.palettes[zone]["colors"], "weights": f.palettes[zone]["weights"]}


## The Rect2 (over x, z) the texture covers: the whole drawn ground, `ground_rect`.
static func texture_rect(cfg: Dictionary) -> Rect2:
	var width := float(cfg["stage"]["width"])
	var depth := float(cfg["stage"]["depth"])
	var apron: Dictionary = cfg["apron"]
	var side := float(apron["sides"])
	var far := float(apron["far"])
	return Rect2(Vector2(-side, -depth / 2.0 - far), Vector2(width + 2.0 * side, depth + far + side))


## The ground texture image for a seed, covering `rect` at ground.px_per_m.
static func image(cfg: Dictionary, seed_value: int) -> Image:
	var f := _field(cfg, seed_value)
	var rect := texture_rect(cfg)
	var ppm := float(cfg["ground"]["px_per_m"])
	var columns := ceili(rect.size.x * ppm)
	var rows := ceili(rect.size.y * ppm)
	var bytes := PackedByteArray()
	bytes.resize(columns * rows * 3)
	var at := 0
	for row in rows:
		var z := rect.position.y + (row + 0.5) / ppm
		for column in columns:
			var c := f.color(rect.position.x + (column + 0.5) / ppm, z)
			bytes[at] = roundi(c.r * 255.0)
			bytes[at + 1] = roundi(c.g * 255.0)
			bytes[at + 2] = roundi(c.b * 255.0)
			at += 3
	return Image.create_from_data(columns, rows, false, Image.FORMAT_RGB8, bytes)


## A texture from image(), filtered linearly.
static func texture(cfg: Dictionary, seed_value: int) -> ImageTexture:
	return ImageTexture.create_from_image(image(cfg, seed_value))


static func image_hash(img: Image) -> int:
	return hash(img.get_data())


## The water colour at relative radius r (0 = centre, 1 = rim): a smooth gradient from
## `lake.deep` to `lake.rim`. The water shader draws the same gradient.
static func lake_color(r: float, cfg: Dictionary) -> Color:
	var t := clampf(r, 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	return Color.html(String(cfg["lake"]["deep"])).lerp(Color.html(String(cfg["lake"]["rim"])), t)


static func hex(text: String) -> Color:
	return Color.html(text)


static func _field(cfg: Dictionary, seed_value: int) -> Field:
	var cached = _fields.get(seed_value)
	if cached != null and is_same(cached["cfg"], cfg):
		return cached["field"]
	if _fields.size() > 6:
		_fields.clear()
	var f := Field.new(cfg, seed_value)
	_fields[seed_value] = {"cfg": cfg, "field": f}
	return f


## Everything color() needs, parsed once per (cfg, seed).
class Field:
	var width := 0.0
	var depth := 0.0
	var lake_center := Vector2.ZERO
	var lake_radius := 0.0
	var shore_band := 0.0
	var forest_end := 0.0
	var blend := 4.0
	var max_luma := 0.65
	var soften := 0.2
	var patch_gain := 1.0
	var speckle_amount := 0.0
	var under := Color.BLACK
	var mud := Color.BLACK
	var basalt := Color.BLACK
	var bank_m := 0.8
	var bank_blend := 0.3
	var bank_gain := 1.8
	var bank := FastNoiseLite.new()
	## zone name -> {"colors": Array[Color], "weights": Array[float], "bounds": PackedFloat32Array}
	var palettes := {}
	var patch := FastNoiseLite.new()
	var speckle := FastNoiseLite.new()

	func _init(cfg: Dictionary, seed_value: int) -> void:
		width = float(cfg["stage"]["width"])
		depth = float(cfg["stage"]["depth"])
		var lake: Dictionary = cfg["lake"]
		lake_center = Vector2(float(lake["center"][0]), float(lake["center"][1]))
		lake_radius = float(lake["radius"])
		var habitats: Dictionary = cfg["habitats"]
		shore_band = float(habitats["shore"]["band_frac"]) * depth
		forest_end = -depth / 2.0 + float(habitats["forest"]["top_frac"]) * depth
		var g: Dictionary = cfg["ground"]
		blend = maxf(float(g["blend_m"]), 0.001)
		max_luma = float(g["max_luma"])
		soften = clampf(float(g["soften"]), 0.0, 0.5)
		patch_gain = float(g["patch"]["gain"])
		speckle_amount = float(g["speckle"]["amount"])
		under = Color.html(String(lake["under"]))
		mud = Color.html(String(lake["mud"]))
		basalt = Color.html(String(lake["basalt"]))
		bank_m = float(lake["bank_m"])
		bank_blend = clampf(float(lake["bank_blend_m"]), 0.0, bank_m)
		bank_gain = float(lake["bank_gain"])
		bank.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		bank.seed = seed_value + 104729
		bank.frequency = float(lake["bank_frequency"])
		for zone in g["palettes"]:
			var colors: Array[Color] = []
			var weights: Array[float] = []
			var total := 0.0
			for entry in g["palettes"][zone]:
				colors.append(Color.html(String(entry[0])))
				weights.append(float(entry[1]))
				total += float(entry[1])
			var bounds := PackedFloat32Array()
			var run := 0.0
			for weight in weights:
				run += weight / total
				bounds.append(run)
			bounds[bounds.size() - 1] = 1.0
			palettes[zone] = {"colors": colors, "weights": weights, "bounds": bounds}
		patch.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		patch.seed = seed_value
		patch.frequency = float(g["patch"]["frequency"])
		speckle.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		speckle.seed = seed_value + 7919
		speckle.frequency = float(g["speckle"]["frequency"])

	## [lake, shore, forest, grass] weights summing to 1.
	func weights(x: float, z: float) -> PackedFloat32Array:
		var d := Vector2(x, z).distance_to(lake_center)
		var below := lake_center.y - z  # > 0 above the lake's flat edge
		var lake_w := _smooth(minf(lake_radius - d, below))
		var shore_w := _smooth(minf(minf(d - lake_radius, lake_radius + shore_band - d), below))
		var forest_w := _smooth(forest_end - z)
		var grass_w := maxf(0.0, 1.0 - lake_w - shore_w - forest_w)
		var total := lake_w + shore_w + forest_w + grass_w
		return PackedFloat32Array([lake_w / total, shore_w / total, forest_w / total, grass_w / total])

	## `inside` = signed distance in metres into the zone; 0.5 at the border.
	func _smooth(inside: float) -> float:
		var t := clampf(inside / blend + 0.5, 0.0, 1.0)
		return t * t * (3.0 - 2.0 * t)

	func color(x: float, z: float) -> Color:
		var d := Vector2(x, z).distance_to(lake_center)
		var half := z <= lake_center.y
		if half and d <= lake_radius:
			return under  # plain ground under the water
		var land := _land_color(x, z)
		if half and d <= lake_radius + bank_m:
			var m := clampf(0.5 + bank.get_noise_2d(x, z) * bank_gain, 0.0, 1.0)
			var bank_color := mud.lerp(basalt, m)
			var edge := lake_radius + bank_m - d  # metres to the bank's outer edge
			if edge >= bank_blend:
				return bank_color
			return land.lerp(bank_color, edge / bank_blend)
		return land

	## The land colour: the zone weights without the lake's share (the water has a crisp rim).
	func _land_color(x: float, z: float) -> Color:
		var w := weights(x, z)
		var land_total := w[SHORE] + w[FOREST] + w[GRASS]
		var mixed := Color(0.0, 0.0, 0.0)
		var t := clampf(0.5 + patch.get_noise_2d(x, z) * patch_gain + speckle.get_noise_2d(x, z) * speckle_amount, 0.0, 0.99999)
		for zone in [SHORE, FOREST, GRASS]:
			var weight: float = w[zone] / maxf(land_total, 0.0001)
			if weight <= 0.0001:
				continue
			mixed += _palette_color(palettes[ZONES[zone]], t) * weight
		mixed.a = 1.0
		var luma := mixed.get_luminance()
		if luma > max_luma:
			var k := max_luma / luma
			mixed = Color(mixed.r * k, mixed.g * k, mixed.b * k)
		return mixed

	## The palette colour at position t (0..1) along the weighted palette; the ends of each
	## colour's stretch blend halfway toward the neighbour, so patches have soft edges.
	func _palette_color(palette: Dictionary, t: float) -> Color:
		var colors: Array = palette["colors"]
		var bounds: PackedFloat32Array = palette["bounds"]
		var i := 0
		while t >= bounds[i]:
			i += 1
		var low := bounds[i - 1] if i > 0 else 0.0
		var f := (t - low) / (bounds[i] - low)
		var c: Color = colors[i]
		if soften <= 0.0:
			return c
		if f < soften and i > 0:
			return c.lerp(colors[i - 1], 0.5 * (1.0 - f / soften))
		if f > 1.0 - soften and i < colors.size() - 1:
			return c.lerp(colors[i + 1], 0.5 * (1.0 - (1.0 - f) / soften))
		return c
