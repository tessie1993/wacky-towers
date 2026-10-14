# Moving platform (gap G8)

## Status (round 2, 2026-10-14)

Done and tested (25 tests: `tests/unit/track/track_runner_test.gd` 20, `track_rule_test.gd` 5):
sim core with lean and topple, cargo state machine, time limit, restart (queued wipe), preview feed with time and safe
height, rule plugin with restore, `track_race` goal, two tracks (`meadow_brook_run` 150 s, `meadow_kite_day` 124 s),
stage reacts to `track_started`, `track_progress`, `track_restart`, `track_topple`, `track_cargo_lost`.
Not done: HUD lean meter and preview strip UI (ui-programmer; the data is in goal metrics and `TrackRunner.preview()`),
the real cart and basket art, the `meadow_03` and `meadow_bonus` level JSON entries (see Level wiring), hold-slot reset,
the build-rate simulation behind the tuning numbers, a survival bot over the shipped tracks.

## Race rule: survive to the finish (user, levels.md section 8)

Reach the end of the track before `time_limit_ms` with the cargo aboard. `TrackRaceGoal` (`goal.type = "track_race"`)
reads the runner's goal metrics: won on `track_finished = 1`, lost on `track_failed = 1`. A return to a post adds
`restart_penalty_ms` to the clock, so each loss costs time. Validation rejects a limit shorter than the base drive time.

## Data model: `assets/data/tracks/<id>.json` (TrackDef)

Every required value must exist; a missing parameter is a validation error (`TrackDef.errors`), never a default.

| Field | Meaning |
|---|---|
| `time_limit_ms`, `restart_penalty_ms` | The clock. |
| `segments[]` | `{id, length_mm, speed_mm_s, fall_pct}`. `fall_pct` is the piece fall speed for the section; the runner requests `fall.gravity_scale = fall_pct * 10` on entering it. |
| `events[]` | `{kind, at_mm, params}`. Kinds and required params: `bump` (force; optional dir), `cloud_bump` (force, dir), `arch` (gap_layers), `crosswind` (dir, strength), `gust` (dir, strength), `updraft` (duration_ms). dir is one of `+x -x +z -z`. |
| `checkpoints[]` | `{id, at_mm}`, strictly inside the track. |
| `lean` | `danger_pm, limit_pm, relax_pm_per_s, spill_cells, spill_relief_pm, hysteresis_pm`. |
| `cargo` | `height_layers, min_support_cells, level_tolerance_layers, wobble_pm, slip_pm, rise_pm_per_s, recover_pm_per_s, lean_stress_pm_per_s, drop_stress_pm_per_layer, top_out_stress_pm_per_s`. |
| `effects` | Per-kind numbers (see below). |
| `preview_window_mm`, `preview_min_lead_ms` | The strip's reach; validation requires every event to be previewed at least this long ahead at its local speed. |
| `path` | View polyline; the sim never reads it. |

## Sim: deterministic, tick-based, dice-free

`TrackRunner` advances in fixed ticks. Position is integer micrometres; rates are accumulated in milli-permille. There is
no RNG now: every outcome follows from the stack and the schedule, with explicit tie-breaks. The step size does not change
results (tested at 50, 10 and 33 ms). `snapshot()`/`restore()` continue identically (tested). A board-changing tick ends
the step early and carries the remainder, because RuleApi writes land at the hook boundary.

## Lean and topple

`lean = centre_of_mass_pm + impulse`. The centre of mass is per axis, in permille of the half-width, from occupied
cells (an edge cell reads (W-1)/W). Impulses decay at `relax_pm_per_s`. The HUD value is `max(|x|, |z|)` clamped to
0..1000 (`track_lean_pm`, with `track_lean_danger_pm`). Crossing `danger_pm` emits `track_lean_warning`. At `limit_pm`
the platform topples: `spill_cells` column-top blocks on the heavy side go, highest layer first, then furthest out, then
lowest z and x (`track_topple`), and the impulse is relieved by `spill_relief_pm`. Building on the light side moves the
centre of mass back, which is the "right it" rule.

## Events

| Kind | Lean | Cargo stress | Other |
|---|---|---|---|
| bump | `impulse_pm_per_force * force` toward the heavy side (the event `dir` if the stack is centred) | `cargo_stress_pm_per_force * force` | |
| cloud_bump | small impulse along `dir` | large | the kite's shake: hits the hamper more than the lean |
| crosswind | `impulse_pm_per_layer_strength * layers * strength` along `dir` (taller catches more wind) | per strength | |
| gust | `layers * cells * strength * impulse_pm_per_100_layer_cells / 100` (tall AND heavy) | per strength | |
| updraft | none | none | speed `+ (lift_pct + height_pct_per_layer * layers - mass_pct_per_cell * cells)` percent for `duration_ms`, fixed when it fires (tall and light gains most); a newer updraft overwrites |
| arch | none | none | the cargo is lost if `seat height + height_layers > gap_layers` |

## Cargo: rides on the highest block

Logic-only; `TrackRunner.cargo_state()` gives the view `{state, name, stress_pm, x, z, h, support}`. The seat is the
highest column (ties: best supported, nearest the centre, lowest z, lowest x). Support is the number of the 9 footprint
columns within `level_tolerance_layers` of the seat height; it must reach `min_support_cells`. An unstable seat, a lean
past danger, a top-out and a seat that drops (a line clear or a trim) all raise stress; a stable seat recovers it.
Stress crossing `wobble_pm` then `slip_pm` emits `track_cargo_state` (the warnings); 1000 loses the cargo, so the save
window is `(1000 - slip_pm) / rise_pm_per_s`. Loss emits `track_cargo_lost`, then restarts from the post or fails
(`on_loss`).

## Restart

`TrackEffects.clear_all()` queues `RuleApi.request_wipe()` (new, applied in write order at the hook boundary, so it also
clears blocks moved by writes still in the queue; regression test `track_rule_test.gd`, which failed against the old
loop first). The piece returns to spawn (`return_piece_to_spawn`), position, lean, stress and lift reset, events after
the post replay, the clock takes the penalty, and `track_progress_pm` is the best progress so far (never goes backwards).

## Camera, preview, view

The board stays at the origin and the camera is unchanged; `WtTrackFollower` scrolls the placeholder track under it.
`MovingPlatformRule` emits `track_started` (the stage loads the track and calls `attach_track`) and `track_progress` each
step (`set_track_progress`). Preview rows (`TrackDef.preview`) carry `ahead_mm`, `ahead_ms`, `severity`,
`safe_height_layers` (arch), `impulse_pm`, `lift_pct`, and checkpoint rows.

## Tuning table (starting values, not yet balanced by simulation)

| Value | Brook Run | Why |
|---|---|---|
| lean danger / limit | 550 / 800 | one off-centre column (750) is survivable until a bump |
| bump impulse per force | 120 | force 1-3 pushes 120-360, so a centred stack takes 0 topples and a lopsided one does |
| crosswind per layer-strength | 30 | 6 layers at strength 2 = 360 |
| cargo rise / recover | 140 / 220 pm/s | about 2 s to wobble and 2.5 s from slip to fall on a bad seat |
| time limit | 190 s for a 150 s drive | two restarts at the 8 s penalty fit |

Kite Day has a lower lean limit (750) and faster cargo rise, no arches or road bumps, so the two races differ.

## Level wiring (open)

`src/levels/meadow/meadow_03/meadow_03.json` is owned by the level designer and I did not change it. The entry it needs:
`"goal": {"type": "track_race"}` and `"rules": [{"id": "moving_platform", "params": {"track": "meadow_brook_run"}}]`.
`meadow_bonus` is the same with `meadow_kite_day`.

## Composition guide

New component per concern (def, runner, effects, goal, rule glue, view follower), data in JSON, no subclassing, no
`get_parent()`; the stage only forwards `track_*` events.
