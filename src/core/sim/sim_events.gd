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
const CMD_USE_SKILL := &"cmd_use_skill"
const CMD_USE_ITEM := &"cmd_use_item"
const CMD_RECEIVE_ITEM := &"cmd_receive_item"
const CMD_PICK_SHAPE := &"cmd_pick_shape"
const CMD_CHOOSE_DOWN := &"cmd_choose_down"
const CMD_FLICK := &"cmd_flick"
const CMD_UNDO := &"cmd_undo"
const CMD_RESET := &"cmd_reset"

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
const RESOLVE_STARTED := &"resolve_started"
const LEVEL_RESULT := &"level_result"
const RESCUE_WIPED := &"rescue_wiped"
const KIT_CHANGED := &"kit_changed"
const TURN_RESTORED := &"turn_restored"

## --- Juice / feel events (review D14; presentation agents subscribe, the sim never depends on them) ---
## COMBO_CHANGED {combo:int, previous:int}: consecutive clearing locks changed (0 = combo ended).
const COMBO_CHANGED := &"combo_changed"
## NEAR_MISS {height_before:int, headroom:int, limit:int, rows_cleared:int}: a clear landed while the stack was within
## goal.near_miss_margin layers of the limit (headroom = limit_layer - 1 - stack_height, measured before the clear).
const NEAR_MISS := &"near_miss"
## PERFECT_CLEAR {layers:int, pieces_placed:int}: the board is completely empty after a clearing lock.
const PERFECT_CLEAR := &"perfect_clear"
## DANGER_CHANGED {level:int 0..3, previous:int, headroom:int, stack_height:int, limit:int}: graded stack-height tension.
## Thresholds are goal.danger_margin_1..3. Fires only when the level changes (after locks, clears and rescues).
const DANGER_CHANGED := &"danger_changed"
## LOCK_RESET {uid:int, resets_left:int, resets_max:int}: a move/rotate while resting restarted the lock-delay timer.
const LOCK_RESET := &"lock_reset"
## SPAWN_RESCUED {kind:StringName ("swap_shape"|"wipe"), shape_id, replaced, k, n_cubes}: spawn safety stepped in
## instead of ending the level (see BoardSim._ensure_safe_spawn).
const SPAWN_RESCUED := &"spawn_rescued"

## LAYERS_CLEARED payload (additive; older keys unchanged): {indices, layers, layer_indices (PackedInt32Array, layer
## index along the down axis, 0 = floor end, ascending), count (int, same as n_layers), n_layers, chain_round, cells}.

## Original cube record emitted only when ordinary clear or structural damage actually removes it.
const CUBE_CLEARED := &"cube_cleared"
