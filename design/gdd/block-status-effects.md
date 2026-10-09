# Block Status Effects

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Readable Chaos; The Block Is the Constant

## Summary

Status effects are shells on locked blocks that change how those blocks behave: **Frozen** and **Vines** make a block tougher to clear (vines also spread), **Honey** makes pieces stick the instant they touch it, **Burning** burns a block away after a few pieces and can spread, **Crumbling** gives way soon after something lands on it, **Shadow** hides the block, and **Spiked** bounces a landing piece up once. Each has its own look from the art bible, and a block carries at most one.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Board / Grid, Rule-Twist Framework`

## Overview

The art bible gives blocks status "shells" (frost, honey, vines, cracks and so on) that re-skin a block without changing its silhouette. This GDD gives each shell its gameplay. A status is a tag on a Block (or obstacle) content; it travels with the block through slice shifts, conveyors and flips; it is applied by level data, twists, items and effects through the Rule-Twist Framework; and its behaviour runs on the framework's hooks. Tough statuses reuse Obstacle Clearing's hit-point model (a Frozen or Vined block adds one hit point, so its full layer waits one resolve). Removal statuses (Burning, Crumbling) use direct damage, leaving holes in slice mode. All values are starting defaults.

## Detailed Design

### Core Rules

1. A **status** is a tag on one block or obstacle: `status_id`, a counter where needed, and the rule that applied it (for framework priority). A block holds **at most one** status; applying a new one replaces the old unless the old one's rule has higher framework priority.
2. Statuses move with their block (shifts, conveyors, flips) and are removed with it.
3. Starter statuses:

| Status | Rule | Hook |
|---|---|---|
| **Frozen** | +1 hit point (Obstacle Clearing); thaws (status removed) when its layer takes layer damage or a layer directly above or below clears | `on_clear`, resolve |
| **Vines** | +1 hit point; every `vine_every_locks` (4) locks, spreads to one random face-adjacent block with no status | `on_lock` |
| **Honey** | A falling piece that comes to rest touching a honey block locks instantly (lock delay 0 for that landing) | resting check |
| **Burning** | After `burn_locks` (3) locks the block is removed (direct damage); when it burns out, each face-adjacent block catches fire with probability `burn_spread_p` (0.3) | `on_lock` |
| **Crumbling** | When anything comes to rest on top of it, it is removed `crumble_locks` (2) locks later | `on_lock` |
| **Shadow** | Drawn at `invisible_alpha` (Twist Library T2) at all times; collision unchanged | visual |
| **Spiked** | The first time a falling piece would come to rest on it, the piece is pushed up 1 cell (`try_translate`) and the spike breaks (status removed) | fall step |

4. **Sources**: Level Data `starting_contents`, twists (e.g. a "frost" biome twist), items and debuffs (later), and pieces spawning with a status tag (the status is applied to all its cubes on lock).
5. Spread uses the rule's random stream (framework rule 13).

### States and Transitions

Per status: **Applied → (counting) → Resolved** (thawed, burned out, crumbled, spike broken) or **Removed** with its block.

### Interactions with Other Systems

Board / Grid (content tags), Rule-Twist Framework (hooks, priority, random), Obstacle Clearing (hit points, direct damage), Fall, Drop & Lock (honey instant lock, spiked bounce), Movement & Rotation (`try_translate`), Twist Library (Shadow alpha; status-applying twists), Items / Buffs & Debuffs (later sources), Game Feel & VFX and Audio.

## Formulas

### F1. Vine spread

`vined(k) ≤ 1 + floor(k / vine_every_locks)` after `k` locks from one starting vine (fewer if no free neighbour). **Example:** 20 locks → at most 6 vined blocks.

### F2. Expected burn spread

`E[new fires per burn-out] = burn_spread_p × free_neighbours` (≤ 6). **Example:** 0.3 × 3 neighbours = 0.9: fires roughly sustain themselves on a dense stack and die out on a sparse one.

### F3. Effective hit points

`hp_eff = hp_base + 1` for Frozen or Vines (blocks have `hp_base = 0` in this sense: a plain block never holds its layer). **Example:** a frozen block → its full layer waits 1 extra resolve (Obstacle Clearing F1); a frozen 2-hp rock → 3.

## Edge Cases

- **If a status is applied to a block that already has one**: replaced unless the old rule has higher priority.
- **If a burning block's layer clears before it burns out**: it is removed with the layer; no spread.
- **If honey and spiked would both apply to one landing**: spiked bounce first (it is a fall step), then honey on the next rest.
- **If a spiked bounce is blocked**: the spike breaks and the piece rests normally.
- **If vines have no free neighbour**: no spread that cycle.
- **If Shadow is on a block during an Invisible Blocks reveal**: it stays hidden (status, not twist).
- **If reduced motion is on**: flames and vine growth animate as static changes.

## Dependencies

**Upstream:** Board / Grid, Rule-Twist Framework (Hard); Obstacle Clearing, Fall Drop & Lock, Movement & Rotation (Hard).
**Downstream:** Twist Library (later twists), Items, Skills, Level Data (Soft).

## Tuning Knobs

| Knob | Default |
|---|---|
| vine_every_locks | 4 |
| burn_locks / burn_spread_p | 3 / 0.3 |
| crumble_locks | 2 |

## Visual/Audio Requirements

> **Status look rule (user decision 2026-10-09):** biome block sets may use the same surface details as statuses (cracks, frost, vines, glowing seams…), so a status must be recognised by its own look: an **animation** on the block (pulse, wobble, flicker), a **buff/debuff colour pulse** on the shell rim, and its **icon badge**. Surface texture alone never identifies a status.

Shells per art bible §3 (re-skin surface, never outline): frost, honey gloss, vine wraps, ember glow and flames, cracks, shadow tint, spikes. Each status also gets a small badge icon (chevron shape not used — those are for buffs/debuffs). Audio: `freeze`, `thaw`, `vine_grow`, `honey_stick`, `ignite`, `burn_out`, `crumble`, `spike_bounce`.

## Game Feel

Statuses should read at a glance and change the player's plan, not punish them blindly: every timed status shows its countdown on the block.

## UI Requirements

None beyond on-board shells and countdown pips.

## Cross-References

`design/art/art-bible.md` §3 (shells), `obstacle-clearing.md` (hp, direct damage), `rule-twist-framework.md` (hooks), `twist-library.md` T2 (alpha), `fall-drop-lock.md` (lock delay), `movement-rotation.md` (`try_translate`).

## Acceptance Criteria

1. [U] **GIVEN** a frozen block in a full layer, **THEN** the layer waits one resolve and the block thaws.
2. [U] F1: one vine over 20 locks with free neighbours → 6 vined blocks.
3. [U] **GIVEN** a piece resting against honey, **THEN** it locks in the same frame.
4. [U] **GIVEN** a burning block, **THEN** it is removed on the 3rd lock and neighbours ignite at 30% ± 3% over 10 000 trials.
5. [U] **GIVEN** a piece rests on crumbling, **THEN** the crumbling block is removed 2 locks later.
6. [U] **GIVEN** a spiked block, **THEN** the first landing piece is pushed up 1 cell and the spike breaks.
7. [U] **GIVEN** a new status on a block with a status, **THEN** priority rules decide which stays.
8. [M] **GIVEN** a playtest, **THEN** testers name each status correctly from its look at play size.

## Open Questions

- Which biome introduces which status (Campaign Structure).
- Whether items can cleanse statuses.
