# Layer Clearing

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10 (against ADR-0001, ADR-0002, ADR-0004, ADR-0011)
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Comeback Energy

## Summary

Layer Clearing is the payoff of the game: when a piece locks and completes a layer, the layer vanishes in a ripple and the tower above settles down to fill the gap. By default the layers above drop as whole slices, so the tower keeps its shape and nothing chain-reacts; a level can switch to cascading or chunk-falling settles for wilder play. Several full layers clear in a bottom-to-top ripple, and a level or twist can switch clearing off altogether.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Board / Grid, Fall, Drop & Lock`

## Overview

The Board reports which layers are full; it never removes anything. Layer Clearing is the system that acts on that report. After every lock (and after any other change that fills a layer), it takes the board's Resolving state and runs a short, fixed routine: find the full layers, fire each cleared cell's effects, remove the cubes, and settle the stack above. Logically the whole clear happens at once and the board is back to Live in a moment; visually the cleared layers dissolve one after another from the bottom up in a quick staggered ripple, and then the rest of the tower drops. The default settle is a **slice shift**: every layer above a cleared one moves down by the number of cleared layers beneath it, as a rigid slice, so the player can see exactly where everything will end up. Levels can pick other settle modes (**cascade**, where loose cubes fall individually and may trigger chain clears; **chunks**, where connected groups fall as units) or turn clearing off, for build-up races and other twists. Clears raise the layers-cleared count that drives the gravity ramp, goals and score, and they announce what was cleared and who owned it, so items, attacks and effects can react. This serves *The Block Is the Constant* (clearing is the heartbeat), *Readable Chaos* (the default settle never surprises), and *Comeback Energy* (clears are the moment the trailing player swings the round). All values are starting defaults.

## Detailed Design

### Core Rules

**When it runs**
1. A clear check runs at **S3** of the **per-lock sequence** owned by Fall, Drop & Lock (rule 15, step ids per ADR-0011 §3: after the P3 lock veto, S1 lock and S2 `on_lock`; before S4a structure changes, S4b `on_resolve_end`, the goal check and the top-out check), and **once more at S4c** if an S4b `on_resolve_end` subscriber wrote or removed content (`on_clear` fires as usual; S4c clears count normally; `on_resolve_end` does not re-run, so a layer still full after S4c waits for the next check). Content written by a rule outside the per-lock sequence (an `on_tick` write, an item placing cubes) is checked at the next lock's S3. A vetoed lock (P3) runs no clear check. The board is in **Resolving** for the whole routine. This GDD does not define what happens after the routine; the per-lock sequence does.
2. If `clear_enabled` is off (a level, twist or mechanic switched it off), the check does nothing: full layers simply stay on the board. They are still reported by the board for goals that count them.
2a. **Rescue entry point: `wipe_bottom(k)`.** Level Goals calls this for a `rescue` top-out (Level Goals rule 8). It removes the bottom `k` layers (along the down axis) and settles the stack with a **slice shift** (F1), whatever the level's `collapse` and `clear_enabled`. It is a **silent wipe**: no `on_clear` hooks, no status or bomb effects, no chain rounds, and it does **not** add to `layers_cleared` (or any clear count), the gravity ramp, the score or the goal. It emits only `rescue_wiped(k, n_cubes)` for presentation. It is not called by anything else. (Its board deltas need their own cause so the view does not play clear effects: ADR-0002 lists no `RESCUE` cause yet, an open amendment.)
3. Only layers perpendicular to the board's current **down axis** are checked ("layer" and "full" are defined by Board / Grid), for any of the 6 down directions.

**The routine**
4. **Find.** The level's **`clear_detector`** (slot `clear.detector`, ADR-0004; `collapse_mode` is slot `clear.collapse`) decides what is cleared. Default `layer`: ask the board for `full_layers()` and sort them from the bottom up (along the down axis); a layer with no active cells is never full. Other detectors are per-level options defined in Level-Specific Mechanics (`row` M8, `colour_connect` M5, `colour_bridge` M6, mono layer M7, and later catalogue entries); each returns a set of cells to clear, and rules 5–12 apply to those cells the same way. If nothing is found, the routine ends with `t_resolve = 0`.
5. **Notify.** For each cell in a full layer, fire the `on_clear(cell, content)` hook before removal, so status effects (burning, honey, bomb tags and the like) and objects can react. Hooks run in layer order, bottom to top, in cell order.
6. **Remove.** All contents in every full layer are removed as one logical step (blocks, obstacles and objects alike), with the exceptions Obstacle Clearing defines: a layer held by a breakable obstacle with hit points left is deferred, and stone pillar cells stay in place. The cleared Blocks' records (`{shape_id, piece_instance_id, owner, tags, status}`, Board / Grid rule 6) are kept for the events below; hue is derived from `shape_id` and the art set when the effect is drawn.
7. **Settle.** The stack above is settled by the level's **`collapse`** mode (`collapse_mode` in level data; rules 8–10). **Slice is the default**; cascade (and chunks) are set per level or by a level mechanic.
8. **Slice shift (default).** Each remaining layer moves down by the number of cleared layers below it (Formulas F1), all contents together with their flags and status. The order of layers is preserved. Slice shift never creates a new full layer, so it never chains.
9. **Cascade (level option).** After removal, every cube that is not supported falls one layer at a time, all unsupported cubes together, one layer per `cascade_step_ms`, until nothing can fall. A cube is *supported* if the cell below it is the floor or holds solid content. Then the board is checked again: if layers are now full, they clear (the next *round*, chain index +1) and the settle repeats. Rounds stop at `chain_max`; any layers still full are handled by the next clear check.
10. **Chunks (level option).** After removal, Blocks are grouped into face-connected **chunks**; a chunk is supported if any of its cubes rests on the floor or on a supported chunk. Unsupported chunks fall together one layer per `cascade_step_ms` until all are supported; chain rounds work as in rule 9.
11. **Events.** For each cleared layer the routine emits `layer_cleared(layer, cubes[], owners[], round)`; at the end it emits `clear_resolved(n_layers, n_cubes, rounds)`. It also adds `n_layers` to the level's `layers_cleared` count (which feeds the gravity ramp in Fall, Drop & Lock and goals). With a non-layer `clear_detector`, the mechanic defines what one clear counts as (a row, a pop, a bridge) and that count is used instead. There is no fixed number of clears per level: how many clears happen is up to the player.
12. **Return.** The routine ends and control returns to the per-lock sequence (S4a, S4b `on_resolve_end`, S4c, goal check, then the top-out check). `over_limit()` is therefore read **after** the routine, so a clear can bring a too-high stack back under the limit.

**Pacing and presentation (logic is instant, visuals are staggered)**
13. The logical result of rules 4–8 happens in one step on the lock tick, at the start of Resolving; the sim then stays in Resolving for `t_resolve_ms` (F2, plus the S4c round when S4c clears) and reports that length in the `resolve_started` event (ADR-0001, ADR-0011). The sim never waits for the view. The visuals then play over `t_resolve` (Formulas F2): the cleared layers dissolve one after another from the bottom up, `clear_stagger_ms` apart, each taking `clear_anim_ms`; then the layers above drop together over `clear_settle_ms`. The player cannot act on the board during Resolving (the next piece has not spawned), so the visuals never block control.
14. A long ripple is capped at `resolve_max_ms`; the stagger shrinks to fit (F2).

**Rules from outside**
15. The Rule-Twist Framework and Level-Specific Mechanics can turn clearing off, change `collapse_mode`, change which layer axis is used (via the down axis), or veto clearing of a particular layer or cell. They go through the framework, never write to the board directly.

### States and Transitions

Per board:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Idle** | Nothing to resolve | Level start; routine finished | A lock or outside change → Checking |
| **Checking** | Looking for full layers | Lock or change | None found → Idle; found → Clearing |
| **Clearing** | Hooks run, cubes removed, stack settled (logical) | Full layers found | Done → Animating |
| **Animating** | Ripple and settle visuals play (`t_resolve`) | Logical clear done | Visuals done → Idle (or Checking for the next chain round) |
| **Frozen** | Timers stopped | Pause, mode ends | Resume (mode end: logical result stands, visuals skip) |

The Board is Resolving from Checking until Idle.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid | ↔ | Reads `full_layers()`, `active_cells_in_layer`, down axis; removes and moves contents (`clear`, `set`) during Resolving |
| Fall, Drop & Lock | FDL → | Lock event starts the check; Layer Clearing's end returns the board to Live; `t_resolve` feeds the piece cycle time |
| Level Goals & Fail States | ↔ | `layer_cleared`, `clear_resolved`, `layers_cleared`; Goals calls `wipe_bottom(k)` for a rescue; `over_limit()` evaluated after the routine (per-lock sequence) |
| Rule-Twist Framework, Twist Library | ↔ | `clear_enabled`, `collapse_mode`, `on_clear` hooks, vetoes |
| Level-Specific Mechanics | ↔ | May contradict this system ("full layers do not clear here"); the framework's priority order decides |
| Obstacles, Obstacle Clearing | ↔ | Contents with their own clear behaviour (provisional) |
| Block Status Effects | ↔ | `on_clear` effects |
| Scoring & Stars | LC → | Cleared layer and cube counts, chain rounds |
| Items, Characters & Perks, Local Multiplayer | LC → | Owners of cleared cubes and layers cleared (for attacks, comeback items) |
| Game Feel & VFX, Audio | LC → | Per-layer and final events for the ripple, dissolve and settle |
| Physics Mode | ↔ | May replace the whole system |

## Formulas

All values are starting defaults. Time in milliseconds. Layers are indexed from the bottom (0) along the down axis.

### F1. Slice shift

The slice_shift formula is defined as:

`y' = y − |{ c ∈ C : c < y }|` for every remaining layer `y ∉ C`, where `C` is the set of cleared layer indices

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| C | set of int | 0–`board_height − 1`, up to `board_height` entries | calculated (Board `full_layers()`) | Cleared layer indices |
| y | int | 0 to `board_height − 1`, y ∉ C | calculated | A remaining layer's index before the clear |
| y' | int | 0 to `board_height − 1 − |C|` | calculated | Its index after the clear |

**Output Range:** `y' ≤ y`; relative order is preserved; the stack height drops by `|C|`. **Example:** C = {2, 5}: layer 3 → 2, layer 4 → 3, layer 6 → 4, layer 7 → 5; a stack that reached layer 9 now reaches layer 7.

### F2. Resolve time

The resolve_time formula is defined as:

`t_resolve = clear_anim_ms + (n − 1) × stagger_eff + clear_settle_ms` for `n ≥ 1` cleared layers (0 for `n = 0`);
`stagger_eff = min(clear_stagger_ms, (resolve_max_ms − clear_anim_ms − clear_settle_ms) / (n − 1))` for `n ≥ 2`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n | int | 0–`board_height` | calculated | Layers cleared in this round |
| clear_anim_ms | int | 100–600 | data file | Time for one layer to dissolve; default 250 |
| clear_stagger_ms | int | 0–200 | data file | Delay between layers; default 100 |
| clear_settle_ms | int | 100–500 | data file | Time for the stack to drop; default 200 |
| resolve_max_ms | int | 500–2000 | data file | Cap on `t_resolve`; default 1000 |

**Output Range:** 0 to `resolve_max_ms`; the `clear_settle_ms` term is dropped when nothing sits above the cleared layers. **Example:** n = 1 → 250 + 200 = 450 ms; n = 2 → 550 ms; n = 4 → 250 + 300 + 200 = 750 ms; n = 8 → uncapped 1150, so `stagger_eff = (1000 − 450) / 7 ≈ 78.6` and `t_resolve = 1000` ms. For cascade and chunks, each round adds its own `t_resolve` plus `fall_steps × cascade_step_ms`; at most `chain_max` rounds.

### F3. Cubes cleared

The cubes_cleared formula is defined as:

`n_cubes = Σ over y ∈ C of (contents in layer y)`; for a layer of only blocks, this equals `active_cells_in_layer(y)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| active_cells_in_layer(y) | int | Board F1 range (default 64) | calculated (Board) | Cells needed to fill layer y |
| n_cubes | int | 0 to `board_capacity` | calculated | Cubes removed in the round |

**Output Range:** 0 to the board's capacity. **Example:** default 8 × 8 board, 2 layers cleared → 128 cubes (about 32 average-size pieces' worth; the Board's F2 expects about 21 pieces per layer on average, since layers are built over time).

### F4. Cascade and chunk time bound

The cascade_time formula is defined as:

`t_resolve_total ≤ chain_max × ( t_resolve + max_fall × cascade_step_ms )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| chain_max | int | 1–20 | data file | Rounds before the routine stops; default 10 |
| max_fall | int | 1 to `board_height` | calculated | Greatest number of layers any cube falls in a round |
| cascade_step_ms | int | 80–400 | data file | Time per falling layer; default 180 |

**Output Range:** only for the optional cascade and chunk modes; bounded by the worst case. **Example:** one round with max_fall 3 → 450 + 3 × 180 ≈ 1 s; 10 rounds of the same ≈ 10 s absolute worst case (rare), after which the routine ends and the board returns to Live.

## Edge Cases

- **If no layer is full after a lock**: the routine ends at once; the board stays Live; `t_resolve = 0`.
- **If several layers are full but not adjacent**: all are cleared in one round; F1 handles the gaps; the ripple goes bottom to top.
- **If the locking piece itself completes layers in the spawn zone** (above the height limit): they clear like any others; `over_limit()` is evaluated afterwards, so a clear can save the player.
- **If `clear_enabled` is off**: nothing is removed; full layers stay and are still reported to goals.
- **If a layer has cubes of several owners** (versus junk, shared boards): all are removed; the event lists every owner.
- **If contents in a full layer have `fills_layer = false`** (an object that doesn't count): they are removed with the layer (default; exceptions come from Obstacle Clearing).
- **If an `on_clear` hook adds content to a cleared layer or changes fullness**: its changes apply after the settle and may start another round; the total rounds are limited by `chain_max`.
- **If a hook vetoes a layer**: that layer is skipped this round and remains full; other layers clear.
- **If the board is masked**: fullness uses only active cells; slices move along the down axis and keep their footprint position.
- **If the stack above is empty** (the top layer cleared): nothing settles; `settle` time is skipped (F2 still uses `clear_settle_ms` only when something moves).
- **If a twist wants to flip the down axis or resize the board**: the request is queued and applied at S4a, after this routine's S3 pass and before `on_resolve_end` (ADR-0011); layers are then defined by the new down axis.
- **If an `on_resolve_end` hook fills a layer** (a hatched chick, a belt shift): the S4c pass clears it once; any layer still full afterwards waits for the next lock.
- **If the game is paused during Animating**: visuals freeze and resume; the logical state is unchanged.
- **If the mode ends (win or loss) during Animating**: the logical clear stands; visuals jump to the end state.
- **If cascade or chunk mode reaches `chain_max`**: the routine stops, the board returns to Live, and any layers still full are cleared at the next check.
- **If reduced motion is on**: the dissolve is replaced by a fade, shake and flash are off; timings may shorten but logic is the same.
- **If a clear leaves `layers_cleared` higher than a level's cap** (a goal): Level Goals decides (win check runs after `clear_resolved`).
- **If two players clear on their own boards at the same time** (local versus): each board resolves independently.
- **If the level uses Physics Mode**: this system does not run; Physics Mode defines its own clearing (if any).

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | `full_layers()`, `active_cells_in_layer`, down axis, content removal and moves during Resolving |
| Fall, Drop & Lock | Hard | Lock event starts the check; returns the board to Live |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Level Goals & Fail States | Hard | `layer_cleared`, `clear_resolved`, `layers_cleared`; post-clear `over_limit()` |
| Rule-Twist Framework | Hard | `clear_enabled`, `collapse_mode`, `on_clear` hook, vetoes |
| Obstacle Clearing | Hard | Extends rule 6 for obstacle exceptions |
| Scoring & Stars | Soft | Layer and cube counts, rounds |
| Block Status Effects | Soft | `on_clear` effects |
| Items, Characters & Perks, Local Multiplayer Setup | Soft | Owners and counts for attacks and comebacks |
| Game Feel & VFX, Audio | Soft | Events for ripple and settle |
| Fall, Drop & Lock | Soft | `t_resolve` and `layers_cleared` (gravity ramp) |

Board / Grid and Fall, Drop & Lock already name Layer Clearing; the remaining downstream GDDs must list it when written.

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| clear_enabled | true / false | true | data file (level, twist) | Whether full layers clear; false makes every other knob inert |
| clear_detector | layer / row / colour_connect / colour_bridge / mono / … | layer | data file (level, mechanic) | What counts as a clear (rule 4; options in Level-Specific Mechanics) |
| collapse_mode | slice / cascade / chunks | slice | data file (level) | How the stack settles; cascade and chunks add chains and ignore F1 |
| clear_anim_ms | 100–600 | 250 | data file | Length of one layer's dissolve (F2) |
| clear_stagger_ms | 0–200 | 100 | data file | Ripple speed between layers (F2) |
| clear_settle_ms | 100–500 | 200 | data file | Time for the stack to drop (F2) |
| resolve_max_ms | 500–2000 | 1000 | data file | Longest pause a big clear can cause (F2) |
| cascade_step_ms | 80–400 | 180 | data file | Time per falling layer (cascade, chunks) |
| chain_max | 1–20 | 10 | data file | Safety limit on chain rounds |

`clear_stagger_ms` and `resolve_max_ms` interact: a larger stagger only matters until the cap is reached; `cascade_step_ms` and `chain_max` are inert in slice mode.

## Visual/Audio Requirements

- **Clear ripple**: each full layer flashes in its blocks' own hues, then dissolves into soft confetti puffs (painterly, art bible §6 juice), starting at the bottom layer and rippling upward with a small stagger; the layers' outlines stay in ink until they vanish so the player sees which layers cleared.
- **Settle**: the remaining slices drop together with a quick squash on landing; cascade and chunk modes show individual cubes or chunks falling with a short ease and squash.
- **Camera**: a small translation-only punch scaled by the number of layers (off with reduced motion); the camera never zooms or rotates.
- **Readability**: nothing else on the board animates during the ripple; the landing ghost and spawn are not shown until Resolving ends (Pillar 2).
- **Chain rounds**: each round uses a rising colour accent and sound pitch (shape-coded as well as colour-coded), never the effect accent colours reserved for buffs and debuffs (art bible §4).
- Audio events (owned by Audio): `layer_cleared` (per layer, pitch rising bottom to top), `clear_resolved` (a final chord that grows with `n_layers`), `settle_thunk`, `chain_round` (cascade, chunks).

## Game Feel

Clearing should be the most satisfying moment of the loop: a clean ripple and a firm settle, over before the player gets impatient. Targets: logical result on the lock tick; first dissolve starts within one frame of the `resolve_started` event; single-layer clear ≤ 450 ms; any clear ≤ 1 s in slice mode; the rising pitch makes a multi-clear feel bigger without extra waiting. Reduced motion keeps the same timing with fades instead of motion.

## UI Requirements

None directly. The HUD shows the layers-cleared count and goals (Level Goals & Fail States, HUD); any "multi-clear" callouts are Game Feel & VFX and Mascot Reactions.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` Core Rules 3, 6, 7, 9, 10; Query contract; States; Edge Cases; F2 | Full layers, `fills_layer` / `solid` flags, down axis, Resolving state, `active_cells_in_layer`, masked boards, pieces per clear |
| `design/gdd/fall-drop-lock.md` Core Rules 14–16; F1, F5 | Lock event, Waiting after Resolving, `t_resolve` in the cycle time, `layers_cleared` in the gravity ramp |
| `design/gdd/piece-set.md` Core Rules 5–6 | Tags carried by blocks (read by `on_clear` hooks) |
| `design/gdd/game-concept.md` | Pillars; clearing as the heartbeat; "layer-clear with/without obstacles" twist |
| `design/gdd/systems-index.md` | Rule-Twist Framework resolves conflicts when a level mechanic contradicts clearing |
| `design/art/art-bible.md` §4, §6 | Colour accent rules; painterly juice |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: 8 × 8 × 16 board, `collapse_mode = slice`, anim 250, stagger 100, settle 200, cap 1000.

**Detection and removal**
1. [U] **GIVEN** no full layer, **WHEN** a piece locks, **THEN** nothing is removed, `t_resolve = 0`, and the board stays Live.
2. [U] **GIVEN** layer 3 gets its 64th cube from a lock, **THEN** the routine runs, layer 3 is emptied, and the board is Resolving until it ends.
3. [U] **GIVEN** layers 2 and 5 become full by one lock, **THEN** both are cleared in the same round and ordered bottom to top.
4. [U] **GIVEN** `clear_enabled = false`, **THEN** nothing is removed, the full layers remain and the board still reports them.
5. [U] **GIVEN** a masked board with 60 active cells in a layer, **THEN** it is full when the 60 active cells hold fills-layer content.
6. [U] **GIVEN** a full layer containing a non-filling object, **THEN** the object is removed with the layer.

**Slice shift**
7. [U] F1: C = {2, 5} → layers 3, 4, 6, 7 move to 2, 3, 4, 5; relative order and each cube's flags and status are preserved.
8. [U] **GIVEN** slice mode, **THEN** no new full layer can appear and no chain round starts.
9. [U] **GIVEN** a clear of the top layer, **THEN** nothing moves and the settle phase is skipped.
10. [U] **GIVEN** a stack to layer 9 and two layers cleared, **THEN** `stack_height()` is 7.

**Timing**
11. [U] F2: n = 1 → 450 ms; n = 2 → 550; n = 4 → 750; n = 8 → 1000 with `stagger_eff ≈ 78.6`.
12. [I] **GIVEN** a clear, **THEN** the board is Resolving for `t_resolve` and Fall, Drop & Lock calls `spawn()` only after `t_resolve` plus the entry delay.
13. [U] **GIVEN** pause during Animating, **THEN** the visuals freeze and resume without changing the logical state.

**Hooks, events and counts**
14. [U] **GIVEN** a full layer with a block carrying an `on_clear` effect, **THEN** the hook fires before the cube is removed, in layer then cell order.
15. [U] **GIVEN** a hook vetoes layer 5 of {2, 5}, **THEN** layer 2 clears, layer 5 stays full, and F1 uses C = {2}.
16. [U] **GIVEN** a clear, **THEN** `layer_cleared` is emitted once per layer with its cubes and owners, `clear_resolved` once, and `layers_cleared` rises by n.
17. [U] F3: two cleared 8 × 8 layers → `n_cubes = 128`.
17a. [U] **GIVEN** `wipe_bottom(3)` on a stack with a bomb-tagged Block in layer 1 and `collapse_mode = cascade`, **THEN** layers 0–2 are removed, the rest slice-shift down 3, no `on_clear` hook fires, no chain round runs, and `layers_cleared` is unchanged.
17b. [U] **GIVEN** `clear_detector = row`, **WHEN** a lock completes one row, **THEN** only that row's cells are removed and the clear count rises by 1 (the mechanic's unit).
18. [I] **GIVEN** the lock completes a layer above the height limit, **WHEN** the clear brings the stack below it, **THEN** `over_limit()` evaluated afterwards is false.

**Optional modes**
19. [U] **GIVEN** `collapse_mode = cascade` and cubes left unsupported after a clear, **THEN** they fall one layer per `cascade_step_ms` until supported, and a newly full layer clears in round 2.
20. [U] **GIVEN** `chunks`, **THEN** a face-connected group falls as a unit and rests on the first support.
21. [U] **GIVEN** a chain that would exceed `chain_max = 10`, **THEN** it stops at round 10, the board returns to Live, and the remaining full layers clear at the next check.

**Robustness**
22. [U] **GIVEN** a down-axis flip requested before or during a lock's resolve, **THEN** it applies at S4a, after the S3 clear and before `on_resolve_end`.
22a. [U] **GIVEN** an S4b hook that completes a layer, **THEN** S4c clears it once with `on_clear` firing and `layers_cleared` rising; **GIVEN** no S4b write, **THEN** S4c does not run; **GIVEN** a lock vetoed at P3, **THEN** no clear check runs.
23. [I] **GIVEN** two boards in local versus, **THEN** each resolves independently with its own events.
24. [I] **GIVEN** reduced motion, **THEN** no shake or confetti plays; layers fade out; timings are unchanged.
25. [M] **GIVEN** the reference phone, **THEN** a 4-layer clear reads clearly (which layers cleared and where the stack lands) and ends within 1 s.

## Open Questions

- **Obstacles and survivors**: answered in Obstacle Clearing (layers with surviving rocks are deferred; pillars stay).
- ~~**Over-limit timing**~~: resolved — after the clear, in the per-lock sequence (Fall, Drop & Lock rule 15).
- **Silent rescue wipe (rule 2a), open to playtest**: designer default 2026-10-09 is that a rescue wipe fires no effects or chains, so it reads as a calm second chance. If it feels flat, the wacky moment can come from presentation (the biome mascot hauling the bottom away) rather than from rule effects.
- **Cascade and chunk balance**: both modes are provisional until a level wants them; chain rules, scoring and support rules need a prototype pass.
- **Versus attacks**: do multi-layer clears send junk or trigger comeback items, and by how much? Items and Tournament Flow to decide; this system only reports owners and counts.
- **Ripple direction with a flipped down axis**: bottom-to-top follows the current down axis; confirm it reads well when the view is upside down.
- **Reduced motion timing**: shorten `clear_anim_ms` when reduced motion is on, or keep it the same? Decide in Onboarding & Accessibility.
- **Ghost during Animating**: confirm that hiding the ghost and spawn during Resolving doesn't feel like a long pause for fast players.
