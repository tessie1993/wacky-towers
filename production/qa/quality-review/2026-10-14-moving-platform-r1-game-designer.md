# Moving platform core (G8), round 1, game designer

Reviewer: game designer (blind). Kind of thing marked: a mechanics BUILD of the sim core (pure logic, unit-tested), with a
placeholder view. I judge the design the core enables, not art. Pass mark 9.7. Every item starts at 5 and is earned up.
Any open defect caps at 8.5. All scores below are far under that cap because the defects are structural.

Method note: I read the files listed in the brief plus `design/levels/levels.md` (meadow_03 lines 131-161, meadow_bonus
lines 386-415) and `level-identity-spec.md` lines 116-130. I did not run the game. I checked that only one track exists
(`assets/data/tracks/` holds only `meadow_brook_run.json`).

## Scoreboard

| Item | Score | Why (short) |
|---|---|---|
| D1 core loop and fun | 5.5 | Event-by-event the sim is sound, but progress never depends on the player, so "race" and "build as you drive" are not yet the loop |
| D2 meaningful decisions | 5.0 | One dominant strategy: a tidy, short stack ignores almost every event; cargo can be made immune |
| D3 learnability | 5.5 | The preview feed is good and the events are simple, but there is no teach-by-play ramp and no failure explanation data |
| D4 pacing along the track | 4.5 | Brook Run is about 51 s, events per second do not rise, the last 10 m is empty, the sample contradicts the level doc |
| D5 variety, cart vs kite | 4.0 | Kite Day has no track, no rival link, and 3 of 5 event kinds have no content or a one-sided effect |
| D6 fit to the user's fantasy | 6.0 | "Foresee the track" is real; "race" and "try not to fall over" are not |

Overall: FAIL. No item is near 9.7. Items scoring above 7 would need 3 citations and none qualify.

Positives that earned the points above 5 (for the record):
- Deterministic, seeded, replayable sim with chunk-independent stepping (`docs/architecture/moving-platform.md:20-26`,
  `tests/unit/track/track_runner_test.gd:86-96`). This lets a designer balance by simulation.
- A preview feed is a first-class output (`src/core/track/track_runner.gd:107-109`, test at `track_runner_test.gd:52-59`),
  and the preview window shrinks in seconds as speed rises (`meadow_brook_run.json:5` vs `:8-10`): a free difficulty ramp.
- All tuning is data-driven (`meadow_brook_run.json:25-31`), good for iteration.
- A fair, no-clock loss with a checkpoint (`track_runner.gd:198-227`), matching `levels.md:153`.

## Ranked defects

### 1. (Critical) The track moves at a fixed speed; the player cannot race, so there is no race
- Position advances only by the segment speed (`track_runner.gd:62`, `meadow_brook_run.json:8-10`). The only player-driven
  term is the updraft stack-height bonus (`track_runner.gd:141-143`), and no event in the sample is an updraft.
- Nothing the player builds changes how soon the lawn is reached. Win = the cargo survives for about 51 s. Brook Run is a
  survival-with-a-basket level, not "a Tetris race" (`levels.md:133`).
- The user fantasy "build your car as you drive" (`level-identity-spec.md:125-126`) needs the build to matter to the drive.
  Today the cart is a stack on a scrolling floor, which is exactly the failure mode the brief asks me to look for.
- Fix: give the build a cost or a benefit on speed. Options: cart weight or height slows or speeds the segment (a
  `mass_pct_per_layer` knob), cleared lines give a boost, wasted pieces cost time. Add a measurable "race" quantity (lap time
  vs a par or the rival) for stars (`levels.md:506`). Decide which in a short design memo first.
- Owner: game designer (decision), systems designer (formula), gameplay programmer (`track_runner.gd`).

### 2. (Critical) Dominant strategy: stay tidy and short, and nothing is ever at risk
- `_loose()` is true only for a block with an empty cell below (`track_effects.gd:71-72`). Bumps roll only loose blocks (30
  percent per force, `meadow_brook_run.json:26`) plus blocks at layer 6 or higher (10 percent per force). A stack with no
  overhang and under layer 6 takes zero damage from all three bumps. Crosswind also touches only loose blocks
  (`track_effects.gd:113`).
- The arch only needs the stack under 6 or 7 layers (`track_effects.gd:99`, `meadow_brook_run.json:18,21,23`). A stack
  under layer 6 is safe from every event in the sample.
- So the optimal play is "stack neatly, stay low". That is just normal Tetris and needs no foresight. The preview is
  decoration for a player who already plays safe. Meaningful decisions (D2) need a trade-off, and there is none.
- Fix: make height and tidiness trade against something the player wants (see defects 1 and 3). Give bumps a small base
  chance on any block of the top layer or on the cart edge, or make force shift the stack sideways (lean) so well-supported
  stacks still need management. Add events that ask a different question from "stay low".
- Owner: systems designer (bump model), game designer (decision).

### 3. (Critical) The cargo is trivial to make immune, so it creates no tension
- The cargo is lost only if the arch gap is less than seat plus height (`track_runner.gd:193-194`), or if a single event
  drops the cargo column's height by more than 2 (`track_runner.gd:195`, `meadow_brook_run.json:15`).
- Column (1,1) holds the seat. If the player never builds on (1,1), the seat is 0, and neither condition can fire (arch
  needs height 6 or more at `meadow_brook_run.json:21,23`; a drop needs height 3 or more). Unlike a protected piece the
  cargo has no interaction with the player's builds, so it is a pre-cleared tile, not a threat.
- On a supported column only the tall-layer 10 percent roll (`meadow_brook_run.json:26`) can drop it. The documented
  "cascade" (`moving-platform.md:36-37`) is really a 30 percent roll per newly loose block, not a guaranteed cascade, so
  even a 3-drop is unlikely. The unit test hides this by using 100 percent (`track_runner_test.gd:9,107`).
- The cargo is also invisible to every event but arch and bump: crosswind and updraft cannot move or hurt it.
- Fix: make the cargo a thing the player builds around: a heavy item that must be seated each time, that shifts on crosswind,
  that tips if the support under it is narrow (width of support, not just column height), or that rides a column the player
  cannot avoid (centre of the cart). Add a loss cause that depends on how the stack is shaped.
- Owner: game designer (cargo rules), systems designer (formulas).

### 4. (High) Pacing: the sample track does not match the level doc, and the curve is flat then empty
- `levels.md:154` says "the events come more often" and fall speed rises. In `meadow_brook_run.json:17-23` events come at 6,
  12, 18 (segment 1), then 26, 34 (segment 2), then 42, 50 (segment 3). Per second at the segment speeds that is 3 in 20 s,
  2 in 16.7 s, 2 in 14.3 s: 0.15, 0.12, 0.14 events per second. The density does not rise; segment 2 is the quietest.
- The whole run is 60 m at 1.0 to 1.4 m/s, about 51 s (`track_runner_test.gd:55`, `meadow_brook_run.json:8-10`). At the
  halfway post a restart costs about 17 s of replay. A first-time player may place only a handful of pieces before the first
  arch at 12 m (about 12 s). A 51 s level with 7 events is a tutorial, not a campaign level.
- Arch gaps go 7, 6, 6 (`meadow_brook_run.json:18,21,23`) and bump force goes 1, 2, 1, 2. That is nearly flat. There is no
  sawtooth with a release and a harder re-engage, and no finale: the last event is at 50 m and the final 10 m (7 s) is dead.
- Nothing in the core ties fall speed to the section (`track_runner.gd` has no gravity hook), so "fall speed rises with it"
  is unbuilt.
- Fix: lengthen to a 2 to 3 minute track, sawtooth the density (calm, ramp, release at the post, ramp higher), end with a
  combined finale, and add the per-section fall-speed hook. Owner: level designer (track data), gameplay programmer (hook).

### 5. (High) Kite Day cannot be built: no track, and two thirds of the event vocabulary has no content
- `assets/data/tracks/` contains one track. Kite Day has no JSON, so D5 is judged on the core only.
- Updraft is a pure benefit: a speed boost (`track_effects.gd:34-35`, `track_runner.gd:141-143`). `levels.md:396` promises "a
  tall stack catches more wind", but crosswind ignores height (`track_effects.gd:105-125`) and nothing penalises the tall
  stack. So the kite rule is "stack as high as you can": a dominant strategy, the opposite of the cart's "stay low".
- Crosswind, updraft and cloud_bump are never used in any shipped track, and crosswind has no test (grep of
  `track_runner_test.gd`). cloud_bump is an alias of bump with the same numbers (`meadow_brook_run.json:27`), so the kite
  shake will play like the cart shake.
- The rival: `race_rival` exists in `src/mechanics/wave4/race_rival.gd` but the core publishes only `track_progress_pm`
  (`track_runner.gd:63`). `levels.md:408` needs a rubber-banded rival at 0.9 to 1.1; with a fixed player speed (defect 1)
  the race is decided before it starts. Nothing in the doc says how the rival reads track progress.
- Same engine, same numbers and same rules: the two races would feel like one level with a different skin
  (`levels.md:156,410` ask for a ground cart and a hanging, bobbing basket).
- Fix: add a height-sensitive wind term (crosswind pushes the stack and the push scales with height), give the kite its own
  vocabulary (e.g. a lane choice, a gust that must be braced), write `meadow_kite_day.json`, and specify how `race_rival`
  consumes `track_progress_pm`. Owner: game designer (kite rules), systems designer, level designer (track),
  gameplay programmer (rival wiring).

### 6. (Medium) Events are single-axis: no decisions across them, no reading of combos
- Every event is a hit at one instant. There are no overlapping or sequential lanes, no choice of route, no player action
  while the platform moves (nothing like a brace, a lean, or a lane swap), so the preview offers information with nothing
  to do about it except hold pieces back. "Foresee the track" works only as "do not stack above 6 before an arch".
- Fix: add at least one player-facing verb on the platform (steer between two tracks, brace, drop ballast, hold a piece),
  or events that reward a specific build shape (a ramp that wants a flat top, a crosswind that wants a wide base).
- Owner: game designer.

### 7. (Medium) Learnability: no scaffold, no feedback data to explain a loss
- The first 12 s has a force-1 bump at 6 m that cannot hurt a tidy stack (`meadow_brook_run.json:17`), then an arch at 12 m
  that kills any stack of 7 or more. A first-time player who has built tall dies at 12 s with no earlier signal. The kite has
  no teach-by-play ramp at all.
- `track_cargo_lost` carries only `cause` (`track_runner.gd:200`). It does not say how many layers were over the gap or how far
  the seat dropped, so the UI cannot show the player why they lost (competence feedback, SDT).
- A restart wipes the whole board (`track_runner.gd:209-215`) and replays from the post, so failure costs about 17 s plus a
  rebuild from empty, and the player restarts with a safe empty board, which makes the next arch trivially easy
  (`meadow_brook_run.json:21` at 4 m after the post). Fail cost is neither proportional nor informative.
- Fix: introduce each event alone in a quiet stretch (bump, then arch, then both), add a warning phase on the preview, extend
  the loss record with margin data, and keep part of the board (or the seat) at a restart. Owner: ux designer (warning),
  game designer (scaffold), gameplay programmer (loss record).

### 8. (Low) Unbuilt design promises in the same level text
- Biscuit's lean (`levels.md:143,154`) has no core support: no weight, no sideways load anywhere in `track_effects.gd`.
- The doc says removal "cascades upward within one shake" (`moving-platform.md:36-37`) but the sim rolls every newly loose
  block again, so it is chance-based. Reword the doc or change the sim.
- Owner: game designer (decide), architect or gameplay programmer (doc sync).

## Fix list by owner

| Owner | Fixes |
|---|---|
| Game designer | 1 (build must affect the race), 2 (trade-off), 3 (cargo rules), 5 (kite rules), 6 (verb on the platform), 8 (lean decision) |
| Systems designer | 1 (speed vs mass formula), 2 (bump model), 3 and 5 (wind and tall-stack term), numbers for all of them in `meadow_brook_run.json:25-31` |
| Level designer | 4 (longer, sawtooth, finale track), 5 (author `meadow_kite_day.json`), 7 (introduce each event alone) |
| Gameplay programmer | 1 (speed hook), 4 (fall-speed hook), 5 (rival wiring), 7 (loss record margins), tests for crosswind, cloud_bump and updraft with a real height term |
| UX designer | 7 (preview warning phase, loss explanation) |

## Why nothing is above 6

- D1, D2 and D4 have open structural defects (1 to 4), which cap them under 8.5 and drag them down to the 4.5 to 5.5 range on the
  evidence above.
- D5 cannot pass until a second track and a second event vocabulary exist.
- D3 and D6 have good bones (preview feed, no-clock loss) but each is held back by the same unbuilt promises.
- I could not run the game; a playtest could move D1 by 1 point either way, but it would not remove defects 1 to 3, which are visible in the data.
