# Moving platform (G8) core, round 1: three blind experts (2026-10-14)

Panel: gameplay programmer, systems designer and game designer. Each was fresh and blind to the others. **Result: FAIL.**

| Expert | Scores | Lowest |
|---|---|---|
| Gameplay programmer (G1-G6) | 8.0, 8.0, 6.5, 7.5, 6.5, 5.0 | 5.0 |
| Systems designer (S1-S6) | 6.5, 6.0, 5.5, 5.5, 5.0, 4.5 | 4.5 |
| Game designer (D1-D6) | 5.5, 5.0, 5.5, 4.5, 4.0, 6.0 | 4.0 |

## Merged findings

**Strong:** a deterministic, seeded, chunk-invariant sim with snapshot/restore. All tuning is in data, and 14 tests pass.

**Design blockers** (these need user decisions):
1. **There is no race.** Speed is fixed, so nothing you build changes how fast you finish. The build must affect speed, for example through mass, height or line boosts, and there must be a rival, a par or a clock.
2. **One safe strategy.** A tidy stack below layer 6 is immune to every event. Height and shape need trade-offs, such as wind on tall stacks, lean and tilt (the "don't fall over" in the user's fantasy).
3. **The cargo has no tension.** It can be avoided by never building on its column, and its loss is hair-trigger (more than 2 layers dropped from one roll). The cargo should be something you must build around, with graded warnings.
4. **Pacing:** the track lasts about 51 s with no finale. Event density does not ramp, and fall speed is not tied to the section.
5. **The two races would play alike.** The kite race needs its own events and a wind-height term, and there is no Kite Day track yet.

**Engineering:**
1. Nothing is wired end to end: no stage, goal, preview or level uses it.
2. A restart can leave blocks behind that were moved by queued writes.
3. Cargo checks ignore clears and top-out, and a restart does not reset the piece, hold or goal.
4. Bump rolls dice per cell, so a cascade can leave blocks floating.
5. Missing parameters silently default to 0 (a missing `gap_layers` wipes the board), and the sort is unstable.
6. Tests are missing for the rule glue, crosswind, updraft height, restart replay and snapshot continuation.
7. The preview feed lacks time-to-event, hit chance and safe height.

The full reports are in `2026-10-14-moving-platform-r1-{gameplay-programmer,systems-designer,game-designer}.md`.
