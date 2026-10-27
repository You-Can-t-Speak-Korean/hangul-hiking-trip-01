extends RefCounted
## Spare plants, with no nodes. Completing a word queues one spare of that
## word's kind; when the spelling view has closed the map settles the queue.
## Each spare carries the jamo the unfinished words are most short of, or is not
## spawned at all if no jamo is short. A word queues once, and at most `cap`
## spares are spawned in all. A new Spares (a scene restart) has none.

## Data: foraging.spares.
var cap := 6
var grow_seconds := 0.5
## Word (target kind) id -> where its spare appears, as (x, z).
var slots: Dictionary = {}
## The spares spawned so far: {"word_id", "letter", "spot"}, in spawn order.
var spawned: Array[Dictionary] = []
## Every settled word, in order: {"word_id", "spawn", "letter", "reason", "deficit"}.
var decisions: Array[Dictionary] = []

var _words: Array[Dictionary] = []  # target kinds in data order: {"id", "name"}
var _queued: Array[String] = []
var _seen := {}  # word id -> true, once queued


## `config` is foraging.spares, `plants_data` is foraging.plants.
func _init(config: Dictionary, plants_data: Dictionary) -> void:
	cap = int(config["cap"])
	grow_seconds = float(config["grow_seconds"])
	for id in config["slots"]:
		slots[id] = Vector2(float(config["slots"][id][0]), float(config["slots"][id][1]))
	for kind in plants_data["kinds"]:
		if kind["kind"] == "target":
			_words.append({"id": String(kind["id"]), "name": String(kind["name"])})


## Notes a completed word. False if it was queued before (or is not a word).
func queue(word_id: String) -> bool:
	if _seen.has(word_id) or not slots.has(word_id):
		return false
	_seen[word_id] = true
	_queued.append(word_id)
	return true


func has_pending() -> bool:
	return not _queued.is_empty()


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
		var blocks := Hangul.syllable_count(word["name"])
		for block in range(int(solved.get(word["id"], 0)), blocks):
			for part in Hangul.decompose(word["name"][block]):
				if part != "":
					jamo.append(part)
	return jamo


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


## Settles the queued words, in the order they completed. Returns what to
## spawn: {"word_id", "letter", "spot"} per spare. Each spawn counts as
## available for the words settled after it.
func settle(solved: Dictionary, available: Array) -> Array[Dictionary]:
	var orders: Array[Dictionary] = []
	var pool := available.duplicate()
	for word_id in _queued:
		var decision := {"word_id": word_id, "spawn": false, "letter": "", "reason": "", "deficit": 0}
		if spawned.size() >= cap:
			decision["reason"] = "cap reached"
		else:
			var choice := choose(solved, pool)
			decision["letter"] = choice["letter"]
			decision["reason"] = choice["reason"]
			decision["deficit"] = choice["deficit"]
			if choice["letter"] != "":
				decision["spawn"] = true
				pool.append(choice["letter"])
				var order := {"word_id": word_id, "letter": choice["letter"], "spot": slots[word_id]}
				spawned.append(order)
				orders.append(order)
		decisions.append(decision)
	_queued.clear()
	return orders
