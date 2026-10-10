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
var _plain_material: StandardMaterial3D
var _patterns: bool = false
var _contrast: bool = false
var _occlusion: int = 0
var _focus: Vector3 = Vector3.ZERO
var _eye: Vector3 = Vector3(1,1,1)
var _visibility: float = 1.0
var _stickers: int = 0
var _custom_content: bool = false


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
	_update_presentation_material()


## Fades or cuts foreground cubes above the ghost; changes only rendered coverage.
func set_occlusion(mode: String, focus: Vector3, eye: Vector3) -> void:
	_occlusion = 2 if mode == "cutaway" else (1 if mode in ["fade", "default"] else 0)
	_focus = focus
	_eye = eye
	_update_presentation_material()


func _update_presentation_material() -> void:
	if _mmi == null:
		return
	if not _patterns and _occlusion == 0 and _visibility >= .999 and _stickers==0:
		_mmi.material_override = _plain_material
		return
	if _pattern_material == null:
		var shader := Shader.new()
		shader.code = """shader_type spatial;
varying vec3 lp;
varying vec3 ln;
varying float motif;
varying vec3 center;
uniform int stickers=0;
uniform bool patterns=false;
uniform bool high_contrast=false;
uniform int occlusion=0;
uniform vec3 focus=vec3(0.0);
uniform vec3 eye=vec3(1.0);
uniform float visibility=1.0;
void vertex(){lp=VERTEX;ln=NORMAL;motif=INSTANCE_CUSTOM.r;center=(MODEL_MATRIX*vec4(0.0,0.0,0.0,1.0)).xyz;}
void fragment(){
 if(fract(sin(dot(floor(FRAGCOORD.xy),vec2(12.9898,78.233)))*43758.5453)>visibility)discard;
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


func _write(slot: int, cell: int) -> void:
	var pos: Vector3 = BoardGeom.cell_center(_board.cell(cell), _board.size())
	_mm.set_instance_transform(slot, Transform3D(Basis.from_scale(Vector3.ONE * (.001 if _custom_content and _board.get_kind(cell)>=3 else _scale)), pos))
	_mm.set_instance_color(slot, _palette.color(_board.get_color(cell)))
	_mm.set_instance_custom_data(slot, Color(float(_palette.pattern_code(_board.get_color(cell)))/16.0, 0, 0, 1.0))
