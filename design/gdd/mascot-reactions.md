# Mascot Reactions

> **Status**: In Design (Draft v1)
> **Author**: Tessa + agents (game-designer)
> **Last Updated**: 2026-10-10
> **Systems index**: #35 (Presentation, Alpha)
> **Implements Pillar**: Readable Chaos; Comeback Energy
> **Technical truth**: ADR-0011 (rules in the sim, beehave staging only), ADR-0015 (audio cues), ADR-0014 (camera, safe area), ADR-0013 (settings)
> **Narrative sources**: `design/gdd/narrative/characters.md`, `design/gdd/narrative/emote-bubbles.md`, `design/levels/meadow.md`
> All numbers are tunable defaults, never hard rules.

## Overview

Each biome has one mascot critter that sits at the rim of the board and reacts to the player's play. The Meadow mascot is **Pip**, the harvest mouse. A reaction is a short pose plus, sometimes, one wordless emote bubble from the shared set in `emote-bubbles.md`. Reactions are **view-only**: they run in a beehave `StagingTree` (ADR-0011 §7) that only reads `SimEvent`s, and they never change the board, the clock, the score or any number the player is scored on. A reaction's pose lasts 300 ms or less. The one exception to "no gameplay effect" is the **World & Mascot atoms** (mechanics-module slot 14, WO01–WO11). Any WO atom that changes play (Pip's catch WO11, Pip's hint WO06, later WO01/WO07/WO08/WO10) is a `RuleBehaviour` on the `mascot` layer inside `BoardSim`. It announces what it did in an event, and this system only stages that event. A reaction priority ladder, per-reaction cooldowns and a bubble rate cap keep the mascot lively without spamming the player.

## Player Fantasy

"Pip is watching, and Pip is on my side." The mascot is the player's tiny fan: a hop when a layer clears, a gasp when the stack gets tall, a big cheer for a double, eyes covered when things go wrong. It feels like playing with a friend on the sofa. The friend never talks and never blocks the view, and is never annoying. The mascot reacts to what *you* did, so it reads as warmth, not commentary.

Target MDA aesthetics: **Fantasy** (a living biome with a character in it), **Narrative** (Pip's wordless arc across the Meadow) and, in a supporting role, **Challenge** (warnings felt through a character, not only through the HUD). SDT: **Relatedness** first, then **Competence** (instant, readable praise for good play).

## Detailed Design

### 1. Scope and the split (ADR-0011)

| Kind | Example | Where it runs | Gameplay effect |
|---|---|---|---|
| **Reaction** (this system's core) | Pip hops and shows `heart` on a clear | Mascot presenter's `StagingTree` | None, ever |
| **WO atom staging** | Pip leaps and carries the piece back (WO11); Pip points at a cell (WO06) | The same presenter, triggered by the atom's own event (`mascot_catch`, `mascot_hint`) | The effect is in the sim rule. Staging only shows it |
| **WO atom logic** | Deciding whether the lock is caught; choosing the hint cell | `RuleBehaviour`, layer `mascot` (rank 1), in `BoardSim` | Yes, through `RuleApi` only |

Rules:
1. A reaction never writes to the sim and never reads gameplay knobs (ADR-0011 §7 forbidden list). If removing the mascot presenter could change one `SimEvent` or `state_hash()`, the logic is in the wrong place.
2. **WO09 Watcher** (react only) is this system's default and needs no rule. A level with no WO rule still has a mascot that reacts.
3. Every WO atom with a gameplay effect must emit an event that carries the decision and its window (`hold_ms`, `cell`, …). This system plays that event as a **scripted reaction** (tier R0, §4) and clamps it to the window.
4. Any information the mascot shows that matters to play must also be shown by the board view or HUD. For example, WO06's hint cell also gets a cell highlight, and a warning is also on the HUD. The mascot is a second channel and never the only one (accessibility).
5. Skits (Intro, Results, story beats) belong to the level's story tree (ADR-0011 §8), not to this system. While a skit owns the mascot, reactions are suppressed (§4 rule 7).

### 2. The mascot roster

| Biome | Mascot | Status |
|---|---|---|
| Meadow | **Pip**, harvest mouse (`characters.md`) | Designed (this doc) |
| Candy, Ice, Lava, Underwater, + 5 to come | one critter each | Not designed. Each needs a reaction table (§3) and an emote subset |

- Each mascot is one data record, `assets/data/mascots/<id>.json`, holding its id, biome, presenter scene, emote subset, pose list and reaction table. This is **presentation data**, like `cues.json` (ADR-0015 §3). It is not an ADR-0004 sim knob, and the sim never loads it.
- The presenter scene is the shared kit scene (`src/levels/_kit/staging/pip_presenter.tscn`, ADR-0011 §8). A level places it under `Trees` at a rim marker.
- The mascot's emote subset must be a subset of `emote-bubbles.md`. A table row that uses an emote outside the subset fails the data test (AC 9).
- **Pip's subset** (`characters.md`): `heart`, `exclaim`, `question`, `idea`, `note`, `sparkle`, `sweat`, `angry`, `dizzy`, `invite`, `tear`. `tear` is allowed only on a lost level (`emote-bubbles.md` rules of use).
- **Pip's poses** (`characters.md`): idle, point, catch, cheer, cover-eyes, sneeze, stuck, hang, look-up, give. This system adds two short ones: **hop** (a small bounce) and **ears-up** (alert). They are input for the art-director, not decisions.
- The Miller, the wizard and the meadow friends may reuse the same reaction-table format and arbiter (§4) in their own presenters. Their tables belong to the narrative-director and their level's story tree. This doc specifies only the mascot.

### 3. Pip's reaction table (Meadow defaults)

Triggers are `SimEvent` kinds as they arrive in the `StagingHost` batch (ADR-0011 §7). Cooldown applies per row. Tiers are defined in §4.

| # | id | Trigger (event, condition) | Pose | Emote | Tier | Cooldown |
|---|---|---|---|---|---|---|
| 1 | `catch` | `mascot_catch {from_cells, to_cells, hold_ms}` (WO11) | catch (leap, carry back) | none | R0 | none (window) |
| 2 | `catch_spent` | `mascot_catch_spent {cells}` (WO11) | cover-eyes | `sweat` | R0 | none |
| 3 | `hint` | `mascot_hint {cell}` (WO06) | point, held until the next `piece_locked` | none | R0 | none |
| 4 | `won` | `level_result`, result WON | cheer | `sparkle` | R1 | none |
| 5 | `lost` | `level_result`, result LOST | stuck, ears drooped | `tear` | R1 | none |
| 6 | `big_clear` | `cells_cleared`, layers ≥ `big_clear_layers` (2) | cheer | `sparkle` | R2 | 0 ms |
| 7 | `flip` | `flip_applied` (EV03) | hang, then wobble | `dizzy` | R2 | 0 ms |
| 8 | `warning` | `phase_changed` → WARNING | ears-up, then cover-eyes | `exclaim` | R3 | `warning_cd_ms` 8000 |
| 9 | `gust_warn` | `gust_warn` (EV01) | ears-up, braced | `exclaim` | R3 | `gust_cd_ms` 6000 |
| 10 | `clear` | `cells_cleared`, 1 layer | hop | `heart` | R4 | `clear_cd_ms` 4000 |
| 11 | `recovered` | `phase_changed` WARNING → PLAYING | wipes brow | `sweat` | R4 | `recover_cd_ms` 8000 |
| 12 | `gust_hit` | `gust {moved: true}` | ears flat, huff | `angry` | R4 | `gust_cd_ms` 6000 |
| 13 | `bad_drop` | `piece_locked` with `holes_added` > 0 (see Dependencies, open question 1) | small flinch | `sweat` | R4 | `bad_drop_cd_ms` 10000 |
| 14 | `streak` | clean streak reaches `streak_n` locks (F4) | sways, humming | `note` | R5 | `streak_cd_ms` 15000 |
| 15 | `idle` | no `piece_locked` for `idle_ms` (12000) of play time | idle fidget (variant pool) | none | R5 | `idle_ms` |

- Every row with a bubble is paired with a pose, so its meaning never depends on the icon or its colour alone (`emote-bubbles.md` display defaults).
- Pip reacts to the player's play and never mocks it. No row uses a "told you so" pose. A bad drop gets a small flinch, never a sulk.
- Watcher levels (tier 4 on, `meadow.md`) use the same table. Rows 1–3 simply never fire, because the level JSON has no WO06/WO11 rule.
- Level overrides: an official level may disable rows or swap a pose or emote in its own presenter override (ADR-0011 §8), for example meadow_03 "seeds stick to Pip's face" on `gust_hit`. It may not add a gameplay effect.

### 4. Arbitration: priority, cooldowns, no spam

One **arbiter** per mascot presenter decides what plays. Tiers, highest first:

| Tier | Name | What | Can be interrupted by |
|---|---|---|---|
| R0 | Scripted | WO atom staging (catch, spent, hint) | nothing. A newer R0 waits (rule 4) |
| R1 | Outcome | won / lost | R0 only |
| R2 | Big moment | double clear, flip | R0, R1 |
| R3 | Warning | stack warning, gust telegraph | R0–R2 |
| R4 | Small | single clear, recovery, gust hit, bad drop | R0–R3, and a newer R4 after `min_hold_ms` |
| R5 | Ambient | streak hum, idle fidget | anything |

Rules:
1. **One reaction at a time** per mascot, and one bubble at a time. A new bubble replaces the old one (`emote-bubbles.md`).
2. **Coalesce per frame.** From one frame's event batch, the arbiter considers only the best candidate: the highest tier, then the latest in tick order. The others are dropped. This handles catch-up frames after a hitch.
3. **Accept rule** (F1). Lower-tier candidates are **dropped, never queued**, so the mascot never plays a backlog of stale reactions.
4. **R0 queue of one.** If an R0 arrives while another R0 is playing, it starts when the current one ends, provided its own window is still open. Otherwise it is dropped. Example: a `mascot_hint` for the returned piece after a catch shows once the catch ends.
5. **Cooldowns** (F2) start when a row *plays*, not when its event fires. A row on cooldown is not a candidate.
6. **Bubble cap** (F3). An R3–R5 reaction that would break the bubble cap still plays its pose, without the bubble. R0–R2 bubbles are never capped.
7. **Suppression.** While a skit owns the mascot (`StagingHost.play_skit`), or while the game is paused, the arbiter accepts nothing. Events in that time are dropped, not saved for later. After `level_result`, only R1 and the Results skit play.
8. **No repeats.** Rows with a variant pool (idle, hop) never pick the same variant twice in a row. Selection uses the host's cosmetic RNG, which is never replayed (ADR-0011 §7).

### 5. Timing

- **Onset**: a reaction starts on the frame the `StagingHost` hands over the event batch. Pose and bubble start together. Target ≤ 1 frame after the event reaches the presenter. This keeps it inside the 0.5 s micro-feedback window by a wide margin.
- **Pose length**: R1–R5 poses are at most `react_ms_max` (300 ms) of motion, then Pip eases back to idle. Holding a final frame (for example the end of a cheer) is idle time, not reaction time.
- **Bubble hold**: up to `bubble_hold_ms` (1000 ms, the cap from `emote-bubbles.md`), then a pop-out. The bubble may outlast the 300 ms pose.
- **R0 windows**: scripted reactions are not bound by 300 ms. They are bound by the event's own window: the catch plays inside `hold_ms` (WO11 `catch_ms`, default 300, range 0–600), and the hint holds until the next lock. `PlayAnimation` clamps to the window (ADR-0011 §6). The sim never waits for the mascot.
- **Frame time**: reactions run on frame time. A slow frame shortens a reaction and never stretches gameplay.

### 6. Reduced motion

Reduced motion follows the OS setting (decision sheet). It is read from the blackboard key `reduced_motion` (ADR-0011 §7).

| Normal | Reduced-motion variant |
|---|---|
| hop, cheer bounce | pose swap with a `rm_crossfade_ms` (120 ms) crossfade, no vertical travel |
| catch leap and carry (R0) | Pip fades to the spawn-side rim marker and holds the catch pose. The piece's return is shown by the board view as normal |
| flip hang and wobble | hang pose only, no wobble. `dizzy` bubble stays |
| bubble pop-in with bounce | bubble fades in over `rm_crossfade_ms`, no bounce (`emote-bubbles.md`) |
| idle fidget pool | only the subtle fidgets (blink, ear twitch); the bigger fidgets are off |
| cover-eyes, ears-up | unchanged (small motion) |

- Every reduced variant is at most as long as its normal version. Gameplay timing is unchanged, because the sim never sees the flag (TR-game-feel-vfx-005).
- If the setting changes mid-level, the reaction that is playing finishes as it is, and the next one uses the new variant.

### 7. Placement and the camera

- Pip stands on one of the level's **rim markers** (at least the 4 corner markers), never over the grid. Bubbles sit above his head, inside the safe area (ADR-0014) and clear of HUD elements (`hud.md`).
- After the camera snaps (ADR-0014 `view_changed`), Pip moves to the rim marker that is nearest the camera and not occluded by the stack. The move is a hop, or a fade under reduced motion. During free orbit, Pip stays where he is.
- If no marker is visible (an edge case on tall stacks), reactions still play, and the bubble is clamped to the nearest screen edge of the board's rim.

### 8. Sound

- A bubble fires `SFX_MASCOT_EMOTE_POP` through `EmitCue` (ADR-0015). That cue's own 300 ms cooldown and P4 priority mean it can never mask gameplay cues.
- Rows 1–2 use `SFX_PIP_CATCH` and `SFX_PIP_CATCH_RETURN` (`sfx-cue-list.md`). Critter voices are an open audio question (`sfx-cue-list.md` OQ 2). This system adds no voice cues until that is settled.

### 9. Modes

- **Campaign**: one mascot per board, the biome's mascot.
- **Local Wi-Fi versus / tournaments** (ADR-0009, one phone per player): each phone stages the mascot for its own player's board only. Rival boards shown as minis run with no presenter (ADR-0011 implementation guidelines). WO10 (mascot pick) and party mascots are later work and will need their own rows.
- **Daily challenge**: the generator's mascot role (WO06–WO09) picks which WO rule goes into the JSON. The reaction table is the biome mascot's.

## Formulas

### F1. Accept rule

```
accept(c) = not on_cooldown(c.row)
            and not suppressed
            and ( cur == none
                  or c.tier < cur.tier
                  or (c.tier == cur.tier == R4 and t_now - cur.t_start >= min_hold_ms) )
```
For R0 while an R0 plays, see §4 rule 4.

| Variable | Meaning | Range |
|---|---|---|
| `c.tier`, `cur.tier` | tier index, R0 = 0 … R5 = 5 (lower is higher priority) | 0–5 |
| `t_now`, `cur.t_start` | frame time (ms) now, and when the current reaction started | ≥ 0 |
| `min_hold_ms` | the shortest time an R4 plays before a newer R4 can replace it | 150–400, default 250 |
| `cur == none` | Pip is idle (the last reaction's pose and hold have ended) | — |

Example: a single clear (R4) starts at t = 0. A gust hits at t = 120 (R4): 120 < 250, so it is dropped. A double clear at t = 200 (R2): 2 < 4, so it is accepted at once.

### F2. Cooldown

```
on_cooldown(row) = (t_now - row.t_last_played) < row.cooldown_ms
```
`t_last_played` starts at −∞ on level start and on retry. Cooldowns use frame time and stop while paused (the host is `PROCESS_MODE_PAUSABLE`).

### F3. Bubble cap (R3–R5 only)

```
bubble_ok = (t_now - t_last_bubble) >= bubble_gap_ms
            and count(bubbles in the last bubble_window_ms) < bubble_max
```
Defaults: `bubble_gap_ms` 1500, `bubble_window_ms` 10000, `bubble_max` 4. R0–R2 bubbles count toward the window but are never blocked by it.

Worst-case check (a busy Meadow level with gusts, such as meadow_h1). Suppose a player clears a single every 2.5 s, holds a warning, and gusts arrive every 6 s. Row 10 plays at most every 4 s, row 9 every 6 s and row 8 every 8 s. That is 0.25 + 0.17 + 0.125 = 0.54 candidate bubbles per second, or about 5.4 per 10 s. The cap trims this to 4 per 10 s, one bubble every 2.5 s on average, and never two within 1.5 s. A calm player in meadow_01 sees about one bubble per clear (one every 30–40 s), plus the occasional hum.

### F4. Clean streak

```
streak = streak + 1        on piece_locked with holes_added == 0
streak = 0                 on piece_locked with holes_added > 0, on level start, on retry
fire row 14 when streak > 0 and streak mod streak_n == 0 (and not on cooldown)
```
Default `streak_n` 5. This is a staging-side count of events, like the boss-phase count in ADR-0011 §5. It is cosmetic and is never in the sim. If `holes_added` is not available (open question 1), rows 13 and 14 are disabled, not guessed.

### F5. Reaction length

```
d_pose   = min(anim_len, react_ms_max)                    (R1–R5)
d_pose   = min(anim_len, event.window_ms)                 (R0; window from the event, e.g. hold_ms)
d_rm     = min(d_rm_anim, d_pose)                         (reduced motion; never longer than normal)
d_bubble = min(bubble_anim_len, bubble_hold_ms)
```
Example: a cheer clip of 420 ms is cut to 300 ms of motion and then eases to idle. A catch with `hold_ms` 300 and a 360 ms leap clip plays at 360/300 = 1.2× speed, so the clip ends exactly when the piece is back at the spawn.

## Edge Cases

- **Several events in one frame** (a lock that clears two layers and ends the level): coalesce (§4 rule 2) picks `won` (R1). `big_clear` and `clear` are dropped, and their cooldowns do not start.
- **Catch-up after a hitch** (up to `max_catch_up_ticks` of events at once): same coalescing. Pip reacts once, to the most important event.
- **Outcome arrives during a reaction**: R1 interrupts at once. After `level_result`, only R1 and the Results skit play.
- **Catch while a reaction plays**: R0 interrupts anything. The interrupted reaction is not resumed.
- **Hint and catch in a row**: the hint is held until the catch ends (R0 queue of one). If its window closed (the piece locked), it is dropped.
- **`hold_ms` of 0** (WO11 `catch_ms` set to 0): the catch staging is skipped. Pip shows the catch pose for one frame and returns to idle, and `SFX_PIP_CATCH` still plays. The board view shows the return.
- **Pause**: the host is pausable, so the reaction and bubble freeze in place and cooldowns stop. On resume they continue. Nothing is replayed.
- **Retry** (`StagingHost.reset()`): reactions are interrupted, the bubble is cleared, cooldowns reset to −∞, streak resets to 0, and the Intro skit is skipped (ADR-0011).
- **App backgrounded mid-reaction**: same as pause (ADR-0010 pauses first).
- **Level with no presenter** (player-made JSON with no `view.scene`, versus minis): the level plays fully. No mascot, no errors.
- **WO rule present but no mascot presenter** in an official scene: the scene check warns (ADR-0011 §8). The rule still works, and the board view shows the catch and the hint highlight.
- **Emote not in the mascot's subset** (data error): load fails the data test. In a debug build at runtime, the bubble is skipped with one log line and the pose still plays.
- **`tear` outside a loss**: rejected by the data test for Pip (rules of use).
- **Pip occluded by the stack**: Pip moves after the snap (§7). If no rim marker is visible, the bubble is clamped to the screen edge and the pose plays where Pip stands.
- **Bubble would overlap the HUD or a notch**: it is pushed inside the safe area and away from HUD rects. It is never placed over the grid.
- **Reduced motion toggled mid-reaction**: the current reaction finishes, and the next uses the new variant.
- **Very fast player** (many clears in a row): cooldowns and the bubble cap hold the rate at ≤ 4 bubbles per 10 s (F3). R2 big clears still always show.
- **Very slow or stuck player**: the idle fidget plays at most every `idle_ms`, with no bubble, so Pip never nags. The warning row has its own 8 s cooldown.
- **Degenerate play**: none possible. Reactions have no gameplay effect, so they cannot be farmed or exploited. The only risk is annoyance, which F1–F3 and the "never mocks" rule address. Playtest AC 13 checks it.
- **Frame-rate differences between phones**: reactions run on frame time and the sim never waits for them. Replays with and without the mascot give the same `state_hash()` (AC 6).

## Dependencies

| System / doc | Direction | Contract |
|---|---|---|
| ADR-0011 mechanic and level-event runtime | ← | `StagingHost` batch (`events`, `latest`, `reduced_motion`), `StagingTree`, shared leaves (`OnEvent`, `PlayAnimation`, `EmitCue`), `play_skit`/`reset`. The forbidden list applies |
| Mechanics Module slot 14 (WO01–WO11) | ← | WO rules emit the events that rows 1–3 stage, with windows in event data. New WO atoms must add an event and a row here. `mechanics-module.md` Dependencies already lists this system |
| `meadow-candidate-atoms.md` WO11 | ← | `mascot_catch {from_cells, to_cells, hold_ms}`, `mascot_catch_spent {cells}`, `catch_ms` default 300 |
| Level Goals & Fail States | ← | `phase_changed` (WARNING in and out), `level_result` (WON/LOST). That GDD already lists Mascot Reactions downstream |
| Layer Clearing | ← | `cells_cleared` with the layer count |
| Fall, Drop & Lock | ← | `piece_locked`. **Needs** `holes_added` (int) in its data for rows 13–14 (open question 1) |
| Twist Library (EV01, EV03) | ← | `gust_warn`, `gust {moved}`, `flip_applied` |
| Game Feel & VFX | ↔ | Same event timing. The reaction tiers mirror its priority idea, and mascot motion obeys its reduced-motion rule 7. That GDD lists this system downstream |
| Audio (ADR-0015, `sfx-cue-list.md`) | → | `SFX_MASCOT_EMOTE_POP`, `SFX_PIP_CATCH`, `SFX_PIP_CATCH_RETURN` through `EmitCue` |
| Camera (ADR-0014) | ← | `view_changed` for rim-marker choice, safe-area rect for bubbles |
| HUD | ← | HUD rects to keep bubbles clear |
| Settings (ADR-0013) | ← | The reduced-motion flag (follows the OS) |
| `narrative/emote-bubbles.md`, `narrative/characters.md` | ← | Emote ids, meanings, display defaults, Pip's emote subset and poses |
| `design/levels/meadow.md` | ← | Pip's role per tier (helper 01–03, watcher from 04), per-level gags for presenter overrides |
| Characters & Perks | ↔ | Listed in the systems index as an upstream. The playable characters are not mascots. If a perk ever changes how the mascot behaves in play, it must be a WO rule, not a reaction |

## Tuning Knobs

All are presentation data in `assets/data/mascots/<id>.json` (not sim knobs, ADR-0011 §6). None changes gameplay.

| Knob | Range | Default | Category | Affects / rationale |
|---|---|---|---|---|
| `react_ms_max` | 150–400 | 300 | feel | Pose motion length. 300 ms reads at phone size without lingering |
| `bubble_hold_ms` | 500–1000 | 1000 | feel | Bubble readability. The cap comes from `emote-bubbles.md` |
| `min_hold_ms` | 150–400 | 250 | feel | How long an R4 plays before a newer R4 can replace it. Stops flicker |
| `rm_crossfade_ms` | 80–200 | 120 | feel | Reduced-motion pose swap and bubble fade |
| `bubble_gap_ms` | 1000–3000 | 1500 | gate | Minimum gap between capped bubbles |
| `bubble_window_ms` / `bubble_max` | 5000–20000 / 2–6 | 10000 / 4 | gate | The rolling bubble cap (F3) |
| `clear_cd_ms` | 2000–8000 | 4000 | gate | Single-clear hop rate. About every other clear in busy levels |
| `warning_cd_ms` | 4000–15000 | 8000 | gate | Stops warning ping-pong on a stack at the limit |
| `recover_cd_ms` | 4000–15000 | 8000 | gate | Same, for the relief row |
| `gust_cd_ms` | 3000–10000 | 6000 | gate | One brace or huff per gust cycle |
| `bad_drop_cd_ms` | 5000–20000 | 10000 | gate | Rare on purpose, so it never feels like scolding |
| `streak_n` | 3–10 | 5 | curve | Locks per hum |
| `streak_cd_ms` | 8000–30000 | 15000 | gate | Hum rate |
| `idle_ms` | 6000–20000 | 12000 | gate | Idle fidget gap |
| `big_clear_layers` | 2–3 | 2 | curve | What counts as a big moment |

## Acceptance Criteria

Functional ([U] unit with a fake event source and fake clock, [I] integration, [M] manual):

1. [U] Coalescing: a batch with `cells_cleared {layers: 2}` and `level_result WON` in one frame plays only `won`. `big_clear` does not start its cooldown.
2. [U] Accept rule (F1): R4 at t = 0, a second R4 at t = 120 is dropped, a third R4 at t = 260 replaces it, and an R2 at any time replaces an R4.
3. [U] Lower tiers are dropped, not queued: an R4 that arrives during an R2 never plays after the R2 ends.
4. [U] Cooldowns (F2): with `clear_cd_ms` 4000, single clears at 0, 2000 and 4100 ms play at 0 and 4100 only. Cooldowns do not advance while paused.
5. [U] Bubble cap (F3): with the defaults, a scripted flood of R3–R5 candidates yields at most 4 bubbles per 10 s and no two within 1500 ms. Poses still play without bubbles. R0–R2 bubbles are never blocked.
6. [I] Determinism (ADR-0011 §9): replaying meadow_02 and meadow_09 with the mascot presenter, without it, and with reduced motion on gives identical `SimEvent` lists and `state_hash()`.
7. [I] On `mascot_catch {hold_ms: 300}`, Pip's catch leaf starts on the same frame and ends no later than 300 ms of frame time. With `hold_ms` 0 the pose shows for one frame only.
8. [U] Layering: the mascot presenter's scripts contain none of the ADR-0011 §7 forbidden references (grep test).
9. [U] Data test: every emote in `pip.json` is in Pip's subset and in `emote-bubbles.md`. `tear` appears only on the `lost` row. Every row with a bubble names a pose.
10. [I] Retry: after `StagingHost.reset()`, no bubble is visible, all cooldowns are clear, and the streak is 0.
11. [M] Reduced motion on: no hop, bounce or wobble on any row. The catch is shown by fade. Each reaction lasts no longer than with it off. Screenshots of each reduced variant go in `production/qa/evidence/`.
12. [M] At all 12 snap angles and all 4 corner views in meadow_01, Pip and his bubbles never cover the grid, the HUD or a notch (screenshots in `production/qa/evidence/`).

Experiential (playtest, Meadow 01–05, 5+ testers):

13. ≥ 80% of testers say Pip "cheers me on". ≤ 10% call Pip annoying or distracting, and none says Pip blocked the view.
14. Shown a reaction clip with no sound, ≥ 80% of testers name the meaning of `heart`, `exclaim`, `sparkle` and `sweat` (pose plus icon).
15. ≥ 70% of testers notice the catch in meadow_01–03 and can say that Pip saved a bad drop.

## Open Questions

1. **`holes_added` in `piece_locked`**: rows 13 (bad drop) and 14 (streak) need the number of new covered holes a lock made. WO11 already computes this through `RuleApi.new_covered_holes`. The question is whether Fall, Drop & Lock should add it to the `piece_locked` event data (owner: that GDD and ADR-0001's event list). Until it does, rows 13–14 stay disabled. Staging must not compute holes from `SimReadout` itself, because that would put game logic in the view.
2. **Pip's `dots` emote**: `emote-bubbles.md` lists `dots` for Pip, but `characters.md` leaves it out of his subset. This doc follows `characters.md` (no `dots`) until the narrative-director decides.
3. **300 ms vs 1 s**: the brief's "≤ 300 ms" is read here as the pose motion. The bubble keeps the 1 s hold from `emote-bubbles.md`. Confirm this reading.
4. **Mascots for the other 9 biomes** (and whether the Miller-style rival per biome uses this arbiter): narrative-director and world-builder.
5. **Critter voices** (`sfx-cue-list.md` OQ 2): if approved, add a voice cue per row with its own cooldown.
6. **Systems index**: row #35 still says "Not Started" with no doc link, and its category is UI where its design order says Presentation. The index owner needs to update it (outside this brief).
