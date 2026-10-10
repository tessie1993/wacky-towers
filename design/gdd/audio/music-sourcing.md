# Music Sourcing: user-supplied tracks, licence and credit checklist

> **Status**: Draft. Revised 2026-10-10: the user supplies every music track; "Carefree" is the placeholder only
> **Author**: audio-director
> **Last Updated**: 2026-10-10
> **Uses**: `design/gdd/audio/audio-direction.md` §4–5 (formats, track slots) · `docs/architecture/adr-0015-audio-feedback-pipeline.md` §5, §8 (music catalogue, import) · `assets/data/audio/music.json` (catalogue) · `assets/data/credits.json` (credit entries)

**Every value here is a tunable default.**

## 1. Who supplies what

- **The user supplies the music**: one full mixed track per slot (audio-direction §5.2). No stems, no MIDI rendering, no in-house composition.
- **Placeholder until then**: Kevin MacLeod, "Carefree" (CC-BY 4.0), catalogued as `meadow_theme` and used as the biome default for every Meadow level and for `title_theme`. It is a **placeholder**, not a pick: it is a well-known internet meme ("royalty-free ukulele") and could make the game feel cheap.
- The audio-director and sound-designer check each delivered track against the brief and the checklist below, cut the loop, and add the catalogue and credit rows. They do not choose the music.

**Track brief (for the user, a guide, not a rule):** toybox folk (ukulele, glockenspiel, pizzicato, light percussion), cheerful, loops cleanly, **sparse in the 700 Hz–4 kHz band** so block sounds read over it on a phone speaker, no vocals with words. Lengths: level tracks about 1.5–3 min loops, jingles 2–6 s, skit stingers under 2 s.

## 2. Licence checklist (one per delivered file)

Tick every line before the file goes into `assets/audio/music/`.

- [ ] **Source recorded**: page URL, or "made by / commissioned by the user", with the date.
- [ ] **Licence confirmed on the source page itself** (not a search snippet; licences change). A dated copy (PDF or screenshot) saved next to the files in `assets/audio/music/licences/`.
- [ ] **Licence allows commercial use** (no NC). The game may be sold later; monetization is undecided but the seam is there.
- [ ] **Licence allows edits** (no ND): we cut loops, trim, fade and re-level.
- [ ] **Licence allows bundling in a game on Android and PC/Steam**. "Free but custom licence" packs: the user reads and accepts the terms, and the terms file is saved.
- [ ] **No Content ID / fingerprint registration** that would flag streamers or YouTube videos of the game. If the track is registered (common for some royalty-free libraries), the user decides whether that is acceptable.
- [ ] **Commissioned or own work**: a short written note (email is fine) that the composer grants the game the right to use and edit it, saved in `licences/`.
- [ ] **Credit line written** exactly as the licence asks (§3).
- [ ] **`credits.json` entry added**, its `files` listing the exact asset paths.
- [ ] **Catalogue row added** in `music.json` (`file`, `volume_db`, `loop_offset_s`, `credit`).

**Allowed by default**: CC0, CC-BY (any version, credit as required), the user's own or commissioned work, paid licences the user has bought and read. **Not allowed**: CC-BY-NC, CC-BY-ND, "personal use only", ripped commercial music.

## 3. Credit lines

- CC-BY: copy the exact line from the track page. Placeholder:
  `"Carefree" by Kevin MacLeod (incompetech.com). Licensed under Creative Commons: By Attribution 4.0 License. http://creativecommons.org/licenses/by/4.0/`
- If we cut, loop or re-level a CC-BY track, add `Modified (looped) for Wacky Towers.`
- CC0 tracks need no credit, but we credit them anyway (courtesy, and it records where the file came from).
- Own or commissioned work: `Music by <name>` (or as the composer asks).
- Credits appear in the in-game Credits screen (UI defaults: credits + privacy note are the only extra screens) and in `credits.json`.

**`credits.json` entry shape** (same as the existing items):

```json
{"name": "Carefree", "author": "Kevin MacLeod", "licence": "CC-BY-4.0", "source": "https://incompetech.com", "files": ["assets/audio/music/mus_meadow_theme_loop.ogg"]}
```

**`music.json` catalogue row** (ADR-0015 §5):

```json
"meadow_theme": {"file": "res://assets/audio/music/mus_meadow_theme_loop.ogg", "volume_db": 0.0, "loop_offset_s": 0.0, "credit": "Carefree"}
```

## 4. Technical check per delivered track

Done by sound-designer when the file arrives (audio-direction §4, ADR-0015 §8):

- [ ] OGG Vorbis, 44.1 kHz stereo, quality ~5 (~160 kbps). If delivered as WAV/MP3, re-encode to OGG.
- [ ] Integrated loudness about -18 LUFS (jingles about -16 LUFS short-term), true peak ≤ -1 dBTP.
- [ ] Loop point clean: no click at the seam; `loop_offset_s` set if the track has an intro.
- [ ] Sums to mono without losing the melody.
- [ ] Listening test on the reference phone at 50 % volume: a 4-layer clear is clearly audible over it.
- [ ] Size fits the music budget (≤ 25 MB total for the MVP).
- [ ] Named per audio-direction §4 (`mus_<context>_<name>_loop.ogg`, `jgl_…`, `stg_…`).

## 5. Release gate

- [ ] Every file in `assets/audio/music/` has a `credits.json` entry and a saved licence copy.
- [ ] "Carefree" is either replaced or kept by an explicit user decision (ADR-0015 risk table).
- [ ] No catalogue row points at a missing file.

## Appendix: earlier candidate shortlist (ideas only, not picks)

Kept for reference if the user wants starting points. Licences were **not** confirmed on the pages.

| Track / pack | Artist | URL | Licence (as listed) | Note |
|---|---|---|---|---|
| Carefree | Kevin MacLeod | https://incompetech.com | CC-BY 4.0 | **Current placeholder.** Meme risk |
| Quinklette | Cakeflaps | https://opengameart.org/content/quinklette | CC0 (pick CC0) | Cute, loopable; listen first |
| FREE Music Loop Bundle | Tallbeard Studios | https://tallbeard.itch.io/music-loop-bundle | CC0 per one listing, unconfirmed | Many loops; dig for acoustic ones |
| Catsong | Dan Knoflicek | https://opengameart.org/content/catsong | CC0 | Jingle or stinger source |
| CC0 Comical / Silly Music | various | https://opengameart.org/content/cc0-comical-silly-music | CC0 | Stingers, loss jingle |
| Monkeys Spinning Monkeys | Kevin MacLeod | https://incompetech.com | CC-BY (3.0 or 4.0, verify) | Meme risk, like Carefree |

Rejected: "Fluffing a Duck" (meme), CC-BY-ND packs such as "Cute Medieval Fantasy Loops" (no edits allowed), paid packs with no stated licence.
