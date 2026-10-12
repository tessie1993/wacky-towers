# Level intro and countdown

> Intro card → Play → Countdown (3 s, `countdown_ms` 3 000) with the wordless intro skit playing on the island (`design/levels/meadow.md` §1: no play time lost). Patterns: [interaction-patterns.md](interaction-patterns.md).

## States

| State | Shown | Enters | Leaves |
|---|---|---|---|
| Card | Island diorama behind; card: level number + name, **goal** (icon + digits, e.g. layer icon `× 4`), **rule icons** (mechanic/twists, ≤ 3) with 2-word names, **stars**: best stars, ★★ and ★★★ times as clock icon + digits (Survive: layer counts), **Play** | Map island tap; Results → Next | Play / Back |
| Countdown | Board + HUD (Countdown state, `design/gdd/ux/hud.md`), controls visible but inert, big 3-2-1 number, skit with emote bubbles over the board edge | Play | First spawn → Play |
| Retry countdown | Same, skit **skipped**, card skipped | Results/Pause → Retry | First spawn |

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Card | Bottom sheet, 60% height, full width; Play at the bottom, 72 pt | Right panel, 45% width, full height; Play bottom-right, 72 pt |
| Diorama | Visible above the sheet | Visible left of the panel |
| Back | ◀ top-left, 44 pt | ◀ top-left |
| Countdown number | Centre of the board rect, H1 size × 2, ink outline | Same |
| Emote bubbles | Anchored to Pip/Miller in the world, kept off the HUD top band | Same |

## Interactions

| Input | Result |
|---|---|
| Play / Enter / A | Countdown |
| Tap a rule icon | One-line description expands under it (no navigation) |
| Back | Island map (Card) — no back during Countdown; Pause works |
| Tap during Countdown | Nothing (input inert; nothing buffered). Pause button works |
| Countdown skip | None in MVP; it is 3 s and the skit carries the story |

## New-control spotlight (onboarding)

When a level enables controls the player has not used yet (meadow_01: d-pad, Turn, Drop; meadow_02: Flip), the Countdown dims the HUD except those buttons, which get a pulsing ring (reduced motion: static thick ring) and a hand-tap icon. Shown on first play only; replays skip it.

## Edge cases

- **Orientation change on Card**: re-lay out instantly. **During Countdown**: pause (pause.md); countdown restarts from 3 on resume.
- **App backgrounded during Countdown**: Pause; restart countdown on resume.
- **Bonus level**: card shows the ant clock icon + `60 s` and the fixed list as 6 small piece previews (they are known in advance).
- **Level with no star time data**: shows formula times (Scoring F1), same look.
- **First ever play of meadow_01**: card is skipped (Title Play goes straight to Countdown) to reach the first piece fastest.

## Acceptance criteria

1. [I] Card shows goal, ≤ 3 rule icons, best stars and both star thresholds as digits; no sentence text except rule names.
2. [I] Countdown lasts 3 000 ms ± 1 frame; the first piece spawns at its end; touches during it send no command.
3. [I] Retry skips the card and the skit; Next shows the card.
4. [I] meadow_02 first play spotlights Flip ◀ ▶; second play does not.
5. [I] P and L layouts inside the safe area; Play ≥ 72 pt; keyboard/pad reach Play, rule icons, Back.
