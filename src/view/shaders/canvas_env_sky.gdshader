// canvas_env_sky: painted sky backdrop behind the 3D board (technical art, 2026-10-13).
// Gradient + sun haze + hazy mountain ridge + distant floating islands (grass cap, rocky
// underside, optional thin waterfall) + a puffy cloud sea below + drifting clouds; stars at night,
// bubbles underwater. Drawn on a CanvasLayer used as the Environment background (BG_CANVAS).
// Target: Mobile / Compatibility. Cost: ~10 value-noise evaluations per pixel plus 6 island SDFs;
// star and bubble terms sit behind uniform branches (coherent, skipped when off).
shader_type canvas_item;

group_uniforms sky;
uniform vec4 top : source_color = vec4(0.56, 0.79, 0.94, 1.0);
uniform vec4 middle : source_color = vec4(0.85, 0.93, 0.97, 1.0);
uniform vec4 bottom : source_color = vec4(0.97, 0.95, 0.87, 1.0);
uniform vec4 cloud : source_color = vec4(1.0);
/** Grass/cap colour of the distant islands. */
uniform vec4 far_island : source_color = vec4(0.62, 0.78, 0.6, 1.0);
/** Rock colour of the distant islands' undersides. */
uniform vec4 far_rock : source_color = vec4(0.55, 0.42, 0.3, 1.0);
/** Colour of the thin distant waterfalls. */
uniform vec4 far_fall : source_color = vec4(0.8, 0.94, 1.0, 1.0);
/** 1 = distant islands have waterfalls. */
uniform float far_falls : hint_range(0.0, 1.0) = 1.0;
/** 1 = night sky: stars instead of bright clouds. */
uniform float night : hint_range(0.0, 1.0) = 0.0;
/** 1 = rising bubbles (underwater). */
uniform float bubbles : hint_range(0.0, 1.0) = 0.0;
/** 0 under reduced motion: clouds, stars and bubbles hold still. */
uniform float motion : hint_range(0.0, 1.0) = 1.0;
group_uniforms;

const int ISLANDS = 6;

float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vnoise(p) * 0.5 + vnoise(p * 2.0) * 0.27 + vnoise(p * 4.0) * 0.15 + vnoise(p * 8.0) * 0.08; }

// One distant island in local units d (x across, y down = positive). Returns
// x: rock coverage, y: grass cap coverage, z: waterfall coverage, w: vertical shade 0..1.
vec4 island(vec2 d, float seed) {
	float jag = (vnoise(vec2(d.x * 7.0, seed * 9.0)) - 0.5) * 0.25;
	// Underside: an inverted, stepped cone.
	float depth = d.y;
	float width = 1.0 - pow(clamp(depth / 1.1, 0.0, 1.0), 0.8) + jag;
	width *= 0.9 + 0.1 * step(0.5, fract(depth * 4.0));
	float rock = step(0.0, depth) * step(depth, 1.15) * step(abs(d.x), width);
	// Cap: a soft rounded slab with a lumpy tree line.
	float cap_top = -0.08 - 0.1 * vnoise(vec2(d.x * 9.0, seed * 3.0)) * step(abs(d.x), 0.8);
	float cap = step(abs(d.x), 1.04 + jag * 0.3) * step(cap_top, d.y) * step(d.y, 0.08);
	// Thin waterfall off one side.
	float fx = 0.55 - 0.3 * hash21(vec2(seed, 2.0));
	float fall = step(abs(d.x - fx), 0.035 + depth * 0.03) * step(0.0, d.y) * step(d.y, 1.6) * far_falls;
	return vec4(max(rock, cap), cap, fall, clamp(depth, 0.0, 1.0));
}

void fragment() {
	vec2 uv = UV;
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float t = TIME * motion;
	vec3 col = mix(top.rgb, middle.rgb, smoothstep(0.0, 0.55, uv.y));
	col = mix(col, bottom.rgb, smoothstep(0.55, 1.0, uv.y));
	vec2 p = vec2(uv.x / max(aspect, 0.2), uv.y);
	// Sun haze (day) top left.
	float sun = exp(-length((uv - vec2(0.18, 0.12)) * vec2(1.0, 1.6)) * 4.0) * (1.0 - night);
	col = mix(col, bottom.rgb + vec3(0.08, 0.06, 0.0), sun * 0.55);
	// Hazy mountain ridge at the horizon.
	float ridge = 0.6 - 0.12 * fbm(vec2(p.x * 2.2, 1.7)) - 0.05 * vnoise(vec2(p.x * 9.0, 4.0));
	col = mix(col, mix(far_island.rgb, middle.rgb, 0.68), smoothstep(ridge, ridge + 0.004, uv.y) * 0.75);
	// Distant floating islands: three far (hazy) and three nearer.
	for (int i = 0; i < ISLANDS; i++) {
		float fi = float(i);
		float near = step(3.0, fi);
		vec2 c = vec2((0.08 + 0.84 * fract(hash21(vec2(fi, 3.0)) + 0.37 * fi)) / max(aspect, 0.2),
			mix(0.2 + 0.28 * hash21(vec2(fi, 9.0)), 0.3 + 0.4 * hash21(vec2(fi, 11.0)), near));
		float w = mix(0.035, 0.07, near) + 0.03 * hash21(vec2(fi, 5.0));
		vec2 d = (p - c) / w;
		d.y *= 0.9;
		vec4 isl = island(d, fi);
		float haze = mix(0.62, 0.32, near);
		vec3 rock = mix(far_rock.rgb, far_rock.rgb * 0.6, isl.w);
		vec3 icol = mix(rock, far_island.rgb * (1.0 + 0.15 * step(d.y, -0.04)), isl.y);
		icol = mix(icol, middle.rgb, haze);
		col = mix(col, icol, isl.x);
		col = mix(col, mix(far_fall.rgb, middle.rgb, haze * 0.6), isl.z * (1.0 - isl.y) * 0.85 * (1.0 - smoothstep(0.8, 1.6, d.y)));
	}
	// Soft clouds drifting slowly across the upper sky; fainter at night.
	float n = fbm(vec2(p.x * 2.4 + t * 0.01, p.y * 5.0));
	float band = smoothstep(0.42, 0.0, uv.y);
	col = mix(col, cloud.rgb, smoothstep(0.55, 0.75, n) * band * mix(0.8, 0.3, night));
	// Puffy cloud sea along the bottom: lit tops, shaded undersides.
	float sea_line = 0.78 - 0.06 * fbm(vec2(p.x * 3.0 + t * 0.005, 2.0)) - 0.03 * vnoise(vec2(p.x * 14.0, 7.0));
	float sea = smoothstep(sea_line, sea_line + 0.012, uv.y);
	float puff = fbm(vec2(p.x * 6.0 - t * 0.006, uv.y * 9.0));
	vec3 sea_col = mix(cloud.rgb, mix(cloud.rgb, middle.rgb, 0.55), smoothstep(0.0, 0.25, uv.y - sea_line) * 0.6 + puff * 0.25);
	col = mix(col, sea_col, sea * mix(0.92, 0.45, night));
	// Stars for night biomes.
	if (night > 0.0) {
		vec2 sp = floor(FRAGCOORD.xy / 3.0);
		float star = step(0.996, hash21(sp)) * night * (0.6 + 0.4 * sin(t * 2.0 + hash21(sp + 1.0) * 30.0));
		col += vec3(star) * (1.0 - sea);
	}
	// Rising bubbles for underwater.
	if (bubbles > 0.0) {
		vec2 bp = vec2(p.x * 30.0, p.y * 30.0 + t * 0.6);
		vec2 cell = floor(bp);
		float has = step(0.93, hash21(cell));
		vec2 off = vec2(hash21(cell + 4.0), hash21(cell + 8.0)) * 0.5 + 0.25;
		float r = 0.08 + 0.12 * hash21(cell + 2.0);
		float ring = smoothstep(0.05, 0.0, abs(length(fract(bp) - off) - r));
		col = mix(col, vec3(0.9, 0.97, 1.0), ring * has * bubbles * 0.6);
	}
	COLOR = vec4(col, 1.0);
}
