# Hangul Hiking Trip — Phase 0 Project Log F

*9 November 2026 · Covers sessions from 5 to 9 Nov 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log E (5 Nov)*

> **Read this first in every new session.** Read this log, then Logs E, D, C, B and A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED
>
> **Rule from the user:** any "rule" written in a log is not absolute and may be overridden by the user. Where this log overturns an earlier rule, §2 says so.

---

## 0. Summary

- **The Hallasan foraging scene is complete as graybox.** It now has an ending: plant rewards per word, the exit note, the 고사목 exit, a pending loot bank and a hold on black. This is the "graybox lock" point of Log E §8.
- Prompts **8a** and **8b** were built through Claude Code. The headless suite went from 2717 (Log E) to **3121 passed, 0 failed**.
- **Words pay plants, not DDEOK.** DDEOK comes from chaos finds and store trades only.
- **A recurring cast of note writers** was created: the old lady (a 무당), 동철수, 송수민 and 봉민수. Notes are never addressed to the travelers.
- Two production docs were written: **Hallasan Exit Note v0.1** and **Hallasan Item Names v0.1**.
- **Next:** decide on Claude Code's unrequested build doc (§8), then plan the animal sightseeing scene. Art direction (FRONTEND) can now start against a locked graybox.

---

## 1. Workflow rules (changes and reminders)

| # | Rule | Status |
|---|---|---|
| 1 | All rules of Log E §1 stand (screenshots optional, content inline, playtest checklist, API checks with doc pages, numbered deviations, no stray Godot processes, no legal, licence or tax topics) | ✅ |
| 2 | **Claude Code prompts stay under 5 KiB.** Prompt 8a (about 9 KiB) was too large. Split a prompt rather than exceed this | ✅ user rule |
| 3 | During 8b, Claude Code ran two read-only git commands (`git log -1`, `git diff --stat`) out of habit and saved a memory note. If it happens again, tighten the wording in `CLAUDE.md` | 🟡 watch |
| 4 | Claude Code wrote an unrequested production doc during 8b (§8). Prompts should say that Claude Code writes no docs unless asked | 🟡 add to next prompt |
| 5 | Production docs are written to the Project's `claude/` folder; the user saves them to `docs/production/` in the repo | ✅ |
| 6 | **Game text lives in `data/`; the human-readable production doc lives in `docs/production/`.** For example, the exit note's text is in `data/notes/hallasan.json`, and its reasoning and checks in `docs/production/hallasan-exit-note-v0.1.md` | ✅ |

---

## 2. Decisions that overturn or change earlier docs

| Earlier item | Was | Now | Status |
|---|---|---|---|
| Log E §9 #1 (DDEOK payouts for play; lab placeholders review 10, bonus 30, white deer 100, dish 50) | Open; words might pay DDEOK | **Words pay no DDEOK.** Each finished word gives **2 of that plant** to Fernanda's backpack. Plants can be cooked or sold in stores for DDEOK. This matches DDEOK Dev Decisions §4 | ✅ built |
| Log D §2 / Log E §4.2 (loot rule) | Two readings: loot kept only after all of Hallasan, or restored to scene start on death | **Each scene banks its loot when it ends. A death restarts the scene and loses only what was gained in that scene** | ✅ built |
| Roadmap §6 / Log E §2 (carry-over) | On-chain play carries everything | **DDEOK and NFT items can be claimed to a wallet only after finishing the whole game (all of Hallasan).** Only survivors bring their Hallasan loot to Jirisan | ✅ |
| Log B §2 #8 (recurring cast: only the protagonists, maybe) | Protagonists only | **Four recurring note writers** (§6). They may be met later as people or monsters (but see #9 below and 동철수's rule) | ✅ |
| Log B §2 #9 (괴물 are creatures with no personality) | No exceptions | Unchanged for now. A writer who later turns out to be a monster would be the first exception. **Not decided; don't decide it by accident** | ❓ |
| Log E §5 #6 (notes as NFTs in the backpack, holding facts) | Notes as backpack rows | **Notes live only inside the 수첩 (notebook)**, never as their own backpack rows. They're loot (lost on death in their scene). They act as an in-world game guide | ✅ built |
| Ending design, batch 1 (exit with confirm prompt, B + C) | Walk to exit, then confirm | **B only: no confirm prompt.** The note is the prompt | ✅ built |
| Roadmap (side characters) | Hotel staff etc. | **A new side character: the old lady,** a quiet 무당 who gives Fernanda the 수첩 in the opening scene when the hotel key turns out to be missing. Not in the roadmap | ✅ |

---

## 3. What was built

Repo: `github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01`. Godot **4.7.2**, GL Compatibility.

### Commits now known (from the user's `git log`)

| Prompt | Commit |
|---|---|
| 6c | `e854a6e` |
| 6d | `4bb433d` |
| 6e | `90fca34` |
| 7a | `4574eb0` |
| 7b | `519a783` |
| 7b-ii | `11545dc` |
| 7c | `7a2377e` |
| 7d | `8289d82` |
| 7d-ii | `6b92489` |
| Docs: Logs D and E, word bank v0.1, `CLAUDE.md` no-git rule | `0cd6e11` |
| 8a | 🔍 not seen |
| Docs: exit note v0.1, item names v0.1 | 🔍 not seen |
| 8b | 🔍 not seen (commands given) |

Still 🔍 from Log D: 5c, 6a, 6b, 6b-ii. Run `git log --oneline -30` to fill them.

### Builds

| Prompt | What | Tests after |
|---|---|---|
| 8a | Six plant items; +2 per finished word with a float; the 수첩 and a starting kit; note writers and note data; notes stored as inventory items and hidden from backpack rows; the notebook view (newest first, flip, scroll, empty state); quick keys; `--debug-notes` | 2978 |
| 8b | P1 notebook key N → Q; the exit note's flight and pickup; the placeholder 고사목 and exit gap; fade to black; pending bank; hold on black with a debug line; Restart from the hold | 3121 (`MIN_CHECKS` 3115) |

### New files

| Path | What |
|---|---|
| `data/series/note_writers.json` | The four writers (ids, names, a note each) |
| `data/series/notebook.json` | Notebook look and text (panel title, Back/Close, arrow glyphs, sizes) |
| `data/notes/hallasan.json` | The exit note `hallasan_exit_sumin` |
| `scenes/foraging/notebook.gd` | The notebook view |
| `scenes/foraging/ending.gd` | The ending sequence |
| `scenes/foraging/exit_note.gd` | The note's flight, landing and pickup |
| `scenes/foraging/dead_tree.gd` | The placeholder 고사목 and its barrier |
| `scenes/foraging/ending_hud.gd` | The fade and the hold-on-black line |

Changed data: `data/series/items.json` (six plants, `sucheop`), `data/series/rules.json` (`starting_kit`), `data/mountains/hallasan.json` (`foraging.word_rewards`, `foraging.ending`), `project.godot` (input actions `notebook_p1` = Q, `notebook_p2` = /).

---

## 4. The foraging scene as built (changes since Log E §4)

### 4.1 Controls

| Player | Walk | Pick / confirm | Backpack | 수첩 | Menu |
|---|---|---|---|---|---|
| P1 | WASD | Space; mouse | Tab | **Q** | Esc |
| P2 | — (no traveler yet) | Enter or keypad Enter | Right Shift or Right Ctrl | **/** (physical key, US position) | Esc (shared) |

- Quick keys open the 수첩 only when the spelling view, pause menu, gore, death and monster sequences are all inactive. Only the same key closes it; the other player's key does nothing over it.
- Neither quick key works while the backpack list, or a notebook opened from its row, is showing. Tab or a P2 backpack key over a notebook opened from its row closes the whole panel.

### 4.2 Plant rewards
- Finishing any target word (review or bonus) adds `word_reward_count` (2) of its plant to Fernanda's backpack and floats "+2 고사리" (name_ko, Noto Sans KR) from the controlled traveler.
- Plant rows are view-only. Plants are scene loot.
- The 시로미 target's existing kind id is **`simiro`** (a typo for siromi). It maps to item `plant_siromi`.

### 4.3 The 수첩
- `GameState.new_hike()` clears the backpack, then adds `rules.json → starting_kit` (sucheop ×1), so the 수첩 is part of every scene-start snapshot and is never lost.
- The 수첩 row is the **first selectable row**, so reaching an elixir takes one extra step. The user found this fine in playtest.
- One page per note, showing **only the note's text**: no title, writer, date or page number. ◀ ▶ indicators sit outside the page edge when a page exists that way.
- Newest first. Flip: P1 A/D, P2 Left/Right. Scroll: P1 W/S, P2 Up/Down. Empty state: "No notes yet."
- The panel is the backpack's 520×560 px. The exit note (921 px tall) scrolls within a 441 px page.
- Notes are registered from `data/notes/*.json` as items of kind `note`. Newest-first relies on Dictionary insertion order, covered by a snapshot/restore test.
- `-- --debug-notes` adds every Hallasan note at scene start, as scene loot.

### 4.4 The ending
- **Completion:** `Spelling.all_done()` is checked after every `word_completed`; words finish in any order.
- **Exit note:** 1.5 s after the sixth word completes (counted only while the map runs), the note flies in off the right edge over 5 s with sway, spin, bob and tilt, and lands 1.5–3 m from Fernanda on clear ground. It freezes when the map pauses. If no clear spot is in range, a second pass with smaller clearances runs, then open ground. If the traveler walks away mid-flight, the note re-aims from where it is.
- **Pickup:** human traveler only, Space and the reach ring, no hover name, no click-to-walk. Adds the note and floats "+1 note". Optional.
- **고사목:** at (64.0, −7.0), near the 12 alpine 구상나무 (x 45–63). Before completion the edge is a wall. After completion, a barrier branch tips over and a 2.2 m gap opens. Exit trigger: x 65.2–67. Two keep-out points stop props from blocking the gap.
- Leftover decoys and chaos piles stay live until the travelers leave. The stuck countdown can't start after completion (tested).
- **Exit:** entering the trigger blocks input and fades to black over 1 s. GameState stores a **pending bank** (backpack and hearts) and the target `cutscene_foraging_to_animals`.
- **Pending bank:** applied only when `begin_scene` is called with the target's id. Until then, the scene holds on black with "next: cutscene_foraging_to_animals (not built)". Esc opens the pause menu; **Restart scene discards the pending bank** and restores foraging's original start snapshot, so loot can't be farmed.
- All ending numbers and text are in `foraging.ending` in `data/mountains/hallasan.json`.

---

## 5. Decided but not built

| # | Decision | Status |
|---|---|---|
| 1 | **Quick heal on E (P1):** drinks 쌍화탕 first, and 공진단 only when 쌍화탕 runs out. Who it heals (🟡 the traveler with fewer hearts) and P2's key are open | ✅ idea · later |
| 2 | **The cutscene** between foraging and animal sightseeing; the user makes it in another session. Then the travelers appear in the animal sightseeing scene | ✅ |
| 3 | **DDEOK as a cooking ingredient:** some combinations make an expensive or beneficial food, others ruin the recipe or add nothing. For the recipe spec. On chain, DDEOK spent in a pot must be burned or sent to the reward pool | 🟡 |
| 4 | **The opening scene:** the hotel key is missing; the old lady gives Fernanda the 수첩 | ✅ unbuilt |
| 5 | **Handwritten-looking notes,** possibly a different hand per writer | 🟡 FRONTEND, later |
| 6 | **The 수첩's look:** a worn pocket notebook of the kind an old person would carry | ✅ FRONTEND |

---

## 6. Note writers and series note rules

### 6.1 Rules

| # | Rule | Status |
|---|---|---|
| 1 | Notes are **never written to Nestor or Fernanda.** They're written to oneself, to an unknown person, to anyone, or between writers. The travelers find them by chance | ✅ |
| 2 | **Mostly English, with familiar Korean nouns,** preferably words the player has just learned | ✅ |
| 3 | Notes are mysterious and may plant clues for the story later | ✅ |
| 4 | Notes double as an in-world game guide | ✅ |
| 5 | The old lady is **never called "grandma"** in game text; she is "the old lady" | ✅ |

### 6.2 The writers

| Writer | Who | Voice | Rules |
|---|---|---|---|
| **The old lady** | A quiet, reserved **무당** who gives Fernanda the 수첩 | Notes that rarely make immediate sense; ramblings like folklore visions | No name in data |
| **동철수** | The over-equipped **등산 아저씨** | Eccentric, slightly crazy, comic relief; writes about where he pooped and what he shouldn't have eaten | **Never a 괴물.** Whether he survives stays a mystery |
| **송수민** | University student, lost on an **MT** hiking trip, then lost 민수 too | Cute and girly in style; never states her gender | Writes letters to 민수 |
| **봉민수** | University student, lost on the same trip | ❓ voice not yet written | Writes letters to 수민 |

- 수민 and 민수 **aren't a couple yet,** but both clearly have crushes. Their notes are cute and flirty.
- Their genders stay unstated; the names read naturally as a woman and a man.
- More writers may be added later.
- ❌ Rejected along the way: a warm, bossy grandma; a grandma who reveals as a giant (설문대할망); the lovers as a nameless pair already in love.

### 6.3 Notes so far

| Id | Writer | Where | Doc |
|---|---|---|---|
| `hallasan_exit_sumin` | 송수민, to 봉민수 | Hallasan foraging, after the sixth word | Exit Note v0.1 |

The exit note includes an unnamed cameo by 동철수 (the hundred-pocket hiker) 🟡 kept.

---

## 7. Known gaps and deviations

| # | Item | Notes |
|---|---|---|
| 1 | **The 고사목 doorway reads poorly** | From the camera, the gap is seen end-on and the fallen barrier is hard to see. Art pass |
| 2 | The real `change_scene_to_file` hand-off is untested | Tested only through the `exit_handoff` signal; no target scene exists yet |
| 3 | 87 older tests use `_bare_hike()` (empty backpack) | New tests cover the real `new_hike()` |
| 4 | The 시로미 kind id is `simiro` | Cleanup later |
| 5 | API checks used a `--doctool` dump of the 4.7.2 class reference (signatures, no descriptions) | Semantics rest on tests |
| 6 | The `--debug-notes` console line is checked by hand only | The suite doesn't capture stdout |
| 7 | Untested: mouse-only play, pause-menu button visuals over the black, the spelling view during the note's flight | User playtest passed |
| 8 | The notebook panel is fixed in pixels (same at 1280×720 and 1920×1080) | 16:9 only, as before |
| 9 | Native-speaker review | Plant item names, 수첩, the exit note ("MT", "고기 from MT"), captions from Log E |
| 10 | Log E §6 gaps not listed here are unchanged | |

---

## 8. Repo and Project notes

- **Untracked:** `docs/production/hallasan-foraging-ending-build-v0.1.md`, written by Claude Code during 8b **without being asked**. It was left out of the 8b commit. ❓ Keep it (as a build note, possibly renamed), or delete it.
- Claude Code also saved two memory files outside the repo (its own notes, including one about the no-git rule).
- **Production docs added this session** (Project `claude/` and repo `docs/production/`): `hallasan-exit-note-v0.1.md`, `hallasan-item-names-v0.1.md`. Nothing superseded.
- **Facts verified this session:**
  - Only the 성판악 and 관음사 trails reach 백록담; 영실 and 어리목 stop at 윗세오름 / 남벽분기점.
  - Dead 구상나무 turn white and are spreading on the summit routes.
  - 노루 graze in the 백록담 basin on clear days.
  - Raw 고사리 contains ptaquiloside and thiaminase and must be boiled and soaked.
- **Project docs to clean up** (still pending from Log E §7; deletion is irreversible, so ask first): duplicate logs at the root and in `claude/`, three Hallasan roadmap entries under one path, two copies of DDEOK Dev Decisions v0.1. This log was written to the `claude/` folder of the Project.

---

## 9. Open questions

1. **The build doc** Claude Code wrote (§8).
2. **Trail:** still undecided (roadmap §3). The 고사목 choice keeps it open; 성판악 or 관음사 are the summit options.
3. **봉민수's voice.**
4. **Romanized names** (Sumin, Minsu) anywhere, or Hangul only. 민수 and 수민 use ㅅ, untaught on Hallasan.
5. **The 동철수 cameo** in 수민's note: kept for now.
6. **Writers as monsters** vs. Log B §2 #9.
7. **Quick heal:** who it heals, P2's key.
8. Carried from Log E §9: off-chain carry-over (#2); recipe spec (#3); Fernanda's drops (#4); hint and charm (#5); DDEOK finds beyond piles (#6); who makes the art (#7); captions (#8); and Log D §8 items.

---

## 10. Next steps

| Area | Remaining | Status |
|---|---|---|
| **Animal sightseeing** | Planning session: roadmap §5.2 (spell words that give the 노루 what it needs; the white deer's boss word). No word bank yet. Its scene must call `begin_scene("cutscene_foraging_to_animals")` or the agreed id to apply the pending bank | next |
| **Cutscene** | The user makes it in another session | user |
| **Art direction** | FRONTEND: the graybox is now locked (Log E §8 stage 2). Include the 고사목 doorway, the note, the 수첩's look | 🟡 start |
| **Opening scene** | The missing hotel key and the old lady | unbuilt |
| **Quick heal** | Design, then a small prompt | later |
| **Content** | Native review; word bank v0.2 | pending |

**Also pending:**
1. Fill the 🔍 hashes in §3 with `git log --oneline -30`.
2. Decide on the untracked build doc.
3. Save this log to `docs/logs/hangul-hiking-trip-phase-0-project-log-f.md` and commit it.
4. Clean up duplicate Project docs, after confirmation.
