# Minigame Mechanics — Wave 4 (reusable atoms from the mockup sheets)

> **Status**: Draft — atoms proposed, open decisions listed at the end of Detailed Rules
> **Author**: Tessa + agents (systems-designer)
> **Last Updated**: 2026-10-13
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Source**: `assets/art/reference/minigame_mockups/mockup_01.jpg`–`mockup_20.jpg` (viewed 01–13, 15, 18)

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Mechanics Module (RuleApi, ADR-0004/0011), Minigame Session (rules_a–d), Physics Mode, Obstacles, Twist Library`

## Overview

The 20 mockup sheets show about 75 minigame panels. Most of them reuse a small number of mechanics. This document
breaks them down into **atoms**: reusable mechanics. Each atom is either mapped to something the engine already
has, or specified here as a new `RuleBehaviour` / goal evaluator / session helper. A designer should be able to
build a new minigame by combining atoms, with no new code. Every new atom follows the same contract as the
existing rules: it is a pure `RefCounted`, it writes only through `RuleApi`, its randomness comes only from
`api.rng()`, its mutable state is returned by `snapshot()`, and **every hazard warns the player before it
acts** (twist-library rule 11, *Readable Chaos*). The hook names match `src/mechanics/behaviour/flip.gd`:
`on_spawn`, `on_tick`, `on_lock`, `on_clear`, `on_resolve_end` (plus `on_level_start` as used by Wave 3).

Some atoms need to change a **rival's** board (siege shots, territory steals). `RuleApi` cannot write to another
player's board, so those atoms live at the minigame-session layer (`WtMinigameSession.charge_send` /
`preview_attack` / `attack` / `request_shared` + `_authority`). This is the same pattern that mg06 bird,
mg13 pump and mg20 wet_paint already use.

## Player Fantasy

"I know this trick — it's the wobbly plate again, but now it's a cake." Players pick up a mechanic once and
recognise it in another costume: the stability meter in Cake Stackers is the same one as in Kraken Keep. The
fort you shell in Fort Blast loses HP by the same rule as the rock you dig through in Rubble Rumble. Under
the costume, every minigame is still about placing blocks well.

## Detailed Rules

### 1. Mockup → atom recurrence (panels viewed)

| Atom | Mockup panels that need it | Count | Status |
|---|---|---|---|
| **A1 `gauge`** (generic HUD meter that drives an effect) | Altitude, Heat (Bridge Dash, Clockwork Chaos), Balance, Topple Risk, Stability ×3, Cargo Security, Water Flow, Pressure ×2, Oxygen, Egg Temperature, Spatial Pull, Grid Heat, Sweetness, Slippery, Height-to-Safety ×4 | ~25 | **NEW** (the existing meters are each written separately: wobble, pressure_cooker, fever_rush, speed_bump) |
| **A2 `tilt_plate`** (stability/topple on a tilting plate or spring) | Tumbling Towers, Cake Stackers, Chroma Sky Climb, Kraken Keep, Sugar Rush Stack, Jungle Giant Ascent | 6 | **NEW** (grid). Jolt `balance`/`seesaw` already exist but are not deterministic |
| Rising lava / water timer | Avalanche Ascent, Summit Scramble, Frenzy Footholds, Volcano Dash, Glacier Gauntlet | 5 | **EXISTS** — `lava_rise` (EV06), mg13 `_lava_tick` (`WtMinigameGeometry.lava_interval`, safe layers, ghost), `rising_silt`, `lava_lid` |
| **A3 `span_goal`** (bridge across a gap / connect a path) | Bridge Bashers, Bridge Dash, Jungle Bridge Rush, Meadow Mayhem (bridge), Runaway Rail Rush, Sweet Rush Rails, Coral Conduit, Cosmic Climb | 8 | **NEW goal** (generalises mg06 `WtMinigameGeometry.bridge_path` and Jolt `bridge_builder`) |
| **A4 `material_hp`** (block strength) | Fort Blast ("Block Strength"), Shatter Shootout, Fort Frenzy, Castle Siege Crash, Candy Crushers, Rubble Rumble, Digging Frenzy | 7 | **PARTIAL** — `lava_rock_spawn` `hits_left` status; registry `rock_hp`=2, `crate_hp`=1, `junk_hp`=1. Needs to be generalised into a material table |
| **A5 `siege_shot`** (catapult/cannon at a rival fort) | Fort Frenzy, Fort Blast, Shatter Shootout, Castle Siege Crash, Candy Crushers, Airship Scrap Brawl | 6 | **NEW** (session layer). The closest existing mechanic is `storm_bolt` (damage to the top of a column) |
| **A6 `boss_hp`** (boss health bar damaged by clears) | Kraken Blockade, Boss Bash, Abyssal Kraken Siege, Airship (Ship Health), Castle Siege (Fortress Health) | 5 | **PARTIAL** — `bonk_boss` goal counts bonks only. There is no HP, no scaling and no phases |
| **A7 `delivery_intake`** (conveyor delivers to a machine) | Clockwork Conveyor, Factory Frenzy Assemble, Galactic Grab, Sweet Rush Rails | 4 | **PARTIAL** — `conveyor` / `mill_belt` move content; nothing consumes or scores it |
| **A8 `laser_sweep`** (a telegraphed beam crosses a row) | Nebula Laser Hack, Galactic Grab, Magnetic Mash | 3 | **NEW** (`storm_bolt` targets a column; `thin_ice` removes the rim) |
| **A9 `strata_dig`** (dig down through layers for gems) | Rubble Rumble, Digging Frenzy, Submarine Salvage | 3 | **MOSTLY COMPOSITE** — `rising_silt` (gapped floor feed with a reachability guard) + `dig_rescue` (rescue by clear) + `items` (collect on clear) + A4 |
| **A10 `territory_claim`** (paint / claim tiles) | Neon Splat, Island Claim (named in the brief; not on the sheets I viewed); Slippery Sumo targets | 2–3 | **PARTIAL** — mg20 paint is a solo stencil; `chameleon_paint` recolours by majority. There is no contested ownership |
| Carry objects to a base | Maze Heist (keys), Submarine Salvage, Pirate Plunder Maze, Glacier Rush (stars), Temple Roller Run (coins) | 5 | **EXISTS** — mg19 `_gem_*` (bag_capacity, deposit at base, gold gem via `request_shared`), `star_coins` |
| **A11 `herd_critter`** (herd sheep into a pen) | Meadow Mayhem (herd sheep) | 1 | **NEW, deferred** (`hatching_eggs` hop logic can be reused) |
| Bomb defuse timer | Hub "Bomb Defuse" island, Prehistoric Nest | 2 | **EXISTS** — `countdown_bomb` (defused by an adjacent clear), mg14 hot potato |
| **A12 `balloon_lift`** (balloons lift a crate) | Hub balloon island | 1 | **PARTIAL, deferred** — `balloon` is a half-gravity piece with a bob, not a lift |
| Rolling boulders | Temple Roller Run, Pyramid Climber, Jungle Bridge Rush, Rolling Rumble | 4 | **EXISTS** — `snowball` |
| Rotating platform / gears | Clockwork Chaos, Steampunk Gear-Up, Cake Stackers | 3 | **EXISTS** — `turntable` |
| Gravity well / magnet | Wormhole Gravity Rush, Magnetic Mash | 2 | **EXISTS** — `magnet_pull` |
| Wind | Chroma Sky Climb, Jungle Vine | 2 | **EXISTS** — `gust`, Jolt `windy_tower` |
| Falling debris | Avalanche Ascent, Volcano Dash | 2 | **EXISTS** — `storm_bolt`, `gumdrop_hail`, Jolt `meteor_shower` |
| Slippery ice / bounce | Slippery Sumo, Glacier Rush, Jungle Vine (mushrooms) | 3 | **EXISTS** — `ice_slide`, `bounce_pad` |
| Balance by mass | Tumbling Towers (alt), Sugar Rush | — | **EXISTS** — mg21 balance pans (equal mass) |

### 2. Shared conventions for every NEW atom

- **Integer maths.** Meters are stored in milli-units (0–1000) so that every client gets a bit-identical
  result. Fractions shown below are display values, computed as `value / 1000`.
- **Warning floor.** Every `*_warn_ms` param is clamped to `≥ 600` (the `magnet_pull` floor) and defaults to
  `1500` (the same as mg06 `bird` `warn_ms`). A warning that is set to trigger on a lock count instead of a
  time is still scheduled one warning window ahead, exactly as `flip.gd` does.
- **Clear-to-cancel** is optional on each hazard (`cancel_on_clear`, as in `crab_claw` / `squirrel_heist`).
- **Events** use the names `<atom>_warning`, `<atom>_<verb>`, and `<atom>_state` (sent every time the value
  changes, for the HUD).

### 3. Atom specs

#### A1 `gauge` — NEW (`twist` layer) · priority 1

A bounded meter driven by data. Its inputs are chosen from a fixed list. When it reaches a threshold it fires
one existing effect. A single atom covers Oxygen, Heat, Pressure, Stability (the plain version), Egg
Temperature (a two-sided band) and Cargo Security. Several gauges can be active at once (`gauge_id` keeps them
apart).

- **Hooks:** `on_level_start` (init), `on_tick` (time input, warning, two-sided grace timer), `on_lock`
  (lock inputs), `on_clear` (clear inputs), `on_resolve_end` (applies the trigger and re-arms).
- **Params:**

| Param | Type | Safe range | Default | Meaning |
|---|---|---|---|---|
| `gauge_id` | string | unique per level | `"gauge"` | HUD key / event tag |
| `start` | int (milli) | 0–1000 | 0 | initial value |
| `per_s` | int (milli/s) | −100–100 | 0 | time drift (negative = drains, e.g. oxygen) |
| `per_lock` | int | −200–200 | 0 | added on every lock |
| `per_lock_no_clear` | int | 0–200 | 0 | added on a lock whose resolve cleared nothing |
| `per_layer` | int | −500–500 | 0 | added per layer cleared (negative = relief) |
| `per_overhang` | int | 0–100 | 0 | added per newly locked cube with an empty cell below it (the same count `wobble` uses) |
| `mode` | enum | `high` / `low` / `band` | `high` | trigger at full, at empty, or when outside the band |
| `warn_at` | int | 500–950 | 800 | warning threshold (`low` mode: `1000 − warn_at`) |
| `band_lo`, `band_hi` | int | 100–900, lo < hi − 100 | 300, 700 | the safe band in `band` mode |
| `band_grace_ms` | int | 1000–8000 | 3000 | time allowed outside the band before it triggers |
| `hysteresis` | int | 20–200 | 100 | drop needed before the warning re-arms |
| `on_full` | string | registered effect id | `"none"` | `"lose"`, `"junk_layer"`, `"slip"`, `"top_out_warning"`, or a send effect |
| `reset_to` | int | 0–1000 | 500 | value after a trigger |
| `warn_ms` | int | 600–4000 | 1500 | minimum warning lead |

- **Formula (per tick, order: time → lock → clear):**

  `G' = clamp(G + per_s·Δt_ms/1000 + per_lock·n_lock + per_lock_no_clear·n_dry + per_layer·L + per_overhang·n_oh, 0, 1000)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| G | int | 0–1000 | gauge before the step |
| Δt_ms | int | 0–100 per tick | simulated playing time this tick (paused through warnings, results and pause) |
| n_lock | int | 0–1 | lock this tick |
| n_dry | int | 0–1 | the lock produced no clear (counted at `on_resolve_end`) |
| L | int | 0–4 | layers cleared in this resolve |
| n_oh | int | 0–5 | overhang cubes in the locked piece |
| G' | int | **clamped 0–1000** | new value |

  **Output range:** clamped to [0, 1000]. The unclamped per-tick delta spans about −2210 (`per_layer` −500 ×
  L 4, `per_lock` −200, `per_s` −100 over 100 ms) to +2710 (`per_layer` +500 × 4, `per_lock` +200,
  `per_overhang` 100 × 5, `per_s` +10). `per_lock_no_clear` and a positive L cannot both apply. The clamp can
  therefore be reached in a single step. That is intended: a quad clear fully refills oxygen.
  Integer division of `per_s·Δt_ms` loses up to 1 milli per tick. Accumulate the remainder in `_frac` so the drift
  stays exact.

  **Trigger condition:** `high`: G' = 1000 · `low`: G' = 0 · `band`: G' ∉ [band_lo, band_hi] continuously for
  `band_grace_ms`.

  **Worked example (Deep Sea Bubble Build oxygen):** start 1000, `per_s` −20, `per_layer` +250, `mode` low,
  `warn_at` 800 → the warning fires at G ≤ 200. With no clears, oxygen runs out in 1000/20 = **50 s** and the
  warning comes at 40 s. A double clear at G = 300 gives 300 + 500 = 800.
  **Egg Temperature (band):** `per_s` +15, `per_layer` −120, band 300–700, grace 3000 ms. From 500, the egg
  overheats after (700−500)/15 ≈ 13.3 s, plus the 3 s grace, unless the player clears.

- **Telegraph:** `gauge_warning {gauge_id, value, eta_ms}` fires once when G crosses `warn_at`. It re-arms only
  after G moves back by `hysteresis`. `eta_ms` is a linear projection from the current `per_s`. **The trigger
  itself is always delayed until at least `warn_ms` after the warning.** If a big input jumps G from below
  `warn_at` straight to full, the effect is still scheduled `warn_ms` later, and a fall back below `warn_at`
  inside that window cancels it.
- **Edge cases:** (a) the same tick fills and clears → apply in the fixed order above, then test the trigger
  once; (b) the trigger fires on the same tick the goal is won → the goal wins and the trigger is dropped;
  (c) `per_s = 0` and `mode = low` → `eta_ms = -1` (the HUD shows no countdown); (d) `band_lo ≥ band_hi − 100` →
  `validate()` error; (e) several gauges whose `on_full = lose` fire on the same tick → one loss, with the
  reason taken from the lowest `gauge_id` in sorted order.
- **Test idea:** a fake clock with 50 ticks of 1000 ms at `per_s` −20 → G = 0 exactly on the 50th, the warning
  fires on the 40th, and the trigger fires ≥ 1500 ms after the warning. In band mode, step 2999 ms outside the
  band (no trigger), then step to 3000 ms (trigger). Snapshot round-trip equality.

#### A2 `tilt_plate` — NEW (`twist` layer) · priority 2

The stack stands on a plate that tilts toward its centre of mass. Building lopsided fills a topple risk meter.
Staying in danger too long makes the top of the heavy side slide off. This is grid-deterministic, unlike the
Jolt `balance`/`seesaw` variants. The moment maths reuses `WobbleRule.heavier_side`. The slip reuses wobble's
virtual-occupancy rigid move. The spring variant (Chroma Sky Climb) only changes the recovery term.

- **Hooks:** `on_lock` (recompute τ), `on_resolve_end` (danger count, warning, slip), `on_tick` (spring decay).
- **Params:** `tilt_warn` int 300–800 (default 500); `tilt_slip` int 500–950 (700, must be > `tilt_warn`);
  `slip_after_resolves` int 1–4 (2); `slip_cells` int 1–2 (1); `slip_layers` int 1–2 (1, the top layers of the
  heavy half that move); `spring_decay_per_s` int 0–200 (0 = rigid plate); `theta_max_deg` float 4–20 (12,
  visual only); `material_weight` flag (false; when true, cube weight = A4 hp).
- **Formula:**

  `M_x = Σ_c w_c·(2·c.x − (W−1))`, `M_z = Σ_c w_c·(2·c.z − (D−1))`, `N_w = Σ_c w_c`

  `τ = 1000 · max( |M_x| / (N_w·(W−1)), |M_z| / (N_w·(D−1)) )` (an axis term is 0 when its width − 1 = 0)

  `θ_display = theta_max_deg · τ / 1000` (spring: `τ_shown = max(τ, τ_shown − spring_decay_per_s·Δt)`)

| Symbol | Type | Range | Description |
|---|---|---|---|
| c | Vector3i | in board | each occupied, active, non-rock cube |
| w_c | int | 1–4 | 1, or the material hp when `material_weight` |
| W, D | int | 1–10 | board width / depth |
| M_x, M_z | int | ±N_w·(W−1) | moments in half-cell units around the plate centre |
| N_w | int | 0–1000 | total weight |
| τ | int | **0–1000** | centre-of-mass offset as a share of the half-width (0 = centred, 1000 = all weight on the rim) |

  **Output range:** bounded to [0, 1000] by construction (each cube's |2c−(W−1)| ≤ W−1). There is a division by
  zero when N_w = 0 → define τ = 0. W = 1 or D = 1 → that axis term is 0.
  **Worked example:** W = 5, cubes at x = 0, 3, 4, 4 (z centred, w = 1): M_x = −4+2+4+4 = 6, N_w·(W−1) = 16 →
  τ = 375 (safe). Add two cubes at x = 4: M_x = 14, N_w = 6 → τ = 14/24 = 583 → warning band. Add a third:
  M_x = 18, N_w = 7, τ = 18/28 = 643. One more: 22/32 = 688. One more: 26/36 = 722 ≥ 700 → danger. After 2
  consecutive resolves in danger, the top layer of the +x half slides 1 cell toward +x. Cubes pushed past the rim
  are removed (`Cause.TRIM`, event `tilt_popoff`).
- **Telegraph:** a `tilt_state {tau, theta, axis, sign}` event on every recompute, so the plate visibly leans.
  `tilt_warning {resolves_left}` fires the first time τ ≥ `tilt_slip`. The slip happens no earlier than the next
  resolve end, so the player always gets at least one placement to rebalance. Bringing τ back below
  `tilt_slip` resets the danger count.
- **Edge cases:** (a) `M_x` and `M_z` give the same normalised value → slip along x (the same tie-break as
  wobble); (b) the slip target is blocked → `tilt_hold` and the danger count stays (no infinite retries: at most
  one slip attempt per resolve); (c) a clear in the same resolve as the danger count → recompute τ after the
  collapse, before counting; (d) rocks and authored obstacles are fixed to the plate and are excluded from
  M and N; (e) the slip leaves a cube unsupported → the virtual drop lands it in the same buffered move (no
  extra resolve pass).
- **Test idea:** the boards from the worked example give τ = 375, 583, 722; a symmetric board gives τ = 0;
  an empty board gives 0 with no error; a 1-wide board gives no x-term; 2 danger resolves → exactly one
  `move_cells`, and cells pushed off the rim are removed.

#### A3 `span_goal` — NEW goal evaluator + walker · priority 3

Win by connecting a walkable surface from anchor A to anchor B across a chasm. The chasm is made of inactive
mask columns: pieces that fall into it are trimmed. The rail/pipe variant (Runaway Rail, Sweet Rush Rails,
Coral Conduit) requires the connecting cubes to carry a `conduit` tag.

- **Hooks/slots:** goal slot `span`. `on_resolve_end` recomputes reachability (as an evaluator, not a writer);
  `on_tick` walks the mascot once the path is complete (the same `walk_ms` cadence as mg06: 250).
- **Params:** `anchor_a`, `anchor_b` ([x, z]); `step_max` int 1–2 (1; matches mg06 and the Jolt 1.05 check);
  `walk_layer_min` int (0); `conduit_only` flag (false); `walk_ms` int 150–600 (250); `hold_ms` int 0–2000
  (500: the path must stay intact for this long before the walk starts, to avoid a win on a piece that is about
  to be eaten).
- **Formula:** a surface graph over ground columns. Node (x, z) has height h(x, z) = the top occupied layer
  (or −1 if none, which blocks). There is an edge between face-adjacent columns when `|h₁ − h₂| ≤ step_max`
  and both heights are ≥ `walk_layer_min`. Breadth-first search from A, in canonical neighbour order.

  `progress = 1000 · max_{n ∈ reach(A)} proj(n) / proj(B)`, where `proj(n) = (n − A)·(B − A)` (dot product,
  integer)

| Symbol | Type | Range | Description |
|---|---|---|---|
| h(x,z) | int | −1 – h_play | column top |
| proj(n) | int | ≤ proj(B) | progress of node n along the A→B direction |
| progress | int | **clamped 0–1000** | shown on the HUD |

  **Output range:** clamped to [0, 1000] (nodes behind A give a negative projection → 0). proj(B) = 0 only if
  A = B, which `validate()` rejects.
  **Worked example:** A = (0, 1), B = (7, 1), heights along z = 1: [1, 1, 2, −1, 2, 2, 1, 1]. Reach stops at
  x = 2 because column 3 is empty → progress = 1000·2/7 = 285. A piece fills column 3 to height 2 →
  B is reachable → 1000, then after 500 ms the walker starts and finishes in 7 × 250 = 1.75 s.
- **Telegraph:** this is not a hazard. Any hazard paired with it (bird peck, `storm_bolt`) uses its own warning.
  The HUD shows the reach frontier in the same colour as mg06 `walkway`.
- **Edge cases:** (a) the path breaks during the walk → the walker stops at the last intact node, and the win
  waits until it is reconnected; (b) several routes → the BFS takes the first in canonical order (deterministic
  walker); (c) `conduit_only` and a mixed path → non-conduit cubes count as blocked nodes; (d) gravity axis
  changes (`flip`) → recompute in the new ground plane; anchors are stored as ground coordinates.
- **Test idea:** the heights from the worked example → 285 then 1000; a step of 2 with `step_max` 1 → blocked;
  A = B fails validation; a path broken mid-walk freezes the walker; a seeded run gives the same result on 2
  instances.

#### A4 `material_hp` — PARTIAL → generalise · priority 4

Block strength by material. `lava_rock_spawn` already stores `hits_left` and removes the cube with
`Cause.DAMAGE` at 0. This atom moves that behaviour into a shared status (`hp`, `material`) and a damage helper,
`MaterialHp.damage(api, cell, amount) -> int` (returns the unused damage). Fort, dig and shatter games all
call it.

- **Hooks:** `on_level_start` (stamp the authored materials), `on_lock` (stamp a piece's material from a piece
  flag or a material bag), `on_clear` (optional `clear_damage_adjacent`).
- **Params:** `materials` dict id → hp. **Proposed defaults:** `glass` 1, `wood` 2, `stone` 3, `iron` 4. These
  are new registry entries. The existing `rock_hp` = 2, `crate_hp` = 1 and `junk_hp` = 1 stay authoritative for
  those obstacles. `clear_damage_adjacent` int 0–1 (0; registry `adjacent_damage` = 0); `piece_material` string
  (`"wood"`).
- **Formula:** `hp' = hp − min(hp, d)`, `d_left = d − min(hp, d)`. The cube is removed when hp' = 0.
  Fort strength `F = Σ hp`. `destruction‰ = 1000 · (F₀ − F) / F₀`.

| Symbol | Type | Range | Description |
|---|---|---|---|
| hp | int | 1–4 | current block strength |
| d | int | 0–12 | incoming damage |
| d_left | int | 0–12 | carried to the next cube (pierce) |
| F, F₀ | int | 0–4000 | current / starting fort strength |
| destruction‰ | int | **0–1000** | the Shatter Shootout "Destruction %" HUD value |

  **Output range:** hp' ∈ [0, hp]; destruction‰ ∈ [0, 1000]. F₀ = 0 (no fort) → destruction‰ is defined as 0.
  **Worked example:** a column top-down glass(1), wood(2), stone(3) takes d = 3: glass → 0 (d_left 2), wood → 0
  (d_left 0). 2 cubes are destroyed and the stone is untouched. F drops by 3. If F₀ = 60, destruction‰ = 50.
- **Telegraph:** a crack decal per hp step (`material_cracked {cell, hp}`), as with `rock_cracked`.
- **Edge cases:** a cleared layer removes cubes regardless of hp (`Cause.CLEAR`); only `DAMAGE` respects hp.
  A cube with hp that moves through `move_cells` keeps its status. `material_weight` in A2 reads this hp.
- **Test idea:** the d = 3 column above; d greater than the column total → d_left > 0 is returned; a clear
  ignores hp; the status survives a conveyor shift.

#### A5 `siege_shot` — NEW (session layer) · priority 5

Line clears earn ammo. Each shot is aimed at one column of a rival's fort, shows a landing marker for
`shot_warn_ms`, then lands and applies A4 damage from the top down. The fort is an authored zone that ignores
clears (`clear_protected`, like the rock), so a player's own clears never destroy their own fort.

- **Hooks (session):** `tick` (convert `LAYERS_CLEARED` events into ammo), `command mg_aim {x, z}` /
  `mg_fire`, `preview_attack` (fixes the target column and computes the predicted cells), `attack`
  (applies damage through `MaterialHp.damage`).
- **Params:** `ammo_per_layer` int 1–2 (1); `ammo_max` int 1–5 (3); `shot_power` int 2–6 (3);
  `power_per_extra_layer` int 0–2 (1, a multi-clear makes a heavier shot); `pierce_max` int 1–4 (3);
  `splash` int 0–1 (0, damages the 4 face neighbours of the top cube by 1); `shot_warn_ms` 600–3000 (1500);
  `fire_cooldown_ms` 500–3000 (1000).
- **Formula:** shot power `P = shot_power + power_per_extra_layer·(L_src − 1)`, where L_src is the size of the
  clear that minted the ammo. Damage walks down the column: at most `pierce_max` cubes, stopping when d = 0.
  Expected cubes destroyed in a uniform column of hp h: `k = min(pierce_max, ⌊P / h⌋)`.

| Symbol | Type | Range | Description |
|---|---|---|---|
| L_src | int | 1–4 | layers in the clear that produced this ammo |
| P | int | 2–12 | shot damage |
| h | int | 1–4 | material hp |
| k | int | 0–4 | cubes destroyed |

  **Output range:** P ∈ [2, 12] (shot_power 6, extra 2, quad). k is bounded by `pierce_max`. P < h → k = 0, but
  the top cube still loses P hp (the shot is never wasted).
  **Worked example:** a double clear → P = 3 + 1 = 4 against a stone column (h = 3): the top stone is destroyed,
  the next stone is left at hp 2 → k = 1. A quad → P = 6 → k = 2.
- **Telegraph:** the defender sees a reticle on the column and a projected crack preview for `shot_warn_ms`.
  The attacker sees the trajectory arc (cosmetic only: landing is resolved on the grid, so there is no physics
  non-determinism).
- **Edge cases:** (a) the target column is empty at landing → the shot fizzles (`siege_fizzle`, the ammo is
  spent, as with `storm_bolt`); (b) the column changed during the warning → damage hits the column's current
  top, because the column is fixed but the cells are not; (c) the target player has become a ghost or left →
  the host retargets to the living rival with the highest F (a fixed rule, as items do at send time); (d) firing
  at an `ammo_max` cap → extra clears do not mint ammo (`ammo_full` event).
- **Test idea:** the session receives 1 double clear → ammo 1 with P 4; a fire into an authored stone column
  gives one destroyed cube and one hp-2 cube after 1500 ms and not before; an empty column fizzles; a ghost
  target is retargeted.

#### A6 `boss_hp` — NEW goal + behaviour · priority 6

A boss health bar damaged by clears. Bigger clears hit harder. HP thresholds start telegraphed boss phases that
switch on existing hazard twists. Like `bonk_boss`, damage is a separate metric and never counts as clear credit.

- **Hooks:** `on_clear` (damage), `on_resolve_end` (phase check), `on_tick` (attack schedule). Goal slot
  `boss_hp`.
- **Params:** `boss_hp` int 100–1000 (240); `dmg_base` int 5–20 (10); `multi_bonus` permille 0–1000 (500);
  `combo_bonus` int 0–20 (5; combo = consecutive clearing resolves); `phases` list of permille thresholds
  (`[660, 330]`); `phase_rules` list of rule ids (`["storm_bolt", "crab_claw"]`); `phase_warn_ms` 1500–4000
  (2500); `coop_shared` flag (false; true = one host-arbitrated pool via `request_shared`).
- **Formula:** `D = dmg_base · L · (1000 + multi_bonus·(L − 1)) / 1000 + combo_bonus · max(0, C − 1)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| L | int | 1–4 | layers cleared this resolve |
| C | int | 1–10 (capped) | consecutive clearing resolves including this one |
| D | int | 5–(20·4·4 + 20·9) = 500 | damage this resolve |
| HP | int | 0–boss_hp | remaining, **clamped at 0** |

  **Output range:** D ∈ [5, 500] across the param ranges. At the defaults, D ∈ [10, 145]. HP is clamped at 0, so
  overkill is discarded.
  **Worked example (defaults):** single = 10; double = 10·2·1.5 = 30; triple = 10·3·2 = 60; quad = 10·4·2.5 =
  100. A double on a 3-resolve streak = 30 + 10 = 40. A 240-HP boss takes 24 singles, or 2 quads + 1 double +
  1 single. This rewards building up for big clears, which suits a 60–90 s round.
- **Telegraph:** crossing a phase threshold emits `boss_phase_warning {phase, rule, due_ms}`. The boss winds up
  (an art cue) and the phase rule activates only after `phase_warn_ms`. The phase rule's own warnings still
  apply to each attack.
- **Edge cases:** one clear crosses two thresholds → both phases queue in order, separated by `phase_warn_ms`;
  a clear that wins (HP 0) cancels any pending phase; damage done by rescue/trim wipes is ignored (only
  `Cause.CLEAR`); in coop, simultaneous kills are resolved by the host, so the first authority message wins.
- **Test idea:** the D table above, exact; the combo resets after a dry resolve; a single crossing of 660 from
  700 → the phase is due at +2500 ms; HP never goes below 0; a trim wipe deals no damage.

#### A7 `delivery_intake` — NEW (`mechanic` layer) · priority 7

Authored intake tiles at the end of a `conveyor`/`mill_belt` path consume cubes the belt pushes into them and
score them against a visible order. "Wrong" deliveries feed an A1 gauge (jam).

- **Hooks:** `on_level_start` (orders queue from `api.rng()`), `on_resolve_end` (after the belt rule has moved
  content: cubes now standing on intake cells are consumed with `remove_cell`, `Cause.TRIM` until a `DELIVER`
  cause exists).
- **Params:** `intake` list of [x, z]; `order_size` int 2–8 (4 cubes); `order_key` enum `colour`/`shape`
  (`colour`); `order_preview` int 1–3 (2); `score_match` int (10 per cube); `score_wrong` int (0); `jam_per_wrong`
  int 0–300 (150, sent to the gauge with `gauge_id = "jam"`); `belt_warn_ms` 600–3000 (1000; the belt must emit a
  shift warning when paired with an intake).
- **Formula:** `S = Σ_delivered cube (match ? score_match : score_wrong)`. An order completes when
  `matched ≥ order_size`, and the next order is shown. Throughput `≈ order_size / (conveyor_every × t_lock)`.
  **Worked example:** order red ×4, the belt carries a red L-tetromino into the intake → 4 matches → +40, order
  complete. A blue I → 4 wrong → +0 and jam +600 (→ 60 % of the jam gauge).
- **Telegraph:** the belt warning (`conveyor_warning`) plus the intake glow showing the current order colour.
- **Edge cases:** a piece only partly over the intake → only the cells over the intake are consumed, and the rest
  remains (it may collapse by the level's collapse rule); a rainbow cube (`status.rainbow`) matches any colour;
  the order completes mid-piece → the overflow counts toward the next order.
- **Test idea:** a scripted belt shift consumes exactly the intake cells; the red-L example gives 40; the
  rainbow example matches; jam gauge input arrives.

#### A8 `laser_sweep` — NEW (`twist` layer) · priority 8

A beam marks one row (an x-line or a z-line) at a seeded height, then removes the cube in each column of that
row with `Cause.DAMAGE` (so A4 hp applies).

- **Hooks:** `on_level_start`, `on_tick` (schedule, warning, fire), `on_clear` (optional cancel).
- **Params:** `sweep_every_ms` 6000–30000 (12000); `sweep_warn_ms` 1000–4000 (2000); `sweep_axis`
  `x`/`z`/`alt` (`alt`); `sweep_height` `top`/`seeded` (`top` = the highest layer with ≥ 1 cube); `sweep_damage`
  int 1–2 (1); `cancel_on_clear` flag (true: clearing the marked layer during the warning disarms the beam).
- **Formula:** cubes hit = the occupied cells of line ℓ at layer y. Expected loss ≤ W (or D). Rate cap: at most
  `W / (sweep_every_ms/1000)` cubes per second, i.e. 5 cubes per 12 s at W = 5.
- **Telegraph:** a red guide line drawn through the target cells for `sweep_warn_ms`, with an audio charge-up.
- **Edge cases:** the line is empty at fire time → `laser_fizzle`; the marked cells are moved by a belt during
  the warning → the beam keeps its world line (a fixed beam, as the moving storm bolt does not); the line holds a
  rock → the rock takes damage per A4.
- **Test idea:** a seeded schedule fires at 12000/24000 ms; there is no removal before warn + due; a clear
  cancels; it damages but does not remove an hp-2 cube.

#### A9 `strata_dig` — COMPOSITE + thin NEW helper · priority 9

Dig mode: the board starts filled with gapped strata, and clearing them digs downward. The feed keeps
`keep_height` layers present. New strata get harder with depth, and some contain a gem that is collected when
its layer clears.

- **Reuse:** the `rising_silt` gap generator and reachability guard (the feed), `dig_rescue` semantics (only a
  clear rescues), `items`-style collection, A4 hp.
- **New helper `strata_dig` (`mechanic`):** `on_level_start` (seed strata), `on_resolve_end` (after clears:
  if height < `keep_height`, push one new layer up from the floor with its depth index).
- **Params:** `keep_height` int 3–8 (5); `gaps_per_layer` int 1–3 (1); `band_depth` int 2–10 (4);
  `hp_max` int 1–4 (3); `p_gem` permille 0–500 (250).
- **Formula:** `hp(d) = min(hp_max, 1 + ⌊d / band_depth⌋)`; `depth_m = layers_cleared` (HUD "Depth: 32 m" =
  `depth_m × metres_per_layer`, a cosmetic value, default 2). Expected gems per layer = p_gem/1000.
  **Worked example:** band 4 → layers 0–3 hp 1, 4–7 hp 2, 8+ hp 3. After 12 clears, 3 gems are expected.
- **Telegraph:** the next stratum is previewed under the floor (its gem column is visible) one push ahead.
- **Edge cases:** a gem destroyed by damage (laser, hp) is **lost**, not collected (matches `dig_rescue`);
  a feed blocked by a full column → it waits for the next clear (same as `rising_silt`).
- **Test idea:** the hp bands at d = 3/4/8; a gem is collected only by `Cause.CLEAR`; the feed keeps height ≥
  `keep_height` after each resolve.

#### A10 `territory_claim` — NEW (session layer) · priority 10

A shared tile map arbitrated by the host. A player claims tiles (by cursor stamp, as in mg20, or by landing a
piece on the shared arena map). The score is the number of owned tiles.

- **Hooks (session):** `command mg_claim`, `_authority` (the host orders claims by arrival, then by player id),
  `tick` (dry timer, score).
- **Params:** `map_size` 5–9 (7); `steal_cooldown_ms` 0–3000 (1500: a tile that just changed owner cannot change
  again yet); `dry_ms` 0–20000 (0 = never locks; > 0 = a tile owned that long becomes permanent); `final_lock_ms`
  (3000: the last 3 s freeze claims and show the tally).
- **Formula:** `share_i = 1000 · owned_i / tiles_total`; points_i = owned_i. The winner has max owned_i; a tie →
  the higher count of permanent (dry) tiles, then a draw.
- **Telegraph:** a contested tile flashes the attacker's colour for `steal_cooldown_ms` before it changes owner
  (the defender can re-stamp to keep it). `final_lock_ms` is announced on screen.
- **Edge cases:** two claims on the same tile on the same tick → the host order decides, and the loser gets
  `claim_rejected`; a player becomes a ghost → their tiles stay theirs, but they cannot claim.
- **Test idea:** host ordering with 2 simultaneous claims; the cooldown blocks a re-steal at 1499 ms but allows it
  at 1500 ms; the share sums to 1000 when the map is full.

#### A11 `herd_critter` — NEW, deferred · priority 11

Critters walk on the top surface. Each step they move to a seeded reachable neighbour (`|Δh| ≤ 1`), biased
toward lower ground. A pen tile captures them. The player builds walls to steer them. Reuses `hatching_eggs`
(reachable-column hop with a fixed tie order). Move weight `w = 1 + bias·max(0, h_now − h_next)`. A piece landing
on a critter bonks it to the nearest free surface, with a 1-lock telegraph shown as a "!" above any critter
under the ghost piece. Spec on request.

#### A12 `balloon_lift` — PARTIAL, deferred · priority 12

Crates rise one layer per `lift_every_ms` while ≥ `balloons_needed` balloon cubes are attached. Today's `balloon`
only halves gravity. Used by one hub vignette only; defer until a minigame commits to it.

### 4. Level-module contract (campaign composition + tournament versus)

**Decision (user, 2026-10-13):** minigame mechanics are not separate games. Every atom is a **module** that
runs *alongside* the normal falling-block loop inside campaign levels. It is reskinned per biome and combined
with other modules. The same modules make up head-to-head tournament rounds, which the randomizer
(`design/gdd/mode-minigame-randomizer.md`) picks at random. A "minigame" is therefore just a level template
with 1–3 modules and a module-driven goal.

#### 4.1 Common fields (added to every atom's rule JSON / module entry)

| Field | Type | Values | Default | Rule |
|---|---|---|---|---|
| `start` | dict | `{"on":"level_start"}` · `{"on":"time_ms","value":n}` · `{"on":"clears","value":n}` · `{"on":"height","value":layer}` · `{"on":"after","module":id}` | level_start | Before start, the module subscribes to no hooks and draws no RNG. `after` chains stages (the `bake_stage` swap pattern). |
| `until` | dict | `{"on":"time_ms"}` · `"clears"` · `"height"` · `"hp_zero"` (A4 fort / A6 boss) · `"reached"` (A3) · `"orders"` (A7) · `"depth"` / `"gems"` (A9) · `"gauge"` (A1 value crosses) · `"never"` | never | When the condition becomes true at `on_resolve_end`, the module emits `<id>_ended`, **cancels any pending warning without firing it** (a hazard never acts after it has ended), and stops. |
| `until_role` | enum | `goal` · `stage` · `stop` | stop | `goal`: meeting `until` wins the level (it fills the goal slot, like `bonk_boss`). `stage`: starts the module that names this one in `start.after`. `stop`: the module just stops, and the level goal is unaffected. At most **one** `goal` module per level. |
| `skin` | string | a biome skin id (table 4.2) | `"default"` | Presentation only: art set, SFX bank, HUD icon, the event `skin` tag. **A skin must never change a rule or a param.** Same convention as the existing `conveyor.skin` / `climber_boss.skin`. An unknown skin → `"default"` plus a validator warning. |
| `versus` | dict | `{"attack":effect_id,"charge":n,"cap_ms":n}` or `{}` | per atom (4.4) | Used only in tournament rounds; ignored in solo campaign. |

#### 4.2 Biome skin hooks

The five biomes that exist in data/art (meadow, candy, lava, underwater, forest) plus two mockup biomes
(ice, space) that are pending art direction. Each cell is a skin id. Names are placeholders for the art
director.

| Atom | meadow | candy | lava | underwater | forest | ice* | space* |
|---|---|---|---|---|---|---|---|
| A1 gauge | `wind_sock` | `sweetness` | `heat` | `oxygen` | `sap_stability` | `frostbite` | `cargo_security` |
| A2 tilt | `seesaw_log` | `cake_plate` | `basalt_slab` | `ship_deck` | `stump_spring` | `ice_floe` | `cloud_pad` |
| A3 span | `plank_bridge` | `candy_rails` | `stepping_basalt` | `coral_conduit` | `vine_bridge` | `ice_ramp` | `light_bridge` |
| A4 hp materials | grass/wood/stone/iron | sugar-glass/gingerbread/rock-candy/jawbreaker | ash/obsidian/basalt/iron | coral/driftwood/stone/hull | moss/log/stone/iron | snow/ice/stone/iron | glass/panel/alloy/core |
| A5 siege | `catapult_castle` | `candy_cannon` | `magma_sling` | `pirate_cannon` | `acorn_trebuchet` | `snowball_fort` | `airship_cannon` |
| A6 boss | `scarecrow_giant` | `cake_monster` | `lava_golem` | `kraken` | `jungle_giant` | `yeti` | `mothership` |
| A7 intake | `mill_hopper` | `bakery_oven` | `forge` | `salvage_crane` | `sawmill` | `ice_factory` | `cargo_bay` |
| A8 laser | `sun_beam` | `licorice_whip` | `lava_jet` | `eel_current` | `storm_ray` | `icicle_line` | `laser_grid` |
| A9 dig | `meadow_soil` | `cake_layers` | `rubble_rumble` | `silt_salvage` | `root_mine` | `glacier_core` | `asteroid_core` |
| A10 territory | `flower_claim` | `frosting_splat` | `crust_claim` | `coral_claim` | `moss_claim` | `snow_angel` | `neon_splat` |

\*ice and space are not yet registered biomes. Their skins fall back to `default` until art direction confirms
them.

#### 4.3 Composition with other modules in the same level

**Per-resolve evaluation order.** This extends the Mechanics README write order. Earlier steps write before
later steps read.

1. Content movers: `conveyor` / `mill_belt`, A2 slip, `turntable`.
2. A7 intake consumes cubes on intake cells.
3. Damage: A8 sweep, A5 shot landing, `storm_bolt` (A4 hp applies to all of them).
4. Clear detection and collapse (normal loop; A6 / A9 gem credit reads `Cause.CLEAR` here).
5. A9 strata feed (after collapse, so the height is final).
6. Readers: A2 τ recompute, A1 gauge inputs, A3 reachability.
7. `until` checks, then the goal slot.

**Level budget:** at most 1 goal module (`until_role = goal`); at most 2 hazard modules (A1 with a non-`none`
`on_full`, A2, A8, and any existing twist), which respects the framework's two-twist cap; at most 2 HUD meters
(A1 / A2 / A6 bar), plus the timer.

**Conflict matrix.** "✗" = hard conflict: add to `incompatible_with`; the validator rejects the level/round.
"⚠" = allowed but needs the listed constraint. A blank cell = free to combine.

| | A1 | A2 | A3 | A5 | A6 | A7 | A8 | A9 |
|---|---|---|---|---|---|---|---|---|
| **A2 tilt** | ⚠ `on_full≠slip` | — | | | | ✗ (the belt shifts the CoM every shift, so τ is not readable) | | |
| **A3 span** | | ⚠ slip may break the path; `hold_ms ≥ 1000` | — | | | ✗ (the belt moves the bridge) | ⚠ the sweep may not target the walk layer | ✗ (the feed raises the chasm floor) |
| **A5 siege** | | | | — | ✗ (two clear→damage sinks; pick one) | | | |
| **A6 boss** | | | | ✗ | — | | | |
| **A7 intake** | ⚠ the jam gauge is A1 | ✗ | ✗ | | | — | | ✗ (the feed pushes content into the intake) |
| **A9 dig** | | ⚠ `material_weight=false` | ✗ | | | ✗ | | — |

Conflicts with **existing rules**:

| Atom | ✗ with | ⚠ with |
|---|---|---|
| A2 tilt | `wobble` (double slip), `side_travel`, `flip` in `axis` mode (tilt assumes vertical gravity) | `turntable` (recompute after the turn), `rising_silt` |
| A3 span | `side_travel`, `flip`; `clear.enabled = true` with `slice` collapse (a clear deletes the bridge) unless `walk_layer_min` is above every clearable layer | `lava_rise` (walk layer must stay above the lava), `quicksand`, `crumble_tiles` |
| A5 / A6 | `bonk_boss`, `climber_boss` (one boss/damage sink per level) | `items` in versus (bomb items also deal damage; both are allowed, but must use separate counters) |
| A7 intake | `turntable`, `flip`, `piston_punch` | `mirror` |
| A8 laser | — | `storm_bolt` (same role; allowed only if the combined hazard rate is ≤ 1 per 8 s) |
| A9 dig | `rising_silt`, `lava_rise`, `quicksand` (each also owns the floor) | `anvil_drop` |
| A1 gauge | `pressure_cooker` / `fever_rush` only when both drive the same knob | — |

#### 4.4 Versus (head-to-head tournament rounds)

**Shared seed.** Each module's RNG stream is `Seeds.make_rng(round_seed, [module_id, gauge_id or ""])`, where
`round_seed` comes from the randomizer (`tournament_seed + round_index`). Both players therefore get the same
gauge schedule, tilt plate, chasm, fort layout, boss phases, orders, laser times and strata. Rival attacks use
the session's separate `attack_rng`, so receiving an attack never moves a player off the shared stream.
Mid-round randomness that depends on a player's own board (e.g. "lowest reachable column") stays per-board,
but its candidate ordering is canonical.

**Attack rules shared by every module:** an attack is minted only by the sender's own play (the `charge`
column); it is sent through `charge_send`; it is previewed to the target through `preview_attack` with
**`warn_ms ≥ 1500`**; it can never skip the target module's own warning; at most one attack per `cap_ms`
per target; a ghost or eliminated player is never targeted (the host retargets at send time, as `items` does);
an attack aimed at a module the target does not have is dropped (`attack_unmatched`).

| Atom | Versus shape | "Attack the rival" effect | Charged by | Cap |
|---|---|---|---|---|
| A1 gauge | mirrored race | `gauge_spike`: +150 to the rival's same `gauge_id` (it can push into the warning band; the trigger still waits for `warn_ms`) | each multi-layer clear | 1 / 5 s |
| A2 tilt | mirrored race (last standing / most layers) | `heavy_piece`: the rival's next queued piece is flagged weight 4 (iron skin) and shown in their preview | double+ clear | 1 / 8 s |
| A3 span | race to cross | `bird_peck` (exists, mg06): removes one cube on the rival's current path | 4 locks (mg06 `bird_charge_ms` pacing alternative) | 1 / 10 s |
| A4 hp | (attribute) | — | — | — |
| A5 siege | **direct duel**: each player's fort is the other's target | the shot itself (§3 A5) | ammo from clears | `fire_cooldown_ms` |
| A6 boss | race on identical bosses (or coop on one shared pool, if `coop_shared`) | `boss_swipe`: triggers one of the rival boss's current-phase attacks early (with its normal warning) | every 60 damage dealt | 1 / 10 s |
| A7 intake | mirrored race on identical order lists | `jam`: +150 to the rival's jam gauge; or `order_swap` (their next order is swapped with the one after, shown one order ahead) | completed order | 1 / 8 s |
| A8 laser | mirrored hazard | `extra_sweep`: one extra sweep on the rival with the standard warning | triple+ clear | 1 / 10 s |
| A9 dig | race to depth / gems | `hard_stratum`: the rival's next feed layer gets hp +1 (preview shows it) | each gem collected | 1 / 8 s |
| A10 territory | **direct duel** on the shared map | the steal itself (§3 A10) | — | `steal_cooldown_ms` |

**Solo campaign stand-ins for the duel atoms.** A5 targets an authored static fort (`fort_target` module: a
second, non-playable board view whose blocks follow A4). A10 plays against a stencil (mg20 mode) or a scripted
painter. Both run through a single-player `WtMinigameSession` wrapper. *A dependency is open: campaign levels
do not host a session today.*

### 5. Open decisions (for the caller to present)

1. **Fort zone model (A5).** Is the fort (a) an authored zone protected from clears, separate from the build
   area (Recommended: clears always help you, and the fort strength is readable), or (b) the player's own stack,
   so that clears also weaken their fort (a strong tension, but it punishes the core verb)?
2. **Gauge as framework (A1).** Either (a) ship `gauge` and later refactor `pressure_cooker`/`wobble` meters onto
   it (Recommended: one HUD widget and one test suite), or (b) keep writing per-game meters (faster for the
   first minigame, but ~25 panels need meters).
3. **Stability on grid or Jolt (A2).** (a) A grid `tilt_plate` (Recommended: deterministic, works online and with
   replays), or (b) extend the Jolt `balance`/`seesaw` variants (better feel, but no lockstep hashes).
4. **Campaign host for session atoms (A5, A10).** (a) Add a single-player `WtMinigameSession` wrapper that
   campaign levels can host (Recommended: one code path for solo and versus), or (b) reimplement the A5 static
   fort as a pure `RuleBehaviour` (campaign only, and versus diverges).
5. **Territory input (A10).** (a) Cursor stamping on a shared map, as in mg20 (Recommended: reuses the existing
   session code), or (b) pieces dropped onto a shared arena board (needs a multi-owner BoardSim, which does not
   exist yet).

## Formulas

All formulas, with variable tables, ranges and worked examples, are inline in each atom in §3. Summary:

| Atom | Formula | Output range |
|---|---|---|
| A1 gauge | `G' = clamp(G + per_s·Δt/1000 + per_lock·n + per_lock_no_clear·n_dry + per_layer·L + per_overhang·n_oh, 0, 1000)` | 0–1000 (clamped) |
| A2 tilt | `τ = 1000·max(|M_x|/(N_w(W−1)), |M_z|/(N_w(D−1)))` | 0–1000 (by construction; N_w = 0 → 0) |
| A3 span | `progress = 1000·max proj(n)/proj(B)` | 0–1000 (clamped) |
| A4 hp | `hp' = hp − min(hp, d)`; `destruction‰ = 1000(F₀−F)/F₀` | hp' 0–4; 0–1000 (F₀ = 0 → 0) |
| A5 shot | `P = shot_power + extra·(L_src−1)`; `k = min(pierce_max, ⌊P/h⌋)` | P 2–12; k 0–4 |
| A6 boss | `D = dmg_base·L·(1000 + multi·(L−1))/1000 + combo·max(0, C−1)` | 5–500; HP clamped ≥ 0 |
| A7 intake | `S = Σ match ? score_match : score_wrong` | 0–unbounded (round-time bounded) |
| A9 dig | `hp(d) = min(hp_max, 1 + ⌊d/band_depth⌋)` | 1–hp_max |
| A10 claim | `share_i = 1000·owned_i/tiles_total` | 0–1000 |

## Edge Cases

Per-atom edge cases are listed in §3. Cross-atom cases:

- **A2 + A4 `material_weight`:** a slip moves hp cubes and keeps their status. Damage that removes a heavy cube
  lowers τ at the next recompute, not in the middle of a resolve.
- **A1 `on_full = slip` + A2:** both may request a slip in the same resolve → only one slip per resolve (A2 wins;
  the gauge resets).
- **A5/A8 damage + A9 gems:** damage never collects a gem. A gem cube that is destroyed emits `gem_lost`.
- **A6 + rescue top-out:** rescue wipes never deal boss damage (only `Cause.CLEAR` counts).
- **Any hazard warning in progress when the round ends:** the hazard is dropped and nothing resolves after the
  results screen.
- **Ghost players (mg13 pattern):** session atoms (A5, A10) must accept a ghost as a sender, if the minigame
  allows it, and never as a target.

## Dependencies

- **Mechanics Module** (`src/mechanics/README.md`; RuleApi write order, `move_cells`, `api.rng()`, snapshot):
  A1–A4, A6–A9, A11. *Bidirectional note needed in the Mechanics README "Wave 4" section once implemented.*
- **Minigame Session** (`src/game/minigames/rules_*.gd`, `charge_send` / `preview_attack` / `attack` /
  `request_shared` / `_authority`): A5, A10.
- **Obstacles / Obstacle Clearing** (`design/gdd/obstacles.md`, `obstacle-clearing.md`; registry `rock_hp`,
  `crate_hp`, `junk_hp`, `layer_damage`, `adjacent_damage`): A4 (and through it A5, A8, A9).
- **Existing behaviours reused:** `wobble` (A2 moments and slip), `rising_silt` (A9), `dig_rescue` / `items`
  (A9), `conveyor` / `mill_belt` (A7; needs a `belt_warn_ms` warning), `bonk_boss` (A6 coexists with it),
  `hatching_eggs` (A11), `storm_bolt` / `crab_claw` (A6 phases).
- **WtMinigameGeometry** (`bridge_path`, `lava_interval`, `safe_layers`): A3 generalises `bridge_path`.
- **Physics Mode** (`design/gdd/physics-mode.md`): A2 is the grid counterpart of `balance`/`seesaw`. No shared
  code.
- **Minigame Randomizer / Tournament Flow** (`design/gdd/mode-minigame-randomizer.md`): supplies `round_seed`
  and the two-twist cap; module templates join its pool. *Needs a reciprocal note there.*
- **Level Data / Rule-Twist Framework** (`incompatible_with`, stage swaps): enforces §4.3.
- **HUD** (`design/gdd/hud.md`): one vertical meter widget used by A1, A2 and A6, with these keys:
  `gauge_state`, `tilt_state`, `boss_state`.

## Tuning Knobs

| Knob | Atom | Safe range | Default | Gameplay effect |
|---|---|---|---|---|
| `per_s` | A1 | −100–100 | 0 | Time pressure; −20 gives a 50 s oxygen tank |
| `per_layer` | A1 | −500–500 | 0 | How much clears relieve the gauge; ≥ 250 means one double fully saves you |
| `warn_at` / `warn_ms` | A1 | 500–950 / 600–4000 | 800 / 1500 | Readability; a lower warn_at gives earlier, calmer warnings |
| `band_grace_ms` | A1 | 1000–8000 | 3000 | Leniency outside the band |
| `tilt_slip` | A2 | 500–950 | 700 | How lopsided a stack may get; < 600 feels unfair on 5-wide boards |
| `slip_after_resolves` | A2 | 1–4 | 2 | Recovery window; 1 is harsh, 3+ is toothless |
| `step_max` | A3 | 1–2 | 1 | 2 makes bridges trivially easy |
| `hold_ms` | A3 | 0–2000 | 500 | Protects against wins on a path that is about to break |
| `materials` | A4 | hp 1–4 | glass 1, wood 2, stone 3, iron 4 | Fort toughness; >4 makes shots feel like they do nothing |
| `shot_power` / `pierce_max` | A5 | 2–6 / 1–4 | 3 / 3 | Siege pace; a target of about 8–12 shots per round for a 60-hp fort |
| `ammo_max` | A5 | 1–5 | 3 | Hoarding versus spending |
| `boss_hp` | A6 | 100–1000 | 240 | Round length; about 24 singles at the defaults |
| `multi_bonus` | A6 | 0–1000‰ | 500 | Reward for big clears (0 = linear) |
| `order_size` / `jam_per_wrong` | A7 | 2–8 / 0–300 | 4 / 150 | Delivery pace and how much mistakes cost |
| `sweep_every_ms` | A8 | 6000–30000 | 12000 | Laser pressure |
| `band_depth` / `p_gem` | A9 | 2–10 / 0–500‰ | 4 / 250 | Dig difficulty curve and reward density |
| `steal_cooldown_ms` | A10 | 0–3000 | 1500 | Churn of the territory war |

## Acceptance Criteria

1. Each NEW atom has a rule JSON in `assets/data/rules/` (for session atoms, a params block in the minigame
   entry), a `PLUGIN_ID`, a `snapshot()` that round-trips, and a gdUnit4 test under `tests/unit/mechanics/`
   (session atoms under `tests/unit/minigames/`) that covers the worked example in §3 exactly.
2. **Warning first:** for A1 (trigger), A2 (slip), A5 (shot), A6 (phase) and A8 (sweep), a test asserts that no
   board write from the hazard happens before `warn_ms` has elapsed since the matching `*_warning` event.
3. **Determinism:** two simulations with the same seed and the same command log produce identical snapshots
   after 600 ticks for every atom (session atoms: identical host-arbitrated state).
4. A1 oxygen preset: with no clears, G reaches 0 on the 50 000 ms tick (±0 ticks); the warning fires at 40 000 ms.
5. A2: the worked-example boards give τ = 375, 583, 722; an empty board gives τ = 0 with no error.
6. A3: the worked-example heights give progress 285 then 1000; A = B fails `validate()`.
7. A4/A5: a P = 4 shot into a stone column destroys exactly 1 cube and leaves the next at hp 2; an empty column
   fizzles and spends the ammo.
8. A6: the defaults give D = 10/30/60/100 for L = 1–4; HP never goes below 0; trim/rescue removal deals 0 damage.
9. A7: the red-L example scores 40 and completes the order; partial overlap consumes only the intake cells.
10. A9: a gem removed by `Cause.DAMAGE` emits `gem_lost` and does not increase the gem counter.
11. **Module stop:** for each hazard module, a test where `until` becomes true while its warning is pending
    asserts that `<id>_ended` is emitted and the hazard makes no board write afterwards.
12. **Composition validator:** every ✗ pair in §4.3 is rejected by level/round validation with a named error;
    every blank pair loads and runs 600 ticks without error.
13. **Skins are cosmetic:** the same seed and command log with two different `skin` values produce identical
    snapshots.
14. **Versus seed:** two boards in one round with the same `round_seed` produce identical module schedules
    (gauge/laser times, strata, orders, boss phases) until the first attack lands; attacks never consume the
    shared module stream.
15. **Attack telegraph:** every versus attack in §4.4 reaches the target's view ≥ 1500 ms before it changes
    their board; a ghost target is never chosen; an attack on a missing module is dropped.
16. Each atom is used in at least one prototype minigame config and launched with a retained screenshot in
    `production/qa/evidence/` (coding-standards: "a parse check is not a run").
