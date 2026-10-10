# Audio Direction: Wacky Towers (Meadow MVP)

> **Status**: Draft (Phase 1, Meadow MVP plan). Revised 2026-10-10: no stems, one full track per level
> **Author**: audio-director
> **Last Updated**: 2026-10-10
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Variation Over Depth; Comeback Energy
> **Sources**: `design/levels/meadow.md` §2, §6, §9 · `design/gdd/game-feel-vfx.md` (vocabulary, haptics) · `design/art/art-bible.md` §1–2 · `production/levels/meadow/world-and-scenes.md` §3 A1–A3 · `production/orchestration/meadow-mvp-plan.md` (decisions)
> **Technical truth**: `docs/architecture/adr-0015-audio-feedback-pipeline.md` (buses, cue registry, music catalogue, haptics). Where this file and ADR-0015 disagree on *how*, the ADR wins; this file owns *what it should sound like*.
> **Companions**: `design/gdd/audio.md` (Audio system GDD) · `design/gdd/audio/sfx-cue-list.md` (sound-designer: every SFX event, owns cue names) · `design/gdd/audio/music-sourcing.md` (user-supplied tracks, licences, credits)

**Every number here is a tunable default** (dB, ms, LUFS, sizes). Change it in the data file, not in code.

---

## 1. Sonic identity

**The rule, borrowed from the art bible: the board is loud, the world is quiet.** Block sounds are the toys and get the brightest, closest, driest sound in the mix. Music and ambience are the box they came in: soft, warm, a little distant.

| Axis | Choice |
|---|---|
| Acoustic vs synthetic | Acoustic toys. Wood, felt, plastic, glass marbles. No synth leads; soft synth pads only as glue |
| Clean vs distorted | Clean, rounded transients. Nothing harsh above about 6 kHz |
| Sparse vs dense | Sparse by default; density is the intensity lever on the **SFX** side (cue layers add, never replace). Music density is whatever the supplied track has |
| Music | **Toybox folk** (user decision): ukulele, glockenspiel, pizzicato strings, light percussion (shaker, woodblock, brushed kit, a soft kick). This is the brief for the tracks the user supplies |
| Voices | **None.** Skits are wordless. Emote stingers (a squeak, a gasp, a "hmph" made from an instrument or a soft mouth sound with no words) are allowed |
| Spatial | Board SFX are 2D, centred. The 3D diorama is not spatialised in the MVP (phones are effectively mono; spatial cues would be lost) |

**Reference feel (mood, not a spec):** Animal Crossing (warm acoustic folk under play), Tetris Effect (clears that feel musical), Yoshi's Crafted World (toy materials as sound), Puyo Puyo (big, cheerful clear chains).

### Pillar check

| Pillar | What audio contributes | Gap / risk |
|---|---|---|
| **The Block Is the Constant** | One shared block-sound family (move tick, Turn/Flip/Roll whooshes, land, lock, clear) across every biome; biomes only re-skin the *material* layer (Meadow = wood and felt) | Keep the core cues identical across biomes so muscle memory transfers. sound-designer owns the family |
| **Readable Chaos** | Mix priority (§3) keeps board cues on top; every disturbance has an audio telegraph before it fires (gust whoosh-in, flip warning tick, mushroom sparkle chime) | Telegraphs must be distinct by timbre, not just volume. A dense full-mix track can hide cues on a phone speaker; the sidechain duck (§2) and the 700 Hz–4 kHz rule (§3) are the guard, and the track brief asks for sparse arrangements (music-sourcing.md §1) |
| **Variation Over Depth** | Each level can name its own track (§5); the biome default covers any level without one | **Gap since the no-stems decision**: per-level variety now costs one track each. Until the user supplies tracks, every Meadow level plays the same placeholder. Variety must come from SFX, ambience and the level events |
| **Comeback Energy** | Rescue and warnings get a clear "you can save this" sting rather than a doom sound; the danger filter is tense but not sad | MVP is single-player; the versus item stingers come later. Nothing yet |

## 2. Godot bus layout

As built in ADR-0015 §2:

```text
Master  ── HardLimiter (ceiling -1.0 dB)
 ├─ Music      ── Compressor (sidechain: SFX) ── LowPass (off by default)
 ├─ SFX        ── (no effects; board cues stay dry and immediate)
 ├─ UI         ── (no effects)
 └─ Ambience   ── Compressor (sidechain: SFX) ── LowPass (off by default)
```

| Bus | Carries | Default level | Player slider |
|---|---|---|---|
| Master | everything | 0 dB | no (OS volume does this) |
| Music | level tracks, title/map track, results jingles, skit stingers | -6 dB | **Music** |
| SFX | board, events, Pip and the Miller reactions | 0 dB | **SFX** |
| UI | buttons, menus, star stamps | -3 dB | **UI** |
| Ambience | A1 bed, A3 one-shots | -12 dB | follows **Music** slider (MVP; no fourth slider) |

**Ducking and filter defaults** (these are the *only* adaptive music treatment, see §6)
- **Clears and locks duck music**: sidechain compressor on Music and Ambience keyed from SFX. Defaults: threshold -18 dB, ratio 3:1, attack 10 ms, release 300 ms (about -3 to -4 dB on a clear). **Verify** the `AudioEffectCompressor.sidechain` cost on the reference phone (ADR-0015 verification 1); fall back to a scripted tween duck driven by each cue's `ducks_music_db`.
- **Results jingle and skit stingers**: scripted duck, Music track to -12 dB over 150 ms, restore over 400 ms.
- **Pause**: Music LowPass on (cutoff 800 Hz) and -6 dB over 0.2 s; SFX and Ambience paused with the tree.
- **Danger** (rescue levels only): Music LowPass on (cutoff 2 kHz) and -4 dB over 0.5 s; Ambience LowPass 1.5 kHz.
- **App backgrounded** (ADR-0010 `app_backgrounded`): mute Master; restore on resume.

**Sliders** are 0–100 % stored in settings, mapped with `linear_to_db()`, 0 % = bus muted. Haptics is a separate on/off toggle (§8).

## 3. Mix rules

1. **Priority** (matches game-feel-vfx rule 3): (1) danger/warning cues, the piece's lock and blocked bonk; (2) layer clear; (3) event telegraphs (gust, flip, fog, belt); (4) Pip/Miller reactions, items; (5) music; (6) ambience.
2. **Voice limits** (polyphony): SFX pool 12 players; the same cue retriggers at most once per 50 ms and at most its `max_voices` copies at once (oldest stolen). UI pool 4. Ambience one-shots 2.
3. **Phone speakers**: the bottom of a phone speaker rolls off below about 200 Hz. Every important cue (lock, clear, flip drum hit, danger) carries energy in **700 Hz–4 kHz** so it reads on a speaker; sub-bass is a bonus for headphones only. Music is high-passed at 80 Hz.
4. **Mono-safe**: nothing gameplay-critical is panned. Music stereo width is fine but must sum to mono without losing the melody.
5. **Intensity scaling**: SFX gain on clears follows game-feel F1 (`I` = 1–2). Map `I` to +0 to +3 dB and one extra pitch-up step per extra layer, capped at F1's `intensity_cap`.
6. **Pitch variation**: repetitive cues (move tick, lock) get random pitch (±1–2 st per the cue list) so long sessions do not fatigue. The random draw is presentation-only and never touches the sim RNG (ADR-0015 §3).

## 4. Loudness and asset specs

| Item | Target |
|---|---|
| Overall game mix | **-16 LUFS integrated** (mobile norm), true peak ≤ **-1 dBTP** |
| Music tracks (as delivered) | each full mix at about -18 LUFS, so SFX sit 2–4 dB on top |
| SFX | peak-normalised to -3 dBFS; short cues judged by ear against the music, not by LUFS |
| Jingles | about -16 LUFS short-term |
| Music format | OGG Vorbis, 44.1 kHz stereo, quality about 5 (≈160 kbps), `loop` on, loop offset in the music catalogue |
| SFX format | WAV 16-bit 44.1 kHz **mono**; import as **QOA** compression (verify the 4.7.2 import key, ADR-0015 verification 3) |
| Size budget (MVP) | music ≤ 25 MB, SFX ≤ 8 MB, ambience ≤ 4 MB. At ~160 kbps a 2-minute loop is ~2.4 MB, so 12 Meadow tracks fit, but only just with jingles; a distinct track per level across all biomes needs a budget revisit |
| Naming | `[category]_[context]_[name]_[variant].[ext]`, for example `mus_meadow_theme_loop.ogg`, `mus_meadow_09_loop.ogg`, `mus_title_theme_loop.ogg`, `jgl_results_win_01.ogg`, `amb_meadow_bed_loop.ogg`, `stg_skit_surprise_01.ogg` |
| Folder | `assets/audio/music/`, `assets/audio/sfx/`, `assets/audio/amb/`, `assets/audio/ui/` |
| Credits | every shipped file gets a `credits.json` entry (`files` lists the exact asset paths); see music-sourcing.md |

## 5. Music plan: one full track per level

**User decision (2026-10-10): no stems.** Music is **one full mixed track per level**, **supplied by the user**. Kevin MacLeod "Carefree" (CC-BY 4.0) is the **placeholder only**, catalogued as `meadow_theme` until the user's tracks arrive. No layer, stem, clip-switching or key-change system is built.

### 5.1 How a level gets its track

1. The level JSON may name a track id: `"music": "<track_id>"` (ADR-0015 §5, ADR-0005 schema addition).
2. If it does not, the biome's `default_music` is used (Meadow: `meadow_theme`).
3. The track id resolves through the music catalogue `assets/data/audio/music.json` (`file`, `volume_db`, `loop_offset_s`, `credit`). Level data never holds a path.
4. Swapping the placeholder for a user track is a one-row catalogue edit.

### 5.2 Track slots for the Meadow (what the user is asked to supply)

| Slot (track id) | Used by | Brief for the user's track | Until supplied |
|---|---|---|---|
| `title_theme` | title screen and island map (shared, so moving between them does not restart it) | music-box feel: glock + soft uke, no drums, calm, loops cleanly | `meadow_theme` (Carefree) |
| `meadow_theme` | biome default: any Meadow level without its own id | toybox folk, cheerful, mid tempo, sparse enough that clears read over it | Carefree (placeholder) |
| `meadow_01` … `meadow_10` | optional per-level tracks | same family as `meadow_theme`; 07 should be the quietest, 09 and 10 the busiest | biome default |
| `meadow_bonus` | B Picnic Puzzle | hurried, ticking, playful | biome default |
| `jgl_results_win`, `jgl_results_win_3star`, `jgl_results_loss`, `jgl_meadow_complete` | results and the 10 payoff skit | win ≈3 s, 3-star ≈4 s, loss ≈2.5 s ("aw, one more go", never sad), Meadow complete ≈6 s | SFX-bus stings from the cue list (`SFX_GOAL_WIN`, `SFX_GOAL_LOSE`) |
| `stg_skit_*` (≈6) | wordless skits: surprise, sneaky (the Miller), oops, triumph, sulk, cheer | short one-shots, ideally in the key of the biome track | silent (skits still play their event SFX) |

Defaults: all Meadow levels point at the biome default, so the MVP ships with one track plus jingles even if no per-level track is supplied. Each extra per-level track is the user's call.

### 5.3 Per-level music treatment (bus effects only)

| Level | Track | Danger filter? | Ambience | Audio "moment" (SFX, not music) |
|---|---|---|---|---|
| 01 First Sprout | biome default | yes | bed (birds, bees) | each leaf = soft glock "grow" sting (SFX) |
| 02 Tilt & Roll | biome default | yes | bed, LowPass 3 kHz (underground) | snore one-shots on filled beds (SFX) |
| 03 Breezy Hill | biome default | yes | bed + breeze up | gust telegraph whoosh (SFX) |
| 04 Mushroom Ring | biome default | yes | bed + frogs (A3) | mushroom pop (SFX) |
| 05 Tall Tower | biome default | **no** (trim cannot lose) | bed, wind high | sign reached = jingle duck |
| 06 Flower Bed | biome default | **no** | bed + bees | each bloom stage = glock sparkle (SFX) |
| 07 Hide & Seek | biome default (user may supply a quieter `meadow_07`) | yes | bed quiet + owl (A3) | fog roll / reveal (SFX) |
| 08 Dewdrop | biome default (a faster track, if wanted, is a user-supplied `meadow_08`) | yes | bed, glitter shimmer | 150 s sun dial end = "pop free" sting |
| 09 Topsy-Turvy | biome default | yes | bed + bird fuss | **flip drum hit** (§6): the stack flips, the island stays |
| 10 Meadow Mill | biome default (or `meadow_10`) | yes | mill creak, flour puffs (A3) | each sail knocked off = short sting; flip drum hit at phase 2 |
| B Picnic Puzzle | `meadow_bonus` if supplied | **no** (out of pieces / clock) | picnic bed | — |
| H1–H3 | later (not MVP) | — | — | — |

**Dropped with the stems** (ADR-0015 Consequences): the W swell on gusts, the build layer following tower height in 05, the glock jump on fog reveal in 07, the +10 % tempo set in 08, the +2 semitone key change in 10 phase 2, the B double-tick clip switch, and the 07 static music low-pass. Their job moves to the SFX cues listed above. Entering a level crossfades from the title/map track over 1 s, starting on the Countdown.

## 6. Adaptive rules

Music adapts only through **low-pass and volume ducking** (ADR-0015 §5). Nothing switches clips, layers or keys.

| Trigger (game event) | Music / Ambience response | Timing |
|---|---|---|
| Level entry | crossfade title/map track → level track | 1 s, starts on the Countdown |
| Stack enters the danger zone (warning state), levels with `topout_rule` rescue only | Music LowPass 2 kHz and -4 dB; Ambience LowPass 1.5 kHz; one-shot `SFX_GOAL_DANGER` | 0.5 s; stinger immediate |
| Stack leaves danger | filters off, volume restored | 1.0 s |
| Rescue used | rescue sting (SFX); danger filter off | 1.0 s |
| Layer clear / lock | sidechain duck (§2); the clear SFX fires on the frame, not quantised to the beat (waiting costs feel) | immediate |
| Flip warning (09, 10) | ticking countdown (SFX), music unchanged | 2 s warning |
| **Flip** (09, 10) | **drum hit** on SFX (big tom + woodblock + cymbal swell, energy in 700 Hz–4 kHz); Music -6 dB for 300 ms, then back | on the flip frame |
| 10 sail knocked off (each clear) | sail sting (Music bus jingle player), ducks the track | 150 ms down, 400 ms up |
| Jingle or skit stinger | Music to -12 dB | 150 ms down, 400 ms up |
| Win / loss | track fades out, then the results jingle | fade 0.5 s |
| Pause / resume | Music LowPass 800 Hz and -6 dB on; off on resume | 0.2 s |
| App backgrounded | Master muted | immediate |

## 7. Godot 4.7 implementation approach

The implementation is decided in **ADR-0015** (`AudioDirector` under `Main`, `MusicDirector` per `PlaySession`, `MusicDeck` with two crossfade players and one jingle player, rules in `assets/data/audio/music_rules.json`). This file does not repeat it. Design-side notes only:

- `MusicDeck.play_track(id)` is the only entry point. If stems ever return, a second deck can sit behind it; nothing is built for that now.
- The pause low-pass must animate while the tree is paused (tree tweens with `TWEEN_PAUSE_PROCESS`, ADR-0010 rule).
- Gravity or lock timing that "follows the music BPM" (TR-mechanics-module-008) cannot read audio: the level's tempo knob is set by hand to match the chosen track.
- The cue-to-event mapping lives in `sfx-cue-list.md` and `event_cues.json`; this file only owns music, buses, mix and adaptive rules.

## 8. Haptics pairing

Follows `game-feel-vfx.md` rule 8 (off by setting, rate-limited to one pulse per 50 ms) and ADR-0015 §6 (Android `vibrate_handheld`, PC gamepad rumble, `NullHaptics` when off). **Verify** the amplitude argument on 4.7.2 and on the target phones (some ignore it). Requires the VIBRATE permission in the Android export preset.

| Moment | Haptic (duration ms / amplitude 0–1) | Paired sound |
|---|---|---|
| Move / rotate | 8 / 0.2 (optional, off by default) | move tick / Turn, Flip, Roll |
| Camera settles on a snap | 8 / 0.2 (same optional setting as move ticks) | camera settle |
| Blocked | 20 / 0.4 | bonk |
| Lock (hard drop) | 25 / 0.6 | lock thunk |
| Layer clear | 40 / 0.7 per layer, × F1 `I`, 60 ms apart | clear |
| Warning | two 30 / 0.6 pulses, 80 ms apart | danger stinger |
| Flip (09, 10) | 80 / 1.0 | flip drum hit |
| Belt shift (10) | 15 / 0.3 | belt clack |
| Win / 3 stars | 3 light pulses on the star stamps | star bells |
| Loss | one soft 60 / 0.3 | loss sting / jingle |

The haptic fires on the same frame as its sound. Haptics never replace a sound cue, and sound never carries information that a deaf player could not get from the screen (accessibility requirement).

## 9. Acceptance criteria

1. **GIVEN** each level 01–10 and B, **WHEN** it starts, **THEN** the track playing is the level's `music` id if set, else `meadow_theme` (check by the MusicDirector's debug readout).
2. **GIVEN** the stack enters danger in a rescue level, **THEN** the Music low-pass and volume drop reach their targets within 0.5 s; in 05, 06 and B they never apply.
3. **GIVEN** a flip in 09 or 10, **THEN** the drum hit fires on the flip frame and the music dips -6 dB for 300 ms.
4. **GIVEN** a 4-layer clear over the busiest supplied track, **THEN** the clear is clearly audible on the reference phone's speaker at 50 % volume (listening test).
5. **GIVEN** the Music slider at 0, **THEN** music, jingles and ambience are silent and SFX/UI are not.
6. **GIVEN** a 10-minute session, **THEN** the measured mix is -16 LUFS ±2 and never clips (Master meter).
7. **GIVEN** haptics off, **THEN** no vibration or rumble fires anywhere.
8. Every shipped music file has a matching `credits.json` entry; the release checklist confirms the "Carefree" placeholder was replaced or kept by user decision.
9. **GIVEN** pause, **THEN** the Music low-pass applies within 0.2 s and is fully removed on resume.

## 10. Open questions

1. ~~Who renders the stems~~: **closed 2026-10-10**, no stems (user decision).
2. **Fourth slider for Ambience**, or keep it under Music (default)?
3. **Clears on the beat**: keep SFX instant (default). Beat-quantised extras are no longer possible without a track BPM; drop unless a track ships with a known BPM.
4. **Per-level tracks**: which Meadow levels get their own track, and which share the biome default? (User; default: all share.)
5. **07 hushed music**: add a per-level static music low-pass (needs a `level` filter state in ADR-0015 `MusicDeck.set_filter`), or rely on the user supplying a quieter `meadow_07`? Default: the latter.
