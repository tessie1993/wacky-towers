# Mockup Alignment: Minigame Boards to Modules, Biomes and the Campaign

> **Status**: Draft v1 for review (level-designer, 2026-10-13). Written directly under the user's instruction "This is what our game should be. Get the level designer to study the mockups."
> **Author**: level-designer
> **Sources (all viewed)**: `assets/art/reference/index.md`; `style/01, 02, 07, 09, 10, 11, 12, 13, 14, 15`; `minigame_mockups/mockup_06, 12, 14, 15, 16, 17`.
> **Reads against**: `design/gdd/campaign-structure.md`, `campaign-minigames.md` (module catalogue and biome plan), `minigame-mechanics-wave4.md` (atoms A1-A12), `mechanics-module.md`, `mode-minigame-randomizer.md`, `party-minigames-wave2.md`, `rule-twist-framework.md`; `design/levels/level-type-mix.md`, `tumble-fair.md`, `minigame-stages.md`; `assets/data/campaign/catalog.json`.
> **Replaces**: the stage-sheet approach in `minigame-stages.md`, which treats minigames as side stages. Per the standing decision they are **modules inside levels**; that file stays as a source of board and rule ideas only.

**Every number and name here is a tunable default or a working title.** "Covered" means **specified in a GDD**. Nothing in `assets/data/modules/` or `src/` exists yet for the module framework, so no mockup minigame is playable today.

---

## 0. Standing decisions applied and flags raised

| Decision | How it is applied here |
|---|---|
| Minigames are building blocks inside levels, reskinned per biome, plus random head-to-head tournament rounds | Every mockup minigame is mapped to a module id (`campaign-minigames.md`) plus a biome skin. Titles become **level names or round names**, never separate stages |
| No hardcoded levels; the next block is random each attempt | No `fixed_list` anywhere except the existing puzzle bonuses. Tutorial prompts key off events (piece landed, meter crossed), never off a scripted piece |
| Level types: race, balance, defender, funny, completing, twist | Every row is typed (section 1). No "standard rules" level is proposed |
| Single-grid boards are 8x8 or larger, no maximum | Mockup islands look 5x5 to 6x6 (First Steps, Fort cut-aways). **All boards here are 8x8 minimum**, and wide boards (12x8 bridges, 10x10 meadow) are expected |
| Solo campaign first, then Tumble Fair (4 players, Baron Balloon host) | Section 3 defines the hub; solo campaign arcs (section 2) are built first and tournament templates unlock from them (`campaign-minigames.md` tournament rule 2) |
| Pirate-island biome, crab claws, meadow sheep, Jolt physics tilt, potions on | Pirate Cove (section 2.3), `crab_claw` as the pirate defender overlay, `herd_critter` for sheep, `balance_plate` on Jolt (flag F2), "Power-Up / Item / Weapon / Tool" slots = potions |
| No "Tetris" naming; never copy TETRO PARTY / WACKY PARTY logos; no Nintendo IP | Five titles renamed for trademark risk (section 1.2). The mockups' hub banner reads "Party Quest" and the boards carry "Wacky Party" and "Party Battle" ribbons: **we use none of them**. The hub is the **Tumble Fair Midway**, in our own logo style |

**Flags for the owners** (not decided here; options and a recommendation each):

- **F1. Pirate Cove has no slot.** The catalog has 11 biomes (10 main plus the Tumble Fair side island) and `campaign-structure.md` says 10 x 10. Style/13's block sheet shows 12 biomes (it adds Dune Bazaar) and **no pirate block**. Options: (a) Pirate Cove as an 11th main biome after Underwater (recommended: the sea-faring arc stays continuous and 3 mockup siege games need a home); (b) a second side island like Tumble Fair (5 levels plus bonus, no gate; cheaper, but it hides the biggest set of mockup minigames); (c) fold pirate into Underwater (crowds that biome). Needs creative-director and narrative-director; art-director must add a pirate block skin (driftwood, rope, brass).
- **F2. Jolt tilt vs deterministic tilt.** The user chose Jolt physics tilt. `minigame-mechanics-wave4.md` A2 recommends a deterministic grid `tilt_plate` for lockstep and replays. Recommendation: Jolt for solo campaign; in tournaments every seat simulates locally from the shared seed and the **host takes the reported result** (no lockstep hash for `balance_plate` rounds). Grid `tilt_plate` stays a fallback. Needs technical-director.
- **F3. Kraken ownership.** `campaign-minigames.md` gives Kraken Blockade to Underwater and Fort Blast to the Lava bonus. The mockups show the Kraken beside cannons, towers and a sea (pirate), and Fort Blast with pirates on cliffs. Recommendation: **move Kraken Blockade to the Pirate Cove finale and Fort Blast into Pirate Cove**, and give Underwater a crab boss ("Crab King", uses `crab_claw`). That edits the game-designer's biome table, so it goes to game-designer first.
- **F4. Cast.** The boards show knights, dwarves, elves, "Sif", goblins and gnomes. The project cast is wizard, pirate, astronaut, robot, penguin, alien, tiki, plus biome mascots and Baron Balloon. All rows use the project cast. Goblins (style/07 "Goblins' ambush!") and gnomes (mockup_12) are **enemy and critter roles for the narrative-director to confirm**; this file only needs "a pack of small raiders" and "acorn-throwing critters".
- **F5. Hearts on the Party Battle cards (mockups 12-15).** Hearts conflict with the tournament's "first to 3 wins" (style/14). Rule: hearts appear **only in elimination rounds** (Lava Rumble, Candy Dodger, Block Dodge); every other round shows score or progress.

---

## 1. Per-minigame alignment (all 36)

**Columns.** Verb and goal is the block-stacking verb (the player only drops, rotates or slides pieces; mascots act on what is placed). Meter and HUD lists what the board shows. Covered by uses module ids from `campaign-minigames.md` and atoms from `minigame-mechanics-wave4.md`; **NEW** marks something with no spec. Mode: **Solo** (campaign), **Tourn** (tournament round), **Both**. Duel games get scripted rivals in the campaign (`campaign-minigames.md` tournament rule 6).

### 1.1 Sheets style/09 to 12

| # | Mockup title -> our title | Verb and goal | Meter and HUD | Covered by | Biome | Type | Mode |
|---|---|---|---|---|---|---|---|
| 1 | Bridge Bashers | Drop pieces into a river gap until a deck joins both banks; mascots carry the cubes and walk the finished deck | Timer 1:12; two score rows per side (portrait + score); a Next Block slot per side | `bridge_dash` (+ `pace_mascot` ghost); acorn-thrower overlay = rule `squirrel_heist`. COVERED (A3 `span_goal` NEW code) | Meadow | race | Both (MG37) |
| 2 | Avalanche Ascent | Place pieces as steps up a snowy slope ahead of the avalanche; the mascot climbs what you build | **Altitude** vertical thermometer (green top, red bulb); timer 0:35; 3 score rows; Next Block (crystal) | `summit_climb` + `rising_hazard` (avalanche). COVERED | Ice | defender | Both (MG42) |
| 3 | Rubble Rumble | Clear layers to dig down through rock in a lava cave; clears free gems; mining karts are the mascots | **Depth: 32m** counter; Next Block; 3 score rows | `dig_down` + A4 `material_hp` + `crumble_floor`. COVERED (A9 helper partly NEW) | Cave (lava-cave skin) | twist | Both (MG44) |
| 4 | Fort Frenzy | Build a block castle, then lob pieces at the rival castle with a catapult | Timer 0:35; 3 score rows; Next Block | `fort_siege` (meadow skin `catapult_castle`). COVERED (A4, A5 NEW) | Meadow skin | twist | Tourn-first (MG43); Solo vs scripted fort |
| 5 | Rolling Rumble | Piece-shaped track segments pave a winding forest road for a kart; stars and hazards ahead | Timer 1:12; **Next Hazard** and **Next Block** slots; star coins | `road_race` + `star_coins`. COVERED | Forest | race | Both (MG41) |
| 6 | Tumbling Towers | Stack on a round tilting plate over the sea; chest crane drops treasure; a sea serpent pesters | **Balance / Danger** thermometer (red top); **Hold Item** slot (chest); Treasure slot | `balance_plate` on Jolt (flag F2); hold = `spawn.hold_enabled`; treasure = SP11 / GO08. COVERED | Pirate (Forest treetop skin allowed) | balance | Both (MG38) |
| 7 | Shatter Shootout | Two ships fire at one shared tower of mixed materials; clears mint ammo | Timer 0:45; per-player **Destruction %** (5/10, 0/2); ammo and material icons | `fort_siege` with **`target: shared_tower`**. PARTIAL (new param; A4, A5 NEW) | Pirate | twist | Tourn-first; Solo vs a bot ship |
| 8 | Frenzy Footholds | Stack glowing blocks as footholds above rising lava; hooks pull mascots up | **Heat** thermometer plus **Rising Lava Height: 50m** bar; **Live Leaderboard** (4 rows); hazard signs | `summit_climb` + `rising_hazard` (lava). COVERED. Leaderboard widget NEW (HUD) | Lava | defender | Both |
| 9 | Bridge Dash | Span the gap while a **heat gauge** punishes overbuilding; next piece shown as "module" | **Heat 10% to 30%** thermometer; Next Module; timer 1:20; 3 rows | `bridge_dash` + A1 `gauge` (`heat`, mode high, relief per layer). PARTIAL (A1 NEW) | Meadow (sky isles) | race | Both (MG37 + `rising_hazard`) |
| 10 | Fort Blast | Build a fort, then fire block ammo from cannons across a sea cliff | **Fort HP** bar (green/red); aim-arc preview; Next Ammo; **Block Strength** vertical bar; timer 0:50 | `fort_siege` + A4. COVERED | Pirate | twist | Both (MG43) |
| 11 | Maze Heist | Place pieces to route the runner through a sleeping golem's maze and collect keys | **Guard Sleep** bar; **Keys Left 1/3**; minimap; Next Key; 3 rows | `route_runner` (`key_stamp`, `guard`). COVERED (reuses MG17 maze view, to confirm) | Cave | twist | Both (MG48) |
| 12 | Summit Scramble | Build a block mountain to the trophy while lava rises; last climber alive wins | **Lava Rise** bar with warning icon; **Players Alive**; Next Block (gear); timer 0:30 | `summit_climb` + `rising_hazard`. COVERED | Lava | defender | Tourn-first (MG42); Solo as hard track |
| 13 | Clockwork Conveyor | Sort belt pieces into hoppers while climbing above lava | **Height to Safety 10% to 80%** gauge; Next Block; timer 0:45 | `conveyor_sort` + `rising_hazard`. PARTIAL (A7 NEW) | Clockwork | twist | Both (MG45) |
| 14 | Kraken Blockade | Wall the tentacles out with blocks and fire clears at the boss | **Boss Health Bar**; timer 0:58; Next block | `boss_hp`. COVERED (A6 NEW; flag F3) | Pirate | defender | Both (MG46) |
| 15 | Digging Frenzy | Dig a shaft; clears break dirt and free gem blocks | **Depth: 32m**; Next block; 3 rows | `dig_down`. COVERED | Cave | twist | Both (MG44) |
| 16 | Chroma Sky Climb | Stair rainbow blocks to the stars while a storm cloud blows | **Stability** thermometer; timer 0:35; 3 rows; Next Block | `stair_path` + `gust_wind` + A2 spring variant. COVERED | Celestial | balance | Both (MG47) |

### 1.2 mockup_06, 12, 14, 15, 16, 17

| # | Mockup title -> our title | Verb and goal | Meter and HUD | Covered by | Biome | Type | Mode |
|---|---|---|---|---|---|---|---|
| 17 | Temple Roller Run -> **Rolling Idol Run** | Fill the gaps in a temple path while a boulder rolls behind; coins on the way | **Hazard Warning** thermometer (80%); coins; Next Block; 4 rows | `bridge_dash` + **chaser overlay** (rule `snowball`, boulder skin). PARTIAL | Forest | race | Both |
| 18 | Submarine Salvage | Clear down to treasure crates on a sea floor; a crane drops pieces | **Treasure Salvaged 0/30**; **Pressure Meter** (blue); Next Block | `dig_down` (treasure) + A1 `pressure`. PARTIAL (A1, A9 NEW) | Underwater | completing | Both |
| 19 | Factory Frenzy Assemble -> **Factory Frenzy** | Deliver the cubes an order card asks for into the machine; wrong ones jam the belt | **Conveyor Speed** bar; Next Block (gear); timer 0:35 | `conveyor_sort` in **order mode** (A7). PARTIAL (NEW). Same module as 13, different params | Clockwork | completing | Both |
| 20 | Cosmic Gravity Goal -> **Zero-G Goal Rush** | Pieces become bumpers and walls that steer a plasma ball into the rival goal | **Speed Boost** meter; Next Block; timer 0:14 | **NEW** (no module; needs ball physics) | Celestial | funny | Tourn only |
| 21 | Meadow Mayhem herd sheep -> **Shepherd's Pen** | Drop pieces as fences to steer wandering sheep into the pen; a piece landing on a sheep bonks it away | **Sheep 5/10** counter; timer 1:15; score and hearts card | `route_runner` (followers: sheep) + A11 `herd_critter`. **NEW** (A11 deferred) | Meadow | funny | Both |
| 21b | Meadow Mayhem "bridge the gap" (mockup_12) | Log-and-rock bridge across a waterfall while critters throw acorns | Timer 2:30; Next Item (vine log) | Same as #1 plus the acorn overlay. COVERED. **Fold into Bridge Bashers; no separate level** | Meadow | race | Both |
| 22 | Candy Crushers -> **Sugar Siege** | Build a cake fort, then fire candy ammo at the rival | Next Ammo (spiked candy); card goal "Fortress Smash" | `fort_siege` (candy skin `candy_cannon`). COVERED | Candy | twist | Both (MG43) |
| 23 | Candy Dodger | Pave and cross a frosting road while gumdrops fall; pieces become cover | **Next Hazard** (wrapped candy); hearts | `bridge_dash` + rule `gumdrop_hail`; tournament = MG28 Block Dodge reskin. COVERED | Candy | defender | Both |
| 24 | Glacier Gauntlet | Place ramp-blocks on an ice grid so the sledder clears a rolling snowball | **Next Ramp** slot; hearts | `floe_survive` + `snowball` + `crumble_floor`; ramp piece = `bounce_pad` skinned as a ramp. PARTIAL | Ice | defender | Both (MG50) |
| 25 | Glacier Rush | Steer the sledder across ice to grab stars by placing walls and ramps | **Stars 7/12** counter (board labels it "Next Block"; relabel); hearts | `route_runner` (goals = stars) + `ice_slide`. COVERED, **but `campaign-minigames.md` lists `road_race`**: amend (flag in 2.2) | Ice | race | Both |
| 26 | Cosmic Climb | Place connectors to spiral a path up a space tower; lasers sweep | **Next Connector** slot; hearts | `stair_path` on a spiral board + A8 `laser_sweep`. PARTIAL (A8 NEW; spiral = BL19 wrap, Pr) | Celestial | race | Both |
| 27 | Lava Rumble | Patch and defend a ring platform while rivals bump you toward lava | **Power-Up** slot (glove); timer 1:15; hearts | `floe_survive`, shared floe (MG50). Glove = potion. COVERED | Lava | funny | Tourn-first |
| 28 | Jungle Dash | Fill gaps and bridge spikes while a boulder chases | **Item** slot (boots); timer 1:15; hearts | `bridge_dash` + chaser overlay (as #17), mirrored lanes. PARTIAL | Forest | race | Tourn-first (MG37) |
| 29 | Gem Grab -> **Crystal Cart Haul** | Dig to gem veins, then route cubes onto cart rails to the base | **Tool** slot (pickaxe); timer 1:15; hearts | `dig_down` (gems) + mg19 gem carry (exists). COVERED | Cave | completing | Tourn-first (MG44) |
| 30 | Neon Splat -> **Glow Paint Clash** | Landing pieces claim hex tiles on a shared floor; rivals can re-claim | **Weapon** slot (paint gun); hearts; tile share | `paint_claim` (A10). **NEW** (session layer, host-arbitrated) | Neon | twist | Tourn-first (MG39); Solo vs scripted painter |
| 31 | Cyber Defender | Build shield walls; clears fire shots at waves of viruses | **Targets 8/15** counter; shield icon; hearts | `fort_siege` with **`mode: defend`** (waves). PARTIAL (new mode) | Neon | defender | Both |
| 32 | Bridge Builders (hub) | Race to build a tetromino bridge between pillars | **Score 50**, timer **:25**, trophy **20**; 3 player badges | `bridge_dash` mirrored lanes (MG37). COVERED | Hub island 1 (meadow skin) | race | Tourn |
| 33 | Bomb Defuse (hub) | Fill red and blue ring cubes around a bomb before the fuse ends | None visible; fuse on the bomb | `ring_defuse` + `countdown_bomb`. COVERED | Hub island 2 (clockwork skin) | completing | Both (MG49) |
| 34 | Balloon Race (hub) | Pave a cloud track; balloons lift cargo carts | None visible | `road_race` + A12 `balloon_lift`. PARTIAL (A12 deferred) | Hub island 3 (sky skin) | race | Both (MG41) |
| 35 | Lava Escape (hub) | Climb or hold a lava-cube pyramid on a volcano island as it crumbles | None visible | `floe_survive` (mirrored, not shared). COVERED | Hub island 4 (lava skin) | defender | Both (MG50) |
| 36 | Quantum Spire | Mood sheet: a sci-fi hex board, a Next Block monitor, two astronauts | Next Block monitor; two score panels | **Skin, not a module**: celestial / neon arena with a hex-decal floor over the square grid; reused by `paint_claim` | Celestial / Neon | twist | Tourn arena + Celestial L10 stage |

### 1.3 Renames for trademark and cast reasons

| Mockup name | Our name | Why |
|---|---|---|
| Candy Crushers | **Sugar Siege** | Too close to a famous match-3 title |
| Neon Splat | **Glow Paint Clash** | "Splat" reads as a Nintendo paint-shooter; no Nintendo IP |
| Gem Grab | **Crystal Cart Haul** | A known mobile-game mode name |
| Temple Roller Run | **Rolling Idol Run** | Close to a famous endless-runner title |
| Cosmic Gravity Goal | **Zero-G Goal Rush** | Close to a known car-football title |
| Meadow Mayhem (herd sheep) | **Shepherd's Pen** | The same name is used on two different mockup games; ours keeps one game per name |
| Factory Frenzy Assemble | **Factory Frenzy** | Shorter, matches the sheet title |
| "Party Quest", "Party Battle", "Wacky Party", "Tetro Party Dimensions" | none | Logos and ribbons from other products; the hub is the **Tumble Fair Midway** |

Kept as is (generic or descriptive): Bridge Bashers, Avalanche Ascent, Rubble Rumble, Fort Frenzy, Rolling Rumble, Tumbling Towers, Shatter Shootout, Frenzy Footholds, Bridge Dash, Fort Blast, Maze Heist, Summit Scramble, Clockwork Conveyor, Kraken Blockade, Digging Frenzy, Chroma Sky Climb, Submarine Salvage, Candy Dodger, Glacier Gauntlet, Glacier Rush, Cosmic Climb, Lava Rumble, Jungle Dash, Cyber Defender, Bridge Builders, Bomb Defuse, Balloon Race, Lava Escape, Quantum Spire.

### 1.4 What the boards say about HUD (for ux-designer and the HUD programmer)

| Pattern on the boards | Meaning | Rule |
|---|---|---|
| Vertical thermometer with a flame or skull bulb (Altitude, Heat, Balance, Stability, Hazard Warning, Height to Safety, Pressure, Speed Boost) | One widget, many meanings | One `vertical_gauge` widget (HUD keys `gauge_state`, `tilt_state`, `boss_state`). Two kinds: **danger** (fills up = bad, red on top: Balance, Heat, Hazard Warning, Pressure) and **progress** (fills up = good, green on top: Altitude, Height to Safety, Speed Boost). Never mix the two in one level |
| Horizontal bar (Fort HP, Boss Health, Guard Sleep, Rising Lava, Conveyor Speed) | Same idea, sideways | `horizontal_bar`, same colour grammar |
| "Next Block / Item / Module / Hazard / Ramp / Ammo / Connector / Key" slot, one per sheet | One preview slot whose label changes | One `next_slot` widget (icon plus label key). A level may show **two** (Rolling Rumble: Next Hazard plus Next Block). Cap: 2 gauges plus 2 slots plus the timer (the wave-4 budget of 2 meters) |
| Player rows: portrait plus score, 2 to 4 per sheet, left and right | Tournament and duel readout | `player_row`; collapses to a single score card in solo |
| Counters "5/10 sheep", "7/12 stars", "8/15 targets", "0/30 treasure", "Keys 1/3" | Goal progress | `goal_counter`, goal text on a parchment tag (as on mockup_12 to 15: "Goal: herd sheep!") |
| Hearts on cards | Lives | Elimination rounds only (flag F5) |
| Live Leaderboard (Frenzy Footholds), Players Alive (Summit Scramble), minimap (Maze Heist) | One-off panels | Build only with their module |
| Style/15 mobile frame: pause, Score with 3 stars, Next, plus a **tray of three pieces** at the bottom | Phone HUD | The tray is shown as the **3-piece queue preview** (`queue_lookahead 3`). A real "pick 1 of 3" draft (AR08) is a twist-level choice, not the default. Confirm with game-designer |

---

## 2. Campaign arcs

### 2.1 The tutorial island (style/01 panel 2, style/02 panel 1, style/07)

Style/01 puts the tutorial **on its own island** before the story begins and exploration. Style/07 names two lessons: **First Steps** and **Balance and Physics**; style/01 and 02 add **Learn to Stack** ("Tap to rotate, drag to drop!", the wizard on a cloud, a ghost outline) and **Drag and Match**. Decision for review: a three-level **Wizard's Practice Island** before `meadow_01` (option (a)); the alternative (b) is to fold the lessons into `meadow_01` and `meadow_02`, which saves a map node but leaves no skip for veterans. Recommended: (a), skippable, no stars, no gate.

| id (working) | Style board | Teaches | Module | Type | Board | Time | Fail |
|---|---|---|---|---|---|---|---|
| `tutorial_01` First Steps | style/07 "Tap and place the block to build your tower!" | Move, drop, land. A pointer hand follows the ghost to a highlighted cell | `clear_layers` n=1, no hazards | funny (balloon-gentle) | 8x8, H8 | 2 min | none |
| `tutorial_02` Learn to Stack | style/01 panel 2, style/02 panel 1 | Rotate button, drag to drop, fill a layer, clear it | `clear_layers` n=2 | completing (a 3-cube outline) | 8x8, H8 | 3 min | rescue |
| `tutorial_03` Balance and Physics | style/07 "Watch the wind!" | The balance thermometer, a tilting plate, wind arrows (`gust_wind`), recovering a wobble | `balance_plate` (Jolt) + `gust_wind` | balance | 8x8 plate, H10 | 3 min | topple = 2 cells off, no fail |

Rules: the next piece is random every attempt (first two from {O, I} as in `tumble_fair_01`); each hint triggers on an **event** (piece landed in a hole, meter above 60%), not on a specific piece. The pirate guide on the plate in style/07 is the pirate cast member; the wizard on the cloud narrates (the boards show a knight too: flag F4). `tutorial_03` spends the `balance_plate` introduction, so **Candy and Pirate no longer count it as new** (`campaign-minigames.md` rule 12).

### 2.2 Per-biome arcs

Slots follow `campaign-minigames.md`: 01-02 legacy, 03 A, 04 A+O, 05 B, 06 B+O, 07 A to B, 08 R+O, 09 B to R+O, 10 finale chain, then bonus and hard h1-h3. The tables below bind **mockup titles to those slots in difficulty order**. Authored levels keep their boards and rules (catalog `meadow_01` to `meadow_10`, and so on); a slot binds either as phase 1 or by an amendment, as that GDD already allows.

Intensity key: 1 calm, 2 steady, 3 busy, 4 tense, 5 boss.

| Biome | 03 (A) | 04 | 05 (B) | 06 | 07 | 08 (R) | 09 | 10 finale | Bonus | Hard track and tournament-first |
|---|---|---|---|---|---|---|---|---|---|---|
| **Meadow** | Hay Bale Sprint (`clear_layers`, 2) | + Dandelion Gust (3) | **Bridge Bashers** (`bridge_dash`, 2) | + gust (3) | Sprint to Bridge (3) | **Shepherd's Pen** (`route_runner`, 2) | Bridge Dash with heat (`bridge_dash` + A1, 3) | Sprint, Bridge, Sheep (4) | Fruit Stack (`balance_plate`) | h: Fort Frenzy (meadow skin, vs scripted fort); Bridge Builders (tournament) |
| **Candy** | Cake Stackers (`balance_plate`, 2; already taught) | + sugar breeze (3) | **Sugar Siege** (`fort_siege`, 3) | + `gumdrop_hail` (4) | Cake to Siege (4) | Hay-style Sprint (`clear_layers`, 2) | **Candy Dodger** (`bridge_dash` + hail, 3) | Cake, Siege, Gingerbread Giant (`boss_hp`, 5) | Frosting Claim (`paint_claim`) | h: Candy Dodger in duel form (MG28 skin) |
| **Ice** | **Avalanche Ascent** (`summit_climb`, 3) | + avalanche pressure (4) | **Glacier Gauntlet** (`floe_survive`, 3) | + `crumble_floor` (4) | Ascent to Gauntlet (4) | Ice-ramp Bridge (`bridge_dash`, 2) | Gauntlet to Bridge (4) | Bridge, Ascent, Iceberg Sumo (5) | **Glacier Rush** (`route_runner`, goals = stars; see below) | h: Summit Scramble (tournament-first) |
| **Underwater** | Coral Conduit (`route_runner`, 2) | + silt (3) | **Submarine Salvage** (`dig_down` + pressure A1, 3) | + silt (4) | Conduit to Salvage (4) | Reef Climb (`summit_climb`, 3) | Salvage to Climb (4) | Conduit, Salvage, **Crab King** (`boss_hp` + `crab_claw`, 5; flag F3) | Current Racers (`road_race`) | h: Lava-free Salvage variants |
| **Pirate Cove** (flag F1) | **Fort Blast** (`fort_siege`, 3; first appearance solo) | + `crab_claw` (4) | **Tumbling Towers** (`balance_plate` on a deck, 3) | + wind (4) | Fort to Towers (4) | Plank Bridge (`bridge_dash`, 2) | Towers to Bridge, + `crab_claw` (4) | Fort, Towers, **Kraken Blockade** (5) | **Shatter Shootout** vs a bot ship (`fort_siege` shared tower) | h: Shatter Shootout tournament, Fort Blast duel |
| **Lava** | **Volcano Dash** (`bridge_dash`, 3) | + lava rise (4) | **Frenzy Footholds** (`summit_climb`, 4) | + lava (4) | Dash to Footholds (4) | **Lava Escape** (`floe_survive`, 3) | Footholds to Escape (4) | Dash, Footholds, **Molten Guardian** (`boss_hp`; style/07 "Boss Battle!", 5) | **Lava Rumble** vs bots (`floe_survive` shared) | h: Summit Scramble (also here) |
| **Forest** | Tumbling Towers treetop (`balance_plate`, 2) | + rotten logs (3) | Jungle Vine Ascent (`summit_climb`, 3) | + logs (4) | Towers to Vines (4) | **Rolling Rumble** (`road_race`, Canopy Chaos story, 3) | Vines to Rumble (4) | Towers, Vines, Boss Bash (5); **Goblin Ambush** (`fort_siege` `mode: defend`, style/07, 4) sits at 09 | Woodpile Sprint (`clear_layers`) | h: **Rolling Idol Run**, **Jungle Dash** (chaser races) |
| **Cave** | **Digging Frenzy** (`dig_down`, 2) | + rubble (**Rubble Rumble**, 3) | **Maze Heist** (`route_runner`, 3) | + guard (4) | Dig to Heist (4) | Sprint (`clear_layers`, 2) | Heist to Sprint (4) | Dig, Heist, Crystal Golem (5) | Mine Bomb (`ring_defuse`) | h: **Crystal Cart Haul** (tournament-first) |
| **Clockwork** | **Clockwork Conveyor** (`conveyor_sort`, 3) | + lava below (4) | **Bomb Defuse** (`ring_defuse`, 3) | + lava (4) | Sort to Defuse (4) | Gear Balance (`balance_plate`, 3) | **Factory Frenzy** (`conveyor_sort` order mode, 4) | Sort, Defuse, **Gear Titan** with a two-sided temperature band gauge (style/02 "The Forge Boss", 5) | Castle Siege Crash (`fort_siege`) | h: Factory Frenzy at speed |
| **Neon** | Glow Paint Clash vs scripted painter (`paint_claim`, 3) | + glitch tiles (4) | Neon Maze (`route_runner`, 3) | + gravity flip (4) | Paint to Maze (4) | Rail Rush (`road_race`, 3) | Maze to Rush (4) | Paint, Maze, Rail Rush (5) | Laser Sprint | h: **Cyber Defender** (`fort_siege` defend), Quantum Spire arena |
| **Celestial** | **Chroma Sky Climb** (`stair_path` + `gust_wind`, 3) | + storm cloud (4) | Galactic Grab (`road_race`, 3) | + laser (4) | Climb to Grab (4) | **Cosmic Climb** (`stair_path` spiral + A8, 4) | Grab to Climb (5) | **Cosmic Gateway** (style/02 panel 5, style/07 "Cosmic Nexus"): Climb, Grab, Storm Cloud with portal-pair content (SP16), staged on the **Quantum Spire** hex-decal board (5) | Moon Stack (`balance_plate`) | h: **Zero-G Goal Rush** only if built (gap table) |
| **Tumble Fair** (side) | per `tumble-fair.md` | | Balloon Race (`road_race` + A12) | | | | | Baron Balloon (`tumble-fair.md` 05) | Prize Shelf | the hub islands, section 3 |

**Mid-biome rules respected.** A biome introduces at most 2 new primary modules and the first appearance is solo (`campaign-minigames.md` rule 12). Check: Meadow introduces `clear_layers` and `bridge_dash` (+ `route_runner` as R: at the limit, as the existing plan already does); Candy introduces only `fort_siege` (balance taught in the tutorial); Ice introduces `summit_climb` and `floe_survive`; Underwater `dig_down` (+ `route_runner` known); Pirate introduces nothing new (`fort_siege`, `balance_plate`, `bridge_dash`, `boss_hp` all known by then, except `boss_hp` which Candy's finale already taught); Lava, Forest, Cave, Clockwork, Neon and Celestial each introduce at most 2.

**Level-type mix check** (`level-type-mix.md`: all six types in each biome's 10 levels). Module slots give: race (bridge, road), balance (`balance_plate`, stability), defender (hazard overlays, bosses, `fort_siege` defend), funny (Shepherd's Pen, Candy Dodger, Lava Rumble), completing (existing `fill_shape` levels, Salvage, Bomb Defuse, Factory Frenzy), twist (siege, dig, maze). Meadow's `funny`, Candy's `balance`, Ice's `completing` and Underwater's `race` slots remain served by the **legacy authored levels** in `level-type-mix.md`; no biome loses a type.

**Mapping notes**

- **Glacier Rush**: the board is an open ice grid with stars, closer to `route_runner` (goals) than `road_race` (`campaign-minigames.md` lists it under `road_race` and as the Ice bonus). Recommend amending that doc; the bonus stays.
- **Story levels**: style/02 "Canopy Chaos: Story Quest" (a buggy hauling blocks, monkeys) = Forest 08 Rolling Rumble with the acorn-monkey overlay (`squirrel_heist`). "Forge Boss: Advanced Event" = Clockwork 10 (a two-sided temperature gauge is the A1 `band` mode; the board shows 45 degrees and minus 35 degrees). "Molten Guardian" (style/07) = Lava 10; the two bosses share one `boss_hp` module with different skins. "Lost Tomes" (style/02 panel 2) is the **map-level story frame**: each finished biome returns a tome to the library (narrative-director owns beats). "Grand Finale" (style/02 panel 6, a treasure chest, fireworks) = the campaign-end reward scene after Tumble Fair's Grand Tour.
- **Goblins' ambush** (style/07, "Defend the fort!") is the only pure **defender-fort** board: a cannon tower under rock fire. It is `fort_siege` with `mode: defend` (build phase, then waves; see gap 5) rather than a new module.
- **Potions on**: the Power-Up / Item / Tool / Weapon slots (mockup_14) are the potion slots. In the campaign they are off by default (`campaign-structure.md` rule 8) except where a biome enables buffs; in tournaments they follow the lobby's Items toggle (style/14 "Items On").

### 2.3 Pirate Cove (new biome, working title)

- **Theme**: a tropical island bay with palm trees, a wooden fort on cliffs, a rope-and-plank harbour, a friendly sea serpent in the shallows, and the Kraken at the finale. Pirate is the biome's cast member and tutorial guide (style/07's pirate on the balance plate).
- **Defender hook**: `crab_claw` (claws pinch the stack, telegraphed; exists in `crab_claw.json`).
- **Block**: pirate skin is missing from style/13. Proposed: sun-bleached driftwood planks with rope lashing and brass studs (art-director to confirm).
- **Music and audio**: sea shanty on a squeeze-box; cannon thumps duck the music by 3 dB; a gull motif tags each phase banner.
- **Size**: 10 main plus bonus plus h1-h3 (option (a) in flag F1), or 5 plus bonus (option (b); then keep Fort Blast, Tumbling Towers, Plank Bridge, Kraken and Shatter Shootout, drop the second pairing).

---

## 3. The Party Quest hub (mockup_16) as the Tumble Fair Midway

**What the board shows.** A central wooden platform with a banner, a scoreboard (four rows: wizard, pirate, astronaut, robot, each with two score columns), four players standing in a line, cannons and barrels at the rim; four glowing plank bridges run to four floating islands: Bridge Builders (grass, NW), Bomb Defuse (brass machine, NE), Balloon Race (cloud track, SW), Lava Escape (volcano, SE). The cast is exactly our four-player line-up.

**Design.**

1. **Name and host.** The platform is the **Tumble Fair Midway**; Baron Balloon floats above it as host, leaning down to announce rounds (his basket carries the scoreboard banner in place of the "Party Quest" banner). Our logo only.
2. **Setup and lobby (style/14, step 1).** Four wizard badges P1 to P4 (colour + shape: circle, triangle, square, star) on the platform; Ready toggles; rounds (3, 5, 7, 13), "first to N wins", Game mode **Normal / Mixed**, Items **On / Off**. **Normal** = the classic race templates; **Mixed** = the Randomizer's full pool including island minigames (`minigame_share` 0.4). Empty seats get bots (`campaign-minigames.md` F2).
3. **Round pick (style/14, step 2).** The wheel shows **category slices**, not 50 templates: Clear Race, Highest Tower, Largest Footprint (the three on the board) plus **the four islands** in Mixed. Landing on an island makes its **bridge glow and extend**; the camera crosses it; the Randomizer then picks a template inside that island's family (the Randomizer's F3 weights are unchanged). One re-roll for the trailing player (existing rule 6). The three classic wheel slices map to `versus_clear_race`, `versus_build_race` and a **new** `versus_footprint` (gap table 12).
4. **The four islands are venues, each a module family.**

| Island (mockup) | Skin | Module family it hosts | Seat arrangement |
|---|---|---|---|
| Bridge Builders | meadow grass | `bridge_dash`, `stair_path`, `clear_layers` (race to span) | mirrored lanes on pillars |
| Bomb Defuse | clockwork brass | `ring_defuse`, `conveyor_sort`, `route_runner`, `paint_claim` (task rounds) | mirrored boards around a central machine |
| Balloon Race | sky cloud | `road_race`, `summit_climb` + `rising_hazard`, `balance_plate` (speed and height) | mirrored track, shared view |
| Lava Escape | lava rock | `floe_survive`, `fort_siege`, `boss_hp`, `dig_down` (survive and smash) | shared floe or facing forts |

   Each template still skins to the player's most recent biome art via unlocks (campaign-minigames tournament rule 2). New venues appear as the campaign unlocks them: **the hub starts with its four islands and gains a bridge for each biome whose first appearance of a module was cleared**, up to eight bridges (octagonal platform, two extra at the Pirate Cove and Celestial milestones). That makes the campaign visibly feed the tournament.
5. **Round play (style/14, step 3).** Four mirrored boards (or one shared arena) in a 4-up frame: P1 to P4 badges, a progress chip ("6 / 12"), a one-line rule card ("Be the first to clear the highlighted blocks!"). Mockup_15's portrait 4-up grid is the phone layout. Every seat uses the same `round_seed`.
6. **Standings (style/14, step 4).** Back on the Midway: the scoreboard lights, Wins and "Match point!" chips. **Next Round** returns to the wheel.
7. **Win (step 5).** The winner (wizard on a cloud with a trophy in the board) is lifted by the Baron's balloon; round history shows one badge per round. Play again or Home.
8. **Scope.** The Midway is **UI plus a 3D diorama**, not a gameplay level; the hub has no block board of its own. It follows the solo campaign (user order).

---

## 4. Gap table: mockup minigames with no matching module (NEW list)

Fun: 1 low to 5 high for the 4-player party and the solo campaign. Cost: S (under 2 days), M (about a week), L (2 weeks), XL (more than a month). "Priority" is fun over cost with dependencies (a dependency lifts priority).

| Rank | NEW item | Needed by (mockup titles) | Fun | Cost | Priority and notes |
|---|---|---|---|---|---|
| 1 | **Module framework** (`modules` array, phases, `carry`, validator, `assets/data/modules/*.json`) | all 36 | 5 (enabler) | L | Do first; spec exists in `campaign-minigames.md` |
| 2 | **A1 `gauge`** plus the shared HUD thermometer | 25 panels: Bridge Dash, Frenzy Footholds, Submarine Salvage, Clockwork, Temple Roller, Chroma Sky Climb... | 4 | M | One widget, one test suite; highest reuse |
| 3 | **A3 `span_goal`** + walker (`bridge_dash`) | Bashers, Dash, Candy Dodger, Rolling Idol Run, Jungle Dash, Bridge Builders | 5 | M | Generalises mg06 `bridge_path`; first vertical slice |
| 4 | **`balance_plate` on Jolt** (flag F2) | Tumbling Towers, tutorial 03, Fruit Stack, Cake Stackers | 5 | L (Jolt feel) | Fallback A2 grid tilt costs M |
| 5 | **`fort_siege`** = A4 `material_hp` + A5 `siege_shot` + single-player session host | Fort Frenzy, Fort Blast, Shatter Shootout, Sugar Siege | 5 | L | The flagship duel; defend mode (below) is an add-on |
| 6 | **`boss_hp`** (A6) | Kraken, Molten Guardian, Crab King, Gear Titan, Gingerbread Giant | 5 | M | Gives every finale its face; needs A1 for the band gauge |
| 7 | **`herd_critter`** (A11, deferred) | Shepherd's Pen (user-chosen sheep) | 4 | M | Charm item; `hatching_eggs` hop logic is reusable |
| 8 | **`paint_claim`** (A10, session layer) | Glow Paint Clash, Island Claim | 4 | L | Needs host arbitration and a multi-owner floor |
| 9 | **`conveyor_sort` / A7 `delivery_intake`** | Clockwork Conveyor, Factory Frenzy | 3 | M | Order cards plus jam gauge |
| 10 | **`fort_siege` `mode: defend`** (waves, kill counter) | Goblin Ambush, Cyber Defender | 4 | M | Reuses the siege HUD; two levels from one add-on |
| 11 | **A9 `strata_dig`** helper + gems | Rubble Rumble, Digging Frenzy, Submarine Salvage, Cart Haul | 3 | M | Mostly composition |
| 12 | **`versus_footprint`** template (Largest Footprint from style/14) | Tumble Fair wheel | 3 | S | Score = cells covered at layer 0; pure scoring change |
| 13 | **Chaser overlay** (boulder or snowball behind the runner) | Rolling Idol Run, Jungle Dash, Glacier Gauntlet | 4 | S | `snowball` rule exists; reskin plus a trigger |
| 14 | **A8 `laser_sweep`** | Cosmic Climb | 3 | S to M | Telegraphed line; low risk |
| 15 | **A12 `balloon_lift`** | Balloon Race (hub) | 3 | S to M | Defer until the hub exists |
| 16 | **`route_runner` goals = stars** (`ice_slide` floor) | Glacier Rush | 3 | S | Parameter on an existing module |
| 17 | **HUD widgets**: `next_slot`, `player_row`, `goal_counter`, live leaderboard | all | 3 | M | Needed for the 4-up tournament frame |
| 18 | **Spiral / wrap board** (BL19, Pr) | Cosmic Climb | 2 | M to L | Needs ADR-0002 neighbour hook; alternative: flat stair with a spiral camera (S) |
| 19 | **Ramp / wedge piece** ("Next Ramp") | Glacier Gauntlet | 2 | M | Reuse `bounce_pad` skinned as a ramp (S) first |
| 20 | **`floe_survive` shared-floe bump** with potion glove | Lava Rumble | 3 | M | MG50 spec exists; bump is a push effect |
| 21 | **Zero-G Goal Rush** (ball physics, goals) | Cosmic Gravity Goal | 2 | XL | Recommend **cut or defer**; needs ball physics plus a net model, and the block verb is weak |
| 22 | **True hex board** | Quantum Spire | 2 | XL | Cut; use a hex-decal floor on the square grid (S) |

**Ranked by fun, then cost (top picks):** (1) bridge_dash, (2) fort_siege, (3) balance_plate, (4) boss_hp, (5) gauge. **Cheapest wins:** versus_footprint, chaser overlay, goals = stars, Quantum Spire as a skin.

**NEW-module list (final report):** `span_goal` (bridge), `gauge`, `tilt_plate` or Jolt `balance_plate`, `siege_shot` + `material_hp` (+ defend mode and shared-tower target), `boss_hp`, `delivery_intake`, `laser_sweep`, `strata_dig`, `territory_claim` (`paint_claim`), `herd_critter`, `balloon_lift`, plus the small additions chaser overlay, `versus_footprint`, ramp skin. Cut or defer: Zero-G Goal Rush, true hex board.

---

## 5. Next steps for the gameplay programmers

Order is dependency-first; each step names a retained screenshot, as `coding-standards.md` requires.

1. **Module framework**: add `modules`, `phase`, `until`, `carry`, overlays and the validator in level data (`campaign-minigames.md` rules 1-12); load `assets/data/modules/<id>.json`; treat legacy goals as `legacy_goal`. Gate: all existing levels load unchanged. Evidence: a 2-phase demo level.
2. **HUD widgets** (`vertical_gauge`, `horizontal_bar`, `next_slot`, `goal_counter`, `player_row`), data-driven from section 1.4. Evidence: one screenshot of each widget at 720 p.
3. **First vertical slice: Bridge Bashers** = `bridge_dash` (A3 `span_goal`, walker, `pace_mascot` ghost) on a 12x8 board, meadow skin. This proves modules, HUD and the race type end to end. Then add the heat gauge (A1) to make Bridge Dash.
4. **Tutorial island** (3 levels, section 2.1) once the balance decision (F2) is made; build `balance_plate` first on grid `tilt_plate` as a spike for feel and compare against Jolt before committing.
5. **`fort_siege` core**: `material_hp`, `siege_shot`, single-player session host (open decision 4 in `minigame-mechanics-wave4.md`), meadow and candy skins, scripted rival fort; then `target: shared_tower` (Shatter Shootout) and `mode: defend`.
6. **`boss_hp`** with phases that switch on `storm_bolt`, `crab_claw`, `climber_boss`; one boss face per biome as a skin.
7. **Level data**: the Pirate Cove biome record and level files after flag F1; the Tumble Fair Midway scene and wheel after the solo campaign has 3 biomes on modules; `versus_footprint` template.
8. **Tournament seeds**: shared `round_seed` per module stream; bots for each module (`campaign-minigames.md` F2); mid-round disconnect takeover.
9. **Cross-checks for the game-designer** (do not edit those GDDs from this file): amend `campaign-minigames.md` for flags F1, F3 and Glacier Rush (`route_runner`), and note the new tutorial island and Pirate Cove in `campaign-structure.md`; add the Midway venues to `mode-minigame-randomizer.md`.
10. **Per-level params**: each new level needs `modules[].params` within safe ranges and the F3 difficulty scale (`campaign-minigames.md` F3: `p = p_base x (1 + s_p x (k - 1))`); the level-designer provides those in a follow-up pass per biome.

---

## 6. Open questions and review checklist

- Does the user want the Pirate Cove as a main biome (F1)? Which biome does the Kraken belong to (F3)?
- Is the tutorial island a separate three-level island (recommended) or folded into Meadow?
- Are goblins, knights and dwarves in the cast (F4)?
- Jolt tilt in tournaments: reported result vs lockstep (F2)?
- The bottom tray of three pieces in style/15: queue preview or a draft pick?
- Should the hub grow bridges as the campaign unlocks biomes (section 3, point 4)?

**Playtest checks** (for later): at least 80% can say what a module wants within 5 s of its banner (`campaign-minigames.md` criterion 12); at least 75% recognise a tournament round from its campaign level (criterion 15); the Midway wheel resolves in 3 s or less (Randomizer game-feel target).
