# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

*Hangul Hiking Trip: Hallasan* — first of a planned series of 12 Godot games (one per Korean mountain) that teach Hangul through comedy-gore survival. Godot 4.7, GL Compatibility renderer, GDScript, 3D gray-box. Licence AGPL-3.0.

Design documents live in `docs/`: `roadmaps/` hold the original plan and are **never modified**; `logs/` record what was actually built and every deviation from the roadmap. Check the logs (not the roadmap) for the current state of decisions. Currency is **DDEOK** (not "points"); point values and timers in data files are placeholders.

## Commands

Godot is not on PATH; use your local Godot 4.7 executable as `godot` below.

- Run the game: `godot --path .` (main scene is `scenes/foraging/foraging.tscn`)
- Run all tests (headless, exits 1 on failure): `godot --headless --path . res://tests/test_runner.tscn`
- There is no per-test selector; edit `_ready()` in `tests/test_runner.gd` to run a subset. Tests use a custom `check(condition, label)` helper.
- Screenshots of the foraging map (needs a display): run `res://tests/capture.tscn`; output goes to `tests/shots/` (gitignored).

## Architecture

Four autoloads (see `project.godot`) hold all cross-scene logic; scenes stay thin:

- `Hangul` (`scripts/hangul.gd`) — compose/decompose syllables, letter tokens, review-vs-bonus word checks. Letter tokens in data: `"ㄱ"` = initial consonant or any vowel, `"-ㄱ"` = 받침 (final).
- `Content` (`scripts/content.gd`) — loads JSON data and answers "which letters are known at game N".
- `GameState` (`scripts/game_state.gd`) — hearts (5 each, no refills), the both-die rule (one traveler at 0 hearts kills both), scene restart restoring hearts/DDEOK from scene start, DDEOK carry-over between games.
- `Settings` (`scripts/settings.gd`) — romanization and English-subtitle toggles, persisted via `setting_changed` signal. Custom user dir is `NHMH/HangulHikingTrip`.

**Data-driven mountains:** every game is data, not code. `data/series/curriculum.json` (letters taught per game), `data/series/rules.json` (hearts, difficulty time scales), and `data/mountains/<id>.json` (per-mountain words and per-scene config, e.g. the `foraging` stage size, apron, props, start positions). A new mountain = a new JSON file plus art/audio.

**Foraging scene** (`scenes/foraging/`): `foraging.gd` builds the ground, backdrop and props procedurally from the mountain JSON; `traveler.gd` is the `CharacterBody3D` used for both travelers (player via `p1_*`/`p2_*` input actions, partner follows as AI). Coordinates: x along the stage (0..width), z depth, 1 unit = 1 m; orthographic camera pitched down with a two-axis follow.

`reference/` is gitignored exploratory code to port from (and outdated in places); never commit it.
