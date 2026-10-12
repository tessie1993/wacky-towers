# MB-031 / CH-064, CH-166, CH-066, CH-167 BoardSim spawn, gravity, move, rotate, drop, lock
| Final path | Action | See it working |
|---|---|---|
| src/core/sim/board_sim.gd | replace (extends CH-035 skeleton; same constructor and API) | Build a BoardSim from meadow_01 (catalog with plugins). Step 179 ticks: COUNTDOWN, no piece; tick 180: FALLING, one PIECE_SPAWNED, `get_piece()` set, `ghost_cells()` at the floor. ~100 ticks at g0 0.6: one PIECE_MOVED fall. Queue CMD_MOVE xN at a wall: PIECE_MOVED move, then PIECE_BLOCKED. CMD_SOFT_DROP_ON: falls ~10x faster. CMD_ROTATE [Y,+1] x4: orient returns, 4 PIECE_ROTATED. CMD_HARD_DROP: PIECE_MOVED drop, GRACE, 150 ms later PIECE_LOCKED hard_drop (holes_added), CELLS_CHANGED, new spawn ~200 ms later. Resting with no input locks at 500 ms (delay); second hard drop in grace locks at once (commit). |

Depends on integration of: Movement + KickTable (MB-021, src/core/sim/), TopArrival + bases (MB-016, incl. GoalEvaluator/TopOutPolicy), BoardState (live). Spawner, ActivePiece, SimCommand/SimEvent already live.

Notes
- Bare-clock mode kept: a level with no boards or an empty catalog (existing sim tests, Replay with `LevelData.new()`) still echoes every command as COMMAND_APPLIED.
- `CMD_COUNTDOWN_RESTART` (&"countdown_restart") is a const on BoardSim, not SimEvents (not player input; SimEvents not in my scope). Build it with SimCommand.make.
- `board()` accessor added (hud_snapshot wants it). Only boards[0] is simulated.
- Blocked spawn emits LEVEL_FAILED {reason: spawn_blocked} and phase ENDED until CH-068.
- Resting test is `Movement.drop_distance == 0` (matches the fall step, also true over masked-out cells), not `is_resting`.
- Lock stand-in until CH-068: RESOLVING for fall.entry_delay_ms, then WAITING and spawn. P3 veto, S2-S10 not run.
- Rotation axes: any non-empty control.rotation_axes_enabled enables all 3 world axes (MVP, per ticket).
- No tests (user rule).

## CH-068 included (per-lock resolve, warning phase, level end, stars, score)
| Final path | Action | See it working |
|---|---|---|
| src/core/sim/board_sim.gd | replace (this staged file now includes CH-068) | meadow_01: fill one layer, lock the last piece: PIECE_LOCKED, CELLS_CHANGED, LAYERS_CLEARED {n_layers 1}, CELLS_CHANGED, SCORE_CHANGED, GOAL_PROGRESS, RESOLVE_STARTED {450}; spawn ~t_resolve+200 ms later. Clear the goal n: GOAL_REACHED, LEVEL_RESULT {outcome won, stars}, phase ENDED. Stack past the limit with a warning left: TOP_OUT_WARNING, bottom layers wiped (CELLS_CHANGED), phase WARNING for goal.warning_ms, then spawn; second top-out: LEVEL_FAILED {top_out} + LEVEL_RESULT lost. `sim.score()`, `sim.result()`, `sim.goal_state()`. |
| src/core/sim/sim_events.gd | replace (adds RESOLVE_STARTED, LEVEL_RESULT, SCORE_CHANGED) | consts exist |

Needs MB-023 (ScoreKeeper, StarRater, LevelResult) and MB-022 (LayerDetector, SliceCollapse, ClearNGoal, Rescue/LoseTopOut) integrated.
Notes
- Resolve order: P3 veto, S1, S2 on_lock, S3 clear, S4b on_resolve_end, S4c (only if hooks wrote), S5 goal (win beats top-out), S6/S7 top-out, then RESOLVING for t_resolve (F2), WAITING for entry_delay, spawn. S4a is a no-op (no RuleApi requests until CH-091/092). Rule hooks run only for level rules whose RuleDef has a behaviour.
- Blocked spawn goes through the top-out policy; after a rescue it retries once, a second block loses.
- Clock: level_ms counts ticks outside COUNTDOWN, WARNING, ENDED. Warning phase = clear window + goal.warning_ms.
- Stars use `relaxed_timing` (public var, set before stepping) and optional knob relaxed_time_scale (not registered; StarRater default 1.5).
- Review fixes folded in: rotate param `dir`; integer_division warning ignores; fall.soft_drop_locks now locks a resting soft-dropping piece; null goal/top-out plugin ends the level with LEVEL_FAILED reason no_goal_plugin / no_top_out_plugin on the first step; holes_added now follows K3 (empty cell under a cube with no solid above it in its column; already-covered gaps do not count).
- Not done: `trim` top-out plugin (not built, so goal.top_out=trim fails with no_top_out_plugin), time-limit extra fail conditions, out-of-pieces (10d), survive stars, obstacle points, return_piece_to_spawn on veto (veto restarts lock delay).
- Plugins are passed `_api`; goal plugin is configured with level.goal in the constructor. Combo counts once per lock.
