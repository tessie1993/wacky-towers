class_name LevelResult extends RefCounted
## What a finished level reports (ADR-0010 section 1; Level Goals rule 14). Plain data built from the `level_result` event.

const OUTCOME_WON := &"won"
const OUTCOME_LOST := &"lost"
const OUTCOME_OUT := &"out"

## &"won" | &"lost" | &"out".
var outcome: StringName = OUTCOME_LOST
## Level clock in ms (Playing ticks only).
var level_ms: int = 0
## Layers cleared by Layer Clearing (rescue wipes excluded).
var layers_cleared: int = 0
## Warnings spent.
var warnings_used: int = 0
## Pieces locked.
var pieces_placed: int = 0
## Final score (Scoring & Stars F2/F3).
var score: int = 0
## Stars earned, 0 when not won (set by the sim via StarRater with the level's own star times).
var stars: int = 0


## Builds a result from a `level_result` event payload. Usage: `LevelResult.from_event(ev.data)`.
static func from_event(data: Dictionary) -> LevelResult:
	var r: LevelResult = LevelResult.new()
	r.outcome = data.get("outcome", OUTCOME_LOST)
	r.level_ms = int(data.get("level_ms", 0))
	r.layers_cleared = int(data.get("layers_cleared", 0))
	r.warnings_used = int(data.get("warnings_used", 0))
	r.pieces_placed = int(data.get("pieces_placed", 0))
	r.score = int(data.get("score", 0))
	r.stars = int(data.get("stars", 0))
	return r


## True when the level was won.
func is_won() -> bool:
	return outcome == OUTCOME_WON
