# Hangul Hiking Trip — Phase 0 Project Log B

*23 October 2026 · Covers sessions from 22 Oct (evening) to 23 Oct 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log A (22 Oct)*

> **Read this first in every new session.** Read this log, then Log A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED

---

## 0. Summary

- The **series bible**, **curriculum map** and **scene templates** were worked through at *Hallasan* depth.
- The **scoring & damage spec** is mostly settled; injury persistence is still open.
- **Controls changed:** WASD walking, split-screen local co-op.
- Points are named **DDEOK**.
- **Next:** switch to DEV mode and build a gray-box of the **foraging scene**.

---

## 1. Changes to Log A

| Log A item | Was | Now | Status |
|---|---|---|---|
| 3.1 #4 Phone release | Only as the complete collection after *Baekdusan* | A phone version **might** happen; if so, it's worked out when that build starts | ❓ |
| 3.5 #2 Local co-op | Local co-op | Local co-op is **split screen** | ✅ |
| 3.5 #3 Controls | Mouse click on PC, touch on phone | PC: **WASD to walk, mouse to pick and drag** (see §5) | ✅ |
| 3.6 #9 Point values | Open | Placeholder numbers, tuned in playtesting | ✅ |
| 5 #3 *Hallasan* opening | Hotel key at the summit (example) | **Settled** | ✅ |
| 5 #6 *Hallasan* letters | 11 letters including ㅡ | **10 letters**; ㅡ moves to *Jirisan* (see §3) | ✅ |
| 5 #9 Dish | 고사리육개장 | **Replaced.** Too far beyond *Hallasan*'s letters. New dish open | ❓ |
| 2 Documents | — | `claude/hht-project-log-001.md` is still in the Project, superseded. Delete when convenient | ❓ |

---

## 2. Series bible (at *Hallasan* depth)

| # | Decision | Status |
|---|---|---|
| 1 | Nestor and Fernanda are **backpackers in their 20s** | ✅ |
| 2 | They are **coworkers** | ✅ |
| 3 | They're in Korea on **vacation** | ✅ |
| 4 | They might become lovers later in the series | ✅ |
| 5 | Romance shown as **awkward moments only**. Nothing explicit | ✅ |
| 6 | A kiss on top of 백두산, maybe | ❓ |
| 7 | Why they hike each mountain: brainstormed, but **decided in each game's own sessions**. *Hallasan* is settled (the hotel key) | ✅ |
| 8 | Recurring cast: only the protagonists, maybe | ❓ |
| 9 | **괴물 are creatures, not characters.** They have no personality; what matters is how they look and behave on screen. Details later | ✅ |
| 10 | Possible recurring engines: Nestor's excuses backfire and create the reason to hike; each hike caused by a Korean word they couldn't read yet | 🟡 |

**Note on the content rule:** the project instructions say "no sexual content of any kind, in any game." The user has allowed awkward romantic moments between Nestor and Fernanda, nothing explicit. Updating the project instructions to say so would stop future sessions flagging it.

**Brainstormed reasons to hike (none decided):** 지리산 passport in a 등산 아저씨's backpack · 소백산 fox steals Fernanda's phone · 월악산 산양 mistaken for a lost dog · 태백산 swept up by the New Year sunrise crowd · 설악산 Nestor loses a 화투 bet, must carry a 할머니's 막걸리 · 금강산 festival balloon drifts across the DMZ · 구월산 the minder insists · 묘향산 Fernanda's suitcase displayed as a dignitary's gift 🔍 · 칠보산 squid-eating contest prize · 관모봉 Nestor's stove-left-on excuse backfires · 백두산 they choose to climb, then Fernanda forgets something.

---

## 3. Curriculum map (at *Hallasan* depth)

### Letters
| Game | Letters | Status |
|---|---|---|
| *Hallasan* | **ㅏ ㅓ ㅗ ㅜ ㅣ · ㄱ ㄴ ㄹ ㅁ · silent ㅇ** (10) | ✅ |
| *Jirisan* | **ㅡ** ㄷ ㅂ ㅅ ㅈ ㅎ | ✅ (ㅡ moved here) |

Why ㅡ moved: with *Hallasan*'s letters and no 받침, ㅡ appears in almost no useful nouns. With ㅅ and ㄷ it comes alive (스, 드, 드라마).

### Letters by scene 🟡
| Scene | New letters | Carried by |
|---|---|---|
| Foraging | ㅁ ㄹ ㄴ · ㅏ ㅓ ㅜ ㅣ | 머루, 미나리, 나무 |
| Animal sightseeing | ㅗ ㄱ, silent ㅇ | 노루, 오리, 거미, 모기 |
| Eruption | None (review + bonus) | 머리, 이마, 이 + bonus words |
| Camp cooking | None | Foraged plant names |

**Readable words (about 20) 🟡:** 머루 · 미나리 · 나무 · 노루 · 오리 · 거미 · 모기 · 머리 · 이마 · 이 (tooth) · 아이 · 오이 · 고기 · 고구마 · 어머니 · 누나 · 이모 · 우리 · 나이 · 거리 · 고리 · 구리

### Rules
| # | Decision | Status |
|---|---|---|
| 1 | **Sound:** tapping a tile plays its sound; a finished block says its syllable; a correct word is spoken | ✅ |
| 2 | **The user records the audio** | ✅ |
| 3 | **Romanization:** an option in settings | ✅ |
| 4 | Romanization **off** by default | 🟡 |
| 5 | Romanization system: Revised Romanization (머루 → "meoru") | 🟡 |
| 6 | **English subtitles:** an option in settings, **off by default** | ✅ |
| 7 | **Bonus words have at most 1–2 unknown letters**, so players can guess by elimination | ✅ |

### Recording list for *Hallasan* 🟡 (about 75 clips)
- **5 vowels:** 아, 어, 오, 우, 이
- **4 consonants**, with the neutral 으 vowel (consonants can't be said alone): 그, 느, 르, 므. Silent ㅇ plays nothing.
- **25 open syllables:** every block a player can build (가, 거, 고 … 미)
- **Bonus-word syllables** actually used (e.g. 물, 불, 돌, 용, 암, 화, 산, 사, 상, 시, 로)
- **About 30 whole words**

---

## 4. Scene templates (at *Hallasan* depth)

### 4.1 Foraging
| # | Rule | Status |
|---|---|---|
| 1 | A **small map to explore** | ✅ |
| 2 | The traveler walks with **WASD**; letters are **picked with mouse clicks** | ✅ |
| 3 | Clicking a letter makes the traveler **walk to the spot** and collect it into a traditional basket | ✅ |
| 4 | Basket: a 망태기 (woven forager's bag) or a 소쿠리 | 🟡 |
| 5 | Letters sit **still**, in or with the pickable plants and fruits | ✅ |
| 6 | **Hovering** over a target plant shows its **English name** as a clue | ✅ |
| 7 | **Decoy plants** show **"???"** on hover. Some cost a heart; some give a surprise reward | ✅ |
| 8 | Letters are **dragged from the basket** onto the word spot | ✅ |
| 9 | Words are built **syllable by syllable**: 고, then 사, then 리 → 고사리 is foraged | ✅ |
| 10 | Each real syllable is spoken as it forms | ✅ (from §3) |
| 11 | A letter that doesn't fit is **rejected and gouges** the traveler | ✅ |
| 12 | Only *impossible* combinations are rejected (two consonants stacked, two vowels, no slot left). Any real syllable, even one not in a plant name, is spoken and costs nothing | 🟡 |
| 13 | **No timer** | ✅ |
| 14 | Other injuries: branch to the eye or ear with blood spurting; thorns flaying a hand; slipping on wet basalt (skull cracks, or a tooth flies out: 이); poison done gory (face swells and pops) | 🟡 |
| 15 | Phones (if ever): long-press instead of hover | 🟡 |

### 4.2 Animal sightseeing
| # | Rule | Status |
|---|---|---|
| 1 | Letters **ride on animals** as they graze, hunt, leap through trees | ✅ |
| 2 | Animals move **on and off screen**, visible for about **15 seconds** | ✅ |
| 3 | Caught letters go into the basket, then are dragged into words | 🟡 |
| 4 | Damage | ❓ Placeholder; brainstorm later |

### 4.3 Eruption
| # | Rule | Status |
|---|---|---|
| 1 | Letters ride on **lava spurts, fire rocks, blazing tree branches, blazing milk cartons**, etc. | ✅ |
| 2 | The player **clicks the flying letters** to spell the word (no drag-and-drop) | ✅ |
| 3 | Much **shorter time** than the other scenes | ✅ |
| 4 | Letters must be clicked **in spelling order** | ✅ |
| 5 | A correct letter clicked out of order counts as wrong | 🟡 |
| 6 | There are **right and wrong letters** | ✅ |
| 7 | Wrong letters **left alone** hit the ground and explode, or tumble off screen, **harmlessly** | ✅ |
| 8 | **Clicking a wrong letter** → that object pummels the traveler | ✅ |
| 9 | **Timer runs out** → the **closest object** hits the traveler | ✅ |

### 4.4 Camp cooking
| # | Rule | Status |
|---|---|---|
| 1 | **Traditional recipes or new, invented ones**, from combinations of the real plants foraged | ✅ |
| 2 | Use the plants actually foraged where possible | ✅ |
| 3 | If an ingredient is nearly impossible to forage, it turns up in the **backpack with an absurd story**. Tone example: *"Oh, 파래. That dude at the market gave it to me as collateral so he could borrow my pencil but... he never gave it back. Let's use it."* | ✅ |
| 4 | **No timer** | ✅ |
| 5 | Penalty for a wrong combination: **a pack of wolves** rips off a traveler's leg from the knee down and runs off with it | ✅ |
| 6 | Other penalties: stove explosion; food poisoning (face swells and pops) | 🟡 |
| 7 | Skill: reading. The dish name is shown and spoken; the player reads foraged words and drags the right ones into the pot | 🟡 |
| 8 | Setting: an illegal camp at the base; Nestor explains why it doesn't count | 🟡 🔍 |
| 9 | The *Hallasan* dish | ❓ |

🔍 Wolves are extinct in South Korea and may never have lived on Jeju. Funny either way; verify for the 도감 text.

---

## 5. Controls & co-op

| # | Decision | Status |
|---|---|---|
| 1 | **Building the PC version now** | ✅ |
| 2 | Player 1: **WASD** to walk; **mouse** to pick, drag and click | ✅ |
| 3 | Player 2: **arrow keys** to walk; a nearby key to pick (**numpad 0** or **right Ctrl**) | ✅ |
| 4 | Local co-op is **split screen** | ✅ |
| 5 | Controller support | ❓ Future |
| 6 | Phones: on-screen joystick, if a phone version happens | ✅ |

❓ Still to design: how player 2 drags letters into words without a mouse (e.g. select with arrow keys, confirm with the pick key).

---

## 6. Scoring, rewards & damage

| # | Decision | Status |
|---|---|---|
| 1 | Points are called **DDEOK** | ✅ |
| 2 | Whether DDEOK goes on-chain (Sui) | ❓ STRATEGY mode |
| 3 | Point values: **placeholder numbers, tuned in playtesting** | ✅ |
| 4 | Reward: **slow-time charm** | ✅ |
| 5 | Reward: **spelling hint** — a greyed-out, flickering letter on the right spelling spot for **2 seconds** | ✅ |
| 6 | Other reward ideas: a 도감 entry (collectible plant and animal encyclopedia), a shield that absorbs one hit, a 30-second romanization "hallucination," a cosmetic | 🟡 |
| 7 | Random NFTs as prizes | ❓ Later, STRATEGY mode |
| 8 | Hearts still don't refill: rewards never give a heart back (Log A 3.6 #2 stands) | ✅ |
| 9 | **Injury persistence** | ❓ See below |
| 10 | Animal-scene damage | ❓ Placeholder |

**Injury persistence — options to weigh:**
- **A.** Injuries persist within a game (lose a leg in *Hallasan*, hop for the rest of it) and reset in the next game.
- **B.** Physical injuries never persist; limbs reappear after each hit. Only heart losses persist. A player can lose many limbs, one per heart.

**Sui / blockchain flags (for STRATEGY mode):**
- 🔍 Steam's rules prohibit games that issue or allow exchange of cryptocurrencies or NFTs (since 2021, to verify). Check other storefronts too.
- Wallets are friction for absolute beginners.
- Tokens raise legal and tax questions → a lawyer.
- The Sui Foundation grant: check current programs and terms.

---

## 7. Phase 1 status, at *Hallasan* depth

| # | Item | Status | Next |
|---|---|---|---|
| 1 | Series bible | Decided in chat (§2) | Write up later |
| 2 | Curriculum map | Decided for *Hallasan* (§3) | Recording list |
| 3 | Mountain bible | Not started | Hallasan research |
| 4 | Scene templates | Foraging, eruption, cooking decided; animals partly (§4) | Animal damage |
| 5 | Scoring & damage spec | Mostly decided (§6) | Injury persistence |
| 6 | Gore style guide | Ideas only | After the style test |
| 7 | Art, audio & UI style guides | Art direction decided | Style test |
| 8 | Tech decisions | Controls and co-op decided (§5) | Player 2 drag input |
| 9 | Licensing | Code done | Asset licence |

---

## 8. Open questions

1. Injury persistence: option A or B (§6).
2. The *Hallasan* dish.
3. Animal-scene damage.
4. Player 2's drag input in co-op.
5. A kiss on 백두산.
6. Recurring cast beyond the protagonists.
7. Whether DDEOK goes on-chain; NFT prizes; the Sui grant (STRATEGY mode).
8. Phone version: whether it happens.
9. Controller support.
10. Delete `claude/hht-project-log-001.md` from the Project.
11. Carried from Log A: asset licence, AI partner behaviour, Fernanda's forgetfulness as a mechanic, online co-op, standalone vs cumulative curriculum, gore for animals, release cadence, Mixamo licence, Blender MCP, artist collaborator, hosting and donations, localization order, team roles, crossover with Noraebang Night.

---

## 9. Next steps

1. **Switch to DEV mode.** Build a **gray-box of the foraging scene**:
   - WASD walking on a small map
   - Target plants with English hover names; decoys with "???"
   - Click a letter → the traveler walks over and picks it into the basket
   - Drag letters from the basket to build syllables, one at a time
   - Impossible combinations rejected, with a placeholder gouge and a heart lost
   - Placeholder art and audio
2. Before the prompt: the user says what's in the repo now (believed to be only the AGPL-3.0 licence).
3. ❓ Whether Claude's exploratory code (Hangul engine, game state, carry-over code) goes into the Claude Code prompt as a reference.
4. **In parallel:** the art style test in live 2.5D (Blender work on the user's side).
5. Record the audio clips once the *Hallasan* recording list is final.
