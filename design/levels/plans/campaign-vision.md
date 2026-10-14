# Campaign vision: Wacky Towers (phase 1 brief)

Author: studio game director (creative-director). Date: 2026-10-14. Status: for the phase 1 gate.
Inputs: `campaign-redo-plan.md`, `reference-quality-bar.md`, `art-bible.md`, reference boards 01, 02, 07
(story) and 09-12 (minigame layout only), `catalog.json`, `progression.md`, `minigames.md`,
`level-identity-spec.md`, the 2026-10-14 level/mechanics review (4.8/10) and level playtest, and
`2026-10-14-story-cast-decisions.md`.
User words: "all levels look the same", "make each level not just in art but also different in game play",
"make the narrative first and get inspired by the story to make the levels", "pass grade must be 9.7".
Decisions in force: 168 levels (12 biomes x 14); a FRESH story that keeps only the cast (Wizard mascot;
heroes Dame Ada the knight, Bram the dwarf, Sif the elf; NPCs Lana, Boulder, Glim). Old panels S01-S20
and `story-v2.md` are not binding.

## 1. Campaign fantasy

You are the tower-builder the Wizard trusts: a pair of steady hands in a sky of floating islands. The
world is a chain of twelve islands, and every one has a problem that a stack can solve. A broken path
needs a bridge. A drifting house needs a stout wall. A sleeping beacon needs a tall column to reach the
sky. You never swing a sword. You drop, turn and slot chunky blocks, and the heroes (Dame Ada, Bram,
Sif) and the Wizard react to what you build: they cross it, climb it, hide behind it and cheer on top
of it. Stacking matters because in this world **built things hold the sky together**. A tidy layer is a
mended floor, a cleared layer is a cheer, and a finished tower changes the island you are standing on.
The player should feel clever, a little mischievous, and always looked after.

## 2. Three pillars

Each pillar has a one-line test any reviewer can apply to a single level, cold, with the JSON, one
start screenshot and one clear screenshot.

**P1. Every level is a scene, not a stage.** One place, one problem, one reason to stack, written as the
level's `metadata.signature` and visible in the first 3 seconds with no text.
- *Test (swap test):* reskin the level into another biome. If it still makes sense, it fails. The
  story event, the set piece and the goal must be tied to this place.
- *Resolves:* a generic "clear 3 layers" slot vs a goal that is the story problem (build the bridge the
  goat needs).

**P2. The stack is the answer.** The goal is something the player builds or reveals, and the world
visibly changes when it is done. The rule that makes the level different must be felt in the piece
physics or the board, not only in a pill of rule names.
- *Test (change test):* name the world change the win causes (the bridge is crossed, the lamp lights,
  the door opens). Then name the one rule or shape that changes how the player drops pieces here. If
  either is missing, it fails.
- *Resolves:* a boss that is a hit-point bar vs a boss the player beats by building (walls, ramps, bait).

**P3. Cosy mischief, always fair.** Failure is funny and cheap, wins are generous, and nothing is
mean. One new idea per level. The game never hides a rule, never spawns an unwinnable piece run, and
never needs a sentence to be understood.
- *Test (kind-and-clear test):* (a) a first-time player can say what to do from the start frame alone;
  (b) a lost attempt shows a comic reaction and restarts in 2 seconds or less; (c) the level introduces at
  most one rule the biome has not already taught.
- *Resolves:* an opener with four stacked rules (the current `ice_01`) vs a single clear idea.

## 3. Emotional arc (catalog order)

Shape: wonder, then mischief, hush, strangeness, swagger, danger (the midpoint reversal), tangled warmth,
isolation, tension, loneliness (the low point), awe, release. Each biome has a feel verb and a role.

| # | Biome | Role in the arc | Feel the player leaves with |
|---|---|---|---|
| 1 | Meadow | **Wonder and welcome.** Meet the Wizard and the first hero. Teach by doing. | "I can do this, and the world is kind." |
| 2 | Candy | **Mischief.** Sweet chaos, a prankster problem, the first real boss. | Delight, a giggle at a mess |
| 3 | Ice | **Hush and slide.** Quieter music, slippery floors, the first moment of real care for a hero. | Calm awe, careful hands |
| 4 | Underwater | **Strange wonder.** Light from above, odd friends, a shy giant. | Curiosity with a hint of unease |
| 5 | Pirate | **Swagger and cheek.** Loud, rowdy, funny rivals. Energy lift after two slow biomes. | Cheeky confidence |
| 6 | Lava | **Danger (midpoint reversal).** The first time the team is truly in trouble. A hero is at risk. | Tension, "we might lose this" |
| 7 | Forest | **Tangled warmth.** After the heat, shelter and a secret. The cast bonds. | Relief, belonging |
| 8 | Cave | **Trust in the dark.** Small light, small boards, one hero alone with the player. | Quiet courage |
| 9 | Clockwork | **Tension of precision.** A machine everyone is stuck in. Ticking, timed, tidy. | Focus, satisfaction in order |
| 10 | Neon | **Low point.** Bright but empty. The loneliest island. A setback the heroes must face. | Doubt turning to resolve |
| 11 | Celestial | **Awe and gathering.** Above the weather. Everyone returns. The stakes are named. | Sublime calm, readiness |
| 12 | Carnival | **Triumph and release.** The party of the whole cast. Every learned idea comes back as a game. | Joy, pride, "I built all of this" |

Intensity runs as a sawtooth inside each biome (teach, twist, combine, finale, then a breather bonus)
and as a stair across the campaign (the Lava danger and Neon low are the two deepest dips).
Bonus levels are always the exhale. The hard track (h1-h3) is mastery, not story.

## 4. Tone rules

**Voice.** Storybook-wacky: warm, a little silly, kind to everyone. Think a bedtime tale told by a
cheerful uncle. Villains are mischievous or misunderstood, never cruel. Nobody dies. Peril is comic.

**Wordless in-level moments.** Anything that happens during play (a hero waving, the goat bleating, a
door opening) is shown through animation, sound and the set piece. No dialogue during a drop. No
text over the board. Level intros and outros may use one short caption outside play.

**Text budget (live UI only, never baked into art).**
- Story caption: one sentence, 14 words or fewer, on a title ribbon over a painted panel.
- Tutorial bubble: 12 words or fewer, shown once, dismissible, never over the grid.
- Level and boss names: 1-4 words, in the storybook-pun style ("Mushroom Ring", "Madame Meringue").
- No sentence needs the player to have read a previous one. Story is optional and never gates progress.

**Humour style.** Physical, visual and character-based: wobbling stacks, a hero bonking a door,
a sheep sitting on the wrong tower, a crab with a tiny hat. Puns in names only, one per name. No
sarcasm, no mocking the player, no fourth-wall nagging, no toilet gags. Losing is a pratfall, not a shame.

**Hard rules.**
- No Nintendo IP: no characters, items, names, music or level layouts. Boards 09-12 are layout only.
- No "Tetris" naming anywhere (code strings, level names, captions, marketing text). Never copy the board
  logos ("TETRO PARTY DIMENSIONS", "WACKY PARTY", "PARTY QUEST"); our logo is `logo_master.jpg`.
- No beige or parchment UI: open purple-wood frames over a painted scene (board 05), plum glass planks.
- No board title is reused as a level or minigame name (see `minigames.md` "Naming fixes").
- Cast discipline: Wizard (mascot), Dame Ada, Bram, Sif (heroes), Lana, Boulder, Glim (NPCs) are the
  only recurring named characters. Everyone else is a one-off local (a goat, a crab, a clockmaker) or a
  villain. New characters need a silhouette and a colour key that follow `art-bible.md` section 5.

## 5. "Every level unique" as testable rules

This extends `level-identity-spec.md` and keeps all its rules (shape and goal quotas, no `fixed_list`,
`look` block, one signature). Every level must answer four questions with a distinct answer. A reviewer
checks them from the level spec alone (phase 5) and from capture (phase 8).

**Four facets per level.**
1. **Story beat:** a beat id (`<biome>_<nn>`) with who is there, what goes wrong and why the player stacks.
2. **Place:** a named spot on the island with a set piece (`look.set_piece`) and a `time_of_day`.
3. **Way of playing:** a unique triple of (goal, main rule, board shape) plus one signature sentence.
4. **Look:** a distinct silhouette on the start frame: board mask, set piece, sky and weather.

**Rules (all machine- or reviewer-checkable).**
- **U1 Beat first.** Every spec starts from its beat. A spec with no beat id and no reason to stack is rejected.
- **U2 Swap test.** The beat, goal and set piece cannot move to another biome unchanged (P1).
- **U3 Unique triple.** No two levels in the campaign share (goal type, main rule, board shape). Compare mask
  topology, not just size. A mirrored or rotated mask counts as the same shape.
- **U4 Signature is a story sentence,** 4-14 words, naming the event or place, not the rules ("the one where
  the goat's bridge sways"). No two signatures share a verb-noun core.
- **U5 Squint test.** Hide the HUD and the biome skin. A reviewer must tell any two levels in a biome apart
  from the start frame by silhouette alone. This needs different masks or set pieces, not just a recolour.
- **U6 Look spread.** Within a biome no two consecutive levels share `time_of_day` + `set_piece`. Across a
  biome at least 4 of 5 `time_of_day` values, at least 3 `weather` values and at least 5 set pieces appear.
- **U7 Feel spread.** Within a biome at least 6 distinct goal types, at least 8 distinct board shapes (at most
  4 plain squares), at most 5 `clear_n` goals, and at least 3 levels where the camera is not `default`.
- **U8 First-10-seconds event.** Each level has one distinct opening moment (a hero walks in, a tide rises,
  a clock chimes) that makes it recognisable in a screen recording with the sound off.
- **U9 Finale is a face.** Each tier-10 level is a phased boss tied to its chapter villain or problem. It
  changes the arena at least once. It is beaten by building, not by stat checks (P2).
- **U10 Rule budget.** At most one new rule per level, at most two rules visible on the pill in levels 01-03,
  and a rule must be taught alone (in isolation) before it is combined.
- **U11 World change.** The clear state changes the scene (a lit lamp, a crossed bridge), captured in the
  clear screenshot. Failure shows a comic reaction.
- **U12 No cookie-cutter slots.** The same tier number may not share a goal type in more than 4 of 12 biomes
  (today tier 05 is `build_race` + height in 11 of 12).
- **U13 Cross-biome echo.** Echoes are allowed only as a deliberate callback with a story reason, and are
  marked `callback_of` in the spec.

## 6. Brief for the narrative lead (phase 2)

**Output:** `design/narrative/campaign-story.md` (12 chapters, campaign arc, villains, allies) and
`design/narrative/beats/<biome>.md` (14 beats each). Each beat: id, place, who is there, what goes wrong,
why the player stacks, the world change on win, the wordless moment, an optional caption of 14 words or fewer.

**The fresh story must achieve:**
1. **A single through-line** a child can retell in two sentences, with one reason the heroes travel from
   island 1 to island 12 and why the order matters (it fits section 3).
2. **Stacking is canon.** Say why building holds the world together (the world rule in section 1), so each
   chapter's problem is a stacking problem.
3. **Twelve distinct chapters,** each with its own problem, local ally or villain (one-offs allowed), set pieces
   and emotional beat from the arc table. Every biome has a boss face for its finale. Pirate is its own
   chapter and does not copy Underwater.
4. **The cast earns its place.** Each of Ada, Bram and Sif has an arc and a reason to be in at least 3 biomes.
   Lana, Boulder and Glim are NPCs who help or hinder, with a clear role each. The Wizard has a flaw
   (kind, forgetful, a bit vain) and a payoff.
5. **14 beats per biome that vary by function:** teach (01-03), twist (04-06), combine (07-09), boss (10), a
   bonus exhale, and three hard-track remixes that are "the same place, sillier or faster".
6. **Designed for the screen:** every beat can be shown with no text in play, in one place, with one set piece.
   Beats must be gameplay-neutral enough that phase 3 can assign mechanics (but not mechanics-first).
7. **Resolve doc conflicts:** `tumble-fair.md` (a 5-level side island) is replaced by the 14-level Carnival
   biome; the finale of the story is the Carnival.
8. **Lean text:** the whole story must survive as 12 chapter captions plus the level names. A skimmer who
   reads nothing else still gets the arc.

**Three candidate high concepts.** Each passes the "and also" test. The narrative lead chooses and may
combine or replace them.

- **A. "The Wobbling World."** A sneeze (the Wizard's) topples the Great Tower that pins the islands
  together and scatters twelve Keystones. Each island starts to sag, drift or go odd in its own way, and the
  trio rebuilds each island's piece. *It's a cosy island-hopper, and also the world is held together by what
  you build.* Strength: stacking is literally the plot, and the finale is a refit party. Risk: the sneeze
  can feel like a generic accident, so give the Wizard a real flaw.
- **B. "The Grand Tumble Fair."** The Wizard sends invitations for a once-a-century Fair and the heroes
  collect a ticket-stub from each island by solving its local mess, only to find the Fair's host is
  secretly lonely. *It's a trip across twelve biomes, and also every island is a game at the Fair.* Strength:
  the party tone and minigames fit, and the Carnival is the natural climax. Risk: a thin villain, and the
  middle biomes can feel like errands.
- **C. "The Lamplighters' Road."** The sky has gone dim because the twelve beacons on the islands are out. The
  heroes light them by building each a base tall enough to reach the old light line. The final beacon is built
  by every island's ally together. *It's a stacking puzzler, and also a quest to bring the light back.*
  Strength: a clear visual payoff (each beacon lights, the sky brightens by biome), strong time-of-day and
  `look` variety. Risk: a "quest for items" structure, and a need for a strong reason for the Neon low.

**Recommendation: A.** It makes P2 (the stack is the answer) the plot itself, and the Carnival's
triumph (the world holds) has an earned payoff. It also gives every biome a simple problem to dress up
(a sagging, drifting or humming island). I would borrow C's beacon-light payoff for the visual reward on each
win. This is the narrative lead's call: if B or C produces better beats, take it and say why.

## 7. Brief for the systems designer (phase 3)

**Output:** `design/levels/plans/mechanics-roster.md` and `progression.md` v2.

1. **Mechanics follow the story.** Each biome gets one signature mechanic family that comes from its
   chapter's problem (not from the old rule list). Re-use the 40-odd existing rules where they fit, and
   list engine gaps explicitly (the plan names boss phases, the minigame phase runner, new goals and the
   shape overlay).
2. **Teach, twist, combine.** For each biome list: 1 new rule taught alone, 2 twists, 2 combines. At most
   one new rule per level (U10). Show a dependency graph across biomes so no rule appears untaught.
3. **Goal vocabulary.** Assign every level a goal from the full set (`height`, `shape`, `survive`,
   `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven`, `clear_n`, plus the span/climb/route
   goals from the minigames). `clear_n` is the exception: at most 5 per biome.
4. **Minigame blocks.** Keep the 16 modules and give each a debut level, a recall and a story reason
   (which beat motivates it). No biome debuts more than 2. Define the phase runner contract.
5. **Boss systems.** A phased boss for every tier 10, defeated by building. Define the 12 boss mechanics
   and the arena change per phase. No hit-point bar that ignores board state.
6. **Difficulty formulas.** Write `g0`, goal `n`, time stars and the hard track as formulas of tier and
   biome index. Fix the review's faults: `g0` rises across the campaign and within each biome, the hard
   track is faster than tier 10, finale `n` is not lower than tiers 07-09, stars depend on the rules.
7. **Fairness spec.** No `fixed_list`. Opening sets for tier 01 of each biome, a spawn-safety rule and a
   soft-lock warning for finite puzzles.
8. **Unlock flow.** Keep the 15/30 star gate unless a case is made. Cover the minigame to tournament unlock
   and the hard track gate.
9. **First hour.** `meadow_01` must be winnable by a new player in under two minutes (the review found it
   was a wall).

## 8. Brief for the level design lead (phase 4)

**Output:** `design/levels/plans/<biome>.md` v2 for all 12 biomes, run as 4 groups of 3 biomes in parallel.

1. **Start from the beat.** Each level spec opens with the phase 2 beat id and a one-line restatement.
2. **Required fields per level:** `id`, beat id, `metadata.signature`, board mask (ASCII grid or named
   shape), goal (type and n), main rule and extras, minigame block if any, `look` block (all keys),
   camera, `g0` and stars from the phase 3 formula, the role (teach, twist, combine, boss, bonus, hard),
   the first-10-seconds event, the world-change on win, the comic fail reaction, and `callback_of` if used.
3. **Check the unique rules.** Each biome file ends with a table that proves U3, U6, U7 and U12 (the
   triple, the look spread, the shape and goal counts). A group lead checks cross-biome U3.
4. **Shapes.** Use real masks (cross, ring, L, twin islands and bridge, terraces, diamond, U-bay, stepping
   stones) up to 12x12, and make sure masks render as missing floor, not as a texture (C1 from the playtest).
5. **Readability.** Targets (shape goals, keyholes, objectives) must be visible from frame 0 at 720x1280.
   Make the active piece distinct from the stack, and the landing marker high contrast. Flag any spec that
   needs engine support so phase 6 can build it first.
6. **Level 01 of each biome** has one rule at most, an opening set and a gentle `g0`.
7. **Bonus and hard levels.** The bonus is a relaxed set piece with a playful goal. Hard levels are
   remixes of the biome's best ideas with a new look, not recolours.
8. **No fixes to JSON in this phase.** Specs only.

## 9. The 9.7 review rubric (phases 2, 3 and 4)

**How scoring works.** Each reviewer scores every criterion from 1 to 10 and cites evidence (file and
line, level ids). **A phase passes only if every criterion is at least 9.7 and the mean is at least 9.7.**
Anchors: 10 means a stranger could not improve it; 9.7 means only nitpicks that do not change a player's
experience; 9 means a clear fix is listed; 8 or lower means a real defect. Reviewers list ranked defects
with an owner and a fix, and they instruct while makers fix. Reviewers must check the rules in sections
4 and 5 and the cast and IP rules.

### Rubric N (phase 2: narrative)

- **N1 Through-line and logic.** A two-sentence summary works; each chapter follows the last; the order of
  the 12 biomes is motivated; stacking is canon.
- **N2 Arc and emotion.** Matches the section 3 arc; the Lava reversal and Neon low land; the Carnival pays off.
- **N3 Cast and characters.** Only the allowed recurring cast; each hero has an arc; villains are charming;
  silhouettes and colour keys follow the art bible.
- **N4 Beat quality.** 168 beats, each with place, problem, reason to stack, world change and a wordless
  moment; varied by function; no two beats alike.
- **N5 Tone and text.** Storybook-wacky; caption and bubble limits kept; no dialogue in play; no IP or
  "Tetris"; no cruelty.
- **N6 Playability hand-off.** Beats are showable in one place with one set piece, give phases 3 and 4
  clear hooks, and leave mechanics to the systems designer.

### Rubric M (phase 3: mechanics and progression)

- **M1 Story-to-mechanic fit.** Every mechanic traces to a beat; none is a leftover.
- **M2 Teach and combine.** One new idea per level, taught alone, graphed with no untaught rule.
- **M3 Variety and quotas.** Goal and shape quotas (U7), minigame debuts (max 2 per biome) and boss mechanics
  are all met and are distinct from each other.
- **M4 Difficulty math.** The formulas rise across and within biomes; the hard track beats tier 10; stars fit
  the rules; the first hour is gentle.
- **M5 Fairness and feel.** No `fixed_list`; spawn safety and soft-lock warnings; boss fights are beaten by
  building; readable feedback.
- **M6 Buildability.** Engine gaps are listed with an owner and a size; the roster is realistic for the
  plan's phase 6 and respects Compatibility-safe rendering.

### Rubric L (phase 4: level specs)

- **L1 Beat fidelity.** Every level spec follows its beat and keeps its signature.
- **L2 Uniqueness.** Rules U1-U13 pass for all 168 (triples, signatures, squint test, look spread).
- **L3 Gameplay variety.** Goals, shapes, rules, cameras and minigame blocks differ across a biome and
  across the campaign; no cookie-cutter slots.
- **L4 Curve and pacing.** `g0`, `n` and stars follow the phase 3 formulas; sawtooth within a biome;
  finales are the peak; bonus levels are the exhale.
- **L5 Readability and fairness.** Targets visible from frame 0 at 720x1280; piece and stack contrast;
  one new rule per level; no unwinnable runs.
- **L6 Look and art direction.** The `look` block is complete and distinct; set pieces exist or are
  specced; palettes follow the art bible and board 15; no beige UI.
- **L7 Completeness and buildability.** All required fields are present for every level; engine needs are
  flagged; the spec is concrete enough to build JSON without guessing.

## 10. Validation: we will know this vision worked if

- A new player can describe three different levels from different biomes by story, not by rules.
- A reviewer shown any two start frames from one biome can say which is which with the HUD hidden.
- The final review scores every criterion at 9.7 or higher, with the Lava dip and the Carnival payoff
  noticed by playtesters without prompting.
