# meadow_01 "Stump Day" mechanics build: systems designer review (2026-10-15)

Lens: systems designer. Build review against `design/levels/meadow/meadow_01.md` (incl. Decisions 2026-10-15).
Method note: the Bash tool was not available to this reviewer, so the allowed gdUnit run
(`tests/unit/levels`) was NOT executed. Test results are unverified; scores below come from reading code and tests.
Marking: start 5, open defect caps 8.5, pass = 9.7 on every item. No item passes.

## Scoreboard

| # | Item | Score | Pass (9.7) |
|---|---|---|---|
| 1 | Rule correctness vs spec | 8.0 | FAIL |
| 2 | Numbers and formulas, in data | 7.5 | FAIL |
| 3 | Edge cases | 6.0 | FAIL |
| 4 | Piece bag and tileability | 5.0 | FAIL |
| 5 | Test coverage quality | 6.0 | FAIL |

## 1. Rule correctness vs spec: 8.0

Earned:
- Grip order left roots, right stones, rim matches the spec table: `meadow_01.json:53-129` vs spec section 3 table (x0-1 z2-5; x6-7 z2-5; rim rows z0, z1, z6, z7).
- Rim rects sum 4+6+6+4 = 20; 16+8+8+20 = 52, the spec's round mask. Stage widths 4, 6, 8 and counts 16, 24, 32 (test `meadow_01_grip_release_test.gd:51-69`).
- Columns released on every layer: `board_state.gd:420-434` `set_active` loops all `_size.y`; rule calls `request_mask` per column (`grip_release.gd:43`); test checks y = 0, 5, 11 (`grip_release_test.gd:72-84`).
- One grip per cleared layer, not per cell: `_seen` key chain_round:layer (`grip_release.gd:26-29`).
- Win on 3rd: `goal clear_n n=3` (`meadow_01.json:45-48`); extra clears are ignored (`grip_release.gd:35`).
- Rescue never releases: the rule only subscribes to `on_clear` (`grip_release.gd:13`) and `rescue_top_out.gd` never emits a clear.

Defects:
- D1 (open). Two layers cleared in one lock or resolve (chain or gravity settle) give two keys, so two releases in one tick. The spec says "any full layer counts" but is silent on the multi-clear case. Behaviour is undefined and untested. The goal counter and the grip counter could diverge (win at `layers_cleared == 3` while `_released` is still 2).
- D2 (open). Partial layers after widening: the spec says half-filled layers now need the new cells. Nothing in the tests checks that a layer filled at 4 wide is NOT full after widening to 6 (clear detection reading the new active count). Only `active_in_layer` is checked.
- D3. `_seen` is cleared on `on_lock` and `on_resolve_end` only. If `on_clear` for round-1 layer 0 arrives after a mid-resolve `on_lock`-less path, a double release is possible. This needs an explicit invariant test.
- D4. The doc comment (`grip_release.gd:2-3`) says "switches cage columns ON", but the spec says the cage is "switched on at load and off at each grip". The inverse polarity is a naming trap (the data is "pit mask", the spec is "cage"). Not wrong, but confusing for the next maker.

Why not 10: D1 and D2 are untested rule semantics; the rule has no explicit multi-clear policy.

## 2. Numbers and formulas, in data: 7.5

Earned:
- All values live in data: `g0` 1.2, lock delay, resets, entry delay, preview, hold, randomizer, warnings 3, rescue.layers 3 (`meadow_01.json:30-44`); ramp 1.25 and cap 3.0 in rule params (`:130-131`); star bounds (`:135-141`); `rescue.layers` is a registered knob (`goals.json:102-112`, default 0, max 8).
- Rule schema bounds the ramp (`grip_release.json:10-11`).
- Ramp = min(cap, 1.25^k): 1.25, 1.5625, 1.953125 are tested (`grip_release_test.gd:96-110`).

Defects:
- D5 (open). `g0` 1.2, ramp 1.25, rescue layers 3, star bounds 22/28 and warnings are all still "TO BE MEASURED" (`meadow_01.json:140,197`). No G6 bot measurement exists. Numbers are unvalidated guesses.
- D6. The cap never binds: with 3 releases the max multiplier is 1.953 < 3.0, so the cap is dead data and the clamp branch (`grip_release.gd:47`) is untested. The spec cap is "3x g0"; the code caps the scale, and `fall.g_max` (default 6.0, `fall.json:26-31`) is an unrelated second clamp. Two caps, one meaning. Pick one.
- D7. Star formula (`star_rater.gd:38-47`): the 2-star test is `rescues <= 1 OR pieces <= 28`. A player with 0 rescues and 60 pieces still gets 2 stars, and 1 star needs 2+ rescues AND over 28 pieces. The spec says 2 stars is "one rescue or some waste", but the OR means waste is effectively uncapped at 2 stars. The minimum is 18 pieces (4+6+8), so the 3-star limit of 22 allows 4 wasted pieces; that was not derived from any bag simulation. The formula has no variable table in the spec.
- D8. `stars.status` is free text inside the numeric block (`meadow_01.json:140`). It is not a documented schema field.
- D9. `rescue.layers` is a level knob with default 0 meaning "use the F3 formula", so two formulas coexist. `fixed` is read via `api.knob` and type-checked as INT. A float in JSON silently falls back to F3 (`rescue_top_out.gd:37-39`). The test passes an int, so the JSON path is untested.

Why not 10: nothing measured, a dead cap, and a star formula that does not enforce the spec's waste idea.

## 3. Edge cases: 6.0

Covered: extra clears after the third release (`grip_release_test.gd:124-129`); per-cell versus per-layer (`:87-93`).

Defects (all untested):
- D10. Clear during rescue: no test or code guard when a lock's clear lands in the same resolve as a top-out wipe. Order of `on_clear` against `wipe_bottom` is undefined.
- D11. Top-out on the release tick: a clear that widens the pit while the stack is at the red line. No test of whether `over_limit` is re-evaluated after the clear, nor of the rescue count consumed.
- D12. Multiple layers cleared at once (see D1). No test and no stated policy.
- D13. Restore and replay determinism: `snapshot()` (`grip_release.gd:51-52`) returns `released` and `seen`; `restore` relies on the base class generic property walker (`rule_behaviour.gd:36-44`) mapping `_released` and `_seen`. Nothing tests snapshot, restore or a replay hash. The spec asks for "Replay determinism with a logged seed". Not delivered.
- D14. Rescue wipe in a widened pit (after a release) is never tested. The rescue test uses a plain 4x4 board with no rule (`meadow_01_hud_rescue_test.gd:45`).
- D15. The wipe removes the lowest 3 layers. The spec says the grip meter is never reset; the test only checks that the rule saw no `mask` request, not that `_released` is unchanged.

Why not 10: the spec's four named edge cases have no test and no stated behaviour.

## 4. Piece bag and tileability: 5.0

Evidence for what exists: `pieces.shapes` = o, i, l and `spawn.randomizer = bag`, `preview_count 1`, `hold_enabled false` (`meadow_01.json:23-36`); a level-data assertion on shapes (`grip_release_test.gd:138`).

Defects:
- D16 (major). No tiling solver, no bag simulator, no 98% statistic. Acceptance criterion 9 ("every stage tiles with O, I and L in at least 98% of seeds") has no evidence. Grep of `tests` for meadow plus bag or tile finds nothing.
- D17. The tileability reasoning is not recorded. 16, 24 and 32 are multiples of 4, but an I (4x1) in a 4 wide pit fits only along the axis; an L (3 cells) plus O (4) plus I (4) = 11 cells per bag of 3, which does not divide 16, 24 or 32. A bag of O, I, L therefore cannot fill a layer on its own, and L has 3 cells in a layer if flat, so L-only parity matters. Needs a solver, not a claim. (Cell count of the L shape was not checked in the shape bank by this reviewer.)
- D18. The seed is "new every attempt, logged": no test of seeded bag reproducibility for this level.
- D19. The spec's fallback ("add a second L before changing shapes") has not been tried or ruled out.

Why not 10: tileability is the central fairness promise of the level and is unproven.

## 5. Test coverage quality: 6.0

Earned: 11 tests across two files; data-driven (read the real JSON); source and production JSON equality (`grip_release_test.gd:143-145`); level loads in sim with warnings 3 and 16 cells (`:147-154`); neat star table (`hud_rescue_test.gd:64-71`).

Defects:
- D20. `test_rescue_without_clear_releases_no_grip` (`grip_release_test.gd:113-121`) is vacuous: it never sends a rescue through the sim, it just calls `board.wipe_bottom` and does not call the rule. It cannot fail if the rule were broken to react to a wipe. By the test standard, a gate never seen failing is not a gate.
- D21. `test_speed_multiplies_1_25_per_release` (`:96-110`) runs the rule against two APIs, and the first loop result is discarded (`scales` is only read from the second). It is confusing and tests only the formula, not that the sim's gravity actually rises (`board_sim.gd:851-856`).
- D22. `test_level_loads_and_wins_on_third_clear_in_sim` (`:147`) is misnamed: it never plays or wins, it only loads and checks 16 cells.
- D23. The tests use hand-fed `on_clear` events and never a sim integration where three real layers clear and the goal fires on the third. "Win on 3rd" is verified only by reading `n == 3`.
- D24. Nothing for the cap, the multi-clear, restore, replay, partial layers, bag, tiling or an input_simulate path.
- D25. `test_neat_stars` is correct for the code but encodes D7 (0 rescues and 40 pieces gives 2 stars, line 68 says 1 rescue and 40 pieces gives 2).
- D26. The suite was not run by this reviewer (no Bash). Pass state unverified.

Why not 10: missing edge, determinism and tiling tests, one vacuous test, and no end-to-end win test.

## Ranked fixes (owner)

1. [systems designer + main session] Build the bag/tiling simulator (G5/G6): 1-lookahead, no hold, per stage 16, 24, 32, at least 98% of seeds; plus measured `g0` and star thresholds. Record the results in the spec and the knobs; remove the "TO BE MEASURED" tags. Add a unit test that runs a small deterministic seed set. (D5, D16-D19)
2. [main session + gameplay programmer] Define and test the edge policies: multiple layers in one resolve (one grip per layer or one per lock; keep `layers_cleared` and `_released` in lockstep); clear during rescue; top-out on the release tick; partial-layer fullness after widening. (D1-D3, D10-D12, D14)
3. [main session] Add snapshot, restore and replay determinism tests (same seed gives the same hash; restore mid-level keeps `_released`). Fix the vacuous rescue test to drive a real sim rescue, and add an end-to-end sim test that wins on the third clear. (D13, D15, D20-D23)
4. [game designer / systems designer] Decide the star rule (require both rescues and pieces for 2 stars, or state the OR on purpose), document the formula with a variable table, and move `stars.status` out of the numeric block. (D7, D8, D25)
5. [systems designer] Resolve the two caps: either make the cap bind (a ramp that can reach 3.0) or delete `ramp_cap_mult` and rely on `fall.g_max`; add a clamp test. (D6)
6. [main session] Make `rescue.layers` accept a float-valued JSON integer or validate it at load; add a test through the JSON path. (D9)
7. [main session] Rename or fix the misnamed test and the rule doc comment polarity. (D4, D21, D22)
