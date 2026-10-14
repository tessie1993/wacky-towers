# Campaign progression: the whole arc

> Layer 1 (Play and progression) by the level-design team, 2026-10-14. Later layers add their own sections.
> Companion: `design/levels/plans/minigames.md` (the minigame ids used below).

## Sources and method

- **Biome order:** `assets/data/campaign/catalog.json` `biomes`: meadow, candy, ice, underwater, pirate, lava, forest, cave, clockwork, neon, celestial, carnival. `assets/data/meta/economy.json` uses the same order.
- **Numbers:** taken from the **top-level** `knobs."fall.g0"` and `stars` of every `src/levels/<biome>/<id>/<id>.json` (168 files). These are the post-2026-10-13 values on 8x8 boards. The copy under `metadata.design_spec` holds pre-8x8 values and was ignored.
- **Not used for numbers:** `assets/data/campaign/balance_audit.json`. It is **stale**: it has no pirate or carnival entries, has h-levels only for candy, lava and cave, and records pre-8x8 areas (16 to 49 cells) and star times.
- **Medians:** computed over the 10 main levels (`_01` to `_10`). Survive levels (`s2`/`s3` star metric) and candy_05 (`frosted_tiers` metric) are left out of the time medians. Hard-track medians (h1 to h3) are listed separately. Star times are t2/t3 in seconds; lower is better.
- **Not assessed:** first-attempt star rates, completion medians and perceived fairness. These need a playtest. All levels are still "Authored; awaiting playtest".

## Gates (from `campaign-structure.md` and `economy.json`)

| Gate | Rule | Value |
|---|---|---|
| Level | finishing tier t (any stars) unlocks t+1 | - |
| Next biome | biome's tier-10 finished **and** stars ≥ `biome_star_gate` | 15 of 30 |
| Bonus | biome stars ≥ `bonus_star_gate` | 20 of 30 |
| Hard track h1 to h3 | biome's tier-10 finished | - |
| Shop | `shop_unlock_level` | meadow_03 |
| Tournament minigames MG37+ | the module's first campaign appearance is cleared | not reachable today (no campaign module levels exist) |

Gate observations:
- 15 of 30 means 1.5 stars per level. With survive levels capped at their own metric, a player can clear the gate on 1-star finishes plus a few 2-star finishes. It is gentle, and a good fit for a party-puzzle audience.
- The bonus gate (20 of 30) is the only reason to replay for stars. Hard tracks open on completion alone, so mastery players never meet a star wall.
- **Gap:** minigame blocks have no gate role. The GDD ties tournament unlocks to campaign module debuts, but no level hosts a module yet.

## Biome-by-biome arc

Columns: **Introduces** = the mechanic the biome teaches (rule ids that first appear on its main path, taken from level JSON rules). **Minigame blocks** = the proposed placement from `minigames.md` (A = debut at L03, B = debut at L05, R = recall). **Finale** = tier 10 today. **g0** = median fall speed of the mains, then the min to max range. **t2 / t3** = median star times of the mains in seconds. **Hard** = median g0 and t2 of h1 to h3.

| # | Biome | Introduces (current data) | Minigame blocks (proposed) | Finale today (tier 10) | g0 median (range) | t2 / t3 median s | Hard: g0 / t2 s |
|---|---|---|---|---|---|---|---|
| 1 | Meadow | balloon, wobble, gust, dandelion_puff, mushroom_popup, build_race, fill_shape, sprouts, fog, fog_ghost, sticky_landing, storm_bolt, topsy_tumble, hatching_eggs, mill_belt (about 15) | A `gap_runner`, B `sneak_route` (herd), bonus `wobble_plate` (gentle) | meadow_10 Meadow Mill: clear 3, mill_belt + gust + topsy_tumble. **No boss.** | 0.775 (0.60 to 1.00) | 345 / 250 | 1.00 / 535 |
| 2 | Candy | mono_layer, gumdrop_hail, syrup_band, jelly_piece, tier_frosting, rainbow_piece, colour_pop, pest, speed_bump, earned_specials, goo_spread, licorice_lock, flip, bake_stage, climber_boss (about 15) | A `wobble_plate`, B `catapult_keep`, R `gap_runner`, finale phase `giant_bonk`, bonus `splat_claim` preview | candy_10 Madame Meringue: `bake_oven` + `climber_boss`. **The only real boss on the main path.** | 0.85 (0.65 to 1.05) | 383 / 268 | 1.00 / 350 |
| 3 | Ice | ice_slide, snowball, thin_ice, side_travel (+ mascot_hint) | A `foothold_climb` (avalanche), B `floe_footing`, R `gap_runner` (ice ramps) | ice_10 Sniffles' Sneeze: clear 4, side_travel + gust + ice_slide on a **16x3 board** | 0.85 (0.72 to 1.10) | 435 / 310 | 1.05 / 445 |
| 4 | Underwater | bounce_pad, rising_silt, turntable, conveyor, crab_claw | A `gate_squeeze`, B `giant_bonk`, R `foothold_climb` (silt) | underwater_10 Crab's Pile: clear 3, conveyor + gust + crab_claw | 0.925 (0.60 to 1.15) | 400 / 280 | 1.05 / 535 |
| 5 | Pirate | tilt_plate, race_rival, squirrel_heist (parrot skin), golden_row | A `knockdown_tower`, R `catapult_keep` (broadside), bonus `fuse_rings` preview | pirate_10: clear, gust + crab_claw (the name copies a board title) | 0.975 (0.80 to 1.20) | 435 / 310 | 1.15 / 535 |
| 6 | Lava | ember, lava_rise, quake, lava_rock_spawn | A `paver_rally` (crust road), R `foothold_climb` (rising lava), R `floe_footing` (crust raft) | lava_10 Smolder's Spa: clear 3, rocks + quake + fog | 1.025 (0.85 to 1.25) | 290 / 205 | 1.30 / 430 |
| 7 | Forest | anchored_shelf, woodpecker_knock, vines (squirrel_heist was already used in Pirate) | A `splat_claim` (moss), R `wobble_plate` (treetop), R `sneak_route` | forest_10 Oak's Gap: clear 3, conveyor + gust + mushroom_popup | 1.025 (0.60 to 1.30) | 293 / 210 | 1.25 / 530 |
| 8 | Cave | rock_obstacle, mirror | A `deep_dig`, R `sneak_route` (guard form) | cave_10 Geode's Hollow: clear 3, conveyor + woodpecker_knock + fog | 1.125 (0.60 to 1.35) | 293 / 205 | 1.30 / 535 |
| 9 | Clockwork | piston_punch, stopwatch, key_stamp (`wind_keys`) | A `sorting_belt`, R `gate_squeeze` (shutters), bonus `domino_run` | clockwork_10 Cuckoo's Midnight: clear 3, conveyor + piston_punch + stopwatch | 1.165 (0.60 to 1.40) | 340 / 238 | 1.30 / 540 |
| 10 | Neon | bubble (**only one new rule**) | A `fuse_rings`, R `splat_claim` (paint), R `paver_rally` | neon_10 The Lonely Billboard: clear 4, conveyor + mirror + gust on a 9x9 board | 1.10 (0.90 to 1.30) | 465 / 330 | 1.30 / 550 |
| 11 | Celestial | event_card, lava_lid | A `sky_steps`, R `foothold_climb` (cloud flood) | celestial_10 The Top of the Sky: clear 3, event_card + lava_lid | 1.275 (0.60 to 1.50) | 435 / 308 | 1.45 / 550 |
| 12 | Carnival (Tumble Fair) | remix: echo_drop, chameleon_paint, fever_rush, pressure_cooker, magnet_pull, storm_bolt, mystery_piece, rusty_hinge, confetti_fill | Remix of every module; L10 is a 4-phase Grand Tour (the only one in the game) | carnival_10 Baron Balloon's Big Show: clear, mystery_piece + storm_bolt + fever_rush + golden_row | 1.355 (0.60 to 1.55) | 435 / 310 | 1.55 / 540 |

### Minigame block pattern inside each biome (from `campaign-minigames.md`, applied with minigames.md ids)

| Slot | Composition | Purpose |
|---|---|---|
| 01 to 02 | authored legacy goal | biome rules and pieces |
| 03 | A solo | teach A |
| 04 | A + biome overlay | pressure |
| 05 | B solo (or R, in biomes with one debut) | teach B |
| 06 | B + overlay | pressure |
| 07 | A then B (2 phases) | first chain |
| 08 | R in the biome skin + overlay | recall |
| 09 | B then R + overlay | combine |
| 10 | A then B then `giant_bonk` (or the biome finale) | climax |
| bonus | showcase module solo, relaxed | party breather |
| h1 to h3 | L07, L09 and L10 chains x `hard_mult` 1.25 | mastery |

Every one of the 16 minigames debuts exactly once, and no biome debuts more than 2 (GDD scaffolding rule 12). Ice and Underwater carry two debuts each because they are early and slow (g0 0.85 to 0.93). Late biomes debut one each and lean on recalls.

## Difficulty curve

**g0 (fall speed), median of the mains, in catalog order:**

```
meadow     0.775 |######
candy      0.850 |#######
ice        0.850 |#######
underwater 0.925 |########
pirate     0.975 |########
lava       1.025 |#########
forest     1.025 |#########
cave       1.125 |##########
clockwork  1.165 |##########
neon       1.100 |#########   <- dips below clockwork
celestial  1.275 |###########
carnival   1.355 |############
```

- **Shape.** It rises almost monotonically, with one dip: neon (1.10) sits below clockwork (1.165). Ice ties candy, and forest ties lava. Each biome resets down by 0.15 to 0.35 at L01 and climbs back up, which gives a healthy sawtooth (for example, neon_10 1.30 drops to celestial_01 1.14).
- **Fixed dip at tier 06.** In 9 of 12 biomes, the tier-06 shape level drops g0 to 0.60 (cave does it at 07, and neon_06 is 0.90). The breather is fine, but it is the same breather in the same slot every time.
- **Outliers.** lava_h3 0.80 on a hard track whose siblings run at 1.30. pirate_bonus 1.10 and carnival_bonus 1.30 are much faster than the other bonuses (0.50 to 0.70).
- **Star times do not follow the curve.** The t2 medians are 345, 383, 435, 400, 435, 290, 293, 293, 340, 465, 435 and 435 s. Lava, forest and cave sit 30 percent below ice and underwater, while neon is the highest. Star pressure therefore drops just as speed rises, and then spikes in neon.
- **Star times are long and templated.** Clear levels on 8x8 boards cluster on reused values (580000/410000, 435000/310000, 585000/410000). Hard levels mostly use 535000/375000 or 550000/375000. A 7 to 10 minute 2-star target is long for a portrait mobile puzzle level, and identical numbers across biomes show they were scaled, not tuned. **No stated range exists** for level duration, so this is not judged against a target. It is flagged for a decision.
- **Height and shape levels were not rescaled.** For example, meadow_05 (height 10, board 5x5 → 8x8, coverage 0.6) kept t2 240 s while its layers now need 2.56x as many cells. Every `_05` race level and every `_06` / bonus shape level has the same mismatch. These are the most likely star-wall spikes in the game.
- **Hard track.** The hard g0 medians (1.00 to 1.55) sit at or just above each biome's L10, which is right for an optional track. Its t2 times (about 535 s) are longer than the mains', so hard levels are slower but not stricter.

## Boss and set-piece beats

| Biome | Today | Proposed beat |
|---|---|---|
| Meadow | no boss; a mill finale | gap_runner → sneak_route herd finale: the picnic is saved. A soft beat, no boss in biome 1. |
| Candy | Madame Meringue (bake_oven + climber_boss); rematch at candy_h3 (bonk_boss) | keep it, and rebuild it as wobble_plate → catapult_keep → giant_bonk |
| Ice | Sniffles' Sneeze (side-travel clear) | climb → floe → Sniffles sneezes the gust overlay. Re-author on 8x8. |
| Underwater | Crab's Pile (crab_claw) | gate_squeeze → foothold_climb → giant_bonk (the crab, as the first full boss fight) |
| Pirate | clear level named after a board | knockdown_tower → catapult_keep → giant_bonk (layer 2 names the pirate boss) |
| Lava | Smolder's Spa (rocks, quake) | paver_rally → foothold_climb (rising lava) → giant_bonk (Smolder) |
| Forest | Oak's Gap (conveyor) | splat_claim → wobble_plate treetop → giant_bonk (Oak) |
| Cave | Geode's Hollow (conveyor) | deep_dig → sneak_route guard → giant_bonk (Geode) |
| Clockwork | Cuckoo's Midnight (conveyor) | sorting_belt → gate_squeeze → giant_bonk (the cuckoo) |
| Neon | The Lonely Billboard (conveyor) | fuse_rings → splat_claim → paver_rally: a no-boss "show" finale for contrast |
| Celestial | The Top of the Sky (event_card) | sky_steps → foothold_climb → giant_bonk (storm cloud). The story climax. |
| Carnival | Baron Balloon's Big Show | the Grand Tour: 4 phases drawn from earlier modules, then Baron Balloon |

Mid-biome set pieces: every L07 becomes the biome's first two-phase chain. It is the "the level changes under you" moment the GDD's Player Fantasy promises, and no level does this today.

## Gaps and repetition across the whole game

1. **Minigames are absent from the campaign.** No level uses `modules`. The game's best-differentiated content (the boards 09 to 12) does not appear on the critical path at all.
2. **Finales are not climaxes.** 11 of 12 tier-10 levels are plain `clear_n` with three stacked rules. Only candy_10 has a boss. **Conveyor appears in 5 finales** (underwater, forest, cave, clockwork, neon) and gust in 5.
3. **The same biome template repeats 12 times.** 05 is always a `height` race (12 of 12), 06 is a `shape` breather at g0 0.60 (10 of 12), 08 is `survive` (7 of 12), and the bonus is `shape` (9 of 12).
4. **Goal monotony.** 88 of 120 main levels (73 percent) are `clear_n`. On the hard track, 32 of 36 are `clear_n`.
5. **Front-loaded teaching.** Meadow and Candy introduce about 30 rules between them. Lava to celestial introduce 2 to 4 each, and neon introduces 1. This is the reverse of a good scaffold. Late biomes feel like remixes, and early biomes overload new players.
6. **Rules debut in someone else's biome.** squirrel_heist debuts in Pirate (pirate_07), before Forest's own squirrel level (forest_04). storm_bolt is used in Meadow before its story home.
7. **Board-rule violation.** ice_10 is 16x3 (the 8x8 rule). Physics and tournament boards need a scoped exemption decision.
8. **Naming.** Board titles are used as level names (pirate_03, 09, 10, h1, h2) and as the module title (bridge_dash). See minigames.md "Naming fixes".
9. **Stale records.** `balance_audit.json` (pre-8x8, missing 2 biomes). `campaign-structure.md` says the Pirate h1 to h3 levels are "not authored yet", but they exist.
10. **Tournament pool unlocks are dead.** MG37+ unlock on campaign debuts that do not exist, and the templates are not in `templates.json`.

## Top 10 progression fixes (ranked)

1. **Build the module phase runner and ship `gap_runner` end to end in meadow_03.** The data and pure code already exist. Write the missing `design/gdd/modules-framework.md`, add `span` and `modules` to `goals.json`, add unit tests for `span_reach` and `span_walker`, and capture the screenshot evidence. Every other fix here depends on this.
2. **Turn tier-10 levels into real finales.** Use the A → B → `giant_bonk` chain (or the biome finale listed above), give each a boss with HP and a telegraph, and remove conveyor from at least 4 of the 5 finales it is in.
3. **Re-time the stars from the formula, not by scaling.** Use GDD F8 (`t2 = T_med`, `t3 = T_med / 1.35`) with per-phase medians, and agree a target level length with the user (proposal: t2 of 120 to 240 s for mains). Fix the unscaled `_05` height and `_06` shape levels first.
4. **Rebalance the teaching curve.** Cap each biome at 2 new rules plus 2 new minigames. Move about 10 of meadow's and candy's rules into later biomes (for example storm_bolt to celestial, conveyor to clockwork, mirror to neon) so that neon and celestial each teach something new.
5. **Break the fixed 05/06/08 template.** Rotate the slots of the race, shape and survive levels per biome, and replace generic `survive` with `floe_footing` or `foothold_climb` phases.
6. **Place one two-phase chain at L07 in every biome**, so the "level changes under you" beat lands mid-biome.
7. **Smooth the curve.** Raise the neon median above clockwork (neon_01 to 05 up by 0.05 to 0.10, or swap neon_06 down to 0.60 for consistency). Set lava_h3 g0 0.80 → 1.25. Bring pirate_bonus and carnival_bonus g0 down to the bonus band (0.60 to 0.80).
8. **Fix the board-rule violations.** Re-author ice_10 at 16x8 or bigger (side view), and get a user decision on whether tournament-only and physics boards are exempt.
9. **Rename the board-titled content** (pirate_03, 09, 10, h1, h2 and the bridge_dash title) and give the Pirate finale its own boss via layer 2.
10. **Regenerate `balance_audit.json`** from the top-level level JSON (all 12 biomes, all 168 levels), and add the MG37 to MG52 tournament templates for the 16 minigames, so that the tournament unlock-on-debut rule can work.

## World and story arc (layer 2: pending)

_(layer 2: pending)_

## Godot review (layer 4: pending)

_(layer 4: pending)_
