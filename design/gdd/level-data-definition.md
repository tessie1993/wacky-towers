# Level Data & Definition

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Readable Chaos

## Summary

Every level is a data file, not code: it lists the board, the pieces, the goal, the twists and the level mechanic, and leaves everything else at the defaults set by the other GDDs. A validator checks every level against all the rules those GDDs define before it can be played. The MVP ships one full biome — ten grass / meadow levels that introduce each twist and mechanic once and end with a full stack.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Level Goals & Fail States, Rule-Twist Framework, Level-Specific Mechanics, Twist Library`

## Overview

With 100 campaign levels plus arcade and tournament rounds, levels must be content rather than code. Level Data & Definition owns the **level file**: a single structured record per level that names its biome and tier, its board (size, height, mask, starting contents), its piece set, any overrides to the defaults of the core systems, its goal, and the rules it declares (up to two twists and one level mechanic). Any field left out takes the default from the GDD that owns it, so a minimal level is a few lines. Level values set the **base** for that level; twists and mechanics are rules layered on top through the Rule-Twist Framework. Before a level can load, a **validator** runs every check the other GDDs define (pieces fit the board, the board is readable on a phone, targets are reachable, rule caps and incompatibilities, parameters in their safe ranges) and names the field and the rule that failed. This GDD also defines the **MVP biome**: ten meadow levels that teach the controls, then introduce each of the four twists and four mechanics once, ending with a level that stacks two twists and a mechanic. This serves *Variation Over Depth* (new levels are cheap) and *Readable Chaos* (the validator enforces the readability rules). All values are starting defaults.

## Detailed Design

### Core Rules

**The level file**
1. Each level is one data record with an `id` (e.g. `meadow_03`), a display name, a `biome`, a `tier` (1–10; 11 = the biome's bonus level, Campaign Structure rule 17) and the sections in rule 3. The storage format (engine resources, JSON, etc.) is an implementation choice → becomes an ADR after `/setup-engine`.
2. **Every field is optional except `id`, `biome` and `tier`.** An omitted field takes the default from the GDD that owns it (rule 3). Level values replace those defaults as the level's base; they are not framework rules and have no priority.
3. Sections and owners:

| Section | Fields (examples) | Owner GDD |
|---|---|---|
| `board` | `width`, `depth`, `H_play`, `mask`, `down_axis`, `spawn_anchor`, `starting_contents` | Board / Grid |
| `pieces` | `shapes`, `weights`, `tags`, `opening_set`, `opening_count` | Piece Set, Spawner |
| `spawner` | `randomizer`, `queue_lookahead`, `preview_count`, `hold_enabled`, `sequence_mode`, `seed` | Piece Spawner & Queue |
| `controls` | `rotation_axes_enabled`, `landed_move_rule`, `kick_enabled` | Movement & Rotation, Touch Controls |
| `fall` | `g0`, `ramp_per_clear`, `ramp_per_min`, `g_max`, `lock_delay_ms`, `lock_resets_max`, `entry_delay_ms` | Fall, Drop & Lock |
| `clearing` | `clear_enabled`, `collapse_mode` | Layer Clearing |
| `camera` | `occlusion_mode`, elevation override | Camera & Rotate-View |
| `goal` | `type`, target (`N`, `H_target`, `T` or `target_shape`), `height_coverage`, `T_level`, `t_piece`, `warnings_max`, `rescue_margin`, `topout_rule`, `countdown_ms`, `time_limit`, extra fail conditions | Level Goals & Fail States |
| `mechanic` | `id` and parameters (at most one) | Level-Specific Mechanics |
| `twists` | list of `id` and parameters (at most two) | Twist Library |
| `stars` | star times (added by Scoring & Stars) | Scoring & Stars |

4. A level never contains behaviour; new behaviour is a new twist or mechanic in its own GDD.
4a. **Grid fields use ASCII rows** (one string per row; row 0 = `z = 0`, character 0 = `x = 0`), so levels are readable and diff cleanly:
   - `board.mask`: `#` active, `.` off (Board / Grid rule 4). Omitted = all active.
   - `board.starting_contents`: `{layers: {y: [rows]}}` with `#` = starter block (`shape_id: starter`, drawn in the biome's stone style), `m` = the biome object, `.` = empty.
   - `goal.target_shape`: `{layers: {y: [rows]}}` with `#` = target cell. This is the Shape goal's `M`.
4b. `board.spawn_anchor` `{x, z}` sets where pieces spawn (Board / Grid rule 11a); default the footprint centre (lower cell on ties).
4c. Schema sketch (every field optional except `id`, `biome`, `tier`; `version` is set by the tools):

```
id, version, name, biome, tier
board:    width, depth, H_play, down_axis, mask, spawn_anchor, starting_contents
pieces:   shapes[], weights{}, tags{}, opening_set[], opening_count, fixed_list[]   # fixed_list = puzzle levels
spawner:  randomizer, queue_lookahead, preview_count, hold_enabled, sequence_mode, seed
controls: rotation_axes_enabled, landed_move_rule, kick_enabled
fall:     g0, ramp_per_clear, ramp_per_min, g_max, lock_delay_ms, lock_resets_max, entry_delay_ms
clearing: clear_enabled, collapse_mode
camera:   occlusion_mode, elevation
goal:     type, N | H_target | T | target_shape, height_coverage, T_level, t_piece,
          warnings_max, rescue_margin, topout_rule, countdown_ms, time_limit
mechanic: {id, params}          # at most 1
twists:   [{id, params}]        # at most 2
stars:    t2, t3 | s2, s3
```

**Validation**
5. The validator runs when a level is authored (editor check) and again at load. A failing level cannot be played; the error names the level, the field and the rule. Warnings allow play but are listed.
6. Checks (failures unless marked *warn*):
   - **Board**: footprint and height within Board / Grid ranges; at least `min_active_cells_per_layer` active cells per layer; readability F5 cube edge ≥ 20 px on the reference phone (*warn* below 28 px).
   - **Pieces**: set not empty; every shape fits each active region (Piece Set rule 8); at most 8 shapes (10 in minigames) and at most 3 in one 60° hue band (*warn* on hues within 15°); spawn clearance = `L_max` (Board F4).
   - **Spawner**: `preview_count ≤ queue_lookahead ≤` cap; bag size ≤ `bag_max_size` (*warn* and scale); every `opening_set` shape is in the level's set and `1 ≤ opening_count ≤ 10`.
   - **Spawn**: `spawn_anchor` is an active cell, and every shape's spawn cells around it are active (Board / Grid rule 11a).
   - **Grids**: every ASCII grid has `depth` rows of `width` characters and only its legal characters; no starting content or target cell on an inactive cell or at or above `H_play`.
   - **Goal**: valid target (Level Goals edge cases); Shape cells active and below the limit; Height target below the limit.
   - **Rules**: at most 2 twists and 1 mechanic (framework F3); no incompatible pairs (Twist Library, Level-Specific Mechanics); every parameter within its safe range; every rule has an icon; *warn* when two rules set one parameter.
   - **Mechanic-specific**: Conveyor only on unmasked boards; Gravity Flip not with Build Race or Target Shape.
   - **Length**: estimated length (F1) within 5–15 min (*warn* outside).

**Seeds**
7. A level has no fixed seed by default; each attempt gets a new `round_seed`. A level may pin a seed (puzzle-style levels, daily challenges). Versus rounds take the seed from Tournament Flow.

**The MVP biome: grass / meadow (tier 1–10)**
8. The MVP ships **10 meadow levels**: two control tutorials, then each twist and each mechanic introduced once, ending with a full stack. Rotation axes follow Touch Controls' progressive disclosure. Board size is picked per level for fun (user decision 2026-10-09), not fixed at 8 × 8. **The full level specs (masks, starting contents, target shape, star times) live in `design/levels/meadow.md`**; this table is the summary, and all values are tunable defaults.

| # | id | Name | Board (W×D, H_play / mask) | Pieces | Axes | Goal | Mechanic | Twists | g0 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | meadow_01 | First Sprout | 4×4, 8 | 5 flat Standard; opening {O, I} × 2 | spin | Clear 4 | — | — | 0.6 |
| 2 | meadow_02 | Tilt & Roll | 6×6, 10 + 2 starter layers with 3D pockets | 8 Standard; opening {Tripod, Screws} × 3 | spin, tilt, roll | Clear 3 | — | — | 0.6 |
| 3 | meadow_03 | Breezy Hill | 8×4 lane, 10 | 8 Standard | all | Clear 5 | — | Wind | 0.7 |
| 4 | meadow_04 | Mushroom Ring | 7×7 ring (A = 40), 10; anchor (3, 5) | 8 Standard | all | Clear 3 | — | Spawned Objects | 0.75 |
| 5 | meadow_05 | Tall Tower | 5×5, 12 | 8 Standard + Big Cube (w 0.5) | all | Height 10, coverage 0.6 | No-Clear Build Race (trim) | — | 0.8 |
| 6 | meadow_06 | Flower Bed | 8×8, 8 | I, O, T, L, S, Tripod, Duo, Tri-Corner | all | Shape (50-cell flower) | Fill the Target Shape (trim) | — | 0.7 |
| 7 | meadow_07 | Hide & Seek | 6×6, 10 + 2 starter layers | 8 Standard | all | Clear 4 | — | Invisible Blocks | 0.85 |
| 8 | meadow_08 | Dewdrop | 5×5, 8 | 8 Standard | all | Survive 150 s | Sticky Landing | — | 0.9 |
| 9 | meadow_09 | Topsy-Turvy | 6×6, 10 | 8 Standard | all | Clear 4 | — | Gravity Flip | 0.95 |
| 10 | meadow_10 | Meadow Mill | 8×6 (A = 48), 12 | 7 Standard (no S) + Chair | all | Clear 3 | Conveyor Floor | Wind, Spawned Objects | 1.0 |
| B | meadow_bonus | Picnic Puzzle | 4×4, 6 | `fixed_list` of 6 (I, O, Big Cube ×2 each) | all | Shape (4×4×2 box) | Fill the Target Shape | — | 0.5 |

9. Level 10 is the systems index's risk test: two twists and a mechanic stacked. Level 1 has no twist so the first playtest measures the controls alone. Speeds are hand-set per level and agree with Campaign Structure F2 (`0.6 + 0.045 × (tier − 1)`) within ±0.05; a level's own `g0` always wins.

### States and Transitions

A level file has: **Draft** (authored, may fail validation) → **Valid** (passes; warnings listed) → **Locked** (shipped; changes need a version bump so saved stars stay meaningful). At runtime a loaded level is read-only.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid, Piece Set, Spawner, Movement & Rotation, Touch Controls, Fall Drop & Lock, Layer Clearing, Camera | Level Data → | Base values for their knobs |
| Level Goals & Fail States | Level Data → | Goal, targets, warnings, extra fails |
| Rule-Twist Framework, Level-Specific Mechanics, Twist Library | Level Data → | Declared rules and parameters; validation of caps and pairs |
| Scoring & Stars | ↔ | Star times stored per level |
| Campaign Structure | → Level Data | Order of levels by biome and tier |
| Mode / Minigame Randomizer, Tournament Flow, Arcade Mode | → Level Data | Picks levels or templates; supplies seeds |
| Save & Profile | Level Data → | Level ids and versions for saved results |

## Formulas

### F1. Level length estimate

The level_length_estimate formula is defined as:

`t_est = N × t_beat` (Clear); `build_race_time` (Height, Level-Specific Mechanics F2); `shape_fill_time` (Shape, Level-Specific Mechanics F3); `T` (Survive)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N | int | ≥ 1 | data file (suggested by Level Goals F1) | Clears to make |
| t_beat | float | 5–340 s | calculated (Board F6) | Seconds between clears for this board, clear rule, piece set and `t_piece` (layer clears: `P_eff × t_piece`) |
| t_piece | float | 4–12 s | data file (Level Goals) | Average time per piece, inside t_beat; default 8 s |
| T | float | > 0 | data file | Survive time |

**Output Range:** used only for *warn* checks: length 5–15 min, plus t_beat, hidden share and survive pressure inside the level type's bands (Board / Grid "Recommended board per level type"). **Example:** meadow_01: 4 × 4, layer, c = 4, η 0.75 → `t_beat ≈ 42.7 s`; N = 4 → `t_est ≈ 171 s` (short on purpose; warns). meadow_05: Height 10, coverage 0.6, A = 25, c ≈ 4.24 → 35 pieces ≈ 283 s. meadow_03: 8 × 4 lane, `t_beat ≈ 85 s`, N = 5 → ≈ 427 s ≈ 7 min. meadow_10: 8 × 6 (A 48), c ≈ 4.1 → `t_beat ≈ 125 s`; N = 3 → ≈ 375 s. A default 6 × 6 level: `t_beat = 96 s`, N = 5 → 480 s. F1 ignores `starting_contents`, so levels with pre-built layers set their star times by hand.

## Edge Cases

- **If a field is omitted**: the owning GDD's default is used; the validator lists the effective values in the editor so designers see what will play.
- **If a field is unknown** (typo or removed knob): validation fails, naming the field.
- **If a field's value is outside its safe range**: validation fails, naming the range.
- **If a level changes after it shipped**: its version increments; saved stars for the old version stay but are marked as an older version (Save & Profile decides display).
- **If a twist or mechanic id doesn't exist**: validation fails.
- **If a level has a pinned seed and `sequence_mode = independent`** (versus): each player's stream still mixes in the player id (Spawner).
- **If two levels share an id**: validation fails for the campaign as a whole.
- **If `starting_contents` places content in inactive cells or over the limit**: validation fails.
- **If the length estimate is outside 5–15 min**: warning only; tutorials and minigames may be short on purpose.
- **If a Shape level has an empty or missing `target_shape`**: the level stays Draft (fails validation for an empty M).
- **If the footprint centre is inactive and no `spawn_anchor` is given**: validation fails, naming the field.
- **If `opening_count` is larger than the number of pieces the level deals before ending**: allowed; the rest of the opening is never used.

## Dependencies

**Upstream:** Level Goals & Fail States, Rule-Twist Framework, Level-Specific Mechanics, Twist Library (Hard); every core GDD whose knobs it sets (Board / Grid, Piece Set, Spawner, Touch Controls, Camera, Movement & Rotation, Fall Drop & Lock, Layer Clearing) (Hard: field definitions, defaults and ranges).

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Campaign Structure | Hard | Levels by biome and tier |
| Scoring & Stars | Hard | Star times per level |
| Mode / Minigame Randomizer, Tournament Flow, Arcade Mode, Tournament Minigames | Hard | Level and template selection |
| Save & Profile, Menus & Level Select | Soft | Ids, names, versions |

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| length warn range | 3–20 min | 5–15 min | Validator warning (F1) |
| per-level fields | as in owning GDDs | owning GDD defaults | Everything about a level |

## Visual/Audio Requirements

None at runtime beyond what the systems it configures draw. The editor validator shows errors and warnings next to fields.

## Game Feel

Level difficulty should rise smoothly through a biome: one new idea per level, and the last level of the biome combines them. The meadow sequence raises base speed from 0.6 to 1.0 cells/s (very slow early, user decision) and adds one idea per level; the build-race and shape levels (5, 6) are a low-pressure break before the second half.

## UI Requirements

Player-facing: none (Menus & Level Select shows names). Designer-facing: an editor view that lists effective values and validation results per level — a tools task → `/ux-design` not needed; noted for tools-programmer.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` F1, F2, F4, F5; Core Rules 2, 4 | Board fields, readability and capacity checks |
| `design/gdd/piece-set.md` Core Rules 7–8; Visual/Audio | Piece-set fields and validation; hue bands |
| `design/gdd/piece-spawner-queue.md` Tuning Knobs; F4 | Spawner fields and checks |
| `design/gdd/touch-controls.md` Core Rule 9 | Progressive disclosure of axes |
| `design/gdd/movement-rotation.md`, `fall-drop-lock.md`, `layer-clearing.md`, `camera-rotate-view.md` Tuning Knobs | Overridable fields |
| `design/gdd/level-goals-fail-states.md` F1; Edge Cases | Goals, default N, validation |
| `design/gdd/rule-twist-framework.md` F3; Core Rules 15–17 | Rule caps and checks |
| `design/gdd/level-specific-mechanics.md` F2, F3 | Length estimates; mechanic rules |
| `design/gdd/twist-library.md` Core Rule 3 | Twist parameters and incompatibilities |
| `design/gdd/game-concept.md` | 10 biomes × 10 tiers; MVP biome |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [U] **GIVEN** a level with only `id`, `biome` and `tier`, **THEN** it validates and plays with every default (6 × 6 footprint, H_play 10, 8 Standard shapes, Clear with N from Level Goals F1 for that board).
2. [U] **GIVEN** an unknown field or an out-of-range value, **THEN** validation fails naming the field and range.
3. [U] **GIVEN** a shape that doesn't fit a masked region, 9 shapes, or 4 shapes in one hue band, **THEN** validation fails.
4. [U] **GIVEN** 3 twists, 2 mechanics, Gravity Flip with Build Race, or Conveyor on a masked board, **THEN** validation fails.
5. [U] **GIVEN** a board whose cube edge would be 18 px, **THEN** validation fails; 25 px → warning.
6. [U] F1: meadow_01 → about 171 s (warning, still playable); meadow_05 → about 283 s; meadow_03 → about 427 s.
7. [I] **GIVEN** each of the 10 meadow levels, **THEN** all validate and load.
8. [I] **GIVEN** meadow_01, **THEN** only spin is enabled, only the 5 flat shapes appear, and the first 2 pieces are O or I.
8a. [U] **GIVEN** a mask with the footprint centre off and no `spawn_anchor`, an anchor on an inactive cell, an ASCII grid with the wrong row count, or an `opening_set` shape outside the level's set, **THEN** validation fails naming the field.
9. [I] **GIVEN** meadow_10, **THEN** Conveyor Floor, Wind and Spawned Objects are all active and shown on the Intro card.
10. [U] **GIVEN** a shipped level edited, **THEN** its version increments.
11. [M] **GIVEN** a playtest of the 10 meadow levels, **THEN** each level's median length is 5–15 min and testers report that difficulty rises without a sudden spike.

## Open Questions

- **Storage format** (engine resources vs. JSON) → ADR after `/setup-engine`.
- ~~**meadow_06 shape**~~: authored in `design/levels/meadow.md` (50-cell flower, 2 layers).
- **Tier meaning**: in the campaign, tiers re-run biomes with added mechanics; the MVP uses tier = level number in one biome. Confirm in Campaign Structure.
- **Level editor**: build a simple in-engine editor with live validation, or author in text first? Tools decision after the prototype.
- **Star times**: added when Scoring & Stars is designed.
