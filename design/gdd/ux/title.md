# Title

> Patterns: [interaction-patterns.md](interaction-patterns.md). Goal: launch → playing in ≤ 10 s (Menus Game Feel).

## States

| State | Shown | Enters | Leaves |
|---|---|---|---|
| Boot | Engine splash → studio card (≤ 2 s, skippable after first run) | App start | Save loaded |
| First run | Logo, cloud wizard idle, one big **Play** + ⚙ | No save | Play → meadow_01 intro (map skipped once) |
| Returning | Logo, **Continue** (big, with next level's island thumbnail + ★), **Map**, ⚙ | Save has progress | Button |
| Quit dialog | ✔ / ✖ icon dialog | Back on Title | ✔ quits, ✖ returns |

Continue = first unfinished Meadow level; if all done, the last played level (Menus rule 2). Save load error → Save & Profile edge case dialog, then First run.

## Layout

| Zone | Portrait (390 × 844) | Landscape (844 × 390) |
|---|---|---|
| Logo | Top 25%, centred | Left half, upper 50% |
| Wizard + meadow diorama | Middle 40% (behind the buttons, never under them) | Left half, lower 50% |
| Primary (Play / Continue) | Bottom 30%, full-width pill 72 pt tall, inside safe area | Right half, centred, 72 pt tall, 280 pt wide |
| Secondary (Map) | Under primary, 56 pt | Under primary |
| ⚙ Settings | Top-right corner, 44 pt | Top-right corner, 44 pt |
| Sync cloud icon | Top-left, 24 pt, non-interactive | Top-left |

## Interactions

| Input | Result |
|---|---|
| Tap Play / Continue / Enter / A | Go (fires on release) |
| Tap anywhere outside buttons (first run only) | Same as Play |
| Map | Island map |
| ⚙ | Settings overlay; back returns here |
| Back / Esc / B | Quit dialog |
Default focus: primary button.

## Edge cases

- **Orientation change**: re-anchor instantly, focus kept.
- **Bonus or next biome just unlocked (returning)**: Continue still targets the main path; the map shows the unlock.
- **First run with screen reader** (AccessKit): focus starts on Play, label "Play".
- **Music**: menu theme starts on Title, not during Boot; respects Music volume set from a previous session.

## Acceptance criteria

1. [I] No save → Title shows Play only; Play opens meadow_01's intro directly.
2. [I] Save with meadow_01–03 finished → Continue opens meadow_04's intro in 1 tap.
3. [M] Returning player on the reference phone: launch to Countdown ≤ 10 s.
4. [I] Both orientations: no element outside the safe area, primary ≥ 72 pt tall, all targets ≥ 44 pt.
5. [I] Keyboard only and gamepad only: Play/Continue, Map, ⚙ and Quit reachable and activatable.
