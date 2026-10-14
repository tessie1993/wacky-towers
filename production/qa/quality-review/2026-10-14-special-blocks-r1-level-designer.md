# Quality review r1: special-blocks-and-objects.md, LEVEL DESIGNER (blind expert 1 of 3)

Reviewed: `design/gdd/special-blocks-and-objects.md` (GDD) as a PLAN, against `design/levels/levels.md` (LV), `design/levels/plans/level-identity-spec.md` (LIS), `design/levels/plans/reference-minigames-catalog.md` (RMC), `.claude/docs/reference-quality-bar.md`. Appendix E (GDD:1673-1681) is binding. Marking: stricter rules apply; no item has 3 clean citations plus zero open defects, so none reaches 9. Pass mark 9.7. I did not open `production/qa/quality-review/` before writing and did not read other reviews.

Plan-gate note: this is marked as a plan, so the "paper-only <= 7" cap is not applied. The "open defect <= 8.5" cap applies and every item below has several open defects, so scores are set by defect weight.

## Scoreboard

| ID | Item | Score | Pass 9.7? |
|---|---|---|---|
| L1 | Level-building value of the specials and objects | 6.8 | FAIL |
| L2 | Biome spread and identity | 5.5 | FAIL |
| L3 | Campaign introduction pacing | 5.0 | FAIL |
| L4 | Spatial readability from the game camera | 6.0 | FAIL |
| L5 | First-12 mapping quality (section 8.1) | 6.3 | FAIL |
| L6 | Coverage of reference minigame needs | 5.8 | FAIL |

Verdict is the orchestrator's. The lowest item is L3 (5.0). Strengths that earned points above the 5.0 start are listed per item.

## Strengths that were credited (with evidence)

- Every catalogue entry has a fixed field set (What / Rule / Look / Audio / Fits / Intro and teach / Fairness / Engine / Source), GDD:74. A level builder can look up a special and find its hint, warning and counterplay.
- Conventions give a real readability test (0.5 s, three signals: silhouette, loop, rim colour, plus a badge) and a telegraph rule for every hazard, GDD:61-62. Strong for a plan.
- Fairness machinery is concrete: F1 cap of active specials (GDD:1209-1220), F2 hazard interval (GDD:1222-1236), F3 cap-reach check (GDD:1238-1246), banned combinations (GDD:1196-1203), interaction matrix with fixed order (GDD:1157-1173), acceptance items 23-27 as validator checks (GDD:1519-1527).
- All 12 levels of the frame have a row in 8.1 with frame gap ids and shape lists (GDD:1537-1550), and the meadow_01 shape rule O/I/L is kept (GDD:1539 vs LV:82).

## Ranked defects

Severity: S1 blocks a pass on its own; S2 should be fixed before use; S3 polish. Each has a citation, a concrete spatial or plan fix, and an owner.

### D1 (S1, L3 and L5) The doc breaks its own pacing formula F1 in the first 12 levels, and says it does not

- Evidence. F1 gives A_max = 1 for n = 1 to 3, 2 for n = 4 to 6, 3 for n = 7 or more, and new_specials <= 1 (GDD:1211, 1220). The 8.1 budget check then lists meadow_02 as "2 (core, wind)" and meadow_03 as "2 (cargo, track)" and concludes "All within F1" (GDD:1552). n = 2 and n = 3 allow 1. The 8.1 table also lists three NEW things in meadow_02: OB-01 core, OB-02 gust, OB-35 gnome attacker (GDD:1540), and four in meadow_03: OB-31, OB-32, OB-33, lean (GDD:1541). meadow_05 is called "Correct" with stone throw plus hedge wall (GDD:1220); both are new at n = 5, which breaks new_specials <= 1. meadow_09 adds tilt plate and heavy shapes, both new (GDD:1547).
- Why it matters. This is the doc's own teach curve, "one new idea per level" (GDD:42), and it is the first thing a level designer will test. The self-check is false.
- Fix (spatial/plan). Either (a) change F1 to count "level goal rule" separately and define "new" per verb (core + attacker + warning = one idea), then restate the counts honestly in 8.1; or (b) keep F1 and move the tell-props (weathervane, gnome, finish flag) to a "dressing, not a special" class that does not count. Also split meadow_09: teach tilt alone, hold heavy shapes for meadow_10 or h2. Owner: systems-designer (F1 text), level-designer (8.1 table).

### D2 (S1, L3 and L5) Appendix E is not applied; the doc still carries superseded recommendations

- Evidence. E says "Chapter 1 uses character skills only" and items from Chapter 2 (GDD:1679). Yet 8.1 header says items are "off in the campaign unless a level turns them on" (GDD:1535); IT-14 Shield fits "meadow_02, 05, 10" (GDD:1117 area, "Fits" line of IT-14), IT-15 Rewind fits "meadow_06" (IT-15 Fits), IT-16 Grip fits "meadow_08, 09" (IT-16 Fits). Appendix B Q1 and Q4 still recommend "Keep the frame ... from Chapter 2 on" and "Off in the campaign" (GDD:1626-1641), Q2 still recommends a lock-count mode while E ruled "Hidden timer" (GDD:1630-1633 vs 1677-1678); OB-13 to 16 still say "Proposed schedule_mode: locks" (GDD:790). Q3 (rescue vs goal objects) has no ruling and Edge Case 13 depends on it (GDD:1383).
- Fix. Rewrite the Appendix B questions that E closed as "DECIDED" and delete their option lists; re-tag IT-14/15/16 "Fits" to Chapter 2+ levels (for example Shield in the first defender level of biome 2); change 8.1 header to "Chapter 1: skills only (E)". Drop the lock-count mode from Q2 or mark it optional. Owner: systems-designer.

### D3 (S1, L5) meadow_h2 and meadow_h3 remix levels, which E binds, are not mapped; the only teach suggestions contradict E

- Evidence. E: "Each of meadow_h2 and meadow_h3 adds one existing special kind as a remix. The teach levels 01-10 keep the core objects only" (GDD:1675-1677). The 8.1 table stops at meadow_h1 (GDD:1550). h2/h3 appear only as loose suggestions: mushroom "meadow_h2 or forest_01" (GDD:221), egg "meadow_h2 or a bonus" (GDD:242). BK-02 sprout says "add a gentle intro in meadow_07 or the bonus" (GDD:232), which puts a new special into a teach level and violates E. Appendix B Q1 says the same (GDD:1626-1629).
- Fix. Add two rows to 8.1: h2 = one pick (recommend mushroom, it needs no new engine work and the sparkle is its own teach, GDD:223), h3 = one pick (recommend egg + dented_cube nest as one story beat, or bounce_pad remix). State shapes and the F1 budget for each. Delete the "add a sprout intro in meadow_07" advice; h1 may keep sprouts only if h1 is the sprout teach (it is, LV:419-448), and say so. Owner: level-designer with game-designer.

### D4 (S1, L5 and L6) Several 8.1 rows disagree with the frame's later user decisions

- Evidence. LV section 8 (user, after the G8 panel): "no rival speed race in this round"; cargo "sits on the highest block" of your build (LV:607-614). GDD OB-05 rival is still mapped to meadow_bonus (GDD:1549, OB-05 Fits) and OB-31 says cargo "sits on a marked cell of the platform" with fills_layer false (GDD:899). That is a different spatial rule: cargo on the top block moves up with the stack and is swept by arches (the GDD's arch sweep at GDD:910 is then a build-height test, not a placement test). OB-01 says the core is a "2x2 board centre" on layer 0 (GDD:675), but LV:106 puts the sprout "in the inner curve of a hilltop ledge" on a crescent platform (LV:122).
- Fix. Re-derive OB-31 as "cargo rides on the highest block; knocked off by bump/arch/wind; wobble warning before fall" and drop the marked-cell form; mark OB-05 "not in this round" and remove it from the bonus row; make OB-01's position a level parameter set in the crescent inner curve for meadow_02. Owner: level-designer (rows), gameplay-programmer note for G8 cargo rule.

### D5 (S1, L2) No biome-by-special spread table; four of the 12 biomes have no signature specials; "pirate" is used as a biome but is not one of the 12

- Evidence. The 12 biome skins are listed at GDD:68 (meadow, candy, ice, underwater, lava, forest, cave, clockwork, neon, celestial, carnival, desert). F2 numbers biomes "meadow 1 ... carnival 12" (GDD:1228). "Pirate" is a Fits target in at least 20 entries (for example GDD:85, 96, 107, 118, 354, 365) but is not a biome. The doc counts 29 existing kinds that sit in meadow, candy, forest, cave, lava, underwater (GDD:211-450), and 11 NEW meadow-only actors (OB-27 to OB-37, GDD:853-972). Neon, celestial, carnival and desert have no entry of their own; every mention is a "Fits" reuse (for example GDD:128, 444, 514, 571). Work log admits lava, desert, carnival, pirate and clockwork "Fits" are "design intent, not cited" (GDD:12). Candy has nine kinds (BK-09 to BK-17).
- Why it matters. Biome identity is a core requirement ("biome identity of the specials"). With no matrix, a reviewer cannot test spread, and the tower of candy entries against empty neon/celestial/carnival suggests uneven spread.
- Fix. Add a 12 x (shape / block kind / object / item) matrix in section 3 with exactly: signature special (new in that biome), reused specials, banned specials. Give the four empty biomes one signature each from the already-listed ideas: neon = laser gate / laser sweep + hologram plate (RMC M40, GDD:1580), celestial = wormhole or gravity well (M27, GDD:1577), carnival = ring-toss peg + high-striker (SH-01/BK-40 already fit), desert = rolling boulder + quicksand (OB-38, OB-18). Replace "pirate" with the nearest real biome (underwater/carnival/desert) or add pirate to the biome list through game-director. Owner: level-designer + game-designer.

### D6 (S1, L3) No campaign-wide introduction order for 12 biomes

- Evidence. First-appearance data is scattered inside "Intro and teach" lines: "Cave 01" (gem, GDD:563), "Lava 03" (fire tile, GDD:596), "Clockwork 02" (magnet, GDD:574), "Underwater 04" (crab claw, GDD:779), "Ice 01" (ice cube, GDD:585), "Cave 04" (boulder, GDD:980), "Candy tier 2" (several). Chapter order is never listed, so "Ice 01" cannot be placed on the curve. F1 caps by biome-level index, but F1 does not say which specials a biome may introduce, and "Candy tier 2" is used by moody, rainbow, frosting and licorice at once (GDD:313, 335, 346, 515), which contradicts new_specials <= 1.
- Fix. Add a table "campaign introduction order": biome order, level index, the one new special per level, and what is recalled. Move Candy tier-2 specials to separate levels. Cross-check with F1/F2 and the acceptance test #24 (GDD:1521). Owner: level-designer (table), game-designer (curve sign-off).

### D7 (S2, L4) Camera readability is stated but not tested for stack occlusion or small footprints

- Evidence. The read test is a cube-size rule (28 to 60 px at 720x1280, GDD:61) and a per-entry "Look" line, but there is no rule for what hides what. Gems must sit in the lowest layers (GDD:564) and the key/critter pockets are protected by being inside rings and dents (GDD:82, 170), which also means they are buried under the stack from a three-quarter camera. The defend core sits on layer 0 behind the wall the player is building (GDD:675). The peg is "a thin standing post" on one cell (GDD:635). The angle gem is only visible "from the matching camera angle" (GDD:830). LV:34 itself asks for "a camera plan and a wall fade" for level 1 (G23) and the GDD never mentions this need for specials. `ART-CHECK` is open on 14+ entries (for example GDD:125, 320, 331, 399, 500) and acceptance #4 is not yet run (GDD:1494).
- Fix. Add a "see-through rule" convention: goal objects (gem, key, critter, cargo, core) draw an always-on silhouette/outline through cubes in front, with a 2 px gold rim; pegs get a minimum 1-cell wide base and a vertical beam while a ring piece is falling; gems placed in lowest layers get a floor-level marker visible from the camera, plus a clear-time cue when the layer above is sealed. Run block_gallery per biome and close every ART-CHECK before use. Owner: technical-artist (silhouette pass), ui-programmer (outline layer), level-designer (placement ranges).

### D8 (S2, L1) Cross-reference ids are wrong in the shape entries

- Evidence. SH-01 sends the reader to "a `peg` or `pillar` (OB-14, OB-15)" (GDD:82), but OB-14 and OB-15 are lava lid and quake (GDD:783); pegs are BK-40 and BK-41 (GDD:634, 645). SH-05 names "OB-16: peg, branch, rail" for the hang point (GDD:104); OB-16 is the geyser vent; the hang point is BK-42 (GDD:656). Appendix D counts 12 shape entries (GDD:1665) while the headings number SH-01 to SH-14 and several groups; the 112 total cannot be verified by a level designer.
- Fix. Correct ids to BK-40, BK-41, BK-42; reconcile Appendix D with the heading count and say how grouped entries are counted. Owner: systems-designer.

### D9 (S2, L2 and L5) Special shapes do not reach the first 12 levels or any teach; hollow shapes only in the last biome

- Evidence. SH-01 to SH-07 are "Not in the first 12 levels" (GDD:85). Ring teach is "a carnival or meadow bonus level" (GDD:86), while carnival is biome 12 (GDD:1228) and the meadow bonus row has no ring or peg (GDD:1549). Jack "Chapter 2 or later" (GDD:130), giant ring "third chapter" (GDD:97). LIS:135-141 requires level designers to pick shapes "from the full shape bank" with a reason. The mapping uses O, I, L, duo, tri, slab, big_cube, pole, tripod, tall_corner, pento_flat (GDD:1539-1550) but the 67-shape bank has 10 families.
- Fix. Give hollow family a home early: add peg to meadow_06 (fence post ring-toss patch) or to h3 (as the "existing special" remix is a shape not a kind), and give claw/hook a Chapter-2 teach level. State the shape-bank coverage per chapter (how many of the 10 families each chapter uses). Owner: level-designer.

### D10 (S2, L6) Large parts of the reference minigame set are not specified as specials or objects

- Evidence. RMC gap list: avatar on the board (~25 entries, L), projectile/catapult/cannon (7), bumper physics (4), ball sport (1), rail laying (2), connector/pipe path (3), radial pull (3), laser sweep (1), herding/shooter/pad-press (3) (RMC:340-356). GDD Appendix A records the ideas ("Ideas: crane claw, furnace ...", "laser hazard", "swinging spike ball", "paint-the-tile", "pipe connection blocks", GDD:1573-1584, 1587) but section 3.2 specifies none of them. 3.2.e defers "plank pieces, pipe-connector pieces, rune and mud floor tiles" with "needs a ruling" (GDD:1149). Cannon/siege is only an attacker skin (OB-35, GDD:941), not a shoot-back player verb. Covered well: gems (BK-33), keys (BK-24), bomb defuse (BK-16), balloon (BK-26), boost pad (OB-34), boulder (OB-38), sleeping guard (OB-39), herd (OB-27).
- Fix. Add a coverage table "RMC id -> GDD id or EXPLICITLY OUT (reason)" for all 83 minigames. Add short entries for the cheap ones (laser gate, swinging spike ball, paint/claimed tile, pipe connector piece, crane claw) and mark avatar and ball sport OUT (not a Tetris-variant need). Owner: game-designer (scope call), level-designer (table).

### D11 (S2, L4) Colour-role collisions in the readability system

- Evidence. Roles: buff cyan, debuff magenta, hazard orange, danger red, reward gold (GDD:61). Candy bomb is a "reward" earned block but gets a "pulsing orange rim (hazard-reward)" (GDD:354); mushroom warning also uses hazard orange (GDD:218); IT-14 shield and IT-01 slow time both cyan. Sprout leaf sticker is on every cube in the HUD board, so a sprout special badge must differ (GDD:1613) but BK-02 uses "green stalk with two leaves" (GDD:229).
- Fix. Make the candy bomb gold-rim with an orange fuse spark only; give the sprout a bud-and-gold-tip silhouette; add a one-page colour-role chart per biome palette so no two specials in one biome share rim and badge. Owner: art-director with level-designer.

### D12 (S3, L5) Terminology clash: "arch" piece versus "arch" track event

- Evidence. SH-02 arch is a hollow shape (GDD:81); OB-32 low arch sweeps tall stacks and meadow_03 shape rule "no tall shapes (arch sweeps tall stacks)" (GDD:1541). Same word for two unrelated objects in the same level.
- Fix. Rename the track event "low gate" or "rainbow gate". Owner: level-designer.

## Item notes (what lifts or caps each score)

- **L1 6.8.** Gains: field set, fairness formulas, matrix, validator hooks (GDD:74, 1209-1246, 1157-1203, 1519-1527). Capped by D1, D2, D4, D8 and the unrun gallery check (GDD:1494). Not higher than 8.5 because of open defects, and the 6.8 reflects that the self-check in 8.1 is wrong.
- **L2 5.5.** Gains: skin rule keeps one silhouette and badge per kind across the 12 materials (GDD:68). Capped by D5 and D9; four biomes have no signature and "pirate" is an extra biome.
- **L3 5.0.** The per-level hint lines exist, but the campaign order does not (D6), F1 is violated by its own mapping (D1), and Appendix E is not integrated (D2, D3).
- **L4 6.0.** Gains: 0.5 s read test, three signals plus badge, reduced-motion and colour-blind rules (GDD:61, 1404-1405, acceptance 31-32). Capped by D7 and D11, and ART-CHECK items open.
- **L5 6.3.** Gains: every frame level mapped with gap ids and shapes (GDD:1537-1550). Capped by D1, D3, D4, D12.
- **L6 5.8.** Gains: a deep reading of 37 mockups and many matched specials (GDD:1561-1615). Capped by D10; and the doc itself says some mockup attributions "may be shifted" and several images could not be read (GDD:1619). RMC states a similar read limit (RMC:7-12).

## Fixes by owner (merged, deduplicated)

| # | Fix | Owner | Defects |
|---|---|---|---|
| 1 | Rewrite F1 counting and restate 8.1 budget honestly; split meadow_09 tilt/heavy | systems-designer + level-designer | D1 |
| 2 | Close Appendix B Q1-Q4 against E; re-tag IT-14/15/16 Fits; fix 8.1 item header; update OB-13-16 clock note | systems-designer | D2 |
| 3 | Add meadow_h2 and meadow_h3 rows (one existing special each); delete "sprout intro in meadow_07" advice | level-designer + game-designer | D3 |
| 4 | Align cargo, rival and core rules with LV section 8 and LV:106 | level-designer + gameplay-programmer | D4 |
| 5 | Add 12-biome signature matrix; give neon, celestial, carnival, desert a signature; remove "pirate" as a biome or add it | level-designer + game-director | D5 |
| 6 | Add campaign introduction order table; split Candy tier-2 introductions | level-designer + game-designer | D6 |
| 7 | Add see-through/outline rule for goal objects; peg size; close ART-CHECK; run the gallery | technical-artist + ui-programmer | D7 |
| 8 | Fix SH-01 and SH-05 cross-ids; reconcile Appendix D counts | systems-designer | D8 |
| 9 | Place hollow/hook/claw shapes into early teach slots; add shape-family coverage per chapter | level-designer | D9 |
| 10 | Add RMC-to-GDD coverage table; entries for laser gate, spike ball, paint tile, pipe piece, crane claw | game-designer + level-designer | D10 |
| 11 | Colour-role chart per biome; fix bomb and sprout rims | art-director | D11 |
| 12 | Rename the "low arch" track event | level-designer | D12 |

## Top 5 defects (for the caller)

1. D1: F1 is broken by 8.1 itself (meadow_02 and 03 list 2 specials at n = 2, 3 where A_max = 1; new_specials <= 1 broken at 02, 03, 05, 09) yet the text says "All within F1" (GDD:1211, 1220, 1552).
2. D2/D3: Appendix E is not integrated: items still "Fits" in Chapter 1 levels, Appendix B Q1, Q2, Q4 still recommend superseded options, meadow_h2/h3 are not mapped, and a sprout teach is proposed inside a teach level (GDD:232, 1535, 1626-1641, 1675-1679).
3. D5/D6: No 12-biome spread table or campaign introduction order; neon, celestial, carnival and desert have no signature specials; "pirate" is used as a biome but is not one of the 12 (GDD:68, 1228, 12).
4. D4: 8.1 rows contradict LV section 8 and LV:106: cargo must ride on the highest block, no rival race this round, sprout core sits in the crescent ledge curve, not at board centre (GDD:675, 899, 1549 vs LV:122, 607-614).
5. D7/D10: Readability from the game camera has no occlusion plan (gems and cores buried under the stack, thin pegs, 14+ open ART-CHECK) and large parts of the reference minigame list have no specification or explicit "out" ruling (GDD:564, 635, 675, 1149, 1573-1587; RMC:340-356).
