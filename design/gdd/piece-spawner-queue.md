# Piece Spawner & Queue

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: Readable Chaos; Comeback Energy

## Summary

The Spawner decides which piece comes next and puts it on the board. By default it deals pieces from a **weighted bag** (every shape in the level's set appears in each bag, so there are no long droughts), shows the player the next **1 piece** (levels can show up to 3), and has **no hold slot** unless a perk, item or level turns it on. In versus play the level decides whether all players get the **same sequence** (the default) or their own.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Piece Set`

## Overview

The Piece Spawner & Queue sits between the Piece Set (which defines the shapes) and the pieces the player actually handles. It owns three things: the **sequence** (which shape comes next, and how random it is), the **queue** (the upcoming pieces, and how many the player can see), and the **spawn** (placing the next piece in the spawn zone in its spawn orientation). The default sequence is a *weighted bag*: each shape in the level's set is put in the bag in proportion to its weight, the bag is shuffled and dealt out, then refilled. This keeps the game fair — a shape can't vanish for dozens of pieces — while still being unpredictable beyond the next bag. A level may instead pick pure random or a history-roll randomizer for more chaos. The preview shows the real upcoming 3D piece (art bible §7), 1 by default and up to 3 by level, perk or item. A hold slot exists but is off by default; a perk, item or level can turn it on. In versus play, all players can draw from one seeded sequence so results come from skill and items rather than luck, which serves *Comeback Energy*; a clear preview serves *Readable Chaos*. All values are starting defaults.

## Detailed Design

### Core Rules

**Sequence**
1. Each player has a **piece stream**: an endless, numbered sequence of pieces (index 0, 1, 2, …). The stream is a pure function of `(round_seed, player scope, config, index)`, so peeking ahead never changes it, and replaying the same seed gives the same game.
2. The stream uses its **own seeded random generator**, never a shared global one. No gameplay event (clears, items, twists, other players) draws from it or advances it.
3. **Default randomizer: weighted bag.** A *bag* holds `copies_i` copies of each shape `i` in the level's set (Formulas F1). It is shuffled (Fisher–Yates with the stream's generator) and dealt in order; when it is empty it is refilled and reshuffled. The set is read at each refill, so a change to the set takes effect from the **next refill** (Piece Set edge case).
4. A level may override the randomizer with **history-roll** (pick at random, re-roll up to `history_tries` times if the shape is among the last `history_len` pieces; Formulas F3) or **pure random** (an independent weighted pick each time, `P(i) = w_i / Σw`).
5. **Injected pieces** (an item that sends a piece, a twist that forces a shape) are placed at the front of a player's queue **outside** the stream: they do not use up a stream index, so the stream stays identical for everyone.
5a. **Opening pieces are picked before the level starts.** At level load, before play begins, the randomizer deals the opening pieces (the queue and preview) from the stream. A level may give an `opening_set` (shape ids) and `opening_count`: the randomizer then draws the first `opening_count` pieces from that set only, still at random, then continues with the level's normal set. Tutorial levels use this to introduce a new shape; there is no hand-scripted fixed sequence (user decision 2026-10-09).

**Queue and preview**
6. The Spawner keeps the next `queue_lookahead` pieces (default 3) generated ahead of the falling piece. `preview_count` (default 1; level range 0–3) of them are shown. A perk or item can raise `preview_count` up to `preview_cap` (3).
7. The preview shows the **real upcoming pieces** in their spawn orientation; the first in line is the one that spawns next. If an injected piece or a twist changes the queue, the preview updates at once.

**Spawn**
8. Fall, Drop & Lock calls `spawn()` when its Waiting state ends. The Spawner takes the head of the queue, creates a piece instance (Piece Set: Queued → Falling), and places it in the spawn zone in the shape's **spawn orientation**, centred on the active region's footprint centre (the lower cell when the centre falls between cells) with its lowest cube at layer `H_play`.
9. If the spawn cells are occupied, the Spawner reports **spawn blocked** (Board / Grid) once. The piece stays at the head of the queue (it is not consumed or skipped), the Spawner does not retry on its own, and the mode decides what happens (default: loss). A mode that carries on calls `spawn()` again when it is ready.
10. A spawn is never skipped, reordered or "fixed" to avoid a loss: Readable Chaos means the player can always see why they lost.

**Hold (optional, off by default)**
11. When `hold_enabled` is on (by level, perk or item), each player has **one hold slot**. A `hold` command swaps the falling piece with the held piece; if the slot is empty it stores the piece and spawns the next one from the queue (using up one stream index).
12. Hold can be used **once per falling piece** (the allowance resets when a piece spawns from the queue), only while a piece is falling (not in Waiting), and a swapped-in piece appears at the spawn position in its spawn orientation. If the swapped-in piece's spawn cells are occupied, the swap is refused and nothing changes.

**Versus and seeds**
13. Each round has a `round_seed`. With `sequence_mode = shared` (default) every player's stream is built from `round_seed` alone, so everyone sees the same pieces in the same order. With `independent`, each stream also mixes in the player's id. The level decides the mode.
14. In `shared` mode, a perk or item that changes one player's set (e.g. adds Helpers) adds those extra pieces to **that player's** next bag only, using a separate sub-stream, so other players' streams are unaffected. (Provisional — see Open Questions.)

### States and Transitions

Per player:

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| **Idle** | No level running | Created, or the level ends | Level starts |
| **Ready** | Queue is filled; waiting for `spawn()` | Level starts; a piece spawned and the queue was refilled; a blocked spawn was cleared | `spawn()` called |
| **Blocked** | Spawn cells occupied; head piece waiting | `spawn()` found occupied cells | Mode calls `spawn()` again and it succeeds, or the level ends |
| **Stopped** | No more spawns (level over) | Level won, lost or quit | Next level starts (back to Idle) |

Transitions: Idle → Ready (level start); Ready → Ready (spawn succeeded, queue topped up); Ready → Blocked (spawn failed); Blocked → Ready (a later spawn succeeded); any → Stopped (level ends).

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Piece Set | Piece Set → Spawner | The level's allowed shapes, spawn orientations and tags; weights `w_i` are owned here |
| Level Data & Definition | → Spawner | `piece_set`, weights, `randomizer`, `preview_count`, `hold_enabled`, `sequence_mode`, `round_seed` |
| Fall, Drop & Lock | ↔ | Calls `spawn()`; receives the new piece or a spawn-blocked report |
| Board / Grid | ↔ | Reads spawn cells to check they are free; reports spawn blocked |
| Movement & Rotation | Spawner → | The new piece instance (shape, position, orientation) |
| HUD | Spawner → | The next `preview_count` pieces, the held piece, hold availability |
| Touch Controls | → Spawner | `hold` command (only when hold is enabled) |
| Rule-Twist Framework, Items, Skills | ↔ | Inject or swap pieces; change set, weights, preview or hold; the Spawner exposes `inject_front(piece)`, `set_preview_count(n)`, `set_hold_enabled(b)`, `add_to_next_bag(shapes)` |
| Characters & Perks, Shop | → Spawner | Perks that add Helpers, raise preview or enable hold |
| Local Multiplayer Setup | → Spawner | Player count and ids for the stream scope |

## Formulas

All values are starting defaults. Weights `w_i` come from Piece Set F1 and are owned by this system.

### F1. Bag copies and bag size

The bag_copies formula is defined as:

`copies_i = max(1, round(w_i / w_min))`, `B = Σ copies_i` over shapes i in the level's set S

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_i | float | > 0 | data file | Spawn weight of shape i; default 1 |
| w_min | float | > 0 | calculated | Smallest weight in S, so the rarest shape gets one copy |
| copies_i | int | 1–`bag_max_size` | calculated | Copies of shape i in each bag |
| B | int | \|S\|–`bag_max_size` | calculated | Bag size, in pieces |

**Output Range:** B is at least the number of shapes; above `bag_max_size` (default 32) the loader warns and the weights are scaled down proportionally (each shape keeps at least one copy). **Example:** I = 1, O = 1, T = 2 → copies 1, 1, 2, B = 4. The default 8 Standard shapes at w = 1 → B = 8.

### F2. Longest drought (bag)

The max_drought formula is defined as:

`D_max_i = 2 × (B − copies_i)` pieces of other shapes between two appearances of shape i

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| B | int | \|S\|–32 | calculated (F1) | Bag size |
| copies_i | int | 1–B | calculated (F1) | Copies of shape i per bag |
| D_max_i | int | 0–2(B−1) | calculated | Worst-case wait for shape i |

**Output Range:** 0 up to 2(B − 1). The mean gap is `B / copies_i`. The most times in a row the same shape can be dealt is `2 × copies_i` (the last copies of one bag followed by the first copies of the next). **Example:** default 8 shapes → D_max = 2 × (8 − 1) = 14, mean gap 8, at most 2 in a row. The classic 7-shape bag gives 12. For comparison, pure random with p = 1/8 leaves a shape unseen for 14 pieces with probability (7/8)^14 ≈ 15%.

### F3. History-roll fall-through

The roll_fallthrough formula is defined as:

`h_eff = min(history_len, |S| − 1)`; `p_roll_in_history ≈ h_eff / |S|` (an upper bound, since the history may repeat shapes); `p_accept_repeat ≈ p_roll_in_history ^ history_tries`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| history_len | int | 0–8 | data file | How many recent pieces to avoid; default 4 |
| history_tries | int | 1–8 | data file | Re-rolls before the last roll is accepted; default 4 |
| \|S\| | int | 1–10 | calculated | Number of shapes in the level's set |
| h_eff | int | 0–\|S\|−1 | calculated | History actually used; a one-shape set uses none |
| p_accept_repeat | float | 0–1 | calculated | Chance a recent shape is dealt anyway |

**Output Range:** 0–1. Unlike the bag, droughts have no cap. **Example:** 8 shapes, history 4, tries 4 → (4/8)^4 = 6.25% at most.

### F4. Queue size check

`queue_lookahead ≥ preview_count`, and `preview_count ≤ preview_cap`. Level validation fails otherwise. **Example:** lookahead 3, preview 1 → valid; preview 4 → fails (cap 3).

## Edge Cases

- **If the level's set has one shape**: B = 1; every piece is that shape; the history-roll history is 0. Valid ("straights only" challenge).
- **If the set is empty**: the level fails validation (Piece Set); the Spawner never starts.
- **If a perk or item changes the set mid-bag**: pieces already in the current bag and queue are unchanged; the change applies from the next refill (Piece Set).
- **If `add_to_next_bag` is called twice before the refill**: both sets of extra pieces are added to that bag.
- **If `spawn()` is called while a piece is already falling**: ignored with a warning in the log; one falling piece per player.
- **If spawn is blocked and the mode carries on**: the head piece stays queued; `spawn()` may be called again; the stream index is not advanced until a spawn succeeds.
- **If an injected piece and a blocked spawn happen together**: the injected piece goes to the front and is the one that fails to spawn; the stream is unaffected.
- **If hold is used with an empty slot and the queue's next piece cannot spawn**: the swap is refused (the falling piece stays falling) and the slot stays empty.
- **If hold is used on an injected or twist-swapped piece**: allowed; the held piece keeps its tags.
- **If hold is turned off while a piece is held**: the held piece returns to the front of the queue (outside the stream) at the next spawn.
- **If `preview_count` is raised or lowered mid-level**: the preview updates at once; the queue itself is unchanged.
- **If the same `round_seed` is used twice**: identical sequences. Rounds in a tournament use different seeds (Tournament Flow).
- **If two players' sets differ in `shared` mode** (e.g. one has extra Helpers): they share the base stream; the extras are added only to that player's next bag (Core Rule 14).
- **If a level sets `sequence_mode = shared` with one player**: no effect.
- **If the app is paused or backgrounded**: the stream and queue do not change.
- **If the stream is asked for an index far ahead** (e.g. a bot or replay): it is computed bag by bag from the seed without changing live state.

## Dependencies

**Upstream (this system depends on):**

| System | Hard / soft | Interface |
|---|---|---|
| Piece Set | Hard | Shape definitions, spawn orientations, tags; the allowed set |
| Board / Grid | Hard | Spawn cells, `H_play`, spawn-blocked report |

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Fall, Drop & Lock | Hard | Calls `spawn()`; handles spawn blocked |
| Movement & Rotation | Hard | Receives the spawned piece |
| HUD | Hard | Preview pieces, held piece, hold availability |
| Rule-Twist Framework | Hard | `inject_front`, shape swaps, set and weight changes |
| Level Data & Definition | Hard | Randomizer, weights, preview count, hold flag, sequence mode, seed |
| Touch Controls | Soft | `hold` command, only when enabled |
| Items, Skills, Characters & Perks, Shop | Soft | Preview and hold changes; extra pieces |
| Local Multiplayer Setup, Tournament Flow | Soft | Player ids and per-round seeds |

Board / Grid and Piece Set describe the Spawner already (spawn blocked, weights `w_i`, "from the next refill"). Touch Controls must add `hold` when this GDD is accepted; the other downstream GDDs must list the Spawner when written.

## Tuning Knobs

| Knob | Range | Default | Source | Affects |
|---|---|---|---|---|
| randomizer | bag / history / random | bag | data file (level) | Fairness vs. chaos of the sequence |
| bag_max_size | 8–64 | 32 | data file | Longest drought for heavily weighted sets (F1, F2) |
| history_len | 0–8 | 4 | data file | How strongly repeats are avoided (F3) |
| history_tries | 1–8 | 4 | data file | Same (F3) |
| queue_lookahead | 1–5 | 3 | data file | Pieces generated ahead; must be ≥ preview_count (F4) |
| preview_count | 0–3 | 1 | data file (level, perk, item) | How far ahead the player can plan |
| preview_cap | 1–5 | 3 | data file | Largest preview any source can give (HUD space) |
| hold_enabled | true / false | false | data file (level, perk, item) | Whether a hold slot exists |
| hold_uses_per_piece | 1–2 | 1 | data file | Hold swaps allowed per falling piece |
| sequence_mode | shared / independent | shared | data file (level) | Luck vs. fairness in versus play |
| w_i (weights) | > 0 | 1 | data file (level) | How often each shape appears (F1) |

`preview_count` and `queue_lookahead` interact: raising the preview past the lookahead is invalid, so raise lookahead first.

## Visual/Audio Requirements

- The preview shows the **real 3D piece** in its spawn orientation from the gameplay camera angle, on a plate of at least 64 pt (art bible §7), in the shape's hue, motif and ink outline (Piece Set). A flat icon is not used.
- When the next piece advances, the preview piece slides into the board's spawn position and the others shuffle forward, in 150–250 ms (art bible §7 timing). With reduced motion, the change is an instant cut.
- Spawn: the piece pops in at the spawn position with a quick squash-and-settle, and a soft puff in the shape's hue. Spawn-blocked shows the piece at the spawn point with the danger red outline (art bible §4) before the mode reacts.
- Hold plate (when enabled): same style as a preview plate, labelled with an icon, never with the word "hold" alone; greyed with a lock mark when this piece's hold use is spent.
- Audio events (owned by Audio): `piece_spawned`, `queue_advanced` (very soft), `hold_swap`, `hold_refused`, `spawn_blocked`. The sequence itself makes no sound.
- The sequence's randomizer type is never shown as a number or word to the player; only the pieces are.

## Game Feel

The next piece should appear the instant the last one locks (after the Waiting delay owned by Fall, Drop & Lock), and the preview should always already show what's coming, so the player is planning while the current piece falls. Targets: preview updated within one frame of a queue change; spawn pop-in 150 ms; hold swap visible in under 100 ms. The bag should feel fair rather than predictable: runs of three of the same shape should not happen in the default (F2: at most 2 in a row at default weights).

## UI Requirements

- Preview plate(s): top-right, above the rotate thumb (HUD; the left-hand mirror swaps it), outside the board's screen rectangle, 1–3 stacked, nearest on top and largest; each at least 64 pt for the first, 48 pt for the others.
- Hold plate: beside the preview, only if enabled; tapping it is the `hold` command (tap-only, in the item strip's thumb zone per Touch Controls, to be settled when hold is first enabled).
- Four-player layouts show the first preview plate only.
- Settings: none by default (preview count is a level or perk property, not a user preference).

📌 **UX Flag — Piece Spawner & Queue**: this system has UI requirements. Run `/ux-design` for the HUD (preview and hold plates) before implementation.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/piece-set.md` Core Rules 2, 10; F1; Edge Cases | Shapes, spawn orientation, weights `w_i`, "from the next refill", one-shape sets, spawn-blocked on swaps |
| `design/gdd/board-grid.md` F4; Core Rule 11; Edge Cases | Spawn zone, `H_play`, spawn blocked, over limit |
| `design/gdd/touch-controls.md` Edge Cases (Waiting state) | `spawn()` timing; `hold` command is new and must be added there |
| `design/gdd/camera-rotate-view.md` | Preview is drawn from the gameplay camera angle |
| `design/art/art-bible.md` §4, §7 | Danger red outline, 3D preview, plate sizes, animation timing |
| `design/gdd/game-concept.md` | Pillars; tournament randomness |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device. Defaults: weighted bag, 8 Standard shapes, preview 1, no hold, shared sequence.

**Sequence**
1. [U] **GIVEN** a seed, set and config, **WHEN** the stream is generated twice (and once more after peeking 50 pieces ahead), **THEN** all three sequences are identical.
2. [U] **GIVEN** the default set at w = 1, **WHEN** 10 000 pieces are dealt, **THEN** each consecutive 8 pieces aligned to a bag boundary contain each shape exactly once.
3. [U] **GIVEN** the same run, **THEN** no shape waits more than D_max = 14 pieces between appearances and none appears more than 2 times in a row.
4. [U] F1: weights {1, 1, 2} → copies {1, 1, 2}, B = 4; weights {0.5, 1} → copies {1, 2}; a set whose B would exceed 32 loads with a warning and each shape keeps at least 1 copy.
5. [U] F2: B = 7 with one copy each → D_max = 12; B = 8, k = 2 → 12.
6. [U] **GIVEN** `randomizer = random` and weights {1, 3}, **WHEN** 10 000 pieces are dealt, **THEN** the share of shape 2 is 75% ± 2%.
7. [U] F3: with history 4, tries 4 and 8 shapes over 10 000 deals, no more than 7% of pieces repeat a shape from the last 4; with a one-shape set the history is 0 and every piece is that shape.
8. [U] **GIVEN** an item calls `inject_front`, **WHEN** the piece spawns, **THEN** the stream index is unchanged and the stream afterwards is identical to a run without the injection.
9. [U] **GIVEN** a set change at index 3 of a bag, **WHEN** the bag finishes, **THEN** the current bag is unchanged and the next bag uses the new set (Piece Set criterion 16).

**Queue and preview**
10. [U] **GIVEN** `queue_lookahead = 3` and `preview_count = 1`, **WHEN** a piece spawns, **THEN** the queue still holds 3 pieces and the preview shows the first.
11. [U] **GIVEN** `preview_count = 4`, **WHEN** the level loads, **THEN** validation fails (cap 3); **GIVEN** a perk raises the preview from 1 to 3, **THEN** the preview shows 3 immediately.
12. [I] **GIVEN** the preview is on screen, **WHEN** the piece spawns, **THEN** the spawned piece has the shape, hue and spawn orientation the preview showed.

**Spawn**
13. [U] **GIVEN** a free spawn zone, **WHEN** `spawn()` is called, **THEN** the piece appears in its spawn orientation, footprint-centred, lowest cube at layer `H_play`, and Piece Set state is Falling.
14. [U] **GIVEN** the spawn cells are occupied, **WHEN** `spawn()` is called, **THEN** spawn blocked is reported once, the head piece is not consumed, the state is Blocked, and no retry happens until `spawn()` is called again.
15. [U] **GIVEN** a falling piece, **WHEN** `spawn()` is called again, **THEN** it is ignored and nothing changes.

**Hold**
16. [I] **GIVEN** `hold_enabled = false`, **WHEN** the level loads, **THEN** no hold slot or plate is shown and `hold` does nothing.
17. [U] **GIVEN** hold is enabled and the slot is empty, **WHEN** `hold` is used, **THEN** the piece is stored and the next queue piece spawns (using one stream index); a second `hold` on that piece is refused.
18. [U] **GIVEN** a held piece, **WHEN** `hold` is used on a new falling piece, **THEN** the pieces swap and the held piece appears in its spawn orientation; if its spawn cells are occupied, the swap is refused and nothing changes.
19. [U] **GIVEN** hold is used during Waiting, **THEN** it is ignored and not buffered.

**Versus**
20. [I] **GIVEN** `sequence_mode = shared` and two players on the same seed, **WHEN** 100 pieces are dealt to each, **THEN** the two sequences are identical, even when one player plays much faster and uses items.
21. [U] **GIVEN** `independent`, **THEN** the sequences differ but each is reproducible from the seed and player id.
22. [U] **GIVEN** a perk adds Helpers to player A in shared mode, **WHEN** the next bag is built, **THEN** only A's bag contains the extras and B's stream is unchanged.

**Presentation**
23. [M] **GIVEN** the reference phone, **THEN** the preview piece is readable at the plate size (64 pt) in all 19 shapes and never overlaps the board rectangle.
24. [I] **GIVEN** reduced motion on, **THEN** the preview advance and the spawn pop-in are instant.

## Open Questions

- **Opening piece**: should the first piece of a level avoid the biggest Specials (Big Cube, Big Tripod) so the first drop is never awkward? Default today: no restriction.
- **Perks in shared mode** (Core Rule 14): is extras-in-next-bag fair enough, or should a perk add pieces to the queue front instead? Decide when Characters & Perks is designed.
- **Weights per level vs. per player**: handicap weights for a trailing player (Comeback Energy) — Rule-Twist Framework or Items to decide.
- **Spawn delay**: the Waiting time between lock and spawn is owned by Fall, Drop & Lock; it affects how fast the queue feels.
- **Hold button placement**: depends on the Touch Controls prototype result; the item strip is the default home.
- **Bot simulation**: measure real drought and run statistics per set (with Board η) before tuning weights.
- **Spawn position on masked boards**: footprint-centred may land on an inactive cell; Board / Grid or Level Data should supply a `spawn_anchor` per level (default centre).
- **Injected pieces and the preview**: do they show in the preview slot count or as a separate marked piece?
