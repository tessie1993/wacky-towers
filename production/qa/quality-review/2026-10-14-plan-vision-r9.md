# Plan review r9: phase 1 campaign vision (header still "revision 6"), exemplars (revision 6), scene vocabulary

**Strict marking rules applied (user, 2026-10-14, `.claude/docs/reference-quality-bar.md` "Stricter marking", all 8 rules):** every item starts at 5 and earns points only with cited evidence; 9.0+ would need 3 cited
pieces of evidence and a reason it is not 10 (nothing here reaches 9.0); any open defect caps an item at 8.5; paper-only player-facing qualities cap at 7; sub-items are scored separately and the lowest open sub-item governs;
when unsure I took the lower score; 9.6 is a fail. The r7 and r8 scores in the history column were given under the earlier rules, so the drops below are the new rules at work, not regressions (no score rose, so rule 5 does not trigger).

**Interpretation I applied, flagged for the coordinator:** V1 (campaign fantasy) and V3 (emotional arc) describe what the *player* feels and exist only on paper, so I applied the "paper-only player-facing, at most 7" cap to them.
V2, V4, V5, V6 and V7 score the vision as a design document (testability, consistency, completeness), so the paper cap does not apply, but the open-defect cap (8.5) does. If you want V1/V3 judged as document clarity instead, tell me and I will re-score them
(they would be capped by the open defects in G6 and A1 below, at 8.5).

Reviewed commit e75a4f5: `design/levels/plans/campaign-vision.md` (489 lines), `exemplars.md`, `scene-vocabulary.md`, against rulings A and B, the build-ceiling anchor, and my r8 fixes. Method: I re-derived every mask, canonical
string and recogniser clause by hand, counted `level_table` columns, and re-read the whole vision for drift.

## Scores

| # | Criterion | r8 (old rules) | r9 | Cap that applied | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.7 | **7.0** | paper-only player-facing (7) | NO |
| V2 | Pillars: distinct, each with an appliable test | 9.5 | **8.5** | open defects (8.5) | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.7 | **7.0** | paper-only player-facing (7) | NO |
| V4 | "Every level unique" rules | 9.4 | **8.0** | open defects G2, G4 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.4 | **8.0** | open defects G3, G4 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.5 | **7.5** | G1 makes gates unpassable | NO |
| V7 | Consistency with user decisions and constraints | 9.6 | **8.0** | G1 misapplies the user's anchor | NO |
| Ex | Exemplars as calibration (supplementary) | 9.4 | **8.0** | open defects G5 | NO |

### Sub-item scores (rule 6; evidence from file and line)

| Criterion | Sub-item | Score | Evidence for the points | Why not higher |
|---|---|---|---|---|
| V1 | Pitch and stacking-is-canon | 7.0 | vision lines 33-34 (pitch), 36-39 ("built things hold the sky together"), 41-45 (ruling A: "every level is a minigame") | Paper only, cap 7; section 1 does not mention footprint variety (ruling B) |
| V2 | P1 scene tests | 8.5 | lines 62-78: P1a swap, P1b fields incl. meter rule (agrees with P2d), P1c 60% pixels | P1c needs a capture tool that does not exist; line 51 still says "extra verb" |
| V2 | P2 tests | 8.5 | lines 80-90: P2a-P2d, P2d names mechanic, verb, 12-word line, `extra_control` | `ex_candy_03` omits its P2b note |
| V2 | P3 tests | 8.0 | lines 92-102: P3a-P3e; P3e telegraph 2 s / 4 s | P3a and P3d need players and a solver that are not built; unsized (G3) |
| V3 | Arc table, stakes, ending | 7.0 | lines 110-133: 12 rows with intensity 2,3,2,3,5,2,3,4,5,3,4,5; first reversal chapter 5; Neon low chapter 9; ending proposed | Paper only, cap 7; stakes and ending are "proposed" |
| V4 | Definitions and glossary | 8.5 | lines 176-202: glossary, canonical mask, footprint, `level_table` of 23 columns | Footprint names depend on recognisers that overlap (G2) |
| V4 | Uniqueness rules U3, U14, U17, U18, U19 | 8.5 | lines 207-276; rows in `exemplars.md` section 9 pass by hand | Unscripted (script not built) |
| V4 | Shape recognisers | 8.0 | `scene-vocabulary.md` lines 64-77 | `funnel` and `ship hull` match the same mask; `crescent` wording contradicts itself |
| V4 | U10 budget | 8.0 | lines 240-250: 2 rules plus 2 modules, 3+ verbs per mechanic | Totals say 24 rules; the stated rule gives 25 (G4) |
| V5 | Narrative brief | 8.5 | lines 291-315: YAML schema, `verb`, 5 of 8 verbs, `opening_event` ids 84+ | Header stale; no open defect beyond that |
| V5 | Systems brief | 8.0 | lines 341-390: engine gaps with owners and 21 days for ruling A/B items | Older gaps unsized, "qa tooling" is not an agent (G3) |
| V5 | Level brief | 8.5 | lines 394-414: fields in order, `mechanic` and `verb` first | Depends on unbuilt script |
| V6 | Rubric structure | 8.0 | lines 418-441 (scoring, caps, calibration), 443-488 (N, M, L, A, B, C, S with "9.7 means") | Build ceiling cap is structurally wrong (G1) |
| V6 | Build ceiling | 6.0 | lines 436-440 | It lists L6 (a spec criterion), so phases 4-5 can never reach 9.7 and phase 6 can never start (G1) |
| V6 | Exemplars as anchors | 8.0 | `exemplars.md`: eight 9.7 exemplars, near-miss, three weak samples, A/C/S one-liners | Data errors (G5); no mislabelled-footprint near-miss |
| V7 | Rulings A, B, plain-square cap, Pirate 11th, no-beige/IP | 8.5 | lines 10-15 (rulings), 17 (order), 220-222 (at most 1 plain square), 150-166 (hard rules) | |
| V7 | Build-ceiling anchor | 6.0 | line 436-440 | Intent right, implementation deadlocks gates (G1) |

No criterion reaches 9.0, so rule 2's three-evidence requirement is not triggered; no score rose, so rule 5 is not triggered.

## Verdict: FAIL

All eight items are below 9.7; none came within 1.2 of the pass mark under the strict rules. All five r8 fixes landed and are sound in substance, but the blocking item is structural: the build-ceiling cap as written makes the phase 4 and 5 gates impossible
to pass (G1), and several rules are still gameable or miscounted (G2, G4).

## r8 fixes: did they land?

| r8 item | Landed? | Note |
|---|---|---|
| G1 U10: 2 rules plus 2 module debuts, 3+ verbs per mechanic, campaign totals | YES | Totals arithmetic wrong (G4) |
| G2 glossary, `extra_control`, P1b/P2d meter | YES | Line 51 still says "extra verb" (G6) |
| G3 `ex_forest_05` to 12 wide; `gap_runner` in `mechanic`; module exemplar | YES | `ex_candy_03` added; stale note in `ex_forest_h1` (G5) |
| G4 recognisers for all 12 shapes; corridor sentence for every shape | YES | Two recognisers overlap (G2) |
| G5 engine gaps with owners and days; build-ceiling cap; old rule struck | MOSTLY | New gaps sized; older gaps not; cap deadlocks the gates (G1, G3) |

### Hand checks (all pass unless listed under defects)

- `ex_forest_05` (12x8 `bridge span`): columns 0-3 give 4 solid rows, columns 4-7 give `#####...` x4, columns 8-11 give 4 solid rows; the `8x12` string is the smallest orientation. Recogniser holds (gap 4 wide, 3 rows deep, pillars 4 wide, base 5 deep);
  `spawn_cols: 0-3` is right (centre columns 4-7 are void).
- `ex_forest_h1` stair: heights 4, 6, 8 (3 distinct, monotone), treads 4 wide; canonical string correct. `ex_candy_03` cross 10x10: corners 3x3, arms 4 wide, symmetric; spawn columns 3-6 floor; 23-column row.
- `ex_underwater_09` funnel: widths 10,10,10,10,10,10,8,6; `ex_pirate_10` L: 8x8 minus a 4x4 corner. Biome footprints: Forest = plain 10x8, bridge span 12x8, stair 12x8; Pirate = plain 9x9, L 8x8.

## Does the length matter? (489 lines against the old 340)

Mildly. Length is where drift enters: this pass found a stale phrase (line 51), a stale number (`14x8`), an arithmetic slip (24 vs 25), and a header that still says "revision 6". Sections 5 (rules, about 115 lines) and 9 (rubrics, about 75 lines) are reference material.
Recommendation (not a blocker): keep sections 1-4 plus a one-page summary of U1-U19 in the vision and move the full rules and rubrics to `level-rules.md` and `review-rubrics.md`. Until then, add a table of contents with rule numbers and a changelog line per revision.

## Open defects (ranked)

**G1 (V6, V7) The build-ceiling cap makes phases 4 and 5 impossible to pass.** Section 9 ("Build ceiling", lines 436-440) says no item may be scored above what retained screenshots show, and caps L6, A-build and C4 at 3 for a built biome with a repeated footprint or
more than one plain square. But **L6 is a phase 4 (spec) criterion** and A1 a phase 5 one, judged before any build exists (phase 6 builds and depends on 5). Read literally, L6 can never exceed what screenshots show (today 163 of 168 levels are squares, about 3), so
phases 4 and 5 cannot pass and phase 6 cannot start. The same condition also gets two caps (L6 and A1 at 8.0 under "Caps", L6 at 3 under "Build ceiling"). Fix:
> **Build ceiling.** Scene variety is scored in two places. **Phases 4-5 (L6, A1, A-spec)** score the *rules and fields* (footprints, shapes, scene fields, recogniser results), state "plan only: the current build still has N squares", and may not claim the build is varied.
> **Phases 7-8 (A-build, C4, C5)** score screenshots: for a built biome with more than one plain square or any shared footprint, A-build and C4 are capped at 3, and no item scores above what the retained screenshots show. Remove L6 from the ceiling list;
> keep the 8.0 cap for specs with a repeated footprint. Under the stricter marking rules, a phase 4-5 item that describes a player-facing quality on paper is itself capped at 7; the phase 4-5 gates therefore need their own bar for plans: "9.7 on every
> *document* criterion (consistency, testability, completeness)", with player-facing qualities judged at phases 7-8.
(That last sentence resolves a second deadlock created by the new marking rules: a paper-only plan can never score above 7 on player-facing items, so the gates must state which items are document items.)

**G2 (V4) Two shape recognisers overlap.** `funnel` and `ship hull` match the same masks (`ex_underwater_09` satisfies both), so one mask can be counted as two names toward the "8 different names per biome" quota (U18), and the script checks only that a
declared name matches. Fix: "A mask must match exactly one recogniser; when two match, the earlier row names it (priority: plain square, ring, moat, cross, L, stair, bridge span, twin towers, crescent, island chain, funnel, ship hull). `ship hull` also requires a pointed bow
(end rows narrowing to 2 or fewer cells over at least 3 rows) and a flat stern." Reword `crescent`: "one bay bounded by floor on three sides and open on the fourth by 3+ cells" (the current text says "enclosed" and "open").

**G3 (V5) The engine-gap tail is unsized.** Section 7.1 promises an owner and size for each gap but only the ruling A/B items have them (spawn_cols 1 day, strike 4, row_cannon 2, breach_plug and seal_breaches 3, tutorial UI 2, recognisers 2, capture tool 2, solver 5 = 21 days).
Boss phases, goal phases, hidden or revealed goals, story-objective HUD text, ending events, the phase runner, the shape overlay and the scene kit have neither. Add owner and size for each (or point to an `engine-gaps.md` table), and replace "qa tooling" (not an agent) with `qa-tester` or `tools-programmer`.

**G4 (V4) Campaign totals arithmetic.** U10 and 7.2 say "up to 24 rules (2 per biome, biome 1 up to 3)". 12 x 2 plus 1 extra is **25**. Fix both places: "up to 25 rules plus 16 modules", and keep the phase 3 check that this inventory can cover 168 levels with unique `(goal list, mechanic list, mask)` triples.

**G5 (V6, Ex) Exemplar data errors.** (a) `ex_forest_h1` comment says "differs from the source's bridge span **14x8**"; the source is 12x8. (b) `ex_candy_03` row has `min_dead_end_width n/a`, but its bottom arm (4 wide, bounded by void on both sides, open only at the top) is a dead-end channel
as U7 defines it (`ex_pirate_10`'s leg is reported as 4); report 4. (c) `ex_candy_03` headline comment says "8 words"; it has 7. (d) `ex_candy_03` is a `height` level at position 03, so P2b applies; add a `p2b_note`. (e) Add a near-miss with a **mislabelled footprint** so the panel
sees a G2-type defect.

**G6 (V2, V5, nit) Residual drift.** Line 51 still says "at most one extra verb"; change to "at most one `extra_control`". The header should read "revision 7, after r1-r8" with a changelog line. Rules appear in the order U14, U18, U19, U17, U15, U16; reorder.

**A1 (V1) The fantasy omits ruling B.** Section 1 says "small diorama (a gully, a fort wall, a raft)" but never says that boards take many shapes (ring, bridge, stair, island chain, hull). That is the user's 3/10 complaint, and the player-facing fantasy should name it. Add: "No two levels in an island share a footprint: you build on bridges, rings, stairs and ship decks, not one square."

## Build reality: rules the build cannot yet meet (flag)

163 of 168 levels are 8x8 squares and 9 have masks, so today's scene variety is about 3. In `src/` I found mask parsing and `defend_core`, and no `spawn_cols`, `row_cannon`, `breach_plug` or `seal_breaches`. The shape recognisers, the uniqueness script, the P1c capture tool, the P3d solver,
the telegraph actors and the tutorial preview UI do not exist. Under rule 3 ("a plan cannot score more than the build that carries it out") this is why V1 and V3 sit at 7.

## Ordered fix list

1. G1: split the build ceiling by phase; remove L6 from it; give phases 4-5 a document-item bar.
2. G2: recogniser priority and `ship hull` bow clause; reword `crescent`.
3. G3 and G4: size the older engine gaps, fix the owner name, correct 24 to 25 in U10 and 7.2.
4. G5: fix the five exemplar items and add the mislabelled-footprint near-miss.
5. G6 and A1: line 51, header and changelog, rule order, and one sentence on footprint variety in the fantasy. Optionally split the vision.

Even with all of these fixed, V1 and V3 cannot exceed 7 until the arc and fantasy are built and captured (phases 7-8). I need the coordinator's ruling on whether they should be judged as document items at this gate.
