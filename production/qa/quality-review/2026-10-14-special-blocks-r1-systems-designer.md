# Special Blocks and Objects GDD: round 1, systems designer (blind expert)

Reviewed: `design/gdd/special-blocks-and-objects.md` (1682 lines), marked as a PLAN (`.claude/docs/reference-quality-bar.md`, panel rule 1: clear, complete, testable, consistent, buildable).
Code checked: `assets/data/content/blocks.json`, `assets/data/rules/*.json`, `assets/data/items/starter.json`, `assets/data/knobs/`, `assets/data/shapes/families.json`, `src/core/board/board_state.gd`, `src/core/sim/board_sim.gd`, `src/mechanics/**` (bounce_pad, goo_spread, mushroom_popup, pest, sprouts, hatching_eggs, earned_specials, countdown_bomb, rock_obstacle, anvil_drop, tilt_plate, items).
Appendix E (user decisions) is treated as binding. Rule applied: start at 5, 9+ needs 3 citations, any open defect caps at 8.5, when unsure give the lower score. Pass mark 9.7.

## Scoreboard

| Item | Score | Pass (9.7) | Why not higher (one line) |
|---|---|---|---|
| S1 Rule precision per item | 7.0 | FAIL | Most existing-kind rules are exact and cited, but the NEW anchored/hang/gem/critter rules are impossible under the engine's removal guard (D1), and 17 `ART-CHECK` tags leave rules unresolved. |
| S2 Interaction matrix | 6.5 | FAIL | 10x10 grid, but the ANC row contradicts the doc's own notes (D3), two cells describe behaviour no plugin has (D4), and several real interactors are not in the grid. |
| S3 Formulas F1-F11 | 6.5 | FAIL | F7, F4, F2 arithmetic is right. F3's fairness logic is inverted (D2), F1 fails the doc's own level table (D5), F8/F9 ranges are wrong, F11 misstates its source. |
| S4 Edge cases | 7.5 | FAIL | 30 stated cases with citations; a dangling "unsupported goo" case, no case for anchored vs clear, nothing for hidden-timer hazards. |
| S5 Data-driven tuning | 7.5 | FAIL | Real files named and the NEW file is flagged; but a listed param is not in the rule schema, safe ranges are not enforced anywhere, one default is wrong. |
| S6 Engine accuracy (existing/partial/new) | 7.0 | FAIL | File:line citations are mostly accurate; status labels, a goo/bounce veto claim, and the `anchored` semantics are not. |
| S7 Testable acceptance criteria | 7.0 | FAIL | Many criteria carry numbers; AC15, AC19 and AC24 are wrong or self-contradicting, and nothing tests Appendix E. |

Average 7.0. Result: FAIL on every item. The panel verdict needs the other two experts; this expert is below 9.7 on all seven.

What is genuinely strong (these earn the score above 5, they do not lift it past the caps):
- Shape and kind counts are correct: 67 shapes in 10 families (`families.json:4-92`, I counted 8+7+4+12+14+7+3+7+1+4 = 67), 24 kinds with next `kind_id` 25 (`blocks.json:3-242`), 8 items with the stated weights (`starter.json:5-52`; solo buff total 38 gives 26.3 and 21.1 percent as F8 says).
- Rule citations for bounce, goo, mushroom, pest, sprouts, eggs, candy bomb, countdown, rock are right to the line (`bounce_pad.gd:24-41`, `goo_spread.gd:15-33`, `mushroom_popup.gd:19-38`, `pest.gd:19-76`, `sprouts.gd:46-53`, `hatching_eggs.gd:20-47`, `earned_specials.gd:11-19`, `countdown_bomb.gd:9-25`).
- F7 arithmetic checks out (M_x = 5, N_w = 7, tau 142.9; and 25/55 gives 454.5), F2 and F4 examples check out, F10 checks out.
- Edge cases 3, 4, 5, 6 match the hook order in `board_sim.gd:1421-1434` and the plugins.
- Appendix D totals add up (12+45+39+16 = 112; 66+19+27 = 112).

## Ranked defects

Severity: B = blocks a maker from building correctly or contradicts the engine; M = wrong or inconsistent but fixable in the text; m = polish.

### D1 (B) `anchored` blocks CLEAR and RESCUE removal, so hung cubes, protected gems and protected critters can never clear or be collected
- `board_state.gd:685-688`: `can_remove` returns false for `anchored` unless the cause is DAMAGE. `board_state.gd:1430` (`board_sim.gd:1430`): a clear only removes a cell if `can_remove(i, Cause.CLEAR)`.
- Doc says the opposite in three places: SH-05 "a hung cube in a full layer clears normally and the status goes with it" (line 104); AC19 "it still clears in a full layer" (line 1513); R-8 "protected objects carry `anchored` while a goal needs them (`gem_safe`, `critter_safe`)" (line 1183) while AC18 requires a gem to be "collected by a real clear" (line 1512); BK-15 "critters and keys are `anchored` or protected" (line 358); Edge Case 18 "Anchored and hung cubes are exempt" and the claim that rescue wipes anchored cubes "like any cube" (lines 104, 1390). Cause.RESCUE is also blocked by `board_state.gd:687`.
- Also the reverse: blast and Smash DAMAGE do remove `anchored` cells (only `fixed` stops them, `board_state.gd:685`), so `earned_specials.gd:18` has to special-case `anchored`. The matrix cell BMB x ANC "L anchored survives" holds only for that one plugin, not for the item bomb, ember or Smash. The doc never says which causes each protection state blocks.
- Fix: add a table "status x Cause" (CLEAR, DISPLACED, DAMAGE, TRIM, RESCUE, MASKED) copied from `can_remove`, and define NEW statuses (`hung`, `goal_object`, `blast_safe`) as separate flags with their own row. Do not reuse `anchored` for hang or protection. Re-write R-8, SH-05, AC18, AC19, Edge Cases 13 and 18 against that table. Owner: systems-designer (spec), gameplay-programmer (confirm against `board_state.gd`).

### D2 (B) F3 "cap-reach fairness" is inverted, and its worked example "fixes" a failing level by making it harder
- Lines 1238-1250: pass if `objects_max * E >= k_fair * P_eff`. Example: mushrooms with E = 3 fail (12 < 18), and the text says "raise `objects_max` to 6 (6 x 3 = 18, passes)". A higher cap with the same fast spawn rate lets MORE hazards sit on the board, which is strictly worse for the player. The formula rewards a larger cap instead of a smaller one, and the text then rationalises it ("fair only because they arrive slowly", but E is unchanged at 3).
- It also ignores the clear rate it cites elsewhere (F5, F6 use `c`), so hazards removed by play are not in the model, and it takes `objects_max` per kind while hail's cap is shared across three kinds (`gumdrop_hail.gd`, doc line 298).
- AC17 (line 1511) bakes the inversion into a unit test.
- Fix: replace with a pressure ratio. Example form: hazards arrive at 1/E per lock, the player removes them at about c_adj per lock, so equilibrium count `H_eq = (1/E) / c_adj` (capped at `objects_max`), and require `H_eq * cells_blocked <= k * free_cells` or require `E >= E_floor(P_eff)`. State the rationale and rewrite AC17. Owner: systems-designer.

### D3 (B) Interaction matrix: the ANC row contradicts the notes, and the grid omits real interactors
- Row ANC (line 1166): ANC x MAG = `L`, ANC x WND = `L` (row loses), while the MAG and WND rows say `L stops at anchored` (the OTHER side loses). Both cannot hold, and "ANC loses to magnet and wind" contradicts the note at line 1192 ("Wobble and tilt ignore anchored") and SH-05 ("Anchored cubes are not moved by ... wind"). The row's semantics ("acts") are undefined for a thing that never acts.
- BMB x GHO "W ghost cells are not solid until solid" (line 1162) is meaningless.
- Missing rows or columns for things the doc itself specifies: pest, sprout, honey/`sticky_landing`, frosting and locked shells, conveyor/belt/turntable/piston, lava rise, tilt, fire/burning, fog, rescue. They are pushed into prose notes (lines 1187-1194), so completeness is not checkable and Acceptance 13-14 cover only 2 cells.
- ICE is used for both the ice slide (`ice_slide.gd`, fixed `slide_dir`) and the NEW ice cube (BK-35, last move). R-6 admits they differ; the grid does not.
- Fix: define "row = the effect, column = the target state"; split ICE into slide and cube; rebuild as a full effect x target matrix with one outcome code per cell and a generated check that no pair is blank. Owner: systems-designer.

### D4 (B) Matrix and BK-05 assert behaviour that no plugin has, labelled as if existing
- GOO x BNC "W cancels the hop" and BNC x GOO "L sticky wins, no hop" (lines 1159-1160); BK-05 rule text: "goo (pad bounce is vetoed on a sticky landing)" (line 250). `bounce_pad.gd:12-41` has no sticky check and subscribes only to `on_spawn`, `on_command`, `on_land`. `goo_spread.gd` is a cell-spreading rule and never touches a piece. BK-07 itself says "goo as a kind does not slow pieces today" (line 272). So the doc contradicts itself and the engine; "sticky beats motion" (Order rule 3, line 1172) is a NEW rule with no size, no owner, no AC.
- GOO x ICE "W cancels the slide": same problem.
- R-2 (one displacement per piece) is sized 0.5 day (line 1177). Three independent plugins (`bounce_pad`, `jelly_piece`, `ice_slide`) each fire in `on_land`; arbitrating them needs shared piece-flag state and a defined plugin order. 0.5 day is not supported.
- Fix: mark every cell not backed by code as NEW with its own rule id (R-n), size and owner; add AC per NEW cell. Owner: systems-designer, gameplay-programmer for sizing.

### D5 (M) F1 contradicts the doc's own level table, and AC24 would fail the plan
- F1 gives `A_max(2) = A_max(3) = 1` (line 1220: n = 1 to 3 gives 1). Section 8.1 budget check (line 1552) lists meadow_02 as 2 active (core, wind) and meadow_03 as 2 (cargo, track), then states "All within F1 except the bonus". They are not. AC24 (line 1521) would reject the plan's own meadow_02 and meadow_03.
- meadow_04 introduces herd animals, pen and gates (OB-27, OB-28, BK-39) in one level (line 1542), against `new_specials <= 1`.
- `A_cap = 3` is not reconciled with the framework knobs `rules.max_twists` 2 and `rules.max_level_mechanics` 1 (`knobs/rules.json:6-7`), the real per-level limit. Appendix E "remix in hard levels" (h2, h3) has no entry: which kind, which n (13 and 14), what F1 value. 
- Fix: either change F1 to start at 2 or re-split the levels; define "active special" against the framework layers (content/twist/mechanic) and show the mapping; assign the h2 and h3 remix kinds. Owner: systems-designer with level-designer.

### D6 (M) Appendix E is not integrated; the body still contradicts the binding decisions
- Appendix B questions 1-4 are still presented as open with recommendations that differ from the user rulings (Q2 recommends `schedule_mode: locks`, line 1631; the user chose "Hidden timer", line 1677). Section 7 row for `melt_every_s` still says "see Open Question 2" (line 1465). F8 still says "Campaign default: items off ... only if the user rules so" (line 1322); Appendix E says items unlock from Chapter 2. Section 8.1 intro still says "Items are off in the campaign" (line 1535). Header still says "Not yet reviewed".
- No formula or AC covers ms-scheduled hazards: F2 and F3 are lock-only (lines 1222-1250), so the Lava, Underwater and Forest clock hazards listed in Section 7 (`melt_every_s` 35, `claw_warn_ms` 2000, `quake_warn_ms` 2000) have no fairness check. The countdown bomb shows a numeric digit (BK-16 Look) and must be checked against "no countdown shown"; the doc does not rule on it.
- No AC checks the Chapter 1 vs Chapter 2 item gating.
- Fix: rewrite Appendix B as resolved, patch F8, 8.1, Section 7; add F2b/F3b for ms hazards (telegraph time vs reaction time); add ACs. Owner: systems-designer.

### D7 (M) Formula defects (each separately scored under S3)
- F7 vs AC15: AC15 says "tau = 143 (round down)" and "455" (line 1509). Engine uses integer division, `tilt_plate.gd:81-82`, which gives 142 and 454. The doc's 143 and 455 are rounded to nearest, and "round down" is false. F7 also needs weights in `measure()` (static, `tilt_plate.gd:72-86`) which counts cells only; OB-04 sizes this as 1 day with "weighted_cells ... could take a weight" (line 714), but `weighted_cells` (`:57-68`) returns cells, not weights.
- F8 range: "E_items about 0 to 43" (line 1322). Max at the stated bounds is 120 x 0.5 x 1.0 = 60; at defaults 120 x 0.12 x 0.6 = 8.6. 43 matches nothing. F8 has no link to level progression.
- F9 range: `gem_max_layer = floor(f * H_play)`, f 0.3-0.7 and H_play 6-12 gives 1 to 8, doc says 2 to 8 (line 1334). The 50 percent rationale ("a gem in layer 6 would need a full 6 layers") is not a rule derivation.
- F11 misstates its source: `levels.md:438` says "Speed rises one step per lamb rescued", the formula has two phases ("first half of the lambs"). With `grow_locks = 1` the bud warning and the growth occur on the same lock (`sprouts.gd:46-48`: `locks % 1 == 0` for both), breaking the doc's own telegraph rule (convention 2, line 62). BK-02 points to "Formulas F6" for this (line 234); it is F11.
- F6: `c_adj` "about half of c" (line 1288) has no derivation; p_def treats locks as independent Bernoulli trials, which is not true while the clear rate rises with stack height. It also bundles two unrelated formulas under one name.
- F2: "applies to hazards without a stated default" (line 1236). Mushroom 5, hail 4, ant 3, countdown 8 all have defaults (`mushroom_popup.gd:15`, `pest.gd:32`, `countdown_bomb.gd:22`), so F2 drives almost nothing, and E_min = 3 equals the existing ant default. `E0` range 4-10 and `E_min` range 2-5 allow `E_min > E0`, making the clamp invalid. The biome index `b` makes a hazard harder simply because its biome is later, which is not tied to when the hazard is introduced.
- F5: the model counts goo growth as `(1-c)*g*k`; `goo_spread.gd:29` takes `per_lock` total, not per goo, which matches, but the claim "fills the board in about 2.5 layers of play" is not derived. `G0` is not tied to progression.
- Fix: correct each as above; add rationale lines and a "tied to progression" column. Owner: systems-designer.

### D8 (M) Status labels: several "EXISTS" entries are PARTIAL, and Appendix D tallies disagree with the entries
- BK-02 sprout is EXISTS but needs a per-phase change (0.5 day, line 234); BK-07 goo is EXISTS but lacks the cap AND the spread warning its Look section describes (`goo_spread.gd:15-33` emits no warning; line 278 sizes 0.75 day); BK-14, BK-15, BK-16, BK-28 each list NEW gaps (lines 348, 359, 370, 506). By the doc's own definition (line 1671, "Partial means the base exists and a power, view or rule is missing") these are PARTIAL. The BK "Partial 6" count (line 1666) is therefore too low.
- Appendix D says the 10 NEW block kinds include hole, gate, pillar (lines 1666, 1671), but BK-37 hole is EXISTS (line 609), BK-39 gate and BK-41 pillar are PARTIAL (lines 631, 653).
- SH ids are not one per entry (SH-01/02/03 share one entry), so AC1 "exactly one" mapping is unclear. Dangling cross-references: "see Edge Cases: unsupported goo" (line 272) has no such case; "Open question 5" for gumdrop stickiness (line 304) is the "next step" question; "ART-CHECK" appears 17 times (rule/engine claims left unverified: blast vs `clear_protected`, `remove_cell` DAMAGE vs `on_clear`, rescue vs fixed rocks, moody vs rainbow). Several are answerable from the repo now: `board_state.gd:691` shows `clear_protected` only blocks CLEAR, so blasts DO remove frosting and locked cubes (BK-15 line 353 says locked cubes "unlock only by adjacent clears, not by blast", and line 1188 says the opposite).
- Fix: re-tag, recount Appendix D, resolve every ART-CHECK with a citation. Owner: systems-designer; gameplay-programmer confirms.

### D9 (M) Data-driven section names knobs the schema does not have
- `bounce_dir` is listed (line 1443) but `assets/data/rules/bounce_pad.json:8-15` declares only `bounce_h` and `dir_mode`. Rule JSONs carry type only, no min/max, so every "safe range" in Section 7 is documentation, not enforced; the doc says so but still labels the rows "Safe range". 
- `max_crush` default is shown as "n.a." (line 1458); `anvil_drop.gd:37` defaults it to 3.
- `assets/data/knobs/specials.json` does not exist (`assets/data/knobs/` holds board, data, fall, controls, view, clearing, rules, spawn, goals); flagged NEW, fine, but the doc does not give the file format fields or say which knobs are rule-adjustable.
- Fix: add the missing schema params to the rule JSONs list and a min/max enforcement note; give the specials.json skeleton. Owner: gameplay-programmer (schemas), systems-designer (values).

### D10 (m) Gap sizing is unsupported and not rolled up
- Day counts are given per item (for example SH-01 peg fit 3 days, SH-05 hang 3 days, R-2 0.5 day) with no basis, no contingency and no total. SH-01's "hole aligns with a peg cell" (AC20) is a collision-rule change in the core movement path, not a mechanic plugin; SH-05's timed status needs a new timer on a status that today blocks CLEAR (D1). Both look undersized.
- Fix: add a sizing table (basis, risk, total) and mark core-touching items for lead-programmer. Owner: producer with systems-designer.

## Fixes by owner

| Owner | Fix | Defect |
|---|---|---|
| systems-designer | Status x Cause table; redefine hang, goal_object, blast_safe as own flags; rewrite R-8, SH-05, AC18, AC19, EC13, EC18 | D1 |
| systems-designer | Replace F3 with a pressure model, rewrite AC17 | D2 |
| systems-designer | Rebuild matrix as full effect x target grid, split ICE, remove ANC contradiction | D3 |
| systems-designer + gameplay-programmer | Mark unbacked matrix cells NEW with R-n, size and AC; re-size R-2 | D4 |
| systems-designer + level-designer | Reconcile F1 with 8.1 and the framework twist/mechanic limits; place h2/h3 remix kinds | D5 |
| systems-designer | Integrate Appendix E into Appendix B, F8, 8.1, Section 7; add ms-hazard fairness formula and ACs | D6 |
| systems-designer | Fix F6-F11 ranges, rounding (AC15 to 142/454 or specify rounding), F11 per-lamb steps and E=1 telegraph | D7 |
| systems-designer | Re-tag EXISTS/PARTIAL, recount Appendix D, resolve all ART-CHECK, fix dangling refs | D8 |
| gameplay-programmer | Add missing rule-schema params, enforce min/max, confirm defaults | D9 |
| producer | Sizing basis and roll-up table | D10 |

## Top 5 defects

1. D1: `anchored` blocks CLEAR and RESCUE (`board_state.gd:685-688`, `board_sim.gd:1430`), so hung cubes, protected gems and critters cannot clear or be collected as SH-05, R-8, AC18 and AC19 require.
2. D2: F3 fairness rewards raising `objects_max`, which makes the board more hazardous (lines 1238-1250, AC17).
3. D3: matrix ANC row contradicts the notes and the MAG/WND rows (line 1166 vs 1159-1165, 1192); major interactors missing.
4. D4: matrix and BK-05 claim a goo veto and "sticky beats motion" that `bounce_pad.gd:12-41` and `goo_spread.gd:11-33` do not implement, and BK-07 line 272 denies.
5. D5: F1 gives A_max = 1 for levels 2 and 3, but section 8.1 puts 2 specials in meadow_02 and meadow_03 and AC24 would fail the plan (lines 1220, 1552, 1521).
