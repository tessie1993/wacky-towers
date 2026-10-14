# Level difficulty curve check: 2026-10-14

Scope: every catalog level, per biome, tiers 1-10 (main), 11 (bonus) and 12-14 (hard track h1-h3).
Signals: `knobs.fall.g0`, `goal.n` (clear_n only) and `stars` (t2/t3 ms; s2/s3 for survive).
An inversion means a later tier is clearly easier on the same axis than the tier before it. All
values are initial estimates with no playtest medians, so only clear inversions were changed.

## Deliberately excluded

- Tier-6 `shape` levels (g0 0.6-0.9) and tier-11 bonus levels. These are finite, proof-backed
  breather puzzles (`assets/data/campaign/puzzle_proofs.json`) where fall speed is not the challenge.
- lava_h3 (g0 0.8, n 1). It is a fixed-list finite puzzle.

## fall.g0 inversions: fixed (data only)

| Level | Was | Now | Reason |
|---|---|---|---|
| pirate_06 | 0.85 | 1.00 | below pirate_05 (0.95) on a clear_n level |
| celestial_08 | 1.30 | 1.45 | below celestial_07 (1.40) |
| carnival_08 | 1.40 | 1.50 | below carnival_07 (1.45) |
| meadow_h3 | 0.95 | 1.00 | hard finale below meadow_h2 (1.00) |
| ice_h2 | 1.00 | 1.05 | below ice_h1 (1.05) |
| cave_h3 | 1.25 | 1.30 | hard finale below cave_h2 (1.30) |
| carnival_h3 | 1.45 | 1.55 | hard finale below carnival_h2 (1.55) |

Each changed file has a `metadata.design_amendments` entry pointing here (pirate_06 was edited
in place to keep its hand formatting, so it has no amendment entry).

Flat, but not inverted: meadow_h1 equals meadow_09 (0.95), and the clockwork/neon hard tracks
sit level at 1.30. Hard-track g0 sits at or below tier 10 in clockwork (1.40 to 1.30),
celestial (1.50 to 1.45) and cave (1.35 to 1.30). The hard track may be meant to carry its
difficulty in twists rather than speed. **Flagged for the designer, not changed.**

## goal.n: flagged only

Most biomes follow a 2 / 3 / 4 / 3 rhythm on tiers 1-4, with n dropping when a new twist arrives.
That reads as intentional, so nothing was changed. Outliers worth a look:

- clockwork_02 n=1 after clockwork_01 n=2.
- forest_08 n=2 and cave_08 n=2 sit between n=4 levels.
- Finales with lower n than tier 9: meadow_10 (3 vs 4), forest_10, cave_10, clockwork_10,
  celestial_10, carnival_10 (3 vs 4). These are consistent with the three-twist finale budget.
- carnival_h3 n=3 after carnival_h2 n=4.

## Stars: flagged only

There are no `t3 > t2` or `s3 < s2` violations (LevelValidator enforces these). Pace per clear
(t3 / n) is far below the biome median (< 0.65x) for meadow_02 (53k vs 93k), meadow_h3 (55k),
ice_10 (47k vs 98k), underwater_02 (61k), forest_04 (52k), cave_06 (62k), cave_09 (61k) and
celestial_02 (61k). Most of these are tier-2 levels with pre-filled starter layers, which explains
the faster clears. ice_10, forest_04 and cave_09 have no such reason and need playtest medians.

## Procedural variation

Per-attempt layout variation (symmetry, plus jitter of sparse features) is now opt-in through a
level `"variation"` block. Config: `assets/data/variation/variation_rules.json`. Code:
`src/core/board/level_variation.gd`. Symmetry is an isomorphism, so difficulty is unchanged.
Jitter moves are kept only when the layout still has no full layer at spawn, no fewer clearable
layers than the authored layout, and the lowest clearable layer is no higher.
