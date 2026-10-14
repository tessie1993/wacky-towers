# L01 Meadow 01 "Stump Day": Art Scene Brief r2 (Giant Tree Stump)

Status: DRAFT r2 for user approval. Author: art-director. Date 2026-10-14.
Supersedes r1 (height ring goal). Follows design/levels/campaign/l01_meadow_01.md r2 plus "User decisions (round 3)".
Style guide (NOT a layout to copy): assets/art/reference/ (biome_screens_ref.jpg, party_biome_islands_ref.jpg, biome_block_materials_ref.png, title_screen_ref.png). The references set style and finish only: painterly, chunky, saturated, warm key with cool shadow, rounded bevels. They never dictate what is in this scene or where it stands.
Rule: the level decides the art. Every scene element below is derived from design/levels/campaign/l01_meadow_01.md and the story beat (section 0 maps each element to its source). Level 1 is campaign, single player.
Bar: 9.7/10 or higher from each of 3 blind art experts. No beige or parchment anywhere (scene or HUD).

What changed from r1:
- The goal is "clear 3 layers before 2:00". The glowing height ring is gone. Section 6 is a layer-clear sweep, three tree rings that turn green, a rush to the rim and the bell.
- Two full-height obstacle walls frame a 4-wide lane: tangled ROOTS (left) and stacked mossy STONES (right). They are the hero objects (section 3b).
- A themed 2:00 timer, designed in section 9b: the Sundial Medallion.
- Composition, asset table, pipeline and acceptance are redone around the real layout and pixel budget.

User decisions carried in: giant stump IS the board, round 8x8 with cut corners, minimal HUD, dawn, Wizard and Ada present, timer has a "fitting theme".

Naming note: the asset library is BlenderKit (blenderkit.com), not "BlendKit".
Source honesty: PolyHaven ids were confirmed from polyhaven.com asset pages by web search (id exists, CC0, triangle count). The /files/<id> download lists were not fetched. The BlenderKit API was not queried. BlenderKit ids, uuids and per-asset licences must be recorded by hand from the add-on.

## 0. Where each element comes from (level decides the art)

| Scene element | Derived from |
|---|---|
| Giant stump, rings, round rim | User scene decision "Giant tree stump"; board "Round" |
| 52-cell mask, 4x8 lane, 8 layers | Level spec section 4 |
| Root wall left, stone wall right, full height | Level spec section 4 and user round-3 decision |
| Three lit tree rings, sweep, bell, bell post | Level spec sections 3, 6, 7 (ring of light, rings 1-3, `bell_ring`) |
| Wizard on his cloud, hat brim, Wrong Sack, spoon gag | Level spec sections 3 and 7 (blocks tumble from the hat brim) |
| Ada | Level spec cast and poses (cheer) |
| Floating meadow island with grass, wildflowers, rocks | User scene decision; end beat "grass greens, flowers open" |
| Distant islands, cottage, chimney smoke, waterfall | User scene decision; level spec sections 6 and 7 (chimney at Warm, waterfall sparkle) |
| Dawn light | Level spec (Hearth Stump, dawn) |
| Sundial Medallion timer | User round-3 decision "fitting theme"; 2:00 `time_limit_ms` |
| Plaque, 3 ring pips, NEXT, Hum meter, pause | Level spec section 9 (Minimal HUD) |

Nothing else is added. Items that were in earlier drafts and are not in the spec (fungus shelves, mushroom groups, crystals, a window that brightens, a sky warm-up) are removed.

## 1. Mood and palette

Feeling: a calm, proud morning. Warm, bright, chunky, and a little magical.

| Role | Hex | Use |
|---|---|---|
| Dawn key light | #FFC98A | one DirectionalLight3D, energy about 1.3 |
| Key direction | azimuth 300 deg (upper left, behind the camera's left shoulder), elevation 28 deg | long soft shadows fall right and toward the camera |
| Shadow (cool, never black) | #5B4A8A | ramp shadow stop, AO tint, cast shadow colour |
| Fill / sky bounce | #8FC4F2 | ambient, weight 0.35 |
| Rim (backlight) | #FFE7B8 | fresnel rim on the stump edge, walls and characters |
| Sky top to horizon | #6FB4EE to #FFD9B0 | peach at the horizon, not grey |
| Sun disc / glow | #FFE9A8 | low behind the left distant island |
| Lane floor pad (lit) | #E8B873 | the 32 playable cells, brightest large area |
| Stump wood mid / rings | #B87A3C, ring grooves #8E5A2E | apron and lane rings |
| Cell grooves | #5A3A22 | between lane pads |
| Stump bark | #7A4A2A, shadow #4A2E3E | skirt |
| Root wall (hero) | lit #A8693A, mid #7A4A2A, shadow #4A2E3E, burl accent #C98A4E | left wall |
| Stone wall (hero) | lit #A7A2B0, mid #8A84A0, shadow #6E6490, lichen #C7BFD6 | right wall |
| Wall moss (muted on purpose) | #6E9A45 lit, #3E5E3A shadow | max 25% of a wall's surface |
| Stump moss | #5FB34A, shadow #2F6B4A | skirt and rim only |
| Grass lip | #7CCB3F lit, #3E9A4A shadow | island |
| Island soil / strata | #8A5A34 / #A47848 / underside #4A3A5E | |
| Flowers | #FF7AB6, #FFD94A, #FFFFFF, #6C8CFF | max 4 hues |
| Tree-ring win glow | #4CFF8A core, bloom #B8FFD0 | rings 1-3 and end beat |
| Layer-clear sweep | #FFF6C8 core, #FFD36B edge | sweeping ring of light |
| Timer remaining / elapsed | gold #FFD36B / violet #3E2F6B | Sundial Medallion |

Shadow description: shadows are cool violet-blue (#5B4A8A), semi-transparent, soft at the edges. Never grey or black. Lit edges are cream. The terminator is a soft wrap (half-Lambert).

Shadow rule for the walls (readability beats realism): the walls and the stump do NOT cast the key shadow onto the lane. A wall 8 cells tall would shade the whole lane at a 28 deg sun. Instead the lane gets a baked soft violet AO gradient 0.8 cell wide at each wall base (max 18% darker). Blocks and characters do cast soft key shadows. The technical-artist confirms the exact light layer set-up.

Value rule: the lane floor and the blocks are the lightest, most saturated things. The walls sit at mid-low value and low saturation. The world sits 15-25% below the board in saturation. At most 4 hues outside the blocks.

## 2. Composition (720x1280 portrait, camera 42 deg elevation, near-isometric, FOV about 30)

Camera: elevation 42 deg, yaw 0 (board axis-aligned), the lane runs up the screen. Pixel scale at the stump: 1 cell = about 58 px wide, one layer = about 43 px tall on screen, so the 8 playable layers are about 345 px tall and the 12-layer spawn zone about 517 px. These are planning numbers; re-measure from the first render.

Geometry (cells): stump top disc 10.4 across (r 5.2); board 8x8 (52 mask cells) inside it; lane = x 2..5 (4 wide, 32 cells); left wall = roots on x 0-1 (10 cells); right wall = stones on x 6-7 (10 cells); mirror rows as in the level spec. The apron (bare wood outside the board) is 1.2 cells at the lane ends and 1.2 beyond the walls, and at least 0.7 at the cut corners.

Zones (px from the top, 1280 total):
- 0 to 154 (12%): HUD top row: pause (left), goal plaque (centre), NEXT (right). Sky only behind it.
- 150 to 400 (12-31%): spawn clearance (to about y 227) and the top of the walls (about y 399). Wizard on his cloud, cottage island, distant islets.
- 400 to 700: the walls, stack and lane rise through here. Background islets peek out left and right of the walls only.
- 697 to 1100 (54-86%): the stump disc (back edge to front edge). Lane floor centre of mass around y 900.
- 1126 to 1280 (88-100%): HUD bottom row: Hearth Hum meter (left), Sundial Medallion (centre).

Clear zones: no scene detail with contrast above the apron level in the HUD rows; the area directly behind the plaque and medallion is calm sky or soft violet underside.

ASCII thumbnail (not to scale; W = Wizard on cloud, A = Ada):

    +----------------------------------+
    | (II)   [ GOAL PLAQUE o o o ]  [N]|  pause / plaque + 3 ring pips / NEXT
    |  _                    /\_/\      |
    | (W)~cloud~  spawn      [cottage] |  Wizard hat brim by the lane top
    |  Wrong Sack  zone       ||waterfall
    | .o far     |  .  |             .o |  distant islets
    |  ROOT |    | lane |    | STONE    |
    |  WALL |    |  4   |    | WALL     |  full-height walls, lane between
    |  (10  |    | wide |    | (10      |
    |  cells|    |      |    | cells)   |
    |  ,---'     |      |     '---.     |
    |  |   stump top, apron rings  |    |
    |  '--.______________________.-'  A |  Ada front-right on the grass
    |  [HUM flame]   (SUNDIAL)          |  HUD bottom
    +----------------------------------+

Characters:
- The Wizard (purple robe, star hat; see assets/art/reference/wizard_turnaround_ref.png) floats on his cloud at upper left, over the back of the left wall, hat brim at about x 236, y 232. Blocks tumble from the brim into the lane. His Wrong Sack hangs from the cloud. He must never overlap the lane's spawn columns or the plaque.
- Ada stands on the grass lip at front right (about x 560-650, y 1000-1100), clear of the lane, the apron and the bottom HUD row. Her cheer pose points at the stump.
- Silhouettes must read at 64 px.

Backdrop placement (r2): the cottage island upper right (x 500-700, y 180-330), the waterfall dropping off its left edge, 2 plain distant islets at the far left (x 0-130, y 320-410) and far right (x 600-720, y 410-480), clouds in 2-3 layers. Nothing in the middle column between y 150 and 400, so falling pieces keep a clean, bright backdrop.

## 3. The stump in detail

- Size: top disc diameter 10.4 cells (r 5.2). Height 2.2 cells visible above the grass, 2.5 with roots.
- Board mask (fixed by the level spec): rows `..####..`, `.######.`, `########` x4 (rows 2-5), `.######.`, `..####..`. 52 cells; 20 are wall cells; 32 are lane cells. Cut cells are plain ring wood.
- Round edge: rounded lip (bevel 8% of the diameter, 3 segments), cream edge glint on the lit side, darker bark skirt below, faint wavy hand-felled cut line (amplitude 0.05 cell).
- Rings: 14-18 concentric rings painted into the albedo (512x512, over bark_brown_02 end-grain colours), ring contrast 8-10% in value. The OUTER THREE rings (r 4.3, 4.7 and 5.05) are authored as separate mask channels because they are the win-glow rings (section 6). Their grooves are 0.07 cell wide and visible all the way round the apron, including past the walls.
- Lane cell treatment (grid must read on the rings): the 32 lane cells are raised pads (0.03 cell high, 3-segment bevel), 12% lighter than the wood (#E8B873), separated by 0.06-cell grooves (#5A3A22). Every second pad is 3% lighter so the pattern stays calm under placed blocks. Pads exist only in the lane. The lane is the brightest, flattest area.
- Wall bases: the two walls grow out of the wood. A 0.08-cell dark violet contact groove at each wall base keeps them separate from the lane pads.
- Moss: three clumps on the bark skirt and one thin lip at the rim, never on the lane.
- Bark: 6 large vertical ridges per quarter, lit side and violet shadow side.
- Roots below: 5-7 thick roots flare out of the bark and drop over the island edge (no root thinner than 6 px at 720 px).
- Collision: a simple cylinder `-col` for the stump top only. Wall and board logic are not physics.

## 3b. The two walls (HERO ART)

These are the most important new objects. They carry the level's identity and its only obstacles.

Layout: left wall = cells (1,1), (0..1, 2..5), (1,6) = 10 cells. Right wall = (6,1), (6..7, 2..5), (6,6) = 10 cells. Each is a full-height column mass of 8 layers (h_play = 8). Visual height 8.4 cells with a rounded crown. If the level designer's open point is confirmed (rocks reach the spawn clearance, y up to 11), add an `ext` module that stacks the same material up to 12 layers. Build the crown and the ext module as separate meshes.

Design goals, in order:
1. Read as SOLID and PERMANENT at 64 px.
2. Read as NOT-A-BLOCK at 64 px, and clearly differ from every player block.
3. Frame the lane like a gate. Be handsome (the first frame of the game).

How each wall differs from a player block (all five must hold):
| Cue | Player block | Wall |
|---|---|---|
| Shape | 1-cell bevelled cubes, tetromino outlines, visible cell edges | One continuous mass, 2 cells wide and 8+ tall, irregular outline, NO cell grid |
| Colour | Candy saturation: green, pink, yellow, blue | Earth and stone: warm brown (roots), cool grey-lilac (stones). Never green, pink, yellow or blue except muted moss |
| Surface | Smooth gloss, bright edge glint, painted gradient | Matte, rough, carved ridges and cracks, no edge glint |
| Outline | Thin tinted inverted-hull outline | None. Outline is reserved for pieces and characters |
| Light | Subtle inner warmth, brightest values in the frame | Mid-low value (L 35-55%), takes light, gives none |
Also: they never wobble, glow, pop or move. A clear sweep only brushes them with a thin warm rim flash.

ROOT WALL (left): "tangled roots"
- Concept: ancient roots that grew over the cut stump and braided into a living wall. 5-7 thick main roots (0.5-0.9 cell) twist up together in 2-3 big S-curves, with two knotted burls (about layers 2-3 and 6), a few chunky side roots that dive back into the wood, and a leafy sprout crown at the top.
- Silhouette at 64 px: a slender, wavy, braided column with negative-space notches. It must NOT look like a stack of cubes: roots run diagonally, never along the cell grid.
- Surface: simplified bark ridges (6-8 per root), a painted lit side (#A8693A) and violet shadow side (#4A2E3E), muted moss on the top-facing surfaces (<=25%).
- Permanence cues: roots visibly enter the wood, the grain flows around the base, a lichen patch. Only the crown leaves sway (cosmetic, amplitude small). The body is static.
- Source and stylisation (PolyHaven CC0): take the exposed-root geometry from tree_stump_01 and tree_stump_02 as the root-shape library (the lower third of the scans). Retopo in Blender: thicken x1.5, delete rootlets under 6 px, weld into one column mass (voxel remesh 0.04 then quad remesh), Bevel 8-10% plus Weighted Normal, bake AO to COLOR_0.R tinted violet, paint over bark_brown_02 at 512 px posterised to 6-8 tones, saturation +20%. Budget 5,500 tris.
- Inset: nothing crosses the lane boundary at x = 2.0. Keep the inner face at x <= 1.96 (0.04 cell) so a locked block never visually intersects.

STONE WALL (right): "stacked mossy stones"
- Concept: a dry-stone cairn of 5-6 big rounded boulders, the biggest at the base, stacked and slightly off-centre, with dark gaps between them (violet, not black). A flat capstone with a grass tuft and one flower sits on top. Convex bulges, 10% bevel.
- Silhouette at 64 px: a lumpy, bulging pile, wider in the middle. A different silhouette from the roots (roots are slender and wavy, stones are bulky and convex), so the two sides stay distinct for colour-blind players too.
- Surface: cool grey-lilac stone with big facets (6-12 per boulder), cracks on the capstone, muted moss caps (<=25%), lichen spots (#C7BFD6, not beige).
- Permanence cues: dark contact gaps with baked AO, moss fuzz, small chips and a settled tilt, ground-hugging base boulder half buried in the wood.
- Source and stylisation (PolyHaven CC0): rock_moss_set_01 (six mossy rocks) as the stone kit, boulder_01 (124k tris) decimated for the base boulder and capstone, moss_01 for the moss shells. Pick 4-5 rocks, rigid-body settle them in Blender into a cairn, decimate each to 600-900 tris, merge into one mesh, remove detail under 6 px, Bevel 10% plus Weighted Normal, bake AO and curvature (R, G), paint over mossy_rock at 512 px posterised, saturation +15%. Budget 4,500 tris.
- Inset: inner face x >= 6.04.

Hero process gate (before texturing): present the wall pair next to the 4 block shapes, all rendered at 64 px and at 720x1280, to the creative-director. Walls that fail the five-cue table go back to silhouette work.

Optional per-column skin param (NEW-5 in the level spec): the walls are authored as one mesh per side. If the engine insists on per-column skins, split each wall at the 10 cell columns but keep the sculpt seamless across the cut.

## 4. The island

- Shape: tapered rock mass, bottom about 45% of the top width. 2-3 big strata bands (#A47848, #8A5A34, then #4A3A5E), 3-5 overhang chunks, 4-8 hanging roots. Chunky readable silhouette.
- Top: rounded grass lip overhanging the strata by 8%, painted vertex-colour gradient (#7CCB3F to #3E9A4A).
- Dressing: tuft clumps (5-7 cards plus 3-4 flowers), 3 rock sizes (150-400 tris), 2 ferns, 2 shrubs. Flowers are big (about 12 px), few, clustered at the front corners.
- Density rule: no dressing within 0.3 cells of any playable cell (the 32 lane cells). Wall base moss and root tendrils also keep 0.3 cells from the lane edge, and the wall meshes keep the 0.04-cell inset. Scatter masks are generated from the lane plus a 0.3 cell margin. A validator script checks every instance centre and radius and fails the export on a violation.
- Rest area: a calm, low-contrast grass ring around the stump. Detail concentrates at the front corners and the island rim.
- Island top diameter about 15 cells (wider than the frame, so only the front corners and lip show); Ada stands on the front right.
- Bell post: a short wooden post with a bronze bell on the stump apron at the back right (set piece `hearth_stump`, action `bell_ring`), just outside the board.

## 5. Background

- Sky: 3-stop gradient (#6FB4EE, #BFE3FF, #FFD9B0 at the horizon). HDRI spruit_sunrise at 2K for reflections and ambient only. Visible sky is the painted gradient plus cards.- Clouds: 6-8 chunky painted cloud cards in 2-3 layers, warm lit side, violet underside, slow parallax. No grey. The Wizard's cloud is a hero cloud, same style.
- Distant islands: 2 plain islets plus the cottage island, each 25-40% of the main island, 300-800 tris, varied landmarks, aerial perspective by hue (lighter, cooler, 30% lower contrast, same chroma).
- Cottage island (upper right): custom cottage 800-1500 tris, overhanging red-orange roof (#E0603A), warm window (#FFD27A), chimney with a slim smoke puff. The chimney starts smoking at Warm (2 clears), per the level spec.
- Waterfall: a thin misty semi-transparent ribbon off the cottage island's left edge, scrolling shader, soft spray. Not an opaque bar.
- Sun: low behind the left islet with a soft glow card.

## 6. Layer-clear flash, tree rings and the end beat

The goal is clear 3 layers in 2:00. The visuals are the player's reward loop. Three clears = three tree rings lit green = bell.

The three win rings: the outer three painted rings of the stump top (r 4.3 inner, 4.7 middle, 5.05 rim), authored as the R, G and B channels of one 1024 ring-mask texture. They are visible around the whole apron, including past the walls, so they stay readable even when the lane is full of blocks. Their grooves are lit by emission, never by extra geometry. The plaque's 3 ring pips (concentric-ring icons) light with them.

Layer-clear flash (clear 1 and 2, about 1.2 s):
1. The last lane cell fills. The cleared layer glows white-gold for 0.15 s.
2. A ring of light sweeps the layer: a flat additive annulus in the layer's plane (core #FFF6C8, edge #FFD36B, 0.4 cell thick) expands from the lane centre to r 5.2 over 0.6 s. Blocks in that layer pop into sparkles as it passes (staggered by distance). It crosses the walls and brushes them with a thin warm rim flash only. The walls do not move.
3. Blocks above settle down one layer with a soft bounce.
4. The ring arrives at the apron and lights tree ring k green: clear 1 = inner (r 4.3), clear 2 = middle (r 4.7). The green flows clockwise from the arrival point over 0.5 s, then settles at 60% emission and stays on for the rest of the level.
5. The Hearth Hum meter gains one third and the matching plaque ring pip lights green at the same moment.

Third clear and end beat (about 4 s):
1. The sweep does not stop at the lane edge. It races over the walls and the apron to the rim (0.45 s, faster than clears 1 and 2).
2. Ring 3 (the rim) lights green with a flash. All three rings pulse green outward once (0.5 s).
3. The whole stump glows green: ring grooves, lane grooves, bark skirt veins, moss, and the wall base veins (emission mask only). Walls stay solid; only their moss and root-tip leaves brighten.
4. The bell swings 3-4 times (2.5 s). Audio (bell, chord) is the audio-director's domain; the visual shows motion lines and a ring of bloom.
5. The grass greens, wildflowers open, the chimney puffs, the waterfall sparkles (as in the level spec).
6. Wizard pose "point" at the tower, Ada "cheer". The result card appears 3 s after the bell.

Soft retry beat (timer ran out once): the Wizard yawns, the Sundial Medallion rewinds (section 9b), and the scene stays as it is.

Wobble-giggle on hanging blocks is cosmetic and belongs to the block asset, not the scene.

## 7. Asset list

| Element | Source | Licence | Stylisation steps | Tri budget |
|---|---|---|---|---|
| Stump body, bark, roots below | PolyHaven tree_stump_01 / tree_stump_02 as reference; custom retopo | CC0 | Retopo to 6 big ridges, bevel 8%, AO to vertex R, paint over bark_brown_02 at 512 px | 6,000 |
| Stump top disc (rings, lane pads, apron) | custom | own work | Hand-painted ring albedo, 3 ring-mask channels, 32 lane pads and grooves | 3,500 |
| Root wall (hero, left) | PolyHaven tree_stump_01 / tree_stump_02 roots as shape library; custom sculpt | CC0 | Thicken x1.5, remesh and weld, bevel 8-10%, bake AO, paint 512 px | 5,500 |
| Stone wall (hero, right) | PolyHaven rock_moss_set_01, boulder_01, mossy_rock (texture) | CC0 | Pick 4-5 rocks, settle into a cairn, decimate 600-900 each, bevel 10%, paint 512 px | 4,500 |
| Wall crown and ext module | custom | own work | Crown caps (one per side) and a 4-layer ext module if clearance walls are confirmed | 800 + 1,500 |
| Bark texture | PolyHaven bark_brown_02 (alt tree_bark_03) | CC0 | Downsample to 512, posterise, saturation +25% | texture |
| Moss shells | PolyHaven moss_01 as reference; custom | CC0 | Rounded lobed shells, muted green on walls | 500 |
| Island rock mass | custom sculpt; ref namaqualand_boulders_01 | CC0 ref | 2-3 strata bands, decimate, vertex colour bake | 6,000 |
| Island textures | PolyHaven aerial_grass_rock, forrest_ground_01 (misspelled slug on the site) | CC0 | 512 px, painted, saturation +20% | texture |
| Island rocks (3 sizes) | PolyHaven rock_moss_set_01, boulder_01 | CC0 | Decimate to 150-400 tris, chunky facets | 3 x 300 |
| Grass tufts | PolyHaven grass_medium_01 as reference; custom cards | CC0 | 5-7 card clumps, painted gradient, MultiMesh | 400 per clump |
| Flowers | PolyHaven dandelion_01 as reference; custom | CC0 | Chunky 5-petal heads, 4 hues | 150 each |
| Ferns / shrubs | PolyHaven fern_02, shrub_04, shrub_02 | CC0 | Card-based, painted | 300 each |
| Cottage | custom (no PolyHaven cottage found; BlenderKit candidate id TBD) | own work | 3 volumes, bevel 5%, warm window | 1,500 |
| Waterfall | custom | own work | Ribbon mesh, scrolling shader | 200 |
| Distant islets (2) | custom | own work | Tint, reduced contrast | 2 x 500 |
| Clouds incl. Wizard's cloud | custom painted cards | own work | Painted, sorted alpha | 10 quads |
| Bell post and bell | custom | own work | Bronze #D9A441, chunky bevel | 600 |
| Wrong Sack | custom | own work | Soft cloth, patched | 300 |
| Layer-clear sweep ring | custom VFX | own work | Additive annulus plus shader, sparkle particles | 2 draws |
| Tree-ring emission mask | custom texture | own work | 1024 RGB mask (R/G/B = rings 1/2/3), green glow in shader | texture |
| Dawn HDRI | PolyHaven spruit_sunrise (alts bloem_field_sunrise, qwantani_dawn_puresky, spruit_dawn) | CC0 | 2K, ambient and reflections only | texture |
| Sundial Medallion (HUD) | custom UI kit | own work | Rendered in Blender with the world's light rig: `ui_timer_sundial_rim_large.png`, `ui_timer_sundial_face_large.png`, `ui_timer_sundial_shadow_large.png` | UI |
| Wizard, Ada | existing characters (wizard_turnaround_ref.png) | project | Same toon ramp | 5,000 each |

Each BlenderKit asset used must have its id, uuid, author and licence recorded in this table before import. BlenderKit licences are per asset (Royalty Free or CC0), so check each one.

## 8. Pipeline

Blender tools: Poly Haven add-on (asset browser), BlenderKit add-on (free assets usable without login; direct REST download probably needs an account token, unconfirmed), Geometry Nodes for scatter (grass_medium_01 node group as base), Bevel plus Weighted Normal, Decimate, Voxel and Quad Remesh, rigid-body settle for the stone cairn. Geo-Scatter (paid) is not assumed.

Stylisation conversion for every PolyHaven or BlenderKit source:
1. Decimate or retopo to budget, keep silhouettes, remove detail finer than 6 px at 720 px.
2. Bevel 6-10% with weighted normals.
3. Replace photoreal PBR with a 512 px painted albedo (posterise to 6-8 tones, saturation +15-25%, warm lights, violet shadows). Drop normal maps except on bark.
4. Bake AO to COLOR_0.R (tinted violet), curvature to G, height gradient to B, outline weight to A (walls: A = 0, no outline).
5. In Godot: toon ramp shader (wrap lighting, 3-stop ramp), rim light, thin inverted-hull outline on blocks, characters and the stump only (not the walls).

GLB export (Y up, glTF Binary):
- env_stump_board_large.glb: stump, lane pads, ring mask UVs, bell post. `-col` cylinder.
- env_wall_roots_meadow_large.glb and env_wall_stones_meadow_large.glb: the hero walls with crown and ext module as separate nodes. No collision (board logic owns it). Origin at the stump centre so the wall cell footprints match the board grid.
- env_island_meadow_large.glb: island, grass, dressing.
- env_backdrop_meadow_large.glb: islets, cottage island, waterfall, clouds.
- Settings: apply modifiers, tangents off unless normal-mapped, vertex colours on, materials as export, no cameras or lights, Draco off, images PNG or WebP.

Godot import:
- `-col` suffix for the stump collision.
- Mipmaps on. Mobile VRAM compression ETC2/ASTC; normal maps in Normal Map mode; painted albedo VRAM Compressed sRGB; UI textures and the sundial layers stay lossless.
- Addons to consider (all UNCONFIRMED on 4.7.2): ProtonScatter (no stated tested version), Terrain3D (documented 4.4-4.6; not needed, skip). Sky, water, toon and sweep-ring shaders are plain `.gdshader` files, no addon. Verify each addon on 4.7.2 in a throwaway project.
- Renderer features (glow, fog, depth texture under Compatibility vs Mobile) are still unverified (flag V in art-research-2026-10-14.md). The green end glow needs glow or a bloom card fallback.

Validator (build step): wall meshes must not cross x = 2.0 or x = 6.0 for any y <= 8; scatter instances must stay 0.3 cells from lane cells.

Budgets (mobile, whole frame):
- Visible triangles at most 110,000 (stump 9.5k, walls 10k plus crowns 1.6k, island 6k, dressing 14k, backdrop 12k, characters 10k, bell, sack and effects 6k, margin).
- Draw calls at most 120.
- Texture memory at most 40 MB VRAM compressed (stump atlas 1024, wall atlas 1024, island atlas 1024, dressing 512, cards 1024 x2, ring mask 1024, characters 512 x2, HUD).
- Lights: one directional plus ambient; key shadows only from blocks, characters and the bell post; one cascade.

## 9. HUD placement and the timer

### 9a. Minimal HUD layout (720x1280)

| Element | Position | Size | Notes |
|---|---|---|---|
| Pause | top-left | 64 px circle | Round, standard |
| Goal plaque | top centre | about 330 x 90 px | Purple wood, gold plate, cream caps. Headline "Plant the Hearth Tower's first course"; objective line for the first 4 s; three concentric-ring pips along the bottom edge (they light green with the tree rings). No parchment. |
| NEXT | top-right | 100 px round frame | One piece drawn as the real block |
| Hearth Hum meter | bottom-left | 104 px medallion | Flame glyph with a three-note ring. No number |
| Sundial Medallion (timer) | bottom-centre | 120 px | See below; twin frame to the Hum medallion |

Why the timer sits bottom-centre: thumbs rest on the lower corners and cover them in portrait; the centre stays visible, directly under the stump the player is watching.

### 9b. The timer: recommended design

RECOMMENDED: the Sundial Medallion (a carved wooden sundial whose shadow sweeps).
- Look: a round plate of purple-wood frame with a thin gold rim (same carved language as the HUD kit). The face is stump wood. A small gold gnomon topped with a tiny star (the Wizard's star-hat motif) stands in the centre. Twelve carved ticks (one per 10 s) with the four quarter marks (every 30 s) larger.
- How it reads: the face is a pie. The REMAINING time is warm GOLD (#FFD36B). The ELAPSED time is a cool VIOLET shadow (#3E2F6B) cast by the gnomon. The shadow is the clock hand: it starts at 12 o'clock with the whole face gold and sweeps clockwise, one full turn over 2:00 (3 deg per second). Time left is the amount of gold, readable in about 0.3 s without text.
- Value contrast gold vs violet is above 60 points, so it works for colour-blind players (the hand shape and the carved ticks are the non-colour cues).
- Last 30 s: the last gold quarter breathes gently (1 Hz glow, never red, never loud). Last 10 s: a large carved numeral (the seconds) fades in at the centre; the audio ticks are the audio-director's domain.
- Soft retry (+30 s once): the Wizard yawns, the shadow rewinds a quarter turn (90 deg) in 0.8 s with a sand-pour shimmer, and a small gold sand stud lights on the rim to show the extra time has been used. A second time-out loses.
- Grace and fairness: nothing changes in the first 30 s; the player never sees a grace countdown.
- Size: 120 px diameter, single player. The seconds numeral is at least 40 px.

ALTERNATIVE B: Hearth Candle. A carved wooden candlestick whose wax shrinks over 2:00, with a flame that flickers faster in the last 30 s. Best link to the Hearth story and the most linear read (a height bar). Risk: it is a second flame next to the Hearth Hum flame glyph (two flames confuse "progress" and "time").

ALTERNATIVE C: Sunrise over the Cottage. A painted sun disc climbs an arc in the sky behind the cottage; the sky shifts from peach to day blue. Most diegetic and prettiest. Risks: far from the stump, hard to read in 0.5 s, and it fights the cottage and waterfall for attention.

## 10. Acceptance criteria

Capture at 720x1280 in-engine, saved in production/qa/evidence/. The references are judged for style and finish only (painterly, chunky, saturated, warm key and cool shadow, bevel quality), never for layout or content.

1. Three blind art experts each score at least 9.7/10 on the start frame, a mid-play frame with 6-10 locked blocks, and the end beat. Pass bar is 9.7; no lower anchor applies.
2. The lane reads first: the 32 lane pads are the lightest, flattest, most saturated area and every cell is readable at arm's length on the ring wood.
3. Walls, 64 px test: render the two walls and the 4 block shapes at 64 px. In a 5-viewer 0.5 s test, every viewer identifies the walls as the permanent, not-a-block objects, and tells roots from stones. The wall mean saturation is at most 60% of the block mean, and the mean luminance difference is at least 20% (measured on the render).
4. Walls hold the five-cue table in section 3b: continuous mass, earth colours, matte surface, no outline, mid-low value. The wall pair passes the hero process gate before texturing.
5. No wall mesh crosses x = 2.0 or x = 6.0 below y = 8 (validator output attached). No dressing, moss or tendril sits within 0.3 cells of a lane cell.
6. Clear flash: frames at last-cell-fill, sweep mid-flight, arrival, and settled show the sweep ring, then the matching tree ring turning green (for clears 1, 2 and 3). The plaque pips and the Hum meter light in the same frames.
7. End beat: frames at the rim rush, the full stump green, and the bell mid-swing show the walls staying solid and in place, and the result card 3 s later.
8. Timer: in a 5-viewer 0.5 s test from a still capture, at least 4 of 5 state the time left to within one quarter. The retry rewind is captured in 3 frames.
9. HUD: pause top-left, plaque top-centre, NEXT top-right, Hum bottom-left, Sundial bottom-centre; nothing else HUD-like on the board; no beige or parchment.
10. Composition: the Wizard and his cloud do not overlap the lane or the plaque; Ada does not overlap the lane or the bottom HUD row; the middle column y 150-400 is clean sky.
11. No beige or parchment, no grey fog, shadows are violet, and the walls cast no key shadow onto the lane.
12. Budgets in section 8 are met, shown by a frame-stat capture on a mobile-class device.
13. All asset licences are CC0 or recorded; BlenderKit ids are filled in.

## 11. Decisions

| Decision | Status | Recommended default | Alternative |
|---|---|---|---|
| Corner-cut rule | RESOLVED by the level spec | The exact 52-cell mask in section 3 | none |
| Cottage source | pending user confirmation | Custom model | A BlenderKit pick (id TBD, licence to be checked) |
| Scatter tool | pending user confirmation | Blender Geometry Nodes | Geo-Scatter (paid) |
| Timer look | pending user confirmation | Sundial Medallion, bottom-centre | Hearth Candle, or Sunrise over the Cottage |
| Walls authored per side | pending technical-artist | One mesh per side (seamless sculpt) | Per-column skin (NEW-5) |
| Wall height | pending level designer / Godot master | 8 layers plus crown | 12 layers via the ext module if rocks may sit in the clearance zone |

## 12. Blocked / uncertain

- BlenderKit API not queried; ids and licences are to be recorded by hand from the add-on. API-key need for direct REST download is unconfirmed.
- Godot 4.7.2 support is unconfirmed for ProtonScatter and Terrain3D.
- No PolyHaven cottage or waterfall asset found.
- Pixel positions in section 2 are planning values from a 42 deg camera model, not a render. Re-measure on the first render.
- Whether walls need to reach the spawn clearance (y up to 11) is open in the level spec.
