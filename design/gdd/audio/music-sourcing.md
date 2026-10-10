# Music Sourcing: Meadow MVP (toybox folk, CC0 / CC-BY)

> **Status**: Draft shortlist, nothing downloaded
> **Author**: audio-director
> **Last Updated**: 2026-10-10
> **Uses**: `design/gdd/audio/audio-direction.md` §5 (slots, stem plan) · `assets/data/credits.json` (credit entries)

**Rules (defaults):** prefer **CC0**; **CC-BY** is fine with the exact credit line in the in-game credits **and** `credits.json`. Avoid NC (non-commercial), ND (no-derivatives: we need to cut loops, render stems and transpose), and "free but custom licence" packs unless the user reads and accepts the terms. Open each page and **confirm the licence on the page itself before downloading**. Search snippets are not proof, and the licence can change. Save a dated copy of the licence page next to the files.

## 1. Shortlist

| # | Track / pack | Artist | URL | Licence (as listed) | Fit | Slot it could fill | Loop / stems |
|---|---|---|---|---|---|---|---|
| 1 | **Quinklette** | Cakeflaps @ You're Perfect Studio | https://opengameart.org/content/quinklette | CC0 (also offered as CC-BY 4.0 / OGA-BY 3.0; **pick CC0**) | Described as cute and loopable; instruments not stated, so **listen first** | Title/map music-box candidate, or bonus | Loopable; WAV + OGG; no stems |
| 2 | **[Music Assets] FREE Music Loop Bundle** | Tallbeard Studios | https://tallbeard.itch.io/music-loop-bundle | Listed as CC0 in one listing; **not confirmed** on the page | 150–200+ seamless loops in all genres; dig for acoustic/whimsical ones | Danger, build or ant-march loops; filler for any gap | Seamless loops; no stems |
| 3 | **Catsong** | Dan Knoflicek (uploaded by josepharaoh99) | https://opengameart.org/content/catsong | CC0 | Short, happy, funny | Results win jingle or skit stinger source | Short; no stems |
| 4 | **CC0 – Comical / Silly Music** (collection) | various, collected by josepharaoh99 | https://opengameart.org/content/cc0-comical-silly-music | CC0 | Silly, fun; small collection | Skit stingers, loss jingle | Mixed |
| 5 | **Carefree** | Kevin MacLeod | https://incompetech.com (search "Carefree") | CC-BY 4.0 (verify on the track page) | Real ukulele, cheerful, exactly the toybox-folk sound | Meadow theme (fallback B in audio-direction §5.1) | Loopable with an edit; no stems; MacLeod sells MIDI/sheet for some tracks (check) |
| 6 | **Monkeys Spinning Monkeys** | Kevin MacLeod | https://incompetech.com (search the title) | CC-BY (one source says 3.0, others 4.0: **verify** the version) | Pizzicato and bouncy; good for the bonus ant march or the mill rhythm | Bonus (B) or 10 phase 1 | Loopable with an edit; no stems |

**CC-BY credit lines** (copy the exact text from the track page if it differs):
- `"Carefree" by Kevin MacLeod (incompetech.com). Licensed under Creative Commons: By Attribution 4.0 License. http://creativecommons.org/licenses/by/4.0/`
- `"Monkeys Spinning Monkeys" by Kevin MacLeod (incompetech.com). Licensed under Creative Commons: By Attribution 4.0 License. http://creativecommons.org/licenses/by/4.0/` (use 3.0 and its URL if the page says 3.0)
- If we cut, loop or transpose a CC-BY track, add `Modified (looped and transposed) for Wacky Towers.`
- CC0 tracks need no credit, but we credit them anyway (courtesy, and it records where the file came from). Catsong is credited to **Dan Knoflicek**, not the uploader.

**`credits.json` entry shape** (same as the existing items):

```json
{"name": "Carefree", "author": "Kevin MacLeod", "licence": "CC-BY-4.0", "source": "https://incompetech.com", "files": ["assets/audio/music/mus_meadow_theme_full_loop.ogg"]}
```

## 2. Warnings

- **MacLeod's "Carefree" and "Monkeys Spinning Monkeys" are internet memes** ("royalty-free ukulele"; TikTok and YouTube background music). Players will recognise them, and that can make the game feel cheap or turn it into a joke. They fit the sound perfectly, so this is a taste call for the user (open question 2).
- **Fluffing a Duck** (MacLeod, CC-BY) was considered and dropped: it is even more of a meme (the 2024 Golden Globes, TikTok).
- **Paid packs that fit well but are not free**: "Playful Pizzicato" (skcompositions, itch.io, $20 min, licence not stated). Listed only in case the user changes the budget rule.
- **CC-BY-ND packs** (for example "Cute Medieval Fantasy Loops", Callum Lee Gow) are unusable: no loop edits or stems allowed.

## 3. Gaps

| Gap | Why | Default plan |
|---|---|---|
| **Stems for one Meadow theme** | None of the candidates ships stems; meadow.md §9 needs layers | audio-direction §5.1 A: find a CC0 tune with MIDI (Komiku's CC0 albums on OpenGameArt ship MIDI, for example "Helice Incredible Adventure", https://opengameart.org/node/96795, but that one is disco/RPG, not folk) and render toybox stems; else fallback B (one full mix + filters) |
| **+2 semitone boss version** | No free track ships one | Make offline from our stems (or Audacity pitch shift on the full mix; CC0/CC-BY both allow it) |
| **Faster 08 version** | Same | Offline time-stretch +10 % |
| **Matched key and tempo across slots** | Tracks from different artists will not share a key | Use one theme for all 11 levels (the plan); only jingles and stingers may come from other sources, and they should be pitch-matched to the theme |
| **Danger layer, build layer, ant-march tick** | Too specific for a free pack | Render from MIDI with the stems, or pull a percussion loop from the Tallbeard bundle and match its tempo |
| **Glockenspiel-led title music box** | Not found as CC0 | Render from the theme MIDI (glock + uke) |

## 4. Next steps (for the user)

1. Listen to #1, #3, #5 and #6 and pick the theme direction (CC0 original vs. MacLeod meme risk).
2. Confirm each licence on its page and save a dated copy.
3. Decide who renders the stems (audio-direction open question 1).
4. Then sound-designer downloads, cuts loops and adds every file to `credits.json`.

## Sources (search results, 2026-10-10)

- [Quinklette, OpenGameArt](https://opengameart.org/content/quinklette)
- [Tallbeard FREE Music Loop Bundle, itch.io](https://tallbeard.itch.io/music-loop-bundle/purchase)
- [Catsong, OpenGameArt](https://opengameart.org/content/catsong)
- [CC0 Comical / Silly Music, OpenGameArt](https://opengameart.org/content/cc0-comical-silly-music)
- [Komiku, Helice Incredible Adventure (CC0 + MIDI), OpenGameArt](https://opengameart.org/node/96795)
- [Royalty Free Ukulele ("Carefree") meme, Know Your Meme](https://amp.knowyourmeme.com/memes/royalty-free-ukulele)
- [Monkeys Spinning Monkeys, NPR](https://www.npr.org/2024/09/24/g-s1-23951/monkeys-spinning-youtube-tiktok-viral-social-media-music)
- [Monkeys Spinning Monkeys licence note, flutetunes](https://flutetunes.com/tunes.php?id=4614)
- [Fluffing a Duck, Know Your Meme](https://amp.knowyourmeme.com/memes/fluffing-a-duck-by-kevin-macleod)
- [Playful Pizzicato, itch.io](https://skcompositions.itch.io/playful-pizzicato)
- [Cute Medieval Fantasy Loops (CC-BY-ND), itch.io](https://callumleegow.itch.io/cute-medieval-fantasy-loops)
