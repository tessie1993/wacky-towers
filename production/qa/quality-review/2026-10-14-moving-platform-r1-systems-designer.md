# Moving platform core (G8), round 1, systems designer (blind expert 2 of 3)

Reviewed as a BUILD of a sim core (no capture exists; the preview strip and views are placeholders, per docs/architecture/moving-platform.md:3,58-62). Art not scored. Start at 5, earn each point, lower when unsure. Pass mark 9.7. Nothing was run (no engine in the sandbox); all findings are from reading the files.

## Scoreboard

| Item | Score | Why not higher (cap) |
|---|---|---|
| S1 Rule precision and fairness | 6.5 | Open defects D1, D2, D3, D5, D8 (cap 8.5), and rules are only partly precise |
| S2 Tuning and data | 6.0 | D6, D9: no rationale for any number, no validation of event params, cannot be sim-checked |
| S3 Counterplay and readability (preview feed) | 5.5 | D4, D7: feed is raw distance, hides chances, limits and cargo seat |
| S4 Failure and restart | 5.5 | D2, D10: total wipe, unspecified piece/queue state, possible stale-write leak |
| S5 Fit to race levels and fantasy | 5.0 | D11: no race (no rival, no clock, no par), no "fall over" lean/tilt |
| S6 Completeness for meadow_03 and bonus | 4.5 | D11, D12: no kite track, no rival, no Biscuit lean, track far shorter than the level plan, view/strip unbuilt |

Result: FAIL on every item. Strengths that earned points above 5: integer-um position with tick accumulation and chunk invariance (track_runner.gd:20-21,46-64, tested at track_runner_test.gd:86-96); seeded private rng stream and snapshot/restore including rng state (track_runner.gd:40,112-134, test :181-188); effects are in data not code (meadow_brook_run.json:25-31) and the sim has a clean def/runner/effects split (moving-platform.md:64-67). Not 10 because of the defects below.

## Ranked defects

D1 (S1, high). Bump "tilt test" is per-cell independent dice and the doc over-promises a cascade. track_effects.gd:83-91 rolls `randi_range` for every occupied cell; a cell made loose by an earlier removal in the same pass only gets `loose_pct_per_force * force` (30 or 60 percent), it is not guaranteed to fall. moving-platform.md:36 says "Removal cascades upward"; the test only passes because it forces 100 percent (track_runner_test.gd:9,105-107). A floating overhang can therefore survive a bump and stay in the air. Unsupported blocks surviving at 40 to 70 percent is neither the "tidy survives, loose falls" promise (levels.md:140) nor predictable. A player cannot plan around per-cell rolls.

D2 (S1/S4, high). Cargo loss is binary, invisible and keyed to a column the player may not see. track_runner.gd:176-195: seat is the contiguous column height at fixed (x,z); loss if drop > `max_drop_layers` (meadow_brook_run.json:15, value 2) or arch gap < seat+height. Contiguity means one removed mid-column block (even while the blocks above float, see D1) counts as a full drop of the whole column, so a single 30 percent roll at layer 1 of a 6-high cargo column loses the run. No gradation (tilt, wobble, warning) and no rationale for 2. Levels.md:153 says loss means "returns to the last post"; this gives a hair-trigger version with no telegraph.

D3 (S1, high). Crosswind does nothing to a tidy stack and ignores height. track_effects.gd:113 only moves `_loose` cells, so it is a no-op on any supported stack, while levels.md:395-396 says "a tall stack catches more wind". Also moved loose cells stay floating (no settle step), the cargo column cannot be hit (loose cells are never in the contiguous column), and an unknown `dir` silently becomes +x (track_effects.gd:133). Crosswind has no direct test (only appears in the determinism test, track_runner_test.gd:87). The kite level's main hazard is therefore unspecified and untested.

D4 (S3, high). The preview feed cannot be countered as built. track_def.gd:94-105 returns raw event dicts with `ahead_mm` only. Missing: time-to-event (speed changes per segment and during updraft, track_runner.gd:137-143, so the fixed 12000 mm window is 12 s, 10 s, 8.6 s and shorter in an updraft; JSON line 5), checkpoint rows, next-segment speed, the hit chance (30/60/10/20 percent live only in effects, not in the feed), the tall layer, and the cargo seat/limit. The feed also does not list the cargo's safe height for an arch (gap minus height_layers). Nothing guarantees a minimum lead time per event, and there is no validator for it. "Foresee the race track" is only half served.

D5 (S1, medium). Arch at gap 7 (meadow_brook_run.json:19) fires 12 s into play (12000 mm at 1000 mm/s). A player cannot have 7 layers by then, so the first arch is a dead event; the second and third (gap 6, lines 21,23) sweep every cell at layer >=6 (track_effects.gd:98-101) with no relation to the cargo seat. Event density (7 events in 60 m) and gaps are untuned; no sim shows a median build fits. Also the cargo loss test at an arch uses `after + height > gap`, i.e. column height must be <= gap-1, but this is stated nowhere in the doc (moving-platform.md:43 states it only in prose with a different form).

D6 (S2, high). Numbers have no stated rationale, and no sim spec exists. meadow_brook_run.json:25-31 (30, 10, 6, 60, 30, 3), segment speeds 1000/1200/1400 (lines 8-10) and the preview window 12000 are unexplained in moving-platform.md or the data (data-files rule: numeric values need a companion explanation). No safe ranges, no tuning table, no expected build-rate vs track-speed analysis. `cloud_bump` duplicates the bump numbers by hand (JSON line 27).

D7 (S3/S5, medium). Updraft's effect is only speed, and speed has no stated consequence. moving-platform.md:40; track_runner.gd:137-143. Without a rival or clock (D11) faster is neither good nor bad, and it also shortens build time per event distance. Lift scales with `stack_height()+1` re-read every tick, so speed jitters as pieces land. Updraft restart semantics: a second updraft overwrites the first (track_runner.gd:179-180), undocumented. The lift formula's height term is untested (fixture sets `height_pct_per_layer: 0`, track_runner_test.gd:10).

D8 (S1/S2, medium). Silent defaults and no event parameter validation. track_def.gd:176-197 checks kind and at_mm only. A missing `gap_layers` defaults to 0 and trims the whole stack (track_effects.gd:96), missing `force` to 1, missing `duration_ms` to 0, bad `dir` to +x, cargo x/z outside the board, percentages above 100, checkpoints not ordered against segments, `at_mm` equal to the track length all pass as valid. A typo in a hand-authored kite track would ship a lethal event.

D9 (S2, medium). The rule's data model cannot express what the level plans need: per-segment fall speed ("the fall speed rises with it", levels.md:154), Biscuit's side lean (levels.md:143,154), section difficulty, a rubber band, or a par time. Segment rows are only `{id, length_mm, speed_mm_s}` (moving-platform.md:9).

D10 (S4, medium). Restart design is a full wipe with unspecified state. track_runner.gd:209-227 clears every block and resets position; moving-platform.md:43 and levels.md:153 agree on wipe. Unspecified: the falling piece, next queue, score and goal metrics (`track_progress_pm` goes backward), hold slot, whether the same events at `at_mm == cp_mm` refire onto an empty board (the skip uses `<`, line 222), and any mercy after repeated loss (attempts is counted but never used, line 218). With one post at 30000 (JSON line 13) a loss at 29 s costs 29 s plus the whole cart, then the player rebuilds from zero for the arch at 34000. Possible leak: the restart sweep reads `api.kind_at` (line 214) while this event's writes are still queued (moving-platform.md:28), so a block moved by a queued `move_cell` may not be cleared; `_lose_cargo` also double-clears cells already dropped in the same event. Needs a test with a loss in the same step as a queued write.

D11 (S5/S6, high). Not a race. No rival, no clock, no par, no placement (levels.md:459,467 call both levels race; `race_rival` does not exist in G8). "Try not to fall over" has no tilt or balance model; the only fail is the cargo column rule (D2). "Build the car as you drive" is only served as stacking under random shakes; nothing rewards a clever shape beyond staying short.

D12 (S6, high). Shipping scope. Only one track exists (assets/data/tracks lists meadow_brook_run.json only); no meadow_bonus Kite Day track, no hamper/tip rule, no cloud posts, no Gert. Brook Run is 60000 mm = about 51 s of travel (20/1000 + 20/1200 + 20/1400 s) against a campaign slot of "~7 min" with 585/410 s star times (design/levels/meadow.md:49 and plans/meadow.md:24; note that table still calls meadow_03 Breezy Hill, so the level plan and levels.md disagree). Strip, views and camera are placeholders (moving-platform.md:3,58-62). Tests cover the pure core only; no rule glue test for `MovingPlatformRule` (moving_platform.gd:15-37), no crosswind, tall-layer, updraft-height, or replay-after-restart tests (track_runner_test.gd), and no solvability or survival simulation of the shipped track.

## Fixes with owners

| # | Fix | Owner |
|---|---|---|
| 1 | Replace per-cell dice with a defined rule: deterministic cascade (a block that loses support in a bump falls 100 percent), roll once per supported-base piece, and show the chance in the feed. Update the doc and test with real percentages. (D1) | systems-designer decides, gameplay-programmer builds |
| 2 | Cargo as a graded state: tilt/wobble levels with a telegraph, a visible seat marker, loss only on a sustained or severe hit; document the numbers. (D2) | game-designer (feel), systems-designer (numbers), gameplay-programmer |
| 3 | Define crosswind to affect tall and loose stacks (height-weighted push chance), add a settle step, validate `dir`, add tests. (D3) | systems-designer, gameplay-programmer |
| 4 | Extend `preview()` rows with `ahead_ms`, `severity`, `hit_pct`, `safe_height_layers`, checkpoint and segment rows, a min lead-time validator (e.g. every event previewed at least N s ahead at every speed). (D4) | systems-designer, ui-programmer |
| 5 | Write a tuning table (value, safe range, rationale, impact) in moving-platform.md and run a build-rate simulation (pieces per second vs layers vs event gaps) to retune the 7 events; make the first arch matter or drop it. (D5, D6) | systems-designer |
| 6 | Give updraft a stated purpose (race gain vs risk), document overlap/overwrite rule, add the height-term test. (D7) | systems-designer |
| 7 | Add schema validation: required params per kind, ranges, cargo inside the board, checkpoints sorted, `at_mm < length`. (D8) | gameplay-programmer |
| 8 | Extend the data model with per-segment `fall_speed_mult`, `lean`, and a `race` block (rival pace, rubber band, par). (D9, D11) | systems-designer, lead-programmer |
| 9 | Specify restart state (piece, queue, score, metric, mercy after N attempts, event refire at the post) and test the same-step queued-write wipe. (D10) | game-designer, systems-designer, gameplay-programmer |
| 10 | Lengthen/rebalance Brook Run to the plan's time budget, resolve the meadow_03 name/goal conflict between levels.md and plans/meadow.md, author `meadow_kite_day.json`. (D12) | level-designer, game-designer |
| 11 | Add tests: crosswind, tall layer, rule glue, replay after restart, shipped-track survival bot. (D12) | qa-lead, gameplay-programmer |

## Top 5 defects

1. D11/D12: not yet a race and not shippable (no rival or clock, no kite track, Brook Run about 51 s vs about 7 min plan).
2. D4: the preview feed lacks time, chance, safe height and checkpoint info, so events cannot be countered.
3. D1: bump uses per-cell dice with a partial cascade, contradicting the doc and "tidy survives".
4. D2: cargo loss is binary and hair-trigger on a contiguous column, with no telegraph.
5. D6: no rationale or sim for any tuning number (plus D3 crosswind being a no-op on tidy stacks).
