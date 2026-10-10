# CH-024 CameraMath.ortho_size

**Story:** VEW-004
**Goal:** one orthographic size that fits the whole board (footprint + all layers incl. spawn zone) at all 12 yaws (Camera GDD rule 4, F2).
**Depends:** CH-023
**Parallel-safe with:** every batch-2 ticket except CH-023, CH-025
**Files:** `src/view/camera_math.gd` (edit: add 1 func), `tests/unit/view/camera_math_test.gd` (edit: append)

## API (add)

```gdscript
static func ortho_size(board_size: Vector3i, elevation_deg: float, aspect: float, margin: float) -> float
	## board_size = (W, board_height, D); aspect = board screen area width / height; margin in cells.
	## Returns the Camera3D.size (vertical extent, keep_aspect = KEEP_HEIGHT).
```

## Formula (Camera GDD F2)

- `Ws = max over k in 0..11 of ( W·|cos yaw_k| + D·|sin yaw_k| )`, yaw_k from `yaw_degrees(k, DEFAULT_BASE_DEG, DEFAULT_STEP_DEG)`.
- `Hs = Ws·sin(elev) + H·cos(elev)`.
- Add `margin` to both, then `return max(Hs + margin, (Ws + margin) / aspect)`.
- `aspect <= 0` is a caller bug (document, no check).

## Tests to write first (append; tolerance 0.01)

1. `test_ortho_default_board_landscape` — `(6,14,6)`, 30°, aspect `1139.0/673.0`, margin 0.5 -> **16.87** (GDD F2 example: 8.49·0.5 + 14·0.866 + 0.5).
2. `test_ortho_width_binding` — same board, aspect 0.5 -> **17.97** ((8.485 + 0.5) / 0.5).
3. `test_ortho_8x8x16` — `(8,16,8)`, 30°, aspect 1.692, margin 0.5 -> **20.01**.
4. `test_ortho_widest_yaw_is_corner` — `(6,14,6)`: the max term equals `6·cos45 + 6·sin45` (8.485) — assert via a margin-0, elevation-0 call
   with aspect 1.0: result == max(14.0, 8.485) == 14.0, and with aspect 0.1 == 84.85.

## Run
`-a res://tests/unit/view` (README).

## Done when
README "Done when" + all camera_math tests green.
