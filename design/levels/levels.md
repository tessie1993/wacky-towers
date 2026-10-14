# Levels: Chapter 1 (Meadow) arc frame

Status: FRAME for level designers. Author: game director. Date: 2026-10-14.
Scope: the first 12 campaign levels in play order: meadow_01 to meadow_10, meadow_bonus, meadow_h1.
Later frames cover meadow_h2 and meadow_h3 and the other chapters.

## 1. Purpose and how to read it

This file is the frame, not the levels. Each level designer writes one level in full from its row, in the order
mechanics, then story, then art. Each aspect gets three blind experts at 9.7. A designer may change the detail
of a row. A designer may not change a level's verb, core mechanic, new thing, type, ending pattern or platform form
without sending it back to the game director, because the rest of the frame depends on them.

Rules this frame obeys:
- `level-identity-spec.md`: no "clear N layers" goals, a level is a scene, endings that surprise, and every level has its own platform made from its description.
- `minigame-party-rules.md` rules 1 to 5, and the user line "minigames are the level; the game mechanics will be the base of each level".
- `level-type-mix.md`: Meadow main levels 01 to 10 hold all six types.
- `reference-quality-bar.md`: the references are style, not literal layout.

User decisions already made for level 1 (binding, kept as they are):
- The goal is "Free the Hearth Stump before sunset."
- Roots and stones cage the stump. Each full layer releases one grip.
- The timer is the sundial medallion.
- The meter is "Stump Grip": three bark knots that let go.
- Pieces come from a seeded random bag on every attempt. There is never a fixed list or a fixed opening.
- The campaign is single player.
- Top-out is a soft rescue.
- Running out of time gives one soft retry of +30 s, once.

What the two expert reviews of level 1 found, and how this frame answers each (details in `l01_meadow_01.md`, to be rewritten):
- Rock walls cannot shrink with the current engine. The cage becomes masked-off columns that are switched on by a release (gap G1). It is not a wall of rocks.
- The T piece breaks the layer parity, so the first layer cannot be filled. Spin-only rotation never gives a J, so J is not an option. Level 1 uses O, I and L only. Every later level that adds T must pass the tiling solver with a 1-lookahead bot and no hold (gap G5).
- Rock that counts as stack height breaks the top-out. Masked columns (`static_geometry`) add no height, so the first lock is safe.
- Also from the review: a camera plan and wall fade per stage (gap G23), stars from the plan formula (gap G5), a `verify_campaign_biomes` check in every level's acceptance list, and the three-knot meter is considered as a continuous grip ring (open question 2).
- The fall speed makes the 2:00 timer unfair. `fall.g0` is in cells per second, so 0.6 is about 18 s per piece. Level 1 takes a measured `g0`, the sundial pauses during the release beats, and the limit comes from a piece budget, not from a round number (open question 1).
- Meadow lost its funny level. Meadow_08 is now the funny level.
- Also fixed: rescue wipes the bottom layers, and a wipe never releases a grip. The grace knob is cut. The hud block, meter name and objective key must be rewritten in the JSON.

## 2. Chapter 1 arc

The player journey is wonder and welcome. The world is kind. Gert is a nuisance, never a threat. She is lonely, and that is
only revealed at meadow_10.

### Teach (01 to 03)
- 01 Stump Day: drop, turn, finish a layer, and see that a finished layer changes the board.
- 02 Windbreak: a block wall can protect something. Something can attack it from the side.
- 03 Brook Gap: a clock can be a hazard that chases the stack, not a timer on the wall.
- **At the end of the first third the player can** drop and turn a piece on purpose, finish a layer, wall off a thing that needs shelter, and build a path ahead of a rising hazard.

### Twist (04 to 06)
- 04 Sheep on the Run: the stack steers living things (sheep wander and blocks fence them).
- 05 Gnome Hedge: things hit the stack (stones knock holes out of a wall) and the player repairs it.
- 06 Blanket Patch: the stack must match a picture exactly.
- **At the end of the second third the player can** steer wandering actors with blocks, repair damage under fire, and fill a target shape cell for cell.

### Combine (07 to 09)
- 07 Fog Frolic: build tall while the view is blocked. It joins height with trust in the preview.
- 08 Bouncy Lambs (funny): build a path with a wild surface. It joins the bridge idea with silly physics.
- 09 Tilting Hill: balance on a plate that tips. It joins shelter and counterweight.
- **At the end of the third the player can** build tall without seeing the top, plan around chaotic pieces and surfaces, and keep a stack balanced on a moving base.

### Boss (10) and after
- 10 Gert's Whirl: three phases recall 02 (windbreak), 04 (pen) and 09 (tilt-proof tower). Gert is lonely, not beaten.
- bonus Kite Day: a playful race against Gert, now a friend. Nothing is needed to pass the chapter.
- h1 Beanstalk Rescue: a fast remix of 03 (bridges), 04 (rescue) and sprouts.

Emotional line: wonder (01), delight (02, 03), mischief (04), a laugh and a surprise (05), calm pride (06), curiosity in the fog (07), pure silliness (08), tension that is still kind (09), release and a tear (10), joy (bonus), a clever dare (h1).

## 3. Mechanics ladder

Verbs used: destroy 01, defend 02 and 10, race 03 and bonus, rescue 04 and h1, survive 05, build 06 and 07, carry 08, balance 09. All eight verbs appear.
No two levels share the same verb, mechanic and goal. Types in 01 to 10: twist 3, defender 3, race 1, completing 1, funny 1, balance 1.
Endings: 3 plain (01, 06, bonus) and 9 not plain. No pattern is used more than twice in the chapter.

"Engine goal" is the goal id the engine runs. The player only ever sees the story objective (section 5).

| Level | Verb | Core mechanic (the base) | New thing taught (max 1) | Level type | Ending | Difficulty knob trend |
|---|---|---|---|---|---|---|
| meadow_01 Stump Day | destroy | Full layers break a cage. Engine goal `clear_n`, hidden from the player. | `grip_release`: walls that loosen with each full layer | twist | plain | Pit grows 4x4, 6x4, 8x4. Sundial limit from a piece budget. `g0` measured (cells per second). Pieces O, I, L only. |
| meadow_02 Windbreak | defend | `defend_core`: a sprout core with hit points. Wind attacks from one side. Engine goal `survive`. | `defend_core` (the first protected thing) | defender | twist: the wind swings round and the star-sign weathervane warns first | Attack gap 12 s down to 8 s. Warning 2.0 s down to 1.5 s. Core hit points 3. |
| meadow_03 Brook Gap | race | Span a gap before water rises. Engine goal `span` (the `bridge_dash` module). | `span` plus rising water (a skin of `rising_silt`) | race | guest: Biscuit and the flock cross early | Gap 5 cells to 7. Water rise speed up. |
| meadow_04 Sheep on the Run | rescue | Herd: blocks fence a lane and steer wandering sheep. Engine goal `rescue_all`. | `herd` (sheep wander; fences steer them) | twist | twist: the last sheep is Bram in a fleece | Sheep 4 to 6. Wander speed up. Two gates, then three. |
| meadow_05 Gnome Hedge | survive | `storm_bolt` stones knock cells out of a hedge wall. Hold out until the stones run out. Engine goal `survive`. | `storm_bolt` (the first projectile hazard) | defender | reveal: the last hole opens from inside, where a sheep peers at the windmill | Stone gap 12 s down to 7 s. Warning shortens. Wall is 2 cells thicker at the start. |
| meadow_06 Blanket Patch | build | `fill_shape`: match a picture cell for cell. Engine goal `shape`. | `fill_shape` (a target picture) | completing | plain (a small arrow payoff, no surprise) | Picture grows from 3 patches to 5. Patch shapes get odder. T may join here only if the solver proves every patch tileable. |
| meadow_07 Fog Frolic | build | Raise a lookout while fog hides the top. Engine goal `height`. | `fog` (the view is blocked) | twist | reveal: the glow in a bonnet ribbon is Keystone one | Fog thicker with height. Target height up. `g0` up a little. |
| meadow_08 Bouncy Lambs | carry | Build a lily-pad path so a lamb bounces to the far bank. Engine goal `span` (walker). | `bounce_pad` (pads that fling pieces and the lamb) | funny | secret: bounce the lamb through the windmill hoop for an extra star | Pad count 2 to 4. Pad strength is wilder. Pond width up. |
| meadow_09 Tilting Hill | balance | `tilt_plate`: the plate tips as weight shifts. Counterweights level it. Engine goal `survive`. | `tilt_plate` (a tipping platform) | balance | guest: Gert slides in laughing | Slip threshold 0.7 down to 0.5. Slip count 1 to 2. |
| meadow_10 Gert's Whirl | defend | Boss with three phases, by `bonk_boss` and `active_after_clears`. Phase 1 windbreak, phase 2 pen, phase 3 tilt-proof tower. Engine goal `bonk_boss`. | none (recall of 02, 04 and 09) | defender | story: Gert was only lonely | Each phase is faster than its first level. Peak of the chapter. |
| meadow_bonus Kite Day | race | `race_rival`: a rival kite climbs as you build. Engine goal `height`. | `race_rival` (a racing partner) | race | plain | Rival rate 0.9 up to 1.1. Rubber band on. Short and playful. |
| meadow_h1 Beanstalk Rescue | rescue | Spans between growing stalks bring lambs down. Engine goal `rescue_all`. | none (remix: `span`, `sprouts`, fast) | twist | secret: a golden lamb sits on the tallest stalk | `g0` above tier 10. Sprouts grow every 2 locks, then every lock. Fewer free cells. |

Notes for the designers:
- Level 1 is the only level with `grip_release`. Nothing in 02 to 10 may reuse it as a new thing.
- `defend_core`, `race_rival` and `tilt_plate` exist in `src/mechanics/wave4` and no level uses them yet. Treat them as unproven (gap G9).
- Hazards in 02, 05 and 09 are all random in timing. None of them may use a fixed list of pieces.
- Every level has an event in the first 10 seconds and a payoff on the win. The opening events are the ones in `meadow.md`, except where section 5 changes them.

## 4. Platform plan

Each platform is derived from its level description. The form is the first column. No two levels share a form.
Twin stages are kept back for meadow_h2.

| Level | Platform form | One-line description |
|---|---|---|
| meadow_01 | Growing pit in a cage | The stump top is a 4x4 pit caged by roots and stones. It widens to 6x4 and 8x4 as grips let go. The full round stump shows on the win. |
| meadow_02 | Crescent ledge | A curved hilltop ledge hugs a sprout bed. The wind comes from the open, convex side. The sprout sits in the inner curve. |
| meadow_03 | Plank bridge | Two grassy banks with a brook pit between them. The span is built from the bank edges. The water rises up the pit. |
| meadow_04 | Sheep pen with gates | A pasture lane runs to a pen with two gates. Blocks fence the lane. The pen sits at the elbow of the lane. |
| meadow_05 | Hedge court | A three-sided U court inside a hedge wall. The open end is the gate. The hedge wall is the thing under attack. |
| meadow_06 | Terraced flower bed | Three stepped terraces form the bed. Each layer has a different mask. The whole picture reads from above. |
| meadow_07 | Lookout scaffold | A narrow timber scaffold on a hilltop. It stands in fog. The camera is tall and the top fades into mist. |
| meadow_08 | Lily-pad stepping stones | Separate pads scattered across a pond. The player builds the path between them. Pads bounce. |
| meadow_09 | Tilting hilltop plate | A round plate on a pivot under the windmill. It visibly tips. A rim marks the edge sheep slide off. |
| meadow_10 | Spiral mill ramp | A spiral ramp winds up the windmill hill. Each phase opens the next turn. The mill tower is the last stage. |
| meadow_bonus | Kite cart track | The board rides a cart on a rail along a ridge and moves with the player. A kite climbs above it. |
| meadow_h1 | Beanstalk comb | A row of separate tall stalk columns, joined by rope bridges the player builds. The lambs wait on top. |

Check: crescent, span, pen, court, terraces, scaffold, stepping stones, plate, spiral, cart track and comb are ten different forms, with the cage pit as the eleventh and a growing one. Twelve levels, twelve forms.
The playable platform in 01 is the pit. The 52-cell octagon is a stage prop and a reveal.

## 5. Story spine

The story one-liner is what the level is about. The HUD objective is 12 words or fewer and never contains a count.
The Hat Dip gag (the Wizard pulls out a wrong object each chapter) stays in the opening event of meadow_01 (the wooden spoon).
Gert is a friend from meadow_10 on.

| Level | Story one-liner | HUD story objective |
|---|---|---|
| meadow_01 | The Wizard's spoon pops out, and the choked old Hearth Stump shakes itself free. | Free the Hearth Stump before sunset. |
| meadow_02 | The Wizard nails a gold star to a sprout stake, a puff bends it flat, and a curved wall saves it. | Shelter the sprout until the wind drops. |
| meadow_03 | The brook swallows the footpath, Biscuit barks from the far bank, and the whole flock follows the bridge. | Bridge the brook before the water rises. |
| meadow_04 | Gert zips past, the flock bounces like popcorn, and the last sheep through the gate is Bram in a fleece. | Herd the flock into the pen. |
| meadow_05 | Gnomes lob stones at the hedge, and the sheep inside are pushing out to see the windmill. | Keep the hedge shut until the stones run out. |
| meadow_06 | The picnic blanket lies in shreds, and mending the flower bed draws an arrow to the windmill. | Mend the flower bed pattern. |
| meadow_07 | Fog hides the flock, a lookout lifts Biscuit above the mist, and Ada spots a glow in a bonnet ribbon. | Raise a lookout above the fog. |
| meadow_08 | Fat dewdrops turn lily pads into trampolines, Bram shades a lamb with a huge leaf, and the lamb bounces home. | Bounce the lamb across the pond to the picnic. |
| meadow_09 | Gert spins the windmill sails backward, the hill tips like a tray, and she slides down giggling. | Level the tipping hilltop. |
| meadow_10 | Gert holds Keystone one in her ribbons, three builds tire her out, and she cries a little and joins the picnic. | Calm Gert and free Keystone one. |
| meadow_bonus | Gert, now a friend, flies a kite with the picnic hamper tied on, and the Wizard's cloud is towed as the tail. | Lift the picnic kite over the gorge first. |
| meadow_h1 | Gert's last seeds shoot into beanstalks with lambs on top, and rope bridges bring them down. | Bring the lambs down the beanstalks. |

Changes from the story draft (`campaign-story.md`, `beats/meadow.md`). The narrative director updates both files:
- meadow_01: verb build becomes destroy. Objective, problem and meter change to the stump cage and "Stump Grip".
- meadow_05: verb defend becomes survive. The plug rule `plug_breach` is replaced by `storm_bolt` stones.
- meadow_08: "Leafy Roof" (shelter the lamb) becomes "Bouncy Lambs" (funny, carry). Bram's big leaf stays. It is a leaf, not an umbrella.
- meadow_bonus: verb carry becomes race. The kite and the hamper stay.
- meadow_h1: the ending is now secret (golden lamb).
- Mix file `level-type-mix.md`: update the Meadow table and summary to this frame. Owner: game designer.

## 6. Shared kit and engine gaps

### Mechanics reused across the 12 levels
- Base clearing of full layers: every level. 01 is the lesson. In 06 and 10 it fills or breaks things.
- `defend_core`: 02, and phase 1 of 10.
- `gust` and wind attacks: 02, phase 1 of 10, 09 (wind on the plate), bonus.
- `span` and the walker: 03, 08, h1. The module is `bridge_dash` in `src/core/modules`.
- Herd and fences: 04, phase 2 of 10.
- `storm_bolt`: 05, and a stone volley in 10 as a recall.
- `fill_shape`: 06 only. Its bag-parity check is shared by all levels.
- `fog`: 07 only, and h1 at night may reuse it.
- `bounce_pad`: 08 only.
- `tilt_plate`: 09, and phase 3 of 10.
- `race_rival`: bonus only.
- `sprouts`: h1 only.
- Soft rescue and the one +30 s retry: every timed level (01, 03, 05, 09 and the boss).

### Platform kit pieces (reused)
- Island mask builder (`WtIslandBuilder`) and the per-level masks: all twelve.
- Plank and rope bridge kit: 03, 08, bonus, h1.
- Sheep, lamb and gnome actors: 04, 05, 08, 10, h1.
- Windmill and sails (animated): 07, 09, 10, bonus.
- Hedge segments: 05, 04 (fence skin), 10.
- Wind particles and weathervane star sign: 02, 09, 10, bonus.
- Water shader (brook and pond): 03, 08.
- Fog volume: 07, h1 at night.
- Cast poses: Wizard, Ada, Bram, Sif, Biscuit, Gert. Sundial plaque. Goal plaque and meters from the no-beige HUD kit.
- Closed-list additions: new terrain `stump_top` and new action `grip_release`. Others come from the existing lists.

### Engine gaps
Sizes are in working days and are estimates. Owners are roles.

| ID | Gap | Used by | Size | Owner |
|---|---|---|---|---|
| G1 | Cage release as a core board operation: masked-off columns switched on by `request_mask(..., true)` on all layers, layer counters rebuilt, a layout event for the view, replay support. Then the rule `grip_release` on top. | 01 | 5 to 6 | lead-programmer (core), gameplay-programmer (rule), systems-designer (spec) |
| G2 | Soft retry: +30 s once instead of a loss on timeout. A state machine with the win checked first. The extension is in the replay snapshot. | 01, 03, 05, 09, 10 | 1.5 | gameplay-programmer |
| G3 | Pause the sundial and the clock during release beats, the end beat and the sun-hold. | 01 | 1 | gameplay-programmer, ui-programmer |
| G4 | Story objective on the HUD, pause card, level card and result card. It replaces the `clear_n` "layers" icon and any count. Meter source that does not publish a layer count. | all | 3 (shared) | ui-programmer |
| G5 | Tiling solver and bag simulator: parity check of each stage for the shape set, minimum and median piece counts, star time model. No J exists with spin-only rotation. Shape sets per level come from this tool. | all, first 01 and 06 | 3 | systems-designer, gameplay-programmer |
| G6 | Measure `fall.g0`: time per piece for a gravity-only, soft-drop and hard-drop bot. Set the 01 timer from the result. | 01 and all timed levels | 0.5 | systems-designer |
| G7 | Herd module (sheep wander, fences steer, pen gate is the goal). Module handbook entry. | 04, 10, h1 | 6 to 8 | gameplay-programmer, systems-designer |
| G8 | Rising water hazard (a skin of `rising_silt`) with a view. | 03 | 1.5 | gameplay-programmer, technical-artist |
| G9 | Wire and verify unused rules: `defend_core` with a wind attack skin, `race_rival` with a kite view, `tilt_plate` with a visible tilt. Each needs a unit test and one level run. | 02, 09, bonus | 4 (1 to 2 each) | gameplay-programmer |
| G10 | Lamb walker with bounce pads on the span goal, so a lamb is flung along the path. | 08 | 3 | gameplay-programmer |
| G11 | Wind schedule: the wind swings direction at a set time (a param change with a warning). | 02, 10 | 1 | gameplay-programmer |
| G12 | Stone skin and a sheep peek view for `storm_bolt`. A fail rule for open holes, agreed by game designer and systems designer. | 05 | 2 | gameplay-programmer, technical-artist |
| G13 | Boss phases are run with `bonk_boss` and `active_after_clears`. Phase hand-over beat (camera and cast). No new goal code. | 10 | 2 | gameplay-programmer |
| G14 | Goal phases (goal A, then goal B) and hidden goals. Needed only for reveal endings that change play. In Meadow 07 can fall back to a cosmetic reveal at the win. | 07 (optional), later chapters | 4 to 5 | systems-designer (spec), gameplay-programmer |
| G15 | Secret ending hook: an optional hidden condition gives an extra star. | 08, h1 | 2 | gameplay-programmer, systems-designer |
| G16 | Moving platform: the board rides a cart on a rail and the camera follows. | bonus | 5 to 7 | lead-programmer, technical-artist |
| G17 | Per-layer masks (terraces) and disconnected cells (stepping stones). Check that the mask loader supports both. | 06, 08 | 1 to verify, 2 to fix | gameplay-programmer |
| G18 | Hints: best-fit outline, slide, drop and turn icons, pulse on the last cells. A 3-second looping preview. Hint priority rules. | 01 first, then all | 5 | ui-programmer, gameplay-programmer |
| G19 | Cosmetic giggle on a hanging lock. No board change. | 01 | 1 | gameplay-programmer, technical-artist |
| G20 | Platform art, one per level, and its animated set piece (root snap, hedge hits, tilt, rail). About 3 to 5 days each, 01 is bigger. | all | 45 to 60 total | art-director, technical-artist |
| G21 | Closed-list additions for terrain and set-piece action ids (`stump_top`, `grip_release`, and any new ids from this frame). | 01 | 0.5 | technical-artist |
| G22 | Update `level_type` tags and the mix file to this frame. | all | 0.25 | game-designer |
| G23 | Camera preset and near-wall fade per stage, so a pit sunk in walls stays readable at 720x1280 as its aspect changes. A retained screenshot per stage. | 01, then all | 2 | art-director, technical-artist, level-designer |

Order of work. First G6, G5, G1, G2, G3 and G4, so level 1 can ship alone. Then G9, G11 and G8 for 02 and 03. Then G7 for 04. Then G12, G17, G10, G13. G16 and G14 last.
Level 1 total (G1 to G6, G18, G19, G21, G23): about 21 to 23 days of code and UI, plus its platform art.

## 7. Open questions for the user

Each has a recommended option first.

1. **How long is the level 1 sundial?**
   - Piece-budget timer (Recommended): the limit is about 1.4 times the expert median (about 2:30), `g0` is measured so an undropped first piece lands in about 9 s, and the sundial pauses during release beats. Fair and still tense.
   - Keep 2:00 and `g0` 0.6: about 18 s per piece without a hard drop, so first-timers lose unless they find the hard drop at once.
   - Keep 2:00, pause during beats, raise `g0` to about 1.2: a middle path, still tight for new players.
2. **How does the Stump Grip meter show progress?**
   - Keep three bark knots (Recommended): you already chose it. Pieces are O, I and L only, so the first layer is fillable.
   - A continuous grip ring that loosens as the layer fills: no visible count of 3, as the reviewers suggested, but it needs more view work (about 1 day).
   - Both: knots plus a creaking ring between clears.
3. **Do you accept the verb recasts?** Meadow_01 becomes destroy, meadow_05 becomes survive, meadow_08 becomes the funny carry level (Bouncy Lambs), and the bonus becomes a kite race against Gert.
   - Accept all four (Recommended): all eight verbs appear and Meadow keeps a funny level.
   - Keep 05 as defend: then defend appears three times (02, 05, 10) and survive disappears from the chapter.
   - Keep the bonus as carry: then 08 must give up carry and the funny level loses its verb.
4. **How does the bonus Kite Day get its moving platform?**
   - Build the real moving rail platform, after levels 01 to 10 (Recommended): it is the form you asked for and does not block the chapter. About 5 to 7 days.
   - A fixed board with a scrolling backdrop: about 1 day, but it breaks the "own platform" rule in spirit.
   - Swap the bonus onto twin stages and move the cart track to a later chapter: no engine cost, a different race.
5. **Does meadow_07 need a real goal change at the reveal?**
   - Cosmetic reveal at the win (Recommended for Meadow): the lookout is done, then the glow shows. No goal-phase code. The real goal phases are built for chapter 2.
   - Real second goal: after the lookout is raised, hold it steady for 10 s while Biscuit points. Adds 4 to 5 days (G14) and moves a lot of risk into level 7.
