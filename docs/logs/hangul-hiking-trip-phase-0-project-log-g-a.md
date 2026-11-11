# Hangul Hiking Trip — Phase 0 Project Log G-A

*11 November 2026 · Covers planning sessions from 9 to 11 Nov 2026*
*Dev team: 니가 한국어 못해 (NHMH)*
*Previous log: Phase 0 Project Log F (9 Nov)*
*Next log: G-B (the animal sightseeing build)*

> **Read this first in every new session.** Read this log, then Logs F, E, D, C, B and A for everything it doesn't change, then the documents they point to.
>
> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY · ❌ REJECTED
>
> **Rule from the user:** any "rule" written in a log is not absolute and may be overridden by the user. Later logs win over earlier ones. Where this log overturns an earlier rule, §2 says so.

---

## 0. Summary

- **Planning only; no code was built.** The headless suite is unchanged at **3121 passed** (Log F).
- **The animal sightseeing scene (roadmap §5.2) is designed** (§4). It has a walkable map, needs discovered by watching, letters fetched with **tools**, **predators** that hunt animals and attack travelers, a random timer and a **giant brown bear**.
- **New series systems:** breakable **tools** (§5), the **막걸리 아저씨** trail seller (§5.3), animal **thank-you gifts** and **reward tiers** (§4.6).
- **The gore rule changed:** predators now hunt other animals on screen (§2).
- **New production doc:** Hallasan Animal Word Bank v0.1.
- Log F §8 and §9 #1 are resolved: Claude Code's build doc was kept and committed.
- **Next:** MODE: DEV, planning the build prompts for the animal scene.

---

## 1. Workflow rules (changes and reminders)

| # | Rule | Status |
|---|---|---|
| 1 | All rules of Logs E and F §1 stand: prompts under 5 KiB, screenshots optional, content inline, a playtest checklist at the end of each prompt, no docs unless asked, no legal, licence or tax topics | ✅ |
| 2 | **Later logs override earlier brainstorm decisions without ceremony.** Conflicts between an old log and a newer one aren't escalated; the newer one wins | ✅ user rule |
| 3 | Logs may be split **A (planning) / B (build)** when a planning session precedes a big build | ✅ |
| 4 | `git log` opens a pager; press `q`, or use `git --no-pager log --oneline -30` | ✅ |

---

## 2. Decisions that overturn or change earlier docs

| Earlier item | Was | Now | Status |
|---|---|---|---|
| Log A §3.7 #3, Roadmap §0 #15, Word Bank v0.1 §1 #7 (gore never to animals) | Gore only to the travelers | **Predators hunt other animals on screen,** with over-the-top gore. Travelers' tools never hurt animals 🟡 | ✅ |
| Log B §3 (animal scene teaches ㅗ, ㄱ, silent ㅇ) | Three new letters | Foraging already taught ㅗ and ㄱ. **Silent ㅇ is the scene's one new letter** | ✅ |
| Log B §4.2 (letters ride animals ~15 s, caught into the basket) | Catch by hand | Letters ride animals across a **walkable map** with several entry and exit points. They are fetched with **tools** or bare hands at a cost | ✅ |
| Roadmap §5.2 (spell what the 노루 needs) | 노루 only | **Every animal has needs.** Met by spelling a word or giving a backpack item. **One animal can be another's need** | ✅ |
| Roadmap §5.2 (white deer at 백록담) | The scene's monster | **The white deer's boss word stays.** The scene's monster is now a **giant brown bear** | ✅ |
| Log F §4.4 (foraging stuck countdown, 40 s) | Stuck → countdown → monster | Animal scene: stuck players **wait** for more animals. The bear comes only when the **timer ends and words are unfinished** | ✅ |
| Item Names v0.1 (마 = "Chinese yam") | Chinese yam | **Korean yam** (as built since Log C). Item Names v0.2 to follow | ✅ |
| Log F §8, §9 #1 (untracked build doc) | Keep or delete | **Kept** as `docs/production/hallasan-foraging-ending-build-v0.1.md` (`b94a163`) | ✅ |

---

## 3. Commits now known

| Prompt / doc | Commit |
|---|---|
| 5c | `741031e` |
| 6a | `6e8d2ff` |
| 6b | `8bff1ac` |
| 6b-ii | `989a01d` |
| 8a | `7dd8bd0` |
| Docs: exit note v0.1, item names v0.1 | `18693d0` |
| 8b | `da2c324` |
| Docs: Log F | `b2d7660` |
| Docs: foraging ending build notes v0.1 | `b94a163` (HEAD at session start) |

All 🔍 hashes from Logs D–F are now filled.

---

## 4. The animal sightseeing scene (design)

Full content: **Hallasan Animal Word Bank v0.1.**

### 4.1 Core loop ✅
1. Animals cross a **walkable map** through several entry and exit points.
2. Letters ride on the animals. Players fetch them with **tools** (§5) or bare hands.
3. Watching an animal reveals a **need**: an entry with empty blocks appears.
4. A need is met by **spelling the word** or **giving a backpack item** the animal really eats. Inventory choices may carry consequences later.
5. When every word is done, the **exit note** floats in and points to the exit.

### 4.2 Animals and tiers ✅
| Tier | Animals |
|---|---|
| Extinct here | 고라니, 사슴 |
| Endangered | 노루 (game tier), 비바리뱀, 검독수리 |
| Common | 멧돼지, 들개, 큰부리까마귀, 오소리, 제주족제비, 오리 |

Extinct animals are simply **alive, unexplained**.

### 4.3 Timer and the bear ✅
- The timer is random, **6–12 min**. ⏰ **Bring this back after playtests.**
- When the timer ends and the words aren't done, a **giant brown bear** (from Paleolithic 빌레못동굴 bones) kills both travelers, as the white deer does in foraging.
- If the players are stuck early, they **wait** for more animals.

### 4.4 Predators and damage ✅
- Predators: **들개, 멧돼지, 검독수리.** They hunt other animals, and a hunted animal's letter is lost.
- Predator attacks on travelers: **about once every 3 minutes.**
- **1/4 death chance** on predator attacks and on bare-hand grabs of predators. A death kills both travelers.
- Non-lethal hits roll **1 to max half hearts.** Max per animal: ½ ♥ (오리, 족제비, 비바리뱀); 1 ♥ (노루, 고라니, 오소리); 1½ ♥ (사슴, 까마귀); 2 ♥ (검독수리, 들개); 2½ ♥ (멧돼지).
- Bare-hand grabs: ½ ♥ for less dangerous animals, 1 ♥ for more dangerous ones.

### 4.5 Teaching and words ✅ (new feature)
- **Silent ㅇ** is introduced and hinted at by a note from the old lady, 수민 or 민수 (❓ who).
- **Words to spell are first met** in uncollectable notes, or in conversations overheard at the hotel or a store at the start of each game.

### 4.6 Rewards ✅
| Tier | Per need met |
|---|---|
| Common | A thank-you gift + a normal loot roll |
| Endangered | Gift ×2 + a better loot roll + a 도감 entry |
| Extinct here | All of the above + a unique trophy item (NFT candidate) |

Gifts are absurd, and some are tools. For example, the 고라니 **spits** an 어묵꼬치 at the player. The full list is in the word bank §5.1. The **백록담 boss bonus** is deferred until the build starts.

### 4.7 Season ✅
**October.** Male 노루 shed their antlers then (user-supplied cycle 🔍).

---

## 5. New series systems

### 5.1 Tools ✅ (stats 🟡)
- Tools are **items** that take damage and **break**. Each differs in function and durability.
- Hallasan has no store. Tools come from **random loot**, gifts and the seller.
- The list: 어묵꼬치, 집게, 효자손, 잠자리채, 뜰채, 우산, 셀카봉, 등산스틱, 고무장갑. Stats are in the word bank §7.

### 5.2 Getting tools before the scene ✅ / ❓
- Random scenarios, sensible or absurd. For example, the travelers ate 어묵 near the hotel and kept a few 꼬치.
- ❓ More scenarios: the next WRITE pass.
- A **등산스틱** lies near poop and a 막걸리 bottle (동철수's spot 🟡).

### 5.3 The 막걸리 아저씨 ✅
A random trail seller with a 수레 full of 막걸리. He's bright, energetic and friendly. He sells 집게, 우산 and 고무장갑 at ridiculous prices, and 막걸리, which makes you **dizzy and heals ½ ♥**.

---

## 6. Facts verified this session

| Fact | Source |
|---|---|
| 사슴 and 고라니 went extinct on Hallasan; only the 노루 remained | jnuri 2023 |
| 노루: near extinction mid-1980s; pest 2013–2019; ~7,032 culled; 조릿대 crowds out its food | Seoul Shinmun 2019; Dailyvet |
| The Siberian roe deer is IUCN **Least Concern**; not found on Korea's national endangered list | mammaldiversity.org |
| 고라니 is IUCN **Vulnerable** | JERI; Insight |
| 비바리뱀 and 검독수리 are **Class I**; both surveyed at 어리목 | Herald 2026 |
| 검독수리 nest confirmed near Hallasan, the first in 77 years | korea.kr |
| 들개 and 멧돼지 slow the 노루's recovery; boar strand hikers on 성판악 | Kyunghyang 2025; Insight |
| Brown bear and deer bones in **빌레못동굴** (애월) | jeju.guru |
| Diets of 노루, 고라니, 멧돼지, 오소리, 비바리뱀, 큰부리까마귀 | See the word bank §9 |
| User-confirmed: 큰부리까마귀 common on Hallasan; 오소리, 제주족제비 present; 오리 at 백록담; 족제비 and 오리 diets; 비바리뱀 habitat; 노루 antler cycle | 🔍 written sources for 도감 text |

---

## 7. Production docs

| Doc | Status |
|---|---|
| **Hallasan Animal Word Bank v0.1** (`docs/production/hallasan-animal-word-bank-v0.1.md`) | ✅ new |
| Hallasan Item Names v0.1 | To be superseded by v0.2 ("Korean yam") |
| Hallasan Foraging Ending Build v0.1 | ✅ kept (Claude Code's build note) |

Nothing else was superseded.

---

## 8. Open questions

1. **Who writes the silent ㅇ note:** the old lady, 수민 or 민수.
2. **Tool scenarios before the scene** (WRITE).
3. **Needs per run:** how many appear, and how many must be met to finish.
4. **Need entries:** an English hint, a picture, or nothing.
5. **The 백록담 boss bonus** (deferred to the build).
6. **The timer range** (⏰ after playtests).
7. 🔍 The 사슴's diet; 미나리 for 오리.
8. 🟡 노루 as the 들개's need, and 고라니 as the 검독수리's need (in the word bank, flagged as dark satire).
9. Carried from Log F §9: the trail (#2), 봉민수's voice (#3), romanized names (#4), writers as monsters (#6), quick heal (#7), and Log E/D carry-overs.

---

## 9. Next steps

| Area | Remaining | Status |
|---|---|---|
| **Animal sightseeing build** | MODE: DEV. Plan and split the prompts (each under 5 KiB). The scene must call `begin_scene("cutscene_foraging_to_animals")` to apply the pending bank | next |
| **Log G-B** | After the build | after DEV |
| **Cutscene** | The user makes it in another session | user |
| **Content** | Item Names v0.2; the tool scenarios; the silent ㅇ note; the overheard conversations; native review | pending |
| **Art direction** | FRONTEND, when ready | 🟡 |

**Also pending:**
1. Save this log to `docs/logs/hangul-hiking-trip-phase-0-project-log-g-a.md` and commit it.
2. Clean up duplicate Project docs, after confirmation (Log F §8).