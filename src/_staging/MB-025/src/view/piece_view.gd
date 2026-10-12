class_name PieceView extends Node3D
## The falling piece: shape GLB (or cube fallback) under this node, root transform from BoardGeom, eased between ticks.
## Node origin = board anchor. Usage: pv.setup(bank, art_set, palette); pv.show_piece(&"l", 0, Vector3i(1, 8, 1), board.size())

## Suggested tween for a move step (CH-057: fixed 60 ms). Rotations use the control.rotate_anim_ms knob.
const MOVE_TWEEN_MS: int = 60

@export var outline_color: Color = Color(0.07, 0.06, 0.09) # ponytail: matches BoardView placeholder
@export var outline_grow: float = 0.03

var _bank: ShapeBank
var _art: ArtSet
var _palette: PaletteTable
var _shape: ShapeDef
var _board_size: Vector3i = Vector3i.ZERO
var _body: Node3D
var _tween: Tween
var _from: Transform3D = Transform3D.IDENTITY
var _to: Transform3D = Transform3D.IDENTITY


## Injects the data sources. Usage: pv.setup(bank, art_set, art_set.palette())
func setup(bank: ShapeBank, art_set: ArtSet, palette: PaletteTable) -> void:
	_bank = bank
	_art = art_set
	_palette = palette


## Shows a shape at origin (the pivot cube cell) and orientation. Uses the set's shape GLB; falls back to one cube
## per offset when the GLB is missing. Usage: pv.show_piece(&"l", 0, piece.pivot, board.size())
func show_piece(shape_id: StringName, orient: int, origin: Vector3i, board_size: Vector3i) -> void:
	hide_piece()
	_shape = _bank.get_shape(shape_id)
	if _shape == null:
		push_error("PieceView: unknown shape '%s'" % shape_id)
		return
	_board_size = board_size
	var mat: StandardMaterial3D = BoardView.make_material(_palette.color(_shape.hue_id), outline_color, outline_grow, false)
	_body = Node3D.new()
	_body.name = "Body"
	add_child(_body)
	var scene: PackedScene = _art.shape_scene(shape_id)
	if scene != null:
		_build_from_scene(scene, mat)
	else:
		_build_fallback(mat)
	transform = BoardGeom.piece_root_transform(origin, orient, Vector3(_shape.source_pivot), board_size)
	visible = true


## Moves/rotates to a new pivot cell and orientation, eased over tween_ms (instant when 0).
## Usage: pv.move_to(piece.pivot, piece.orient, PieceView.MOVE_TWEEN_MS)
func move_to(origin: Vector3i, orient: int, tween_ms: int) -> void:
	if _shape == null:
		return
	_kill_tween()
	_to = BoardGeom.piece_root_transform(origin, orient, Vector3(_shape.source_pivot), _board_size)
	if tween_ms <= 0 or not is_inside_tree():
		transform = _to
		return
	_from = transform
	_tween = create_tween()
	_tween.tween_method(_blend, 0.0, 1.0, tween_ms / 1000.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


## Hides and frees the piece (lock: BoardView shows the written cubes the same frame).
func hide_piece() -> void:
	_kill_tween()
	visible = false
	_shape = null
	if _body != null:
		remove_child(_body)
		_body.queue_free()
		_body = null


func _blend(w: float) -> void:
	transform = _from.interpolate_with(_to, w)


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null


func _build_from_scene(scene: PackedScene, mat: Material) -> void:
	var root: Node = scene.instantiate()
	_body.add_child(root)
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	# Source cubes are ~1.03 wide on a 1.0 grid (overlap): shrink each about its own centre when it is one mesh per cube.
	# ponytail: a GLB with merged meshes keeps the overlap; fix in the asset pipeline.
	var s: float = _art.cube_scale()
	var shrink: bool = meshes.size() == _shape.cube_count and not is_equal_approx(s, 1.0)
	for n: Node in meshes:
		var mi: MeshInstance3D = n as MeshInstance3D
		mi.material_override = mat
		if shrink:
			var c: Vector3 = mi.get_aabb().get_center()
			mi.transform = mi.transform * Transform3D(Basis.from_scale(Vector3.ONE * s), c * (1.0 - s))


func _build_fallback(mat: Material) -> void:
	var mesh: Mesh = _art.cube_mesh()
	if mesh == null:
		mesh = BoxMesh.new()
	var s: float = _art.cube_scale()
	for off: Vector3i in _shape.offsets(0):
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = mat
		mi.transform = Transform3D(Basis.from_scale(Vector3.ONE * s), Vector3(off + _shape.source_pivot))
		_body.add_child(mi)
