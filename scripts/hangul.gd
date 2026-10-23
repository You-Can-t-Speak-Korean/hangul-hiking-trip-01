extends Node
## Hangul engine. Composes letters (jamo) into syllable blocks and checks
## which words a player can read with the letters taught so far.
##
## Letter tokens used everywhere in the data files:
##   "ㄱ"  = consonant in the initial position (or any vowel)
##   "-ㄱ" = consonant as 받침 (final). Finals are taught separately (월악산).

const SYLLABLE_BASE := 0xAC00
const SYLLABLE_LAST := 0xD7A3

const INITIALS: Array[String] = [
	"ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
	"ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
]
const MEDIALS: Array[String] = [
	"ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ",
	"ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ",
]
const FINALS: Array[String] = [
	"", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ",
	"ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ",
	"ㅋ", "ㅌ", "ㅍ", "ㅎ",
]

## Vowels written to the right of the consonant (block is side-by-side).
const VERTICAL_VOWELS := ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅣ"]
## Vowels written under the consonant (block is stacked).
const HORIZONTAL_VOWELS := ["ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ"]
## The rest (ㅘ ㅙ ㅚ ㅝ ㅞ ㅟ ㅢ) wrap under and to the right.


func is_vowel(jamo: String) -> bool:
	return MEDIALS.has(jamo)


func is_consonant(jamo: String) -> bool:
	return INITIALS.has(jamo) or (jamo != "" and FINALS.has(jamo))


func vowel_shape(vowel: String) -> String:
	if VERTICAL_VOWELS.has(vowel):
		return "vertical"
	if HORIZONTAL_VOWELS.has(vowel):
		return "horizontal"
	return "mixed"


func is_syllable(ch: String) -> bool:
	if ch.length() != 1:
		return false
	var code := ch.unicode_at(0)
	return code >= SYLLABLE_BASE and code <= SYLLABLE_LAST


## Builds one syllable block. Returns "" if the parts can't form a block.
func compose(initial: String, medial: String, final: String = "") -> String:
	var i := INITIALS.find(initial)
	var m := MEDIALS.find(medial)
	var f := FINALS.find(final)
	if i < 0 or m < 0 or f < 0:
		return ""
	return String.chr(SYLLABLE_BASE + (i * 21 + m) * 28 + f)


## Splits a syllable into [initial, medial, final]. final is "" if none.
func decompose(syllable: String) -> Array[String]:
	if not is_syllable(syllable):
		return []
	var index := syllable.unicode_at(0) - SYLLABLE_BASE
	var result: Array[String] = [
		INITIALS[index / 588],
		MEDIALS[(index % 588) / 28],
		FINALS[index % 28],
	]
	return result


## The curriculum tokens a word needs, in reading order (duplicates kept).
func tokens_of(word: String) -> Array[String]:
	var tokens: Array[String] = []
	for ch in word:
		var parts := decompose(ch)
		if parts.is_empty():
			continue
		tokens.append(parts[0])
		tokens.append(parts[1])
		if parts[2] != "":
			tokens.append("-" + parts[2])
	return tokens


## Unique tokens a word needs.
func letters_needed(word: String) -> Array[String]:
	var unique: Array[String] = []
	for t in tokens_of(word):
		if not unique.has(t):
			unique.append(t)
	return unique


## Tokens a word needs that are not in `known`.
func unknown_letters(word: String, known: Array) -> Array[String]:
	var missing: Array[String] = []
	for t in letters_needed(word):
		if not known.has(t):
			missing.append(t)
	return missing


## True if every letter in `word` has been taught: a review word.
## False means it's a bonus guess.
func is_readable(word: String, known: Array) -> bool:
	return unknown_letters(word, known).is_empty()


## The plain letters (no "-" prefix) a word is built from, for tile trays.
func tiles_for(word: String) -> Array[String]:
	var tiles: Array[String] = []
	for t in tokens_of(word):
		tiles.append(t.trim_prefix("-"))
	return tiles
