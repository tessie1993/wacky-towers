# Mechanics — Wave 3 (15 new rule behaviours)

> **Status**: In Design (implementation in progress)
> **Author**: Tessa + agents (game-designer, systems-designer)
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Rule-Twist Framework, Mechanics Module, Level-Specific Mechanics, Campaign Structure`

## Overview

Fifteen new `RuleBehaviour` plugins for the campaign (bonus and hard-track
remix levels), Arcade and tournament twist pools. Each is a pure, statically
typed `RefCounted` plugin under `src/mechanics/wave3/` with a `PLUGIN_ID`, a
rule definition JSON in `assets/data/rules/`, deterministic state in
`snapshot()`, randomness only from `api.rng()`, and writes only through
`RuleApi` (ADR-0004, ADR-0011). Every one telegraphs before it acts
(*Readable Chaos*), and none removes the core verb of placing blocks.

## Player Fantasy

"The island has a new trick, but I can read it." Each rule is one sentence on a
card — a magnet that tugs, a floor that crumbles, a cannon that fills your holes
after a double clear — and the player learns the counterplay in one level.

## Detailed Design

All rules follow the Mechanics Module write order: content writes flush at the
hook boundary, structural requests (mask, slots) apply in Resolving. Params are
read with `api.param(name, default)`; defaults below.

| # | id | Layer | Hooks | One-line rule |
|---|---|---|---|---|
| W1 | `magnet_pull` | twist | on_level_start, on_spawn, on_tick | A magnet column tugs the falling piece one cell toward it on a timer. |
| W2 | `crumble_tiles` | mechanic | on_level_start, on_lock | Cracked floor tiles break after N locks touch them; the column above drops. |
| W3 | `chameleon_paint` | twist | on_lock | A locked piece takes the majority colour of the cubes it touches. |
| W4 | `anvil_drop` | mechanic | on_spawn, on_lock | Every Nth piece is an anvil: on lock it crushes the gaps beneath it. |
| W5 | `jumbled_queue` | twist | on_lock | Every N locks the preview queue is shuffled (telegraphed one lock ahead). |
| W6 | `mystery_piece` | twist | on_spawn | Every Nth queued piece is a "?" whose shape is revealed only at spawn. |
| W7 | `pressure_cooker` | twist | on_lock, on_clear | Gravity rises a step each lock without a clear and resets on a clear. |
| W8 | `star_coins` | mechanic | on_level_start, on_lock, on_clear | Coins float in empty cells; covering one collects it (score + goal counter). |
| W9 | `echo_drop` | twist | on_lock | Every N locks the last piece's shape is echoed as the next piece. |
| W10 | `rusty_hinge` | twist | on_spawn, veto | Each piece may rotate only `max_turns` times. |
| W11 | `storm_bolt` | twist | on_level_start, on_tick | A telegraphed lightning bolt zaps the top cube of a marked column. |
| W12 | `confetti_fill` | mechanic | on_clear | A multi-layer clear fires confetti that fills up to N covered holes. |
| W13 | `quicksand` | mechanic | on_level_start, on_lock | Quicksand tiles swallow the bottom cube of their column every N locks. |
| W14 | `fever_rush` | twist | on_clear, on_tick, on_lock | Quick consecutive clears build Fever; at full Fever, scores double and gravity slows. |
| W15 | `golden_row` | mechanic | on_level_start, on_clear | One layer glows gold; clearing it pays a bonus, then gold moves up. |

**W1 `magnet_pull`** — Params: `magnet_col` ([x, z], default board centre-right `[w−1, d/2]`), `pull_interval_ms` 2500, `pull_warn_ms` 600, `pull_axis` ("x"/"z"/"both", default "x").
Every interval (first one after the first spawn), if a piece is falling, emit `magnet_warning` `pull_warn_ms` early; at due, move the piece one cell along the chosen axis toward the magnet column via `api.request_move_piece` (blocked moves are ignored). A piece already aligned is not moved. Event `magnet_pull {dir}`.

**W2 `crumble_tiles`** — Params: `tiles` (list of [x, z]; default two seeded floor cells), `crumble_after` 3.
Each lock whose cells include a cube at layer 0 directly on a tile increments that tile's counter (once per lock per tile). At `crumble_after − 1` emit `tile_cracking`; at `crumble_after` remove only the layer-0 cube (`Cause.DAMAGE`) and move the rest of that column down one cell (`move_cells`, preserving status); the tile is then spent and becomes a normal tile. Event `tile_crumbled {cell}`.

**W3 `chameleon_paint`** — Params: `min_neighbours` 2.
On lock, count the colours of locked cubes face-adjacent to the piece (excluding the piece's own cells). If the most common colour has ≥ `min_neighbours` contacts and differs from the piece colour, recolour all the piece's cells to it (`set_cell` with same kind, uid). Ties pick the lowest colour id. Event `chameleon {hue, cells}`. Synergy: `colour_connect`, `mono_layer`.

**W4 `anvil_drop`** — Params: `every` 6, `max_crush` 3.
Count spawns; every `every`-th piece gets piece flag `anvil` and event `anvil_spawned`. On lock of an anvil piece, for each column under its lowest cubes, move down every cube between the anvil's lowest cube and the next floor/support so the column becomes gap-free beneath the anvil (move_cells, at most `max_crush` cells of gap removed per column). Event `anvil_crush {cells_moved}`.

**W5 `jumbled_queue`** — Params: `every` 5.
Count locks. At `every − 1` emit `queue_jumble_warning`; at `every`, read `api.preview_ids(n)` (n = queued preview count, ≥2), shuffle with `api.rng()` (Fisher–Yates) and `api.replace_preview`. If the shuffle is the identity, rotate by one so something visibly changes. Counter resets.

**W6 `mystery_piece`** — Params: `every` 4, `pool` (default the level's shape pool).
Count spawns; the queued piece that will be the `every`-th is flagged hidden in a `mystery_preview` event (index into the preview). When it spawns, `api.replace_shape` with a seeded pick from `pool` (never the same shape as the one replaced unless pool size 1). Event `mystery_reveal {shape_id}`.

**W7 `pressure_cooker`** — Params: `step` 0.15 (gravity scale per lock), `max_scale` 2.5.
Each lock with no clear in its resolution raises `pressure` by one; gravity modifier = `min(max_scale, 1 + step × pressure)` applied as `{"knob": "fall.gravity_scale", "op": "mul", "value": v}` via `request_modifiers(&"pressure_cooker", …)`. A clear resets pressure to 0 and `clear_modifiers`. Events `pressure {level}` and `pressure_release`.

**W8 `star_coins`** — Params: `coins` 5 (count), `min_layer` 1, `score` 50, `goal_counter` "coins".
At level start place `coins` coin markers in seeded empty cells at layers `min_layer`…`h_play−2` (state only — no board content). A lock whose cells include a coin cell collects it: `request_score(score)`, `add_goal_counter(goal_counter)`, event `coin_collected {cell, remaining}`. Coins shift down with cleared layers (cells above a cleared layer move down by the number of cleared layers below them; coins in a cleared layer are collected). Event `coins_state {cells}` after every change.

**W9 `echo_drop`** — Params: `every` 4.
Count locks; at the `every`-th lock, `api.inject_front([last_shape_id])` and emit `echo {shape_id}`. Counter resets.

**W10 `rusty_hinge`** — Params: `max_turns` 2.
Reset `turns_left` on every spawn. `veto(CMD_ROTATE)` returns true when `turns_left` is 0 (and emits `hinge_stuck`), otherwise decrements it and returns false. Hold resets nothing.

**W11 `storm_bolt`** — Params: `bolt_interval_ms` 9000, `bolt_warn_ms` 1500.
Schedule seeded bolts. At warn time choose a seeded column among columns with at least one cube (if none, skip this bolt) and emit `bolt_warning {column, due_ms}`; at due, remove the highest cube of that column (`Cause.DAMAGE`) and emit `bolt_strike {cell}`. Bolts never hit the falling piece.

**W12 `confetti_fill`** — Params: `min_layers` 2, `max_fill` 3.
On a clear of ≥ `min_layers` layers in one resolution (`ctx.data.layers` size or `clear_count` delta), find covered holes (empty cells with an occupied cell somewhere above in the same column), ordered lowest first then x, z, and fill up to `max_fill` with `block` cubes of colour 0 (`confetti` status). Event `confetti {cells}`.

**W13 `quicksand`** — Params: `tiles` (list of [x, z]; default one seeded cell), `sink_every` 4.
Every `sink_every` locks, for each quicksand tile with a cube at layer 0, remove that bottom cube and move the rest of the column down one cell (move_cells, preserving status). Warn one lock ahead with `quicksand_warning`. Event `quicksand_sink {tiles}`.

**W14 `fever_rush`** — Params: `window_ms` 6000, `clears_needed` 3, `fever_ms` 8000, `bonus` 100, `gravity_scale` 0.6.
A clear within `window_ms` of the previous one adds to `combo` (else combo restarts at 1). At `clears_needed`, Fever starts: modifiers `fall.gravity_scale ×gravity_scale`, every clear during Fever adds `request_score(bonus × layers)`, event `fever_start`; after `fever_ms` of ticks, `clear_modifiers`, `fever_end`. Event `fever_meter {combo, needed}`.

**W15 `golden_row`** — Params: `start_layer` 1, `bonus` 200, `goal_counter` "gold".
The gold layer index starts at `start_layer`. When a clear includes the gold layer, `request_score(bonus)`, `add_goal_counter`, event `gold_cleared`, and the gold layer moves up by one (wrapping to `start_layer` past `h_play − 2`). Event `gold_layer {layer}` at start and after every move.

### States and Transitions

Counter-driven rules (W2, W4–W6, W9, W13) count locks/spawns and reset. Timer rules (W1, W11) are Idle → Warned → Fired → Idle. W7 holds a pressure level; W14 is Idle → Combo → Fever → Idle.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework | → | Hook dispatch, vetoes, modifiers, layer (twist/level) |
| Board Sim / RuleApi | ↔ | Writes, moves, preview, score, goal counters |
| Campaign levels (hard-track remixes, neon bonus) | → | Authored params |
| Tournament randomizer / Arcade | → | Twist-layer rules (W1, W3, W5–W7, W9–W11, W14) join twist pools |
| Game Feel & VFX, HUD | ← | Events listed per rule |

## Formulas

- **W7 gravity:** `scale = min(max_scale, 1 + step × pressure)`. Defaults: after 6 clearless locks, 1.9×; cap 2.5× after 10.
- **W14 fever:** `combo(n) = combo(n−1) + 1 if t_n − t_{n−1} ≤ window_ms else 1`; Fever when `combo ≥ clears_needed`. Score during Fever `+bonus × layers` per clear.
- **W8 coin shift:** `y' = y − |{cleared layers < y}|`.
- **W4 crush:** per column, `moved = min(max_crush, gap_cells_below_anvil)`.

## Edge Cases

- **W1** the move toward the magnet is blocked → nothing happens, no retry until next interval.
- **W2** a tile is under a masked cell → ignored at level start (validation warning).
- **W3** the piece touches nothing locked (floor only) → no recolour.
- **W4** an anvil piece is held → the flag stays with the piece's uid; holding does not count a spawn twice.
- **W5** preview has fewer than 2 ids → nothing, no warning.
- **W6** the mystery index falls on an injected (echo/item) piece → reveal still applies to the piece that actually spawns at that count.
- **W8** a coin cell becomes occupied by rule content (not a lock) → coin collected only by locks; coin stays.
- **W10** a rotation vetoed by the hinge does not consume a turn.
- **W11** the chosen column is emptied before due (by a clear) → the bolt fizzles (`bolt_fizzle`).
- **W12** fewer covered holes than `max_fill` → fills those that exist.
- **W13** the column's bottom cube is part of the falling piece → impossible (falling pieces are not board content).
- **W14** level ends during Fever → modifiers cleared on level end via owner key.
- **W15** the gold layer is above the current stack → still shown; clearing is simply impossible until the stack reaches it.

## Dependencies

- `design/gdd/rule-twist-framework.md`, `design/gdd/mechanics-module.md` (runtime contract)
- `design/gdd/twist-library.md` (twist-layer rules join the library)
- `design/gdd/campaign-structure.md` rule 17 (hard-track remixes use these rules)
- `design/gdd/game-feel-vfx.md` (event presentation)

## Tuning Knobs

| Knob | Default | Safe range | Affects |
|---|---|---|---|
| `pull_interval_ms` (W1) | 2500 | 1500–6000 | Magnet pressure |
| `crumble_after` (W2) | 3 | 2–6 | Floor lifetime |
| `every` (W4/W5/W6/W9) | 6/5/4/4 | 3–10 | Frequency |
| `step`, `max_scale` (W7) | 0.15, 2.5 | 0.05–0.3, 1.5–3.5 | Clear urgency |
| `coins` (W8) | 5 | 1–10 | Collect goal length |
| `max_turns` (W10) | 2 | 1–4 | Rotation planning |
| `bolt_interval_ms` (W11) | 9000 | 5000–20000 | Erosion rate |
| `max_fill` (W12) | 3 | 1–6 | Reward size |
| `sink_every` (W13) | 4 | 2–8 | Erosion rate |
| `window_ms`, `clears_needed` (W14) | 6000, 3 | 3000–12000, 2–5 | Fever access |
| `bonus` (W15) | 200 | 50–500 | Gold reward |

## Acceptance Criteria

1. Each of the 15 plugins is discovered by `PluginRegistry` (unique `PLUGIN_ID`) and its rule JSON loads into `GameCatalog.rule_defs`.
2. Each plugin has at least one unit test in `tests/unit/mechanics/wave3_*_test.gd` using `MechanicsFixture` that asserts its described board/event effect.
3. Each plugin's `snapshot()` changes when its internal counter or timer changes, and two runs with the same seed produce identical snapshots.
4. Every campaign level that uses a wave-3 rule loads without validation errors (`WtContent.level(id)` non-null).
5. Twist-layer wave-3 rules can be listed in a tournament twist pool without randomizer errors.
