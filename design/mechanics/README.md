# Mechanics Folder: the Box of Tricks

All game mechanics live in one library: **[`design/gdd/mechanics-module.md`](../gdd/mechanics-module.md)**. Every level, tournament minigame and daily challenge is built from it.

- One file per atom would be overkill for now, so every atom stays in the module's tables.
- Split an atom into its own file here only when its rules grow past one table row. The module's row then links to that file.
- Ideas that are not atoms yet go in [`design/gdd/mechanics-catalog.md`](../gdd/mechanics-catalog.md).

## What's in the box

The atoms are grouped into 14 slots. Each atom has an ID, a one-line rule, the game it came from, its tags, a cost and a status (Designed / Candidate / Proposed / Parked).

- **Proposed** (2026-10-10): 42 new atoms from the puzzle and party proposals. Their hook, knobs and guards are in module §2b. Review one to Candidate before a shipped level uses it.
- **Renamed ids**: party BL17 → BL20 Handicap Footprint, GO27 → GO30 Boss Raid, EV20 → EV24 Sprinkle Shower, WO12 → WO14 Skill Rule. BL17, GO27, EV20 and WO12 are the puzzle atoms.
- **Runtime**: every atom that changes the game is a rule or slot plugin inside the sim (ADR-0004, ADR-0011). Beehave trees only stage animation.

| # | Slot | Prefix | Examples |
|---|---|---|---|
| 1 | Board / Layout | BL | box, well, tubes, islands, track, creature back |
| 2 | Arrival / Piece source | AR | top drop, slide-in, crane, tray of three |
| 3 | Control / Verb | CV | rotate, swap, tap-pop, pull, chisel, throw, push cube, gravity nudge |
| 4 | Placement rule | PL | trim, wobble, laser line, crosswise |
| 5 | Clear / Match | CL | layer, row, colour pop, sweep, merge |
| 6 | Collapse | CO | slice, cascade, refill, launch |
| 7 | Goal / Win | GO | clear N, height, orders, picture reveal, critter walkers |
| 8 | Fail / Top-out | FT | warnings, trim, piece budget, topple |
| 9 | Scoring / Combo | SC | chain, multi-clear, perfect streak |
| 10 | Interaction / Items | IN | garbage, offset, Banana Cube, Comet |
| 11 | Modifiers / Events | EV | wind, goo, rule cubes, biome events |
| 12 | Special pieces / objects | SP | rockets, jelly tiles, living blocks, ghost piece |
| 13 | Secrets | SE | poke the mascot, angle gems, hidden levels |
| 14 | World & Mascot | WO | tidiness mood, weather forecast, mascot roles |

## How to build a level or minigame from atoms

1. **Write the story card first.**
   - One-line premise, for example: "The candy mascot spilled jelly all over the shop floor."
   - The mascot's role: helper, prankster, mood swing or watcher.
   - Every level is a tiny story, and the atoms you pick should explain it.
2. **Pick the context.**
   - `campaign`: solo.
   - `minigame`: always competitive, 2–4 players. Pick a length: `burst` (30–60 s), `standard` (60–180 s) or `showpiece` (180–240 s).
   - `arcade`.
   - The daily challenge is made by the generator; don't hand-build it.
3. **Fill the five required slots**: Board, Arrival, Verb, Goal, Fail.
4. **Add the optional atoms that tell the story**: a clear rule plus its collapse, placement, specials, scoring and events. A recipe allows at most 1 level mechanic and 2 twists.
   - Minigames must add at least one Interaction (IN) atom.
   - Co-op and team atoms are Parked; don't use them. Exception: the team-up events GO30 Boss Raid and IN31 Truce Pact, in tournaments only (scores stay individual).
   - Atoms tagged `tourney` (edges and team-ups) are off in quick versus.
5. **Check the tags.** No conflicting pairs, for example:
   - `noclr` with `clr`
   - `nofall` with `fall`
   - `floor` with gravity flip
   
   The full list is in module §3.
6. **Check the readability budget** (module F1):
   - A campaign level has at most 2 atoms new to the player and 4 non-default atoms.
   - Showpiece levels in tiers 7–10 may have up to 6 non-default atoms.
   - A minigame has at most 3 new and 5 non-default, and lasts 30–240 s.
   - **How to count**: Goal and Fail picks count when they are not the default (GO01, FT01). A listed bundle counts 1 (M1 build race GO02 + CL14 + FT02, M2 fill shape, Pull, Last standing; table in module F1). Secrets and the story card's mascot role count 0.
   - Puzzle (`turn`) levels can be failed. FT12 undo/reset is an optional atom and counts if picked.
   - The idea must fit one sentence and be visible within the first two pieces.
   - **No drift curve.** How far a level strays from classic Tetris, and how much physics silliness it has, goes up and down from level to level, with only a general trend toward variety. A calm, near-classic level after a wild one is fine.
7. **Write the level JSON.**
   - Each atom becomes a slot knob, a `mechanic`/`twists` rule, `starting_contents` content, or minigame data.
   - Keep the `recipe` block (atoms plus story card) for the editor and reviews.
   - See the R3 example in module §3.
8. **Picked a Candidate atom?** Move its full rules into the owning GDD. Then change its status in the module to Designed, with a link.

## Recipe template

```text
Name:          <two words>
Context:       campaign | minigame (<length class>) | arcade
Story:         <one-line premise> · mascot: helper | prankster | mood swing | watcher
Board:         BLxx (size, mask)
Arrival:       ARxx
Verb:          CVxx
Goal:          GOxx (target)
Fail:          FTxx
Optional:      CLxx + COxx · PLxx · SPxx · SCxx · EVxx · SExx · WOxx
Interaction:   INxx (minigames only)
One sentence:  "<the rule card>"
```

Ten worked recipes (Sky Sprint, Toy Box Critter, Candy Cascade, Kitchen Rush, Melon Merge, Beat Sweep, Wobble Pull, Panel Clash, Picnic Tray, Storm Keeper) and eight tournament rounds (T1–T8: Piñata Party, Monster Mash, Card Shark, Boss Raid, Spotlight Showdown, Sprinkle Frenzy, Skill Storm, Underdog Derby) are in module §3. All are within their caps under the count rule.
