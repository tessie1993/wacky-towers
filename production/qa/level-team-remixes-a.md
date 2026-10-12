# Hard-track remixes, batch A (meadow, ice, underwater, forest)

Source: Campaign Structure rule 17. Specs are in the "Hard-track remixes (tiers 12–14)" section of each `design/levels/<biome>.md`. Level JSON: `src/levels/<biome>/<id>/<id>.json`. Status: authored, awaiting playtest. All goals are `clear_n`. Coins and gold are score only. Stars are in ms in the JSON (seconds below).

Each level uses exactly one wave-3 rule, marked in **bold**. Those rule JSONs do not exist in `assets/data/rules/` yet, so these 12 levels will not validate until wave-3 lands.

| id | Display name (EN) | Tier | Rules | Goal | Stars t2 / t3 (s) |
|---|---|---|---|---|---|
| meadow_h1 | Seed Sprouts | 12 | sprouts, gust, **star_coins** | clear_n 5 | 375 / 265 |
| meadow_h2 | Petal Party | 13 | mushroom_popup, topsy_tumble, **confetti_fill** | clear_n 4 | 300 / 210 |
| meadow_h3 | Lucky Dip | 14 | fog, fog_ghost, **mystery_piece** | clear_n 4 | 180 / 125 |
| ice_h1 | Snowball Fight | 12 | snowball, gust, **rusty_hinge** | clear_n 5 | 375 / 265 |
| ice_h2 | Blind Curling | 13 | fog, **storm_bolt** (+ curling_flick verb knob) | clear_n 4 | 265 / 190 |
| ice_h3 | Floe Breakup | 14 | thin_ice, ice_slide, **crumble_tiles** | clear_n 4 | 250 / 175 |
| underwater_h1 | Sinking Sand | 12 | bounce_pad, gust, **quicksand** | clear_n 4 | 300 / 210 |
| underwater_h2 | Riptide Whirl | 13 | turntable, **magnet_pull** | clear_n 3 | 225 / 160 |
| underwater_h3 | Crab's Rematch | 14 | crab_claw, fog, **golden_row** | clear_n 4 | 300 / 210 |
| forest_h1 | Firefly Night | 12 | fog, gust, **anvil_drop** | clear_n 5 | 375 / 265 |
| forest_h2 | Drum Solo | 13 | woodpecker_knock, vines, **echo_drop** | clear_n 5 | 260 / 185 |
| forest_h3 | Squirrel Shuffle | 14 | conveyor, squirrel_heist, **jumbled_queue** | clear_n 4 | 290 / 205 |

Name keys follow `LVL_<BIOME>_H<N>_TITLE` / `LVL_<BIOME>_H<N>_PREMISE`. Music ids are `<biome>_h<N>`, which fall back to the biome default until the tracks arrive.
