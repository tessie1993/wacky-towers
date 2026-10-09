# Level-Specific Mechanics

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos

## Summary

A level-specific mechanic is the one rule that makes a level *that* level: it deliberately breaks a general rule ("full layers don't clear here", "the floor moves") and always wins over twists, items and perks. Each level has at most one. The MVP ships four, all in the grass / meadow biome: **No-Clear Build Race**, **Fill the Target Shape**, **Sticky Landing** and **Conveyor Floor**.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rule-Twist Framework`

## Overview

Biome twists (Twist Library) are reusable modifiers that can appear in many levels. A **level-specific mechanic** is different: it is the level's central idea, often a contradiction of the general rules, and it sits at the top of the Rule-Twist Framework's priority order (layer 4) so nothing else can switch it off. This GDD defines what a level mechanic must declare and the four MVP mechanics. **No-Clear Build Race** turns clearing off and asks the player to build a tower to a target height. **Fill the Target Shape** turns clearing off and asks the player to fill a marked set of cells. **Sticky Landing** makes pieces lock the moment they touch anything. **Conveyor Floor** moves the whole stack one cell along a loop after every lock. Each is built only from the framework's parameters, hooks and API, so new mechanics later are data and small behaviours. All four are designed for the MVP grass / meadow biome but are biome-neutral. This serves *Variation Over Depth* (each level feels different), *The Block Is the Constant* (every mechanic is about placing the same blocks) and *Readable Chaos* (one mechanic per level, always announced). All values are starting defaults.

## Detailed Design

### Core Rules

**What every level mechanic declares**
1. A level mechanic is a Rule-Twist Framework rule at layer `level_mechanic` with: `mechanic_id`, icon and two-word name, the general rule(s) it contradicts, its parameters (with safe ranges), the goal type it expects (if any), and its lifetime (always the whole level).
2. A level has **at most one** mechanic (framework F3). A level with none plays the base rules plus its twists.
3. The mechanic is shown on the Intro goal card next to the goal and stays in the HUD rule strip for the whole level.
4. Because it is layer 4, a mechanic's `set` operations and vetoes beat every twist, item, buff and perk. An item or twist that would undo it has no effect (framework edge case).

**M1. No-Clear Build Race**
5. Contradicts: full layers clear. Sets `clear_enabled = false` (Layer Clearing). Expects the **Height** goal (Level Goals).
6. Rescue wipes (Level Goals warnings) still run: they use Layer Clearing's routine with the `rescue` flag, which `clear_enabled = false` does not block.
7. Parameters: `H_target` (default `H_play − 2`), `height_coverage` (default 0.5). In versus, the first to the target height wins (Level Goals default).

**M2. Fill the Target Shape**
8. Contradicts: full layers clear; any placement is as good as another. Sets `clear_enabled = false`. Expects the **Shape** goal with a set of target cells `M`.
9. Target cells are drawn as marked outlines on the board; they fill in as blocks cover them. Blocks outside `M` are allowed.
10. Parameters: `M` (from Level Data), `stick_when_filled` (default false; if a level turns clearing back on, true keeps a covered target cell counted).

**M3. Sticky Landing**
11. Contradicts: a landed piece can still be adjusted. Sets `lock_delay_ms = 0` and `hard_drop_grace_ms = 0` (Fall, Drop & Lock): a piece locks on the frame it first rests.
12. To stay fair it also multiplies `gravity_scale` by `sticky_gravity_scale` (default 0.7), giving more time to aim in the air. The landing ghost is the player's main tool.
13. Any goal type may be used (default Clear).

**M4. Conveyor Floor**
14. Contradicts: locked blocks never move. After every `conveyor_every` locks (default 1), at `on_resolve_end`, **every content on the board** moves one cell along the conveyor direction `d` (a world ground axis, fixed per level), as one rigid shift.
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
| Layer Clearing | Mechanic → | `clear_enabled = false` (M1, M2); M4 runs after the clear check |
| Fall, Drop & Lock | Mechanic → | Lock delay, grace and gravity (M3); lock count (M4) |
| Board / Grid | Mechanic → | Rigid shift of all contents (M4); target cells (M2) |
| Level Goals & Fail States | ↔ | Expected goal types; rescue still works under M1 |
| Level Data & Definition | → Mechanic | Which mechanic a level uses and its parameters |
| Twist Library | ↔ | Twists combine with a mechanic; the mechanic wins conflicts |
| HUD, Game Feel & VFX, Audio | Mechanic → | Icon, target cells, conveyor arrows and events |

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
| W, D | int | 4–12 | data file (Board) | Footprint width and depth |

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
- **If M1's stack goes over the limit**: the warning rescue runs (bottom wipe) even though clearing is off.
- **If M1's `H_target ≥ H_play`**: validation fails (Level Goals).
- **If M2's target cells include inactive cells or cells above the limit**: validation fails.
- **If M2 is played with `clear_enabled` turned on by the level** (a variant): cleared target cells count as empty unless `stick_when_filled` is true.
- **If M3's hard drop is used**: the piece locks at once, since grace is 0; there is no commit step.
- **If M3's piece rests during a rotation kick**: it locks immediately after the kick.
- **If M4 shifts an object or obstacle**: it moves like any content.
- **If M4 shifts while a status effect is running on a block**: the effect moves with the block.
- **If M4 has no wrap and contents fall off**: they are removed with a visible fall; they do not count as cleared and do not trigger `on_clear`.
- **If M4 runs on a masked board**: validation fails (rule 17).
- **If M4 is combined with the Gravity Flip twist**: the shift is along a ground axis, which stays horizontal after a flip; the flip happens first in Resolving, then the shift.
- **If M4's shift would overlap a falling piece**: impossible; the shift happens in Resolving before the next spawn.
- **If a twist is vetoed by the mechanic** (e.g. a twist wants to clear layers in M1): the twist's action has no effect for this level; validation warns.

## Dependencies

**Upstream:** Rule-Twist Framework (Hard: layer-4 rules, hooks, vetoes); Board / Grid (Hard: content shift, target cells); Layer Clearing (Hard: `clear_enabled`, rescue routine); Fall, Drop & Lock (Hard: lock delay, grace, gravity, lock count); Level Goals & Fail States (Hard: Height and Shape goals).

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
| `design/gdd/layer-clearing.md` Core Rules 2, 5–8 | `clear_enabled`, rescue flag, clear before the shift |
| `design/gdd/fall-drop-lock.md` Core Rules 7–13; F1 | Lock delay, grace, gravity scale |
| `design/gdd/level-goals-fail-states.md` Core Rules 3, 5, 8; F2 | Height and Shape goals, rescue, coverage |
| `design/gdd/board-grid.md` F1; Core Rules 4, 6 | Active cells, masks, contents |
| `design/gdd/piece-set.md` F1 | Mean cubes per piece |
| `design/gdd/game-concept.md` | Build-up races, shape-filling, level mechanics that contradict general rules |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [U] **GIVEN** a level with two mechanics, **THEN** validation fails.
2. [U] **GIVEN** M1, **WHEN** a layer becomes full, **THEN** it does not clear; **WHEN** the stack goes over the limit with a warning left, **THEN** the rescue wipe still runs.
3. [U] **GIVEN** M1 and an item that sets `clear_enabled = true`, **THEN** clearing stays off.
4. [U] **GIVEN** M2 with 60 target cells, **WHEN** the 60th is covered, **THEN** the level is won; blocks outside M do not affect progress.
5. [U] **GIVEN** M3, **WHEN** a piece first rests, **THEN** it locks in the same frame; a hard drop locks at once with no grace.
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
