# Toy-Box Trials: standalone arcade pack

> **Status:** implementation specification and creative review, 2026-10-10.
> **Scope:** nine single-player practice stages on `feat/minigame-arcade-pack`.
> **Creative references:** `.claude/agents/creative-director.md`, `game-designer.md`, `level-designer.md`, `writer.md`.
> **Sources:** `tournament-minigames.md` MG4/MG1/MG10; `game-concept.md`; `narrative/README.md`; `narrative/characters.md`; `design/levels/meadow.md`, `clockwork.md`, `celestial.md`; `design/art/art-bible.md`.

## Overview

Toy-Box Trials adds three independent Godot minigames, with a lesson, a remix and a mastery stage for each. Perfect Stack combines timing, shrinking support and optional magnet recovery. Hole in the Wall combines three-dimensional rotation, translation, changing projection axes and a limited time-focus ability. Shadow Workshop combines two silhouettes, spatial construction, a cube budget and forbidden cells. The stages use Meadow, Clockwork and Celestial toy dioramas without replacing campaign levels. Story intent gives each rule a visible reason: build a picnic lookout, deliver a gear, or draw a constellation. The existing tournament specification remains authoritative for multiplayer; this pack is playable single-player practice and an integration boundary for later tournament work.

## Player Fantasy

“I recognise these blocks, but this little toy set asks me to use them differently.” The first stage gives a clear success, the second asks the player to combine known actions, and the third rewards deliberate mastery. Challenge and Discovery drive play; chunky Blender art supports Sensation. The player remains the cloud wizard. Pip stays in Meadow, Tock in Clockwork and Comet in Celestial. These are optional practice vignettes, not a new campaign ending, keepsake or unlock requirement.

## Detailed Design

### Shared round and content rules

1. Each stage lives in `minigames/arcade_pack/levels/` as JSON. Its stable `id`, `mode`, `name`, `biome`, one-sentence `rule`, `controls`, `time_limit`, `star_times`, numeric tuning and human-readable `story`, `objective`, `twist` describe one complete challenge.
2. The hub lets the player select any stage; restart reproduces the same seeded challenge. It shows the action and objective before play. The standalone scene is launched explicitly, leaving the default main scene, core board, autoloads and input map untouched.
3. Models provide `start(level, seed)`, `advance(delta)`, `act(action)` and `snapshot()`. Rendering, navigation and pause belong to the host. Pausing stops simulation time and actions; it cannot consume a focus charge or advance a wall.
4. A successful round meets its stage objective before the cap. A failed round stops, gives a concrete reason and permits an immediate restart. Finishing publishes exactly one result. An ended round rejects further actions.
5. Results include level ID, success, elapsed time, score and 0–3 stars. Star thresholds are inclusive. Stars in this standalone pack do not pay campaign currency or imply save/profile integration.
6. Story strings are authoring summaries. Existing narrative rules still apply: optional wordless poses, icons and rim props communicate story; no dialogue or compulsory story-reading. Functional rules, controls and objectives remain readable gameplay help. Failure is a toy gag, never an injury.
7. New art follows “quiet world, loud board”: rounded matte biome props, saturated bevelled blocks, legible silhouettes, and effect cues independent of piece colour. No ambient motion hides a deadline, fit or projection error.

### Perfect Stack — MG4 practice

- A square foundation supports a moving slab. Successive slabs slide on alternating X and Z axes; Space or the primary button locks the current slab. There is no rotation.
- The retained slab is the X/Z intersection with the slab directly below. A small alignment error snaps to a Perfect; a larger error trims the overhang and makes later support narrower. A complete miss ends the attempt.
- U or E uses one magnet charge only while inside the visible snap range. The magnet centres and locks the slab, preserving width. An invalid use spends nothing. Assisted locks break the unassisted Perfect streak.
- Three consecutive unassisted Perfects publish a `perfect_streak` / `steal_slab` interaction request for a future adapter. A local practice round has no opponent, stolen slab or leader shield.
- Meadow teaches constant-speed alternating slides. Clockwork adds a smooth pendulum speed pulse. Celestial combines the pulse with seeded starwind speed variation, a longer climb and one recovery charge. Waves affect travel speed; they do not teleport a slab or secretly reverse its direction.
- Goal: lock the configured number of slabs above the foundation. Height is the primary metric; Perfect count celebrates precision without becoming a mandatory win gate.

### Hole in the Wall — MG1 practice

- One cube-built piece floats inside a bounded frame. Move it within the frame and rotate it about the exposed axes to match an approaching hole.
- Every hole starts from a legal hidden orientation and legal translation of the current piece. Its core is that pose's projection along the announced wall axis; extra slack cells provide early forgiveness. A witness pose always exists.
- At contact, or when Space manually sends the parcel immediately, pass when every projected piece cell lies in the open hole. A Perfect fills the core exactly. Slack does not invalidate an otherwise exact core match. A successful manual send in the final beat window earns an optional score bonus; it does not change the pass goal.
- A missed wall bonks the toy back, increments misses and temporarily stuns input. Reaching the miss limit ends the attempt. Passed walls advance the goal and score.
- Clockwork introduces front/side approaches, asymmetric shapes, decreasing slack and an optional closing-beat score bonus. Celestial combines these with exact openings and limited focus. The first occurrence of a new axis has a slower introduction; its direction is readable before contact.
- In Celestial, U spends a visible focus charge to slow the current wall for 2.5 seconds at 35% wall speed. It has no score penalty. Focus ends when that wall resolves and does not carry into the next wall. Focus is optional recovery, not a prerequisite for a generated hole to be reachable.
- A configured pass streak publishes a `tight_wall` interaction request. A future tournament adapter owns target selection, telegraphing and applying it; the local hub must not claim that a rival was attacked.

### Shadow Workshop — MG10 practice

- Each stage contains three authored blueprints. A cursor builds a small cube sculpture on a fixed grid: left/right changes X, up/down changes Z depth, E/Q raises/lowers Y, primary adds/removes a cube, and U undoes the last edit. Cubes may float; no gravity or support condition is implied.
- Two continuously visible panels show the required front and side projections. A build wins when both projections match exactly, its cube count is within budget and every cube occupies a legal cell. Extra projection cells are errors.
- More than one sculpture may satisfy the panels. Any valid matching build wins; the authored witness is a validation fixture, not an exact hidden sculpture that the player must copy.
- Meadow teaches projection agreement on a 3×3×3 board. Clockwork combines asymmetric silhouettes, an efficient cube budget and a first forbidden gear socket, growing to three. Celestial expands to 4×4×4 with exact cube trays and two to five forbidden cloud gaps. Front-only or side-only solutions never suffice in any stage.
- Removal and undo refund available construction capacity. A budget mistake never traps the player into restarting. The time cap is a replay challenge, not a reason to hide panels or rush the first lesson.
- A completed blueprint publishes a `flicker_requested` interaction for future MG10 tournament integration, awards 100 score, then clears the build and undo history for the next blueprint. The stage wins after all three; its timer continues across them. Practice panels remain visible.

## Formulas

**Stars.** Let `t` be elapsed seconds, `t3 = star_times[0]`, `t2 = star_times[1]`, and `T = time_limit`, with `0 < t3 ≤ t2 ≤ T`. Failure earns 0; success earns 3 when `t ≤ t3`, otherwise 2 when `t ≤ t2`, otherwise 1. Example: `t3 = 24`, `t2 = 44`; a 24-second win earns 3 stars and a 25-second win earns 2.

**Slab support.** For centre `c`, size `s`, support centre `b` and support size `q`, calculate independently on axes `a ∈ {X,Z}`: `lo_a = max(c_a − s_a/2, b_a − q_a/2)`, `hi_a = min(c_a + s_a/2, b_a + q_a/2)`. Retained width is `hi_a − lo_a`, with centre `(hi_a + lo_a)/2`. If either width is at most `10⁻⁶`, there is no support and the round fails. Example: equal widths 4, offset 0.7 on X → retained X width 3.3, centre halfway across the overlap. No-loss Perfect requires axis distance at most `perfect_tolerance`; magnet use additionally requires a charge and distance at most `magnet_range`.

**Stack speed curve.** With `n` locked slabs and height goal `H ≥ 1`, `v(n) = lerp(speed_start, speed_max, clamp(n/max(1,H−1),0,1))`. The Clockwork example `H = 10`, `2.1 → 3.6` gives `v(0) = 2.1` and `v(9) = 3.6` cells/s. Smooth wind and rhythm waves are integrated from slab spawn time, then reflected at travel bounds. The implementation clamps wind amplitude to at most `0.45v` and rhythm amplitude to at most `0.35`; travel cannot stall. Analytic integration makes the same elapsed time give the same position regardless of render frame subdivisions.

**Wall fit.** Let `P_a(B)` project the piece's integer cells along wall axis `a`, `C` be the core-hole cells, and `S` its extra slack cells. `pass = P_a(B) ⊆ (C ∪ S)`; `perfect = P_a(B) = C`. Example: a four-cell L projected along Z fits its four-cell core plus two slack cells, and is Perfect when aligned exactly to the core. An extra piece cell outside that six-cell opening fails.

**Wall cadence and score.** For resolved gate count `g`, `duration = max(wall_interval_min, wall_interval − g × wall_ramp)`. The first appearance of an axis additionally uses `max(duration, axis_intro_interval)`. A pass awards 1 score, an exact core match 2, and a successful manual send with `duration − wall_age ≤ rhythm_window` adds `rhythm_bonus`. Example: Clockwork `g=4`, interval 9, minimum 6.5 and ramp 0.4 → 7.4 seconds; an exact send in its last second earns 3 score. Automatic contact has no beat bonus. While focus is active, wall age increases by `delta × focus_rate` and the total round timer still advances at ordinary speed.

**Shadow fit.** Let `F(B) = {(x,y) | (x,y,z) ∈ B}` and `R(B) = {(z,y) | (x,y,z) ∈ B}`. Required silhouettes are `F*` and `R*`. Win requires `F(B)=F*`, `R(B)=R*`, `|B| ≤ budget`, and `B ∩ forbidden = ∅`. Exact set equality prevents extra cells from passing. Example: two cubes at `(0,0,0)` and `(0,0,1)` cover one front cell and two side cells. A single cube covers the front target but cannot cover both side cells.

**Progress.** Stack uses `clamp(locked/H,0,1)`; wall uses `clamp(passes/pass_target,0,1)`. Shadow blueprint progress is `clamp((correct_projected_cells − extra_projected_cells)/max(1,target_front_cells + target_side_cells),0,1)`; stage progress is `(completed_blueprints + blueprint_progress)/blueprint_count`, or 1 after winning. Example: targets have 8 front plus 6 side cells, current projections cover 13 with one extra → `12/14 ≈ 0.86`. Coverage is not authoritative if constraints are violated; the host treats the model's completion result as authoritative.

## Edge Cases

- A slab touching only the edge of support has zero area and fails; it cannot create an indefinitely narrow floating tower. An invalid magnet attempt spends no charge. A magnet lock cannot also earn an unassisted Perfect reward.
- `H = 1` avoids zero division. Width, speed, periods and wave amplitude are clamped to safe nonzero ranges by the model. A tiny or finished tower must not produce invalid camera dimensions.
- Wall generation is bounded by the frame and validated against its hidden witness. Symmetric shapes are legal: the game judges their projection, not the number or direction of button presses. A new wall-axis transition cannot silently shorten the first learning window.
- A large `advance(delta)` must resolve wall contacts in chronological order and preserve any remaining elapsed time. Repeated focus input cannot spend multiple charges after the round has ended. Misses never delete already-earned passes.
- Shadow cubes at a boundary stay in range. Duplicate cube placement toggles/removes rather than inflating count. Grid sizes are clamped to 2–4 and cube budgets to 1–grid-volume. Empty silhouette panels fail with an explicit blueprint message; a nonempty target with no valid witness is invalid authored content.
- Any alternative legal shadow solution counts. Undo reverses the last cube edit and moves the cursor to that cell; it does not rewind a completed blueprint. Empty target projections cannot cause progress division by zero.
- Restart clears score, timer, charges, interactions, cursor/build and failure messages. Pause does not charge the timer. Models emit at most one completion even if an action, time cap and goal coincide.
- Authored content validation must identify malformed JSON, out-of-range cells, missing tuning and unsolvable witnesses before release. Model defensive defaults are not evidence that invalid content is a valid stage. Offline interaction requests remain local events, not network delivery claims.

## Dependencies

| Dependency | Required from it | Provided to it |
|---|---|---|
| `minigames/arcade_pack/CONTRACT.md` | Model/action/snapshot/result boundary | Three independent rule models and nine JSON stages |
| `models/round_base.gd` | Seeded RNG, elapsed-time cap, one completion and star rule | Model-specific reset, step, actions, metric and snapshots |
| Arcade hub and scene | Stage selection, semantic actions, renderer, pause/retry | Render-neutral cells, status, progress, result and optional interaction request |
| Blender-generated arcade assets | Native `.blend` sources, GLB dioramas and chunky cube style | Biome and prop requirements; no dependency from simulation to asset geometry |
| Tournament minigames GDD | MG4/MG1/MG10 design intent | Practice implementation and future adapter hook; no local-multiplayer completion claim |
| Narrative/art references | Wordless optional story, biome cast, readable toy finish | Canon-compatible stage stories and visual motifs in `design/levels/arcade-pack.md` |
| Future tournament adapter | Explicit mapping of standings, targets, networking and telegraphs | Serializable `interaction_requested` payloads; adapter remains future work |

This pack neither consumes nor modifies the live campaign registries, save/profile, economy, character perks or BoardSim. Adding it to campaign or tournament selection is a separate adapter task. The systems index should link this implementation from the Tournament Minigames row.

## Tuning Knobs

All stage tuning lives in external JSON. The current shipped values, stage IDs, progression and rationale are listed in `design/levels/arcade-pack.md`; they are prototype defaults pending player evidence.

| Category | Knob | Intended range | Design reason |
|---|---|---|---|
| Feel | Stack slide speed | 2–4 cells/s | One visible traversal is enough to understand the timing |
| Feel | `perfect_tolerance` | 0.10–0.20 cells | Rewards accurate input without requiring exact floating-point equality |
| Feel | `magnet_range` | 0.65–1.0 cells | A legible, useful recovery band wider than Perfect tolerance |
| Curve | Wind / rhythm amplitude | 0–0.45 cells/s / 0–0.26 relative | Varies cadence while keeping forward movement readable |
| Gate | Stack height / magnet count | 8–12 slabs / 1–3 | Longer climbs combine learned actions; limited recovery encourages choice |
| Feel | Wall interval / focus | 5.5–13 seconds / 2.5 s at 35% speed | Allows planning and a concrete rescue action |
| Curve | Hole slack / axis mixture | 0–2 cells / Z then Z+X | Precision escalates only after orientation is understood |
| Gate | Wall passes / miss allowance | 5–7 passes / 3–4 misses | Enough encounters to practise, with several mistakes before failure |
| Feel | Shadow cursor repeat / feedback | Host input and visual settings | Cursor and each projection error must remain legible |
| Curve | Shadow grid / cube budget / forbidden cells | 3–4 cells per axis / 4–10 cubes / 0–5 forbidden | Adds reasoning rather than only faster input |
| Gate | Time cap / star thresholds | `0 < t3 ≤ t2 ≤ T` | All stages remain completable at one star; speed is optional mastery |

Balance rule: change one difficulty axis at a time in the lesson, two learned axes in the remix, and a small third constraint only in the mastery stage. If playtests identify unreadability, widen the arrival or recovery window before adding explanatory text.

## Acceptance Criteria

1. **Functional:** all nine stages load, start, reach a success or explicit failure, and restart from the hub without touching the main campaign or default main scene.
2. **Determinism:** same level/seed/action times give identical snapshots, goals, wall witnesses and results; stack travel agrees after large versus subdivided time steps.
3. **Stack fairness:** centre locks preserve width, overhang trims the actual intersection, edge-only contact fails, invalid magnet input spends nothing, and every third unassisted Perfect requests one future interaction.
4. **Wall fairness:** every generated hole has a replayable valid witness; contact uses set inclusion; exact core match gives Perfect; focus has a visible finite charge, affects time consistently and never penalises score.
5. **Shadow fairness:** both projections are required, an extra silhouette cell prevents win, budget/forbidden constraints are enforced, removal refunds capacity, and a legal alternative build is accepted.
6. **Lifecycle:** pause freezes model time/actions; finished input is ignored; one round emits one result; time thresholds yield 0–3 stars with inclusive boundaries.
7. **Presentation:** Blender sources and exports are present; pieces, hole cells, cursor, projection errors and active effects read above matte biome props. Placeholders, if any, are explicitly identified.
8. **Creative review:** every objective has a visible story counterpart; canonical mascots stay in their biome, player is the wizard, and no vignette alters the main campaign finale or adds mandatory story reading.
9. **Player test target, not a claim:** a new player explains the main action after one rule card, acts meaningfully within five seconds, and identifies the reason for a miss without staff explanation. Observe three novices per mode; revise stages if fewer than two can do this.
10. **Variety test target:** after one run of each stage, players can identify the second and third stage's new decision rather than describing them only as faster. Collect median completion and retry count before final star-time tuning.

Creative review disposition: the three verbs and nine-stage plan match the block-constant and readable-chaos pillars. The local implementation intentionally proves single-player feel first. Formal mobile usability, final star balance, complete mascot skits, and networked tournament play remain unverified until their owning systems are integrated and played.
