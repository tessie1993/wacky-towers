# Plan review r10: campaign vision (phase 1), game designer

Reviewer: game designer (blind, fresh; saw no other review and no earlier round).
Marked as a plan (`reference-quality-bar.md` "Three blind experts per review" rule 1): clear, complete, testable,
internally consistent, buildable. No paper-only cap. No credit for visuals. Strict marking: start at 5, earn each
point with a cite, any open defect caps at 8.5, unsure means lower. Pass mark 9.7 on every item.

Files read: `campaign-vision.md` (V), `exemplars.md` (E), `scene-vocabulary.md` (SV), `level-identity-spec.md`,
`minigame-party-rules.md`, `campaign-redo-plan.md` (R), `reference-study-defence.md`, `minigames.md` (module table),
`reference-quality-bar.md`. I checked the four canonical mask strings in E by hand (see Ex).

## Scoreboard

| Item | Score | Verdict | One-line reason |
|---|---|---|---|
| V1 Fantasy | 8.0 | FAIL | Pitch and paragraph are clear; perks untested, concept A text contradicts the decided premise, party play absent |
| V2 Pillars | 7.5 | FAIL | Tests exist and are phased; several are label checks, one contradicts its own exemplar, human difficulty is untested |
| V3 Campaign arc | 8.0 | FAIL | Arc table is clear and shaped; peril tone conflicts with a logged user decision, no skill curve or recall schedule |
| V4 Uniqueness rules | 7.0 | FAIL | Mostly measurable, but unique-by-mask is gameable, one shape cannot legally exist, IoU is ill-defined |
| V5 Level briefs | 7.5 | FAIL | Owners, outputs and fields named; module work unpriced, scene-kit estimate not derived, field list incomplete |
| V6 Rubric quality | 7.5 | FAIL | Anchors and caps exist; two scales disagree, calibration samples carry unflagged defects, no anchors for V/N/M/L |
| V7 Internal consistency | 6.5 | FAIL | Stale header, stale open items, user-decision conflict, premise mismatch, exemplar/rule mismatches |
| Ex Exemplars | 7.5 | FAIL | Complete exemplar and hand-checked masks are strong; 3 of 8 verbs have no exemplar, verbs inconsistent, unflagged defects |

Phase result: FAIL. Lowest item V7 6.5. No item reaches 9.0, so the 3-citation rule for 9+ is not triggered.

## Score reasoning (earned points and caps)

**V1 Fantasy, 8.0.** Earned: a one-line pitch (V:44-45); a paragraph that fixes the player role, the verbs and the
payoff (V:47-58); "Every level is a minigame" stated once with its constraints (V:53-55); wordless-in-play
(V:151-153). Capped at 8.5 by open defects, then lowered: (a) the fantasy promises hero perks as pre-level tools
(V:51-53) but no pillar test, rubric item or phase gate covers them, and they can break `strike` or `breach_plug`
levels (Smash against a wall defence); (b) the fantasy is solo-campaign only while the studio's own party rules treat
the minigames as 1-4 player rounds (`minigame-party-rules.md:4-10`), so "party-game accessibility" has no home in
the vision; (c) the chosen concept text does not match the decided premise (see V7). Not 10, not 9: three defects.

**V2 Pillars, 7.5.** Earned: each test is scored 0/1/2 with a pass line (V:69), tests are split into spec-time and
build-time sets (V:70-73), P3e gives a numeric telegraph floor (V:112-114), P2b scopes itself to height/shape/boss
and exempts level 01 (V:95-97). Lost: (1) P1b says a "decorative-only set piece" scores 0 (V:83-84) but V:89-91 and
E:80 let a purely cosmetic action (`root_whip`, "no block moves") sit in the 9.7 exemplar; the test is not
decidable. (2) P2d is a label test: it checks that a `verb` field is filled, not that the play differs (V:100-104).
(3) P3d proves a bot can win, not that a child can (V:110-111); there is no attempts-to-win or human win-rate
target. (4) P3a needs 5 first-time players per level, which is 840 sessions if applied to all 168 levels (V:107-109,
459); the sample is not stated. (5) P3b says restart in 2 s or less (V:108) but gives no checkpoint rule for
multi-phase levels and bosses, so a phase-3 loss may restart a 90 s fight. (6) P1c's 60% threshold has no stated
basis (V:85-88).

**V3 Campaign arc, 8.0.** Earned: a 12-row table with role, stakes, intensity and exit feeling (V:123-136); a named
first reversal, midpoint, low and a 3,4,5 recovery (V:138-141); an ending with owner and constraints (V:143-146);
Pirate vs Underwater guard (V:141). Lost: (1) the peril tone in Lava and Neon is written as a rule, "comic and
reversible" (V:115), and as "proposed" (V:38), but the user logged the opposite emphasis: "real tension ... real
sense of loss" (R:96-97). (2) "Intensity" is never tied to numbers: does it drive `g0`, telegraph, board size? Only
P3e uses it (V:113-114), while 7.8 says `g0` rises across biomes (V:415-417), so Forest (2) after Lava (5) is
undefined. (3) The arc is emotional only: no mechanic/skill curve (what the player can do by biome 4, 8, 12) and no
spaced recall for rules (only modules get "a recall", V:398), so a rule taught in Candy can go unused for six
biomes. (4) Carnival "every learned idea returns" (V:136) has no mechanism or quota.

**V4 Uniqueness rules, 7.0.** Earned: closed definitions and a glossary (V:188-216); a fixed IoU threshold (V:227-228);
numeric spreads for look, feel, scene and verb (V:231-302); a named script and its columns (V:207-216); the
arithmetic checks out (84 opening ids, 7-8 set pieces, 25 rules, 81 days). Lost, ranked in the defects below: U3/U14
pass on mask change alone; U18 allows "own size" (same shape, different size); `ship hull` contradicts the corridor
rule; U5 compares independently canonicalised masks with unspecified padding; `min_spawn_width` is undefined and
computed two ways in the exemplars; U12 compares "goal type" though `goal_type` is now a list, and names a
"tier 11" that the id scheme lacks (V:265); the script omits U8, U10 and the boss-triple columns of U12.

**V5 Level briefs, 7.5.** Earned: each brief names outputs, owner, ordering ("mechanic and verb first", V:426-428)
and a required-fields list (V:429-436); the gap table has owner and days and the sum is right (V:362-381);
function-to-mechanic ownership is settled (V:323-324). Lost: (1) the gap table prices a phase runner (5 days) but
none of the 16 modules, and `minigames.md:27-42` lists 8 modules MISSING (no module code, several need rival AI,
a kart, a scrolling board or a two-zone board); (2) the scene kit is "about 40" days for 84-96 terrain builds, 84-96
animated set pieces, 24+ cast poses and meters (V:371, 403) with no per-asset derivation, about 4 assets a day;
(3) P3d solver at 5 days for hidden goals, bosses and physics plates is unrealistic; (4) the required-fields list
omits `name`, `extras`, `canonical_mask`, `corridor_check`, `boss_triple` and `phases`, all of which the exemplars
and U12 rely on (V:429-436 vs E:45-89, E:226-230).

**V6 Rubric quality, 7.5.** Earned: 10/9.7/9.6 anchors (V:447-449); script-failure cap at 8.0 (V:452-453); named
caps (V:460-464); a calibration file with 9.7, ~9.0, ~8.5 and weak samples (E:22-203). Lost: (1) E:26 defines
"9.0 = a structural fix is needed" while V:448-449 defines "9.6 or lower = a structural fix is needed"; a reviewer
cannot place a 9.3. (2) V1-V7, N4-N6, M1-M6, L1-L7 and B have no 9.0-vs-9.7 one-liner; only N1-N3, M7, A, C, S do
(E:389-402). (3) Both near-miss samples carry defects the file does not flag (see Ex), so they do not isolate the
one lesson they claim to teach. (4) The V line (V:480-483) lists what 9.7 means but not what 8.5 looks like, which
is the item's own definition ("separates 9.7 from 8.5").

**V7 Internal consistency, 6.5.** Earned: a glossary that fixes "rule, module, mechanic, verb, extra control"
(V:190-193); superseded values are marked inline (SV, identity spec lines 11, 17, 51); arithmetic is consistent
across the tables. Lost: eight concrete mismatches, all in the defects list (D3, D4, D6, D7, D9, D10, D12).

**Ex Exemplars, 7.5.** Earned: one fully-specified 9.7 level that meets the required-fields list in form (E:45-89);
canonical strings for `ex_forest_05`, `ex_forest_h1`, `ex_pirate_10` and `ex_underwater_09` are correct (I
transposed and flipped each by hand; they match E:70, E:269, E:223, E:332); `level_table` rows for all eight 9.7
samples (E:411-418); the "form, not content" rule (E:6-8); a near-miss with per-criterion scores whose mean is
9.04 (E:116-117). Lost: see D9 and D2.

## Ranked defects (file:line)

**D1 (high). "Different in game play" is measured by mask, not by play.**
- U3's triple is `(goal list, mechanic list, canonical_mask)` (V:219-223); U14 and U18 also key on mask (V:270-271,
  295-299). Two levels with the same mechanics, verb and goal pass by changing one cell, or by `ring 9x9` vs
  `ring 10x10` (U18 allows "its own size"; U5 only fails at IoU 0.85). The user's complaint was gameplay
  (R:6; V:20); `reference-quality-bar.md:45` already says a same-footprint reskin is the same scene.
- Nothing requires the footprint to change how pieces are dropped except for height/shape/boss (P2b, V:95-97);
  `plain square` rows are cleared by 12 other shapes with no stated effect on row-clearing or spawn.
- Fix (game director, systems designer): add a play signature `(verb, mechanic list, goal list)` that must be unique
  per biome and not equal to the previous 2 levels'; forbid size-only distinction (a shape name appears once per
  biome unless its shape changes, not only WxD); add a one-sentence `mask_effect` field ("the funnel squeezes the
  stack toward the middle") scored by P2b for every level.

**D2 (high). The verb is a label with no definition, no test, and inconsistent use.**
- The closed list of 8 (V:64-66) has no definition of what the stack does for each (what is "race" or "carry"
  when one player drops blocks?). The definitions are deferred to a handbook (V:392-395) that does not exist.
- Same mechanics, same goal, same flavour D3: `ex_pirate_10` is `destroy` (E:211), `ex_underwater_09` is `defend`
  (E:312). D1-D4 map to goals (V:389-390) but not to verbs; `ex_forest_05` is `build` with a `survive` second phase
  (E:47, 57); `ex_forest_h1` is `rescue` with `survive` first (E:247-258). No rule says which phase names the verb.
- The module verbs in `minigames.md:25-42` (claim, sort, dig, defuse, squeeze) are not in the closed 8.
- Fix (game director defines, systems designer confirms): add a verb table to the vision (verb, what the stack
  does, win signal, lose signal, one example) and the rule "the verb is the player's main action in the longest goal
  phase"; map D1-D4 to verbs; map each of the 16 modules to a verb or extend the list by change request.

**D3 (high). Conflict with a logged user decision, plus a stale premise and open items.**
- Peril: the user decided "real tension ... real sense of loss ... no on-screen harm" (R:96-97); the vision lists
  it as open "proposed: comic" (V:38) and states "comic and reversible" as a pillar rule (V:115) and the Lava stakes
  row says "We might lose this" (V:129). Reconcile in one sentence.
- Premise: the user chose "The Twelve Keystones" where Huffle the baby cloud topples the Wizard's tower (V:36-37;
  R:113-114). Concept A is titled "The Wobbling World" and says the Wizard's sneeze topples the Great Tower
  (V:332-336), yet V:36-37 says the premise "is concept A".
- Open item (3), "the plan task list needs a phase 3 task for the uniqueness script" (V:41), is already done
  (R:130-131).
- Fix (game director): rewrite V:332-336 to the decided premise, move the peril line to "decided" with the
  no-on-screen-harm limit, delete open item 3.

**D4 (high). Shape and corridor rules contradict each other and cannot be computed consistently.**
- `ship hull` must narrow to "2 cells or fewer over at least 3 rows" (SV:78); every band, arm, tread, link or leg
  must be at least 3 wide elsewhere and a dead end at least 3 wide (V:243-246). A hull meeting its recogniser
  breaks the corridor rule at its bow; one meeting the corridor rule is not a hull. U18's 8-shape quota
  (V:297-298) needs it.
- `min_spawn_width` has no definition (V:238-242). The table computes it as the whole floor run for most rows
  (E:415, 417: 8, 10) but as the 4 spawn columns for `ex_forest_h1` (E:413: 4; the floor run at row 2 is 8 wide,
  E:260-269), and spawning into void rows 0-1 above the spawn columns is not specified (E:270).
- U5: canonical masks are normalised independently (V:198-200) and padded to 12x12 with no anchor stated
  (V:227-228), so two near-identical masks can canonicalise to different orientations and score a low IoU. Compute
  max IoU over the 8 transforms and a stated anchor.
- Shape feasibility: a `moat with centre island` needs 3+1+4+1+3 = 12 wide (SV:73), `island chain` needs at least
  9x9 (SV:77), `twin towers` at least 11 wide (SV:75). The Cave row says "narrow masks inside the 8x8 minimum
  box" (V:131). Say which shapes Cave can use.
- Fix (technical artist, tools-programmer, game director): define `min_spawn_width` and spawn-on-void in one
  paragraph, relax the hull recogniser (bow 3 wide) or drop the shape, and fix the IoU definition.

**D5 (high). Human fairness and onboarding are untested.**
- Winnable means "a solver wins 98% of 500 runs" (V:110-111); there is no human target (median attempts to win,
  share of first-time players who clear tier 01-03 within N tries). P3a is 5 players per level (V:107-109) with no
  stated sample for 168 levels. No checkpoint rule for goal phases or boss phases (V:108, 112; `B4` in V:521).
- No first-10-minutes plan for the core controls or the base stacking skill; `meadow_01` "winnable in under two
  minutes" (V:419) is the only onboarding line, and Meadow must teach up to 5 mechanics in 14 levels (V:256).
- No assist or skip for a stuck child, though the party rules have per-player assists (`minigame-party-rules.md:26-28`).
- Fix (systems designer, game director): add a P3f human test (attempts, per-biome sample of 6 levels), a phase
  checkpoint rule, an onboarding sequence for Meadow 01-03 and an assist policy.

**D6 (medium-high). Buildability: gap table incomplete and one estimate not derived.**
- 8 of 16 modules are MISSING and 8 PARTIAL (`minigames.md:27-42`; rival AI for `catapult_keep`, `splat_claim`,
  `paver_rally`; a kart; a two-zone board); the gap table has only a phase runner (V:369). The "about 81 days" is
  therefore a floor (V:381).
- Scene kit "about 40" for roughly 200 builds (V:371, 403); P3d solver 5 days (V:379).
- Fix (producer, systems designer, technical artist): add module rows with owner and days; derive the scene-kit
  figure per asset class and show the total against the phase 6 buffer, as V:403 already asks.

**D7 (medium). P1b contradicts its own 9.7 exemplar; "the landmark acts" is mostly cosmetic.**
- "Decorative-only set piece scores 0" (V:83-84) vs `root_whip` cosmetic at 9.7 (E:80, E:91-93); `old_tree` decorative
  is the 9.0 defect (E:112-113, E:119-121). Only 5 action ids are rules (SV:44-47) and defence takes at most 1
  of a biome's 2 new rules (V:262-263), so at least 12 of 14 levels per biome have a cosmetic landmark, against
  "the catapult fires, the kraken grabs" (identity spec lines 101-103).
- Fix (game director): define "decorative-only" (no story link and no action) vs "cosmetic action" (story-linked,
  board untouched) and say what share of levels per biome must have a rule action.

**D8 (medium). The script does not check everything V4 calls "scripted".**
- The script list (V:209-211, 451) omits U8 (opening ids, trivially scriptable), U10 (first-occurrence in the
  table), and the `level_table` has no `boss_triple` or phase columns (V:211-216) though U12 needs them
  (V:266-268). Fix (tools-programmer, game director): add the columns and the three checks.

**D9 (medium). Calibration samples carry unflagged defects.**
- `ex_near_forest_06` has `mechanic: [vines]` but goal `span>survive` (E:102, E:110); `span` comes from the module
  `gap_runner` (E:46, E:246). `ex_near_candy_05`'s top band is 2 rows (E:136-137) and the recogniser needs band 3+
  everywhere (SV:72), so it fails twice, but only the notch is named (E:148-152).
- `ex_pirate_10` phase 3 adds `tilt_plate` while saying "no new idea" (E:230), and the verbs differ (D2).
- `ex_forest_05`: the gap is void (E:62-64), so what `span` means when no block can enter the void is not stated.
  `ex_candy_03`: the win condition is a height the tutorial line never states (E:361-363).
- Fix (game director): correct the samples or list every defect; add a one-line `span` rule.

**D10 (medium-low). U12 definition gaps.** "Share a goal type" with a list-valued field and "tiers 01-09 and 11"
(V:265-266) when the id scheme is `01..10, bonus, h1-h3` (V:204-205). Fix (game director): define equality on the
first element and name the bonus tier.

**D11 (medium-low). Exemplar coverage.** Verbs `race`, `carry` and `survive` have no exemplar (E:22-385 cover build,
rescue, defend, destroy, balance), and there is no bonus-level, Carnival-recall or secret-ending exemplar. These are
the verbs hardest to picture in a falling-block game. Fix (game director): add three exemplars.

**D12 (low). Stale text.** V:1 says "revision 7" while V:8 says "r9 (this revision)"; E:1 says "revision 7".
`campaign-redo-plan.md:62` still says "at most 4 plain-square boards per biome" against U18's 1 (V:299-300), and
R:18-19 still puts Pirate 5th. Fix (game director, producer): update header and acceptance criteria.

## Owner-tagged fix list (merged)

| # | Fix | Owner |
|---|---|---|
| 1 | Add a play signature and `mask_effect` field; ban size-only distinction (D1) | game director, systems designer |
| 2 | Verb table with definitions, phase rule, D1-D4 and module mapping (D2) | game director, systems designer |
| 3 | Align premise, peril line, open items with logged decisions (D3) | game director |
| 4 | Fix hull recogniser, define `min_spawn_width`, spawn-on-void, IoU anchor and transforms, list Cave shapes (D4) | technical artist, tools-programmer, game director |
| 5 | Human difficulty test, checkpoint rule, onboarding sequence, assist policy (D5) | systems designer, game director |
| 6 | Price the 16 modules; derive the scene-kit and solver estimates (D6) | producer, systems designer, technical artist |
| 7 | Define decorative vs cosmetic; set a rule-action share (D7) | game director |
| 8 | Extend the script: U8, U10, boss-triple columns (D8) | tools-programmer |
| 9 | Repair the calibration samples; add a `span` rule (D9) | game director |
| 10 | U12 equality and tier naming (D10) | game director |
| 11 | Three more exemplars (D11) | game director |
| 12 | Update header, R:62, R:18-19 (D12) | game director, producer |

Note: the `balance-check` command wrapper that launched this task had no argument and there is no balance data
file for this plan, so that skill was not run; this review is the requested plan review only.
