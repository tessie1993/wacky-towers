# meadow_01 "Stump Day" - mechanics build review (game designer)

Date 2026-10-15. Blind reviewer, game designer lens. Marked as a BUILD against `.claude/docs/reference-quality-bar.md`
(start at 5, evidence per point, open defect <= 8.5, 9+ needs 3 evidence and why-not-10, no capture caps at 6, pass = 9.7 on every item).

Inputs read: spec `design/levels/meadow/meadow_01.md`; `src/levels/meadow/meadow_01/meadow_01.json`; `src/mechanics/behaviour/grip_release.gd`;
`assets/data/rules/grip_release.json`; `src/mechanics/goal/rescue_top_out.gd`; `src/core/sim/star_rater.gd`;
`tests/unit/levels/meadow_01_grip_release_test.gd`, `meadow_01_hud_rescue_test.gd`; capture `production/qa/evidence/meadow_01/01-stage0-running-720x1280.png`.

**Test run: NOT DONE.** My tool set had no shell, so the allowed gdUnit command could not be run. Test results below are from reading the tests only.
The orchestrator should run it and treat any red test as an open defect.

Only ONE capture exists (stage 0, running). There is no capture of grip 1, grip 2, the win, a rescue or a lose. Per the bar, a missing capture caps the item at 6.

## Scoreboard

| # | Item | Score | Pass 9.7 |
|---|------|-------|----------|
| 1 | Core loop and fun of the grip-release twist | 6.0 | FAIL |
| 2 | Teaching curve for a first level | 6.0 | FAIL |
| 3 | Pacing and difficulty ramp (x1.25 per release, pit 4-6-8) | 6.0 | FAIL |
| 4 | Fail and rescue fairness | 6.0 | FAIL |
| 5 | Goal clarity (story objective, no counts) | 7.5 | FAIL |

## 1. Core loop and fun of the grip-release twist - 6.0

Evidence for:
- The loop is one verb with a legible reward: one cleared layer = one grip = a wider pit. `grip_release.gd:24-30` (one grip per layer, keyed by chain_round:layer) and `:38-43` (mask on in all layers).
- Test `test_pit_widths_grow_four_six_eight_then_full_stump` (grip_release_test.gd:51-59) asserts 4, 6, 8, 8 columns and 52 cells at the end; `test_pit_cell_counts_are_16_24_32` (:62-69) asserts 16/24/32. Each stage is a rectangle, so no unfair pocket (spec section 3 "Fairness").
- The twist changes the rules of the next layer (the pit widens, part-filled layers need new cells), which is a real dynamic, not a cosmetic one (spec "Layer rule").
- Piece set O, I, L only, bag, one preview, no hold (json:24-36) keeps the decision space small enough to read the twist.

Defects:
- D1.1 No capture of any release beat. The twist, the actual fun, is unobserved: no ring of light, no wall drop, no sky step, no widened pit. Cap 6.
- D1.2 The one capture (stage 0) shows no falling piece and no landing ghost on the pit. Only the NEXT tile shows a gold block. I cannot confirm the micro-loop is visible in the build.
- D1.3 The capture shows no cage: no roots, no stones, no walls around the 4x4 pit. The pit is a lighter 4x4 tile patch on a big brown ring floor. The player cannot see what a "grip" holds, so the "release makes the wall go away" fantasy is not readable.
- D1.4 `grip_release.gd` only emits `grip_released` and changes the mask and gravity. Any juice (ring, twang, rumble, camera shake) is in the view layer, which I could not see.
- D1.5 Tension: a cleared layer widens the pit, which makes the next layer harder to fill (6 then 8 pieces), so the reward is a larger chore. It is intended as "the surprise", but nothing in the data gives the player a pull toward clearing beyond the objective text. Needs playtest proof.

Why not 10: the build is unobserved at the key moments, one retained capture, no playtest.

## 2. Teaching curve for a first level - 6.0

Evidence for:
- One new mechanic only; the old balloon rule is removed (json:49-134 has only grip_release). Matches the scaffolded-challenge rule.
- Small shape set and no hold (json:24-29, 36), `hud.hide_rules: true` (json:158) and 4 HUD elements only (json:142-148). Capture shows pause, plaque, NEXT, meter, Turn, Drop and nothing else.
- Spec onboarding (spec lines 19-31): finger-and-arrow at 4 s, down-arrow at 8 s, curved arrow for the first two turns, banner line at 2 s.

Defects:
- D2.1 None of the spec hint set is in the data or the tests. The JSON has banner keys only (json:166-169); there are no hint keys, no hint timers. The two test files cover none of the hints. The teaching beats are paper only. Cap 7, and no capture of any hint: 6.
- D2.2 No test or capture shows the first lock hum or first-turn chime.
- D2.3 The first full layer needs 4 perfectly tiled pieces on a 4x4 with an unfamiliar rotation set. The spec G5 tiling solver (98% of seeds per stage) is NOT in the tests (spec lines 207-208). If a bag deals an L first, a new player can create a hole in the first 4 pieces and the first lesson (clear a layer) is delayed. Unverified.
- D2.4 The "Turn" button in the capture is a small circle bottom left, "Drop" bottom right; no hint of which is which for first-time players beyond the label. Fine, but no first-10-seconds capture to judge.

Why not 10: hints and onboarding not built or not shown; no tiling proof.

## 3. Pacing and difficulty ramp - 6.0

Evidence for:
- Ramp is data-driven: `ramp_per_release_mult 1.25`, `ramp_cap_mult 3.0` (json:130-131), `fall.g0 1.2` (json:31). Test `test_speed_multiplies_1_25_per_release` asserts 1.25, 1.5625, 1.953125 (grip_release_test.gd:96-110).
- Back-of-envelope (spec 1.2 cells/s, ~9 s a piece at start): stage 0 is 4 pieces at about 9 s = about 36 s; stage 1 is 6 pieces at about 7 s = about 43 s; stage 2 is 8 pieces at about 5.8 s = about 46 s. Time per layer stays near flat (about 36-46 s) because the speed gain (x1.25) is smaller than the need gain (x1.5, x1.33). Total about 2 to 2.5 min, inside the 2-4 min target. Good sawtooth shape on paper.

Defects:
- D3.1 Everything is "TO BE MEASURED": `json:197` and spec section 3. G6 gravity, soft-drop and hard-drop bots are not run. No capture or number shows real piece time.
- D3.2 The ramp the player actually feels is x1.0, x1.25, x1.5625. The x1.953 from the third release never plays, because the third release is the win (`goal.n 3`, json:45-48). `ramp_cap_mult 3.0` can never be reached (1.25^3 = 1.95): a dead knob, and spec acceptance criterion 5 (cap test) has no test.
- D3.3 Time per layer is flat, so difficulty rises only slightly: the third stage is the widest (8 pieces) but at only 1.56x speed. For a "teach" level this is acceptable; for a "ramp" claim it is weak, and the final stage has no peak moment before the win.
- D3.4 Chain rounds: a settle can complete a layer (round 2) and fire an extra grip in the same lock (`grip_release.gd:26` keys by round). That can skip a stage beat (two widenings in one move) with no test. The `test_third_release_is_last...` test (:124-128) covers only extra clears after the last grip.
- D3.5 Speed multiplier is `pow(mult, released)` applied with op "mul" on `fall.gravity_scale` (gd:47). Does it replace or stack with the previous modifier? Tests do not cover the sim reading it (the sim test at :147-154 only checks warnings_max and 16 cells).

Why not 10: no measured numbers, no run, the last ramp step is never played, cap is dead.

## 4. Fail and rescue fairness - 6.0

Evidence for:
- Rescue never releases a grip and never counts as a clear: `rescue_top_out.gd:7-9` header, `:40-44`; tests `test_rescue_without_clear_releases_no_grip` (grip_release_test.gd:113-121) and `test_rescue_layers_knob_wipes_exactly_three_and_releases_no_grip` (hud_rescue_test.gd:43-61, asserts layers_cleared 0 and no mask request).
- Fixed wipe of 3 layers via `rescue.layers` (json:43, rescue_top_out.gd:36-39) and 3 rescues (json:42) is generous for a teach level. Top-out limit is 8 layers (json:10).
- Neat stars cannot be farmed by stalling: no clock (`star_rater.gd:38-47`), tests at hud_rescue_test.gd:64-71.

Defects:
- D4.1 No capture of the rescue beat or lose beat; cloud giggle and whoosh unobserved. Cap 6.
- D4.2 `rescue_top_out.gd:44` returns LOST if the stack is still over the limit after the wipe. With a fixed wipe of 3 and a limit of 8, this is unreachable in normal play, but there is no test for a double top-out or for the 4th top-out restart (spec acceptance 7: restart in 2 s or less). The restart path is untested.
- D4.2b The fixed `k = 3` overrides the formula even when the stack is far above the limit (rescue_top_out.gd:38-39). It is fine at h_play 8, but `LOST` after a wipe that cannot clear the overflow would feel unfair; no test.
- D4.3 Star 2 uses OR: `rescues <= 1` OR `pieces <= 28` (star_rater.gd:45). The 3-star bar is 22 pieces vs a hard minimum of 18 (spec section 3) = only 4 wasted pieces, with a random bag and 4+6+8 tiling. Both values are labelled TO BE MEASURED (json:140). Possible 3-star frustration for a teach level; unknown without bot data.
- D4.4 Failure is almost impossible by design (8-layer limit on a 16-cell pit and 3 rescues), so the lose state is likely never seen; the "blocks giggle into the box" beat may never be tested by real players. Fine for a teach level, but it means no real stakes.

Why not 10: no capture, restart and double-top-out untested, star thresholds unmeasured.

## 5. Goal clarity (story objective, no counts) - 7.5

Evidence for:
- Capture shows the plaque "Stump Day / Free the Hearth Stump." at the top centre, readable at 720x1280, with no count and no timer. Matches json:149 and the test at grip_release_test.gd:136.
- Stump Grip meter is three bark knots, no numbers, left-bottom (capture; json:151-157); `hud.show` has no `clock` (json:143-148).
- Win is a single path, clear_n 3 behind the rule, never shown (json:45-48, spec "Goal"). `test_strings_exist_in_localisation_csv` (hud_rescue_test.gd:27-34) pins the keys.

Defects:
- D5.1 The objective says "stump" but the capture shows no stump read: a flat brown ring floor, no roots, no stones, no cage. The player cannot connect "Free the Hearth Stump" to anything on screen. Open defect, so <= 8.5, and I take it lower.
- D5.2 The meter sits bottom-left, far from the pit and the plaque; its meaning ("grips") is only a label "Stump Grip". It is not shown to the player that layers drive it. The player must learn "clear a layer" with no word for layer allowed (spec rule: no "clear", no "layers"); the only teaching channel is the hint set, which is not built (D2.1).
- D5.3 Banner lines are keys only; I did not see them rendered. No capture at 2.0 s.
- D5.4 `level_type "funny"` (json:183) with an "after" banner only; no player-facing proof of humour in the build.

Why not 10: the objective text is clear but the world does not show what is gripped; no win or banner capture.

## Ranked fixes

1. **[owner: world/level maker + main session builder]** Capture the missing beats at 720x1280: first 10 s, a piece falling with ghost, grip 1, grip 2, win, rescue, lose. Make the cage (roots left, stones right, rim) visible around the 4x4 pit at stage 0, so "Free the Hearth Stump" and the release are readable. Caps on items 1, 3, 4 lift only with these.
2. **[owner: systems designer + main session]** Run G5 tiling solver (98% of seeds per stage, O/I/L, 1-lookahead, no hold) and G6 gravity/soft/hard-drop bots. Replace the "TO BE MEASURED" values (g0 1.2, ramp 1.25, rescue 3, warnings 3, stars 22/28) with measured ones and record them in the spec.
3. **[owner: gameplay programmer / main session]** Build and test the hint set (4 s slide, 8 s drop, first 2 turns, first lock hum) and the missing spec tests: speed cap, replay determinism, no forbidden strings, restart in 2 s, double top-out, two clears in one lock, `input_simulate` presets.
4. **[owner: game designer]** Decide the dead ramp: the x1.953 step never plays, and the cap 3.0 is unreachable. Either apply the ramp on stage entry (so stage 3 plays at x1.5625 and the win gives the peak), raise the multiplier, or drop the cap knob. Also decide whether star 2 should be OR.
5. **[owner: game designer + level designer]** Consider moving the Stump Grip meter next to the plaque or pit and give the first release an on-screen cue so the player learns the layer to grip link without count words.
6. **[owner: main session]** Run `timeout 300 godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/levels --ignoreHeadlessMode` and attach the result; this review could not run it.

## Verdict

FAIL: every item is below 9.7 (6.0, 6.0, 6.0, 6.0, 7.5). The rule logic and data are sound and unit-tested on paper; the build has not yet been shown to play.
