// spatial_env_island: floating-island ground and rocky underside (technical art, 2026-10-13).
// Vertex colours carry the biome bands from WtIslandBuilder; this adds painterly mottling,
// rock strata and a soft grass/snow lip. Target: Mobile renderer; no textures, cheap noise.
shader_type spatial;
render_mode cull_disabled, diffuse_burley;

group_uniforms look;
/** Biome style id (same table as spatial_block_biome). */
uniform int style = 1;
/** Accent colour for small speckles (flowers, embers, crystals). */
uniform vec3 accent : source_color = vec3(1.0, 0.9, 0.4);
/** Strength of the large-scale colour mottling. */
uniform float mottle : hint_range(0.0, 0.5) = 0.18;
group_uniforms;

varying vec3 wp;

float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vnoise(p) * 0.55 + vnoise(p * 2.1) * 0.3 + vnoise(p * 4.3) * 0.15; }

void vertex() { wp = VERTEX; }

void fragment() {
	vec3 col = COLOR.rgb;
	bool top_face = wp.y > -0.06;
	if (top_face) {
		col *= 1.0 - mottle + 2.0 * mottle * fbm(wp.xz * 0.9);
		// Tiny speckles: flowers on grass, embers on lava, glints on ice.
		float speck = step(0.975, hash21(floor(wp.xz * 6.0)));
		col = mix(col, accent, speck * 0.7);
	} else {
		// Horizontal rock strata broken up by noise, darker towards the tip.
		float strata = fbm(vec2(atan(wp.z, wp.x) * 3.0, wp.y * 2.4));
		col *= 0.8 + 0.4 * strata;
		col *= 0.85 + 0.15 * step(0.5, fract(wp.y * 1.3 + strata * 0.6));
		if (style == 5) {
			float vein = 1.0 - smoothstep(0.0, 0.06, abs(fbm(vec2(atan(wp.z, wp.x) * 4.0, wp.y * 1.5)) - 0.5));
			col = mix(col, vec3(1.0, 0.45, 0.1), vein * 0.9);
			EMISSION = vec3(1.0, 0.4, 0.08) * vein * 1.5;
		}
	}
	ALBEDO = col;
	ROUGHNESS = 0.9;
}
