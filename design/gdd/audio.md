# Audio

> **Status**: In Design
> **Author**: Tessa + audio-director
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Variation Over Depth; Comeback Energy
> **Systems index**: #36 Audio (Presentation, Alpha)
> **Technical design**: `docs/architecture/adr-0015-audio-feedback-pipeline.md` (Proposed). This GDD holds the **design hooks** only: what must be heard, when, and why. How it is built (nodes, data files, pools, APIs) is the ADR's; where the two seem to disagree, the ADR is the technical truth and the mismatch is a bug in this file.
> **Detail docs**: `design/gdd/audio/audio-direction.md` (sound, mix, music, haptics) · `design/gdd/audio/sfx-cue-list.md` (every cue) · `design/gdd/audio/music-sourcing.md` (user-supplied tracks, licences)

## Summary

Audio is the ear's half of the feedback language: every move, lock, clear, warning and level event the other systems already send gets a short, toy-like sound on the same frame, and every level plays one full music track the user supplies. Sound never changes the game and never carries information the screen does not also show. The board is loud and the world is quiet: block sounds sit on top, music and ambience sit underneath and step back (duck or low-pass) whenever something matters.

> **Quick reference** — Layer: `Presentation` · Priority: `Alpha` · Key deps: `Layer Clearing, Items, Campaign Structure` · Tech: ADR-0015

## Overview

The Audio system turns sim events, UI actions and flow changes into sound and haptics. It owns five buses (Master, Music, SFX, UI, Ambience), a library of cues keyed by id, one music track per level, a handful of music treatments (crossfade, duck, pause and danger low-pass) and the haptic pairing for each cue. It serves *Readable Chaos* by keeping gameplay cues audible above everything and telegraphing every disturbance by ear, and *The Block Is the Constant* by giving the core block actions one sound family across every biome. Music is deliberately simple: **one full track per level, supplied by the user** (decision 2026-10-10); Kevin MacLeod's "Carefree" is a placeholder only. All values are tunable defaults.

## Player Fantasy

"My blocks are wooden toys and the whole meadow is cheering me on." Every action clicks, clacks or pops like a toy in the hand; big clears ring out bigger; a danger moment makes the music hold its breath but never turns scary; winning sounds like a small party. A player with the sound off still plays the same game, and a player with the sound on never has to strain to hear what matters.

## Detailed Design

### Core Rules

1. **Listen, never write.** Audio reacts to events from the board, UI and level flow. It never changes the board, queues a command, reads the sim's random numbers or delays gameplay. Turning sound, music or haptics off leaves the game identical (ADR-0015 Implementation Guidelines).
2. **Same frame.** A cue plays on the frame its event happens. Clears are not held back to land on the beat.
3. **Every cue has an id.** Every sound the game makes is a row in `sfx-cue-list.md` (`SFX_<AREA>_<THING>`, 79 rows at 2026-10-10). Adding or tuning a sound is a data change. A row marked GAP with no file is valid: it plays nothing until filled.
4. **Priority.** When sounds compete: (1) the piece, blocked bonk, danger and warning; (2) lock and clear; (3) event telegraphs; (4) items, mascot, extras; (5) music; (6) ambience. When voices run out, the lowest priority, then the oldest, is cut; a low-priority sound never cuts a higher one.
5. **Board loud, world quiet.** Gameplay cues carry energy in 700 Hz–4 kHz so they read on a phone speaker. Music and ambience duck under board sounds (sidechain), drop for jingles and skit stingers, and low-pass on pause and danger.
6. **Telegraph by ear.** Every disturbance that a level fires at the player (gust, flip, belt, fog, mushroom) has an audio warning before it acts, distinct from the others **by timbre**, not only volume.
7. **Rotation axes by ear.** Turn, Flip and Roll (code: spin, tilt, roll) each have their own cue, about 3 semitones apart, so the player can tell which axis they used without looking.
8. **One track per level.** A level names a track id or falls back to its biome's default. The title screen and island map share one track, so moving between them does not restart it. Entering a level crossfades into the level's track over 1 s, starting on the Countdown. There are no stems, layers, clip switches or key changes.
9. **Music adapts only by ducking and filtering.** Pause: low-pass + drop. Danger (rescue levels only): low-pass + drop. Jingles, stingers and the flip drum hit: short ducks. Win and loss: the track fades, then the result jingle.
10. **Haptics pair, never replace.** A cue may carry a haptic pattern that fires on the same frame. Haptics are off by a setting, rate-limited to one pulse per 50 ms, and the per-move ticks are a separate setting (default off). Android uses the phone motor; PC uses gamepad rumble.
11. **No voices.** Skits and characters are wordless. Instrument or wordless mouth-sound emotes are allowed.
12. **Reduced motion does not change audio.** Only the visuals change.
13. **Settings.** Sliders for Music, SFX and UI (0–100 %; 0 mutes). Ambience follows Music. Haptics on/off and move-tick haptics on/off. All persist per profile (Save & Profile, ADR-0013).
14. **Backgrounding.** When the app goes to the background, everything is muted; it returns on resume.
15. **Two boards** (local versus on one device, ADR-0009) share one mix: two locks at once do not play twice as loud.

### States and Transitions

The music side has one small state machine per play session; SFX are stateless per event.

| State | Entered when | Music | Ambience | Leaves to |
|---|---|---|---|---|
| **Menu** | title or island map shown | `title_theme` | none | Countdown (crossfade 1 s) |
| **Countdown** | level loaded, 3-2-1 | crossfading to the level track | crossfade 1 s to the level bed | Playing on Go |
| **Playing** | Go | level track, sidechain ducking live | level bed | Danger, Paused, Result |
| **Danger** | HUD danger state on, `topout_rule` rescue levels only | low-pass + drop (0.5 s in) | low-pass 1.5 kHz | Playing (1.0 s out), Paused, Result |
| **Paused** | pause menu | low-pass 800 Hz + -6 dB (0.2 s) | paused | the state it came from |
| **Result** | win or loss | fade out 0.5 s, then jingle | stops | Menu or Countdown (retry) |
| **Backgrounded** | app backgrounded (any state) | Master muted | muted | the state it came from |

### Interactions with Other Systems

| System | Direction | What passes |
|---|---|---|
| Movement & Rotation | → Audio | moved, rotated (with axis), kicked, blocked |
| Fall, Drop & Lock | → Audio | spawn, soft-drop tick, hard drop, land, lock, lock-resets-low |
| Layer Clearing | → Audio | per-layer clear (ripple index), clear resolved (layer count), settle, combo |
| Level Goals & Fail States | → Audio | countdown, go, danger on/off, warning, rescue, win, loss, star stamps |
| Items, Buffs & Debuffs | → Audio | collected, used, applied (cues added when items ship) |
| Level-Specific Mechanics, Twist Library, Obstacles | → Audio | each mechanic's telegraph and action events (gust, flip, fog, belt, mushroom, crack, break) |
| Camera & Rotate-View | → Audio | view settled on a snap after free orbit or a corner shortcut (`SFX_CAM_SETTLE`) |
| Menus & Level Select, HUD, Save & Profile UI | → Audio | button taps (automatic), back, toggles, sliders, island/node select, unlock, pause, profile select |
| Campaign Structure / Level Data | → Audio | the level's track id, biome default track, danger flag, per-level cue overrides (for example sticky levels swap land + lock for the splat) |
| Game Feel & VFX | ↔ Audio | shared event timing and intensity `I` (F1 there); haptic table |
| Settings (Save & Profile) | → Audio | volumes, haptics flags |
| Level Flow (ADR-0010) | → Audio | pause, backgrounded, load cover, results |

## Formulas

### F1. Slider to bus volume

`bus_db = 20 × log10(pct / 100)`; `pct = 0` → muted.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| pct | int | 0–100 | settings | Player slider value |

**Output range:** −∞ (muted) to 0 dB, added to the bus default level. **Example:** 50 % → −6.0 dB; 80 % (Music default) → −1.9 dB.

### F2. Clear intensity gain

`gain_db = intensity_gain_db_max × (I − 1) / (intensity_cap − 1)`, with `I` from game-feel-vfx F1 (`I = min(intensity_cap, 1 + intensity_step × (layers − 1))`).

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| I | float | 1–`intensity_cap` | game-feel-vfx F1 | Event size |
| intensity_cap | float | 1–3 (default 2) | game-feel-vfx | Same cap as VFX |
| intensity_gain_db_max | float | 0–6 (default 3) | `cues.json` → `intensity` | Extra loudness at the cap |

**Output range:** 0 to +3 dB. **Example:** 4-layer clear, `I` = 1.75 → 3 × 0.75 / 1 = **+2.25 dB**; 6 layers, `I` = 2 → +3 dB. (If `intensity_cap` is set to 1, the gain is 0.)

### F3. Pitch

`pitch_scale = 2^(semitones / 12)`, where `semitones = fixed_offset + ripple_step[index] + random(−random_st, +random_st)`.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| fixed_offset | float st | −12 to +12 | cue row | e.g. Turn +5, Flip +2, Roll −1 |
| ripple_step | table | +0, +2, +4, +7, +9, cap +12 | `event_cues.json` | Per-layer rise in a multi-layer clear |
| random_st | float st | 0–3 | cue row | Anti-fatigue variation; presentation RNG only |

**Example:** the third layer of a clear, no random part: +4 st → `2^(4/12)` = **1.26**.

### F4. Clear haptic strength

`amplitude = min(1.0, base_amplitude × I)`. **Example:** base 0.7, `I` 1.75 → 1.0 (capped); `I` 1.25 → 0.875.

## Edge Cases

- **If a cue row is a GAP with no file**: nothing plays, a debug log notes it once; gameplay is unaffected.
- **If a level names a track id that is not in the catalogue**: the level validator warns, the biome default plays, the level still starts.
- **If a level's `music` field holds a file path**: it is rejected by the validator (player levels must never name a path) and the biome default plays.
- **If the user has not supplied a track for a slot**: the slot falls back to the biome default (Meadow: the "Carefree" placeholder).
- **If 12 SFX voices are already playing**: the new cue steals the lowest-priority, then oldest voice; if every playing voice outranks it, the new cue is dropped.
- **If the same cue fires twice within 50 ms** (for example two boards lock on one frame): the second is dropped.
- **If danger turns on while paused**: the pause filter wins until resume; the danger filter then applies.
- **If danger is on when the level ends**: the danger filter clears as the track fades out; the result jingle plays clean.
- **If the danger state flickers on and off quickly**: `SFX_GOAL_DANGER` has a 5 s cooldown so it does not repeat; the filter follows the state with its fade times.
- **If the level is 05, 06 or B** (trim or out-of-pieces fail): no danger filter and no danger stinger.
- **If the phone is on silent or the OS volume is 0**: no special handling; haptics still follow the haptics setting.
- **If haptics are off**: no vibration or rumble reaches the engine anywhere.
- **If a gamepad is used on Android**: no rumble by default (`pad_rumble_on_android` false); touch on PC gets no haptic.
- **If the player orbits the camera continuously**: no sound while dragging; one settle cue on release.
- **If the app is backgrounded mid-jingle**: Master mutes; on resume the jingle is not replayed.
- **If the Music slider is 0**: music, jingles, stingers and ambience are silent; SFX and UI are not.

## Dependencies

**Upstream (Audio needs them):**
- Layer Clearing (Hard): clear events and layer counts.
- Items (Hard, later): item events; Meadow MVP ships without item cues.
- Campaign Structure / Level Data (Hard): track id, biome default, danger flag, cue overrides (ADR-0005 adds the optional `music` field).
- Movement & Rotation, Fall Drop & Lock, Level Goals & Fail States, Level-Specific Mechanics, Obstacles, Camera & Rotate-View, HUD, Menus & Level Select (Soft: event sources).
- Game Feel & VFX (Soft): intensity `I`, haptic vocabulary.
- Save & Profile / Settings (Hard: volumes and haptics persist; ADR-0013).
- Level Flow (Hard: pause, backgrounding, results; ADR-0010).

**Downstream (they need Audio):**
- Game Feel & VFX (Soft: paired sound and haptic timing).
- Menus & Level Select (Soft: settings rows preview at the new level).
- Mascot Reactions and skits (Soft: wordless stingers).

Bidirectional note: game-feel-vfx.md already lists Audio downstream. The event-source GDDs list their audio events in their Visual/Audio sections; the camera, save-profile and menus GDDs should add `SFX_CAM_SETTLE` and `SFX_UI_PROFILE_SELECT` to theirs.

## Tuning Knobs

All live in data (`assets/data/audio/*.json`, ADR-0015); none is a sim knob.

| Knob | Safe range | Default | Affects |
|---|---|---|---|
| Bus levels Music / SFX / UI / Ambience | −24 to 0 dB | −6 / 0 / −3 / −12 | Overall balance; board loud, world quiet |
| Sidechain duck threshold / ratio / attack / release | −30 to −10 dB / 2–6 : 1 / 5–30 ms / 150–600 ms | −18 / 3 / 10 / 300 | How much music steps back on clears and locks |
| Jingle duck depth / down / up | −18 to −6 dB / 50–300 ms / 200–800 ms | −12 / 150 / 400 | Results and skit stinger clarity |
| Pause low-pass cutoff / drop / fade | 400–2 000 Hz / −12 to 0 dB / 0.1–0.5 s | 800 / −6 / 0.2 | Pause feels "away" |
| Danger low-pass cutoff / drop / in / out | 1–4 kHz / −8 to 0 dB / 0.2–1.0 s / 0.5–2.0 s | 2 kHz / −4 / 0.5 / 1.0 | Tension without fear |
| Level crossfade | 0.5–2 s | 1 s | Smoothness of menu → level |
| Pool sizes SFX / UI / Ambience | 8–16 / 2–6 / 1–3 | 12 / 4 / 2 | Polyphony vs cost |
| Default cue cooldown | 30–100 ms | 50 ms | Machine-gun repeats |
| `intensity_gain_db_max` | 0–6 dB | 3 | F2: how much bigger a big clear sounds |
| `ripple_step` table | rising, cap ≤ +12 st | +0, +2, +4, +7, +9, +12 | F3: clear "climb" |
| Rotation offsets Turn / Flip / Roll | ≥ 2 st apart | +5 / +2 / −1 st | Telling axes apart by ear |
| Haptic rate limit | 30–100 ms | 50 ms | Buzz fatigue |
| Default volumes Music / SFX / UI | 0–100 % | 80 / 100 / 100 | First-run mix |
| `haptics_move_ticks` | on/off | off | Move/rotate/camera-settle ticks |
| Loudness target | −18 to −14 LUFS | −16 LUFS, ≤ −1 dBTP | Matches other mobile games |

## Visual/Audio Requirements

This GDD is the audio hub. The sound itself is specified in `audio-direction.md` (palette, mix, music slots, haptics) and `sfx-cue-list.md` (79 cues, gaps and temp files). Tracks come from the user via `music-sourcing.md`, which holds the licence and credit checklist.

## UI Requirements

Settings rows: Music, SFX, UI sliders (with live preview), Haptics toggle, Move-tick haptics toggle (Menus & Level Select, Onboarding & Accessibility). Credits screen lists every music and SFX credit from `credits.json`.

## Cross-References

ADR-0015 (pipeline), ADR-0001 (events out of the sim), ADR-0005 (level `music` field), ADR-0006 (sim RNG untouched), ADR-0009 (two boards share pools), ADR-0010 (pause, backgrounding), ADR-0012 (device id for rumble), ADR-0013 (settings persistence), ADR-0014 (camera rig, settle event); `game-feel-vfx.md`, `camera-rotate-view.md`, `movement-rotation.md`, `save-profile.md`, `design/levels/meadow.md`.

## Acceptance Criteria

1. [U] **GIVEN** a scripted replay of meadow_01, **WHEN** run with the audio system present and absent, **THEN** the sim events are identical.
2. [U] **GIVEN** every `SFX_` row in `sfx-cue-list.md`, **THEN** each id exists in `cues.json` and vice versa (79 ids at 2026-10-10).
3. [U] F1: 50 % → −6.0 dB (±0.1); 0 % → muted.
4. [U] F2: clears of 1, 4 and 6 layers → +0, +2.25 and +3.0 dB with defaults.
5. [U] F3: ripple index 0–6 → +0, +2, +4, +7, +9, +12, +12 st; Turn, Flip and Roll cues have different fixed offsets ≥ 2 st apart.
6. [U] **GIVEN** level data with `music` absent / unknown / a path, **THEN** the biome default plays (with a validator warning for unknown, and a rejection for a path).
7. [U] **GIVEN** the same cue twice 30 ms apart, **THEN** the second is dropped; **GIVEN** a full SFX pool, **THEN** a lower-priority cue never cuts a higher one.
8. [I] **GIVEN** boot → meadow_01 → win, **THEN** lock, clear and win cues play on the right buses and the title track crossfades into the level track on the Countdown.
9. [I] **GIVEN** a rescue level, **WHEN** danger turns on, **THEN** the music low-pass reaches its target within 0.5 s; **GIVEN** 05, 06 or B, **THEN** it never applies.
10. [I] **GIVEN** pause, **THEN** the music low-pass applies within 0.2 s and is fully removed on resume; gameplay SFX stop while paused and pause-menu clicks still sound.
11. [I] **GIVEN** haptics off, **THEN** no backend vibration or rumble call is made during a full level.
12. [I] **GIVEN** a camera free-orbit drag and release, **THEN** exactly one `SFX_CAM_SETTLE` plays, on the settle frame.
13. [M] **GIVEN** the reference phone at 50 % volume and the busiest supplied track, **THEN** a 4-layer clear is clearly audible (listening test, note in `production/qa/evidence/`).
14. [M] **GIVEN** a 10-minute session, **THEN** the mix measures −16 LUFS ±2 and never clips (meter capture in `production/qa/evidence/`).
15. [M] **GIVEN** a playtest of meadow_02, **THEN** testers can name which of Turn, Flip and Roll they used by sound alone at least 2 times in 3 (sign that the axis cues differ enough).
16. [M] **GIVEN** a release build, **THEN** every shipped music and SFX file has a `credits.json` entry and the "Carefree" placeholder was replaced or kept by user decision.

## Open Questions

1. **Per-level tracks**: which Meadow levels get their own user-supplied track and which share `meadow_theme`? (User; default: all share.)
2. **Fourth slider for Ambience**, or keep it under Music (default)?
3. **Who emits the camera settle cue**: the camera rig (ADR-0014) needs a `feedback_requested(cue_id)` signal like UI; ADR-0015 §1 does not yet list `view`/camera as a cue emitter. Flagged.
4. **07 hushed music**: a per-level static low-pass would need a new `MusicDeck` filter state (ADR-0015); default is to ask the user for a quieter `meadow_07` instead.
5. **Music-synced gravity** (TR-mechanics-module-008): the tempo knob must be set by hand per track, so each user-supplied track needs its BPM noted in the catalogue or level data.
6. **Critter sounds** for Pip, chicks and the Miller (cue list §8 question 2).
