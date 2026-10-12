class_name OrientationLayout extends Node
## Child of a screen root (ADR-0016 §4). Watches the viewport, applies safe-area margins to [member safe_target]
## and emits [signal changed] so the screen can flip the few nodes that move. One node tree for P and L.
## ponytail: no LayoutProfile resources yet; screens flip their own nodes in the signal handler. Add profiles when 3+ screens share a pattern.

## Emitted on ready and on every viewport size change.
signal changed(is_landscape: bool)

## Control that receives the safe-area insets as offsets (should be full-rect anchored).
@export var safe_target: Control
## Swap left/right insets (HUD mirror later).
@export var mirrored: bool = false

var is_landscape: bool = false


func _ready() -> void:
	get_viewport().size_changed.connect(refresh)
	refresh.call_deferred()


## Re-reads the viewport size and safe area, then emits [signal changed].
func refresh() -> void:
	var s: Vector2 = get_viewport().get_visible_rect().size
	is_landscape = s.x > s.y
	if safe_target != null:
		var m: Rect2i = _safe_margins()
		var l: int = m.size.x if mirrored else m.position.x
		var r: int = m.position.x if mirrored else m.size.x
		safe_target.offset_left = l
		safe_target.offset_top = m.position.y
		safe_target.offset_right = -r
		safe_target.offset_bottom = -m.size.y
	changed.emit(is_landscape)


## Insets as Rect2i(position = left/top, size = right/bottom). Zero off mobile (window is not the screen).
func _safe_margins() -> Rect2i:
	if not OS.has_feature("mobile"):
		return Rect2i()
	var scr: Vector2i = DisplayServer.screen_get_size()
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2 = get_viewport().get_visible_rect().size
	var k: Vector2 = win / Vector2(scr)
	return Rect2i(Vector2i(Vector2(safe.position) * k), Vector2i(Vector2(scr - safe.end) * k))
