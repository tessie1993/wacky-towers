# Art Gap Review, 2026-10-13

Art director review of the current build against the reference boards (`assets/art/reference/index.md`).
Evidence reviewed: `islands-v2/meadow_720x1280_vs_ref15.png`, `screens-v2/*` (title, map, standings,
results), `blocks-v2/gallery.png`, `ui-kit-v2/contact_sheet.png`, `assets/art/ui/wizard_idle.png`.

Verdict in one line: the **UI frame kit, the blocks and the wizard are on the right path**. The game still
reads as "empty sky with a nice frame" because the world, the cast, the party HUD and the menu
illustrations do not exist yet.

Priorities: P0 = blocks the "looks like the reference" bar for a first playable. P1 = needed for the
party and story modes. P2 = polish and breadth.

## Ranked gaps

| # | Gap | Screen | Reference shows | We have | Fix (agent / skill) | Pri |
|---|---|---|---|---|---|---|
| 1 | **No backdrop scenery** | Every level, title | Painted sky with 3-6 distant floating islands, waterfalls, castle, mountains, haze (ref 15, 13) | A flat lilac-grey gradient and a flat cloud sea. In the level shot: a few low-poly tree islands, no depth | technical-artist plus Blender backdrop layers per biome (cookbook 5.4), `/asset-spec` | P0 |
| 2 | **Island cliffs and rim dressing are weak** | Level (`meadow_720x1280`) | Stepped chunky rock ledges with strata, grass overhang, roots, big readable clover and flowers (ref 15) | One smooth brown band with noisy texture, red root streaks, rim items are tiny and dense; the board is a flat grey grid with no tile depth and no pieces shown | islands agent, technical-artist (cookbook 5.1 production upgrade: Voronoi chunked bands, MultiMesh props) | P0 |
| 3 | **Level HUD is not the reference HUD** | Level | Biome-framed screen, parchment SCORE chip with stars, NEXT chip with a 3D piece, 3-slot tray (ref 15) | Pause gem plus brown-wood chips, a floating long cream bar ("Balloon"), five cream pill buttons (View, Soft, 0%, Potion), a wide goal chip. No screen frame, no star row, tray slots are empty or tiny | ui-programmer plus ux-designer, `/ux-design` HUD spec, ui-kit agent for the biome frame and tray | P0 |
| 4 | **Title screen is bare** | Title (`title_1280_vs_ref15`) | Wizard on a cloud, cottage island with waterfall, library shelves and parchment frame, big PLAY, BIOMES sign (ref 15) | Logo, a tiny floating grass tile, big gold PLAY, brown sign, five cream pills, empty pastel sky. No wizard, no cottage, no library | Characters agent (wizard in the scene), islands agent (hero cottage island), ui-kit agent (shelf frame) | P0 |
| 5 | **Menus are flat peach panels with generic pills** | Map, Standings, Results | Painted picture cards, parchment with burnt edge, star buttons, tournament cards with wizard portraits, wheel, trophy, chest and confetti (refs 02, 05, 06, 14) | Frame kit is good, but the interior is a flat peach fill with plain text, cream pills stretched full width, small black text lines, no illustration. Standings is just two text lines. Results shows 2 outline stars and no chest or banner | ui-kit agent (parchment panel, stars, ribbon banner), ux-designer layouts, UI render of picture cards (5d) | P0 |
| 6 | **Cast does not exist** | All | Wizard, knight, pirate, dwarf, elf, robot, astronaut, explorer, alien, gnomes, four coloured wizards (refs 01, 02, 09-16) | Only the wizard on a cloud, a mouse and a placeholder wizard in the level. The wizard is good but chubby: the beard hides the body and the arm is a loop | characters agent: wizard polish, then the cast pipeline (cookbook 6) | P1 |
| 7 | **Party HUD language missing** | Party minigames | Player tags, P1-P4 cards with hearts, timer lozenge, NEXT slots, thermometers, boss bar, goal chips (refs 09-12, mockup 15) | None of it | ui-kit agent for the pieces, ui-programmer for scenes (5b) | P1 |
| 8 | **Mode-select picture cards missing** | Mode select (shown as map hub with pills) | Five painted cards in gold frames, library backdrop, wizard peek (refs 03, 05, 06) | Level map buttons labelled "Toy shop, Arcade, Tournament" as cream pills | UI render plus painted card art, ux-designer | P1 |
| 9 | **Block gallery is close but too clean** | Blocks | Clumpy grass tufts, sculpted pebbles, translucent jelly, icicles, snowflake emboss, bubbles, hex cracks, gear emboss, topper meshes on some cubes (ref 13) | Smooth airbrushed painted textures. Toppers exist but are tiny. Ice and Underwater lack translucency and depth. Neon and Celestial read flat. Dune Bazaar is yellow with weak arabesque | blocks agent plus technical-artist (bake path, cookbook 3.4) | P1 |
| 10 | **Party Quest hub** | Hub | Fort deck, four bridges, four minigame islands (mockup 16) | Nothing | Islands agent (hub model), characters agent, level-designer | P1 |
| 11 | **Boss set pieces** | Boss levels | Molten golem, kraken, wind cloud, stone guardian, goblins (refs 02, 07, 11, 12) | Nothing | characters agent (bosses), technical-artist (lava and cloud shaders) | P1 |
| 12 | **Story-beat scenes** | Story | Library, tutorial, jungle, forge, cosmic, finale scenes (refs 01, 02, 07) | Nothing | Painted illustrations (UI render from Blender or commissioned paint), narrative-director for text | P2 |
| 13 | **Minigame world sets** | Minigames | 24+ distinct diorama sets (refs 09-12, mockups) | Nothing | islands agent, level-designer; build in priority order from the asset list | P2 |
| 14 | **Settings panel details** | Settings (`settings_1280`) | Rope borders, gear ornaments, wizard peek, star sliders, multicolour SETTINGS title, segmented controls (refs 04, 08, 16) | Kit has panel_wood with rope, slider, toggles. No wizard peek, no gear ornaments, no segmented control, no pause variant | ui-kit agent | P2 |
| 15 | **VFX** | All | Golden sparkles, confetti, explosion bursts, dust puffs, wind swirls, laser trails, lava splash (refs 01, 02, 07, 10) | Unverified, not in evidence screenshots | technical-artist | P2 |
| 16 | **Tiles on the play board** | Level | Rounded stone tiles with soft grout and edge lighting, glowing ghost cells (ref 15) | Flat grey grid with weak depth, ghost not visible in the shot | blocks and islands agents | P1 |
| 17 | **Rendering polish: bloom, tinted shadows, rim light** | Level | Warm rim light, purple-tinted shadow, bloom on gold (ref 15) | Washed-out, low-contrast look (grey-green background fog) | technical-artist (environment preset, cookbook 2.1) | P1 |

## Notes for the user

1. The frame kit (`ui-kit-v2`) is the strongest asset in the repo. Keep it. Fix grain regularity and the
   vine hiding noted in the cookbook, not the concept.
2. The scale of the boards is huge. We recommend shipping order: **world and HUD for one biome (meadow)
   first** (gaps 1-5), then cast, then party.
3. `wizard_idle.png` is on style: matte felt hat, plush beard, cloud with swirls. Fix: the beard
   swallows the torso, the arm and gold ring read as a hoop, and the hat needs a cream band as in
   ref 16. Add idle, cheer and peek poses.
4. Quality ceiling: procedural paint gets to about 70% of the references (cookbook 10). Plan a
   bake-and-paint-over pass for hero assets.
