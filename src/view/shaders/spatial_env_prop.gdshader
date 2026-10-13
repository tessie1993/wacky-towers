// spatial_env_prop: island dressing props drawn as one MultiMesh per kind (technical art, 2026-10-13).
// Meshes: assets/models/env/prop_*.glb (assets/source/blender/env/build_env_kit.py).
// Vertex colour contract: RGB = sRGB albedo with AO baked in, A = tint mask (1 = multiplied by the
// per-instance biome tint, 0 = fixed colour).
// Per-instance data: INSTANCE_CUSTOM.rgb = linear tint, INSTANCE_CUSTOM.a = phase 0..1
// (MultiMesh.use_custom_data must be on). No textures, no discard.
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms look;
/** Emission of the tinted region (crystals, glowing mushrooms, neon). > 1 blooms with glow. */
uniform float emission_strength : hint_range(0.0, 8.0) = 0.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.8;
/** Soft sky rim on upward/silhouette edges. */
uniform vec3 rim_color : source_color = vec3(1.0, 0.97, 0.9);
uniform float rim : hint_range(0.0, 1.0) = 0.12;
group_uniforms;

group_uniforms motion;
/** Wind/current sway in metres at 1 m height (kelp, trees). */
uniform float sway : hint_range(0.0, 0.5) = 0.0;
/** Spin in radians per second about the local Y axis (gears). Direction alternates per instance. */
uniform float spin = 0.0;
/** 0 under reduced motion. */
uniform float motion : hint_range(0.0, 1.0) = 1.0;
group_uniforms;

varying vec3 tint;

void vertex() {
	tint = INSTANCE_CUSTOM.rgb;
	float phase = INSTANCE_CUSTOM.a * 6.2831853;
	if (spin != 0.0) {
		float a = TIME * spin * motion * (INSTANCE_CUSTOM.a > 0.5 ? 1.0 : -1.0) + phase;
		mat2 r = mat2(vec2(cos(a), sin(a)), vec2(-sin(a), cos(a)));
		VERTEX.xz = r * VERTEX.xz;
		NORMAL.xz = r * NORMAL.xz;
	}
	if (sway > 0.0) {
		float h = max(VERTEX.y, 0.0);
		float k = sway * h * h * motion;
		VERTEX.x += sin(TIME * 1.3 + phase) * k;
		VERTEX.z += cos(TIME * 1.05 + phase * 1.7) * k * 0.6;
	}
}

void fragment() {
	vec3 base = pow(COLOR.rgb, vec3(2.2));
	float mask = COLOR.a;
	vec3 col = base * mix(vec3(1.0), tint, mask);
	ALBEDO = col;
	ROUGHNESS = roughness_value;
	vec3 wn = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = col * emission_strength * mask + rim_color * fres * rim * smoothstep(-0.2, 0.7, wn.y);
}
