# Hangul Hiking Trip: Hallasan — Game Roadmap

*Version 0.1 · Drafted 21 October 2026*
*Parent document: Hangul Hiking Trip — Master Roadmap*
*Dev team: 니가 한국어 못해 (NHMH)*

> **How to read this document**
> - ✅ **DECIDED** — locked in.
> - 🟡 **SUGGESTED** — first ideas, to be decided in session.
> - ❓ **OPEN** — needs a decision.
> - 🔍 **VERIFY** — factual detail to confirm during research.
>
> **Document rules**
> - This roadmap is the record of the original plan for *Hangul Hiking Trip: Hallasan*. **It is never modified.**
> - What is actually built, and every change from this plan, is recorded in the **project logs**, which also carry context between sessions.

---

## 0. Decision Log

| # | Decision | Status |
|---|---|---|
| 1 | *Hallasan* is game 1 of 12 and the series pilot | ✅ |
| 2 | Protagonists: **Nestor** and **Fernanda** | ✅ |
| 3 | Solo players **choose** which traveler to control; the other is the AI partner | ✅ |
| 4 | Two-player: local co-op | ✅ |
| 5 | Scenes: **foraging, animal sightseeing, volcano eruption survival, camp cooking** | ✅ |
| 6 | 괴물: the **white deer of 백록담** | ✅ |
| 7 | **5 hearts** each, full only at the start of the hike | ✅ |
| 8 | If one traveler dies, both die: the dead one dies gorily, then a monster eats the survivor | ✅ |
| 9 | Death **restarts the current scene**, with the hearts the travelers had at the start of that scene | ✅ |
| 10 | Cooking earns **points**, spent like money on gear in later games | ✅ |
| 11 | No street market in *Hallasan*; markets begin in *Jirisan* | ✅ |
| 12 | Points carry over to the next game (shared save folder on PC, carry-over code as fallback) | ✅ / ❓ format |
| 13 | **PC standalone release**; phone only in the complete collection after *Baekdusan* | ✅ |
| 14 | Engine: Godot. Released independently, unrated, open source, free with donations to NHMH | ✅ (from Master) |
| 15 | Gore only to the travelers, never to animals or plants | ✅ (from Master) |

---

## 1. Game Overview

### Pitch
Locked out of their Jeju hotel, Nestor and Fernanda learn the only key is at the summit of Korea's highest southern peak. They climb Hallasan, learning their first Hangul, dodging lava and getting eaten by a mythical white deer.

### Role in the series
*Hallasan* is the tutorial and pilot. It must prove:
1. The full pipeline: data-driven scenes, word banks, gore, saving.
2. All four scene types work and are fun for absolute beginners.
3. The gore makes failure funny, not discouraging.
4. Points carry over to *Jirisan*.

---

## 2. Characters

### Protagonists ✅
| | Nestor | Fernanda |
|---|---|---|
| Personality | Serious, monotone | Outgoing, energetic, relentlessly positive |
| Signature | Long-winded excuses for anything that goes wrong, verging on the absurd | Loses items and forgets things |
| Role in the opening | "Ok, whatever." | "Why don't we learn Hangul since we are in Korea and need to hike this mountain?" |

- Both look Korean but are foreigners from **unknown countries**.
- 🟡 Running gag: every Korean they meet fires rapid Korean at them, assuming they understand.

### Hallasan side characters 🟡
- **Hotel manager:** delivers the bad news with total calm.
- **Janitor:** dropped the key at the summit. Why was he up there? Nobody asks.
- **Park ranger:** enforces rules they keep breaking.
- **Korean hikers:** fully geared, judgmental, chatty.

---

## 3. Story Flow

| # | Beat | Location 🔍 | What happens |
|---|---|---|---|
| 1 | **Opening** | Jeju hotel | Locked out. The janitor dropped the only key at the summit. Fernanda proposes learning Hangul; Nestor: "Ok, whatever." |
| 2 | **Foraging** | Lower trail | Plants drop letters; first syllable blocks |
| 3 | **Animal sightseeing** | Upper trail → 백록담 | Help the 노루. The white deer appears at the summit lake, where the key is |
| 4 | **Volcano eruption** | Summit → descent | Hallasan erupts. They grab the key and flee |
| 5 | **Camp cooking** | Base of the mountain | Illegal camp. Nestor explains why it doesn't count. Cook to earn points |
| 6 | **Ending** | Hotel | Fernanda has lost the key. Carry-over code shown |

🔍 Verify: summit trail options (성판악, 관음사), summit hiking reservation system (a possible first obstacle and Nestor's first excuse), and the camping ban on Hallasan.

---

## 4. Hangul Curriculum

### New letters ✅
**Vowels:** ㅏ ㅓ ㅗ ㅜ ㅡ ㅣ · **Consonants:** ㄱ ㄴ ㄹ ㅁ · **Silent ㅇ** as a placeholder. No 받침 yet.

### Review word bank 🟡 (fully readable with these letters)
| Word | Meaning | Likely scene |
|---|---|---|
| 머루 | Wild grape | Foraging 🔍 |
| 미나리 | Water dropwort | Foraging 🔍 (confirm on Hallasan) |
| 노루 | Roe deer | Animal sightseeing |
| 나무 | Tree | Animal / disaster |
| 머리 | Head | Disaster |
| 이마 | Forehead | Disaster |
| 아이, 오이, 고기, 거미, 모기, 고구마, 어머니, 누나, 이모 | Assorted | Filler and gags |

### Bonus-guess bank 🟡 (letters not yet taught)
| Word | Meaning | Scene |
|---|---|---|
| 고사리 | Bracken fern | Foraging, cooking |
| 시로미 | Crowberry | Foraging 🔍 |
| 구상나무 | Korean fir | Foraging 🔍 |
| 물 | Water | Animal |
| 불 | Fire | Disaster |
| 돌 | Rock | Disaster |
| 용암 | Lava | Disaster |
| 화산 | Volcano | Disaster |
| 다리 | Leg | Disaster |

---

## 5. Scenes

### 5.1 Foraging — collect and combine
- **Exercise:** letters fall from real Hallasan plants as collectibles. Players tap and drag them into syllable blocks and discover which plant names they can spell.
- **Content:** 머루, 미나리 (review); 고사리, 시로미, 구상나무 (bonus).
- **Gore ideas 🟡:** a branch takes an eye; a thorn bush flays a hand; a falling pine cone cracks a skull.
- **Death:** the white deer appears early, out of nowhere, and eats the survivor. Foreshadows the 괴물.

### 5.2 Animal sightseeing — build words with meaning
- **Exercise:** spell words that give the 노루 what it needs (e.g. 나무, 물).
- **괴물 encounter ✅:** the white deer of 백록담 appears at the summit lake. A harder word catches it for the highest points.
- **Gore ideas 🟡:** a stampede tramples a traveler flat; antlers skewer a traveler (the deer is unharmed and unbothered).
- **Death:** the white deer eats the survivor.

### 5.3 Volcano eruption — English in, Korean out
- **Exercise:** an English word flashes up; the player builds the Korean from tiles before the lava hits.
- **Twist 🟡:** the English prompt is the body part about to be hit (head → 머리, forehead → 이마). Get it wrong and that body part gets destroyed.
- **Bonus gambles:** 불, 돌, 용암, 화산.
- **Gore ideas 🟡:** lava melts legs to stumps; a volcanic bomb to the neck sprays blood in a fountain; ash cloud cooks a head like a 군고구마.
- **Death:** the white deer emerges from the smoke and eats the survivor.

### 5.4 Camp cooking — combine foraged words
- **Exercise:** combine foraged words into a real Jeju dish.
- **Dish 🟡:** 고사리육개장 (Jeju bracken-and-pork soup) 🔍.
- **Reward ✅:** points, banked for spending at the *Jirisan* market.
- **Gore ideas 🟡:** spectacular food poisoning; a camp stove explosion.

---

## 6. Systems in *Hallasan*

| System | Hallasan rules |
|---|---|
| **Hearts** ✅ | 5 each at the start of the hike only; no refills during the game |
| **Death** ✅ | One dies → both die (monster eats the survivor) → restart the current scene with the hearts held at its start |
| **Scoring** 🟡 | Review word = base; correct bonus guess = bonus; white deer capture = highest |
| **Difficulty** ✅ | Easy · So So · Diffifuckingcult change speed and time limits only |
| **Input** ✅ | Tap and drag letter tiles; PC mouse first |
| **AI partner** ❓ | How it helps, hinders and gets hurt |
| **Fernanda's forgetfulness** 🟡 | As AI partner, she occasionally drops collected tiles |
| **Local co-op** ✅ | Two players, one screen |
| **Saving** 🟡 | Autosave at the start of each scene |
| **Carry-over** ✅ / ❓ | Points saved to a shared series folder on PC 🔍; a carry-over code shown at the ending as fallback |

---

## 7. Build Plan

Follows Master Roadmap Phases 1–4. *Hallasan* is where the shared engine is first built and proven.

### Step 1 — Pre-production
1. Finalize the opening and ending scripts, including Nestor's excuses.
2. Verify plants, trail, 노루 history, white deer legend and dish (§9).
3. Lock the review and bonus-guess word banks.
4. Write the gore list for every scene and every death.
5. Art style guide: pixel art, Hallasan palette, character sprites.

### Step 2 — Core engine (shared with all 12 games)
1. Letter tiles: tap, drag, snap into syllable blocks.
2. Word checking against data-file word banks.
3. Timers and the three difficulty levels.
4. Hearts, death, scene restart and the monster-eats-survivor sequence.
5. AI partner and local co-op.
6. Save system, points bank and carry-over code.
7. Translation-ready text pipeline (English first).

### Step 3 — Gray-box
1. Build each of the four scenes with placeholder art.
2. Wire the full story flow from opening to ending.

### Step 4 — Playtest
1. Test with real Hangul beginners.
2. Tune timers, difficulty levels and word-bank size.
3. Check that the gore lands as funny.

### Step 5 — Production
1. Final pixel art and animations.
2. Gore animations and blood effects.
3. Music and sound effects.

### Step 6 — Review
1. Native-speaker review of all Korean.
2. Final balance pass.

### Step 7 — Release
1. PC build.
2. Website download page and donation page.
3. Trailer.
4. Project-log entry with lessons learned for *Jirisan*.

---

## 8. Open Questions & Uncertainties

1. AI partner behaviour: helping, hindering and taking damage.
2. Fernanda's tile-dropping: in or out.
3. Carry-over code format and the shared save folder setup.
4. Which trail they take.
5. Whether 미나리 actually grows on Hallasan.
6. Final dish: 고사리육개장 or another.
7. Scoring values for review words, bonus guesses and the white deer.
8. Timer lengths per difficulty level.
9. Open-source licences for code and for art, music and writing.
10. Website hosting and donation methods.
11. What the hotel ending shows: a gift shop, a teaser for *Jirisan*, or both.

---

## 9. Research Checklist 🔍

- [ ] Plants that actually grow on Hallasan, and which match the letters
- [ ] 미나리, 머루, 시로미, 구상나무 and 고사리 on Hallasan
- [ ] 노루 decline and recovery history on Jeju
- [ ] The white deer legend of 백록담
- [ ] Hallasan's volcanic and eruption history
- [ ] Summit trails, hiking reservations and the camping ban
- [ ] 고사리육개장 and other Jeju dishes from foraged plants
- [ ] Godot shared user-data folder across separate games
- [ ] Current stable Godot version at build start
