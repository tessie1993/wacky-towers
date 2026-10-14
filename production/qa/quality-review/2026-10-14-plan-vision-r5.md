# Plan review r5: phase 1 campaign vision (revision 4) plus exemplars (revision 3) and scene-vocabulary (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md` (revision 4, commit b33d2d3), `design/levels/plans/exemplars.md` (revision 3),
`design/levels/plans/scene-vocabulary.md` (new), against the r1-r4 reports, the redo plan (line 114 now carries the script task), the art bible,
and `catalog.json`. The near-miss `sways` id is deliberately off-list and is not counted.

**Correction to my own r4 report.** r4 D5 said T, L, S and Z pieces "cannot enter a 2-wide channel". That is wrong: every tetromino fits a 2-wide shaft in
a vertical orientation. The vision copied my wording into U7. The corrected defect is in D2 below.

## Scores

| # | Criterion | r3 | r4 | r5 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.5 | 9.6 | 9.7 | YES |
| V2 | Pillars: distinct, each with an appliable test | 9.1 | 9.4 | 9.6 | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.1 | 9.4 | 9.7 | YES |
| V4 | "Every level unique" rules | 9.0 | 9.2 | 9.3 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.1 | 9.3 | 9.5 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.0 | 9.1 | 9.4 | NO |
| V7 | Consistency with user decisions and constraints | 9.2 | 9.4 | 9.6 | NO |
| Ex | Exemplars as calibration (supplementary) | ~8.6 | 8.9 | **9.3** | NO |

## Verdict: FAIL

V1 and V3 now pass. Five criteria remain below 9.7, but the distance is small, and what is left is four narrow structural slips (an id-scope
contradiction, a corridor rule whose rationale is wrong and whose exemplar breaks it, exemplars that fail the checks they are fed to, and an
undefined "idea" vs "rule"), not new design gaps.

## r4 fixes: did they land?

| r4 item | Landed? | Note |
|---|---|---|
| D1 terrain 7-8; own bullet for scene-kit budget; U17 in Preconditions; L2 = U1-U17 | YES | 7.5 is its own bullet, preconditions and L2 updated |
| D2 closed lists file with owner and seeding | YES | `scene-vocabulary.md`. Its "84 ids" claim conflicts with U17 (D1 below) |
| D3 Celestial 3, "rising intensity (3, 4, 5)" | YES | |
| D4 header "revision 4", inputs list | YES | |
| D5 corridor minimum | PARTLY | Added to U7, but the rationale is false, "spawn region" and "dead-end" are undefined, and the solver (phase 7) is the wrong place (D2) |
| D6 phase-2 file exists before gate | NOT IN VISION | Producer item; still open (`design/narrative/campaign-story.md` exists) |
| X1 vines debut at ex_forest_02; forest_05 adds no rule | YES | |
| X2 handbook/root_whip contradiction | YES | root_whip is cosmetic, entry text matches |
| X3 boss teaches cannon_volley at ex_pirate_03; one idea per phase | YES | "Idea" vs "rule" is not defined (D4) |
| X4 near-miss abridged; mean 9.0 | YES | Mean is 9.04 |
| X5 abridged/complete labels | YES | |
| X6 8-word headline; `ex_` ids; `react` pose | YES | Weak samples reuse an exemplar id (D3) |
| X7 weak beat, weak handbook entry, A/C/S 9.0 vs 9.7 | YES | Good |

Checked and correct: all headlines are within 8 words (7, 6, 8, 7); signatures are 4-14 words; the canonical strings for the 12x8 trench and the
thick L deck are right (each is the smallest of the 8 transforms); the `level_table_row` has 16 columns in schema order; the near-miss mean is 9.04.

## Defects (ranked)

**D1 (V4, V5) Terrain and action ids: global or per biome? The documents disagree.**
- `scene-vocabulary.md` says "the full lists must grow to at least 84 terrain and 84 action ids (7 per biome x 12)". That assumes ids are never shared
  across biomes. U17 says only that, per biome, there are at least 7 distinct ids, none used more than twice, and that across the campaign no
  `(terrain, set_piece_action)` pair repeats. The seeds are generic (`plank_bridge`, `raft`, `fort_wall`, shared names). With global ids, 13 terrains and 13
  actions already give 169 unique pairs; with per-biome ids the pair rule is vacuous. The budget in 7.5 ("terrain modules 7-8 per biome", 84-96 acting set
  pieces) then prices either 84-96 builds or about 13, depending on the reading, a factor-of-6 swing in the art budget.
- Fix wording (U17): "Ids are **global**; a terrain id may appear in several biomes, each time as a biome-skinned build. A terrain id used in two biomes
  is one id for the pair rule and two builds for the budget. The scene-kit budget counts builds (7-8 per biome, 84-96 in total); the vocabulary counts ids
  (target 20-30 terrain ids and 20-30 action ids, so that 168 pairs are possible)." Then replace the "84 ids" sentence in `scene-vocabulary.md` with
  "the lists must grow to at least 20 ids each, with every biome using 7 or more of them".

**D2 (V4, V2) The corridor rule has a false rationale and undefined terms, and the exemplar breaks it.**
- The U7 parenthetical "(4-cell pieces cannot enter 2-wide shafts)" is wrong (see the correction above). The real risks are that a horizontal I piece needs 4
  width at spawn and that a 2-wide dead end punishes rotation. Fix: "(a piece that spawns flat needs a 4-wide landing area, and a 3-cell-extent piece cannot
  be rotated inside a 2-wide shaft)".
- "Where pieces spawn", "playable region" and "dead-end channel" are not defined, and the mask semantics are (`#` floor, `.` void). Define: "the spawn region is the
  floor cells of the top mask row (or the rows named by `spawn_rows`); a dead-end channel is a run of floor cells open on one side only".
- `ex_forest_05`'s `corridor_check` says "the trench is 6 cells wide", but the trench is void. The floor strips in the top three rows are two 3-wide pillars, which
  is under the 4-cell minimum if pieces spawn there. Either spawn in the full-width rows below (say so: `spawn_rows: 4-8`) or widen the pillars to 4. This
  matters because the 9.7 exemplar currently breaks its own rule.
- The check is placed at phase 7 in the solver (P3d). It is a mask property: add it to the U7 script at phase 4 ("`min_spawn_width` and `min_dead_end_width` columns
  in `level_table`, computed from the mask").

**D3 (V6) Exemplars are fed to checks they must fail, and ids collide.**
- The vision says the exemplars are included in the U3, U14 and U17 checks. The near-miss (`sways`, `cliff` not on the list) and the weak samples fail on purpose,
  so the check can never be green. Fix: "The 9.7 exemplars (`ex_forest_02`, `ex_forest_05`, `ex_forest_h1`, `ex_pirate_03`, `ex_pirate_10`, `ex_meadow_01`) are included in the
  checks. The near-miss and weak samples are excluded; they exist only for human scoring."
- The weak spec and the weak beat reuse `ex_forest_05`, the id of the 9.7 exemplar. Fix: `ex_weak_forest_05`, and `ex_near_forest_06` for the near-miss.
- The near-miss also uses `terrain: cliff`, which is not on the list. Only `sways` is declared deliberate. Either add "and `cliff`" to its note or use a seeded
  generic id (`summit_ledge`) so the defect is "generic", not "unlisted".

**D4 (V5, V2) "Idea" vs "rule" is undefined and could allow three new rules in a boss.** 7.6 says a boss "adds at most one new idea per phase", while U10 allows one new
rule per level. Three phases could then carry three new rules. Fix: "An *idea* is a variant of a rule already taught (a second lane, a higher speed, a new
target); it is not a rule. A boss adds no new rule; each phase adds at most one idea." Also list `tilt_plate` in `ex_pirate_10`'s pill (it appears only in a phase note).

**D5 (V2) The exemplar's Sway meter hides a gameplay question.** `ex_forest_05` calls `root_whip` cosmetic (nothing moves) but shows a "Sway meter (Balance)" HUD
meter. A balance meter implies a mechanic. Fix: "Sway meter shows the strength of `gust`" (the real rule), so the meter is a readout of a taught rule and the cosmetic
claim is clean. Also move `ex_meadow_01`'s top-level `hud_meter:` under `scene:` for consistency.

**D6 (V7, process, not the vision) Pending coordinator work.** `catalog.json` still lists pirate fifth (the vision notes the reorder is the coordinator's job); and
`design/narrative/campaign-story.md` exists while the phase 1 gate is FAIL. The producer should log both (draft allowed pending the gate, reorder pending).

**D7 (V2, nit) Level-01 exemplar and P2b.** `ex_meadow_01` is a `height` level, so P2b applies ("name the rule or shape that changes how pieces are dropped").
The exemplar does not. Add "P2b: the `lookout` rule asks for a tall, steady stack (nothing changes the drop, which is why this is level 01)", or exempt level 01
from P2b in the pillar text.

## Exemplars: calibration score 9.3 / 10

Strong: the coverage is now right (9.7 beat and spec, near-miss with a stated mean of 9.04, weak spec, weak beat, weak handbook entry, boss, hard remix, level 01,
chapter and handbook anchors, A/C/S one-liners), the abridged/complete labelling is clear, and each exemplar teaches its rule (teach-alone, one idea per
phase, reveal telegraph, 7-word headline). What still costs it: it breaks its own corridor rule (D2), its weak and near-miss entries cannot be run through the
checks (D3), and the cosmetic/rule line is blurred by the Sway meter (D5).

## Ordered fix list

1. D1: declare terrain and action ids global (builds vs ids), fix `scene-vocabulary.md`'s "84 ids" and 7.5.
2. D2: correct the corridor rationale, define spawn region and dead-end, fix `ex_forest_05`'s `corridor_check`, move the check into the phase 4 script.
3. D3: exclude the near-miss and weak samples from the checks; rename the weak and near-miss ids; resolve `cliff`.
4. D4: define "idea" vs "rule"; put `tilt_plate` on the boss pill.
5. D5 and D7: Sway meter wording; `hud_meter` placement; P2b for level 01. Then D6: the producer logs the catalog reorder and the phase-2 file.

I expect V2, V4, V5, V6 and V7 to reach 9.7 once items 1-4 are applied. Re-run as r6.
