extends RefCounted
## Style R&D shared kit: the ONE environment preset and ONE light rig every scene uses,
## plus a procedural rounded-box mesh and the painted material. Prototype code (relaxed rules).
## Values are mirrored in design/art/style-techniques.md §2 (keep them in sync).

const BLOCK_SHADER := preload("res://prototypes/style_rnd/spatial_proto_painted_block.gdshader")
const SKY_SHADER := preload("res://prototypes/style_rnd/sky_proto_painted.gdshader")

## Biome presets: key light colour/energy, fill, ambient, sky and fog colours.
const PRESETS := {
	"meadow": {"key": Color("fff0d6"), "key_e": 0.9, "fill": Color("b8c4ff"), "fill_e": 0.2,
		"back": Color("ffe0a8"), "back_e": 0.3, "amb": Color("c9c3e6"), "amb_e": 0.42,
		"sky_top": Color("6fa8ea"), "sky_hor": Color("fde8cc"), "sky_low": Color("d9e4f7"),
		"fog": Color("dfe6f6"), "fog_d": 0.012, "sat": 1.12, "con": 1.06, "bri": 1.02},
	"ice": {"key": Color("f2f6ff"), "key_e": 0.95, "fill": Color("a9c8ff"), "fill_e": 0.3,
		"back": Color("e8d8ff"), "back_e": 0.3, "amb": Color("c4d2f2"), "amb_e": 0.5,
		"sky_top": Color("8fb2e8"), "sky_hor": Color("eef0ff"), "sky_low": Color("dfe8fb"),
		"fog": Color("e6ecfa"), "fog_d": 0.014, "sat": 1.05, "con": 1.04, "bri": 1.03},
	"celestial": {"key": Color("e9dcff"), "key_e": 0.85, "fill": Color("8a7cff"), "fill_e": 0.35,
		"back": Color("ffd890"), "back_e": 0.45, "amb": Color("6a5a9e"), "amb_e": 0.5,
		"sky_top": Color("140f3a"), "sky_hor": Color("4b2f86"), "sky_low": Color("23184f"),
		"fog": Color("3a2a6e"), "fog_d": 0.01, "sat": 1.15, "con": 1.08, "bri": 1.0},
}

static func make_environment(biome := "meadow", tonemap := Environment.TONE_MAPPER_AGX) -> Environment:
	var p: Dictionary = PRESETS[biome]
	var env := Environment.new()
	var sky_mat := ShaderMaterial.new()
	sky_mat.shader = SKY_SHADER
	sky_mat.set_shader_parameter("top", p.sky_top)
	sky_mat.set_shader_parameter("horizon", p.sky_hor)
	sky_mat.set_shader_parameter("low", p.sky_low)
	var sky := Sky.new(); sky.sky_material = sky_mat
	sky.radiance_size = Sky.RADIANCE_SIZE_32
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	# Ambient: flat art-directed colour (deterministic, identical on every renderer).
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = p.amb
	env.ambient_light_energy = p.amb_e
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = tonemap
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0
	# Glow: only emissives and specular glints should bloom (threshold ~1.0 HDR).
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_strength = 1.0
	env.glow_bloom = 0.04
	env.glow_hdr_threshold = 0.95
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.set_glow_level(0, 0.0); env.set_glow_level(1, 0.0); env.set_glow_level(2, 1.0)
	env.set_glow_level(3, 1.0); env.set_glow_level(4, 0.6)
	# Aerial perspective: distant islands melt into a lavender-blue haze.
	env.fog_enabled = true
	env.fog_light_color = p.fog
	env.fog_density = p.fog_d
	env.fog_sky_affect = 0.0
	env.fog_aerial_perspective = 0.0
	# Grading: a touch more saturation and contrast = the "premium mobile" punch.
	env.adjustment_enabled = true
	env.adjustment_saturation = p.sat
	env.adjustment_contrast = p.con
	env.adjustment_brightness = p.bri
	return env

## Three-light rig: warm key (top-left-front, shadows), cool fill (opposite, no shadow),
## warm back/rim (behind, no shadow). Angles are relative to the camera yaw so every screen
## gets the same light direction on screen: light always comes from the upper-left.
static func add_light_rig(parent: Node3D, biome := "meadow", cam_yaw_deg := 45.0) -> Array:
	var p: Dictionary = PRESETS[biome]
	var key := DirectionalLight3D.new(); key.name = "Key"
	key.light_color = p.key; key.light_energy = p.key_e
	key.rotation_degrees = Vector3(-50.0, cam_yaw_deg - 75.0, 0.0)
	key.shadow_enabled = true
	key.shadow_opacity = 0.7          # shadows stay coloured, never black
	key.shadow_blur = 1.5
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 40.0
	key.light_angular_distance = 1.5
	var fill := DirectionalLight3D.new(); fill.name = "Fill"
	fill.light_color = p.fill; fill.light_energy = p.fill_e
	fill.rotation_degrees = Vector3(-20.0, cam_yaw_deg + 105.0, 0.0)
	var back := DirectionalLight3D.new(); back.name = "Back"
	back.light_color = p.back; back.light_energy = p.back_e
	back.rotation_degrees = Vector3(-20.0, cam_yaw_deg + 180.0 + 10.0, 0.0)
	for l in [key, fill, back]: parent.add_child(l)
	return [key, fill, back]

## cam_yaw_deg = rad_to_deg(atan2(cam.x - target.x, cam.z - target.z)).
## Rounded box ("chunky") mesh: cube grid pushed onto a box with radius r. Smooth normals.
static func rounded_box(size := Vector3.ONE, r := 0.12, n := 14) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := Vector3(0.5, 0.5, 0.5)
	var inner := half - Vector3(r, r, r) / size  # in unit space, radius stays round after scaling
	var faces := [
		[Vector3.RIGHT, Vector3.BACK, Vector3.UP], [Vector3.LEFT, Vector3.FORWARD, Vector3.UP],
		[Vector3.UP, Vector3.RIGHT, Vector3.BACK], [Vector3.DOWN, Vector3.RIGHT, Vector3.FORWARD],
		[Vector3.BACK, Vector3.RIGHT, Vector3.UP], [Vector3.FORWARD, Vector3.LEFT, Vector3.UP]]
	for f in faces:
		var nrm: Vector3 = f[0]; var u: Vector3 = f[1]; var v: Vector3 = f[2]
		var grid := []
		for j in n + 1:
			var row := []
			for i in n + 1:
				# cluster samples near the edges so the rounding is smooth
				var a := _ease(float(i) / n) - 0.5
				var b := _ease(float(j) / n) - 0.5
				var q: Vector3 = nrm * 0.5 + u * a + v * b
				var c := q.clamp(-inner, inner)
				var d := (q - c) * size
				var dn := d.normalized() if d.length() > 0.00001 else nrm
				var pos := c * size + dn * r
				row.append([pos, dn, Vector2(a + 0.5, b + 0.5)])
			grid.append(row)
		# Godot front faces are clockwise: cross(p1-p0, p2-p0) must point INTO the mesh.
		var flip: bool = u.cross(v).dot(nrm) > 0.0
		for j in n:
			for i in n:
				var q00 = grid[j][i]; var q10 = grid[j][i + 1]; var q01 = grid[j + 1][i]; var q11 = grid[j + 1][i + 1]
				var tris := [q00, q11, q10, q00, q01, q11] if flip else [q00, q10, q11, q00, q11, q01]
				for t in tris:
					st.set_normal(t[1]); st.set_uv(t[2]); st.add_vertex(t[0])
	st.index()
	return st.commit()

static func _ease(t: float) -> float:
	# denser near 0 and 1
	return 0.5 - 0.5 * cos(t * PI) if true else t

static func painted_material(params := {}) -> ShaderMaterial:
	var m := ShaderMaterial.new(); m.shader = BLOCK_SHADER
	for k in params: m.set_shader_parameter(k, params[k])
	return m

## Generic "painted prop" material (leaves, flowers, rock): body only, no cap, no pebbles.
static func prop_material(c: Color, dark: Color, extra := {}) -> ShaderMaterial:
	var d := {"body_color": c, "body_dark": dark, "cap_y": 2.0, "pebbles": 0.0, "strata": 0.0,
		"ao_strength": 0.2, "edge_light": 0.25, "paint_scale": 5.0}
	d.merge(extra, true)
	return painted_material(d)

static func snap(vp: Viewport, path: String) -> void:
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	img.save_png(path)
	print("SNAP ", path, " ", img.get_size(), " method=", RenderingServer.get_current_rendering_method())

# ---------------- UI helpers (no import step needed; works from -s scripts) ----------------
static func load_tex(res_path: String, size_px := 0) -> ImageTexture:
	var img := Image.load_from_file(ProjectSettings.globalize_path(res_path))
	if size_px > 0: img.resize(size_px, size_px, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)

static func load_font(res_path: String) -> FontFile:
	var f := FontFile.new(); f.load_dynamic_font(ProjectSettings.globalize_path(res_path))
	return f

## Nine-patch from the Blender render. size_px = texture edge after downscale; margin scales with it.
static func frame_patch(tex: Texture2D, margin_src: int, src_px: int, draw_center := true) -> NinePatchRect:
	var np := NinePatchRect.new(); np.texture = tex
	var m := int(round(float(margin_src) * tex.get_width() / src_px))
	np.patch_margin_left = m; np.patch_margin_top = m; np.patch_margin_right = m; np.patch_margin_bottom = m
	np.draw_center = draw_center
	return np

## Multicolour chunky title: each letter its own colour, a stacked dark "extrusion" (6 layers),
## a thick plum outline, a lighter top highlight and a slight per-letter wobble.
const LETTER_COLORS := [Color("f08a2c"), Color("f6e2b8"), Color("4aa8e8"), Color("6cc04a"), Color("b48ad8"), Color("ee6aa0")]
static func title_text(text: String, font: Font, size := 96, depth := 7) -> Control:
	var box := Control.new()
	var x := 0.0
	var i := 0
	for ch in text:
		if ch == " ": x += size * 0.35; continue
		var col: Color = LETTER_COLORS[i % LETTER_COLORS.size()]; i += 1
		var holder := Control.new(); holder.position = Vector2(x, 0)
		holder.rotation_degrees = [-4.0, 3.0, -2.0, 4.0, -3.0, 2.0][i % 6]
		holder.pivot_offset = Vector2(size * 0.35, size * 0.6)
		for d in range(depth, -1, -1):
			var l := Label.new(); l.text = ch
			var ls := LabelSettings.new(); ls.font = font; ls.font_size = size
			ls.outline_size = int(size * 0.16); ls.outline_color = Color("3b2346")
			if d > 0:
				ls.font_color = col.darkened(0.45)
				if d == depth:
					ls.shadow_color = Color(0.1, 0.03, 0.15, 0.45); ls.shadow_offset = Vector2(0, size * 0.06); ls.shadow_size = int(size * 0.08)
			else:
				ls.font_color = col
			l.label_settings = ls; l.position = Vector2(0, d * size * 0.012)
			holder.add_child(l)
		# top highlight sliver: same glyph, lighter, clipped to the upper part
		var clip := Control.new(); clip.clip_contents = true; clip.size = Vector2(size, size * 0.62)
		var hl := Label.new(); hl.text = ch
		var hs := LabelSettings.new(); hs.font = font; hs.font_size = size; hs.font_color = col.lightened(0.3)
		hl.label_settings = hs; hl.position = Vector2(0, -size * 0.02)
		clip.add_child(hl); holder.add_child(clip)
		box.add_child(holder)
		x += font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * 0.96
	box.custom_minimum_size = Vector2(x, size * 1.3)
	box.size = box.custom_minimum_size
	return box

static func label(text: String, font: Font, size: int, col := Color("3b2346"), outline := 0, ocol := Color("3b2346")) -> Label:
	var l := Label.new(); l.text = text
	var ls := LabelSettings.new(); ls.font = font; ls.font_size = size; ls.font_color = col
	ls.outline_size = outline; ls.outline_color = ocol
	l.label_settings = ls
	return l
