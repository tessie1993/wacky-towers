# Meadow Scene Build Sheets (01-10 + bonus)

> Status: v1 (level-designer, 2026-10-10). Every number is a tunable default. Sources: `world-and-scenes.md` (scene notes, kit), `coder-handoff.md` (board/camera per level), `architecture-modular-layout.md` (LevelStage), `meadow_platform.gd` (exports `board_size`, `margin_cells`).
> Board sizes come from the handoff, NOT all 8x8: 01 4x4, 02 6x6, 03 8x4, 04 7x7, 05 5x5, 06 8x8, 07 6x6, 08 5x5, 09 6x6, 10 8x6, bonus 4x4.
> Stand-in assets: `assets/models/standin/meadow/` was empty when written (no MANIFEST). Props are named by ROLE (`bush_small`, `windmill_mid` ...); the builder maps role -> `sa_*.glb` and substitutes a primitive (box/sphere/cylinder, flat colour) if none exists.

## 0. Conventions (apply to every sheet)

- Units = cells. Origin = `BoardAnchor` = board footprint centre at floor y=0. +x east (right at yaw 0), +z toward the camera at yaw 0 (front), -z = backdrop side. Bearing = degrees clockwise from -z (0 = straight behind the board, 90 = +x).
- W x D = board_size (x by z). Board half-extents hx = W/2, hz = D/2. Platform covers board + margin (default 1).
- **Clear zone**: no prop inside |x| < hx+3 and |z| < hz+3 (margin 1 + 2 cells). Props sit on the island rim beyond that. Island body (turf) extends at least 5 cells past the board edge on every side.
- Scene path `src/levels/meadow/meadow_NN/meadow_NN.tscn`, inherits `src/levels/_template/level_stage_base.tscn`. JSON beside it: `meadow_NN.json`.
- Root exports (all levels): `level_json = res://src/levels/meadow/meadow_NN/meadow_NN.json`, `block_set = &"candy_toy"`, `camera_yaw_index = 0`, `camera_elevation_override_deg = 0` unless the sheet says otherwise.
- Base tree (all levels):
```
meadow_NN (LevelStage)
  BoardAnchor (Marker3D) pos (0,0,0)
  Diorama (Node3D)
    Platform (LevelPlatform)      board_size, margin_cells=1
    IslandBody                    turf+soil+pebble band, below y=0, rim >=5 cells past board
    Underside                     roots, clover drip (+ duck socket 01/02 only)
    Props (Node3D)                clusters per sheet
    Critters (Node3D)
    Landmark (Node3D)             windmill role + distance/bearing
    Sky (Node3D)                  WorldEnvironment + DirectionalLight3D (+ fill)
  MascotSpots (Node3D)            Marker3D by name
  Trees (Node3D)                  Beehave slot, see sheet
```
- **Beehave slot**: under `Trees`, instance one `meadow_NN_events` tree (scene-side events: skits, mascot cues, story-grows presenter) plus one tree per mechanic id listed in the sheet (id = handoff `rules`, e.g. `gust`). Trees only present/listen to `BoardController` signals; no rule numbers in the scene.
- Light presets (B5): sun = DirectionalLight3D, rotation given as (pitch down, yaw) degrees; shadows on, soft; `fog` = Environment depth fog. Sky colours are tunables, keep <=40% saturation (art bible).

## 1. Readability checks common to all levels

R1 Board contrast: platform top tiles lighter/cooler-neutral than surrounding turf by ~15% value; no dressing within the clear zone. R2 No gloss+bevel+cube-sized props (blocks own that look). R3 No mushroom/egg props near the board (backdrop only, >=12 cells away). R4 One moving thing near the board at most (the level's disturbance); ambient motion only in backdrop (>=10 cells). R5 Corner views (yaw index 0/3/6/9 = the four 90-degree views): tall props (>1.5 cells) never on a board diagonal inside 8 cells, so no cube is occluded and no cell sits behind a prop from any of the four. Check by placing the camera at each yaw and confirming the board + danger line are unobstructed.

## 2. Sheets

### 01 First Sprout (4x4, h_play 8)
- Exports: standard. Platform board_size (4,4), margin 1. Island: round-ish soil plot radius ~6, turf only on the rim ring (bare soil plot inside the clear zone).
- Seed mound: `seed_mound` at (0,0,0) is a presenter on `layers_cleared`, NOT on the playable cells' layer: put it on the underside side? No: the board is open, so place the mound at **(0, 0, -3.2)** just behind the board (clear zone edge) and let `meadow_01_events` grow leaf stages there; sunflower on win.
- Landmark: `windmill_far` at bearing 8 deg, distance 60, sails idle, no Miller.
- Props: `daisy_clump` x3 at (-5.5,0,4.5), (5.5,0,-4), (-4.5,0,-5.5); `clover_tuft` x4 on rim ring radius ~5.5; `pebble` x3 radius ~5.5; `fence_stub` x1 at (6,0,1.5). Backdrop: `hill_card` x3 at distance 45-70, `cloud_card` x4 at y 14-20.
- Critters: `butterfly` x2 backdrop (-12,6,-14),(10,5,-16) slow loop; `bee` x1 pass, backdrop only.
- Duck: socket in Underside on the -x side, visible from one yaw snap (handoff G12).
- Sky: clear morning. sky top #8F9AD8 -> horizon #E8E0CC; sun (-40, 35 deg yaw), warm white #FFF1D6 energy 1.1; ambient #BFC8E8; fog off.
- MascotSpots: `pip_idle` (-2.6,0,2.6), `pip_point`, `pip_catch` (1.0,0,2.8), `pip_cheer` (0,0,-3.0). Beside the platform margin edge, not on play cells.
- Trees: `meadow_01_events` (leaf-per-clear, win skit). No mechanic trees in first draft (mascot_catch later).
- Checks: bare board vs turf rim = strong contrast, OK. Mound behind board reads from yaw 0; from yaw 6 (180 deg) it is in front: it is low (<0.8 cell), acceptable; keep height <=0.8.

### 02 Tilt & Roll (6x6, h_play 10) - burrow
- Exports: standard. Platform (6,6), margin 1. Island: islet cut-away: stone+root chamber walls on -x, -z and +x sides only, **walls >=4 cells from board edge and <=1.5 cells high** so no occlusion; front (+z) open. Starter blocks are normal drizzle blocks (not stone).
- Landmark: `windmill_far` seen through `burrow_window` (round, 3 cells wide) in the back wall at (0,2.5,-hz-5 = -8), bearing 0, distance 55.
- Props: `nightcap` x3 on pocket edges (presenters of pockets; positions are board-content-driven, builder places at pocket edge markers `friends_a/b/c` instead: set the three markers at (-1.5,0,-3.6),(0,0,-3.6),(1.5,0,-3.6)); `root_arch` x2 on back wall; `candle` x1 at (-5,0,-6) (wall shelf, not floor); `pebble` x4; `clover_tuft` x3 at rim corners.
- Critters: three sleepy friends (vole, shrew, hedgehoglet roles) at `friends_a/b/c` (see above); snoring = events tree.
- Sky: dusk through window; env ambient warm #D9B58A low energy 0.6; key = `candle_light` OmniLight3D warm #FFB866 energy 1.4 at (-5,2.5,-6) range 12; sun (-15, 200) #FFC48A energy 0.5; fog off.
- Duck socket: underside +x side.
- MascotSpots: `pip_idle` (-3.8,0,3.8), `pip_point`, `pip_catch`, `friends_a/b/c`.
- Trees: `meadow_02_events`, `mascot_catch`.
- Checks: warm light vs block colours: ensure ambient not tinting starter blocks so pockets read; candle OmniLight must not cast hard shadow across the board (shadow off). Walls low enough for all four corner views.

### 03 Breezy Hill (8x4, h_play 10) - lane
- Exports: standard. Platform (8,4), margin 1. Island: long slope: uphill -x side rises 0 -> 2 cells over x -14..-5; **board area itself flat** at y=0. Downhill (+x) edge: `stone_fence` low wall (1 cell high, x=+7..+8, z -2..2) beyond the clear zone.
- Landmark: `windmill_mid` at bearing -70 (west/uphill), distance 38; sails animated by the gust presenter; `miller_silhouette` on its balcony.
- Props: `dandelion_clump` x8 (rim and backdrop, non-board), at (-8,0,5),(9,0,5),(-9,1,-4),(6,0,-5),(-6,0.5,-6),(10,0,-3),(0,0,-6.5),(3,0,6); `grass_tuft` x6; `pebble` x3. Clear zone: |x|<7, |z|<5.
- Critters: `butterfly` x1 backdrop; seed fluff only via the gust presenter.
- Sky: late morning scudding clouds. top #8F9AD8, horizon #EEE6D2; sun (-55, 20) #FFF4DC energy 1.2; `cloud_card` x6 drifting +x slowly (backdrop >=15 cells).
- MascotSpots: `pip_idle` (-5.2,0,3.4), `pip_catch` (3,0,3.5), `pip_sneeze` (-5.2,0,3.4).
- Trees: `meadow_03_events`, `gust`, `dandelion_puff`, `mascot_catch`.
- Checks: 8-wide board; dandelion heads are white round on green: not cube-sized (<0.5 cell), OK. Gust arrow is world-anchored; sails visible from yaw 0 only partially, fine. Uphill rise must stay below board sightline from yaw 3 (west view): keep rise starting x<-8.

### 04 Mushroom Ring (7x7, h_play 10) - pond
- Exports: standard. Platform (7,7), margin 1, mask centre 3x3 inactive (pond). Island: ring islet; `pond_water` plane at y=-0.4 under centre 3x3 (+0.25 margin), `lily_pad` x3 inside it (frogs). Pond lower than tiles.
- Landmark: `windmill_mid` bearing 15, distance 34; `bellows` prop on mill side (decor).
- Props: `reed_clump` x4 at pond-adjacent rim outside clear zone (x,z: (-7,0,-6),(7.5,0,-6.5),(-7.5,0,6.5),(7,0,7)); `daisy_clump` x4; `pebble` x4; `stepping_stone` x3 at far rim. **No mushrooms within 12 cells**; backdrop mushrooms (for `pip_bounce`) at (-14,0,-12),(15,0,-10),(-16,0,-6).
- Critters: `frog` x2 on lily pads (inside pond, y below grid), flinch on pop; `dragonfly` x1 backdrop.
- Sky: noon. top #8F9AD8, horizon #F0EAD8; sun (-75, 0) #FFF7E6 energy 1.3; pond glitter shader.
- MascotSpots: `pip_idle` (-5,0,5), `pip_bounce` (-14,0,-12). Floating `picnic_cloth` on pond at (1,-0.35,0) (inside the mask).
- Trees: `meadow_04_events`, `mushroom_popup`.
- Checks: pond water colour must differ from block colours and from play floor (blue-green desaturated vs warm turf). Spawn on front band (z+): keep front rim clear.

### 05 Tall Tower (5x5, h_play 12) - hilltop
- Exports: standard. Platform (5,5), margin 1. Island: small bare hill, radius ~6.5, lots of sky; **the wooden sign** `goal_sign` ribbon at layer 9 is a framework/goal presenter (E6): scene supplies a `sign_post` decor only at (hx+3.5=6, 0, -4) 2 cells high.
- Landmark: `windmill_far` bearing -25, distance 70 (needs distance for the reveal).
- Props: `grass_tuft` x5, `pebble` x4 on rim; no tall props beyond sign_post. Backdrop: `cloud_card` x8 at y 8-25 for a sense of height.
- Critters: `kite_bird` x1 circling at (15,10,-25) far.
- Sky: afternoon high clouds; sun (-45, -30) #FFEBCB energy 1.2; light breeze sways sign.
- MascotSpots: `pip_idle` (-3.4,0,3.4), `pip_climb_0..9` at (-3.4, 0.9*N, 3.4) one per layer (presenter moves Pip), `miller_laugh` backdrop (bearing -25, 60 away).
- Trees: `meadow_05_events`, `build_race`, `wobble`.
- Checks: camera must frame 12 layers; set `camera_elevation_override_deg = 0` and let framework frame. The sign must not be hidden by `sign_post`; keep post outside x range. Tall `pip_climb` spots stay on the platform-margin edge.

### 06 Flower Bed (8x8, h_play 8)
- Exports: standard. Platform (8,8), margin 1. Island: tidy garden bed with `wood_edging` frame at hx+1.5 (5.5 beyond centre = 1.5 cells outside platform) height 0.3. Soil flower-outline is a board overlay (E6): no scene work.
- Landmark: `windmill_mid` bearing -20, distance 30; Miller napping silhouette.
- Props (all outside clear zone |x|,|z| < 7): `flower_bush` x6 at (-8,0,-8),(8,0,-8),(-8,0,8),(8,0,8),(0,0,-8.5),(-8.5,0,0); `watering_can` x1 at (8.5,0,5); `vase_empty` x1 at (-8.5,0,5); `bee_hive`/skip; `pebble` x4. Flower colours restricted to desaturated pinks/yellows so as not to read as target cells.
- Critters: `bee` x3 around rim flowers (small, slow, backdrop-ish >=8 cells).
- Sky: late afternoon warm and still; sun (-25, 250) #FFD9A8 energy 1.0; ambient #C9B8D0; fog off.
- MascotSpots: `pip_idle` (-6.5,0,6.5), `pip_water` (7.8,0,4.2).
- Trees: `meadow_06_events`, `fill_shape`, `sprouts`.
- Checks: 8x8 board nearly fills the island; confirm the target overlay colour is distinct from soil and bed flowers. Flower bushes <=1 cell tall at corners only.

### 07 Hide & Seek (6x6, h_play 10) - foggy hollow
- Exports: standard (`view.occlusion_mode` default fade). Platform (6,6), margin 1. Island: damp dip: `moss_bank` ring rising 0 -> 1.5 cells from radius 7 to 10; board floor flat.
- Landmark: `windmill_mid` hidden: sail silhouette only + `chimney_puff` mist, bearing 30, distance 26, fog-faded (distance fog).
- Props: `moss_clump` x5, `stump` x1 at (8,0,-6) (owl), `dew_droplet` clusters x4 on moss (small), `pebble` x3. Rim fog banks (`fog_bank` x5, soft sprites) at radius 8-10, y 0-1.2, drift slow; presenter E2 puffs them on clears.
- Critters: `owl` half-asleep on stump (8,0,-6) -> (8,1,-6).
- Sky: dawn fog. top #A9B2D6, horizon #E9E4DA; sun (-12, 100) #FFDDB0 energy 0.7; Environment fog: density 0.012, colour #DDE0E8, **start beyond 14 cells so the board is not fogged** (the stack's fade is the twist, not scene fog).
- MascotSpots: `pip_idle` (-4.4,0,4.4) ears-only, `pip_pop`.
- Trees: `meadow_07_events`, `fog`, `fog_ghost`.
- Checks: fog density must NOT grey out the board or compete with the fade twist; fog_bank sprites outside the clear zone (>=hx+4). Moss banks low (<1.5), outside all four corner views' board lines.

### 08 Dewdrop (5x5, h_play 8)
- Exports: standard. Platform (5,5), margin 1. Island: small glittering lawn radius ~7; dew shader sparkles on turf.
- Landmark: `windmill_mid` silhouette against low sun at bearing 0 (-z), distance 28; `flour_drift` particles from door.
- Props: `snail` x3 on rim with trails at (-6,0,3),(6.5,0,-3),(-5,0,-6.5); `daisy_clump` x4; `dewdrop_big` x1 at (-4,0,4.5) (Pip stuck). `grass_tuft` x6.
- Critters: snails as above.
- Sky: sunrise. DirectionalLight3D starts pitch -8, yaw 180 (low, behind, back-lit), presenter rises it to -45 over the level; colours #FFC27A -> #FFF0D0, energy 0.8 -> 1.2. Horizon #F6C99A.
- MascotSpots: `pip_stuck` (-4,0,4.5), `pip_free` (-3.5,0,5.2).
- Trees: `meadow_08_events` (sun rise echo, Pip skit), `sticky_landing`.
- Checks: low sun behind the board + backlit rim glare: the mill silhouette must not wash out blocks; add a fill light (energy 0.4) from front. Dew sparkle only on the rim, never inside the clear zone.

### 09 Topsy-Turvy (6x6, h_play 10) - tree island
- Exports: standard. Platform (6,6), margin 1. Island: islet with `nesting_tree` (big, 5 cells tall) at the **back-left corner (-8, 0, -8)**; nests (`nest_empty` x4) in branches. Underside should be dressed as a "second top" if flip presentation (F2) shows it: add `Underside` roots + flat soil cap; decision pending.
- Landmark: `windmill_near` bearing 55, distance 14; `miller_lever` + rope to the islet (rope from the mill to (7.5,2,-3.5)). The lever pose is `miller_lever` marker.
- Props: tree as above; `fallen_leaf` x3; `daisy_clump` x3 on the front; **no egg props near board** (eggs are board content); `branch` pile x1 at (8,0,6.5).
- Critters: `mother_bird` fussing at nests (-8,3.5,-8); `sparrow` x2 backdrop.
- Sky: midday bright. sun (-70, 20) #FFF7E6 energy 1.3.
- MascotSpots: `pip_idle` (-4.4,0,4.4), `pip_hang` (6.8,-1.2,6.8) hanging from a root under the island, `miller_lever` (14*sin55=11.5, 3, -14*cos55=-8).
- Trees: `meadow_09_events`, `topsy_tumble`, `hatching_eggs`.
- Checks: tree is a large occluder: at (-8,-8) it sits on a diagonal 11 cells out; from yaw 6 (looking from -z) it is in front of the board: keep trunk radius <=1 and crown above y>5 so cells stay visible; verify all four views. Flip: camera unaffected by +/-y.

### 10 Meadow Mill (8x6, h_play 12) - boss
- Exports: standard; `camera_elevation_override_deg = 0`. Platform (8,6), margin 1. Island: the mill yard: packed-earth tiles around a mossy `mill_belt` surface on the board (belt surface is a presenter E4, floor y=0). Yard extends 6 cells past the board; mill at +x edge.
- Landmark: `windmill_near` **in-scene**: base at (hx+7 = 11, 0, 0), roof height 9, facing -x. Three sails (`sail_1..3`) boss health: presenter on `layers_cleared`; Miller on roof; `shutter`, `giant_lever` at (11,0,3.5).
- Props: `flour_sack` x4 at corners of the yard **outside the clear zone**: (-8,0,-6.5),(-8,0,6.5),(8.5,0,-6.5),(8.5,0,6.5); `crate_decor` x2; `cart` x1 at (-9,0,0); `pebble` x3. Hidden: `miller_blanket` tiny on roof (seen from high snaps).
- Critters: `sparrow` x4 on sacks (scatter on flip); `flour_puff` from door on belt shift.
- Sky: afternoon turning golden. sun (-35, 120) #FFE3B0 -> #FFC77A on win; ambient #C9C2D8; slight warm fog #EAD8B8 density 0.004 past 16 cells.
- MascotSpots: `miller_roof` (11,9,0), `miller_lever` (11,0,3.5), `miller_bonk` (5.5,0,0), `pip_blanket` (-4.8,0,-3.8).
- Trees: `meadow_10_events`, `mill_belt`, `gust`, `topsy_tumble`.
- Checks: **the mill (9 high) is on the +x side**: from yaw 3 (east view) it is directly behind the board: fine (backdrop). From yaw 9 (west view) it is in front of... no: it is behind the camera. From yaw 0/6 it sits to the side. Verify the sails do not cross into the board's sight line at yaw 6. Flour puffs and gusts are the only near-board motion: keep sparrow scatter to flip events only. Open: dressed underside (F2).

### B Picnic Puzzle (4x4, h_play 6, spec only)
- Exports: standard (`meadow_bonus`; JSON deferred). Platform (4,4), margin 1. Island: tiny islet under a `picnic_cloth` (chequered, flat, y 0.02); the 4x4 board is the open `hamper`: `hamper_rim` basket edge 0.4 high around the margin, beyond the clear zone? The rim IS the margin edge (x,z = +/-3). Island radius ~6.
- Landmark: `windmill_mid` bearing 10, distance 32.
- Props: `plate` x2, `fork` x2, `sandwich_crumbs` x5 at rim >=hx+3=5; `thermos` x1.
- Critters: `ant_line` presenter along rim path (radius 5.5, toward cloth) = the visible clock (level timer presenter, not ambient). `ant_scout` marker.
- Sky: picnic noon. sun (-75, 0) energy 1.3.
- MascotSpots: `pip_lid` (-2.8,0,2.8), `ant_scout` (5.5,0,0).
- Trees: `meadow_bonus_events`, `fill_shape`.
- Checks: cloth checker pattern must be low-contrast (<10% value difference) or it competes with block colours; keep the board floor plain.

## 3. Cross-level concerns for the caller

1. The brief said "8x8 all levels" but the handoff gives per-level sizes; sheets follow the handoff.
2. Stand-in manifest missing; role names only.
3. Open decisions that change 09/10 scene content: flip presentation (world-and-scenes F2) and the 10 phase-timing C1.
4. Mill distances (bearing/distance) per level: 01 8/60, 02 0/55 (window), 03 -70/38, 04 15/34, 05 -25/70, 06 -20/30, 07 30/26 (fog), 08 0/28, 09 55/14, 10 in-scene at +x 11, bonus 10/32. The ordering is monotonic closer except 05 (far, by design for the reveal) and 08 (mid-far).
