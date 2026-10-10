# Architecture Traceability Index
Last Updated: 2026-10-10
Engine: Godot 4.7.2

## Coverage Summary
- Total requirements: 242
- Covered: 128 (52%)
- Partial: 74
- Gaps: 40

Source: `/architecture-review` 2026-10-10 — `docs/architecture/architecture-review-2026-10-10.md`. All covering ADRs are Accepted.

## Full Matrix

| Requirement ID | GDD | System | Requirement | ADR Coverage | Status | Note |
|---|---|---|---|---|---|---|
| TR-board-grid-001 | board-grid.md | Board / Grid | One board store, the single source of truth; O(1) is_free/get/layer_full; can_place O(piece cells) | ADR-0002 §1–4 | ✅ | Flat packed arrays, fixed world index, counters |
| TR-board-grid-002 | board-grid.md | Board / Grid | Size and cell mask set per level from untrusted data; validated at load, naming the cell/rule | ADR-0002 §6; ADR-0005 | ✅ | Validated before allocation; ValidationIssue names the field |
| TR-board-grid-003 | board-grid.md | Board / Grid | Down axis in any of 6 directions; flipping re-indexes layers without moving contents; only while Resolving | ADR-0002 §2; ADR-0004 RuleApi | ✅ | `_layer_order` rebuild; `request_down_axis` queued until Resolving |
| TR-board-grid-004 | board-grid.md | Board / Grid | Per-content-type solid/fills_layer, blocking vs overlay; overlay on-lock collected/squashed/kept | ADR-0002 §3; ADR-0004 `on_enter` | ✅ | CELL/OVERLAY slot per content type |
| TR-board-grid-005 | board-grid.md | Board / Grid | Setup/Live/Resolving/Frozen gate writes; twist writes only via framework, priority order, last write wins | ADR-0002 mutators; ADR-0004 RuleApi | ✅ | Buffered writes applied at end of tick in priority order |
| TR-board-grid-006 | board-grid.md | Board / Grid | Height limit and spawn zone along ±x/±z gravity (H_play_axis = E_down − C; E_down ≥ C+6) | ADR-0002 | ⚠️ | ADR-0002 Open Item 1 (also architecture.md open question) is still unresolved |
| TR-board-grid-007 | board-grid.md | Board / Grid | Cell-change stream for view, HUD and VFX (stack height, limit, cell changes) | ADR-0002 §5 delta; ADR-0001 events | ✅ | `take_delta()` → `cells_changed` SimEvent |
| TR-board-grid-008 | board-grid.md | Board / Grid | Footprint has no maximum size (large boards gated only by the readability check) | ADR-0002 §6 | ⚠️ | ADR imposes hard caps (24/side, 8192 cells) that the GDD does not have; see revision flag |
| TR-piece-set-001 | piece-set.md | Piece Set | 67-shape bank: offsets, bbox, family, motif, spawn orientation from one data source matching the art | ADR-0003 Extraction | ✅ | Generated `shape_bank.tres` from GLBs |
| TR-piece-set-002 | piece-set.md | Piece Set | 24 proper rotations only, mirrors kept distinct, distinct-orientation list per F4, integer and device-identical | ADR-0003 Decision | ✅ | Precomputed TURN table, canonical key |
| TR-piece-set-003 | piece-set.md | Piece Set | Shapes rejected at load if not face-connected or duplicated up to rotation | ADR-0003 Extraction | ✅ | Checked by the extractor plus a unit test |
| TR-piece-set-004 | piece-set.md | Piece Set | Validate the level piece set: empty set, F3 fit, L_max → spawn clearance, hue-band warnings | ADR-0005 validator; ADR-0002 §6 | ✅ | ValidationContext carries the shape bank; palette JSON |
| TR-piece-set-005 | piece-set.md | Piece Set | Per-instance tags (behaviour/junk/owner_set) never change the shape; tag conflicts settled by framework priority | ADR-0002 §1 `pieces[uid]`; ADR-0003 `tags` | ⚠️ | Tag storage is defined, but how a `behaviour` tag binds to a RuleBehaviour and how conflicts resolve is not stated |
| TR-piece-set-006 | piece-set.md | Piece Set | Giant family pieces up to 27 cubes must work in movement, kicks, rendering and ghost | ADR-0003; ADR-0007 | ⚠️ | No ADR budget for 9–27-cube pieces (kick query bound, ~27k-vertex piece + ghost GLB); see revision flag |
| TR-piece-spawner-queue-001 | piece-spawner-queue.md | Spawner | Piece stream is a pure function of (seed, scope, config, index); peeking ahead never changes it | ADR-0006 Streams | ✅ | Per-bag derived seeds; FNV-1a derivation |
| TR-piece-spawner-queue-002 | piece-spawner-queue.md | Spawner | The stream has its own generator; no gameplay event draws from it | ADR-0006 | ✅ | Rules and items use separate streams |
| TR-piece-spawner-queue-003 | piece-spawner-queue.md | Spawner | Injected pieces outside the stream; shared/independent mode; per-player extras sub-stream | ADR-0006 Streams | ✅ | Scope part; `extra` stream |
| TR-piece-spawner-queue-004 | piece-spawner-queue.md | Spawner | Same seed plus same inputs reproduces the game (replay) | ADR-0001 Commands/Replay | ✅ | Command log replay into a fresh BoardSim |
| TR-piece-spawner-queue-005 | piece-spawner-queue.md | Spawner | Rules/items call inject_front, add_to_next_bag, set_preview_count, set_hold_enabled | ADR-0004 RuleApi | ⚠️ | RuleApi lists inject_front and add_to_next_bag only; preview and hold as rule-adjustable knobs is implied, not stated |
| TR-piece-spawner-queue-006 | piece-spawner-queue.md | Spawner | Versus: every device deals identical pieces from the host-supplied round_seed | ADR-0009 sim req. 5; ADR-0006 | ✅ | Only `round_seed` is sent |
| TR-movement-rotation-001 | movement-rotation.md | Movement & Rotation | Falling piece not stored in the grid; one collision authority (try_translate/can_place) for move, fall, ghost | ADR-0002 queries; ADR-0001 | ✅ | `can_place`, `cast(dir)` |
| TR-movement-rotation-002 | movement-rotation.md | Movement & Rotation | Atomic commands applied in arrival order (same frame too); result codes return to Touch for feedback | ADR-0001 Commands in | ⚠️ | Ordering is covered. Results arrive as next-tick SimEvents, not the synchronous return the GDD implies; the bonk feedback path is not defined |
| TR-movement-rotation-003 | movement-rotation.md | Movement & Rotation | Integer 90° world-axis rotation; view-relative spin/tilt/roll mapping from the camera snap | ADR-0003 TURN table | ✅ | Input is mapped to a world axis before the lookup |
| TR-movement-rotation-004 | movement-rotation.md | Movement & Rotation | Kick search capped at ≤14 placement tests / 112 cell queries per rotation | ADR-0002 perf table | ⚠️ | Only implied by can_place cost; the bound fails for Giant pieces (27 cubes → 378 queries) |
| TR-movement-rotation-005 | movement-rotation.md | Movement & Rotation | Rules can lift (place_nearest_up), swap shape, restrict axes, change kick limits and landed rule | ADR-0004 RuleApi, knobs | ✅ | — |
| TR-movement-rotation-006 | movement-rotation.md | Movement & Rotation | Down-axis flip mid-piece: cells kept; ground axes and up-kick follow the new axis | ADR-0001 travel direction; ADR-0002 | ✅ | — |
| TR-fall-drop-lock-001 | fall-drop-lock.md | Fall, Drop & Lock | Lock 500 / grace 150 / entry 200 ms timers exact, frame-rate independent, frozen on pause | ADR-0001 Clock | ✅ | Integer-ms deadlines on a 60 Hz tick |
| TR-fall-drop-lock-002 | fall-drop-lock.md | Fall, Drop & Lock | Gravity in cells/s with ramp and scale; gravity clock carries across soft-drop toggles | ADR-0001 Clock (g_milli) | ✅ | Fixed-point milli-units; loader converts decimals once |
| TR-fall-drop-lock-003 | fall-drop-lock.md | Fall, Drop & Lock | Single 10-step per-lock sequence (lock→on_lock→clear→on_resolve_end→goal→top-out→outcome→entry delay→spawn) | ADR-0001 step(); ADR-0004 hooks | ⚠️ | ADR-0001's step order leaves out the top-out steps and entry delay, and does not say whether goal/top-out run at the start or end of the t_resolve window |
| TR-fall-drop-lock-004 | fall-drop-lock.md | Fall, Drop & Lock | No piece and no input effect during Resolving; outcome can't change mid-sequence | ADR-0001 Resolving duration | ✅ | Sim never waits for the view |
| TR-fall-drop-lock-005 | fall-drop-lock.md | Fall, Drop & Lock | Ghost and drop target update in the same frame as every move, rotation or fall step | ADR-0001; ADR-0007 §2 | ⚠️ | Commands apply on the next tick (≤17 ms) and the view interpolates; "same frame" is not literally guaranteed |
| TR-fall-drop-lock-006 | fall-drop-lock.md | Fall, Drop & Lock | App backgrounded → all timers freeze (Frozen); resume exactly | ADR-0001 Clock | ⚠️ | ADR says backgrounding stops ticking but no mechanism (Android pause/focus notifications) → see gap Level Flow & App Lifecycle |
| TR-fall-drop-lock-007 | fall-drop-lock.md | Fall, Drop & Lock | Rules adjust gravity scale/base/ramp, lock delay, resets, down axis; wind/drift via try_translate | ADR-0004 knobs, RuleApi | ✅ | — |
| TR-layer-clearing-001 | layer-clearing.md | Layer Clearing | Pluggable clear detectors (layer/row/colour/…) and collapse modes (slice/cascade/chunks) | ADR-0004 slots `clear.detector`, `clear.collapse` | ✅ | — |
| TR-layer-clearing-002 | layer-clearing.md | Layer Clearing | Logical clear instant; visuals staggered over t_resolve (capped); sim never blocks on view | ADR-0001; ADR-0007 dying MultiMesh | ✅ | — |
| TR-layer-clearing-003 | layer-clearing.md | Layer Clearing | on_clear hooks per cell, bottom-to-top, before removal; per-layer/cell vetoes | ADR-0004 hooks, vetoes | ✅ | — |
| TR-layer-clearing-004 | layer-clearing.md | Layer Clearing | Slice shift, cascade and chunk settle with chain_max; bounded cost | ADR-0002 `shift_layers`, `connected`, `column_cells` | ✅ | — |
| TR-layer-clearing-005 | layer-clearing.md | Layer Clearing | layer_cleared events carry cubes and owners; clear_resolved; layers_cleared count | ADR-0002 delta REMOVE(cause) + per-piece owner | ✅ | — |
| TR-layer-clearing-006 | layer-clearing.md | Layer Clearing | wipe_bottom(k) silent rescue: slice-only, no hooks, no counts, only rescue_wiped event | ADR-0004 TopOutPolicy; ADR-0002 | ⚠️ | No RESCUE delta cause (causes: CLEAR, DISPLACED, DAMAGE, MASKED, TRIM); the hook-bypass contract is not written down |
| TR-level-goals-fail-states-001 | level-goals-fail-states.md | Goals | Goal types clear/height/survive/shape/endless, one per level, swappable | ADR-0004 `goal.type` slot | ✅ | `endless` not in the listed plugins, but the slot is extensible |
| TR-level-goals-fail-states-002 | level-goals-fail-states.md | Goals | topout_rule rescue/trim/lose per level, rule-adjustable | ADR-0004 `goal.top_out` slot | ✅ | — |
| TR-level-goals-fail-states-003 | level-goals-fail-states.md | Goals | Level flow Intro→Countdown→Playing→Warning→Won/Lost/Out, Paused; results fan out | — | ❌ | **Gap: Level Flow & App Lifecycle State Machine** (Core/Scripting, MEDIUM). Also decides on the untracked `godot_state_charts` addon |
| TR-level-goals-fail-states-004 | level-goals-fail-states.md | Goals | Level clock runs only while Playing (not countdown, warning, pause); drives stars and Survive | ADR-0001 tick time; ADR-0004 lifetimes | ⚠️ | Sim time comes from ticks; the countdown/warning exclusion and who owns the level clock are not defined |
| TR-level-goals-fail-states-005 | level-goals-fail-states.md | Goals | Survive and time-limit conditions checked continuously ("every frame") | ADR-0001 | ⚠️ | Must be per sim tick, not per frame; see revision flag |
| TR-level-goals-fail-states-006 | level-goals-fail-states.md | Goals | On result: board Frozen, input Disabled; result/clock/counts sent to Scoring, Campaign, Tournament | ADR-0001 events | ⚠️ | Events exist; consumers and the result payload contract are not defined (ties to the flow gap) |
| TR-level-goals-fail-states-007 | level-goals-fail-states.md | Goals | Versus: own goal per board; same-time ties broken by layers cleared, then stack | ADR-0009 (acceptance 4, round clocks) | ✅ | See the revision flag on "same frame" |
| TR-camera-rotate-view-001 | camera-rotate-view.md | Camera | One orthographic size per level and orientation, fits all 12 yaws; recomputed on orientation change | ADR-0007 §3 (outline vs ortho_h) | ⚠️ | ADR uses ortho_h but no ADR owns the camera rig/framing or its recompute trigger |
| TR-camera-rotate-view-002 | camera-rotate-view.md | Camera | Camera publishes yaw plus screen→world direction map; switches instantly while the turn animates | ADR-0003 (mapping note) | ⚠️ | No ADR defines the camera↔input contract (who owns the map, how it reaches SimCommands) |
| TR-camera-rotate-view-003 | camera-rotate-view.md | Camera | Fade occluders (alpha 0.3/100 ms, outline too); Cutaway fallback above 40 | ADR-0007 §4 | ✅ | DDA from piece/ghost cubes; dithered fade |
| TR-camera-rotate-view-004 | camera-rotate-view.md | Camera | Per-level occlusion mode Fade/Cutaway/Ghost-only | ADR-0007 §4 (`cut_layer`) | ✅ | — |
| TR-camera-rotate-view-005 | camera-rotate-view.md | Camera | Falling piece, ghost and height line never hidden or faded | ADR-0007 §2, §4 | ✅ | — |
| TR-camera-rotate-view-006 | camera-rotate-view.md | Camera | Portrait and landscape; turning mid-level pauses, re-lays out, reframes, keeps yaw step | — | ❌ | **Gap: Screen Orientation, Safe Area & Layout Profiles** (Platform/UI, MEDIUM: Android sensor orientation, DisplayServer safe area) |
| TR-touch-controls-001 | touch-controls.md | Touch Controls | Controls emit discrete commands; sim decides success | ADR-0001 SimCommand queue | ✅ | — |
| TR-touch-controls-002 | touch-controls.md | Touch Controls | Waiting-state buffer: latest move/rotate within 100 ms applied to the new piece; never drop/hold | ADR-0001 | ⚠️ | Not said whether the buffer lives in input (wall clock) or in the sim (ticks); this affects replay determinism. Movement rule 5 drops commands when no piece |
| TR-touch-controls-003 | touch-controls.md | Touch Controls | Gesture classification, multi-touch zones, zone ownership, board-area exclusion, mirror, haptics | — | ❌ | **Gap: Touch Input Pipeline (InputEvent → SimCommand)** (Input/Platform, MEDIUM: 4.6 dual-focus, 4.7 VirtualJoystick, Android vibrate permission) |
| TR-touch-controls-004 | touch-controls.md | Touch Controls | Touch-to-visible-move latency < 50 ms on device | ADR-0001 (≤1 tick) | ⚠️ | Only sim latency is budgeted; interpolation lag (+1 tick) and Android Vulkan present latency are not |
| TR-touch-controls-005 | touch-controls.md | Touch Controls | Backgrounding or phone call: pause at once, cancel touches, buffer nothing across pause | — | ❌ | Covered by gap **Level Flow & App Lifecycle State Machine** |
| TR-touch-controls-006 | touch-controls.md | Touch Controls | Control verb replaceable per mechanic or minigame | ADR-0004 `control.verb` slot | ✅ | — |
| TR-touch-controls-007 | touch-controls.md | Touch Controls | Player settings persist: scheme, mirror, one-handed, sensitivities, haptics, scale, reduced motion | — | ❌ | **Gap: Save, Profile & Settings Persistence** (Core/Persistence, LOW–MEDIUM: 4.4 FileAccess return types) |
| TR-hud-001 | hud.md | HUD | Display-only; reacts to sim events in the same frame; never writes game state | ADR-0001 node side | ✅ | BoardController re-emits typed signals |
| TR-hud-002 | hud.md | HUD | Preview drawn from current camera yaw; re-rendered within one frame of a view turn | ADR-0007 §6 | ⚠️ | ADR bakes one static angle per shape at level load; see revision flag |
| TR-hud-003 | hud.md | HUD | Safe-area layout; never overlaps the board rect at 12 yaws; mirror and 150% scale variants | — | ❌ | Covered by gap **Screen Orientation, Safe Area & Layout Profiles** |
| TR-hud-004 | hud.md | HUD | Rule strip from active-rule start/end/blocked events with durations | ADR-0004 `rule_started`/`rule_ended`/`rule_blocked` | ✅ | — |
| TR-scoring-stars-001 | scoring-stars.md | Scoring & Stars | Score events (clear, combo, drop, place, obstacle) computed deterministically from sim events | ADR-0004 (scoring atoms are RuleBehaviours) | ⚠️ | No owner for core scoring; the formula uses fractions, which conflicts with integer-only math (revision flag) |
| TR-scoring-stars-002 | scoring-stars.md | Scoring & Stars | Stars from level clock and warnings/trim on result; star times in level data | ADR-0005 `stars {t2,t3}` ms | ✅ | — |
| TR-scoring-stars-003 | scoring-stars.md | Scoring & Stars | Best result per level persisted, never lost; old stars kept and marked on level version change | ADR-0005 `level_hash` (identity only) | ❌ | **Gap: Save, Profile & Settings Persistence** (Core/Persistence, LOW–MEDIUM) |
| TR-scoring-stars-004 | scoring-stars.md | Scoring & Stars | Invalid star data (t3 ≥ t2) fails validation | ADR-0005 validator | ✅ | — |
| TR-scoring-stars-005 | scoring-stars.md | Scoring & Stars | Versus/tournament standings consistent across devices | ADR-0009 host-computed standings | ✅ | — |
| TR-rule-twist-framework-001 | rule-twist-framework.md | Rule-Twist | Rule = data (layer, scope, lifetime, ops) plus optional behaviour using only the framework API | ADR-0004 §1, §2, §7 | ✅ Covered | `RuleBehaviour` via `RuleApi`; data cannot name code |
| TR-rule-twist-framework-002 | rule-twist-framework.md | Rule-Twist | Closed list of rule-adjustable knobs; unknown or non-adjustable parameter fails validation | ADR-0004 §3; ADR-0005 Validator | ✅ Covered | `rule_adjustable` flag in knob JSON |
| TR-rule-twist-framework-003 | rule-twist-framework.md | Rule-Twist | F1 effective value deterministic, recomputed on rule start/end; running timers keep their start value | ADR-0004 §3; ADR-0001 clock | ✅ Covered | Integer milli-unit fixed point |
| TR-rule-twist-framework-004 | rule-twist-framework.md | Rule-Twist | Fixed hook points dispatched in ascending F2 priority; highest priority writes last and wins | ADR-0004 §5 | ✅ Covered | Subscriber lists rebuilt only on start/end |
| TR-rule-twist-framework-005 | rule-twist-framework.md | Rule-Twist | Hook chain depth capped by `max_hook_depth`; deeper actions dropped and logged | ADR-0004 §5 | ✅ Covered | `rule_chain_dropped` event |
| TR-rule-twist-framework-006 | rule-twist-framework.md | Rule-Twist | Vetoes apply at priority ≥ requester (tie: veto); vetoed command returns Disabled with the rule's icon | ADR-0004 §6 | ✅ Covered | `VetoResult` names rule → `rule_blocked` |
| TR-rule-twist-framework-007 | rule-twist-framework.md | Rule-Twist | Each rule has its own seeded stream from round seed + rule_id, identical across players | ADR-0006; ADR-0009 sim req. 5 | ✅ Covered |  |
| TR-rule-twist-framework-008 | rule-twist-framework.md | Rule-Twist | on_tick/on_fall_step board writes buffered to end of tick; mask/down-axis changes queued to Resolving | ADR-0004 §7; ADR-0002 §5 | ✅ Covered |  |
| TR-rule-twist-framework-009 | rule-twist-framework.md | Rule-Twist | Duration/piece lifetimes; clocks suspended in pause, warnings and Resolving | ADR-0004 §8 | ✅ Covered |  |
| TR-rule-twist-framework-010 | rule-twist-framework.md | Rule-Twist | Framework ≤ 0.5 ms per frame with 2 twists, 1 mechanic, 4 buffs on reference phone | ADR-0004 Impl. Guidelines | ✅ Covered | Budget stated; device measurement still owed |
| TR-rule-twist-framework-011 | rule-twist-framework.md | Rule-Twist | rule_started/ended/blocked events reach HUD within one frame | ADR-0004 §6, §8; ADR-0001 events | ✅ Covered |  |
| TR-rule-twist-framework-012 | rule-twist-framework.md | Rule-Twist | "No effect" detection (every op loses to higher layers) reported to the cause for refund | ADR-0004 §6 | ⚠️ Partial | Veto result exists; no API reports "all modifiers overridden" (needed by Items refund, Buffs pop) |
| TR-twist-library-001 | twist-library.md | Twists | Twists move the piece only via try_translate; blocked pushes silent, no lock-delay reset | ADR-0004 §7 | ✅ Covered |  |
| TR-twist-library-002 | twist-library.md | Twists | Gust times, wind directions and object cells identical across runs and players for one seed | ADR-0006 rule stream | ✅ Covered |  |
| TR-twist-library-003 | twist-library.md | Twists | Telegraphs emitted ahead of action (wind warn, object cell chosen one lock early), world-anchored | ADR-0004 §7 `emit`; ADR-0001 events | ✅ Covered | View instances telegraph scene on event (modular layout) |
| TR-twist-library-004 | twist-library.md | Invisible Blocks | Per-block time-driven fade from lock time, reveal on clear, timer travels with the block | ADR-0007 §4, §5 | ⚠️ Partial | Dither fade and `invisible_alpha` exist; per-block lock-time fade clock and whether sim or view owns it undefined |
| TR-twist-library-005 | twist-library.md | Gravity Flip | Down axis flip in Resolving; layers re-indexed; stack settles as rigid slices to new floor | ADR-0002 §1, §5; ADR-0004 §7 | ✅ Covered | `set_down` + `shift_layers`, `request_down_axis` |
| TR-twist-library-006 | twist-library.md | Spawned Objects | Free top-surface cell query along current down axis; objects are solid, layer-filling content | ADR-0002 §3, §4 | ✅ Covered | Content table type |
| TR-twist-library-007 | twist-library.md | Twists | Incompatible twist/mechanic pairs fail validation | ADR-0004 §2; ADR-0005 | ✅ Covered | `incompatible_with` + atom tags |
| TR-mechanics-catalog-001 | mechanics-catalog.md | Catalog | Swappable strategies for clear, collapse, arrival, goal, top-out, board kind | ADR-0004 §1, §4 | ✅ Covered | Naming mismatch: see revision flags |
| TR-mechanics-catalog-002 | mechanics-catalog.md | Catalog | Colour rules read the Piece Set family colour key; unpainted content has no key | ADR-0002 §2 `color` | ⚠️ Partial | ADR stores palette hue id; family ↔ hue mapping per art set not specified |
| TR-mechanics-catalog-003 | mechanics-catalog.md | Turntable (BL11) | Rigid 90° rotation of whole stack during Resolving | ADR-0002 §5 | ⚠️ Partial | Only per-cell `move`; no rotate op; non-square footprints undefined |
| TR-mechanics-catalog-004 | mechanics-catalog.md | Physics ideas | Wobble, crane, pull-out, topple run as Physics Mode variants | ADR-0001 Exceptions; ADR-0004 `board.kind` | ⚠️ Partial | No Physics Mode ADR; Jolt default 4.6, SoftBody/Area changes 4.7 (HIGH) |
| TR-mechanics-catalog-005 | mechanics-catalog.md | Minigames | Tournament minigames as their own scenes | ADR-0004 §9 | ✅ Covered |  |
| TR-mechanics-catalog-006 | mechanics-catalog.md | Top-out | Top-out rule enum extensible (trim, shake, bonk, hearts) | ADR-0004 §1 `TopOutPolicy` | ✅ Covered |  |
| TR-mechanics-module-001 | mechanics-module.md | Box of Tricks | ~90 atoms map to slot plugins, RuleBehaviours or content without core edits | ADR-0004 §1, §2 | ✅ Covered |  |
| TR-mechanics-module-002 | mechanics-module.md | Box of Tricks | Compatibility tags and conflict/needs pairs validated for every level and generated mix | ADR-0004 §2 `atom_tags.json`; ADR-0005 | ✅ Covered | "Needs" pairs (CO04 needs CV12) must be expressible in the tag file |
| TR-mechanics-module-003 | mechanics-module.md | Box of Tricks | Recipe maps 1:1 onto level JSON fields | ADR-0005 `recipe` | ✅ Covered | Contradiction on runtime use: see flags |
| TR-mechanics-module-004 | mechanics-module.md | Box of Tricks | Context rules and novelty budget need campaign path order and context at validation | ADR-0005 `ValidationContext` | ⚠️ Partial | Context carries bank/knobs/rules/plugins only; no campaign path or context |
| TR-mechanics-module-005 | mechanics-module.md | Daily | Same date gives same recipe on every device; reroll then fallback; 1000 dates validate | ADR-0005 Daily; ADR-0006 | ✅ Covered |  |
| TR-mechanics-module-006 | mechanics-module.md | Control verbs | Verb atoms replace the input-to-command mapping (swap, tap_pop, board_slide…) | ADR-0004 §1 `ControlVerb` | ✅ Covered |  |
| TR-mechanics-module-007 | mechanics-module.md | Undo / Rewind | Undo last N locks on own or rival board (IN19, SP17), never across a clear | — | ❌ Gap | ADR: "Board history, undo and rewind" · Core · LOW. ADR-0001 lock veto covers WO11 only (before write) |
| TR-mechanics-module-008 | mechanics-module.md | Beat tempo | Gravity steps, sweep and on-beat lock follow music BPM (EV08, CL10, SC11) | — | ❌ Gap | ADR: "Music beat clock vs. sim clock" · Audio/Core · MEDIUM (Android audio latency; must stay deterministic) |
| TR-mechanics-module-009 | mechanics-module.md | Mascot | Mascot behaviours (helper nudge, prankster, mood from tidiness) decide and act at runtime | ADR-0004 §2 (layer `mascot`) | ⚠️ Partial | Gameplay effects fit RuleBehaviour; decision runtime (session note: Orchestrator + beehave) has no ADR; ADR-0011 absent |
| TR-mechanics-module-010 | mechanics-module.md | Secrets | Secret collection flags, cosmetics and hidden-level unlocks persist in Save & Profile | — | ❌ Gap | ADR: "Save & Profile persistence" · Persistence · LOW (`FileAccess.store_*` return bool since 4.4) |
| TR-mechanics-module-011 | mechanics-module.md | Physics atoms | BL13, BL16 seesaw, CO07 topple, SP36 bounce on real physics | ADR-0001 Exceptions | ⚠️ Partial | Same missing Physics Mode ADR; HIGH |
| TR-mechanics-module-012 | mechanics-module.md | Camera-dependent atoms | Gameplay depends on camera snap (SE05 angle gems, tap on 3D object) | — | ❌ Gap | ADR: "Camera rig, snap constraints and 3D picking" · Camera/Input · MEDIUM (GUIDE and Phantom Camera enabled in project.godot without an ADR) |
| TR-level-data-definition-001 | level-data-definition.md | Level Data | One storage format and loader for official and player levels | ADR-0005 Formats, Loader | ✅ Covered | GDD Open Question now resolved |
| TR-level-data-definition-002 | level-data-definition.md | Level Data | Omitted fields take owning-system defaults; level values are base, not rules | ADR-0005; ADR-0004 §3 | ✅ Covered |  |
| TR-level-data-definition-003 | level-data-definition.md | Level Data | Validator names level, field and rule; errors block play, warnings listed; at authoring and load | ADR-0005 Validator, Where validation runs | ✅ Covered |  |
| TR-level-data-definition-004 | level-data-definition.md | Level Data | ASCII grids for mask, starting contents and target shape | ADR-0002 §6; ADR-0005 | ✅ Covered |  |
| TR-level-data-definition-005 | level-data-definition.md | Level Data | Seed fresh per attempt, pinnable, or from Tournament | ADR-0006 | ✅ Covered |  |
| TR-level-data-definition-006 | level-data-definition.md | Level Data | Draft → Valid → Locked; shipped edit bumps version so saved stars stay meaningful | ADR-0005 `level_hash` | ⚠️ Partial | Identity is a hash, GDD says version; Save mapping of old results absent (no Save ADR) |
| TR-level-data-definition-007 | level-data-definition.md | Level Data | Validator fails cube edge < 20 px, warns < 28 px on reference phone | ADR-0002 §6.3 | ⚠️ Partial | Delegated to "camera's own validator", which no ADR defines |
| TR-level-data-definition-008 | level-data-definition.md | Level Data | Duplicate level ids across the campaign fail validation | ADR-0005 (per-file CI test) | ⚠️ Partial | Only per-file checks specified; no cross-file pass |
| TR-level-specific-mechanics-001 | level-specific-mechanics.md | Mechanics | Mechanic is a layer-4 rule; its sets and vetoes beat everything; max one per level | ADR-0004 §2, §5, §6 | ✅ Covered |  |
| TR-level-specific-mechanics-002 | level-specific-mechanics.md | Conveyor (M4) | Rigid shift of all content with wrap, carrying status, overlay and hp, before next spawn | ADR-0004 (conveyor `on_resolve_end`); ADR-0002 §5 `move` | ✅ Covered |  |
| TR-level-specific-mechanics-003 | level-specific-mechanics.md | Conveyor (M4) | No-wrap fall-off removes content without counting as clear or firing on_clear | ADR-0002 §5 causes | ⚠️ Partial | REMOVE causes lack a fall-off cause; Items also depends on it |
| TR-level-specific-mechanics-004 | level-specific-mechanics.md | Resolving | Fixed sub-step order: clear check, flip, conveyor shift, then next spawn | ADR-0004 §4, §7; ADR-0001 | ⚠️ Partial | Queued layout changes vs on_resolve_end behaviours have no defined order |
| TR-level-specific-mechanics-005 | level-specific-mechanics.md | Colour Pop (M5) | Face-connected same-key groups from ≥2 piece ids pop; cascade chain to chain_max | ADR-0002 §4 `connected`, `piece`; ADR-0004 slots | ✅ Covered |  |
| TR-level-specific-mechanics-006 | level-specific-mechanics.md | Row Clear (M8) | Row detector on x/z lines plus per-column slice collapse; masked rows ≥ row_min_len | ADR-0002 §4 `line_cells`; ADR-0004 slots | ✅ Covered |  |
| TR-level-specific-mechanics-007 | level-specific-mechanics.md | Sideways (M9) | Down axis any ground axis; camera snaps restricted by side_view_min_deg | ADR-0002 §1; ADR-0004 ArrivalStyle | ⚠️ Partial | Sim side covered; per-level camera snap restriction has no ADR (camera gap) |
| TR-level-specific-mechanics-008 | level-specific-mechanics.md | Slide-In (M10) | Piece glides along travel_dir with gravity paused; release command; ghost updates every tick | ADR-0004 `ArrivalStyle` side_travel; ADR-0002 `cast` | ✅ Covered |  |
| TR-level-specific-mechanics-009 | level-specific-mechanics.md | Two-Way Meet (M11) | Two halves with opposite down axes meeting at a solid seam | ADR-0002 §1, §7 | ⚠️ Partial | One down axis per BoardState; must be two linked boards: see flags |
| TR-level-specific-mechanics-010 | level-specific-mechanics.md | Mechanic cap | Pairing exception: one clear option + one arrival option count as one mechanic | ADR-0004 §2 F3 | ⚠️ Partial | F3 counts by layer; exception undecided |
| TR-obstacles-001 | obstacles.md | Obstacles | Obstacle content with per-instance hp, anchored, owner, tags | ADR-0002 §2 `extra[i]`, §3 | ✅ Covered |  |
| TR-obstacles-002 | obstacles.md | Pillars | Full-height anchored pillars never move in shifts, conveyors or flip settles | ADR-0002 §5 | ⚠️ Partial | `shift_layers` has no anchored/skip concept |
| TR-obstacles-003 | obstacles.md | Junk | Junk pushed in from the floor lifts whole stack; falling piece lifted; overflow removed | ADR-0002 §5; ADR-0004 §7 | ⚠️ Partial | No insert-at-floor mutator; `place_nearest_up` exists |
| TR-obstacles-004 | obstacles.md | Obstacles | Rule-placed obstacles only through API, applied end of tick or in Resolving | ADR-0004 §7 | ✅ Covered |  |
| TR-obstacles-005 | obstacles.md | Obstacles | Pillar share, spawn-zone and conveyor/flip conflicts validated | ADR-0005 plugin `validate()` | ✅ Covered |  |
| TR-obstacles-006 | obstacles.md | Obstacles | Crack (hp change) and break events reach view and audio | ADR-0002 §5 delta | ⚠️ Partial | No delta op for an hp change; break is `REMOVE(DAMAGE)` only |
| TR-obstacle-clearing-001 | obstacle-clearing.md | Obstacle Clearing | Damage step after Find, once per resolve (not per chain round), deferring layers | ADR-0004 §5, §6 | ⚠️ Partial | Veto/new hook can express it; clear-pipeline stage order and resolve-scoped state unspecified |
| TR-obstacle-clearing-002 | obstacle-clearing.md | Obstacle Clearing | Deferred layers excluded from slice shift and layers_cleared | ADR-0002 §5 `shift_layers(cleared)` | ✅ Covered |  |
| TR-obstacle-clearing-003 | obstacle-clearing.md | Obstacle Clearing | Rules call damage(cell, amount) through the framework | ADR-0004 §7 | ⚠️ Partial | `damage` not in RuleApi list |
| TR-obstacle-clearing-004 | obstacle-clearing.md | Obstacle Clearing | Break events carry source (layer, direct, adjacent, rescue) and owner | ADR-0002 §5 | ⚠️ Partial | REMOVE carries one cause, no source or owner |
| TR-obstacle-clearing-005 | obstacle-clearing.md | Obstacle Clearing | Rescue wipe removes regardless of hp, except pillars | ADR-0004 `TopOutPolicy` rescue | ✅ Covered |  |
| TR-block-status-effects-001 | block-status-effects.md | Status | One status per block; replaced by framework priority; moves and dies with block | ADR-0002 §2 `status[i]` | ✅ Covered | Record holds rule_id for priority |
| TR-block-status-effects-002 | block-status-effects.md | Status | Status behaviours on lock counters, resting check (honey) and fall step (spike) | ADR-0004 §5 | ✅ Covered | Honey needs a rest hook; ADR allows new hook names |
| TR-block-status-effects-003 | block-status-effects.md | Status | Spread randomness from the applying rule's stream | ADR-0006 | ⚠️ Partial | Statuses from `starting_contents` have no rule; their stream is undefined |
| TR-block-status-effects-004 | block-status-effects.md | Status | Status recognisable by look at play size (pulse, rim, badge, shadow alpha) | ADR-0007 §5 | ✅ Covered |  |
| TR-block-status-effects-005 | block-status-effects.md | Status | Piece status tag applied to all its cubes on lock | ADR-0002 §2 `pieces[uid].tags`, `set_status` | ✅ Covered |  |
| TR-buffs-debuffs-001 | buffs-debuffs.md | Effects | Layer-2 rule scoped to target; same effect refreshes lifetime, does not stack | ADR-0004 §8 | ⚠️ Partial | `activate` makes a new instance; refresh-instead-of-stack not defined |
| TR-buffs-debuffs-002 | buffs-debuffs.md | Effects | Opponent debuffs routed across devices; queued until target's Resolving ends | ADR-0009 §4; ADR-0004 `on_attack_received` | ✅ Covered |  |
| TR-buffs-debuffs-003 | buffs-debuffs.md | Junk Rain | Gap from effect stream, replayable on the target | ADR-0006 attack stream; ADR-0009 | ✅ Covered |  |
| TR-buffs-debuffs-004 | buffs-debuffs.md | Bomb | 3×3×3 removal at on_lock before clear check; no collapse in slice mode | ADR-0004 §5; ADR-0002 §5 | ✅ Covered |  |
| TR-buffs-debuffs-005 | buffs-debuffs.md | Helper Drop | Inject pieces outside the stream; stream index unchanged | ADR-0006; ADR-0004 `inject_front` | ✅ Covered |  |
| TR-buffs-debuffs-006 | buffs-debuffs.md | Fog | Target board follows Invisible Blocks fade with own timings | ADR-0007 §4, §5 | ⚠️ Partial | Same gap as TR-twist-library-004 |
| TR-items-001 | items.md | Items | One cube of a piece carries an item tag that persists after lock | ADR-0002 §2 | ⚠️ Partial | Tags are per piece; status slot is taken: see flags |
| TR-items-002 | items.md | Items | Item rolled at collection from items stream, weighted by live standing | ADR-0006; ADR-0009 `roll_rank` | ✅ Covered |  |
| TR-items-003 | items.md | Items | Collected only on clear removal, not bomb, rescue or fall-off | ADR-0002 §5 causes | ⚠️ Partial | Causes cannot tell rescue or fall-off from clear |
| TR-items-004 | items.md | Items | Per-player item slots; use_item(slot) command, queued during Resolving | ADR-0001 commands | ⚠️ Partial | Command path covered; inventory state owner (sim vs session) undefined |
| TR-items-005 | items.md | Items | Debuffs auto-target leader (then second); never a player who is out | ADR-0009 `leader_seat` | ✅ Covered |  |
| TR-items-006 | items.md | Items | items_enabled and item_slots set per mode, level or round | ADR-0004 knobs; ADR-0009 `round_setup` | ✅ Covered |  |
| TR-game-concept-001 | game-concept.md | Platform | Ship on iOS and Android mobile | ADR-0008 §7, ADR-0009 §11 | ⚠️ Partial | Android first only; no iOS export/plugin/signing plan |
| TR-game-concept-002 | game-concept.md | Input | Touch scheme for 3-axis rotation and moves on a fixed angled camera | ADR-0001 (SimCommand), ADR-0003 (view-relative TURN), ADR-0004 §1 ControlVerb | ⚠️ Partial | Gesture recognition, touch zones, multi-touch tracking not in an ADR (code exists in `src/game/input/`). Suggest "Touch Input & Gesture Pipeline" (Input, MEDIUM) |
| TR-game-concept-003 | game-concept.md | Rule-Twist | Dozens of combinable modular modifiers | ADR-0004 §1–§6 | ✅ Covered |  |
| TR-game-concept-004 | game-concept.md | Physics | Physics modes must perform on mobile hardware | — | ❌ Gap | "Physics Mode on Jolt" (Physics, HIGH) |
| TR-game-concept-005 | game-concept.md | Multiplayer | Local multiplayer first, online later | ADR-0009 §1–§9 | ✅ Covered |  |
| TR-game-concept-006 | game-concept.md | Data | 100 levels + modes as data, not code | ADR-0005 Formats/Level file | ✅ Covered |  |
| TR-game-concept-007 | game-concept.md | RNG | Seeded random mode selection and item pickups | ADR-0006 Streams | ✅ Covered |  |
| TR-game-concept-008 | game-concept.md | Audio | Per-biome music plus layer-clear / item SFX driven by events | — | ❌ Gap | "Audio Architecture: buses, event→cue map, music streaming" (Audio, MEDIUM: 4.7 `AudioStreamPlayer.area_mask` default change) |
| TR-game-concept-009 | game-concept.md | Performance | Whole-game 60 fps / memory budget on reference phone | ADR-0007 §7, ADR-0004 (0.5 ms), ADR-0008 §2 | ⚠️ Partial | Per-system budgets only; no consolidated frame/memory/load budget |
| TR-game-feel-vfx-001 | game-feel-vfx.md | Feedback | Consume move/lock/clear/warning/item events from all systems | ADR-0001 Commands/events, node side | ✅ Covered | Signals re-emitted by BoardController |
| TR-game-feel-vfx-002 | game-feel-vfx.md | VFX | ≤6 particle systems, ≤600 particles; priority eviction of oldest lowest-priority | — | ❌ Gap | "Presentation Feedback Pipeline (VFX budget, haptics, camera punch)" (Presentation, MEDIUM) |
| TR-game-feel-vfx-003 | game-feel-vfx.md | Performance | VFX ≤2 ms GPU + 0.5 ms CPU per frame | ADR-0007 §7 | ⚠️ Partial | ADR-0007 budgets blocks only; VFX not in the budget table |
| TR-game-feel-vfx-004 | game-feel-vfx.md | Camera | Translation-only camera punch/shake API, ≤6 px | ADR-0007 §3 (ortho fixed size) | ⚠️ Partial | Punch API and owner undefined |
| TR-game-feel-vfx-005 | game-feel-vfx.md | Accessibility | Global reduced-motion/haptics flags swap variants; gameplay timing unchanged | ADR-0001 (sim never waits on view) | ⚠️ Partial | Timing independence covered; settings source/propagation undefined (needs save ADR) |
| TR-game-feel-vfx-006 | game-feel-vfx.md | Haptics | Haptic patterns, off by setting, rate-limited to 1 per 50 ms | — | ❌ Gap | Same presentation ADR; MEDIUM (`Input.vibrate_handheld` amplitude/iOS behaviour to verify) |
| TR-game-feel-vfx-007 | game-feel-vfx.md | Platform | Detect device low-power mode and halve particles | — | ❌ Gap | HIGH: no confirmed 4.7 API (see revision flag) |
| TR-game-feel-vfx-008 | game-feel-vfx.md | VFX | Split-screen: separate VFX budget per half | — | ❌ Gap | Depends on split-screen ADR (see TR-local-multiplayer-setup-007) |
| TR-menus-level-select-001 | menus-level-select.md | App flow | Screen state machine Title→Profile→Main→Map→Select→Intro→Play, overlays return below | implementation-plan `AppFlow` (not an ADR) | ⚠️ Partial | Suggest "App Flow & Scene Management" (Core, LOW) |
| TR-menus-level-select-002 | menus-level-select.md | Platform | Android system Back returns exactly one screen | — | ❌ Gap | Fold into App Flow ADR; LOW (`NOTIFICATION_WM_GO_BACK_REQUEST`, `quit_on_go_back`) |
| TR-menus-level-select-003 | menus-level-select.md | App flow | App resumed mid-level shows pause menu | ADR-0001 (backgrounding stops ticking), ADR-0009 §7 | ⚠️ Partial | Sim freeze covered; UI routing on resume not specified |
| TR-menus-level-select-004 | menus-level-select.md | Persistence | Continue/map read progress, stars, unlocks per profile | — | ❌ Gap | Needs Save & Profile ADR |
| TR-menus-level-select-005 | menus-level-select.md | Data | Level order from biome data; Draft/missing levels hidden | ADR-0005 Formats (biomes JSON), GDD table (Draft→Valid→Locked) | ✅ Covered |  |
| TR-menus-level-select-006 | menus-level-select.md | Persistence | Settings screen persists controls/display/audio settings | — | ❌ Gap | Needs Save & Profile ADR |
| TR-menus-level-select-007 | menus-level-select.md | Performance | Launch to playing ≤10 s on returning profile | ADR-0005 Loader, ADR-0007 §6 | ⚠️ Partial | No load-time budget (boot, catalog, PluginRegistry scan, preview bake) |
| TR-menus-level-select-008 | menus-level-select.md | Multiplayer | Show "Join" for an in-progress LAN lobby | ADR-0009 §3 beacons | ✅ Covered |  |
| TR-campaign-structure-001 | campaign-structure.md | Data | Ordered biomes; tiers 1–10, bonus 11, hard-track 12+ | ADR-0005 Level file (`biome`, `tier`), biomes JSON | ✅ Covered |  |
| TR-campaign-structure-002 | campaign-structure.md | Progression | Level/biome unlock state machine with star gates | — (implementation-plan `ProfileStore`) | ❌ Gap | "Save & Profile Persistence" (Persistence, MEDIUM) |
| TR-campaign-structure-003 | campaign-structure.md | Data | Computed default g0(b,t) when level omits g0 | ADR-0004 §3 knob resolution | ⚠️ Partial | Resolution chain is level → static base; no computed/biome-tier default layer |
| TR-campaign-structure-004 | campaign-structure.md | Persistence | Edited/re-versioned level keeps its earned stars | ADR-0005 (`level_hash` identity) | ⚠️ Partial | Conflict with hash-keyed records (revision flag) |
| TR-campaign-structure-005 | campaign-structure.md | Progression | Campaign-met twists/Specials feed Arcade and Randomizer pools | — | ❌ Gap | Unlock pools in Save ADR; cross-system read contract |
| TR-campaign-structure-006 | campaign-structure.md | Rules | Per-level failure config (warnings_max, top-out rule, fixed_list) | ADR-0004 §4 slots, ADR-0005 `knobs` | ✅ Covered |  |
| TR-campaign-structure-007 | campaign-structure.md | Presentation | Finale boss/mascot performs twist telegraphs from events | ADR-0001 events, ADR-0005 level scenes (mascot spots, skits) | ✅ Covered |  |
| TR-arcade-mode-001 | arcade-mode.md | Goals | `endless` goal: no win, run ends on loss | ADR-0004 §1 `GoalEvaluator` slot | ✅ Covered | New plugin only |
| TR-arcade-mode-002 | arcade-mode.md | Fall | Speed ramps with layers cleared, capped | ADR-0004 §3 knob modifiers (fixed-point) | ✅ Covered |  |
| TR-arcade-mode-003 | arcade-mode.md | Rule-Twist | Redraw active twist set mid-run every N layers; apply at next Resolving after 2 s | ADR-0004 §4, §8 | ⚠️ Partial | Lifetimes/Resolving swap covered; no "rule director" that starts/ends rules at runtime |
| TR-arcade-mode-004 | arcade-mode.md | RNG | Dedicated Arcade random stream for redraws | ADR-0006 Streams | ⚠️ Partial | No `arcade` stream in the table; add `["arcade", draw_n]` |
| TR-arcade-mode-005 | arcade-mode.md | Spawner | Piece set grows mid-run within 8-shape limit and validator rules | ADR-0006 bag streams, ADR-0005 validator | ⚠️ Partial | Runtime piece-set mutation and runtime validation not addressed (validator is load-time) |
| TR-arcade-mode-006 | arcade-mode.md | Persistence | Best score per biome skin saved | — | ❌ Gap | Save ADR |
| TR-arcade-mode-007 | arcade-mode.md | Timing | Pause freezes run and rotation timers | ADR-0001 clock, ADR-0004 §8 | ✅ Covered |  |
| TR-physics-mode-001 | physics-mode.md | Physics | Rigid body per piece from cube offsets; mass ∝ cubes; friction/bounce | ADR-0003 (offsets), ADR-0001 Exceptions | ⚠️ Partial | Compound shape/PhysicsMaterial/Jolt config undecided |
| TR-physics-mode-002 | physics-mode.md | Physics | Controlled cell-step descent, then release to full physics on contact | — | ❌ Gap | "Physics Mode on Jolt" (Physics, HIGH: kinematic→rigid switch, freeze modes) |
| TR-physics-mode-003 | physics-mode.md | Physics | Settle detection (speed/spin below threshold for 400 ms); force-settle at 3 s | — | ❌ Gap | Same ADR; MEDIUM (which tick: 60 Hz sim vs physics tick) |
| TR-physics-mode-004 | physics-mode.md | Performance | Freeze pieces below freeze_depth; ≤40 active bodies; unfreeze on impact | — | ❌ Gap | Same ADR; HIGH (Jolt sleep/freeze behaviour) |
| TR-physics-mode-005 | physics-mode.md | Performance | Auto-shrink freeze depth when fps < 50 | — | ❌ Gap | Runtime perf governor; MEDIUM |
| TR-physics-mode-006 | physics-mode.md | Sim contract | Same SimCommand/SimEvent contract; non-determinism accepted | ADR-0001 Exceptions, ADR-0004 `board.kind` | ✅ Covered |  |
| TR-physics-mode-007 | physics-mode.md | Rendering | Frozen pieces drawn cheaply | ADR-0007 §2 | ⚠️ Partial | Explicitly deferred "until Physics Mode is built" |
| TR-physics-mode-008 | physics-mode.md | Physics | Variant props: hinged seesaw, moving platform, sticky contact, meteors, bell trigger | — | ❌ Gap | Same ADR; HIGH (Jolt joint differences, see flags) |
| TR-physics-mode-009 | physics-mode.md | Performance | 60 fps with 30-piece tower on reference phone | — | ❌ Gap | Physics budget missing from ADR-0007/0008 |
| TR-mode-minigame-randomizer-001 | mode-minigame-randomizer.md | Data | Round templates = Level Data tagged versus/minigame with mode, weight, standing_metric | ADR-0005 Formats (minigame JSON) | ⚠️ Partial | Level schema lacks `tags`/`mode`/`weight`; unknown keys are errors |
| TR-mode-minigame-randomizer-002 | mode-minigame-randomizer.md | RNG | Weighted pick, no previous mode, no-recent-repeat, category share | ADR-0006 Rules (weighted pick), Streams (`round`) | ✅ Covered | Integer-weight caveat (flag) |
| TR-mode-minigame-randomizer-003 | mode-minigame-randomizer.md | Multiplayer | Same picks on every device; host's pick wins | ADR-0009 §1, §4 `round_setup` | ✅ Covered |  |
| TR-mode-minigame-randomizer-004 | mode-minigame-randomizer.md | Data | Pool from host's unlocks; all devices hold the content | ADR-0009 §2 `content_hash` | ⚠️ Partial | Content parity covered; unlock source needs Save ADR |
| TR-mode-minigame-randomizer-005 | mode-minigame-randomizer.md | Rule-Twist | Twist draw excludes incompatible pairs and mechanic conflicts | ADR-0004 §2 (`incompatible_with`, atom tags), ADR-0005 Validator | ✅ Covered |  |
| TR-mode-minigame-randomizer-006 | mode-minigame-randomizer.md | Multiplayer | Trailing player's re-roll window, host-authoritative | ADR-0009 §4 | ⚠️ Partial | No `reroll` request message in the table (append-only addition) |
| TR-mode-minigame-randomizer-007 | mode-minigame-randomizer.md | Items | Per-template standing metric for item rolls | ADR-0004 §1 `StandingFn`, ADR-0009 §4 | ✅ Covered |  |
| TR-tournament-flow-001 | tournament-flow.md | Tournament | Host state machine: setup → rounds → sudden death → result | ADR-0009 §1 `TournamentHost` | ✅ Covered |  |
| TR-tournament-flow-002 | tournament-flow.md | RNG | Per-round seeds from tournament seed | ADR-0006 round_seed sources | ✅ Covered |  |
| TR-tournament-flow-003 | tournament-flow.md | Multiplayer | Synchronized countdown and round start | ADR-0009 §5 | ✅ Covered |  |
| TR-tournament-flow-004 | tournament-flow.md | Tournament | Time-cap winner by goal progress, then score | ADR-0009 §4 `progress`, §5 | ✅ Covered |  |
| TR-tournament-flow-005 | tournament-flow.md | Multiplayer | Between-round standings end on timeout or all-ready | ADR-0009 §4 | ⚠️ Partial | No `ready` message defined |
| TR-tournament-flow-006 | tournament-flow.md | Multiplayer | Disconnect = out for round, rejoin next; host leave ends tournament | ADR-0009 §7 | ✅ Covered |  |
| TR-tournament-flow-007 | tournament-flow.md | Multiplayer | Pause pauses all players | ADR-0009 §4 `pause`/`resume` | ✅ Covered |  |
| TR-tournament-flow-008 | tournament-flow.md | Persistence | Tournament results/stats saved to profile | — | ❌ Gap | Save ADR |
| TR-tournament-minigames-001 | tournament-minigames.md | Minigames | Contract: template declares slots, goal_evaluator, standing_metric, hook, t_mg, item whitelist | ADR-0004 §9, ADR-0005 minigame JSON | ⚠️ Partial | ADR leaves minigames unconstrained; contract fields and slot names mismatch (flag) |
| TR-tournament-minigames-002 | tournament-minigames.md | Scenes | Minigame = own scene with fixed-tick loop reusing core libs | ADR-0001 Exceptions, ADR-0004 §9 | ✅ Covered |  |
| TR-tournament-minigames-003 | tournament-minigames.md | RNG | Same round seed → identical walls/models/golden-piece times/lanes everywhere | ADR-0006 `["minigame", id]` | ✅ Covered |  |
| TR-tournament-minigames-004 | tournament-minigames.md | Multiplayer | Send/Steal routed via host; target leader (leader hits 2nd) | ADR-0009 §4 `mg_event`, `route()`, debuff targeting | ✅ Covered |  |
| TR-tournament-minigames-005 | tournament-minigames.md | Multiplayer | Host-owned shared objects decided by host-received time | ADR-0009 §4 shared-object profile | ✅ Covered |  |
| TR-tournament-minigames-006 | tournament-minigames.md | Multiplayer | Telegraph ≥ attack_warn_ms before effect acts; applies exactly once | ADR-0009 §6 | ⚠️ Partial | ADR applies on arrival; delayed-apply and `instance_id` dedupe not stated |
| TR-tournament-minigames-007 | tournament-minigames.md | Multiplayer | Sends to a lagging device queue at host, apply on reconnect | ADR-0009 §7 | ⚠️ Partial | Lagging state exists; host-side queue unspecified |
| TR-tournament-minigames-008 | tournament-minigames.md | Multiplayer | Eliminated ghosts keep sending on a timer | ADR-0009 §4 `player_out` | ⚠️ Partial | Whether out seats may send is unspecified |
| TR-tournament-minigames-009 | tournament-minigames.md | Physics | MG5 Crane Tower runs on Physics Mode core | — | ❌ Gap | Blocked by Physics Mode ADR (GDD has grid-crane fallback) |
| TR-tournament-minigames-010 | tournament-minigames.md | Effects | Lasting sends implemented as Buffs & Debuffs effect ids | ADR-0004 rules, ADR-0009 `apply_effect` | ✅ Covered |  |
| TR-local-multiplayer-setup-001 | local-multiplayer-setup.md | Network | LAN host/join with nearby-host list | ADR-0009 §2, §3 | ✅ Covered |  |
| TR-local-multiplayer-setup-002 | local-multiplayer-setup.md | Sim | Each device simulates only its own board; no lockstep | ADR-0001, ADR-0009 §1 | ✅ Covered |  |
| TR-local-multiplayer-setup-003 | local-multiplayer-setup.md | Network | Host authoritative: settings, seed, picks, start, results, pause | ADR-0009 §1 | ✅ Covered |  |
| TR-local-multiplayer-setup-004 | local-multiplayer-setup.md | Network | Progress at sync_hz; events as they happen | ADR-0009 §4, §8 | ✅ Covered |  |
| TR-local-multiplayer-setup-005 | local-multiplayer-setup.md | Network | Attacks applied on arrival, never rolled back; ties by sender clock then arrival | ADR-0009 §5, §6 | ✅ Covered |  |
| TR-local-multiplayer-setup-006 | local-multiplayer-setup.md | Network | Connected/Lagging/Disconnected with timeouts | ADR-0009 §7 | ✅ Covered |  |
| TR-local-multiplayer-setup-007 | local-multiplayer-setup.md | Rendering | Shared tablet: two boards/cameras/HUDs on one device, one rotated 180°, landscape lock | — | ❌ Gap | "Shared-Device Split Screen" (Presentation, MEDIUM: 2 viewports on Mobile renderer doubles ADR-0007 vertex budget) |
| TR-local-multiplayer-setup-008 | local-multiplayer-setup.md | Input | Route touches by starting half; per-half control orientation | — | ❌ Gap | Same ADR / input ADR; MEDIUM (multi-touch index ownership) |
| TR-local-multiplayer-setup-009 | local-multiplayer-setup.md | Rendering | Split cube-size check (F1 ≥ 20 px) hides option per device/board | — | ❌ Gap | Same ADR; LOW |
| TR-local-multiplayer-setup-010 | local-multiplayer-setup.md | Network | Opponent mini-boards from progress updates | ADR-0009 §4 `progress` (col_heights, danger) | ✅ Covered | Mini-board view itself not in ADR-0007 (minor) |
| TR-save-profile-001 | save-profile.md | Persistence | Save schema: ≤4 profiles, level records, unlocks, settings, stats | — | ❌ Gap | "Save & Profile Persistence" (Persistence, MEDIUM: `FileAccess.store_*` return bool since 4.4) |
| TR-save-profile-002 | save-profile.md | Persistence | Atomic temp-then-replace write; backup fallback on corrupt main | — | ❌ Gap | Same ADR; MEDIUM (rename semantics on Android `user://`) |
| TR-save-profile-003 | save-profile.md | Persistence | Schema versions migrated on load, never discarded | ADR-0005 (`LevelMigrations` pattern) | ⚠️ Partial | Pattern exists for levels only |
| TR-save-profile-004 | save-profile.md | Persistence | Save on result/settings/unlock only, never during play, within 1 s | — | ❌ Gap | Same ADR |
| TR-save-profile-005 | save-profile.md | Platform | Cloud sync via iCloud / Google Play saved games; throttled; on background | — | ❌ Gap | "Cloud Save Integration" (Platform, HIGH: no built-in Godot API, native plugins vs ADR-0008) |
| TR-save-profile-006 | save-profile.md | Persistence | Conflict merge: best-of records, union unlocks, newest settings | — | ❌ Gap | Same Save ADR; LOW (pure logic) |
| TR-save-profile-007 | save-profile.md | Persistence | Offline play and saving work; sync retries later | — | ❌ Gap | Same Save/Cloud ADR |
| TR-save-profile-008 | save-profile.md | Multiplayer | Guest players play with no profile; nothing saved | ADR-0009 §1 lobby seats | ⚠️ Partial | Seat ↔ profile linkage unspecified |

## Known Gaps

- ❌ TR-level-goals-fail-states-003 (level-goals-fail-states.md): Level flow Intro→Countdown→Playing→Warning→Won/Lost/Out, Paused; results fan out — **Gap: Level Flow & App Lifecycle State Machine** (Core/Scripting, MEDIUM). Also decides on the untracked `godot_state_charts` addon
- ❌ TR-camera-rotate-view-006 (camera-rotate-view.md): Portrait and landscape; turning mid-level pauses, re-lays out, reframes, keeps yaw step — **Gap: Screen Orientation, Safe Area & Layout Profiles** (Platform/UI, MEDIUM: Android sensor orientation, DisplayServer safe area)
- ❌ TR-touch-controls-003 (touch-controls.md): Gesture classification, multi-touch zones, zone ownership, board-area exclusion, mirror, haptics — **Gap: Touch Input Pipeline (InputEvent → SimCommand)** (Input/Platform, MEDIUM: 4.6 dual-focus, 4.7 VirtualJoystick, Android vibrate permission)
- ❌ TR-touch-controls-005 (touch-controls.md): Backgrounding or phone call: pause at once, cancel touches, buffer nothing across pause — Covered by gap **Level Flow & App Lifecycle State Machine**
- ❌ TR-touch-controls-007 (touch-controls.md): Player settings persist: scheme, mirror, one-handed, sensitivities, haptics, scale, reduced motion — **Gap: Save, Profile & Settings Persistence** (Core/Persistence, LOW–MEDIUM: 4.4 FileAccess return types)
- ❌ TR-hud-003 (hud.md): Safe-area layout; never overlaps the board rect at 12 yaws; mirror and 150% scale variants — Covered by gap **Screen Orientation, Safe Area & Layout Profiles**
- ❌ TR-scoring-stars-003 (scoring-stars.md): Best result per level persisted, never lost; old stars kept and marked on level version change — **Gap: Save, Profile & Settings Persistence** (Core/Persistence, LOW–MEDIUM)
- ❌ TR-mechanics-module-007 (mechanics-module.md): Undo last N locks on own or rival board (IN19, SP17), never across a clear — ADR: "Board history, undo and rewind" · Core · LOW. ADR-0001 lock veto covers WO11 only (before write)
- ❌ TR-mechanics-module-008 (mechanics-module.md): Gravity steps, sweep and on-beat lock follow music BPM (EV08, CL10, SC11) — ADR: "Music beat clock vs. sim clock" · Audio/Core · MEDIUM (Android audio latency; must stay deterministic)
- ❌ TR-mechanics-module-010 (mechanics-module.md): Secret collection flags, cosmetics and hidden-level unlocks persist in Save & Profile — ADR: "Save & Profile persistence" · Persistence · LOW (`FileAccess.store_*` return bool since 4.4)
- ❌ TR-mechanics-module-012 (mechanics-module.md): Gameplay depends on camera snap (SE05 angle gems, tap on 3D object) — ADR: "Camera rig, snap constraints and 3D picking" · Camera/Input · MEDIUM (GUIDE and Phantom Camera enabled in project.godot without an ADR)
- ❌ TR-game-concept-004 (game-concept.md): Physics modes must perform on mobile hardware — "Physics Mode on Jolt" (Physics, HIGH)
- ❌ TR-game-concept-008 (game-concept.md): Per-biome music plus layer-clear / item SFX driven by events — "Audio Architecture: buses, event→cue map, music streaming" (Audio, MEDIUM: 4.7 `AudioStreamPlayer.area_mask` default change)
- ❌ TR-game-feel-vfx-002 (game-feel-vfx.md): ≤6 particle systems, ≤600 particles; priority eviction of oldest lowest-priority — "Presentation Feedback Pipeline (VFX budget, haptics, camera punch)" (Presentation, MEDIUM)
- ❌ TR-game-feel-vfx-006 (game-feel-vfx.md): Haptic patterns, off by setting, rate-limited to 1 per 50 ms — Same presentation ADR; MEDIUM (`Input.vibrate_handheld` amplitude/iOS behaviour to verify)
- ❌ TR-game-feel-vfx-007 (game-feel-vfx.md): Detect device low-power mode and halve particles — HIGH: no confirmed 4.7 API (see revision flag)
- ❌ TR-game-feel-vfx-008 (game-feel-vfx.md): Split-screen: separate VFX budget per half — Depends on split-screen ADR (see TR-local-multiplayer-setup-007)
- ❌ TR-menus-level-select-002 (menus-level-select.md): Android system Back returns exactly one screen — Fold into App Flow ADR; LOW (`NOTIFICATION_WM_GO_BACK_REQUEST`, `quit_on_go_back`)
- ❌ TR-menus-level-select-004 (menus-level-select.md): Continue/map read progress, stars, unlocks per profile — Needs Save & Profile ADR
- ❌ TR-menus-level-select-006 (menus-level-select.md): Settings screen persists controls/display/audio settings — Needs Save & Profile ADR
- ❌ TR-campaign-structure-002 (campaign-structure.md): Level/biome unlock state machine with star gates — "Save & Profile Persistence" (Persistence, MEDIUM)
- ❌ TR-campaign-structure-005 (campaign-structure.md): Campaign-met twists/Specials feed Arcade and Randomizer pools — Unlock pools in Save ADR; cross-system read contract
- ❌ TR-arcade-mode-006 (arcade-mode.md): Best score per biome skin saved — Save ADR
- ❌ TR-physics-mode-002 (physics-mode.md): Controlled cell-step descent, then release to full physics on contact — "Physics Mode on Jolt" (Physics, HIGH: kinematic→rigid switch, freeze modes)
- ❌ TR-physics-mode-003 (physics-mode.md): Settle detection (speed/spin below threshold for 400 ms); force-settle at 3 s — Same ADR; MEDIUM (which tick: 60 Hz sim vs physics tick)
- ❌ TR-physics-mode-004 (physics-mode.md): Freeze pieces below freeze_depth; ≤40 active bodies; unfreeze on impact — Same ADR; HIGH (Jolt sleep/freeze behaviour)
- ❌ TR-physics-mode-005 (physics-mode.md): Auto-shrink freeze depth when fps < 50 — Runtime perf governor; MEDIUM
- ❌ TR-physics-mode-008 (physics-mode.md): Variant props: hinged seesaw, moving platform, sticky contact, meteors, bell trigger — Same ADR; HIGH (Jolt joint differences, see flags)
- ❌ TR-physics-mode-009 (physics-mode.md): 60 fps with 30-piece tower on reference phone — Physics budget missing from ADR-0007/0008
- ❌ TR-tournament-flow-008 (tournament-flow.md): Tournament results/stats saved to profile — Save ADR
- ❌ TR-tournament-minigames-009 (tournament-minigames.md): MG5 Crane Tower runs on Physics Mode core — Blocked by Physics Mode ADR (GDD has grid-crane fallback)
- ❌ TR-local-multiplayer-setup-007 (local-multiplayer-setup.md): Shared tablet: two boards/cameras/HUDs on one device, one rotated 180°, landscape lock — "Shared-Device Split Screen" (Presentation, MEDIUM: 2 viewports on Mobile renderer doubles ADR-0007 vertex budget)
- ❌ TR-local-multiplayer-setup-008 (local-multiplayer-setup.md): Route touches by starting half; per-half control orientation — Same ADR / input ADR; MEDIUM (multi-touch index ownership)
- ❌ TR-local-multiplayer-setup-009 (local-multiplayer-setup.md): Split cube-size check (F1 ≥ 20 px) hides option per device/board — Same ADR; LOW
- ❌ TR-save-profile-001 (save-profile.md): Save schema: ≤4 profiles, level records, unlocks, settings, stats — "Save & Profile Persistence" (Persistence, MEDIUM: `FileAccess.store_*` return bool since 4.4)
- ❌ TR-save-profile-002 (save-profile.md): Atomic temp-then-replace write; backup fallback on corrupt main — Same ADR; MEDIUM (rename semantics on Android `user://`)
- ❌ TR-save-profile-004 (save-profile.md): Save on result/settings/unlock only, never during play, within 1 s — Same ADR
- ❌ TR-save-profile-005 (save-profile.md): Cloud sync via iCloud / Google Play saved games; throttled; on background — "Cloud Save Integration" (Platform, HIGH: no built-in Godot API, native plugins vs ADR-0008)
- ❌ TR-save-profile-006 (save-profile.md): Conflict merge: best-of records, union unlocks, newest settings — Same Save ADR; LOW (pure logic)
- ❌ TR-save-profile-007 (save-profile.md): Offline play and saving work; sync retries later — Same Save/Cloud ADR

## Superseded Requirements

None (first review).
