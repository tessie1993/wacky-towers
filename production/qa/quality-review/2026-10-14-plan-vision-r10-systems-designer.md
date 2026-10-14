# Plan-vision review r10: systems designer (blind, one of three)

Scope: `design/levels/plans/campaign-vision.md` (CV), `exemplars.md` (EX), `scene-vocabulary.md` (SV), `level-identity-spec.md`,
`campaign-redo-plan.md` (RP) and `reference-study-defence.md` (context only). Marked as a plan: clear, complete,
testable, internally consistent, buildable. No credit for visuals, no paper-only cap. Strict rules applied: start at 5,
earn each point with a citation, any open defect caps at 8.5, 9+ needs 3 citations and a reason it is not 10. No item
reaches 9 here, because every item has open defects.

## Scoreboard (systems designer view)

| Item | Score | Pass 9.7? | One-line reason |
|---|---|---|---|
| V1 fantasy | 8.4 | no | Pitch and paragraph are clear, but the paragraph is mixed with rule references and the tone line conflicts with a user decision |
| V2 pillars | 8.0 | no | Tests are mapped to phases, but "1 = partial" is undefined everywhere and P3d cannot fail |
| V3 campaign arc | 8.2 | no | Table is coherent, but decided items are labelled "proposed" and "Neon low" is intensity 5 |
| V4 uniqueness rules | 7.0 | no | Script input cannot support its own recognisers; several rules are ambiguous or unscripted |
| V5 level briefs | 7.8 | no | Owners, outputs and fields are present, but the script table lacks fields and the day budgets are not credible |
| V6 rubric quality | 7.8 | no | 9.7 vs 9.6 hinges on "structural vs wording"; the two scoring systems collide; partial scores undefined |
| V7 internal consistency | 7.2 | no | Stale revision header, a stale "open" item, a decided peril tone overridden, 4-vs-1 plain squares |
| Ex exemplars | 7.5 | no | Useful and mostly checked, but the 9.7 anchors break the plan's own rules in at least four places |

Mean 7.8. FAIL: every item is below 9.7.

## Arithmetic and budget checks (what adds up, what does not)

- Engine gap total: 4+3+2+2+1+5+3+40+1+4+2+3+2+2+2+5 = **81**; the last eight rows = 1+4+2+3+2+2+2+5 = **21**. CV:381 is correct.
- Rule budget: 11x2 + 3 = **25** rules (CV:253-258) is correct. 16 modules at 2 per biome (max 24) is feasible.
- Set pieces, terrains, actions: 12 x 7 = 84 and 12 x 8 = 96; 14 levels / 2 repeats = 7 minimum (CV:232, 288). Correct.
- Beats: 10 + bonus + 3 hard = 14; 168 = 12 x 14. Correct. Opening ids: 168 / 2 = 84 (CV:250). Correct.
- Verb spread, shape floor: 5 of 8 verbs and 8 of 12 shapes per biome are feasible.
- Near-miss mean: (9.3+9.0+9.0+9.3+9.2+8.5+9.0)/7 = 9.04, correct (EX:117). Weak mean 6.7.
- EX:285 says "9 words" for "Stack high so Ada can spot the sheep." It has **8**. Every other tutorial line I counted is right.
- FAILS: the scene kit (about 40 days, CV:371) covers 84-96 terrain builds + 84-96 acting animated set pieces + 24 poses +
  4-6 meters = about 200-220 assets, roughly 0.2 day each. The set-piece to action mapping is not 1:1, so acting builds could be up to 168.
  The "phase 6 buffer" (CV:380, 403) is a 20% line with no size (RP:56), so the producer's check cannot be run.
  The uniqueness script is "2 days" (CV:208, RP:130) but the recognisers add another "2 days" (CV:377) and neither is in the 81.

## Ranked defects

### D1 (critical, V4/V5/Ex). The uniqueness script cannot run its own recognisers on the table it reads
- CV:211-212 defines the table `mask` column as the **canonical string**, which is normalised to the narrower orientation (CV:198-200).
  SV:61-62 says the script checks each declared shape against "its mask", and the recognisers are orientation-dependent
  ("top to bottom", "open at the top", "tread", "bay", SV:76, 82).
- Run on the canonical form, the exemplars fail. `ex_underwater_09` (funnel 10x8) canonicalises to 8x10 with row widths 6,7,8...8,7,6
  (EX:332), which is not "non-increasing top to bottom". `ex_forest_h1` (stair 12x8) canonicalises to 8x12 with "treads" of 4,2,2 (EX:269), so "each tread 4+ wide" fails.
- Footprint `WxD` is authored un-normalised (`10x8`, EX:411) while the mask is `8x10`. `ex_forest_02` reports `min_spawn_width 10` (EX:411) but its table mask is only 8 wide.
- `spawn_cols` is not a table column (CV:211-215), yet `min_spawn_width` depends on it (CV:238-241).
- Fix (owner: tools-programmer with systems designer): add authored `mask` (orientation as played) and `spawn_cols` to the table; run recognisers and corridor widths on the authored mask; use the canonical mask only for U3/U5/U14. Normalise `WxD` as well (`max x min`) and say so in U18.

### D2 (critical, V4/V5). The script's check list leaves out columns and rules it claims to check
- CV:207-210 says the script performs "the name check", but the table (CV:211-215) has **no `name` column**.
- U12's boss triple (CV:266-268) needs `arena`, `phases`, `building_action`. The table has none (the exemplar spec has `boss_triple`, EX:226; the row at EX:415 drops it). "Verifies U12" is therefore half true.
- U8 (unique `opening_event`) is trivially scriptable and the column exists, yet U8 is not in the script list (CV:209) or the preconditions (CV:448). U10 (mechanic budget, P3c) has no `debut` or `new_mechanic` column, so it cannot be scripted, and nothing says a human checks it.
- U10 counts only rules and modules (CV:253-264); new **goals** (`seal_breaches`, CV:389; `wind_keys`, `bake_oven`) are unbudgeted, so the "one new mechanic" limit is dodged by adding a goal.
- Fix (owner: systems designer, then tools-programmer): add `name`, `boss_triple`, `debut` columns; add U8 to the script; define whether a new goal is a mechanic.

### D3 (high, V7/V3). A decided user ruling is overridden and the open list is stale
- RP:96-97 logs a user decision: "peril tone is real tension in Lava and Neon... kid-safe, no on-screen harm". CV:38-39 lists comic peril as **open/proposed** and P3 (CV:115) states "Peril (Lava, Neon) is comic and reversible" as a rule. This breaks V7 (every user decision honoured).
- CV:39-40 lists "the plan task list needs a phase 3 task for the uniqueness script" as open, but RP:130-131 already has it.
- CV:143-146 labels the ending "(proposed)", but RP:98-99 records it as a user decision (Carnival boss plus bonus; h1-h3 an optional epilogue).
- RP:62 still says "at most 4 plain-square boards per biome" against CV:233 and CV:296 ("at most 1"). Header CV:1 says "revision 7" and CV:8 says "r9 (this revision)".
- Fix (owner: game director for CV; producer for RP): reconcile P3 and the open list to RP:96; mark the ending as decided; fix the header; update RP:62.

### D4 (high, V2/V4). Several rules are untestable or contradictory as written
- **P3d (CV:110-111):** "a loss counts against the level only if no legal winning line existed". Proving no line exists is infeasible, so any bot loss can be dismissed and the 98% test never fails. State what is measured: for example a seeded solver with a fixed search budget, and the level fails if the solver wins under 98%.
- **U16 (CV:280):** "No pattern is used more than twice per biome". If `plain` counts as a pattern, 6 patterns x 2 = 12 < 14 levels, which is unsatisfiable. Say "non-plain pattern".
- **U12 (CV:265):** "tiers 01-09 and 11". There is no tier 11 (levels are 01-10, bonus, h1-h3). "Share a goal type" is ambiguous for list-valued `goal_type`. The same ambiguity hits U7 "6 distinct goal types" (CV:234).
- **U5 (CV:227-231):** the pad alignment to 12x12 is unspecified. IoU on canonical masks can swing when one cell flips the chosen orientation. IoU also ignores scale. "12 random pairs" is not reproducible between reviewers. `ex_forest_05` vs `h1` is IoU 0.77, which passes by only 0.08 although it is the same gully.
- **U6 (CV:230-231):** "2 plus dawn or dusk" for night biomes reads as 3 values, the same as the general rule, or as 2. Pick one.
- **Dead-end channel (CV:241-243):** the L leg (one side is the board edge) is counted as a dead end with width 4 (EX:224), but the bridge pillars, also bounded by void on one side only, are `n/a` (EX:412). The "open end" is not tied to gravity.
- Fix (owner: systems designer, with tools-programmer for U5 and the recognisers).

### D5 (high, V5/V4). The shape recognisers have self-contradictions and some shapes can only exist at one size
- Island chain (SV:77) needs "3+ floor components" joined by links, but a component is defined as a 4-connected region (SV:61), and links make it one. The recogniser can never fire as written.
- `stair` needs 3 distinct heights with treads 4+ wide (SV:76), so width is at least 12. `moat with centre island` (SV:73) needs 4+2+6 = 12 in both directions. `cross` needs 10 and `twin towers` 11. With sizes capped at 12x12 (SV:57) these shapes have almost no size slack. This undercuts "own shape or own size" (U18) and "own size" as an escape.
- `floating_island` is a seed terrain (SV:37), but P1b scores "the same floating island" as 0 (CV:83-84) and EX:168 calls it a defect.
- Plain "square" is defined as any full rectangle (CV:198-199) although `plain square 10x8` is named a square (EX:411).
- Fix (owner: technical artist for SV, systems designer for sizes): define link/lobe terminology; publish the legal size table per shape; decide the `floating_island` rule (legal at most once, not a P1b fail by itself).

### D6 (high, V5). The engine-gap days are not credible and are not closed
- CV:371 scene kit of 40 days against 200+ assets (see arithmetic above); no per-asset unit cost is stated.
- The script (2 days, CV:208) plus recognisers (2 days, CV:377) plus P1c tool (2 days) are in the 81 only partly; the script itself is not.
- The engine is assumed to support boards of 9-12 columns, non-8 spawn, and wide-camera framing; no gap row covers it (identity spec line 16 only says the island builder follows the mask). 
- Boss arena change (U9, CV:251-252) and module-phase levels mean the mask can change during play, but the table has one mask. State which mask counts for U3/U14/U18 and the recognisers.
- Fix (owner: producer for the buffer in days; technical artist for per-asset costs; gameplay-programmer for board-size support).

### D7 (medium, V6). The rubric will not give two reviewers the same answer
- Each pillar test scores "0 fail, 1 partial, 2 pass" (CV:69) but only P1b defines a 0; **no test defines what 1 is**. P1a (swap) and P2c (mundane) are pure judgement.
- CV:447-449 anchors 9.7 vs 9.6 on "structural vs wording"; EX:20 states "9.0 = a structural fix is needed". There is no definition of the 9.0 to 9.6 band or of 8.5.
- CV:447 (anchors from 10 down) collides with `reference-quality-bar.md` rule 1 (start at 5, earn each point). Which system does a V reviewer use?
- CV:460-464 caps are 8.0, while the quality-bar cap for an open defect is 8.5. State which wins.
- Fix (owner: game director): define 1 for every test, add a 3-4 row band table (9.7 / 9.0 / 8.5 / 8.0) with a decision procedure, and state precedence versus the quality bar.

### D8 (medium, Ex). The 9.7 exemplars break the plan's own rules
- **EX:270** `ex_forest_h1` sets `spawn_cols 4-7`, but its rows 0-1 are void in those columns (EX:261-262). CV:239-241 requires a floor run when the spawn columns hold void in the top 3 rows. Columns 8-11 would be legal. The exemplar teaching "valid" is invalid. Also `min_spawn_width` 4 is inconsistent with the 8-wide run in row 2.
- **EX:230** `ex_pirate_10` phase 3 says "higher speed ... no new idea", but CV:405-406 defines a higher speed as an idea.
- **EX:285** miscounted tutorial line (8 words, not 9).
- **EX:6-8 and CV:292-294** forbid real levels from reusing an exemplar's terrain, footprint, ending or character. Eight of the 15 terrain seeds (SV:23-30) are exemplar-only, and every ending pattern except secret and story is used by an exemplar. Read literally, real levels cannot use them. The exemplars are also "included in the U3/U14/U17/U18/U19 checks" (EX:10), so they consume a biome's plain-square, set-piece and terrain quotas (EX:421-422), contradicting "14 levels per biome".
- **EX:148-152** the near-miss ring is blamed on the notch only. The top band is 2 rows thick, so it fails the "band 3+" clause as well. "G2-type defect" (EX:152) is an undefined reference.
- **EX:298** `hud_meter: Altitude` is a bare-number gauge in a pillar that bans bare counters (U15).
- Fix (owner: game director): repair each exemplar; add an "exemplar-excluded from quotas, ids reserved" paragraph; remove `ex_`-only terrain from the seed count or label it reserved.

### D9 (medium, V4). Look and scene rules are only partly machine-checkable
- A rule action must be "one of the level's mechanic ids or an extra" (CV:89-90), but action ids (`cannon_volley`) are not mechanic ids (`strike`). SV:43-47 only gives the mapping in prose. Add an `implements` column.
- U14's fingerprint (CV:270) is trivially unique whenever masks differ, so it does not constrain look. The 1:1 set-piece to action mapping is unspecified, which breaks the "84-96 builds" count.
- `headline_objective` "no bare numeral" (CV:275) can be evaded by number words (the weak beat uses "four", EX:190-192).
- Fix (owner: tools-programmer / technical artist).

### D10 (low-medium, V3). Arc table details
- Neon is "low point... lowest morale" but its **intensity is 5** (CV:133), the same as Lava and Carnival. The text says the narrative lead must not change "Neon low" or the intensity column, yet intensity (play tension) and morale (emotional low) are conflated. P3e uses intensity for telegraph times (CV:113-114), so it must be defined as a play value.
- "Twelve Keystones" (RP:113) versus "the last key" held by Pirate (CV:135, 140). The mapping of keystone to island is not stated. (Owner: narrative lead.)
- U10 biome-1 exception (CV:255-256) is justified by the verb map, but 4 mechanics x 3 verbs can already reach 5 verbs (CV:257-258), so the exemption is unmotivated. (Owner: systems designer.)

## Per-item evidence (what was earned)

- **V1 8.4.** Earned: pitch sentence (CV:42-43); stack is the answer, "built things hold the sky together" (CV:49-50); minigame and diorama promise (CV:52-56). Not higher: rule jargon in the fantasy ("ruling B", CV:55); tone line (CV:150, 105) conflicts with RP:96; the party hero perks are only "proposed" (CV:52).
- **V2 8.0.** Earned: tests are split spec-time and build-time with named phases (CV:70-73); P1b has closed lists and 0-scores (CV:79-84); P3e has numeric telegraph times (CV:112-114). Not higher: D4 (P3d), D7 (undefined partial), P3 contradicts RP:96.
- **V3 8.2.** Earned: 12-row table with role, stakes, intensity (CV:123-136); named reversal, midpoint and recovery (CV:138-141); ending and hero-beat rules (CV:143-146). Not higher: D3 (decided items labelled proposed) and D10.
- **V4 7.0.** Earned: closed glossary and canonical-mask definition (CV:189-200); U1-U19 are numbered and ordered; the 84/96 and 25-rule arithmetic is right. Not higher: D1, D2, D4, D5, D9.
- **V5 7.8.** Earned: owners, outputs and dependencies for phases 2, 3 and 4 (CV:303, 347, 421); engine-gap table with owners and sizes that sums correctly (CV:362-381); ordered required-fields list (CV:429-436). Not higher: D2, D6; the 8.2 required fields do not all map to table columns.
- **V6 7.8.** Earned: anchor scale and caps (CV:447-464); preconditions before human scoring (CV:448-449); exemplar scores that average correctly (EX:116-121, 177). Not higher: D7; V6 requires separating 9.7 from 8.5, but 3b has no per-criterion scores (EX:123-152).
- **V7 7.2.** Earned: ruling A and B are followed throughout; supersessions are marked in the identity spec (identity spec lines 11-17, 51). Not higher: D3 and D8; the 25 vs 19 "rules" usage in the changelog (CV:10) is ambiguous.
- **Ex 7.5.** Earned: 8 complete or abridged 9.7 anchors across roles (EX:22-418), one near-miss, one script-failure near-miss, three weak samples, and a script-input table whose 23 columns match CV:211-215. Not higher: D8; the five anchors for A, C and S are one-liners only (EX:397-402).

## Concrete fixes by owner

| # | Fix | Owner |
|---|---|---|
| 1 | Table: add authored `mask`, `spawn_cols`, `name`, `boss_triple`, `debut`, `implements`; run recognisers on the authored mask; normalise `WxD` | tools-programmer + systems designer |
| 2 | Add U8 and U10 (with `debut`) to the script list and the preconditions; define whether a new goal is a mechanic | systems designer |
| 3 | Reconcile P3 peril, the "open" list, the ending label, the header revision with RP:96-99 and RP:62; update RP:62 | game director (CV), producer (RP) |
| 4 | Rewrite P3d as a measurable solver test; fix U16 "non-plain", U12 "tier 11" and list-valued goal types, U5 padding/alignment and a deterministic pair sample, U6 night wording, dead-end definition | systems designer |
| 5 | Fix the island chain recogniser; publish a legal size table per shape; settle `floating_island` | technical artist + systems designer |
| 6 | Re-price the scene kit per asset; give the buffer in days; add board-size and camera support to the gaps; state which mask counts for boss/phase levels | producer + technical artist + gameplay-programmer |
| 7 | Define score 1 for every pillar test; add a 9.7 / 9.0 / 8.5 / 8.0 band table; state precedence over the quality-bar cap and scoring method | game director |
| 8 | Repair exemplars: `h1` spawn_cols to 8-11; `ex_pirate_10` p3 idea; word count at EX:285; ring diagnosis (band 2 thick); replace Altitude meter; define the exemplar-versus-quota exclusion; label exemplar-only seeds as reserved | game director |
| 9 | Add `set_piece` to action 1:1 (or price builds by pair); cover number words in U15 | technical artist + tools-programmer |
| 10 | Separate intensity (play tension) from morale in the arc table; map keystones to islands | game director + narrative lead |
