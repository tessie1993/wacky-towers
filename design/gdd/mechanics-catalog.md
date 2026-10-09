# Mechanics Catalog

> **Status**: In Design
> **Author**: Tessa + agents (game-designer)
> **Last Updated**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos; Comeback Energy

## Purpose

This is a menu of every level mechanic, rule variation, board variant, goal variant, physics idea and minigame proposed so far for going "beyond the layer clearer". It is not a system GDD. When an idea is **Picked**, its full rules move into the owning GDD and this catalog only links to them. **Candidate** ideas are ready to pick up. **Parked** ideas are kept but are not planned. All values are tunable defaults.

Every idea must pass two tests:
- **Pillar 1 test**: it is built from the same Piece Set blocks.
- **Pillar 2 test**: it can be explained in one sentence and seen on the board within the first two pieces.

**Columns**
- **Slots**: the architecture strategy slots the idea uses: `clear_detector`, `collapse`, `spawn_entry`, `top_out_check`, `goal_evaluator`, `board_kind`.
- **Hooks into**: TW = twist (Rule-Twist Framework layer 3), LM = Level-Specific Mechanic (layer 4), MG = tournament minigame, Data = Level Data only.
- **Cost**: S / M / L.
- **Diff**: how different it feels from the base game, from 1 to 5.

**Colour.** Every colour rule in this catalog uses the block's **colour key**, which is its Piece Set **family**. Its look per art set is settled in `design/art/block-art-sets.md`: every biome keeps each family at the same relative lightness and warmth, plus the face motif. Colour definition is not re-opened here.

## 1. Clear-rule variants (`clear_detector` + `collapse`)

| # | Idea | Hook | Slots | Hooks into | Cost | Diff | Status | Pillar notes |
|---|---|---|---|---|---|---|---|---|
| C1 | **Colour Pop** | 6+ face-connected cubes of one colour key (from 2+ pieces) pop; what's above falls and can chain | `clear_detector = colour_connect`, `collapse = cascade` | LM M5 | M | 4 | **Picked** (per-level option) | P1: same blocks, new verb (match). P2: groups glow when 1 cube short. |
| C2 | **Colour Bridge** | Join two coloured posts with a path of their colour; the path clears | `clear_detector = colour_bridge`, `collapse = cascade` | LM M6 | M | 5 | **Picked** (per-level option) | P2: posts are tall and bright; the path previews as it grows. |
| C3 | **Mono Layer** | A full layer of one colour clears with a blast that also takes the layer above | `clear_detector = layer` + mono check | LM M7 | S | 2 | **Picked** (per-level option) | Low Diff, but teaches colour reading for C1/C2. |
| C4 | **Row Clear** | Any full straight row inside a layer clears just that row | `clear_detector = row`, `collapse = slice` (per column) | LM M8 | S | 3 | **Picked** (per-level option; listed by the user 2026-10-09) | Easy step up from layer clears. |
| C5 | Pillar Clear | A full vertical column clears | `clear_detector = column` | TW | S | 3 | Candidate | Rewards walls; pairs well with Two-Way Meet. |
| C6 | Ring Clear | The outer ring of a layer clears and the core stays | `clear_detector = ring` | LM | S | 3 | Candidate | Pairs with donut masks. |
| C7 | Cube Pop | Any solid 2×2×2 cube pops | `clear_detector = cube` | LM | M | 4 | Candidate | Strong 3D-thinking verb; check its readability first. |

## 2. Piece-arrival variants (`spawn_entry`)

| # | Idea | Hook | Slots | Hooks into | Cost | Diff | Status | Pillar notes |
|---|---|---|---|---|---|---|---|---|
| A1 | **Sideways Gravity** | Pieces enter from one wall and fall sideways; the far wall is the floor | `spawn_entry = side`, down axis = `travel_dir` | LM M9 | M | 4 | **Picked** (per-level option) | Reuses Gravity Flip's down axis. Restricted to camera snaps that read well. |
| A2 | **Slide-In** | The piece glides in from an edge at the top; tap to drop it | `spawn_entry = slide_in` | LM M10 | S | 3 | **Picked** (per-level option) | The verb is timing (Tower Bloxx / Stack). |
| A3 | **Two-Way Meet** | Pieces alternate from the left and right walls and stack toward a centre seam | `spawn_entry = side_alternating`, split down axis | LM M11 | M | 5 | **Picked** (per-level option) | Highest readability load: late tiers only. |
| A4 | Pick a Gate | The player taps which of 4 edge gates the next piece enters from | `spawn_entry = gate_choice` | TW | S | 3 | Candidate | Adds autonomy to A2. |
| A5 | Twin Drop | Two linked pieces fall and move as one | spawner pair | LM | M | 4 | Candidate | Check that rotation stays readable. |
| A6 | Shelf Draft | Pick 1 of 3 pieces from a shelf | spawner choice | TW | S | 3 | Candidate | Pure autonomy; good for slow tiers. |
| A7 | Rising Floor | A junk layer pushes up every N locks | Obstacles junk | TW | S | 2 | Candidate | Already possible through Junk Rain. |

## 3. Board variants (`board_kind`, masks, Resolving hooks)

| # | Idea | Hook | Hooks into | Cost | Diff | Status | Notes |
|---|---|---|---|---|---|---|---|
| B1 | Turntable | Every N locks the stack (not the camera) turns 90° | LM | M | 3 | Candidate (used in MG12 Spin Cycle) | A rigid rotation in Resolving, like Conveyor. |
| B2 | Crumbling Edge | Rim cells crumble on a timer and the footprint shrinks | TW | M | 3 | Candidate | Uses Block Status `crumbling` visuals. |
| B3 | Twin Towers | Two small boards; pieces alternate between them | LM | M | 4 | Candidate | Needs a split camera. Parked if it is not readable. |
| B4 | Lava Floor | The bottom layer melts every N seconds | TW | S | 3 | Candidate (used in MG13 Floor Is Lava) | |
| B5 | Donut and Stairs | Masked or stepped floors | Data | S | 2 | Candidate | Data only. |

## 4. Goal variants (`goal_evaluator`)

| # | Idea | Hook | Hooks into | Cost | Diff | Status | Notes |
|---|---|---|---|---|---|---|---|
| G1 | Shadow Match | Build so the stack casts the shown front and side silhouettes | LM | M | 5 | Candidate (used in MG10 Shadow Duel) | Picross in 3D. |
| G2 | Mascot Path | Build stairs so the mascot can walk from flag A to flag B | LM | M | 5 | Candidate (used in MG6 Mascot Bridge Race) | |
| G3 | Perfect Box | Fill a box with no holes | LM | M | 4 | Candidate (used in MG7 Box Packers) | |
| G4 | Dig Out | Clear down to free a buried critter | LM | S | 3 | Candidate | Reuses Obstacle Clearing. |
| G5 | Sinking Ceiling | A lid lowers over time; stay under it | TW | S | 3 | Candidate | Mirror of Lava Floor. |

## 5. Physics and wobble

| # | Idea | Hook | Hooks into | Cost | Diff | Status | Notes |
|---|---|---|---|---|---|---|---|
| P1 | Stack Trim | Cubes hanging past their support snap off (grid, no physics engine) | LM / `top_out_check` | S | 4 | Candidate (used in MG4, MG15) | Shares its pop-off logic with the Trim top-out rule. |
| P2 | Wobble Meter | Overhangs add wobble; past a threshold the top piece slips one cell | LM | M | 4 | Candidate | |
| P3 | Crane Drop | The piece swings on a crane; tap to release | Physics Mode variant | M | 4 | Candidate (used in MG5 Crane Tower) | |
| P4 | Pull Out | Remove a block from the tower without toppling it (Jenga) | Physics Mode variant | L | 5 | Parked | Expensive. Revisit after Physics Mode ships. |

## 6. Build-race top-out rules (`top_out_check`)

**Research.** In Tricky Towers' race mode, dropped bricks cost height and time, not elimination, and a win needs the tower to stand for about 3 s past the line. Lives belong to its Survival mode. Our rule follows the same principle: **time is the penalty, not elimination.**

| Rule | `topout_rule` | What happens when a cube goes over the limit | Status |
|---|---|---|---|
| **Trim** | `trim` | Cubes above the limit pop off. The level never fails, so time is the only cost. | **Default** for build races (decided by level-designer 2026-10-09; owned by Level Goals & Fail States) |
| Shake Loose | `shake` (proposed) | The tower shudders and every cube not supported straight down to the floor falls off. The solid core stays. It may not trigger again until the next lock. | Alternative a mode may pick |
| Bonk and Stun | `bonk` (proposed) | The offending piece bounces off and is removed; the player is frozen for `bonk_stun_ms` (2 000). | Alternative a mode may pick |
| Three Hearts | `hearts` (proposed) | Each top-out costs a heart and pops the last piece. At 0 hearts the player is out but keeps sending sabotage (ghost rules in Tournament Minigames). | Alternative for Survival rounds |

The enum `rescue | trim | lose` is owned by `level-goals-fail-states.md`. The three values above are proposals to add when a mode first needs them.

## 7. Tournament minigames

There are 15 for Alpha, all designed in `design/gdd/tournament-minigames.md`:

Hole in the Wall, Copycat, Colour Rush, Perfect Stack, Crane Tower, Mascot Bridge Race, Box Packers, Gift Exchange, Speed Sort, Shadow Duel, Memory Tower, Spin Cycle, Floor Is Lava, Hot Block, Catch Tower.

## 8. Where the picked level options fit (suggestions for level-designer)

These are suggestions only; the biome order is per `design/art/block-art-sets.md`.

| Option | Suggested home | Why |
|---|---|---|
| M8 Row Clear | Forest, early tiers | The smallest change from layer clears, so it is a good second-biome idea. |
| M10 Slide-In | Forest or Desert, mid tiers; Perfect Stack minigame | Timing verb, gentle, normal gravity. Pairs with build races. |
| M7 Mono Layer | Desert, mid tiers | Teaches colour reading before the harder colour rules. |
| M5 Colour Pop | Underwater (bubbles) or Ice, from mid tiers | Needs colour reading; cascades suit a "floaty" biome. |
| M9 Sideways Gravity | Underwater (current) or Desert (sandstorm) | The theme explains the sideways pull. |
| M6 Colour Bridge | Cave or Lava (bridge over a chasm) | Spatial path-building suits a mid-to-late biome. |
| M11 Two-Way Meet | Clockwork (two gear chutes), tiers 7+ | The highest readability load, so it goes late. |

## Cross-References

`level-specific-mechanics.md` (M5–M11 full rules), `tournament-minigames.md`, `level-goals-fail-states.md` (`topout_rule`), `twist-library.md`, `physics-mode.md`, `piece-set.md` (families), `design/art/block-art-sets.md` (colour per set), `game-concept.md` (pillars).
