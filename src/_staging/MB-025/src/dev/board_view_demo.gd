extends Node3D
## MB-025 demo (dev only): BoardView + BoardStage + PieceView + GhostView on a 4x4 board.
## Keys: 1-5 spawn shape | arrows move x/z | R/F move up/down | Q/E rotate about Y | Space lock (piece cells written)
##       Z remove top block | X drop layer 0 (shift_layers) | C add a block on the first free floor cell | G toggle danger
## Piece moves are in board axes (not camera-relative); this is a view check, not the input pipeline.

const CONTENT_JSON := "res://assets/data/content/blocks.json"
const BANK_PATH := "res://assets/data/shapes/shape_bank.tres"
const CONTENT_MAX_BYTES := 65536
const SET_ID := &"candy_toy"
const KIND_BLOCK: int = 1
const BOARD: Dictionary = {
	"width": 4, "depth": 4, "h_play": 8,
	"starting_contents": {"layers": {
		"0": ["####", "#..#", "#..#", "####"],
		"1": ["#...", "....", "....", "...#"],
	}},
}
## Demo-only palette (candy_toy.json has just hue 0 today).
const DEMO_COLORS: Dictionary = {"colors": {"0": "#f2a35c", "1": "#e8605a", "2": "#5aa9e8", "3": "#f2d45c", "4": "#9b6fe0", "5": "#6fcf7a"}}
const ELEVATION_DEG := 30.0
const CAMERA_DISTANCE := 60.0
const MARGIN := 1.0
const ROTATE_MS := 120

var _board: BoardState
var _spec: BoardSpec
var _bank: ShapeBank
var _art: ArtSet
var _palette: PaletteTable
var _view: BoardView
var _stage: BoardStage
var _piece_view: PieceView
var _ghost: GhostView
var _piece: ActivePiece
var _danger: bool = false
var _uid: int = 1


func _ready() -> void:
	var entries: Array = []
	var r: Dictionary = JsonReader.read_file(CONTENT_JSON, CONTENT_MAX_BYTES)
	if r["ok"] and r["data"].get("types") is Array:
		entries.append_array(r["data"]["types"])
	else:
		push_error("board_view_demo: " + str(r["error"]))
	var types: ContentTypes = ContentTypes.from_entries(entries)
	var res: BoardSpecResult = BoardSpec.parse(BOARD, BoardLimits.new(), types)
	if not res.errors.is_empty():
		push_error("board_view_demo: " + ", ".join(res.errors))
		return
	_spec = res.spec
	_board = BoardState.new(_spec, types)
	_bank = load(BANK_PATH) as ShapeBank
	_art = ArtSet.new(SET_ID)
	_palette = PaletteTable.from_dict(DEMO_COLORS)

	_stage = BoardStage.new()
	_view = BoardView.new()
	_piece_view = PieceView.new()
	_ghost = GhostView.new()
	for n: Node3D in [_stage, _view, _piece_view, _ghost]:
		add_child(n)
	_stage.build(_spec.size, _spec.h_play, _spec.mask)
	_view.bind(_board, _art, _palette)
	_piece_view.setup(_bank, _art, _palette)
	_place_camera()
	_spawn(0)
	print("board_view_demo: filled=%d (expect %d)" % [_view.filled_count(), _spec.contents.size()])


func _unhandled_key_input(event: InputEvent) -> void:
	var k: InputEventKey = event as InputEventKey
	if k == null or not k.pressed or _board == null:
		return
	match k.keycode:
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
			_spawn(k.keycode - KEY_1)
		KEY_LEFT: _try(Vector3i(-1, 0, 0), 0)
		KEY_RIGHT: _try(Vector3i(1, 0, 0), 0)
		KEY_UP: _try(Vector3i(0, 0, -1), 0)
		KEY_DOWN: _try(Vector3i(0, 0, 1), 0)
		KEY_R: _try(Vector3i(0, 1, 0), 0)
		KEY_F: _try(Vector3i(0, -1, 0), 0)
		KEY_Q: _try(Vector3i.ZERO, -1)
		KEY_E: _try(Vector3i.ZERO, 1)
		KEY_SPACE: _lock()
		KEY_Z: _remove_top()
		KEY_X:
			_board.shift_layers(PackedInt32Array([0]))
			_flush()
		KEY_C: _add_block()
		KEY_G:
			_danger = not _danger
			_stage.set_danger(_danger)


func _spawn(i: int) -> void:
	var ids: PackedStringArray = _bank.ids()
	var def: ShapeDef = _bank.get_shape(StringName(ids[mini(i, ids.size() - 1)]))
	var a: Vector2i = _spec.spawn_anchor
	_piece = ActivePiece.new(def, Vector3i(a.x, _spec.h_play - 2, a.y))
	_piece_view.show_piece(def.shape_id, _piece.orient, _piece.pivot, _spec.size)
	_refresh_ghost()


func _try(step: Vector3i, turn: int) -> void:
	if _piece == null:
		return
	var o: int = _piece.orient
	if turn != 0:
		o = _piece.rotated_orient(Orientations.Axis.Y, turn)
	var p: Vector3i = _piece.pivot + step
	if not _board.can_place(_piece.cells_at(o, p)):
		return
	_piece.orient = o
	_piece.pivot = p
	_piece_view.move_to(p, o, ROTATE_MS if turn != 0 else PieceView.MOVE_TWEEN_MS)
	_refresh_ghost()


func _refresh_ghost() -> void:
	var cells: Array[Vector3i] = _piece.cells()
	var drop: int = _board.cast(cells, Vector3i(0, -1, 0))
	var landed: Array[Vector3i] = _piece.cells_at(_piece.orient, _piece.pivot + Vector3i(0, -drop, 0))
	# Shadow: for each column, the cell resting on the surface (lowest landed cell of that column).
	var shadow: Array[Vector3i] = []
	for c: Vector3i in landed:
		var seen: bool = false
		for j: int in shadow.size():
			if shadow[j].x == c.x and shadow[j].z == c.z:
				shadow[j] = Vector3i(c.x, mini(shadow[j].y, c.y), c.z)
				seen = true
		if not seen:
			shadow.append(c)
	_ghost.show_cells(landed, _spec.size, _palette.color(_piece.shape.hue_id), shadow)


func _lock() -> void:
	if _piece == null:
		return
	for c: Vector3i in _piece.cells():
		_board.place(_board.index(c), KIND_BLOCK, _piece.shape.hue_id, _uid)
	_uid += 1
	_flush()
	_spawn(_uid % 5)


func _remove_top() -> void:
	for i: int in range(_spec.size.x * _spec.size.y * _spec.size.z - 1, -1, -1):
		if _board.is_active(i) and _board.get_kind(i) != 0:
			_board.remove(i, BoardState.Cause.CLEAR)
			break
	_flush()


func _add_block() -> void:
	for z: int in _spec.size.z:
		for x: int in _spec.size.x:
			var c := Vector3i(x, 0, z)
			while _board.in_bounds(c) and not _board.is_free(c):
				c.y += 1
			if _board.is_free(c):
				_board.place(_board.index(c), KIND_BLOCK, (x + z) % 6, _uid)
				_flush()
				return


func _flush() -> void:
	_view.apply_delta(_board.take_delta())
	if _piece != null:
		_refresh_ghost()
	print("board_view_demo: filled=%d" % _view.filled_count())


## Orthographic camera at the default yaw (CameraMath convention), looking at the board centre.
func _place_camera() -> void:
	var cam: Camera3D = $Camera3D
	var yaw: float = deg_to_rad(CameraMath.yaw_degrees(0, CameraMath.DEFAULT_BASE_DEG, CameraMath.DEFAULT_STEP_DEG))
	var elev: float = deg_to_rad(ELEVATION_DEG)
	var centre := Vector3(0.0, _spec.size.y * 0.5, 0.0)
	var forward_flat := Vector3(cos(yaw), 0.0, -sin(yaw))
	var offset: Vector3 = -forward_flat * cos(elev) * CAMERA_DISTANCE + Vector3.UP * sin(elev) * CAMERA_DISTANCE
	var vs: Vector2 = get_viewport().get_visible_rect().size
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.far = CAMERA_DISTANCE * 3.0
	cam.size = CameraMath.ortho_size(_spec.size, ELEVATION_DEG, vs.x / vs.y, MARGIN)
	cam.look_at_from_position(centre + offset, centre)
