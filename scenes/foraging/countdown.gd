extends RefCounted
## The stuck countdown's clock and the monster's kill timeline, with no nodes.
## Countdown: one run per stuck episode (a stretch of "stuck" verdicts). It
## starts on the first stuck verdict of an episode, is cancelled by a verdict that
## is not stuck, stands still while `paused`, and from `lockout` seconds before
## the end it can no longer be cancelled (the scene locks its inputs there).

## Seconds from the start to the monster (data: foraging.stuck.countdown_seconds)
## and the last seconds that cannot be cancelled (stuck.lockout_seconds).
var duration := 40.0
var lockout := 1.0
## Seconds left; meaningful while `running`.
var left := 0.0
var running := false
var paused := false
## True once the clock has reached 0 in this episode (it fires "expired" once).
var expired := false
## How many runs have started (a run per episode).
var starts := 0

var _episode := false  # a stuck verdict is in force and has had its run


func _init(config: Dictionary) -> void:
	duration = float(config["countdown_seconds"])
	lockout = float(config["lockout_seconds"])


## Feeds the latest verdict. `allowed` is false while the scene is dying or a
## traveler is dead: then nothing starts. Returns "started", "cancelled" or "".
func verdict(stuck: bool, allowed: bool = true) -> String:
	if not stuck:
		_episode = false
		if running and not is_locked():
			_stop()
			return "cancelled"
		return ""
	if _episode or not allowed or expired:
		return ""
	_episode = true
	running = true
	left = duration
	starts += 1
	return "started"


## Advances the clock. Returns true once, when it reaches 0.
func tick(delta: float) -> bool:
	if not running or paused or expired:
		return false
	left = maxf(left - delta, 0.0)
	if left <= 0.0:
		expired = true
		running = false
		return true
	return false


## Stops without an episode ending (the scene is dying).
func abandon() -> void:
	_stop()


## True in the last `lockout` seconds: the verdict can no longer cancel the run.
func is_locked() -> bool:
	return running and left <= lockout


## 0 at the start, 1 at the end.
func fraction() -> float:
	return clampf(1.0 - left / maxf(duration, 0.001), 0.0, 1.0) if running or expired else 0.0


## The whole seconds shown (rounded up, so 40 at the start and 1 until the end).
func shown_seconds() -> int:
	return ceili(left - 0.0005) if running else 0  # (a hair of float error must not show 31)


## Vignette opacity: `strength` at the end, growing as fraction^growth.
static func vignette_alpha(fraction_done: float, strength: float, growth: float) -> float:
	return strength * pow(clampf(fraction_done, 0.0, 1.0), growth)


func _stop() -> void:
	running = false
	left = 0.0
