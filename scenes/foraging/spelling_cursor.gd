extends RefCounted
## The keyboard cursor of the spelling view, with no nodes. It points at one
## tile of the basket, which is laid out as a grid of `columns` tiles per row in
## the basket's own order. Left/right step one tile and wrap around the whole
## basket; up/down step one row, keep the column and wrap, landing on the last
## tile when the next row is shorter. Only the active player's keys act. The
## HUDs call into this and draw it; the placing itself goes through the same
## drop path as the mouse.

## How many tiles a basket row holds (the basket HUD's max_columns).
var columns := 7
## Which player's keys act, 1 (WASD + Space) or 2 (arrows + Enter). The co-op
## turn banner switches it with set_active_player.
var active_player := 1: set = set_active_player
## False until the first key press of a session, and again after the mouse is used.
var shown := false
## The tile the cursor is on (clamped to the basket whenever it changes).
var index := 0


## Anything but 1 or 2 is ignored.
func set_active_player(player: int) -> void:
	if player == 1 or player == 2:
		active_player = player


## "left", "right", "up", "down" or "place" if `event` is a press of the active
## player's key for it, else "". Held movement keys repeat; place does not.
func action_for(event: InputEvent) -> String:
	for direction in ["left", "right", "up", "down"]:
		if event.is_action_pressed("p%d_%s" % [active_player, direction], true):
			return direction
	if event.is_action_pressed("p%d_pick" % active_player):
		return "place"
	return ""


## True if `event` is a press of ANY player's movement or place key.
static func is_player_key(event: InputEvent) -> bool:
	for player in [1, 2]:
		for name in ["left", "right", "up", "down", "pick"]:
			if event.is_action_pressed("p%d_%s" % [player, name], true):
				return true
	return false


## A key of the active player went down over a basket of `count` tiles. Returns
## what the caller has to do: "" (nothing: the basket is empty), "shown" (the
## cursor appeared on the first tile; nothing else happens), "moved" or "place".
func press(action: String, count: int) -> String:
	if count <= 0 or action == "":
		return ""
	if not shown:
		shown = true
		index = 0
		return "shown"
	clamp_to(count)
	if action == "place":
		return "place"
	index = stepped(index, action, count)
	return "moved"


## The tile `action` leads to from `from` in a basket of `count` tiles.
func stepped(from: int, action: String, count: int) -> int:
	if count <= 0:
		return 0
	var cols := maxi(columns, 1)
	match action:
		"left":
			return posmod(from - 1, count)
		"right":
			return posmod(from + 1, count)
		"up", "down":
			var rows := ceili(float(count) / cols)
			var row := posmod(floori(float(from) / cols) + (1 if action == "down" else -1), rows)
			return mini(row * cols + from % cols, count - 1)
	return from


## Keeps the cursor on the basket after tiles left or came back.
func clamp_to(count: int) -> void:
	index = clampi(index, 0, maxi(count - 1, 0))


func hide_cursor() -> void:
	shown = false


## True if a cursor is to be drawn over a basket of `count` tiles.
func is_visible_over(count: int) -> bool:
	return shown and count > 0
