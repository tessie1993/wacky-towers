# Moving platform core (G8) round 2: systems designer review

Reviewer: systems designer (blind, one of three). Marked as a plan plus sim core (logic is built, UI, art and level
wiring are not). Rules applied: reference-quality-bar.md "Stricter marking" and "Three blind experts per aspect".
Pass mark 9.7 on every item.

Limits of this review: the Bash tool was not available to me, so I could not run `track_runner_test.gd` or
`track_rule_test.gd`. The doc's "25 tests" claim (moving-platform.md:5) is unverified by me. Everything below comes
from reading code, data and tests, plus hand arithmetic. Hand calculations are shown so the owner can reproduce them.

## Scoreboard

| Item | Score | Cap that applies | Why not higher |
|---|---|---|---|
| S1 rule precision and fairness | 6.5 | open defects, cap 8.5, and D1/D5/D6 are real fairness holes | the clock never binds; events can skip the cargo warning; topple has no dwell |
| S2 tuning and data, with rationale | 5.5 | open defects, "not simulated" | numbers are justified on a 4x4 board but meadow_03 is 8x8 |
| S3 counterplay and readability | 5.5 | not built (strip and meter UI absent) | data feed only; rows lack stress, stack-dependent safe height, honest direction |
| S4 failure and restart | 4.5 | open defect | a retry costs a flat 8 s and the 190 s / 175 s limit can never be reached |
| S5 fit to race levels and user decisions | 6.0 | open defects | decision 1 (time limit) is not enforceable; levels.md bump/Biscuit rules not modelled |
| S6 completeness for meadow_03 and bonus | 3.5 | not built | no level JSON, no HUD, no art, no balance sim, no bot, no stars |

None of the six passes. Strengths I can cite (why the scores are not lower): deterministic integer sim with
step-size independence (track_runner.gd:1-6, test at track_runner_test.gd:45-55); mandatory-parameter validation with no
silent defaults (track_def.gd:306-311, :314-332); a queued wipe that respects write order with a regression test
(rule_api.gd:284-287, track_rule_test.gd:48-58); an explicit seat tie-break chain (track_effects.gd:90-107).

## Ranked defects

### D1 (critical, S1 S4 S5): the time limit can never be reached, so "reach the finish before time runs out" cannot be lost

`_restart_from_checkpoint` sets `_elapsed_ms = _cp_elapsed_ms + restart_penalty_ms` (track_runner.gd:366).
`_cp_elapsed_ms` is only written when a post is passed (track_runner.gd:320), so every loss since that post rewinds to
the same value. Penalties do not stack, and the time spent on the failed attempt is refunded.

Finish time after any number of losses is always `base_drive + one penalty`:
- Brook Run: drive 150 s + 8 s = 158 s, limit 190 s (meadow_brook_run.json:5-6). Slack is never consumed.
  Hand check: gate at 134000 mm is 120 s in (40 s + 40 s + 40 s), +8 = 128, +30 s final = 158.
- Kite Day: 124 s + 8 s = 132 s, limit 175 s (meadow_kite_day.json:5-6).
- With `on_loss = checkpoint` (both shipped tracks, brook:9, kite:9) `track_failed` can only come from `fail` mode, which
  no shipped track uses. A player can lose the cargo at the same spot forever.

The doc claim "each loss costs time" (moving-platform.md:16) and the tuning row "two restarts at the 8 s penalty fit"
(moving-platform.md:94) are false. The test that "proves" time-up (track_runner_test.gd:169-176) only works because its
limit equals the drive time (10000 vs a 10 s track), so it hides the shipped-data case. No test loads a shipped track
and asks whether the clock can fail.
Fix (gameplay-programmer, systems-designer): make the clock monotonic. Options: (a) keep `_elapsed_ms` running and add
the penalty on top (a loss costs the wasted time plus the penalty, the usual checkpoint-race rule); (b) keep the
refund but make penalties cumulative (`_penalty_total_ms`); (c) add a loss budget. Then re-derive the limits:
limit = drive + k x (penalty + average segment replay). Add a test that loads both shipped tracks, forces N losses, and
asserts `time_up` fires.

### D2 (high, S2 S1 S6): tuning is justified for a 4x4 board, but meadow_03 is 8x8

The lean maths normalises by board width: `sx*1000/(cells*size.x)` (track_effects.gd:85-87). The tuning rationale
"one off-centre column (750) is survivable" (moving-platform.md:89) is the edge value of a 4-wide board only (W-1)/W.
On the real board, meadow_03.json:8-12 is 8x8 and the user's rule is "single-board levels are 8x8 or bigger"
(meadow_03.json:157):
- An edge-cell stack reads 875, which is above limit 800 and above danger 550. A lone first piece dropped at the edge
  topples instantly.
- Fixture tests use 4x4 boards (track_fixture.gd:29-30), so the shipped numbers have never been exercised on the
  shipped board size.
- Danger/limit are fractions of the half-width, so cell quantum is 125 on 8 wide versus 250 on 4. The limit 800
  is unreachable by COM alone on 4 wide (max 750) but reachable on 8 wide. The doc does not say which board
  each track targets.
- Gust: `layers x cells x strength x 60 / 100` (track_effects.gd:36) is quadratic in build size. A flat 8x8 board
  3 layers high gives 3 x 192 x 2 x 0.6 = 691 for strength 2 (kite gust at 118000, meadow_kite_day.json:128-132), nearly
  a topple from a perfectly centred, tidy build. The fixture comment (track_runner_test.gd:113-114) shows only 3x3 values.
- Updraft `lift = 10 + 12 x layers - cells` (track_effects.gd:39) clamps to 0 for most 8x8 builds
  (for example 4 layers, 50 cells gives 8), so the "tall and light gains most" reward may be invisible.
Fix (systems-designer): state target board size per track in the tracks and doc; re-derive danger/limit/gust/updraft on
8x8 with a build-rate model (D8). Add `board_width_ref` or normalise lean by a fixed reference. Cap gust and updraft
(add `max_impulse_pm`, `max_lift_pct`) so unbounded outputs (gust up to 8x8x10 layers x 3 = thousands) cannot occur.

### D3 (high, S1 S5): cargo can be lost with no warning, against decision 3 ("wobbles and warns before it falls")

Events add stress instantly (track_runner.gd:335) and `_update_cargo_state` loses the cargo whenever stress >= 1000
(track_runner.gd:285-287), skipping wobble and slip:
- Kite finale: gust strength 3 at 134000 adds 240, cloud_bump force 3 at 135000 adds 480 (meadow_kite_day.json:146-156,
  :168-171, :164-167). 240 + 480 = 720 lands in slip from zero. Add any prior wobble (300) and it exceeds 1000: lost
  with no warning step.
- A line clear that drops the seat adds 200 pm per layer at once (track_runner.gd:275-276). Dropping 5 layers is
  1000 pm, instant loss. Line clears are the core verb of the base game, and the levels.md pitch says "leave room to
  clear layers" (levels.md:141), so the system punishes the main verb.
- The preview does not list cargo stress at all (track_def.gd:187-209), so the player cannot see the kite's main threat.
Fix (systems-designer, gameplay-programmer): any single instant add (event or drop) is clamped so it cannot take the
cargo from below `slip_pm` to lost (clamp to 999 and require at least one tick in slip), or add a `min_slip_ms` dwell.
Add `cargo_stress_pm` to preview rows. Test: stress 600 plus a force 3 cloud bump must produce `slip` and then a save
window, not `track_cargo_lost`.

### D4 (high, S3 S6): the lean meter and preview strip do not exist

moving-platform.md:10 lists "HUD lean meter and preview strip UI" as not done. S3 asks for readable preview rows;
the rows are a dictionary only. Not built caps S3 at 7 and S6 lower. Gaps in the rows themselves:
- Only arches get `safe_height_layers` (track_def.gd:195-196). Crosswind and gust, which threaten lean and are
  stack-height dependent (track_effects.gd:33, :36), only show a per-layer impulse
  (track_def.gd:202, :205). The player must do the maths. A crosswind safe height would be
  `(limit - |com| - decay) / (per_layer x strength)`.
- Severity is not on one scale: arch is constant 3 (track_def.gd:195) and equals a force 3 bump or strength 3 wind
  (track_def.gd:198, :201), though an arch is an instant loss and a bump is not. Updraft is constant 1.
- Bump rows echo the data `dir` (row duplicates the event, track_def.gd:188), but the push actually goes to the heavy
  side unless the stack is exactly centred (track_effects.gd:167-173). The preview points the wrong way for any lopsided
  stack. Also a COM of exactly 0 uses the data dir, while COM of +1 flips to the heavy side: a discontinuity.
- `ahead_ms` ignores an active updraft (track_def.gd:191, uses base speeds), so the lead shrinks silently during lift.
  Lift up to 10 + 12 x L can be more than double speed; validation checks the lead only at base speed
  (track_def.gd:286-289).
Fix: ui-programmer builds the strip and meter (owner as in the doc). Systems-designer defines a common severity scale
(0-3 from "pm of lean at the current stack" and "kills cargo") and adds `safe_height_layers` for crosswind and gust,
`cargo_stress_pm` for every kind, and `dir_effective` for bumps.

### D5 (medium-high, S1 S3): topple has no dwell, no landing preview and can cascade

`_eval_lean` spills whenever lean >= limit, every tick, 4 cells at a time (track_runner.gd:247-252, lean json
`spill_cells` 4, brook:51). Lean from the COM is not relieved by the spill (only the impulse is,
track_runner.gd:256-258), so a COM above 800 strips the heavy side at up to 4 cells per 50 ms until COM falls.
Cargo has a save window (the 2.5 s the doc computes), lean has none: the player's own landing piece can push the
COM across the limit and the loss is that tick. The meter shows the board as it is, not what the landing piece will do.
There is one `track_lean_warning` per crossing (track_runner.gd:242-244) and no graded steps between 550 and 800.
Fix: add `topple_dwell_ms` (the lean must stay above limit for N ms; wobble feedback in between) or give spill a
rate limit, and provide a landing-piece lean preview in the HUD feed (`api.piece_cells()` already exists).

### D6 (medium, S1): arch is a cliff, and its trim path is dead code

An arch loses the cargo when `seat_h + height_layers > gap_layers` (track_runner.gd:341) with no graded warning, and
the trim removes cells with `y >= gap` (track_effects.gd:157-163). A cell with `y >= gap` means a column of height
`>= gap + 1`, which already implies seat_h >= gap + 1 > gap - 1, so the cargo is always lost first and the restart wipe
removes the blocks anyway. The trim and its `mutated` barrier never change the outcome. Either make the arch trim
without killing (a graded rule: trimmed blocks cost stress, the cargo survives when only the loose top is trimmed), or
delete the trim. Tests only cover the loss (track_runner_test.gd:117-122). Owner: systems-designer to choose, gameplay-programmer to implement.

### D7 (medium, S5): rules in levels.md and the decisions that the sim does not model

- levels.md:140 says a bump "shakes loose any block that is not supported". The sim applies lean impulse and cargo
  stress only (track_effects.gd:26-28) and never removes unsupported blocks.
- levels.md:143: Biscuit's weight sits on one side. No hook or lean offset exists.
- levels.md:601 says race stars come from finishing position; there is no rival this round (levels.md:607-608) and the
  goal exposes only progress and time_left (track_race_goal.gd:20-22). No star rule is defined for track_race, so
  the two levels have no scoring.
- The slot `fall.gravity_scale` is set absolutely to `pct x 10` (track_runner.gd:407), overriding the level's own
  `fall.g0` 0.7 (meadow_03.json:31). The effective base fall speed of Brook is not the level designer's number.
Fix: level-designer and systems-designer agree and document each; add a star rule (time_left bands, attempts).

### D8 (medium, S2 S6): no simulation behind the numbers, no survival bot, no shipped-track survival test

moving-platform.md:10-11 and :86 call the values "starting values, not yet balanced by simulation". The only shipped-data
test checks validity and `base <= limit` (track_runner_test.gd:7-12). Needed: a bot that builds a plausible stack under
the real spawn rate and gravity, and reports the loss rate per section and per cargo cause. Hand check of the Brook finale:
crosswind strength 3 at 166000 gives 30 x 3 x L pm on a centred stack. With L = 6 that is 540 and a force 3 bump a second
later (167000) adds 360 against a 60 pm/s decay, so about 857 >= 800 topples even a centred stack; safe height is 5.
That may be intended (it matches arch gap 6, safe height 5), but nothing in the data, preview or doc states it.

### D9 (low-medium, S1 S5): small rule gaps

- Cargo state has no hysteresis (track_runner.gd:288-296), unlike lean (:245-246), so stress hovering at 300 flickers
  `track_cargo_state` events and will flicker the HUD.
- Lean uses a max-norm (track_runner.gd:160): a diagonal lean (700, 700) reads 700 and is safe at limit 800, though its
  true magnitude is about 990.
- Restart replays the checkpoint with an empty board and a fresh piece: `clear_all` wipes everything
  (track_effects.gd:150-155, track_runner.gd:362). The loss therefore always resets to a safe empty deck (cargo on empty
  deck is stable, track_effects.gd:96). Pair this with D1 and a restart is a free reset. A rebuild cost (carry-over of
  some layers, or a slower first piece) is not designed.
- A restart is silent about hold-slot content (the doc lists "hold-slot reset" as not done, moving-platform.md:10).
- `TrackDef._validate_clock` stops after the first preview-lead error (`break`, track_def.gd:290), hiding later ones.
- Doc and code disagree on the word "permille of half-width" versus the dictionary key names; the test comment
  at track_runner_test.gd:68 is garbled ("(3 + 3 - 3 - 3... cells ...)").

### D10 (blocker for S6): not wired, not built

- meadow_03.json still has `goal.type = clear_n` and the `gust` rule (meadow_03.json:35-50); no file under
  `src/levels/meadow` references `track_race` or `moving_platform` (grep found none). `meadow_bonus` was not checked
  separately but the doc says the same (moving-platform.md:98-102).
- HUD, preview strip, real cart and basket art, level entries, balance sim, survival bot: all listed as not done in the doc.

## Fixes with owners

| # | Fix | Owner | Defect |
|---|---|---|---|
| 1 | Make the clock monotonic or the penalties cumulative; re-derive both limits; add shipped-track time-up test | gameplay-programmer + systems-designer | D1 |
| 2 | Re-derive lean/gust/updraft numbers on an 8x8 board; state board size per track; add output caps | systems-designer | D2 |
| 3 | Clamp instant stress so the slip step is always seen; stop line-clear drop stress from being a hidden kill; add stress to preview | systems-designer + gameplay-programmer | D3 |
| 4 | Build lean meter and preview strip; add common severity scale, crosswind/gust safe height, effective bump direction, updraft-aware lead | ui-programmer + systems-designer | D4 |
| 5 | Topple dwell or rate limit and landing-piece lean preview | systems-designer + gameplay-programmer | D5 |
| 6 | Decide arch graded trim versus kill; remove dead trim path | systems-designer | D6 |
| 7 | Reconcile levels.md with the sim (bump shake, Biscuit, stars, fall.g0) | level-designer + systems-designer | D7 |
| 8 | Build-rate simulation and a survival bot over both tracks; report loss per section | systems-designer + gameplay-programmer | D8 |
| 9 | Cargo hysteresis, norm choice, restart rebuild cost, validation without `break` | gameplay-programmer | D9 |
| 10 | Wire meadow_03 and meadow_bonus entries, remove clear_n and the old gust rule | level-designer (Godot master applies) | D10 |

## Why no item reaches 10 or 9

Every item has at least one open defect that a player or the user would notice (a race that cannot be lost, a cargo
that vanishes without warning, a meter that does not exist). The 9+ rule needs three citations and I could cite
strengths (above) but could not run the suites to confirm them, and any open defect caps at 8.5.
