# Block Rendering Plan

> **Author**: godot-shader-specialist, 2026-10-10. Plan only: no shader or code written.
> **Authority**: ADR-0007 (current uncommitted text), ADR-0001, ADR-0002 §5 (delta triples `[op, a, b]`), implementation-plan §1.2 `src/view/` and VEW-002 / VEW-003 / MDW-007, art bible §3 + §8, block-art-sets.md, Game Feel & VFX, Block Status Effects, Layer Clearing (visual rules 13, 206).
> **Engine**: Godot 4.7.2 (installed, probed), Mobile renderer, Vulkan on Android, **D3D12 in the Windows editor** (4.6 default, see `project.godot`). Desktop screenshots are therefore D3D12, not Vulkan: every "looks right" check needs one Android pass too.
> **IDs**: RND-01... are provisional. The orchestrator renumbers them into the CH-037+ sequence. Where a chunk *is* an existing plan story, it says so (do not build both).

## 0. What I found in the assets (inspected 2026-10-10)

- `candy_toy`: 68 GLBs (67 shapes + `blk_candy_toy_cube.glb`). **Every cube in every file references the one mesh `cube_candy_toy`**: 1014 verts, 1728 tris, POSITION/NORMAL/TEXCOORD_0/TANGENT, AABB ±0.515, **no material, no texture, no vertex colours**. So the motif atlas (ADR `CUSTOM.r`) has no art yet; the channel stays reserved.
- `.import` files already have `generate_lods=false`, `create_shadow_meshes=false`, `light_baking=0` and the post-import script, through `[importer_defaults]` in `project.godot`. Nothing to change there.
- `neon_voxel`: 67 GLBs, **no `blk_neon_voxel_cube.glb`** (so `test_block_sets_each_set_has_a_cube_file` should currently fail), and its cube mesh has **2 surfaces** (body 336 verts + glow 48 verts, GLB materials `mat_neon_voxel` / `mat_neon_voxel_glow` with emissive strength 4). That is 2.6x lighter than candy_toy, but each pass costs 2 draws. Section 4 covers how the plan handles multi-surface sets.

---

## 1. Greybox first: the minimum renderer for the first playable

The first playable is APP-001 (meadow_01 end to end on an Android debug APK). The renderer only has to make the board, the piece, the ghost and a clear **readable**. It does not have to look final.

| Needed for first playable | How (minimum) | Custom shader? |
|---|---|---|
| Board cells | One `MultiMeshInstance3D` per board, candy_toy cube mesh (`.res`), packed slots, per-instance setters, flat hue through `StandardMaterial3D.vertex_color_use_as_albedo` (= VEW-002) | No |
| Falling piece | GLB scene per shape; each cube child gets a cached `StandardMaterial3D` per hue as `material_override`; physics interpolation (= VEW-003) | No |
| Ghost | Same GLB, one shared `StandardMaterial3D`: unshaded, transparent, alpha `view.ghost_alpha`, **`no_depth_test = true`** so the ghost is never hidden while fade is not built yet (Camera rule 13 stop-gap). Removed when RND-15 lands | No |
| Layer-clear flash | A reusable "dying" `MultiMeshInstance3D` per board. `REMOVE(cause=CLEAR)` cubes are copied in, then flash to warm white and shrink, bottom-to-top, inside the sim's Resolving window | **Yes**, `spatial_block_clear.gdshader`. It is small and self-contained, and a material tween cannot stagger per layer. It is written once and kept, not thrown away later |
| Outline (optional in greybox) | `StandardMaterial3D` `next_pass` with `grow = true`, `cull_mode = CULL_FRONT`, unshaded, `vertex_color_use_as_albedo` × dark albedo gives a **hue-tinted inverted hull with zero shader code**. Width = `BlockViewMath.outline_world_width()`. Toggle by knob | No |

The native `grow` hull matters for one reason: the **device stress test (RND-09) can run right after greybox**, with the real 2x vertex cost, *before* any time goes into the toon shader. ADR-0007's top risk (vertex budget) gets measured first.

**Skipped until after first playable** (each is a later chunk, and the sim already emits what it needs):
toon/gloss block shader · custom outline shader · ghost shader · dithered occlusion fade + cutaway (the ghost x-ray stands in) · settle animation (blocks above a clear snap down at once; the dying cubes flash in their old cells, which reads fine) · status looks, shells, badges, countdown pips · PreviewBaker (the HUD uses name placeholders, UI-001) · packed `multimesh_set_buffer` upload · hidden-cube culling · Shader Baker / warm-up · motif atlas · multi-board layouts · four-board quality tier · height line (not a block system; HUD/view owner).

---

## 2. Shader set

All files live in `res://assets/shaders/`. Naming: `[type]_[category]_[name]`.

| File | Purpose | Chunk |
|---|---|---|
| `block_common.gdshaderinc` | Shared: instance-data decode, settle offset, status wobble, Bayer 4x4, cut-plane test. Included by every block pass so the hull always matches the body | RND-10 |
| `spatial_block_toon.gdshader` | Board blocks (MultiMesh, reads `INSTANCE_CUSTOM`) | RND-10 |
| `spatial_block_piece.gdshader` | `#define PIECE` + include: falling piece cubes; reads `instance uniform`s, because `INSTANCE_CUSTOM` only exists for MultiMesh | RND-12 |
| `spatial_block_outline.gdshader` | Inverted-hull `next_pass` (board and piece: `#ifdef PIECE` through a second 3-line file `spatial_block_piece_outline.gdshader`) | RND-11 |
| `spatial_block_ghost.gdshader` | Ghost body | RND-13 |
| `spatial_block_clear.gdshader` | Dying MultiMesh: flash + shrink ripple | RND-07 |
| `materials/mat_block_default.tres` (+ optional `mat_block_<set>.tres`) | ShaderMaterials carrying the per-set look values (section 4) | RND-10 |

`#include` of `.gdshaderinc` has been stable since 4.0. It is not in the engine-reference docs, so RND-10 confirms it compiles on 4.7.2.

### 2.1 Per-instance data layout (board MultiMesh): ADR-0007 §1, refined

`transform_format = TRANSFORM_3D`, `use_colors = true`, `use_custom_data = true`, all set **while `instance_count == 0`**, then `instance_count = board.active_cell_count()` once per LAYOUT. Every value is an integer ≤ 2048 or lies in [0,1], so it survives half precision (ADR verification item 3).

| Channel | Board MultiMesh | Dying MultiMesh (clear) |
|---|---|---|
| TRANSFORM | cell centre, identity basis | cell centre, identity basis |
| COLOR.rgb | hue (palette lookup on the CPU) | hue of the removed cube |
| COLOR.a | settle drop, whole cells 0–32 (0 in greybox). StandardMaterial ignores it while opaque | unused (1) |
| CUSTOM.r | motif atlas index (0 = none; reserved, no art yet) | **ripple rank**: 0 = first cleared layer along down |
| CUSTOM.g | **status id** (0 = none). The shader maps id → look kind + accent through uniform arrays, so a new status that reuses a kind is data only (ADR §7) | unused |
| CUSTOM.b | status counter / pips | unused |
| CUSTOM.a | fade (1 opaque … 0 gone) | unused |

**Refinement 1.** Status id stays in the instance; `status_kind[16]` (int) and `status_accent[16]` (vec4) uniform arrays, filled from `statuses.json` at bind, turn it into a look. That keeps the ADR's "branch on kinds, not ids" without a CPU id→kind rewrite of every instance.

**Refinement 2.** Shaders read `CUSTOM.g` as `int(INSTANCE_CUSTOM.g + 0.5)` and pass it as a `flat varying`, so fragments never see an interpolated id.

**Per-board values** are `instance uniform`s on the `MultiMeshInstance3D` (one value per node = per board): `settle_t` (float), `down_local` (vec3, the board's down vector in board space: instance bases are identity, so this is also the vertex-local direction), `cut_plane` (vec4, world-space plane; `w = 1e6` = off). Cutaway works in world space: the CPU builds the plane from layer + board transform, so the shader never needs board-local layer maths. If verification item 4 fails (instance uniforms on MultiMesh under Mobile), each board gets its own material copy (≤ 4 boards).

**Piece variant** `instance uniform`s on each cube `MeshInstance3D`: `piece_hue` (vec4), `piece_status` (int), `piece_counter` (float). PieceView sets them per child with `set_instance_shader_parameter`. With the board's 3, that is 6 in total, well under the per-shader instance-uniform cap (believed 16; **unverified for 4.7**, RND-10 checks).

**`MODEL_MATRIX` in a MultiMesh vertex shader** is assumed to include the instance transform (true in 4.x as far as I know). Instance world origin = `MODEL_MATRIX[3].xyz`. **Unverified on 4.7.2**; RND-10 checks it with the cutaway plane screenshot.

### 2.2 `spatial_block_toon.gdshader` (board) / `spatial_block_piece.gdshader`

- `render_mode diffuse_toon, specular_disabled, cull_back;` Built-in toon diffuse comes before a custom `light()`. Shadow colour comes from the level's `Environment` ambient (lilac by default per block-art-sets). A custom `light()` ramp is the fallback only if art direction wants 2–3 bands with a ramp texture.
- **vertex()**: decode instance data. `VERTEX -= down_local * drop * (1 - settle_t)` (settle: the cube is drawn back toward where it came from, then slides home). Status wobble ≤ 0.08 × edge for wobble-kind statuses, scaled by `global uniform float reduced_motion`. Pass `v_world_up_offset` = world-space height of the vertex above the cube centre, for the gradient.
- **fragment()**:
  - Albedo = hue × gradient (`top_lighten`, `bottom_darken` from `v_world_up_offset`, so the gradient is world-up for the board *and* rotated pieces).
  - Gloss = view-space highlight: `smoothstep` on `dot(NORMAL, gloss_dir_view)` (NORMAL is view space in fragment), **mixed into ALBEDO toward white**. It stays upper-left at all 12 yaws, which a light-driven specular would not. Optional `matcap : hint_default_black` adds one texture sample later, when art supplies one.
  - Fake inner glow: fresnel lighten `pow(1 - dot(NORMAL, VIEW), fresnel_power) * fresnel_strength`.
  - Status rim: accent × pulse(TIME) on the same fresnel term.
  - Fade: `if (fade < bayer4(FRAGCOORD.xy)) discard;`. Cutaway: discard when the instance origin is past `cut_plane`.
  - **Never write gloss, flash or rim into EMISSION.** Glow runs *before* tonemapping since 4.6, so a value over 1 there blooms. Emission is reserved for sets that really glow (neon) and for the clear flash.
- Uniforms (`group_uniforms`): `gradient` {top_lighten 0.12, bottom_darken 0.15}; `gloss` {gloss_dir_view (-0.45, 0.6, 0.65), gloss_threshold 0.9, gloss_softness 0.04, gloss_strength 0.85, matcap}; `glow` {fresnel_power 3, fresnel_strength 0.12}; `status` {status_kind[16], status_accent[16], pulse_hz 2, wobble_amp 0.06, invisible_alpha 0.1}. Starting values are first guesses for the technical artist to tune (art docs are defaults, not rules).

### 2.3 `spatial_block_outline.gdshader` (`next_pass`)

- `render_mode unshaded, cull_front;` Same include, so settle, wobble, fade dither and cutaway match the body exactly (faded blocks fade their outline: ADR §4, a user decision).
- Extrude along **`normalize(VERTEX)`** (from the cube centre), not `NORMAL`. Every board/piece mesh is a cube centred on its origin, so this cannot crack at hard-edged normals (ADR risk row 5), whatever normals a set exports.
- Width: `uniform float outline_width` (world units) = `outline_px × camera.size / viewport_height_px` (ortho, KEEP_HEIGHT), recomputed on `LAYOUT` and on viewport `size_changed`. This is ADR §3 unchanged; the formula is a pure function (RND-05).
- Colour `COLOR.rgb × outline_darken` (about −35 % value, "never black").
- Off switch: `next_pass = null` (four-board tier, stress-test toggle). No shader permutation.

### 2.4 `spatial_block_ghost.gdshader`

`render_mode unshaded, cull_back;` Albedo = `mix(piece_hue, white, ghost_lighten)`, ordered-dither discard at `ghost_density` (opaque pass: no sorting, no blend overdraw), plus the piece outline `next_pass` at full strength, so the shape reads through the dither. Depth test stays **on**. The greybox x-ray is dropped once fade (RND-15) protects the ghost. The ghost is never faded and never in the board MultiMesh.

### 2.5 `spatial_block_clear.gdshader` (dying MultiMesh)

`render_mode unshaded, cull_back;` Per-board `instance uniform float clear_ms` (BoardView writes it each frame **only while Resolving**: O(1) CPU). Per instance: `t = clamp((clear_ms - rank × stagger_eff_ms) / anim_ms, 0, 1)`, flash = `mix(hue, flash_color, flash_curve(t))` (warm white, about 0.3 s, art bible §2), scale `VERTEX *= 1 - smoothstep(dissolve_start, 1, t)`. Reduced motion: no shrink, dither-fade instead (Layer Clearing AC 24). `stagger_eff_ms` and `anim_ms` come from the sim's Layer Clearing F2 values (`clear.stagger_ms`, `clear.anim_ms`, `clear.resolve_max_ms` cap) and are pushed as uniforms. **The view reuses the sim's F2 helper; it does not re-derive it.** Outline `next_pass` optional ("outlines stay in ink until they vanish"). Confetti is a later particle system (Game Feel & VFX budget), not this shader.

### 2.6 Mobile-renderer limits that shape these shaders

1. **Lights.** The board MultiMesh is *one* object with a board-sized AABB, so every omni/spot light touching that AABB lights all of it, and the Mobile per-object cap (8 omni + 8 spot) is shared by the whole board. Blocks get **one DirectionalLight**. Diorama prop lights use a `light_cull_mask` that excludes the block render layer.
2. **`MultiMesh.custom_aabb`** = board bounds + settle/wobble margin. That avoids AABB recompute on uploads and wrong culling when the vertex shader moves cubes.
3. **No real transparency on blocks.** Dither discard keeps them in the opaque pass (ADR Alternative 3). The ghost's transparency is greybox only.
4. **`discard` on tile-based GPUs** may cost early-Z for the whole draw, even when a uniform branch skips it at run time (the driver sees `discard` in the shader). Measure in RND-09/RND-15. Mitigation (ADR): faded/cut instances move to a small second MultiMesh, and the main one uses a no-discard variant.
5. **Shadows off on blocks by default** (`cast_shadow = OFF` on the board MultiMesh). A shadow pass is another full vertex pass of 1014-vertex cubes. The "lilac blob under pieces" is a cheap decal or quad later. Art direction decides (art bible trade-off 5).
6. **No `hint_screen_texture` / `hint_depth_texture`** in block shaders (copy plus bandwidth).
7. **Divergent branches.** The status branch is per instance, so neighbouring pixels on one cube agree. Animation maths goes in `vertex()` where possible and is passed as varyings.
8. **Precision.** Packed values are half-safe. Mobile Vulkan defaults to highp; no `mediump` hand-tuning until profiling asks for it.
9. **Vertex compression** stays on (`meshes/force_disable_compression = false`, import default).
10. **Compile hitches.** Shader Baker on export (4.5+; setting name unverified for 4.7, ADR item 7) plus a one-frame warm-up draw of every block material at level load (RND-21).
11. **Desktop vs device.** The editor runs D3D12. Verification items 1–6 count only once checked on Android Vulkan.

---

## 3. Import pipeline (candy_toy GLBs and the cube `.res`)

**Keep as is** (already configured through `[importer_defaults]` + `.import` files): `.glb` source (never `.blend`), `meshes/generate_lods=false` (protects the bevels), `meshes/create_shadow_meshes=false`, `meshes/light_baking=0`, `import_script/path=res://tools/asset-pipeline/block_post_import.gd` (drops the wrapper root; cube file root = the `MeshInstance3D`), `meshes/ensure_tangents=true` (the GLB already carries tangents; later normal-mapped sets need them), `force_disable_compression=false`, `materials/extract=0`, `nodes/root_scale=1.0`.

**Add: the cube mesh as its own resource** (only for `blk_<set>_cube.glb`):
1. In the editor (driven through the godot-ai MCP or by the user): Advanced Import Settings on `blk_candy_toy_cube.glb` → Meshes → `cube_candy_toy` → **Save to File: on**, path `res://assets/models/blocks/candy_toy/blk_candy_toy_cube.res`. Confirm the per-mesh LOD option is off. Reimport.
2. Commit the resulting `.import` `_subresources` diff and the `.res`. **Do not hand-write the `_subresources` keys**: their exact format is not in the reference docs. Let the editor write them and diff.
3. Why: `BoardView` loads a `Mesh` straight from a stable path, without instancing a scene, and every board of that set shares one GPU mesh. Piece GLBs keep their embedded copy (only the shapes in play are loaded). Pointing all 67 piece imports at the same `.res` would save memory but risks reimport races (`ponytail:` skip until memory says otherwise).
4. Same steps for every future set. The import test enforces it (RND-01).

**Neon_voxel / multi-surface sets**: the board uses `material_override`, which covers *all* surfaces, so a glow surface would lose its emission. When a multi-surface set becomes real (not for first playable): give the saved cube `.res` per-surface materials (body = block toon ShaderMaterial, glow = the same shader with an `emission_strength` uniform). The `MultiMeshInstance3D` then uses no override. That is one chunk, gated on that set getting its cube GLB.

---

## 4. Per-biome theming hook (no code per biome)

Resolution, all by naming convention (no registry, a new set = new files only, ADR §7):

```
art_set   = LevelScene.@export art_set   (empty → biomes/<biome>.json "art_set" → &"candy_toy")
palette   = LevelScene.@export palette_id (empty → art_set id) → palette.json["palettes"][id]
            (missing → "candy_toy" + push_warning)
cube mesh = res://assets/models/blocks/<set>/blk_<set>_cube.res            (required)
piece     = res://assets/models/blocks/<set>/blk_<set>_<shape_id>.glb      (required)
material  = res://assets/shaders/materials/mat_block_<set>.tres            (optional, else mat_block_default.tres)
light/env = the level scene's own WorldEnvironment + DirectionalLight3D    (ambient tint = shadow colour)
```

- `ArtSet` (`src/view/art_set.gd`, the VEW-003 path helper, extended) is the single resolver. `BoardView.bind(board, look)` and `PieceView` take a resolved `BlockLook` (`RefCounted`: `cube_mesh`, `block_material`, `palette: PackedColorArray`) instead of loose meshes. `LevelScene.start()` builds it once.
- `palette.json` becomes `{"palettes": {"candy_toy": [...], "meadow": [...], ...}}`: index 0 = neutral (starter/hue 0), indices 1–10 = families in block-art-sets order. Values are copied from block-art-sets.md; art owns them. **This changes the implementation plan's `GameCatalog.palette: PackedColorArray` into a per-id table** (concern for the lead).
- The two new `LevelScene` exports are presentation only, which fits implementation-plan §2.2 rule 1.
- A level scene can therefore swap set, palette and lighting in the inspector. A new biome = set folder + palette entry + optional `mat_block_<set>.tres` + biome JSON.

---

## 5. Chunk list

Columns: **Files** = created (C) / edited (E). Tests are written first. Visual checks are windowed godot-ai screenshots kept under `production/qa/evidence/<chunk>/` (run-and-observe.md). **Do not assert on `MultiMesh` getters in headless tests**: headless uses the dummy rendering server, so instance data may not read back (unverified, but do not depend on it). Test the pure classes instead.

### Greybox (first playable)

| ID | Title | Files | Depends | Model | Tests-first acceptance |
|---|---|---|---|---|---|
| **RND-01** | Cube mesh `.res` + import contract test | E `assets/models/blocks/candy_toy/blk_candy_toy_cube.glb.import` (editor-written), C `blk_candy_toy_cube.res`, E `tests/unit/assets/block_set_import_test.gd` | none | Sonnet (editor via MCP) | New tests: every set with a cube GLB has `blk_<set>_cube.res`; the `.res` loads as `Mesh` with the same surface count and vertex count as the cube scene's root mesh; every block `.import` has `meshes/generate_lods=false` and `create_shadow_meshes=false` (read with `ConfigFile`). Records that neon_voxel lacks a cube GLB (existing test fails; do not "fix" it by skipping) |
| **RND-02** | Palette data | C `assets/data/palette.json` (candy_toy + Meadow from block-art-sets), C `src/view/palette_table.gd` (parse hex → `PackedColorArray`, fallback) | none | Haiku | `tests/unit/view/palette_table_test.gd`: 11 entries per palette (0 neutral + 10 families); bad hex → error; unknown id → candy_toy; **reserved-hue check**: no family hue within 25° of 186° (buff) or 322° (debuff) for saturated colours (block-art-sets rule) |
| **RND-03** | `ArtSet` resolver + `BlockLook` | C/E `src/view/art_set.gd`, C `src/view/block_look.gd` | RND-01, RND-02 | Sonnet | `tests/unit/view/art_set_paths_test.gd`: path strings for set/shape/cube; override order (export → biome dict → candy_toy); missing material → default; missing palette → candy_toy. Uses the real candy_toy files (no mocks needed). Merges with VEW-003's `art_set_paths_test` |
| **RND-04** | Slot map (pure) | C `src/view/slot_map.gd` | none | Sonnet | `tests/unit/view/slot_map_test.gd`: add/remove swap-last/move keeps `cell_to_slot`/`slot_to_cell` inverse; `filled` count; LAYOUT reset; remove of an empty cell is a no-op; returns the touched slots (for the uploader). Replaces VEW-002's `board_view_slots_test` |
| **RND-05** | `BlockViewMath` (pure) | C `src/view/block_view_math.gd` | none | Haiku | `tests/unit/view/block_view_math_test.gd`: `outline_world_width(px, ortho_size, vh)` (e.g. 2.5 px, size 16.87, 1920 px → 0.02197); `instance_color(hue, drop)` with drop clamped 0–32; `instance_custom(motif, status, counter, fade)` with range clamps (≤ 2048, [0,1]); `ripple_ranks(cleared_layers_bottom_up)`; `cut_plane(layer, down, board_xform)` |
| **RND-06** | Greybox BoardView (= **VEW-002**) | C `src/view/board_view.gd`, `board_view.tscn`, C `src/dev/board_view_debug.tscn/.gd` | RND-03, RND-04, RND-05, ADR-0002 delta (BRD) | Sonnet | Unit: `apply_delta` with a fake `BoardState` drives `SlotMap` + CPU colour mirror (SET/REMOVE/MOVE/LAYOUT). Visual: debug scene fills a default 8×8×12 board in family hues at 3 yaws, portrait + landscape. AC: formats before `instance_count`; `custom_aabb` set; `cast_shadow` off; StandardMaterial `vertex_color_use_as_albedo`; optional `grow` hull `next_pass` behind knob `view.outline_enabled`; records ADR item 2 |
| **RND-07** | Clear flash (dying MultiMesh + first shader) | C `assets/shaders/spatial_block_clear.gdshader`, E `src/view/board_view.gd` | RND-06 | Sonnet | Unit: `REMOVE(cause=CLEAR)` triples copy hue + ripple rank into the dying mirror; `clear_ms` only advances while Resolving; dying count resets after `t_resolve`. Visual: 1-, 2- and 4-layer clears captured mid-ripple (bottom layer whiter or smaller than the top); reduced-motion variant fades without shrinking |
| **RND-08** | Greybox PieceView + ghost (= **VEW-003**) | C `src/view/piece_view.gd`, `piece_view.tscn` | RND-03 | Sonnet | Unit: hue → cached material (one per hue, not per spawn); cube wrap for `blk_<set>_cube.glb`. Visual: piece + ghost at 2 orientations; the ghost stays visible behind a tall stack (`no_depth_test` stop-gap); knob `view.ghost_alpha` added to `knobs/view.json` |
| **RND-09** | Device stress test (ADR Validation 1) | C `src/dev/render_stress.tscn/.gd`, E ADR-0007 Verification table | RND-06 (hull toggle) | Sonnet + **user on device** | Scene fills 8×8×12 (and a 16×16×32 cap board), toggles hull/shadows, cycles 12 yaws, logs `Performance` frame times + draw calls (monitor name verified on 4.7) to `user://`. AC: numbers recorded **before** any toon shader work; decides whether RND-22 (culling) is needed |

**First playable gate** = RND-01…RND-08 plus APP-001. RND-09 should run in the same wave: it needs a device, not more code.

### Production shaders (after first playable)

| ID | Title | Files | Depends | Model | Tests-first acceptance |
|---|---|---|---|---|---|
| **RND-10** | Block toon shader (board) + per-set material | C `assets/shaders/block_common.gdshaderinc`, `spatial_block_toon.gdshader`, `materials/mat_block_default.tres`, E `board_view.gd` | RND-06, RND-09 results | Sonnet (shader-specialist review) | Visual: full board at 3 yaws; gloss stays upper-left at every yaw; gradient lighter on top; no EMISSION over 1 (glow on vs off identical). Verifies: `#include`, `diffuse_toon` on Mobile, `MODEL_MATRIX` includes the instance, instance-uniform cap. Tech-artist look sign-off |
| **RND-11** | Outline `next_pass` shader | C `spatial_block_outline.gdshader`, E `mat_block_default.tres`, E `board_view.gd` (width on resize), knobs `view.outline_px`, `view.outline_darken` | RND-10, RND-05 | Sonnet | Visual: outline measured at about 2–3 px in portrait **and** landscape (pixel count on the screenshot); hue-tinted, not black; no cracks at corners; `next_pass = null` removes it |
| **RND-12** | Piece variant shader | C `spatial_block_piece.gdshader`, `spatial_block_piece_outline.gdshader`, E `piece_view.gd` | RND-11 | Sonnet | Unit: PieceView sets `piece_hue/status/counter` on every cube child. Visual: the falling piece matches a locked block of the same hue side by side (no seam in look); the gradient stays world-up after tilt/roll |
| **RND-13** | Ghost shader | C `spatial_block_ghost.gdshader`, E `piece_view.gd`, knobs `view.ghost_density`, `view.ghost_lighten` | RND-12 | Sonnet | Visual: ghost readable on light and dark biomes at 28 px; dither stable while the piece moves (screen-space Bayer, ortho); no transparency pass in the frame debugger |
| **RND-14** | Theming hook wiring | E `src/app/level_scene.gd` (exports `art_set`, `palette_id`), E `art_set.gd`, data `biomes/meadow.json` `art_set` | RND-03, RND-10, APP-001 | Sonnet | Unit: `tests/unit/view/art_set_resolve_test.gd` with biome dict + export combinations. Data test: every `art_set` named in `biomes/*.json` has a cube `.res` and a palette (or an explicit fallback). Visual: meadow_01 with `palette_id` overridden shows the other palette, no code change |
| **RND-15** | Occlusion fade + cutaway (shader side) | E `block_common.gdshaderinc` (Bayer, cut plane), E `board_view.gd` (`set_faded`, `set_cutaway`), C `src/view/fade_tween.gd` (pure), remove ghost `no_depth_test` | RND-11, OcclusionAid DDA (camera owner), knobs `view.fade_ms`/`fade_alpha` (exist) | Sonnet | Unit `fade_tween_test.gd`: targets move linearly over `fade_ms`; only changed slots are reported; return-to-1 when uncrossed; > `max_faded_blocks` → cutaway request. Visual: fade in progress, cutaway, Camera AC 20–24 (outline fades too). **Overlaps MDW-007** (fog fade on `CUSTOM.a`): build this first, and MDW-007 only writes fade values |
| **RND-16** | Settle animation | E `block_common.gdshaderinc`, E `board_view.gd` (`play_settle`), E `block_view_math.gd` (`drop_cells(from, to, down)`) | RND-10 | Sonnet | Unit: drop distance for MOVE under −y, +y, ±x, ±z. Visual (ADR Validation): settle after a slice shift under −y, +y and ±x; finishes inside `clear.settle_ms` |
| **RND-17** | Status looks | C/E `assets/data/content/statuses.json` (look kind, accent per status), C `src/view/status_looks.gd` (pure: JSON → `status_kind[16]`, `status_accent[16]`), E toon shader branches (pulse / wobble / flicker / shadow-dither), project setting `shader_globals/reduced_motion` | RND-10, Block Status Effects content | Sonnet | Unit: ids > 15 rejected; unknown kind rejected; accents come from art bible §4.1 roles. Visual: each status at play size + reduced-motion variant (static). Shells and badges are separate (RND-18) |
| **RND-18** | Badges + countdown pips | C billboard-quad MultiMesh in `board_view.gd`, C `assets/shaders/spatial_block_badge.gdshader` | RND-17, icon atlas from art | Sonnet | Visual: badge + pips readable at 28 px; 1 draw call (monitor). Blocked until art ships icons |
| **RND-19** | PreviewBaker | C `src/view/preview_baker.gd` | RND-12 | Sonnet | Unit: atlas grid layout maths (cells per row, rects) pure. Visual: atlas PNG for the meadow piece set. Verifies ADR item 6 (readback after `frame_post_draw`) **on Android** |
| **RND-20** | Packed buffer upload (only if profiling asks) | E `board_view.gd`, E `block_view_math.gd` (`pack_instance` → 20 floats) | RND-09 numbers | Sonnet | Unit: 20-float layout (12 row-major 3×4 transform, 4 colour, 4 custom). Visual: one known instance renders identically to the setter path. Verifies ADR items 1 + 3 |
| **RND-21** | Warm-up + Shader Baker | E `level_scene.gd` (one-frame warm-up draw of every block material), export preset setting | RND-13 | Haiku | AC: no first-clear hitch on device (frame-time log); Shader Baker setting name recorded in ADR-0007 item 7 |
| **RND-22** | Hidden-cube culling (only if RND-09 fails the budget) | E `slot_map.gd` / C `src/view/hidden_cull.gd` (pure) | RND-09, RND-15 | Sonnet | Unit: a cube is hidden only if all 6 neighbours are solid, unfaded and inside the mask; the floor counts as cover; full 8×8×12 → 372 drawn. Visual: no holes visible at any yaw |
| **RND-23** | Multi-surface set support (neon_voxel) | E cube `.res` surface materials, E `board_view.gd` (no override when the mesh has materials) | RND-10 + neon_voxel cube GLB from art | Sonnet | Visual: the glow surface stays emissive on the board; draw calls = surfaces × passes |

---

## 6. Performance budget notes (mid-range phone: Adreno 610–619 / Mali-G57)

Rule of thumb (not sourced, per ADR): about 300–500k triangles per frame for the whole scene at 60 fps. candy_toy cube = 1014 v / 1728 t; the hull doubles it.

| Case | Cubes drawn | Tris (body + hull) | vs ~400k |
|---|---|---|---|
| Meadow-size board, ~40 % full (8×8×12) | ~300 | ~1.04M | ~2.6x over |
| Default full 8×8×12 | 768 | 2.65M | ~6.6x |
| Same + hidden-cube culling | ~372 | 1.29M | ~3.2x |
| **Largest legal board** (`board.max_cells` 8192, e.g. 24×24×14), 40 % full | ~3 300 | ~11.3M | ~28x: unplayable without a lighter cube |
| Largest, full, culled (24×24×14 → ~1 770 surface cubes) | ~1 770 | ~6.1M | ~15x |
| neon_voxel cube (384 v, est. ~600 t) on the default full board | 768 | ~0.9M | ~2.3x |

- **Draw calls are not the problem.** Board 1 (+1 hull) per surface; dying 1–2 only while Resolving; piece = 1 per cube per pass (4–8 typical, **27 cubes × 2 = 54 for `giant_mega_cube`**) plus the ghost again. A greybox board frame is about 20–40 draws; production about 30–60 per board (ADR estimate holds). If piece draws ever matter, the piece can become a 27-instance MultiMesh (2 draws), at the cost of per-cube hero props.
- **Vertices and micro-triangles are the problem.** At about 28 px per cube, 1728 triangles is close to one triangle per pixel. Tile GPUs shade 2×2 quads, so most of that work is wasted. The levers, in the order the ADR allows: shadows off on blocks (done in greybox) → hull off in the four-board tier → hidden-cube culling → a lighter board cube per set (**art direction's call**; the board takes `blk_<set>_cube.res`, so a lighter mesh there needs no code change).
- **Instance counts.** Allocate `instance_count = active_cell_count()` per LAYOUT (≤ 8192); draw `visible_instance_count = filled`. CPU mirror ≤ 8192 × 80 B = 640 KB, uploaded per delta, never per frame. Default board: 768 × 80 B = 61 KB.
- **CPU per frame**: O(1) while Live (no per-instance work); O(changed slots) per delta; `clear_ms`/`settle_t` writes are 1–2 uniform sets per frame during Resolving.
- **GPU target (tunable default, ADR)**: board ≤ 8 ms on the reference phone; VFX ≤ 2 ms (Game Feel F2). RND-09 sets the real numbers. **Recommend a render-side size cap** (for example warn in the level validator above a measured cube count) if the large-board numbers hold.
- Four-board view: ×4 everything above; it needs the quality tier (hull off, simple look) by default.

---

## 7. Verification items this plan relies on (all unverified on 4.7.2 until a chunk records them)

ADR-0007 items 1–7, plus: `.gdshaderinc` `#include` (RND-10) · `diffuse_toon` under Mobile (RND-10) · `MODEL_MATRIX` includes the MultiMesh instance (RND-10) · instance-uniform cap per shader (RND-10) · `StandardMaterial3D.grow` + `vertex_color_use_as_albedo` honouring MultiMesh instance colour (RND-06) · `MultiMesh.custom_aabb` (RND-06) · `shader_globals` project setting (RND-17) · draw-call monitor name (RND-09) · the Advanced Import "Save to File" `_subresources` format (RND-01, editor-written).
