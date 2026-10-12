# Production simulation API

Implemented 2026-10-10 from ADR-0001, ADR-0002, ADR-0004 and ADR-0011. The simulation is single-threaded. Its installed Beehave nodes are detached and ticked manually; rendering, wall clocks, SceneTree processing and global random functions do not affect gameplay. Presentation consumes typed events and reads state; it never writes the board.

## Tick and application contract

```gdscript
var sim := BoardSim.new(level, round_seed, catalog)
sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i.RIGHT]))
var events: Array[SimEvent] = sim.step()
```

`step()` advances one 60 Hz tick. `now_ms()` is integer tick time. `elapsed_ms()` excludes countdown, warning pauses and the visual wait after a deciding goal. The application pauses by stopping calls to `step()`.

The stable accessors are `board()`, `get_piece()`, `get_piece_uid()`, `ghost_cells()`, `preview(n)`, `preview_hues(n)`, `held_shape()`, `goal_state()`, `goal_progress()` / `progress_snapshot()`, `score()`, `result()`, `get_tick()` and `knobs()` / `get_knobs()`. `result()` is null until the run ends. `get_api()` supports injected pure ability controllers; gameplay mutations still pass through that facade.

Commands received at the present or a past tick are stamped for the next tick. Future commands retain replay timing. A level with no board/catalog runs as a clock and echoes commands, preserving the original clock/replay tests.

## Resolution order

1. Commands, rule tick hooks and gravity run in their documented order.
2. `piece.lock` veto runs before board writes or lock counters. A mascot catch preserves the orientation and returns the piece to its authored spawn anchor.
3. Lock writes emit `PIECE_LOCKED`, then the optional ability `on_lock` callback and rule `on_lock` hooks run before clearing.
4. S3 clears notify `on_clear` in layer/index order, remove cells, then collapse. Candidate hooks observe the same original cells, then buffered status/content writes flush before clear guards decide removals; this permits same-clear unlocks and frosting peels.
5. S4a applies post-clear damage, stack flips, gravity changes, mask/floor/height/junk changes, goal-stage replacement, slots and settle requests.
6. S4b runs `on_resolve_end`. Content writes flush between handlers in ascending priority.
7. When S4b writes content, one S4c clear pass runs. S4b never repeats.
8. Goal evaluation precedes top-out, so a simultaneous win counts. Rescue uses silent removal; trim never counts as clearing. Warnings pause the level clock.
9. A typed `LEVEL_RESULT` emits once after the resolving wait. Won/lost simulations emit no further gameplay events.

Rule priority uses ranks base 0; perk/mascot 1; item_buff/content 2; twist 3; mechanic 4, then activation tick and lexical rule id for ties. Trusted modifiers rebuild cached effective knobs. Strategy requests are applied at a resolving boundary; initialization requests apply before the first spawn.

## Data and fixed point

`LevelLoader` converts scalar knobs once into integer milli-units. `KnobRegistry(defs, overrides, true)` consumes those converted values. Its default two-argument form retains the raw-JSON contract for existing callers. Runtime numeric requests use fixed units: `request_slot(&"fall.gravity_scale", 250)` means 0.25. Strategy requests use plugin ids. Board content, statuses and overlay records remain separate.

Shape resources are immutable. `ActivePiece.hue_id` carries the actual piece hue. Colour levels roll hues from a dedicated seeded stream when filling the queue; preview and held pieces retain those hues. `spawn.colour_count = 0` preserves ordinary family colours. Fixed puzzle lists deal exactly once and report out of pieces after exhaustion; an absent or empty list uses the configured bag, history-roll or weighted-random stream. History-roll uses `min(history_len, positive_shape_count-1)` recent entries and bounded attempts. Opening and fixed lists retain their authored order/mode. Injected helpers never advance the generated stream or its RNG. Each generated bag entry carries its true bag id, size and zero-based position through lookahead; fixed/opening entries have bag id -1. Per-entry fixed tags and fixed hues remain attached to their entries.

## Plugin mutation facade

Read methods cover occupancy, layer counts, colours, content records, authored spawn anchor, effective knobs, rule params, hypothetical clear/top-out/goal checks and the piece. `rng()` returns one independent stream per rule id.

Content methods are `set_cell`, `clear_cell` / `remove_cell`, `move_cell`, simultaneous `move_cells`, and `set_status`. Tick/fall/clear content writes buffer; lock and resolve handlers flush at each priority boundary. Structural methods are `request_stack_flip`, `request_down_axis` / `request_flip`, `request_mask`, `request_slot` and `request_settle`. Piece/queue methods include `try_translate` / `request_move_piece`, `place_nearest_up`, `replace_shape`, `set_travel_dir`, `set_piece_flag`, `return_piece_to_spawn` / `request_catch`, and `inject_front`. `preview_ids(n)` reads the upcoming queue; `replace_preview(ids)` replaces its front in place while preserving later pieces and the bag generator.

An ability controller binds through `bind_abilities(controller)` and may implement `step(api, now_ms)`, `command(command, api)`, `on_lock(api, cells)`, `veto(action, rank)`, `snapshot()`, `restore(snapshot, offset_ms)` and `observe(events)`. `BoardSim` calls `observe` exactly once after constructing the tick's complete event list, so charge and combo state remain identical in local and LAN replay simulations.

`emit(kind, data)` produces deterministic presentation events. `snapshot()` on stateful behaviours and abilities exposes all mutable counters; `state_hash()` includes board, piece, queue, hues, clocks, rule RNG state, rule snapshots and optional ability snapshots. Stitch protects rule shifts/removals at ranks up to 3; protected writes remain queued, while base clear/collapse and higher-ranked mechanics retain authority.

## Verification

`tests/unit/sim/board_sim_gameplay_test.gd` verifies lock/clear/result timing, goal precedence, survive timing, the S4c boundary, deterministic replay hashes, buffered writes/statuses, rotation limits, hold, fixed lists/hues, preview replacement, time limits, silent rescue, trim star requirements, modifier order and protected mutation deferral. `tests/integration/gameplay/official_campaign_sim_test.gd` exercises the actual WtContent -> LevelLoader -> BoardSim route for all 118 authored campaign entries and multiple Meadow locks, including the fixed-point and first-spawn regressions. This verifies loading and legal first arrivals, choosing an authored kit entry where required. `turn_controls_test.gd` additionally covers actual Beehave execution/cleanup, kit inventory, undo/reset and replay hashes, direction choice and curling flick, bag metadata, static geometry and cause-specific protection, randomizer distribution and history bounds, modifier priority, twist replacement, and private stage configuration. Authored gameplay solutions are verified separately by the puzzle packing integration suite.

## Turn controls and inventory

`kit_choices()` returns distinct `{shape_id, remaining}` entries; `selection_remaining()` counts copies. A nonempty `pieces.kit` enters `Phase.SELECTING`, exposes no active piece, and accepts `CMD_PICK_SHAPE` with a shape id or `{shape_id}`. Invalid/depleted ids do nothing. The chosen copy is consumed once; final-piece victory is evaluated before budget/exhaustion failure.

`capabilities()` exposes `kit`, `undo`, `reset`, `undo_available`, `choose_down`, `ice_flick` and `flicks_left`. `CMD_CHOOSE_DOWN` accepts a unit `Vector3i` or `{direction}` allowed by `control.travel_dirs`. It changes the active piece's travel/ghost/drop direction without changing stack gravity. `CMD_FLICK` is legal during rest and respects `control.flick_dirs` and the per-piece quota; it stops at a wall, or drops into the first gap and ends there.

The `undo_reset` rule enables `CMD_UNDO` and `CMD_RESET`. Undo restores the preceding turn's board, piece identity, inventory/queue, RNG streams, rule state, effective knobs, counters and score while the level clock continues. Reset restores the first turn and resets the level clock. Absolute core timers are rebased to the current simulation tick; injected ability controllers receive the time offset in their restore callback. Stored turn snapshots have deterministic primitive hashes and contain no node identifiers. Every simulation owns its own deep-copied `LevelData` dictionaries, so goal-stage changes and undo cannot alter cached campaign content.

## Runtime effects, stages and protected geometry

`set_rule_definitions(Array)` schedules replacement of only rank-3 twists at the next fixed tick. It preserves content, perks and mechanics, emits end/start events, discards removed twists' pending writes/structural requests, rebuilds effective modifiers and initializes new handlers through Beehave. Queue previews remain unchanged when a replacement changes the randomizer.

`request_modifiers(owner, modifiers)` and `clear_modifiers(owner)` maintain named effects within the issuing rule's priority. Modifiers use RuleDef JSON units (`0.5` for a scalar multiplier, integer counts, string choices), with `{knob, op, value}` keys. The highest-priority set applies before all multipliers/adds, then safe limits clamp the result. `modifiers_would_change(modifiers)` performs a pure effective-value comparison; `rule_active(id)` reads active ids. Direct `request_slot` numeric values continue to use runtime fixed units.

`bind_item_context({players, rank, mode, owner})` supplies deterministic multiplayer context to rule APIs. Integer/dictionary `CMD_USE_ITEM` and `CMD_RECEIVE_ITEM` reach rule `on_command` hooks even without a piece; resolving defers them to the next available tick. String item commands retain the ability-controller interface. `request_score(points)` awards nonnegative points; `request_post_clear_damage(cells, hits)` applies damage at S4a without clear credit. If hold expires, its tagged/hued piece returns to the queue front at the next spawn unless another active effect still enables hold.

Goal evaluators may implement `begin`, `on_spawn`, `on_lock`, `on_clear`, `evaluate`, `progress`, `snapshot` and `restore`. `goal_config()` returns a copy; `goal_metric`, `goal_counter` and `add_goal_counter` manage metrics copied into `LevelResult`. `request_goal(config)` replaces a stage at S4a. Stars may use `stars.metric` and `three_star_zero_metrics`. Piece flags accept variants, including local stamped-key dictionaries. Hue requests may update the active piece or a preview entry without rerolling future pieces.

Statuses centrally enforce `fixed`, `anchored`, `locked`, `clear_protected`, `fills_layer`, `static_geometry`, `vined` and `hits_left`/`hp`. Fixed/static geometry remains solid and does not count against a layer's fill denominator. Anchored cells resist passive collapse; deliberate behaviour moves may explicitly pass `force=true`, but fixed/locked cells remain immovable. Vines protect trim while allowing ordinary clear and movement. Damage decrements health before removal; rescue/trim/floor loss never count as clear credit. Shelf barriers keep slice collapse inside its chamber. `request_floor` masks/removes lower layers silently without collapsing survivors; `request_height_limit` changes the danger boundary; `request_junk_layers` raises movable contents while preserving anchors.
