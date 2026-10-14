# Level 1: meadow_01 "Stump Day"

Status: DRAFT r3 for user review. Author: level designer. Date: 2026-10-14.
r3 replaces r2. Reason: r2 broke the level rules (a counter goal, a fixed opening, no story action by the stack).
Rules read for r3: `design/levels/plans/level-identity-spec.md`, `design/levels/plans/minigame-party-rules.md`,
`design/levels/level-type-mix.md` and `design/levels/plans/campaign-vision.md`. See "Rules compliance" at the end.

User decisions (binding):
- **Story goal:** "Free the Hearth Stump". Roots (left) and stones (right) choke the old stump. Each full layer the player clears makes the stump shake one grip loose. The walls shrink and the play space changes. Win: freed before sunset (2:00). The stump wakes, glows green and rings its bell.
- **HUD objective:** "Free the Hearth Stump before sunset." The words "clear N layers" never appear anywhere the player can see.
- **Pieces:** a fair seeded random bag on every attempt. Never a fixed list. No fixed opening.
- **Kept:** soft rescue on top-out, +30 s soft retry once, cosmetic giggle, campaign single player, the round 52-cell stump, the Minimal HUD, the sundial medallion as the timer.
- Earlier: scene "Giant tree stump" built from PolyHaven/BlendKit assets; HUD "Minimal".

Facts checked in code (2026-10-14):
- Under the hood the goal is `clear_n` (`src/mechanics/goal/clear_n_goal.gd`). It is only the engine goal. The player never sees it.
- `rock_obstacle` places permanent rocks. It sets `fixed`, `anchored` and `clear_protected` (`src/mechanics/lava/rock_obstacle.gd:20`). A `fixed` cell can never be removed (`src/core/board/board_state.gd:685-686`). So `rock_obstacle` cannot shrink. A new rule is needed (section 10).
- Precedent for removing a rock: `lava_rock_spawn.gd:58` uses `api.remove_cell(cell, BoardState.Cause.DAMAGE)` on a rock that is not `fixed`. Precedent for reacting once per clear: `lava_rock_spawn.gd:49,55` stamps `clear_count` from the `on_clear` hook.
- Rocks (`rock` kind, glyph `R`) have `fills_layer = false`, so they are outside the clear denominator (`assets/data/content/blocks.json`).
- The timer exists: `goal.time_limit_ms`. A timeout today is a LOSS (`src/core/sim/board_sim.gd:751-752,763-764`). The +30 s retry is new.
- Pieces are flat (spin axis only), so one piece fills one layer. A layer can only be filled exactly if its free area is a multiple of 4. All stages below obey this.
- The HUD icon for `clear_n` is "layers" (`src/ui/common/snapshots/hud_snapshot.gd:13`). It must be replaced by the story objective for this level (NEW-8).

---

## 1. One-line pitch and objective

**Pitch.** An old stump is choked by roots and stones, and every full layer you stack makes it shake one grip loose.

**On-screen objective (6 words):** "Free the Hearth Stump before sunset."

Level card facts:
- Name: Stump Day. Biome: meadow. Tier 1. Role: teach.
- Verb: build. One mechanic: `grip_release` (walls that loosen with each full layer). That is the level's twist (`level_type`).
- Place and time: Hearth Stump, dawn, sliding toward sunset over 2:00. Cast: Wizard, Ada.
- Estimated play time: 60 to 120 s. Hard cap 2:30 with the soft retry.
- `metadata.signature` (13 words): "The Wizard's spoon pops out, and the choked old stump shakes itself free."
- `metadata.ending`: `plain`. Why: level 1 may not hide its goal, and the user's quota needs only 4 non-plain endings in the biome, placed from 04 on (vision U16, `campaign-vision.md:277-282`). The surprise in level 1 is the wall change after each clear, not a hidden goal.
- Opening event id: `spoon_pops_block_hums`.

---

## 2. Minigame: Free the Hearth Stump

**Verb.** Build. Drop a block. Turn a block. Fill the pit. Free the stump.

**Core loop.**
1. A block tumbles from the Wizard's hat brim.
2. Slide it, turn it, drop it into the pit between the roots and stones.
3. It locks with a warm hum.
4. When a whole layer of the pit is full, it clears. The stump shakes and one grip lets go: a root snaps back or a stone rolls off. The pit gets wider.
5. Three grips free the stump. The sundial medallion shows how much of the day is left.

**Win condition.** Free the stump: 3 full layers cleared before 2:00. Under the hood: `clear_n`, `n = 3`, `time_limit_ms = 120000`. The player sees only the story:
- The meter "Stump Grip" has three knots. Each cleared layer loosens one knot.
- When the third knot lets go, the stump is free. No number is ever shown.

**What the stack does in the story.** Each cleared layer is a pull on the stump. The stump shakes, a grip breaks, the walls shrink, and the play space grows.

**Fail condition.**
- Sunset (2:00) without freeing the stump: soft retry once. The Wizard tips his hat and holds the sun back. The sundial shadow winds back 30 s. The stack stays. If the extra 30 s also runs out, the sun sets, the stump yawns, blocks giggle into their box, and the level restarts in 2 s or less.
- Stack too high: soft rescue only. `goal.top_out = rescue`, `goal.warnings_max = 3`. The Wizard's cloud scoops the top blocks with a giggle. Never a restart.
- With walls up to the top and a pit that is at least 4 wide, a top-out is very unlikely.

**30-second grace.** For the first 30 seconds there is no top-out check, no warning and no red flash (`goal.grace_ms = 30000`, NEW-2). The sunset cannot arrive in that time either.

**Stars (the Wizard's thanks).**

| Stars | Rule | Reasoning |
|---|---|---|
| 1 | Free the stump, with or without the retry. | A guest never leaves with nothing. |
| 2 | Freed in 90 s or less (`t2 = 90000`). | The minimum is 18 pieces (4 + 6 + 8). At 4.5 s per piece that is 81 s. A calm player who drops often gets it. |
| 3 | Freed in 60 s or less (`t3 = 60000`), no warning, no trim. | 18 pieces in 60 s is 3.3 s per piece. It needs hard drops and tidy fits. |

Notes: the sums assume a random bag, so real runs will use 20 to 26 pieces. Overfilled blocks drop down and count for the next layer. First estimates; replace with playtest medians. A run that used the retry is capped at 1 star because its time is over 90 s.

---

## 3. Teaching beats, second by second

Rules for all beats: no text walls. Icons, glow, motion and sound only. The only words on screen are the objective on the plaque. Input is open from second 2. No beat blocks play.

The pieces are random, so hints adapt. The game checks the current piece against the pit. Hints appear only when they would help.

| Time | What happens | What the player learns | How the game shows it |
|---|---|---|---|
| 0.0 s | Dawn. The camera looks down at the stump in its cage of roots and stones. The sundial medallion shows a short shadow. | The stump is trapped. | The cage is tight and dark. The pit is the bright, flat tree-ring floor. The plaque slides in: "Free the Hearth Stump before sunset." |
| 0.8 s | The Wizard's cloud floats in. He tips his hat. | Someone is helping. | Wizard pose "point" at the stump. |
| 1.4 s | Out plops a wooden spoon. He flings it into his sack. Plink. | Tone: silly and kind. | The spoon gag. |
| 2.2 s | The first block tumbles from the hat brim. A warm hum starts. **(event in the first 10 s)** | A block is coming and it is mine. | The block glows gold. NEXT shows the following piece. |
| 3.5 s | A root creaks and tightens. A stone wobbles. | These are the problem. | A small camera nudge and a creak sound. Cosmetic. |
| 2.2 to 9 s | The block falls slowly. A bright landing marker shows in the pit. | Where it will land. | The marker is a high-contrast disc on the wood. |
| 4 s with no input | A finger-and-arrow loop near the block. | Slide the block. | Icon only. Fades on first input. |
| 8 s with no drop | A down-arrow pulse on the block. | Drop the block. | Icon only. At the baseline gravity a piece takes about 7 s to land alone, so a player who learns to drop saves time. |
| first lock (about 9 s, or when dropped) | **First lock.** | **Drop and lock.** | Warm hum note. A gold ripple runs through the tree rings. Ada cheers. |
| first piece that needs a turn | A faint glowing outline shows the best fit. A curved arrow pulses on the block after 3 s. | **Turn the block.** | Icon only. The outline turns green when the block matches. A chime. Shown for at most the first 2 such pieces. |
| when the pit has 8 or fewer empty cells | The empty cells pulse softly gold. | Fill these to finish the layer. | A glow on the empty cells. |
| about 20 to 30 s | **First full layer.** | **The big lesson: a full layer shakes a grip loose.** | See below. |
| after that | No hints unless the player idles for 6 s. | The player does it alone. | The empty-cell pulse stays. |
| 30 s | Grace ends. Nothing visible changes. | | |

**The first free (about 3 s). The big teaching moment.**
1. The last cell fills. The layer glows white-gold.
2. A ring of light sweeps across the layer. The blocks pop into sparkles. Blocks above settle down one step.
3. The stump shudders. Ada hauls on a root rope. The left roots snap back and spring away.
4. The first knot on the Stump Grip meter turns green and drops off.
5. The pit is now 6 wide. Wizard pose "point" at the new space.
6. Everything that moved shows why: a wall is gone, so there is more room.

**Pacing chart (intensity 0 to 5).**

| Time | Intensity | Note |
|---|---|---|
| 0 to 2 s | 1 | Intro, spoon gag. |
| 2 to 25 s | 1 | A small pit, no pressure. |
| 25 to 30 s | 3 | First grip breaks. Reward spike. |
| 30 to 60 s | 2 | A wider pit. The player chooses. |
| 60 to 90 s | 2 to 3 | Second grip breaks (stones roll off). The sun is lower. |
| 90 to 120 s | 3 | Third layer. The sky turns gold. |
| win | 4 | The whole stump frees. |
| 3 s after | 0 | Result card. |

Encounter list: none. The "encounter" is the cage and the sun.

---

## 4. Board: the round stump in a cage

**Size.** `width 8`, `depth 8`, `h_play 8`. The board height is 12 layers with the spawn clearance.

**Mask** (1 = cell, 0 = cut). Unchanged: the round 52-cell stump.

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

JSON rows: `["..####..", ".######.", "########", "########", "########", "########", ".######.", "..####.."]`

**The cage (stage 0).** `.` = free pit. `r` = root column. `s` = stone column. `-` = cut. The roots (left) and stones (right) are full-height columns, 12 layers. 36 columns. 16 free cells.

```
      x: 0 1 2 3 4 5 6 7
z=0      - - r r s s - -
z=1      - r r r s s s -
z=2      r r . . . . s s
z=3      r r . . . . s s
z=4      r r . . . . s s
z=5      r r . . . . s s
z=6      - r r r s s s -
z=7      - - r r s s - -
```

**How the walls shrink per clear (exact cells).** Three grips. Each release removes whole columns, in every layer.

| Grip | Trigger | What the player sees | Cells freed | Free pit after | Size |
|---|---|---|---|---|---|
| 1. Left roots | 1st cleared layer | The left roots snap back. | x 0 and 1, z 2 to 5 (8 columns) | x 0 to 5, z 2 to 5 | 6 x 4 = 24 cells (6 pieces) |
| 2. Right stones | 2nd cleared layer | The right stones roll off the stump. | x 6 and 7, z 2 to 5 (8 columns) | x 0 to 7, z 2 to 5 | 8 x 4 = 32 cells (8 pieces) |
| 3. The rim | 3rd cleared layer (the win) | The last roots and stones (front and back) tumble away. The round stump shows. | z 0, 1, 6, 7: 20 columns | the whole 52-cell stump | the win beat, no play |

Stage 1 (after grip 1):
```
      x: 0 1 2 3 4 5 6 7
z=2      . . . . . . s s
z=3      . . . . . . s s
z=4      . . . . . . s s
z=5      . . . . . . s s
```
Stage 2 (after grip 2): z 2 to 5 are all free, 8 wide. The rim rows (z 0, 1, 6, 7) stay walled until the win.

**Rules for the cage (what the engine does).**
- Does clearing a layer remove obstacles in it? **Yes, by design.** A cleared layer releases the next grip. The cleared layer's blocks are removed as usual. The released columns are removed in all layers, not only in the cleared one.
- How do the layers above fall? As usual: each layer above drops one step. The released columns are empty in every layer, so blocks never land on a vanished wall.
- Do wall columns count in the clear? **No.** The `rock` kind has `fills_layer = false`. A layer is full when every free cell in the current pit is filled.
- When the pit widens, the new empty cells appear in all layers. A layer that was part full now needs the new cells too. That is the intended change in play.

**Fairness (no unfillable layer).**
- Every stage is a plain rectangle: 4x4, 6x4, 8x4. No pocket, no channel, no notch.
- Free area is 16, 24, 32. All are multiples of 4, so a layer can be filled exactly with 4-cell pieces. This is a hard rule for the level data.
- The pit is always at least 4 wide and 4 long. A piece can rotate in it. Spawn columns x 2 to 5 are always free. The vision's spawn run of 4 (`campaign-vision.md:239`) holds.
- Walls are full height (12 layers), so a piece cannot slide over a wall and land on it, and no covered hole forms by resting on a wall.
- Any full layer counts, not only the bottom one. A hole in layer 1 does not block clearing layer 2.
- A solver checks that each stage can be tiled by the four shapes (O, I, L, T) and that a bag of 4 pieces leaves a winning line in at least 98 percent of seeds (see section 11).

**Why the round edge is fair.** The cut corners sit behind the rim columns and are never touched in play. The stump's round outline stays visible, and the full 52-cell round stump is revealed when the last grip lets go. The player never meets a narrow round-edge pocket.

---

## 5. Pieces

**Shapes (4 only):** O, I, L, T. S is dropped. Its skew is fiddly for a first-time player. S joins in level 3 or later.

**Order.** A seeded random bag, new on every attempt (`spawn.randomizer = bag`, the default). Each bag holds one of each shape in a random order. The seed is logged for replay. There is no `fixed_list`, no `opening_set` and no fixed opening. The loader accepts a missing `opening_set` (it defaults to empty).

**Preview.** `spawn.preview_count = 1`. One NEXT slot. `spawn.hold_enabled = false`.

**Fall speed.** `fall.g0 = 0.6`. This is the tier-1 baseline. The campaign levels 01 use 0.60 (meadow), 0.65 (candy), 0.72 (ice), 0.75 (underwater), 0.80 (pirate), 0.85 (lava, forest), 0.95 (cave, neon), 0.97 (clockwork), 1.14 (celestial), 1.20 (carnival). Meadow is first, so it takes the lowest value (current `meadow_01.json`: 0.6). No ramp in this level.
- Risk: at 0.6 a piece may take about 7 s to land alone, so the 2:00 timer pushes the player to use the drop gesture. That is the point of the level, but it must be tested. If first-timers fail the clock, lengthen the retry (+45 s) before touching `g0`. This is a playtest knob, not an open question.
- Units of `g0` are not confirmed in the data. The 7 s is a target to measure.

**Lock delay.** `fall.lock_delay_ms = 900` (default 500), `fall.lock_resets_max = 15` (default 10). A guest has time to nudge a block.

**Pause between pieces.** `fall.entry_delay_ms = 300` (default 200).

**Rules in the pill:** one only, `grip_release`. `sticky_landing` (named in the beat's minigame line) is dropped to obey one mechanic per level 1 (`campaign-vision.md:442`, U10). Its gentle feel comes from `g0` and the lock delay instead.

**Controls.** Slide, turn (spin only: `control.rotation_axes_enabled = ["spin"]`), soft drop and hard drop. Standard controls. No extra gem button.

---

## 6. Stump Grip meter (replaces "Hearth Hum")

**Proposed name: "Stump Grip".** The old name "Hearth Hum" described a hum that fills. Now the stump loses its grip. A meter that fills would also read like a counter. The new meter shows three bark knots that let go.
Alternatives: "Bark Bind", "Hearth Wake". The beat file lists "Hearth Hum" in `hud_meter` and needs a one-word update by the narrative director (open question 1).

**What it shows.** Three knots on a bark ring around a small stump glyph. No numbers.
- Tight: 3 brown knots, the glyph is dark.
- Each cleared layer: one knot glows green, then drops off the ring with a snap.
- Between clears, the ring creaks louder as the current layer fills (optional, NEW-3).
- Free: no knots, the glyph glows green.

**Visual states.**

| State | Knots left | Meter look | Scene look and sound |
|---|---|---|---|
| Tight | 3 | Dark bark ring. | Roots and stones hug the stump. Dawn light. A low creak per lock. |
| Loosening | 2 | One knot gone. | Left roots are gone. A warm chord joins. The sundial shadow is longer. |
| Nearly free | 1 | Two knots gone. | Right stones are gone. The cottage chimney starts to smoke. Light turns gold. |
| Free | 0 | Glyph glows green. | The end beat. |

**Timer: the sundial medallion.** A round bronze-and-purple medallion on the goal plaque. A shadow sweeps from dawn to sunset over 2:00. In the last 30 s the shadow pulses gently. In the last 10 s a soft tick sounds. Never red or loud. The scene's light also warms from dawn gold toward sunset gold (not darker) as time passes. After the retry, the shadow winds back 30 s.

**End beat (about 4 s). The payoff on the win.**
1. The third layer clears. The ring of light races to the rim.
2. The rim roots and stones tumble away. Grip 3 lets go. The whole round stump shows, with its tree rings.
3. The stump wakes: it shudders like a yawn, then the tree rings glow green from the centre outward.
4. The stump bell rings. A big clear bell note.
5. The grass greens and the wildflowers open. The cottage chimney puffs. The waterfall sparkles.
6. The Wizard points at the stump. Ada cheers.
7. The result card appears 3 s after the bell.

World change on win: the first block hums and the stump glows green.

**Audio cues.**
- Start: soft dawn pad, birds, a creaking cage.
- Each lock: a warm hum note.
- First turn: a small green chime.
- Each free: a stump groan, a snap or a rumble, then a bright chord step.
- Last 30 s: a gentle pulse. Last 10 s: soft ticks.
- Soft retry: a yawn and a long sun-hold note.
- Win: bell, chord resolves, short joyful sting, then a calm loop.

---

## 7. Moments of delight

1. **The spoon gag (0.8 to 2 s).** The Wizard tips his hat. A wooden spoon plops out. He flings it into the Wrong Sack tied to his cloud. Plink. This is item 1 of the Hat Dip gag (`campaign-story.md`, chapter 1). It never blocks input.
2. **The wobble-giggle block.** A block that locks with a hanging cell wobbles for 0.6 s and giggles. A tidy neighbour keeps its glow. It is cosmetic only: no cell moves, nothing is lost. The `wobble` rule is not used.
3. **The ring flash.** Each cleared layer sends a ring of light across the pit, like a tree ring. The third ring races to the rim and the bell rings.
4. **The root snap and the stone roll.** Roots whip back with a twang. A mossy stone rolls off the stump edge and bounces down the island. Ada hauls on the rope.
5. **The sun-hold.** At the retry, the Wizard tips his hat and the sun stops. A bird lands on the sundial.

---

## 8. Party play

The user decided: campaign is single player. Level 1 has no party mode.
For later use, side by side with the same seed would work natively, because the engine gives one board per player. The cage and the wall release are per board, so each player would free their own stump. No work is planned now.

---

## 9. HUD contract (Minimal)

Only these four elements show. Nothing else.

| Element | Shows | Position | Notes |
|---|---|---|---|
| Goal plaque | "Free the Hearth Stump before sunset." for the first 4 s. Then the short headline "Free the Hearth Stump". The sundial medallion sits on its right end. | Top centre | Purple wood, gold plaque, cream caps text. Not parchment. The medallion is part of the plaque, not a fifth element. |
| NEXT piece | One piece, drawn as the real block, in a small round frame. | Top right | `spawn.preview_count = 1`. |
| Stump Grip meter | Three bark knots around a stump glyph (section 6). | Left edge or bottom left | No number. |
| Pause | A round pause button. | Top left | Standard. |

Hidden until later levels: Hold, items, score, rule pills, extra buttons.
The teaching icons (slide, drop, turn, outline) are scene hints near the block. They are not HUD.
Player-facing text rule: no screen, tooltip, pause card, level card or result card may say "clear", "layers" or a count of layers. They use the story line.

---

## 10. Data: proposed level JSON diff

EXISTS = already in the engine. NEW = work needed, with a size.

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
+    "shapes": ["o","i","l","t"]
   },
   "knobs": {
     "fall.g0": 0.6,
+    "fall.lock_delay_ms": 900,
+    "fall.lock_resets_max": 15,
+    "fall.entry_delay_ms": 300,
+    "spawn.randomizer": "bag",
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
+    { "id": "grip_release", "params": {
+        "height": "full",
+        "base_columns": [ ... 36 columns, see below ... ],
+        "grips": [
+          { "id": "roots_left",   "on_clear": 1, "skin": "roots",  "columns": [[0,2],[1,2],[0,3],[1,3],[0,4],[1,4],[0,5],[1,5]] },
+          { "id": "stones_right", "on_clear": 2, "skin": "stones", "columns": [[6,2],[7,2],[6,3],[7,3],[6,4],[7,4],[6,5],[7,5]] },
+          { "id": "rim",          "on_clear": 3, "skin": "mixed",  "columns": [[2,0],[3,0],[4,0],[5,0],[1,1],[2,1],[3,1],[4,1],[5,1],[6,1],[1,6],[2,6],[3,6],[4,6],[5,6],[6,6],[2,7],[3,7],[4,7],[5,7]] }
+        ] } }
   ],
   "stars": {
-    "t2": 290000,
-    "t3": 210000
+    "t2": 90000,
+    "t3": 60000
   },
   "story": {
     "title_key": "LVL_MEADOW_01_TITLE",
     "premise_key": "LVL_MEADOW_01_PREMISE",
+    "objective_key": "LVL_MEADOW_01_OBJECTIVE",
     "mascot_role": "helper",
     "icon": "sprout"
   },
+  "look": { "time_of_day": "dawn", "weather": "petals", "set_piece": "hearth_stump", "set_piece_side": "back", "camera": "high", "dressing": "lush" },
```

`base_columns` is the union of the three grips, so the data lists each column once. In practice the rule builds the cage from the `grips` lists: all `columns` in all grips are rock columns at level start. No separate `base_columns` is needed (remove it from the final JSON).

Strings: `LVL_MEADOW_01_OBJECTIVE` = "Free the Hearth Stump before sunset." (6 words).

Also: delete `metadata.design_spec` (stale 4x4 copy). Set:
- `metadata.signature` = "The Wizard's spoon pops out, and the choked old stump shakes itself free."
- `metadata.ending` = `plain`
- `metadata.level_type` = `twist` (see Rules compliance and the flag below).
- `metadata.scene` = `{ "terrain": "stump_top", "set_piece": "hearth_stump", "set_piece_action": "grip_release", "cast_on_stage": "Wizard:point, Ada:haul", "hud_meter": "Stump Grip" }`.
- `metadata.footprint` = `octagon 8x8`.
- Note: `scene` is not a top-level key in the loader (`KEYS_TOP`, `src/data/level_loader.gd:7`). `look` is. Use `metadata.scene` until a top-level key is added (NEW-9).

**EXISTS (no work):** `board.mask`, `clear_n` with `n`, `goal.time_limit_ms`, `fall.*` knobs, `spawn.randomizer`, `spawn.preview_count`, `spawn.hold_enabled`, `goal.top_out = rescue`, `goal.warnings_max`, `goal.intro_card_ms`, `stars.t2/t3`, the `rock` kind and its `fills_layer = false`, the `on_clear`, `on_level_start` and `on_resolve_end` hooks, `api.remove_cell`, `api.set_status`, `api.emit`.

**To confirm with the Godot master (I could not verify):**
- That the clear check treats removed rock cells correctly: after a rock column is removed, its cell becomes an empty active cell, so the layer needs it filled. The layer counters must update (`BoardState._layer_filled`, `active_in_layer`).
- That rocks can be placed in the clearance zone (layers 8 to 11).
- That the validator accepts the new goal keys (`time_extension_ms`, `time_extensions_max`) and a missing `opening_set`.
- What `rescue` does on a top-out (`design/gdd/level-goals-fail-states.md`, not read).
- `fall.g0` units.

**NEW / engine gaps:**

| ID | Gap | Size | Owner |
|---|---|---|---|
| NEW-1 | Soft retry: on timeout, add `time_extension_ms` once instead of losing (two `_finish(LOST, time_limit)` sites, `board_sim.gd:751,763`), plus a sun-hold event for the UI. | 1 day | gameplay-programmer |
| NEW-2 | `goal.grace_ms` knob: no top-out check and no warnings for the first N ms. | 0.5 to 1 day | gameplay-programmer |
| NEW-3 | New rule `grip_release`. `rock_obstacle` cannot be extended in place: it marks cells `fixed`, and a fixed cell can never be removed (`board_state.gd:685-686`), and it has no `on_clear` hook. The new rule: builds the cage at `on_level_start` (rock kind, `anchored`, `clear_protected`, `fills_layer = false`, NOT `fixed`), counts clears with the `clear_count` stamp at `on_clear` (as `lava_rock_spawn.gd:49,55`), and releases the next grip at `on_resolve_end` by `remove_cell(cell, Cause.DAMAGE)` on every layer of each column. It emits `grip_loosened {id, cells, skin}` for the view. It takes a `columns` list and `height: "full"` so the data is 36 columns, not 432 cells. Needs a rule JSON in `assets/data/rules/` and unit tests (release order, no release twice, layer counters). Also a handbook entry (it counts toward U10). | 2 days | gameplay-programmer |
| NEW-4 | Adaptive hints: best-fit outline for the current piece, slide, drop and turn icons, and the pulse on the last empty cells. Show a hint only when it helps. Check if `mascot_hint` already covers part of it. | 2 to 3 days | gameplay-programmer + ui-programmer |
| NEW-5 | Cosmetic giggle on a lock with a hanging cell. No board change. | 1 day | gameplay-programmer + technical-artist |
| NEW-6 | Set piece `hearth_stump` in action: root snap, stone roll, rim tumble, tree-ring green spread, bell. Poses Wizard:point and Ada:haul and Ada:cheer. Scene build "Giant tree stump" from PolyHaven/BlendKit assets. Art list: stump top with visible rings and a round rim; the root and stone cage with two skins; a floating meadow island with grass, wildflowers and rocks; distant islands; the cottage with chimney smoke; the waterfall; the bell; the Wrong Sack. | 3 days (animations) + 2 days (intro) + 5 to 8 days (scene) | technical-artist + art-director |
| NEW-7 | Sundial medallion timer on the plaque, plus the dawn-to-sunset light grade. | 2 days | ui-programmer + technical-artist |
| NEW-8 | Story-objective HUD text per level: show `story.objective_key` instead of the `clear_n` "layers" icon and counter. Also for the pause, level and result cards. Plus the 3-second looping preview that shows a layer filling and a root snapping. This overlaps vision gaps "story-objective HUD text" (1 day) and "tutorial preview and 12-word line UI" (2 days). | 3 days (shared) | ui-programmer |
| NEW-9 | Add `scene` as a top-level key in `KEYS_TOP` and validate it (otherwise keep `metadata.scene`). | 0.25 day | gameplay-programmer |
| NEW-10 | Optional smooth meter creak between clears (layer fill value to the HUD). | 0.5 day | gameplay-programmer |

Total engine work: about 12 to 14 days of code and UI, plus about 10 to 13 days of art.

---

## 11. Acceptance criteria (testable)

Automated:
1. `meadow_01.json` loads with `LevelLoader.load_level` and returns no errors.
2. The mask has 52 active cells and the rows in section 4. The default spawn anchor (3,3) is active and free.
3. At level start there are exactly 36 rock columns, 12 layers each. The free pit is x 2 to 5, z 2 to 5 (16 cells per layer). No rock is `fixed`.
4. After the 1st cleared layer, columns x 0 and 1, z 2 to 5 are empty in all 12 layers. After the 2nd, x 6 and 7, z 2 to 5. After the 3rd, the rim columns. No grip releases twice. No grip releases without a clear. Grips release in the order roots, stones, rim.
5. Free area per layer is 16, then 24, then 32. Each is a rectangle and a multiple of 4.
6. A layer with all free cells filled clears and the layers above drop one step. A layer is not full while any free pit cell is empty. Newly freed cells count as empty cells.
7. Any full layer counts: a hole in layer 1 does not stop layer 2 from clearing and releasing a grip.
8. The pieces are only O, I, L, T. The sequence differs between attempts (two different seeds give two different first 12 pieces). No `fixed_list` and no `opening_set` in the file. The seed is logged.
9. The same seed gives the same sequence on replay.
10. A solver finds a winning line (3 clears) for at least 98 percent of 500 seeded bags; a loss counts only if no legal winning line existed (`campaign-vision.md:111`).
11. A bot that only drops (never turns) frees the stump within 120 s in at least 90 percent of 500 seeded runs. Turning is taught, not required.
12. At 120000 ms without the 3rd free, the game adds 30000 ms once and does not end. A second timeout loses and restarts in 2 s or less. (NEW-1)
13. With `goal.grace_ms = 30000`, a forced top-out stack at 29 s gives no warning and no loss. (NEW-2)
14. Stars: freed in 90 s or less gives 2. In 60 s or less with no warning and no trim gives 3. Any win gives at least 1. A retry run gives 1.
15. The Stump Grip meter loses knots monotonically and shows no knots at the win.
16. String check: no player-facing string in the level (plaque, pause, level card, result card, hints, tooltips) contains "clear" or "layers" or a count of layers. The objective string is 12 words or fewer.
17. Hint check: the turn hint appears only when a turn improves the fit for the current piece. It never appears on a piece that fits in its spawn orientation.
18. `metadata.signature` is set (13 words), `metadata.ending` is `plain`, and `metadata.level_type` is set.

Observed (retained screenshots in `production/qa/evidence/`):
19. Start frame at 720x1280: the stump in its root and stone cage, the pit, the plaque with the objective and the sundial medallion, one NEXT piece, the meter and pause. Nothing else HUD-like. Scene pixels (not board, not HUD, not plain sky) are at least 60 percent of the board's pixel area (P1c, `campaign-vision.md:85`). No beige or parchment.
20. Frames at: the spoon gag, the first lock, the first turn hint, the pulse on the last empty cells, the first free (roots snapping), the second free (stone rolling), the rim tumble and green stump, the sun-hold retry and the sunset fail.
21. Playtest with 5 first-time players: at least 4 say what to do from the start frame in 10 seconds (P3a, `campaign-vision.md:106`). At least 4 of 5 can say "a full layer frees the stump" after the first free. Median finish time between 70 and 120 s. At most 1 of 5 needs the retry.
22. The wall change is readable: after each free, the new space is visible and the player uses it within 5 s.
23. No text over the board. Wizard and Ada are posed on stage and act (point, haul, cheer).

---

## 12. Rules compliance

| Rule | How this spec meets it | Rule at |
|---|---|---|
| No mundane "clear N layers". The HUD shows a story objective, never a layer count. | The objective is "Free the Hearth Stump before sunset." The meter has bark knots, not numbers. Section 9 forbids "clear" and "layers" in any player-facing string. `clear_n` is only the engine means. | `level-identity-spec.md:64-68`; `campaign-vision.md:272-276` (U15) |
| Never mundane: an event in the first 10 s, a payoff on the win. | Event: the spoon gag at 0.8 to 2 s, the first block hum, the root creak at 3.5 s. Payoff: the stump wakes, glows green, the rim tumbles, the bell rings. | `level-identity-spec.md:81-82`; `campaign-vision.md:96` (P2a) |
| A level is a scene, not a grid. The board lives in a place; the cast is on stage; the set piece acts; a themed meter. | Place: the stump in a root and stone cage on a meadow island. Cast: Wizard:point, Ada:haul then cheer. Set piece: `hearth_stump` frees itself (root snap, stone roll, bell). Meter: Stump Grip. | `level-identity-spec.md:86-108`; `minigame-party-rules.md:21-23`; `campaign-vision.md:79-84` (P1b) |
| Closed lists for terrain and action ids. | Needs two change requests: terrain `stump_top` and action `grip_release` (a rule, because it removes blocks). Neither is on the list yet (`scene-vocabulary.md:21-37,41-53`). Flagged as open question 3. | `campaign-vision.md:283-294` (U17) |
| Fairness: random next block, never `fixed_list`. | A seeded bag per attempt. No fixed list and no fixed opening. | `level-identity-spec.md:25-26`; `minigame-party-rules.md:29-30`; `campaign-vision.md:418` |
| Teach in 3 seconds with a sentence of 12 words or fewer. | The objective is 6 words. A 3-second looping preview shows a layer filling and a root snapping (NEW-8). No text tutorial. | `minigame-party-rules.md:14-15`; `campaign-vision.md:100` (P2d) |
| Standard controls, at most one extra verb. | Slide, turn, drop. No extra gem button. | `minigame-party-rules.md:16-18` |
| Built on stacking: the stack does something in the story. | Each full layer frees one grip of the stump. | `minigame-party-rules.md:19-20`; `campaign-vision.md:93` (P2) |
| One signature sentence. | `metadata.signature` = "The Wizard's spoon pops out, and the choked old stump shakes itself free." (13 words, 4 to 14 allowed). | `level-identity-spec.md:21-22`; `campaign-vision.md:224` (U4) |
| Ending pattern recorded; level 1 may not hide its goal. | `metadata.ending = plain`. Reason in section 1. | `level-identity-spec.md:69-80`; `campaign-vision.md:277-282` (U16) |
| No standard rules: every level has a twist rule. | The rule `grip_release` is the twist. `level_type = twist` (layer clearing plus an unusual rule). | `level-type-mix.md:4,16` |
| At most one new mechanic; level 01 has one mechanic and a gentle `g0`. | One rule, `grip_release`. `sticky_landing` is dropped. `fall.g0 = 0.6` is the biome 1 baseline. | `campaign-vision.md:253` (U10), `campaign-vision.md:109` (P3c), `campaign-vision.md:442` |
| Spawn run of 4 wide; arms 3 wide; no dead-end pockets. | The pit is a rectangle, 4 wide at minimum, in every stage. Spawn columns x 2 to 5 are always free. | `campaign-vision.md:233-246` (U7) |
| Comic fail, restart in 2 s or less. | Second sunset: the stump yawns, blocks giggle into their box, restart. | `campaign-vision.md:108` (P3b) |
| Readability: target visible from frame 0; the active piece differs from the stack; high-contrast landing marker. | The cage and the sundial are visible at frame 0. The marker is a bright disc. | `campaign-vision.md:440` |
| Unique opening event id. | `spoon_pops_block_hums`. | `campaign-vision.md:248` (U8) |

**Flags for other owners (not changed here):**
- The beat file `design/narrative/beats/meadow.md` (meadow_01) still says `headline_objective: Plant the Hearth Tower's first course`, `hud_meter: Hearth Hum`, `problem: The island has a bare stump...` and `minigame: base: build_tower + sticky landing`. The narrative director should update it to match this spec.
- `level-type-mix.md` lists meadow_01 as `funny` (balloon) and counts it as the biome's only funny main level. Setting it to `twist` leaves meadow with no main-level `funny`, which breaks the mix target at `level-type-mix.md:21`. Another meadow level (for example 06 or 09) would need a `funny` twist, or meadow_01 stays tagged `funny`. Owner: game-designer.
- `scene.terrain` and `scene.set_piece_action` need new ids (technical artist).

---

## 13. Open questions for the user

Three questions. Each has a recommended option first.

1. **What is the new meter called?**
   - "Stump Grip" (Recommended): says what the player sees, the grip loosening.
   - "Bark Bind": cosier and more rhyming, less clear.
   - Keep "Hearth Hum": the beat file stays unchanged, but the name no longer fits a meter that empties.
2. **How does the play space grow?**
   - Rectangles: 4x4, then 6x4, then 8x4, then the round stump appears at the win (Recommended). Always tileable, always fair, 18 pieces minimum.
   - Round at the end: stage 2 becomes the 44-cell octagon minus the end rows. The round shape is played, not just revealed. More pieces (about 21 minimum) and edge steps that need a tiling check.
   - Start bigger: a 4x6 first pit. More pieces (22 minimum) and a slower first clear.
3. **Which scene ids do we add to the closed lists?**
   - New terrain `stump_top` and new rule action `grip_release` (Recommended): honest, because the action removes blocks and counts as a rule.
   - Reuse terrain `floating_island` (as in the beat) with the new action: scores 0 on the "same floating island" test (P1b).
   - Treat the root and stone moves as cosmetic `root_whip`: not allowed, because they remove blocks.
