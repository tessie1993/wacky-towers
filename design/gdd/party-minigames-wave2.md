# Party Minigames — Wave 2 (MG22–MG36)

> **Status**: In Design (implementation in progress)
> **Author**: Tessa + agents (game-designer)
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; Comeback Energy; The Block Is the Constant; Readable Chaos

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Tournament Minigames (contract), Mode / Minigame Randomizer, Local Multiplayer Setup, Piece Set`

## Overview

Fifteen more tournament party rounds that follow the **minigame contract** in
`design/gdd/tournament-minigames.md` (Core Rules 1–13, F1 comeback scale, F2
leader send scale, telegraphed sends, ghosts). Each one introduces a verb the
first 21 minigames do not use: aim, recall a sequence, react, estimate, spot
the difference, pair, dodge, slide, reflect, tally, whack, pull, orient,
gamble and deduce. Every round is still about Piece Set shapes and cubes.
They run on the same fixed-60 Hz `WtMinigameSession` and are selected by the
template field `rules_script` (wave-2 rules live in `rules_c.gd` for MG22–MG29
and `rules_d.gd` for MG30–MG36). All values are starting defaults.

## Player Fantasy

"One more! I know this one!" Wave 2 is the quick-fire half of the party: most
rounds are 45–90 s, explained by one sentence, and a single good moment (a
strike, a perfect pull, a lucky Plinko jackpot) can swing the room. Target MDA
aesthetics: **Fellowship** (primary), **Challenge**, **Sensation**.

## Detailed Design

### Shared rules (all of wave 2)

1. Every template carries `rules_script`, `view.kind` names the arena drawer,
   and all randomness comes from `s.rng` (round seed: every player gets the
   same challenge sequence) or `s.attack_rng` (incoming attacks only).
2. Every command is a semantic intent (`mg_*`). Commands outside `playing`
   are ignored; ghosts may only send.
3. Scoring uses `s.add_score()`; race rounds write `s.progress` (0–1000).
4. Sends use `s.charge_send(effect, data, base_charge)` (F1) and land through
   `attack()` after `attack_warn_ms`; lasting effects store an `*_until` time.
5. No wave-2 round enables items; each has at least one Send or Shared hook.
6. Every template has `duration_ms` 45–120 s (inside the 30–240 s contract).

### The 15 minigames

| # | Minigame | Verb | t_mg | Standing | Hook | Send effect |
|---|---|---|---|---|---|---|
| MG22 | Block Bowling | Aim and spin | 90 s | score | S | `greased_lane` |
| MG23 | Simon Stack | Repeat a sequence | 90 s | score | S | `scramble` |
| MG24 | Quick Drop | React to the signal | 60 s | score | Sh | (shared draw) |
| MG25 | Cube Count | Estimate a tower | 75 s | score | S | `short_peek` |
| MG26 | Odd Block Out | Spot the mirror twin | 75 s | score | S | `extra_decoy` |
| MG27 | Toy Pairs | Match hidden pairs | 90 s | score | S | `shuffle_pair` |
| MG28 | Block Dodge | Dodge the rain | 90 s | alive_time | S | `extra_rain` |
| MG29 | Slide Shuffle | Solve a slide puzzle | 120 s | race_progress | S | `nudge` |
| MG30 | Mirror Mirror | Paint the reflection | 90 s | score | S | `flip_axis` |
| MG31 | Colour Count | Tally the parade | 75 s | score | S | `fast_parade` |
| MG32 | Whack-a-Block | Tap the pop-ups | 60 s | score | S | `decoy_bombs` |
| MG33 | Tower Pull | Pull without toppling | 120 s | score | S | `wobble_tower` |
| MG34 | Spin Match | Orient in few turns | 90 s | score | S | `sticky_axis` |
| MG35 | Plinko Drop | Drop for the buckets | 75 s | score | Sh | (shared jackpot) |
| MG36 | Treasure Dig | Deduce the dig site | 120 s | score | S | `mud` |

**MG22. Block Bowling** — `view.kind = "bowling"`
- Lane: 5 columns × 9 rows. Ten pins are single cubes in a triangle at rows 6–9.
- The ball is the next Piece Set shape, flattened to its footprint (width ≤ 3).
- `mg_aim {"dir": ±1}` moves the ball one column (0–4); `mg_spin {"dir": ±1}`
  sets curve −1/0/+1; `mg_bowl` releases.
- Roll (F1): the ball advances one row per `roll_step_ms` (120); after row
  `curve_row` (4) its column shifts by `curve` once. Any pin in a column the
  footprint covers on its row is knocked down; a knocked pin also knocks the pin
  directly behind it (row + 1, same column) — the domino rule.
- Frame: 2 balls per frame. All 10 on ball 1 = Strike (+20), on ball 2 = Spare
  (+15), otherwise +1 per pin. A new rack appears after each frame.
- Send `greased_lane` (charge 2 strikes/spares, scaled by F1): the target's next
  ball gets an extra forced curve of +1 for `duration_ms` 8000.

**MG23. Simon Stack** — `view.kind = "sequence"`
- Four coloured pads (hues 0–3), each holding a Piece Set shape.
- Show phase: the sequence of length `start_len` (3), +1 per success, flashes
  one step per `flash_ms` (600). Input is locked while showing.
- Input: `mg_pad {"pad": 0..3}`. A correct full sequence scores its length;
  a wrong pad ends the attempt (0 points), and a new sequence of length
  `max(start_len, len − 1)` begins.
- Send `scramble` (charge 2 successes): the target's next sequence shows with
  pads' positions swapped once (view field `swapped`), so colours stay but
  places change.

**MG24. Quick Drop** — `view.kind = "signal"`
- Each duel: a seeded wait of `wait_min_ms`–`wait_max_ms` (1500–4500), then the
  block lights green. `mg_tap` after green scores
  `max(1, 10 − reaction_ms / 50)` points and requests the shared `quick_drop_win`
  (host awards +3 to the fastest player that duel). A tap before green is a false
  start: −2 points (floor 0) and that duel is lost.
- A fake flash (amber, never green) appears in `fake_chance` (0.3) of duels after
  round 4 seconds; tapping it is also a false start.
- Duel cadence: next duel `gap_ms` (1200) after a tap or after `timeout_ms` (1500)
  without one.

**MG25. Cube Count** — `view.kind = "count"`
- A seeded tower of 2–5 Piece Set pieces (6–20 cubes) on a 4 × 4 pad is shown
  for `show_ms` (3000), including hidden cubes behind others.
- Then four answers are offered (`choices`): the true count and three seeded
  distractors within ±1..4. `mg_answer {"index": i}`.
- Correct: +3 (+2 bonus if answered within `fast_ms` 2000). Wrong: 0.
- Send `short_peek` (charge 2 correct): the target's next tower shows for
  `show_ms − 1200` (minimum 1200).

**MG26. Odd Block Out** — `view.kind = "odd"`
- Four rotated copies of one chiral shape; one is a mirror image (reflected in
  x). Rotations are seeded from the 24 orientations; the odd one is never just a
  rotation of the others (asserted by comparing normalised cell sets over all
  24 orientations).
- `mg_pick {"index": i}`. Correct +2; wrong 0 and a `pick_lock_ms` (1000) lock.
- From the 5th puzzle on, there are 5 copies.
- Send `extra_decoy` (charge 3 correct): the target's next puzzle shows 6 copies.

**MG27. Toy Pairs** — `view.kind = "pairs"`
- A 4 × 4 grid of face-down cards, 8 pairs of Piece Set shapes. `mg_flip
  {"index": i}` turns a card. Two face-up cards: a match stays up (+2); a
  mismatch flips back after `mismatch_ms` (800).
- A cleared grid scores +5 and deals a new grid.
- Send `shuffle_pair` (charge 3 matches): two of the target's face-down cards
  swap places (visible as a little hop, `swap_cells` in view).

**MG28. Block Dodge** — `view.kind = "dodge"`
- Your mascot stands on a 5-lane floor. Blocks fall in seeded lanes, each
  telegraphed by a floor shadow `shadow_ms` (900) before impact.
- `mg_step {"dir": ±1}` moves one lane. A block landing in your lane costs a
  heart (3 hearts). At 0 hearts you become a ghost (contract rule 10).
- Rain speeds up: interval `max(rain_min_ms, rain_start_ms − 40 × n)`
  (start 1100, min 450). From 30 s, some drops cover 2 adjacent lanes.
- Every 10 s survived: +1 point. Send `extra_rain` (charge 3 dodges near-miss:
  a drop in the adjacent lane): the target gets `count` (3) extra drops.
- Winner: last standing; at `t_mg`, longest alive (`alive_time`).

**MG29. Slide Shuffle** — `view.kind = "slide"`
- A 3 × 3 sliding puzzle with one empty slot; tiles 1–8 show pieces of one block
  picture. Scrambled with `scramble_moves` (30) seeded legal moves from solved,
  so it is always solvable.
- `mg_slide {"dir": Vector2i}` moves a neighbouring tile into the gap.
- `progress = 1000 × correct_tiles / 8`; solved = +1 puzzle and a new scramble.
  Two puzzles solved finishes the round (`won`).
- Send `nudge` (charge 5 tiles placed correctly for the first time): the target
  suffers `count` (3) seeded extra moves.

**MG30. Mirror Mirror** — `view.kind = "mirror"`
- A 5 × 5 half-pattern is shown on the left; paint its reflection across the
  centre line on the right. `mg_move {"direction": Vector3i}` moves the cursor,
  `mg_paint` toggles a cell.
- `mg_submit` scores `10 × accuracy` (Jaccard, F4 of the contract) then deals a
  new pattern of `cells` (6, +1 per pattern up to 12).
- Send `flip_axis` (charge 2 submissions ≥ 0.9): the target's next pattern
  reflects across the horizontal instead of the vertical line.

**MG31. Colour Count** — `view.kind = "tally"`
- A parade of 12–20 coloured Piece Set blocks crosses the screen, one every
  `parade_ms` (450). Afterwards the question asks how many were the round's
  target hue. Four `choices`; `mg_answer {"index": i}`. Correct +3.
- Send `fast_parade` (charge 2 correct): the target's next parade uses
  `parade_ms − 150` (minimum 250).

**MG32. Whack-a-Block** — `view.kind = "whack"`
- A 3 × 3 field of holes. Seeded pop-ups show for `pop_ms` (900, falling to
  550). Kinds: block +1, golden block +3 (1 in 10), bomb −2 (1 in 8).
  `mg_whack {"index": i}` hits a hole; a missed tap on an empty hole costs nothing.
- Send `decoy_bombs` (charge 8 good hits): the target's next `count` (4) pop-ups
  are bombs dressed as blocks for the first 300 ms (`disguised` flag).

**MG33. Tower Pull** — `view.kind = "pull"`
- A 3-wide Jenga-like tower of 3-cube bars, 9 layers, alternating direction.
- `mg_pull {"layer": l, "slot": 0..2}` removes one bar. The bar is placed on top
  (completing a top layer before starting a new one).
- Stability (F2): each layer needs the centre bar, or both edge bars. A pull that
  breaks stability topples the tower: −5 points, and the tower is rebuilt after
  `rebuild_ms` (2500). The top layer and the one under it cannot be pulled.
- Each safe pull +1; a pull from the bottom three layers +2.
- Send `wobble_tower` (charge 4 safe pulls): for `duration_ms` (5000) the
  target's view shakes and edge pulls count as risky (an edge pull with only one
  edge remaining fails even with the centre present).

**MG34. Spin Match** — `view.kind = "spin"`
- A target orientation of a shape is shown beside your copy. `mg_rotate {"axis",
  "dir"}` turns your copy by quarter-turns; `mg_submit` checks the orientation.
- Score = `max(1, 6 − (turns − par))` where `par` is the minimum number of
  quarter-turns (BFS over the 24 orientations). Wrong submit: 0 and a new puzzle.
- Send `sticky_axis` (charge 3 par solves): for `duration_ms` (8000) one of the
  target's three axes is locked (`locked_axis` in view).

**MG35. Plinko Drop** — `view.kind = "plinko"`
- A 7-column peg board, 6 peg rows, 7 buckets worth `[1, 3, 5, 10, 5, 3, 1]`.
- `mg_aim {"dir": ±1}` chooses the start column; `mg_bowl` drops the block.
  Pegs deflect deterministically from a seeded per-row pattern (L/R), visible to
  everyone; the block steps one row per `drop_step_ms` (180).
- Shared jackpot: every `jackpot_ms` (15000) the 10 bucket becomes a jackpot
  (×2) for everyone at once; the first host-received jackpot landing requests
  `plinko_jackpot` and wins +5 more.
- Drops: one per `drop_cooldown_ms` (1200).

**MG36. Treasure Dig** — `view.kind = "dig"`
- A 6 × 6 dirt patch hides one buried Piece Set shape (3–5 cubes, footprint).
- `mg_move` moves the shovel; `mg_dig` digs the cell: a hit reveals a treasure
  cell; a miss shows the Manhattan distance to the nearest unrevealed treasure
  cell (hot/cold number).
- Revealing every treasure cell scores `max(2, 12 − misses)` and buries a new one.
- Send `mud` (charge 2 treasures): `count` (3) of the target's dug miss cells are
  filled back in (their distance numbers vanish).

### States and Transitions

As the contract: Intro → Countdown → Playing → Finished. MG28 adds Ghost.
MG33 adds a short `rebuilding` sub-state (input ignored). MG23/MG25/MG31 have a
`showing` sub-state where answer input is ignored.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Tournament Minigames (contract) | → | Session API, F1/F2, telegraph, ghosts |
| Mode / Minigame Randomizer | ↔ | Templates mg22–mg36 join the pool with weight 1 |
| Local Multiplayer / main tournament | ↔ | `mg_send_request`, `mg_shared_request`, `mg_authority` |
| Piece Set | → | Shapes, hues, orientations |
| HUD / Minigame UI | ← | `view` dictionaries, rule card text |
| Art (WtMinigameArt) | ← | One landmark toy per minigame |

## Formulas

### F1. Bowling roll (MG22)

`col(row) = c0 + (row ≥ curve_row ? curve + forced_curve : 0)`, clamped to 0–4.
Pins hit = pins whose column is in `[col, col + w − 1]` on their row, plus the
domino follow-on (row + 1, same column). **Example:** w = 2 at c0 = 1, no curve:
columns 1–2 → hits pins in those columns on each pin row → typically 4–6 pins.

### F2. Tower stability (MG33)

`stable(layer) = centre ∨ (left ∧ right)`; with `wobble_tower`, `stable = (centre ∧ (left ∨ right)) ∨ (left ∧ right)`.
**Example:** a layer with only the centre bar is stable normally, unstable while wobbling.

### F3. Reaction score (MG24)

`points = max(1, 10 − floor(reaction_ms / 50))`. 180 ms → 7; 500 ms → 1.

### F4. Spin par (MG34)

`par = BFS distance in the quarter-turn graph from start to target orientation (0–3 for most shapes)`.
`score = max(1, 6 − max(0, turns − par))`.

### F5. Dig reward (MG36)

`score = max(2, 12 − misses)`. 3 misses → 9.

## Edge Cases

- **MG22, a footprint wider than 3** (e.g. a long I): the widest 3 cells are used.
- **MG22, both balls of a frame knock nothing**: 0 points, new rack.
- **MG23, a send arrives mid-show**: it applies to the next sequence, never the current one.
- **MG24, two players tie for the fastest reaction**: both get +3 (shared win).
- **MG25 / MG31, a distractor equals the answer**: distractors are drawn without replacement from non-answer values ≥ 1.
- **MG26, a shape is achiral (its mirror is a rotation)**: it is skipped; only chiral shapes enter the pool, verified at start.
- **MG27, a shuffle arrives with < 2 face-down cards**: it does nothing.
- **MG28, an `extra_rain` arrives while a ghost**: discarded (missed).
- **MG29, a `nudge` would undo the target's last move**: the seeded move list never picks the reverse of the previous move.
- **MG33, the player pulls a bar that does not exist**: ignored.
- **MG35, the jackpot landing request reaches the host after the jackpot ended**: no bonus.
- **MG36, `mud` with fewer than 3 dug miss cells**: fills those that exist.
- **Any round, `mg_send` while charging**: ignored (session rule).

## Dependencies

- `design/gdd/tournament-minigames.md` — the contract this extends (that doc's Interactions table lists the Randomizer pool; wave-2 templates join it).
- `design/gdd/mode-minigame-randomizer.md` — draw rules, no-repeat window.
- `design/gdd/piece-set.md` — shapes and orientations.
- `design/gdd/local-multiplayer-setup.md` — shared requests resolved by the host.
- `design/gdd/hud.md` — rule card and telegraph presentation.

## Tuning Knobs

| Knob | Default | Safe range | Affects |
|---|---|---|---|
| `roll_step_ms` (MG22) | 120 | 60–250 | Bowling readability |
| `flash_ms` (MG23) | 600 | 350–900 | Sequence difficulty |
| `wait_min_ms`/`wait_max_ms` (MG24) | 1500/4500 | 800–6000 | Suspense |
| `show_ms` (MG25) | 3000 | 1200–5000 | Counting difficulty |
| `mismatch_ms` (MG27) | 800 | 400–1500 | Memory pace |
| `rain_start_ms`/`rain_min_ms` (MG28) | 1100/450 | 300–2000 | Dodge pressure |
| `scramble_moves` (MG29) | 30 | 10–80 | Puzzle depth |
| `parade_ms` (MG31) | 450 | 250–800 | Tally speed |
| `pop_ms` (MG32) | 900 | 400–1500 | Whack speed |
| `rebuild_ms` (MG33) | 2500 | 1000–4000 | Topple penalty |
| `jackpot_ms` (MG35) | 15000 | 8000–30000 | Shared moment cadence |
| `k_cb`, `leader_send_scale`, `attack_warn_ms` | contract defaults | contract | Comeback |

## Acceptance Criteria

1. All 15 templates validate in `WtTournamentRandomizer` and appear in `modes.json` tournament modes.
2. For each minigame, a seeded session started twice with the same seed and the same command script produces the same `state_hash()` (determinism).
3. Each minigame has a unit test that drives its core verb through commands and asserts the score/progress change from F1–F5 or the rules above.
4. Each minigame's send effect, delivered via `mg_receive_attack`, changes the target's state as described after `attack_warn_ms`.
5. MG28 makes the player a ghost at 0 hearts; MG29 finishes as `won` after two solved puzzles.
6. `WtMinigameUi` renders every wave-2 id without script errors and builds its controls (smoke test), at 720 p and 1280 p.
7. Every wave-2 minigame has a `WtMinigameArt` landmark toy.
