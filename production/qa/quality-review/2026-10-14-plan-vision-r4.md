# Plan review r4: phase 1 campaign vision (header still says "revision 3") plus exemplars (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md`, `design/levels/plans/exemplars.md` (revision 2), the two amended art-bible
passages (section 1 pillar 3, lines 54-57; section 7 board terrain, line 304: both verified), `minigame-party-rules.md`, and the
redo plan. Previous reports: r1, r2, r3 in this folder. As instructed, the near-miss sample's off-list `sways` id is deliberate and is not
counted as a defect.

## Scores

| # | Criterion | r2 | r3 | r4 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.4 | 9.5 | 9.6 | NO |
| V2 | Pillars: distinct, each with an appliable test | 8.9 | 9.1 | 9.4 | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.2 | 9.1 | 9.4 | NO |
| V4 | "Every level unique" rules | 8.7 | 9.0 | 9.2 | NO |
| V5 | Briefs for narrative, systems, level teams | 8.8 | 9.1 | 9.3 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 8.7 | 9.0 | 9.1 | NO |
| V7 | Consistency with user decisions and constraints | 9.0 | 9.2 | 9.4 | NO |
| Ex | Exemplars as calibration (supplementary, not a V score) | | ~8.6 | **8.9** | NO |

## Verdict: FAIL

All seven are below 9.7. The vision is now close and internally mostly coherent; what remains is one set of arithmetic and consistency
slips between the new U17 and the rest of the document, plus a set of exemplar errors that break the vision's own rules (an exemplar
that violates the rules it teaches calibrates the panel wrongly).

## r3 fixes: did they land?

| r3 item | Landed? | Note |
|---|---|---|
| C1 U17 scene spread, table columns, U14 extended | YES | Closed lists are not seeded (D2); budget conflicts (D1) |
| C2 P1c measurable (60% of board pixels, no occlusion) | YES | |
| C3 cosmetic vs rule for set-piece actions | YES | Applied in U10 too |
| C4 art-bible amended, scene-kit budget, producer report | YES | Art bible verified. Budget sits under the Minigames bullet (D1) |
| A1 Pirate stakes, "first reversal" label | YES | Celestial/Pirate intensity both 4 (D5) |
| A2 reorder side effects | YES | |
| F1 fantasy sentence and diorama | YES | |
| F2 phase scope of tests; rubric A split | YES | |
| F3 `goal_type` as a list | YES | U3 compares the list |
| E1 near-miss sample | PARTLY | Not "all fields filled"; mean score 9.3, not 9.0 (X4) |
| E2 boss, hard, level-01 exemplars, N/M anchors | YES in kind | Content errors (X1-X3) |
| E3 tone/schema fixes in the exemplar | YES | comic fail, caption, handbook link, canonical mask string present |
| E4 "form, not content" | YES | Id collision for the check (X6) |
| E5/E6 | YES | |

I checked the canonical mask strings: the 12x8 trench canonicalises correctly to `8x12:...` (width 8, rows ordered with `#` before `.`)
and the L-shaped 8x8 deck is its own canonical form (it is symmetric under transpose). The `level_table_row` has 16 columns in schema order.

## Defects in the vision (ranked)

**D1 (V4, V5) U17 conflicts with the scene-kit budget, and U17 is missing from the checks.**
- U17 needs at least 7 distinct terrain ids per biome; section 7.4 budgets "terrain modules (6-8 per biome)". Six would fail U17. Fix:
  "terrain modules (7-8 per biome)". The budget paragraph is also filed under the Minigames bullet (7.4); give it its own bullet
  ("5. Scene kit budget") so it is not read as a minigame item, and renumber.
- Section 9 Preconditions list "U3, U5, U6, U7, U12, U14, U15, U16, the name check" (no U17), and L2 says "U1-U16". The script check in
  section 5 does verify U17. Fix: add U17 to the Preconditions list and change L2 to "U1-U17".

**D2 (V4, V2) The closed lists P1b and U17 depend on do not exist.** `scene.terrain`, `scene.set_piece_action` and `cast_pose` ids are "closed
lists" whose first approval is "before specs are scored", but nothing seeds, files or owns them. The script needs a file to read.
Fix wording (U17): "The lists live in `design/levels/plans/scene-vocabulary.md` (owner: technical artist). Phase 3 seeds them from the
roster and the exemplars (terrain, action and pose ids); phase 4 groups may propose additions only through a change request that the
artist approves before the `level_table` is checked. A spec using an id not on the list fails the U17 script."

**D3 (V3) "Rising stakes" are not rising.** The text says "Recovery takes three biomes with rising stakes" but intensity is 4, 4, 5
(Celestial, Pirate, Carnival), and Celestial is "sublime calm". Fix: set Celestial intensity 3 ("awe and gathering, quiet before the
rise") so the run is 3, 4, 5, and make the sentence say "rising intensity (3, 4, 5)".

**D4 (V7, V1) Header is stale.** Line 1 says "revision 3" and line 3 says "after the r1 and r2 reviews". Fix: "revision 4; revised after r1-r3".
Also add `minigame-party-rules.md` (user decision) to the Inputs list, since 7.4 depends on it.

**D5 (V2, V4) Mask playability is unconstrained.** Exemplar masks include a 2-cell-wide, 6-deep leg (pirate_10) and a 3-wide pillar.
Pieces such as T, L, S, Z cannot enter a 2-wide channel, so this can create unwinnable runs, against P3d. The vision has no minimum
corridor width. Fix (U7 addendum): "Every playable region is at least 4 cells wide where pieces spawn and no dead-end channel is narrower
than 3; the solver (P3d) checks this at phase 7." (If the piece set permits narrower shafts, the rule states the actual minimum.)

**D6 (V7, process) Phase 2 output already exists.** `design/narrative/campaign-story.md` is present, but the plan says "no phase starts before
the one it depends on passes", and this gate is still FAIL. Not a vision defect; the producer should log it as a decision (draft work
allowed pending gate) or hold it.

## Exemplars: calibration score 8.9 / 10

What works: the structure is now right (beat, spec, near-miss, weak, boss, hard remix, level 01, N/M anchors), the weak sample is
excellent, the "form, not content" and exemption rules are clear, the canonical masks and the table row are correct, and the boss and
chapter anchors tie to the arc.

What still breaks calibration (every item makes the anchor disagree with the vision):

**X1 The 9.7 spec breaks "teach alone before combining" (U10).** `forest_05` is a tier-05 twist level, yet the spec says `vines` is "new,
taught alone here" while the pill also carries `gust`, and the handbook anchor says "Debut: forest_05". The vision's function labels put
new rules in teach levels (01-03). Fix: have `vines` debut in `forest_02` ("handbook#vines, taught in forest_02") and make `forest_05` add no new
rule (its novelty is the goal-phase twist); change the "Rule budget note" and the M7 anchor's "Debut" accordingly.

**X2 The handbook anchor contradicts the spec.** The M7 entry says vines "never removes or moves a block on its own", while the spec calls
`root_whip` "the same idea" that "sways the bridge". Either root_whip is a separate rule with its own entry (then forest_05 adds a rule, see X1),
or the vines entry must say what the whip does. Fix: "Vines. ... In a gale a vine-held bridge sways but never loses a block."

**X3 The boss exemplar breaks the rule budget and the teaching order.** `pirate_10` debuts `cannon_volley` as its `main_rule` at tier 10
(untaught), then adds a second lane, a tilting deck and "cleared rows load the cannon": at least three new ideas in one level, against U10/P3c, and a
boss must combine rules already taught in tiers 04-09. Fix: "main_rule: cannon_volley (taught alone in pirate_03; handbook#cannon_volley)", and
reduce the phases to: p1 volley from the bow; p2 rival ship adds a second lane; p3 the same volley at higher speed, with the tilt deleted (or a
named earlier rule, `tilt_plate`, taught in pirate_06).

**X4 The near-miss sample is not what its label says.**
- It says "All fields are filled" but shows only 8 fields (no mask, `target_visible`, `comic_fail`, `opening_event`, world change, minigame
  block). A panel following the vision's cap would score L7 low, but the sample expects L7 9.6. Fix: add "abridged for display; assume every other
  required field is present and valid", or list them.
- Its expected scores average 9.3 (L1 9.5, L2 9.0, L3 9.3, L4 9.5, L5 9.5, L6 8.8, L7 9.6), not "about 9.0". Fix: relabel "about 9.3" or lower
  L3, L5 and L6 so the mean is about 9.0.
- `scene.set_piece: old_tree` is inside `scene` while the `look` block omits `set_piece`; one place should own it (`look.set_piece`).

**X5 Required fields are missing from two "9.7" exemplars.** `meadow_01` has no `metadata.signature`, `look` block, `target_visible`, `opening_event`,
`comic_fail` or handbook link; `forest_h1` has no `comic_fail`, `target_visible`, `world_change` or mask string; `pirate_10` has no `look` block,
`target_visible` or `opening_event`. Under the vision's own caps these would not score 9.7 on L7. Fix: either complete the fields or add above each:
"Abridged: only the fields that teach this role are shown; all other fields are present." (And say which they are.)

**X6 Rule violations in the content.**
- `meadow_01` headline "Raise the lookout so Ada can see the sheep" is 9 words; U15 caps `headline_objective` at 8. Fix: "Raise the lookout so Ada spots sheep" (7).
- Exemplar ids (`forest_05`, `meadow_01`, `pirate_10`) collide with real ids in the `level_table`, so the script would see duplicate rows. Fix: use
  `ex_forest_05` etc. for the exemplars and say the real levels must still differ.
- Pose verbs: Nanny Tuft "paces and rings her bell (point)" uses a hero verb for an animal. Fix: add `react` to the closed pose list for
  animals and props, or list the goat as scenery with no pose.
- The hard remix's `reveal` ("the goat's far ledge is the real destination") is vague; state what is hidden and what the telegraph is.

**X7 Thin anchors outside level specs.** There is no weak sample for beats or for the N, M, A, C, S items; "A, C, S: a 9.7 item is one with
evidence on file" does not teach the panel to separate 9.7 from 9.0. Fix: add a weak beat ("Forest. A mossy place. The heroes stack
blocks to clear four rows."), a weak handbook entry ("Vines: uses the `vine_tick` signal"), and one-line 9.0 and 9.7 examples for A (one cost sheet),
C (one contact-sheet judgement) and S (one cue list).

## Remaining fixes, ranked

1. **Align U17 with the rest (D1, D2):** terrain modules 7-8; U17 in Preconditions and L2; `scene-vocabulary.md` with owner and seeding.
2. **Fix the exemplars' rule breaks (X1, X2, X3, X6):** vines debuts in forest_02; cannon_volley taught in pirate_03; boss adds one idea per phase; 8-word
   headline; `ex_` ids.
3. **Complete or declare-abridged the exemplar fields (X4, X5)** and relabel the near-miss.
4. **Raise the weak-anchor coverage (X7)** for beats, handbook, and A/C/S.
5. **Arc and housekeeping (D3, D4, D5, D6):** Celestial intensity 3; revision header and inputs; minimum corridor width in U7; log the phase-2 file.

After fixes 1-3 I expect V4, V5 and V6 to clear 9.7; V1-V3 and V7 need fix 5. Re-run as r5.
