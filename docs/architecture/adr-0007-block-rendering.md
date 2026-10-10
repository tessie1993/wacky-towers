# ADR-0007: Block Rendering

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-09

## Last Verified

2026-10-09

## Decision Makers

Tessa (user), godot-specialist (architecture lead), engine-programmer (author). The `technical-artist` and `art-director` are to be consulted on the shader look and on the vertex-budget risk.

## Summary

Locked blocks, the falling piece, the ghost, occlusion fades, outlines, status looks and piece previews all have to read clearly at about 28 px on a mid-range Android phone. The art bible's ~1000-vertex cubes put the vertex budget at risk. Decision:
- **Locked blocks:** one packed `MultiMeshInstance3D` per board, with per-instance hue, motif, status and fade data.
- **Falling piece and ghost:** GLB scenes.
- **Outline:** an inverted-hull `next_pass`.
- **Occlusion fade:** dithered, and it fades the outline too.
- **Status looks:** done in the shader.
- **Previews:** baked once per shape into an atlas.
- **Vertex cost:** recorded as a risk to measure on a device, with an engine-side mitigation ready.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2, Mobile renderer (Vulkan on Android) |
| **Domain** | Rendering |
| **Layer** | Presentation |
| **Knowledge Risk** | HIGH. The Mobile renderer, MultiMesh buffer layout and 4.5–4.7 shader features are past the model's training data, and `modules/rendering.md` does not cover MultiMesh or instance uniforms. |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/rendering.md`, `breaking-changes.md`, `current-best-practices.md` (Shader Baker 4.5, stencil buffer 4.5), `design/art/art-bible.md` (Materials, LOD and VFX), the `candy_toy` GLBs (inspected) |
| **Post-Cutoff APIs Used** | Shader Baker (4.5) for export: recommended, setting name not verified. No other post-cutoff API is required. |
| **Verification Required** | Each item below is **unverified on 4.7.2**:<br>(1) MultiMesh buffer layout with `TRANSFORM_3D` + colours + custom data is 20 floats per instance, in the order 12 transform, 4 colour, 4 custom, with the transform stored row-major 3×4.<br>(2) `use_colors` / `use_custom_data` / `transform_format` must be set while `instance_count == 0`, and are reset otherwise.<br>(3) Precision of `INSTANCE_CUSTOM` and `COLOR` under the Mobile renderer (possibly half-float). This ADR keeps every packed value an integer ≤ 2048 or a value in [0,1] so half precision is safe.<br>(4) `instance uniform` on a `MultiMeshInstance3D` under Mobile.<br>(5) `discard` in an opaque material on a tile-based GPU: early-Z loss is measured, not assumed.<br>(6) Viewport readback (`get_texture().get_image()`) after `RenderingServer.frame_post_draw` on Android Vulkan.<br>(7) The Shader Baker export setting name in 4.7. |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (view reads events only; interpolation), ADR-0002 (delta ops, down axis, `get_kind`), ADR-0003 (shape bank cube offsets from GLB node translations) |
| **Enables** | Game Feel & VFX (clear ripple, settle), Camera occlusion aid, HUD previews, Block Status Effects visuals |
| **Blocks** | Board view story; first playable screenshot evidence |
| **Ordering Note** | Build the block shader plus MultiMesh first, using flat hue and no outline, then add the outline, fade and status passes. Run the device stress test (Validation) before Alpha content. |

## Context

### Problem Statement

A full default board (8×8, 12 playable layers) is 768 cubes. Drawn as separate nodes that is hundreds of draw calls. Several design rules also need decisions:
- Camera GDD: blocks in front of the piece must fade without visual mess.
- Art bible: a hue-tinted, constant-width outline.
- Block Status Effects GDD: every status is animated, pulses and shows an icon badge.
- User decision: previews are drawn once per shape.

The art cubes are detailed, so the vertex count is the risk to manage.

### Current State

- `src/dev/block_set_preview.gd` instances GLB scenes directly. Fine for a dev preview; not usable for a board.
- Inspected `candy_toy` GLBs: every cube in every piece references **one shared mesh**, `cube_candy_toy`, with 1014 vertices and 1728 triangles (POSITION, NORMAL, TEXCOORD_0, TANGENT) and **no material**.
- The root carries glTF extras `{shape, look, cubes, family}`.
- Cube node names use Blender axes (`c0_1_0` sits at translation (0,0,−1)). The shape bank must read translations, not names (ADR-0003).
- `blk_<set>_cube.glb` imports with the MeshInstance3D itself as the root and no pivot empty (see `tools/asset-pipeline/block_post_import.gd`).

### Constraints

- Mobile renderer; Android mid-range is the reference (Adreno 610–619 / Mali-G57 class).
- A shared set of about five shaders (art bible); per-instance parameters instead of one-off materials.
- No Blender work and no generated meshes (user decision, round 2). GLBs come from art direction.
- 12 camera yaws in orthographic projection; both portrait and landscape.
- The board may have gravity along any of 6 directions (ADR-0002).

### Requirements

- About 2 draw calls for all locked blocks of a board, plus a few for statuses and badges.
- No per-frame CPU work proportional to block count. Updates happen per delta (per lock or clear).
- Fade toward alpha 0.3 over 100 ms; fallback to Cutaway above 40 faded blocks (Camera F4).
- Constant-width, hue-tinted outline.
- A status is recognisable by animation, rim pulse and badge, not by texture.
- The falling piece, its ghost and the height line are never faded.

## Decision

### 1. Locked blocks: one packed MultiMesh per board

`BoardView` (Node3D, one per board) owns a `MultiMeshInstance3D`. It rebuilds on `LAYOUT` and applies the other delta ops (ADR-0002) incrementally.

```gdscript
var mm := MultiMesh.new()
mm.transform_format = MultiMesh.TRANSFORM_3D  # set all three formats BEFORE instance_count
mm.use_colors = true
mm.use_custom_data = true
mm.mesh = set_cube_mesh                        # the shared cube mesh of the active art set
mm.instance_count = board.active_cell_count()  # allocated once per layout, never during play
mm.visible_instance_count = 0
```

- **Packed slots.** Only filled cells get an instance. The view keeps `cell_to_slot` and `slot_to_cell` (both `PackedInt32Array`). A removal swaps the last slot into the hole. `visible_instance_count = filled`. Empty cells are not drawn with zero scale, because they would still pay full vertex cost.
- **Upload.** A CPU mirror `PackedFloat32Array` (capacity × 20) is updated for the changed slots. The whole buffer is then pushed once per delta through `RenderingServer.multimesh_set_buffer`. Even the largest board (8192 × 80 B) is 640 KB, and an upload happens only once per lock or clear.
- **Per-instance data.** Every value is an integer ≤ 2048 or lies in [0,1], so it is safe at half precision.

  | Channel | Content |
  |---|---|
  | TRANSFORM | the cell's position in board space (identity basis) |
  | COLOR.rgb | hue tint (palette lookup on the CPU) |
  | COLOR.a | settle drop distance in cells (0–32) |
  | CUSTOM.r | motif atlas index |
  | CUSTOM.g | status id (0 = none) |
  | CUSTOM.b | status counter or phase (countdown pips) |
  | CUSTOM.a | fade (1 = opaque, 0 = fully faded) |

- **Settle animation without per-instance CPU work.** After a `MOVE`, the instance is written at its new cell with `COLOR.a = cells dropped`. The vertex shader offsets the cube back by `−down × drop × (1 − settle_t)`, where `down` is the board's down vector (any of 6). `settle_t` is a per-board `instance uniform` animated 0→1 over `clear_settle_ms`. If (4) fails verification, it becomes a per-board material copy (≤ 4 boards).
- **Clear ripple.** Removed cubes are copied into a second, reusable "dying" MultiMesh with a dissolve parameter. It only draws during Resolving.
- **Interpolation.** Locked blocks never move between ticks, so ADR-0001's interpolation applies only to the falling piece.

### 2. Falling piece, ghost and previews: GLB scenes

- **Falling piece.** An instance of the shape's GLB scene: the root is the pivot empty and the cube `MeshInstance3D` children sit at integer offsets. `material_override` on each cube is the **piece variant** of the same block shader, which reads hue, motif and status from `instance uniform`s, because `INSTANCE_CUSTOM` only exists for MultiMesh. Position and rotation are interpolated between ticks.
- **Ghost.** The same GLB, with a ghost material: an unshaded, dithered tint plus the outline.
- **`blk_<set>_cube.glb`.** It has no pivot empty, so the piece loader wraps it in a `Node3D`. A cleaner fix in the post-import script is a follow-up for whoever owns `tools/asset-pipeline/`; it is not done here.
- **Physics Mode (Alpha).** Settled pieces stay as GLB scenes while active. Frozen pieces fold into a free-transform MultiMesh, because 100 frozen pieces as scenes would cost about 1000 draw calls. This is decided in detail when Physics Mode is built.

### 3. Outline: inverted hull

- The outline is a `next_pass` material on the block shader (and on the piece variant): `render_mode cull_front, unshaded`, with vertices pushed out along NORMAL by `outline_width`.
- The camera is orthographic with one fixed size per level (Camera F2), so a world-space width gives a constant screen width: `outline_width = outline_px × ortho_h / viewport_height_px`. It is recomputed when the viewport resizes (portrait or landscape).
- Colour: `COLOR.rgb × outline_darken`, a darker tint of the piece's own hue (art bible).
- Cost: a second vertex pass over every drawn cube, which **doubles vertex cost**. The fragment cost is small: thin slivers only.
- **Rejected: post-process edge detection.** It needs a full-screen depth and normal read, which costs bandwidth on tile-based GPUs. It cannot tint per piece. It also depends on Compositor support in the Mobile renderer, which is not verified for 4.7.

### 4. Occlusion fade: dithered, outline included

- **When it runs:** only when the piece moves or rotates, the ghost changes, or the camera turns. Not every frame.
- **What fades:** for each cube of the piece and ghost, the CPU walks a 3D grid line (DDA) through board cells toward the camera, using the inverse of the camera's forward vector in board space, and collects occupied cells. Cost: ≤ 16 rays × ≤ 24 cells, about 0.2–0.5 ms in GDScript on a phone (estimate).
- **Fallback:** if more than `max_faded_blocks` (40) would fade, Cutaway is used for that frame (Camera F4). Cutaway is a per-board uniform `cut_layer` plus the down vector, and the shader discards everything above it.
- **Tweening:** fade values move over `fade_ms`, only for the changed slots (≤ 80 at once), through `multimesh.set_instance_custom_data`. The CPU mirror is kept in sync.
- **Shader:** both the block pass and the outline pass discard where `CUSTOM.a < bayer4x4(FRAGCOORD.xy)`. The geometry stays in the opaque pass, so there is no sorting and no blend overdraw.
- **Faded blocks fade their outline too** (user decision, round 2). This **changes `design/gdd/camera-rotate-view.md`** rule 12 ("with its outline kept"), its Visual Requirements ("Faded blocks keep their outline") and AC 20. This ADR does not edit the GDD. The owner (game-designer / camera GDD author) should update it.
- **Never faded:** the falling piece, the ghost and the height line. They do not use the board MultiMesh, so this follows automatically.

### 5. Status looks

- **Shader branch on `CUSTOM.g`.** Each status has an animation from `TIME`: pulse, a wobble in the vertex stage (≤ 8 % of the cube edge, inside the art bible shell envelope), or flicker. Each also has a rim in its buff/debuff accent colour. Shadow status uses the same dither at `invisible_alpha`.
- **Geometry shells** (frost caps, vines and so on, when art provides them): one MultiMesh per shell type in use on that board. It is created when that status first appears and freed when no cube has it. Until shell GLBs exist, statuses are shader-only.
- **Badges and countdown pips:** one billboard-quad MultiMesh per board. `CUSTOM.r` holds the icon atlas index and `CUSTOM.b` the pip count. That is 1 draw call.
- **Shader variants** are kept to one block shader with uniform branches (no `#define` permutations per status). Export uses the Shader Baker (4.5+) to avoid first-use compile hitches; the setting name needs verifying for 4.7.

### 6. Previews: baked once per shape

- At level load, `PreviewBaker` builds one `SubViewport` with `own_world_3d = true`, `transparent_bg = true` and `render_target_update_mode = UPDATE_ONCE`. It contains an orthographic camera and **every shape in the level's piece set laid out in a grid**, rendered at 256 px per cell.
- After one `RenderingServer.frame_post_draw`, `get_texture().get_image()` becomes one `ImageTexture` atlas. Each shape is an `AtlasTexture`, cached by `(art_set, shape_id)`. Then the viewport is freed.
- Cost: one render plus one GPU readback per level load. There are no live viewports during play. Next and hold slots are `TextureRect`s.

### 7. Budget (estimates, to measure on a device)

Reference: mid-range Android at 60 fps. From experience, a comfortable load is about 300–500k triangles per frame for the whole scene. This is a rule of thumb, not a sourced figure.

| Case (one board) | Cubes drawn | Vertices (block + hull) | Triangles (block + hull) |
|---|---|---|---|
| Typical mid-game (~40 % full) | ~300 | ~0.61M | ~1.04M |
| Full 8×8×12, no culling | 768 | 1.56M | 2.65M |
| Full 8×8×12, hidden-cube culling (mitigation 1) | ~372 | ~0.75M | ~1.29M |
| + shadow pass (if blocks cast shadows) | — | +50 % | +50 % |
| Four-board view | ×4 | — | — |

Draw calls per board:

| Item | Draw calls |
|---|---|
| Blocks + outline | 2 |
| Each active shell type | 2 |
| Badges | 1 |
| Falling piece (≈ 4–8 cubes × 2 passes) | 8–16 |
| Ghost | 4–8 |
| Dying MultiMesh (during clears) | 2 |
| Island / board tiles | ~10–20 |
| **Total** | **≈ 30–50** |

A shadow pass roughly doubles the board part. Four boards come to about 200. Draw calls are not the problem; **vertex count is**. Also, at ~28 px on screen a 1014-vertex cube is close to one vertex per pixel. Such tiny triangles waste GPU work on any phone.

**Mitigation ladder** (in order; no Blender work planned):
1. **Hidden-cube culling (engine side, no art).** Skip the instance, and so its hull, for a cube whose 6 face-neighbours are all solid, none faded, and not past a board edge or masked cell. The floor counts as cover, because the camera never looks from below. For a full 8×8×12 board this removes 6×6×11 = 396 of 768 cubes (52 %). It is recomputed per delta for the touched cells and their neighbours, and for the faded set. **Built only if the device test fails the budget** (`ponytail:` the extra fade/neighbour bookkeeping isn't worth paying before a measurement says so).
2. **Locked blocks cast no shadows.** The light setup is art direction's call (art bible trade-off 5).
3. **A lighter board cube per art set.** `BoardView` takes the board mesh from the set and falls back to the shared cube mesh. If art direction later ships a lighter board variant in a set's GLB, it is used with no code change. **Art direction decides whether and when; nothing is planned now.**
4. **Four-board quality tier** (art bible): a thinner outline or no outline, and the simple motif.

### 7. Data and extension points (lead-architect review, 2026-10-09)

Follows the modular principle in `architecture.md`; no visual value or content list is a code constant.
- **Tunables** (`fade_ms`, `outline_darken`, `invisible_alpha`, preview cell px, the GPU budget) are knobs in `res://assets/data/knobs/view.json` (ADR-0004 knob registry, ADR-0005 JSON).
- **Palette:** hue ids map to colours through `res://assets/data/palette.json`, the art docs' colour definition as data. The board stores only hue ids (ADR-0002 `color`, ADR-0003 `ShapeDef.hue_id`).
- **Block sets:** chosen by `set_id`. Meshes are found by the existing naming convention `res://assets/models/blocks/<set_id>/blk_<set_id>_<shape_id>.glb` (cube mesh: `blk_<set_id>_cube*.glb`). A new set is new files only.
- **Status looks:** each status id maps to a look entry (animation kind, accent colour, optional shell GLB) in `res://assets/data/content/statuses.json`, next to the gameplay content table (ADR-0002 `ContentTypes`). The shader branches on a small set of look **kinds**, not on status ids, so a new status that reuses a kind is data only. A new look kind is one shader branch.
- **Object/overlay meshes** (obstacles, spawned objects) are named per content type in the same content table. The view renders any type it finds there.
- **Several boards per level** (islands, lanes, ADR-0002 section 7): one `BoardView` per board, each placed by its board's `world_transform` from level data. Diorama dressing (floating island meshes, track pieces) is a per-biome scene named in data (`res://assets/data/biomes/<biome>.json`), never hard-wired.

### Architecture

```
BoardController ─cells_changed(delta)─▶ BoardView (Node3D, per board)
                                          ├─ blocks: MultiMeshInstance3D  (block.gdshader + outline next_pass)
                                          ├─ dying:  MultiMeshInstance3D  (clear ripple, Resolving only)
                                          ├─ shells[type]: MultiMeshInstance3D (lazy)
                                          ├─ badges: MultiMeshInstance3D  (billboards)
                                          ├─ piece:  GLB scene (piece material variant, interpolated)
                                          └─ ghost:  GLB scene (ghost material)
Camera ─yaw/forward─▶ OcclusionAid ─fade slots / cut_layer─▶ BoardView
Level load ─piece set─▶ PreviewBaker (SubViewport, once) ─AtlasTexture per shape─▶ HUD
```

### Key Interfaces

```gdscript
class_name BoardView extends Node3D
func bind(board: BoardState, art_set: StringName) -> void   # builds the MultiMesh (LAYOUT)
func apply_delta(delta: PackedInt32Array) -> void           # SET/REMOVE/MOVE/STATUS/OVERLAY/LAYOUT
func play_settle(duration_ms: int) -> void                  # animates settle_t 0→1
func set_faded(cells: PackedInt32Array) -> void             # tween target fade for these cells, others to 1
func set_cutaway(layer: int) -> void                        # -1 = off

class_name PreviewBaker extends RefCounted
static func bake(art_set: StringName, shape_ids: PackedStringArray, host: Node) -> Dictionary  # shape_id -> AtlasTexture (awaits one frame)
```

### Implementation Guidelines

- Shared, documented per-instance layout (the table in section 1). Both the shader and `BoardView` cite this ADR.
- Never set `instance_count` during play; resize only on `LAYOUT`.
- **Debug view first** (2026-10-10, implementation plan VEW-002): the first `BoardView` uses per-instance setters (`set_instance_transform`, `set_instance_color`) and a flat-hue `StandardMaterial3D`; the packed `multimesh_set_buffer` upload replaces them only when profiling asks for it. This defers verification items 1 and 3.
- No `MeshInstance3D` per locked cube anywhere, including debug paths.
- Screenshot evidence for the board, fade, outline and each status goes in `production/qa/evidence/` (coding standards: Visual/UI rows).
- The shader specialist (`godot-shader-specialist`) writes `block.gdshader` against the layout here. The technical-artist signs off the look.

## Alternatives Considered

### Alternative 1: One `MeshInstance3D` per cube
- **Pros**: Simplest code; each cube is its own node.
- **Cons**: 768+ draw calls per board, and ×2 with the outline.
- **Rejection Reason**: Draw calls and scene-tree overhead on a phone.

### Alternative 2: Zero-scale instances for empty cells (fixed slot per cell)
- **Pros**: No slot bookkeeping.
- **Cons**: Empty cells still pay full vertex cost.
- **Rejection Reason**: Vertex count is the budget at risk.

### Alternative 3: Alpha-blended fade
- **Cons**: Needs sorting, the hull and the faces show through each other, and blending adds overdraw.
- **Rejection Reason**: Dithering stays opaque and readable at 28 px.

### Alternative 4: Stencil-buffer x-ray (4.5+)
- **Rejection Reason**: The reference docs give no API detail for 4.7; unverified. Revisit if dithering reads badly in playtests.

### Alternative 5: Post-process outline (Compositor)
- **Rejection Reason**: See section 3: bandwidth on tile-based GPUs, no per-piece tint, unverified on Mobile.

### Alternative 6: A light cube generated in code
- **Rejection Reason**: User decision, round 2. Meshes come from the Blender GLBs; art direction owns the look.

### Alternative 7: Live SubViewport per preview slot
- **Rejection Reason**: User decision, round 2 (bake once per shape). Live viewports are extra render passes every frame.

## Consequences

### Positive
- A few draw calls per board. CPU work happens per delta, not per frame.
- One block shader serves board, piece, ghost, statuses and fades.
- Works for any of the 6 gravity directions through one down-vector uniform.

### Negative
- The outline doubles vertex cost on cubes that are already heavy. The budget depends on a device measurement.
- `discard` (dither, cutaway) may cost early-Z on tile-based GPUs. Measured, not assumed.
- Slot bookkeeping (`cell_to_slot`) in the view.
- **Design change:** faded blocks lose their outline. camera-rotate-view.md needs an update by its owner.

### Neutral
- Previews show the real piece, but static (no spin).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| 1014-vertex cubes plus hull exceed the GPU budget on the reference phone | High | High | Device stress test before Alpha; mitigation ladder in section 7. The lighter mesh is for art direction to decide later. |
| MultiMesh buffer layout or precision differs on 4.7 Mobile | Medium | Medium | Verification items 1–3; one unit/visual test writes a known instance and checks the screenshot |
| `instance uniform` unsupported on MultiMesh under Mobile | Medium | Low | Per-board material copy |
| `discard` makes the board fragment-bound | Medium | Medium | Measure; move faded instances to a small second MultiMesh so the main one has no discard |
| Hull outline cracks on hard-edged normals in some art sets | Medium | Low | Visual check per set; art direction smooths hull normals or the shader extrudes along vertex position from the cube centre |
| First-use shader compile hitch on Android | Medium | Medium | Shader Baker on export; warm-up draw at level load |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | — | < 0.3 ms per frame; ≤ 2 ms on a delta frame (buffer rebuild + DDA) | 1 ms view per board, average |
| GPU (frame time) | — | **Unknown: measure.** At risk for full boards with full-detail cubes | Board ≤ 8 ms on the reference phone (tunable default) |
| Memory | — | ≤ 640 KB CPU buffer at the largest cap; ~64 KB on the default board; preview atlas ≤ 4 MB | 8 MB view per board |
| Load Time | — | preview bake ≈ 1 frame + readback | < 100 ms |

## Migration Plan

`src/dev/block_set_preview.gd` stays as a dev tool. Nothing in the game path uses it.

**Rollback plan**: If the MultiMesh path fails verification, `BoardView` can temporarily fall back to per-cube `MeshInstance3D` for small boards. The delta API does not change.

## Validation Criteria

- [ ] **Device stress test.** A dev scene fills an 8×8×12 board; toggles outline, shadows and fade; and runs at 12 yaws. GPU and CPU frame times on the reference phone are recorded before any mitigation, and after each one that is used.
- [ ] Draw calls ≤ 50 per board (Godot monitor `RENDER_TOTAL_DRAW_CALLS_IN_FRAME`, name to verify for 4.7) on the default board, excluding environment.
- [ ] Camera AC 20–24 pass, with AC 20 amended for outline fading.
- [ ] Screenshots in `production/qa/evidence/`: full board, a fade in progress, cutaway, each status, and the preview atlas.
- [ ] A settle after a slice shift animates correctly under −y, +y and ±x gravity.
- [ ] All 7 Verification Required items are checked on 4.7.2 and recorded here.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/camera-rotate-view.md` | Camera | Fade occluding blocks to alpha 0.3 over 100 ms; Cutaway fallback above 40; piece, ghost and height line never hidden | Section 4 (outline now fades too: a GDD change for its owner) |
| `design/gdd/layer-clearing.md` | Layer Clearing | Bottom-to-top ripple, settle within `t_resolve` | Dying MultiMesh, `settle_t` uniform, `MOVE` ops |
| `design/gdd/block-status-effects.md` | Block Status Effects | Status recognised by animation, colour pulse and badge | Section 5 |
| `design/gdd/game-feel-vfx.md` | Game Feel & VFX | Clarity first; VFX frame budget | No effect on the piece or ghost; view CPU per delta only |
| `design/art/art-bible.md` | Art | One MultiMesh per board per mesh type; inverted-hull hue-tinted constant-width outline; ~5 shared shaders; no auto LOD on blocks | Sections 1, 3, 5, 7 |
| `design/gdd/board-grid.md` | Board / Grid | Cube edge ≥ 20 px (28 px target) | Outline width derived from ortho size; previews independent of board size |

## Open Items

1. **Camera GDD update** (owner: camera GDD author): faded blocks lose their outline (rule 12, Visual Requirements, AC 20).
2. **Cutaway "outlines only"**: the default here is that hidden layers are hidden. Outline-only cutaway with an inverted hull looks like a dark shell, not a wireframe. Art direction to decide.
3. **Vertex budget**: measure first. A lighter board cube is art direction's decision; no Blender work is planned.
4. **Physics Mode frozen-piece batching**: decided when Physics Mode is built.
5. **`blk_<set>_cube.glb` root contract**: the loader wraps it for now. A post-import fix is optional; its owner decides.

## Related

- ADR-0001, ADR-0002, ADR-0003, ADR-0008.
- `design/art/art-bible.md` (Materials, LOD and VFX; trade-offs 1–5), `design/gdd/camera-rotate-view.md`.
- `src/dev/block_set_preview.gd`, `tools/asset-pipeline/block_post_import.gd`.
