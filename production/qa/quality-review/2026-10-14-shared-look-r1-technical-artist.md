# Shared look r1: technical artist (blind expert 2 of 3)

Scope: lighting and post pass, and block materials v4. Rules: reference-quality-bar.md "Stricter marking" and "Three blind experts per aspect". Pass mark 9.7. Captures were viewed at the contact-sheet level and at one or two full-size frames. I did not run the game. Shader findings come from reading the code, so they are flagged "code-read" where no capture proves them.

## Scoreboard (technical artist)

| Item | Score | Cap or reason |
|---|---|---|
| A1 Lighting mood and shading | 7.0 | Open defects D3, D8. The key, fill and ambient rig is data-driven (biomes.<id>.env.light) and gives a warm/violet split. The new look shows in lighting-v1/after_contact.png against before_contact.png. Block shading is still murky and dark next to ref 13. |
| A2 Colour and value hierarchy | 7.0 | Open defects D6, D7. Blocks are about 60 px and sit in a mid-value board. In after_contact.png the lava, neon and cave blocks are darker than their floor, so the focal piece does not out-rank the island. |
| A3 Block material quality | 6.0 | Stale-capture cap. Every blocks-v4/ capture predates the lighting pass (as stated in the brief), so the material has not been judged under the shipped grade. Defects D5, D9 also apply. |
| A4 Post finish | 7.0 | Open defects D1, D2, D4. The pass is cohesive, but the sky is over-blurred, the bloom is a mip box filter and the outline is 1 px aliased. |
| A5 Per-biome identity | 7.0 | Open defect D6. Silhouette, sky and props differ per biome (after_contact.png). The post values, however, are near-identical in 11 of 13 biomes (biome_looks.json biomes.*.post: outline_strength 0.55, ao_strength 0.7, vignette_strength 0.48, outline_width 1.6, ao_radius 10, haze_strength 0.35 repeat). Only tints change. |
| A6 Overall screen quality | 7.0 | Open defects across A1 to A4. Sits beside the references as the same family, but not as the same game: after/biome_ice.png has soft, hazy mountains and a flat white board, and blocks are tiny. |
| T1 Technical soundness and performance | 6.0 | Missing-capture cap: the shipped Mobile renderer was never captured (only opengl3). Defects D1, D2, D4, D10, D11. |

## Ranked defects

### D1 (high, T1/A4): the sky is blurred by the depth-of-field path, and the target renderer is unverified (code-read)
- spatial_post_painted.gdshader:92-95. `behind`, `blur_t` and `lod` are not masked by `is_geo`. Sky pixels sit at zc of about 150 (camera far = 150, wt_stage.gd:782).
- So `behind` is about 115, `blur_t` is 1, and lod = dof_strength*3 = 6.0 to 7.2 (dof 2.0 to 2.4, biome_looks.json). The painted canvas sky is sampled at mip 6, which is 1/64 resolution.
- Capture evidence: after/biome_ice.png shows the mountain range and castle melted into pastel blocks with visible stair-steps, and faint vertical ghost bands at the upper left. weather_after/weather_snow.png shows hills and mesa-fall streaks that are soft and low-detail.
- The canvas_env_sky.gdshader work (ridges, castle, clouds) is largely thrown away.
- Compatibility builds the mip chain with `glGenerateMipmap` (a box filter). Forward+ and Mobile build a blurred chain. The look differs per renderer, and only opengl3 was captured.

### D2 (high, T1): full-screen post cost on Mobile
- spatial_post_painted.gdshader:78-87 runs a loop of 8 iterations with 2 depth taps each. That is 16 depth taps plus 1 centre tap, plus 3 colour taps. The header comment at :5 says "8 depth taps + 4 colour taps", so the comment is wrong.
- This breaks .claude/rules/shader-code.md ("No texture reads inside loops"; "Two-pass approach for blur effects").
- Reading hint_screen_texture and hint_depth_texture on a Mobile TBDR GPU forces a render-pass split and a screen copy plus a depth copy. At 720x1280 that is 0.9 Mpx x about 20 taps.
- Budget: the brief states no numbers. The shader-code rule requires a documented complexity budget per shader, and there is none for this shader.
- A low tier exists (wt_post_process.gd:39-42), but it only scales strengths. It never drops the loop or the taps, so cost does not fall on the low tier. The `quality <= 0` path still runs 20 taps.

### D3 (medium, A1/T1): double-counted lighting and AO with no capture proof
- The block shader applies coloured AO in six stacked terms: foot, cavity, edge, seam, layer and below-cap (spatial_block_biome.gdshader:722, 760, 767, 778, 781).
- It then adds toon_shadow_floor (toon_light.gdshaderinc:21, 44) on top of environment ambient, which Godot adds separately.
- The post quad then adds depth AO (ao_strength 0.7, radius 10 px) and an ink outline on the same creases.
- Result in after_contact.png: lava, cave, neon and clockwork blocks read as dark and low-key. Ref 13 blocks are bright and lit on all three faces.
- The ao_radius is in screen pixels, not scaled by viewport height. A 1080x1920 device gets a thinner AO than the 720x1280 captures.

### D4 (medium, A4/T1): aliasing and artefacts in the post pass
- No MSAA is available in Mobile. The outline uses nearest-filtered depth with a 1.6 px width (post, all biomes) and a hard `smoothstep` edge, so it will stair-step.
- Block glint lines are 1 px (`edge_line`, spatial_block_biome.gdshader:806, 810) and will crawl on motion.
- Bloom is a bright-pass on mips 3 and 5 (:98-100). A box-filtered mip shows square-edged halos, and there is no Gaussian blur.
- The draw order is decided: render_priority is MIN (wt_post_process.gd:54), and the quad has no depth test and writes opaque ALBEDO. That is correct for particles that sit after it. The side effects are:
  - Transparents (sparkles at render_priority 10, wt_sparkle_fx.gd:49, weather particles, glass) are not graded, hazed, blurred or outlined. In weather_after/weather_snow.png the snow discs are crisp and white on a softly graded scene.
  - Transparents are absent from the depth texture, so AO and outline ignore them.
  - Any other material with a negative render_priority is drawn before the post quad and is graded; any material with default priority is drawn after.
  - Any other screen-texture shader would sample the ungraded frame.
- The glow settings (glow_hdr_threshold 0.95 or 0.8, softlight, wt_island_builder.gd:110-117) rely on HDR 3D buffers. I could not verify that Compatibility applies the threshold to an 8-bit buffer. It is marked unverified.

### D5 (medium, A3): block shader cost and discard
- Header budget (spatial_block_biome.gdshader:4): "<= 2 Voronoi + ~8 value-noise taps". Lava runs 2 domain-warped Voronoi plus 3 vnoise warps plus fbm (:440-466) before the cap and detail code. Forest and cave run Voronoi in both body and cap. The budget is not met.
- One uber shader holds 13 styles behind uniform branches. Register pressure is the maximum of all branches, which lowers mobile occupancy.
- The fragment uses `discard` (:286, 289-290, 310). That disables early-Z for every block pixel, including the cap-shell/body overlap, so the heaviest shader in the scene is paid for at overdraw.
- The dither hash `fract(sin(dot(...)*43758.5453))` (:286) loses precision on mediump devices.
- Header version labels conflict: v3, v4 and v5 appear on lines 1, 11 and 15. The v4 header comment on line 11 is out of date.

### D6 (medium, A2/A5): data-driven tuning is not differentiated per biome
- 11 of 13 biomes carry the same numeric post block (see scoreboard A5). The tuning keys are in the data, which is good, but the values have not been tuned per biome.
- Meadow, ice, candy, pirate and carnival share the same strength, radius and haze numbers. They differ only by hex tints.
- Two sources of truth exist for glow: wt_island_builder.gd:110-117 hard-codes glow values (0.55, 0.04, 0.95), and WtPostProcess.DEFAULTS duplicates them at wt_post_process.gd:19. Data-driven standard violated.
- wt_level_look.gd:171-257 also drives glow_intensity per level, which can fight with `attach()`.

### D7 (medium, A2): focal piece and floor value separation
- The playfield board is a mid-value cream or grey in meadow, ice and pirate, so blocks do not separate from the floor (after/biome_ice.png: blue-white cubes on a blue-white board; weather_after/weather_snow.png: dark cubes on a pale board are fine, but ice and underwater are low).
- Per-biome greyscale checks exist (blocks-v4/*_grey.png), but none under the new grade.

### D8 (low-medium, A1): ambient is high enough to flatten faces
- Ambient energy is 0.336 on meadow, with fill at 0.28 and back at 0.5 (biome_looks.json env.light). Side faces in blocks-v4/ingame_vs_ref13_set.png read as flat saturated colours. The ref 13 faces have a clear top, left and right value step, with a warm top and a cool side.
- The light() ramp and its shadow floor are good, but the side separation relies on `side_shade` and `shade_side_extra` hacks in albedo (:756), not on lighting.

### D9 (medium, A3): block fidelity against ref 13 (blocks-v4/ingame_vs_ref13_set.png)
- Meadow in-game shows coloured stone pieces with grass tops. Ref 13 shows dirt and grass blocks with a clover and pebbles on each face. The grass cap is dithered, so the cap edge looks noisy at this size.
- Forest uses a repeating green top with a bark side. Ref 13 has moss patches and tree rings on top, so the identity is weaker in-game.
- Cave and clockwork use a pink-purple top and dark sides. Ref 13 cave is grey rock with purple crystals, and ref 13 clockwork is brass with a navy panel. The brass frame in-game looks orange, and the palette tints make each piece a different colour.
- The glyph in every face corner (:734-746) adds noise at 60 px blocks.

### D10 (low, T1): comment and docs drift
- spatial_post_painted.gdshader:5 says 8 depth taps. It is 16.
- Two doc comments in the block shader are orphaned, at :89 ("Strength of the faint painted cracks" sits above `cap_body_mix`) and at :11-18, so the doc comments are out of order.

### D11 (low, T1): no performance numbers recorded
- No GPU timing, draw call, vertex or texture-memory figure appears in any evidence folder. Budgets in the shader headers are claims.
- There is no Mobile (Vulkan) capture of any biome, although the project renderer is Mobile.

## Fixes (each tagged with its owner)

1. **[godot-shader-specialist / technical-artist]** Mask the blur by `is_geo` (or lerp lod to 0 for the backdrop): `lod *= is_geo` at spatial_post_painted.gdshader:94. Then recapture ice and meadow and confirm the ridge and castle keep detail. Fixes D1.
2. **[godot-shader-specialist]** Cut post cost. Reduce the ring to 4 taps for AO and 4 for the outline, or use Roberts-cross on 4 depth taps. Drop the loop on the low tier. Add a documented budget to the header ("N taps, target GPU ms on a named Mobile device"). Fixes D2.
3. **[engine-programmer]** Capture every biome with the Mobile renderer on Vulkan and attach the frames and the GPU frame times to production/qa/evidence/. Fixes D1, D2, D11.
4. **[technical-artist]** Replace the box-mip bloom with the Environment glow only, or add a small Gaussian on mip 3. Scale `ao_radius` and `outline_width` by viewport height. Fixes D3, D4.
5. **[technical-artist]** Add AA for the outline (smoothstep over a depth gradient, 2 px), or fade it at distance. Fixes D4.
6. **[technical-artist]** Reduce stacked AO. Pick either shader AO or post AO per surface. Lift the ambient so side faces step cleanly (top warm, left, right cool). Fixes D3, D8.
7. **[art-director]** Decide per-biome post values. Then **[technical-artist]** fill the JSON so that outline, AO, vignette and haze differ in strength by biome, not just in tint. Fixes D6.
8. **[technical-artist]** Remove the duplicate glow constants in wt_island_builder.gd:110-117. WtPostProcess should be the only source. Reconcile with wt_level_look.gd:171-257. Fixes D6.
9. **[godot-shader-specialist]** Split the block shader into per-style variants or per-family shaders, or remove `discard` from the opaque path (use alpha-to-coverage dither only when fading). Cap Voronoi count at 2 per pixel. Update the header budget and version lines. Fixes D5, D10.
10. **[art-director + technical-artist]** Recapture blocks-v4 per biome stacks and ingame_vs_ref13_set.png under the final lighting and post. Add a greyscale check. Make the playfield value darker or the cubes lighter so the focal piece separates. Fixes D7, D9, and clears the stale-capture cap on A3.
11. **[world-builder / blocks maker]** Bring meadow and forest block caps and side motifs closer to ref 13 (dirt body, clover, bark and tree rings). Fixes D9.

## Not built / unverified
- Compatibility glow with `glow_hdr_threshold` on 8-bit buffers: unverified.
- Mobile (Vulkan) look of the post pass: no capture.
- Motion shimmer of glints and outlines: no video or frame sequence.
