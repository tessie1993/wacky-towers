# Obstacle Clearing

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Readable Chaos

## Summary

Obstacle Clearing decides how obstacles break. Every time the game finds a layer full, each breakable obstacle in it takes one hit; a layer only clears once nothing in it is left standing, so a tough rock holds its full layer back for a few more pieces until it cracks apart. Stone pillars never break and simply stay put while the layer clears around them.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Layer Clearing, Obstacles`

## Overview

Obstacles (crates, rocks, pillars, junk) fill cells and count toward full layers. This GDD adds the damage step to Layer Clearing's routine. After Layer Clearing finds the full layers, every **breakable** obstacle in each full layer takes `layer_damage` (1) hit point of damage. A full layer **clears** only if no breakable obstacle in it still has hit points; otherwise it is **deferred**: it stays full on the board, keeps taking a hit at every later resolve, and clears in the resolve where its last obstacle breaks. Crates (1 hp) therefore clear with their layer at once, junk behaves like blocks, and a 2-hp rock holds its layer for one more piece. Stone pillars are unbreakable and anchored: they never take damage, never defer a layer, stay in place when their layer clears, and slices shift past them. Items, skills and effects can also damage obstacles directly through the framework, and a Level Goals rescue wipe removes everything except pillars. This serves *The Block Is the Constant* (obstacles are broken by the same layer clears) and *Readable Chaos* (the player sees cracks and knows exactly how long a layer will wait). All values are starting defaults.

## Detailed Design

### Core Rules

**Damage**
1. A **breakable** obstacle has `hp ≥ 1`; pillars are unbreakable. Damage lowers `hp`; at 0 the obstacle **breaks** (it is removed in the same resolve, Obstacles state Broken).
2. **Layer damage.** In each resolve, right after Layer Clearing's *Find* step (Layer Clearing rule 4), every breakable obstacle in each full layer takes `layer_damage` (default 1). This happens **once per resolve**, not once per chain round, so cascades cannot break a rock instantly.
3. **Direct damage.** Rules may call `damage(cell, amount)` through the Rule-Twist Framework (items, skills, bomb tags, twists). An obstacle broken by direct damage is removed and its cell becomes empty; in slice mode nothing above falls into it (cascade and chunk modes let things fall).
4. **Adjacent damage** (option, off by default): a level or twist may set `adjacent_damage = 1`, so a clearing layer also hits breakable obstacles in the layers directly above and below it.

**Deferral**
5. After layer damage, each full layer is either **clearable** (no breakable obstacle in it has hp left) or **deferred** (at least one does). Layer Clearing clears only the clearable layers; F1 (slice shift) uses only them.
6. A deferred layer stays on the board, stays full, does **not** count toward `layers_cleared`, and is checked again at every later resolve (each one deals more layer damage). It clears in the resolve where its last breakable obstacle breaks, and counts then.
7. A deferred layer shows its obstacles' cracks and a "waiting" outline, so the player knows it will clear.

**Pillars**
8. Pillars never take damage and never defer a layer. When a layer with pillar cells clears, everything in it except the pillar cells is removed.
9. **Slice shift with pillars**: unanchored contents shift down by Layer Clearing F1; pillar cells stay fixed. Since every layer has the same pillar positions, a shifted content never lands on a pillar.

**Rescue and special cases**
10. A Level Goals rescue wipe removes all contents of the wiped layers regardless of hp, except pillar cells.
11. Breaking events carry the source (`layer`, `direct`, `adjacent`, `rescue`) and the obstacle's `owner` (junk), for Scoring & Stars, Items and versus feedback.

### States and Transitions

Per full layer within a resolve: **Found → Damaged → Clearable** (cleared by Layer Clearing) or **→ Deferred** (stays; re-checked next resolve). Obstacle states are in Obstacles (Whole → Cracked → Broken).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Layer Clearing | ↔ | Inserts the damage step after Find; returns clearable vs. deferred layers; pillar-aware slice shift |
| Obstacles | ↔ | hp, anchored, owner; Whole / Cracked / Broken |
| Rule-Twist Framework | → | `damage(cell, amount)`, `adjacent_damage`, `layer_damage` parameters |
| Level Goals & Fail States | ↔ | Deferred layers don't count until cleared; rescue ignores hp |
| Items, Skills, Block Status Effects | → | Direct damage (later) |
| Scoring & Stars | Obstacle Clearing → | Break events with source and owner |
| Game Feel & VFX, Audio | Obstacle Clearing → | Crack, break and waiting-layer events |

## Formulas

### F1. Resolves until a layer clears

The resolves_to_clear formula is defined as:

`r = max(1, ceil( max_hp(y) / layer_damage ))`, where `max_hp(y)` is the highest hp among breakable obstacles in layer y when it first becomes full (0 if none)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| max_hp(y) | int | 0–5 | calculated | Highest remaining hp in the layer |
| layer_damage | int | 1–3 | data file | Damage per resolve; default 1 |
| r | int | 1–5 | calculated | Resolves (including the one that filled it) until it clears |

**Output Range:** 1 when only crates, junk or blocks; more with rocks. **Example:** a layer with a 2-hp rock fills on a lock: resolve 1 → rock at 1, deferred; the next lock's resolve → rock at 0, the layer clears. At about 8 s per piece, the layer waits about 8 s.

### F2. Shift with pillars

The pillar_shift formula is defined as:

`y' = y − |{ c ∈ C : c < y }|` for unanchored contents; `y' = y` for pillar cells

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| C | set of int | — | calculated | Clearable layers this resolve (deferred layers excluded) |
| y | int | 0 to `board_height − 1` | calculated | Content's layer before the shift |

**Output Range:** as Layer Clearing F1. **Example:** C = {2}, a pillar at (1, *, 1), a block at (1, 4, 2) → block to (1, 3, 2); the pillar cell (1, 3, 1) is unchanged.

## Edge Cases

- **If a layer has only pillars and blocks**: it clears normally (pillars stay).
- **If two rocks with different hp share a layer**: the layer waits for the higher one (F1).
- **If a deferred layer loses a block to an item** (no longer full): it stops taking layer damage until it is full again; the rocks keep their current hp.
- **If a deferred layer is below a clearable one**: the clearable one clears; the deferred one does not move (only layers above a cleared layer shift).
- **If a deferred layer is above a clearable one**: it shifts down with the slices, keeping its obstacles and hp.
- **If `clear_enabled = false`**: no layer damage happens; only direct damage breaks obstacles.
- **If direct damage breaks the last rock of a deferred full layer outside a resolve**: the layer clears at the next resolve (after the next lock).
- **If adjacent damage is on and a rock is hit by two clearing layers in one resolve**: it takes 2 damage (one per neighbouring layer) plus any layer damage.
- **If a chain round in cascade mode fills a layer with a rock**: the rock takes no extra damage this resolve (rule 2); the layer waits for the next resolve.
- **If a rescue wipe includes a deferred layer**: it is removed with everything else except pillars; it does not count toward `layers_cleared`.

## Dependencies

**Upstream:** Layer Clearing (Hard: routine and events), Obstacles (Hard: types and flags), Rule-Twist Framework (Hard: direct damage API and parameters).

**Downstream:** Scoring & Stars (Soft: break events), Items, Skills, Block Status Effects (Soft: direct damage), Level Goals & Fail States (Soft: deferred layers and rescue), Game Feel & VFX, Audio (Soft).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| layer_damage | 1–3 | 1 | How fast rocks break (F1) |
| adjacent_damage | 0–1 | 0 | Whether clears hit neighbouring layers |
| rock_hp | 2–5 | 2 (Obstacles) | How long layers wait (F1) |

## Visual/Audio Requirements

- Crack stage per hp lost, visible at play size; a puff and a chunky break when hp reaches 0.
- A deferred layer gets a soft "waiting" outline in the biome's neutral colour (not danger red) and its rock shakes slightly at each hit (static with reduced motion).
- Pillars stay perfectly still during clears; the slices visibly slide past them.
- Audio events: `obstacle_hit`, `obstacle_broken`, `layer_deferred`, `deferred_layer_cleared`.

## Game Feel

Breaking a rock should feel like a reward for patience: each hit lands with a visible crack, and the moment the layer finally clears feels bigger than a normal clear. Targets: crack in the same frame as the hit; deferral never longer than `rock_hp − 1` pieces with defaults.

## UI Requirements

None beyond on-board cues.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/layer-clearing.md` Core Rules 4–8, 11; F1 | Routine steps, slice shift, events |
| `design/gdd/obstacles.md` Core Rules 1–4 | Types, hp, anchored pillars |
| `design/gdd/rule-twist-framework.md` Core Rule 13 | Direct damage through the API |
| `design/gdd/level-goals-fail-states.md` Core Rules 2, 8 | Counting cleared layers; rescue wipe |

## Acceptance Criteria

1. [U] **GIVEN** a full layer with a crate, **THEN** the crate breaks and the layer clears in the same resolve.
2. [U] F1: a full layer with a 2-hp rock → deferred at resolve 1 (rock 1 hp), cleared at resolve 2; it counts toward `layers_cleared` only at resolve 2.
3. [U] **GIVEN** rocks with hp 2 and 3 in one layer, **THEN** it clears at resolve 3.
4. [U] **GIVEN** a chain of 3 cascade rounds in one resolve, **THEN** each rock takes only 1 layer damage in that resolve.
5. [U] **GIVEN** a cleared layer with a pillar, **THEN** the pillar cell stays and other contents shift past it (F2 example).
6. [U] **GIVEN** a deferred layer above a clearing layer, **THEN** it shifts down with its rock and hp unchanged; below → it doesn't move.
7. [U] **GIVEN** direct damage of 2 on a 2-hp rock in slice mode, **THEN** it is removed and the cell above does not fall into it.
8. [U] **GIVEN** `adjacent_damage = 1`, **THEN** obstacles in the layers directly above and below a clearing layer take 1 damage.
9. [U] **GIVEN** a rescue wipe over a layer with a 3-hp rock and a pillar, **THEN** the rock is removed and the pillar stays; nothing counts as cleared.
10. [I] **GIVEN** a deferred layer, **THEN** it shows the waiting outline and crack stages, and a break event carries source and owner.

## Open Questions

- **Score for breaking obstacles**: Scoring & Stars to decide.
- **Deferral feel**: does a waiting full layer feel like a reward or a stall? Playtest with `rock_hp` 2 vs. 3.
- **Adjacent damage**: keep as a twist option or make it the rock's own rule?
