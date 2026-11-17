extends RefCounted
## The animals' needs, with no nodes (data: animals.needs, animals.watch). Watching an animal
## long enough shows one of its kind's needs: a word to spell or an item to hand over. A
## need joins the discovery list (this object has the same `entries` and `opacity()` as
## the foraging Discovery, so DiscoveryHud draws it) with empty syllable blocks and an
## English hint that shows, flickers and is then gone for good (`hint_alpha()`).
##
## Needs are distinct words or items for the whole run; at most `total` are shown. An item
## need is only drawn if `has_item` says the backpack holds the item. One animal shows one
## need at most. `mark_done()` tells when the last of the `total` was finished, once.

const WORD := "word"
const ITEM := "item"
const EPSILON := 0.0001  # seconds: float sums of small steps may fall just short

var total := 6
var radius := 8.0
var seconds := 3.0
var fade_time := 0.1
var hint_show := 0.6
var hint_flicker := 0.4
var hint_rate := 10.0
## Kind id -> [{"word", "en"} or {"item"}], in data order.
var table: Dictionary = {}
## The discovered needs in order: {"id", "hover_name" (always ""), "hint" (the English), "name_ko",
## "syllables", "age", "kind", "item", "from_kind" (the animal kind it was shown by), "walker"
## (the animal's id, once watch() has shown it)}.
var entries: Array[Dictionary] = []
## The ids of the needs that are finished.
var done: Dictionary = {}
var rng := RandomNumberGenerator.new()
## Called with an item id: true if the backpack holds one.
var has_item: Callable

var _drawn: Dictionary = {}     # need id -> true
var _progress: Dictionary = {}  # walker id -> {traveler index -> seconds in range}
var _watched: Dictionary = {}   # walker ids that have shown their need
var _complete_sent := false


## `animals` is the animals section of the data; `seed_value` fixes the draws.
func _init(animals: Dictionary, seed_value: int, has_item_fn: Callable) -> void:
	var needs: Dictionary = animals["needs"]
	total = int(needs["needs_total"])
	fade_time = float(needs["fade_time"])
	hint_show = float(needs["hint"]["show_s"])
	hint_flicker = float(needs["hint"]["flicker_s"])
	hint_rate = float(needs["hint"]["flicker_rate"])
	table = needs["table"]
	radius = float(animals["watch"]["radius"])
	seconds = float(animals["watch"]["seconds"])
	rng.seed = seed_value
	has_item = has_item_fn


## The id a table row goes by: the Korean word, or the item id.
static func need_id(row: Dictionary) -> String:
	return String(row["word"]) if row.has("word") else String(row["item"])


## The rows of `kind_id` that could be drawn now: not drawn yet, and an item row only
## while the backpack holds the item. Empty once `total` needs are shown.
func eligible(kind_id: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	if entries.size() >= total:
		return rows
	for row in table.get(kind_id, []):
		if _drawn.has(need_id(row)):
			continue
		if row.has("item") and not has_item.call(String(row["item"])):
			continue
		rows.append(row)
	return rows


## Shows one random eligible need of the kind: its new entry, or {} if there is none.
func discover(kind_id: String) -> Dictionary:
	var rows := eligible(kind_id)
	if rows.is_empty():
		return {}
	var row: Dictionary = rows[rng.randi_range(0, rows.size() - 1)]
	var id := need_id(row)
	var entry := {"id": id, "age": 0.0, "kind": WORD, "item": "", "hover_name": "", "from_kind": kind_id, "walker": 0}
	if row.has("word"):
		entry["hint"] = String(row["en"])
		entry["name_ko"] = String(row["word"])
	else:
		var item: Dictionary = Content.item(id)
		entry["hint"] = String(item["name_en"])
		entry["name_ko"] = String(item["name_ko"])
		entry["kind"] = ITEM
		entry["item"] = id
	entry["syllables"] = Hangul.syllable_count(entry["name_ko"])
	_drawn[id] = true
	entries.append(entry)
	return entry


func is_item(id: String) -> bool:
	for entry in entries:
		if entry["id"] == id:
			return entry["kind"] == ITEM
	return false


func entry_of(id: String) -> Dictionary:
	for entry in entries:
		if entry["id"] == id:
			return entry
	return {}


## One tick of watching. `travelers` are the travelers' (x, z); `animals` are
## {"id", "kind", "spot"} for every animal on the map. A traveler within `radius` of an
## animal for `seconds` (the clock restarts when it steps out) makes that animal show a
## need of its kind. Returns the entries shown this tick.
func watch(travelers: Array, animals: Array, delta: float) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	var live := {}
	for a in animals:
		var id: int = a["id"]
		live[id] = true
		if _watched.has(id) or eligible(String(a["kind"])).is_empty():
			_progress.erase(id)
			continue
		var clocks: Dictionary = _progress.get(id, {})
		var ready := false
		for i in travelers.size():
			if (travelers[i] as Vector2).distance_to(a["spot"]) <= radius:
				clocks[i] = float(clocks.get(i, 0.0)) + delta
				ready = ready or float(clocks[i]) >= seconds - EPSILON
			else:
				clocks.erase(i)
		_progress[id] = clocks
		if ready:
			_watched[id] = true
			_progress.erase(id)
			var entry := discover(String(a["kind"]))
			if not entry.is_empty():
				entry["walker"] = id
				found.append(entry)
	for id in _progress.keys():
		if not live.has(id):
			_progress.erase(id)
	return found


## 0..1: the best watch clock on an animal, over `seconds`.
func progress_of(walker_id: int) -> float:
	var best := 0.0
	for t in (_progress.get(walker_id, {}) as Dictionary).values():
		best = maxf(best, float(t))
	return clampf(best / maxf(seconds, 0.001), 0.0, 1.0)


## Ages every entry (they fade in, and their hints run out).
func update(delta: float) -> void:
	for entry in entries:
		entry["age"] += delta


## 0..1: how far an entry has faded in (as Discovery.opacity).
func opacity(entry: Dictionary) -> float:
	return clampf(float(entry["age"]) / maxf(fade_time, 0.001), 0.0, 1.0)


## The English hint's opacity: solid for hint_show seconds, then flickering (it starts
## hidden) for hint_flicker seconds at hint_rate changes per second, then 0 for good.
func hint_alpha(entry: Dictionary) -> float:
	var age := float(entry["age"])
	if age <= hint_show:
		return 1.0
	var flicker := age - hint_show
	if flicker < hint_flicker:
		return 1.0 if int(flicker * hint_rate) % 2 == 1 else 0.0
	return 0.0


## "met/total", the counter the scene always shows.
func counter_text() -> String:
	return "%d/%d" % [done.size(), total]


## The need is finished. True exactly once: when this finishes the `total`-th need.
func mark_done(id: String) -> bool:
	if not _drawn.has(id) or done.has(id):
		return false
	done[id] = true
	if done.size() >= total and not _complete_sent:
		_complete_sent = true
		return true
	return false


## The jamo the unfinished word needs still lack: letter -> how many more, over every shown
## word need not done (its blocks not yet judged correct), less what the basket holds.
## `spelling` is the Spelling that holds the words.
func missing_letters(spelling, basket: Array) -> Dictionary:
	var wanted := {}
	for entry in entries:
		var id: String = entry["id"]
		if entry["kind"] != WORD or not spelling.has_word(id) or spelling.is_done(id):
			continue
		for block in range(spelling.solved(id).size(), spelling.block_count(id)):
			for letter in Hangul.decompose(spelling.target_syllable(id, block)):
				if letter != "":
					wanted[letter] = int(wanted.get(letter, 0)) + 1
	for letter in basket:
		if wanted.has(letter):
			wanted[letter] = int(wanted[letter]) - 1
	for letter in wanted.keys():
		if int(wanted[letter]) <= 0:
			wanted.erase(letter)
	return wanted
