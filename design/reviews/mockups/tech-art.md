# Tech-Art Review: Minigame Mockups vs Current Rendering

> **Author**: technical-artist (subagent) · **Date**: 2026-10-13
> **Engine**: Godot 4.7.2, Mobile renderer (`renderer/rendering_method="mobile"`), phone targets
> **Status**: Review / proposal. No code was changed. All budget numbers below are **PROPOSED**:
> `.claude/docs/technical-preferences.md` sets 60 fps / 16.6 ms, but draw calls are still
> `[TO BE CONFIGURED — set once the reference phone is chosen]`. Confirm every number on that phone.

## Sources reviewed

- **Mockups viewed (16 of 20)**: `assets/art/reference/minigame_mockups/mockup_01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 12, 13, 14, 16, 17, 20.jpg`
- **Shaders**: `src/view/shaders/spatial_block_biome.gdshader`, `spatial_env_island.gdshader`, `canvas_env_sky.gdshader`
- **Code**: `src/view/wt_island_builder.gd`, plus the light/env/confetti parts of `src/view/wt_stage.gd`
- **Data/config**: `assets/data/biome_looks.json`, `project.godot` `[importer_defaults]` and `[rendering]`, `tools/asset-pipeline/block_post_import.gd`
- **Measured with Blender 5.2.2 headless** (not taken from memory):
  - Triangle counts:
    - `blk_candy_toy_cube.glb`: 1,728 tris.
    - `big_cube`: 13,824 tris (8 x 1,728).
    - `dented_cube`: 12,096 tris.
    - `giant_mega_cube`: 46,656 tris (27 x 1,728).
    - `crown`: 13,824 tris.
    - All of them have 0 materials and 0 images.
  - glTF exporter property names: listed in section 3.2.
  - Render engines: on this machine `CYCLES` (CPU) renders headless. `BLENDER_EEVEE` (and Workbench) abort because `libEGL.so.1` is missing.

**Engine-reference caveat.** `docs/engine-reference/godot/modules/rendering.md` was last verified for 4.6. It does not cover the following, so every statement about them below is **UNVERIFIED for 4.7.2**:
- Mobile-renderer limits on particles, decals, per-object lights and glow.
- glTF importer support for Draco and `EXT_mesh_gpu_instancing`.

The reference does document these changes:
- Glow runs before tonemapping (4.6).
- The Shader Baker exists (4.5).
- SMAA is available (4.5).
- Stencil support exists (4.5).

---

## 1. Effect-by-effect: cheapest mobile technique

Legend for "Tool":
- **SH**: a shader on existing or simple geometry.
- **GPU-P / CPU-P**: GPUParticles3D / CPUParticles3D.
- **BL-M / BL-T**: Blender-baked mesh / Blender-baked texture.
- **DEC**: Decal.

General rule: emission plus Environment glow replaces real lights. No screen-texture reads (refraction or heat haze), no depth-texture reads, and no real transparency except where noted.

### 1.1 Lava flows and waterfalls
*Seen in*: mockup_01 Bridge Bashers river; 02 Bridge Dash and Summit Scramble; 07 Prehistoric Nest; 09 Pirate Plunder; 12 Meadow Mayhem; 16 Lava Escape island.

- **Tool**: BL-M ribbon plus SH. Small CPU-P at the impact point.
- **Mesh**: model each fall as a curved ribbon strip in Blender, 40-100 tris.
  - UV.y runs down the flow and UV.x across it.
  - Vertex colour alpha carries an edge fade (0 at the edges) and a "speed" factor.
  - One mesh library is shared by all biomes.
- **Shader**: `spatial_env_fall`, unshaded or Burley.
  - Scroll procedural bands along UV.y: two `vnoise` octaves at different speeds.
  - Add a bright foam lip at the top (UV.y < 0.1) and a widening at the bottom.
  - Lava variant: emissive orange-to-yellow ramp in the band cores, `EMISSION` > 1.0 so glow picks it up, dark crust flecks from the same noise.
  - Water variant: white/cyan bands on a `cap_color`-like tint, with a fresnel brighten.
  - Render it opaque with an alpha-scissor edge (`ALPHA_SCISSOR_THRESHOLD`), not alpha-blended. That avoids sort issues and overdraw.
- **Splash or steam at the base**: CPU-P, 12-16 particles, billboard quads, lifetime about 0.6 s, no collision.
  - Disable it via `visibility_range_end` when the camera is far, and under reduced-motion.
- **Cost**: 1 draw call per fall (MultiMesh several falls if they share a material), plus 1 per splash emitter.

### 1.2 Glowing cracks and frosted glass
*Seen in*: Rubble Rumble and Digging Frenzy lava cubes; Summit Scramble ice and lava pyramid; Avalanche ice; Chroma Sky Climb glass.

**Cracks: SH (already present in style 5).** Cheapen and improve it:
- Use a two-tone crack: yellow-white core for `v.x` < 0.03, orange to `glow_color` toward the edge, dark basalt plates. Today the crack is a single colour.
- Pulse the crack per cube with the existing `seed`. That part already exists.
- Optional cheaper path: bake a crack mask into a 256² `noise pack` texture (see 2.4). This replaces the per-pixel 3x3 Voronoi (27 hashes) with one sample.
- Needs Environment glow enabled. It is currently off (see 2.3).

**Frosted glass and ice: SH, opaque fake translucency. Do not alpha-blend MultiMesh cubes.**
- Godot sorts transparent objects per node, not per MultiMesh instance (UNVERIFIED for 4.7.2), so blended cubes in one MMI will mis-sort.
- The look is three cheap terms:
  - An inner "core" gradient: bright, saturated centre, already partly done via `face_edge`.
  - A frosted white rim band near `face_edge` > 0.42.
  - Fake interior parallax: offset the inner-pattern UV by `VIEW.xy * depth` on each face, so a crackle or bubble layer seems to sit inside the cube.
- Chroma Sky Climb's see-through glass bridge is the one place real alpha is justified. Use a separate non-MultiMesh material with `blend_mix` and `depth_draw_always`, cap it at about 20 visible cubes, and accept that intra-MMI sorting is imperfect.

### 1.3 Neon grid floors
*Seen in*: 06 Cosmic Gravity Goal hex arena; 13 Neon Maze; 14 Neon Splat; 17 Quantum Spire hex floor; 03 Frenzy Footholds.

- **Tool**: SH on one quad, or on the existing tile MultiMesh. No textures.
- **Square grid**: `abs(fract(uv) - 0.5)`.
- **Hex grid**: the standard two-offset hex-distance function, about 10 ALU ops.
- Anti-alias the lines with `fwidth()` so they do not shimmer on phones.
- Make lines emissive, with a slow `TIME` pulse travelling outward from a uniform `pulse_origin` (Quantum Spire's orange lit path). Unlit lines are the dark glass base colour.
- **Painted cells** (Neon Splat, mockup_14): do not use Decals. Use a low-res paint mask (64²-128² `ImageTexture`, R8) that gameplay writes cell colours into; the floor shader samples it once. Decals would cost per-pixel clustering for every splat and are count-limited on Mobile (UNVERIFIED for 4.7.2).
- **Cost**: 1 draw call. 1 texture sample, only with paint.

### 1.4 Galaxy cubes
*Seen in*: 02 Bridge Dash purple starry cube; 03 Frenzy Footholds; 10 Nebula; 17.

- **Current style 10** puts the nebula on the face (fbm-of-fbm, i.e. 6 noise evaluations) plus stars. The mockups read as a *window into space*: stars do not stick to the faces.
- **Tool**: SH plus one small BL-T.
  - Sample a 256² nebula texture (baked in Blender Cycles, or painted by art) with `SCREEN_UV * scale + center_offset`, so all galaxy cubes share one continuous sky "behind" them.
  - Or sample with `reflect(VIEW, NORMAL)` as a fake cubemap.
  - Keep the existing procedural `star4` twinkle on top.
- This removes the nested fbm (expensive) for one texture fetch. It is also the strongest visual match.
- This is a **deviation** from the shader header's "no texture samples" rule. It needs sign-off from the art director and lead programmer.

### 1.5 Explosions and confetti
*Seen in*: Fort Frenzy and Shatter Shootout (01/03), Fort Blast fireballs (02), Clockwork sparks (04/08), celebrations.

**Explosion** = flash + flipbook + debris + no light:
- **Flash**: one camera-facing additive quad, emissive, about 0.1 s. Fakes the light pop instead of an OmniLight3D.
- **Fireball/smoke**: BL-T flipbook, 4x4 frames in a 512² sheet (ASTC). Played by CPU-P with 3-6 particles using `ParticleProcessMaterial`/CPU flipbook animation. Rendered in Blender (Cycles smoke/fire sim, or hand-painted by art).
- **Debris**: reuse the existing CPU-driven `_fx` MultiMesh pool in `wt_stage.gd` (cap 120). Use the real cube mesh at small scale, tinted with the destroyed piece's colour. This needs a **low-poly cube** (see 2.1), not the 1,728-tri one.

**Confetti**:
- Already a 120-instance MultiMesh, 1 draw call. Keep it.
- For bigger party-end bursts, use GPU-P with up to 200 quads, a flat-colour unshaded material and no collision.
- Respect reduced motion. It already does.

### 1.6 Bubbles, sparkles and fire
**Bubbles** (Coral Conduit, Deep Sea, Submarine, Abyssal):
- Background bubbles already exist in `canvas_env_sky`.
- Foreground bubbles: GPU-P or CPU-P billboards, at most 40 alive.
- The ring look comes from a procedural shader (ring = `smoothstep` on `length(UV - 0.5)` plus a highlight dot), so no texture is needed.
- Rise with a slight sine wobble in the vertex.

**Sparkles** (ice, gems, stars on Rolling Rumble, crystals):
- CPU-P, 8-24 per emitter, star4 SDF on a quad, additive.
- On block faces, keep the existing in-shader sparkle (style 3 `sp`). It costs nothing.

**Fire** (torches, braziers, cannons, chimneys):
- SH on a two-quad cross mesh (BL-M, 4 tris).
- Use a scrolling `vnoise` mask times a teardrop gradient, emissive, with alpha-scissor or additive blending.
- Use a flipbook only for hero fires.
- **Smoke puffs** (Clockwork chimneys, Airship): CPU-P, 6-10 particles with a soft-circle procedural sprite, alpha blend, short lifetime.

**Lasers and beams** (Galactic Grab, Nebula, Magnetic Mash):
- A camera-aligned ribbon quad (or a 6-sided cylinder) with an additive emissive core gradient across UV.x.
- Add a sparkle CPU-P at the hit point.

### 1.7 Wobble and topple deformation
*Seen in*: Cake Stackers "Topple Risk"; Tumbling Towers; Jungle Giant "Stability".

- The real topple is physics (Jolt) and gameplay, which is not tech-art scope. The tech-art layer is a **visual jiggle in the vertex shader**.
- `INSTANCE_CUSTOM.r` (motif) and `.a` (cell fade) are used. **`.g` and `.b` are free.**
- Proposal:
  - `.g` = wobble amplitude (0-1), written per instance by the view from a gameplay-provided stability value.
  - `.b` = phase.
  - Vertex: shear `VERTEX.xz += wobble_dir * amp * (VERTEX.y + 0.5 + height_in_tower) * sin(TIME * freq + phase)`. Squash-and-stretch on landing goes through the same channel.
- Deforming in the vertex stage does not move the AABB. Set `extra_cull_margin` (or `custom_aabb`) on the MMI so cubes near the screen edge are not culled.
- No skeletons and no extra draw calls.

### 1.8 Rising lava plane
*Seen in*: Frenzy Footholds; Volcano Dash; Lava Rumble; Floor Is Lava `mg13`.

- **Tool**: SH on a `PlaneMesh`, subdivided about 24x24 (about 1.2k tris), sized to the island footprint plus margin. Rendered **opaque**.
- Height: set the node's `position.y` from gameplay, plus a **global shader uniform** `lava_level` so other shaders can react.
- Plane shader:
  - Two scrolling noise layers give dark crust plates over bright molten channels (emissive > 1 for glow).
  - A low-amplitude vertex wave.
  - A brighter band where the crust "breaks" over time.
- **Contact glow without a depth-texture read**: block, island and prop shaders add `glow_color * smoothstep(lava_level + 0.4, lava_level, world_y)` to `EMISSION`. That gives the "blocks being heated" rim from mockup 03 for 2 ALU ops.
- Embers: 1 CPU-P, at most 30 particles, rising slowly.
- No heat-haze `hint_screen_texture`. On Mobile it forces a screen copy, which is expensive on tile-based GPUs.

### 1.9 Water and ice surfaces
*Seen in*: Tumbling Towers, Kraken Keep (stormy sea), Bumper Battle (water cube with whirlpool), Coral Conduit, Glacier Gauntlet.

**Open water**: SH on a subdivided plane (16x16 to 32x32).
- Vertex: 2-3 summed Gerstner-lite sine waves. Storm intensity is a uniform (Kraken Keep).
- Fragment:
  - Two scrolling noise samples for normal perturbation, using the `noise pack` (2.4) or procedural `vnoise`.
  - Depth tint from a **baked shore-distance vertex colour**, not the depth texture.
  - A white foam band where the shore distance is near 0.
  - Fake sky reflection: `mix(water, sky_top_color, fresnel)`. There is no SSR on Mobile and no sky radiance here (see 2.3).
- **Whirlpool**: same shader in polar UV mode (`atan`/`length`), spiral scroll, darker toward the centre.
- **Water cube** (Bumper Battle): the plane plus 4 side quads that show the same bands, i.e. the ribbon shader from 1.1.
- **Underwater caustics** (Coral Conduit floor): in the island/tile shaders, add world-XZ caustic bands gated by `style == 4`. The block shader already has a caustic term.

**Ice surface**: opaque, low roughness, fresnel white rim, Voronoi crackle (style 3 already has it), and a fake reflection gradient. A real ReflectionProbe is not worth it on phones.

### 1.10 Boss tentacles
*Seen in*: Kraken Blockade (rainbow), Abyssal Kraken, Deep Sea, Kraken Keep, Tumbling Towers sea serpent.

- **Tool**: BL-M plus vertex-shader animation by default. Use a skeleton only for gameplay-attached grabs.
- Model one tentacle in Blender, 400-700 tris.
  - UV.y = 0 at the root to 1 at the tip. Vertex colour R = bend weight, increasing toward the tip.
  - Suckers can be modelled bumps, or a normal-free shader dot pattern on UV.
- Vertex shader: sinusoidal curl `rotate(VERTEX.xz, bend * sin(TIME * speed + phase + UV.y * k))` around the root axis. Optional `grab_target` uniform pulls the tip toward a point.
- Several tentacles go in one MultiMesh, with per-instance phase and tint in `INSTANCE_CUSTOM`: 1 draw call for all tentacles.
- Rainbow (Kraken Blockade): a hue ramp along UV.y. Orange spots from a cell-hash pattern.
- **Splash** where a tentacle meets the water: the waterfall ribbon shader in a ring shape, plus a CPU-P of about 16 particles.
- If a tentacle must hold a block (physics contact), switch that tentacle to a 6-8 bone chain (`Skeleton3D`, glTF skin) driven by animation. Budget: at most 2 skinned tentacles on screen.

---

## 2. Gaps: current shaders and builder vs mockups

### 2.1 Block shader (`spatial_block_biome.gdshader`)

| # | Gap | Evidence | Concrete change |
|---|---|---|---|
| B1 | **Bevel edges are darkened; the mockups highlight them** | Line 211 multiplies non-top edges by 0.82. Mockup cubes (01, 02, 03, 20) have a bright lit chamfer on top and light-facing edges. | Replace it with an edge term `e = smoothstep(0.40, 0.49, face_edge)`. Add `col += e * bevel_highlight * max(dot(world_normal, KEY_DIR), 0)` and darken only bottom edges. New uniforms `bevel_highlight` (0-0.6) and `key_dir` (or a global), values set per biome in `biome_looks.json`. |
| B2 | **Rim light is omnidirectional** | Line 235 adds fresnel x `rim` to EMISSION regardless of direction. In the mockups the rim is a top/back sky rim. | Weight the fresnel by `smoothstep(-0.2, 0.6, world_normal.y)` and tint it from a `rim_color` (sky top colour). Keep it in EMISSION; it is cheap. |
| B3 | **No AO / contact shadow between stacked cubes** | Mobile has no SSAO. Stacked cubes in every mockup show dark creases at contacts. | (a) **Per-instance neighbour bits**: pack 6 occupancy bits into `INSTANCE_CUSTOM.b` (or `.g` if wobble does not need both channels), written by the view. Darken a face's border where a neighbour touches: about 6 ALU ops. (b) **Bake bevel AO into the cube GLB's vertex colour** in Blender (Cycles bake to colour attribute). Needs a check that MultiMesh instance colour multiplies vertex colour in 4.7.2 (UNVERIFIED). |
| B4 | **`discard` on every pixel of every opaque block** | Line 73 runs the dither `discard` unconditionally. Even at `visibility * cell_alpha == 1.0`, the presence of `discard` disables early-Z / hidden-surface removal on tile-based phone GPUs (Mali, Adreno, Apple). | Split into two materials: a **discard-free** opaque variant for the bulk, and the dithered variant only for fading, occluded or ghosted instances. Use a `#define`-style second shader or a material swap per MMI. This is the biggest pure-performance win in the shader. |
| B5 | **Unit cube is 1,728 tris** | Measured in Blender. A 128-300-cube board is 0.22-0.52 M tris, roughly doubled by the shadow pass (`create_shadow_meshes=false`, key light casts shadows). | Ship a **board LOD cube** of 44 tris (single chamfer) to about 150 tris (2-segment bevel). B1 restores the look in the shader. Keep the 1,728-tri cube for UI previews and close-ups. Add a **12-tri shadow-only cube MMI** (`cast_shadow = SHADOWS_ONLY`) and set the visible MMI to `SHADOWS_OFF`. Multi-cell GLBs (`big_cube` etc.) keep the hidden interior faces of every sub-cube. Delete them in the export step. |
| B6 | **Glossy styles have nothing to reflect** | Env is `AMBIENT_SOURCE_COLOR` with `BG_CANVAS`, so there is no radiance. Ice (gloss 0.85), candy (0.85) and neon (0.75) look flat compared with the wet, shiny mockups. | Add a fake specular environment: `EMISSION += mix(horizon, sky_top, refl.y) * fres * gloss * k`, where `refl = reflect(-VIEW, NORMAL)` in world space and the sky colours are global uniforms fed from `biome_looks.json`.`sky`. |
| B7 | **Ice lacks a frosted rim and clear core** | Mockup 01/02 ice cubes: white frosty edge, saturated blue core, interior cracks. | Add frost band `smoothstep(0.38, 0.48, face_edge)` to white, plus interior parallax crackle (1.2). Line 112 `mix(..., 0.0)` is a no-op; remove it or give it a real cap value. |
| B8 | **Lava cracks are one colour** | Mockup lava cubes go yellow-white at the crack centre and orange at the edges. | Two-tone crack (1.2). Add a `lava_level` contact glow (1.8). |
| B9 | **Galaxy / neon cubes do not read as "windows" or "glass"** | 02, 03, 07 Wormhole, 10 Nebula. | Galaxy: screen-space nebula sample (1.4). Neon: brighter edge border plus fake inner back-edges via the parallax offset. Raise `glow` only once Environment glow is enabled (2.3). |
| B10 | Dead code | Line 189 `* 0.0` term; line 112. | Remove it. The compiler likely folds it, but it misleads tuning. |
| B11 | Cost of the heaviest styles | Celestial: 6 `vnoise` (fbm-of-fbm) plus star hash. Lava: Voronoi (27 hashes) plus fbm plus cap fbm. | Under budget for now on mid phones (UNMEASURED). If GPU time is over budget on the reference phone, move fbm/Voronoi to one `noise pack` sample (2.4). |

### 2.2 Island shader and builder (`spatial_env_island.gdshader`, `wt_island_builder.gd`)

| # | Gap | Evidence | Concrete change |
|---|---|---|---|
| I1 | **No waterfalls or lava falls off the island rim** | Mockups 02, 09, 12, 16 (Lava Escape), 07 Prehistoric. | Builder places 1-3 fall ribbons (1.1) at outline points chosen with the seeded `_rng`, per biome. Add a `falls: {kind, count}` key in `biome_looks.json` (water for meadow/forest/ice, lava for lava, sugar syrup for candy). |
| I2 | **No gears or machinery under the islands** | Party sheets: 16 Bomb Defuse (brass gears on the rim), 12 Cosmic Climb, 17 Quantum Spire (gears in the base housing), 04/07 airship gears. | BL-M gear (300-500 tris, brass, vertex colour) attached to the underside rings at 2-4 points. Rotate it by a vertex-shader `TIME` rotation around its local axis: no `_process` cost, 1 MMI for all gears. Enabled by a `under: ["gears"]` key per biome (clockwork, neon, celestial, carnival). |
| I3 | **Thin, uniform rim; no grass/snow overhang lip** | The rim band is a 0.45 ring (builder line 123). Mockup islands have a chunky grass slab with drips over the cliff (01, 12, 20). | Extrude a 0.25-0.35 lip ring slightly *outside* the outline. Reuse the block shader's cap-drip function on the island side faces: drips of grass, snow or icing. |
| I4 | **No hanging roots, vines or crystals under the island** | Mockups 01, 20 (vines), 14 Gem Grab (crystals), 16 (rocky tips). | 2-5 BL-M dangling props (100-300 tris) per island from a per-biome list, via one MultiMesh. |
| I5 | **`atan` seam in the strata** | Line 37/41: `atan(wp.z, wp.x)` jumps at ±π, which leaves a visible vertical seam in the noise on one side. | Use `wp.x`/`wp.z` triplanar-lite (a blend of two planar fbm by `abs(normal.x)`) or `sin`/`cos` of the angle as 2D input. |
| I6 | **`cull_disabled` on a closed mesh** | Shader line 5. The island is a large closed mesh, so back faces are rasterised for nothing (overdraw). | Fix the winding in `_tri`/`_quad` and the tip fan in the builder, then drop `cull_disabled`. |
| I7 | **No rim light or top-edge highlight on the island** | Mockup island tops catch a bright edge where the grass meets the cliff. | Add a highlight band on the first ring (vertex colour alpha marks the lip) and the same directional rim as B2. |
| I8 | **Dressing is a draw-call explosion** | Every tuft (3 nodes), flower (6), ball and cyl creates its own `MeshInstance3D` and **its own new `StandardMaterial3D`** (`_flat()`), so nothing can batch or instance. Estimated (not profiled) for a 6x6 board: about 19 accepted items, about 70-80 MeshInstance3D, all casting shadows, so about 150 draws in colour plus shadow passes. | Bake every prop kind in Blender to a GLB with vertex colours and **one shared material** (vertex colour albedo, or a 256x16 palette texture). Spawn each kind via **one MultiMesh per kind**: about 6-10 draws total. Set dressing `cast_shadow = OFF`; small props read fine with a baked contact-AO vertex colour at their base. |
| I9 | Tile grid border is a flat `BoxMesh` | Mockups use stone plaza tiles with a bevel and a light top edge. | The tile MMI can use the board-LOD cube (B5) with a `style`-aware tile shader (grout AO plus edge highlight). Still 1 draw. |

### 2.3 Sky and environment (`canvas_env_sky.gdshader`, `wt_stage.gd` `_build_light`)

| # | Gap or cost | Concrete change |
|---|---|---|
| S1 | **Full-screen per-pixel cost** | Every pixel evaluates 5 island SDFs, a 4-octave fbm, a star hash and the **bubble cell math even when `bubbles == 0`** (multiplied by 0, still computed). At phone resolution (~2.5 M px) this is a meaningful fill cost. **Cheapest**: bake the static sky (gradient, islands, stars) once per biome to a 512x1024 texture (Godot `SubViewport` render-once at load, or offline), and keep only a cloud UV-scroll layer live. **Minimum**: wrap stars in `if (night > 0.0)` and bubbles in `if (bubbles > 0.0)`. These are uniform branches, so they are coherent and cheap. |
| S2 | **No glow** | `Environment` has no glow, so all `EMISSION` (lava 1.4, neon 1.6, celestial 1.2) only brightens and never blooms. The mockups bloom heavily on lava, neon, crystals and lasers. Enable glow on Mobile with 2-3 levels and an HDR threshold near 1.0, so only emission above 1 blooms. Since 4.6, glow runs **before tonemapping** (engine-reference). Retune intensity after the switch. **Art director sets the look.** |
| S3 | **Tonemapper is Linear** | The mockups are saturated with soft highlight roll-off. Whether to move to Filmic or AgX is an **art-director decision**. Tech-art can supply A/B captures. |
| S4 | **No sky radiance for reflections** | See B6. Feed the `sky` triplet from `biome_looks.json` into global shader uniforms (`wt_sky_top`, `wt_sky_horizon`) so blocks, water, ice and the island can fake reflections consistently. |

### 2.4 Proposed shared asset: `noise pack` (deviation, needs sign-off)

- One 256² RGBA tileable texture, ASTC 4x4, about 64 KB:
  - **R** = value-noise fbm
  - **G** = Voronoi border distance
  - **B** = caustic bands
  - **A** = flow/streak noise
- Baked in Blender (Cycles texture bake) or a small Godot tool script.
- One sample replaces 9-27 hash evaluations.
- This reverses the current "no texture samples" rule in the shader headers. Use it only where profiling on the reference phone shows the procedural version is over budget.

---

## 3. Blender 5.2 pipeline

Binary: `/tmp/claude-0/blender/blender-5.2.2-linux-x64/blender` (5.2.2 LTS, verified).
Proposed home for scripts: `tools/asset-pipeline/blender/` (the existing tool root). Invocation pattern:

```
blender -b --factory-startup -P tools/asset-pipeline/blender/<script>.py -- --spec <json> --out <dir>
```

### 3.1 Headless script plan

| Script | Job | Notes |
|---|---|---|
| `wt_bpy_common.py` | Shared helpers. | Factory reset; an **orthographic camera matching the game's 3/4 board view** (pitch about -52°, matching the key light in `wt_stage.gd`); a 3-point light rig; Colour Management `view_transform = 'Standard'` so renders match Godot's Linear tonemap (factory default is AgX, which desaturates); render engine pick. |
| `render_ninepatch.py` | UI panels: wood frames, parchment cards, gold-gear timer, ribbon banners, "Next Block" cards, score plaques (mockups 12-14, 20). | Builds the panel procedurally from a JSON spec: size, corner radius, frame depth, bevel, material preset `wood` / `parchment` / `brass` / `glass`. Renders at **4x**, then downsamples with `bpy` `Image.scale` to 2x of the 720-px design canvas. The **stretch regions must be flat** in the stretch axis; tileable wood grain uses `axis_stretch = TILE_FIT`. Writes `ui_<name>_9p.png` plus a sidecar `ui_<name>_9p.json` with `patch_margin_{left,top,right,bottom}` for `NinePatchRect` / `StyleBoxTexture`. Transparent film, straight alpha. |
| `render_icons.py` | "Next Block / Next Item / Power-up" icons, block-set swatches (mockup 20). | Imports each GLB, frames it by bounding box, renders 256² transparent with the same camera and lights for consistency, and assembles a 2048² atlas plus an atlas JSON. |
| `export_assets.py` | Source `.blend` to GLB. | One collection = one asset. Applies the settings in 3.2. Deletes interior faces of multi-cell blocks (`bmesh` dissolve of faces shared by two cells). Writes a per-asset **observation report** (tri count, material count, texture sizes, names matching import suffixes). Per project rule, it reports and does not judge. |
| `bake_vertex_ao.py` | Contact and bevel AO into vertex colour (B3, I8). | Cycles bake `type='AO'` to a colour attribute, multiplied into the `Color` attribute. Godot `light_baking=0` means there is no UV2 or lightmap, so AO has to live in the vertex colour. |
| `bake_textures.py` | Noise pack (2.4), galaxy nebula (1.4), fire/explosion flipbooks (1.5). | Cycles CPU. Flipbooks are a 4x4 grid, 512², transparent. |

**Engine choice (verified on this machine 2026-10-13)**:
- `render.engine = 'CYCLES'` with `cycles.device = 'CPU'` renders headless.
- `BLENDER_EEVEE` and Workbench abort with `Couldn't open libEGL.so.1`.
- Use Cycles with 32-64 samples and the OpenImageDenoise denoiser for UI and icons. Small images make it fast enough.
- Use absolute output paths. `//` has no base without a saved `.blend`; that failed in testing.

### 3.2 GLB export settings (property names verified in 5.2.2's `export_scene.gltf`)

```python
bpy.ops.export_scene.gltf(
    filepath=out, export_format='GLB',
    use_active_collection=True,           # or use_selection=True per asset
    export_yup=True,                      # Godot is +Y up
    export_apply=True,                    # bake modifiers (bevel, mirror, array)
    export_normals=True,
    export_tangents=False,                # no normal maps; Godot's import already has ensure_tangents=true
    export_texcoords=True,
    export_vertex_color='ACTIVE',         # IMPORTANT: default 'MATERIAL' drops COLOR on material-less meshes,
    export_all_vertex_colors=False,       #   and our shaders read COLOR (blocks, island, props)
    export_materials='NONE',              # blocks/props use material_override in Godot; 'EXPORT' only for textured assets
    export_image_format='AUTO',           # PNG; never JPEG (Godot recompresses to ASTC/ETC2: double-lossy)
    export_extras=True,                   # block_post_import.gd keeps glTF extras as meta "extras"
    export_cameras=False, export_lights=False,
    export_animations=False,              # True only for animated assets (bosses, gears if not shader-rotated)
    export_skins=False,                   # True only for skinned bosses/tentacles
    export_morph=False,
    export_draco_mesh_compression_enable=False,  # Godot glTF import support for Draco: UNVERIFIED, assume none
    export_gpu_instances=False,           # EXT_mesh_gpu_instancing support in Godot 4.7.2: UNVERIFIED
)
```

**How this matches `project.godot` `[importer_defaults] scene`**:

| Godot import default | Consequence for Blender authoring |
|---|---|
| `meshes/generate_lods=false` | No automatic LODs. **The authored tri count is the shipped tri count.** Hit the budget in Blender. If an asset needs LODs, author `_lod1` as a separate mesh and switch with `visibility_range_begin/end`. |
| `meshes/create_shadow_meshes=false` | The full mesh is rendered in the shadow pass. For assets over 1k tris, author a low-poly `*_shadowproxy` and mark it in glTF extras for a future post-import rule. The post-import script would need a change, which belongs to the engine or tools programmer. Otherwise set `cast_shadow = OFF` on small dressing. |
| `meshes/light_baking=0` | No lightmaps, so do not spend a UV2 channel. Bake AO into vertex colour instead. |
| `import_script/path = block_post_import.gd` | Files under `res://assets/models/blocks/` must have **exactly one root child** (the piece empty, or the cube mesh), or the wrapper is not stripped. |
| `nodes/use_name_suffixes=true` (per-file default seen in `.import`) | **Never** end object names in Godot suffixes (`-col`, `-colonly`, `-convcol`, `-noimp`, `-rigid`, `-vehicle`, `-wheel`, `-navmesh`, `-occ`, `-occonly`) unless the behaviour is wanted. The export report should list any matches. |

- **Units and pivots**: 1 grid cell = 1 m. Block pivots are at the cube centre (existing). Props and islands have their pivot at bottom-centre.
- **Naming**: `blk_<set>_<shape>.glb` (existing), `prop_<biome>_<name>.glb`, `boss_<name>.glb`, `fx_<name>_flipbook.png`, `ui_<name>_9p.png`, `icon_<name>.png`. All snake_case per `project.yaml`.

### 3.3 Per-asset triangle and texture budget (PROPOSED)

| Asset class | Tris | Textures | Notes |
|---|---|---|---|
| Block cube, **board LOD** (MultiMesh) | 44-150 | none (procedural shader) | Replaces the 1,728-tri cube on the board (B5). |
| Block cube, shadow proxy | 12 | none | `SHADOWS_ONLY` MMI. |
| Block cube, preview/hero | ≤1,728 (current) | none | UI previews, title island. |
| Multi-cell block GLB | cells x LOD cube, **interior faces removed** | none | Today `giant_mega_cube` is 46,656 tris. |
| Small prop (bush, rock, crystal, mushroom, gear, tuft) | 60-400 | none: vertex colour plus shared palette 256x16 | One shared material, MultiMesh per kind. |
| Medium prop (catapult, cannon, cart, totem, chest) | 600-1,500 | shared 512² atlas, ASTC 6x6 | |
| Hero set piece (airship, castle, factory core, conveyor) | 2,500-6,000 | 1024² atlas, ASTC 6x6 | At most 1-2 per scene. |
| Island base per biome (incl. lip, falls, gears) | 2,000-4,000 | none (procedural) | Current mesh: 72-pt outline x 7 rings, about 1.1k tris. |
| Fall/flow ribbon | 40-100 | none | |
| Tentacle (vertex-animated) | 400-700 each | none, or 256² gradient | MMI for all tentacles. |
| Boss total (body plus tentacles) | 5,000-8,000 | 1024² atlas | At most 30 bones if skinned. |
| Party character (if 3D) | 2,500-4,000 | 512² atlas, ASTC 6x6 | At most 4-8 on screen. |
| VFX flipbook | n/a (quads) | 512² (4x4 frames), ASTC 4x4 for alpha quality | |
| Sparkle/bubble/fire sprite | n/a | none (procedural) or 64² | |
| Noise pack / nebula | n/a | 256² each, ASTC 4x4 | Shared project-wide. |
| UI nine-patch | n/a | source at 2x of the 720 canvas: 128-256 px per panel | Packed per screen into a 2048² atlas. |
| UI icon | n/a | 256² source, packed into a 2048² atlas | Displays at about 96-128 px. |

**Texture memory, PROPOSED**: at most 48 MB VRAM for the 3D scene plus at most 16 MB for UI per minigame scene. ASTC on phones (`import_etc2_astc=true` is already on).

---

## 4. Performance budget per minigame scene (PROPOSED, 60 fps / 16.6 ms on the reference phone)

**Global caps for every minigame scene**:

| Category | Cap | How it is met |
|---|---|---|
| Draw calls, 3D colour pass | ≤ 60 | Block MMIs (one per material variant), tiles 1, island 1, dressing ≤ 10 (I8), VFX ≤ 10, set pieces ≤ 10 |
| Draw calls, shadow pass | ≤ 20 | Shadow-proxy cube MMI; dressing and VFX cast no shadows |
| Draw calls, UI canvas | ≤ 40 batches | Atlas-packed nine-patches and icons |
| Triangles on screen (colour plus shadow) | ≤ 300k | Board LOD cube (B5) is the main lever: about 0.5-1 M down to about 50-100k |
| Live particles | ≤ 400 total, ≤ 150 per emitter, ≤ 6 active emitters | CPU-P under 32 particles; GPU-P only for big bursts |
| VFX overdraw | ≤ 2.5x average on the VFX screen area | Opaque/alpha-scissor where possible; additive quads stay small |
| Lights | 1 DirectionalLight3D with shadows plus 1 fill directional without shadows (current setup), **0-2 OmniLight3D, no shadows** | Emission plus glow replaces point lights. Mobile per-object light limits are UNVERIFIED for 4.7.2 |
| Shadows | 1 orthogonal directional, `directional_shadow_max_distance` ≈ board extent (currently 45, tighten to about 20-25) | Better texel density and fewer casters |
| Post | Glow 2-3 levels; no SSAO/SSR/SSIL/volumetric fog (not on Mobile); FXAA or SMAA 1x | SMAA per engine-reference 4.5 |

**Per-scene archetypes** (each minigame maps to one):

| Archetype (mockups) | Draw calls 3D (colour / shadow) | Particles (alive max) | Lights | Signature cost to watch |
|---|---|---|---|---|
| **Meadow/bridge race**: Bridge Bashers, Bridge Dash, Jungle Bridge Rush, Meadow Mayhem | 45 / 15 | 60 (2 fall splashes, sparkles) | Dir + fill | 2-3 fall ribbons; dressing batching |
| **Lava rise**: Floor Is Lava `mg13`, Frenzy Footholds, Volcano Dash, Lava Rumble, Lava Escape | 45 / 15 | 120 (embers 30, splashes, crack sparks) | Dir + fill + ≤1 omni (optional) | Lava plane ALU, glow, `lava_level` contact glow on all blocks |
| **Ice/avalanche**: Avalanche Ascent, Glacier Gauntlet, Summit Scramble | 50 / 18 | 150 (snow 80, sparkles, rolling-boulder debris) | Dir + fill | Ice fake reflections; snow particles kept small |
| **Destruction**: Fort Frenzy, Fort Blast, Shatter Shootout, Boss Bash | 55 / 20 | 300 (debris MMI 120, flipbooks 3x6, sparks) | Dir + fill | Flipbook overdraw; debris uses LOD cube |
| **Water/boss**: Kraken Blockade, Kraken Keep, Abyssal Kraken, Tumbling Towers, Bumper Battle | 55 / 18 | 120 (splash rings, rain 60 in Keep) | Dir + fill | Water plane plus tentacle MMI; storm rain as one GPU-P |
| **Underwater**: Coral Conduit, Deep Sea Bubble Build, Submarine Salvage | 50 / 12 | 100 (bubbles 40, caustic motes) | Dir + fill + ≤2 omni (sub lamps) | Caustics in shaders; jellyfish emissive, not lights |
| **Neon/space arena**: Cosmic Gravity Goal, Neon Maze, Neon Splat, Wormhole, Nebula Laser Hack, Galactic Grab, Quantum Spire, Magnetic Mash | 55 / 12 | 150 (sparks, beam hits) | Dir + fill | Glow plus emissive grid; galaxy texture; paint mask; holo panels opaque-additive |
| **Clockwork/factory**: Clockwork Conveyor, Clockwork Chaos, Factory Frenzy, Steampunk Gear-Up, Airship | 55 / 20 | 120 (sparks 40, smoke 3x10) | Dir + fill + ≤1 omni (furnace) | Shader-rotated gears, 1 MMI; conveyor belt UV scroll |
| **Candy/cake topple**: Cake Stackers, Sugar Rush Stack, Candy Climb, Sweet Rush Rails | 45 / 15 | 200 (sprinkles/confetti) | Dir + fill | Vertex wobble (1.7) and custom AABB margin |
| **Celebration / results overlay** | +5 | +200 confetti (existing MMI 120, GPU-P for more) | n/a | Disabled under reduced motion (already) |

---

## 5. Decisions needed (not tech-art's call)

1. **Art director**:
   - Glow intensity and threshold (S2).
   - Tonemapper Linear vs Filmic vs AgX (S3).
   - Bevel-highlight and rim colours per biome (B1/B2).
   - The galaxy nebula image (1.4).
   - Flipbook art style (1.5).
2. **Lead programmer / technical director**:
   - Allowing texture samples (noise pack, nebula, paint mask) against the shaders' "no texture samples" rule (2.4).
   - The discard-free material split (B4).
   - Use of the free `INSTANCE_CUSTOM.g/.b` channels (1.7, B3).
   - A `*_shadowproxy` rule in `block_post_import.gd` (3.2).
3. **Gameplay programmer**:
   - Exposes `lava_level`, stability/wobble per piece, and the paint-cell mask as view inputs. Tech-art does not touch gameplay code.
4. **Producer / technical director**:
   - Choose the **reference phone**. Every number in sections 3.3 and 4 then gets confirmed or replaced in `technical-preferences.md`.
