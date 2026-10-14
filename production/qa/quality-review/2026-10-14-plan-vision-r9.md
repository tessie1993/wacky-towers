# Plan review r9: phase 1 campaign vision (header still "revision 6"), exemplars (revision 6), scene vocabulary (strict, pass mark 9.7 on every criterion)

Reviewed commit e75a4f5: `design/levels/plans/campaign-vision.md` (489 lines), `exemplars.md`, `scene-vocabulary.md`, against the user rulings A and B, the build-ceiling
anchor, and my r8 fixes. Method: I re-derived every mask, canonical string and recogniser clause by hand, counted `level_table` columns, and re-read the whole vision for terminology drift.

## Scores

| # | Criterion | r7 | r8 | r9 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.7 | 9.7 | 9.7 | YES |
| V2 | Pillars: distinct, each with an appliable test | 9.6 | 9.5 | 9.7 | YES |
| V3 | Emotional arc: escalation, variety, ending | 9.7 | 9.7 | 9.7 | YES |
| V4 | "Every level unique" rules | 9.6 | 9.4 | 9.5 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.5 | 9.4 | 9.6 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.6 | 9.5 | 9.3 | NO |
| V7 | Consistency with user decisions and constraints | 9.7 | 9.6 | 9.5 | NO |
| Ex | Exemplars as calibration (supplementary) | 9.6 | 9.4 | **9.5** | NO |

V6 and V7 fall because the new build-ceiling cap, as written, makes the phase 4 and 5 gates impossible to pass (G1). That is a structural defect, found while fixing r8 item 5.

## Verdict: FAIL

V1, V2 and V3 pass. V4, V5, V6 and V7 are below 9.7. All five r8 fixes landed and are sound in substance. Four items remain that are structural, not wording: a rubric deadlock (G1), overlapping shape recognisers (G2),
an unsized engine-gap tail (G3) and a budget arithmetic slip (G4). The rest is stale text and exemplar data errors.

## r8 fixes: did they land?

| r8 item | Landed? | Note |
|---|---|---|
| G1 U10: 2 new rules plus 2 module debuts, 3+ verbs per mechanic, campaign totals | YES | Totals sentence has an arithmetic slip (G4) |
| G2 glossary, `extra_control`, P1b/P2d meter | YES | One residual "extra verb" (line 51, G6) |
| G3 `ex_forest_05` to 12 wide; `gap_runner` in `mechanic`; module exemplar | YES | `ex_candy_03` added. Stale note on `ex_forest_h1` (G5) |
| G4 recognisers for all 12 shapes; corridor sentence covers every shape | YES | Two recognisers overlap (G2) |
| G5 engine gaps with owner and days; build-ceiling cap; old rule struck | MOSTLY | New gaps sized (21 days total); the older gaps are not; the cap deadlocks the gates (G1, G3) |

### Hand checks (all pass unless listed under defects)

- `ex_forest_05` (12x8 `bridge span`): mask rows `####....####` x3, then full x5. Columns 0-3 give 4 solid rows, columns 4-7 give `#####...` (floor in rows 3-7) x4, columns 8-11 give 4 solid rows: the given
  `8x12` string (4 + 4 + 4 rows) is the smallest orientation. The `bridge span` recogniser holds: a 4-wide gap (3+), 3 rows deep (2-3), pillars 4 wide, base 5 deep (3+). `spawn_cols: 0-3` is right (the centre columns 4-7 are void).
- `ex_forest_h1` stair: column heights 4, 6, 8 (3 distinct, monotone), treads 4 wide; canonical string correct; spawn run 4 wide.
- `ex_candy_03` cross 10x10: corners 3x3, arms 4 wide, symmetric so its own canonical form; spawn columns 3-6 are floor; tutorial line is 9 words; the row has 23 columns in schema order.
- `ex_underwater_09` funnel: row widths 10,10,10,10,10,10,8,6 (narrowing by 4, top 10, bottom 6): matches the recogniser; canonical `8x10` string correct.
- `ex_pirate_10` L: 8x8 minus a 4x4 corner, legs 4 wide, its own canonical form.
- Unique biome footprints: Forest = plain 10x8, bridge span 12x8, stair 12x8; Pirate = plain 9x9, L 8x8; one plain square per biome in all biomes shown.

## Does the length matter? (489 lines against the old 340)

Mildly. The rules are dense and mostly consistent, but length is where drift enters: this pass found one stale phrase ("extra verb", line 51), one stale number (`bridge span 14x8` in `ex_forest_h1`), an arithmetic slip (24 vs 25 rules) and a header that still says
"revision 6". Five teams must read it, and sections 5 (rules, about 115 lines) and 9 (rubrics, about 75 lines) are reference material. Recommendation (not a blocker): keep sections 1-4 and a one-page summary of U1-U19 in the vision, and move the full
rules and rubrics to `level-rules.md` and `review-rubrics.md`, each linked from the vision. Until then, add a short table of contents with the rule numbers, and a changelog line per revision so makers can see what moved.

## Defects (ranked)

**G1 (V6, V7) The build-ceiling cap makes the phase 4 and 5 gates impossible to pass.** Section 9 says: "no item may be scored above what the retained screenshots show of the build ... A phase gate may not claim scene variety passes on the plan alone",
and caps L6, A-build and C4 at 3 for any built biome with a repeated footprint or more than one plain square. But **L6 is a phase 4 (spec) criterion** and A1 a phase 5 criterion, judged before any build or screenshot exists (phase 6 builds and depends on 5).
Read literally, L6 can never exceed what the screenshots show (today: 163 of 168 levels are squares, scene variety about 3), so phases 4 and 5 can never reach 9.7 and phase 6 can never start. Also, the same condition gets two different caps
(L6 and A1 at 8.0 under "Caps", then L6 at 3 under "Build ceiling"). The user's anchor is right: a plan cannot claim that scene variety is achieved. Fix: scope the ceiling to what can be evidenced at each phase.
> **Build ceiling.** Scene variety is scored in two places. **Phases 4-5 (L6, A1, A-spec)** score the *rules and fields*: footprints, shapes, scene fields and the recogniser results. They do not claim the build is varied; a spec review states
> "plan only: the current build still has N squares" and scores the spec on its merits. **Phases 7-8 (A-build, C4, C5)** score screenshots: for a built biome with more than one plain square or any shared footprint, A-build and C4 are capped at 3, and no
> item scores above what the retained screenshots show. Delete L6 from the build-ceiling list; keep the 8.0 cap for specs with a repeated footprint.

**G2 (V4) Two shape recognisers overlap, which makes the name count gameable.** `funnel` (symmetric about the vertical axis, row widths non-increasing, narrowing by 4 or more, bottom 4+ wide) and `ship hull`
(symmetric about its long axis, non-increasing toward one end by 4 or more, narrow end 4+ wide) match the same masks: `ex_underwater_09`'s mask satisfies both. U18 needs at least 8 different names per biome and the script checks only that each declared
name *matches*, so one mask can be given either name and the same shape can be counted twice. Fix:
> "A mask must match exactly one recogniser; when two match, the earlier row in the table names it (priority: plain square, ring, moat, cross, L, stair, bridge span, twin towers, crescent, island chain, funnel, ship hull). `ship hull` additionally requires a
> pointed bow: the end rows narrow to 2 or fewer cells over at least 3 rows, and the stern is flat." (A `ship hull` is not a `funnel`.) Re-check `ex_underwater_09`: it remains a `funnel` (its narrow end is 6 wide).
Also reword `crescent`: "exactly one enclosed bay, open on one side by 3+ cells" is self-contradictory; say "one bay bounded by floor on three sides and open on the fourth by 3+ cells".

**G3 (V5) The engine-gap tail is unsized.** Section 7.1 promises "each with an owner and a size" but only the items rulings A and B add have them (spawn_cols 1 day, strike 4, row_cannon 2, breach_plug and seal_breaches 3, tutorial UI 2, recognisers 2, capture tool 2, solver 5 = 21 days).
The older gaps (boss phases, goal phases, hidden or revealed goals, story-objective HUD text, ending events, the minigame phase runner, the shape overlay, the scene kit) have neither. These are the largest items. Add an owner and a size for each
or write "owner and size: see `engine-gaps.md` (phase 3)" and create that table. Also "qa tooling" is not an agent in the plan; use `qa-tester` or `tools-programmer`.

**G4 (V4) Campaign totals arithmetic.** U10 says "up to 24 rules (2 per biome, biome 1 up to 3)". 12 biomes at 2 rules plus the one extra in biome 1 is **25**, not 24. Fix: "up to 25 rules (2 per biome, plus 1 extra in biome 1) plus the 16 modules".
Section 7.2 repeats "up to 24 rules plus 16 modules cover 168 levels"; change both and keep the phase 3 check.

**G5 (V6, nit) Exemplar data errors.**
- `ex_forest_h1`: the footprint comment says "differs from the source's bridge span **14x8**". The source is now 12x8. Fix to "12x8".
- `ex_candy_03`: the row says `min_dead_end_width n/a`, but the bottom arm of the cross (3 rows tall, 4 wide, bounded by void on both sides and open only at the top) is a dead-end channel as defined in U7 (`ex_pirate_10`'s leg is reported as 4). Report **4**.
  The arms left and right are horizontal and are not vertical runs; the top arm is open to the spawn edge.
- `ex_candy_03`: the headline comment says "8 words"; "Keep the cake tower on its stand" is 7.
- `ex_candy_03` is a `height` level in position 03, so P2b applies. Add `p2b_note: the wobble_plate tilts toward the stack's centre, which changes how pieces are dropped`.

**G6 (V2, V5, nit) Residual drift.**
- Line 51 still says "standard controls plus at most one extra verb (shown as one gem button)". The glossary says the extra control is never called a verb. Change to "at most one `extra_control`".
- The header says "revision 6, revised after r1-r7" and lists no r8 change. Update to "revision 7, after r1-r8" and add a changelog line.
- U17 appears after U18/U19 and U15/U16 after it (the order is U14, U18, U19, U17, U15, U16). Reorder for readability.

## Build reality: rules the build cannot yet meet (flag, not a plan defect)

Unchanged from r8; today's build has 163 of 168 levels as 8x8 squares, only 9 with masks, and no `spawn_cols`, `row_cannon`, `breach_plug` or `seal_breaches` in `src/` (`defend_core` and mask parsing exist). The new shape recognisers, the uniqueness script, the P1c capture tool,
the P3d solver, the telegraph actors and the tutorial preview UI do not exist. The plan names owners and days for them (21 days for the items from rulings A and B), but the older gaps are unsized (G3).

## Exemplars: calibration score 9.5 / 10

Good: eight 9.7 exemplars cover teach, twist, boss, hard, level 01, defence and now a module-based level; every one has a `level_table` row (23 columns), unique biome footprints, and hand-verified canonical strings. Remaining: the stale and incorrect items in G5, no weak sample
for the scene fields of a module level, and no near-miss for the new footprint rules (for example a level whose declared shape name does not match its mask). Add one abridged near-miss with a mislabelled footprint so the panel sees a G2-type defect.

## Ordered fix list

1. G1: split the build ceiling by phase (spec rules at 4-5, screenshots at 7-8); remove L6 from the ceiling list.
2. G2: recogniser priority and a pointed-bow clause for `ship hull`; reword `crescent`.
3. G3: size the older engine gaps (or point to a table) and fix the owner name.
4. G4 and G5: correct 24 to 25; fix the four exemplar items; add a mislabelled-footprint near-miss.
5. G6: line 51, header revision and changelog, rule order. Optionally split the vision (rules and rubrics to their own files).

I expect V4, V5, V6 and V7 to clear 9.7 after 1-4. Re-run as r10.
