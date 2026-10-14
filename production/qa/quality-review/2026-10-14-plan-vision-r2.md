# Plan review r2: phase 1 campaign vision, revision 2 (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md` (revision 2). Checked against the r1 report
(`2026-10-14-plan-vision.md`), `level-identity-spec.md` (including "User rules, 2026-10-14 (later)"),
`campaign-redo-plan.md` (now updated: it carries U15/U16 at line 62 and the handbook at line 92), the art bible and
the quality bar. Inputs all FOUND; `assets/data/set_pieces.json` is still absent (the vision now says so).

## Scores

| # | Criterion | r1 | r2 | Pass (>= 9.7) |
|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 8.8 | 9.4 | NO |
| V2 | Pillars: distinct, each with an appliable test | 8.2 | 8.9 | NO |
| V3 | Emotional arc: escalation, variety, ending | 8.5 | 9.2 | NO |
| V4 | "Every level unique" rules (incl. no-mundane / surprise-ending rule) | 6.8 | 8.7 | NO |
| V5 | Briefs for narrative, systems, level teams | 8.0 | 8.8 | NO |
| V6 | Rubric quality | 8.0 | 8.7 | NO |
| V7 | Consistency with user decisions and constraints (incl. new user rule) | 6.9 | 9.0 | NO |

## Verdict: FAIL

Large progress; no score reaches 9.7. The remaining defects are narrower, but several are real arithmetic or
sequencing errors that would make the gate unpassable or unenforceable, so they must be fixed, not noted.

## Verification of the r1 fixes

| r1 fix | Landed? | Note |
|---|---|---|
| 1 U12 vs U9 tier-10 contradiction | YES | Tier 10 exempt, boss triple added, Neon boss confirmed. |
| 2 Mechanics handbook | YES | Section 7 deliverable, M7 rubric, linked from level specs. Plan updated too. |
| 3 Measurable uniqueness (definitions, U14, U5 protocol, U8 ids, U6 edit) | MOSTLY | Definitions and U14 present; see new defects N1, N2, N3, N6. |
| 4 Pillar tests appliable, split, tension recorded, rule budget reconciled | PARTLY | P2 split and budget reconciled; but P3a and P3d cannot run on specs (N4). |
| 5 Board-title ban, any-third-party IP | YES | Hard rule present with script. "Paraphrase" can only be human-checked (N10). |
| 6 Rubric strengthening | PARTLY | Preconditions, coverage, anchors, calibration, A/B/C/S added; see N4, N8. |
| 7 Cast and art dependencies | YES | Mapping, art rows, Pirate block, Dune Bazaar recorded. Species stated as fact (N9). |
| 8 Arc: stakes, ending, intensity | YES | Stakes column, intensity, ending (proposed). Stakes presuppose concept A (N7). |
| 9 Pitch, beat schema, id mapping, set-piece owner | YES | Pitch, YAML schema, beat id = level id, technical artist owns set pieces. |
| 10 Minor edits | YES | Ribbon wording, accessibility, Cave, Clover Circle, 11-of-12 source. |
| New user rule (no "clear N", surprise endings) | MOSTLY | U15/U16, P2c, `ending_pattern`, rubric caps, plan line updated. Loopholes N2, N5. |

## New or remaining defects (ranked)

**N1 (V4) Set-piece arithmetic is impossible.** U14 says "within a biome no `set_piece` repeats more than twice".
With 14 levels, that needs at least 7 set pieces per biome. U6 and section 8 allow "5-8" (minimum 5), and the total
"60-96" is wrong. Fix: U6 "7-8 set pieces" and section 8 "84-96 in total".

**N2 (V4/V7) "No counter goals" is undefined, and the surprise quota has a loophole.**
- U15 bans "any fill-a-counter goal" but `shape` (fill a shape), `height` (reach N) and `survive` (timer) are all
  allowed goals, and the identity spec itself uses "fill the dam shape" as a good example. P2c bans the words "clear,
  fill or reach N". A reviewer cannot tell which of these are legal.
- U16 counts "secret" and "story" endings toward the 4. A secret ending is optional (the base ending is obvious from the
  start), and a story-resolved end can also be obvious. The user asked that endings are sometimes NOT obvious from the start.
Fix wording:
> **U15 (add):** A *counter goal* is any goal whose only HUD readout is a bare number to reach or fill (rows, cells,
> seconds) with no story object. `height`, `shape`, `survive` and the other goals are legal only when the HUD names a
> story object (the lookout, the dam, the cloud) and the number is secondary. The `headline_objective` must contain a
> noun from the beat and no bare numeral.
> **U16 (add):** At least 3 of the 4 required surprise endings per biome must be `twist`, `reveal` or `guest` (the end
> is not predictable from frame 0). `secret` and `story` may fill only the 4th slot.
> **P2c (edit):** replace "the words clear, fill or reach N" with "a bare counter".

**N3 (V4/V5) The uniqueness script is underspecified and mis-sequenced.**
- `tools/qa/check_level_uniqueness.gd` is "built in phase 4" by "qa tooling", which is not an owner in the plan, and it
  must exist before the phase 4 output is reviewed. Add it to the plan task list as a phase 3 task with an owner and a
  size.
- The `level_table` has no schema. Fix: "`level_table` is a Markdown table with the columns `id`, `goal_type`, `main_rule`,
  `mask` (canonical string), `set_piece`, `time_of_day`, `weather`, `camera`, `opening_event`, `ending_pattern`,
  `headline_objective`, `role`, `callback_of`."
- U5 uses "mask plus set piece, HUD and skin removed" frames, which do not exist at phase 4-5, and "a threshold set in
  phase 5" (the review that uses it). Fix: "In phases 4-5 the script compares the table (canonical mask plus set-piece id);
  in phases 7-8 it compares real start frames. The threshold is set in phase 3 and fixed before specs are written."
- U7 "at least 8 distinct canonical masks" is superseded by U14 (all 14 distinct). Delete the U7 clause or restate it as
  "(U14 applies)". Note this means the 4 plain squares per biome must be 4 different sizes; say so.

**N4 (V2/V6) Pillar tests still cannot all run at the stated phase, and the rubrics apply them everywhere.**
Section 2 says each test runs on the spec in phases 4-5. P3a (5 first-time players) and P3d (500 bot runs) need a built
level. P3b and P3c can be read from the spec. Section 9 says "Every rubric applies P1, P2a-c and P3a-d to 5 sampled
levels", which is impossible for the phase 2, 3 and 4 gates. Also P3d "98% of 500 seeded bot runs are winnable" measures the
bot, not winnability. Fix:
> Spec-time tests (phases 2-5): P1, P2a, P2b, P2c, P3b, P3c, plus a `target visible` field for P3a. Build-time tests
> (phases 7-8): P3a (5 players, 4 of 5) and P3d ("a solver or bot with unlimited time wins at least 98% of 500 seeded
> runs; a loss is a bot failure only if a legal winning line existed"). Section 9 Pillars bullet: "Phases 2-5 apply the
> spec-time tests to 5 sampled levels; phases 7-8 apply all of them."

**N5 (V5) Ownership loops and naming mismatches.**
- `opening_event` ids are required in phase 2 beats, but section 5 U8 says "Phase 4 lists the ids". Fix: "Phase 2 assigns
  and lists the ids (the narrative lead); phase 4 may refine them under the same uniqueness rule."
- `ending_pattern` (vision) vs `metadata.ending` (identity spec). Fix: "The spec field `ending_pattern` is written to
  `metadata.ending` in the JSON."
- Section 8.2 dropped goal size `n` and the `target visible` field that 8.4 uses; add both ("goal parameters from the
  phase 3 formula").
- The identity spec still says "at most 5 clear_n levels per biome" (line 16-17) and "4-6 set pieces". The vision says
  it supersedes only clear_n. Fix: mark both lines in the identity spec as superseded (coordinator), and say in the vision
  "also supersedes the set-piece count (now 7-8)".

**N6 (V4) Smaller measurability gaps.**
- U12 boss triple: "the building action that damages them" needs a closed list (from the handbook), or the triple is
  trivially unique.
- U6 "night biomes ... may use 2 plus dawn or dusk" is fine, but add the list: "Celestial and Neon".
- U8 "none appears in more than 2 biomes" with 168 levels and 12 biomes: at least 14 ids per biome and at most 2 biomes each
  means at least 84 distinct ids. State it so phase 2 plans for it.

**N7 (V3) Stakes and ending pre-empt the story.** The Stakes column ("The world holds, or sags", "The party is split")
reads as concept A and is not marked proposed, though the narrative lead may pick B or C. Mark the whole column
"proposed; the narrative lead may change wording but not the escalation shape". Also, the arc has no "Wizard flaw"
checkpoint before the finale; add "the flaw is shown by biome 4 and costs the party in biome 10".

**N8 (V6) Rubric.**
- Exemplars are written by the phase makers and scored by the panel as anchors; makers marking their own anchor biases
  the scale. Fix: the game director writes the exemplar and the weak sample.
- Rubrics A, B, C and S are bare lists with no definition of a 9.7 for each item; V1-V7 are names only. Add a one-line
  "9.7 means" per item or reuse the global anchors explicitly ("each item uses the section 9 anchors").
- The bullet "Specific criteria are single-purpose" does not say what it requires; reword to "Mundane or counter-based
  levels cap N4, M3 and L3 at 8.0".
- Script caps: say which role runs the script (QA) and that the reviewer applies the cap.

**N9 (V7/V1) Facts stated as decisions.** Section 1 says perks "are tools you choose before a level" and section 4 fixes
Lana as an alpaca and Boulder as a hippo; the cast decision gives neither, and section 7.6 itself says "proposed". Mark
both as proposed in sections 1 and 4. Section 0 says the user's word was "the 11th biome added"; the user's text is
"11th main biome, after Underwater", so the gloss is invented. Replace it with open decision (5): "Pirate plays 5th (catalog);
the user's decision says '11th main biome, after Underwater'; confirm 5th."

**N10 (V7) The name check.** "equal or paraphrase" cannot be scripted. Fix: "The script catches exact and near-match names;
reviewers catch paraphrases (N5, L1)."

**N11 (V1) Small.** "Clearing a layer is a cheer and a pay-out" repeats the counter flavour the user rejected; prefer "a cleared layer
pays out something in the story". Keep the pitch.

## Verdict on the new user criterion

Scored under V4 (8.7 total, criterion-specific 9.0) and V7 (criterion-specific 9.2): the vision now bans headline
`clear_n`, requires a story objective, requires 4 surprise endings per biome with a field and a script, and amends P1/P3a.
It falls short of 9.7 because "counter goal" is undefined for `height`, `shape` and `survive` (N2) and because the
quota can be met with endings that are still obvious from the start (N2).

## Next step

Apply N1-N5 (all are small text edits except the script owner and schema) and N8's exemplar change, then re-run r3.
V1, V3 and V7 should clear 9.7 once N7, N9 and N11 are done; V2 and V6 need N4; V4 and V5 need N1-N3 and N5.
