# Minigame Idea Bank: Mockups, Web Ideas and the Top 30

> **Status**: Research (input for `/brainstorm`, `/quick-design`, `/design-system`). Nothing here is a commitment.
> **Author**: game-design researcher (agent) for Tessa
> **Date**: 2026-10-13
> **Sources viewed**: all 20 sheets in `assets/art/reference/minigame_mockups/` (`mockup_01.jpg` to `mockup_20.jpg`), plus `party_minigames_ref.jpg`, `party_modes_ref.jpg`, `party_versus_ref.jpg`, `biome_screens_ref.jpg`, `title_variants_ref.jpg`, `party_biome_islands_ref.jpg`, `tournament_flow_ref.png`, `underwater_biome_sheet_ref.png` and `volcanic_biome_sheet_ref.png`. Web research ran on 2026-10-13 and every web idea below cites its URL.
> **Companion doc**: `design/research/puzzle-party-research-2026-10.md`, which covers goal types, team formats and structure. This doc is the concept catalogue.

**Counts**
- **69** distinct concepts on the 20 mockup sheets. Sheets 18 and 19 repeat three of them, and those repeats are not counted again.
- **13** more concepts or modes in the other references, so **82** in all from the art.
- **38** web ideas with URLs (section 3).
- **30** picks in the Top 30 (section 5).

**Existing-content overlap.** The game already has party minigames MG1 to MG36 (`design/gdd/tournament-minigames.md`, `party-minigames-wave2.md`). Wherever a mockup or pick is close to one of them, the doc says so: "extends MGx" means the idea could be shipped as a variant of that minigame instead of a new one.

---

## 1. Mockup catalogue

Key to the columns:
- **Verb**: what the player mainly does.
- **Blocks**: how falling 3D blocks are used.
- **HUD**: the meters and readouts shown on the sheet.
- **Cast as drawn**: the characters as they appear in the mockup. Names that need changing are flagged in section 6.
- **Biome**: the Wacky Towers biome the concept maps to.

Every sheet also shows a mm:ss timer, player score cards and a Next Block box unless a row says otherwise.

### Sheets 01–04 (glossy "studio" style, 4 panels each)

| # | Name | Sheet | Verb | Blocks | HUD | Hazards | Items / power-ups | Cast as drawn | Biome |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Bridge Bashers | 01 | Carry and place | Mascots heave grass, wood and ice cubes into a gap to bridge a river gorge | Timer, scores, Next Block ×2 | River below, gap | — | Wizard, pirate, dwarf, astronaut, knight | Meadow / forest |
| 2 | Avalanche Ascent | 01 | Climb and dodge | Ice and rock blocks tumble down a slope; climbers use landed ones as steps | **Altitude** thermometer, timer | Lightning, boulders, ice chunks | Crystal pickups | Astronaut, knight, elf | Ice |
| 3 | Rubble Rumble | 01 | Dig / demolish | A pillar of lava, gear and wood blocks gets drilled down by carts with saws | **Depth: 32m** | Lava pit, falling debris | Gems | Wizard, pirate, elf, knight, dwarf (in drill carts) | Lava / cave |
| 4 | Fort Frenzy | 01 | Launch and siege | Catapults lob ice and jelly blocks at rival castles built of blocks | Timer, scores, Next Block | Incoming projectiles | — | Robot, dwarf, kids | Meadow |
| 5 | Bridge Dash | 02 | Carry and place | Bridge modules between floating sky islands; candy and galaxy cubes | **Heat** thermometer 10–30%, **Next Module** | Crumbling island edges | Cake block | Knight, wizard, thief | Celestial / meadow |
| 6 | Fort Blast | 02 | Aim and fire | Cannons fire "ammo" blocks along a trajectory arc at a cliff fort | **Fort HP** ×2 bars, trajectory preview, **Next Ammo**, **Block Strength** meter | Return fire | Lava and dice ammo | Pirate, robot, dwarf | Underwater coast / dune |
| 7 | Maze Heist | 02 | Sneak and collect | Coloured key tiles and glowing cubes in a dungeon maze | **Guard Sleep** bar (Zzz), **Keys Left 1/3**, minimap, **Next Key** | Stone guardian wakes up | Keys | Dwarf, elf, astronaut | Cave |
| 8 | Summit Scramble | 02 | Climb and survive | A stair of ice and lava cubes up to a trophy | **Lava Rise** bar with a warning icon, **Players Alive** | Lava flow, swinging hammers, gears | Trophy at the top | Kids, robot, dwarf | Lava / ice |
| 9 | Rolling Rumble | 03 | Kart race | Tetracube "karts"; blocks used as ramps on a winding track | **Next Hazard**, **Next Block** | Bumpers, star arches | Stars | Knight, robot, dwarf | Forest |
| 10 | Tumbling Towers | 03 | Balance-stack | Candy, ice and wood blocks on a **seesaw** platform at sea | **Balance** meter (green→Danger), **Hold Item** (chest), crane-held treasure | Sea serpent, waves | Treasure chest | Pirate, wizard | Underwater (tropical) |
| 11 | Shatter Shootout | 03 | Demolish | A central tower of gear, ice, galaxy and lava blocks is shot at by cannons on airships | **Destruction %** per side (5/10, 0/2) | Ricochet | Cannon ammo | Dwarf, pirate, elf | Clockwork / dune canyon |
| 12 | Frenzy Footholds | 03 | Jump between stacks | Neon blocks float as footholds above rising lava | **Rising Lava Height: 50m**, **Live Leaderboard** 1–4 | Lava, warning signs | Gems, grapple claw | Astronaut, dwarf, elf, robot | Lava / neon |
| 13 | Clockwork Conveyor | 04 | Sort and assemble | Coloured tetracubes ride conveyors into a central press under a crane claw | **Height to Safety** thermometer | Lava under the factory, steam | — | Astronaut, pirate | Clockwork |
| 14 | Kraken Blockade | 04 | Build wall and fire | Build a wall between two towers; cannons fire glowing blocks at a sea monster | **Boss Health Bar** | Tentacle sweeps | Glowing ammo | Wizard, knight | Underwater |
| 15 | Digging Frenzy | 04 | Dig | Clear dirt blocks downward to reach crystals; lava blocks inside | **Depth: 32m** | Lava cells | Crystals | Dwarf, elf | Cave |
| 16 | Chroma Sky Climb | 04 | Path-build and run | Rainbow glass cubes form a staircase path through space | **Stability** thermometer | **Wind cloud** blowing gusts | — | Kids, robot | Celestial |

### Sheets 05–11 (same style, 4 panels each)

| # | Name | Sheet | Verb | Blocks | HUD | Hazards | Items | Cast as drawn | Biome |
|---|---|---|---|---|---|---|---|---|---|
| 17 | Galactic Grab | 05 | Salvage and sort | A claw drops cargo cubes onto a space-station conveyor | **Cargo Security** thermometer, **Next Salvage** | Laser turret, asteroids | Salvage crates | Astronaut, cyber bot | Celestial |
| 18 | Cake Stackers | 05 | Balance-stack | Cakes and donuts on a **rotating plate** (lazy Susan) | **Topple Risk** bar with a marker | Plate spin | — | Chefs, robot, bear cubs | Candy |
| 19 | Ancient Ascenders | 05 | Climb | Carved stone blocks become stairs up to a golden idol | **Height to Idol** bar, Next Block ×2, **Trap:** arrow preview | Arrow traps, swinging log | Idol | Wizard, pirate, elf, explorers | Forest (jungle) |
| 20 | Coral Conduit | 05 | Connect pipes | Pipe and conduit blocks on an undersea grid | **Water Flow Rate** bar and thermometer, **Next Conduit** | Sharks | — | Divers, mermaid | Underwater |
| 21 | Temple Roller Run | 06 | Run and dodge | Tetracube floor tiles appear under the path | **Hazard Warning** thermometer | Rolling stone discs | Coins | Explorer, pirate, elf, dwarf | Forest (jungle) |
| 22 | Submarine Salvage | 06 | Crane-deliver | A crane lowers treasure crates onto a sub platform | **Treasure Salvaged 0/30**, **Pressure Meter** | Jellyfish, shark | Treasure | Alien, astronaut, divers | Underwater |
| 23 | Factory Frenzy Assemble | 06 | Sort | Gears and cubes ride conveyors into a central reactor | **Conveyor Speed** bar | Furnace | Gear pieces | Dwarf, wizard, robot | Clockwork |
| 24 | Cosmic Gravity Goal | 06 | Sport (soccer) | Neon blocks; an energy ball goes into hologoals | **Speed Boost** meter | Rival tackles | Boost | Astronaut, alien, cyborg | Neon / celestial |
| 25 | Abyssal Kraken Siege | 07 | Defend | Block walls on a sub platform against a giant octopus | **Hull Integrity** bar, **Undersea Safety** thermometer | Tentacles | — | Divers, sub-mariner, knights | Underwater |
| 26 | Airship Scrap Brawl | 07 | Stack and brawl | Stack crates on an airship deck between cannons | **Ship Health** bar, heat thermometer 16/50/30 | Cannon fire, flying gears | Scrap | Pirates, aviators, inventors, robot | Clockwork (sky) |
| 27 | Wormhole Gravity Rush | 07 | Place near a vortex | Neon cubes around a **black hole** that pulls them in | **Grav Force 55%**, **Spatial Pull** thermometer, **Preview ×3** queue | The vortex | — | Robots, astronaut, alien | Celestial |
| 28 | Prehistoric Nest Defense | 07 | Wall and warm | Build walls around glowing eggs | **Egg Temperature** thermometer (−4% to −26°C), **Heat Level** next | Dino, meteors, lava | Eggs | Cavemen, alien, inventor | Lava / forest |
| 29 | Pyramid Climber | 08 | Climb-build | Sandstone blocks stacked into a pyramid stair | **Height 50%** thermometer | Rolling boulder, sand spill | — | Explorers, mummy | Dune bazaar |
| 30 | Clockwork Chaos | 08 | Stack on a turntable | Gear-faced metal cubes on a **rotating cog platform** | **Heat Level** bar | Sparks, steam | — | Engineers, steam robots | Clockwork |
| 31 | Kraken Keep | 08 | Stack cargo on a rocking ship | Crates and chests on a ship deck in a storm | **Stability** thermometer | Tentacles, rain, rocking | Treasure chest | Pirate, monkey, elf | Underwater (storm) |
| 32 | Sugar Rush Stack | 08 | Balance-stack | Cake, jelly and waffle blocks on a plate over a chocolate river | **Sweetness Meter** | — | — | Chef bears, fairy | Candy |
| 33 | Magnetic Mash | 09 | Pull and stack | Magnet beams pull cubes onto a central platform | **Height to Safety** thermometer | Asteroids | — | Astronauts, robots | Celestial |
| 34 | Sweet Rush Rails | 09 | Lay track | Candy blocks along a coaster or minecart track on a cake island | Circular portrait badges (6 players) | Cart collisions | — | Chefs, fairy, alien | Candy |
| 35 | Pirate Plunder Maze | 09 | Maze-build | Sandstone tetracube walls and bridges on a waterfall island | Scores, Next Block ×2 | Water channels | Treasure chests | Pirate, wizard, elf, dwarf | Underwater (tropical) / dune |
| 36 | Jungle Giant Ascent | 09 | Climb under fire | A mossy block tower that a stone giant ape pelts with blocks | **Stability Hazard** twin thermometers | Thrown blocks | — | Explorers, tribal | Forest |
| 37 | Jungle Bridge Rush | 10 | Bridge | Stone blocks and rope bridges across a waterfall | **Height to Safety** thermometer | Boulder | Golden idol | Pirate, explorer, dwarf | Forest |
| 38 | Deep Sea Bubble Build | 10 | Grid-stack (classic well) | Coral and **bubble** cubes in a vertical well | **Oxygen Meter** | Octopus | Bubble blocks | Scuba divers, astronaut | Underwater |
| 39 | Steampunk Gear-Up | 10 | Place on turning gears | Metal blocks set onto rotating cogs | **Pressure Meter** bar | Steam | — | Dwarf, inventor | Clockwork |
| 40 | Nebula Laser Hack | 10 | Build shields | Neon wall blocks stop drone lasers | **Grid Heat** thermometer | Laser drones | — | Neon runners, robot | Neon |
| 41 | Slippery Sumo Iceberg | 11 | Shove | Snowballs; target rings on an ice floe | **Slippery** thermometer | Edge, rolling snowballs | Ridden mounts | Knights, pirate on bear and boar mounts | Ice |
| 42 | Runaway Rail Rush | 11 | Lay track ahead of a cart | Rail planks dropped in front of a gem minecart | **Speed** gauge (dial) | Gaps, sparks | Gems | Alien, robot, astronaut, dwarf, elf | Clockwork (sky) |
| 43 | Castle Siege Crash | 11 | Catapult | Catapults hit a block castle and targets | **Castle Health** bar | Gargoyle statues | Targets | Kids, knights | Meadow |
| 44 | Jungle Vine Ascent | 11 | Vertical race | Carved blocks and mushroom bouncers | **Height** thermometer with **portrait markers** per player | Falling rocks, goblins | Mushroom springs | Elf, wizard, pirate, dwarf | Forest |

### Sheets 12–15 ("Wacky Party" painted-wood UI; P1 to P4 cards with hearts)

| # | Name | Sheet | Goal plaque | Blocks | HUD | Hazards | Items | Cast | Biome |
|---|---|---|---|---|---|---|---|---|---|
| 45 | Meadow Mayhem: Bridge the Gap | 12 | "Bridge the gap!" | Log, vine and boulder pieces | **Next Item** (log) | Acorns thrown by gnomes | — | Wizard, gnomes, sheep | Meadow |
| 46 | Candy Crushers | 12 | "Fortress smash!" | A cannon fires spiked candy at a gingerbread cake fort | **Next Ammo**, "Party Battle" ribbon | Return fire | Candy ammo | Pirate, gingerbread folk | Candy |
| 47 | Glacier Gauntlet | 12 | "Avalanche survival!" | Ice ramps and walls guide a sled | **Next Ramp** | Rolling snowball | Ramps | Astronaut on a sled | Ice |
| 48 | Cosmic Climb | 12 | "Ascend the tower!" | Connector pieces form a spiral track round a neon tower | **Next Connector** | Lasers | — | Robot | Neon / celestial |
| 49 | Volcano Dash | 13 | "Survive the lava!" | Stone stepping blocks with jump pads | **Power-up: Speed Boost** | Swinging spiked balls, lava | Speed boost | Explorer | Lava |
| 50 | Bumper Battle | 13 | "Collect coins & bump!" | Chests and blocks on a whirlpool sea | **Next Block** = chest, **Power-up: Water Cannon** | Whirlpool | Water cannon, coins | Pirates in tubs and boats | Underwater |
| 51 | Neon Maze | 13 | "Guide the orb!" | The maze floor tilts; a mascot rides inside an orb | **Mission** cube, **Item: Gravity Flip** | Laser gates | Gravity flip | Astronaut in a bubble | Neon |
| 52 | Boss Bash | 13 | "Defeat the giant!" | Harvest field; hammer blows | **Weapon: Super Hammer** | Scarecrow-pumpkin giant | Super hammer | Robots | Meadow (farm) |
| 53 | Lava Rumble | 14 | "Last one standing!" | A shrinking stone arena; bumper balls | **Power-up: Boxing Glove** | Lava edge | Boxing glove | Wizard, kids in bubbles | Lava |
| 54 | Jungle Dash | 14 | "Reach the finish!" | Temple path, rope bridge, jump pads | **Item: Boots** | Boulder, spikes | Fruit, boots | Pirate, kid | Forest |
| 55 | Gem Grab | 14 | "Collect the most gems!" | Mine carts and crystal clusters | **Tool: Pickaxe** | — | Pickaxe | Astronauts, explorers | Cave |
| 56 | Neon Splat | 14 | "Paint the arena!" | A hex arena gets painted | **Weapon: Paint Blaster** | Rival blasts | Paint blaster | Robots | Neon |
| 57 | Meadow Mayhem: Herd Sheep | 15 (portrait) | "Herd sheep!" | Fenced pen on a stone grid | **5/10** sheep counter | Wandering sheep | — | Wizard, gnomes | Meadow |
| 58 | Candy Dodger | 15 (portrait) | "Survive the candy!" | A frosting path with rolling peppermints | Warning icon | Rolling candy | — | Pirate | Candy |
| 59 | Glacier Rush | 15 (portrait) | "Collect stars!" | Ice grid; a snowmobile collects stars | **7/12** stars | Slide | Stars | Astronaut, penguins | Ice |
| 60 | Cyber Defender | 15 (portrait) | "Blast enemies!" | Hex shield platform | **8/15** targets | Virus orbs | Shield | Robot | Neon |

### Sheets 16–20 (Wacky Towers party hub and party mode)

| # | Name | Sheet | Verb | Blocks | HUD | Hazards | Items | Cast | Biome |
|---|---|---|---|---|---|---|---|---|---|
| 61 | Bridge Builders | 16 (also 19) | Bridge between pillars | Glowing tetracubes span a gap between floating pillars | Banner: lives 50, **0:25**, trophy 20 | Gap | — | Wizard, pirate, astronaut, monkey | Meadow / celestial |
| 62 | Bomb Defuse | 16 (also 18, 19) | Clear around a bomb | Red and blue blocks rain onto a clockwork disc with a bomb at the centre | Timer **7:38**, "Mini games" clock | Bomb fuse | — | Monkey, robot, explorer | Clockwork |
| 63 | Balloon Race | 16 (also 18, 19) | Race with block carts | Carts carry block stacks, lifted by balloons, along a cloud track | Portrait pins on a cloud | — | Balloons | Monkey, robot, mascots | Carnival / celestial |
| 64 | Lava Escape | 16 | Stack out of lava | Obsidian and lava cubes on a volcano island | — | Lava flow | — | — | Lava |
| 65 | Quantum Spire: Galactic Core Nexus | 17 | Grid-place (premium sci-fi stage) | Mechanical cubes on a glowing hex grid with holo panels | Holo stat panels, **Next Block** terminal with a level gauge | Drones | — | Astronauts | Celestial / clockwork |
| 66 | Tower Tumble | 19 | Versus stack | Coloured tetracubes on a wood-planked island; glow on clear | Score badges per player | — | — | Wizard, pirate, astronaut, parrot | Meadow |
| 67 | Fruit Stack | 20 | Match-stack | Banana, watermelon and orange cubes on a palm island | **Next Block** = banana | — | — | Monkey vs parrot | Meadow (tropical) |
| 68 | Potion Puzzle | 20 | Grid-sort | Potion bottles placed on a lab-table grid | **Next Block** = potion | — | — | Wizard, alien vs golem | Cave / forest |
| 69 | Candy Climb | 20 | Climb-stack | Gummy and candy cubes on a cake island | **Next Block** = spring coil | — | Spring block | Gummy king vs princess | Candy |

Sheets 18 and 19 also show a **block palette tray** with grass, carved wood, mossy stone, crate, crystal and **spring coil**. Sheet 18 is the **main menu hub**: floating gear-driven islands, coin and gem counters (205 and 35), a play button, and tower, bridge, balloon and bomb islands.

### Other references

| # | Name / item | File | What it shows | Biome |
|---|---|---|---|---|
| 70 | Block Bridge Dash | party_minigames, party_versus | Split-screen race to build a bridge over lava to a checkered flag. Time and height per player, **Stability Meter**, **Speed Boost** power-up | Lava |
| 71 | Wobble / Wonky Builders | party_minigames, party_modes, party_versus | Tallest tower on a **spring pedestal**. **Stability Meter** and Height (15m vs 12m), 2v2 team cards | Meadow |
| 72 | Speed Stack Challenge | party_minigames | Fill a grid on your own island fastest | Meadow |
| 73 | Party Tour (board mode) | party_minigames | Board map: Tropical Beach, Candy Kingdom, Party Tower, Space Disco, Lava Keep. Coins, hearts, level, stars | All |
| 74 | Battle Arena: Candy Clash | party_modes | Shared candy grid arena; penguin vs alien drop blocks | Candy |
| 75 | Island Claim Battle | party_versus | Blocks paint a tropical island red or blue; tug-of-war VS bar (1500 vs 1450) | Meadow (tropical) |
| 76 | Grid Fill Rumble | party_biome_islands (**IP**) | Shared 3D grid on a floating island; everyone fills it | Meadow |
| 77 | Lava Keep with fire tiles and crusher totems | party_biome_islands (**IP**) | Burning cells and holes in the grid, stone crushers at the rim | Lava |
| 78 | Starlight Grid | party_biome_islands (**IP**) | Glass neon grid over rainbow highways in space | Celestial / neon |
| 79 | Clear Race | tournament_flow | "Be the first to clear the highlighted blocks". Ghost cubes on each island, progress 6/12 | Carnival (Tumble Fair) |
| 80 | Highest Tower | tournament_flow | One option on the round-pick wheel | Carnival |
| 81 | Largest Footprint | tournament_flow | One option on the round-pick wheel | Carnival |
| 82 | Tournament shell | tournament_flow | Lobby: 3/5/7/13 rounds, "First to 3 wins", Normal/Mixed mode, Items on/off, shape-coded P1 to P4 (circle, triangle, square, star). Then a spin wheel with Reroll (1), standings with "Match point!", and a win screen with round history | Carnival |

`biome_screens_ref.jpg` and `title_variants_ref.jpg` show biome stages, not new minigames:
- Candy: gingerbread wizard, wafer floor.
- Lava: dragon in a party hat, fire sprite, cavemen.
- Underwater: DJ octopus in a pirate hat, jellyfish, mermaid.
- Neon: arcade cabinets, robot wizard.
- Title screen: purple crystal island.
- Block chooser: Meadow, Candy, Lava, Crystal Cave, Neon, Dune Bazaar.

---

## 2. Art-style notes

**Two UI languages appear in the mockups. Pick one.**
1. **Painted wood and parchment.** Seen on sheets 12–16, 18–20, the tournament flow, both biome sheets and the title variants. It looks cozy and matches the "Wacky Towers" brand. **Recommended.**
2. **Glossy navy-blue pill plaques.** Seen on sheets 01–11 and the party_* refs. Readable, but generic mobile.

The volcanic sheet states the rule outright: *"Painted wood UI with parchment interiors."*

**UI framing kit, as it recurs:**
- **Logo**: chunky wooden sign with letters in alternating cream and lilac (or yellow and purple), nailed plank, gears hung at the corners.
- **Timer**: a round wooden dial with a **gear-toothed rim**, centred at the top, with gears beside it (sheets 12–15).
- **Ribbons**: red cloth banners for "PARTY BATTLE", "BUMPER BATTLE" and the mode name. **Bunting** of triangle flags along the top edge.
- **Player portrait cards**: a P1/P2/P3/P4 tab in red/blue/yellow/green, a portrait in a wooden frame, SCORE, and LIVES as three hearts. Use the tournament's shape-coding (circle, triangle, square, star) as a colour-blind backup.
- **Goal plaque**: a parchment scroll in the bottom right with the mode name in caps and "GOAL: …" below.
- **Item boxes**: square parchment tiles with a wood border and a caps label above (NEXT BLOCK, NEXT ITEM, NEXT AMMO, NEXT RAMP, NEXT CONNECTOR, POWER-UP, WEAPON, TOOL, MISSION, ITEM). These cover every "next X" slot, so a minigame only needs to change the label.
- **Thermometer meters**: a vertical tube with a bulb, filling green→yellow→red or blue for water and oxygen, with the % ticks printed on it. Used for Heat, Stability, Altitude, Lava Rise, Oxygen, Pressure, Height to Safety, Egg Temperature and Cargo Security. The **horizontal bar** version is used for Boss HP, Fort HP, Hull Integrity, Conveyor Speed and Topple Risk. Treat it as one widget with a label and a fill colour.
- **Counters**: `5/10`, `7/12` and `0/30` sit inside the item box.
- **Biome-skinned frames**: underwater frames use kelp rope, shells and pearls; volcanic frames use dark planks with iron rivets. Each set has a menu frame, pill, round icon button and tab.

**Palette**
- Sky: saturated sky blue with soft cumulus.
- Meadow: warm grass green and cream stone.
- Candy: pastel pink, mint and lilac.
- Lava: orange-red glow against charcoal, with violet crystals as the accent (the volcanic sheet keeps it "muted and atmospheric").
- Underwater: teal, periwinkle and pearl.
- Neon: deep indigo with cyan and magenta glow.
- Clockwork: brass and copper.
- Dune: sand and terracotta with teal tile accents.
- Accent across all biomes: brand purple and gold.

**Materials**
- Chunky bevelled cubes with **one hero ornament per piece** (coral bud, pearl cluster, shell; cooled shard, small vent, ash tuft).
- Translucent glass and ice cubes with an inner glow.
- Jelly and gummy cubes with subsurface sheen.
- Carved stone with glyphs, wood plank crates and riveted metal gear-faced cubes.
- Galaxy cubes with a starfield inside, neon wireframe cubes, and spring-coil blocks.

**Island shapes**
- The play area is always a **floating island with an 8×8 grid top** on an inverted-cone underside. Variants: earth with roots and vines, coral and kelp, obsidian with dripping lava seams, cake and frosting, a gear-driven chassis, or a sci-fi hull.
- Waterfalls pour off the rims. Small satellite islands float around.
- The hub links islands to a central wooden stage with **glowing rope bridges** (sheet 16).

**Recurring props**
- Gears and cogs everywhere, even on meadow islands.
- Treasure chests, barrels, crates, lanterns and bunting.
- Crystals (purple, cyan), mushrooms, waterfalls and palm trees.
- Lollipops and candy canes; coral, shells and kelp; obsidian spurs and vents.
- Cannons and catapults; minecarts and rails; balloons; a bomb with a lit fuse.
- Stone idols and guardians; airships and blimps in the sky backgrounds.

**Camera**: 3/4 isometric over a single island for puzzle play. Side-on for bridge and climb races. **Portrait 9:16** layouts on sheet 15, party_modes and party_versus show the phone framing: HUD top and bottom, island in the middle third.

---

## 3. Web ideas (adaptable to falling 3D blocks)

| W# | Idea (source game) | Mechanic in brief | Wacky Towers adaptation | Source |
|---|---|---|---|---|
| W1 | Laser-line puzzle (Tricky Towers) | Place as many bricks as possible below a cutoff line; a drop or a brick over the line fails | Solo trial: fit N pieces under a glowing line | https://en.wikipedia.org/wiki/Tricky_Towers |
| W2 | Light vs dark spells (Tricky Towers) | Help yourself (vine glue, undo bolt) or hinder rivals (fog, oversized next block); one spell at a time | Party item pairs: Moss Glue / Rewind vs Fog / Big Block | https://nintendolife.com/reviews/switch-eshop/tricky_towers |
| W3 | Storm race (Tricky Towers special) | Strong wind pushes the tower during the race | Gust-cloud modifier on any race | https://en.wikipedia.org/wiki/Tricky_Towers |
| W4 | Brick quota with lives (Tricky Towers Survival) | First to place their quota wins; dropped bricks cost lives | Survive mode with 3 hearts (matches the mockup cards) | https://en.wikipedia.org/wiki/Tricky_Towers |
| W5 | Time-freeze zone (Tetris Effect) | Stop gravity to stack clears, then release them all at once | "Hourglass Hush" power-up: freeze the fall for 5 s | https://store.steampowered.com/app/1003590/ |
| W6 | Linked co-op vs AI boss (Tetris Effect Connected) | Three players share a joined field against a boss | Co-op boss island (kraken, giant) | https://www.nintendo.com/us/store/products/tetris-effect-connected-switch/ |
| W7 | Classic score attack (TEC) | No hold, one preview; two rounds summed | "Purist" tournament rule toggle | https://www.nintendo.com/us/store/products/tetris-effect-connected-switch/ |
| W8 | Targeting and KO badges (99-player battle royale) | Choose attack targets; KOs give badges that boost attacks | 4-player send targeting and a crown-steal badge | https://tetris.wiki/Tetris_99 |
| W9 | Vanishing hex floors (Fall Guys Hex-A-Gone) | Tiles vanish after you step on them; several layers stacked | "Crumble Combs": block floor tiles crumble, players drop patch blocks | https://primagames.com/tips/all-fall-guys-survival-rounds-and-strategies-to-win-them |
| W10 | Sweeping walls (Fall Guys Block Party) | Shaped walls sweep across the platform | Hole-in-the-wall with incoming block walls (extends MG1) | https://www.androidcentral.com/list-all-mini-games-fall-guys-ultimate-knockout |
| W11 | Fake tiles (Fall Guys Tip Toe) | Some tiles fall away and the real path must be found | Hidden-safe-block bridge: some blocks are hollow | https://www.ggrecon.com/guides/fall-guys-mini-games-list/ |
| W12 | Rotating drum (Fall Guys Roll Out) | Stay on a spinning segmented cylinder | Stack on a slowly rolling log or drum | https://primagames.com/tips/all-fall-guys-survival-rounds-and-strategies-to-win-them |
| W13 | Memory tiles (Fall Guys Perfect Match) | Memorise the pictures, then stand on the matching tile | Cubes flash biome icons and the call-out says which to stand on (near MG11) | https://www.androidcentral.com/list-all-mini-games-fall-guys-ultimate-knockout |
| W14 | Tail tag | Hold the tail at the end of the timer | "Crown cube" carried on your tower top; rivals' sends knock it over | https://www.androidcentral.com/list-all-mini-games-fall-guys-ultimate-knockout |
| W15 | Hoops with gold hoops (Hoopsie Daisy) | Teams score through hoops; gold hoops are worth more | Drop a piece cleanly through floating rings for points | https://www.androidcentral.com/list-all-mini-games-fall-guys-ultimate-knockout |
| W16 | 2v2 build past a line and hold 3 s (Mario Party 10 Shape Up) | Teams stack past a line and hold it | Team "Hold the Line" | https://www.mariowiki.com/Shape_Up |
| W17 | Co-op plush tower (Mario Party Jamboree Stuffie Stacker) | Teams stack plush pieces into the tallest tower | Soft "plush" block set that squashes | https://www.mariowiki.com/Stuffie_Stacker |
| W18 | Rotate halves into a cube (Super Mario Party Perfect Fit) | Partners rotate halves to align | 2-player co-op: each controls half of a shape | https://mario.fandom.com/wiki/Perfect_Fit |
| W19 | Punch out the bottom crate (Mario Party Knock Block Tower) | Remove lower crates to bring the chest at the top down | Dig-down puzzle: clear the lower layers to lower the chest safely | https://www.mariowiki.com/Knock_Block_Tower |
| W20 | Box mountain with coins (Mario Party) | Break boxes to reveal coins | "Lucky Crates": clears reveal coins | https://en.wikibooks.org/wiki/Mario_Party/Minigames |
| W21 | 8-player co-op boss with bombs (Jamboree Kaboom Squad) | Collect bombs and use them on a boss over 5 rounds | Co-op boss: clears produce bombs to throw | https://en.wikipedia.org/wiki/Super_Mario_Party_Jamboree |
| W22 | Hot-potato bomb (Pummel Party Explosive Exchange) | Pass the bomb before it blows | Bomb block passed by sending lines (extends MG14) | https://store.steampowered.com/app/880940/ |
| W23 | Knock-off ring (Pummel Party Snowy Spin) | Spinning arena knock-off | Iceberg sumo with block shoves | https://store.steampowered.com/app/880940/ |
| W24 | Moving kitchens and mid-level relocation (Overcooked 2) | Moving floors, portals, walkways, fires; a level changes setting halfway | Island splits or drifts mid-round; portal columns | https://en.wikipedia.org/wiki/Overcooked_2 |
| W25 | Swap mode (Puyo Puyo Tetris) | Your field swaps between two rule-sets every 25 s | Two islands, swap every 20 s; a falling piece keeps falling on the inactive one | https://strategywiki.org/wiki/Puyo_Puyo_Tetris/Modes |
| W26 | Fusion field (PPT) | Two piece types share one field; heavy pieces crush soft ones | Jelly cubes crushed by stone tetracubes | https://strategywiki.org/wiki/Puyo_Puyo_Tetris/Modes |
| W27 | Preset-board race into a lifebar hit (PPT Big Bang) | Race to clear a preset board; the damage hits the rival's HP | Puzzle-board duel with HP hearts | https://tetris.com/article/36/puyo-puyo-tetris-modes-explained |
| W28 | Items and KO costs points (PPT Party) | Score over time; topping out costs points instead of ending play | Party "no-elimination" rule for kids | https://tetris.com/article/36/puyo-puyo-tetris-modes-explained |
| W29 | Push tug-of-war (Tetris DS Push) | Shared double-height field; multi-clears push the stack toward the rival | "Shove Line" duel on a shared island | https://tetris.wiki/Tetris_DS |
| W30 | Mission ladder (Tetris DS Mission) | Micro-objectives like "clear 2 lines with one piece" | Quick-fire task list in campaign | https://tetris.wiki/Tetris_DS |
| W31 | No-gravity touch puzzle (Tetris DS Touch) | Slide blocks to lower a cage of balloons | Lower a mascot cage by clearing below it | https://www.giantbomb.com/games/3030-10234/ |
| W32 | Place traps, then race (Ultimate Chicken Horse) | Everyone places obstacles, then races; you score only if someone else fails | "Saboteur Course" | https://mergegames.com/games/ultimate-chicken-horse |
| W33 | Throw to topple, Jenga pulls, special blocks (Boom Blox) | Gem, point, vanish and chemical blocks; throw or pull | Demolition rounds and explosive "fizz cubes" | https://en.wikipedia.org/wiki/Boom_Blox |
| W34 | Dice-dictated pulls (Jenga Throw 'n Go) | A die picks the colour or the move | Spin-wheel dictates the next piece colour or rule | https://en.wikipedia.org/wiki/Jenga |
| W35 | Pass-the-platform (Jenga Pass Challenge) | Hold the tower base and pass it on | Hot-seat shared tower on one phone | https://en.wikipedia.org/wiki/Jenga |
| W36 | Swinging crane plus perfect-drop combo (Tower Bloxx) | Time drops from a swinging crane; perfect drops build a combo; taller towers swing faster | Crane variant combo (extends MG5) | https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/TowerBloxx |
| W37 | Turf % (Splatoon Turf War / Tricolor) | Most area painted wins; 4v2v2 variant | Island Claim with a live % bar | https://splatoonwiki.org/wiki/Tricolor_Turf_War |
| W38 | Island chokepoint defence (Bad North) | Position units on a tiny island against boat raids | Wall-building defence of the mascot's house | https://www.pushsquare.com/reviews/ps4/bad_north |

Further notes that were used for synthesis but are not counted as ideas:
- Townscaper is a goal-free build toy, which suggests a "Free Build" sandbox reward room (https://www.nintendolife.com/news/2021/03/townscaper_is_an_idyllic_toy-like_game_thatll_melt_all_your_worries_away).
- Monument Valley introduces one new mechanic per level, such as rotating structures (https://mechanicsofmagic.com/?p=1631).
- Block Blast has players pick from 3 offered shapes (https://www.gamepressure.com/games/block-blast/ze70e2).
- Hyper-casual stackers ramp shape variety and use adaptive difficulty (https://apps.apple.com/us/app/-/id6759821751).
- Kirby Air Riders has a collect phase followed by a stadium minigame (https://strategywiki.org/wiki/Kirby_Air_Riders/City_Trial).

---

## 4. Theme clusters

The theme names follow the task brief. Each line lists catalogue numbers (art) and W numbers (web).

- **Race**: 9 Rolling Rumble, 21 Temple Roller Run, 34 Sweet Rush Rails, 42 Runaway Rail Rush, 44 Jungle Vine Ascent, 54 Jungle Dash, 63 Balloon Race, 70 Block Bridge Dash, 79 Clear Race; W3, W11, W32.
- **Survive**: 2 Avalanche Ascent, 8 Summit Scramble, 12 Frenzy Footholds, 40 Nebula Laser Hack, 47 Glacier Gauntlet, 49 Volcano Dash, 53 Lava Rumble, 58 Candy Dodger, 60 Cyber Defender, 64 Lava Escape, 77 Lava Keep; W4, W9, W10, W12, W13, W14, W28.
- **Build-high**: 13 Clockwork Conveyor (height to safety), 19 Ancient Ascenders, 29 Pyramid Climber, 33 Magnetic Mash, 36 Jungle Giant Ascent, 48 Cosmic Climb, 66 Tower Tumble, 69 Candy Climb, 71 Wobble Builders, 80 Highest Tower; W16, W17, W36.
- **Bridge**: 1 Bridge Bashers, 5 Bridge Dash, 16 Chroma Sky Climb, 37 Jungle Bridge Rush, 45 Bridge the Gap, 61 Bridge Builders, 70 Block Bridge Dash.
- **Siege / Boss**: 4 Fort Frenzy, 6 Fort Blast, 11 Shatter Shootout, 14 Kraken Blockade, 25 Abyssal Kraken Siege, 26 Airship Scrap Brawl, 43 Castle Siege Crash, 46 Candy Crushers, 52 Boss Bash; W6, W21, W27, W33, W38.
- **Dig**: 3 Rubble Rumble, 15 Digging Frenzy, 55 Gem Grab; W19, W20, W31.
- **Sort / Deliver**: 17 Galactic Grab, 22 Submarine Salvage, 23 Factory Frenzy, 68 Potion Puzzle; W34.
- **Balance**: 10 Tumbling Towers, 18 Cake Stackers, 30 Clockwork Chaos, 31 Kraken Keep, 32 Sugar Rush Stack, 39 Steampunk Gear-Up, 41 Slippery Sumo; W12, W35.
- **Paint / Territory**: 56 Neon Splat, 74 Candy Clash, 75 Island Claim Battle, 81 Largest Footprint; W37, W29.
- **Collect**: 7 Maze Heist, 35 Pirate Plunder Maze, 50 Bumper Battle, 57 Herd Sheep, 59 Glacier Rush; W15, W20.
- **Puzzle-fit**: 20 Coral Conduit, 27 Wormhole Gravity Rush, 38 Deep Sea Bubble Build, 51 Neon Maze, 62 Bomb Defuse, 65 Quantum Spire, 67 Fruit Stack, 72 Speed Stack, 76 Grid Fill, 79 Clear Race; W1, W18, W25, W26, W30.
- **Other (sport, brawl, meta)**: 24 Cosmic Gravity Goal and 28 Nest Defense (sit between Survive and Balance), 73 Party Tour board, 82 tournament shell; W2, W5, W7, W8, W22, W23, W24.

---

## 5. Top 30 for Wacky Towers

How to read the table:
- **Mode**: *Both* means a solo campaign stage and a party round. *Solo* means a campaign stage (it can still appear in Mixed tournaments). *Party* means it needs rivals.
- **Rule**: one line, written for falling 3D blocks on an 8×8 floating island.
- **Inspired by**: catalogue number and sheet, or W number and URL.
- **Overlap**: the existing MG it could extend.
- **Use**: how the idea fits the decision that minigames are reusable modules (campaign levels reskin and combine them per biome) and also random head-to-head tournament rounds.
  - **module**: can sit inside a normal campaign level as a phase, a hazard or a mechanic, reskinned per biome.
  - **h2h**: works as a stand-alone head-to-head tournament round, and can go on the Tumble Fair round-pick wheel.
  - **module + h2h**: both.

| # | Name (original) | One-line rule | Theme | Biome fit | Mode | Use | Inspired by | Overlap |
|---|---|---|---|---|---|---|---|---|
| 1 | **Gap Bridge Dash** | Drop pieces to span the chasm; your mascot walks the moment the path is continuous, and the first to the flag wins | Bridge / Race | Meadow, lava, forest | Both | **module + h2h** | #1, #5, #45, #61, #70 (sheets 01, 02, 12, 16, 19, party_minigames) | Extends MG6 Mascot Bridge Race |
| 2 | **Wobble Springs** | Build the tallest tower on a spring pedestal that bounces with every landing, with a Stability meter; tallest at time-out wins | Build-high / Balance | Carnival (Tumble Fair), meadow | Both | **module + h2h** | #71 (party_minigames, party_modes, party_versus) | — |
| 3 | **Lava Rise Climb** | Lava rises a row at a time; stack a staircase and your mascot climbs it automatically; last above the lava wins | Survive / Build-high | Lava | Both | **module + h2h** | #8, #12, #64 (sheets 02, 03, 16) | Extends MG13 Floor Is Lava |
| 4 | **Ghost Fill Race** | Ghost cubes outline a shape; be the first to fill every ghost cell (12 cells) | Puzzle-fit / Race | Any (tournament default) | Both | **module + h2h** | #79 Clear Race (tournament_flow) | Extends MG2 Copycat |
| 5 | **Isle Claim** | Everyone drops onto one shared island; each top face shows its owner's colour; highest % at the buzzer wins | Paint / Territory | Meadow, candy | Party | **h2h** | #75, #81, #74 (party_versus, tournament_flow, party_modes); W37 https://splatoonwiki.org/wiki/Tricolor_Turf_War | — |
| 6 | **Seesaw Cargo** | Stack on a seesaw that tilts toward the heavier side; a Balance meter fails you at Danger; the treasure chest piece doubles the score | Balance | Underwater (tropical), meadow | Both | **module + h2h** | #10 Tumbling Towers (sheet 03) | — |
| 7 | **Spinning Bakery** | Cake, donut and jelly blocks land on a slowly rotating plate; Topple Risk rises with the overhang | Balance | Candy | Both | **module + h2h** | #18, #32 (sheets 05, 08) | Extends MG12 Spin Cycle |
| 8 | **Tentacle Tide** (boss) | A sea monster swipes a lane each wave; walls you complete block the swipe, and every layer you clear fires a glow cube at its HP bar | Siege / Boss | Underwater | Both (co-op boss) | **module** | #14, #25, #31 (sheets 04, 07, 08); W6 https://www.nintendo.com/us/store/products/tetris-effect-connected-switch/ | — |
| 9 | **Catapult Forts** | Build your fort for 30 s, then lob your Next Block at the rival fort; most Fort HP left wins | Siege | Meadow, candy | Party | **module + h2h** | #4, #6, #43, #46 (sheets 01, 02, 11, 12); W33 https://en.wikipedia.org/wiki/Boom_Blox | — |
| 10 | **Gem Dig** | The island starts full; clear layers downward to expose buried crystals before the Depth timer ends | Dig | Cave | Both | **module + h2h** | #3, #15, #55 (sheets 01, 04, 14); W19 https://www.mariowiki.com/Knock_Block_Tower | Extends MG36 Treasure Dig |
| 11 | **Conveyor Sorter** | Pieces ride in on a conveyor; flick each into the bay of its colour before it falls off; Conveyor Speed ramps up | Sort / Deliver | Clockwork | Both | **module + h2h** | #13, #17, #23 (sheets 04, 05, 06) | Extends MG9 Speed Sort |
| 12 | **Coral Conduit** | Pipe-cubes fall; connect the spring to the outlet before the Water Flow (oxygen) meter drains | Puzzle-fit | Underwater | Solo | **module** | #20, #38 (sheets 05, 10) | — |
| 13 | **Gear Turntable** | The island is a cog that turns 90° every few drops; a stable stack scores and a slide-off costs a heart | Balance | Clockwork | Solo | **module** | #30, #39 (sheets 08, 10) | — |
| 14 | **Gust Path** | Build a glass stair to the moon while a puffing cloud mascot blows gusts that shove unsupported pieces | Bridge / Survive | Celestial | Solo | **module** | #16 (sheet 04); W3 https://en.wikipedia.org/wiki/Tricky_Towers | — |
| 15 | **Star Vortex** | A vortex at the island centre drags each falling piece one cell inward; fill the ring around it | Puzzle-fit | Celestial, neon | Both | **module + h2h** | #27, #33 (sheets 07, 09) | — |
| 16 | **Laser Shield** | Drones telegraph laser rows; drop walls to shield your mascot; Grid Heat ends the round | Survive | Neon | Party | **module + h2h** | #40, #60 (sheets 10, 15) | Extends MG28 Block Dodge |
| 17 | **Runaway Rails** | A cart rolls forward and never stops; drop rail-cubes ahead of it; gaps derail you | Race / Bridge | Clockwork, candy | Both | **module + h2h** | #34, #42 (sheets 09, 11) | — |
| 18 | **Floe Shove** | On a slippery ice floe, landing a piece next to a rival mascot shoves it one cell; last on the floe wins | Survive | Ice | Party | **h2h** | #41, #53 (sheets 11, 14); W23 https://store.steampowered.com/app/880940/ | — |
| 19 | **Fizz Bomb** | A fizzing bomb cube sits in your pile; clear its layer before the fuse ends, or pass it with a 2-line send | Survive / Puzzle | Clockwork, carnival | Party | **module + h2h** | #62 (sheets 16, 18, 19); W22 https://store.steampowered.com/app/880940/ | Extends MG14 Hot Block |
| 20 | **Balloon Lift** | Each cleared layer releases a balloon that pulls your cart further along the cloud track; first to the flag wins | Race | Carnival, celestial | Party | **h2h** | #63 (sheets 16, 18, 19) | — |
| 21 | **Flock Fence** | Sheep wander the island; drop blocks to fence them into the pen (10 sheep) | Collect / Puzzle | Meadow | Solo | **module** | #57 (sheet 15) | — |
| 22 | **Sled Ramps** | A sledding penguin slides each turn; place ramp and wall cubes to steer it through 12 stars | Collect / Puzzle | Ice | Solo | **module** | #47, #59 (sheets 12, 15); W31 https://www.giantbomb.com/games/3030-10234/ | — |
| 23 | **Sleepy Guardian** | Build stepping paths to 3 keys; every hard drop raises the cave guardian's Guard Sleep meter | Collect / Puzzle | Cave | Solo | **module** | #7 (sheet 02) | — |
| 24 | **Fruit Pop Stack** | Fruit-faced cubes; 3 matching fruits touching pop for points; monkey vs parrot | Puzzle-fit | Meadow (tropical), forest | Party | **module + h2h** | #67 (sheet 20); W26 https://strategywiki.org/wiki/Puyo_Puyo_Tetris/Modes | Extends MG3 Colour Rush |
| 25 | **Potion Shelf** | Drop potion cubes so each row's colours mix to the recipe card | Puzzle-fit / Sort | Cave, forest | Solo | **module** | #68 (sheet 20) | — |
| 26 | **Glowline Trial** | Place all the given pieces under a glowing line; no drops allowed | Puzzle-fit | Celestial, any | Solo | **module + h2h** | W1 https://en.wikipedia.org/wiki/Tricky_Towers; #13 Height to Safety (sheet 04) | Fits existing fixed-piece levels |
| 27 | **Crumble Combs** | Each floor cell crumbles 2 s after a mascot stands on it; drop patch cubes to save yourself, or skip a patch to trap rivals | Survive | Candy (honeycomb), carnival | Party | **module + h2h** | W9 https://primagames.com/tips/all-fall-guys-survival-rounds-and-strategies-to-win-them; #49 (sheet 13) | — |
| 28 | **Shove Line** | Two players share one island split by a line; every multi-layer clear pushes the line one row toward the rival | Paint / Territory (duel) | Carnival, neon | Party | **h2h** | W29 https://tetris.wiki/Tetris_DS | — |
| 29 | **Saboteur Course** | Each player drops 2 obstacle blocks onto a shared course, then all mascots race; you score only if someone else fails | Race | Carnival, dune bazaar | Party | **h2h** | W32 https://mergegames.com/games/ultimate-chicken-horse | — |
| 30 | **Pyramid Steps** | Stack sandstone cubes into a stair up a pyramid while rolling boulders knock loose any unsupported cube | Build-high | Dune bazaar | Both | **module + h2h** | #29 (sheet 08), #19 (sheet 05) | — |

**Biome coverage of the Top 30.** Every biome has at least two picks:
- Meadow ×8
- Candy ×5
- Ice ×2
- Underwater ×4
- Lava ×2
- Forest ×4
- Cave ×3
- Clockwork ×6
- Neon ×3
- Celestial ×6
- Carnival / Tumble Fair ×8
- Dune bazaar ×2

**Mode split**: 12 Both, 9 Solo, 9 Party.

**Use split**: 17 module + h2h, 8 module only, 5 h2h only. So 25 can live inside campaign levels and 22 can be tournament rounds.

- **Module only**: #8 Tentacle Tide, #12 Coral Conduit, #13 Gear Turntable, #14 Gust Path, #21 Flock Fence, #22 Sled Ramps, #23 Sleepy Guardian, #25 Potion Shelf. These are slow, solo-paced or need a scripted boss, so they are weak as a 60-second duel.
- **h2h only**: #5 Isle Claim, #18 Floe Shove, #20 Balloon Lift, #28 Shove Line, #29 Saboteur Course. Each one needs a rival to mean anything.

### 5.1 Per-biome module combinations

A campaign level is a sequence of 2 or 3 module phases on one island, with the biome providing the reskin. The usual pattern is **opener** (teach) → **pressure** (twist) → **finale** (boss or escape). The numbers refer to the Top 30. Every module in a row is tagged *module* or *module + h2h* above.

| Biome | Signature combo (opener → pressure → finale) | Alternate combos | Reskin notes |
|---|---|---|---|
| **Lava** | #3 Lava Rise Climb → #1 Gap Bridge Dash over the lava gorge → boss phase (Ember Keep lava mascot, Tentacle Tide rules with fireballs, #8) | #27 Crumble Combs (cooling crust) + #19 Fizz Bomb (volcanic vent cube); #10 Gem Dig (obsidian) → #3 escape upward | Obsidian cubes; lava = kill line; Heat thermometer |
| **Meadow** | #21 Flock Fence → #1 Gap Bridge Dash → #2 Wobble Springs finish | #4 Ghost Fill + #9 Catapult Forts (Gourdon scarecrow boss, Boss Bash #52); #6 Seesaw on a log | Grass, wood cubes; gnome = meadow mascot heckler |
| **Candy** | #7 Spinning Bakery → #27 Crumble Combs (honeycomb wafer) → #9 Catapult Forts vs a gingerbread fort | #17 Runaway Rails (coaster) + #24 Fruit Pop (gummies); #2 Wobble Springs on jelly | Jelly cubes wobble; Topple Risk bar; Sweetness meter = score |
| **Ice** | #22 Sled Ramps → #6 Seesaw (tilting floe) → #3 Rise variant: avalanche snow line | #14 Gust Path (blizzard) + #26 Glowline Trial; #10 Gem Dig in a glacier | Slippery cubes slide one cell; Altitude thermometer |
| **Underwater** | #12 Coral Conduit → #6 Seesaw Cargo (tropical) → #8 Tentacle Tide boss (Inkwell) | #11 Conveyor Sorter (salvage crane) + oxygen timer; #24 Fruit Pop as pearl/shell pop | Oxygen meter replaces timer; bubble cubes float up |
| **Forest** | #30 Pyramid Steps re-skinned as a jungle temple stair → #1 Gap Bridge Dash (rope bridge) → Mossback stone titan boss (#8 rules, thrown blocks) | #17 Runaway Rails (log flume) + #24 Fruit Pop; #23 Sleepy Guardian in ruins | Carved stone cubes; arrow-trap "Trap:" preview box |
| **Cave** | #10 Gem Dig → #23 Sleepy Guardian (keys) → #25 Potion Shelf vault door | #4 Ghost Fill (crystal outline) + #19 Fizz Bomb (mine charge); #11 sort gems into carts | Crystal cubes glow; Depth readout; Guard Sleep bar |
| **Clockwork** | #11 Conveyor Sorter → #13 Gear Turntable → #19 Fizz Bomb defuse | #17 Runaway Rails (sky rails) + #16 Laser Shield as steam jets; #2 Wobble Springs on pistons | Gear-faced metal cubes; Pressure meter; brass and copper |
| **Neon** | #16 Laser Shield → #15 Star Vortex → #4 Ghost Fill against the clock | #27 Crumble Combs (glitching tiles) + #26 Glowline Trial; #5-style paint as a solo % target | Wireframe cubes; Grid Heat meter |
| **Celestial** | #14 Gust Path → #15 Star Vortex (black hole) → #26 Glowline Trial to the moon | #1 Gap Bridge Dash between sky islands + #20 Balloon Lift; #2 Wobble Springs in low gravity | Glass and galaxy cubes; Stability meter; wind cloud mascot |
| **Carnival / Tumble Fair** | #2 Wobble Springs → #19 Fizz Bomb → #27 Crumble Combs | #4 Ghost Fill + #17 Runaway Rails (coaster); #6 Seesaw on a fairground teeter | Home of the h2h wheel, so every h2h pick is shown here first |
| **Dune bazaar** | #30 Pyramid Steps → #11 Conveyor Sorter (bazaar stall sort) → #3 Rise variant: quicksand | #25 Potion Shelf re-skinned as spice jars + #23 Sleepy Guardian (tomb); #14 Gust Path as a sandstorm | Sandstone cubes with teal tiles; boulders; lamp-spirit mascot |

**Combination rules of thumb**
1. **At most one "auto-walking mascot" module per level** (#1, #3, #17). Two at once overload a phone screen.
2. **Pair a precision module with a pressure module.** Precision: #4, #12, #25, #26. Pressure: #3, #14, #16, #27.
3. **Bosses are finales only** (#8 and its reskins). Each biome gets one boss face that reuses the same lane-swipe and HP-bar rules.
4. **Reuse the HUD.** A combo shows at most one thermometer (the pressure module's) and one Next X box at a time.
5. **h2h rounds are pulled from the same module pool with the biome kept**, so a lava tournament round can be "Lava Rise Climb, 4 players, last above lava". Modules tagged *module only* never appear on the wheel.

**Strong runners-up** (good concepts that did not make the 30):
- Nest Warmers (#28)
- Hoop Drop (W15)
- Hourglass Hush power-up (W5)
- Swap Isles (W25)
- Crown Cube tag (W14)
- Lucky Crates (W20)
- Hold the Line 2v2 (W16)
- Plush stack co-op (W17)
- Island Drift mid-round change (W24)
- Free Build sandbox (Townscaper note)

---

## 6. IP flags and renames

**Do not ship or show externally:**
- **`party_biome_islands_ref.jpg`** is built entirely on Nintendo IP: the Mushroom Kingdom, two plumber brothers, a princess, a turtle-king villain, angry stone crushers, mushroom foot-soldiers, a green dino and mushroom retainers, green warp pipes, a rainbow highway, and the titles "Mushroom Kingdom Rumble", "Bowser's Lava Keep" and "Rainbow Road Tetris". Use it for layout reference only. Rename the concepts: #76 **Grid Fill Rumble**, #77 **Ember Keep** (crushers become **Thudstone totems**), #78 **Starlight Grid**.
- **"TETRO PARTY DIMENSIONS"** (sheets 06 and 10) echoes a falling-block trademark. Remove the logo. Also avoid "Tetris", "Tetrimino" and "Tetromino" in player-facing text and say **"block", "piece" or "tetracube"**.
- **"Wacky Party Quest: Crazy Dimensions"** (sheet 11) and **"Wacky Party"** (sheets 12–14) are off-brand. Use **Wacky Towers: Party Mode** / **Tumble Fair**.

**Renames for the web ideas:**

| Source term | Wacky Towers name |
|---|---|
| Hex-A-Gone | Crumble Combs |
| Turf War | Isle Claim |
| Zone | Hourglass Hush |
| Kaboom Squad | Fizz Squad (co-op boss) |
| Perfect Match | Picture Tiles |
| Tail Tag | Crown Cube |
| Shape Up | Hold the Line |
| Push mode | Shove Line |
| Big Bang | Puzzle Burst |
| Explosive Exchange | Fizz Bomb |

Never use the source games' names in-game or in store copy.

**Cast clean-up.** Original cast only: wizard, pirate, astronaut, robot, penguin, alien, tiki, monkey, parrot, knight, elf, dwarf, chef, and biome mascots.

| As drawn | Replace with |
|---|---|
| Explorer / safari kid | Monkey, or the parrot in its safari outfit (sheet 19) |
| Thief | Elf |
| Engineer / inventor / aviator | Dwarf or robot |
| Cyborg / cyber bot | Robot |
| Mummy | Dune bazaar mascot (a sand-wrapped lamp spirit) |
| Cavemen | Dwarf, or the lava mascot (the fire sprite / party-hat dragon) |
| Divers / sub-mariner | Penguin, or the underwater mascot (DJ octopus) |
| Mermaid | Underwater mascot |
| Generic kids / "Player" portraits (sheets 01–03, party refs) | Cast portraits |
| Gnomes | Meadow mascot |
| Bear-cub chefs | Chef plus the candy mascot |
| Princess | Candy mascot. A crowned princess reads as a franchise heroine next to a gummy "king" |
| Gummy king | Candy mascot |
| Golem / stone guardian | Cave mascot (friendly "Snoozle" guardian) |
| Scarecrow-pumpkin giant | Meadow boss "Gourdon" |
| Giant stone ape (Jungle Giant Ascent) | A **mossy stone titan** with no ape silhouette, to avoid a famous-gorilla read. Forest boss "Mossback" |
| Kraken | Generic myth, but use a named original: "Inkwell", the pirate-hat octopus from biome_screens |
| Dinosaur | Lava-biome egg guardian (generic dino is fine; avoid a famous green dino) |

---

## 7. Notes for whoever designs next

1. **One HUD widget covers the meters.** Every meter in the mockups is either a labelled thermometer or a labelled bar. Build one `WtMeter` widget that takes a label, a fill gradient and threshold ticks, plus a parchment "Next X" box with a label slot.
2. **Most top picks are goals and rules on the existing core.** Examples: Ghost Fill (shape goal), Gem Dig (dig_rescue), Lava Rise (survive plus a rising kill line), Glowline Trial (piece budget), Gear Turntable and Spinning Bakery (rotation rules). Only a few need new subsystems: an auto-walking mascot (Gap Bridge Dash, Runaway Rails, Lava Rise), physics springs or tilt (Wobble Springs, Seesaw Cargo), and a boss lane (Tentacle Tide).
3. **Tournament shell.** The round-pick wheel on `tournament_flow_ref.png` names only three modes (Clear Race, Highest Tower, Largest Footprint). All 22 Top-30 items tagged *h2h* or *module + h2h* can go on that wheel, keeping the skin of the biome they came from.
