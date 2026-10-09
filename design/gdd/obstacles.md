# Obstacles

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Variation Over Depth; Comeback Energy

## Summary

Obstacles are cubes on the board that the player didn't place: **crates** that break on the first clear, tough **rocks** that need a few clears, **stone pillars** that stand from floor to sky and never break, and grey **junk** that opponents and twists send in. All of them fill their cell and count toward full layers, so they are part of the puzzle, not walls around it. How they are damaged and removed is defined in Obstacle Clearing.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Board / Grid, Rule-Twist Framework`

## Overview

The Board / Grid GDD reserves an **Obstacle** content type: a non-player cube placed by the level or a rule. This GDD defines the starter obstacle types and how they get onto the board. Every obstacle is a cube-sized content with Board's flags (`solid`, `fills_layer`) plus two of its own: **hit points** (`hp`, how much damage it takes to break; Obstacle Clearing) and **anchored** (whether it ever moves). The four starter types are **Crate** (hp 1: breaks with its layer, a gentle starter), **Rock** (hp 2 by default: holds its full layer back until it breaks), **Stone Pillar** (anchored, unbreakable, a full-height column that counts toward every layer it is in and lets the rest of the layer clear around it — effectively a board shape that also counts as filled) and **Junk** (hp 1, hue-less grey cubes sent by opponents, items or twists, which fill and clear like blocks). Obstacles enter the board three ways: in a level's `starting_contents` (Level Data), from rules through the framework (twists, level mechanics), and from items and versus attacks (later systems). This serves *The Block Is the Constant* (obstacles are cubes too), *Variation Over Depth* (four distinct behaviours from two flags), and *Comeback Energy* (junk is how a trailing player pressures the leader). All values are starting defaults.

## Detailed Design

### Core Rules

**What an obstacle is**
1. An obstacle is a Board content of type **Obstacle** that occupies one cell, with: `obstacle_type`, `solid` (always true for the starter set), `fills_layer` (always true for the starter set), `hp` (1+ or `unbreakable`), `anchored` (true / false), `owner` (none, or the player who sent it), and optional tags (shared with Piece Set tags, e.g. a status effect).
2. Obstacles block movement like blocks (Movement & Rotation) and support falling pieces (resting test).
3. An obstacle never has a piece hue (art bible §4: hues belong to pieces); its look comes from its type and the biome.

**Starter types**

| Type | hp | anchored | Notes |
|---|---|---|---|
| **Crate** | 1 | no | Breaks the first time its layer is full |
| **Rock** | 2 (level 2–3) | no | Its full layer waits until it breaks (Obstacle Clearing) |
| **Stone Pillar** | unbreakable | yes | Occupies the same footprint cell in every layer from the floor to the top of the board; counts as filled; the layer clears around it |
| **Junk** | 1 | no | Grey, hue-less; `owner` = sender; behaves like a block |

4. **Stone pillars** are declared by footprint position, not per cell; a pillar covers that position for the whole board height. They are part of the level layout (`starting_contents`), never sent during play. A pillar cell is never empty, so slices shift past pillars without ever landing on them.
5. **Junk** arrives as whole layers or partial layers pushed in from the bottom (versus "garbage") or as cubes dropped on top, as the sending item or twist defines; this GDD only defines the junk cube.

**Placement**
6. **Level layout**: `starting_contents` in Level Data may place crates, rocks, junk and pillars. Validation: within active cells, below the height limit, not in the spawn zone, pillars only on active footprint positions, and pillars covering at most `pillar_max_share` (default 25%) of the footprint.
7. **Rules**: twists and level mechanics place obstacles only through the framework API (`set`), during Resolving or at the end of a frame (framework rule 14).
8. **Pushed-in junk**: inserting junk from the bottom lifts the whole stack by the number of junk layers (a slice shift upward); the falling piece, if any, is lifted with `place_nearest_up()`. If the lift puts content over the limit, the board reports over limit after the Resolving (Level Goals applies a warning or loss).

**Movement after placement**
9. Unanchored obstacles move with the stack: slice shifts, conveyor shifts, flips' settles, cascade and chunk falls (Layer Clearing, Twist Library, Level-Specific Mechanics). Anchored pillars never move; they act as fixed support.
10. A level with stone pillars cannot use Conveyor Floor or Gravity Flip with a settle that would move pillars (validation): pillars are fixed to the island.

### States and Transitions

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Whole** | Full hp | Placed | Takes damage → Cracked (if hp remains) or Broken |
| **Cracked** | hp below its maximum | Damaged | More damage → Broken |
| **Broken** | Removed from the board | hp reaches 0 | — |

Pillars are always Whole.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | ↔ | Obstacle content with flags, hp, anchored, owner |
| Obstacle Clearing | ↔ | Damage, breaking, layer deferral |
| Layer Clearing | ↔ | Obstacles count toward full layers; removal and deferral per Obstacle Clearing |
| Movement & Rotation, Fall, Drop & Lock | → | Solid and support like blocks |
| Rule-Twist Framework, Twist Library, Level-Specific Mechanics | → Obstacles | Placement through the API |
| Level Data & Definition | → Obstacles | `starting_contents`; validation |
| Items, Tournament Flow, Local Multiplayer | → Obstacles | Junk attacks (later) |
| Level Goals & Fail States | ↔ | Junk lifts can cause a top-out |
| HUD, Game Feel & VFX, Audio | Obstacles → | Looks, crack and break events |

## Formulas

### F1. Pieces per clear with obstacles

The pieces_per_clear_obstacles formula is defined as:

`P_eff_obs = (A − n_obs(y)) / (c × η)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| A | int | 16–144 | calculated (Board F1) | Active cells per layer |
| n_obs(y) | int | 0 to A − 1 | calculated | Obstacle cells already in layer y (pillars count in every layer) |
| c | float | 1–8 | calculated (Piece Set F1) | Mean cubes per piece |
| η | float | 0.6–0.9 | constant (Board) | Packing efficiency |

**Output Range:** lower than the Board's P_eff whenever obstacles are present. **Example:** 8 × 8 with 4 pillar positions: (64 − 4) / 3 = 20 pieces per clear instead of 21.3; a layer that already holds 8 crates: 56 / 3 ≈ 18.7.

### F2. Pillar share

The pillar_share formula is defined as:

`share = n_pillars / A`, valid when `share ≤ pillar_max_share`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_pillars | int | 0 to A | data file (level) | Pillar footprint positions |
| pillar_max_share | float | 0–0.5 | data file | Default 0.25 |

**Output Range:** 0 to `pillar_max_share`. **Example:** 8 × 8 with 16 pillars → 0.25, valid; 17 → invalid.

## Edge Cases

- **If an obstacle would be placed on an occupied or inactive cell**: the placement fails; for rules, the framework logs it and the rule may pick another cell.
- **If pushed-in junk would lift content above the board top**: content that would leave the board top is removed (visible) and the board reports over limit.
- **If a pillar is in the spawn zone path**: pillars always reach the board top, so spawns must avoid pillar positions; the Spawner's footprint-centred spawn shifts to the nearest position where the piece fits (Spawner open question on `spawn_anchor`).
- **If junk is sent to a player who is out**: no effect (framework).
- **If a status effect tag is on an obstacle**: it behaves as on a block (Block Status Effects, later).
- **If an obstacle is in a level with `clear_enabled = false`**: it never takes clear damage; only items and effects can break it.
- **If pillars are combined with Conveyor Floor or a settling Gravity Flip**: validation fails.
- **If a rock's layer is part of a multi-layer clear**: Obstacle Clearing defers that layer only; the others clear.

## Dependencies

**Upstream:** Board / Grid (Hard), Rule-Twist Framework (Hard).

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Obstacle Clearing | Hard | Types, hp, anchored |
| Layer Clearing | Hard | Obstacles count toward fullness; deferral |
| Level Data & Definition | Hard | `starting_contents`, validation |
| Items, Tournament Flow, Local Multiplayer Setup | Soft | Junk |
| Twist Library, Level-Specific Mechanics | Soft | Placement through the API |
| Game Feel & VFX, Audio | Soft | Looks and events |

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| crate_hp | 1 | 1 | Fixed: a crate is the 1-hp obstacle |
| rock_hp | 2–5 | 2 | How long a rock holds its layer (Obstacle Clearing F1) |
| pillar_max_share | 0–0.5 | 0.25 | How much of the footprint pillars may use (F2) |
| junk look | per biome | grey matte | Readability vs. pieces |

## Visual/Audio Requirements

- **Crate**: wooden crate in the biome's material (meadow: planks and twine), matte, ink outline; never glossy like a piece.
- **Rock**: chunky boulder, visible crack stages per hp lost.
- **Stone Pillar**: a carved column rising through the whole board height, slightly translucent above the stack when it would hide the falling piece (Camera occlusion rules apply).
- **Junk**: neutral grey matte cubes with a faint pattern, no motif and no hue (Piece Set: junk uses a neutral matte material).
- Audio events: `obstacle_placed`, `obstacle_cracked`, `obstacle_broken`, `junk_incoming`.

## Game Feel

Obstacles should read as "part of the puzzle": the player sees at a glance which cells are already filled and which obstacles will hold a layer back. Targets: obstacle type recognisable at the 28 px cube size by silhouette and material alone; a crack visible the frame damage lands.

## UI Requirements

None beyond the board. Junk warnings in versus (incoming junk count) belong to the versus HUD (Local Multiplayer Setup).

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 6–7; F1, F2 | Obstacle content type, flags, active cells, pieces per clear |
| `design/gdd/layer-clearing.md` Core Rule 6 | Removal of layer contents (exceptions in Obstacle Clearing) |
| `design/gdd/rule-twist-framework.md` Core Rules 13–14 | Placement API and timing |
| `design/gdd/level-data-definition.md` Core Rule 3 | `starting_contents` |
| `design/gdd/level-specific-mechanics.md`, `twist-library.md` | Conveyor and flip incompatibility with pillars |
| `design/gdd/piece-set.md` Visual/Audio | Junk material, no hue |
| `design/art/art-bible.md` §3, §4 | Matte vs. glossy, hue rules |

## Acceptance Criteria

1. [U] **GIVEN** each starter type, **THEN** it is solid, fills its layer, and has the listed hp and anchoring.
2. [U] **GIVEN** a pillar at footprint (2, 5), **THEN** every layer has an obstacle at (2, *, 5) and `active_cells_in_layer` counts it as filled.
3. [U] **GIVEN** pillars over 25% of the footprint, **THEN** validation fails; pillars with Conveyor Floor or Gravity Flip → validation fails.
4. [U] **GIVEN** 2 layers of junk pushed in from the bottom, **THEN** all contents rise 2 layers, the falling piece is lifted if needed, and over limit is reported after the Resolving if the stack crosses the limit.
5. [U] **GIVEN** obstacles placed by a twist outside Resolving, **THEN** they appear at the end of the frame.
6. [U] F1: 8 × 8 with 4 pillars → 20 pieces per clear.
7. [M] **GIVEN** the reference phone, **THEN** testers identify crate, rock, pillar and junk correctly at play size.

## Open Questions

- **Junk delivery**: bottom push vs. drop on top; how much per attack — Items and Tournament Flow.
- **Rock hp by tier**: 2 by default; harder tiers 3?
- **Pillars and the spawn point**: confirm the Spawner's `spawn_anchor` rule handles pillar positions.
- **More obstacle types**: ice blocks, vines, bombs (Block Status Effects and Items).
