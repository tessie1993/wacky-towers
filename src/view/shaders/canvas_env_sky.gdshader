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
group_uniforms layers;
/** Painted mesa-cliff layers (far + mid) with grass/snow tops and thin waterfalls (§5.4). */
uniform float mesa_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 mesa_top : source_color = vec4(0.42, 0.68, 0.29, 1.0);
uniform vec4 mesa_rock : source_color = vec4(0.66, 0.5, 0.35, 1.0);
/** Chance a mesa carries a waterfall streak (0 = none). */
uniform float mesa_falls : hint_range(0.0, 1.0) = 0.6;
/** 0 = flat-topped mesas, 1 = rounded painterly hills (ref 15 meadow) with grass caps. */
uniform float mesa_round : hint_range(0.0, 1.0) = 0.0;
group_uniforms peaks;
/** Sharp snowy peak ridge behind the layers (ref 15 ice). 0 = none. */
uniform float peaks : hint_range(0.0, 1.0) = 0.0;
uniform vec4 peak_rock : source_color = vec4(0.62, 0.62, 0.86, 1.0);
uniform vec4 peak_snow : source_color = vec4(0.97, 0.97, 1.0, 1.0);
group_uniforms castle;
/** Distant castle silhouette on the ridge (ref 15 ice). 0 = none. */
uniform float castle : hint_range(0.0, 1.0) = 0.0;
uniform vec4 castle_color : source_color = vec4(0.72, 0.74, 0.95, 1.0);
uniform vec4 castle_roof : source_color = vec4(0.45, 0.55, 0.9, 1.0);
/** Castle centre (uv.x) and base height (uv.y). */
uniform vec2 castle_pos = vec2(0.2, 0.37);
group_uniforms layers;
/** Near puffy cloud bank in front of the mesas (0 = none). */
uniform float cloud_bank : hint_range(0.0, 1.0) = 0.0;
group_uniforms night;
uniform float stars : hint_range(0.0, 1.0) = 0.0;
uniform float nebula : hint_range(0.0, 1.0) = 0.0;
uniform vec4 nebula_a : source_color = vec4(0.69, 0.35, 0.78, 1.0);
uniform vec4 nebula_b : source_color = vec4(0.29, 0.42, 0.85, 1.0);
group_uniforms;
/** 0 under reduced motion: clouds and stars hold still. */
uniform float motion : hint_range(0.0, 1.0) = 1.0;
/** Camera-turn parallax: horizontal shift of the painted layers in aspect-scaled screen widths (0 at rest). */
uniform float view_shift = 0.0;

/** Castle silhouette size relative to its authored proportions. */
const float CASTLE_SCALE = 0.55;
float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vn(p) * 0.5 + vn(p * 2.1) * 0.3 + vn(p * 4.3) * 0.2; }

void fragment() {
	vec2 uv = UV;
	float aspect = SCREEN_PIXEL_SIZE.y / max(SCREEN_PIXEL_SIZE.x, 1e-6);
	vec2 p = vec2((uv.x - 0.5) * aspect + view_shift, uv.y);
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
		float r1 = 0.3 - 0.11 * fbm(vec2(p.x * 1.6, 1.7)) - 0.07 * pow(abs(sin(p.x * 3.1 + 1.0)), 3.0);
		float r2 = 0.37 - 0.08 * fbm(vec2(p.x * 2.3 + 7.0, 3.1)) - 0.06 * pow(abs(sin(p.x * 4.3 + 2.0)), 4.0);
		vec3 far_c = mix(mountains.rgb, horizon.rgb, 0.62);
		vec3 near_c = mix(mountains.rgb, horizon.rgb, 0.38);
		float m1 = smoothstep(r1, r1 + 0.003, uv.y);
		float m2 = smoothstep(r2, r2 + 0.003, uv.y);
		col = mix(col, far_c * (0.96 + 0.08 * fbm(p * 9.0)), m1 * mountain_amount);
		col = mix(col, near_c * (0.94 + 0.1 * fbm(p * 7.0 + 3.0)), m2 * mountain_amount);
		col = mix(col, mix(horizon.rgb, low.rgb, 0.5), smoothstep(0.4, 0.8, uv.y) * 0.6 * m1);
	}
	// Snowy peaks: two jagged ridges of triangular mountains, snow on the upper slopes, the
	// right flank (away from the top-left sun) shaded. Hazier for the far ridge.
	if (peaks > 0.0) {
		for (int r = 0; r < 2; r++) {
			float fr = float(r);
			float k = p.x * mix(2.4, 3.6, fr) + fr * 3.7 + 0.4;
			float kc = floor(k);
			float kf = fract(k);
			float ph = mix(0.55, 1.0, h21(vec2(kc, 31.0 + fr)));
			float off = (h21(vec2(kc, 37.0 + fr)) - 0.5) * 0.3;
			float tri = clamp(1.0 - abs(kf - 0.5 - off) * 2.0 / (1.0 - abs(off) * 2.0 + 0.3), 0.0, 1.0);
			float base = mix(0.34, 0.39, fr);
			float rp = base - mix(0.17, 0.11, fr) * ph * pow(tri, 1.25) - 0.012 * fbm(vec2(p.x * 14.0, fr * 5.0));
			float inside = smoothstep(rp, rp + 0.002, uv.y);
			float snowl = rp + (0.03 + 0.05 * ph) * (0.75 + 0.5 * vn(vec2(p.x * 24.0, fr)));
			float shade = smoothstep(0.48, 0.56, kf - off);
			vec3 rock = peak_rock.rgb * mix(1.0, 0.8, shade) * (0.94 + 0.1 * fbm(p * 18.0));
			vec3 snow = peak_snow.rgb * mix(1.0, 0.86, shade);
			vec3 pc = mix(snow, rock, smoothstep(snowl, snowl + 0.008, uv.y));
			pc = mix(pc, horizon.rgb, mix(0.5, 0.22, fr) + smoothstep(rp + 0.04, rp + 0.2, uv.y) * 0.4);
			col = mix(col, pc, inside * peaks);
		}
	}
	// Castle silhouette: wall + five towers with cone roofs, painted pale like distant ice.
	if (castle > 0.0) {
		vec2 cq = vec2((uv.x - castle_pos.x) * aspect + view_shift, castle_pos.y - uv.y) / CASTLE_SCALE;
		float body = step(abs(cq.x), 0.085) * step(cq.y, 0.045) * step(-0.06, cq.y);
		float roof = 0.0;
		float shade_c = 0.0;
		for (int i = 0; i < 5; i++) {
			float fi = float(i);
			float tx = (fi - 2.0) * 0.042;
			float th = mix(0.075, 0.15, 1.0 - abs(fi - 2.0) / 2.0);
			float tw = mix(0.011, 0.017, 1.0 - abs(fi - 2.0) / 2.0);
			float tower = step(abs(cq.x - tx), tw) * step(cq.y, th) * step(-0.06, cq.y);
			float cone = step(abs(cq.x - tx), (tw + 0.004) * (1.0 - (cq.y - th) / 0.05)) * step(th, cq.y) * step(cq.y, th + 0.05);
			body = max(body, tower);
			roof = max(roof, cone);
			shade_c = max(shade_c, tower * step(tx + tw * 0.2, cq.x));
		}
		vec3 cc = castle_color.rgb * mix(1.0, 0.86, shade_c);
		col = mix(col, cc, body * castle);
		col = mix(col, castle_roof.rgb * mix(1.0, 0.8, step(0.0, cq.x - floor((cq.x + 0.021) / 0.042) * 0.042)), roof * castle);
	}
	// Painted mesa cliffs, two layers: far = hazier/smaller, mid = saturated. Each cell of the
	// strip may hold a flat-topped cliff (cap + striated rock, shade side right) with an optional
	// waterfall streak; everything fades into the horizon haze toward its foot.
	if (mesa_amount > 0.0) {
		for (int layer = 0; layer < 2; layer++) {
			float fl = float(layer);
			float sc = mix(mix(16.0, 10.0, fl), mix(7.0, 4.5, fl), mesa_round);
			float qx = p.x * sc + fl * 7.3;
			float cell = floor(qx);
			float fx = fract(qx);
			float present = step(0.3, h21(vec2(cell, 3.0 + fl)));
			float topy = mix(0.27, 0.42, h21(vec2(cell, 7.0 + fl))) + fl * 0.06;
			float half_w = mix(0.2, 0.34, h21(vec2(cell, 11.0 + fl)));
			float edge = abs(fx - 0.5) - half_w - (uv.y - topy) * 1.4 - 0.06 * vn(vec2(uv.y * 60.0, cell));
			float inside = present * step(edge, 0.0) * step(topy, uv.y);
			float cap = 1.0 - step(topy + 0.016 + 0.012 * vn(vec2(fx * 18.0, cell)), uv.y);
			float shade_x = smoothstep(0.48, 0.62, fx);
			if (mesa_round > 0.5) {
				// Rounded hills: the dome of this cell or a neighbour, whichever is in front
				// (higher). Domes are wide and soft so they overlap into a rolling range.
				float best = 9.0; float bdx = 0.0; float bw = 1.0; float bcell = cell;
				for (int nb = -1; nb <= 1; nb++) {
					float c = cell + float(nb);
					float pres = step(0.22, h21(vec2(c, 3.0 + fl)));
					float cx = c + 0.5 + (h21(vec2(c, 5.0 + fl)) - 0.5) * 0.5;
					float w = mix(0.75, 1.25, h21(vec2(c, 11.0 + fl)));
					float dx = qx - cx;
					float ty = mix(0.26, 0.4, h21(vec2(c, 7.0 + fl))) + fl * 0.07;
					float ys = ty + 0.11 * pow(abs(dx) / w, 2.0) + 0.012 * vn(vec2(qx * 4.0, fl + 2.0));
					ys = mix(9.0, ys, pres);
					if (ys < best) { best = ys; bdx = dx; bw = w; bcell = c; }
				}
				topy = best;
				inside = step(best, uv.y);
				fx = clamp(0.5 + bdx / (bw * 2.0), 0.0, 1.0);
				cell = bcell;
				float grass_l = best + 0.035 + 0.05 * vn(vec2(qx * 3.0, 9.0 + fl)) + 0.02 * vn(vec2(qx * 14.0, fl));
				cap = 1.0 - smoothstep(grass_l - 0.004, grass_l + 0.004, uv.y);
				// Grass ledges further down the slope (terraces).
				float terr = step(0.5, vn(vec2(qx * 2.0, floor((uv.y - best) * 14.0) + fl * 3.0)));
				cap = max(cap, terr * (1.0 - smoothstep(0.0, 0.012, fract((uv.y - best) * 14.0))) * 0.9);
				shade_x = smoothstep(-0.1, 0.5, bdx / bw) * 0.9;
			}
			vec3 rockc = mesa_rock.rgb * (0.82 + 0.3 * vn(vec2(fx * 16.0 + cell, uv.y * 20.0)));
			rockc *= mix(1.0, 0.74, shade_x);
			vec3 grassc = mesa_top.rgb * mix(1.08, 0.82, shade_x) * (0.92 + 0.14 * vn(vec2(qx * 9.0, uv.y * 40.0)));
			vec3 mc = mix(rockc, grassc, cap);
			float fall_x = 0.5 + 0.18 * (h21(vec2(cell, 23.0 + fl)) - 0.5);
			float fall = step(1.0 - mesa_falls, h21(vec2(cell, 19.0 + fl))) * (1.0 - smoothstep(mix(0.05, 0.012, mesa_round), mix(0.09, 0.026, mesa_round), abs(fx - fall_x))) * step(topy + 0.012, uv.y);
			mc = mix(mc, vec3(0.92, 0.97, 1.0) * (0.9 + 0.1 * vn(vec2(fx * 30.0, uv.y * 80.0 - t * 2.0))), fall * 0.9);
			float hz = mix(mix(0.38, 0.06, fl), mix(0.3, 0.02, fl), mesa_round) + smoothstep(topy + 0.08, topy + 0.32, uv.y) * mix(0.4, 0.3, mesa_round);
			mc = mix(mc, horizon.rgb, clamp(hz, 0.0, 1.0));
			col = mix(col, mc, inside * mesa_amount);
		}
	}
	// Near puffy cloud bank in front of the cliffs: scalloped top, lit crown, shaded belly.
	if (cloud_bank > 0.0) {
		float bl = 0.54 - 0.04 * fbm(vec2(p.x * 2.0 + 4.0, 1.0)) - 0.03 * abs(sin(p.x * 9.0 + fbm(vec2(p.x * 2.5, 9.0)) * 4.0));
		float bank = smoothstep(bl, bl + 0.006, uv.y) ;  // runs to the bottom edge: the old fade-out at y 0.66-0.72 left a hard seam above the cloud sea
		vec3 bc = mix(cloud.rgb, cloud_shade.rgb, clamp((uv.y - bl) * 9.0, 0.0, 1.0) * 0.7);
		col = mix(col, bc, bank * cloud_bank);
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
