# Level-Specific Mechanics

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos

## Summary

A level-specific mechanic is the one rule that makes a level *that* level: it deliberately breaks a general rule ("full layers don't clear here", "the floor moves") and always wins over twists, items and perks. Each level has at most one. The MVP ships four, all in the grass / meadow biome: **No-Clear Build Race**, **Fill the Target Shape**, **Sticky Landing** and **Conveyor Floor**.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rule-Twist Framework` · ADRs: 0002 (boards), 0004 (knobs, slots, rules), 0011 (rules in the sim, beehave staging only)

## Overview

Biome twists (Twist Library) are reusable modifiers that can appear in many levels. A **level-specific mechanic** is different: it is the level's central idea, often a contradiction of the general rules, and it sits at the top of the Rule-Twist Framework's priority order (layer 4) so nothing else can switch it off. This GDD defines what a level mechanic must declare and the four MVP mechanics. **No-Clear Build Race** turns clearing off and asks the player to build a tower to a target height. **Fill the Target Shape** turns clearing off and asks the player to fill a marked set of cells. **Sticky Landing** makes pieces lock the moment they touch anything. **Conveyor Floor** moves the whole stack one cell along a loop after every lock. Each is built only from the framework's parameters, hooks and API, so new mechanics later are data and small behaviours. Anything a mechanic does to the board runs inside the board simulation as a rule; characters such as the Miller only act it out (staging). All four are designed for the MVP grass / meadow biome but are biome-neutral. This serves *Variation Over Depth* (each level feels different), *The Block Is the Constant* (every mechanic is about placing the same blocks) and *Readable Chaos* (one mechanic per level, always announced). All values are starting defaults.

## Detailed Design

### Core Rules

**What every level mechanic declares**
1. A level mechanic is a Rule-Twist Framework rule at layer `level_mechanic` with: `mechanic_id`, icon and two-word name, the general rule(s) it contradicts, its parameters (with safe ranges), the goal type it expects (if any), and its lifetime (always the whole level).
2. A level has **at most one** mechanic (framework F3). A level with none plays the base rules plus its twists.
3. The mechanic is shown on the Intro goal card next to the goal and stays in the HUD rule strip for the whole level.
4. Because it is layer 4, a mechanic's `set` operations and vetoes beat every twist, item, buff and perk. An item or twist that would undo it has no effect (framework edge case).
4a. **Where a mechanic runs** (ADR-0011 §1). A mechanic is a rule JSON (`assets/data/rules/<rule_id>.json`, ADR-0004 §2) whose number changes are knob modifiers (data) and whose board changes are a `RuleBehaviour` or a slot plugin inside `BoardSim.step()`, acting only through `RuleApi` on the sim clock. **Anything that changes the board, the piece, the queue, the goal or the score is never a beehave tree, a presenter or a level script.** Beehave `StagingTree`s (in the level `.tscn` or the mechanic's default presenter) are staging only: they read sim events and animate. Every change the player must see coming is announced by a sim event that carries its window (`in_ms`, `at_ms`).
4b. Knob and slot names in this GDD are the ADR-0004 ids (`clear.enabled`, `clear.detector`, `clear.collapse`, `spawn.arrival`, `spawn.router`, `goal.type`, `goal.top_out`, `fall.*`, `board.kind`, `layout.kind`). Scalars are stored as integer milli-units (0.7 → 700).

**M1. No-Clear Build Race** (rule `build_race`)
5. Contradicts: full layers clear. Sets `clear.enabled = false` (Layer Clearing). Expects the **Height** goal (`goal.type = height`).
6. **No rescue wipe** (user decision 2026-10-09). The mechanic sets `goal.top_out` to its `top_out` parameter, default `trim` (Level Goals rule 10b): cubes over the limit pop off, no warning is used, and the level is never lost to a top-out; over-building only costs time. A level may set the parameter to `rescue`; the wipe then uses Layer Clearing's routine with the `rescue` flag, which `clear.enabled = false` does not block.
7. Parameters: `H_target` (default `H_play − 2`), `height_coverage` (default 0.5), `top_out` (default `trim`). In versus, the first to the target height wins (Level Goals default).

**M2. Fill the Target Shape** (rule `fill_shape`)
8. Contradicts: full layers clear; any placement is as good as another. Sets `clear.enabled = false`. Expects the **Shape** goal (`goal.type = shape`) with a set of target cells `M`.
9. Target cells are drawn as marked outlines on the board; a target cell is **covered** when it holds solid `fills_layer` content (blocks, and objects such as sprouts or mushrooms). Content outside `M` is allowed.
10. Parameters: `M` (from Level Data `goal.target_shape`), `stick_when_filled` (default false; if a level turns clearing back on, true keeps a covered target cell counted), `top_out` (default `trim`, as M1 rule 6, so a top-out never wipes the picture).

**M3. Sticky Landing** (rule `sticky_landing`, data only: no behaviour)
11. Contradicts: a landed piece can still be adjusted. Sets `fall.lock_delay_ms = 0` and `fall.hard_drop_grace_ms = 0` (Fall, Drop & Lock): a piece locks on the sim tick it first rests.
12. To stay fair it also multiplies `fall.gravity_scale` by `sticky_gravity_scale` (default 0.7, stored 700), giving more time to aim in the air. The landing ghost is the player's main tool.
13. Any goal type may be used (default Clear).

**M4. Conveyor Floor** (rule `mill_belt` in ADR-0011; Meadow skin: Mill Belt EV05)
14. Contradicts: locked blocks never move. After every `conveyor_every` locks (default 1), at `on_resolve_end` (S4b, last, because the mechanic has the highest rank), the conveyor's `RuleBehaviour` moves **every content on the board** one cell along the conveyor direction `d` (a world ground axis, fixed per level) as one rigid shift through `RuleApi.move_cells`. On the lock before a shift the sim emits `belt_windup`; on the shift, `belt_shift {dir, wrapped}`. The Miller's lever and the rolling belt are staging driven by these events. If the shift completes a layer, it clears in the S4c pass (ADR-0011 §3).
15. Contents pushed past the footprint edge **wrap around** to the opposite edge (`conveyor_wrap = true`), so every layer keeps its cell count and layer clearing still works. With `conveyor_wrap = false`, contents pushed off the edge fall off the island and are removed (not counted as cleared); such levels should use the Height or Survive goal, since layers then rarely fill.
16. The shift happens after the clear check, so a layer completed by a lock clears before it moves. The next piece spawns after the shift. The ghost of the next piece already accounts for the moved stack.
17. Conveyor levels require an unmasked rectangular board (validation).
18. Any goal type may be used (default Clear).

### States and Transitions

A mechanic is Active for the whole level (framework states). M4 also has a per-lock cycle: **Idle → Shifting** (at `on_resolve_end` when the lock count reaches `conveyor_every`) **→ Idle**. Shifting is part of the board's Resolving state.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Mechanic → | Layer-4 rule: parameter sets, hooks (`on_resolve_end` for M4), vetoes |
| Layer Clearing | Mechanic → | `clear.enabled = false` (M1, M2); M4 runs after the clear check; S4c clears what M4 completes |
| Fall, Drop & Lock | Mechanic → | Lock delay, grace and gravity (M3); lock count (M4) |
| Board / Grid | Mechanic → | Rigid shift of all contents (M4); target cells (M2) |
| Level Goals & Fail States | ↔ | Expected goal types; rescue still works under M1 |
| Level Data & Definition | → Mechanic | Which mechanic a level uses and its parameters |
| Twist Library | ↔ | Twists combine with a mechanic; the mechanic wins conflicts |
| Staging (ADR-0011), HUD, Game Feel & VFX, Audio | Mechanic → | Sim events (`belt_windup`, `belt_shift`, `target_cell_filled`, `height_reached`, `sticky_lock`); icon, target cells, conveyor arrows. Staging never writes back |

## Formulas

All values are starting defaults, for level designers estimating difficulty.

### F1. Conveyor shift

The conveyor_shift formula is defined as:

`p' = p + d` for every content position `p`; with wrap: `x' = (x + d_x) mod W`, `z' = (z + d_z) mod D`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p | int[3] | inside the board | calculated | A content's cell |
| d | int[3] | one of ±x, ±z (unit) | data file (level) | Conveyor direction |
| W, D | int | 4+ (no max) | data file (Board) | Footprint width and depth |

**Output Range:** inside the footprint (wrap) or removed (no wrap). **Example:** `d = +x` on 8 × 8: a block at x = 7 moves to x = 0; a block at x = 3 moves to x = 4. After 8 shifts the stack is back where it started.

### F2. Build-race length estimate

The build_race_time formula is defined as:

`t_est ≈ (H_target × height_coverage × A / c) × t_piece`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| H_target | int | 2 to `H_play − 1` | data file | Target height |
| height_coverage | float | 0.25–1.0 | data file (Level Goals) | Share of a layer that must be filled to count |
| A | int | 16–144 | calculated (Board F1) | Active cells per layer |
| c | float | 1–8 | calculated (Piece Set F1) | Mean cubes per piece |
| t_piece | float | 4–12 s | data file (Level Goals) | Average time per piece |

**Output Range:** a rough lower-bound guide (gaps below the top layer add more). **Example:** H 10, coverage 0.5, 8 × 8 (A = 64), c = 4, 8 s → 80 pieces ≈ 640 s ≈ 10.7 min, inside 5–15 min. On a 6 × 6 board (A = 36): 45 pieces ≈ 6 min.

### F3. Shape fill estimate

The shape_fill_time formula is defined as:

`t_est ≈ (|M| / (c × η_shape)) × t_piece`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| \|M\| | int | 4–200 | data file (level) | Number of target cells |
| η_shape | float | 0.4–0.9 | constant (tuning) | Share of placed cubes that land in target cells; placeholder 0.6 until playtests |
| c, t_piece | float | — | as F2 | — |

**Output Range:** a guide for level length. **Example:** a 60-cell heart shape, c = 4, η 0.6, 8 s → 25 pieces ≈ 3.3 min.

### F4. Sticky aim time

The sticky_aim_time formula is defined as:

`t_aim = d / (g × sticky_gravity_scale)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d | int | 0–15 | calculated (FDL F3) | Fall distance |
| g | float | 0.3–6 | calculated (FDL F1) | Fall speed before the mechanic |
| sticky_gravity_scale | float | 0.4–1.0 | data file | Default 0.7 |

**Output Range:** seconds to aim before the piece lands and locks. **Example:** d = 10, g = 1 → 10 / 0.7 ≈ 14.3 s instead of 10 s plus the 500 ms lock delay.

## Edge Cases

- **If a level declares a mechanic and a twist that set the same parameter differently**: the mechanic wins; validation warns.
- **If an item would re-enable clearing in M1 or M2**: no effect (framework).
- **If M1's or M2's stack goes over the limit**: with the default `trim`, cubes at or above the limit pop off and play continues; with `goal.top_out = rescue`, the bottom-wipe rescue runs even though clearing is off.
- **If M1's `H_target ≥ H_play`**: validation fails (Level Goals).
- **If M2's target cells include inactive cells or cells above the limit**: validation fails.
- **If M2 is played with `clear.enabled` turned on by the level** (a variant): cleared target cells count as empty unless `stick_when_filled` is true.
- **If M3's hard drop is used**: the piece locks at once, since grace is 0; there is no commit step.
- **If M3's piece rests during a rotation kick**: it locks immediately after the kick.
- **If M4 shifts an object or obstacle**: it moves like any content.
- **If M4 shifts while a status effect is running on a block**: the effect moves with the block.
- **If M4 has no wrap and contents fall off**: they are removed with a visible fall; they do not count as cleared and do not trigger `on_clear`.
- **If M4 runs on a masked board**: validation fails (rule 17).
- **If M4 is combined with the Gravity Flip twist**: the flip (S4a) happens first in Resolving, then the shift (S4b). In the default stack mode the stack turns over in place and the down axis never changes, so the shift axis is unaffected (Twist Library T3).
- **If a level scene has no staging tree for M4**: the mechanic plays the same; only the Miller/belt animation is missing (ADR-0011 §8).
- **If M4's shift would overlap a falling piece**: impossible; the shift happens in Resolving before the next spawn.
- **If a twist is vetoed by the mechanic** (e.g. a twist wants to clear layers in M1): the twist's action has no effect for this level; validation warns.

## Dependencies

**Upstream:** Rule-Twist Framework (Hard: layer-4 rules, hooks, vetoes); Board / Grid (Hard: content shift, target cells); Layer Clearing (Hard: `clear.enabled`, rescue routine); Fall, Drop & Lock (Hard: lock delay, grace, gravity, lock count); Level Goals & Fail States (Hard: Height and Shape goals).

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Level Data & Definition | Hard | Selects a mechanic and its parameters |
| Campaign Structure | Soft | Uses mechanics as a tier's "new idea" |
| Tournament Minigames, Mode / Minigame Randomizer | Soft | May reuse mechanics as rounds |
| HUD, Game Feel & VFX, Audio | Soft | Icons, target outlines, conveyor arrows, events |

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| H_target (M1) | 2 to `H_play − 1` | `H_play − 2` | data file (level) | Build race length (F2) |
| M (M2) | set of cells | per level | data file (level) | Shape and length (F3) |
| top_out (M1, M2; sets `goal.top_out`) | trim / rescue | trim | data file (level) | Over-limit cubes pop off vs. bottom-wipe rescue (Level Goals 10a–10b) |
| stick_when_filled (M2) | true / false | false | data file | Whether covered targets stay counted with clearing on |
| sticky_gravity_scale (M3) | 0.4–1.0 | 0.7 | data file | Aim time (F4) |
| conveyor_every (M4) | 1–5 locks | 1 | data file | How often the floor moves |
| conveyor_dir (M4) | ±x, ±z | +x | data file (level) | Direction |
| conveyor_wrap (M4) | true / false | true | data file | Loop vs. falling off the edge |

## Visual/Audio Requirements

- **M1**: a ribbon at `H_target` around the board (not danger red); the counting layer glows when it reaches coverage.
- **M2**: target cells as soft dotted outlines on the board in a neutral colour, filling with a gentle pop when covered.
- **M3**: pieces show a faint "sticky" sheen (honey-like gloss, not the honey status shell) and lock with a soft splat.
- **M4**: the island's top edge shows arrows along `d`; on each shift the whole stack slides in 200 ms with a soft rumble; wrapped cubes slide out of one edge and in at the other with a short sparkle so the player sees the loop.
- Grass / meadow dressing for all four in the MVP: a wooden sign for the target height, flower outlines for the target shape, dew for sticky, a mossy belt for the conveyor.
- Audio events: `conveyor_shift`, `target_cell_filled`, `height_reached`, `sticky_lock`.

## Game Feel

Each mechanic should be obvious within the first two pieces: the player sees the ribbon, the outlines, the sticky lock or the conveyor move before they need to plan around it. Targets: M4's shift ≤ 200 ms and never during player control; M3's aim time at least 40% longer than the same level without it (F4).

## UI Requirements

Mechanic icon and two-word name on the Intro card and in the HUD rule strip; M2 progress in cells; M1 progress in height. Covered by the UX flags in Level Goals and the Rule-Twist Framework.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 1–17; F3 | Layer-4 rules, hooks, vetoes, one mechanic per level |
| `design/gdd/layer-clearing.md` Core Rules 2, 5–8 | `clear.enabled`, rescue flag, clear before the shift |
| `design/gdd/fall-drop-lock.md` Core Rules 7–13; F1 | Lock delay, grace, gravity scale |
| `design/gdd/level-goals-fail-states.md` Core Rules 3, 5, 8; F2 | Height and Shape goals, rescue, coverage |
| `design/gdd/board-grid.md` F1; Core Rules 4, 6 | Active cells, masks, contents |
| `design/gdd/piece-set.md` F1 | Mean cubes per piece |
| `design/gdd/game-concept.md` | Build-up races, shape-filling, level mechanics that contradict general rules |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [U] **GIVEN** a level with two mechanics, **THEN** validation fails.
2. [U] **GIVEN** M1, **WHEN** a layer becomes full, **THEN** it does not clear; **WHEN** the stack goes over the limit, **THEN** the cubes over the limit are trimmed, no warning is used and the level continues; **GIVEN** M1 with `goal.top_out = rescue`, **THEN** the rescue wipe runs instead.
3. [U] **GIVEN** M1 and an item that sets `clear.enabled = true`, **THEN** clearing stays off.
4. [U] **GIVEN** M2 with 60 target cells, **WHEN** the 60th is covered, **THEN** the level is won; blocks outside M do not affect progress.
5. [U] **GIVEN** M3, **WHEN** a piece first rests, **THEN** it locks on the same sim tick; a hard drop locks at once with no grace.
5a. [U] **GIVEN** any MVP mechanic, a seed and a command log, **THEN** two replays, and a replay with no staging host, give identical sim events and `state_hash()` (ADR-0011 §9).
6. [U] F4: d = 10, g = 1, scale 0.7 → aim time ≈ 14.3 s.
7. [U] F1: M4 with `d = +x`, wrap on, 8 × 8: a block at x = 7 → x = 0; x = 3 → x = 4; 8 shifts return every block to its start.
8. [U] **GIVEN** M4, **WHEN** a lock completes a layer, **THEN** the layer clears first and the shift follows in the same Resolving; the next piece spawns after the shift.
9. [U] **GIVEN** M4 with wrap off, **WHEN** a block is pushed past the edge, **THEN** it is removed, does not count as cleared, and `on_clear` does not fire.
10. [U] **GIVEN** M4 on a masked board, **THEN** validation fails.
11. [U] **GIVEN** M4 with `conveyor_every = 3`, **THEN** the shift happens after every 3rd lock.
12. [I] **GIVEN** M4 and the Gravity Flip twist in one Resolving, **THEN** the flip applies first, then the shift.
13. [I] **GIVEN** any mechanic, **THEN** its icon and name are on the Intro card and in the HUD for the whole level.
14. [M] **GIVEN** a playtest, **THEN** at least 80% of testers can say what the level's mechanic does after the first two pieces.
15. [M] **GIVEN** an MVP level of each mechanic, **THEN** the measured median length is within 5–15 minutes (checks F2 and F3).

## Open Questions

- **Conveyor wrap feel**: does wrapping read clearly on a 2:1 dimetric view, or should the conveyor only run on levels with no wrap and a Height goal?
- **Sticky + kicks**: should Sticky Landing also disable up-kicks so pieces can't "climb" before sticking?
- **Shape library**: who authors target shapes (hearts, letters, biome icons)? Level Data and level design.
- **Mechanic progression**: which campaign tier introduces each mechanic? Campaign Structure.
- **Versus with M2**: same target for both players, or mirrored shapes? Tournament Flow.

---

## Addendum (2026-10-09): Clear-rule and arrival options, M5–M11

> **Author**: game-designer. **Source**: user decisions of 2026-10-09: colour clears and side arrivals **depend on the level**, so all variants are kept as per-level options. The idea list is in `design/gdd/mechanics-catalog.md`. Every value is a tunable default. The scoring and star notes are proposals for economy-designer to review.

### Slots and the one-mechanic cap

A1. M5–M8 are **clear-rule options**: they set the `clear.detector` and `clear.collapse` strategy slots (ADR-0004 §4; new detector ids such as `colour_connect`, `colour_bridge`, `row` are `ClearDetector` plugins). M9–M10 are **arrival options**: they set the `spawn.arrival` slot (`side_travel`, `side_then_fall`), and M9 also sets the board's down axis. M11 is a **layout option**: two linked boards (`layout.kind`, `spawn.router`). Each one is still a layer-4 level mechanic (rule 1), so it is announced on the Intro card and wins conflicts.

A2. **Pairing exception (proposed)**: at tier ≥ `pair_min_tier` (default 8), a level may combine **one** clear-rule option with **one** arrival option, and the pair counts as the level's single mechanic. No other pairing is allowed. This needs the framework F3 cap to read "one mechanic, or one clear option + one arrival option". See the Open Questions below.

A3. **Colour key.** Colour rules read a cube's `colour_key`, which is its Piece Set `family`. The look of each family per art set is defined in `design/art/block-art-sets.md`. Junk, obstacles, objects and posts that are not painted have no key: they never join a colour group and they break a Mono layer.

A4. **Colour pool.** Levels using M5–M7 limit the piece pool to `colour_count` families (default 4 for M5, 3 for M7, any number for M6). Without this limit, 10 families make groups too rare.

### M5. Colour Pop

5a. Contradicts: only full layers clear. Sets `clear.detector = colour_connect` and `clear.collapse = cascade` (Layer Clearing cascade). The default goal is Clear, counted in pops.

5b. After each lock, the board finds **colour groups**: maximal sets of face-connected cubes with the same `colour_key`. A group **pops** (all its cubes are removed) when it has ≥ `pop_min` cubes (default 6) **and** its cubes come from ≥ `pop_min_pieces` different `piece_instance_id`s (default 2). The second condition stops a single big piece (Chunky 8, Giant 9–27) from popping on its own.

5c. After the pops, the board collapses (cascade) and the detector runs again. Each further round is a **chain** step. The loop stops when nothing pops, or after `chain_max` rounds (default 20, a safety cap).

5d. **Telegraph**: a group that is exactly 1 cube short of `pop_min` (and meets 5b's piece rule) gets a soft rim glow in its colour, so the player can see what to aim for.

5e. Full layers do **not** clear unless the level also sets `layer_clear_too = true` (default false).

### M6. Colour Bridge

6a. Contradicts: only full layers clear. Sets `clear.detector = colour_bridge` and `clear.collapse = cascade`. The goal is Clear, counted in bridges (`bridges_target`, default 3).

6b. Two **posts** stand on opposite edges of the footprint. Each is a pillar obstacle (Obstacles: immune, never moves) `post_height` cells tall (default 3), painted with one `colour_key` `c`.

6c. A **bridge** is a face-connected group of key-`c` cubes that is face-adjacent to both posts. When a bridge exists after a lock, every cube of that group is removed. The board collapses (cascade), and both posts repaint to the next key, drawn from the mechanic's random stream and never the same key twice in a row. The next key is shown in the HUD and on the posts as soon as the repaint happens.

6d. Other colour groups never clear. A level wants an open, mostly flat board: default 7 × 4 footprint, posts on the short edges.

### M7. Mono Layer

7a. Keeps the normal layer clear. It adds this: when a cleared layer's filled cells all share one `colour_key` (A3: any cell with no key breaks it), it is a **Mono Clear**.

7b. A Mono Clear also removes the next `mono_extra_layers` layers above it (default 1, counting only layers with content). It then collapses with the level's `clear.collapse` setting (default slice) and scores the Mono bonus (economy notes below).

7c. **Telegraph**: a layer that is ≥ 50% filled and still all one key shows a thin ring in that colour.

7d. Default board 5 × 5 (A = 25 cells), so a Mono layer is reachable with about 6 pieces of one family (F7).

### M8. Row Clear

8a. Contradicts: only full layers clear. Sets `clear.detector = row`. In any layer, a **row** is a full straight line of active cells along x or along z. Every full row clears; rows along both axes that cross can clear in the same lock.

8b. **Collapse (column slice)**: for each column (x, z), the contents above it drop by the number of cells removed from that column below them. Holes stay holes, matching the base slice rule (no cascade unless the level sets `clear.collapse = cascade`).

8c. A full layer is a special case: all of its rows clear together. Scoring counts it as a layer clear (economy notes below).

8d. Masked boards: a row is a maximal run of active cells of length ≥ `row_min_len` (default 4). Shorter runs never clear.

### M9. Sideways Gravity

9a. Contradicts: pieces fall down. Sets `spawn.arrival = side_travel`. The board's down axis (`board.down_axis`, fixed at level start) becomes `travel_dir`, a ground axis set per level (default −x), using the Board / Grid down-axis re-indexing (the same one Gravity Flip uses in its `axis` mode). Pieces spawn at the opposite wall and fall along `travel_dir`. The far wall is the floor.

9b. Everything follows the new axis: "layers" are planes perpendicular to `travel_dir`, height and `H_play` are measured along it, and soft and hard drop push along it. The player's move controls use the two axes perpendicular to `travel_dir`: up and down on screen, plus one ground axis.

9c. **Camera**: only the snap angles where the angle between `travel_dir` and the view direction is ≥ `side_view_min_deg` (default 45°) are allowed, so the pieces always travel visibly across the screen and never "into" it. Landscape is the preferred orientation.

9d. Default board: 10 along `travel_dir`, 5 × 5 across (so a layer has 25 cells).

9e. **Incompatible** with Gravity Flip. Wind and Conveyor are allowed only along an axis perpendicular to `travel_dir` (validation).

### M10. Slide-In

10a. Contradicts: the player positions the piece freely before it falls. Sets `spawn.arrival = side_then_fall`.

10b. The piece spawns just outside an edge **gate** at spawn height and glides across the board along `travel_dir` (a ground axis) at `slide_speed` (default 2 cells/s). Gravity is paused while it glides.

10c. While gliding, the player may rotate the piece and move it on the **other** ground axis. They cannot move it along `travel_dir`: the verb is timing. A tap (or swipe down) **releases** it. From then on it is a normal falling piece, with the base gravity, lock delay and controls.

10d. If the piece reaches the last column without a release, it auto-releases there.

10e. The gate side is set by `slide_gates`: `one` (default), `alternate`, or `random`. With `random`, the next gate is shown in the preview as an arrow.

10f. The ghost shows the landing spot as if released now, and updates every sim tick.

### M11. Two-Way Meet

11a. Contradicts: one floor, one fall direction. **Re-specified as two linked boards** (architecture review 2026-10-10: ADR-0002 allows one down axis per `BoardState`). Sets `layout.kind = meet` (a new `LayoutKind` plugin, ADR-0004 §1; level JSON uses the `boards` list, ADR-0005) and `spawn.router` per `meet_pattern`.

11b. The level has two boards, `left` (`down_axis +x`) and `right` (`down_axis −x`), placed back to back in the diorama so that their floors meet at a solid glass **seam**. The seam is presentation of the two floors: it never clears and nothing passes through it, because no board links to the other.

11c. Each board's floor is its seam-side wall. Pieces enter the left board from its outer wall (falling +x) or the right board from its outer wall (falling −x), as chosen by the router: `meet_pattern = alternate` (default) → `spawn.router = round_robin`; `random` → `spawn.router = seeded_random` (new router plugin, draws from the level's spawner stream). The preview shows an arrow per queued piece.

11d. Each board is its own clear space with its own layers (planes parallel to the seam), slice collapse, height and `H_play`. Every shape in the pool must fit each board (Piece Set rule 8), which replaces the old "piece longer than a half" check. The level's `goal.top_out` applies to whichever board goes over its limit; the level is lost if either board's top-out loses.

11e. **Pair Clear**: when one board clears a plane at depth k, and the other board cleared its plane at the same depth k on the previous lock, the player scores the Pair bonus. The `meet` layout plugin scores it, because it is the one place that sees both boards' clear events (see Open Questions).

11f. Camera snaps are limited to views with the seam vertical on screen, using 9c's rule with the x axis. Landscape is preferred.

11g. Default boards: 2 boards of 5 deep (along x) each, with a 5 × 5 face. Tiers ≥ 7 only (Readable Chaos).

### Formulas (M5–M11)

**F5. Cubes per clear event.** `cells_per_clear`: layer = A; row = W or D (8a); pop ≥ `pop_min` (often 6–9); bridge ≥ `gap` = distance between the posts (6c, about 5–8 on 7 × 4); mono = A × (1 + `mono_extra_layers`).
*Example:* 6 × 6 board: a layer is 36 cells, a row 6 cells, a typical pop about 7 cells.

**F6. Clear-goal conversion.** To keep a level's length close to a layer-clear level of the same tier:
`N_option ≈ N_layer × A / (cells_per_clear × η_option)`
η_option is how efficiently the option uses placed cubes. Placeholders until playtests: row 0.8, pop 0.6, bridge 0.5.
*Example:* a 6 × 6 layer level with N = 8 → row level N ≈ 8 × 36 / (6 × 0.8) = 60 rows. Pop level ≈ 8 × 36 / (7 × 0.6) ≈ 69 pops. Both are too many to read as a goal, so these levels should state goals in **cubes cleared** (288 cubes) and show a cube bar (Open Questions).

**F7. Mono reachability.** `pieces_for_mono ≈ A / c`, with c the mean cubes per piece of that family (Piece Set F1).
*Example:* A = 25 with Standard family (c ≈ 4) → about 6 pieces of one family in one layer. On 8 × 8 (A = 64) it is about 16, which is too rare. Hence 7d.

**F8. Slide-In time per piece.** `t_piece_slide = t_piece + t_glide`, with `t_glide ≤ W_travel / slide_speed`.
*Example:* W 6, 2 cells/s → up to 3 s more per piece. Star times (Scoring & Stars F1) must use `t_piece_slide`.

**F9. Chain multiplier (M5)**, proposal for Scoring & Stars' "chain multiplier in cascade rounds": `chain_mult(k) = chain_base^(k − 1)`, default `chain_base` 1.5.
*Example:* a 3rd chain step scores ×2.25.

### Scoring and star notes for economy-designer

| Option | Score implication | Star implication |
|---|---|---|
| M5 Colour Pop | `clear_base` per pop scaled by cubes (F5) × chain multiplier (F9). Chains are the skill expression and the score spike: cap the scoring with `chain_max`. | Clear-N goals in cubes or pops (F6). Chain luck widens time variance, so the 3★ margin may need to be looser. |
| M6 Colour Bridge | Per bridge, scaled by bridge length. Longer bridges are slower, so a length bonus keeps the reward fair. | `bridges_target` small (3–5). Time variance is high because of the repaint. |
| M7 Mono Layer | Mono bonus = `mono_mult` (default 3) × the layer score, plus the extra layers. | Monos are optional skill play. Do not tie 3★ to them. |
| M8 Row Clear | Score per row ≈ `clear_base × W / A`, so it is cube-fair; a full layer scores as a layer. | Goal in rows or cubes (F6). |
| M9 Sideways Gravity | Same as base (layer planes). | Same estimates as base with H along `travel_dir`. Add +10% to star times for the learning cost (placeholder). |
| M10 Slide-In | Optional `early_release_points` (default 0): never mandatory, but a small bonus for releasing early is cheap skill expression. | Use `t_piece_slide` (F8). |
| M11 Two-Way Meet | Pair bonus `pair_bonus` (default 150). Clears per half score as layers of A_half. | Two halves halve the per-half area, so clears come faster; recompute N with A_half. |

### Edge cases (M5–M11)

- **M5, a group pops while an item cube is in it**: the item is collected (it counts as a clear, Items rule 2).
- **M5, a status-effect block (frozen) is in a group**: it pops only if the effect lets it clear (Block Status Effects). If not, it blocks the group's connection at that cell.
- **M5, pops and a full layer happen in the same lock with `layer_clear_too`**: the pops resolve first, then the layer check, then the cascade. One chain step.
- **M5, no group can ever reach `pop_min`** (a single-family pool): validation requires `colour_count ≥ 2`.
- **M6, a bridge also touches a third post or forms a loop**: the whole group clears once.
- **M6, the repaint key has no cubes on the board**: fine. The player starts the new bridge from nothing.
- **M6, a post would be buried**: posts are pillars, so they are always reachable from the sides. A bridge can touch any face of a post.
- **M7, a layer of one key with an item cube or a status block**: the item cube keeps its family key, so it counts. A status shell does not change the key.
- **M8, a lock completes rows along x and z that cross**: the shared cell is removed once and counts in both rows' scores.
- **M8, the column-slice collapse leaves a now-full row**: it does **not** clear in the same Resolving (slice, no chain) unless `clear.collapse = cascade`.
- **M9, the view rotates to a forbidden snap**: the rotate-view button skips it.
- **M9 and M11, a Bomb item**: the 3 × 3 × 3 is in world axes and is not affected by the down axis.
- **M10, the player releases over a cell column that is already over the limit**: the piece falls and locks, and `goal.top_out` applies normally.
- **M10, a piece is pushed during the glide by Wind** (perpendicular axis only, 9e-style validation): the push is applied. A push along `travel_dir` is ignored.
- **M11, a piece would land touching both boards**: impossible; they are separate boards with no link. A shape that does not fit a board fails validation (Piece Set rule 8).
- **M11, one board tops out while the other is empty**: `goal.top_out` applies to that board (for trim levels, its over-limit cubes pop off).
- **Any arrival or layout option and staging**: arrows, gates and the seam are view/staging; which wall a piece enters is decided by the sim router and announced in the queue, so replays agree.
- **Any option combined with an incompatible twist**: validation fails (9e).

### Tuning knobs (M5–M11)

| Knob | Range | Default | Category | Affects |
|---|---|---|---|---|
| pop_min | 4–12 | 6 | curve | Pop frequency |
| pop_min_pieces | 1–3 | 2 | gate | Stops single-piece pops |
| colour_count (M5/M7) | 2–6 | 4 / 3 | curve | Group frequency |
| chain_max | 5–30 | 20 | gate | Safety cap |
| chain_base | 1.0–3.0 | 1.5 | curve | Chain score spike (F9) |
| layer_clear_too (M5) | bool | false | gate | Also clear layers |
| post_height | 1–6 | 3 | curve | How easy bridges are |
| bridges_target | 1–8 | 3 | gate | Level length |
| mono_extra_layers | 0–2 | 1 | curve | Mono payoff |
| mono_mult | 1–5 | 3 | curve | Mono score |
| row_min_len | 3–8 | 4 | gate | Masked-board rows |
| travel_dir (M9/M10) | ±x, ±z | −x | feel | Direction |
| side_view_min_deg | 30–75 | 45 | feel | Allowed camera snaps |
| slide_speed | 1–5 cells/s | 2 | feel | Timing difficulty |
| slide_gates | one / alternate / random | one | curve | Predictability |
| early_release_points | 0–50 | 0 | curve | Optional skill reward |
| meet_pattern | alternate / random | alternate | curve | Predictability |
| pair_bonus | 0–500 | 150 | curve | Pair Clear reward |
| pair_min_tier | 6–10 | 8 | gate | When a clear option may pair with an arrival option |

### Acceptance criteria (M5–M11)

16. [U] M5: a face-connected group of 6 same-key cubes from 2 pieces pops; a single 8-cube piece of one key does not.
17. [U] M5: a pop that causes a cascade forming a new group pops in the next chain step; the chain stops at `chain_max`.
18. [U] M6: when a key-`c` group touches both posts, exactly that group is removed, and the posts repaint to a different key.
19. [U] M7: a full layer of one key clears together with the next non-empty layer above; a full mixed layer clears alone.
20. [U] M8: a full x-row in a layer clears only its cells; the columns above drop by the removed count; crossing rows remove the shared cell once.
21. [U] M9: with `travel_dir = −x`, a piece spawned at the +x wall lands against the −x wall or the content in front of it; a full plane perpendicular to x clears.
22. [U] M10: a piece that is not released auto-releases at the last column; a released piece then falls with base gravity.
23. [U] M11: the level loads as two boards with down axes +x and −x; pieces alternate between them with `round_robin`; a plane clears on one board without changing the other; a Pair Clear scores once.
24. [U] Validation: M9 with Gravity Flip fails; M5 with `colour_count = 1` fails; M11 with a shape that does not fit a board fails.
25. [M] For each option, ≥ 80% of playtesters can say what it does after the first two pieces (rule 14 applied to M5–M11).

### Open questions (M5–M11)

- **Framework cap**: accept the pairing exception (A2), or keep strictly one mechanic per level? (Owner: Rule-Twist Framework.)
- **Goal units**: should Clear goals for M5, M6 and M8 count cubes cleared (one comparable bar) rather than pops, bridges or rows (F6)?
- **Two-Way Meet on portrait phones**: playable, or landscape-only?
- **Pair Clear across boards**: ADR-0004 has one `RuleRuntime` per board, so a rule cannot see the other board. Default here: the `meet` `LayoutKind` plugin scores it. Confirm with the ADR-0002/0004 owner.
- **Pairing cap (A2) vs ADR-0004 F3** (mechanic ≤ 1 by layer): alternatively, arrival options could be plain level slot values in `knobs` (no F3 cost) instead of layer-4 rules. Owner: Rule-Twist Framework.
