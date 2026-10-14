class_name WtSetPieceBuilder extends RefCounted
## Builds one level landmark ("set piece") from assets/data/set_pieces.json: composed primitives
## (box, cylinder, sphere, torus, prism, beam) merged per animation group into a few ArrayMeshes,
## drawn with the island prop shader (spatial_env_prop) on a small floating islet in the biome colours.
## Schema (also in tools/asset-pipeline/build_set_pieces.py, which generates the file):
##   pieces.<id> = {biome, title, accent, scale, islet_r, groups, parts}
##   part  = [kind, pos, size, colour, rot_deg?, group?, scale?]
##   kinds : b box [sx,sy,sz]  c cylinder [rtop,rbottom,h,segments]  s ellipsoid [rx,ry,rz]
##           t torus [inner,outer] (lies in XZ)  p gable prism [w,h,d]  m beam from pos to size[0..2], thickness size[3]
##   colour: "#RRGGBB" painted; "!#.." always glowing; "~#.." glows with the time of day (windows, lamps);
##           "@" the level accent (also "!@", "~@")
##   groups.<name> = {pivot, axis x|y|z, speed rad/s, mode spin|swing, amp deg, parent, counter}
## Piece space: ground is y = 0, the front faces +z, footprint radius <= 2.2. Draw calls: one
## MeshInstance3D per group, up to three surfaces (painted, glow, lit).

const DATA_PATH := "res://assets/data/set_pieces.json"
const PROP_SHADER := "res://src/view/shaders/spatial_env_prop.gdshader"
const HOT := 2.2

static var _data: Dictionary = {}


## All piece records keyed by id (loaded once).
static func pieces() -> Dictionary:
	if _data.is_empty() and FileAccess.file_exists(DATA_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if parsed is Dictionary:
			var root: Dictionary = parsed
			var all: Variant = root.get("pieces", {})
			if all is Dictionary: _data = all
	return _data


## True when `id` is defined in set_pieces.json.
static func has_piece(id: String) -> bool:
	return pieces().has(id)


## Ids that belong to `biome`, in file order.
static func ids_for_biome(biome: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for id: String in pieces():
		var rec: Dictionary = pieces()[id]
		if String(rec.get("biome", "")) == biome: out.append(id)
	return out


## Builds the landmark `id` standing on an islet. `opts`: accent (hex), shadow_tint (hex), motion (0..1),
## islet_dressing (count of rim tufts). Returns null for an unknown id. Metadata on the result:
## `anims` (Array of Dictionary, driven by animate()), `lit_mat` (ShaderMaterial of the "~" parts),
## `radius` (islet radius), `piece_scale` (authored scale).
static func build(id: String, opts: Dictionary = {}) -> Node3D:
	if not has_piece(id): return null
	var rec: Dictionary = pieces()[id]
	var biome: String = String(rec.get("biome", "meadow"))
	var accent_hex: String = String(opts.get("accent", rec.get("accent", "#D9674E")))
	var accent: Color = Color(accent_hex)
	var tint: String = String(opts.get("shadow_tint", "#6B5C9E"))
	var motion: float = float(opts.get("motion", 1.0))
	var mats: Dictionary = {
		"base": _material(0.0, tint),
		"glow": _material(HOT, tint),
		"lit": _material(HOT * 0.35, tint),
	}
	var root := Node3D.new()
	root.name = "SetPiece_" + id
	root.set_meta(&"lit_mat", mats["lit"])
	root.set_meta(&"piece_scale", float(rec.get("scale", 1.0)))
	var radius: float = float(rec.get("islet_r", 2.4))
	root.set_meta(&"radius", radius)
	var anims: Array[Dictionary] = []
	var groups: Dictionary = rec.get("groups", {})
	var nodes: Dictionary = {"": root}
	var pivots: Dictionary = {"": Vector3.ZERO}
	var surfaces: Dictionary = {"": _new_surfaces()}
	# Groups are created parent-first (a group may name a parent defined later in the file).
	var pending: Array = groups.keys()
	var guard: int = 0
	while not pending.is_empty() and guard < 64:
		guard += 1
		for gname: String in pending.duplicate():
			var g: Dictionary = groups[gname]
			var parent_name: String = String(g.get("parent", ""))
			if not nodes.has(parent_name): continue
			var pivot: Vector3 = _v3(g.get("pivot", [0, 0, 0]))
			var node := Node3D.new()
			node.name = gname
			node.position = pivot - (pivots[parent_name] as Vector3)
			(nodes[parent_name] as Node3D).add_child(node)
			nodes[gname] = node
			pivots[gname] = pivot
			surfaces[gname] = _new_surfaces()
			pending.erase(gname)
			var axis: int = ["x", "y", "z"].find(String(g.get("axis", "y")))
			anims.append({"node": node, "axis": maxi(axis, 0), "speed": float(g.get("speed", 0.3)) * motion if String(g.get("mode", "spin")) == "spin" else float(g.get("speed", 1.0)),
				"mode": String(g.get("mode", "spin")), "amp": deg_to_rad(float(g.get("amp", 20.0))) * motion,
				"counter": nodes.get(String(g.get("parent", "")), null) if bool(g.get("counter", false)) else null})
	_build_islet(surfaces[""], biome, id, radius, int(opts.get("islet_dressing", 4)), accent)
	for part: Array in rec.get("parts", []):
		var gname: String = String(part[5]) if part.size() > 5 else ""
		if not surfaces.has(gname): gname = ""
		_emit(surfaces[gname], part, pivots[gname], accent)
	for gname: String in surfaces:
		var inst: MeshInstance3D = _commit(surfaces[gname], mats)
		if inst == null: continue
		inst.name = "Mesh" if gname == "" else "Mesh_" + gname
		(nodes[gname] as Node3D).add_child(inst)
	root.set_meta(&"anims", anims)
	return root


## Advances every animated group of `root` to time `t` seconds (absolute pose, no accumulation).
static func animate(root: Node3D, t: float) -> void:
	if root == null or not root.has_meta(&"anims"): return
	var anims: Array = root.get_meta(&"anims")
	for a: Dictionary in anims:
		var node: Node3D = a["node"]
		if not is_instance_valid(node): continue
		var axis: int = int(a["axis"])
		var angle: float = 0.0
		if a["counter"] != null:
			angle = -(a["counter"] as Node3D).rotation[axis]
		elif String(a["mode"]) == "swing":
			angle = float(a["amp"]) * sin(float(a["speed"]) * t)
		else:
			angle = float(a["speed"]) * t
		var r: Vector3 = node.rotation
		r[axis] = angle
		node.rotation = r


# ------------------------------------------------------------------ meshes

static func _material(hot: float, tint: String) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load(PROP_SHADER) as Shader
	mat.set_shader_parameter(&"hot", hot)
	mat.set_shader_parameter(&"glow", 0.0)
	mat.set_shader_parameter(&"haze", 0.0)
	mat.set_shader_parameter(&"sway", 0.0)
	mat.set_shader_parameter(&"motion", 0.0)
	mat.set_shader_parameter(&"rim_amount", 0.45)
	mat.set_shader_parameter(&"gloss", 0.25)
	mat.set_shader_parameter(&"shadow_tint", Color(tint))
	return mat


static func _new_surfaces() -> Dictionary:
	var out: Dictionary = {}
	for key: String in ["base", "glow", "lit"]:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		out[key] = {"st": st, "n": 0}
	return out


static func _commit(surfaces: Dictionary, mats: Dictionary) -> MeshInstance3D:
	var mesh := ArrayMesh.new()
	var mat_list: Array[Material] = []
	for key: String in ["base", "glow", "lit"]:
		var s: Dictionary = surfaces[key]
		if int(s["n"]) == 0: continue
		(s["st"] as SurfaceTool).commit(mesh)
		mat_list.append(mats[key] as Material)
	if mat_list.is_empty(): return null
	for i: int in mat_list.size(): mesh.surface_set_material(i, mat_list[i])
	var inst := MeshInstance3D.new()
	inst.mesh = mesh
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return inst


static func _v3(a: Variant) -> Vector3:
	var arr: Array = a
	return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))


## Splits a colour code into [surface key, vertex colour].
static func _decode(code: String, accent: Color) -> Array:
	var key: String = "base"
	var alpha: float = 0.5
	var body: String = code
	if body.begins_with("!"):
		key = "glow"
		alpha = 0.0
		body = body.substr(1)
	elif body.begins_with("~"):
		key = "lit"
		alpha = 0.0
		body = body.substr(1)
	var c: Color = accent if body == "@" else Color(body)
	c.a = alpha
	return [key, c]


## Appends one authored part to the group's surfaces (position is relative to the group pivot).
static func _emit(surfaces: Dictionary, part: Array, pivot: Vector3, accent: Color) -> void:
	var kind: String = String(part[0])
	var pos: Vector3 = _v3(part[1]) - pivot
	var size: Array = part[2]
	var dec: Array = _decode(String(part[3]), accent)
	var surf: Dictionary = surfaces[String(dec[0])]
	var col: Color = dec[1]
	var rot: Vector3 = Vector3.ZERO
	if part.size() > 4 and (part[4] as Array).size() == 3: rot = _v3(part[4]) * (PI / 180.0)
	var extra: Vector3 = Vector3.ONE
	if part.size() > 6 and (part[6] as Array).size() == 3: extra = _v3(part[6])
	var st: SurfaceTool = surf["st"]
	var basis: Basis = Basis.from_euler(rot) * Basis.from_scale(extra)
	match kind:
		"b":
			var m := BoxMesh.new()
			m.size = _v3(size)
			_prim(st, m, Transform3D(basis, pos), col)
		"c":
			var m := CylinderMesh.new()
			m.top_radius = float(size[0])
			m.bottom_radius = float(size[1])
			m.height = float(size[2])
			m.radial_segments = int(size[3]) if size.size() > 3 else 12
			m.rings = 1
			_prim(st, m, Transform3D(basis, pos), col)
		"s":
			var m := SphereMesh.new()
			m.radius = 1.0
			m.height = 2.0
			m.radial_segments = 14
			m.rings = 7
			_prim(st, m, Transform3D(basis * Basis.from_scale(_v3(size)), pos), col)
		"t":
			var m := TorusMesh.new()
			m.inner_radius = float(size[0])
			m.outer_radius = float(size[1])
			m.rings = 28
			m.ring_segments = 8
			_prim(st, m, Transform3D(basis, pos), col)
		"p":
			_prism(st, Transform3D(basis * Basis.from_scale(_v3(size)), pos), col)
		"m":
			var to: Vector3 = Vector3(float(size[0]), float(size[1]), float(size[2])) - pivot
			var dir: Vector3 = to - pos
			var length: float = dir.length()
			if length < 0.0001: return
			var thick: float = float(size[3])
			var q: Quaternion = Quaternion(Vector3.UP, dir / length) if (dir / length).dot(Vector3.DOWN) < 0.9999 else Quaternion(Vector3.RIGHT, PI)
			var m := BoxMesh.new()
			m.size = Vector3(thick, length, thick)
			_prim(st, m, Transform3D(Basis(q), (pos + to) * 0.5), col)
		_:
			return
	surf["n"] = int(surf["n"]) + 1


static func _prim(st: SurfaceTool, prim: PrimitiveMesh, xf: Transform3D, col: Color) -> void:
	var arrays: Array = prim.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var nb: Basis = xf.basis.inverse().transposed()
	if xf.basis.determinant() < 0.0:
		for t: int in range(0, idx.size(), 3):
			var tmp: int = idx[t + 1]
			idx[t + 1] = idx[t + 2]
			idx[t + 2] = tmp
	for i: int in idx:
		st.set_color(col)
		st.set_normal((nb * norms[i]).normalized())
		st.add_vertex(xf * verts[i])


## Unit gable prism (width 1 along x, height 1 along y, depth 1 along z; ridge along z), centred.
static func _prism(st: SurfaceTool, xf: Transform3D, col: Color) -> void:
	var a := Vector3(-0.5, -0.5, 0.5)
	var b := Vector3(0.5, -0.5, 0.5)
	var c := Vector3(0.0, 0.5, 0.5)
	var d := Vector3(-0.5, -0.5, -0.5)
	var e := Vector3(0.5, -0.5, -0.5)
	var f := Vector3(0.0, 0.5, -0.5)
	var tris: Array = [
		[a, b, c, Vector3(0, 0, 1)], [e, d, f, Vector3(0, 0, -1)],
		[a, c, f, Vector3(-1, 1, 0).normalized()], [a, f, d, Vector3(-1, 1, 0).normalized()],
		[b, e, f, Vector3(1, 1, 0).normalized()], [b, f, c, Vector3(1, 1, 0).normalized()],
		[a, d, e, Vector3(0, -1, 0)], [a, e, b, Vector3(0, -1, 0)],
	]
	var nb: Basis = xf.basis.inverse().transposed()
	var flip: bool = xf.basis.determinant() < 0.0
	for t: Array in tris:
		var order: Array[int] = [0, 2, 1] if flip else [0, 1, 2]
		for k: int in order:
			st.set_color(col)
			st.set_normal((nb * (t[3] as Vector3)).normalized())
			st.add_vertex(xf * (t[k] as Vector3))


# ------------------------------------------------------------------ islet

## The small floating rock under every landmark, in the biome's island colours.
static func _build_islet(surfaces: Dictionary, biome: String, id: String, r: float, dressing: int, accent: Color) -> void:
	var look: Dictionary = WtBlockMaterials.look(StringName(biome))
	var isl: Dictionary = look.get("island", {})
	var top: String = String(isl.get("top", "#86C060"))
	var rim: String = String(isl.get("rim", "#6FA94D"))
	var cliff: String = String(isl.get("cliff", "#8C6A4A"))
	var dark: String = String(isl.get("cliff_dark", "#5E4630"))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	var parts: Array = [
		["c", [0, -0.17, 0], [r, r * 0.97, 0.34, 20], top],
		["c", [0, -0.12, 0], [r * 1.04, r * 1.0, 0.18, 20], rim],
		["c", [0, -1.65, 0], [r * 0.97, r * 0.2, 2.6, 16], cliff],
		["c", [0, -1.0, 0], [r * 0.99, r * 0.7, 0.5, 16], dark],
	]
	for i: int in 5:
		var a: float = rng.randf() * TAU
		var d: float = r * rng.randf_range(0.55, 0.85)
		var s: float = r * rng.randf_range(0.18, 0.3)
		parts.append(["s", [cos(a) * d, -rng.randf_range(0.7, 1.7), sin(a) * d], [s, s * 1.5, s], cliff if i % 2 == 0 else dark])
	for i: int in 3:
		var a: float = rng.randf() * TAU
		parts.append(["c", [cos(a) * r * 0.3, -3.3 - rng.randf() * 0.5, sin(a) * r * 0.3], [r * 0.12, 0.0, 0.8 + rng.randf() * 0.6, 6], dark])
	for i: int in dressing:
		var a: float = (float(i) + rng.randf() * 0.6) / float(maxi(dressing, 1)) * TAU
		var d: float = r * rng.randf_range(0.8, 0.95)
		var s: float = rng.randf_range(0.1, 0.2)
		var col: String = rim if i % 3 != 0 else "@"
		parts.append(["s", [cos(a) * d, s * 0.5, sin(a) * d], [s * 1.3, s, s * 1.3], col])
	for p: Array in parts: _emit(surfaces, p, Vector3.ZERO, accent)
