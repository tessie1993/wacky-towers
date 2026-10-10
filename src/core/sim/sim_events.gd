class_name SimEvents extends RefCounted
## The one vocabulary of event and command kinds. Never write a kind string literal elsewhere.
## Later stories append; never rename.

# Commands
const CMD_MOVE := &"cmd_move"
const CMD_ROTATE := &"cmd_rotate"
const CMD_SOFT_DROP_ON := &"cmd_soft_drop_on"
const CMD_SOFT_DROP_OFF := &"cmd_soft_drop_off"
const CMD_HARD_DROP := &"cmd_hard_drop"
const CMD_HOLD := &"cmd_hold"
const CMD_TAP := &"cmd_tap"

# Events
const PHASE_CHANGED := &"phase_changed"
const COMMAND_APPLIED := &"command_applied"
const PIECE_SPAWNED := &"piece_spawned"
const PIECE_MOVED := &"piece_moved"
const PIECE_ROTATED := &"piece_rotated"
const PIECE_BLOCKED := &"piece_blocked"
const PIECE_LOCKED := &"piece_locked"
const CELLS_CHANGED := &"cells_changed"
const LAYERS_CLEARED := &"layers_cleared"
const TOP_OUT_WARNING := &"top_out_warning"
const CELLS_TRIMMED := &"cells_trimmed"
const GOAL_PROGRESS := &"goal_progress"
const GOAL_REACHED := &"goal_reached"
const LEVEL_FAILED := &"level_failed"
const RULE_STARTED := &"rule_started"
const RULE_ENDED := &"rule_ended"
const RULE_BLOCKED := &"rule_blocked"
const CHAIN_DROPPED := &"chain_dropped"
const KNOB_CLAMPED := &"knob_clamped"
