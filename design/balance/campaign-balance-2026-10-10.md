# Campaign balance and variety — 2026-10-10

**Verdict: CONCERNS; human difficulty is NOT ASSESSED — NO PLAYER DATA.** The implemented campaign contains 100 mains and 18 extras. Every level has a distinct structural configuration after the documented amendments. All 118 scenes pass the ordered engine integration checks, and all 15 finite packing puzzles have actual winning witnesses. This establishes a usable playtest build, not measured completion rates or tuned star times.

## Inputs and targets

| Input | Status | Evidence supplied |
|---|---|---|
| `design/registry/entities.yaml` | FOUND | Named campaign speed and progression targets |
| Board, piece-set, scoring, campaign, fall/drop/lock GDDs | FOUND | Axis geometry, source override policy, star evaluation, lock timing |
| Ten biome design documents and approved Meadow production JSON | FOUND | Per-level intention and teach/practice/remix ordering |
| `assets/data/campaign/catalog.json`, 118 official JSONs, rule/knob/shape data | FOUND | Actual geometry, controls, objectives, supply and atom combinations |
| `assets/data/campaign/balance_audit.json` | FOUND | Reproducible structural comparisons and surviving time-star errors |
| `assets/data/campaign/puzzle_proofs.json` | FOUND | Exact oriented pieces, inventory, gravity ingress, colours, mirrors and turn cadence |
| `production/qa/evidence/full-build/biome-level-verification.json` | FOUND | Ordered actual engine scenes, hooks, legal spawns, locks, control actions and finite puzzle wins |
| Candy real-board tests, meta tests, independent difficulty review | FOUND | State transitions, persistence and an independent design challenge |
| Human first-attempt stars, completion medians, input timings, failure explanations | ABSENT | NOT ASSESSED — NO PLAYER DATA |
| Per-level reference-phone readability/performance measurements | ABSENT | NOT ASSESSED — NO DATA |

The balance-check skill's evidence rule, the level-designer agent, studio-level-design-lead and gamedev-level-design pacing reference were applied. Required player evidence is absent, so it is not estimated from simulation fixture times.

Campaign F2 is `g0 = 0.6 + 0.045(tier − 1) + 0.06(biome − 1)` for tiers1–10, with output0.6–1.545. The registry's older0.04 increment/range was brought into agreement with the later approved GDD retune. Explicit source speeds remain intentional overrides, especially packing breaks. The next biome requires the previous finale and15 main-path earned stars; spending never lowers that gate. The first-time Meadow target in the GDD remains unmeasured.

## Distinct configuration and pacing

`python tools/content/audit_campaign_balance.py` ignores name, music, seed, skin and metadata in comparisons. Its strict configuration includes boards, pieces, goals, knobs and rules. Its structural comparison excludes speed and star values entirely, so merely changing a timer does not establish variety. All118 strict and structural configurations are distinct. The independent review's88 reduced rule/goal/control families intentionally use a weaker comparison: learned ideas recur with new geometry and constraints.

| Biome | Main goals | Footprint/height variants | Distinct atoms | Source g0 range | Learning and release |
|---|---|---:|---:|---|---|
| Meadow | Clear, tower, picture, survive | 8 | 14 | 0.60–1.00 | Move/rotation first, helper practice, tower/picture release, then wind/fog/flip/mill remix |
| Candy | Clear, frosted tower, colour picture, survive, bake/boss | 8 | 20 | 0.65–1.05 | Flavour matching develops into jelly, syrup, frosting and the oven's second stage |
| Ice | Clear, tower, picture, survive | 8 | 11 | 0.72–1.10 | Slide before selectable flick, snow and thin ice; finale uses a sideways lane |
| Underwater | Clear, tower, kit picture, survive | 9 | 14 | 0.60–1.15 | Pockets/helpers precede drift and bounce; kit selection supplies a planning break |
| Lava | Clear, tower, picture, survive | 8 | 10 | 0.85–1.25 | Ember/rise precede conveyor, rock and quake combinations |
| Forest | Clear, tower, picture | 8 | 10 | 0.60–1.30 | Shelf and squirrel practice; fixed packing release; vine/woodpecker counter pair |
| Cave | Clear, tower, mirrored picture | 7 | 9 | 0.60–1.35 | Rock shapes the routes; mirror and lantern visibility add planning constraints |
| Clockwork | Clear, tower, picture, wind keys | 7 | 8 | 0.60–1.40 | Turn/conveyor/pistons precede stopped time, chosen motion and the key finale |
| Neon | Clear, tower, sign picture, survive | 8 | 8 | 0.90–1.30 | Proposed slower callback biome with an eight-piece stepped sign and timed sprint |
| Celestial | Clear, balloon tower, picture | 7 | 11 | 0.60–1.50 | Familiar helpers lead to chosen gravity and the final event deck/lid |

The main chain is ten levels per biome. Bonus and hard tracks are optional; required teaching cannot depend on them. The sequence uses teach → practice → twist → test with tower and picture releases instead of a monotonic speed increase. Configuration counts do not prove that every level feels different to a player.

## Changes made from evidence

| Level | Before | Implemented change | Preserved intention |
|---|---|---|---|
| Clockwork05 | Same4×4 height10, pool and rules as Forest05 |4×5, targetheight8 | No-fail tower release; nominal coverage work remains96 cells |
| Neon06 | Proposed repeat of a24-cell Forest picture |40-cell stepped sign, eight fixed pieces | New Neon proposal; exact constructive packing wins |
| Neon08 | Survive150s with170s third-star timer, automatic clean3stars | Clear-count stars `s2=1,s3=2` | ScoringF4 survival performance rather than elapsed duration |
| Ice10 | Fresh engine:12×16×6 physical board, danger8,96-cell planes |16×10×3 physical board, danger12,30-cell planes | Authored12-cell travel,30-cell clear work, standard pool, four clears and staged slide |

Before/after definitions and source retention are recorded in `campaign-geometry-amendments-2026-10-10.md` and `assets/data/campaign/design_amendments.json`. No finite puzzle budget needed inflation: accounting for real BigCube volume, mirror duplication and selectable kit inventory resolved the apparent contradictions.

## Remaining concerns and playtest work

Candy09 introduces goo, licorice and a gravity flip together; Forest08 first pairs vines and woodpecker; Celestial10 first combines the event deck and lid schedule. Their behavior is implemented, but the initial warnings need player comprehension checks. The revised Ice10 dimensions and preserved190/270-second star thresholds require an unassisted sideways playthrough. A geometry/goal fixture cannot certify those human star times.

For the first playtest, record completion, warnings, first-attempt stars, decision time and the player's explanation of each first new cause. Check the main-chain15-star gate at the Meadow finale; test no-perk star times before optional edges. Preserve planning releases unless observed pacing, rather than the default speed formula alone, shows a problem. No observed medians or empirical success rates are currently available.

## Reproduction

1. `python tools/author_campaign.py`
2. `python tools/refresh_rule_catalog.py`
3. `python tools/content/solve_campaign_puzzles.py`
4. `python tools/content/audit_campaign_balance.py`
5. Run `tools/qa/verify_campaign_biomes.gd` on the pinned Godot4.7.2 build after editor class registration; it writes the ordered per-level evidence.

The solver fixture establishes a legal sky pose, then runs actual hard-drop, lock, clear, mirror/turntable, kit consumption and goal evaluation. Its measured simulation time excludes a human's rotation, camera and planning decisions. The full-build report explicitly marks non-finite objectives `FULL_PLAYTHROUGH_NOT_ASSESSED`.
