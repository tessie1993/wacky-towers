# Asset List v2 (from the reference boards)

2026-10-13. Companion to `design/art/art-bible.md` (v2.1) and `design/art/art-gap-review-2026-10-13.md`.
Naming follows `[category]_[name]_[variant]_[size].[ext]`. Ids are stable, use them in stories.

Build method codes: **BM** = Blender model (GLB export), **SH** = Godot shader, **UR** = UI render
from Blender to PNG (nine-patch where needed), **BR** = Blender render of a painted scene or backdrop
layer, **PT** = particle / VFX setup in Godot.
Priority: P0 = first playable look, P1 = party and story modes, P2 = polish and breadth.
Refs: numbers are `style/NN_*`; `m06` etc. are `minigame_mockups/mockup_NN`.

## 1. UI

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| ui_frame_biome_green | Screen border frame with green vines for meadow | 15 | UR | P0 |
| ui_frame_biome_ice | Ice-blue screen frame with snow on top edge | 15 | UR | P0 |
| ui_frame_biome_celestial | Purple celestial frame with gold stars | 15 | UR | P1 |
| ui_chip_score | Parchment SCORE card with star row slots | 15 | UR | P0 |
| ui_chip_next | Parchment NEXT card with a piece render slot | 15 | UR | P0 |
| ui_tray_3slot | Three-slot parchment piece tray in a biome frame | 15 | UR | P0 |
| ui_btn_pause | Small parchment square pause button | 15 | UR | P0 |
| ui_panel_parchment_burnt | Parchment panel with burnt edge, nine-patch | 06, 14 | UR | P0 |
| ui_banner_ribbon | Purple wood and gold ribbon title banner (VICTORY, story beats) | 02, 01 | UR | P0 |
| ui_card_picture_frame | Gold and wood frame for picture cards plus vines | 03, 05 | UR | P0 |
| ui_sign_label | Cream label signboard hanging on a card | 03 | UR | P0 |
| ui_badge_livenow | Red scalloped "LIVE NOW" badge | 05 | UR | P2 |
| ui_ribbon_level | Red ribbon "Level 15" | 05 | UR | P2 |
| ui_btn_gold_star_v2 | Gold pill with star: normal, pressed, disabled | 15 | UR | P0 |
| ui_btn_green_pill | Green "link account" pill | 08 | UR | P2 |
| ui_btn_pink_blue | Pink and blue pills (Help, Credits) | 16 | UR | P2 |
| ui_segmented_control | Gold-selected and brown-unselected segment buttons | 08 | UR | P2 |
| ui_slider_branch | Branch-stick slider track | 08 | UR | P2 |
| ui_rope_border | Tileable rope border | 04, 16 | UR | P2 |
| ui_ornament_gears | Gear pair for settings corners | 08 | UR | P2 |
| ui_ornament_wizard_hat | Small hat sitting on a frame corner | 08, 16 | UR | P2 |
| ui_title_plaque_multicolor | Multicolour letter plaque (baked for fixed titles) | 05, 16 | UR | P0 |
| ui_icon_set_modes | Icons: map, book, gamepad, globe, trophy, star, coin, heart | 03, 05 | UR | P1 |
| ui_hud_tag_player | Dark rounded tag with portrait box, name, score | 09-12 | UR | P1 |
| ui_hud_card_player | Parchment P1-P4 card with tab, portrait, score, lives | m15, m12 | UR | P1 |
| ui_hud_tab_p1_p4 | Four coloured player tabs | m15 | UR | P1 |
| ui_hud_heart_full_empty | Red heart and dark heart | m15 | UR | P1 |
| ui_hud_timer_lozenge | Dark rounded timer with gear ornaments | 09-12, m12 | UR | P1 |
| ui_hud_slot_next | Wood-framed NEXT slot, square | 09-12 | UR | P1 |
| ui_hud_meter_thermo | Vertical glass thermometer with bulb (empty tube, fill in shader) | 09-12 | UR plus SH | P1 |
| ui_hud_bar_horizontal | Wood-framed horizontal bar (lava, conveyor, guard sleep) | 09-12 | UR | P1 |
| ui_hud_bar_boss | Wide red boss health bar frame | 12 | UR | P1 |
| ui_hud_chip_goal | Parchment goal chip with torn edge | m15 | UR | P1 |
| ui_hud_leaderboard | Dark 4-row live leaderboard | 10 | UR | P2 |
| ui_hud_sign_hazard | Yellow warning triangle | 10, 12 | UR | P2 |
| ui_hud_bubble_hint | Parchment tutorial speech bubble and hand cursor | 01, 07 | UR | P1 |
| ui_hud_holo_panel | Holographic cyan panel for sci-fi biomes | 02, m17 | UR plus SH | P2 |
| ui_tour_card_lobby | Tumble Fair setup card and Ready button | 14 | UR | P1 |
| ui_tour_wheel | Round-pick wooden wheel | 14 | BM plus UR | P1 |
| ui_tour_standings | Standings table with wizard portraits and trophy banner | 14 | UR | P1 |
| ui_tour_win | Win screen backdrop, round history rings | 14 | UR | P1 |
| ui_card_mode_campaign | Painted campaign picture | 03, 05, 06 | BR | P0 |
| ui_card_mode_story | Painted story picture (book and castle) | 03, 05, 06 | BR | P0 |
| ui_card_mode_tournament | Painted trophy picture | 03, 05, 06 | BR | P0 |
| ui_card_mode_arcade | Painted tumbling cube picture | 03, 05, 06 | BR | P0 |
| ui_card_mode_biomes | Painted orbiting islands picture | 03, 05, 06 | BR | P0 |
| ui_bg_library_blur | Blurred library with windows (menu backdrop) | 03, 16 | BR | P0 |
| ui_bg_title_shelves | Shelf, books, lantern and globe frame for title | 15 | BR | P0 |
| ui_icon_next_items | NEXT icons: log, ramp, key, pickaxe, boot, glove, blaster, gear, crosshair | m12, m14 | BM | P2 |

## 2. Characters

All 3D (BM, 4-8k tris, 1024 albedo) with 5 poses each (idle, run or carry, cheer, oops, point), plus a
UI portrait render. Ref listed is the best board.

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| char_wizard_v2 | Mascot wizard: fix beard-torso ratio, cream hat band, arms, wand (idle, cheer, peek, point) | 15, 16 | BM | P0 |
| char_wizard_cloud | Wizard on cloud, scene version | 15 | BM | P0 |
| char_wizard_red / blue / green / purple | Four tournament wizards with P1-P4 hat markers | 14 | BM (recolour) | P1 |
| char_knight | Silver armour, red plume | 01, 07 | BM | P1 |
| char_pirate | Tricorn, red beard, eyepatch | 09, 16 | BM | P1 |
| char_dwarf | Ginger braid, helmet, pickaxe | 01, 12 | BM | P1 |
| char_elf | Green hood, blond, slingshot | 01, 10 | BM | P1 |
| char_robot | White-blue round robot | 09, 12 | BM | P1 |
| char_astronaut | White suit, gold visor | 07, 12 | BM | P1 |
| char_explorer | Pith hat, backpack | 06, 11 | BM | P2 |
| char_alien | Lime alien on hover board | 06 | BM | P2 |
| char_gnome | Red-hat garden gnome | m12, m15 | BM | P1 |
| char_crowd_silhouette | Painted spectator strip with banners | 01, 07 | BR | P2 |
| char_sheep | Fluffy sheep | m15 | BM | P1 |
| char_penguin | Penguin | m15 | BM | P2 |
| char_monkey | Jungle monkey | 02 | BM | P2 |
| char_jellyfish_shark | Submarine wildlife | m06 | BM | P2 |
| char_hand_cursor | Pointing hand | 01, 02 | UR | P0 |

## 3. Bosses

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| boss_molten_golem | Basalt golem with emissive lava cracks | 02, 07 | BM plus SH | P1 |
| boss_kraken_rainbow | Rainbow octopus, 6 tentacles, splash | 12 | BM plus SH | P1 |
| boss_wind_cloud | Angry storm cloud with swirl streams | 12 | BM plus PT | P1 |
| boss_stone_guardian | Mossy stone golem, glowing eyes | 11 | BM | P2 |
| boss_goblin | Green goblin, two variants, rock throw pose | 07 | BM | P1 |
| boss_sea_serpent | Teal sea monster head and fins | 10 | BM | P2 |

## 4. Biome islands and backgrounds

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| env_island_meadow_large | Meadow board island with chunked cliffs, roots | 15 | BM | P0 |
| env_island_ice_large | Ice island with snow cap, icicles | 15 | BM | P0 |
| env_island_celestial_large | White marble island with gold inlay, broken pillars | 15 | BM | P1 |
| env_island_candy_large | Cake and frosting island | 13, m15 | BM | P2 |
| env_island_lava_large | Basalt island with lava falls | 13, m16 | BM | P1 |
| env_island_forest_large | Forest bark island | 13 | BM | P2 |
| env_island_crystal_large | Crystal cave floating rock | 13, m14 | BM | P2 |
| env_island_clockwork_large | Brass gear-base island | 13, m16 | BM | P2 |
| env_island_neon_large | Sci-fi hex deck | 13, m17 | BM | P2 |
| env_island_underwater_large | Reef island | 13, m06 | BM | P2 |
| env_island_fair_large | Fairground tent and bunting island | 14 | BM | P2 |
| env_island_dune_large | Sand and arabesque island | 13 | BM | P2 |
| env_bg_meadow_far / mid / near | Backdrop layers: islands, waterfalls, mountains, clouds, 1440x2560 | 15 | BR | P0 |
| env_bg_ice_far / mid / near | Ice castle, snow mountains | 15 | BR | P0 |
| env_bg_celestial_far / mid / near | Galaxy, planets, ruined arch | 15 | BR | P1 |
| env_bg_other_biomes | One far plus mid layer for the 9 other biomes | 13 | BR | P2 |
| env_hub_party_fort | Central wooden fort, scoreboard stage, banner | m16 | BM | P1 |
| env_hub_bridge_glow | Rope-light plank bridge (x4) | m16 | BM | P1 |
| env_hub_island_bridge | Bridge Builders island | m16 | BM | P1 |
| env_hub_island_bomb | Brass bomb disc island | m16 | BM | P1 |
| env_hub_island_balloon | Cloud racetrack island | m16 | BM | P2 |
| env_hub_island_lava | Volcano island with pyramid | m16 | BM | P2 |
| env_story_library | Library interior hero scene (also menu backdrop) | 01, 03 | BR | P0 |
| env_story_scene_01..09 | Story-beat paintings: library, tutorial, biomes cart, canopy, goblins, forge, cosmic, finale, tournament | 01, 02, 07 | BR | P2 |

## 5. Props

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| prop_rim_meadow_kit | Flowers, clover, bushes, grass tufts (MultiMesh atlas) | 15 | BM | P0 |
| prop_rim_ice_kit | Frost trees, snow shrubs | 15 | BM | P0 |
| prop_rim_celestial_kit | Broken pillars, arch, floating rubble | 15 | BM | P1 |
| prop_tile_stone_board | Rounded stone board tile with soft grout | 15 | BM | P0 |
| prop_ghost_cell | Glassy ghost cube and cell highlight | 01, 14 | SH | P0 |
| prop_cottage_waterfall | Title cottage with waterfall | 15 | BM | P0 |
| prop_lantern | Brass lantern | 15, 14 | BM | P1 |
| prop_bunting | Flag bunting strings | 14, m12 | BM | P1 |
| prop_cannon_catapult | Cannon, catapult, trebuchet | 07, 09, 12 | BM | P1 |
| prop_cart_blocks | Block wagon, buggy, mine cart | 01, 02 | BM | P2 |
| prop_castle_tower_fort | Stone castle, tower, brick fort | 07, 09, 12 | BM | P1 |
| prop_balance_platform | Tilting disc platform | 07, 10 | BM | P1 |
| prop_trophy_chest | Gold trophy, chest of jewels, confetti sheet | 02, 03, 14 | BM | P0 |
| prop_book_open | Glowing open book, lectern | 01, 02 | BM | P0 |
| prop_potions_books | Potions, books, globe set dressing | 03 | BM | P1 |
| prop_cloud_set | Puffy clouds with lilac swirls | 15, 16 | BM | P0 |
| prop_conveyor_gear | Conveyor belts, gears, furnace, claw | m06, 12 | BM | P2 |
| prop_temple_ruins | Stone head, boulders, vines | m06 | BM | P2 |
| prop_bomb_big | Giant cartoon bomb | m16 | BM | P2 |
| prop_pickaxe_drill_key | Tool, drill, key props | 11, 12 | BM | P2 |
| prop_hex_scifi_deck | Hex floor, holo screens, drones | m17 | BM | P2 |
| prop_wheel_round_pick | Wooden roulette wheel | 14 | BM | P1 |

## 6. Blocks

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| blk_meadow_cube | Dirt, thick grass cap, pebbles, clover topper | 13 | BM plus SH plus bake | P0 |
| blk_ice_cube | Frosted translucent, snow cap, icicles, snowflake | 13 | BM plus SH | P0 |
| blk_celestial_cube | Galaxy swirl, gold stars, star topper | 13 | BM plus SH | P0 |
| blk_candy_cube | Jelly, frosting drip, sprinkles, heart | 13 | BM plus SH | P1 |
| blk_lava_cube | Cracked basalt, emissive cracks, spike | 13 | BM plus SH | P1 |
| blk_underwater_cube | Deep-blue glass, bubbles, coral | 13 | BM plus SH | P1 |
| blk_forest_cube | Bark, tree-ring top, moss, leaf | 13 | BM plus SH | P2 |
| blk_crystal_cube | Grey stone, purple crystals | 13 | BM plus SH | P2 |
| blk_clockwork_cube | Navy panel, brass rivet frame, gear | 13 | BM plus SH | P2 |
| blk_neon_cube | Dark glass, cyan circuit | 13 | BM plus SH | P2 |
| blk_fair_cube | Pink-cream stripes, ticket | 13 | BM plus SH | P2 |
| blk_dune_cube | Sand, teal arabesque, dome | 13 | BM plus SH | P2 |
| blk_toppers_atlas | Sprout, flower, clover, crystal, star, heart, ticket, gear, dome | 13 | BM | P0 |
| blk_scifi_crate | Metal cube with glowing seams (Quantum Spire) | m17 | BM plus SH | P2 |
| blk_piece_icons | Pre-rendered piece icons for NEXT and tray, per biome | 15 | UR | P0 |
| blk_sheep_fence | Wooden fence segment | m15 | BM | P2 |

## 7. VFX

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| vfx_sparkle_star_loop | Four-point gold star sparkle (additive, 128px) | 01, 16 | PT | P0 |
| vfx_confetti_burst | Win confetti and fireworks | 02, 14 | PT | P0 |
| vfx_drop_dust_puff | Landing dust ring | 15, 07 | PT | P0 |
| vfx_place_glow | Ghost snap glow and landing flash | 01 | PT plus SH | P0 |
| vfx_magic_trail | Wand glitter trail from the wizard | 01 | PT | P1 |
| vfx_explosion_burst | Impact burst, debris chunks | 02, 10, 12 | PT | P1 |
| vfx_lava_splash_ember | Lava splash and embers | 02, 07 | PT plus SH | P1 |
| vfx_wind_swirl | Cloud wind streams | 07, 12 | PT plus SH | P1 |
| vfx_snow_avalanche | Falling ice and snow | 09 | PT | P2 |
| vfx_water_splash_foam | Kraken splash, river foam | 12, 09 | PT plus SH | P2 |
| vfx_laser_trace | Sci-fi beams and portals | 02, m17 | PT plus SH | P2 |
| vfx_portal_swirl | Cosmic swirl portal | 02, 07 | SH | P2 |
| vfx_water_caustics | Underwater light shafts | m06 | SH | P2 |
| vfx_tilt_warning | Danger ring and warning flash | 07, 10 | PT | P1 |

## 8. Minigame set pieces

Each set is an island or arena with a diorama look plus its dressing. Build after the
hub. Names are working titles from the boards; we will rename with the game designer if any are too close
to third-party titles.

| Id | Description | Ref | Build | Pri |
|---|---|---|---|---|
| mg_bridge_bashers | Canyon with river and block bridge | 09 | BM | P1 |
| mg_avalanche_ascent | Snowy cliff, storm, avalanche | 09 | BM | P2 |
| mg_rubble_rumble | Lava cave arena with block ruins | 09 | BM | P2 |
| mg_fort_frenzy | Two castles on a meadow with catapults | 09 | BM | P1 |
| mg_rolling_rumble | Forest racetrack with arches | 10 | BM | P2 |
| mg_tumbling_towers | Tilting disc island at sea | 10 | BM | P1 |
| mg_shatter_shootout | Cliff, ships, cannons, tower | 10 | BM | P2 |
| mg_frenzy_footholds | Lava cave with floating glowing blocks | 10 | BM | P2 |
| mg_bridge_dash | Floating cliffs, cloud gap | 11 | BM | P2 |
| mg_fort_blast | Sea cliffs, cannons, stone fort | 11 | BM | P2 |
| mg_maze_heist | Ruined maze, stone guardian | 11 | BM | P2 |
| mg_summit_scramble | Snow peak and lava stream | 11 | BM | P2 |
| mg_clockwork_conveyor | Gear factory floor | 12 | BM | P2 |
| mg_kraken_blockade | Sea wall and towers | 12 | BM | P1 |
| mg_digging_frenzy | Mine block grid with crystals | 12 | BM | P2 |
| mg_chroma_sky_climb | Glass cube bridge in space | 12 | BM | P2 |
| mg_temple_roller | Jungle temple run with boulders | m06 | BM | P2 |
| mg_submarine_salvage | Seabed crane and wreck | m06 | BM | P2 |
| mg_factory_frenzy | Assembly floor with gear cubes | m06 | BM | P2 |
| mg_cosmic_gravity | Neon stadium hover goal | m06 | BM | P2 |
| mg_meadow_mayhem | Meadow with sheep pen and gnomes | m12, m15 | BM | P1 |
| mg_candy_land | Cake and lollipop track | m12, m15 | BM | P2 |
| mg_glacier | Ice floe with penguins | m12, m15 | BM | P2 |
| mg_cosmic_tower | Sci-fi ring tower | m12 | BM | P2 |
| mg_lava_rumble | Bumper bubbles on a round stone arena | m14 | BM | P2 |
| mg_jungle_dash | Rope bridge, boulder, fruit | m14 | BM | P2 |
| mg_gem_grab | Crystal mine island | m14 | BM | P2 |
| mg_neon_splat | Hex arena painting floor | m14 | BM | P2 |
| mg_quantum_spire | Hex board with holo HUD | m17 | BM | P2 |
