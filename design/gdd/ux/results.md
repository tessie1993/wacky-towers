# Results

> Win: payoff skit → stars → buttons. Loss: funny-failure beat → buttons. Wordless: conditions are icons + digits (Scoring & Stars V/A). Patterns: [interaction-patterns.md](interaction-patterns.md).

## States

| State | Shown | Duration | Skip |
|---|---|---|---|
| Win banner | H1 banner + clear burst on the board | 0.8 s | Tap |
| Payoff skit | Wordless skit on the island, emote bubbles | 3–6 s (`design/levels/meadow.md`) | Tap (always skippable; replays offer skip at once) |
| Star stamp | 3 star slots stamp in one by one; each with its condition icon: flag (finished), clock + time vs ★★ time, shield + clock (no warning, ★★★) | 0.4 s per star | Tap = show all |
| Win buttons | **Next** (primary), Retry, Map | Until input | n/a |
| Loss beat | Funny failure (Pip covers eyes / ants carry the basket off); goal progress digits | 1.5 s | Tap |
| Loss buttons | **Retry** (primary), Map | Until input | n/a |
| Unlock note | Small icon chip: "next island open", "bonus open (★ 20)" | With buttons | n/a |

**New best** chip on a better time or more stars than the saved best. Save is written before buttons appear (Save & Profile rule 2).

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Skit / diorama | Upper 55% | Left 55% |
| Stars + conditions | Under the skit, 3 slots in a row, ≥ 64 pt each | Right panel top |
| Time + best | Digits under the stars | Under the stars |
| Buttons | Bottom: primary 72 pt full width, Retry + Map side by side 56 pt | Right panel bottom: primary 72 pt, then Retry · Map |

## Interactions

| Input | Result |
|---|---|
| Next | Next main-path level's intro card (the bonus is reached from the map) |
| Retry | Retry countdown (card + skit skipped) |
| Map | Island map (unlock reveal plays there) |
| Back | Map |
| Tap during skit/stamp | Skip to the next state |
Default focus: primary. Input during the first 300 ms of the button state is ignored (stops a skip-tap from pressing Next).

## Edge cases

- **meadow_10 won**: Next → Map (Meadow complete; bank reveal shows the 15★ gate result).
- **Survive (meadow_08)**: clock icon replaced by layer icon + `layers / s2 / s3`.
- **Trim levels (05, 06, B)**: ★★★ condition icon = "no cube trimmed" (popped-cube icon crossed out).
- **Fewer stars than best on a replay**: show this run's stars, plus the kept best as small outlined stars ("best ★★★").
- **Reduced motion**: stars appear without bounce, same order and timing.

## Acceptance criteria

1. [I] Win at ≤ t3 with no warning → 3 stars each with its condition icon; with a warning → 2.
2. [I] Every skit and stamp skips on one tap; buttons ignore input for 300 ms after appearing.
3. [I] Loss shows Retry focused and no stars; Retry reaches the first spawn in ≤ 3.5 s.
4. [I] Save is on disk before buttons accept input.
5. [I] P and L inside the safe area; keyboard/pad reach all buttons.
