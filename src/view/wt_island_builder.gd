class_name WtIslandBuilder extends RefCounted
## Builds the big floating-island platform under the board, its stone tile grid, biome
## props scattered on the margin, and a painted sky backdrop.
## Look data: res://assets/data/biome_looks.json (via WtBlockMaterials.look).
## References: assets/art/reference/screens_flow_ref.png, underwater/volcanic biome sheets.

## Ground margin around the board footprint, in cells.
const MARGIN := 2.4
## Superellipse exponent of the island outline: 2 = oval, higher = squarer.
const SQUARENESS := 5.0
const OUTLINE_POINTS := 72
const UNDERSIDE_RINGS := 6
const TILE_GAP := 0.06
const TILE_HEIGHT := 0.12
const ISLAND_SHADER := "res://src/view/shaders/spatial_env_island.gdshader"
const SKY_SHADER := "res://src/view/shaders/canvas_env_sky.gdshader"
const STYLE_IDS := {"meadow": 1, "candy": 2, "ice": 3, "underwater": 4, "lava": 5, "forest": 6, "cave": 7,
	"clockwork": 8, "neon": 9, "celestial": 10, "carnival": 11, "dune": 12}

var _look: Dictionary
var _biome: StringName
var _rng := RandomNumberGenerator.new()


func _init(biome: StringName) -> void:
	_biome = biome
	_look = WtBlockMaterials.look(biome)
	_rng.seed = hash(String(biome))


## Half extents (x, z) of the island top for a board footprint.
static func half_extents(board: Vector3i) -> Vector2:
	return Vector2(board.x * 0.5 + MARGIN, board.z * 0.5 + MARGIN)


## Adds island ground, underside and tile grid under `parent`. `active` filters inactive cells.
func build_island(parent: Node3D, board: Vector3i, active: Callable) -> void:
	var island: Dictionary = _look.get("island", {})
	var half: Vector2 = half_extents(board)
	var material := ShaderMaterial.new()
	material.shader = load(ISLAND_SHADER) as Shader
	material.set_shader_parameter(&"style", int(STYLE_IDS.get(String(_biome), 1)))
	material.set_shader_parameter(&"accent", Color(String(_look.get("accent", "#F2E35C"))))
	var node := MeshInstance3D.new()
	node.name = "FloatingIsland"
	node.mesh = _island_mesh(half, island)
	node.material_override = material
	parent.add_child(node)
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
	material.set_shader_parameter(&"night", 1.0 if _biome in [&"neon", &"celestial", &"cave", &"underwater"] else 0.0)
	material.set_shader_parameter(&"bubbles", 1.0 if _biome == &"underwater" else 0.0)
	rect.material = material
	layer.add_child(rect)
	owner.add_child(layer)


## Scatters small biome dressing on the island margin (never on the grid).
func build_dressing(parent: Node3D, board: Vector3i) -> void:
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


func _island_mesh(half: Vector2, island: Dictionary) -> ArrayMesh:
	var top_color: Color = Color(String(island.get("top", "#86C060")))
	var rim_color: Color = Color(String(island.get("rim", "#6FA94D")))
	var cliff: Color = Color(String(island.get("cliff", "#8C6A4A")))
	var cliff_dark: Color = Color(String(island.get("cliff_dark", "#5E4630")))
	var outline: PackedVector2Array = _outline(half)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Top: a fan from the centre, slightly domed at the edges.
	var centre := Vector3(0, -0.02, 0)
	for i: int in outline.size():
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[(i + 1) % outline.size()]
		_tri(st, centre, Vector3(a.x, -0.05, a.y), Vector3(b.x, -0.05, b.y), top_color, top_color, top_color)
	# Rings down the underside: a rim band, then rocky strata tapering to a point.
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
		_tri(st, last[(i + 1) % last.size()], last[i], tip, cliff_dark, cliff_dark, cliff_dark.darkened(0.2))
	st.generate_normals()
	return st.commit()


func _build_tiles(parent: Node3D, board: Vector3i, island: Dictionary, active: Callable) -> void:
	var tile: Color = Color(String(island.get("tile", "#E9DFC8")))
	var tile_alt: Color = Color(String(island.get("tile_alt", "#DDD1B6")))
	# Raised stone border around the grid, like the mockup's paved plaza.
	var border := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(board.x + 0.5, 0.16, board.z + 0.5)
	border.mesh = box
	border.position = Vector3(0, -0.07, 0)
	border.material_override = _flat(tile_alt.darkened(0.18))
	parent.add_child(border)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var tile_mesh := BoxMesh.new()
	tile_mesh.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	mm.mesh = tile_mesh
	var cells: Array[Vector3] = []
	var tints: Array[Color] = []
	for z: int in board.z:
		for x: int in board.x:
			if not active.call(x, z): continue
			cells.append(Vector3(x - board.x * 0.5 + 0.5, -TILE_HEIGHT * 0.5 + 0.01, z - board.z * 0.5 + 0.5))
			var c: Color = tile if (x + z) % 2 == 0 else tile_alt
			tints.append(c.lightened(_rng.randf() * 0.05).darkened(_rng.randf() * 0.04))
	mm.instance_count = cells.size()
	for i: int in cells.size():
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, cells[i]))
		mm.set_instance_color(i, tints[i])
	var node := MultiMeshInstance3D.new()
	node.name = "BoardTiles"
	node.multimesh = mm
	var mat := _flat(Color.WHITE)
	mat.vertex_color_use_as_albedo = true
	node.material_override = mat
	parent.add_child(node)


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
		"clover":
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
	_tri(st, a, c, b, upper, lower, upper)
	_tri(st, a, d, c, upper, lower, lower)
