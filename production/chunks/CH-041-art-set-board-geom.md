# CH-041 ArtSet + BoardGeom

**Story:** VEW-003 (folds RND-03) · **Model:** Sonnet · **Wave:** W2 · **Mode:** direct
**Goal:** one resolver for block-set files and one place for board-space maths (layout doc §4.3, §7).
**Depends:** CH-038 (PaletteTable, palette file), CH-079 (cube `.res`) · **Parallel-safe with:** W2
**Files:** new `src/view/art_set.gd`, `src/view/board_geom.gd`, `tests/unit/view/art_set_paths_test.gd`, `tests/unit/view/board_geom_test.gd`.

## API
```gdscript
class_name ArtSet extends RefCounted
## Block-set files for one set id. Usage: ArtSet.new(&"candy_toy").cube_mesh()
const BLOCKS_DIR := "res://assets/models/blocks/"
const PALETTES_DIR := "res://assets/data/palettes/"
const FALLBACK_SET := &"candy_toy"
static func resolve_set_id(stage_set: StringName, biome: Dictionary) -> StringName ## stage export -> biome.art_set -> FALLBACK_SET
static func available_sets() -> PackedStringArray     ## set dirs that have blk_<set>_cube.res (neon_voxel excluded today)
func _init(set_id: StringName) -> void
func set_id() -> StringName
func shape_scene_path(shape_id: StringName) -> String ## BLOCKS_DIR + "<set>/blk_<set>_<shape>.glb"
func shape_scene(shape_id: StringName) -> PackedScene ## null if missing
func cube_mesh() -> Mesh                              ## blk_<set>_cube.res; null if missing
func cube_scale() -> float                            ## 1.0 / longest AABB side of cube_mesh (candy_toy 1.03 -> ~0.971; GP-0 overlap fix); 1.0 if null
func palette() -> PaletteTable                        ## palettes/<set>.json, else the candy_toy palette
func block_material() -> StandardMaterial3D           ## cached; vertex_color_use_as_albedo = true

class_name BoardGeom extends RefCounted
## Board-anchor-space maths. Anchor = footprint centre at floor level (audit default).
static func cell_center(c: Vector3i, size: Vector3i) -> Vector3   ## (x - W/2 + 0.5, y + 0.5, z - D/2 + 0.5), float division
static func orient_basis(o: int) -> Basis                         ## basis * Vector3(v) == Vector3(Orientations.apply(o, v)) for all v
static func piece_root_transform(origin: Vector3i, o: int, source_pivot: Vector3, size: Vector3i) -> Transform3D
	## basis = orient_basis(o); position = cell_center(origin) - basis * source_pivot (layout doc §7)
```

## Tests first
`art_set_paths_test.gd` (real candy_toy files, no mocks):
1. `test_paths` — `shape_scene_path(&"l")` ends with `candy_toy/blk_candy_toy_l.glb`; `shape_scene(&"l") != null`; `shape_scene(&"nope") == null`.
2. `test_resolve_order` — (`&"x"`, {...}) -> `&"x"`; (`&""`, {"art_set":"candy_toy"}) -> candy_toy; (`&""`, {}) -> candy_toy.
3. `test_cube_mesh_and_scale` — candy_toy mesh not null; `cube_scale() * 1.03` ≈ 1.0 (0.01); neon_voxel `cube_mesh() == null`, not in `available_sets()`.
4. `test_palette_fallback` — `ArtSet.new(&"neon_voxel").palette().size() > 0`.
`board_geom_test.gd`:
5. `test_cell_center` — size (4,12,4): (0,0,0) -> (-1.5, 0.5, -1.5); (3,7,3) -> (1.5, 7.5, 1.5); size (5,·,5): (2,0,2) -> (0, 0.5, 0).
6. `test_orient_basis_matches_orientations` — all 24 o x unit vectors ±x/±y/±z.
7. `test_piece_root` — o 0, pivot (0,0,0): position == cell_center(origin).

## Run / Done when
`--import`, `-a res://tests/unit/view`. README "Done when"; 7 tests green.
**Out of scope:** BoardView/PieceView, biome theming wiring (later RND-14).
