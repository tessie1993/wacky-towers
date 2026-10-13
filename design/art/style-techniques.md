# Wacky Towers: Style Techniques Cookbook

Version 1 · 2026-10-13 · Art-direction R&D. **Companion to `design/art/art-bible.md` (v2).** The bible
says *what* the game looks like. This document says *how to build it* in our stack (Godot 4.7.2,
Blender 5.2.2, GDScript). Every art agent (UI kit, blocks, islands, characters) follows it.

- Proof code: `prototypes/style_rnd/` (throwaway; rewrite to production standards, never import it).
- Proof screenshots: `production/qa/evidence/style-rnd/` (each one side by side with its reference).
- Where this document and a reference image disagree, the **reference wins**. Where this document and
  the bible disagree on a technique, **this document wins** (it was tested). Raise any conflict with the
  art director.

---

## 0. What we looked at

All 60 unique user uploads were deduplicated by hash and reviewed: 48 are already in
`assets/art/reference/` (15 style boards, 37 minigame mockups, older sheets) and 12 are new. Four of the
new ones show Nintendo characters (party-mode boards, a "Party Tour" iPad board, a minigame grid). We
used them **only** for layout, camera and block look. No character, logo or prop from them is
reproduced anywhere.

One upload (`e4c27051`) is a screenshot of the current game (flat vector mouse and wizard on cream)
with a **red X over it**. Read that as the user's verdict: the flat clip-art look is rejected. Every
recipe below exists to get away from it.

---

## 1. The style, broken down

### 1.1 Rendering
| Trait | What the references do | Consequence for us |
|---|---|---|
| Shading | Soft painted form shading: broad light plane, broad shade plane, soft terminator. **Shadows are tinted** (purple/blue), never grey or black | Custom `light()`: wrap + soft 2-tone ramp + tinted shadow (§3.3) |
| Light direction | Key light from **upper-left**, warm (golden hour). Cool sky fill from the right. Warm back/rim on silhouettes | Shared rig, camera-relative (§2.2) |
| Rim light | Thin warm rim on tops and silhouettes; strong on glassy blocks | Fresnel rim gated by N·L |
| AO | Painted, art-directed: dark under overhangs (grass lip, frame lips), darker block bottoms, contact shadow on boards | Bake AO into albedo (Blender) or fake it in shader by local height |
| Edge highlight | Every bevel has a **lit top edge** (wood planks, gold, blocks, stones) | Blender: bevel-normal mask into albedo. Godot: edge mask in shader |
| Glow | Only on emissives and sparkles: gold stars, magic, lava, neon, celestial stars, UI "selected" state | Glow threshold ~1.0 HDR, soft-light blend |
| Grading | Saturated, warm mid-tones, lifted shadows, no crushed blacks | AgX + saturation 1.18–1.28 |
| Outlines | **None** on 3D. UI text has a thick plum outline (`#3b2346`) | No inverted-hull outlines on 3D |
| Texture style | Hand-painted: low-frequency colour variation, a few strokes, chunky detail (pebbles, grain, cracks). No photo noise, no micro detail | Procedural fbm at low frequency or painted 512 px maps |
| Detail level | Big readable shapes first; detail lives on rims and props, never on the play grid | Keep tiles quiet, dress the rim |

### 1.2 Materials per family
| Family | Look (refs) | Key ingredients |
|---|---|---|
| **Wood, purple** (frames) | `#6b4a8a` planks, darker grain lines, lighter lit edge, matte | Wave bands + fine dark grain lines + bevel-edge light + AO. Roughness 0.7. Never glossy |
| **Wood, brown** (signs, sliders, panels) | `#8a5a34`, horizontal grain, carved letter recesses | Same recipe, brown ramp `#4e2f1a → #8a5a34 → #c08a5a` |
| **Parchment** | Cream `#f6e7c4`, burnt edge `#e2c995 → #b98a55`, very soft noise | Distance-to-edge ramp + low noise. Matte (0.85) |
| **Gold** | `#f8c840` face, `#c98418` lip, `#fff3b0` glint, tiny bloom | Metallic 1, roughness 0.22, bevel-edge glint, slight emission so it blooms |
| **Grass** | Thick overhanging cap, ragged hanging strands, lighter tufts on top, clover, white flowers | Cap mask + ragged edge + vertex swell (§3) |
| **Dirt** | Warm brown `#9a6e4a`, 2–3 strata bands, round light pebbles | fbm + strata + pebble dots |
| **Stone tiles** | Warm grey `#bdb2a2`, rounded, soft mottling, dark grout gap | Rounded box 0.96, painted mottle, edge light |
| **Ice** | Translucent pale blue, frosted, white snow cap with icicles, inner sparkles | Fresnel-heavy, inner "depth" parallax, snow cap mask (cap colour white) |
| **Jelly / candy** | Saturated pink/orange, translucent glow from inside, glossy highlight blobs, frosting drips | Inner glow = `1 - face_edge` mix, gloss 0.8, frosting cap with drip |
| **Lava** | Dark basalt with glowing orange cracks | Voronoi cracks into EMISSION (>1.0 so it blooms) |
| **Galaxy** (celestial) | Deep purple with nebula swirl and gold 4-point stars | Screen/triplanar nebula fbm + star sprites, emissive stars |
| **Metal** (clockwork, frame caps) | Dark iron or brass with gold rivets | Metallic 0.85, roughness 0.35, edge light |
| **Crystals** | Faceted purple/cyan, bright inner glow, hard spec | Flat-shaded facets, emission 0.3–0.6, rim |

### 1.3 UI construction (refs 03–08, 14, 15)
- **Frames**: thick purple planks, top/bottom planks overrun the side posts, **iron corner caps with a
  gold star and 4 gold rivets**, vines with leaves and white 5-petal blossoms wrapping 2 opposite
  corners, a dark inner lip, parchment or wood interior. Settings variant adds **rope** borders.
- **Title plaque**: purple-wood scroll, gold curls, **multicolour chunky letters** (orange, cream,
  blue, green, lilac, pink), each with a thick plum outline, a darker extrusion, a lit top and a slight
  wobble.
- **Buttons**: glossy gold pill, thick `#c98418` lip under it, white specular streak, star icon on the
  left, plum ALL-CAPS label. Secondary = cream or wood pill. Close = red gem with gold rim.
- **HUD chips** (ref 15): parchment card in a **thin biome-tinted frame** (vine green, ice blue,
  celestial purple), label on top, big number, star row. Pause = small parchment square.
- **Tray**: 3-slot parchment shelf in the biome frame, each slot shows a 3D render of the piece.
- **Ornaments**: vines, blossoms, gold stars, rivets, rope, gears (settings), wizard hat. Always on
  corners and edges, never over content.

### 1.4 Characters (wizard turnaround, refs 01, 02, 07, 14)
- About 2.5 heads tall. The head plus hat is about 55% of the height. Hands are big, feet are small stubs.
- Faces: small glossy black oval eyes with one big and one small catch-light, big round pink nose, rosy
  cheeks, closed-eye smile for "cheer".
- Beard: a huge, soft, sculpted mass with 3–5 big curl lobes and a spiral at the tip. It reads as one
  shape, never strands.
- Cloth: thick, felt-like and soft, with a few big folds, a cream trim band, star motifs and a matte
  velvet sheen on the hat.
- The wizard sits on a cloud: puffy spheres with spiral swirls, white with lilac shade.

### 1.5 Environment (refs 15, 09–12, biome sheets)
- **Island silhouette**: a square-ish slab that follows the board. A thick biome cap overhangs the
  edge (grass, snow or marble). Under it sit 2–3 **stepped rock ledges** made of chunky blocks, each band a
  little inset, tapering to a rough point. Roots, icicles or crystals hang from it.
- **Rim dressing**: flowers, clover, bushes and grass tufts (meadow); frost trees and snow shrubs (ice);
  broken pillars, gold inlay and arches (celestial). It stays in the ring between the board and the island
  edge.
- **Background**: a painted sky gradient (blue top, warm/pale horizon) and a soft cloud sea at the
  bottom. Behind that, **3–6 distant floating islands** with landmarks (waterfall, castle, mountains)
  fade into haze.
- **Atmosphere**: aerial perspective (far = paler, bluer, lower contrast), sparkles, and light shafts in
  interiors.

### 1.6 Composition and camera
- Gameplay: an **isometric-ish 3/4 view**. The board is rotated 45° (a diamond) and seen from about
  40° above. A narrow FOV (35–42°) keeps it toy-like with little distortion.
- On a portrait phone the island fills about 75–85% of the width, centred slightly above the
  middle. The HUD wraps it: the pause, SCORE and NEXT chips sit in the top 15%, the 3-slot tray in the
  bottom 18%, and a biome frame runs around the whole screen edge. Nothing overlaps the board.
- Menus are **framed panels over a blurred painted room** (the wizard's library) with ornaments
  breaking the frame edge (the wizard peeking in, the close gem on the corner).

---

## 2. Shared foundations: every scene uses these

### 2.1 Godot environment preset (`WorldEnvironment`)
Proven under Compatibility (opengl3, llvmpipe). Reference implementation:
`prototypes/style_rnd/style_kit.gd::make_environment()`.

| Setting | Value | Why |
|---|---|---|
| `background_mode` | `BG_CANVAS`, `background_canvas_max_layer = -1` | Painted 2D backdrop behind 3D (§5.4). **Not `BG_SKY`**: see 2.4 |
| `ambient_light_source` | `AMBIENT_SOURCE_COLOR` | Deterministic, identical on all renderers |
| `ambient_light_color / energy` | meadow `#c9c3e6` / 0.42 · ice `#c4d2f2` / 0.5 · celestial `#6a5a9e` / 0.5 | Lilac ambient = tinted shadows |
| `reflected_light_source` | `REFLECTION_SOURCE_DISABLED` | Fake reflections live in shaders |
| `tonemap_mode` | **`TONE_MAPPER_AGX`**, exposure 1.0, white 6.0 | Best match in the tonemap test. Linear/ACES clip the background and turn the grass neon |
| `glow_enabled` | true · intensity 0.55 · strength 1.0 · bloom 0.04 · hdr_threshold 0.95 · blend `SOFTLIGHT` · levels 0,0,1,1,0.6 | Only emissives and gold glints bloom |
| `fog_enabled` | **false** | See 2.4. Use per-material haze |
| `adjustment_enabled` | true · saturation meadow 1.28 / ice 1.18 / celestial 1.25 · contrast 1.04–1.08 · brightness 1.0–1.03 | AgX desaturates, so this puts the "premium mobile" punch back |
| SSAO, SSR, SSIL, SDFGI, volumetric fog | **off** | Not available in Compatibility and/or Mobile. Bake AO into albedo instead |

### 2.2 Shared light rig (3 directional lights, camera-relative)
`style_kit.gd::add_light_rig(parent, biome, cam_yaw_deg)`, where
`cam_yaw_deg = rad_to_deg(atan2(cam.x - target.x, cam.z - target.z))`. Angles are relative to the
camera, so **on screen the light always comes from the upper left**, whatever the camera does.

| Light | rotation_degrees (x, y) | Colour / energy (meadow) | Shadows |
|---|---|---|---|
| **Key** (warm sun) | (-50, cam_yaw − 75) | `#fff0d6` / 0.9 | on, ORTHOGONAL, opacity 0.7, blur 1.5, bias 0.08, normal bias 2.5, max dist 40 |
| **Fill** (cool sky) | (-20, cam_yaw + 105) | `#b8c4ff` / 0.2 | off |
| **Back / rim** (warm) | (-20, cam_yaw + 190) | `#ffe0a8` / 0.3 | off |

Ice: key `#f2f6ff`/0.95, fill `#a9c8ff`/0.3, back `#e8d8ff`/0.3. Celestial (night): key `#e9dcff`/0.85, fill
`#8a7cff`/0.35, back `#ffd890`/0.45. Biome presets change **only** the colours, energies and grade,
never the angles.

**Calibration target** (sRGB, measured in `a_block_compat.png`): ground parchment ≈ (247, 237, 222),
lit grass top ≈ (161, 207, 99), lit dirt ≈ (180, 113, 63), shade dirt ≈ (122, 67, 37). That is a
**shade-to-lit ratio of about 0.65–0.7**. If a new scene's numbers drift far from these, fix the scene,
not the preset.

> `LIGHT_COLOR` in a Godot 4 `light()` function already includes energy × π, so divide by `PI` as the
> built-in Lambert does. Our first pass forgot this and every surface clipped to white.

### 2.3 Blender rig for renders (UI pieces, portraits, piece icons)
Same direction language as in-game: key from the upper-left front. From
`blender_frame_ninepatch.py`:
- Key: area light at (-2.5, 3.0, 4.0), **520 W**, colour (1.0, 0.90, 0.76), size 3.0
- Fill: area light at (3.0, -1.0, 3.0), **140 W**, colour (0.72, 0.80, 1.0), size 4.0
- Rim: area light at (0, 4, 1), **160 W**, colour (1.0, 0.95, 0.85), size 2.0
- World: `#e8dcff` at strength 0.25
- Camera: orthographic for UI (`ortho_scale` = asset width + margin); 35 mm at 3/4 for portraits and icons
- Cycles CPU, 48 samples, OIDN denoise, film transparent, PNG RGBA
- **Colour management: View Transform = `Standard`, Look = None.** AgX/Filmic in Blender would shift
  the palette hexes. Convert hex to linear before typing it into a colour socket (`hexc()` in the script).

### 2.4 Renderer facts that shape every recipe
| Feature | Compatibility (CI, screenshots, low-end) | Mobile (`project.godot` default) | Forward+ (desktop) |
|---|---|---|---|
| Glow, tonemap (incl. AgX), adjustments | yes | yes | yes |
| Custom `light()` in spatial shaders | yes (proven) | yes | yes |
| Directional shadows | yes (proven) | yes | yes |
| SSAO | yes | **no** | yes |
| FXAA / DOF | **no** | yes | yes |
| SSR / SSIL / SDFGI / volumetric fog | no | no | yes |
| Compositor effects | no | (RD only) | yes |
| MSAA 3D | yes | yes | yes |

**Found in this R&D (Compatibility):**
1. **Sky shaders are unreliable for a painted backdrop.** A `SCREEN_UV` gradient in a sky shader had no
   effect: the visible sky was the radiance-cubemap colour for the view direction, so a camera looking
   down saw only the "low" colour (grey after grading). Use `BG_CANVAS` and a 2D backdrop instead.
2. **Global fog also tints the background colour or canvas** even with `fog_sky_affect = 0`, and
   exponential fog hazes the board. Keep global fog off. Distant props write `FOG = vec4(haze_color, haze)`
   in their own shader.

Rule: **anything that must look the same on all three renderers is done in our own shaders or baked into
textures, never in renderer-only post effects.** Forward+ extras (SSAO, SSR) are bonuses, never
requirements.

---

## 3. Blocks (gameplay cubes, ref 13 is law)

### 3.1 Mesh
- Rounded box: unit cube, **radius 0.12–0.13**, 12–14 segments per face edge with samples clustered
  near the edges. Generated procedurally (`style_kit.gd::rounded_box`) or modelled in Blender (Cube +
  Bevel modifier, width 0.13, segments 4, then export GLB). The game scale is 0.97–0.98 per cell, which
  leaves a hairline gap that reads as two pieces.
- **Godot winding is clockwise for front faces.** A procedural mesh must satisfy
  `cross(p1 − p0, p2 − p0) · outward < 0`. We lost a pass to culled faces.
- Toppers (sprout, clover, flower, crystal, star, heart, ticket, gear) are **separate instanced
  meshes** on about 1 in 4 top-exposed cubes, never on every cube (ref 15).
- Grass/snow/frosting **cap overhang** is vertex-displaced in the shader (swell the top band outward
  with noise). For hero shots, add 6–10 tuft cards or blobs on the cap rim (see gaps, §9).

### 3.2 Material recipe (shader `spatial_proto_painted_block.gdshader`)
Albedo layers, bottom to top:
1. **Body paint**: `mix(body_dark, body_color, smoothstep(.25,.75,fbm(uv*3)))`, i.e. low-frequency
   fbm, 3 octaves.
2. **Strata** (dirt, rock): `fract(p.y*2.6 + paint*0.5)` banding at ±7%.
3. **Pebbles / motifs**: hashed circle cells, lit top-left, dark contact ring.
4. **Cap mask**: `smoothstep(cap_y - drip ± 0.012, p.y)`, where `drip` is fine strands (`vn(around*28)`)
   plus big lobes (`fbm(around*5)`). It is mixed toward the cap colours with lighter tufts where
   `normal.y` is high.
5. **Under-cap contact line**: a dark 6% band just below the drip, which is the painted AO.
6. **Painted lit edge**: `mix(col, col*1.25 + .03, edge*edge_light*up)`, with `edge` from the per-axis
   rounding zone `clamp((|p| - (half - r)) / r)`.
7. **Bottom AO**: `col *= mix(1, smoothstep(-.55,-.15,p.y), 0.45)`.

**Paint UV rule:** tops use `p.xz`; sides use a wrap-around coordinate. A wrap coordinate that switches on
`|x| = |z|` will paint an **X across every top face**, which is the bug we hit on tiles and bushes.

Lighting (`light()`), the heart of the painted look:
```glsl
void light() {
	float ndl = dot(NORMAL, LIGHT);
	float w = (ndl + wrap) / (1.0 + wrap);                       // wrap 0.45
	float band = smoothstep(0.0, band_soft, w) * 0.5             // band_soft 0.35: 2-tone
	           + clamp(ndl, 0.0, 1.0) * 0.5;                      // + true lambert keeps faces distinct
	float lit = band * ATTENUATION;
	vec3 diff = mix(shadow_tint * 0.18, vec3(1.0), lit);         // shadow_tint #6b5c9e-ish purple
	DIFFUSE_LIGHT += diff * LIGHT_COLOR / PI;
	vec3 h = normalize(LIGHT + VIEW);                            // soft painted highlight blob
	float sp = pow(clamp(dot(NORMAL, h), 0.0, 1.0), mix(8.0, 64.0, gloss)) * gloss * ATTENUATION;
	SPECULAR_LIGHT += smoothstep(0.3, 0.6, sp) * LIGHT_COLOR / PI * 0.5;
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0); // fresnel rim, lit side only
	DIFFUSE_LIGHT += rim * 0.45 * rim_color * clamp(ndl + 0.6, 0.0, 1.0) * LIGHT_COLOR / PI;
}
```
Defining `light()` disables Godot's built-in diffuse and specular for that material, so every lit
material in the game must use the same `light()` (put it in a shared `.gdshaderinc`) or the game will
not look like one game.

### 3.3 Per-biome block specifics
| Biome | Body | Cap | Extras | Emissive |
|---|---|---|---|---|
| Meadow | dirt `#9a6e4a`/`#6b4a33`, strata, pebbles | grass `#5c9e38`/`#9bd65e`/`#2f6a24`, drip 0.10, lip 0.035 | clover, sprout, white flower | – |
| Candy | jelly, inner glow `mix(col*0.78, col*1.2+0.07, 1-face_edge)`, gloss 0.8 | frosting white/pink, drip 0.16 | sprinkles (hashed dots), heart topper | – |
| Ice | frosted pale blue, fresnel 0.6, fake inner parallax `uv + VIEW.xy*0.1` | snow white, drip 0.06 + icicle cones | snowflake emboss (normal bump) | sparkle 1.2 |
| Underwater | deep blue glass, internal bubbles (circles parallaxed) | – | coral topper | – |
| Lava | basalt `#2f2a2e` | – | Voronoi cracks | cracks `#ff7a1a` × 2.5 |
| Forest | bark vertical stripes, ring top | moss patches | leaf topper | – |
| Crystal cave | grey stone facets | – | purple crystals embedded | 0.4 |
| Clockwork | navy panel | – | brass frame + rivets + gear emboss | – |
| Neon | dark glass | – | cyan circuit lines | lines × 2.0 |
| Celestial | purple galaxy fbm swirl | – | gold 4-point stars | stars × 1.5 |
| Tumble Fair | pink/cream stripes, gloss 0.6 | – | ticket topper | – |
| Dune Bazaar | sand with speckle | – | teal arabesque band, gold dome topper | – |

Pieces stay **palette-tinted** within the biome (ref 15: green, pink, yellow and blue meadow pieces).
Readability first: the cap colour may tint the top, but the body colour must identify the piece.

### 3.4 Production upgrade path (when procedural is not enough)
Per biome, model 1 hero cube in Blender, keep the procedural layer stack in nodes, and **bake** it:
1. UV unwrap (Smart UV, 0.02 island margin), or use a shared 3×2 "cube cross" atlas.
2. Bake **AO** (Cycles, 64 samples, distance 0.15) and a **curvature mask** (Bevel-node normal ⋅ true
   normal, as in §4.2, routed into an Emission shader).
3. Build the painted albedo in nodes = base ramp × AO^1.6 (85%) + edge light (curvature) + cavity dark.
4. Bake that **albedo through an Emission shader** (bake type EMIT) into a 512 px texture per biome. The
   result stays crisp at phone size.
5. In Godot, sample the texture in `fragment()` and keep the same `light()`.
This makes the bevel highlight and AO "free" at runtime and gives painters a texture to paint over in
Blender Texture Paint or Krita.

### 3.5 Do / Don't
- **Do** keep tops calm (big shapes) and put detail on sides and rims. **Do** cap only cubes whose top is
  exposed, if you can afford the check.
- **Do** keep the shade-to-lit ratio at 0.65–0.7 (§2.2).
- **Don't** use photo textures, normal maps from photos, or noise above 4 octaves.
- **Don't** use black or grey shadows, outlines, or `diffuse_toon` hard cel bands (too "anime", not painted).
- **Don't** let glow touch non-emissive blocks (keep albedo × light < 0.95 so the threshold is never hit).

---

## 4. UI kit

### 4.1 Pipeline
Model in Blender, render orthographic at **2× target** as transparent PNG, write the nine-patch margins
to JSON, and display in Godot as a `NinePatchRect` (panels) or `StyleBoxTexture` (buttons). Reference:
`blender_frame_ninepatch.py`, which writes `renders/frame_purple_*.png` and `.json`.

### 4.2 Purple-wood frame recipe (Blender)
- **Geometry**: 4 cubes. Top and bottom planks are `2H + 0.10` long (they overrun the posts), side
  posts sit between them. Plank width W = 0.34 (panel) or 0.24 (chip), thickness 0.13. **Bevel modifier
  width 0.045, segments 4**, smooth shading, tiny rotations (±0.006 rad) so it looks hand-built. Add a dark
  inner lip (`#2e1f40`, 0.05 cube) around the opening. Corner caps are a beveled iron plate, an extruded
  star (5 points, r 0.12/0.055, bevel 45% of depth) in gold, and 4 gold rivet spheres.
- **Wood material** (all procedural, Cycles):
  - TexCoord(Object) → Mapping, scaled (0.5, 3.5, 1) along the plank → Wave BANDS (scale 1.6,
    distortion 3.5, detail 2) + Noise (scale 3, **detail 2**: low detail reads as painted)
    → ColorRamp `#33224a → #5e3f7e → #8f6cae`.
  - Second Wave (scale 5, distortion 3) → narrow ramp (white to `#a58cbf` at 0.08–0.12) → MULTIPLY at 0.7
    for **dark grain lines**.
  - **Painted edge light**: `1 − dot(Bevel(radius 0.03).Normal, Geometry.Normal)` × 6 (clamped) → mix
    toward the light wood colour.
  - **Cavity**: AmbientOcclusion(distance 0.08).AO ^ 1.6 → MULTIPLY at 0.85.
  - Roughness 0.72, Specular IOR Level 0.3, no coat. **Matte**: glossy wood reads as plastic, which was
    our first failure.
- **Vines**: a NURBS curve (order 4) riding **on** the plank surface (z = T + 0.045 ± 0.012; letting it dip
  under the plank breaks the vine into segments). Bevel depth 0.024, radius tapering 1.4→0.5. Leaves
  are UV spheres scaled (0.095, 0.043, 0.011) with a Simple Deform TAPER of 0.9, alternating sides with
  random tilt. Blossoms are 5 flattened petal spheres (`#fff6f0`) and a yellow pistil (`#ffd34d`, slight
  emission).
- **Variants from one script** (`WT_VARIANT`): `panel` (parchment inside, vines on 2 corners), `chip`
  (W 0.24, no vines, 1 sprig), `screen` (no parchment, so it can border the 3D view). Biome tints (vine
  green, ice blue, celestial purple) are the same script with a different ramp. Add those next.

### 4.3 Godot nine-patch rules (proven in `ui_demo.gd`)
- Downscale the 2× render to the size class you need **once** (Lanczos), then
  `patch_margin = margin_json × tex_width / 1024`.
- **A nine-patch must never be drawn smaller than 2 × margin on either axis.** If it is, the corners
  overlap and seams appear. This happened with our tall panel. Make one render per **size class**:
  | Class | Render | Godot texture | Margin (at Godot size) | Min size |
  |---|---|---|---|---|
  | Screen border | `screen` 1024 | 384 | 118 | 236 |
  | Panel (settings, mode select) | `panel` 1024 | 512 / 384 | 158 / 118 | 316 / 236 |
  | HUD chip, pause, tray | `chip` 1024 | 256 | 50 | 100 |
  | Button | dedicated pill render | 256×128 | 56 h | – |
- Use `axis_stretch = STRETCH` for planks (the grain runs lengthwise, so stretching is invisible). Use
  `TILE_FIT` only for rope or patterned borders.
- Screen-border frames use `draw_center = false`, and the parchment must **not** be in that render.
- Put vines and blossoms only inside the corner patches. Anything in an edge patch gets stretched.
- Bigger ornaments that break the frame (the wizard peeking in, the close gem, the title plaque) are
  separate `TextureRect`s layered on top, not part of the nine-patch.

### 4.4 Buttons
- Render the gold pill in Blender: capsule (Cube + Bevel width 0.5 × height, 6 segments), gold material
  from §1.2 with a separate white specular streak (a thin stretched sphere, emission 0.6 white,
  alpha 0.7), and a `#c98418` lip 0.08 below. Render 3 states: normal, pressed (lip hidden, 4 px down),
  disabled (desaturated 60%).
- In Godot: `StyleBoxTexture` with `texture_margin_left/right` = half the height and top/bottom 0, so
  only the middle stretches. The star icon is a separate `TextureRect`. The label is Fredoka 700 ALL-CAPS
  in `#3b2346`.

### 4.5 Multicolour 3D title text (proven, `style_kit.gd::title_text`)
Per letter (one `Control` holder per glyph):
1. **Extrusion**: 6–7 stacked `Label`s, each offset +1.2% of the font size in y, coloured
   `letter_colour.darkened(0.45)`, outline `size × 0.16` in `#3b2346`. The deepest layer carries the drop
   shadow (`#1a0826` at 45%, offset 6%, blur 8%).
2. **Face**: the same glyph in the letter colour (cycle `#f08a2c, #f6e2b8, #4aa8e8, #6cc04a, #b48ad8,
   #ee6aa0`).
3. **Top light**: the same glyph lightened 30%, clipped to the top 62% of the glyph box.
4. **Wobble**: rotate each holder −4°…+4°.
This runs live, so it is localisable. **For fixed hero titles** (the "SELECT MODE" plaque) render the
letters in Blender instead: Text object → Extrude 0.08, Bevel 0.03 (4 segments), per-letter material
(split with "Separate by Loose Parts" after converting to mesh), the same wood edge-light node trick,
and bake into the plaque PNG. Never redraw the logo: `logo_master.jpg` is used as-is.

### 4.6 Fonts (downloaded to `prototypes/style_rnd/fonts/`)
| Role | Font | Licence | URL |
|---|---|---|---|
| Display / numbers | **Lilita One** | OFL 1.1 | https://raw.githubusercontent.com/google/fonts/main/ofl/lilitaone/LilitaOne-Regular.ttf |
| Display alt (rounder) | Titan One | OFL 1.1 | https://raw.githubusercontent.com/google/fonts/main/ofl/titanone/TitanOne-Regular.ttf |
| Display alt (comic) | Luckiest Guy | **Apache 2.0** (not OFL, but still fine to ship with the licence text) | https://raw.githubusercontent.com/google/fonts/main/apache/luckiestguy/LuckiestGuy-Regular.ttf |
| UI labels / body | Fredoka 600/700 (already in `assets/fonts/fredoka/`) | OFL 1.1 | https://raw.githubusercontent.com/google/fonts/main/ofl/fredoka/Fredoka%5Bwdth,wght%5D.ttf |
| UI alt | Baloo 2 | OFL 1.1 | https://raw.githubusercontent.com/google/fonts/main/ofl/baloo2/Baloo2%5Bwght%5D.ttf |
Recommendation: Lilita One for titles and numbers, Fredoka for everything else. Record each font in
`assets/third_party/CREDITS.md` with its licence text.

### 4.7 Do / Don't
- **Do** render every frame, button and chip from 3D. **Do** keep a plum (`#3b2346`) outline on all
  display text. **Do** match ornament colours to the palette tokens.
- **Don't** use `StyleBoxFlat` for anything visible except debug. **Don't** use hairline borders, flat
  light-yellow bars, or white text on light backgrounds. **Don't** stretch vines.

---

## 5. Islands and environment

### 5.1 Island chunk (Blender, then GLB)
- **Top slab**: a rounded box the size of board + rim (board 8 × 8 + 1.2 ring each side), height 0.8,
  radius 0.35. The biome cap is the same cap-mask shader as the blocks (`cap_y` near the top, drip 0.12,
  `half_size` and `edge_width` set to the mesh).
- **Strata**: 2–3 bands. Each is a rounded-square prism (superellipse n=4, 20–24 sides, radius jitter 7–13%)
  inset 0.15–0.5 from the band above: [5.35→5.2, h 1.5], [5.15→4.7, h 1.5], [4.7→2.2, h 2.4]. **The
  bands must be nearly vertical**, otherwise a 40° camera never sees the lower ones (our first version
  showed only one band).
- **Production upgrade**: chunk the bands into **rock blocks**. Take a Voronoi Fracture or Cell Fracture
  of the band, bevel each cell (width 0.06, segments 2), and shift cells in and out ±0.08. Then add a Decimate
  (planar 5°) for painted planes. Bake AO and curvature into a 1024 albedo per biome (the §3.4 method).
  Hang roots (curves, bevel 0.03, taper) or icicles (cones) from the bottom.
- **Board**: 8 × 8 rounded tiles 0.96 × 0.3 × 0.96, radius 0.07, warm grey `#bdb2a2` ±4% value jitter
  per tile, painted mottle, edge light 0.45. The board sits 0.05 above the slab so the grout reads as
  shadow.

### 5.2 Rim dressing
Place only in the square ring `max(|x|,|z|) ∈ [4.25, 5.1]`. Meadow uses about 70 items: 65% flowers (5
petals, white or lilac, **petal 0.26 × 0.17 world units**: they must be readable at phone size and
small ones disappear), clover triplets (0.28 leaves) and 9 bushes (0.5–0.85 spheres). Use `MultiMeshInstance3D`
in production (one draw per prop type).

### 5.3 Biome cap and colour swap
One island mesh per silhouette family. The biome changes the cap colours, band colours, rim props and
the environment preset. Proven: meadow to ice was only parameter changes (`island_demo.gd -- biome=ice`).

### 5.4 Background (painted backdrop)
- **Technique**: `Environment.background_mode = BG_CANVAS`, plus a `CanvasLayer` at layer −10 holding a
  full-screen `ColorRect` with `canvas_proto_backdrop.gdshader`. That shader draws a gradient top →
  horizon → low, a soft fbm cloud sea with a lit top and shaded underside, and stars for night.
- **Production**: render each biome's distant scenery (3–6 floating islands with landmarks, waterfalls,
  mountains) **in Blender** as 2–3 parallax layers (far / mid / near clouds). Use the Mist pass for
  aerial perspective and Standard view transform. Export each layer as a 1440 × 2560 (portrait) PNG and
  show the layers as `TextureRect`s in the backdrop CanvasLayer, with a slow parallax tied to camera yaw.
  The backdrop never moves with gameplay, so pre-rendered is cheaper and prettier than real 3D.
- **Mid-distance 3D islands** (if any) use the painted shader with `haze 0.5–0.6`, `haze_color` = the
  biome horizon.

### 5.5 Do / Don't
- **Do** keep the board area visually quiet (low-contrast tiles) and push saturation and detail to the rim.
- **Do** keep a lighter horizon behind the island so its silhouette pops (ref 15).
- **Don't** use global fog, a `Sky` resource for the look, or real-time GI. **Don't** put props on the
  grid. **Don't** make cliffs a single smooth cone.

---

## 6. Characters

### 6.1 Blocking (scripted, headless-friendly)
1. **Metaballs for the soft masses**: head, body, beard lobes, cloud puffs. `bpy.data.metaballs.new`,
   one `MetaElement` BALL or ELLIPSOID per mass (radius 0.3–1.0, stiffness 2), resolution 0.04. Then
   **Convert to Mesh**.
2. **Skin modifier for limbs**: a polyline skeleton (shoulder → elbow → wrist → hand), skin radius per
   vertex (arm 0.12 → hand 0.18), then Subdivision level 2. Big mitten hands are a skin blob with a thumb branch.
3. **Merge and unify**: Join, then **Remesh (Voxel, 0.02–0.03)**, then Corrective Smooth (factor 0.5,
   10 repeats). The result is one clean closed surface.
4. **Cloth folds and beard curls**: Displace modifier with a Blender `CLOUDS` texture (size 0.4, strength
   0.03) restricted by a vertex group, or a few sculpt strokes. For the beard, add 3–5 torus or curl
   metaballs at the bottom and a spiral curve at the tip, then remesh again.
5. **Hat**: a cone with 3 bend segments (Simple Deform BEND 60°, then TWIST) and a brim torus. The felt
   look comes from noise bump (scale 30, strength 0.05) and roughness 0.9.
6. **Face**: eyes are separate black ellipsoids (roughness 0.1) with 2 white emissive catch-light
   spheres. The nose is a pink sphere. Cheeks are a vertex-paint blush (Color Attribute node, radial gradient).
7. **Retopo for the game**: Decimate the remesh to 4–8k tris (Collapse 0.1), smooth shading, UV smart
   project, then **bake** albedo (Emission bake of the node colour), AO and a curvature edge light into one
   **1024 px** albedo. Godot uses the shared painted `light()` with rim 0.5.

### 6.2 Materials
- Skin `#f7c9a8`, cheeks `#f29a9a`. In Blender renders use Subsurface weight 0.15, radius
  (1, 0.4, 0.25), scale 0.05. In-game, fake it with a warm `shadow_tint` (`#c97a7a`) on skin only.
- Beard and cloud `#fff6f0` with a **lilac shade** (`shadow_tint #9d8cc8`). Rim 0.6. This is the most
  important trait for the "plush toy" read.
- Robe `#7a52b0`, trim `#f6e2b8`, star decals `#f8c840` (projected via UV or a decal texture).

### 6.3 Do / Don't
- **Do** silhouette-test at 64 px. **Do** pose with big readable gestures (cheer, oops).
- **Don't** model strands or fingers you cannot read at phone size. **Don't** copy any third-party
  character, including the Nintendo board characters (layout reference only).

---

## 7. Glow, sparkles and VFX
- Gold stars, the wand tip, lava cracks, neon lines and celestial stars write `EMISSION` > 1.0 (1.5–2.5).
  Nothing else should exceed 0.95 after lighting.
- Sparkles: `GPUParticles3D` is not ideal on Compatibility. Use `CPUParticles3D` (or 2D in UI) with a
  4-point star texture (render it in Blender, 128 px, additive), scale curve 0→1→0, lifetime 0.6 s.
- Confetti and fireworks are 2D CPU particles in a UI CanvasLayer.

---

## 8. Texture sizes and budgets
| Asset | Size (source) | In game |
|---|---|---|
| Block albedo (if baked) | 512 per biome (cube-cross atlas) | ETC2/ASTC, mipmaps |
| Toppers | 256 atlas shared | – |
| Island slab + strata | 1024 per biome | – |
| Rim props | 512 atlas per biome | MultiMesh |
| Character | 1024 albedo (AO and curvature baked in) | 4–8k tris |
| UI panel / screen frame | 1024 render (2×) | downscale to 512/384 per size class |
| UI chip / button | 1024 render | 256 |
| Icons, stars, sparkles | 256 / 128 | – |
| Backdrop layers | 1440 × 2560 PNG ×2–3 per biome | lossless or high-quality JPG/WebP |

---

## 9. Prototype results (honest)

All Godot shots are **Compatibility (opengl3) under Xvfb/llvmpipe**: the CI path, so the cheapest
renderer. Every image is in `production/qa/evidence/style-rnd/`.

### (a) Painted rounded block with grass cap: PASS with gaps
- `a_block_vs_ref13.png` (ref 13 meadow vs prototype), `a_block_compat.png`, `a_tonemap_strip.png`
  (Linear / Filmic / ACES / **AgX**).
- **Works**: chunky rounded silhouette, overhanging ragged grass lip, strata and pebbles, the lit bevel,
  purple-tinted shade side, a soft coloured contact shadow, and the sprout topper. It is the right
  "family" of image.
- **Gaps**: the grass cap is a texture, not geometry, so the ref's clumpy tufts and leaf clovers are
  missing. Hero blocks need 6–10 tuft blobs on the rim. Pebbles are flat dots, not sculpted. Grass reads
  slightly too smooth and airbrushed: it needs bigger, fewer brush shapes (§3.4 bake and paint-over).

### (b) Purple-wood frame (Blender) as a nine-patch: PASS
- `b_blender_frame_vs_ref08.png`, `b_ninepatch_vs_ref05.png`, `b_ninepatch_ui.png`; renders in
  `prototypes/style_rnd/renders/`.
- **Works**: planks with grain, overrun corners, iron caps with gold stars and rivets, vines with leaves and
  blossoms, a dark inner lip, a parchment interior; it stretches cleanly to wide and tall panels. Render
  time about 1–2 min per variant on CPU. Multicolour live title text reads like the refs.
- **Gaps**: the grain is too regular and stripy (the refs have broad painted strokes, knots and chipped
  ends). The vine stem is hidden under leaves (fewer, larger leaves). There is no rope or gears yet (settings
  variant). The chip size class is still visually heavy: the chip needs an even thinner plank (W ≈ 0.18)
  and a parchment card interior. The title "top light" sliver is a hard split: replace it with a gradient
  shader on the label (`canvas_item` shader on the face layer). The first render was **too glossy and
  pastel** (Filmic-like look, coat 0.15). Fixed with roughness 0.72, a darker ramp, and Standard view
  transform.

### (c) Warm lighting and environment preset: PASS for lighting, FAIL for Sky and fog (replaced)
- `c_island_meadow_vs_ref15.png`, `c_island_ice_vs_ref15.png`, `c_island_meadow.png`,
  `c_island_ice.png`.
- **Works**: one preset and one rig give warm, readable pieces with tinted shadows. Swapping the preset
  to ice changes the mood with no other edits. The HUD wraps the board without covering it.
- **Failed then fixed**: `Sky` shader backdrop (grey in Compatibility), global fog (tinted the background),
  over-bright first rig (forgot that `LIGHT_COLOR` carries π), and an X artefact on tiles (paint UV).
- **Gaps**: the background is empty sky. The refs' depth comes from **painted distant islands, mountains
  and waterfalls**, which is the biggest visual gap and needs the Blender backdrop layers (§5.4). The
  cliffs are smooth bands, not rock blocks with roots. The HUD frame is purple instead of
  **biome-tinted** (green vine in meadow, ice-blue, celestial). The chips lack parchment cards, stars and
  NEXT piece renders. The ice biome still shows meadow pieces (only the preset was tested).

---

## 10. Top risks
1. **Backdrop scenery** carries about half of the reference's richness and none of it exists yet. It needs a
   Blender pipeline per biome (§5.4). Without it, every screen will look "empty sky".
2. **Single `light()` discipline.** Any material that uses Godot's default lighting will look like
   another game next to the painted ones. Put it in one shared `.gdshaderinc` and lint for it.
3. **Compatibility versus Forward+ drift.** Forward+ adds SSAO, SSR and better shadows, so desktop will
   look different. Screenshots and acceptance must be judged on **Compatibility (CI)** and Mobile, with
   Forward+ extras turned off by default.
4. **Hand-painted quality ceiling.** Procedural paint gets to about 70% of the references. The last 30% (brush
   shapes, tufts, knots, faces) needs baked textures and paint-over (§3.4, §6.1 step 7). Budget artist
   time for it.
5. **Performance on phones.** Fragment fbm costs about 10–15 noise taps per pixel. Baking to textures (§3.4)
   is also the performance fix. Rim props must be MultiMesh.
6. **Nine-patch size classes.** UI agents must respect the min-size rule (§4.3) or corners will overlap.
7. **Licensing.** Luckiest Guy is Apache-2.0, not OFL. Credit every font and CC0 asset. Never use the
   Nintendo boards beyond layout.

---

## 11. Research sources
- Godot renderer feature matrix (Compatibility vs Mobile vs Forward+):
  https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot 4.6 rendering changes (glow before tonemap, AgX controls): `docs/engine-reference/godot/modules/rendering.md`
- Toon and wrap lighting in Godot 4 `light()`: https://godotshaders.com/shader/toon-shader-for-godot-4/ ·
  https://godotshaders.com/shader/flexible-toon-shader-godot-4/ (CaptainProton42/FlexibleToonShaderGD)
- Blender stylised textures and AO baking: https://blenderartists.org/t/tutorial-create-stylized-textures-in-blender/673948 ·
  https://www.katsbits.com/tutorials/blender/baking-ambient-occlusion-maps-for-terrain.php
- Fonts: Google Fonts repository (`github.com/google/fonts`, `ofl/` and `apache/` folders),
  https://fontsource.org/fonts/lilita-one/about
- CC0 sources for later: Poly Haven (HDRIs, rocks, plants), Kenney (UI icons, props), ambientCG
  (base textures to repaint), BlendKit free assets (check each one's licence; restyle to this cookbook).
