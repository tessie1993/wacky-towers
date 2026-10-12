# CH-078 Move SimCommand + SimEvent to core/model

**Story:** SIM-001 · **Model:** Haiku · **Wave:** W1 · **Mode:** direct
**Goal:** plan gap 5 decision: plain value types live in `src/core/model/` so `core/rules` bases may name them. `SimEvents` stays in `core/sim`.
**Depends:** none · **Parallel-safe with:** W1
**Files:** `git mv src/core/sim/sim_command.gd src/core/model/sim_command.gd` and `sim_event.gd` the same, **with their `.gd.uid` files**.
Tests that sit in for these two classes: `git mv` to.

## Behaviour
- No code edit. `class_name` resolves by name, so callers do not change. `grep -rn "core/sim/sim_command\|core/sim/sim_event\.gd" src tests`
  must find nothing afterwards (fix any `preload` path found).
- Run `--import` once after the move (stale class cache otherwise).

## Expected results (no tests)
User rule 2026-10-10: NO TESTS. Do not write test files. These are the expected results: the integrator checks them in the editor (godot-ai script eval or a scratch script, read with `logs_read`) after moving the file in.
None new: the moved tests are the proof.

## Run
Integrator: move staged files in, rescan, `logs_read` must show no parse errors or class-name clashes, then check the cases above. No gdUnit run.

**Out of scope:** `sim_events.gd`, any renames.
