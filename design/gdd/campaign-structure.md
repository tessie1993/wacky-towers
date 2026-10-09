# Campaign Structure

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant

## Summary

The campaign is 10 biomes of 10 levels each (100 levels). Inside a biome, levels 1–10 are its difficulty tiers: each introduces one new idea and the 10th stacks them. Finishing a level unlocks the next; the next biome opens once you've finished the biome's last level and earned 15 of its 30 stars.

> **Quick reference** — Layer: `Feature` · Priority: `Vertical Slice` · Key deps: `Level Data & Definition, Scoring & Stars`

## Overview

Campaign Structure orders the content Level Data defines and decides what unlocks when. The map is a chain of **biomes** (grass / meadow first; the rest are named when designed — references suggest ice, lava, forest, celestial, underwater, rune/neon). Each biome holds **10 levels**, and a level's **tier** is its position in the biome (1–10). Every biome follows the meadow template (Level Data rule 8): early tiers teach or re-teach, middle tiers introduce the biome's own twists and level mechanics one at a time, and tier 10 is the **biome finale** stacking two twists and a mechanic. Later biomes may call back one earlier twist per level. Base speed rises gently with biome and tier (F2). Finishing a level (1★) unlocks the next; a biome unlocks when the previous biome's finale is finished **and** at least 15 of its 30 stars are earned, so stars matter without blocking casual players for long. Levels can be replayed freely to improve stars. This serves *Variation Over Depth* (new ideas every level, new biome every 10) and *The Block Is the Constant* (every level is still blocks). All values are starting defaults.

## Detailed Design

### Core Rules

1. The campaign is an ordered list of **biomes**; each biome is an ordered list of exactly 10 levels with tiers 1–10 (Level Data `biome`, `tier`), plus one optional bonus level at tier 11 (rule 17).
2. **Biome template** (guide, not law): tier 1 re-teaches the controls with the biome's look; tiers 2–9 each introduce or remix one of the biome's twists or mechanics (4 twists and 4 mechanics in the meadow); tier 10 stacks two twists and one mechanic. A later biome may include **one callback** twist or mechanic from an earlier biome per level.
3. **Level unlock**: finishing level `t` (any stars) unlocks level `t + 1` in the same biome.
4. **Biome unlock**: biome `b + 1` unlocks when biome `b`'s tier-10 level is finished **and** biome `b`'s star total ≥ `biome_star_gate` (default 15 of 30).
5. The first biome (meadow) is open from the start; its level 1 is the first-run experience (Onboarding).
6. **Replays** are free and unlimited; only the best stars and time are kept (Scoring & Stars rule 4).
7. **Speed curve**: a level without its own `g0` uses F2.
8. **Items**: off in the campaign by default (Items rule 12); a biome may enable buffs on chosen levels from biome 2 on.
9. **Unlocked content** for other modes: every twist, mechanic and Special shape met in the campaign joins the Arcade pool (Arcade rule 5) and the Randomizer's pool (later).

### Campaign shape (user decisions 2026-10-09, round 3; all tunable defaults)

10. **Two tracks.** The main path (tiers 1–10) is gentle: most players finish every biome. Optional hard content (the bonus level, puzzle levels and ★★★ targets) holds the real difficulty.
11. **Failure is set per level** (via `warnings_max`, `topout_rule`, `fixed_list`). Main-path levels aim for most first tries finishing; puzzle and bonus levels may be meant to be retried a lot (retry is free).
12. **Length is mixed**: short punchy levels (about 2–4 min) alternate with longer ones (about 6–10 min) inside a biome; no two long levels in a row before the finale.
13. **One new idea per level**, plus remix levels that recombine ideas the player already knows. Arc per biome: **teach** (tiers 1–2) → **twist** (3–8: one new idea each, with remixes between them) → **remix** (9: a hard combination) → **finale** (10).
14. **Twist cap**: at most 2 twists per level (framework F3); a **biome finale may run 3**. One level mechanic as always.
15. **Puzzle levels**: 1–2 per biome use a `fixed_list` (Piece Spawner rule 5b). In the tutorial biome (meadow), the puzzle is the bonus level so the main path stays gentle.
16. **Finale boss**: each tier-10 level gives its twists a face: a biome character that performs the twist events (telegraphs as wind-ups), reacts to the player, and is beaten by the winning clear. The rules stay those of the declared twists and mechanic.
17. **Bonus level**: one per biome (`tier = 11`), off the main path, unlocked when the biome's star total reaches `bonus_star_gate` (default 20 of 30). It does not count toward the next biome's gate. It should be the biome's wackiest level.
18. **Order**: linear inside a biome (rule 3); the player chooses which open biome to play. How a finished biome offers a choice of next biome (for example, opening two at once) is an open question for the map.
19. **Wacky test and biome identity**: every level needs a surprising rule change, something silly, a funny failure and a big visual moment. Each biome has its own mascot critter that reacts, and each twist is presented as a biome-specific event (the meadow's Wind is the "Dandelion Gust"). See `design/levels/meadow.md`.

### States and Transitions

Per level: **Locked → Open → Finished (1–3★)**. Per biome: **Locked → Open → Complete** (finale finished) **→ Mastered** (30★, cosmetic).

### Interactions with Other Systems

Level Data (levels, biomes, tiers), Scoring & Stars (stars), Level Goals (results), Save & Profile (progress), Menus & Level Select (map), Arcade Mode and Mode / Minigame Randomizer (unlocked pools), Points System (stars feed points, later), Onboarding (first run).

## Formulas

### F1. Biome unlock

The biome_unlock formula is defined as:

`open(b + 1) = finished(b, tier 10) AND stars(b) ≥ biome_star_gate`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| stars(b) | int | 0–30 | calculated (Scoring) | Best stars summed over biome b's 10 levels |
| biome_star_gate | int | 0–30 | data file | Default 15 |

**Output Range:** true / false. **Example:** a player who finished all ten meadow levels with ★★ on five and ★ on five has 15 stars → the next biome opens.

### F2. Default base speed

The campaign_g0 formula is defined as:

`g0(b, t) = g0_start + g0_per_tier × (t − 1) + g0_per_biome × (b − 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b | int | 1–10 | data file | Biome index |
| t | int | 1–10 | data file | Tier |
| g0_start, g0_per_tier, g0_per_biome | float | — | data file | 0.6, 0.045, 0.06 (retuned 2026-10-09: "very slow early") |

**Output Range:** 0.6 (meadow 1) to 0.6 + 0.405 + 0.54 ≈ 1.55 cells/s (biome 10, tier 10). **Example:** meadow tier 10 → 1.005 (the meadow levels hand-set g0 within ±0.05 of F2; a level's own `g0` wins); biome 3 tier 1 → 0.72.

## Edge Cases

- **If a level is edited and re-versioned**: its old stars still count toward the gate (Level Data versions).
- **If a player has 14 stars after finishing a biome**: the next biome stays locked; the map shows which levels can earn more.
- **If `biome_star_gate = 0`**: finish-only progression.
- **If a biome has fewer than 10 authored levels** (during development): it is hidden from the shipped map.
- **If a player finishes the last biome**: the campaign is complete; Mastered biomes are cosmetic.

## Dependencies

**Upstream:** Level Data & Definition (Hard), Scoring & Stars (Hard), Level Goals (Hard).
**Downstream:** Save & Profile, Menus & Level Select (Hard), Arcade Mode, Mode / Minigame Randomizer, Points System, Onboarding & Accessibility, Audio (Soft).

## Tuning Knobs

| Knob | Range | Default |
|---|---|---|
| biome_star_gate | 0–30 | 15 |
| g0_start / g0_per_tier / g0_per_biome | — | 0.6 / 0.045 / 0.06 |
| callbacks per level | 0–2 | 1 |
| bonus_star_gate | 0–30 | 20 |
| twists in a finale | 2–3 | 3 max |
| puzzle levels per biome | 0–3 | 1–2 |

## Visual/Audio Requirements

A world map of floating islands (art bible §6: one island per biome, linked); level nodes with stars; a lock showing "★ 15" on gated biomes. Each biome brings its palette, music and frame trim (art bible §4.4, §7). Audio: `level_unlocked`, `biome_unlocked`.

## Game Feel

Progress should feel steady: a new level every ~8 minutes and a new biome every ~1.5 hours of play, with stars as a gentle push rather than a wall.

## UI Requirements

World map and level select (Menus & Level Select). 📌 **UX Flag — Campaign Structure**: include the map in `/ux-design`.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/level-data-definition.md` Core Rules 1–3, 8 | Biome and tier fields; meadow template |
| `design/gdd/scoring-stars.md` Core Rules 1, 4 | Stars and best results |
| `design/gdd/arcade-mode.md` Core Rule 5 | Unlocked pools |
| `design/gdd/items.md` Core Rule 12 | Items off in the campaign by default |
| `design/art/art-bible.md` §4.4, §6, §7 | Biome palettes, islands, frames |
| `design/gdd/game-concept.md` | 10 biomes × 10 tiers; tiers add mechanics, not just speed |

## Acceptance Criteria

1. [U] **GIVEN** level 3 finished with ★, **THEN** level 4 opens.
2. [U] F1: finale finished and 15 stars → next biome opens; 14 stars → stays locked; finale not finished with 30 stars → stays locked.
3. [U] F2: (b 1, t 1) → 0.6; (b 1, t 10) → 1.005; (b 10, t 10) → 1.545; a level's own `g0` overrides.
4. [U] **GIVEN** a replay with fewer stars, **THEN** progress and the gate total are unchanged.
5. [U] **GIVEN** a twist met in the campaign, **THEN** it appears in the Arcade pool.
6. [M] **GIVEN** a playtest of the meadow, **THEN** at least 70% of testers reach 15 stars by the time they finish level 10.

## Open Questions

- **Biome names and order** beyond the meadow.
- **Gate size**: 15 of 30 — tune from the meadow playtest (AC 6).
- ~~**Optional challenge levels**~~: decided, one bonus level per biome (rule 17).
- **Choice of next biome**: does finishing a biome open two biomes at once (a branching map), or is the choice only between biomes already open?
- **Finale twist cap of 3**: the Rule-Twist Framework's F3 cap (2) needs a finale exception; owned by the framework GDD.
- **Mid-campaign difficulty spikes**: tune F2 per biome once more biomes exist.
