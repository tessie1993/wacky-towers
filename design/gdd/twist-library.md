# Twist Library

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Readable Chaos; The Block Is the Constant

## Summary

The Twist Library holds the reusable rule-twists that biomes and levels draw from. The MVP library has four: **Wind** (gusts nudge the falling piece sideways), **Invisible Blocks** (the stack fades out and you must remember it), **Gravity Flip** (down becomes up) and **Spawned Objects** (things pop up on the stack). A level uses up to two at a time, each with its own telegraph so the player always sees it coming.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rule-Twist Framework`

## Overview

Where a level-specific mechanic is one level's central idea, a **twist** is a reusable modifier: the same Wind can blow in a meadow tutorial and in a tier-9 storm level with different parameters. Each twist is a Rule-Twist Framework rule at layer `twist` (priority 3: above items, buffs and perks, below the level mechanic), built only from the framework's parameters, hooks and API. This GDD defines the contract every twist follows and the four MVP twists. Every twist has a **telegraph** (it warns before it acts), a **parameter set** with safe ranges so tiers can make it harder without new code, and a clear visual identity. **Wind** pushes the falling piece one cell in a shown direction every few seconds. **Invisible Blocks** fades locked blocks out after a short time, revealing them briefly after each clear. **Gravity Flip** swaps the down axis after some clears or time, settling the stack against the new floor. **Spawned Objects** places a meadow object (a mushroom, by default) on top of the stack every few pieces; it fills a cell and clears with its layer. At most two twists run in a level (framework F3). This serves *Variation Over Depth* (four very different twists from one contract), *Readable Chaos* (telegraphs, safe ranges, two at most), and *The Block Is the Constant* (each twist changes how blocks behave, never replaces them). All values are starting defaults.

## Detailed Design

### Core Rules

**The twist contract**
1. A twist is a framework rule at layer `twist` with: `twist_id`, icon and two-word name, parameters with safe ranges, the hooks it uses, a **telegraph** (what the player sees before it acts, and for how long), and its own seeded random stream (framework rule 13).
2. A twist never moves or edits the falling piece except through `try_translate` (Movement & Rotation), and never edits the board except through the framework API. Blocked twist pushes fail silently (no bonk, no lock-delay reset).
3. A level may use up to two twists (framework F3); their parameters come from Level Data. A twist may be marked **incompatible** with another twist or a level mechanic; validation fails on incompatible pairs.

**T1. Wind**
4. Every `wind_interval_ms` (default 6 000, ± `wind_jitter_ms` 2 000 from the twist's random stream) a **gust** pushes the falling piece `wind_strength` cells (default 1) in the wind direction, one `try_translate` per cell. The direction is a world ground axis set by the level (fixed) or rotating each gust (`wind_mode = rotating`, which picks among the four ground axes from the twist's random stream).
5. **Telegraph**: `wind_warn_ms` (default 1 000) before each gust, an arrow on the board edge and streaks show the direction; the arrow is world-anchored, so it stays correct after a rotate-view.
6. A gust affects only a falling piece (not during Waiting or Resolving). It does not reset the lock delay. A gust on a resting piece can push it off a ledge, after which it falls normally.

**T2. Invisible Blocks**
7. After a block locks, it stays visible for `visible_ms` (default 4 000), then fades over `fade_ms` (default 1 000) to `invisible_alpha` (default 0.1). Collision, fullness and the ghost are unchanged: the ghost still lands correctly on invisible blocks.
8. **Reveals**: after each clear, all blocks flash fully visible for `reveal_ms` (default 600) and then fade again. The height-limit line and danger cues always stay visible (Readable Chaos).
9. **Telegraph**: the twist icon shows an eye; each block's fade starts with a short shimmer.

**T3. Gravity Flip**
10. The board's down axis flips between −y and +y when `flip_every_layers` layers have been cleared since the last flip (default 2) or `flip_every_ms` of play has passed (default 45 000), whichever comes first. The flip itself happens at the next Resolving (Board / Grid).
11. On a flip, the stack **settles toward the new floor**: layers are re-indexed along the new down axis (Board / Grid), then the contents slide as rigid slices against the new floor with empty layers removed (the same slice-shift rule as Layer Clearing F1), keeping their order. Without this, the old stack would sit in the new spawn zone and top out at once.
12. The camera does not flip (Camera & Rotate-View); new pieces spawn at the new top and fall the new way, and Touch Controls mapping is unchanged.
13. **Telegraph**: from `flip_warn_ms` (default 2 000) before the flip becomes due, arrows on the island sides point the new way and a countdown ring fills; the flip waits for the next lock if no Resolving happens in that time.
14. Gravity Flip is **incompatible** with No-Clear Build Race and Fill the Target Shape (their goals depend on a fixed floor).

**T4. Spawned Objects**
15. Every `spawn_every_locks` locks (default 6), at `on_resolve_end`, the twist places one **object** on a free **top-surface cell**: an empty active cell below the height limit whose cell below (along the down axis) is the floor or solid content, chosen from the twist's random stream. In the meadow biome the object is a mushroom.
16. The object is `solid = true`, `fills_layer = true`, removed by layer clears like a block (Layer Clearing rule 6) and moved by slice shifts and conveyors like any content. At most `objects_max` (default 4) objects are on the board at once; if none is free or the cap is reached, no object spawns.
17. **Telegraph**: from the lock before a spawn, a sparkle marks the chosen cell (chosen one lock ahead), so the player can avoid or use it.
18. Later variants (objects that prefer colours or shapes, objects that move) reuse this contract with their own hooks.

### States and Transitions

Every twist is Active for the whole level (framework). Per twist cycle:

| Twist | Cycle |
|---|---|
| Wind | Calm → Warning (`wind_warn_ms`) → Gust → Calm |
| Invisible Blocks | per block: Visible (`visible_ms`) → Fading (`fade_ms`) → Hidden; any clear → Revealed (`reveal_ms`) → Fading |
| Gravity Flip | Counting → Warning (`flip_warn_ms`) → Due → Flipping (in the next Resolving) → Counting |
| Spawned Objects | Counting locks → Marked (one lock ahead) → Placed (at `on_resolve_end`) → Counting |

All timers use play time and are Suspended during pause, warnings and results (framework).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Twist → | Layer-3 rules, hooks (`on_tick`, `on_lock`, `on_clear`, `on_resolve_end`), API calls, random streams |
| Movement & Rotation | Twist → | `try_translate` for gusts |
| Board / Grid | Twist → | Down-axis flip, object placement, alpha state per block (visual) |
| Layer Clearing | ↔ | Clears trigger reveals and count toward flips; settle uses slice shift |
| Fall, Drop & Lock | ↔ | Lock count for objects; gravity follows the flip |
| Camera & Rotate-View | ↔ | Camera never flips; wind arrows are world-anchored |
| Level-Specific Mechanics | ↔ | Mechanic wins conflicts; incompatibility list |
| Level Data & Definition | → Twist | Which twists and their parameters |
| HUD, Game Feel & VFX, Audio | Twist → | Icons, telegraphs, events |

## Formulas

All values are starting defaults.

### F1. Gusts per piece (Wind)

The gusts_per_piece formula is defined as:

`gusts ≈ t_fall_active / wind_interval_ms`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_fall_active | float | 0–40 000 ms | calculated (FDL F2 plus lock delay) | Time a piece is falling or resting |
| wind_interval_ms | int | 2 000–15 000 | data file | Mean time between gusts |

**Output Range:** 0 upward. **Example:** a piece in play for 8 s with gusts every 6 s → about 1.3 gusts per piece; with soft drop (2 s) → about 0.3.

### F2. Block visibility (Invisible Blocks)

The block_alpha formula is defined as:

`alpha(t) = 1` for `t < visible_ms`; `1 − (1 − invisible_alpha) × (t − visible_ms) / fade_ms` while fading; `invisible_alpha` after

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t | int | ≥ 0 ms | calculated | Time since the block locked or was last revealed |
| visible_ms | int | 0–10 000 | data file | Time fully visible; default 4 000 |
| fade_ms | int | 200–3 000 | data file | Fade length; default 1 000 |
| invisible_alpha | float | 0–0.5 | data file | Final opacity; default 0.1 |

**Output Range:** `invisible_alpha` to 1. **Example:** at t = 4 500 ms with defaults: `1 − 0.9 × 0.5 = 0.55`.

### F3. Flip timing (Gravity Flip)

The flip_due formula is defined as:

`due = (layers_since_flip ≥ flip_every_layers) OR (play_ms_since_flip ≥ flip_every_ms)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| flip_every_layers | int | 1–10 | data file | Default 2 |
| flip_every_ms | int | 15 000–180 000 | data file | Default 45 000 |

**Output Range:** true / false; the flip applies at the next Resolving. **Example:** on the default 8 × 8 board at about 2.8 min per layer, the 45 s timer usually triggers first, so a level flips about every 45–50 s.

### F4. Object count (Spawned Objects)

The objects_spawned formula is defined as:

`n_spawned ≈ floor(locks / spawn_every_locks)`; on the board at once ≤ `objects_max`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| locks | int | ≥ 0 | calculated | Pieces locked this level |
| spawn_every_locks | int | 2–20 | data file | Default 6 |
| objects_max | int | 1–12 | data file | Default 4 |

**Output Range:** objects add about `1 / spawn_every_locks` cells of free filler per piece. **Example:** 60 pieces → 10 objects spawned over the level; each fills a cell, so about 2.5% of the cubes needed for one 64-cell layer per object.

## Edge Cases

- **If a gust is blocked** (wall or stack): no movement, no bonk, no lock-delay reset.
- **If a gust happens while the player holds a move**: both resolve in arrival order; the gust is one `try_translate` per cell.
- **If Wind and the Conveyor Floor mechanic are in one level**: allowed; the conveyor moves the stack, the wind moves the piece.
- **If the view rotates during a wind warning**: the arrow stays on the same world side; the screen direction it points changes with the view.
- **If an Invisible block is cleared, shifted or moved by a conveyor**: it keeps its timer; clears reveal all blocks.
- **If the player has reduced motion**: the fade still happens (it is the twist); the shimmer and flash become static highlights.
- **If a flip becomes due while a piece is falling**: it waits for the next Resolving (after that piece locks).
- **If a flip settle would put content over the limit**: the board reports over limit after the Resolving; Level Goals applies a warning or loss as usual.
- **If Gravity Flip is combined with an incompatible mechanic**: validation fails.
- **If an object's marked cell is filled by the player before the spawn**: the twist picks another free top-surface cell; if none, no object spawns.
- **If objects reach `objects_max`**: no new objects until one is cleared.
- **If two twists both use `on_resolve_end`** (Spawned Objects and a later twist): they run in framework priority order (both layer 3: activation time, then `rule_id`).
- **If Invisible Blocks and Spawned Objects are combined**: objects follow the same fade rules (they are content on the board).
- **If a twist's parameters are outside their safe ranges**: validation fails.

## Dependencies

**Upstream:** Rule-Twist Framework (Hard); Movement & Rotation (Hard: `try_translate`); Board / Grid (Hard: down axis, content); Layer Clearing (Hard: clear events, slice settle); Fall, Drop & Lock (Hard: lock count, gravity direction); Camera & Rotate-View (Soft: world-anchored telegraphs).

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Level Data & Definition | Hard | Selects twists and parameters |
| Campaign Structure, Arcade Mode | Soft | Biome twists by tier; arcade twist rotation |
| Obstacles, Block Status Effects | Soft | Reuse Spawned Objects' placement rules |
| HUD, Game Feel & VFX, Audio | Soft | Icons, telegraphs, events |

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| wind_interval_ms / wind_jitter_ms | 2 000–15 000 / 0–5 000 | 6 000 / 2 000 | Gust frequency (F1) |
| wind_strength | 1–2 | 1 | Cells per gust |
| wind_mode | fixed / rotating | fixed | Predictability |
| wind_warn_ms | 300–2 000 | 1 000 | Reaction time |
| visible_ms / fade_ms / invisible_alpha | see F2 | 4 000 / 1 000 / 0.1 | Memory difficulty |
| reveal_ms | 200–2 000 | 600 | Relief after clears |
| flip_every_layers / flip_every_ms | see F3 | 2 / 45 000 | Flip frequency |
| flip_warn_ms | 1 000–5 000 | 2 000 | Reaction time |
| spawn_every_locks / objects_max | see F4 | 6 / 4 | Object pressure |

All are per-level data so tiers can raise difficulty without new code.

## Visual/Audio Requirements

- **Wind**: grass bends and petals stream in the wind direction during the warning; the board-edge arrow uses the hazard accent frame (art bible §4); a whoosh on the gust.
- **Invisible Blocks**: blocks fade to a faint ghostly tint with outlines lost last; reveals flash with a soft chime; never confuse with the landing ghost (the ghost keeps its outline style).
- **Gravity Flip**: island-side arrows and a countdown ring; on the flip, the stack slides to the new floor in 300 ms with a deep "whump"; the spawn sparkle moves to the new top.
- **Spawned Objects**: meadow mushroom with a cute face (biome prop style), a sparkle on the marked cell one lock ahead, a pop when it appears, a squeak when it is cleared.
- Every twist icon sits in the HUD rule strip with the hazard orange frame.
- Audio events: `wind_warning`, `gust`, `blocks_fading`, `reveal`, `flip_warning`, `flip`, `object_marked`, `object_spawned`, `object_cleared`.

## Game Feel

Twists should feel like weather, not unfairness: the player always gets a warning and a moment to react. Targets: every action telegraphed at least `*_warn_ms` ahead (wind 1 s, flip 2 s, object one lock); no twist acts during Resolving except the flip and object placement, which happen while the player has no piece.

## UI Requirements

Twist icons in the HUD rule strip and on the Intro card (framework). Telegraphs are on the board, not in the HUD.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 1–17; F3 | Layer-3 rules, hooks, API, random streams, cap of 2 |
| `design/gdd/movement-rotation.md` Core Rule 8 | `try_translate` |
| `design/gdd/board-grid.md` Core Rule 3; Edge Cases (down-axis flip) | Down axis, re-indexing, Resolving-only changes |
| `design/gdd/layer-clearing.md` Core Rules 6, 8; F1 | Objects removed by clears; slice settle |
| `design/gdd/fall-drop-lock.md` Core Rules 10, 18 | Lock delay not reset by twists; gravity follows the down axis |
| `design/gdd/camera-rotate-view.md` Edge Cases | Camera never flips |
| `design/gdd/level-specific-mechanics.md` | Conflicts and incompatibilities |
| `design/art/art-bible.md` §4 | Hazard accent for twist telegraphs |
| `design/gdd/game-concept.md` | Twist list; MVP needs at least 2 twists |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

**Contract**
1. [U] **GIVEN** a level with 3 twists or an incompatible pair, **THEN** validation fails.
2. [U] **GIVEN** a twist pushes the piece into a wall, **THEN** nothing moves, no bonk event, and the lock timer is unchanged.
3. [U] **GIVEN** the same seed, **THEN** gust times, wind directions and object cells are identical across runs and players.

**Wind**
4. [U] **GIVEN** defaults, **THEN** gusts come every 4–8 s, each preceded by a 1 s warning, and push 1 cell.
5. [U] **GIVEN** a gust during Waiting or Resolving, **THEN** it is skipped (no piece to push).
6. [I] **GIVEN** a rotate-view during a warning, **THEN** the arrow stays on the same world side.

**Invisible Blocks**
7. [U] F2: alpha 1 until 4 000 ms; 0.55 at 4 500; 0.1 from 5 000.
8. [U] **GIVEN** a clear, **THEN** all blocks are fully visible for 600 ms, then fade.
9. [I] **GIVEN** hidden blocks, **THEN** the ghost and collisions behave exactly as with visible blocks, and the height-limit line stays visible.

**Gravity Flip**
10. [U] F3: 2 layers cleared or 45 s → due; the flip applies at the next Resolving, after a 2 s warning.
11. [U] **GIVEN** a stack at layers 0–3 and a flip, **THEN** the stack settles against the new floor with its layer order reversed relative to the old floor and no gaps, and the board is not over limit.
12. [I] **GIVEN** a flip, **THEN** the camera does not change, and new pieces spawn at the new top and fall toward the new floor.
13. [U] **GIVEN** Gravity Flip with No-Clear Build Race or Fill the Target Shape, **THEN** validation fails.

**Spawned Objects**
14. [U] F4: 60 locks with `spawn_every_locks = 6` → 10 objects spawned; never more than 4 on the board.
15. [U] **GIVEN** a spawn, **THEN** the object sits on a free top-surface cell below the limit, is solid and fills its layer, and clears with its layer.
16. [I] **GIVEN** the marked cell gets filled before the spawn, **THEN** another free top-surface cell is used (or none).

**Readability**
17. [M] **GIVEN** a playtest of the MVP biome, **THEN** at least 80% of testers can describe each twist after one level, and fewer than 20% call a twist "unfair" (the stacked-rules risk in the systems index).

## Open Questions

- **Wind on hard drops**: should a gust during the 150 ms grace still push? Default yes (the piece is resting); revisit if it feels mean.
- **Invisible + versus**: is memory play fun in party versus, or campaign only?
- **Flip settle direction**: confirm that "rigid slices against the new floor" reads well; alternative is mirroring the whole stack.
- **Object variants**: colour-loving and moving objects (concept) — next Twist Library pass, Vertical Slice.
- **More twists**: build-up hindrances, drifting pieces, blocks that move after placement — next pass.
