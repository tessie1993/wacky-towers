# Campaign vision: Wacky Towers (phase 1 brief)

Author: studio game director. Date: 2026-10-14. For the phase 1 gate. Inputs: the redo plan, quality bar,
art bible, reference boards, `catalog.json`, `progression.md`, `minigames.md`, `level-identity-spec.md`,
the level/mechanics review (4.8/10) and the level playtest.
User words: "all levels look the same", "different in game play", "narrative first", "pass grade must be 9.7".
Decisions in force: 168 levels (12 biomes x 14); a FRESH story keeping only the cast (Wizard mascot; heroes
Dame Ada the knight, Bram the dwarf, Sif the elf; NPCs Lana, Boulder, Glim). Old panels S01-S20 and
`story-v2.md` are not binding.

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

Each pillar has a test a reviewer can apply to one level from its JSON and two screenshots.

**P1. Every level is a scene, not a stage.** One place, one problem, one reason to stack, written as the
level's `metadata.signature` and visible in the first 3 seconds with no text.
- *Test (swap test):* reskin the level into another biome. If it still makes sense, it fails. The
  story event, the set piece and the goal must be tied to this place.

**P2. The stack is the answer.** The goal is something the player builds or reveals, and the world
visibly changes when it is done. The rule that makes the level different must be felt in the piece
physics or the board, not only in a pill of rule names.
- *Test (change test):* name the world change the win causes (the bridge is crossed, the lamp lights,
  the door opens). Then name the one rule or shape that changes how the player drops pieces here. If
  either is missing, it fails.

**P3. Cosy mischief, always fair.** Failure is funny and cheap, wins are generous, and nothing is
mean. One new idea per level. The game never hides a rule, never spawns an unwinnable piece run, and
never needs a sentence to be understood.
- *Test (kind-and-clear test):* (a) a first-time player can say what to do from the start frame alone;
  (b) a lost attempt shows a comic reaction and restarts in 2 seconds or less; (c) the level introduces at
  most one rule the biome has not already taught.

## 3. Emotional arc (catalog order)

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

Intensity is a sawtooth inside each biome (teach, twist, combine, finale, breather bonus) and a rising
stair across the campaign, with Lava and Neon as the two deep dips. Hard levels (h1-h3) are mastery.

## 4. Tone rules

**Voice.** Storybook-wacky: warm, a little silly, kind to everyone. Villains are mischievous or
misunderstood, never cruel. Nobody dies. Peril is comic.

**Wordless in-level moments.** Anything during play (a hero waving, a door opening) is shown by animation,
sound and the set piece. No dialogue during a drop, no text over the board. Intros and outros may carry
one short caption outside play.

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
- Cast discipline: Wizard (mascot), Dame Ada, Bram, Sif (heroes), Lana, Boulder, Glim (NPCs) are the
  only recurring named characters. Everyone else is a one-off local (a goat, a crab, a clockmaker) or a
  villain. New characters need a silhouette and a colour key that follow `art-bible.md` section 5.

## 5. "Every level unique" as testable rules

This extends `level-identity-spec.md` and keeps all its rules (quotas, no `fixed_list`, `look`, signature).
Every level has four distinct facets: **story beat** (id `<biome>_<nn>`, who, what goes wrong, why stack),
**place** (set piece and time of day), **way of playing** (unique goal, rule, shape triple plus signature)
and **look** (start-frame silhouette: mask, set piece, sky, weather). Checked from specs (phase 5) and
captures (phase 8).

- **U1 Beat first.** Every spec starts from its beat. A spec with no beat id and no reason to stack is rejected.
- **U2 Swap test.** The beat, goal and set piece cannot move to another biome unchanged (P1).
- **U3 Unique triple.** No two levels in the campaign share (goal type, main rule, board shape). Compare mask
  topology, not just size. A mirrored or rotated mask counts as the same shape.
- **U4 Signature is a story sentence,** 4-14 words, naming the event or place, not the rules.
- **U5 Squint test.** Hide the HUD and the biome skin. A reviewer must tell any two levels in a biome apart
  from the start frame by silhouette alone. This needs different masks or set pieces, not just a recolour.
- **U6 Look spread.** Within a biome no two consecutive levels share `time_of_day` + `set_piece`. Across a
  biome at least 4 of 5 `time_of_day` values, at least 3 `weather` values and at least 5 set pieces appear.
- **U7 Feel spread.** Within a biome at least 6 distinct goal types, at least 8 distinct board shapes (at most
  4 plain squares), at most 5 `clear_n` goals, and at least 3 levels where the camera is not `default`.
- **U8 First-10-seconds event.** One distinct opening moment (a hero walks in, a tide rises) that makes the
  level recognisable on mute.
- **U9 Finale is a face.** Each tier-10 level is a phased boss tied to its chapter villain or problem. It
  changes the arena at least once. It is beaten by building, not by stat checks (P2).
- **U10 Rule budget.** One new rule per level at most, two rules on the pill in levels 01-03, and a rule is
  taught alone before it is combined.
- **U11 World change.** The clear changes the scene (a lit lamp, a crossed bridge); failure is a comic reaction.
- **U12 No cookie-cutter slots.** The same tier number may not share a goal type in more than 4 of 12 biomes
  (today tier 05 is `build_race` + height in 11 of 12).
- **U13 Echoes** are allowed only as a deliberate callback with a story reason, marked `callback_of`.

## 6. Brief for the narrative lead (phase 2)

**Output:** `design/narrative/campaign-story.md` (12 chapters, campaign arc, villains, allies) and
`design/narrative/beats/<biome>.md` (14 beats each). Each beat: id, place, who is there, what goes wrong,
why the player stacks, the world change on win, the wordless moment, an optional caption of 14 words or fewer.

**The fresh story must achieve:**
1. **One through-line** a child can retell in two sentences, with a reason to travel island 1 to 12 in
   this order (fits section 3).
2. **Stacking is canon:** say why building holds the world together, so every chapter's problem is a stacking problem.
3. **Twelve distinct chapters,** each with a problem, a local ally or villain (one-offs allowed), set pieces
   and the arc-table emotion. Every biome has a boss face. Pirate is its own chapter, not Underwater's twin.
4. **The cast earns its place.** Ada, Bram and Sif each have an arc and appear in 3+ biomes; Lana, Boulder
   and Glim are NPCs with a clear role each; the Wizard has a flaw (kind, forgetful, a bit vain) and a payoff.
5. **14 beats per biome by function:** teach (01-03), twist (04-06), combine (07-09), boss (10), bonus
   exhale, three hard-track remixes ("same place, sillier or faster").
6. **Built for the screen:** each beat shows with no text, in one place, with one set piece, and is
   mechanics-neutral enough for phase 3 to assign rules.
7. **Resolve doc conflicts:** `tumble-fair.md` (5-level side island) gives way to the 14-level Carnival biome.
8. **Lean text:** the story must survive as 12 chapter captions plus level names.

**Three candidate high concepts.** Each passes the "and also" test. The narrative lead chooses and may
combine or replace them.

- **A. "The Wobbling World."** The Wizard's sneeze topples the Great Tower that pins the islands together,
  scattering twelve Keystones. Each island sags, drifts or goes odd in its own way, and the trio rebuilds
  each one. *A cosy island-hopper, and also the world is held together by what you build.* Strength:
  stacking is the plot; the finale is a refit party. Risk: the sneeze is a generic accident, so give the
  Wizard a real flaw.
- **B. "The Grand Tumble Fair."** The Wizard sends invitations to a once-a-century Fair; the heroes win a
  ticket-stub on each island by fixing its local mess, then find the host is secretly lonely. *A trip across
  twelve biomes, and also every island is a game at the Fair.* Strength: party tone, minigames and a natural
  Carnival climax. Risk: a thin villain; middle biomes feel like errands.
- **C. "The Lamplighters' Road."** The sky is dim because twelve beacons are out. The heroes light each by
  building a base tall enough to reach the old light line; the last beacon is built by every ally together.
  *A stacking puzzler, and also a quest to bring the light back.* Strength: a visual payoff per win and
  strong time-of-day variety. Risk: an item-quest structure; the Neon low needs a strong reason.

**Recommendation: A.** It makes P2 the plot itself, gives every biome a simple problem to dress up (a
sagging, drifting or humming island) and earns the Carnival payoff. Borrow C's beacon-light as the win
reward. This is the narrative lead's call: if B or C yields better beats, take it and say why.

## 7. Brief for the systems designer (phase 3)

**Output:** `design/levels/plans/mechanics-roster.md` and `progression.md` v2.

1. **Mechanics follow the story.** One signature mechanic family per biome, drawn from its chapter's
   problem. Reuse existing rules where they fit; list engine gaps (boss phases, minigame phase runner,
   new goals, shape overlay) with an owner.
2. **Teach, twist, combine.** Per biome: 1 new rule taught alone, 2 twists, 2 combines, at most one new
   rule per level (U10). Include a cross-biome dependency graph so no rule appears untaught.
3. **Goal vocabulary.** Assign every level a goal from the full set (`height`, `shape`, `survive`,
   `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven`, minigame goals); `clear_n` at most 5 per biome.
4. **Minigame blocks.** Keep the 16 modules, each with a debut, a recall and the beat that motivates it;
   at most 2 debuts per biome; define the phase runner contract.
5. **Bosses.** A phased boss at every tier 10, beaten by building, with the arena change per phase.
6. **Difficulty formulas.** `g0`, goal `n`, stars and the hard track as formulas of tier and biome index.
   Fix the review faults: `g0` rises within and across biomes, hard track beats tier 10, finale `n` is
   not below tiers 07-09, stars depend on the rules.
7. **Fairness and flow.** No `fixed_list`; opening sets for each level 01; spawn safety; soft-lock
   warning; keep the 15/30 star gate unless argued; `meadow_01` winnable in under two minutes.

## 8. Brief for the level design lead (phase 4)

**Output:** `design/levels/plans/<biome>.md` v2 for all 12 biomes, in 4 parallel groups of 3 biomes.

1. **Start from the beat.** Each spec opens with its phase 2 beat id.
2. **Required fields per level:** `id`, beat id, `metadata.signature`, board mask (ASCII grid), goal and n,
   main rule and extras, minigame block, full `look` block, camera, `g0` and stars from the phase 3 formula,
   role (teach, twist, combine, boss, bonus, hard), first-10-seconds event, world change on win, comic fail
   reaction, `callback_of` if any.
3. **Prove uniqueness.** Each biome file ends with a table proving U3, U6, U7, U12; group leads check
   cross-biome U3.
4. **Shapes and readability.** Real masks up to 12x12 that render as missing floor; targets visible from
   frame 0 at 720x1280; active piece distinct from the stack; high-contrast landing marker. Flag engine needs.
5. **Level 01** has at most one rule, an opening set and a gentle `g0`. Bonus is a relaxed set piece;
   hard levels are remixes with a new look, not recolours.
6. Specs only. No JSON edits in this phase.

## 9. The 9.7 review rubric (phases 2, 3 and 4)

**Scoring.** Each reviewer scores every criterion 1-10 and cites evidence (file, level ids). **A phase
passes only if every criterion is at least 9.7.** Anchors: 10 = a stranger could not improve it; 9.7 =
nitpicks only; 9 = a clear fix is listed; 8 or lower = a real defect. Reviewers list ranked defects with
owner and fix; makers fix. Reviewers also check sections 4 and 5, the cast and the IP rules.

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
