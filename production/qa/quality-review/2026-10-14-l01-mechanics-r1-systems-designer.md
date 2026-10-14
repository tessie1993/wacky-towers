# L01 meadow_01 "Stump Day" - mechanics review r1 - systems designer (blind expert 2 of 3)

Subject: `design/levels/campaign/l01_meadow_01.md` (r3 + "User decisions" round 4), marked as a PLAN (clear, complete,
testable, consistent, buildable). Marking rules: `.claude/docs/reference-quality-bar.md` "Stricter marking" and "Three
blind experts per aspect". Pass mark 9.7. Any open defect caps at 8.5. Binding user decisions are not scored against
the spec (shrinking walls, 2:00 timer, soft rescue, +30 s retry once, random bag, "Stump Grip", single player).
No file other than this review was written. I could not run code (read-only tools), so the tiling remarks are
hand analysis and are labelled as such.

Abbreviations: SPEC = the l01 file; BS = `src/core/board/board_state.gd`; SIM = `src/core/sim/board_sim.gd`.

## Scoreboard (systems designer)

| Item | Score | Cap reason / main driver |
|---|---|---|
| M1 core loop and fun | 7.5 | Loop is clear and fits the verb. Fun depends on a 17 s fall the spec thinks is 7 s (D3), and on T-parity (D7). |
| M2 first-time-player teaching | 6.5 | All beat times assume a 7 s fall; engine gives about 18 s (D3). The "never-turn bot" claim is unproven (D8). |
| M3 difficulty and pacing (timer, stars) | 5.5 | Star and timer maths rest on the wrong fall time and an unproven 18-piece minimum (D3, D6, D9). |
| M4 goal clarity and feedback | 7.5 | Objective and Stump Grip are clear. The rescue story contradicts the sim (D5). Meter label still "Hearth Hum" in the JSON (D10). |
| M5 rules compliance | 7.0 | Open `level_type` mix break (D11), no `verify_campaign_biomes` criterion, stars not from the plan formula (D12). |
| M6 rule completeness and edge cases | 6.0 | Release path, clock pause, same-tick clears, hook timing are unspecified (D2, D4, D13). |
| M7 buildability, verified in code | 4.0 | Two engine-fatal defects: the layer can never be full (D1) and the first lock is an instant loss (D2). |

No item reaches 9 (no 3-citation justification possible while D1-D2 stand). Nothing passes.

## What I verified as correct (evidence)

- Cage arithmetic: 36 wall columns (4+6+16+6+4), 16 free; grips 8 + 8 + 20 = 36; free pit 16/24/32 (SPEC:147-176, 351-353).
  All three are rectangles with area a multiple of 4. Mask rows total 52 (SPEC:133-145).
- `rock` has `fills_layer=false` (`assets/data/content/blocks.json:204-209`) and `can_remove(CLEAR)` refuses
  `clear_protected` cells (BS:691), so a clear does not eat wall cells. `shift_layers` skips immovable cells (BS:485).
- A `fixed` cell cannot be removed (BS:685-686); the SPEC's reason for a new rule is correct.
- `lava_rock_spawn.gd:49,55,58` is real precedent (clear_count stamp, DAMAGE removal). `on_clear` is fired per cell
  with `clear_count = layers_cleared + layers` (SIM:1423), so a stamp-based "once per clear" is the right idea.
- `clear_n` WON when `layers_cleared >= n` (`clear_n_goal.gd:17`). A win is decided before a timeout in
  `_resolve_step` (SIM:747-752), so a last-tick win beats the clock. Timeout is a LOSS at two sites, SIM:751-752, 763-764.
- Spawn clearance 4 gives a 12-layer board with `h_play` 8 (`level_loader.gd:136`, BS:287-290); SPEC:129 is right.
- The bag is deterministic per seed: `Seeds.make_rng(_seed, ["spawn_bag", _bag_index])` (`spawner.gd:175`), and the
  attempt seed is fresh per attempt (`main.gd:472, 865-866`). `opening_set` defaults to empty (`spawner.gd:54-55`).
  The "same seed, same sequence" test (SPEC:422-423) is buildable. One bag = one each of O, I, L, T.
- Every knob value in the SPEC is inside its registry range: g0 0.6 (min 0.3), lock delay 900 (max 1500), resets 15
  (max 30), entry delay 300 (max 600), warnings_max 3 (max 3), intro_card_ms 2000 (max 4000)
  (`assets/data/knobs/fall.json`, `goals.json:70, 216-225`).
- Seed logging, 4-piece bag and the first-lock/first-clear teaching order are coherent as a design.

## Ranked defects

### D1 (BLOCKER, M7/M6) A layer can never be full while the cage exists; the SPEC's rock recipe contradicts the engine

- SPEC:182 says "A layer is full when every free cell in the current pit is filled", justified only by `fills_layer = false`.
  SPEC:399 (NEW-3) builds the cage as rock, `anchored`, `clear_protected`, `fills_layer=false`, "NOT fixed".
- Engine: `layer_full(k)` is `_layer_filled[k] == _layer_active[k]` (BS:199-201). `fills_layer=false` only removes the cell from
  `_layer_filled`; the cell is still counted in `_layer_active` (BS:240-241). A layer with 36 inert but active wall cells can
  never reach filled == active. No layer ever clears, so the goal is unreachable.
- The existing mechanism that really excludes rocks from the denominator is `static_geometry: true`, which clears
  `F_ACTIVE` (BS:94-96, 373-377). `rock_obstacle` sets it (`rock_obstacle.gd:20`) and the test proves it
  (`tests/unit/mechanics/campaign_hazards_test.gd:138-148`). NEW-3's status list omits it, and SPEC:417 (AC3) tests "No rock is fixed" but not "inactive".
- Consequence for release: an inactive cell stays inactive after `remove_cell` (remove only clears content, BS:335-355), so
  `is_free` stays false (BS:249-252) and the "released" column would still be a wall. Release needs `request_mask(x, z, true)`
  (`rule_api.gd:294`, handled `board_sim.gd:1373-1374`, `BoardState.set_active` BS:420-439), which the SPEC never mentions.
- Fix (owner: level-designer to rewrite NEW-3 and AC3-AC7, gameplay-programmer to build):
  Preferred: model the cage as inactive (masked-off) columns, not rocks. Start with the 16-cell pit active, wall columns
  `set_active(false)`, and grips are `request_mask(..., true)` on all 12 layers. The view draws roots and stones from the
  grip lists. This also removes D2, needs no `remove_cell`, keeps the denominator correct, and stops pieces sliding over walls.
  Add AC: "layer_full is true for a filled 16-cell pit at stage 0" and "after grip 1, active_in_layer = 24".

### D2 (BLOCKER, M7) Full-height 12-layer walls trigger top-out on the first lock

- SPEC:147, 188 and 351-353 make walls 12 layers high. `over_limit()` is `stack_height() >= limit_layer()` (BS:289-295), and `stack_height()`
  uses `_layer_solid`, which counts every `F_SOLID` cell including rock (BS:244-245, 525-526; rock is `solid: true`, blocks.json:208).
  `limit_layer()` is 8 here. So `over_limit()` is true from level start.
- At the first lock SIM:993 runs `_board.over_limit() and not _handle_top_out`. `RescueTopOut` (`rescue_top_out.gd:34-39`) wipes
  the bottom `stack_height - (h_play - 1 - margin)` = 11 - 5 = 6 layers, cannot remove the walls, and returns LOST because
  `board.over_limit()` is still true. Result: one lock, level lost. If it did not, a rescue would also burn a warning every lock.
- SPEC:386-390 lists "rocks in the clearance zone" as a thing to confirm but never names this consequence, so the AC list
  (SPEC:413-432) would not catch it until play.
- Fix (owner: level-designer; gameplay-programmer): adopt D1's masked-off columns (no solid cells, so no stack height), or cap rock height
  at layer 7 and accept pieces sliding over the wall in layers 8-11 (worse). Add AC: "stack_height() = -1 on an empty level start".

### D3 (HIGH, M1/M2/M3) The fall-time claim is wrong by about 2.5x, and the timer, star and teaching maths all use it

- SPEC:94 and 206: "At the baseline gravity a piece takes about 7 s to land alone". Engine: `g0` is cells per second
  (`board_sim.gd:13-15, 865`): 0.6 gives 1_000_000 / 600 = 1666 ms per cell. Pieces spawn in the top layer (flattest face,
  `top_arrival.gd:9-16`; clearance 4 so layer 11). An empty-pit landing is 11 steps = about 18 s; with 900 ms lock delay about 19 s.
  The `ramp_per_clear` default 0.05 (fall.json:81-89) raises g0 slightly after each clear (SIM:853), so it is still 0.65-0.7.
  SPEC:206 even admits "units of g0 are not confirmed in the data"; the code answers it.
- Consequences: (a) A player who never hard-drops places 6-7 pieces in 120 s, 11 pieces short of the 18 minimum. (b) The teaching
  table (SPEC:90-95: first lock "about 9 s", first layer "20 to 30 s", grip 1 at 25-30 s) is only true for a player who already
  drops; a first-timer reaches grip 1 at about 60-70 s. The pacing chart SPEC:112-121 is for experts. (c) Soft drop is 8000-30000
  milli (fall.json:132-148), i.e. 125 ms per cell, hard drop is instant, so the real difficulty cliff is "discover drop".
- Fix (owner: systems-designer for the numbers, level-designer for the text): state the per-piece budget in a variable table:
  `t_piece = t_entry(0.3) + t_aim + t_fall + t_lock + t_resolve`, with `t_fall = (layer_spawn - layer_land) * 1000 / g_milli`. Then
  choose g0 so an undropping first piece lands in <= 9 s (g0 about 1.2, which is above the SPEC's 0.6 biome baseline), or keep 0.6
  and make hard drop the taught first action (hint at 3 s, not 8 s). The SPEC must pick one and say so (it currently calls this a
  "playtest knob", SPEC:206, but the maths shows it is a spec error, not a tuning question).

### D4 (HIGH, M6) The grip-release timing path is unspecified and the two hook channels differ

- SPEC:399: "releases the next grip at `on_resolve_end` by `remove_cell`". Rule effects come in two kinds. Cell writes (`remove_cell`,
  `set_status`) are flushed and make the sim run a second clear pass (SIM:982-984, `wrote`). Structural changes such as masks are
  `_requests` (`rule_api.gd:294`) applied in `_apply_structural`, not guaranteed before the entry delay / next spawn (SIM:995).
  The SPEC does not say which, nor whether the next piece can spawn before the new columns exist.
- Edge cases the SPEC does not close: (a) two clears in one resolve (a cascade; `clear_count` jumps by 2, SIM:1423) - does the rule
  release one grip or two? (b) the win clear (clear 3) - the rim release must not run after `_pending_outcome` is set (SIM:989-993).
  (c) a rescue wipe (`wipe_bottom`, BS:601-614) does not call `on_clear`, which is correct, but the SPEC must state "rescue never
  counts". (d) when widening, upper partial layers now lack 8 more cells; SPEC:183 mentions this but the solver criterion SPEC:191, 424
  does not model it.
- Fix (owner: level-designer spec, gameplay-programmer code): define grip index = `min(clear_count, 3)` and release all grips up to that
  index idempotently; release in the same `_apply_structural` pass before `_entry_deadline`; add ACs for (a)-(c).

### D5 (HIGH, M4/M6) Rescue story contradicts the sim

- SPEC:62: "The Wizard's cloud scoops the top blocks". `RescueTopOut` calls `board.wipe_bottom(k)` (`rescue_top_out.gd:36`, BS:601-614),
  i.e. the BOTTOM k layers, destroying the oldest, possibly almost-full layers, and shifting the rest down. The clock also freezes
  while the warning shows (`board_sim.gd:174`, `_warning_until`), which the SPEC never states and which affects the 120 s and star maths
  (a warning adds `goal.warning_ms` 1200 ms of free time; `goals.json:204-214`).
- Also SPEC:63 "a top-out is very unlikely": with D3's 18 s fall a top-out is essentially impossible in the 4-wide stage; with a
  correct fast fall the 8-layer limit is 128 cells = 32 pieces, still far beyond the 18-26 pieces needed. So `goal.grace_ms` (NEW-2, 0.5-1 day,
  SPEC:65, 398) protects against an event that cannot happen in the first 30 s: the highest legal stack after 30 s of play is about 7 pieces = 2 layers.
  `goal.grace_ms` also collides in name with the sim's hard-drop GRACE phase (`fall.hard_drop_grace_ms`, SIM:660-676).
- Fix (owner: game-designer decision, level-designer text): either say "the cloud scoops the bottom blocks and the rest settle", or
  change the view contract. Drop NEW-2 and `grace_ms` from level 1 (saves a day, removes a new knob); keep `goal.warnings_max` 3.

### D6 (HIGH, M3) Star thresholds are not derived from a stated model and 3 stars is near-unreachable

- SPEC:72-73: 2 stars <= 90 s "81 s at 4.5 s per piece" for 18 pieces; 3 stars <= 60 s "3.3 s per piece". SPEC:75 admits real runs need
  20-26 pieces. At 22 pieces, 60 s = 2.7 s per piece including 3 s of grip beats (SPEC:102, level_ms runs during resolve: SIM:174 only freezes in
  warning/countdown/ended) and a 4 s end beat. t3 needs about 1.5 s of aim per piece, 300 ms entry delay (SPEC:211), and a lucky bag. I estimate
  3-star success under 5 percent of skilled attempts; the SPEC has no target rate. The quality bar says level 1 should hand out stars generously
  to "teach".
- AC21 (SPEC:437) says "median finish 70-120 s" with "at most 1 of 5 needs the retry". A median of 120 s means half of runs time out.
  The range should be 70-100 s.
- `StarRater` is time-only (`star_rater.gd:14`: 2 if level_ms <= t2; 3 if <= t3 and no warning). It does not know about the retry. SPEC:75
  and AC14 rely on "over 90 s so 1 star"; that is true only because t2 is 90 s < 120 s. State it as a rule, not a coincidence.
- `level-identity-spec.md:28` says "Stars come from the formula in the plan files, not copied". The SPEC invents its own numbers and does
  not cite the plan formula.
- Fix (owner: systems-designer): give the formula `t2 = ceil(1.3 * median_expert_time)` and `t3 = ceil(1.0 * median_expert_time)` from a bot
  or solver run with the corrected D3 timing, plus a target star-rate table (for example 1 star 95%, 2 stars 55%, 3 stars 10% of first-time players).

### D7 (HIGH, M1/M6) "Every stage exactly fillable with O, I, L, T" is asserted, not shown, and a parity rule makes T hostile

- SPEC:187, 191 claim a stage is tileable "by the four shapes" and asks a solver for 98 percent, but there is no solver in the repo
  (`**/*solver*` finds only vendor files) and no tiling table.
- Area: yes. 16, 24 and 32 are fillable with O only, or I only (all rectangles with even sides or length 4).
- Hand check, checkerboard colouring (labelled as my analysis): O, I and L cover 2 + 2 black/white cells; T covers 3 + 1. Every region in the
  SPEC is balanced (8/8, 12/12, 16/16), so any exact tiling uses an EVEN number of T. One T per bag therefore means a T can only be
  placed into a layer that another T will later join. Pieces are flat, spin only (SPEC:215), so a lone T leaves a layer unfinishable until
  a second T arrives, up to 4+ pieces later (a bag deals exactly one T per 4 pieces).
- Chirality: spin-only rotation means only L, never J (`control.rotation_axes_enabled = ["spin"]`). I hand-checked the one-of-each 4x4 attempts I
  tried (I on an edge, then O, then T+L in the 3x4 rest) and found the remainders were J-shaped; I did not enumerate all, so treat as
  "likely not tileable by a bag of exactly O+I+L+T".
- Result: the 18-piece minimum (SPEC:72, 480) is only reachable with a stream of O and I; with the bag it is not the minimum for any realistic run.
  The 98 percent solver criterion (AC10) could fail, and nothing says what happens if it does.
- Fix (owner: systems-designer, with level-designer): (a) run the tiling enumerator and put the result table in the SPEC. (b) Consider dropping T
  from level 1 (shapes O, I, L; or O, I, L, J since J is only a mirror and `rotation_axes` has no flip) or weighting T low. (c) Rewrite the
  minimum as an expected value: `E[pieces] = sum over stages (area / 4) * waste_factor`, with waste_factor measured from the solver.

### D8 (MEDIUM, M2/M6) Acceptance criterion 11 (the "drop-only bot") is likely false

- AC11 (SPEC:425): "A bot that only drops (never turns) frees the stump within 120 s in at least 90 percent of runs. Turning is taught, not
  required." A 4-wide pit with fixed-orientation L and T cannot be exactly filled without turning: fixed-orientation L/T each leave
  holes or covered cells (hand reasoning; see D7), and half the bag is L or T. The SPEC also teaches a turn hint
  "for at most the first 2 such pieces" (SPEC:96), which contradicts "turning is not required".
- Fix (owner: level-designer): drop AC11 or replace it with "a bot that drops and rotates but never uses slide-to-fit" and run it.

### D9 (MEDIUM, M3/M2) Timer extension is defined in the SPEC but not testable as written

- NEW-1 (SPEC:397) puts `time_extension_ms` and `time_extensions_max` in `goal`, which the validator does not know. `level_validator.gd`
  only validates specific goal keys (lines 36-52); unknown keys are not rejected but also not read. The timeout test is at SIM:1610-1612,
  reading `_level.goal["time_limit_ms"]`, with no extension state, no snapshot field for replay (snapshot list at SIM:521-529), and no
  rule for the exact boundary (`level_ms >= limit`).
- AC12 (SPEC:426) says "at 120000 ms ... adds 30000 ms once". It does not say what happens to a piece in flight, the lock timer, or a
  timeout that lands during RESOLVING (SIM:751 vs 763 handle it differently: the first finishes at the next spawn, the second at any
  tick; `_goal_step` skips RESOLVING). The winner-wins order in SIM:747-752 is right but not tested in the ACs.
- Fix (owner: gameplay-programmer, level-designer for ACs): add `time_extends_used` to the replay snapshot, add ACs: timeout in RESOLVING, win and
  timeout on the same tick (win wins), and replay determinism across the extension.

### D10 (MEDIUM, M4/M5) The JSON diff leaves a stale meter and a duplicated objective

- `src/levels/meadow/meadow_01/meadow_01.json:53` has `"hud": {... "objective": ..., "meter": {"label": "Hearth Hum", "label_key":
  "HUD_METER_HEARTH_HUM", "pips": 3, ...}}`. The user decision (SPEC:493) is "Stump Grip". SPEC:222 and 465 flag the narrative beat file
  but SPEC:297-370 (the JSON diff) never edits the `hud` block. The file also lists `clock` in `hud.show`, while the SPEC calls the timer
  part of the plaque and counts four HUD elements (SPEC:282-292).
- `story.objective_key` (new, SPEC:365) and `hud.objective` already hold the same text. Pick one source.
- Also `design_spec` and the old stale `metadata` (the SPEC does say delete `design_spec`, SPEC:376).
- Fix (owner: level-designer to extend the diff; ui-programmer for NEW-8): add the `hud` edits to section 10 and a unit test that the
  meter label key is `HUD_METER_STUMP_GRIP`.

### D11 (MEDIUM, M5) Open rules-compliance breaks

- `level-type-mix.md:31` still lists meadow_01 as `funny` (balloon); the SPEC sets `twist` and records that meadow then has no main-level
  `funny` (SPEC:466), breaking the mix target at `level-type-mix.md:21`. The SPEC leaves it as a flag. An unresolved cross-doc conflict is an
  open defect (owner: game-designer decides which meadow level takes `funny`).
- `level-identity-spec.md:29` requires `tools/qa/verify_campaign_biomes.gd` with 0 failures; the SPEC acceptance list (SPEC:412-441) has no such check.
- `level-identity-spec.md:28` stars formula (see D6) not cited.
- SPEC:450 and 483-486: the terrain `stump_top` and action `grip_release` still need closed-list change requests (Q3 open). The round-4
  user decisions answer Q1 (meter) and Q2 (growing pit) but not Q3; SPEC:3 and 471-486 still read "DRAFT ... for user review" and list
  all three as open, which is stale after SPEC:488-493.
- `minigame-party-rules.md:12-13`: a minigame phase is 20-90 s; this level is 60-120 s with a 150 s cap. It is a level not a phase, so this is
  only a note, but the SPEC should state that it is exempt.

### D12 (MEDIUM, M6) The instability of "free pit after widening" for already built layers

- Because release removes the wall in every layer (SPEC:180), all upper partial layers gain 8 empty cells at once (SPEC:183). A player who
  built two full 4x4 layers before clear 1 now has one fresh 4x4+8 layer and an 8-cell hole; a player who built an upper layer unevenly
  (an L/T-shaped rim) may have an unfillable 2x4 side strip (2x4 is tileable by O+O, I+I, or L+L, but not by T). The "fairness" claims
  (SPEC:185-191) cover only empty layers.
- Fix (owner: systems-designer): table of "upper layer state x widening" outcomes, or restrict: release only widens layers at and above the
  current stack height + 1 (view shows walls vanish, board keeps the old width for existing layers by locking them in a "sealed" state).

### D13 (LOW, M6/M7) Smaller gaps

- Rotation inside the 4-wide pit: the I piece spawns flat and 4 long (`top_arrival.gd`), so at stage 0 it has zero lateral room, and a spin
  needs a kick (`control.kick_enabled`, SIM:653). The SPEC says "a piece can rotate in it" (SPEC:188) but gives no test; add an AC "all four
  shapes can rotate through all four spins at stage 0 from the spawn anchor".
- `spawn.anchor (3,3)`: the JSON has no `spawn_anchor`; AC2 (SPEC:416) relies on a default. Name it.
- Cell budget estimate (SPEC:408): 12-14 engine days listed, but the total omits D1/D2 re-work and the replay snapshot of the new rule
  (rule `snapshot()` is required, cf. `lava_rock_spawn.gd:65-66`).
- Wording: SPEC:63 "at least 4 wide" is true only if all four columns stay free; with a 4-wide I piece, a stray block leaves a pit narrower than the piece.

## Concrete fixes by owner

| # | Fix | Owner |
|---|---|---|
| F1 | Replace the rock cage with masked-off columns released by `request_mask(...,true)` across 12 layers; rewrite NEW-3, AC3, AC4, AC6 (D1, D2) | level-designer (spec), gameplay-programmer (build) |
| F2 | Add ACs: empty level has `stack_height() == -1`; `layer_full` true for a filled 16-cell stage 0; `active_in_layer` 16/24/32 (D1, D2) | level-designer |
| F3 | Replace the 7 s fall claim with the formula and numbers; decide g0 or hint timing; rewrite the beats and pacing chart (D3) | systems-designer, level-designer |
| F4 | Specify grip index, idempotent release, order versus `_entry_deadline`, win clear, cascade, rescue (D4) | level-designer |
| F5 | Fix the rescue story (bottom wipe), document clock freeze in warning, drop `goal.grace_ms` and NEW-2 (D5) | game-designer, level-designer |
| F6 | Derive t2/t3 from an expert-time model and a star-rate target; fix AC21 range; cite the plan formula (D6) | systems-designer |
| F7 | Tiling table for all stages from a solver; handle T parity and L chirality; reconsider the shape set or weights; make the minimum an expectation (D7) | systems-designer |
| F8 | Replace AC11 (D8) | level-designer |
| F9 | Time-extension state in snapshot; ACs for RESOLVING timeout and same-tick win (D9) | gameplay-programmer, level-designer |
| F10 | Extend the JSON diff to the `hud` block and one objective source (D10) | level-designer, ui-programmer |
| F11 | Resolve the `level_type` mix; add `verify_campaign_biomes` AC; mark Q3 and status as decided or open (D11) | game-designer, producer |
| F12 | Define widening effect on existing upper layers (D12) | systems-designer |

## Why no item reaches 9

M1-M6 carry an open defect that a player or the user would notice (caps at 8.5), and M7 has two defects that make the level unwinnable as
specified (D1, D2). Nothing here was built, but this is marked as a plan and the plan itself is wrong against the code it cites.
