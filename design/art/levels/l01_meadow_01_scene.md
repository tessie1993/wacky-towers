# L01 Meadow 01: Art Scene Brief (Giant Tree Stump)

Status: DRAFT for user approval. Author: art-director. Date 2026-10-14.
Targets: assets/art/reference/biome_screens_ref.jpg, party_biome_islands_ref.jpg, biome_block_materials_ref.png, title_screen_ref.png. Beat to beat: production/qa/evidence/art-critique-2026-10-14/v3_level_meadow.png.
Bar: 9.7/10 from the strict 3-expert panel. No beige or parchment anywhere.
User decisions: giant stump IS the board; round 8x8 with cut corners; minimal HUD; dawn; Wizard and Ada present.

Naming note: the asset library is BlenderKit (blenderkit.com), not "BlendKit".
Source honesty: PolyHaven ids below were confirmed from polyhaven.com asset pages via web search (id exists, CC0, triangle count). The /files/<id> download lists were not fetched. The BlenderKit API was not queried; BlenderKit asset ids, uuids and per-asset licences must be recorded by hand from the add-on.

## 1. Mood and palette

Feeling: a calm, proud morning. Warm, bright, chunky, and a little magical.

| Role | Hex | Use |
|---|---|---|
| Dawn key light | #FFC98A | one DirectionalLight3D, energy about 1.3 |
| Key direction | azimuth 300 deg (upper left, behind the camera's left shoulder), elevation 28 deg | long soft shadows fall right and toward the camera |
| Shadow (cool, never black) | #5B4A8A | ramp shadow stop, AO tint, cast shadow colour |
| Fill / sky bounce | #8FC4F2 | ambient, weight 0.35 |
| Rim (backlight) | #FFE7B8 | fresnel rim on the stump edge and the characters |
| Sky top to horizon | #6FB4EE to #FFD9B0 | peach at the horizon, not grey |
| Sun disc / glow | #FFE9A8 | low behind the distant islands, left |
| Stump wood lit | #D9A05B | board pads |
| Stump wood mid | #B87A3C | rings |
| Stump bark | #7A4A2A, shadow #4A2E3E | |
| Ring grooves | #8E5A2E | |
| Cell grooves / inlay | groove #5A3A22, pad #E8B873 | |
| Moss | #5FB34A, shadow #2F6B4A | |
| Grass lip | #7CCB3F lit, #3E9A4A shadow | |
| Island soil / strata | #8A5A34 / #A47848 / underside #4A3A5E | |
| Rocks | #A7A2B0 lit, #6E6490 shadow | |
| Flowers | #FF7AB6, #FFD94A, #FFFFFF, #6C8CFF | max 4 hues |
| Goal ring | #FFE27A core, #FFF6C8 inner | |
| Win glow | #4CFF8A, bloom #B8FFD0 | |

Shadow description: shadows are cool violet-blue (#5B4A8A), semi-transparent, and soft at the edges. Never grey or black. Violet reflected light also reads on the underside of leaves and rocks. Lit edges are cream. The terminator is a soft wrap (half-Lambert), not a hard cel band.

Value rule: the board is the lightest, most saturated thing in the frame. The world is mid-value with 15-25% lower saturation. At most 4 hues outside the board.

## 2. Composition (720x1280 portrait, camera 35-45 deg elevation, near-isometric, FOV about 30)

Camera: elevation 40 deg, yaw 0 (board axis-aligned), orthographic-feel perspective. Board centre at about 52% of the frame height.

Zones (fractions of frame height from the top):
- 0 to 12%: HUD top (goal plaque left/centre, pause right). Sky only behind it: clear of detail.
- 12 to 32%: background (distant islands, cottage island, waterfall, clouds).
- 32 to 80%: stump board, 8x8 centred. Board occupies about 86% of the frame width (about 620 px).
- 80 to 88%: foreground rim: grass lip, flowers, rocks, the Wizard and Ada flanking the stump.
- 88 to 100%: HUD bottom (NEXT and Hearth Hum meter). The island underside silhouette fades into soft violet here: keep it calm.

ASCII thumbnail (not to scale):

    +------------------------------+
    | [GOAL PLAQUE]        [PAUSE] |  HUD top, sky behind
    |   ~cloud~     ~cloud~        |
    |  .o(far isl)  [cottage isl]  |  background
    |               ||waterfall    |
    |       ,-- goal ring --,      |  glowing ring above stump
    |      /  .---------.    \     |
    |     |  /  8x8 board \   |    |  stump top = board
    |     |  \  (octagon) /   |    |
    |      \  '---------'    /     |
    |  (W)  rocks  ~~~  flowers (A)|  Wizard left, Ada right
    |  grass lip ======== roots v  |
    | [NEXT]        [HEARTH HUM]   |  HUD bottom
    +------------------------------+

Characters: the Wizard (purple robe, star hat; see assets/art/reference/wizard_turnaround_ref.png) stands front-left on the grass rim, facing the board, about 1.6 cells tall. Ada stands front-right, slightly lower and a little further forward, about 1.4 cells tall. Both stand on the island at least 0.5 cells from the board edge, and never overlap the NEXT/Meter HUD region or the goal ring. Their silhouettes must read at 64 px.

## 3. The stump in detail

- Size: top disc diameter 9.6 cells (outer rim 0.8 cells beyond the 8-cell board span). Height 2.2 cells visible above the grass, 2.5 including roots.
- Board mask: the 8x8 grid with corners cut. RECOMMENDED DEFAULT: the cut follows the level designer's mask. Placeholder until that exists: cells with |x|+|y| <= 5 (centre offsets in cells) give 52 cells and an octagon. The level data owns the mask. The art must hold for any mask inside radius 4.3 cells.
- Round edge: a rounded lip (bevel 8% of the diameter, 3 segments) with a bright cream edge glint on the lit side and a darker bark skirt below. A faint wavy cut line (low-frequency noise, amplitude 0.05 cell) makes it feel hand-felled.
- Ring top: the custom disc carries 14-18 concentric rings painted into the albedo (512x512, hand-painted over bark_brown_02 end-grain colours). Ring contrast is 8-10% in value, far below the cell lines. A radial crack or two sits in the outer ring only, never inside the cells.
- Cell treatment: each playable cell is a slightly raised pad (0.03 cell high, 3-segment bevel) with a groove 0.06 cells wide between pads, in #5A3A22. Pads are lighter (#E8B873) than the surrounding wood by about 12%, so cells read by value, not by lines. No hard checker. Every second pad is 3% lighter so the pattern stays calm for placed pieces. Cut (non-playable) corner cells are plain ring wood at ring contrast, with no pad and no groove.
- Moss: three clumps on the bark skirt and one thin lip at the rim, never inside the 8x8 area. Moss is a separate shell (rounded, 2 cm overhang) coloured #5FB34A.
- Bark: vertical furrows simplified into 6 large ridges per quarter, with a painted lit side and a violet shadow side. Two fungus shelves in warm orange as the one accent.
- Roots: 5-7 thick roots (chunky, not spindly) flare out of the bark and drop over the island edge into the underside rock. Two big roots wrap a boulder. No root is thinner than 6 px at 720 px.
- Collision: a simple cylinder `-col` for the stump top, nothing else. Board logic is not physics.

## 4. The island

- Shape: a tapered rock mass, bottom about 45% of the top width. 2-3 big strata bands (#A47848, #8A5A34, then #4A3A5E), 3-5 overhang chunks, 4-8 hanging roots and a few small crystals in cool violet. Silhouette is chunky and readable.
- Top: rounded grass lip overhanging the strata by 8%. Grass is a painted vertex-colour gradient (#7CCB3F lit to #3E9A4A).
- Dressing: tuft clumps (5-7 cards plus 3-4 flowers each), 3 rock sizes (150-400 tris), 2 ferns, 2 shrubs, one small mushroom group. Flowers are big (about 12 px), few and clustered at the corners.
- Density rule: no dressing within 0.3 cells of any playable cell. In practice the exclusion zone is the board octagon expanded by 0.3 cells (and the whole stump disc footprint). Scatter masks are generated from this zone. A validator script in the build checks every instance centre and its radius against the zone and fails the export on a violation.
- Rest area: a calm, low-contrast grass ring directly around the stump. Detail concentrates at the island rim and the two front corners.
- Island top diameter: about 15 cells; the Wizard and Ada stand on the front rim.

## 5. Background

- Sky: 3-stop gradient (#6FB4EE, #BFE3FF, #FFD9B0 at the horizon). HDRI spruit_sunrise at 2K is used for reflections and ambient colour only, not drawn as the visible sky. The visible sky is the painted gradient plus cards.
- Clouds: 6-8 chunky painted cloud cards in 2-3 depth layers, lit warm on the sun side and violet underneath, with slow parallax. No grey.
- Distant islands: 3-4, each 25-40% of the main island size, 300-800 tris, varied landmarks (arch, round hill, pine cluster). Aerial perspective by hue, not grey: lighter, cooler, 30% lower contrast, same chroma.
- Cottage island (upper right, clear of the HUD top zone): a small cottage, 800-1500 tris, 3 chunky volumes, overhanging red-orange roof (#E0603A), a warm lit window (#FFD27A), a chimney with a slim smoke puff. The Hearth Hum meter links to its window glow: the window brightens as the meter rises.
- Waterfall: a thin misty ribbon falling off the cottage island's edge, semi-transparent with a scrolling shader and a soft spray cloud at the end. Not an opaque white bar.
- Sun: low behind the left distant island with a soft glow card.

## 6. Goal ring and end beat

- Goal ring: a torus-like ring hovering above the stump at the target height. Core #FFE27A, soft inner #FFF6C8, 0.08-cell tube radius, an additive glow sprite halo, and 6-10 slow sparkle motes. Gentle bob (0.04 cell, 2 s) and a slow pulse. It must not block the view of the board: it is drawn behind the pieces' silhouettes and thin enough to read. Brightness rises when the stack nears the ring (the proximity cue).
- Reached state: the ring flashes white, then expands and fades while the bell rings (audio is the audio-director's domain).
- End beat: the stump glows green. The ring grooves and the cell grooves emit #4CFF8A from the centre outwards over 0.8 s (ripple along the rings), the moss brightens, the rim glints, and bloom lifts. Petals or motes rise. The sky warms by 10%. A held 1.2 s settle follows, then the result UI. The glow is emission on a mask texture (rings), so it costs no extra mesh.

## 7. Asset list

| Element | Source | Licence | Stylisation steps | Tri budget |
|---|---|---|---|---|
| Stump body, bark, roots | PolyHaven tree_stump_01 / tree_stump_02 as reference; custom retopo | CC0 | Retopo to 6 big ridges, bevel 8%, bake AO to vertex R, paint over bark_brown_02 at 512 px | 6,000 |
| Stump top disc and board pads | custom | own work | Hand-painted ring albedo, pads and grooves modelled | 3,500 |
| Bark texture | PolyHaven bark_brown_02 (alt tree_bark_03) | CC0 | Downsample to 512, posterise, saturation +25%, paint highlights | texture |
| Moss | PolyHaven moss_01 as reference; custom shell | CC0 | Shell with rounded lobes, gradient | 500 |
| Island rock mass | custom sculpt; reference namaqualand_boulders_01 | CC0 ref | 2-3 strata bands, decimate, vertex colour bake | 6,000 |
| Island rock texture | PolyHaven mossy_rock, aerial_grass_rock | CC0 | 512 px, painted, saturation +20% | texture |
| Island ground texture | PolyHaven forrest_ground_01 (slug misspelled on the site) | CC0 | 512 px, painted | texture |
| Rocks (3 sizes) | PolyHaven rock_moss_set_01, boulder_01 | CC0 | Decimate to 150-400 tris, chunky facets, bevel, gradient | 3 x 300 |
| Grass tufts | PolyHaven grass_medium_01 as reference; custom cards | CC0 | 5-7 card clump, painted gradient, MultiMesh | 400 per clump |
| Flowers | PolyHaven dandelion_01 as reference; custom | CC0 | Rebuild as chunky 5-petal heads, 4 hues | 150 each |
| Ferns / shrubs | PolyHaven fern_02, shrub_04, shrub_02 | CC0 | Card-based, 12 fronds, painted | 300 each |
| Mushrooms | custom (BlenderKit candidate, id TBD) | check per asset | Toon ramp | 200 |
| Cottage | custom (no PolyHaven cottage found; BlenderKit candidate, id TBD) | own work | 3 volumes, bevel 5%, warm window | 1,500 |
| Waterfall | custom | own work | Ribbon mesh, scrolling shader | 200 |
| Distant islands (4) | custom | own work | Tint, reduced contrast | 4 x 500 |
| Clouds | custom painted cards | own work | Painted, alpha scissor/blend sorted | 8 quads |
| Goal ring | custom | own work | Emission, additive halo | 400 |
| Dawn HDRI | PolyHaven spruit_sunrise (alts bloem_field_sunrise, qwantani_dawn_puresky, spruit_dawn) | CC0 | 2K, ambient and reflections only | texture |
| Wizard, Ada | existing characters (wizard_turnaround_ref.png) | project | Same toon ramp | 5,000 each |

Each BlenderKit asset used must have its id, uuid, author and licence recorded in this table before import. BlenderKit licences are per asset (Royalty Free or CC0), so check each one.

## 8. Pipeline

Blender tools: Poly Haven add-on (asset browser), the BlenderKit add-on (free assets are usable without login; direct REST downloads probably need an account token, which is unconfirmed), Geometry Nodes for scatter (use the Poly Haven grass_medium_01 node group as a base), Bevel plus Weighted Normal modifiers, and Decimate. Geo-Scatter is a paid tool and is not assumed.

Stylisation conversion, applied to every PolyHaven or BlenderKit source:
1. Decimate or retopo to budget, keep silhouettes, remove detail finer than 6 px at 720 px.
2. Bevel 6-10% with weighted normals.
3. Replace photoreal PBR with a 512 px painted albedo (posterise to 6-8 tones, saturation +20-25%, hue push toward warm in lights and violet in shadows). Drop normal maps except on bark.
4. Bake AO to COLOR_0.R (tinted violet), curvature to G, height gradient to B, outline weight to A.
5. In Godot: toon ramp shader (wrap lighting, 3-stop ramp), rim light, thin inverted-hull outline on the characters and the stump only.

GLB export (3 files, Y up, glTF Binary):
- env_stump_board_large.glb: stump, board pads, goal-ring anchor empty. Collision `-col` cylinder.
- env_island_meadow_large.glb: island, grass, dressing (scatter baked as instanced objects or MultiMesh data).
- env_backdrop_meadow_large.glb: distant islands, cottage, waterfall, cloud cards.
- Export settings: apply modifiers, tangents off unless normal-mapped, vertex colours on, materials as export, no cameras or lights, Draco off, images as PNG or WebP (compress in Godot).

Godot import:
- Mesh nodes use the `-col` suffix for static collision (`-convcol` for the rocks if ever needed).
- Mipmaps on. VRAM compression: Mobile uses ETC2/ASTC; normal maps use the Normal Map setting; painted albedo uses VRAM Compressed with sRGB. UI textures stay lossless.
- Godot addons to consider (all UNCONFIRMED on 4.7.2): ProtonScatter (scatter; no stated tested version), Terrain3D (documented for 4.4-4.6 only; not needed here, skip). Sky, water and toon shaders are plain .gdshader files and need no addon. Verify each addon on 4.7.2 in a throwaway project first.
- Renderer features (glow, fog, depth texture under Compatibility versus Mobile) are still unverified; see art-research-2026-10-14.md, flag V.

Budgets (mobile, whole frame):
- Visible triangles at most 110,000 (stump 9.5k, island 6k, dressing 20k, backdrop 12k, characters 10k, effects 5k, margin).
- Draw calls at most 120.
- Texture memory at most 40 MB VRAM compressed (stump atlas 1024, island atlas 1024, dressing atlas 512, cards 1024 x2, characters 512 x2).
- Lights: one directional plus ambient; shadows only from the key; at most one shadow cascade.

## 9. Acceptance criteria

1. A 720x1280 in-engine capture of meadow_01 is saved in production/qa/evidence/ and placed beside biome_screens_ref.jpg, party_biome_islands_ref.jpg and v3_level_meadow.png.
2. A strict 3-expert panel (art, UI, gameplay readability) scores at least 9.7/10 from each reviewer.
3. The board reads first: the stump top is the lightest, most saturated area, and every cell is readable at arm's length.
4. No dressing sits within 0.3 cells of a playable cell (validator output attached).
5. No beige or parchment, no grey fog, shadows are violet.
6. Hierarchy holds with the HUD on: the top and bottom zones are clear of busy detail.
7. The goal ring is visible without hiding the board, and the green end beat is captured in 3 frames (before, mid, after).
8. Budgets in section 8 are met, shown by a frame-stat capture on a mobile-class device.
9. All asset licences are CC0 or recorded; BlenderKit ids are filled in.

## Decisions (pending user confirmation, recommended default first)

| Decision | Recommended default | Alternative |
|---|---|---|
| Corner-cut rule | Follows the level designer's mask (52-cell octagon is a placeholder) | Fixed octagon or circle rule decided by art |
| Cottage source | Custom model | A BlenderKit pick (id TBD, licence to be checked) |
| Scatter tool | Blender Geometry Nodes | Geo-Scatter (paid) |

## Blocked / uncertain

- BlenderKit API not queried; ids and licences to be recorded by hand from the add-on. API-key need for direct REST download unconfirmed.
- Godot 4.7.2 support unconfirmed for ProtonScatter and Terrain3D.
- No PolyHaven cottage or waterfall asset found.
