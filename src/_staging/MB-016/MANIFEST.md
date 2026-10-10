# MB-016 (CH-151 + CH-150 + CH-152 + CH-059; CH-043 superseded)
All paths relative to src/ (stage mirrors final path under _staging/MB-016/src/).
- core/rules/bases/goal_evaluator.gd, top_out_policy.gd, control_verb.gd, layout_kind.gd -> NEW
- core/rules/bases/rule_behaviour.gd, clear_detector.gd, collapse_policy.gd, arrival_style.gd -> REPLACE (append validate())
- mechanics/arrival/top_arrival.gd -> NEW
- Needs RuleApi from MB-010/CH-052 (board_size, down_vector, can_place) integrated first.
- Check: logs_read has no parse errors / class clashes; GoalEvaluator/ControlVerb scripts .can_instantiate() == false; PluginRegistry errors() empty;
  TopArrival.new().plan_arrival(shape_i, board, RuleApi.new(board)) on 4x4x12 -> blocked false, travel_dir (0,-1,0), origin y in spawn zone; fill top layer SOLID -> blocked true.

## Review (gdscript-specialist, 2026-10-10)
- Verdict: ready. Live src/core/rules/rule_api.gd already has board_size/down_vector/can_place (identical to MB-010 staged), so MB-010 is NOT required first.
- top_arrival.gd: added `@warning_ignore("integer_division")` on plan_arrival (centring `/ 2` on ints).
- Bases checked against live (only validate() added; ValidationIssue/LevelData/GameCatalog/GoalState consts exist); PLUGIN_ID/@abstract patterns OK.
