// canvas_env_sky: painted sky backdrop drawn BEHIND the 3D world (Environment BG_CANVAS,
// CanvasLayer -10). design/art/style-techniques.md §5.4: gradient top -> horizon -> low, warm
// sun haze top-left, two hazy mountain ridges, drifting cloud wisps with lit tops, a puffy cloud
// sea along the bottom, and stars + nebula for night biomes. Distant floating islands are real
// 3D props (WtIslandBuilder.build_far) hazed in their own shaders. Same on all renderers.
// Cost: ~12 value-noise taps per pixel; stars/nebula behind uniform branches.
shader_type canvas_item;

group_uniforms sky;
uniform vec4 top : source_color = vec4(0.31, 0.58, 0.9, 1.0);
uniform vec4 horizon : source_color = vec4(0.81, 0.9, 0.98, 1.0);
uniform vec4 low : source_color = vec4(1.0, 0.96, 0.9, 1.0);
/** Warm sun haze strength (top-left). */
uniform float sun : hint_range(0.0, 1.0) = 1.0;
group_uniforms clouds;
uniform vec4 cloud : source_color = vec4(1.0, 0.98, 0.95, 1.0);
uniform vec4 cloud_shade : source_color = vec4(0.82, 0.84, 0.95, 1.0);
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.85;
/** Height (0 top .. 1 bottom) where the cloud sea starts. */
uniform float sea_line : hint_range(0.5, 1.0) = 0.8;
group_uniforms ridge;
uniform vec4 mountains : source_color = vec4(0.56, 0.72, 0.66, 1.0);
uniform float mountain_amount : hint_range(0.0, 1.0) = 0.6;
group_uniforms night;
uniform float stars : hint_range(0.0, 1.0) = 0.0;
uniform float nebula : hint_range(0.0, 1.0) = 0.0;
uniform vec4 nebula_a : source_color = vec4(0.69, 0.35, 0.78, 1.0);
uniform vec4 nebula_b : source_color = vec4(0.29, 0.42, 0.85, 1.0);
group_uniforms;
/** 0 under reduced motion: clouds and stars hold still. */
uniform float motion : hint_range(0.0, 1.0) = 1.0;

float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vn(p) * 0.5 + vn(p * 2.1) * 0.3 + vn(p * 4.3) * 0.2; }

void fragment() {
	vec2 uv = UV;
	float aspect = SCREEN_PIXEL_SIZE.y / max(SCREEN_PIXEL_SIZE.x, 1e-6);
	vec2 p = vec2((uv.x - 0.5) * aspect, uv.y);
	float t = TIME * motion;
	vec3 col = mix(top.rgb, horizon.rgb, smoothstep(0.0, 0.62, uv.y));
	col = mix(col, low.rgb, smoothstep(0.62, 1.0, uv.y));
	// Warm sun haze, upper left.
	float sd = length((uv - vec2(0.12, 0.08)) * vec2(1.0, 1.5));
	col = mix(col, low.rgb * vec3(1.04, 1.0, 0.92), exp(-sd * 3.2) * 0.5 * sun);
	if (nebula > 0.0) {
		float warp = fbm(p * 1.4 + 3.0);
		float neb = fbm(p * 2.2 + warp * 1.6);
		float lane = exp(-pow((uv.y - 0.25 - (uv.x - 0.5) * 0.5) * 3.2, 2.0));
		col += mix(nebula_a.rgb, nebula_b.rgb, smoothstep(0.35, 0.7, warp)) * smoothstep(0.4, 0.75, neb) * lane * nebula * 0.7;
	}
	if (stars > 0.0) {
		vec2 sp = floor(FRAGCOORD.xy / 2.0);
		float tw = 0.6 + 0.4 * sin(t * 2.0 + h21(sp + 1.0) * 30.0);
		float s = step(0.9965, h21(sp)) * tw;
		vec2 bp = FRAGCOORD.xy / 46.0;
		vec2 bc = floor(bp);
		vec2 bf = fract(bp) - 0.5 - (vec2(h21(bc + 2.0), h21(bc + 5.0)) - 0.5) * 0.6;
		float big = step(0.86, h21(bc + 9.0));
		float cross_ = max(exp(-abs(bf.x) * 60.0) * exp(-abs(bf.y) * 9.0), exp(-abs(bf.y) * 60.0) * exp(-abs(bf.x) * 9.0));
		s += big * (cross_ + exp(-length(bf) * 22.0)) * tw;
		col += vec3(1.0, 0.95, 0.85) * s * stars * (1.0 - smoothstep(0.55, 0.85, uv.y));
	}
	// Two hazy mountain ridges at the horizon (far = paler).
	if (mountain_amount > 0.0) {
		float r1 = 0.5 - 0.13 * fbm(vec2(p.x * 1.6, 1.7)) - 0.07 * pow(abs(sin(p.x * 3.1 + 1.0)), 3.0);
		float r2 = 0.58 - 0.09 * fbm(vec2(p.x * 2.3 + 7.0, 3.1)) - 0.06 * pow(abs(sin(p.x * 4.3 + 2.0)), 4.0);
		vec3 far_c = mix(mountains.rgb, horizon.rgb, 0.62);
		vec3 near_c = mix(mountains.rgb, horizon.rgb, 0.38);
		float m1 = smoothstep(r1, r1 + 0.003, uv.y);
		float m2 = smoothstep(r2, r2 + 0.003, uv.y);
		col = mix(col, far_c * (0.96 + 0.08 * fbm(p * 9.0)), m1 * mountain_amount);
		col = mix(col, near_c * (0.94 + 0.1 * fbm(p * 7.0 + 3.0)), m2 * mountain_amount);
		col = mix(col, low.rgb, smoothstep(0.55, 0.85, uv.y) * 0.55 * m1);
	}
	// Cloud wisps: billowy soft threshold, lit top / shaded underside from an offset sample.
	vec2 cp = vec2(p.x * 2.0 + t * 0.006, uv.y * 6.0);
	float n = fbm(cp);
	float n_up = fbm(cp + vec2(0.0, 0.3));
	float wisp_band = smoothstep(0.62, 0.15, uv.y) * 0.85 + smoothstep(0.45, 0.62, uv.y) * smoothstep(0.75, 0.62, uv.y) * 0.9;
	float cl = smoothstep(0.5, 0.7, n) * wisp_band * cloud_amount;
	col = mix(col, mix(cloud_shade.rgb, cloud.rgb, smoothstep(-0.06, 0.08, n - n_up)), cl);
	// Puffy cloud sea along the bottom: scalloped top line, lit crowns, shaded body.
	float line = sea_line - 0.05 * fbm(vec2(p.x * 2.5 + t * 0.004, 2.0)) - 0.035 * abs(sin(p.x * 11.0 + fbm(vec2(p.x * 3.0, 5.0)) * 4.0));
	float sea = smoothstep(line, line + 0.006, uv.y);
	float puff = fbm(vec2(p.x * 7.0 - t * 0.005, uv.y * 12.0));
	float depth = clamp((uv.y - line) * 7.0, 0.0, 1.0);
	vec3 sea_c = mix(cloud.rgb, cloud_shade.rgb, clamp(depth * 0.55 + (puff - 0.5) * 0.5, 0.0, 1.0));
	col = mix(col, sea_c, sea * cloud_amount);
	COLOR = vec4(col, 1.0);
}
