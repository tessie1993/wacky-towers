class_name WtIslandBuilder extends RefCounted
## Builds the big floating-island platform under the board, its stone tile grid, biome
## props scattered on the margin, falls off the lip, under-island dressing and the sky.
## 3D kit: res://assets/models/env/*.glb (assets/source/blender/env/build_env_kit.py).
## Look data: res://assets/data/biome_looks.json (via WtBlockMaterials.look), key `env` per biome.
## Every GLB is optional: when one is missing the old procedural geometry is used instead.
## Draw calls: one MultiMesh per prop kind, one for the lip, one for the tiles, one per under kind.
## References: assets/art/reference/screens_flow_ref.png, underwater/volcanic biome sheets.

## Ground margin around the board footprint, in cells.
const MARGIN := 2.4
## Superellipse exponent of the island outline: 2 = oval, higher = squarer.
const SQUARENESS := 5.0
const OUTLINE_POINTS := 72
const UNDERSIDE_RINGS := 6
const TILE_GAP := 0.06
const TILE_HEIGHT := 0.12
## Spacing of lip segments along the outline, metres (segments are 1.1 m long, so they overlap).
const LIP_STEP := 0.8
## How far the lip segment origin sits inside the outline (the lip bulges ~0.28 m outward).
const LIP_INSET := 0.1
## Minimum spacing between dressing props, metres.
const PROP_SPACING := 0.42
const ENV_DIR := "res://assets/models/env/"
const ISLAND_SHADER := "res://src/view/shaders/spatial_env_island.gdshader"
const ROCK_SHADER := "res://src/view/shaders/spatial_env_rock.gdshader"
const PROP_SHADER := "res://src/view/shaders/spatial_env_prop.gdshader"
const TILE_SHADER := "res://src/view/shaders/spatial_env_tile.gdshader"
const FALL_SHADER := "res://src/view/shaders/spatial_env_fall.gdshader"
const DETAIL_TEXTURE := "res://assets/models/env/env_detail.png"
const SKY_SHADER := "res://src/view/shaders/canvas_env_sky.gdshader"
const STYLE_IDS := {"meadow": 1, "candy": 2, "ice": 3, "underwater": 4, "lava": 5, "forest": 6, "cave": 7,
	"clockwork": 8, "neon": 9, "celestial": 10, "carnival": 11, "dune": 12}
## Lip GLB per `env.lip` value.
const LIP_MESHES := {"grass": "env_lip_grass", "snow": "env_lip_snow", "rock": "env_lip_rock"}
## Under-island dressing: mesh, flipped upside down, base scale, surface depth range (fraction).
const UNDER_KINDS := {
	"roots": {"mesh": "env_roots", "flip": false, "scale": 1.0, "depth": [0.0, 0.0]},
	"shards": {"mesh": "prop_crystal", "flip": true, "scale": 1.3, "depth": [0.2, 0.75]},
	"icicles": {"mesh": "prop_crystal", "flip": true, "scale": 1.1, "depth": [0.1, 0.6]},
	"kelp": {"mesh": "prop_kelp", "flip": true, "scale": 1.0, "depth": [0.0, 0.0]},
	"gears": {"mesh": "prop_gear", "flip": false, "scale": 1.6, "depth": [0.08, 0.35]},
}

static var _mesh_cache: Dictionary = {}

var _look: Dictionary
var _env: Dictionary
var _biome: StringName
var _rng := RandomNumberGenerator.new()
var _fall_sources: Array[Vector3] = []
## Seconds-per-frame motion scale for shader animation (0 = reduced motion).
var motion: float = 1.0


func _init(biome: StringName) -> void:
	_biome = biome
	_look = WtBlockMaterials.look(biome)
	_env = _look.get("env", {})
	_rng.seed = hash(String(biome))


## Half extents (x, z) of the island top for a board footprint.
static func half_extents(board: Vector3i) -> Vector2:
	return Vector2(board.x * 0.5 + MARGIN, board.z * 0.5 + MARGIN)


## Depth of the rocky underside below the top for a given half extent.
static func underside_depth(half: Vector2) -> float:
	return 2.4 + maxf(half.x, half.y) * 0.62


## Returns the first mesh in res://assets/models/env/<mesh_name>.glb, or null if it is missing.
static func env_mesh(mesh_name: String) -> Mesh:
	if _mesh_cache.has(mesh_name):
		return _mesh_cache[mesh_name]
	var mesh: Mesh = null
	var path: String = ENV_DIR + mesh_name + ".glb"
	if ResourceLoader.exists(path):
		var scene := load(path) as PackedScene
		if scene != null:
			var root: Node = scene.instantiate()
			var found: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
			if root is MeshInstance3D:
				found.push_front(root)
			if not found.is_empty():
				mesh = (found[0] as MeshInstance3D).mesh
			root.free()
	_mesh_cache[mesh_name] = mesh
	return mesh


## Adds island ground, underside, lip, falls, under-dressing and tile grid under `parent`.
## `active` filters inactive cells.
func build_island(parent: Node3D, board: Vector3i, active: Callable) -> void:
	var island: Dictionary = _look.get("island", {})
	var half: Vector2 = half_extents(board)
	var underside: Mesh = env_mesh("env_island_underside")
	var material := ShaderMaterial.new()
	material.shader = load(ISLAND_SHADER) as Shader
	material.set_shader_parameter(&"style", _style())
	material.set_shader_parameter(&"accent", Color(String(_look.get("accent", "#F2E35C"))))
	material.set_shader_parameter(&"detail", _detail())
	if String(_env.get("lip", "grass")) != "grass":
		material.set_shader_parameter(&"speckle", 0.012)
	var node := MeshInstance3D.new()
	node.name = "FloatingIsland"
	node.mesh = _island_mesh(half, island, underside == null)
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	if underside != null:
		var under := MeshInstance3D.new()
		under.name = "IslandUnderside"
		under.mesh = underside
		under.material_override = _rock_material(island, 1.0)
		under.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		under.position = Vector3(0, -0.12, 0)
		under.scale = Vector3(half.x * 0.99, underside_depth(half), half.y * 0.99)
		parent.add_child(under)
	_build_lip(parent, half, island)
	_build_under(parent, half, island)
	_build_falls(parent, half)
	_build_tiles(parent, board, island, active)


## Paints the sky behind the 3D world (a canvas layer drawn as the environment background).
func build_sky(owner: Node, environment: Environment) -> void:
	var sky: Array = _look.get("sky", ["#8EC9F0", "#D9EEF8", "#F7F1DE"])
	environment.background_mode = Environment.BG_CANVAS
	environment.background_canvas_max_layer = -1
	var layer := CanvasLayer.new()
	layer.name = "SkyBackdrop"
	layer.layer = -10
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = load(SKY_SHADER) as Shader
	material.set_shader_parameter(&"top", Color(String(sky[0])))
	material.set_shader_parameter(&"middle", Color(String(sky[1])))
	material.set_shader_parameter(&"bottom", Color(String(sky[2])))
	material.set_shader_parameter(&"cloud", Color(String(_look.get("cloud", "#FFFFFF"))))
	material.set_shader_parameter(&"far_island", Color(String(_look.get("far_island", "#9FC79A"))))
	var island: Dictionary = _look.get("island", {})
	material.set_shader_parameter(&"far_rock", Color(String(island.get("cliff", "#8C6A4A"))))
	material.set_shader_parameter(&"night", 1.0 if _biome in [&"neon", &"celestial", &"cave", &"underwater"] else 0.0)
	material.set_shader_parameter(&"bubbles", 1.0 if _biome == &"underwater" else 0.0)
	var falls: Dictionary = _env.get("falls", {})
	material.set_shader_parameter(&"far_fall", Color(String(falls.get("light", "#CFEFFF"))))
	material.set_shader_parameter(&"far_falls", 0.0 if String(falls.get("kind", "none")) == "none" else 1.0)
	material.set_shader_parameter(&"motion", motion)
	rect.material = material
	layer.add_child(rect)
	owner.add_child(layer)


## Scatters biome dressing on the island margin (never on the grid), one MultiMesh per kind.
func build_dressing(parent: Node3D, board: Vector3i) -> void:
	var half: Vector2 = half_extents(board)
	var inner := Vector2(board.x * 0.5 + 0.45, board.z * 0.5 + 0.45)
	var kinds: Array = _env.get("dressing", [])
	if kinds.is_empty():
		_build_dressing_fallback(parent, board)
		return
	var count: int = int((half.x * half.y - inner.x * inner.y) * 2.4)
	var placed: Array[Vector3] = []
	var groups: Dictionary = {}
	# Frame each fall source with a pair of rocks, like the mockup springs.
	for src: Vector3 in _fall_sources:
		var side: Vector3 = Vector3(src.z, 0, -src.x).normalized() * 0.55
		for s: float in [-1.0, 1.0]:
			_add_instance(groups, {"kind": "rock", "tint": "cliff"}, src + side * s, _rng.randf_range(0.9, 1.2))
			placed.append(src + side * s)
	for i: int in count * 3:
		if placed.size() >= count: break
		var p := Vector3(_rng.randf_range(-half.x + 0.4, half.x - 0.4), 0.0, _rng.randf_range(-half.y + 0.4, half.y - 0.4))
		if absf(p.x) < inner.x and absf(p.z) < inner.y: continue
		if not _inside(p, half, 0.45): continue
		if _near(p, placed, PROP_SPACING) or _near(p, _fall_sources, 0.9): continue
		placed.append(p)
		var spec: Dictionary = _pick(kinds)
		var scale_range: Array = spec.get("scale", [0.75, 1.25])
		_add_instance(groups, spec, p, _rng.randf_range(float(scale_range[0]), float(scale_range[1])))
	_commit_groups(parent, groups, "Dressing_")


## Larger set-dressing behind and beside the board (stage backdrop), one MultiMesh per kind.
func build_backdrop(parent: Node3D, board: Vector3i) -> void:
	var kinds: Array = _env.get("backdrop", [])
	if kinds.is_empty(): return
	var half: Vector2 = half_extents(board)
	var groups: Dictionary = {}
	var spots: Array[Vector3] = []
	# Back corners and the two far edges (the default camera looks from +x +z).
	for i: int in 7:
		var t: float = (i + 0.5) / 7.0
		spots.append(Vector3(lerpf(-half.x + 0.7, half.x - 0.7, t), 0, -half.y + 0.75 + _rng.randf_range(-0.15, 0.25)))
	for i: int in 4:
		var t: float = (i + 0.5) / 4.0
		spots.append(Vector3(-half.x + 0.75 + _rng.randf_range(-0.15, 0.25), 0, lerpf(-half.y + 1.6, half.y - 1.0, t)))
	for p: Vector3 in spots:
		if not _inside(p, half, 0.3): continue
		var spec: Dictionary = _pick(kinds)
		_add_instance(groups, spec, p, _rng.randf_range(1.35, 1.9))
	_commit_groups(parent, groups, "Backdrop_")


# ------------------------------------------------------------------ island top + fallback underside

func _island_mesh(half: Vector2, island: Dictionary, with_underside: bool) -> ArrayMesh:
	var top_color: Color = Color(String(island.get("top", "#86C060")))
	var rim_color: Color = Color(String(island.get("rim", "#6FA94D")))
	var cliff: Color = Color(String(island.get("cliff", "#8C6A4A")))
	var cliff_dark: Color = Color(String(island.get("cliff_dark", "#5E4630")))
	var outline: PackedVector2Array = _outline(half)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Top: a fan from the centre, slightly domed at the edges. Winding: clockwise seen from above.
	var centre := Vector3(0, -0.02, 0)
	for i: int in outline.size():
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[(i + 1) % outline.size()]
		_tri(st, centre, Vector3(b.x, -0.05, b.y), Vector3(a.x, -0.05, a.y), top_color, top_color, top_color)
	if with_underside:
		# Procedural fallback: rings down the underside, a rim band then rocky strata to a point.
		var depth: float = 3.0 + maxf(half.x, half.y) * 0.55
		var rings: Array[PackedVector3Array] = []
		var colours: Array[Color] = []
		var first := PackedVector3Array()
		for v: Vector2 in outline: first.append(Vector3(v.x, -0.05, v.y))
		rings.append(first); colours.append(top_color)
		for r: int in range(1, UNDERSIDE_RINGS + 1):
			var t: float = float(r) / UNDERSIDE_RINGS
			var shrink: float = 1.0 - pow(t, 1.6) * 0.92
			var y: float = -0.05 - (0.45 if r == 1 else 0.45 + (t - 1.0 / UNDERSIDE_RINGS) * depth)
			var ring := PackedVector3Array()
			for i: int in outline.size():
				var v: Vector2 = outline[i] * (0.99 if r == 1 else shrink)
				var jag: float = 1.0 if r == 1 else 1.0 + (_rng.randf() - 0.5) * 0.22
				ring.append(Vector3(v.x * jag, y + (0.0 if r == 1 else (_rng.randf() - 0.5) * 0.5), v.y * jag))
			rings.append(ring)
			colours.append(rim_color if r == 1 else cliff.lerp(cliff_dark, t).lightened(0.08 if r % 2 == 0 else 0.0))
		for r: int in range(rings.size() - 1):
			var upper: PackedVector3Array = rings[r]
			var lower: PackedVector3Array = rings[r + 1]
			for i: int in upper.size():
				var j: int = (i + 1) % upper.size()
				_quad(st, upper[i], upper[j], lower[j], lower[i], colours[r], colours[r + 1])
		var tip := Vector3(0, -0.5 - depth * 1.15, 0)
		var last: PackedVector3Array = rings[rings.size() - 1]
		for i: int in last.size():
			_tri(st, last[i], last[(i + 1) % last.size()], tip, cliff_dark, cliff_dark, cliff_dark.darkened(0.2))
	st.generate_normals()
	return st.commit()


# ------------------------------------------------------------------ lip, under-dressing, falls

func _build_lip(parent: Node3D, half: Vector2, island: Dictionary) -> void:
	var kind: String = String(_env.get("lip", "grass"))
	var mesh: Mesh = env_mesh(String(LIP_MESHES.get(kind, "env_lip_grass")))
	if mesh == null: return
	var outline: PackedVector2Array = _outline(half)
	var transforms: Array[Transform3D] = []
	for sample: Dictionary in _walk(outline, LIP_STEP, _rng.randf() * LIP_STEP):
		var p: Vector2 = sample.point - sample.normal * LIP_INSET
		var basis := Basis(-sample.tangent3, Vector3.UP, sample.normal3)
		var thick: float = _rng.randf_range(1.0, 1.35)
		basis = basis.scaled_local(Vector3(_rng.randf_range(0.95, 1.15), thick, _rng.randf_range(0.95, 1.1)))
		transforms.append(Transform3D(basis, Vector3(p.x, -0.06 + _rng.randf_range(-0.01, 0.015), p.y)))
	var mat := _rock_material(island, 0.0)
	mat.set_shader_parameter(&"cover_color", _lip_color(island))
	parent.add_child(_mmi("IslandLip", mesh, transforms, [], mat))


func _build_under(parent: Node3D, half: Vector2, island: Dictionary) -> void:
	var depth: float = underside_depth(half)
	var outline: PackedVector2Array = _outline(half)
	for kind: String in _env.get("under", []):
		var spec: Dictionary = UNDER_KINDS.get(kind, {})
		if spec.is_empty(): continue
		var mesh: Mesh = env_mesh(String(spec.mesh))
		if mesh == null: continue
		var transforms: Array[Transform3D] = []
		var customs: Array[Color] = []
		var range_t: Array = spec.depth
		var step: float = 1.6 if kind == "gears" else 1.15
		for sample: Dictionary in _walk(outline, step, _rng.randf() * step):
			if _rng.randf() < 0.25: continue
			var t: float = _rng.randf_range(float(range_t[0]), float(range_t[1]))
			var r: float = _underside_profile(t)
			var p: Vector2 = sample.point * r
			var y: float = -0.12 - t * depth
			var s: float = float(spec.scale) * _rng.randf_range(0.7, 1.25)
			var basis := Basis.IDENTITY
			if kind == "gears":
				# Axle along the outward normal, half sunk into the rock.
				basis = Basis(sample.tangent3, sample.normal3, sample.tangent3.cross(sample.normal3)).orthonormalized()
				p -= sample.normal * 0.18
				y -= 0.35
			elif kind == "roots" or kind == "kelp":
				p = sample.point * 0.94
				y = -0.36
				basis = Basis(Vector3.UP, _rng.randf() * TAU)
			if spec.flip:
				basis = basis * Basis(Vector3.RIGHT, PI)
				p -= sample.normal * 0.12
			transforms.append(Transform3D(basis.scaled_local(Vector3.ONE * s), Vector3(p.x, y, p.y)))
			customs.append(Color(1, 1, 1, _rng.randf()))
		var mat: Material
		if kind == "roots":
			mat = _rock_material(island, 0.0)
			mat.set_shader_parameter(&"cover_color", _lip_color(island).darkened(0.1))
		else:
			var tint: String = {"shards": "accent", "icicles": "#DDF2FF", "kelp": "white", "gears": "white"}.get(kind, "white")
			if kind == "shards" and _biome == &"lava": tint = "#6A3FB0"
			for i: int in customs.size():
				var c: Color = _tint(tint).srgb_to_linear()
				customs[i] = Color(c.r, c.g, c.b, customs[i].a)
			mat = _prop_material({"glow": 0.9 if kind == "shards" else (0.2 if kind == "icicles" else 0.0),
				"spin": 0.35 if kind == "gears" else 0.0, "sway": 0.06 if kind == "kelp" else 0.0})
		parent.add_child(_mmi("Under_" + kind, mesh, transforms, customs, mat))


func _build_falls(parent: Node3D, half: Vector2) -> void:
	var falls: Dictionary = _env.get("falls", {})
	var count: int = int(falls.get("count", 0))
	if String(falls.get("kind", "none")) == "none" or count <= 0: return
	var mesh: Mesh = env_mesh("env_fall_ribbon")
	if mesh == null: return
	var outline: PackedVector2Array = _outline(half)
	var depth: float = underside_depth(half)
	var mat := ShaderMaterial.new()
	mat.shader = load(FALL_SHADER) as Shader
	for key: String in ["deep", "light", "foam"]:
		if falls.has(key): mat.set_shader_parameter(StringName(key), Color(String(falls[key])))
	for key: String in ["emission", "speed", "sparkle"]:
		if falls.has(key): mat.set_shader_parameter(StringName(key), float(falls[key]))
	mat.set_shader_parameter(&"motion", motion)
	# Front-facing edges for the default camera (+x, +z): angles ~25 deg and ~70 deg.
	var angles: Array[float] = [0.42, 1.22, 0.85]
	for i: int in mini(count, angles.size()):
		var idx: int = int(round(angles[i] / TAU * OUTLINE_POINTS)) % OUTLINE_POINTS
		var a: Vector2 = outline[idx]
		var b: Vector2 = outline[(idx + 1) % OUTLINE_POINTS]
		var tangent: Vector2 = (b - a).normalized()
		var normal := Vector2(tangent.y, -tangent.x)
		if normal.dot(a) < 0.0: normal = -normal
		var src: Vector2 = a - normal * 0.35
		var basis := Basis(-Vector3(tangent.x, 0, tangent.y), Vector3.UP, Vector3(normal.x, 0, normal.y))
		basis = basis.scaled_local(Vector3(1.5, depth * 1.05, 1.35))
		var node := MeshInstance3D.new()
		node.name = "Fall%d" % i
		node.mesh = mesh
		node.material_override = mat
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.transform = Transform3D(basis, Vector3(src.x, 0.0, src.y))
		parent.add_child(node)
		_fall_sources.append(Vector3(src.x, 0, src.y))


# ------------------------------------------------------------------ tiles

func _build_tiles(parent: Node3D, board: Vector3i, island: Dictionary, active: Callable) -> void:
	var tile: Color = Color(String(island.get("tile", "#E9DFC8")))
	var tile_alt: Color = Color(String(island.get("tile_alt", "#DDD1B6")))
	var tile_mesh: Mesh = env_mesh("env_tile")
	# Raised stone border around the grid, like the mockup's paved plaza.
	var border := MeshInstance3D.new()
	border.name = "BoardBorder"
	var box := BoxMesh.new()
	box.size = Vector3(board.x + 0.5, 0.16, board.z + 0.5)
	border.mesh = box
	border.position = Vector3(0, -0.07, 0)
	border.material_override = _flat(tile_alt.darkened(0.18))
	parent.add_child(border)
	var transforms: Array[Transform3D] = []
	var customs: Array[Color] = []
	for z: int in board.z:
		for x: int in board.x:
			if not active.call(x, z): continue
			var c: Color = tile if (x + z) % 2 == 0 else tile_alt
			c = c.lightened(_rng.randf() * 0.05).darkened(_rng.randf() * 0.04)
			var lin: Color = c.srgb_to_linear()
			if tile_mesh != null:
				var basis := Basis(Vector3.UP, (_rng.randi() % 4) * PI * 0.5)
				transforms.append(Transform3D(basis, Vector3(x - board.x * 0.5 + 0.5, 0.01, z - board.z * 0.5 + 0.5)))
				customs.append(Color(lin.r, lin.g, lin.b, _rng.randf()))
			else:
				transforms.append(Transform3D(Basis.IDENTITY, Vector3(x - board.x * 0.5 + 0.5, -TILE_HEIGHT * 0.5 + 0.01, z - board.z * 0.5 + 0.5)))
				customs.append(c)
	if tile_mesh != null:
		var mat := ShaderMaterial.new()
		mat.shader = load(TILE_SHADER) as Shader
		mat.set_shader_parameter(&"detail", _detail())
		if _env.has("tile_glow"):
			mat.set_shader_parameter(&"edge_glow_color", Color(String(_env["tile_glow"])))
			mat.set_shader_parameter(&"edge_glow", 1.6)
		var node := _mmi("BoardTiles", tile_mesh, transforms, customs, mat)
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(node)
		return
	# Fallback: flat boxes tinted by instance colour.
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var box_tile := BoxMesh.new()
	box_tile.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	mm.mesh = box_tile
	mm.instance_count = transforms.size()
	for i: int in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, customs[i])
	var fallback := MultiMeshInstance3D.new()
	fallback.name = "BoardTiles"
	fallback.multimesh = mm
	var flat := _flat(Color.WHITE)
	flat.vertex_color_use_as_albedo = true
	fallback.material_override = flat
	parent.add_child(fallback)


# ------------------------------------------------------------------ helpers

func _style() -> int:
	return int(STYLE_IDS.get(String(_biome), 1))


func _detail() -> Texture2D:
	return load(DETAIL_TEXTURE) as Texture2D if ResourceLoader.exists(DETAIL_TEXTURE) else null


func _lip_color(island: Dictionary) -> Color:
	return Color(String(_env.get("lip_color", island.get("rim", "#6FA94D"))))


func _rock_material(island: Dictionary, gradient: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load(ROCK_SHADER) as Shader
	mat.set_shader_parameter(&"cliff", Color(String(island.get("cliff", "#8C6A4A"))))
	mat.set_shader_parameter(&"cliff_dark", Color(String(island.get("cliff_dark", "#5E4630"))))
	mat.set_shader_parameter(&"cover_color", Color(String(island.get("rim", "#6FA94D"))))
	mat.set_shader_parameter(&"depth_gradient", gradient)
	mat.set_shader_parameter(&"style", _style())
	mat.set_shader_parameter(&"accent", Color(String(_look.get("accent", "#F2E35C"))))
	mat.set_shader_parameter(&"detail", _detail())
	var block: Dictionary = _look.get("block", {})
	if _biome == &"lava":
		mat.set_shader_parameter(&"glow_color", Color(String(block.get("glow_color", "#FF6A1A"))))
		mat.set_shader_parameter(&"glow", 2.2)
	elif _biome in [&"cave", &"neon", &"celestial"]:
		mat.set_shader_parameter(&"glow", 1.2)
	return mat


func _prop_material(spec: Dictionary) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load(PROP_SHADER) as Shader
	mat.set_shader_parameter(&"emission_strength", float(spec.get("glow", 0.0)))
	mat.set_shader_parameter(&"sway", float(spec.get("sway", 0.0)))
	mat.set_shader_parameter(&"spin", float(spec.get("spin", 0.0)))
	mat.set_shader_parameter(&"motion", motion)
	var sky: Array = _look.get("sky", ["#8EC9F0", "#D9EEF8", "#F7F1DE"])
	mat.set_shader_parameter(&"rim_color", Color(String(sky[1])))
	return mat


## Resolves a tint keyword (white|top|rim|cliff|accent) or a #hex colour (sRGB).
func _tint(key: String) -> Color:
	var island: Dictionary = _look.get("island", {})
	match key:
		"white", "": return Color.WHITE
		"top": return Color(String(island.get("top", "#86C060"))).lightened(0.1)
		"rim": return Color(String(island.get("rim", "#6FA94D"))).lightened(0.12)
		"cliff": return Color(String(island.get("cliff", "#8C6A4A"))).lightened(0.35)
		"accent": return Color(String(_look.get("accent", "#F2E35C")))
	return Color(key) if key.begins_with("#") else Color.WHITE


func _pick(kinds: Array) -> Dictionary:
	var total: float = 0.0
	for k: Dictionary in kinds: total += float(k.get("weight", 1.0))
	var roll: float = _rng.randf() * total
	for k: Dictionary in kinds:
		roll -= float(k.get("weight", 1.0))
		if roll <= 0.0: return k
	return kinds[kinds.size() - 1]


func _add_instance(groups: Dictionary, spec: Dictionary, p: Vector3, s: float) -> void:
	var kind: String = String(spec.get("kind", "rock"))
	if not groups.has(kind):
		groups[kind] = {"spec": spec, "xf": [] as Array[Transform3D], "custom": [] as Array[Color]}
	var basis := Basis(Vector3.UP, _rng.randf() * TAU).scaled_local(Vector3.ONE * s)
	var c: Color = _tint(String(spec.get("tint", "white"))).srgb_to_linear()
	var jitter: float = _rng.randf_range(0.9, 1.08)
	(groups[kind].xf as Array[Transform3D]).append(Transform3D(basis, p + Vector3(0, -0.04, 0)))
	(groups[kind].custom as Array[Color]).append(Color(c.r * jitter, c.g * jitter, c.b * jitter, _rng.randf()))


func _commit_groups(parent: Node3D, groups: Dictionary, prefix: String) -> void:
	var island: Dictionary = _look.get("island", {})
	var accent: Color = Color(String(_look.get("accent", "#F2E35C")))
	for kind: String in groups:
		var group: Dictionary = groups[kind]
		var mesh: Mesh = env_mesh("prop_" + kind)
		if mesh == null:
			# Procedural fallback, one node per instance (old path, many draw calls).
			for xf: Transform3D in group.xf:
				_prop(parent, xf.origin, kind, island, accent)
			continue
		parent.add_child(_mmi(prefix + kind, mesh, group.xf, group.custom, _prop_material(group.spec)))


func _mmi(node_name: String, mesh: Mesh, transforms: Array[Transform3D], customs: Array[Color], mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i: int in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_custom_data(i, customs[i] if i < customs.size() else Color(1, 1, 1, float(i % 7) / 7.0))
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## Samples the closed outline every `step` metres: point, outward normal and tangent (2D and 3D).
func _walk(outline: PackedVector2Array, step: float, offset: float) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var carry: float = offset
	for i: int in outline.size():
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[(i + 1) % outline.size()]
		var seg: float = a.distance_to(b)
		var tangent: Vector2 = (b - a) / maxf(seg, 0.0001)
		var normal := Vector2(tangent.y, -tangent.x)
		if normal.dot(a + b) < 0.0: normal = -normal
		while carry <= seg:
			var p: Vector2 = a + tangent * carry
			out.append({"point": p, "normal": normal, "tangent3": Vector3(tangent.x, 0, tangent.y), "normal3": Vector3(normal.x, 0, normal.y)})
			carry += step
		carry -= seg
	return out


## Radius scale of env_island_underside at depth fraction t (mirrors build_env_kit.underside_profile).
static func _underside_profile(t: float) -> float:
	var k: float = t * 4.0
	var saw: float = 1.0 - (k - floorf(k))
	return maxf(pow(1.0 - t, 0.85) * (0.9 + 0.1 * saw * saw), 0.0)


func _near(p: Vector3, others: Array[Vector3], dist: float) -> bool:
	for o: Vector3 in others:
		if p.distance_to(o) < dist: return true
	return false


func _outline(half: Vector2) -> PackedVector2Array:
	# Superellipse (exponent SQUARENESS) reads as a soft rounded square, like the mockup islands.
	var points := PackedVector2Array()
	for i: int in OUTLINE_POINTS:
		var a: float = TAU * i / OUTLINE_POINTS
		var c: float = cos(a)
		var s: float = sin(a)
		var x: float = signf(c) * pow(absf(c), 2.0 / SQUARENESS) * half.x
		var z: float = signf(s) * pow(absf(s), 2.0 / SQUARENESS) * half.y
		var wobble: float = 1.0 + sin(a * 7.0 + 1.3) * 0.015 + sin(a * 13.0) * 0.01
		points.append(Vector2(x, z) * wobble)
	return points


func _inside(p: Vector3, half: Vector2, pad: float) -> bool:
	var hx: float = maxf(half.x - pad, 0.1)
	var hz: float = maxf(half.y - pad, 0.1)
	return pow(absf(p.x) / hx, SQUARENESS) + pow(absf(p.z) / hz, SQUARENESS) < 1.0


# ------------------------------------------------------------------ procedural fallback dressing
# Used only when a biome has no `env.dressing` list or a prop GLB is missing.

func _build_dressing_fallback(parent: Node3D, board: Vector3i) -> void:
	var half: Vector2 = half_extents(board)
	var inner := Vector2(board.x * 0.5 + 0.45, board.z * 0.5 + 0.45)
	var island: Dictionary = _look.get("island", {})
	var accent: Color = Color(String(_look.get("accent", "#F2E35C")))
	var top: Color = Color(String(island.get("top", "#86C060")))
	var props: Array = _look.get("props", [])
	var count: int = int((half.x * half.y - inner.x * inner.y) * 1.6)
	for i: int in count:
		var p := Vector3(_rng.randf_range(-half.x + 0.5, half.x - 0.5), 0.0, _rng.randf_range(-half.y + 0.5, half.y - 0.5))
		if absf(p.x) < inner.x and absf(p.z) < inner.y: continue
		if not _inside(p, half, 0.6): continue
		var roll: float = _rng.randf()
		if roll < 0.45:
			_tuft(parent, p, top)
		elif roll < 0.75:
			_flower(parent, p, accent)
		elif not props.is_empty():
			_prop(parent, p, String(props[_rng.randi() % props.size()]), island, accent)


func _tuft(parent: Node3D, p: Vector3, colour: Color) -> void:
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0; cone.bottom_radius = 0.09; cone.height = 0.22; cone.radial_segments = 5; cone.rings = 1
	for k: int in 3:
		var m := MeshInstance3D.new()
		m.mesh = cone
		m.position = p + Vector3((k - 1) * 0.07, 0.1, _rng.randf_range(-0.05, 0.05))
		m.rotation.z = (k - 1) * 0.35
		m.material_override = _flat(colour.darkened(0.15 + _rng.randf() * 0.1))
		parent.add_child(m)


func _flower(parent: Node3D, p: Vector3, accent: Color) -> void:
	var palette: Array[Color] = [Color("#FFFDF4"), accent, Color("#F6A8C8"), Color("#B9A2F0")]
	var petal := SphereMesh.new()
	petal.radius = 0.07; petal.height = 0.08; petal.radial_segments = 8; petal.rings = 4
	var colour: Color = palette[_rng.randi() % palette.size()]
	for k: int in 5:
		var a: float = TAU * k / 5.0
		var m := MeshInstance3D.new()
		m.mesh = petal
		m.position = p + Vector3(cos(a) * 0.07, 0.06, sin(a) * 0.07)
		m.material_override = _flat(colour)
		parent.add_child(m)
	var heart := MeshInstance3D.new()
	heart.mesh = petal
	heart.scale = Vector3.ONE * 0.6
	heart.position = p + Vector3(0, 0.08, 0)
	heart.material_override = _flat(Color("#F2C14E"))
	parent.add_child(heart)


func _prop(parent: Node3D, p: Vector3, kind: String, island: Dictionary, accent: Color) -> void:
	var root := Node3D.new()
	root.name = "Prop_" + kind
	root.position = p
	root.rotation.y = _rng.randf() * TAU
	var s: float = _rng.randf_range(0.8, 1.2)
	root.scale = Vector3.ONE * s
	parent.add_child(root)
	var rock: Color = Color(String(island.get("cliff", "#8C6A4A"))).lightened(0.15)
	match kind:
		"bush":
			for k: int in 3: _ball(root, Vector3((k - 1) * 0.22, 0.2 + (k % 2) * 0.08, 0), 0.24, Color(String(island.get("rim", "#6FA94D"))).darkened(0.1 * k))
		"rock", "rock_snow", "obsidian":
			_ball(root, Vector3(0, 0.12, 0), 0.26, rock, Vector3(1.2, 0.7, 1.0))
			if kind == "rock_snow": _ball(root, Vector3(0, 0.22, 0), 0.2, Color("#F6FAFF"), Vector3(1.2, 0.4, 1.0))
		"tree":
			_cyl(root, Vector3(0, 0.35, 0), 0.06, 0.09, 0.7, Color("#8B6A48"))
			_ball(root, Vector3(0, 0.95, 0), 0.42, Color(String(island.get("rim", "#6FA94D"))).darkened(0.12), Vector3(1, 1.15, 1))
		"pine_snow":
			_cyl(root, Vector3(0, 0.15, 0), 0.05, 0.06, 0.3, Color("#7A5A40"))
			for k: int in 3: _cyl(root, Vector3(0, 0.4 + k * 0.28, 0), 0.0, 0.42 - k * 0.1, 0.45, Color("#E8F2FB").darkened(0.05 * k))
		"ice_crystal", "crystal":
			var c: Color = Color("#BFE7FF") if kind == "ice_crystal" else accent
			for k: int in 3:
				var shard := _cyl(root, Vector3((k - 1) * 0.14, 0.3, 0), 0.0, 0.1, 0.55 + k * 0.12, c)
				shard.rotation.z = (k - 1) * 0.3
		"clover", "flowers":
			for k: int in 3: _ball(root, Vector3(cos(k * 2.1) * 0.06, 0.06, sin(k * 2.1) * 0.06), 0.06, Color("#4E9A3A"))
		"coral":
			for k: int in 4:
				var branch := _cyl(root, Vector3((k - 1.5) * 0.1, 0.3, 0), 0.04, 0.06, 0.6 + (k % 2) * 0.2, accent)
				branch.rotation.z = (k - 1.5) * 0.3
		"shell":
			_ball(root, Vector3(0, 0.1, 0), 0.2, Color("#F3D9E6"), Vector3(1.0, 0.5, 0.8))
		"kelp":
			for k: int in 3:
				var blade := _cyl(root, Vector3((k - 1) * 0.1, 0.45, 0), 0.02, 0.05, 0.9 + k * 0.15, Color("#5E8F4A"))
				blade.rotation.z = (k - 1) * 0.18
		"lollipop", "candy":
			_cyl(root, Vector3(0, 0.4, 0), 0.025, 0.025, 0.8, Color("#FFF7EC"))
			_ball(root, Vector3(0, 0.85, 0), 0.24, accent, Vector3(1, 1, 0.45))
		"mushroom", "mushroom_glow":
			_cyl(root, Vector3(0, 0.16, 0), 0.06, 0.08, 0.32, Color("#F4EAD8"))
			_ball(root, Vector3(0, 0.34, 0), 0.22, Color("#D9534F") if kind == "mushroom" else accent, Vector3(1, 0.55, 1))
		"stump":
			_cyl(root, Vector3(0, 0.15, 0), 0.22, 0.26, 0.3, Color("#8B6A48"))
		"gear":
			var gear := TorusMesh.new()
			gear.inner_radius = 0.16; gear.outer_radius = 0.3; gear.rings = 10; gear.ring_segments = 6
			var g := MeshInstance3D.new(); g.mesh = gear; g.position = Vector3(0, 0.32, 0); g.rotation.x = PI * 0.5
			g.material_override = _flat(accent); root.add_child(g)
		"pipe":
			_cyl(root, Vector3(0, 0.4, 0), 0.08, 0.08, 0.8, accent.darkened(0.2))
		"neon_pillar", "neon_ring", "pillar":
			_cyl(root, Vector3(0, 0.5, 0), 0.12, 0.14, 1.0, Color(String(island.get("tile", "#EFEAE0"))))
			_ball(root, Vector3(0, 1.05, 0), 0.1, accent)
		"star":
			_ball(root, Vector3(0, 0.25, 0), 0.14, accent)
		"arch":
			_cyl(root, Vector3(-0.3, 0.45, 0), 0.08, 0.08, 0.9, Color(String(island.get("tile", "#EFEAE0"))))
			_cyl(root, Vector3(0.3, 0.45, 0), 0.08, 0.08, 0.9, Color(String(island.get("tile", "#EFEAE0"))))
		"tent", "balloon", "flag":
			_cyl(root, Vector3(0, 0.45, 0), 0.015, 0.015, 0.9, Color("#FFF7EC"))
			_ball(root, Vector3(0, 0.95, 0), 0.18, [accent, Color("#E98AA6"), Color("#9CC3DE")][_rng.randi() % 3], Vector3(1, 1.2, 1))
		"palm":
			_cyl(root, Vector3(0, 0.5, 0), 0.05, 0.08, 1.0, Color("#A57A50"))
			for k: int in 5:
				var leaf := _ball(root, Vector3(cos(k * 1.26) * 0.25, 1.0, sin(k * 1.26) * 0.25), 0.2, Color("#5E9A3E"), Vector3(1.6, 0.25, 0.6))
				leaf.rotation.y = -k * 1.26
		"pot":
			_ball(root, Vector3(0, 0.2, 0), 0.22, Color("#C8722E"), Vector3(1, 1.1, 1))
		"vent":
			_cyl(root, Vector3(0, 0.2, 0), 0.14, 0.3, 0.4, rock)
			_ball(root, Vector3(0, 0.4, 0), 0.1, Color("#FF7A1F"))
		_:
			_ball(root, Vector3(0, 0.12, 0), 0.2, rock)


func _ball(parent: Node3D, pos: Vector3, radius: float, colour: Color, stretch: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius; mesh.height = radius * 2.0; mesh.radial_segments = 10; mesh.rings = 6
	var m := MeshInstance3D.new()
	m.mesh = mesh; m.position = pos; m.scale = stretch
	m.material_override = _flat(colour)
	parent.add_child(m)
	return m


func _cyl(parent: Node3D, pos: Vector3, top: float, bottom: float, height: float, colour: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top; mesh.bottom_radius = bottom; mesh.height = height; mesh.radial_segments = 8; mesh.rings = 1
	var m := MeshInstance3D.new()
	m.mesh = mesh; m.position = pos
	m.material_override = _flat(colour)
	parent.add_child(m)
	return m


func _flat(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	m.roughness = 0.85
	return m


func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ca: Color, cb: Color, cc: Color) -> void:
	st.set_color(ca); st.add_vertex(a)
	st.set_color(cb); st.add_vertex(b)
	st.set_color(cc); st.add_vertex(c)


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, upper: Color, lower: Color) -> void:
	# Outward-facing winding for the fallback underside rings.
	_tri(st, a, b, c, upper, upper, lower)
	_tri(st, a, c, d, upper, lower, lower)
