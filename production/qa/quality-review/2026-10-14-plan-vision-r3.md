# Plan review r3: phase 1 campaign vision, revision 3, plus exemplars (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md` (r3), `design/levels/plans/exemplars.md`. Checked against the r1 and r2 reports,
`level-identity-spec.md` (now with the "scene, not a grid" user rule), the redo plan, the art bible and the quality bar.

## Scores

| # | Criterion | r1 | r2 | r3 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 8.8 | 9.4 | 9.5 | NO |
| V2 | Pillars: distinct, each with an appliable test | 8.2 | 8.9 | 9.1 | NO |
| V3 | Emotional arc: escalation, variety, ending | 8.5 | 9.2 | 9.1 | NO |
| V4 | "Every level unique" rules | 6.8 | 8.7 | 9.0 | NO |
| V5 | Briefs for narrative, systems, level teams | 8.0 | 8.8 | 9.1 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 8.0 | 8.7 | 9.0 | NO |
| V7 | Consistency with user decisions and constraints | 6.9 | 9.0 | 9.2 | NO |

## Verdict: FAIL

Close, but every score is still below 9.7. No criterion has a structural contradiction left of the kind seen in r1 (U9 vs U12),
yet each has a fix that is not a wording nit: scene fields are not covered by any uniqueness or budget rule, the exemplar breaks
the vision's own tone and schema rules, and the calibration set cannot teach the 9.7 / 9.0 boundary.

## r2 fixes: did they land?

| r2 item | Landed? |
|---|---|
| N1 set-piece arithmetic (7-8 per biome, 84-96 total) | YES (U6, section 8, identity spec struck through) |
| N2 counter goal defined; 3 of 4 surprise endings must be twist/reveal/guest; P2c reworded | YES (U15, U16, P2c) |
| N3 script owner, phase 3, `level_table` schema, U5 threshold (IoU 0.85), U7 clause removed | YES. Schema lacks the new `scene` columns (see C1) |
| N4 spec-time vs build-time pillar tests, P3d definition | YES |
| N5 opening_event owned by phase 2; `metadata.ending`; `n` and `target_visible` fields; identity spec marked | YES |
| N6 closed list for boss actions, night biomes named, 84 ids | YES |
| N7 stakes proposed; Wizard flaw checkpoints | YES |
| N8 director writes exemplars; "9.7 means" lines; caps wording | YES. Content gaps remain (see E1-E6) |
| N9 proposed labels; open decision | YES. Pirate decision now settled by the user (11th) |
| N10 name-check split | YES |
| N11 fantasy wording | YES |

## Pirate 11th and the scene rule: handling

- **Pirate 11th:** recorded as a user decision; biome-order paragraph, section 3 table, narrative brief and systems brief
  all follow it; the coordinator is told to reorder `catalog.json`, `economy.json`, `progression.md`. Good.
  Defects: see A1, A2.
- **"A level is a scene, not a grid":** P1 is rewritten into P1a/b/c, `scene.*` fields are in 8.2, a scene kit is in the
  engine gaps, rubric L6/A1/C5 and caps exist. Good in intent. Defects: see C1-C4.

## Defects (ranked)

### Criterion-level defects in the vision

**C1 (V4, V2) Scene fields are not under any uniqueness rule, so "a different scene each level" is unenforced.**
The user wants every level to be a different place. `scene.terrain`, `scene.set_piece_action`, `scene.cast_on_stage` appear only
in P1b ("empty or decorative scores 0") and the 8.2 field list. U14 omits them, `level_table` has no scene columns, and the
script cannot check them. A biome could use "a ravine" 14 times and pass. Fix wording:
> **U17 Scene spread.** `scene.terrain` and `scene.set_piece_action` each take an id from a closed list (the phase 4 groups
> propose it; the technical artist approves it before specs are scored). Per biome: at least 7 distinct terrain ids and 7
> distinct action ids; no terrain id more than twice and no action id more than twice; across the campaign no
> `(terrain, set_piece_action)` pair repeats. The `level_table` gains the columns `terrain`, `set_piece_action` and
> `cast_pose` (a closed list of cast-action verbs: build, haul, cheer, hide, brace, point). U14 is extended to
> `(canonical_mask, terrain, set_piece, time_of_day, weather)`.

**C2 (V2) P1c is not measurable.** "At least as much art as board" and "the camera frames both" have no method. Fix:
> *P1c (build-time):* on the start and mid screenshots at 720x1280, scene pixels (not board, not HUD, not plain sky gradient)
> are at least 60 percent of the board's pixel area, measured by a segmentation mask in the capture tool; the terrain, the
> cast and the set piece acting are each identifiable; and the active piece, the stack and the landing marker are never
> occluded by the scene (readability first, art bible pillar 5).

**C3 (V2, V5) Is the set-piece action cosmetic or a rule?** The identity spec says the catapult "fires", the kraken "grabs", the
lava "rises" and that the set piece "is part of the play". The exemplar's "roots whip the new bridge in the gale" changes the
board. If it changes play it is a rule (U10 budget, handbook entry, M7); if it is scenery it must not touch the board. The vision
does not say. Fix, in section 2 under P1: "`set_piece_action` is cosmetic unless it is the level's `main_rule` or an extra; any action
that moves, removes, blocks or scores blocks is a rule, counts toward U10 and needs a handbook entry. Cosmetic actions have a
static reduced-motion pose."

**C4 (V5, V7) Scope and the art bible are unaddressed.** The scene kit asks for 168 terrains, 84-96 acting set pieces, posed
and animated cast in every level, and themed meters, with no budget in the vision (only "art-costed"). The art bible still says
"every play space is a floating island chunk" (section 1, pillar 3) and "board island: a square stone-tile board" (section 7),
which contradicts "not the same floating square". Fix: add to the art-bible change list at the top (next to Pirate/Dune Bazaar/
Lana, Boulder, Glim): "section 1 pillar 3 and section 7 are amended: a board sits in a level-specific terrain; the floating island
is one terrain among many." Add to section 7: "The phase 3 engine-gap list prices the scene kit as: terrain modules (target 6-8 per
biome, reused under U17), cast poses (6 verbs per hero, three heroes plus the Wizard, set once and reused), acting set pieces
(84-96, each a looping 2-4 second animation), and the 4-6 HUD meters, each with owner and size. The producer reports the total
against the phase 6 buffer before phase 4 starts."

**A1 (V3) Stakes fall at the wrong place after the Pirate move.** The table now goes Celestial "The whole sky" (4) then Pirate
"Treasure and a ship's pride" (4) then Carnival "The world holds or sags" (5). Stakes drop right before the finale and intensity is
flat at 4-4. Fix: change Pirate's stakes to "The last key and the way to the Fair" and its role line to "the rowdy rivals hold
the last piece the party needs", and set Pirate intensity 3 or 4 with a finale-bound hook in the tier-10 boss. Also change row 5's
role "the midpoint reversal" to "the first reversal (chapter 5 of 12)"; the true midpoint is 6.5.

**A2 (V7) Reorder side effects not owned.** The coordinator is to reorder three data files, but `minigames.md` debut assignments
(Pirate debuts modules in biome 5) and the tournament unlocks shift too. Add: "`minigames.md` debut biomes and tournament unlock
order are re-derived in phase 3 from the new order; the narrative and systems leads must not use the old 5th-place Pirate position."

**F1 (V1) Fantasy grammar and the scene.** The sentence "their perks (...; proposed as tools you choose before a level), and they
are on stage" is broken, and the fantasy never mentions the diorama. Replace with: "Dame Ada, Bram and Sif are your party. Their
perks (Stitch, Smash and Redraw, kept from the old design) are proposed as tools you choose before a level, and they stand on
stage reacting to what you build. Every level is a small diorama, a gully, a fort wall, a raft, with a landmark that acts and
a cast that cheers."

**F2 (V5) Phase scope of the tests and rubric A.** The spec-time list includes P1b (needs specs), so phases 2 and 3 can only apply
P1a, P2a, P2c. Section 9 says "phases 2-5 apply the spec-time tests" for all. Fix: "Phase 2 and 3 apply P1a, P2a, P2c;
phases 4-5 apply the full spec-time set." Rubric **A is labelled phase 5** but A2 (match boards 13 and 15), A4 (reference parity),
A5 (no beige anywhere) and A6 (reduced motion) can only be judged on built art. Split: "A-spec (phase 5): A1, A3 and a cost check.
A-build (phase 8): A2, A4, A5, A6." S, B and C are correctly build-time.

**F3 (V4) Goal phases are not representable.** The twist pattern changes the goal mid-level (exemplar: span, then survive), but
`goal_type` and U3 hold one value. Fix: "`goal_type` is a list in play order (for example `span>survive`); U3 compares the full list."

**F4 (V7) Minor.** Section 3 labels Lava the "midpoint reversal" (see A1). The caption rule says "one sentence", the exemplar
caption is a fragment (see E3).

### Exemplars: does `exemplars.md` calibrate well?

Verdict on the calibrator: **useful, not yet sufficient (about 8.6/10).** The weak sample is excellent at the bottom end: every defect is
named, mapped to a rule, tied to a cap, with expected panel scores. The good beat and spec show form and the schema. But:

**E1 Wrong boundary coverage.** Only two points are anchored, 9.7 and about 6-8. The vision's anchors turn on 9.7 vs 9.6 vs 9.0, and
the panel's real work is separating a 9.7 from a competent 9.0. Add a **near-miss sample** (target 9.0): all fields filled and a good
twist, but a generic `scene` ("a cliff", set piece decorative-but-named), two cast poses repeated from the neighbouring level, and a
signature that names rules. Expected scores per criterion with the one structural fix that keeps it from 9.7.

**E2 One level type only.** The exemplar is a twist level. There is no tier-10 boss (U9, boss triple, arena change), no bonus level, no
hard remix (U3 remix rule, `callback_of`), no minigame-block level, and no level 01 (opening set, one rule). These are the highest-
risk specs. Add three more exemplar specs (boss, hard remix, level 01) and one exemplar chapter entry. Also add short anchors for the
non-L rubrics: N1-N3 (one chapter paragraph), M (one handbook entry, M7; one boss triple row), and the A, C, S items.

**E3 The exemplar breaks the vision's own tone and schema rules.**
- `comic_fail: ... Sif holds up a "ten out of ten" leaf`. That is sarcasm aimed at the player's failure and text inside play, against
  "no sarcasm, no mocking the player" and "wordless in play" (section 4). Replace with: "Nanny Tuft slides down on her bottom, the
  bell rings once, and Sif covers her eyes; retry in 1.5 s."
- `level_table_row` holds `U-trench-12x8` in the `mask` column; the schema requires the canonical mask string (the smallest of the
  8 transforms). Replace with the actual canonical string, and add the new `terrain`, `set_piece_action`, `cast_pose` columns (C1).
- The caption "A bridge, a bell and a very patient goat." is a fragment; the rule is "one sentence". Use "Nanny Tuft rings her
  bell, and everyone builds."
- `extras: gust` should show its handbook link (8.2 requires "each linked to its handbook entry"), and the TBD values for `g0` and
  stars would fail L4/L7 under the vision's own caps. State at the top: "Fields derived from phase 3 formulas are exempt in exemplars."
- `goal_type: span` (single value) hides the span>survive twist (F3).

**E4 Copy risk.** The exemplar's goat, bridge-then-gale and trench mask are the same example the vision's fantasy uses, so 168 makers
will anchor to it, and it would then count against U3/U14 as a template. Add: "Exemplars teach **form**, not content. No level may reuse
the exemplar's set piece, terrain, mask, ending or character." Make the exemplar forest level a recorded ID (`forest_05` stays a
neutral calibration id, and the real `forest_05` must differ from it; U14 includes the exemplar in the uniqueness check).

**E5 The 9.7 exemplar claims "target 9.7 on N4" for a single beat.** N4 scores 168 beats. Reword: "each field would pass N4 on its own."

**E6 Scene specificity is the best part; extend it.** The exemplar's `scene` block is the right level of detail. Add the missing
`scene.hud_meter` rationale ("Sway meter fits the gale phase"), and add an exemplar of a level where no meter fits, so makers know
`hud_meter` is optional and an empty cell here is not a defect (the vision says "where it fits" but the cap says "empty scene field").
Clarify the cap: "an empty required scene field (terrain, set_piece_action, cast_on_stage)".

## Ranked fixes (what to do, in order)

1. **U17 scene spread plus table columns** (C1), and extend U14.
2. **Make P1c measurable and decide cosmetic vs rule for set-piece actions** (C2, C3).
3. **Fix the exemplar** (E3): comic fail, mask string, caption, handbook link, exemption note; add a near-miss sample (E1) and boss,
   hard, level-01 exemplars (E2); add the "form, not content" rule (E4).
4. **Budget the scene kit and amend the art bible** (C4), and split rubric A into spec and build halves (F2).
5. **Repair the late-campaign arc** (A1) and the reorder side effects (A2); fix `goal_type` lists (F3) and fantasy wording (F1).

Once 1-4 are done, V2, V4, V5 and V6 should reach 9.7; V1, V3 and V7 need A1, A2 and F1. Re-run r4 after.
