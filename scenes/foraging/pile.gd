extends Node3D
## A chaos DDEOK pile lying on the ground (look only). Placeholder: the code-drawn
## item icon (item_icon.gd) rendered once into a SubViewport and shown on a small
## tilted Sprite3D. Plain and unshaded on purpose: no glint, no glow, no letter,
## no name. The origin is on the ground. Its click area is on its own physics
## layer, so a click on a pile is never mistaken for a plant.

const ItemIcon := preload("res://scenes/foraging/item_icon.gd")
const PICK_LAYER := 3          # physics layer for the click Area3D (plants use 2)
const EXTENT_WIDTH := 1.2      # click box width and depth, in metres
const EXTENT_HEIGHT := 0.7
const TEXTURE_SIZE := 96       # pixels of the icon's SubViewport
const SIZE := 0.6              # metres across the shown icon
const LIFT := 0.3              # metres from the ground to the icon's centre
const TILT_DEGREES := -60.0    # leans back from standing (-90 would lie flat)

var amount := 0
var icon_id := ""


func setup(pile_amount: int, icon: String) -> void:
	amount = pile_amount
	icon_id = icon
	name = "ChaosPile_%s" % get_instance_id()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(TEXTURE_SIZE, TEXTURE_SIZE)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var drawn := ItemIcon.new()
	drawn.setup(icon, float(TEXTURE_SIZE))
	viewport.add_child(drawn)
	add_child(viewport)
	var sprite := Sprite3D.new()
	sprite.name = "Sprite"
	sprite.texture = viewport.get_texture()
	sprite.pixel_size = SIZE / float(TEXTURE_SIZE)
	sprite.shaded = false
	sprite.double_sided = true
	sprite.rotation_degrees.x = TILT_DEGREES
	sprite.position.y = LIFT
	add_child(sprite)
	var area := Area3D.new()
	area.name = "PickArea"
	area.collision_layer = 1 << (PICK_LAYER - 1)
	area.collision_mask = 0
	var shape := BoxShape3D.new()
	shape.size = Vector3(EXTENT_WIDTH, EXTENT_HEIGHT, EXTENT_WIDTH)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = EXTENT_HEIGHT / 2.0
	area.add_child(collision)
	add_child(area)
