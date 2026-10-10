# Core-Loop Rules Audit: Coder-Readiness

> **Author**: game-designer (orchestrated run) · **Date**: 2026-10-10
> **Scope**: board-grid, piece-set, piece-spawner-queue, movement-rotation, fall-drop-lock, layer-clearing, level-goals-fail-states, scoring-stars, camera-rotate-view, touch-controls, hud, rule-twist-framework, game-feel-vfx (all read in full); systems-index and game-concept skimmed. I also checked `design/levels/meadow.md` (meadow_01), ADR-0001 (tick order), ADR-0003 (pivot), the implementation plan and `assets/data/knobs/*.json`, so I don't re-ask anything those already settle.
> **No GDD was edited.** Every proposed answer is a **flexible default** with a named knob. The user or the owning designer confirms them, and then they get folded into the GDDs.

## Target: first playable = meadow_01 "First Sprout"

From `design/levels/meadow.md`: a 4 × 4 board with H_play 8, using pieces I, O, T, L, S (`opening_set` {O, I}, count 2). Only spin is enabled (CV02). Goal: Clear 4. `topout_rule` rescue with `warnings_max` 2. g0 0.6, `T_level` 180, stars 145 / 105 s. L_max is 4 (from I), so C = 4 and board_height = 12. Pip's catch (WO11) and the duck (SE05) are deferred, as the implementation plan already says.

## Already settled elsewhere (do not re-ask)

- **Tick model** (ADR-0001). A fixed 60 Hz sim with integer ms. Commands apply at the start of the next tick, in arrival order. The `step()` order is: commands → `on_tick` → gravity/travel → lock → resolve → goal.
- **Resolving length comes from data** (ADR-0001). The sim never waits for animations, and `t_resolve` comes from Layer Clearing F2.
- **Input scheme for first playable.** Scheme A buttons plus a keyboard for dev (INP-001).
- **Spawner opening and fixed list**, and **lock veto for WO11**, are covered in the implementation plan.

## Legend

- **BFP** = BLOCKING-FIRST-PLAYABLE (meadow_01 cannot be built without guessing)
- **BL** = BLOCKING-LATER (a later Meadow level or mode needs it)
- **MIN** = MINOR (wording, stale example, or a coder can proceed safely)

---

## 1. Board / Grid (`board-grid.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| B1 | **BFP** | (not specified anywhere) | How do cell coordinates map to world space? The view, camera framing, ghost and kicks all need this. | 1 cell = 1 world unit. The board node's origin is the footprint centre at floor level. Cell `(x,y,z)` has its centre at world `(x − W/2 + 0.5, y + 0.5, z − D/2 + 0.5)`. Tiles sit below y = 0 (1/5 cube thick, art only). Knob: none (convention). Record it in ADR-0002 or ADR-0007. |
| B2 | MIN | Summary, Overview, Game Feel | These sections say the default is 8 × 8 × 12. Formulas and AC 1 say 6 × 6, H_play 10, C 4 (14 drawn). | **Formulas and AC 1 win.** `board.json` defaults are 6 / 6 / 10, C = L_max. meadow_01 overrides to 4 × 4 × 8 anyway. |
| B3 | MIN | Rule 11a | Spawn anchor on even footprints: what does "lower cell on ties" mean? | For an even side n, the anchor index is `n/2 − 1` (4 × 4 → (1,1)). Already in BRD-001; confirm. |
| B4 | MIN | Open Q "20 px floor" | Are pixels device px or logical points? | Device px (the F5 math is in device px at 2532 × 1170). meadow_01 is far above the floor (4 × 4, H 12 → about 40 px). |
| B5 | BL | Edge "down axis changes" | Re-indexing for ±x / ±z is described only by analogy. | Layer index along `d` = distance from the floor face of that axis. ADR-0002 already parameterises all 6 axes; no design change needed. |
| B6 | MIN | AC 2–8 | These use an "8 × 8 test board". That is fine because it is explicit. | Keep. |

## 2. Piece Set (`piece-set.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| P1 | **BFP** | Rule 1, rule 9, library table, ADR-0003 | **Which cube is the pivot?** The table puts the pivot at (0,0,0), which is the *end* of I and a *corner* of O/T/L/S. Spinning around those cubes swings I around its tip and makes O shift one cell per spin. ADR-0003 takes the pivot from whichever Blender empty the artist chose. | The pivot cube is the cube nearest the bounding-box centre of the spawn orientation. Ties go to the lowest y, then x, then z. For I that is offset 1, and for T it is the middle of the bar. Store it as `pivot_index` per shape in the shape bank (hand field, overridable). Movement's Open Question "pivot feel" becomes this knob. |
| P2 | **BFP** | Rule 9, Movement rule 13 | O under spin: does it move? | **No-drift rule:** if a rotation lands in the same *distinct* orientation (`distinct_of` unchanged), the cells stay exactly where they are. The result is still `Ok` and still counts as a rotation (feedback plays, and it uses a lock reset per FDL edge case). This covers O spin, Big Cube and Mono. Knob: none. |
| P3 | **BFP** | Rule 10 + Spawner 8a | How is the spawn orientation chosen? Piece Set says "smallest extent up, first listed wins ties". The Spawner adds "long axis along x". Neither says which mirror-equivalent pose wins (for example T's bump toward +z or −z). | Filter the 24 orientations in ADR-0003 BFS order. Keep those whose y extent is the smallest. Of those, keep the ones whose x extent ≥ z extent. Take the lowest index. That gives a deterministic pose, and art can override it with a hand field `spawn_orient`. Example: T is flat, its bar is along x, and the bump goes to whichever side BFS gives first. |
| P4 | MIN | Game Feel, Open Q | "~28 px on the default 8 × 8" is stale. | Ignore it; Board F5 governs. |
| P5 | MIN | Visual/Audio | The per-shape hue table (legacy) and the per-family hue table conflict. | **Family hue** (the 2026-10-09 decision) wins. Colour is derived from the art set and never stored (Board rule 6). |

## 3. Piece Spawner & Queue (`piece-spawner-queue.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| S1 | **BFP** | Rule 8 | Is the spawn position tied to world axes or to the current camera yaw? | **World:** the long axis is along world x at every yaw. That keeps it deterministic and replayable, and the rotate-view reframes the view anyway. Revisit after playtest (`spawn.align_to_view`, default false, no code until needed). |
| S2 | **BFP** | Rule 8 / 8a | Spawn height: what does "lowest cube at layer H_play" mean for meadow_01? | The lowest cube is at y = 8, and the box is centred on anchor (1,1) with the lower cell on even sides. I covers x 0–3. O covers x 1–2, z 1–2. |
| S3 | **BFP** | Rule 1, 13 | Where does the seed come from in single-player campaign play? | `round_seed` comes from Seeds (ADR-0006), freshly generated at each level start *and each retry*. Debug replay stores it. Knob: `spawn.fixed_seed` (dev only, default none). |
| S4 | MIN | Rule 5a | `opening_count` = 2 with set {O, I}. Is it O then I, or I then O, at random? | It is random: the bag of {O, I} is shuffled (as the rule already says). Confirmed. |
| S5 | MIN | AC 19b | This criterion assumes "default 8 × 8 board". | Read it as the default board; the criterion is unchanged. |
| S6 | BL | Open Q | Do injected pieces count toward the preview? | They take preview slot 1 and push the others down. No separate marker until Items. |
| S7 | MIN | Open Q | Should the first piece avoid big Specials? | Not relevant for meadow_01 (`opening_set`). |

## 4. Movement & Rotation (`movement-rotation.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| M1 | **BFP** | Rule 9, Touch rule 3 | **Sign of spin.** Which `rotate(y, ±1)` is "spin right"? | **Spin right = clockwise seen from above = `rotate(y, −1)`.** (By F1, `R_y(+90)` sends +x to −z, which is counter-clockwise from above.) Spin left = `rotate(y, +1)`. Knob: `control.invert_spin` (accessibility, default false). |
| M2 | BL | Rule 9 | Signs of tilt and roll. | **Tilt away** (top moves away from camera) = −90° about the world direction that the camera map gives for *screen-right*. Tilt toward = +90°. **Roll right** (top moves screen-right) = −90° about the world direction mapped to *screen-down* (toward the camera). Roll left = +90°. Needed for meadow_02. |
| M3 | **BFP** | Rule 12, F2 | Kick "up" is written as `(0,+1,0)`, but "up" also means against the down axis. | Up = −down (already implied). It is `(0,+1,0)` under default gravity. |
| M4 | **BFP** | F2 | Is the kick-order centre `(cx,cz)` measured in cell indices or cell centres? | Cell indices: `cx = (W − 1)/2`, `cz = (D − 1)/2` (so (1.5, 1.5) on 4 × 4). Compare against the candidate **pivot** index. The ties order +x, −x, +z, −z stands. |
| M5 | MIN | Rule 12 | Does an up-kick count against the budget even if the piece later falls back down? | Yes. The counter only goes up for that piece. |
| M6 | MIN | AC defaults | These use an 8 × 8 × 16 test board. | Fine because it is explicit. |
| M7 | BL | Rule 18 `supported` | Do moves in the air count as "resting"? | Rule 18 applies only while F4 says resting = true. Not used in Meadow. |

## 5. Fall, Drop & Lock (`fall-drop-lock.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| F1 | **BFP** | Rule 3 vs rule 9 vs State table | **When does the lock timer start?** Rule 3 and the state table say "when a fall step is *blocked*" (one gravity interval after landing; 1.67 s late at g 0.6). Rule 9 says "every time the piece comes to rest" (immediately). | **Rule 9 wins.** At the end of every tick, after commands and the gravity step, recompute `resting` (Movement F4). On a false → true change, set `lock_deadline = now + lock_delay_ms`. While resting, gravity steps are not attempted. On true → false, clear the deadline and restart the gravity clock from 0. |
| F2 | **BFP** | ADR-0001 step order + rules 7–10 | What is the order inside one tick? | 1) Apply commands in order. Successful move/rotate while resting resets the deadline and uses a reset. Hard drop moves to the target and starts grace. 2) `on_tick`. 3) Gravity: if not resting and `now ≥ next_step`, do **one** step. 4) Recompute resting and timers (F1). 5) Lock if `now ≥ lock_deadline`, or `now ≥ grace_deadline` while resting, or a commit happened. 6) Run the per-lock sequence. At most one fall step per tick: effective `g` is capped at `SIM_HZ` (60 cells/s ≥ every range). |
| F3 | **BFP** | Rule 1a | What happens to the gravity clock when a piece rests and then becomes airborne again? | It resets to 0 at the moment it becomes airborne, so the next step comes after one full interval. Soft drop still keeps elapsed time (rule 1a). |
| F4 | **BFP** | Rule 7 | Does a move or rotation during grace use a lock reset or restart grace? | Neither. The grace deadline is fixed when the hard drop happens. If the piece leaves grace unsupported, it goes back to Falling, and the next rest starts a normal lock timer with the resets it has left. |
| F5 | **BFP** | Rule 8 | Hard drop while Resting (lock timer running): which deadline applies? | Grace replaces the lock timer: `grace_deadline = now + hard_drop_grace_ms`, and the lock timer is cleared. |
| F6 | **BFP** | Rule 11 | What is the initial "lowest layer reached"? | The spawn position's lowest-cube layer. Each step to a new minimum restores `lock_resets_max`. |
| F7 | **BFP** | Rule 15 step 8–9 | Rescue timing: how long does the Warning phase last? Does it come before or replace the entry delay? | New knob `goal.warning_ms` (count, 600–1500, default **1200**). Order: rescue wipe is logically instant → Warning phase lasts `warning_ms` (clock stopped, input disabled, no Waiting buffer) → entry delay → spawn. The Game Feel target is ≤ 1.5 s. |
| F8 | MIN | F2 example | "lowest cube at layer 12" doesn't fit the default H_play 10. | Illustrative only. |
| F9 | MIN | Rule 2 `minutes` | Is it play time? | Yes: level-clock minutes (Level Goals rule 13), so Warning and pause don't count. |
| F10 | MIN | Rule 9 / 12 | Stall loop: an up-kick makes the piece unsupported, it rests again, and the timer is full again. | Bounded by `max_up_kicks_per_piece` (2) and by each rotation using a reset. No change. |
| F11 | MIN | Rule 6 / Touch | Does hard drop with soft drop held conflict? | No: hard drop acts and soft drop stays on until the finger lifts (and is cleared at spawn). |

## 6. Layer Clearing (`layer-clearing.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| L1 | **BFP** | F2 + rule 13 | Does `t_resolve` include the settle term when nothing sits above the cleared layers? | Drop `clear_settle_ms` when no content is above the highest cleared layer (the rule already says so; AC 9 confirms it). meadow_01 single clear = 250 + 200 = 450 ms. |
| L2 | **BFP** | Rule 11 + FDL F1 | Does the gravity ramp `layers_cleared` count chain rounds and non-layer detectors? | Yes, all logical clears. Rescue wipes and trims never count. |
| L3 | MIN | F3 example | Says "default 8 × 8". | Stale; formula unchanged. |
| L4 | BL | Rule 4 | For non-layer detectors, the unit of a "clear" is per mechanic. | Defined per mechanic GDD (M5–M8). Not Meadow-1. |
| L5 | MIN | Edge "settle skipped" | Is the settle term computed per round? | Yes. |

## 7. Level Goals & Fail States (`level-goals-fail-states.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| G1 | **BFP** | Rule 12, State table | **How long is the Intro?** "Player taps / auto after the card" has no time. | New knob `goal.intro_card_ms` (count, 0–4000, default **2000**). Any tap skips it. 0 means no intro. |
| G2 | **BFP** | Rule 13 vs AC 14 | When does the clock start? Does it run during Resolving and entry delay? | It starts at the **first spawn**. It runs through Resolving and entry delays. It stops during Warning, pause and the result. |
| G3 | **BFP** | F3 | Rescue on meadow_01 (H_play 8, margin 2): is `s` the highest occupied layer after the lock and its clears? | Yes: `s` = `stack_height()` read at step 6. Example: s = 9 → k = 9 − 5 = 4, so the top ends at 5 and layers 6–7 are free. |
| G4 | **BFP** | Rule 14 / UI | What is the minimal result flow for first playable? | Win and Lose both show stars (0–3), time and **Retry**. Win also shows **Next** (disabled until level select). Retry reloads the level with a new seed (S3). Stars are not saved in first playable unless ProfileStore lands (APP-001 already includes it). |
| G5 | MIN | Rule numbering | There are two rules numbered "10c" (Lose, Out of pieces). | Renumber Out of pieces to 10d when the GDD is next edited. |
| G6 | MIN | Edge "spawn blocked but under limit" | Contradicts itself: content in the spawn zone means over the limit. | It only arises from non-solid or unremovable content. No first-playable path. |
| G7 | BL | Edge "rescue cannot bring under" | How is that detected? | After the wipe, if `over_limit()` is still true, the level is lost. |
| G8 | MIN | AC defaults | Use 8 × 8 × 16 with H_play 12. | Explicit; fine. |
| G9 | MIN | Tie-breaks rule 15 | Uses "higher stack-free margin" vs "lower stack". | Same meaning: the lower `stack_height` wins. |

## 8. Scoring & Stars (`scoring-stars.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| R1 | **BFP** | Rule 3 | meadow_01 star times. | Read the level's `stars {t2: 145, t3: 105}` (seconds). F1 is only the fallback. Compare with `≤` on whole-ms level clock. |
| R2 | MIN | Knob files `goals.json` | Marked "TODO(design): no range", but the GDD **does** give ranges. | Set star2_share to 0.6–1.0, star3_share to 0.4–0.9, survive shares to 0.3–1.5 (Scoring F1/F4). Validation keeps t3 < t2. |
| R3 | MIN | HUD show_clock | Star times are time-based but the clock is hidden by default. | First playable: show the clock in meadow_01 (`hud.show_clock` = on for campaign during prototype). Final call goes to the user. |
| R4 | BL | F2 | Score isn't needed for first playable (Vertical Slice). | Compute it, don't show it (reserved slot). |

## 9. Camera & Rotate-View (`camera-rotate-view.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| C1 | **BFP** | Rule 2, F1, rule 6 | **Yaw convention.** Which axis is yaw 0 measured from, which way does it grow, and what does "clockwise" mean? | The camera's horizontal position is `centre + r·(cos yaw, 0, sin yaw)`, so yaw grows from +x toward +z (clockwise seen from above in Godot's y-up coordinates). `rotate_view(+1)` = k + 1 = the camera orbits clockwise seen from above. This reproduces the GDD's yaw-75° example (+x appears 15° off screen-right). At k = 0, screen-right maps to −z (up-right) and screen-left to +z. |
| C2 | **BFP** | Rule 2, F2 | What is the look-at point (vertical centring)? | `(0, board_height/2, 0)` in board-local world (B1), i.e. the centre of the full drawn height including the spawn zone. F2 assumes this symmetric box. |
| C3 | MIN | F1 range | `yaw_offset` default 45° sits outside its 0–29° range (the knob file already uses 15). | Use **15°**: the same views, since corner views sit at k = 0, 3, 6, 9. Fix the GDD text. |
| C4 | **BFP** | Rule 5a / HUD | Orientation for first playable? HUD is landscape-only while Touch and Camera support both. | First playable is **landscape-only** (`app.orientation_lock = landscape`). Portrait follows once the HUD has a portrait layout (INP-001 may still build both control layouts). |
| C5 | BL | Rule 12 Fade | Fade is the default occlusion mode and needs per-block alpha (ADR-0007). | On a 4 × 4 H8 board, h ≈ 0.32. First playable may override meadow_01 to `view.occlusion_mode = ghost_only` until fade lands. **User decision** (it changes how the level reads). |
| C6 | MIN | Rule numbering | 5a comes before 5. | Cosmetic. |
| C7 | MIN | Ortho near/far | Not specified. | Camera at distance 2 × the board's diagonal; near 0.1, far 4 × the diagonal. Engineering choice, not design. |

## 10. Touch Controls (`touch-controls.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| T1 | **BFP** | Scheme A, F3 | Does a button act on touch-down or on release? | D-pad and rotation buttons act on **touch-down**. Repeats follow F3 while held. The drop button is the exception (T2). |
| T2 | **BFP** | Scheme A drop button, F2 | When do hard drop and soft drop fire? | On touch-down, nothing happens. At `hold_ms` (200), soft drop turns on, and it turns off on release. Releasing before `hold_ms` (and `d < flick_min_px`) gives a hard drop on **release**. A hold-then-release never hard-drops. `tap_ms` and `hold_ms` share 200 ms; if they ever differ, `hold_ms` wins on the drop button. |
| T3 | **BFP** | F3 heading | Do rotate buttons repeat when held? | **No** repeat on rotation by default: `control.rotate_repeat` flag, default false. A held spin of 4 × 90° is too easy to overshoot. The d-pad repeats. |
| T4 | **BFP** | Rule 9, meadow_01 CV02 | Which controls exist in spin-only mode? | Only the diamond's left/right (spin) arms are visible. Tilt arms and roll arcs are hidden (not greyed). Rotate-view stays visible. |
| T5 | **BFP** | Waiting state | When does the input buffer start? It says "the last `input_buffer_ms`", but Waiting can last 450 ms or more. | Only presses whose tick is within `input_buffer_ms` (100) **before the spawn tick** are kept (the latest one). Earlier Waiting presses are dropped. Matches AC 14. |
| T6 | MIN | F1 cap | "±7 on 8 wide board" | Cap = W − 1 of the active board. Scheme B only. |
| T7 | MIN | Dev keyboard | No design mapping exists. | Arrows/WASD = move (screen-relative), Q/E = spin left/right, R/F = tilt, Z/C = roll, Space = hard drop, Shift (held) = soft drop, `[` / `]` = rotate view, Esc = pause. Dev only. |
| T8 | MIN | Rule 3 | The axis tie at corner snaps is defined twice (here and in Movement rule 9). | Consistent with each other; no action. |

## 11. HUD (`hud.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| H1 | **BFP** | Rule 2, F2 | Danger state on meadow_01? | `H_play − 1 − danger_margin` = 8 − 1 − 2 = **5**, so danger starts when `stack_height() ≥ 5`. Already in the formula; confirmed. |
| H2 | **BFP** | Rule 2 | Is the first-playable preview a placeholder? | UI-001 placeholder (shape name or flat icon) is acceptable for first playable. The real 3D preview (PreviewBaker) comes later. Design accepts this. |
| H3 | BL | Open Q Portrait | No portrait layout exists. | See C4. |
| H4 | MIN | Rule 6 | What happens when the pause button is tapped? | The pause menu holds Resume, Retry and Quit (back to boot level for now). |
| H5 | MIN | Rule 8 | Is the danger state recomputed during Resolving? | It updates on each `cells_changed` event. |

## 12. Rule-Twist Framework (`rule-twist-framework.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| X1 | **BFP** | Rule 11, Movement rule 9 | CV02 (spin only) is implemented as a veto (`rotate.<axis>`, per the implementation plan), while `rotation_axes_enabled` is a knob. Which one hides the controls? | Use the **knob** `control.rotation_axes_enabled = ["spin"]`, set by the `spin_only` rule. Touch hides controls from the knob. A disabled-axis command returns `Disabled` with **no** "blocked by rule" pop (Movement rule 9 wins over framework rule 11 for this case, because the control isn't visible). |
| X2 | MIN | Rule 16 | Must spin-only show an icon? | Yes, in the rule strip (validation requires an icon). Placeholder icon is fine. |
| X3 | MIN | Rule 7 | A rule changes `g` mid-interval. | The current step deadline stands and the new interval applies from the next step (already covered by rule 7). |
| X4 | BL | Rule 14 | When in the tick are `on_tick` writes applied? | At the end of the tick, after lock and resolve (ADR-0001 order). Not used in meadow_01. |

## 13. Game Feel & VFX (`game-feel-vfx.md`)

| # | Sev | Section | Question | Proposed default (knob) |
|---|---|---|---|---|
| V1 | MIN | All | Vertical Slice; nothing here blocks first playable. | First playable uses flat placeholders: snap, flash and fade. |
| V2 | MIN | Rule 6 | Is `max_punch_px` measured in device px or points? | Device px. |
| V3 | BL | F1 | What is the `size` input for row and colour detectors? | Clear-count units (the mechanic's unit). |

## 14. Cross-GDD contradictions (summary)

1. Default board 8 × 8 × 12 vs 6 × 6 × 10 + 4: Board Overview, Piece Set Game Feel, Camera Overview and several ACs (B2).
2. When the lock timer starts: FDL rule 3 and the state table vs rule 9 (F1).
3. Camera `yaw_offset` default outside its range (C3).
4. HUD landscape-only vs portrait support in Touch and Camera (C4).
5. Pivot: GDD library (0,0,0) vs the art-authored Blender pivot (P1).
6. Disabling spin-only: knob vs veto (X1).

## 15. Not audited

- Only skimmed: systems-index.md and game-concept.md. No core-loop rule gaps were found in either.
- Level Data GDD, Twist Library, Level-Specific Mechanics and Obstacles were out of scope, except for checking the meadow_01 fields.
