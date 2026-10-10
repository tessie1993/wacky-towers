class_name HudSnapshot extends RefCounted
## Plain-data HUD frame (ADR-0016 §7, hud.md). No Node. [method from_sim] is the only place that reads the sim;
## times are sim ms and are formatted by [UiFormat].

enum State { HIDDEN, COUNTDOWN, PLAY, DANGER, PAUSED, RESULT }

## Stack within this many layers of the limit counts as DANGER. ponytail: constant; move to ui.json if tuned.
const DANGER_MARGIN_LAYERS := 2
## Countdown length used for the 3-2-1 number. ponytail: mirrors knob goal.countdown_ms (3000); read the knob once CH-064 exposes it.
const COUNTDOWN_MS := 3000
const NEXT_SHAPES_COUNT := 3
## Goal type -> HUD icon id. Unknown types fall back to [constant DEFAULT_GOAL_ICON].
const GOAL_ICONS := {&"clear_n": &"layers", &"height": &"height", &"survive": &"time", &"shape": &"shape"}
const DEFAULT_GOAL_ICON := &"layers"

var state: State = State.HIDDEN
## &"layers" | &"height" | &"time" | &"shape"
var goal_icon: StringName = &""
var goal_done: int = 0
var goal_target: int = 0
var level_ms: int = 0
var score: int = 0
var star2_ms: int = 0
var star3_ms: int = 0
## Preview shape ids, head first.
var next_shapes: PackedStringArray = PackedStringArray()
var rule_icons: Array[StringName] = []
var warnings_left: int = 0
## 3, 2, 1 during COUNTDOWN, else 0.
var countdown_n: int = 0


## Builds a snapshot from the live sim. Example: var snap := HudSnapshot.from_sim(sim, level).
@warning_ignore("integer_division")
static func from_sim(sim: BoardSim, level: LevelData) -> HudSnapshot:
	var s: HudSnapshot = HudSnapshot.new()
	var goal_type: StringName = StringName(level.goal.get("type", ""))
	s.goal_icon = GOAL_ICONS.get(goal_type, DEFAULT_GOAL_ICON)
	s.goal_target = int(level.goal.get("n", level.goal.get("target", 0)))
	s.star2_ms = int(level.stars.get("t2", 0))
	s.star3_ms = int(level.stars.get("t3", 0))
	for r in level.rules:
		s.rule_icons.append(StringName(r.get("id", "")))
	# Dynamic calls: BoardSim does not expose goal_progress()/preview() yet (parse-safe until CH-064).
	if sim.has_method("goal_progress"):
		var progress: GoalState = sim.call("goal_progress")
		if progress != null:
			s.goal_done = progress.layers_cleared
			s.warnings_left = progress.warnings_left
			s.level_ms = progress.level_ms
	var now: int = sim.now_ms()
	if sim.has_method("preview"):
		var ids: Array = sim.call("preview", NEXT_SHAPES_COUNT)
		for shape_id: Variant in ids:
			s.next_shapes.append(String(shape_id))
	match sim.get_phase():
		BoardSim.Phase.COUNTDOWN:
			s.state = State.COUNTDOWN
			s.countdown_n = clampi(ceili(float(COUNTDOWN_MS - now) / 1000.0), 1, COUNTDOWN_MS / 1000)
		BoardSim.Phase.ENDED:
			s.state = State.RESULT
		_:
			s.state = State.DANGER if _is_danger(sim) else State.PLAY
	return s


# Needs BoardSim to expose its BoardState (CH-031 queries) as board(); stays PLAY if it does not.
static func _is_danger(sim: BoardSim) -> bool:
	if not sim.has_method("board"):
		return false
	var b: BoardState = sim.call("board")
	if b == null:
		return false
	return b.stack_height() >= b.limit_layer() - DANGER_MARGIN_LAYERS
