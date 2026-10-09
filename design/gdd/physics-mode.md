# Physics Mode

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Variation Over Depth; Comeback Energy

## Summary

Physics Mode drops the grid: pieces fall as real, wobbly objects that can slide, tip and topple. It is a family of 13 variants built on one physics core — from a Tricky-Towers-style build race and a grid-with-physics-settle mode to balance challenges, bridges and seesaws. Players steer, spin and tilt the falling piece; once it settles it stays part of a living, wobbly tower.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Board / Grid, Piece Set, Fall, Drop & Lock, Rule-Twist Framework`

## Overview

The concept calls for "physics towers" beside the grid-locked modes, kept isolated behind the Rule-Twist Framework because they must perform on mobile. Physics Mode replaces Movement & Rotation, Fall, Drop & Lock and Layer Clearing for a level (framework edge case) while keeping the board's footprint, the camera, the piece set and the spawner. Each piece becomes a rigid body made of its cubes. While falling, the player moves it in cell-sized steps, spins it and tilts it in 90° steps (roll is off in physics modes), and can soft- or hard-drop it; once it touches something and slows below a threshold for a short time it **settles** and control passes to the next piece. Settled pieces stay physical (they can still be knocked), but pieces far below the top are **frozen** into static bodies to keep the simulation cheap. Most variants are races or challenges about height, balance or shape; pieces that fall off the platform are **drops**, limited per level. This serves *The Block Is the Constant* (still the same blocks), *Variation Over Depth* (13 variants from one core) and *Comeback Energy* (a leader's tower can still topple). All values are starting defaults; the physics engine choice is an ADR (Godot 4.6 defaults to Jolt).

## Detailed Design

### Core Rules

**Physics core**
1. Each piece is one rigid body whose collision shape is its cubes (Piece Set offsets), with mass proportional to cube count, friction `phys_friction` (0.8) and bounce `phys_bounce` (0.05).
2. **Control while falling**: `move(dir)` shifts the piece one cell-width along a ground axis (smooth over 80 ms); `rotate(spin|tilt, ±1)` turns it 90° (roll is disabled by the mode); soft drop raises fall speed ×4; hard drop drops it fast (×12). Falling speed is a controlled descent at the level's `g` (Fall, Drop & Lock F1), not free fall, until contact.
3. **Contact and settle**: after first contact the piece is released to full physics. It **settles** when its linear speed < `settle_speed` (0.2 cells/s) and angular speed < `settle_spin` (10°/s) for `settle_ms` (400), or after `settle_max_ms` (3 000). Then the next piece spawns.
4. **Drops**: a piece (or settled piece) that falls below the platform is a drop; each variant sets `drops_allowed` (default 3); exceeding it loses (or another rule per variant).
5. **Freezing**: settled pieces whose highest point is more than `freeze_depth` (4 cells) below the tower's top become static, so at most `max_active_bodies` (40) are simulated.
6. **Height** is the highest point of any settled, non-dropped piece above the platform (F1).
7. **Grid helpers**: the landing ghost shows a raycast shadow of the piece; the height line and target lines are drawn as in grid modes.

**The 13 variants** (each a Level-Specific Mechanic-style rule set on the core)

| # | Variant | Goal / rule |
|---|---|---|
| 1 | **Tower Race** (Tricky-Towers style) | Reach the height line first; drops allowed 3 |
| 2 | **Grid Settle** | Pieces snap to the grid on settle, but unsupported chunks tip and fall as physics chunks (Layer Clearing chunk mode with physics) |
| 3 | **Balance** | Stack as many pieces as possible on a small platform; any drop ends the run; score = pieces placed |
| 4 | **Bridge Builder** | Span a gap between two cliffs; win when the mascot walks across |
| 5 | **Seesaw** | Build on a pivoting plank; lose if it tilts past 25° for 2 s |
| 6 | **Bowl Fill** | Fill a bowl to its rim line; spills over the rim count as drops |
| 7 | **Windy Tower** | Tower Race with physical gusts (Wind twist as force) |
| 8 | **Meteor Shower** | Survive T seconds while balls fall and knock pieces |
| 9 | **Tallest in Time** | No line: tallest stable tower after 90 s wins |
| 10 | **Gentle Drop** | Pieces landing faster than `fragile_speed` break (count as drops) |
| 11 | **Moving Platform** | The platform slides slowly back and forth; Tower Race goal |
| 12 | **Domino Chain** | Place pieces so a chain topples onto a bell; win when the bell rings |
| 13 | **Reach Out** | Pieces stick on contact (honey physics); build sideways to touch a target flag |

8. Variants are rule sets declared through Level Data and the Rule-Twist Framework (layer 4 for the variant, twists on top where compatible); physics variants can appear in the campaign, Arcade (later) and tournament rounds (Randomizer).

### States and Transitions

Per piece: **Controlled (falling) → Released (contact) → Settled → Frozen**, or **Dropped**.

### Interactions with Other Systems

Replaces Movement & Rotation, Fall Drop & Lock and Layer Clearing for the level; uses Board / Grid (footprint, height line), Piece Set (shapes), Spawner, Camera, Touch Controls (roll hidden), Level Goals (height, survive, custom goals), Rule-Twist Framework (variant rules, physical twists), Tournament Minigames and Randomizer (rounds), Game Feel & VFX, Audio.

## Formulas

### F1. Tower height

`height = max over settled, non-dropped pieces of their highest point − platform top` (in cells). **Example:** a stack reaching 7.4 cells above the platform → 7.4; the Tower Race line at 8 is not yet reached.

### F2. Active body budget

`active = pieces with top > tower_top − freeze_depth` ≤ `max_active_bodies` (40). **Example:** a 12-cell tower with freeze depth 4 → only pieces with a point above 8 cells are simulated.

### F3. Settle time bound

`t_settle ≤ settle_max_ms` (3 s); typical `settle_ms` 0.4 s after the piece stops.

## Edge Cases

- **If a piece never settles** (wobbling): it is force-settled at 3 s.
- **If a frozen piece is hit by a meteor** (variant 8): it is unfrozen for that frame and simulated.
- **If the tower collapses after reaching the line**: the race counts the moment height ≥ line held for `hold_ms` (1 s).
- **If physics differs across devices** (versus): boards are independent; only seeds are shared, so non-determinism doesn't matter.
- **If roll is pressed**: hidden control; no effect.
- **If performance drops below 50 fps**: freeze depth shrinks to 3 automatically.

## Dependencies

**Upstream:** Board / Grid, Piece Set, Fall Drop & Lock (speed), Rule-Twist Framework (Hard).
**Downstream:** Tournament Minigames, Mode / Minigame Randomizer, Level Data (Soft).

## Tuning Knobs

| Knob | Default |
|---|---|
| phys_friction / phys_bounce | 0.8 / 0.05 |
| settle_speed / settle_spin / settle_ms / settle_max_ms | 0.2 cells/s / 10°/s / 400 / 3 000 |
| freeze_depth / max_active_bodies | 4 / 40 |
| drops_allowed | 3 |
| fragile_speed (variant 10) | 6 cells/s |

## Visual/Audio Requirements

Same chunky pieces; wobble shows as soft squash; a drop shows the piece tumbling off the island with a cartoon "whee"; frozen pieces get no visual change. Variant props (bridge cliffs, seesaw plank, bowl, bell, flag) in biome style.

## Game Feel

Wobbly but fair: pieces should feel heavy and grippy, towers should sway rather than explode, and a topple should be funny, not frustrating.

## UI Requirements

Drops-left counter in the goal plate; variant-specific goal icons.

## Cross-References

`design/gdd/game-concept.md` (physics towers, Tricky Towers reference), `board-grid.md`, `piece-set.md`, `fall-drop-lock.md` F1, `layer-clearing.md` (chunk mode), `rule-twist-framework.md` (replacement edge case), `touch-controls.md` (axis disclosure), `docs/engine-reference/godot/VERSION.md` (Jolt default in 4.6).

## Acceptance Criteria

1. [I] **GIVEN** a piece at rest for 400 ms, **THEN** it settles and the next piece spawns; a wobbling piece force-settles at 3 s.
2. [I] **GIVEN** roll input in physics mode, **THEN** nothing happens and roll controls are hidden.
3. [I] **GIVEN** a 4th drop with `drops_allowed = 3`, **THEN** the level is lost.
4. [U] F2: no more than 40 bodies are simulated; pieces below the freeze depth are static.
5. [I] **GIVEN** each of the 13 variants, **THEN** its goal rule triggers a win or loss as specified.
6. [M] **GIVEN** the reference phone with a 30-piece tower, **THEN** the game holds 60 fps.

## Open Questions

- Engine physics settings and determinism → ADR after `/setup-engine`.
- Which variants ship first (prototype Tower Race and Balance first).
- Review the 10 proposed variants (4–13).
