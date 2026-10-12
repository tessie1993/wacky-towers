# CH-084 Knob additions (rules-audit defaults + controls)

**Story:** DAT-001 · **Model:** Haiku · **Wave:** W2 · **Mode:** direct (only ticket in W2 that touches `assets/data/knobs/`)
**Goal:** add the knobs the adopted rules-audit defaults and later tickets read. Every value is a tunable default.
**Depends:** none · **Parallel-safe with:** W2
**Files:** edit `assets/data/knobs/goals.json`, `view.json`, `controls.json`, `rules.json`.

## Entries (copy the field set of a neighbouring entry in the same file: id, type, default, min, max, choices, rule_adjustable, source, note)
| File | id | type | default | range / choices | source |
|---|---|---|---|---|---|
| goals.json | `goal.warning_ms` | count | 1200 | 600..1500 | rules-audit F7 |
| goals.json | `goal.intro_card_ms` | count | 2000 | 0..4000, allows_zero | rules-audit G1 |
| view.json | `view.ghost_alpha` | scalar | 0.35 | 0.1..1.0 | RND-08 |
| controls.json | `control.rotate_repeat` | flag | false | — | rules-audit T3 |
| controls.json | `control.invert_spin` | flag | false | — | rules-audit M1 |
| controls.json | `control.touch_scheme` | choice | "a" | ["a","b"] | touch-controls.md schemes |
| controls.json | `control.left_hand_mirror` | flag | false | — | touch-controls.md rule 5 |
| controls.json | `control.fog_ghost_preview` | choice | "faint" | ["none","faint","full"] | handoff G6 |
| rules.json | `rules.layer_order` | (edit default) | append `"content"`, `"mascot"` after the existing layers | — | handoff G4 |

`rule_adjustable`: false for all new entries except `goal.warning_ms` (true).

## Check
User rule 2026-10-10: NO TESTS. Do not write test files. These are the expected results: the integrator checks them in the editor (godot-ai script eval or a scratch script, read with `logs_read`) after moving the file in.
No new test file. Run the existing (CH-018) red-first only if it pins entry counts; then green.

## Run
Integrator: move staged files in, rescan, `logs_read` must show no parse errors or class-name clashes, then check the cases above. No gdUnit run.

**Out of scope:** code that reads them (CH-057, CH-068, CH-095, CH-098, CH-099, CH-129).
