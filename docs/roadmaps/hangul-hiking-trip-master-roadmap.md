# Hangul Hiking Trip — Master Roadmap

*Version 0.1 · Drafted 21 October 2026*
*Dev team: 니가 한국어 못해 (NHMH)*

> **How to read this document**
> - ✅ **DECIDED** — locked in. Change only by deliberate team decision.
> - 🟡 **SUGGESTED** — first ideas, to be decided in session.
> - ❓ **OPEN** — needs a decision before production on that area begins.
> - 🔍 **VERIFY** — factual detail to confirm during research.
>
> **Document rules**
> - This roadmap is the record of the original plan for Hangul Hiking Trip. **It is never modified.**
> - What is actually built, and every change from this plan, is recorded in the **project logs**, which also carry context between sessions.
> - Each game in the series gets its own roadmap, starting with **Hangul Hiking Trip: Hallasan**.

---

## 0. Decision Log

| # | Decision | Status |
|---|---|---|
| 1 | Comedy-gore survival game for learning Hangul | ✅ |
| 2 | A series of **12 individual games**, one per mountain, from *Hangul Hiking Trip: Hallasan* to *Hangul Hiking Trip: Baekdusan* | ✅ |
| 3 | After the final game, all 12 are packaged together as the complete game | ✅ |
| 4 | Route: about half the mountains in South Korea, half in North Korea | ✅ |
| 5 | Two protagonists: foreign travelers who never meant to hike, repeatedly forced to climb whole mountains by random circumstances | ✅ |
| 6 | Solo play: the second traveler is an **AI partner** | ✅ |
| 7 | Two-player: **local co-op**. Online co-op if feasible | ✅ / ❓ online |
| 8 | Controls: mouse click on PC, touch on phone. Letters are **tapped and dragged** | ✅ |
| 9 | Each mountain introduces new Hangul | ✅ |
| 10 | Four scenes per mountain: **foraging, animal sightseeing, disaster survival, camp cooking** | ✅ |
| 11 | Each animal sightseeing scene includes a folklore **괴물**; catching it is worth extra points | ✅ |
| 12 | Wrong or too-slow answers cause over-the-top, silly gore (Evil Dead 2 / Re-Animator style) | ✅ |
| 13 | Each traveler has **3 or 5 hearts** | ✅ / ❓ number |
| 14 | Gore happens **only to the two travelers**, never to animals or plants (may be revisited) | ✅ |
| 15 | Guessing unseen words is part of the game: correct guesses earn bonus points; review words earn fewer | ✅ |
| 16 | Difficulty: **Easy · So So · Diffifuckingcult** — changes speed and time limits only | ✅ |
| 17 | Engine: **Godot** | ✅ |
| 18 | Interface language: **English** at launch | ✅ |
| 19 | Released independently, **unrated**, completely **open source** | ✅ |
| 20 | Free to play; players are encouraged to donate to NHMH | ✅ |
| 21 | Visual style: 2D pixel art | 🟡 |
| 22 | Route: 12 mountains (§3) | 🟡 |

---

## 1. Vision & Pillars

### Elevator pitch
Two travelers came to Korea for the food. They keep getting stranded on mountains. The only way out is up, and the mountain is throwing Hangul at them.

### Pillars
1. **Hangul is survival.** Every letter the player learns is used to dodge, forage, help an animal or escape. The Korean always *does* something.
2. **Practice over explanation.** Players learn by collecting and combining letters, not by reading lessons.
3. **Failure is the punchline.** Wrong answers are gruesome, ridiculous and memorable.
4. **Fortune favours the bold.** Guessing words you haven't learned yet is risky and rewarded.
5. **Korea, mountain by mountain.** Real peaks, real plants, real wildlife, real folklore.
6. **Edutainment for adults.** Not a gentle course. A party game you happen to learn from.

### Target players
- **Primary:** adults who are absolute beginners in Hangul.
- **Secondary:** K-culture fans, people planning a trip to Korea, friends and couples who want a co-op game.

### What makes it distinctive
- The curriculum *is* the map. Finish the trip and you can read Korean.
- Mountain names, plant names and disaster words become readable as the trip goes on (e.g. 한라산 is pronounced [할라산], taught on mountain 11).
- The gore tells you exactly what you got wrong.

---

## 2. Protagonists

### Fixed facts ✅
- Two foreign travelers. Neither planned to hike.
- Each mountain begins with a random circumstance that makes climbing it unavoidable.
- In solo play the player controls one traveler; the other is an AI partner. In two-player, each player controls one.
- Each has their own hearts.

### Suggestions 🟡 (decide in session)
- **A contrasting pair:** one over-prepared, one hopelessly unprepared. Or one who blames everyone else, one who blames themselves.
- **Different home countries and languages**, so wrong guesses can be gags rooted in their own languages.
- **Names:** TBD. Possibly names Korean characters mangle in Hangul, which pays off once the player can read them.
- **Series arc:** after every mountain they swear never to hike again. At Baekdusan, they choose to climb.

### The "why are we hiking again?" engine 🟡
Each game opens with a fresh emergency. Recurring patterns:
- Something precious goes up the mountain without them (phone, passport, parcel, a friend).
- A misread Korean sign, bus destination or tour flyer.
- A Korean 등산 club adopts them and will not take no for an answer.
- An animal steals something.

---

## 3. The Route 🟡 🔍

Twelve mountains, south to north, crossing the DMZ at mountain 7. Starts and ends on a volcano.

| # | Game | Region | Why it's on the route |
|---|---|---|---|
| 1 | **Hallasan** 한라산 | Jeju | Volcano; 구상나무, 시로미; tutorial island |
| 2 | **Jirisan** 지리산 | South | 반달가슴곰 restoration; Korea's great foraging mountain |
| 3 | **Sobaeksan** 소백산 | South | Red fox (여우) restoration |
| 4 | **Woraksan** 월악산 | South | Long-tailed goral (산양) restoration |
| 5 | **Taebaeksan** 태백산 | South | 단군 shrine (천제단); 주목 forests |
| 6 | **Seoraksan** 설악산 | South | Most dramatic peak; avalanche terrain; 산솜다리 |
| 7 | **Geumgangsan** 금강산 | North | Just over the DMZ; 금강초롱꽃 |
| 8 | **Guwolsan** 구월산 | North | West coast; 단군 legend site |
| 9 | **Myohyangsan** 묘향산 | North | Famous temples, deep forest |
| 10 | **Chilbosan** 칠보산 | North | Coastal volcanic rock formations |
| 11 | **Gwanmobong** 관모봉 | North | Korea's second-highest peak; alpine zone |
| 12 | **Baekdusan** 백두산 | North | Volcano finale; 천지 monster; tiger and leopard territory |

❓ Judgment calls deferred to later sessions, once early games are built:
- 태백산 vs 북한산 (Seoul, more famous, bends the path west).
- Final North Korean selection, depending on available data.

---

## 4. Hangul Curriculum 🟡

### Rule
Each game introduces new letters. Words built from letters taught so far are **review words**. Words using letters not yet taught are **bonus guesses**.

### Letters by mountain

| # | Mountain | New letters / skill | Hoped-for word match 🔍 | Disaster |
|---|---|---|---|---|
| 1 | 한라산 | ㅏ ㅓ ㅗ ㅜ ㅡ ㅣ, silent ㅇ, ㄱ ㄴ ㄹ ㅁ | 머루, 미나리 | Volcano |
| 2 | 지리산 | ㄷ ㅂ ㅅ ㅈ ㅎ | 고사리, 도라지 | Landslide |
| 3 | 소백산 | ㅑ ㅕ ㅛ ㅠ | 여우 (the fox itself) | Gale winds |
| 4 | 월악산 | First 받침: ㄱ ㄴ ㄷ ㄹ ㅁ ㅂ ㅇ | 더덕 | Rockfall |
| 5 | 태백산 | ㅋ ㅌ ㅊ ㅍ | 참나물 | Blizzard (눈보라) |
| 6 | 설악산 | ㅐ ㅔ ㅒ ㅖ | 얼레지 | Avalanche (눈사태) |
| 7 | 금강산 | ㄲ ㄸ ㅃ ㅆ ㅉ | 금강초롱꽃 | Rockfall |
| 8 | 구월산 | ㅘ ㅝ ㅟ ㅢ | 취나물 | Landslide |
| 9 | 묘향산 | ㅚ ㅙ ㅞ + remaining 받침 | Mushrooms (버섯) | Flash flood |
| 10 | 칠보산 | Double 받침 + linking (연음) | 칡 | Typhoon |
| 11 | 관모봉 | Sound-change rules (비음화, 유음화, 경음화, 구개음화) | 만병초 | Blizzard |
| 12 | 백두산 | Everything, top speed | 들쭉 | Eruption (화산) |

### Plant-name principle
Foraged plants must **actually grow on that mountain** ✅, and **hopefully** use that mountain's letters 🟡. The match is a hope, not a requirement.

### North Korean spelling trap 🟡
From 금강산 on, signs may use North Korean spelling (e.g. 로동 for 노동), creating real guessing hazards.

---

## 5. The Four Scenes

Every mountain runs the same four scenes, from easiest to hardest. The curriculum lives in which letters are in play.

| # | Scene | Exercise | What the player does |
|---|---|---|---|
| 1 | **Foraging** | Collect and combine | Letters fall from real plants as collectibles. The player snaps them into syllable blocks and discovers which plant names they can spell. |
| 2 | **Animal sightseeing** | Build words with meaning | Spell whole words to give an endangered or extinct animal what it needs (e.g. 물, 집, 먹이), helping reverse its decline. |
| 2+ | **괴물 encounter** | Harder word, bigger reward | A folklore monster appears during the animal scene. Catching it is worth the most points. |
| 3 | **Disaster survival** | English in, Korean out | An English word flashes up; the player builds the Korean from tiles before the disaster hits. The disaster fits what is most likely on that mountain. |
| 4 | **Camp cooking** | Combine foraged words | Survivors cook what they foraged into a real regional dish. Rewards: 🟡 hearts or similar, brainstormed later. |

---

## 6. Core Systems

### 6.1 Hearts & damage ✅
- Each traveler has **3 or 5 hearts** ❓.
- Wrong answer or timeout → lose a heart, with gore.
- 0 hearts → death → ❓ retry rules (scene restart, mountain restart).

### 6.2 Gore ✅
- Over-the-top and laughable: Evil Dead 2, Re-Animator.
- Examples: pummelled by a rock, mauled by a bear, a limb lost to a tiger's jaws, an eye lost to a tree branch, a rock to the neck with blood spurting everywhere.
- Every injury comes from that mountain's world: its rocks, branches, weather and animals.
- **Only the travelers get hurt.** Animals and plants are never harmed.

### 6.3 Scoring 🟡
| Answer | Points |
|---|---|
| Review word | Base points |
| Correct bonus guess (unseen word) | Bonus points |
| 괴물 capture | Highest points |
| Wrong answer | Heart lost + gore |

### 6.4 Difficulty ✅
| Level | Effect |
|---|---|
| Easy | Slowest speed, widest time limits |
| So So | Medium |
| Diffifuckingcult | Fastest speed, narrowest time limits |

### 6.5 Input ✅
- Tap and drag letter tiles into syllable blocks.
- All targets large enough for phone screens.

### 6.6 AI partner & co-op
- Solo: AI partner controls the second traveler ✅. ❓ How it helps, hinders or gets hurt.
- Two-player: local co-op ✅. Online co-op ❓ if feasible.

---

## 7. Build Plan

### Phase 1 — Series foundations (once, for all 12 games)
1. **Series bible:** premise, tone, travelers, the "why are we hiking again?" engine.
2. **Curriculum map:** final letters per mountain, review-word and bonus-guess rules.
3. **Mountain bible:** route, plants, animals, 괴물, disaster and dish per mountain, all flagged 🔍.
4. **Scene templates:** exact rules for the four scenes and the 괴물 encounter.
5. **Scoring & damage spec:** hearts, points, death and retry, cooking rewards.
6. **Gore style guide:** injury list, blood effects, comic timing.
7. **Art, audio & UI style guides.**
8. **Tech decisions:** Godot version, PC vs phone priority, local co-op architecture with room for online later.
9. **Licensing setup:** open-source licences for code and assets (❓ which licences).

### Phase 2 — Core engine (shared code for every game)
1. Letter-tile tap and drag; syllable-block assembly.
2. Word checking against each mountain's word bank.
3. Timers and the three difficulty levels.
4. Hearts, damage, death and the gore system.
5. AI partner and local co-op.
6. Save system and score tracking.
7. Translation-ready text pipeline (including right-to-left support for Arabic later).
8. **Content as data:** a new mountain = new data files, art and audio, not new code.

### Phase 3 — Prototype & playtest
1. One rough scene of each type, placeholder art.
2. Playtest with real Hangul beginners.
3. Adjust controls, timers and difficulty before building content.

### Phase 4 — Game 1: *Hangul Hiking Trip: Hallasan*
- Planned in its own roadmap.
- First full release; proves the whole pipeline.
- **Post-release checkpoint:** platform priority, 3 vs 5 hearts, online co-op feasibility, release cadence.

### Phase 5 — The per-mountain cycle (games 2–12)
Each game repeats these steps:
1. Write the game's own roadmap.
2. Research and verify plants, animals, 괴물, disaster and dish.
3. Build word banks from the curriculum letters.
4. Design the four scenes and the 괴물 encounter.
5. Create art, audio and gore assets.
6. Build, playtest and get native-speaker Korean review.
7. Release.
8. Record lessons in the project logs.

### Phase 6 — Series milestones
| Milestone | After | Review |
|---|---|---|
| Southern half complete | Game 6: Seoraksan | Curriculum pace, scope, player feedback |
| Crossing the DMZ | Game 7: Geumgangsan | North Korean data, spelling trap |
| Series complete | Game 12: Baekdusan | Package the complete collection |

### Phase 7 — Complete collection
All 12 games packaged together as the complete Hangul Hiking Trip.

### Phase 8 — Localization
Hoped-for languages: Vietnamese, Chinese, Arabic, Russian, Spanish, Italian, Thai. ❓ Order and timing.

---

## 8. Release & Distribution

- Released independently ✅.
- Unrated ✅. 🟡 A content warning screen that informs, without apologizing.
- Completely open source ✅. ❓ Licences for code and for art, music and writing.
- Free, with donations to NHMH encouraged ✅. ❓ Donation methods.
- ❓ Where it's hosted and downloaded (own website, itch.io, GitHub, app stores).

---

## 9. Open Questions & Uncertainties

1. **Standalone games vs a cumulative curriculum.** A player who starts at Seoraksan hasn't learned games 1–5. Catch-up warm-up, skip option, or required order?
2. PC or phone first.
3. 3 or 5 hearts, and whether it depends on difficulty.
4. Death and retry rules.
5. Online co-op: feasible or not.
6. AI partner behaviour.
7. Cooking rewards.
8. Whether the no-gore-for-animals rule ever changes.
9. Release cadence between games.
10. 태백산 vs 북한산; final North Korean mountains.
11. North Korean content data and the spelling trap.
12. Open-source licences for code and assets.
13. Hosting, distribution and donation methods.
14. Localization order.
15. Team roles.
16. Crossover with Noraebang Night (shared NHMH universe, cameos).

---

## 10. Research Checklist 🔍

- [ ] Plants that actually grow on each of the 12 mountains, and which match each mountain's letters
- [ ] Endangered and extinct animals for each mountain; restoration projects (반달가슴곰, 여우, 산양)
- [ ] Natural disasters most likely on each mountain
- [ ] Regional dishes that can be made from each mountain's forageable plants
- [ ] Folklore 괴물 sources, and a 괴물 for each mountain
- [ ] North Korean mountain ecology sources
- [ ] North Korean spelling differences for the spelling trap
- [ ] Competing Hangul-learning games
- [ ] Current stable Godot version at build start
- [ ] Open-source licence options for code and assets
- [ ] Donation and hosting options
