# Quality review, round 1: Special Blocks and Objects GDD (game designer, blind expert)

Reviewer: game designer (one of three blind experts; no other review was read).
Item: `design/gdd/special-blocks-and-objects.md` (1682 lines, 112 specials claimed).
Marked as a PLAN (clear, complete, testable, consistent, buildable, will make great levels), per
`.claude/docs/reference-quality-bar.md` "Mark each thing for what it is". Stricter marking applied: start at 5, earn
each point with a citation, any open defect caps at 8.5, ties go to the lower score, pass mark 9.7.
Appendix E (`special-blocks-and-objects.md:1673-1681`) is treated as binding.

Inputs read: the GDD in full; `design/levels/levels.md`; `design/levels/plans/level-identity-spec.md`;
`design/levels/plans/reference-minigames-catalog.md` (summary table, gaps, section 5); `assets/data/content/blocks.json`
(24 kinds, confirmed); `assets/data/shapes/families.json` (10 families, confirmed); `design/levels/plans/underwater.md`
(spot check of the biome fit claims).

## 1. Scoreboard (game designer)

| Item | Score | Pass 9.7? | One-line reason |
|---|---|---|---|
| P1 Fun and variety of the specials | 7.0 | FAIL | Wide and well-themed set, but a third of the shape powers are stakes-free bonuses and goo has no real threat. |
| P2 Readability (0.5 s) and teachability | 6.5 | FAIL | Three-signal read test is a good rule, but no badge sheet proves it; several look collisions are in the text itself. |
| P3 Fit to the minigames and levels | 5.5 | FAIL | The doc breaks its own F1 budget on 3 of the first 12 levels; 11 biomes are design intent only; no minigame traceability. |
| P4 Fairness and counterplay | 6.5 | FAIL | Telegraph and clear-answer rules are strong; several counterplays are unbuilt, unpriced or wrong. |
| P5 Completeness of the catalogue | 6.0 | FAIL | Core engine rules covered; 3 of the catalogue's own engine gaps are missing; the index and Appendix D counts cannot be reproduced. |
| P6 Consistency with the user rules | 5.0 | FAIL | Body text still follows the superseded recommendations on 3 of the 4 binding Appendix E decisions. |

Overall: FAIL on every sub-item. No sub-item reaches 9.0, so no 3-citation proof for a high score is claimed. Each
score below is the evidence-supported figure; where I was unsure I took the lower number.

Why no item is near 10: the document is a thorough first draft (strong per-entry template, a real interaction
matrix, formulas with worked examples, 33 acceptance checks) but it is explicitly "DRAFT v1" with its own listed
weak spots (`:3`, `:12`), 14 unresolved `ART-CHECK` tags in the body, and body text that was never reconciled with
the decisions the user made after it was written (`:1673-1681`).

## 2. Ranked defects

Severity: S1 blocks sign-off (breaks a binding decision or the doc's own gate), S2 will cause a bad level or a
wrong build, S3 polish or hygiene. IDs are used in the fix table.

### S1. Blocks sign-off

**D1. The body contradicts three binding Appendix E decisions (P6, P3).**
- Items in Chapter 1. Appendix E: "Chapter 1 uses character skills only" and items unlock "From Chapter 2"
  (`:1679-1680`). But the first-12 mapping offers IT-15 Rewind in meadow_06 (`:1544`), and the item entries place
  IT-14 Shield Bubble in "meadow_02, 05, 10" (`:1117`) and IT-16 Grip in "meadow_08, 09" (`:1139`). The mapping
  header still says "Items are off in the campaign ... so only skills apply" (`:1535`) and F8 says "items off ... only
  if the user rules so" (`:1322`). So the body neither follows nor even states the user's ruling, and no table says
  which item unlocks in which Chapter 2 level or at what `p_item`.
- Teach levels keep core objects only. Appendix E: "The teach levels 01-10 keep the core objects only" (`:1675-1676`).
  The mapping adds optional BK-25 ghost piece and BK-21 shelf to meadow_07 (`:1545`), and optional IT-15 to
  meadow_06 (`:1544`). Both are non-core specials in teach levels.
- Hard-level remix. Appendix E: meadow_h2 and meadow_h3 each add one existing special kind (`:1675-1676`). Table 8.1
  has no h2 or h3 row (`:1537-1550`); the only mentions are two loose suggestions (`:221`, `:242`) and F1's index
  note (`:1215`). The user's one concrete Chapter 1 instruction is therefore not designed. The h2 and h3 choice
  should be the doc's best showcase of the existing kinds (mushroom, egg, sprout, pest) and it is missing.
- Clock hazards. Appendix E: "Hidden timer. Millisecond schedules stay" (`:1677-1678`). The body still proposes
  `schedule_mode: locks` as the fix (`:790`, `:1631`), and Edge Case/Acceptance 23 mixes "1 lock or 2000 ms"
  without saying which applies to a hidden-clock level (`:1519`).

**D2. The doc fails its own F1 special budget on the first 12 levels (P3, P6).**
- F1: `A_max(n) = min(A_cap, 1 + floor((n-1)/3))` and `new_specials(n) <= 1` (`:1211`). That gives 1 active special for
  n = 1 to 3 (`:1220`).
- The mapping lists meadow_02 with defend core + gust + edge attacker, and meadow_03 with cargo + track events +
  finish marker (`:1539-1541`), and the budget check scores them "2" (`:1552`). 2 is greater than A_max(2) = 1 and
  A_max(3) = 1. meadow_05 introduces stone throw AND hedge wall together (`:1543`) but the F1 example calls that
  "Correct" (`:1220`) although new_specials would be 2. meadow_04 introduces herd, pen and gates at once (`:1542`).
- The line "All within F1 except the bonus" (`:1552`) is therefore false. Acceptance 24 ("no level has more than
  `A_max(n)` ... or more than 1 new special", `:1520`) would fail the doc's own mapping on levels 02, 03, 04 and 05.
- Either the budget is wrong (the frame, `levels.md:455-468`, shows exactly one New thing per level, so the formula
  matches the frame and the mapping is what over-counts) or the count rule needs to say which sub-objects (attacker
  prop, finish marker, pen gate) are scenery and cost nothing. The doc does neither.

**D3. Wrong or dangling cross-references that would send a maker to the wrong entry (P5, P2).**
- SH-01 and SH-05 say the peg and hang point are "OB-14, OB-15" and "OB-16" (`:82`, `:104`). In the catalogue OB-14 is
  lava lid, OB-15 quake, OB-16 geyser vent (`:783`). The peg, pillar and hang point are BK-40, BK-41, BK-42
  (`:634`, `:645`, `:656`).
- SH-11 says "with the egg object (OB-02)" (`:174`). OB-02 is wind gust (`:684`); the egg is BK-03.
- BK-20 says "the key cube (BK-24) is the planned stronger opener (see there)" (`:410`). BK-24 is the wind-up key
  piece and has no opener rule (`:454-463`). R-8 and R-10 also protect a "key cube" (`:1183`, `:1185`), and the
  overview lists "key" as a block kind (`:18`), but no key cube kind exists anywhere in the catalogue.
- BK-07 sends the reader to "Edge Cases: unsupported goo" (`:272`); section 5 has no such case (`:1366-1406`).
- BK-09 sends the reader to "Open question 5" for sticky gumdrops (`:304`); Open Question 5 is "what next"
  (`:1642`). The matrix also sends ice stacking to "see matrix" (`:250`).
- `:48` and `:70` refer to "the index" with `*` marks; no index table exists in the file.
- Appendix D claims 112 entries (12 + 45 + 39 + 16, `:1665-1669`) but the file has 14 SH ids, 42 BK ids, 39 OB ids
  and 16 IT ids, with group entries (SH-01 to 03, IT-05 to 08, OB-13 to 16) that the counting rule at `:70` does not
  resolve. The headline "112" cannot be reproduced by a reader.

### S2. Will cause a bad level or a wrong build

**D4. Goo has no real threat and a degenerate answer: feed it (P1, P4).**
- Goo cells are `fills_layer: true` (`blocks.json:89`) and BK-07 says so on purpose: "goo can fill a layer cell and
  count for a clear" (`:272`). It "does not slow pieces today" (`:272`). It spreads to any free neighbour "including
  mid-air" (`:272`) and the cap at 12 cells bounds it (`:1279`).
- So goo spreading into a layer's empty cells is free layer fill, which helps the player. The only harm is unsupported
  overhangs that cover holes, and that case is cited to an edge case that does not exist (D3). The matrix columns
  assume a sticky goo ("sticky wins", `:1159`, `:1161`, R-2/Sticky beats motion `:1172`) that the engine does not have
  (`:298`, `:272`). F5 even states the clear-cancel is "a bonus" and the cap does the work (`:1279`), so the "naughty,
  not cruel" fantasy (`:39`) has no designed edge: goo is either harmless or an unfair overhang.
- Fix by deciding goo's one job: sticky landing (a piece that rests on goo locks at once, honey-style) with
  `fills_layer: false` while goo, so it blocks a layer until a neighbour clear removes it.

**D5. Ring, hook, claw and jack powers are stakes-free bonuses, and two are mis-taught (P1, P3, P4).**
- SH-01's reward for a fit is that the piece "locks one lock-delay early with a ring chime" (`:82`). SH-05's hang gives
  an `anchored` status for 4 locks and "never blocks a win" (`:104`, `:109`). SH-06's grip is "pure bonus" (`:121`).
  Nothing in the player's goals or score depends on them, so a player gains nothing from learning them (SDT
  competence needs a visible reason to master). `peg` goals are mentioned only as a validator condition
  (`:641`) with no goal definition, no scoring, no "ring toss" win condition.
- SH-01 is also internally inconsistent: "`fills_layer` for the pocket cell stays false until filled, so a layer with
  a ring-pocket cannot clear until the pocket holds something" (`:82`). By the doc's own convention 4, `fills_layer`
  false means the cell is excluded from the denominator (`:64`), i.e. the layer CAN clear. A programmer cannot
  implement both. The 8-cube ring is the biggest hole-maker in the bag, and its only safety net is a solver check
  that does not exist yet (G5, `:87`).
- SH-06 is taught as "your claw answers the crab's claw" (`:119`). The crab claw removes a cube from a column
  (`:774`); a gripped piece is immune to a gust or bounce push (`:115`). The grip does not answer the crab. The
  teaching metaphor trains the wrong lesson. Also, `plans/underwater.md:59,75` introduces the claw at level 02, the
  GDD teaches it at 04 (`:778`), and the plan's claw uses a 2500 ms warning against the GDD default 2000
  (`:774`).
- SH-13 rocket's trigger is a double tap on the drop button (`:191`), but hard drop already exists on that button,
  and the verb only exists when a rocket happens to fall, so it cannot be learned reliably (`:192`, `:198`).

**D6. Fairness counterplays that are unbuilt, unpriced or wrong (P4).**
- Many "Counterplay" lines are NEW features that appear in no schedule: blast preview outline (`:359`, `:1020`), hop-end
  ghost (`:256`), slide-end ghost (`:587`, `:813`), shaft preview (`:506`), rise-end preview (`:495`), hint arrow for
  moody (`:348`), tilt landing preview (`:164`, `:713`), spawn warning for goo (`:278`). The level plan depends on
  them: meadow_08 is "a little wild" without the hop ghost (`levels.md:300`), and meadow_09's first heavy piece
  tips the plate "at once" without the tilt preview (`:164`). None has an owner and day count in a single place, so
  no producer can see the total UI bill.
- Countdown bomb defaults are not self-balancing. F6 says 7 of 10 bombs need an aimed clear (`:1293`). With
  `thrown_every_locks` 8 and `cd_start` 8 (`:1448`), about one bomb is live at a time and about 71 percent of
  them add a junk layer, roughly one junk layer per 11 locks, against a steady-play clear every ~12 locks
  (P_eff, `:1246`; c = 0.083, `:1274`). Junk makes the stack rise (`:1482`). The doc calls these "calm starter
  values" (`:1236`) but its own numbers say the unaimed stack climbs.
- Heavy shapes: F7's example shows 3 heavy cubes already move tau from 143 to 455 (`:1307`). One `big_cube`
  (8 cubes at weight 2) or a 27-cube `giant_mega_cube` lands far more weight than that; the spawn gate in F10 only
  covers giant shapes by height fraction (`:1346`), and SH-10 does not cite it (`:157-166`).
- Hidden timer plus a 35 s lava rise (`:785`) is a clock the player cannot see. Telegraphs exist, but there is no
  assist rule (pause, slower option) and no accessibility acceptance check for ms-based hazards (`:1519`,
  `:1528-1532`).
- BK-10 says frosting "waits until peeled" while the layer "clears around it" (`:309`) and then lists the risk "a
  layer that never clears" (`:314`). BK-20 says "A locked cube blocks its layer until opened" (`:415`) but needs an
  adjacent clear to open (`:410`); a locked cube in a lone layer is a deadlock with no edge case.

**D7. Readability: the 0.5 s test is claimed but not demonstrated, and some looks collide (P2).**
- Convention 1 requires a silhouette change, a looping animation and a rim colour role, plus "a distinct icon badge"
  (`:61`). Edge case 29 claims "every special has a badge shape that is unique across the set" (`:1405`). No badge
  list or sheet exists; only about a third of the entries name a badge. Acceptance 4 and 32 are manual and
  unspecified for 112 items (`:1494`, `:1530`).
- Collisions inside the text: frozen shell "snowflake badge" (`:442`) and ice cube "snowflake badge" (`:582`), which
  behave differently (extra hit point vs. slippery). Vines "leaf badge" (`:442`) while Appendix A says every cube on
  the HUD board already wears a sprout leaf and "a special's badge must differ from it" (`:1613`). The ice biome's
  baseline hero ornament is already a snowflake (`:1561`).
- Four translucent-identity pieces (ghost, bubble, jelly, rainbow) rely on a sheen to tell them apart (`:468`, `:490`,
  `:534`, `:512`), and convention 1 says surface texture alone never counts (`:61`). In candy, gumdrop, candy bomb,
  countdown bomb and the jelly piece are all round glossy things with a fuse or digit (`:299`, `:354`, `:365`).
- Colour roles overlap: candy bomb gets a "pulsing orange rim (hazard-reward)" (`:354`), mixing the hazard and
  reward roles the convention keeps apart (`:61`).

**D8. Biome fit is intent only, and the minigame link is untraceable (P3, P5).**
- The work log admits lava, desert, carnival, pirate and clockwork "Fits" lines are design intent, not cited to a
  level (`:12`), and the basis list (`:26`) omits the biome plans (`design/levels/plans/lava.md`, `cave.md`,
  `clockwork.md`, `underwater.md`). The spot check on underwater found a mismatch (D5), and `plans/underwater.md:41`
  already lists its needs (Submarine Salvage, Coral Conduit) with no counterpart in the GDD.
- The catalogue file defines 101 minigames with ids M01 to M94 and M200 or more (`reference-minigames-catalog.md:19-103`,
  `:386-396`). The GDD never cites an M-id (0 matches); it cites board files whose own attributions it says may be
  "shifted by one or two files" (`:1619`), so every `Source` line is unverified. It also cites `mockup_06` three
  times (`:748`, `:983`, `:1575`) although the catalogue says to ignore that board for a third-party logo
  (`reference-minigames-catalog.md:216`).
- There is no matrix of "minigame -> specials it needs" and no check that each of the 101 has an answer.

**D9. Completeness: three of the catalogue's own engine gaps and several reference mechanics have no entry (P5).**
- Catalogue gap 7 connector or pipe path (`reference-minigames-catalog.md:350`), gap 8 radial pull or black hole
  (`:351`), gap 9 laser sweep hazard (`:352`) are not entries. The GDD defers connector pieces and rune or mud tiles to
  "Open Questions" (`:1149`) but no open question lists them. Others noted in Appendix A but never specified:
  swinging log and arrow traps, swinging spiked wrecking balls, floor spikes, paint-the-tile, territory claim, whirlpool,
  mine cart and rails (`:1574`, `:1583`, `:1584`, `:1566`). Plank pieces and crates (block-type palette, `:1595`) are
  skins only.
- The 14 unresolved `ART-CHECK` tags (`:125`, `:320`, `:331`, `:342`, `:353`, `:375`, `:388`, `:399`, `:500`, `:675`,
  `:785`, `:1182`, `:1188`, `:1375`) each hide a rule that decides behaviour (does blast damage respect
  `clear_protected`, does rescue wipe anchored cells, does the moody cube accept rainbow). A maker cannot build from
  an entry whose rule says "confirm".
- Many entries say "Not taught" or "not in the first 12" without naming the real level (`:425`, `:651`, `:1554`), so
  "teachability" is unverifiable for a large share of the set.

### S3. Polish and hygiene

**D10. Stale decision text.** Appendix B still presents all five questions with "Recommended" options that
Appendix E overrode (`:1626-1645` vs `:1675-1681`), and the header still says "Decisions are the user's. Anything
marked PROPOSED ... is a recommendation" (`:7`) with Status "not yet reviewed" (`:3`). Mark Appendix B closed and
point to Appendix E.

**D11. Edge case 12 and acceptance 29 still reference "clear_n-style goal" (`:1382`)**, a goal the user banned as a
headline (`level-identity-spec.md:59-63`). Reword to "layer-clear-driven goal".

**D12. Dependencies not made bidirectional.** Section 6 admits the other GDDs and the registry are not edited
(`:1410`, `:1430`). The project rule requires bidirectional dependencies (`.claude/rules/design-docs.md`). Acceptable for
a draft, a defect at sign-off.

**D13. Source citations name third-party-style board titles** ("Wonky Builders", "Wobble Builders", `:257`) while the
doc's own rule says references give ideas only, never names (`:30`).

## 3. What is good (kept short, for the maker)

- The per-entry template (What / Rule / Look / Audio / Fits / Teach / Fairness / Engine / Source) with EXISTS,
  PARTIAL, NEW status and file:line citations is excellent and mostly checks out (`blocks.json` has the 24 kinds
  the doc lists; `families.json` matches the shape families).
- The telegraph rule and the clear-answers-hazard rule (`:62-63`) are the right fairness spine, and the worked
  formulas F3, F5, F6, F7 have real example arithmetic.
- The interaction matrix with fixed order rules and R-2 (one displacement per landing) fixes a real stacking bug
  (`:1171`).
- The F1 idea (one new special at a time) matches the user's variation pillar; it is the mapping that does not honour it.

## 4. Fixes, with owners

| Fix | Resolves | Owner |
|---|---|---|
| F-A. Rewrite 8.1 and every "Fits/Intro" line to match Appendix E: remove IT-14/15/16 and optional ghost/shelf from Chapter 1 teach levels; add an item-unlock table for Chapter 2 on (which item, which level, `p_item`); state skills-only for Chapter 1. | D1, D10 | game-designer (this doc), systems-designer (item table) |
| F-B. Add meadow_h2 and meadow_h3 rows. Recommend h2 = mushroom_popup (sparkle telegraph) and h3 = hatching_eggs plus dented_cube nest, each exactly one existing kind, each with shapes and a teach line. | D1 | game-designer, level-designer |
| F-C. Replace `schedule_mode: locks` text with the hidden-timer ruling; add an assist rule (pause, hazards pause during rescue, optional slow) and an accessibility acceptance check for ms hazards; reword acceptance 23 to "2000 ms or 1 lock, per schedule type". | D1, D6 | game-designer, ux-designer |
| F-D. Reconcile F1 with 8.1: define which sub-objects are scenery (attacker prop, finish marker, pen gate) and cost 0; recount 02 to 05; or raise `A_cap`/lower `n` steps. Re-run acceptance 24 against the 12 levels and publish the table. | D2 | systems-designer, game-designer |
| F-E. Fix all cross-references (OB-14/15/16 to BK-40/41/42, OB-02 to BK-03, BK-24 key cube, unsupported goo, Open Question 5 pointers); add the missing index table; regenerate Appendix D from the ids with a stated counting rule. | D3 | systems-designer |
| F-F. Decide goo's single job (recommend sticky landing with `fills_layer` false while goo) and rewrite BK-07, F5, matrix rows and R-2 accordingly; add the "unsupported goo" edge case. | D4 | game-designer, gameplay-programmer |
| F-G. Give SH-01/05/06/13 a stake: a peg or ring-toss goal and score, hang as a defence against wind/tilt/quake that a level can require, claw as an answer to a push hazard (not the crab) or re-teach it correctly; resolve the ring pocket `fills_layer` contradiction; give rocket its own button, not a double tap. | D5 | game-designer, gameplay-programmer |
| F-H. Add one table of every preview/ghost/telegraph UI feature the counterplays depend on, with owner, days and the level that needs it; re-tune countdown bomb defaults (`thrown_every_locks` >= 12 or `cd_start` >= 10) or document that aimed clears are required; add a spawn gate for all heavy and giant shapes; add the locked-cube deadlock case. | D6 | systems-designer, ui-programmer |
| F-I. Produce a badge and silhouette sheet for all kinds (one unique shape per special, no overlap with the biome hero ornament), and a per-biome collision check; resolve frozen vs ice cube, vines vs sprout leaf, and the four translucent pieces. | D7 | art-director, technical-artist, ux-designer |
| F-J. Read the lava, cave, clockwork, underwater, ice and other biome plans; rewrite every "Fits" and "Intro" line to cite a real level id and fix the mismatches (claw at 02, warning 2500 ms). | D8 | level-designer, game-designer |
| F-K. Add a minigame-to-special coverage table keyed by M-id for all 101 reference minigames, marking each Covered / Needs new special / Out of scope; re-verify every `Source` line against the catalogue and drop `mockup_06` as a source. | D8, D9, D13 | game-designer |
| F-L. Add entries (or recorded rejections) for connector/pipe, radial pull, laser sweep, swinging traps, spikes, paint tile, territory tile, plank/crate skins. | D9 | systems-designer |
| F-M. Resolve all 14 body `ART-CHECK` tags by reading `wt_block_materials.gd`, `biome_looks.json`, `candy_cells.gd`, `rescue_top_out.gd`, `moody_cube.gd`, `earned_specials.gd`, then replace each with a stated rule. | D9 | gameplay-programmer, technical-artist |
| F-N. Close Appendix B, refresh header status, reword clear_n mentions, add the bidirectional dependency edits (or list them as a scheduled task). | D10 to D12 | game-designer, producer |

## 5. Sub-item notes

- **P1 (7.0).** For: very wide palette (shapes, kinds, hazards, objects, items); each kind has a distinct verb
  (spring, spread, steal, hatch, defuse, peel). Against: D4, D5; the shape specials (13 of 14 SH entries) have no
  goal that needs them; several kinds are one-biome reskins of each other (pad, gumdrop, jelly, snowball, boulder
  are all "displacement or fall" cells). Not 10 because of D4 and D5.
- **P2 (6.5).** For: three-signal test, 12-word hint cap, reduced-motion and colour-blind rules (`:1404-1405`).
  Against: D7 and the absence of any rendered proof. Not credited for art that does not exist.
- **P3 (5.5).** For: the first-12 mapping is the right kind of artefact and names real shapes (`:1537-1550`). Against: D1,
  D2, D8. A plan that breaks its own budget on four of the first five levels does not fit the levels.
- **P4 (6.5).** For: warning-then-act on every hazard, clear-based answers, determinism rules (`:1406`). Against: D6.
- **P5 (6.0).** For: all 24 engine kinds and the wave3/wave4 rules are covered with file and line. Against: D3, D9.
- **P6 (5.0).** For: no `clear_n` headline, no beige UI, no "Tetris" naming in names, shapes from the 67-bank (`:30`,
  `:78`). Against: D1 (three of four binding decisions not reflected in the body), D10, D11.

Verdict: FAIL. Pass needs every sub-item at 9.7 from all three experts. Re-submit after F-A to F-N, with the
mapping table, badge sheet and coverage table attached.
