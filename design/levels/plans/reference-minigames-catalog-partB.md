# Reference Minigame Catalogue, Part B (M200+)

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
