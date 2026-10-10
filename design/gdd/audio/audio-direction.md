# Audio Direction: Wacky Towers (Meadow MVP)

> **Status**: Draft (Phase 1, Meadow MVP plan)
> **Author**: audio-director
> **Last Updated**: 2026-10-10
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Variation Over Depth; Comeback Energy
> **Sources**: `design/levels/meadow.md` §2, §6, §9 · `design/gdd/game-feel-vfx.md` (vocabulary, haptics) · `design/art/art-bible.md` §1–2 · `production/levels/meadow/world-and-scenes.md` §3 A1–A3 · `production/orchestration/meadow-mvp-plan.md` (decisions)
> **Companions**: `design/gdd/audio/sfx-cue-list.md` (sound-designer: every SFX event, owns cue names) · `design/gdd/audio/music-sourcing.md` (tracks, licences, credits)

**Every number here is a tunable default** (dB, ms, LUFS, sizes). Change it in the data file, not in code.

---

## 1. Sonic identity

**The rule, borrowed from the art bible: the board is loud, the world is quiet.** Block sounds are the toys and get the brightest, closest, driest sound in the mix. Music and ambience are the box they came in: soft, warm, a little distant.

| Axis | Choice |
|---|---|
| Acoustic vs synthetic | Acoustic toys. Wood, felt, plastic, glass marbles. No synth leads; soft synth pads only as glue |
| Clean vs distorted | Clean, rounded transients. Nothing harsh above about 6 kHz |
| Sparse vs dense | Sparse by default; density is the intensity lever (layers add, never replace) |
| Music | **Toybox folk** (user decision): ukulele, glockenspiel, pizzicato strings, light percussion (shaker, woodblock, brushed kit, a soft kick) |
| Voices | **None.** Skits are wordless. Emote stingers (a squeak, a gasp, a "hmph" made from an instrument or a soft mouth sound with no words) are allowed |
| Spatial | Board SFX are 2D, centred. The 3D diorama is not spatialised in the MVP (phones are effectively mono; spatial cues would be lost) |

**Reference feel (mood, not a spec):** Animal Crossing (warm acoustic folk under play), Tetris Effect (clears lock to the music), Yoshi's Crafted World (toy materials as sound), Puyo Puyo (big, cheerful clear chains).

### Pillar check

| Pillar | What audio contributes | Gap / risk |
|---|---|---|
| **The Block Is the Constant** | One shared block-sound family (move tick, rotate, land, lock, clear) across every biome; biomes only re-skin the *material* layer (Meadow = wood and felt) | Keep the core cues identical across biomes so muscle memory transfers. sound-designer owns the family |
| **Readable Chaos** | Mix priority (§3) keeps board cues on top; every disturbance has an audio telegraph before it fires (gust whoosh-in, flip warning tick, mushroom sparkle chime) | Telegraphs must be distinct by timbre, not just volume. A busy level (10) can hide cues if the music is too dense; full-mix levels cap at 4 layers |
| **Variation Over Depth** | One Meadow theme, re-arranged per level (§5), so every level sounds a little different at very little asset cost | CC0 tracks rarely ship stems; see §5.1 for how layers are produced |
| **Comeback Energy** | Rescue and warnings get a clear "you can save this" sting rather than a doom sound; the danger layer is tense but bouncy | MVP is single-player; the versus item stingers come later. Nothing yet |

## 2. Godot bus layout

```text
Master  ── Limiter (ceiling -1.0 dB)
 ├─ Music      ── Compressor (sidechain: SFX) ── EQ/LowPass (off by default)
 ├─ SFX        ── (no effects; board cues stay dry and immediate)
 ├─ UI         ── (no effects)
 └─ Ambience   ── Compressor (sidechain: SFX) ── LowPass (off by default)
```

| Bus | Carries | Default level | Player slider |
|---|---|---|---|
| Master | everything | 0 dB | no (OS volume does this) |
| Music | level themes, title/map, results jingles, skit stingers | -6 dB | **Music** |
| SFX | board, events, Pip and the Miller reactions | 0 dB | **SFX** |
| UI | buttons, menus, star stamps | -3 dB | **UI** |
| Ambience | A1 bed, A3 one-shots | -12 dB | follows **Music** slider (MVP; no fourth slider) |

**Ducking defaults**
- **Clears and locks duck music**: sidechain compressor on Music and Ambience keyed from SFX. Defaults: threshold -18 dB, ratio 3:1, attack 10 ms, release 300 ms (about -3 to -4 dB on a clear). **Verify** the `AudioEffectCompressor.sidechain` cost on the reference phone; fall back to a scripted tween duck if it shows up in the profiler.
- **Results jingle and skit stingers**: scripted duck, Music theme to -12 dB over 150 ms, restore over 400 ms.
- **Pause**: Music LowPass on (cutoff 800 Hz) and -6 dB; SFX and Ambience paused with the tree.
- **App backgrounded** (Android `NOTIFICATION_APPLICATION_PAUSED`): mute Master; restore on resume.

**Sliders** are 0–100 % stored in settings, mapped with `linear_to_db()`, 0 % = bus muted. Haptics is a separate on/off toggle (§8).

## 3. Mix rules

1. **Priority** (matches game-feel-vfx rule 3): (1) danger/warning cues, the piece's lock and blocked bonk; (2) layer clear; (3) event telegraphs (gust, flip, fog, belt); (4) Pip/Miller reactions, items; (5) music; (6) ambience.
2. **Voice limits** (polyphony): SFX pool 12 players; the same cue retriggers at most once per 50 ms and at most 3 copies at once (oldest stolen). UI pool 4. Ambience one-shots 2.
3. **Phone speakers**: the bottom of a phone speaker rolls off below about 200 Hz. Every important cue (lock, clear, flip drum hit, danger) carries energy in **700 Hz–4 kHz** so it reads on a speaker; sub-bass is a bonus for headphones only. Music is high-passed at 80 Hz.
4. **Mono-safe**: nothing gameplay-critical is panned. Music stereo width is fine but must sum to mono without losing the melody.
5. **Intensity scaling**: SFX gain on clears follows game-feel F1 (`I` = 1–2). Map `I` to +0 to +3 dB and one extra pitch-up step per extra layer, capped at F1's `intensity_cap`.
6. **Pitch variation**: repetitive cues (move tick, lock) get random pitch ±3 % (`AudioStreamRandomizer`) so long sessions do not fatigue.

## 4. Loudness and asset specs

| Item | Target |
|---|---|
| Overall game mix | **-16 LUFS integrated** (mobile norm), true peak ≤ **-1 dBTP** |
| Music stems / tracks (as delivered) | each full mix at about -18 LUFS, so SFX sit 2–4 dB on top |
| SFX | peak-normalised to -3 dBFS; short cues judged by ear against the music, not by LUFS |
| Jingles | about -16 LUFS short-term |
| Music format | OGG Vorbis, 44.1 kHz stereo, quality about 5 (≈160 kbps), loop points set in the import dock |
| SFX format | WAV 16-bit 44.1 kHz **mono**; import as **QOA** compression (Godot 4.3+) for small size and low CPU |
| Size budget (MVP) | music ≤ 25 MB, SFX ≤ 8 MB, ambience ≤ 4 MB |
| Naming | `[category]_[context]_[name]_[variant].[ext]`, for example `mus_meadow_theme_uke_loop.ogg`, `mus_meadow_danger_loop.ogg`, `jgl_results_win_01.ogg`, `amb_meadow_bed_loop.ogg`, `stg_skit_surprise_01.ogg` |
| Folder | `assets/audio/music/`, `assets/audio/sfx/`, `assets/audio/amb/`, `assets/audio/ui/` |
| Credits | every sourced file gets a `credits.json` entry (`files` lists the exact asset paths); see music-sourcing.md |

## 5. Music plan

### 5.1 How layers are produced

The plan in meadow.md §9 needs **one theme split into layers**. Free tracks almost never ship stems, so the default is:

- **Default (A): render stems from a CC0 MIDI.** Pick a CC0 toybox-folk tune that ships MIDI (or transcribe one, CC0 allows it), then render each part with free instrument samples into same-length loops: `base` (ukulele chords + soft kick/shaker), `glock` (melody), `pizz` (counter-line), `wind` (airy pad / whistle), `perc` (brushes, woodblock), `build` (ascending pizz ostinato), `danger` (staccato low pizz + woodblock tick), `mill` (woodblock/clack ostinato for 10). Also render a **+2 semitone** set of every stem for the boss phase 2, and a **+10 % tempo** set for 08. Who renders this is an open question (see the end of this file).
- **Fallback (B): one full-mix track plus filters.** If no one renders stems, use one full-mix Meadow loop and fake layers with bus effects: LowPass for hushed, a separate CC0 percussion loop at the same tempo for build/danger, a separate transposed copy (made offline in Audacity) for phase 2. Less variety, zero production.

All stems for one theme share **tempo, key, bar count and length** (default 100 BPM, 16 bars, F major; tunable). This is what lets `AudioStreamSynchronized` run them together.

### 5.2 Layer map per level (meadow.md §9)

Layers: **B** base, **G** glock melody, **P** pizz, **W** wind, **Pc** perc, **Bu** build, **D** danger (adaptive), **M** mill. Volumes in dB relative to the stem's unity; `off` = -60 dB.

| Level | Layers on | Mix note | Danger layer? | Ambience | Special |
|---|---|---|---|---|---|
| 01 First Sprout | B + G | calm base | yes | bed (birds, bees) | each leaf = soft glock "grow" sting (SFX) |
| 02 Tilt & Roll | B + G | calm base, slightly softer (burrow) | yes | bed, LowPass 3 kHz (underground) | snore one-shots on filled beds (SFX) |
| 03 Breezy Hill | B + G + W | + wind layer | yes | bed + breeze up | W swells +3 dB for 1 s on each gust telegraph |
| 04 Mushroom Ring | B + G + W + P | + plucks | yes | bed + frogs (A3) | mushroom pop in key with P (sound-designer) |
| 05 Tall Tower | B + G + Bu | light build layer; Bu gain rises with tower height (-12 dB at 0 → 0 dB at the sign) | **no** (trim cannot lose) | bed, wind high | sign reached = jingle |
| 06 Flower Bed | B + G + P + Bu (Bu at -6 dB) | light build, calm | **no** | bed + bees | each bloom stage = glock sparkle (SFX) |
| 07 Hide & Seek | B only, + G at -9 dB; Music LowPass 2.5 kHz | **sparse, hushed** | yes | bed quiet + owl (A3) | on each fog reveal: G jumps to 0 dB for the 0.6 s reveal, then back |
| 08 Dewdrop | B + G + Pc (**fast set**, +10 %) | faster tempo | yes | bed, glitter shimmer | the 150 s sun dial end = "pop free" sting |
| 09 Topsy-Turvy | B + G + W + P + Pc | **full mix** | yes | bed + bird fuss | **flip drum hit** (§6) |
| 10 Meadow Mill, phase 1 | B + M + G + Pc | the mill rhythm | yes | mill creak, flour puffs (A3) | each sail knocked off = short sting (Music bus, ducks theme) |
| 10 Meadow Mill, phase 2 | same layers, **+2 semitone set** | key change, + W | yes | as phase 1 | key change lands with the flip drum hit |
| B Picnic Puzzle | own short cue: Pc + P "ant march" with a woodblock tick; tempo 120 BPM | ticking, hurried | **no** (out of pieces / clock) | picnic bed | last 10 s: tick doubles (switch clip) |
| H1–H3 | later (not MVP) | — | — | — | — |

**Title / island map**: a **music-box arrangement** of the theme (glock + soft uke, no perc), its own loop. Map and title share it so the transition is seamless; entering a level crossfades over 1 s into that level's layer set (starting on the Countdown).
**Results jingles** (Music bus, one-shot, theme ducked): `win` (≈3 s, uke strum + glock run), `win_3star` (≈4 s, + one bell per star in sync with the star stamps), `loss` (≈2.5 s, soft descending pizz, "aw, one more go", never sad), `meadow_complete` (≈6 s, full band, after the 10 payoff skit).
**Skit stingers** (wordless): about 6 short one-shots in the theme key: surprise, sneaky (the Miller), oops, triumph, sulk, cheer. Skits play over the theme ducked to -12 dB. The full list belongs in the cue list.

## 6. Adaptive rules

| Trigger (game event) | Response | Timing |
|---|---|---|
| Stack enters the danger zone (warning state), levels with `topout_rule` rescue only | **D** fades in to 0 dB; Ambience LowPass 1.5 kHz; one-shot **danger stinger** on the SFX bus | D fade 0.5 s, stinger immediate |
| Stack leaves danger | D fades out; Ambience filter off | 1.0 s |
| Rescue used | rescue sting (SFX), D cuts out | immediate |
| Layer clear | sidechain duck (§2); the clear SFX fires on the frame, not quantised to the beat (waiting costs feel) | immediate |
| Gust telegraph (03, 10) | W swell +3 dB | over the 1 s warning |
| Flip warning (09, 10) | ticking countdown (SFX), music unchanged | 2 s warning |
| **Flip** (09, 10) | **drum hit** on SFX (big tom + woodblock + cymbal swell, energy in 700 Hz–4 kHz), Music ducked -6 dB for 300 ms, then back | on the flip frame |
| 10 phase 2 starts (flip after the 2nd clear) | switch every stem to the +2 semitone set, aligned to the bar; W joins | transition at the next beat, 0.2 s crossfade, so the drum hit covers the seam |
| 10 sail knocked off (each clear) | sail sting (Music bus) | immediate |
| 05 height grows | Bu gain follows tower height | continuous, smoothed 0.5 s |
| 07 fog reveal | G up for the reveal | 0.6 s |
| B last 10 s | switch ant-march clip to double-tick | next beat |
| Win / loss | theme fades out, jingle plays | fade 0.5 s |
| Pause / resume | §2 pause rule | 0.2 s |

## 7. Godot 4.7 implementation approach

Owner: lead-programmer decides the structure; this is the recommended default. Godot 4.7.2 knowledge here comes from 4.3+ docs; anything marked **verify** must be checked in the 4.7 editor before code depends on it.

- **Layered theme**: one `AudioStreamSynchronized` per level resource (`res://assets/audio/music/meadow_theme_sync.tres`) holding all stems. Layers are faded by changing the per-stream volume (`set_sync_stream_volume(index, db)`) from a tween. **Verify** that changing the volume on the resource updates a playing stream live; if it does not, use the playback object, or fall back to N `AudioStreamPlayer`s started on the same frame on the Music bus.
- **States and key change**: wrap it in an `AudioStreamInteractive` with clips `theme` (the synchronized stream), `theme_up2` (the +2 semitone synchronized stream), `fast` (08). Transitions use "next beat" or "next bar" with a short fade (needs `bpm` and `bar_beats` set on each OGG import). Switch with `get_stream_playback().switch_to_clip_by_name(&"theme_up2")`. **Verify** the exact 4.7 method names and the transition-from-time enums.
- **Jingles** and stingers: a separate `AudioStreamPlayer` on the Music bus, with the scripted duck.
- **Driver**: a thin **MusicDirector** node in the level scene (data-driven from a `music_meadow.json` table, one row per level: stem volumes, ambience, danger flag, special cues) listens to the existing game signals (warning state, layers_cleared, flip, phase change, win, loss). An autoload only for the persistent title/map music and bus setup. Per coding standards, the director takes its signal source by injection so it can be unit-tested without audio.
- **SFX**: pooled `AudioStreamPlayer`s per bus (engine-reference `modules/audio.md` pattern); `AudioStreamRandomizer` for pitch variation.
- **Bus layout** saved as `res://default_bus_layout.tres`.
- **Breaking change to remember**: `AudioStreamPlayer.area_mask` default changed (engine-reference `breaking-changes.md`); not relevant to 2D players, check if any 3D player is added.
- The cue-to-event mapping lives in `sfx-cue-list.md`; this file only owns music, buses, mix and adaptive rules.

## 8. Haptics pairing

Follows `game-feel-vfx.md` rule 8 (off by setting, rate-limited to one pulse per 50 ms). Android first: `Input.vibrate_handheld(duration_ms, amplitude)`; **verify** the amplitude argument on 4.7 and on the target phones (some ignore it). Requires the VIBRATE permission in the Android export preset.

| Moment | Haptic (duration ms / amplitude 0–1) | Paired sound |
|---|---|---|
| Move / rotate | 8 / 0.2 (optional, off by default) | move tick |
| Blocked | 20 / 0.4 | bonk |
| Lock (hard drop) | 25 / 0.6 | lock thunk |
| Layer clear | 40 / 0.7 per layer, × F1 `I`, 60 ms apart | clear |
| Warning | two 30 / 0.6 pulses, 80 ms apart | danger stinger |
| Flip (09, 10) | 80 / 1.0 | flip drum hit |
| Belt shift (10) | 15 / 0.3 | belt clack |
| Win / 3 stars | 3 light pulses on the star stamps | star bells |
| Loss | one soft 60 / 0.3 | loss jingle |

The haptic fires on the same frame as its sound. Haptics never replace a sound cue, and sound never carries information that a deaf player could not get from the screen (accessibility requirement).

## 9. Acceptance criteria

1. **GIVEN** each level 01–10 and B, **WHEN** it plays, **THEN** the active layers match §5.2 (check by the MusicDirector's debug readout).
2. **GIVEN** the stack enters danger in a rescue level, **THEN** the danger layer reaches full volume within 0.5 s; in 05, 06 and B it never plays.
3. **GIVEN** 10 phase 2 starts, **THEN** the music is in the +2 key within one beat and the drum hit fires on the flip frame.
4. **GIVEN** a 4-layer clear over full music, **THEN** the clear is clearly audible on the reference phone's speaker at 50 % volume (listening test).
5. **GIVEN** the Music slider at 0, **THEN** music, jingles and ambience are silent and SFX/UI are not.
6. **GIVEN** a 10-minute session, **THEN** the measured mix is -16 LUFS ±2 and never clips (Master meter).
7. **GIVEN** haptics off, **THEN** no vibration fires anywhere.
8. Every shipped music file has a matching `credits.json` entry.

## 10. Open questions

1. **Who renders the stems** (§5.1 A): a sound-designer session with free samples, the user, or skip to fallback B?
2. **Fourth slider for Ambience**, or keep it under Music (default)?
3. **Clears on the beat**: keep SFX instant (default) or try a light beat-quantised sparkle layer on top later?
4. **Theme key and tempo** (F major, 100 BPM) are set by whichever track is chosen in music-sourcing.md.
