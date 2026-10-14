# Level 1: meadow_01 "Stump Day"

Status: DRAFT r2 for user review (goal changed by the user). Author: level designer. Date: 2026-10-14.
The user's decisions for level 1 are binding and override `design/levels/plans/campaign-vision.md`:
minigame "Build to the mark", scene "Giant tree stump", board "Round", HUD "Minimal".
r2 user decisions: the goal is "layer clearer with obstacles, on a timer"; a stack that gets too high gets a soft
rescue plus a grace knob; party play is side by side, same seed; the wobble-giggle is cosmetic only.
Story source: `design/narrative/beats/meadow.md` (meadow_01) and `design/narrative/campaign-story.md`.
Ruling on words: the headline names the story, not a row count. The objective line may say "Clear 3 layers before time runs out".
This overrides vision rule U15 (no counter goals) for this level, by the user's choice.

Facts checked in code (2026-10-14):
- `clear_n` goal: wins when `layers_cleared >= n`. HUD progress is `{done, target}` (`src/mechanics/goal/clear_n_goal.gd`).
- Timer: `goal.time_limit_ms` exists as a goal field and a knob (`board_sim.gd` `_timed_out`). Today a timeout is a LOSS (`time_limit`). A "+30 s once" soft retry does NOT exist (NEW-1).
- Obstacles: the `rock` content kind (glyph `R`) has `fills_layer = false`. The `rock_obstacle` rule places rocks from a `cells` list of `[x, y, z]` and marks them fixed, anchored, clear-protected and excluded from the clear denominator (`src/mechanics/lava/rock_obstacle.gd`).
- Clearing: `BoardState.shift_layers` empties each full layer, then drops every layer above by the number of cleared layers beneath. Cells that cannot move (rocks) stay, and blocks above them stop on them.
- Plain `starting_contents` with `R` would place rocks WITHOUT the protected status flags. So use the `rock_obstacle` rule, not `starting_contents`.
- Board mask rows are strings. `#` = cell, `.` = cut (`src/core/board/ascii_grid.gd`). Row = z, char = x.
- Stars: time stars `t2`/`t3` compare `level_ms`. 3 stars also need no warning used and no cells trimmed (`src/core/sim/star_rater.gd`).
- The old `meadow_01.json` is wrong for this design (balloon rule, no mask, no timer, a stale `metadata.design_spec`).

---

## 1. One-line pitch and objective

**Pitch.** Fill the gaps between the old roots and stones on a giant stump, and each full layer lights the meadow awake.

**On-screen objective (10 words):** "Clear 3 layers before time runs out." Shown once, on the plaque, for 4 seconds.

**Goal plaque headline (6 words, from the beat):** "Plant the Hearth Tower's first course".

Level card facts:
- Level name: Stump Day. Biome: meadow. Tier 1. Role: teach.
- Verb: build. Mechanics: layer clearing (`clear_n`) with permanent rock obstacles, plus `sticky_landing`.
- Place and time: Hearth Stump, dawn. Cast: Wizard, Ada.
- Estimated play time: 60 to 120 s for a first-time player. Hard cap 2:30 with the soft retry.
- Ending pattern: plain. Opening event id: `spoon_pops_block_hums`.

---

## 2. Minigame: Build to the mark

**Verb.** Build. Drop a block. Turn a block. Fill the gaps.

**Core loop.**
1. A block tumbles from the Wizard's hat brim.
2. Slide it, turn it, and drop it into the lane between the roots and stones.
3. It locks with a warm hum.
4. When a whole layer is full, it clears: the blocks pop, the layers above settle, the Hearth Hum grows.
5. Repeat until 3 layers are cleared.

**Win condition (exact).** `clear_n`, `n = 3`, `time_limit_ms = 120000`.
- Win when 3 layers have been cleared before the clock reaches 2:00.
- Any full layer counts, not only the bottom one.
- Why `clear_n`: it is the engine's native layer-clear goal. Zero new goal code. The "mark" is now the glowing ring of light that sweeps the layer on each clear (see section 7).

**Layer size and workload (see section 4).** The lane is 32 cells. That is 8 pieces per layer. The minimum is 24 pieces for 3 clears. A first-timer needs about 26 to 30 pieces. Pieces that overfill a cleared layer drop down and count toward the next one, so over-stacking is not wasted.

**Fail condition.**
- Time runs out: soft retry, once. See below.
- Stack too high: soft rescue only. `goal.top_out = rescue`, `goal.warnings_max = 3`. The Wizard's cloud scoops the top blocks with a giggle. Never a restart. The comic reaction if it ever fully fails: blocks giggle back into their box, restart in 2 s or less.
- With a 4-wide lane and 8 playable layers, a top-out needs a very sloppy tower.

**Soft retry (NEW-1).** At 2:00, if the goal is not met, the game does not end. The Wizard yawns, a sandglass refills, and the clock gets +30 s once. The stack stays as it is. If the extra 30 s also runs out, blocks giggle into the box and the level restarts in 2 s or less. Using the retry caps the run at 1 star (the finish time is over 90 s).

**30-second grace.**
- For the first 30 seconds there is no top-out check, no warning and no red flash. The new knob `goal.grace_ms = 30000` makes it a rule (NEW-2).
- The timer cannot run out in that window either (2:00 limit).

**Stars (the Wizard's thanks).**

| Stars | Rule | Reasoning |
|---|---|---|
| 1 | Win, with or without the retry. | A party guest never leaves with nothing. |
| 2 | 3 clears in 90 s or less (`t2 = 90000`). | 24 to 28 pieces at about 3.5 s each. Needs the drop gesture most of the time. |
| 3 | 3 clears in 60 s or less (`t3 = 60000`), with no warning and no trim. | The minimum is 24 pieces, so about 2.5 s per piece with hard drops and almost no gaps. Hard but fair for a fast, tidy player. |

Notes: a calm first-timer at about 4.5 s per piece lands near 110 to 120 s, which is the 1-star zone, and the +30 s retry catches the slow ones. All values are first estimates and need playtest medians. `t3 <= t2` holds, as the validator requires. The engine's 3-star rule also needs `warnings_used == 0` and `cells_trimmed == 0`.

---

## 3. Teaching beats, second by second

Rules for all beats: no text walls. Icons, glow, motion and sound only. The only words on screen are the objective on the plaque (once) and the headline.
Input is open from second 2. No beat blocks play.

| Time | What happens | What the player learns | How the game shows it |
|---|---|---|---|
| 0.0 s | Dawn light. Camera rests on the stump. Roots and stones frame a lane of bare tree rings. | There is a lane to fill. | The lane is the brightest, flattest area. The plaque slides in with the objective. |
| 0.8 s | The Wizard's cloud floats in. He tips his hat. | Someone is helping. | Wizard pose "point". |
| 1.4 s | Out plops a wooden spoon. He flings it into his sack. Plink. | Tone: silly and kind. | The spoon gag. Not a tutorial step. |
| 2.2 s | The first block (an O, a plain 2x2) tumbles from the hat brim. A warm hum starts. | A block is coming and it is mine. | The block glows gold. The NEXT slot shows the following piece. |
| 2.2 to 7 s | The block falls slowly. A soft landing shadow shows in the lane. | Where it will land. | The landing marker is a bright disc on the wood, high contrast. |
| 4 s, if no input | A glowing arrow-and-finger loop shows a slide. | Slide the block. | Icon only, near the block. Fades on first input. |
| 7 s, or on drop | **First lock.** The block lands. | **Drop and lock.** | Warm hum note. A gold ripple runs through the tree rings. Ada cheers. |
| lock + 0.4 s | The second block, an I (1x4 bar), arrives. A glowing 1x4 outline lies in the lane at a right angle to the bar. | The bar can match the outline. | The outline is an invitation, not a rule. It does not block anything. |
| +3 s, if no turn | A curved turn arrow pulses on the bar. | **Turn the block.** | Icon only. |
| on first turn | The outline turns green. A small chime sounds. | Turning fixes things. | Green is shape plus colour plus sound. |
| on drop of block 2 | **First turn done.** It snaps into the outline. | Turning matters. | Sparkle, hum. Ada points at the lane. |
| block 3 | An L arrives. No hint. | The player now chooses alone. | Hints stay off after the first turn. |
| around block 4 to 6 | If a block locks with a hanging cell, it wobbles and giggles. | Neat stacks look good. | See section 7. Cosmetic only. |
| when 8 or fewer lane cells are empty | The empty cells pulse softly gold. | **Fill these to clear the layer.** | A glow on the empty cells. No text. |
| about 35 to 50 s | **The first clear.** The last cell fills. | **Full layer = clear. This is the big lesson.** | See the clear beat below. |
| after the first clear | The second and third layers have no hints. | The player repeats it alone. | The empty-cell pulse stays on for each layer (it is not text). |
| 30 s | Grace ends. Nothing visible changes. | Nothing to learn. | The player never sees a grace countdown. |
| about 75 to 110 s | The third clear. | Done. | See section 6. |

**The first clear (about 2.5 s). The big teaching moment.**
1. The last cell fills. The whole layer glows white-gold.
2. A ring of light sweeps across the layer from the centre outward and chimes.
3. The blocks pop into sparkles. Any blocks above settle down one layer with a soft bounce.
4. The roots and stones do not move. They stay where they are.
5. The first tree ring of the stump lights green. The Hearth Hum gains one third.
6. Ada cheers. The Wizard points at the meter.

**First piece.** An O. It cannot be placed wrongly and needs no turn.
**First turn.** The I piece, with its outline.
**First lock.** About 5 seconds of unaided fall at the start, or earlier if the player drops it.

**Pacing chart (intensity 0 to 5).**

| Time | Intensity | Note |
|---|---|---|
| 0 to 2 s | 1 | Intro, spoon gag. |
| 2 to 30 s | 1 | Teaching. Timer is far away. |
| 30 to 50 s | 2 | The first clear. Reward spike (3 for 2 s). |
| 50 to 90 s | 2 to 3 | Second clear. The timer becomes visible in the last 30 s. |
| 90 to 120 s | 3 | Third clear, the push. |
| win | 3 | Bell, glow, cheer. |
| 3 s after | 0 | Result card. |

Level 1 has no enemies. Encounter list: none. The "encounter" is the lane and the clock.

---

## 4. Board: Round, with obstacles

**Size.** `width 8`, `depth 8`, `h_play 8`.

**Mask** (1 = cell, 0 = cut). Row = z from back to front, column = x. The mask is unchanged from r1.

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

**Playable cells per layer:** 52. After obstacles: **32 free cells per layer** (see below).

**Obstacle layout.** `R` = a permanent rock column (stone or root knot). `.` = free lane. `-` = cut.

```
      x: 0 1 2 3 4 5 6 7
z=0      - - . . . . - -
z=1      - R . . . . R -
z=2      R R . . . . R R
z=3      R R . . . . R R
z=4      R R . . . . R R
z=5      R R . . . . R R
z=6      - R . . . . R -
z=7      - - . . . . - -
```

- 20 rock columns: 2 + 4 + 4 + 4 + 4 + 2 = 20 (left flank 10, right flank 10).
- The free lane is columns 2 to 5 on every row: 4 wide, 8 long, 32 cells = 8 pieces exactly.
- Left flank is skinned as twisting roots. Right flank is skinned as mossy stones. This is a cosmetic choice (NEW-5). Both are the `rock` kind.
- Each rock column is 8 layers tall (the full `h_play`). See why below.

**Rules for the obstacles (what the engine does).**
- Does clearing a layer remove obstacles in it? **No.** Rocks are clear-protected and anchored. They never clear and never move.
- How do layers above fall? Each layer above a cleared layer drops one step. Lane cells drop freely. Rock columns stay, and nothing needs to drop through them.
- Do rocks count in the clear? **No.** The `rock` kind has `fills_layer = false`, so it is excluded from the denominator. A layer is full when all 32 lane cells are filled.
- Why the walls are full height: if the rocks were only 1 layer high, layer 2 would have 20 extra flank cells that must be filled. Layers 2 and up would need 52 cells and be much slower. Full-height columns keep every layer at 32 cells, so any layer can clear.
- Why that also prevents a trap: with 1-high rocks a piece could rest on a rock and hang over the lane. That makes a covered hole. Full-height walls block pieces from sliding sideways over the flanks at all.
- Pieces above `h_play` (in the spawn clearance zone) could still slide over a flank. Cover this by making the rock columns run to the top of the board, 12 layers. Confirm with the Godot master that rocks can sit in the clearance zone (open point).

**Fairness: no unfillable layer.**
- Every free cell is in one connected region. There is no pocket.
- The free region is a plain 4 x 8 rectangle. An I (1x4) fits across it or along it. An O fits anywhere. An L or T fits anywhere. A 4 x 8 rectangle can be tiled exactly with I, O, L and T alone.
- The lane is 4 wide. The vision doc asks for at least 4 wide at spawn rows and 3 wide elsewhere. Both hold.
- Rocks only touch the lane on straight edges. There are no 1-wide notches or channels.
- The spawn anchor `(3, 3)` is in the lane. Pieces spawn in columns 2 to 5, which is exactly the lane.
- A covered hole made by the player blocks only that layer. Another full layer still counts. The rescue trims a too-high stack.

**Why the round edge is fair.**
- The cut corners of the octagon never touch the lane. They sit behind the rock flanks.
- The round shape shows in the scene as the stump's outline and the curved root walls.

**Later levels** can add stones inside the lane. Level 1 keeps it a clean lane so the clear is easy to read.

---

## 5. Pieces

**Shapes (4 only):** O, I, L, T. S is dropped on purpose. Its skew is fiddly for a first-time player and a party guest. S joins in level 3 or later.
JSON: `"shapes": ["o","i","l","t"]`, equal weights, `spawn.randomizer = bag` (the default, a fair shuffle).

**Opening set:** `["o","i","l"]`, `opening_count 3`. The first three pieces are fixed: O (drop), I (turn), L (free choice). Then the bag takes over.

**Preview.** `spawn.preview_count = 1`. Only one NEXT slot shows. `spawn.hold_enabled = false`.

**Fall speed.** `fall.g0 = 0.9` (default 1.0, minimum 0.3). `sticky_landing` with `sticky_gravity_scale = 0.8`. No speed-up: leave `fall.ramp_per_min` and `fall.ramp_per_clear` at 0 for this level (confirm the defaults). Design target: about 5 s of unaided fall per piece. A piece that is dropped lands in about 1 s. The units of `g0` are not confirmed, so these are targets to measure in a playtest.

**Lock delay.** `fall.lock_delay_ms = 900` (default 500), `fall.lock_resets_max = 15` (default 10). A guest has time to nudge a block after it touches down.

**Pause between pieces:** `fall.entry_delay_ms = 300` (default 200), so the lock hum can finish. Shorter than r1 because the timer is now running.

**Controls.** Slide, turn (spin axis only: `control.rotation_axes_enabled = ["spin"]`), soft drop and hard drop. Gestures or standard pad buttons, not extra HUD buttons.

---

## 6. Hearth Hum meter

**What fills it.** Layer clears. Each clear is one third. Three clears = Done.
- The `clear_n` goal already reports `{done, target}`, so the meter works with no new data.
- Optional smooth fill (NEW-3): between clears, the current layer's fill adds up to 90 percent of one third. It makes the meter move on every lock. If skipped, the meter moves in three steps and each lock only plays a hum note.

**Visual states.** The meter is a small hearth-flame glyph in a purple-wood frame, with a ring of three notes around it.

| State | Clears | Meter look | Scene look and sound |
|---|---|---|---|
| Quiet | 0 | Dim ember. | Dawn light. Wind and birds. Each lock adds a hum note. |
| Hum | 1 | Small steady flame. Note 1 lit. | The inner tree ring glows green. A warm chord joins. |
| Warm | 2 | Bigger flame. Note 2 lit. | The middle tree ring glows green. The cottage chimney starts a thin smoke curl. |
| Done | 3 | Flame bursts. All notes lit. | The end beat below. |

**End beat (about 4 s).**
1. The third layer clears. The ring of light sweeps out and does not stop at the lane edge. It races to the rim of the stump.
2. The outer tree ring lights green. The whole stump glows green.
3. The stump bell rings. A big clear bell note, and the hum chord resolves. (Set-piece action `bell_ring`.)
4. The grass greens and the wildflowers open. The cottage chimney puffs. The waterfall sparkles.
5. Wizard pose "point" at the tower, Ada pose "cheer". The result card with stars appears 3 s after the bell.

World change on win (from the beat): the first block hums and the stump glows green.

**Timer display.** See section 9. In the last 30 s the timer pulses gently. In the last 10 s a soft tick sounds. It is never red or loud.

**Audio cues.**
- Start: soft dawn pad and birds.
- Each lock: one warm hum note (pitch rises with clears).
- First turn: a small green chime.
- Each clear: a chime and a light sweep sound.
- Last 30 s: a gentle pulse under the music. Last 10 s: soft ticks.
- Soft retry: a yawn and a sand-pour sound.
- Win: bell, chord resolves, short joyful sting, then a calm loop under the result card.

---

## 7. Moments of delight

1. **The spoon gag (0.8 to 2 s).** The Wizard tips his hat. A wooden spoon plops out. He flings it over his shoulder into the Wrong Sack tied to his cloud. Plink. The sack bulges. This is the first item of the Hat Dip running gag (`campaign-story.md`, chapter 1, wooden spoon). It plays once and never blocks input.
2. **The wobble-giggle block.** When a block locks with a hanging cell (fewer than 2 of its cells have support below), it wobbles for 0.6 s and giggles. A tidy neighbour keeps its glow and hums. It is purely cosmetic (user decision). It never moves a cell and never costs anything. The `wobble` rule is not used.
3. **The ring flash.** Each layer clear sends a ring of light across the layer, like a tree ring. Ring 1, 2 and 3 light the three tree rings green. The last one rushes to the rim and the bell rings.
4. **The sandglass yawn** (soft retry). The Wizard yawns, the sandglass refills, and Ada gives a thumbs up. It turns a near-fail into a laugh.

Small extras (no cost, optional):
- Ada waves at the tower after the first lock.
- A butterfly lands on the first block.
- The roots shift a little when a layer clears, as if cheering.

---

## 8. Party play (2 to 4 players)

**Decision (user): side by side, same seed. First to 3 clears rings the bell.**

How it plays:
- Each player has their own round stump with the same rock layout.
- All players get the same piece sequence. Fair.
- Each player has their own Hearth Hum meter. Each player has their own 2:00 clock and the same start moment.
- The first player to 3 clears rings the bell. Their stump glows green.
- Everyone else keeps playing to their own 3 clears and gets the green glow and at least 1 star. No one is knocked out.
- The soft retry (+30 s once) is per player.
- Ties: the player with the earlier finish time wins the bell. An exact tie rings the bell for both.

Solo play: no rival. The stars decide the challenge.

Engine: one board per player is native (`layout.kind = single`). No shared-board code. Three or four boards on one screen is a presentation task (NEW-8).

Art note: for 3 to 4 players the scene is one wide meadow with the stumps in a row. The distant islands and the cottage stay behind them. Each stump has its own tree rings and its own bell light.

---

## 9. HUD contract (Minimal)

Only these four elements show. Nothing else is on the screen.

| Element | Shows | Position | Notes |
|---|---|---|---|
| Goal plaque | "Plant the Hearth Tower's first course". For the first 4 s also the objective "Clear 3 layers before time runs out." After that it shrinks to the headline plus a thin sunrise bar (the timer, see below) and 3 small layer pips. | Top centre | Purple wood, gold plaque, cream caps text. Not parchment. |
| NEXT piece | One piece, drawn as the real block, in a small round frame. | Top right | `spawn.preview_count = 1`. |
| Hearth Hum meter | The flame glyph with the three-note ring (section 6). | Left edge or bottom left | No number. A fill and a glow only. |
| Pause | A round pause button. | Top left | Standard. |

**Timer on a Minimal HUD.** The timer is part of the plaque, not a fifth element: a thin sunrise bar under the headline. A small sun slides along the bar from the left to the right edge over 2:00. Seconds are shown only in the last 10 s. This is an open question for the user (section 12).

The three layer pips show cleared layers (a lit pip per clear). They repeat the meter and are optional.

Hidden until later levels teach them: Hold, items, score, rule pills, extra buttons.
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
+    "fall.g0": 0.9,
+    "fall.lock_delay_ms": 900,
+    "fall.lock_resets_max": 15,
+    "fall.entry_delay_ms": 300,
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
     "type": "clear_n",
-    "n": 2
+    "n": 3,
+    "time_limit_ms": 120000,
+    "time_extension_ms": 30000,
+    "time_extensions_max": 1
   },
   "rules": [
-    { "id": "balloon", "params": { ... } }
+    { "id": "sticky_landing", "params": { "sticky_gravity_scale": 0.8 } },
+    { "id": "rock_obstacle", "params": { "cells": [ /* 20 columns x layers 0..7, see below */ ] } }
   ],
   "stars": {
-    "t2": 290000,
-    "t3": 210000
+    "t2": 90000,
+    "t3": 60000
   },
```

**Rock cells (`[x, y, z]`).** For each column below, one entry per layer y = 0 to 7 (160 triples). Extend to y = 11 if rocks must fill the clearance zone.

| z | rock columns x |
|---|---|
| 0 | none |
| 1 | 1, 6 |
| 2 | 0, 1, 6, 7 |
| 3 | 0, 1, 6, 7 |
| 4 | 0, 1, 6, 7 |
| 5 | 0, 1, 6, 7 |
| 6 | 1, 6 |
| 7 | none |

Also: delete `metadata.design_spec` (stale 4x4 copy). Set `metadata.ending = "plain"`, `metadata.level_type = "build"` (old value was `funny`). Add footprint `octagon` and `signature` ("The Wizard's spoon pops out and the first block hums").

**EXISTS (no work):** `board.mask`, the `clear_n` goal with `n`, the timer field `goal.time_limit_ms` (a timeout currently LOSES), `rock_obstacle` rule and `rock` kind, `sticky_landing`, `fall.*` knobs, `spawn.preview_count`, `spawn.hold_enabled`, `goal.top_out = rescue`, `goal.warnings_max`, `goal.intro_card_ms`, `stars.t2/t3`, clear_n HUD progress `{done, target}`.

**To confirm with the Godot master before build** (I could not verify):
- That a layer containing rock columns clears when all non-rock cells are full (the code comments say rocks are excluded from the denominator).
- That `rock_obstacle.cells` accepts 160 to 240 entries and can reach the spawn clearance zone (y up to 11).
- The goal block accepts the new keys `time_extension_ms` and `time_extensions_max` (the validator may reject unknown goal keys).
- `fall.g0` units, the `sticky_landing` scale meaning, what `rescue` does on a top-out (see `design/gdd/level-goals-fail-states.md`, not read).
- That `opening_set` plays pieces in the listed order, and the spawn orientation of the I.

**NEW / engine gaps:**

| ID | Gap | Size | Owner |
|---|---|---|---|
| NEW-1 | Soft retry: on timeout, add `time_extension_ms` once instead of losing (two `_finish(LOST, time_limit)` sites in `board_sim.gd`), plus a sandglass event for the UI. | 1 day | gameplay-programmer |
| NEW-2 | `goal.grace_ms` knob: no top-out check and no warnings for the first N ms. | 0.5 to 1 day | gameplay-programmer |
| NEW-3 | Optional smooth Hum fill: the current layer's fill adds to the meter. Needs a layer-fill value from the board. | 0.5 day | gameplay-programmer |
| NEW-4 | Teaching hints: the 1x4 outline for block 2, slide and turn icons after idle, a pulse on the last empty cells of the layer. Check if `mascot_hint` already does part of it. | 2 days | gameplay-programmer + ui-programmer |
| NEW-5 | Rock skins: two looks (roots, stones) for the `rock` kind, chosen per column. Optional compact param `columns: [[x, z, height]]` instead of 160 triples. | 1 day (art) + 0.5 day (param) | technical-artist + gameplay-programmer |
| NEW-6 | Cosmetic giggle on a lock with a hanging cell. No board change. | 1 day | gameplay-programmer + technical-artist |
| NEW-7 | Clear sweep ring, three-tree-ring green lighting, bell and rim rush (set piece `hearth_stump`, action `bell_ring`). | 3 days | technical-artist |
| NEW-8 | Intro (Wizard hat-tip, spoon gag, sandglass yawn) plus poses Wizard:point and Ada:cheer, shared later. Scene build "Giant tree stump" from PolyHaven/BlendKit assets (stump top with rings and the round rim, floating meadow island with grass, wildflowers and rocks, distant islands, cottage with chimney smoke, waterfall, bell post, Wrong Sack). | 2 days (intro) + 5 to 8 days (scene) | technical-artist + art-director |
| NEW-9 | Timer on the plaque (sunrise bar) and the 12-word objective line UI (overlaps the vision gap "per-level tutorial preview and 12-word line UI"). | 2 days (shared) | ui-programmer |
| NEW-10 | 2 to 4 boards on one screen (side by side). | 0 to 2 days | gameplay-programmer |

Scene art must beat the reference boards in `assets/art/reference/`. No beige, no parchment. Dawn lighting with a warm rim light.

---

## 11. Acceptance criteria (testable)

Automated:
1. `meadow_01.json` loads with `LevelLoader.load_level` and returns no errors.
2. The board mask has 52 active cells and the exact rows in section 4. The default spawn anchor (3,3) is active.
3. There are exactly 20 rock columns at the listed positions. All rocks are fixed and clear-protected. The free lane is 32 cells per layer.
4. Goal is `clear_n` with `n 3` and a 120000 ms limit. Filling all 32 lane cells of one layer clears that layer, leaves every rock in place, and drops the layers above by one.
5. After a clear, no rock has moved and no block sits inside a rock cell.
6. The first three pieces are O, I, L in that order. All later pieces are from O, I, L, T only. No S appears in 200 seeded pieces.
7. Tiling check: a solver can tile the 4 x 8 lane with the shape set (the 3 clears are always reachable).
8. A bot that never turns and only drops still clears 3 layers within 120 s in at least 90 percent of 500 seeded runs. (Turning is taught, not required.)
9. A bot with unlimited time wins 500 of 500 seeded runs, including with the retry (the vision doc asks for 98 percent or more).
10. At 120000 ms with fewer than 3 clears, the game adds 30000 ms once and does not end. A second timeout loses. (Needs NEW-1.)
11. With `goal.grace_ms = 30000`, a forced top-out stack at t = 29 s produces no warning and no loss. (Needs NEW-2.)
12. Stars: 3 clears in 90 s or less gives 2 stars. In 60 s or less with no warning and no trim gives 3. Any win gives at least 1. A run that used the retry gives 1.
13. The Hum meter is monotone non-decreasing and equals full at the win.

Observed (retained screenshots in `production/qa/evidence/`):
14. Start frame at 720x1280: the lane, the roots and stones, the plaque with the objective, the timer bar, one NEXT piece, the meter and pause. Nothing else HUD-like. No beige or parchment.
15. Frames at the first lock, the first turn (green outline), a giggle block, the pulse on the last empty cells, the first clear sweep, the Warm state, the sandglass retry, the win flash and the green stump.
16. Playtest with 5 first-time players: at least 4 say what to do from the start frame in 10 seconds. At least 4 of 5 turn a block by the third piece without being told in words. At least 4 of 5 can say "a full row clears" after the first clear. Median finish time between 70 and 120 s. At most 1 of 5 needs the retry.
17. In a 4-player side-by-side run, all four stumps, timers and bell lights are readable. The first finisher's bell is audible and visible to all.
18. No text appears over the board. The objective line is 12 words or fewer.

---

## 12. Open questions for the user

Three questions. Each has a recommended option first.

1. **Where does the 2:00 timer live on the Minimal HUD?**
   - (Recommended) A thin sunrise bar inside the goal plaque. It keeps the four elements and fits the dawn story.
   - Diegetic only: a big sun climbing the sky behind the stump, no HUD bar. Prettier, but hard to read on a split screen.
   - A fifth HUD element: a classic number clock. Clear, but it breaks "Minimal".
2. **How do the obstacles look and block?**
   - (Recommended) Two full-height root and stone walls that frame a 4-wide lane. Every layer stays 32 cells, no trap holes, easy to read.
   - Low scattered stones and roots (1 high) across the whole stump. Looks more natural, but every layer above grows to 52 cells and the level gets too long for 2:00.
   - The walls plus a few stones inside the lane. More variety, but 1-wide gaps appear and the first clear gets harder to teach.
3. **If first-timers miss 2:00 in the playtest, what do we change first?**
   - (Recommended) Make the soft retry +45 s. No change to the goal or the layout.
   - Raise the limit to 2:30.
   - Cut the goal to 2 clears.

## User decisions (2026-10-14, round 3)

- **Timer:** "fitting theme". The 2:00 timer is shown with a themed, in-world look that fits the meadow and the Hearth story, not a plain number clock. The art director designs it (for example a carved sundial or a hearth candle that burns down), and it stays readable at a glance. It replaces the "sunrise bar" option.
- **Obstacles:** two full-height walls (roots left, stones right) framing a 4-wide lane, 32 cells per layer.
- **Playtest tuning:** "nothing". The 2:00 limit, the 3-clear goal and the +30 s soft retry stay as designed. No pre-planned fallback.
