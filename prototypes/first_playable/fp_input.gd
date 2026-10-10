class_name FpInput extends Node
## Keyboard/touch input for the first playable. Polls wt_* actions and drives FpGame / FpView.

const REPEAT_DELAY_MS: int = 170
const REPEAT_INTERVAL_MS: int = 50

const MOVE_ACTIONS: Array[StringName] = [
	&"wt_move_up", &"wt_move_down", &"wt_move_left", &"wt_move_right"
]

# Screen "up" and "right" as world (dx, dz) per view_k (yaw = 45 + 90*k degrees).
# Down = -up, left = -right.
const SCREEN_UP: Array[Vector2i] = [
	Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(1, 0)
]
const SCREEN_RIGHT: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 1)
]

var _game: FpGame
var _view: FpView
var _hold_ms: Dictionary = {}   # action -> ms held since last fire
var _delayed: Dictionary = {}   # action -> true once initial delay passed
var _last_msec: int = 0
var _soft_on: bool = false


## Connect to the sim and the view.
func setup(game: FpGame, view: FpView) -> void:
	_game = game
	_view = view
	_last_msec = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	if _game == null or _view == null:
		return
	var now: int = Time.get_ticks_msec()
	var dt: int = now - _last_msec
	_last_msec = now

	if Input.is_action_just_pressed(&"wt_restart"):
		_game.restart()
		return

	if _game.state != FpGame.State.PLAYING:
		_set_soft(false)
		return

	if Input.is_action_just_pressed(&"wt_view_left"):
		_view.rotate_view(-1)
	if Input.is_action_just_pressed(&"wt_view_right"):
		_view.rotate_view(1)

	# Horizontal = turntable about world Y (right = clockwise seen from above).
	if Input.is_action_just_pressed(&"wt_rot_h_left"):
		_game.spin(-1)
	if Input.is_action_just_pressed(&"wt_rot_h_right"):
		_game.spin(1)
	# Vertical = tip in the screen plane: turn about the view axis snapped to world X/Z for view_k
	# (+90 about forward maps up -> screen-right, so "right" tips the top to the right).
	var fwd: Vector2i = SCREEN_UP[posmod(_view.view_k, 4)]
	if Input.is_action_just_pressed(&"wt_rot_v_left"):
		_rotate_about(fwd, -1)
	if Input.is_action_just_pressed(&"wt_rot_v_right"):
		_rotate_about(fwd, 1)

	if Input.is_action_just_pressed(&"wt_hard_drop"):
		_game.hard_drop()
		return

	for action: StringName in MOVE_ACTIONS:
		_update_move(action, dt)

	_set_soft(Input.is_action_pressed(&"wt_soft_drop"))


func _set_soft(on: bool) -> void:
	if on != _soft_on:
		_soft_on = on
		_game.set_soft_drop(on)


func _update_move(action: StringName, dt: int) -> void:
	if Input.is_action_just_pressed(action):
		_hold_ms[action] = 0
		_delayed[action] = false
		_fire(action)
		return
	if not Input.is_action_pressed(action):
		_hold_ms.erase(action)
		_delayed.erase(action)
		return
	var held: int = int(_hold_ms.get(action, 0)) + dt
	var threshold: int = REPEAT_INTERVAL_MS if _delayed.get(action, false) else REPEAT_DELAY_MS
	while held >= threshold:
		held -= threshold
		_delayed[action] = true
		threshold = REPEAT_INTERVAL_MS
		_fire(action)
	_hold_ms[action] = held


func _fire(action: StringName) -> void:
	var k: int = posmod(_view.view_k, 4)
	var up: Vector2i = SCREEN_UP[k]
	var right: Vector2i = SCREEN_RIGHT[k]
	var d: Vector2i = Vector2i.ZERO
	match action:
		&"wt_move_up":
			d = up
		&"wt_move_down":
			d = -up
		&"wt_move_right":
			d = right
		&"wt_move_left":
			d = -right
	if d != Vector2i.ZERO:
		_game.move(d.x, d.y)


## Turn about a horizontal world axis given as (dx, dz) with one non-zero unit component.
func _rotate_about(axis_xz: Vector2i, dir: int) -> void:
	if axis_xz.x != 0:
		_game.rotate(0, dir * axis_xz.x)
	else:
		_game.rotate(2, dir * axis_xz.y)
