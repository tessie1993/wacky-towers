# Level 1: meadow_01 "Stump Day"

Status: DRAFT for user review. Author: level designer. Date: 2026-10-14.
The user's decisions for level 1 are binding and override `design/levels/plans/campaign-vision.md`:
minigame "Build to the mark", scene "Giant tree stump", board "Round", HUD "Minimal".
Story source: `design/narrative/beats/meadow.md` (meadow_01) and `design/narrative/campaign-story.md`.

Facts checked in code (2026-10-14):
- Goal types that exist: `clear_n`, `height`, `shape`, `survive`, `endless`, `rescue_all`, `bonk_boss`, `dig_rescue`, `wind_keys`, `bake_oven` (`assets/data/knobs/goals.json`).
- The `height` goal is a layer-coverage goal, not a "highest block" goal. It wins when layer `h_target` has at least `height_coverage` of its active cells filled (`src/mechanics/goal/height_goal.gd`). Layers count from 1.
- Board mask rows are strings. `#` = cell, `.` = cut (`src/core/board/ascii_grid.gd`). Row = z, char = x.
- Rules that exist: `sticky_landing` (slow gravity, lock on first support) and `wobble` (moves pieces; not used here).
- Current `meadow_01.json` is wrong for this design: goal `clear_n 2`, a `balloon` rule, no mask, and a stale `metadata.design_spec` copy.

---

## 1. One-line pitch and objective

**Pitch.** Drop a few glowing blocks on a giant old stump, and a sleepy meadow island hums awake.

**On-screen objective (12 words):** "Stack blocks on the stump until the tower reaches the glowing ring."

**Goal plaque headline (6 words, from the beat):** "Plant the Hearth Tower's first course".

Level card facts:
- Level name: Stump Day. Biome: meadow. Tier 1. Role: teach.
- Verb: build. Mechanics: `build_tower` (the height goal) plus `sticky_landing`. That is one mechanic with one gentle twist.
- Place and time: Hearth Stump, dawn. Cast: Wizard, Ada.
- Estimated play time: 70 to 100 s for a first-time player. Under 2 minutes for anyone.
- Ending pattern: plain. Opening event id: `spoon_pops_block_hums`.

---

## 2. Minigame: Build to the mark

**Verb.** Build. Drop a block. Turn a block. Make it fit.

**Core loop.**
1. A block tumbles from the Wizard's hat brim.
2. Slide it, turn it, and drop it.
3. It locks with a warm hum. The Hearth Hum meter grows.
4. The next block arrives. Repeat until the tower touches the ring.

**Win condition (exact).** The goal is `height`, `h_target = 4`, `height_coverage = 0.25`.
- The glowing ring sits on layer 4.
- On this mask one layer has 52 cells. 25 percent of 52 is 13 cells.
- The level is won when 13 or more cells of layer 4 are filled.
- That needs at least 52 cells in total, which is 13 pieces. A normal first run takes 16 to 20 pieces.
- Why 4 layers and 25 percent: pieces turn only on the flat "spin" axis, so a piece is one layer high. A fully flat ring-high tower would take 4 full layers (52 cells each), which is too long. 25 percent keeps it "a real tower" but short. `0.25` is the knob minimum.
- Why not 1 or 2 layers: it would be won in 20 seconds and teach nothing.

**Fail condition.** None the player can feel in level 1.
- `goal.top_out = rescue`, `goal.warnings_max = 3`. Top-out is a warning with a rescue, never a restart.
- Comic reaction if it ever happens: the top blocks giggle and tumble back into their box. The Wizard's cloud scoops them. Restart in 2 seconds or less.
- With 8 playable layers and a ring at layer 4, a top-out needs a very sloppy tower. It should be near impossible in a normal run.

**30-second grace.**
- For the first 30 seconds there is no top-out check, no warning and no flashing red.
- In practice the board cannot fill that fast (about 6 pieces at most, under 1 layer).
- To make it a rule and not luck, add a small knob `goal.grace_ms = 30000` (see section 10, NEW-1).

**Stars (the Wizard's thanks).**

| Stars | Rule | Reasoning |
|---|---|---|
| 1 | Reach the ring. | Everyone who finishes gets it. A party guest never leaves with nothing. |
| 2 | Ring in 120 s or less (`t2 = 120000`). | A calm first-timer at about 6 s per piece, 18 pieces, lands near 110 s. |
| 3 | Ring in 80 s or less (`t3 = 80000`). | Needs the drop gesture and 13 to 15 tidy pieces. It rewards learning "drop". |

Notes: the old values (`t2 290000`, `t3 210000`) were scaled from a clear-two-rows goal and are void. All values are first estimates and need playtest medians. `t3 <= t2` is required by the validator and holds.

---

## 3. Teaching beats, second by second

Rules for all beats: no text walls. Icons, glow, motion and sound only. The only words on screen are the 12-word objective plaque (shown once) and the goal headline.
Input is open from second 2. No beat blocks play.

| Time | What happens | What the player learns | How the game shows it |
|---|---|---|---|
| 0.0 s | Dawn light. Camera rests on the stump. The glowing ring floats above it. | There is a mark to reach. | The ring is the brightest thing on screen. The plaque slides in with the objective. |
| 0.8 s | The Wizard's cloud floats in. He tips his hat. | Someone is helping. | Wizard pose "point". |
| 1.4 s | Out plops a wooden spoon. He flings it into his sack. Plink. | Tone: this world is silly and kind. | The spoon gag. It is not a tutorial step. |
| 2.2 s | The first block (an O, a plain 2x2) tumbles from the hat brim. A warm hum starts. | A block is coming and it is mine. | The block glows gold. The NEXT slot shows the following piece. |
| 2.2 to 9 s | The block falls slowly. A soft landing shadow shows on the stump. | Where it will land. | The landing marker is a bright disc on the wood, high contrast. |
| 5 s, if no input | A glowing arrow-and-finger loop shows a slide. | Slide the block. | Icon only, near the block, not over the board. Fades on first input. |
| 9 s, or on drop | **First lock.** The block lands. | **Drop and lock.** | Warm hum note. A gold ripple runs through the tree rings. The meter gains one notch. Ada cheers. |
| lock + 0.4 s | The second block, an I (1x4 bar), arrives. A glowing 1x4 outline lies on the stump at a right angle to the bar. | The bar does not match the outline. | The outline is the target. It is cosmetic and does not block anything. |
| +3 s, if no turn | A curved turn arrow pulses on the bar. | **Turn the block.** | Icon only. |
| on first turn | The outline turns green. A small chime sounds. | Turning fixes things. | Green is a shape plus colour plus sound cue. |
| on drop of block 2 | **First turn done.** Snaps into the outline. | Turning matters. | Sparkle, hum, meter up. Ada points at the ring. |
| block 3 | An L arrives. No hint. | The player now chooses alone. | Hints stay off after the first turn. |
| around block 4 to 6 | If a block locks with a hanging cell, it wobbles and giggles. | Neat stacks look good. | See section 7. |
| 30 s | Grace ends. Nothing visible changes. | Nothing to learn. | The player never sees a countdown. |
| about 75 s | The tower nears the ring. The ring brightens. | Almost there. | See section 6. |

**First piece.** An O. It cannot be placed wrongly and needs no turn.
**First turn.** The I piece. It is the first shape where turning matters, and the outline shows why.
**First lock.** About 9 seconds of unaided fall at the start, or earlier if the player drops it. Its sound is the level's signature note.

**Pacing chart (intensity 0 to 5).**

| Time | Intensity | Note |
|---|---|---|
| 0 to 2 s | 1 | Intro, spoon gag. |
| 2 to 30 s | 1 | Teaching. No pressure at all. |
| 30 to 60 s | 2 | The tower grows. The player chooses. |
| 60 to 90 s | 2 | Last layers. The ring brightens. |
| ring reached | 3 | Bell, glow, cheer. |
| 3 s after | 0 | Result card. |

Level 1 has no enemies and no encounters. Encounter list: none. The only "event" is the teaching outline at block 2.

---

## 4. Board: Round

**Size.** `width 8`, `depth 8`, `h_play 8`.

**Mask** (1 = cell, 0 = cut). Row = z from back to front, column = x.

```
      x: 0 1 2 3 4 5 6 7
z=0      0 0 1 1 1 1 0 0     4 cells
z=1      0 1 1 1 1 1 1 0     6 cells
z=2      1 1 1 1 1 1 1 1     8 cells
z=3      1 1 1 1 1 1 1 1     8 cells
z=4      1 1 1 1 1 1 1 1     8 cells
z=5      1 1 1 1 1 1 1 1     8 cells
z=6      0 1 1 1 1 1 1 0     6 cells
z=7      0 0 1 1 1 1 0 0     4 cells
```

JSON rows (`#` = cell, `.` = cut):
`["..####..", ".######.", "########", "########", "########", "########", ".######.", "..####.."]`

**Playable cells per layer:** 4 + 6 + 8 + 8 + 8 + 8 + 6 + 4 = **52**. This is 13 pieces of 4 cells, so a perfect layer is possible.

**Spawn area.** Default anchor `(3, 3)` is a cell, so no `spawn_anchor` is needed. Pieces spawn in the centre 4 columns (x 2 to 5). Every row in the mask has cells in x 2 to 5, so any piece spawns clear of the cuts. The top spawn rows have a 4-wide landing area. The board height is `h_play 8` plus the spawn clearance (4), so 12 layers in total.

**Why the round edge is fair (no dead-end pockets).**
- Every row is one unbroken run. There are no holes inside the mask.
- The shortest run is 4 cells. The rule from the vision doc says arms must be at least 3 wide and the spawn rows at least 4. Both hold.
- Row widths go 4, 6, 8, 8, 8, 8, 6, 4. Each step in or out is exactly one cell. A step is a diagonal bite, not a slot or a channel.
- Check of the worst spots: an O (2x2) fits every corner step, for example at (1,1), (2,0) and (0,2). An I (1x4) fits the 4-cell rows at the back and front. An L or T fits against the steps in at least two turns.
- No cell is reachable only by a 1-wide void-bounded channel.
- Pieces cannot hang over a cut. They stop at the cut edge. The cut reads as the stump's round bark, so the player understands it without text.

---

## 5. Pieces

**Shapes (4 only):** O, I, L, T. S is dropped on purpose. Its skew is fiddly for a first-time player and a party guest. S joins in level 3 or later.
JSON: `"shapes": ["o","i","l","t"]`, equal weights, `spawn.randomizer = bag` (the default, a fair 7-bag style shuffle).

**Opening set:** `["o","i","l"]`, `opening_count 3`. The first three pieces are fixed: O (drop), I (turn), L (free choice). Then the bag takes over. The beat requires the first block to be a clean landing, which the O gives.

**Preview.** `spawn.preview_count = 1`. Only one NEXT slot shows. This matches the Minimal HUD. `spawn.hold_enabled = false`.

**Fall speed.** `fall.g0 = 0.5` (default is 1.0, the knob minimum is 0.3). `sticky_landing` adds `sticky_gravity_scale = 0.7`. No speed-up in this level: leave `fall.ramp_per_min` and `fall.ramp_per_clear` at 0 for this level (confirm the defaults). Design target: the first piece takes about 9 s to land unaided. Later pieces take about 6 s. The units of `g0` are not confirmed in the data, so the numbers are targets to measure in a playtest, not final.

**Lock delay.** `fall.lock_delay_ms = 900` (default 500), `fall.lock_resets_max = 15` (default 10). A lock on first support is also the point of `sticky_landing`. A guest has time to nudge a block after it touches down.

**Pause between pieces:** `fall.entry_delay_ms = 400` (default 200), so the lock hum can finish before the next block arrives.

**Controls.** Slide, turn (spin axis only: `control.rotation_axes_enabled = ["spin"]`), soft drop and hard drop. These are gestures or standard pad buttons, not extra HUD buttons.

---

## 6. Hearth Hum meter

**What fills it.** The tower's progress to the ring.
- Value = (cells filled in layers 1 to 4, each layer capped at 13) divided by 52.
- Each good lock adds a visible step. The meter never goes down.
- This is NEW data (NEW-2). The `height` goal today only reports the ring layer's own progress.

**Visual states.** The meter is a small hearth-flame glyph in a purple-wood frame, with a ring of notes around it.

| State | Fill | Meter look | Scene look and sound |
|---|---|---|---|
| Quiet | 0 to 10 percent | Dim ember. | Dawn light. Wind and birds only. |
| Hum | 10 to 40 percent | Small steady flame. One note added per lock. | The tree rings glow warm after each lock. A low hum note per lock. |
| Warm | 40 to 75 percent | Bigger flame. The note ring glows. | The cottage chimney starts a thin smoke curl. A soft chord joins the music. |
| Bright | 75 to 99 percent | Flame flickers up. The ring shimmers. | The glowing ring brightens and bobs. Music lifts a little. |
| Done | win | Flame bursts. | The end beat below. |

**End beat (about 4 s).**
1. The last cell touches the ring. The ring flashes white-gold and expands outward (the ring flash).
2. The stump bell rings. A big clear bell note, plus the hum chord resolves. (Set-piece action `bell_ring`.)
3. The tree rings light up green from the centre outward, one ring at a time. The whole stump glows green.
4. The grass greens and the wildflowers open. The cottage chimney puffs. The waterfall sparkles.
5. Wizard pose "point" at the tower, Ada pose "cheer". The result card with stars appears 3 s after the bell.

World change on win (from the beat): the first block hums and the stump glows green.

**Audio cues.**
- Start: soft dawn pad and birds.
- Each lock: one warm hum note (rises in pitch with the meter state).
- First turn: a small green chime.
- Warm state: a gentle chord joins.
- Win: bell, chord resolves, short joyful sting, then a calm loop under the result card.
- Pause and result: music ducks.

---

## 7. Moments of delight

1. **The spoon gag (0.8 to 2 s).** The Wizard tips his hat. A wooden spoon plops out. He flings it over his shoulder into the Wrong Sack tied to his cloud. Plink. The sack bulges. This is the first item of the Hat Dip running gag and matches the table in `campaign-story.md` (chapter 1, wooden spoon). It plays once and never blocks input.
2. **The wobble-giggle block.** When a block locks with a hanging cell (fewer than 2 of its cells have support below), it wobbles for 0.6 s and giggles. A tidy neighbour keeps its glow and hums. It is purely a cosmetic reaction. It never moves a cell and never costs anything. This shows the world rule "blocks remember how they were placed" without text. Recommended: do not use the `wobble` rule here, because it slips pieces and is unfair in level 1.
3. **The ring flash.** The glowing ring bobs like a halo while the player builds. On the win it flashes, grows outward and chimes. The bell follows.

Small extras (no cost, optional):
- Ada waves at the tower after the first lock.
- A butterfly lands on the first block.
- The first block's hum makes a nearby flower turn toward it.

---

## 8. Party play (2 to 4 players)

**Options.**

A. **Side by side, same seed (recommended).** Each player has their own round stump and tower. All players get the same piece sequence (fair, same seed). First to reach the ring rings the bell. Everyone else keeps building to their own ring and still gets the green glow and 1 star. No one is knocked out.
- Pros: the engine already supports one board per player (`layout.kind = single` means one board per player). No new rules. Fair. No waiting for turns. Fits "short and intense".
- Cons: four small stumps on one screen are less cosy. The stump scene must scale down (see art note).

B. **One shared stump, turn-taking.** Players take turns dropping one piece each on a single stump.
- Pros: cosy, co-operative, everyone watches one tower. Good for a living-room party.
- Cons: the engine has no shared-board turn system (about 5 days of new work). Waiting players get bored. A bad player ruins the tower for others, which clashes with "no shame".

C. **Co-op hum.** Side by side boards, but all players' Hearth Hum meters add into one shared meter. The bell rings only when the group reaches the total.
- Pros: no losers. Gentle for mixed skill.
- Cons: removes the race that makes a party. Needs a shared meter (about 1 to 2 days).

**Recommendation: A.** It costs nothing in the engine, is fair, and keeps the stump simple. Add a small shared touch from C for free: the bell rings in the same note for everyone, and the first finisher's Wizard pose cheers the others on.

**Solo play:** no rival. The stars decide the challenge.

**Art note for A:** for 3 to 4 players, the scene is shared as one wide meadow with the stumps in a row. The distant islands and the cottage stay behind them. Each stump has its own ring. Layout of the screen is a build-phase task (confirm split-screen or one wide camera with the Godot master).

---

## 9. HUD contract (Minimal)

Only these four elements show. Nothing else is on the screen.

| Element | Shows | Position | Notes |
|---|---|---|---|
| Goal plaque | "Plant the Hearth Tower's first course". Then the 12-word objective for the first 4 s. Then it shrinks to the headline plus a small ring icon. | Top centre | Purple wood, gold plaque, cream caps text. Not parchment. |
| NEXT piece | One piece, drawn as the real block, in a small round frame. | Top right | `spawn.preview_count = 1`. |
| Hearth Hum meter | The flame glyph with the note ring (section 6). | Left edge or bottom left | No number. A fill and a glow only. |
| Pause | A round pause button. | Top left | Standard. |

Hidden until later levels teach them: Hold, items, score, timer, rule pills, extra buttons.
There is no visible timer, although the stars use time. The clock only matters on the result card.
The teaching icons (slide arrow, turn arrow) are scene hints near the block, not HUD elements. They disappear after first use.

---

## 10. Data: proposed level JSON diff

Fields that already exist are marked EXISTS. New work is marked NEW with a size estimate.

```diff
 {
   "schema": 1,
   "id": "meadow_01",
   "biome": "meadow",
   "tier": 1,
   "name": "LVL_MEADOW_01_TITLE",
   "board": {
     "width": 8,
     "depth": 8,
     "h_play": 8,
-    "down_axis": "-y"
+    "down_axis": "-y",
+    "mask": ["..####..", ".######.", "########", "########", "########", "########", ".######.", "..####.."]
   },
   "pieces": {
-    "shapes": ["i","o","t","l","s"],
-    "opening_set": ["o","i"],
-    "opening_count": 2
+    "shapes": ["o","i","l","t"],
+    "opening_set": ["o","i","l"],
+    "opening_count": 3
   },
   "knobs": {
-    "fall.g0": 0.6,
+    "fall.g0": 0.5,
+    "fall.lock_delay_ms": 900,
+    "fall.lock_resets_max": 15,
+    "fall.entry_delay_ms": 400,
+    "spawn.preview_count": 1,
+    "spawn.hold_enabled": false,
+    "goal.intro_card_ms": 2000,
     "control.rotation_axes_enabled": ["spin"],
     "goal.top_out": "rescue",
-    "goal.warnings_max": 2
+    "goal.warnings_max": 3,
+    "goal.grace_ms": 30000
   },
   "goal": {
-    "type": "clear_n",
-    "n": 2
+    "type": "height",
+    "h_target": 4,
+    "height_coverage": 0.25
   },
   "rules": [
-    { "id": "balloon", "params": { ... } }
+    { "id": "sticky_landing", "params": { "sticky_gravity_scale": 0.7 } }
   ],
   "stars": {
-    "t2": 290000,
-    "t3": 210000
+    "t2": 120000,
+    "t3": 80000
   },
```

Also: delete `metadata.design_spec` (stale 4x4 copy). Set `metadata.ending = "plain"`, `metadata.level_type = "build"` (the old value was `funny`). Add the footprint `octagon` and `signature` ("The Wizard's spoon pops out and the first block hums").

**EXISTS (no work):** `board.mask` (parsed as `#`/`.`), the `height` goal with `h_target` and `height_coverage` (knob minimum 0.25), `sticky_landing`, `fall.*` knobs, `spawn.preview_count`, `spawn.hold_enabled`, `goal.top_out = rescue`, `goal.warnings_max`, `goal.intro_card_ms`, `stars.t2/t3`.

**To confirm with the Godot master before build** (I could not verify):
- `fall.g0` units, the `sticky_landing` scale meaning, and what `rescue` does on a top-out (see `design/gdd/level-goals-fail-states.md`).
- That `opening_set` plays the pieces in the listed order.
- `goal.height_coverage` inside the `goal` block. The loader copies it into the knob, so it should work.
- That `fills_layer_at` counts cells on a layer whose lower cells have gaps (overhangs).

**NEW / engine gaps:**

| ID | Gap | Size | Owner |
|---|---|---|---|
| NEW-1 | `goal.grace_ms` knob: no top-out check and no warnings for the first N ms. | 0.5 to 1 day | gameplay-programmer |
| NEW-2 | Hearth Hum progress: `HeightGoal.progress()` also returns the filled-to-target total across layers 1 to 4, for the meter. | 0.5 day | gameplay-programmer |
| NEW-3 | Teaching hints: a target outline (1x4 glow) on the stump for block 2, slide and turn icons after idle, fade on first use. Check if `mascot_hint` already does part of it. | 1 to 2 days | gameplay-programmer + ui-programmer |
| NEW-4 | Giggle reaction: a cosmetic event on a lock with a hanging cell (fewer than 2 cells supported). No board change. | 1 day | gameplay-programmer + technical-artist |
| NEW-5 | Win ring flash, bell and green tree-ring spread (set piece `hearth_stump`, action `bell_ring`). | 2 to 3 days | technical-artist |
| NEW-6 | Intro: Wizard hat-tip and spoon gag, non-blocking, with poses Wizard:point and Ada:cheer. Poses are shared with later levels. | 2 days (the poses are reused) | technical-artist |
| NEW-7 | Scene build "Giant tree stump" from PolyHaven/BlendKit assets (see art checklist). | 5 to 8 days | technical-artist + art-director |
| NEW-8 | Tutorial objective line (12 words) UI. This overlaps the vision-doc gap "per-level tutorial preview and 12-word line UI". | 2 days (shared) | ui-programmer |
| NEW-9 | Party A: confirm 2 to 4 boards on one screen. Option B would add a shared-board turn system (about 5 days). | 0 to 2 days for A | gameplay-programmer |

**Art checklist (for NEW-7, assets not procedural):**
- Stump top with visible tree rings, cut to a round (octagon) top that matches the mask. The rim must read as the cut edge.
- Floating meadow island: grass, wildflowers, rocks.
- Behind it: distant islands, a small cottage with chimney smoke, and a waterfall.
- The hanging glowing ring, the wooden bell on a small post, and the Wrong Sack on the Wizard's cloud.
- Dawn lighting. Warm rim light. Palette must beat the reference boards in `assets/art/reference/`. No beige, no parchment.

---

## 11. Acceptance criteria (testable)

Automated:
1. `meadow_01.json` loads with `LevelLoader.load_level` and returns no errors.
2. The board mask has 52 active cells and the exact rows in section 4. The default spawn anchor (3,3) is active.
3. Goal type is `height`, `h_target 4`, coverage 0.25. The evaluator returns WON with 13 cells filled in layer 4 and RUNNING with 12.
4. The first three pieces are O, I, L in that order. All later pieces are from O, I, L, T only, and no S appears in 200 seeded pieces.
5. No dead-end: every active cell can be covered by an O in some position. A flood-fill finds no channel narrower than 3 cells.
6. With `goal.grace_ms = 30000`, a forced top-out stack at t = 29 s produces no warning and no loss. (Needs NEW-1.)
7. A bot with unlimited time wins 500 of 500 seeded runs (the vision doc asks for 98 percent or more).
8. A bot that never turns and only drops still wins (turning is taught, not required for victory).
9. Stars: ring in 120 s or less gives 2 stars. Ring in 80 s or less gives 3. Any win gives at least 1.
10. Hum meter value is monotone non-decreasing and equals 1.0 at the win.

Observed (retained screenshots in `production/qa/evidence/`):
11. Start frame at 720x1280: the ring, the stump, the plaque and one NEXT piece are all visible. Nothing else HUD-like is on screen. No beige or parchment.
12. Frame at the first lock, the first turn (green outline), a giggle block, the Warm state, the win flash and the green stump.
13. Playtest with 5 first-time players: at least 4 say what to do from the start frame in 10 seconds. At least 4 of 5 turn a block by the third piece without being told in words. Median finish time between 70 and 120 s.
14. In a 4-player side-by-side run, all four stumps and rings are readable and the first finisher's bell is audible and visible to all.
15. No text appears over the board. The tutorial line is 12 words or fewer.

---

## 12. Open questions for the user

Four questions. Each has a recommended option first.

1. **How should "reach the ring" be measured?**
   - (Recommended) Existing height goal: 13 cells on layer 4. Zero engine work. Takes 70 to 100 s.
   - New "touch" mode: any block touching the ring wins. About 1 to 1.5 days. Very short (about 40 s) because pieces lie flat, and it teaches less.
   - Taller or fuller: layer 5 or 50 percent coverage. Longer (2.5 to 3 minutes). Too long for level 1.
2. **What happens when the stack gets too high in level 1?**
   - (Recommended) Soft rescue only: three warnings, then the Wizard's cloud scoops the top blocks with a giggle. Plus a real 30 s grace knob (NEW-1).
   - No fail at all in level 1: the top-out check is switched off for the whole level.
   - Normal fail after the 30 s grace: the tower topples, and the level restarts in 2 s.
3. **How do 2 to 4 players play?**
   - (Recommended) Side by side, same seed, own stump each. First to the ring rings the bell, everyone still glows green. Zero engine work.
   - One shared stump with turn-taking. About 5 days of engine work. Cosy, but others wait.
   - Co-op: boards side by side with one shared Hum meter. About 1 to 2 days. No race.
4. **How should the wobble-giggle block work?**
   - (Recommended) Cosmetic only: a giggle animation on a hanging-cell lock. No effect on the board. About 1 day.
   - The real `wobble` rule: sloppy pieces slip toward the heavy side. Free (rule exists) but risky and unfair on level 1.
   - A scripted giggle on piece 4 whatever the player does. Always seen, but it can look wrong beside a neat stack.
