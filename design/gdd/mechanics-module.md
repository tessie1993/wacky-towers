# Mechanics Module (the Box of Tricks)

> **Status**: In Design
> **Author**: Tessa + agents (game-designer)
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos; Comeback Energy
> **Folder entry point**: `design/mechanics/README.md`

## Overview

The Mechanics Module is a library of composable **mechanic atoms**. Each atom is one small rule built from our Piece Set blocks: a board, a way pieces arrive, a verb, a placement rule, a clear rule, a collapse, a goal, a fail rule, a scoring rule, an interaction, an event, a special object, a secret or a world/mascot rule. A level, a tournament minigame or the daily challenge is a **recipe**: one atom from each required slot, plus optional atoms, plus a one-line **story card**. Every atom maps to exactly one engine hook that already exists in ADR-0004: a strategy-slot plugin id, a rule (data or `RuleBehaviour`), a content type, or a minigame-scene parameter. So a recipe becomes level or minigame JSON with no new framework. Verbs use ADR-0004's `control.verb` slot (`ControlVerb` plugin base). The atoms are distilled from popular games: Candy Crush, Toon Blast, Royal Match, Puyo, Lumines, Tetris 99, Tetris Effect, Tricky Towers, Stack, Tower Bloxx, 2048, Suika, Block Blast, Woodoku, Ball Sort, Jenga, Panel de Pon, Dr. Mario, Meteos, Picross 3D, Boom Blox, Minecraft Build Battle, Ultimate Chicken Horse, Mario Party, Mario Kart, Fall Guys, Lemmings and Baba Is You. Atom ideas here are **Candidates** unless marked otherwise. When a level or minigame picks one, its full rules move into the owning GDD and the row here links to it. All numbers are tunable defaults.

## Player Fantasy

"I know these blocks, and every level still surprises me." The player always holds the same chunky, cute blocks, but one day they're popping candy jelly, the next they're racing a friend across floating islands, and the next they're pulling pieces out of a wobbling tower while the mascot pranks them. Each level feels like a tiny story with one clear idea that is readable within two pieces. For the team, the fantasy is a toy box: pick atoms, snap them together, write a story card and get a new level.

Target MDA aesthetics: **Discovery** (new atom combinations), **Challenge** (each recipe is a puzzle), **Fellowship** (competitive minigame recipes) and **Expression** (secrets, theme builds).

## Detailed Design

### 1. How to read the library

- **Slots.** There are 14 slots. Slots 1–12 cover the moment-to-moment rules. Slot 13 (Secrets) and slot 14 (World & Mascot) are the discovery and world layers.
- **Atom ID.** `<slot prefix><number>`, for example `CL05`. IDs never change once written; new atoms are appended.
- **Engine hook.** Given per slot in the slot heading. It names the ADR-0004 / architecture §5 extension point the atoms use.
- **Status**
  - **D** = Designed: full rules already live in the linked GDD.
  - **C** = Candidate: in the box, ready to pick.
  - **Pr** = Proposed: added from the 2026-10-10 puzzle and party proposals (user decision: all 42 go in). Not yet reviewed into Candidate. Extra notes (hook, knobs, guard) are in §2b.
  - **P** = Parked: kept, not planned. Co-op and team atoms are parked, because minigames are always competitive and there is no co-op mode (user rule, 2026-10-10). **Exception** (user, 2026-10-10): short team-up party events, GO30 Boss Raid and IN31 Truce Pact, are allowed **in tournaments only**, and scores stay individual. They carry `vs tourney`, not `coop`.
- **Renamed proposal ids.** Four party proposals clashed with puzzle proposals. The puzzle ids were kept, and the party ids moved to the next free id: party BL17 Handicap Footprint → **BL20**, party GO27 Boss Raid → **GO30**, party EV20 Sprinkle Shower → **EV24**, party WO12 Skill Rule → **WO14**.
- **Cost.** S / M / L, the implementation effort.

**Compatibility tags**

| Tag | Meaning |
|---|---|
| `grid` / `phys` | Needs `board.kind` grid / physics |
| `fall` / `nofall` | Needs a falling piece / has no falling piece |
| `floor` | Needs a fixed down axis (no gravity flip or side gravity) |
| `axis` | Changes the down axis during play (conflicts with `floor`) |
| `clr` / `noclr` | Needs clears on / clears off |
| `col` | Uses colour keys (2 or more colours in the level) |
| `tgt` | Needs target cells in the level data |
| `rect` | Needs an unmasked rectangular footprint |
| `multi` | Several boards per player |
| `shared` | Several players write one board (Parked) |
| `turn` | Piece- or move-limited, no gravity pressure |
| `rt` | Real-time pressure |
| `vs` | Multiplayer only (competitive) |
| `solo` | Single-player only |
| `coop` | Co-operative (Parked) |
| `mg` | Needs a minigame scene |
| `daily` | Allowed in the daily generator |
| `absurd` | Counts as the daily challenge's "absurd rule" |
| `wrap` | A ground axis wraps (no wall on it). Proposed |
| `cam` | The rule reads the camera snap. The snap reaches the sim only as the recorded `view_snap` command (ADR-0014 §6), so replays stay deterministic. Proposed |
| `face` | Needs tilt and roll (the 3rd rotation pair, Flip / Roll, taught in meadow_02). Proposed |
| `tourney` | Tournament rounds only; off in quick versus, which allows sidegrades only (decision sheet). Used for edges (BL20, IN26, EV22) and team-up events (GO30, IN31). Proposed |
| `stack` | The rule moves or removes locked cubes or changes the stack's structure (belts, ants, stack flip, rider junk). Lana's Stitch vetoes these writes (Skills rule 14, framework rule 11a). Proposed |

**Runtime alignment (ADR-0004, ADR-0011).** Every atom that changes the board, the piece, the queue, goals or score is a slot plugin or a `RuleBehaviour` inside `BoardSim` and writes only through `RuleApi`. Player intent (verbs, undo, a camera snap) arrives as a `SimCommand`; a rule never queues one. Beehave trees are **staging only**: they read `SimEvent`s and drive animation, and removing them never changes an event or `state_hash()`. A rule's layer sets its rank and its F3 cost: `mascot` 1 and `content` 2 do not count toward the twist/mechanic budget; `twist` 3 (≤ 2) and `mechanic` 4 (≤ 1) do (ADR-0011 §2, `rule_layers.json`). Tags are the `requires` / `provides` vocabulary of `assets/data/atom_tags.json` (ADR-0004 §2), and the four new tags above must be added there before a Proposed atom using them is built.

### 2. The atom library

#### Slot 1. Board / Layout: hook `board.kind`, `layout.kind`, mask, `starting_contents`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| BL01 | Box | W×D×H grid, default 6×6×10 | Tetris | grid daily | S | D (board-grid) |
| BL02 | Masked floor | Donut, plus, stairs or picture-shaped footprint | Candy board shapes | grid daily | S | D (level-data) |
| BL03 | Well | Narrow, tall bottle (3×3×12 or 4×4×10) with "neck" spawn cells | Dr. Mario | grid floor daily | S | C |
| BL04 | Tubes | Row of 1×1 or 2×2 columns, each with capacity H | Ball Sort | grid col | S | C |
| BL05 | Pre-built tower | Level starts with a placed stack | Jenga, Boom Blox | grid daily | S | D ([level-data-definition](level-data-definition.md) `starting_contents`; meadow_02, 07, H1, H2) |
| BL06 | Strip | Long 8×3 lane with cliffs at both ends | Fall Guys course | grid | S | C |
| BL07 | Islands | Several small boards; the player picks where each piece goes. Meadow remix "Two Fields" = 2 boards | Tricky Towers, Mario Party boards | multi | M | D (ADR-0002 §7, layout) |
| BL08 | Track | Chain of boards; finishing one moves you to the next | Fall Guys race | multi rt | L | C |
| BL09 | Shared tower | 2–4 players build one board, each in their own colour | Overcooked, Tetris Effect Connected | shared coop | L | P |
| BL10 | Tray | Small moving board that catches pieces | MG15 Catch Tower | grid | M | D (tournament-minigames) |
| BL11 | Turntable | The stack turns 90° every N locks | catalog B1 | grid | M | D (MG12) |
| BL12 | Shrinking floor | Rim cells crumble on a timer; the footprint shrinks | Hex-A-Gone, Block Party | grid rt | M | C |
| BL13 | Physics plate | Real physics tower | Tricky Towers | phys | L | D (physics-mode) |
| BL14 | Creature back | The board rides a creature (turtle, whale, sleepy cat). Every `creature_step_locks` it takes a step: the stack shifts one cell (wrap off) or the camera bobs; telegraphed by the creature's head turning | world research | grid floor | M | C |
| BL15 | Stage medley | A level of 2–3 short stages, each its own mini-recipe; finishing a stage swaps the board with a fanfare | level research, WarioWare | grid | M | C |
| BL16 | Seesaw board | The board sits on a pivot. Mass left and right of centre tilts it; past `seesaw_max` degrees a lip of cubes slides off | Tricky Towers, Boom Blox | phys | L | C |
| BL17 | Canopy shelf | A fixed shelf at `shelf_y` covers the footprint except its `openings`. Shelf cells support pieces but never clear; a piece over an opening falls through to the floor below | puzzle proposal | grid floor | M | Pr |
| BL18 | Carved cavern | A per-cell **volume** mask: inactive rock cells anywhere (arches, stalactites, pillars). A layer is full when its active cells are full | Picross 3D, cave puzzles | grid | M | Pr |
| BL19 | Wrap board | Leaving the board on `wrap_axis` re-enters on the opposite side; pieces may straddle the seam | Pac-Man wrap | grid wrap | M | Pr |
| BL20 | Handicap footprint (party proposal BL17) | Each player's footprint is set by tournament rank at round start: leader 6×6, middle 5×5, last 4×4. Clear-goal rounds only | Mario Kart rubber band | grid vs tourney | S | Pr |

#### Slot 2. Arrival / Piece source: hook `spawn.arrival`, `spawn.router`, Spawner knobs

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| AR01 | Top drop | Falls from above | Tetris | fall daily | S | D (fall-drop-lock) |
| AR02 | Side then fall | Enters from a wall (M9) | — | fall | M | D (level-specific-mechanics) |
| AR03 | Slide-in | Glides in; tap to drop (M10) | Stack | fall rt daily | S | D (level-specific-mechanics) |
| AR04 | Two-way meet | Alternates between two walls (M11) | — | fall | M | D (level-specific-mechanics) |
| AR05 | Crane | Swinging crane; tap to release | Tower Bloxx | fall rt | M | D (MG5) |
| AR06 | Sky lanes | Random lanes with a floor shadow | MG15 | fall rt | M | D (MG15) |
| AR07 | Tray of three | Drag 1 of 3 pieces onto any cell. No gravity; the tray refills when all 3 are used | Block Blast, Woodoku | nofall turn daily | M | C |
| AR08 | Shelf draft | Pick 1 of 3; it then falls (catalog A6) | — | fall daily | S | C |
| AR09 | Fixed list | Set piece sequence, puzzle style (Picnic Puzzle) | Tricky Towers puzzle | turn daily | S | D (campaign bonus level) |
| AR10 | Rising feed | A row of seeded cubes pushes up from below every N s; chains pause it | Panel de Pon | grid floor rt | M | C |
| AR11 | Bi-colour pieces | Each piece's cubes carry 2 colour keys | Puyo pair, Dr. Mario, Lumines | col daily | S | C |
| AR12 | Shared belt | Pieces ride a belt past all players; the first to grab takes it | Overcooked | shared coop | M | P |
| AR13 | Kit box | All the level's `kit` pieces are shown in a box. Pick any, in any order, each once; it then falls | Tricky Towers puzzle, packing puzzles | fall turn | S | Pr |

#### Slot 3. Control / Verb: hook Movement and Touch knobs + vetoes; `control.verb` slot (ADR-0004 `ControlVerb`)

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| CV01 | Move + 3-axis rotate | The base verb | Tetris | fall daily | S | D (movement-rotation) |
| CV02 | Spin only | Tilt and roll vetoed (`rotation_axes_enabled`) | — | daily | S | D (rule-twist-framework) |
| CV03 | Tap to release | Timing is the only skill | Stack | rt daily | S | D (M10) |
| CV04 | Swap | Swap two face-adjacent locked cubes | Panel de Pon, Candy | grid col | M | C |
| CV05 | Tap-pop | Tap a same-colour group of ≥ `tap_pop_min` to pop it | Toon Blast | grid col | S | C |
| CV06 | Pull and re-place | Remove one locked piece below the top layer; it must be dropped on top | Jenga | grid/phys | M grid / L phys | C |
| CV07 | Chisel | Tap cubes away from a solid block to reveal a shape | Picross 3D | grid tgt nofall | M | C |
| CV08 | Tube move | Lift a tube's top piece onto a matching colour or an empty tube | Ball Sort | grid col turn | S | C |
| CV09 | Board slide | Swipe: the whole stack slides one way until blocked | 2048 | grid | M | C |
| CV10 | Swipe sort | Fling the piece into a bin | MG9 | mg | S | D (MG9) |
| CV11 | Steer tray | Move the board, not the piece | MG15 | — | M | D (MG15) |
| CV12 | Zone | A meter fills from clears; tap to freeze gravity for `zone_ms` | Tetris Effect | fall clr | S | C |
| CV13 | Throw | Flick the piece in an arc at a target column. It lands on the column's top surface; a miss lands on the nearest valid column | Boom Blox, world research | grid fall | M | C |
| CV14 | Push cube | Tap a locked cube: it slides one cell away from you along the floor into the next empty cell. It can push one other cube, never off the edge | Sokoban, ROTA, PuzzleScript | grid floor turn | M | C |
| CV15 | Gravity nudge | Tap to rotate the down axis 90° for the whole stack; one use per `gravity_nudge_cd` locks. Player-driven (EV03 is a rule event; BL11 turns the stack on a timer) | ROTA | grid fall axis | M | C |
| CV16 | Tilt charges | Variant of CV15: 1–3 `tilt_charges` per level; each one rotates the down axis 90° for the current piece only | ROTA | grid fall axis | M | C |
| CV17 | Twist a layer | Tap a layer's handle: that layer's cubes turn 90° about the board's vertical centre axis. `layer_twist_charges` per level; only layers below the falling piece. Needs a square, 90°-symmetric footprint | Rubik's Cube | grid floor | M | Pr |
| CV18 | Curling flick | During lock delay, one flick slides the landed piece along a ground axis until it is blocked. Over a gap it drops and the flick ends | curling, ice puzzles | grid fall | M | Pr |
| CV19 | Choose your down | Before release, a swipe picks the piece's fall direction (down, ±x or ±z); it falls to that wall. Cube board 6×6×6 | 3D gravity puzzles | grid fall axis | L | Pr |

#### Slot 4. Placement rule: hook rule vetoes on `board.write` / `on_lock` behaviours

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| PL01 | Sticky landing | Locks on first touch (M3) | — | fall daily | S | D (level-specific-mechanics) |
| PL02 | Overhang trim | Unsupported cubes snap off (catalog P1) | Stack | floor daily | S | C |
| PL03 | Wobble | Meadow 05 "Tall Tower". Overhangs build sway; past the limit the top piece slips (catalog P2) | Tower Bloxx | grid floor | M | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §1) |
| PL04 | Laser line | No cube may rest above the line | Tricky Towers puzzle | floor daily | S | C |
| PL05 | Same-colour touch | A piece must touch its own colour (the first piece is free) | Dominoes | col absurd daily | S | C |
| PL06 | Crosswise | Each layer's long axis turns 90° from the one below | Jenga | floor absurd | S | C |
| PL07 | Inside the outline | Cubes outside the target cells fade out (no penalty, no use) | Picross, Box Packers | tgt | S | C |
| PL08 | Hot cells | Marked cells burn any cube placed on them | Fall Guys hazards | grid daily | S | C |
| PL09 | Fit or bonk | The piece must pass the hole (MG1) | Hole in the Wall | mg | M | D (MG1) |
| PL10 | Pond mirror | On lock, a twin copy is written mirrored across the centre plane, then drops rigidly until supported; twin cells that are taken are skipped | mirror puzzles | grid | M | Pr |

#### Slot 5. Clear / Match: hook `clear.detector`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| CL01 | Layer | Full layer | Tetris | grid daily | S | D (layer-clearing) |
| CL02 | Row | Full row inside a layer (M8) | Tetris, Woodoku | grid daily | S | D (M8) |
| CL03 | Column | Full vertical column (catalog C5) | — | grid daily | S | C |
| CL04 | Ring | Outer ring of a layer (catalog C6) | — | grid rect daily | S | C |
| CL05 | Colour pop | ≥ N face-connected of one colour (M5) | Puyo | col daily | M | D (M5) |
| CL06 | Colour bridge | A path between two posts (M6) | — | col | M | D (M6) |
| CL07 | Mono layer | A full one-colour layer gives a bonus blast (M7) | — | col daily | S | D (M7) |
| CL08 | Colour line | ≥ 4 in a straight line of one colour | Dr. Mario, Candy | col daily | S | C |
| CL09 | Cube block | A solid 2×2×2 of one colour (catalog C7, coloured) | Lumines squares | col | M | C |
| CL10 | Sweep | Matches are only marked; a plane sweeps on the beat and clears them | Lumines | col rt | M | C |
| CL11 | Zones | A layer is split into 3×3 (or 2×2) zones; a full zone clears | Woodoku | grid rect daily | S | C |
| CL12 | Merge | Two equal-tier pieces that touch fuse into one next-tier piece | Suika, 2048 | grid daily | M | C |
| CL13 | Sealed tube | A full one-colour tube seals and clears | Ball Sort | col | S | C |
| CL14 | None | Clears off | — | noclr daily | S | D (M1, M2) |
| CL15 | Wall clear | A full vertical slab (all active cells with x = k, or z = k, in layers 0 to `wall_h` − 1) clears | 3D block puzzles | grid | M | Pr |
| CL16 | Looks full | At the current camera snap, a row whose **front silhouette** is full (each cell has a cube at some depth) clears its front skin | Fez | grid cam | L | Pr |

#### Slot 6. Collapse: hook `clear.collapse`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| CO01 | Slice | Rigid slices drop | Tetris | clr daily | S | D (layer-clearing) |
| CO02 | Cascade | Cubes fall freely and can chain | Puyo | clr daily | S | D (layer-clearing) |
| CO03 | None | Holes stay | — | clr daily | S | D (layer-clearing) |
| CO04 | Push down | Cleared layers pile up as gold "bonus floor" at the bottom until the Zone ends (needs CV12) | Tetris Effect | clr | M | C |
| CO05 | Refill | New seeded cubes rain into the gaps from the top | Candy, Toon Blast | clr col | M | C |
| CO06 | Launch | The cleared group rockets up, carrying the cubes above it. The biome's `lift` decides whether they escape or fall back | Meteos | clr | M | C |
| CO07 | Topple | Unsupported pieces tip over | Tricky Towers, Boom Blox | phys | L | C |
| CO08 | Pour | A "liquid" piece does not lock as a solid: it spreads sideways and down into the lowest open cells, then sets as a flat layer | The Powder Toy | grid fall | M | C |
| CO09 | Close the gap | After a wall clear (CL15), cubes beyond the cleared slab slide one cell toward the `anchor` wall; cubes above it fall (CO01) | 2048 | clr | S | Pr |

#### Slot 7. Goal / Win: hook `goal.type`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| GO01 | Clear N | Clear N layers (or groups) | Tetris | clr daily | S | D (level-goals) |
| GO02 | Height | Reach height H | Tricky Towers race | daily | S | D (M1) |
| GO03 | Fill shape | Cover the target cells (M2) | — | tgt daily | S | D (M2) |
| GO04 | Survive | Last T seconds | Tetris marathon | rt daily | S | D (level-goals) |
| GO05 | Score in time | Best score in T | arcade | daily | S | D (level-goals) |
| GO06 | Orders | Collect N cubes of colour X and N objects (order card) | Candy, Royal Match | col daily | S | C |
| GO07 | Rescue all | Clear every critter or jelly cell | Dr. Mario, Candy jelly | daily | S | C |
| GO08 | Treasure down | Bring the treasure cube(s) to the floor | Candy ingredients | floor clr | M | C |
| GO09 | Shadow match | Match front and side silhouettes (catalog G1) | Picross | tgt | M | D (MG10) |
| GO10 | Mascot path | Build a path the mascot can walk (catalog G2) | — | — | M | D (MG6) |
| GO11 | Perfect box | Fill a box with no holes (catalog G3) | — | tgt | M | D (MG7) |
| GO12 | Copy model | Rebuild a model from memory | — | tgt | M | D (MG2) |
| GO13 | Top tier | Merge up to the golden Giant piece | Suika | grid | M | C |
| GO14 | Last standing | Survive the elimination | Fall Guys | vs | S | D (MG13) |
| GO15 | Picture reveal | Fill the outline until a voxel critter appears | Picross 3D | tgt daily | M | C |
| GO16 | Theme build + vote | Build to a prompt in T s; rivals vote (you can't vote for yourself) | Minecraft Build Battle | vs mg | M | C |
| GO17 | Team quota | Shared order rail filled by the team | Overcooked | coop | M | P |
| GO18 | Pull count | Pull N pieces without toppling | Jenga | — | M | C |
| GO19 | Order rush | A shared rail shows 3 orders (a small pattern to build in one layer). The first player to build an order claims it, and a new one appears | Overcooked, made competitive | vs | M | C |
| GO20 | Critter walkers | Critters walk along the top surface, turn at walls and step up or down ≤ 1. Guide `walkers_needed` of them to the exit | Lemmings | grid floor | M | C |
| GO21 | Dig to rescue | Clear down to free buried critters (catalog G4) | Dr. Mario, Mr. Driller | clr daily | S | C |
| GO22 | Sculpt reveal | Start from a full block; clears carve it until only the hidden figure (protected cells) remains | level research (reverse level) | clr tgt | M | C |
| GO23 | Bridge race | The first player to build a continuous cube path across the gap to the flag wins; the mascot then walks it. The vs version of GO10 | Mascot Bridge Race, Fall Guys | vs rt mg | M | C |
| GO24 | Echo | The mascot shows a sequence of 3 placements (cell and colour); repeat them in order. Each wrong step costs a heart. GO12 copies a shape; this tests order | Simon, WarioWare memory games | turn tgt | S | C |
| GO25 | Slide-clear | Clear the whole board using at most M board slides (needs CV09) | Puznic / Wizznic | grid nofall | M | C |
| GO26 | Impatient order | Variant parameter of GO06 / GO19, not a separate goal: each order's reward bar shrinks over time, so early delivery pays more (`order_decay_s`) | Hurry Curry! | — | S | C |
| GO27 | Sunbeds | A flower is lit when no solid cell lies on its ray to the sun; each lock with a flower lit adds 1 bloom. Win when every flower reaches `bloom_need` | shadow puzzles | grid tgt clr | M | Pr |
| GO28 | Layer cake | A recipe card gives a colour per layer; win when those layers are full and match. Wrong-colour cubes in a cake layer fade (PL07 style) | cake-stacking games | col noclr | M | Pr |
| GO29 | Wind the clock | Keyholes sit on the board walls. A piece's **key face** (one stamped cube face) must touch a keyhole; wind `keys_needed` | orientation puzzles | grid face | M | Pr |
| GO30 | Boss Raid (party proposal GO27) | Team-up event: everyone's clears damage one boss (1 layer = 1 hit) and the boss counter-attacks every board. Most damage wins; the killing blow is worth +`kill_bonus`. Scores stay individual | Mario Party, raid bosses | vs tourney clr | M | Pr |

#### Slot 8. Fail / Top-out: hook `goal.top_out`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| FT01 | Warnings | Top-out warnings, then fail | — | daily | S | D (level-goals) |
| FT02 | Trim | Cubes over the limit pop off; never fails | Tricky Towers race | daily | S | D (level-goals) |
| FT03 | Lose | Top-out loses at once | Tetris | — | S | D (level-goals) |
| FT04 | Shake loose | The tower shudders; unsupported cubes fall off (catalog §6) | — | floor | S | C |
| FT05 | Bonk and stun | The piece bounces off; stun `bonk_stun_ms` (catalog §6) | — | — | S | C |
| FT06 | Three hearts | Each top-out costs a heart (catalog §6) | Tricky Towers survival | — | S | C |
| FT07 | Piece budget | Out of pieces or moves = the level ends; stars come from what is left | Candy moves | turn daily | S | D ([level-goals-fail-states](level-goals-fail-states.md) rule 10c; meadow_bonus) |
| FT08 | Neck | Only blocking the spawn cells fails | Dr. Mario | fall | S | C |
| FT09 | No fit | You lose when no tray piece fits anywhere | Block Blast | nofall | S | C |
| FT10 | Topple | The tower falls (or wobble maxes out) = you lose the turn | Jenga | — | M | C |
| FT11 | Never | No fail; time and stars only | — | daily | S | C |
| FT12 | Undo & reset | Optional add-on for `turn` levels: unlimited undo of locks and a one-tap reset. Not a default: the level's Fail pick still applies, so puzzle levels can still be lost (user decision 2026-10-10) | Tricky Towers puzzle, Baba Is You | turn | M | Pr |
| FT13 | Stuck cue | Add-on for `turn` + `tgt` levels: after each lock, if the cubes left are fewer than the uncovered targets, or a target is sealed, the mascot shrugs and the retry (or FT12 reset) button pulses. Observational; never ends the level | puzzle proposal | turn tgt | S | Pr |

#### Slot 9. Scoring / Combo: hook Scoring & Stars knobs + `RuleBehaviour` on `on_clear` / `on_lock`

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| SC01 | Per clear | Base score per clear | — | daily | S | D (scoring-stars) |
| SC02 | Chain | Chain multiplier | Puyo | clr daily | S | D (M5 F9) |
| SC03 | Multi-clear | Several groups in one lock multiply | Woodoku | clr daily | S | C |
| SC04 | Perfect streak | A streak of perfect placements; at N, a reward (piece grows back, or a special) | Stack | daily | S | C |
| SC05 | Sweep combo | ≥ 4 groups in one sweep pass multiply (F4) | Lumines | CL10 | S | C |
| SC06 | Underdog finish | Points only if some but not all finish; underdog bonus | Ultimate Chicken Horse | vs | S | C |
| SC07 | Coins | Coin cells are collected by covering or clearing them | Ultimate Chicken Horse, Boom Blox gems | daily | S | C |
| SC08 | Residents | Score = how tidy and full each layer is | Tower Bloxx City | — | M | C |
| SC09 | Push your luck | After a clear, bank the points or keep building for a bigger multiplier; a top-out loses the unbanked points | Board-game push-your-luck | solo | S | C |
| SC10 | Party awards | At round end, three silly awards (Tidiest Tower, Most Bonks, Comeback Kid) each give fixed points. Rewards style; pairs with SC06 | Super Tux Party | vs | S | C |
| SC11 | On-beat lock | Locking inside the beat window gives a small bonus and a visible pulse. The scoring half of EV08 (needs EV08) | osu! | fall | S | C |
| SC12 | Final Frenzy | In the last `frenzy_s` of a round, all points count ×2, and ×3 for the trailing half; a siren and a music bump mark it. Only for `score` / `race_progress` standings | Mario Party last turns | vs | S | Pr |

#### Slot 10. Interaction / Sabotage / Items: hook minigame `interaction_hook`, Items, Buffs & Debuffs effects, `StandingFn`

All of these are competitive. Every incoming effect is telegraphed for `attack_warn_ms` (Tournament Minigames rule 7).

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| IN01 | Garbage send | Junk or grey cubes go to a rival | Tetris, Puyo | vs | S | D (MG3) |
| IN02 | Offset | Your clears cancel pending incoming garbage; the excess bounces back (F5) | Puyo | vs IN01 | S | C |
| IN03 | Target mode | Pick: leader, attackers, weakest, random | Tetris 99 | vs | S | C |
| IN04 | Badges | Knocking a rival out takes their badges; badges boost your sends | Tetris 99 | vs GO14 | S | C |
| IN05 | Gift piece | Put an awkward piece in a rival's queue | — | vs | M | D (MG8) |
| IN06 | Steal | Steal a slab or points | — | vs | S | D (MG4, MG9) |
| IN07 | Hot potato | The Hot Block | — | vs | M | D (MG14) |
| IN08 | Trap planting | Before the round, each player places one trap content on a rival's board | Ultimate Chicken Horse | vs | M | C |
| IN09 | Light or dark | Each pickup: use it on yourself (light) or send it to a rival (dark) | Tricky Towers spells | vs | S | C |
| IN10 | One vs rest | One player is the Storm (fires twists and drops on a cooldown); the rest race to build | Mario Party 1-vs-3 | vs | M | C |
| IN11 | Teams 2v2 | Paired boards share a goal and a send meter | Mario Party 2v2 | coop vs | M | P |
| IN12 | Tower swap | On a gong, every tower moves to the next player | party chaos | vs | M | C |
| IN13 | Ghost sends | Players who are out keep sabotaging | — | vs | S | D (tournament-minigames rule 10) |
| IN14 | Banana Cube | Item: the rival's next piece slides 1 cell after landing (one slip) | Mario Kart banana | vs | S | C |
| IN15 | Tickle Hand | Item: a cartoon hand tickles the rival's falling piece, which spins once on the vertical axis (telegraphed wiggle) | world research | vs | S | C |
| IN16 | Sticky Fingers | Item: steal the rival's next queued piece; they get yours | Mario Kart, party | vs | S | C |
| IN17 | Party Hat | Item: a giant party hat and confetti cover part of the rival's view for ≤ `party_hat_ms` (2 000 max), after a telegraph | party chaos | vs | S | C |
| IN18 | Comet | Rare leader-hunter: only the last-place player can roll it, and only with 3+ players. It flies to the leader and pops their top 2 layers (F8) | Mario Kart blue shell | vs | M | C |
| IN19 | Rewind | Item: undo the last `rewind_locks` locks on your own board (light) or on a rival's (dark, only their last lock) | Tricky Towers undo, world research | vs | M | C |
| IN20 | Big combo payoff | A combo ≥ `big_combo_k` triggers one of three payoffs, picked from the rule's seeded stream (F9): IN20a, IN20b or IN20c | Tetris 99, Mario Party | vs | M | C |
| IN20a | Hit the Leader | The payoff sends a telegraphed junk layer to the leader (the leader's own payoff hits 2nd) | Mario Kart | vs | S | C |
| IN20b | Chaos meter | The payoff fills a shared table meter; when it is full, a table-wide event card fires for every player | party chaos | vs | M | C |
| IN20c | Power unlock | The payoff unlocks a one-use power for you (hold, a bomb, slow time) | Tetris Effect Zone | vs | S | C |
| IN21 | Tug of war | Each clear moves a shared marker one step toward the rival's side; the first to push it to the edge wins | Mario Party tug-of-war | vs | S | C |
| IN22 | Dizzy Cam | Send: the rival's camera orbits 90° (3 of the 12 snaps); controls stay camera-relative. Once per `dizzy_cd_s` per target, never during their landing telegraph | party chaos | vs | S | Pr |
| IN23 | Crown Bounty | The leader wears a crown. A send that lands on the crown holder pays the sender +`bounty_pts` and +1 charge. Off with 2 players | party bounty games | vs | S | Pr |
| IN24 | Piñata | A piñata hangs over the leader's mini-board on every rival phone. At `pinata_hits` total taps it bursts: 3 candy junk cubes on the leader, a light item to the last hitter | Mario Party | vs | M | Pr |
| IN25 | Termite Gift | Send a termite (SP31 pest rules) onto the rival's top surface; it eats one cube per lock for `termite_locks` locks; a clear next to it removes it | party chaos | vs | S | Pr |
| IN26 | Underdog Tailwind | Gravity scales by rank: last place falls `tw_max` slower, the leader `tw_max` faster, linear between (hard cap 0.15, the perk edge cap) | Mario Kart rubber band | vs tourney | S | Pr |
| IN27 | Revenge Meter | Every send you receive fills your meter; when full, a free send auto-fires at whoever hit you most this round | fighting-game meters | vs | S | Pr |
| IN28 | Slipstream | Within `draft_gap` of the leader's standing, your sends charge `draft_bonus` faster; a ribbon trails the leader | racing drafting | vs | S | Pr |
| IN29 | Piece Dealer | One vs rest: the Dealer picks 1 of 3 for each builder's next piece within `deal_ms` (else a seeded auto pick). The Dealer scores per hole or warning caused | Mario Party 1-vs-3 | vs | M | Pr |
| IN30 | Monster on the Table | One vs rest: one player is the biome boss and taps a rival mini-board cell to stomp it after a 1 s shadow (FT04 shake-loose on 3×3). Builders score height; the Monster scores cubes knocked off | Mario Party 1-vs-3 | vs mg | L | Pr |
| IN31 | Truce Pact | Team-up event: if the leader's lead exceeds `truce_gap`, the two lowest players pair for `truce_s`. Their sends all go to the leader and share one meter. Scores stay individual; 3–4 players only | party alliances | vs tourney | M | Pr |
| IN32 | Skill Clash | Two skills fired at each other within `clash_ms` cancel into confetti; both players get half their charge back | party chaos | vs | S | Pr |
| IN33 | Skill Echo | Being hit by a rival's skill charges your own skill by `echo_charge`. Only under the WO14 `charge` rule | fighting-game meters | vs | S | Pr |

#### Slot 11. Modifiers / Events: hook `RuleBehaviour` twists (layer 3) and level mechanics (layer 4)

**Biome events are fightable.** Every biome event atom declares a `counter`. HUD shows the counter icon with the event telegraph. The four counters:
- **Clear to cancel**: a clear during the telegraph cancels the event (example: storm cloud).
- **Feed the mascot**: drop a piece of the asked colour on the mascot's pad and it eats the event (example: hungry dragon breath).
- **Use it**: the event can be turned to your advantage (example: a geyser that lifts a piece onto a high ledge).
- **Ride it out**: the event is short and harmless if you build well (example: a quake that only shakes loose overhangs).

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| EV01 | Wind | Gusts push the falling piece (T1) | — | fall daily | S | D (twist-library) |
| EV02 | Invisible blocks | Locked blocks fade (T2) | — | daily | S | D (twist-library) |
| EV03 | Gravity flip | The down axis flips (T3) | — | — | M | D (twist-library) |
| EV04 | Spawned objects | Objects appear on the top surface (T4) | — | daily | S | D (twist-library) |
| EV05 | Conveyor | The stack shifts each lock (M4) | — | rect | M | D (M4) |
| EV06 | Lava and lid | The floor melts up, or a lid lowers (catalog B4, G5) | Fall Guys | floor rt | S | D (MG13) |
| EV07 | Junk rise | A junk layer pushes up every N locks (catalog A7) | Panel de Pon | floor | S | C |
| EV08 | Beat tempo | Gravity steps and the sweep follow the music's BPM. Its scoring half is SC11 | Lumines, Tetris Effect | rt | M | C |
| EV09 | Ice | Landed pieces slide 1 cell along the camera-forward axis | Tricky Towers dark spell | fall absurd daily | S | C |
| EV10 | Balloon | One piece floats at ½ gravity and may drift up 1 | Tricky Towers dark spell | fall absurd daily | S | C |
| EV11 | Goo spread | Each lock, goo takes over one cube next to it unless a clear happens next to the goo | Candy chocolate | grid | M | C |
| EV12 | Quake | Every N s, shake loose (FT04 logic) | — | floor | S | C |
| EV13 | Halftime swap | At half time the rule card flips to a second rule set | Fall Guys, WarioWare | — | M | C |
| EV14 | Rule cubes | Word cubes (`RED`, `IS`, `BOMB`, …) arrive as pieces. Lining up a sentence in one row sets that rule until the row is broken. Sentences come from a closed list | Baba Is You | grid absurd | L | C |
| EV15 | Mystery event card | Every `event_card_locks` locks a card flips and plays a random event from the level's pool (seeded) | level research, party games | absurd daily | M | C |
| EV16 | Biome event | One biome-themed event with a telegraph and a `counter` (above) | world research | daily | M each | C |
| EV17 | Speed-up bump | Each completed stage, or every `bump_locks` locks, raises gravity one notch with a clear cue (EV08 follows the music; BL15 is the stage wrapper) | WarioWare | rt | S | C |
| EV18 | Lift tiles | A few marked floor cells rise and sink on a short cycle, so the same drop lands one cell higher or lower depending on timing | Puznic / Wizznic lifts | grid fall | M | C |
| EV19 | Nanogame interlude | Every `nanogame_every` pieces the board freezes for a 5-second one-tap challenge (tap the bubble, stop the spinner). Win: the next piece is a free pick. Lose: nothing happens | Librerama, WarioWare | grid | M | C |
| EV20 | Pistons | Wall pistons each face one row. Every `piston_locks` each pushes its row one cell inward if the row has an empty cell, else it jams. Counter: use it | Clockwork puzzles | grid floor | M | Pr |
| EV21 | Spotlight Duel | A spotlight picks 2 players (the leader plus one weighted to the trailers); the first of the two to clear within `duel_s` steals `duel_pts` from the other | party showdowns | vs | S | Pr |
| EV22 | Gift Rain | A gift box (SP37) lands on each player's top surface; a clear next to it opens it. Contents are rank-weighted (trailers get better items) | Mario Kart item boxes | vs tourney | S | Pr |
| EV23 | Skill Surge | Table event: every player's skill is ready at once for `surge_s`. At most 1 per round | party chaos | vs | S | Pr |
| EV24 | Sprinkle Shower (party proposal EV20) | For `shower_s` every player gets only Mono pieces at ×2 gravity; each lock scores +1. Counter: use it | WarioWare | vs | S | Pr |

#### Slot 12. Special pieces and objects: hook content JSON + optional `RuleBehaviour`

**Pieces** are a whole falling Piece Set shape with a property. **Objects** are single cells or overlays.

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| SP01 | Bomb | 3×3×3 blast when cleared or when its fuse ends | Candy wrapped, Toon bomb | daily | S | D (obstacles) |
| SP02 | Rocket | When cleared, clears its whole line in both directions | Candy striped, Toon rocket | clr daily | S | C |
| SP03 | Colour bomb | When cleared, clears every cube of the colour it touched most | Candy colour bomb, disco ball | col clr | M | C |
| SP04 | Earned specials | A pop of ≥ 5 leaves a rocket, an L/T-shaped pop leaves a bomb, a pop of ≥ 7 leaves a colour bomb (F3) | Candy, Royal Match | col clr | M | C |
| SP05 | Special combo | Two specials touching when cleared make a super effect | Candy combos | SP02–SP04 | M | C |
| SP06 | Jelly tile | Floor overlay, removed when a cube on it clears | Candy jelly | clr daily | S | C |
| SP07 | Critter | Pre-placed creature cube; freed by a clear of its colour | Dr. Mario viruses | clr daily | S | C |
| SP08 | Ice cage | Needs 2 clears next to it | Candy blockers | clr | S | C |
| SP09 | Steel | Never clears; only a bomb removes it | Panel de Pon steel | — | S | C |
| SP10 | Grey garbage | Turns to colour, or pops, when a pop happens next to it | Puyo, Panel de Pon | col | S | D (MG3) |
| SP11 | Treasure | Must reach the floor (GO08) | Candy ingredients | floor | S | C |
| SP12 | Vines | Bind a piece to its neighbours: immune to trim, topple and shake | Tricky Towers light spell | — | S | C |
| SP13 | Giant piece | The Giant family | Tricky Towers dark spell | — | S | D (piece-set) |
| SP14 | Chemical | Two chemical cubes that touch explode | Boom Blox | daily | S | C |
| SP15 | Jewel cube | When cleared, also clears every cube of its colour connected to it | Lumines chain block | col | S | C |
| SP16 | Portal pair | A piece entering one portal comes out of the other | Royal Match portals | grid fall | M | C |
| SP17 | Undo charm | Removes your last placed piece | Tricky Towers light spell | — | S | C |
| SP18 | Hot Block | The shared hot potato | — | vs | M | D (MG14) |
| SP19 | Mushroom | The meadow spawned object | — | daily | S | D (T4) |
| SP20 | Moody cube | Living block. Its face shows a mood. Grumpy (not touching its own colour) means it does not count toward clears; a same-colour neighbour makes it happy and it counts again | living blocks | col | M | C |
| SP21 | Hatching egg | Meadow 09 "Topsy-Turvy". Living block. Hatches after `hatch_locks` into a chick cube that hops to the lowest free neighbour cell; clearing the egg first gives a bonus | living blocks | grid | M | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §5) |
| SP22 | Growing sprout | Meadow 06 "Flower Bed" (`grow_max` 1) and remix "Seed Sprouts". Living block. Grows one cube upward every `grow_locks` until capped by a cube above it | living blocks | grid floor | S | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §3) |
| SP23 | Sleepy piece | Living block. Falls at half speed. After landing it naps and does not count toward clears until a clear happens next to it | living blocks | fall | S | C |
| SP24 | Magnet block | A falling piece within `magnet_range` cells is pulled one cell toward the magnet each fall step | board tricks | fall | S | C |
| SP25 | Jelly piece | On landing, the piece squishes: one cube may slump into an empty cell directly below it | special pieces | fall floor | M | C |
| SP26 | Ghost piece | Meadow 07 "fog ghost". Passes through locked cubes until you solidify it (hard drop by default); it locks where it is (if blocked, nearest free up) | special pieces | fall | M | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §4) |
| SP27 | Rainbow piece | Its cubes count as any colour for colour clears | special pieces | col | S | C |
| SP28 | Split piece | Meadow 03 "dandelion puff". On landing, it splits into its two halves (seeded cut), which fall separately | special pieces | fall | M | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §2) |
| SP29 | Frosting | Multi-layer blocker cell: each clear next to it peels one layer (1–3) | Candy frosting | clr | S | C |
| SP30 | Lock | Locked cube: it cannot clear or move until a clear next to it unlocks it | Candy locks | clr | S | C |
| SP31 | Pest | Meadow remix "Picnic Ants". Every `ant_every_locks` locks (staggered per ant), it moves to a neighbouring cube and eats it; shooed by a clear in or next to it | Candy spreading pests | grid | M | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §6) |
| SP32 | Countdown bomb | A number counts down by 1 per lock. Clear it before 0, or it blasts junk (or costs a heart) | Candy bombs | clr | S | C |
| SP33 | Walker critter | The walking critter used by GO20 | Lemmings | grid floor | M | C |
| SP34 | Crumble cube | A locked cube dissolves `crumble_s` seconds after another cube lands on it (BL12 shrinks the rim; this is per cube) | Kenney platformer falling platforms, Fall Guys | floor rt | S | C |
| SP35 | Bounce pad | A piece landing on it hops up `bounce_h` cells and relocks one cell onward in its move direction; once per landing | 3D platformers | fall | S | C |
| SP36 | Bouncy ball | A ball bounces inside the tower for a few seconds and pops the jelly cells it touches; it ends when it leaves the board | Breakout | phys | L | C |
| SP37 | Pickup crate | A cube with a bow. When it breaks (chisel, bomb or clear), the next piece carries a pickup: a size-1 bonus cell or one free rotation. It is the carrier, not the reward | DynaDungeons | grid | S | C |
| SP38 | Ladybird piece | Two-tone cubes: top and bottom faces colour A, side faces colour B (piece-local). At lock each cube takes the colour of its face pointing up. The payoff for the 3rd rotation pair | puzzle proposal | col face | M | Pr |
| SP39 | Bubble cube | A bubble cube in a piece detaches on lock and rises through empty cells; it stops under a solid cell and becomes a Block. With open sky above it pops | bubble puzzles | grid | S | Pr |
| SP40 | Ember drill | On lock, each ember cube melts up to `drill_depth` Blocks straight below it (not a clear), then the piece drops rigidly until supported. Steel stops it | Mr. Driller | grid | S | Pr |

#### Slot 13. Secrets & Discovery: hook content + `RuleBehaviour` + Save & Profile flags

None of these ever affects stars or tournament results (fun-only, like weather of the day).

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| SE01 | Poke the mascot | Tap the mascot: it reacts. After `poke_secret_count` pokes in one level, a silly secret reaction plays | world research | daily | S | C |
| SE02 | Secret shapes | Build a hidden pattern (heart, smiley, the biome glyph) anywhere: a sparkle and a collection stamp | world research | grid | M | C |
| SE03 | Legendary piece | A very rare golden variant of a normal shape (`legendary_p`). Placing it adds it to the collection | world research | daily | S | C |
| SE04 | Hidden levels | A level that is not on the map, unlocked by a secret condition (SE02, SE05 or SE06) | world research | — | M | C |
| SE05 | Angle gems | A gem visible only from one camera snap angle; tap it to collect it. The snap reaches the sim as `view_snap` | level research | daily cam | S | D ([levels/meadow.md](../levels/meadow.md) §1 rubber duck; ADR-0014 §6) |
| SE06 | Secret exit | An alternative goal hidden in a level (for example, build onto the cloud), which opens a hidden level | Super Mario World | — | M | C |
| SE07 | Mascot wish | Once per biome, the mascot shows a thought bubble with a wish (a colour, a shape); fulfilling it gives a cosmetic | world research | — | S | C |

#### Slot 14. World & Mascot: hook `RuleBehaviour` + Mascot Reactions + Campaign data

| ID | Atom | One line | From | Tags | Cost | Status |
|---|---|---|---|---|---|---|
| WO01 | Tidiness mood | The mascot's mood follows board tidiness (F10). A happy mascot gives small help (a slower next drop); a grumpy one just pouts | world research | daily | M | C |
| WO02 | Visiting mascot | A mascot from another biome visits and brings its event (EV16) for the level | world research | — | M | C |
| WO03 | Junk comes back | Junk you cleared returns `junk_return_locks` later as a smaller pile, unless a special cleared it | world research | — | S | C |
| WO04 | Weather forecast | A small strip shows the next 2–3 events and when they arrive | world research | daily | S | C |
| WO05 | Event remix | Later biomes reuse earlier biomes' events, remixed (an Underwater current plus Meadow wind) | world research | — | S | C |
| WO06 | Mascot: helper | The mascot sometimes nudges a piece one cell toward a good spot (telegraphed) or points at a good cell | world research | — | M | C (the point half is used by Meadow tiers 1–3 as rule `mascot_hint`, ADR-0011 §5; its cell-choice rule has no owner yet) |
| WO07 | Mascot: prankster | The mascot sometimes pulls a harmless prank (spins the next piece's preview, tickles) and is always telegraphed | world research | absurd | M | C |
| WO08 | Mascot: mood swing | The mascot flips between helper and prankster, driven by WO01 | world research | — | M | C |
| WO09 | Mascot: watcher | The mascot only reacts (cheers, gasps); no gameplay effect | world research | daily | S | D (staging only, ADR-0011; [levels/meadow.md](../levels/meadow.md) §1, Meadow tier 4+) |
| WO10 | Mascot pick | Each player picks a mascot with one small, capped passive (for example, a longer preview). WO06–WO09 are the AI mascot behaviours | Variable player powers, Mario Party characters | vs | M | C |
| WO11 | Mascot catch | Up to `mascot_catches` times per level (default 1), a lock that would leave a new covered hole and clears nothing is undone: the mascot catches the piece and it returns to the spawn in its current orientation. Meadow tiers 1–3 (Pip) | Meadow design (user decision 2026-10-10) | fall | S | D ([meadow-candidate-atoms](meadow-candidate-atoms.md) §7; ADR-0011 §5) |
| WO12 | Mascot's peek | After `hint_after_retries` failed tries of a `turn` level, the mascot points (no text) at the cell and orientation of the next solution piece. Never affects stars | puzzle proposal | turn | S | Pr |
| WO13 | Skill Swap | On a gong at half time, each player's skill moves to the next player (perks stay) | party chaos | vs | S | Pr |
| WO14 | Skill Rule (party proposal WO12) | Mode or recipe override of each character skill's use rule: `charge` (from clears), `once` (per round), `consumable` or `off`. Defaults: campaign `charge`, tournament `once`, quick versus `once` with sidegrade skills only | decision sheet (skill use rule by mode) | — | S | Pr |

### 2b. Proposed atoms: hook, knobs and guards

The 42 Proposed atoms come from two 2026-10-10 proposals (game-designer: puzzle atoms; level-designer: party atoms). This table keeps what the one-line rows leave out. **Hook** follows ADR-0004 / ADR-0011: a slot plugin, a `RuleBehaviour` with its layer, content, a `SimCommand` (player intent), or minigame round data. All numbers are tunable defaults. Every incoming party effect keeps the `attack_warn_ms` telegraph and sender-colour frame (Tournament Minigames rule 7).

| ID | Hook | Knobs (default, range) | Readability cue · soft-lock guard |
|---|---|---|---|
| BL17 | board mask + content `shelf` (solid, never clears) | `shelf_y` 3 (2–5); `openings` level data, each ≥ 2×2 | Branch shelf, leaf-ringed openings; the ghost shows the fall-through. Guard: Clear-N counts any layer, and the shelf layer clears on its non-shelf cells |
| BL18 | board volume mask (ADR-0002 inactive cells, 3D) | `rock` cells level data | Layer counter shows cells left. Guard: the validator flood-fills reachability from spawn for a monomino and rejects unreachable active cells; the spawn zone is all active |
| BL19 | `board.kind` topology flag | `wrap_axis` x / z / both | Seam line; the ghost is drawn on both sides. **Needs a Board/Grid neighbour hook (ADR-0002) before it is picked** |
| BL20 | round data: footprint by tournament rank | `hc_sizes` [6, 5, 5, 4] | Sizes show on the mini-boards. Clear-goal rounds only (it inverts on height races) |
| AR13 | slot `spawn.arrival` `kit_box`; the pick is a `SimCommand` | `kit` 4–10 pieces | Box tray, used pieces greyed. Guard: a bad order runs out of pieces and the level is lost (FT07); FT12, FT13, WO12 are optional helpers |
| CV17 | slot `control.verb` add-on; `layer_twist` command | `layer_twist_charges` 2 (1–4) | Handle on the layer rim; a preview ring before commit. Guard: validator needs W = D and a 90°-symmetric mask. **Open**: the clear check after a twist with no lock (ADR-0011's sequence assumes a lock) |
| CV18 | `control.verb` add-on; `flick` command during lock delay | `flick_per_piece` 1 | Arrow ghost to the end cell. Blocked = no move |
| CV19 | `control.verb` + arrival travel dir (`set_travel_dir`, any of 6) | cube board 6×6×6; clears CL01 + CL15 | Big arrow on the piece; the wall glows where it lands. Spawn top centre only; spawn blocked = top-out |
| PL10 | `RuleBehaviour` `on_lock`, layer `twist` | `mirror_axis` x / z | Pond line; a second ghost shows the twin. Twin cubes at or above `H_play` are trimmed with a splash, never a top-out |
| CL15 | slot `clear.detector` `wall` | `wall_h` 4 (3–6); axes x / z / both | The slab outline lights when 1 cell short |
| CL16 | slot `clear.detector` `silhouette`; reads the sim's `view_k` (from `view_snap`) | `skin_depth` 1 | The front silhouette glows when 1 short; checked only at lock; the rule strip shows the active view axis. Allowed because the snap is a recorded command (user, 2026-10-10) |
| CO09 | slot `clear.collapse` `close_gap` | `anchor` −x / −z | Short slide with a dust puff |
| GO27 | slot `goal.type` `sunbeds`; flower content | `bloom_need` 3 (2–6); `sun` (0, −1, 0) intro, diagonal later; `sun_turn_locks` 0 (off) | The real directional shadow, aligned to the sun ray, **is** the rule; flowers open and close. Guard: validator rejects a flower shaded by steel or rock |
| GO28 | `goal.type` `layer_cake` + fade rule (layer `content`) | `cake` 2–5 layers | Each layer's rim tinted its flavour. Wrong cubes fade, so no layer is ever blocked |
| GO29 | `goal.type` `wind_keys`; content `key` stamp, `keyhole` wall cell | `keys_needed` | Gold key decal; the keyhole glows when the ghost's key face aligns. Guard: needs `clr` (a clear frees a covered keyhole) or FT12 in `turn` levels |
| GO30 | `goal.type` `raid_damage`; the boss is a minigame-scene object, not a shared board | `boss_hp` 6 × players; `kill_bonus` 3 | Boss HP bar; counter-attacks telegraphed. Scores individual |
| FT12 | `undo` / `reset` `SimCommand`s; the sim restores its own snapshot incl. RNG streams. **Needs two ADR-0001 command kinds** | — | Rewind animation; reset button. The Fail pick still applies (out of pieces still loses at S7) |
| FT13 | `RuleBehaviour` `on_resolve_end`, layer `mascot`; emits `stuck_cue` | — | Mascot shrug, pulsing retry/reset. False negatives allowed (cheap bound), false positives not |
| SC12 | scoring multipliers in a round window (round data) | `frenzy_s` 15 (10–30); `frenzy_mult` 2; `frenzy_trail_mult` 3 | Siren and music bump |
| IN22 | Buffs & Debuffs effect `dizzy_cam` (target's view only) | `dizzy_snaps` 1 (1–2); `dizzy_cd_s` 12 | Telegraph; never during the target's landing telegraph. Under a `cam` atom the forced snap is sent as `view_snap` like any snap |
| IN23 | `StandingFn` rank 1 + send bonus | `bounty_pts` 2 (1–5) | Crown on the leader's mini-board |
| IN24 | table event; rival taps are commands received by the host | `pinata_hits` 12 (8–20); `pinata_every_s` 30 | The leader sees the piñata fill (telegraph). Only non-leaders can hit |
| IN25 | send = content `pest` (SP31 rules) via `on_attack_received` | `termite_locks` 3 (2–5) | The leader's termite lives half as long (F2 comeback). Never eats a cube under a mascot or goal ribbon |
| IN26 | gravity knob multiplier per `StandingFn`, layer `item_buff` | `tw_max` 0.10 (0–0.15, hard cap 0.15); `tw_refresh_s` 5 | Leaves blowing on the trailing boards |
| IN27 | Buffs & Debuffs meter | `revenge_fill` 3 hits (2–5) | Meter on the HUD; the return send is the minigame's own send type |
| IN28 | send charge rate by standing | `draft_gap` 15 % of the standing range; `draft_bonus` 0.25 (0–0.5) | Ribbon trail behind the leader |
| IN29 | spawner override per target | `deal_ms` 1 500 | The Dealer sees 3 previews. Role goes to the last-placed player |
| IN30 | minigame scene param + stomp send | `stomp_cd_ms` 3 000 (2 000–6 000); `stomp_radius` 1; `stomp_lead_bonus` | 1 s shadow telegraph. Monster = last place; needs a 3-board overview HUD |
| IN31 | send routing + shared meter for `truce_s` | `truce_gap` 30 % of standing; `truce_s` 20 | Truce banner; 3–4 players only |
| IN32 | skill hook (host-received time decides) | `clash_ms` 800 (400–1 500) | Confetti burst |
| IN33 | skill hook | `echo_charge` 0.34 (0.2–0.5) | Skill button fills |
| EV20 | `RuleBehaviour` `on_resolve_end`, layer `twist` | `piston_locks` 4 (2–8); piston cells level data | Winds up one lock ahead; a jam is a steam puff and no move |
| EV21 | table event; pick from the rule's seeded stream | `duel_s` 15; `duel_pts` 3; `duel_every_s` 40 | Spotlight on two mini-boards |
| EV22 | table event; reuses SP37 + the Items roll table | `gift_rain_every_s` 45 | Gift boxes; rank-weighted contents |
| EV23 | table event on skill state | `surge_s` 6; max 1 per round | Telegraphs staggered by 300 ms (Readable Chaos) |
| EV24 | spawner override + gravity knob, layer `twist` | `shower_s` 8 (5–12) | Seeded, the same moment for all |
| SP38 | content tag `two_tone`; `on_lock` recolour, layer `content` | `colour_a` / `colour_b`; `recolour_on_flip` false | Painted faces; the ghost is tinted by the up colour |
| SP39 | content `bubble`; `on_lock`, layer `content` | `bubble_per_bag` 1 (0–2) | Dotted rise line on the ghost; a pop at the surface |
| SP40 | content tag `ember`; `on_lock`, layer `content` | `drill_depth` 1 (1–3); `ember_per_bag` 1 | Glowing underside; the ghost shows the post-melt cells |
| WO12 | `RuleBehaviour`, layer `mascot`; level `solution` list (the validator replays it to prove the level solvable). Proposal name "Pip's peek"; Pip is Meadow-only, so the biome mascot points | `hint_after_retries` 2 | Paw and faint ghost at the solution cell. The retry count is passed in at level start by `PlaySession` (ADR-0010); it is not sim state |
| WO13 | skill state swap at half time (pairs with EV13) | 1 s icon swap | Swap animation |
| WO14 | mode / recipe data `skill_rule` | per context, see the row | Skill button state |

**Still open for the Proposed set** (owners named):
- **Character-skill sources** (puzzle proposal Q3): CV17, CV18, SP39 and SP40 could double as character skills. Decide in the character-skill GDD (not started). If a skill reuses an atom, its data stays in the atom. Perks may only tune knobs within the ≤ 15% edge cap, and FT12 undo is never a perk.
- **Skill hooks** WO14, IN32, IN33, EV23 and WO13 wait for that GDD. WO14's defaults follow the decision sheet (skill use rule depends on mode).
- **Core changes** before picking: BL19 (grid wrap topology, ADR-0002), FT12 (`undo` / `reset` commands, ADR-0001), CV17 (the post-twist clear check, ADR-0011 §3).

### 3. Recipes

A **recipe** has these fields:
- `atoms`: the atom IDs.
- `context`: one of `campaign`, `minigame`, `daily` or `arcade`.
- `story`: a story card, required.
  - `premise`: one line.
  - `mascot_role`: one of WO06–WO09.
- `length_class`: minigames only.
  - `burst`: 30–60 s.
  - `standard`: 60–180 s.
  - `showpiece`: 180–240 s.
- `params`: the atoms' parameter values.

The level's design must fit its story: the premise explains why the atoms are there (Pillar "every level is a tiny story", user rule 2026-10-10).

**Required slots**: Board, Arrival, Verb, Goal, Fail. FT11 "never" counts as a Fail pick.

**Optional slots**:
- Placement, Scoring, Specials, Secrets and World have no default.
- Clear defaults to CL01; CL14 opts out.
- Collapse is required when Clear is not CL14 (CO01 default).
- Events: a recipe has at most 1 level-mechanic rule and 2 twist rules (framework F3). Slot-value atoms do not count toward that cap.

**Context rules**

| Context | Players | Interaction | Forbidden tags | Novelty budget (F1) |
|---|---|---|---|---|
| campaign | solo | none (Items only as board effects) | `vs`, `coop`, `shared`, `mg` | ≤ 2 new atoms, ≤ 4 non-default atoms; **showpiece levels in tiers 7–10: ≤ 6 non-default** (user decision 2026-10-10) |
| minigame | 2–4, **always competitive** (Kitchen Rush, R4, is the approved default). Team-up events (GO30, IN31) allowed in tournaments, scores individual | ≥ 1 IN atom required | `coop`, `shared`, `solo`; `tourney` too when played as quick versus | ≤ 3 new, ≤ 5 non-default; length 30–240 s |
| daily | solo, same puzzle for everyone | none | everything without `daily` | see §4 |
| arcade | solo | none | `vs`, `coop`, `shared` | ≤ 3 non-default |

**No drift curve** (user decision 2026-10-10). How far a recipe drifts from classic Tetris, and how much physics silliness it has, is set per level by its mechanics and difficulty. It goes up and down across the campaign, with only a general trend toward more variety. Nothing in this module ramps drift in a straight line. A gentle, near-classic level after a wild one is intended.

**Conflicts.** The validator rejects these. They extend ADR-0004 `incompatible_with`:
- `noclr` ✕ `clr`
- `nofall` ✕ `fall`
- `phys` ✕ CL02–CL13, CV04, CV05, CV07–CV09, CO04–CO06
- `floor` ✕ `axis` (EV03, CV15, CV16) and ✕ AR02, AR04
- `col` needs a colour count of 2 or more
- `rect` ✕ BL02 masks
- `turn` ✕ `rt`, unless the event is set to tick per move
- `tgt` needs target data
- CO04 needs CV12
- SC05 needs CL10
- SP05 needs at least one of SP02–SP04
- GO08 needs SP11
- GO20 needs SP33
- IN02 needs IN01
- SC11 needs EV08
- GO25 needs CV09
- GO26 needs GO06 or GO19
- `phys` ✕ CV14, CO08
- `wrap` ✕ AR02, AR04, CV09, CV14, PL03, CL04, and BL02 masks on the wrapped axis
- `face` ✕ CV02, and ✕ any level before meadow_02 in the path
- CO09 needs CL15
- FT12 needs `turn`; FT13 needs `turn` and `tgt`; WO12 needs `turn` and a validated `solution` list
- CV17 needs W = D and a 90°-symmetric mask
- IN33 needs WO14 `charge`; IN25 needs a board that allows SP31 content
- BL20 only with a clear goal; SC12 only with a `score` or `race_progress` standing; IN23 needs 3+ players; IN31 needs 3–4 players

#### The ten example recipes

`nd` is counted with the F1 count rule (bundles count 1; SE atoms and slot defaults count 0). Recipes that were over their cap were trimmed on 2026-10-10; the dropped atoms are noted, and they stay good remix candidates.

| # | Name | Context / length | Atoms | nd | Story card (premise · mascot role) |
|---|---|---|---|---|---|
| R1 | **Sky Sprint** | minigame · standard | BL08 (3 islands) · AR01 · CV01 · M1 bundle (CL14 + GO02 per island + FT02) · IN08 · SC06 | 4 (was 6 when the bundle counted 3) | "The cloud ferry leaves at sunset: build up to each island's ribbon and hop across, and plant a trap on a rival's island before you go." · watcher |
| R2 | **Toy Box Critter** | campaign | BL01 5×5×5 · AR01 · CV01 · PL07 · CL14 · GO15 · FT07 · SE05. Dropped AR08, SC04 (was 6) | 4 | "Someone hid a toy in the toy box: fill its glowing outline and see who it is." · helper |
| R3 | **Candy Cascade** | campaign (Candy, tier 8 showpiece) | BL01 6×6×7 · AR01 · CV01 · CL05 (5) · CO02 · GO06 + GO07 · SP04 · SP06 · FT07 (30 pieces). Dropped BL02 heart mask, SP08 (was 8, F1 example) | 6 | "The candy mascot spilled jelly all over the shop floor: pop colour groups to clean it before the customers arrive." · mood swing |
| R4 | **Kitchen Rush** (competitive; approved default 2026-10-10) | minigame · standard | BL01 5×5×6 per player · AR01 · CV01 · CL14 · GO19 order rush · EV11 goo · IN01 (each claimed order sends goo) · FT02 | 5 | "Lunch rush at the block café: build the orders on the rail before your rivals do, and every order you win slops goo onto their counter." · prankster |
| R5 | **Melon Merge** | arcade | BL03 4×4×10 · AR01 (small-tier pieces) · CV01 · CL12 · CO01 · GO13 · FT01. Dropped CV02, CO02, FT03; arcade only, not daily (was 6) | 3 | "The picnic jar is filling up: merge matching snacks into the golden Giant before the lid won't close." · watcher |
| R6 | **Beat Sweep** | campaign (Neon, tier 7–10 showpiece) | BL01 8×4×8 · AR11 · CV01 · CL09 + CL10 (one combined detector) · CO01 · SP15 · EV08 · GO05 · SC05 | 6 (needs the showpiece cap) | "The neon club's light-bar sweeps on the beat: build colour cubes and let the music wipe them for a ×16." · helper |
| R7 | **Wobble Pull** | minigame · showpiece | BL05 (the same tower for everyone) · AR01 (re-place on top) · CV06 · PL03 · Pull bundle (GO18 + CL14 + FT10) · IN01 (each pull adds wobble to the leader's tower). Dropped PL06, SP09 (was 8) | 5 | "Everyone got the same wobbly wedding cake: pull pieces out and stack them on top, and the last tower standing wins." · prankster |
| R8 | **Panel Clash** | minigame · standard | BL01 6×6×10 · AR10 · CV04 · CL08 · CO01 · Last-standing bundle (GO14 + FT03) · IN01 (sends grey SP10 junk as its payload). Dropped CO02, IN02, IN03, SP09 (was 10, no Fail pick) | 5 | "The block factory's conveyor won't stop pushing: swap cubes into colour lines and send grey junk to your rivals' lines." · watcher |
| R9 | **Picnic Tray** | daily (curated fallback) | BL01 6×6×2 · AR07 · CV01 · CL11 · CO01 · GO05 · FT02 · PL05 (the absurd rule) · SE03 · SC01. Dropped CL02, CO03, SC03, FT09 (was 6, no absurd rule, and FT09 broke "the daily never hard-fails") | 4 | "A calm picnic on the meadow: lay snacks from the tray on the blanket, every snack must touch its own kind, and full squares vanish into the ants' basket." · watcher |
| R10 | **Storm Keeper** | minigame · burst | BL07 (one island per builder) · AR01 · CV01 · M1 bundle (CL14 + GO02 + FT02) · IN10 (Storm fires EV01, EV09, SP13) · IN13 | 4 | "One player is the weather god for a minute: everyone else races to the ribbon while the storm throws wind, ice and giant blocks." · prankster |

#### Tournament round recipes (party proposal, 2026-10-10)

Context `minigame`, played in tournaments. Party-skill length guideline is 30 s–2 min; T8 is the only showpiece. Atom ids use the renamed numbers. The biome "party twin" levels in the same proposal are for the biome-outline writer and are not listed here.

| # | Name | Length | Atoms | Rule card | Story card (premise · mascot role) | nd / new |
|---|---|---|---|---|---|---|
| T1 | **Piñata Party** | burst 45 s | BL01 5×5×8 · AR01 · CV01 · CL01 · CO01 · GO05 · FT02 · IN24 · IN23 | "Clear layers for points; whack the leader's piñata." | "Birthday on the hill: the winner wears the crown, and everyone else wants a whack at their piñata." · prankster | 4 / 2 |
| T2 | **Monster Mash** (1 vs 3) | standard 120 s | BL07 one island per builder · AR01 · CV01 · M1 bundle (CL14 + GO02 H 8 + FT02) · IN30 | Builders: "Reach the ribbon." Monster: "Stomp their towers." | "The biome boss woke up grumpy: one of you is the boss, the rest build before it stomps." · watcher | 3 / 1 |
| T3 | **Card Shark** (1 vs 3) | standard 90 s | BL01 5×5×8 · AR08 · CV01 · CL01 · CO02 · GO01 (N 4) · FT06 · IN29 | Builders: "Clear 4." Dealer: "Pick their worst piece." | "The mascot's card table: the Dealer picks every piece, and everyone else tries to clear anyway." · prankster | 4 / 2 |
| T4 | **Boss Raid** (team-up, tournament only) | standard 150 s | BL01 5×5×10 · AR01 · CV01 · CL01 · CO01 · GO30 · EV16 (boss attacks; counter: clear to cancel) · FT02 · IN28 | "Clear to hit the boss; most hits wins." | "The boss built a fortress tower: knock it down, and the killing blow gets the trophy." · watcher | 4 / 2 |
| T5 | **Spotlight Showdown** | burst 60 s | BL01 4×4×10 · AR01 · CV01 · CL01 · CO01 · GO05 · FT02 · EV21 · IN06 | "Clear for points; win the spotlight duels." | "Talent show night: the spotlight keeps picking two of you for a face-off." · watcher | 4 / 1 |
| T6 | **Sprinkle Frenzy** | burst 45 s | BL01 5×5×8 · AR01 · CV01 · CL01 · CO01 · GO05 · FT02 · EV24 · SC12 · IN01 | "Clear for points; the last 15 s count double." | "The sprinkle machine broke: tiny pieces pour down, and for the last 15 seconds the café pays double." · prankster | 5 / 2 |
| T7 | **Skill Storm** | standard 120 s | BL01 5×5×10 · AR01 · CV01 · CL01 · CO01 · GO01 (N 5) · FT01 · WO14 (`charge`) · EV23 · IN32. Added the missing AR01 and CV01 | "Clear 5; skills charge from clears." | "The four heroes' training day: the sky crackles and everyone's power goes off at once." · watcher | 3 / 3 |
| T8 | **Underdog Derby** (tournament only) | showpiece 200 s | BL08 (3 boards) · AR01 · CV01 · M1 bundle (CL14 + GO02 per board + FT02) · IN26 | "Build to each ribbon and hop to the next board." | "The great tower derby: the tail-wind is on the side of whoever is behind." · helper | 3 / 2 |

Recounts against the proposal: T2 and T8 drop to 3 with the M1 bundle; T3 is 4 (GO01 is the default); T7 is 3. All eight fit the minigame cap (≤ 5 nd, ≤ 3 new). T4 and T8 use `tourney` atoms, so they are never offered in quick versus.

#### Recipe → level JSON

Each atom maps 1:1 to a field of the ADR-0005 level file:

| Atom kind | Becomes |
|---|---|
| Slot-value atom | A `knobs` slot entry (`clear.detector`, `clear.collapse`, `spawn.arrival`, `spawn.router`, `goal.type`, `goal.top_out`, `board.kind`, proposed `control.verb`) or `layout.kind` |
| Rule atom | `mechanic` or `twists[]` with params |
| Content atom | `starting_contents` or a spawn rule |
| Interaction atom | Minigame data `interaction_hook` / item whitelist |
| Secret / world atom | A rule plus Save & Profile flags |

`recipe` is an optional block kept for the editor panel, the daily generator and design review; the runtime ignores it. Example (R3; knob names are illustrative until the knob JSON files are written):

```json
{ "id": "candy_08", "layout": { "kind": "single" },
  "board": { "width": 6, "depth": 6, "h_play": 7,
             "starting_contents": [ { "cell": [2,0,3], "content": "jelly_tile" } ] },
  "knobs": { "clear.detector": "colour_connect", "clear.collapse": "cascade",
             "goal.top_out": "piece_budget", "spawn.arrival": "top" },
  "mechanic": { "id": "earned_specials", "params": { "rocket_at": 5, "colour_bomb_at": 7 } },
  "twists": [],
  "goal": { "type": "orders", "piece_budget": 30,
            "orders": [ { "content": "jelly_tile", "count": 6 }, { "colour": "berry", "count": 20 } ] },
  "recipe": { "context": "campaign", "showpiece": true,
              "atoms": ["BL01","AR01","CV01","CL05","CO02","GO06","GO07","SP04","SP06","FT07"],
              "story": { "premise": "The candy mascot spilled jelly all over the shop floor.",
                         "mascot_role": "mood_swing" } } }
```

### 4. Daily challenge generator

The daily challenge spawns one mini-level from the box. It is the same puzzle for everyone, seeded by the date (ADR-0006).

1. **Fixed atoms**: CV01 (verb), FT11 or FT02 (fail; the daily never hard-fails), SC01.
2. **Randomised slots**, drawn from atoms tagged `daily` with weights `daily_weight`:
   - Board: BL01 or BL02, size 4×4 to 6×6.
   - Arrival: AR01 70%, AR03, AR07, AR08 or AR11.
   - Clear and its compatible Collapse.
   - Goal: from the solo pool, with a target sized by F2.
   - **One absurd rule**: one atom tagged `absurd`.
   - **0–1 extra**: one special object or one EV16 biome event.
   - **Mystery box**: SE03 or SE05 placement.
3. **Readability budget**: at most 4 non-default atoms, counting the absurd rule. Only atoms taught in the Meadow or Candy biome, or self-explaining atoms (tag `daily`), may appear.
4. **Validation**: the draw runs the normal validator and conflict checks. On a failure the generator rerolls the failing slot, up to `daily_rerolls` (20) times, then falls back to the curated recipe list `daily_fallbacks`.
5. **Story card**: generated from the biome of the day plus the absurd rule's template line (for example, "Today in the meadow, every piece is a little sleepy."). The mascot role is drawn from WO06–WO09.
6. **Never affects** campaign stars (Points rule: stars only for campaign levels). Its rewards follow the Round 4 decision (mystery box).

## Formulas

### F1. Novelty budget

`new = |{a ∈ recipe : a not met before in this context's path}|`; `nd = |{a ∈ recipe : a ≠ slot default}|`

Valid if `new ≤ new_max[context]` and `nd ≤ nd_max[context]`.

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| new_max | int | 0–4 | data | campaign 2, minigame 3, daily 1, arcade 2 |
| nd_max | int | 1–6 | data | campaign 4 (6 for `showpiece` levels in tiers 7–10), minigame 5, daily 4, arcade 3 |

"Met before" in the campaign means the atom appeared in an earlier level of the path order. Minigames count every atom not used by the base game as new.

**Count rule** (clarified 2026-10-10). The validator counts `nd` and `new` this way:
1. **Goal and Fail picks count.** They are required slots, but a pick other than the slot default counts 1, like any other slot. Slot defaults count 0: BL01 (any size), AR01, CV01, CL01, CO01, GO01, FT01.
2. **A bundle counts 1**, for `nd` and for `new`. A bundle is a goal plus the Clear and Fail picks its own rule names, so the player reads it as one idea (`design/levels/meadow.md` budget note):

| Bundle | Atoms | Source |
|---|---|---|
| M1 Build race | GO02 + CL14 + FT02 | Level-Specific Mechanics M1 |
| M2 Fill shape | GO03 + CL14 | Level-Specific Mechanics M2 |
| Pull | GO18 + CL14 + FT10 | this module (until a Pull GDD exists) |
| Last standing | GO14 + FT03 | MG13 |
| Combined detector | two Clear atoms the detector plugin reports as one (CL02 + CL11, CL09 + CL10) | Edge Cases, combined detectors |
| Compound goal | two Goal atoms on one goal card (GO06 + GO07) | this formula's example |

   Only bundles in this table count as 1. A new bundle is added here by the game-designer, never ad hoc in a recipe.
3. **Not counted**: Secrets (SE, fun-only, never affect results); the story card's `mascot_role` field (it is a field, not a pick; WO06–WO08 picked as rules do count); the daily's fixed frame (CV01, FT11 or FT02, SC01).
4. **Optional add-ons count**: FT12 undo, FT13 stuck cue and WO12 peek are non-default picks. Puzzle (`turn`) levels have no special default Fail (user decision 2026-10-10: they can be failed).

**Example**: R3 (with CL05 met in Candy 2 and SP06 in Candy 3). The original pick was BL02, CL05, CO02, GO06 + GO07 (compound goal, 1), SP04, SP06, SP08, FT07 = 8.
- As a tier-4 level that is over nd_max 4.
- As the tier-8 showpiece (`candy_08`) it is still over 6, so SP08 and the BL02 mask were dropped (§3 table): 6, which is legal.
- New atoms: SP04 = 1, which is legal.

**Example**: R1 Sky Sprint. Listed atom by atom it is BL08, CL14, GO02, FT02, IN08, SC06 = 6, over the minigame cap. With the M1 bundle it is BL08, M1, IN08, SC06 = 4, which is legal.

### F2. Daily goal sizing

`target = round(k_goal × est(goal, board, pieces_expected))`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| k_goal | float | 0.4–0.9 | data | Fraction of the estimate; default 0.6 (easy daily) |
| est | int | — | Level-Specific Mechanics F2/F3, Layer Clearing estimates | Expected clears, height or cells for the board in `daily_t_s` (180 s) |

**Example**: Clear-N on 5×5 with an estimate of 10 layers in 180 s → target 6.

### F3. Earned specials (SP04)

For a cleared colour group G with |G| cubes:
- If |G| ≥ `colour_bomb_at` (7): spawn SP03.
- Else if G spans 2 axes with ≥ 3 cubes on each (an L/T): spawn SP01.
- Else if |G| ≥ `rocket_at` (5): spawn SP02, aimed along G's longest axis.
- Otherwise: nothing.

The special appears at the cell of G nearest the last-locked cube. **Example**: a pop of 6 in a straight line gives a rocket along that line.

### F4. Sweep combo (SC05)

`m(k) = min(sweep_mult_max, sweep_mult_base × 2^(k − 1))` for the k-th consecutive pass that clears ≥ `sweep_combo_min` (4) groups. `k` resets on a pass below the minimum.

Defaults: base 4, max 16. **Example**: three combo passes in a row → ×4, ×8, ×16.

### F5. Offset (IN02)

`net = pending − sent`. If `net ≥ 0`, the pending garbage becomes `net`. If `net < 0`, pending = 0 and `−net` is sent to the target.

**Example**: 5 pending, your chain sends 7 → 0 pending and 2 go out.

### F6. Merge tiers (CL12)

Tier ladder t = 1…6:

| Tier | Piece | Cubes c(t) |
|---|---|---|
| 1 | Mono | 1 |
| 2 | Domino | 2 |
| 3 | Tri | 3 |
| 4 | Tetra | 4 |
| 5 | Chunky 2×2×2 | 8 |
| 6 | Golden Giant | 12 |

Two touching tier-t pieces merge into one tier-t+1 piece, placed at the lower piece's position and nudged up to the nearest free fit. Merges are checked in Resolving and may chain (`max_hook_depth` caps them). **Example**: two tetras merge (8 cubes in), one chunky comes out (8 cubes), so the stack never grows from a merge.

### F7. Countdown bomb (SP32)

`n_after = n − 1` per lock of the board's owner. At `n = 0` it blasts `cd_blast_junk` (1) junk layer, or costs a heart under FT06. Start value `cd_start` (8; range 4–15).

### F8. Comet roll (IN18)

The Comet is in the roll table only if `rank = P` and `P ≥ 3`. In that case `p_comet = comet_p` (0.05). At most one Comet may be in flight per round (`comet_cap` 1). Damage: the leader's top `comet_layers` (2) layers pop, telegraphed for `attack_warn_ms`. **Example**: 4 players, last place opens an item: 5% chance of a Comet.

### F9. Big combo payoff (IN20)

Triggered when one lock's clear groups plus chain ≥ `big_combo_k` (4). The payoff is drawn from the rule's stream with weights `w_hit / w_chaos / w_power` (40 / 30 / 30). The chaos meter fills by 1 per payoff; at `chaos_meter_max` (6) an event card fires for the whole table and the meter resets.

### F10. Tidiness (WO01)

`tidy = 1 − holes / max(1, filled)`. `holes` = empty cells below any locked cube in the same column; `filled` = locked cubes.

Mood bands: happy if tidy ≥ 0.9, neutral if ≥ 0.7, otherwise grumpy. **Example**: 40 cubes and 3 holes → 0.925, happy.

## Edge Cases

- **A recipe names an unknown atom ID**: validation error (the editor panel highlights it).
- **Two atoms set the same slot** (e.g. CL05 and CL08): validation error, unless the slot's plugin supports a combined list (CL02 + CL11 in R9 is allowed only if the `zones` detector also reports rows; otherwise an error). Combined detectors are opt-in per plugin.
- **A minigame recipe contains a `coop` or `shared` atom**: validation error. These atoms are Parked.
- **A minigame recipe has no IN atom**: validation error (Tournament Minigames rule 5).
- **Campaign recipe over the F1 budget**: validation warning, not an error, so a designer can make a deliberate finale. The warning is logged in the level review.
- **A daily draw keeps failing**: after `daily_rerolls` it uses `daily_fallbacks[date mod n]`. Every device uses the same date seed and the same fallback.
- **SP04 spawn cell is occupied by the next piece in the same tick**: the special takes the nearest free cell in the cleared group's footprint; if there is none, it is lost (and logged).
- **SP05: two specials of the same kind** (rocket + rocket): a cross blast along both axes.
- **CL12: three pieces of the same tier touch at once**: the two lowest merge first (lowest y, then lowest x, z), deterministic.
- **CL12: the merged piece fits nowhere**: it is placed at the nearest free fit upward; if over the limit, the recipe's Fail rule applies.
- **SP26 ghost piece solidified inside cubes**: `place_nearest_up()` (Board / Grid).
- **SP28 split halves**: if the piece is a monomino, it does not split.
- **SP31 pest with no cube next to it**: it waits. If it is enclosed with nothing to eat, it starves and pops.
- **SP32 countdown bomb inside a cleared group**: it is defused (counts as cleared, no blast).
- **IN18 Comet when the leader's tower is under 2 layers**: it pops what exists. A Shield absorbs it, as with Steal.
- **IN18 when last place and the leader swap during flight**: the target was fixed at launch.
- **IN19 Rewind across a clear**: rewind stops at the last clear (clears are never undone); if the last lock caused a clear, Rewind does nothing and is not consumed.
- **IN17 Party Hat during a telegraph of another attack**: the hat never covers the board's incoming-attack marker or the height line (Readable Chaos).
- **IN20 chaos meter fills in the same tick for two players**: one event fires; the overflow carries over.
- **EV14 rule cube sentence that contradicts a level mechanic**: the level mechanic wins (framework layer 4). The sentence glows grey ("blocked").
- **EV16 biome event countered by two counters at once**: the first resolved in tick order applies; the event ends.
- **SE secrets in a tournament**: off. Secrets are solo-only.
- **WO06 helper nudge would push a piece into a worse spot under a twist**: the nudge only runs on the frame it is telegraphed and uses `try_translate`; a blocked nudge fails silently.
- **Story card missing**: validation error for campaign and minigame recipes; the daily generates its own.
- **Minigame length outside 30–240 s**: validation error (user decision 2026-10-10). Tournament Minigames' `t_mg` range must be widened from 60–180 s to match when it is next revised.
- **CV15 or CV16 in a recipe with a `floor` atom**: validation error. A tilt mid-piece is applied at the next Resolving (down-axis rule).
- **CO08 pour piece meets a full layer**: it fills what it can and the rest is lost (no overflow over the height limit).
- **SC09: the top-out happens in the same tick as a bank tap**: the bank wins (input before resolve).
- **SC11 without EV08 active**: validation error (needs EV08).
- **A recipe lists the old party ids** (BL17 meaning Handicap, GO27 Boss Raid, EV20 Sprinkle, WO12 Skill Rule): the ids now name the puzzle atoms, so the tag check usually fails. Use BL20, GO30, EV24, WO14.
- **GO30 or IN31 in a minigame recipe**: allowed (`vs tourney`, not `coop`). Played as quick versus: validation error, like every `tourney` atom.
- **AR07 tray under the daily's never-fail frame (FT02 / FT11) and no tray piece fits**: the tray is discarded and refilled from the rule's stream after a short shuffle cue. It costs time, never a fail. (FT09 is not allowed in the daily.)
- **CL16 or SE05 while the player drags the camera**: no `view_snap` is sent during a drag, so the sim keeps the last settled snap. A lock during a drag uses that snap (ADR-0014 §6).
- **FT12 undo at the last piece**: the outcome is fixed at S7 (ADR-0011 §3). Once out of pieces resolves, the level is lost; undo is only available before that lock. Reset is always free.
- **A Proposed atom in a shipped recipe**: validation warning. It must be reviewed to Candidate (and its rules written in an owning GDD) before the level ships.

## Dependencies

| System | Direction | What flows |
|---|---|---|
| Rule-Twist Framework (ADR-0004) | Module → | Every rule atom is a rule (layer, params, hooks, vetoes). Slot atoms are slot values. Caps from F3. Tags live in `atom_tags.json`; the new tags `wrap`, `cam`, `face`, `tourney` are to be added |
| Mechanic & level-event runtime (ADR-0011) | Module → | Rules in the sim, beehave staging only; layer ranks `mascot` 1, `content` 2; S4a / S4c steps; every telegraphed decision is a `SimEvent` |
| Camera rig (ADR-0014) | ← | `view_snap` command for `cam` atoms (CL16, SE05) |
| Meadow Candidate Atoms | ↔ | Full rules of PL03, SP21, SP22, SP26, SP28, SP31, WO11 |
| Character skills (GDD not started) | ↔ | WO14 skill rule; IN32, IN33, EV23, WO13 hooks; CV17, CV18, SP39, SP40 as possible skill sources |
| Level Data & Definition (ADR-0005) | ↔ | Recipe → level JSON; the optional `recipe` block; the validator runs the tag and conflict checks |
| Level-Specific Mechanics, Twist Library | ↔ | Designed atoms link here. Picked candidates move their rules there |
| Layer Clearing, Level Goals & Fail States, Fall/Drop/Lock, Movement & Rotation | → atoms | The plugin base classes the CL, CO, GO, FT, AR and CV atoms extend |
| Tournament Minigames | ↔ | Minigame recipes; IN atoms; length classes (30–240 s, user decision; that GDD's `t_mg` range is to be widened) |
| Items, Buffs & Debuffs | ↔ | IN14–IN20 become item and effect ids |
| Obstacles, Obstacle Clearing, Block Status Effects | ↔ | SP blockers (SP06–SP09, SP29–SP32) are obstacle content |
| Mode / Minigame Randomizer, RNG/Seeds (ADR-0006) | → | Daily seed by date; per-rule streams for F9 and EV15 |
| Mascot Reactions (not started) | ← | WO01, WO06–WO09 and SE01 need the mascot behaviour hooks |
| Save & Profile, Campaign Structure | ← | Secrets (SE02–SE07) need collection flags and hidden-level unlocks |
| Scoring & Stars | ← | SC atoms; F4 |
| mechanics-catalog.md | ↔ | The catalog's idea IDs map to atom IDs (catalog §9) |

**Verbs.** The CV atoms CV04–CV09 and CV13–CV19 replace the input-to-command mapping through ADR-0004's `control.verb` slot (`ControlVerb` plugin base, default `piece`). So they work in campaign levels as well as in minigames.

Bidirectional notes: the GDDs above should list the Mechanics Module when they are next revised.

## Tuning Knobs

| Knob | Range | Default | Category | Affects |
|---|---|---|---|---|
| new_max / nd_max per context | see F1 | see F1 | gate | Readability per level |
| daily_weight per atom | 0–10 | 1 (AR01 7) | curve | Daily variety |
| daily_rerolls | 5–50 | 20 | gate | Generator robustness |
| k_goal | 0.4–0.9 | 0.6 | curve | Daily difficulty |
| daily_t_s | 90–300 | 180 | gate | Daily length |
| rocket_at / colour_bomb_at | 4–6 / 6–9 | 5 / 7 | curve | Special frequency (F3) |
| sweep_mult_base / max / combo_min | 2–4 / 8–32 / 3–6 | 4 / 16 / 4 | curve | Sweep combo (F4) |
| tap_pop_min | 2–4 | 2 | feel | Tap-pop group size |
| zone_ms | 3 000–10 000 | 6 000 | feel | Zone freeze |
| cd_start / cd_blast_junk | 4–15 / 1–2 | 8 / 1 | curve | Countdown bomb |
| hatch_locks / grow_locks | 3–12 / 2–10 | per level (meadow_09: 12) / 4 | curve | Living blocks (meadow-candidate-atoms F1, balance B1) |
| ant_every_locks | 1–6 | 3 | curve | SP31 ant pressure (meadow-candidate-atoms §6 F1, balance B2) |
| Proposed-atom knobs | see §2b | see §2b | — | Move here when an atom becomes Candidate |
| magnet_range | 1–4 | 2 | feel | Magnet pull |
| creature_step_locks | 3–12 | 6 | gate | Creature back |
| event_card_locks | 4–15 | 8 | gate | Mystery cards |
| walkers_needed | 1–10 | 3 | curve | Critter walkers |
| comet_p / comet_cap / comet_layers | 0.01–0.15 / 1 / 1–3 | 0.05 / 1 / 2 | curve | Leader hunter |
| party_hat_ms | 500–2 000 | 1 500 | feel | Party Hat (hard max 2 000) |
| rewind_locks | 1–3 | 1 | curve | Rewind |
| big_combo_k | 3–8 | 4 | curve | Combo payoff frequency |
| w_hit / w_chaos / w_power | 0–100 | 40 / 30 / 30 | curve | Payoff mix |
| chaos_meter_max | 3–12 | 6 | gate | Table event frequency |
| junk_return_locks | 4–20 | 10 | curve | Junk comes back |
| legendary_p | 0.001–0.02 | 0.005 | curve | Legendary piece rarity |
| poke_secret_count | 3–20 | 7 | feel | Mascot poke secret |
| length class bounds | burst 30–60 s, standard 60–180 s, showpiece 180–240 s | — | gate | Minigame mix |
| gravity_nudge_cd / tilt_charges | 3–15 / 1–3 | 8 / 2 | gate | CV15 / CV16 |
| seesaw_max | 5–30° | 15° | feel | BL16 |
| crumble_s / bounce_h | 1–5 s / 1–3 | 2 / 2 | feel | SP34 / SP35 |
| bump_locks | 5–30 | 12 | gate | EV17 |
| nanogame_every | 5–20 pieces | 10 | gate | EV19 |
| order_decay_s | 10–60 | 30 | curve | GO26 |
| luck_mult_step | 0.1–1.0 | 0.25 | curve | SC09 multiplier gain per unbanked clear |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or playtest.

1. [U] Every atom ID in this document is unique and maps to one engine hook kind (slot value, rule, content or minigame param). A test parses the tables.
2. [U] Validator: a recipe missing any of Board, Arrival, Verb, Goal or Fail fails.
3. [U] Validator: each conflict pair in §3 fails (for example, CL14 + SP02; AR07 + EV01; BL13 + CL05; BL02 + EV05).
4. [U] Validator: a minigame recipe with BL09, AR12, GO17 or IN11 fails, and a minigame recipe with no IN atom fails.
5. [U] Validator: a campaign or minigame recipe without `story.premise` and `story.mascot_role` fails.
6. [U] Daily generator: the same date gives the same recipe on every device. For 1 000 consecutive dates, every recipe passes the validator, has exactly one `absurd` atom and ≤ 4 non-default atoms.
7. [U] F3: pops of 5 (line), 6 (L shape with 3+3) and 7 give a rocket, a bomb and a colour bomb.
8. [U] F4: three combo passes in a row give ×4, ×8, ×16, and a weak pass resets to ×4.
9. [U] F5: 5 pending with 7 sent leaves 0 pending and sends 2.
10. [U] F8: the Comet is never rolled by a player who is not last, nor with 2 players. At most one is in flight per round.
11. [U] F10: 40 cubes and 3 holes → tidy 0.925 → happy.
12. [U] IN17: the Party Hat never lasts over 2 000 ms and never covers the height line or attack markers.
13. [I] R3 Candy Cascade, written as level JSON, loads and plays with no core-code change beyond its plugins.
14. [M] Playtest: for each recipe built, ≥ 80% of testers can explain the level's idea in one sentence after 2 pieces (Pillar 2), and ≥ 70% can retell the story premise after playing.
15. [M] Playtest: in a 3–4 player tournament, the Comet feels like a comeback rather than a punishment (a post-session survey shows no more than 20% "unfair" votes).
16. [U] F1 count rule: R1 counts nd 4 (M1 bundle = 1), R3 counts 6, and a recipe with GO03 alone (no CL14) counts GO03 as 1. Every recipe R1–R10 and T1–T8 passes its context's cap.
17. [U] Validator: a quick-versus recipe with BL20, IN26, EV22, GO30 or IN31 fails; the same atoms in a tournament minigame recipe pass.
18. [U] Determinism: a CL16 level replayed from its command log (with `view_snap` commands) gives the same clears and `state_hash()`; removing every staging tree changes no `SimEvent` (ADR-0011 §9).
19. [M] Playtest: in a 3–4 player tournament with T4 Boss Raid, ≥ 70% of testers describe it as "racing each other" rather than "a team game" (individual scores stay readable).

## Open Questions

Resolved 2026-10-10 (user):
- Showpiece levels in tiers 7–10 allow up to 6 non-default atoms.
- Minigame length is 30–240 s.
- Kitchen Rush (competitive) is the approved default.
- `control.verb` now exists in ADR-0004.
- All 42 proposed atoms are in, status Proposed; the 4 clashing party ids are renumbered.
- Co-op party events (Boss Raid GO30, Truce Pact IN31) are allowed in tournaments only, with individual scores.
- Puzzle (`turn`) levels can be failed; FT12 undo/reset is an optional atom, not the default.
- CL16 is kept: camera snaps are recorded `view_snap` commands (ADR-0014).
- Goal and Fail picks count toward nd; designed bundles count 1 (F1 count rule).
- Edges (BL20, IN26, EV22) are off in quick versus (`tourney`).

Still open:
4. **Story-card display**: does the premise show on the Intro goal card, or only drive mascot lines? (ux-designer, HUD)
5. **EV14 rule cubes** are L cost and readability-risky. Prototype one sentence (`COLOUR IS BOMB`) before any level uses it.
