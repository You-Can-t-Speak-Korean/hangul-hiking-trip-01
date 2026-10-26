# Hangul Hiking Trip — Phase 0 Project Log C

*26 October 2026 · Covers sessions from 24 Oct to 26 Oct 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log B (23 Oct)*

> **Read this first in every new session.** Read this log, then Log B and Log A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED

---

## 0. Summary

- The build started. The **foundation**, **game state** and the **foraging map** were built in Godot 4.7.2 through small Claude Code prompts (1, 2, 3, 3b, 4, 4b, 4c, 4d, 4e).
- The foraging map now has: an uphill climb left → right, three zones, **36 plants carrying one letter each**, decoys that look exactly like targets, a **discovery list** that fills as you walk up to plants, and **hover names that flash and vanish**.
- The headless suite is at **416 passed, 0 failed**, and the runner now fails if a test section dies on a script error.
- Not built yet: picking, the basket, syllable building, hearts in play, gore, audio, co-op.
- **Next:** Prompt 5, picking a letter into the 망태기, and the decoy steam effect.

---

## 1. Workflow rules added (permanent)

| # | Rule | Status |
|---|---|---|
| 1 | Claude **never touches the GitHub repo** and never authors commits. Claude Code works in the user's repo; the user runs all git | ✅ |
| 2 | Claude Code prompts **never** tell it to run `git add`, `git commit` or `git push`. Claude gives the git commands after reviewing the report and screenshots | ✅ |
| 3 | **Small prompts only.** No giant prompts; split work into lettered steps (4, 4b, 4c…) | ✅ |
| 4 | **Each prompt is self-contained.** Claude Code does not keep earlier prompts; a lost session means re-sending the full prompt | ✅ |
| 5 | **Build what ships, not disposable junk.** The gray-box is the real structure with placeholder art | ✅ |
| 6 | **Everything is driven by discovery.** Nothing is shown to the player before they've walked up to it | ✅ |
| 7 | Run the tests yourself before committing, and look for `SCRIPT ERROR` lines | ✅ |
| 8 | Commits use the identity **3th4n** / `273777105+eth4nh4rdy@users.noreply.github.com`, with no Claude co-author lines | ✅ |

---

## 2. Changes to earlier docs

| Doc and item | Was | Now | Status |
|---|---|---|---|
| Word bank v0.1 §2 zones, §7 Q1 | Open; then "2 of each plant, 1 of each target needed, 20 plants" (said in chat 25 Oct) | **One letter per plant.** A target word has one plant per letter (repeats included): 마 2 · 머루 4 · 미나리 6 · 고사리 6 · 고비 4 · 시로미 6 = **28 letter plants**, plus decoys 2 each = **36 plants**. Every letter plant of a word is needed | ✅ |
| Word bank v0.1 §3.1 hover name | "Chinese yam" | **"Korean yam"** | ✅ |
| Word bank v0.1 §4.2 description | "Japanese star anise" | **"Korean star anise"** (decoy; players see "???") | ✅ |
| Word bank v0.1 §7 Q2 | Decoy rewards and gore as suggested | Unchanged so far; decoy effects not built | 🟡 |
| Word bank v0.1 §7 Q3 | Climb direction | **Left → right**, uphill | ✅ |
| Word bank v0.1 §4 | Decoys carry no letters (implied) | **Decoys carry a letter**, so the hover name is the only tell | ✅ |
| Log B 4.1 #5 | Letters sit still in or with the plants | Still true, but **one letter per plant**, scattered, never in word order along the map | ✅ |
| Log B 4.1 #6 | Hover shows the English name | The name **flashes and vanishes**: steady 0.5 s, flickers 0.4 s, gone. Comes back only after leaving and re-entering a plant | ✅ (numbers 🟡) |
| Log B 4.1 #7 | Decoys show "???" | Same, with the same flash timing as targets | ✅ |
| Log B §8 #10 | Delete `claude/hht-project-log-001.md` | Still to do | ❓ |

🔍 "Korean yam" and "Korean star anise" are not standard English names. Chosen on purpose for the game. Word bank **v0.2** should record the new counts and names; v0.1 stays as it is.

---

## 3. What was built

Repo: `github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01` (moved from `eth4nh4rdy`). Godot **4.7.2**, GL Compatibility.

| Prompt | What | Commit |
|---|---|---|
| 1 | Foundation: project, Hangul engine, curriculum data, headless tests | `323789a` |
| 2 | Game state and settings: hearts, both-die rule, scene restart, DDEOK, romanization/subtitle options | `76920eb` |
| 3 + 3b | Foraging gray-box: 64 × 24 m stage, WASD walking with depth, partner follow, two-axis camera, apron, backdrop | `fdb8517` |
| 4 | Rising terrain (≈10 m, slopes < 30°), three zones, plants with letters, hover tooltip, Noto Sans KR font | Commit given 🔍 confirm |
| 4b | Backdrop follows terrain (data), props fade over travelers, tooltip fade, Korean names, distinct fruit colours | Commit given 🔍 confirm |
| 4c | One letter per plant, 36 plants scattered, 붓순나무 orange fruit, readable letters | Commit given 🔍 confirm |
| 4d | Decoys carry letters; discovery list HUD; `Hangul.syllable_count` | Commit given 🔍 confirm |
| 4e | Hover names flash and vanish; test runner fails on dead sections | **Not committed yet** |

### Files (main ones)
| Path | What |
|---|---|
| `scripts/hangul.gd`, `content.gd`, `game_state.gd`, `settings.gd` | Autoloads `Hangul`, `Content`, `GameState`, `Settings` |
| `data/series/curriculum.json`, `rules.json` | Letters per game; hearts, difficulty scales, starting DDEOK |
| `data/mountains/hallasan.json` | Foraging stage, terrain height profile, zones, backdrop, props, plant kinds, `plants.placed`, tooltip, discovery, prop fade |
| `scenes/foraging/foraging.gd/.tscn` | Builds the map from data; hover; ticks discovery |
| `scenes/foraging/terrain.gd` | Smooth monotone height curve; HeightMapShape3D collision |
| `scenes/foraging/plant.gd` | One plant, one letter, four letter styles |
| `scenes/foraging/prop.gd` | Trees and rocks; fade over travelers |
| `scenes/foraging/traveler.gd` | CharacterBody3D, gravity, floor snapping; partner follows |
| `scenes/foraging/discovery.gd`, `discovery_hud.gd` | Discovery logic (no window needed); the list HUD |
| `tests/test_runner.gd/.tscn` | Headless suite: 18 sections, `EXPECTED_SECTIONS`, `MIN_CHECKS` 410 |
| `tests/capture.gd/.tscn` | Screenshots to `tests/shots/` (gitignored); needs a display |
| `art/fonts/NotoSansKR-VariableFont_wght.ttf` + `OFL-NotoSansKR.txt` | Font, SIL OFL 1.1 |

### Run commands (Windows)
```
C:\Users\smeefer\nhmh\tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/test_runner.tscn
```
Godot lives in `C:\Users\smeefer\nhmh\tools\godot\`, outside the repo: the console exe for import and tests, the plain exe for screenshots.

---

## 4. The foraging map now

### Layout
| Zone | x (m) | Ground | Contents |
|---|---|---|---|
| Lower forest | 0–28 | Green | 마, 머루, 미나리, 고사리, 고비 (targets) · 큰천남성, 붓순나무 (decoys, harm) |
| Mid slope | 28–44 | Brown | 노루귀 (decoy, reward) |
| Alpine grassland | 44–64 | Yellow-green | 시로미 (target) · 들쭉나무 (decoy, reward) · 12 구상나무 as scenery |

### Plants
| Rule | Status |
|---|---|
| Each plant carries **one letter**; positions and letters are fixed in data | ✅ |
| Same-kind plants ≥ 4 m apart; any two plants ≥ 2 m apart; none within 6 m of the starts | ✅ |
| A target's plants span ≥ 60% of the zone's width; no word runs in order along x | ✅ |
| Decoy letters come from the letters of the six target words; the two plants of a decoy kind differ | ✅ |
| Letter styles: hanging (머루, 붓순나무, 들쭉나무) · sprouting (마, 큰천남성, 노루귀) · unfurling (고사리, 고비) · on_top (미나리, 시로미) | 🟡 |
| Fruit: 머루 purple · 붓순나무 brown-orange · 들쭉나무 blue-black | ✅ |

Placed plants (x, z, letter):

| Kind | Plants |
|---|---|
| 마 | (2, −9, ㅏ) (25, 4, ㅁ) |
| 머루 | (2, 10, ㅜ) (11, −8, ㅁ) (19.5, 0.5, ㅓ) (25.5, −7.5, ㄹ) |
| 미나리 | (5, 9.5, ㄹ) (11, 9, ㅁ) (13, −4, ㅣ) (18.5, 5, ㄴ) (23, −1.5, ㅏ) (26, 7, ㅣ) |
| 고사리 | (5, −8.5, ㄱ) (8, 8.5, ㅏ) (14.5, 9, ㄹ) (19, −9, ㅣ) (22, 5.5, ㅅ) (26, −3, ㅗ) |
| 고비 | (1.5, 7, ㄱ) (8, −8, ㅂ) (17, −4, ㅣ) (25, 10, ㅗ) |
| 시로미 | (47, 5.5, ㄹ) (50.5, −3.5, ㅗ) (52.5, 3.5, ㅁ) (55, −8, ㅣ) (59.5, −1.5, ㅣ) (62, 6, ㅅ) |
| 큰천남성 | (13, 4, ㅗ) (20, −5, ㄴ) |
| 붓순나무 | (15, 1.5, ㅂ) (21.5, 9.5, ㅓ) |
| 노루귀 | (36.5, 5.5, ㅏ) (34.5, −3, ㄹ) |
| 들쭉나무 | (46, 2.5, ㅅ) (49.5, −6.5, ㅜ) |

The layout came from a seeded one-off script outside the repo; the result is hard-coded in the JSON.

### Discovery list
| # | Rule | Status |
|---|---|---|
| 1 | The list starts **empty** | ✅ |
| 2 | A target kind is discovered when **either traveler** comes within **3 m** of any of its plants | ✅ (radius 🟡) |
| 3 | Decoys never create entries | ✅ |
| 4 | Each entry: the **English name** plus **one empty block per syllable**. No Korean shown | ✅ |
| 5 | Entries appear in discovery order, fade in over 0.4 s | 🟡 |
| 6 | The list **resets** when the scene restarts after a death | ✅ (to try out) |
| 7 | A speaker button that plays the recorded word | ✅ idea · not built (needs audio) |
| 8 | The list's names stay on screen (only hover names vanish) | 🟡 |

### Hover names
Steady **0.5 s**, flicker **0.4 s** at **10 changes/s**, then gone. Same for "???". Values in data. ✅ (numbers 🟡)

### Props
Trees, rocks and 구상나무 fade to **25%** over **0.2 s** while they cover a traveler. Plants and letters never fade. ✅

---

## 5. New decisions not yet built

| # | Decision | Status |
|---|---|---|
| 1 | When a **decoy** is picked, its letter **vanishes in steam with a "tsssss…" sound**, whether the decoy harms or rewards | ✅ |
| 2 | Decoy rewards: the user mentioned a **"health elixir or something"** | ❓ Conflicts with Log B §6 #8 (rewards never give a heart back) |
| 3 | Whether a decoy's letter can be used in a word | ❓ (decide with Prompt 5) |
| 4 | Steam sound source: the user's recording or a CC0 sound | ❓ 🔍 licence |

---

## 6. Known gaps and deviations

| # | Item | Notes |
|---|---|---|
| 1 | **Backdrop** is a stepped dark-grey wall in 4 m blocks | Placeholder; art pass |
| 2 | **Trees can hide letters** | Props fade only over travelers. Small fix later: fade over letters too |
| 3 | **Parse errors hang the test runner** with no exit code | The new guard catches runtime script errors, not parse errors. A hung run = a parse error |
| 4 | Old tests were loosened when terrain arrived (1 cm, 0.1 m tolerances) | Small; recorded |
| 5 | Prop nudging runs 12 passes (was 2) | Needed with 36 plants |
| 6 | 마's two letters: ㅏ is left of ㅁ | Only two orders exist |
| 7 | **Export not tested**; no export preset or templates | The font loads from `res://` in tests |
| 8 | Hover, flicker, prop fade and discovery not tried with a **live mouse** by Claude Code | The user played the climb (feels good) |
| 9 | The partner capsule only follows | AI partner behaviour still ❓ |
| 10 | Orthographic camera | Revisit in the art style test |
| 11 | The top-down debug shot draws the HUD over its legend | Debug only |

---

## 7. Repo and environment notes

- The repo moved to the **You-Can-t-Speak-Korean** org. ❓ The laptop still needs `git remote set-url origin https://github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01.git`.
- Git identity was fixed on both machines (history rewritten by the user; backup branches made first).
- **Godot download trap:** extracting the zip made a *folder* named `Godot_v4.7.2-stable_win64.exe` with the real exes inside. The exes now live in `C:\Users\smeefer\nhmh\tools\godot\`.
- **Stray Godot processes** have been left running twice. Check with `Get-Process *godot*` before running tests.
- **`CLAUDE.md`** (made by Claude Code) is **untracked**. It is accurate but lacks "never run `git add`, `git commit` or `git push`". ❓ Add that line, then commit it.
- ❓ Confirm that `reference/` is in `.gitignore` (CLAUDE.md says so; not checked).
- Untracked junk to delete if still there: `noto-sans-kr.zip`, `out.txt`, `scripts/.gitkeep`.

---

## 8. Open questions

1. Health elixir vs "no heart refills" (§5 #2).
2. Can a decoy's letter be used in a word (§5 #3)?
3. Steam sound source and licence (§5 #4).
4. Does the discovery list fade too, or stay as a reference?
5. Tuning: discovery radius, hover timings, plant counts (spares after playtesting).
6. Word bank **v0.2** (new counts, names, decoy letters).
7. `CLAUDE.md` git line; `reference/` in `.gitignore`; laptop remote.
8. Delete `claude/hht-project-log-001.md` from the Project.
9. Carried from Log B: injury persistence (A or B), the *Hallasan* dish, animal-scene damage, player 2's drag input, AI partner behaviour, asset licence, DDEOK on-chain / NFTs / Sui (STRATEGY mode), 금강초롱꽃 readability (game 9), and the rest of Log B §8.

---

## 9. Next steps

1. **Commit Prompt 4e** (after running the tests yourself: 416 passed, 0 failed, no `SCRIPT ERROR`).
2. **Prompt 5:** click a letter → the traveler walks over and picks it into the 망태기; the decoy's letter vanishes in steam (placeholder sound). Decide §8 #1–2 first.
3. **Prompt 6:** drag letters from the basket into the syllable blocks of the discovery list; impossible combinations gouge; a finished word is foraged.
4. Then: hearts and placeholder gore in play, decoy effects (harm and reward), fade props over letters, split-screen co-op and P2 controls.
5. Word bank v0.2, on request.
6. **In parallel:** the art style test in Blender (live 2.5D).
7. Record audio once the *Hallasan* recording list is final.
