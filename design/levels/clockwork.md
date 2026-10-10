# Clockwork Biome: Tock's Midnight (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10)
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format**: copies `design/levels/meadow.md` section for section. Biome number 8 in the main chain (after Cave, before Neon).
> **Sources**: `production/narrative/campaign-story/brief.md` (§3.8, §2.3, §7), `lore-world.md` §3.8, `dialogue-campaign-skits.md` §8, `visual-direction.md` §3.2 (Clockwork), `design/gdd/mechanics-module.md` (atoms, F1), `design/gdd/campaign-structure.md`, `design/gdd/twist-library.md`, `design/gdd/level-specific-mechanics.md`, `design/gdd/level-goals-fail-states.md`, `design/gdd/scoring-stars.md`, `design/gdd/level-data-definition.md`, `design/gdd/skills.md`.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs.

---

## 1. Level name and theme

**Tock's Midnight.** Tock the wind-up duck has to deliver the last gear to the town clock before midnight, so the clock can strike twelve and the wind-up town's midnight party can begin. Blocks fall as a **brass-and-cog drizzle** under a sepia night sky where the clock face is the moon. Cuckoo Prime, a giant cuckoo clock, has been given a clock-stopper (Mizzle's parcel, meant so "the party never ends") and uses it to make it **midnight forever**: he jams the hands at one minute to twelve, punches his pistons, stops the stopwatch and turns the town's gears. In the finale the last clear pops the stopper out of his gears, the bell strikes twelve, and Cuckoo is sprung out on his spring, still ticking smugly. Keepsake: a gear.

**Quirk: "Everything ticks."** The Clockwork biome is about **things moving on a schedule you can read**. Every disturbance runs on a visible beat (every N locks or every N seconds) with a wind-up telegraph, so the player learns to plan one beat ahead. Energy is **tense** (brief §7: waiting, suspense) but never punishing: the danger is always announced, and strangeness still zig-zags rather than ramping.

**Thread (Mizzle, strength 2: partly seen).** A window across the square shows a long table set for twelve. A figure waits at it; every time the clock tries to strike, a violet cuff straightens a chair. Levels 03–09 carry one small clue each (§8, from the skits doc). Missing every clue still gives a clean, happy story.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level, from `lore-world.md` §3.8 A: base cog plaza (01), gear-pocket workshop (02), conveyor street (03), spring yard (04), clock-tower climb (05), pendulum hall (06), stopwatch square (07), winding-key square (08), the rewind works (09), the clock face (10); bonus a music box on a shop counter. All sit on a brass island with a huge mainspring underside |
| Stage | Busy by nature (cogs, rooftops), but every level keeps ambient motion **slow and in the backdrop** (rule 9: one disturbance near the board). Landmark in every backdrop: the clock face as the moon, its hands one minute later each level (01 at 11:50 … 09 at 11:58, 10 jammed at 11:59) |
| Intro skit | A wordless 3-second mini-scene in which Tock shows the problem, played during the Countdown (no play time lost); ends on the hand-off |
| Payoff skit | A skit of 5 s or less on every win, tap to skip; the biome finale is 6 s on first play, the last 2 beats on replays |
| Mascot | **Tock** (Clockwork only), WO09 watcher on every level (reactions only, staging only, no gameplay effect). No catches (`mascot_catches` 0; WO11 is Pip-only). His running gag: he **runs down** when stressed (a warning, a miss) and a townsperson's key **winds him up** again; his emote is `sweat` |
| Boss | **Cuckoo Prime** (never hurt: he is sprung out on his spring). The clock tower is visible from 01; Cuckoo's door rattles from 03 on, and every Clockwork disturbance is his wind-up |
| Friends | **All four have joined**: the wizard, **Lana** (Stitch), **Boulder** (Smash) and **Glim** (Redraw) may be picked in solo play. No level is tuned around a skill; star times are balanced for no perks and no skills. Stitch vetoes every `stack`-tagged write (turntable, pistons, conveyor, rewind), which is a valid counter and allowed. Smash can remove a chunk (undoing a bad piston shove). **Redraw has no effect on fixed-list and kit levels** (06, B), because their queue is the puzzle (§10) |
| Physics | None in the Clockwork |
| Rubber duck | Riding round and round on a slowly turning gear under the island in 01 and 02 (SE05, visible from one low snap angle; tap to collect; no stars attached) |
| Clockwork events | Turntable = **Cog Turn** (BL11); Pistons = **Piston Punch** (EV20); Stopwatch = **Stopwatch Stutter** (EV16 biome event, new rule `stopwatch`); Wind the clock = **Winding Keys** (GO29); Conveyor = **Tram Street** (EV05); Gravity Flip = **Rewind** (EV03); Bounce pad = **Spring Step** (SP35) |
| Callbacks | Conveyor (Meadow, Forest, Lava), flip (Meadow, Ice), spring pads (Lava) return, renamed. Only one callback per level is the *new* idea; the rest are known |
| Dressing | Block set Clockwork Gears on the `_16` cube kit (primary); gold-coloured pieces stay brass-muted (reserved gold rule). UI frame: polished walnut with brass corner plates, two rivets per corner and a thin engraved border (visual-direction; art-director to confirm against lore's "brass-stained wood with one tiny gear") |
| Prototype priority | **02, 04, 07, 08, 10** (★PROTO): they carry the biome's new rules (BL11 turntable, EV20 pistons, the stopwatch, GO29 keys) and the boss stack |

**Lighting (decision: follow `visual-direction.md`, five stages).** Used as written in each level below. Sepia evening `#4A3A30` umber with lamp cream; lamp-lit night (warm street lamps); clock-face moonlight (cool slate-blue `#3A4458`, long backdrop shadows); midnight strike (one warm bell bloom on the backdrop at the finale, **no full-screen flash**); music-box interior.

| L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | B |
|---|---|---|---|---|---|---|---|---|---|---|
| sepia evening | sepia evening | sepia evening | lamp-lit night | lamp-lit night | lamp-lit night | clock-face moonlight | clock-face moonlight | clock-face moonlight | **midnight strike** | music-box interior |

`lore-world.md` §3.8 F lists seven presets (incl. "frozen blue" at L7); the brief says follow visual-direction. The stopwatch's freeze in 07 may tint the backdrop cool for its 2.5 s as staging only, which keeps the lore's idea without a separate preset (§10).

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll), `t_piece` 8 s. **Pieces**: "8 Std" = I, O, T, L, S, Tripod, Screw-Left, Screw-Right. **Speeds** are hand-set within ±0.05 of campaign F2 (`0.6 + 0.045 × (tier − 1) + 0.06 × (8 − 1)` = 1.020 at tier 1 up to 1.425 at tier 10), trimmed toward the low end because every level has a moving rule; puzzle levels (06, B) are exempt and use a slow `g0` so the player can think. **Star times** use Scoring & Stars F1 (`t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`) with `t_est = N × A × 2.667 s` for Clear-N (`A` = active cells per layer). The build race, the keys level, the puzzles and the bonus hand-set their times. Stars are for play with no perks.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; tiers 7–10 showpiece levels may use up to 6. "New" below means *not used in the Meadow, Candy, Ice, Lava, Forest or an earlier Clockwork level*; the Underwater and Cave files are not written yet (§10). A bundle counts 1 (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14). Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. Secrets (SE05) and the mascot field count 0.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block; targets `#` target cell. `P` marks a piston on the wall beside a row, `K` a keyhole on a wall. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Clockwork rule notes (new and changed rules; owners named in §10)

| Rule | Definition (all values tunable) |
|---|---|
| **BL11 Cog Turn** (Candidate, Board slot, tags `grid stack`, counter: **plan for the turn**) | The whole stack turns 90° about the board's vertical centre axis every `turn_every_locks` (4; 2–8) locks, direction `turn_dir` (`cw` default, `ccw`). It applies at `on_resolve_end` after the clear check (like the conveyor), as one rigid move through `RuleApi.move_cells`, so support is kept and no layer gains or loses a cell. **Telegraph**: on the lock before a turn the cog ring around the board lights tooth by tooth and a curved arrow shows the direction (`turn_windup`); the ghost of the next piece already accounts for the turned stack. Needs a square footprint and a 90°-symmetric mask (validation) |
| **EV20 Piston Punch** (Proposed, layer `twist`, tags `grid floor stack`, counter: **use it**) | Pistons sit on the board walls, each facing one row of one layer (level data: `{wall, row, y}`). Every `piston_locks` (4; 2–8) locks, at `on_resolve_end`, each piston pushes: the cubes from the wall-side cell up to the **first empty cell** of its row shift one cell inward, closing that gap; the wall-side cell becomes empty. If the wall-side cell is already empty, or the row is full, the piston **jams** (a steam puff, no move). Cubes above a moved cell stay where they are. A push that completes a layer clears in the S4c pass. **Telegraph**: winds up one lock ahead (piston glows, hiss, an arrow on the row). If a piston and another `stack` rule fall due on the same lock, the piston waits one lock (Readable Chaos) |
| **Stopwatch Stutter** (EV16 biome event, Candidate container; new rule `stopwatch`, layer `twist`, tags `fall rt`, counter: **use it**) | Every `stop_every_ms` (14 000 ± `stop_jitter_ms` 3 000) of play time, after `stop_warn_ms` (1 000: the town's second hand stops, a "tick… TOCK" with a ring filling), the **falling piece freezes** for `stop_ms` (2 500): gravity off and the lock-delay clock paused; move, rotate and hard drop still work. Then **catch-up** gravity runs at ×`catchup_scale` (1.6) for `catchup_ms` (2 500). A stop that falls due while no piece is falling is **dropped, not deferred** (as a gust, twist-library rule 6). Net fall time is about neutral; the skill is to aim during the freeze and drop before the catch-up. The ticking SFX must not read as a goal timer (audio-director) |
| **GO29 Winding Keys** (Proposed, Goal slot `wind_keys`, tags `grid face`) | Keyholes sit on the board walls (level data `{wall, row, y}`). `key_per_bag` (2; 1–3) pieces in each bag carry a **brass key stamp** on one face of one cube (seeded). A keyhole is **wound** when a key cube locks in the cell next to it **with the stamped face pointing at the wall**: the key turns, the keyhole lights and stays wound. Win when `keys_needed` keyholes are wound. Clears stay on (CL01), so a keyhole covered by a plain cube is freed by clearing that layer (the module's guard). The ghost shows the key decal; a keyhole glows when the ghost's key face lines up. Turning the stamp to the wall uses all three rotation pairs. Brass, not reward gold |
| **Tram Street** (EV05 `conveyor`, mechanic) | Level-Specific Mechanics M4 as written: unmasked rectangle, wrap on. Staging: a tram bell rings one lock before a shift |
| **Rewind** (EV03 `flip`, `flip_mode` stack) | Twist-library T3 as written (the stack turns over in place; the island stays). Staging: the works' gears spin backwards and the clock hands sweep back a minute during the warning |
| **Spring Step** (SP35 bounce pad) | As defined in `lava.md` (vent pads), skinned as a coiled spring with a brass cap and a "boing" |

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Tock | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | clockwork_01 | Cog Plaza | Polish the base cog | cog mask (BL02) | watcher | clean, calm | Clear 3 | 21-cell cog, H8 | 8 Std; first 2 from {O, I} | 0.97 | rescue, 2 | ~2.8 min | 145 / 100 s |
| 02 ★ | clockwork_02 | Gear Workshop | The workbench turns | Cog Turn (BL11) | watcher | clean, calm | Clear 3 | 5×5 turntable, H10 | 8 Std | 1.05 | rescue, 1 | ~3.3 min | 170 / 120 s |
| 03 | clockwork_03 | Tram Street | The street rolls | Tram Street (EV05) | watcher | busy | Clear 4 | 8×4, H10 | 8 Std | 1.10 | rescue, 1 | ~5.7 min | 290 / 205 s |
| 04 ★ | clockwork_04 | Spring Yard | Pistons punch the rows | Piston Punch (EV20) | watcher | busy | Clear 3 | 6×6, H10, 4 pistons | 8 Std | 1.15 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 05 | clockwork_05 | Clock Tower | Climb to the clock | build race (M1) | watcher | clean, tense | Height 10 (cov. 0.6) | 4×4, H12 | 8 Std | 1.18 | trim | ~3.2 min | 165 / 115 s* |
| 06 | clockwork_06 | Pendulum Hall | Rebuild the pendulum | fixed list (AR09), fill shape (M2), budget (FT07) | watcher | clean, hushed | Shape 28 | 4×4, H6 | fixed: L T T I O O O | 0.60 | out of pieces | ~1.5 min | 80 / 55 s |
| 07 ★ | clockwork_07 | Stopwatch Square | Time stutters | Stopwatch Stutter (EV16) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.28 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 08 ★ | clockwork_08 | Winding Keys | Wind Tock up | Winding Keys (GO29) | watcher | clean, tense | Wind 4 keys | 5×5, H10, 4 keyholes | 8 Std, 2 key pieces per bag | 1.30 | rescue, 1 | ~3.5 min | 200 / 140 s |
| 09 | clockwork_09 | Rewind Works | The gears run backwards | Cog Turn + Rewind (EV03) | watcher | busy | Clear 4 | 6×6 turntable, H10 | 8 Std | 1.35 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 10 ★ | clockwork_10 | Cuckoo's Midnight | Boss: Cuckoo Prime | Tram Street + Pistons + Stopwatch | boss | busiest | Clear 3 | 8×6, H12 | I O T L Tripod Screws Chair | 1.40 | rescue, 1 | ~6.4 min | 325 / 230 s |
| B | clockwork_bonus | Music Box | The last cylinder pin | kit box (AR13) on a turning box (BL11) | watcher | clean, whimsical | Shape 28 | 4×4 turntable, H6 | kit: I I I O O L L | 0.60 | out of pieces | ~2 min | 110 / 75 s |
| H1 | clockwork_h1 | Spring Streets | Springs on the tram line | Tram Street + Spring Step (SP35) | watcher | busy | Clear 5 | 8×4, H10 | 8 Std | 1.30 | rescue, 1 | ~7 min | 365 / 255 s |
| H2 | clockwork_h2 | Piston Keys | Keys behind the pistons | Winding Keys + Pistons | watcher | busy, tense | Wind 5 keys | 5×5, H10 | 8 Std, 2 key pieces per bag | 1.30 | rescue, 1 | ~4.5 min | 260 / 185 s |
| H3 | clockwork_h3 | Frozen Turntable | The turntable and the stopwatch | Cog Turn + Stopwatch | watcher | busy | Clear 4 | 6×6 turntable, H10 | 8 Std | 1.30 | rescue, 1 | ~6.4 min | 325 / 230 s |

★ = prototype priority. \* ★★★ also requires no cube trimmed (05). Hand-set times: 05 (build race, as `forest_05`), 06 and B (piece lists), 08 and H2 (key goals). Length notes: 01, 02, 05, 06, 08 and B are short on purpose; the validator's 5–15 min length warning is expected on those.

**F1 budget table** (nd = non-default atoms, new = new to the player; "met" = an earlier written biome or an earlier Clockwork level):

| Level | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | BL02 | 1 | 0 (Meadow 04) |
| 02 | BL11 | 1 | 1 (BL11) |
| 03 | EV05 | 1 | 0 (Meadow 10) |
| 04 | EV20 | 1 | 1 (EV20) |
| 05 | M1 bundle | 1 | 0 |
| 06 | AR09, M2 bundle, FT07 | 3 | 0 (Forest 06, bonuses) |
| 07 | EV16 (`stopwatch`) | 1 | 1 (EV16) |
| 08 | GO29 | 1 | 1 (GO29) |
| 09 | BL11, EV03 | 2 | 0 |
| 10 | EV05, EV20, EV16 | 3 (cap 6, showpiece) | 0 |
| B | BL11, AR13, M2 bundle, FT07 | 4 | 0 |
| H1 | EV05, SP35 | 2 | 0 (SP35 Lava 04) |
| H2 | GO29, EV20 | 2 | 0 |
| H3 | BL11, EV16 | 2 | 0 |

Twists per level never exceed 2 (10 has 2 twists + the Tram Street mechanic; the finale's third-twist allowance is unused).

**Hard track (decision).** `clockwork_bonus` is tier 11 (unlocks at 20 clockwork stars). The remixes are **tiers 12–14** (`clockwork_h1`–`h3`); all three open when `clockwork_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay points as usual.

## 3. Layout overview

```text
01 cog plaza   02 workshop (turns)  03 tram street (→)   04 spring yard     05 clock tower
##.##          #####   ↻            ########            ######             ####
#####          #####                ########           P######  ← z1       ####
.###.          #####                ########            ######             ####
#####          #####                ########            ######             ####
##.##          #####                                    ######P  ← z4      (12 tall)
                                                        ######
06 pendulum    07 stopwatch square  08 winding keys     09 rewind works    10 clock face (tram →)
####           ######               ..K..               ######   ↻         ########
####           ######              K#####K  (walls)     ######             ########
####           ######               #####               ######             ########
####           ######               ..K..               ######             ########
(6 tall)       ######                                   ######             ########
               ######                                   ######             ########
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Clockwork; the next biome (Neon) opens with 15 of 30 clockwork stars. The town's far end, Neon, "switches on after midnight" (lore §2).
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the bonus Music Box (20 stars); hard-track remixes H1–H3 (after 10).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                   #     #
      |        #        #           #     #  #  #
  mid |        #  #     #           #  #  #  #  #   #
      |        #  #  #  #     #     #  #  #  #  #   #
  low |  #  #  #  #  #  #  #  #  #  #  #  #  #  #   #
      +-01-02-03-04-05-06-07-08-09-10--B
       learn turn tram piston climb puzzle stop keys rewind FINALE
```

Zig-zag, not a ramp: classic (01) → the turning bench (02) → the rolling street (03) → pistons (04) → a no-lose pair (05 climb, 06 pendulum puzzle with free retry) → the stopwatch (07) → keys (08, a short, thoughtful orientation level) → the remix of turn + rewind (09, the hardest) → the three-rule boss (10). Short and long alternate (campaign rule 12): short (01, 02), mid-long (03), mid (04), short (05, 06), long (07), short (08), long (09), long finale. The heavy levels (04, 07, 09) are separated by easier ones. The energy is "tense waiting": every level has a schedule, but the schedule is always visible.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 Cog Plaza

**Story card.** Tock's town square sits on a giant base cog, and tonight it must shine for the midnight party. Fill each layer of the cog and it clears: three clears and the plaza is polished. · **Tock: watcher**.
**Stage**: clean, calm; a cobbled cog plaza, tin mice sweeping, the clock tower far off at 11:50. **Light**: sepia evening. **Intro skit** (3 s): Tock waddles across the plaza carrying a gear bigger than himself, winds down mid-step and freezes (`sweat`); a tin mouse winds his key; hand-off: Tock looks up, glint, first piece. **Payoff skit** (4 s): the cog plaza clicks one notch round and gleams; Tock sees his reflection, straightens his bow tie, and the gear rolls away behind him (`exclaim`). **Mizzle clue**: none (slots 01–02 carry none). **Reactions (R)**: clear `note`; warning `sweat` (Tock runs down a little).

```text
Recipe: BL02 (5×5 cog mask, A = 21, H8) · AR01 · CV01 · GO01 (3) · FT01 (2 warnings) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Fill a whole layer of the cog and it clears."
New to the player: nothing. Tier 1 re-teaches the controls in the Clockwork look.
```
**Encounters**: none (pure classic). Pieces 8 Std; `opening_set` [O, I], count 2. `T_level` 180. Control: CV01, all three rotation pairs.

```text
mask 5×5 (A = 21; notches between the teeth)   side (z = 2)
##.##                                          11 . . S . .   spawn zone
#####                                           8 ==========  danger line
.###.                                           :
#####                                           0 . # # # .   the cog face
##.##
```
**How it plays**: (1) an O drifts down through lamp light. (2) The first layer clears in about 5 pieces: the cog clicks a notch, a soft tick-chime. (3) T, L and the 3D pieces arrive; the notches teach that the mask is part of the board (a notch is never a hole). (4) The third clear polishes the plaza.
**Teaches**: the controls and the rule, in the new look.
**Readability**: notches are dark recessed brass, never placeable; the cog teeth glint so the outline reads from every snap.
**Wacky test**: surprising, the floor is a gear; silly, Tock frozen mid-waddle; funny failure, Tock runs down on a warning and topples over like a toy; big moment, the plaza clicking round on the third clear.

```json
{ "schema": 1, "id": "clockwork_01", "biome": "clockwork", "tier": 1,
  "board": { "width": 5, "depth": 5, "h_play": 8,
             "mask": { "layers": { "all": ["##.##","#####",".###.","#####","##.##"] } },
             "spawn_anchor": { "x": 2, "z": 1 } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 0.97, "goal.warnings_max": 2, "goal.top_out": "rescue" },
  "goal": { "type": "clear_n", "N": 3, "T_level": 180 },
  "rules": [ { "id": "wo09_watcher", "params": {} } ],
  "stars": { "t2": 145000, "t3": 100000 },
  "music": "clockwork_01_tbd", "story": { "mascot_role": "watcher", "icon": "cog" } }
```

---

### 02 Gear Workshop ★PROTO

**Story card.** The workshop bench is a turntable: every few pieces it turns a quarter round, so the gap you left on the left is now at the back. Watch the cog ring light up and plan for the turn. · **Tock: watcher** (rides the bench, dizzy).
**Stage**: clean, calm; a cosy gear-pocket workshop, tools on hooks, a lamp. **Light**: sepia evening. **Intro skit** (3 s): Tock puts a gear on the bench; the bench turns a quarter and the gear is behind him; he turns, it turns again (`question`); hand-off. **Payoff skit** (4 s): the bench stops; Tock, still spinning, wobbles in a circle and sits down (`dizzy`), then grins and claps (`note`). **Mizzle clue**: none. **Reactions (R)**: turn wind-up `exclaim`; clear `note`.

```text
Recipe: BL11 Cog Turn on a 5×5 box (H10, turn_every_locks 4, cw) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO09
One sentence: "Every 4 pieces the bench turns a quarter: plan for the turn."
New to the player: BL11 (1).
```
**Encounters**: **Cog Turn** (§1): every 4 locks, clockwise, wind-up one lock ahead (the cog ring lights tooth by tooth, a curved arrow). Because the board is square and the turn is about the centre, the turned stack fits exactly; layers keep their counts, so a layer is as full after a turn as before. A layer completed by a lock clears **before** the turn. Pieces 8 Std. Stitch pins a turn (counter allowed).

```text
top-down 5×5 (turns ↻ every 4 locks)   side (z = 2)
#####                                  13 . . S . .   spawn zone
#####   gap at (0,3) …                 10 ==========  danger line
#####                                   :
###.#   … becomes (1,0) after ↻         0 # # . # #
#####
```
**How it plays**: (1) four calm pieces, then the cog ring lights and the bench turns; the player watches the gap move. (2) The ghost of the next piece already shows the turned stack, so aiming is always correct. (3) The player learns that a turn never hurts a flat stack: build flat and the turn is free. (4) Three clears.
**Teaches**: reading a scheduled board move, and that flat stacks are immune. The turn is the biome's signature "tick".
**Readability**: the turn is a 400 ms smooth rotation with a ratchet click; the camera never turns with it (world-anchored snaps), so controls stay the same. Only the stack moves.
**Wacky test**: surprising, the board turns under you; silly, Tock riding the bench; funny failure, a gap you saved swings to the far side and Tock shrugs; big moment, a clear right before the turn, then the empty bench spinning.

```json
{ "schema": 1, "id": "clockwork_02", "biome": "clockwork", "tier": 2,
  "board": { "width": 5, "depth": 5, "h_play": 10 },
  "knobs": { "fall.g0": 1.05, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 4, "turn_dir": "cw", "turn_warn_locks": 1 } } ],
  "stars": { "t2": 170000, "t3": 120000 },
  "recipe": { "atoms": ["BL11","AR01","CV01","CL01","CO01","GO01","FT01","SE05","WO09"] },
  "music": "clockwork_02_tbd" }
```

---

### 03 Tram Street

**Story card.** Tock's delivery route runs along a tram street, and the whole street rolls like a belt. Drop where the gap *will be*. · **Tock: watcher** (rides the tram roof).
**Stage**: busy; a cobbled street with a tram, shop windows, lamps lighting one by one. **Light**: sepia evening. **Intro skit** (3 s): Tock steps onto the street and it rolls him past three shop windows (`sweat`); hand-off. **Payoff skit** (4 s): the street stops at the clock tower's door; Tock hops off and bows to the tram, which dings. **Mizzle clue (M, 1.5 s, backdrop, static)**: a window across the square shows a long table with twelve chairs, all empty (no emote). **Reactions (R)**: tram bell `exclaim`; clear `note`.

```text
Recipe: BL01 (8 wide × 4 deep, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV05 Tram Street [mechanic] · WO09
One sentence: "The street moves your stack: drop where the gap will be."
New to the player: nothing (Meadow 10, Forest 09–10, Lava 09).
```
**Encounters**: **Tram Street** (conveyor): +x, every 3 locks, wrap on; the tram bell rings one lock ahead. Pieces 8 Std.

```text
top-down 8×4 (street → along x)   side (z = 1)
→ → → → → → → →                   13 . . . S S . . .   spawn zone
########                          10 ================  danger line
###S####                           :
########                           0 # # . # # # . #   → shift +x, wrap
########
```
**How it plays**: (1) after the 3rd lock the stack slides right and wraps. (2) The player learns the one-cell lead. (3) Long lanes mean I pieces are gold. (4) Four clears and the street delivers Tock to the tower.
**Teaches**: a known rule in the Clockwork rhythm; it sets up the finale.
**Readability**: the bell and the moving cobbles are the telegraph; the ghost shows the post-shift position on the shift lock.
**Wacky test**: surprising, a street that is a belt; silly, Tock surfing the tram roof; funny failure, the perfect gap rolls past the piece; big moment, the street stopping at the tower door.

```json
{ "schema": 1, "id": "clockwork_03", "biome": "clockwork", "tier": 3,
  "board": { "width": 8, "depth": 4, "h_play": 10, "spawn_anchor": { "x": 3, "z": 1 } },
  "knobs": { "fall.g0": 1.10, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true } } ],
  "stars": { "t2": 290000, "t3": 205000 },
  "music": "clockwork_03_tbd" }
```

---

### 04 Spring Yard ★PROTO

**Story card.** In the spring yard, wall pistons punch their rows every few pieces, shoving cubes inward to close the first gap. Leave your gaps at the wall, or let the piston fill a hole for you. · **Tock: watcher** (boings on a spring).
**Stage**: busy; a yard of coiled springs and brass pistons, wind-up frogs hopping in time. **Light**: lamp-lit night. **Intro skit** (3 s): a piston punches a crate into Tock, who boings into the air and lands on a spring (`exclaim`); hand-off. **Payoff skit** (4 s): the pistons punch in rhythm like a drum line; Tock and the frogs dance on top (`note`). **Mizzle clue (M, 1.5 s, backdrop) ★**: the mail-cloud drifts over the yard and drops a ribboned parcel into Cuckoo's door (`gift` over the mail-cloud). **Reactions (R)**: piston wind-up `exclaim`; a piston fills a hole `note`; jam: Tock giggles at the steam puff.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV20 Piston Punch (4 pistons) · WO09
One sentence: "Pistons punch their row inward and close the first gap."
New to the player: EV20 (1).
```
**Encounters**: **Piston Punch** (§1): `piston_locks` 4, wind-up one lock ahead. Pistons: west wall facing row `z = 1` at layers 0 and 1; east wall facing row `z = 4` at layers 0 and 1. A push closes the first gap from the wall and opens the wall-side cell (always reachable from above if the cell above it is empty). The pistons only act on the bottom two layers, so the twist matters most early and when the stack is low: it teaches without wrecking a tall build. Pieces 8 Std. Stitch vetoes a push.

```text
top-down 6×6 (P = piston beside a row)   side (row z = 1, layers 0–1, piston on the left)
######                                   10 ==============
P######   → row z = 1                     :
######                                    1 P # # . # # #   before: gap at x = 2
######                                    1 P . # # # # #   after:  cubes x0–1 shift → x1–2
######P   ← row z = 4                     0 P # # # # # #   full row: jam (steam puff)
######
```
**How it plays**: (1) a calm start; the first wind-up glows on a row with a gap; the push closes the gap with a clang. (2) The player sees a gap move to the wall edge, where it is easy to fill. (3) They start leaving gaps on the piston rows on purpose: the piston finishes the layer for them (a push that completes a layer clears). (4) Three clears.
**Teaches**: a board twist you can **use**. The jam rule (full row or empty edge = nothing) keeps it predictable.
**Readability**: only rows with a piston can move; their wall plates are painted with an arrow. The wind-up glow shows which pistons will move (jams show a grey plate).
**Wacky test**: surprising, the wall punches your stack; silly, frogs hopping in time with the pistons; funny failure, a piston shoves the gap under your best piece and Tock covers his eyes; big moment, a push that completes a layer and clears it with a "ka-CHUNK".

```json
{ "schema": 1, "id": "clockwork_04", "biome": "clockwork", "tier": 4,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.15, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "pistons", "params": { "piston_locks": 4,
               "pistons": [ {"wall":"-x","row":1,"y":0}, {"wall":"-x","row":1,"y":1},
                            {"wall":"+x","row":4,"y":0}, {"wall":"+x","row":4,"y":1} ] } } ],
  "stars": { "t2": 245000, "t3": 175000 },
  "music": "clockwork_04_tbd" }
```

---

### 05 Clock Tower

**Story card.** Tock must climb to the clock tower's door to deliver the gear. Stack to the sign; nothing clears, too high pops off, and you cannot lose. · **Tock: watcher** (climbs as the tower grows).
**Stage**: clean, tense; the narrow tower shaft, the clock face huge above at 11:54. **Light**: lamp-lit night. **Intro skit** (3 s): Tock looks up at the door far above, winds down from the thought (`sweat`), is wound up, and points at the shaft; hand-off. **Payoff skit** (4 s): Tock reaches the door and knocks; it is the cuckoo's door, which snaps open, the cuckoo pops out halfway, holds, and snaps shut in his face (`exclaim`). **Mizzle clue (M, 1.5 s, backdrop) ★**: in the window across the square, one figure sits at the long table, waiting; the clock tries to strike and stops (no emote). **Friend cameo**: Glim hangs upside-down from a beam in the backdrop, sketching the tower on her blueprint (no gameplay). **Reactions (R)**: layer 5 `note`; trimmed cubes `sweat`.

```text
Recipe: BL01 (4×4, H12) · AR01 · CV01 · M1 build race (GO02 height 10, coverage 0.6 + CL14 + FT02 trim) · CO01 · WO09
One sentence: "Build up to the sign; nothing clears."
New to the player: nothing (M1 from Meadow 05).
```
**Encounters**: none; no twists. Pieces 8 Std. Trim: cubes at or above layer 12 pop off; the level never fails.

```text
top-down 4×4    side (z = 2)
####            15 . S S .   spawn zone
####            12 ========  danger line (trim)
####            10 - - - -   sign: layer 10 must be ≥ 60% full (10 of 16)
####             :
                 0 . . . .
```
**How it plays**: (1) the floor fills; a full layer glows and stays. (2) The height meter climbs with Tock. (3) A narrow shaft makes every misplaced piece matter. (4) Layer 10 reaches 10 cubes; Tock knocks.
**Teaches**: a no-fail breather after the pistons; the pleasure is the climb.
**Readability**: the sign is a brass bracket with a lamp; the trim line is the tower's top beam. No danger music.
**Wacky test**: surprising, full layers stay; silly, Tock climbing his own tower; funny failure, cubes ping off the beam like popcorn; big moment, the cuckoo slamming its door on Tock.

```json
{ "schema": 1, "id": "clockwork_05", "biome": "clockwork", "tier": 5,
  "board": { "width": 4, "depth": 4, "h_play": 12 },
  "knobs": { "fall.g0": 1.18, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 10, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": {} } ],
  "stars": { "t2": 165000, "t3": 115000 },
  "music": "clockwork_05_tbd" }
```

---

### 06 Pendulum Hall (puzzle)

**Story card.** The tower's pendulum fell off its hook. Seven pieces, no spares: rebuild the bob and the rod on the glowing outline. · **Tock: watcher** (swings his head side to side like a pendulum).
**Stage**: clean, hushed; a tall hall, the empty pendulum hook, slow shadows. **Light**: lamp-lit night. **Intro skit** (3 s): the hall's clock ticks once and stops; Tock looks at the empty hook, then at the pile of parts (`question`); hand-off. **Payoff skit** (4 s): the rebuilt pendulum swings; Tock follows it with his head, gets dizzy, and sits (`sweat`), then the clock ticks again (`note`). **Mizzle clue (M, 1.5 s, backdrop) ★**: across the square, as the clock tries to strike, a violet cuff straightens a chair at the long table (no emote). **Reactions (R)**: good fit `note`; wrong lock `sweat`.

```text
Recipe: BL01 (4×4, H6) · AR09 fixed list [L, T, T, I, O, O, O] · CV01 · M2 fill shape (GO03 28 cells + CL14) · FT07 piece budget (7) · WO09
One sentence: "Seven pieces, no spares: rebuild the pendulum."
New to the player: nothing (AR09, M2 and FT07 met in Forest 06 and the bonuses). Retry is free and instant.
```
**Encounters**: none. Preview 3. Target: the bob, a full 4×4 base on layer 0 (16), and the rod, a 2×2 column on layers 1–3 over the centre (12): 28 cells. **Known solution** (for the validator's `solution` list), layer 0: L on (0,0) (1,0) (2,0) (0,1); T on (3,0) (3,1) (3,2) (2,1); T on (1,1) (0,2) (1,2) (2,2); I on z = 3 (x0–3). Layers 1–3: an O on x1–2, z1–2 per layer. Dealt in list order, every placement is supported. The L may need a Flip to be mirrored, depending on how it spawns. Redraw has no effect (the list is the puzzle). Stars: ★★ 80 s, ★★★ 55 s (no timer on screen).

```text
target layer 0 (16)   layers 1–3 (4 each)   side (z = 1)
####                  ....                  6 ======   danger line
####                  .##.                  3 . # # .  rod
####                  .##.                  2 . # # .
####                  ....                  1 . # # .
                                            0 # # # #  bob
```
**How it plays**: (1) read the preview (L, T, T) and the glowing cells. (2) The L and the two Ts interlock in the base; the I seals the front row. (3) Three O's stack straight up the middle. (4) The pendulum swings. A misplaced piece wastes a piece; retry is free.
**Teaches**: the puzzle verb as a breather between the climb and the stopwatch.
**Readability**: target cells glow lamp cream; filled cells go solid brass; the next piece in the list shows its ghost.
**Wacky test**: surprising, a pendulum built bottom-up; silly, Tock's pendulum head; funny failure, the hall clock goes "tock?" and the outline dims; big moment, the first swing.

```json
{ "schema": 1, "id": "clockwork_06", "biome": "clockwork", "tier": 6,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "fixed_list": ["l","t","t","i","o","o","o"] },
  "knobs": { "fall.g0": 0.60, "spawn.preview_count": 3, "goal.top_out": "out_of_pieces", "skill.redraw": "off" },
  "goal": { "type": "shape", "piece_budget": 7,
            "target_shape": { "layers": { "0": ["####","####","####","####"],
                                          "1": ["....",".##.",".##.","...."],
                                          "2": ["....",".##.",".##.","...."],
                                          "3": ["....",".##.",".##.","...."] } } },
  "stars": { "t2": 80000, "t3": 55000 },
  "solution": "see level notes",
  "music": "clockwork_06_tbd" }
```

---

### 07 Stopwatch Square ★PROTO

**Story card.** Cuckoo has been fiddling with the town stopwatch, and time stutters: the falling piece freezes in mid-air, then hurries to catch up. Aim while it is frozen; drop before the rush. · **Tock: watcher** (freezes mid-waddle with every stop).
**Stage**: busy; a square with a giant stopwatch on a plinth, townsfolk frozen mid-step whenever it clicks. **Light**: clock-face moonlight (the backdrop tints cool for each freeze, staging only). **Intro skit** (3 s): the stopwatch clicks; Tock and a tin mouse freeze mid-step; it clicks again and both rush on and bump into each other (`sweat`); hand-off. **Payoff skit** (4 s): the stopwatch is tamed; Tock clicks it once, freezes the tin mouse mid-sneeze, clicks again, and the sneeze blows Tock's hat off (`exclaim`). **Mizzle clue (M, 1.5 s, payoff end, backdrop window)**: the figure at the long table counts on his fingers to twelve, then to one (`dots`). **Reactions (R)**: stop warning `exclaim`; catch-up `sweat`; clear `note`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV16 Stopwatch Stutter (rule stopwatch) · WO09
One sentence: "Time freezes your piece, then makes it rush: aim in the freeze."
New to the player: EV16 / stopwatch (1).
```
**Encounters**: **Stopwatch Stutter** (§1): every 14 s ± 3 s; warning 1 s; freeze 2.5 s; catch-up ×1.6 for 2.5 s. During the freeze a big ring on the board edge drains like a stopwatch hand; during the catch-up the piece's trail stretches. Pieces 8 Std.

```text
top-down 6×6        side (z = 2)
######              13 . . S . . .   spawn zone (piece frozen mid-air)
######              10 =============  danger line
##S###               :
######               0 # # . # # #
######
######
```
**How it plays**: (1) a calm start; the second hand stops, the piece hangs, and the player discovers it can still move and turn. (2) The catch-up comes: a piece left high falls fast. (3) The player learns to use the freeze to line up and hard drop before the rush. (4) Four clears.
**Teaches**: a timing twist that is a gift if read; prepares the finale's stopwatch.
**Readability**: the freeze ring and the cool tint are the telegraph; gravity never changes without the ring. A stop never starts in Resolving or Waiting (dropped). The ticking SFX is distinct from any countdown.
**Wacky test**: surprising, your piece stops in mid-air; silly, a whole square frozen mid-step; funny failure, the catch-up drops a piece into the wrong slot and Tock freezes in horror; big moment, a perfect freeze-aim and a hard drop that clears two layers.

```json
{ "schema": 1, "id": "clockwork_07", "biome": "clockwork", "tier": 7,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.28, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "stopwatch", "params": { "stop_every_ms": 14000, "stop_jitter_ms": 3000, "stop_warn_ms": 1000,
               "stop_ms": 2500, "catchup_scale": 1600, "catchup_ms": 2500 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "clockwork_07_tbd" }
```

---

### 08 Winding Keys ★PROTO

**Story card.** Tock has run down completely in the winding-key square. Four keyholes sit in the walls around him: lock a key piece next to each keyhole with its brass key facing the wall, and each turn winds him up a little more. · **Tock: watcher** (slumped, perks up one notch per key).
**Stage**: clean, tense; a small square, Tock slumped on a bench, four brass keyholes in the low walls. **Light**: clock-face moonlight. **Intro skit** (3 s): Tock ticks slower, slower, and stops, beak open (`sweat`); the townsfolk point at the keyholes; hand-off. **Payoff skit** (4 s): the fourth key turns; Tock springs up fully wound and races in a circle so fast he leaves a dust ring, then stops and bows (`note`). **Mizzle clue (M, 1.5 s, backdrop window)**: as the hands jam again, the waiting figure's hat droops (`tear`). **Reactions (R)**: key turned `note`; keyhole lined up `exclaim`; warning `sweat`.

```text
Recipe: BL01 (5×5, H10) · AR01 · CV01 · GO29 Winding Keys (keys_needed 4, key_per_bag 2) · FT01 (1) · CL01 + CO01 · WO09
One sentence: "Turn the key face to the keyhole and lock it there."
New to the player: GO29 (1). Uses all three rotation pairs (Turn / Flip / Roll).
```
**Encounters**: **Winding Keys** (§1). Keyholes: west wall at `z = 2`, layer 1; east wall at `z = 2`, layer 2; back wall at `x = 2`, layer 3; front wall at `x = 2`, layer 1. Two pieces per bag carry a key stamp. Layers still clear: clearing the layer at a keyhole frees a cell that a plain cube covered. Wound keyholes stay wound when their layer clears. Pieces 8 Std. The level is short because the goal is 4 placements, not 4 layers; most time is spent building to the keyhole heights. Stars hand-set: ★★ 200 s, ★★★ 140 s.

```text
top-down 5×5 (K = keyhole in the wall, its layer)   side (z = 2)
..K..   back, layer 3                               13 . . S . .   spawn zone
K#####K west layer 1 / east layer 2                 10 ===========  danger line
 #####                                               3 . . . . .    (back keyhole at x = 2)
 #####                                               2 . . . . . K  east keyhole
 #####                                               1 K k # # .    k = key cube, stamp facing west
..K..   front, layer 1                               0 # # # # #
```
**How it plays**: (1) a key piece spawns; the ghost shows its brass stamp. (2) The player builds layer 0 and rolls the key piece so the stamp faces the west wall at layer 1: the keyhole glows on the ghost, the key turns, Tock twitches. (3) Higher keyholes need a flat stack to the right height; a plain cube over a keyhole is freed by a clear. (4) The fourth key and Tock races off.
**Teaches**: orientation as the goal, the payoff for the 3rd rotation pair. A short, thoughtful level between two long busy ones.
**Readability**: the stamp is a bold brass key decal on one face, visible on the piece, its ghost and the preview; a keyhole glows only when the ghost's stamp would wind it. No twist runs here, so the only motion is the player's.
**Wacky test**: surprising, the goal is which way a face points; silly, Tock perking up one notch per key; funny failure, a key piece locks with the stamp facing the sky and Tock's eye twitches; big moment, the dust ring.

```json
{ "schema": 1, "id": "clockwork_08", "biome": "clockwork", "tier": 8,
  "board": { "width": 5, "depth": 5, "h_play": 10,
             "keyholes": [ {"wall":"-x","row":2,"y":1}, {"wall":"+x","row":2,"y":2},
                           {"wall":"-z","row":2,"y":3}, {"wall":"+z","row":2,"y":1} ] },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1 },
  "goal": { "type": "wind_keys", "keys_needed": 4 },
  "rules": [ { "id": "key_stamp", "params": { "key_per_bag": 2 } } ],
  "stars": { "t2": 200000, "t3": 140000 },
  "music": "clockwork_08_tbd" }
```

---

### 09 Rewind Works (remix)

**Story card.** Deep in the works, the gears run backwards: the bench turns a quarter every few pieces, and every two clears the whole stack rewinds, turning upside down in place. Keep the top flat, because the top becomes the floor. · **Tock: watcher** (walks backwards).
**Stage**: busy; huge gears spinning backwards, the clock hands sweeping back a minute on every rewind. **Light**: clock-face moonlight. **Intro skit** (3 s): Tock steps forward and the floor walks him backwards; he tries again and ends further back (`sweat`); hand-off. **Payoff skit** (4 s): the gears stop; Tock walks forward one triumphant step, and the hands tick on to 11:59. **Mizzle clue (M, 1.5 s, backdrop window)**: the figure pushes his glasses up and sets out one more cup at the long table, just in case (`dots`). **Reactions (R)**: turn wind-up `exclaim`; rewind warning `exclaim`; clear `note`.

```text
Recipe: BL11 Cog Turn on a 6×6 box (H10, turn_every_locks 5, ccw) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV03 Rewind (flip_mode stack) · WO09
One sentence: "The bench turns, and every two clears the stack rewinds."
New to the player: nothing (BL11 from 02, EV03 from Meadow 09 / Ice 09).
```
**Encounters**: **Cog Turn**: every 5 locks, counter-clockwise (the gears run backwards). **Rewind**: `flip_every_layers` 2, `flip_every_ms` 40 000, `flip_warn_ms` 2 000; arrows curl over the stack, the hands sweep back. Both apply in Resolving; if both fall due in the same Resolving, the rewind applies (S4a) and the turn waits one lock. Stitch vetoes both (counter allowed). Pieces 8 Std.

```text
top-down 6×6 (turns ↺ every 5 locks)   side (z = 2), before → after a rewind
######                                 13 . . S . . .     . . S . . .
######                                 10 ============    ============
##S###                                  :                  :
######                                  1 # . # # . #      # # . # # #   old floor is now the top
######                                  0 # # . # # #      # . # # . #
######
```
**How it plays**: (1) normal stacking; the bench turns backwards on the 5th lock. (2) The second clear brings the rewind warning; the stack turns over. (3) The player keeps the top flat and buried holes come up to the top to be filled. (4) The fourth clear and the works stop.
**Teaches**: the remix of two known ideas; the hardest combination in the biome.
**Readability**: the turn and the rewind have different telegraphs (tooth ring vs. curling arrows and a countdown ring) and never apply on the same Resolving.
**Wacky test**: surprising, the stack turns sideways and over; silly, Tock walking backwards; funny failure, a spiky top becomes a messy floor and the cuckoo pops out to laugh; big moment, a rewind that brings three buried holes up for one perfect piece.

```json
{ "schema": 1, "id": "clockwork_09", "biome": "clockwork", "tier": 9,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.35, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 5, "turn_dir": "ccw", "turn_warn_locks": 1 } },
             { "id": "flip", "params": { "flip_mode": "stack", "flip_every_layers": 2, "flip_every_ms": 40000, "flip_warn_ms": 2000 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "clockwork_09_tbd" }
```

---

### 10 Cuckoo's Midnight (boss: Cuckoo Prime) ★PROTO

**Story card.** Cuckoo Prime has stuffed the clock-stopper into his gears and jammed the hands at one minute to midnight. The clock face rolls your stack like a tram, his pistons punch the low rows, and he stops the stopwatch. Each clear moves the hands a notch and climbs the stack toward the bell; the third clear pops the stopper out, and the bell strikes twelve. · **Boss**: Cuckoo Prime (a tall clock house, a cuckoo on a spring, two hands as arms); Tock clutches the last gear and watches.
**Stage**: busiest, but readable; the clock face itself, the bell above, the town far below. **Light**: midnight strike (one warm bell bloom on the backdrop at the end; no full-screen flash). **Intro skit** (3 s, from the skits doc): 0.0–1.0 Cuckoo Prime pops out and stuffs the ribboned clock-stopper into his own gears (`smug`); 1.0–2.0 the hands jam at one minute to twelve and the town's gears start to run backwards; 2.0–3.0 hand-off: Tock looks up at the wizard, glint, first piece. **Payoff skit** (6 s on first play, beats 4–5 on replays; from the skits doc): 0.0–1.5 last clear: the clock-stopper pops out of the gears, the hands click to twelve; 1.5–3.0 the bell strikes; Cuckoo is sprung out on his spring, boinging, still ticking smugly (`smug`); keepsake pop: the gear; 3.0–4.0 Tock gets a full wind and dances (`note`); 4.0–5.0 [R] the clock face swings open: inside, a table set for twelve, every chair empty, one cup missing; 5.0–6.0 [R] the wand glint (the player's last clear) sets one cup in the gap; the cups ring softly. **Mizzle clue**: the open table is the finale's one thread beat (flag 8 stays on the cuckoo door as set dressing, no hold). **Reactions (R)**: each clear Cuckoo's door slams and the hands tick (`angry`); warning use Cuckoo pops out grinning (`smug`).

```text
Recipe: BL01 (8 wide × 6 deep, H12) · AR01 · CV01 · GO01 (3 = three notches to twelve) · FT01 (1) · CL01 + CO01 · EV05 Tram Street [mechanic] · EV20 Piston Punch · EV16 Stopwatch Stutter · WO09
One sentence: "The clock face rolls your stack; pistons punch and time stutters."
New to the player: nothing (all three known).
```
**Encounters**:
- **Tram Street** (conveyor, the clock face's gear rim): +x, every 3 locks, wrap on (the board is a rectangle because Conveyor forbids masks).
- **Piston Punch**: two pistons on the front wall (`z = 6` side, pushing −z) facing columns `x = 2` and `x = 5` at layer 1, every 4 locks. Because the belt moves the stack under the pistons, a piston row is always "whatever cubes are under the piston now". If the belt and a piston fall due on the same lock, the piston waits one lock (§1).
- **Stopwatch Stutter**: every 16 s ± 3 s (slower than 07), freeze 2 s, catch-up ×1.5 for 2 s.
- **Staggered starts (decision)**: the belt shifts on lock 3, the first piston wind-up is on lock 4 (applies at lock 5 after deferral rules), and the first stop falls due at about 13–19 s, so the three rules arrive one after another. Each clear moves the clock hands a notch and lifts the camera toward the bell (staging only); the rules do not change between clears. Spring pads and the turntable are not used (the third-twist allowance is unused).
- **Escape feel**: the danger line is drawn as the midnight mark on the clock face; the player is racing to the bell before "midnight forever" sets in.
- Cuckoo is the face of the rules: the belt is his rim turning, the pistons are his pendulum punches, the stopwatch is the cuckoo bird holding the second hand. He sulks on each clear.

```text
top-down 8×6 (belt → along x; pistons P push −z on columns x2, x5)   side (z = 3)
→ → → → → → → →                                                     15 . . . S S . . .   spawn zone
########                                                            12 ================  danger line (the midnight mark)
########                                                             :
###S####                                                             1 # # . . # # . #
########                                                             0 # # # . # # # #   → shift +x, wrap
########
########
..P..P..   front wall
```
**How it plays**: (1) after the 3rd lock the whole stack rolls right; the first piston wind-up glows. (2) The first stop freezes a piece in mid-air; the player aims and drops. (3) Each clear moves the hands a notch; Cuckoo's door slams. (4) The third clear pops the stopper out and the bell strikes.
**Teaches**: nothing new: the final exam of the belt, the pistons and the stopwatch.
**Readability**: three distinct telegraphs (tram bell and cobbles, piston glow and hiss, stopwatch ring and cool tint), never on the same lock, each a different colour family (brass, steam white, slate blue). If playtests find it too busy, slow the stopwatch to every 20 s or drop the pistons (§10).
**Wacky test**: surprising, the clock face itself is the board; silly, Cuckoo's smug ticking; funny failure, he pops out and does a little dance when you use a warning; big moment, the bell strike and the open table.

```json
{ "schema": 1, "id": "clockwork_10", "biome": "clockwork", "tier": 10,
  "board": { "width": 8, "depth": 6, "h_play": 12 },
  "pieces": { "shapes": ["i","o","t","l","tripod","screw_l","screw_r","chair"] },
  "knobs": { "fall.g0": 1.40, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "conveyor", "params": { "dir": "+x", "conveyor_every": 3, "conveyor_wrap": true } },
             { "id": "pistons", "params": { "piston_locks": 4,
               "pistons": [ {"wall":"+z","row":2,"y":1}, {"wall":"+z","row":5,"y":1} ] } },
             { "id": "stopwatch", "params": { "stop_every_ms": 16000, "stop_jitter_ms": 3000, "stop_warn_ms": 1000,
               "stop_ms": 2000, "catchup_scale": 1500, "catchup_ms": 2000 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "clockwork_10_tbd", "story": { "mascot_role": "boss", "icon": "cuckoo" } }
```

---

### B Music Box (bonus, tier 11, 20 clockwork stars)

**Story card.** A music box on the shop counter is missing its cylinder. Pick the pieces in any order from the kit box and rebuild it, but the box turns a quarter every two pieces, like a wound-up cylinder. Seven pieces, no spares. · **Tock: watcher** (sways to the tune).
**Stage**: clean, whimsical; the inside of a music box, a tiny dancer waiting on her spring. **Light**: music-box interior. **Intro skit** (3 s): Tock winds the music box key; it plays one note and clunks; the dancer droops (`question`); hand-off. **Payoff skit** (5 s, from the skits doc): 0.0–2.0 the last cylinder pin fits; the lid opens and a tiny dancer spins; 2.0–4.0 Tock dances along and winds down halfway through a twirl (`sweat`); 4.0–5.0 the music box's key winds Tock up; both spin (`note`). **Postcard 8** (Scrapbook only, not in-level): he cuts the sheet into ten flags and ties each to a ribbon (`dots`). **Reactions (R)**: good pick `note`; wrong lock `sweat`.

```text
Recipe: BL11 Cog Turn on a 4×4 box (H6, turn_every_locks 2, cw) · AR13 kit box [I, I, I, O, O, L, L] · CV01 · M2 fill shape (GO03 28 cells + CL14) · FT07 piece budget (7) · WO09
One sentence: "Seven pieces in any order, on a box that turns."
New to the player: nothing (AR13 Ice/Forest bonuses, BL11 from 02). Retry is free.
```
**Encounters**: none beyond the turn. The kit box shows all seven pieces; pick one, it falls. Target: layer 0 full (16) and a ring on layer 1 (12): 28 cells. Both target layers are **90°-symmetric**, so a turn always maps covered targets onto targets: the turn never ruins progress, it only moves where the gaps are. **Known solution** (before any turn; after a turn, place the same piece in the turned gap): layer 0: I on z = 0, I on z = 3, O on x0–1 z1–2, O on x2–3 z1–2; layer 1: I on z = 0, L on (x0, z1–3) + (x1, z3), L on (x3, z1–3) + (x2, z3). Layer 0 must be finished before the ring (support). Redraw has no effect. Stars: ★★ 110 s, ★★★ 75 s.

```text
layer 0   layer 1   side (z = 1)
####      ####      6 =====
####      #..#      :
####      #..#      1 # . . #   the ring (cylinder)
####      ####      0 # # # #   the base
```
**How it plays**: (1) read the kit and the two-layer box. (2) Pick the base pieces; after every second lock the box turns and the gap moves. (3) The ring's I and L's close the rim; the hollow stays empty for the dancer. (4) The last "pin" and the lid opens.
**Teaches**: the kit box on a moving board; it is the biome's wackiest level (the turning box and the dancing duck).
**Readability**: target cells glow lamp cream; used pieces are greyed in the box; the turn wind-up is the same tooth ring as 02.
**Wacky test**: surprising, the box turns while you pack it; silly, Tock twirling with the dancer; funny failure, a wrong pick and the music box plays a sour note; big moment, the lid opening on the dancer.

```json
{ "schema": 1, "id": "clockwork_bonus", "biome": "clockwork", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "kit": ["i","i","i","o","o","l","l"] },
  "knobs": { "fall.g0": 0.60, "spawn.arrival": "kit_box", "goal.top_out": "out_of_pieces", "skill.redraw": "off" },
  "goal": { "type": "shape", "piece_budget": 7,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["####","#..#","#..#","####"] } } },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 2, "turn_dir": "cw", "turn_warn_locks": 1 } } ],
  "stars": { "t2": 110000, "t3": 75000 },
  "solution": "see level notes",
  "music": "clockwork_bonus_tbd" }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Spring Streets

**Story card.** The tram street now has springs in the cobbles: a piece that lands on one boings up and hops a cell onward, while the street keeps rolling. · **Tock: watcher** (boings along the tram line). **Light**: sepia evening. **Intro skit**: Tock steps on a spring and boings onto the tram roof (`exclaim`). **Payoff skit**: Tock rides the tram, boinging on every spring, and lands on the clock tower step with a bow.

```text
Recipe: BL01 (8 wide × 4 deep, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV05 Tram Street [mechanic] (+x, every 3, wrap) · SP35 Spring Step (3 springs on the floor at (1,1), (4,2), (6,0); bounce_h 1)
```
```text
top-down 8×4 (→, ^ = spring)   side (z = 1)
########                       10 ================
#^######                        :
####^###                        0 . ^ . . . . . .   springs ride the belt like any content
######^#
```
Pieces 8 Std; `g0` 1.30; Clear 5; ★★ 365 s, ★★★ 255 s (~7 min). Springs are floor content and clear with their layer (then they are gone). Music `clockwork_03_tbd` until the user supplies a track.

### H2 Piston Keys

**Story card.** The keyholes are back, and pistons now punch the rows in front of them. Wind five keys before the pistons shove your key cubes out of line. · **Tock: watcher** (slumped again, eyes on the pistons). **Light**: clock-face moonlight. **Intro skit**: a piston punches Tock's key out of his back; it rolls away (`sweat`). **Payoff skit**: Tock, fully wound, punches a piston back with his wing; it jams with a puff.

```text
Recipe: BL01 (5×5, H10) · AR01 · CV01 · GO29 Winding Keys (keys_needed 5, key_per_bag 2; keyholes −x z2 y1, +x z2 y2, −z x2 y3, +z x2 y1, −x z4 y3) · FT01 (1) · CL01 + CO01 · EV20 Piston Punch (every 5 locks; pistons −z wall row x1 y1, +z wall row x3 y2)
```
```text
top-down 5×5 (K keyhole, P piston)   side (z = 2)
.PK..                                10 ===========
K#####K                               2 . . . . . K
 #####                                1 K k # # .
 #####
K#####                                (a push moves a locked key cube; a key already wound stays wound)
...KP
```
Pieces 8 Std; `g0` 1.30; Wind 5; hand-set ★★ 260 s, ★★★ 185 s (~4.5 min). Pistons never face a row that holds a keyhole cell (validator), so a push cannot unwind a key. Stitch vetoes a push.

### H3 Frozen Turntable

**Story card.** The bench turns and the stopwatch stutters together: aim in the freeze, and remember the bench will turn after you land. · **Tock: watcher** (frozen on the spinning bench). **Light**: lamp-lit night. **Intro skit**: the stopwatch clicks; Tock freezes on the bench while it keeps turning (`sweat`). **Payoff skit**: Tock clicks the stopwatch himself and the bench stops a hair before his beak hits the vice.

```text
Recipe: BL11 Cog Turn on a 6×6 box (H10, turn_every_locks 4, cw) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV16 Stopwatch Stutter (every 13 s ± 3 s, freeze 2.5 s, catch-up ×1.6 for 2.5 s)
```
```text
top-down 6×6 (↻ every 4)   side (z = 2)
######                     13 . . S . . .   piece frozen
######                     10 =============
##S###                      :
######                      0 # # . # # #
######
######
```
Pieces 8 Std; `g0` 1.30; Clear 4; ★★ 325 s, ★★★ 230 s (~6.4 min). The turn is a board move in Resolving and the stop acts only on a falling piece, so they never collide.

---

## 8. Narrative beats

Wordless (campaign story rules): intro and payoff skits per level, Tock's reactions, Cuckoo in the backdrop from 01, and one Mizzle clue per level from 03 (at most 1.5 s, never over the grid, never during a warning; strength cap 2 = partly seen). Clue slots follow `dialogue-campaign-skits.md` §8 exactly. Arc: Tock polishes the plaza (01), rides the turning bench (02), is rolled down the tram street (03), is boinged by pistons (04), knocks on the cuckoo's door (05), rebuilds the pendulum (06), is frozen by the stopwatch (07), runs down and is wound up (08), walks backwards through the works (09), and gets the bell to strike twelve (10). The bonus and remixes are after-party gags.

| Level | Mizzle clue (strength cap 2) | Emote | Where |
|---|---|---|---|
| 03 | A window across the square shows a long table with twelve chairs | none | backdrop, static |
| 04 | ★ The mail-cloud delivers the parcel to Cuckoo's door | `gift` | backdrop, 1.5 s |
| 05 | ★ In the window, one figure sits at the long table, waiting; the clock tries to strike | none | backdrop, 1.5 s |
| 06 | ★ As the clock tries to strike, a violet cuff straightens a chair | none | backdrop, 0.5–1.5 s |
| 07 | The figure counts on his fingers to twelve, then to one | `dots` | payoff end |
| 08 | The figure's hat droops as the hands jam again | `tear` | payoff end |
| 09 | The figure pushes his glasses up and sets out one more cup, just in case | `dots` | payoff end |
| 10 | The clock face opens on the table; the wand glint sets one cup (finale thread beat; flag 8 is set dressing) | none | payoff [R] |

**Arrival (map, 4 s; from the skits doc)**: the cloud drifts into the sepia town; the mail-cloud drops a ribboned box into the clock tower's door; Tock winds down mid-step and is wound up by a townsperson's key.
**Map change (3 s, after the finale; from the skits doc)**: the clock chimes over the island and the hands move again; flag 8 hangs on the cuckoo door; on top of Mizzle's horizon tower a small table appears, set. **Hidden thread**: the long-table window is in the backdrop of every level from 03, lit warmer each level.

## 9. Music and audio cues

One track per level, supplied by the user; ids are placeholders (`clockwork_01_tbd` … `clockwork_10_tbd`, `clockwork_bonus_tbd`; H1–H3 reuse `clockwork_03_tbd`, `clockwork_08_tbd` and `clockwork_07_tbd` until the user provides new ones). Until the tracks arrive, every Clockwork level plays the biome `default_music` ("Carefree" is a placeholder only). No stems and no layered mixes: each track simply plays for its level. Authoring notes for the user's tracks: 01–03 a gentle music-box waltz, 04 bouncier (springs), 05–06 hushed (no danger music, since neither can be lost), 07 stop-start, 08 slow and thoughtful, 09 a melody that sounds "played backwards", 10 the biggest, ending on the twelve bell strikes; the bonus a real music-box tune. A **danger stinger** only where `topout_rule` is rescue. Skits use short stingers, never voices.

SFX cues (one-shots, no music change): a ratchet click on every turn and a tooth-by-tooth tick on its wind-up; a steam hiss before a piston, a "ka-CHUNK" on a push and a puff on a jam; a tram bell before a belt shift; a "tick… TOCK" before a stopwatch stop and a whoosh on the catch-up (must not sound like a countdown timer: audio-director); a key-turn and a little wind-up whirr on each wound keyhole; one bell strike per clear in 10 and twelve at the payoff. Ambience (under the SFX slider): layered ticking at slightly different tempos, springs, tin-mouse brooms, a distant chime that never completes until 10. The SFX pack (MB-003) provides the base sounds.

## 10. Open questions

- **New rules needing owners.** EV20 Piston Punch (Proposed): my push reading ("cubes from the wall up to the first gap shift one inward; edge empty or row full = jam") and the per-layer piston data `{wall, row, y}` need confirming in the module §2b. GO29 Winding Keys (Proposed): the key stamp is a per-bag content (`key_per_bag`, a proposed param) and "wound stays wound through a clear" is my default. **Stopwatch Stutter** is a new rule under the EV16 biome-event container (no own atom id; params `stop_every_ms`, `stop_ms`, `catchup_scale`, `catchup_ms`); the game-designer may prefer a numbered atom. BL11 Cog Turn (Candidate) needs its level-rule form (`turntable`, `turn_every_locks`, `turn_dir`, a `turn_windup` event, a `stack` tag) beyond MG12. Owner: game-designer.
- **Atom id clashes in other biome files** (seen while counting F1, not mine to fix): `candy.md` uses EV25 for the Syrup band while `forest.md` uses EV25 for the Squirrel Heist; `candy.md` and `ice.md` both use SP41 for different atoms. This file invents no ids.
- **Same-lock collisions.** Pistons, the conveyor and the turntable all write the stack in Resolving. I defer the piston (or the turn) one lock when two fall due together; the framework should state one general order rule for `stack` writers.
- **Redraw on puzzle levels.** Glim's Redraw re-rolls queued shapes, which would break fixed-list and kit puzzles. 06 and B set `skill.redraw` off (a proposed level knob); Skills / WO14 should own a general rule ("no Redraw on AR09 / AR13 levels").
- **Mail-cloud delivery slot.** The skits doc puts it in the 04 clue slot (alternative to the arrival); `lore-world.md` §3.8 says the L8 or L9 intro; the arrival skit already shows a parcel drop. This file follows the skits doc (04); if the arrival keeps its drop, swap 04's clue for another strength-2 beat. Owner: narrative-director.
- **Lighting mismatch.** `lore-world.md` §3.8 F (seven presets, "frozen blue" at L7, gaslight night at L6 and L8) and `visual-direction.md` (five stages) differ; this file follows visual-direction as instructed, with the stopwatch's cool tint kept as staging. Owner: art-director.
- **Finale beat wording.** The skits doc's "last clear" fits 10 because it is a Clear goal; an Escape height race was considered and rejected so the skit stays as written.
- **F1 recount.** "New to the player" is counted against the written biome files only (Meadow, Candy, Ice, Lava, Forest); Underwater and Cave are not written yet. Recount against the real path order (it can only lower the counts).
- **06 and B `solution` lists.** The validator should replay the known solutions above; in 06 the L may need mirroring (Flip), and in B the validator must replay through the turns (the target sets are 90°-symmetric, so any rotated placement of the same piece is valid).
- **10 busyness.** If belt + pistons + stopwatch is too much, slow the stopwatch (20 s) or drop the pistons, or swap one out with EV13 as in the Meadow.
- **Star times** are formula estimates (and hand-set where noted); replace with playtest medians.
