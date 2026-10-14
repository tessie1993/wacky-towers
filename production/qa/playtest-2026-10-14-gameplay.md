# Playtest 2026-10-14 — Core Loop (gameplay + readability)

**Story type**: Integration (documented playtest) | **Gate**: BLOCKING evidence for core-loop stories, this run is a PARTIAL pass
**Build**: Godot 4.7.2.stable, branch `ccr-86d4b3f2-dl6mzv`, Xvfb + opengl3, 720x1280
**Driver**: `tools/qa/playtest/core_loop_capture.gd` / `.tscn` (new; reuses the island_capture / story_playthrough patterns)
**Evidence**: `production/qa/evidence/playtest-2026-10-14/`
**Raw log**: one PT_ROW JSON line per level on stdout (run 1 log is in the session scratchpad, not retained)

## Coverage — be honest about what ran

| Level | Planned | Captured | Status |
|---|---|---|---|
| meadow_02 | start / mid / clear / end | start, mid, fail | PLAYED. Real input path (move + rotate intents, then gravity, then bot, then drop-at-spawn). No layer clear, so no `_clear` shot. Result was FORCED LOST (see F-03) |
| ice_04 | same | start, fail | INVALID. Harness bug: calling `_start_level` again on the same main after the results screen left the meadow sim live. The ice shots show the stale meadow board/results. Do not use them |
| lava_05 | same | start (partial) | Run was stopped while lava was in progress |
| underwater_03, pirate_01, pirate_h1, carnival_03, meadow_h3 | same | none | NOT RUN |

The script has been fixed (a fresh `main.tscn` for each level, 40 sim ticks per rendered frame during the bot phase, 120 s wall cap, and a deliberate fail on `pirate_h1`). It parses, but the corrected full run was not executed: clearing the old shots was denied, and the coordinator then asked for a wrap-up. **Re-run command** (about 15-25 min):

```
XDG_DATA_HOME=<scratch>/xdg timeout 1700 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . \
  --rendering-driver opengl3 --resolution 720x1280 res://tools/qa/playtest/core_loop_capture.tscn
```

## Measured feel data (meadow_02, `fall.g0` 0.6, lock_delay 600 ms)

- Countdown: 3000 ms. First spawn came at tick 180 as expected.
- Scripted move +x and rotate (spin) on piece 1 were both applied (`moved: true, rotated: true`).
- Gravity: a steady **100 ticks per row (1.67 s/row)**. Piece 1 took 18 gravity steps and **1788 ticks (~29.8 s)** to lock with no input. It spawns about 8 rows above the 10-layer play volume.
- Lock delay: 36 ticks (600 ms) passed between the last gravity step and the lock. This matches the knob.
- Next-piece randomness over 3 attempts of the same level (current + preview). The sequences differ, so the per-attempt reseed in `main.gd` works:
  - `tripod, screw_right, screw_left, t`
  - `screw_right, tripod, screw_left, l`
  - `tripod, screw_left, screw_right, screw_left`
- The bot reached 5 locks and 0 clears in 36 s of sim time before the harness wall cap. This is a harness speed limit, not a game finding.

## Findings

| ID | Severity | Level | Screenshot | Finding | Suggested owner |
|---|---|---|---|---|---|
| F-01 | S2-High | meadow_02 | meadow_02_mid.png | The falling piece is the same saturated blue as every locked block, and it floats far above the island with no drop line or column. Its depth cannot be read. The only cue for where it lands is the faint tan ghost patch on top of the stack, which is low contrast against the grass and dirt. | art-director / gameplay-programmer (ghost + piece tint) |
| F-02 | S2-High | meadow_02 | (log) | Unassisted fall is slow: 1.67 s per row and ~30 s from spawn to lock, with a spawn about 8 rows above the play volume. A player who does not know Drop/Soft exists waits half a minute per piece on a tier-2 level. | game-designer (fall.g0, spawn height) |
| F-03 | S2-High (needs repro) | meadow_02 | meadow_02_fail.png | With `goal.top_out: rescue` and warnings_max 1 (1/1 used), hard-dropping at spawn for more than 60 s wall time never ended the level, so the harness forced LOST. The level may be unfailable through stacking. Needs a manual repro before a bug report. | gameplay-programmer (rescue rule) |
| F-04 | S3-Medium | meadow_02 | meadow_02_mid.png | The NEXT tile caption shows the raw shape list "O, T, Tripod" under a single icon, while the tray shows a "THEN" preview twice. The next piece is shown in two places that disagree in format. | ui-programmer |
| F-05 | S3-Medium | meadow_02 | meadow_02_mid.png | Two stacked pills sit near the top: "Tilt & Roll" packed into the goal pill, and "Mascot Catch · Wobble · Wobble 0/10" below it. The meaning of "Tilt & Roll" is unclear (it is a control hint, not a goal), and "Wobble" appears twice. | ui-programmer / game-designer |
| F-06 | S3-Medium | meadow_02 | meadow_02_mid.png | The level timer is tiny ("0:36") and sits on the bottom frame edge. It is barely readable at 720x1280, yet stars are time-based. | ui-programmer |
| F-07 | S4-Low | meadow_02 | meadow_02_mid.png | The score tile shows 3 stars at 0/3 layers. This is star pace, not stars earned, but it reads as already earned. | ui-programmer |
| F-08 | S3-Medium | meadow_02 | (log) | Early-tier spawn mix is dominated by complex 3D shapes (tripod, screw_left/right) in all 3 attempts. On a tier-2 level this probably increases the difficulty more than intended. Needs the bag/weights to be checked. | game-designer |
| F-09 | S4-Low (QA tooling) | ice_04 | ice_04_*.png | Harness issue, not a game bug: re-calling `_start_level` on a main that is showing results did not replace the sim. The script now uses a fresh main per level. If players can reach this path (e.g. a "next level" flow calling `_start_level` directly), it is worth a check. | qa-tester (verify), gameplay-programmer if it reproduces through UI |

Camera framing (meadow_02): the island and stack are well framed in the lower half. The upper third is sky plus the floating piece, which uses vertical space but makes the piece look disconnected from the board (feeds F-01). Overlap: no HUD element covers the board. The bottom button rows ("View", "Soft", "0%", "Potion 0") are dense, and "0%" has no label.

"Can you tell what to do next?": partly. The goal pill is clear. Where the piece will land is not (F-01), and there is no prompt to press Drop while the piece drifts for 30 s (F-02).

## Top 5 fixes

1. **F-01**: Give the active piece its own tint or outline and a vertical drop column or shadow, and raise the ghost contrast (an outline plus emissive tint instead of a tan fill).
2. **F-02**: Lower the spawn height to just above the play volume, and/or raise early `fall.g0`. Add an idle "Tap DROP" hint after about 3 s.
3. **F-03**: Reproduce manually whether rescue levels (meadow_02 and similar) can be lost at all. File a BUG if they cannot.
4. **F-04 / F-05 / F-06**: Clean up the HUD. Use one next-piece presentation, separate the control hint from the goal pill, de-duplicate "Wobble", and enlarge the timer.
5. **Finish this playtest**: re-run the fixed script for all 8 levels to get the `_clear` (sparkle FX) and `_win` shots, and the ice, lava, underwater, pirate, carnival and hard-level data.
