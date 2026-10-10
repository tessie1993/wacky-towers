# CH-016 Knob files: fall, spawn, controls

**Story:** DAT-001
**Goal:** the knob data the game reads instead of hardcoded numbers (ADR-0004 §3, coding standard: data-driven values). Data only, no code.
**Depends:** none
**Parallel-safe with:** every batch-2 ticket except CH-018 (which reads these files)
**Files:** `assets/data/knobs/fall.json` (new), `assets/data/knobs/spawn.json` (new), `assets/data/knobs/controls.json` (new)

## Per file

| File | Id prefix | Source GDD(s) | Notes |
|---|---|---|---|
| `assets/data/knobs/fall.json` | `fall.` | design/gdd/fall-drop-lock.md |  |
| `assets/data/knobs/spawn.json` | `spawn.` | design/gdd/piece-spawner-queue.md (+ piece-set.md data-file knobs) | Slot `spawn.arrival`: choices `["top"]`. |
| `assets/data/knobs/controls.json` | `control.` | design/gdd/touch-controls.md + design/gdd/movement-rotation.md | Slot `control.verb`: choices `["piece"]`. Includes `rotation_axes_enabled` as a `structure` (array) knob. |

## Format (contract checked by CH-012 / CH-018)

Each file is `{"knobs": [ {entry}, ... ]}`. Entry keys: `id`, `type`, `default`, `min`, `max`, `allows_zero`,
`rule_adjustable`, `choices`, `source`, `note` — nothing else. Rules from CH-012:
- `type`: `scalar` (decimals in natural units, e.g. `0.6`; stored x1000), `count` (whole numbers, ms values are counts),
  `flag` (bool), `choice` / `slot` (`choices` list of strings), `structure` (object/array default).
- `scalar`/`count` need `min` and `max` with `min <= default <= max`. Use the GDD's **safe range** as min/max.
- `rule_adjustable`: true only if `design/gdd/rule-twist-framework.md` lists it as rule-adjustable (default false).
- `source`: the GDD file and section, e.g. `"design/gdd/fall-drop-lock.md#tuning-knobs"`.

## How to fill it

1. Open the listed GDD(s), section **Tuning Knobs** (and Formulas tables marked "data file"). One row = one entry.
2. **Id = `<prefix>.<snake_case_name>`.** Before inventing a name, grep `docs/architecture/` and `design/gdd/` for
   `<prefix>.` and reuse any id already written there (e.g. `fall.g0`, `goal.top_out`, `goal.warnings_max`, `view.turn_anim_ms`).
3. A knob whose value is a strategy is a `slot`; its choices are only the plugin ids the plan builds for Meadow
   (implementation-plan §1.2 `src/gameplay/`), default first.
4. Do not invent tuning values. If a GDD row has no default or range, add it with the closest stated value and a `note`
   `"TODO(design): no range in GDD"`, and list it in your ticket hand-off.
5. Valid JSON (2-space indent), entries sorted by id.

## Tests
None of its own — CH-018 loads every knob file. Self-check before done: each file parses with
`JSON.parse_string(FileAccess.get_file_as_string(path)) != null` (one-off headless `-s` script in the scratchpad, not committed),
and ids are unique.

## Done when
Files written; self-check passes; hand-off lists any `TODO(design)` knobs. Status row updated.
