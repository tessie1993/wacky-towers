# CH-078 Move SimCommand + SimEvent to core/model

**Story:** SIM-001 · **Model:** Haiku · **Wave:** W1 · **Mode:** direct
**Goal:** plan gap 5 decision: plain value types live in `src/core/model/` so `core/rules` bases may name them. `SimEvents` stays in `core/sim`.
**Depends:** none · **Parallel-safe with:** W1
**Files:** `git mv src/core/sim/sim_command.gd src/core/model/sim_command.gd` and `sim_event.gd` the same, **with their `.gd.uid` files**.
Tests that sit in `tests/unit/sim/` for these two classes: `git mv` to `tests/unit/model/`.

## Behaviour
- No code edit. `class_name` resolves by name, so callers do not change. `grep -rn "core/sim/sim_command\|core/sim/sim_event\.gd" src tests`
  must find nothing afterwards (fix any `preload` path found).
- Run `--import` once after the move (stale class cache otherwise).

## Tests first
None new: the moved tests are the proof.

## Run / Done when
`--import`, then `-a res://tests/unit/model` and `-a res://tests/unit/sim`: both green, same test count as before the move.
**Out of scope:** `sim_events.gd`, any renames.
