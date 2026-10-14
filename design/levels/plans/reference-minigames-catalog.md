# Reference Minigame Catalogue (DRAFT, extended in place)

Status: PART 1 written early on request. Parts 2+ (mockup_18..34, remaining style boards) are appended below as they are read.
Legend for engine status: [E] exists by name in rules / mechanics / templates, [P] partial or close cousin, [N] new.
Names are traced for reference only. Every name below needs an original working name (suggested in the entry). No logos, no IP characters.

## Part 1 entries (boards read so far)

### Board: minigame_mockups/mockup_01.jpg (style/09_minigames_a.jpg shows the same content)
- **A01 Bridge Bashers** (working name: Cliff Carriers). 3-4 players, versus race. Players physically carry a block (grass, ice, wood) from their cliff and place it into a river gap to make a bridge, then run over. Side view, two cliffs with a waterfall river, still platform. HUD: timer, score list, next block, avatars. Mechanics: avatar carries block [N], bridge path goal [P: mg06 path goal], live multiplayer [P]. Fit: Meadow / forest, early campaign.
- **A02 Avalanche Ascent** (Slope Scramble). 3 players race. Climb a snowy cliff while ice cubes and rocks tumble down; altitude thermometer, lightning storm. Falling blocks are both hazard and foothold. Mechanics: avatar climb [N], falling hazards [E: snowball, anvil_drop], height meter [E: height_goal]. Fit: Ice biome.
- **A03 Rubble Rumble** (Quarry Crash). 3 players versus. Little vehicles on a lava-cave plateau ram and smash stacked blocks (lava rock, gear crates) and grab gems; depth counter 32m. Mechanics: vehicle bump/destroy [N], collapse [P: cascade_collapse], lava [E: lava_rise]. Fit: Volcanic.
- **A04 Fort Frenzy** (Castle Catapults). 3 players versus. Each builds a castle of coloured cubes while catapults fling blocks at rivals. Mechanics: build + projectile siege [N], core defence [P: defend_core]. Fit: Candy / medieval, mid campaign.

### Board: minigame_mockups/mockup_02.jpg (style/10_minigames_b.jpg)
- **B01 Bridge Dash** (Gap Runner). Co-op/versus, carry modules between floating islands, Heat meter 10-30%, a Thief role. Like A01 with a hazard meter. [N carry][P mg06].
- **B02 Fort Blast** (Cannon Cove). Cannons fire block ammo across a bay at the opposing fort, trajectory arc shown, Fort HP bars, Block Strength meter. [N projectile][P defend_core].
- **B03 Maze Heist** (Key Vault). Isometric dungeon maze with a sleeping stone golem guard (Guard Sleep bar), collect 3 keys, minimap. Solo/co-op/versus. [N maze + stealth][P mg17 maze]. Fit: Cave / crystal.
- **B04 Summit Scramble** (Magma Peak). Climb a snowy mountain of block steps while lava rises (Lava Rise bar, Players Alive), trophy at top. [P lava_rise, height_goal][N avatar climb].

### Board: minigame_mockups/mockup_04.jpg (style/11_minigames_c.jpg)
- **C01 Clockwork Conveyor** (Belt Works). Conveyor belts feed blocks into a furnace press, claw arm; Height to Safety meter above lava. 2-4 players. [E conveyor, mill_belt][P assembler goal].
- **C02 Kraken Blockade** (Tentacle Wall). Players build a wall of blocks and fire cannons at a giant octopus boss, Boss Health Bar. Co-op. [P defend_core, bonk_boss_goal, crab_claw][N boss attack]. Fit: Underwater / sea.
- **C03 Digging Frenzy** (Dig Down). Dwarf/elf dig with pick and drill down through block layers; Depth 32m; crystals. Versus. [E dig_rescue_goal][P]. Fit: Cave / volcanic.
- **C04 Chroma Sky Climb** (Rainbow Stairs). Glass cubes form a stair across the sky; a wind cloud blows; Stability meter. Race. [E gust, wobble][N avatar run]. Fit: Cosmic.

### Board: minigame_mockups/mockup_03.jpg (style/12_minigames_d.jpg)
- **D01 Rolling Rumble** (Block Karts). Kart race on a forest track, drivers carry block loads, Next Hazard, boost pads, stars. [E race_rival][N kart track, side_travel P].
- **D02 Tumbling Towers** (Seesaw Stack). Stack on a tilting disc over the sea, Balance meter, crane drops treasure, sea monster, hold item. [E tilt_plate, wobble, items]. Closest to our core. Fit: Pirate island, early-mid.
- **D03 Shatter Shootout** (Tower Pelt). Two cliffs with cannons shoot a shared tower; Destruction % each. [P defend_core, anvil_drop][N projectile].
- **D04 Frenzy Footholds** (Hop Blocks). Hop between floating blocks above rising lava; magnet grapple; live leaderboard. [E lava_rise, magnet_pull][N avatar hop].

### Board: minigame_mockups/mockup_05.jpg
- **E01 Galactic Grab** (Cargo Catcher). Space-station conveyor, crane claw, laser tractor grabs cargo cubes; Cargo Security meter. [E conveyor, magnet_pull][N tractor].
- **E02 Cake Stackers** (Bake Tower). Stack desserts on a spinning plate; Topple Risk meter; chefs. [E turntable, wobble, bake_stage]. Fit: Candy.
- **E03 Ancient Ascenders** (Temple Steps). Place stair blocks up a jungle temple to reach an idol; arrow traps; Height to Idol. [P height_goal, woodpecker_knock][N avatar climb].
- **E04 Coral Conduit** (Pipe Reef). Place conduit pieces on a grid to connect water flow; Water Flow Rate. [N connect-path goal; P fill_shape]. Fit: Underwater.

### Board: minigame_mockups/mockup_06.jpg (carries a third-party logo; ignore the logo)
- **F01 Temple Roller Run** (Boulder Chase). Run from rolling boulders, place blocks to cross gaps, coins; Hazard Warning. [N endless runner][P snowball (rolling hazard)]. Fit: Jungle.
- **F02 Submarine Salvage** (Crate Crane). Crane lowers salvage crates to a submarine deck; Treasure Salvaged 0/30; Pressure meter. [P mg05 crane][N]. Underwater.
- **F03 Factory Frenzy Assemble** (Part Press). Conveyors carry gear and cube parts to a central assembler; Conveyor Speed. [E conveyor, mill_belt][P fill_shape].
- **F04 Cosmic Gravity Goal** (Hover Goal). Hoverboard players hit a glowing ball into hex-arena goals; Speed Boost. [N ball sport]. Cosmic.

### Board: minigame_mockups/mockup_07.jpg
- **G01 Abyssal Kraken Siege** (Deep Wall Siege). Defend a platform with cube walls vs a Kraken; Hull Integrity. [E defend_core][P crab_claw].
- **G02 Airship Scrap Brawl** (Sky Ship Repair). Airship deck with cannons, patch with blocks; Ship Health. [P defend_core][N].
- **G03 Wormhole Gravity Rush** (Black Hole Pull). Black hole centre pulls cubes; Grav Force, Spatial Pull, preview column. [E magnet_pull][N radial pull]. Cosmic.
- **G04 Prehistoric Nest Defense** (Egg Guard). Protect glowing eggs from heat/meteors/T-rex with blocks; Egg Temperature. [E hatching_eggs, defend_core]. Fit: Jungle / volcanic.

### Board: minigame_mockups/mockup_08.jpg
- **H01 Pyramid Climber** (Sand Stair). Build an ascending pyramid versus a mummy while a boulder rolls; Height 50%. [P height_goal, snowball].
- **H02 Clockwork Chaos** (Gear Stack). Stack gear crates on a rotating gear; Heat Level; steam. [E turntable, wobble, ember].
- **H03 Kraken Keep** (Storm Crates). Stack crates on a pirate deck in a storm; tentacle; Stability. [E wobble, gust, storm_bolt][P crab_claw].
- **H04 Sugar Rush Stack** (Sweet Stack). Stack desserts on a plate; Sweetness meter. [E frosting, bake_stage, wobble].

### Board: minigame_mockups/mockup_09.jpg
- **I01 Magnetic Mash** (Tractor Tower). Players use beams to pull floating cubes into a stack; Height to Safety. [E magnet_pull][N beam aim].
- **I02 Sweet Rush Rails** (Candy Coaster). Mine cart on candy railway; place blocks/track; six avatars. [E side_travel][P].
- **I03 Pirate Plunder Maze** (Chest Maze). Island maze with bridges and waterfalls, collect chests. [P mg17, mg19 gem grab][N].
- **I04 Jungle Giant Ascent** (Gorilla Tower). Climb a stone tower while a giant throws rocks; two stability meters. [E climber_boss, wobble]. Jungle boss.

### Board: minigame_mockups/mockup_10.jpg
- **J01 Jungle Bridge Rush** (Vine Bridge). Build a bridge over a gorge with a boulder, idol at end. [P mg06].
- **J02 Deep Sea Bubble Build** (Bubble Grid). Stack coral/bubble cubes in a grid; Oxygen meter. [E bubble, rising_silt]. Underwater.
- **J03 Steampunk Gear-Up** (Gear Pad). Place blocks on rotating gears; Pressure meter. [E turntable, pressure_cooker].
- **J04 Nebula Laser Hack** (Laser Wall). Drones fire lasers at a cube wall; Grid Heats. [E storm_bolt (zap)][N laser sweep]. Cosmic.

### Board: minigame_mockups/mockup_11.jpg
- **K01 Slippery Sumo Iceberg** (Floe Sumo). Bear-cart bumpers push each other off an ice floe, snowballs, target rings. [E ice_slide][N bumper].
- **K02 Runaway Rail Rush** (Track Layer). Lay rail pieces ahead of a runaway cart; Speed gauge. [N rail laying][P conveyor].
- **K03 Castle Siege Crash** (Gargoyle Keep). Catapults hit a castle with gargoyles; Fortress Health. [N projectile][P defend_core].
- **K04 Jungle Vine Ascent** (Vine Climb). Climb blocks and vines, mushroom bounce, height gauge with player icons. [E bounce_pad, vines][N climb].

### Board: minigame_mockups/mockup_12.jpg
- **L01 Meadow Mayhem** (Gap Logs). Place logs and rocks across a waterfall gap while gnomes throw acorns. [P mg06][N thrown hazard]. Meadow.
- **L02 Candy Crushers** (Cake Fortress). Pirate cannon smashes a gingerbread cake fortress. [P defend_core][N projectile]. Candy.
- **L03 Glacier Gauntlet** (Avalanche Run). Survive an avalanche with ramps, sled. [E snowball, ice_slide, survive_goal].
- **L04 Cosmic Climb** (Spiral Tower). Ascend a spiral tower laying connector pieces. [N connector path][P height_goal].

### Board: minigame_mockups/mockup_13.jpg
- **M01 Volcano Dash** (Lava Hop). Run across lava platforms avoiding swinging spiked balls; speed boost. [E lava_rock_spawn, quake][N runner].
- **M02 Bumper Battle** (Boat Bump). Bumper boats collect chests with water cannon around a whirlpool. [N bumper].
- **M03 Neon Maze** (Orb Guide). Guide an orb through a holographic maze; gravity flip item. [E mg17 Magnet Maze, flip].
- **M04 Boss Bash** (Scarecrow Smash). Smash a giant scarecrow boss with a super hammer. [E bonk_boss_goal, piston_punch].

### Board: minigame_mockups/mockup_14.jpg
- **N01 Lava Rumble** (Bubble Brawl). Bumper bubble cars last one standing on a lava arena. [N bumper][E lava_rise].
- **N02 Jungle Dash** (Boulder Run). Run to finish with rolling boulder, speed boots. [N runner].
- **N03 Gem Grab** (Mine Haul). Collect gems with minecarts; pickaxe. [E mg19 Gem Grab].
- **N04 Neon Splat** (Paint Arena). Paint the hex arena with paint guns. [E mg20 Paint Dash, chameleon_paint].

### Board: minigame_mockups/mockup_15.jpg
- **O01 Meadow Mayhem herd** (Sheep Pen). Herd sheep into a pen, 5/10. [N herding].
- **O02 Candy Dodger** (Frosting Run). Survive rolling candy on a frosting path. [E mg28 Block Dodge][N].
- **O03 Glacier Rush** (Star Slide). Collect stars on ice with a snowmobile, 7/12. [E star_coins, ice_slide].
- **O04 Cyber Defender** (Hex Defender). Blast virus enemies on a hex platform, 8/15. [N shooter][P defend_core].

### Board: minigame_mockups/mockup_16.jpg (party hub with 4 spokes)
- **P01 Bridge Builders** (Tri-Island Bridge). 3 players build coloured cube bridges between islands, 0:25. [E build_race][P mg06].
- **P02 Bomb Defuse** (Cube Defuse). Central bomb on a rotating platter, red/blue cubes ringing it. [E countdown_bomb, colour_pop, turntable].
- **P03 Balloon Race** (Balloon Carts). Carts lifted by balloons carrying stacked cubes on a cloud track. [E balloon, race_rival].
- **P04 Lava Escape** (Magma Stack). Stack cubes on a volcano island above lava falls. [E lava_rise, mg13].

### Board: minigame_mockups/mockup_17.jpg
- **Q01 Quantum Spire** (Hex Nexus). Two astronauts at the edges of a glowing hex board place cubes; next block monitor. [P fill_shape][N hex grid].

### Boards: party_minigames_ref.jpg, party_modes_ref.jpg, party_versus_ref.jpg, party_biome_islands_ref.jpg, mockup_35, mockup_36, mockup_37
- **R01 Block Bridge Dash / Race** (Lava Span Race). 2 players: tetromino drops build a bridge across lava between two checker flags; a mascot walks across; Stability meter, height. [E mg06 Mascot Bridge Race, build_race]. Sources: party_minigames TL, party_modes #2, party_versus #1.
- **R02 Wobble Builders / Wonky Tower Builders** (Spring Stack). 2 players stack on a spring-mounted island, Height m and Stability Meter; tower wobbles. [E wobble, tilt_plate, build_race].
- **R03 Speed Stack Challenge** (Grid Dash). 2 kids place on a grid island, scores 450 v 320, next block. [E clear_race, shape_race].
- **R04 Island Claim Battle** (Territory Tiles). Shared tropical island board, blue v red cells recoloured as pieces land, territory bar. [N territory claim; P colour_target_goal].
- **R05 Battle Arena Candy Clash**. 3 players on a shared candy grid; avatars stand on the board. [N shared-board versus].
- **R06 Mushroom-style meadow island** (Meadow Grid). Floating island score race with props. [E clear_race].
- **R07 Fire-tile Keep** (Hole and Flame Grid). Holes + fire tiles in board, statues at edge. [P rock_obstacle, ember, lava_lid]. Volcanic.
- **R08 Glass Grid Rainbow** (Glass Road Grid). Glowing glass grid, rainbow roads. [E rainbow_piece][P]. Cosmic.
- **R09 Dino Jungle Rumble** (mockup_35). 2 players, mossy blocks, mud-pit holes. [P rock_obstacle, sticky_landing].
- **R10 Clockwork Gear Challenge** (mockup_35). Gear/pipe pieces on a gear table. [E turntable, conveyor].
- **R11 Deep Sea Treasure Trove** (mockup_35). Clamshell board, treasure-chest pieces. [P fill_shape, bubble].
- **R12 Jousting Tournament** (mockup_36, hinted NEW, hub card only; knight on horse). [N, unspecified].
- **R13 Potion Brewing Challenge** (mockup_36 NEW, cauldron). [N; maybe P mystery_piece].
- **R14 Deep Sea Dive** (mockup_37). Bubble cubes on reef island, mermaid v diver scores. [E bubble].
- **R15 Space Station Zeta** (mockup_37). Glowing cubes on a plate with pad buttons, asteroids; Robot 20, Inventor 320. [P magnet_pull, colour_pop].
- **R16 Haunted Mansion** (mockup_37). Ghost block, graveyard, pumpkins; Vampire v Ghost Hunter. [E fog_ghost, mascot_hint]. Fit: Haunted/forest night.

(Not minigames, meta only: Party Tour map in party_minigames BR, Party Quest hub in mockup_16, mockup_36 hub.)

## Still to read (next append)
mockup_18-34, style/04, 08, 13, 16, tournament_flow_ref, title_screen_ref, title_variants_ref, underwater_biome_sheet_ref, volcanic_biome_sheet_ref, wizard_turnaround_ref, biome_block_materials_ref, logo_ref, logo_master, style/09-12 (duplicates of mockups 01-04 content, to confirm), style/13-15.
