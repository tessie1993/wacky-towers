# Plan review r7: phase 1 campaign vision (revision 5), exemplars (revision 4), scene vocabulary (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md`, `design/levels/plans/exemplars.md`, `design/levels/plans/scene-vocabulary.md`,
checked against `reference-study-defence.md` and the r1-r6 reports. As instructed, an exemplar with no `flavour` field is read as `none`.

## Scores

| # | Criterion | r5 | r6 | r7 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.7 | 9.7 | 9.7 | YES |
| V2 | Pillars: distinct, each with an appliable test | 9.6 | 9.6 | 9.6 | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.7 | 9.7 | 9.7 | YES |
| V4 | "Every level unique" rules | 9.3 | 9.5 | 9.6 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.5 | 9.5 | 9.5 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.4 | 9.6 | 9.6 | NO |
| V7 | Consistency with user decisions and constraints | 9.6 | 9.6 | 9.7 | YES |
| Ex | Exemplars as calibration (supplementary) | 9.3 | 9.5 | **9.6** | NO |

## Verdict: FAIL

Three criteria pass (V1, V3, V7). V2, V4, V5 and V6 are each 0.1-0.2 short. All r6 fixes landed, but the defence family, now mandatory in every biome, collides with
the new-rule budget, and P3e is scoped too narrowly. Both are rule-system gaps (not wording), so they must be settled before phase 2 starts.

## r6 fixes: did they land?

| r6 item | Landed? | Note |
|---|---|---|
| E1 spawn columns (`spawn_cols`, default centre 4) | YES | In U7 and 8.2. `ex_forest_05` sets `spawn_cols: 0-3`; the centre columns (5-8) are void, so the left 4-wide pillar is the spawn run: consistent |
| E2 defence: `flavour` column, 1-2 per biome, D1-D4 goal map, P3e | MOSTLY | In 7.3, 7.6, the column list and 8.2. The U7 text itself has no count clause (F4); budget collision (F1); P3e scope (F2) |
| E3 title-ban line for the study's names | YES | 7.6 |
| E4 rows for `ex_forest_02`, `ex_pirate_03`; defence exemplar | PARTLY | Two rows added (19 columns each, correct). `ex_underwater_09` added. But four of the seven exemplars named in the checks still have no row (F5) |
| E5 vocabulary text | YES | "By change request"; `sways` reference is now just an example |
| E6 revision labels | YES | |
| E7 rule-kind defence actions | YES | `tentacle_grab`, `rock_throw`, `catapult_volley` seeded as `rule` |

### Hand check of `ex_underwater_09` canonical mask

Canonical string given: `8x10:######../#######./########/########/########/########/########/########/#######./######..`
- The raw mask is 10 wide x 8 high, bottom corners notched; the 10 columns, read top to bottom, give 10 rows of 8 characters: column 0 = `######..`
  (floor in rows 0-5, void in rows 6-7), column 1 = `#######.`, columns 2-7 = `########`, column 8 = `#######.`, column 9 = `######..`.
  The string has exactly these 10 rows (1 + 1 + 6 + 1 + 1). It is symmetric, so reversing the row order gives the same string.
- Orientation choice: the width-8 candidates are the transpose and its vertical/horizontal flips. The transposed row text `######..` sorts before the flipped `..######` (because `#` < `.`), and the 10-wide
  untransposed forms lose on width. So the given string is the canonical one: **correct**.
- Implied notch: 2 cells deep in the outer columns (rows 6-7), 1 deep in the next (row 7). The spec only says "10x8, bottom corners notched", so the prose is under-specified (F6).
- `min_spawn_width 10` is right (top rows are full); no dead-end channel; headline is 7 words with a story noun and no numeral; the telegraph (3 s) exceeds the 2 s minimum for an intensity-3 biome.

Other checks that pass: `ex_forest_05` canonical `8x14` (4 solid, 6 gap, 4 solid rows) and both `level_table` rows have 19 columns in schema order.

## Defects (ranked)

**F1 (V5, V4) Defence in every biome collides with the new-rule budget.** Every biome must now have 1-2 defence levels (7.6), and an attacker's block-removing action is a **rule**,
never cosmetic (7.6, vocabulary: `cannon_volley`, `tentacle_grab`, `rock_throw`, `catapult_volley`). D2 adds the new rule `breach_plug`; D3 adds the row-clear cannon (7.3).
U10 allows **at most 2 new rules per biome** and 7.1 wants "one mechanic family per biome from its chapter's problem". So in each of 12 biomes the defence plumbing consumes one
or both of the two new rules, and the biome's own family has little left. `ex_underwater_09` shows it: both of Underwater's two new rules (`tentacle_grab`, `row_cannon`) are defence rules.
Unresolved, the campaign trends to "12 biomes with one attacker rule each", against "every level different in play". Fix (choose one and write it into U10 and 7.3):
> **Option A (recommended):** one shared parameterised rule `strike` (attacker variant = tentacle, rock, catapult, cannon, comet) and one shared rule `row_cannon`. Each is taught once, in the
> first biome that uses it, and is reused with a new attacker and scene elsewhere. Defence levels in later biomes add no new rule; `breach_plug` is the one extra defence rule. The set-piece
> action ids stay distinct (scene variety), but they are variants of `strike`, not new rules. Defence rules count at most 1 of a biome's 2 new rules.
> **Option B:** raise U10 to "2 new rules per biome plus the defence rule" and say so.
Then change the exemplar to match (`main_rule: strike [tentacle]`, extras `row_cannon`).

**F2 (V2, V4) P3e is scoped to "defence levels", but the fairness risk is any strike.** Section 2 lists "P3e (defence levels)" in the spec-time set. But `cannon_volley` (a rule action) is used
by `ex_pirate_03` (flavour none) and `ex_pirate_10` (a boss), and neither shows a telegraph. The test, as the P3e text itself says, covers "every strike lane". Fix: in section 2 change
"P3e (defence levels)" to "P3e (every level whose `set_piece_action` is a rule that removes or moves blocks)". Add a `telegraph:` line to `ex_pirate_03` and `ex_pirate_10` (for example
"the gull gun's arm cranks back 4 s before every shot (intensity-1-2 rule not needed: Pirate is intensity 4, so at least 2 s)"), and add a `telegraph` field to 8.2.

**F3 (V6) Two exemplars carry a flavour/headline mismatch.**
- `ex_pirate_03` has `flavour: none` and `goal_type: [height]` but the headline is "Wall the dock from the gull gun", which is a D1 (hold the wall) headline, and D1 maps to `survive`.
  Either rename the level "Raise the dock above the gull gun" with `height`, or mark it `flavour: D1` with `survive`. (Pirate needs at least one defence level anyway.)
- `ex_pirate_10` (cleared rows load the cannon, a wall blocks volleys, `bonk_boss`) is a D3 by the vision's own definition; `ex_forest_h1` (a hidden kid goat sheltered, `rescue_all`)
  reads as D4. Read as `none` per your instruction, they would mis-teach the panel. Mark them D3 and D4 (and then P3e applies to both; see F2).

**F4 (V4) The defence count is not in the rules section.** The 1-2 per biome rule exists only in 7.6 (a brief). The script spec in section 5 and U7 do not state it. Add to U7:
"**Defence flavour:** each biome has 1 or 2 levels with `flavour` D1-D4 (the script counts them)."

**F5 (V6) Four 9.7 exemplars have no `level_table` row.** The exemplar header says the seven 9.7 exemplars (`ex_forest_02`, `ex_forest_05`, `ex_forest_h1`, `ex_pirate_03`, `ex_pirate_10`, `ex_meadow_01`,
`ex_underwater_09`) are in the U3, U14 and U17 checks, and the vision says the same. Rows exist for three (`ex_forest_05`, `ex_forest_02`, `ex_pirate_03`). `ex_forest_h1`, `ex_pirate_10`, `ex_meadow_01`
and `ex_underwater_09` have none, and several rows' fields (set piece, time of day, weather, camera, opening event) are only "in the real spec". The script cannot check them. (I flagged only the first two in
r6; the same applies to these four.) Fix: add a row for each, for example
`ex_meadow_01 | height | lookout | 8x8:... | hilltop_ledge | windmill | sails_turn | point,cheer | dawn | clear | default | sheep_bleat | plain | Raise the lookout so Ada spots sheep | teach | none | none | 8 | n/a`,
and the equivalents for the other three, filling the fields their abridged blocks already imply.

**F6 (V6) `ex_underwater_09` details.**
- Give the mask as ASCII (10 rows of 8 shown above) so a reader can verify the canonical string; the prose "bottom corners notched" is ambiguous (how deep?).
- It is a **tier-9 combine level that fights the named boss and ends with the boss calming**. That reads as the Underwater finale. Either say "this is a rehearsal against Squidge; the tier-10 boss is
  its parent, Mother Squidge" or move it to a mini-boss role. Otherwise the panel learns that the boss can be resolved a level early (U9).
- Its `canonical_mask` and `min_spawn_width` are correct (checked above).

**F7 (V4, nit) Spawn default for odd widths.** "The centre 4 columns of the mask's bounding width" is exact for even widths; for odd widths (9, 11, 13) the centre 4 is asymmetric. Add:
"For odd widths, take the 4 columns starting one left of centre."

## Exemplars: calibration score 9.6 / 10

Strong: the anchors cover every role (teach, twist, boss, hard, level 01, defence), the near-miss mean is 9.04, the weak samples are excluded from the checks and renamed, the corridor and mask data are now
correct, and the defence exemplar shows the telegraph, the meter, the named boss and the reveal. Remaining: four rows missing (F5), two flavour/headline mismatches (F3), the tier-9 boss positioning and the
under-specified mask (F6), and the budget collision the exemplar itself exposes (F1).

## Ordered fix list

1. F1: settle the defence rule budget (shared `strike` and `row_cannon`, or raise U10) and update `ex_underwater_09`.
2. F2: widen P3e to every block-removing action; add `telegraph` to `ex_pirate_03` and `ex_pirate_10` and to 8.2.
3. F5 and F3: complete the `level_table` rows for the other four 9.7 exemplars; fix the `flavour` fields and the `ex_pirate_03` headline.
4. F4 and F7: put the 1-2 defence count into U7; define the odd-width spawn default.
5. F6: ASCII mask and tier-9 positioning for `ex_underwater_09`.

After 1-3, I expect V2, V4, V5 and V6 to clear 9.7. Re-run as r8.
