# Hangul Hiking Trip: Hallasan — Item Names v0.1

*8 November 2026 · Production doc (versioned)*
*Parent documents: Hallasan Foraging Word Bank v0.1; Hallasan Exit Note v0.1; foraging ending design (CHAT, 7 Nov 2026, to be recorded in Log F)*
*Dev team: 니가 한국어 못해 (NHMH)*

> **Markers:** ✅ DECIDED · 🟡 SUGGESTED · ❓ OPEN · 🔍 VERIFY

---

## 1. Plant items ✅

Each finished word puts **2 of that plant** into Fernanda's backpack straight away, with a float such as "+2 고사리". English names match the hover names in Word Bank v0.1 §3; only the capitalization changes for display.

| Korean | English | Flavor line |
|---|---|---|
| **마** | Chinese yam | Slimy when cut. Good for stamina, they say. |
| **머루** | Wild grape | Small, sour, and purple. Stains everything. |
| **미나리** | Water dropwort | Grows where your feet get wet. Crunchy. |
| **고사리** | Bracken fern | Curled up like it's hiding. Never eat it raw. |
| **고비** | Royal fern | Fuzzy little fist. Bracken's fancier cousin. |
| **시로미** | Crowberry | Tiny black berries from the windy top. |

---

## 2. The notebook ✅

| Field | Value |
|---|---|
| Korean | **수첩** |
| English | Notebook |
| Flavor line | A gift from the old lady. The pages smell like incense. |
| Empty state | No notes yet. |
| Source | In Fernanda's backpack from the start of foraging. The old lady gives it to her in the opening scene |
| Look | A worn pocket notebook of the kind an old person would carry (FRONTEND) |

The old lady is never called "grandma" in game text.

---

## 3. Note pages ✅

- The notebook opens to the **newest note first**. Players flip back to older ones.
- **A page shows only the note's content.** No title, no writer label, no date. Any signature is part of the note's own text, such as "— 수민".
- Notes are loot: a note found in a scene is lost on death in that scene. The notebook itself stays.
- 🟡 **Handwritten look: deferred.** Plain text for now. A handwritten look, possibly a different hand per writer, is a later FRONTEND task.

---

## 4. Checks

| Check | Result | Status |
|---|---|---|
| English names match the word bank | Matches §3 hover names | ✅ |
| 고사리 "never eat it raw" | Raw bracken contains ptaquiloside and thiaminase and must be boiled and soaked before eating ([Segye Ilbo](https://www.segye.com/newsView/20261001511173)) | ✅ |
| 마 "slimy… stamina" | Phrased as hearsay ("they say") | 🟡 |
| 고비 "fuzzy little fist" | Young royal-fern fronds are woolly | 🔍 |
| Hangul as text | Names and notes are set as text, never baked into images | ✅ |
| Native-speaker review | 수첩 as an old person's notebook, all item names | 🔍 |
