# Meadow Candidate Atoms: Full Rules

> **Status**: In Design (for review)
> **Author**: game-designer (systems rigour), orchestrated run, 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Covers**: PL03 wobble · SP28 dandelion puff · SP22 growing sprout · SP26 fog ghost · SP21 hatching egg · SP31 picnic ants · WO11 Pip's catch. §9 checks the Meadow's designed events (EV01–EV05, PL01, M1, M2).
> **Sources**: `design/levels/meadow.md` (§1, §6, §7, §10), `design/gdd/mechanics-module.md`, `twist-library.md`, `level-specific-mechanics.md`, `fall-drop-lock.md` (rule 15), `layer-clearing.md`, `board-grid.md`, `rule-twist-framework.md`, `level-goals-fail-states.md`, `production/orchestration/core-loop-rules-audit.md` (adopted defaults F1–F7), ADR-0001, ADR-0004, `docs/architecture/implementation-plan.md`.
> **Every number here is a tunable default.** Meadow values come from `meadow.md`, except where §10 recommends a change.

**ADR-0011 note.** No `adr-0011*` file exists in `docs/architecture/` (checked 2026-10-10). The tree sketches follow the brief: a beehave tree per behaviour, deterministic, acting through the sim. Two points need the ADR owner to decide (Open Questions 1–2).

---

## 0. Common rules (all seven atoms)

### 0.1 Where each atom runs in the sim

The tick order comes from ADR-0001 and audit F2. The per-lock sequence is FDL rule 15.

| Phase | When | Atoms that act here |
|---|---|---|
| **P0 commands** | Start of tick, in arrival order (`on_command`) | SP26 (a hard drop on an intangible ghost solidifies it first) |
| **P1 `on_tick`** | After commands | none (EV01 gusts live here) |
| **P2 gravity** | One fall step at most | SP26 (collision ignores content while intangible) |
| **P3 lock veto** | Before cubes are written: `can(&"piece.lock")` (ADR-0001 lock veto) | WO11 catch; SP26 solidify-at-lock |
| **S1 lock** | Cubes written | — |
| **S2 `on_lock`** | Before the clear check | SP28 split + settle; PL03 counts overhangs |
| **S3 clear** | Layer Clearing routine; `on_clear` per cell | SP21 egg bonus; SP31 ants shooed |
| **S4a structure** | **New (proposed)**: queued down-axis / mask requests are applied and settled | EV03 flip |
| **S4b `on_resolve_end`** | Subscribers in ascending F2 priority | SP22 grow, SP21 hatch, SP31 ants move, PL03 slip, EV04 mark/place, EV05 shift |
| **S4c post-clear pass** | **New (proposed)**, see 0.2 | — |
| **S5–S10** | Goal, top-out, outcome, entry delay, spawn | — |
| **`on_spawn`** | Spawner, before the piece appears | SP28 stores its cut seed; SP26 sets intangible |

### 0.2 New rule: post-hook clear pass (S4c)

Layer Clearing rule 1 says a clear check runs whenever a rule changes the contents. But no step in rule 15 runs it after `on_resolve_end`, and mushrooms, sprouts, chicks, ants and slips can all complete a layer there.

**Default:** after S4b, if any S4b subscriber wrote or removed content, the clear routine runs **once** more (S4c).
- Its clears count normally (goals, gravity ramp, flip counters, score).
- `on_resolve_end` does **not** run again, so there is no loop.
- A layer that is still full afterwards clears at the next check.
- `t_resolve` adds the extra round's F2 time.

### 0.3 Deterministic choices

- Every random choice uses the rule's own stream: `api.rng()` (ADR-0006, framework rule 13). There is never more than one draw per decision.
- Candidates are sorted canonically first: layer index along the down axis (ascending), then x, then z. Then `i = rng.randi_range(0, n − 1)`.
- If `n ≤ 1`, there is **no draw**, so the stream does not depend on how a container happens to iterate.
- Beehave nodes that use time or global randomness (RandomSelector, Cooldown/Delay on wall time) are **forbidden**. Counters live in the blackboard and count locks or sim ms (`api.now_ms()`).

### 0.4 Terms

| Term | Meaning |
|---|---|
| down / up | Along the board's current down axis / against it (Board rule 3). After a flip, "up" flips too. |
| `locks` | Completed locks on this board (S1 reached). **A lock that is caught (WO11) or vetoed is not a lock**: no `on_lock`, and no counter advances. |
| empty | `get(cell)` returns Empty. Overlay content does not count as empty. |
| top-surface cell | As defined in Twist Library T4 rule 15. |
| Block | A locked piece cube, or a starter block from level data (`shape_id` `starter`). |

### 0.5 New content types

| Type | Atom | `solid` | `fills_layer` | Moved by slice, flip settle, conveyor | Edible by ants | Counts for `over_limit()` | Covers an M2 target |
|---|---|---|---|---|---|---|---|
| `sprout` (`sprout_id`) | SP22 | true | true | yes | no | yes | yes |
| `egg` (`egg_id`, `age`) | SP21 | true | true | yes | no | yes | yes |
| `chick` | SP21 | true | true | yes | no | yes | yes |
| `ant` (`ant_id`, `hungry`) | SP31 | true | true | yes | — | yes | yes |
| (split halves) | SP28 | written as normal Blocks | | | yes | | |

### 0.6 Rule layers and priority (proposal for ADR-0004 §2)

ADR-0004 puts specials, living blocks and mascot atoms in layers `content` and `mascot`, but gives them no rank.

**Proposed ranks:** `mascot` = 1, `content` = 2, `twist` = 3, `level_mechanic` = 4.

The resulting S4b order is: ants, eggs and sprouts → mushrooms and wobble → the belt. Living blocks therefore act first, the mushroom picks its cell on the final surface, and the conveyor moves everything last.

PL03 wobble is a `twist` (it is a rule, and it uses one of meadow_05's 2 twist slots).

### 0.7 Tree convention (all sketches)

- `bb.phase` is set by the behaviour's `handle(hook, ctx, api)` before it ticks the tree once for that hook call. Every tree is a root **Selector** of one **Sequence** per phase it uses.
- `C` = condition leaf, `A` = action leaf.
- Actions write only through `RuleApi`. Player intent arrives as `SimCommand`.
- State is in the blackboard and is reset on `on_level_start` (a retry gets a fresh seed and fresh state).

---

## 1. PL03 Wobble (meadow_05 "Tall Tower")

### Overview

A grid-sim sway meter, not Physics Mode. Each lock adds the number of **new overhang cubes** it made, and a well-supported lock calms the tower. When the meter reaches `wobble_max`, the piece that just locked **slips** one cell toward the heavier side of the tower and slides down until it lands. If the slip would take it off the island, it pops off.

### Detailed rules

| # | Rule |
|---|---|
| W1 | **Overhang cube of a lock**: a cube `c` of the just-locked piece where `c + down` is an empty cell inside the board, or an inactive cell. Floor cells and cells holding the piece's own cubes are support. |
| W2 | **S2**: `o = ` the number of overhang cubes of this lock. |
| W3 | **Meter** (F1): if `o > 0`, `m += o`. Otherwise `m = max(0, m − wobble_decay)`. |
| W4 | **S4b**: if `m ≥ wobble_max`, run a **slip** (W5–W8) on the just-locked piece. Then set `m = 0` whatever the slip result. |
| W5 | **Direction** (F2): the heavier side of all solid content on the board. The dominant axis wins, x on a tie. If both moments are 0, use the piece's own centroid. If that is 0 too, nothing slips (the tower is balanced) and `m = 0`. |
| W6 | **Off the island**: if any target cell `cell + dir` is outside the footprint or inactive, the whole piece **pops off**. Its cubes are removed: not a clear, no `on_clear`, event `wobble_popoff`. |
| W7 | **Blocked**: if any target cell holds content that is not the piece's own, there is no move ("creak and hold"), event `wobble_hold`. |
| W8 | **Slip**: move all the piece's cubes by `dir` as one rigid group. Then drop it rigidly along down until any cube is supported (the FDL F3 sweep). Event `wobble_slip`. |
| W9 | Slips and pop-offs never add to `m`. Cubes left at or above `H_play` are trimmed at S8 by the level's `topout_rule`, so the meadow text "pops off over the danger line" comes from trim. |
| W10 | **Telegraph**: when `m ≥ wobble_max − wobble_warn`, the tower sways (view) and the HUD meter turns warm. The meter is always visible in the rule strip. |
| W11 | Tags `grid floor`: incompatible with EV03, CV15 and CV16 (validator). |

### Formulas

**F1 meter.** `m' = m + o` if `o > 0`, else `max(0, m − wobble_decay)`. A slip is due when `m' ≥ wobble_max`.

| Var | Type | Range | Default (Meadow 05) |
|---|---|---|---|
| o | int | 0–8 | calculated (W1) |
| wobble_max | int | 2–20 | 6 |
| wobble_decay | int | 0–3 | 1 |

*Example*: a Big Cube is set half over a gap (2 bottom cubes hang, so `o = 2`, `m = 2`). Then an L is placed flat with 1 overhang (`m = 3`), then a supported O (`m = 2`), then a Tripod with 3 hanging (`m = 5`), then a T with 2 hanging (`m = 7 ≥ 6`). The T slips, and `m = 0`.

**F2 heavier side** (integers only).
- `Mx = Σ (2x − (W − 1))` and `Mz = Σ (2z − (D − 1))` over all solid content.
- If `|Mx| ≥ |Mz|`, `dir = sign(Mx) · x̂`; otherwise `dir = sign(Mz) · ẑ`.

*Example*: 5 × 5 with cubes at x = 3, 4, 4 (z = 2): `Mx = 2 + 4 + 4 = 10` and `Mz = 0`, so `dir = +x`.

### Edge cases

| Case | Result |
|---|---|
| Clears in the same lock (wobble on a clearing level) | `o` is counted at S2 before the clear. The slip at S4b acts on the piece's cubes that are left. If none are left, there is no slip and `m = 0`. |
| The slip completes a layer | S4c post-clear pass (0.2). Under M1 clears are off, so nothing happens. |
| Pop-off and ★★★ "no cube trimmed" (05) | Counts as trimmed by default (`popoff_counts_as_trim`). **Open Question 5.** |
| Flip | Not allowed (W11). |
| Conveyor | Allowed. The slip (twist, rank 3) runs before the belt shift (rank 4). |
| Fog | The slipped cubes keep their own fade timers. |
| Top-out | The slip happens before S6, so the top-out check sees the final cells. |
| Pip's catch | A caught lock adds nothing (0.4). |
| Degenerate play | Building only supported pieces never slips. That is healthy mastery, and it is the lesson of the level. Deliberate slips to fill a gap are allowed (the result can be read in advance). |

### Tuning knobs

| Knob | Range | Meadow default | Cat. | Affects |
|---|---|---|---|---|
| wobble_max | 2–20 | 6 | curve | How many overhangs before a slip |
| wobble_decay | 0–3 | 1 | curve | How much a supported lock forgives |
| wobble_warn | 0–4 | 2 | feel | How early the sway warns |
| slip_cells | 1–2 | 1 | feel | Slip distance |
| popoff_counts_as_trim | bool | true | gate | ★★★ strictness |

### Acceptance criteria (gdUnit4, `tests/unit/rules/wobble_test.gd`)

1. [U] F1: the example sequence gives m = 2, 3, 2, 5, then a slip and m = 0.
2. [U] W1: a cube above its own piece's cube is not an overhang; a cube above an inactive cell is.
3. [U] F2: cubes at x = 3, 4, 4 on 5 × 5 → `+x`. If both moments are 0 and the centroid is 0, there is no slip and m = 0.
4. [U] W6: a piece at x = 4 slipping `+x` on 5 × 5 is removed. `on_clear` does not fire and `layers_cleared` does not change.
5. [U] W7: a target cell holding another piece's cube → no move, `wobble_hold`, m = 0.
6. [U] W8: a slipped piece ends supported, with no cube in a solid cell.
7. [U] Determinism: the same command log gives the same slip events.
8. [U] Validator: PL03 + EV03 fails.
9. [M] Playtest of 05: at least 70% of testers say that "hanging cubes make it wobble" after one slip.

### Tree sketch

```
Selector wobble
├─ Sequence on_lock
│  ├─ C phase == ON_LOCK
│  ├─ A count_overhangs(ctx.cells) → bb.o
│  └─ A update_meter(bb.o)                          # F1
└─ Sequence resolve_end
   ├─ C phase == RESOLVE_END
   ├─ C bb.m ≥ wobble_max
   ├─ A reset_meter                                 # always resets once due
   ├─ C piece_has_cubes(bb.last_piece)
   ├─ A pick_dir → bb.dir                           # F2; fails if balanced
   └─ Selector
      ├─ Sequence: C target_off_island · A pop_off · A emit wobble_popoff
      ├─ Sequence: C target_blocked · A emit wobble_hold
      └─ Sequence: A move_cells(dir) · A drop_until_supported · A emit wobble_slip
```

---

## 2. SP28 Dandelion puff (meadow_03 "Breezy Hill")

### Overview

A special piece (tag `puff`, 1 per bag). When it locks, it splits along a fluffy **seam** into two halves, and each half drops on its own. The seam is fixed by a seed drawn at spawn and is drawn on the falling piece, so the player can rotate it to choose how the halves fall.

### Detailed rules

| # | Rule |
|---|---|
| D1 | **`on_spawn`**: the piece tagged `puff` gets `r = rng.randi()` (one draw), stored on the piece. |
| D2 | **Candidate cuts** for the current cells: planes perpendicular to a **ground axis** (never to the down axis), between two adjacent coordinates, that leave both sides non-empty. |
| D3 | **Pick**: keep the cuts with the smallest `|n₁ − n₂|`, sort them canonically (axis x before z, then plane position), and pick `r mod n`. This uses no new draw, so the seam is a pure function of the orientation. |
| D4 | **No cut possible** (a monomino, or an upright column with a 1 × 1 footprint): no split. The puff "poofs" (view only) and locks normally. |
| D5 | **S2 split**: the locked cubes are partitioned by the cut. Each half is a rigid group, even if it is not face-connected. The half whose lowest cube is lower drops first (ties: smaller min x, then z). It drops along down until a cube is supported (F3 sweep), and then the other half drops. Both halves stay Blocks with the same `piece_instance_id` plus `half` 0/1. |
| D6 | The S3 clear check sees the halves at their final cells. |
| D7 | **Telegraph**: the seam is drawn on the falling piece and updates with every rotation. The **landing ghost shows both halves at their post-split cells** (`puff_ghost_split`). |
| D8 | Resolving time adds `puff_settle_ms` when a half moves. |

### Formulas

**F1 cut balance.** `cut* = argmin |n₁ − n₂|` over D2. Ties are broken by `r mod n` (D3).

| Shape (flat, down −y) | Cuts (sizes) | Kept |
|---|---|---|
| I along x | x: 1/3, 2/2, 3/1 | x 2/2 (1 cut) |
| O | x 2/2, z 2/2 | both; `r mod 2` |
| T | x 1/3, 3/1; z 3/1 | all three; `r mod 3` |
| S | x 1/3, 3/1; z 2/2 | z 2/2 |
| Tripod | x 1/3; z 1/3 | both |

**F2 settle distance** for each half: `d_h` = the FDL F3 sweep for the half's cells (0 to `board_height − 1`).

### Edge cases

| Case | Result |
|---|---|
| Gust (EV01) | Affects the falling puff only. The halves move in Resolving, where no gusts act. |
| A half lands in the spawn zone | It cannot: the halves only drop, never rise. |
| A split completes a layer | The halves are placed before S3, so the layer clears in the normal check. |
| Pip's catch (03) | Evaluated on the **post-split settled cells** (WO11 rule K2), using the stored `r` (no extra draw). |
| Catch returns a puff | `r` is kept. The seam may change with the orientation (D3). |
| Flip | Splits use the current down axis. |
| Fog | Each half's fade timer starts when it settles. |
| Conveyor | No interaction (the shift happens after S4). |
| Degenerate play | Aiming the seam to drop a half into a 1-wide well is intended skill expression. |

### Tuning knobs

| Knob | Range | Meadow 03 | Cat. | Affects |
|---|---|---|---|---|
| puff_per_bag | 0–2 | 1 | gate | Frequency (Spawner tag rule) |
| puff_ghost_split | bool | true | feel | Readability |
| puff_settle_ms | 100–400 | 200 | feel | Resolve length |
| puff_cut_axes | ground / any | ground | curve | Whether cuts may also be horizontal |

### Acceptance criteria (`tests/unit/rules/dandelion_puff_test.gd`)

1. [U] F1 table: every shape row gives exactly the listed kept cuts.
2. [U] The same `r` and orientation give the same cut. Rotating 90° about y changes the kept set as F1 predicts.
3. [U] A monomino puff locks unsplit, with no extra RNG draw (stream position unchanged).
4. [U] A flat I locked over a 2-deep gap under its right half: the left half rests and the right half drops 2. Both are Blocks with `half` 0/1.
5. [U] A split that fills the last 2 cells of a layer clears that layer in the same Resolving.
6. [U] The landing ghost cells equal the post-split cells.
7. [I] With a catch available, a puff whose split result leaves a new covered hole is caught.
8. [M] At least 70% of 03 testers notice that the seam changes when they rotate the puff.

### Tree sketch

```
Selector puff
├─ Sequence spawn:  C phase == ON_SPAWN · C piece.has_tag(puff) · A store_seed(rng)
└─ Sequence lock:   C phase == ON_LOCK · C piece.has_tag(puff)
   ├─ A find_cuts → bb.cuts
   ├─ C bb.cuts.size() > 0                          # D4: else locks normally
   ├─ A pick_cut(r mod n)
   ├─ A drop_half(lower first)
   └─ A drop_half(other) · A emit puff_split
```

---

## 3. SP22 Growing sprout (meadow_06 "Flower Bed", H1 "Seed Sprouts")

### Overview

A living block placed by level data. Every `grow_locks` locks, each sprout grows one cube upward from its tip, unless the cell above is taken or it has reached `grow_max`. In 06 the sprouts fill two target cells for free. In H1 they grow without a cap and must be capped or cleared before they poke through the danger line.

### Detailed rules

| # | Rule |
|---|---|
| G1 | Level data places `sprout` content (0.5) with a unique `sprout_id`. A column is all the cells with that id. Its **tip** is the cell with the highest layer index (along up). |
| G2 | The counter `n` rises by 1 per lock (0.4). At **S4b**, if `n ≥ grow_locks`, set `n = 0` and grow each sprout in ascending `sprout_id`. |
| G3 | **Grow** a sprout if (a) its grown count `g < grow_max` (`grow_max` 0 = no cap), and (b) the cell `tip + up` is inside the board (any layer, including the spawn zone), active and empty. Write `sprout` there and set `g += 1`. Otherwise skip it this time. A capped sprout grows again once the cover is gone (re-checked each time). |
| G4 | Sprout cubes clear like any `fills_layer` content. If every cell of a sprout is cleared, the sprout is gone. |
| G5 | **Telegraph**: on the lock before a growth (`n = grow_locks − 1`), the bud on every sprout that can grow swells. A capped sprout shows a squashed bud. |
| G6 | A growth that reaches `H_play` makes `over_limit()` true at S6, and the level's `topout_rule` applies (H1: rescue). |

### Formulas

**F1 growth.** Cubes grown by one uncapped sprout after L locks: `g(L) = min(grow_max, floor(L / grow_locks))`.

**F2 time to poke** (H1, no cap): `L_poke = (H_play − tip₀) × grow_locks`.

| Var | Range | 06 | H1 |
|---|---|---|---|
| grow_locks | 2–10 | 4 | 3 |
| grow_max | 0–8 (0 = none) | 1 | 0 |
| tip₀ | 0–H_play−1 | 0 | 0 |

*Examples*:
- 06: each sprout gives 1 cube at lock 4. The cells (3,1,2) and (4,1,2) are layer-1 target cells, so 2 free targets (plus 2 base cells already in layer 0).
- H1: `L_poke = 10 × 3 = 30 locks` ≈ 4 min at 8 s per piece. A ~7 min level therefore forces about one cap or clear per sprout. This is the intended pressure.

### Edge cases

| Case | Result |
|---|---|
| The growth cell is under the falling piece | Impossible: S4b has no active piece. |
| The growth completes a layer | S4c post-clear pass (0.2). |
| Growing in M2 (06) | The sprout cube covers a target (0.5). Clears are off, so it stays. |
| Flip | Grows toward the new up. Columns move with the settle (H1 has no flip). |
| Conveyor | Moves as content. The tip is recomputed from the ids. |
| Ants | Sprouts are not edible. |
| Fog | A new sprout cube starts its own visible timer. |
| Trim (06) | A growth at `H_play` would be trimmed. This cannot happen at `grow_max` 1. |
| Pip's catch | A caught lock does not advance `n`. |
| Starting cell invalid | A sprout in an inactive cell → validation error (Board edge case). |

### Tuning knobs

| Knob | Range | Default | Cat. | Affects |
|---|---|---|---|---|
| grow_locks | 2–10 | 4 (06), 3 (H1) | curve | Growth pace (F1) |
| grow_max | 0–8 | 1 (06), 0 (H1) | gate | Cap |
| sprout cells | level data | 06: (3,0,2),(4,0,2); H1: 4 on the floor | gate | Layout |

### Acceptance criteria (`tests/unit/rules/sprout_test.gd`)

1. [U] F1: `grow_locks` 4, `grow_max` 1 → one growth at lock 4, none at locks 8 or 12.
2. [U] G3: with a Block on the cell above the tip, there is no growth. After that Block is cleared, the next growth fires.
3. [U] G6: an uncapped sprout at tip 9 with `H_play` 10 grows to 10 → `over_limit()` is true at S6.
4. [U] 06 fixture: a growth to (3,1,2) increases the M2 covered count by 1.
5. [U] A growth that completes a layer clears it in S4c, and `layers_cleared` rises.
6. [U] A caught lock does not advance the counter.
7. [U] Determinism: no RNG is used. Sprouts grow in `sprout_id` order.

### Tree sketch

```
Sequence sprouts
├─ C phase == RESOLVE_END
├─ A n += 1
├─ C n ≥ grow_locks
├─ A n = 0
└─ ForEach sprout_id (asc)                          # custom composite, ordered
   └─ Sequence: C g < grow_max or grow_max == 0 · C free(tip + up) · A set_cell(tip + up, sprout) · A emit sprout_grew
(telegraph: Sequence: C phase == RESOLVE_END · C n == grow_locks − 1 · A emit sprout_bud)
```

---

## 4. SP26 Fog ghost (meadow_07 "Hide & Seek")

### Overview

A special piece (tag `ghost`, 1 per bag) that falls **through** locked content. The player solidifies it by **hard drop**: it becomes a normal piece where it is (pushed up to the nearest free fit if it overlaps), then drops. If it reaches the floor un-solidified, it solidifies when it locks. This lets a player slip a piece into a hole they remember under the fog.

### Detailed rules

| # | Rule |
|---|---|
| F1r | **`on_spawn`**: a tagged piece gets the flag `intangible = true`. The spawn check is the normal one (so top-out is unchanged). |
| F2r | **While intangible**, movement, rotation, gravity and gust `try_translate` test only bounds and active cells. Content is ignored, so kicks happen only off walls and the mask. A ghost rests only on the floor. |
| F3r | **Solidify** = `place_nearest_up()` (move up along −down until all cells are free), then `intangible = false`. From then on it is a normal piece. |
| F4r | **P0**: a `hard_drop` command on an intangible ghost first solidifies (F3r), then applies the normal hard drop and grace. This is the default verb (**Open Question 3**: a separate tap). |
| F5r | **P3**: a lock attempt while intangible is vetoed. The ghost solidifies. If it is now resting, it locks at once ("locks where it is"); otherwise it is Falling. |
| F6r | **Landing outline** while intangible = `drop_target(place_nearest_up(cells))`, which is exactly the result of a hard drop now. |
| F7r | Look: translucent with a soft glow, never confused with the landing outline or with fog-faded blocks (art). |

### Formulas

**F1 solidify lift.** `k = min k ≥ 0 such that can_place(cells − k·down)`. Then the final position is `drop_target` (FDL F3) from there.
*Example*: a flat O inside starter layers 0–1, overlapping 1 cube at y = 1: `k` lifts it to y = 2 (above the stack), and it rests there.

### Edge cases

| Case | Result |
|---|---|
| Ghost inside a closed cavity with all cells free, then hard drop | Solidifies in place and drops to the cavity floor. This is the intended trick. |
| Ghost reaches the floor overlapping the starter blocks | When the lock delay expires, F5r lifts it to the nearest free fit. If it is resting there, it locks. |
| Sticky Landing (lock delay 0) | F5r still applies, so it never locks inside content. |
| Gust | Pushes it through content (bounds only). |
| Fog (EV02) | The ghost is never faded. The landing outline stays visible (fog rule). It may hint at hidden holes, which is accepted. |
| Clears | None happen while it falls. After the lock it is a normal Block. |
| Pip's catch | Not in 07. In general a caught ghost returns intangible. |
| Spawn zone overlap at solidify (the lift ends above `H_play`) | It locks there and the normal S6 top-out applies. |
| Mushrooms and objects | Ignored while intangible (all content). |
| Degenerate play | The ghost fills covered holes. That is strong but limited to 1 per bag (12.5% of pieces). Accept. |

### Tuning knobs

| Knob | Range | Meadow 07 | Cat. | Affects |
|---|---|---|---|---|
| ghost_per_bag | 0–2 | 1 | gate | Frequency |
| ghost_solidify_verb | hard_drop / tap | hard_drop | feel | Controls (Touch) |
| ghost_alpha | 0.3–0.8 | 0.5 | feel | Readability (art) |

### Acceptance criteria (`tests/unit/rules/fog_ghost_test.gd`)

1. [U] An intangible ghost falls through a 2-layer stack and rests on the floor.
2. [U] F1: the O fixture lifts to y = 2.
3. [U] A ghost in a free cavity, then `hard_drop`, locks at the cavity floor (the cells match the landing outline).
4. [U] With lock delay 0, no cube is ever written into an occupied cell.
5. [U] A spawn with the stack in the spawn zone → spawn blocked, as for a normal piece.
6. [U] The landing outline while intangible equals the hard-drop result for 20 seeded positions.
7. [M] At least 70% of 07 testers use the ghost to fill a remembered hole at least once.

### Tree sketch

```
Selector fog_ghost
├─ Sequence spawn:  C phase == ON_SPAWN · C has_tag(ghost) · A set_piece_flag(intangible, true)
├─ Sequence cmd:    C phase == ON_COMMAND · C cmd.kind == hard_drop · C intangible · A solidify
└─ Sequence veto:   C phase == LOCK_VETO · C intangible
   ├─ A veto(piece.lock)
   ├─ A solidify
   └─ Selector: Sequence(C resting · A request_lock_now) · A noop   # else falls
```

---

## 5. SP21 Hatching egg (meadow_09 "Topsy-Turvy")

### Overview

A living block from level data. After `hatch_locks` locks, an egg cracks and a **chick cube** hops into the lowest free neighbour cell. That is a free cube that tends to fill gaps, especially after a flip. Clearing an egg's layer before it hatches scores `egg_bonus`.

### Detailed rules

| # | Rule |
|---|---|
| E1 | Level data places `egg` content with `egg_id`. Its `age` rises by 1 per lock (0.4). |
| E2 | **S3 `on_clear`** on an egg cell: score `egg_bonus`, event `egg_saved`. The egg is removed with its layer. |
| E3 | **S4b**: each egg with `age ≥ hatch_locks` hatches, in ascending `egg_id`. Remove the egg; the chick goes to the cell from E4. Event `egg_hatched`. |
| E4 | **Hop target.** Candidate columns are the 4 ground neighbours of the egg cell `e` in order `+x, −x, +z, −z`, then `e` itself. A neighbour is a candidate only if the cell at `e`'s layer is active and empty. In each candidate, drop from `e`'s layer down to the lowest free cell reachable straight down. Choose the lowest landing layer; ties go to the earlier column in the order. `e` is always a candidate (it is empty after removal), so a chick always lands. |
| E5 | The chick is `chick` content (0.5): permanent and cleared with its layer. |
| E6 | **Telegraph**: the crack grows with age, and the egg wobbles at `age = hatch_locks − 1`. |

### Formulas

**F1 bonus reachability.** The bonus is possible only if the egg's layer can be filled before the hatch:
`pieces_needed = ceil((A − n_eggs_in_layer) / c) ≤ hatch_locks`.

| Var | Range | Meadow 09 |
|---|---|---|
| A | 12–144 | 36 (6 × 6) |
| c | 1–8 | 4 (8 Standard) |
| hatch_locks | 3–12 | **6 in meadow.md → recommend 12** |
| egg_bonus | 0–500 | 150 (for economy-designer) |

*Example*: (36 − 2) / 4 = 8.5 → 9 pieces with zero waste. At `hatch_locks` 6 the bonus is **unreachable**: a dead reward and a false choice (balance finding B1). At 12, perfect play has 3 spare pieces.

### Edge cases

| Case | Result |
|---|---|
| A flip and a hatch in the same Resolving | S4a flip settle first, then S4b hatch. The chick hops along the new down. |
| A chick completes a layer | S4c post-clear pass (0.2). |
| An egg is buried (all neighbours occupied) | The chick takes the egg's own cell. |
| Conveyor | Eggs move as content. The hop uses the post-move cells (the hatch runs at rank 2, before the belt shift at rank 4). |
| Fog | The chick starts its own visible timer. |
| Top-out | The chick lands at or below the egg's layer, so it never raises the stack. |
| Ants | Eggs and chicks are not edible. |
| Pip's catch | A caught lock does not age eggs. |

### Tuning knobs

| Knob | Range | Default | Cat. | Affects |
|---|---|---|---|---|
| hatch_locks | 3–12 | 12 (recommended; meadow.md 6) | curve | Bonus window (F1) |
| egg_bonus | 0–500 | 150 | curve | Reward (economy-designer) |
| hop_order | fixed list | +x, −x, +z, −z, self | feel | Predictability |
| egg cells | level data | (1,0,1), (4,0,4) | gate | Layout |

### Acceptance criteria (`tests/unit/rules/hatching_egg_test.gd`)

1. [U] An egg hatches exactly at lock `hatch_locks`, and not on a caught lock.
2. [U] E4: an egg at (1,0,1) with an empty column at +x → the chick lands at (2,0,1). With every neighbour blocked → the chick takes (1,0,1).
3. [U] E4 tie: two neighbours at the same landing layer → the `+x` one is chosen.
4. [U] E2: clearing the egg's layer scores `egg_bonus` once, and no chick appears.
5. [U] A flip and a hatch in one lock → the chick position is computed after the flip settle.
6. [U] F1: A 36, 2 eggs, c 4 → 9 pieces needed. The validator warns when `hatch_locks < pieces_needed`.
7. [U] Determinism: no RNG.

### Tree sketch

```
Selector eggs
├─ Sequence clear:  C phase == ON_CLEAR · C ctx.content.type == egg · A add_score(egg_bonus) · A emit egg_saved
└─ Sequence hatch:  C phase == RESOLVE_END · A age_all
   └─ ForEach egg_id (asc): Sequence
      ├─ C age ≥ hatch_locks
      ├─ A clear_cell(egg)
      ├─ A pick_hop_target → bb.t                    # E4
      └─ A set_cell(bb.t, chick) · A emit egg_hatched
```

---

## 6. SP31 Picnic ants (H2 "Picnic Ants"; hard track, not MVP)

### Overview

A pest. Every so often each ant eats a neighbouring Block and moves into its cell, leaving a hole behind. A clear in or next to an ant's layer sends it packing. An ant with nothing to eat for a while starves and leaves.

### Detailed rules

| # | Rule |
|---|---|
| A1 | Level data places `ant` content with `ant_id` (0.5: solid, fills the layer). |
| A2 | **S3 `on_clear`**: any ant in a cleared cell, or face-adjacent (6 neighbours) to a cleared cell, is **shooed**. It is removed with this clear step (ants in the next layers leave empty cells), scores `ant_shoo_bonus` and emits `ant_shooed`. |
| A3 | **S4b**: ant `i` acts on locks where `(locks + i) mod ant_every_locks == 0`. This staggers them, so with 3 ants and 3, one ant acts per lock. |
| A4 | **Act**: the candidates are the 6 face neighbours holding a **Block**. Objects, eggs, sprouts, chicks, mushrooms and ants are not edible. If there are candidates, pick by 0.3, remove the Block (event `ant_ate`, not a clear), move the ant there and leave its old cell empty. Set `hungry = 0`. |
| A5 | No candidate: `hungry += 1`. At `hungry ≥ ant_starve_acts`, the ant leaves (removed, no bonus, `ant_starved`). |
| A6 | **Telegraph**: on the lock before an ant acts, it turns toward its chosen cube. The choice is made one lock ahead and redrawn only if the target is gone. |

### Formulas

**F1 net fill per lock.** `net = c − n_ants / ant_every_locks`.

| n_ants | ant_every_locks | net (c = 4) |
|---|---|---|
| 3 | 1 (meadow.md "every lock") | 1.0. On a 36-cell layer that is about 36 locks per clear, so 4 clears ≈ 19 min. **Too punishing** (finding B2) |
| 3 | 3 (recommended) | 3.0 → about 12 locks per clear. Hard, but fair |

### Edge cases

| Case | Result |
|---|---|
| An ant eats a cube that supports others | Allowed. Slice rules have no gravity, so the cubes above stay put (a hole). |
| An eaten cube is in an otherwise full layer | That layer is no longer full. This is the threat. |
| An ant adjacent to two clears in one lock | Shooed once; the bonus is paid once. |
| A mushroom (EV04 callback) | Not edible. Mushrooms can trap ants, which leads to starving. |
| An ant in the spawn zone (eats upward) | Counts for `over_limit()`. Default: ants may not move to a cell at or above `H_play` (the candidate is excluded). |
| Flip, conveyor | Ants move as content. |
| Fog | Ants are never faded (they are pests, and readability wins). |
| Pip's catch | Not on the hard track. |

### Tuning knobs

| Knob | Range | H2 default | Cat. | Affects |
|---|---|---|---|---|
| ant_every_locks | 1–6 | 3 (recommended; meadow.md 1) | curve | Pressure (F1) |
| ant_starve_acts | 1–6 | 3 | gate | How long a trapped ant stays |
| ant_shoo_bonus | 0–200 | 50 | curve | Reward |
| ant cells | level data | 3 in the starter layer 1 | gate | Layout |

### Acceptance criteria (`tests/unit/rules/picnic_ants_test.gd`)

1. [U] A3: 3 ants with `ant_every_locks` 3 → exactly one ant acts per lock, in a fixed rotation.
2. [U] A4: an ant next to 2 Blocks and 1 mushroom picks only a Block. The old cell ends up empty and the ant is in the eaten cell.
3. [U] A2: a clear of layer 2 shoos an ant in layer 1 or 3, and the bonus is paid once.
4. [U] A5: after 3 acts with no candidate, the ant is removed (`ant_starved`).
5. [U] Determinism: the same seed gives the same ant paths.
6. [U] An ant never moves to a cell at or above `H_play`.

### Tree sketch

```
Selector ants
├─ Sequence clear:  C phase == ON_CLEAR · A mark_adjacent_ants · A remove_marked · A add_score
└─ Sequence act:    C phase == RESOLVE_END
   └─ ForEach ant_id (asc): Sequence
      ├─ C (locks + i) mod ant_every_locks == 0
      └─ Selector
         ├─ Sequence: A edible_neighbours → bb.c · C bb.c not empty · A pick(rng) · A eat_and_move
         └─ Sequence: A hungry += 1 · C hungry ≥ ant_starve_acts · A remove_ant
```

---

## 7. WO11 Pip's catch (Meadow tiers 1–3)

### Overview

Pip's one-time safety net (`mascot_catches` 1). A lock that would leave a **new covered hole** and clear nothing is undone before Resolving. Pip catches the piece and puts it back at the spawn position in its current orientation.

### Detailed rules

| # | Rule |
|---|---|
| K1 | **P3 lock veto**, rule layer `mascot`. `P` = the cells the piece would occupy. |
| K2 | For a puff, `P` = its post-split settled cells (SP28 D3/D5, pure function). For an intangible ghost, F5r runs first and the catch checks the solidified cells. |
| K3 | **New covered hole**: there is a cube `c ∈ P` whose cell `e = c + down` is empty, `e ∉ P`, and, before the lock, no solid content was in `e`'s column above `e`. The floor and inactive cells are never holes. |
| K4 | **Clears nothing**: `would_clear(P)` is false. A layer would be full with `P` added. Always false while `clear_enabled` is off. |
| K5 | **Not a goal lock**: `goal.would_meet(P)` is false. For Clear-N, K4 already guarantees this. |
| K6 | **Not a top-out lock** (this reading of "not during a warning"; **Open Question 5**): `P` must not leave solid content at or above `H_play` after K4. |
| K7 | The spawn cells for the **current orientation** (spawn rule: anchor-centred, lowest cube at `H_play`) must be free. |
| K8 | If K3–K7 hold and `catches_left > 0`: veto `piece.lock`, call `return_piece_to_spawn()`, set `catches_left −= 1` and emit `mascot_catch`. |
| K9 | **Return state**: current orientation; gravity clock 0; lock resets full; lowest layer reached = spawn; soft drop and grace cleared; puff `r` and ghost `intangible` kept. For `catch_ms` the piece is "in Pip's paws". Gravity does not run and input follows the Waiting rules (Touch keeps the latest move or rotate within `input_buffer_ms`). |
| K10 | The level clock keeps running. Catches never affect stars. `mascot_catches` 0 on tiers 4+ and the hard track (the rule is absent there). |

### Formulas

**F1 hole test** (per cube): `hole(c) = empty(c + down) ∧ (c + down) ∉ P ∧ ¬∃ solid y' above (c + down) in that column, pre-lock`. Catch if `Σ hole ≥ 1 ∧ K4–K7`.
*Example* (meadow_02): a flat L laid over pocket A covers the empty pocket cell → hole = 1 → caught. A Tripod that fills A exactly → hole = 0 → it locks.

### Edge cases

| Case | Result |
|---|---|
| A piece over a cell already covered (an overhang cavity) | Not new (K3), so no catch. |
| Hard drop commit | Caught the same way. The grace is cleared. |
| A gust mid-catch | No piece is falling during `catch_ms`, so the gust is skipped (EV01 rule 6). |
| Counters (sprouts, mushrooms, belt, wobble) | Do not advance (0.4). |
| Second qualifying lock | `catches_left` is 0, so it locks normally. Pip covers its eyes (view). |
| Return cells blocked | No catch. It locks normally (K7). |

### Tuning knobs

| Knob | Range | Default | Cat. | Affects |
|---|---|---|---|---|
| mascot_catches | 0–3 | 1 (tiers 1–3), 0 after | gate | Forgiveness |
| catch_ms | 0–600 | 300 | feel | Readability of the catch |
| catch_on_topout | bool | false | gate | K6 |

### Acceptance criteria (`tests/unit/rules/mascot_catch_test.gd`; MDW-002)

1. [U] F1 example: an L over pocket A → caught, the piece is at spawn in the same orientation, and `catches_left` is 0.
2. [U] A second hole-making lock → locks normally.
3. [U] A lock that clears a layer and leaves a hole → not caught.
4. [U] A piece over an already-covered cavity → not caught.
5. [U] After a catch, no gravity step happens for `catch_ms`, and the first step comes one full interval after that.
6. [U] A caught lock fires no `on_lock`, and the lock counters are unchanged.
7. [U] A puff whose split leaves a hole → caught, with no extra RNG draw.
8. [M] At least 80% of tier 1–3 testers say Pip "saved" a bad drop.

### Tree sketch

```
Sequence mascot_catch
├─ C phase == LOCK_VETO
├─ C catches_left > 0
├─ A resolve_final_cells → bb.P                     # K2
├─ C not would_clear(bb.P)
├─ C new_covered_holes(bb.P) ≥ 1
├─ C not goal_would_meet(bb.P)
├─ C not would_top_out(bb.P) or catch_on_topout
├─ C spawn_cells_free(current orientation)
├─ A veto(piece.lock)
├─ A return_piece_to_spawn(catch_ms)
└─ A catches_left -= 1 · A emit mascot_catch
```

---

## 8. Balance check (designed defaults vs. Meadow levels)

**Data sources:**
- `design/levels/meadow.md` and the GDDs listed in the header.
- `assets/data/knobs/*.json`: no rule JSON exists yet, so the data files are **NOT ASSESSED — NO DATA**.
- `design/registry/entities.yaml`: not used.

**Health: CONCERNS.** Every finding below can be fixed by tuning.

| # | Priority | Finding | Fix |
|---|---|---|---|
| B1 | High | SP21: the egg bonus is unreachable at `hatch_locks` 6 on 6 × 6 (needs 9 pieces, F1). That makes it a dead reward. | `hatch_locks` 12 for meadow_09 |
| B2 | High | SP31: 3 ants every lock leave a net +1 cube per lock, so 4 clears take about 19 min | `ant_every_locks` 3, staggered (net +3) |
| B3 | Med | EV03 in meadow_10: `flip_every_ms` 180 000 does not guarantee "never again before the 3rd clear" | New knob `flip_max` (0 = unlimited; meadow_10 = 1) |
| B4 | Med | PL03 slip rate: no data | Playtest 05. Target 1–3 slips per run for median players |
| B5 | Low | SP22 H1: time to poke is 30 locks (≈ 4 min) in a ~7 min level | Intended. Check in a playtest |

Degenerate strategies: none found that dominate. The ghost (SP26) is strong, but its rate is limited.

---

## 9. Events the Meadow uses: completeness check

| Atom | Levels | Verdict | Gaps found → proposed default |
|---|---|---|---|
| **EV01 Gust** (T1) | 03, 10, H1 | Complete, with 3 small gaps | (a) The jitter distribution is not stated → uniform integer in `[interval − jitter, interval + jitter]`, drawn when each gust ends. (b) The timer start is not stated → it starts at the first spawn, on the level clock. (c) A gust that falls due with no falling piece is **dropped, not deferred**, and the clock keeps running. |
| **EV02 Fog** (T2) | 07 | Gap: contradiction | Rule 8 says "visible for `reveal_ms`, then fade"; F2 says `t` = time since the last reveal, which would mean visible for `visible_ms` again. → **Rule 8 wins**: alpha 1 for `reveal_ms`, then the fade over `fade_ms`. Fog alpha and the camera occlusion fade combine as `min`. Starter blocks: their timers start at the first spawn (meadow.md). |
| **EV03 Topsy Tumble** (T3) | 09, 10 | Gaps | (a) A layer-triggered flip cannot be warned 2 s ahead → **Due → Warning (`flip_warn_ms` play time) → apply at the first Resolving that starts after the warning**. Time triggers start the warning at `flip_every_ms − flip_warn_ms`. (b) The step is not stated → S4a (0.1), before S4b. (c) `flip_max` (B3). (d) The counters reset when the flip is applied. |
| **EV04 Mushroom Pop-up + SP19** (T4) | 04, H2 | Gaps | (a) A mushroom that completes a layer → S4c pass (0.2). (b) If the marked cell is taken, the substitute cell gets no telegraph. Default: keep T4 rule 15 (choose another cell) and play the pop with a 1-beat sparkle. (c) "Every 5 locks" counts from the level start: mark at lock 4, place at lock 5. |
| **EV05 Mill Belt** (M4) | 10 | Complete | Proposed only: a wind-up telegraph on the lock before a shift (the Miller's lever). The flip-then-shift order is already in the LSM edge cases. |
| **PL01 Sticky** (M3) | 08 | Complete | The open up-kick question stays non-blocking. SP26 F5r covers sticky + ghost. |
| **M1 Build race** | 05 | Complete | Wobble pop-offs and ★★★ (Open Question 5). |
| **M2 Fill shape** | 06, B | Gap | "Covered" = holds solid `fills_layer` content (includes sprouts, 0.5). LSM M2 rule 9 says "blocks" only. |

---

## 10. Proposed edits to owning GDDs (not made; for the owners)

| File | Edit |
|---|---|
| `fall-drop-lock.md` rule 15 | Add S4a (structure changes applied) and S4c (post-hook clear pass, once). Add the P3 lock-veto step. |
| `layer-clearing.md` rule 1 | Point to S4c as the single "rule changed contents" check after a lock. |
| `rule-twist-framework.md` rule 12 / F2 | Add ranks `mascot` 1 and `content` 2 (0.6). Add `flip_max` to the rule-adjustable list. |
| ADR-0004 §2, §7 | Same ranks. RuleApi additions: `set_piece_flag(&"intangible")`, `would_clear(cells)`, `new_covered_holes(cells)`, `would_top_out(cells)`, `GoalEvaluator.would_meet(cells)`. |
| `movement-rotation.md` | `intangible` piece flag: `can_place` tests only bounds and the mask. |
| `twist-library.md` | EV01 gaps (a–c), the EV02 rule 8 vs F2 fix, EV03 warning flow + `flip_max`, EV04 S4c. |
| `level-specific-mechanics.md` M2 rule 9 | "Covered" includes `fills_layer` objects. |
| `mechanics-module.md` | PL03, SP21, SP22, SP26, SP28, SP31, WO11 → status D (this file). `hatch_locks` default 6 → per level. Add `ant_every_locks`. |
| `design/levels/meadow.md` | 09 `hatch_locks` 12; H2 `ant_every_locks` 3; 10 `flip_max` 1; 07: the ghost is solidified by hard drop (if accepted); §10 open questions closed by this doc. |
| `touch-controls.md` | Only if Open Question 3 picks a tap: add the `solidify` gesture and button. |
| `scoring-stars.md` | `egg_bonus`, `ant_shoo_bonus`; whether wobble pop-offs count as trims. |
| ADR-0011 (missing) | Write it, or point to where the beehave decision lives. Rule that a tree ticks once per subscribed hook call (0.7). |

## Open Questions

1. **ADR-0011 is missing.** Confirm that a tree ticks once per subscribed hook call. A tree ticked "once per sim tick" cannot act between S2, S3 and S4 in one tick.
2. **RuleApi vs SimCommand.** Mechanics write through RuleApi (ADR-0004), and only player intent is a SimCommand. Confirm this, or say what ADR-0011 intends.
3. **Fog ghost verb.** Hard drop solidifies (recommended: no new gesture), or a separate tap and button?
4. **Balance.** Egg `hatch_locks` 6 → 12 (09); ants `ant_every_locks` 1 → 3 (H2); `flip_max` 1 for 10.
5. **Readings of meadow.md.** Do wobble pop-offs count as "trimmed" for ★★★ in 05? Does the catch's "not during a warning" mean "not on a lock that would top out"?
6. **Engine rules.** Accept the new S4a/S4c steps and the `mascot`/`content` ranks.
