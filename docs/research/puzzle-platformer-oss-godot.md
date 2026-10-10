# Research: Puzzle Tools, 3D Platformer Kits, OSS Godot Games, Mechanic Catalogs

> **Date**: 2026-10-10. **Scope**: beyond awesome-gamedev / awesome-godot (see `awesome-gamedev-resources.md`).
> **Method**: GitHub API (`gh api`) for licence, last push and stars (verified 2026-10-10 unless marked); WebSearch for items not on GitHub. Nothing was downloaded, cloned or installed.
> **Verdicts**: Adopt = use now. Evaluate = spike before deciding. Reference = read, do not depend. Skip = not useful.
> **Licence flags**: GPL = reference only, no code copying. NC = non-commercial, never ship. "Unverified" = from search snippets only.

## 1. Headline findings

1. **Solvability checking** is best done offline in a small tool, not in-game: exact cover (DLX or CP-SAT) for "perfect box" and polycube-fill levels, BFS or A* over our own rules for move-limited levels, **OR-tools CP-SAT** when a level has side constraints. Generating levels by reverse play (start solved, play backwards) is solvable by construction.
2. **Kenney Starter-Kit-3D-Platformer is MIT with CC0 assets**: the cleanest base for the platformer minigames. GDQuest's 3D third-person controller has MIT code but **CC-BY-NC-SA art**: take code only.
3. **No mature OSS 3D falling-block / stacking Godot game was found.** The closest genre relative is **Turbofat** (MIT code, CC BY-NC assets).
4. **Best local-multiplayer / party sources**: `godotengine/godot-demo-projects` (MIT, pushed 2026-10-08) plus two small MIT lobby / phone-controller templates.
5. **Mechanic catalogs** (Mario Party / WarioWare wikis, pattern wikis) yield about 11 new atoms (section 7). Most of what they list we already have.

## 2. Puzzle design: solvers, generators, frameworks

| Name | URL | Licence | Last update | What we can use | Verdict |
|---|---|---|---|---|---|
| OR-tools (CP-SAT) | https://github.com/google/or-tools | Apache-2.0 | 2026-10-09 | Constraint solver for "is this level solvable / how many solutions / minimum moves". Python offline tool run over `production/levels/`. Handles side constraints (colour keys, targets, piece budgets) plain exact cover cannot. | **Adopt** (tooling only, never in the APK) |
| PySAT | https://github.com/pysathq/pysat | MIT | 2026-08-16 | SAT encodings for small yes/no solvability and uniqueness checks. | Evaluate (pick this or CP-SAT, not both) |
| Z3 | https://github.com/Z3Prover/z3 | MIT (GitHub shows NOASSERTION; LICENSE.txt is Microsoft's MIT header) | 2026-10-09 | SMT solver; overkill, CP-SAT covers our cases. | Skip |
| Clingo (ASP) | https://github.com/potassco/clingo | MIT | 2026-10-09 | Declarative rules for "generate all levels satisfying X". Learning cost. | Reference |
| mlepage/polycube-solver | https://github.com/mlepage/polycube-solver | MIT | 2011-10-23 | Lua, Algorithm X; box and pieces in a short problem file. Dated, but the encoding (cell columns, placement rows) is the whole idea. | Reference |
| DlxLib (C#), dancing-links-java | https://github.com/taylorjg/DlxLib ; https://github.com/rafalio/dancing-links-java | MIT / MIT | 2018 / 2014 | Exact cover for our Piece Set filling a box (GO11 Perfect box, AR09 fixed list). Rows = (piece, orientation, position), columns = cells. Own ~100-line version is simplest. blynn/dlx and benfowler/dancing-links are **GPL: reference only**. | Evaluate (write our own) |
| nonogrid, Nonograms, pynogram, nonogram-solver | https://github.com/tsionyx/nonogrid ; https://github.com/Izaron/Nonograms ; https://github.com/tsionyx/pynogram ; https://github.com/ThomasR/nonogram-solver | MIT / MIT / Apache-2.0 / Apache-2.0 | 2018-2024 | 2D line solvers. Picross 3D adds a third axis; the clue-line logic extends. Use to check CV07 / GO15 / GO22 levels have a deduction path. | Reference |
| nathsou/Picross3D, liouh/picross | https://github.com/nathsou/Picross3D | **none (all rights reserved)** | 2022-2025 | Browser 3D picross; behaviour reference only. | Reference (do not copy) |
| PuzzleScript | https://github.com/increpare/PuzzleScript | MIT | 2026-10-07 | Rule-rewriting puzzle prototyper: prototype a new atom's rule in minutes before engine work. Large community games corpus (check each game's own licence). | **Adopt** (design sandbox) |
| PuzzleScriptAI | https://github.com/icelabMIT/PuzzleScriptAI | none | 2015-07-01 | BFS / best-first solver in `simulator.js`. Old; idea only. | Reference |
| Awesome PuzzleScript | https://leetusman.com/awesome-puzzlescript | list | seen in search | Index of PuzzleScript solvers, forks (PuzzleScript Plus has a solver) and games. | Reference |
| PuzzleScript Rules (BorisTheBrave) | https://www.boristhebrave.com/2024/06/10/puzzlescript-rules | article | 2024-06 | How rewrite rules express puzzles; pairs with our `RuleBehaviour` design. | Reference |
| WaveFunctionCollapse | https://github.com/mxgmn/WaveFunctionCollapse | MIT-style (GitHub: NOASSERTION; LICENSE present; sample images separate; verify before shipping derivatives) | 2026-03-22 | Original algorithm; README links many ports and the Karth/Smith "WFC is constraint solving" papers. | Reference |
| DeBroglie | https://github.com/BorisTheBrave/DeBroglie | MIT | 2025-12-21 | C# WFC with **full backtracking, non-local constraints, 2D / hex / 3D voxel** (README). Best fit for generating box layouts (BL05 pre-built tower, BL02 masks). Run offline, bake to JSON. | **Evaluate** |
| Godot_WaveFunctionCollapse | https://github.com/theBGPguy/Godot_WaveFunctionCollapse | MIT | 2022-10-24 | GDScript 2D port, small. | Reference |
| wfc_2019f | https://github.com/ikarth/wfc_2019f | MIT | 2023-08-18 | Python WFC with backtracking, from the 2021 paper. | Reference |
| sokoban-solver-generator | https://github.com/xbandrade/sokoban-solver-generator | MIT | 2023-11-12 | BFS / A* / Dijkstra solver plus generator in small Python; template for a level-checker script. | Reference |
| puzzlekit | https://github.com/SmilingWayne/puzzlekit | MIT | 2026-07-30 | 100+ OR-tools models for logic puzzles with datasets; CP-SAT modelling examples. | Reference |
| SokoSolve, YASS | https://github.com/guylangston/SokoSolve ; https://github.com/joriswit/YASS | **GPL-2.0 / GPL-3.0** | 2026 | Strong Sokoban solvers. | Reference only |

### Design writing and talks

URLs came from search; individual video titles were **not** verified.

| Name | URL | Use | Verdict |
|---|---|---|---|
| Game Maker's Toolkit (Mark Brown), puzzle design category | https://gamemakerstoolkit.com/ | Search showed a "Puzzle Game Design" playlist of 8 videos. Find the Baba Is You / Snakebird style episodes there. | Reference |
| Gameplay Design Patterns wiki (Björk, Holopainen et al.) | https://gameplaydesignpatterns.org | 607 patterns as of 2021 (per search). Use to check slot coverage and pattern relationships. | Reference |
| Game Design Tools: Game Design Patterns | https://gamedesigntools.notion.site/Game-Design-Patterns-c98251a4dc684ae680dadeccee195fc6 | Curated entry to the same material. | Reference |
| Jonathan Blow / Stephen Lavelle talks | no verified URL | Search tied neither to a specific talk. Lavelle writes on increpare.itch.io and the PuzzleScript docs. Ask the team for exact talks before citing. | Skip until verified |
| Sokoban level-generation papers (Murase et al.; Taylor and Parberry; Balyo and Froleyks 2022, "AI Assisted Design of Sokoban Puzzles Using Automated Planning") | via search only | One result reported only 14 good levels per 500 BFS-generated Sokoban levels: expect to **filter** generated levels, not trust them. | Reference |

### Recommended solvability pipeline (for a later ADR)

1. Level JSON stays the source of truth; a tool in `tools/` reads it.
2. Per goal type: GO11 / GO03 fill goals use exact cover (DLX or CP-SAT); piece-budget levels (FT07) use BFS over (board, queue index) with symmetry pruning; colour-clear goals (GO06) use depth-limited search with a heuristic.
3. The daily generator builds levels by **reverse play**, then verifies with the solver and records par.
4. Report unique-solution count and minimum moves as observations only (project rule: scripts emit observations, not verdicts).

## 3. 3D platformer libraries and templates (Godot 4)

| Name | URL | Licence | Last update | What we can use | Verdict |
|---|---|---|---|---|---|
| Kenney Starter-Kit-3D-Platformer | https://github.com/KenneyNL/Starter-Kit-3D-Platformer | MIT code; models, sprites, sounds CC0 (README) | 2026-03-12 | Godot 4.6 kit: character controller with double jump, coins, falling platforms, rotate/zoom camera, gamepad. Falling platforms map to BL12 and the new crumble cube; coins to SC07. Needs touch controls. | **Adopt** (Mascot Bridge Race, critter walkers) |
| godot-demo-projects `3d/platformer` | https://github.com/godotengine/godot-demo-projects | MIT | 2026-10-08 | `CharacterBody3D` platformer with enemies, coins and a `touch_screen_ui` folder: a ready on-screen controls reference for Android. | **Adopt** (touch UI reference) |
| godot-demo-projects `3d/rigidbody_character`, `physics_tests`, `soft_body_physics`, `squash_the_creeps`, `ragdoll_physics`, `physics_interpolation` | same repo | MIT | 2026-10-08 | Cube RigidBody character (`cubelib`), relevant to BL13 / Catch Tower; physics interpolation for smooth phone frame rates. Check each demo's asset licence before copying art. | Evaluate |
| GDQuest godot-4-3d-third-person-controller | https://github.com/gdquest-demos/godot-4-3d-third-person-controller | **Code MIT; art CC-BY-NC-SA 4.0** (LICENSE; GitHub shows NOASSERTION) | 2026-08-15 | Camera rig and animation-driven movement. Scripts only; **never ship its models**. | Evaluate (code only) |
| Kenney Starter-Kit-Racing | https://github.com/KenneyNL/Starter-Kit-Racing | MIT | 2026-08-21 | Drift feel, lap loop; Mario Kart style item box reference. | Reference |
| Kenney Starter-Kit Basic-Scene / City-Builder / FPS | https://github.com/KenneyNL | MIT | 2026-03-12 | Basic Scene is a clean 4.6 skeleton; City Builder shows grid placement and save/load. | Reference |
| straif | https://github.com/vasiltop/straif | MIT | 2026-10-01 | Precise-movement 3D platformer with leaderboards; ghost / timer reference. | Reference |
| 3D-Platformer-Kit (SilverDemons-PK) | https://github.com/SilverDemons-PK/3D-Platformer-Kit | MIT | 2025-06-25 | Beginner Godot 4 platformer; second opinion on camera follow. | Reference |
| SuperTuxWorld | https://github.com/studiobool/SuperTuxWorld | **GPL-3.0** | 2026-02-21 | Open 3D platformer in Godot 4. | **Reference only** |
| Zylann godot_voxel | https://github.com/Zylann/godot_voxel | MIT | 2026-10-01 | Voxel terrain module. Our boards are tiny grids. | Skip |

Design note (not licence): coyote time about 0.1 s and jump buffer about 0.15 s are common starting values from tutorial snippets seen in search; treat them as tunable defaults. Smooth the camera follow.

## 4. Open-source Godot games

| Name | URL | Licence | Last update | What we can use | Verdict |
|---|---|---|---|---|---|
| Turbofat | https://github.com/Poobslag/turbofat | **Code MIT; `LICENSE2.md` is CC BY-NC 4.0** (assets; header verified). No art or audio. | 2026-09-30 | Shipped block-dropping puzzle with creature characters, career mode, level data files and lots of juice; localisation via pybabel. Closest genre and tone relative. Read for level data layout, UI flow, creature reactions. | **Evaluate** (patterns only, no assets) |
| ROTA | https://github.com/HarmonyHoney/ROTA | **MIT** (LICENSE verified; older asset-library entries said Unlicense / GPLv3, trust the repo file) | 2026-06-25 | Gravity-bending puzzle platformer, Godot **3.6** (port, don't paste). Source for the "push block" and "gravity rotation" atoms. | **Evaluate** |
| Pixelorama | https://github.com/Orama-Interactive/Pixelorama | MIT | 2026-10-08 | Large Godot 4 app: UI theming, undo / redo, export. No gameplay. | Reference |
| Tanks of Freedom | https://github.com/w84death/Tanks-of-Freedom | custom (NOASSERTION; sequel repo shows "other") | 2025-02-03 | Turn-based strategy with map editor. Read the licence text before any reuse. | Reference |
| Liblast | Codeberg `Liblast/Liblast` | GPL-3.0 (from a Flathub request; **unverified**) | n/a | Libre Godot 4 FPS; modular layout. | **Reference only** |
| Dungeons of Dice | not found | unknown | n/a | No repo located. Ask the user for a link. | Skip |
| Brackeys' Godot projects | not found by `gh api` | n/a | n/a | No Godot repo located. | Skip |
| godot-open-rpg (GDQuest) | https://github.com/gdquest-demos/godot-open-rpg | MIT | 2026-05-01 | Turn-based menu / UI structure. Check art licence (GDQuest art is often NC). | Reference |
| godot-design-patterns (GDQuest) | https://github.com/gdquest-demos/godot-design-patterns | NOASSERTION (check LICENSE) | 2026-05-16 | State machine, observer, command / undo examples; fits our undo atoms. | Reference |
| Godot_GamePad | https://github.com/ACB-prgm/Godot_GamePad | MIT | 2026-10-04 | Phones as controllers for a Godot game: a **phone-as-controller** party model. Check network and privacy implications. | **Evaluate** |
| godot-couch-party | https://github.com/Domogo/godot-couch-party | MIT | 2026-08-03 | Godot 4 local-party input isolation and lobby; tiny, one author. | Evaluate |
| party-games-godot | https://github.com/harryjjacobs/party-games-godot | MIT | 2025-02-26 | Phone-controlled party minigames. | Reference |
| godot-demo-projects `networking/*`, `mobile/*` | https://github.com/godotengine/godot-demo-projects | MIT | 2026-10-08 | `multiplayer_bomber`, `multiplayer_pong`, `mobile/multitouch_cubes`, `mobile/sensors`. Direct multitouch and tilt references. | **Adopt** (reference) |
| Kenney Starter-Kit-Match-3 | https://github.com/KenneyNL/Starter-Kit-Match-3 | MIT; sprites CC0 | 2026-08-22 | Drag-swap match-3 with animation, sound and particles; touch UX for CV04. | Evaluate |
| zanneth "Tetris Trance" | https://code.zanneth.com/zanneth/zanntetris | unknown | n/a | Godot 4 falling-block game. | Skip until licence verified |
| jaidev14/jengadness | https://github.com/jaidev14/jengadness | CC0-1.0 | 2026-01-21 | Tiny Jenga jam game; look at how pull-and-replace (CV06) is done. | Reference |
| godot-sokoban (baiXfeng) | https://github.com/baiXfeng/godot-sokoban | MIT | 2025-02-27 | 3D push-box in Godot with MVC; base for the "push cube" verb. | Reference |

Searches for 3D falling-block, stacker or tower-builder games in Godot found no mature OSS project, so we build BL13 ourselves.

## 5. Mechanics inspiration and design resources

| Name | URL | Licence | What we can use | Verdict |
|---|---|---|---|---|
| Super Mario Wiki: Mario Party minigame lists | https://www.mariowiki.com/List_of_minigames_in_Mario_Party | CC BY-SA (text; ideas are not covered, still do not copy text) | Format taxonomy: 4-player, 1-vs-3, 2-vs-2, Duel, Battle, Co-op, Rhythm, Bowser. Our rule keeps minigames competitive, so 2-vs-2 and co-op stay Parked; 1-vs-3 maps to IN10. | Reference |
| Super Mario Wiki: WarioWare microgame lists | https://www.mariowiki.com/List_of_microgames_in_WarioWare:_Touched! | CC BY-SA | Sets of 20-25 microgames plus a boss; one-verb commands; speed ramps. Supports BL15 and EV13. | Reference |
| Gameplay Design Patterns wiki | https://gameplaydesignpatterns.org | see site | Check slot gaps against pattern relationships. | Reference |
| BoardGameGeek mechanics list | https://boardgamegeek.com/browse/boardgamemechanic | not verified, not fetched | Names from general knowledge: Drafting (we have AR08), Pattern Building (GO03), Take That (slot 10). Not in the library: **Push Your Luck**, **Variable Player Powers**. | Reference |
| Tile / block puzzle catalogs | no single page found | n/a | The PuzzleScript games corpus is the closest broad set of tile-puzzle verbs (push, pull, merge, slide, gravity). | Reference |

## 6. Gaps checked against the library (no atom needed)

- Undo: SP17 exists. Par / move counter: FT07 covers it.
- Drafting: AR08. Memory shapes: GO12.
- Picross clue numbers on board edges: display only; CV07 / GO15 / GO22 exist.
- Ice slide, wind, gravity flip, portal pair, conveyor: all in the box.
- Sokoban "push" is the one common puzzle verb we lack (CV14).

## 7. New mechanic atoms suggested

Row format follows `design/gdd/mechanics-module.md`. IDs continue each slot's numbering; "Match" says new or existing. All are Candidates.

| ID | Atom | One line | From | Tags | Cost | Status | Match |
|---|---|---|---|---|---|---|---|
| CV14 | Push cube | Tap a locked cube; it slides one cell away from you along the floor into the next empty cell. It can push one other cube, never off the edge. | Sokoban, ROTA, PuzzleScript | grid floor turn | M | C | **New** |
| CV15 | Gravity nudge | Tap to rotate the down axis 90 degrees for the whole stack; one use per `gravity_nudge_cd` locks. | ROTA | grid fall | M | C | **New** (player-driven; EV03 is a rule event, BL11 turns the stack on a timer) |
| BL16 | Seesaw board | The board sits on a pivot. Mass left and right of centre tilts it; past `seesaw_max` degrees a lip of cubes slides off. | Tricky Towers, Boom Blox | phys | L | C | **New** |
| SP34 | Crumble cube | A locked cube dissolves `crumble_s` seconds after another cube lands on it. | Kenney platformer falling platforms, Fall Guys | floor rt | S | C | **New** (BL12 shrinks the rim; this is per cube) |
| SP35 | Bounce pad | A piece landing on it hops up `bounce_h` cells and relocks one cell onward in its move direction; once per landing. | 3D platformers | fall | S | C | **New** |
| GO23 | Bridge race | First to build a continuous cube path across a gap to the flag wins; the mascot then walks it. | Mascot Bridge Race, Fall Guys | vs rt mg | M | C | **New** as a vs goal (GO10 is the solo version) |
| GO24 | Echo | The mascot shows a sequence of 3 placements (cell and colour). Repeat them in order; each wrong step costs a heart. | Simon, WarioWare memory microgames | turn tgt | S | C | **New** (GO12 copies a shape; this tests order) |
| IN21 | Tug of war | Each clear moves a shared marker one step toward the rival's side; first to the edge wins. | Mario Party tug-of-war | vs | S | C | **New** |
| EV17 | Speed-up bump | Each completed stage or `bump_locks` locks raises gravity speed one notch, with a clear cue. | WarioWare | rt | S | C | **New** (EV08 follows music BPM; BL15 is the stage wrapper) |
| SC09 | Push your luck | After a clear, bank the points or keep building for a bigger multiplier; a top-out loses the unbanked points. | Board game "push your luck" | solo | S | C | **New** |
| WO10 | Mascot pick | Each player picks a mascot with one small, capped passive (for example a longer preview). | Variable Player Powers, Mario Party characters | vs | M | C | **New** (WO06-WO09 are the AI mascot behaviours) |
| (tooling) | Reverse-play daily | The daily generator builds a level by playing a solved board backwards, so it is solvable by construction. | Sokoban generators | daily | M | C | **New, tooling note** for the daily-generator ADR, not an atom |
| CV07 | Chisel | Confirmed by Picross 3D clue solving. | Picross 3D | | | | **Existing** |
| CV06 | Pull and re-place | Confirmed by Jenga jam games. | Jenga | | | | **Existing** |
| CV04 | Swap | Kenney Match-3 drag-swap is the touch UX reference. | Candy | | | | **Existing** |
| BL12 | Shrinking floor | Kenney falling platforms. | Fall Guys | | | | **Existing** |
| SP16 | Portal pair | PuzzleScript portals. | | | | | **Existing** |
| EV14 | Rule cubes | Baba Is You rewrite rules; PuzzleScript shows how little code a rewrite rule needs. | | | | | **Existing** |

## 8. Concerns and open items

- **NC art licences**: GDQuest 3D controller art (CC-BY-NC-SA) and Turbofat assets (CC BY-NC) must never enter the build. Their code is MIT.
- **GPL repos** (SuperTuxWorld, blynn/dlx, benfowler/dancing-links, SokoSolve, YASS, Liblast) are reference only.
- **No licence = not reusable**: PuzzleScriptAI, nathsou/Picross3D, liouh/picross.
- **WFC and Z3** show NOASSERTION on GitHub; confirm the LICENSE file before shipping anything derived. Both would be offline tooling here, so exposure is low.
- **Not found**: Dungeons of Dice repo, Brackeys Godot repos, any Blow / Lavelle talk with a verified URL. Ask the user for links.
- ROTA targets Godot 3.6 (port needed). Kenney kits target 4.6; our project is 4.7.2, so expect small API fixes.
- Gameplay Design Patterns, BGG and Mario wiki pages were seen in search results, not fetched.
