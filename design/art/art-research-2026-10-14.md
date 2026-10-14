# Art Research: why our frames look worse than the references, and the recipe to fix it

Date 2026-10-14. Author: art-director. Bar: 9.7/10 against `assets/art/reference/style/*` (15 and 13 are the targets).
Inputs viewed: refs 01, 05, 09, 13, 14, 15 (plus the index and bible); our `blocks-v2/gameplay_stack_4biomes.png`,
`islands-v2/meadow|lava_720x1280_stack.png`, `level-look-v1/meadow_sheet.png`, `playtest-2026-10-14/levels/meadow_sheet.png`,
`full-build/ui/hud_720.png` and `title_720.png`, and `quality-review/2026-10-14-art.md`.
Not individually opened this pass: the other ~25 evidence PNGs. The art review's scores (3.6/10 mean) were used for those.

Source honesty: the web searches returned technique pages and shader examples, not shipped-game postmortems. Where a
recipe item rests on general craft knowledge and not on a fetched page, it is marked (craft). Renderer feature support
(glow, DOF, fog under Compatibility vs Mobile) was not confirmed from the docs table this session. Verify it on
the Godot 4.7.2 "Overview of renderers" page before building on it (flagged V below).

---

## 1. Gap diagnosis: the 10 biggest reasons we look worse than the references

1. **Lighting is flat and unmotivated.** Ref 15 has one warm key from the upper left, a visible cool shadow side, a bright
   lit edge on every top, and a soft bounce. Ours is evenly lit. Tops and sides of cubes differ by only a few percent, so
   the board reads as a texture sheet, not a volume. (meadow_720x1280_stack, lava_stack)
2. **No value grouping.** In ref 15 the board and blocks are the lightest, most saturated, highest-contrast thing, and the
   world is a mid-value, lower-contrast bed. In ours the blocks (dark green, red, navy) are as dark and as busy as the rim
   foliage and cliff, so nothing is "first read". Meadow blocks are darker than the tan tile they sit on.
3. **Beige/tan board tiles.** Warm tan tile is the same hue as the cliff and the old UI, so the play surface vanishes.
   Ref 15 uses cool light-grey stone (meadow, ice) and white marble with gold seams (celestial), which makes the
   saturated pieces pop by hue contrast.
4. **Blocks have a texture, not a material.** Ref 13 blocks have a fat, rounded bevel (about 8-10% of the edge) with a bright
   specular line on every edge, a distinct cap shape (dripping frosting, moss lip, snow with icicles) and inner depth
   (translucent jelly, glass with bubbles). Ours are crisp boxes with a repeating noise tile, a thin cap, and no edge
   glints. The lava cracks are a brick grid with a bloom halo, not organic basalt.
5. **Fog and haze wash out saturation.** The grey-white fog at the horizon, the pink fog on candy and the maroon sky on lava
   all desaturate. Ref 15 keeps saturation high at distance and shifts only hue and value (cooler, lighter). Atmosphere
   should add sky colour, not grey.
6. **The backdrop is cardboard.** Flat cutout hills with visible seams, opaque white bars for waterfalls, and distant islands
   that are too close and identical (slab plus four lollipop trees) and fully saturated. Ref 15 has layered painted
   mountains and clouds, thin misty waterfalls, big depth falloff, and varied landmarks (castle, arch, windmill).
7. **Uniform detail density.** Rim flowers and clover, cliff roots, chunky blocks, floating props and UI all have the same
   contrast and frequency. The ref uses rest areas: a calm tile surface, a calm sky, and detail concentrated at the rim.
   Our high-frequency noise (grass cap, root tangles, flower clutter) competes with the pieces.
8. **Uniform bevels and no silhouette design.** The island is a box with a ragged skirt. Ref islands have a thick, chunky,
   tapered rock mass with 2-3 large strata bands, a few big overhangs, hanging roots and crystals, and a lip of rounded
   grass over the edge. Props (mouse, cone-hat blob, fence) have thin, small parts that vanish at 720 px.
9. **UI and 3D are two different materials.** Our HUD is flat purple rectangles with gold outlines over a 3D scene. In ref 15
   the SCORE and NEXT chips are tactile carved objects with the same warm light, thick frames and vine details as the
   world. The 10-button control strip, debug labels and hard-edged lozenges add noise (the review's U10/U11).
10. **No finishing pass.** The refs read as painted: subtle bloom on highlights, warm-cool grading, soft vignette, gentle
    depth blur at the diorama's far edges and sparkles. Ours has none, or has hard glow only on lava. Hence the
    "game render" look.

---

## 2. The target recipe (what the look is made of)

Constraint: Godot 4.7.2, Mobile (or Compatibility) renderer, 720x1280. No SSAO, SSR, SDFGI or VoxelGI (V). So bake
everything we can (vertex colour, AO, gradients), keep lights few (one directional plus ambient), and do the rest in
`ShaderMaterial`. Existing includes: `painted_light.gdshaderinc`, `env_painted.gdshaderinc`, `spatial_post_painted.gdshader`.

| # | Ingredient | Recipe | Godot 4 Mobile/Compat note | Inspiration |
|---|---|---|---|---|
| R1 | **Wrap + ramp lighting** | Half-Lambert wrap (`NdotL*0.5+0.5`), then sample a 3-stop colour ramp: shadow = cool violet-blue (not black), mid = base, lit = warm cream. Soft terminator, no hard cel bands | `light()` function with `diffuse_toon`, or lit in `fragment()` using `LIGHT_VERTEX`-free math so it works with one DirectionalLight3D. Pass `ramp` as a `sampler2D` (128x1 PNG, `filter_linear`). Keep the ramp per biome in `biome_looks.json` | Godot Shaders "Toon Shader" / "Flexible Toon Shader (Godot 4)" (ramp, rim, spec groups) |
| R2 | **Specular blob and edge glint** | Small hard-edged spec dot (smoothstep on `pow(NdotH, 64)`) on tops, plus a thin edge glint from a baked curvature mask. This gives the "wet candy/plastic" read of ref 13 | Spec blob in `light()`. Edge glint = vertex colour channel G (curvature bake) multiplied by `NdotL^2` and added as emission | "Complete Toon Shader" (toonified specular and rim bands) |
| R3 | **Fresnel rim, warm and cool** | Rim = `pow(1-NdotV, 3)`, tinted warm from the key side, cool from the other. Ice, candy, neon and celestial blocks additionally get a bright fresnel edge | In `fragment()` add to `EMISSION`. Cheap, mobile safe | Godot Shaders toon pages; (craft) |
| R4 | **Baked AO in vertex colour R** | AO baked in Blender into the R channel (tinted, not black: multiply with a deep violet or brown). The shader does `albedo *= mix(ao_tint, 1, vc.r)` | Vertex colour stays in the glTF `COLOR_0` and is read as `COLOR` in the shader (set `vertex_color_use_as_albedo` off in custom shaders). No SSAO needed | Polycount advice to use coloured, not flat-black, AO; Tripo3D/Octopus vertex-colour baking (AO, curvature, gradient layered) |
| R5 | **Vertex-colour gradient + paint layer** | G = curvature (edge wear), B = height gradient (light-to-dark from top to bottom, e.g. cliff band tops lit and undersides cool and dark). Colour variation per face comes from a small 256px painted atlas, not noise | One shared atlas per biome keeps draw calls low. Cluster the mesh to 32+ subdivisions on large faces or bake into the atlas to avoid banding | Tripo3D vertex-colour baking guide (notes banding if mesh is too coarse) |
| R6 | **Outline: inverted hull, thin and tinted** | 1.5-2 px worldspace hull, colour = darkened albedo (not black), width driven by vertex colour A so edges taper. Only on pieces, characters, set pieces. NOT on terrain or foliage. Soft and thick on blocks | Second material pass, `render_mode cull_front, unshaded`, `VERTEX += NORMAL * width * COLOR.a`. Needs hard-normal fix: bake smooth outline normals into UV2 or use the weighted-normal result | Godot Shaders "simplest outline shader" and "Improved inverted hull" (vertex-colour width weight) |
| R7 | **Optional post edge (hero only)** | Normal/depth Sobel at low strength, only to separate block pile from tiles. Skip if inverted hull reads well; post outlines on a mobile target cost fill rate | Quad-on-camera screen shader in `spatial_post_painted.gdshader`. Needs depth/normal textures, so check availability under Compatibility (V) | Godot Shaders "Post-Process Outline (Depth/Normal)", Sobel variants |
| R8 | **Colour grade and glow** | Warm highlights, cool shadows (split-tone), saturation +10-15%, soft glow threshold at 0.9 to catch glints and emissives only, mild vignette | `Environment.glow_*` plus `adjustment_*` (V: confirm glow in the chosen renderer). Otherwise do the grade in the post quad | (craft) |
| R9 | **Atmospheric perspective by hue, not grey** | Fog colour = the sky horizon colour at 25-35% density. Far layers lighter, cooler, 30% less contrast, but keep chroma. Foreground purer, background tinted | `Environment.fog_*` with `fog_light_color` sampled from the sky gradient and `fog_sun_scatter` 0. For card layers, a per-layer `tint` uniform and `depth_fade` | Alto's Adventure palette practice (purer foreground, tinted background, few hues per scene; Ulster/Design Milk commentary); general aerial-perspective guides |
| R10 | **Painted sky + cloud cards** | Gradient (3 stops, hue-shifting), 2-3 soft painted cloud billboard layers with a hand-painted rim of light, one nebula or sunbeam layer, slow parallax. No grid lines | Keep `canvas_env_sky.gdshader` for the gradient. Clouds are `QuadMesh` with `billboard_mode = ENABLED`, `shading_mode = UNSHADED`, alpha-blend (few, large, sorted). Optionally Godot Shaders "Stylized Sky" for the gradient | Godot Shaders Stylized Sky / AAA Fake Volumetric Clouds (noise-based alternative if painting is not available) |
| R11 | **Foliage cards** | Trees and bushes are 8-14 leaf cards (clump shapes, not square) around a trunk, with a baked gradient (light top, dark bottom, AO at the trunk), a soft fresnel rim and light wind sway | Alpha scissor (0.5), `cull_disabled`, double-sided normal flip, `VERTEX.x += sin(TIME + world.x) * UV.y * k`. Scissor/hash, never blended, for depth and mobile speed | Godot Shaders "Stylized Fluffy Tree Leaves" (wind, fresnel, discard) and "Pixel Art Wind Sway" (UV.y weighted sway, backlight fix) |
| R12 | **Tilt-shift miniature** | Slight blur above and below the board band, a gentle saturation boost and a warm vignette. Gives the "toy diorama" feel. Keep the board band fully sharp | Screen-space band blur from the depth-based Tilt-Shift shader (the built-in DOF near-blur does not suit a top-down 3/4 camera, per the author). Strength 0.3-0.5 so HUD text is unaffected (render HUD on a CanvasLayer above) | Godot Shaders "Tilt-Shift Shader" and "Depth based Tilt-shift" |
| R13 | **Chunky bevels and silhouettes** | Bevel width 6-10% of edge on blocks, 2-3 segments, with weighted normals. Props have no part thinner than about 6 px at 720 px. Every object reads as a silhouette at 64 px | Blender Bevel modifier (Limit method: Angle or weight) plus Weighted Normal modifier. Export as GLB with custom normals | Blender manual, Weighted Normal and Bevel "Face Influence" |
| R14 | **UI and 3D cohesion** | The HUD is carved from the same material: thick bevelled frames with the same warm key and cool shadow side, same vine and blossom language, and its lettering in cream with a dark outline. Render UI nine-patches from Blender with the same light rig as the world (key from upper left) | `StyleBoxTexture` nine-patches from the Blender kit, with the single Theme palette. A 2D plate behind HUD floaters (the Parasol feedback: 2D over 3D looks odd without a shared plate) | Unity forum "Parasol" critique; FANTASIAN diorama article on low-cost lighting |

Priorities when the budget is tight: R1, R4, R9, R13 and R14 are the biggest for 9.7. R6, R7 and R12 are second.

---

## 3. The asset recipe (Blender, then GLB)

Global rules: one light rig for all hero renders and bakes (key from upper left, about 4200 K, cool fill from the right,
rim from behind). Every GLB carries `COLOR_0` (R = AO, G = curvature, B = height gradient, A = outline width).
Naming per the bible: `env_<object>_<descriptor>_<size>.glb`.

| Asset | Build | Budget | Notes |
|---|---|---|---|
| **Blocks** (ref 13) | Rounded cube, bevel 8-10% (3 segments), weighted normals. Cap as a separate shell (2-3 mm overhang, a dripping edge for candy, lip for moss, icicle fringe for ice). Cubes 1:1:1, topper as a separate instanced mesh on 1 cube in 3 | 400-700 tris per cube, 1 material per biome, 512 atlas | Silhouette must read as "cube plus cap". Jelly and ice use fake transmission (backlit rim plus inner gradient), not real refraction. Lava: Voronoi cracks, emission only in cracks, 2.0+ |
| **Island** (ref 15) | One sculpted tapered mass: top slab (the board terrain) with a rounded grass/snow/marble lip overhanging 8%, then 2-3 big strata bands with deep grooves, then 3-5 large overhang chunks and 4-8 hanging roots, icicles or crystals. Bottom tapers to about 45% of the top width | 3-5k tris. No chip detail below 6 px at 720 | Bake AO into the grooves and under the lip (tinted violet). Value: top lightest, strata mid, underside darkest-coolest |
| **Board tiles** | Tile grid with a rounded 3 px grout bevel, light cool grey stone, a few painted chips and moss in corners. Marble variant with gold seam emission | 12 tris per tile; one 256 atlas | Tile value 15% lighter than the surrounding rim to push the board forward. Ghost = glassy cells, fresnel edge glow |
| **Rocks** | 3 sizes, chunky 6-12 facets with a bevel, vertex-colour gradient (lit top, cool base), moss patch cap. Not noisy | 150-400 tris | Reuse as strata debris and floating islets |
| **Grass and flowers** | Rim = rounded tuft clumps (5-7 cards plus 3-4 flowers each) with a gradient and baked light; flowers are big (about 12 px) and sparse, clustered at corners; fewer, bigger, cleaner | 300-500 tris per clump instanced via MultiMesh | Remove the clutter that overlaps the first row of tiles (rest area) |
| **Trees** | Trunk with a bevel plus 8-14 leaf cards (clump-shaped), gradient light top. Pine = 3 stacked cone-cards, snow caps for ice | 150-400 tris | Use 2-3 species per biome. Outline: none, soft rim only |
| **Set pieces** | Cottage, windmill, castle, arch, pillars: 3-5 chunky volumes, roofs overhanging, one saturated accent colour, bevel 5%, lantern or window glow. Each has a unique silhouette | 800-2000 tris | Scale them smaller than the board and place them off the board's sight line. A light beacon on one per biome gives a focal point |
| **Distant islands** | 3-5 per frame, 25-40% of the current size, painted mostly in tint (aerial perspective), vary landmarks | 300-800 tris | Fog colour into them, lower contrast |
| **Characters** | 2.5 heads, chunky toy bodies, a painted albedo (warm-to-cool gradient, cheek and knuckle tints), rim lamp, toy metal (roughness 0.35, painted highlight band), consistent hands rule, closed-eye smile default | 3-6k tris | Outline hull with A-weighted width. Check silhouette at 64 px. See review C1-C10 |
| **UI kit** | Render in Blender with the same rig. Carved plum glass, purple wood, thick bevels, 2x res, nine-patch | n/a | No beige. See review section 0 |

---

## 4. The colour script (board and blocks read first, scene supports them)

Rule for all biomes: value order from lightest to darkest = pieces and board highlight, then sky and clouds, then island
body and rim, then far layers. The pieces carry the most saturation and contrast; the scene sits 15-25% lower in
saturation and compresses contrast with distance. Use at most 4 hues per frame outside the pieces. Hex values are
starting points, to be sampled against refs 13 and 15 during the Blender pass.

| Biome | Sky (top to horizon) | Island and rim | Board tile | Piece palette (saturated) | Accent / light |
|---|---|---|---|---|---|
| **Meadow** | `#6fb4ee` to `#d9efff`, white clouds | grass `#6dbb3f`, soil `#8a5a34`, strata `#a47848` | cool grey `#b9b6b0` | green, pink, yellow, blue (ref 15) | warm key `#ffe2a8`, shadow `#5b4a8a` |
| **Ice** | `#8ec3f0` to `#eaf3ff` | snow `#f4fbff`, cliff `#3e6fb3`, underside navy `#1c2f5c` | frosted grey-blue `#a9bfd8` | cyan, violet, pink glass | cool key `#dff0ff`, rim magenta |
| **Lava** | `#2a0f26` to `#7a2a2a` (dark, not maroon mud) | basalt `#2a2224`, strata `#463036` | near-black `#38292d`, lit edge `#6a4a46` | warm basalt, glowing orange, a cyan or violet crystal accent | ONE emissive `#ff8a2a` in cracks plus a lava sea, steam |
| **Candy** | `#ffc6e0` to `#fff1f6` (low fog) | frosting `#fff4f8`, pink body `#f27ab0` | pink-white sugar `#fbe2ec` | translucent pink, orange, lime jelly | warm `#fff0c8`, sprinkle accents |
| **Celestial** | `#1b1050` to `#6a3fc0`, nebula magenta | marble `#efeaf5`, gold `#e8b84a` | white marble, gold seams | violet `#5b3bc8` with gold fresnel | gold glow, ringed planet painted |
| **Underwater** | `#1f6fa8` to `#7fd3e0`, light shafts | coral rock `#3a5a8a` | pale sand-blue | blue/purple glass, bubbles | cyan caustic accent |
| **Forest** | `#2f6f5a` to `#bfe0b0` | moss `#4f8a3a`, bark `#6b4a2a` | mossy grey | warm wood, leaf green | golden god-rays |
| **Clockwork / Neon / Fair / Dune / Cave** | per ref 13 and 14: gold-on-navy, cyan on dark glass, pink-cream stripes at dusk, teal-on-sand, grey with violet crystals | each follows the same rule: dark or mid world, bright board | | | one accent only |

Frame colour (HUD) follows the biome: vine green, ice blue, celestial purple, dark iron (lava), pink frosting (candy).

---

## 5. Prioritized fix plan (12 tasks)

| # | Task | Owner | Expected gain | Evidence to capture |
|---|---|---|---|---|
| 1 | Replace tan tiles with cool grey stone / marble / sugar; make ghost glassy with fresnel edge | Blender + shader | Large: pieces separate from board instantly | Side-by-side with ref 15, 5 biomes, one build, one suffix |
| 2 | Block pass: 8-10% bevel, weighted normals, cap shells on every piece, vertex-colour AO/curvature, edge glint, jelly/ice fake transmission, organic lava cracks | Blender + shader/tech-art | Large: ref 13 look | Contact sheet vs ref 13 (12 biomes), plus in-play crop |
| 3 | Lighting rig + wrap ramp shader (R1-R3) with warm key, cool shadow ramp, rim; one include shared by all materials | shader/tech-art | Large: volume and "painted" feel | Before/after of meadow frame, same camera |
| 4 | Value pass: lower the saturation and contrast of the world by 15-25%, raise the board and pieces; remove the clutter overlapping the first row of tiles | world | Large: clear first read | Greyscale screenshot of each biome (value check) next to colour |
| 5 | Fog and sky: hue-based aerial perspective, remove grey/pink wash, remove celestial grid, add nebula, painted cloud cards (R9, R10) | world + shader | Medium-large | 5 biomes at 720x1280 vs ref 15 |
| 6 | Backdrop rebuild: 3 painted parallax layers, thin misty waterfalls (scrolling alpha), 3-5 smaller, varied distant islands with landmarks | world + Blender | Medium-large | Meadow and ice frames vs ref 15 |
| 7 | Island resculpt: tapered chunky mass, 2-3 strata bands, rounded lip, overhangs, roots/icicles/crystals, baked AO | Blender | Medium-large | Turntable of island plus in-game frame |
| 8 | Foliage and rim pass: clump cards with gradient + wind, bigger sparser flowers, calm tile rest-area | Blender + shader | Medium | Close crop of rim, in-game |
| 9 | Outline and finishing: inverted-hull on pieces and characters, glow, grade, vignette, tilt-shift band (R6, R8, R12) | shader/tech-art | Medium: "painted game" finish | A/B toggles on the same frame |
| 10 | HUD rebuild in the same material language: plum glass or purple wood with Blender-rendered nine-patches, NEXT with a piece render, 3-slot tray, remove the 10-button strip and debug labels, safe-area timer, biome frame | UI | Large for UI score | All 13 `full-build/ui/*_720.png` re-shot with the 3D stage behind |
| 11 | Props and set pieces per biome (cottage, windmill, castle, arch), mascot replaced by the real wizard GLB | Blender + world | Medium | Per-biome hero frame |
| 12 | Characters material pass (painted albedo, rim, toy metal, closed-eye wizard) and the elf IP fix | Blender | Medium | 5-pose sheet vs refs 01, 14, 15 |

Process: one build, one suffix, all 12 biomes plus 5 hero UI screens, each as a `_vs_ref` pair, in
`production/qa/evidence/art-pass-v1/`. Gate each task with a greyscale (value) check and a 64 px silhouette check.

---

## 6. Sources

Fetched pages could not be opened this session (no page-fetch tool), so these are from search result summaries.
- Godot Shaders, Toon Shader (ramp texture, toon spec): https://godotshaders.com/shader/toon-shader/
- Godot Shaders, Toon Shader for Godot 4 (ramp offset, rim, subsurface): https://godotshaders.com/shader/toon-shader-for-godot-4/
- Godot Shaders, Flexible Toon Shader (Godot 4): https://godotshaders.com/shader/flexible-toon-shader-godot-4/
- Godot Shaders, Complete Toon Shader (specular blobs, rim bands): https://godotshaders.com/shader/complete-toon-shader/
- Godot Shaders, The simplest outline shader (inverted hull, `cull_front`): https://godotshaders.com/shader/the-simplest-outline-shader-via-material/
- Godot Shaders, Improved inverted hull (vertex colour width): https://godotshaders.com/shader/improved-inverted-hull-simplest-outline-shader-improved/
- Godot Shaders, Post-Process Outline (Depth/Normal): https://godotshaders.com/shader/post-process-outline-depth-normal/
- Godot Shaders, Normal-based Sobel edge detection: https://godotshaders.com/shader/normal-based-edge-detection-with-sobel-operator-screenspace/
- Godot Shaders, Tilt-Shift Shader: https://godotshaders.com/shader/tilt-shift-shader/
- Godot Shaders, Depth based Tilt-shift: https://godotshaders.com/shader/depth-based-tilt-shift/
- Godot Shaders, Stylized Sky: https://godotshaders.com/shader/stylized-sky/
- Godot Shaders, AAA Fake Volumetric Clouds: https://godotshaders.com/shader/aaa-fake-volumetric-clouds/
- Godot Shaders, Stylized Fluffy Tree Leaves: https://godotshaders.com/shader/stylized-fluffy-tree-leaves/
- Godot Shaders, Pixel Art Wind Sway (UV.y sway, alpha scissor and backlight tips): https://godotshaders.com/shader/pixel-art-wind-sway-meshinstance3d-godot-4-0
- Godot docs, Overview of renderers (verify the feature table): https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Tripo3D, Smart Vertex Color Baking for Stylized 3D Shading: https://www.tripo3d.ai/blog/explore/smart-mesh-vertex-color-baking-for-stylized-shading
- Polycount thread on coloured AO in stylized work: https://polycount.com/discussion/comment/1505558
- Vertex Color Octopus docs (vertex-colour AO baking for mobile): https://superhivemarket.com/products/vertex-color-octopus/docs
- Blender manual, Weighted Normal modifier: https://docs.blender.org/manual/en/4.1/modeling/modifiers/modify/weighted_normal.html
- Design Milk, Alto's Adventure palette practice: https://design-milk.com/altos-adventure-keeps-simple/
- Unity blog, FANTASIAN diorama art (low-cost lighting): https://unity.com/blog/games/ambitious-art-how-mistwalker-fulfilled-their-magnificent-vision-for-fantasian
- Unity forum, Parasol (2D UI over 3D critique): https://discussions.unity.com/t/parasol-a-mobile-puzzler/521151
- Zelda BotW art direction summary (painterly look, cel shading choice): https://www.tweaktown.com/news/63954/legend-zelda-breath-wild-art-style-explained/index.html

Gaps: no GDC slide deck or shipped-game postmortem was retrieved. Next research step if wanted: the Takizawa GDC 2017 talk,
a Godot Compatibility feature table check, and Blender-side bevel width conventions from a named studio talk.
