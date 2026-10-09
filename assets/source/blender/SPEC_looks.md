# Block look sets — build spec (art director, 2026-10-09)

All numbers are tunable defaults. Every look = one full set of the 67-shape bank (text block `wt_shapes`), built from individual cubes on a 1.0 grid, collection `SET_<look>`, piece empties `blk_<look>_<shape>`.

## User rules
- Work ONLY through the live Blender MCP server (`mcp__Blender__execute_blender_code`). Never `blender -b`.
- Triangles only where they make detail; flat regions collapse (planar Decimate is in the builder). No budgets otherwise.
- Use Blender's installed add-ons where they genuinely help: LoopTools (relax/circle), Bool Tool (`object.boolean_auto_*`), Vertex Col Forge (`mesh.ylvc_*`, curvature/AO masks), The Better Baker (`better_baker.*`), Attribute Baker, ambientCG importer (CC0 textures), BlenderKit (user logged in; Royalty-Free → only ship own bakes), UniV (`mesh.univ_*`), Node Arrange (`node.na_*`), 3D-Print Toolbox checks (`mesh.print3d_check_*`), Ucupaint.
- Pieces stay individual cubes but must read as one object (FILL overlap / continuous materials).
- Keep a licence ledger for every downloaded asset (name, source, id, licence, used for) in `LICENCES.md` next to this file.

## Decisions taken
Envelope rule (cube within 0.97–1.08 of its cell); pearl + volcanic glass kept (limited); ice = snow_porcelain; marble veins pale = mix(hue, white, 0.75); natural tint: wood 0.7, stone 0.55, tin 0.85, bare metal 0. No status-shell vocabulary in native looks (cracks, frost, flames, vines, drips, spikes, swirls with a centre, dark smoke). No idle emission except neon groove.

## Build order
1 neon_voxel (DONE — check & polish) · 2 gummy_jelly · 3 river_stone · 4 enamel_tin · 5 volcanic_glass · 6 pearl_bead · 7 wood_block · 8 marble_cut · 9 terracotta_tile · 10 snow_porcelain · 11 toy_brick. (candy_toy exists as base.)

## Geometry recipes (G = geometry, T = texture)
- **candy_toy**: Bevel 0.14 seg 2 → Subsurf 2 → Cast sphere 0.04 → FILL 1.03.
- **gummy_jelly**: Bevel 0.22 seg 3 profile 0.5 → Subsurf 2 → Cast sphere 0.10 (pillow G) → FILL 1.06. Bubbles T. No sag.
- **pearl_bead**: Bevel 0.30 seg 4 → Subsurf 2 → Cast sphere 0.30 (0.25–0.35, never above) → FILL 1.08 (scalloped outline).
- **snow_porcelain**: Bevel 0.16 seg 6 profile 0.80 miter_outer ARC; no subsurf/cast; FILL 1.02; dead-flat faces, squircle corners.
- **terracotta_tile** (3 variants): bmesh bevel offset 0.07 seg 3; main faces inset_individual thickness 0.10 depth −0.02 (recessed dish, verify sign); micro-bevel 0.02; Subsurf SIMPLE 3 + Displace CLOUDS noise_scale 0.8 strength 0.012 NORMAL GLOBAL, object offset (k*10.37, k*3.71, 0) per variant; FILL 1.01; random 24-orientation.
- **wood_block**: Bevel 0.035 seg 3; FILL 1.00; hairline V seams; grain T box-projected continuous across the piece; no plank grooves.
- **river_stone** (4 variants): Bevel 0.22 seg 3 → Subsurf 3 → Cast 0.12 → Displace CLOUDS noise_scale 0.6 depth 1 strength 0.05 (variant offsets) → FILL 1.04; low-frequency lumps only, no pits; random 24-orientation.
- **marble_cut**: Bevel 0.07 seg 1 (flat chamfer) + micro-bevel 0.006; FILL 1.02; veins T continuous.
- **volcanic_glass** (4 variants): bmesh bevel offset 0.10 seg 1; per variant rng=Random(v+1) cut 3 of 8 corners with bisect_plane (normal = corner dir + uniform(−0.25,0.25) per axis, normalised; offset uniform(0.70,0.74)), clear_outer, holes_fill; FILL 1.02; smooth by angle 20°; random 24-orientation.
- **enamel_tin**: bmesh bevel 0.04 seg 3; main faces inset thickness 0.09 depth +0.02 (raised panel); micro-bevel 0.01; FILL 1.00; rivets G: 4 per face at in-plane (±0.415, ±0.415), uv-sphere r 0.025 (12×8), scaled 0.6 along normal, centred at face plane −0.005, material index 1.
- **neon_voxel**: bevel 0.015 seg 1; groove frame per face (inset 0.06 → depth −0.025 → inset 0.035 → back +0.025), groove floor material index 1; FILL 1.00; micro-bevel (0.006, 2) + weighted normals.
- **toy_brick**: Bevel 0.03 seg 3; FILL 1.00; one stud on +Z: cylinder r 0.17, depth 0.07, centred z 0.515, micro-bevel 0.012. No random rotation.

## Variation
Variants + random 24-orientation only for terracotta (3), river_stone (4), volcanic_glass (4). Deterministic seed per cube.

## Preview materials (Principled; hue from Object Info → Color; "tint" = how strongly hue replaces base)
| look | tint | base | rough | coat w/r | other | emission | texture |
|---|---|---|---|---|---|---|---|
| candy_toy | 1.0 | flat hue | 0.35 | 0.6/0.08 | — | none | none |
| gummy_jelly | 1.0 | hue +10% value | 0.25 | 1.0/0.03 | SSS 0.35 r0.2, no transmission | none | Voronoi dots lighter tint ~8% |
| pearl_bead | 0.8 | over #F3EEF0 | 0.20 | 1.0/0.05 | sheen 0.4 white, thin film 400nm IOR 1.4 | none | none |
| snow_porcelain | 0.9 | hue glaze | 0.08 | 1.0/0.02 | SSS 0.1, no white edges | none | none |
| terracotta_tile | 0.75 | glaze; bare clay #B5653F at dish lip (AO/pointiness) | 0.15 | 0.5/0.1 | — | none | BlenderKit "glazed ceramic tile" |
| wood_block | 0.7 | hue paint × wood grain ±15% | 0.55 | 0.3/0.15 | — | none | Poly Haven/ambientCG fine wood (verify id) |
| river_stone | 0.55 | hue over grey mottle, value 0.45–0.85 | 0.30 | 0.4/0.1 | — | none | Noise scale 3 detail 4 (no veins) |
| marble_cut | 0.5 | veins mix(hue, white, 0.75) | 0.12 | 0.6/0.05 | — | none | Wave+Noise or Poly Haven marble_01 as mask |
| volcanic_glass | 0.9 | hue value 0.6 | 0.08 | 0 | IOR 1.5 spec 0.7 | none | none |
| enamel_tin | 0.85 | rivets #C9C9C6 metallic 1 rough 0.3 | 0.25 | 0.8/0.05 | no chipping | none | none |
| neon_voxel | 0.6 | body hue value 0.35; groove full hue | 0.40 | 0.3/0.1 | — | groove strength 4 | none |
| toy_brick | 1.0 | flat hue | 0.30 | 0 | spec 0.5 | none | none |

## Acceptance (render T piece + 2x2x2 per look; 256 px silhouettes + greyscale)
gummy: cubes merge into one blob, pinch <30% edge · pearl: scalloped but squarish bumps · snow_porcelain: squarer corners than candy · terracotta: dish visible at 64 px · wood: hairline seams, grain flows across · river_stone: neighbours differ, grid still reads · marble: chamfer highlight band, veins cross joints · volcanic: facets on ≥1 in 2 cubes · tin: panels + rivets read at 64 px · neon: sharpest, groove grid aligns · toy_brick: studs read from 3/4.
