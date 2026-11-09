# Hangul Hiking Trip: Hallasan — Foraging Ending, Build Record v0.1

*9 November 2026 · Production doc (versioned) · Prompt 8b*
*Parent documents: Hallasan Exit Note v0.1; Phase 0 Project Log E §9 #1 (scene ending); foraging ending design (CHAT, 7 Nov 2026)*
*Dev team: 니가 한국어 못해 (NHMH)*

> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY
> This page records what Prompt 8b **built**. All numbers and texts live in `data/mountains/hallasan.json` → `foraging.ending`; all of them are 🟡 placeholders.

---

## 1. What happens, in order

| Step | What the player sees | Where it lives |
|---|---|---|
| 1 | The sixth word is done (any order). "+2 시로미" floats as before. | `foraging.gd` `_on_word_completed` → `_open_exit()` |
| 2 | The 고사목's gap opens: its barrier branch tips over and goes. The countdown can no longer start; leftover decoys and chaos piles stay live. | `dead_tree.gd`, `evaluate_stuck` |
| 3 | 1.5 s later (`note_delay_s`) a cream paper quad flutters in from off the right edge over 5 s (`flight_s`) and lands 1.5–3 m from Fernanda. | `ending.gd` (rules), `exit_note.gd` (look) |
| 4 | Space picks it (nearest-target logic and reach ring, no name, no glow). "+1 note" floats; 수민's note is the newest page of the 수첩 (Q). | `picking.gd` `add_note`, `pick_note()` |
| 5 | Fernanda walks through the gap into the trigger: input stops, the screen fades to black over `fade_s` (1.0 s). | `_begin_exit()`, `ending_hud.gd` |
| 6 | The pending bank (backpack, hearts, DDEOK) and the target id `cutscene_foraging_to_animals` are stored in `GameState`. | `game_state.gd` `store_pending_bank` |
| 7 | The target is not built, so the screen **holds on black** with "next: cutscene_foraging_to_animals (not built)" bottom left. Esc opens the pause menu over it. | `_exit_faded()` |

A death or Restart scene removes the note, shuts the exit, lifts the black and **discards** the pending bank; the scene restarts from its own scene-start snapshot, so nothing is duplicated.

## 2. The bank

`GameState.pending_bank` = `{units, ddeok, inventory, target}`. It is applied **only** by `begin_scene(id)` when `id` equals its target; that makes it the new scene's start snapshot. Another scene's `begin_scene` leaves it alone; `new_hike()` and Restart scene drop it. Until then the current scene's own snapshot is untouched.

## 3. Placement

- 고사목 at **(64.0, −7.0)**, on the stage's far right (uphill) edge, 3.2 m from the nearest 구상나무 (63, −4). Gap 2.2 m wide along z, centred on the tree. Walkable strip beyond it runs to x = 67; the exit trigger is x 65.2–67.
- The edge is `walk_bounds()` (x ≤ 63.6). While the gap is shut it is a wall everywhere; once open, `Traveler.gap` lets a traveler through it only inside the gap's z range.
- Props are kept 1.8 m clear of the whole strip (keep-out points), so no rock stands in the doorway.
- The note lands on ground ≥ 1.0 m inside the walk limits, ≥ 1.5 m from every plant and pile, ≥ 0.6 m from every prop box and ≥ 3.0 m from the 고사목. If the 1.5–3 m ring has no such ground (a traveler cornered behind firs) the clearances relax (`note.relaxed`); only if that fails too does it land in the open.
- If the traveler walks out of range while it flies, it is re-aimed from where it is (never jumps) and still lands in range.

## 4. Keys

`notebook_p1` moved from **N to Q** (Q was unused). `notebook_p2` stays `/`. N is bound to nothing.

## 5. Deviations from the brief

1. "After its +2 float" is read as: `note_delay_s` counts from the moment the word completes (when the float starts), and only while the map runs, not from the float's end.
2. The note cannot be click-walked to; Space (and the reach ring) only, as the brief lists.
3. When no clear ground exists in range, a relaxed second pass is used (§3); the brief had no fallback.
4. The 고사목's two trunks and barrier are rough primitives, seen end-on from the camera; art direction has not looked at them. 🟡

## 6. Tests

Nine sections (`test_ending_*` and `test_pending_bank`, 143 checks): data, logic with no nodes, keys, the note (delay, flight, pauses, landing, pickup, death), the follow-the-traveler re-aim, 24 landings over 3 layouts × 8 places, the exit (blocked, open, fade, bank, hold, Esc, Restart, built target), and leftovers after completion (decoys, piles, no stuck countdown).
