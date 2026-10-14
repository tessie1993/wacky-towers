# Reference Minigame Catalogue, Part A (M84 onward)

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
