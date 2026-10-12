# CH-157 OrthoFraming (ortho size, offsets, cube edge px)

**MB task:** MB-019 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-024 (CameraMath.ortho_size)
**Files:** new `src/view/camera/ortho_framing.gd`

## API
```gdscript
class_name OrthoFraming extends RefCounted
## Camera GDD F2 as pure static functions (ADR-0014 §2).
static func ortho_height(board_size: Vector3i, elevation_deg: float, margin: float) -> float
static func lens_size(ortho_h: float, viewport_h_px: float, board_rect: Rect2) -> float      ## size = ortho_h * viewport_h_px / board_rect.size.y
static func lens_offset(viewport: Vector2, board_rect: Rect2, px_per_unit: float) -> Vector2 ## h_offset / v_offset so the footprint centre lands at the board rect centre
static func cube_edge_px(ortho_h: float, board_rect: Rect2) -> float                         ## must be >= 20 (Board F5)
```

## Behaviour
- Reuse `CameraMath.ortho_size` for the footprint+height fit; this class adds the board-rect (HUD) projection and the 20 px check. Values from the Camera GDD F2; numbers in knobs `view.elevation_deg`, `view.margin` (callers pass them).
- Division guards: rect size <= 0 returns the unmodified `ortho_h` and prints a warning.

## How the integrator sees it working
Editor script eval for the 4x4x12 board, elevation 30, margin 0.5, board rect 360x380 in a 390x844 viewport: print the four values; expected `cube_edge_px` a plausible 40-70 px and >= 20. A 960x540 landscape rect prints a smaller but still >= 20 value.

**Out of scope: applying to a Camera3D (CH-159).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
