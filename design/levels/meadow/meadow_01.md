# meadow_01 "Stump Day"

Status: DRAFT r1 for user review. Author: level designer. Date: 2026-10-15.
Source of truth: `design/levels/levels.md` lines 64-97, its rows in section 4, user decisions in sections 7-9.
Replaces the level part of `design/levels/campaign/l01_meadow_01.md` (that file still has the 2:00 timer, the sundial, T and S pieces).
Order of work: mechanics, then story, then art. The level decides the art.
Rules obeyed: single player, a level is a scene, no timer between pieces, speed ramps, HUD shows the story objective, shapes from the 67-shape bank, Meadow 01-10 core objects only, no beige UI, no Nintendo IP, never "Tetris" in player text.

## 1. Summary

Level 1 is a block-stacking puzzle where full layers are a lever. An old Hearth Stump sits choked by roots (left) and stones (right).
You drop O, I and L blocks into a small 4x4 pit on top of it. Each full layer makes the stump shake and one grip lets go.
The pit grows 4x4, 6x4, 8x4, then the whole round stump shows, glows green and rings its bell. That is the win.
Nothing can run out. The pieces only fall faster. The sky goes from dawn to gold to sunset as the grips go.
Play time: about 2 to 4 minutes. Role: teach. Level type: funny. Ending: plain.

## 2. Walkthrough

Screen: 720x1280 portrait. The player watches the pit, NEXT, the Stump Grip meter and the sky.

**The first 10 seconds.**
- 0.0 s. Dawn. Camera looks down at the stump in its cage of roots and stones. The pit is a bright flat tree-ring floor. A plum-wood plaque slides in: "Free the Hearth Stump."
- 0.8 s. The Wizard's cloud floats in from the top right. He tips his hat and points at the stump.
- 1.4 s. A wooden spoon plops out of his hat. He flings it into the Wrong Sack. Plink. It never blocks input.
- 2.0 s. Input opens. A banner line fades in (section 4).
- 2.2 s. The first block tumbles from the hat brim. It glows gold. A warm hum starts. NEXT shows the following piece.
- 3.5 s. A root creaks and a stone wobbles. Cosmetic.
- 4.0 s with no input: a finger-and-arrow loop near the block (slide). It fades on first input.
- 8.0 s with no drop: a down-arrow pulses on the block (drop). A landing ghost is always visible.
- First lock: a warm hum note and a gold ripple through the tree rings.
- First piece that needs a turn: the best-fit outline shows, a curved arrow pulses after 3 s. Only for the first 2 such pieces.

**Stage 0, pit 4x4 (16 cells, 4 pieces per layer).** Roots wrap the left, stones wrap the right. Calm. The first full layer comes at about 25 to 45 s.

**Grip 1, left roots (first full layer).**
1. The last cell fills. The layer glows white-gold.
2. A ring of light sweeps the layer. Its blocks pop into sparkles. Blocks above settle one step.
3. The stump shudders. The left roots whip back with a twang.
4. The first knot on the Stump Grip meter turns green and drops off.
5. The pit is now 6x4 (24 cells, 6 pieces per layer). The walls of the released columns are gone in every layer. Sky shifts dawn toward gold. Camera widens.

**Grip 2, right stones (second full layer).** Same beat. A mossy stone rolls off the stump edge and bounces down the hill. Pit 8x4 (32 cells, 8 pieces per layer). The chimney starts to smoke. Sky is gold.

**Grip 3 and the win (third full layer).**
1. The third ring races to the rim. The front and back roots and stones tumble away.
2. The whole round stump shows, 52 cells of tree rings. No play now. Input is locked.
3. The stump yawns. The rings glow green from the centre outward. The bell rings.
4. The sky is sunset gold. Grass greens, wildflowers open, the chimney puffs, the waterfall sparkles.
5. The Wizard points. Ada cheers (optional cast). The result card appears 3 s after the bell.

**Top-out and soft rescue.** The stack reaches the height limit. Pieces stop at the red line. The Wizard's cloud floats over and scoops the lowest layers away with a giggle. Blocks above settle. It never releases a grip. The first 2 times only (see 3). Cloud sound: a soft whoosh and a giggle.

**Lose and restart.** The rescues are spent and the stack tops out again. The stump yawns, the blocks giggle back into their box. The level restarts in 2 s or less with a new seed. No clock, no retry timer, no penalty text.

## 3. Mechanics

**Platform.** Growing pit in a cage on the Hearth Stump. The cage is masked-off columns, switched on at load and off at each grip.

**Board.** `width 8`, `depth 8`, `h_play 8`, board height 12 with spawn clearance. Round mask (1 = cell):
`["..####..", ".######.", "########", "########", "########", "########", ".######.", "..####.."]` (52 cells).

**Cage (columns, full height, every layer).** `r` root, `s` stone, `.` pit, `-` cut.
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
Stage 0 pit: x2-5, z2-5 = 4x4. Walls add no stack height and are outside the clear count.

| Grip | Trigger | Columns released (all layers) | Pit after |
|---|---|---|---|
| 1 left roots | 1st full layer | x0-1, z2-5 | 6x4 = 24 cells |
| 2 right stones | 2nd full layer | x6-7, z2-5 | 8x4 = 32 cells |
| 3 rim | 3rd full layer (win) | z0-1 and z6-7 rim columns | full 52-cell stump, no play |

**Fairness.** Every stage is a plain rectangle: 16, 24, 32 cells, all multiples of 4. No pocket, no notch. Spawn columns x2-5 are always free. Any full layer counts, not only the bottom.

**Layer rule.** A layer is full when every free cell of the current pit in that layer is filled. Pieces are flat (spin only), so one piece covers one layer. Cells that were part-filled when the pit widens now need the new cells too. That is the intended change.

**Pieces.** Shapes O, I, L only, from the 67-shape bank. `spawn.randomizer = bag`, seeded, new seed every attempt, seed logged for replay. A bag holds O, I and L (3 pieces) in a random order. No `fixed_list`, no `opening_set`, no fixed opening. `spawn.preview_count = 1`, `spawn.hold_enabled = false`. Spin-only rotation gives no J, so L alone covers the L family. The bag must pass the tiling solver (G5): each stage tiles with O, I, L using a 1-lookahead bot and no hold, in at least 98% of seeds. If it fails, add a second L to the bag before changing shapes.

**Fall speed (no timer).**
- `fall.g0` start: about 1.2 cells per second per `levels.md` line 87 (first piece lands in about 9 s). TO BE MEASURED by G6 on gravity-only, soft-drop and hard-drop bots. The old data value 0.6 is about 18 s per piece and is too slow.
- Ramp: the frame says x1.25 per release. User decision (levels.md section 7) says a smooth ramp per minute, with releases only as story beats. These disagree. Data holds both: `ramp.per_release_mult` and `ramp.per_minute_add`. Default: per minute, `per_release_mult = 1.0`. The frame alternative is `per_release_mult = 1.25`, `per_minute_add = 0`. Both values TO BE MEASURED. See open question.
- Soft cap on the ramp so speed never exceeds 3x `g0`. TO BE MEASURED.

**Timing knobs.** `lock_delay_ms 900`, `lock_resets_max 15`, `entry_delay_ms 300` (guest-friendly, from the old spec; to be playtested).

**Height limit and rescue.**
- Height limit: `h_play 8` layers. The red line sits at layer 8.
- `goal.top_out = rescue`. Rescue wipes the lowest 3 layers (TO BE MEASURED), never releases a grip, never resets the Stump Grip meter.
- Rescue count: `goal.warnings_max = 2` (kept from the data). A third top-out restarts. TO BE MEASURED.
- No grace knob (cut by the frame).

**Goal.** Under the hood `clear_n`, `n = 3`, driven by the new rule `grip_release`. The player never sees a count. No `time_limit_ms`.

**Stars (neat play, no clock).** 3 stars: no rescue and few wasted pieces. 2 stars: one rescue or some waste. 1 star: any win. Thresholds from the plan formula (G5). TO BE MEASURED. Minimum pieces to win: 4 + 6 + 8 = 18 plus waste.

**Data keys.** `board.mask`, `board.cage` (stage masks), `grip_release.stages` (list of released column sets), `grip_release.trigger = "layer_clear"`, `fall.g0`, `ramp.*`, `goal.top_out`, `goal.warnings_max`, `rescue.layers`, `pieces.shapes`, `spawn.randomizer`, `hud.objective_key`, `hud.meter`, `look.*`, `scene.*`. All values in data, none hardcoded.

## 4. Story

**Place.** Hearth Stump on a meadow island. Dawn at the start.
**Cast.** Wizard (cloud, hat, wand). Ada appears only as a wordless cameo (hauls the root rope, cheers). The narrative beat file lists Ada for meadow_01. The frame names only the Wizard. See open question.
**Problem.** The old stump is choked by roots and stones.
**Why the stack matters.** Blocks are the pull on the stump. Full layers are the only way out.
**HUD objective (player text):** "Free the Hearth Stump." No count, no "before sunset".
**Banner lines (each 120 characters or fewer, in a banner, never loose text).**
- Before (2.0 s): Wizard: "Old stump is stuck! Stack it up and give it a good pull." (56 chars)
- After (3 s after the bell): Wizard: "There! The old stump is free. Hear that bell?" (45 chars)
**Wordless moment.** The spoon plops out of the hat. A careless block wobbles and giggles beside a tidy one (cosmetic, no cell moves).
**Ending.** Plain. The surprise is the wall change after each clear.
**Files to align (owner narrative director).** `beats/meadow.md` still says "Plant the Hearth Tower's first course" and meter "Hearth Hum".

## 5. Art and scene

**Camera.** 720x1280 portrait, high three-quarter view looking down at the stump. HUD in the outer 15%. A camera preset and a near-wall fade per stage (G22):
- Stage 0: tight on the 4x4 pit, cage walls in front fade to 40%.
- Stage 1: pulls back and widens to frame 6 wide.
- Stage 2: frames 8 wide, the pit fills about 80% of the screen width.
- Win: pulls back and up to show the whole round stump and the meadow.
Pit rows fill the middle two thirds. NEXT top right. Stump Grip meter left edge. Pause top left. Plaque top centre. Wizard's cloud top right behind NEXT.

**The stump.** A huge old stump, top cut flat, visible tree rings on the pit floor, bark sides down the island edge. Wide as the 52-cell octagon, a stage prop and reveal. Rings glow green on the win.
**Roots (left).** Thick mossy roots wrap the left columns like fingers. Chunky, rounded, lit top edge. On release they whip back and sink into the soil.
**Stones (right).** Mossy grey boulders stacked in the right columns. On release they roll off the edge and bounce down.
**Cage.** Roots and stones together read as a cage around the pit, front and back rim included. Walls are as tall as the 12 layers. Rim roots and stones tumble away on the win.
**Surroundings.** Floating meadow island rim with clover, grass tufts, wildflowers, a small cottage with chimney, a waterfall off the island, a windmill far away, distant floating islands, sparkles. Decoration stays on the rim and never covers the grid.

**Sky and light per release.** One grade driven by progress (G3):
- Stage 0: dawn. Pink-peach horizon, cool blue fill, long soft shadows.
- Grip 1: dawn warms to gold.
- Grip 2: full gold morning. Chimney smokes.
- Win: sunset. Deep orange and plum sky, warm rim light, the stump glow is the hero light.
Warm key from top left, cool fill. Light warms and never goes dark.

**Palette.** Meadow blocks per ref 13: dirt body, grass cap, clover, a sprout on some cubes. O, I, L tinted green, pink, yellow (ref 15). Roots warm brown with green moss, stones cool grey with moss. Brand UI tokens: `wood_purple #6b4a8a`, `gold #f8c840`, `vine_green #4f9a3a`, plum glass panel. Green glow `go_green #4cc04a` for the freed stump. No beige, no parchment.

**HUD.** Four elements only: purple-wood goal plaque, one NEXT slot (plum glass tile, biome vine frame), Stump Grip meter (three bark knots on a ring around a stump glyph, no numbers), pause gem. Meter states: tight (3 brown knots), loosening, nearly free, free (glyph glows green).

**VFX and sound per beat.**
- Start: soft dawn pad, birds, a creaking cage.
- Each lock: warm hum note, gold ripple through the tree rings.
- First turn: small green chime.
- Each release: white-gold layer glow, ring of light, camera shake 0.3 s, stump groan, root twang or stone rumble, then a brighter chord step.
- Top-out rescue: soft whoosh, cloud giggle.
- Lose: stump yawn, blocks giggle into the box.
- Win: bell (big clear note), chord resolves, joyful sting, petals and confetti, then a calm loop.

**Assets needed (PolyHaven / BlenderKit via Blender, restyled to the art bible, CC0 only, credited in `assets/third_party/CREDITS.md`).** Pick exact items at build time.
- Tree stump or log model with visible rings (stump base), bark texture set.
- Tree root and root-cluster models, moss patches.
- Boulders and mossy rock set.
- Grass, clover, ground and soil textures; wildflower and grass tuft models.
- Sky HDRIs: dawn, golden morning, sunset.
- Small cottage, windmill, fence, and a waterfall or rock cliff for the island rim.
- Barrel or sack prop for the Wrong Sack (optional).
Wizard, cloud, Ada, blocks and HUD come from the existing cast and UI kit, not from these libraries.

## 6. Image generator prompts

Style words for all: painted chunky toy-like storybook fantasy, soft rounded glossy shapes, hand-painted textures, rim light, warm golden-hour glow, premium mobile puzzle game, matching the reference boards in `assets/art/reference/style/` (15 title and HUD, 13 biome blocks, mockup 15 portrait).

**a. Hero shot, mid-play.**
Portrait 9:16 painted storybook game screenshot, high three-quarter view down onto a giant old tree stump on a floating meadow island at golden morning, a 6-by-4 pit of flat tree rings in the middle with chunky glossy green, pink and yellow grass-capped dirt blocks half stacked in it, one gold-glowing L block mid-fall with a glassy landing ghost, mossy boulders caged along the right edge and thick mossy roots already snapped away on the left, a small purple-robed wizard with a tall star hat and huge white beard riding a puffy lilac cloud at top right, a purple-wood plaque at top centre, a square plum-glass next-piece tile at top right, a thermometer-like meter with three bark knots on the left edge, a small cottage with a smoking chimney and a waterfall off the island rim, distant floating islands, wildflowers and clover on the rim, warm key light top left with cool fill, soft bloom and sparkles, game UI free of any readable text, no logos.
Negative: text, letters, logos, watermark, photorealistic, flat vector, beige or parchment panels, thin hairlines, Nintendo characters, mushrooms with faces, dark gloomy lighting, clutter over the pit.

**b. The win moment.**
Portrait 9:16 painted storybook scene, pulled-back high view of the whole freed round Hearth Stump on a floating meadow island at sunset, deep orange and plum sky, the stump top glowing emerald green from the centre outward through its tree rings, roots and mossy boulders tumbling away down the island edge, petals and golden confetti and sparkles bursting upward, a big brass bell shape of light ringing over the stump, a purple-robed wizard with star hat and white beard cheering on a lilac cloud and a small round-faced helper with a rope cheering below, wildflowers opening, cottage chimney puffing, waterfall glittering, distant floating islands in a sunset haze, chunky glossy toy-like shapes, rim light, warm glow, empty banner shape at the bottom with no text, no logos.
Negative: text, letters, logos, watermark, photorealistic, flat vector, beige or parchment, hairline borders, Nintendo characters, scary faces, grey dull sky, UI covering the stump.

**c. Asset and prop sheet.**
Portrait 9:16 painted game asset sheet on a plain soft blue-grey background, arranged in a tidy grid with generous spacing and no overlap: a huge old tree stump with flat top, visible tree rings and bark sides, a set of three thick chunky mossy tree roots curling like fingers, a set of three rounded mossy grey boulders, a cage made of interlocking roots and stones shown as one piece, a meadow dirt block with a thick grass cap and clover and a small sprout, a small cottage, a brass bell, wildflower and grass tuft clusters, each prop shown from a high three-quarter view, soft rounded glossy hand-painted style with lit top edges and rim light, warm key light top left, premium mobile puzzle game art, no text, no labels, no logos.
Negative: text, letters, labels, logos, watermark, photorealistic, flat vector, beige or parchment, Nintendo characters, hairline outlines, cluttered background, cropped objects.

## 7. Build checklist

**Files to change (owner: main session writes Godot code).**
- `src/levels/meadow/meadow_01/meadow_01.json` and `production/levels/meadow/data/meadow_01.json` (see below).
- New rule `grip_release` and core op `request_mask(x, z, true)` on all layers, layer counters rebuilt, a layout event for the view (G1, G2).
- Sky grade by progress (G3). Story objective on HUD, pause, level and result cards (G4). Hint set (G17). Cosmetic giggle (G18). Terrain `stump_top`, action `grip_release` in the closed list (G20). Camera preset and wall fade per stage (G22).
- Strings: `LVL_MEADOW_01_OBJECTIVE` = "Free the Hearth Stump.", before and after banner lines, `HUD_METER_STUMP_GRIP`.
- Art: stump, roots, stones, cage, island rim, three skies, Wizard and Ada poses.
- Update `design/narrative/beats/meadow.md`, `level-type-mix.md` (owners: narrative director, game designer).

**What must change in the existing data.**
- `src/.../meadow_01.json` (top level):
  - `board` 8x8 with no mask: add the round 52-cell mask and the cage stages. (The `design_spec` copy inside `metadata` says 4x4.)
  - `pieces.shapes` i,o,t,l,s: change to o,i,l. Remove `opening_set` and `opening_count`.
  - `fall.g0` 0.6: measure, set about 1.2 first; add `ramp.*`.
  - `goal` `clear_n` n=2: set n=3 and attach `grip_release`. Drop any layer-count wording.
  - `rules` `balloon`: remove. One new mechanic only. `level_type` funny: set to twist (mix file then lacks a funny meadow level; game designer decides).
  - `stars` t2 290000 / t3 210000 (milliseconds): remove. Replace with neat-play thresholds.
  - `hud` objective "Free the Hearth Stump before sunset.": change to "Free the Hearth Stump." Remove `clock` from `show`. Meter "Hearth Hum", `source goal_progress`, icon `hearth`: rewrite as "Stump Grip", `HUD_METER_STUMP_GRIP`, source `grip_release`, 3 knots.
  - `metadata.design_amendments` (8x8, balloon, funny): mark superseded. `metadata.status`: set to "Spec r1".
  - Add `story.objective_key`, `look` (dawn, high camera) and `scene` (terrain `stump_top`, set piece `hearth_stump`, action `grip_release`, cast Wizard:point, Ada:haul).
- `production/.../meadow_01.json`: board 4x4 only (no mask, no cage); same shape, goal (`clear_n` n=4), stars (145000/105000 ms), `fall.g0`, `rules` [] and missing `hud` fixes apply. Both files must agree. Decide one file as source and generate the other.
- `goal.warnings_max` 2: keep, to be measured.

**Tests to add (`tests/unit/`, `tests/integration/`).**
- `grip_release`: each of 3 clears releases the right columns in all layers; a rescue never releases; release rebuilds layer counters.
- Tiling solver and bag simulator: each stage with O, I, L, 1-lookahead, no hold; at least 98% of seeds win.
- Loader: `LevelLoader.load_level` returns no errors; `verify_campaign_biomes` passes.
- No player-facing string contains "clear", "layers", a count, "Tetris" or "before sunset".
- Speed ramp: fall rate rises per data, caps at the soft cap, and never stops play.
- Replay determinism with a logged seed.
- `input_simulate` wins on Buttons, Gestures, One-handed and Simple presets (ACC-10, ACC-16).

**Captures to take (`production/qa/evidence/`, side by side with ref 15 and 13).**
- Frame at 0 s, 5 s, stage 0 mid-play, post grip 1, post grip 2, win beat, rescue beat, lose beat. Each at 720x1280.
- One screenshot per stage proving the pit is readable behind the walls (G22).
- HUD at stage 0 (four elements only).

## 8. Acceptance criteria

1. Loads without errors. Pit 4x4, then 6x4 on the first full layer, then 8x4 on the second, then the full stump on the third.
2. The third release is a win. The result shows 3 s after the bell. No other win path exists.
3. No clock, no countdown, no timer text, no retry timer. The level can never end by time.
4. Pieces are only O, I and L, from a seeded bag, with a new seed every attempt. No fixed opening.
5. Speed rises as specified in data and stays at or below the cap. Start speed and ramp are measured (G6) and recorded here.
6. First block is on screen within 2.5 s. First input accepted by 2.2 s. First 10 seconds show the plaque, the Wizard and the spoon gag.
7. A rescue wipes the lowest layers, never releases a grip, and can happen the stated number of times. After that, a restart takes 2 s or less.
8. The HUD shows "Free the Hearth Stump." and the Stump Grip meter. No layer count, no number.
9. Every stage tiles with O, I and L in at least 98% of seeds.
10. Each stage is readable at 720x1280 with a retained screenshot. Pieces and the landing ghost read at a glance on a phone.
11. Sky moves dawn, gold, sunset with the grips, and it never goes dark.
12. Scenery comes from PolyHaven or BlenderKit assets restyled in Blender. Licences credited. No procedural scenery.
13. Art placed next to refs 15 and 13 looks like the same game and scores at least 9.7 from the reviewer panel. No beige or parchment UI.
14. No Nintendo IP, no "Tetris" in player text, no board logos.
15. A tester can win with one finger using toggle soft drop and repeat off (ACC-16).

## Decisions (2026-10-15)

1. Speed: steps x1.25 per grip release (not per minute). The per-minute ramp is removed (`ramp_per_release_mult 1.25`, cap 3x).
2. Ada: dropped. Only the Wizard appears.
3. Soft rescues: 3 (`goal.warnings_max = 3`).
4. `level_type`: "funny".
