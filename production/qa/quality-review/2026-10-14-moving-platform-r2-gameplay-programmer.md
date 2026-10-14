# Moving platform core (G8) round 2: gameplay programmer review

Blind reviewer. Judged as an engine core with placeholder visuals. Ran only `track_runner_test.gd` (20/20 pass) and `track_rule_test.gd` (5/5 pass).
Pass mark 9.7. Any open defect caps a score at 8.5.

## Scoreboard

| Item | Score | Why it is not higher |
|---|---|---|
| G1 correctness and determinism | 8.5 | D1 (clock refund), D7 (stale read after a rule-external write), D12 (event shorter than a tick does nothing) |
| G2 architecture fit | 8.0 | D4 (restore leaves the view detached), D9 (per-tick full-board rescans), D11 (assert-only guards) |
| G3 test quality and coverage | 7.5 | D5: no stage/follower test, updraft speed effect, fall request, restart arithmetic, hysteresis and tie-breaks untested |
| G4 data-driven tuning and validation | 7.5 | D3: silent defaults and missing range checks; malformed shapes crash the loader |
| G5 robustness and edge cases | 7.0 | D2 (bad track = unwinnable level), D3, D4, D8 |
| G6 readiness for the race levels | 6.5 | D6: no level wiring, no HUD, no balance sim, no survival bot, no screenshot |

Strengths, with evidence: integer micrometre position and milli-permille accumulators (`track_runner.gd:55,58,229`), step-size invariance tested at 50/10/33 ms (`track_runner_test.gd:171-181`), and explicit tie-break keys (`track_effects.gd:97-104,142-143`).
Snapshot/restore continuity is tested (`track_runner_test.gd:328-339`). The queued-wipe regression is fixed and covered (`rule_api.gd:286,465-468`, `track_rule_test.gd:116-126`). Data keys are all required (`track_def.gd:28-30,306-311`).
Not 10 because of the defects below.

## Ranked defects

1. **D1 (G1, design-unclear) The restart refunds all time driven since the post.** `track_runner.gd:366` sets `_elapsed_ms = _cp_elapsed_ms + restart_penalty_ms`.
   - A loss 40 s past a post costs 8 s, not 48 s. Because the platform moves on its own, the clock never binds without losses, and every loss costs a flat 8 s whenever it happens.
   - Brook Run has 40 s of slack (`meadow_brook_run.json:4-5`) and Docs say "adds the penalty" (`moving-platform.md:16`). The tests never assert the post-restart `time_left_ms` (`track_runner_test.gd:305-318`).
   - Fix: game-designer to confirm the intended rule. The runner then either keeps elapsed and adds the penalty, or documents the refund and adds a test of the clock arithmetic. Owner: game-designer, then gameplay-programmer.
2. **D2 (G5/G6) A track that fails to load leaves the level unwinnable and silent in release.** `moving_platform.gd:60-63` returns after `push_error`; the goal then sits at RUNNING forever (`track_race_goal.gd:34-40`). `track_rule_test.gd:98-102` locks that behaviour in.
   - Fix: on a bad track call `api.request_fail` or surface a level-load error, and have `track_race` report LOST when no runner exists. Owner: gameplay-programmer.
3. **D3 (G4/G5) Validation has gaps and silent defaults, against the doc's rule "a missing parameter is a validation error, never a default".**
   - `tick_ms` defaults to 50 and `on_loss` to "checkpoint" (`track_def.gd:74,79`).
   - No range checks on `relax_pm_per_s`, `hysteresis_pm`, `spill_relief_pm`, any cargo rate, `restart_penalty_ms >= 0`, or `duration_ms >= tick_ms` (`track_def.gd:293-303,321-325`). A 30 ms updraft yields 0 ticks (`track_runner.gd:332`).
   - The preview-lead check stops at the first failure and tests lead at the event's own speed only (`track_def.gd:286-290`).
   - A wrong-typed shape crashes the loader instead of adding an error (`track_def.gd:80-82,215,249-250`; for example `"effects": []`).
   - Fix: add range and type guards, collect every error, make the schema fields required. Owner: gameplay-programmer.
4. **D4 (G2/G5) Rule restore leaves the view and fall slot out of sync.** `moving_platform.gd:45-57` rebuilds the runner but emits no `track_started`, so `attach_track` (`wt_stage.gd:172-175`) never runs and `set_track_progress` silently no-ops while `_track_follower == null` (`wt_stage.gd:1417-1419`).
   - Test `track_rule_test.gd:93-95` only compares snapshots, not the view contract. Fix: re-announce on restore (or on the first tick after it) and test it. Owner: gameplay-programmer.
5. **D5 (G3) Test gaps.**
   - No test covers the stage sync (`wt_stage.gd:172-182`), the follower (`wt_track_follower.gd`), `track_progress` records, or the `fall.gravity_scale` request (`track_runner.gd:407`).
   - The updraft test checks only the reported `lift_pct`, never that position gains speed (`track_runner_test.gd:227-240`).
   - There is no test for hysteresis re-arm (`track_runner.gd:245`), seat/spill tie-breaks, a `time_up` at the finish boundary (`track_runner.gd:387`), `on_loss: fail` metrics, or a failure after a restart.
   - Shipped tracks are only checked for validity and base drive time (`track_runner_test.gd:133-138`), not for survivability.
   - `T.run` drains 20 empty steps (`track_fixture.gd:61-64`), which can hide carry-over bugs.
   - `track_runner_test.gd:194` has a garbled comment; the 150 threshold at `:284` is loose.
   - Fix: add these tests. Owner: gameplay-programmer, with qa-lead to review.
6. **D6 (G6) Not ready for levels.** `meadow_03` and `meadow_bonus` are not wired (`moving-platform.md:98-102`), there is no HUD meter or preview strip UI (`:10-11`), no build-rate simulation behind the tuning numbers (`:86`), no survival bot, and no retained screenshot of the follower. The tuning is unproven.
   - Fix: level-designer wires the two levels; ui-programmer builds the lean meter and preview strip; gameplay-programmer writes the bot; capture a screenshot into `production/qa/evidence/`.
7. **D7 (G1) Tick evaluation reads a board that excludes other writers' pending writes.** `track_effects.gd:197` reads `_api.kind_at`. The barrier only protects the runner's own writes (`track_runner.gd:251,340`), so a write queued by another rule in the same hook is invisible.
   - Fix: document it in the ADR, or have the runner flush or read through the queue. Owner: lead-programmer.
8. **D8 (G5) Follower gaps.** No `gust` colour (`wt_track_follower.gd:98-100`, falls back to white). `set_progress` dereferences a null `_def` if called before `setup` (`:123-125`). Fix: add the colour, guard null. Owner: technical-artist.
9. **D9 (G2) Per-tick cost.** A new `TrackEffects` is built each tick (`track_runner.gd:233`), and `com_pm`, `cell_count`, `stack_layers` and `seat` each rescan the whole board (`track_effects.gd:63-72,205-220`). Fine now, wasteful on tall boards. Fix: compute heights and cells once per tick and cache them. Owner: gameplay-programmer.
10. **D10 (G6) Gust preview row key.** `track_def.gd:205` uses a different key shape from the other kinds; the future strip UI must special-case it. Fix: agree the row contract with ui-programmer.
11. **D11 (G2) Constructors guard with `assert` only** (`track_runner.gd:68`, `wt_track_follower.gd:110`), so a release build crashes on an invalid def. Fix: the callers already check, so this is low; add a defensive early return.
12. **D12 (G1) Truncating integer division on impulse (`track_runner.gd:239`) and a gust of tiny amplitude (`track_effects.gd:36`) can silently zero small effects.** Document the rounding in the tuning table.

## Fixes with owners

| Fix | Owner |
|---|---|
| D1 confirm the clock rule and test it | game-designer, gameplay-programmer |
| D2 bad track handling and goal LOST | gameplay-programmer |
| D3 validation hardening | gameplay-programmer |
| D4 restore re-announce and test | gameplay-programmer |
| D5 missing tests | gameplay-programmer, qa-lead |
| D6 wiring, HUD, bot, screenshot | level-designer, ui-programmer, gameplay-programmer, technical-artist |
| D7 board-read contract | lead-programmer |
| D8 follower gaps | technical-artist |
| D9 caching | gameplay-programmer |
