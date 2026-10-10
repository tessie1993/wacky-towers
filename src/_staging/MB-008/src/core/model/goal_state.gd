class_name GoalState extends RefCounted
## Running goal counters for one board (Level Goals GDD). Plain data; the sim writes it, goal plugins read it.

## Same values as GoalEvaluator results.
const RESULT_RUNNING := 0
const RESULT_WON := 1
const RESULT_LOST := 2

## Layers cleared so far.
var layers_cleared: int = 0
## Cells trimmed by overflow so far.
var cells_trimmed: int = 0
## Top-out warnings remaining before loss.
var warnings_left: int = 0
## Elapsed level time in milliseconds.
var level_ms: int = 0
## Pieces locked so far.
var locks: int = 0
## RESULT_RUNNING, RESULT_WON or RESULT_LOST.
var result: int = RESULT_RUNNING
