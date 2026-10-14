// spatial_env_island: floating-island top slab (rounded box) with the biome cap, painted body,
// strata, pebbles, under-cap contact AO, lit rim edge, optional gold inlay and lava cracks.
// Recipe: design/art/style-techniques.md §3.2 + §5.1. Local-space painting (VERTEX), so one
// material per slab. Cost: ~6 value-noise taps. Target: Compatibility / Mobile / Forward+.
shader_type spatial;
render_mode cull_back;
#include "res://src/view/shaders/env_painted.gdshaderinc"

group_uniforms shape;
/** Half extents of the slab mesh (local units). */
uniform vec3 half_size = vec3(5.25, 0.45, 5.25);
/** Corner radius of the rounded box. */
uniform float radius = 0.35;
uniform float seed = 0.0;
group_uniforms cap;
uniform vec3 cap_color : source_color = vec3(0.36, 0.62, 0.22);
uniform vec3 cap_light : source_color = vec3(0.61, 0.84, 0.37);
uniform vec3 cap_dark : source_color = vec3(0.18, 0.42, 0.14);
/** Cap depth down the side from the top (local units). */
uniform float cap_depth : hint_range(0.0, 1.0) = 0.14;
/** Ragged drip of the cap edge (strands + lobes). */
uniform float cap_drip : hint_range(0.0, 0.5) = 0.12;
group_uniforms body;
uniform vec3 body_color : source_color = vec3(0.63, 0.46, 0.31);
uniform vec3 body_dark : source_color = vec3(0.42, 0.29, 0.2);
uniform float paint_scale = 1.2;
uniform float strata : hint_range(0.0, 1.0) = 1.0;
uniform float pebbles : hint_range(0.0, 1.0) = 1.0;
uniform float edge_light : hint_range(0.0, 1.0) = 0.25;
group_uniforms extras;
/** Gold inlay ring around the board (celestial). half extents of the board + gap. */
uniform vec3 inlay_color : source_color = vec3(0.89, 0.76, 0.42);
uniform float inlay : hint_range(0.0, 1.0) = 0.0;
uniform vec2 inlay_half = vec2(4.1, 4.1);
/** Emissive cracks on the sides (lava); > 1 blooms. */
uniform vec3 glow_color : source_color = vec3(1.0, 0.42, 0.1);
uniform float glow : hint_range(0.0, 4.0) = 0.0;

varying vec3 lp;
varying vec3 ln;

void vertex() { lp = VERTEX; ln = NORMAL; }

void fragment() {
	vec3 n = normalize(ln);
	float up = n.y;
	vec2 side_uv = abs(n.x) > abs(n.z) ? vec2(lp.z, lp.y) : vec2(lp.x, lp.y);
	float paint = wt_fbm((up > 0.6 ? lp.xz : side_uv) * paint_scale + seed * 3.7);
	vec3 col = mix(body_dark, body_color, smoothstep(0.25, 0.75, paint));
	col *= 1.0 + (step(0.5, fract(lp.y * 2.6 + paint * 0.5)) - 0.5) * 0.14 * strata;
	// Pebbles: hashed round cells, lit top-left, sides only.
	vec2 pc = side_uv * 3.0 + seed;
	vec2 cell = floor(pc);
	vec2 off = (vec2(wt_h21(cell + 3.0), wt_h21(cell + 7.0)) - 0.5) * 0.4;
	float pd = length(fract(pc) - 0.5 - off);
	float peb = step(0.72, wt_h21(cell)) * (1.0 - smoothstep(0.15, 0.19, pd)) * pebbles * step(up, 0.6);
	col = mix(col, body_color * 1.3 + 0.04, peb);
	// Cap mask with a ragged drip (fine strands + big lobes).
	float d = half_size.y - lp.y;
	float around = atan(lp.z, lp.x) * (half_size.x + half_size.z) * 0.5;
	float drip = wt_vn(vec2(around * 7.0, 1.3)) * cap_drip * 0.45 + wt_fbm(vec2(around * 1.1, 4.0)) * cap_drip;
	float cap_end = cap_depth + drip;
	float cap = max(1.0 - smoothstep(cap_end - 0.012, cap_end + 0.012, d), step(0.55, up)) * step(0.001, cap_depth + cap_drip);
	vec2 cuv = up > 0.55 ? lp.xz : vec2(around, lp.y * 2.0);
	vec3 capc = mix(cap_dark, cap_color, smoothstep(0.2, 0.7, wt_fbm(cuv * 2.2 + seed)));
	capc = mix(capc, cap_light, smoothstep(0.55, 0.8, wt_fbm(cuv * 4.0 + 7.0)) * clamp(up + 0.3, 0.0, 1.0) * 0.75);
	float contact = (1.0 - smoothstep(0.0, 0.08, d - cap_end)) * step(cap_end, d);
	col *= 1.0 - contact * 0.45 * step(0.001, cap_depth + cap_drip);
	col = mix(col, capc, cap);
	// Painted lit edge on the top rim (per-axis rounding zone).
	vec3 e3 = clamp((abs(lp) - (half_size - vec3(radius))) / radius, 0.0, 1.0);
	col = mix(col, col * 1.25 + 0.03, max(e3.x, e3.z) * e3.y * edge_light);
	// Bottom AO.
	col *= mix(1.0, smoothstep(-half_size.y, -half_size.y * 0.2, lp.y), 0.35);
	vec3 em = vec3(0.0);
	if (inlay > 0.0) {
		float q = max(abs(lp.x) - inlay_half.x, abs(lp.z) - inlay_half.y);
		float ring = (1.0 - smoothstep(0.035, 0.06, abs(q - 0.07))) * step(0.6, up) * inlay;
		col = mix(col, inlay_color, ring);
		em += inlay_color * ring * 0.35;
	}
	if (glow > 0.0) {
		float v = abs(wt_fbm(side_uv * 1.6 + 2.0) - 0.5);
		float crack = (1.0 - smoothstep(0.0, 0.03, v)) * (1.0 - cap) * step(up, 0.6);
		col = mix(col, glow_color, crack * 0.6);
		em += glow_color * crack * glow;
	}
	ALBEDO = col;
	ROUGHNESS = 0.85;
	EMISSION = em;
	FOG = vec4(haze_color, haze);
}
