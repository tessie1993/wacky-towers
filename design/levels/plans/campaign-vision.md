# Campaign vision: Wacky Towers (phase 1 brief, revision 3)

Author: studio game director. 2026-10-14. Revised after the r1 and r2 plan-vision reviews in
`production/qa/quality-review/`.
Inputs: the redo plan, quality bar, art bible, reference boards, `catalog.json`, `progression.md`,
`minigames.md`, `level-identity-spec.md` (including its later user rules), the 4.8/10 level review (source of
the "tier 05 is `build_race` + height in 11 of 12 biomes" figure) and the level playtest.
User words: "all levels look the same", "different in game play", "narrative first", "pass grade must be 9.7",
"never clear so many layers", "level end must not be obvious from the start sometimes", "so mundane".
Decisions in force: 168 levels (12 biomes x 14); a FRESH story keeping only the cast; a plain-words
mechanics handbook is written before any art or code (plan decisions log).

**Biome order (user decision, 2026-10-14: Pirate Cove plays 11th):** 1 meadow, 2 candy, 3 ice, 4 underwater,
5 lava, 6 forest, 7 cave, 8 clockwork, 9 neon, 10 celestial, 11 pirate, 12 carnival. This differs from the
current `catalog.json` (pirate 5th); the coordinator must reorder the catalog, `economy.json` and
`progression.md` to match. Dune Bazaar is dropped from the art bible's 12. Needed
art-bible changes: a Pirate block row (user decision), removal of Dune Bazaar, and section 5 rows for Lana,
Boulder and Glim.

**Open decisions for the user (everything marked "proposed" below is not decided):**
(1) concept A is only a recommendation; (2) `tumble-fair.md` is replaced by the 14-level Carnival biome
(proposed; phase 2 resolves it); (3) how scary is comic peril in Lava and Neon (proposed: always comic and
reversible, a hero is never shown hurt); (4) the plan acceptance line "at most 5 `clear_n` goals" is
superseded by U15 (updated in the plan); (5) the plan task list needs a phase 3 task for the uniqueness
script (owner tools-programmer, see section 5).

## 1. Campaign fantasy

**Pitch:** a cosy tower-building puzzler where every island has a problem only a stack can fix, and the
world answers back.

You are the Wizard's trusted builder in a sky of twelve floating islands. You drop, turn and slot chunky
blocks. Each stack is an answer: a bridge a goat can cross, a wall that shelters the heroes, a lookout that
spots the ship. Stacking matters because in this world **built things hold the sky together**. A cleared
layer pays out something in the story: it charges a beacon, mends a floor or drains a flood.
Dame Ada, Bram and Sif are your party: their perks (Stitch, Smash and Redraw, kept from the old design;
proposed as tools you choose before a level) and they react in the scene to what you build. Minigame blocks are the
island's own games, the hard track (h1-h3) is the mastery epilogue, and stars are the Wizard's thanks. The
player feels clever, a bit mischievous, and rooted for: someone always cheers when a piece lands well.

## 2. Three pillars

Each test scores 0 fail, 1 partial or 2 pass; a level passes at 2. Tests come in two sets.
- **Spec-time tests (phases 2-5), read from beats and specs:** P1, P2a, P2b, P2c, P3b, P3c, plus the
  `target_visible` field standing in for P3a.
- **Build-time tests (phases 7-8), run on the built level, JSON and screenshots:** all of the above plus P3a
  and P3d.

**P1. Every level is a scene, not a stage.** One place, one problem, one reason to stack.
- *P1 swap test:* reskin the level into another biome. If it still makes sense, it fails. The story event,
  the set piece and the headline objective must be tied to this place.

**P2. The stack is the answer, and never mundane.** The goal is something the player builds, protects or
reveals, and the world visibly changes when it is done.
- *P2a world change:* name the visible world change on win (every level, including bonus and minigame levels).
- *P2b drop change:* applies to `height`, `shape` and boss levels only. Name the rule or board shape that changes
  how pieces are dropped here.
- *P2c mundane test:* describe the level without a bare counter (U15). If it reads "do the generic thing in
  a different skin", it fails.

**P3. Cosy mischief, always fair.** Failure is funny and cheap, wins are generous, nothing is mean.
- *P3a opening clarity (build-time):* 5 first-time players; at least 4 say what to do first, from the start
  frame, within 10 seconds. The ending may change later (U16); the opening objective may not be hidden.
- *P3b comic fail (spec-time):* a lost attempt shows a comic reaction and restarts in 2 seconds or less.
- *P3c rule budget (spec-time):* the level adds at most one new rule (U10).
- *P3d winnable (build-time):* a solver (or a bot with unlimited time) wins at least 98% of 500 seeded runs;
  a loss counts against the level only if no legal winning line existed (otherwise it is a bot failure).
- Peril (Lava, Neon) is comic and reversible. Accessibility: every cue is shape plus colour plus sound, and the
  level reads with reduced motion on.

## 3. Emotional arc, stakes and ending

Intensity target 1-5 (tier 10 peak). **Stakes** say what is at risk if the island is not mended (always
reversible and gentle). **The Stakes column is proposed:** the narrative lead may change the wording (it
presupposes concept A) but not the escalation shape (intensity column, Lava reversal, Neon low).

| # | Biome | Role in the arc | Stakes | Int. | Player leaves feeling |
|---|---|---|---|---|---|
| 1 | Meadow | **Wonder and welcome.** Meet the Wizard and Ada. Teach by doing. | A picnic and a path | 2 | "I can do this, the world is kind" |
| 2 | Candy | **Mischief.** Sweet chaos, a prankster problem. | A town of sweets goes sticky | 3 | Delight, a giggle at a mess |
| 3 | Ice | **Hush and slide.** Quiet music, slippery floors, care for a hero. | A lost creature is cold | 2 | Calm awe, careful hands |
| 4 | Underwater | **Strange wonder.** Light from above, odd friends, a shy giant. | A reef loses its glow | 3 | Curiosity with a hint of unease |
| 5 | Lava | **Danger, the midpoint reversal.** The team is truly in trouble. | The party is cut off | 5 | "We might lose this" |
| 6 | Forest | **Tangled warmth.** Shelter after heat; a secret; the cast bonds. | A home in the trees | 2 | Relief, belonging |
| 7 | Cave | **Trust in the dark.** Tight boards (narrow masks inside the 8x8 minimum box), one hero alone with you. | A lost light | 3 | Quiet courage |
| 8 | Clockwork | **Tension of precision.** A machine everyone is stuck in; ticking and tidy. | Time itself runs down | 4 | Focus, joy in order |
| 9 | Neon | **Low point.** Bright but empty; a setback the heroes face; lowest morale. | The party is split | 5 | Doubt turning to resolve |
| 10 | Celestial | **Awe and gathering.** Above the weather; everyone returns; stakes named. | The whole sky | 4 | Sublime calm, readiness |
| 11 | Pirate | **Swashbuckling swagger.** Loud, rowdy rivals and a ship of the party's own; the energy lift before the finale. | Treasure and a ship's pride | 4 | Cheeky, confident, ready to party |
| 12 | Carnival | **Triumph and release.** Every learned idea returns as a game. | The world holds, or sags | 5 | Joy, pride, "I built all this" |

Every biome has a tier-10 boss (the first is in Candy; "first real boss" is retired). The early run (1-4) is
wonder, mischief, hush and strangeness. The Lava reversal sits at chapter 5, near the midpoint, and the Neon
low at chapter 9. Recovery takes three biomes: Celestial gathers the party, Pirate lifts the mood with swagger,
and the Carnival pays off. Pirate must not feel like a reprise of Underwater (water, tides, a shy giant): its
play is rowdy, rival-driven and ship-based.

**The ending (proposed, narrative lead owns detail).** The campaign ends on the Carnival tier-10 boss and its
bonus level, with an ending panel. h1-h3 are an optional epilogue and not the ending. Each hero has a stated
resolution beat in biomes 9-12, appears in at least 6 of the 12 chapters, and the Wizard has a flaw (kind,
forgetful, a bit vain) that is shown by biome 4, costs the party in biome 9 (Neon) and pays off in the finale.

## 4. Tone rules

**Voice.** Storybook-wacky: warm, a little silly, kind to everyone. Villains are mischievous or misunderstood.
Nobody dies. Nothing is cruel.

**Wordless in-level moments.** Anything during play is shown by animation, sound and the set piece. No dialogue
during a drop, no text over the board. Intros and outros carry at most one short caption outside play.

**Text budget (live UI only, never baked into art).**
- Story caption: one sentence, 14 words or fewer, on a title ribbon over a painted panel. Ribbons are purple
  wood or gold plaques with cream caps text, never paper, scroll or parchment.
- Tutorial bubble: 12 words or fewer, shown once, dismissible, never over the grid.
- Level and boss names: 1-4 words, one pun at most (example: "Clover Circle", "Madame Meringue").
- No caption needs an earlier one. Story is optional and never gates progress.

**Humour.** Physical and visual: wobbling stacks, a hero bonking a door, a sheep on the wrong tower, a crab in
a tiny hat. No sarcasm, no mocking the player, no fourth-wall nagging. Losing is a pratfall, not a shame.

**Hard rules.**
- No third-party IP of any kind, Nintendo included (characters, items, names, music, layouts). Boards 09-12 are
  layout only.
- No "Tetris" naming. Never copy the board logos ("TETRO PARTY DIMENSIONS", "WACKY PARTY", "PARTY QUEST");
  our logo is `logo_master.jpg`.
- **No board titles as names.** No level, boss, chapter, minigame or module name may equal or paraphrase a
  title on the reference boards (`assets/art/reference/index.md`) or in the `minigames.md` Naming fixes table
  (for example Bridge Bashers, Tumbling Towers, Fort Blast, Kraken Blockade, Molten Guardian, Maze Heist).
  A name-check script catches exact and near-match names against those two sources; reviewers catch
  paraphrases (N5, L1). pirate_03, 09, 10, h1, h2 and the
  `bridge_dash` title are renamed in phase 4. The art bible and plan quote board names as references only.
- No beige or parchment UI: open purple-wood frames over a painted scene (board 05), plum glass planks.
- **Cast.** Recurring named characters: the Wizard (mascot); heroes Dame Ada = art-bible Knight (silver and
  red), Bram = Dwarf (ginger and steel), Sif = Elf (green and tan); NPCs Lana, Boulder and Glim (proposed
  species: Lana an alpaca and Boulder a hippo, from story-v2; Glim's species is set by the narrative lead;
  the cast decision fixes none). Lana, Boulder and Glim need art-bible section
  5 rows (silhouette, colour key, prop) before phase 6. Pirates, robots, explorers and similar archetypes are
  unnamed one-offs. New characters follow `art-bible.md` section 5.

## 5. "Every level unique" as testable rules

This extends `level-identity-spec.md` and keeps its rules except where marked superseded. Every level has four
facets: **story beat**, **place** (set piece, time of day), **way of playing** (unique triple plus signature)
and **look** (start-frame silhouette).

**Definitions.**
- `main_rule`: a required spec field, one id from the roster. Two rules are the same if their ids match,
  whatever the parameters.
- **Canonical mask:** the board mask normalised under the 8 rotations and reflections, compared as a string
  (the smallest of the 8). A **plain square** is a full rectangle with no holes and no notches, at any size.
- **The pill:** the rule list shown on the level card.
- **Beat id = level id** (`<biome>_01`..`_10`, `_bonus`, `_h1`..`_h3`).
- **Counter goal:** any goal whose only HUD readout is a bare number to reach or fill (rows, cells, seconds)
  with no story object.
- **Script check:** `tools/qa/check_level_uniqueness.gd`. Owner: tools-programmer. Built in **phase 3**, so it
  exists before phase 4 specs are written; the plan task list gets this task (size: 2 days). It reads the
  `level_table` that ends each biome plan and verifies U3, U5 (table mode), U6, U7, U12, U14, U15, U16 and the
  name check. It reports observations; reviewers score. `level_table` is a Markdown table with the columns
  `id`, `goal_type`, `main_rule`, `mask` (canonical string), `set_piece`, `time_of_day`, `weather`, `camera`,
  `opening_event`, `ending_pattern`, `headline_objective`, `role`, `callback_of`.

**Rules.**
- **U1 Beat first.** Every spec starts from its beat id and has a reason to stack.
- **U2 Swap test.** The beat, headline objective and set piece cannot move to another biome unchanged (P1).
- **U3 Unique triple.** `(goal_type, main_rule, canonical_mask)` is unique across the 168 levels. Hard remixes
  and `callback_of` levels are not exempt: a remix changes at least one element of the triple and also differs in
  `set_piece` or `time_of_day` from its source.
- **U4 Signature** is a story sentence of 4-14 words naming the event or place, not the rules.
- **U5 Squint test.** Similarity of two levels in a biome = IoU of their canonical masks padded to 12x12; the
  **threshold is fixed here: IoU of 0.85 or more fails.** In phases 4-5 the script compares the table's
  canonical masks and set-piece ids; in phases 7-8 it compares real start frames (HUD and skin removed) with
  the same threshold. The reviewer also hand-checks 12 random pairs per biome and none may be confused.
- **U6 Look spread.** Within a biome no two consecutive levels share `time_of_day` + `set_piece`; at least 3 of 5
  `time_of_day` values (the night biomes Celestial and Neon may use 2 plus dawn or dusk); at least 3
  `weather` values; **7-8 set pieces** (U14 needs 7 at least for 14 levels). This supersedes the identity
  spec's "4-6 set pieces per biome": 84-96 set pieces in total.
- **U7 Feel spread.** Per biome: at least 6 distinct goal types, at most 4 plain squares (U14 forces them to be
  4 different sizes), at least 3 levels with a non-default camera. **No `clear_n` headline goals (U15)**; this
  supersedes the identity spec's "at most 5 `clear_n` levels".
- **U8 Opening event.** One distinct `opening_event` id per level (same field as the beat's). **Phase 2 assigns
  and lists the ids** (the narrative lead); phase 4 may refine them under the same rule: none repeats within
  a biome and none appears in more than 2 biomes, so phase 2 plans for at least 84 distinct ids.
- **U9 Boss finale.** Every tier-10 level is a phased boss (all 12 biomes, Neon included; the `progression.md`
  no-boss "show" finale is withdrawn), tied to its chapter villain, changing the arena at least once, and beaten
  by building.
- **U10 Rule budget.** A level adds at most one new rule. Levels 01-03 show two rules on the pill only if one
  was taught in an earlier biome. A biome adds at most 2 new rules. A rule is taught alone before it combines.
- **U11 World change.** The clear changes the scene (a lit lamp, a crossed bridge); failure is a comic reaction.
- **U12 No cookie-cutter slots.** For tiers 01-09 and 11, the same tier number may not share a goal type in
  more than 4 of 12 biomes. Tier 10 is exempt (U9). Instead the 12 bosses differ in arena mask, phase count and
  the building action that damages them (the "boss triple"; actions come from a closed list in the handbook,
  for example wall, ramp, bridge, bait, cage, pillar), and no two bosses share all three.
- **U13 Echoes** are allowed only as a deliberate callback with a story reason, marked `callback_of`, and still
  obey U3.
- **U14 Look fingerprint.** `(canonical_mask, set_piece, time_of_day, weather)` is unique per level across the
  campaign; within a biome no `set_piece` repeats more than twice and no `canonical_mask` repeats.
- **U15 No counter goals.** No level's headline goal is `clear_n` or any counter goal (defined above).
  `height`, `shape`, `survive` and the other goals are legal only when the HUD names a story object (the
  lookout, the dam, the cloud) and the number is secondary. `clear_n` is a means only (it charges, bonks,
  drains). Each spec records `headline_objective` (story wording, 8 words or fewer) that contains a noun from
  the beat and no bare numeral.
- **U16 Surprise quota.** At least 4 of the 14 levels in each biome use an `ending_pattern` other than `plain`
  (twist, reveal, guest, secret, story). **At least 3 of those 4 must be twist, reveal or guest** (the end
  is not predictable from frame 0); secret and story may fill only the 4th slot. No pattern is used more than
  twice per biome. The spec field `ending_pattern` is written to `metadata.ending` in the level JSON. Each
  one is telegraphed, fair, carries a comic fail reaction and keeps a clear opening objective. Tier 10 and
  level 01 may not hide their goal. **Reconciliation:** P1 and P3a demand a clear opening problem; U16 lets
  the ending change after it. Secret endings are optional extras, never required.

## 6. Brief for the narrative lead (phase 2)

**Outputs:** `design/narrative/campaign-story.md` and `design/narrative/beats/<biome>.md`. Each beat file has
one YAML front-matter block per beat: `id` (= level id), `role`, `place`, `who`, `problem`, `why_stack`,
`headline_objective`, `ending_pattern`, `world_change`, `wordless_moment`, `opening_event`, `caption`
(optional, 14 words or fewer). Field limits: one sentence each, 20 words or fewer.

**The fresh story must achieve:**
1. One through-line a child can retell in two sentences, with a reason to travel island 1 to 12 in the order
   of the biome-order paragraph at the top (Pirate 11th).
2. Stacking is canon: say why building holds the world together.
3. Twelve chapters, each with a problem, a local ally or villain, and the section 3 role and stakes. Pirate is a
   chapter of its own, not Underwater's twin. Every biome has a boss face.
4. The cast earns its place: hero arcs and resolutions in biomes 9-12, each hero in 6+ chapters, the Wizard flaw
   and payoff, NPC roles for Lana, Boulder and Glim, and the species for Glim. Pirate (chapter 11) is the
   swaggering run-up to the Carnival and must not reprise Underwater.
5. 14 beats per biome with a **function label** (teach 01-03, twist 04-06, combine 07-09, boss 10, bonus,
   h1-h3 remixes). The narrative lead writes situations; **the systems designer owns the mapping from function
   to rule**.
6. At least 4 beats per biome carry a non-plain `ending_pattern`, at least 3 of them twist, reveal or guest
   (U16), and none is a counter goal (U15). **This phase assigns the `opening_event` ids** (U8, 84+ distinct).
7. A story that survives as 12 chapter captions plus level names; all names pass the board-title ban.
8. Resolve the `tumble-fair.md` conflict (proposed: the 14-level Carnival biome replaces the side island).
9. Freshness: borrow nothing from old level names or story-v2 beats.

**Three candidate high concepts** (proposed; pending the user's choice):
- **A. "The Wobbling World."** The Wizard's sneeze topples the Great Tower that pins the islands, scattering
  twelve Keystones. Each island sags, drifts or goes odd, and the trio rebuilds it. *A cosy island-hopper, and
  also the world is held up by what you build.* Strength: stacking is the plot; the finale is a refit party.
  Risk: a generic accident; give the Wizard a real flaw.
- **B. "The Grand Tumble Fair."** The Wizard invites everyone to a once-a-century Fair; the heroes win a
  ticket-stub on each island by fixing its mess, then find the host is secretly lonely. *A trip across twelve
  biomes, and also every island is a game at the Fair.* Strength: party tone, minigames, natural Carnival
  climax. Risk: a thin villain, errand-like middles.
- **C. "The Lamplighters' Road."** The sky is dim because twelve beacons are out; the heroes light each by
  building a base tall enough to reach the light line. *A stacking puzzler, and also a quest to bring the light
  back.* Strength: a visual payoff per win. Risk: an item quest; the Neon low needs a reason.

**Recommendation: A** (the narrative lead's call; B or C may win if they give better beats). It makes P2 the
plot, gives each biome a simple problem, and earns the Carnival payoff. Borrow C's beacon-light as a win reward.

## 7. Brief for the systems designer (phase 3)

**Outputs:** `design/levels/plans/mechanics-handbook.md`, `mechanics-roster.md` and `progression.md` v2
(in the section 0 biome order), plus the uniqueness script (tools-programmer, section 5).
- **Handbook (owner: systems designer; phase 3 deliverable; written before any art or code, per the user's
  order):** a plain-words entry for every rule and goal a player meets: what it does, how the player reads it,
  a worked example, what it never does, and its debut level. No engine terms.

1. **Mechanics follow the story.** One mechanic family per biome from its chapter's problem. Reuse existing
   rules where they fit; list engine gaps (boss phases, goal phases, hidden or revealed goals, story-objective
   HUD text, ending events, the minigame phase runner, the shape overlay) each with an owner and a size.
2. **Teach, twist, combine.** A biome adds at most 2 new rules (U10), each taught alone. Include a cross-biome
   dependency graph. The systems designer owns the function-to-rule mapping for the narrative beats.
3. **Goal vocabulary as story objectives.** Define every goal's HUD wording. Allowed goals: `height`, `shape`,
   `survive`, `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven` and the minigame goals. `clear_n`
   is a means only (U15). Define the ending patterns as engine features (goal phases, reveal, guest, secret).
4. **Minigames.** The 16 modules each have a debut, a recall, the beat that motivates it and a tournament use;
   at most 2 debuts per biome; define the phase runner contract.
5. **Bosses.** Twelve tier-10 bosses with distinct boss triples (U12), arena changes per phase, beaten by building.
6. **Hero perks.** State how Stitch, Smash and Redraw work as pre-level tools (proposed: Ada Stitch, Bram
   Smash, Sif Redraw, following the cast decision) and how they interact with each biome's rules.
7. **Difficulty and unlocks.** Formulas for `g0`, goal size and stars by tier and biome index: `g0` rises within
   and across biomes, the hard track beats tier 10, finale difficulty is not below tiers 07-09, stars depend on
   the rules. Keep the 15 of 30 star gate (defined as stars in the biome needed to open the next) unless argued.
8. **Fairness.** No `fixed_list`; opening sets for each level 01; spawn safety; soft-lock warning;
   `meadow_01` winnable in under two minutes.

## 8. Brief for the level design lead (phase 4)

**Outputs:** `design/levels/plans/<biome>.md` v2 for all 12 biomes (4 groups of 3), each ending with the
machine-readable `level_table` for the script check. Set pieces: 7-8 per biome, 84-96 in total; the technical
artist owns `assets/data/set_pieces.json` and flags art cost per piece (the file does not exist yet).
1. **Start from the beat.** Each spec opens with its beat id (= level id).
2. **Required fields per level:** `id`, `headline_objective`, `ending_pattern` (written to `metadata.ending`),
   `metadata.signature`, `main_rule` (and extras, each linked to its handbook entry), `goal_type`, goal
   parameters `n` (from the phase 3 formula), `target_visible` (yes or no, with where), board mask (ASCII grid: `#` floor, `.` void,
   one row per line), minigame block, full `look` block, `g0` and stars from the phase 3 formula, role,
   `opening_event`, world change on win, comic fail reaction, `callback_of` if any.
3. **Prove uniqueness.** The `level_table` must pass the script check; group leads check cross-biome U3 and U14.
4. **Readability.** Targets (shape goals, keyholes, objectives) are visible from frame 0 at 720x1280, checked in
   the spec by a "target visible" field; the active piece differs from the stack; the landing marker is high
   contrast. Flag engine needs.
5. Level 01 has at most one rule, an opening set and a gentle `g0`. The bonus is a relaxed set piece. Hard
   levels are remixes under U3 with a new look. Specs only; no JSON edits in this phase.

## 9. The 9.7 review rubrics

**Scoring.** One decimal, never rounded up. **A phase passes only if every criterion is at least 9.7.**
Anchors: 10 = no change you would request; 9.7 = wording or tuning notes only, no structural change; 9.6 or
lower = a structural fix is needed. Reviewers list ranked defects with owner and fix; makers fix.
- **Preconditions.** QA runs the scripts (U3, U5, U6, U7, U12, U14, U15, U16, the name check) before human
  scoring; the reviewer applies the cap: a script failure caps the matching criterion at 8.0.
- **Coverage.** Read every beat and spec of one biome in full and at least 5 levels of every other biome
  (across teach, boss and hard roles); cite at least 10 level ids per criterion.
- **Calibration.** The **game director** writes one exemplar beat, one exemplar spec and one deliberately weak
  sample (target 8) before the phase 2 gate, stored in `design/levels/plans/exemplars.md`; the panel scores
  them as anchors before reviewing the rest. Makers do not write their own anchors.
- **Pillars.** Phases 2-5 apply the spec-time tests (section 2) to 5 sampled levels; phases 7-8 apply all of them.
- **Caps.** A mundane or counter-based level caps N4, M3 and L3 at 8.0.
- **Each item below uses these anchors unless a "9.7 means" is given.**

**V (phase 1, this vision).** 9.7 means no structural fix is needed. V1 fantasy is clear in a pitch and a
paragraph; V2 each pillar has a test that runs at its stated phase; V3 arc, stakes and ending are defined;
V4 uniqueness rules are measurable, scripted and consistent; V5 briefs name owner, output and fields; V6 the
rubric separates 9.7 from 8.5; V7 every user decision is honoured.

**N (phase 2, narrative)**
- N1 Through-line and logic. N2 Arc, stakes and ending. N3 Cast (arcs, perks hand-off, art rows).
- N4 Beat quality (schema complete, 168 beats; no mundane or counter beat; at least 4 surprise endings per biome).
- N5 Tone, text limits and names (names pass the title script, no IP, no parchment ribbons).
- N6 Hand-off (showable in one place; function labels; opening events unique).

**M (phase 3, mechanics)**
- M1 Story-to-mechanic fit. M2 Teach and combine (budget, dependency graph).
- M3 Variety and quotas (goal set, boss triples, minigame debuts; no mundane or counter goals; surprise endings
  specified as engine features). M4 Difficulty math. M5 Fairness and feel (98% winnable, boss by building).
- M6 Buildability (engine gaps with owner and size). **M7 Handbook:** every rule and goal has a plain-words
  entry (what it does, how it reads, worked example, what it never does, debut level); no engine terms.

**L (phase 4, level specs)**
- L1 Beat fidelity (names pass the title script). L2 Uniqueness (U1-U16 and the scripts).
- L3 Gameplay variety (no mundane or counter-based levels; at least 4 surprise endings per biome).
- L4 Curve and pacing. L5 Readability and fairness. L6 Look and art direction (fingerprint, set pieces, palette,
  no beige). L7 Completeness (all fields, handbook links, `level_table`).

**A (phase 5, art).** 9.7 means each item is met for all 168 levels with no structural fix.
A1 every `look` block and set-piece spec is complete and art-costed; A2 palette and block skins incl. Pirate
match boards 13 and 15; A3 cast rows (silhouette, colour key, prop) exist for all recurring characters;
A4 reference parity; A5 no beige or parchment anywhere; A6 reduced motion keeps every cue readable.

**B (phase 6, build).** 9.7 means zero failures and no workaround.
B1 verifier reports 0 failures; B2 the game boots (`ui_flow_smoke`); B3 every JSON matches its spec and
`level_table` row; B4 boss phases, goal phases and reveals behave as the handbook entries say; B5 CI green and
no `fixed_list`.

**C (phases 7-8, captures).** 9.7 means every level has retained evidence and none is a near-duplicate.
C1 start, mid, clear and end screenshot per level in `production/qa/evidence/campaign-v2/`; C2 U5 and U14 hold
on real frames; C3 targets visible at 720x1280; C4 contact sheets show 12 clearly different biomes; C5 all
pillar tests (spec-time and build-time) hold in play.

**S (phase 8, sound).** 9.7 means every item is audible and mixed without a clash.
S1 every action has feedback; S2 a music theme per biome following the arc; S3 boss and ending cues; S4 a
comic fail sound; S5 the mix is clear and cues are shape, colour and sound redundant.
