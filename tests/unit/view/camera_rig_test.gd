extends GdUnitTestSuite

const SCENE: PackedScene = preload("res://src/view/camera_rig.tscn")


func _rig() -> CameraRig:
	var r: CameraRig = auto_free(SCENE.instantiate())
	add_child(r)
	return r


func test_starts_at_k0() -> void:
	assert_int(_rig().get_yaw_index()).is_equal(0)


func test_rotate_wraps() -> void:
	var r := _rig()
	r.rotate_view(-1)
	assert_int(r.get_yaw_index()).is_equal(11)
	r.rotate_view(1)
	r.rotate_view(1)
	assert_int(r.get_yaw_index()).is_equal(1)


func test_yaw_changed_emitted() -> void:
	var r := _rig()
	var mon := monitor_signals(r)
	r.rotate_view(1)
	await assert_signal(mon).is_emitted("yaw_changed", [1])


func test_mapping_switches_instantly() -> void:
	var r := _rig()
	r.turn_anim_ms = 150
	r.rotate_view(1)
	r.rotate_view(1)
	r.rotate_view(1)
	r.rotate_view(-1)
	assert_int(r.get_yaw_index()).is_equal(2)
	r.rotate_view(1)
	assert_vector(Vector3(r.screen_dir_to_world(Vector2i(1, 0)))).is_equal(Vector3(0, 0, -1))


func test_world_axis_for() -> void:
	var r := _rig()
	assert_vector(Vector3(r.world_axis_for(&"spin"))).is_equal(Vector3(0, 1, 0))
	r.rotate_view(1)
	assert_vector(Vector3(r.world_axis_for(&"tilt"))).is_equal(Vector3(1, 0, 0))
	assert_vector(Vector3(r.world_axis_for(&"bogus"))).is_equal(Vector3.ZERO)


func test_frame_board_sets_ortho_size() -> void:
	var r := _rig()
	r.frame_board(Vector3i(6, 14, 6))
	var vs: Vector2 = r.get_viewport().get_visible_rect().size
	var cam: Camera3D = r.get_node("Camera")
	assert_float(cam.size).is_equal_approx(
		CameraMath.ortho_size(Vector3i(6, 14, 6), r.elevation_deg, vs.x / vs.y, r.margin), 0.001)
	assert_vector(r.position).is_equal_approx(Vector3(3, 7, 3), Vector3.ONE * 0.001)


func test_instant_cut_when_anim_zero() -> void:
	var r := _rig()
	r.turn_anim_ms = 0
	r.rotate_view(1)
	assert_float(r.rotation.y).is_equal_approx(deg_to_rad(75 - 90), 0.0001)


func test_scene_contains_phantom_camera_and_host() -> void:
	var r := _rig()
	var kinds: Array[String] = []
	for n in r.find_children("*", "", true, false):
		if n is PhantomCamera3D:
			kinds.append("pcam")
		elif n is PhantomCameraHost:
			kinds.append("host")
	assert_array(kinds).contains_exactly_in_any_order(["pcam", "host"])
