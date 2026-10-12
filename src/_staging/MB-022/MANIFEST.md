# MB-022 (CH-060, CH-161, CH-061, CH-162)
All NEW, paths relative to src/ (stage mirrors final path under _staging/MB-022/src/). Built on LIVE core/board/board_state.gd (shift_layers, Cause.RESCUE) and MB-016 bases (needs MB-016 integrated: GoalEvaluator, TopOutPolicy).
- mechanics/clear/layer_detector.gd, none_detector.gd, slice_collapse.gd
- mechanics/goal/clear_n_goal.gd, rescue_top_out.gd, lose_top_out.gd
Check (editor script eval): see each CH ticket "How the integrator sees it working". Notes: RescueTopOut(margin=-1) reads knob goal.rescue_margin via api (fallback 2); SliceCollapse relies on shift_layers for removal (cause CLEAR); rescue removes with cause RESCUE first.

## Review (gdscript-specialist, 2026-10-10)
- Verdict: ready after MB-016 lands (bases GoalEvaluator/TopOutPolicy/ClearDetector/CollapsePolicy with validate()).
- clear_n_goal.gd: explicit `int(n)` when assigning the Variant from JsonNum.whole_int to the typed `_n`.
- Note (no change): RescueTopOut calls api.knob(), which crashes if RuleApi was built with null knobs (live RuleApi._knobs unguarded); pass margin to the constructor or build the api with a KnobRegistry.
