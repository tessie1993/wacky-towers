# Rule-Twist Framework

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Readable Chaos; The Block Is the Constant

## Summary

The Rule-Twist Framework is the plug-in socket every rule change uses: biome twists, level-specific mechanics, items, buffs and perks all describe themselves as **rules** that adjust numbers or react at fixed moments in the game (spawn, fall, lock, clear and so on). When rules disagree, a fixed order decides — level mechanic, then twist, then item or buff, then perk, then the base game — and numbers changed by several rules are multiplied together and kept within safe limits. A level can have up to 2 twists and 1 level mechanic at once, so the chaos stays readable.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Board / Grid, Piece Spawner & Queue, Movement & Rotation, Fall, Drop & Lock, Layer Clearing, Level Goals & Fail States`

## Overview

Wacky Towers' promise is variety: dozens of twists on the same blocks (wind, gravity flips, invisible blocks, drifting pieces, living objects), plus level mechanics that may deliberately break the general rules, plus items, buffs and perks. If each of these edited the core systems directly, they would collide. This framework is the single contract they all use. A **rule** is data plus, where needed, a small behaviour: it has a **layer** (level mechanic, twist, item/buff, perk, or base), a **scope** (which board or player), a **lifetime**, and any of three kinds of operations: **parameter modifiers** (multiply, add, set or toggle a tuning knob that a core GDD exposes, such as gravity scale, lock delay, preview count or `clear_enabled`), **hook actions** (do something at a fixed hook point, such as push the falling piece on each tick or spawn an object after a resolve), and **vetoes** (forbid something, such as clearing a layer). The framework computes every parameter's effective value, runs hooks in a fixed order, and settles conflicts by the layer order the user chose: **level mechanic > twist > item/buff > perk > base**, newest first within a layer. Numeric effects multiply and are then clamped to the knob's safe range from its GDD. Per level, at most **2 twists + 1 level mechanic** are active, and every active rule is shown to the player. This serves *Variation Over Depth* (new twists are data and small behaviours, not core rewrites), *Readable Chaos* (bounded stacking, visible rules, safe ranges), and *The Block Is the Constant* (rules change how blocks behave, never replace them). All values are starting defaults.

## Detailed Design

### Core Rules

**What a rule is**
1. A **rule** has: `rule_id`, a **layer** (`level_mechanic`, `twist`, `item_buff`, `perk`, `base`), a **scope** (one board / one player / all players / the opponents of a player), a **lifetime** (the whole level, a duration in play time, a number of pieces, or until an event), an icon and a short name, and one or more **operations**.
2. The base game is itself the lowest layer: the defaults in each core GDD are `base` values.
3. Rules are defined in data (Level Data, Twist Library, Items, Characters & Perks). Behaviour beyond parameters and the built-in actions is a small scripted action that only uses the framework's API (rule 13), never a direct write to a core system.

**Operation 1 — parameter modifiers**
4. A rule may change any parameter that a core GDD lists as a tuning knob and marks as rule-adjustable: for example `gravity_scale`, `g0`, `lock_delay_ms`, `lock_resets_max`, `preview_count`, `hold_enabled`, `randomizer`, `clear_enabled`, `collapse_mode`, `landed_move_rule`, `rotation_axes_enabled`, `kick_enabled`, `warnings_max`, the down axis, the cell mask. A parameter the framework does not know is a validation error.
5. Each parameter has a **type** taken from its knob: **scalar** (float), **count** (int), **flag** (true/false), **choice** (enum) or **structure** (down axis, mask). Allowed operations: scalars — `multiply` or `set`; counts — `add` or `set`; flags, choices and structures — `set` only.
6. **Effective value** (Formulas F1): the highest-priority `set` (if any) replaces the base; then all multipliers multiply (scalars) or all adds add (counts); then the result is clamped to the knob's safe range. Flags, choices and structures use the highest-priority `set`.
7. Effective values are **recomputed** whenever a rule starts or ends. A timer already running (a lock delay, a grace, a fall step) keeps the value it started with; the new value applies from the next start.

**Operation 2 — hook actions**
8. The framework calls rules at fixed **hook points**, owned by the core systems:

| Hook | Called by | When | Typical use |
|---|---|---|---|
| `on_level_start` | Level Goals | After Countdown | Place objects, set up the board |
| `on_spawn(piece)` | Spawner | A piece is created, before it appears | Add a tag, swap the shape |
| `on_tick(dt)` | Framework | Every frame while Playing | Wind or drift pushes, timers |
| `on_fall_step(piece)` | Fall, Drop & Lock | After each gravity step | Drift, spin |
| `on_lock(piece, cells)` | Fall, Drop & Lock | Cubes written, before the clear check | Sticky, convert, crumble |
| `on_clear(cell, content)` | Layer Clearing | Before a cleared cell's content is removed | Bombs, status effects |
| `on_resolve_end` | Layer Clearing | Board about to return to Live | Spawn objects, move blocks after placement |
| `on_top_out` | Level Goals | Before a warning or loss is applied | Override the warning rule |
| `on_goal_check` | Level Goals | After each resolve | Extra fail or win conditions |

9. Within one hook call, rules run in **ascending priority** (F2), so for conflicting writes the **highest-priority rule writes last and wins** (Board / Grid criterion 18).
10. Actions may trigger hooks (a bomb's `on_clear` clears more cells). The chain depth is limited to `max_hook_depth` (default 4); deeper actions are dropped and logged.

**Operation 3 — vetoes**
11. A rule may veto an action at a hook (for example, "this layer does not clear", "tilt is disabled"). A veto applies if its rule's priority is **equal to or higher than** the priority of the rule (or base system) asking for the action. A vetoed player command returns `Disabled` (Movement & Rotation), with feedback that a rule blocked it.

**Priority and conflicts**
12. Priority order is **level mechanic (4) > twist (3) > item/buff (2) > perk (1) > base (0)**. Within a layer, the rule activated later has higher priority; if two activate in the same frame, the higher `rule_id` in sort order wins (deterministic). A level mechanic that contradicts a general rule (e.g. "full layers do not clear here") therefore always wins over twists, items and perks.

**The API rules may use**
13. Actions go through the framework, never directly into a core system:
    - board: `set`, `clear`, `move` content; change the mask or the down axis (only applied during Resolving, Board / Grid);
    - piece: `try_translate(delta)` and `place_nearest_up()` (Movement & Rotation), replace the shape (Spawner / Movement);
    - queue: `inject_front`, `add_to_next_bag`, `set_preview_count`, `set_hold_enabled` (Spawner);
    - goals: add an extra fail or win condition (Level Goals);
    - random numbers: each rule gets its **own seeded stream** from the round seed and its `rule_id`; it never uses the Spawner's stream (Spawner Core Rule 2).
14. Board content writes from `on_tick` or `on_fall_step` are applied at the end of the frame; if they overlap the falling piece, `place_nearest_up()` runs (Board / Grid edge case).

**Limits and readability**
15. Per level, at most `max_twists` (default 2) twists and `max_level_mechanics` (default 1) level mechanics are active; Level Data fails validation above that. Items, buffs and perks are capped by their own systems.
16. **Every active rule is visible**: its icon is in the HUD for as long as it lasts, and twists and level mechanics are shown on the Intro goal card. A rule with no icon fails validation.
17. Validation warns when two rules at the same layer `set` the same parameter to different values in the same level (one will always be hidden).

### States and Transitions

Per rule instance:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Pending** | Declared, not yet active (level data, queued item) | Level load; item picked up | Its start condition → Active |
| **Active** | Modifiers applied, hooks called | Start condition met | Lifetime ends → Expired; level ends → Expired |
| **Suspended** | Lifetime clock frozen | Pause, warning, Resolving (for duration rules) | Resume → Active |
| **Expired** | Removed; effective values recomputed | Lifetime over or level end | — |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | ↔ | Content writes, mask and down-axis changes (in Resolving); all twist changes to the board go through here |
| Piece Spawner & Queue | ↔ | `on_spawn` hook; injects, bag additions, preview and hold changes; randomizer and weights as parameters |
| Movement & Rotation | ↔ | `try_translate`, `place_nearest_up`, axis and kick parameters, `landed_move_rule`, vetoes on commands |
| Fall, Drop & Lock | ↔ | `on_fall_step`, `on_lock` hooks; gravity, lock and drop parameters |
| Layer Clearing | ↔ | `on_clear`, `on_resolve_end` hooks; `clear_enabled`, `collapse_mode`, vetoes |
| Level Goals & Fail States | ↔ | `on_level_start`, `on_top_out`, `on_goal_check`; `warnings_max`; extra conditions |
| Level-Specific Mechanics, Twist Library | → Framework | Rules at layers 4 and 3 |
| Items, Buffs & Debuffs, Skills | → Framework | Rules at layer 2 |
| Characters & Perks, Shop | → Framework | Rules at layer 1 |
| Obstacles, Block Status Effects, Physics Mode | ↔ | Use the same hooks and API |
| Level Data & Definition | → Framework | Which rules a level declares, with parameters |
| HUD, Game Feel & VFX, Audio | Framework → | Active rules, start/end events, "blocked by a rule" feedback |

## Formulas

All values are starting defaults.

### F1. Effective parameter value

The effective_parameter formula is defined as:

scalars: `v = clamp( (s_top ?? v_base) × Π m_i , v_min, v_max )`; counts: `v = clamp( (s_top ?? v_base) + Σ a_i , v_min, v_max )`; flags, choices, structures: `v = s_top ?? v_base`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_base | any | knob range | data file (core GDD) | The base value |
| s_top | any or none | knob range | calculated | The `set` value from the highest-priority active rule that sets this parameter |
| m_i | float | > 0 (0 only if the knob allows 0) | data file (rules) | Multipliers from all active rules |
| a_i | int | any | data file (rules) | Additions from all active rules |
| v_min, v_max | number | — | data file (core GDD) | The knob's safe range |

**Output Range:** always within the knob's safe range. **Example:** gravity scale: base 1, a slow potion ×0.5 and a fast twist ×1.5 → 0.75. Lock delay: a level mechanic sets 300 ms, a perk ×1.2 → 360 ms. Preview count: base 1, perk +1, item +2 → 4, clamped to the cap 3. Clearing: base `true`, a twist sets `true`, the level mechanic sets `false` → `false`.

### F2. Rule priority

The rule_priority formula is defined as:

`key = (layer_rank, activated_at, rule_id)`, compared in that order; higher key = higher priority

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| layer_rank | int | 0–4 | data file | base 0, perk 1, item_buff 2, twist 3, level_mechanic 4 |
| activated_at | int | ≥ 0 | calculated | Play-time tick when the rule became Active |
| rule_id | string | — | data file | Deterministic tie-breaker |

**Output Range:** a total order over active rules. **Example:** a twist activated at tick 10 beats an item activated at tick 900 (layer 3 > 2); of two items, the one at tick 900 beats the one at tick 10.

### F3. Active rule budget

The rule_budget formula is defined as:

`valid = (n_twists ≤ max_twists) AND (n_level_mechanics ≤ max_level_mechanics)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_twists, n_level_mechanics | int | ≥ 0 | calculated (Level Data) | Rules of each layer declared for the level |
| max_twists | int | 0–4 | data file | Default 2 |
| max_level_mechanics | int | 0–2 | data file | Default 1 |

**Output Range:** true / false (a level fails validation when false). **Example:** a level with wind, invisible blocks and a gravity flip as twists → 3 > 2 → invalid.

### F4. Remaining lifetime

The rule_lifetime formula is defined as:

`remaining_ms = duration_ms − active_play_ms` (duration rules); `remaining_pieces = pieces − locks_since_start` (piece rules)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| duration_ms | int | > 0 | data file (rule) | Rule length in play time |
| active_play_ms | int | ≥ 0 | calculated | Time the rule has been Active, excluding Suspended time |
| pieces | int | > 0 | data file (rule) | Rule length in pieces |
| locks_since_start | int | ≥ 0 | calculated (Fall, Drop & Lock) | Pieces locked by the scoped player since the rule started |

**Output Range:** the rule expires at 0. **Example:** a 10-second slow potion used just before a 1-second warning wipe expires 11 seconds of real time later (warnings suspend it).

## Edge Cases

- **If two rules at the same layer `set` one parameter in the same frame**: the higher `rule_id` wins (F2); validation warned at load.
- **If an item tries to undo a level mechanic** (e.g. re-enable clearing in a no-clear level): the level mechanic wins; the item's icon shows "no effect" and the item is still consumed unless the Items GDD says otherwise.
- **If a multiplier would push a value outside its knob's range**: clamped (F1); the clamp is logged for tuning.
- **If a multiplier of 0 is applied to a knob whose range excludes 0**: validation fails.
- **If a rule targets a parameter that is not rule-adjustable**: validation fails.
- **If a rule starts or ends while a timer is running**: the running timer keeps its value; the new value applies at its next start.
- **If a rule asks for a mask or down-axis change outside Resolving**: it is queued and applied at the next Resolving.
- **If a rule's board write overlaps the falling piece**: applied at the end of the frame, then `place_nearest_up()`; if impossible, spawn blocked (top-out).
- **If hook actions chain beyond `max_hook_depth`**: the deeper actions are dropped and logged.
- **If a veto and an action have equal priority**: the veto wins.
- **If a rule targets an opponent who is out** (versus): no effect; the item is not consumed.
- **If a level declares more than 2 twists or more than 1 level mechanic**: validation fails (F3).
- **If a duration rule is active during pause, a warning or Resolving**: its clock is Suspended.
- **If a piece-count rule's player has no piece locking for a long time**: it simply lasts longer; piece rules have no time cap unless they also set a duration.
- **If a rule's random choices must match across players** (shared versus): its stream is seeded from the round seed and `rule_id`, so all players see the same sequence.
- **If two different rules want to replace the same falling piece in one `on_spawn`**: the higher-priority replacement wins (last write).
- **If Physics Mode is active**: hooks owned by systems it replaces are not called; its own GDD lists which hooks it offers.

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | Content API, mask, down axis, Resolving |
| Piece Spawner & Queue | Hard | `on_spawn`; queue API |
| Movement & Rotation | Hard | `try_translate`, `place_nearest_up`, command vetoes |
| Fall, Drop & Lock | Hard | `on_fall_step`, `on_lock`; parameters |
| Layer Clearing | Hard | `on_clear`, `on_resolve_end`; parameters |
| Level Goals & Fail States | Hard | `on_level_start`, `on_top_out`, `on_goal_check` |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Level-Specific Mechanics, Twist Library | Hard | Define rules at layers 4 and 3 |
| Level Data & Definition | Hard | Declares rules per level; F3 validation |
| Obstacles, Block Status Effects, Physics Mode | Hard | Hooks and API |
| Buffs & Debuffs, Items, Skills | Hard | Layer-2 rules |
| Characters & Perks, Shop | Hard | Layer-1 rules |
| HUD, Game Feel & VFX, Audio | Soft | Active-rule display and events |

All six upstream GDDs mention the framework; each must add its rule-adjustable knobs to a "rule-adjustable" note when next revised (see Open Questions).

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| max_twists | 0–4 | 2 | data file | Twists per level (F3) |
| max_level_mechanics | 0–2 | 1 | data file | Level mechanics per level (F3) |
| max_hook_depth | 1–8 | 4 | data file | Chain reactions from actions |
| layer order | permutation of the 5 layers | mechanic > twist > item/buff > perk > base | data file | Who wins conflicts (F2); change only with care |
| framework_budget_ms | 0.2–2 | 0.5 | data file | Time per frame the framework may use on the reference phone |

## Visual/Audio Requirements

- **Active-rule icons**: every active rule shows its icon in the HUD rule strip; twists and level mechanics use the hazard orange frame, buffs the cyan chevron and debuffs the magenta chevron (art bible §4 effect accents); perks show only on the pause screen.
- **Start and end**: a rule starting pops its icon in with a short label (≤ 2 words); ending fades it out. Duration rules show a shrinking ring.
- **Blocked by a rule**: a command vetoed by a rule shows the vetoing rule's icon briefly next to the piece instead of the plain bonk.
- **Twist intro**: the Intro goal card shows the level's twists and mechanic as icons beside the goal.
- Each rule's own visuals and sounds belong to its GDD (Twist Library, Items…); the framework only sends `rule_started`, `rule_ended`, `rule_blocked` events.

## Game Feel

The player should never wonder why the game behaved differently: every rule that changes play is on screen, and every surprising refusal points at the rule that caused it. Targets: rule icons visible within one frame of starting; the framework's own work ≤ 0.5 ms per frame on the reference phone with 2 twists, 1 level mechanic and 4 items/buffs active.

## UI Requirements

- HUD rule strip (icons, rings for duration rules), Intro card icons, "blocked by" pop, pause-screen list of all active rules including perks with one-line descriptions.
- 📌 **UX Flag — Rule-Twist Framework**: run `/ux-design` for the HUD rule strip and the pause-screen rule list.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 3, 5, 6; Edge Cases; criterion 18 | All twist changes go through the framework; mask and down-axis changes in Resolving; last-write priority |
| `design/gdd/piece-spawner-queue.md` Core Rules 2, 5, 14; Interactions | Separate RNG stream; injects; bag additions; preview and hold |
| `design/gdd/movement-rotation.md` Core Rules 8, 9, 19 | `try_translate`, `place_nearest_up`, `Disabled` |
| `design/gdd/fall-drop-lock.md` Core Rule 18; Tuning Knobs | Gravity, lock and drop parameters |
| `design/gdd/layer-clearing.md` Core Rules 2, 5, 15 | `clear_enabled`, `on_clear`, vetoes, collapse mode |
| `design/gdd/level-goals-fail-states.md` Core Rules 8, 11 | Warnings, extra fail conditions |
| `design/gdd/systems-index.md` | Bottleneck; conflict resolution between level mechanics and general rules |
| `design/art/art-bible.md` §4 | Effect accent colours for rule icons |
| `design/gdd/game-concept.md` | Pillars; twist list |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

**Parameters**
1. [U] F1: gravity scale ×0.5 and ×1.5 → 0.75; lock delay set 300 by a level mechanic and ×1.2 by a perk → 360; preview +1 and +2 → clamped to 3; `clear_enabled` set true by a twist and false by the level mechanic → false.
2. [U] **GIVEN** a rule ends, **THEN** the effective value is recomputed in the same frame and equals the value without that rule.
3. [U] **GIVEN** a lock delay running at 500 ms, **WHEN** a rule changes it to 300, **THEN** the running timer keeps 500 and the next one starts at 300.
4. [U] **GIVEN** a rule targeting an unknown parameter or multiplying a no-zero knob by 0, **THEN** the level fails validation.

**Priority, hooks and vetoes**
5. [U] F2: a twist at tick 10 outranks an item at tick 900; of two items, tick 900 outranks tick 10; same tick → higher `rule_id`.
6. [U] **GIVEN** two rules write different content to one cell in one hook call, **THEN** the higher-priority rule's content remains (Board criterion 18).
7. [U] **GIVEN** a level-mechanic veto on clearing layer 0 and an item that clears layer 0, **THEN** layer 0 is not cleared and the item shows "no effect".
8. [U] **GIVEN** a twist vetoing tilt, **WHEN** the player tilts, **THEN** Movement returns `Disabled` and the twist's icon pops next to the piece.
9. [U] **GIVEN** a chain of 6 hook actions, **THEN** actions beyond depth 4 are dropped and logged.
10. [I] **GIVEN** each hook in rule 8, **WHEN** its moment occurs, **THEN** subscribed rules are called once, in ascending priority.

**API and determinism**
11. [U] **GIVEN** a mask change requested while Live, **THEN** it applies at the next Resolving.
12. [U] **GIVEN** an `on_tick` write overlapping the falling piece, **THEN** it applies at the end of the frame and the piece is lifted by `place_nearest_up()`.
13. [U] **GIVEN** the same round seed and rule, **THEN** its random choices are identical across runs and across players, and the Spawner's sequence is unchanged by the rule.

**Limits, lifetimes and readability**
14. [U] F3: 3 twists or 2 level mechanics → validation fails; 2 + 1 → valid.
15. [U] F4: a 10 s rule active through a 1 s warning and a 2 s pause expires after 10 s of active play.
16. [U] **GIVEN** a 3-piece rule, **THEN** it expires on the 3rd lock by its player.
17. [U] **GIVEN** a rule with no icon, **THEN** validation fails.
18. [I] **GIVEN** any rule starts, **THEN** its icon is in the HUD within one frame; when it ends, the icon is removed.
19. [U] **GIVEN** an item targeting an opponent who is out, **THEN** nothing happens and the item is not consumed.
20. [I] **GIVEN** 2 twists, 1 level mechanic and 4 items/buffs active on the reference phone, **THEN** framework time per frame ≤ 0.5 ms (profiler, 60 s sample).
21. [M] **GIVEN** a playtest of the MVP level with 2 twists and a contradicting level mechanic stacked, **THEN** at least 80% of testers can name what each active rule does after one level (systems index mitigation).

## Open Questions

- **Rule-adjustable knob list**: each core GDD should mark which of its knobs rules may change (and confirm safe ranges). Do this in one pass after the MVP GDDs are done.
- **Scripted actions**: which language and sandbox for rule behaviours (Godot scripts with a restricted API?) → becomes an ADR after `/setup-engine`.
- **Layer order exceptions**: should some items deliberately outrank twists (a "shield" that ignores wind)? If needed, add a per-rule `priority_bonus` rather than changing the order.
- **Items consumed with no effect**: confirm with Items (consumed vs. refunded).
- **Perk visibility**: perks are on the pause screen only — is that enough for Readable Chaos in versus?
- **More than 2 twists**: tournament minigames may want 3; revisit after the MVP playtest.
