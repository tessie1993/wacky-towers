# Moving platform core (G8), round 2: game designer review (blind expert 1 of 3)

Reviewer: game designer. Scope: the design the sim core enables, not art. Marking: `.claude/docs/reference-quality-bar.md`
"Stricter marking" (start at 5, earn each point, any open defect caps at 8.5, unsure means lower, pass is 9.7 on every item).
Inputs read: docs/architecture/moving-platform.md, both track JSONs, track_runner.gd, track_effects.gd, track_def.gd (preview and
validation), track_race_goal.gd, the three files in tests/unit/track/, levels.md (meadow_03, meadow_bonus, section 8),
src/levels/meadow/meadow_03/meadow_03.json. I did not open any earlier review. Nothing was run: scores come from reading the
files and from hand arithmetic on the shipped numbers (shown in the defects, so they can be checked).

## Scoreboard

| Item | Score | Pass 9.7 | Main reason |
|---|---|---|---|
| D1 core loop and fun | 6.0 | FAIL | Loop is coherent on paper and the sim is solid, but nothing is playable: no HUD, level not wired, tuning never simulated. |
| D2 meaningful decisions | 5.5 | FAIL | "Keep a low, flat, centred plateau" beats every alternative; risk is never paid; the kite's tall-light choice has no payoff. |
| D3 learnability and readability from the preview | 5.5 | FAIL | Good data feed, but the strip and lean meter are unbuilt, bump direction cannot be previewed, the cargo warning has no cause. |
| D4 pacing along each track | 6.0 | FAIL | Sensible ramp and teaching order, but the first minute is harmless for a tidy stack, the clock never bites, long replays on late loss. |
| D5 variety between cart and kite | 6.0 | FAIL | Different event vocabulary and limits, but one sim, one winning posture, and the kite's signature trade-off is dead. |
| D6 fit to fantasy and decisions | 6.5 | FAIL | All three section 8 decisions are implemented; "race" and "foresee" are not yet felt. |

Lowest: D2 and D3 at 5.5. Verdict: FAIL (every item is below 9.7 and every item has open defects, so each is capped at 8.5 at best).
The caps for unbuilt player-facing parts also apply: the preview strip, lean meter, cargo view and level wiring are not built
(moving-platform.md:9-11), and no capture exists.

Balance-check read of the shipped numbers (no registry entry or GDD gives targets, so targets are the doc's own tuning table,
moving-platform.md:86-96): health CRITICAL ISSUES, because of a degenerate strategy (defect 2). Source docs say the values are
"starting values, not yet balanced by simulation" (moving-platform.md:86), so this is expected, but it cannot pass.

## What earns the points (evidence for each score)

- Deterministic, dice-free sim with explicit tie-breaks, tested across step sizes: track_runner.gd:1-6, runner_test.gd:45-55.
  Every loss is therefore a cause the player could have read. This is the base of the 6.0 on D1.
- Bump pushes toward the heavy side while crosswind has a fixed direction: track_effects.gd:166-173 against :32-34. This gives
  one real decision (pre-weight into the wind, centre for bumps). It lifts D2 above 5.
- Section 8 rules map one to one onto code: survive to finish (track_race_goal.gd:12-17), lean past limit spills the heavy side
  (track_runner.gd:247-252, track_effects.gd:117-146), building light side rights it (runner_test.gd:58-69), cargo
  wobble then slip then lost with a save window (track_runner.gd:283-296, runner_test.gd:135-147). This is D6.
- Preview feed carries time ahead, severity and safe height, and validation forces every event to be previewed at least 8 s ahead:
  track_def.gd:187-209, :284-289. This is the only D3 credit.
- Event teaching order is sound: bumps at 20 and 30 m, first crosswind at 38 m, first arch at 66 m (brook_run.json:68-109), so
  mechanics arrive in isolation before they combine.

## Ranked defects

### 1. Tuning is unvalidated and written for a 4x4 board, but the level is 8x8x10 (blocks D1, D2, D4)
- Tests and fixture use a 4x4x10 board and `spill_cells: 2` (track_fixture.gd:11, :29); the shipped tracks use `spill_cells: 4`
  (meadow_brook_run.json:51) and the level board is 8 by 8 by 10 (meadow_03.json:7-12).
- "One off-centre column reads 750" is a W=4 number (moving-platform.md:90; track_effects.gd:77-87). On 8 wide an edge cell reads 875.
- The gust and updraft formulas use absolute cell counts (track_effects.gd:36, :39). A strength-3 gust on 5 layers with 150 cells
  is 5*150*3*60/100 = 1350 pm, an instant topple. The same stack on 4x4 (80 cells) is 720. The track data cannot be right on both.
- Arch gaps of 6 and 7 layers (brook_run.json:100-103, :123-126) are probably never reached on an 8x8 board: 150 s of pieces is
  roughly 2 to 3 average layers over 64 columns, so the arch may never fire. Unverified; that is the point.
- `test_shipped_tracks_are_valid_and_winnable` only checks that the limit is at least the drive time (runner_test.gd:7-12). It does
  not show any build can survive the track. The build-rate simulation and survival bot are listed as not done (moving-platform.md:11).
- Owners: systems-designer (normalise cell terms by board area, or put a board spec in the TrackDef), gameplay-programmer
  (survival bot with sloppy, average and expert placement profiles, run on both shipped tracks at 8x8).

### 2. Dominant strategy: a low, flat, centred plateau beats every alternative (blocks D2, D1)
Hand arithmetic on the shipped numbers, for a perfectly centred stack with a level 5-of-9 seat:
- A centred stack takes the event's own direction (track_effects.gd:169-170), so a bump is 120 per force (brook_run.json:182):
  at most 360. Crosswind is 30*layers*strength (brook_run.json:186). Worst centred case is the finale: wind 3 and bump 3, 0.7 s apart
  (brook_run.json:167-178), is 90*5 + 360 - 43 decay = 767 pm at 5 layers, which is under the limit of 800. Nothing else on the
  track reaches the 550 danger line for a centred stack. The lean system is therefore inert for tidy play on most of the track.
- With a stable seat the rate is -220 + 160 = -60 pm/s even while leaning (track_runner.gd:266-269), so lean never hurts a level
  seat. Worst event stress is 544 pm on the kite (cloud 3 plus gust 3, kite_day.json:145-156, 170) and about 413 on the cart;
  slip is 650. A level seat cannot lose the cargo to events.
- Arch at 6 or 7 layers only punishes a player who is already sloppy (track_runner.gd:341).
- Nothing pays for risk: there is no speed lever, no bonus and no star rule that uses height, mass or cargo state. So no one has
  a reason to leave the safe posture, and the preview has little to change.
- Fix: decide which choices should be tempting. Candidates for the user: (a) make a stable seat still tire under lean
  (lean_stress above recover), (b) a reward for height or risk (see defect 3), (c) one event per section that cannot be answered
  by being low and centred (for example a gust that comes from the side the stack is lightest on). Owner: game-designer with
  systems-designer; (a)-(c) are a decision for the user.

### 3. The clock is a hidden life counter; the player has no speed lever, so there is no "race" (blocks D6, D4, D2)
- A restart sets elapsed to the post's elapsed plus the penalty (track_runner.gd:366), so the distance replayed is free and a loss
  costs exactly 8 s. Brook slack is 190 - 150 = 40 s, which is 5 restarts (brook_run.json:5-6); the kite is 175 - 124.3 = 50.7 s,
  which is 6 (kite_day.json:5). Speed is fixed per segment in the cart, so nothing the player does can save or lose time.
- Docs disagree with the data: "two restarts fit" (moving-platform.md:94) and "once or twice" (brook_run.json:10) against five.
  levels.md:153 says Brook Run has "no countdown", yet the JSON has a 190 s limit; section 8 allows a clock (levels.md:607-609).
- The user's fantasy is a Tetris race. With no rival (section 8 removes it) and no speed control, the "race" is a survival timer
  that can only be failed by dying five times. Stars for races "come from the finishing position" (levels.md:600-601), which no
  longer exists; `time_left_ms` and `attempts` are emitted at finish (track_runner.gd:391) but no star rule uses them.
- Fix options for the user: (a) clean play raises speed (clears or a stable seat give a boost), so time is earned; (b) tighten the
  limit to the drive time plus about two penalties and say so in the doc; (c) show "restarts left" instead of seconds. Also define
  stars from attempts and time left. Owners: game-designer (rule), creative-director (decision), level-designer (stars).

### 4. The kite's signature trade-off, the updraft, is dead (blocks D5, D2)
- Lift is 10 + 12*layers - cells (track_effects.gd:39). On the 8x8 level, 3 flat layers (over 46 cells) give 0. Even a good case
  saves 5 s * lift/(100+lift) of a clock that does not bind (defect 3): at most about 2 s per updraft, 5 updrafts, under 11 s in total
  (kite_day.json:65-69, :83-86, :112-115, :141-144; duration 5000 ms).
- It also costs the player: faster travel means less time to build before the next event, with fall_pct unchanged
  (kite_day.json:14-17). The updraft at 128 m pulls the player into the gust 3 plus cloud 3 finale 6 m later
  (kite_day.json:140-156).
- The reward posture (tall and light) conflicts with the seat rule (5 of 9 columns within one layer: track_effects.gd:111-113,
  :176-184; kite_day.json:54), so the player must build wide, not light.
- Fix: give the updraft something the player wants (a lull that pauses the fall, a free seat settle, or a gust shield) or cut it.
  Owner: systems-designer; level-designer to move the 128 m updraft before the finale.

### 5. Cargo warnings and the preview do not tell the player what to do (blocks D3)
- The wobble record carries state and stress but no cause (track_runner.gd:169-171, :295), although the cause is computed one
  line earlier (:283). Cloud bumps add 160 per force straight to stress (kite_day.json:170), so a force 2 bump is 320, over the
  wobble line of 300 (kite_day.json:56), whatever the seat. On the kite the warning fires for unavoidable jolts as well as for a
  bad seat, so it cannot be learned as "fix your seat". It will cry wolf at 56, 98 and 119.5 m (kite_day.json:87-92, :116-121,
  :134-139).
- Bump direction depends on the stack (track_effects.gd:166-173), so a preview row cannot state it: rows have only `impulse_pm`
  (track_def.gd:197-199). Wind rows show a per-layer number, not the resulting lean for the player's own stack
  (track_def.gd:200-205).
- The preview strip, lean meter and cargo view are not built (moving-platform.md:9-10; no track HUD code in src/ui/game_ui.gd).
- Fix: add `cause` to the cargo state record and split "jolt" from "seat" stress so the warning only means the seat; add
  `predicted_lean_pm` to the preview rows (given the current stack, computed by TrackEffects) and the heavy-side arrow for bumps.
  Owners: systems-designer (stress split), ui-programmer and ux-designer (strip and meter), gameplay-programmer (feed).

### 6. Spec and implementation diverge in four places (blocks D6)
- Arch: levels.md:140 says it "sweeps anything taller than the gap off the top"; the code loses the cargo and wipes the board
  (track_runner.gd:341-342, :361-363). The trim code is dead, because cells at or above the gap exist only when the cargo is
  already lost (track_effects.gd:157-163). One layer over the line costs the whole build plus 8 s, with no wobble stage, against the
  section 8 rule that the cargo "wobbles and warns before it falls" (levels.md:613-614). It is previewed, but a cliff next to the
  graded lean topple is inconsistent.
- Biscuit's weight "adds a lean" (levels.md:143, :154): no event kind exists for it (track_def.gd event kinds; brook_run.json).
- The level is not wired: meadow_03.json still has `clear_n` with a `gust` rule (meadow_03.json:35-49); the wiring is listed as open
  (moving-platform.md:98-102).
- The bonus text still has the rival and "second place passes" (levels.md:397, :402), against section 8 (levels.md:607-609).
- Owners: level-designer (wiring, bonus text, Biscuit), creative-director (arch as a cliff or a graded sweep), narrative-director
  consulted on the Biscuit beat.

### 7. Failure cost is uneven and the drop stress punishes the core Tetris reward (blocks D4, D1)
- A loss wipes the whole board (track_runner.gd:362) and replays from the last post. The kite has one post at 70 m of 142
  (kite_day.json:37-42); a loss at 140 m replays 72 m, about 58 s of real play. The cart's late loss at 133 m replays 45 m, about 34 s.
  The clock refunds it (defect 3), the player does not get that time back.
- Seat drops add 200 per layer (track_runner.gd:275-278; brook_run.json:65). A three-layer clear is 600 stress, a four-layer clear is
  slip, and a five-layer clear (1000) loses the cargo on a good move. The wipe then removes the evidence. This may be intended
  tension (clear gradually before an arch), but it is not telegraphed or tested at that size (runner_test.gd:150-158 uses one layer).
- Fix: add a kite post near 35 and 105 m; consider keeping the bottom two layers on restart; cap or telegraph the drop stress.
  Owners: level-designer (posts), systems-designer (cap).

### 8. Pacing: the first minute is nearly harmless and the difficulty arrives as a late spike (blocks D4)
- Brook: force 1 bumps (120 pm) and a strength 1 wind arrive in the first 38 m, 38 s (brook_run.json:68-92), far under the 550
  danger line for any tidy stack. The peak force per section is 1, 2, 2, 3 (120, 240, 240, 360), so sections 2 and 3 are the same
  size and the real step is the finale (brook_run.json:167-178). Section 3 does not end on a cluster: its events end at 124 m and
  the next is 142 m (brook_run.json:139-149), against the notes "ends in a hard cluster" (brook_run.json:10).
- Fall speed rises 100 to 135 percent while the preview lead falls from 14 s to 10 s at 1400 mm/s (brook_run.json:7, :34): both
  push the same way. This is a sensible ramp, but unproven (defect 1).
- Fix: after defect 1, place the first real test (force 2 or a tall-stack wind) in section 1, and make section 3 end in a
  cluster. Owner: level-designer.

### 9. Test evidence overstates what is covered (blocks D1 confidence)
- The test named "winnable" checks the clock only (runner_test.gd:7-12). The topple test uses `spill_cells: 2` (runner_test.gd:77,
  track_fixture.gd:11) while the tracks ship with 4. A comment at runner_test.gd:68 is garbled. No test touches an 8x8 board, an
  arch on the shipped tracks, or the final cluster. The restart regression test is good (track_rule_test.gd:48-58).
- Owner: gameplay-programmer. Add shipped-track survival tests (from the bot in defect 1) and rename the winnable test.

## Fixes by owner (merged, in order)

| Order | Owner | Fix | Defect |
|---|---|---|---|
| 1 | systems-designer + gameplay-programmer | Build-rate sim and survival bot at 8x8 on both tracks; normalise cell-count terms by board area | 1 |
| 2 | creative-director (decision) + game-designer | Choose what makes risk worth taking and what the clock means (speed lever, tighter limit, or lives); define race stars | 2, 3 |
| 3 | systems-designer | Make the updraft pay or cut it; split jolt stress from seat stress; cap drop stress | 4, 5, 7 |
| 4 | gameplay-programmer | Add `cause` and `predicted_lean_pm` to the feeds; shipped-track tests; rename the winnable test | 5, 9 |
| 5 | ui-programmer + ux-designer | Build the preview strip, lean meter and cargo view from the feed | 5 |
| 6 | level-designer | Wire meadow_03 and meadow_bonus; fix bonus text and Biscuit; add kite posts; rebalance the finale and section 3 | 6, 7, 8 |

## What is needed to pass

A playable build with a capture, a survival bot over both shipped tracks at the real board size, and a design answer for the
dominant strategy and the clock. Until then no item can honestly be marked above 8.5, and the scores above are held to what the
files show.
