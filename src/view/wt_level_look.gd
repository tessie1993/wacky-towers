class_name WtLevelLook extends Node3D
## Optional per-level `look` block (design/levels/plans/level-identity-spec.md), applied by WtStage
## AFTER the biome look. Levels without `look` never create this node, so they render as before.
##   time_of_day : dawn | day | golden | dusk | night  (assets/data/look_presets.json: overrides/multipliers)
##   weather     : clear | mist | drizzle | snow | embers | bubbles | petals | stars | confetti
##                 (CPUParticles3D, Compatibility-safe, skipped under reduced motion)
##   set_piece   : id from assets/data/set_pieces.json (WtSetPieceBuilder), set_piece_side left | right | back
##   accent      : "#RRGGBB" tints the landmark trim, petals, and a touch of the fog
##   camera      : default | low | high | wide | close
##   dressing    : sparse | normal | lush
## apply() is repeatable: it restores the biome look first, so a QA tool can swap looks on one stage.
## Budget: weather <= 140 CPU particles on 1 draw call; set piece 1-6 mesh draws; no extra lights.

const PRESETS_PATH := "res://assets/data/look_presets.json"
const LEVEL_PATH := "res://src/levels/%s/%s/%s.json"
const SIDES: Array[String] = ["left", "right", "back"]
const DIAMOND := 1.4142
## Island ring (cells) around the board, mirrors WtIslandBuilder.RING.
const ISLAND_RING := 1.25

static var _presets: Dictionary = {}
static var _textures: Dictionary = {}

var _env: Environment
var _rig: Array[DirectionalLight3D] = []
var _camera: Camera3D
var _world: Node3D
var _sky_mat: ShaderMaterial
var _size: Vector3i = Vector3i(8, 8, 8)
var _biome: StringName = &"meadow"
var _reduced: bool = false
var _hide: Dictionary = {}
var _base: Dictionary = {}
var _base_elevation: float = 32.0
var _look: Dictionary = {}
var _sun_override: bool = false
var _sun_pitch: float = 50.0
var _sun_yaw: float = 0.0
var _accent: Color = Color(0, 0, 0, 0)
var _piece: Node3D
var _piece_side: String = "right"
var _weather: CPUParticles3D
var _rim: Array[Dictionary] = []
var _hidden: Array[Node3D] = []
var _time: float = 0.0


## Loads (once) the preset table; empty when the file is missing.
static func presets() -> Dictionary:
	if _presets.is_empty() and FileAccess.file_exists(PRESETS_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PRESETS_PATH))
		if parsed is Dictionary: _presets = parsed
	return _presets


## The `look` block of a level's JSON (empty when the level has none).
static func read_level_look(biome: StringName, level_id: String) -> Dictionary:
	if level_id.is_empty(): return {}
	var path: String = LEVEL_PATH % [biome, level_id, level_id]
	if not FileAccess.file_exists(path): return {}
	var text: String = FileAccess.get_file_as_string(path)
	if not text.contains("\"look\""): return {}
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var root: Dictionary = parsed
		var look: Variant = root.get("look", {})
		if look is Dictionary: return look
	return {}


## Problems in a `look` block (unknown ids and values); empty when valid. Used by QA tools.
static func validate(look: Dictionary) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var p: Dictionary = presets()
	var tod: Dictionary = p.get("time_of_day", {})
	var wx: Dictionary = p.get("weather", {})
	var cams: Dictionary = p.get("camera", {})
	var dress: Dictionary = p.get("dressing", {})
	if look.has("time_of_day") and not tod.has(String(look["time_of_day"])): out.append("time_of_day: " + str(look["time_of_day"]))
	if look.has("weather") and not wx.has(String(look["weather"])): out.append("weather: " + str(look["weather"]))
	if look.has("camera") and not cams.has(String(look["camera"])): out.append("camera: " + str(look["camera"]))
	if look.has("dressing") and not dress.has(String(look["dressing"])): out.append("dressing: " + str(look["dressing"]))
	if look.has("set_piece") and not WtSetPieceBuilder.has_piece(String(look["set_piece"])): out.append("set_piece: " + str(look["set_piece"]))
	if look.has("set_piece_side") and not SIDES.has(String(look["set_piece_side"])): out.append("set_piece_side: " + str(look["set_piece_side"]))
	if look.has("accent") and not Color.html_is_valid(String(look["accent"])): out.append("accent: " + str(look["accent"]))
	return out


## Binds the stage parts this look drives and snapshots the biome look. `parts`: environment, rig
## (Array[DirectionalLight3D]), camera, world, sky_parent, size (Vector3i), biome, reduced, elevation,
## hide (Dictionary name -> Node3D of built-in landmarks: windmill, carousel, ferris).
func bind(parts: Dictionary) -> void:
	_env = parts["environment"] as Environment
	_rig = parts["rig"] as Array[DirectionalLight3D]
	_camera = parts["camera"] as Camera3D
	_world = parts["world"] as Node3D
	_size = parts["size"] as Vector3i
	_biome = StringName(String(parts["biome"]))
	_reduced = bool(parts.get("reduced", false))
	_base_elevation = float(parts.get("elevation", 32.0))
	_hide = parts.get("hide", {})
	var sky_parent: Node = parts.get("sky_parent", null) as Node
	var layer: Node = sky_parent.get_node_or_null("SkyBackdrop") if sky_parent != null else null
	if layer != null:
		for c: Node in layer.get_children():
			if c is ColorRect and (c as ColorRect).material is ShaderMaterial:
				_sky_mat = (c as ColorRect).material as ShaderMaterial
	_snapshot()
	set_process(false)


## Applies a look block over the biome look. Returns {"elevation": float, "zoom": float} for the stage camera.
func apply(look: Dictionary) -> Dictionary:
	_restore()
	_look = look.duplicate(true)
	for problem: String in validate(look): push_warning("WtLevelLook: unknown %s" % problem)
	_accent = Color(String(look["accent"])) if look.has("accent") and Color.html_is_valid(String(look["accent"])) else Color(0, 0, 0, 0)
	var tod: String = String(look.get("time_of_day", ""))
	var lit: float = 0.35
	if presets().get("time_of_day", {}).has(tod): lit = _apply_time_of_day(tod)
	_apply_dressing(String(look.get("dressing", "normal")))
	_build_weather()
	_build_set_piece(lit)
	var cam: Dictionary = presets().get("camera", {}).get(String(look.get("camera", "default")), {})
	_update_process()
	return {"elevation": float(cam.get("elevation_deg", _base_elevation)) if look.has("camera") else _base_elevation,
		"zoom": float(cam.get("zoom", 1.0)) if look.has("camera") else 1.0}


## Reduced motion toggled at runtime: weather and landmark animation stop, the rest stays.
func set_reduced(value: bool) -> void:
	if value == _reduced: return
	_reduced = value
	if _weather != null:
		_weather.queue_free()
		_weather = null
	_build_weather()
	if _reduced: WtSetPieceBuilder.animate(_piece, 0.0)
	_update_process()


## Called by WtStage every camera update: re-aims the key light for the time of day and keeps the
## landmark on its chosen screen side whatever the view yaw (degrees).
func update_view(rig: Array[DirectionalLight3D], yaw_deg: float, camera: Camera3D) -> void:
	_camera = camera
	if _sun_override and not rig.is_empty() and is_instance_valid(rig[0]):
		rig[0].rotation_degrees = Vector3(-_sun_pitch, yaw_deg - 75.0 + _sun_yaw, 0.0)
	if _piece != null: _place_piece(yaw_deg)


func _process(delta: float) -> void:
	_time += delta
	WtSetPieceBuilder.animate(_piece, _time)


func _update_process() -> void:
	set_process(_piece != null and not _reduced and _piece.has_meta(&"anims") and not (_piece.get_meta(&"anims") as Array).is_empty())


# ------------------------------------------------------------------ biome snapshot and restore

func _snapshot() -> void:
	_base.clear()
	_base["key_color"] = _rig[0].light_color
	_base["key_energy"] = _rig[0].light_energy
	_base["fill_color"] = _rig[1].light_color
	_base["fill_energy"] = _rig[1].light_energy
	_base["back_energy"] = _rig[2].light_energy
	_base["ambient_color"] = _env.ambient_light_color
	_base["ambient_energy"] = _env.ambient_light_energy
	_base["saturation"] = _env.adjustment_saturation
	_base["brightness"] = _env.adjustment_brightness
	_base["glow"] = _env.glow_intensity
	_base["fog_enabled"] = _env.fog_enabled
	_base["fog_density"] = _env.fog_density
	_base["fog_color"] = _env.fog_light_color
	if _sky_mat != null:
		for key: String in ["top", "horizon", "low"]: _base["sky_" + key] = _sky_param(key, Color.WHITE)
		for key: String in ["sun", "stars", "nebula"]: _base["sky_" + key] = _sky_param(key, 0.0)
	_rim.clear()
	if _world != null: _collect_rim(_world)


func _sky_param(key: String, fallback: Variant) -> Variant:
	var v: Variant = _sky_mat.get_shader_parameter(StringName(key))
	if v == null and _sky_mat.shader != null:
		v = RenderingServer.shader_get_parameter_default(_sky_mat.shader.get_rid(), StringName(key))
	return v if v != null else fallback


func _collect_rim(node: Node) -> void:
	for c: Node in node.get_children():
		if c is MultiMeshInstance3D and (String(c.name).begins_with("Rim_") or String(c.name).begins_with("Hero_")):
			var mmi: MultiMeshInstance3D = c as MultiMeshInstance3D
			if mmi.multimesh != null: _rim.append({"mm": mmi.multimesh, "visible": mmi.multimesh.visible_instance_count})
		_collect_rim(c)


func _restore() -> void:
	if _base.is_empty(): return
	_rig[0].light_color = _base["key_color"]
	_rig[0].light_energy = _base["key_energy"]
	_rig[1].light_color = _base["fill_color"]
	_rig[1].light_energy = _base["fill_energy"]
	_rig[2].light_energy = _base["back_energy"]
	_env.ambient_light_color = _base["ambient_color"]
	_env.ambient_light_energy = _base["ambient_energy"]
	_env.adjustment_saturation = _base["saturation"]
	_env.adjustment_brightness = _base["brightness"]
	_env.glow_intensity = _base["glow"]
	_env.fog_enabled = _base["fog_enabled"]
	_env.fog_density = _base["fog_density"]
	_env.fog_light_color = _base["fog_color"]
	if _sky_mat != null:
		for key: String in ["top", "horizon", "low", "sun", "stars", "nebula"]: _sky_mat.set_shader_parameter(StringName(key), _base["sky_" + key])
	_sun_override = false
	for r: Dictionary in _rim:
		if is_instance_valid(r["mm"]): (r["mm"] as MultiMesh).visible_instance_count = int(r["visible"])
	for n: Node3D in _hidden:
		if is_instance_valid(n): n.visible = true
	_hidden.clear()
	if _piece != null:
		_piece.queue_free()
		_piece = null
	if _weather != null:
		_weather.queue_free()
		_weather = null
	_time = 0.0


# ------------------------------------------------------------------ time of day

## Applies a preset as overrides and multipliers on the biome look; returns the lit-window multiplier.
func _apply_time_of_day(tod: String) -> float:
	var table: Dictionary = presets()
	var p: Dictionary = (table["time_of_day"][tod] as Dictionary).duplicate(true)
	var biome_over: Dictionary = (p.get("biome", {}) as Dictionary).get(String(_biome), {})
	p.merge(biome_over, true)
	var sky_scale: float = float(table.get("biome_scale", {}).get("sky_mix", {}).get(String(_biome), 1.0))
	var sky_mix: float = clampf(float(p["sky_mix"]) * sky_scale, 0.0, 1.0)
	if _sky_mat != null:
		_sky_mat.set_shader_parameter(&"top", (_base["sky_top"] as Color).lerp(Color(String(p["sky_top"])), sky_mix))
		_sky_mat.set_shader_parameter(&"horizon", (_base["sky_horizon"] as Color).lerp(Color(String(p["sky_horizon"])), sky_mix))
		_sky_mat.set_shader_parameter(&"low", (_base["sky_low"] as Color).lerp(Color(String(p["sky_low"])), sky_mix))
		_sky_mat.set_shader_parameter(&"sun", float(_base["sky_sun"]) * float(p["sun_disc"]))
		_sky_mat.set_shader_parameter(&"stars", maxf(float(_base["sky_stars"]), float(p["stars"])))
		_sky_mat.set_shader_parameter(&"nebula", maxf(float(_base["sky_nebula"]), float(p["nebula"])))
	_rig[0].light_color = (_base["key_color"] as Color).lerp(Color(String(p["sun_color"])), float(p["sun_color_mix"]))
	_rig[0].light_energy = float(_base["key_energy"]) * float(p["sun_energy_mult"])
	_rig[1].light_color = (_base["fill_color"] as Color).lerp(Color(String(p["fill_color"])), float(p["fill_color_mix"]))
	_rig[1].light_energy = float(_base["fill_energy"]) * float(p["fill_energy_mult"])
	_rig[2].light_energy = float(_base["back_energy"]) * float(p["back_energy_mult"])
	_env.ambient_light_color = (_base["ambient_color"] as Color).lerp(Color(String(p["ambient_color"])), float(p["ambient_mix"]))
	_env.ambient_light_energy = float(_base["ambient_energy"]) * float(p["ambient_energy_mult"])
	_env.adjustment_saturation = float(_base["saturation"]) * float(p["saturation_mult"])
	_env.adjustment_brightness = float(_base["brightness"]) * float(p["brightness_mult"])
	_env.glow_intensity = float(_base["glow"]) * float(p["glow_mult"])
	var density: float = float(p["fog_density"])
	if density > 0.0:
		var fog: Color = Color(String(p["fog_color"]))
		if _accent.a > 0.0: fog = fog.lerp(Color(_accent, 1.0), 0.2)
		_set_fog(fog, density)
	_sun_pitch = float(p["sun_pitch_deg"])
	_sun_yaw = float(p["sun_yaw_deg"])
	_sun_override = absf(_sun_pitch - 50.0) > 0.01 or absf(_sun_yaw) > 0.01
	return float(p["lit_mult"])


func _set_fog(color: Color, density: float) -> void:
	_env.fog_enabled = true
	_env.fog_light_color = color
	_env.fog_density = density
	_env.fog_sky_affect = 0.0
	_env.fog_aerial_perspective = 0.0


# ------------------------------------------------------------------ dressing

func _apply_dressing(mode: String) -> void:
	var cfg: Dictionary = presets().get("dressing", {}).get(mode, {})
	var frac: float = float(cfg.get("rim_fraction", 1.0))
	if frac >= 0.999: return
	for r: Dictionary in _rim:
		var mm: MultiMesh = r["mm"] as MultiMesh
		if is_instance_valid(mm): mm.visible_instance_count = int(float(mm.instance_count) * frac)


# ------------------------------------------------------------------ set piece

func _build_set_piece(lit: float) -> void:
	var id: String = String(_look.get("set_piece", ""))
	if id.is_empty() or not WtSetPieceBuilder.has_piece(id): return
	_piece_side = String(_look.get("set_piece_side", "right"))
	if not SIDES.has(_piece_side): _piece_side = "right"
	var tint: String = String(WtIslandBuilder.new(_biome).preset().get("shadow_tint", "#6B5C9E"))
	var dressing_cfg: Dictionary = presets().get("dressing", {}).get(String(_look.get("dressing", "normal")), {})
	var opts: Dictionary = {"shadow_tint": tint, "motion": 0.0 if _reduced else 1.0, "islet_dressing": int(dressing_cfg.get("islet_dressing", 4))}
	if _accent.a > 0.0: opts["accent"] = "#" + _accent.to_html(false)
	_piece = WtSetPieceBuilder.build(id, opts)
	if _piece == null: return
	add_child(_piece)
	var lit_mat: ShaderMaterial = _piece.get_meta(&"lit_mat") as ShaderMaterial
	lit_mat.set_shader_parameter(&"hot", WtSetPieceBuilder.HOT * lit)
	_hide_builtin(id)
	_place_piece(rad_to_deg(atan2(_camera.position.x, _camera.position.z)) if _camera != null else 45.0)


## The stage's own hand-built landmarks would collide with a new one, so they step aside.
func _hide_builtin(id: String) -> void:
	var hide_keys: Array[String] = []
	if _biome == &"meadow": hide_keys.append("windmill")
	if id.ends_with("_ferris_wheel"): hide_keys.append("ferris")
	if id.ends_with("_carousel"): hide_keys.append("carousel")
	for key: String in hide_keys:
		var n: Node3D = _hide.get(key, null) as Node3D
		if n != null and is_instance_valid(n):
			n.visible = false
			_hidden.append(n)


## Camera-relative placement (screen right u, away-from-camera v) so the landmark never overlaps the
## board's island or the camera sight line, and keeps its side while the view rotates.
func _place_piece(yaw_deg: float) -> void:
	var layout: Dictionary = presets().get("set_piece_layout", {})
	var board_scale: float = float(maxi(_size.x, _size.z)) / 8.0
	var s: float = board_scale * float(_piece.get_meta(&"piece_scale", 1.0))
	var r: float = float(_piece.get_meta(&"radius", 2.4)) * s
	var reach: float = float(_size.x + _size.z) * 0.5 * 0.7071 + ISLAND_RING * DIAMOND
	var yaw: float = deg_to_rad(yaw_deg)
	var right: Vector3 = Vector3(cos(yaw), 0.0, -sin(yaw))
	var away: Vector3 = Vector3(-sin(yaw), 0.0, -cos(yaw))
	var sign_side: float = -1.0 if _piece_side == "left" else (1.0 if _piece_side == "right" else 0.0)
	var u: float = 0.0
	var v: float = 0.0
	if _piece_side == "back":
		v = reach + r * float(layout.get("back_gap", 1.1))
	else:
		v = reach * float(layout.get("side_v_fraction", 0.4))
		u = sign_side * (reach - v + r * DIAMOND + 0.3)
		if _camera != null and is_inside_tree():
			var half_w: float = _camera.size * get_viewport().get_visible_rect().size.aspect() * 0.5
			if half_w > r * 2.2:
				u = clampf(u, _camera.h_offset - half_w + r * 0.95, _camera.h_offset + half_w - r * 0.95)
	_piece.scale = Vector3.ONE * s
	_piece.position = right * u + away * v + Vector3(0.0, float(layout.get("islet_y", 0.5)), 0.0)
	_piece.rotation = Vector3(0.0, yaw - sign_side * deg_to_rad(float(layout.get("face_yaw_deg", 22.0))), 0.0)


# ------------------------------------------------------------------ weather

func _build_weather() -> void:
	var kind: String = String(_look.get("weather", "clear"))
	if _reduced or kind == "clear": return
	var cfg: Dictionary = presets().get("weather", {}).get(kind, {})
	if cfg.is_empty(): return
	var dressing_cfg: Dictionary = presets().get("dressing", {}).get(String(_look.get("dressing", "normal")), {})
	var span: float = maxf(1.0, float(maxi(_size.x, _size.z)) / 8.0)
	var p := CPUParticles3D.new()
	p.name = "Weather_" + kind
	p.amount = maxi(8, int(float(cfg["amount"]) * float(dressing_cfg.get("weather_mult", 1.0)) * span))
	p.lifetime = float(cfg["lifetime"])
	p.preprocess = float(cfg["lifetime"])
	p.fixed_fps = 30
	p.local_coords = false
	p.draw_order = CPUParticles3D.DRAW_ORDER_VIEW_DEPTH
	p.visibility_aabb = AABB(Vector3(-40, -30, -40), Vector3(80, 80, 80))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var box: Array = cfg["box"]
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(float(box[0]) * span, float(box[1]), float(box[2]) * span)
	p.position = _vec(cfg["center"])
	p.direction = _vec(cfg["direction"])
	p.spread = float(cfg["spread"])
	var speed: Array = cfg["speed"]
	p.initial_velocity_min = float(speed[0])
	p.initial_velocity_max = float(speed[1])
	p.gravity = _vec(cfg["gravity"])
	var size: Array = cfg["size"]
	p.scale_amount_min = float(size[0])
	p.scale_amount_max = float(size[1])
	var spin: Array = cfg.get("spin", [0.0, 0.0])
	p.angular_velocity_min = float(spin[0])
	p.angular_velocity_max = float(spin[1])
	p.angle_min = -180.0
	p.angle_max = 180.0
	if bool(cfg.get("twinkle", false)):
		var curve := Curve.new()
		curve.add_point(Vector2(0.0, 0.0))
		curve.add_point(Vector2(0.5, 1.0))
		curve.add_point(Vector2(1.0, 0.0))
		p.scale_amount_curve = curve
	# Fade in and out over the lifetime (colour ramp) and pick the tint per particle (initial ramp).
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.12, 0.8, 1.0])
	fade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	p.color_ramp = fade
	var colors: Array = cfg["colors"]
	var palette: Array[Color] = []
	for c: Variant in colors:
		var code: String = String(c)
		if code == "@accent": palette.append(_accent if _accent.a > 0.0 else Color("#FF9EC0"))
		else: palette.append(Color(code))
	p.color = Color(1, 1, 1, float(cfg.get("alpha", 1.0)))
	if palette.size() > 1:
		var pick := Gradient.new()
		var offs := PackedFloat32Array()
		var cols := PackedColorArray()
		for i: int in palette.size():
			offs.append(float(i) / float(palette.size()))
			cols.append(palette[i])
			if bool(cfg.get("discrete_colors", false)):
				pick.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
		pick.offsets = offs
		pick.colors = cols
		p.color_initial_ramp = pick
	else:
		p.color = Color(palette[0], float(cfg.get("alpha", 1.0)))
	var quad := QuadMesh.new()
	var dims: Array = cfg["mesh"]
	quad.size = Vector2(float(dims[0]), float(dims[1]))
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Dithered alpha stays in the opaque pass: the shared post-process quad (priority 127) is drawn last and would
	# paint over alpha-blended particles. Hash gives soft edges without a blend pass (Compatibility-safe).
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	mat.vertex_color_use_as_albedo = true
	mat.albedo_texture = _texture(String(cfg["texture"]))
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	quad.material = mat
	p.mesh = quad
	add_child(p)
	_weather = p
	var fog_add: float = float(cfg.get("fog_add", 0.0))
	if fog_add > 0.0:
		var color: Color = _env.fog_light_color if _env.fog_enabled else Color("#DDE6F4")
		_set_fog(color, (_env.fog_density if _env.fog_enabled else 0.0) + fog_add)


static func _vec(a: Variant) -> Vector3:
	var arr: Array = a
	return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))


## Soft procedural particle sprites (white + alpha, cached): soft, bubble, streak, star, petal, rect.
static func _texture(kind: String) -> Texture2D:
	if _textures.has(kind): return _textures[kind]
	var n: int = 64
	var img: Image = Image.create(n if kind != "streak" else 16, n, false, Image.FORMAT_RGBA8)
	for y: int in img.get_height():
		for x: int in img.get_width():
			var nx: float = (float(x) + 0.5) / float(img.get_width()) * 2.0 - 1.0
			var ny: float = (float(y) + 0.5) / float(n) * 2.0 - 1.0
			var d: float = sqrt(nx * nx + ny * ny)
			var a: float = 0.0
			match kind:
				"soft":
					a = pow(clampf(1.0 - d, 0.0, 1.0), 1.6)
				"bubble":
					a = smoothstep(0.7, 0.88, d) * (1.0 - smoothstep(0.9, 1.0, d)) * 0.95
					a += (1.0 - smoothstep(0.0, 0.9, d)) * 0.07
					var h: float = sqrt((nx + 0.38) * (nx + 0.38) + (ny + 0.38) * (ny + 0.38))
					a += (1.0 - smoothstep(0.08, 0.2, h)) * 0.9 * (1.0 if d <= 0.85 else 0.0)
				"streak":
					a = pow(clampf(1.0 - absf(nx), 0.0, 1.0), 2.0) * sin(clampf((ny + 1.0) * 0.5, 0.0, 1.0) * PI)
				"star":
					var q: float = sqrt(absf(nx)) + sqrt(absf(ny))
					a = pow(clampf(1.0 - q, 0.0, 1.0), 1.5) * 1.6 + pow(clampf(1.0 - d * 1.6, 0.0, 1.0), 2.0)
				"petal":
					var w: float = 0.62 * sqrt(clampf(1.0 - ny * ny, 0.0, 1.0)) * (1.0 - 0.3 * ny)
					a = 1.0 - smoothstep(w - 0.12, w, absf(nx))
					a *= 1.0 - 0.35 * clampf(1.0 - absf(nx) / 0.12, 0.0, 1.0) * 0.5
				_:
					a = 1.0 - smoothstep(0.82, 1.0, maxf(absf(nx), absf(ny)))
			img.set_pixel(x, y, Color(1, 1, 1, clampf(a, 0.0, 1.0)))
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_textures[kind] = tex
	return tex
