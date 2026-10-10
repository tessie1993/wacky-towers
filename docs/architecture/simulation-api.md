# Production simulation API

Implemented 2026-10-10 from ADR-0001, ADR-0002, ADR-0004 and ADR-0011. The simulation is single-threaded and independent of nodes, rendering, wall clocks and global random functions. Presentation consumes typed events and reads state; it never writes the board.

## Tick and application contract

```gdscript
var sim := BoardSim.new(level, round_seed, catalog)
sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i.RIGHT]))
var events: Array[SimEvent] = sim.step()
```

`step()` advances one 60 Hz tick. `now_ms()` is integer tick time. `elapsed_ms()` excludes countdown, warning pauses and the visual wait after a deciding goal. The application pauses by stopping calls to `step()`.

The stable accessors are `board()`, `get_piece()`, `ghost_cells()`, `preview(n)`, `preview_hues(n)`, `held_shape()`, `goal_state()`, `goal_progress()` / `progress_snapshot()`, `score()`, `result()`, `get_tick()` and `knobs()` / `get_knobs()`. `result()` is null until the run ends. `get_api()` supports injected pure ability controllers; gameplay mutations still pass through that facade.

Commands received at the present or a past tick are stamped for the next tick. Future commands retain replay timing. A level with no board/catalog runs as a clock and echoes commands, preserving the original clock/replay tests.

## Resolution order

1. Commands, rule tick hooks and gravity run in their documented order.
2. `piece.lock` veto runs before board writes or lock counters. A mascot catch preserves the orientation and returns the piece to its authored spawn anchor.
3. Lock writes emit `PIECE_LOCKED`, then the optional ability `on_lock` callback and rule `on_lock` hooks run before clearing.
4. S3 clears notify `on_clear` in layer/index order, remove cells, then collapse. Hook content writes flush after settling.
5. S4a applies queued stack flips, gravity changes, mask changes, slots and settle requests.
6. S4b runs `on_resolve_end`. Content writes flush between handlers in ascending priority.
7. When S4b writes content, one S4c clear pass runs. S4b never repeats.
8. Goal evaluation precedes top-out, so a simultaneous win counts. Rescue uses silent removal; trim never counts as clearing. Warnings pause the level clock.
9. A typed `LEVEL_RESULT` emits once after the resolving wait. Won/lost simulations emit no further gameplay events.

Rule priority uses ranks base 0; perk/mascot 1; item_buff/content 2; twist 3; mechanic 4, then lexical rule id for initial activation ties. Trusted modifiers rebuild cached effective knobs. Strategy requests are applied at a resolving boundary; initialization requests apply before the first spawn.

## Data and fixed point

`LevelLoader` converts scalar knobs once into integer milli-units. `KnobRegistry(defs, overrides, true)` consumes those converted values. Its default two-argument form retains the raw-JSON contract for existing callers. Runtime numeric requests use fixed units: `request_slot(&"fall.gravity_scale", 250)` means 0.25. Strategy requests use plugin ids. Board content, statuses and overlay records remain separate.

Shape resources are immutable. `ActivePiece.hue_id` carries the actual piece hue. Colour levels roll hues from a dedicated seeded stream when filling the queue; preview and held pieces retain those hues. `spawn.colour_count = 0` preserves ordinary family colours. Fixed puzzle lists deal exactly once and report out of pieces after exhaustion; an absent or empty list uses the normal weighted bag.

## Plugin mutation facade

Read methods cover occupancy, layer counts, colours, content records, authored spawn anchor, effective knobs, rule params, hypothetical clear/top-out/goal checks and the piece. `rng()` returns one independent stream per rule id.

Content methods are `set_cell`, `clear_cell` / `remove_cell`, `move_cell`, simultaneous `move_cells`, and `set_status`. Tick/fall/clear content writes buffer; lock and resolve handlers flush at each priority boundary. Structural methods are `request_stack_flip`, `request_down_axis` / `request_flip`, `request_mask`, `request_slot` and `request_settle`. Piece/queue methods include `try_translate` / `request_move_piece`, `place_nearest_up`, `replace_shape`, `set_travel_dir`, `set_piece_flag`, `return_piece_to_spawn` / `request_catch`, and `inject_front`. `preview_ids(n)` reads the upcoming queue; `replace_preview(ids)` replaces its front in place while preserving later pieces and the bag generator.

An ability controller binds through `bind_abilities(controller)` and may implement `step(api, now_ms)`, `command(command, api)`, `on_lock(api, cells)`, `veto(action, rank)`, `snapshot()` and `observe(events)`. `BoardSim` calls `observe` exactly once after constructing the tick's complete event list, so charge and combo state remain identical in local and LAN replay simulations.

`emit(kind, data)` produces deterministic presentation events. `snapshot()` on stateful behaviours and abilities exposes all mutable counters; `state_hash()` includes board, piece, queue, hues, clocks, rule RNG state, rule snapshots and optional ability snapshots. Stitch protects rule shifts/removals at ranks up to 3; protected writes remain queued, while base clear/collapse and higher-ranked mechanics retain authority.

## Verification

`tests/unit/sim/board_sim_gameplay_test.gd` verifies lock/clear/result timing, goal precedence, survive timing, the S4c boundary, deterministic replay hashes, buffered writes/statuses, rotation limits, hold, fixed lists/hues, preview replacement, time limits, silent rescue, trim star requirements, modifier order and protected mutation deferral. `tests/integration/gameplay/official_campaign_sim_test.gd` exercises the actual WtContent -> LevelLoader -> BoardSim route for all 118 authored campaign entries and multiple Meadow locks, including the fixed-point and first-spawn regressions. This confirms loading and legal first arrivals; supported mechanic coverage and authored goals are tracked separately in the campaign coverage document.
