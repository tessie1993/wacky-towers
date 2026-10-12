# Art TODO: Wacky Towers (production checklist)

> **Owner**: art-director · **Scanned**: 2026-10-10 · **Data twin**: `production/art/art-todo.json` (same ids)
> **Sources**: `design/art/art-bible.md`, `design/art/block-art-sets.md`, `docs/art/biomes/*.md` + `art_asset_manifest.json`, `design/gdd/meadow-asset-list.md`, `design/gdd/ux/*.md`, `design/gdd/mechanics-wave3.md`, `design/gdd/party-minigames-wave2.md`, `design/levels/*.md`, `assets/data/**`, `src/view/**`, `src/ui/**`, the user's references in `assets/art/reference/` (`title_screen_ref.png`, `screens_flow_ref.png`, `wizard_turnaround_ref.png`, `biome_block_materials_ref.png`).

## How to read a row

`- [ ] <asset id> — <description> — <where used> — <spec> — <priority> — <status>`

**Status words**
- **missing**: no file and no stand-in found.
- **placeholder → final**: drawn procedurally in code today (`wt_stage.gd`, `wt_toy_actor.gd`, `wt_content_geometry.gd`, `wt_minigame_art.gd`, `game_ui.gd` StyleBoxes). It works on screen but is not final art. The biome manifest marks all 2016 of its entries "live procedural geometry".
- **in progress**: being built now, per the user (block shader materials, title scene, wizard).
- **exists**: a file is on disk. Ticked `[x]`.

**Priority**: P0 = needed for the Meadow vertical slice and the first screens · P1 = the rest of the main campaign, tournament and shop · P2 = hard track, polish, store extras.

**Spec defaults** (art bible §8; there are no poly/texture budgets, removed 2026-10-09 by decision, so "budget" means profile on device later):
- Models: Blender → `.glb`, 1 unit = 1 cube edge, transforms applied, hand-painted albedo with baked AO, matte (gloss is for blocks only). Auto-LOD off on block and shell imports.
- 2D: lossless PNG, painted at 2× the shipped size. UI atlas uncompressed. Skies are shader gradients, not textures.
- Icons: painterly prop, one ink outline (`#2E2433`), two tones + highlight, must read as a silhouette at 32 px; author at 256 px, ship 128/64 px. They must never look like a block piece.
- UI frames: painted-wood 9-slice PNG, parchment `#FFF4DE` interior, dark neutral outer edge, trim under 10% of plate height, no glow.
- Naming: `prefix_scope_name_variant` (`blk_`, `shl_`, `env_`, `prp_`, `chr_`, `ui_`, `vfx_`), map suffixes `_alb/_nrm/_msk`.

## 1. Summary

| Category | Needed | Exists | In progress | Placeholder → final | Missing |
|---|---|---|---|---|---|
| (filled in at the end of the pass) | | | | | |

---

## 2. Screens & UI

Nothing under `assets/ui/` or `assets/fonts/` exists yet. Every screen is built in code by `src/ui/game_ui.gd` (`_make_theme()` draws flat cream/ink StyleBoxes) and `src/ui/minigame_ui.gd`. All screen chrome is therefore **placeholder → final**. The UI theme spec (`design/gdd/ux/ui-theme.md`) defines the file layout used below.

### 2.1 Shared theme, fonts and frames

- [ ] ui_font_display_fredoka — Display font Fredoka (variable, 300–700) + `OFL.txt`; MSDF import; verify `tnum` digits — every screen, H1–H2, HUD digits — `assets/fonts/`, SIL OFL — P0 — missing
- [ ] ui_font_body_nunito — Body font Nunito (variable) + `OFL.txt` — menus, settings, credits — `assets/fonts/`, SIL OFL — P0 — missing (only addon copies in `addons/phantom_camera/fonts/`)
- [ ] ui_theme_base — `wt_base.tres` with every type variation (PlateFrame, PanelSheet, DialogPanel, ToastPanel, PrimaryButton, IconButton, InPlayButton, GoalDigits, TabButton, ProfileCard, ToggleRow) — all screens — Godot Theme; art supplies the textures — P0 — placeholder → final (code theme in `game_ui.gd::_make_theme`)
- [ ] ui_focus_ring — Double focus ring (3 pt ink inside, 2 pt white outside) — all buttons — 9-slice PNG — P0 — placeholder → final
- [ ] ui_states_kit — Toggle knob on/off with ✔ notch, lock badge (disabled), bin badge (destructive), tab underline / side bar — Settings, Profiles — PNG sheet, 128 px cells — P0 — missing
- [ ] ui_dim_overlay — Modal dim (50% black) and pause dim — Pause, dialogs — shader/colour, no texture — P0 — placeholder → final

### 2.2 Biome frame sets (painted wood, 12 sets)

Each set holds the 9 frames from ui-theme §2: plate, sheet, dialog, toast, pill (primary), round (icon button), in-play (no trim), tab, card. Plus `assets/ui/themes/biomes/<biome>.tres`. Meadow is built first. Trim per art bible §7.

- [ ] ui_meadow_frameset — Honey wood / leaf green; daisies, clover, vine curl — all screens while in Meadow; fallback for every biome — 9 × 9-slice PNG (2×), `assets/ui/frames/meadow/` — P0 — missing
- [ ] ui_candy_frameset — Pastel pink / mint; sprinkle dots, piped icing edge — Candy — 9 × 9-slice PNG — P1 — missing
- [ ] ui_ice_frameset — Pale blue-white / deep teal; snowflakes, short icicle edge — Ice — 9 × 9-slice PNG — P1 — missing
- [ ] ui_underwater_frameset — Sea green / coral (driftwood); shells, bubble dots, wave scallops — Underwater — 9 × 9-slice PNG — P1 — missing
- [ ] ui_lava_frameset — Charred brown / ember orange; painted embers (below 60% saturation), chipped corners — Lava — 9 × 9-slice PNG — P1 — missing
- [ ] ui_forest_frameset — Dark oak / moss; acorns, carved leaves — Forest — 9 × 9-slice PNG — P1 — missing
- [ ] ui_cave_frameset — Slate grey / crystal violet; painted crystals, lantern dots — Cave — 9 × 9-slice PNG — P1 — missing
- [ ] ui_clockwork_frameset — Walnut / brass yellow; painted cogs and rivets — Clockwork — 9 × 9-slice PNG — P1 — missing
- [ ] ui_neon_frameset — Navy / flat-paint glow pink and cyan, no emission; line trim — Neon — 9 × 9-slice PNG — P1 — missing
- [ ] ui_celestial_frameset — Cream / gold (kept off reward gold); stars, sun and moon — Celestial — 9 × 9-slice PNG — P1 — missing
- [ ] ui_carnival_frameset — Tumble Fair: striped big-top paint; bunting, bulb dots (painted, not lit) — Tumble Fair (carnival) — 9 × 9-slice PNG — P2 — missing (art bible: side islands reuse the nearest set with own trim)
- [ ] ui_dune_frameset — Dune Bazaar (planned): sun-bleached wood / terracotta; tile-pattern band — Dune Bazaar (dune) — 9 × 9-slice PNG — P2 — missing

### 2.3 Title screen (user brief + `title_screen_ref.png`; ux `title.md`) — IN PROGRESS

The title is a 3D scene: a wizard workshop, a floating Meadow island with a tile grid, the wizard on a cloud, a wooden title sign, PLAY and BIOMES buttons. `game_ui.gd::show_title` today draws a flat panel over the stage (evidence `production/qa/evidence/build-2026-10-10/title.png`).

- [ ] env_title_workshop — Wizard workshop interior: shelves of toy dioramas, workbench, window, warm lamplight (art bible §2 "Menus and shop") — Title — glb, hand-painted matte, high prop density allowed — P0 — in progress
- [ ] env_title_meadow_island — Floating Meadow island with flat gridded tile top, strata body, root underside — Title (also map hero) — glb; tiles ≤ 1/5 cube high with grid lines — P0 — in progress
- [ ] chr_wizard_title_pose — Wizard on cloud, idle bob + wave/cast loop for the title — Title — uses `chr_wizard` rig — P0 — in progress
- [ ] prp_title_sign — Wooden title sign carrying the logo, hung/planted on the island — Title — glb + logo decal; sign wood matches Meadow frame set — P0 — in progress
- [ ] ui_title_logo — "Wacky Towers" logo, chunky stacked-block letters, ink outline; landscape and portrait lockups — Title sign, store, splash — PNG 2048 wide + 1024 portrait lockup; 3D letters rendered from Blender allowed — P0 — in progress (part of the title scene)
- [ ] ui_btn_title_play — PLAY primary pill, reward-gold face, ink label, press squash states — Title — 9-slice pill + label; ≥ 56 pt tall — P0 — in progress
- [ ] ui_btn_title_biomes — BIOMES pill (secondary, parchment face) — Title — 9-slice pill — P0 — in progress
- [ ] ui_title_secondary_icons — Settings gear, profile badge chip, credits heart, quit door — Title corners — icons 128 px — P0 — missing
- [ ] vfx_title_ambient — Drifting clouds, dust motes in the workshop lamp light, slow camera orbit — Title — particles; reduced-motion off — P1 — missing

### 2.4 Profile select (ux `profile-select.md`)

- [ ] ui_profile_card — Card frame with nameplate notch; states filled / empty "+" / active ring + ✔ / edit mode — Profile select — in the frame set + state overlays — P0 — placeholder → final
- [ ] ui_profile_badges_8 — 8 profile badges with distinct silhouettes (colourblind identity) — Profile cards, HUD plates, results — 8 icons, 128 px — P0 — missing
- [ ] ui_profile_icons — add "+", edit ✎, delete bin, dice (random name) — Profile select — icons 128 px — P0 — missing

### 2.5 Island map / BIOMES (ux `island-map.md`; `screens_flow_ref.png`)

- [ ] env_map_overworld — Map scene: island chain of 10 biomes (+ Tumble Fair, Dune Bazaar side islands), stepping-cloud paths — Map — glb dioramas on a toy-shelf, warm indoor light — P0 (Meadow cluster) / P1 (rest) — placeholder → final (`show_map` panel)
- [ ] env_meadow_map_millhill — Central Mill Hill with mill, Miller on the roof (grumpy → at picnic) — Map, Title — glb, re-use of island_10 + mill_near — P0 — missing
- [ ] prp_meadow_map_path_cloud — Stepping-cloud path pieces that light up per cleared level — Map — small glb from the wizard cloud mesh — P0 — missing
- [ ] ui_map_level_node — Level node plate: number, 0–3 stars, lock, "!" new, bonus/hard-track marker — Map — PNG set — P0 — placeholder → final
- [ ] ui_map_biome_island_icons_12 — Biome island thumbnails (locked / open / complete), one per biome incl. carnival, dune — Map, BIOMES picker — 12 × PNG 512 px — P1 — missing
- [ ] ui_map_star_counter — Star total plate + sparkle — Map — plate + icon — P0 — missing

### 2.6 Level intro and countdown (ux `level-intro-countdown.md`)

- [ ] ui_intro_card — Story card panel with level name, story icon slot, goal icon, rule-strip icons — Level intro (`show_intro`, `_staging/level_intro`) — sheet frame + layout — P0 — placeholder → final
- [ ] ui_countdown_digits — 3-2-1-GO display digits with pop-in — Countdown (`show_countdown`) — font-based, ink outline; optional painted "GO!" PNG — P0 — placeholder → final

### 2.7 In-game HUD (ux `hud.md`, `design/gdd/hud.md`; user brief)

User brief: SCORE panel with stars, NEXT preview, pause button and a bottom 3-piece tray, each themed per biome. One row per element per biome (12 biomes). The NEXT preview shows the real 3D piece (art bible §7), so its plate is a frame, not an icon.

- [ ] ui_hud_shared_icons — Star filled/outline, clock, warning triangle, goal-type icons (clear, height, fill, survive, rescue, bonk, wind keys, free moles), mascot-catch token, duck collectible, fog "tap solid" hint — HUD — icons 128 px — P0 — missing
- [ ] ui_hud_inplay_buttons — d-pad arrow, Turn ◀/▶, Flip ◀/▶, Roll ◀/▶, hard drop, soft drop, View ◀/▶, corner view ×4, hold slot — HUD controls — icons 128 px on InPlayButton frame (no trim), 56–64 pt — P0 — placeholder → final (text buttons in `_build_hud`)
- [ ] ui_hud_rule_strip_frame — Rule-strip chip frames: buff up-chevron (cyan), debuff down-chevron (magenta), hazard triangle (orange) — HUD — 9-slice PNG ×3 — P0 — missing
- [ ] ui_hud_item_slot — Round item slot (circle = consumable) with charge ring — HUD item bar (`_build_item_bar`) — PNG + ring shader — P0 — placeholder → final
- [ ] ui_hud_danger_plate_state — Warm-edge plate state + stripe pattern (Shapes setting) — HUD plates — overlay PNG — P1 — missing

**Per-biome HUD set** (4 elements × 12 biomes). Spec for all: painted-wood 9-slice PNG at 2×, parchment interior, H2 digits ≥ 18 pt, inside safe-area; frames never animate in play. Score panel = rounded plate with score digits and a 3-star row; NEXT = plate ≥ 64 pt holding the live 3D piece; pause = round IconButton frame with ❚❚ glyph; tray = bottom plate with 3 piece slots.

| Biome | Score panel + stars | NEXT preview frame | Pause button | Bottom 3-piece tray | Priority |
|---|---|---|---|---|---|
| meadow | ui_meadow_hud_score | ui_meadow_hud_next | ui_meadow_btn_pause | ui_meadow_hud_tray | P0 |
| candy | ui_candy_hud_score | ui_candy_hud_next | ui_candy_btn_pause | ui_candy_hud_tray | P1 |
| ice | ui_ice_hud_score | ui_ice_hud_next | ui_ice_btn_pause | ui_ice_hud_tray | P1 |
| underwater | ui_underwater_hud_score | ui_underwater_hud_next | ui_underwater_btn_pause | ui_underwater_hud_tray | P1 |
| lava | ui_lava_hud_score | ui_lava_hud_next | ui_lava_btn_pause | ui_lava_hud_tray | P1 |
| forest | ui_forest_hud_score | ui_forest_hud_next | ui_forest_btn_pause | ui_forest_hud_tray | P1 |
| cave | ui_cave_hud_score | ui_cave_hud_next | ui_cave_btn_pause | ui_cave_hud_tray | P1 |
| clockwork | ui_clockwork_hud_score | ui_clockwork_hud_next | ui_clockwork_btn_pause | ui_clockwork_hud_tray | P1 |
| neon | ui_neon_hud_score | ui_neon_hud_next | ui_neon_btn_pause | ui_neon_hud_tray | P1 |
| celestial | ui_celestial_hud_score | ui_celestial_hud_next | ui_celestial_btn_pause | ui_celestial_hud_tray | P1 |
| carnival | ui_carnival_hud_score | ui_carnival_hud_next | ui_carnival_btn_pause | ui_carnival_hud_tray | P2 |
| dune | ui_dune_hud_score | ui_dune_hud_next | ui_dune_btn_pause | ui_dune_hud_tray | P2 |

- [ ] ui_meadow_hud_score — Meadow SCORE panel with 3-star row — HUD — see table spec — P0 — placeholder → final
- [ ] ui_meadow_hud_next — Meadow NEXT preview frame — HUD — see table spec — P0 — placeholder → final
- [ ] ui_meadow_btn_pause — Meadow pause button — HUD — see table spec — P0 — placeholder → final
- [ ] ui_meadow_hud_tray — Meadow bottom 3-piece tray — HUD — see table spec — P0 — placeholder → final
- [ ] ui_<biome>_hud_score / _hud_next / _btn_pause / _hud_tray — the other 11 biomes, 44 rows (listed individually in the JSON) — HUD — see table spec — P1 (carnival, dune P2) — placeholder → final for the 9 campaign biomes, missing for carnival and dune

### 2.8 Pause (ux `pause.md`; `show_pause`)

- [ ] ui_pause_sheet_icons — resume ▶, restart ↺, rules list (scroll), map, settings, quit door — Pause — icons 128 px — P0 — missing
- [ ] ui_pause_rule_list_row — Rule list row with rule icon + "not used here" perk tag — Pause — row frame — P1 — placeholder → final

### 2.9 Results (ux `results.md`; `show_results`)

- [ ] ui_results_banner — Win / lose H1 banner plates (no repeated banners) — Results — 9-slice PNG ×2 — P0 — placeholder → final
- [ ] ui_results_star_stamp — 3 large reward-gold stars + empty sockets, stamp-in bounce frames — Results — PNG 256 px + sparkle — P0 — missing
- [ ] vfx_results_win_confetti — Golden-hour rim light + confetti on 3★ — Results — particles — P1 — missing
- [ ] ui_results_buttons — next ▶▶, retry ↺, map — Results — icons 128 px — P0 — missing

### 2.10 Settings (ux `settings.md`; `show_settings`)

- [ ] ui_settings_tab_icons — speaker, screen, gamepad+hand, camera, accessibility figure, ⓘ — Settings tabs — 6 icons — P1 — missing
- [ ] ui_settings_row_icons — music note, SFX burst, UI click, haptics, mirror, layout editor, keyboard, gamepad, touch, eye (reduced motion), shapes (colourblind), Aa, button size, labels, gizmo rings, snail (relaxed timing), orientation lock — Settings rows — 17 icons — P1 — missing

### 2.11 Loading, save error, notices (ux `loading-and-save-error.md`)

- [ ] ui_loading_wizard_swirl — Loading: cloud-wizard swirl loop — Loading — PNG sequence or 3D wizard pose — P1 — missing
- [ ] ui_notice_icons — save problem (cracked scroll), backup restored, update needed, saving (quill), privacy shield — Notices, dialogs — 5 icons — P1 — missing
- [ ] ui_splash — Boot splash with logo — App start — PNG 1920×1080 + portrait — P1 — missing

### 2.12 Credits (ux `credits.md`)

- [ ] ui_credits_backdrop — Credits sheet over slowly turning diorama; heart icon — Credits — reuse title scene camera — P2 — missing

### 2.13 Story skits (`show_story`, `src/ui/wordless_story.gd`, `assets/data/story/**`)

- [ ] ui_emote_set_14 — Wordless emote bubbles: heart, exclaim, question, idea, zzz, music, anger, laugh, sweat, tear, star eyes, dizzy, lonely cloud, invite — Skits, toy actors (`wt_toy_actor.gd` Label3D bubble) — 14 icons 256 px + bubble frame — P0 — placeholder → final (Label3D text)
- [ ] ui_skit_bubble_frame — Speech-bubble frame for emotes — Skits — 9-slice PNG — P0 — missing

### 2.14 Shop (`show_shop`; `design/gdd/shop.md`)

- [ ] ui_shop_shelf_backdrop — Toy-shop shelf with the biome diorama turning slowly — Shop — 3D scene re-using the workshop set — P1 — missing
- [ ] ui_shop_item_card — Item card frame (perk / potion / cosmetic variants), price plate, owned ✔ — Shop — 9-slice PNG ×3 — P1 — placeholder → final
- [ ] ui_currency_icon — Star currency icon (reward gold + sparkle) — Shop, results, map — icon 128 px — P1 — missing

### 2.15 Character select + perks (`characters-perks.md` Visual/Audio; not built in code yet)

- [ ] ui_charselect_cards_4 — Four character cards (c1 wizard, Lana, Boulder, Glim) with portrait, identity icon, skill icon — Character select — card frame + 4 portraits 512 px — P1 — missing
- [ ] ui_perk_chip — Perk chips: signature with ribbon, edge with "+" and edge bar — Character select, Pause — PNG set — P1 — missing

### 2.16 Arcade, tournament and party screens (`show_arcade`, `show_tournament`, `show_round_card`, `show_round_results`, `minigame_ui.gd`)

- [ ] ui_arcade_hub — Arcade hub (Toy-Box Trials): 3 diorama tiles (Meadow, Clockwork, Celestial) — Arcade (evidence `arcade_pack/godot_hub.png`) — tile frames + renders of the existing GLBs — P1 — placeholder → final
- [ ] ui_tournament_lobby — Lobby: 4 player plates in player colours + hat emblems, ready ✔ — Tournament (evidence `full-build/ui/lobby_*.png`) — plate frames ×4 colours — P1 — placeholder → final
- [ ] ui_hat_emblems_4 — 4 multiplayer hat emblems (distinct silhouettes) — Lobby, HUD, wizard hats — icons 128 px + decal — P1 — missing
- [ ] ui_round_card — Minigame round card: card art slot (mgNN.png), name, rule icons — Round card (`game_ui.gd:1445`) — card frame 9-slice — P1 — placeholder → final
- [ ] ui_round_results_podium — Round results podium / ranking plates 1st–4th — Round results — PNG set — P1 — placeholder → final
- [ ] ui_minigame_action_buttons — Per-minigame action buttons (roll, pull, whack, dig, tap pads) — `minigame_ui.gd::_build_actions` — icons 128 px — P1 — placeholder → final
- [ ] ui_physics_challenge_frame — Physics challenge screen chrome — `show_physics` (evidence `full-build/ui/physics_*.png`) — frame set use — P2 — placeholder → final
- [ ] ui_tools_screen — Dev/level-maker tools screen — `show_tools` — frame set use only — P2 — placeholder → final
- [ ] ui_toast_icons — Toast leading icons (info, star, warning) — `show_toast` — 3 icons — P1 — missing

---

## 3. Blocks and block materials

The shape bank is 67 shapes (`assets/data/shapes/shape_bank.tres`). Per the art bible, a biome is an **art style only**: every biome set holds the full shape bank, and only the material, edge style and palette change. Reference: `assets/art/reference/biome_block_materials_ref.png`. There are now **12 biome block materials** (10 campaign + Tumble Fair `carnival` + Dune Bazaar `dune`, planned). The user says the block shader materials are being built now.

### 3.1 What exists on disk

- [x] blk_candy_toy_set — Default set, 67 shape GLBs + `blk_candy_toy_cube.res` — every board today — `assets/models/blocks/candy_toy/` — P0 — exists
- [x] blk_neon_voxel_set — Neon voxel set, shape GLBs + `blk_neon_voxel_cube.res` — Neon / board preview — `assets/models/blocks/neon_voxel/` — P1 — exists
- [ ] blk_forest_bark_set — Forest Bark set: an import screenshot exists (`production/qa/evidence/block_import_forest_bark.png`) but no `assets/models/blocks/forest_bark/` folder — Forest — re-export or commit the GLBs — P1 — missing (evidence only)

### 3.2 Biome block shader materials (12) — IN PROGRESS

Spec for all: one shared block shader (toon ramp, top-left gloss, inverted-hull outline tinted per piece), per-instance params (hue, motif, effect id) through MultiMesh, palette from `block-art-sets.md` §Palettes, ≥ 5–6 lightness steps (greyscale check), no hue within 25° of buff 186° / debuff 322°. Colour-vision simulator pass required.

- [ ] mat_blk_meadow — Meadow: gummy jelly, fat pillow 22%, sugar speckle, trapped bubbles; turf/clover theme set — Meadow boards — shader material + `_alb/_nrm/_msk` — P0 — in progress
- [ ] mat_blk_candy — Candy: gummy candy / gummy jelly — Candy — shader material — P1 — in progress
- [ ] mat_blk_ice — Ice: frosted glass / snow-porcelain tile 11% (keep pieces off the ice backdrop) — Ice — shader material — P1 — in progress
- [ ] mat_blk_underwater — Underwater: deep-sea gems with bubbles / pearl nacre 22% (teal vs buff cyan check) — Underwater — shader material — P1 — in progress
- [ ] mat_blk_lava — Lava: obsidian glass, chamfered 12% (glow seams allowed, kept below hazard orange) — Lava — shader material — P1 — in progress
- [ ] mat_blk_forest — Forest: forest bark / painted wooden toy 14%, planks, end-grain rings — Forest — shader material — P1 — in progress
- [ ] mat_blk_cave — Cave: slate with violet crystals / river pebble 25% — Cave — shader material — P1 — in progress
- [ ] mat_blk_clockwork — Clockwork: gears cube kit / enamelled tin 10%, rivets (gold vs reward gold check) — Clockwork — shader material — P1 — in progress
- [ ] mat_blk_neon — Neon: neon glass, glowing edge grooves (cyan/magenta vs buff/debuff open question) — Neon — shader material — P1 — in progress
- [ ] mat_blk_celestial — Celestial: purple cosmic marble, stepped 15%, star flecks — Celestial — shader material — P1 — in progress
- [ ] mat_blk_carnival — Tumble Fair (carnival): candy-stripe / toy plastic look — Tumble Fair — shader material — P2 — in progress
- [ ] mat_blk_dune — Dune Bazaar (dune, planned): glazed terracotta, 17% hand-thrown wobble, pottery band — Dune Bazaar — shader material — P2 — in progress

### 3.3 Shared block support art

- [ ] blk_motif_atlas_msk — Face-motif mask atlas (bar, ring, cross, half-moon, wave, … one per shape) shared by blocks and UI symbols — every set, colourblind aid — PNG atlas 2048 — P0 — missing
- [ ] ui_motif_symbols — 2D motif symbols matching the atlas — NEXT preview, Shapes setting — icons 64 px — P0 — missing
- [ ] blk_ghost_material — Landing ghost (hatched under the Shapes setting) — board — shader — P0 — placeholder → final (`ghost_view.gd`)
- [ ] shl_status_shells — Status shells: frost, honey, cracks, vines, licorice, frosting tiers, locked, confetti, anvil, mystery "?" — each = surface pattern + accent rim + icon badge, within 8% of the cube edge — board — shell meshes/shader variants — P1 — placeholder → final

---

## 4. Biome stages

Today every biome stage is procedural: `src/view/wt_stage.gd::BIOME_LOOKS` (4 colours per biome), `_build_light`, `_build_island`, `_build_props`, `_story_prop`. Captures: `production/qa/evidence/build-2026-10-10/biome-*.png`. The manifest lists per level a `background_<biome>` (island, sky, landmark), `board_<level>`, a hero prop, a clue prop and the mascot, all "live procedural geometry". Tumble Fair and Dune Bazaar have no stage code and no level data yet.

Spec for every stage: three-layer floating island (flat gridded top ≤ 1/5 cube high, strata body, signature underside); matte hand-painted, dark neutral outlines; backdrop ≤ 40% saturation; prop density by zone (none in grid + 1-cube margin, sparse rim, rich body/underside); one background landmark that moves closer across the 10 tiers; sky as a shader gradient. glb per piece.

| Biome | Sky + light | Island kit (top/body/underside) | Landmark + backdrop | Rim prop kit | Palette check |
|---|---|---|---|---|---|
| meadow | env_meadow_sky | env_meadow_island_kit | env_meadow_mill_near / _mid / _far (windmill), garden trees | prp_meadow_rim_kit | pal_meadow_check |
| candy | env_candy_sky | env_candy_island_kit | env_candy_landmark (lollipop row, cake strata) | prp_candy_rim_kit | pal_candy_check |
| ice | env_ice_sky | env_ice_island_kit | env_ice_landmark (ice crystal row, icicle roots) | prp_ice_rim_kit | pal_ice_check |
| underwater | env_underwater_sky | env_underwater_island_kit | env_underwater_landmark (coral, sunken ship) | prp_underwater_rim_kit | pal_underwater_check |
| lava | env_lava_sky | env_lava_island_kit | env_lava_landmark (volcano, ember caps) | prp_lava_rim_kit | pal_lava_check |
| forest | env_forest_sky | env_forest_island_kit | env_forest_landmark (Grandpa Oak giant tree, canopy) | prp_forest_rim_kit | pal_forest_check |
| cave | env_cave_sky | env_cave_island_kit | env_cave_landmark (crystal row, geode) | prp_cave_rim_kit | pal_cave_check |
| clockwork | env_clockwork_sky | env_clockwork_island_kit | env_clockwork_landmark (gear row, clock tower) | prp_clockwork_rim_kit | pal_clockwork_check |
| neon | env_neon_sky | env_neon_island_kit | env_neon_landmark (Glowtown skyline, billboard) | prp_neon_rim_kit | pal_neon_check |
| celestial | env_celestial_sky | env_celestial_island_kit | env_celestial_landmark (Moon, star/marble strata) | prp_celestial_rim_kit | pal_celestial_check |
| carnival | env_carnival_sky | env_carnival_island_kit | env_carnival_landmark (big top, Ferris wheel) | prp_carnival_rim_kit | pal_carnival_check |
| dune | env_dune_sky | env_dune_island_kit | env_dune_landmark (bazaar domes, dunes) | prp_dune_rim_kit | pal_dune_check |

Each cell above is one checklist row in the JSON. Status: placeholder → final for the 10 campaign biomes (procedural in `wt_stage.gd`), missing for carnival and dune. Priority: Meadow P0, the other 9 P1, carnival and dune P2.

- [ ] env_meadow_sky — Sky shader gradient + warm late-morning light per tier — all Meadow levels, Map, Title — shader, ≤ 40% saturation — P0 — placeholder → final
- [ ] env_meadow_island_kit — Board island tiles, soil/brick strata body, root underside; 10 tier variants (more overgrown with tier) + bonus picnic islet — Meadow 01–10, B, H1–H3 — glb kit — P0 — placeholder → final
- [ ] env_meadow_mill_near / env_meadow_mill_mid / env_meadow_mill_far — The Miller's windmill at three distances (sails spin) — Meadow 03–10, Map, Title — glb + card renders — P0 — placeholder → final
- [ ] prp_meadow_rim_kit — Daisies, clover tufts, small stones, garden trees (rim corners only) — Meadow — glb kit — P0 — placeholder → final
- [ ] pal_meadow_check — Colour-vision + greyscale pass of Meadow pieces on the Meadow backdrop (moss vs lime) — Meadow — capture sheet in `production/qa/evidence/` — P0 — missing
- [ ] env_<biome>_sky / _island_kit / _landmark, prp_<biome>_rim_kit, pal_<biome>_check — the other 11 biomes (55 rows, listed in the JSON) — see table — P1 / P2 — placeholder → final (campaign) or missing (carnival, dune)

### 4.1 Story hero and clue props (shared factory)

`wt_stage.gd::_story_prop` builds 29 procedural props used as each level's intro/goal hero and wordless clue: bed, chair, seed, flower, acorn, mushroom, basket, egg, pearl, tower, cube, gift, cake, bridge, clock, gear, flip, ice, star, moon, invite, hat, wind, mill, fog, dew, note, ember, lantern.

- [ ] prp_story_<id> ×29 — One painted glb per story prop id above (rows in the JSON) — level intro rim, payoff, skits — glb, ≤ 0.35 cube for hero props on pieces; rim props never hide the grid from any view angle — P0 for the Meadow ones (seed, invite, bed, flower, mushroom, tower, fog, dew, flip, mill, wind, basket), P1 rest — placeholder → final

### 4.2 Arcade pack (Toy-Box Trials)

- [x] env_meadow_arcade — Arcade diorama — Arcade — `assets/models/arcade_pack/env_meadow_arcade.glb` — P1 — exists
- [x] env_clockwork_arcade — Arcade diorama — Arcade — `assets/models/arcade_pack/env_clockwork_arcade.glb` — P1 — exists
- [x] env_celestial_arcade — Arcade diorama — Arcade — `assets/models/arcade_pack/env_celestial_arcade.glb` — P1 — exists
- [ ] arcade_pack_polish — Device readability review of the 3 arcade dioramas against the final block materials — Arcade — capture — P2 — missing
