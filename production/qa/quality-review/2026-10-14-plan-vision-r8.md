# Plan review r8: phase 1 campaign vision (revision 6), exemplars (revision 5), scene vocabulary (strict, pass mark 9.7 on every criterion)

Reviewed commit 5177c77: `design/levels/plans/campaign-vision.md`, `exemplars.md`, `scene-vocabulary.md`, against the user rulings logged in
`campaign-redo-plan.md` (A "Minigames are the level", B "scene variety is 3/10, no two levels in a biome share a footprint, at most one plain square") and my r7 fixes.
Accepted as settled, per instruction: (1) extras modify a base and do not count toward the 1-2 mechanics; (2) exemplars may show `strike` in two biomes (ids are not campaign order).

**Anchor applied.** A plan cannot score scene variety higher than the build that carries it out. I score the plan's rules on their merit, and the "Build reality" section lists
the rules the current build cannot yet meet. What I could confirm in `src/`: board masks are supported (`board_spec.gd`, `ascii_grid.gd`) and `defend_core` exists; I found no
`spawn_cols`, `row_cannon`, `breach_plug` or `seal_breaches`. 163 of 168 levels are 8x8 squares and 9 have masks, so today's build scene variety is about 3.

## Scores

| # | Criterion | r6 | r7 | r8 | Pass (>= 9.7) |
|---|---|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 9.7 | 9.7 | 9.7 | YES |
| V2 | Pillars: distinct, each with an appliable test | 9.6 | 9.6 | 9.5 | NO |
| V3 | Emotional arc: escalation, variety, ending | 9.7 | 9.7 | 9.7 | YES |
| V4 | "Every level unique" rules | 9.5 | 9.6 | 9.4 | NO |
| V5 | Briefs for narrative, systems, level teams | 9.5 | 9.5 | 9.4 | NO |
| V6 | Rubric quality (incl. exemplars as calibration) | 9.6 | 9.6 | 9.5 | NO |
| V7 | Consistency with user decisions and constraints | 9.6 | 9.7 | 9.6 | NO |
| Ex | Exemplars as calibration (supplementary) | 9.5 | 9.6 | **9.4** | NO |

Scores dipped from r7 because rulings A and B added rules (P2d, U18, U19, `mechanic`, `footprint`) that are strong in intent but not yet consistent with the older rules.

## Verdict: FAIL

V1 and V3 pass. Five criteria are below 9.7. The new rulings are well carried (the spec order, P2d, U18, U19, the footprint column, the plain-square cap of one, and the rows for all seven exemplars), but the mechanic cap
now collides with the verb and goal quotas, the shape list is a set of free labels, one exemplar exceeds the maximum board size, and the "build ceiling" anchor is not written into the rubric.

## r7 fixes: did they land?

| r7 item | Landed? | Note |
|---|---|---|
| F1 defence rule budget (shared `strike`, `row_cannon`; defence takes at most 1 of 2) | YES | In U10 and 7.3. Feasible if `strike`, `row_cannon`, `breach_plug` debut in different biomes |
| F2 P3e widened; `telegraph` field and column | YES | Both Pirate exemplars show 3 s; `ex_underwater_09` shows 3 s |
| F3 flavour/headline mismatches | YES | `ex_pirate_03` = D1 `survive`, `ex_pirate_10` = D3, `ex_forest_h1` = D4 |
| F4 defence count in U7; F7 odd-width spawn | YES | |
| F5 rows for the other four exemplars | YES | Section 9 has all seven rows; all have 22 columns in schema order |
| F6 ASCII mask and rehearsal for `ex_underwater_09` | YES | Canonical string re-verified from the ASCII below |

### Hand checks (all pass unless stated)

- `ex_underwater_09`: the ASCII has 6 full rows, `.########.`, `..######..`. Transposing gives column 0 = `######..`, column 1 = `#######.`, columns 2-7 = `########`, columns 8-9 mirror, and the given
  `8x10` string matches. Width 8 beats the flipped form (`#` < `.`). Correct.
- `ex_forest_h1` stair (12 wide, 8 high, rows `........####` x2, `....########` x2, full x4): transpose rows are `....####` x4, `..######` x4, `########` x4. Reversed and char-flipped, the smallest is
  4 x `########`, 4 x `######..`, 4 x `####....`, which equals the given `8x12` string. Correct. Spawn run (columns 4-7, the first floor row) is 4 wide. (The comment says "row 3"; it is index 2. State the indexing.)
- `ex_forest_05` `8x14` string is correct for the mask as drawn, **but the mask is 14 wide (see G3)**.
- `ex_pirate_10` L deck is its own canonical form (symmetric under transpose); leg 4 wide.
- Rows for `ex_forest_02` (plain 10x8, canonical `8x10`), `ex_pirate_03` (plain 9x9) and `ex_meadow_01` (plain 8x8) are right, and each biome has at most one plain square. Forest's three footprints (plain 10x8,
  bridge span 14x8, stair 12x8) and Pirate's two (plain 9x9, L 8x8) are distinct, so U18 holds; U17 pairs are unique; headline lengths are 5-8 words; tutorial lines are 8-10 words.

## Defects (ranked)

**G1 (V4, V5) The new-mechanic cap cannot support the verb, goal and uniqueness quotas in early biomes.** U10 now says a biome adds **at most 2 new mechanics**, where `mechanic` means "rules or modules" (section 5 definitions).
Extras are earlier-taught rules, so in biome 1 (Meadow) there is nothing earlier: the whole biome has a pool of at most 2 mechanics, which yields at most three mechanic lists ([A], [B], [A,B]) for 14 levels.
Against that pool the rules ask for: at least 5 of 8 verbs per biome (U19; the handbook maps each mechanic to the verbs it serves), at least 6 goal types (U7), 14 distinct masks (U14), and a defence level taking 1 of the 2
new mechanics (U10). The same ceiling applies to Candy (about 4 in total) and so on. Ruling A makes the mechanic "the base of each level"; with a pool this small, most of the difference between Meadow's levels comes from the
board shape, not from play. `progression.md` fix 4 and 7.4 imply a different budget (2 new rules **plus** 2 module debuts per biome). Fix wording (U10, 7.2):
> "A biome adds at most 2 new **rules** and at most 2 **module** debuts. A *mechanic* is a rule or a module. A level adds at most one new mechanic. Each mechanic serves at least 3 verbs in the handbook's verb map, so a biome
> with 4 mechanics can cover 5 verbs. Biome 1 may teach 3 rules plus 2 modules if the handbook shows the verb map reaching 5 verbs."
Also state the target total (for example 24 rules plus 16 modules across the campaign) so phase 3 can check that the inventory is big enough for 168 levels.

**G2 (V2, V5) Terminology drift: "rule", "mechanic", "module", "verb".** P3c says "adds at most one new rule"; 7.2 and 7.6 say "rule"; U10 says "mechanic"; P2d says "one `verb`" and also "at most one extra control verb" (that is the
minigame-party-rules gem button: dash, fire or grab), so "verb" means two things. There is also no spec field or column for the extra control. Fix:
> Glossary (section 5): *mechanic* = a rule or a module; *rule* = an engine rule; *module* = a minigame module; *play verb* = one of the 8 (race ... carry), field `verb`; *control* = the optional extra button (`dash`, `fire`, `grab`, or `none`),
> field `extra_control`. Use these words everywhere. Add `extra_control` to the 8.2 fields and the `level_table` columns. P3c and 7.2/7.6 say "mechanic" where they now say "rule".

**G3 (V4, V6) `ex_forest_05` exceeds the maximum board size and breaks U5.** The mask is 14 wide (footprint "bridge span 14x8"). The identity spec caps shapes at 12x12, and U5 pads canonical masks to 12x12 to compute IoU, which cannot hold a 14-wide mask.
Fix either way: (a) shrink the exemplar to 12 wide (`####....####`, a 4-cell gap) and update `gap 4 cells`, the footprint (`bridge span 12x8`), the canonical string (`8x12`) and the row; or (b) raise the cap to 14x14 and change U5 to pad to 14x14 and the vocabulary to say so. Option (a) is cheaper.

**G4 (V4) Shape names are free labels.** U18 compares `shape WxD` text and requires at least 8 names per biome, but `scene-vocabulary.md` lists 12 names with no definition ("stair", "ship hull", "crescent", "island chain" can mean anything).
A spec can label an arbitrary mask "ring 10x10". The IoU test (U5) catches near-duplicates, not mislabelling, and the shape-name count is gameable. Fix: add one testable recogniser per shape, for example
> `ring`: one hole, no notches, band 3+; `bridge span`: two floor blocks joined by one band at least 3 deep with a void gap above it; `stair`: monotone steps, each tread at least 4 wide; `island chain`: 3+ components joined by 3-wide links;
> `funnel`: rows narrow monotonically toward the bottom; `L`, `cross`, `crescent`, `twin towers`, `ship hull`, `moat with centre island`: likewise.
The script verifies each declared name against its mask. Also extend the U7 corridor sentence from "ring, moat, crescent, stair, funnel or island chain" to **every shape in the list** (cross, twin towers, L, bridge span, ship hull are missing; the vocabulary already says "every shape keeps the corridor rule").

**G5 (V2) P1b and P2d disagree about the HUD meter.** P1b: the meter is optional and "an empty meter is not a defect". P2d: "a themed meter or an explicit 'no meter fits'". Fix P1b to: "`scene.hud_meter` names the meter or says `no meter fits`; a blank field scores 0".
Also fix the `ex_forest_05` row's `mechanic`: the level uses the `gap_runner` module (its `minigame_block` and `span` goal) but `mechanic: [vines]` omits it. Under the vision's own definition a module is a mechanic, so it should be `[gap_runner, vines]`
(two mechanics, within the cap), with `gust` as an extra. The same goes for the `ex_forest_h1` row (`span` is the module's goal).

**G6 (V5) The engine-gap list (7.1) lacks the items rulings A and B add.** 7.1 names boss phases, goal phases, hidden/revealed goals, story-objective HUD text, ending events, the minigame phase runner, the shape overlay and the scene kit.
Not named, and not found in `src/`: `spawn_cols`, the `strike` family, `row_cannon`, `breach_plug`, the `seal_breaches` goal, telegraph actors, the per-level tutorial preview and 12-word line UI, the shape recognisers, the P1c segmentation-mask capture tool and the P3d solver. (`defend_core` and mask parsing exist.)
Add them to 7.1 with an owner and a size each, and have the producer report them against the phase 6 buffer.

**G7 (V6, V7) The user's build-ceiling anchor is not in the rubric.** Section 9's caps say "a grid of squares is a 3, not a 9" for a biome with a repeated footprint, but nothing stops a plan review from scoring scene variety 9+ while the build is still 163 squares.
Add to Caps:
> **Build ceiling.** Scene-variety items (L6, A1, A-build, C4, C5) are judged on evidence: a plan is scored on its rules and a spec on its fields, but no item may be scored above what the retained screenshots show of the build.
> While a built biome still has more than one plain square or any two levels with the same footprint, L6, A-build and C4 for that biome are capped at 3. A phase gate may not claim scene variety passes on the plan alone.

**G8 (V7, nit) Superseded lines in the identity spec.** The vision says U7 supersedes the identity spec's "at most 4 plain squares"; mark that line (struck through, as was done for `clear_n` and the set pieces). I could not confirm it has been marked.

## Build reality: rules the build cannot yet meet (flag, not a plan defect)

| Rule | State of the build |
|---|---|
| U18 footprints (8+ shapes per biome, at most 1 plain square, size up to 12x12) | Masks exist, but only 9 of 168 levels use one; at least 96 masks must be authored; shape recognisers do not exist |
| U7 `spawn_cols` and corridor columns | No `spawn_cols` in `src/`; needs engine support and a script |
| U17/P1b/P1c scene kit (terrain, acting set pieces, cast poses, themed meters) | Not built (phase 6 task; budget in 7.5) |
| P3e telegraph actors; `strike`, `row_cannon`, `breach_plug`, `seal_breaches` | `defend_core` exists; the rest are absent |
| U16 / goal phases / reveals; P3d solver; P1c capture mask | Not built |
| Script `check_level_uniqueness.gd` | Not built (phase 3, 2 days); it also needs a recogniser per shape (G4) |
Until these exist, the build's scene variety stays near 3, as the user ruled. The plan's rules are what the build must grow into.

## Exemplars: calibration score 9.4 / 10

Strong: every 9.7 exemplar starts from `mechanic` and `verb`, shows its own `footprint`, has a table row, passes the checks I could compute by hand (canonical strings, plain-square counts, unique pairs and shapes per biome), and the near-miss and weak
samples carry the new defects (a repeated plain square, no mechanic or verb). Remaining: `ex_forest_05` is 14 wide (G3), two exemplars omit the module they use from `mechanic` (G5), the header's `row 3` indexing note on `ex_forest_h1` (0 vs 1 index),
and there is still no exemplar where the base is a **module** rather than a rule (for instance a `gap_runner` level), which is the form ruling A most relies on. Add one abridged module-based exemplar.

## Ordered fix list

1. G1: reconcile U10 with the verb, goal and uniqueness quotas (2 rules plus 2 modules, verb map of 3+ per mechanic, campaign totals).
2. G2: add the glossary and `extra_control`; use "mechanic" throughout; fix P1b/P2d.
3. G3 and G5: bring `ex_forest_05` to 12 wide; list `gap_runner` in the `mechanic` of `ex_forest_05` and `ex_forest_h1`; add a module-based exemplar.
4. G4: shape recognisers in `scene-vocabulary.md`; extend the corridor sentence to all shapes.
5. G6 and G7: add the missing engine gaps to 7.1; write the build-ceiling cap into section 9. Then G8.

After 1-4 I expect V2, V4, V5 and V6 to clear 9.7; V7 clears with fix 5. Re-run as r9.
