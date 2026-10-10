## Translates GUIDE actions into game-level input signals. Framework layer:
## src/core never imports this; consumers only connect to the signals.
## Keyboard, gamepad and touch (TouchInput = virtual gamepad) all feed the
## same GUIDE actions, so this node does not care where input came from.
class_name GameInput
extends Node

## Screen-space step, y down: up = (0,-1). Fires on press, then auto-repeats.
signal move(screen_dir: Vector2i)
## axis is InputAxes.SPIN (turntable around world Y), TILT (flip in the screen
## plane around the camera view axis) or ROLL (resolved downstream). dir = +1 right, -1 left.
signal rotate_piece(axis: StringName, dir: int)
## true while soft drop is held, false on release.
signal soft_drop(active: bool)
signal hard_drop
## Camera orbit step, -1 = left, +1 = right.
signal view_rotate(dir: int)
signal pause_pressed
signal restart_pressed

const MOVE: GUIDEAction = preload("res://src/game/input/actions/move.tres")
const ROT_SPIN_LEFT: GUIDEAction = preload("res://src/game/input/actions/rot_spin_left.tres")
const ROT_SPIN_RIGHT: GUIDEAction = preload("res://src/game/input/actions/rot_spin_right.tres")
const ROT_TILT_LEFT: GUIDEAction = preload("res://src/game/input/actions/rot_tilt_left.tres")
const ROT_TILT_RIGHT: GUIDEAction = preload("res://src/game/input/actions/rot_tilt_right.tres")
const ROT_ROLL_LEFT: GUIDEAction = preload("res://src/game/input/actions/rot_roll_left.tres")
const ROT_ROLL_RIGHT: GUIDEAction = preload("res://src/game/input/actions/rot_roll_right.tres")
const SOFT_DROP: GUIDEAction = preload("res://src/game/input/actions/soft_drop.tres")
const HARD_DROP: GUIDEAction = preload("res://src/game/input/actions/hard_drop.tres")
const VIEW_L: GUIDEAction = preload("res://src/game/input/actions/view_l.tres")
const VIEW_R: GUIDEAction = preload("res://src/game/input/actions/view_r.tres")
const PAUSE: GUIDEAction = preload("res://src/game/input/actions/pause.tres")
const RESTART: GUIDEAction = preload("res://src/game/input/actions/restart.tres")

## Minimum stick/axis magnitude that counts as a move direction.
const MOVE_THRESHOLD: float = 0.5

## Mapping context enabled by [method enable].
@export var context: GUIDEMappingContext = preload("res://src/game/input/contexts/play.tres")
## Router that owns GUIDE context switching. Null = enable/disable [member context] directly.
@export var router: InputContextRouter
# ponytail: repeat exports until knob wiring (control.repeat_delay_ms / repeat_interval_ms)
## Auto-repeat delay (ms) before a held move repeats.
@export var repeat_delay_ms: float = 170.0
## Auto-repeat interval (ms) between repeated moves.
@export var repeat_interval_ms: float = 50.0
## Enable the context automatically on _ready.
@export var auto_enable: bool = true

## Rotation axes the current rules allow; others emit nothing.
var enabled_axes: Array[StringName] = InputAxes.ALL.duplicate()

var _enabled: bool = true
var _soft_active: bool = false
var _repeat: RepeatTimer


func _ready() -> void:
	_repeat = RepeatTimer.new(repeat_delay_ms / 1000.0, repeat_interval_ms / 1000.0)
	ROT_SPIN_LEFT.just_triggered.connect(try_rotate.bind(InputAxes.SPIN, -1))
	ROT_SPIN_RIGHT.just_triggered.connect(try_rotate.bind(InputAxes.SPIN, 1))
	ROT_TILT_LEFT.just_triggered.connect(try_rotate.bind(InputAxes.TILT, -1))
	ROT_TILT_RIGHT.just_triggered.connect(try_rotate.bind(InputAxes.TILT, 1))
	ROT_ROLL_LEFT.just_triggered.connect(try_rotate.bind(InputAxes.ROLL, -1))
	ROT_ROLL_RIGHT.just_triggered.connect(try_rotate.bind(InputAxes.ROLL, 1))
	SOFT_DROP.just_triggered.connect(_set_soft.bind(true))
	SOFT_DROP.completed.connect(_set_soft.bind(false))
	HARD_DROP.just_triggered.connect(_emit_if_enabled.bind(hard_drop))
	VIEW_L.just_triggered.connect(_emit_view.bind(-1))
	VIEW_R.just_triggered.connect(_emit_view.bind(1))
	PAUSE.just_triggered.connect(_emit_if_enabled.bind(pause_pressed))
	RESTART.just_triggered.connect(_emit_if_enabled.bind(restart_pressed))
	if auto_enable:
		enable()


## Activates the mapping context and signal output.
func enable() -> void:
	_enabled = true
	if router:
		router.set_screen(InputContextRouter.Ctx.PLAY)
	elif context:
		GUIDE.enable_mapping_context(context)


## Deactivates the mapping context; releases a held soft drop.
func disable() -> void:
	_enabled = false
	_set_soft(false)
	if not router and context and is_inside_tree():
		GUIDE.disable_mapping_context(context)


## Stops all in-flight input (repeat timer, held soft drop) without disabling
## the context. Used by pause and screen changes (ADR-0010, ADR-0012 §7.5).
func cancel_all() -> void:
	_repeat = RepeatTimer.new(repeat_delay_ms / 1000.0, repeat_interval_ms / 1000.0)
	_set_soft(false)
	Input.flush_buffered_events()


## Sets the rotation axes the current rules allow (from control.rotation_axes_enabled).
func set_enabled_axes(axes: Array[StringName]) -> void:
	enabled_axes = axes.duplicate()


## Emits [signal rotate_piece] unless disabled or the axis is not allowed.
func try_rotate(axis: StringName, dir: int) -> void:
	if _enabled and axis in enabled_axes:
		rotate_piece.emit(axis, dir)


## Snaps an analogue/2D value to a single cardinal step (x wins ties).
static func snap_dir(v: Vector2) -> Vector2i:
	if v.length() < MOVE_THRESHOLD:
		return Vector2i.ZERO
	if absf(v.x) >= absf(v.y):
		return Vector2i(int(signf(v.x)), 0)
	return Vector2i(0, int(signf(v.y)))


func _process(delta: float) -> void:
	var dir: Vector2i = snap_dir(MOVE.value_axis_2d) if _enabled else Vector2i.ZERO
	for i in _repeat.update(dir, delta):
		move.emit(dir)


func _set_soft(active: bool) -> void:
	if active and not _enabled:
		return
	if _soft_active != active:
		_soft_active = active
		soft_drop.emit(active)


func _emit_view(dir: int) -> void:
	if _enabled:
		view_rotate.emit(dir)


func _emit_if_enabled(sig: Signal) -> void:
	if _enabled:
		sig.emit()
