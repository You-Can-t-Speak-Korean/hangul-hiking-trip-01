# Hangul Hiking Trip — Phase 0 Project Log A

*22 October 2026 · Covers all sessions from 20–22 October 2026*
*Dev team: 니가 한국어 못해 (NHMH)*

> **Read this first in every new session.** Project logs carry context between sessions. Read the latest log, then the documents it points to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED

---

## 0. What Phase 0 is

✅ **Phase 0 = taste and experiment.** The Master Roadmap's Phase 1 (series foundations) is too large to finish before any production starts. Instead:

- Each Phase 1 item is done **only as deep as *Hallasan* needs**. Other mountains are filled in when their turn comes.
- **Build experiments start in parallel**, to find out what we can actually make before deciding everything.
- Phase 1 is expected to complete gradually, across the whole series.

Logs in Phase 0 are lettered: **A**, B, C…

---

## 1. Workflow rules (permanent)

| # | Rule | Status |
|---|---|---|
| 1 | Roadmaps are **never modified**. They record the original plan. | ✅ |
| 2 | Project logs record what was actually decided and built, and every change from the roadmaps. | ✅ |
| 3 | **Claude never touches the GitHub repo.** No cloning into the session, no attaching, no commits, no pushes, no commits authored in Claude's name. | ✅ |
| 4 | All repo work goes **through the user**. Claude learns what's in the repo from the user. | ✅ |
| 5 | Plans and outlines are discussed **in chat first**. Documents are produced only when asked. | ✅ |
| 6 | Documents are produced as **Markdown (MD)** files. | ✅ |
| 7 | Content is data, not code: a new mountain = new data files, art and audio. | ✅ |

---

## 2. Documents

| Document | Status |
|---|---|
| Hangul Hiking Trip — Master Roadmap (v0.1, 21 Oct) | Frozen record |
| Hangul Hiking Trip: Hallasan — Game Roadmap (v0.1, 21 Oct) | Frozen record |
| Phase 0 Project Log A (this document) | Current |
| `claude/hht-project-log-001.md` (in the Project) | **Superseded and inaccurate.** It describes a build that is not in the repo. Replaced by this log; delete when convenient. |

---

## 3. Series decisions

### 3.1 Format & release
| # | Decision | Status |
|---|---|---|
| 1 | A series of **12 individual games**, *Hallasan* first, *Baekdusan* last | ✅ |
| 2 | All 12 packaged together as the complete game after *Baekdusan* | ✅ |
| 3 | **PC:** each game released as a standalone as soon as it's finished | ✅ |
| 4 | **Phone:** released only as the complete collection, after *Baekdusan* | ✅ |
| 5 | Released independently, **unrated**, completely **open source** | ✅ |
| 6 | Free; players encouraged to **donate to NHMH** | ✅ |
| 7 | Code licence: **AGPL-3.0** (already the `LICENSE` in the repo) | ✅ |
| 8 | Licence for art, music and writing | ❓ |
| 9 | Interface language: **English**. Hoped-for later: Vietnamese, Chinese, Arabic, Russian, Spanish, Italian, Thai | ✅ |
| 10 | Engine: **Godot** | ✅ |
| 11 | Godot **4.7.2** (latest stable on 22 Oct 2026) | 🟡 |

### 3.2 Route & curriculum
| # | Decision | Status |
|---|---|---|
| 1 | About half the mountains in South Korea, half in North Korea | ✅ |
| 2 | First: 한라산. Final: 백두산 | ✅ |
| 3 | 12-mountain route as in Master Roadmap §3 | 🟡 |
| 4 | 태백산 vs 북한산 and the final North Korean picks are decided later, with context from earlier builds | ✅ (deferred) |
| 5 | Each mountain introduces new Hangul; letters per mountain as in Master Roadmap §4 | 🟡 |
| 6 | Foraged plants must **actually grow on that mountain**; their names **hopefully** use that mountain's letters (a hope, not a rule) | ✅ |
| 7 | The curriculum decides which letters each mountain teaches; plants are chosen to fit | ✅ |
| 8 | North Korean spelling trap from 금강산 on | 🟡 |

### 3.3 Scenes
| # | Decision | Status |
|---|---|---|
| 1 | Four scenes per mountain: **foraging → animal sightseeing → disaster survival → camp cooking** | ✅ |
| 2 | **Foraging:** collect letters from real plants and combine them; learn plant names. Practice over explanation | ✅ |
| 3 | **Animal sightseeing:** build whole words that give an endangered or extinct animal something that improves its life | ✅ |
| 4 | Each animal scene has a **folklore 괴물**; catching it is worth the most points | ✅ |
| 5 | **Disaster:** English word in, Korean out, before the disaster hits. The disaster fits what is most likely on that mountain (landslide, mudslide, avalanche, eruption…) | ✅ |
| 6 | **Camp cooking:** combine foraged words into a real regional dish. Rewards **points** | ✅ |
| 7 | **Street market** before every mountain **except *Hallasan***, where points are spent like money on gear | ✅ |
| 8 | Market reading as a Hangul exercise; regional markets (e.g. a 오일장 near Jirisan, a 장마당 in the North) | 🟡 |
| 9 | Gear makes things easier but is never required (e.g. a helmet absorbs one hit, poles add time) | 🟡 |

### 3.4 Protagonists
| # | Decision | Status |
|---|---|---|
| 1 | **Nestor and Fernanda**: foreign travelers from **unknown countries** who **look Korean** but aren't | ✅ |
| 2 | **Nestor:** serious, monotone; long-winded, absurd excuses for anything that goes wrong | ✅ |
| 3 | **Fernanda:** outgoing, energetic, very positive; constantly loses items and forgets things | ✅ |
| 4 | Neither likes hiking. Every game opens with a random circumstance that forces them up a whole mountain | ✅ |
| 5 | Every game: Fernanda — "Why don't we learn Hangul since we are in Korea and need to hike this mountain?" Nestor — "Ok, whatever." Then foraging begins | ✅ |
| 6 | Running gag: Koreans keep firing rapid Korean at them, assuming they understand | 🟡 |
| 7 | Series arc: they swear never to hike again; at Baekdusan they choose to climb | 🟡 |

### 3.5 Players & controls
| # | Decision | Status |
|---|---|---|
| 1 | Solo: the player **chooses** Nestor or Fernanda; the other is the **AI partner** | ✅ |
| 2 | Two-player: **local co-op**. Online co-op if feasible | ✅ / ❓ online |
| 3 | Controls: mouse click on PC, touch on phone. Letters are **tapped and dragged** | ✅ |
| 4 | Difficulty: **Easy · So So · Diffifuckingcult** — changes speed and time limits only | ✅ |

### 3.6 Hearts, death & scoring
| # | Decision | Status |
|---|---|---|
| 1 | Health is **hearts**. *Hallasan*: **5 each** | ✅ |
| 2 | Full hearts **only at the start of the hike**; no refills between scenes | ✅ |
| 3 | Every wrong or too-slow answer: lose a heart **with gory damage** | ✅ |
| 4 | If one traveler dies, **both die**: the dead one dies gorily, then by chance the 괴물 appears and eats the survivor | ✅ |
| 5 | If death happens before the 괴물 is introduced (foraging), the 괴물 appears early anyway, as foreshadowing | 🟡 |
| 6 | Death **restarts the current scene** with the hearts held at the start of that scene | ✅ |
| 7 | **Guessing is part of the game:** correct guesses on unseen words earn **bonus points**; review words earn fewer | ✅ |
| 8 | A wrong guess gets the **same full brutal carnage** as any wrong answer | ✅ |
| 9 | Point values and timer lengths | ❓ |
| 10 | **Carry-over:** points move to the next game. PC: one shared save folder for the series. Fallback: a **carry-over code** shown at the end of each game | ✅ |
| 11 | Players with no save start a later game with a default amount of points | 🟡 |

### 3.7 Gore & tone
| # | Decision | Status |
|---|---|---|
| 1 | Over-the-top, laughable gore: **Evil Dead 2, Re-Animator**. Rock to the neck → blood spurting everywhere | ✅ |
| 2 | Injury examples: pummeled by a rock, maimed by a bear, a limb lost to a tiger, an eye lost to a branch | ✅ |
| 3 | Gore happens **only to Nestor and Fernanda**, never to animals or plants (may be revisited) | ✅ |
| 4 | Edutainment for adults, not gentle: "Guess the wrong word and get Jason's machete" | ✅ |

---

## 4. Art direction

| # | Decision | Status |
|---|---|---|
| 1 | Not 1960s-style retro. **Mid-to-late 90s** feel, with real visuals | ✅ |
| 2 | Look **unique**, as good as possible, **while vintage** | ✅ |
| 3 | Choose the **least burdensome and most convenient** option that still looks good | ✅ |
| 4 | Production reality: **solo with AI, no budget** → keep each game's art small (few characters, reuse) and use 3D | ✅ |
| 5 | **Art direction: live 2.5D.** Low-poly 3D models seen from the side, shown live in Godot | ✅ |
| 6 | Vintage look via low-poly models, limited-colour textures, low-resolution rendering scaled up sharply, no texture smoothing; optional PS1 touches (vertex wobble, dithering). Reference: Klonoa (1997) | 🟡 |
| 7 | **Hybrid option:** background layers may be pre-rendered for an Oddworld-style rich look, with characters, animals, lava and gore kept live (as Resident Evil, 1996, did). Decided per scene | ✅ (option) |
| 8 | Gore in 2.5D: limbs and heads are separate model pieces that detach; blood as lit particles; physics so deaths vary | 🟡 |
| 9 | Hallasan palette: black basalt, green crater lake, tangerine orange, lava red | 🟡 |

**Styles considered and rejected:**
| Style | Example | Why not |
|---|---|---|
| Hand-drawn pixel art | Blasphemous, Metal Slug | Every frame hand-drawn; not realistic solo with no budget |
| 3D rendered to pixel art | Dead Cells | Render and clean-up step for every change |
| Pre-rendered 3D (as the main style) | Oddworld | Re-render for every change; deaths play the same way every time; large files. Kept as the background hybrid |
| Silhouette | Limbo | Loses faces (Nestor's deadpan) and Korean colour |
| Painted | Ori and the Blind Forest | Very heavy |

**Tools:**
- **Blender** for models. The user is new to Blender.
- **Blender MCP server** (Blender Lab) is an option: requires Blender 5.1+, installs as an `.mcpb` bundle (Claude's desktop app supports it), runs AI-written code in Blender with **no safeguards** — use a separate project folder and backups. Best treated as a helper, not a modeller. 🟡
- **Mixamo** for auto-rigging and base animations. 🔍 Licence: rendered results should be fine; raw animation files may not be allowed in a public open-source repo.

---

## 5. *Hallasan* decisions

| # | Decision | Status |
|---|---|---|
| 1 | Game 1 of 12; pilot and tutorial | ✅ |
| 2 | Scenes: foraging, animal sightseeing, **volcano eruption**, camp cooking | ✅ |
| 3 | Opening: locked out of the hotel; the janitor dropped the only key at the summit | 🟡 (the example given) |
| 4 | 괴물: the **white deer of 백록담** | ✅ |
| 5 | Animal: **노루** (Jeju roe deer) | 🟡 🔍 |
| 6 | Letters: ㅏ ㅓ ㅗ ㅜ ㅡ ㅣ, silent ㅇ, ㄱ ㄴ ㄹ ㅁ; no 받침 | 🟡 |
| 7 | Plant candidates: 머루, 미나리 (review); 고사리, 시로미, 구상나무 (bonus) | 🟡 🔍 |
| 8 | Eruption twist: the English prompt is the body part about to be hit (head → 머리) | 🟡 |
| 9 | Dish: 고사리육개장 | 🟡 🔍 |
| 10 | Ending: Fernanda has lost the key | 🟡 |
| 11 | Camping is illegal on Hallasan; Nestor explains why it doesn't count | 🟡 🔍 |

---

## 6. Build experiments so far

**Repo:** `github.com/eth4nh4rdy/hangul-hiking-trip-01` — contains the initial commit with the AGPL-3.0 licence. **Nothing else from Claude is in it.**

**Claude's exploratory build (22 Oct)** exists **only in Claude's workspace**. It was sent as a git bundle, which **should not be applied** because it carries a commit in Claude's name. If wanted, it can be sent as plain files for the user to review and commit. It contains:

- A Hangul engine: composes letters into syllable blocks; decides from the curriculum whether a word is a review word or a bonus guess.
- Curriculum, rules and *Hallasan* word banks as data files.
- Game state: hearts, both-die rule, scene restart, points, shared save folder, carry-over code (`HHT-XXXX-XXXX`).
- A gray-box "tile lab" of the eruption scene with drag-and-drop letters and placeholder blood. **Its art is not the art direction.**

**Findings from it:**
- 🔍 **금강초롱꽃 is not fully readable on 금강산.** The ㅊ under 꽃 isn't taught until 묘향산. Decide when planning 금강산.
- The draft curriculum covers all 19 initial consonants, 21 vowels and 27 받침 by 백두산.
- Ideas worth keeping 🟡: consonant and vowel tiles in different colours; answers checked only when the player presses GO, so trial and error can't beat the timer.

---

## 7. Phase 1 status, at *Hallasan* depth

| # | Item | Status | Next |
|---|---|---|---|
| 1 | Series bible | Decided in chat; not written | **Discuss next** |
| 2 | Curriculum map | Draft | **Discuss next** |
| 3 | Mountain bible | Not started | Hallasan research only |
| 4 | Scene templates | Concepts only | **Discuss next** |
| 5 | Scoring & damage spec | Mostly decided | **Discuss next** |
| 6 | Gore style guide | Ideas only | After the style test |
| 7 | Art, audio & UI style guides | Art direction decided | Style test |
| 8 | Tech decisions | Mostly decided | Co-op setup |
| 9 | Licensing | Code done | Asset licence |

---

## 8. Open questions

1. Licence for art, music and writing.
2. Point values and timer lengths.
3. AI partner behaviour: how it helps, hinders and takes damage.
4. Fernanda's forgetfulness as a mechanic (e.g. the AI partner drops collected tiles).
5. Online co-op: feasible or not.
6. Standalone games vs a cumulative curriculum: what happens when a player starts on a later game.
7. Whether the no-gore-for-animals rule ever changes.
8. Release cadence between games.
9. Mixamo licence for an open-source repo.
10. Blender MCP: use it or not.
11. A pixel/3D artist collaborator later, possibly funded by donations.
12. Hosting and donation methods.
13. Localization order.
14. Team roles; crossover with Noraebang Night.

---

## 9. Next steps

1. **Discuss in chat:** series bible, curriculum map, scoring & damage spec, scene templates — each at *Hallasan* depth.
2. **Art style test:** the lava bomb at 백록담 in live 2.5D, with Nestor and Fernanda.
3. Hallasan research checklist (Hallasan Roadmap §9).
