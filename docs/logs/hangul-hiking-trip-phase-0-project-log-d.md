# Hangul Hiking Trip — Phase 0 Project Log D

*30 October 2026 · Covers sessions from 26 Oct to 30 Oct 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log C (26 Oct)*

> **Read this first in every new session.** Read this log, then Log C, Log B and Log A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED
>
> **Rule from the user:** any "rule" written in a log is not absolute and may be overridden by the user. Where this log overturns an earlier rule, §2 says so.

---

## 0. Summary

- The Hallasan foraging scene now plays end to end as a loop: walk, discover, pick (mouse or keyboard), spell syllable by syllable, take damage for mistakes, earn spare plants, get stuck, face a countdown and a monster, restart.
- Prompts **5, 5b, 5c, 5d, 5e, 6a, 6b, 6b-ii, 6b-iii, 6c, 6d and 6e** were built through small Claude Code prompts.
- The headless suite went from 416 (Log C) to **1528 passed, 0 failed**.
- **Not built:** the scene ending, decoy effects (harm and elixirs), loot rules, real audio, co-op, and everything in the art pass.
- **Never heard:** the "tsss" steam sound and the stuck-countdown music (both generated in code, placeholders).
- **Next:** decide the scene ending and decoy effects, then audio, then co-op (see §9).

---

## 1. Workflow rules (changes and reminders)

| # | Rule | Status |
|---|---|---|
| 1 | Rules 1–8 of Log C §1 all stand (Claude never touches the repo, no git commands in Claude Code prompts, small self-contained prompts, run the tests yourself, commit identity 3th4n) | ✅ |
| 2 | **Big prompts get split.** Prompt 6 became 6a, 6b, 6b-ii, 6b-iii, 6c, 6d and 6e | ✅ |
| 3 | Claude Code **never edits `project.godot` by opening the editor**. Changes are made by script so the diff is only the intended lines. The Godot editor rewrites the whole file layout when it re-saves | ✅ |
| 4 | Close any Godot editor **on this project** before running the suite | ✅ |
| 5 | After every Claude Code report: user runs the suite, pastes `git status --short`, Claude writes the exact `git add` line naming each file | ✅ |
| 6 | The suite is run from the repo root: `…\Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/test_runner.tscn` (Windows). On CachyOS use the Linux Godot build, not a path guess | ✅ |

---

## 2. Decisions that overturn or change earlier docs

| Earlier item | Was | Now | Status |
|---|---|---|---|
| Log A §3.6 #2, Log B §6 #8 (no heart refills; rewards never give a heart back) | Hearts never refill | **Healing exists.** Decoy plants can give 쌍화탕 (restores ½ heart) and 공진단 (restores 1 whole heart) | ✅ |
| Log B §5 #3 (P2 picks with numpad 0 / right Ctrl) | Numpad 0 / right Ctrl | **P1 = WASD + Space. P2 = arrow keys + Enter (or keypad Enter).** | ✅ |
| Log B §4.1 #2 (letters are picked with the mouse) | Mouse only | Mouse **and** keyboard (Space/Enter picks the nearest pickable plant in reach) | ✅ |
| Log B §4.1 #11–12 (rejected letter gouges; any real syllable is fine) | Only impossible combinations are rejected; real syllables cost nothing | **Strict.** A real but wrong syllable is a failure. A failed syllable **destroys all of its letters** and hurts the travelers | ✅ |
| Log B §4.1 #11 (gouge, heart lost) | A heart lost | **Half a heart on Hallasan, to both travelers** per failed syllable | ✅ |
| Log C §5 #3 (can a decoy's letter be used?) | ❓ | **No.** A decoy's letter vanishes in steam with a "tsss" and never enters the basket | ✅ |
| Log C §9 #3 (Prompt 6 drags into the small blocks in the discovery list) | Drag into the list | **Clicking a discovery entry opens a spelling view** that pauses the map. Letters are dragged (or keyed) from the basket into its blocks | ✅ |
| Log C §2 / word bank (letter plants fixed at 36) | Fixed 36 plants | **Completed words earn spare credits** that spawn extra plants after mistakes (cap 6, from data slots) | ✅ |
| Log C §4 hover names (steady 0.5 s, flicker 0.4 s at 10/s) | 0.9 s total | **Halved on purpose:** steady 0.25 s, flicker 0.2 s at 20 changes/s, 0.45 s total. Applies to mouse hover and walk-up alike | ✅ |
| Log C §6 #9 / stuck players | Nothing | **A stuck but living player gets a 40-second countdown with quiet death music, then the mountain's monster kills both travelers.** A menu restart is the other way out | ✅ |
| The 원고지 inventory screen | Planned as the item inventory | **Belongs to another game**, not Hangul Hiking Trip. Dropped here | ✅ |
| Loot | Not decided | **Items picked up disappear on death.** Loot stays only after finishing all of Hallasan without death (except in the disaster boss scene) | ✅ decided · unbuilt |
| Co-op input | Open | The mouse is shared; a banner says **"Nestor's turn" / "Fernanda's turn"**. Foraging itself uses P2 = arrows + Enter | 🟡 |

Corrections the user made to my readings:

- **Letters lost per failed syllable is not always 2.** On Hallasan syllables have at most two letters (no 받침), so it is 2 there. On other mountains it scales with the syllable: a 밝 spelled as 밢 hits each traveler with two letters and costs each a whole heart ✅.
- Both travelers take the damage (cooperative, collective challenge) ✅.
- A syllable's letters all die together. In the user's example, with 머루 and ㅁ then ㅗ chosen, ㅁ whacks one traveler in the head, ㅗ stabs the other in the ear, and both letters vanish ✅. **Per-letter targeting is not built** (see §8).

---

## 3. What was built

Repo: `github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01`. Godot **4.7.2**, GL Compatibility.

| Prompt | What | Tests after | Commit |
|---|---|---|---|
| 5 | Click a plant: traveler walks and picks the letter into the 망태기. Decoy letters vanish in steam with generated "tsss". Picking logic is node-free | 491 | `87900a9` |
| 5b | HUD panels swallow clicks; basket drawn as a woven bag; tiles wrap into rows (7 columns, 28 letters fit) | 535 | `bc959c3` |
| 5c | Space (P1) / Enter (P2) pick actions; walk-up name flash at halved timings; subtle reach ring on the nearest pickable plant | 595 | 🔍 not seen |
| 5d | Hearts stored in half-units (Hallasan: 10 units each); `damage_units()`, `heal()`; stale "No refills" header fixed | 751 | `630066d` |
| 6a | Spelling view: strict per-syllable judging, pause, drag from basket, done marks | 732 | 🔍 not seen |
| 6b | Failed syllable costs both travelers ½ heart; placeholder gore; hearts readout; death beat and real scene restart | 836 | 🔍 not seen |
| 6b-ii | Spare plant on word completion (deficit-based letter, data slots, cap 6) | 938 | 🔍 not seen |
| 6b-iii | Spare **credits** banked per completed word and spent on failures | 1008 | 🔍 not seen |
| 5e | Travelers can walk down to the bottom screen edge; camera clamp follows the slope | 1070 | 🔍 not seen |
| 6c | Keyboard cursor and placement in the spelling view for P1 and P2 | 1198 | 🔍 not seen |
| 6d | Stuck check, 40 s countdown, placeholder music, white deer kill | 1394 | 🔍 not seen (pushed per user) |
| 6e | Pause menu with Resume and confirmed Restart scene | 1528 | 🔍 not seen (commit given to user) |

Order of commits was 4e (`4e3fc5b`), 5, 5b, 5c, 5d, then 6a onward. Run `git log --oneline -30` to fill the 🔍 hashes.

### New files (main ones)

| Path | What |
|---|---|
| `scenes/foraging/picking.gd` | Basket, picked-once state, walk bookkeeping, reach and nearest-pickable logic (node-free) |
| `scenes/foraging/basket_hud.gd` | The 망태기 bag, tile rows, keyboard highlight |
| `scenes/foraging/steam_sound.gd` | Generated "tsss" (AudioStreamWAV, no files) |
| `scenes/foraging/spelling.gd`, `spelling_hud.gd`, `spelling_cursor.gd` | Spelling logic (node-free), the panel and drag, the keyboard cursor |
| `scenes/foraging/damage.gd`, `hearts_hud.gd` | Damage routing and death decision (node-free), the hearts readout |
| `scenes/foraging/spares.gd` | Spare credits, deficit calculation, cap (node-free) |
| `scenes/foraging/stuck.gd`, `countdown.gd`, `kill_timeline.gd` | Stuck decision, the clock, the kill's timing (all node-free) |
| `scenes/foraging/stuck_hud.gd`, `stuck_music.gd`, `deer.gd` | Countdown number and vignette, generated music loop, the deer from primitives |
| `scenes/foraging/pause_menu.gd`, `pause_menu_hud.gd` | Menu rules (node-free) and the panel |

New data blocks in `data/mountains/hallasan.json`: `picking`, `basket_hud`, `reach_ring`, `spelling_view`, `keyboard_select`, `damage`, `gore_placeholder`, `hearts_hud`, `spares`, `walk_limit`, `stuck`, `stuck_music`, `monster`, `pause_menu`. `data/series/rules.json` gained `half_units_per_heart: 2`.

---

## 4. The foraging scene as built

### 4.1 Controls
| Player | Walk | Pick / place / confirm | Menu |
|---|---|---|---|
| P1 | WASD | Space; mouse click on a plant or HUD | Esc opens the pause menu |
| P2 | Arrow keys | Enter or keypad Enter | Arrows + Enter work in the menu and spelling view |

Only P1 has a controllable traveler. P2's keys are bound and tested but there is no P2 traveler or split screen yet. The mouse is the shared pointer.

### 4.2 Picking
- Clicking a plant walks the traveler to it and picks. Any WASD input cancels the walk. A blocked walk gives up after 1.0 s. `pick_radius` is 1.3 m.
- Space picks the nearest plant in reach that still has its letter, instantly, and cancels any click-walk.
- A subtle ring marks the nearest pickable plant in reach. It is identical for targets and decoys (radius 1.0 m, width 0.14, alpha 0.35).
- A plant's hover name flashes (mouse hover or the human traveler entering its radius), then vanishes. It returns only after leaving and re-entering. The AI partner never triggers it.
- A picked plant stays in the world, letterless. A picked decoy steams and its letter is gone.
- Clicks pass through trees to a hidden letter (kept on purpose; the real fix is fading props over letters, §8).

### 4.3 Basket and discovery list
- The 망태기 sits bottom right, drawn in code as a woven bag with a rope handle. Tiles wrap at 7 columns, growing upward.
- Consonant and vowel tiles have different colours. Panels swallow clicks; the full-screen layer roots do not.
- The discovery list is unchanged from Log C, except clicking an entry opens the spelling view. A finished word is tinted green with a check mark and opens nothing.

### 4.4 Spelling view
- Opens from a discovered entry, pauses the map, panel at top centre. One block per syllable, with a consonant slot and a vowel slot. 받침 slots come from `slots_for(syllable)` if a syllable has one (untested beyond Hallasan).
- Blocks fill left to right. A block is judged when both slots are filled. It is correct **only if the composed syllable equals the target's**. Anything else, including a real wrong syllable, is a failure.
- Letters leave the basket when dropped. Correct: consumed and locked. Failure: both letters destroyed, red flash 0.6 s, view closes. Closing early (Esc or Close) returns unjudged letters; correct blocks stay locked.
- Keyboard: the cursor appears on the first key press (it only shows on tile 0, no move or place). WASD/arrows move over the basket grid with wrapping; Space/Enter places in the next empty slot through the same code as a mouse drop. A glowing red outline marks the current tile. One player is "active" at a time (`SpellingCursor.set_active_player(p)`, P1 default). Held movement keys repeat; the place key does not. All player keys are swallowed while the view is open.
- Hook for damage: `Spelling.syllable_failed(word_id, block_index, letters)`; also `word_completed(word_id)`.

### 4.5 Hearts, damage, death
- Hearts are stored in half-units (1 heart = 2 units; Hallasan 5 hearts = 10 units each). `hearts_changed(traveler, units)` carries **units**.
- `damage_units(t, units, injury)` is the entry point. The old `damage(t, injury)` still works (one whole heart). `heal(t, units)` caps at max and does nothing for a dead traveler. **Nothing calls `heal()` yet.**
- A failed syllable queues damage of `failure_damage_units` (1 unit = ½ heart) for **both** travelers, applied **when the spelling view closes**, so the consequence is visible on the map. Two placeholder blood bursts, staggered 0.15 s, plus a red tint flash.
- Nestor reaches 0 first at equal damage; the both-die rule (in `GameState`) is unchanged.
- Death beat: about 1.5 s of dim, then `_restart()` (which calls `GameState.restart_scene()` and reloads the scene). `foraging._ready` calls `GameState.begin_scene("foraging")` so a restart returns to the scene's start hearts, not the hike's.
- Hearts readout: top right, code-drawn hearts (full, half, outline), one row per traveler.

### 4.6 Spare plants
- Each completed word earns **one credit** (word-specific), kept oldest first. Credits plus spawned spares never exceed the cap of **6**.
- On completion: if a shortage exists, that word's credit is spent at once. Otherwise it is banked.
- On a failed syllable: while a shortage exists and credits remain, the oldest credit is spent, spawning a spare **of that word's kind** in **that word's data slot**, carrying the jamo with the largest deficit. The deficit counts jamo needed by unfinished words minus jamo in the basket, on letter-bearing **target** plants, and on unpicked spares. Decoy letters never count.
- Spawns happen when the spelling view closes, before damage. A 0.5 s grow-in; pickable only after it ends.
- Slots (x, z): 마 (15, −8.5) · 머루 (13, −1) · 미나리 (22.5, −10) · 고사리 (16.5, −1) · 고비 (12, 6.5) · 시로미 (57.5, 10).
- A consequence the user accepted: a spare's hover name matches the word whose credit was spent, not the word its letter is for.

### 4.7 Walking
- Travelers can now walk down to the bottom screen edge. The old stop (feet at screen y 510 of 720) was an invisible stage wall at z ±11.6, while ground and collision already ran to z = 24.
- The new limit keeps the feet 0.3 m from the bottom edge (`walk_limit.near_margin`). It depends on x because of the slope (z 22.36 at x = 0, 20.22 at x = 32, 23.69 at x = 64). The camera clamp stops short by the slope rise so no sky shows.
- Left, right and top walls were left as they were (see §8).

### 4.8 Stuck, countdown, monster
- **Stuck** means no sequence of correct word completions can finish every unfinished word, using the real `spares.gd` rules on forks of the live state. Evaluated after every pick and after the spelling view closes.
- A brute-force check showed "deliberate failures never help" is false in general (three banked credits and one letter short makes a deliberate failure useful), but that state is unreachable in play, and the search includes failures anyway, so it cannot start a countdown unfairly. If the search budget is exceeded it assumes "not stuck".
- **Countdown:** 40 s, once per stuck episode, cancels if the verdict stops being stuck, pauses while the spelling view or the menu is open. A faint whole-second number at top centre (hidden while the spelling view is open) and a growing vignette.
- **Music:** generated in code, 24 s loop at 11025 Hz, very quiet (around −30 dB), a drone of two detuned tones plus sparse gong-like hits, faded in over 4 s. Placeholder only: no melody, not a recording.
- **Monster:** the white deer of 백록담, built from primitives, leaps in within about 0.3 s, hits one traveler then the other (about 0.35 s apart) with large blood bursts. Then the existing death beat and restart. The last 1 s before zero locks all input (`lockout_seconds`). The monster is data-driven per mountain.
- 🔍 The deer's folklore details are unverified; the placeholder claims none and is named just "White deer".

### 4.9 Pause menu
- Esc opens it only when the spelling view is closed, the scene is not restarting, and no death beat or monster sequence is running. Inside the spelling view Esc closes the view only. One Esc event reaches one or the other.
- Resume and **Restart scene** (with a confirmation: "Restart? Progress in this scene is lost."; the default focus is No; Esc on the question means No). Yes restarts through `_restart()` with no death beat, no gore, no monster, and no extra penalty.
- Opening pauses the tree, the countdown, the vignette and the music (the player and its fade are paused and resume in place). Both players' keys work in the menu; the mouse works too.
- Input is blocked while open by `picks_allowed()` plus checks in `step()` and `update_hover`; the `restarting` flag is not reused, because it would block Resume.

---

## 5. Decided but not built

| # | Decision | Status |
|---|---|---|
| 1 | Decoys give the elixirs: **쌍화탕 (½ heart)** and **공진단 (1 heart)**. They are found by accident. The decoys stay | ✅ |
| 2 | Which decoy yields which elixir; how and when an elixir is used (no 원고지 inventory in this game) | ❓ |
| 3 | Harm decoys (큰천남성, 붓순나무) need their gore (face swells and pops; convulsions, eyes pop out) | 🟡 from word bank v0.1 §4.1 |
| 4 | Loot persists only after finishing all of Hallasan without death (except the disaster boss scene); picked items vanish on death | ✅ |
| 5 | Co-op: split screen; mouse shared; "Nestor's turn" / "Fernanda's turn" banner; both travelers take half a heart for a failed spelling | ✅ / 🟡 banner |
| 6 | Walking limit idea: feet may go further, "until only the heads are visible". Current limit is feet at the bottom edge | 🟡 tweak later |

---

## 6. Known gaps and deviations

| # | Item | Notes |
|---|---|---|
| 1 | **The "tsss" and the stuck music have never been heard** | Both generated in code. Listen and tune; values are in data |
| 2 | No audio recordings yet | The ~75-clip *Hallasan* list is still to be recorded (Log B §3) |
| 3 | Backdrop, travelers, plants, gore and the deer are placeholders | Art pass pending |
| 4 | Trees can hide letters; clicks pass through | Fade props over letters too (Log C §6 #2) |
| 5 | Hover through a panel still shows a plant name | Unchanged, untested |
| 6 | Left, right and top walls stop travelers with apron still visible | Only the near side was fixed |
| 7 | Tests cover 16:9 only | Other aspect ratios untested |
| 8 | The `restarting` flag and `begin_death_beat` guard were reworked | The map now has several lockouts (restarting, dim layer, kill, menu) |
| 9 | The second kill fires `travelers_died` again | Nothing listens |
| 10 | A mistaken keyboard placement cannot be taken back by keyboard | Only Esc or the mouse |
| 11 | `damage.gd`, `spares.gd` and others show no `.uid` files in `git status` | Godot writes them on an import or editor run; commit separately if they appear |
| 12 | Walks and drags were verified with synthetic events plus the user's playtests | No other hardware checked |
| 13 | The user perceived hover names as about 3 s long | Code showed 0.9 s before halving. Cause unexplained |
| 14 | Noto Sans KR renders thin at its default weight in the blocks | Cosmetic; variable font, so a bolder weight is probably a small fix |
| 15 | Export not tested | Carried from Log C |

---

## 7. Repo and environment notes

- Windows machine: `C:\Users\smeefer\nhmh\hangul-hiking-trip-01`. Godot in `C:\Users\smeefer\nhmh\tools\godot\`. The console exe runs headless tests; the plain exe is needed for screenshots (`tests/capture.gd`, options like `--stuck-only`, `--pause-only`).
- CachyOS laptop: works with the Linux Godot 4.7.2 build kept outside the repo. Watch for case-sensitive paths and CRLF line endings.
- **Remote:** the laptop's remote was fixed to `https://github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01.git` after one push (`bc959c3`) still went to the old `eth4nh4rdy` address. The 5d push went to the org. Windows pushes also reach the org.
- **`project.godot`** was rewritten by the editor twice (cosmetic `]` moves, plus a stray right-Ctrl binding). Both were dropped with `git restore`. The only deliberate change is the 5c input map.
- A Godot Project Manager window (launched from Downloads) has often been open during runs. It is harmless but can confuse "stray process" checks.
- **`CLAUDE.md`** is still untracked and still lacks the "never run `git add`, `git commit` or `git push`" line. ❓
- ❓ Confirm `reference/` is in `.gitignore`. Untracked junk to delete if still there: `noto-sans-kr.zip`, `out.txt`, `scripts/.gitkeep`.
- **Project docs to clean up** (deletion is irreversible, so ask first): `claude/hht-project-log-001.md` (superseded); one of the two identical Log C copies; root and `claude/` duplicates of earlier logs.

---

## 8. Open questions

1. Which decoy gives 쌍화탕 and which gives 공진단, and how an elixir is used (§5).
2. How loot carries between scenes (§5 #4).
3. **Per-letter damage targeting:** should each letter of a failed syllable hit a specific traveler (ㅁ one, ㅗ the other), and how does that scale on mountains where a two-letter hit costs a whole heart?
4. Spare plants show the old word's English name on hover. Keep, or match the word the letter is needed for?
5. Fade props over letters, and the left, right and top walls.
6. A key for taking a letter back out of a block (keyboard players).
7. Steam sound source and licence. The stuck music's real recording and licence (originals only, Global Rule 9).
8. The white deer's folklore details and whether other mountains' legends go into the 도감 text 🔍.
9. Tuning in playtests: countdown length and vignette, stuck-music mood and volume, spare cap and credit rules, discovery radius, hover timings.
10. Co-op: split screen, P2's traveler and drag input, the turn banner, AI partner behaviour.
11. The scene's ending (see §9) and DDEOK scoring, including bonus points for guessed words (Log A §3.6 #7).
12. Word bank **v0.2** (counts, names, decoy letters, spare slots) and 🔍 native-speaker review of every Korean string.
13. Whether romanization and English-subtitle settings are used in this scene 🔍.
14. Carried from Logs A–C: injury persistence (A or B), the *Hallasan* dish, animal-scene damage, asset licence, DDEOK on-chain / NFTs / Sui (STRATEGY mode), 금강초롱꽃 readability (game 9), and the rest of Log B §8.

---

## 9. Next steps and what remains for the Hallasan foraging scene

| Area | Remaining | Status |
|---|---|---|
| **Scene ending** | Finishing all six words does nothing yet. Needs an end state, a hand-off to animal sightseeing, and DDEOK scoring | ❓ not designed |
| **Decoy effects** | Harm decoys need gore. Reward decoys need to give the elixirs. Elixir use is undecided | ❓ open |
| **Loot rules** | Keep items only after finishing Hallasan without death | decided, unbuilt |
| **Audio** | Recordings, tile tap sound, the speaker button in the list, a first listen to the "tsss" and the stuck music | unbuilt / unheard |
| **Co-op** | Split screen, P2 traveler, turn banner, AI partner | ❓ open |
| **Small fixes** | See §6 and §8 #5–6 | listed |
| **Content** | Word bank v0.2, native-speaker review, written plant sources | pending |
| **Art pass** | Backdrop, models, real gore, plant art, the Blender style test | not started |
| **Release** | Export presets and a test export | untested |

Suggested order 🟡: scene ending with decoy effects, then audio, then co-op. The first needs the user's decisions on decoy rewards and the end-of-scene flow.

**Also pending:**
1. Fill the 🔍 hashes in §3 with `git log --oneline -30`.
2. Add the "never run git" line to `CLAUDE.md`, commit it, and check `reference/` in `.gitignore`.
3. Clean up duplicate and superseded docs in the Project, after confirmation.
4. In parallel: the art style test in Blender (live 2.5D).
