extends RefCounted
## The gore beat after a harm decoy was picked, with no nodes: which beat is
## playing, for whom, how long, and when it pops. The map draws it (DecoyGoreFx)
## and gates the game while it runs. All numbers are data (foraging.decoy_gore).
##
##   problem_with(kinds, table) -> String    why the data is bad, or ""
##   start(id, who, entry) -> bool            false if a beat runs or `entry` is unusable
##   tick(delta) -> Array[String]             "pop" once, then "done" once
##   cancel()                                 drops the beat without "done"

var active := false
var gore_id := ""
var who := ""            # the traveler it plays on
var elapsed := 0.0
var duration := 0.0
var pop_seconds := 0.0
var popped := false
## How many beats have started and finished (a cancelled one counts as neither finished).
var starts := 0
var finishes := 0


## The keys of the table that are not gore entries.
const TABLE_SETTINGS: Array[String] = ["show_captions", "caption_style"]


## Why the gore data can't serve the plant kinds, or "": every decoy kind names a
## gore id that is in `table`, every entry has a duration above 0, a pop time in
## (0, duration] and, if it has one, a non-empty string caption_ko, `show_captions`
## is a bool, and no target has a gore field.
static func problem_with(kinds: Array, table: Variant) -> String:
	if not table is Dictionary:
		return "foraging.decoy_gore is missing or is not a table"
	if table.has("show_captions") and not table["show_captions"] is bool:
		return "decoy_gore show_captions is not true or false"
	if table.has("caption_style") and not table["caption_style"] is Dictionary:
		return "decoy_gore caption_style is not a dictionary"
	for id in table:
		if String(id).begins_with("_") or TABLE_SETTINGS.has(String(id)):
			continue
		var entry: Variant = table[id]
		if not entry is Dictionary:
			return "decoy_gore '%s' is not a dictionary" % id
		var duration := float(entry.get("duration", 0.0))
		if duration <= 0.0:
			return "decoy_gore '%s' has no positive duration (%s)" % [id, str(entry.get("duration", "missing"))]
		var pop := float(entry.get("pop_seconds", 0.0))
		if pop <= 0.0 or pop > duration:
			return "decoy_gore '%s' needs 0 < pop_seconds <= duration (%s of %s)" % [id, str(entry.get("pop_seconds", "missing")), str(duration)]
		if entry.has("caption_ko") and (not entry["caption_ko"] is String or String(entry["caption_ko"]) == ""):
			return "decoy_gore '%s' has a caption_ko that is not a non-empty string" % id
	for kind in kinds:
		var name := String(kind.get("id", "?"))
		if kind.get("kind", "") == "decoy":
			if not kind.has("gore") or String(kind["gore"]) == "":
				return "Decoy '%s' has no gore id" % name
			var gid := String(kind["gore"])
			if gid.begins_with("_") or TABLE_SETTINGS.has(gid) or not table.has(gid):
				return "Decoy '%s' names gore '%s', which is not in decoy_gore" % [name, gid]
		elif kind.has("gore"):
			return "Target '%s' (%s) must not have a gore field" % [name, kind.get("kind", "?")]
	return ""


## The caption shown for gore `id`: its caption_ko, or "" if it has none or
## `show_captions` is false.
static func caption(table: Dictionary, id: String) -> String:
	if not bool(table.get("show_captions", true)) or not table.get(id) is Dictionary:
		return ""
	return String(table[id].get("caption_ko", ""))


## Starts a beat of `entry` (a decoy_gore table entry) on traveler `traveler`.
func start(id: String, traveler: String, entry: Dictionary) -> bool:
	if active or float(entry.get("duration", 0.0)) <= 0.0:
		return false
	active = true
	gore_id = id
	who = traveler
	elapsed = 0.0
	duration = float(entry["duration"])
	pop_seconds = float(entry["pop_seconds"])
	popped = false
	starts += 1
	return true


## Advances the beat. Returns "pop" the first tick elapsed reaches pop_seconds and
## "done" the tick it reaches duration (both on one tick if a long delta spans them).
func tick(delta: float) -> Array[String]:
	var events: Array[String] = []
	if not active:
		return events
	elapsed += delta
	if not popped and elapsed >= pop_seconds:
		popped = true
		events.append("pop")
	if elapsed >= duration:
		active = false
		finishes += 1
		events.append("done")
	return events


func cancel() -> void:
	active = false
	popped = false
	elapsed = 0.0
	who = ""
	gore_id = ""


## 0 at the start, 1 at the end of the beat; 0 when none runs.
func fraction() -> float:
	return clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0) if active else 0.0


## 0 at the start, 1 at the pop (and after it): the build-up.
func build_up() -> float:
	return clampf(elapsed / maxf(pop_seconds, 0.001), 0.0, 1.0) if active else 0.0
