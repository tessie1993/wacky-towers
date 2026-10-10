class_name BlockViewMath extends RefCounted
## Pure helpers for block rendering (ADR-0007, block-rendering-plan §2.1).

const MAX_COUNTER := 2048   # block-rendering-plan §2.1 clamp


## World-space width of an outline that is px pixels wide on screen. Returns 0.0 when the viewport height is not positive.
## Usage: outline_world_width(2.5, 16.87, 1920.0) -> ~0.02197
static func outline_world_width(px: float, ortho_size: float, viewport_h_px: float) -> float:
	if viewport_h_px <= 0.0:
		return 0.0
	return px * ortho_size / viewport_h_px


## Per-instance CUSTOM data (block-rendering-plan §2.1): r = motif, g = status id, b = counter (clamped 0..MAX_COUNTER), a = fade (clamped 0..1).
## Usage: instance_custom(0, 0, 0, 1.0) -> Color(0, 0, 0, 1)
static func instance_custom(motif: int, status: int, counter: int, fade: float) -> Color:
	return Color(
		float(motif),
		float(status),
		float(clampi(counter, 0, MAX_COUNTER)),
		clampf(fade, 0.0, 1.0)
	)


## Ripple ranks for cleared layers, sorted ascending; rank 0 = bottom layer.
## Usage: ripple_ranks(PackedInt32Array([5, 2, 3])) -> PackedInt32Array([2, 3, 5])
static func ripple_ranks(cleared_layers: PackedInt32Array) -> PackedInt32Array:
	var ranks: PackedInt32Array = cleared_layers.duplicate()
	ranks.sort()
	return ranks
