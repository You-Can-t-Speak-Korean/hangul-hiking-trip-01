extends RefCounted
## The pause menu's rules, with no nodes: when it may open, which button has the
## focus, and the restart confirmation. The HUD draws it and calls in; the map
## decides whether it may open (`allowed`) and does the pausing and the restart.
##
## Two screens, each with two choices:
##   menu     0 Resume, 1 Restart scene
##   confirm  0 Yes, 1 No          ("Restart? Progress in this scene is lost.")
## The focus wraps. A new screen starts on Resume (menu) or on No (confirm, so a
## double tap of the pick key cannot throw the scene away).

const COUNT := 2
const RESUME := 0
const RESTART := 1
const YES := 0
const NO := 1

var is_open := false
var confirming := false
var focus := RESUME
## How many times Yes was chosen. It is 1 at most: a restart is asked for once.
var restart_requests := 0


## Opens the menu. False if `allowed` is false (the map says so), it is open
## already, or a restart has been asked for.
func open(allowed: bool) -> bool:
	if not allowed or is_open or restart_requests > 0:
		return false
	is_open = true
	confirming = false
	focus = RESUME
	return true


## Closes it (Resume). False if it was not open.
func close() -> bool:
	if not is_open:
		return false
	is_open = false
	confirming = false
	focus = RESUME
	return true


## Moves the focus one choice, wrapping: -1 up, +1 down. Does nothing when closed.
func move(step: int) -> void:
	if is_open:
		focus = posmod(focus + step, COUNT)


## Puts the focus on a choice (the mouse is over it). Does nothing when closed.
func focus_on(index: int) -> void:
	if is_open and index >= 0 and index < COUNT:
		focus = index


## Presses the focused choice. Returns what happened: "resume" (closed), "ask" (the
## confirmation is up), "restart" (Yes: the caller restarts the scene, once),
## "back" (No: the menu again, on Restart scene) or "" (closed, or already restarting).
func activate() -> String:
	if not is_open:
		return ""
	if not confirming:
		if focus == RESUME:
			close()
			return "resume"
		confirming = true
		focus = NO
		return "ask"
	if focus == YES:
		restart_requests += 1
		is_open = false
		confirming = false
		return "restart"
	confirming = false
	focus = RESTART
	return "back"


## Esc. Closed: opens the menu if `allowed` ("open"). Open: Resume ("resume"), or
## No on the confirmation ("back"). "" if nothing happened.
func escape(allowed: bool) -> String:
	if not is_open:
		return "open" if open(allowed) else ""
	if confirming:
		confirming = false
		focus = RESTART
		return "back"
	close()
	return "resume"
