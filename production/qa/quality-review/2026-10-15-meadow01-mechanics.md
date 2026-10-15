# meadow_01 "Stump Day" mechanics: merged 3-expert blind BUILD review (2026-10-15)

Sources (unedited, read as-is):
- `2026-10-15-meadow01-mechanics-game-designer.md` (GD)
- `2026-10-15-meadow01-mechanics-systems-designer.md` (SD)
- `2026-10-15-meadow01-mechanics-gameplay-programmer.md` (GP)

Rule (`.claude/docs/reference-quality-bar.md`, "Three blind experts"): scores are copied, never edited or averaged.
Pass only if every item of every expert is >= 9.7.

## Result: FAIL

Lowest score: **3.0** (GP item 5, Evidence completeness). 15 of 15 items are below 9.7. Highest score is 8.5 (GP item 3).

## Test-run note

GD and SD had no shell, so they did NOT run tests; their test statements come from reading the files and are unverified by them.
GP's report states it ran the suite. The main session ran `tests/unit/levels`: **35 cases, 0 failures**.
Green tests do not lift any score below: the defects are missing tests, missing captures and missing presentation, not red tests.

## Scores side by side (lowest first within each expert's table order kept as reported)

### Game designer (lowest: 6.0)

| # | Item | Score | Pass 9.7 |
|---|------|-------|----------|
| 1 | Core loop and fun of the grip-release twist | 6.0 | FAIL |
| 2 | Teaching curve for a first level | 6.0 | FAIL |
| 3 | Pacing and difficulty ramp | 6.0 | FAIL |
| 4 | Fail and rescue fairness | 6.0 | FAIL |
| 5 | Goal clarity | 7.5 | FAIL |

### Systems designer (lowest: 5.0)

| # | Item | Score | Pass 9.7 |
|---|------|-------|----------|
| 1 | Rule correctness vs spec | 8.0 | FAIL |
| 2 | Numbers and formulas, in data | 7.5 | FAIL |
| 3 | Edge cases | 6.0 | FAIL |
| 4 | Piece bag and tileability | 5.0 | FAIL |
| 5 | Test coverage quality | 6.0 | FAIL |

### Gameplay programmer (lowest: 3.0)

| # | Item | Score | Pass 9.7 |
|---|------|-------|----------|
| 1 | Implementation correctness and robustness | 8.0 | FAIL |
| 2 | Feel and feedback hooks per beat | 5.5 | FAIL |
| 3 | Data-driven | 8.5 | FAIL |
| 4 | Determinism | 7.0 | FAIL |
| 5 | Evidence completeness | 3.0 | FAIL |

Lowest shown: GP 5 Evidence completeness, 3.0 (1 of 5 required captures exists; stage 0 only).

## What is sound (all three agree)

- Grip order, stage widths 4/6/8 and cell counts 16/24/32 match the spec; the round mask sums to 52.
- One grip per cleared layer (not per cell); extra clears after the third grip are ignored.
- Rescue never releases a grip or counts as a clear (by code reading).
- Values are in data; ramp 1.25 / 1.5625 / 1.953125 is tested; source and production JSON agree.

## Merged fixes, ranked (deduped; owner tag; reviewer refs)

1. **[main session builder + VFX/audio maker] Build the presentation consumers.** Nothing consumes `sky_step`; no ring, shake,
   wall-drop, lock hum, rescue cloud, win bell or input lock. Add column and timing data to the `grip_released` payload.
   (GP D2.1-D2.5; GD D1.4)
2. **[QA + level maker] Capture the missing beats at 720x1280 into `production/qa/evidence/meadow_01/`:** first 10 s, falling piece
   with ghost, grip 1 (6x4), grip 2 (8x4), win, rescue, lose, per-stage wall readability. Make the cage (roots, stones, rim)
   visible around the pit; today the world shows no stump. Missing captures cap GD items 1, 3, 4 at 6. (GP item 5; GD D1.1-D1.3, D5.1; GP capture notes)
3. **[systems designer + main session] Run the G5 tiling solver (>= 98% of seeds per stage, O/I/L, 1-lookahead, no hold) and G6
   gravity/soft/hard-drop bots.** Replace every "TO BE MEASURED" value (g0, ramp, rescue 3, warnings 3, stars 22/28); record in the spec.
   SD flags that O+I+L (11 cells per bag) does not divide 16/24/32, so tileability is unproven. (SD D5, D16-D19; GD D2.3, D3.1; GP D3.4, D4.3)
4. **[gameplay programmer] Real end-to-end sim tests:** play to a win through BoardSim (mask in the structural phase, ability-veto
   path, layer counters rebuilt after widening, win on the third clear, rescue never releases, restart with a new seed in 2 s).
   Rename the overclaiming `test_level_loads_and_wins_on_third_clear_in_sim`; make the rescue test drive a real rescue. (SD D2, D20-D23; GP D1.2, D1.3, D1.4, D1.6; GD D4.2)
5. **[gameplay programmer + systems designer] Define and test edge policies:** multiple layers cleared in one lock or resolve
   (keep `layers_cleared` and `_released` in lockstep); same-round re-clear of a shifted layer (dedupe key; add a clear serial);
   clear during rescue; top-out on the release tick; rescue wipe in a widened pit; grip meter never reset by a rescue. (SD D1, D3, D10-D12, D14, D15; GP D1.1; GD D3.4, D4.2b)
6. **[gameplay programmer] Snapshot, restore and replay determinism:** add a `restore` proof for `_released`, a same-seed same-hash
   replay test, and a test that the bag reseeds per attempt. (SD D13, D18; GP D4.1, D4.2, D4.4)
7. **[game designer] Decide the dead ramp:** with 3 releases the multiplier tops out at 1.953, so `ramp_cap_mult` 3.0 never binds, the
   x1.953 step never plays (third release is the win), and `fall.g_max` is a second unrelated cap. Apply the ramp on stage entry,
   raise the multiplier, or delete the knob; add a clamp test. (GD D3.2, D3.3; SD D6)
8. **[game designer + systems designer] Decide the star rule:** `rescues <= 1 OR pieces <= 28` gives 2 stars to 0 rescues and 99 pieces.
   State the OR on purpose or require both; add a formula variable table; move `stars.status` out of the numeric block. (SD D7, D8, D25; GP D1.5; GD D4.3)
9. **[gameplay programmer + level designer] Build and test the onboarding hints:** finger-and-arrow at 4 s, down-arrow at 8 s,
   curved arrow for the first two turns, first lock hum. They exist on paper only (no hint keys in data). (GD D2.1, D2.2, D5.2, D5.3)
10. **[game designer] Align goal wiring:** spec says the win is driven by `grip_release`; the build uses generic `clear_n n=3`. Align spec or code. (GP D1.4)
11. **[gameplay programmer] Data hygiene:** declare `board.cage` and a 52-cell mask in data and validate the stage union; one constant
    for the `"stump_grip"` id; drop code fallbacks (`ramp_cap_mult` 3.0, `DEFAULT_MARGIN`); one knob namespace for ramp; make
    `rescue.layers` accept a whole-number float or validate at load. (GP D3.1-D3.3; SD D9)
12. **[game designer + level designer] Meter placement and cue:** move the Stump Grip meter near the plaque or pit and give the first
    release an on-screen cue so the layer-to-grip link is learned without count words. (GD D5.2, item 5)
13. **[systems designer] Doc comment polarity:** `grip_release.gd` says "switches cage columns ON"; the spec says the cage is off at
    each grip. Rename or fix. (SD D4)

## Verdict

FAIL. Lowest score 3.0; every one of the 15 items is below the 9.7 bar. Re-review is blind and fresh after fixes 1 to 6 land.
