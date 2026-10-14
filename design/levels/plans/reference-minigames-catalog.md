# Reference Minigame Catalogue

**Coverage: complete. All 68 reference images were read. 101 unique minigames (see the merge note before Part A).**

Scope: minigames spotted in `assets/art/reference/`. Total spotted: **83** (M01-M83). Every name below is for tracing only. Each entry gives an original working name ("Our name"). No logos, names or IP are to be copied.

## 0. Honest coverage note (read first)

- Image reads that actually rendered for me this session: `minigame_mockups/mockup_01-20` and `mockup_21-37` in order of content (see section 5), i.e. all 37 mockups.
- Image reads that returned only "media removed: request limit" (no pixels seen, so NO minigames could be verified from them): everything else, listed as UNREAD in section 5. A first draft of this file contained entries R01-R08 for the party boards; those were written without seeing the pixels and have been removed. Those boards must be re-scanned (most likely they repeat the Party Battle / Party Mode / Party Quest content seen in mockups 12-16, 19-20, 33-37, but that is unverified).
- No Bash/Python is available to me, so I made no crops. Small HUD text was read at display size.
- File-to-content note: mockups 21-31 are re-exports of the content of mockups 01-10, 16, 17 (same panels). mockup_35 is a variant of 33. Read as the content, not a new set.
- The existing engine check below is by NAME against `assets/data/rules/*.json`, `src/mechanics/**`, `assets/data/tournament/templates.json` (mg01-mg36 exist there) and goal scripts in `src/mechanics/goal/` (height, clear_n, shape, survive, rescue_all, dig_rescue, bonk_boss, wind_keys, colour_target, endless). `assets/data/knobs/goals.json` exists but my grep of it returned nothing, so goal names come from the goal scripts. Marks: [E] exists, [P] partial or close cousin, [N] new.

## 1. Summary table

Players: V = versus (3-4), C = co-op, S = solo, 1v3 = one against three, 2P = two.

| ID | Name (as shown) | Source | One-line | Players | Mechanics |
|---|---|---|---|---|---|
| M01 | Bridge Bashers | mockup_01 TL | Carry block-modules over a cliff gap to bridge a river | V | N carry, P path goal |
| M02 | Avalanche Ascent | mockup_01 TR | Climb a storm slope while ice and rock tumble | V | N climb, E hazards |
| M03 | Rubble Rumble | mockup_01 BL | Karts ram and smash stacked lava blocks for gems | V | N vehicle smash |
| M04 | Fort Frenzy | mockup_01 BR | Catapult duel against block castles | V | N projectile siege |
| M05 | Bridge Dash | mockup_02 TL | Carry modules to bridge, with heat meter and a thief | V | N carry, steal |
| M06 | Fort Blast | mockup_02 TR | Cannons fire block ammo across a bay at a fort | V | N projectile |
| M07 | Maze Heist | mockup_02 BL | Steal 3 keys in a dungeon maze past a sleeping golem | V | N maze+stealth |
| M08 | Summit Scramble | mockup_02 BR | Climb block steps up a peak as lava rises | V | E lava, N climb |
| M09 | Clockwork Conveyor | mockup_04 TL | Belts feed a furnace press; stay above lava | V | E conveyor |
| M10 | Kraken Blockade | mockup_04 TR | Co-op wall and cannons against an octopus boss | C | E boss/defend |
| M11 | Digging Frenzy | mockup_04 BL | Dig down through block layers with pick and drill | V | E dig |
| M12 | Chroma Sky Climb | mockup_04 BR | Run a glass-stair path while a wind cloud blows | V | E gust, N runner |
| M13 | Rolling Rumble | mockup_03 TL | Block-load kart race with hazards and boost pads | V | E race, N kart |
| M14 | Tumbling Towers | mockup_03 TR | Stack on a tilting disc island, sea monster | V | E tilt/wobble |
| M15 | Shatter Shootout | mockup_03 BL | Two cannon ships shoot one shared tower | V | N projectile |
| M16 | Frenzy Footholds | mockup_03 BR | Hop floating blocks above rising lava, grapple | V | E lava,magnet |
| M17 | Galactic Grab | mockup_05 TL | Tractor-beam and claw cargo on a space conveyor | V | E conveyor,magnet |
| M18 | Cake Stackers | mockup_05 TR | Stack desserts on a spinning plate, topple risk | V | E turntable,wobble |
| M19 | Ancient Ascenders | mockup_05 BL | Place stair blocks up a temple while traps fire | V | N climb, trap |
| M20 | Coral Conduit | mockup_05 BR | Place conduit pieces to connect water flow | V | N connect-path |
| M21 | Temple Roller Run | mockup_06 TL | Run from boulders and place blocks over gaps | V | N runner |
| M22 | Submarine Salvage | mockup_06 TR | Crane salvage crates onto a sub deck | V | P crane |
| M23 | Factory Frenzy Assemble | mockup_06 BL | Conveyors deliver parts to a central assembler | V | E conveyor |
| M24 | Cosmic Gravity Goal | mockup_06 BR | Hoverboard ball sport on a hex arena | V | N ball sport |
| M25 | Abyssal Kraken Siege | mockup_07 TL | Wall platform vs kraken, hull integrity | C | E defend_core |
| M26 | Airship Scrap Brawl | mockup_07 TR | Patch a cannon airship deck with blocks | C/V | P defend |
| M27 | Wormhole Gravity Rush | mockup_07 BL | Black hole pulls cubes, place into a stack | V | E magnet, N radial pull |
| M28 | Prehistoric Nest Defense | mockup_07 BR | Shield dino eggs from heat and meteors | C | E hatching_eggs |
| M29 | Pyramid Climber | mockup_08 TL | Build a pyramid up while mummy and boulder harass | V | E height |
| M30 | Clockwork Chaos | mockup_08 TR | Stack gear crates on a rotating gear, heat | V | E turntable |
| M31 | Kraken Keep | mockup_08 BL | Stack crates on a storm-tossed pirate deck | V | E wobble,gust |
| M32 | Sugar Rush Stack | mockup_08 BR | Stack sweets, sweetness meter | V | E wobble |
| M33 | Magnetic Mash | mockup_09 TL | Tractor-beam floating cubes into a tower | V | E magnet |
| M34 | Sweet Rush Rails | mockup_09 TR | Mine cart on candy track, place blocks | V | P side_travel |
| M35 | Pirate Plunder Maze | mockup_09 BL | Isometric island maze, collect chests | V | P maze |
| M36 | Jungle Giant Ascent | mockup_09 BR | Climb a vine tower while a giant throws rocks | V | E climber_boss |
| M37 | Jungle Bridge Rush | mockup_10 TL | Bridge a jungle gorge with a boulder chasing | V | P mg06 |
| M38 | Deep Sea Bubble Build | mockup_10 TR | Grid stack of coral/bubble cubes, oxygen | V | E bubble |
| M39 | Steampunk Gear-Up | mockup_10 BL | Place blocks on rotating gears, pressure | V | E turntable |
| M40 | Nebula Laser Hack | mockup_10 BR | Drones laser a cube wall; grid heats | V | N laser sweep |
| M41 | Slippery Sumo Iceberg | mockup_11 TL | Bear-cart sumo on an ice floe | V | E ice_slide, N bump |
| M42 | Runaway Rail Rush | mockup_11 TR | Lay rail pieces ahead of a runaway cart | V | N track laying |
| M43 | Castle Siege Crash | mockup_11 BL | Catapults vs castle with gargoyles | C/V | N projectile |
| M44 | Jungle Vine Ascent | mockup_11 BR | Climb blocks, vines, mushroom bounce | V | E bounce_pad,vines |
| M45 | Lava Survival Race | mockup_32 TL | Build stone stacks above lava to reach safety | V | E lava_rise |
| M46 | Zero-G Blitz | mockup_32 TR | Beam floating cubes into a central core | V | E magnet |
| M47 | Boss Battle Build | mockup_32 BL | Rebuild a wall a stone golem smashes | C | E defend_core |
| M48 | Physics Tumble Tower | mockup_32 BR | Stack beams on a gear, tower collapses | V | E wobble |
| M49 | Meadow Mayhem (bridge) | mockup_12 TL | Log and rock bridge over waterfall; gnomes throw acorns | V | P mg06 |
| M50 | Candy Crushers | mockup_12 TR | Cannon smashes a cake fortress | V | N projectile |
| M51 | Glacier Gauntlet | mockup_12 BL | Survive a rolling snowball with ice ramps | V | E snowball |
| M52 | Cosmic Climb | mockup_12 BR | Ascend a spiral tower with connector pieces | V | N connector path |
| M53 | Volcano Dash | mockup_13 TL | Run lava platforms past swinging spiked balls | V | N runner |
| M54 | Bumper Battle | mockup_13 TR | Bumper boats collect chests near a whirlpool | V | N bump |
| M55 | Neon Maze | mockup_13 BL | Guide an orb through a hologram maze, gravity flip | V | E mg17, flip |
| M56 | Boss Bash | mockup_13 BR | Hammer a giant scarecrow boss | C | E bonk_boss |
| M57 | Lava Rumble | mockup_14 TL | Bumper bubble cars, last one standing | V | N bump, E lava |
| M58 | Jungle Dash | mockup_14 TR | Run to the finish, rolling boulder, spikes | V | N runner |
| M59 | Gem Grab | mockup_14 BL | Collect gems with minecarts and picks | V | E mg19 |
| M60 | Neon Splat | mockup_14 BR | Paint-gun the hex arena | V | E mg20 |
| M61 | Meadow Mayhem (herd) | mockup_15 TL | Herd sheep into a pen, 5/10 | V | N herding |
| M62 | Candy Dodger | mockup_15 TR | Survive rolling candy on a frosting path | V | E mg28 |
| M63 | Glacier Rush | mockup_15 BL | Collect stars on ice with a snowmobile, 7/12 | V | E star_coins,ice |
| M64 | Cyber Defender | mockup_15 BR | Blast virus enemies on a hex platform, 8/15 | V | N shooter |
| M65 | Bridge Builders | mockup_16 TL, 19 TR | Tetromino bridges between islands, 3-4 players, 0:25 | V | E build_race |
| M66 | Bomb Defuse | mockup_16 TR, 19 BR | Central bomb on a platter ringed by cubes | V | E countdown_bomb |
| M67 | Balloon Race | mockup_16 BL, 19 BL | Balloon carts carry cubes round a cloud track | V | E balloon |
| M68 | Lava Escape | mockup_16 BR | Stack cubes on a volcano island above lava falls | V | E lava_rise |
| M69 | Tower Tumble | mockup_19 TL | Stack coloured blocks on a floating island, 0:20 | 2P | E wobble |
| M70 | Fruit Stack | mockup_20 TL, BL | Stack fruit cubes, matching sets | 2P | E colour_target |
| M71 | Potion Puzzle | mockup_20 TR | Place potion bottles on a lab table grid | 2P | P fill_shape |
| M72 | Candy Climb | mockup_20 BR | Stack candy cubes into a tall tower | 2P | E height |
| M73 | Dino Jungle Rumble | mockup_33 L | Fill mossy blocks around mud pits | 2P | P rock_obstacle |
| M74 | Clockwork Gear Challenge | mockup_33 M, 34 | Place gear and pipe pieces on a gear table | 2P | E turntable |
| M75 | Deep Sea Treasure Trove | mockup_33 R | Treasure chest and coral pieces in a clamshell | 2P | P fill_shape |
| M76 | Jungle Rumble | mockup_34 L | Place temple-block cubes at ruins | 2P | E build_race |
| M77 | Candy Castle | mockup_34 BR | Place gummy cubes near a sweet castle | 2P | E frosting |
| M78 | Deep Sea Dive | mockup_37 L | Bubble-glass cubes on a reef island | 2P | E bubble |
| M79 | Space Station Zeta | mockup_37 TR | Energy cubes on pad buttons in space | 2P | P colour_pop |
| M80 | Haunted Mansion | mockup_37 BR | Ghost block graveyard grid | 2P | E fog_ghost |
| M81 | Jousting Tournament | mockup_36 BL (NEW tag) | Knight on horse; no rules visible | ? | N |
| M82 | Potion Brewing Challenge | mockup_36 BR (NEW tag) | Cauldron brewing; no rules visible | ? | N |
| M83 | Quantum Spire | mockup_17, 30 | Two astronauts place hex-board cubes | 2P | P fill_shape |

## 2. Full entries, grouped by source board

Common to all mockups: a "Next Block" HUD slot, timer, player score cards. I list only what differs. "Falling blocks FOR" is stated per entry. Fields that the image does not show are marked (not shown).

### 2.1 mockup_01 (4-up, titles in white caps; same content on style/09)

**M01 Bridge Bashers.** Our name: Cliff Carriers. Source: mockup_01 TL (no crop).
What it is: a bridge-building relay: each player runs with a block on their back and drops it into the river gap.
How it plays: blocks are carried, not falling; place grass, ice or log modules into the gap, run over, first across wins; a dropped block falls into the river.
Platform and scene: two still cliffs with a river and waterfall, side-on, forest setting.
HUD: timer 1:12, score list left, Next Block slots top-left and top-right.
Players: versus (4 avatars seen). Mechanics: avatar carries block [N]; bridge-path goal [P mg06 path]; Fit: Meadow/forest early campaign.

**M02 Avalanche Ascent.** Our name: Slope Scramble. mockup_01 TR.
What it is: a climb race up a snow slope while ice cubes and rocks tumble.
How it plays: falling blocks are hazards and footholds; climb past them to the top; altitude thermometer. Lose by being swept down (not shown).
Scene: one steep sloped plane, lightning storm, moving hazards.
HUD: Altitude thermometer, timer 0:35, Next Block gem.
Players: versus (3). Mechanics: avatar climb [N], falling hazards [E snowball, anvil_drop], height meter [E height goal]. Fit: Ice biome.

**M03 Rubble Rumble.** Our name: Quarry Crash. mockup_01 BL.
What it is: three karts on a plateau smash stacked lava and gear blocks for gems.
How it plays: blocks fall into the pit and are broken by saw and ram; collect gems; Depth 32m counter.
Scene: lava cave, one still square platform ringed by lava.
HUD: depth, Next Block, scores. Players: versus (3).
Mechanics: vehicle ram/destroy [N]; collapse [P cascade_collapse]; lava [E lava_rise]. Fit: Volcanic.

**M04 Fort Frenzy.** Our name: Castle Catapults. mockup_01 BR.
What it is: two builders each stack a coloured-cube castle while catapults fling blocks at the rival.
How it plays: blocks are ammo and building material; destroy the other castle; build and shoot; (win condition not shown, likely last standing).
Scene: meadow with two castles, still. HUD: timer 0:35, scores, Next Block tetromino.
Players: versus (3-4 seen). Mechanics: build plus siege [N], defend a core [P defend_core]. Fit: Meadow/Candy mid.

### 2.2 mockup_02 (style/10)

**M05 Bridge Dash.** Our name: Gap Runner. mockup_02 TL.
What it is: Cliff Carriers with a Heat meter (10-30%) and a Thief role that steals modules.
How it plays: carry a module (grass, ornate, cake) to the bridge; thief picks from others; Next Module slot.
Scene: floating cliffs with waterfall, still. HUD: Heat thermometer, timer 1:20. Players: versus with a Thief (1v3 role).
Mechanics: carry [N], steal [P mg04 steal hook], heat meter [N]. Fit: Meadow.

**M06 Fort Blast.** Our name: Cannon Cove. mockup_02 TR.
What it is: cannons across a bay fire block ammo that breaks fort walls.
How it plays: aim along a trajectory arc shown at the top, loaded block type sets strength; fort HP bars; Block Strength meter.
Scene: two sandstone cliffs, sea between, still. HUD: Fort HP x2, timer 0:50, Next Ammo.
Players: versus. Mechanics: projectile arc [N], fort HP [P defend_core]. Fit: Pirate sea.

**M07 Maze Heist.** Our name: Key Vault.
What it is: sneak through a dungeon maze to steal 3 keys while a stone golem sleeps.
How it plays: grab keys, avoid waking the Guard (Guard Sleep bar); minimap; Next Key. Cave, isometric, still.
HUD: Guard Sleep, Keys Left 1/3, minimap, timer 0:45. Players: versus.
Mechanics: maze [P mg17], stealth meter [N], keys [P key_stamp]. Fit: Crystal cave.

**M08 Summit Scramble.** Our name: Magma Peak.
What it is: climbers race up a snowy pyramid of ice and lava blocks as lava rises; trophy at top.
How it plays: place and climb block steps; Lava Rise bar; Players Alive; last/first up wins.
Scene: mountain with lava river, hammer arms. HUD: Lava Rise, Players Alive, Next Block gear.
Players: versus (3). Mechanics: lava [E lava_rise], height [E height], climber [N]. Fit: Volcanic.

### 2.3 mockup_04 (style/11)

**M09 Clockwork Conveyor.** Our name: Belt Works.
What it is: belts push blocks into a central furnace press; players weld and stack above lava.
How it plays: pick blocks off belts, feed the press, Height to Safety meter 10-80%.
Scene: still machine platform over lava, claw arm above. HUD: height meter, timer 0:45. Players: versus.
Mechanics: conveyor [E conveyor, mill_belt], assembler goal [P fill_shape]. Fit: Forge.

**M10 Kraken Blockade.** Our name: Tentacle Wall.
What it is: build a wall and cannon-fire a rainbow octopus boss.
How it plays: place wall blocks to stop tentacles, fire cannon; Boss Health Bar; timer 0:58.
Scene: island with two towers, sea. Players: co-op. HUD: boss bar, Next Block.
Mechanics: boss HP [E bonk_boss_goal], defend [E defend_core], crab_claw-like attacker [P]. Fit: Underwater/sea boss.

**M11 Digging Frenzy.** Our name: Dig Down.
What it is: dwarf and elf dig through block layers with pick and drill; Depth 32m; crystals.
How it plays: break blocks beside you to descend; collect crystals. Scene: cave shaft with lava floor. Players: versus (3).
Mechanics: dig [E dig_rescue_goal], pick tool [N]. Fit: Cave.

**M12 Chroma Sky Climb.** Our name: Rainbow Stairs.
What it is: run along a glass-cube stair in space while an angry cloud blows.
How it plays: stairs are placed ahead; wind pushes; Stability meter. Players: versus (3).
Mechanics: gust [E gust], wobble [E], runner [N]. Fit: Cosmic.

### 2.4 mockup_03 (style/12)

**M13 Rolling Rumble.** Our name: Block Karts.
What it is: kart race along a forest road carrying block loads; boost pads and hazards.
How it plays: drive, drop blocks as hazards (Next Hazard), pick stars. Players: versus (2 seen).
Scene: winding road, moving. Mechanics: race [E race_rival], kart [N], hazards [E anvil_drop]. Fit: Meadow/forest.

**M14 Tumbling Towers.** Our name: Seesaw Stack.
What it is: stack on a tilting disc over the sea while a crane drops treasure and a sea monster lurks.
How it plays: balance meter (Danger) rises with tilt; hold-item slot. Scene: one tilting platform island. Players: versus (2).
Mechanics: tilt_plate [E], wobble [E], items [E items]. Fit: Pirate island, early-mid; closest to our core.

**M15 Shatter Shootout.** Our name: Tower Pelt.
What it is: two cannon ships shoot at one shared tower on a stone pillar; Destruction % each.
How it plays: fire to topple your rival's score pieces; Scene: canyon, still tower. Players: versus (2).
Mechanics: projectile [N], collapse [P]. Fit: Sky pirates.

**M16 Frenzy Footholds.** Our name: Hop Blocks.
What it is: hop between floating glowing blocks above rising lava, grapple with magnet.
How it plays: Rising Lava Height 50m; live leaderboard 1-4. Players: versus (4). Mechanics: lava [E], magnet [E magnet_pull], hop [N]. Fit: Volcanic.

### 2.5 mockup_05 (and 26)

**M17 Galactic Grab.** Our name: Cargo Catcher. Space conveyor, crane claw, laser grab; Cargo Security meter; Next Salvage. Versus. [E conveyor, magnet_pull][N tractor]. Fit: Cosmic.
**M18 Cake Stackers.** Our name: Bake Tower. Stack dessert slabs on a spinning plate; Topple Risk. Versus (3). [E turntable, wobble, bake_stage]. Fit: Candy.
**M19 Ancient Ascenders.** Our name: Temple Steps. Place stair blocks up a jungle temple; arrows trap (Trap slot); Height to Idol. Versus. [P height_goal][N climb, trap]. Fit: Jungle.
**M20 Coral Conduit.** Our name: Pipe Reef. Place conduit pieces on a grid to link flow; Water Flow Rate. Versus. [N connect-path][P fill_shape]. Fit: Underwater.

### 2.6 mockup_06 (carries third-party logo; ignore)

**M21 Temple Roller Run.** Our name: Boulder Chase. Run from rolling boulders, place blocks across gaps, coins; Hazard Warning 80%. Versus. [N endless runner][P snowball]. Fit: Jungle.
**M22 Submarine Salvage.** Our name: Crate Crane. Crane lowers crates to a sub deck; Treasure Salvaged 0/30; Pressure Meter. Versus. [P mg05 crane]. Fit: Underwater.
**M23 Factory Frenzy Assemble.** Our name: Part Press. Conveyors carry gears and cubes to a central assembler; Conveyor Speed bar. Versus. [E conveyor, mill_belt][P fill_shape]. Fit: Forge.
**M24 Cosmic Gravity Goal.** Our name: Hover Goal. Hoverboards hit a glowing ball into goals on a hex arena; Speed Boost. Versus (3). [N ball sport]. Fit: Cosmic, big new.

### 2.7 mockup_07

**M25 Abyssal Kraken Siege.** Our name: Deep Wall Siege. Divers wall a platform against a kraken; Hull Integrity; Undersea Society meter. Co-op. [E defend_core][P crab_claw]. Fit: Underwater.
**M26 Airship Scrap Brawl.** Our name: Sky Ship Repair. Patch an airship deck with crates under cannon fire; Ship Health. Co-op/versus. [P defend_core][N]. Fit: Sky.
**M27 Wormhole Gravity Rush.** Our name: Black Hole Pull. Black hole centre pulls cubes in; Grav Force 55%, Spatial Pull; Preview. Versus. [E magnet_pull][N radial pull]. Fit: Cosmic.
**M28 Prehistoric Nest Defense.** Our name: Egg Guard. Shield eggs from meteors and T-rex with blocks; Egg Temperature, Heat Level. Co-op. [E hatching_eggs, defend_core]. Fit: Jungle/volcano.

### 2.7b mockup_08

**M29 Pyramid Climber.** Our name: Sand Stair. Build an ascending pyramid against a mummy while a boulder rolls; Height 50%. Versus. [P height_goal, snowball]. Fit: Desert.
**M30 Clockwork Chaos.** Our name: Gear Stack. Stack gear crates on a rotating gear; Heat Level; steam. Versus. [E turntable, wobble, ember]. Fit: Forge.
**M31 Kraken Keep.** Our name: Storm Crates. Stack crates on a rocking pirate deck; tentacle; Stability. Versus. [E wobble, gust, storm_bolt][P crab_claw]. Fit: Pirate.
**M32 Sugar Rush Stack.** Our name: Sweet Stack. Stack desserts on a plate; Sweetness Meter; bear chefs. Versus. [E frosting, bake_stage, wobble]. Fit: Candy.

### 2.8 mockup_09

**M33 Magnetic Mash.** Our name: Tractor Tower. Beams pull floating cubes into one stack on a space platform; Height to Safety. Versus (4). [E magnet_pull][N beam aim]. Fit: Cosmic.
**M34 Sweet Rush Rails.** Our name: Candy Coaster. Mine cart circles a candy track while chefs place blocks; six avatar bubbles. Versus. [P side_travel][N]. Fit: Candy.
**M35 Pirate Plunder Maze.** Our name: Chest Maze. Island maze with bridges and waterfalls; collect chests. Versus. [P mg17, mg19][N]. Fit: Pirate.
**M36 Jungle Giant Ascent.** Our name: Gorilla Tower. Climb a vine stone tower while a giant throws rocks; two stability meters. Versus. [E climber_boss, wobble]. Fit: Jungle boss.

### 2.9 mockup_10

**M37 Jungle Bridge Rush.** Our name: Vine Bridge. Build a gorge bridge with a boulder chasing; idol at end. Versus. [P mg06]. Fit: Jungle.
**M38 Deep Sea Bubble Build.** Our name: Bubble Grid. Stack coral and bubble cubes; Oxygen meter. Versus. [E bubble, rising_silt]. Fit: Underwater.
**M39 Steampunk Gear-Up.** Our name: Gear Pad. Place blocks on rotating gears; Pressure Meter. Versus. [E turntable, pressure_cooker]. Fit: Forge.
**M40 Nebula Laser Hack.** Our name: Laser Wall. Drones fire sweeping lasers at a cube wall; Grid Heats. Versus. [E storm_bolt][N laser sweep]. Fit: Cosmic.

### 2.10 mockup_11 (Party Quest logo)

**M41 Slippery Sumo Iceberg.** Our name: Floe Sumo. Bear carts bump each other off an ice floe, snowballs, target rings; Slippery meter. Versus. [E ice_slide][N bumper]. Fit: Ice.
**M42 Runaway Rail Rush.** Our name: Track Layer. Lay rail pieces ahead of a runaway mine cart; Speed gauge. Versus. [N track laying][P conveyor]. Fit: Mine/sky.
**M43 Castle Siege Crash.** Our name: Gargoyle Keep. Catapults hit a castle with gargoyles; Castle Health. Versus/co-op. [N projectile][P defend_core]. Fit: Castle.
**M44 Jungle Vine Ascent.** Our name: Vine Climb. Climb blocks and vines, mushroom bounce; height gauge with player icons. Versus. [E bounce_pad, vines][N climb]. Fit: Jungle.

### 2.11 mockup_32

**M45 Lava Survival Race.** Our name: Magma Stack Race. Build stone stacks on rock pillars above lava; Height to Safety. Versus. [E lava_rise, mg13]. Volcanic.
**M46 Zero-G Blitz.** Our name: Core Pull. Beams from astronauts guide drifting cubes into a central core. Versus. [E magnet_pull]. Cosmic.
**M47 Boss Battle Build.** Our name: Golem Wall. Team rebuilds an ice and stone wall a golem punches; Boss Health Bar. Co-op. [E defend_core, bonk_boss]. Meadow boss.
**M48 Physics Tumble Tower.** Our name: Jenga Gear. Place beams on a gear while the tower sways; Stability. Versus. [E wobble, mg33 Tower Pull]. Fit: Sky.

### 2.12 mockup_12 (Wacky Party logo, 4-player split)

**M49 Meadow Mayhem (Bridge the Gap).** Our name: Gap Logs. Place logs and rocks over a waterfall gap while gnomes throw acorns; Next Item log. Versus. [P mg06][N thrown hazards]. Meadow.
**M50 Candy Crushers (Fortress Smash).** Our name: Cake Fort. Pirate cannon on a ship hits a gingerbread cake fortress; Next Ammo. Versus. [N projectile][P defend_core]. Candy.
**M51 Glacier Gauntlet (Avalanche Survival).** Our name: Avalanche Run. A snowball rolls down; place ice ramps; Next Ramp. Versus. [E snowball, ice_slide, survive_goal]. Ice.
**M52 Cosmic Climb (Ascend the Tower).** Our name: Spiral Tower. Place connector pieces to climb a glowing spiral tower. Versus. [N connector path][P height_goal]. Cosmic.

### 2.13 mockup_13

**M53 Volcano Dash (Survive the Lava).** Our name: Lava Hop. Run across lava platforms past swinging spiked balls; Speed Boost. Versus. [E lava_rock_spawn, quake][N runner]. Volcanic.
**M54 Bumper Battle (Collect Coins and Bump).** Our name: Boat Bump. Boats around a whirlpool collect chests with water cannon; Next Block chest. Versus. [N bump]. Pirate.
**M55 Neon Maze (Guide the Orb).** Our name: Orb Guide. Guide an orb through a hologram maze; Gravity Flip item. Versus. [E mg17 Magnet Maze, flip]. Cosmic.
**M56 Boss Bash (Defeat the Giant).** Our name: Scarecrow Smash. Robots hit a giant scarecrow with a Super Hammer. Co-op. [E bonk_boss_goal, piston_punch]. Meadow boss.

### 2.14 mockup_14

**M57 Lava Rumble (Last One Standing).** Our name: Bubble Brawl. Bumper bubble cars on a stone disc ringed by lava. Versus. [N bump][E lava_rise]. Volcanic.
**M58 Jungle Dash (Reach the Finish).** Our name: Boulder Run. Run a ruin path with a rolling boulder and spikes; speed boots. Versus. [N runner]. Jungle.
**M59 Gem Grab (Collect the Most Gems).** Our name: Mine Haul. Minecarts and pickaxes in a crystal cave. Versus. [E mg19 Gem Grab]. Cave.
**M60 Neon Splat (Paint the Arena).** Our name: Paint Arena. Paint guns colour a hex arena. Versus. [E mg20 Paint Dash, chameleon_paint]. Cosmic.

### 2.15 mockup_15 (portrait, 4-up)

**M61 Meadow Mayhem (Herd Sheep).** Our name: Sheep Pen. Wizard herds sheep into a fence on a floating island with waterfall; 5/10. [N herding]. Meadow.
**M62 Candy Dodger (Survive the Candy).** Our name: Frosting Run. Run a frosting path past rolling candy; hazard icon. [E mg28 Block Dodge][N]. Candy.
**M63 Glacier Rush (Collect Stars).** Our name: Star Slide. Snowmobile collects stars on an ice floor; 7/12. [E star_coins, ice_slide]. Ice.
**M64 Cyber Defender (Blast Enemies).** Our name: Hex Defender. Shoot virus enemies from a hex platform; 8/15. [N shooter][P defend_core]. Cosmic.

### 2.16 mockups 16, 18, 19, 20, 31 (Party Quest hub and Party Mode)

**M65 Bridge Builders.** Our name: Tri-Island Bridge. 3 players on three islands build coloured tetromino bridges between them; 0:25. [E build_race][P mg06]. Meadow. Players: 3-4 versus, scores 30 v 15 etc.
**M66 Bomb Defuse.** Our name: Cube Defuse. Bomb on a rotating platter with red/blue cubes ringing it; place/remove cubes before it blows; scores 15 v 0. [E countdown_bomb, colour_pop, turntable]. Forge.
**M67 Balloon Race.** Our name: Balloon Carts. Balloon-lifted carts carry cube stacks round a cloud track to a chequered finish. [E balloon, race_rival]. Sky.
**M68 Lava Escape.** Our name: Magma Stack. Stack cubes on a volcano island above lava falls. [E lava_rise, mg13]. Volcanic.
**M69 Tower Tumble.** Our name: Wonky Stack. Stack coloured blocks on a floating island ringed by planks; 0:20; Wizard 50 v Pirate 35. [E wobble, tilt_plate]. Meadow.
**M70 Fruit Stack.** Our name: Fruit Pile. Place banana/orange/watermelon cubes on a jungle island; 2P (Monkey v Parrot). [E colour_target_goal]. Jungle.
**M71 Potion Puzzle.** Our name: Bottle Grid. Place potion bottles on a lab table; Alien/Golem scores. [P fill_shape]. Haunted/wizard.
**M72 Candy Climb.** Our name: Gummy Tower. Stack candy cubes high on a pink island; Gummy v Princess. [E height_goal, frosting]. Candy.

### 2.17 mockups 33, 34, 35, 37 (portrait Party Mode, 2 players, scores + 00:45 timers)

**M73 Dino Jungle Rumble.** Our name: Mud Pit Grid. Mossy stone pieces on a grid with mud-pit holes; T-rex v triceratops; 1450 v 1300. [P rock_obstacle, sticky_landing]. Jungle.
**M74 Clockwork Gear Challenge (Clockwork Gears).** Our name: Gear Table. Place gears, pipes and crates on a gear-shaped table; 2100 v 1950, 00:58. [E turntable, conveyor]. Forge.
**M75 Deep Sea Treasure Trove.** Our name: Clam Chest. Place chests and coral pieces in a clamshell; mermaid v octopus. [P fill_shape, bubble]. Underwater.
**M76 Jungle Rumble.** Our name: Ruin Blocks. Place carved temple cubes near ruins; Monkey v Parrot. [E build_race]. Jungle.
**M77 Candy Castle.** Our name: Sweet Fort. Place jelly cubes beside a candy castle. [E frosting]. Candy.
**M78 Deep Sea Dive.** Our name: Reef Cubes. Bubble-glass cubes on a coral island; Mermaid v Scuba Diver. [E bubble]. Underwater.
**M79 Space Station Zeta.** Our name: Pad Station. Place energy cubes onto marked pad buttons on a station plate. [P colour_pop, magnet_pull]. Cosmic.
**M80 Haunted Mansion.** Our name: Ghost Yard. Ghost block into a graveyard grid; Vampire v Ghost Hunter. [E fog_ghost, mascot_hint]. Haunted.

### 2.18 mockup_36 (hub, Party Mode), mockup_17 and 30

**M81 Jousting Tournament.** Our name: Lance Lane. Hub card tagged NEW: armoured knight on a horse; rules not shown. [N]. Fit: Castle. (hub islands also show volcano, pirate cove, mushroom forest and lab zones: biome hints, not minigames)
**M82 Potion Brewing Challenge.** Our name: Cauldron Mix. Hub card tagged NEW: wizard at a potion bench, cauldron icon; rules not shown. [N; maybe P mystery_piece]. Fit: Wizard biome.
**M83 Quantum Spire (Galactic Core Nexus).** Our name: Hex Nexus. Two astronauts at opposite edges of a glowing hex board place cubes; Next Block monitor; both scoreboards. [P fill_shape][N hex grid]. Cosmic.

## 3. Patterns (family counts, an entry may count in two families)

| Family | Count | Members |
|---|---|---|
| Build-to-height / stack | 20 | M14, M18, M30, M31, M32, M45, M48, M68, M69, M70, M72, M29, M09, M33, M46, M27, M76, M77, M78, M38 |
| Climb (avatar on blocks) | 9 | M02, M08, M12, M19, M36, M44, M52, M29, M16 |
| Bridge / path build | 8 | M01, M05, M37, M49, M65, M20, M42, M34 |
| Defend / siege / boss | 12 | M04, M06, M10, M15, M25, M26, M28, M43, M47, M50, M56, M64 |
| Hazard dodge / run | 9 | M21, M53, M58, M62, M63, M51, M13, M61, M54 |
| Destroy / smash | 6 | M03, M04, M15, M50, M40, M57 |
| Dig | 3 | M11, M59, M35 |
| Maze / key | 4 | M07, M35, M55, M34 |
| Carry / collect | 6 | M01, M05, M17, M22, M23, M59 |
| Balance (tilt, spin) | 8 | M14, M18, M30, M39, M48, M31, M74, M66 |
| Versus (bump, sport) | 5 | M24, M41, M54, M57, M13 |
| Place on target grid / fill | 10 | M71, M73, M75, M79, M80, M83, M20, M70, M74, M62 |

Observations: about 70% are 3-4 player versus with a shared goal; co-op against a boss appears 7 times (M10, M25, M28, M47, M56, M26, M43); Party Mode 2-player boards (M69-M80) are all "place pieces on a themed island" and map directly onto our existing build/fill rules.

## 4. Gaps (new engine features needed) with rough size

S = days, M = 1-2 weeks, L = multi-week.

1. Avatar on the board (run, carry, climb, hop) shared by ~25 entries (M01, M02, M05, M08, M12, M16, M19, M21, M36, M44, M53, M58...). Size L. The biggest single feature.
2. Projectile / catapult / cannon with aim arc and fort HP: M04, M06, M15, M43, M50, M10, M25. Size M.
3. Bumper-car / boat physics with ring-out: M03, M41, M54, M57. Size M.
4. Ball sport on a hex arena: M24. Size L.
5. Maze + stealth guard + keys: M07, M35. Size M (grid maze exists via mg17).
6. Rail / track laying ahead of a cart: M42, M34. Size M.
7. Connector / pipe path goal (flow connect): M20, M52, M74. Size S-M.
8. Radial pull (black hole) and beam aiming: M27, M33, M46. Size S-M (magnet_pull exists).
9. Laser sweep hazard: M40. Size S.
10. Herding / shooter / pad-press mini rules: M61, M64, M79. Size M each.
11. Hex board for fill rules: M83. Size M (board kind).
12. Unspecified new cards: M81, M82. Need design first.
13. Many [E] entries need only a new goal + biome skin: M09, M17, M18, M30, M31, M32, M38, M39, M45, M65-M72, M74-M78, M80. Size S each.

## 5. Image coverage (68 files)

Rendered and examined: mockup_01 to mockup_37 (37 files). Content map: 01-10 and 11-15 as the entries above; 16 hub; 17 Quantum Spire; 18 island menu (hub with Wizard, Pirate, Astronaut, Robot, Bomb Defuse card; no new minigame); 19 and 20 Party Mode boards; 21-31 duplicates of 01-10, 16, 17 content; 32 the M45-M48 board; 33-35 portrait Party Mode (35 is a variant of 33); 36 hub with NEW cards; 37 the M78-M80 board.

NOT rendered (all returned "media removed: request limit"; no minigames verified from them, they remain partial or unread):
- Top level: party_minigames_ref.jpg, party_modes_ref.jpg, party_versus_ref.jpg, party_biome_islands_ref.jpg, biome_screens_ref.jpg, screens_flow_ref.png, tournament_flow_ref.png, title_screen_ref.png, title_variants_ref.jpg, underwater_biome_sheet_ref.png, volcanic_biome_sheet_ref.png, wizard_turnaround_ref.png, biome_block_materials_ref.png, logo_ref.jpg, logo_master.jpg (15 files).
- style/: 01_story_flow, 02_story_beats, 03_choose_mode_library, 04_settings_wide, 05_select_mode_a, 06_select_mode_b, 07_story_tutorial_beats, 08_settings_options_tall, 09_minigames_a, 10_minigames_b, 11_minigames_c, 12_minigames_d, 13_biome_blocks, 14_tournament_flow, 15_title_and_hud, 16_settings_wizard_peek (16 files). style/09-12 are indexed as the same four-up boards as mockups 01, 02, 04, 03, so M01-M16 are covered by name through them.

Re-scan needed for the 31 unrendered files, especially party_minigames, party_modes, party_versus, tournament_flow, screens_flow, style/01, 02, 07, 14 (story beats and tournament flow likely hint at extra minigames).

---

# Part A: party, flow, title and biome sheets (15 images, all read)

Duplicates across parts: M92 = M207 (Clear Race), M93 = M208 (Highest Tower), M94 = M209 (Largest Footprint).
Unique total after merge: 83 (M01-M83) + 8 (M84-M91) + 10 (M200-M209) = **101 minigames** from all 68 images.


Continues `reference-minigames-catalog.md` (M01-M83). Scope: the 15 top-level images in `assets/art/reference/` that the first scan never saw. All 15 rendered and were read once each at display size. No crops were needed. Names shown are for tracing only; each entry has an original working name. No logos, names or IP are to be copied. Two party boards (party_biome_islands_ref) carry third-party characters and names, so those are recorded only as layout and rules.

Marks: [E] exists, [P] partial, [N] new. Checked by name against `assets/data/rules/*.json`, `src/mechanics/**` (goal scripts: height, clear_n, shape, survive, rescue_all, dig_rescue, bonk_boss, wind_keys, colour_target, endless) and `assets/data/tournament/templates.json` (versus templates clear_race, build_race, shape_race, survival; mg01-mg29+). A grep for footprint, territory and claim in `assets/data` found no such goal or rule, so those are [N].

Confidence: A = rules visible on screen. B = layout visible, rules inferred. C = hinted only (a map node, mascot or background), rules are a proposal for design to confirm.

## 1. New entries

| ID | Name (as shown) | Source | One-line | Players | Mechanics | Conf |
|---|---|---|---|---|---|---|
| M84 | Wobble Builders / Wonky Builders | party_minigames TL-R, party_modes L, party_versus M | Stack tetromino cubes on a spring-mounted island; stability meter; height race | V (2) | E wobble, E tilt_plate, P spring base | A |
| M85 | Battle Arena: Candy Clash | party_modes R | Two avatars on one shared candy-tile board place pieces | V (2) | P fill_shape, N shared board | B |
| M86 | Island Claim Battle | party_versus R | Pieces colour tiles on a shared tropical island; territory bar | V (2) | N territory claim, P fill_shape | A |
| M87 | Lava Keep grid | party_biome_islands TR, BL | Fill a stone grid with fire holes and flaming pieces; boss statue | V (2) | E ember, P rock_obstacle, P fill_shape | B |
| M88 | Beat Drop | party_minigames BR (Space Disco node), biome_screens BL (DJ octopus) | Rhythm drop on a disco or DJ-deck board (hinted) | V | E mg16 Rhythm Blocks, P | C |
| M89 | Party Tower Finale | party_minigames BR (centre landmark) | Tour finale: stack the central tower (hinted) | V / C | E height_goal, P | C |
| M90 | Hoard Guard | biome_screens TR | Lava dragon guards a crystal stack; cavemen and fire sprite around it (hinted) | V / C | P pest, P squirrel_heist | C |
| M91 | Tray Tower | screens_flow_ref (3 gameplay phones), title_variants_ref | Solo puzzle: pick one of 3 tray pieces, place on a floating island, 3 stars | S | P items / jumbled_queue, E height_goal | A |
| M92 | Clear Race | tournament_flow_ref panel 2 and 3 | Clear the highlighted ghost blocks first; progress 6/12 | V (4) | E clear_race, E clear_n_goal | A |
| M93 | Highest Tower | tournament_flow_ref panel 2 | Round mode on the wheel: tallest tower wins | V (4) | E height_goal | A |
| M94 | Largest Footprint | tournament_flow_ref panel 2 | Round mode on the wheel: cover the most ground area | V (4) | N footprint goal | A |

## 2. Entries

**M84 Wobble Builders.** Our name: Spring Stack. Source: party_minigames_ref TL-right ("Wobbler Builders", 15m v 12m, wizard v alien), party_modes_ref L (0:50), party_versus_ref M (24m v 26m, 0:25, wizard v penguin).
What it is: a height duel on two small grass islands, each standing on a big coil spring.
How it plays: blocks are tetrominoes that fall into each player's half; you place them to build the tallest stack. The spring tilts and bounces as weight is added, shown by a Stability Meter (red to green) under each side. If the stack topples the height drops; most metres at 0:25 to 0:50 wins. Lose by collapse or by a lower height at the bell.
Platform and scene: a floating or spring-mounted platform, side-on meadow, split screen (party_minigames, party_versus) or a portrait three-quarter view (party_modes).
HUD: Height Xm each side, Stability Meter with a lightning icon each side, timer, Next Block slots (party_modes), player avatar plates.
Players: versus, 2 (portrait), 3 shown with a second player card in party_modes.
Mechanics: wobble [E wobble], tilt [E tilt_plate], spring bounce on the base [P bounce_pad is a cousin; a spring base is not a rule], height goal [E height_goal], stability meter [P].
Fit: Meadow, early campaign. Closest existing cousins M14 Seesaw Stack and M69 Wonky Stack; this one adds the spring and the bar.

**M85 Battle Arena: Candy Clash.** Our name: Sweet Board Brawl. Source: party_modes_ref R (0:38, penguin v alien).
What it is: two characters stand on one shared iso board made of candy tiles (jelly, striped mint, sugar) among giant lollipops and candy canes.
How it plays: blocks (tetrominoes and single cubes) fall onto the one shared grid; both players drop pieces onto it. Win and lose are not shown: likely most tiles covered, or blocking the rival from fitting. Both Next Block slots are shown (red S, green T).
Platform and scene: one still candy board with raised tile cubes, three-quarter view.
HUD: player cards 1 and 2, timer, Next Block x2 (two slots, one each).
Players: versus, 2.
Mechanics: shared board with two droppers [N], fill_shape [P], frosting [E] for the candy tile skin.
Fit: Candy. Different from M77 and M72, which are two separate islands.

**M86 Island Claim Battle.** Our name: Tile Claim. Source: party_versus_ref R (Party Mode, P1 1500 v P2 1450).
What it is: a shared tropical island floor of blue and red tiles. Each player's pieces turn the tiles they land on to their colour, and the colours are blended in the middle.
How it plays: blocks fall from a Next Block slot each; place to claim ground; a tug-of-war bar (blue v red, VS) shows who holds more. Win: larger share at the timer (timer not shown).
Platform and scene: one floating sand island with palms, tiki, fruit and drinks, still.
HUD: P1 and P2 scores, Next Block x2 plus a second queued piece on each side, tug bar.
Players: versus, 2.
Mechanics: territory ownership per tile [N], shared board [N], tug bar [N], fill_shape [P], colour_target [P].
Fit: Tropical beach (a Party Tour node) or Meadow. Strong candidate for a new goal "most tiles owned".

**M87 Lava Keep Grid.** Our name: Ember Keep. Source: party_biome_islands_ref TR and BL (two panels, same scene: 900 v 950, 00:35). Third-party characters; ignore.
What it is: a grey stone grid with burning holes in it, a stone boss statue and angry stone-face crushers in the corners, lava falling off the island edges.
How it plays: tetrominoes drop onto the grid; some are fiery pieces (the Next Block slot shows a flame-edged piece) and some cells are open fire pits. Fill the board while avoiding or plugging fire cells; fire pieces burn adjacent blocks (not shown, inferred). Win: higher score at 00:35.
Platform and scene: floating volcanic island, dark, lava glow.
HUD: two score cards, Next Block, timer, Party Mode ribbon.
Players: versus, 2.
Mechanics: ember [E ember], fire pit holes [P rock_obstacle], lava edge [E lava_rise, lava_lid], burn spread [P goo_spread], fill_shape [P].
Fit: Volcanic. Extra source for M45 and M68 as the same biome, but a distinct grid-with-holes game.

**M88 Beat Drop.** Our name: Disco Drop (hint only). Source: party_minigames_ref BR (Space Disco map node), biome_screens_ref BL (octopus on a DJ deck among glowing jellyfish).
What it is: nothing but the name and a DJ booth is shown. Proposed: blocks fall to a beat, and you place on the beat for a combo.
How it plays: proposal. Place on the beat to build a streak, off beat breaks it. Win: best combo score.
Platform and scene: glowing tile board on a seabed or a space dance floor.
HUD: not shown.
Players: not shown, propose versus.
Mechanics: rhythm timing [P mg16 Rhythm Blocks exists], beat-sync cue [N].
Fit: Cosmic (Space Disco) and Underwater. Low confidence; confirm with design before building.

**M89 Party Tower Finale.** Our name: Landmark Climb (hint only). Source: party_minigames_ref BR (Party Tower at the centre of the Party Tour map, circled by the path).
What it is: a stone tower in the middle of the map, ringed by the route to every biome. Nothing about its rules is shown.
How it plays: proposal. A last stage after the biome nodes: stack the landmark tower, or a boss round. Win: reach the top.
Platform and scene: a floating meadow island with a tower.
HUD: map shows Level 12/20 style progress, coins, hearts, gems (that is metagame HUD, not a minigame HUD).
Players: not shown.
Mechanics: height goal [E height_goal], boss [E bonk_boss_goal, climber_boss].
Fit: Finale of the Party Tour. Low confidence.

**M90 Hoard Guard.** Our name: Dragon's Stack (hint only). Source: biome_screens_ref TR (a cartoon dragon wearing a party cone hat beside a stack of crystal and lava cubes, two cavemen, a fire sprite).
What it is: a title panel for the lava biome, no HUD.
How it plays: proposal. A guardian creature roams the board and burns or steals cubes; you place fast and fill before it acts. A sleeping dragon could echo M07 Key Vault.
Platform and scene: lava island, still.
HUD: none.
Players: versus or co-op.
Mechanics: pest [E pest], steal [P squirrel_heist], ember [E ember], defend_core [E].
Fit: Volcanic. Low confidence.

**M91 Tray Tower.** Our name: Pick Three. Source: screens_flow_ref panels 2-4 (Score 1,250 / 3,470 / 7,320 with stars; meadow, ice, celestial); title_variants_ref (candy 1,500 and underwater 3,800 phones).
What it is: the solo core mode: a tray of three pieces sits under a floating island; you choose one and place it on the grid.
How it plays: pick a piece from the tray, set it down; the NEXT slot shows the upcoming piece; stars fill with the score (1 to 3). Corner icons on the celestial tray (a cyan and a pink round button) suggest rotate and swap or undo. Win: reach the star score. Lose: no space (not shown).
Platform and scene: a floating stone-tile island per biome, with a sprout on top of each cube.
HUD: pause, Score with three stars, Next slot, three-piece tray.
Players: solo.
Mechanics: three-piece choice tray [P items, jumbled_queue; the tray itself is not a rule], undo [E undo_reset], sprout skin [E sprouts], height or fill goals [E].
Fit: every biome; the base solo mode.

**M92 Clear Race.** Our name: Ghost Clear. Source: tournament_flow_ref panel 3 ("Mode: Clear Race. Be the first to clear the highlighted blocks!") and panel 2 (wheel).
What it is: four players each own a small floating island with a built stack that has translucent highlighted cubes.
How it plays: pieces are used to clear the highlighted cubes; each side has progress 6/12, 4/12, 8/12, 3/12; first to finish wins.
Platform and scene: four islands in a 2x2 layout, fair-night ambience.
HUD: player badges (circle, triangle, square, star), progress bars with x/12 each, mode banner.
Players: versus, 4.
Mechanics: [E clear_race template, E clear_n_goal]. Already built; extra source only for the clear-race template, not in M01-M83.
Fit: any biome; Tumble Fair.

**M93 Highest Tower.** Our name: Tall Wins. Source: tournament_flow_ref panel 2 (a wheel segment).
What it is: round mode picked by the spin wheel. Rules not shown beyond the name and a tower icon.
How it plays: tallest stack at the end wins.
Mechanics: [E height_goal]. Players: versus, up to 4. Fit: any biome.

**M94 Largest Footprint.** Our name: Wide Load. Source: tournament_flow_ref panel 2 (a wheel segment, icon of two broad blocks).
What it is: round mode; rules not shown beyond the name.
How it plays: proposal. Cover the largest area of the island floor with placed blocks at the end.
Mechanics: [N footprint or area-covered goal] (no footprint goal found in assets/data or goal scripts); related to [P shape_goal, E fill_shape].
Players: versus, up to 4. Fit: any biome.

## 3. Extra sources for existing entries

| Existing | Extra source | What it adds |
|---|---|---|
| M65 Bridge Builders | party_minigames_ref TL (Block Bridge Dash, 0:18, 25 v 28); party_modes_ref M (Block Bridge Race, 0:09, 3 players, wizard and tiki on a lava canyon); party_versus_ref L (Block Bridge Dash, 0:45, 15m v 12m) | 2-3 player split-screen tetromino bridge over lava with checkered flags at the far side |
| M05 Bridge Dash | party_versus_ref L (side view: penguin on one cliff, tiki on the other, bridge cubes over lava, Speed Boost item and Stability Meters) | Avatar on the cliff plus a Speed Boost power-up on the same bridge game |
| M76 Ruin Blocks | party_minigames_ref BL (Speed Stack Challenge: two grid islands, 450 v 320) | A plain 2-island grid placement race with Next Block per side |
| M69 Wonky Stack | party_biome_islands_ref TL (meadow grid island with pipes and mascots, 1200 v 1150, 00:35) | Same Party Mode grid fill; third-party characters, ignore names |
| M79 Pad Station | party_biome_islands_ref BR (neon glass grid among rainbow roads, 1400 v 1350, 00:53, outline-style pieces) | Space-glass grid with four spectators and outline Next Block pieces |
| M77 Candy Castle | biome_screens_ref TL (waffle-tile grid, candy castle, gummy bears, gingerbread wizard) | Candy biome skin: waffle floor tiles |
| M78 Reef Cubes | biome_screens_ref BL (glowing tile grid on a reef, shell tiles, mermaid, diver) | Shell-marked cells on the reef grid |
| M64 Hex Defender (weak) | biome_screens_ref BR (neon circuit board, robot wizard tower, two heroes, arcade cabinets) | A tower with two defenders on a neon grid, hinted only |

## 4. Non-minigame content seen (for the record)

- party_modes_ref and party_minigames_ref BR: the Party Tour map (Tropical Beach, Candy Kingdom, Space Disco, Lava Keep, Party Tower; coins, hearts, level 12/20, gems) is the metagame; its nodes are biome hints (M88, M89).
- tournament_flow_ref: Tumble Fair setup (3/5/7/13 rounds, First to 3 wins, Normal or Mixed, Items on or off), spin wheel with a Reroll (1) button, round play, standings with Match point, tournament win with round history. Not minigames; they are existing tournament flow.
- title_screen_ref, title_variants_ref (biome picker Meadow, Candy, Lava, Crystal Cave, Neon, Dune Bazaar), biome_block_materials_ref (12 block materials: Meadow, Candy, Ice, Underwater, Lava, Forest, Crystal Cave, Clockwork, Neon, Celestial, Tumble Fair, Dune Bazaar), underwater and volcanic biome sheets, wizard_turnaround_ref (four hat shapes: circle, triangle, diamond, club), logo_ref and logo_master (identical): no minigames. The 12 materials give the full biome list for fit mapping; Forest, Ice, Dune Bazaar and Tumble Fair have no entry above yet.

## 5. Image coverage

All 15 images were read once each and all rendered: party_minigames_ref.jpg, party_modes_ref.jpg, party_versus_ref.jpg, party_biome_islands_ref.jpg, biome_screens_ref.jpg, screens_flow_ref.png, tournament_flow_ref.png, title_screen_ref.png, title_variants_ref.jpg, underwater_biome_sheet_ref.png, volcanic_biome_sheet_ref.png, wizard_turnaround_ref.png, biome_block_materials_ref.png, logo_ref.jpg, logo_master.jpg. No crops were made. Images remaining unread: none.

---

# Part B: style boards 01-16 (all read)


Scope: the 16 style boards `assets/art/reference/style/01_story_flow.jpg` to `16_settings_wizard_peek.jpg`. All 16 were opened once each and rendered. No crops were needed (no Python/PIL used). Companion to `design/levels/plans/reference-minigames-catalog.md` (M01-M83), which is NOT edited. Numbering starts at M200 to avoid clashing with the other scanner. Names are original working names; no logos, names or IP copied.

Marks: [E] exists, [P] partial or close cousin, [N] new. Checked by name against `assets/data/rules/*.json`, `src/mechanics/**` (goal scripts: height, clear_n, shape, survive, rescue_all, dig_rescue, bonk_boss, wind_keys, colour_target, endless), and `assets/data/tournament/templates.json` (clear_race, build_race, shape_race, survival, mg01-mg36).

Players: V = versus (3-4), C = co-op, S = solo, 2P = two.

## 1. Board verdicts

| Board | Content | Minigames? |
|---|---|---|
| 01_story_flow | 4 story panels: intro, Learn to Stack tutorial, Explore the Biomes (heroes on a block cart), The Tournament (cannons and catapults vs block towers) | M205 new; extra sources for M13, M15, M04 |
| 02_story_beats | 6 beats: Tutorial, Lost Tomes, Canopy Chaos, Forge Boss, Cosmic Gateway, Grand Finale | M200, M201, M204 new; extra source M83, M40 |
| 03_choose_mode_library | Mode cards Campaign, Story, Tournament, Arcade, Biomes; star and coin counters | M206 hint (Arcade card) |
| 04_settings_wide | Settings screen | None |
| 05_select_mode_a | Mode cards, Level 15 campaign, Tournament "LIVE NOW", hearts (lives) HUD | Extra source M206 |
| 06_select_mode_b | Same five cards, Arcade card has a stopwatch | Extra source M206 |
| 07_story_tutorial_beats | Story intro, First Steps, Balance and physics, Goblins' ambush, Molten Guardian, Cosmic Nexus | M202, M203 new; extra sources M201, M205, M14, M31 |
| 08_settings_options_tall | Settings and Options (grid helpers, camera shake, speed slider, control style tap and drag or swipe) | None (accessibility hints only, see section 4) |
| 09-12 minigames a-d | Verified: identical to mockups 01, 02, 04, 03 | Nothing new, see section 3 |
| 13_biome_blocks | 12 biome block swatches: Meadow, Candy, Ice, Underwater, Lava, Forest, Crystal Cave, Clockwork, Neon, Celestial, Tumble Fair, Dune Bazaar | Biome hints only, see section 4 |
| 14_tournament_flow | Tumble Fair: lobby, round pick wheel, round play, standings, tournament win | M207, M208, M209 |
| 15_title_and_hud | Title screen; HUD in Meadow, Ice and Celestial with Score, 3 stars, Next, 3-piece tray | None new (see section 4) |
| 16_settings_wizard_peek | Settings screen | None |

## 2. New entries

**M200 Canopy Chaos.** Our name: Jungle Haul. Source: 02_story_beats panel 3 ("Canopy Chaos: Story Quest").
What it is: a knight and a pirate drive an off-road buggy through a jungle track with a tall mossy stone stack lashed to the roof, while monkeys throw acorns and loose blocks fall onto the path.
How it plays: the blocks are the cargo. Catch or place the falling pieces onto the stack on the moving buggy and keep it balanced over bumps and ruins; the stack height at the finish is the score. Win: the tallest intact stack at the finish. Lose: the stack topples off or the buggy stalls.
Platform and scene: a moving buggy platform on a scrolling side-on road, waterfall, vines and ruins, parallax jungle.
HUD: not shown; infer Stack Height and a Next Block slot.
Players: V (2 rivals visible, a second buggy behind) or C.
Mechanics: stack on a moving plate [P wobble, side_travel]; thrown hazards [P squirrel_heist, woodpecker_knock]; vehicle drive-along [N]; height goal [E height_goal]. Fit: Forest/Jungle, mid campaign. Relates to M13 and M36.

**M201 Molten Guardian.** Our name: Cooling Pillars. Sources: 02_story_beats panel 4 ("The Forge Boss: Advanced Event"), 07_story_tutorial_beats panel 5 ("The Molten Guardian: Boss Battle", extra source for the same game).
What it is: two builders (astronaut and dwarf/inventor) on stone platforms in a lava cavern raise block pillars toward a huge lava golem; the golem smashes and splashes, and ice and gear blocks cool the lava ones.
How it plays: blocks build a pillar that reaches a goal marker and blocks the golem's fists. A temperature gauge (shown 45 and -35 degrees) and a Boss Level bar frame the fight: ice blocks drop the heat, lava blocks raise it. Win: reach the goal height, or drain the Boss Level bar by completing rows. Lose: a pillar is smashed or the heat gauge tops out.
Platform and scene: two or three small flat platforms in a lava lake, boss in the backdrop, a mine cart on a rail at the base.
HUD: two player cards (Alien 395, Inventor 5), Boss Level bar top centre, vertical thermometer left.
Players: C or V (cards show two competing scores plus one boss bar, so co-op with a score).
Mechanics: boss bar [E bonk_boss_goal]; heat/ember [E ember, pressure_cooker per M39]; lava hazards [E lava_rise, lava_rock_spawn]; mixed biome blocks [P event_card]; temperature gauge cooling by material [N]. Fit: Forge/Volcanic boss, late game. Relates to M47, M08, M10.

**M202 Goblin Gate.** Our name: Fort Hold. Source: 07_story_tutorial_beats panel 4 ("Story: The Goblins' ambush! Defend the Fort!").
What it is: a knight on top of a stone tower with a cannon builds the fort from wood and stone blocks while goblins hurl rocks from the forest edge.
How it plays: blocks are the fort. Place walls and a battlement to absorb incoming rocks; the cannon fires back at goblins when a gap is closed. Win: survive N waves with the tower standing. Lose: the tower's core row breaks.
Platform and scene: one stone tower on a forest clearing, still; goblins at the left and right edges, dust and impact sparks.
HUD: not shown; infer Tower HP and Wave count.
Players: C (one fort).
Mechanics: survive goal [E survive_goal]; defend a core [P defend_core per M10/M25]; thrown rocks [P gumdrop_hail, snowball]; goblin raiders [N]; cannon return fire [N projectile]. Fit: Forest/Castle, early-mid story. Relates to M43, M04.

**M203 Portal Relay.** Our name: Wormhole Passing. Source: 07_story_tutorial_beats panel 6 ("Advanced: The Cosmic Nexus. An Epic Ending!"; 02_story_beats panel 5 shares the setting).
What it is: two astronaut-and-robot builders on separate floating space platforms pass glowing cubes through twin black-hole portals to each other.
How it plays: a cube launched into one portal comes out at the partner's platform on a curved trail; each player must place the received cube onto their own stack in time, so the stacks only grow when both cooperate. Win: both stacks reach the target. Lose: a missed cube falls into the void.
Platform and scene: two small hex-tile platforms in a starfield, one portal ring on each side.
HUD: not shown; infer Next Block and a shared progress bar.
Players: C or 2P.
Mechanics: portal and pass [N]; magnet_pull catch [E]; radial pull [N, shared with M27]; fall-off [E lose_top_out]. Fit: Cosmic/Celestial, finale. Relates to M27, M46.

**M204 Drag & Match.** Our name: Match Drop. Source: 02_story_beats panel 1 ("The Tutorial", speech bubble "Drag & Match!").
What it is: a wizard on a cloud teaches the first puzzle: drag an ice cube onto the cube of the matching colour on a small island; a hand cursor shows the drag.
How it plays: the blocks are coloured cubes that must be paired with their match; finish pairs to clear. Win: all pairs matched. Lose: none (tutorial), timers off.
Platform and scene: a small still floating island on a cloud sky.
HUD: wizard speech bubble and drag hint only.
Players: S.
Mechanics: colour match goal [E colour_target_goal, colour_pop]; drag hint [E mascot_hint]. Fit: Meadow, onboarding. Relates to M70.

**M205 Ghost Footprint.** Our name: Rotate and Drop. Sources: 01_story_flow panel 2 ("Learn to Stack", TUTORIAL: Tap to rotate, drag to drop!) and 07_story_tutorial_beats panel 2 ("Tutorial: First Steps", Tap and place the block).
What it is: the core placement lesson: a translucent ghost shows where the dragged piece will land on a grid island; a Rotate button turns the piece.
How it plays: pick a piece, rotate, drop it on the dotted footprint; build a small tower. Win: fill the marked footprint or reach the target height. Lose: none, tutorial.
Platform and scene: a still floating grass island with a checker grid.
HUD: Rotate button, speech bubble, hand pointer.
Players: S.
Mechanics: fill the marked shape [E fill_shape, shape_goal]; ghost preview [E preview in the player's grid helpers]. Fit: Meadow, tutorial. Relates to M71, M83.

**M206 Arcade Rush.** Our name: Beat the Clock. Sources: 03_choose_mode_library (Arcade card), 05_select_mode_a and 06_select_mode_b (Arcade card with stopwatch).
What it is: the Arcade card shows a storm of coloured cubes, coins and stars around a stopwatch: a timed score mode.
How it plays (inferred, the card shows no rules): blocks fall in a timed run; chain rows to earn coins and stars; the clock is the limit. Win: highest score before time out. Lose: stack tops out first.
Platform and scene: not shown (card art only).
HUD: stopwatch icon; star and coin counters on the mode screens.
Players: S.
Mechanics: timed endless score [E endless_goal, stopwatch]. Fit: any biome, repeatable arcade mode.

**M207 Clear Race.** Our name: Highlight Sweep. Source: 14_tournament_flow panel 3 ("Round Play", Mode: Clear Race. "Be the first to clear the highlighted blocks!").
What it is: four players each have their own island of cubes with a set of translucent highlighted target cubes; clear them before the others. Score chips show 6/12, 4/12, 8/12, 3/12.
How it plays: place falling pieces so the highlighted cubes complete rows and clear; each clear ticks the counter. Win: first to 12/12. Lose: topping out, or a slower count at the timer.
Platform and scene: four islands in a fair at dusk, still.
HUD: four player chips (circle, triangle, square, star) with progress bars and counts, a mode banner.
Players: V (4).
Mechanics: [E] templates.json `clear_race` ("first to clear two layers"), clear_n_goal; highlighted-target variant [P colour_target_goal]. Fit: Tumble Fair and every biome. Matches the existing template; the highlighted-block marker is the only difference.

**M208 Highest Tower.** Our name: Sky Count. Source: 14_tournament_flow panel 2 ("Round Pick" wheel, wedge icon of stacked towers).
What it is: a wheel wedge naming a round mode in which the tallest tower wins.
How it plays (inferred from the icon): stack as high as you can in the time; the highest column wins the round. Win: tallest. Lose: toppled or shorter.
Platform and scene: not shown beyond the wheel.
HUD: the wheel with a Reroll (1) button and a Starting in... 3 countdown.
Players: V.
Mechanics: [E height_goal]; closest template [P build_race, "build to the line while clears are off"]. Fit: Tumble Fair.

**M209 Largest Footprint.** Our name: Sprawl Score. Source: 14_tournament_flow panel 2 (wheel wedge icon of an L-shaped footprint).
What it is: a wheel wedge naming a round mode in which the widest layout wins rather than the tallest.
How it plays (inferred): spread blocks to cover the most floor tiles on the island; extra height does not count. Win: most tiles covered. Lose: fewer tiles.
Platform and scene: not shown.
HUD: as M208.
Players: V.
Mechanics: floor area count [N, a new goal; closest is shape_goal] and [P fill_shape]. Fit: Tumble Fair, meadow.

## 3. Extra sources for existing entries

| Existing | Extra source | What it adds |
|---|---|---|
| M01 Bridge Bashers | style/09 TL | Identical to mockup_01 TL |
| M02 Avalanche Ascent | style/09 TR | Identical to mockup_01 TR |
| M03 Rubble Rumble | style/09 BL | Identical to mockup_01 BL |
| M04 Fort Frenzy | style/09 BR; 01_story_flow panel 4 | Panel 4 shows catapults and cannons flinging blocks into three coloured towers with climbers on top, in a crowd arena: also suits a tournament Tower Pelt round |
| M05 Bridge Dash | style/10 TL | Identical to mockup_02 TL |
| M06 Fort Blast | style/10 TR | Identical to mockup_02 TR |
| M07 Maze Heist | style/10 BL | Identical to mockup_02 BL |
| M08 Summit Scramble | style/10 BR | Identical to mockup_02 BR |
| M09 Clockwork Conveyor | style/11 TL | Identical to mockup_04 TL |
| M10 Kraken Blockade | style/11 TR | Identical to mockup_04 TR |
| M11 Digging Frenzy | style/11 BL | Identical to mockup_04 BL |
| M12 Chroma Sky Climb | style/11 BR | Identical to mockup_04 BR |
| M13 Rolling Rumble | style/12 TL; 01_story_flow panel 3 | Panel 3 shows three heroes riding a block-loaded cart along a path: a story-mode kart bridge |
| M14 Tumbling Towers | style/12 TR; 07_story_tutorial_beats panel 3 | Panel 3 teaches it: balance gauge marked Danger, wind arrows and a pirate on a tilting platter |
| M15 Shatter Shootout | style/12 BL; 01_story_flow panel 4 | As in M04 row |
| M16 Frenzy Footholds | style/12 BR | Identical to mockup_03 BR |
| M31 Kraken Keep | 07_story_tutorial_beats panel 3 | Wind and balance read as the teaching form of its gust and wobble |
| M40 Nebula Laser Hack | 02_story_beats panel 5 | Laser-beam hackers on the crystal tower board |
| M83 Quantum Spire | 02_story_beats panel 5 ("The Cosmic Gateway: Late Game") | Same glowing hex board, crystal spire and two hackers; adds portal swirl and a Hacker v Hacker-Heroes score card (255 and a second card) |
| M08/M47 family | 02 panel 4 | See new M201 |

Verification of boards 09-12: all 16 panels match the existing M01-M16 entries panel by panel (names, HUD, characters). Differences found: none. The existing catalogue's M13 lists "Next Hazard" and "Next Black" (a typo for Next Block in the image); no change needed.

## 4. Hints that are not minigames (for the other owners)

- Biome list on 13_biome_blocks has 12 biomes. Two are not in the existing catalogue's fit column: **Tumble Fair** (pink and cream striped fair blocks with a ticket topper; also the tournament venue) and **Dune Bazaar** (patterned sand-and-teal desert blocks with a golden dome topper, a natural home for M29 Pyramid Climber). Also named: Forest (wood rings and leaf), Crystal Cave, Clockwork, Neon, Celestial.
- 15_title_and_hud shows the core in-level HUD on every biome: pause button top-left, Score with 3 star slots, Next piece tile, and a 3-piece tray at the bottom (two small circular power buttons on the Celestial board, one cyan one pink). This looks like a core stacking mode, not a separate minigame. It is the baseline for every entry above.
- 05_select_mode_a shows a hearts (lives) counter and a "LIVE NOW" badge on Tournament: a lives economy and live-event hint, a systems matter for game-designer.
- 08_settings_options_tall lists Grid Helpers, Camera Shake, Speed Slider and Control Style (Tap & Drag or Swipe): relevant to M205 and M206 input design.
- 14_tournament_flow lobby: rounds 3, 5, 7, 13; match rule "First to 3 wins"; game mode Normal or Mixed; Items on or off; a spin wheel with Reroll (1); standings with a "Match point!" status; round history. All of it maps onto existing tournament templates and the mode randomizer, not new minigames.

## 5. Coverage

All 16 images were opened once and rendered; none were skipped or limited. No crops were made (text was legible at display size). Unread images: none.
