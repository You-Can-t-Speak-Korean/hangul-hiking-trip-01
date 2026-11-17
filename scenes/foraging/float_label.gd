extends RefCounted
## The short label that rises from a world position and fades ("+2 고사리", "+1 쌍화탕"): one
## Label3D with its own tween, shared by the foraging and animal scenes (data: the
## decoy_rewards.floating_label block).

const FONT := preload("res://art/fonts/NotoSansKR-VariableFont_wght.ttf")


## Puts the label in `host` at the world position `at`, rising and fading as `cfg` says.
static func make(host: Node3D, text: String, at: Vector3, cfg: Dictionary) -> Label3D:
	var label := Label3D.new()
	label.name = "FloatingLabel"  # a second one at once is renamed by Godot; find them by type
	label.text = text
	label.font = FONT
	label.font_size = int(cfg["font_size"])
	label.pixel_size = float(cfg["pixel_size"])
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.no_depth_test = true  # never hidden by the thing it rose from
	label.render_priority = int(cfg["render_priority"])  # sorted in front of the steam puff
	label.outline_render_priority = int(cfg["render_priority"]) - 1  # the outline stays behind its own text
	label.outline_size = 16
	label.outline_modulate = Color(0.08, 0.06, 0.1)
	var c: Array = cfg["color"]
	label.modulate = Color(c[0], c[1], c[2])
	host.add_child(label)
	label.global_position = at
	var tween := host.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", at.y + float(cfg["rise"]), float(cfg["seconds"]))
	tween.tween_property(label, "modulate:a", 0.0, float(cfg["seconds"]))
	tween.chain().tween_callback(label.queue_free)
	return label
