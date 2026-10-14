# L01 meadow_01 "Stump Day": mechanics review, round 1, game designer

Reviewer: game designer (blind, independent). Date: 2026-10-14.
Thing reviewed: `design/levels/campaign/l01_meadow_01.md` (r3 + "User decisions"), marked as a PLAN (clear, complete,
testable, consistent, buildable, will it play well). No credit for visuals, no cap for "not built yet".
Rules applied: `.claude/docs/reference-quality-bar.md` "Stricter marking" and "Three blind experts per aspect". Pass mark 9.7.
Any open defect caps the item at 8.5. Items start at 5.

Inputs read (all FOUND): the spec, `level-identity-spec.md`, `minigame-party-rules.md`, `level-type-mix.md`, `meadow_01.json`,
`board_state.gd`, `board_sim.gd`, `rock_obstacle.gd`, `lava_rock_spawn.gd`, `clear_n_goal.gd`, `hud_snapshot.gd`, `level_loader.gd`,
`assets/data/knobs/fall.json`, `design/gdd/level-goals-fail-states.md`, `blocks.json`.

## 1. Scoreboard

| Item | Score | Pass (9.7) | Why not higher (one line) |
|---|---|---|---|
| M1 Core loop and fun | 7.0 | FAIL | The idea is strong and readable, but the piece set cannot tile the pit in the way the spec claims (D2) and there is no hold and one preview in a 4x4 well. |
| M2 First-time teaching | 7.5 | FAIL | Beat table is well ordered and icon-only, but its timings contradict the fall speed (D3) and the hints need a solver that is sized at 2-3 days (D9). |
| M3 Difficulty, pacing, timer fairness | 6.5 | FAIL | The pacing chart schedules the win at the 2:00 cliff and the success criteria contradict each other (D3, D4). |
| M4 Goal clarity and feedback | 8.0 | FAIL | Objective, meter and first-free beat are clear and legible; what a "full layer" is has to be learned from a 3 s preview that is only a NEW item (D12). |
| M5 Rules compliance | 7.0 | FAIL | Honours the binding user decisions and the "no layer count" rule, but leaves an open `level-type-mix.md` break, a rescue contradiction and a stale JSON `hud` block (D5, D6, D10). |
| M6 Completeness and edge cases | 5.5 | FAIL | The central mechanic rests on a wrong reading of the board code (D1); rescue, multi-clear, extension state are undefined (D6, D7, D8). |
| M7 Buildability | 5.5 | FAIL | The release rule needs a core board operation that does not exist; effort is understated (D1, D9). |

Lowest item: M6 and M7 at 5.5. Overall: FAIL. Nothing here reaches 9, so no 3-citation proof for a 9 is needed. Strengths
that earned points above 5 are listed in section 4.

## 2. Ranked defects (with evidence)

### D1 (CRITICAL, M6, M7). The wall-release rule is built on a wrong reading of the board code. As specced it either never clears a layer or never widens the pit.

Spec claims: rocks are "outside the clear denominator" because `fills_layer = false` (spec line 19), and after
`remove_cell` "its cell becomes an empty active cell" (spec lines 387-388, listed only as "to confirm").

Code says otherwise:
- `board_state.gd:200-201`: `layer_full(k)` is true only when `_layer_filled[k] == _layer_active[k]`.
- `board_state.gd:239-243`: a cell adds to `_layer_active` whenever it is `F_ACTIVE`, and to `_layer_filled` only if it also has `F_FILLS_LAYER`.
- So a rock with `fills_layer = false` that is still ACTIVE sits in the denominator but not the numerator. Any layer containing a wall rock can never be full. The NEW-3 rule (spec line 399) lists `rock`, `anchored`, `clear_protected`, `fills_layer = false`, "NOT fixed", and does not set `static_geometry`. Built as written, no layer can ever clear and the level is unwinnable.
- The real engine exclusion is `static_geometry`, which removes `F_ACTIVE` (`board_state.gd:94-96, 373-376`; `rock_obstacle.gd:20`). With that flag the wall cells are inactive. After `remove_cell`, the cell stays INACTIVE (no code path sets `F_ACTIVE` again; `is_free` needs an active cell, `board_state.gd:248-249`). The freed columns would be dead space and the pit would never widen.
- Therefore the user's binding decision ("the walls shrink") needs a new core operation: activate a cell, rebuild the layer counters (`_rebuild_layout`), log a LAYOUT delta for the view, and stay consistent with `restore`/`snapshot` for replay (`board_state.gd:652-675`). The alternative is to model the walls as masked-out cells and grow the mask. Either is a `src/core/board` change, not a rule-only change.

Impact: the entire level hangs on this. The spec's own risk list had the right question but guessed the answer.

### D2 (HIGH, M1, M6). The tileability claim is wrong: the T piece breaks "a multiple of 4 can be filled exactly" and the bag solver criterion.

Spec: "A layer can only be filled exactly if its free area is a multiple of 4. All stages below obey this" (line 21-ish note, line 187),
"a bag of 4 pieces leaves a winning line in at least 98 percent" (line 191, criterion 10 at line 424), "18 pieces minimum" (line 72).

Problem (chessboard colouring): O, I and L cover 2 dark and 2 light cells. T covers 3 and 1. A 4x4, 6x4 or 8x4 rectangle has equal dark and light cells. So any single layer must contain an EVEN number of T pieces. The spec's bag holds exactly one T per 4 pieces (line 201). Consequences:
- The first four pieces of every run contain exactly one T, so they can never complete the first 4x4 layer on their own. The "4 + 6 + 8 = 18 pieces" floor and the star arithmetic (lines 72-75) are not reachable in the cheap way assumed.
- A first-time player in a 4-wide well with no hold (line 203) and one preview is handed a piece that is a guaranteed leftover (the lone T) with no way to know it. Gaps appear that look like the player's fault. This breaks SDT competence ("the player must know WHY they failed") for a TEACH level.
- The S piece is dropped for being fiddly (line 199) but S is colour-balanced, T is not. The wrong piece was cut for tileability.
- Criterion 10 (98 percent, 500 seeds) is probably unmeetable or only met by solver lines that bury holes; nobody has run it, and it is the only fairness proof.

### D3 (HIGH, M2, M3). The fall-speed assumption is unverified and probably wrong by 2x; the beat table and pacing chart use it.

- Spec lines 94 and 206: "about 7 s to land alone", then "units of g0 are not confirmed". `board_sim.gd:850` says fall speed is "milli-cells/s", and `fall.json:15-19` has g0 default 1.0, range 0.3 to 4.0. So g0 = 0.6 reads as 0.6 cells per second. With spawn above `h_play = 8` and a short stack, a fall is 8 to 11 cells = roughly 13 to 18 s, not 7 s.
- The beat table (line 87-99) puts the first lock at "about 9 s" and the first full layer at "20 to 30 s". Four pieces by 30 s without hard drops is impossible at that speed; with the "8 s no drop" hint it only works because the drop is taught. The first full layer is therefore a time-pressured teach on the clock, not the "no pressure" stage the chart claims (line 115: "A small pit, no pressure").
- Soft drop is x10 with min 8 cells/s (`fall.json:112-147`), so the timer is fair to a player who holds down. It is unfair to any player who waits for gravity. The spec treats this as a "playtest knob" (line 206) but sets the retry, the stars and the pacing chart on a number it never measured.

### D4 (HIGH, M3). The pacing chart and the success criteria contradict the 2:00 limit.

- Pacing chart (lines 113-120): the second grip breaks at 60 to 90 s, the third layer is built from "90 to 120 s", the win is last. So the planned typical run ends AT the sunset.
- Criterion 21 (line 437): median finish "between 70 and 120 s" and "at most 1 of 5 needs the retry". If the median is 120 s, half the players time out. Even a median of 100 s with normal skew puts more than 1 in 5 over 120 s.
- Star 2 at 90 s (line 72) is meant for "a calm player"; star 3 at 60 s needs 3.3 s per piece (line 73) including a 300 ms entry delay and 900 ms lock delay (lines 209-211) and the T-parity extras (D2). 60 s for 20+ pieces is an expert target on a level 1.
- Resolve animations (first free "about 3 s", end beat 4 s, lines 102, 246) and the sundial run on `level_ms` while the player cannot place a piece (`board_sim.gd:744-754`: the next spawn waits for the resolve). About 6 to 8 s of a 120 s budget is non-play time and is not counted in any estimate. Spec line 80 says "no beat blocks play", which is wrong for the free beats.
- Fix target: either lengthen the base timer (150 s) or have the sundial pause during free beats, and state a median that leaves 25 to 30 percent headroom (for example a 55 to 85 s median against a 120 s limit).

### D5 (HIGH, M5). Open break of `level-type-mix.md`, flagged but not resolved.

- Spec line 466: setting meadow_01 to `twist` leaves meadow with no main-level `funny`. `level-type-mix.md:21` requires at least one of each type in the ten main levels; the meadow table at `level-type-mix.md:31` and the summary at `:240` count meadow_01 as the only `funny`.
- The spec's changelog (line 380 `level_type = twist`) changes the data first and leaves the rule broken. A level plan that violates a binding mix rule cannot be rated above 8.5. Also: the spec says `grip_release` is "the twist", so it is tagged `twist`, which is correct by the type table at `level-type-mix.md:16`; the missing piece is a replacement `funny` main level in meadow plus an update to the mix file.

### D6 (HIGH, M5, M6). The soft-rescue description contradicts the fail-state GDD, and its interaction with the cage is undefined.

- Spec line 62: "The Wizard's cloud scoops the top blocks." GDD `level-goals-fail-states.md:11 and :160`: rescue wipes the BOTTOM `k` layers, using `rescue_margin`, and `:161` says if rescue cannot get the stack under the limit because of an indestructible obstacle, the warning is spent and the level is LOST.
- The cage is 36 permanent full-height columns, 12 layers (spec lines 147-158), taller than `h_play = 8`. Whether rocks in layers 8 to 11 count as stack height or block the spawn zone is listed as unconfirmed (spec line 388). If they count, the very first piece is a top-out and a "very unlikely" top-out (line 63) becomes certain; if not, nothing in the spec says so.
- Bottom-wipe also deletes the layer the player was finishing, and does not count as a clear (`level-goals-fail-states.md:25`). The spec does not say that the grips do not release on a rescue wipe, nor how many layers `k` removes in a 4-wide pit at `warnings_max = 3` (line 62). The "comic scoop" description cannot be the rule the engine runs.

### D7 (MEDIUM, M6). Multi-layer and chained clears are not defined for `grip_release`.

- The engine adds `layers` to `layers_cleared` in one step (`board_sim.gd:1443`) and the `clear_count` stamp is `layers_cleared + layers` (`:1423`). The spec releases "the next grip" per cleared layer (lines 399, 418) but never says what happens when one resolve clears 2 layers (release two grips in one resolve? the win rule and rim at once?). Pieces are flat so it is rare, but a chain after a grip release (new cells, layers above dropping) can produce it and a bad answer skips a teach beat or releases the rim early.
- The stamp is per cell (`lava_rock_spawn.gd:47-56` fires `on_clear` for every cell). Counting clears from that hook as "precedent" (spec line 18) risks one release per cleared CELL unless the rule dedupes per layer. NEW-3 does not say it dedupes.
- Order of "release at `on_resolve_end`" vs the win check (`board_sim.gd:747-748`): the third clear wins before the rim release runs, so the rim tumble is a view-only effect. The spec treats it as a board change (line 167, criterion 4 line 418). State it as view-only.

### D8 (MEDIUM, M6, M7). The +30 s retry has no state definition and the grace knob is dead scope.

- The retry changes two `_finish(LOST)` sites (`board_sim.gd:751-752, 763-764`) but the spec does not define: the check order against a win in the same tick, whether `level_ms` or only the limit is extended, what the stars timer reads (`stars` use `level_ms`), whether the second timeout restart in 2 s keeps or changes the seed (line 61 says "a fair seeded random bag on every attempt"; criterion 9 says same seed replays), or how pause interacts.
- `goal.grace_ms` (NEW-2, 0.5 to 1 day, spec lines 65, 398) buys nothing. A 4x4 well with 12 layers needs well over 30 s of pieces to top out (8 layers x 4 pieces = 32 pieces), and the spec itself says top-out is "very unlikely" (line 63). Removing NEW-2 and criterion 13 saves a day and a new top-level knob with no consumer. It also conflicts with `rescue`'s protective purpose (a hidden "no warning" window is an exploit-free but pointless special case).
- Star 3 text "no warning, no trim" (line 74): `trim` is a different top-out rule (`level-goals-fail-states.md:11`); under `rescue` there is no trim. Say "no rescue".

### D9 (MEDIUM, M7). Effort and ownership are understated; several items are mis-labelled.

- NEW-3 is "2 days" but needs the core board operation from D1, the view delta, replay snapshot support and unit tests. Realistic: 4 to 5 days, owner engine/lead programmer, not only gameplay-programmer.
- NEW-4 (adaptive hints, "2 to 3 days") needs a runtime best-fit solver over a changing pit with rotation and the T-parity rule (D2). Realistic: 5 days. The criterion that a hint "never appears on a piece that fits in its spawn orientation" (line 430) needs the same solver.
- NEW-1 + NEW-2 + NEW-3 + NEW-4 + NEW-8 touch the sim, the loader and the HUD: the "12 to 14 days" total (line 408) is optimistic by at least 3 to 4 days.
- Cross-reference error: spec line 227 says the creak is "(optional, NEW-3)"; the creak is NEW-10 (line 406).
- Loader: `KEYS_TOP` includes `hud` and `look` (`level_loader.gd:7`); `scene` is not a key (spec line 382, correct); but `pieces` parsing keeps `opening_set` as an empty list (`level_loader.gd:140`), consistent with the spec.

### D10 (MEDIUM, M5, M4). The data diff leaves the shipped JSON non-compliant.

- `meadow_01.json:53` has a `hud` block with `"meter": {"label": "Hearth Hum", "label_key": "HUD_METER_HEARTH_HUM", "source": "goal_progress", "pips": 3, "icon": "hearth"}` and `"show": [..., "clock"]`. The spec diff (lines 301-370) does not touch `hud` at all. The user decided the meter name "Stump Grip" (spec line 493). The meter source `goal_progress` reads `clear_n` progress, and `main.gd:690` publishes `progress` and `target` in the HUD snapshot; `hud_snapshot.gd:13-14` maps `clear_n` to the "layers" icon. Without suppressing those the HUD can still show "layers" and a count, which breaks the binding rule.
- The spec invents `story.objective_key` (line 365) but the engine reads `story.objective` (`main.gd:690`) and `hud.objective` (`game_ui.gd:1989-1990`, and `meadow_01.json:53` already has it). Pick one path and say how the plain-text objective and the localization key relate.
- `metadata.design_spec` cleanup is correct (spec line 376).

### D11 (LOW-MEDIUM, M5). Smaller rule items.

- `campaign-vision.md:418` says "opening sets at each level 01"; the user decision for L01 says no fixed opening (spec lines 12, 201). The spec does not list this as a conflict for the vision owner.
- The footprint (the 52-cell octagon) is inherited ("Unchanged", spec line 135) and also used by `candy_02` and `lava_h3` (same mask string in `src/levels`). The rule is per biome, so it passes, but the user's last platform rule says the platform is DERIVED from the written description, after mechanics. The strongest form of that rule is met in spirit (a growing pit is in the rule's own examples, `level-identity-spec.md:116-117`), but 36 of the 52 cells never host a block (spec line 193) and the octagon is a reveal, not a platform. Say plainly that the playable platform is the 4x4 to 8x4 pit and the octagon is a stage prop.
- Spec line 54: "Win condition: 3 full layers cleared" is the mundane goal the user banned (`level-identity-spec.md:64-68`). It is permitted as engine means, and the wall change does make the layers matter, so the swap test passes; but the three-knot meter is a layer counter in costume. The user approved the meter, so this is a note, not a fail.

### D12 (LOW, M2, M4). Teaching and feedback gaps.

- The only explanation of "a full layer" is a 3 s looping preview (NEW-8, spec line 404) that is not designed in the spec: what does it show? A first-time player who sees four blocks in a 4x4 pit must infer "fill the floor".
- The hint rules (lines 94-99) trigger on idle times that overlap (4 s finger, 8 s down-arrow, 6 s idle) but do not say what happens if two hints qualify or if the turn hint fires while the player is mid-slide. Add priority.
- Hints depend on the fit solver (D2/D9). The "faint glowing outline shows the best fit" (line 96) would teach the wrong thing when the best fit is an odd-T leftover.
- No failure feedback for a buried hole is described: when a layer cannot be completed because a hole is covered, the player gets no explanation; at 4 wide this will happen often with D2.

## 3. Concrete fixes (owner tagged)

| Fix | Resolves | Owner |
|---|---|---|
| F1. Design the release as a core board operation: either (a) `activate_cell(cell)` on `BoardState` that sets `F_ACTIVE`, rebuilds layer counters and logs a layout delta, or (b) per-stage mask growth. State it in spec section 10, size it, and fix the NEW-3 text: the cage rock must carry `static_geometry` so layers can clear, and `grip_release` re-activates cells on release. Add tests: layer counters before and after release, replay/restore, no double release. | D1 | lead-programmer + systems-designer (spec), gameplay-programmer (build) |
| F2. Fix the piece set: replace T with J (flat 4-cell, colour-balanced) for L01, or keep T and write the even-T rule into the fairness section. Confirm a flat J exists in the shape catalog. Re-run the "98 percent winning line" and "minimum pieces" numbers with an actual solver BEFORE the spec is re-reviewed, and report the real minimum pieces and median. Introduce T in level 2 or 3 as the "new shape" teach. | D2, D4 (stars) | game-designer (decision), systems-designer (solver) |
| F3. Measure fall: confirm `fall.g0` units, then recompute time per piece with a drop-only, a soft-drop and a gravity-only bot. Rewrite the beat table (lines 87-99) and the pacing chart (113-120) with real numbers. If gravity-only play cannot finish in 120 s, say that the level requires the drop and teach it in the first 10 s with a hard gate on the hint, not 8 s. | D3 | systems-designer + game-designer |
| F4. Re-time the clock: pause the sundial during the free beats, or raise the limit to 150 s, and set the median target to 55 to 85 s with at most 1 in 5 needing the retry. Make star 3 about 75 s unless the solver shows 60 s is median-achievable for good players. Rewrite pacing chart so the typical win lands near 70 to 90 s. | D4 | game-designer |
| F5. Resolve the funny/twist break: add a `funny` main level in meadow (named level and rule) and update `level-type-mix.md` meadow table and summary in the same change. | D5 | game-designer + level-designer |
| F6. Align the rescue text with `level-goals-fail-states.md`: bottom `k` layers wiped, warning token consumed, no grips on a wipe. Decide whether wall rocks count as stack height and say so; set `rescue_margin`. Keep the comic cloud as view only. Add an acceptance test: a forced top-out in the 4x4 pit does not end the level. | D6 | game-designer + gameplay-programmer |
| F7. Add `grip_release` edge rules: one release per cleared LAYER (dedupe per layer), a 2-layer clear releases two grips in order, the win beats the rim release (rim is view-only), and pause/restart behaviour. | D7 | systems-designer |
| F8. Write the retry as a state machine (extension granted at most once, check order win-before-timeout, what `level_ms` and the stars read, seed on restart, pause). Delete NEW-2 `goal.grace_ms` and criterion 13. Change the star 3 wording from "no trim" to "no rescue". | D8 | systems-designer + game-designer |
| F9. Re-size NEW-3 to 4 to 5 days and NEW-4 to about 5 days, fix the NEW-3/NEW-10 cross reference, and update the 12 to 14 day total. | D9 | producer + lead-programmer |
| F10. Extend the data diff to the `hud` block: meter label `Stump Grip`, `source` that does not publish layer counts, drop the "layers" icon for this level, choose one objective key path (`hud.objective` or `story.objective`) and align `main.gd:690` and `game_ui.gd:1989`. | D10 | ui-programmer + gameplay-programmer |
| F11. Add a note for the vision owner on `campaign-vision.md:418`; state in section 4 that the playable platform is the pit and the octagon is stage dressing. | D11 | creative-director, game-designer |
| F12. Design the 3 s looping preview (frames, no words), add hint priority rules, and add a "buried hole" feedback (a soft tint on the covered cell) to the beat table. | D12 | ux-designer + game-designer |

## 4. What earned points above 5 (evidence)

- Objective is story-first and 6 words: "Free the Hearth Stump before sunset." (spec line 30), HUD forbids "clear", "layers" and counts (line 293), criterion 16 tests it (line 430). Honours the binding decisions on objective and HUD (M4, M5).
- Rectangular stages 4x4, 6x4, 8x4 with spawn run always 4 wide and no pockets (spec lines 185-193) fit the vision's spawn rule (`campaign-vision.md:241`) and the binding wall-shrink decision (M5, M6).
- Random seeded bag, no `fixed_list`, no opening (spec line 201, criteria 8-9) satisfy `level-identity-spec.md:25-26` and `minigame-party-rules.md:29-30` (M5).
- Soft rescue, +30 s retry once, cosmetic giggle, single player all present and traceable (spec lines 61-62, 273-276, 285) (M5).
- Teaching table is icon-only, never blocks input and has a first-lock, first-turn and first-free sequence (spec lines 79-108) (M2).
- Acceptance list is mostly testable and separates automated from observed evidence (spec lines 412-439) (M7).
- Dependency honesty: the spec states which engine facts it could not verify (spec lines 386-391); the verification, done here, shows the main guess is wrong (D1).

Why none of these reaches 9: each score is capped at 8.5 by open defects D1 to D8, and several items are below 8 because the defect is in the item's core.

## 5. Top 5 (summary)

1. D1 wall-release rule contradicts `board_state.gd:200-201, 239-243, 94-96, 373-376`: unwinnable or never widens. Needs a core activate-cell operation.
2. D2 T-piece parity: one T per 4-piece bag cannot tile 4x4/6x4/8x4 layers alone, so the "98 percent" and "18 piece" claims are unproven and the first layer is unfair.
3. D3/D4 fall speed (g0 is cells/s, so about 13 to 18 s per gravity-only fall, not 7 s) and a pacing chart that ends at the 2:00 cliff, with median 70-120 s vs a 120 s limit and 1-in-5 retry target.
4. D6 rescue text contradicts the fail-state GDD (bottom wipe, indestructible-obstacle loss) and wall rocks above `h_play` are unresolved.
5. D5 meadow loses its only `funny` main level, an open break of `level-type-mix.md:21`.
