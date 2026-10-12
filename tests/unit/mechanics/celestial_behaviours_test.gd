extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")

func test_balloon_selects_one_per_real_bag_and_restores_on_hard_drop() -> void:
	var board := F.board()
	var api := F.api_with_knobs(board,{&"fall.gravity_scale":1000})
	var rule := BalloonRule.new()
	var count: int = 0
	for i: int in 8:
		api.bind_piece_flags({&"bag_index":0,&"bag_position":i,&"bag_size":8,&"injected":false})
		F.handle(rule,&"on_spawn",api)
		if bool(api.piece_flag(&"balloon",false)):
			count += 1
			var requests: Array = api.take_requests()
			var half_gravity: bool = false
			for request: Dictionary in requests:
				if request.op == &"slot" and request.id == &"fall.gravity_scale" and int(request.value) == 500: half_gravity = true
			assert_bool(half_gravity).is_true()
			F.handle(rule,&"on_command",api,{"kind":SimEvents.CMD_HARD_DROP})
			requests = api.take_requests()
			assert_int(int(requests[-1].value)).is_equal(1000)
		else: api.take_requests()
	assert_int(count).is_equal(1)

func test_balloon_helper_injection_does_not_consume_or_select_bag_slot() -> void:
	var api := F.api_with_knobs(F.board(),{&"fall.gravity_scale":1000})
	var rule := BalloonRule.new()
	api.bind_piece_flags({&"bag_index":0,&"bag_position":0,&"bag_size":8,&"injected":true})
	F.handle(rule,&"on_spawn",api)
	assert_bool(bool(api.piece_flag(&"balloon",false))).is_false()
	assert_int(int(rule.snapshot().bag)).is_equal(-999)

func test_keys_stamp_two_exposed_faces_per_real_bag() -> void:
	var api := F.api(F.board())
	var shape := ShapeDef.build(&"test_duo",[Vector3i.ZERO,Vector3i.RIGHT])
	api.bind_piece(ActivePiece.new(shape,Vector3i(1,4,1),0))
	var rule := KeyStampRule.new()
	var count: int = 0
	for i: int in 8:
		api.bind_piece_flags({&"bag_index":0,&"bag_position":i,&"bag_size":8,&"injected":false})
		F.handle(rule,&"on_spawn",api)
		var stamp: Dictionary = api.piece_flag(&"key_stamp",{})
		if not stamp.is_empty():
			count += 1
			assert_bool(shape.offsets(0).has(stamp.cell)).is_true()
			assert_bool(shape.offsets(0).has(stamp.cell+stamp.face)).is_false()
	assert_int(count).is_equal(2)

func test_gadget_draw_has_one_lock_warning_and_deck_does_not_repeat() -> void:
	var api := F.api(F.board(),{"event_card_locks":6,"pool":[{"card":"a","event":"gust"},{"card":"b","event":"slide"},{"card":"c","event":"drop"}]})
	var rule := EventCardRule.new()
	var warnings: Array[String] = []
	for lock_number: int in 18:
		F.handle(rule,&"on_resolve_end",api)
		for event: Dictionary in api.take_events():
			if event.kind == &"gadget_warning":
				assert_int((lock_number+1)%6).is_equal(5)
				assert_int(event.data.locks_left).is_equal(1)
				warnings.append(event.data.card)
			elif event.kind == &"gadget_card": assert_int((lock_number+1)%6).is_equal(0)
	assert_array(warnings).has_size(3)
	assert_int({warnings[0]:true,warnings[1]:true,warnings[2]:true}.size()).is_equal(3)
