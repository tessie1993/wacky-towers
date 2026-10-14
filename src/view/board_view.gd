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
var _pattern_material: ShaderMaterial
var _biome_material: ShaderMaterial
var _plain_material: StandardMaterial3D
var _patterns: bool = false
var _contrast: bool = false
var _occlusion: int = 0
var _focus: Vector3 = Vector3.ZERO
var _eye: Vector3 = Vector3(1,1,1)
var _visibility: float = 1.0
var _cell_visibility: Dictionary = {}
var _item_hidden: Dictionary = {}
var _cell_default: float = 1.0
var _stickers: int = 0
var _custom_content: bool = false
## Per-piece palette variation (biome material `palette`): piece uid -> palette index, stable for the
## life of the view. Adjacent pieces never share an index when the palette allows it.
var _variant_count: int = 0
var _uid_variant: Dictionary = {}
## Neighbour order = seam bit order read by spatial_block_biome.gdshader: axis * 2 + (positive ? 1 : 0).
const _NEIGHBOURS: Array[Vector3i] = [Vector3i(-1, 0, 0), Vector3i(1, 0, 0), Vector3i(0, -1, 0), Vector3i(0, 1, 0), Vector3i(0, 0, -1), Vector3i(0, 0, 1)]


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
	_uid_variant.clear()
	_plain_material = make_material(Color.WHITE, outline_color, outline_grow, true)
	_mmi.material_override = _plain_material
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
	_refresh_pieces()
	_mm.visible_instance_count = _slots.filled()


## Number of blocks currently drawn. Usage: assert(view.filled_count() == 3)
func filled_count() -> int:
	return _slots.filled()


## Refreshes presentation from authoritative state without consuming its delta log.
func refresh() -> void:
	if _board != null:
		_rebuild()


## Optional painted pattern backup lets locked pieces remain distinct without colour.
func set_patterns(enabled: bool, contrast: bool = false) -> void:
	_patterns = enabled
	_contrast = contrast
	_update_presentation_material()


## Fog uses screen-door coverage on locked contents; the active/ghost layers stay clear.
func set_custom_content(enabled: bool) -> void:
	_custom_content=enabled
	refresh()


func set_stickers(code: int) -> void:
	_stickers=clampi(code,0,11)
	_update_presentation_material()


func set_visibility(alpha: float) -> void:
	_visibility = clampf(alpha,0.0,1.0)
	_cell_visibility.clear()
	_cell_default = 1.0
	_refresh_visibility_data()
	_update_presentation_material()


## Authoritative Cave fade/lantern coverage by cell; each newly locked piece stays bright.
func set_cell_visibility(records: Array, default_alpha: float = 1.0) -> void:
	_visibility = 1.0
	_cell_default = clampf(default_alpha,0.0,1.0)
	_cell_visibility.clear()
	for record: Variant in records:
		if record is Dictionary and record.get("cell") is Vector3i and _board.in_bounds(record.cell):
			var index: int = _board.index(record.cell)
			if index >= 0:
				_cell_visibility[index] = clampf(float(record.get("alpha",1.0)),0.0,1.0)
	_refresh_visibility_data()
	_update_presentation_material()


## The fog item is an independent mask and may coexist with biome fog.
func set_item_hidden(cells: Array) -> void:
	_item_hidden.clear()
	for cell: Variant in cells:
		if cell is Vector3i and _board.in_bounds(cell):
			var index: int = _board.index(cell)
			if index >= 0:
				_item_hidden[index] = true
	_refresh_visibility_data()
	_update_presentation_material()


func visibility_at(index: int) -> float:
	var alpha: float = float(_cell_visibility.get(index,_cell_default))
	return minf(alpha,.1) if _item_hidden.has(index) else alpha


func _refresh_visibility_data() -> void:
	if _mm == null:
		return
	for slot: int in _slots.filled():
		var custom: Color = _mm.get_instance_custom_data(slot)
		custom.a = visibility_at(_slots.cell_at(slot))
		_mm.set_instance_custom_data(slot,custom)


## Fades or cuts foreground cubes above the ghost; changes only rendered coverage.
func set_occlusion(mode: String, focus: Vector3, eye: Vector3) -> void:
	_occlusion = 2 if mode == "cutaway" else (1 if mode in ["fade", "default"] else 0)
	_focus = focus
	_eye = eye
	_update_presentation_material()


## Uses a biome block material (same uniform contract as the pattern material) for every state.
func set_biome_material(material: ShaderMaterial) -> void:
	_biome_material = material
	var size_param: Variant = material.get_shader_parameter(&"palette_size") if material != null else null
	_variant_count = int(size_param) if size_param is int or size_param is float else 0
	_refresh_pieces()
	_update_presentation_material()


## Number of per-piece colour variants of the current biome material (0 = none, pieces use the palette hue).
func variant_count() -> int:
	return _variant_count


## Authored (sRGB) colour of palette variant v, for the ghost/active layers; Color.WHITE when out of range.
func variant_color(v: int) -> Color:
	if _biome_material == null or v < 0 or v >= _variant_count:
		return Color.WHITE
	var pal: Variant = _biome_material.get_shader_parameter(&"palette")
	if pal is PackedColorArray and v < (pal as PackedColorArray).size():
		return (pal as PackedColorArray)[v]
	return Color.WHITE


## Variant index for the falling piece (-1 = none). Chosen against the pieces around `cells` (its landing
## cells), kept while it does not clash, and remembered so the piece keeps its colour when it locks.
## Usage: var v: int = view.variant_for_active(sim.get_piece_uid(), ghost_cells)
func variant_for_active(uid: int, cells: Array[Vector3i]) -> int:
	if _variant_count <= 0 or uid <= 0 or _board == null:
		return -1
	var taken: Dictionary = {}
	for c: Vector3i in cells:
		_collect_neighbour_variants(c, uid, taken)
	var cur: int = int(_uid_variant.get(uid, -1))
	if cur < 0 or taken.has(cur):
		cur = _pick_variant(uid, taken)
		_uid_variant[uid] = cur
	return cur


func _pick_variant(uid: int, taken: Dictionary) -> int:
	var h: int = (uid * 1103515245 + 12345) & 0x7fffffff
	var start: int = (h >> 8) % _variant_count
	for k: int in _variant_count:
		var v: int = (start + k) % _variant_count
		if not taken.has(v):
			return v
	return start


func _collect_neighbour_variants(c: Vector3i, uid: int, taken: Dictionary) -> void:
	for d: Vector3i in _NEIGHBOURS:
		var n: Vector3i = c + d
		if not _board.in_bounds(n):
			continue
		var ni: int = _board.index(n)
		if _slots.slot_of(ni) == SlotMap.EMPTY:
			continue
		var nu: int = int(_board.get_record(ni).get("piece_instance_id", 0))
		if nu != uid and _uid_variant.has(nu):
			taken[int(_uid_variant[nu])] = true


## Writes the per-piece channels of every locked instance: custom.g = palette variant + 1 (0 = none),
## custom.b = (seam bitmask + 64 * depth layer) / 2048; a mask bit is set when that face's neighbour is ANOTHER piece.
func _refresh_pieces() -> void:
	if _mm == null or _board == null:
		return
	if _biome_material != null:
		_biome_material.set_shader_parameter(&"layer_span", float(maxi(_board.layer_count(), 1)))
	var count: int = _slots.filled()
	var uid_of: Dictionary = {}
	var cells_of: Dictionary = {}
	for slot: int in count:
		var cell: int = _slots.cell_at(slot)
		var uid: int = int(_board.get_record(cell).get("piece_instance_id", 0))
		uid_of[cell] = uid
		if not cells_of.has(uid):
			cells_of[uid] = []
		(cells_of[uid] as Array).append(cell)
	if _variant_count > 0:
		var uids: Array = cells_of.keys()
		uids.sort()
		for uid: int in uids:
			if uid <= 0 or _uid_variant.has(uid):
				continue
			var taken: Dictionary = {}
			for cell: int in cells_of[uid]:
				_collect_neighbour_variants(_board.cell(cell), uid, taken)
			_uid_variant[uid] = _pick_variant(uid, taken)
	for slot: int in count:
		var cell: int = _slots.cell_at(slot)
		var uid: int = int(uid_of[cell])
		var mask: int = 0
		var c: Vector3i = _board.cell(cell)
		for bit: int in 6:
			var n: Vector3i = c + _NEIGHBOURS[bit]
			if _board.in_bounds(n):
				var ni: int = _board.index(n)
				if uid_of.has(ni) and int(uid_of[ni]) != uid:
					mask |= 1 << bit
		var custom: Color = _mm.get_instance_custom_data(slot)
		var variant: int = int(_uid_variant.get(uid, -1)) if _variant_count > 0 and uid > 0 else -1
		custom.g = float(variant + 1) / 16.0
		custom.b = float(mask + 64 * clampi(_board.layer_of(cell), 0, 31)) / 2048.0
		_mm.set_instance_custom_data(slot, custom)


func _update_presentation_material() -> void:
	if _mmi == null:
		return
	if _biome_material != null:
		for pair: Array in [[&"patterns", _patterns], [&"high_contrast", _contrast], [&"occlusion", _occlusion], [&"focus", _focus],
				[&"eye", _eye], [&"visibility", _visibility], [&"stickers", _stickers]]:
			_biome_material.set_shader_parameter(pair[0], pair[1])
		_mmi.material_override = _biome_material
		return
	if not _patterns and _occlusion == 0 and _visibility >= .999 and _stickers==0 and _cell_visibility.is_empty() and _item_hidden.is_empty():
		_mmi.material_override = _plain_material
		return
	if _pattern_material == null:
		var shader := Shader.new()
		shader.code = """shader_type spatial;
varying vec3 lp;
varying vec3 ln;
varying float motif;
varying float cell_alpha;
varying vec3 center;
uniform int stickers=0;
uniform bool patterns=false;
uniform bool high_contrast=false;
uniform int occlusion=0;
uniform vec3 focus=vec3(0.0);
uniform vec3 eye=vec3(1.0);
uniform float visibility=1.0;
void vertex(){lp=VERTEX;ln=NORMAL;motif=INSTANCE_CUSTOM.r;cell_alpha=INSTANCE_CUSTOM.a;center=(MODEL_MATRIX*vec4(0.0,0.0,0.0,1.0)).xyz;}
void fragment(){
 if(fract(sin(dot(floor(FRAGCOORD.xy),vec2(12.9898,78.233)))*43758.5453)>visibility*cell_alpha)discard;
 vec2 toward=normalize(eye.xz-focus.xz);
 if(occlusion>0&&center.y>focus.y+.4&&dot(center.xz-focus.xz,toward)>.3){
  if(occlusion==2)discard;
  if(fract(FRAGCOORD.x*.5)+fract(FRAGCOORD.y*.5)>.25)discard;
 }
 vec2 uv=abs(ln.y)>.5?lp.xz:(abs(ln.x)>.5?lp.zy:lp.xy);
 int code=int(floor(motif*16.0+.1));
 float stripe=0.0;
 if(code==1)stripe=step(.8,fract(uv.y*5.0));
 if(code==2)stripe=1.0-step(.16,length(fract(uv*4.0)-vec2(.5)));
 if(code==3)stripe=step(.8,fract(uv.y*4.0+sin(uv.x*12.0)*.18));
 if(code==4)stripe=mod(floor(uv.x*4.0)+floor(uv.y*4.0),2.0);
 if(code==5)stripe=step(.8,fract(length(uv)*8.0));
 if(code==6)stripe=max(step(.85,fract(uv.y*4.0)),step(.88,fract(uv.x*4.0+floor(uv.y*4.0)*.5)));
 vec2 st=abs(fract(uv*3.0)-vec2(.5));
 if(code==7)stripe=max((1.0-step(.06,st.x))*(1.0-step(.24,st.y)),(1.0-step(.06,st.y))*(1.0-step(.24,st.x)));
 if(code==8)stripe=1.0-step(.07,abs(st.x+st.y-.34));
 if(code==9)stripe=step(.8,fract(uv.x*5.0));
 if(code==10)stripe=max(step(.85,fract(uv.x*4.0)),step(.85,fract(uv.y*4.0)));
 ALBEDO=COLOR.rgb*(1.0-stripe*(patterns?(high_contrast?.58:.26):0.0));
 if(stickers>0){
  vec2 badge=uv-vec2(.23,.23);
  float mark=0.0;
  if(stickers%3==0)mark=1.0-step(.055,abs(badge.x)+abs(badge.y));
  if(stickers%3==1)mark=1.0-step(.048,length(badge));
  if(stickers%3==2)mark=(1.0-step(.048,abs(badge.x)))*(1.0-step(.025,abs(badge.y)));
  ALBEDO=mix(ALBEDO,vec3(.97,.92,.77),mark*.8);
 }
 ROUGHNESS=.45;SPECULAR=.45;
}"""
		_pattern_material = ShaderMaterial.new()
		_pattern_material.shader = shader
		# Outline would fill the dithered holes, so this material uses the bevel's painted edge.
	_pattern_material.set_shader_parameter(&"patterns",_patterns)
	_pattern_material.set_shader_parameter(&"high_contrast",_contrast)
	_pattern_material.set_shader_parameter(&"occlusion",_occlusion)
	_pattern_material.set_shader_parameter(&"focus",_focus)
	_pattern_material.set_shader_parameter(&"eye",_eye)
	_pattern_material.set_shader_parameter(&"visibility",_visibility)
	_pattern_material.set_shader_parameter(&"stickers",_stickers)
	_mmi.material_override = _pattern_material


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
	_refresh_pieces()


func _write(slot: int, cell: int) -> void:
	var pos: Vector3 = BoardGeom.cell_center(_board.cell(cell), _board.size())
	_mm.set_instance_transform(slot, Transform3D(Basis.from_scale(Vector3.ONE * (.001 if _custom_content and _board.get_kind(cell)>=3 else _scale)), pos))
	_mm.set_instance_color(slot, _palette.color(_board.get_color(cell)))
	_mm.set_instance_custom_data(slot, Color(float(_palette.pattern_code(_board.get_color(cell)))/16.0, 0, 0, visibility_at(cell)))
