# Emote bubbles (shared set)

> **Status**: Draft v1 (narrative-director, 2026-10-10). Tunable defaults.
> **Owners**: narrative-director (meaning, use); art-director (icon look); ux-designer + accessibility-specialist (size, timing, reduced motion).

A speech bubble with one icon, over a character's head. No text, ever. The emoji below are references for the meaning only; the art-director draws the final icons in the game's style.

**Display defaults**: one bubble per character at a time (a new one replaces the old); shown ≤ 1 s for reactions, as long as the beat needs in skits; pop-in with a small bounce (no bounce under reduced motion). Every bubble is paired with a **pose**, so the meaning never depends on the icon or its colour alone (colourblind backup). Bubbles sit at the rim or in the backdrop, never over the grid.

| # | id | Icon (ref) | Meaning | Typical trigger | Who |
|---|---|---|---|---|---|
| 1 | `heart` | ♥ | Love, thanks | A layer clear, a friend helped, the payoff | All |
| 2 | `exclaim` | ! | Surprise, alert | A warning, a catch, a sparkle telegraph, the Miller spotted | All |
| 3 | `question` | ? | Confusion, "what's that?" | Intro problem beats; a fog fade; a Miller clue noticed | All |
| 4 | `angry` | 💢 | Cross, huffy (never scary) | The Miller when a clear wrecks his prank; Pip at a gust | Miller, Pip |
| 5 | `sleep` | 💤 | Asleep, bored | The 02 friends, the 07 owl, the 06 Miller nap | Friends, Miller |
| 6 | `sweat` | 💦 (one drop) | Nervous, "oops" | A near-miss, the first warning, a bad drop | Wizard, Pip |
| 7 | `tear` | 💧 (falling drop) | Sad, lonely | **Reserved for the Miller's hidden clues** and a lost level | Miller (clues), Pip (loss) |
| 8 | `note` | ♪ | Happy, humming | Calm play, a clean streak, the picnic | All |
| 9 | `sparkle` | ✨ | Wow, delight | A double clear, a goal met, the keepsake | All |
| 10 | `dots` | … | Hesitant, awkward, lost for words | The Miller almost waving; a stalled moment | Miller, Pip |
| 11 | `dizzy` | @ spiral | Dizzy | After a flip (09, 10), after a bonk | All |
| 12 | `idea` | 💡 | "I've got it!" | Pip's plan beats (05 tower, 06 outline) | Pip, wizard |
| 13 | `blush` | two pink ovals | Shy, flattered | The Miller receiving the invite (10) | Miller (mostly) |
| 14 | `smug` | ☺ with half-lid eyes | Pleased with himself | A prank lands; the player uses a warning | Miller |
| 15 | `gloom` | tiny rain cloud | Sulking | The Miller on a clear; echoes the grumpy-cloud gag on a loss | Miller, wizard |
| 16 | `invite` | leaf card with a basket stamp | "You're invited!" | Pip handing out picnic invites (story prop as icon) | Pip; the Miller *holds* one |

**Rules of use**
- `tear` is rare on purpose. The Miller's 💧 appears only in his clue beats (03–09), so attentive players learn it means "lonely". Pip uses it only on a lost level.
- The Miller's surface emotes are `smug`, `angry`, `gloom`; his secret ones are `dots`, `tear`, `blush`. A clue beat is always a surface emote that slips into a secret one, then snaps back.
- The wizard's emotes are reactions to the player's own play (`sweat` on a warning, `sparkle` on a double), never commentary on the player.
- Reactions are driven by `BoardController` signals through a presenter; no rule values live in the bubble system.
