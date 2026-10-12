class_name RescueTopOut extends TopOutPolicy
## `rescue` top-out: spend a warning to silently wipe the bottom layers (Level Goals rules 8-9, 10c, F3; CH-162).
## The sim owns the Warning phase and its timer; this only mutates board and state. Never touches layers_cleared.

const PLUGIN_ID := &"rescue"
## Knob id and fallback (assets/data/knobs/goals.json goal.rescue_margin, default 2).
const MARGIN_KNOB := &"goal.rescue_margin"
const DEFAULT_MARGIN := 2

var _margin: int


## `margin` < 0 means read the goal.rescue_margin knob from the api at resolve time.
## Usage: `RescueTopOut.new()` or `RescueTopOut.new(3)`.
func _init(margin: int = -1) -> void:
	_margin = margin


## F3: layers to wipe, max(1, s - (h_play - 1 - margin)). Usage: `RescueTopOut.wipe_size(9, 8, 2)` -> 4.
static func wipe_size(stack_h: int, h_play: int, margin: int) -> int:
	return maxi(1, stack_h - (h_play - 1 - margin))


## CONTINUE after a wipe; LOST if no warning is left or the stack is still over the limit after wiping.
## Usage: `policy.resolve_top_out(board, state, api)`.
func resolve_top_out(board: BoardState, state: GoalState, api: RuleApi) -> int:
	if state.warnings_left <= 0:
		return LOST
	var margin: int = _margin
	if margin < 0:
		var knob: Variant = api.knob(MARGIN_KNOB) if api != null else null
		margin = knob if typeof(knob) == TYPE_INT else DEFAULT_MARGIN
	# s = stack_height() (highest solid layer index), as in the ticket example (s=9 -> k=4 -> stack 5).
	var k: int = mini(wipe_size(board.stack_height(), board.h_play(), margin), board.layer_count())
	state.warnings_left -= 1
	var wiped: PackedInt32Array = PackedInt32Array()
	for layer: int in k:
		wiped.append(layer)
		for i: int in board.layer_cells(layer):
			board.remove(i, BoardState.Cause.RESCUE)
	board.shift_layers(wiped) # layers are already empty, so this only drops the rest
	return LOST if board.over_limit() else CONTINUE
