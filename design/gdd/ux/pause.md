# Pause

> Overlay over the dimmed board. Clock stops (pausing never costs stars). Patterns: [interaction-patterns.md](interaction-patterns.md).

## States

| State | Enters | Leaves |
|---|---|---|
| Paused | ❚❚, Esc/P, Start, Android back, app backgrounded, call | Resume |
| Rotated pause | Phone turned mid-level (Touch rule 5b, Camera rule 5a): layout switches, then this shows with Resume only highlighted | Resume |
| Rules list | "Rules" button or the "+N" chip | Back → Paused |
| Confirm | Restart or Map | ✔ / ✖ |
| Settings | ⚙ | Back → Paused |
Resume → 1 s "3-2-1"-lite (big 1 only, 600 ms) so the thumb is back before the piece falls. Reduced motion: same timing, no pop.

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Board | Dimmed 60%, frozen, visible above the panel (so the player can plan) | Dimmed, visible on the left |
| Panel | Bottom sheet: **Resume** (72 pt, top of sheet), then Restart · Rules · ⚙ · Map as a 2 × 2 grid of 56 pt icon+label buttons | Right panel: Resume on top, then a vertical list |
| Goal reminder | Goal icon + progress digits + both star times at the top of the panel | Same |

## Interactions

| Input | Result |
|---|---|
| Resume / Esc / Start / B / Back | Resume (Back never quits from pause) |
| Restart | Confirm → Retry countdown (skit skipped) |
| Map | Confirm → Island map (no result saved) |
| Rules | Full active-rule list: icon, name, one line |
| ⚙ | Settings overlay; changes apply on Resume |
Default focus: Resume.

## Edge cases

- **Backgrounded during a turn animation**: turn completes instantly, then Paused (Camera edge case).
- **Touches held when pausing**: cancelled, nothing buffered (Touch edge case).
- **Pause during Countdown**: countdown restarts from 3 on resume.
- **Controls changed in Settings while paused** (scheme, mirror, scale, camera type): HUD re-lays out before the resume beat.
- **Pause pressed during Result**: ignored.

## Acceptance criteria

1. [I] Every pause trigger in the table opens Paused and the level clock stops.
2. [I] Turning the phone mid-level pauses; board framing recomputed; yaw step kept.
3. [I] Restart and Map each ask exactly one confirmation; Resume asks none.
4. [I] Resume shows a 600 ms beat before gravity resumes.
5. [I] P and L inside the safe area; keyboard-only and gamepad-only can reach every button.
