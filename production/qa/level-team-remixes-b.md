# Level team B: Neon bonus + Clockwork / Neon / Celestial hard-track remixes

Authored 2026-10-10 (level-designer). Status: Authored; awaiting playtest. Source sections: `design/levels/clockwork.md`, `neon.md`, `celestial.md` ("Bonus level (tier 11)", "Hard-track remixes (tiers 12–14)"). Wave-3 rules per `design/gdd/mechanics-wave3.md`. Catalog and .tscn not touched (coordinator generates them).

Stars: `t2 = round5(0.80 × t_est)`, `t3 = round5(0.55 × t_est)`, `t_est = N × A × 2.667 s`; `clockwork_h3` hand-set from `clockwork_08`.

| id | Display name (EN) | Tier | Rules (wave-3 in bold) | Goal | ★★ / ★★★ (ms) |
|---|---|---|---|---|---|
| neon_bonus | Glow Party | 11 | mirror, **fever_rush**, **golden_row** | clear_n 5 (5×5, H10) | 265000 / 185000 |
| clockwork_h1 | Magnet Tram | 12 | conveyor, **magnet_pull** | clear_n 5 (8×4, H10) | 340000 / 235000 |
| clockwork_h2 | Boiler Bench | 13 | turntable, **pressure_cooker** | clear_n 4 (6×6, H10) | 305000 / 210000 |
| clockwork_h3 | Magnet Keys | 14 | key_stamp, piston_punch, **magnet_pull** | wind_keys 5 (5×5, H10) | 240000 / 170000 |
| neon_h1 | Fever Hour | 12 | stopwatch, **fever_rush** | clear_n 6 (5×5, H10) | 320000 / 220000 |
| neon_h2 | Spotlight Surge | 13 | turntable, gust, **golden_row** | clear_n 5 (6×6, H12) | 385000 / 265000 |
| neon_h3 | Colour Shift | 14 | mono_layer, mirror, **chameleon_paint** | clear_n 5 (6×6, H10) | 385000 / 265000 |
| celestial_h1 | Meteor Storm | 12 | gust, **storm_bolt** | clear_n 5 (6×6, H10) | 385000 / 265000 |
| celestial_h2 | Wishing Eclipse | 13 | fog, **mystery_piece** | clear_n 4 (6×6, H10) | 305000 / 210000 |
| celestial_h3 | Constellation Shuffle | 14 | turntable, **jumbled_queue** | clear_n 5 (6×6, H10) | 385000 / 265000 |

## Notes for the validator / playtest

- Wave-3 rule defs (`assets/data/rules/<id>.json`) do not exist yet; the 10 levels will not load until the plugins land (acceptance criterion 4 of the wave-3 GDD).
- Name keys needed: `LVL_<BIOME>_BONUS_TITLE` / `_PREMISE` (neon) and `LVL_<BIOME>_H1..H3_TITLE` / `_PREMISE`.
- New story icons (may need art): magnet, boiler, key, disco_ball, traffic_light, spotlight, paint, meteor, wishing_star, constellation.
- Clockwork and Celestial already had pre-wave-3 H1–H3 drafts in their §7; the new sections supersede them (noted in each file and in each JSON's `design_amendments`).
- `neon_h3` uses `mono_layer` as a Candy callback; `celestial_h3` needs `spawn.preview_count` 3 for the shuffle to read.
