extends SceneTree
## Cave and item fog compose per cell without changing board hue, geometry or status.
var failures: Array[String]=[]
func _initialize() -> void:
	_run.call_deferred()
func _assert(ok: bool, message: String) -> void:
	if not ok:failures.append(message);push_error(message)
func _alpha(view: BoardView, index: int) -> float:
	return view._mm.get_instance_custom_data(view._slots.slot_of(index)).a
func _run() -> void:
	if DisplayServer.get_name()=="headless":
		print("VIEW_FOG_SMOKE: real_renderer_required=true headless_dummy_cannot_read_custom_data=true")
		quit(77);return
	var spec:=BoardSpec.new();spec.size=Vector3i(4,12,4);spec.h_play=8
	var types:=ContentTypes.from_entries(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/content/blocks.json")).types)
	var board:=BoardState.new(spec,types)
	var bright:=Vector3i(0,0,0);var fading:=Vector3i(3,0,3)
	board.place(board.index(bright),1,2,17);board.place(board.index(fading),1,8,16)
	var before: Dictionary=board.snapshot()
	var view:=BoardView.new();root.add_child(view)
	var art:=ArtSet.new(&"candy_toy");view.bind(board,art,art.palette())
	view.set_cell_visibility([{"cell":bright,"alpha":1.0},{"cell":fading,"alpha":0.1}])
	_assert(is_equal_approx(_alpha(view,board.index(bright)),1.0),"Lantern/new lock stays fully visible")
	_assert(absf(_alpha(view,board.index(fading))-0.1)<(1.0/255.0),"Older locked cell retains its own fade")
	print("FOG_ALPHA_GPU: bright=",_alpha(view,board.index(bright))," faded=",_alpha(view,board.index(fading))," authoritative=",view.visibility_at(board.index(fading)))
	_assert(is_equal_approx(view.visibility_at(board.index(fading)),.1),"Exact source coverage remains unquantized")
	_assert(view._mmi.material_override is ShaderMaterial,"Per-cell alpha uses coverage shader")
	view.set_item_hidden([bright])
	_assert(absf(_alpha(view,board.index(bright))-0.1)<(1.0/255.0),"Independent item fog dims its eligible lock")
	view.set_item_hidden([])
	_assert(is_equal_approx(_alpha(view,board.index(bright)),1.0),"Expired item restores lantern coverage")
	_assert(absf(_alpha(view,board.index(fading))-0.1)<(1.0/255.0),"Item expiration leaves Cave age fade intact")
	view.set_cell_visibility([{"cell":bright,"alpha":1.0},{"cell":fading,"alpha":1.0}])
	_assert(is_equal_approx(_alpha(view,board.index(fading)),1.0),"Clear reveal restores old locks")
	view.refresh()
	_assert(is_equal_approx(_alpha(view,board.index(bright)),1.0),"Geometry refresh preserves coverage")
	_assert(board.snapshot()==before,"Presentation must not mutate authoritative cells/hues/status")
	view.queue_free();await process_frame
	print("VIEW_FOG_SMOKE: per_cell=true lantern=true item_mask=true clear_reveal=true immutable_board=true failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
