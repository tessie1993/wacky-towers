# Special Blocks and Objects, r2: systems designer review (blind, fresh)

Reviewed: `design/gdd/special-blocks-and-objects.md` (2137 lines), marked **as a plan** (clear, complete, testable, consistent, buildable). Paper-only caps do not apply. The open-defect cap (8.5) does. Checked against `src/core/board/board_state.gd`, `src/core/sim/board_sim.gd`, `src/core/rules/rule_api.gd`, `src/mechanics/**`, `src/mechanics/goal/rescue_top_out.gd`.

Coverage limit: I read sections 1, 3.1, 3.1b, 3.3 to 3.7, 4 to 8 and Appendices A to F in full, and spot-read SH-01, SH-05 to SH-07, BK-07 and BK-33 from the 3.2 catalogue (about 1,150 lines of entries, not read line by line).

## Scoreboard (start 5, evidence-earned)

| # | Item | Score | Pass (9.7)? |
|---|---|---|---|
| 1 | Rule unambiguity and completeness | **7.5** | FAIL |
| 2 | Formulas and tuning knobs | **7.5** | FAIL |
| 3 | Interaction matrices and edge cases (consistency with each other and the engine) | **7.5** | FAIL |
| 4 | Data model and flags (`hung`, `blast_safe`, `rescue_safe`, `goal_object`) | **6.5** | FAIL |
| 5 | Testable acceptance criteria | **7.5** | FAIL |

Overall result: FAIL. Every item has at least one open defect, which caps it at 8.5. Items 1 to 3 and 5 sit below that cap because of the defects listed. Item 4 is the weakest because a user-decided mechanism (`rescue_safe`) cannot work as specified against the engine.

What earns the points above 5 (so the owner knows what to keep):
- The status-by-cause table (3.1b, lines 97-108) matches `can_remove` / `can_move` exactly (`board_state.gd:677-695`). I checked all rows for `fixed`, `anchored`, `locked`, `clear_protected`, `vined` against code.
- Matrix B's `on_clear` backing note (line 1340) is correct. `remove_cell` only queues (`rule_api.gd:281-282`), and hooks fire only from the clear loop (`board_sim.gd:1421-1423`).
- Arithmetic is right in F3, F4, F5 (G* = 44.2 and 14.7), F6 (p_def 0.50 and 0.29, L_peel 71), F6b (0.089 and 0.054), F7 (142 and 454), F8, F3b (1110 ms). I recomputed each.
- Matrix cells carry `[C]` / `[T]` / `[G n]` tags, so gaps are declared (lines 1300-1303).
- Why none is 9+: each item below has named open defects.

---

## 1. Rule unambiguity and completeness: 7.5

**Evidence for the score.** Conventions are stated once (3.1, lines 67-83). Entries use a fixed field order (line 138). R-1 to R-13 and the four order rules are explicit (lines 1355-1374). Layer-fill rule 4 (line 72) is correct against `board_state.gd:200-201` and `:94-96`.

**Why it is not 10 (open defects).**
1. **The `hung` rule leaves the slice-collapse behaviour undefined.** `shift_layers` treats any cell with `can_move` false as a "chamber bottom" (`board_state.gd:485-495`). A hung cube is therefore a floor for everything above it, and cubes beside it in the same layer drop past it. Nothing in 3.1b rule 3 (line 132), SH-05 (line 175) or edge case 32 (line 1808) says what happens to cells above a hung cube, or to the layer it sits in, when layers below clear. The doc says only "it floats". A programmer would have to invent this.
2. **Edge 9 and edge 32 contradict.** Edge 9 (line 1778): after the hang expires "it does not fall unless a slice collapse moves it". Edge 32 (line 1808): after expiry "the rule requests a settle and it falls". SH-05 (line 178) agrees with 32. 3.1b rule 3 (line 132) agrees with 32.
3. **Edge 16 contradicts the table.** Line 1789: "Anchored cells are never deactivated". Table line 100 and `board_state.gd:683-684` say MASKED removes anchored cells.
4. **Edge 13 is stale.** Line 1784 still calls `rescue_safe` "a proposal for the user to confirm" although it is DECIDED (lines 127, 2076).
5. **Edge 12 versus R-7.** Edge 12 (line 1783) says a blast "cannot complete a layer-clear-driven goal". R-7 (line 1369) says a blast that completes a layer clears it in the extra pass and counts as a clear. Both cannot hold without the distinction being stated.
6. **Gem first appearance is given three ways.** BK-33 intro says "Cave 01" (line 649). 3.4a row 8 says cave slot 02 (line 1416). 3.4a row 4 introduces "BK-33 pearl gems" in underwater slot 06 (line 1412), and ice, lava and underwater all precede cave in biome order. 3.4b says "the first appearance is its first row". The new-per-slot rule (F1) is unverifiable until this is fixed.
7. **"At most one new package per slot" is broken by the doc's own table.** Candy slot 03 adds OB-21 plus three items (line 1431). Candy slot 05 adds frosting plus the bomb item. Ice slot 04 adds thin ice plus hammer. Clockwork slot 05 adds OB-08 and OB-09 (line 1417) with no declared package. F1 counts "one item class" as a special (line 1569), so these are 2 new in one slot, against `new(n) <= 1` (line 1573) and 3.4b ("No two new specials share a slot", line 1424).
8. Smaller: SH-07 pin condition ("lowest arm lands in a 1-cell hole") never defines how a 3x3x3 jack's arm can reach a 1-cell hole against a belt (line 203). The "locked cube in a full layer ... unlocks and clears in the same resolve" (edge 35, line 1811) conflicts with the engine order. The `on_clear` unlock hook queues a status change, and the clear loop then tests `can_remove(CLEAR)` (`board_sim.gd:1424-1430`). The doc asserts it works but gives no test.

**Ranked fixes**
1. [owner: systems-designer] Define `hung` under `shift_layers` (chamber-bottom behaviour, ragged layer, what is above it), and add an AC. Co-sign: lead-programmer.
2. [systems-designer] Reconcile edge 9 / 32 / 3.1b rule 3 to one statement. Fix edge 16 (MASKED removes anchored), edge 13 (decided), and edge 12 versus R-7.
3. [level-designer + systems-designer] Resolve gem first appearance and the multi-new slots (candy 03, candy 05, ice 04, clockwork 05). Either split packages or amend F1/3.4b.
4. [systems-designer] Add the edge-35 test or an explicit hook-order note.

---

## 2. Formulas and tuning knobs: 7.5

**Evidence for the score.** Every F has an expression, a variable table, an output range and a worked example (lines 1565-1763). Directions are checked (F3 "Direction check", line 1619). Arithmetic is correct (see scoreboard). The `specials.json` skeleton follows the registry format (lines 1895-1906). Enforcement is honestly flagged as documentation-only (line 1893).

**Why it is not 10 (open defects).**
1. **F2 example mislabels the biome.** "Biome 5 (lava)" (line 1599). Lava is biome 6 (line 1403, `catalog.json:3-16`); biome 5 is pirate. The number is accidentally the same (3), but the example names a wrong biome in a doc whose r1 panel already got this wrong.
2. **Countdown defaults contradict.** F2 note (line 1599): 8 and 8 "stay as the Candy defaults". F6b (line 1694): the new default is 12 and 10. The knob table has both: line 1854 (8 / 8, range 5-16) and line 1874 (12 / 10, range 6-20). Two rows, two ranges, two defaults for the same knobs.
3. **`k_fair` is a knob with no formula.** Appendix C (line 2090) and the knob row (line 1886) give `k_fair` 1.5. F3 uses `k_free` 0.1 and F3b uses `k_int` 2 (line 1636). Nothing uses 1.5.
4. **Safe ranges break the doc's own fairness formula.** F3b's minimum warning is 1110 ms. Line 1867 `warn_ms` range 1000-3000. Line 1870 `claw_warn_ms` 1000-3000. Line 1879 `quake_warn_ms` 1000-3000. Line 1860 `pull_warn_ms` default 600, range 300-1500. All allow values below `T_warn_min`. Hazard-interval safe ranges also allow `spawn_every_locks` 2 (line 1844), which F3 rejects when `E_floor` = 3.
5. **F3 versus F5 caps.** F3 has `objects_max` 1-8 and `cells_blocked` up to 3 for goo (line 1613). F5 sets `goo_max` 12 (line 1664). At the F3 limit (k_free 0.1 x about 300 cells = 30), 12 goo x 3 cells = 36 fails F3 at the defaults. The two formulas never reconcile.
6. **F5 range is wrong.** G is stated as "G0 to G_max" (line 1665), but a wash lowers G below G0 (the doc's own example drops 12 to 9, and G0 is 2).
7. **F6 range contradiction.** `c_adj` is stated as 0.02-0.2 (line 1676) but its derivation gives `c x min(1, 3/L_s)`. At P_eff 24 and L_s 12 that is 0.0417 x 0.25 = 0.0104, below the floor.
8. **F9 default violates its own validator.** The validator is `gem_max_layer <= H_play - 4` (line 1738). At H_play 6 (the stated minimum, line 1733), f = 0.5 gives `floor(3)` = 3, which exceeds 2. Output range "3 to 8 gems" also ignores g0 = 1 (line 1731), where the minimum is 1.
9. **`hung_locks` / `hang_locks` duplicated.** Line 1876: `hung_locks` per shape (hook 4, claw 2, jack 3). Line 1889: `hang_locks` 4. SH-05 and AC19 use `hang_locks`. The JSON skeleton (line 1902) has a single `special.hung_locks` default 4, so per-shape values cannot be expressed. Jack 3 and claw 2 are not representable.
10. F6b's stability test compares `junk_rate` with `c` only (line 1685). It ignores that normal piece placement also adds layers, so "junk_rate < c" is necessary but not shown sufficient. Rationale is thin.
11. Two `p_item` rows (lines 1873, 1881) and no `p_item` slot in `specials.json`. F8 `P_i` ignores items unlocking from Chapter 2 on (the weight sum changes with 3.4c).

**Ranked fixes**
1. [systems-designer] One source of truth for countdown defaults (F2 note, F6b, both knob rows). Drop `k_fair` or define it.
2. [systems-designer] Clamp every ms-warning and `spawn_every_locks` safe range to F3 / F3b minima. Make the validator derive the minimum from F3b rather than a copied table.
3. [systems-designer] Reconcile F3 with `goo_max` x `cells_blocked`, and correct F5 and F6 ranges.
4. [systems-designer] Fix F9 for H_play < 7. Make `hung_locks` a per-shape map with one name.
5. [systems-designer] Correct the F2 biome label. Merge the `p_item` rows. Redo F8 `P_i` for the unlocked item set.

---

## 3. Interaction matrices and edge cases: 7.5

**Evidence for the score.** Matrix B rows 1-6 are exact copies of `can_remove` and `can_move` (lines 1330-1336). Matrix C cells carry line cites (`mushroom_popup.gd`, `goo_spread.gd`, `pest.gd`). R-7 "blasts do not chain" is verified: `earned_specials.gd:18` queues DAMAGE and hooks fire only in the clear loop. The slice-mode single clear round matches `board_sim.gd:1402`. Banned combinations follow from Matrix A gaps.

**Why it is not 10 (open defects).**
1. **A goal object is still deletable by the very causes that kill it in play.** Matrix B GOB column (line 1330-1336): DISPLACED Y, TRIM Y. Quake, woodpecker, squirrel, crab claw, bubble pop, tilt slip and wobble can delete a gem, key or critter cube. `goal_object` protects only DAMAGE and RESCUE. R-3 and R-9 cover actor critters but the cube critters (egg, mole, gem) are exposed. No rule or fairness note states that this is intended.
2. **Rescue column is wrong for `rescue_safe` (see item 4, defect 1).** Matrix B row 2, GOB = N, and edge 13 hold only if `wipe_bottom` is reworked; as built the object is removed by the CLEAR pass inside `shift_layers`.
3. **Matrix A is almost entirely `[G]`.** 28 of 36 cells are gaps, so the matrix documents absence, not behaviour. Honest, but the "banned combinations" table bans most of the pad / jelly / ice / sticky content in the same levels the biome table (3.4a) schedules together (ice slot 02 + 05; jelly slot 04; goo + pad). The validator would reject candy, ice and underwater levels listed in the doc until GAP-2 (6 days) lands. 3.4 does not say which levels are blocked on GAP-2.
4. **Edge 33 asserts flag-merge semantics the engine does not have.** `set_status` replaces the whole record (`board_state.gd:370`). Any shell write (frozen, burning) wipes `hung`, `blast_safe` and `rescue_safe` unless every writer merges. The doc says shells "never remove a flag" (line 1809) but sizes no merge change (GAP-3, line 1543, covers three one-line checks and the hang rule only).
5. **Pest / cause naming mismatch.** 3.1b says DAMAGE covers pest bites and frosting peel (line 92), but `pest.gd:27` (shoo) and `countdown_bomb.gd:14` (defuse) remove with `Cause.CLEAR`. Those cells would be refused if `anchored` / `locked`, and `items.gd:169` filters on CLEAR. The cause map in 3.1b is therefore incomplete for hooks that use CLEAR as a removal cause.
6. Edge-case numbering runs 29, 31, 32, 33, 34, 35, then 30 (lines 1806-1812). Cosmetic, but it breaks "refer by number".
7. Matrix A row text "[C] flight comes first" is asserted for GST+STK without a cited line for the order guarantee.

**Ranked fixes**
1. [systems-designer + lead-programmer] Decide goal-object exposure to DISPLACED / TRIM and write it in R-8/R-9 and Matrix B (add a `displace_safe`, or state that the level must avoid those hazards).
2. [systems-designer] Add the `set_status` merge requirement to GAP-3 and size it.
3. [systems-designer] Add a "blocked-on" column to 3.4a, listing levels waiting on GAP-2.
4. [systems-designer] Extend 3.1b with the CLEAR-as-removal-cause hooks (pest shoo, countdown defuse). Renumber edge 30.

---

## 4. Data model and flags (`hung`, `blast_safe`, `rescue_safe`, `goal_object`): 6.5

**Evidence for the score.** The flag semantics table is precise per cause (lines 106-108). The three flags are one-line additions to `can_remove` / `can_move`, which matches the code shape (`board_state.gd:681-695`). Flags live in the status dict, which `snapshot()` already serializes (`board_state.gd:653-654`), so replays stay deterministic. A skeleton `specials.json` and a registry-facts list exist (Appendix C).

**Why it is not 10 (open defects, ranked by severity).**
1. **`rescue_safe` does not protect a goal object in the real rescue path.** `wipe_bottom` (`board_state.gd:601-614`) first calls `remove(i, Cause.RESCUE)`, then `shift_layers(layers)`. `shift_layers` removes every cell in those layers with `Cause.CLEAR` (`:468-471`). `rescue_safe` blocks RESCUE only (line 108), so the gem, key, critter or cargo is removed by the second call. Edge case 13, decision 5 (line 2076, "makes `wipe_bottom` skip them"), AC18 and AC29 would all fail. The only things that survive today are the flagged `fixed` / `anchored` cells (which also block CLEAR). Unflagged tests pass trivially, so the test as written (AC29) does not catch the bug unless it asserts survival. Fixing needs a `wipe_bottom` change (skip layers or cells, or pass a rescue-aware cause), not "one line in `can_remove`". GAP-3 sizing (2.5 days) is therefore low and "makes `wipe_bottom` skip them" is not a one-line check.
2. **The status record is overwritten, not merged** (`board_state.gd:370`, see item 3 defect 4). Flags that share a dict with shells and counters (`hung` counter, `hits_left`, frosting count, `static_geometry`) are lost whenever a rule writes a new record. There is no merge contract.
3. **`goal_object` is both a flag and a shorthand.** Lines 131 and 2094 define it as "`blast_safe` plus `rescue_safe`", but AC18 / AC29 / R-8 sometimes say "carries `goal_object`" and sometimes the two flags. It is not in the 3.1b table, the skeleton, or Appendix F. A data author cannot tell whether to write one key or two, and the level validator has no key to check.
4. **`hung` has no stored form.** The doc says "a lock counter (`hung_locks`)" but never names the field in the status record, who decrements it, which hook, or how it serializes. The name collision `hung_locks` / `hang_locks` (item 2, defect 9) compounds this.
5. **`arch_safe` (edge 19, line 1792) and `hang` / `peg` markers are undeclared flags.** `arch_safe` is not in 3.1b, Appendix C or the skeleton. `hang` points are `fixed` + `static_geometry` props (line 745), but a "peg" and "hang point" appear both as cell kinds (BK-40, BK-42) and as props, with `kind_id` 25+ assignments not listed.
6. **Interaction of the three flags with `fixed` / `anchored` / `locked` is only stated for pairs.** The 3.1b table rows are single-flag. Edge 33 says they combine, but no combined row is given (for example `locked` + `rescue_safe`, `clear_protected` + `blast_safe`), and the `force` path (`remove(force)`, `board_state.gd:338`) is not addressed for the new flags.
7. **Versioning / migration:** The studio systems gate asks for versioning and save impact. The doc has no section on whether a mid-level save (`snapshot()`) with new status keys needs a version bump, nor a default for old snapshots without the keys.

**Ranked fixes**
1. [lead-programmer + systems-designer] Rework the rescue path: `wipe_bottom` must skip `rescue_safe` cells (and `shift_layers` must not CLEAR them). Re-size GAP-3. Rewrite AC18 / AC29 so they assert survival through `wipe_bottom`, not just `can_remove(RESCUE)`.
2. [lead-programmer] Specify the status merge contract (`set_status` merge, or a separate flags field).
3. [systems-designer] Make `goal_object` either a real flag or purely a level-data macro, and say which in 3.1b and the skeleton.
4. [systems-designer] Name the `hung` fields (flag, counter key, decrementing hook). Unify `hung_locks`. Declare `arch_safe` and combined-flag rows.
5. [systems-designer] Add a snapshot / replay version note for the new keys.

---

## 5. Testable acceptance criteria: 7.5

**Evidence for the score.** Each AC is tagged [U] / [V] / [M] and names the test location (line 1916). Rules ACs cite the line they reproduce (AC5-AC12). AC19b requires `can_remove` to match all six causes per row (line 1942), which is a strong, mechanical regression for 3.1b. AC29b requires a test per matrix cell and failing-first tests for gaps (line 1961). F7 values 142 and 454 are asserted exactly (AC15).

**Why it is not 10 (open defects).**
1. **AC18 and AC29 would pass or fail for the wrong reason** (item 4, defect 1). AC18 specifies that a rescue-safe gem "is NOT removed by `wipe_bottom`", which the described flag cannot achieve. AC29's flagged case would fail on the real engine.
2. **No AC for F2, F4 (beyond AC5 / AC13), F9 clamp, F10, F11, F6b.** F2 (interval), F10 (bag share), F11 (sprout phase switch) and F6b (junk_rate) have no acceptance test. F9's `gem_max_layer <= H_play - 4` is not tested, and the default violates it at H_play 6 (item 2 defect 8).
3. **No AC for the `hung` interaction with slice collapse** (item 1 defect 1) and none for chamber-bottom behaviour.
4. **No AC on the flag merge** (item 4 defect 2): a shell write must leave `hung` intact.
5. **AC20d refers to 29c** ("see 29c", line 1946) rather than stating a test. AC numbering is non-monotonic (19, 19b, 20, 20b, 20c, 20d, 21, ...).
6. **Subjective [M] thresholds:** "3 of 3 reviewers" (AC4, AC32), "3 of 4 playtests" (AC30), "9.7 or more" (AC33). These are testable in form but have no sampling or tester-definition, and AC30 "names its job" has no rubric.
7. **AC24 fixture is the 8.1 table, which itself violates the rule it tests** (item 1 defect 7: multiple new per slot in 3.4a). The AC would fail on the doc's own data unless the table is fixed first.
8. AC20c ("NOT ASSESSED ... never reports pass") is the only gate with a could-not-assess value; the other [V] gates (23, 24b, 26, 27) do not say what they report when the solver (gap G5) is not built. Per `.claude/rules/skill-authoring.md`, those need a NOT ASSESSED state or they pass silently.

**Ranked fixes**
1. [systems-designer + gameplay-programmer] Rewrite AC18 / AC29 to assert `wipe_bottom` survival with the full pipeline; add tests for hung + slice collapse and for status merge.
2. [systems-designer] Add ACs for F2, F6b, F9 bound, F10, F11.
3. [systems-designer] Give every [V] gate a NOT ASSESSED outcome when its input (solver, art skin, validator ranges) is missing.
4. [producer / qa-lead] Define the [M] sampling (who, how many, rubric) and renumber the ACs.

---

## Merged fix list (ranked, with owner)

1. **[lead-programmer + systems-designer] Fix the rescue path.** `wipe_bottom` plus `shift_layers` CLEAR removal defeats `rescue_safe`. Re-spec, re-size GAP-3, rewrite AC18 / AC29. (Items 3, 4, 5.)
2. **[lead-programmer] Status-record merge contract.** `set_status` overwrites; flags, counters and shells collide. (Items 3, 4, 5.)
3. **[systems-designer] Define `hung` in slice collapse** (chamber-bottom), name its fields, unify `hung_locks` / `hang_locks`, resolve edge 9 / 32. (Items 1, 2, 4.)
4. **[systems-designer] Make the formulas consistent.** Countdown defaults, `k_fair`, F3 versus `goo_max`, F5 / F6 / F9 ranges, F2 biome label, merge duplicate knob rows. Clamp safe ranges to F3 / F3b minima. (Item 2.)
5. **[systems-designer] Goal-object exposure** to DISPLACED / TRIM, and the full `goal_object` definition. (Items 3, 4.)
6. **[level-designer + systems-designer] Slot budget.** Gem first appearance, and the slots with two new things (candy 03 / 05, ice 04, clockwork 05). Add a "blocked on GAP-2" column. (Items 1, 3.)
7. **[systems-designer] Acceptance gaps.** Tests for F2 / F6b / F9 / F10 / F11, hung + collapse, status merge. NOT ASSESSED states for [V] gates. (Item 5.)
8. **[systems-designer] Housekeeping.** Edge-case renumbering and stale text (13, 12 versus R-7, 16), 3.1b cause map for CLEAR-as-removal hooks, snapshot version note. (Items 1, 3, 4.)

Single-expert note: this is one expert's report. Per the panel rules, an item passes only when all three experts score it 9.7 or more; this report scores nothing above 7.5.
