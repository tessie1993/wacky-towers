# meadow_01 "Stump Day" mechanics build: gameplay programmer review (2026-10-15)

Method: reference-quality-bar.md strict marking; every item starts at 5. Reviewed as a BUILD. Ran
`gdUnit4 tests/unit/levels`: 35 cases, 0 failures (exit 0).
Pass = 9.7. A 9.6 is a fail. Result: FAIL on all five items.

## Scoreboard
| # | Item | Score | Cap reason |
|---|---|---|---|
| 1 | Implementation correctness and robustness | 8.0 | open defects (below) |
| 2 | Feel and feedback hooks per beat | 5.5 | only meter wired; no lock/release/rescue/win presentation consumers found |
| 3 | Data-driven | 8.5 | open defect: stale source/prod divergence risk, hardcoded fallbacks |
| 4 | Determinism | 7.0 | seed plumbed, but no replay test and no grip restore proof |
| 5 | Evidence completeness | 3.0 | 1 of 5 required captures exists (stage 0 only) |

## 1. Implementation correctness and robustness: 8.0
Evidence for:
- grip_release.gd:24-30 de-dupes on_clear per cell by `chain_round:layer`; `_seen` cleared on lock and resolve_end (lines 22-23). Test `test_one_grip_per_layer_clear_not_per_cell` passes.
- grip_release.gd:35 stops at `stages.size()`; `test_third_release_is_last_and_extra_clears_do_nothing` passes.
- rescue_top_out.gd:36-44 `rescue.layers` knob fixes the wipe at 3, decrements warnings, never touches layers_cleared or masks; `test_rescue_layers_knob_wipes_exactly_three_and_releases_no_grip`.
- Masks apply in the structural phase (board_sim.gd:1347,1373) so a release is ordered with settle.
Defects:
- D1.1 Dedupe key: two different layers clearing in one resolve with the same `chain_round` are fine, but a layer index that shifts after settle within one chain (layer 0 cleared, blocks settle, new layer 0 full) in the same chain_round reuses key `1:0` only if `_seen` is not cleared; it is cleared only on lock/resolve_end, so a same-round re-clear of the same index is silently dropped. Not covered by a test (tests only use distinct layers or one layer).
- D1.2 `_release` re-evaluates layer fullness never: after the pit widens, previously full layers become partial. The rule trusts the sim's clear counter rebuild (spec G1/G2 "layer counters rebuilt"). No test proves counters are rebuilt after request_mask (test uses a bare board, `test_level_loads_and_wins_on_third_clear_in_sim` only checks 16 active cells and never plays to a win; its name overclaims).
- D1.3 `_apply` in the test reproduces the sim's mask handling instead of running the sim, so the real path (request, deferred by ability veto at board_sim.gd:1361, then applied) is untested. A veto would defer a release silently.
- D1.4 Win path: goal `clear_n n=3` is driven by generic layer clears, not by `grip_release`. Spec section 3 says "driven by the new rule"; coincidence of counts only. A rescue never counts, but a clear on a stage-3 board is the win; no end-to-end test shows win on the third grip with input lock.
- D1.5 StarRater._neat: `2 = rescues <= n2_rescues_max OR pieces <= n2_pieces_max` lets a 3-rescue... (rescues 3 with pieces 28 gives 2 stars); acceptable but `or` means 0 rescues and 99 pieces also scores 2 (rescues 0 <= 1). So "some waste" never drops below 2 when no rescue is used; 1 star only after 2+ rescues AND >28 pieces. Differs from spec text (2 stars: one rescue OR some waste; 1 star: any win) in intent; thresholds flagged TO BE MEASURED.
- D1.6 Lose-and-restart in 2 s with a new seed: no test and no evidence found.

## 2. Feel and feedback hooks per beat: 5.5
Evidence for:
- `grip_released` emitted with grip, stage, of, sky_step (grip_release.gd:48); main.gd:1053 consumes it for the meter only; game_ui.gd:2036-2039 maps it to knot fill, no numbers; wt_meter.gd:38,87,135 draws knots.
- Banner before: main.gd:629-635 data-driven (`banner_before_ms`); strings tested.
- RESCUE_WIPED emitted (rescue_top_out.gd:43).
Defects:
- D2.1 No consumer found for `sky_step` anywhere in src or assets (grep: only grip_release.gd and main.gd mention grip_released). The sky never changes dawn/gold/sunset though `look.sky` is in data. Release beat has no sky, camera shake, ring of light, twang/rumble, or chord step.
- D2.2 No lock beat (hum, gold ripple) hook identified for meadow_01; no first-turn hint hook.
- D2.3 No rescue presentation consumer for RESCUE_WIPED in app/ui/view (cloud, whoosh, giggle), and the win beat has only the banner-after line (main.gd:643-647, 3 s delay from data); no bell, ring glow or input-lock hook found.
- D2.4 Meter knot "turns green and drops off" is drawn from a fill value: grip 1 gives fill 0.33 with no animated transition tied to the event, and no timing guarantee against the layer-clear VFX.
- D2.5 Event carries no cell/column list or timing, so the view cannot sequence "ring sweeps layer, then walls drop" without reading the board.

## 3. Data-driven: 8.5
Evidence for:
- meadow_01.json:30-44 knobs (g0 1.2, lock_delay_ms 900, resets 15, entry 300, warnings_max 3, rescue.layers 3); rules[0].params stages/ramp (lines 53-132); stars (135-141); hud meter (151-157); story timings (160-170).
- grip_release.gd:34-47 reads stages, `ramp_per_release_mult`, `ramp_cap_mult` from params; test asserts 1.25/1.5625/1.953125.
- `test_source_and_production_json_agree` enforces one source of truth.
Defects:
- D3.1 Fallback literals in code: `ramp_cap_mult` default 3.0 (grip_release.gd:46), `DEFAULT_MARGIN := 2` (rescue_top_out.gd:8), meter source string `"stump_grip"` and `"grip"` event key hardcoded in main.gd:1053/game_ui.gd:2036; the rule id `"stump_grip"` is a magic string shared across three files.
- D3.2 `board.mask` holds only the 4x4 pit; the cage columns exist only in rule stages. The spec's 52-cell round mask and `board.cage` keys (spec lines 59, 105) are absent, so the full-stump win state is implied by union of stages, not declared (no data check that stages union equals the 52-cell mask).
- D3.3 `ramp_per_release_mult` is a rule param, the spec lists `fall.g0`/`ramp.*` knobs; inconsistent knob namespace. `fall.gravity_scale` string is a literal in code.
- D3.4 Star thresholds (22/28 pieces) are still "TO BE MEASURED"; no G5/G6 bot data in repo.

## 4. Determinism: 7.0
Evidence for:
- BoardSim takes `round_seed` (board_sim.gd:110,126,137); rule state has `snapshot()` (grip_release.gd:51-52) and the sim snapshot includes runtime state (board_sim.gd:349). Rule logic holds no RNG and no wall-clock.
Defects:
- D4.1 `snapshot()` exists but no `restore` counterpart was found for this rule; `_seen` is duplicated but `_released` restore from a snapshot is untested. A replay or rewind mid-level could re-release or skip a grip.
- D4.2 No replay-determinism test with a logged seed (spec section 7 requirement); no test that the bag reseeds per attempt.
- D4.3 Bag tiling solver (G5, 98% of seeds) and bot sims absent, so "fair on every seed" is unproven.
- D4.4 Gravity modifier is re-requested each release with `mul` of pow(mult, n); deterministic, but `clear_modifiers` on level start only; after a rescue/restart inside one session the `_released` reset relies on on_level_start firing (tested only indirectly).

## 5. Evidence completeness: 3.0
Present: `production/qa/evidence/meadow_01/01-stage0-running-720x1280.png` (stage 0, 4x4 pit, plaque "Free the Hearth Stump.", NEXT, Stump Grip meter with 3 brown knots, Turn and DROP buttons, wizard cloud on the rim).
Missing (spec section 7 captures list): stage 1 (6x4), stage 2 (8x4), win beat, rescue beat, lose beat, post-grip frames, 5 s frame, wall-fade readability per stage. 1 of 5 requested = no capture for the other four beats, capped at 6, scored 3 by coverage.
Capture observations (defects visible to a player): no cage roots/stones are visible around the pit (the pit sits in a flat tree-ring floor with cream tiles), so grips have nothing to release visually; no landing ghost or falling block in frame; no "tight" feel for the first 2.2 s. Capture is not at-play-time proof of any mechanic.

## Why not 10 (all items)
Nothing reaches 9: each has open player-noticeable defects and fewer than 3 positive pieces of evidence at the 9 level; items 2 and 5 are mostly missing.

## Ranked fixes (owner)
1. (Godot master / main session, VFX+audio) Build consumers for `grip_released`, `RESCUE_WIPED`, lock and win: sky step from `look.sky`, 0.3 s shake, layer glow/ring, root/stone release animation, rescue cloud, win bell and banner-after at +3 s with input lock. Add event payload for columns and timing if needed.
2. (QA / level designer) Capture stage 1, stage 2, win, rescue, lose at 720x1280 into production/qa/evidence/meadow_01/, plus per-stage wall readability.
3. (Gameplay programmer) End-to-end sim test: play to a win through real BoardSim (mask via structural phase, ability veto path, counters rebuilt after widening, win on third clear, rescue never releases, new seed on restart); add restore/replay-determinism test with logged seed; fix D1.1 dedupe key to include a clear serial.
4. (Level designer / systems designer) Run G5 tiling solver and G6 speed bots; replace TO BE MEASURED star and g0 values; fix `_neat` OR logic or document it.
5. (Gameplay programmer) Put cage/stump masks and meter source ids in data (`board.cage`, one constant for "stump_grip"), validate stage union equals 52-cell mask in the loader.
6. (Game designer) Decide goal wiring: spec says win driven by `grip_release`; build uses clear_n=3. Align spec or code.
