// spatial_env_island: floating-island top surface and procedural fallback underside (technical art, 2026-10-13).
// Target: Mobile / Compatibility. Vertex colours carry the biome bands from WtIslandBuilder.
// The top is painted with the shared Poly Haven detail map (B = leafy_grass) plus mottling and
// accent speckles; the fallback underside (used only when env_island_underside.glb is missing)
// gets seam-free strata. Back faces are culled: the builder emits consistent winding.
shader_type spatial;
render_mode cull_back, diffuse_burley;

group_uniforms look;
/** Biome style id (same table as spatial_block_biome). */
uniform int style = 1;
/** Accent colour for small speckles (flowers, embers, crystals). */
uniform vec3 accent : source_color = vec3(1.0, 0.9, 0.4);
/** Strength of the large-scale colour mottling. */
uniform float mottle : hint_range(0.0, 0.5) = 0.16;
/** Shared detail map (R cliff, G stone, B grass, A displacement). */
uniform sampler2D detail : hint_default_white, repeat_enable, filter_linear_mipmap;
uniform float detail_strength : hint_range(0.0, 1.0) = 0.4;
/** Density of accent speckles on the top (0 = none). */
uniform float speckle : hint_range(0.0, 0.1) = 0.03;
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
	bool top_face = wp.y > -0.07;
	if (top_face) {
		col *= 1.0 - mottle + 2.0 * mottle * fbm(wp.xz * 0.9);
		col *= mix(1.0, 0.7 + 0.6 * texture(detail, wp.xz * 0.45).b, detail_strength);
		// Tiny speckles: flowers on grass, embers on lava, glints on ice.
		float speck = step(1.0 - speckle, hash21(floor(wp.xz * 6.0)));
		col = mix(col, accent, speck * 0.7);
	} else {
		// Seam-free strata: planar noise on x and z blended by the facing direction.
		float sx = fbm(vec2(wp.x * 1.5, wp.y * 2.4));
		float sz = fbm(vec2(wp.z * 1.5, wp.y * 2.4));
		float strata = mix(sx, sz, abs(normalize(cross(dFdx(wp), dFdy(wp))).x));
		col *= 0.8 + 0.4 * strata;
		col *= 0.85 + 0.15 * step(0.5, fract(wp.y * 1.3 + strata * 0.6));
		if (style == 5) {
			float vein = 1.0 - smoothstep(0.0, 0.06, abs(fbm(vec2(wp.x + wp.z, wp.y * 1.5)) - 0.5));
			col = mix(col, vec3(1.0, 0.45, 0.1), vein * 0.9);
			EMISSION = vec3(1.0, 0.4, 0.08) * vein * 1.5;
		}
	}
	ALBEDO = col;
	ROUGHNESS = 0.9;
}
