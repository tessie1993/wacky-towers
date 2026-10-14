# Campaign vision: Wacky Towers (phase 1 brief, revision 7)

**Contents.** 1 Campaign fantasy; 2 Three pillars and their tests (P1a-P3e); 3 Emotional arc, stakes and ending;
4 Tone rules; 5 "Every level unique" (glossary, `level_table`, rules U1-U19); 6 Narrative brief (phase 2);
7 Systems brief (phase 3, engine gaps); 8 Level brief (phase 4); 9 Review rubrics (N, M, L, A, B, C, S, V).

**Changelog.** r1: U9/U12 settled. r2: counter goals, surprise quota. r3: scene rule, U17. r4: `scene-vocabulary.md`.
r5: global ids, corridor rule. r6: defence flavour. r7 (rulings A and B): mechanic and verb first, footprints,
U18, U19. r8: glossary, `extra_control`, recognisers, engine gaps, build ceiling. r9 (this revision): recogniser
priority, sized gap tail, 25 rules, exemplar fixes, contents and changelog, rules in numeric order. The
build-ceiling paragraph is rewritten to the user's ruling "mark each thing for what it is" (plan gates score the
plan; screenshot ceilings and the paper-only cap apply only at build gates, phases 7-8).

Author: studio game director. 2026-10-14. Revised after the r1-r9 plan-vision reviews in
`production/qa/quality-review/`. Inputs: the redo plan, quality bar, art bible, reference boards, `catalog.json`,
`progression.md`, `minigames.md`, `minigame-party-rules.md` (user decision), `level-identity-spec.md` (with its
later user rules), `exemplars.md`, `scene-vocabulary.md`, the 4.8/10 level review
(source of "tier 05 is `build_race` + height in 11 of 12 biomes") and the level playtest.
User words: "all levels look the same", "different in game play", "narrative first", "pass grade must be 9.7",
"never clear so many layers", "end must not be obvious sometimes", "so mundane", "more art than only the grid",
**ruling A** "Minigames are the level. The principles of minigames. The game mechanics will be the base or bases
of each level", **ruling B** "Scene variety should not have gotten 9.0 out of 10 but 3. All scenes were square
grids... Not varied at all" (163 of 168 current levels are 8x8 squares; only 9 have a mask).
Decisions in force: 168 levels (12 biomes x 14); a FRESH story keeping only the cast; a plain-words
mechanics handbook before any art or code. **Order of a level spec: mechanic and verb first, then the goal,
then the footprint and scene, then the look.**

**Biome order (user decision: Pirate Cove plays 11th):** 1 meadow, 2 candy, 3 ice, 4 underwater, 5 lava,
6 forest, 7 cave, 8 clockwork, 9 neon, 10 celestial, 11 pirate, 12 carnival. The coordinator must reorder
`catalog.json`, `economy.json` and `progression.md` (pirate is 5th there). `minigames.md` debut biomes and the
tournament unlock order are re-derived in phase 3 from the new order; no lead may use the old 5th-place Pirate.
Art-bible changes: a Pirate block row, Dune Bazaar dropped, section 5 rows for Lana, Boulder and Glim, and
(done 2026-10-14) section 1 pillar 3 and section 7 amended: a board sits in a level-specific terrain and the
floating island is one terrain among many.

**Decided by the user:** the story premise is "The Twelve Keystones" (Huffle, the baby cloud, topples the
Wizard's tower; logged in `campaign-redo-plan.md`), which is concept A below. **Open (anything marked "proposed"
is not decided):** (1) `tumble-fair.md` replaced by the 14-level Carnival biome; (2) comic peril in Lava and
Neon (proposed: comic, reversible, no hero shown hurt); (3) the plan task list needs a phase 3 task for the
uniqueness script.

## 1. Campaign fantasy

**Pitch:** a cosy tower-building puzzler where every island has a problem only a stack can fix, and the
world answers back.

You are the Wizard's trusted builder in a sky of twelve floating islands. You drop, turn and slot chunky
blocks. Each stack is an answer: a bridge a goat can cross, a wall that shelters the heroes, a lookout that
spots the ship. Stacking matters because in this world **built things hold the sky together**. A cleared
layer pays out something in the story: it charges a beacon, mends a floor or drains a flood.
Dame Ada, Bram and Sif are your party. Their perks (Stitch, Smash and Redraw, kept from the old design) are
proposed as tools you choose before a level, and they stand on stage reacting to what you build. **Every level
is a minigame** (ruling A): one clear goal in one verb, built on one or two mechanics, short and intense, in a
small diorama (a gully, a fort wall, a raft) with a landmark that acts and a cast that cheers. **No two levels
in an island share a footprint** (ruling B): you build on bridges, rings, stairs, ship decks and island chains,
not on one square. Minigame
modules are the island's own games, h1-h3 are the mastery epilogue, and stars are the Wizard's thanks. The
player feels clever, a bit mischievous, and rooted for: someone always cheers when a piece lands well.

## 2. Three pillars

**Level principle (ruling A): a level is a minigame.** It follows `minigame-party-rules.md`: one clear goal
taught in 3 seconds with one sentence of 12 words or fewer, short and intense, a themed meter, a story payoff,
standard controls plus at most one `extra_control` (shown as one gem button). It is built on 1-2 **mechanics** (rules
or modules), which are its base, and has one **verb** from the closed list: race, defend, build, destroy,
survive, rescue, balance, carry. The spec states mechanic and verb first (section 8); the board and scene
follow from them.

Each test scores 0 fail, 1 partial or 2 pass; a level passes at 2. Tests come in two sets.
- **Spec-time tests:** phases 2-3 apply P1a, P2a, P2c; phases 4-5 apply the full set P1a, P1b, P2a, P2b, P2c,
  P2d, P3b, P3c, P3e (every level whose set-piece action is a rule that removes or moves blocks), plus the
  `target_visible` field for P3a.
- **Build-time tests (phases 7-8), on the built level, JSON and screenshots:** all of the above plus P1c, P3a, P3d.

**P1. Every level is a scene, not a grid.** One place, one problem, one reason to stack, and the board lives
inside a diorama (user rule, refs 01 and 09-12, layout only).
- *P1a swap test (spec-time):* reskin the level into another biome. If it still makes sense, it fails. The
  story event, the set piece and the headline objective must be tied to this place.
- *P1b scene test (spec-time):* the spec names `scene.terrain` (the place the board sits in: plank bridge,
  fort wall, raft, mine shaft, conveyor deck, summit ledge; not "floating square"), `scene.set_piece_action`
  (what the landmark does during play: fires, grabs, moves, rises) and `scene.cast_on_stage` (who is posed and
  doing what). An empty required field, a decorative-only set piece or "the same floating island" scores 0.
  Terrain and action ids come from closed lists (U17). `scene.hud_meter` names the themed meter or says
  `no meter fits`; a blank field scores 0 (agrees with P2d).
- *P1c scene test (build-time):* on the start and mid screenshots at 720x1280, scene pixels (not board, not
  HUD, not plain sky gradient) are at least 60% of the board's pixel area, measured by a segmentation mask in
  the capture tool; the terrain, the cast and the set piece acting are each identifiable; and the active
  piece, the stack and the landing marker are never occluded by the scene.
- *Cosmetic or rule:* a `set_piece_action` is cosmetic unless it is one of the level's `mechanic` ids or an extra. Any
  action that moves, removes, blocks or scores blocks is a rule: it counts toward U10 and needs a handbook
  entry. Cosmetic actions never touch the board and have a static reduced-motion pose.

**P2. The stack is the answer, and never mundane.** The goal is something the player builds, protects or
reveals, and the world visibly changes when it is done.
- *P2a world change:* name the visible world change on win (every level, including bonus and minigame levels).
- *P2b drop change:* applies to `height`, `shape` and boss levels only. Name the rule or board shape that changes
  how pieces are dropped here. Level 01 of each biome is exempt (it teaches a rule and changes no drop).
- *P2c mundane test:* describe the level without a bare counter (U15). If it reads "do the generic thing in
  a different skin", it fails.
- *P2d minigame test (spec-time):* the spec names its 1-2 `mechanic` ids and one play `verb`; its tutorial
  sentence is 12 words or fewer; it has one clear goal, a themed meter or an explicit `no meter fits`, a story
  payoff and at most one `extra_control` (dash, fire or grab, or none). A level that is "a board with a rule
  pill" scores 0.

**P3. Cosy mischief, always fair.** Failure is funny and cheap, wins are generous, nothing is mean.
- *P3a opening clarity (build-time):* 5 first-time players; at least 4 say what to do first, from the start
  frame, within 10 seconds. The ending may change later (U16); the opening objective may not be hidden.
- *P3b comic fail (spec-time):* a lost attempt shows a comic reaction and restarts in 2 seconds or less.
- *P3c mechanic budget (spec-time):* the level adds at most one new mechanic (U10).
- *P3d winnable (build-time):* a solver (or a bot with unlimited time) wins at least 98% of 500 seeded runs;
  a loss counts against the level only if no legal winning line existed (otherwise it is a bot failure).
- *P3e strike telegraph (spec-time):* in every level whose `set_piece_action` is a rule that removes or moves
  blocks (any `strike` variant), each strike lane is warned by an actor (a rising tentacle, a cranking catapult
  arm) at least 2 s ahead, and at least 4 s in biomes of intensity 1-2. The spec's `telegraph` field says how.
- Peril (Lava, Neon) is comic and reversible. Every cue is shape plus colour plus sound; reduced motion is safe.

## 3. Emotional arc, stakes and ending

Intensity target 1-5 (tier 10 peak). **Stakes** say what is at risk if the island is not mended (always
reversible and gentle). **The Stakes column is proposed:** the narrative lead may change the wording (it
presupposes concept A) but not the escalation shape (intensity column, first reversal, Neon low).

| # | Biome | Role in the arc | Stakes | Int. | Player leaves feeling |
|---|---|---|---|---|---|
| 1 | Meadow | **Wonder and welcome.** Meet the Wizard and Ada. Teach by doing. | A picnic and a path | 2 | "I can do this, the world is kind" |
| 2 | Candy | **Mischief.** Sweet chaos, a prankster problem. | A town of sweets goes sticky | 3 | Delight, a giggle at a mess |
| 3 | Ice | **Hush and slide.** Quiet music, slippery floors, care for a hero. | A lost creature is cold | 2 | Calm awe, careful hands |
| 4 | Underwater | **Strange wonder.** Light from above, odd friends, a shy giant. | A reef loses its glow | 3 | Curiosity with a hint of unease |
| 5 | Lava | **Danger, the first reversal (chapter 5 of 12).** The team is truly in trouble. | The party is cut off | 5 | "We might lose this" |
| 6 | Forest | **Tangled warmth.** Shelter after heat; a secret; the cast bonds. | A home in the trees | 2 | Relief, belonging |
| 7 | Cave | **Trust in the dark.** Tight boards (narrow masks inside the 8x8 minimum box), one hero alone with you. | A lost light | 3 | Quiet courage |
| 8 | Clockwork | **Tension of precision.** A machine everyone is stuck in; ticking and tidy. | Time itself runs down | 4 | Focus, joy in order |
| 9 | Neon | **Low point.** Bright but empty; a setback the heroes face; lowest morale. | The party is split | 5 | Doubt turning to resolve |
| 10 | Celestial | **Awe and gathering.** Above the weather; everyone returns; stakes named. | The whole sky | 3 | Sublime calm, readiness |
| 11 | Pirate | **Swashbuckling swagger.** Rowdy rivals hold the last piece the party needs; the energy lift into the finale. | The last key and the way to the Fair | 4 | Cheeky, confident, ready to party |
| 12 | Carnival | **Triumph and release.** Every learned idea returns as a game. | The world holds, or sags | 5 | Joy, pride, "I built all this" |

Every biome has a tier-10 boss. The first reversal is Lava (chapter 5), the true midpoint is 6.5, and the Neon
low is chapter 9. Recovery takes three biomes with rising intensity (3, 4, 5): Celestial gathers the party in
quiet awe, Pirate lifts the mood and its tier-10 boss hands over the last key, the Carnival pays off.
Pirate must not reprise Underwater: its play is rowdy, rival-driven and ship-based.

**The ending (proposed, narrative lead owns detail).** The campaign ends on the Carnival tier-10 boss and its
bonus level, with an ending panel. h1-h3 are an optional epilogue and not the ending. Each hero has a stated
resolution beat in biomes 9-12, appears in at least 6 of the 12 chapters, and the Wizard has a flaw (kind,
forgetful, a bit vain) that is shown by biome 4, costs the party in biome 9 (Neon) and pays off in the finale.

## 4. Tone rules

**Voice.** Storybook-wacky: warm, silly, kind. Villains are mischievous or misunderstood. Nobody dies.
**Wordless in play:** everything during play is animation, sound and the set piece; no dialogue during a
drop, no text over the board. Intros and outros carry at most one short caption outside play.

**Text budget (live UI only, never baked into art).**
- Story caption: one sentence, 14 words or fewer, on a title ribbon over a painted panel. Ribbons are purple
  wood or gold plaques with cream caps text, never paper, scroll or parchment.
- Tutorial bubble: 12 words or fewer, shown once, dismissible, never over the grid.
- Level and boss names: 1-4 words, one pun at most (example: "Clover Circle", "Madame Meringue").
- No caption needs an earlier one. Story is optional and never gates progress.

**Humour.** Physical and visual: wobbling stacks, a hero bonking a door, a crab in a tiny hat. No sarcasm,
no mocking the player. Losing is a pratfall, not a shame.

**Hard rules.**
- No third-party IP of any kind, Nintendo included (characters, items, names, music, layouts). Boards 09-12 are
  layout only.
- No "Tetris" naming. Never copy the board logos ("TETRO PARTY DIMENSIONS", "WACKY PARTY", "PARTY QUEST");
  our logo is `logo_master.jpg`.
- **No board titles as names.** No level, boss, chapter, minigame or module name may equal or paraphrase a
  title on the reference boards (`assets/art/reference/index.md`) or in the `minigames.md` Naming fixes table
  (for example Bridge Bashers, Tumbling Towers, Fort Blast, Kraken Blockade, Molten Guardian, Maze Heist).
  A name-check script catches exact and near-match names against those two sources; reviewers catch
  paraphrases (N5, L1). pirate_03, 09, 10, h1, h2 and the `bridge_dash` title are renamed in phase 4.
- No beige or parchment UI: open purple-wood frames over a painted scene (board 05), plum glass planks.
- **Cast.** Recurring named characters: the Wizard (mascot); heroes Dame Ada = art-bible Knight (silver and
  red), Bram = Dwarf (ginger and steel), Sif = Elf (green and tan); NPCs Lana, Boulder and Glim (proposed
  species: Lana an alpaca and Boulder a hippo, from story-v2; Glim's is set by the narrative lead). They need
  art-bible section 5 rows (silhouette, colour key, prop) before phase 6. Pirates, robots, explorers and
  similar archetypes are unnamed one-offs.

## 5. "Every level unique" as testable rules

This extends `level-identity-spec.md` and keeps its rules except where marked superseded. Every level has five
facets, in spec order: **mechanic and verb** (the base), **story beat**, **way of playing** (unique triple plus
signature), **footprint and place** (board shape, terrain, set piece, time of day) and **look** (start-frame
silhouette).

**Definitions.**
- **Glossary (use these words everywhere).** A *rule* is an engine rule (for example `vines`, `strike`). A
  *module* is a minigame module (for example `gap_runner`, `wobble_plate`). A *mechanic* is a rule or a module.
  The *play verb* is one of the 8 (race, defend, build, destroy, survive, rescue, balance, carry), in the field
  `verb`. The *extra control* is the optional extra button (`dash`, `fire`, `grab`, or `none`), in the field
  `extra_control`; it is never called a verb.
- `mechanic`: a required spec field, 1-2 base ids from the roster (rules or modules); the first is the main
  one. `extras` may add rules already taught earlier (for example `gust`); they modify the base and are not
  bases themselves. Two mechanics are the same if their ids match, whatever the parameters. A parameterised
  family counts as one id plus a variant (`strike[tentacle]` and `strike[catapult]` are the same mechanic).
- **Canonical mask:** the board mask normalised under the 8 rotations and reflections; the smallest wins,
  ordered by width, then height, then the rows joined with `/` (with `#` < `.`), written `WxH:rows`. A
  **plain square** is a full rectangle with no holes and no notches, at any size.
- **Footprint:** a shape name from the closed list in `scene-vocabulary.md` (plain square, ring, bridge span,
  stair, island chain, ship hull, L, cross, crescent, twin towers, funnel, moat with a centre island, and
  others added by change request) plus its size, written `shape WxD` (for example `ring 10x10`).
- **The pill:** the rule list on the level card. **Beat id = level id** (`<biome>_01`..`_10`, `_bonus`, `_h1`-`_h3`).
- **Counter goal:** any goal whose only HUD readout is a bare number to reach or fill (rows, cells, seconds)
  with no story object.
- **Script check:** `tools/qa/check_level_uniqueness.gd`. Owner: tools-programmer. Built in **phase 3**, so it
  exists before phase 4 specs are written; the plan task list gets this task (size: 2 days). It reads the
  `level_table` that ends each biome plan and verifies U3, U5 (table mode), U6, U7, U12, U14, U15, U16, U17,
  U18, U19 and the name check. The 9.7 exemplars are included in the checks. It reports observations; reviewers
  score. `level_table` is a Markdown table with the columns `id`, `mechanic` (1-2 ids), `verb`,
  `extra_control`, `goal_type` (a list in play order, e.g. `span>survive`), `footprint` (`shape WxD`), `mask` (canonical string), `terrain`,
  `set_piece`, `set_piece_action`, `cast_pose`, `time_of_day`, `weather`, `camera`, `opening_event`,
  `ending_pattern`, `headline_objective`, `role`, `callback_of`, `flavour` (`D1`-`D4` or `none`), `telegraph`
  (seconds, or `n/a`), and the computed `min_spawn_width` and `min_dead_end_width`.

**Rules.**
- **U1 Beat first.** Every spec starts from its beat id and has a reason to stack.
- **U2 Swap test.** The beat, headline objective and set piece cannot move to another biome unchanged (P1a).
- **U3 Unique triple.** `(goal_type list, mechanic list, canonical_mask)` is unique across the 168 levels (the
  full lists are compared, so `span>survive` differs from `span`). Hard remixes
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
- **U7 Feel spread.** Per biome: at least 6 distinct goal types, **at most 1 plain square** (ruling B; this
  supersedes the identity spec's "at most 4"), at least 3 levels with a non-default camera, and **1 or 2
  defence levels** (`flavour` D1-D4, counted by the script). **No `clear_n` headline goals (U15)**; this
  supersedes the identity spec's "at most 5 `clear_n` levels". **Corridor width** (a mask property, computed
  by the phase 4 script into `min_spawn_width` and `min_dead_end_width`): the *spawn region* is the floor
  cells of the top 3 mask rows across the spawn columns and must offer a landing area at least 4 wide (a piece
  that spawns flat needs 4). Pieces spawn in the **centre 4 columns of the mask's bounding width** (for odd
  widths, the 4 columns starting one left of centre) unless the spec sets `spawn_cols`; a level whose spawn
  columns hold void in the top 3 rows must set `spawn_cols` to a floor run at least 4 wide. A *dead-end
  channel* is a void-bounded vertical run of floor open at one end only, and must be at least 3 wide (a 3-cell
  piece cannot rotate inside a 2-wide shaft). **For every shape in the vocabulary** (plain square, ring, bridge
  span, stair, island chain, ship hull, L, cross, crescent, twin towers, funnel, moat with a centre island, and
  any later addition): every band, arm, tread, tower, link or leg is at least 4 wide at the spawn rows and at
  least 3 wide elsewhere. The script reports the computed widths. Phase 3 restates the minimums if the piece set
  changes them.
- **U8 Opening event.** One distinct `opening_event` id per level (same field as the beat's). **Phase 2 assigns
  and lists the ids** (the narrative lead); phase 4 may refine them under the same rule: none repeats within
  a biome and none appears in more than 2 biomes, so phase 2 plans for at least 84 distinct ids.
- **U9 Boss finale.** Every tier-10 level is a phased boss (Neon included; the `progression.md` no-boss
  finale is withdrawn), tied to its chapter villain, changing the arena once or more, beaten by building.
- **U10 Mechanic budget.** A level adds at most one new mechanic (a rule-like set-piece action counts). Levels
  01-03 show two mechanics only if one was taught in an earlier biome. **A biome adds at most 2 new rules plus
  at most 2 module debuts** (biome 1 may teach 3 rules plus 2 modules if the handbook's verb map reaches 5
  verbs there). Each mechanic serves **at least 3 verbs** in the handbook's verb map, so a biome with 4
  mechanics can cover 5 verbs (U19). **Campaign totals** for phase 3 to check against 168 levels: up to 25
  rules (2 per biome, biome 1 up to 3) plus the 16 modules, each debuting once. A mechanic is taught alone
  before it combines. **Shared defence rules:** attacker variants (cannon, tentacle,
  rock, catapult, comet) are one parameterised rule `strike`, and complete-row ammo is one rule `row_cannon`;
  each is taught once, in the first biome that uses it, and reused later with a new attacker and scene (a
  variant is not a new rule). `breach_plug` (D2) is the one extra defence rule. Defence rules take at most 1 of
  a biome's 2 new rules.
- **U11 World change.** The clear changes the scene (a lit lamp, a crossed bridge); failure is a comic reaction.
- **U12 No cookie-cutter slots.** For tiers 01-09 and 11, the same tier number may not share a goal type in
  more than 4 of 12 biomes. Tier 10 is exempt (U9). Instead the 12 bosses differ in arena mask, phase count and
  the building action that damages them (the "boss triple"; actions come from a closed list in the handbook,
  for example wall, ramp, bridge, bait, cage, pillar), and no two bosses share all three.
- **U13 Echoes** need a story reason, are marked `callback_of`, and still obey U3.
- **U14 Look fingerprint.** `(canonical_mask, terrain, set_piece, time_of_day, weather)` is unique per level
  across the campaign; within a biome no `set_piece` repeats more than twice and no `canonical_mask` repeats.
- **U15 No counter goals.** No level's headline goal is `clear_n` or any counter goal (defined above).
  `height`, `shape`, `survive` and the other goals are legal only when the HUD names a story object (the
  lookout, the dam, the cloud) and the number is secondary. `clear_n` is a means only (it charges, bonks,
  drains). Each spec records `headline_objective` (story wording, 8 words or fewer) that contains a noun from
  the beat and no bare numeral.
- **U16 Surprise quota.** At least 4 of the 14 levels in each biome use an `ending_pattern` other than `plain`
  (twist, reveal, guest, secret, story). **At least 3 of those 4 must be twist, reveal or guest** (the end
  is not predictable from frame 0); secret and story may fill only the 4th slot. No pattern is used more than
  twice per biome. `ending_pattern` is written to `metadata.ending` in the JSON. Each is telegraphed, fair,
  comic on failure and keeps a clear opening objective; tier 10 and level 01 may not hide their goal. P1 and
  P3a demand a clear opening problem; U16 lets the ending change after it. Secret endings are optional.
- **U17 Scene spread.** `scene.terrain`, `scene.set_piece_action` and `cast_pose` take ids from the closed
  lists in `design/levels/plans/scene-vocabulary.md` (owner: technical artist). **Ids are global**: one list of
  about 20-30 terrain ids and 20-30 action ids, and an id may appear in several biomes, each time as a
  biome-skinned build. Phase 3 seeds the lists from the roster and the exemplars; phase 4 groups add ids only
  by change request that the artist approves before the `level_table` is checked. A spec using an id not on
  the list fails the U17 script. Per biome: 7-8 distinct terrain ids and 7-8 distinct action ids, none used
  more than twice; across the campaign no `(terrain, set_piece_action)` pair repeats. The art budget counts
  **builds** (7-8 terrain builds and 7-8 acting set-piece builds per biome, 84-96 each in total); the
  vocabulary counts ids. `cast_pose` verbs are build, haul, cheer, hide, brace, point, plus `react` for animals
  and props; a biome uses at least 4. Exemplars teach **form, not content**: no level may reuse an
  exemplar's set piece, terrain, mask, ending or character. The 9.7 exemplars are included in the U3, U14, U17,
  U18 and U19 checks; the `ex_near_*` and `ex_weak_*` samples are excluded and exist only for human scoring.
- **U18 Footprint spread (ruling B).** No two levels in a biome share a footprint: each has its own shape or its
  own size (`shape WxD` unique per biome, and the U5 IoU threshold holds). A plain square is allowed at most
  once per biome. Biomes use at least 8 different shape names between them across the 14 levels, and a hard
  remix changes the footprint of its source. A mask matches exactly one recogniser (priority order in
  `scene-vocabulary.md`), so one mask cannot count as two shape names.
- **U19 Verb spread (ruling A).** Each biome uses at least 5 of the 8 verbs, and the same verb never appears in
  more than 2 levels in a row (in level order 01-10, bonus, h1-h3). The script checks both.

## 6. Brief for the narrative lead (phase 2)

**Outputs:** `design/narrative/campaign-story.md` and `design/narrative/beats/<biome>.md`. Each beat file has
one YAML front-matter block per beat: `id` (= level id), `role`, `place`, `who`, `problem`, `why_stack`,
`headline_objective`, `verb` (proposed, from the closed list of 8), `ending_pattern`, `world_change`,
`wordless_moment`, `opening_event`, `caption` (optional, 14 words or fewer). Field limits: one sentence each,
20 words or fewer. Each biome's 14 beats cover at least 5 of the 8 verbs and never repeat a verb more than twice
in a row (U19).

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
   h1-h3 remixes). The narrative lead writes situations and proposes a verb; **the systems designer owns the
   mapping from function to mechanic** and may change a verb with a stated reason. Every beat must be playable as
   a minigame (ruling A): one goal a child can state in one sentence.
6. At least 4 beats per biome carry a non-plain `ending_pattern`, at least 3 of them twist, reveal or guest
   (U16), and none is a counter goal (U15). **This phase assigns the `opening_event` ids** (U8, 84+ distinct).
7. A story that survives as 12 chapter captions plus level names; all names pass the board-title ban.
8. Resolve the `tumble-fair.md` conflict (proposed: the 14-level Carnival biome replaces the side island).
9. Freshness: borrow nothing from old level names or story-v2 beats.

**Three candidate high concepts** (the user chose the premise "The Twelve Keystones", i.e. A; B and C remain
as sources of ideas):
- **A. "The Wobbling World."** The Wizard's sneeze topples the Great Tower that pins the islands, scattering
  twelve Keystones; each island sags or drifts and the trio rebuilds it. *A cosy island-hopper, and also the
  world is held up by what you build.* Strength: stacking is the plot. Risk: a generic accident; the Wizard
  needs a real flaw.
- **B. "The Grand Tumble Fair."** The Wizard invites everyone to a once-a-century Fair; the heroes win a
  ticket-stub on each island, then find the host is secretly lonely. *A trip across twelve biomes, and also
  every island is a game at the Fair.* Strength: party tone, natural climax. Risk: a thin villain, errands.
- **C. "The Lamplighters' Road."** The sky is dim because twelve beacons are out; the heroes light each by
  building a base tall enough to reach the light line. *A stacking puzzler, and also a quest to bring the
  light back.* Strength: a visual payoff per win. Risk: an item quest; the Neon low needs a reason.

**Chosen: A.** It makes P2 the plot, gives each biome a simple problem and earns the Carnival payoff. The
narrative lead may borrow C's beacon-light as a win reward.

## 7. Brief for the systems designer (phase 3)

**Outputs:** `design/levels/plans/mechanics-handbook.md`, `mechanics-roster.md` and `progression.md` v2
(in the biome order above), plus the uniqueness script (tools-programmer, section 5).
- **Handbook (owner: systems designer; phase 3; written before any art or code):** a plain-words entry for
  every rule and goal a player meets: what it does, how it reads, a worked example, what it never does, its
  debut level. No engine terms.

1. **Mechanics are the base of each level (ruling A).** Assign every level 1-2 mechanics and one verb from
   the closed list; one mechanic family per biome from its chapter's problem. Every level obeys
   `minigame-party-rules.md` (one clear goal, 12-word tutorial sentence, themed meter, story payoff, standard
   controls plus at most one `extra_control`). Reuse existing rules where they fit. **Engine gaps**, each with
   an owner and a size in days (estimates; phase 3 confirms and the producer totals them against the phase 6
   buffer before phase 4 starts):

   | Gap | Owner | Days |
   |---|---|---|
   | Boss phases (arena change per phase) | gameplay-programmer | 4 |
   | Goal phases (a goal list in play order) | gameplay-programmer | 3 |
   | Hidden or revealed goals | gameplay-programmer | 2 |
   | Ending events (twist, reveal, guest, secret, story) | gameplay-programmer | 2 |
   | Story-objective HUD text (per-level wording) | ui-programmer | 1 |
   | Minigame phase runner (module phases inside levels) | gameplay-programmer | 5 |
   | Shape overlay (target cells shown from frame 0) | technical-artist | 3 |
   | Scene kit: terrain modules, cast poses, acting set-piece actors, themed HUD meters (see 7.5) | technical-artist | about 40 |
   | `spawn_cols` support | gameplay-programmer | 1 |
   | `strike` family, variants and telegraph actors | gameplay-programmer plus technical-artist | 4 |
   | `row_cannon` | gameplay-programmer | 2 |
   | `breach_plug` and the `seal_breaches` goal | gameplay-programmer | 3 |
   | Per-level tutorial preview and 12-word line UI | ui-programmer | 2 |
   | Shape recognisers (inside the uniqueness script) | tools-programmer | 2 |
   | P1c segmentation-mask capture tool | tools-programmer | 2 |
   | P3d solver | gameplay-programmer | 5 |

   The sum is about 81 days, of which the 21 days for the last eight rows are ruling A/B items.
2. **Teach, twist, combine.** A biome adds at most 2 new rules plus 2 module debuts (U10), each mechanic taught
   alone. Include a cross-biome dependency graph and the campaign totals check (up to 25 rules plus 16 modules
   cover 168 levels with unique `(goal list, mechanic list, mask)` triples). The systems designer owns the
   function-to-mechanic mapping for the narrative beats.
3. **Goal vocabulary as story objectives.** Define every goal's HUD wording; `goal_type` is a list in play
   order for goal phases (U3 compares the whole list). Allowed goals: `height`, `shape`,
   `survive`, `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven`, the new `seal_breaches` and
   the minigame goals. `clear_n` is a means only (U15). **Defence mapping:** D1 = `survive`, D2 =
   `seal_breaches`, D3 = `bonk_boss`, D4 = `rescue_all` inside a goal sequence. The shared rules are `strike`
   (parameterised by attacker variant) and `row_cannon`, each taught once and reused, plus `breach_plug` for
   D2; defence takes at most 1 of a biome's 2 new rules (U10). All need handbook entries. Define the
   ending patterns as engine features (goal phases, reveal, guest, secret). **Verb map:** the handbook lists
   which play verbs each mechanic serves (race, defend, build, destroy, survive, rescue, balance, carry), and
   **each mechanic serves at least 3 verbs**, so the U19 quota (5 of 8 verbs per biome) is reachable.
4. **Minigames.** Follow `design/levels/plans/minigame-party-rules.md` (short and intense, taught in 3
   seconds, standard controls plus one `extra_control`, built on stacking, a scene not a grid, fair shared
   seeds). The 16 modules each have a debut, a recall, the motivating beat and a tournament use; at most 2
   module debuts per biome, re-derived for the new biome order; define the phase runner contract.
5. **Scene kit budget.** Price in the engine-gap list, each with owner and size, counting biome-skinned
   builds (U17): terrain builds (7-8 per biome, 84-96 total), cast poses (6 verbs for each of the three heroes
   and the Wizard, made once and reused), acting set-piece builds (84-96, each a looping 2-4 second
   animation with a static reduced-motion pose) and 4-6 themed HUD meters. The producer reports the total against the phase 6 buffer before phase 4 starts.
6. **Bosses.** Twelve tier-10 bosses with distinct boss triples (U12), arena changes per phase, beaten by
   building. A boss adds no new mechanic: it combines mechanics already taught in tiers 03-09. An *idea* is a
   variant of a mechanic already taught (a second lane, a higher speed, a new target), and each phase adds at most one.
   **Defence flavour:** `reference-study-defence.md` D1-D4 (hold the wall, plug the breach, shield and strike,
   shelter the guest) is one level flavour among many: **each biome has at least 1 and at most 2 full defence
   levels** (U7; the `flavour` column; the script counts them). A D3 level names its boss in the headline,
   never a row count (rows are ammo). An attacker's set-piece action that removes blocks is a `strike`
   variant: a rule, never cosmetic, with a telegraph (P3e). The idea names in `reference-study-defence.md` are working titles only; every real
   name passes the title script and the paraphrase check (N5, L1).
7. **Hero perks.** How Stitch, Smash and Redraw work as pre-level tools (proposed: Ada Stitch, Bram Smash, Sif
   Redraw) and how they interact with each biome's rules.
8. **Difficulty and unlocks.** Formulas for `g0`, goal size and stars by tier and biome index: `g0` rises within
   and across biomes, the hard track beats tier 10, finales are not easier than tiers 07-09. Keep the 15 of 30
   star gate (stars in the biome needed to open the next) unless argued.
9. **Fairness.** No `fixed_list`; opening sets at each level 01; spawn safety; soft-lock warning; `meadow_01`
   winnable in under two minutes.

## 8. Brief for the level design lead (phase 4)

**Outputs:** `design/levels/plans/<biome>.md` v2 for all 12 biomes (4 groups of 3), each ending with the
machine-readable `level_table` for the script check. Set pieces: 7-8 per biome, 84-96 in total; the technical
artist owns `assets/data/set_pieces.json` and flags art cost per piece (the file does not exist yet).
1. **Start from the mechanic and verb (ruling A), then the beat.** Each spec opens with `mechanic` (1-2 ids,
   each linked to its handbook entry) and `verb`, then its beat id (= level id) and the one-sentence tutorial
   line (12 words or fewer). The board and scene come after.
2. **Required fields per level, in this order:** `mechanic`, `verb`, `extra_control`, `id`, `tutorial_line`, `headline_objective`,
   `goal_type` (a list in play order), goal parameters `n` (phase 3 formula), `target_visible` (yes or no, with
   where), `ending_pattern` (written to `metadata.ending`), `metadata.signature`, **`footprint` (`shape WxD`)**
   and the board mask (ASCII: `#` floor, `.` void) with `spawn_cols` (default: the centre 4 columns),
   `flavour` (D1-D4 or none), `telegraph` (seconds, for any `strike` level), minigame block, full `look`
   block, **`scene.terrain`, `scene.set_piece_action` (cosmetic or rule), `scene.cast_on_stage` with
   `cast_pose` and `scene.hud_meter` (a themed meter or `no meter fits`)**, `g0` and stars from the phase 3 formula, role,
   `opening_event`, world change on win, comic fail reaction, `callback_of` if any.
3. **Prove uniqueness.** The `level_table` passes the script check (U3, U14, U18, U19 and the rest); group
   leads check cross-biome U3 and U14. A biome has at most one plain square; every other footprint is a named
   shape or its own size.
4. **Readability.** Targets are visible from frame 0 at 720x1280 (`target_visible`); the active piece differs
   from the stack; the landing marker is high contrast. Flag engine needs.
5. Level 01 has at most one mechanic, an opening set and a gentle `g0`. The bonus is a relaxed set piece. Hard
   levels are remixes under U3 with a new look. Specs only; no JSON edits in this phase.

## 9. The 9.7 review rubrics

**Scoring.** One decimal, never rounded up. **A phase passes only if every criterion is at least 9.7.**
Anchors: 10 = no change you would request; 9.7 = wording or tuning notes only, no structural change; 9.6 or
lower = a structural fix is needed. Reviewers list ranked defects with owner and fix; makers fix.
- **Preconditions.** QA runs the scripts (U3, U5, U6, U7, U12, U14, U15, U16, U17, U18, U19, the name check) before human
  scoring; the reviewer applies the cap: a script failure caps the matching criterion at 8.0.
- **Coverage.** Read every beat and spec of one biome in full and at least 5 levels of every other biome
  (across teach, boss and hard roles); cite at least 10 level ids per criterion.
- **Calibration.** The **game director** writes the anchors in `design/levels/plans/exemplars.md`: a 9.7
  beat and spec, a near-miss (about 9.0), weak samples (8 or below) for beat, spec and handbook entry, boss,
  hard-remix and level-01 specs, and 9.0 vs 9.7 one-liners for A, C and S. The panel scores them before reviewing the rest. Makers do not write their own anchors. Fields
  derived from phase 3 formulas (`g0`, stars, `n`) are exempt in exemplars.
- **Pillars.** Phases 2-3 apply P1a, P2a, P2c; phases 4-5 apply the spec-time set (section 2) to 5 sampled
  levels; phases 7-8 apply all tests.
- **Caps.** A level with no mechanic or verb, or that fails P2d, caps M1, M3 and L3 at 8.0; a biome with a
  repeated footprint or more than one plain square caps L6 and A1 at 8.0 (ruling B: a grid of squares is a 3,
  not a 9). A mundane or counter-based level caps N4, M3 and L3 at 8.0; a spec with an empty required `scene`
  field (terrain, set_piece_action, cast_on_stage) caps L6 at 8.0; a built level that is only a grid on a
  floating square caps A-build and C5 at 8.0.
- **Mark each thing for what it is (user ruling; `reference-quality-bar.md`, "Three blind experts per
  review").** Every review is done by three blind, fresh experts in that field (level and campaign plans: level
  designer, game designer, systems designer), who do not see each other's scores or earlier rounds.
  - **Plan gates (phases 1-5)** score the document as a plan: clear, complete, testable, consistent, buildable.
    No paper-only cap and no screenshot ceiling applies. L6, A1 and A-spec score the rules, fields and
    recogniser results, and are not held down by the state of the current build.
  - **Build gates (phases 7-8)** score the build from retained captures against the reference boards. The
    paper-only cap and the screenshot ceiling apply only here: no item scores above what the screenshots show,
    and while a built biome has more than one plain square or any two levels with the same footprint, A-build and
    C4 for that biome are capped at 3 (ruling B).
  - **No borrowed credit.** A plan may not claim visual or feel qualities the build does not show yet. Its
    scene-variety and feel statements are worded as requirements ("each level must..."), and a reviewer scores
    the build, not the plan, on whether the game looks varied.
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
- M1 Story-to-mechanic fit (every level is a minigame on 1-2 mechanics and one verb). M2 Teach and combine
  (budget, dependency graph, shared `strike` and `row_cannon`).
- M3 Variety and quotas (goal set, at least 5 of 8 verbs per biome, boss triples, minigame debuts; no mundane or
  counter goals; surprise endings specified as engine features). M4 Difficulty math. M5 Fairness and feel (98% winnable, boss by building).
- M6 Buildability (engine gaps with owner and size). **M7 Handbook:** every rule and goal has a plain-words
  entry (what it does, how it reads, worked example, what it never does, debut level); no engine terms.

**L (phase 4, level specs)**
- L1 Beat fidelity (names pass the title script). L2 Uniqueness (U1-U19 and the scripts).
- L3 Gameplay variety (mechanic and verb first, verb spread, no mundane or counter-based levels, at least 4
  surprise endings per biome).
- L4 Curve and pacing. L5 Readability and fairness. L6 Look, scene and art direction (footprint variety U18,
  fingerprint, U17 scene spread, set pieces, palette, no beige). L7 Completeness (all fields, handbook links, `level_table`).

**A-spec (phase 5, art on paper).** 9.7 means each item is met for all 168 levels with no structural fix.
A1 every `look` block, `scene` kit item (terrain, acting set piece, posed cast, HUD meter) and set-piece spec
is complete and art-costed within the scene-kit budget; A3 cast rows (silhouette, colour key, prop) exist for
all recurring characters; A7 the art-bible amendments and the closed terrain and action lists are approved.

**A-build (phase 8, built art).** A2 palette and block skins incl. Pirate match boards 13 and 15; A4 reference
parity; A5 no beige or parchment anywhere; A6 reduced motion keeps every cue readable (static poses).

**B (phase 6, build).** 9.7 means zero failures and no workaround. B1 verifier 0 failures; B2 boots
(`ui_flow_smoke`); B3 every JSON matches its spec and `level_table` row; B4 boss phases, goal phases and
reveals behave as the handbook says; B5 CI green, no `fixed_list`.

**C (phases 7-8, captures).** 9.7 means every level has retained evidence and none is a near-duplicate.
C1 start, mid, clear and end screenshots per level in `production/qa/evidence/campaign-v2/`; C2 U5 and U14
hold on real frames; C3 targets visible at 720x1280; C4 contact sheets show 12 clearly different biomes;
C5 all pillar tests (including P1c) hold in play.

**S (phase 8, sound).** 9.7 means every item is audible and mixed without a clash. S1 every action has
feedback; S2 a music theme per biome following the arc; S3 boss and ending cues; S4 a comic fail sound; S5 a
clear mix with cues redundant in shape, colour and sound.
