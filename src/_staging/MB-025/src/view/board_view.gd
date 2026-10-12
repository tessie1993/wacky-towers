class_name BoardView extends Node3D
## Locked blocks as ONE MultiMeshInstance3D (ADR-0007 §1, greybox). Node origin = board anchor
## (footprint centre at floor level, BoardGeom). Usage: view.bind(board, art_set, palette); view.apply_delta(board.take_delta())

## Dark outline colour shared by blocks and the falling piece (HUD readability table). Art direction may retint.
@export var outline_color: Color = Color(0.07, 0.06, 0.09) # ponytail: placeholder
## Outline thickness in mesh-local units (cube mesh is ~1.03 wide). 0 disables the outline.
@export var outline_grow: float = 0.03 # ponytail: one colour for all hues; per-hue outline needs the block shader

var _board: BoardState
var _palette: PaletteTable
var _scale: float = 1.0
var _mesh: Mesh
var _mmi: MultiMeshInstance3D
var _mm: MultiMesh
var _slots: SlotMap = SlotMap.new()


## Flat material with an inverted-hull outline pass. albedo is used when use_instance_color is false.
## Usage: mesh_instance.material_override = BoardView.make_material(Color.RED, Color.BLACK, 0.03, false)
static func make_material(albedo: Color, outline: Color, grow: float, use_instance_color: bool) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = use_instance_color
	m.albedo_color = albedo
	m.roughness = 0.6
	if grow > 0.0:
		var o := StandardMaterial3D.new()
		o.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		o.cull_mode = BaseMaterial3D.CULL_FRONT
		o.albedo_color = outline
		o.grow = true
		o.grow_amount = grow
		m.next_pass = o
	return m


## Builds the MultiMesh from the board's current contents (LAYOUT). Safe to call again.
## Usage: view.bind(board, art_set, art_set.palette())
func bind(board: BoardState, art_set: ArtSet, palette: PaletteTable) -> void:
	_board = board
	_palette = palette
	_scale = art_set.cube_scale()
	_mesh = art_set.cube_mesh()
	if _mesh == null:
		push_warning("BoardView: set '%s' has no cube mesh, using BoxMesh" % art_set.set_id())
		_mesh = BoxMesh.new()
	if _mmi == null:
		_mmi = MultiMeshInstance3D.new()
		_mmi.name = "LockedBlocks"
		add_child(_mmi)
	_mmi.material_override = make_material(Color.WHITE, outline_color, outline_grow, true)
	_rebuild()


## Applies a BoardState.take_delta() record: triples [op, a, b] (ADR-0002 §5). STATUS/OVERLAY are ignored for now.
## Usage: view.apply_delta(board.take_delta())
func apply_delta(delta: PackedInt32Array) -> void:
	if _board == null:
		return
	for t: int in range(0, delta.size() - 2, 3):
		var a: int = delta[t + 1]
		var b: int = delta[t + 2]
		match delta[t]:
			BoardState.Op.SET:
				var slot: int = _slots.slot_of(a)
				if slot == SlotMap.EMPTY:
					slot = _slots.add(a)
				if slot == SlotMap.EMPTY:
					_rebuild()
					return
				_write(slot, a)
			BoardState.Op.REMOVE:
				var r: Vector2i = _slots.remove(a)
				if r.x != SlotMap.EMPTY and r.x != r.y: # swap the last slot into the hole
					_mm.set_instance_transform(r.x, _mm.get_instance_transform(r.y))
					_mm.set_instance_color(r.x, _mm.get_instance_color(r.y))
					_mm.set_instance_custom_data(r.x, _mm.get_instance_custom_data(r.y))
			BoardState.Op.MOVE:
				var s: int = _slots.move(a, b)
				if s == SlotMap.EMPTY:
					_rebuild() # view out of sync with the log; the board is the truth
					return
				_write(s, b)
			BoardState.Op.LAYOUT:
				_rebuild()
				return
			_:
				pass # STATUS, OVERLAY: no status/fade/ripple yet (CH-056 out of scope)
	_mm.visible_instance_count = _slots.filled()


## Number of blocks currently drawn. Usage: assert(view.filled_count() == 3)
func filled_count() -> int:
	return _slots.filled()


func _rebuild() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D # formats before instance_count (ADR-0007 §1)
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = _mesh
	mm.instance_count = _board.active_cell_count()
	mm.visible_instance_count = 0
	_mm = mm
	_mmi.multimesh = mm
	var size: Vector3i = _board.size()
	var n: int = size.x * size.y * size.z
	_slots.reset(n)
	for i: int in n:
		if _board.is_active(i) and _board.get_kind(i) != ContentTypes.KIND_EMPTY:
			_write(_slots.add(i), i)
	mm.visible_instance_count = _slots.filled()


func _write(slot: int, cell: int) -> void:
	var pos: Vector3 = BoardGeom.cell_center(_board.cell(cell), _board.size())
	_mm.set_instance_transform(slot, Transform3D(Basis.from_scale(Vector3.ONE * _scale), pos))
	_mm.set_instance_color(slot, _palette.color(_board.get_color(cell)))
	_mm.set_instance_custom_data(slot, BlockViewMath.instance_custom(0, 0, 0, 1.0))
