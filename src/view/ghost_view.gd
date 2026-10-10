class_name GhostView extends Node3D
## Landing ghost (hatched, dark-outlined, translucent) plus soft square shadows on the surface below.
## Node origin = board anchor. Pooled nodes, no allocation after warm-up.
## Usage: ghost.show_cells(piece_cells_at_drop_target, board.size(), hue_color)

const MAX_CUBES: int = 27 ## CH-164 pool cap (3x3x3).
const CUBE_SCALE: float = 0.96 ## Slightly under 1 so the ghost does not z-fight the piece when resting.
const SHADOW_SIZE: float = 0.9
const SHADOW_LIFT: float = 0.02

const _GHOST_SHADER: String = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec4 line_color : source_color = vec4(0.05, 0.05, 0.08, 1.0);
uniform float fill_alpha = 0.22;
uniform float hatch_alpha = 0.6;
uniform float hatch_freq = 5.0;
uniform float edge_width = 0.05;
varying vec3 lp;
void vertex() { lp = VERTEX; }
void fragment() {
	vec3 e = abs(abs(lp) - 0.5);
	float near = step(e.x, edge_width) + step(e.y, edge_width) + step(e.z, edge_width);
	float edge = step(2.0, near);
	float stripe = step(0.5, fract((lp.x + lp.y + lp.z) * hatch_freq));
	ALBEDO = mix(tint.rgb, line_color.rgb, edge);
	ALPHA = mix(mix(fill_alpha, hatch_alpha, stripe), 1.0, edge);
}
"""

const _SHADOW_SHADER: String = """
shader_type spatial;
render_mode unshaded, depth_draw_never;
uniform float strength = 0.35;
void fragment() {
	vec2 e = min(UV, 1.0 - UV);
	ALBEDO = vec3(0.0);
	ALPHA = strength * smoothstep(0.0, 0.35, min(e.x, e.y));
}
"""

## Shadow darkness (0..1). ponytail: fixed; wire to a setting if playtests want it.
@export var shadow_strength: float = 0.35

var _cubes: Array[MeshInstance3D] = []
var _shadows: Array[MeshInstance3D] = []
var _ghost_mat: ShaderMaterial


## Shows outline cubes at cells and a shadow under each column. shadow_cells = cells whose bottom face lies on the
## surface to shade (caller projects down to the highest solid cell); empty = shade the floor (y = 0) under each column.
## Usage: ghost.show_cells(piece.cells_at(o, landed_pivot), board.size(), palette.color(hue), landing_cells)
func show_cells(cells: Array[Vector3i], board_size: Vector3i, hue: Color, shadow_cells: Array[Vector3i] = []) -> void:
	_ensure_pool()
	_ghost_mat.set_shader_parameter(&"tint", hue)
	var n: int = mini(cells.size(), MAX_CUBES)
	for i: int in MAX_CUBES:
		_cubes[i].visible = i < n
		if i < n:
			_cubes[i].position = BoardGeom.cell_center(cells[i], board_size)
	var shade: int = 0
	if not shadow_cells.is_empty():
		for c: Vector3i in shadow_cells:
			if shade < MAX_CUBES:
				_place_shadow(shade, c, board_size)
				shade += 1
	else:
		for i: int in n: # first cell of each (x, z) column only
			var dup: bool = false
			for j: int in i:
				if cells[j].x == cells[i].x and cells[j].z == cells[i].z:
					dup = true
					break
			if not dup:
				_place_shadow(shade, Vector3i(cells[i].x, 0, cells[i].z), board_size)
				shade += 1
	for i: int in MAX_CUBES:
		_shadows[i].visible = i < shade
	visible = true


## Hides the ghost and shadows. Usage: ghost.hide_ghost()
func hide_ghost() -> void:
	visible = false


func _place_shadow(slot: int, c: Vector3i, board_size: Vector3i) -> void:
	var p: Vector3 = BoardGeom.cell_center(c, board_size)
	_shadows[slot].position = Vector3(p.x, c.y + SHADOW_LIFT, p.z)


func _ensure_pool() -> void:
	if not _cubes.is_empty():
		return
	var gs := Shader.new()
	gs.code = _GHOST_SHADER # ponytail: inline until the shader specialist owns a .gdshader
	_ghost_mat = ShaderMaterial.new()
	_ghost_mat.shader = gs
	var ss := Shader.new()
	ss.code = _SHADOW_SHADER
	var shadow_mat := ShaderMaterial.new()
	shadow_mat.shader = ss
	shadow_mat.set_shader_parameter(&"strength", shadow_strength)
	var box := BoxMesh.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(SHADOW_SIZE, SHADOW_SIZE)
	for i: int in MAX_CUBES:
		var c := MeshInstance3D.new()
		c.mesh = box
		c.material_override = _ghost_mat
		c.scale = Vector3.ONE * CUBE_SCALE
		c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		c.visible = false
		add_child(c)
		_cubes.append(c)
		var s := MeshInstance3D.new()
		s.mesh = plane
		s.material_override = shadow_mat
		s.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		s.visible = false
		add_child(s)
		_shadows.append(s)
