// spatial_env_rock: island strata bands, distant island undersides and hanging rock.
// Paints chunky stacked rock blocks (offset rows, dark seams, per-block value jitter, lit top
// lip), a cover dusting on upward faces (snow, moss, frosting) and optional lava cracks.
// Coordinates are world-relative to the node origin, so non-uniform node scale is fine.
// Recipe: design/art/style-techniques.md §5.1 (production upgrade: rock blocks). ~5 noise taps.
shader_type spatial;
render_mode cull_back;
#include "res://src/view/shaders/env_painted.gdshaderinc"

uniform vec3 body_color : source_color = vec3(0.63, 0.46, 0.31);
uniform vec3 body_dark : source_color = vec3(0.42, 0.29, 0.2);
/** Cover colour on upward faces (snow, moss) and amount. */
uniform vec3 cover_color : source_color = vec3(0.36, 0.62, 0.22);
uniform float cover : hint_range(0.0, 1.0) = 0.0;
/** Rock block size (arc length, height) and seam darkness. */
uniform vec2 block = vec2(1.1, 0.55);
uniform float seam : hint_range(0.0, 1.0) = 0.6;
uniform float seed = 0.0;
uniform vec3 glow_color : source_color = vec3(1.0, 0.42, 0.1);
uniform float glow : hint_range(0.0, 4.0) = 0.0;

varying vec3 rel;
varying vec3 wn;

void vertex() {
	rel = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz - MODEL_MATRIX[3].xyz;
	wn = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

void fragment() {
	vec3 n = normalize(wn);
	float arc = atan(rel.z, rel.x) * max(length(rel.xz), 0.6);
	vec2 uv = vec2(arc, rel.y);
	float paint = wt_fbm(uv * 1.3 + seed);
	vec3 col = mix(body_dark, body_color, smoothstep(0.25, 0.75, paint));
	float row = floor(rel.y / block.y + seed);
	float cx = arc / block.x + wt_h21(vec2(row, seed + 1.0)) * 3.0 + paint * 0.3;
	vec2 g = vec2(fract(cx), fract(rel.y / block.y + seed));
	float s = min(min(g.x, 1.0 - g.x) * block.x, min(g.y, 1.0 - g.y) * block.y);
	col *= 0.88 + 0.24 * wt_h21(vec2(floor(cx), row));
	col *= 1.0 + smoothstep(0.72, 0.92, g.y) * 0.16;
	col *= 1.0 - (1.0 - smoothstep(0.015, 0.06, s)) * 0.5 * seam;
	col = mix(col, cover_color, smoothstep(0.45, 0.75, n.y) * cover);
	vec3 em = vec3(0.0);
	if (glow > 0.0) {
		float crack = (1.0 - smoothstep(0.0, 0.05, s)) * smoothstep(0.4, 0.7, wt_vn(uv * 0.8 + 5.0));
		col = mix(col, glow_color, crack * 0.7);
		em = glow_color * crack * glow;
	}
	ALBEDO = col;
	ROUGHNESS = 0.9;
	EMISSION = em;
	FOG = vec4(haze_color, haze);
}
