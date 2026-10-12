# ADR-0015: Audio and Feedback Pipeline

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user: one full music track per level, supplied by the user, no stems; haptics on Android and gamepad rumble on PC, both behind settings), engine-programmer (author); inputs from `design/gdd/audio/audio-direction.md` (audio-director) and `design/gdd/audio/sfx-cue-list.md` (sound-designer)

## Summary

All sound and haptics are presentation. They listen to the `SimEvent`s that `BoardController` re-emits (ADR-0001) and to UI and flow signals, and they never write to the sim. One `AudioDirector` node under `Main` owns the five buses (Master, Music, SFX, UI, Ambience), pooled players with voice limits, the music player and the haptics output. Every cue is a row of data keyed by its cue id (`assets/data/audio/cues.json`), and a data table maps event kinds to cue ids. Music is **one full OGG track per level**, picked by a track id in the level data and resolved through a music catalogue. The only adaptive treatment is bus effects (low-pass and volume ducking) for pause, danger and jingles. Haptics and rumble go through one `Haptics` service that a settings flag can switch off and that is rate-limited to one pulse per 50 ms.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Audio / Input (haptics) |
| **Layer** | Presentation (framework, `src/game/audio/`) |
| **Knowledge Risk** | MEDIUM. `modules/audio.md` reports no audio breaking changes in 4.4–4.6, and `breaking-changes.md` lists only `AudioStreamPlayer.area_mask` (3D only, not used) and the removal of `AudioEffectSpectrumAnalyzer.tap_back_pos` (not used). QOA import (4.3+), `AudioEffectHardLimiter` (4.3+), the `amplitude` argument of `Input.vibrate_handheld` and joypad rumble after the 4.5 input backend change are **not covered by `docs/engine-reference/godot/`** and are marked unverified below |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `modules/audio.md` (pooling pattern, bus API), `modules/input.md`; `design/gdd/audio/audio-direction.md` §2–4, §7–8 |
| **Post-Cutoff APIs Used** | None known. Everything named here existed in 4.3. The items below are unverified on 4.7.2 because the reference files do not cover them |
| **Verification Required** | (1) `AudioEffectCompressor.sidechain` (StringName bus) works and its cost on the reference phone is acceptable; else scripted tween duck. (2) `AudioEffectHardLimiter` exists in 4.7.2 (else `AudioEffectLimiter`, which may be deprecated). (3) WAV import option for QOA compression: exact `.import` key and value in 4.7.2. (4) OGG import: `loop` and `loop_offset` keys in 4.7.2. (5) `Input.vibrate_handheld(duration_ms, amplitude)`: signature on 4.7.2 and whether target phones honour amplitude; VIBRATE permission in the Android export preset. (6) `Input.start_joy_vibration(device, weak, strong, duration)` on an XInput pad and a PlayStation pad on Windows after the 4.5 joypad backend change. (7) An `AudioStreamPlayer` with `PROCESS_MODE_PAUSABLE` pauses and resumes its stream with `SceneTree.paused`. (8) Whether 4.7.2 exposes the OS reduced-motion setting (needed by ADR-0013, not by audio) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Accepted): events out of `BoardSim`, re-emitted by `BoardController`; ADR-0010 (Accepted): pause, backgrounding (`app_backgrounded`), Results; ADR-0005: level JSON schema (gains one optional field) |
| **Enables** | Every story that plays a cue or a haptic; HUD and menu sound; Meadow levels 01–10 and B audio pass; Settings audio and haptics rows |
| **Blocks** | GP-5 first playable sound (lock, clear, win, loss); Meadow MVP audio pass |
| **Ordering Note** | ADR-0013 (settings) owns persistence of volumes, the haptics flag and the reduced-motion flag; this ADR consumes a `FeedbackSettings` value and works with defaults until ADR-0013 lands. ADR-0012 (input) supplies the joypad device id that owns each board, which rumble needs. Audio values are **presentation data**, not sim knobs; they do not go into the ADR-0004 knob registry |

## Context

### Problem Statement

The audio direction and the cue list define 5 buses, a -16 LUFS target, voice limits, ducking, haptics and the full cue set, but nothing says who plays a cue, where cue data lives, how presentation hears the sim without touching it, or how haptics differ between a phone and a PC with a gamepad. The music plan in audio-direction §5 assumed stems. The user has since decided against stems: music is one full track per level, which the user supplies (Kevin MacLeod "Carefree" is a placeholder, CC-BY). The pipeline has to fit that decision.

### Constraints

- ADR-0001: the sim is pure and deterministic. Presentation reads events and never writes. Presentation randomness (pitch variation, variant pick) must never draw from the sim's RNG (ADR-0006).
- Modular layout: `game` may import every module except `levels`. `ui` may import only `core/model` value types and `SimEvents` constants, so UI cannot call `AudioDirector` by class name.
- Architecture principle 5: few autoloads. `Main` lives for the whole app, as in ADR-0010.
- Values are data. Every dB, ms, voice count and file path is a tunable default in a data file (audio-direction header).
- Android and PC ship together (decision sheet). Flagship phones are the target device, with the Mobile renderer.
- Player levels are untrusted (ADR-0005). They must never name a resource path.

### Requirements

- 5 buses and the default levels and effects from audio-direction §2; mix at -16 LUFS integrated, ≤ -1 dBTP.
- Every cue in `sfx-cue-list.md` is playable by its cue id; adding or tuning a cue is a data edit.
- Voice limits: SFX pool 12, UI 4, Ambience one-shots 2; same cue at most once per 50 ms and at most its `max_voices` copies; when voices run out, steal the lowest priority, then the oldest.
- One music track per level; title and island map share one track; crossfade on level entry; jingles duck the track; pause and danger apply a low-pass and a volume drop.
- Haptics on Android and gamepad rumble on PC, each off by setting, rate-limited to one pulse per 50 ms, fired on the same frame as its sound.
- Reduced motion does not change audio (cue list §1). Gameplay timing is the same with every feedback toggle.

## Decision

### 1. Who owns what

| Owner | Where | Owns |
|---|---|---|
| `AudioDirector` (Node, `PROCESS_MODE_ALWAYS`) | child of `Main` | bus setup at boot, `CueLibrary`, the three `VoicePool`s, `MusicDeck`, `AmbienceDeck`, `Haptics`, applying `FeedbackSettings` |
| `FeedbackRouter` (Node, `PROCESS_MODE_PAUSABLE`) | one per `BoardController` in `PlaySession` | connects to its controller's event signal, maps event kinds to cue ids through `EventCueMap`, calls `AudioDirector.play_cue()`; carries the board's owner (touch or joypad device id) for rumble |
| `MusicDirector` (Node) | in `PlaySession` | reads the level's track id at start, asks `MusicDeck` to crossfade, applies danger, pause, jingle and result rules from `assets/data/audio/music_rules.json` |
| UI screens | `src/ui/` | emit `feedback_requested(cue_id: StringName)` signals only; `AppFlow` connects them to `AudioDirector`. A generic tap needs nothing: `AudioDirector` hooks `BaseButton.pressed` through `SceneTree.node_added` and plays `SFX_UI_TAP` |

- Nothing in `core`, `data`, `mechanics` or `view` plays a sound. `mechanics` helper scenes that need a sound emit a cue id the same way UI does.
- **Exception — view-state presentation cues (amendment 2026-10-10).** A view node may *emit a cue id* (never play it) for a cue triggered purely by view state, e.g. `BoardCameraRig` emits `feedback_requested(&"SFX_CAM_SETTLE")` when a settle tween ends (ADR-0014). `AppFlow`/`PlaySession` connects it to `AudioDirector` as for UI. Such cues never come from sim state, never feed the sim, and are muted by nothing but the normal bus volumes.
- `AudioDirector` is not an autoload (same reasoning as ADR-0010 Alternative 5). Tests construct it with injected backends.

### 2. Buses

Saved as `res://default_bus_layout.tres`, built from audio-direction §2:

```text
Master    0 dB   HardLimiter (ceiling -1.0 dB)
 ├ Music  -6 dB  Compressor (sidechain SFX; -18 dB, 3:1, 10/300 ms) · LowPass (disabled)
 ├ SFX     0 dB  none
 ├ UI     -3 dB  none
 └ Ambience -12 dB Compressor (sidechain SFX) · LowPass (disabled)
```

- Effects are toggled with `AudioServer.set_bus_effect_enabled()` and tuned by writing the effect's properties; effects are never added or removed at runtime.
- Bus indices are looked up once at boot by name (`&"Music"` etc.) and cached. A missing bus is a boot error in debug and a logged warning in release.
- Sliders are 0–100 % from settings, mapped with `linear_to_db(value / 100.0)`; 0 % mutes the bus. Ambience has **no slider of its own; its volume follows the SFX slider** (amendment 2026-10-10, user decision; the Ambience bus keeps its own -12 dB trim and effects). Master has no slider.
- If verification item 1 fails, the sidechain compressors are removed from the layout and `MusicDeck.duck(db, attack_ms, release_ms)` runs a tree tween on the bus volume instead. The cue data marks which cues duck (`ducks_music_db`), so both paths read the same data.

### 3. Cue registry (data keyed by cue id)

`assets/data/audio/cues.json`, one entry per cue id from `sfx-cue-list.md` (`SFX_<AREA>_<THING>`). The cue list's table is the design source; the JSON is its machine form, and a test keeps them in step.

```json
{
  "schema_version": 1,
  "cues": {
    "SFX_PIECE_LOCK": {
      "bus": "SFX", "files": ["res://assets/audio/sfx/sfx_piece_lock_wood_01.wav"],
      "volume_db": -8.0, "pitch_st": 0.0, "random_st": 1.0, "variants": "random_no_repeat",
      "priority": 2, "max_voices": 2, "cooldown_ms": 50,
      "haptic": "medium", "ducks_music_db": 0.0, "loop": false, "gap": false
    }
  }
}
```

- Fields: `bus` (one of the 5), `files` (1+ paths; layered cues such as `SFX_GOAL_STAR_3` use `layers: [{file, volume_db, pitch_st}]` instead), `volume_db`, `pitch_st` (fixed offset in semitones), `random_st` (± semitones), `variants`, `priority` (1–5, P1 highest), `max_voices`, `cooldown_ms` (default 50), `haptic` (pattern id or `""`), `ducks_music_db`, `loop`, `gap`.
- A cue with `gap: true` and no temp file is valid data: it plays nothing and logs once in debug. This lets the list ship before every GAP is filled.
- `CueLibrary` (RefCounted, `src/game/audio/cue_library.gd`) parses the file once at boot through `JsonReader`, converts cue ids to dense int indices, and loads every stream. The SFX budget (≤ 8 MB) allows keeping all of them loaded; no per-play `load()`.
- **Event to cue map**: `assets/data/audio/event_cues.json` maps an event kind (`piece_moved`, `lock_thunk`, `layer_cleared`, `clear_resolved`, …) to a cue id, with two data selectors for the parameterised rows: `select_by` (an event data field and ranges, for example `n` 1, 2, 3, `4+` → `SFX_CLEAR_1..4`) and `pitch_by` (a field and a semitone table, for example ripple index → +0, +2, +4, +7, +9, cap +12). Per-level overrides (sticky levels swap land and lock for `SFX_PL_STICKY_SPLAT`, Pip's catch replaces the lock) are a `cue_overrides` map in the level's presentation data, never code.
- Pitch is applied as `pitch_scale = pow(2.0, semitones / 12.0)` on the pooled player. The random part comes from a presentation-only `RandomNumberGenerator` owned by `AudioDirector`, seeded once at boot; it never touches the sim's RNG.
- Intensity scaling (audio-direction §3 rule 5) reads the event's `I` value from the router: +0 to +3 dB and one pitch step per extra layer, capped by game-feel F1's `intensity_cap`. The mapping constants are in `cues.json` under `intensity`.

### 4. Voices and pooling

- Three `VoicePool`s, created at boot and never resized: SFX 12, UI 4, Ambience one-shots 2. Each holds pre-made `AudioStreamPlayer`s on its bus. Sizes are data (`cues.json` → `pools`).
- `play_cue(id)` does no allocation: index lookup, cooldown check against a `PackedInt64Array` of last-play times, a count of active copies per cue (`PackedInt32Array`), then a free player or a stolen one.
- Stealing: if the cue already has `max_voices` copies, the oldest copy restarts. Else if the pool is full, the playing voice with the lowest priority, then the oldest, is stopped; if every playing voice has higher priority than the new cue, the new cue is dropped.
- The clock for cooldowns and age is injected (`Callable` returning ms; default `Time.get_ticks_msec`), so tests are deterministic. This is presentation time; it never feeds the sim.
- Pause: SFX players are `PROCESS_MODE_PAUSABLE` and stop with the tree (verification item 7). UI players are `PROCESS_MODE_ALWAYS` so pause-menu clicks sound. Ambience pauses with the tree.
- Loops (`SFX_SP_FOG_GHOST`, ambience beds) return a `VoiceHandle` (int) and stop with `stop_voice(handle)`. A stale handle is a no-op.
- Two boards (ADR-0009 split screen) share the pools. Cooldowns are per cue, not per board, so two simultaneous locks do not double in volume.

### 5. Music: one full track per level

- **Music catalogue** `assets/data/audio/music.json`: track id → `{file, volume_db, loop_offset_s, credit}`. `credit` names an entry in `assets/data/credits.json`. Placeholder now: `meadow_theme` → Kevin MacLeod "Carefree" (CC-BY 4.0, credit line from `music-sourcing.md`), replaced by the user's tracks later by editing one row.
- **Level data**: level JSON gains one optional presentation field, `"music": "<track_id>"` (ADR-0005 schema addition). If it is absent, the biome's `default_music` in `assets/data/biomes/<biome>.json` is used. A track id is validated against the catalogue; player levels can only pick catalogue ids, never a path. An unknown id is a validator warning and falls back to the biome default, so a bad id never blocks play.
- Title and island map share one track id (`title_theme`) in `music_rules.json`, so moving between them does not restart it.
- `MusicDeck` holds two Music-bus players and crossfades between them (default 1 s, starting on Countdown, audio-direction §5.2). A third Music-bus player carries jingles and skit stingers.
- Adaptive treatment is bus effects only (`music_rules.json`, defaults from audio-direction §2 and §6):
  - **Pause**: Music LowPass on at 800 Hz and -6 dB over 0.2 s; off on resume. SFX and Ambience pause with the tree.
  - **Danger** (rescue levels only, `danger: true` per level): Music LowPass at a danger cutoff and a volume drop over 0.5 s, Ambience LowPass 1.5 kHz, plus `SFX_GOAL_DANGER`; off over 1.0 s when danger ends. Off in 05, 06 and B.
  - **Jingle or stinger**: Music to -12 dB over 150 ms, back over 400 ms.
  - **Flip drum hit**: Music -6 dB for 300 ms.
  - **Win / loss**: track fades out over 0.5 s, then the jingle.
  - **App backgrounded**: ADR-0010 calls `AudioDirector.set_backgrounded(true)`, which mutes Master; `false` restores it.
- All tweens are tree tweens with `TWEEN_PAUSE_PROCESS` (ADR-0010 rule), so the pause low-pass can animate while the tree is paused.
- `MusicDirector` reads `phase_changed`, `level_result`, the HUD danger state and the jingle cues. It takes its signal source by injection and is unit-tested with a fake source and a fake deck.
- **Interface kept open, not built**: `MusicDeck.play_track(id)` is the only entry point. If stems return later, a second deck implementation can sit behind the same call; nothing else changes. No stem code is written now.

### 6. Haptics and rumble

- `Haptics` (RefCounted, `src/game/audio/haptics.gd`) plays a pattern id (`tick`, `buzz`, `medium`, `strong`, `double`, `light`, `success`, `soft`, as named in the cue list) from `assets/data/audio/haptics.json`. Each pattern has an `android` list of pulses `[duration_ms, amplitude, gap_ms]` (defaults from audio-direction §8) and a `pad` list `[weak, strong, duration_s, gap_ms]`.
- Backends behind one interface, chosen at boot: `AndroidHaptics` (`Input.vibrate_handheld`, only when `OS.has_feature("android")`), `PadRumble` (`Input.start_joy_vibration` on the board owner's device id, PC only), and `NullHaptics` (headless, tests, and when the setting is off). GodotSteam is not used for rumble.
- Gates, in order: the `haptics` setting (off → `NullHaptics`, no call reaches the engine); rate limit of one pulse per 50 ms globally (pulses inside a pattern are scheduled from the pattern's own gaps); move/rotate ticks only if the separate `haptics_move_ticks` setting is on (default off, audio-direction §8).
- A cue's `haptic` field fires the pattern on the same frame as the sound. Haptics never replace a sound, and no sound or haptic carries information that is not also on screen.
- Clear haptics scale with game-feel F1 `I` (amplitude × `I`, capped at 1.0).
- Touch-only input on PC (rare) gets no haptic. A gamepad on Android (rare) gets rumble only if `pad_rumble_on_android` is true in `haptics.json` (default false).

### 7. Feedback settings

```gdscript
class_name FeedbackSettings extends RefCounted   ## filled by ADR-0013; defaults until then
var music_pct: int = 80
var sfx_pct: int = 100
var ui_pct: int = 100
var haptics: bool = true
var haptics_move_ticks: bool = false
var reduced_motion: bool = false   ## read by view/VFX; audio ignores it (cue list §1)
```

`AudioDirector.apply_settings(s)` sets bus volumes and swaps the haptics backend. It is called at boot and on every Settings change, so the slider preview (`SFX_UI_SLIDER`) plays at the new level.

### 8. Asset import settings

| Asset | Source | Import | Folder |
|---|---|---|---|
| Music tracks | OGG Vorbis, 44.1 kHz stereo, quality ~5 (~160 kbps), mixed to about -18 LUFS | OGG, `loop` on, `loop_offset` from the catalogue | `assets/audio/music/` |
| Jingles, skit stingers | OGG, same spec, about -16 LUFS short-term | OGG, `loop` off | `assets/audio/music/` |
| Short SFX (< ~5 s) | WAV 16-bit 44.1 kHz **mono**, peak -3 dBFS | WAV, **QOA** compression (verification item 3), loop off unless the cue is a loop | `assets/audio/sfx/`, `assets/audio/ui/` |
| Ambience beds | WAV source; long beds (> ~10 s) may be re-encoded to OGG to save size | loop on | `assets/audio/amb/` |

- Naming follows audio-direction §4 (`[category]_[context]_[name]_[variant].[ext]`).
- Budgets: music ≤ 25 MB, SFX ≤ 8 MB, ambience ≤ 4 MB. One full track per level means Meadow needs at most 12 tracks; reusing one Meadow track across levels (the plan) keeps this far under budget.
- The cue list currently points into `res://Sound FX Starter Pack Vol. 1/`. Paths live only in `cues.json`, so moving the chosen files into `assets/audio/` (cue list open question 6) is a data edit plus a `git mv`.
- `.import` files are committed. Every shipped audio file needs a `credits.json` entry (audio-direction AC 8).

### Architecture Diagram

```
BoardSim ──step()──▶ Array[SimEvent] ──▶ BoardController ──signals──▶ View / HUD
                                               │
                                               └──▶ FeedbackRouter (per board)
                                                      EventCueMap (event_cues.json)
                                                      │ play_cue(id, I, owner)
UI screens ── feedback_requested(cue) ──▶ AppFlow ──┐ ▼
BaseButton.pressed (node_added hook) ───────────▶ AudioDirector (under Main, ALWAYS)
                                                   ├ CueLibrary (cues.json)
                                                   ├ VoicePool SFX 12 · UI 4 · Amb 2
                                                   ├ MusicDeck (2 crossfade + 1 jingle) ◀── MusicDirector (PlaySession)
                                                   ├ AmbienceDeck                          level "music" id → music.json
                                                   └ Haptics → Android | PadRumble | Null
                                                         ▲ FeedbackSettings (ADR-0013)
Nothing on the right ever calls into BoardSim.
```

### Key Interfaces

```gdscript
# game/audio
class_name AudioDirector extends Node
## Example: audio.play_cue(&"SFX_PIECE_LOCK", 1.0, owner_id)
func play_cue(cue_id: StringName, intensity: float = 1.0, owner_id: int = -1) -> int  ## VoiceHandle or -1
func stop_voice(handle: int) -> void
func apply_settings(s: FeedbackSettings) -> void
func set_backgrounded(on: bool) -> void
func music() -> MusicDeck

class_name CueLibrary extends RefCounted
static func from_json(text: String) -> CueLibrary   ## errors collected, never thrown
func index_of(cue_id: StringName) -> int            ## -1 if unknown
func cue(index: int) -> CueDef

class_name VoicePool extends RefCounted
func _init(players: Array[AudioStreamPlayer], now_ms: Callable) -> void
func play(cue: CueDef, cue_index: int, pitch_scale: float, volume_db: float) -> int

class_name MusicDeck extends RefCounted
## Example: deck.play_track(&"meadow_theme", 1.0)
func play_track(track_id: StringName, fade_s: float) -> void
func set_filter(state: StringName) -> void          ## &"none" | &"pause" | &"danger"
func play_jingle(track_id: StringName) -> void      ## ducks the track per music_rules.json
func stop(fade_s: float) -> void

class_name Haptics extends RefCounted
## Example: haptics.play(&"medium", owner_id, 1.0)
func play(pattern: StringName, owner_id: int, intensity: float) -> void
func set_backend(b: HapticsBackend) -> void         ## Android | PadRumble | Null
```

### Implementation Guidelines

- Presentation must never write to `BoardSim`, queue a `SimCommand`, or read the sim RNG. Audio timing must never gate gameplay: no `await` on a sound in a sim-facing path, and sim timing is identical with sound, haptics or reduced motion on or off.
- Never `load()` or `AudioStreamPlayer.new()` while playing. Streams load at boot or in the level-load cover (ADR-0010); players are pre-created.
- Never hardcode a cue id string outside data and a `CueIds` constants file generated from `cues.json` (or a test that checks every `&"SFX_…"` literal in `src/` exists in `cues.json`).
- Never call `Input.vibrate_handheld` or `Input.start_joy_vibration` outside a `HapticsBackend`.
- Never set bus volume from screen code. Only `AudioDirector` touches `AudioServer`.
- Music track paths come only from `music.json`. Level data holds a track id, never a path.

## Alternatives Considered

### Alternative 1: Layered stems with `AudioStreamSynchronized` / `AudioStreamInteractive`
- **Description**: audio-direction §5.1 A and §7: one synchronized stream of stems per theme, layers faded per level and per event, clip switching for the +2 key change.
- **Pros**: per-level variety from one theme; danger, build and fog-reveal layers.
- **Cons**: needs rendered stems no one has produced; more APIs to verify on 4.7.2.
- **Rejection Reason**: User decision (2026-10-10): no stems, one full track per level. `MusicDeck.play_track()` stays the only entry point, so stems could be added behind it later.

### Alternative 2: `AudioDirector` as an autoload
- **Rejection Reason**: Breaks the few-autoloads principle. `Main` lives for the whole app (same as ADR-0010).

### Alternative 3: Cue logic in code (a `match` on event kind)
- **Pros**: simplest to write.
- **Cons**: every new mechanic or cue tweak is a code change; values hardcoded.
- **Rejection Reason**: Breaks the data-driven rule and the "tunable defaults" requirement.

### Alternative 4: Sound played by the view nodes that animate each event
- **Rejection Reason**: Spreads voice limits, priorities and haptics across many nodes; two boards and pause would each need handling in every node.

## Consequences

### Positive
- Sound designers tune and add cues in JSON without touching code; tests keep data and the cue list in step.
- The sim stays deterministic and replayable: sound and haptics are pure listeners.
- One place enforces voice limits, priorities, the 50 ms haptic rate limit and the settings.
- Swapping the placeholder music for the user's tracks is a catalogue edit.

### Negative
- Losing stems removes the per-level layer plan and the event layers in audio-direction §5.2 and §6 (W swell on gusts, Bu with tower height, G on fog reveal, +2 key change in 10, the faster 08 set, the B double-tick clip). They become low-pass and ducking only, or are dropped. **This is a deviation from the audio GDD**; the GDD must be updated.
- `TR-mechanics-module-008` (gravity and lock follow music BPM) cannot read audio; it needs a BPM in level knobs that matches the chosen track, set by hand.
- One more optional field in the level schema (ADR-0005).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Sidechain compressor costs too much on the phone | Low | Medium | Verification item 1; scripted tween duck from the same `ducks_music_db` data |
| `vibrate_handheld` amplitude ignored on some phones | Medium | Low | Patterns still differ by duration and count; device test |
| Rumble does not work on some PC pads after the 4.5 backend change | Medium | Low | Verification item 6; rumble is optional feedback, never information |
| Cue list and `cues.json` drift | Medium | Medium | Unit test compares cue ids in the markdown table with the JSON |
| Phone speakers hide cues under a dense full-mix track | Medium | Medium | Mix rule (700 Hz–4 kHz energy), sidechain duck, listening test AC on the reference phone |
| Placeholder "Carefree" ships by accident | Low | Medium | Credit entry present; release checklist item: replace or keep by user decision |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| game-concept.md (TR-game-concept-008) | Per-biome music plus layer-clear / item SFX driven by events | Level/biome music id → `music.json`; `FeedbackRouter` + `event_cues.json` |
| game-feel-vfx.md (TR-game-feel-vfx-001), audio part | Consume move/lock/clear/warning/item events from all systems | Router listens to `BoardController` signals; UI and mechanics emit cue ids |
| game-feel-vfx.md (TR-game-feel-vfx-005) | Global reduced-motion/haptics flags swap variants; gameplay timing unchanged | `FeedbackSettings`; haptics backend swap; audio ignores reduced motion; nothing gates timing |
| game-feel-vfx.md (TR-game-feel-vfx-006) | Haptic patterns, off by setting, 1 per 50 ms | `Haptics` + `haptics.json`, `NullHaptics` when off, global 50 ms gate |
| touch-controls.md (TR-touch-controls-003), haptics part | Haptics on gestures | Cue `haptic` field; `haptics_move_ticks` default off |
| touch-controls.md (TR-touch-controls-007), haptics part | Haptics and reduced motion persist | `FeedbackSettings` consumed here; persistence in ADR-0013 |
| obstacles.md (TR-obstacles-006) | Crack and break events reach audio | Event kinds mapped in `event_cues.json` |
| menus-level-select.md (TR-menus-level-select-006), audio part | Settings persist audio settings | Sliders → `apply_settings`; persistence in ADR-0013 |
| audio/audio-direction.md §2–4, §8 (no TR id yet) | 5 buses, ducking, voice limits, -16 LUFS, formats, haptics table | §2, §4, §5, §6, §8 above |
| audio/sfx-cue-list.md (no TR id yet) | Every cue by id, with bus, priority, voices, cooldown, haptic | `cues.json` keyed by cue id; `CueLibrary` |

## Performance Implications
- **CPU**: one id-to-index lookup and a few packed-array reads per cue, with no allocation; at most 18 one-shot voices plus 3 music and 2 ambience players mixing. Target < 0.3 ms main-thread per frame for the audio pipeline on the reference phone (to be measured; no number exists yet).
- **Memory**: all SFX loaded (≤ 8 MB budget, less with QOA); music streams from OGG, two tracks resident during a crossfade.
- **Load Time**: `CueLibrary` loads at boot behind the splash; the level's music track loads inside the ADR-0010 load cover.
- **Network**: none.

## Migration Plan

No audio code exists yet. Changes to other docs (not made by this ADR):
- `design/gdd/audio/audio-direction.md` §5–7: replace the stem plan with "one full track per level"; keep the bus-effect rules; mark the layer-only adaptive rules as dropped or filter-only.
- ADR-0005 / level schema: optional `music` field; `biomes/<biome>.json` gains `default_music`.
- `docs/architecture/tr-registry.yaml`: `/architecture-review` should append TR ids for `audio-direction` and `sfx-cue-list`, and point the TRs above at ADR-0015.
- `architecture.md`: add ADR-0015 to §3 and `src/game/audio/` to the layout.
- Android export preset: VIBRATE permission.
- `assets/data/credits.json`: entry for the placeholder track.

**Rollback plan**: the router and director are listeners; removing them leaves a silent but fully working game. Data files can be reverted independently.

## Validation Criteria

- [ ] [U] `CueLibrary`: parses `cues.json`; every cue id in `sfx-cue-list.md` tables exists in the JSON and vice versa; every non-gap file path exists; unknown fields are errors.
- [ ] [U] `VoicePool` (injected clock): same cue within 50 ms is dropped; a 4th copy of a `max_voices: 3` cue steals the oldest; a full pool steals lowest priority then oldest; a lower-priority cue never steals a higher one.
- [ ] [U] `FeedbackRouter` with a fake event source: `clear_resolved` n = 1, 2, 3, 6 → `SFX_CLEAR_1/2/3/4`; ripple index 0–6 → +0, +2, +4, +7, +9, +12, +12 st; a sticky level override replaces land and lock.
- [ ] [U] `Haptics`: setting off → zero backend calls in a full scripted level; two patterns 30 ms apart → the second is dropped.
- [ ] [U] Music resolver: level id → track; missing id → biome default; unknown id → warning + biome default; a path in the field is rejected.
- [ ] [U] Determinism: a replay of meadow_01 produces the same sim events with `AudioDirector` present and absent.
- [ ] [I] headless `tests/integration/audio/`: boot → meadow_01 → win plays lock, clear and win cues on the right buses, with the dummy audio driver.
- [ ] [M] Reference phone: 4-layer clear audible over the track at 50 % volume; 10-minute session at -16 LUFS ±2, no clipping (meter capture in `production/qa/evidence/`).
- [ ] [M] Android: haptics on and off; PC: rumble on an XInput pad, off by setting.
- [ ] [M] Pause applies the low-pass and resumes cleanly; danger filter in a rescue level and never in 05, 06, B; Music slider at 0 silences music and jingles but not SFX/UI/ambience; SFX slider at 0 silences SFX and ambience.

## Related
- ADR-0001 (events out, presentation listens), ADR-0005 (level `music` field), ADR-0006 (sim RNG untouched), ADR-0009 (two boards share pools), ADR-0010 (pause, backgrounding, load cover), ADR-0012 (device id for rumble), ADR-0013 (settings persistence)
- `design/gdd/audio/audio-direction.md`, `design/gdd/audio/sfx-cue-list.md`, `design/gdd/audio/music-sourcing.md`, `design/gdd/game-feel-vfx.md`, `design/gdd/touch-controls.md`
- `docs/engine-reference/godot/modules/audio.md`

## Amendment (2026-10-10)

Status unchanged (Accepted). Cross-doc fixes from `production/session-state/conflicts-open.md`:
- **View-state cue exception** (§1): view nodes may emit cue ids for cues triggered by view state only (e.g. `SFX_CAM_SETTLE`), never from sim state.
- **Ambience volume** follows the SFX slider (no own slider), §2.
