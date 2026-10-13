// canvas_env_sky: painted sky backdrop behind the 3D board (technical art, 2026-10-13).
// Gradient + soft drifting clouds + distant floating-island silhouettes; stars at night.
// Drawn on a CanvasLayer used as the Environment background (BG_CANVAS). Target: Mobile.
shader_type canvas_item;

group_uniforms sky;
uniform vec4 top : source_color = vec4(0.56, 0.79, 0.94, 1.0);
uniform vec4 middle : source_color = vec4(0.85, 0.93, 0.97, 1.0);
uniform vec4 bottom : source_color = vec4(0.97, 0.95, 0.87, 1.0);
uniform vec4 cloud : source_color = vec4(1.0);
uniform vec4 far_island : source_color = vec4(0.62, 0.78, 0.6, 1.0);
/** 1 = night sky: stars instead of bright clouds. */
uniform float night : hint_range(0.0, 1.0) = 0.0;
/** 1 = rising bubbles (underwater). */
uniform float bubbles : hint_range(0.0, 1.0) = 0.0;
group_uniforms;

float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vnoise(p) * 0.5 + vnoise(p * 2.0) * 0.27 + vnoise(p * 4.0) * 0.15 + vnoise(p * 8.0) * 0.08; }

// One distant island: flat top, tapering rocky underside. Returns coverage 0..1.
float island(vec2 uv, vec2 c, float w) {
	vec2 d = (uv - c) / w;
	float top_cap = 1.0 - smoothstep(0.0, 0.04, abs(d.y + 0.02) - 0.04) ;
	float body = step(d.y, 0.0) * step(-1.0, d.y) * step(abs(d.x), 1.0 + d.y * 0.85 + (vnoise(vec2(d.x * 6.0, c.x * 9.0)) - 0.5) * 0.25);
	float slab = step(abs(d.x), 1.05) * step(abs(d.y + 0.03), 0.07);
	float trees = step(d.y, -0.0) * 0.0 + step(0.0, d.y) * step(d.y, 0.08 + 0.12 * vnoise(vec2(d.x * 8.0, c.y))) * step(abs(d.x), 0.95);
	return clamp(max(max(body, slab), trees) + top_cap * 0.0, 0.0, 1.0);
}

void fragment() {
	vec2 uv = UV;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec3 col = mix(top.rgb, middle.rgb, smoothstep(0.0, 0.55, uv.y));
	col = mix(col, bottom.rgb, smoothstep(0.55, 1.0, uv.y));
	vec2 p = vec2(uv.x / max(aspect, 0.2), uv.y);
	// Distant islands in two haze layers.
	for (int i = 0; i < 5; i++) {
		float fi = float(i);
		vec2 c = vec2(fract(hash21(vec2(fi, 3.0)) + 0.15 * fi) / max(aspect, 0.2), 0.32 + 0.38 * hash21(vec2(fi, 9.0)));
		float w = 0.05 + 0.08 * hash21(vec2(fi, 5.0));
		float cov = island(p, c, w);
		float haze = 0.35 + 0.35 * c.y;
		col = mix(col, mix(far_island.rgb, middle.rgb, haze), cov * 0.85);
	}
	// Soft clouds drifting slowly; fainter at night.
	float n = fbm(vec2(p.x * 3.0 + TIME * 0.01, p.y * 6.0));
	float band = smoothstep(0.55, 0.95, uv.y) + smoothstep(0.35, 0.0, uv.y) * 0.6;
	float cl = smoothstep(0.52, 0.72, n) * band;
	col = mix(col, cloud.rgb, cl * mix(0.85, 0.35, night));
	// Stars for night biomes.
	vec2 sp = floor(FRAGCOORD.xy / 3.0);
	float star = step(0.996, hash21(sp)) * night * (0.6 + 0.4 * sin(TIME * 2.0 + hash21(sp + 1.0) * 30.0));
	col += vec3(star);
	// Rising bubbles for underwater.
	vec2 bp = vec2(p.x * 30.0, p.y * 30.0 + TIME * 0.6);
	vec2 cell = floor(bp);
	float has = step(0.93, hash21(cell));
	vec2 off = vec2(hash21(cell + 4.0), hash21(cell + 8.0)) * 0.5 + 0.25;
	float r = 0.08 + 0.12 * hash21(cell + 2.0);
	float ring = smoothstep(0.05, 0.0, abs(length(fract(bp) - off) - r));
	col = mix(col, vec3(0.9, 0.97, 1.0), ring * has * bubbles * 0.6);
	COLOR = vec4(col, 1.0);
}
