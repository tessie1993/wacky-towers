# Balance Review: Minigame Modules (Campaign Budgets, Combination Rules, Head-to-Head Fairness, Stars)

> **Owner**: balance / systems design | **Date**: 2026-10-13 | **Status**: Proposal. Every number is a placeholder from the models below. No playtest data exists.
> **Scope**: 8 modules. Rising hazard (`rising_hazard`, O1), bridge (`bridge_dash`), boss HP (`boss_hp`), balance meter (`balance_plate`), dig (`dig_down`), conveyor (`conveyor_sort`), fort siege (`fort_siege`) and territory paint (`paint_claim`).
> **Inputs read**:
> - `design/gdd/campaign-minigames.md` (module catalogue, biome plan, F1–F8)
> - `design/levels/minigame-stages.md`
> - `design/gdd/minigame-economy.md`
> - `production/qa/campaign-difficulty-review-2026-10-10.md`
> - `design/gdd/tournament-minigames.md` (F1 comeback, F2 leader send scale)
> - `design/gdd/scoring-stars.md` (F1 `star_times`)
> - `design/registry/entities.yaml`
>
> **Mockups viewed** (10 sheets, 37 panels): `mockup_01, 02, 03, 04, 06, 07, 09, 14, 17, 19`.
> **Not edited**: `design/gdd/minigame-mechanics-wave4.md`, which another designer owns.
> **User decisions honoured**: modules are composed inside levels, reskinned per biome, and drawn at random as head-to-head tournament rounds. Boards are 8×8 or larger. Pieces are random on every attempt.

---

## 0. Shared model and the 8×8 finding

### 0.1 The 8×8 layer arithmetic (read this first)

Registry `heartbeat`: `pieces_per_clear = U / (c · η)`.

| Progress unit | U (cells) | η (registry) | Pieces per unit at c = 4 | Seconds at t_ref = 5 s |
|---|---|---|---|---|
| Full 8×8 layer clear | 64 | 0.75 (`eta_layer`) | **21.3** | **107** |
| One 8-cell row | 8 | 0.80 (`eta_row`) | 2.5 | 12.5 |
| Masked 4×4 wall/footprint layer | 16 | 0.75 | 5.3 | 27 |
| 8×8 "height" at `height_coverage` 0.5 | 32 per layer | 0.75 | 10.7 per layer | 53 per layer |

**Consequence.** On an 8×8 board, any module that counts *full-layer clears* or *coverage height* gets roughly one unit of progress per 1–2 minutes. That affects `boss_hp` with layer damage, `dig_down` without a pre-fill, `clear_layers` and any coverage-based height. One unit per 1–2 minutes cannot fit the 60–120 s rounds or a phase of 2–5 min.

**Binding rule B0.** Every module must declare its **progress unit `U`**, and it must satisfy `U / (c·η) ≤ 6` pieces. The budgets below use these units:
- `boss_hp`: damage per **row**
- `dig_down`: pre-filled layers with `hole_cells` ≤ 12
- `balance_plate` and `rising_hazard`: highest-supported-cube height on a small effective footprint, not coverage height

`c = 4` is a placeholder for the level's piece-list mean (`mean_cubes`).

### 0.2 Reference piece time per tier (NEW, placeholder)

`t_ref(b) = t_ref_1 − Δt · (b − 1)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| b | int | 1–11 | Campaign tier (biome index): 1 Meadow, 2 Candy, 3 Ice, 4 Underwater, 5 Lava, 6 Forest, 7 Cave, 8 Clockwork, 9 Neon, 10 Celestial, 11 Carnival |
| t_ref_1 | float | 5–8 s | Median seconds per piece in a module at tier 1; default 6.0 |
| Δt | float | 0.1–0.35 s | Per-tier speed-up; default 0.25 |
| t_ref | float | 3.5–6.0 s | Median player seconds per placed piece in a module (hard drop available) |

- **Output range.** 6.0 s at b=1 down to 3.5 s at b=11, linear and unclamped. A floor of 2.5 s applies if the knobs push it lower.
- **Why it differs from the registry.** It is deliberately faster than the registry's `avg_piece_seconds` (8 s), because module verbs are shallow (bridge deck, footholds, ammo) compared with full-layer puzzle planning. Replace it with playtest medians per module.
- **Example.** b = 5 (Lava): 6.0 − 0.25·4 = **5.0 s**.

### 0.3 Difficulty position D and the tier band

Each module parameter is a function of one scalar, the difficulty position `D ∈ [0, 1]`.

- `D_lo(b) = D_0 + δ_b · (b − 1)`
- `D_hi(b) = D_lo(b) + w_band`
- `D_hard(b) = min(D_hi(b) + δ_hard, D_cap)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| D_0 | float | 0.05–0.25 | Tier-1 floor; default 0.15 |
| δ_b | float | 0.03–0.08 | Per-biome rise; default 0.06 |
| w_band | float | 0.05–0.15 | In-biome ramp for main levels (F3 appearance index k = 1 → 3); default 0.10 |
| δ_hard | float | 0.05–0.20 | Hard track h1–h3 offset; default 0.10 (≈ `hard_mult` 1.25 on mid-range params) |
| D_cap | float | 0.9–1.0 | Absolute ceiling; default 0.95 |
| D_intro | float | 0.2–0.4 | First-ever appearance of a module (Rule C4); default `min(D_lo(b), 0.30)` |

- **Output range.** `D_lo` runs from 0.15 to 0.75 and `D_hi` from 0.25 to 0.85. `D_hard` reaches at most 0.95.
- **Ramp within a biome.** Level slot k uses `D = D_lo + w_band · (k − 1)/2`.
- **Example.** Lava (b = 5): `D_lo` = 0.15 + 0.24 = **0.39**, `D_hi` = **0.49** and hard = **0.59**. A module that first appears at Cave (b = 7) teaches at `D_intro` = 0.30, not 0.51.

| b | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| D_lo–D_hi | .15–.25 | .21–.31 | .27–.37 | .33–.43 | .39–.49 | .45–.55 | .51–.61 | .57–.67 | .63–.73 | .69–.79 | .75–.85 |
| t_ref (s) | 6.00 | 5.75 | 5.50 | 5.25 | 5.00 | 4.75 | 4.50 | 4.25 | 4.00 | 3.75 | 3.50 |

**Relation to `campaign-minigames.md` F3.** F3 (`p_base·(1 + s_p(k−1))·hard_mult`) stays the authoring formula *inside* a band. This review adds the cross-biome band, which F3 lacks. If F3's output leaves `[p(D_lo), p(D_hard)]`, the validator warns. Reconciling the two is flagged for the systems designer.

### 0.4 Parameter mapping

`p(D) = p_easy + (p_hard − p_easy) · D`, rounded to the parameter's grain. Thresholded parameters (counts, colours, lanes) use the step cut-offs listed per module.

| Symbol | Type | Range | Description |
|---|---|---|---|
| p_easy / p_hard | per param | inside the module's safe range | Values at D = 0 and D = 1 |
| p | per param | between p_easy and p_hard | Authored parameter |

- **Output range.** Always inside the module's safe range, because both endpoints are.
- **Example.** `walker_step_ms` (900 → 400) at D = 0.44 gives 900 − 500·0.44 = **680 ms**.

---

## 1. Difficulty budget per module

Each module below has:
- **endpoints**: the parameter values at D = 0 and D = 1
- **a health check**: a derived ratio that must stay in band, otherwise the level is unwinnable or trivial
- **a per-tier table**: the `D_lo`–`D_hi` range for each tier

In the tables, "Campaign" marks the tiers where `campaign-minigames.md` uses the module. Tiers without a mark are reference values for tournament rounds and Carnival remixes.

### 1.1 `rising_hazard` (O1, overlay)

| Param | Easy (D=0) | Hard (D=1) | Grain | Notes |
|---|---|---|---|---|
| `r` (cells/s) | 0.040 | 0.150 | 0.001 | GDD safe range 0.04–0.15 |
| `h0` headroom (cells between the hazard start and the mascot or stack top) | 5 | 2 | 1 | |
| `warn_ms` (NEW: pre-rise telegraph) | 5 000 | 3 000 | 100 | Never below 3 000 (Rule C5) |

**Health check: outbuild ratio.**

`σ = r · t_ref / g_piece ≤ σ_max`

| Symbol | Type | Range | Description |
|---|---|---|---|
| r | float | 0.04–0.15 cells/s | Hazard rise rate |
| t_ref | float | 3.5–6 s | §0.2 |
| g_piece | float | 0.05–1.0 cells/piece | Height the *measured* target gains per median piece: summit footholds about 0.75; tower on footprint A gives `c·η/A` |
| σ | float | 0–∞ | Share of build capacity the hazard eats |
| σ_max | float | 0.6–0.85 | Default 0.75 |

- **Output range.** Unbounded above, and σ ≥ 1 means a median player cannot keep up. At `g_piece` = 0.75, σ runs from 0.30 (b1 lo) to 0.68 (b11 hard): in band.
- **Full 8×8 layers.** With `g_piece` = 4·0.75/64 = 0.047, σ is 5.1 at r = 0.04, so it is never winnable.
- **Rule.** `rising_hazard` may only be measured against a mascot, a foothold column or a masked footprint of 9 cells or fewer.
- **Example.** Lava b5 at D = 0.44: r = 0.088, t_ref 5.0, `g_piece` 0.75, so σ = 0.088·5/0.75 = **0.59**. That passes.
- **GDD note.** The GDD example `r = 0.08` for Lava sits at D = 0.36, just under the b5 band. That is fine for the teach level L04 at `D_lo`. h1–h3 should use about 0.10.

| b | r (cells/s) | h0 | warn_ms | Campaign |
|---|---|---|---|---|
| 1 | .057–.068 | 5–4 | 4 700–4 500 | — |
| 2 | .063–.074 | 4 | 4 580–4 380 | — |
| 3 | .070–.081 | 4 | 4 460–4 260 | Ice O (avalanche); first use at D_intro .27 → r .070 |
| 4 | .076–.087 | 4 | 4 340–4 140 | Underwater O (silt) |
| 5 | .083–.094 | 4 | 4 220–4 020 | Lava O |
| 6 | .090–.101 | 4–3 | 4 100–3 900 | — |
| 7 | .096–.107 | 3 | 3 980–3 780 | — |
| 8 | .103–.114 | 3 | 3 860–3 660 | Clockwork O |
| 9 | .109–.120 | 3 | 3 740–3 540 | — |
| 10 | .116–.127 | 3 | 3 620–3 420 | — |
| 11 | .123–.134 | 3–2 | 3 500–3 300 | Carnival rotation; hard ≤ .145 |

### 1.2 `bridge_dash`

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `gap_cells` | 3 | 10 | 1 | Capped at `W − 4` (two 2-cell banks) |
| `walker_step_ms` | 900 | 400 | 5 | GDD safe range 400–900 |
| `fill_layers` (NEW: deck layers that need support below) | 1 | 2 | step at D ≥ 0.5 | |
| `lane_width` (NEW) | 2 | 2 | — | Fixed; the deck is 2 cells wide in z |
| `ρ` (NEW: slack, the share of the walker's lead time a median player needs) | 0.55 | 0.90 | 0.01 | **The real difficulty knob**; the walker delay is derived from it |

**Derived: walker departure delay.**

- `t_col = lane_width · fill_layers · t_ref / (c · η_deck)`
- `T_need = gap_cells · max(0, t_col − walker_step_ms/1000)`
- `walker_delay = max(delay_min, T_need / ρ)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| t_col | float | 1.2–6 s | Median time to finish one gap column of deck |
| η_deck | float | 0.6–0.9 | Deck packing efficiency; default 0.75 |
| T_need | float | 0–50 s | Lead the builder needs before the walker steps onto the gap; it binds at the far bank when `t_col` > step |
| delay_min | int | 2 000–5 000 ms | Floor; default 3 000 |
| walker_delay | float | 3–60 s | Auto-departure time; the player may tap **Go** earlier (Rule S2) |

- **Output range.** At least `delay_min`. `T_need` is 0 when a column is built faster than the walker steps.
- **Example.** b5 at D = 0.44: gap 6, step 680 ms, fill 1, t_ref 5.0.
  - t_col = 2·1·5/(4·0.75) = 3.33 s
  - T_need = 6·(3.33 − 0.68) = 15.9 s
  - ρ = 0.55 + 0.35·0.44 = 0.70
  - delay = 15.9/0.70 = **22.7 s**
- **Health check.** ρ < 1 for every campaign slot, so the median player wins with margin. A ρ ≥ 1 is allowed only in tournament templates, where losing is fine.

| b | gap_cells | walker_step_ms | fill_layers | ρ | Campaign |
|---|---|---|---|---|---|
| 1 | 4–5 | 825–775 | 1 | .60–.64 | Meadow B, first use at D_intro .15 |
| 2 | 4–5 | 795–745 | 1 | .62–.66 | — |
| 3 | 5–6 | 765–715 | 1 | .64–.68 | Ice R (ice ramps) |
| 4 | 5–6 | 735–685 | 1 | .67–.70 | — |
| 5 | 6 | 705–655 | 1 | .69–.72 | Lava A |
| 6 | 6–7 | 675–625 | 1–2 | .71–.74 | — |
| 7 | 7 | 645–595 | 2 | .73–.76 | — |
| 8 | 7–8 | 615–565 | 2 | .75–.78 | — |
| 9 | 7–8 | 585–535 | 2 | .77–.81 | — |
| 10 | 8–9* | 555–505 | 2 | .79–.83 | — |
| 11 | 8–9* | 525–475 | 2 | .81–.85 | Carnival remix; hard ρ ≤ .88 |

\*A gap of 9 needs W ≥ 13. On a 12-wide board, clamp it to 8 and spend the difficulty on ρ instead.

### 1.3 `boss_hp`

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| Damage unit | **row** (U = W = 8) | row | — | B0. A full-layer damage unit gives hp ≈ 1 on 8×8 |
| `T_kill` target (NEW authoring target, s of net fire) | 60 | 120 | 1 | Drives `hp` |
| `attack_period_ms` | 12 000 | 6 000 | 100 | Inside GDD safe range 4 000–12 000 |
| `attack_cells` | 1 | 2 | step at D ≥ 0.5 | |

**Derived HP.**

- `t_hit = (U / (c · η_row)) · t_ref`
- `hp = max(3, round(T_kill / t_hit)) · dmg_per_clear`

**Health check: repair tax.**

`κ = (attack_cells / attack_period_s) / (c · η_layer / t_ref) ≤ κ_max`

| Symbol | Type | Range | Description |
|---|---|---|---|
| U | int | 8–16 | Cells per damage unit (row, or a masked 16-cell wall layer) |
| η_row | float | 0.8 | Registry `eta_row` |
| t_hit | float | 8–20 s | Median seconds per hit |
| T_kill | float | 60–120 s | Target net fire time |
| hp | int | 3–20 | Boss HP (in `dmg_per_clear` = 1 units) |
| κ | float | 0–1 | Share of build throughput spent repairing |
| κ_max | float | 0.25–0.45 | Default 0.40 |

- **Output range.** hp is 5 at b1 and 13 at b11 (table below). κ runs from 0.19 to about 0.36 over the bands, so it stays under κ_max.
- **Example.** b5 at D = 0.44:
  - t_hit = 8/(4·0.8)·5.0 = 12.5 s
  - T_kill = 60 + 60·0.44 = 86.4 s
  - hp = round(6.9) = **7**
  - κ = (1/9.36)/(3/5.0) = **0.18**
  - T_est = 7·12.5·(1 + 0.18) = **103 s**
- **GDD note.** The GDD example `hp: 10` in Lava is above band (it fits b9). Use 7 for L10 and up to 8 for h3.

| b | hp | attack_period_ms | attack_cells | Campaign |
|---|---|---|---|---|
| 1 | 5 | 11 100–10 500 | 1 | — |
| 2 | 5 | 10 740–10 140 | 1 | **Candy L10 finale; see Risk R14** |
| 3 | 6 | 10 380–9 780 | 1 | — |
| 4 | 6–7 | 10 020–9 420 | 1 | Underwater B (taught solo at L05) |
| 5 | 7 | 9 660–9 060 | 1 | Lava L10 |
| 6 | 7–8 | 9 300–8 700 | 1–2 | Forest L10 |
| 7 | 8–9 | 8 940–8 340 | 2 | Cave L10 |
| 8 | 9 | 8 580–7 980 | 2 | Clockwork L10 |
| 9 | 10 | 8 220–7 620 | 2 | — |
| 10 | 11 | 7 860–7 260 | 2 | Celestial L10 |
| 11 | 12–13 | 7 500–6 900 | 2 | Carnival L10 (hard ≥ 6 300 ms) |

### 1.4 `balance_plate` (balance meter)

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `w_base` (cells) | 8 | 5 | 1 | |
| `s_fail` | 0.05 | 0.25 | 0.01 | GDD safe range 0.05–0.3 |
| `t_grace` (s) | 3.0 | 1.0 | 0.1 | GDD safe range 0.5–3 |
| `target_height` | 6 | 12 | 1 | Highest-supported-cube height (B0). Needs `h_play` ≥ target + 4 |
| `topples_max` | 3 | 1 | 3 if D < .4, 2 if D < .8, else 1 | |
| `tilt_max` | 12° | 12° | — | A feel knob, kept out of difficulty |

**Health check: lateral tolerance.**

`τ = (w_base / 2) · (1 − s_fail)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| τ | float | 1.9–4.0 cells | Centre-of-mass offset the player may carry before the topple clock starts |

- **Output range.** τ = 3.7 at b1 lo and 1.95 at b11 hi. Keep τ ≥ 1.5, because one random 4-long piece placed off-centre can shift the centre of mass by about 1 cell.
- **Example.** b2 at D = 0.31: w 7 and s_fail 0.11, so τ = 3.5·0.89 = **3.1 cells**.

| b | w_base | s_fail | t_grace (s) | target_height | topples_max | Campaign |
|---|---|---|---|---|---|---|
| 1 | 8–7 | .08–.10 | 2.7–2.5 | 7–8 | 3 | Meadow bonus "Fruit Stack" (relaxed showcase) |
| 2 | 7 | .09–.11 | 2.6–2.4 | 7–8 | 3 | Candy A |
| 3 | 7 | .10–.12 | 2.5–2.3 | 8 | 3 | — |
| 4 | 7 | .12–.14 | 2.3–2.1 | 8–9 | 3–2 | — |
| 5 | 7 | .13–.15 | 2.2–2.0 | 8–9 | 3–2 | — |
| 6 | 7–6 | .14–.16 | 2.1–1.9 | 9 | 2 | Forest A |
| 7 | 6 | .15–.17 | 2.0–1.8 | 9–10 | 2 | — |
| 8 | 6 | .16–.18 | 1.9–1.7 | 9–10 | 2 | Clockwork R |
| 9 | 6 | .18–.20 | 1.7–1.5 | 10 | 2 | — |
| 10 | 6 | .19–.21 | 1.6–1.4 | 10–11 | 2 | Celestial bonus |
| 11 | 6–5 | .20–.22 | 1.5–1.3 | 11 | 2–1 | — |

### 1.5 `dig_down`

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `depth` (pre-filled layers to clear) | 3 | 9 | 1 | |
| `hole_cells` (NEW: free cells per pre-filled layer) | 8 | 8 | — | Fixed at about 2 pieces per layer (B0); safe range 6–12 |
| `hole_clusters` (NEW) | 1 | 3 | 1 if D < .35, 2 if D < .7, else 3 | One 8-cell trench is easy; 3 scattered pockets are hard to fit with random pieces |
| `rock_rate` (fraction of pre-fill cells that are 2-hit rock or `locked_cube`) | 0 | 0.15 | 0.01 | |
| `gems` | 1 | 3 | 1 | Star metric only (§4) |

**Derived time.**

`T_dig = depth · (ceil(hole_cells / (c · η_dig)) · t_ref + t_resolve)`

with η_dig = 0.8 / 0.7 / 0.6 for 1 / 2 / 3 clusters and `t_resolve` ≤ 1 s (registry `resolve_max_ms`).

- **Output range.** About 45 s (b1 lo) to 130 s (b11 hi).
- **Example.** b7 at `D_intro` 0.30: depth 5, 1 cluster, t_ref 4.5. That gives 5·(ceil(8/3.2) = 3 pieces · 4.5 + 1) = **72.5 s**.
- **Pressure.** Dig has **no pressure channel** of its own (Rule C1), so it is the ideal module to teach first in a biome.

| b | depth | hole_clusters | rock_rate | Campaign |
|---|---|---|---|---|
| 1 | 4–5 | 1 | .02–.04 | — |
| 2 | 4–5 | 1 | .03–.05 | — |
| 3 | 5 | 1–2 | .04–.06 | — |
| 4 | 5–6 | 1–2 | .05–.06 | — |
| 5 | 5–6 | 2 | .06–.07 | — |
| 6 | 6 | 2 | .07–.08 | — |
| 7 | 6–7 (**intro: 5**) | 2 (intro: 1) | .08–.09 (intro .05) | Cave A, first use |
| 8 | 6–7 | 2 | .09–.10 | — |
| 9 | 7 | 2–3 | .09–.11 | — |
| 10 | 7–8 | 2–3 | .10–.12 | — |
| 11 | 8 | 3 | .11–.13 | — |

### 1.6 `conveyor_sort`

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `hopper_colours` | 2 | 4 | 2 if D < .35, 3 if D < .7, else 4 | |
| `belt_speed` (cells/s) | 0.6 | 1.6 | 0.01 | |
| `miss_max` | 5 | 2 | 5 if D < .3, 4 if D < .5, 3 if D < .7, else 2 | |
| `sort_n` | derived | derived | 1 | `round(T_phase · a_med / t_ref)`, with T_phase = 60 + 30·D s and a_med = 0.8 |

**Health check: jam-free belt.**

`j = (ℓ / belt_speed) / (n_arms · t_ref) ≤ 0.5`

| Symbol | Type | Range | Description |
|---|---|---|---|
| ℓ | float | 1–4 cells | Mean piece extent along the belt; default 2 |
| n_arms | int | 2–4 | Arms (= `hopper_colours`) |
| j | float | 0–∞ | Belt occupancy; above 0.5, pieces pile up and cause unforced misses |

- **Output range.** The worst case is b1 lo: (2/0.75)/(2·6) = **0.22**. That passes on every tier.
- **Example.** b8 at `D_intro` 0.30:
  - colours 2, belt 0.90, miss_max 4
  - T_phase 69 s, so sort_n = round(69·0.8/4.25) = **13**
  - j = (2/0.9)/(2·4.25) = 0.26

| b | hopper_colours | belt_speed | miss_max | sort_n | Campaign |
|---|---|---|---|---|---|
| 1 | 2 | .75–.85 | 5 | 9 | — |
| 2 | 2 | .81–.91 | 5–4 | 9–10 | — |
| 3 | 2–3 | .87–.97 | 5–4 | 10 | — |
| 4 | 2–3 | .93–1.03 | 4 | 11 | — |
| 5 | 3 | .99–1.09 | 4 | 11–12 | — |
| 6 | 3 | 1.05–1.15 | 4–3 | 12–13 | — |
| 7 | 3 | 1.11–1.21 | 3 | 13–14 | — |
| 8 | 3 (**intro: 2**) | 1.17–1.27 (intro .90) | 3 (intro 4) | 15 (intro 13) | Clockwork A, first use |
| 9 | 3–4 | 1.23–1.33 | 3–2 | 16 | — |
| 10 | 3–4 | 1.29–1.39 | 2 | 17–18 | — |
| 11 | 4 | 1.35–1.45 | 2 | 19–20 | — |

### 1.7 `fort_siege`

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `build_pieces` (NEW: replaces the pure timer; Risk R1, Rule S2) | 10 | 6 | 1 | The build phase ends at `build_pieces` placed or at `build_phase_ms` = `build_pieces · t_ref · 1.5`, whichever comes first |
| `rival_fort_cells` (campaign scripted rival) | 24 | 60 | 1 | |
| `target_pct` | 40 | 80 | 1 | |
| `splash_cells` | 2 | 0 | 2 if D < .3, 1 if D < .7, else 0 | GDD safe range 0–2 |
| `return_fire_ms` | 15 000 | 6 000 | 100 | |
| `fort_min_cells` | 12 | 12 | — | GDD padding rule (F5) unchanged |
| Ammo | 1 piece = 1 lob | | | Matches the "Next Ammo" slot on the Fort Blast sheet (`mockup_02`) |

**Derived lob count.**

`N_shots = ceil(target_pct/100 · rival_fort_cells / e_hit)`, where `e_hit = p_hit · (c + splash_cells) + collapse`

| Symbol | Type | Range | Description |
|---|---|---|---|
| p_hit | float | 0.4–0.8 | Median hit rate; default 0.6 |
| collapse | float | 0–2 cells | Mean unsupported-cell bonus per hit; default 0.6 |
| e_hit | float | 3–6 cells | Cells removed per lob |
| N_shots | int | 4–20 | Lobs needed |

- **Output range.** 5 lobs at b1 lo to 14 at b11 hi.
- **Example.** b2 at D = 0.31:
  - rival 35 cells, target 52%, splash 1
  - e_hit = 0.6·5 + 0.6 = 3.6, so N_shots = ceil(18.2/3.6) = **6**
  - T_fort = (9 build + 6 lobs)·5.75 = **86 s**

| b | build_pieces | rival_fort_cells | target_pct | splash | return_fire_ms | Campaign |
|---|---|---|---|---|---|---|
| 1 | 9 | 29–33 | 46–50 | 2 | 13 650–12 750 | — |
| 2 | 9 | 32–35 | 48–52 | 2–1 | 13 110–12 210 | Candy B |
| 3 | 9–8 | 34–37 | 51–55 | 2–1 | 12 570–11 670 | — |
| 4 | 9–8 | 36–39 | 53–57 | 1 | 12 030–11 130 | — |
| 5 | 8 | 38–42 | 56–60 | 1 | 11 490–10 590 | Lava bonus "Fort Blast" (relaxed: use b4) |
| 6 | 8 | 40–44 | 58–62 | 1 | 10 950–10 050 | — |
| 7 | 8–7 | 42–46 | 60–64 | 1 | 10 410–9 510 | — |
| 8 | 8–7 | 45–48 | 63–67 | 1 | 9 870–8 970 | Clockwork bonus |
| 9 | 7 | 47–50 | 65–69 | 1–0 | 9 330–8 430 | — |
| 10 | 7 | 49–52 | 68–72 | 1–0 | 8 790–7 890 | — |
| 11 | 7 | 51–55 | 70–74 | 0 | 8 250–7 350 | Carnival B |

### 1.8 `paint_claim` (territory paint)

| Param | Easy | Hard | Grain | Notes |
|---|---|---|---|---|
| `target_pct` | 50 | 68 | 1 | Bounded by the steady-state check below |
| `q` (NEW: rival-to-player paint-rate ratio) | 0.20 | 0.40 | 0.01 | `rival_rate = q · π / t_ref` |
| `π` paint per piece (cells) | 3 | 3 | — | Placeholder; the mean top-surface footprint of a random piece |

**Health check: steady-state share.**

- `s* = 1 / (1 + q)`, and the rule is `target_pct/100 ≤ 0.95 · s*`
- Time to target: `T_paint = −(A / (v_p + v_r)) · ln(1 − target/s*)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| A | int | 64–144 | Paintable cells (8×8 and up) |
| v_p | float | 0.5–0.86 cells/s | Player paint rate, `π / t_ref` |
| v_r | float | 0.1–0.35 cells/s | Rival paint rate |
| s* | float | 0.71–0.83 | Owned share if both sides paint uniformly at random (median-player model) |
| T_paint | float | 40–150 s | Median time to reach target |

- **Output range.** T_paint is unbounded as target → s*, which is why the 0.95 cap exists.
- **Example.** b5 at D = 0.44:
  - target 58%, q 0.29, so s* = 0.776 and 0.95·s* = 0.737. That passes.
  - v_p = 0.6 and v_r = 0.17
  - T_paint = −(64/0.77)·ln(1 − 0.747) = **114 s**

| b | target_pct | q | Campaign |
|---|---|---|---|
| 1 | 53–55 | .23–.25 | — |
| 2 | 54–56 | .24–.26 | Candy bonus "Frosting Splat" (relaxed: use b1) |
| 3 | 55–57 | .25–.27 | — |
| 4 | 56–58 | .27–.29 | — |
| 5 | 57–59 | .28–.30 | — |
| 6 | 58–60 | .29–.31 | — |
| 7 | 59–61 | .30–.32 | — |
| 8 | 60–62 | .31–.33 | — |
| 9 | 61–63 | .33–.35 | Neon A |
| 10 | 62–64 | .34–.36 | — |
| 11 | 64–65 | .35–.37 | Carnival L10 + bonus |

---

## 2. Rules for combining modules

### 2.1 Pressure channels

A **pressure** is anything that forces a reaction on a clock the player does not control, or that can fail the level by itself. The global round timer `t_mg` is not a pressure. Pressures belong to channels:

| Channel | Sources (of the 8 modules, plus overlays and Sends) |
|---|---|
| TIME | `bridge_dash` walker; fuses |
| HAZARD | `rising_hazard`; `crumble_floor` |
| FORCE | `balance_plate` tilt/topple; `gust_wind`; floe shove |
| ATTACK | `boss_hp` attacks; `fort_siege` return fire or rival lobs; versus Sends of an *attack* kind |
| FLOW | `conveyor_sort` belt |
| RIVAL | `paint_claim` pest painter or rival seats |
| — (none) | `dig_down`; `pace_mascot` (visual only) |

**C1 – Two channels at most.** A phase may have at most **2 distinct pressure channels** active at once. This counts the primary's own channel, every overlay and, in tournaments, the template's Send.
- A Send or overlay in a channel that is already active *intensifies* that channel. It does not add one: Gust Sends on `stair_path` + `gust_wind` count once.
- This is stricter than `max_overlays_per_phase` = 2, which it supersedes for these modules.

### 2.2 Combined load

`L = D_(1) + ω · D_(2)`, and the rule is `L ≤ L_cap(b) = D_hi(b) + λ`, with `L_cap,hard = L_cap + δ_hard`.

| Symbol | Type | Range | Description |
|---|---|---|---|
| D_(1), D_(2) | float | 0–1 | Difficulty positions of the heaviest and second pressure source in the phase (a source with no channel counts as 0) |
| ω | float | 0.4–0.8 | Weight on the second source; default 0.6 |
| λ | float | 0.05–0.15 | Headroom for combining; default 0.10 |
| L | float | 0–1.6 | Combined load |

- **Output range.** L runs from 0 to 1.6, and the cap runs from 0.35 (b1) to 0.95 (b11), or 1.05 on the hard track.
- **Example.** Lava L04, `bridge_dash` + `rising_hazard`, with cap = 0.49 + 0.10 = 0.59:
  - At bridge D = 0.39 and rising D = 0.33, L = 0.39 + 0.6·0.33 = **0.588**. That passes.
  - At bridge D = 0.44, rising must satisfy D ≤ (0.59 − 0.44)/0.6 = **0.25**, which means r = 0.068.
- **Practical rule.** When two modules combine, the second runs about **one to two tiers below** its own band.

### 2.3 Teach, combine, warn

| # | Rule | Validator check |
|---|---|---|
| C2 | **Teach before combine.** A module (primary or overlay) may share a level with another module only after the profile has cleared a level where it was the **only** module. For overlays this means a level where the overlay sat on an already-known primary and nothing else was new. Sequential phases count as "sharing a level". | For each module m in level L, some earlier critical-path level must have `modules = [m]`, or `[known primary, m]` when m is an overlay |
| C3 | **One new thing per level.** At most one module the player has never met. A new biome skin of a known module is not new. | Count unseen ids ≤ 1 |
| C4 | **First appearance is soft.** First-ever appearance uses `D_intro` = min(`D_lo`, 0.30), no overlay, and is never in an L10 finale or a hard-track level. Its next two appearances ramp to the band. | `D(first) ≤ 0.30`; slot ∉ {L10, h1–h3} |
| C5 | **First appearance always warns.** On a module's first appearance, and on each pair's first combination: (a) a pre-phase card with the module icon and a one-line goal; (b) a world-space telegraph (hazard ghost line, walker path arrows, attack target outline) for at least `first_warn_ms` = 3 000 ms; (c) the pressure clock starts only after the first piece locks or the warning ends, whichever is later. Later appearances keep a ≥ 1 000 ms telegraph (`attack_warn_ms`). | Flag `first_warn` on every first-appearance entry |
| C6 | **Finales recombine, never introduce.** L10 and h1–h3 contain only modules and pairs already cleared. This follows the QA finding on Celestial 10. | C3 with an unseen count of 0 |
| C7 | **Phase budget.** At most 3 phases (4 for Carnival L10). The level's `T_est` (§4) must be 120–300 s, and each phase's `T_est` must be 25–120 s. | Sum and per-phase check |
| C8 | **Compatibility matrix** (below). Pairs marked NO are rejected; "cap" pairs need L ≤ L_cap − 0.05. | Matrix lookup |

### 2.4 Compatibility matrix (simultaneous: primary × overlay)

| Primary ↓ / Overlay → | `rising_hazard` (HAZARD) | `gust_wind` (FORCE) | `crumble_floor` (HAZARD) | `pace_mascot` (—) |
|---|---|---|---|---|
| `bridge_dash` (TIME) | OK, 2 channels. Hazard rises in the river and the fail is measured on the deck or walker | OK, 2 channels | **NO** (GDD); it deletes the deck under the walker | OK |
| `boss_hp` (ATTACK) | **NO**: clears (damage) lower the stack while the hazard demands height, a death spiral | OK, 2 channels | **NO**: two drains on the same wall | OK |
| `balance_plate` (FORCE) | cap: a topple costs 2 cells while the hazard rises; allowed only at rising D ≤ D_lo(b−2) | OK (same channel; intensifies) | **NO**: base removal is an instant topple | OK |
| `dig_down` (—) | **NO** (GDD; opposite directions) | OK, 1 channel | **NO**: crumble digs for free and trivialises | OK |
| `conveyor_sort` (FLOW) | OK, 2 channels (the Clockwork Conveyor "Height to Safety" sheet) | cap: gust knocks pieces off belts; `miss_max` +1 | **NO**: the belts are the floor | OK |
| `fort_siege` (ATTACK) | campaign **NO**; versus only as a final-30 s sudden-death flood (anti-turtle, R1) | OK, 2 channels; wind bends lobs | **NO** | OK |
| `paint_claim` (RIVAL) | **NO**: the floor is the score | OK, 2 channels | OK, 2 channels; crumbled cells become unpaintable, an "island claim" | OK |

`rising_hazard` as a primary's partner is covered by the column. As an overlay it is never solo; its solo teach is the climb module it rides on (`summit_climb`).

---

## 3. Head-to-head fairness

### 3.1 Shared seed (extends `campaign-minigames.md` F1)

**H1 – Stream split.** `round_seed = hash(tournament_seed, round_index)`. Each stream is derived from it, with no per-seat salt unless marked:

| Stream | Seed | Shared? | Rule |
|---|---|---|---|
| Piece sequence | `hash(round_seed, "pieces")` | yes | **Index-locked.** Seat i's n-th piece is the same n-th piece for every seat, whatever their tempo. Hold never reorders it. Junk injected by Sends does not consume indices. |
| Board variant (`starting_contents_variants`, dig pre-fill, rock positions, bomb cells) | `hash(round_seed, "board")` | yes | Picked once per round; facing arenas mirror in X |
| Hazard schedule (gust times, crumble pattern, boss attack targets, pest painter path) | `hash(round_seed, "hazard")` | yes | Keyed to the **round clock**, not seat progress, so a fast seat does not get "later" hazards |
| Item and power-up rolls | `hash(round_seed, seat, roll_index)` | per seat | Weights depend on standing (Items F2), so the roll stream is per seat. The *offer times* stay shared |
| Bot decisions | `hash(round_seed, seat_index)` | per seat | Unchanged from GDD F2 |
| Send effects | `attack_rng` | — | Unchanged |

**H2 – Spawn and arena symmetry.**
- Shared arenas (paint island, shared boss, shared floe) rotate seat spawn positions by `round_index mod P`.
- Every seat's distance to its nearest objective cell must be within ±1 cell, which the validator checks on the arena mask.

### 3.2 Comeback without swing

**Principles.**
1. Assist acts on **rate inputs** (hazard speed, belt speed, reload, tolerance, lock delay) and **never on outputs** (score, damage dealt, % owned). A comeback must still be played.
2. It is **continuous in the standing gap**, not in rank. Rank flips at ties and flickers.
3. It is **smoothed** and **capped**.
4. Nothing in MG37–MG50 subtracts from the leader except the contract's telegraphed Sends (tournament F1/F2, unchanged).
5. The Comet (IN18) and Truce Pact (IN31) are **off by default** in these templates.

**Assist formula.**

- `G_i(t) = EMA_τ[(S_lead(t) − S_i(t)) / S_scale]`
- `α_i = 0` if `t < t_on`; otherwise `α_i = α_max · smoothstep(clamp((G_i − g_dead) / (g_full − g_dead), 0, 1))`
- with `smoothstep(x) = 3x² − 2x³`

| Symbol | Type | Range | Description |
|---|---|---|---|
| S_i, S_lead | float | module standing units | Seat's standing and the best standing (race_progress, %, damage, depth…) |
| S_scale | float | > 0 | The module's standing span: deck cells, 100%, boss hp, depth |
| τ | float | 2–10 s | EMA time constant; default 5 s (hysteresis) |
| t_on | float | 5–20 s | Assist off at round start; default 10 s |
| g_dead | float | 0–0.1 | Dead zone; default 0.05 (close races get nothing) |
| g_full | float | 0.2–0.5 | Gap for full assist; default 0.30 |
| α_max | float | 0–0.15 | Cap; default 0.15 (matches the project's ~15% edge cap and IN26's hard cap) |
| α_i | float | 0–α_max | Assist strength for seat i |

- **Output range.** α runs from 0 to 0.15. The leader always has α = 0.
- **Swing bound.** An assist of α raises the trailer's production rate by at most `1/(1−α) − 1` = **17.6%** over the remaining time. Assist alone therefore cannot overturn a lead larger than 17.6% of the trailer's remaining output.
- **Sandbagging is unprofitable.** Idling for Δt costs Δt of output, and recovering it at α_max takes Δt/0.15 ≈ **6.7·Δt**.
- **Example.** Paint round, leader 60% and trailer 42%, so G = 0.18:
  - x = (0.18 − 0.05)/0.25 = 0.52
  - smoothstep = 3·0.2704 − 2·0.1406 = 0.530
  - α = 0.15·0.530 = **0.08**

**Where α applies (one input per module):**

| Module | Assisted input for trailer i |
|---|---|
| `rising_hazard` | `r_i = r·(1 − α_i)` |
| `bridge_dash` | `walker_step_ms_i = step·(1 + α_i)` *while the walker is waiting on an unfinished column only*; otherwise none |
| `boss_hp` (shared boss) | Boss attacks on seat i's wall segment: `attack_period_i = period·(1 + α_i)` |
| `balance_plate` | `s_fail_i = s_fail·(1 − α_i)` |
| `dig_down` | `lock_delay_ms_i = lock_delay·(1 + α_i)` (the pre-fill is shared and never changed) |
| `conveyor_sort` | `belt_speed_i = belt_speed·(1 − α_i)` |
| `fort_siege` | Lob reload `t_reload_i = t_reload·(1 − α_i)` |
| `paint_claim` | `entry_delay_ms_i = entry_delay·(1 − α_i)` |

**Interaction with tournament F1 (Send charge by rank).** F1 stays as written for Sends. IN26 Underdog Tailwind is **not** stacked on α in these templates: it is the same lever. Validator: the effective edge, `1/(1 − α_i)` times the F1 charge speed-up, stays at or below 1.65 at P = 4.

### 3.3 Bot skill tiers

Bot skill is unchanged from GDD F2: `skill = clamp(diff_base + jitter·(u − 0.5), 0, b_max)`. Every behaviour below is a lerp in that skill, so one number drives the whole bot.

| Behaviour | Formula | Easy (.30) | Normal (.55) | Hard (.80) | Max (.90) |
|---|---|---|---|---|---|
| Reaction delay (ms) | lerp(1 200, 350, s) | 945 | 733 | 520 | 435 |
| Placement error (cells, σ) | lerp(1.5, 0.2, s) | 1.11 | 0.79 | 0.46 | 0.33 |
| Pick best of top-3 candidates | p_best = 0.3 + 0.6·s | 0.48 | 0.63 | 0.78 | 0.84 |
| Seconds per piece | lerp(6.0, 2.5, s) | 4.95 | 4.08 | 3.20 | 2.85 |
| Lob aim spread (fort, cells) | lerp(2.0, 0.5, s) | 1.55 | 1.18 | 0.80 | 0.65 |

**Module heuristics.** Each is a probability equal to `skill`, otherwise the bot plays generically:
- bridge: build from the near bank first
- balance: counterweight placement
- paint: target rival or unpainted cells
- conveyor: correct arm
- dig: fill the lowest hole

**Rules.**
- **B1 – Same information as a human.** Bots see the same preview count and the same telegraphs as a human, and nothing more.
- **B2 – No hidden rubber band.** Bots never change skill mid-round. They receive α from §3.2 exactly as a human seat does.
- **B3 – Calibration targets for the simulation** (§3.5). A median-human proxy (skill 0.50, human reaction model) should hit:

| Seats | vs easy | vs normal | vs hard |
|---|---|---|---|
| 1v1 | 75–85% wins | 45–55% | 20–30% |
| 1 human + 3 bots | 55–70% | 30–40% | 10–20% |

**Superseded data.** `minigame-stages.md` hand-sets per-stage bot skills (0.30–0.65). Under the user's "modules, not stages" decision those blocks are superseded. Bot strength comes only from F2.

### 3.4 Round length 60–120 s

**H4 – Fitting the round.**

- `t_mg ∈ [60, 120]` s
- Pick the module size parameter `X` (gap/segments, hp, depth, sort_n, target_pct, N_shots) so that `T_est_vs(X) ∈ [0.65, 0.85] · t_mg`
- `T_est_vs` uses `t_ref_vs = 4.5 s` (the median of b5–b7, the typical point where MG37–MG50 unlock) and §4's per-module `T_est`

| Symbol | Type | Range | Description |
|---|---|---|---|
| t_mg | int | 60–120 s | Round cap |
| T_est_vs | float | 39–102 s | Median finish time; most rounds end by goal, and a minority go to standing at the cap |

- **Output range.** Inside [0.65, 0.85]·t_mg by construction.
- **Example.** MG37 Block Bridge Dash at t_mg = 120:
  - One b5-band gap at t_ref 4.5 is about 26 s
  - With a 1.10 hazard tax, 3 gap segments give 86 s = **0.72·t_mg**. That passes.

**Violations in `campaign-minigames.md`.**

| Template | t_mg now | Proposed | How to cut |
|---|---|---|---|
| MG40 Speed Stack | 150 s | **120 s** | n layers on an ≤ 16-cell masked footprint (B0) |
| MG46 Kraken Blockade | 150 s | **120 s** | hp_vs = round(0.8·P·hp(b5)) = 22 at P = 4 |
| MG47 Chroma Sky Climb | 150 s | **120 s** | path_len −20% |

`mockup_19`'s Bomb Defuse timer (7:38) is a mood reference only. It must not drive data.

**Timeout tie-break.** The standing at `t_mg` decides the round.
- A tie on the primary standing breaks on the secondary metric: bridge = deck cells; fort = own fort cells remaining; paint = hardened cells (R4).
- A tie that remains is shared (Tournament Flow rule 3).

### 3.5 Simulation spec (before implementation)

For each template × bot tier, run 10 000 seeded rounds with 2 and 4 seats. Report:
- (a) the B3 win rates
- (b) the share of rounds ending by goal: target 60–85%
- (c) lead changes per round from α alone (α on vs off, same seeds): target ≤ 0.3 extra
- (d) median finish time inside H4
- (e) the degenerate-policy win rate (§5): each scripted exploit policy must win ≤ its fair share (1/P) against normal bots

---

## 4. Star thresholds from module parameters

### 4.1 Time stars (all campaign module levels)

These reuse the registry formula `star_times` (scoring-stars F1).

- `T_est(level) = Σ_phases T_est(m_i) · (1 + Σ tax_o) + (phases − 1) · phase_banner_ms`
- `t2 = round5(star2_share · T_est)`
- `t3 = round5(star3_share · T_est)`

| Symbol | Type | Range | Description |
|---|---|---|---|
| T_est(m) | float | 25–120 s | Per-module median, from the table below |
| tax_o | float | 0–0.2 | Overlay time tax: `rising_hazard` 0.10, `gust_wind` 0.10, `crumble_floor` 0.15, `pace_mascot` 0 |
| phase_banner_ms | int | 800–2 500 | GDD default 1 500 |
| star2_share / star3_share | float | 0.6–1.0 / 0.4–0.9 | Registry defaults **0.85 / 0.60** |
| round5 | fn | — | Round to the nearest 5 s |

- **Output range.** `t3 < t2`, with a level `T_est` of 120–300 s (C7).
- **Correction needed.** `campaign-minigames.md` F8 uses `t3 = T_med/1.35` (0.74 share). That conflicts with the registry's 0.60. Align F8 to `star_times`, or register a module-specific `star3_share`. Do not keep two rules.

**Per-module `T_est` (median player).**

| Module | T_est(m) | Notes |
|---|---|---|
| `bridge_dash` | `walker_delay + (gap_cells + 2) · step` | The median player lets the walker auto-depart |
| `boss_hp` | `hp · t_hit · (1 + κ)` | §1.3 |
| `balance_plate` | `target_height · κ_h / (c·η_h) · t_ref + E[topples] · topple_penalty · t_ref/(c·η)` | κ_h = 4 cells per height layer; η_h 0.75; E[topples] = 1 |
| `dig_down` | `T_dig` | §1.5 |
| `conveyor_sort` | `sort_n · t_ref / a_med` | a_med 0.8 |
| `fort_siege` | `(build_pieces + N_shots) · t_ref` | §1.7 |
| `paint_claim` | `T_paint` | §1.8 |
| `rising_hazard` | — (an overlay; it adds a tax) | |

### 4.2 Guards (validator)

**S1 – No automatic stars.** A scripted time floor (walker walk, timer phases, fixed animations) must leave room for skill.

`T_floor = Σ scripted minimum time` (time no input can shorten), and the rule is `φ = (T_est − T_floor) / T_est ≥ φ_min`

| Symbol | Type | Range | Description |
|---|---|---|---|
| T_floor | float | ≥ 0 | Unskippable time |
| φ | float | 0–1 | Share of the level's time the player controls |
| φ_min | float | 0.40–0.55 | Default 0.45. With star3_share 0.60, φ ≥ 0.40 is the bare minimum for `t3 > T_floor`; the 0.05 margin keeps 3★ from becoming automatic |

- **Output range.** φ = 0 means stars are automatic for every finisher (the Neon 08 defect the QA review fixed). φ = 1 means fully skill-driven.
- **Example (fails without the fix).** A fort with a 50.7 s fixed build timer and 40 s of lobs gives φ = (91 − 50.7)/91 = **0.44**, which fails. With `build_pieces` (build ends when the pieces are placed), T_floor ≈ 15 lobs·1.5 s, so φ ≈ **0.75**, which passes.

**S2 – Player-controlled starts.** Every module with a scripted actor offers an early trigger, so skill shortens time. This is the precondition for S1.
- bridge: tap **Go** to send the walker early (risk: falling = fail)
- fort: the build ends at `build_pieces`
- boss: the next attack can be pre-empted by a hit (resets `attack_period`)

**S3 – 3★ zero metrics** (`three_star_zero_metrics`):

| Module | Zero metric |
|---|---|
| bridge | `walker_falls` (only after a rescue) |
| balance | `topples` |
| dig | `gems_missed` |
| conveyor | `misses` |
| boss | `wall_breaches` |
| fort | none |
| paint | none |

### 4.3 Worked example: Candy L10 (b = 2, D = D_hi = 0.31, t_ref 5.75)

Chain: `balance_plate` → `fort_siege` → `boss_hp`.

| Phase | Params from §1 | T_est |
|---|---|---|
| 1 Cake stack | target 8, w 7, s_fail .11 | 8·4/3·5.75 = 61.3 + 1 topple·(2/3·5.75 = 3.8) = **65.1 s** |
| 2 Fort siege | build 9, rival 35, target 52%, splash 1 → N_shots 6 | (9 + 6)·5.75 = **86.3 s** |
| 3 Boss | hp 5, t_hit 14.4 s, κ 0.19 | 5·14.4·1.19 = **85.5 s** |

- T_est = 65.1 + 86.3 + 85.5 + 2·1.5 = **239.9 s**
- **t2** = round5(0.85·239.9 = 203.9) = **205 000 ms**
- **t3** = round5(0.60·239.9 = 143.9) = **145 000 ms**
- φ: T_floor (2 banners + boss attack telegraphs) is about 10 s, so φ = 0.96. That passes.
- The GDD F8 rule would have given t3 = 177 700 ms.

**Note.** This level breaks C2, C4 and C6 because `boss_hp` is not taught until Underwater (R14). The arithmetic is shown only to demonstrate the formula.

### 4.4 Tournament standing (no stars)

Versus rounds pay no stars (economy rule 17). Standing uses the module's primary metric, normalised by `S_scale` for §3.2.

---

## 5. Risks: degenerate strategies and systemic issues

Evidence comes from the mockups viewed (sheet/panel). Each fix is a rule or knob, and each gets a scripted policy in the §3.5 simulation.

| # | Risk | Mockup evidence | Mechanism | Fix |
|---|---|---|---|---|
| **R0** | **Layer arithmetic on 8×8** (systemic) | All sheets show large boards | 21 pieces per full-layer clear. `boss_hp` per layer, MG40 Speed Stack, `rising_hazard` against a full stack and coverage height are unwinnable or one-event rounds | B0: progress unit ≤ 6 pieces; row damage; masked ≤ 16-cell footprints; σ check (§1.1) |
| **R1** | **Fort turtling** | Fort Blast (`02`), Fort Frenzy (`01`), Shatter Shootout (`03`, "Destruction % 5/10 vs 0/2"), Airship Scrap Brawl (`07`) | (a) An oversized fort dilutes the rival's destruction % (F5 divides by `cells_at_build_end`). (b) Repair-only play during the lob phase. (c) A low, wide bunker never collapses. At `t_mg` the turtle "wins" by low damage taken. | (a) Equal `build_pieces` on a shared seed, so fort volume is identical. (b) Standing = **damage dealt**, not integrity. Lob-phase pieces are ammo, and a repair costs one lob. (c) A `keep` flag cell must sit at height ≥ `keep_min_height` (default 4), and losing it = 25% bonus damage. (d) Versus only: a final-30 s sudden-death flood (`rising_hazard`, allowed by matrix) erodes bunkers. |
| **R2** | **Ignoring the bridge** | Bridge Dash (`02`, numeric scores beside a heat meter), Bridge Bashers (`01`, scores 243/125), Bridge Builder (`19`, shared bridge with scores 75/71) | Points from clears, pickups or Sends beat deck progress. A player farms score, or spams Crumble Plank Sends, and never bridges. Holding the walker back forever avoids the fail. | Standing = walker cells crossed, then deck cells. Clears and pickups in bridge rounds score 0. Send charge is earned **only** from deck cells placed, so you must bridge to sabotage. The walker auto-departs at `walker_delay` (it cannot be held). The HUD shows deck %, not a free score. |
| **R3** | **Free-riding in shared arenas** | Frenzy Footholds (`03`, shared pit), Summit Scramble (`02`), Kraken Blockade (`04`, co-op wall), Bridge Builder (`19`) | Climbing on rivals' footholds, or letting others defend the wall while you only fire | Footholds are seat-tinted. Standing on a rival's block starts `foreign_stand_ms` (default 2 000), after which it crumbles. Shared boss: each seat owns a wall segment, and a breach on your segment deducts `breach_dmg` (2) from your damage credit. |
| **R4** | **Last-second paint sniping and corner camping** | Neon Splat (`14`), Island Claim (catalogue) | Overwrites in the final seconds swing the winner. One seat camps a corner. | A cell is **hardened** after `harden_ms` (8 000) and then needs 2 hits to flip. The standing tie-break is hardened cells. Assist α never touches % (§3.2). |
| **R5** | **Grief-tipping a shared plank** | Tumbling Towers (`03`, one seesaw for two players) | The leader dumps weight on the far end to topple the shared plate | Versus uses **mirrored** plates. Shared plates are co-op only. If shared, the topple penalty goes to the last placer (liability). |
| **R6** | **Balance spire / rising-hazard spire** | Avalanche Ascent altitude meter (`01`), Clockwork "Height to Safety" (`04`) | Height = highest cube, and the hazard measures stack top, so a 1×1 spire is the optimum | Height and hazard contact measure the **mascot**, or the highest cube with ≥ `support_cells` (3) supported neighbours below. A 1×1 spire does not count. |
| **R7** | **Lock stalling to burn the clock** | Any timed round; a leader in paint, fort or conveyor | Registry `lock_stall` allows up to 46.5 s of piece hovering | In versus: `piece_air_max_ms` = 6 000, then auto hard-drop. Hold may be used once per piece (registry). |
| **R8** | **Conveyor drop-spam** | Clockwork Conveyor (`04`), Factory Frenzy Assemble (`06`) | If misses are free in score mode, dropping every piece on one arm is optimal | A miss scores −1. More than `miss_max` misses means eliminated (campaign) or a 5 s belt jam (versus). |
| **R9** | **Dig: gem-skipping and shaft-only** | Digging Frenzy (`04`, "Depth 32m"), Rubble Rumble (`01`), Gem Grab (`14`) | Under race_progress = depth, gems are worthless. A pre-free shaft lets one I-piece "dig". | Depth counts only **cleared** layers. In versus, each gem = +0.5 depth so the vein is worth a detour. In campaign, gems are the 3★ zero metric. |
| **R10** | **Kill-stealing the shared boss** | Kraken Blockade (`04`), Abyssal Kraken Siege (`07`) | The last hit gets the credit, so players hold rows for the final blow | Standing = cumulative damage. The last hit has no bonus. |
| **R11** | **Sandbagging for comeback** | — | Trailing on purpose to get α | Shown unprofitable in §3.2 (6.7× recovery time); `t_on` 10 s; EMA hysteresis |
| **R12** | **Swing items** | Power-up slots in `14` (glove, ray gun) | Comet- or blue-shell-style items decide the round | IN18 and IN31 off in MG37–MG50. Power-ups follow economy F6 and the leader's lower offensive weight (Items F2). |
| **R13** | **Three pressures through Sends** | MG37 (walker + lava + Crumble Plank), MG42 (lava + Rockfall) | A Send of a new channel makes 3 channels | C1: the Send must share a channel already active (Crumble Plank on the deck counts as TIME/bridge; Rockfall hits footholds as the climb channel), otherwise drop the overlay in the template |
| **R14** | **`boss_hp` introduced in a finale** | — (biome plan) | Candy L10 is the first `boss_hp` (taught only at Underwater L05). It breaks C2, C4 and C6, and repeats the Celestial 10 pattern the QA review flagged. | Swap Candy L10's phase 3 for a taught module (`clear_layers` "Gingerbread Giant" bonk via `legacy_goal` `bonk_boss`), or move Kraken's teach earlier. Decision for game-designer. |
| **R15** | **Off-concept sheets** | `mockup_17` Quantum Spire (hex grid), `06` and `07` (third-party "Tetro Party" branding, non-cast characters), `19` (7:38 timer) | Hex boards and over-long timers cannot meet the 8×8 square grid or the 60–120 s rules | Treat these as mood only. Already noted in `minigame-stages.md` §0 (cast and branding). |

### Inconsistencies to route (not edited here)

1. **Star rules disagree.** `campaign-minigames.md` F8 (`t3 = T/1.35`) vs registry `star_times` (0.60).
2. **Round lengths.** MG40, MG46 and MG47 have `t_mg` = 150 s, above the 120 s cap.
3. **Parameters out of band.**
   - GDD examples: `hp 10` in Lava sits above the b5 band (7), and `r 0.08` sits just below it. The F3 example matches.
   - `minigame-stages.md`: Kraken `bonk_boss` hp 6 per layer clear on a 12×4 wall is a 16-piece hit, so 6 hits is about 96 pieces. That is impossible in 60 s.
4. **Board and bot conflicts.**
   - The registry `default_board_width/depth` is 6, while the user's minigame minimum is 8×8. Module boards need their own constant.
   - `minigame-stages.md` per-stage bot skills are superseded by F2.
5. **`boss_hp` fail rule is contradictory.** It says "wall breached to row 0" = fail, but an Edge Case says the boss never destroys row 0. One must go.
6. **Formula reconciliation.** The `hard_mult` (×1.25 on parameters) and the D-space hard offset (+0.10) both scale difficulty, but in different spaces. Reconcile them in F3.

### Proposed registry additions (not written; need approval)

| Kind | Name | Expression / value |
|---|---|---|
| formula | `module_tier_band` | §0.3 |
| formula | `module_t_ref` | §0.2 |
| formula | `combined_load` | §2.2 |
| formula | `comeback_assist` | §3.2 |
| formula | `skill_share_guard` | §4.2 |
| constant | `max_pressure_channels` | 2 |
| constant | `first_warn_ms` | 3 000 |
| constant | `alpha_max` | 0.15 |
| constant | `module_progress_unit_max_pieces` | 6 |
