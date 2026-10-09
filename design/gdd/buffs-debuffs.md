# Buffs & Debuffs

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Comeback Energy; Readable Chaos; Variation Over Depth

## Summary

Buffs help you and debuffs hinder an opponent, each for a short time or a few pieces. They are the effects behind items (and later skills and potions): Slow Time, Bomb, Helper Drop and Preview Peek help you; Junk Rain, Fog, Speed Up and Spin Lock hit the leader. Every effect is a Rule-Twist Framework rule at the item/buff layer, so it can never switch off a level's mechanic or twist, and it always shows a cyan (buff) or magenta (debuff) badge.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Rule-Twist Framework`

## Overview

A buff or debuff is a timed or counted change to one player's game. This GDD defines what an effect is, how effects stack, how they are shown, and the eight starter effects. Each effect is a framework rule at layer `item_buff` (priority 2): above perks and the base game, below twists and level mechanics. So a Speed Up multiplies with a level's own gravity, a Slow Time can't undo a Sticky Landing mechanic, and a Spin Lock on a level that already allows only spin simply has no effect. Effects come from Items now and from Skills and shop potions later; they don't know who caused them (systems index: items cause effects, effects don't know about items). Applying the same effect again **refreshes** its duration rather than stacking its strength; different effects combine through the framework's multiply-then-clamp rule. Buffs use the cyan chevron and debuffs the magenta chevron (art bible §4) both in the HUD rule strip and on the affected board's edge. This serves *Comeback Energy* (debuffs let a trailing player hit the leader), *Readable Chaos* (bounded strength, clear colours, short durations) and *Variation Over Depth* (eight very different effects from one contract). All values are starting defaults.

## Detailed Design

### Core Rules

**What an effect is**
1. An effect has: `effect_id`, **polarity** (buff / debuff), **target** (self, or one opponent chosen by the cause), a **lifetime** (duration in play time, a number of the target's pieces, or instant), an icon, and framework operations (parameter modifiers, hook actions, vetoes).
2. Every effect is a framework rule at layer `item_buff`, scoped to the target player.
3. **Same effect again**: the lifetime is refreshed to its full value; strength does not stack. **Different effects** combine by framework F1 (multiply, then clamp).
4. Effects pause with the game, during warnings and during Resolving (framework Suspended).
5. An effect that cannot change anything on the target (all its operations lose to higher layers, or the target is out) shows a "no effect" pop; whether the cause is refunded is the cause's rule (Items).

**Starter effects**

| Effect | Polarity | Target | Lifetime | What it does |
|---|---|---|---|---|
| **Slow Time** | buff | self | 10 s | `gravity_scale × 0.5` |
| **Bomb** | buff | self | next piece | The falling piece (or the next one) gets a `bomb` tag; when it locks, every cube in the 3 × 3 × 3 block centred on the piece's centre cube is removed (the piece's own cubes included); rocks take 2 damage; pillars are immune |
| **Helper Drop** | buff | self | instant | Injects 3 Helper pieces (Mono, Duo, Tri-Straight, Tri-Corner, picked by the effect's random stream) at the front of the queue, outside the stream (Spawner rule 5) |
| **Preview Peek** | buff | self | 20 s | `preview_count + 2` (capped at 3) and `hold_enabled = true`; a held piece stays held when it ends (Spawner edge case: returns to the queue front at the next spawn) |
| **Junk Rain** | debuff | opponent | instant | Pushes 1 layer of junk with one random gap under the target's stack (Obstacles rule 8) |
| **Fog** | debuff | opponent | 10 s | The target's locked blocks follow the Invisible Blocks rules with `visible_ms = 1 000` (Twist Library T2) |
| **Speed Up** | debuff | opponent | 15 s | `gravity_scale × 1.5` |
| **Spin Lock** | debuff | opponent | 10 s | Vetoes tilt and roll for the target (spin still works) |

6. **Bomb** removal follows Obstacle Clearing's direct-damage rule: cells become empty and nothing above falls into them in slice mode. Removed cubes do not count as cleared layers; a layer completed by the bomb's own cubes before the blast is checked in the same resolve before the blast (the blast runs at `on_lock`, after the cubes are written and before the clear check).
7. **Junk Rain** gap position comes from the effect's random stream; the junk `owner` is the cause's owner.

### States and Transitions

Framework states (Pending → Active ⇄ Suspended → Expired). Instant effects go Active → Expired in one step after applying.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | Effect → | Layer-2 rules: parameters, hooks (`on_lock` for Bomb), vetoes (Spin Lock) |
| Items (now), Skills, Shop potions (later) | → Effects | Apply an effect to a target |
| Fall, Drop & Lock | ← | Gravity scale; lock events (Bomb) |
| Piece Spawner & Queue | ← | Injects (Helper Drop); preview and hold (Preview Peek) |
| Movement & Rotation | ← | Axis vetoes (Spin Lock) |
| Obstacles, Obstacle Clearing | ← | Junk (Junk Rain); direct damage (Bomb) |
| Twist Library | ← | Invisible Blocks rules reused by Fog |
| HUD, Game Feel & VFX, Audio | Effect → | Badges, board-edge tint, events |

## Formulas

### F1. Effect strength after stacking

Uses the framework's effective-parameter formula (Rule-Twist Framework F1); no new math. **Example:** a level with `g0 = 1` and a meadow Wind twist: Slow Time on the player → `gravity_scale` 0.5; an opponent's Speed Up at the same time → 0.5 × 1.5 = 0.75.

### F2. Bomb blast cells

The bomb_blast formula is defined as:

`blast = { c + (dx, dy, dz) : dx, dy, dz ∈ {−r..r} }` with `r = bomb_radius` (default 1), `c` = the piece's centre cube (the cube nearest the mean of its cubes; ties: lowest y, then x, then z)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| bomb_radius | int | 1–2 | data file | Default 1 (3 × 3 × 3) |
| c | int[3] | inside the board | calculated | Blast centre |

**Output Range:** up to `(2r + 1)^3` cells (27 by default), clipped to the board. **Example:** a T locked with its centre cube at (3, 2, 4) removes everything in x 2–4, y 1–3, z 3–5 except pillars.

## Edge Cases

- **If the same effect is applied twice**: duration refreshes; no double strength.
- **If Slow Time and Speed Up are both on one player**: they multiply (0.75).
- **If an effect loses to a twist or mechanic** (Spin Lock in a spin-only level; Slow Time under Sticky Landing's set): "no effect" pop.
- **If Bomb is used during Waiting**: it tags the next piece.
- **If Bomb is used twice before a lock**: the second refreshes (one blast).
- **If a bomb piece is hard-dropped**: blast at lock, as usual.
- **If Helper Drop is used with pieces already injected**: the 3 Helpers go in front of them.
- **If Preview Peek ends while a piece is held**: the held piece returns to the front of the queue at the next spawn.
- **If Junk Rain would push the target over the limit**: over limit is reported after the Resolving; Level Goals applies a warning or loss.
- **If Fog hits a board already under the Invisible Blocks twist**: the twist (layer 3) wins where they differ; Fog adds nothing.
- **If the target is out**: no effect (framework).

## Dependencies

**Upstream:** Rule-Twist Framework (Hard), and the systems whose knobs and APIs the effects use: Fall, Drop & Lock, Spawner, Movement & Rotation, Obstacles, Obstacle Clearing, Twist Library (Hard).

**Downstream:** Items (Hard), Skills, Characters & Perks, Shop (Hard, later), Game Feel & VFX, HUD, Audio (Soft).

## Tuning Knobs

| Knob | Range | Default | Affects |
|---|---|---|---|
| slow_time_scale / duration | 0.3–0.8 / 5–20 s | 0.5 / 10 s | Buff strength |
| speed_up_scale / duration | 1.2–2.0 / 5–20 s | 1.5 / 15 s | Debuff strength |
| bomb_radius | 1–2 | 1 | Blast size (F2) |
| bomb_rock_damage | 1–3 | 2 | Bomb vs. rocks |
| helper_drop_count | 1–5 | 3 | Helpers injected |
| preview_peek_duration | 10–30 s | 20 s | Buff length |
| fog_duration / fog_visible_ms | 5–20 s / 500–3 000 | 10 s / 1 000 | Debuff strength |
| spin_lock_duration | 5–15 s | 10 s | Debuff length |
| junk_rain_layers | 1–2 | 1 | Debuff strength |

## Visual/Audio Requirements

- Buffs: cyan chevron badge (art bible §4) in the HUD rule strip with a duration ring; debuffs: magenta chevron on the target's HUD and a thin magenta glow along the target board's edge (never on the cubes, so pieces keep their hues).
- Bomb: the tagged piece shows a fuse sticker (parchment sticker, Piece Set tags); blast is a short cartoon puff with confetti in the removed cubes' hues.
- Helper Drop: three little Helpers pop into the preview; Preview Peek: the preview plate extends with a sparkle.
- Junk Rain: a grey rumble rising from below; Fog: soft mist over the target's stack; Speed Up: speed lines on the falling piece; Spin Lock: tilt and roll controls show a padlock.
- Audio events: `buff_on`, `debuff_on`, `effect_end`, `bomb_blast`, `junk_rise`, `no_effect`.

## Game Feel

Effects should feel punchy but short: a debuff is an obstacle to overcome, never a lock-out. Targets: no debuff longer than 15 s by default; every effect visible within one frame of applying; no debuff removes control of the falling piece.

## UI Requirements

Badges with duration rings in the HUD rule strip (Rule-Twist Framework). No new screens.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/rule-twist-framework.md` Core Rules 1–17; F1 | Layer-2 rules, stacking, vetoes, lifetimes |
| `design/gdd/fall-drop-lock.md` F1 | `gravity_scale` |
| `design/gdd/piece-spawner-queue.md` Core Rules 5–6, 11 | Injects, preview, hold |
| `design/gdd/movement-rotation.md` Core Rule 9 | `Disabled` from vetoes |
| `design/gdd/obstacles.md` Core Rules 5, 8; `obstacle-clearing.md` Core Rule 3 | Junk, direct damage |
| `design/gdd/twist-library.md` T2 | Invisible rules for Fog |
| `design/gdd/piece-set.md` Core Rules 5–6 | `bomb` tag; Helpers |
| `design/art/art-bible.md` §4 | Cyan buff, magenta debuff accents |

## Acceptance Criteria

1. [U] **GIVEN** Slow Time twice within 10 s, **THEN** the scale stays 0.5 and the timer restarts.
2. [U] **GIVEN** Slow Time and Speed Up on one player, **THEN** `gravity_scale = 0.75`.
3. [U] F2: a bomb piece with centre (3, 2, 4) removes the 27 cells around it except pillars; a 2-hp rock in range takes 2 damage and breaks.
4. [U] **GIVEN** Helper Drop, **THEN** the next 3 spawns are Helpers and the stream index is unchanged.
5. [U] **GIVEN** Preview Peek, **THEN** preview shows 3 and hold works for 20 s.
6. [U] **GIVEN** Junk Rain on a target, **THEN** its stack rises 1 layer with one gap in the junk layer.
7. [U] **GIVEN** Fog, **THEN** the target's blocks fade after 1 s for 10 s; collisions are unchanged.
8. [U] **GIVEN** Spin Lock, **THEN** the target's tilt and roll return `Disabled` for 10 s; in a spin-only level the effect shows "no effect".
9. [I] **GIVEN** any effect, **THEN** its badge shows on the right player's HUD in the right accent within one frame.
10. [M] **GIVEN** a versus playtest, **THEN** fewer than 20% of testers call any single debuff "unfair".

## Open Questions

- **Bomb targeting**: blast at the locked piece only, or let the player aim with the ghost? Default: the locked piece.
- **Cleanse**: should a buff remove an active debuff? Not in the starter set.
- **More effects**: freeze opponent's queue, swap next pieces, shield — next pass with Skills.
