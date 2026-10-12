# Twist Library

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; Readable Chaos; The Block Is the Constant

## Summary

The Twist Library holds the reusable rule-twists that biomes and levels draw from. The MVP library has four: **Wind** (gusts nudge the falling piece sideways), **Invisible Blocks** (the stack fades out and you must remember it), **Gravity Flip** (the stack turns upside down on its island) and **Spawned Objects** (things pop up on the stack). A level uses up to two at a time, each with its own telegraph so the player always sees it coming.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Rule-Twist Framework` · ADRs: 0004 (rules, params), 0011 (rules in the sim, beehave staging only)

## Overview

Where a level-specific mechanic is one level's central idea, a **twist** is a reusable modifier: the same Wind can blow in a meadow tutorial and in a tier-9 storm level with different parameters. Each twist is a Rule-Twist Framework rule at layer `twist` (rank 3: above items, buffs, perks, mascots and living content, below the level mechanic), built only from the framework's parameters, hooks and API. In code every twist is a `RuleBehaviour` inside the pure board simulation (ADR-0004, ADR-0011); the Miller, the arrows and the sparkles are **staging** that only animates what the sim announces. This GDD defines the contract every twist follows and the four MVP twists. Every twist has a **telegraph** (it warns before it acts), a **parameter set** with safe ranges so tiers can make it harder without new code, and a clear visual identity. **Wind** pushes the falling piece one cell in a shown direction every few seconds. **Invisible Blocks** fades locked blocks out after a short time, revealing them briefly after each clear. **Gravity Flip** turns the whole stack upside down after some clears or time: every column flips in place and the stack lands back on the same island floor, so the old top becomes the new bottom (user decision 2026-10-10: the stack flips, the island stays). **Spawned Objects** places a meadow object (a mushroom, by default) on top of the stack every few pieces; it fills a cell and clears with its layer. At most two twists run in a level (framework F3). This serves *Variation Over Depth* (four very different twists from one contract), *Readable Chaos* (telegraphs, safe ranges, two at most), and *The Block Is the Constant* (each twist changes how blocks behave, never replaces them). All values are starting defaults.

## Detailed Design

### Core Rules

**The twist contract**
1. A twist is a framework rule at layer `twist` with: `rule_id`, icon and two-word name, parameters with safe ranges, the hooks it uses, a **telegraph** (what the player sees before it acts, and for how long), and its own seeded random stream (framework rule 13; `api.rng()`, ADR-0006). Its data is a rule JSON file (`assets/data/rules/<rule_id>.json`: `layer`, `params` schema, `incompatible_with`, `behaviour`; ADR-0004 §2). MVP rule ids: `gust` (Wind), `fog` (Invisible Blocks), `flip` (Gravity Flip), `mushroom_popup` (Spawned Objects).
1a. **Twists live in the sim** (ADR-0011 §1). Every effect on the board, the piece, the queue or the score is done by the twist's `RuleBehaviour` through `RuleApi`, on the sim clock (`api.now_ms()`, integer ms, never frames or wall time). Every decision the player must see in advance is announced by a sim event that carries the absolute `at_ms` or the remaining `in_ms` (ADR-0011 §6). Staging (beehave `StagingTree`s, presenters, the Miller) reads those events and only animates; removing all staging changes no game result.
2. A twist never moves or edits the falling piece except through `try_translate` (Movement & Rotation), and never edits the board except through the framework API. Blocked twist pushes fail silently (no bonk, no lock-delay reset).
3. A level may use up to two twists (framework F3); their parameters come from the level's `rules` list (Level Data). A twist may be marked **incompatible** with another rule (`incompatible_with`); validation fails on incompatible pairs.
3a. **Relaxed timing** (Onboarding & Accessibility F1) multiplies every twist's `*_warn_ms` by `telegraph_scale` once, at level construction. It never changes mid-level (ADR-0013).

**T1. Wind** (`gust`, Meadow: Dandelion Gust EV01)
4. The gust clock starts at the first spawn, on the level clock. Each gap between gusts is a uniform integer in `[wind_interval_ms − wind_jitter_ms, wind_interval_ms + wind_jitter_ms]` (defaults 6 000 ± 2 000), drawn from the twist's stream when the previous gust ends (or at the first spawn). A **gust** pushes the falling piece `wind_strength` cells (default 1) in the wind direction, one `try_translate` per cell. The direction is a world ground axis set by the level (fixed) or rotating each gust (`wind_mode = rotating`, one draw among the four ground axes, made when the gap is drawn so the warning can show it).
5. **Telegraph**: `wind_warn_ms` (default 1 000) before each gust the sim emits `gust_warn {dir, at_ms}`; an arrow on the board edge and streaks show the direction. The arrow is world-anchored, so it stays correct after a rotate-view.
6. A gust affects only a falling piece. A gust that falls due during Waiting or Resolving is **dropped, not deferred** (`gust_dropped` event), and the clock keeps running. It does not reset the lock delay. A gust on a resting piece can push it off a ledge, after which it falls normally.

**T2. Invisible Blocks** (`fog`, Meadow: Morning Fog EV02)
7. After a block locks, it stays visible for `visible_ms` (default 4 000), then fades over `fade_ms` (default 1 000) to `invisible_alpha` (default 0.1). Collision, fullness and the ghost are unchanged: the ghost still lands correctly on invisible blocks. Starter blocks start their timers at the first spawn.
8. **Reveals**: after each clear, all blocks are fully visible for `reveal_ms` (default 600), then fade over `fade_ms` again (F2). The height-limit line, danger cues, the falling piece and its ghost are never faded (Readable Chaos; ACC-35).
9. **Telegraph**: the twist icon shows an eye; each block's fade starts with a short shimmer. When fog and the camera occlusion fade both apply to a block, its alpha is the lower of the two.
9a. Fog is presentation of sim state: the sim tracks each block's lock or reveal time (so replays agree), and the view computes alpha from it (F2).

**T3. Gravity Flip** (`flip`, Meadow: Topsy Tumble EV03)
10. **Trigger.** The flip falls **due** when `flip_every_layers` layers (default 2) have been cleared since the last flip, or `flip_every_ms` of play time (default 45 000) has passed since the last flip, whichever comes first (F3). With `flip_max > 0`, no flip falls due after `flip_max` flips in the level (default 0 = unlimited).
11. **Warning, then apply.** When the flip falls due, the sim emits `flip_due {axis, in_ms}` and a warning of `flip_warn_ms` (default 2 000, play time) runs. The flip applies at the first Resolving that **starts after the warning ends**, at step S4a (ADR-0011 §3: after the clear check, before `on_resolve_end`), and the sim emits `flip_applied {axis}`. A time trigger starts its warning at `flip_every_ms − flip_warn_ms`, so it is applied on time. Both counters reset when the flip is applied.
12. **The stack flips; the island stays** (`flip_mode = stack`, default). Let `h` be the number of layers from the floor up to the highest layer with content. Every content at layer `y` moves to layer `h − 1 − y` in the same column (x and z unchanged): each column turns upside down in place. Then empty layers are removed with the slice shift (Layer Clearing F1), keeping order. The down axis, the floor, the island, the spawn zone, the height limit, the camera and the controls do **not** change. The old top surface is now the bottom of the stack and the old buried floor is now the top, so holes that were buried become reachable.
13. The flip never raises the stack (the height after a flip is at most `h`), it never completes a layer (each layer keeps its cells), and it never runs while a piece is in play (S4a is in Resolving).
14. **Telegraph**: during the warning, arrows on the board sides curl over the top of the stack and a countdown ring fills. Staging may show the Miller hauling his lever; the island and its diorama never turn (decision 2026-10-10).
15. Gravity Flip is **incompatible** with No-Clear Build Race and Fill the Target Shape (their goals depend on a fixed stack order) and with Sideways Gravity (M9). Obstacles that never move (pillars) cannot be on a board with a flip (Obstacles rule 10).
16. **`flip_mode = axis`** (not used in the Meadow; for later biomes such as the Candy "Fountain Tilt" or Celestial): instead of rule 12, the board's down axis changes to `flip_to_axis` (any of the six directions, default `+y`) with Board / Grid re-indexing, the stack settles toward the new floor as rigid slices, new pieces spawn at the new top and Fall, Drop & Lock gravity follows the new down axis. Same trigger, warning and S4a step.

**T4. Spawned Objects** (`mushroom_popup`, Meadow: Mushroom Pop-up EV04)
17. Every `spawn_every_locks` locks (default 6), counted from the level start, the twist places one **object** at `on_resolve_end` (S4b) on a free **top-surface cell**: an empty active cell below the height limit whose cell below (along the down axis) is the floor or solid content, chosen from the twist's random stream. In the meadow biome the object is a mushroom. With the default, the cell is marked at lock 5 and the object placed at lock 6.
18. The object is `solid = true`, `fills_layer = true`, removed by layer clears like a block (Layer Clearing rule 6) and moved by slice shifts, conveyors and flips like any content. If placing it completes a layer, that layer clears in the S4c pass of the same Resolving (ADR-0011 §3). At most `objects_max` (default 4) objects are on the board at once; if none is free or the cap is reached, no object spawns.
19. **Telegraph**: from the lock before a spawn, a sparkle marks the chosen cell (`object_marked {cell}`, chosen one lock ahead), so the player can avoid or use it. If the marked cell is taken by then, another free top-surface cell is chosen and gets a one-beat sparkle as the object pops (Edge Cases).
20. Later variants (objects that prefer colours or shapes, objects that move) reuse this contract with their own hooks.

### States and Transitions

Every twist is Active for the whole level (framework). Per twist cycle:

| Twist | Cycle |
|---|---|
| Wind | Calm → Warning (`wind_warn_ms`) → Gust (or Dropped) → Calm |
| Invisible Blocks | per block: Visible (`visible_ms`) → Fading (`fade_ms`) → Hidden; any clear → Revealed (`reveal_ms`) → Fading |
| Gravity Flip | Counting → Due + Warning (`flip_warn_ms`) → Waiting for Resolving → Flipping (S4a) → Counting (counters reset); after `flip_max` flips: Spent |
| Spawned Objects | Counting locks → Marked (one lock ahead) → Placed (S4b) → Counting |

All timers use sim play time and are Suspended during pause, warnings and results (framework).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Twist → | Layer-3 rules, hooks (`on_tick`, `on_lock`, `on_clear`, `on_resolve_end`), API calls, random streams |
| Movement & Rotation | Twist → | `try_translate` for gusts |
| Board / Grid | Twist → | Stack flip at S4a (stack mode) or down-axis change (axis mode); object placement; per-block lock/reveal times |
| Layer Clearing | ↔ | Clears trigger reveals and count toward flips; settle uses the slice shift; S4c clears placed objects |
| Fall, Drop & Lock | ↔ | Lock count for objects; Resolving steps S4a–S4c; gravity follows the down axis only in axis mode |
| Camera & Rotate-View | ↔ | Camera never flips; wind arrows are world-anchored; fog alpha combines with occlusion (min) |
| Level-Specific Mechanics | ↔ | Mechanic wins conflicts; incompatibility list; flip at S4a runs before the conveyor at S4b |
| Level Data & Definition | → Twist | Which twists (the `rules` list) and their parameters |
| Staging (ADR-0011), HUD, Game Feel & VFX, Audio | Twist → | Sim events: `gust_warn`, `gust`, `gust_dropped`, `flip_due`, `flip_applied`, `object_marked`, `object_spawned`; icons |

## Formulas

All values are starting defaults.

### F1. Gusts per piece (Wind)

The gusts_per_piece formula is defined as:

`gusts ≈ t_fall_active / wind_interval_ms`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_fall_active | int | 0–40 000 ms | calculated (FDL F2 plus lock delay) | Time a piece is falling or resting |
| wind_interval_ms | int | 2 000–15 000 | rule params | Mean time between gusts |

**Output Range:** 0 upward (an estimate; gusts in Waiting or Resolving are dropped). **Example:** a piece in play for 8 s with gusts every 6 s → about 1.3 gusts per piece; with soft drop (2 s) → about 0.3.

### F2. Block visibility (Invisible Blocks, view-side)

The block_alpha formula is defined as:

`alpha(t) = 1` for `t < t_vis`; `1 − (1 − invisible_alpha) × (t − t_vis) / fade_ms` for `t_vis ≤ t < t_vis + fade_ms`; `invisible_alpha` after

where `t` and `t_vis` are: since the block's lock with `t_vis = visible_ms`, or, after a reveal, since the last reveal with `t_vis = reveal_ms` (rule 8 wins over a restart of `visible_ms`).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t | int | ≥ 0 ms | calculated (sim ms) | Time since the block locked, or since the last reveal |
| visible_ms | int | 0–10 000 | rule params | Time fully visible after the lock; default 4 000 |
| reveal_ms | int | 200–2 000 | rule params | Time fully visible after a reveal; default 600 |
| fade_ms | int | 200–3 000 | rule params | Fade length; default 1 000 |
| invisible_alpha | float | 0–0.5 | rule params (view only) | Final opacity; default 0.1 |

**Output Range:** `invisible_alpha` to 1. Alpha is presentation only, so a float is fine here; the sim holds only integer times. **Example:** 4 500 ms after the lock with defaults: `1 − 0.9 × 0.5 = 0.55`. 900 ms after a reveal: `1 − 0.9 × 0.3 = 0.73`.

### F3. Flip timing (Gravity Flip)

The flip_due formula is defined as:

`due = (flips < flip_max OR flip_max = 0) AND ((layers_since_flip ≥ flip_every_layers) OR (play_ms_since_flip ≥ flip_every_ms − flip_warn_ms))`

The flip then applies at S4a of the first Resolving that starts at least `flip_warn_ms` after it fell due.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| flip_every_layers | int | 1–10 | rule params | Default 2 |
| flip_every_ms | int | 15 000–180 000 | rule params | Default 45 000 |
| flip_warn_ms | int | 1 000–5 000 | rule params | Default 2 000 |
| flip_max | int | 0–10 | rule params | 0 = unlimited; default 0 |
| layers_since_flip, play_ms_since_flip, flips | int | ≥ 0 | calculated | Reset (the first two) when a flip applies |

**Output Range:** true / false. **Example:** on a 6 × 6 board at a heartbeat of about 96 s per layer (Board F6), the 45 s timer triggers first: the warning starts at 43 s and the flip applies at the next lock's Resolving after 45 s, so a level flips about every 45–55 s. meadow_10 with `flip_every_layers` 2 and `flip_max` 1 flips exactly once, at the Resolving after the 2nd clear plus the 2 s warning.

### F4. Object count (Spawned Objects)

The objects_spawned formula is defined as:

`n_spawned ≈ floor(locks / spawn_every_locks)`; on the board at once ≤ `objects_max`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| locks | int | ≥ 0 | calculated | Pieces locked this level (caught or vetoed locks do not count) |
| spawn_every_locks | int | 2–20 | rule params | Default 6 |
| objects_max | int | 1–12 | rule params | Default 4 |

**Output Range:** objects add about `1 / spawn_every_locks` cells of free filler per piece. **Example:** 60 pieces → 10 objects spawned over the level; each fills a cell, so about 2.5% of the cubes needed for one 64-cell layer per object.

## Edge Cases

- **If a gust is blocked** (wall or stack): no movement, no bonk, no lock-delay reset.
- **If a gust happens while the player holds a move**: both resolve in arrival order within the tick; the gust is one `try_translate` per cell.
- **If a gust falls due with no falling piece**: it is dropped (`gust_dropped`); the next gap is drawn as usual.
- **If Wind and the Conveyor Floor mechanic are in one level**: allowed; the conveyor moves the stack, the wind moves the piece.
- **If the view rotates during a wind warning**: the arrow stays on the same world side; the screen direction it points changes with the view.
- **If an Invisible block is cleared, shifted, flipped or moved by a conveyor**: it keeps its timer; clears reveal all blocks.
- **If the player has reduced motion**: the fade still happens (it is the twist); the shimmer and flash become static highlights. The stack flip becomes a cross-fade of at most 300 ms to the flipped stack; arrows and the countdown ring stay (ACC-41).
- **If a flip falls due while a piece is falling**: the warning runs; the flip applies at the first Resolving after the warning ends.
- **If a flip falls due during a warning-state (Level Goals) or pause**: play time is suspended, so the warning waits too.
- **If the stack is empty or one layer high when a flip applies**: nothing visible changes except the reversed layer (one layer is its own mirror); the flip still counts toward `flip_max` and resets the counters.
- **If the board is over the limit when a flip applies**: the flip cannot make it worse (rule 13); Level Goals handles the over-limit state as usual after S4a.
- **If a flip and a conveyor shift happen in one Resolving**: the flip (S4a) first, then the shift (S4b).
- **If objects, eggs or other content sit on the stack at a flip**: they move with their cell like any content; living content reacts in S4b (for example chicks hop after a flip).
- **If Gravity Flip is combined with an incompatible mechanic or a pillar obstacle**: validation fails.
- **If an object's marked cell is filled by the player before the spawn**: the twist picks another free top-surface cell (one-beat sparkle); if none, no object spawns.
- **If a placed object completes a layer**: it clears in the S4c pass; `on_resolve_end` does not run again.
- **If objects reach `objects_max`**: no new objects until one is cleared.
- **If two twists both use `on_resolve_end`** (Spawned Objects and a later twist): they run in framework priority order (both rank 3: activation tick, then `rule_id`).
- **If Invisible Blocks and Spawned Objects are combined**: objects follow the same fade rules (they are content on the board).
- **If a twist's parameters are outside their safe ranges**: validation fails.
- **If the level is replayed, or played with no staging scene**: every gust time, direction, object cell and flip is identical, because all of them are decided in the sim (ADR-0011 §9).

## Dependencies

**Upstream:** Rule-Twist Framework (Hard); Movement & Rotation (Hard: `try_translate`); Board / Grid (Hard: content, down axis in axis mode); Layer Clearing (Hard: clear events, slice settle, S4c); Fall, Drop & Lock (Hard: lock count, Resolving steps); Camera & Rotate-View (Soft: world-anchored telegraphs, occlusion fade). Architecture: ADR-0004 (rule JSON, params, `RuleApi`), ADR-0006 (rule streams), ADR-0011 (twists as `RuleBehaviour`s, S4a/S4c, telegraph events, beehave staging only).

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Level Data & Definition | Hard | Lists twists in `rules` with params |
| Campaign Structure, Arcade Mode | Soft | Biome twists by tier; arcade twist rotation |
| Obstacles, Block Status Effects | Soft | Reuse Spawned Objects' placement rules; pillars forbid the flip |
| Level-Specific Mechanics | Soft | Incompatibilities; S4a before S4b |
| Staging (level scenes), HUD, Game Feel & VFX, Audio | Soft | Sim events listed above; icons |

## Tuning Knobs

| Knob | Range | Default | Category | Affects |
|---|---|---|---|---|
| wind_interval_ms / wind_jitter_ms | 2 000–15 000 / 0–5 000 | 6 000 / 2 000 | curve | Gust frequency (F1) |
| wind_strength | 1–2 | 1 | curve | Cells per gust |
| wind_mode | fixed / rotating | fixed | curve | Predictability |
| wind_warn_ms | 300–2 000 | 1 000 | feel | Reaction time |
| visible_ms / fade_ms / invisible_alpha | see F2 | 4 000 / 1 000 / 0.1 | curve | Memory difficulty |
| reveal_ms | 200–2 000 | 600 | curve | Relief after clears |
| flip_every_layers / flip_every_ms | see F3 | 2 / 45 000 | gate | Flip frequency |
| flip_warn_ms | 1 000–5 000 | 2 000 | feel | Reaction time |
| flip_max | 0–10 | 0 (meadow_10: 1) | gate | Caps flips per level (one-off boss phase) |
| flip_mode | stack / axis | stack | curve | Stack turns over in place vs. down axis changes |
| flip_to_axis (axis mode) | `+x −x +y −y +z −z` | `+y` | curve | New down axis |
| spawn_every_locks / objects_max | see F4 | 6 / 4 | curve | Object pressure |

All are per-level rule params (`rules[i].params`), so tiers can raise difficulty without new code.

## Visual/Audio Requirements

- **Wind**: grass bends and petals stream in the wind direction during the warning; the board-edge arrow uses the hazard accent frame (art bible §4); a whoosh on the gust.
- **Invisible Blocks**: blocks fade to a faint ghostly tint with outlines lost last; reveals flash with a soft chime; never confuse with the landing ghost (the ghost keeps its outline style).
- **Gravity Flip**: side arrows that curl over the stack and a countdown ring; on the flip the stack lifts a little, turns over and drops back onto the same island in about 300 ms with a deep "whump" (the event carries the Resolving length; the view clamps to it). The island, its diorama, the spawn sparkle and the danger line stay where they are. No underside dressing is needed for the flip.
- **Spawned Objects**: meadow mushroom with a cute face (biome prop style), a sparkle on the marked cell one lock ahead, a pop when it appears, a squeak when it is cleared.
- Every twist icon sits in the HUD rule strip with the hazard orange frame.
- Sim events consumed by staging and audio: `gust_warn`, `gust`, `gust_dropped`, `blocks_fading`, `reveal`, `flip_due`, `flip_applied`, `object_marked`, `object_spawned`, `object_cleared`.

## Game Feel

Twists should feel like weather, not unfairness: the player always gets a warning and a moment to react. Targets: every action telegraphed at least `*_warn_ms` ahead (wind 1 s, flip 2 s, object one lock); no twist acts during Resolving except the flip and object placement, which happen while the player has no piece. The flip should read as "my tower did a handstand": each cube stays in its own column, so the player can find their holes again at a glance.

## UI Requirements

Twist icons in the HUD rule strip and on the Intro card (framework). Telegraphs are on the board, not in the HUD.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 1–17; F2, F3 | Layer-3 rules, ranks, hooks, API, random streams, cap of 2 |
| `design/gdd/movement-rotation.md` Core Rule 8 | `try_translate` |
| `design/gdd/board-grid.md` Core Rule 3; Edge Cases (down-axis change) | Content; down axis (axis mode only) |
| `design/gdd/layer-clearing.md` Core Rules 6, 8; F1 | Objects removed by clears; slice settle |
| `design/gdd/fall-drop-lock.md` Core Rules 10, 15, 18 | Lock delay not reset by twists; Resolving steps incl. S4a/S4c; gravity follows the down axis |
| `design/gdd/camera-rotate-view.md` Edge Cases | Camera never flips; occlusion fade |
| `design/gdd/level-specific-mechanics.md` | Conflicts, incompatibilities, flip-then-shift order |
| `design/gdd/meadow-candidate-atoms.md` §9 | EV01–EV04 gaps closed here |
| `design/gdd/onboarding-accessibility.md` F1; `design/accessibility-requirements.md` ACC-35, ACC-41 | Relaxed telegraphs; fog readability; reduced-motion flip |
| `docs/architecture/adr-0004-rule-twist-runtime.md`, `adr-0011-mechanic-level-event-runtime.md` | Rule JSON, `RuleApi`, S4a/S4c, telegraph events, staging-only beehave |
| `design/art/art-bible.md` §4 | Hazard accent for twist telegraphs |
| `design/gdd/game-concept.md` | Twist list; MVP needs at least 2 twists |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

**Contract**
1. [U] **GIVEN** a level with 3 twists or an incompatible pair, **THEN** validation fails.
2. [U] **GIVEN** a twist pushes the piece into a wall, **THEN** nothing moves, no bonk event, and the lock timer is unchanged.
3. [U] **GIVEN** the same seed and command log, **THEN** gust times, wind directions, object cells and flip ticks are identical across runs, with and without a staging host.

**Wind**
4. [U] **GIVEN** defaults, **THEN** every gap is a whole number of ms in 4 000–8 000, the first counted from the first spawn; each gust is preceded by a `gust_warn` 1 000 ms ahead and pushes 1 cell.
5. [U] **GIVEN** a gust due during Waiting or Resolving, **THEN** it is dropped (`gust_dropped`), not delayed, and the next gap is drawn.
6. [I] **GIVEN** a rotate-view during a warning, **THEN** the arrow stays on the same world side.

**Invisible Blocks**
7. [U] F2: after a lock, alpha 1 until 4 000 ms; 0.55 at 4 500; 0.1 from 5 000.
8. [U] **GIVEN** a clear, **THEN** all blocks are fully visible for 600 ms, then fade over 1 000 ms (alpha 0.73 at 900 ms after the reveal).
9. [I] **GIVEN** hidden blocks, **THEN** the ghost and collisions behave exactly as with visible blocks, and the height-limit line, falling piece and ghost stay visible.

**Gravity Flip**
10. [U] F3: 2 layers cleared or 45 s → `flip_due`; the flip applies at S4a of the first Resolving that starts ≥ 2 000 ms later; both counters reset.
11. [U] **GIVEN** a stack in layers 0–3 and a flip, **THEN** every cube keeps its x and z, a cube at layer y ends at layer 3 − y, no empty layer remains below content, and the stack is not higher than before.
12. [I] **GIVEN** a flip, **THEN** the down axis, spawn position, height limit, camera and controls are unchanged, and the island scene does not move.
13. [U] **GIVEN** Gravity Flip with No-Clear Build Race, Fill the Target Shape, Sideways Gravity or a pillar obstacle, **THEN** validation fails.
14. [U] **GIVEN** `flip_max = 1`, **THEN** exactly one flip happens however many layers are cleared afterwards.
15. [U] **GIVEN** a flip and a conveyor shift in one Resolving, **THEN** the flip applies first.

**Spawned Objects**
16. [U] F4: 60 locks with `spawn_every_locks = 6` → 10 objects spawned (marked at lock 5, placed at lock 6, …); never more than 4 on the board.
17. [U] **GIVEN** a spawn, **THEN** the object sits on a free top-surface cell below the limit, is solid and fills its layer, and clears with its layer; if it completes a layer, that layer clears in the same Resolving (S4c).
18. [I] **GIVEN** the marked cell gets filled before the spawn, **THEN** another free top-surface cell is used (or none).

**Readability**
19. [M] **GIVEN** a playtest of the MVP biome, **THEN** at least 80% of testers can describe each twist after one level, and fewer than 20% call a twist "unfair" (the stacked-rules risk in the systems index).
20. [M] **GIVEN** a playtest of meadow_09, **THEN** at least 80% of testers can point to where their old bottom holes went after the first flip.

## Open Questions

- **Wind on hard drops**: should a gust during the 150 ms grace still push? Default yes (the piece is resting); revisit if it feels mean.
- **Invisible + versus**: is memory play fun in party versus, or campaign only?
- **Flip as a true turn-over**: the default flips each column in place (y only). A real 180° turn about a ground axis would also mirror x or z and reads as a "pancake flip", but cubes change column. Keep in-place unless playtests say the in-place flip looks fake. (Owner: game-designer with art-director.)
- **Object variants**: colour-loving and moving objects (concept) — next Twist Library pass, Vertical Slice.
- **More twists**: build-up hindrances, drifting pieces, blocks that move after placement — next pass.
