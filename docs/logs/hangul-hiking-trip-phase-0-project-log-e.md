# Hangul Hiking Trip — Phase 0 Project Log E

*5 November 2026 · Covers sessions from 31 Oct to 5 Nov 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log D (30 Oct)*

> **Read this first in every new session.** Read this log, then Log D, Log C, Log B and Log A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED
>
> **Rule from the user:** any "rule" written in a log is not absolute and may be overridden by the user. Where this log overturns an earlier rule, §2 says so.

---

## 0. Summary

- The Hallasan foraging scene now has **decoy effects, Fernanda's backpack, items, DDEOK, drinking and full-chaos randomness**.
- Prompts **7a, 7b, 7b-ii, 7c, 7d and 7d-ii** were built through Claude Code.
- The headless suite went from 1528 (Log D) to **2717 passed, 0 failed**.
- Every decoy is now a hidden 50:50 harm-or-reward roll. Count, kind, slot and letter are random on every scene start.
- **Not built:** the scene ending, DDEOK payouts for play, Fernanda dropping items, hint and charm effects, stores, cooking and recipes, co-op, audio, and all real art.
- **The user's concern:** with no art yet ("the characters still look like pills"), nobody can judge whether the gore is funny. See §8 for the art staging plan.
- **Next:** design the scene ending (CHAT), build it, then plan animal sightseeing. Start art direction (FRONTEND) in parallel (see §10).

---

## 1. Workflow rules (changes and reminders)

| # | Rule | Status |
|---|---|---|
| 1 | All rules of Log D §1 stand (small split prompts, no git in Claude Code prompts, no editor edits of `project.godot`, close the editor before running the suite, the exact `git add` line after every report) | ✅ |
| 2 | **Screenshots are optional.** Claude Code uses a screenshot only if it genuinely helps it check its own work. Prompts carry no capture requirements. Each prompt ends with a short playtest checklist instead; the user checks the look directly | ✅ |
| 3 | **Content a prompt depends on goes inline in the prompt** (for example gore lines), not "read file X". Prompt 7b failed its gore part because the word bank was only in the Project, not the repo | ✅ |
| 4 | Prompts require: every Godot API checked against the 4.7 docs with the page named; deviations as complete numbered sentences with no gaps; no stray Godot processes left running | ✅ |
| 5 | **Claude does not raise legal, licence or tax matters.** Those belong to the user's lawyer and accountant. Claude stays on game design and development | ✅ user rule |
| 6 | The capture options in `tests/capture.gd` stay in the repo but are not required | ✅ |
| 7 | A low-memory stop happened during 7c while extra game windows and a hung test run were open. Kill hung or stray `Godot_v4.7.2-stable_win64_console.exe` processes before playtesting | ✅ |

---

## 2. Decisions that overturn or change earlier docs

| Earlier item | Was | Now | Status |
|---|---|---|---|
| Log D §5 #2 (no inventory in this game) | No item inventory | **Fernanda's backpack is the inventory.** Tab (P1) or Right Shift / Right Ctrl (P2). Nestor's 망태기 stays letters only | ✅ built |
| Log D §5 #1–2 (which decoy gives which elixir) | Open; then 노루귀 → 쌍화탕, 들쭉나무 → 공진단 suggested | **No fixed pairing.** Every reward roll uses one weighted table (쌍화탕 3, 공진단 1, DDEOK 4) | ✅ built |
| Log B §6 #4–5 (노루귀 gives a slow-time charm, 들쭉나무 a spelling hint) | Fixed rewards per plant | **Removed** from the decoys. Hint and charm exist as items but are not in the reward table yet | ✅ built |
| Log D §5 #3, word bank §4 (two harm kinds, two reward kinds) | 큰천남성 and 붓순나무 always harm; 노루귀 and 들쭉나무 always reward | **Every decoy pick is a hidden 50:50 harm-or-reward roll, whatever its kind.** Every kind has its own gore | ✅ built |
| Word bank §2 (decoy kinds live in zones) | Lower forest, mid slope, alpine | **One shared pool.** Any decoy kind can sit in any slot. Zones remain in the data but placement ignores them | ✅ built |
| Word bank / Log C (2 of each decoy kind, 8 total) | Fixed counts | **2–16 decoys per scene, uniform; each decoy's kind random among the four** | ✅ built |
| Log C spacing (same kind ≥ 4 m apart) | Applied to decoys | **Dropped for decoys.** Still applies to targets. Decoys keep ≥ 2 m from any plant and ≥ 6 m from starts | ✅ built |
| Decoy letters (two of a kind differ) | Fixed per entry | **Random from the target-word jamo set** (ㅁ ㅏ ㅓ ㄹ ㅜ ㅣ ㄴ ㄱ ㅗ ㅅ ㅂ, derived from data) | ✅ built |
| Roadmap §5.4, §6 ("points") | Points earned, banked for Jirisan | **DDEOK and points are the same thing.** "Points" was early brainstorming | ✅ |
| Roadmap §5.4 (cooking reward = points) | Points | **Cooking makes food items** (sellable, or eaten for health or other effects). It may also give DDEOK directly | 🟡 / ❓ |
| Roadmap §0 #11, Log A §3.3 #7 (street market before each mountain from Jirisan) | Street market | **Stores near the accommodation, before the hike, starting with Jirisan.** No store in Hallasan | ✅ |
| Roadmap §6 carry-over (points via shared folder or code) | Points only | **On-chain play carries everything** to Jirisan: food, items, hearts status, DDEOK. Players choose on-chain or off-chain. Off-chain carry-over is ❓ | ✅ / ❓ |
| Log B §6 (Steam as a storefront) | Planned | **Released independently or through Sui.** Steam is dropped if it refuses crypto | ✅ |
| Roadmap §6 Fernanda's forgetfulness (drops tiles as AI partner) | Tiles | **Harm events may make Fernanda drop backpack items**, and either traveler can pick them back up | ✅ idea · unbuilt |

---

## 3. What was built

Repo: `github.com/You-Can-t-Speak-Korean/hangul-hiking-trip-01`. Godot **4.7.2**, GL Compatibility.

| Prompt | What | Tests after | Commit |
|---|---|---|---|
| 7a | Fernanda's backpack: item data, node-free `Inventory`, Tab and Right Shift/Ctrl, a pause-style panel, restore to scene-start contents on death and restart | 1748 | 🔍 not seen |
| 7b | DDEOK item with a code-drawn 백설기 icon; weighted reward roll for reward decoys; ½-heart harm damage to the picker only. Gore not built (word bank missing from repo) | 1827 | 🔍 not seen |
| 7b-ii | Gore beats for 큰천남성 (face swells and pops) and 붓순나무 (convulsions, eyes pop out); gore then death; floating label in front of steam | 1991 | 🔍 not seen |
| 7c | Drinking: select an elixir, Nestor or Fernanda choice (fewer hearts preselected), `heal()`, waste at full hearts, feedback inside the panel | 2214 | 🔍 not seen |
| 7d | Random decoy placement from per-kind slot pools; chaos DDEOK piles; `--placement-seed=N` | 2468 | 🔍 not seen (user confirmed pushed) |
| 7d-ii | Full chaos: shared pool, 2–16 decoys, random kinds and letters, hidden 50:50 outcomes; gore for 노루귀 and 들쭉나무 with captions; slot generator tool | 2717 | 🔍 not seen (commands given) |

**Log D hashes now known** (from the user's `git log`): 6b-iii `011c9f8`, 5e `2a32bff`, 6c `e854a6e`, 6d `4bb433d`, 6e `90fca34`. Still 🔍: 5c, 6a, 6b, 6b-ii. Run `git log --oneline -30` to fill all hashes.

### New files (main ones)

| Path | What |
|---|---|
| `data/series/items.json` | Series-wide item types: ssanghwatang, gongjindan, ddeok, spelling_hint, slow_time_charm |
| `scripts/inventory.gd` | The storage interface (`add`, `remove`, `count`, `items`, `snapshot`, `restore`, `clear`, `changed`). A future on-chain store implements the same methods |
| `scripts/reward_table.gd` | Weighted roll with validation and an injectable random source |
| `scenes/foraging/backpack.gd`, `backpack_hud.gd` | Backpack rules (node-free) and panel, including drinking |
| `scenes/foraging/item_icon.gd` | Code-drawn icons (백설기 for DDEOK) |
| `scenes/foraging/decoy_gore.gd`, `decoy_gore_fx.gd` | Gore state machine and data validation; the placeholder shapes and captions |
| `scenes/foraging/decoy_placement.gd` | Count, kind, slot, outcome and letter rolls (node-free) |
| `scenes/foraging/chaos_piles.gd`, `pile.gd` | Chaos DDEOK piles (node-free) and their visual |
| `tools/generate_slots.gd`, `.tscn` | Slot generator: builds the real scene, samples valid slots, `--write` only on request |
| `tests/forced_rng.gd` | Forced random source for tests and capture |

New data in `data/mountains/hallasan.json`: `backpack_hud`, `decoy_rewards` (floating-label settings included), `decoy_gore` (four entries, `caption_style`, `show_captions`), `decoy_placement` (shared slots, `count_min`, `count_max`, `kind_weights`, `outcome_weights`, `damage_units`), `chaos_piles`.

---

## 4. The foraging scene as built (changes since Log D §4)

### 4.1 Controls

| Player | Walk | Pick / confirm | Backpack | Menu |
|---|---|---|---|---|
| P1 | WASD | Space; mouse | **Tab** | Esc |
| P2 | — (no traveler yet) | Enter or keypad Enter | **Right Shift or Right Ctrl** (left ones do nothing) | Esc (shared) |

- Inside the backpack, both players' movement keys move the highlight and their confirm keys choose. The user confirmed the P2 keys pass.
- Nestor still auto-follows Fernanda. The arrow keys do not move him until co-op exists.
- Tab is read in `BackpackHud._input` before the GUI's focus navigation. It never opens the backpack from the spelling view or pause menu.

### 4.2 Fernanda's backpack
- Opens only when the spelling view, pause menu, gore, death and monster sequences are all inactive. It pauses the map like the pause menu (tree, countdown, vignette, music).
- Esc closes one layer at a time: choice → list → closed. It never opens the pause menu.
- Rows show name_ko (Noto Sans KR), name_en, ×count, a small description, and an icon where defined. Empty state: "Empty".
- **Only elixir rows are selectable.** DDEOK, hint, charm and note rows are view-only.
- **Drinking:** choose Nestor or Fernanda; the one with fewer hearts is preselected (Nestor on a tie). `heal()` applies `heal_units` (쌍화탕 1 = ½ heart, 공진단 2 = 1 heart). At full hearts the elixir is consumed and wasted. Overflow past max is wasted. Feedback is one line inside the panel, since the map is paused.
- **Loot rule:** the backpack restores to its scene-start contents on death and on Restart scene. Items gained in the scene, DDEOK included, are lost. `GameState.new_hike()` clears it.

### 4.3 Decoys (after 7d-ii)
- **Rolled once at every scene start** (first load, death restart, Restart scene), never on pause, backpack or menus: count 2–16 (uniform), each decoy's kind (four kinds, equal weights), its slot from the shared pool of 24, its hidden outcome (harm 1 : reward 1), and its letter.
- The console prints `placement_seed=N`. Running with `-- --placement-seed=N` reproduces the whole layout and all outcomes, also across restarts.
- No visible difference between harm and reward decoys: hover name "???", the same ring, colour, scale and material (tested).
- **Every pick** plays the steam and "tsss" first.
  - **Reward:** roll `decoy_rewards` (쌍화탕 3 · 공진단 1 · DDEOK 4, count 1 each), add the item, and float "+1 …" in front of the steam.
  - **Harm:** `damage_units` 1 (½ heart) to the **picker only**, then that kind's gore beat. While a beat runs, picks, spelling view, pause menu, backpack and walking are blocked, and the countdown pauses. A lethal pick plays the gore first, then the existing death sequence one tick later.
- **Gore by kind** (placeholder shapes in code):
  - 큰천남성 → `face_swell_pop`: the head swells to 3.4× and reddens, then pops into a blood burst and chunks.
  - 붓순나무 → `convulse_eyes_pop`: jitter and tilt, then two eyes with red tails fly out and fall.
  - 노루귀 → `deer_ears_rip` (1.8 s): huge furry roe-deer ears sprout, twitch and swivel, tear off with blood from both sides, and hop away. Caption **노루 귀**.
  - 들쭉나무 → `deulssuk_drunk` (2.0 s): blind-drunk stagger in a circle, hiccups, a purple vomit fountain. Caption **들쭉술**.
  - `show_captions` turns all captions off.
- **Fallback:** bad data or exhausted retries use the eight decoy entries in `plants.placed` with their kinds and letters, with outcomes still rolled.

### 4.4 Chaos DDEOK piles
- 12 slots of their own; at least 4 are ≥ 8 m from every target plant. Count per scene 0 (3) · 1 (4) · 2 (2) · 3 (1); amount 1 (10) · 2 (4) · 3 (2) · 10 (1). Seeded from the placement seed.
- A small code-drawn 백설기 on the ground, with no letter, name, glow or tell. It joins the nearest-pickable logic and the same reach ring. Only the human traveler can pick one. The pick adds the DDEOK and shows "+N DDEOK". No steam, no damage.
- Piles never affect stuck detection, spares, the basket, the discovery list or word completion. They vanish with the loot rule on death or restart and re-roll.

### 4.5 Slot generator
- `godot --headless --path . res://tools/generate_slots.tscn -- [--seed=N] [--step=M] [--count=N] [--write] [--data=PATH]` (use the full console exe path). Defaults: seed 1, step 0.5, count 24.
- It runs as a scene because `-s` mode can't see the autoloads, so the game's `placement_seed` line prints before the JSON.
- It writes nothing without `--write`, and `--write` rewrites only the slots array. Its validity check reports the current 24 slots valid. Closest pair: 2.56 m.

---

## 5. Decided but not built

| # | Decision | Status |
|---|---|---|
| 1 | **DDEOK is awarded for exploration and engagement, plus spontaneity and chaos:** some players simply get lucky and find it lying around. Chaos piles are the first piece | ✅ direction |
| 2 | DDEOK sources: stores (buy and sell), random finds while exploring, selling cooked food (definitely), cooking itself (maybe) | ✅ / 🟡 cooking |
| 3 | **Stores** near the accommodation from Jirisan on. On chain, stores stock items other players sold | ✅ |
| 4 | **Recipes:** food items from combinations of foraged plants and miscellaneous backpack items. Needs a recipe spec | ✅ direction |
| 5 | **On-chain or off-chain play,** chosen by the player. A "claim" button moves DDEOK from a rewards pool to the player's wallet. DDEOK is designed separately from this build | ✅ idea |
| 6 | **Notes** as NFTs in the backpack, holding real information about plants, animals and local history (facts 🔍 when written) | ✅ future |
| 7 | Hint and charm items go in the backpack; their effects and how they're found are not designed | ✅ / ❓ |
| 8 | Fernanda drops backpack items on some harm events; either traveler retrieves them | ✅ idea |
| 9 | A **red backpack** look for the panel | ✅ wish, art pass |
| 10 | More decoy kinds later, with word bank v0.2 (each needs a real plant and verified ecology 🔍) | ✅ future |
| 11 | The game is brutal survival horror: **difficulty** is high; the Korean stays at absolute-beginner level (Claude's reading, not confirmed) | ✅ / 🟡 reading |

---

## 6. Known gaps and deviations

| # | Item | Notes |
|---|---|---|
| 1 | **The gore can't be judged without real art** | All four beats are code primitives on pill-shaped travelers. The user found them fine "for what it is" |
| 2 | **Captions 노루 귀 and 들쭉술 need native-speaker review** | Also the 백설기 / 떡 names and item strings |
| 3 | `Foraging.legacy_layout` and `LEGACY_OUTCOMES` are test-only | Older test sections run with fixed decoys and roles. The game default is false (tested) |
| 4 | `plant.kind` is still `decoy_harm` / `decoy_reward` internally | Set from the rolled outcome; not drawn. Kept for older tests |
| 5 | Extra decoys beyond the data's eight are appended | Keeps legacy and fallback indices stable |
| 6 | Generator margins (0.2 m spacing, 0.5 m starts) are in the tool, not data | Fine for now |
| 7 | 7d hand-replaced four slots after props moved; its original generator was deleted | Fixed by the 7d-ii tool |
| 8 | The drunk stagger wobbles on the spot if its circle can't fit | Rare |
| 9 | `placement_seed` print is not captured by a test | Seen in the console |
| 10 | Mouse picks are tested through `click()`, not real mouse events | User playtests cover it |
| 11 | Backpack overflow scrolling untested | Too few item types to scroll |
| 12 | `new_hike()` clears the backpack | Revisit when loot carries between games |
| 13 | Gore shapes follow a head blob and eye primitives | Re-anchor to model sockets when real models arrive (small rework) |
| 14 | Hint and charm exist as items but can't be found or used | Not in the reward table |
| 15 | Log D §6 gaps not listed here are unchanged | The "tsss" and the stuck music still unheard; trees hide letters; 16:9 only; export untested |

---

## 7. Repo and environment notes

- Paths, Godot location and suite command as Log D §7. The plain exe is still needed for any optional screenshot.
- **Word bank:** the user saved it under `docs/production/` (expected `docs/production/hallasan-foraging-word-bank-v0.1.md` 🔍). It is **untracked**.
- **Untracked, for one separate docs commit:** `CLAUDE.md`, `docs/logs/hangul-hiking-trip-phase-0-project-log-d.md`, `docs/production/`. Before committing, the user adds this line to `CLAUDE.md`: "Never run git add, git commit or git push; the user does all git." Claude Code is told not to edit `CLAUDE.md`.
- `.uid` files: if Godot writes one (for example `tools/generate_slots.gd.uid`), add it with its script.
- ❓ Confirm `reference/` is in `.gitignore`; delete `noto-sans-kr.zip`, `out.txt`, `scripts/.gitkeep` if still there.
- **Project docs to clean up** (deletion is irreversible, so ask first): `claude/hht-project-log-001.md`; duplicate Log C copies; root and `claude/` duplicates of earlier logs. This log was written to the `claude/` folder of the Project.

---

## 8. Art staging plan

The user is nervous about building without graphics. The risk is not wasted code, since the placeholders are separate from the logic. The risk is rework in what depends on model size and shape: collision, camera, traveler scale, attach points and layout.

| Stage | When | What | Status |
|---|---|---|---|
| 1. Art direction | **Now**, in parallel (FRONTEND mode) | Style guide; Nestor and Fernanda concept sheets; Hallasan zone concept; plant reference sheet | 🟡 |
| 2. Graybox lock | After the scene ending | Foraging mechanically complete; scale, camera and layout fixed | 🟡 |
| 3. Technical art spec | Right after the lock | Units and scale, a Blender → Godot 4.7 glTF recipe 🔍, socket names (head, eyes, ears, mouth, hands, back) | 🟡 |
| 4. First production slice | After the spec | Both travelers (rigged, with sockets), the 6 target plants and 4 decoys, a Hallasan terrain kit, the 백설기 icon, the red backpack and the 망태기 | 🟡 |

❓ **Who makes the art: the user in Blender, an artist, or both?** This decides what the technical spec must say.

---

## 9. Open questions

1. **Scene ending:** the end state when all six words are done, the hand-off to animal sightseeing, and DDEOK payouts for play (per word at once, or a total at the end; base, bonus guess, white deer). Lab placeholders were review 10, bonus 30, white deer 100, dish 50.
2. **Off-chain carry-over:** what reaches Jirisan off chain (DDEOK only, or items too), and through the shared folder or the code.
3. **Recipe spec:** dishes per combination of plants and backpack items; what food does when eaten; sale values. Replaces the single 고사리육개장 idea (🔍 dish).
4. **Fernanda's drops:** which events, which items, where they land, and whether a Nestor harm pick triggers it.
5. **Hint and charm:** how they're found and what they do. The charm has little to slow in foraging (only the stuck countdown).
6. **DDEOK random finds beyond piles:** wider pile counts? Finds in other scenes?
7. **Art:** who makes it (§8).
8. **Captions:** keep them? They also teach a word. Native review needed.
9. Carried from Log D §8: per-letter damage targeting (#3); spare hover names (#4); fading props and the side walls (#5); a keyboard key to take a letter back (#6); the steam sound and stuck music (original recordings, #7); white deer folklore 🔍 (#8); tuning (#9); co-op (#10); word bank v0.2 and native review (#12); romanization and subtitle settings (#13); injury persistence, animal-scene damage and 금강초롱꽃 readability (#14).

---

## 10. Next steps

| Area | Remaining | Status |
|---|---|---|
| **Scene ending** | Design in CHAT mode (§9 #1), then one build prompt | ❓ not designed |
| **Animal sightseeing** | Planning session: roadmap §5.2 (spell words that give the 노루 what it needs; the white deer's boss word). No word bank yet | next scene |
| **Art direction** | FRONTEND mode, in parallel (§8) | 🟡 start now |
| **Co-op** | P2 traveler and split screen; the arrows then move Nestor | ❓ |
| **Audio** | Recordings; first listen to the "tsss" and stuck music | unbuilt |
| **Economy** | Recipes, stores (Jirisan), Fernanda's drops, hint and charm | design pending |
| **Content** | Word bank v0.2; native review of all Korean, including captions | pending |
| **Release** | Export presets and a test export | untested |

Suggested order 🟡: scene ending design → scene ending build → animal sightseeing planning, with art direction running alongside.

**Also pending:**
1. Fill the 🔍 hashes in §3 and Log D §3 with `git log --oneline -30`.
2. Add the git line to `CLAUDE.md`, then make the docs commit (§7).
3. Clean up duplicate and superseded Project docs, after confirmation.
