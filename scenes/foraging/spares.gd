extends RefCounted
## Spare plants, with no nodes. Every completed word earns one credit, once.
## A credit is spent on a spare of that word's kind at that word's slot, carrying
## the jamo the unfinished words are most short of. A completion that finds a
## shortage spends its own credit at once, otherwise the credit is banked; a
## failed syllable spends the oldest banked credits while a shortage is left.
## Credits banked plus spares spawned never pass `cap`. The map settles the
## queued events when the spelling view has closed. A new Spares (a scene
## restart) has nothing.

## Data: foraging.spares.
var cap := 6
var grow_seconds := 0.5
## Word (target kind) id -> where its spare appears, as (x, z).
var slots: Dictionary = {}
## The spares spawned so far: {"word_id", "letter", "spot"}, in spawn order.
var spawned: Array[Dictionary] = []
## The banked credits (word ids), oldest first.
var credits: Array[String] = []
## Every decision, in order: {"event" ("completed" or "failed"), "word_id" ("" if
## no credit was involved), "spawn", "letter", "reason" (why, from choose), "deficit",
## "action" (what happened to the credit)}.
var decisions: Array[Dictionary] = []

var _config: Dictionary
var _plants_data: Dictionary
var _words: Array[Dictionary] = []  # target kinds in data order: {"id", "name"}
var _events: Array[Dictionary] = []  # {"type": "completed" or "failed", "word_id"}
var _seen := {}  # word id -> true, once it has earned (or been refused) its credit


## `config` is foraging.spares, `plants_data` is foraging.plants.
func _init(config: Dictionary, plants_data: Dictionary) -> void:
	_config = config
	_plants_data = plants_data
	cap = int(config["cap"])
	grow_seconds = float(config["grow_seconds"])
	for id in config["slots"]:
		slots[id] = Vector2(float(config["slots"][id][0]), float(config["slots"][id][1]))
	for kind in plants_data["kinds"]:
		if kind["kind"] == "target":
			_words.append({"id": String(kind["id"]), "name": String(kind["name"])})


## A copy with the same credits, spawns and history, to try moves on (Stuck).
func fork() -> RefCounted:
	var copy = get_script().new(_config, _plants_data)
	copy.credits = credits.duplicate()
	copy.spawned = spawned.duplicate()
	copy._events = _events.duplicate()
	copy._seen = _seen.duplicate()
	return copy


## Notes a completed word. False if it was noted before (or is not a word).
func queue(word_id: String) -> bool:
	if _seen.has(word_id) or not slots.has(word_id):
		return false
	_seen[word_id] = true
	_events.append({"type": "completed", "word_id": word_id})
	return true


## Notes a failed syllable (its letters are already destroyed).
func queue_failure() -> void:
	_events.append({"type": "failed", "word_id": ""})


func has_pending() -> bool:
	return not _events.is_empty()


## Credits banked plus spares spawned: what counts against the cap.
func credit_total() -> int:
	return credits.size() + spawned.size()


## The word ids in data order.
func word_ids() -> Array[String]:
	var ids: Array[String] = []
	for word in _words:
		ids.append(word["id"])
	return ids


## The jamo still needed to finish every unfinished word, in data order, each
## word's unjudged blocks left to right, repeats included. `solved` maps a word
## id to how many of its blocks are judged correct.
func needed(solved: Dictionary) -> Array[String]:
	var jamo: Array[String] = []
	for word in _words:
		jamo.append_array(jamo_left(word["id"], int(solved.get(word["id"], 0))))
	return jamo


## The jamo of one word's blocks from block `solved` on, left to right.
func jamo_left(word_id: String, solved: int) -> Array[String]:
	var jamo: Array[String] = []
	for word in _words:
		if word["id"] != word_id:
			continue
		for block in range(solved, Hangul.syllable_count(word["name"])):
			for part in Hangul.decompose(word["name"][block]):
				if part != "":
					jamo.append(part)
	return jamo


## The block count of a word (0 for an unknown id).
func block_count(word_id: String) -> int:
	for word in _words:
		if word["id"] == word_id:
			return Hangul.syllable_count(word["name"])
	return 0


## Which jamo to spawn. `available` is every jamo the player can still get:
## the basket, the letters on target plants (spares included). Returns
## {"letter": "" if nothing is short, "deficit", "reason"}. The largest deficit
## (needed - available, floored at 0) wins; ties go to the jamo met first in
## data order (earliest unfinished word, then its first position).
func choose(solved: Dictionary, available: Array) -> Dictionary:
	var need := needed(solved)
	var counts := {}
	for jamo in need:
		counts[jamo] = int(counts.get(jamo, 0)) + 1
	for jamo in available:
		if counts.has(jamo):
			counts[jamo] = int(counts[jamo]) - 1
	var letter := ""
	var deficit := 0
	for jamo in need:  # first-met order, so a tie keeps the earlier jamo
		if int(counts[jamo]) > deficit:
			letter = jamo
			deficit = int(counts[jamo])
	if letter == "":
		return {"letter": "", "deficit": 0, "reason": "no deficit"}
	return {"letter": letter, "deficit": deficit, "reason": "short of %s by %d" % [letter, deficit]}


## Settles the queued events, in the order they happened. Returns what to
## spawn: {"word_id", "letter", "spot"} per spare. Each spawn counts as
## available for the decisions after it.
func settle(solved: Dictionary, available: Array) -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	var pool := available.duplicate()
	for event in _events:
		if event["type"] == "completed":
			_settle_completion(String(event["word_id"]), solved, pool, orders)
		else:
			_settle_failure(solved, pool, orders)
	_events.clear()
	return orders


func _settle_completion(word_id: String, solved: Dictionary, pool: Array, orders: Array[Dictionary]) -> void:
	var decision := _decision("completed", word_id)
	if credit_total() >= cap:
		decision["reason"] = "cap reached"
		decision["action"] = "no credit (cap reached)"
	else:
		var choice := choose(solved, pool)
		decision["letter"] = choice["letter"]
		decision["reason"] = choice["reason"]
		decision["deficit"] = choice["deficit"]
		if choice["letter"] == "":
			credits.append(word_id)
			decision["action"] = "credit banked"
		else:
			_spawn(word_id, choice["letter"], pool, orders)
			decision["spawn"] = true
			decision["action"] = "credit spent on completion"
	decisions.append(decision)


## Spends the oldest banked credits while a shortage is left.
func _settle_failure(solved: Dictionary, pool: Array, orders: Array[Dictionary]) -> void:
	var first := true
	while true:
		var choice := choose(solved, pool)
		var decision := _decision("failed", "")
		decision["letter"] = choice["letter"]
		decision["reason"] = choice["reason"]
		decision["deficit"] = choice["deficit"]
		if choice["letter"] == "":
			if first:
				decision["action"] = "no shortage, no credit spent"
				decisions.append(decision)
			return
		first = false
		if credits.is_empty():
			decision["action"] = "shortage left uncovered"
			decisions.append(decision)
			return
		var word_id: String = credits.pop_front()
		decision["word_id"] = word_id
		_spawn(word_id, choice["letter"], pool, orders)
		decision["spawn"] = true
		decision["action"] = "credit spent on failure"
		decisions.append(decision)


func _spawn(word_id: String, letter: String, pool: Array, orders: Array[Dictionary]) -> void:
	var order := {"word_id": word_id, "letter": letter, "spot": slots[word_id]}
	spawned.append(order)
	orders.append(order)
	pool.append(letter)


func _decision(event: String, word_id: String) -> Dictionary:
	return {"event": event, "word_id": word_id, "spawn": false, "letter": "", "reason": "", "deficit": 0, "action": ""}
