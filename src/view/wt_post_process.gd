class_name WtPostProcess extends RefCounted
## Shared painted post-process (design/art/style-techniques.md 1.1): one full-screen spatial quad
## on the stage camera plus Environment glow tuning. Works on Compatibility, Mobile and Forward+.
## Data: assets/data/biome_looks.json biomes.<id>.post (merged over `DEFAULTS`). Every key is a
## shader uniform of spatial_post_painted.gdshader, except the `glow_*` keys which tune the
## Environment glow. Colours are "#RRGGBB" strings, vectors are [r, g, b] arrays.

const SHADER := "res://src/view/shaders/spatial_post_painted.gdshader"
## Fallback values used when a biome has no `post` entry (or omits a key).
const DEFAULTS := {
	"outline_strength": 0.55, "outline_color": "#3B2346", "outline_threshold": 0.35, "outline_width": 1.0,
	"ao_strength": 0.35, "ao_radius": 6.0, "ao_range": 1.5, "ao_tint": "#5A4880",
	"bloom_strength": 0.25, "bloom_threshold": 0.9, "bloom_tint": "#FFD9A6",
	"focus_depth": 35.0, "haze_start": 6.0, "haze_range": 40.0, "haze_strength": 0.3,
	"haze_color": "#CCE0FA", "dof_strength": 2.0,
	"warm_tint": "#FFF5E0", "shadow_lift": 0.02,
	"vignette_strength": 0.25, "vignette_radius": 0.85, "vignette_color": "#3A2050",
	"glow_intensity": 0.55, "glow_bloom": 0.04, "glow_hdr_threshold": 0.95,
}

var _material: ShaderMaterial
var _quad: MeshInstance3D
var _values: Dictionary


## Resolved post values for `biome` (DEFAULTS merged with biomes.<id>.post).
static func values_for(biome: StringName) -> Dictionary:
	var out: Dictionary = DEFAULTS.duplicate()
	out.merge(WtBlockMaterials.look(biome).get("post", {}), true)
	return out


## Adds the full-screen quad under `camera` and tunes `env` glow. `enabled=false` only tunes glow.
func attach(camera: Camera3D, env: Environment, biome: StringName, enabled: bool = true) -> void:
	_values = values_for(biome)
	if env != null:
		env.glow_intensity = float(_values.glow_intensity)
		env.glow_bloom = float(_values.glow_bloom)
		env.glow_hdr_threshold = float(_values.glow_hdr_threshold)
	if not enabled or camera == null:
		return
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER) as Shader
	_material.render_priority = 127
	for key: String in _values:
		if key.begins_with("glow_"): continue
		_material.set_shader_parameter(StringName(key), _convert(_values[key]))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2, 2)
	mesh.flip_faces = true
	_quad = MeshInstance3D.new()
	_quad.name = "PostPainted"
	_quad.mesh = mesh
	_quad.material_override = _material
	_quad.extra_cull_margin = 16384.0
	_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	camera.add_child(_quad)


## Sets the focal distance (camera to board centre) so the far islands blur and haze.
func set_focus(distance: float) -> void:
	if _material != null:
		_material.set_shader_parameter(&"focus_depth", distance)


## The quad's material (null when post is disabled); used by tests and QA captures.
func material() -> ShaderMaterial:
	return _material


static func _convert(v: Variant) -> Variant:
	if v is String: return Color(String(v))
	if v is Array:
		var a: Array = v
		return Vector3(float(a[0]), float(a[1]), float(a[2]))
	return v
