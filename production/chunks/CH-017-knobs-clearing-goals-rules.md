# CH-017 Knob files: clearing, goals, rules

**Story:** DAT-001
**Goal:** the knob data the game reads instead of hardcoded numbers (ADR-0004 §3, coding standard: data-driven values). Data only, no code.
**Depends:** none
**Parallel-safe with:** every batch-2 ticket except CH-018 (which reads these files)
**Files:** `assets/data/knobs/clearing.json` (new), `assets/data/knobs/goals.json` (new), `assets/data/knobs/rules.json` (new)

## Per file

| File | Id prefix | Source GDD(s) | Notes |
|---|---|---|---|
| `assets/data/knobs/clearing.json` | `clear.` | design/gdd/layer-clearing.md | Slots `clear.detector` choices `["layer", "none"]`, `clear.collapse` choices `["slice"]`. Resolving durations `clear.*_ms` and `clear.resolve_max_ms` (implementation-plan SIM stories use these names). |
| `assets/data/knobs/goals.json` | `goal.` | design/gdd/level-goals-fail-states.md + design/gdd/scoring-stars.md | Slots `goal.type` choices `["clear_n", "height", "shape", "survive"]`, `goal.top_out` choices `["rescue", "trim", "lose"]` (default rescue). Includes `goal.warnings_max`, rescue margin. |
| `assets/data/knobs/rules.json` | `rules.` | design/gdd/rule-twist-framework.md | Budget caps (twist <= 2, mechanic <= 1 per ADR-0004 F3), chain depth, etc. |

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
