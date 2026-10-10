# SFX Cue List — Core Loop, UI, Meadow

> **Status**: Draft (sound-designer, 2026-10-10), awaiting audio-director review
> **Author**: Tessa + sound-designer
> **Governed by**: `design/gdd/audio/audio-direction.md` (audio-director; buses Master, Music, SFX, UI, Ambience). Where this list and that file disagree, that file wins and this list is updated.
> **Sources**: `design/levels/meadow.md`, `design/gdd/game-feel-vfx.md`, `design/gdd/fall-drop-lock.md`, `design/gdd/layer-clearing.md`, `design/gdd/movement-rotation.md`, `design/gdd/level-goals-fail-states.md`, `design/gdd/hud.md`, `design/gdd/menus-level-select.md`
> **Library**: `Sound FX Starter Pack Vol. 1/` (repo root, royalty-free; licence PDF in the folder)

**Every value here is a tunable default** (volume, pitch, voices, cooldowns, file picks). Files were matched **by name only**; every mapped file still needs an audition pass before it is final.

## 1. Conventions

- **Style**: cute toybox, soft. Wood, felt, rubber, bells, plucks. No gore, no guns, no horror textures; the Horror, Hollywood (except two wood/reward files) and Sci-Fi folders are deliberately unused.
- **Cue id**: `SFX_<AREA>_<THING>`. Areas: `PIECE`, `ROT`, `DROP`, `CLEAR`, `GOAL`, `UI`, `EV` (level event), `SP` (special piece), `PL` (physics/landing twist), `FT` (fail type), `BOSS`, `PIP`, `MASCOT`, `DUCK`, `AMB`. The GDDs' event names (`piece_moved`, `lock_thunk`, …) are the triggers.
- **File paths** are relative to the repo root (Godot: `res://` + the same path). "GAP — need …" means no usable file; "temp:" gives a stand-in until the GAP is filled.
- **Spatial**: all cues are 2D (non-positional `AudioStreamPlayer`): a phone with a fixed board gains nothing from attenuation. No min/max distance or rolloff.
- **Variations / pitch**: "±N st" = random pitch of N semitones each play (Godot `AudioStreamRandomizer.random_pitch` is a scale: ±1 st ≈ 1.06, ±2 st ≈ 1.12). "+N st" = fixed offset. Variants play as random-no-repeat.
- **Volume**: dB on the cue, before the bus. 0 dB = file as is.
- **Priority** mirrors Game Feel & VFX rule 3: **P1** piece, ghost, danger → **P2** lock and clear → **P3** warnings and level events → **P4** items, mascot, extras → **P5** ambience. When voices run out, the lowest priority, then the oldest, is stolen.
- **Haptics** follow the Game Feel & VFX table and its 50 ms rate limit; off by setting. Names: `tick` (light tick), `buzz` (short buzz), `medium`, `strong`, `double`, `light`, `success`, `soft` (soft pattern), `—` none.
- **Reduced motion** does not change audio.

## 2. Core loop

| Cue id | Trigger | Bus | File | Variations / pitch | dB | Prio / voices | Haptic | Notes |
|---|---|---|---|---|---|---|---|---|
| SFX_PIECE_SPAWN | `spawn()` succeeds | SFX | GAP — need soft "plip" raindrop/felt pop (the block drizzle), 3 variants | ±1 st | -16 | P2 / 1 | — | Plays every piece, so it must be very quiet and short (< 150 ms) |
| SFX_PIECE_MOVE | `piece_moved` | SFX | `Sound FX Starter Pack Vol. 1/UI & Menus/Hover Over.wav` | ±2 st | -14 | P1 / 2 | tick (optional) | Soft click; same frame as the move |
| SFX_ROT_TURN | `piece_rotated`, spin axis | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Weapon Whoosh.wav` | +5 st, ±1 st | -12 | P1 / 2 | tick (optional) | Trim to 120 ms to match the turn |
| SFX_ROT_FLIP | `piece_rotated`, tilt or roll axis | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Weapon Whoosh.wav` | +2 st, ±1 st | -12 | P1 / 2 | tick (optional) | Lower than Turn so the axes are told apart by ear; a dedicated "tumble" whoosh would be better |
| SFX_ROT_KICK | `piece_kicked` | SFX | the Turn/Flip cue + `Sound FX Starter Pack Vol. 1/Retro/Slide.wav` | Slide +4 st | -16 (Slide layer) | P1 / 1 | tick | Short scrape layered on the rotation whoosh |
| SFX_PIECE_BLOCKED | `move_blocked`, `rotate_blocked` | SFX | `Sound FX Starter Pack Vol. 1/Retro/Path Blocked.wav` | ±1 st | -10 | P1 / 1, cooldown 80 ms | buzz | Dull bonk; a `Disabled` rotation plays nothing |
| SFX_DROP_SOFT_TICK | `soft_drop_tick`, per cell | SFX | `Sound FX Starter Pack Vol. 1/Community Requests/Abacus.wav` | slice one bead click; ±2 st | -20 | P2 / 2, cooldown 50 ms | — | FDL: "no sound loop, a soft tick per cell at most" |
| SFX_DROP_HARD | `hard_drop_whoosh` | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Weapon Whoosh.wav` | -3 st, ±1 st | -10 | P2 / 1 | — | ≤ 100 ms, matching the streaks; haptic comes on the lock |
| SFX_PIECE_LAND | `piece_landed` (first rest) | SFX | GAP — need soft felt squash/puff, 3 variants | ±1 st | -14 | P2 / 1 | — | Plays once per first rest, not on every re-rest |
| SFX_PIECE_LOCK | `lock_thunk` | SFX | GAP — need wooden toy-block clack, 4 variants. temp: `Sound FX Starter Pack Vol. 1/Medieval/Shield Block.wav` | ±1 st | -8 (hard-drop lock -6) | P2 / 2 | medium | Same frame as the lock; hard-drop lock adds the camera punch, +2 dB |
| SFX_PIECE_LOCK_BIG | lock of a Big Cube (05, bonus) | SFX | same as SFX_PIECE_LOCK | -5 st | -5 | P2 / 1 | strong | The meadow's "Big Cube thunk" |
| SFX_LOCK_RESETS_LOW | `lock_resets_low` | SFX | `Sound FX Starter Pack Vol. 1/UI & Menus/Notification.wav` | +3 st | -18 | P1 / 1 | — | Soft warning when the lock ring turns warm |
| SFX_CLEAR_LAYER | `layer_cleared`, per layer | SFX | `Sound FX Starter Pack Vol. 1/Retro/Success.wav` | +0, +2, +4, +7, +9 st by ripple index (cap +12) | -8 | P2 / 4 | strong (per layer) | Rising pitch bottom to top (Layer Clearing); one play per layer at `clear_stagger_ms` |
| SFX_CLEAR_1 | `clear_resolved`, n = 1 | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Loot Gold.wav` | ±1 st | -10 | P2 / 1 | — | Final chord; grows with n |
| SFX_CLEAR_2 | `clear_resolved`, n = 2 | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Power Up.wav` | — | -8 | P2 / 1 | — | |
| SFX_CLEAR_3 | `clear_resolved`, n = 3 | SFX | `Sound FX Starter Pack Vol. 1/Retro/Power Up.wav` + SFX_CLEAR_2 layer | — | -7 | P2 / 1 | — | |
| SFX_CLEAR_4 | `clear_resolved`, n ≥ 4 | SFX | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Milestone.wav` | — | -6 | P2 / 1 | — | Biggest; n > 4 reuses it (intensity cap) |
| SFX_CLEAR_SETTLE | `settle_thunk` | SFX | same as SFX_PIECE_LOCK | -3 st | -14 | P2 / 1 | — | Skipped when nothing sits above |
| SFX_CLEAR_COMBO | combo step (CO01; see open question 3) | SFX | `Sound FX Starter Pack Vol. 1/Retro/Combo.wav` | +1 st per combo step, cap +6 | -8 | P2 / 1 | light | Plays after SFX_CLEAR_n |
| SFX_GOAL_COUNTDOWN | `countdown_tick` (3-2-1) | SFX | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Count Down.wav` | — | -8 | P2 / 1 | — | Check length against `countdown_ms` 3 000; slice into 3 ticks if needed |
| SFX_GOAL_GO | `go` (first spawn) | SFX | `Sound FX Starter Pack Vol. 1/Retro/Start.wav` | — | -8 | P2 / 1 | light | |
| SFX_GOAL_DANGER | HUD danger state turns on | SFX | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Health Low.wav` | — | -10 | P1 / 1, cooldown 5 s | light | Only on `topout_rule` rescue levels (meadow §9); not on trim levels 05/06 |
| SFX_GOAL_WARNING | `warning` (top-out with a warning left) | SFX | `Sound FX Starter Pack Vol. 1/Retro/Fail.wav` | — | -10 | P1 / 1 | double | Funny, not harsh |
| SFX_GOAL_TOKEN_POP | HUD warning token breaks | SFX | GAP — need soft pop (pop family, §6) | ±2 st | -12 | P3 / 1 | — | |
| SFX_GOAL_RESCUE | `rescue_wipe` | SFX | `Sound FX Starter Pack Vol. 1/Magic/Holy Healing.wav` | — | -10 | P3 / 1 | — | Calm second chance; silent wipe in logic, not in sound |
| SFX_GOAL_WIN | `goal_met` | SFX | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Success.wav` | — | -6 | P1 / 1 | success | Jingle; bus may move to Music (open question 5) |
| SFX_GOAL_LOSE | `level_lost` | SFX | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Fail.wav` | — | -8 | P1 / 1 | soft | "Game Over.wav" judged too heavy for the tone |
| SFX_GOAL_STAR_1 | result screen, star 1 lands | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Achievement.wav` | +0 st | -8 | P2 / 1 | light | Stars play 300 ms apart |
| SFX_GOAL_STAR_2 | star 2 lands | UI | same | +3 st | -8 | P2 / 1 | light | |
| SFX_GOAL_STAR_3 | star 3 lands | UI | same + `Sound FX Starter Pack Vol. 1/Community Requests/Firework.wav` | +7 st; Firework -16 | -7 | P2 / 2 | medium | Audition the firework: cut if too loud |

## 3. UI

| Cue id | Trigger | Bus | File | Variations / pitch | dB | Prio / voices | Haptic | Notes |
|---|---|---|---|---|---|---|---|---|
| SFX_UI_TAP | any button tap; HUD pause and rule-icon taps | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Click Bounce.wav` | ±1 st | -10 | P2 / 2 | — | The HUD's only own sound (HUD V/A) |
| SFX_UI_BACK | back button, Android back | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Quit Out.wav` | — | -10 | P2 / 1 | — | |
| SFX_UI_TOGGLE | settings toggle on / off | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Equip.wav` | on +2 st, off -2 st | -10 | P2 / 1 | tick | |
| SFX_UI_SLIDER | slider step | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Scroll.wav` | pitch follows value, -3 to +5 st | -14 | P2 / 1, cooldown 60 ms | — | The effects-volume slider previews at the new level |
| SFX_UI_ISLAND_SELECT | world-map island tapped | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Map.wav` | — | -8 | P2 / 1 | light | |
| SFX_UI_NODE_SELECT | level node tapped (Intro card opens) | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Select.wav` | ±1 st | -10 | P2 / 1 | — | |
| SFX_UI_PLAY | Play on the Intro card | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Start.wav` | — | -8 | P2 / 1 | light | |
| SFX_UI_LOCKED | tap on a locked island or node | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Error.wav` | — | -12 | P2 / 1, cooldown 300 ms | buzz | Gentle "nope", not an alarm |
| SFX_UI_UNLOCK | island or node unlocks | UI | `Sound FX Starter Pack Vol. 1/Jingles & Stingers/Area Discovered.wav` | — | -8 | P2 / 1 | success | "A chime on unlocks" (Menus V/A) |
| SFX_UI_PAUSE | pause menu opens | UI | `Sound FX Starter Pack Vol. 1/UI & Menus/Inventory.wav` | — | -12 | P2 / 1 | — | Gameplay SFX pause with the game |

## 4. Meadow events, special pieces and characters

| Cue id | Trigger | Bus | File | Variations / pitch | dB | Prio / voices | Haptic | Notes |
|---|---|---|---|---|---|---|---|---|
| SFX_EV_GUST_TELEGRAPH | Dandelion Gust warning starts (1 s before, grass bends) | SFX | `Sound FX Starter Pack Vol. 1/Environment/Wind Loop.wav` | 1 s slice, fade in over the warning | -14 → -8 | P3 / 1 | — | The ear's half of the arrow telegraph; 03, 10, H1 |
| SFX_EV_GUST | gust pushes the piece | SFX | `Sound FX Starter Pack Vol. 1/Magic/Air Attack.wav` | ±2 st | -8 | P3 / 1 | light | Cuts the telegraph tail |
| SFX_SP_PUFF_SPLIT | dandelion puff lands and splits | SFX | GAP — need soft "pff" + seed scatter. temp: `Sound FX Starter Pack Vol. 1/Magic/Air Attack.wav` | temp +7 st, ±1 st | -12 | P3 / 1 | light | The two halves then use normal land/lock |
| SFX_EV_MUSHROOM_SPARKLE | sparkle marks the next mushroom cell (one lock ahead) | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Weapon Upgrade.wav` | +5 st | -16 | P3 / 1 | — | Audition: must read as twinkle, not metal |
| SFX_EV_MUSHROOM_POP | mushroom pops up | SFX | GAP — need squeaky rubber pop (meadow §6 "pops up with a squeak"), 3 variants. temp: `Sound FX Starter Pack Vol. 1/Retro/Jump.wav` | ±2 st | -10 | P3 / 1 | light | 04, H2 |
| SFX_EV_POND_SPLASH | layer clear in 04 | SFX | `Sound FX Starter Pack Vol. 1/Magic/Water Attack.wav` | ±1 st | -14 | P4 / 1 | — | Layered under SFX_CLEAR_n; the meadow's "big moment" in 04 |
| SFX_PL_WOBBLE_CREAK | wobble count rises (new overhang cube) | SFX | GAP — need wooden tower creak, 3 variants. temp: `Sound FX Starter Pack Vol. 1/Steampunk/Crack Turn.wav` | ±1 st | -18 + 10 × (wobble / `wobble_max`) | P3 / 1, cooldown 500 ms | — | Louder as sway grows; 05 only |
| SFX_PL_WOBBLE_SLIP | piece slips one cell at `wobble_max` | SFX | `Sound FX Starter Pack Vol. 1/Retro/Slide.wav` | ±1 st | -8 | P3 / 1 | buzz | If it pops off, SFX_FT_TRIM_POP follows |
| SFX_FT_TRIM_POP | each cube trimmed above the limit (05, 06, bonus) | SFX | GAP — need popcorn pop (pop family, §6) | ±3 st | -10 | P3 / 4, 40 ms stagger | light (once per trim) | "Cubes bounce off like popcorn" |
| SFX_SP_SPROUT_GROW | sprout grows one cube (06, H1) | SFX | `Sound FX Starter Pack Vol. 1/Retro/Heal.wav` | +5 st, ±1 st | -12 | P3 / 2 | light | |
| SFX_EV_FOG_ROLL | fog starts fading the stack (1 s fade) | SFX | `Sound FX Starter Pack Vol. 1/Environment/Wind Loop.wav` | 1.2 s slice, low-pass ~800 Hz, fade in/out | -16 | P3 / 1 | — | Hushed; 07 |
| SFX_EV_FOG_REVEAL | clear blows the fog away (0.6 s reveal) | SFX | `Sound FX Starter Pack Vol. 1/Magic/Air Attack.wav` | +3 st | -10 | P3 / 1 | — | Layered with the clear |
| SFX_SP_FOG_GHOST | fog ghost piece active (loops while it is a ghost) | SFX | `Sound FX Starter Pack Vol. 1/Community Requests/Magic Effect Loop.wav` | loop | -22 | P3 / 1 | — | Stops on tap or lock |
| SFX_SP_FOG_GHOST_SOLID | ghost tapped solid | SFX | `Sound FX Starter Pack Vol. 1/Magic/Magic Seal.wav` | ±1 st | -10 | P3 / 1 | light | |
| SFX_PL_STICKY_SPLAT | sticky lock on first touch (08) | SFX | GAP — need gummy wet splat, 3 variants. temp: `Sound FX Starter Pack Vol. 1/Magic/Water Attack.wav` | temp +5 st, ±1 st | -8 | P2 / 1 | medium | Replaces SFX_PIECE_LAND + SFX_PIECE_LOCK on sticky levels |
| SFX_EV_FLIP_WARN | Topsy Tumble 2 s warning starts | SFX | `Sound FX Starter Pack Vol. 1/Steampunk/Mechanism Loop.wav` | 2 s, pitch ramps 0 → +4 st | -12 | P3 / 1 | double (at start) | The Miller's lever ratchet; 09, 10 |
| SFX_EV_FLIP | the hill turns over (next Resolving) | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Weapon Whoosh.wav` | -7 st | -6 | P3 / 1 | — | A dedicated big tumble swoosh would be better |
| SFX_EV_FLIP_WHUMP | stack settles against the new floor | SFX | GAP — need soft cushion "whump". temp: `Sound FX Starter Pack Vol. 1/Community Requests/Hammer Fall.wav` | temp low-pass ~1 kHz | -10 | P2 / 1 | strong | "Lands on its head with a whump" |
| SFX_SP_EGG_HATCH | egg hatches after 6 locks | SFX | GAP — need eggshell crack + tiny peep, 2 variants | ±1 st | -10 | P3 / 2 | light | No library file fits |
| SFX_SP_CHICK_HOP | chick hops to a neighbour cell | SFX | `Sound FX Starter Pack Vol. 1/Retro/Jump.wav` | +7 st, ±1 st | -12 | P3 / 2 | — | |
| SFX_SP_EGG_BONUS | egg cleared before it hatches | SFX | `Sound FX Starter Pack Vol. 1/Medieval/Loot Gold.wav` | +4 st | -10 | P3 / 1 | light | Higher than SFX_CLEAR_1 so it reads as a bonus |
| SFX_EV_MILL_BELT | Mill Belt shifts the stack (every 2 locks) | SFX | `Sound FX Starter Pack Vol. 1/Steampunk/Automaton Move.wav` | ±1 st | -10 | P3 / 1 | light | 10 |
| SFX_BOSS_WINDUP_BELT | Miller pulls the belt lever (before a belt shift) | SFX | `Sound FX Starter Pack Vol. 1/Steampunk/Mechanism Open Close.wav` | ±1 st | -12 | P4 / 1 | — | |
| SFX_BOSS_WINDUP_SAIL | Miller spins the sails (gust telegraph in 10) | SFX | `Sound FX Starter Pack Vol. 1/Steampunk/Steampunk Wheel Activate.wav` | ±1 st | -12 | P4 / 1 | — | Plays with SFX_EV_GUST_TELEGRAPH |
| SFX_BOSS_WINDUP_LEVER | Miller hauls the giant lever (phase 2 flip) | SFX | `Sound FX Starter Pack Vol. 1/Steampunk/Automaton Activate.wav` | — | -8 | P3 / 1 | — | Then SFX_EV_FLIP_WARN |
| SFX_BOSS_SAIL_OFF | a clear knocks a sail off | SFX | `Sound FX Starter Pack Vol. 1/Hollywood/Wooden Crate Destruction.wav` | ±1 st | -10 | P3 / 1 | strong | The sail music sting is the audio-director's |
| SFX_BOSS_FLOUR_BONK | last clear bonks the Miller into flour | SFX | GAP — need cartoon bonk + flour poof. temp: `Sound FX Starter Pack Vol. 1/Medieval/Shield Block.wav` + `Sound FX Starter Pack Vol. 1/Magic/Air Attack.wav` | — | -6 | P3 / 1 | strong | The finale's big moment |
| SFX_PIP_CATCH | Pip leaps and catches the piece (WO11, ~300 ms) | SFX | `Sound FX Starter Pack Vol. 1/Retro/Jump.wav` | +3 st | -8 | P3 / 1 | light | Replaces the lock thunk for that lock |
| SFX_PIP_CATCH_RETURN | caught piece returns to spawn | SFX | `Sound FX Starter Pack Vol. 1/Retro/Slide.wav` | +5 st | -12 | P3 / 1 | — | |
| SFX_MASCOT_EMOTE_POP | emote bubble pops in over Pip or the Miller | SFX | GAP — need soft bubble pop (pop family, §6) | ±3 st | -14 | P4 / 2, cooldown 300 ms | — | Never louder than gameplay cues |
| SFX_DUCK_SQUEAK | rubber duck tapped (01, 02) | SFX | GAP — need rubber-duck squeak, 2 variants | ±1 st | -8 | P4 / 1 | light | |
| SFX_DUCK_COLLECT | duck collected | SFX | `Sound FX Starter Pack Vol. 1/Hollywood/Reward.wav` | — | -8 | P4 / 1 | success | Plays after the squeak |

## 5. Ambience (Ambience bus, P5)

| Cue id | Levels | File | dB | Notes |
|---|---|---|---|---|
| SFX_AMB_MEADOW | 01, 02, 04, 06, 08, 09, B, H1–H3 | `Sound FX Starter Pack Vol. 1/Environment/Grassy Field Loop.wav` | -22 | Base layer everywhere in the Meadow |
| SFX_AMB_HILL_WIND | 03, 05 (+ base) | `Sound FX Starter Pack Vol. 1/Environment/Wind Loop.wav` | -26 | 05 "a lot of sky" |
| SFX_AMB_FOG | 07 (base at -30) | `Sound FX Starter Pack Vol. 1/Environment/Dreamscape Loop.wav` | -26 | "Busy but hushed" |
| SFX_AMB_MILL | 10 (+ base) | `Sound FX Starter Pack Vol. 1/Steampunk/Giant Clock Interior Loop.wav` | -26 | Gentle mill clockwork; audition for tone |

Ambience crossfades over 1 s on level load and stops on the result screen. Pond and frog detail for 04 is not covered by the library and is optional.

## 6. Mixing and sourcing notes

- **Pop family**: SFX_GOAL_TOKEN_POP, SFX_FT_TRIM_POP, SFX_MASCOT_EMOTE_POP (and, with pitch, SFX_EV_MUSHROOM_POP and SFX_SP_PUFF_SPLIT) can share one set of about 8 soft pops. Sourcing one pop pack closes 3–5 gaps at once.
- **Wood family**: SFX_PIECE_LOCK, SFX_PIECE_LOCK_BIG, SFX_CLEAR_SETTLE and SFX_PL_WOBBLE_CREAK all want wooden toy-block sources. The lock clack is the single most-heard sound in the game and is the top-priority gap.
- **Skits**: payoff and intro skits reuse the event cues above; their stingers are music (audio-director). Meadow §9: no voices.
- **Proposed ducking**, for the audio-director to confirm in `audio-direction.md`: SFX_CLEAR_n and SFX_GOAL_WIN/LOSE duck Music -4 dB for 400 ms; SFX_GOAL_DANGER and SFX_GOAL_WARNING duck Ambience -6 dB while active.
- **Masking**: the gust (SFX_EV_GUST), fog cues and the wind ambience share the same broadband band; keep the wind ambience at least 12 dB under the gust cue in 03 and 10.
- **Shared files**: Weapon Whoosh (Turn, Flip, hard drop, Topsy Tumble) and Air Attack (gust, fog reveal, temps) carry several cues at different pitches. Fine for the prototype; replace with dedicated sounds if playtesters can't tell them apart.

## 7. Open questions

1. **Turn vs Flip**: is "Turn" the spin axis and "Flip" the tilt/roll axes (as assumed here), or does Flip mean something else?
2. **Voices**: do Pip, the chicks and the Miller make tiny critter sounds (squeak, peep, grumble), or does meadow §9's "never voices" rule out even those?
3. **Combo (CO01)**: what is a combo step: consecutive locks that each clear, or something else?
4. **Spawn sound**: wanted on every piece (quiet), or silent?
5. **Win/lose/countdown jingles**: SFX bus or Music bus? (Audio-director.)
6. **Library location**: keep using files in place at `res://Sound FX Starter Pack Vol. 1/`, or copy the chosen ones into `assets/audio/sfx/` and rename them?
