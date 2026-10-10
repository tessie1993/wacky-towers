extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
func _api(board: BoardState, params: Dictionary = {}, goal: Dictionary = {}) -> RuleApi:
	var api: RuleApi = F.api_with_knobs(board,{&"spawn.colour_count":3})
	api._params=params
	api.bind_goal(GoalState.new(),goal)
	return api

func test_frosting_three_needs_three_distinct_resolves() -> void:
	var b := F.board();var at := Vector3i(1,0,1);var api := _api(b)
	b.place(b.index(at),api.kind_of(&"frosting_three"),0,0)
	var rule := FrostingRule.new()
	F.handle(rule,&"on_level_start",api)
	assert_int(api.record_at(at).status.frosting_layers).is_equal(3)
	for turn: int in 2:
		F.handle(rule,&"on_clear",api,{"cell":at+Vector3i.RIGHT})
		F.handle(rule,&"on_clear",api,{"cell":at+Vector3i.LEFT})
		assert_int(api.record_at(at).status.frosting_layers).is_equal(2-turn)
		F.handle(rule,&"on_resolve_end",api)
	F.handle(rule,&"on_clear",api,{"cell":at+Vector3i.RIGHT})
	assert_int(api.kind_at(at)).is_equal(0)

func test_licorice_survives_clear_and_unbinds_only_adjacent() -> void:
	var b := F.board();var at := Vector3i(1,0,1);var api := _api(b)
	b.place(b.index(at),api.kind_of(&"licorice"),0,0)
	var rule := LicoriceLockRule.new();F.handle(rule,&"on_level_start",api)
	b.remove(b.index(at),BoardState.Cause.CLEAR)
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"licorice"))
	F.handle(rule,&"on_clear",api,{"cell":Vector3i(3,0,3)})
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"licorice"))
	F.handle(rule,&"on_clear",api,{"cell":at+Vector3i.RIGHT})
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"starter"))

func test_sponge_is_fixed_and_survives_damage() -> void:
	var b := F.board();var at := Vector3i(1,0,1);var api := _api(b)
	b.place(b.index(at),api.kind_of(&"sponge"),0,0)
	F.handle(FrostingRule.new(),&"on_level_start",api)
	b.remove(b.index(at),BoardState.Cause.DAMAGE)
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"sponge"))
	api.move_cell(at,at+Vector3i.RIGHT,true);api.flush_writes()
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"sponge"))

func test_tier_frosting_counts_flavour_share_not_height_coverage() -> void:
	var b := F.board(4,4,10);var api := _api(b,{"tier_layers":2,"frost_share":0.5},{"type":"height","h_target":8})
	for tier: int in 4:b.place(b.index(Vector3i(0,tier*2,0)),1,1+tier%2,tier+1)
	F.handle(TierFrostingRule.new(),&"on_resolve_end",api)
	assert_int(api.goal_counter(&"frosted_tiers")).is_equal(4)
	b.place(b.index(Vector3i(0,2,0)),1,1,2)
	F.handle(TierFrostingRule.new(),&"on_resolve_end",api)
	assert_int(api.goal_counter(&"frosted_tiers")).is_equal(2)

func test_gumdrop_forecast_waits_one_lock_and_has_flavour() -> void:
	var b := F.board();var api := _api(b,{"spawn_every_locks":4,"objects_max":1})
	var rule := GumdropHailRule.new();F.handle(rule,&"on_level_start",api)
	for n: int in 3:F.handle(rule,&"on_resolve_end",api)
	assert_bool(rule.snapshot().marked).is_true()
	assert_int(CandyCells.cells(api,true).size()).is_equal(0)
	F.handle(rule,&"on_resolve_end",api)
	var at: Vector3i = rule.snapshot().pending
	assert_int(api.kind_at(at)).is_equal(api.kind_of(&"gumdrop"))
	assert_bool(api.color_at(at)>=1 and api.color_at(at)<=3).is_true()
	for n: int in 4:F.handle(rule,&"on_resolve_end",api)
	assert_int(CandyCells.cells(api,true).size()).is_equal(1)

func test_hail_avoids_original_holes_under_starter() -> void:
	var b := F.board();var api := _api(b,{"avoid_start_holes":true,"spawn_every_locks":2})
	b.place(b.index(Vector3i(1,1,1)),2,0,0)
	var rule := GumdropHailRule.new();F.handle(rule,&"on_level_start",api)
	assert_bool(rule.snapshot().holes.has(Vector3i(1,0,1))).is_true()
	F.handle(rule,&"on_resolve_end",api)
	assert_bool(rule.snapshot().pending!=Vector3i(1,0,1)).is_true()

func test_moody_cube_does_not_fill_until_same_flavour_neighbour() -> void:
	var b := F.board();var api := _api(b);var at := Vector3i(1,0,1)
	b.place(b.index(at),1,2,7)
	var rule := MoodyCubeRule.new();F.handle(rule,&"on_spawn",api,{"tags":PackedStringArray(["moody"])})
	F.handle(rule,&"on_lock",api,{"cells":[at],"uid":7})
	assert_bool(api.fills_layer_at(at)).is_false()
	b.place(b.index(at+Vector3i.RIGHT),1,2,8)
	F.handle(rule,&"on_resolve_end",api)
	assert_bool(api.fills_layer_at(at)).is_true()

func test_countdown_ticks_and_blast_requests_one_junk_layer() -> void:
	var b := F.board();var api := _api(b,{"cd_start":2,"thrown_every_locks":99,"blast_layers":1});var at := Vector3i(1,0,1)
	b.place(b.index(at),api.kind_of(&"countdown_bomb"),0,0);b.set_status(b.index(at),{"counter":2})
	var rule := CountdownBombRule.new();F.handle(rule,&"on_resolve_end",api)
	assert_int(api.record_at(at).status.counter).is_equal(1)
	F.handle(rule,&"on_resolve_end",api)
	assert_int(api.kind_at(at)).is_equal(0)
	assert_int(api.take_requests().size()).is_equal(1)

func test_bake_oven_goal_cannot_win_before_stage_swap() -> void:
	var b := F.board();var api := _api(b,{}, {"type":"bake_oven","h_target":1,"height_coverage":0.5})
	for x: int in 4:
		for z: int in 4:b.place(b.index(Vector3i(x,0,z)),1,1,1)
	var goal := BakeOvenGoal.new();goal.configure(api.goal_config())
	assert_int(goal.evaluate(GoalState.new(),api)).is_equal(GoalState.RESULT_RUNNING)

func test_bake_stage_transforms_batter_and_swaps_bonk_goal() -> void:
	var b := F.board();var api := _api(b,{"bake_warn_ms":2000},{"type":"bake_oven","h_target":1,"height_coverage":0.5})
	for x: int in 4:
		for z: int in 4:b.place(b.index(Vector3i(x,0,z)),1,1,1)
	var rule := BakeStageRule.new();F.handle(rule,&"on_level_start",api);api.take_requests()
	F.handle(rule,&"on_resolve_end",api);api.set_time(1999);F.handle(rule,&"on_tick",api)
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(1)
	api.set_time(2000);F.handle(rule,&"on_tick",api)
	assert_int(api.kind_at(Vector3i.ZERO)).is_equal(api.kind_of(&"sponge"))
	assert_int(api.goal_counter(&"baked")).is_equal(1)
	var goals: Array = api.take_requests().filter(func(r:Dictionary)->bool:return r.op==&"goal")
	assert_int(goals.size()).is_equal(1)
	assert_str(goals[0].config.type).is_equal("bonk_boss")

func test_mood_f10_bands_and_prank_are_telegraphed() -> void:
	var b := F.board();var api := _api(b,{"prank":"bridge_jump"});var rule := MascotMoodRule.new()
	F.handle(rule,&"on_level_start",api);F.handle(rule,&"on_resolve_end",api)
	assert_str(rule.snapshot().band).is_equal("happy")
	b.place(b.index(Vector3i(1,3,1)),1,1,1)
	F.handle(rule,&"on_resolve_end",api)
	assert_str(rule.snapshot().band).is_equal("grumpy")
	api.set_time(999);F.handle(rule,&"on_tick",api)
	assert_int(api.goal_counter(&"jelly_bonus")).is_equal(0)
	api.set_time(1000);F.handle(rule,&"on_tick",api)
	assert_int(api.goal_counter(&"jelly_bonus")).is_equal(1)

func test_jelly_uses_real_array_move_payload_and_hops_once() -> void:
	var b := F.board();var api := _api(b,{"jelly_bounce":1})
	var shape := ShapeDef.build(&"mono",[Vector3i.ZERO]);var piece := ActivePiece.new(shape,Vector3i(1,0,1));api.bind_piece(piece)
	var rule := JellyPieceRule.new();F.handle(rule,&"on_spawn",api,{"tags":PackedStringArray(["jelly"])})
	F.handle(rule,&"on_command",api,{"kind":SimEvents.CMD_MOVE,"args":[Vector3i.RIGHT]})
	F.handle(rule,&"on_land",api)
	assert_int(piece.pivot.x).is_equal(2)
	F.handle(rule,&"on_land",api)
	assert_int(piece.pivot.x).is_equal(2)

func test_earned_bomb_requires_one_connected_seven_cube_flavour_group() -> void:
	var b := F.board();var api := _api(b,{"bomb_at":7,"rocket_at":0,"colour_bomb_at":0});var rule := EarnedSpecialsRule.new()
	var cells: Array[Vector3i]=[Vector3i(0,0,0),Vector3i(1,0,0),Vector3i(2,0,0),Vector3i(3,0,0),Vector3i(0,0,1),Vector3i(1,0,1),Vector3i(2,0,1)]
	F.handle(rule,&"on_lock",api,{"cells":cells})
	for c: Vector3i in cells:b.place(b.index(c),1,1,1)
	for c: Vector3i in cells:
		F.handle(rule,&"on_clear",api,{"cell":c,"kind":1});b.remove(b.index(c),BoardState.Cause.CLEAR)
	F.handle(rule,&"on_resolve_end",api)
	assert_int(MechanicsCells.occupied(api,api.kind_of(&"candy_bomb")).size()).is_equal(1)

func test_climber_actual_downward_tumble_awards_one_bonk() -> void:
	var b := F.board(4,4,6);var api := _api(b,{}, {"type":"bonk_boss","bonks_needed":3})
	var support := Vector3i(0,1,0);b.place(b.index(support),1,1,1)
	var rule := ClimberBossRule.new();F.handle(rule,&"on_level_start",api);F.handle(rule,&"on_resolve_end",api)
	assert_int(rule.snapshot().anchor.y).is_equal(2)
	F.handle(rule,&"on_clear",api,{"cell":support});b.remove(b.index(support),BoardState.Cause.CLEAR)
	F.handle(rule,&"on_resolve_end",api)
	assert_int(api.goal_counter(&"bonks")).is_equal(1)
	assert_int(rule.snapshot().anchor.y).is_equal(0)
	assert_int(MechanicsCells.occupied(api,api.kind_of(&"climber_boss")).size()).is_equal(4)

func test_stitch_veto_keeps_climber_anchor_and_bonk_counter() -> void:
	var b := F.board(4,4,6);var api := _api(b,{}, {"type":"bonk_boss","bonks_needed":3})
	var support := Vector3i(0,1,0);b.place(b.index(support),1,1,1)
	var rule := ClimberBossRule.new();F.handle(rule,&"on_resolve_end",api)
	F.handle(rule,&"on_clear",api,{"cell":support});b.remove(b.index(support),BoardState.Cause.CLEAR)
	api.bind_stack_permission(false);F.handle(rule,&"on_resolve_end",api)
	assert_int(api.goal_counter(&"bonks")).is_equal(0)
	assert_int(rule.snapshot().anchor.y).is_equal(2)
	api.bind_stack_permission(true);F.handle(rule,&"on_resolve_end",api)
	assert_int(api.goal_counter(&"bonks")).is_equal(1)
