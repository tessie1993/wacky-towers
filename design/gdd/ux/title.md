# Title

> Patterns: [interaction-patterns.md](interaction-patterns.md). Goal: launch → playing in ≤ 10 s (Menus Game Feel).

## States

| State | Shown | Enters | Leaves |
|---|---|---|---|
| Boot | Engine splash → studio card (≤ 2 s, skippable after first run) | App start | Save loaded |
| First run | Logo, cloud wizard idle, one big **Play** + ⚙ | No profile in any of the 4 slots | Play → Profile select: Create (name pre-filled) → first-run picker (ACC-02) → meadow_01 intro (map skipped once) |
| Returning | Logo, **profile chip**, **Continue** (big, with next level's island thumbnail + ★), **Map**, ⚙ | Last-used profile remembered (ADR-0013) | Button |
| Pick profile | As Returning, then Profile select opens on top | Profiles exist but the last-used one is missing or unreadable (`needs_profile_select()`) | Pick a card → Returning |
| Quit dialog | ✔ / ✖ icon dialog | Back on Title | ✔ quits, ✖ returns |

Continue = first unfinished Meadow level of the active profile; if all done, the last played level (Menus rule 2). Save problems → [loading-and-save-error.md](loading-and-save-error.md) notice first, then the state above. Profiles: [profile-select.md](profile-select.md).

## Layout

| Zone | Portrait (390 × 844) | Landscape (844 × 390) |
|---|---|---|
| Logo | Top 25%, centred | Left half, upper 50% |
| Wizard + meadow diorama | Middle 40% (behind the buttons, never under them) | Left half, lower 50% |
| Primary (Play / Continue) | Bottom 30%, full-width pill 72 pt tall, inside safe area | Right half, centred, 72 pt tall, 280 pt wide |
| Secondary (Map) | Under primary, 56 pt | Under primary |
| ⚙ Settings | Top-right corner, 44 pt | Top-right corner, 44 pt |
| Profile chip (returning) | Top-left, badge + name, 48 pt tall; tap → Profile select | Top-left |
| Save badge | Only when the save is read-only (scroll + ▲, 24 pt, next to the chip) | Same |

(The cloud-sync icon is dropped: the MVP cloud backend is a no-op, ADR-0013 §8.)

## Interactions

| Input | Result |
|---|---|
| Tap Play / Continue / Enter / A | Go (fires on release) |
| Tap anywhere outside buttons (first run only) | Same as Play |
| Map | Island map |
| Profile chip | Profile select; back returns here |
| ⚙ | Settings overlay; back returns here |
| Back / Esc / B | Quit dialog |
Default focus: primary button.

## Edge cases

- **Orientation change**: re-anchor instantly, focus kept.
- **Bonus or next biome just unlocked (returning)**: Continue still targets the main path; the map shows the unlock.
- **First run with screen reader** (AccessKit): focus starts on Play, label "Play".
- **Music**: menu theme starts on Title, not during Boot; respects Music volume set from a previous session.

## Acceptance criteria

1. [I] No save → Title shows Play only; Play opens Create profile, then the first-run picker, then meadow_01's intro (3 presses with the pre-filled name).
1a. [I] Remembered profile → no Profile select at launch; the chip shows that profile.
2. [I] Save with meadow_01–03 finished → Continue opens meadow_04's intro in 1 tap.
3. [M] Returning player on the reference phone: launch to Countdown ≤ 10 s.
4. [I] Both orientations: no element outside the safe area, primary ≥ 72 pt tall, all targets ≥ 44 pt.
5. [I] Keyboard only and gamepad only: Play/Continue, Map, ⚙ and Quit reachable and activatable.
