# Fall, Drop & Lock

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10 (against ADR-0001, ADR-0004, ADR-0010, ADR-0011)
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Comeback Energy

## Summary

Fall, Drop & Lock makes the piece come down and become part of the tower. Gravity pulls it down at a speed each level sets (and can slowly ramp up), soft drop speeds that up while held, and hard drop sends it straight to the landing ghost with a brief grace moment to adjust. When the piece lands, a lock delay gives the player time to slide or turn it, restarted a limited number of times so nobody can stall forever; then the piece locks into the board and the next one is called.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Board / Grid, Movement & Rotation`

## Overview

This system owns the clock of a falling piece. From the moment a piece spawns until its cubes are written to the board, it decides how fast the piece falls (gravity), what soft drop and hard drop do, when a landed piece locks (lock delay and resets), how the landing ghost is computed, and how long the pause is before the next piece (entry delay). It uses Movement & Rotation's collision primitive for every step, so there is one authority on what space is free, and it writes the locked cubes to the board and then hands control to Layer Clearing and the Spawner. By default fall speed is set per level with an optional ramp (per layer cleared and/or per minute); the lock delay is 500 ms with 10 resets (generous for thumbs on a phone); and hard drop lands instantly on the ghost, then waits a 150 ms grace in which a move or rotation still works, and a second hard drop commits at once. Twists, buffs and perks change the rules by changing the numbers (gravity scale, lock delay) or by replacing gravity (a down-axis flip, or Physics Mode) through the Rule-Twist Framework. This serves *Readable Chaos* (the ghost and a lock cue always show what will happen), *The Block Is the Constant* (falling and locking are the heartbeat), and *Comeback Energy* (a fast, forgiving placement loop). All values are starting defaults.

## Detailed Design

### Core Rules

**Gravity**
1. Each falling piece has a **fall speed** `g` in cells per second along the board's **down axis** (default −y; any of ±x, ±y, ±z, Board / Grid rule 3). A fall step moves the piece one cell along the down axis through `try_translate` (Movement & Rotation) if the target cells pass `can_place`; the interval between steps is `1 / g` (Formulas F1).
1a. **Gravity clock.** Each piece has a clock counting time since its last fall step. It **resets to zero when the piece spawns** (so the first step comes one full interval after the spawn). Turning soft drop on or off does **not** reset it: the elapsed time carries over, and the next step happens as soon as the elapsed time reaches the interval for the current speed. A successful fall step resets it to zero.
2. A level sets a **base speed** `g0` and may add a **ramp**: per layer cleared and/or per minute, up to a cap `g_max`. A **gravity scale** (twists, buffs, potions) multiplies the result. A scale of 0 stops the piece from falling by itself; soft and hard drop still work.
3. When a fall step is blocked, the piece is **resting** (Movement & Rotation F4) and the lock delay starts.

**Soft drop**
4. While `soft_drop` is on, the fall speed is the soft-drop speed `g_soft` (Formulas F1): the current speed times `soft_drop_factor`, never below `soft_drop_min` and never above `soft_drop_max`. Soft drop only changes how fast the piece falls; it does **not** shorten the lock delay (`soft_drop_locks = false` by default).
5. Soft drop turns off when the finger lifts, and is **cleared when a new piece spawns**: the player must press again, so a held finger cannot drop the next piece by accident (`soft_drop_carry = false`).

**Hard drop**
6. `hard_drop` sends the piece down in one go to the **drop target** (the lowest position reachable straight down, Formulas F3, the same place the landing ghost shows). It is ignored in the Waiting state and is never buffered (Touch Controls).
7. After the drop, the piece enters a **grace** of `hard_drop_grace_ms` (default 150). During grace the player may still move or rotate it (Movement & Rotation rules apply; each is a normal command and does not extend the grace). When the grace ends, the piece locks if it is resting; if a move during grace left it unsupported, the grace is cancelled and it falls normally again.
8. A second `hard_drop` during grace **commits**: the piece locks at once. A hard drop while already resting drops zero cells and starts the grace in the same way.

**Lock delay**
9. The **lock timer** starts, at `lock_delay_ms` (default 500), **every time the piece comes to rest**, whatever the cause: a blocked fall step, a move or rotation that ends resting, or content appearing under it. It counts down while the piece rests; at 0 the piece locks. The timer pauses with the game and is cleared whenever the piece stops resting. (Hard drop uses the grace of rules 7–8 instead.)
10. A **successful** move or rotation while resting (a kicked rotation included; a blocked command does not count) restarts the timer to full and uses one of the piece's `lock_resets_max` resets (default 10). When the resets are used up, the timer still runs but no longer restarts, so the piece locks at the end of the current delay.
11. If the piece falls to a layer lower than any it has reached before, its reset count is restored to full. "Lower" is measured by the piece's **lowest cube** along the current down axis (the cube furthest in the down direction), so the rule works for all 6 gravity directions. This lets a piece that is genuinely making progress down a stack keep its resets.
12. If the piece stops resting (the player slides it off a ledge, or a clear or twist removes its support), the timer is cleared (resets used are kept) and gravity resumes. When it rests again the timer restarts from full.
13. `lock_delay_ms = 0` locks the instant the piece rests, which makes this an instant-lock level.

**Lock and after**
14. When the piece locks, each cube is written to the board as a Block with the record `{shape_id, piece_instance_id, owner, tags, status}` (Board / Grid rule 6). Hue is not stored: it comes from `shape_id` plus the level's art set (`design/art/block-art-sets.md`). The piece instance ends (Piece Set: Locked) and the board goes into Resolving (Board / Grid). The `piece_locked` event (ADR-0001) carries `{cells, cause, holes_added}`: the last position, the lock cause (delay, hard drop, commit), and `holes_added` (int ≥ 0), the number of **new covered holes** this lock made, computed at S1 against the board before the write with the same test as `RuleApi.new_covered_holes` (K3 in `meadow-candidate-atoms.md` §7; ADR-0011 §4). It is counted before S3, so a hole that a clear later removes still counts. Mascot Reactions (rows 13–14) reads it; staging never recomputes holes itself.

**Per-lock sequence (the single owner)**
15. Every lock runs this sequence, in this order, and no other GDD defines its own order (step ids per ADR-0011 §3, which amends ADR-0001's `step()` order). Each step finishes before the next starts:
    - **P0–P2** (every tick, before any lock): commands applied in arrival order (`on_command`), rule tick (`on_tick`, writes buffered to end of tick), gravity/travel step (`on_fall_step`).
    - **P3. Lock veto**: before writing, the sim asks `can(&"piece.lock")`. A rule may veto it after calling `return_piece_to_spawn(hold_ms)` (Pip's catch, WO11): the piece goes back to its spawn origin in its current orientation, gravity clock reset, held for `hold_ms`. **A vetoed lock is not a lock**: no cubes, no `on_lock`, no lock count, reset count or piece-lifetime advance, and the sequence below does not run.
    1. **S1 Lock**: cubes written (rule 14); board → Resolving.
    2. **S2 `on_lock`** hooks (Rule-Twist Framework).
    3. **S3 Clear**: Layer Clearing's routine runs with the level's `clear.detector` and `clear.collapse` slots (all chain rounds included), `on_clear` per cell. No clear → it ends at once.
    4. **S4a Structure changes**: queued `request_down_axis` / `request_mask` / `request_slot` changes are applied, then the stack settles. This is the **only** step where the board's structure may change (gravity flip EV03, mask, slot swaps).
    5. **S4b `on_resolve_end`** hooks, in ascending F2 priority (content, then twists, then the mechanic).
    6. **S4c Post-hook clear**: if any S4b subscriber wrote or removed content, the clear routine runs **once** more (`on_clear` included; `on_resolve_end` does not run again; a layer still full waits for the next check). S4c clears count normally.
    7. **S5 Goal check** (Level Goals rule 6, including `on_goal_check`). A met goal ends the level here: the win counts even if the stack is over the limit.
    8. **S6 Top-out check**: `over_limit()` is read **now, after all clears (S3 and S4c)**, never earlier.
    9. **S7 `on_top_out`** hooks (only if S6 found a top-out), then the **top-out outcome** by the level's `goal.top_out` slot (Level Goals rule 10a): `rescue` (wipe through Layer Clearing's `wipe_bottom`; the sim enters the Warning phase), `trim`, or `lose`. A loss ends the level here. The outcome is fixed at S7.
    10. **S8–S9** Board → Live after the Resolving window; **entry delay** `fall.entry_delay_ms` (default 200). This is the **Waiting** state, in which input keeps the latest move or rotate for the new piece (100 ms, counted in ticks, ADR-0012 §7).
    11. **S10 Spawn**: `spawn()` (`on_spawn`). If the spawn is blocked, it is a top-out and goes back to S7 (Level Goals); after a rescue or trim, `spawn()` is called again once.
16. **Timing.** S1–S7 are logic and all run on the lock tick. The sim then stays in Resolving for `t_resolve_ms` (Layer Clearing F2, grown by the S4c round's clear time when S4c clears something) and reports that final length in the `resolve_started` event, so the view and staging never guess it (ADR-0001, ADR-0011). Entry delay starts when Resolving ends. Nothing the player does can change the outcome: no input acts during Resolving. A pause stops ticking, so it freezes the window where it is.

**Landing ghost**
17. The landing ghost shows the drop target (F3) at all times while a piece falls, updating on the tick each move, rotation or fall step applies (ADR-0001: commands apply on the next tick, ≤ 17 ms after the press). It is an outline of the piece in its hue and sits at the piece's own position when the piece is resting.

**Rules from outside**
18. The Rule-Twist Framework can: change the gravity scale, base speed or ramp; set `lock_delay_ms` or `lock_resets_max`; set the down axis to any of the 6 directions (gravity direction follows it; only between pieces or as Board / Grid allows); call `try_translate` for wind or drift; veto a lock at P3 (rule 15); or switch gravity off. Down-axis changes requested while Live are queued to S4a. Physics Mode may replace this system's rules with physics entirely.

### States and Transitions

Per player:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Waiting** | No piece; board resolving, then entry delay | Level start; a piece locked | `spawn()` succeeded → Falling; the mode ends |
| **Falling** | Piece is falling under gravity (or soft drop) | Spawn; support removed from a resting piece; grace cancelled | Piece rests → Resting; `hard_drop` → Grace |
| **Resting** | Piece is on something; lock timer running | A fall step is blocked | Timer reaches 0 → Locked; support lost → Falling; `hard_drop` → Grace |
| **Grace** | Hard-dropped; short window to adjust | `hard_drop` | Grace ends and resting → Locked; second `hard_drop` → Locked; unsupported → Falling |
| **Locked** | Cubes written; board resolving | Lock | Immediately → Waiting |
| **Frozen** | Timers stopped | Pause, level over | Resume to the previous state |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Touch Controls | → FDL | `soft_drop(on/off)`, `hard_drop`; FDL returns lock events |
| Movement & Rotation | ↔ | FDL calls `try_translate` and reads the resting flag and drop target; Movement's successful moves and rotations tell FDL to reset the lock timer |
| Board / Grid | ↔ | FDL writes locked cubes with `set`; reads down axis, `over_limit()`, state (Live / Resolving) |
| Piece Spawner & Queue | FDL → | `spawn()` after Waiting |
| Layer Clearing | FDL → | Lock event starts it; its end (Board Live) ends the wait |
| Level Goals & Fail States | ↔ | FDL runs the per-lock sequence (rule 15) and calls Goals for the goal check, top-out check and `topout_rule` outcome; layers cleared feed the gravity ramp |
| Rule-Twist Framework, Twist Library, Items, Characters & Perks | ↔ | Gravity scale, base speed and ramp, lock delay and resets, down-axis flip, wind/drift translations |
| Physics Mode | ↔ | May replace the whole system |
| HUD, Game Feel & VFX, Audio | FDL → | Ghost, lock cue, land / lock / drop events |
| Level Data & Definition | → FDL | `g0`, ramp values, `g_max`, lock delay, resets, entry delay |

## Formulas

All values are starting defaults to tune by prototype. Time in milliseconds, speed in cells per second.

### F1. Fall speed

The fall_speed formula is defined as:

`g = min(g_max, g0 + ramp_per_clear × layers_cleared + ramp_per_min × minutes) × gravity_scale`
`g_soft = clamp(g × soft_drop_factor, soft_drop_min, soft_drop_max)`; step interval `= 1000 / g` ms (or `1000 / g_soft` while soft drop is on)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| g0 | float | 0.3–4 | data file (level) | Base speed in cells/s |
| ramp_per_clear | float | 0–0.5 | data file (level) | Cells/s gained per layer cleared; default 0.05 |
| ramp_per_min | float | 0–0.5 | data file (level) | Cells/s gained per minute of play; default 0 |
| layers_cleared | int | ≥ 0 | calculated (Layer Clearing) | Layers cleared so far this level |
| minutes | float | ≥ 0 | calculated | Play time this level |
| g_max | float | 1–10 | data file | Speed cap; default 6 |
| gravity_scale | float | 0–4 | calculated (twists, buffs) | Multiplier; default 1; 0 stops falling |
| soft_drop_factor | float | 2–40 | data file | Soft drop multiplier; default 10 |
| soft_drop_min, soft_drop_max | float | 1–60 | data file | Soft drop speed bounds; default 8 and 30 |

**Integer form (ADR-0001, ADR-0004 §3):** scalars are milli-units, so the sim computes `g_milli` (milli-cells/s) with integer math and the step interval as `1_000_000 / g_milli` ms (integer division) when each step is scheduled; the decimals above are the authoring form, converted once on load.

**Output Range:** `g` from 0 to `g_max × max scale`; `g_soft` from 8 to 30 cells/s. **Example:** `g0 = 1`, 10 layers cleared, no time ramp → `g = 1 + 0.05 × 10 = 1.5` cells/s (one step per 667 ms); soft drop = clamp(15, 8, 30) = 15 cells/s (67 ms per step).

### F2. Fall time

The fall_time formula is defined as:

`t_fall = d / g` seconds, where `d` is the drop distance (F3)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d | int | 0 to `board_height − 1` | calculated (F3) | Cells from the current position to the drop target |
| g | float | 0.3–6 | calculated (F1) | Fall speed (or `g_soft` with soft drop) |

**Output Range:** 0 up to about 40 s at the slowest speed on a tall empty board. **Example:** a piece spawns with its lowest cube at layer 12 on an empty board: `d = 12`; at `g = 1`, `t_fall = 12 s`; with soft drop at 10 cells/s, `1.2 s`. The placement-time target of 6 s (flat) to 10 s (3D) from Touch Controls P1 is why the default is not lower than 1 cell/s.

### F3. Drop distance and drop target

The drop_distance formula is defined as:

`d = max k ≥ 0 such that can_place(cells + j × down) for every j in 1..k` (stepping one cell at a time from the current position, stopping at the first failure); drop target = `cells + d × down`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cells | int[3][] | the piece's current cells | calculated (Movement F1) | Occupied cells now |
| down | int[3] | unit axis vector | data file (Board) | Down direction, default (0, −1, 0) |
| d | int | 0 to `board_height − 1` | calculated | Cells the piece can fall straight down |

**Output Range:** `d = 0` when resting. The sweep is one cell at a time, so a piece never passes through a solid cell. **Example:** a piece whose lowest cube is at y = 14 above a stack whose highest solid cell is at y = 4 in that column lands with its lowest cube at y = 5, so `d = 9`.

### F4. Longest stall and lock reset budget

The lock_stall formula is defined as:

`stall_max = lock_delay_ms × (1 + lock_resets_max)` while the piece stays on one lowest layer

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| lock_delay_ms | int | 0–1500 | data file | Time before lock; default 500 |
| lock_resets_max | int | 0–30 | data file | Resets per piece (restored when a new lowest layer is reached); default 10 |
| stall_max | int | 0–46 500 | calculated | Longest the player can keep a piece from locking without making progress down |

**Output Range:** 0 up to 46.5 s at the extremes; with defaults 5 500 ms. **Example:** 500 × (1 + 10) = 5.5 s: even a player who keeps rotating a resting piece loses it after 5.5 s unless they let it descend. The resets are restored only when the piece reaches a lower layer, so stalling by wiggling never goes on forever.

### F5. Piece cycle time (lower bound)

The cycle_time formula is defined as:

`t_cycle ≥ t_fall + lock_delay_ms + t_resolve + entry_delay_ms`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| t_fall | float | 0–40 s | calculated (F2) | Fall time |
| lock_delay_ms | int | 0–1500 | data file | Lock delay (0 if the piece was hard-dropped and committed) |
| t_resolve | int | 0–2000 ms | calculated (Layer Clearing) | Clear and collapse animation time; 0 with no clear |
| entry_delay_ms | int | 0–600 | data file | Wait before the next spawn; default 200 |

**Output Range:** about 0.35 s (hard drop, commit, no clear) upward. **Example:** hard drop with grace 150 ms and entry delay 200 ms and no clear → about 0.35 s per piece; this sets the upper bound on how fast a skilled player can place pieces (about 170 pieces a minute), well above what the 3D rotation controls allow.

## Edge Cases

- **If `hard_drop` is pressed in Waiting**: ignored, not buffered (Touch Controls).
- **If `hard_drop` is pressed while resting**: zero-cell drop; the grace starts; a second press commits.
- **If a move or rotation during grace makes the piece unsupported**: the grace is cancelled and the piece falls normally; it can be hard-dropped again.
- **If the grace ends while the piece is resting**: it locks, even if the lock timer still had time.
- **If a blocked move or rotation is sent while resting**: no reset is used and the timer is unchanged.
- **If the player keeps wiggling a resting piece**: after `lock_resets_max` resets the timer stops restarting; the piece locks at the end of the current delay (F4).
- **If the piece reaches a lower layer than any before**: its resets are restored to full.
- **If a twist or clear removes the support under a resting piece**: the timer is cleared (resets kept) and the piece falls again.
- **If a twist fills the cell below the piece mid-fall**: the next fall step is blocked and the piece rests normally.
- **If `lock_delay_ms = 0`**: the piece locks the instant it rests (instant lock); resets are irrelevant.
- **If `gravity_scale = 0`**: the piece does not fall by itself; soft drop uses `soft_drop_min`; hard drop works. A level with no other way to end must provide a timer (Level Goals).
- **If soft drop is held when a piece locks**: it is cleared; the next piece falls at normal speed until the player presses again.
- **If a piece locks partly in the spawn zone**: it locks normally; clears run first; if the stack is still over the limit after them, the level's `topout_rule` decides (rule 15, steps 6–8).
- **If a spawn is still blocked after a rescue or trim has run for it**: the level is lost (no second rescue for the same spawn).
- **If soft drop is toggled between fall steps**: the gravity clock keeps its elapsed time (rule 1a); turning soft drop on 900 ms into a 1 000 ms interval steps the piece at once.
- **If the down axis flips while a piece is falling or resting**: gravity direction updates, the piece keeps its cells, the resting state is recomputed and the lock timer is cleared (resets kept).
- **If a lock and a pause happen in the same frame**: the tick that is running completes (lock and S1–S7 included), then the game pauses; the Resolving window resumes where it stopped.
- **If a rule vetoes the lock at P3** (Pip's catch): no lock happens; the piece returns to spawn and falls again after `hold_ms`; lock-delay resets and piece-count lifetimes are unchanged.
- **If an S4b hook completes a layer** (a chick hops into the last gap): S4c clears it once; if S4c leaves another layer full, it waits for the next lock.
- **If the app is backgrounded**: the game pauses (ADR-0010: focus-out / app-paused → `request_pause`), ticking stops so all timers freeze (Frozen), touches and pending commands are cancelled, and resume shows the pause menu.
- **If the mode ends during the lock delay or grace**: the piece is not locked; the state is Frozen and the piece stays on screen.
- **If two lock causes occur on the same tick** (timer expiry and a commit): one lock only; the cause is the commit.
- **If a symmetric shape is rotated in place while resting**: it counts as a successful rotation and uses a reset.
- **If the level has no ramp and no clears**: `g = g0`; the level plays at a constant speed.

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | `set` for locked cubes, down axis, `over_limit()`, Live / Resolving state |
| Movement & Rotation | Hard | `try_translate`, resting flag, drop target, success events for lock resets |
| Touch Controls | Hard | `soft_drop`, `hard_drop` commands |
| Piece Spawner & Queue | Hard | `spawn()` |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Layer Clearing | Hard | Lock event starts a clear check |
| Level Goals & Fail States | Hard | Lock events, over-limit result, layers cleared |
| Rule-Twist Framework, Twist Library | Hard | Gravity scale, base speed, ramp, lock delay, resets, down-axis flip, translations |
| Level Data & Definition | Hard | `g0`, ramp, `g_max`, lock delay, resets, entry delay |
| Physics Mode | Hard | May replace it |
| HUD, Game Feel & VFX, Audio | Soft | Ghost, cue and events |
| Mascot Reactions | Soft | `piece_locked.holes_added` (bad drop, clean streak) |
| Items, Characters & Perks | Soft | Gravity scale, lock delay for one player |

Board / Grid, Movement & Rotation, Touch Controls and the Spawner already name Fall, Drop & Lock; each remaining downstream GDD must list it when written.

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| base_gravity (g0) | 0.3–4 cells/s | 1.0 | data file (level) | Overall pressure; F2, F5 |
| ramp_per_clear | 0–0.5 | 0.05 | data file (level) | How quickly speed climbs as layers clear |
| ramp_per_minute | 0–0.5 | 0 | data file (level) | Time pressure independent of clears |
| max_gravity (g_max) | 1–10 | 6 | data file | Hard cap on speed |
| gravity_scale | 0–4 | 1 | data file (twists, buffs) | Slow motion / speed-up effects |
| soft_drop_factor | 2–40 | 10 | data file | Soft drop strength (with min and max below) |
| soft_drop_min / max | 1–60 cells/s | 8 / 30 | data file | Soft drop never too slow or too fast |
| soft_drop_locks | true / false | false | data file | Whether soft drop on the ground shortens the lock delay |
| soft_drop_carry | true / false | false | data file | Whether a held soft drop continues to the next piece |
| hard_drop_grace_ms | 0–400 | 150 | data file | Safety against mis-tap vs. snappiness; 0 = instant lock |
| lock_delay_ms | 0–1500 | 500 | data file (level, perk) | Time to adjust after landing |
| lock_resets_max | 0–30 | 10 | data file (level, perk) | How long a player can stall (F4) |
| entry_delay_ms | 0–600 | 200 | data file | Gap between pieces |

`lock_delay_ms = 0` makes `lock_resets_max` and the lock cue inert; `hard_drop_grace_ms = 0` makes the commit rule inert.

## Visual/Audio Requirements

- **Ghost**: a soft outline of the piece in its hue at the drop target, always visible, never filled (art bible: the ghost must not read as a placed block). It lies on the board surface or on top of the stack.
- **Landing**: when the piece first rests, a small squash and a puff of dust at its footprint.
- **Lock cue**: while the lock timer runs, the piece's outline brightens and a ring on the ghost fills with the remaining delay; with resets exhausted the ring turns warm. It is shape-coded as well as colour-coded and respects reduced motion (no pulse, static fill).
- **Lock**: a quick settle-flash on the piece and a thunk; the piece turns into Blocks without any change of look, so the stack stays readable (Pillar 2).
- **Hard drop**: speed streaks along the fall path for 80–100 ms, then the piece sits for the grace; a small camera punch (translation only, off with reduced motion) at lock.
- **Soft drop**: faint streaks on the piece; no sound loop, a soft tick per cell at most.
- Audio events (owned by Audio): `piece_landed`, `lock_thunk`, `hard_drop_whoosh`, `soft_drop_tick`, `lock_resets_low` (a soft warning).

## Game Feel

Falling should feel steady and fair: the player always knows where the piece will land and how long they have left to adjust. Targets: ghost updated on the tick any command applies; hard drop visuals ≤ 100 ms whatever the distance; grace 150 ms; lock thunk in the same frame as the lock; the lock cue visible for the whole delay. Gravity changes (ramp, twists) are announced by feel, never by a number the player must read. The default pace aims at placement times of 6 s (flat) to 10 s (3D) from Touch Controls P1, which a base speed of 1 cell/s supports.

## UI Requirements

None directly. The HUD may show speed level or time (HUD); Settings may offer ghost opacity and lock-cue style in Onboarding & Accessibility. 📌 **UX Flag — Fall, Drop & Lock**: the ghost and lock cue are on-board elements; run `/ux-design` for the HUD to confirm they don't clash with the preview and item strip.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 3, 8, 10, 11; States; Edge Cases | Down axis, falling piece not in the grid, over limit, spawn zone, Resolving state, locking in the spawn zone |
| `design/gdd/movement-rotation.md` Core Rules 8, 17, 18; F4; Open Questions | `try_translate`, resting flag and test, `landed_move_rule`, the lock-reset question (answered here: successful moves and kicked rotations reset the timer) |
| `design/gdd/touch-controls.md` Edge Cases; Core Rules 7, 8 | `soft_drop`, `hard_drop`, Waiting and the 100 ms buffer, hard drop never buffered, lock events |
| `design/gdd/piece-spawner-queue.md` Core Rules 8, 9; Open Questions | `spawn()`, spawn blocked, Waiting delay owned here |
| `design/gdd/piece-set.md` Core Rules 7–8 | Piece lifecycle: Falling → Locked |
| `design/gdd/camera-rotate-view.md` | Camera punch is translation only |
| `design/art/art-bible.md` §3, §4 | Ghost style, outline and colour rules |
| `design/gdd/game-concept.md` | Pillars; tiers add mechanics, not just speed |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: `g0 = 1`, `ramp_per_clear = 0.05`, lock delay 500, resets 10, grace 150, entry delay 200.

**Gravity and soft drop**
1. [U] F1: `g0 = 1`, 10 layers cleared → `g = 1.5`; `g_max = 6` caps a very high ramp; `gravity_scale = 0.5` halves it.
2. [U] **GIVEN** `g = 1`, **WHEN** 3 s of game time pass, **THEN** the piece has fallen exactly 3 cells (if free).
3. [U] F1 soft drop: `g = 1` → 10 cells/s; `g = 0.3` → 8 (the minimum); `g = 6` → 30 (the maximum).
4. [U] **GIVEN** soft drop is on while resting, **THEN** the lock delay is not shortened; **GIVEN** the piece locks, **THEN** soft drop is cleared for the next piece.
5. [U] **GIVEN** `gravity_scale = 0`, **THEN** the piece does not fall by itself, soft drop moves at 8 cells/s, and hard drop works.

**Hard drop and grace**
6. [U] F3: a piece with lowest cube at y = 14 above a stack top at y = 4 → `d = 9`, lowest cube lands at y = 5.
7. [U] **GIVEN** a piece falls, **WHEN** `hard_drop`, **THEN** it moves to the drop target in one logical step without passing through a solid cell, the ghost position matches, and the grace starts.
8. [U] **GIVEN** grace, **WHEN** 150 ms pass with the piece resting, **THEN** it locks; **WHEN** a second `hard_drop` is pressed first, **THEN** it locks at once.
9. [U] **GIVEN** grace, **WHEN** the player moves it off the ledge so it is unsupported, **THEN** the grace is cancelled and gravity resumes.
10. [U] **GIVEN** the Waiting state, **WHEN** `hard_drop` is pressed, **THEN** it is ignored and not buffered.

**Lock delay and resets**
11. [U] **GIVEN** a resting piece, **WHEN** 500 ms pass with no input, **THEN** it locks.
12. [U] **GIVEN** a resting piece, **WHEN** a successful move or kicked rotation is made, **THEN** the timer returns to 500 ms and the reset count rises by one; **WHEN** a blocked command is made, **THEN** neither changes.
13. [U] F4: with defaults, the longest a piece can stay without reaching a lower layer is 5 500 ms; the 11th wiggle no longer restarts the timer.
14. [U] **GIVEN** a piece reaches a lower layer than before, **THEN** its reset count is restored to 10.
15. [U] **GIVEN** the support under a resting piece is removed, **THEN** the timer clears, resets are kept, and the piece falls.
16. [U] **GIVEN** `lock_delay_ms = 0`, **THEN** the piece locks on the tick it rests.

**Lock and next piece**
17. [U] **GIVEN** a lock, **THEN** the board holds Blocks at the piece's cells, each with `{shape_id, piece_instance_id, owner, tags, status}` and no stored hue, the board is Resolving, and the piece instance is Locked.
17a. [U] **GIVEN** a flat piece locked on a flat floor, **THEN** `piece_locked.holes_added = 0`; **GIVEN** a piece locked over a one-cell gap that nothing above covers, **THEN** `holes_added = 1`, and it equals `RuleApi.new_covered_holes(cells)` evaluated at P3 for the same lock.
18. [I] **GIVEN** the board returns to Live, **WHEN** 200 ms pass, **THEN** `spawn()` is called; **GIVEN** `over_limit()` is still true after the clears and `topout_rule = lose`, **THEN** the level is lost and no spawn is called.
18a. [U] **GIVEN** an instrumented lock that clears one layer and leaves the stack over the limit, **THEN** the events fire in exactly this order: lock veto query (P3), lock (S1), `on_lock`, clear, S4a structure changes, `on_resolve_end`, S4c (only if an S4b hook wrote), goal check, top-out check, `on_top_out`, top-out outcome, entry delay, spawn; S1–S7 happen on the lock tick and the spawn comes `t_resolve_ms + entry_delay_ms` later.
18e. [U] **GIVEN** a rule vetoes `piece.lock` at P3, **THEN** no cubes are written, no `on_lock` fires, and lock count, reset count and piece-count lifetimes are unchanged (ADR-0011 `resolve_sequence_test`).
18f. [U] **GIVEN** a queued down-axis flip, **THEN** it applies at S4a, before any S4b hook; **GIVEN** an S4b write that fills a layer, **THEN** S4c clears it once, `on_resolve_end` does not re-run, and `resolve_started` reports the grown `t_resolve_ms`.
18b. [U] **GIVEN** a lock that goes over the limit and a clear that brings it back under, **THEN** no top-out is reported.
18c. [U] **GIVEN** `g = 1` and 900 ms elapsed since the last step, **WHEN** soft drop turns on, **THEN** the piece steps at once; **GIVEN** a spawn, **THEN** the first step comes 1 000 ms later.
18d. [U] **GIVEN** the down axis is +x, **WHEN** the piece's lowest cube (along +x) reaches a new lowest position, **THEN** its lock resets are restored.
19. [I] **GIVEN** a move pressed 80 ms before the spawn, **THEN** it applies to the new piece (Touch Controls buffer).
20. [U] **GIVEN** pause, **THEN** gravity, lock timer, grace and entry delay all stop and resume exactly.
21. [U] **GIVEN** the down axis flips while a piece is falling, **THEN** gravity follows the new axis, the cells are unchanged, and the lock timer is cleared.

**Presentation and performance**
22. [I] **GIVEN** any command, **THEN** the ghost updates on the tick the command applies.
23. [M] **GIVEN** the reference phone, **WHEN** a hard drop is made from the top of an empty board, **THEN** the visual travel takes ≤ 100 ms and the lock cue is readable through the whole delay.
24. [M] **GIVEN** the Touch Controls prototype, **THEN** hard-drop errors stay ≤ 3% with the 150 ms grace on (P3) and median placement time stays within P1.
25. [I] **GIVEN** reduced motion, **THEN** no camera punch or pulse plays; the lock ring still fills.

## Open Questions

- **Hard drop grace vs. snappiness**: is 150 ms right, or should it be per scheme? Decide with the Touch Controls prototype (P3).
- **Base speed**: 1 cell/s is derived from the 6–10 s placement targets; confirm by playtest with real 3D pieces.
- **Reset count on touch**: 10 is borrowed from classic stacker games; thumbs may need more or fewer.
- **Entry delay during clears**: is 200 ms after Resolving right, or should the next piece appear during a long clear animation? Decide with Layer Clearing.
- **Speed in versus**: should a trailing player fall slower (Comeback Energy) — via items only, or as a built-in handicap? Items / Tournament Flow to decide.
- **Wind and drift**: how often twist translations run relative to gravity is the Twist Library's job; they use `try_translate` and do not reset the lock timer unless the twist says so.
- **Physics Mode**: define which of these rules it keeps (hard drop, ghost) when it designs itself.
- **Tunable defaults, open to playtest**: the per-lock order (rule 15), the gravity clock carrying over across soft drop (rule 1a), the lock timer starting on every rest (rule 9) and "lower" by lowest cube (rule 11) are designer defaults of 2026-10-09; revisit if playtests show stalls or surprise locks.
- **Funny failures** (creative direction 2026-10-09): the lock itself stays clean and readable; the wacky moments belong to the top-out outcome (Level Goals) and the biome mascot's reactions.
