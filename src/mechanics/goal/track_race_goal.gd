class_name TrackRaceGoal extends GoalEvaluator
## "Survive to the finish" for moving-platform levels (gap G8): won when the TrackRunner reports the track finished
## (the end reached in time with the cargo aboard), lost when it reports a failure (time up, or cargo lost in
## fail mode). Reads the goal metrics the runner writes; it holds no race logic itself.
const PLUGIN_ID := &"track_race"


func configure(_goal: Dictionary) -> void:
	pass


func evaluate(state: GoalState, _api: RuleApi) -> int:
	if int(state.metrics.get(TrackRunner.METRIC_FINISHED, 0)) == 1:
		return WON
	if int(state.metrics.get(TrackRunner.METRIC_FAILED, 0)) == 1:
		return LOST
	return RUNNING


func progress(state: GoalState) -> Dictionary:
	var pm: int = int(state.metrics.get(TrackRunner.METRIC_PROGRESS_PM, 0))
	return {"done": pm, "target": 1000, "unit": "pm", "hearts": int(state.metrics.get(TrackRunner.METRIC_HEARTS, 0)),
		"stars": int(state.metrics.get(TrackRunner.METRIC_STARS, 0))}
