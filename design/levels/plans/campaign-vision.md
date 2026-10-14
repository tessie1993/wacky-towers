# Campaign vision: Wacky Towers (phase 1 brief, revision 2)

Author: studio game director. 2026-10-14. Revised after `production/qa/quality-review/2026-10-14-plan-vision.md`.
Inputs: the redo plan, quality bar, art bible, reference boards, `catalog.json`, `progression.md`,
`minigames.md`, `level-identity-spec.md` (including its later user rules), the 4.8/10 level review (source of
the "tier 05 is `build_race` + height in 11 of 12 biomes" figure) and the level playtest.
User words: "all levels look the same", "different in game play", "narrative first", "pass grade must be 9.7",
"never clear so many layers", "level end must not be obvious from the start sometimes", "so mundane".
Decisions in force: 168 levels (12 biomes x 14); a FRESH story keeping only the cast; a plain-words
mechanics handbook is written before any art or code (plan decisions log).

**Biome order is catalog order:** 1 meadow, 2 candy, 3 ice, 4 underwater, 5 pirate, 6 lava, 7 forest, 8 cave,
9 clockwork, 10 neon, 11 celestial, 12 carnival. Pirate was the 11th biome *added* (the user's word, and the
plan's wording) but plays 5th. Dune Bazaar is dropped from the art bible's 12. Needed art-bible changes: a
Pirate block row (user decision), removal of Dune Bazaar, and section 5 rows for Lana, Boulder and Glim.

**Open decisions for the user (everything marked "proposed" below is not decided):**
(1) concept A is only a recommendation; (2) `tumble-fair.md` is replaced by the 14-level Carnival biome
(proposed; phase 2 resolves it); (3) how scary is comic peril in Lava and Neon (proposed: always comic and
reversible, a hero is never shown hurt); (4) the plan acceptance line "at most 5 `clear_n` goals" is
superseded by U15 (the coordinator updates the plan).

## 1. Campaign fantasy

**Pitch:** a cosy tower-building puzzler where every island has a problem only a stack can fix, and the
world answers back.

You are the Wizard's trusted builder in a sky of twelve floating islands. You drop, turn and slot chunky
blocks. Each stack is an answer: a bridge a goat can cross, a wall that shelters the heroes, a lookout that
spots the ship. Stacking matters because in this world **built things hold the sky together**. Clearing a
layer is a cheer and a pay-out: it charges, mends or drains something in the story, never just a counter.
Dame Ada, Bram and Sif are your party: their perks (Stitch, Smash and Redraw, kept from the old design) are
tools you choose before a level, and they react in the scene to what you build. Minigame blocks are the
island's own games, the hard track (h1-h3) is the mastery epilogue, and stars are the Wizard's thanks. The
player feels clever, a bit mischievous, and rooted for: someone always cheers when a piece lands well.

## 2. Three pillars

A pillar test runs on a level's **spec in phases 4-5** (the section 8 fields) and on its **JSON plus start and
clear screenshots in phases 7-8**. Each test scores 0 fail, 1 partial or 2 pass; a level passes at 2.

**P1. Every level is a scene, not a stage.** One place, one problem, one reason to stack.
- *P1 swap test:* reskin the level into another biome. If it still makes sense, it fails. The story event,
  the set piece and the headline objective must be tied to this place.

**P2. The stack is the answer, and never mundane.** The goal is something the player builds, protects or
reveals, and the world visibly changes when it is done.
- *P2a world change:* name the visible world change on win (every level, including bonus and minigame levels).
- *P2b drop change:* applies to `height`, `shape` and boss levels only. Name the rule or board shape that changes
  how pieces are dropped here.
- *P2c mundane test:* describe the level without the words clear, fill or reach N. If it reads "do the generic
  thing in a different skin", it fails.

**P3. Cosy mischief, always fair.** Failure is funny and cheap, wins are generous, nothing is mean.
- *P3a opening clarity:* 5 first-time players; at least 4 say what to do first, from the start frame, within 10
  seconds. The ending may change later (U16); the opening objective may not be hidden.
- *P3b comic fail:* a lost attempt shows a comic reaction and restarts in 2 seconds or less.
- *P3c rule budget:* the level adds at most one new rule (U10).
- *P3d winnable:* at least 98% of 500 seeded bot runs of the level are winnable (no unwinnable piece runs).
- Peril (Lava, Neon) is comic and reversible. Accessibility: every cue is shape plus colour plus sound, and the
  level reads with reduced motion on.

## 3. Emotional arc, stakes and ending

Intensity target 1-5 (tier 10 peak). **Stakes** say what is at risk if the island is not mended (always
reversible and gentle).

| # | Biome | Role in the arc | Stakes | Int. | Player leaves feeling |
|---|---|---|---|---|---|
| 1 | Meadow | **Wonder and welcome.** Meet the Wizard and Ada. Teach by doing. | A picnic and a path | 2 | "I can do this, the world is kind" |
| 2 | Candy | **Mischief.** Sweet chaos, a prankster problem. | A town of sweets goes sticky | 3 | Delight, a giggle at a mess |
| 3 | Ice | **Hush and slide.** Quiet music, slippery floors, care for a hero. | A lost creature is cold | 2 | Calm awe, careful hands |
| 4 | Underwater | **Strange wonder.** Light from above, odd friends, a shy giant. | A reef loses its glow | 3 | Curiosity with a hint of unease |
| 5 | Pirate | **Swagger and cheek.** Loud, rowdy rivals; an energy lift. | Treasure and a ship's pride | 3 | Cheeky confidence |
| 6 | Lava | **Danger, the midpoint reversal.** The team is truly in trouble. | The party is cut off | 5 | "We might lose this" |
| 7 | Forest | **Tangled warmth.** Shelter after heat; a secret; the cast bonds. | A home in the trees | 2 | Relief, belonging |
| 8 | Cave | **Trust in the dark.** Tight boards (narrow masks inside the 8x8 minimum box), one hero alone with you. | A lost light | 3 | Quiet courage |
| 9 | Clockwork | **Tension of precision.** A machine everyone is stuck in; ticking and tidy. | Time itself runs down | 4 | Focus, joy in order |
| 10 | Neon | **Low point.** Bright but empty; a setback the heroes face; lowest morale. | The party is split | 5 | Doubt turning to resolve |
| 11 | Celestial | **Awe and gathering.** Above the weather; everyone returns; stakes named. | The whole sky | 4 | Sublime calm, readiness |
| 12 | Carnival | **Triumph and release.** Every learned idea returns as a game. | The world holds, or sags | 5 | Joy, pride, "I built all this" |

Every biome has a tier-10 boss (the first is in Candy; "first real boss" is retired). Recovery from the Neon
low takes two biomes (11 and 12) by design; Celestial is the quiet before the finale.

**The ending (proposed, narrative lead owns detail).** The campaign ends on the Carnival tier-10 boss and its
bonus level, with an ending panel. h1-h3 are an optional epilogue and not the ending. Each hero has a stated
resolution beat in biomes 10-12, appears in at least 6 of the 12 chapters, and the Wizard has a flaw (kind,
forgetful, a bit vain) with a payoff in the finale.

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
  A name-check script compares every name to those two sources. pirate_03, 09, 10, h1, h2 and the
  `bridge_dash` title are renamed in phase 4. The art bible and plan quote board names as references only.
- No beige or parchment UI: open purple-wood frames over a painted scene (board 05), plum glass planks.
- **Cast.** Recurring named characters: the Wizard (mascot); heroes Dame Ada = art-bible Knight (silver and
  red), Bram = Dwarf (ginger and steel), Sif = Elf (green and tan); NPCs Lana (alpaca), Boulder (hippo) and
  Glim (species set by the narrative lead; story-v2 gives none). Lana, Boulder and Glim need art-bible section
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
- **Script check:** `tools/qa/check_level_uniqueness.gd` (owner: qa tooling, built in phase 4) reads the
  machine-readable `level_table` block that ends each biome plan and verifies U3, U6, U7, U12, U14, U15, U16
  and the name check. It reports observations; reviewers score.

**Rules.**
- **U1 Beat first.** Every spec starts from its beat id and has a reason to stack.
- **U2 Swap test.** The beat, headline objective and set piece cannot move to another biome unchanged (P1).
- **U3 Unique triple.** `(goal_type, main_rule, canonical_mask)` is unique across the 168 levels. Hard remixes
  and `callback_of` levels are not exempt: a remix changes at least one element of the triple and also differs in
  `set_piece` or `time_of_day` from its source.
- **U4 Signature** is a story sentence of 4-14 words naming the event or place, not the rules.
- **U5 Squint test.** A script computes the pairwise silhouette distance of start frames (mask plus set piece
  only, HUD and skin removed) and rejects pairs under a threshold set in phase 5; the reviewer hand-checks 12
  random pairs per biome and none may be confused.
- **U6 Look spread.** Within a biome no two consecutive levels share `time_of_day` + `set_piece`; at least 3 of 5
  `time_of_day` values (night biomes such as Celestial and Neon may use 2 plus dawn or dusk); at least 3
  `weather` values; 5-8 set pieces.
- **U7 Feel spread.** Per biome: at least 6 distinct goal types, at least 8 distinct canonical masks, at most 4
  plain squares, at least 3 levels with a non-default camera. **No `clear_n` headline goals (U15)**; this
  supersedes the identity spec's "at most 5 `clear_n` levels".
- **U8 Opening event.** One distinct `opening_event` id per level (same field as the beat's). Phase 4 lists the
  ids: none repeats within a biome and none appears in more than 2 biomes.
- **U9 Boss finale.** Every tier-10 level is a phased boss (all 12 biomes, Neon included; the `progression.md`
  no-boss "show" finale is withdrawn), tied to its chapter villain, changing the arena at least once, and beaten
  by building.
- **U10 Rule budget.** A level adds at most one new rule. Levels 01-03 show two rules on the pill only if one
  was taught in an earlier biome. A biome adds at most 2 new rules. A rule is taught alone before it combines.
- **U11 World change.** The clear changes the scene (a lit lamp, a crossed bridge); failure is a comic reaction.
- **U12 No cookie-cutter slots.** For tiers 01-09 and 11, the same tier number may not share a goal type in
  more than 4 of 12 biomes. Tier 10 is exempt (U9). Instead the 12 bosses differ in arena mask, phase count and
  the building action that damages them (the "boss triple"), and no two bosses share all three.
- **U13 Echoes** are allowed only as a deliberate callback with a story reason, marked `callback_of`, and still
  obey U3.
- **U14 Look fingerprint.** `(canonical_mask, set_piece, time_of_day, weather)` is unique per level across the
  campaign; within a biome no `set_piece` repeats more than twice and no `canonical_mask` repeats.
- **U15 No counter goals.** No level's headline goal is `clear_n` or any fill-a-counter goal. The HUD shows a
  story objective (for example "Reach the lookout"), never "Clear N layers". `clear_n` is a means only (it
  charges, bonks, drains). Each spec records the objective in `headline_objective` (story wording, 8 words or
  fewer).
- **U16 Surprise quota.** At least 4 of the 14 levels in each biome use an ending pattern (twist, reveal,
  guest, secret, story), recorded in the required field `ending_pattern` (plain otherwise). No pattern is used
  more than twice per biome. Each one is telegraphed, fair, carries a comic fail reaction and keeps a clear
  opening objective. Tier 10 and level 01 may not hide their goal. **Reconciliation:** P1 and P3a demand a clear
  opening problem; U16 allows the ending to change after it. Secret endings are optional extras, never required.

## 6. Brief for the narrative lead (phase 2)

**Outputs:** `design/narrative/campaign-story.md` and `design/narrative/beats/<biome>.md`. Each beat file has
one YAML front-matter block per beat: `id` (= level id), `role`, `place`, `who`, `problem`, `why_stack`,
`headline_objective`, `ending_pattern`, `world_change`, `wordless_moment`, `opening_event`, `caption`
(optional, 14 words or fewer). Field limits: one sentence each, 20 words or fewer.

**The fresh story must achieve:**
1. One through-line a child can retell in two sentences, with a reason to travel island 1 to 12 in catalog order.
2. Stacking is canon: say why building holds the world together.
3. Twelve chapters, each with a problem, a local ally or villain, and the section 3 role and stakes. Pirate is a
   chapter of its own, not Underwater's twin. Every biome has a boss face.
4. The cast earns its place: hero arcs and resolutions in biomes 10-12, each hero in 6+ chapters, the Wizard flaw
   and payoff, NPC roles for Lana, Boulder and Glim, and the species for Glim.
5. 14 beats per biome with a **function label** (teach 01-03, twist 04-06, combine 07-09, boss 10, bonus,
   h1-h3 remixes). The narrative lead writes situations; **the systems designer owns the mapping from function
   to rule**.
6. At least 4 beats per biome carry a non-plain `ending_pattern` (U16), and none is a counter or a plain
   "clear" (U15). The `opening_event` ids follow U8.
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

**Outputs:** `design/levels/plans/mechanics-handbook.md`, `mechanics-roster.md` and `progression.md` v2.
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
machine-readable `level_table` for the script check. Set pieces: 5-8 per biome, 60-96 in total; the technical
artist owns `assets/data/set_pieces.json` and flags art cost per piece (the file does not exist yet).
1. **Start from the beat.** Each spec opens with its beat id (= level id).
2. **Required fields per level:** `id`, `headline_objective`, `ending_pattern`, `metadata.signature`, `main_rule`
   (and extras, each linked to its handbook entry), `goal_type`, board mask (ASCII grid: `#` floor, `.` void,
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
- **Preconditions.** The scripts (U3, U5, U6, U7, U12, U14, U15, U16, the name check) must pass before human
  scoring. A script failure caps the matching criterion at 8.0.
- **Coverage.** Read every beat and spec of one biome in full and at least 5 levels of every other biome
  (across teach, boss and hard roles); cite at least 10 level ids per criterion.
- **Calibration.** The phase 2 and 4 makers first write one exemplar beat and one exemplar spec; the panel scores
  them (target 9.7) and one deliberately weak sample (target 8) before reviewing the rest.
- **Pillars.** Every rubric applies P1, P2a-c and P3a-d to 5 sampled levels.
- **Specific criteria are single-purpose.** The mundane or counter-based level cap is 8.0 on N4, M3 and L3.

**V (phase 1, this vision):** V1 fantasy, V2 pillar tests, V3 arc and ending, V4 uniqueness rules, V5 briefs,
V6 rubric, V7 consistency with user decisions.

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

**A (phase 5, art):** A1 look block and set-piece specs per level, A2 palette and block skins incl. Pirate,
A3 cast rows and silhouettes, A4 reference parity (boards 13 and 15), A5 no beige or parchment, A6 reduced motion.

**B (phase 6, build):** B1 verifier 0 failures, B2 boots (`ui_flow_smoke`), B3 JSON matches the specs and
`level_table`, B4 engine features (boss phases, goal phases, reveals) behave as handbook entries say,
B5 CI green and no `fixed_list`.

**C (phase 7-8, captures):** C1 start, mid, clear and end screenshot per level, C2 U5 and U14 hold on the real
frames, C3 targets visible at 720x1280, C4 contact sheets show 12 clearly different biomes, C5 P1-P3 hold in play.

**S (phase 8, sound):** S1 every action has feedback, S2 a music theme per biome following the arc, S3 boss and
ending cues, S4 comic fail sound, S5 mix and reduced-motion-safe cues.
