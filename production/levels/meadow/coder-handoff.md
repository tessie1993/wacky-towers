# Meadow: Coder Handoff (levels 01–10, bonus, hard track)

> **Status**: Handoff v1 (level-designer, 2026-10-10)
> **Design source (wins on conflict)**: `design/levels/meadow.md` (approved). Not redesigned here.
> **Format source**: `docs/architecture/implementation-plan.md` §1.2 `LevelData`, §1.3, §2.3 (level JSON shape), §5 (ASCII grids); knob ids from `assets/data/knobs/*.json`; shape ids from `design/gdd/piece-set.md`.
> **Data drafts**: `production/levels/meadow/data/meadow_01.json` … `meadow_10.json`. Move them to the plan's level folder when DAT-002 exists (see gap G1 for which folder).
> **Every value is a tunable default.** The validator enforces only the GDD safe ranges. Values marked **[knob]** are not fixed by the design: they are the design default and expected to move in playtest.

---

## 1. How to read the drafts

- Shape of every file = plan §2.3: `schema, id, biome, tier, name, board, pieces, knobs, goal, rules, stars, story`. No `recipe` (plan §8: Meadow writes explicit knobs and rules).
- Omitted fields take the owning GDD default. Meadow common defaults are already the knob-file defaults, so they are **not** written: `spawn.randomizer` bag, `spawn.queue_lookahead` 3, `spawn.preview_count` 1, `spawn.hold_enabled` false, `clear.collapse` slice, `fall.ramp_per_clear` 0.05, `goal.countdown_ms` 3000, `goal.t_piece_s` 8, all rotation axes, `spawn_anchor` = footprint centre (lower cell on ties).
- Grids: one string per row, row 0 = `z = 0`, char 0 = `x = 0`. Glyphs: `#` starter, `^` sprout, `e` egg, `m` mushroom, `a` ant, `.` empty; targets `+`. Only `starter` exists in `content/blocks.json` today; the others land with their MDW story.
- Stars: `{t2, t3}` in ms (clock-based) or `{s2, s3}` layers (Survive). ★★★ also needs "no warning used", which under `trim` reads as "no cube trimmed" (Scoring & Stars rule 1). Nothing extra in data.
- `rules` is one list (plan §2.3). Layer per rule comes from its rule JSON; content/mascot rules do not count toward F3 (see gap G4).
- `T_level` (meadow.md 01: 180 s) is not written: it only suggests N, and every level sets N.

## 2. Per-level spec

Columns: what the draft JSON holds, plus what lives **outside** the JSON (scene-side, per plan §2.2: island, `BoardAnchor`, mascot spots, skits, camera exports `camera_yaw_index` 0 / `camera_elevation_override_deg` 0 unless stated).

### 01 First Sprout — `meadow_01` (tier 1)
| Field | Value |
|---|---|
| board | 4×4, `h_play` 8, `-y`, no mask, no starting contents; anchor default (1,1) |
| pieces | `i o t l s`, weights 1; `opening_set` [o, i], `opening_count` 2 |
| knobs | `fall.g0` 0.6; `control.rotation_axes_enabled` ["spin"] (CV02); `goal.top_out` rescue; `goal.warnings_max` 2 |
| goal | `clear_n`, n 4 |
| rules | none in the first-playable draft. Add `{"id":"mascot_catch","params":{"catches":1}}` when MDW-002 lands (design wants it in 01) |
| stars | t2 145 000, t3 105 000 [knob: replace with playtest medians] |
| scene | seed-plot island; rubber duck (SE05) under the island, tap to collect, no stars: presentation story, deferred (plan §8); Pip helper spot |
| length | F1 ≈ 171 s; validator length warning expected |

### 02 Tilt & Roll ★PROTO — `meadow_02` (tier 2)
| Field | Value |
|---|---|
| board | 6×6, `h_play` 10; starting layers 0–1 as meadow.md (3 pockets: A tripod at (1,·,1)/(2,1,1)/(1,1,2); B, C mirror screws). 12 empty starter cells = 3 pieces × 4 |
| pieces | 8 Standard; `opening_set` [tripod, screw_left, screw_right], `opening_count` 3 (one bag, random order) |
| knobs | `fall.g0` 0.6; rescue; `goal.warnings_max` 1 |
| goal | `clear_n`, n 3 (filling all 3 pockets = a double) |
| rules | `mascot_catch` {catches 1} |
| stars | t2 130 000, t3 90 000 (hand-set; starter layers break F1) |
| scene | burrow cut-away; duck (deferred); Pip points at the pocket the current piece fits (presentation, deferred) |
| tests | MDW-002b pocket test: each pocket exactly fillable by its named shape, and by no flat shape |

### 03 Breezy Hill — `meadow_03` (tier 3)
| Field | Value |
|---|---|
| board | 8 wide × 4 deep, `h_play` 10; anchor default (3,1) |
| pieces | 8 Standard; `tags` {dandelion_puff: {per_bag: 1}} (see G5) |
| knobs | `fall.g0` 0.7; rescue; warnings 1 |
| goal | `clear_n`, n 5 |
| rules | `gust` {wind_dir +x, fixed, interval 8000, jitter 2000, strength 1, warn 1000}; `dandelion_puff` {} (seeded split into two face-connected halves on landing); `mascot_catch` {1} |
| stars | t2 365 000, t3 255 000 |
| scene | busy slope; the Miller visible from here on; wind telegraph is world-anchored |

### 04 Mushroom Ring — `meadow_04` (tier 4)
| Field | Value |
|---|---|
| board | 7×7, `h_play` 10; mask centre 3×3 off (A = 40); `spawn_anchor` {3, 5} (required: centre inactive). See G7 |
| pieces | 8 Standard |
| knobs | `fall.g0` 0.75; rescue; warnings 1 |
| goal | `clear_n`, n 3 |
| rules | `mushroom_popup` {spawn_every_locks 5, objects_max 4}; sparkle marks the cell one lock ahead; mushroom content fills_layer = true (clears with its layer) |
| stars | t2 270 000, t3 190 000 |

### 05 Tall Tower ★PROTO — `meadow_05` (tier 5)
| Field | Value |
|---|---|
| board | 5×5, `h_play` 12 |
| pieces | 8 Standard + `big_cube`; weights {big_cube: 0.5} → bag of 17 (2 each + 1 Big Cube). See G3 |
| knobs | `fall.g0` 0.8; `goal.height_coverage` 0.6 (15 of 25 cells on the counting layer) |
| goal | `height`, h_target 10 (layer 9 counts) |
| rules | `build_race` {topout_rule trim} (sets `clear.detector` none + `goal.top_out` trim); `wobble` {wobble_max 6} (plan MDW-005 rule text) |
| stars | t2 240 000, t3 170 000, ★★★ also no cube trimmed |
| scene | clean hilltop, wooden sign ribbon at `h_target`; no danger music (trim cannot lose) |

### 06 Flower Bed — `meadow_06` (tier 6)
| Field | Value |
|---|---|
| board | 8×8, `h_play` 8; starting contents: sprouts `^` at (3,0,2), (4,0,2) |
| pieces | `i o t l s tripod duo tri_corner` |
| knobs | `fall.g0` 0.7 |
| goal | `shape`, `target_shape` layers 0 (38 cells) + 1 (12 cells) = 50 |
| rules | `fill_shape` {topout_rule trim, stick_when_filled false}; `sprouts` {grow_locks 4, grow_max 1} (grows into layer-1 targets; a cube on top stops it) |
| stars | t2 155 000, t3 110 000, ★★★ also no cube trimmed |
| note | sprout cubes start on layer-0 target cells and count as filled (G9) |

### 07 Hide & Seek — `meadow_07` (tier 7)
| Field | Value |
|---|---|
| board | 6×6, `h_play` 10; starting layers 0–1 as meadow.md (15 empty cells, all reachable from above) |
| pieces | 8 Standard; `tags` {fog_ghost: {per_bag: 1}} |
| knobs | `fall.g0` 0.85; rescue; warnings 1; `control.fog_ghost_preview` faint (G6) |
| goal | `clear_n`, n 4 |
| rules | `fog` {visible_ms 5000, fade_ms 1000, invisible_alpha 0.1, reveal_ms 600}; starters stay visible through Intro + Countdown, timer starts at first spawn; `fog_ghost` {} (tap = solid; untapped sinks to the deepest free hole in its column, plan §10) |
| stars | t2 195 000, t3 140 000 (hand-set) |
| scene | hushed fog; `view.occlusion_mode` default fade (no override) |

### 08 Dewdrop — `meadow_08` (tier 8)
| Field | Value |
|---|---|
| board | 5×5, `h_play` 8 |
| pieces | 8 Standard |
| knobs | `fall.g0` 0.9; `fall.ramp_per_min` 0.15; rescue; warnings 1 |
| goal | `survive`, `t_ms` 150 000 (field name: G8) |
| rules | `sticky_landing` {sticky_gravity_scale 0.7} (data only: lock delay 0, hard-drop grace 0, gravity ×0.7) |
| stars | s2 1, s3 2 layers (★★★ also no warning) |

### 09 Topsy-Turvy ★PROTO — `meadow_09` (tier 9)
| Field | Value |
|---|---|
| board | 6×6, `h_play` 10; eggs `e` at (1,0,1), (4,0,4) |
| pieces | 8 Standard |
| knobs | `fall.g0` 0.95; rescue; warnings 1 |
| goal | `clear_n`, n 4 |
| rules | `topsy_tumble` {flip_every_layers 2, flip_every_ms 40 000, flip_warn_ms 2000}, applied at next Resolving, stack settles to the new floor; `hatching_eggs` {hatch_locks 6} (chick hops to lowest free neighbour along current down; bonus event if an egg is cleared first) |
| stars | t2 325 000, t3 230 000 |
| scene | camera unaffected by ±y flip (plan MDW-009) |

### 10 Meadow Mill ★PROTO — `meadow_10` (tier 10, boss)
| Field | Value |
|---|---|
| board | 8×6, `h_play` 12, no mask (Conveyor forbids masks) |
| pieces | `i o t l tripod screw_left screw_right chair` |
| knobs | `fall.g0` 1.0; rescue; warnings 1 |
| goal | `clear_n`, n 3 (3 sails) |
| rules | mechanic `mill_belt` {conveyor_dir +x, conveyor_every 2, conveyor_wrap true}; twist `gust` {wind_dir +z, interval 8000, jitter 2000, strength 1, warn 1000}; twist `topsy_tumble` {flip_every_layers 2, flip_every_ms 180 000, flip_warn_ms 2000}. At the F3 cap (1 mechanic + 2 twists). See C1 |
| stars | t2 315 000, t3 225 000 |
| scene | Miller on the roof reacts to warnings and clears (presentation; driven by sim events) |

### B Picnic Puzzle — `meadow_bonus` (tier 11) — spec only, no draft (plan §8 defers)
board 4×4, `h_play` 6 · `pieces.fixed_list` [i, o, big_cube, i, o, big_cube] · `spawn.preview_count` 3 · `fall.g0` 0.5 · goal `shape`, both layers fully `+` (32 cells) · rule `fill_shape` (trim) · fail: out of pieces (FT07) + `goal.time_limit` 60 s · stars t2 45 000, t3 30 000 + no trim. Known solution in meadow.md §6 B (verified: every placement supported in list order). Needs G10.

### Hard track — spec only (plan §8 defers)
- **H1 `meadow_h1`** (tier 12): 6×6, `h_play` 10; `^` at (1,0,1),(4,0,1),(1,0,4),(4,0,4) (whether the rest of layer 0 is starters is ambiguous in meadow.md: recipe says sprouts only, side view shows `#`; resolve before scheduling); `sprouts` {grow_locks 3, no grow_max}; `gust` callback every 10 s (direction not in design: default +x **[knob]**); clear_n 5; g0 0.9; stars 410 000 / 290 000.
- **H2 `meadow_h2`** (tier 13): 6×6, `h_play` 10; 2 starter layers with 3 ants `a` (layer 1 as meadow.md; layer 0 full); new atom `ants` (SP31); `mushroom_popup` {spawn_every_locks 6}; clear_n 4; g0 0.9; stars 325 000 / 230 000.
- **H3 `meadow_h3`** (tier 14): two 4×4 boards, `h_play` 8, tap a field to route the piece; needs `layout.kind` multi-board + `PieceRouter` (not built); clear 3 per field; 1 shared warning; g0 0.85; stars 220 000 / 155 000.

## 3. First playable: meadow_01

**Minimal feature set** (all in plan waves 0–7, ending at APP-001):
1. Board 4×4 / `h_play` 8, unmasked, empty (BRD-001…003).
2. Shape bank with the 5 flat shapes; spawn at footprint centre (SHP-*).
3. Spawner: weighted bag + `opening_set`/`opening_count` (SIM-002).
4. Move + **spin only** (`control.rotation_axes_enabled` = ["spin"]; tilt/roll buttons hidden), kicks (SIM-003, INP-001).
5. Fall at g0 0.6, `ramp_per_clear` 0.05, soft/hard drop, lock delay (SIM-004).
6. Layer clear + slice collapse (SIM-005).
7. `clear_n` goal, `rescue` top-out with 2 warnings, countdown 3 s, level clock, stars by time (SIM-006).
8. Level JSON load + validate (DAT-002…004), level scene, camera rotate-view, HUD + result + retry (VEW-*, UI-001, APP-001).

**Not needed for first playable**: Pip's catch, Pip's pointing, rubber duck, intro/payoff skits, audio, any rule plugin.

**What each later level adds** (new system → story):
| Level | Adds |
|---|---|
| 02 | starting contents (starter glyph), tilt + roll, `mascot_catch` rule + `piece.lock` veto/return-to-spawn (MDW-002, 002b) |
| 03 | first twist plugin `gust`; per-bag piece tags + `dandelion_puff` split (MDW-003, 003b); 8-wide lane |
| 04 | footprint mask + `spawn_anchor`; content `mushroom`; `mushroom_popup` (MDW-004) |
| 05 | `height` goal, `build_race` (detector none, trim top-out), float/fractional weights, `big_cube`, `wobble` (MDW-005) |
| 06 | `shape` goal + `target_shape` grid, `fill_shape`, content `sprout` + `sprouts` (MDW-006); helper shapes `duo`, `tri_corner` |
| 07 | `fog` + status fade shader; `fog_ghost` + tap gesture + `pick_cell` (MDW-007, 007b) |
| 08 | `survive` goal, `{s2,s3}` stars, `ramp_per_min`, `sticky_landing` data rule (MDW-008) |
| 09 | `topsy_tumble` (down-axis flip, settle), content `egg`/`chick` + `hatching_eggs` (MDW-009, 009b) |
| 10 | `mill_belt` mechanic; first 3-rule stack; `chair` (MDW-010) |
| B | `fixed_list`, out-of-pieces fail, `time_limit` |
| H1–H3 | uncapped sprouts; `ants` atom; multi-board layout + piece router |

## 4. Coder-blocking gaps

| # | Gap | Owner | Suggested resolution |
|---|---|---|---|
| G1 | **Paths disagree.** Brief: scenes under `src/levels/meadow/`. Plan §1.3/§2.2: scenes `scenes/levels/meadow/meadow_XX.tscn`, JSON `assets/data/levels/meadow/` (§1.3 tree even nests `levels/` under `scenes/`), and `level_files_test` scans `res://assets/data/levels/`. | technical-director / lead-programmer | Pick one before APP-001; update plan §1.3, §2.2, DAT-003, DAT-004 and `level_scenes_test` together |
| G2 | `mascot_role` enum not defined (plan says "WO06–WO09 names"); drafts use `helper`, `watcher`, `boss` (meadow.md wording). 10 = Pip watcher + Miller boss: one field cannot say both. | game-designer (Campaign/mascot owner) | Define enum; 10 likely needs `boss` + a separate mascot field |
| G3 | **Weights**: Piece Set/Spawner GDD allow float `w_i` (0.5); plan `LevelData.pieces.weights` is `Dictionary[StringName,int]` and `Seeds.weighted_pick` takes ints. meadow_05 writes 0.5. | lead-programmer (DAT-002/SIM-002) | Loader converts floats to copies via Spawner F1 (`copies_i = w_i / w_min`); or require ints in files and rewrite 05 as all 2 + big_cube 1 |
| G4 | **Rule layers**: plan uses layers `mechanic`, `twist`, `content`, `mascot`; Rule-Twist GDD has `level_mechanic, twist, item_buff, perk, base`; `knobs/rules.json` `rules.layer_order` lacks `content`/`mascot`. Priority of content/mascot rules is undefined. `wobble` (05) must be `content` or 05 fails F3 (2 mechanics). | systems-designer (framework GDD) + lead-programmer | Add the two layers to the GDD and `rules.layer_order` with ranks; mark `wobble`, `sprouts`, `hatching_eggs`, `dandelion_puff`, `fog_ghost` as content, `mascot_catch` as mascot |
| G5 | **"1 piece per bag carries tag X"** has no schema. Drafts use `pieces.tags: {"<rule_id>": {"per_bag": 1}}` (03, 07). | systems-designer (Spawner GDD) + lead-programmer | Confirm shape in Spawner GDD; tag chosen by the bag's seed on a Standard shape |
| G6 | Knob `controls.fog_ghost_preview` (plan MDW-007b) breaks the `control.` prefix used by every knob in `knobs/controls.json`. Drafts use `control.fog_ghost_preview`. | lead-programmer | Rename in plan |
| G7 | **04 spawn**: "lower cell on ties" with anchor (3,5) may put 2-deep spawn footprints on z 4–5, and (2..4, 4) is inactive → validation fails. Rule 11a does not define tie direction for a 2-deep piece. | systems-designer (Board GDD) + level-designer | Define the tie (toward +z at the anchor); else move anchor to {3,6} — design intent (spawn on the front band) holds either way |
| G8 | Goal target field names not fixed: Survive `T` (drafts `t_ms`), Height `H_target` (drafts `h_target`). `height_coverage` exists both as knob `goal.height_coverage` and as an M1 param; drafts use the knob. `topout_rule` also exists as M1/M2 param and knob `goal.top_out`. | lead-programmer (goal plugins) | One home each: targets in `goal`, coverage + top-out as knobs; drop duplicate params from rule JSON |
| G9 | Does non-piece content (sprout, mushroom, chick) count as a filled target cell / layer cell? 06 depends on yes. | systems-designer (Level-Specific Mechanics M2) | Yes when `solid` + `fills_layer` |
| G10 | Bonus needs `goal.time_limit` and an out-of-pieces (FT07) fail; neither is a knob in `knobs/goals.json`. | lead-programmer | Add when bonus is scheduled (after MDW-012) |
| G11 | Level Data GDD AC 9 lists Spawned Objects for meadow_10 (plan R8); meadow.md wins. | game-designer (Level Data GDD) | Fix AC 9 to Belt + Gust + Flip |
| G12 | Rubber duck "visible from one low snap angle": Camera has 12 yaw snaps at a fixed elevation, so there is no low angle. | level-designer + art-director | Place the duck in a notch in the island side visible from one yaw snap; presentation-only, deferred |
| G13 | Order: 03 uses `mascot_catch` but MDW-003 depends only on APP-001. | producer | MDW-003 depends on MDW-002, or ship 03 without catch until then |

**Design concern (not blocking build)**
- **C1, 10 phase timing**: `flip_every_ms` 180 000 is the twist's max, but F1 puts 2 clears at ≈ 250 s on 8×6, so the timer will usually fire the flip in phase 1, before the 2nd sail, and may flip twice. Options: (a) allow `flip_every_ms` = 0 = "layers only" in the Twist Library; (b) accept a time flip; (c) EV13. Owner: level-designer with game-designer. Recommend (a).
- C2: 04 sparkle "one lock ahead" and 09 "flip applied at next Resolving" are both written in the plan; QA should check them.

## 5. Playtest / acceptance checklist (QA in Godot)

Every level, common checks:
- [ ] Loads with zero validation errors (warnings listed; length warning expected on 01, 02, 06, 08).
- [ ] Board size, height line and mask match §2; danger line visible at every yaw.
- [ ] Countdown 3 s, first spawn after; level clock pauses on pause/warning/result.
- [ ] Win screen gives ★ by the §2 thresholds; ★★★ lost after a warning (or a trim on 05/06).
- [ ] Retry restarts with a fresh seed; screenshots saved to `production/qa/evidence/meadow_XX_*.png` (start, mid, result).

| Level | Specific checks |
|---|---|
| 01 | First 2 pieces ∈ {O, I}; only I O T L S ever appear; tilt/roll controls absent and keys do nothing; 4 clears wins; 2 top-outs rescued, 3rd loses |
| 02 | Starter layers match the grid; first 3 pieces = tripod + both screws in some order; each fills exactly one pocket; filling all three clears 2 layers at once; a flat piece over a pocket is caught once (Pip), second time locks |
| 03 | Gust every 6–10 s, 1 s telegraph, pushes the piece 1 cell +x (blocked = no move); exactly 1 puff per bag, splits into 2 halves on landing; arrow correct after rotate-view |
| 04 | Pond cells never take cubes; pieces spawn on the front band; mushroom every 5 locks, ≤ 4 on board, sparkle shown 1 lock ahead; mushroom clears with its layer |
| 05 | Full layers never clear; cubes at layer 12+ pop off, no warning, never lose; win when layer 9 has ≥ 15 cubes; ~1 Big Cube per 17 pieces; wobble slip at 6 overhang cubes, then sway resets |
| 06 | 50 targets shown (38 + 12); sprouts at (3,0,2),(4,0,2) grow 1 cube after 4 locks, stop if covered; covering all 50 wins; trimmed cube → ★★ max |
| 07 | Starters visible through countdown, fade after 5 s to alpha 0.1; landing ghost still correct; each clear reveals for 0.6 s; 1 fog ghost per bag passes through cubes, tap makes it solid, untapped fills the deepest hole in its column |
| 08 | Pieces lock on first touch (no slide, no grace); fall ×0.7; speed rises per minute; win at 150 s; ★★ 1 layer, ★★★ 2 layers + no warning |
| 09 | Eggs at (1,0,1),(4,0,4); flip after 2 clears or 40 s with 2 s warning, at next Resolving; stack settles to new floor, spawn moves; egg hatches after 6 locks, chick hops to lowest free neighbour |
| 10 | Belt shifts all contents +x every 2 locks with wrap, never during player control (≤ 200 ms); gusts +z; flip fires right after the 2nd clear (log whether the 180 s timer fired first: C1); 3 clears wins |
| B | Pieces exactly I O BigCube I O BigCube, preview 3; known solution wins; 7th piece never arrives (out of pieces = lose); 60 s limit loses |
| H1–H3 | Deferred; checklists written when scheduled |
