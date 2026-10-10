# Level Goals & Fail States

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Comeback Energy

## Summary

This system decides when a level is won or lost. Every level has one goal — clear N layers, build to a height, survive for a time, or fill a target shape — and a **top-out rule** set per level or mode (`topout_rule`): `rescue` (the bottom of the tower is wiped and a warning is used; the default, with 1 warning), `trim` (cubes over the limit pop off and the level never fails), or `lose` (the first top-out loses). There is no time limit by default; the clock only feeds the star times.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Board / Grid, Layer Clearing, Fall, Drop & Lock`

## Overview

Level Goals & Fail States turns the board's reports into a result. It reads the layers-cleared count and clear events (Layer Clearing), the stack height and over-limit report (Board / Grid), spawn-blocked reports (Spawner) and the level clock, and checks them against the level's **goal** at its step of the per-lock sequence (Fall, Drop & Lock rule 15). Four goal types are in the MVP: **Clear** (clear N layers; the default goal, with N set per level — there is no fixed clears-per-level pacing, and Formulas F1 only suggests a starting N when a level gives none), **Height** (build the tower to a target height, usually with clearing off), **Survive** (don't top out until the timer ends), and **Shape** (fill a marked set of cells). What a top-out (over the limit after clears, or spawn blocked) does is the level's or mode's `topout_rule`: **rescue** (default: a **warning** — a visible wipe of the bottom layers — and the top-out after the last warning loses; a level, perk or item can change the number of warnings), **trim** (build races and shape levels) or **lose**. Failures should be funny, never harsh: the biome's mascot reacts and the tower's fate is played for slapstick. Levels have no time limit unless the goal is Survive or the level asks for one; the level clock feeds the 3-star times (Scoring & Stars). In versus play each board has its own goal and fail state, and the mode decides how a round ends (default: first to the goal wins; a player who tops out with no warnings left is out). This serves *The Block Is the Constant* (every goal is built from the same blocks), *Readable Chaos* (one goal at a time, always shown), and *Comeback Energy* (the warning gives a second chance). All values are starting defaults.

## Detailed Design

### Core Rules

**Goals**
1. Each level has exactly **one goal** from Level Data: `clear`, `height`, `survive` or `shape`, with its target. Arcade also uses `endless`: no win condition; the run ends on a loss (Arcade Mode). A level with no goal uses `clear`, with N from Formulas F1 as a starting suggestion; levels normally set N by hand.
2. **Clear N layers.** The goal is met when `layers_cleared ≥ N`. Only layers cleared by Layer Clearing count; rescue wipes do not.
3. **Height H.** The tower's **height** is the number of layers from the floor up to the highest layer that is at least `height_coverage` full (default 50% of its active cells; Formulas F2). The goal is met when height ≥ `H_target`. `H_target` must be below the height limit (default `H_play − 2`). Height levels usually set `clear_enabled = false` (Layer Clearing).
4. **Survive T.** The goal is met when the level clock reaches `T` without a loss. The level usually ramps gravity (Fall, Drop & Lock).
5. **Shape.** The level marks a set of target cells `M` (`goal.target_shape`, per-layer ASCII grids; Level Data rule 4a). The goal is met when every cell in `M` holds content with `fills_layer = true`. Blocks outside `M` are allowed. Shape levels usually set `clear_enabled = false`; if clearing is on, a cleared target cell becomes unfilled again.
6. The goal is checked at **step 5 of the per-lock sequence** (Fall, Drop & Lock rule 15: after the clear routine and `on_resolve_end`, before the top-out check) and, for Survive, every frame. This GDD does not define its own order; it supplies steps 5–8.

**Fail states**
7. A **top-out** happens when `over_limit()` is true at step 6 of the per-lock sequence (after all clears), or when the Spawner reports spawn blocked. `on_top_out` hooks run, then the level's `topout_rule` (rule 10a) applies.
8. **Warnings (`rescue`).** Each level gives `warnings_max` warnings (default 1; level 0–3; perks, items and difficulty may add). On a top-out with a warning left, a **rescue** runs: Layer Clearing's `wipe_bottom(k)` removes the bottom `k` layers (Formulas F3) as a **silent wipe** (no hooks, effects or chains; slices shift down), the stack ends at least `rescue_margin` layers below the limit, and one warning is used. Rescue wipes do not count toward `layers_cleared`, the ramp or the score. Then play continues with the next spawn.
9. On a top-out with **no warning left**, the level is **lost**.
10. If a goal is met and a top-out happens in the same resolve, the **win counts** (the goal is checked first).
10a. **Top-out rule.** `topout_rule` (level or mode data, rule-adjustable) picks what a top-out does. This GDD owns the enum `rescue | trim | lose`:
   - `rescue` (default, rules 8–9);
   - `trim` (rule 10b);
   - `lose` (rule 10c).
   Other proposals (shake, bonk, hearts; Mechanics Catalog §6) are added here when a mode first needs them.
10c. **Lose.** The first top-out loses the level (or puts the player **out** in versus). `warnings_max` and `rescue_margin` are inert. It behaves like `rescue` with `warnings_max = 0` and exists so modes can say so plainly.
10b. **Trim** (default for No-Clear Build Race and Fill the Target Shape; user decision 2026-10-09: build races have no rescue wipe). After a resolve with `over_limit()` true, every content at or above `H_play` is removed with a visible pop-off-the-island effect. Trimmed cubes are not cleared: no `layers_cleared`, no score, no `on_clear`. No warning is used and the level is **never lost to a top-out**; the cost is time (and the ★★★ condition, Scoring & Stars). The goal is checked before the trim (rule 10), so a lock that reaches the target and pokes over the limit wins. Because the spawn zone is empty after a trim, spawn blocked can only come from content a trim cannot remove (see Edge Cases).
10c. **Out of pieces** (puzzle levels with a `fixed_list`, Spawner rule 5b): if the last listed piece has resolved and the goal is not met, the level is lost. No warning is used; retry is free.
11. A level may add **extra fail conditions** from Level Data (for example a time limit, or "an object reached the edge"). Each is checked after every resolve; time limits every frame. Extra fail conditions do not use warnings unless the level says so.

**Level flow and clock**
12. A level runs **Intro → Countdown → Playing → (Warning) → Result**. The countdown (`countdown_ms`, default 3 000) shows the goal and the first piece; the first spawn happens when it ends.
13. The **level clock** runs only while Playing (not during countdown, pause, warnings or the result). It is the time used by Scoring & Stars and by Survive goals.
14. On a result the board freezes (Board / Grid Frozen), input stops (Touch Controls Disabled) and the result, the clock, layers cleared, warnings used and pieces placed go to Scoring & Stars, Campaign Structure and Tournament Flow.

**Versus**
15. In versus, each player's board has its own goal and fail state. The mode decides the round. Default: the first player to meet the goal wins; a player who loses (top-out with no warning left) is **out**, and if only one player is left, they win. Ties in the same frame go to the player with more layers cleared, then the higher stack-free margin.

### States and Transitions

Per board:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Intro** | Goal card shown | Level loaded | Player taps / auto after the card → Countdown |
| **Countdown** | 3-2-1, first piece visible in the preview | Intro ends | Countdown ends → Playing (first spawn) |
| **Playing** | Normal play; clock runs | Countdown ends; Warning ends | Goal met → Won; top-out with a warning → Warning; top-out without → Lost; extra fail → Lost |
| **Warning** | Rescue wipe plays; clock stopped | Top-out with a warning left | Wipe done → Playing |
| **Won** | Result screen | Goal met | Next / retry / quit |
| **Lost** | Result screen | Fail | Retry / quit |
| **Out** (versus) | This player is out; others continue | Lost in versus | Round ends |
| **Paused** | Everything frozen | Pause | Resume |

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | ↔ | Reads `over_limit()`, `stack_height()`, layer fullness, contents of target cells; freezes the board on a result |
| Layer Clearing | ↔ | Reads `layers_cleared` and `clear_resolved`; asks it to run the rescue wipe |
| Fall, Drop & Lock | ↔ | Lock events; tells it not to spawn after a result; holds the first spawn until Countdown ends |
| Piece Spawner & Queue | Spawner → | Spawn-blocked reports |
| Touch Controls | Goals → | Disables input on results and during warnings |
| Level Data & Definition | → Goals | Goal type and target, `warnings_max`, extra fail conditions, `countdown_ms` |
| Scoring & Stars | Goals → | Result, clock, counts for stars |
| Campaign Structure, Tournament Flow, Mode / Minigame Randomizer | Goals → | Results; the mode's round rules |
| Rule-Twist Framework, Level-Specific Mechanics | ↔ | May add goals' extra fail conditions, change targets, or override the warning rule |
| Items, Characters & Perks | → Goals | Extra warnings |
| HUD | Goals → | Goal, progress (F4), warnings left, clock |
| Game Feel & VFX, Audio, Mascot Reactions | Goals → | Warning, win and loss events |

## Formulas

All values are starting defaults to tune by prototype and simulation.

### F1. Default clear target

The default_clear_target formula is defined as:

`N = max(1, round( T_level / t_beat ))`

There is **no fixed clear count** for the game (user decision 2026-10-09). Pacing is set by the heartbeat `t_beat` (Board / Grid F6, time between clears), which must sit in the level type's band; N is **authored per level**, and this formula only suggests it (the editor shows the suggestion; a level with no goal uses it).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T_level | float | 120–900 s | data file | Target level length; default 480 s (8 min, within the concept's 5–15 min) |
| t_beat | float | 5–340 s | calculated (Board F6) | Expected seconds between clears for this board, clear rule, piece set and `t_piece` |
| t_piece | float | 4–12 s | data file | Average time per piece, used inside t_beat; default 8 s (between Touch Controls P1's 6 s flat and 10 s 3D) |
| N | int | ≥ 1 | data file (suggested here) | Clears to make |

**Output Range:** 1 upward; the level's own N always wins. The validator **warns** if t_beat is outside the level type's band (Board / Grid "Recommended board per level type"), not if N differs from the suggestion. **Example:** default 6 × 6 board, `t_beat = 96 s` → `480 / 96 = 5` → N = 5. A 4 × 4 tutorial, `t_beat ≈ 42.7 s` → `480 / 42.7 ≈ 11.2` → N = 11 (a tutorial authors `T_level` 180 → N = 4). 8 × 8 with row clears, `t_beat = 20 s` → N = 24.

### F2. Tower height

The tower_height formula is defined as:

`height = 1 + max { y : filled(y) ≥ height_coverage × active_cells_in_layer(y) }` (0 if no layer qualifies)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| filled(y) | int | 0–64 | calculated (Board) | Cells in layer y holding `fills_layer` content |
| active_cells_in_layer(y) | int | 4–64 | calculated (Board) | Cells layer y has |
| height_coverage | float | 0.25–1.0 | data file | Share of a layer that must be filled to count; default 0.5 |
| H_target | int | 2 to `H_play − 1` | data file | Height to reach; default `H_play − 2` |

**Output Range:** 0 to `board_height`. Layers in between need not be filled to coverage (overhangs count), but the counting layer must, so a thin spire of single pieces does not reach the goal. **Example:** on 8 × 8, layer 9 with 33 filled cells and layer 10 with 20 → height = 10 (layer 10 is below 32); with `H_target = 10` the goal is met.

### F3. Rescue wipe size

The rescue_wipe formula is defined as:

`k = max(1, s − (H_play − 1 − rescue_margin))`, where `s = stack_height()` after the top-out

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s | int | 0 to `board_height − 1` | calculated (Board) | Highest occupied layer index |
| H_play | int | 6–12 | data file (Board) | Height limit layer index |
| rescue_margin | int | 0–4 | data file | Free layers left under the limit after a rescue; default 2 |
| k | int | 1 to `s + 1` | calculated | Bottom layers wiped |

**Output Range:** at least 1 layer, at most the whole stack. **Example:** `H_play = 12`, margin 2, a piece locks with its top at s = 13 → `k = 13 − 9 = 4`; after the wipe and slice shift the top is at layer 9, leaving layers 10 and 11 free under the limit at 12. For spawn blocked with the stack top at s = 15: k = 6.

### F4. Goal progress (for the HUD)

The goal_progress formula is defined as:

`progress = min(1, layers_cleared / N)` (clear), `height / H_target` (height), `clock / T` (survive), `filled(M) / |M|` (shape)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| layers_cleared, height, clock, filled(M) | number | ≥ 0 | calculated | Current value for the goal type |
| N, H_target, T, \|M\| | number | > 0 | data file | Goal target |

**Output Range:** 0–1. **Example:** N = 3 and 2 layers cleared → 0.67.

## Edge Cases

- **If a level has no goal**: `clear` with N from F1.
- **If N, H_target, T or M is invalid** (N < 1, `H_target ≥ H_play`, T ≤ 0, empty M, or M containing inactive cells): the level fails validation.
- **If the goal and a top-out happen in the same resolve**: the win counts.
- **If the goal is met by a clear that also lowers an over-limit stack**: won (over limit is evaluated after the clear anyway).
- **If a top-out happens while a warning is left**: rescue of k layers (F3), one warning used, play continues; the next piece spawns after the rescue.
- **If the rescue cannot bring the stack under the limit** (k would wipe the whole stack and something still sits over the limit, e.g. an indestructible obstacle): the warning is still used and the level is lost.
- **If spawn is blocked but the stack is under the limit** (a piece in the spawn zone, an object): treated as a top-out; the rescue wipes from the bottom as usual.
- **If `warnings_max = 0`**: the first top-out loses (classic).
- **If `topout_rule = trim` and a piece locks partly above the limit**: only its cubes at or above `H_play` pop off; the rest stay (pieces may be split).
- **If `topout_rule = trim` and spawn is still blocked** (content a trim cannot remove, e.g. an indestructible obstacle): the level is lost; `warnings_max` and `rescue_margin` are inert under trim.
- **If `topout_rule = trim` in a Survive level**: allowed, but the level can then only be won; validation warns.
- **If a perk or item adds a warning during play**: it can be used immediately.
- **If clearing is on in a Shape level and a target cell is cleared**: it counts as unfilled again; progress may go down.
- **If a Height level has clearing on**: allowed; clears lower the tower and make the goal harder.
- **If a Survive level's timer ends during a resolve**: the result waits until the resolve ends, then the win counts unless a top-out with no warning happened in that resolve.
- **If the app is paused or backgrounded**: the clock stops.
- **If the player quits**: counted as a loss for that attempt, with no rescue.
- **If two players meet the goal in the same frame** (versus): more layers cleared wins, then the lower stack; a full tie is a shared win (Tournament Flow may break it).
- **If every player is out in the same frame** (versus): the one with more layers cleared wins; then the lower stack.
- **If a twist adds an extra fail condition that triggers during a warning**: it is checked after the warning ends.

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | `over_limit()`, `stack_height()`, layer fill counts, target cells, Frozen |
| Layer Clearing | Hard | `layers_cleared`, `clear_resolved`, rescue wipe |
| Fall, Drop & Lock | Hard | Lock events; spawn control |
| Piece Spawner & Queue | Hard | Spawn-blocked report |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Level Data & Definition | Hard | Goal type, target, warnings, extra fail conditions |
| Rule-Twist Framework, Level-Specific Mechanics | Hard | Extra fail conditions, target and warning overrides |
| HUD | Hard | Goal, progress, warnings, clock |
| Scoring & Stars | Hard | Result, clock, counts |
| Campaign Structure, Arcade Mode, Tournament Flow, Mode / Minigame Randomizer, Tournament Minigames | Hard | Results and round rules |
| Items, Characters & Perks | Soft | Extra warnings |
| Game Feel & VFX, Audio, Mascot Reactions | Soft | Warning, win and loss events |

Board / Grid already lists this system; Layer Clearing and Fall, Drop & Lock name it; the Spawner's spawn-blocked report reaches it through the mode. Downstream GDDs must list it when written.

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| goal | clear / height / survive / shape | clear | data file (level) | What wins |
| T_level | 120–900 s | 480 | data file | Suggested N (F1) |
| t_piece | 4–12 s | 8 | data file | Heartbeat t_beat (Board F6) and suggested N (F1); update from playtests |
| N, H_target, T, M | per goal | F1 / `H_play − 2` / 180 s / level | data file (level) | Goal targets |
| height_coverage | 0.25–1.0 | 0.5 | data file | How "real" a tower must be (F2) |
| topout_rule | rescue / trim / lose | rescue (trim under M1, M2) | data file (level, mode, mechanic) | What a top-out does (rules 10a–10c) |
| warnings_max | 0–3 | 1 | data file (level, perk, item) | Forgiveness |
| rescue_margin | 0–4 | 2 | data file | Room after a rescue (F3) |
| countdown_ms | 0–5 000 | 3 000 | data file | Start pacing |
| time_limit | none or seconds | none | data file (level) | Optional extra fail condition |

`warnings_max = 0` makes `rescue_margin` inert.

## Visual/Audio Requirements

- **Goal card** at Intro: one icon and one number (e.g. a layer icon "× 3", a tower icon "10", a clock "3:00", a shape outline), no paragraphs.
- **Height goals**: a target line around the board at `H_target`, distinct from the danger-red height limit; it glows when reached.
- **Shape goals**: target cells drawn as soft marked outlines on the board (art bible: below the piece and ghost in the eye order), filling in as they are covered.
- **Warning**: the board edge flashes danger red (art bible §4), the mascot reacts, and the bottom `k` layers wipe with a distinct "rescue" effect (not the clear confetti); a warning token on the HUD breaks.
- **Win**: board-wide celebration in the biome's style — a big visual moment. **Loss**: a **funny failure**, never a harsh screen: the tower topples in a slapstick tumble (visual only), the biome's mascot reacts (wholesome, dry or cheeky, per the biome's humour), and the result card lands with a wink.
- **Trim**: cubes over the limit pop off the island with a comic boing and tumble away; **Rescue**: the wipe is presented as a gag (for example the mascot hauling the bottom layers away), with the logic still a silent wipe.
- The **biome mascot** reacts to warnings, trims, wins and losses (Mascot Reactions owns the animations).
- Audio events (owned by Audio): `goal_shown`, `countdown_tick`, `go`, `warning`, `rescue_wipe`, `goal_met`, `level_lost`, `player_out` (versus).

## Game Feel

The player should always know what they're aiming for and how close they are, and a top-out should feel like a scare, not a punishment. Targets: goal visible at all times; progress updates within one frame of a resolve; the warning sequence under 1.5 s; the result appears within 0.5 s of the deciding resolve. The default level length is about 8 minutes on the default board.

## UI Requirements

- HUD: goal icon and progress (F4), warnings left (tokens), level clock (if the level shows it), extra fail conditions if any.
- Intro goal card, countdown, warning banner, and the result screen (stars come from Scoring & Stars).
- 📌 **UX Flag — Level Goals & Fail States**: run `/ux-design` for the goal card, HUD goal widget and result screen before implementation.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 9–11; F2, F4; Edge Cases | Full layers, height limit, spawn zone, over limit, spawn blocked, `pieces_per_clear` |
| `design/gdd/layer-clearing.md` Core Rules 6, 8, 11, 12 | `layers_cleared`, clear events, slice shift for the rescue, over limit after the clear |
| `design/gdd/fall-drop-lock.md` Core Rules 14–16 | Lock events, no spawn after a result, first spawn timing |
| `design/gdd/piece-spawner-queue.md` Core Rule 9 | Spawn-blocked report |
| `design/gdd/touch-controls.md` States | Input Disabled on results |
| `design/gdd/game-concept.md` | Goal types, 5–15 min levels, 3-star times, Comeback Energy |
| `design/art/art-bible.md` §4 | Danger red for warnings and the height limit |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: 8 × 8 × 16 board, `H_play = 12`, 1 warning, margin 2.

**Goals**
1. [U] F1: `t_beat = 96`, `T_level = 480` → suggested N = 5; `t_beat = 42.7` → N = 11; `t_beat = 20` → N = 24; a level's own N replaces the suggestion, and only a t_beat outside the level type's band raises a validator warning.
2. [U] **GIVEN** clear N = 3, **WHEN** the 3rd layer clears, **THEN** the level is won after that resolve; a rescue wipe does not raise `layers_cleared`.
3. [U] F2: layer 9 with 33 of 64 filled and layer 10 with 20 → height 10; a single column of blocks to layer 11 with nothing else → height 0 (no layer at 50%).
4. [U] **GIVEN** a Survive level with T = 180 s, **WHEN** the clock reaches 180 s with no loss, **THEN** won; pauses and countdown do not count.
5. [U] **GIVEN** a Shape level, **WHEN** the last cell of M is filled, **THEN** won; with clearing on, a cleared target cell lowers progress.
6. [U] **GIVEN** an invalid target (N = 0, `H_target = 12`, empty M), **THEN** the level fails validation.

**Fail states**
7. [U] F3: s = 13 → k = 4, top ends at 9; spawn blocked with s = 15 → k = 6.
8. [I] **GIVEN** 1 warning, **WHEN** the stack goes over the limit, **THEN** the bottom k layers are removed by `wipe_bottom(k)` with no hooks or effects firing, `layers_cleared` is unchanged, the warning count becomes 0, and the next piece spawns.
8a. [U] **GIVEN** `topout_rule = lose`, **WHEN** the stack is over the limit after the clears, **THEN** the level is lost on that lock, whatever `warnings_max` says.
8b. [U] **GIVEN** a lock that goes over the limit and also clears a layer that brings the stack back under, **THEN** no top-out happens.
9. [U] **GIVEN** no warnings left, **WHEN** a top-out happens, **THEN** the level is lost and no spawn follows.
10. [U] **GIVEN** `warnings_max = 0`, **THEN** the first top-out loses.
11. [U] **GIVEN** the goal is met and the stack is over the limit in the same resolve, **THEN** the level is won.
12. [U] **GIVEN** a rescue that cannot clear the stack under the limit, **THEN** the warning is used and the level is lost.
13. [U] **GIVEN** an extra time-limit fail of 120 s, **WHEN** the clock reaches 120 s, **THEN** lost (no warning used unless the level says so).
13a. [U] **GIVEN** `topout_rule = trim`, `H_play = 12`, **WHEN** a piece locks with cubes at y = 11 and y = 12, **THEN** the y = 12 cube is removed, the y = 11 cube stays, `layers_cleared` and score are unchanged, no warning is used, and play continues.
13b. [U] **GIVEN** trim and a Height goal met by the same lock that pokes over the limit, **THEN** the level is won.

**Flow and clock**
14. [I] **GIVEN** a level start, **THEN** Intro → 3 s Countdown → first spawn; the clock starts at the first spawn.
15. [U] **GIVEN** pause, warning or result, **THEN** the clock stops.
16. [I] **GIVEN** a result, **THEN** the board is Frozen, input is Disabled and the result, clock, layers cleared, warnings used and pieces placed are sent on.

**Versus**
17. [I] **GIVEN** two players, **WHEN** player A meets the goal first, **THEN** A wins the round.
18. [I] **GIVEN** player B tops out with no warnings, **THEN** B is out, A keeps playing, and A wins if alone.
19. [U] **GIVEN** both meet the goal in the same frame, **THEN** more layers cleared wins, then the lower stack, then a shared win.

**Presentation**
20. [U] F4: N = 3, 2 cleared → 0.67; height 5 of 10 → 0.5.
21. [I] **GIVEN** any resolve, **THEN** the HUD progress updates in the same frame.
22. [M] **GIVEN** the reference phone, **THEN** the goal card is readable in under 2 s with no text beyond a number, and the warning sequence takes ≤ 1.5 s.
23. [M] **GIVEN** a playtest of 5 default levels, **THEN** the median level length is 5–12 minutes and the median time between clears is inside each level type's t_beat band (validates `t_piece`, η and N).

## Open Questions

- **Rescue style**: is a bottom wipe the right warning, or should it remove the top pieces instead, or only the layers over the limit? Prototype both. (Build races and shape levels use trim instead; rule 10b.)
- **Trim feel**: does popping cubes off read as "too high" rather than a bug? Prototype with meadow_05.
- **Silent rescue wipe (rule 8), open to playtest**: designer default 2026-10-09 (no effects or chains during a rescue). The fun comes from how it is shown, not from extra rules.
- **Starting N (F1)**: there is no fixed clears-per-level pacing; F1 is only a fallback when a level gives no N. The systems-designer owns the pacing tables.
- **`t_piece` = 8 s**: replace with measured placement times from the Touch Controls prototype; t_beat (Board F6) and the suggested N follow.
- **Height coverage 50%**: is that the right line between a real tower and a spire? Bot simulation and playtest.
- **Shape goals with clearing on**: should filled target cells "stick" once filled? Default no; decide with the first shape level.
- **Versus round rules**: first to goal vs. last standing vs. score — Tournament Flow and Mode / Minigame Randomizer own this; this GDD only sets the default.
- **Retry cost**: is a retry free in the campaign? Campaign Structure and Points System.
