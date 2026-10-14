class_name WtSpanWalker extends RefCounted
## A3 walker state machine (design/gdd/minigame-mechanics-wave4.md §A3; design/gdd/modules-framework.md).
## Pure and clock-injected: the caller passes level time and the current path; nothing reads the board.
## Usage: walker.configure(a, b, 500, 250); walker.update(level_ms, reached, path); if walker.state == WtSpanWalker.State.ARRIVED: win()

enum State { BUILDING, HOLDING, WALKING, ARRIVED }

## Explicit transition table: state -> states it may move to.
const TRANSITIONS: Dictionary = {
	State.BUILDING: [State.HOLDING],
	State.HOLDING: [State.BUILDING, State.WALKING],
	State.WALKING: [State.ARRIVED],
	State.ARRIVED: [],
}

## Current State.
var state: State = State.BUILDING
## Walker ground cell (x, z).
var cell: Vector2i = Vector2i.ZERO
## True while walking on a broken path (edge case a: stop at the last intact node).
var frozen: bool = false
var _goal_cell: Vector2i = Vector2i.ZERO
var _hold_ms: int = 0
var _walk_ms: int = 1
var _hold_since_ms: int = 0
var _next_step_ms: int = 0


## Resets to BUILDING with the walker on `start`. Usage: walker.configure(Vector2i(0, 1), Vector2i(7, 1), 500, 250)
func configure(start: Vector2i, goal: Vector2i, hold_ms: int, walk_ms: int) -> void:
	state = State.BUILDING
	cell = start
	frozen = false
	_goal_cell = goal
	_hold_ms = maxi(0, hold_ms)
	_walk_ms = maxi(1, walk_ms)
	_hold_since_ms = 0
	_next_step_ms = 0


## Advances the machine to `now_ms`. While BUILDING/HOLDING, `path` runs from anchor A; while WALKING it runs
## from the walker's cell. `reached` is true when `path` ends on the far anchor. Returns the new state.
## Usage: walker.update(state.level_ms, r["reached"], r["path"])
func update(now_ms: int, reached: bool, path: Array) -> State:
	match state:
		State.BUILDING:
			if reached:
				_hold_since_ms = now_ms
				_go(State.HOLDING)
		State.HOLDING:
			if not reached:
				_go(State.BUILDING)
			elif now_ms - _hold_since_ms >= _hold_ms:
				_next_step_ms = _hold_since_ms + _hold_ms + _walk_ms
				_go(State.WALKING)
	if state == State.WALKING:
		_walk(now_ms, reached, path)
	return state


## Deterministic save/replay state. Usage: var s: Dictionary = walker.snapshot()
func snapshot() -> Dictionary:
	return {"state": state, "cell": [cell.x, cell.y], "frozen": frozen, "goal": [_goal_cell.x, _goal_cell.y],
		"hold_ms": _hold_ms, "walk_ms": _walk_ms, "hold_since_ms": _hold_since_ms, "next_step_ms": _next_step_ms}


## Restores snapshot(). Usage: walker.restore(saved)
func restore(saved: Dictionary) -> void:
	if saved.is_empty():
		return
	state = int(saved.get("state", State.BUILDING)) as State
	cell = Vector2i(int(saved.cell[0]), int(saved.cell[1]))
	frozen = bool(saved.get("frozen", false))
	_goal_cell = Vector2i(int(saved.goal[0]), int(saved.goal[1]))
	_hold_ms = int(saved.hold_ms)
	_walk_ms = int(saved.walk_ms)
	_hold_since_ms = int(saved.hold_since_ms)
	_next_step_ms = int(saved.next_step_ms)


func _walk(now_ms: int, reached: bool, path: Array) -> void:
	if not reached:
		frozen = true
		return
	if frozen:
		# Reconnected: resume one full step after the repair, never instantly.
		frozen = false
		_next_step_ms = now_ms + _walk_ms
		return
	while state == State.WALKING and now_ms >= _next_step_ms:
		var index: int = path.find(cell)
		if index < 0 or index + 1 >= path.size():
			return
		cell = path[index + 1]
		_next_step_ms += _walk_ms
		if cell == _goal_cell:
			_go(State.ARRIVED)


func _go(next: State) -> bool:
	if not (TRANSITIONS[state] as Array).has(next):
		push_error("WtSpanWalker: illegal transition %d -> %d" % [state, next])
		return false
	state = next
	return true
