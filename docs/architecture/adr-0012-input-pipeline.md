# ADR-0012: Input Pipeline (Touch, Keyboard/Mouse, Gamepad) on GUIDE

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user: wave 1 decision sheet 2026-10-10), lead-programmer, godot-specialist (engine validation)

## Summary

GUIDE (`addons/guide`, 0.14.0) is the only input layer for touch, keyboard/mouse and gamepad. Every device feeds the same GUIDE actions. Touch buttons are `GUIDEVirtualButton`s on a virtual joypad, so the on-screen pad and a real gamepad take the same path. `GameInput` (one node, per player seat) turns actions into a small set of game signals. `BoardController` turns those signals into tick-stamped `SimCommand`s in `_physics_process` (ADR-0001, ADR-0010). Rotation has three pairs (spin, tilt, roll). Remapping, control presets, button scale and repeat timings are player settings stored through the save ADR (0013) and applied through GUIDE's remapping config. The existing code in `src/game/input/` is the base: this ADR names what stays, what is renamed, and what is added.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Input / UI |
| **Layer** | Game (`src/game/input/`); `src/core` never imports it |
| **Knowledge Risk** | HIGH: GUIDE 0.14.0 is a third-party GDScript addon released after the model's cutoff, and 4.6 dual focus changes how UI focus and gamepad interact. Nothing in `docs/engine-reference/godot/modules/input.md` covers GUIDE |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/input.md`, `modules/ui.md`; `addons/guide/plugin.cfg` (0.14.0), `addons/guide/guide.gd` (`enable_mapping_context`, `set_remapping_config`, `inject_input`, `input_mappings_changed`), `addons/guide/remapping/` (`GUIDERemapper`, `GUIDERemappingConfig`, `GUIDEInputDetector`); `src/game/input/*` as written today |
| **Post-Cutoff APIs Used** | GUIDE 0.14.0 (autoload `GUIDE`, `GUIDEAction`, `GUIDEMappingContext`, `GUIDEVirtualButton`, `GUIDERemapper`); 4.6 dual focus (`grab_focus()` is keyboard/gamepad only) |
| **Verification Required** | (1) `GUIDEVirtualButton` on Android release export: multi-touch (two thumbs plus a third finger), no dropped release, `InputEventJoypadButton` on the virtual device reaches `joy_index "Any"` mappings. (2) `GUIDERemapper` API in 0.14.0: rebind one action on one device class, conflict query, `GUIDERemappingConfig` round trip to a `Dictionary` that the save ADR can persist. (3) Touch-to-visible-move latency < 50 ms (TR-touch-controls-004) with GUIDE's own `_process` read before `GameInput._process` in the same frame; measure on the reference phone. (4) A virtual button resized at runtime (75-200%) keeps its hit area equal to its drawn size. (5) Which free joypad button indices a third virtual pair can use without colliding with real-gamepad bindings (see Decision 3). (6) `GUIDE` autoload and `GUIDEVirtualButton` survive `SceneTree.paused` as intended (see Decision 8) |

**Verification result (2026-10-10, MB-005, live editor 4.7.2 + GUIDE 0.14.0, evidence `production/qa/evidence/MB-005/`):** V2 **PASS with caveat** — `GUIDERemapper` rebind (hard_drop Space→H), `get_input_collisions` (Q reports `rot_h_left`), and a `GUIDERemappingConfig` round trip through a path-keyed JSON `Dictionary` all work; but `GUIDE.set_remapping_config()` on an already-enabled context is ignored (GUIDE reuses the cached action mapping), so apply it as disable context → `set_remapping_config` → enable context (verified: H fires, Space no longer does). V5 **PASS** — virtual buttons on X(2), Y(3), GUIDE(5), L3(7), R3(8), MISC1(15), TOUCHPAD(20), MISC2(21) all reach `joy_index Any` actions; unbound by the play context today are 2, 3, 5, 7, 8, 15, 20, 21. Recommended third pair: X/Y (same as the real-gamepad roll binding, no new collision); MISC1/TOUCHPAD are the spare fallback. V6 **PARTIAL** — the `GUIDE` autoload runs `PROCESS_MODE_ALWAYS` and keyboard/gamepad actions fire under `SceneTree.paused`; `GUIDEVirtualButton`s under a default (pausable) `TouchInput` do NOT (no `_input` while paused) and work once `TouchInput` is `PROCESS_MODE_ALWAYS`. Also: `GameInput` signals still emit while paused (signal callbacks ignore pause), so `GameInput` must gate on `get_tree().paused` itself. No Decision 8 fallback needed: give the pause overlay's buttons/`TouchInput` `ALWAYS`.

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Accepted): `SimCommand`, fixed 60 Hz tick, commands applied in arrival order; ADR-0010 (Accepted): `cancel_all()` contract, `BoardController` pending list, `AppFlow.request_pause()` |
| **Enables** | ADR-0009 local multiplayer (per-seat command stream), ADR-0013 save/settings (control settings schema), ADR-0014 camera (view-relative axis resolution, `view_rotate`), ADR-0016 UI (focus and gamepad navigation), ADR-0017 level-maker (verb and axis lists) |
| **Blocks** | GP-5 first playable (full control set); Meadow `meadow_02` (teaches the third rotation pair); ACC-10, ACC-11, ACC-15 stories |
| **Ordering Note** | The three-pair axis ids (`&"spin"`, `&"tilt"`, `&"roll"`) are decided (user, 2026-10-10); ADR-0014 and the movement-rotation GDD use the same ids. Control knobs (`control.*`) must be in the knob registry (ADR-0004) before `GameInput` stops reading its two hardcoded repeat exports |

## Context

### Problem Statement

A first input layer already exists as a prototype (`GameInput`, `TouchInput`, `RepeatTimer`, `Gestures`, eleven `GUIDEAction` resources and one keyboard+gamepad context), but no ADR owns it. Five things are undecided: how the three platforms share one path; how many mapping contexts exist and who switches them; how rotation grows from two pairs to three; where the 100 ms waiting-state buffer lives without breaking "nothing buffered across a pause" (ADR-0010); and how remap, scale and presets reach the player and survive a restart. The user decided (2026-10-10) that Android and PC/Steam ship together with touch, keyboard/mouse and gamepad, and that rotation gets a third pair taught in `meadow_02`.

### Constraints

- ADR-0001: `BoardSim` is pure RefCounted and knows no devices. It receives `SimCommand`s only.
- ADR-0010: `BoardController` is the only caller of `sim.queue_command()` and only inside `_physics_process`; `input.cancel_all()` must drop touches, gestures, held actions and buffers.
- architecture.md principle 5: few autoloads. `GUIDE` is a third-party autoload (already registered in `project.godot`) and is recorded here as an exception, like Orchestrator in ADR-0010.
- GDD touch-controls rule 1: controls emit discrete commands; the sim decides success. Input code never reads the board.
- Accessibility: ACC-11 (touch remap), ACC-14 (targets, in-play >= 56 dp, gap >= 8 dp), ACC-15 (keyboard and gamepad remap, menus navigable), ACC-16 (no chords, soft drop toggle, repeat can be off), ACC-18 (timing sliders), ACC-10 (presets).
- Values are data: repeat timings, gesture thresholds, buffer window, button scale limits come from `control.*` knobs, not constants.
- Flagship phones are the target (decision sheet), so the per-frame cost budget is generous, but latency is not (< 50 ms).
- Local multiplayer: one device normally has one local player, but a PC may have two keyboards/pads later. The seam must not assume a single `GameInput`.

### Requirements

- One code path for all three device classes after the GUIDE action layer.
- Mapping contexts per screen or mode, enabled and disabled in one place.
- Three rotation pairs with view-relative meaning (spin, tilt, roll); enabled axes come from the level.
- On-screen buttons are the default touch preset; gestures and one-handed presets are alternatives; all are layouts of the same virtual-button set.
- Remap on every device class; reset to default per page (ACC-03); button scale 75-200%, never below 56 dp.
- Move auto-repeat (DAS/ARR) with a repeat-off option; deterministic given the same inputs and tick stamps.
- Latest-only buffer of 100 ms for move or rotate pressed in the Waiting state; hard drop and hold never buffered.
- Pause, backgrounding and rotate-pause cancel everything and buffer nothing.

## Decision

### 1. One layer, one path

```
Keyboard / mouse ─┐
Gamepad ──────────┼─▶ GUIDE (autoload) ─▶ GUIDEAction (rot_*, move, ...) ─▶ GameInput ─signals─▶ BoardController ─▶ SimCommand ─▶ BoardSim
TouchInput ───────┘   (GUIDEVirtualButton / virtual joypad, joy_index "Any")        (per seat)       (_physics_process)
```

- No script calls `Input.is_action_pressed` or reads `InputEvent` for gameplay. The only exceptions are `InputProbe` (dev) and UI focus navigation, which uses Godot `ui_*` actions (mapped separately, see Decision 2).
- Touch buttons are `GUIDEVirtualButton`s that inject `InputEventJoypadButton` on a virtual device. The play context maps gamepad buttons with `joy_index "Any"`, which includes virtual pads. So touch needs no mapping of its own, and a remap of a gamepad binding is also a remap of the matching on-screen button's action. This is kept as is (`touch_input.gd`).
- Buttons with no real-gamepad button (Flip, View) borrow `JOY_BUTTON_PADDLE1-4`. These indices are internal plumbing, never shown to the player. The remap UI shows the on-screen button's label.
- `GameInput` stays the only translator from `GUIDEAction` to game signals. It keeps its present signals (`move`, `rotate_piece`, `soft_drop`, `hard_drop`, `view_rotate`, `pause_pressed`, `restart_pressed`) and adds `hold_pressed` and `use_item(slot)`/`use_skill(slot)` when those systems land. It has no knowledge of the board.

### 2. Mapping contexts per screen and mode

A context is a `GUIDEMappingContext` resource under `src/game/input/contexts/`. `InputContextRouter` (new, plain Node under `Main`, not an autoload) is the only caller of `GUIDE.enable_mapping_context` / `disable_mapping_context` for gameplay and menu contexts; `GameInput.enable()` / `disable()` call the router instead of GUIDE directly.

| Context | Active when | Contents |
|---|---|---|
| `play` (today `play_keyboard.tres`, renamed to `play.tres`; it already holds keyboard and gamepad bindings) | `PlaySession` stepping, plus Countdown and Warning | move, spin/tilt/roll pairs, soft drop, hard drop, view, hold, pause, restart |
| `play_paused` | Pause overlay, resume beat | resume, restart, back; no piece actions |
| `menu` | Title, island map, settings, results, dialogs | navigate, accept, back, tab prev/next. Wraps Godot's `ui_*` actions so focus navigation (4.6 dual focus) works on keyboard and gamepad. Touch uses plain `Control` taps and needs no context |
| `remap_capture` | A remap row is listening | `GUIDEInputDetector` only; all other contexts disabled while it listens |
| `mechanic_<verb>` (later) | A `ControlVerb` (ADR-0004 slot `control.verb`) replaces the piece verb on a level | its own actions; replaces `play`'s piece actions, keeps pause/restart |

- Priority is explicit: `remap_capture` > `play_paused`/`menu` > `play`. `AppFlow` (ADR-0010) tells the router the current screen id on every push and pop, so the router does not poll scene state. Entering Pause disables `play` and enables `play_paused`, which is the input half of "nothing acts across a pause".
- The player's remapping config is applied with `GUIDE.set_remapping_config()` once at boot and again after a remap is saved or reset. Both calls go through the router.

### 3. Three rotation pairs

Rotation is three pairs, each a left/right (+1/-1) action. Axis ids are view-relative, as in movement-rotation GDD rule 9, and the sim never sees them:

| Pair (player-facing name) | Axis id | GUIDE actions | Today | Taught in |
|---|---|---|---|---|
| Turn: spin (turntable, world Y) | `&"spin"` | `rot_spin_left`, `rot_spin_right` | `rot_h_*` / `&"horizontal"` | `meadow_01` |
| Flip: tilt (horizontal world axis nearest screen-horizontal) | `&"tilt"` | `rot_tilt_left`, `rot_tilt_right` | `rot_v_*` / `&"vertical"` | `meadow_01` or `meadow_02` per level data |
| Roll: roll (the other horizontal world axis) | `&"roll"` | `rot_roll_left`, `rot_roll_right` | none | `meadow_02` |

- **Migration (rename, not rewrite):** `&"horizontal"` becomes `&"spin"` and `&"vertical"` becomes `&"tilt"`; `rot_roll_*` `.tres` actions and their bindings are added; `GameInput.enabled_axes` defaults to `[&"spin", &"tilt", &"roll"]` and is set by `BoardController` from the level's enabled axes. A disabled axis emits nothing (matches today's `try_rotate`, and matches the sim's `Disabled` result for the rare case a command still reaches it). The existing `game_input_test.gd` is updated for the new ids.
- **Names (user, 2026-10-10):** player-facing names are Turn / Flip / Roll, mapping to code ids `spin` / `tilt` / `roll`. Names are UI text keys; ids never change with the wording.
- **Default bindings, proposed:** keyboard Q/E = spin, R/F = tilt (already), roll on a free pair (proposed `1`/`3` or `Shift+Q/E` is rejected by ACC-16, so a single-key pair is needed); gamepad shoulders = spin (Turn), triggers = tilt (already), roll on X/Y (`JOY_BUTTON_X`/`JOY_BUTTON_Y`); **View ◀/▶ = right stick X** (`JOY_AXIS_RIGHT_X`, deflection threshold → one snap step, held = repeat; amendment 2026-10-10 — shoulders are never View). Final keys are confirmed in the first-playable pass, since the user's decision is "three pairs", not specific keys.
- **Touch, buttons:** two more `GUIDEVirtualButton`s in the rotate cluster, on free joypad indices (Verification 5; `JOY_BUTTON_MISC1` and the touchpad index are candidates). **Touch, gestures:** `Gestures.classify` keeps flick = spin (horizontal) or tilt (vertical); roll uses the two roll arcs (touch-controls Scheme B). No new gesture class is needed.

### 4. Touch presets, gestures and one-handed layout

All touch presets are data-driven layouts over the same widgets; the present `TouchInput.LAYOUT` constant moves to `assets/data/controls/touch_layouts.json` (anchor fractions per orientation, per preset), read by `TouchInput` at `_ready`.

| Preset (ACC-10) | What it is | Widgets |
|---|---|---|
| Buttons (default until the prototype decides; Scheme A) | Twin pads: d-pad left, rotate cluster right | `GUIDEVirtualButton`s as today |
| Gestures (Scheme B) | Left zone drag = move, right zone flick = spin/tilt, roll arcs, drop button | `GestureZone` Controls (new) that call `Gestures.classify` and emit through the same `GameInput` signals; drop and roll arcs stay `GUIDEVirtualButton`s |
| One-handed (R or L) | All play controls in one corner cluster | Buttons preset, repositioned into one arc by the layout file |
| Simple | Buttons, hold-repeat on, soft-drop toggle | Same widgets, different settings values |

- Zone ownership: a touch belongs to the zone where it started until it lifts (touch-controls rule 17/AC 17). `GestureZone` tracks by finger index; `cancel_all()` clears the table.
- Left-hand mirror swaps sides in the layout, not in the action mapping, so "left still moves screen-left".
- Portrait and landscape each have their own layout block. `TouchInput` re-lays out on `size_changed` and on the safe-area change from ADR-0014. Controls sit outside the safe-area insets and outside the board area (no on-board input).
- Gestures supply discrete `move(screen_dir)`/`rotate_piece` signals, identical to buttons, so the sim path is unchanged. Drag movement uses F1 (dead zone once per drag, `drag_px_per_cell`) in a pure helper next to `Gestures`.

### 5. Remap, scale and settings

- **Remap** uses `GUIDERemapper` and `GUIDEInputDetector`. Keyboard/mouse and gamepad rebinding go through the standard remap UI (ACC-15). Touch remap (ACC-11) is different: the player reassigns an on-screen button's action, not its input. That is stored as a `button_action` table (`slot id -> action id`) in the touch settings, and `TouchInput` maps each slot to the joypad index of the target action's gamepad binding. One action per button; a conflict swaps (ACC-11). No chord is ever offered (ACC-16).
- **Reset to default** per page (ACC-03) clears that device class's remap entries and re-applies the shipped contexts.
- **Button scale 75-200%, minimum 56 dp** for in-play buttons. `button_radius` (44 px exported today) becomes `scale * base_radius_dp * dp_to_px`, where `dp_to_px = DisplayServer.screen_get_dpi() / 160.0` on Android and a fixed value on PC. The result is clamped so that the drawn diameter is never under 56 dp, even at 75% (so 75% shrinks spacing and decoration first, not hit areas below the minimum); the gap between in-play buttons is at least 8 dp (ACC-14). Settings warns if the cube edge would drop under 20 px (touch-controls AC 19).
- Persisted fields (TR-touch-controls-007), owned by the save ADR (0013) under `settings.controls`: `preset`, `mirror`, `one_handed_side`, `button_scale`, `button_action` table, `gesture_sensitivity` (`drag_px_per_cell`, flick thresholds), `repeat` (`das_ms`, `arr_ms`, `enabled`), `soft_drop_toggle`, `haptics`, `reduced_motion` (follows the OS setting, decision sheet), and the `GUIDERemappingConfig` per device class. This ADR defines the keys' meaning; ADR-0013 defines the file and its version.
- One profile in MVP: there is one `settings.controls`. Per-seat overrides for local multiplayer are a later extension (Decision 7).

### 6. Repeat (DAS/ARR)

- `RepeatTimer` stays as written: pure, deterministic, `update(dir, delta) -> int`. `GameInput` keeps owning one instance and feeding it the held `MOVE` direction each frame.
- Delay and interval move from the two `@export` values (170/50 ms) to `control.das_ms` and `control.arr_ms` knobs (ACC-18 sliders, ranges from touch-controls F3, clamped on load). `repeat.enabled = false` means the held direction fires once per press (ACC-16).
- Repeat runs in `_process` (frame time) because it belongs to the input device, not the sim. Replays are unaffected: a replay stores the resulting `SimCommand`s with their tick stamps, so repeat timing is not part of determinism.
- Soft drop is a held state, not a repeat: `soft_drop(true/false)` becomes `soft_drop_on` / `soft_drop_off` commands (ADR-0001). With the toggle setting, one press flips it, and `cancel_all()` clears it.
- Hold-repeat applies to the d-pad and, when the player turns it on, to rotate buttons (touch-controls F3). Hard drop, hold, pause and restart never repeat.

### 7. Input to sim commands, on the tick

Input signals are frame-rate; the sim is 60 Hz. `BoardController` bridges them (ADR-0010 contract kept):

1. `GameInput` signals call `BoardController.push_command(cmd)` with a typed `SimCommand` (`move` with a screen-resolved world direction from the camera map, `rotate` with the resolved world axis and sign, `soft_drop_on/off`, `hard_drop`, `hold`). The view-relative to world resolution lives in the view/camera layer (ADR-0014), called by `BoardController`. The sim only sees world axes.
2. `push_command` appends to the controller's pending list. Several presses within one frame are kept in arrival order and none is merged (touch-controls: rotations are never lost).
3. In `_physics_process`, just before `sim.step()`, the controller drains the list: each command is stamped with the next tick and passed to `sim.queue_command()`. Commands returned `Blocked`/`Disabled` come back as `SimEvent`s and trigger feedback (bonk, haptic).
4. **Waiting-state buffer (100 ms).** While the sim phase says no piece is active, the controller does not drain move/rotate to the sim. It keeps a one-slot buffer `{command, press_tick}` that each new move or rotate replaces. On the spawn tick it applies the slot if `spawn_tick - press_tick <= ceil(input_buffer_ms * SIM_HZ / 1000)` (6 ticks at 100 ms), else drops it. Hard drop and hold in Waiting are discarded, never stored. The window is counted in ticks, so it is deterministic and unaffected by frame rate.
5. **Pause.** On `request_pause()` the controller calls `GameInput.cancel_all()` (clears active touches by index, gesture state, `RepeatTimer`, held soft drop, toggle state; calls `Input.flush_buffered_events()`; `GUIDE` virtual buttons are released) and `BoardController.clear_pending()` (also clears the Waiting buffer). Nothing survives a pause. The `play` context is disabled and `play_paused` enabled.
6. **Rotate-pause** (phone turned mid-level) goes through the same `request_pause(&"rotate")` path.
7. **Latency.** Touch -> visible move < 50 ms: a GUIDE virtual button fires on the touch event, `GameInput` signals the same frame, the controller drains at the next physics tick (at most ~16.7 ms), and the view eases visibly within the sim window (ADR-0001). Verified on device, not asserted.
8. **Multiplayer seam (ADR-0009).** `GameInput` and `TouchInput` are per-seat instances, with an exported `seat: int` (default 0) and a `device_filter` (`joy_index` or keyboard group) that the router passes to GUIDE contexts. A seat's `GameInput` signals reach only that seat's `BoardController`, and `BoardController` stamps commands the same way for a local seat as for a networked one, so ADR-0009's per-board command stream is the same type regardless of origin. Remote players never create a `GameInput`. Only one `GameInput` has `touch` and keyboard/mouse by default; extra gamepads can claim extra seats from the lobby in a later story. For MVP, one seat exists, and the seam is the exported `seat` plus the per-seat router call.

### 8. Pause, focus and GUIDE processing

- `GameInput` and `TouchInput` are `PROCESS_MODE_PAUSABLE` for gameplay; the `menu` and `play_paused` contexts are consumed by `AppFlow` and UI nodes that run `WHEN_PAUSED` or `ALWAYS` (ADR-0010). `GUIDE` itself must keep processing while paused so `play_paused`/`menu` actions work. Verification 6 confirms this; if GUIDE pauses with the tree, the fallback is that the pause overlay uses Godot `ui_*` actions directly for resume/back and `GUIDE` serves play contexts only.
- After a pause or resume the router re-asserts the right context, so a context can never be left on after a screen is gone.
- `cancel_all()` is the only interface other systems use to stop input. Nothing outside `src/game/input/` touches GUIDE.

### Implementation Guidelines

- Gameplay scripts must never read `Input` or `InputEvent` directly; they use `GameInput` signals.
- Only `InputContextRouter` may call `GUIDE.enable_mapping_context` / `disable_mapping_context` / `set_remapping_config`.
- Axis ids are `StringName` constants in one place (`InputAxes`), never string literals (ADR-0010 rule for ids).
- `src/core` must not import `src/game/input/` (existing layering test covers this; extend it to cover `GUIDE*` identifiers).
- Repeat, buffer window, gesture thresholds and scale limits must come from `control.*` knobs. The two exports in `GameInput` and the `button_radius` export in `TouchInput` are prototype leftovers to remove.
- `BoardController` must never `await` in the drain path (ADR-0001).
- Every public `GameInput`/`TouchInput`/`InputContextRouter` method gets a doc comment (coding standard); the pure helpers (`RepeatTimer`, `Gestures`, the F1 drag helper, the buffer logic) stay RefCounted so gdUnit tests run them headless.
- All on-screen text (button labels, remap rows) uses translation keys; the arrows used as labels today are art/icon assets, not text.
- No analytics or event logging of input in release.

## Alternatives Considered

### Alternative 1: Godot `InputMap` and `Input.is_action_*` directly
- **Pros**: no dependency; engine-native; remapping through `InputMap` API.
- **Cons**: no mapping contexts, no per-device modifiers/triggers, no virtual touch buttons or joysticks, no built-in remapper UI helpers; every one of these would be hand-written, including the multi-touch widgets.
- **Rejection Reason**: GUIDE gives all of them, and the user chose GUIDE (the addon is installed and the prototype already uses it).

### Alternative 2: A bespoke touch layer separate from the gamepad path
- **Pros**: full control of gestures; no virtual-device trick.
- **Cons**: two code paths to test; remap and presets would have to be implemented twice.
- **Rejection Reason**: Touch as a virtual gamepad means one binding set, one remap, and one test surface. Gestures stay a thin additional emitter on top of the same signals.

### Alternative 3: Commands applied immediately in the input callback
- **Pros**: lowest possible latency.
- **Cons**: breaks "only inside `_physics_process`" (ADR-0010), makes pause cancel racy, and makes replays order-dependent.
- **Rejection Reason**: The worst-case added latency is one physics tick (~16.7 ms), inside the 50 ms budget.

### Alternative 4: Buffer in wall-clock milliseconds
- **Rejection Reason**: A wall-clock window is frame-rate dependent. Ticks are exact and replayable.

## Consequences

### Positive
- One path for three platforms; a remap or a binding fix is made once.
- Contexts per screen mean a menu press can never move a piece, and a paused game cannot receive piece actions.
- Deterministic buffering and an explicit cancel contract.
- Existing prototype code, tests and `.tres` actions are kept; the changes are renames, one new pair, one router, and moving constants to data.

### Negative
- Dependency on a third-party addon at 0.14.0 (pre-1.0), plus an autoload.
- The virtual-gamepad trick spends joypad indices; the third rotation pair makes this tighter (Verification 5).
- Touch remap of on-screen buttons is a custom layer on top of GUIDE's device-level remapper.
- `GameInput` is no longer a single global node: seat awareness adds a small amount of plumbing for a feature MVP does not use.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| `GUIDEVirtualButton` misbehaves with 3+ simultaneous touches on some Android devices | Medium | High | Verification 1 on a device; fallback is `Control`-based buttons that call the same `GameInput` methods |
| GUIDE pauses with the tree and menu/pause contexts stop working | Medium | Medium | Verification 6; fallback in Decision 8 (Godot `ui_*` for pause overlay) |
| Not enough clean joypad indices for six rotation buttons + view + hold | Medium | Medium | Roll on `MISC1`/touchpad indices; if still short, a custom `Control` button class for the extra pair, feeding `GameInput` directly |
| GUIDE 0.14.0 API changes before release | Medium | Medium | Only `src/game/input/` imports GUIDE; version pinned in the addon folder |
| Scale 75% with a 56 dp minimum leaves too little room in portrait on small phones | Low | Medium | Spacing and decoration shrink first; Settings warns; device check at both orientations |
| Repeat in frame time feels different at 30 vs 120 fps | Low | Low | `RepeatTimer` is delta-based and tested at fixed deltas; flagship target |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| touch-controls.md (TR-touch-controls-001) | Controls emit discrete commands; sim decides success | `GameInput` signals -> `SimCommand`s; blocked results come back as events for feedback |
| touch-controls.md (TR-touch-controls-002) | Waiting-state buffer: latest move/rotate within 100 ms; never drop/hold | Decision 7 item 4: one-slot, tick-counted buffer in `BoardController`; hard drop and hold discarded |
| touch-controls.md (TR-touch-controls-003) | Gesture classification, multi-touch zones, zone ownership, board exclusion, mirror, haptics | Decision 4: `Gestures.classify`, `GestureZone` per finger index, layouts mirrored in data, zones outside the board |
| touch-controls.md (TR-touch-controls-004) | Touch-to-visible-move < 50 ms | Decision 7 item 7: same-frame signal, drain at next physics tick; device measurement (Verification 3) |
| touch-controls.md (TR-touch-controls-005) | Backgrounding or call: pause at once, cancel touches, buffer nothing | Decision 7 item 5: `cancel_all()` + `clear_pending()`; contexts switched (shared with ADR-0010) |
| touch-controls.md (TR-touch-controls-006) | Control verb replaceable per mechanic or minigame | Decision 2: `mechanic_<verb>` contexts replace `play`'s piece actions (ADR-0004 slot `control.verb`) |
| touch-controls.md (TR-touch-controls-007) | Player settings persist: scheme, mirror, one-handed, sensitivities, haptics, scale, reduced motion | Decision 5: field list under `settings.controls`; file format by ADR-0013 |
| movement-rotation.md (TR-movement-rotation-002) | Atomic commands applied in arrival order, same frame too; result codes return for feedback | Decision 7 items 2-3: arrival order kept in the pending list; events carry results |
| movement-rotation.md (TR-movement-rotation-003) | View-relative spin/tilt/roll mapping from the camera snap | Decision 3: three view-relative axis ids; resolution to world axis in the camera layer (ADR-0014) |
| accessibility-requirements.md ACC-03, ACC-10, ACC-11, ACC-14, ACC-15, ACC-16, ACC-18, ACC-70 (no TR ids yet) | Presets, remap, targets, no chords, timing sliders, both orientations | Decisions 4, 5, 6 |

> New TR ids are not invented here. The ACC rows have no entry in `tr-registry.yaml`; `/architecture-review` Phase 8 should add them when it next runs.

## Performance Implications
- **CPU**: negligible. 14-16 `GUIDEVirtualButton`s and two `GUIDEAction` reads per frame; `RepeatTimer` and the buffer are O(1).
- **Memory**: a handful of small resources (actions, contexts, layout JSON).
- **Load Time**: contexts are preloaded constants; the layout JSON is read once.
- **Latency**: <= 1 physics tick (~16.7 ms) between signal and sim command; total < 50 ms on device (to be measured).
- **Network**: none. Local seats add no traffic; remote seats do not use this layer.

## Migration Plan

Existing code is kept and extended, not rewritten:

1. `src/game/input/actions/`: rename `rot_h_*` -> `rot_spin_*` and `rot_v_*` -> `rot_tilt_*` (keep `.uid`s so references survive); add `rot_roll_left.tres` / `rot_roll_right.tres`; add `hold.tres` when hold lands.
2. `src/game/input/contexts/`: rename `play_keyboard.tres` -> `play.tres`; add roll bindings; add `play_paused`, `menu` and `remap_capture` contexts.
3. `game_input.gd`: new axis ids and `enabled_axes` default; `enable()`/`disable()` call the router; `cancel_all()` added; `seat` export; repeat timings from knobs.
4. `touch_input.gd`: layout from JSON, per preset and orientation; runtime scale; `cancel_all()`; two roll buttons.
5. New: `InputContextRouter`, `GestureZone`, `InputAxes`, `assets/data/controls/touch_layouts.json`, knobs `control.das_ms`, `control.arr_ms`, `control.input_buffer_ms`, `control.button_scale_min/max/default`.
6. `tests/unit/game_input/`: update `game_input_test.gd` for new ids; keep `repeat_timer_test.gd`; add tests for the buffer, the scale clamp and the router.
7. `docs/architecture/tr-registry.yaml`: point TR-touch-controls-001 to -007 and TR-movement-rotation-002/003 at this ADR once Accepted. `architecture.md`: add a line for the input layer and the `GUIDE` autoload exception.

**Rollback plan**: if GUIDE fails a device verification, replace `GUIDEVirtualButton` with `Control` buttons that call `GameInput` methods (Risks table). The signals, the commands and the sim do not change.

## Validation Criteria

- [ ] [U] `RepeatTimer`: the existing tests stay green; additionally a change of direction counts as a fresh press and `repeat.enabled = false` fires once per press.
- [ ] [U] `GameInput`: `spin`, `tilt` and `roll` each emit with ±1; an axis not in `enabled_axes` emits nothing; after `disable()` nothing emits and a held soft drop is released.
- [ ] [U] Buffer: a move at tick T-6 applied to a spawn at T; at T-7 dropped; a later rotate replaces an earlier move; hard drop and hold in Waiting are never stored.
- [ ] [U] `cancel_all()` clears touches, gesture state, repeat state, soft-drop toggle and the buffer; `clear_pending()` leaves the sim queue empty.
- [ ] [U] Scale: `scale` 75% -> in-play button diameter >= 56 dp; 200% is the maximum; gap >= 8 dp.
- [ ] [U] Router: entering Pause enables `play_paused` and disables `play`; `remap_capture` disables everything else; leaving restores the prior set.
- [ ] [I] Headless: with `input_simulate` (or GUIDE `inject_input`), a keyboard-only and a gamepad-only run wins `meadow_01` (ACC-15); remap Turn ▶, restart the test scene, the binding holds.
- [ ] [I] Presets: each of Buttons, Gestures, One-handed, Simple wins `meadow_01` by simulated input (ACC-10); with soft-drop toggle and repeat off, `meadow_01` is winnable with one finger (ACC-16).
- [ ] [M] Reference phone, 3-finger multi-touch: two thumbs plus a third finger, no dropped release (Verification 1), screenshot in `production/qa/evidence/`.
- [ ] [M] Reference phone: touch-to-visible-move < 50 ms (high-speed capture or timing log).
- [ ] [M] Reference phone, portrait and landscape, 75% and 200% scale: every in-play button measures >= 56 dp with >= 8 dp gaps (ACC-14); screenshots retained.
- [ ] [M] Home button, app switcher, incoming call with a held button: no input acts after resume (shared with ADR-0010).
- [ ] [M] `meadow_02` teaches roll: the third pair is available on buttons, on the roll arcs (gestures) and on keyboard and gamepad.

## Related
- ADR-0001 (depends on: `SimCommand`, tick), ADR-0004 (`control.verb` slot, `control.*` knobs), ADR-0009 (per-seat command stream), ADR-0010 (depends on: `cancel_all`, `request_pause`, pending list)
- ADR-0013 (settings storage), ADR-0014 (view-relative axes, safe area, `view_rotate`), ADR-0016 (menu focus and navigation), ADR-0017 (level-maker enabled axes)
- `design/gdd/touch-controls.md`, `design/gdd/movement-rotation.md`, `design/accessibility-requirements.md`
- `src/game/input/` (`game_input.gd`, `touch_input.gd`, `repeat_timer.gd`, `gestures.gd`, `actions/`, `contexts/`), `tests/unit/game_input/`

## Amendment (2026-10-10)

Status unchanged (Accepted). Cross-doc fixes from `production/session-state/conflicts-open.md`:
- Gamepad View ◀/▶ = right stick X; shoulders stay Turn (spin). Never View on shoulders.
