# Campaign Minigames ("Party Stops")

> **Status**: Designed (autonomous run, 2026-10-13); awaiting design review and playtest
> **Author**: game-designer
> **Extends**: `tournament-minigames.md` (MG1–MG15 contract), `party-minigames-wave2.md` (MG22–MG36), `arcade-pack.md`, `mode-minigame-randomizer.md`
> **Adds**: minigames MG37–MG50, and 22 campaign Party Stop stages (2 per biome)
> **Pillar note**: the falling block stays the star. Every concept below is played by dropping, rotating or sliding Piece Set shapes.

## Overview

Party minigames exist today only in tournaments. This system puts them into the campaign as **Party Stops**: two optional side stages per biome (22 in all). Each one is a minigame with a biome theme, played solo against 1–3 bots or against a score target, and rated 1–3 stars on the player's own metric. Party Stops branch off the main chain. They never gate it and are never harder than their neighbouring main levels. This GDD also adds 14 new minigames (MG37–MG50), drawn from party games and other block games. Every one is built mostly from existing rule ids (`assets/data/rules/*.json`), goal types and minigame templates. All five of the user's named concepts (Block Bridge Dash, Wobble Builders, Island Claim Battle, Speed Stack, Block Racers) are among them. New minigames also join the tournament pool through the existing minigame template contract.

## Player Fantasy

"A breather and a giggle between puzzles." After three or four careful main levels, the map shows a confetti-ringed tent. Inside, the wizard races the tiki across a lava gap, or the penguin curls a block across a frozen rink. The rules are clear within five seconds, a round lasts 60–150 seconds, and a bad run costs nothing. Each stop is a *preview* of party mode. The player learns the minigame alone, then recognises it in tournaments with friends.

- **MDA targets**: **Challenge** (primary, through quick mastery), **Fantasy** (biome flavour and mascot rivals), **Fellowship by proxy** (bots that taunt, send things and celebrate).
- **SDT**: *Competence* (short rounds, readable star bars, fast retry); *Autonomy* (optional stops, chosen freely); *Relatedness* (the biome mascots act as rivals).
- **Flow**: Party Stops are the **release** in the sawtooth curve. They come after the build-up of levels 1–3 and 5–7, before the biome's tension rises again.

## Detailed Design

### Research distillation (genre → Wacky Towers verb)

These lessons come from the designer's knowledge of the reference games, not from new web research. Live-ops data was not consulted.

| Reference | What works there | How we take it, block-first |
|---|---|---|
| Mario Party / Pummel Party | Rules understood in about 5 s; a shared arena; last place can swing it | One-sentence card; Sends to the leader (contract rule 9) |
| Tricky Towers | Physics wobble and the humour of near-collapse | Spring platform with a stability meter (MG38) |
| Tetris 99 / Tetris Effect | Sprint mode; attacks for clears; the "Zone" time freeze | Speed Stack (MG40); Zone Rush (MG50) |
| Fall Guys | Disappearing floor and races where everyone sees everyone | Last Block Standing (MG48); Block Racers (MG41) |
| Overcooked | Order tickets, a conveyor and time pressure | Order Up (MG45) |
| Puyo Puyo | Chain reactions as the big payoff | Chain Pop (MG43) |
| Bomberman | Cross-shaped blasts and area denial | Bomb Drop Arena (MG44) |
| Jenga | Pulling under tension | Already covered by MG33 Tower Pull (reused, not duplicated) |
| Monument Valley | Rotating the view changes what connects | Path Twist (MG47) |
| Curling / shuffleboard | One aimed slide and a rings payoff | Shell Slide (MG42) |
| Territory painting | A board you can read at a glance as "who is winning" | Island Claim Battle (MG39) |

### New minigames MG37–MG50

Standing kinds and hooks follow `tournament-minigames.md` rules 4–5 (S = Send, St = Steal, Sh = Shared). In the "Reuses" column, "Reuses" means existing rule ids, goals or templates. "New" lists the only new code each one needs.

| id | Name | Verb | Rule (one line) | t_mg | Standing / star metric | Reuses | New |
|---|---|---|---|---|---|---|---|
| MG37 | Block Bridge Dash | Span the gap | Drop pieces to bridge a chasm while lava rises; your mascot walks forward over any solid cells | 120 s | race_progress; star = finish time (s, lower is better) | MG6 walkway logic, `lava_rise`, `build_race`, `speed_bump` (Speed Boost pickup) | Walker that steps 1 cell when the next cell is solid |
| MG38 | Wobble Builders | Balance high | Stack on a spring platform; the platform tilts toward your centre of mass; reach the flag or be tallest at time-out | 90 s | height (cells); star = height | MG5 physics, `wobble`, `bounce_pad`, `height` goal | Stability meter UI and the F4 tilt model |
| MG39 | Island Claim Battle | Paint territory | Landed cubes paint the floor cells below them your colour; landing on a rival's cells flips them | 90 s | score (% of cells owned); star = % owned | `chameleon_paint`, `confetti_fill`, `fill_shape` cell scan | Ownership map (one byte per cell) |
| MG40 | Speed Stack | Sprint-clear | Clear N layers as fast as possible | 150 s cap | race_progress; star = time (s) | `clear_n` goal, `stopwatch` | None (template only) |
| MG41 | Block Racers | Pave and race | The board is a scrolling road (`conveyor`); each layer you clear boosts your kart; holes slow it | 120 s | race_progress; star = finish time | `conveyor`, `mill_belt`, `speed_bump`, `build_race` | Kart speed from F7 |
| MG42 | Shell Slide | Aim and slide | Flick one piece per throw across ice into target rings; it can knock rival pieces out | 6 throws | score; star = ring points | MG22 aim/spin, `ice_slide`, `snowball` (Send) | Ring scorer |
| MG43 | Chain Pop | Set off chains | Groups of 4 or more same-colour cubes pop; when cubes fall into new groups, the chain grows | 90 s | score; star = points | `colour_pop`, MG3 colours, `bubble` | Chain multiplier (F5) |
| MG44 | Bomb Drop Arena | Blast and dodge | Pieces carry fuse bombs that blast in a cross along the floor; keep your mascot's tile alive | 90 s | alive_time; star = seconds survived | `countdown_bomb`, `crumble_tiles`, `rock_obstacle`, MG28 dodge | Cross-blast pattern |
| MG45 | Order Up | Fill tickets | Tickets show small shapes; build the matching shape in a tray to cash the ticket before it expires | 120 s | score; star = tickets served | `fill_shape`, `shape` goal, `bake_stage`, `conveyor` (ticket rail) | Ticket queue |
| MG46 | Rainbow Tower | Climb to the flag | Build up through cloud bands to a flag; rainbow pieces bridge bands | 150 s | race_progress; star = finish time | `height` goal, `build_race`, `rainbow_piece`, `balloon` | None (template only) |
| MG47 | Path Twist | Connect by rotating | Rotate the turntable board so that your drops complete a walkway from the start pad to the door | 120 s | score (puzzles solved); star = puzzles | `turntable`, `flip`, `mirror`, MG29 puzzle flow | Path connectivity check (grid flood fill) |
| MG48 | Last Block Standing | Patch the floor | Floor tiles crumble under the mascots; drop pieces to patch the floor under yours | 90 s | alive_time; star = seconds survived | `crumble_tiles`, `thin_ice`, `quicksand`, MG13 melt | None (template only) |
| MG49 | Candy Clash | Bonk and collect | Shared arena: pieces you land release coins nearby, and landing next to a rival mascot bonks it (it drops 1 coin) | 90 s | score; star = coins | `star_coins`, `gumdrop_hail`, `mascot_paw`, `bonk_boss` hit logic | None (template only) |
| MG50 | Zone Rush | Freeze and stack | Clears fill a Zone meter; tap to freeze gravity, stack clears, and score them all at the end as a mega-clear | 90 s | score; star = points | `fever_rush`, `stopwatch`, `golden_row` | Deferred clear tally (F6) |

**Tournament use.** Each MG37–MG50 template also carries the full minigame contract: `standing_metric`, `interaction_hook`, `item_whitelist` and an optional twist. That puts them in the Randomizer pool automatically. For Party Stops, the hook is played by bots (rule 6 below).

**Gap noted.** MG16–MG21 exist in code (`rules_a.gd`, `rules_b.gd`) but have no design table in any GDD. They are left out of placement until they are documented.

### Party Stop rules

1. **Map placement.** Each biome has two Party Stop nodes, `P1` and `P2`, branching off the chain. `P1` unlocks when `<biome>_03` is cleared and `P2` when `<biome>_07` is cleared. Neither stop unlocks anything on the main chain, the bonus or the hard tracks.
2. **Data.** Each Party Stop is a Level Data file at `src/levels/<biome>/<biome>_party_<n>/<biome>_party_<n>.json` with an extra block:
   - `"minigame": { "id", "theme_rules": [...], "bots": n, "bot_skill", "metric", "metric_dir": "higher"|"lower", "stars": {"t1","t2","t3"}, "t_mg_ms" }`
   - Catalog entries gain `"party_stop": true` and `"after": "<level_id>"`.
   - The schema is documented here and in `level-data-definition.md` (see Dependencies).
3. **Board.** The minimum is 8×8, as for every board. Race and arena stages may be wider (lanes or a shared arena). Size comes from the template, never from code.
4. **Pieces.** The piece order is random for each attempt (F1 seed). The player and all bots share that attempt's `round_seed`, so the challenge is identical for everyone. Sends change only the target's own copy (contract rule 3).
5. **Opponents.** There are two kinds:
   - **Bot stages**: 1–3 bots, each a biome mascot or a cast member (wizard, penguin, alien, tiki).
   - **Target stages**: the player plays against a ghost bar showing the 3-star target.
6. **Bots** play the same template with a skill value from F2. They use the template's Send or Steal hook at the player on the same charge rules (F3), scaled by `bot_send_scale`. Bots cannot use items.
7. **Stars.** Stars come only from the player's own metric, compared against `t1/t2/t3` (F8). Finishing place against bots is shown and celebrated but **never decides stars**, so bot luck cannot cost a star.
   - **Race stages** (lower-is-better time) give 0 stars if the player does not finish within `t_mg`.
   - **Alive-time stages** end at `t_mg` and score the full duration.
8. **No-gate guarantee.** Party Stop stars go into the biome's star total as **bonus stars**. Every star-count gate (biome unlocks, hard track unlocks) must be reachable with zero Party Stop stars (Acceptance Criterion 3).
9. **Difficulty cap.** A stop's `difficulty` must be ≤ that of the main level just before it (F2, `stop_tier = tier(after)`). Its 1-star threshold targets a ≥ 90% first-session completion rate (F8, `k1`).
10. **Retry and fail.** Retry is instant with a new attempt seed. There are no lives, energy or cost. Fail states follow the template (for example, mascot falls in MG37 or MG48).
11. **Items and twists.** Items are off. The theme comes from `theme_rules` (at most 2 rule ids, each from the template's compatible list). These count against the contract's 1-twist cap as "theme", not "twist", and are listed in the table below.
12. **Tutorial.** On the first visit, a single 3-second animated card shows the verb. Rounds open with no other tutorial.

### Placement: the 22 Party Stops

`P1` comes after level 03 (main tier 3); `P2` comes after level 07 (main tier 7). Thresholds are listed as t1 / t2 / t3. All values are **initial estimates** from F8 with assumed medians; nothing has been playtested yet.

| Biome | Slot (after) | MG | Stage name / theme twist | Opp. | Star metric | t1 / t2 / t3 |
|---|---|---|---|---|---|---|
| Meadow | P1 (meadow_03) | MG40 Speed Stack | Hay Bale Sprint: clear 6 layers, gentle `fall.g0` | target | time s (lower) | 150 / 100 / 70 |
| Meadow | P2 (meadow_07) | MG38 Wobble Builders | Dandelion Springs: `dandelion_puff` drifts | 1 bot | height cells | 8 / 12 / 16 |
| Candy | P1 (candy_03) | MG45 Order Up | Cake Counter: tickets are cake tiers, `bake_stage` | target | tickets | 3 / 5 / 7 |
| Candy | P2 (candy_07) | MG49 Candy Clash | Gumdrop Brawl: `gumdrop_hail` spills coins | 2 bots | coins | 10 / 18 / 26 |
| Ice | P1 (ice_03) | MG42 Shell Slide | Penguin Curling: `ice_slide` rink, 6 throws | 1 bot | ring points | 30 / 50 / 70 |
| Ice | P2 (ice_07) | MG1 Hole in the Wall | Glacier Gates: ice walls, `snowball` send | 1 bot | walls passed | 6 / 9 / 12 |
| Underwater | P1 (underwater_03) | MG43 Chain Pop | Bubble Chains: `bubble` lifts popped groups | target | points | 1 500 / 3 000 / 4 500 |
| Underwater | P2 (underwater_07) | MG41 Block Racers | Current Racers: the road is a sea current, `crab_claw` send | 3 bots | finish time s (lower) | 120 / 95 / 75 |
| Lava | P1 (lava_03) | MG37 Block Bridge Dash | Magma Gap: `lava_rise`, Speed Boost pickup | 1 bot | finish time s (lower) | 110 / 90 / 70 |
| Lava | P2 (lava_07) | MG13 Floor Is Lava | Ember Melt: `ember` sparks | 2 bots | alive s (of 150) | 60 / 100 / 140 |
| Forest | P1 (forest_03) | MG33 Tower Pull | Woodpile Pull: `woodpecker_knock` jolts | target | pulls | 6 / 10 / 14 |
| Forest | P2 (forest_07) | MG48 Last Block Standing | Stump Stand: `crumble_tiles` + `vines` | 3 bots | alive s (of 90) | 40 / 65 / 90 |
| Cave | P1 (cave_03) | MG36 Treasure Dig | Gem Hunt: `mud`, crystal glints | target | gems | 3 / 5 / 7 |
| Cave | P2 (cave_07) | MG44 Bomb Drop Arena | Mine Blast: `countdown_bomb` + `rock_obstacle` | 2 bots | alive s (of 90) | 40 / 65 / 90 |
| Clockwork | P1 (clockwork_03) | MG47 Path Twist | Gear Path: `turntable` + `rusty_hinge` | target | puzzles | 2 / 3 / 4 |
| Clockwork | P2 (clockwork_07) | MG4 Perfect Stack | Piston Stack: `piston_punch` nudges | 1 bot | height slabs | 6 / 9 / 12 |
| Neon | P1 (neon_03) | MG50 Zone Rush | Laser Zone: `fever_rush` beat-synced | target | points | 4 000 / 7 000 / 10 000 |
| Neon | P2 (neon_07) | MG32 Whack-a-Block | Arcade Whack: `decoy_bombs` | 2 bots | points | 20 / 32 / 44 |
| Celestial | P1 (celestial_03) | MG46 Rainbow Tower | Rainbow Climb: `rainbow_piece` + `balloon` | 1 bot | finish time s (lower) | 140 / 110 / 85 |
| Celestial | P2 (celestial_07) | MG10 Shadow Duel | Constellation Match: star silhouettes | 1 bot | puzzles | 3 / 5 / 7 |
| Carnival | P1 (carnival_03) | MG35 Plinko Drop | Prize Plinko: Tumble Fair jackpot | 2 bots | points | 300 / 550 / 800 |
| Carnival | P2 (carnival_07) | MG39 Island Claim Battle | Fairground Claim: `confetti_fill` flips | 3 bots | % owned | 30 / 40 / 50 |

Coverage: all 14 new minigames are used once each, plus 8 existing ones (MG1, 4, 10, 13, 32, 33, 35, 36). Stops alternate between target stages and bot stages so the player also gets quiet stops. Bot count grows across the campaign (1 → 3) as the player's skill grows.

## Formulas

**F1 — Attempt seed (fairness).**
`attempt_seed = hash(stage_id, profile_attempt_counter)`; `round_seed = attempt_seed`. The player and all bots draw pieces from `round_seed`, and bot decisions come from `hash(round_seed, bot_index)`. Sends use `attack_rng` (contract). `profile_attempt_counter` goes up by 1 on every start, so retries are always different.

**F2 — Bot skill.**
`bot_skill = clamp(b0 + b_tier · (stop_tier − 1) + b_biome · biome_index, 0, b_max)`
- `stop_tier`: 3 (P1) or 7 (P2). `biome_index`: 0 (meadow) to 10 (carnival).
- Defaults: `b0` = 0.25, `b_tier` = 0.05, `b_biome` = 0.02, `b_max` = 0.80.
- Examples: Meadow P2 → 0.25 + 0.30 + 0 = **0.55**; Carnival P2 → 0.25 + 0.30 + 0.20 = 0.75; Ice P1 → 0.25 + 0.10 + 0.04 = **0.39**.
- `bot_skill` scales bot reaction delay (`lerp(1 200, 350, skill)` ms) and placement error (`lerp(1.5, 0.2, skill)` cells).

**F3 — Bot Sends.**
Bots charge with the contract's F1, then multiply the effect by `bot_send_scale` (default 0.75, range 0.5–1.0). A bot never Sends within `bot_send_grace_ms` (default 10 000) of round start.

**F4 — Wobble stability (MG38).**
`S = clamp(1 − |x_com − x_base| / (w_base / 2), 0, 1)`
- `x_com` = the horizontal centre of mass of the stack; `w_base` = the platform width in cells.
- Platform tilt = `tilt_max · (1 − S) · sign(x_com − x_base)`, with `tilt_max` = 12°.
- The tower topples when `S < s_fail` (0.15) for longer than `t_grace` (1.5 s). Height then resets to the last stable height minus `topple_penalty` (2) cells.
- Example: on an 8-cell base with the COM 3 cells off-centre, S = 1 − 3/4 = 0.25 → amber meter, tilt 9°.

**F5 — Chain multiplier (MG43).** `points = Σ_k cubes_k · base_pop · chain_mult^(k−1)`, with `base_pop` = 10 and `chain_mult` = 2.0, capped at chain 6. Example: 4, then 5, then 4 cubes → 40 + 100 + 160 = 300.

**F6 — Zone tally (MG50).** `points = zone_layers² · zone_base`, with `zone_base` = 100. Example: 6 layers → 3 600. The meter fills by `1 / zone_fill_clears` (default 8) per clear.

**F7 — Kart speed (MG41).** `v = v_base · (1 + boost · clears_recent) · (1 − hole_drag · hole_frac)`
- `clears_recent` = layer clears in the last 5 s; `hole_frac` = the share of empty cells in the kart's row.
- Defaults: `v_base` = 1.0 track-unit/s, `boost` = 0.35, `hole_drag` = 0.6. The minimum `v` is 0.25.

**F8 — Star thresholds.**
- Higher-is-better metrics: `t_i = round(m_med · k_i)`, with `k1` = 0.6, `k2` = 1.0, `k3` = 1.35.
- Lower-is-better times: `t_i = round(m_med / k_i)`, and `t1` is capped at `t_mg`.
- `m_med` is the median first-session result. Until playtest data exists, it is the designer's estimate in the table above.
- Required ordering: `t1 < t2 < t3` (higher is better) or `t1 > t2 > t3` (lower is better).
- Example: Speed Stack with an estimated median of 100 s → 167 / 100 / 74, then t1 is capped at 150 → **150 / 100 / 74**, rounded to 70 in the table.

## Edge Cases

- **Race not finished at `t_mg`.** The player gets 0 stars. The result screen shows how far they got as a percentage, and Retry is offered.
- **Alive stage, player survives to `t_mg`.** Their metric is the full `t_mg`, which meets t3 when t3 = `t_mg` (Forest P2, Cave P2). This is intended: surviving the whole round is the 3-star feat.
- **All bots are eliminated early** (MG44, MG48). The round continues alone until the player's fail or `t_mg`, because stars come from the player's time and not their placement.
- **Player eliminated while bots remain.** The round ends at once for the player (no spectator wait); the stars are computed and the bots' placings are simulated to the end, out of view.
- **Tie between the player and a bot.** Tied places are shared. This has no effect on stars.
- **Unlucky seed** (for example, no flat pieces for Bridge Dash). The Piece Set bag already guarantees shape variety. The `t1` margin (k1 = 0.6) absorbs bad draws, and Retry rerolls the seed.
- **Degenerate stalling.**
  - In alive-time stages, doing nothing still loses: tiles crumble and bombs spawn on a timer, not in response to player actions.
  - In MG39, waiting does not help because your cells can be flipped. Tie-breaks for equal % go to the player with fewer flipped-away cells.
- **Degenerate spamming** in MG49 (dropping at once to bonk). Bonks need the piece to land within 1 cell of a rival mascot. Bonks have a `bonk_cooldown_ms` (default 2 000) for each victim.
- **Turtling in MG38** (building low and wide). This is legitimate, but height is the metric, so a wide tower gives up stars. It is a healthy trade-off, not dominant.
- **MG42 knock-out loops.** Six throws for each side are fixed, so a round cannot go on forever.
- **App suspended mid-round** (phone). The round pauses automatically. On resume there is a 3-second countdown. Seeds are unchanged.
- **Theme rule incompatible with the template.** Load-time validation rejects the stage (Acceptance Criterion 6). The validator never strips the rule silently.
- **`t1 == t2` after rounding.** The validator rejects it. Thresholds must be strictly ordered (F8).
- **A stop unlocked before its biome** (save migration). Unlocks are recomputed from cleared levels on load. A stop whose `after` level is not cleared is hidden.

## Dependencies

| System / doc | Direction | Contract |
|---|---|---|
| `tournament-minigames.md` (minigame contract) | requires | Template slots, standing, hooks, telegraph; MG37–MG50 obey rules 1–13 |
| `party-minigames-wave2.md`, `src/game/minigames/` | requires | `rules_script` model, `s.rng` / `s.attack_rng`, `s.add_score`, `s.progress`, `charge_send` |
| `mode-minigame-randomizer.md` | provides to | MG37–MG50 join the pool; Randomizer rule 7 round seed |
| Level Data (`level-data-definition.md`) | requires / extends | New optional `minigame` block and the `party_stop` / `after` catalog fields; that doc must add them |
| Campaign Structure / map (`assets/data/campaign/catalog.json`) | extends | Side nodes; star gates must exclude bonus stars (rule 8) |
| Rule-twist framework (`assets/data/rules/*.json`) | requires | Theme rules listed in the placement table; compatibility lists per template |
| Level Goals (`clear_n`, `height`, `shape`, `bonk_boss`) | requires | Reused as `goal_evaluator`s |
| Piece Spawner | requires | A shared `round_seed` for the player and bots |
| Bot / AI player | **new** | Plays any template given `bot_skill` (F2); lead-programmer to scope |
| HUD | requires | Stability meter (MG38), ownership bar (MG39), star bar with t1–t3 ticks |
| Narrative (narrative-director) | provides intent | Stage names are working titles; final names and mascot lines are theirs |

Each linked doc must add a back-reference to this GDD. That is flagged for the producer, because this run edited only this file.

## Tuning Knobs

All values live in `assets/data/campaign/party_stops.json` (globals) and in each stop's level JSON (`minigame` block). Nothing is hardcoded.

| Knob | Category | Default | Safe range | Effect / rationale |
|---|---|---|---|---|
| `unlock_after_p1` / `p2` | Gate | 03 / 07 | 02–05 / 06–09 | Places the stops at the sawtooth release points |
| `bot_skill` b0 / b_tier / b_biome / b_max | Curve | 0.25 / 0.05 / 0.02 / 0.80 | 0.1–0.4 / 0–0.08 / 0–0.03 / 0.6–0.9 | Opponent pressure grows with tier; capped so bots never feel perfect |
| `bot_send_scale` | Curve | 0.75 | 0.5–1.0 | Solo play is gentler than human versus |
| `bot_send_grace_ms` | Feel | 10 000 | 5 000–20 000 | Lets the player learn before being attacked |
| `k1` / `k2` / `k3` | Curve | 0.6 / 1.0 / 1.35 | 0.5–0.8 / 0.9–1.1 / 1.2–1.6 | 1★ reachable by about 90%; 3★ is mastery |
| `t_mg_ms` per stop | Gate | per table | 45 000–150 000 | Keeps rounds short for phone sessions |
| `tilt_max`, `s_fail`, `t_grace`, `topple_penalty` (MG38) | Feel | 12°, 0.15, 1.5 s, 2 | 6–18°, 0.05–0.3, 0.5–3 s, 0–4 | Wobble drama vs fairness |
| `base_pop`, `chain_mult`, chain cap (MG43) | Curve | 10, 2.0, 6 | 5–20, 1.5–3, 4–8 | Payoff of chains |
| `zone_base`, `zone_fill_clears` (MG50) | Curve | 100, 8 | 50–200, 5–12 | Zone frequency and payoff |
| `v_base`, `boost`, `hole_drag` (MG41) | Feel | 1.0, 0.35, 0.6 | 0.5–1.5, 0.2–0.6, 0.3–0.9 | Racing feel; reward for clean rows |
| `bonk_cooldown_ms` (MG49) | Feel | 2 000 | 1 000–4 000 | Anti-spam |
| `walker_step_ms` (MG37) | Feel | 600 | 400–900 | Pace of the mascot across the bridge |
| Star thresholds per stop | Curve | table | F8 ordering | Re-derive from playtest medians |

## Acceptance Criteria

**Functional (automated, `tests/unit/campaign_minigames/`, `tests/integration/campaign_minigames/`):**

1. [U] GIVEN the same `round_seed`, THEN the player and every bot receive the identical piece sequence. Two retries give different sequences.
2. [U] F2 gives 0.55 for Meadow P2 and 0.39 for Ice P1. No stop exceeds `b_max`.
3. [I] GIVEN a save with every main level cleared at 3★ and zero Party Stop stars, THEN every biome, bonus and hard-track gate is unlocked.
4. [U] Stars use only the player's metric. A run with a fixed metric yields the same stars whether the player places 1st or last.
5. [U] A race stage not finished by `t_mg` yields 0 stars. An alive stage survived to `t_mg` yields its t3 when t3 = `t_mg`.
6. [U] The level-data validator rejects: unordered thresholds; a `theme_rules` id not compatible with the template; a board smaller than 8×8; a `difficulty` greater than the preceding main level's.
7. [U] F4–F7 match the worked examples (S = 0.25; 300 chain points; 3 600 zone points; minimum kart speed 0.25).
8. [I] All 22 stop JSONs load, have `party_stop: true` and a valid `after`, and the catalog lists exactly 2 per biome.
9. [I] MG37–MG50 appear in the Randomizer pool and pass the minigame contract checks (hook present, `t_mg` 30–240 s).
10. Every player-observable stop has a retained screenshot in `production/qa/evidence/` (run-and-observe rule).

**Experiential (playtest, at least 6 players, phone):**

11. At least 90% earn 1★ on their first or second attempt at each stop; 25% or fewer earn 3★ in their first session.
12. Players can state the rule within 10 s of the round starting (verbal probe) for at least 80% of the stops.
13. Median round length is 60–150 s, and median retries per 3★ chase are 5 or fewer.
14. In the post-session survey, at least 70% rate Party Stops a welcome break, and fewer than 10% report a bot as "unfair".
15. Using MG38 Wobble Builders as the representative, at least 4 of 6 testers laugh or react aloud at a near-topple (observer tally).
