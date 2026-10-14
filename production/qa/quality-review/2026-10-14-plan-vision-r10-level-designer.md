# Plan review r10, campaign vision: level designer (blind expert 1 of 3)

Scope: `design/levels/plans/campaign-vision.md` (CV), `exemplars.md` (EX), `scene-vocabulary.md` (SV),
`level-identity-spec.md` (LI), `campaign-redo-plan.md` (RP), `minigame-party-rules.md` (MP).
Judged as a PLAN: clear, complete, testable, consistent, buildable. No paper-only cap, no credit for visuals.
Speciality: spatial variety, footprints, pacing, difficulty curve, fairness, readability.
Rules applied: start at 5, earn points with file:line, any open defect caps at 8.5, 9+ needs 3 citations and a
reason it is not 10. Lower score when unsure. Pass mark 9.7 on every item.

## Scoreboard

| Item | Score | Pass |
|---|---|---|
| V1 fantasy | 8.4 | FAIL |
| V2 pillars | 8.2 | FAIL |
| V3 campaign arc | 7.9 | FAIL |
| V4 uniqueness rules | 7.7 | FAIL |
| V5 level briefs | 8.1 | FAIL |
| V6 rubric quality | 7.9 | FAIL |
| V7 internal consistency | 7.4 | FAIL |
| Ex exemplars as calibration | 7.6 | FAIL |

Result: FAIL (every item is below 9.7, and every item carries at least one open defect, so each is capped at 8.5).

### Evidence per score

- **V1 8.4.** Earned: pitch in one sentence (CV:44-45); the paragraph states the ruling-A/B consequences
  (CV:52-56: every level a minigame, no shared footprint within an island); the player feeling is named (CV:57-58).
  Not higher: the paragraph says nothing about session length or level duration ("short and intense", CV:53, has no
  seconds), line 56-57 is a broken sentence ("Minigame modules are the island's own games..."), and the fantasy of
  "real tension" the user set for Lava and Neon is absent (D3).
- **V2 8.2.** Earned: every pillar test has a phase and a 0/1/2 scale (CV:69-73); P1b names closed-list fields
  (CV:78-84); P3e gives a numeric telegraph floor (CV:112-114); P1c is measurable (CV:85-88). Not higher: P3d is
  not runnable as written (D10), only `strike` has a telegraph rule, no pillar covers pacing or difficulty
  (D9), and P1a/P2c are judgement calls with no worked 0/1/2 example for the middle score.
- **V3 7.9.** Earned: a 12-row arc with role, stakes, intensity (CV:123-136), named reversal, midpoint and low
  (CV:138-140), a stated Wizard flaw (CV:146). Not higher: the peril tone contradicts the user decision (D3);
  the ending is labelled "proposed" though the user decided it (RP:98-99 vs CV:143); biome intensity dips
  (Ice 2, Forest 2, Celestial 3) are not reconciled with "g0 rises across biomes" (CV:415-417, D9); there is no
  inside-biome intensity curve.
- **V4 7.7.** Earned: canonical mask, footprint, recogniser table and priority order are precise and mostly
  checkable (CV:198-202, SV:64-82); U18 and U7 corridor numbers are concrete (CV:238-247, 295-299); I hand-checked
  `ex_forest_h1` stair (IoU with `ex_forest_05` is 68/88 = 0.77, passes) and `ex_underwater_09` funnel (passes).
  Not higher: D1, D2, D8, D11 and the U16 wording (D14).
- **V5 8.1.** Earned: phase 2, 3, 4 briefs each name outputs and owners (CV:303-329, 347-419, 423-443); the
  engine-gap table sums correctly (81 days, last eight rows 21 days, CV:362-381). Not higher: required-field list
  lacks play time, per-level intensity, audio cue, optional/secret placement (D9); the `level_table` columns do
  not carry what the script must check (D2); the 40-day scene-kit estimate is not credible (D12).
- **V6 7.9.** Earned: scoring anchors (CV:447-449), explicit caps (CV:459-464), coverage rule (CV:452-453),
  plan-versus-build split (CV:465-477). Not higher: two incompatible scales (D5), caps of 8.0 in CV:446,
  459-464 vs 8.5 in the quality bar, and no anchor at all for V1-V7 or P1-P3 (only L/N/M/A/C/S have them,
  EX:387-402).
- **V7 7.4.** Open inconsistencies: D3, D5, D8, D13, D15, D16, D17 below.
- **Ex 7.6.** Earned: eight 9.7 exemplars with table rows (EX:404-419), a near-miss, two weak samples, boss, hard
  remix, level 01, defence, module (EX:22-385); recogniser results hold for 7 of 8 table masks. Not higher: D4,
  D5, D6, D7 and D17.

## Ranked defects

### D1 (critical). The mask legend never says what `.` does, and the flagship exemplar's geometry contradicts its fiction
- CV:431-432 defines `#` floor, `.` void and nothing else. CV:243 ("void-bounded vertical run", "a 2-wide shaft")
  and CV:239-241 (spawn columns that "hold void" need `spawn_cols`) imply void is not playable.
- EX:61-70 `ex_forest_05` ("bridge span 12x8"): rows 0-2 cols 4-7 are void, rows 3-7 are full floor. If void is
  not playable, nothing can be built in the "gap"; the base under it is already solid, so the 4-cell `span` goal
  (EX:55-56) is either trivial or impossible. The far pillar (cols 8-11, rows 0-2) can only be reached by a piece
  crossing void cells, and the spawn is on the left pillar only (EX:71). A solver (P3d) would fail it.
- Same question for every `bridge span`, `twin towers`, `island chain` and `moat` (SV:72-77): can a piece pass
  through void to reach the far side?
- Fix: add one sentence to CV section 5 and section 8 defining void (blocked / absent / passable airspace),
  and add a second symbol (for example `_` empty playable cell) if gaps are meant to be built into.
  Redraw `ex_forest_05` and `ex_forest_h1` once that is decided. Owner: game director (wording) with the
  gameplay-programmer confirming engine semantics via the Godot master.

### D2 (high). The `level_table` cannot feed the checks the script is said to run
- CV:207-209 says the script verifies U12 and "the name check"; CV:211-214 columns have no `name`, no boss
  triple (`arena`, `phases`, `building_action`, needed by U12 at CV:266-268), and no `spawn_cols` (needed to
  compute `min_spawn_width`, CV:238-243). EX:406-408 repeats the same header.
- Fix: add `name`, `boss_arena`, `boss_phases`, `boss_action`, `spawn_cols`, and a `signature` column (U4, CV:224)
  to the column list and to all eight EX:410-418 rows. Owner: game director; tools-programmer confirms.

### D3 (high). Peril and ending decisions contradict the user decision log
- RP:96-97: "peril tone is real tension in Lava and Neon ... a real sense of loss ... no on-screen harm" (user).
  CV:36-38 lists this as OPEN with "proposed: comic, reversible", and CV:115 states "Peril (Lava, Neon) is comic
  and reversible" as a hard pillar line. CV:129 itself calls Lava "We might lose this".
- RP:98-99 decides the ending (Carnival boss plus bonus; h1-h3 optional epilogue). CV:143 labels it "proposed".
- Fix: move both to "Decided by the user", reword P3 to "real tension, kid-safe, no hero shown hurt; comic fail
  reactions only", and keep only the detail as proposed. Owner: game director.

### D4 (high, calibration). The ring near-miss teaches the wrong repair
- EX:133-146 `ex_near_candy_05` mask: rows 0-1 are the top band, 2 cells thick; the ring recogniser needs
  "band width 3+ everywhere" (SV:70). EX:148-152 blames only the bottom notch and says the rest is good and a
  "repaired mask" fixes it. Removing the notch still fails the ring test (top band 2 thick).
- Fix: either thicken the top band to 3 (hole 4x4 at rows 3-6 in a 10-row mask) and say so, or state both
  causes. Owner: game director.

### D5 (high). Two incompatible score scales, and the near-miss is out of line with the cap
- EX:20: "9.0 = a structural fix is needed". CV:447-449: "9.6 or lower = a structural fix is needed";
  CV:480-483 V6 says the rubric must "separate 9.7 from 8.5". `reference-quality-bar.md` caps any open defect
  at 8.5, and CV:459-464 caps at 8.0.
- EX:116-117 gives `ex_near_forest_06` L1 9.3, L4 9.3, L5 9.2 although it has an open structural defect
  (generic scene, rule-naming signature): by the bar it cannot exceed 8.5.
- Fix: one scale in one place (CV section 9); rewrite the near-miss expected scores to 8.0-8.5, or relabel the
  sample as "about 9.0 before caps". Owner: game director.

### D6 (medium). `ex_forest_h1` spoils its own reveal
- EX:251 tutorial_line "Hold the bridge, then find the kid goat." names the hidden kid goat that EX:257 says
  is revealed in the first 10 seconds (U16 reveal, user: "end must not be obvious sometimes"). The line also
  says "hold" first while `goal_type` is `survive>span>rescue_all` (EX:258) and the headline is "cross" (EX:256).
- Fix: tutorial line "Help Nanny Tuft cross before the gale." (7 words). Owner: game director.

### D7 (medium). Exemplars silently consume campaign slots
- EX:6-13 and CV:291-294: exemplars are inside the U3/U14/U17/U18/U19 checks and no real level may reuse their
  set piece, terrain, mask, ending or character. EX:421-422 says Meadow, Forest and Pirate each already spend
  their one plain square, and 8 of 15 seed terrains (SV:23-30) are used up. Result: real `meadow_01` (the
  gentlest level) cannot be a plain 8x8; Pirate (ship-based, CV:141) cannot use `ship_deck` or `dock_pier`.
- Not stated: do exemplars count in the per-biome tallies (7-8 ids, max two uses, U6) or sit outside them?
- Fix: state "exemplars are checked for collision only and do not count toward per-biome tallies or the one
  plain-square allowance", or accept the loss and re-seed SV. Owner: game director with technical-artist (SV).

### D8 (medium). U12 names a tier that does not exist
- CV:265: "For tiers 01-09 and 11". Ids are `_01`..`_10`, `_bonus`, `_h1`-`_h3` (CV:204); there is no tier 11, and
  h1-h3 are not mentioned. Fix: say "01-09 and bonus; h1-h3 exempt (or add a rule)". Owner: game director.

### D9 (medium). No in-biome pacing, difficulty curve or per-level time
- CV:123-136 gives one intensity per biome. CV:415-417 says g0 "rises within and across biomes", but intensity
  drops Lava 5 to Forest 2 and Neon 5 to Celestial 3. Nothing says what the 14-level curve inside a biome looks
  like (rest level, spike level, where D2/D3 defence may sit), and CV:429-436 has no field for estimated play time,
  per-level intensity, audio cue or optional/secret placement, all of which the level-document standard needs.
  MP:12-13 gives 20-90 s per phase only; no whole-level target.
- Fix: add to section 8 a per-biome intensity shape (for example 01 gentle, 04 first spike, 07 high, 10 peak,
  bonus rest) and two spec fields, `target_time_s` and `intensity_1_5`; define whether g0 follows biome
  intensity or only tier. Owner: game director with systems designer (M4).

### D10 (medium). Fairness is not testable at spec time and the solver is under-specified
- CV:109-111 (P3d): wins 98% of 500 seeded runs, but a loss counts "only if no legal winning line existed".
  Proving "no line existed" on a 12x12 board with real-time hazards (strike, tilt, gust) is not tractable, and
  "unlimited time" breaks real-time hazards. CV:379 budgets 5 days.
- CV:112-114 telegraph floors apply only to `strike`; gust, tilt, wobble and twist phases (EX:34, 230) have no
  seconds-based warning rule.
- Fix: define P3d as a bot with fixed skill tiers plus a pass bar per tier, and add a P3e-style rule for every
  hazard that changes the board mid-level. Owner: systems designer (rule), gameplay-programmer (solver estimate).

### D11 (medium). Readability limits and similarity maths are incomplete
- Board sizes 8x8-12x12 appear only in SV:57 and LI:15; CV gives no minimum cell size or maximum footprint at
  720x1280, yet P3a/C3 demand readability there. A 12-wide board on 720 px is about 55-60 px per cell with margins.
- CV:226-228 pads canonical masks to 12x12 but not the alignment (top-left or centred); canonical form (CV:198)
  also treats a funnel and an upside-down funnel, or an L whose leg is above vs below, as the same level, though
  gravity makes them play differently.
- Fix: state min cell px and the alignment, and either keep orientation in U5 or say rotation duplicates are
  intentional. Owner: game director with technical-artist.

### D12 (medium). Scene-kit estimate is not credible
- CV:371 and CV:400-403: about 40 days for 84-96 terrain builds, 84-96 looping acting set pieces, about 24 cast
  poses and 4-6 meters (over 190 assets) is roughly 1.6 hours each, with a reduced-motion pose each.
  CV:381 totals 81 days on that basis. Fix: producer to reprice; the plan should also say which U17 quotas
  shrink if the budget fails. Owner: producer with technical-artist.

### D13 (low-medium). Stale or conflicting labels across the plan set
- CV:1 "revision 7" vs CV:11 "r9 (this revision)" vs this review being r10; EX:1 "revision 7".
- CV:38 open item (3) says the plan task list needs the uniqueness-script task; RP:130 already lists it.
- RP:20 says Pirate sits 5th; RP:62 still says "At most 4 plain-square boards per biome" against U18's 1.
- Fix: renumber, close item (3), and mark RP:62 superseded. Owner: game director / producer.

### D14 (low). Rule wording gaps
- CV:280: "No pattern is used more than twice per biome" does not say whether `plain` counts; as written it forces 12
  non-plain levels.
- CV:260 lists a `comet` attacker; SV:44-47 has no comet action id.
- CV:226-228 / SV: row-clear on segmented masks (the split top of a bridge span, twin towers, island chain) is
  not defined, but `row_cannon` and `clear_n` depend on it. Put it in the handbook brief (CV:355-357).
- Owner: game director / systems designer / technical-artist respectively.

### D15 (low). `ex_pirate_10` phase 3 contradicts the idea definition
- CV:405-406 defines an idea as including "a higher speed"; EX:230 phase 3 is "higher speed ... no new idea".
  Fix: reword to "one idea: higher speed". Owner: game director.

### D16 (low). Verb and goal names collide
- `survive` and `rescue` are both verbs (CV:63-64) and goals (`survive`, `rescue_all`, CV:388); D1 is
  `verb: defend` with `goal_type: survive` (EX:414). Rename the goals (`hold_out`, `save_all`) or add a glossary line.
  Owner: systems designer.

### D17 (low). Near-miss rationale conflicts with global ids
- EX:118-121 faults `summit_ledge` and `lantern_sway` for "not belonging" to a forest gully, but CV:285-287 and
  SV:7-8 say ids are global and re-skinned per biome. State instead that the defect is a missing tie to the place
  (the swap test), not the id. Owner: game director.

## Concrete fixes by owner

- **Game director (CV/EX author):** D1 wording, D2 columns, D3, D4, D5, D6, D7 wording, D8, D9 shape and fields,
  D13, D14 (U16), D15, D17.
- **Systems designer:** D9 (g0 vs intensity), D10, D14 (row-clear in handbook brief), D16.
- **Gameplay-programmer (via Godot master):** confirm void semantics for D1; solver cost for D10.
- **Technical artist:** D7 (re-seed SV), D11 (cell size, alignment), D14 (comet id), D12 pricing input.
- **Tools-programmer:** D2 column support, D11 alignment in the IoU script.
- **Producer:** D12 reprice and fallback quotas; D13 propagation.

## Top 5

1. D1: void is undefined and `ex_forest_05` cannot be built as drawn (EX:61-70, CV:431-432).
2. D2: the `level_table` lacks `name`, boss triple and `spawn_cols`, so U12, the name check and the corridor
   numbers cannot be scripted (CV:207-214).
3. D3: peril tone and ending contradict the user's decisions (CV:36-38, 115, 143 vs RP:96-99).
4. D5 and D4: the score scale and the near-miss calibration are wrong (EX:20, 116-117, 133-152).
5. D9: no in-biome pacing curve, play-time target or intensity field, and g0 vs intensity conflict (CV:123-136,
   415-417, 429-436).
