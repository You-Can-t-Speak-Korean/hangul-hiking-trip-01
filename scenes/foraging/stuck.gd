extends RefCounted
## Can the scene still be finished? No nodes, so tests can feed it any state.
## It tries the moves the player has, with the real Spares rules (the same
## deficit and credit decisions, run on forks of the live Spares): complete an
## unfinished word with letters from the pool, which earns a credit that is
## banked or spent on a spare at once; or, when credits are banked, fail a
## syllable on purpose (it destroys two letters and spends credits on spares).
## "Stuck" means no sequence of those moves finishes every word.
##
## Failing on purpose cannot help in any state the game reaches: the pool never
## holds more of a jamo than the unfinished words need, and a banked credit never
## coexists with a shortage (a failure spends banked credits while one is left).
## There every failure destroys needed letters and a spare replaces at most one
## per credit. It can help in states the game never reaches (three banked credits
## and one letter short: destroy two letters, cover all three), so the search
## includes it; `failures` = "none" gives the completions-only verdict that
## tests compare against.

## Nodes the search may visit before it gives up and calls the scene not stuck,
## so a bad guess can never start a countdown.
const BUDGET := 20000


## `spares` is the live Spares (never changed), `solved` maps a word id to its
## judged blocks, `pool` is every jamo the player can still get (the basket, the
## letters on target plants and spares, the letters in the open block; decoys
## never count). `failures` is which deliberate failures the search may use:
## "none" (completions only), "useful" (only while a credit is banked: with none a
## failure only destroys letters) or "all". Returns {"stuck", "reason", "plan"}:
## `plan` lists the moves of one way through when there is one.
static func analyze(spares, solved: Dictionary, pool: Array, failures: String = "useful") -> Dictionary:
	var open := _unfinished(spares, solved)
	if open.is_empty():
		return {"stuck": false, "reason": "no unfinished word", "plan": []}
	var ctx := {"nodes": 0, "dead": {}, "failures": failures}
	var plan = _search(spares, solved, pool, ctx)
	if plan != null:
		return {"stuck": false, "reason": "can finish: " + ", ".join(plan), "plan": plan}
	if int(ctx["nodes"]) > BUDGET:
		return {"stuck": false, "reason": "search budget exceeded, assumed not stuck", "plan": []}
	var short: Dictionary = spares.choose(solved, pool)
	return {"stuck": true, "reason": "cannot finish %s: %s" % [", ".join(open), short["reason"]], "plan": []}


## The moves from a state, each {"label", "spares", "solved", "pool"} with the state
## after it: complete an unfinished word the pool can spell, or (see `failures`)
## fail a syllable with two letters of the pool.
static func moves(spares, solved: Dictionary, pool: Array, failures: String = "useful") -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in _unfinished(spares, solved):
		var need: Array[String] = spares.jamo_left(id, int(solved.get(id, 0)))
		if not _holds(pool, need):
			continue
		var fork = spares.fork()
		var after := solved.duplicate()
		after[id] = spares.block_count(id)
		var left := _minus(pool, need)
		fork.queue(id)
		_add_spawns(fork.settle(after, left), left)
		out.append({"label": id, "spares": fork, "solved": after, "pool": left})
	if failures == "none" or _unfinished(spares, solved).is_empty() or (failures == "useful" and spares.credits.is_empty()):
		return out
	var letters: Array = []
	for letter in pool:
		if not letters.has(letter):
			letters.append(letter)
	for i in letters.size():
		for j in range(i, letters.size()):
			var pair: Array[String] = [letters[i], letters[j]]
			if not _holds(pool, pair):
				continue
			var fork = spares.fork()
			var left := _minus(pool, pair)
			fork.queue_failure()
			_add_spawns(fork.settle(solved, left), left)
			out.append({"label": "fail %s+%s" % pair, "spares": fork, "solved": solved, "pool": left})
	return out


static func _unfinished(spares, solved: Dictionary) -> Array[String]:
	var open: Array[String] = []
	for id in spares.word_ids():
		if int(solved.get(id, 0)) < spares.block_count(id):
			open.append(id)
	return open


## A list of moves that finishes every word, or null.
static func _search(spares, solved: Dictionary, pool: Array, ctx: Dictionary):
	var open := _unfinished(spares, solved)
	if open.is_empty():
		return []
	if spares.choose(solved, pool)["letter"] == "":  # nothing short: any order works
		return open
	ctx["nodes"] += 1
	if int(ctx["nodes"]) > BUDGET:
		return null
	var key := state_key(spares, solved, pool)
	if ctx["dead"].has(key):
		return null
	for move in moves(spares, solved, pool, ctx["failures"]):
		var rest = _search(move["spares"], move["solved"], move["pool"], ctx)
		if rest != null:
			return [move["label"]] + rest
	ctx["dead"][key] = true
	return null


static func _add_spawns(orders: Array[Dictionary], pool: Array) -> void:
	for order in orders:
		pool.append(order["letter"])


static func state_key(spares, solved: Dictionary, pool: Array) -> String:
	var sorted_pool := pool.duplicate()
	sorted_pool.sort()
	var done := []
	for id in spares.word_ids():
		done.append("%s=%d" % [id, int(solved.get(id, 0))])
	return "%s|%s|%s|%d" % [",".join(done), "".join(sorted_pool), ",".join(spares.credits), spares.spawned.size()]


## True if `pool` holds every letter of `need`, repeats counted.
static func _holds(pool: Array, need: Array) -> bool:
	var counts := {}
	for letter in pool:
		counts[letter] = int(counts.get(letter, 0)) + 1
	for letter in need:
		if int(counts.get(letter, 0)) <= 0:
			return false
		counts[letter] = int(counts[letter]) - 1
	return true


static func _minus(pool: Array, gone: Array) -> Array:
	var left := pool.duplicate()
	for letter in gone:
		left.erase(letter)  # one copy
	return left
