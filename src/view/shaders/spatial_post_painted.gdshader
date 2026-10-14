shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_disabled, fog_disabled, shadows_disabled;
// spatial_post_painted.gdshader: the shared painted finish (design/art/style-techniques.md 1.1).
// One full-screen quad (POSITION override, parented to the ortho camera) that works on
// Compatibility, Mobile and Forward+. Single pass, 8 depth taps + 4 mip-chain colour taps:
//   - depth-aware ink outline (inner edges only; silhouettes against the sky are left clean)
//   - screen-space contact AO (depth based, fills crevices where blocks meet tiles)
//   - mip-chain soft bloom on bright/emissive pixels (adds to the Environment glow)
//   - depth haze + mip-blur "depth of field" for the far floating islands
//   - warm grade (lift shadows, warm mids) and a gentle vignette
// All uniforms are fed from biome_looks.json biomes.<id>.post by WtPostProcess.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;

group_uniforms outline;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.3;
uniform vec3 outline_color : source_color = vec3(0.23, 0.14, 0.27);
uniform float outline_threshold : hint_range(0.01, 4.0) = 0.35;
uniform float outline_width : hint_range(0.5, 4.0) = 1.0;
group_uniforms ao;
uniform float ao_strength : hint_range(0.0, 1.0) = 0.35;
uniform float ao_radius : hint_range(1.0, 24.0) = 6.0;
uniform float ao_range : hint_range(0.1, 6.0) = 1.5;
uniform vec3 ao_tint : source_color = vec3(0.35, 0.28, 0.5);
group_uniforms bloom;
uniform float bloom_strength : hint_range(0.0, 2.0) = 0.25;
uniform float bloom_threshold : hint_range(0.0, 4.0) = 0.9;
uniform vec3 bloom_tint : source_color = vec3(1.0, 0.85, 0.65);
group_uniforms haze;
uniform float focus_depth = 35.0;
uniform float haze_start = 6.0; // distance behind the focus plane where haze begins
uniform float haze_range = 40.0;
uniform float haze_strength : hint_range(0.0, 1.0) = 0.3;
uniform vec3 haze_color : source_color = vec3(0.8, 0.88, 0.98);
uniform float dof_strength : hint_range(0.0, 6.0) = 2.0;
group_uniforms grade;
uniform vec3 warm_tint : source_color = vec3(1.04, 1.0, 0.94);
uniform float shadow_lift : hint_range(0.0, 0.2) = 0.02;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.25;
uniform float vignette_radius : hint_range(0.3, 1.5) = 0.85;
uniform vec3 vignette_color : source_color = vec3(0.2, 0.1, 0.25);
group_uniforms;

// Linear view-space distance from the depth buffer. Works for the orthographic stage camera and
// for perspective cameras; reversed-Z (Forward+/Mobile) is handled by INV_PROJECTION_MATRIX.
float view_dist(vec2 uv, mat4 inv_proj) {
	float d = texture(depth_texture, uv).x;
#if defined(RENDERER_COMPATIBILITY)
	vec3 ndc = vec3(uv * 2.0 - 1.0, d * 2.0 - 1.0);
#else
	vec3 ndc = vec3(uv * 2.0 - 1.0, d);
#endif
	vec4 v = inv_proj * vec4(ndc, 1.0);
	return -(v.z / v.w);
}

void vertex() {
	// Full-screen triangle-pair; z 0.5 stays inside the clip volume on every renderer.
	POSITION = vec4(VERTEX.xy, 0.5, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = 1.0 / vec2(textureSize(screen_texture, 0));
	float zc = view_dist(uv, INV_PROJECTION_MATRIX);
	// Sky/backdrop pixels have no geometry: depth sits on the far plane.
	// The stage camera far plane is 150: anything beyond ~140 is backdrop.
	float is_geo = 1.0 - step(140.0, zc);

	// 8 depth taps: a ring at the AO radius and a ring at the outline width.
	float edge = 0.0;
	float occl = 0.0;
	for (int i = 0; i < 8; i++) {
		float a = float(i) * 0.785398;
		vec2 dir = vec2(cos(a), sin(a));
		float zn = view_dist(uv + dir * px * ao_radius, INV_PROJECTION_MATRIX);
		// Neighbour clearly nearer than us (but not a whole other object): occludes this pixel.
		float dz = zc - zn;
		occl += clamp(dz / ao_range, 0.0, 1.0) * (1.0 - smoothstep(ao_range * 1.2, ao_range * 4.0, dz));
		float zo = view_dist(uv + dir * px * outline_width, INV_PROJECTION_MATRIX);
		edge = max(edge, smoothstep(outline_threshold, outline_threshold * 2.5, zc - zo));
	}
	occl = clamp(occl / 8.0 * 2.0, 0.0, 1.0) * is_geo;
	edge *= is_geo;

	// Depth of field: mip-chain blur grows with distance behind the focus plane.
	float behind = max(zc - focus_depth, 0.0);
	float blur_t = clamp(behind / haze_range, 0.0, 1.0);
	float lod = dof_strength * blur_t * blur_t * 3.0;
	vec3 col = textureLod(screen_texture, uv, lod).rgb;

	// Soft bloom: bright-pass of two wide mips (cheap, already blurred by the mip chain).
	vec3 b1 = textureLod(screen_texture, uv, 3.0).rgb;
	vec3 b2 = textureLod(screen_texture, uv, 5.0).rgb;
	vec3 bl = max(b1 - vec3(bloom_threshold), vec3(0.0)) * 0.6 + max(b2 - vec3(bloom_threshold), vec3(0.0)) * 0.9;
	col += bl * bloom_strength * bloom_tint;

	// Painted contact AO in a purple shadow tint (never grey), then the ink line.
	col = mix(col, col * ao_tint * 1.6, occl * ao_strength);
	col = mix(col, outline_color * (0.6 + 0.4 * length(col)), edge * outline_strength);

	// Aerial perspective: far islands go paler, bluer, lower contrast.
	float haze = smoothstep(haze_start, haze_start + haze_range, behind) * haze_strength;
	col = mix(col, haze_color, haze * is_geo);

	// Warm grade: lift shadows, warm mids.
	col = col * warm_tint + vec3(shadow_lift) * (1.0 - clamp(col, 0.0, 1.0));

	// Vignette with a plum tint.
	vec2 vc = (uv - 0.5) * vec2(1.0, 1.15);
	float vig = smoothstep(vignette_radius * 0.45, vignette_radius, length(vc));
	col = mix(col, col * vignette_color * 2.2, vig * vignette_strength);

	ALBEDO = col;
}
