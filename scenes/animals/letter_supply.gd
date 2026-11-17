extends RefCounted
## Which jamo each new animal carries, with no nodes (data: animals.letters). Seeded: one seed
## gives one sequence of letters for one sequence of spawns and missing sets.
##
## A draw is weighted toward the letters still missing for the needs shown so far
## (`missing`: letter -> how many more, from Needs.missing_letters). Before any need is
## shown (nothing missing) the weights are the letters of the review words of the map's
## kinds. Guarantee: while anything is missing, at least one in every `every` ground
## spawns (those a hand can grab) carries a missing letter. A letter that leaves with its
## animal is simply drawn again later: nothing is ever used up.

var letters: Array[String] = []
var every := 3
var boost := 6.0
var base_weight := 1.0
var rng := RandomNumberGenerator.new()
## Letter -> weight before any need is shown.
var review: Dictionary = {}
## Ground spawns in a row, while something was missing, that carried no missing letter.
var streak := 0


## `config` is animals.letters; `review_weights` is review_weights() of the map's kinds.
func _init(config: Dictionary, seed_value: int, review_weights: Dictionary) -> void:
	for letter in config["set"]:
		letters.append(String(letter))
	every = maxi(int(config["guarantee_every"]), 1)
	boost = float(config["missing_boost"])
	base_weight = float(config["base_weight"])
	review = review_weights
	rng.seed = seed_value


## How often each jamo of `letter_set` appears in the review words among the kinds' names
## (a review word uses only letters in `known`).
static func review_weights(kinds: Array, known: Array, letter_set: Array) -> Dictionary:
	var weights := {}
	for kind in kinds:
		var name_ko := String(kind["name_ko"])
		if not Hangul.is_readable(name_ko, known):
			continue
		for tile in Hangul.tiles_for(name_ko):
			if letter_set.has(tile):
				weights[tile] = float(weights.get(tile, 0.0)) + 1.0
	return weights


## The letter for the next spawn. `ground` is true if a hand can grab this animal.
func draw(ground: bool, missing: Dictionary) -> String:
	var lacking: Array[String] = []
	for letter in letters:
		if int(missing.get(letter, 0)) > 0:
			lacking.append(letter)
	if lacking.is_empty():
		if ground:
			streak = 0
		return _pick(letters, func(l: String) -> float: return float(review.get(l, 0.0)))
	if ground and streak >= every - 1:  # the guarantee: this one carries a missing letter
		streak = 0
		return _pick(lacking, func(l: String) -> float: return float(missing[l]))
	var pick := _pick(letters, func(l: String) -> float: return base_weight + boost * float(missing.get(l, 0)))
	if ground:
		streak = 0 if lacking.has(pick) else streak + 1
	return pick


## A weighted pick from `from` (uniform if every weight is 0).
func _pick(from: Array[String], weight: Callable) -> String:
	var weights := PackedFloat32Array()
	var sum := 0.0
	for letter in from:
		var w := maxf(float(weight.call(letter)), 0.0)
		weights.append(w)
		sum += w
	if sum <= 0.0:
		return from[rng.randi_range(0, from.size() - 1)]
	return from[rng.rand_weighted(weights)]
