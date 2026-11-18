extends RefCounted
## The one-time guide prompts of the animal scene, with no nodes (data: animals.guide). Each
## prompt shows once: `seen` is the dictionary GameState keeps (prompt id -> true), so a scene
## restart does not repeat a prompt and a new hike does. Prompts never stack: a triggered
## prompt waits in a queue until the one on screen is gone. The "start" prompt fires by
## itself `delay_s` seconds after the scene starts.

const START := "start"

var show_s := 4.0
var fade_s := 0.5
## Prompt id -> {"text", "delay_s"?}.
var prompts: Dictionary = {}
## The prompt on screen ("" if none) and how long it has been there.
var current := ""
var current_age := 0.0

var _seen: Dictionary
var _queue: Array[String] = []
var _clock := 0.0


## `config` is animals.guide; `seen` is GameState.guide_seen (shared, written here).
func _init(config: Dictionary, seen: Dictionary) -> void:
	show_s = float(config["show_s"])
	fade_s = float(config["fade_s"])
	prompts = config["prompts"]
	_seen = seen


func has_seen(id: String) -> bool:
	return _seen.has(id)


## Asks for a prompt. Ignored if it was shown before, is on screen, or is already waiting.
func trigger(id: String) -> void:
	if not prompts.has(id) or _seen.has(id) or current == id or _queue.has(id):
		return
	_queue.append(id)
	_promote()


## Advances the clock: the start prompt fires, the one on screen ages and then goes, the
## next one in the queue comes up.
func update(delta: float) -> void:
	_clock += delta
	if prompts.has(START) and _clock >= float(prompts[START].get("delay_s", 0.0)):
		trigger(START)
	if current != "":
		current_age += delta
		if current_age >= show_s + fade_s:
			current = ""
	_promote()


func _promote() -> void:
	if current == "" and not _queue.is_empty():
		current = _queue.pop_front()
		current_age = 0.0
		_seen[current] = true  # shown now: never again, even across a restart


func text() -> String:
	return String(prompts[current]["text"]) if current != "" else ""


## 1 for show_s seconds, then fading to 0 over fade_s.
func alpha() -> float:
	if current == "":
		return 0.0
	if current_age <= show_s:
		return 1.0
	return clampf(1.0 - (current_age - show_s) / maxf(fade_s, 0.001), 0.0, 1.0)


func queued() -> Array[String]:
	return _queue
