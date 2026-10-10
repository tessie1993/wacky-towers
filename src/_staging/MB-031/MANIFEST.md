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
