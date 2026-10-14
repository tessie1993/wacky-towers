# Reference Minigame Catalogue

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
