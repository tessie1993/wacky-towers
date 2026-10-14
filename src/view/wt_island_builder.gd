class_name WtIslandBuilder extends RefCounted
## Builds the in-level environment (ref 15, design/art/style-techniques.md §2 and §5):
## a thick floating chunk (rounded top slab with the biome cap + 2-3 chunky rock strata tapering
## to a point, with hanging roots/icicles/rocks), a square stone-tile board slightly inset into
## the slab, biome rim dressing that never covers the grid, 3-6 distant floating islands with
## landmarks hazed by their own shaders, the painted canvas sky, the AgX environment preset and
## the camera-relative 3-light rig. Geometry comes from the env v3 kit GLBs when present
## (res://assets/models/env_v3/<family>/<kind>.glb, built by tools/asset-pipeline/build_env_v3.py:
## sculpted rock blocks, rim props, hanging roots, distant islands) and falls back to the
## procedural primitives below for any kind the kit does not ship, so every biome still builds.
## Look data: res://assets/data/biome_looks.json, key `env` per biome (schema in `env_notes`).
## Draw calls (8x8 board): slab 1, strata 3, tiles 1, grout 1, one MultiMesh per rim kind and
## per side for tall kinds (~8-14), hanging 1-2, far islands ~4 each (3-6 islands).

## Island ring around the board, in cells (cookbook §5.1: about 1.2 each side).
const RING := 1.25
## Slab top sits just under the tile tops so the board reads slightly inset (tiles proud by 0.06).
const SLAB_TOP := -0.06
const SLAB_DEPTH := 0.9
const SLAB_RADIUS := 0.35
const TILE_SIZE := Vector3(0.96, 0.22, 0.96)
const TILE_RADIUS := 0.07
## Board ledge stones (ref 15 raised stone rim): unit stone size (length, height, width),
## corner radius and how far the stone top stands above the tile tops (tile top = 0).
const LEDGE_SIZE := Vector3(0.6, 0.28, 0.32)
const LEDGE_RADIUS := 0.07
const LEDGE_RISE := 0.1
## Rim dressing keeps this far from the board edge (low props) so nothing overlaps a tile.
const LOW_CLEAR := 0.3
const TALL_CLEAR := 0.5
## Strata bands: [top radius, bottom radius (fractions of the half extent), height].
const DEFAULT_STRATA := [[1.0, 0.96, 1.2], [0.93, 0.83, 1.2], [0.81, 0.34, 2.1]]
## Kinds taller than ~0.3: placed only on the sides facing away from the camera (update_facing).
const TALL_KINDS := ["bush", "shrub", "tree", "tree_white", "pine", "pillar", "pillar_broken", "lollipop", "coral", "crystal"]
## Distant island layout: [x (fraction of half width), y (fraction of half height above target),
## scale, depth behind the board]. Index order = env.far order.
const FAR_LAYOUT := [[-0.68, 0.62, 0.78, 34.0], [0.72, 0.5, 0.85, 30.0], [-0.12, 0.84, 0.5, 44.0],
	[-0.98, 0.12, 0.7, 26.0], [0.98, -0.05, 0.66, 26.0], [0.42, 0.93, 0.42, 46.0]]
## Reference ortho size the far layout was composed at (portrait 8x8 board).
const FAR_REF_SIZE := 24.0
const ISLAND_SHADER := "res://src/view/shaders/spatial_env_island.gdshader"
const ROCK_SHADER := "res://src/view/shaders/spatial_env_rock.gdshader"
const PROP_SHADER := "res://src/view/shaders/spatial_env_prop.gdshader"
const TILE_SHADER := "res://src/view/shaders/spatial_env_tile.gdshader"
const FALL_SHADER := "res://src/view/shaders/spatial_env_fall.gdshader"
const SKY_SHADER := "res://src/view/shaders/canvas_env_sky.gdshader"
## Env v3 kit (Blender GLBs, one vertex-colour mesh each, same colour contract as the shader).
const KIT_DIR := "res://assets/models/env_v3/"
## Biome family -> family whose kit fills the gaps (generic kinds like tuft or root).
const KIT_FALLBACK := {"ice": "meadow"}
## Sculpted strata block variants looked up as rock_block_01..N.
const KIT_ROCK_VARIANTS := 10
## Cookbook §2.1/§2.2 meadow preset; biomes override any key in env.light.
const DEFAULT_PRESET := {"key": "#FFF0D6", "key_energy": 0.9, "fill": "#B8C4FF", "fill_energy": 0.2,
	"back": "#FFE0A8", "back_energy": 0.3, "ambient": "#C9C3E6", "ambient_energy": 0.42,
	"saturation": 1.28, "contrast": 1.06, "brightness": 1.02, "shadow_tint": "#6B5C9E"}

static var _mesh_cache: Dictionary = {}

## Shader animation scale (0 = reduced motion).
var motion: float = 1.0
var _look: Dictionary
var _env: Dictionary
var _biome: StringName
var _rng := RandomNumberGenerator.new()


func _init(biome: StringName) -> void:
	_biome = biome
	_look = WtBlockMaterials.look(biome)
	_env = _look.get("env", {})
	_rng.seed = hash(String(biome))


## Half extents (x, z) of the island top slab for a board footprint.
static func half_extents(board: Vector3i) -> Vector2:
	return Vector2(board.x * 0.5 + RING, board.z * 0.5 + RING)


## Depth from the slab top to the tip of the lowest stratum.
static func underside_depth(_half: Vector2) -> float:
	var total: float = SLAB_DEPTH
	for band: Array in DEFAULT_STRATA: total += float(band[2]) - 0.15
	return total + float(DEFAULT_STRATA[DEFAULT_STRATA.size() - 1][2]) * 0.3


# ------------------------------------------------------------------ preset, rig, sky

## Resolved light/grade preset for this biome (DEFAULT_PRESET merged with env.light).
func preset() -> Dictionary:
	var p: Dictionary = DEFAULT_PRESET.duplicate()
	p.merge(_env.get("light", {}), true)
	return p


## The shared environment preset (cookbook §2.1): canvas backdrop, flat lilac ambient, AgX,
## soft-light glow for emissives only, grading, and NO global fog.
func make_environment() -> Environment:
	var p: Dictionary = preset()
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.background_canvas_max_layer = -1
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(String(p.ambient))
	env.ambient_light_energy = float(p.ambient_energy)
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_strength = 1.0
	env.glow_bloom = 0.04
	env.glow_hdr_threshold = 0.95
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	var levels: Array[float] = [0.0, 0.0, 1.0, 1.0, 0.6, 0.0, 0.0]
	for i: int in levels.size(): env.set_glow_level(i, levels[i])
	env.fog_enabled = false
	env.adjustment_enabled = true
	env.adjustment_saturation = float(p.saturation)
	env.adjustment_contrast = float(p.contrast)
	env.adjustment_brightness = float(p.brightness)
	return env


## Adds the 3-light rig (cookbook §2.2) under `parent`: [key, fill, back]. Angles follow the
## camera yaw (degrees, atan2(cam.x - target.x, cam.z - target.z)) so light reads upper-left.
func add_light_rig(parent: Node, cam_yaw_deg: float) -> Array[DirectionalLight3D]:
	var p: Dictionary = preset()
	var rig: Array[DirectionalLight3D] = []
	for spec: Array in [["Key", "key"], ["Fill", "fill"], ["Back", "back"]]:
		var l := DirectionalLight3D.new()
		l.name = "Env" + String(spec[0])
		l.light_color = Color(String(p[spec[1]]))
		l.light_energy = float(p[String(spec[1]) + "_energy"])
		rig.append(l)
		parent.add_child(l)
	var key: DirectionalLight3D = rig[0]
	key.shadow_enabled = true
	key.shadow_opacity = float(p.get("shadow_opacity", 0.86))
	key.shadow_blur = 2.2
	key.shadow_bias = 0.08
	key.shadow_normal_bias = 2.5
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 40.0
	key.light_angular_distance = 1.5
	rig[1].light_specular = 0.0
	orient_rig(rig, cam_yaw_deg)
	return rig


## Re-aims the rig for a new camera yaw (degrees). Biomes never change the angles.
static func orient_rig(rig: Array[DirectionalLight3D], cam_yaw_deg: float) -> void:
	var angles: Array[Vector3] = [Vector3(-50, cam_yaw_deg - 75.0, 0), Vector3(-20, cam_yaw_deg + 105.0, 0), Vector3(-20, cam_yaw_deg + 190.0, 0)]
	for i: int in mini(rig.size(), 3):
		if is_instance_valid(rig[i]): rig[i].rotation_degrees = angles[i]


## Paints the sky behind the 3D world: a CanvasLayer (-10) drawn as the BG_CANVAS background.
func build_sky(owner: Node, environment: Environment) -> CanvasLayer:
	environment.background_mode = Environment.BG_CANVAS
	environment.background_canvas_max_layer = -1
	var sky: Array = _look.get("sky", ["#4F94E6", "#CFE6FB", "#FFF4E6"])
	var spec: Dictionary = _env.get("sky", {})
	var layer := CanvasLayer.new()
	layer.name = "SkyBackdrop"
	layer.layer = -10
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load(SKY_SHADER) as Shader
	mat.set_shader_parameter(&"top", Color(String(sky[0])))
	mat.set_shader_parameter(&"horizon", Color(String(sky[1])))
	mat.set_shader_parameter(&"low", Color(String(sky[2])))
	for key: String in ["cloud", "cloud_shade", "mountains", "nebula_a", "nebula_b"]:
		if spec.has(key): mat.set_shader_parameter(StringName(key), Color(String(spec[key])))
	for key: String in ["mesa_top", "mesa_rock", "peak_rock", "peak_snow", "castle_color", "castle_roof"]:
		if spec.has(key): mat.set_shader_parameter(StringName(key), Color(String(spec[key])))
	for key: String in ["cloud_amount", "mountain_amount", "stars", "nebula", "sun", "sea_line", "mesa_amount", "mesa_falls", "cloud_bank", "mesa_round", "peaks", "castle"]:
		if spec.has(key): mat.set_shader_parameter(StringName(key), float(spec[key]))
	if spec.has("castle_pos"):
		var cp: Array = spec["castle_pos"]
		mat.set_shader_parameter(&"castle_pos", Vector2(float(cp[0]), float(cp[1])))
	mat.set_shader_parameter(&"motion", motion)
	rect.material = mat
	layer.add_child(rect)
	owner.add_child(layer)
	return layer


# ------------------------------------------------------------------ the island

## Adds the slab, strata, hanging dressing, grout plate and tile grid under `parent`.
## `active(x, z)` filters inactive cells (no tile drawn).
func build_island(parent: Node3D, board: Vector3i, active: Callable) -> void:
	var half: Vector2 = half_extents(board)
	var slab := MeshInstance3D.new()
	slab.name = "FloatingIsland"
	slab.mesh = rounded_box(Vector3(half.x * 2.0, SLAB_DEPTH, half.y * 2.0), SLAB_RADIUS, 10)
	slab.position = Vector3(0, SLAB_TOP - SLAB_DEPTH * 0.5, 0)
	slab.material_override = _slab_material(Vector3(half.x, SLAB_DEPTH * 0.5, half.y), Vector2(board.x * 0.5, board.z * 0.5), 0.0)
	parent.add_child(slab)
	var bottom: float = _build_strata(parent, half, 0.0, 1.0, _rng)
	_build_hanging(parent, half, bottom)
	_build_tiles(parent, board, active)


## Scatters the biome rim dressing in the ring between the board and the island edge.
## Low kinds go everywhere (kept LOW_CLEAR off the grid); tall kinds are grouped by side so
## update_facing() can hide the sides facing the camera (they would cover the grid).
func build_dressing(parent: Node3D, board: Vector3i) -> void:
	var specs: Array = _env.get("rim", [])
	if specs.is_empty(): return
	var half: Vector2 = half_extents(board)
	var b := Vector2(board.x * 0.5, board.z * 0.5)
	var ring_area: float = 4.0 * half.x * half.y - (board.x + 2.0 * LOW_CLEAR) * (board.z + 2.0 * LOW_CLEAR)
	var count: int = int(ring_area * float(_env.get("rim_density", 3.0)))
	var groups: Dictionary = {}
	var placed: Array[Vector3] = []
	var tall_root := Node3D.new()
	tall_root.name = "TallDressing"
	for i: int in count * 4:
		if placed.size() >= count: break
		var spec: Dictionary = _pick(specs)
		var kind: String = String(spec.get("kind", "rock"))
		var tall: bool = bool(spec.get("tall", kind in TALL_KINDS))
		var p := Vector3(_rng.randf_range(-half.x + 0.05, half.x - 0.05), SLAB_TOP - 0.01, _rng.randf_range(-half.y + 0.05, half.y - 0.05))
		var sr: Array = spec.get("scale", [0.8, 1.2])
		var s: float = _rng.randf_range(float(sr[0]), float(sr[1]))
		var edge: bool = bool(spec.get("edge", false))
		if edge:
			# Spill over the rim: snap to the slab edge (dominant axis) so the prop overhangs.
			if absf(p.x) / half.x > absf(p.z) / half.y: p.x = signf(p.x) * (half.x - 0.06)
			else: p.z = signf(p.z) * (half.y - 0.06)
		var gx: float = absf(p.x) - b.x
		var gz: float = absf(p.z) - b.y
		if maxf(gx, gz) < (TALL_CLEAR if tall else LOW_CLEAR + 0.12 * s): continue
		var cx: float = maxf(0.0, absf(p.x) - (half.x - SLAB_RADIUS))
		var cz: float = maxf(0.0, absf(p.z) - (half.y - SLAB_RADIUS))
		if cx * cx + cz * cz > SLAB_RADIUS * SLAB_RADIUS: continue
		if _near(p, placed, float(spec.get("spacing", 0.34))): continue
		placed.append(p)
		var side := Vector3.ZERO
		if tall: side = Vector3(signf(p.x), 0, 0) if gx > gz else Vector3(0, 0, signf(p.z))
		var key: String = kind + "|" + String(spec.get("tint", "")) + "|" + str(side)
		if not groups.has(key): groups[key] = {"spec": spec, "side": side, "xf": [] as Array[Transform3D], "custom": [] as Array[Color]}
		var basis := Basis(Vector3.UP, _rng.randf() * TAU).scaled_local(Vector3(s, s * _rng.randf_range(0.9, 1.15), s))
		if edge:
			var out := Vector3(signf(p.x), 0, 0) if gx > gz else Vector3(0, 0, signf(p.z))
			basis = Basis(out.cross(Vector3.UP).normalized(), -0.35) * basis
		(groups[key].xf as Array[Transform3D]).append(Transform3D(basis, p))
		(groups[key].custom as Array[Color]).append(_instance_tint(spec))
	for key: String in groups:
		var g: Dictionary = groups[key]
		var spec: Dictionary = g.spec
		var kind: String = String(spec.get("kind", "rock"))
		var mat := _prop_material(float(spec.get("glow", 0.0)), 0.0, 0.03 if kind in ["tree", "tree_white", "shrub", "pine"] else 0.0)
		var node := _mmi("Rim_" + kind, prop_mesh(kind), g.xf, g.custom, mat)
		if g.side == Vector3.ZERO:
			parent.add_child(node)
		else:
			node.set_meta(&"side", g.side)
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			tall_root.add_child(node)
	parent.add_child(tall_root)


## Kept for WtStage compatibility: the old large back-of-board props are now part of the rim
## dressing (tall kinds, culled by side) and the distant islands.
func build_backdrop(_parent: Node3D, _board: Vector3i) -> void:
	pass


## Shows only the tall dressing on the sides facing away from the camera (yaw in degrees), so
## trees and pillars frame the board without ever covering it.
static func update_facing(world: Node, cam_yaw_deg: float) -> void:
	if world == null: return
	var tall: Node = world.get_node_or_null("TallDressing")
	if tall == null: return
	var yaw: float = deg_to_rad(cam_yaw_deg)
	var to_cam := Vector3(sin(yaw), 0, cos(yaw))
	for child: Node in tall.get_children():
		if child is Node3D and child.has_meta(&"side"):
			(child as Node3D).visible = (child.get_meta(&"side") as Vector3).dot(to_cam) < 0.3


# ------------------------------------------------------------------ distant islands

## Builds 3-6 distant floating islands with landmarks (env.far). Returns their root; call
## layout_far() whenever the camera moves or resizes so they stay composed behind the board.
func build_far(parent: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "FarIslands"
	var kinds: Array = _env.get("far", [])
	var haze_c: Color = Color(String(_env.get("haze", _look.get("sky", ["", "#D6E4F8"])[1])))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(_biome) + "far")
	for i: int in mini(kinds.size(), FAR_LAYOUT.size()):
		var layout: Array = FAR_LAYOUT[i]
		var haze: float = clampf((float(layout[3]) - 28.0) / 18.0 * 0.4, 0.04, 0.4)
		var isl := _far_island(String(kinds[i]), haze, haze_c, rng)
		isl.set_meta(&"far_layout", layout)
		isl.rotation.y = rng.randf_range(-0.5, 0.5)
		root.add_child(isl)
	parent.add_child(root)
	return root


## Places the distant islands for an orthographic camera looking at `target` from yaw/elevation
## (degrees) with ortho `size` and viewport `aspect` (w/h): fixed screen composition, real depth.
static func layout_far(root: Node3D, target: Vector3, cam_yaw_deg: float, elevation_deg: float, size: float, aspect: float) -> void:
	if root == null: return
	root.position = target
	root.rotation = Vector3(0, deg_to_rad(cam_yaw_deg), 0)
	var e: float = deg_to_rad(elevation_deg)
	var k: float = size / FAR_REF_SIZE
	for child: Node in root.get_children():
		if not child.has_meta(&"far_layout"): continue
		var l: Array = child.get_meta(&"far_layout")
		var depth: float = float(l[3]) * k
		var sx: float = float(l[0]) * size * aspect * 0.5
		var sy: float = float(l[1]) * size * 0.5
		var n3 := child as Node3D
		n3.position = Vector3(sx, (sy - depth * sin(e)) / cos(e), -depth)
		n3.scale = Vector3.ONE * float(l[2]) * k


func _far_island(kind: String, haze: float, haze_c: Color, rng: RandomNumberGenerator) -> Node3D:
	var node := Node3D.new()
	node.name = "Far_" + kind
	if kind == "planet":
		node.add_child(_far_mesh(_landmark_mesh("planet"), haze * 0.6, haze_c))
		return node
	var half := Vector3(1.6, 0.25, 1.35)
	var kit: Mesh = kit_mesh("far_" + kind)
	if kit != null:
		# Env v3: the whole island (cap, sculpted strata, landmark) is one baked GLB.
		var whole := _far_mesh(kit, haze, haze_c)
		whole.name = "Island"
		node.add_child(whole)
		if kind == "waterfall" or kind == "volcano_fall": node.add_child(_far_fall(half, haze, haze_c, 0.3))
		return node
	var top := MeshInstance3D.new()
	top.mesh = rounded_box(half * 2.0, 0.25, 6)
	top.material_override = _slab_material(half, Vector2.ZERO, haze)
	(top.material_override as ShaderMaterial).set_shader_parameter(&"radius", 0.25)
	(top.material_override as ShaderMaterial).set_shader_parameter(&"seed", rng.randf() * 10.0)
	top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_child(top)
	var bands: Array = [[1.0, 0.88, 0.7], [0.86, 0.22, 1.7]]
	var y: float = -0.2
	for i: int in bands.size():
		var b: Array = bands[i]
		var m := MeshInstance3D.new()
		m.mesh = chunk_mesh(float(b[0]), float(b[1]), float(b[2]), 16, 0.1, rng)
		m.scale = Vector3(half.x, 1.0, half.z)
		m.position = Vector3(0, y, 0)
		m.material_override = _rock_material(i, haze, haze_c, 0.5)
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.add_child(m)
		y -= float(b[2]) - 0.1
	var lm := _far_mesh(_landmark_mesh(kind), haze, haze_c)
	lm.position = Vector3(0, half.y, 0)
	node.add_child(lm)
	if kind == "waterfall" or kind == "volcano_fall": node.add_child(_far_fall(half, haze, haze_c, 0.02))
	return node


## Waterfall ribbon down the front of a distant island (`out` pushes it clear of the strata).
func _far_fall(half: Vector3, haze: float, haze_c: Color, out: float) -> MeshInstance3D:
	if true:
		var falls: Dictionary = _env.get("falls", {})
		var q := QuadMesh.new()
		q.size = Vector2(0.55, 3.4)
		var fall := MeshInstance3D.new()
		fall.mesh = q
		fall.position = Vector3(0.45, half.y - 1.7, half.z + out)
		var fm := ShaderMaterial.new()
		fm.shader = load(FALL_SHADER) as Shader
		for key: String in ["deep", "light", "foam"]:
			if falls.has(key): fm.set_shader_parameter(StringName(key), Color(String(falls[key])))
		fm.set_shader_parameter(&"emission", float(falls.get("emission", 0.0)))
		fm.set_shader_parameter(&"motion", motion)
		fm.set_shader_parameter(&"haze", haze * 0.8)
		fm.set_shader_parameter(&"haze_color", haze_c)
		fall.material_override = fm
		fall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		return fall
	return null


func _far_mesh(mesh: Mesh, haze: float, haze_c: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := _prop_material(0.0, haze, 0.0)
	mat.set_shader_parameter(&"haze_color", haze_c)
	mat.set_shader_parameter(&"tint_color", Color(String(_env.get("far_cap", _cap().get("color", "#6AA84A")))))
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi


# ------------------------------------------------------------------ strata, hanging, tiles

## Adds the strata under a slab of half extent `half`; returns the tip y. Each band is a dark
## faceted core (reads as the gaps) wrapped in rows of chunky rounded rock blocks that step in
## and out (cookbook §5.1 production upgrade), one MultiMesh per band.
func _build_strata(parent: Node3D, half: Vector2, haze: float, scale_y: float, rng: RandomNumberGenerator) -> float:
	var bands: Array = _env.get("strata_shape", DEFAULT_STRATA)
	var y: float = SLAB_TOP - SLAB_DEPTH + 0.15
	var block: Mesh = _cached("rock_block", func() -> Mesh: return rounded_box(Vector3.ONE, 0.14, 3))
	var kit_blocks: Array[Mesh] = kit_rock_blocks()
	for i: int in bands.size():
		var b: Array = bands[i]
		var h: float = float(b[2]) * scale_y
		var core := MeshInstance3D.new()
		core.name = "Stratum%d" % i
		core.mesh = chunk_mesh(float(b[0]) * 0.94, float(b[1]) * 0.9, h, 24, 0.035 + i * 0.015, rng)
		core.scale = Vector3(half.x, 1.0, half.y)
		core.position = Vector3(0, y, 0)
		core.material_override = _rock_material(i, haze, Color.WHITE, 1.0)
		(core.material_override as ShaderMaterial).set_shader_parameter(&"seam", 0.0)
		var cc: Color = (core.material_override as ShaderMaterial).get_shader_parameter(&"body_color")
		(core.material_override as ShaderMaterial).set_shader_parameter(&"body_color", cc.darkened(0.45))
		core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(core)
		# Rows of blocks: radius follows the band taper, each row offset and jittered.
		var rows: int = maxi(1, int(round(h / 0.6)))
		var row_h: float = h / rows
		var xf: Array[Transform3D] = []
		var cols: Array[Color] = []
		for r: int in rows:
			var t: float = (r + 0.5) / rows
			var rad: float = lerpf(float(b[0]), float(b[1]), t)
			var yy: float = y - (r + 0.5) * row_h
			var perim: float = 2.0 * PI * rad * (half.x + half.y) * 0.5 * 1.1
			var n: int = maxi(6, int(perim / rng.randf_range(1.0, 1.25)))
			var phase: float = rng.randf()
			for k: int in n:
				var a: float = TAU * (k + phase + rng.randf_range(-0.12, 0.12)) / n
				var c: float = cos(a)
				var sn: float = sin(a)
				var sq: float = 1.0 / pow(pow(absf(c), 4.0) + pow(absf(sn), 4.0), 0.25)
				var px: float = c * sq * rad * half.x
				var pz: float = sn * sq * rad * half.y
				var nrm := Vector3(signf(px) * pow(absf(px) / half.x, 3.0), 0, signf(pz) * pow(absf(pz) / half.y, 3.0)).normalized()
				var out: float = rng.randf_range(-0.1, 0.14)
				var w: float = perim / n * rng.randf_range(0.82, 0.98)
				var bh: float = row_h * rng.randf_range(0.86, 1.0)
				var basis := Basis(nrm.cross(Vector3.UP).normalized(), Vector3.UP, nrm)
				basis = basis * Basis.from_euler(Vector3(rng.randf_range(-0.06, 0.06), rng.randf_range(-0.08, 0.08), rng.randf_range(-0.05, 0.05)))
				var d: float = rng.randf_range(0.55, 0.8)
				var pos := Vector3(px, yy + rng.randf_range(-0.04, 0.04), pz) + nrm * (out - d * 0.35)
				xf.append(Transform3D(basis.scaled_local(Vector3(w, bh, d)), pos))
				var v: float = rng.randf_range(0.82, 1.08)
				cols.append(Color(v, v, v, 1.0))
		var blocks: GeometryInstance3D
		if not kit_blocks.is_empty():
			# Sculpted kit blocks (env v3): one merged static mesh per band, variant per block.
			# Slightly oversized so neighbours overlap into crevices instead of gaps.
			var variant: Array[int] = []
			for k: int in xf.size():
				variant.append(rng.randi() % kit_blocks.size())
				xf[k] = Transform3D(xf[k].basis.scaled_local(Vector3(1.18, 1.12, 1.05)), xf[k].origin)
			var mi := MeshInstance3D.new()
			mi.mesh = merge_instances(kit_blocks, variant, xf, cols)
			blocks = mi
		else:
			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.use_colors = true
			mm.mesh = block
			mm.instance_count = xf.size()
			for k: int in xf.size():
				mm.set_instance_transform(k, xf[k])
				mm.set_instance_color(k, cols[k])
			var mmi := MultiMeshInstance3D.new()
			mmi.multimesh = mm
			blocks = mmi
		blocks.name = "StratumBlocks%d" % i
		blocks.material_override = _rock_material(i, haze, Color.WHITE, 1.0)
		# Painted seams belong to the plain rounded blocks; sculpted blocks carry their own.
		(blocks.material_override as ShaderMaterial).set_shader_parameter(&"seam", 0.25 if kit_blocks.is_empty() else 0.0)
		blocks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(blocks)
		y -= h - 0.15
	return y + 0.15 - float(bands[bands.size() - 1][2]) * scale_y * 0.3


func _build_hanging(parent: Node3D, half: Vector2, tip_y: float) -> void:
	var specs: Array = _env.get("hang", [])
	var bands: Array = _env.get("strata_shape", DEFAULT_STRATA)
	for spec: Dictionary in specs:
		var kind: String = String(spec.get("kind", "root"))
		var xf: Array[Transform3D] = []
		var custom: Array[Color] = []
		# Ledges: under the slab rim and under each band bottom (stepping inward).
		var ledges: Array = [[SLAB_TOP - SLAB_DEPTH + 0.05, 0.97]]
		var y: float = SLAB_TOP - SLAB_DEPTH + 0.15
		for b: Array in bands:
			y -= float(b[2]) - 0.15
			ledges.append([y + 0.25, float(b[1]) * 0.97])
		ledges.pop_back()
		var per: int = int(spec.get("count", 22))
		for li: int in ledges.size():
			var ledge: Array = ledges[li]
			var n: int = per if li == 0 else per / 2
			for k: int in n:
				var a: float = TAU * (k + _rng.randf() * 0.7) / n
				var sq: float = 1.0 / pow(pow(absf(cos(a)), 4.0) + pow(absf(sin(a)), 4.0), 0.25)
				var r: float = float(ledge[1]) * sq * _rng.randf_range(0.9, 0.99)
				var p := Vector3(cos(a) * r * half.x, float(ledge[0]), sin(a) * r * half.y)
				var s: float = _rng.randf_range(0.6, 1.25) * float(spec.get("size", 1.0))
				xf.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled_local(Vector3(s, s * _rng.randf_range(0.8, 1.4), s)), p))
				custom.append(_instance_tint(spec))
		# A cluster at the tip.
		for k: int in 3:
			var s: float = _rng.randf_range(0.8, 1.3) * float(spec.get("size", 1.0))
			xf.append(Transform3D(Basis(Vector3.UP, k * 2.1).scaled_local(Vector3.ONE * s), Vector3(_rng.randf_range(-0.3, 0.3), tip_y + 0.5, _rng.randf_range(-0.3, 0.3))))
			custom.append(_instance_tint(spec))
		parent.add_child(_mmi("Hang_" + kind, prop_mesh(kind), xf, custom, _prop_material(float(spec.get("glow", 0.0)), 0.0, 0.0)))


func _build_tiles(parent: Node3D, board: Vector3i, active: Callable) -> void:
	var tile: Dictionary = _env.get("tile", {})
	var base: Color = Color(String(tile.get("color", "#BDB2A2")))
	var grout := MeshInstance3D.new()
	grout.name = "BoardGrout"
	var gm := BoxMesh.new()
	gm.size = Vector3(board.x + 0.08, 0.04, board.z + 0.08)
	grout.mesh = gm
	grout.position = Vector3(0, SLAB_TOP + 0.005, 0)
	grout.material_override = _rock_material(0, 0.0, Color.WHITE, 0.0)
	var gcol: Color = Color(String(tile.get("grout", "#6B5F55")))
	(grout.material_override as ShaderMaterial).set_shader_parameter(&"body_color", gcol)
	(grout.material_override as ShaderMaterial).set_shader_parameter(&"body_dark", gcol.darkened(0.2))
	(grout.material_override as ShaderMaterial).set_shader_parameter(&"seam", 0.0)
	# The grout is never emissive: a glowing grid would compete with the pieces.
	(grout.material_override as ShaderMaterial).set_shader_parameter(&"glow", 0.0)
	parent.add_child(grout)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = _cached("tile", func() -> Mesh: return rounded_box(TILE_SIZE, TILE_RADIUS, 4))
	var cells: Array[Vector3] = []
	for z: int in board.z:
		for x: int in board.x:
			if active.call(x, z): cells.append(Vector3(x - board.x * 0.5 + 0.5, -TILE_SIZE.y * 0.5, z - board.z * 0.5 + 0.5))
	mm.instance_count = cells.size()
	var jitter: float = float(tile.get("jitter", 0.04))
	# Per-tile colour variation (ref 15): value jitter plus a drift toward `tile.alt`.
	var alt: Color = Color(String(tile.get("alt", tile.get("color", "#BDB2A2"))))
	for i: int in cells.size():
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, cells[i]))
		var v: float = _rng.randf_range(-jitter, jitter)
		var c: Color = base.lerp(alt, _rng.randf() * 0.6)
		mm.set_instance_color(i, c.lightened(v) if v > 0.0 else c.darkened(-v))
	var node := MultiMeshInstance3D.new()
	node.name = "BoardTiles"
	node.multimesh = mm
	var mat := ShaderMaterial.new()
	mat.shader = load(TILE_SHADER) as Shader
	mat.set_shader_parameter(&"tile_half", TILE_SIZE * 0.5)
	mat.set_shader_parameter(&"tile_radius", TILE_RADIUS)
	mat.set_shader_parameter(&"shadow_tint", Color(String(preset().shadow_tint)))
	mat.set_shader_parameter(&"gloss", 0.2)
	if tile.has("edge_glow"):
		mat.set_shader_parameter(&"edge_glow_color", Color(String(tile.edge_glow)))
		mat.set_shader_parameter(&"edge_glow", 1.4)
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	_build_ledge(parent, board, tile)


## Chunky raised stone ledge around the tile grid (ref 15): one MultiMesh of rounded stones,
## LEDGE_SIZE.z wide, standing LEDGE_RISE proud of the tiles, per-stone value jitter. Uses the
## tile shader so the board reads as one material. 1 draw call. Off with env.tile.ledge = "".
func _build_ledge(parent: Node3D, board: Vector3i, tile: Dictionary) -> void:
	var hex: String = String(tile.get("ledge", Color(String(tile.get("color", "#BDB2A2"))).darkened(0.12).to_html(false)))
	if hex.is_empty(): return
	var base: Color = Color(hex)
	var xfs: Array[Transform3D] = []
	var cols: Array[Color] = []
	var w: float = LEDGE_SIZE.z
	var y: float = LEDGE_RISE - LEDGE_SIZE.y * 0.5
	for side: int in 4:
		var along_x: bool = side < 2
		var length: float = float(board.x if along_x else board.z)
		var extra: float = w if along_x else 0.0
		var off: float = (float(board.z if along_x else board.x) * 0.5 + w * 0.5 + 0.01) * (1.0 if side % 2 == 0 else -1.0)
		var t: float = -length * 0.5 - extra
		while t < length * 0.5 + extra - 0.12:
			var seg: float = minf(_rng.randf_range(0.5, 0.78), length * 0.5 + extra - t)
			var mid: float = t + seg * 0.5
			var pos := Vector3(mid, y + _rng.randf_range(-0.012, 0.012), off) if along_x else Vector3(off, y + _rng.randf_range(-0.012, 0.012), mid)
			var yaw: float = (0.0 if along_x else PI * 0.5) + _rng.randf_range(-0.035, 0.035)
			var basis := Basis(Vector3.UP, yaw).scaled_local(Vector3((seg - 0.035) / LEDGE_SIZE.x, 1.0, 1.0))
			xfs.append(Transform3D(basis, pos))
			var v: float = _rng.randf_range(-0.07, 0.07)
			cols.append(base.lightened(v) if v > 0.0 else base.darkened(-v))
			t += seg
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = _cached("ledge", func() -> Mesh: return rounded_box(LEDGE_SIZE, LEDGE_RADIUS, 4))
	mm.instance_count = xfs.size()
	for i: int in xfs.size():
		mm.set_instance_transform(i, xfs[i])
		mm.set_instance_color(i, cols[i])
	var node := MultiMeshInstance3D.new()
	node.name = "BoardLedge"
	node.multimesh = mm
	var mat := ShaderMaterial.new()
	mat.shader = load(TILE_SHADER) as Shader
	mat.set_shader_parameter(&"tile_half", LEDGE_SIZE * 0.5)
	mat.set_shader_parameter(&"tile_radius", LEDGE_RADIUS)
	mat.set_shader_parameter(&"shadow_tint", Color(String(preset().shadow_tint)))
	mat.set_shader_parameter(&"edge_light", 0.6)
	mat.set_shader_parameter(&"gloss", 0.15)
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)


# ------------------------------------------------------------------ materials

func _cap() -> Dictionary:
	return _env.get("cap", {})


func _slab_material(half: Vector3, board_half: Vector2, haze: float) -> ShaderMaterial:
	var cap: Dictionary = _cap()
	var body: Dictionary = _env.get("body", {})
	var mat := ShaderMaterial.new()
	mat.shader = load(ISLAND_SHADER) as Shader
	mat.set_shader_parameter(&"half_size", half)
	mat.set_shader_parameter(&"radius", SLAB_RADIUS)
	mat.set_shader_parameter(&"cap_color", Color(String(cap.get("color", "#5C9E38"))))
	mat.set_shader_parameter(&"cap_light", Color(String(cap.get("light", "#9BD65E"))))
	mat.set_shader_parameter(&"cap_dark", Color(String(cap.get("dark", "#2F6A24"))))
	mat.set_shader_parameter(&"cap_depth", float(cap.get("depth", 0.14)))
	mat.set_shader_parameter(&"cap_drip", float(cap.get("drip", 0.12)))
	mat.set_shader_parameter(&"body_color", Color(String(body.get("color", "#A07650"))))
	mat.set_shader_parameter(&"body_dark", Color(String(body.get("dark", "#6B4A33"))))
	mat.set_shader_parameter(&"pebbles", float(body.get("pebbles", 1.0)))
	mat.set_shader_parameter(&"shadow_tint", Color(String(preset().shadow_tint)))
	if _env.has("inlay") and board_half != Vector2.ZERO:
		mat.set_shader_parameter(&"inlay", 1.0)
		mat.set_shader_parameter(&"inlay_color", Color(String(_env.inlay)))
		mat.set_shader_parameter(&"inlay_half", board_half)
	if float(_env.get("rock_glow", 0.0)) > 0.0:
		mat.set_shader_parameter(&"glow", float(_env.rock_glow))
		mat.set_shader_parameter(&"glow_color", Color(String(_env.get("glow_color", "#FF6A1A"))))
	mat.set_shader_parameter(&"haze", haze)
	mat.set_shader_parameter(&"haze_color", Color(String(_env.get("haze", "#D6E4F8"))))
	return mat


func _rock_material(band: int, haze: float, haze_c: Color, block_scale: float) -> ShaderMaterial:
	var strata: Array = _env.get("strata", ["#A07650", "#8E6646", "#74513A"])
	var c: Color = Color(String(strata[mini(band, strata.size() - 1)]))
	var mat := ShaderMaterial.new()
	mat.shader = load(ROCK_SHADER) as Shader
	mat.set_shader_parameter(&"body_color", c)
	mat.set_shader_parameter(&"body_dark", c.darkened(0.32))
	mat.set_shader_parameter(&"cover_color", Color(String(_cap().get("color", "#5C9E38"))))
	mat.set_shader_parameter(&"cover", float(_env.get("strata_cover", 0.0)))
	mat.set_shader_parameter(&"block", Vector2(1.1, 0.55) * maxf(block_scale, 0.3))
	mat.set_shader_parameter(&"seed", float(band) * 2.3)
	mat.set_shader_parameter(&"shadow_tint", Color(String(preset().shadow_tint)))
	if float(_env.get("rock_glow", 0.0)) > 0.0:
		mat.set_shader_parameter(&"glow", float(_env.rock_glow))
		mat.set_shader_parameter(&"glow_color", Color(String(_env.get("glow_color", "#FF6A1A"))))
	mat.set_shader_parameter(&"haze", haze)
	mat.set_shader_parameter(&"haze_color", haze_c if haze > 0.0 else Color(String(_env.get("haze", "#D6E4F8"))))
	return mat


func _prop_material(glow: float, haze: float, sway: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load(PROP_SHADER) as Shader
	mat.set_shader_parameter(&"glow", glow)
	mat.set_shader_parameter(&"haze", haze)
	mat.set_shader_parameter(&"haze_color", Color(String(_env.get("haze", "#D6E4F8"))))
	mat.set_shader_parameter(&"sway", sway)
	mat.set_shader_parameter(&"motion", motion)
	mat.set_shader_parameter(&"rim_amount", 0.45)
	mat.set_shader_parameter(&"gloss", 0.25)
	mat.set_shader_parameter(&"shadow_tint", Color(String(preset().shadow_tint)))
	return mat


func _instance_tint(spec: Dictionary) -> Color:
	var c: Color = Color(String(spec.get("tint", "#FFFFFF"))).srgb_to_linear()
	var j: float = _rng.randf_range(0.9, 1.08)
	return Color(c.r * j, c.g * j, c.b * j, 1.0)


# ------------------------------------------------------------------ helpers

func _pick(kinds: Array) -> Dictionary:
	var total: float = 0.0
	for k: Dictionary in kinds: total += float(k.get("weight", 1.0))
	var roll: float = _rng.randf() * total
	for k: Dictionary in kinds:
		roll -= float(k.get("weight", 1.0))
		if roll <= 0.0: return k
	return kinds[kinds.size() - 1]


func _near(p: Vector3, others: Array[Vector3], dist: float) -> bool:
	for o: Vector3 in others:
		if p.distance_squared_to(o) < dist * dist: return true
	return false


func _mmi(node_name: String, mesh: Mesh, transforms: Array[Transform3D], customs: Array[Color], mat: Material) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	# Instance colours must be on (white): without them COLOR reaches the shader as zero on
	# Compatibility and every prop renders black.
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i: int in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, Color.WHITE)
		mm.set_instance_custom_data(i, customs[i] if i < customs.size() else Color(1, 1, 1, 1))
	var node := MultiMeshInstance3D.new()
	node.name = node_name
	node.multimesh = mm
	node.material_override = mat
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


static func _cached(key: String, make: Callable) -> Mesh:
	if not _mesh_cache.has(key): _mesh_cache[key] = make.call()
	return _mesh_cache[key]


# ------------------------------------------------------------------ procedural meshes

## Rounded ("chunky") box with smooth normals, samples clustered at the edges (cookbook §3.1).
## Godot front faces are clockwise: cross(p1 - p0, p2 - p0) points into the mesh.
static func rounded_box(size: Vector3, r: float, n: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var inner: Vector3 = Vector3(0.5, 0.5, 0.5) - Vector3(r, r, r) / size
	var faces: Array = [[Vector3.RIGHT, Vector3.BACK, Vector3.UP], [Vector3.LEFT, Vector3.FORWARD, Vector3.UP],
		[Vector3.UP, Vector3.RIGHT, Vector3.BACK], [Vector3.DOWN, Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.BACK, Vector3.RIGHT, Vector3.UP], [Vector3.FORWARD, Vector3.LEFT, Vector3.UP]]
	for f: Array in faces:
		var nrm: Vector3 = f[0]
		var u: Vector3 = f[1]
		var v: Vector3 = f[2]
		var grid: Array = []
		for j: int in n + 1:
			var row: Array = []
			for i: int in n + 1:
				var a: float = 0.5 - 0.5 * cos(float(i) / n * PI) - 0.5
				var b: float = 0.5 - 0.5 * cos(float(j) / n * PI) - 0.5
				var q: Vector3 = nrm * 0.5 + u * a + v * b
				var c: Vector3 = q.clamp(-inner, inner)
				var d: Vector3 = (q - c) * size
				var dn: Vector3 = d.normalized() if d.length() > 0.00001 else nrm
				row.append([c * size + dn * r, dn, Vector2(a + 0.5, b + 0.5)])
			grid.append(row)
		var flip: bool = u.cross(v).dot(nrm) > 0.0
		for j: int in n:
			for i: int in n:
				var q00: Array = grid[j][i]
				var q10: Array = grid[j][i + 1]
				var q01: Array = grid[j + 1][i]
				var q11: Array = grid[j + 1][i + 1]
				var tris: Array = [q00, q11, q10, q00, q01, q11] if flip else [q00, q10, q11, q00, q11, q01]
				for t: Array in tris:
					st.set_normal(t[1])
					st.set_uv(t[2])
					st.add_vertex(t[0])
	st.index()
	return st.commit()


## Faceted rock band: a superellipse (n=4) prism with radius jitter, unit radius at the top
## (`rt`) and `rb` at the bottom, `h` tall, closed by a centre point 1.3 h down. Flat normals.
static func chunk_mesh(rt: float, rb: float, h: float, n: int, jit: float, rng: RandomNumberGenerator) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top: Array[Vector3] = []
	var bot: Array[Vector3] = []
	for i: int in n:
		var a: float = TAU * i / n + PI / 4.0
		var sq: float = 1.0 / pow(pow(absf(cos(a)), 4.0) + pow(absf(sin(a)), 4.0), 0.25)
		var j1: float = 1.0 + rng.randf_range(-jit, jit)
		var j2: float = 1.0 + rng.randf_range(-jit, jit) * 1.6
		top.append(Vector3(cos(a), 0, sin(a)) * rt * sq * j1)
		bot.append(Vector3(cos(a), 0, sin(a)) * rb * sq * j2 + Vector3(0, -h * rng.randf_range(0.88, 1.12), 0))
	var c_top := Vector3.ZERO
	var c_bot := Vector3(0, -h * 1.3, 0)
	var centre := Vector3(0, -h * 0.5, 0)
	for i: int in n:
		var k: int = (i + 1) % n
		for tri: Array in [[top[i], top[k], bot[k]], [top[i], bot[k], bot[i]], [c_top, top[k], top[i]], [c_bot, bot[i], bot[k]]]:
			var p0: Vector3 = tri[0]
			var p1: Vector3 = tri[1]
			var p2: Vector3 = tri[2]
			var outward: Vector3 = (p0 + p1 + p2) / 3.0 - centre
			var cr: Vector3 = (p1 - p0).cross(p2 - p0)
			if cr.dot(outward) > 0.0:
				var tmp: Vector3 = p1
				p1 = p2
				p2 = tmp
				cr = -cr
			var nrm: Vector3 = -cr.normalized()
			for v: Vector3 in [p0, p1, p2]:
				st.set_normal(nrm)
				st.add_vertex(v)
	return st.commit()


## Cached prop mesh for a rim / hanging kind (base at y = 0; hanging kinds point down).
func prop_mesh(kind: String) -> Mesh:
	var kit: Mesh = kit_mesh(kind)
	if kit != null: return kit
	return _cached("prop:" + kind, func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_recipe(st, kind, Transform3D.IDENTITY)
		return st.commit())


## Env v3 kit mesh for `kind` in this biome's family (then its KIT_FALLBACK family), or null when
## the kit has no such GLB. Cached per family and kind; the GLB's own material is ignored (callers
## set material_override), its node transform is baked into the vertices.
func kit_mesh(kind: String) -> Mesh:
	var family: String = String(_env.get("family", String(_biome)))
	var key: String = "kit:%s:%s" % [family, kind]
	if not _mesh_cache.has(key):
		var found: Mesh = null
		for dir: String in [family, String(KIT_FALLBACK.get(family, ""))]:
			if dir.is_empty(): continue
			found = load_kit_glb(KIT_DIR + dir + "/" + kind + ".glb")
			if found != null: break
		_mesh_cache[key] = found
	return _mesh_cache[key]


## Loads the first mesh of an imported GLB scene with its node transform applied; null if absent.
static func load_kit_glb(path: String) -> Mesh:
	if not ResourceLoader.exists(path): return null
	var scene := load(path) as PackedScene
	if scene == null: return null
	var root: Node = scene.instantiate()
	var mesh: Mesh = null
	var stack: Array[Node] = [root]
	while not stack.is_empty() and mesh == null:
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh != null:
			var xf: Transform3D = Transform3D.IDENTITY
			var walk: Node = n
			while walk != null and walk != root:
				if walk is Node3D: xf = (walk as Node3D).transform * xf
				walk = walk.get_parent()
			mesh = (n as MeshInstance3D).mesh
			if not xf.is_equal_approx(Transform3D.IDENTITY):
				var st := SurfaceTool.new()
				st.append_from(mesh, 0, xf)
				mesh = st.commit()
		for c: Node in n.get_children(): stack.append(c)
	root.free()
	return mesh


## Sculpted strata block variants from the kit (empty when the kit has none for this biome).
func kit_rock_blocks() -> Array[Mesh]:
	var out: Array[Mesh] = []
	for i: int in KIT_ROCK_VARIANTS:
		var m: Mesh = kit_mesh("rock_block_%02d" % (i + 1))
		if m != null: out.append(m)
	return out


## Merges instances of `meshes[variant[i]]` placed by `xfs[i]` into one static ArrayMesh with the
## per-instance colour multiplied into the vertex colour (one draw call per strata band).
static func merge_instances(meshes: Array[Mesh], variant: Array[int], xfs: Array[Transform3D], cols: Array[Color]) -> ArrayMesh:
	var src: Array = []
	for m: Mesh in meshes: src.append(m.surface_get_arrays(0))
	var pos := PackedVector3Array()
	var nrm := PackedVector3Array()
	var col := PackedColorArray()
	var idx := PackedInt32Array()
	for i: int in xfs.size():
		var a: Array = src[variant[i]]
		var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var n: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
		var c: PackedColorArray = a[Mesh.ARRAY_COLOR] if a[Mesh.ARRAY_COLOR] != null else PackedColorArray()
		var ix: PackedInt32Array = a[Mesh.ARRAY_INDEX] if a[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		var xf: Transform3D = xfs[i]
		var nb: Basis = xf.basis.inverse().transposed()
		var tint: Color = cols[i]
		var base: int = pos.size()
		for k: int in v.size():
			pos.append(xf * v[k])
			nrm.append((nb * n[k]).normalized())
			var vc: Color = c[k] if k < c.size() else Color.WHITE
			col.append(Color(vc.r * tint.r, vc.g * tint.g, vc.b * tint.b, vc.a))
		if ix.is_empty():
			for k: int in v.size(): idx.append(base + k)
		else:
			for k: int in ix: idx.append(base + k)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = pos
	arrays[Mesh.ARRAY_NORMAL] = nrm
	arrays[Mesh.ARRAY_COLOR] = col
	arrays[Mesh.ARRAY_INDEX] = idx
	var out := ArrayMesh.new()
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return out


func _landmark_mesh(kind: String) -> Mesh:
	return _cached("far:%s:%s" % [_biome, kind], func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_landmark(st, kind)
		return st.commit())


# Vertex colour helpers: tintable (A=1), fixed (A=0.5), emissive (A=0).
static func _n(v: float) -> Color: return Color(v, v, v, 1.0)
static func _fx(hex: String) -> Color:
	var c := Color(hex)
	c.a = 0.5
	return c
static func _em(hex: String) -> Color:
	var c := Color(hex)
	c.a = 0.0
	return c


static func _tr(pos: Vector3, scl: Vector3 = Vector3.ONE, rot: Vector3 = Vector3.ZERO) -> Transform3D:
	return Transform3D(Basis.from_euler(rot) * Basis.from_scale(scl), pos)


static func _sph(r: float, seg: int = 10, rings: int = 6) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = seg
	m.rings = rings
	return m


static func _cyl(top: float, bottom: float, h: float, seg: int = 8) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = h
	m.radial_segments = seg
	m.rings = 1
	return m


static func _bx(size: Vector3) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = size
	return m


## Appends a primitive's triangles with a flat vertex colour, transformed by `xf`.
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


func _recipe(st: SurfaceTool, kind: String, x: Transform3D) -> void:
	match kind:
		"tuft":
			for k: int in 7:
				var a: float = k * TAU / 7.0 + 0.3
				_prim(st, _cyl(0.0, 0.045, 0.26, 4), x * _tr(Vector3(cos(a) * 0.06, 0.11, sin(a) * 0.06), Vector3.ONE, Vector3(sin(a) * 0.5, 0, -cos(a) * 0.5)), _n(1.0 if k % 2 == 0 else 0.78))
		"clover":
			# Three heart-shaped leaves (two lobes each), tilted up, lighter at the tips, on a stem.
			for k: int in 3:
				var a: float = TAU * k / 3.0 + 0.5
				for lobe: int in 2:
					var la: float = a + (0.32 if lobe == 0 else -0.32)
					_prim(st, _sph(0.5, 8, 4), x * _tr(Vector3(cos(la) * 0.12, 0.14 + 0.02 * k, sin(la) * 0.12), Vector3(0.2, 0.06, 0.15), Vector3(0, -la, 0.3)), _n(1.0 if k != 1 else 0.86))
			_prim(st, _cyl(0.012, 0.018, 0.14, 4), x * _tr(Vector3(0, 0.07, 0)), _n(0.65))
			_prim(st, _sph(0.04, 6, 3), x * _tr(Vector3(0, 0.15, 0)), _n(0.7))
		"flower_white", "flower_lilac", "flower_pink", "flower_yellow":
			var petal: Color = _fx({"flower_white": "#FFF6F0", "flower_lilac": "#B99CF2", "flower_pink": "#F6A8C8", "flower_yellow": "#FFE27A"}[kind])
			for k: int in 5:
				var a: float = TAU * k / 5.0
				# Cupped daisy: petals tilt up at the tips so they read as a flower, not a disc.
				_prim(st, _sph(0.5, 8, 4), x * _tr(Vector3(cos(a) * 0.15, 0.1, sin(a) * 0.15), Vector3(0.27, 0.075, 0.17), Vector3(0, -a, 0.32)), petal)
			_prim(st, _sph(0.075, 8, 4), x * _tr(Vector3(0, 0.13, 0), Vector3(1, 0.7, 1)), _fx("#FFC93A"))
			_prim(st, _cyl(0.015, 0.02, 0.1, 4), x * _tr(Vector3(0, 0.05, 0)), _fx("#4E9A3A"))
			for k: int in 2:
				var a: float = k * PI + 0.8
				_prim(st, _sph(0.5, 6, 3), x * _tr(Vector3(cos(a) * 0.2, 0.04, sin(a) * 0.2), Vector3(0.22, 0.05, 0.12), Vector3(0, -a, 0)), _fx("#4E9A3A"))
		"bush":
			for b: Array in [[Vector3(0, 0.22, 0), 0.27, 0.85], [Vector3(0.22, 0.17, 0.05), 0.2, 0.78], [Vector3(-0.18, 0.16, 0.08), 0.2, 0.8], [Vector3(0.02, 0.38, -0.03), 0.18, 1.0], [Vector3(-0.05, 0.14, -0.2), 0.18, 0.75]]:
				_prim(st, _sph(float(b[1]), 10, 6), x * _tr(b[0]), _n(float(b[2])))
		"mound":
			_prim(st, _sph(0.3, 10, 5), x * _tr(Vector3(0, 0.03, 0), Vector3(1, 0.42, 1)), _n(1.0))
			_prim(st, _sph(0.2, 10, 5), x * _tr(Vector3(0.22, 0.04, 0.1), Vector3(1, 0.5, 1)), _n(0.95))
		"shrub":
			for k: int in 7:
				var a: float = k * TAU / 7.0
				var tilt: float = 0.45 + 0.2 * (k % 2)
				var dir := Vector3(sin(a) * sin(tilt), cos(tilt), cos(a) * sin(tilt))
				_prim(st, _cyl(0.012, 0.03, 0.42, 4), x * Transform3D(Basis(Vector3.UP, a) * Basis(Vector3.RIGHT, tilt), dir * 0.21), _n(0.85))
				_prim(st, _sph(0.06, 6, 3), x * _tr(dir * 0.42), _n(1.0))
		"tree_white":
			_prim(st, _cyl(0.045, 0.08, 0.85, 6), x * _tr(Vector3(0, 0.42, 0)), _fx("#E6ECF6"))
			for k: int in 7:
				var a: float = k * 2.4
				var h: float = 0.4 + k * 0.06
				var tilt: float = 0.7 + 0.1 * (k % 3)
				var dir := Vector3(sin(a) * sin(tilt), cos(tilt), cos(a) * sin(tilt))
				_prim(st, _cyl(0.012, 0.03, 0.4, 4), x * Transform3D(Basis(Vector3.UP, a) * Basis(Vector3.RIGHT, tilt), Vector3(0, h, 0) + dir * 0.2), _fx("#EEF2FA"))
				_prim(st, _sph(0.08, 6, 4), x * _tr(Vector3(0, h, 0) + dir * 0.4), _fx("#FFFFFF"))
			_prim(st, _sph(0.11, 6, 4), x * _tr(Vector3(0, 0.88, 0)), _fx("#FFFFFF"))
		"tree":
			_prim(st, _cyl(0.05, 0.08, 0.6, 6), x * _tr(Vector3(0, 0.3, 0)), _fx("#8B6A48"))
			_prim(st, _sph(0.34, 10, 6), x * _tr(Vector3(0, 0.8, 0)), _n(0.95))
			_prim(st, _sph(0.24, 10, 6), x * _tr(Vector3(0.2, 0.64, 0.12)), _n(0.82))
			_prim(st, _sph(0.22, 10, 6), x * _tr(Vector3(-0.2, 0.68, -0.06)), _n(0.88))
		"pine":
			_prim(st, _cyl(0.05, 0.07, 0.3, 6), x * _tr(Vector3(0, 0.15, 0)), _fx("#7A5A40"))
			for k: int in 3:
				var r: float = 0.36 - k * 0.09
				_prim(st, _cyl(0.0, r, 0.42, 8), x * _tr(Vector3(0, 0.45 + k * 0.25, 0)), _n(0.9))
				_prim(st, _cyl(0.0, r * 0.75, 0.24, 8), x * _tr(Vector3(0, 0.56 + k * 0.25, 0)), _fx("#F4F8FF"))
		"rock":
			_prim(st, _sph(0.22, 7, 4), x * _tr(Vector3(0, 0.08, 0), Vector3(1.2, 0.7, 0.95)), _n(0.95))
			_prim(st, _sph(0.13, 6, 3), x * _tr(Vector3(0.22, 0.04, 0.1)), _n(0.8))
		"rubble":
			_prim(st, _bx(Vector3(0.3, 0.2, 0.24)), x * _tr(Vector3(0, 0.1, 0), Vector3.ONE, Vector3(0, 0.4, 0.05)), _n(1.0))
			_prim(st, _bx(Vector3(0.2, 0.14, 0.18)), x * _tr(Vector3(0.26, 0.07, 0.12), Vector3.ONE, Vector3(0.15, 1.0, 0.1)), _n(0.85))
			_prim(st, _bx(Vector3(0.12, 0.1, 0.12)), x * _tr(Vector3(-0.2, 0.05, 0.16), Vector3.ONE, Vector3(0, 0.3, 0.2)), _n(0.9))
		"pillar", "pillar_broken":
			var broken: bool = kind == "pillar_broken"
			var h: float = 0.55 if broken else 1.0
			_prim(st, _bx(Vector3(0.48, 0.12, 0.48)), x * _tr(Vector3(0, 0.06, 0)), _n(0.9))
			_prim(st, _cyl(0.16, 0.18, h, 10), x * _tr(Vector3(0, 0.12 + h * 0.5, 0)), _n(1.0))
			var gold: TorusMesh = TorusMesh.new()
			gold.inner_radius = 0.17
			gold.outer_radius = 0.22
			gold.rings = 16
			gold.ring_segments = 4
			_prim(st, gold, x * _tr(Vector3(0, 0.2, 0)), _fx("#E8C25A"))
			if broken:
				_prim(st, _cyl(0.15, 0.16, 0.16, 10), x * _tr(Vector3(0.03, 0.12 + h + 0.06, 0), Vector3.ONE, Vector3(0.35, 0, 0.25)), _n(0.95))
				_prim(st, _bx(Vector3(0.22, 0.16, 0.2)), x * _tr(Vector3(0.36, 0.08, 0.1), Vector3.ONE, Vector3(0.2, 0.6, 0.3)), _n(0.9))
			else:
				_prim(st, _bx(Vector3(0.44, 0.1, 0.44)), x * _tr(Vector3(0, 0.12 + h + 0.05, 0)), _n(0.95))
				_prim(st, _torus_ring(0.17, 0.21), x * _tr(Vector3(0, 0.12 + h - 0.05, 0)), _fx("#E8C25A"))
		"star":
			_prim(st, _sph(0.07, 8, 4), x * _tr(Vector3(0, 0.22, 0)), _em("#FFD86A"))
			for k: int in 4:
				_prim(st, _cyl(0.0, 0.05, 0.2, 4), x * _tr(Vector3(0, 0.22, 0)) * Transform3D(Basis(Vector3.BACK, k * PI * 0.5), Vector3.ZERO) * _tr(Vector3(0, 0.1, 0)), _em("#FFD86A"))
		"blob":
			_prim(st, _sph(0.2, 10, 5), x * _tr(Vector3(0, 0.07, 0), Vector3(1, 0.6, 1)), _n(1.0))
			_prim(st, _sph(0.14, 10, 5), x * _tr(Vector3(0, 0.18, 0), Vector3(1, 0.75, 1)), _n(0.97))
			_prim(st, _sph(0.075, 8, 4), x * _tr(Vector3(0, 0.27, 0)), _n(1.0))
			_prim(st, _sph(0.05, 8, 4), x * _tr(Vector3(0, 0.34, 0)), _fx("#E8384F"))
		"gumdrop":
			_prim(st, _sph(0.14, 10, 6), x * _tr(Vector3(0, 0.1, 0), Vector3(1, 1.1, 1)), _n(1.0))
		"lollipop":
			_prim(st, _cyl(0.02, 0.02, 0.6, 6), x * _tr(Vector3(0, 0.3, 0)), _fx("#FFF7EC"))
			_prim(st, _cyl(0.2, 0.2, 0.07, 16), x * _tr(Vector3(0, 0.74, 0), Vector3.ONE, Vector3(PI * 0.5, 0, 0)), _n(1.0))
			_prim(st, _cyl(0.13, 0.13, 0.075, 16), x * _tr(Vector3(0, 0.74, 0), Vector3.ONE, Vector3(PI * 0.5, 0, 0)), _fx("#FFF7EC"))
			_prim(st, _cyl(0.07, 0.07, 0.08, 12), x * _tr(Vector3(0, 0.74, 0), Vector3.ONE, Vector3(PI * 0.5, 0, 0)), _n(1.0))
		"basalt":
			for b: Array in [[Vector3(0, 0, 0), 0.32], [Vector3(0.22, 0, 0.08), 0.46], [Vector3(-0.15, 0, 0.17), 0.24], [Vector3(0.05, 0, -0.22), 0.38]]:
				_prim(st, _cyl(0.12, 0.13, float(b[1]), 6), x * _tr(b[0] + Vector3(0, float(b[1]) * 0.5, 0)), _n(0.8 + float(b[1]) * 0.3))
		"lava_pool":
			_prim(st, _sph(0.34, 12, 4), x * _tr(Vector3(0, 0.0, 0), Vector3(1, 0.16, 1)), _n(0.8))
			_prim(st, _sph(0.25, 12, 4), x * _tr(Vector3(0, 0.03, 0), Vector3(1, 0.14, 1)), _em("#FF7A1A"))
		"crystal":
			for k: int in 3:
				_prim(st, _cyl(0.0, 0.09, 0.5 - k * 0.1, 5), x * _tr(Vector3((k - 1) * 0.09, 0.22 - k * 0.04, 0), Vector3.ONE, Vector3(0, k, (k - 1) * 0.35)), _n(1.0 - k * 0.1))
		"mushroom":
			_prim(st, _cyl(0.05, 0.07, 0.25, 6), x * _tr(Vector3(0, 0.12, 0)), _fx("#F4EAD8"))
			_prim(st, _sph(0.18, 10, 5), x * _tr(Vector3(0, 0.26, 0), Vector3(1, 0.6, 1)), _n(1.0))
			for k: int in 3:
				_prim(st, _sph(0.035, 6, 3), x * _tr(Vector3(cos(k * 2.1) * 0.1, 0.33, sin(k * 2.1) * 0.1)), _fx("#FFFFFF"))
		"coral":
			for k: int in 5:
				var a: float = k * 1.3
				var tilt: float = 0.3 + 0.12 * k
				var dir := Vector3(sin(a) * sin(tilt), cos(tilt), cos(a) * sin(tilt))
				_prim(st, _cyl(0.03, 0.05, 0.42, 5), x * Transform3D(Basis(Vector3.UP, a) * Basis(Vector3.RIGHT, tilt), dir * 0.21), _n(0.9))
				_prim(st, _sph(0.055, 6, 3), x * _tr(dir * 0.43), _n(1.0))
		"shell":
			_prim(st, _sph(0.16, 10, 5), x * _tr(Vector3(0, 0.05, 0), Vector3(1, 0.45, 0.8)), _n(1.0))
		"gear":
			_prim(st, _torus_ring(0.15, 0.25), x * _tr(Vector3(0, 0.04, 0), Vector3(1, 1.6, 1)), _n(1.0))
			for k: int in 8:
				var a: float = k * TAU / 8.0
				_prim(st, _bx(Vector3(0.09, 0.08, 0.09)), x * _tr(Vector3(cos(a) * 0.28, 0.04, sin(a) * 0.28), Vector3.ONE, Vector3(0, -a, 0)), _n(0.9))
		# ---- hanging kinds (point down from y = 0)
		"root":
			_prim(st, _cyl(0.05, 0.022, 0.6, 5), x * _tr(Vector3(0, -0.28, 0), Vector3.ONE, Vector3(0.25, 0, 0.15)), _n(0.9))
			_prim(st, _cyl(0.022, 0.006, 0.45, 5), x * _tr(Vector3(0.08, -0.74, 0.07), Vector3.ONE, Vector3(-0.3, 0, 0.35)), _n(0.8))
			_prim(st, _cyl(0.04, 0.0, 0.3, 4), x * _tr(Vector3(-0.12, -0.12, 0.02)), _fx("#5C9E38"))
		"strand":
			for k: int in 3:
				_prim(st, _cyl(0.035, 0.0, 0.28 + k * 0.06, 4), x * _tr(Vector3((k - 1) * 0.08, -0.14 - k * 0.03, 0)), _n(1.0 - k * 0.08))
		"icicle":
			_prim(st, _cyl(0.07, 0.0, 0.7, 6), x * _tr(Vector3(0, -0.33, 0)), _fx("#D8EEFF"))
			_prim(st, _cyl(0.045, 0.0, 0.4, 6), x * _tr(Vector3(0.11, -0.18, 0.04)), _fx("#EEF8FF"))
			_prim(st, _cyl(0.035, 0.0, 0.3, 6), x * _tr(Vector3(-0.09, -0.13, -0.05)), _fx("#C8E4FA"))
		"stalactite":
			_prim(st, _cyl(0.11, 0.0, 0.6, 6), x * _tr(Vector3(0, -0.28, 0)), _n(1.0))
			_prim(st, _cyl(0.06, 0.0, 0.35, 6), x * _tr(Vector3(0.13, -0.15, 0.02)), _n(0.85))
		"lava_drip":
			_prim(st, _cyl(0.1, 0.02, 0.55, 6), x * _tr(Vector3(0, -0.26, 0)), _n(0.9))
			_prim(st, _sph(0.045, 6, 3), x * _tr(Vector3(0, -0.56, 0)), _em("#FF8A2A"))
		"crystal_down":
			_prim(st, _cyl(0.08, 0.0, 0.5, 5), x * _tr(Vector3(0, -0.24, 0), Vector3.ONE, Vector3(0, 0, 0.2)), _n(1.0))
			_prim(st, _cyl(0.05, 0.0, 0.32, 5), x * _tr(Vector3(0.1, -0.15, 0), Vector3.ONE, Vector3(0, 0, -0.3)), _n(0.85))
		_:
			_prim(st, _sph(0.2, 7, 4), x * _tr(Vector3(0, 0.08, 0), Vector3(1, 0.7, 1)), _n(0.9))


static func _torus_ring(inner: float, outer: float) -> TorusMesh:
	var t := TorusMesh.new()
	t.inner_radius = inner
	t.outer_radius = outer
	t.rings = 18
	t.ring_segments = 4
	return t


## Distant landmark on a far island top (y = 0 is the island top). Colours from env.
func _landmark(st: SurfaceTool, kind: String) -> void:
	var rock: String = String(_env.get("far_rock", "#A07650"))
	var accent: String = String(_env.get("far_accent", "#6A7FD0"))
	match kind:
		"trees", "waterfall":
			for p: Vector3 in [Vector3(-0.8, 0, -0.5), Vector3(-0.2, 0, -0.75), Vector3(0.7, 0, -0.4), Vector3(-1.1, 0, 0.4), Vector3(1.0, 0, 0.5)]:
				_recipe(st, "tree", _tr(p, Vector3.ONE * 1.4))
		"pine":
			for p: Vector3 in [Vector3(-0.8, 0, -0.4), Vector3(-0.1, 0, -0.7), Vector3(0.6, 0, -0.3), Vector3(1.1, 0, 0.4), Vector3(-1.1, 0, 0.5)]:
				_recipe(st, "pine", _tr(p, Vector3.ONE * 1.5))
		"castle":
			var stone: Color = _fx(String(_env.get("far_stone", "#ECE8F4")))
			_prim(st, _bx(Vector3(1.1, 0.7, 0.7)), _tr(Vector3(0, 0.35, -0.2)), stone)
			for t: Array in [[Vector3(-0.6, 0, -0.2), 1.1], [Vector3(0.6, 0, -0.2), 1.1], [Vector3(0, 0, -0.45), 1.7], [Vector3(0.25, 0, 0.25), 0.8]]:
				var h: float = float(t[1])
				_prim(st, _cyl(0.17, 0.19, h, 10), _tr(t[0] + Vector3(0, h * 0.5, 0)), stone)
				_prim(st, _cyl(0.0, 0.25, 0.5, 10), _tr(t[0] + Vector3(0, h + 0.25, 0)), _fx(accent))
			_recipe(st, "pine", _tr(Vector3(-1.1, 0, 0.5)))
			_recipe(st, "pine", _tr(Vector3(1.1, 0, 0.4)))
		"arch":
			_prim(st, _cyl(0.15, 0.17, 1.5, 10), _tr(Vector3(-0.55, 0.75, -0.2)), _fx("#ECE6DA"))
			_prim(st, _cyl(0.15, 0.17, 1.5, 10), _tr(Vector3(0.55, 0.75, -0.2)), _fx("#ECE6DA"))
			_prim(st, _bx(Vector3(1.6, 0.26, 0.4)), _tr(Vector3(0, 1.6, -0.2)), _fx("#ECE6DA"))
			_prim(st, _bx(Vector3(1.7, 0.06, 0.44)), _tr(Vector3(0, 1.46, -0.2)), _fx("#E8C25A"))
			_prim(st, _sph(0.13, 8, 4), _tr(Vector3(0, 1.0, -0.2)), _em("#FFD86A"))
			_recipe(st, "pillar_broken", _tr(Vector3(1.0, 0, 0.5), Vector3.ONE * 1.3))
		"pillars":
			_recipe(st, "pillar", _tr(Vector3(-0.7, 0, -0.3), Vector3.ONE * 1.6))
			_recipe(st, "pillar_broken", _tr(Vector3(0.6, 0, -0.1), Vector3.ONE * 1.6))
			_recipe(st, "rubble", _tr(Vector3(0.1, 0, 0.5), Vector3.ONE * 1.4))
		"planet":
			_prim(st, _sph(1.0, 24, 12), _tr(Vector3.ZERO), _fx(String(_env.get("planet", "#C27AD8"))))
			_prim(st, _sph(1.01, 24, 12), _tr(Vector3(0, 0.0, 0), Vector3(1, 0.25, 1)), _fx("#E6A0E8"))
			_prim(st, _torus_ring(1.3, 1.7), _tr(Vector3.ZERO, Vector3(1, 0.06, 1), Vector3(0.35, 0, 0.25)), _fx("#F2D8A0"))
		"mountain":
			_prim(st, _cyl(0.08, 1.2, 2.0, 9), _tr(Vector3(-0.2, 1.0, -0.2)), _fx(rock))
			_prim(st, _cyl(0.0, 0.48, 0.8, 9), _tr(Vector3(-0.2, 1.62, -0.2)), _fx("#FFFFFF"))
			_prim(st, _cyl(0.06, 0.7, 1.1, 8), _tr(Vector3(0.8, 0.55, 0.2)), _fx(rock))
		"volcano":
			_prim(st, _cyl(0.28, 1.25, 1.6, 10), _tr(Vector3(0, 0.8, -0.1)), _fx(rock))
			_prim(st, _sph(0.3, 10, 4), _tr(Vector3(0, 1.6, -0.1), Vector3(1, 0.2, 1)), _em("#FF7A1A"))
			_recipe(st, "basalt", _tr(Vector3(1.0, 0, 0.5), Vector3.ONE * 1.5))
		"candy":
			_recipe(st, "lollipop", _tr(Vector3(-0.6, 0, -0.3), Vector3.ONE * 1.8))
			_recipe(st, "lollipop", _tr(Vector3(0.5, 0, -0.5), Vector3.ONE * 1.4))
			_recipe(st, "blob", _tr(Vector3(0.2, 0, 0.4), Vector3.ONE * 1.8))
			_recipe(st, "blob", _tr(Vector3(-1.0, 0, 0.5), Vector3.ONE * 1.4))
		"crystals":
			_recipe(st, "crystal", _tr(Vector3(-0.4, 0, -0.2), Vector3.ONE * 2.4))
			_recipe(st, "crystal", _tr(Vector3(0.6, 0, 0.2), Vector3.ONE * 1.8))
		"basalt":
			_recipe(st, "basalt", _tr(Vector3(0, 0, 0), Vector3.ONE * 2.2))
		_:
			_recipe(st, "rock", _tr(Vector3.ZERO, Vector3.ONE * 2.0))
