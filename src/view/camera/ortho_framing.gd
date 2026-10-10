class_name OrthoFraming extends RefCounted
## Camera GDD F2 as pure static functions (ADR-0014 §2): board-rect (HUD) projection on top of CameraMath.ortho_size.

const MIN_CUBE_EDGE_PX: float = 20.0  ## Board GDD F5 legibility floor; callers compare cube_edge_px against it
const _NO_WIDTH_LIMIT_ASPECT: float = 1.0e6  ## aspect so wide that ortho_size's width term never wins


## Vertical world extent that fits the board at every yaw (height term; the width term is the caller's board_rect aspect).
## Usage: ortho_height(Vector3i(4, 12, 4), 30.0, 0.5)
static func ortho_height(board_size: Vector3i, elevation_deg: float, margin: float) -> float:
	return CameraMath.ortho_size(board_size, elevation_deg, _NO_WIDTH_LIMIT_ASPECT, margin)


## Camera3D.size so ortho_h world units fill board_rect's height inside a viewport of viewport_h_px.
## Rect height <= 0 returns ortho_h with a warning.
static func lens_size(ortho_h: float, viewport_h_px: float, board_rect: Rect2) -> float:
	if board_rect.size.y <= 0.0:
		push_warning("OrthoFraming.lens_size: board_rect height <= 0")
		return ortho_h
	return ortho_h * viewport_h_px / board_rect.size.y


## Camera3D (h_offset, v_offset) in world units so the board centre, which sits at the viewport centre by default,
## lands at board_rect's centre. px_per_unit = viewport_h_px / lens size. px_per_unit <= 0 returns ZERO with a warning.
static func lens_offset(viewport: Vector2, board_rect: Rect2, px_per_unit: float) -> Vector2:
	if px_per_unit <= 0.0:
		push_warning("OrthoFraming.lens_offset: px_per_unit <= 0")
		return Vector2.ZERO
	var delta: Vector2 = board_rect.get_center() - viewport * 0.5  # px, y down
	return Vector2(-delta.x, delta.y) / px_per_unit  # frustum moves opposite to the content horizontally, with it vertically


## On-screen length in px of one world unit (a cube edge) when ortho_h fills board_rect's height. Must be >= MIN_CUBE_EDGE_PX.
## Rect height or ortho_h <= 0 returns 0 with a warning.
static func cube_edge_px(ortho_h: float, board_rect: Rect2) -> float:
	if ortho_h <= 0.0 or board_rect.size.y <= 0.0:
		push_warning("OrthoFraming.cube_edge_px: non-positive input")
		return 0.0
	return board_rect.size.y / ortho_h
