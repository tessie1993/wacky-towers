class_name WtPropScatter extends RefCounted
## Hand-dressed island top scatter (ref 15, style/15_title_and_hud.png): seeded Poisson-disk
## clusters on the island slab — a hero tree or bush clump first, then bushes, then tufts,
## clovers and flowers ringed round it — plus a sparse clumpy fill and a rim spill band.
## Every prop is snapped to the slab by a downward ray against the slab's TriangleMesh and
## leaned to its normal (so rim props tip over the rounded edge). Exclusion zones keep the
## board grid and the cast spots clear; tall kinds are grouped per island side under the
## `TallDressing` node so WtIslandBuilder.update_facing() hides the sides between the camera
## and the board (the camera sight lines) at every snap yaw.
##
## Rules: res://assets/data/prop_scatter.json, keyed by biome. build() returns false when the
## biome has no rules, and the caller falls back to WtIslandBuilder.build_dressing().
## Draw calls: one MultiMesh per (kind, tint, side) group; hero groups below `multimesh_min`
## instances are plain MeshInstance3D sharing one material per tint (they cast shadows).
##
## Ground ray uses TriangleMesh.intersect_ray (verified on the installed 4.7.2 binary; not in
## docs/engine-reference). No physics space query: setup() may run before the stage is in the
## tree, and a one-shot snap does not justify a collider.

const DATA_PATH := "res://assets/data/prop_scatter.json"
## Name of the slab MeshInstance3D WtIslandBuilder.build_island() adds to the world.
const GROUND_NODE := "FloatingIsland"
const TALL_ROOT := "TallDressing"
const RAY_TOP := 3.0

static var _table_cache: Dictionary = {}

var _biome: StringName
var _builder: WtIslandBuilder
var _rules: Dictionary
var _rng := RandomNumberGenerator.new()
var _ground: TriangleMesh
var _ground_xf: Transform3D
var _half: Vector2
var _board_half: Vector2
## Placed footprints: [Vector2 position, float radius].
var _placed: Array = []
var _groups: Dictionary = {}
var _exclusions: Array = []


## `builder` supplies kit meshes and the prop shader preset for the same biome.
func _init(biome: StringName, builder: WtIslandBuilder) -> void:
	_biome = biome
	_builder = builder
	_rules = rules_for(biome)


## Scatter rules for `biome` from DATA_PATH, or {} when the biome has none.
static func rules_for(biome: StringName) -> Dictionary:
	if _table_cache.is_empty() and FileAccess.file_exists(DATA_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		if parsed is Dictionary: _table_cache = parsed
	var biomes: Dictionary = _table_cache.get("biomes", {})
	return biomes.get(String(biome), {})


## Scatters the biome's props onto the island slab already built under `world`.
## Returns false (nothing added) when the biome has no rules or the slab is missing.
func build(world: Node3D, board: Vector3i) -> bool:
	if _rules.is_empty(): return false
	var slab := world.get_node_or_null(GROUND_NODE) as MeshInstance3D
	if slab == null or slab.mesh == null: return false
	_ground = slab.mesh.generate_triangle_mesh()
	_ground_xf = slab.transform
	_half = WtIslandBuilder.half_extents(board)
	_board_half = Vector2(board.x * 0.5, board.z * 0.5)
	_rng.seed = hash("%s|%s|%d_%d" % [String(_rules.get("seed", "scatter")), String(_biome), board.x, board.z])
	_placed.clear()
	_groups.clear()
	_build_exclusions(board)
	_scatter_clusters()
	_scatter_fill()
	_emit(world)
	return true


# ------------------------------------------------------------------ placement passes

## Cluster anchors: Poisson-disk samples over the ring, weighted toward corners, then each
## template's layers are placed outward from the anchor (largest first).
func _scatter_clusters() -> void:
	var c: Dictionary = _rules.get("clusters", {})
	var templates: Array = c.get("templates", [])
	if templates.is_empty(): return
	var anchors: PackedVector2Array = _poisson(float(c.get("spacing", 2.0)), func(p: Vector2) -> bool:
		return _ring_gap(p) >= float(c.get("anchor_clear", 0.5)) and _inside(p, 0.15))
	var weights: Array[float] = []
	var bias: float = float(c.get("corner_bias", 0.0))
	for p: Vector2 in anchors:
		var corner: float = minf(absf(p.x) / _half.x, absf(p.y) / _half.y)
		weights.append(1.0 + bias * corner * corner * 4.0)
	var cr: Array = c.get("count", [6, 8])
	var want: int = mini(_rng.randi_range(int(cr[0]), int(cr[1])), anchors.size())
	var chosen: Array = []
	for n: int in want:
		var i: int = _weighted_index(weights)
		if i < 0: break
		weights[i] = 0.0
		chosen.append([anchors[i], _pick(templates)])
	# Two passes: every cluster's head (hero tree / bush) first so later rings never block it.
	for c2: Array in chosen: _grow_cluster(c2[0], c2[1], 0, 1)
	for c2: Array in chosen: _grow_cluster(c2[0], c2[1], 1, 999)


## Places layers [from, to) of `template` around `anchor`, spreading each layer's count evenly
## round the ring with angular jitter.
func _grow_cluster(anchor: Vector2, template: Dictionary, from: int, to: int) -> void:
	var layers: Array = template.get("layers", [])
	for li: int in range(from, mini(to, layers.size())):
		var layer: Dictionary = layers[li]
		var cr: Array = layer.get("count", [1, 1])
		var count: int = _rng.randi_range(int(cr[0]), int(cr[1]))
		var ring: Array = layer.get("ring", [0.0, 0.0])
		var start: float = _rng.randf() * TAU
		for n: int in count:
			for attempt: int in int(_rules.get("tries", 12)):
				var a: float = start + TAU * float(n) / maxf(1.0, count) + _rng.randf_range(-0.6, 0.6)
				var d: float = _rng.randf_range(float(ring[0]), float(ring[1]))
				if _try_place(anchor + Vector2(cos(a), sin(a)) * d, layer): break


## Sparse fill between clusters: Poisson samples kept with a probability that falls off with
## distance to the nearest placed prop (clumpy, not even), plus an outer spill band.
func _scatter_fill() -> void:
	var f: Dictionary = _rules.get("fill", {})
	var items: Array = f.get("items", [])
	if items.is_empty(): return
	var near_keep: float = float(f.get("near_keep", 0.8))
	var far_keep: float = float(f.get("far_keep", 0.2))
	var falloff: float = float(f.get("falloff", 1.0))
	var spill: float = float(f.get("spill_chance", 0.0))
	var band: Array = f.get("spill_band", [0.05, 0.22])
	for p: Vector2 in _poisson(float(f.get("spacing", 0.5)), func(q: Vector2) -> bool: return _inside(q, 0.0)):
		var item: Dictionary = _pick(items)
		var q: Vector2 = p
		if _rng.randf() < spill:
			# Push to the outer band on the dominant axis so it leans over the rounded rim.
			var inset: float = _rng.randf_range(float(band[0]), float(band[1]))
			if absf(q.x) / _half.x > absf(q.y) / _half.y: q.x = signf(q.x) * (_half.x - inset)
			else: q.y = signf(q.y) * (_half.y - inset)
		var keep: float = lerpf(far_keep, near_keep, exp(-_nearest(q) / maxf(falloff, 0.01)))
		if _rng.randf() < keep: _try_place(q, item)


## Validates `p` against exclusions and footprints, snaps it to the slab and records it.
func _try_place(p: Vector2, spec: Dictionary) -> bool:
	var kind: String = String(spec.get("kind", "tuft"))
	var tall: bool = bool(spec.get("tall", false))
	var cl: Dictionary = _rules.get("clearance", {})
	var sr: Array = spec.get("scale", [1.0, 1.0])
	var s: float = _rng.randf_range(float(sr[0]), float(sr[1]))
	var r: float = float(spec.get("radius", 0.2)) * s
	if not _inside(p, 0.0): return false
	if _ring_gap(p) < float(cl.get("board_tall" if tall else "board", 0.3)): return false
	for e: Array in _exclusions:
		if p.distance_to(e[0]) < float(e[1]) + r * 0.5: return false
	for o: Array in _placed:
		if p.distance_to(o[0]) < (r + float(o[1])) * 0.5: return false
	var hit: Dictionary = _snap(p)
	if hit.is_empty(): return false
	var ground: Dictionary = _rules.get("ground", {})
	var n: Vector3 = hit.normal
	if n.y < cos(deg_to_rad(float(ground.get("max_slope_deg", 60.0)))): return false
	_placed.append([p, r])
	var up: Vector3 = Vector3.UP.lerp(n, float(spec.get("align", ground.get("align", 0.8)))).normalized()
	var tilt: float = deg_to_rad(float(spec.get("tilt_deg", 0.0)))
	var basis := Basis(Quaternion(Vector3.UP, up))
	basis = basis * Basis(Vector3.UP, _rng.randf() * TAU) * Basis(Vector3.RIGHT, _rng.randf_range(-tilt, tilt))
	var yr: Array = spec.get("stretch", [0.9, 1.12])
	basis = basis.scaled_local(Vector3(s, s * _rng.randf_range(float(yr[0]), float(yr[1])), s))
	var pos: Vector3 = (hit.position as Vector3) - up * float(ground.get("sink", 0.02))
	var side := Vector3.ZERO
	if tall:
		var gx: float = absf(p.x) - _board_half.x
		var gz: float = absf(p.y) - _board_half.y
		side = Vector3(signf(p.x), 0, 0) if gx > gz else Vector3(0, 0, signf(p.y))
	var tint: String = String(spec.get("tint", "#FFFFFF"))
	var key: String = "%s|%s|%s" % [kind, tint, str(side)]
	if not _groups.has(key):
		_groups[key] = {"spec": spec, "side": side, "xf": [] as Array[Transform3D], "custom": [] as Array[Color]}
	(_groups[key].xf as Array[Transform3D]).append(Transform3D(basis, pos))
	(_groups[key].custom as Array[Color]).append(_tint(tint, float(spec.get("tint_jitter", 0.1))))
	return true


## Downward ray onto the slab top. Returns {position, normal} in world space, or {} on a miss.
func _snap(p: Vector2) -> Dictionary:
	var inv: Transform3D = _ground_xf.affine_inverse()
	var from: Vector3 = inv * Vector3(p.x, RAY_TOP, p.y)
	var dir: Vector3 = (inv.basis * Vector3.DOWN).normalized()
	var hit: Dictionary = _ground.intersect_ray(from, dir)
	if hit.is_empty(): return {}
	var n: Vector3 = (_ground_xf.basis * (hit.get("normal", Vector3.UP) as Vector3)).normalized()
	if n.y < 0.0: n = -n
	return {"position": _ground_xf * (hit.position as Vector3), "normal": n}


# ------------------------------------------------------------------ output

func _emit(world: Node3D) -> void:
	var tall_root := world.get_node_or_null(TALL_ROOT) as Node3D
	if tall_root == null:
		tall_root = Node3D.new()
		tall_root.name = TALL_ROOT
		world.add_child(tall_root)
	var low_root := Node3D.new()
	low_root.name = "PropScatter"
	world.add_child(low_root)
	var mm_min: int = int(_rules.get("multimesh_min", 3))
	for key: String in _groups:
		var g: Dictionary = _groups[key]
		var spec: Dictionary = g.spec
		var kind: String = String(spec.get("kind", "tuft"))
		var mesh: Mesh = _builder.prop_mesh(kind)
		var xfs: Array[Transform3D] = g.xf
		var mat: ShaderMaterial = _material(spec)
		var parent: Node3D = low_root if g.side == Vector3.ZERO else tall_root
		var nodes: Array[GeometryInstance3D] = []
		if xfs.size() < mm_min:
			# Hero props: individual meshes, tint via the material uniform.
			mat.set_shader_parameter(&"tint_color", Color(String(spec.get("tint", "#FFFFFF"))))
			for i: int in xfs.size():
				var mi := MeshInstance3D.new()
				mi.name = "Hero_%s_%d" % [kind, i]
				mi.mesh = mesh
				mi.transform = xfs[i]
				mi.material_override = mat
				nodes.append(mi)
		else:
			nodes.append(_multimesh("Scatter_%s_%s" % [kind, String(spec.get("tint", "base")).trim_prefix("#")], mesh, xfs, g.custom, mat))
		for node: GeometryInstance3D in nodes:
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(spec.get("shadow", false)) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			if g.side != Vector3.ZERO: node.set_meta(&"side", g.side)
			parent.add_child(node)


## Same parameter set as the builder's rim dressing so scatter and rim read as one material.
func _material(spec: Dictionary) -> ShaderMaterial:
	var env: Dictionary = WtBlockMaterials.look(_biome).get("env", {})
	var mat := ShaderMaterial.new()
	mat.shader = load(WtIslandBuilder.PROP_SHADER) as Shader
	mat.set_shader_parameter(&"glow", float(spec.get("glow", 0.0)))
	mat.set_shader_parameter(&"haze", 0.0)
	mat.set_shader_parameter(&"haze_color", Color(String(env.get("haze", "#D6E4F8"))))
	mat.set_shader_parameter(&"sway", float(spec.get("sway", 0.0)))
	mat.set_shader_parameter(&"motion", _builder.motion)
	mat.set_shader_parameter(&"rim_amount", 0.45)
	mat.set_shader_parameter(&"gloss", 0.25)
	mat.set_shader_parameter(&"shadow_tint", Color(String(_builder.preset().shadow_tint)))
	return mat


static func _multimesh(node_name: String, mesh: Mesh, xfs: Array[Transform3D], customs: Array[Color], mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	# Instance colours on (white): without them COLOR reaches the shader as zero on Compatibility.
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i: int in xfs.size():
		mm.set_instance_transform(i, xfs[i])
		mm.set_instance_color(i, Color.WHITE)
		mm.set_instance_custom_data(i, customs[i])
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = mat
	return node


# ------------------------------------------------------------------ geometry helpers

## Board grid and cast spots. Cast spots: pos = anchor * board size + offset (x, z), radius.
func _build_exclusions(board: Vector3i) -> void:
	_exclusions.clear()
	for e: Dictionary in _rules.get("exclusions", []):
		var a: Array = e.get("anchor", [0, 0])
		var o: Array = e.get("offset", [0, 0])
		_exclusions.append([Vector2(float(a[0]) * board.x + float(o[0]), float(a[1]) * board.z + float(o[1])), float(e.get("radius", 0.5))])


## Distance outside the board rectangle (<= 0 on the grid).
func _ring_gap(p: Vector2) -> float:
	return maxf(absf(p.x) - _board_half.x, absf(p.y) - _board_half.y)


## Inside the slab footprint (rounded corners included) shrunk by `inset`.
func _inside(p: Vector2, inset: float) -> bool:
	var edge: float = float(_rules.get("clearance", {}).get("edge_inset", 0.03)) + inset
	if absf(p.x) > _half.x - edge or absf(p.y) > _half.y - edge: return false
	var rr: float = WtIslandBuilder.SLAB_RADIUS
	var cx: float = maxf(0.0, absf(p.x) - (_half.x - rr))
	var cz: float = maxf(0.0, absf(p.y) - (_half.y - rr))
	return cx * cx + cz * cz <= (rr - edge) * (rr - edge)


func _nearest(p: Vector2) -> float:
	var best: float = INF
	for o: Array in _placed: best = minf(best, p.distance_to(o[0]))
	return best


## Bridson Poisson-disk sampling over the slab rectangle (seeded), filtered by `accept`.
func _poisson(radius: float, accept: Callable) -> PackedVector2Array:
	var cell: float = radius / sqrt(2.0)
	var origin := -_half
	var gw: int = int(ceil(_half.x * 2.0 / cell)) + 1
	var gh: int = int(ceil(_half.y * 2.0 / cell)) + 1
	var grid: PackedInt32Array = []
	grid.resize(gw * gh)
	grid.fill(-1)
	var all: PackedVector2Array = []
	var active: Array[int] = []
	var seed_p := Vector2(_rng.randf_range(-_half.x, _half.x), _rng.randf_range(-_half.y, _half.y))
	all.append(seed_p)
	active.append(0)
	grid[_gi(seed_p, origin, cell, gw)] = 0
	while not active.is_empty():
		var ai: int = _rng.randi_range(0, active.size() - 1)
		var base: Vector2 = all[active[ai]]
		var found: bool = false
		for k: int in 24:
			var a: float = _rng.randf() * TAU
			var q: Vector2 = base + Vector2(cos(a), sin(a)) * _rng.randf_range(radius, radius * 2.0)
			if absf(q.x) > _half.x or absf(q.y) > _half.y: continue
			var gx: int = int((q.x - origin.x) / cell)
			var gy: int = int((q.y - origin.y) / cell)
			var ok: bool = true
			for yy: int in range(maxi(gy - 2, 0), mini(gy + 3, gh)):
				for xx: int in range(maxi(gx - 2, 0), mini(gx + 3, gw)):
					var j: int = grid[yy * gw + xx]
					if j >= 0 and all[j].distance_squared_to(q) < radius * radius: ok = false
			if not ok: continue
			grid[gy * gw + gx] = all.size()
			active.append(all.size())
			all.append(q)
			found = true
			break
		if not found: active.remove_at(ai)
	var out: PackedVector2Array = []
	for p: Vector2 in all:
		if accept.call(p): out.append(p)
	return out


static func _gi(p: Vector2, origin: Vector2, cell: float, gw: int) -> int:
	return int((p.y - origin.y) / cell) * gw + int((p.x - origin.x) / cell)


func _weighted_index(weights: Array[float]) -> int:
	var total: float = 0.0
	for w: float in weights: total += w
	if total <= 0.0: return -1
	var roll: float = _rng.randf() * total
	for i: int in weights.size():
		roll -= weights[i]
		if roll <= 0.0 and weights[i] > 0.0: return i
	return weights.size() - 1


func _pick(items: Array) -> Dictionary:
	var w: Array[float] = []
	for it: Dictionary in items: w.append(float(it.get("weight", 1.0)))
	return items[maxi(_weighted_index(w), 0)]


## Linear per-instance tint with value jitter (INSTANCE_CUSTOM, .a = 1 marks MultiMesh tint).
func _tint(hex: String, jitter: float) -> Color:
	var c: Color = Color(hex).srgb_to_linear()
	var j: float = _rng.randf_range(1.0 - jitter, 1.0 + jitter * 0.6)
	return Color(c.r * j, c.g * j, c.b * j, 1.0)
