# Moving platform core (G8) - round 1 - gameplay programmer (blind)

Method: read all listed files, ran only `tests/unit/track/track_runner_test.gd` (14 cases, 0 failures, 0 errors, exit 0).
Scored as an engine core with placeholder visuals. Pass mark 9.7. Start at 5, earn each point. Any open defect caps at 8.5.

## Scoreboard

| Item | Score | Pass | Why it is not higher (short) |
|---|---|---|---|
| G1 Correctness and determinism | 8.0 | FAIL | Integer micrometre position and tick loop are sound, but restart leaves moved blocks behind (D2) and the crosswind order rests on an unstable sort (D7). |
| G2 Architecture fit | 8.0 | FAIL | Clean def / runner / effects split and all board writes go through RuleApi, but the runner owns restart policy, the rule has no restore, and view and sim are not wired (D1, D8). |
| G3 Test quality and coverage | 6.5 | FAIL | 14 green tests, but crosswind, updraft height lift, restore-then-continue, restart replay, the rule glue, the follower and the stage hooks are untested or only checked by shape (D4). |
| G4 Data-driven tuning | 7.5 | FAIL | Numbers are in JSON, but unknown or missing keys silently default to 0 or "wipe the board", and there is no schema or validation of event params (D5). |
| G5 Robustness and edge cases | 6.5 | FAIL | Restart ignores the falling piece and queued writes, cargo is checked only at track events, and top-out, line clear and snapshot of the rule are not handled (D2, D3, D6). |
| G6 Readiness for race levels | 5.0 | FAIL | Not built end to end: nothing calls the stage hooks, no level uses the rule, no lean, no rival, no preview consumer, no goal binding (D1). |

Overall: FAIL. Every item is under 9.7. No score of 9 or more is given, so no 3-citation proof is needed; the evidence for each cap is below.

## What is good (earned points)

- Position is integer micrometres, `speed_mm_s * tick_ms` (track_runner.gd:62), no float in the sim. progress_pm is integer (track_runner.gd:74).
- dt accumulation with a barrier carries the remainder (track_runner.gd:51-62). Chunking is tested (track_runner_test.gd:86-96).
- Own seeded stream, `Seeds.make_rng(seed, ["track", id])` (track_runner.gd:40). The rng state is in the snapshot (track_runner.gd:116).
- Effects write only through RuleApi and keep a read overlay for queued writes (track_effects.gd:10, 48-52, 75-78). This is the right answer to the queue problem.
- Checkpoint-before-event tie order and an event exactly at the end fire before finish (track_runner.gd:55, 152).
- TrackDef validates kind, range, on_loss (track_def.gd:176-197). The preview is pure (track_def.gd:96-105).

## Ranked defects

### D1 (critical, G6/G2) The core is not wired to anything a player can run

- `attach_track` and `set_track_progress` have no caller outside wt_stage.gd (grep over src, tests, assets: only the definitions at wt_stage.gd:1397, 1406). `MovingPlatformRule.runner()` exists "for the view hook" (moving_platform.gd:25) but no hook reads it.
- No level JSON uses the rule: `assets/data/levels` has no meadow_03 or meadow_bonus, and the only track is `meadow_brook_run.json`. There is no kite track for meadow_bonus (design/levels/levels.md:386-410).
- Runner records (`track_event`, `track_cargo_lost`, `track_restart`, ...) are emitted to `api.emit` but wt_stage.gd's event switch has no track case (it matches e.g. `syrup_band` at wt_stage.gd:168). No sound, giggle or basket spill can fire.
- No goal consumes `track_finished` or `track_progress_pm` (track_runner.gd:14-16, 232). meadow_03's win is "reach the lawn with the basket" (levels.md:131-160); nothing turns the metric into a win.
- No preview-strip consumer calls `TrackRunner.preview()`; the UI list in the doc is not built.
- `rules/moving_platform.json:10-12` declares `track` with only `type`; no default, no required flag, no description.
- Cap: not built, G6 <= 7; scored 5.0.

### D2 (high, G1/G5) Restart can leave blocks on the board and ignores queued writes

- `_restart_from_checkpoint` clears by reading `api.kind_at` (track_runner.gd:210-215). `kind_at` sees the committed board only. The same step may already hold queued writes from the event that caused the loss (arch removals, crosswind `move_cell`).
- Crosswind queues `move_cell(c, dst)` (track_effects.gd:121) and the same event can then fail the cargo (`max_drop_layers` check, track_runner.gd:195). The restart then clears the old `c` (empty by flush time) but never the `dst`, so the moved block survives "the blocks giggle away". The design says all blocks go (levels.md:155).
- Fix: clear from the TrackEffects overlay as well, or drive the restart through a separate `board_reset` request/hook the session already applies, so it runs after the queued writes. Add a regression test: crosswind + cargo loss in one event, assert `_cell_count == 0` after flush (watch it fail first, per test-standards.md).

### D3 (high, G5) Cargo and restart ignore the rest of the game state

- Cargo is checked only inside `_fire_event` (track_runner.gd:186-189). A seat dropped by a line clear, a top-out trim or a rescue policy never loses the basket; `_cargo_seat` is written (track_runner.gd:187) and snapshotted but never read, so it is dead state. The kite "tips and spills" lose (levels.md:386-410) cannot be triggered by player mistakes between events.
- Restart does not touch the falling piece, hold, next queue, score, or goal counters, and `track_progress_pm` simply goes backwards (track_runner.gd:63, 216). A progress-latching goal would keep the old maximum.
- Arch and bump removals use `Cause.TRIM` / `Cause.DISPLACED` (track_effects.gd:76, 100). Nothing proves how the trim top-out policy (src/mechanics/goal/trim_top_out.gd) or the score/clear logic treats them, and no test covers a bump that happens while the stack is at the limit.
- The cargo cell position (x, z) is not checked against the board size anywhere (track_def.gd has no cargo validation); a wrong x,z reads `column_height` = 0 forever and the basket never falls.

### D4 (high, G3) Test gaps

- No test for `MovingPlatformRule` (hook wiring, `_last_ms` dt, bad track id, `on_level_start` twice). moving_platform.gd has zero coverage.
- Crosswind has no behavioural test; it appears only as an event in the determinism test (track_runner_test.gd:87) whose result is a count tuple, so a wrong slide still passes. Missing: edge blow-off, leeward ordering, inactive-cell blocking.
- Updraft test uses `height_pct_per_layer: 0` (track_runner_test.gd:10), so the "height lifts the kite faster" formula (track_runner.gd:141-143) is never exercised.
- `test_snapshot_restore_round_trips` (track_runner_test.gd:181-188) compares the dict with itself after restore. It does not prove that a restored runner continues identically to the original. Add: snapshot, run N, record; restore, run N, compare records and board.
- Not tested: restart replays events after the post with `_next_event` rewind (track_runner.gd:221-226); a loss before the first post; a second loss; fail mode asserting `request_fail` was queued (test at :161-168 only checks `is_failed`); `step` after finish; `dt = 0`; events and a checkpoint at the same mm; the bump `tall_layer` path alone; `TrackDef` validation of each error branch (only one invalid case, :62-64); `preview()` from the runner; WtTrackFollower; the two stage hooks.
- The determinism loop runs `[50, 50, 10]` (track_runner_test.gd:89), so the first two runs are identical by construction; one is wasted. Use 50, 10, 33 (33 is not a divisor of the tick) to prove chunking.
- The sample-track test reads the real JSON file (track_runner_test.gd:4, 53); a unit test should not depend on shipped data, but a separate data-smoke test would be fine.
- Test fixtures embed magic numbers in a few places (the bump pct and the tick); acceptable as boundary values.

### D5 (medium, G4) Tuning is data-driven but not safe

- Missing or mistyped effect keys fall back silently: `loose_pct_per_force` 0, `tall_layer` `1 << 20`, `slide_pct` 0, `max_drop_layers` `1 << 20` (track_effects.gd:86-87, 113; track_runner.gd:195). A typo disables the mechanic with no error.
- `_arch` ignores its cfg and a missing `gap_layers` defaults to 0, which wipes the whole board (track_effects.gd:96). Validation does not require `gap_layers`, `force`, `duration_ms`, `dir` (valid tokens only: unknown dir silently becomes +x, track_effects.gd:128-133) or cargo keys (track_def.gd:176-197).
- `tick_ms` default 50 and kind constants are code, acceptable as defaults; the speed step between segments is a hard jump with no easing field.
- There is no schema document for `assets/data/tracks/*.json` beyond the architecture table, and the meadow_brook_run numbers have no rationale (data-files.md rule: numbers need a companion explanation).
- `height_pct_per_layer` lives under `effects.updraft` but is read by the runner directly (track_runner.gd:141), bypassing TrackEffects.

### D6 (medium, G5/G2) Snapshot and restore are incomplete at the rule level

- `MovingPlatformRule.snapshot()` exists (moving_platform.gd:40-41) but there is no `restore`, and `_last_ms` is not captured. A rollback would re-derive dt wrongly.
- `restore()` reads keys with `s[...]` and no validation (track_runner.gd:120-134), and does not check the snapshot belongs to the same def (id or length). `_barrier` is intentionally transient; confirm that snapshots are never taken mid-step.
- `step` does not run when the level is paused only if `level_ms` stops; this is assumed, not asserted or tested.

### D7 (medium, G1) Crosswind order depends on an unstable sort

- `cells.sort_custom` on the leeward key (track_effects.gd:109) compares only one axis, so cells tied on that key have an engine-defined order, and each of them consumes one `randi_range` in that order (track_effects.gd:113). Deterministic in one build, but not guaranteed between engine versions or platforms (cross-machine determinism is the stated promise in track_runner.gd:3-4).
- Fix: break ties with y, then the other axis, so the order is total.
- A one-cell slide also splits multi-cell pieces and moves a loose cell above a cell that stays; unspecified in the design, flag to game-designer.

### D8 (medium, G2) Design behaviour that is claimed but absent

- Biscuit's lean ("Biscuit's weight adds a lean to one side", levels.md:155 area) has no hook in the sim.
- "A tall stack catches more wind" (kite, levels.md:386-410): crosswind ignores height; only bump uses `tall_layer`.
- "Events come more often" per section is only authored data, not a pattern the validator or generator checks.
- The runner constructs `TrackEffects` on every event (track_runner.gd:172) and scans the whole board per event (track_effects.gd:59-68). Fine at 8x8x10; note for taller boards.
- Doc says the "cart and basket are both upright" and `down = -y` only (moving-platform.md:48), but nothing asserts it at `_start`; a board with another down axis would silently misbehave (`layer == y` assumed, track_effects.gd:5-6, 72).

## Concrete fixes and owners

| # | Fix | Owner |
|---|---|---|
| 1 | Wire the stage: a session/view hook that calls `attach_track` on load and `set_track_progress(runner.position_mm())` each frame; route `track_*` records to stage and audio; bind `track_finished` to a win goal. | lead-programmer (core, session) with ui-programmer (preview strip) |
| 2 | Author meadow_03 and meadow_bonus level JSON using the rule; add the kite track file. | level-designer, gameplay-programmer |
| 3 | Fix restart to clear through overlay or a reset request; add the crosswind-plus-loss regression test and watch it fail first. | gameplay-programmer |
| 4 | Decide and implement restart scope (falling piece, hold, counters, progress metric) and cargo checks on any board change, not just track events; remove or use `_cargo_seat`. | lead-programmer with game-designer (rules for what resets) |
| 5 | Add tests listed in D4, including rule glue, restore-then-continue and restart replay. | gameplay-programmer |
| 6 | Strengthen TrackDef validation (per-kind required params, cargo keys and bounds, dir tokens, effect-key typos) and write a JSON schema doc plus rationale for the sample numbers. | gameplay-programmer, systems-designer (numbers) |
| 7 | Total order for the crosswind sort; add a rule `restore()` that includes `_last_ms`. | gameplay-programmer |
| 8 | Specify lean and height-dependent wind; implement after sign-off. | game-designer, then gameplay-programmer |
| 9 | Confirm top-out and score treatment of `TRIM` and `DISPLACED` causes with a test. | lead-programmer |

## Unverified

- Whether the rule registers automatically through its JSON `behaviour` key (no registry seen in a quick search, only the syrup_band preload in src/game/atom_lab.gd:3). I did not confirm it; if no registry loads `moving_platform.gd`, the rule never runs.
- D2 is from code reading (queue order vs committed `kind_at`), not from a run; I did not write a test, per the one-file rule.
