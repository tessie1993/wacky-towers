# CH-081 BlockViewMath (pure)

**Story:** VEW-002 (RND-05) · **Model:** Haiku · **Wave:** W1 · **Mode:** direct
**Goal:** the pure numbers BoardView and the block shaders share, testable without a GPU.
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `src/view/block_view_math.gd`, new `tests/unit/view/block_view_math_test.gd`.
Read `production/orchestration/block-rendering-plan.md` §2.1 only (per-instance data layout) for the `instance_custom` channel order.

## API
```gdscript
class_name BlockViewMath extends RefCounted
## Pure helpers for block rendering (ADR-0007, block-rendering-plan §2.1).
const MAX_COUNTER := 2048   # block-rendering-plan §2.1 clamp
static func outline_world_width(px: float, ortho_size: float, viewport_h_px: float) -> float  ## px * size / vh; vh <= 0 -> 0.0
static func instance_custom(motif: int, status: int, counter: int, fade: float) -> Color       ## channels per §2.1; counter 0..MAX_COUNTER, fade 0..1
static func ripple_ranks(cleared_layers: PackedInt32Array) -> PackedInt32Array               ## sorted ascending; rank 0 = bottom layer
```

## Tests first (`block_view_math_test.gd`)
1. `test_outline_width` — (2.5, 16.87, 1920) ≈ 0.02197 (tolerance 1e-5); vh 0 -> 0.0.
2. `test_custom_clamps` — counter 5000 encodes as 2048; fade -1 -> 0, 2 -> 1.
3. `test_custom_default` — (0, 0, 0, 1.0) == `Color(0, 0, 0, 1)` (GP-0 default custom data).
4. `test_ripple_ranks` — [5, 2, 3] -> [2, 3, 5].

## Run / Done when
`--import`, `-a res://tests/unit/view`. README "Done when"; 4 tests green.
**Out of scope:** cut planes, colour drop (later shader tickets).
