# Tournament Minigames

> **Status**: In Design
> **Author**: Tessa + agents (game-designer)
> **Last Updated**: 2026-10-09
> **Implements Pillar**: Variation Over Depth; Comeback Energy; The Block Is the Constant; Readable Chaos

## Summary

Fifteen short party rounds (1–3 minutes) that join the tournament Randomizer pool next to the versus modes. Each one changes the **verb** (fit, copy, match, time, catch, sort, survive), keeps the **blocks** as the star, and has at least one way to mess with your rivals, Mario Party style. Every player plays on their own phone.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Mode / Minigame Randomizer, Items, Buffs & Debuffs, Local Multiplayer Setup, Piece Set`

## Overview

Versus modes (Clear, Build, Shape, Survival races) are "normal Wacky Towers, faster". Minigames are the party spice: each one asks for a different skill with the same Piece Set shapes. Some skip grid placement entirely, which is allowed as long as the blocks are the star (user decision 2026-10-09). Every minigame follows one **contract**. It is a round template (tagged `minigame`) that declares the strategy slots it uses, a `goal_evaluator`, a `standing_metric`, an **interaction hook** and a length. Interactions travel as Local Multiplayer events and always land with a telegraph, so a 100–250 ms LAN delay is hidden and nobody is hit "out of nowhere". Interaction power scales toward trailing players (F1). Players knocked out of a survival minigame become **ghosts** who can still sabotage. This serves *Variation Over Depth* (15 verbs), *Comeback Energy* (all sabotage favours the trailing player), *The Block Is the Constant* (every minigame is about the Piece Set shapes) and *Readable Chaos* (one verb per minigame, explained on one card). All values are starting defaults.

## Player Fantasy

"Wait, what are we playing now?!" Then, five seconds later: "Oh, I get it." Each minigame should feel like a fresh party game you understood instantly. You laugh at your friend across the couch when your gift lands on their board, and the person in last place always has a button to press that could swing it. Target MDA aesthetics: **Fellowship** (primary), **Challenge**, **Discovery**.

## Detailed Design

### Core Rules: the minigame contract

1. **Template.** A minigame is a Level Data round template tagged `minigame`. It has:
   - `minigame_id`, an icon, a two-word name, and a one-sentence rule shown on the Randomizer card
   - its strategy slots (`board_kind`, `spawn_entry`, `clear_detector`, `collapse`, `top_out_check`, `goal_evaluator`; `none` where unused)
   - `t_mg` (60–180 s), `standing_metric`, `interaction_hook`, and an `item_whitelist`
2. **Blocks are the star.** Every minigame's main object is a Piece Set shape. Grid placement is optional.
3. **Shared randomness.** Pieces, walls, models and spawn lanes come from the round seed (Randomizer rule 7), so every player gets the same challenge sequence. Sends and steals change only the target's own copy.
4. **Standing.** Each minigame declares a `standing_metric`. It is used for:
   - item and send scaling (F1)
   - the opponent mini-boards
   - targeting
   - the time-cap winner (Tournament Flow rule 4)

   Kinds: `race_progress` (0–1 toward the goal), `score`, `height`, or `alive_time`. This is the "standing varies per minigame" decision from 2026-10-09.
5. **Interaction hook (required).** Every minigame has at least one of these:
   - **Send**: your action puts something on a rival's board or queue
   - **Steal**: you take score or progress from a rival
   - **Shared**: one contested object or moment for all players
   - **Item**: the standard item slots, with a minigame-specific item trigger
6. **Targeting.** By default a Send or Steal targets the **leader**. If you are the leader, it targets 2nd place (Items rule 8). A minigame may allow **tap-to-pick** (tap a rival's mini-board within `pick_window_ms`, default 1 500; otherwise auto). Players who are out are never targeted, except ghost-on-ghost, which is off.
7. **Telegraph.** Every Send or Steal shows on the target's screen `attack_warn_ms` (default 1 000) before it acts: the sender's colour frame, an icon, and a landing marker. The sender sees a "sent!" pop.
8. **Network.** Sends are Local Multiplayer events (rule 4), applied on arrival and never rolled back. Effects that last are implemented as Buffs & Debuffs effects (new effect ids, layer 2 parameter sets), so they get badges, timers and stacking rules for free.
9. **Comeback.** The charge needed for a Send scales with standing (F1). With 3–4 players, the leader's Sends are weaker (`leader_send_scale`, default 0.5 of duration or amount).
10. **Ghosts.** In minigames with elimination, a player who is out becomes a **ghost**. Every `ghost_send_ms` (default 15 000) they may fire that minigame's Send at the leader. Ghosts cannot win the round but keep tournament standing.
11. **Items.** Items are on only if the template allows them. A minigame without clears declares its own `item_trigger`, and only items in its `item_whitelist` can be rolled.
12. **Twists.** No twists by default (Randomizer F2 does not apply). A template may opt in to at most 1 compatible twist.
13. **Length and winner.** The round ends at the goal or at `t_mg`, whichever comes first. The winner is decided by the `goal_evaluator`. At `t_mg` the best standing wins; ties are shared (Tournament Flow rule 3).

### The 15 minigames

The interaction hook types are S = Send, St = Steal, Sh = Shared, I = Item.

| # | Minigame | Verb | t_mg | Standing | Hook | Cost | Diff |
|---|---|---|---|---|---|---|---|
| MG1 | Hole in the Wall | Rotate to fit | 90 s | score (walls passed) | S: Tight Wall | M | 5 |
| MG2 | Copycat | Remember and rebuild | 150 s | score | S: Smudge | M | 4 |
| MG3 | Colour Rush | Match colours | 90 s | score | S: Grey Garbage | M | 4 |
| MG4 | Perfect Stack | Time the drop | 60 s | height | St: Steal a Slab | S | 4 |
| MG5 | Crane Tower | Release a swinging piece (physics) | 120 s | race_progress | S: Gust | M | 4 |
| MG6 | Mascot Bridge Race | Build a walkway | 150 s | race_progress | S: Bird | M | 5 |
| MG7 | Box Packers | Pack with no holes | 120 s | race_progress (fill %) | S: Awkward Piece | M | 4 |
| MG8 | Gift Exchange | Choose what to send | 150 s | race_progress (layers) | S: Gifts (core verb) | M | 4 |
| MG9 | Speed Sort | Sort by colour | 60 s | score | Sh+St: Golden Piece | S | 5 |
| MG10 | Shadow Duel | Match silhouettes | 150 s | score (puzzles) | S: Flicker | M | 5 |
| MG11 | Memory Tower | Build from memory | 120 s | height | I: height ribbons | S | 3 |
| MG12 | Spin Cycle | Clear on a turntable | 120 s | score | S: Extra Spin + I | S | 3 |
| MG13 | Floor Is Lava | Outbuild the melt | 150 s | alive_time, then height | S: Pump | S | 4 |
| MG14 | Hot Block | Get rid of the bomb | 150 s | race_progress (layers) | Sh: the Hot Block | M | 5 |
| MG15 | Catch Tower | Move the tray to catch | 75 s | height | S: Slippery Tray | M | 5 |

**MG1. Hole in the Wall**
- **Slots**: `board_kind = grid` (a 4 × 4 × 4 frame, no stack), `goal_evaluator = score_timer`.
- **Setup**: one piece floats in the frame. Every `wall_interval` (6 s, ramping to 3 s) a wall slides toward it.
- **Walls**: each wall's hole is the projection of the **current piece** in a hidden random orientation, plus `hole_slack` extra cells (2, falling to 0 over the round). The hole is therefore always passable.
- **Pass**: you pass if the piece's projection along the wall axis fits inside the hole (F3): +1. A projection that fills the hole exactly is a Perfect: +2.
- **Fail**: the piece is bonked back and you are stunned for 1 s.
- **Send (Tight Wall)**: every `tight_charge` passes in a row (3, scaled by F1) sends a Tight Wall to the target. Their next wall has slack 0 and arrives 1 s sooner, with a red rim as the telegraph.

**MG2. Copycat**
- **Slots**: `board_kind = grid` (a 4 × 4 pad, H 4), `goal_evaluator = score_timer`.
- **Models**: a model of 2–4 pieces (6–14 cubes) is shown for `show_ms` (5 000), then hidden. You get exactly the pieces that made it, in a seeded order, and rebuild it.
- **Scoring**: after the last piece locks, score = `100 × accuracy` (F4) + `speed_bonus` (up to 50, falling linearly over 30 s). The next model follows.
- **Send (Smudge)**: finishing a model before the target sends a Smudge. Their next model's `show_ms` drops by 1 500 (minimum 2 000).

**MG3. Colour Rush**
- **Slots**: M5 Colour Pop rules on a 5 × 5 board (`clear_detector = colour_connect`, `collapse = cascade`, `colour_count` 4); `top_out_check = trim`; `goal_evaluator = score_timer`.
- **Send (Grey Garbage)**: every pop chain of k ≥ 2 sends `k − 1` grey cubes (no colour key) to the target. They drop on random top-surface cells, marked one lock ahead. A grey cube is removed when a pop happens face-adjacent to it (Puyo nuisance rule).

**MG4. Perfect Stack**
- **Slots**: `spawn_entry = slide_in` (M10, `slide_gates = alternate`, speed ramping 2 → 4 cells/s), Stack Trim (cubes not resting on a cube directly below them pop off after the lock), 4 × 4 footprint, `top_out_check = trim`, `goal_evaluator = height_timer`.
- **Controls**: no rotation; tap to release.
- **Steal (Steal a Slab)**: 3 Perfects in a row (no cube trimmed) steal the target's top layer. It pops off their tower and a full 4 × 4 slab is added to yours. If you are the leader, your streak gives you a one-hit **Shield** instead.

**MG5. Crane Tower**
- **Slots**: `board_kind = physics` (Physics Mode Tower Race core), `spawn_entry = crane`, `goal_evaluator = height_race` (line at 8), drops allowed 3.
- **Crane**: the piece hangs from a crane that swings along x with `swing_period` (2.4 s). You may spin it, then tap to release, and it falls under physics.
- **Win**: like Tricky Towers, the tower must stay above the line for 3 s.
- **Send (Gust)**: each height ribbon you pass (every 2 cells) sends a Gust. The target's crane swings 30% faster for 8 s.

**MG6. Mascot Bridge Race**
- **Slots**: `board_kind = grid` (an 8 × 3 strip with cliffs at both ends and a 6-cell gap), normal fall and lock, `goal_evaluator = path`.
- **Mascot**: your mascot walks automatically along any path of top-surface cells with steps of ≤ 1 cell. The first mascot to reach the far flag wins. Standing = the mascot's distance.
- **Send (Bird)**: a Bird charges every 25 s (scaled by F1); tap to send it. It removes the **top cube of the leader's walkway** at a telegraphed cell (a 1 500 ms shadow). It never removes a cube under their mascot.

**MG7. Box Packers**
- **Slots**: `board_kind = grid` (a box 4 × 4 × 3 = 48 cells), `clear_detector = none`, hold on, `top_out_check = trim` (anything above the box rim pops off), `goal_evaluator = fill_race` (100% filled, or best % at `t_mg`).
- **Send (Awkward Piece)**: each box layer you fill completely sends an Awkward Piece (a random Hollow or Party family shape) to the **front** of the target's queue, shown in their preview with a red bow.

**MG8. Gift Exchange**
- **Slots**: base rules on 5 × 5, `goal_evaluator = clear_race` (N = 4 layers).
- **Gifts**: after each lock you choose 1 of 2 offered **gifts**, and it goes into a rival's queue after a 1-piece delay, marked with a bow. Targeting is tap-to-pick, else auto.
  - Gifts are drawn from `gift_pool`: Hollow, Party, the larger Pento 3D shapes, and Giant up to 9 cubes.
  - Trailing players are offered the nastier half of the pool; the leader the milder half (F1 bias).
- **Cap**: a queue holds at most `gift_cap` (2) pending gifts. Extra gifts bounce back as nothing.
- Gifts are this minigame's core verb, so it has no other items.

**MG9. Speed Sort**
- **Slots**: `board_kind = none` (a chute), `goal_evaluator = score_timer`.
- **Sorting**: pieces drop down the chute one at a time. Swipe left, down or right to put each into one of 3 bins labelled with the round's 3 colour keys. Correct: +1, with a streak bonus. Wrong: the chute jams for 1 s. The speed ramps up.
- **Shared + Steal (Golden Piece)**: every ~10 s (seeded, so everyone gets it at the same moment) a Golden Piece drops for all players. The first player to sort it correctly (host-received time) steals 3 points from the leader. If the leader wins it, they get +3 with no steal.

**MG10. Shadow Duel**
- **Slots**: `board_kind = grid` (a 4 × 4 pad, H 4), `goal_evaluator = puzzle_race` (3 puzzles).
- **Puzzles**: two silhouettes (front and side, 4 × 4 each) are shown on panels. Build so your stack's projections match both exactly (F5). Extra cubes outside a silhouette count as errors.
- **Scoring**: the first to match takes the puzzle; everyone moves to the next.
- **Send (Flicker)**: each puzzle you win sends a Flicker. The target's silhouette panels go dark for 3 s.

**MG11. Memory Tower**
- **Slots**: Build Race (M1 rules, `topout_rule = trim`) on 5 × 5 with H 6, plus the Invisible Blocks twist (`visible_ms` 2 000).
- **Item**: `item_trigger` = each height ribbon reached. `item_whitelist` = Fog, Speed Up, Spin Lock, Slow Time, Preview Peek. Junk Rain is excluded because it would raise the target's tower.

**MG12. Spin Cycle**
- **Slots**: base layer clears on 5 × 5. The Turntable (catalog B1) turns the stack 90° every 3 locks, telegraphed by a ring countdown. `goal_evaluator = score_timer`. Standard items on.
- **Send (Extra Spin)**: each clear of ≥ 2 layers at once sends an Extra Spin. The target's turntable turns immediately, after the 1 s telegraph, during their next Resolving.

**MG13. Floor Is Lava**
- **Slots**: base rules on 4 × 4, clears off, `goal_evaluator = last_standing`.
- **Lava**: lava rises 1 layer every `lava_ms` (F6: 12 s, shrinking to 7 s). Cubes in a lava layer melt.
- **Safe layers**: a layer is **safe** when it is above the lava and at least `lava_cover` of it is filled (default 0.5, the same idea as Level Goals' `height_coverage`). This stops a degenerate 1 × 1 pole.
- **Mascot**: your mascot stands on your highest safe layer. You are out when you have no safe layer for 2 s.
- **Winner**: last standing. At `t_mg`, the most safe layers wins.
- **Send (Pump)**: every 4 locks fill a Pump. Tap it to make the target's next lava rise come 4 s early (the lava glows as the telegraph).
- **Ghosts**: ghosts may Pump on their own timer (rule 10).

**MG14. Hot Block**
- **Slots**: base rules on 5 × 5, `goal_evaluator = clear_race` (N = 5).
- **The Hot Block**: one Hot Block exists per round: a 2 × 2 × 2 Chunky cube with a fuse of `fuse_ms` (20 000).
  - It starts in the leader's queue front; in round 1, it goes to a random player.
  - Once placed, clearing any layer it is in **passes it on**: it leaves your board and enters the target's queue front, marked with a smoking preview.
  - If the fuse runs out on your board, it explodes and pushes `blast_junk` (2) junk layers under your stack. It then re-spawns in the leader's queue.
- It is the shared hot potato, so it is the whole interaction: no items.

**MG15. Catch Tower**
- **Slots**: `board_kind = grid`. Your board is a 3 × 3 **tray** that you slide along x and z (swipe; one cell per swipe), with Stack Trim. `spawn_entry = sky_lanes`: pieces fall fast (×3 g) in seeded random lanes over a 7 × 7 area, with a floor shadow 1 s ahead. `goal_evaluator = height_timer`.
- **Catching**: a piece that lands on the tray or the stack locks. A missed piece is lost, with no penalty except time.
- **Send (Slippery Tray)**: every 5 catches (scaled by F1) sends a Slippery Tray. For 6 s each of the target's swipes moves the tray 2 cells.

### States and Transitions

Per round: **Intro card** (the rule sentence, 3 s; `pick_window` uses the same card style) → **Countdown** (3 s) → **Playing** → **Finished**. A player who is out in Playing becomes a **Ghost** (MG13; any `last_standing` minigame).

Per interaction: **Charging → Ready → Sent → Telegraphed on target** (`attack_warn_ms`) **→ Applied → (Expired)**.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Mode / Minigame Randomizer | ↔ | Minigame templates join the pool; the round seed |
| Tournament Flow | → Minigames | Round start and time cap; results back as a round winner |
| Level Data & Definition | → Minigames | Template fields (rule 1) |
| Local Multiplayer Setup | ↔ | Send, Steal and Shared events; host-received time decides the Golden Piece and Hot Block passes |
| Buffs & Debuffs | Minigames → | New effect ids for lasting sends (Tight Wall, Smudge, Gust, Flicker, Slippery Tray, Shield) |
| Items | ↔ | Item trigger and whitelist per minigame |
| Piece Set, Spawner | → Minigames | Shapes, families (colour keys), seeded sequences |
| Level-Specific Mechanics | → Minigames | M1 (MG11), M5 (MG3), M10 (MG4) rules |
| Physics Mode | → Minigames | Core for MG5 |
| Twist Library | → Minigames | Invisible Blocks (MG11) |
| Level Goals & Fail States | → Minigames | `topout_rule = trim`; `last_standing` |
| HUD, Game Feel & VFX, Audio | Minigames → | Rule card, telegraphs, sender-colour frames, events |

## Formulas

### F1. Comeback scale

`s(r) = 1 + k_cb × (r − 1) / max(1, P − 1)`; `charge_needed(r) = max(1, round(base_charge / s(r)))`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| r | int | 1–P | calculated (standing_metric) | Rank; 1 = leader |
| P | int | 2–4 | Tournament | Players still in the round, ghosts included |
| k_cb | float | 0–1.5 | data file | Comeback strength; default 0.5 |
| base_charge | int | 1–10 | data file (per minigame) | e.g. 3 passes (MG1), 5 catches (MG15) |

**Output Range:** s from 1.0 (leader) to 1 + k_cb (last place).
**Example:** P = 4, k_cb 0.5, MG15 base 5 → leader 5 catches, 2nd round(5/1.17) = 4, 3rd round(5/1.33) = 4, last round(5/1.5) = 3.

Timed charges (MG6 Bird) use `t_charge = base_t / s(r)`: 25 s for the leader, about 16.7 s for last place.

### F2. Leader send scale (3–4 players)

`effect_amount = base_amount × (r = 1 ? leader_send_scale : 1)`, with default 0.5.

**Example:** a leader's Gust in MG5 lasts 4 s instead of 8 s. With 2 players the scale is 1, because "the leader hits 2nd" is the only possible target.

### F3. Hole fit (MG1)

`pass = proj(piece, wall_axis) ⊆ hole`; `perfect = proj(piece, wall_axis) = hole_core`

Here `proj` is the set of (u, v) cells covered when the piece is flattened along the wall axis, and `hole_core` is the hole without slack.

**Example:** an L of 4 cubes lying flat (z = 0) projects along z to 4 cells. A hole of those 4 cells plus 2 slack cells → pass. Exactly the 4 → perfect.

### F4. Copy accuracy (MG2)

`accuracy = |B ∩ M| / |B ∪ M|` (B = built cells, M = model cells, both relative to the pad)

**Output Range:** 0–1. **Example:** model 10 cells, built 10 with 8 overlapping → 8 / 12 ≈ 0.67 → 67 points.

### F5. Silhouette match (MG10)

`match = (front(B) = S_front) AND (side(B) = S_side)`, where `front` projects along z and `side` along x. Progress shown = `|front(B) ∩ S_front| + |side(B) ∩ S_side|` minus extra cells, over `|S_front| + |S_side|`.

**Example:** S_front 8 cells, S_side 6; a build covering 7 and 6 with 1 extra → (13 − 1) / 14 ≈ 86%.

### F6. Lava timing (MG13)

`lava_ms(n) = max(lava_min_ms, lava_start_ms − lava_step_ms × n)` for the n-th rise.

Defaults: 12 000 / 7 000 / 500.

**Example:** rises come at 12, 23.5, 34.5 s …, and the spacing reaches 7 s from the 11th rise (at about 104.5 s). Over 150 s that is about 17 rises. Keeping one safe layer per rise on 4 × 4 needs 8 cells (`lava_cover` 0.5), about 2 pieces. By the end that is 2 pieces per 7 s, about 1 piece every 3.5 s. That is tight by design, and it is a tuning point for the first playtest.

### F7. Round length

`t_round = min(t_goal, t_mg) + t_intro (3 s) + t_countdown (3 s)`; all minigames fit within Tournament Flow's `round_time_cap_s` (240 s).

## Edge Cases

- **A Send arrives after the target finished or is out**: it is discarded, and the sender gets a "missed" puff with no refund (refunds invite spam with no feedback).
- **Two Sends hit one target at once**: both apply in arrival order. The same effect id refreshes its duration and does not stack (Buffs & Debuffs stacking rule).
- **The leader changes during the telegraph**: the target was fixed at send time, so it still lands.
- **Ranks are tied**: ties go to the higher score, then the lower player index, so targeting is deterministic on every device.
- **2 players**: "leader hits 2nd" means each player always targets the other. F2's leader scale is 1.
- **MG1, the piece fits no orientation for a Tight Wall**: impossible, because the hole is built from the current piece.
- **MG3, a grey cube lands on a cell the player fills in the same instant**: the grey cube takes the next free top-surface cell; if none, it is discarded.
- **MG4, a Steal when the target's tower is 0 high**: the steal fails, and the sender still gets the slab (the comeback still pays).
- **MG4, a Shield is up**: the next Steal against it is absorbed, and the Shield breaks.
- **MG6, the Bird's cell is under the mascot**: the Bird picks the next top walkway cell toward the start; if none, it does nothing.
- **MG8, all of the target's gift slots are full**: the gift bounces (nothing happens), and the sender sees "full".
- **MG9, two players sort the Golden Piece at the same host-received time**: arrival order at the host decides (Local Multiplayer rule 5).
- **MG13, all players are out in the same rise**: the player with the most safe layers before that rise wins; equal counts are a shared win.
- **MG14, the Hot Block holder is the only player left** (others disconnected): the fuse is cancelled.
- **MG14, a Hot Block is cleared by a Bomb item**: it counts as cleared and passes on.
- **MG15, a piece lands half on the tray and half off**: it locks, and the cubes not over the tray (or the stack) are trimmed.
- **A ghost tries to send while all living players are tied for the lead**: the tie rule picks the target.
- **A device lags (no message for 1 s)**: Sends to it queue at the host and apply on reconnect, unless the round has ended.
- **A minigame template enables a twist that conflicts with its slots**: validation fails.

## Dependencies

**Upstream (Hard)**: Mode / Minigame Randomizer, Tournament Flow, Level Data & Definition, Local Multiplayer Setup, Piece Set, Piece Spawner & Queue, Buffs & Debuffs, Level Goals & Fail States.

**Upstream (Soft)**: Items (MG11, MG12), Level-Specific Mechanics (M1, M5, M10), Twist Library (Invisible Blocks), Physics Mode (MG5), Obstacles (junk for MG14).

**Downstream**: HUD (rule card, charge buttons, mini-boards), Game Feel & VFX, Audio, Mascot Reactions, Points System (round wins, unchanged).

Bidirectional notes to add: the Randomizer has an addendum for minigames; the other GDDs list this system when they are next revised.

## Tuning Knobs

| Knob | Range | Default | Category | Affects |
|---|---|---|---|---|
| k_cb | 0–1.5 | 0.5 | curve | Comeback strength (F1) |
| leader_send_scale | 0.25–1 | 0.5 | curve | Leader sabotage (F2) |
| attack_warn_ms | 500–2 000 | 1 000 | feel | Telegraph time; hides latency |
| pick_window_ms | 0–3 000 | 1 500 | feel | Tap-to-pick time; 0 = auto only |
| ghost_send_ms | 5 000–30 000 | 15 000 | gate | Ghost interaction rate |
| t_mg per minigame | 60–180 s | see table | gate | Round length |
| base_charge per minigame | 1–10 | see rules | curve | Sabotage frequency |
| wall_interval / hole_slack (MG1) | 2–8 s / 0–4 | 6 → 3 / 2 → 0 | curve | Difficulty ramp |
| show_ms (MG2) | 2 000–8 000 | 5 000 | curve | Memory difficulty |
| swing_period (MG5) | 1.5–4 s | 2.4 | feel | Timing difficulty |
| gift_cap (MG8) | 1–4 | 2 | gate | Gift pile-up |
| lava_start / min / step (MG13) | see F6 | 12 000 / 7 000 / 500 | curve | Survival pressure |
| lava_cover (MG13) | 0.25–1.0 | 0.5 | curve | Cells needed for a safe layer; blocks the pole strategy |
| fuse_ms / blast_junk (MG14) | 10 000–40 000 / 1–3 | 20 000 / 2 | curve | Hot potato pressure |
| enabled minigames | set | all 15 | gate | Host tournament setting |

## Visual/Audio Requirements

- Every incoming Send uses the **sender's player colour** frame plus the effect icon. The hazard and debuff accents follow the art bible's one-accent-per-effect rule.
- One rule card per minigame: icon, two-word name, one sentence, and a 2-frame looping animation of the verb.
- Audio events: `mg_intro`, `send_charged`, `send_fired`, `send_incoming`, `steal`, `golden_piece`, `hot_block_tick`, `hot_block_boom`, `ghost_send`, `mg_win`.

## Game Feel

The rule card is understood in ≤ 3 s, and the first meaningful action happens within 5 s of the countdown. Sends must feel like a cheeky poke, not a wipe: no single Send may cost the target more than about 10% of a round's progress (checked in playtest, criterion 12).

## UI Requirements

Rule card, charge button (bottom corner, glows when Ready), opponent mini-boards with standing, and the incoming-attack marker on the board. 📌 **UX Flag**: `/ux-design` for the minigame HUD and the tap-to-pick target flow on a phone.

## Cross-References

`mode-minigame-randomizer.md` (pool, seeds), `tournament-flow.md` (rounds, time cap, ties), `local-multiplayer-setup.md` rules 3–5 (events, host time), `items.md` rules 8, 11, 12 (targeting, table, on/off), `buffs-debuffs.md` (effect contract), `level-specific-mechanics.md` M1, M5, M10, `twist-library.md` T2, `physics-mode.md` (Tower Race core), `mechanics-catalog.md` (catalog ideas used here), `piece-set.md` (families), `design/art/block-art-sets.md` (colour per set).

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [U] Validation: a minigame template without an `interaction_hook` or `standing_metric` fails.
2. [U] F1: P 4, k_cb 0.5, base 5 → charges 5 / 4 / 4 / 3 by rank.
3. [U] Targeting: the leader's Send hits 2nd; others hit the leader; ties resolve the same way on every device given the same standings.
4. [I] Two devices on one LAN: a Send shows on the target ≥ `attack_warn_ms` before it acts, and the effect applies exactly once.
5. [U] F3: an L-tetromino flat along z passes a hole equal to its projection plus slack, and is Perfect on the exact projection.
6. [U] F4: model 10, built 10, overlap 8 → accuracy 0.67.
7. [U] F5: a build with exact front and side projections returns match = true; one extra cube outside the silhouette returns false.
8. [U] MG14: clearing the layer that contains the Hot Block moves it to the target's queue front; at the fuse end it adds 2 junk layers to the holder.
9. [U] MG13 F6: rises at 12.0, 23.5, 34.5 s with defaults; spacing never below 7 s.
10. [U] Same round seed → identical walls (MG1), models (MG2), golden-piece times (MG9) and sky lanes (MG15) on every device.
11. [I] A player knocked out in MG13 becomes a ghost and can Pump the leader every 15 s.
12. [M] Party playtest (3–4 players, all 15 minigames): ≥ 80% understand each minigame from the rule card alone; no single Send costs more than about 10% of round progress; trailing players use their interaction at least once in ≥ 90% of rounds.
13. [M] Every minigame's median round length is within 60–180 s.

## Open Questions

- **Solo practice**: should minigames also appear in Arcade (practice against bots, or a score chase)?
- **Tap-to-pick on small phones**: does picking a rival during play cost too much attention? If so, use auto-target only.
- **MG5 cost**: Crane Tower needs Physics Mode (Alpha). If physics slips, swap in a grid crane (release into a lane).
- **New Buffs & Debuffs effect ids**: Tight Wall, Smudge, Gust, Flicker, Slippery Tray and Shield are to be added to `buffs-debuffs.md` when it is next revised.
