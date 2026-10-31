extends RefCounted
## Fernanda's backpack panel, with no nodes: whether it is open and what a key or
## Esc does to it. The map decides whether it may open (`allowed`) and does the
## pausing; the HUD draws the contents of GameState.inventory. For now the panel
## is only opened, looked at and closed: rows can't be selected or used.


var is_open := false


## Opens it. False if `allowed` is false (the map says so) or it is open already.
func open(allowed: bool) -> bool:
	if not allowed or is_open:
		return false
	is_open = true
	return true


## Closes it. False if it was not open.
func close() -> bool:
	if not is_open:
		return false
	is_open = false
	return true


## A backpack key. Closed: opens it if `allowed` ("open"). Open: closes it
## ("close"), allowed or not. "" if nothing happened.
func toggle(allowed: bool) -> String:
	if is_open:
		close()
		return "close"
	return "open" if open(allowed) else ""


## Esc. Open: closes it ("close"). Closed: "" (the map's own Esc opens the pause menu).
func escape() -> String:
	return "close" if close() else ""
