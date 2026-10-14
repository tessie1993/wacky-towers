# Plan review r6: phase 1 campaign vision, exemplars and scene vocabulary (strict, pass mark 9.7 on every criterion)

Reviewed after commit 48b8ef3: `design/levels/plans/campaign-vision.md`, `design/levels/plans/exemplars.md`,
`design/levels/plans/scene-vocabulary.md`, and the new input `design/levels/plans/reference-study-defence.md`
(feeds the one defence line in section 7.6). The catalog reorder and the early story file are producer items, accepted and out of scope.

## Scores

| # | Criterion | r4 | r5 | r6 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.6 | 9.7 | 9.7 | YES |
| V2 | Pillars: distinct, each with an appliable test | 9.4 | 9.6 | 9.6 | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.4 | 9.7 | 9.7 | YES |
| V4 | "Every level unique" rules | 9.2 | 9.3 | 9.5 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.3 | 9.5 | 9.5 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.1 | 9.4 | 9.6 | NO |
| V7 | Consistency with user decisions and constraints | 9.4 | 9.6 | 9.6 | NO |
| Ex | Exemplars as calibration (supplementary) | 8.9 | 9.3 | **9.5** | NO |

## Verdict: FAIL

V1 and V3 pass. The five that remain are within 0.1-0.2, and every r5 structural defect is closed. What is left is the new defence line
(it is not wired into the rule system), a small group of undefined terms, and a few stale or missing exemplar rows. All are short text fixes.

## r5 fixes: did they land?

| r5 item | Landed? | Note |
|---|---|---|
| D1 global ids vs biome-skinned builds | YES | U17, 7.5 and the vocabulary agree: 20-30 ids, 7-8 per biome, 84-96 builds. Pair rule now meaningful |
| D2 corridor: real rationale, definitions, script columns, `ex_forest_05` rebuilt | MOSTLY | Rationale correct (flat spawn needs 4; 3-cell piece cannot rotate in a 2-wide shaft); `min_spawn_width`/`min_dead_end_width` are `level_table` columns; pillars are 4-wide. "Spawn columns" is undefined (E1) |
| D3 exclusions and renames | YES | `ex_near_*`, `ex_weak_*` excluded; near-miss uses seeded generic ids (`summit_ledge`, `lantern_sway`) |
| D4 idea vs rule; `tilt_plate` on the pill | YES | Defined in 7.6; boss adds no rule |
| D5 Gust meter, `hud_meter` under `scene`, P2b exemption for level 01 | YES | Exemption is in P2b text and in `ex_meadow_01` |

Verified correct this round: `ex_forest_05` canonical string (`8x14`: 4 solid rows, 6 gap rows, 4 solid rows, the transpose of the 14x8 mask);
`ex_pirate_10` leg is 4 wide (dead-end minimum 3 satisfied, spawn width 8); the L deck is its own canonical form; headlines are 6-8 words;
the `level_table_row` is in schema order; the near-miss mean is 9.04.

## Defects (ranked)

**E1 (V4) "Spawn columns" is undefined, so `min_spawn_width` cannot be computed.** U7 says the spawn region is "the floor cells of the top 3 mask rows
across the spawn columns". Nothing says which columns spawn. In `ex_forest_05` the centre columns are void in the top rows, so the answer decides
whether the level passes. Fix wording (U7): "Pieces spawn in the **centre 4 columns of the mask's bounding width** unless the spec sets `spawn_cols`. A level whose
spawn columns contain void in the top 3 rows must set `spawn_cols` to a floor run that is at least 4 wide, and the script reports that run as
`min_spawn_width`." Add `spawn_cols` to the 8.2 required-fields list (default allowed).

**E2 (V5, V4) The defence line is not wired into the rules.** Section 7.6 now says defence (D1-D4) is "one flavour among many: at most 2 full defence
levels per biome". The line is not testable or complete:
- **No column or script check.** Add a `flavour` column to `level_table` (`D1`..`D4` or `none`) and add to U7: "at most 2 levels per biome have `flavour` D1-D4 as their
  main play; the script counts them."
- **The study proposes "at least 1, no more than 2".** (`reference-study-defence.md` section 6 question 2.) The vision keeps only the maximum. Decide and state it: either
  "1-2 per biome" or "0-2 per biome" with a one-line reason. The choice affects 12 levels.
- **No mapping from D1-D4 to the goal and rule vocabulary.** 7.3 allows `height`, `shape`, `survive`, `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven`
  and minigame goals. D2 ("seal M breaches") and D4 ("shelter the guest") have no goal id, and D1, D2, D3 depend on `defend_core`, the new rule `breach_plug`, a row-clear
  cannon trigger and a `GoalSequence`. Add to 7.3: "Defence mapping: D1 = `survive`, D2 = a new goal `seal_breaches`, D3 = `bonk_boss`, D4 = `rescue_all` in a goal sequence; the
  new rules `breach_plug` and the row-clear cannon count toward U10 (at most 2 new rules per biome) and need handbook entries."
- **Fair telegraphs.** The study sets a standard (an actor telegraph at least 2 s ahead of every strike, 4 s in intensity 1-2 biomes), but the vision's P3 has no telegraph rule
  and U16 only says "telegraphed". Add to P3 as a spec-time test: "*P3e strike telegraph (spec-time):* every strike lane is warned by an actor at least 2 s ahead (4 s in biomes of
  intensity 1-2)."

**E3 (V7) The study's idea names would break the title ban.** The vision names the study as the source of the defence family, and the study's ideas carry names like
"Goblin Gate" (a paraphrase of the board title "Goblins' Ambush / Defend the Fort") and cites the boards "Kraken Blockade", "Fort Blast" and "Molten Guardian". Add to 7.6:
"The names in `reference-study-defence.md` are working titles for ideas, not level names; every real name passes the title script and the paraphrase check (N5, L1)."

**E4 (V6) Two 9.7 exemplars named in the checks have no data.** The exemplar file lists `ex_forest_02` and `ex_pirate_03` among the 9.7 exemplars included in the U3, U14 and U17
checks, but neither has a spec or a `level_table` row (they are mentioned only as abridged references). The script cannot check what is not there. Fix: add a one-row
`level_table` entry for each ("ex_forest_02 | height | vines | 8x8:... plain | terrain | set_piece | action | pose | tod | weather | camera | opening_event | plain | headline | teach | none")
or remove them from the list and say "these are references, not exemplar levels".

**E5 (V6, nit) Stale and conflicting text in `scene-vocabulary.md`.**
- The last section still says "For example `sways` (from the near-miss exemplar) is not on the list". The near-miss no longer uses it. Replace with "For example `sways` is not on the list".
- The header says "Add `summit_ledge`-style generic ids freely", which contradicts "phase 4 groups add ids only by change request". Replace "freely" with "by change request".

**E6 (V7, nit) Revision labels lag.** The vision header says "revision 4" and "revised after the r1-r3 reviews"; the exemplars header says "revision 3". After the r5 changes these should be revision 5 / revision 4 and mention r1-r5.

**E7 (V2, nit) The cosmetic/rule line vs the defence family.** D1/D3 attackers strike lanes and knock blocks off, which makes the attacker's set-piece action a **rule** (it removes blocks). The seeds list only `cannon_volley` as a rule action. Add rule-kind seeds for the defence family (`tentacle_grab`, `rock_throw`, `catapult_volley`) so a spec cannot mark them cosmetic.

## Exemplars: calibration score 9.5 / 10

Good: the anchor set is now complete for the panel's real decisions (9.7 beat/spec, near-miss with a mean of 9.04, three weak samples, boss, hard remix, level 01, N/M/A/C/S anchors),
every 9.7 exemplar obeys the rules (headline length, teach-alone, corridor, canonical masks, table order), and the near-miss's defect is now "generic", not "unlisted".
Remaining: two named exemplars without data (E4), the stale vocabulary example (E5), and no exemplar that shows a defence level (the new flavour) with its telegraph and meter.
Add a one-line abridged defence exemplar (D3, with the telegraph, the meter and the boss named in the headline) so the panel has an anchor for E2.

## Ordered fix list

1. E2: wire the defence line into the rules (`flavour` column and U7 clause; decide 0/1-2 per biome; map D1-D4 to goal ids; P3e telegraph).
2. E1: define spawn columns (`spawn_cols`, default centre 4).
3. E4: give `ex_forest_02` and `ex_pirate_03` rows, or drop them from the checks; add a defence exemplar.
4. E3: the study's names are working titles only.
5. E5, E6, E7: fix the vocabulary text, update revision labels, add rule-kind defence actions.

After 1-4 I expect V2, V4, V5, V6 and V7 to reach 9.7. Re-run as r7.
