# Moving platform (G8), round 2: three blind experts (2026-10-14)

**Result: FAIL.** The scores are up from round 1. The three section 8 decisions are now in code.

| Expert | Scores | Lowest |
|---|---|---|
| Gameplay programmer | 8.5, 8.0, 7.5, 7.5, 7.0, 6.5 | 6.5 |
| Systems designer | 6.5, 5.5, 5.5, 4.5, 6.0, 3.5 | 3.5 |
| Game designer | 6.0, 5.5, 5.5, 6.0, 6.0, 6.5 | 5.5 |

## Merged findings

**Design calls for the user:**
1. **The clock never binds** (all 3 experts). A restart refunds the replayed time and costs a flat 8 s (`track_runner.gd:366`). That leaves 5-6 restarts of slack, so the time limit is unreachable.
2. **One safe strategy** (game designer). A low, flat, centred plateau beats every event, and nothing rewards risk.
3. **The updraft is dead** (2 experts). Lift is 0 for normal 8x8 stacks, it doesn't affect a clock that doesn't bind, and it pushes the player into the finale.

**Tuning and engineering:**
1. The tuning is validated on a 4x4 board, but the level is 8x8. The gust and lean need normalising and output caps.
2. There is no survival bot and no build-rate sim.
3. The cargo can be lost without any warning stage, from instant event stress or a large drop on a clear.
4. Topple has no dwell time, so the heavy side is stripped within a few ticks.
5. The arch trim is dead code.
6. Preview rows lack a safe height for wind and gust, severity uses mixed scales, the bump direction is misleading, and warnings carry no cause.
7. A track that fails to load leaves the goal RUNNING forever.
8. Validation still has gaps.
9. After a rule restore, the view stays detached.
10. Nothing is wired yet: `meadow_03` is still `clear_n`, the bonus level is not set up, and there is no HUD lean meter or preview strip.
