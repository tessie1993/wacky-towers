# Moving platform (gap G8)

Status: core implemented, polish pending. Serves meadow_03 Brook Run (hay cart) and meadow_bonus Kite Day (kite basket).
Source: `design/levels/levels.md` G8 and section 7; user example "a Tetris race: build your car as you drive,
try not to fall over, foresee the race track".

## Data model: `assets/data/tracks/<id>.json` (TrackDef, RefCounted)

| Field | Meaning |
|---|---|
| `segments[]` | `{id, length_mm, speed_mm_s}`. Sections: speed steps up per segment ("rolls faster each section"). |
| `events[]` | Scheduled by distance: `{kind, at_mm, ...params}`. Kinds: `bump` (force), `arch` (gap_layers), `crosswind` (dir), `updraft` (duration_ms), `cloud_bump` (bump with the kite tuning). |
| `checkpoints[]` | `{id, at_mm}` posts. The start is the implicit first post. |
| `cargo` | One item riding a board column: `{id, x, z, height_layers, max_drop_layers}`. |
| `effects` | Per-kind tuning (percentages, tall layer, lift). All gameplay numbers live here, not in code. |
| `on_loss` | `checkpoint` (return to the last post, blocks giggle away) or `fail` (`api.request_fail`). |
| `path` | View polyline, world units. The sim never reads it. |
| `preview_window_mm` | How far ahead the preview strip looks. |

## Sim: deterministic, tick-based, seeded

`TrackRunner` (src/core/track, RefCounted) advances in fixed `tick_ms` ticks. Position is integer micrometres
(`mm/s * ms`), so there is no float drift. `step(dt_ms, api)` accumulates dt, so chunking dt does not change the
result. Randomness comes only from `Seeds.make_rng(seed, ["track", id])`; the seed is drawn from the rule's own
`api.rng()`. Same def + seed + dt sequence gives the same board and records. `snapshot()`/`restore()` include the
rng state for replay and rollback.

A board-changing event ends the step early (a barrier). Rule API writes queue until the hook boundary, so the
next event must not read cells that are still queued. `TrackEffects` also keeps an overlay of its own pending
writes, so one event reads its own earlier changes.

## Effects on the stack (TrackEffects, through RuleApi only)

- **bump / cloud_bump:** bottom-up pass. A block with nothing under it is shaken loose with
  `loose_pct_per_force * force` percent; blocks at or above `tall_layer` add `tall_pct_per_force * force`.
  Removal cascades upward within one shake. This is the tilt test: tidy, short stacks survive.
- **arch:** every block at layer `>= gap_layers` is removed (`Cause.TRIM`).
- **crosswind:** loose blocks slide one cell in `dir` with `slide_pct`; past the edge they blow off if `blow_off_edge`.
- **updraft:** no board change; platform speed is `base * (100 + lift_pct + height_pct_per_layer * (stack_height + 1)) / 100`
  for `duration_ms`. Height lifts the kite faster, as the design says.
- **cargo:** the basket rides on top of its column. It is lost if an arch gap is `< seat + height_layers`, or an
  event drops its seat by more than `max_drop_layers`. Loss emits `track_cargo_lost`, then restarts from the last post
  (clear all blocks, reset position, attempts + 1) or fails the run.

Emitted records (also `api.emit`): `track_event`, `track_checkpoint`, `track_cargo_lost`, `track_restart`,
`track_finished`. Goal metrics: `track_progress_pm` (0..1000), `track_finished` (1).

Limits: only boards with down = -y (layer == y). The cart and the basket are both upright.

## Camera and preview strip

The board stays at the origin and the existing camera is unchanged. `WtTrackFollower` (view) moves the *track*
under the board: `track.transform = inverse(path pose at position_mm)`, which reads as the camera following.
`WtStage.attach_track(def)` and `set_track_progress(mm)` are the only stage changes. The preview strip is fed by
`TrackRunner.preview()` / `TrackDef.preview(from_mm)`: events ahead with `ahead_mm`. The UI draws it from that
list; nothing in the sim knows about the strip.

## Sim vs view

| Sim, pure and tested (tests/unit/track) | View, placeholder |
|---|---|
| TrackDef, TrackRunner, TrackEffects, `MovingPlatformRule` (hook glue, param `track`) | WtTrackFollower, the two WtStage hooks |

## Composition guide

A new logic component per concern (def, runner, effects), a thin rule plugin as the wiring, data in JSON, and the
view reads runner state through a progress value and a preview list. No subclassing, no `get_parent()`, and the
stage stays an orchestrator.
