// spatial_block_biome: Wacky Towers biome block look (technical art, 2026-10-13).
// One cheap procedural shader for every biome cube. Target: Mobile renderer, phones;
// no texture samples, one 3x3 Voronoi at most, style picked by a uniform (coherent branch).
// Source look: assets/art/reference/biome_block_materials_ref.png (design/art/block-art-sets.md).
// Per-biome values come from assets/data/biome_looks.json via WtBlockMaterials.
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Biome style: 0 plain, 1 meadow, 2 candy, 3 ice, 4 underwater, 5 lava, 6 forest,
// 7 cave, 8 clockwork, 9 neon, 10 celestial, 11 carnival, 12 dune bazaar.
uniform int style = 0;
uniform vec3 cap_color : source_color = vec3(0.45, 0.72, 0.30);
uniform float cap_depth : hint_range(0.0, 0.6) = 0.0;
uniform float cap_drip : hint_range(0.0, 0.3) = 0.08;
uniform vec3 body_color : source_color = vec3(0.55, 0.40, 0.27);
uniform float body_mix : hint_range(0.0, 1.0) = 0.0;
uniform vec3 accent_color : source_color = vec3(1.0);
uniform vec3 glow_color : source_color = vec3(1.0, 0.5, 0.1);
uniform float glow : hint_range(0.0, 4.0) = 0.0;
uniform float gloss : hint_range(0.0, 1.0) = 0.4;
uniform float rim : hint_range(0.0, 1.0) = 0.15;
uniform float detail : hint_range(0.0, 1.0) = 1.0;
uniform float brightness : hint_range(0.5, 1.6) = 1.0;
// Shared with the stage/BoardView accessibility and occlusion contract.
uniform int stickers = 0;
uniform bool patterns = false;
uniform bool high_contrast = false;
uniform int occlusion = 0;
uniform vec3 focus = vec3(0.0);
uniform vec3 eye = vec3(1.0);
uniform float visibility = 1.0;
// Locked cubes carry a per-cell fade in INSTANCE_CUSTOM.a; the falling piece does not.
uniform bool use_cell_alpha = true;

varying vec3 lp;
varying vec3 ln;
varying float motif;
varying float cell_alpha;
varying vec3 center;

float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float hash31(vec3 p) { return hash21(p.xy + p.z * 17.17); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vnoise(p) * 0.55 + vnoise(p * 2.1) * 0.3 + vnoise(p * 4.3) * 0.15; }
// Distance to the nearest Voronoi border (x) and the cell id (y).
vec2 voronoi(vec2 p) {
	vec2 n = floor(p); vec2 f = fract(p);
	float d1 = 8.0; float d2 = 8.0; float id = 0.0;
	for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) {
		vec2 g = vec2(float(i), float(j));
		vec2 o = vec2(hash21(n + g), hash21(n + g + 7.3));
		float d = length(g + o - f);
		if (d < d1) { d2 = d1; d1 = d; id = hash21(n + g + 3.1); } else if (d < d2) { d2 = d; }
	}
	return vec2(d2 - d1, id);
}
float circle(vec2 uv, vec2 c, float r) { return 1.0 - smoothstep(r - 0.015, r + 0.015, length(uv - c)); }
float star4(vec2 uv, vec2 c, float r) {
	vec2 d = abs(uv - c);
	return 1.0 - smoothstep(r * 0.15, r * 0.25, d.x * d.y * 40.0 / r + (d.x + d.y) * 0.4 / r - 0.05);
}

void vertex() {
	lp = VERTEX; ln = NORMAL;
	motif = INSTANCE_CUSTOM.r; cell_alpha = use_cell_alpha ? INSTANCE_CUSTOM.a : 1.0;
	center = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
}

void fragment() {
	if (fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453) > visibility * cell_alpha) discard;
	vec2 toward = normalize(eye.xz - focus.xz);
	if (occlusion > 0 && center.y > focus.y + 0.4 && dot(center.xz - focus.xz, toward) > 0.3) {
		if (occlusion == 2) discard;
		if (fract(FRAGCOORD.x * 0.5) + fract(FRAGCOORD.y * 0.5) > 0.25) discard;
	}
	vec3 p = lp;
	vec3 an = abs(ln);
	bool top = ln.y > 0.6;
	bool bottom = ln.y < -0.6;
	vec2 uv = an.y > 0.5 ? p.xz : (an.x > 0.5 ? p.zy : p.xy);
	// Seed per cube so neighbouring cubes do not repeat the same marks.
	float seed = hash31(floor(center * 1.01 + 0.5));
	vec2 suv = uv + seed * 7.0;
	float edge = max(abs(p.x), max(abs(p.y), abs(p.z)));
	float face_edge = an.y > 0.5 ? max(abs(p.x), abs(p.z)) : (an.x > 0.5 ? max(abs(p.z), abs(p.y)) : max(abs(p.x), abs(p.y)));

	vec3 piece = COLOR.rgb;
	vec3 col = mix(piece, body_color, body_mix);
	vec3 emit = vec3(0.0);
	float rough = 1.0 - gloss;

	if (style == 1) { // Meadow: dirt layers, pebbles, clover.
		float layer = step(0.5, fract(p.y * 3.0 + fbm(suv * 3.0) * 0.4));
		col *= mix(0.92, 1.04, layer);
		float peb = circle(fract(suv * 2.3), vec2(0.5), 0.09) * step(0.55, hash21(floor(suv * 2.3)));
		col = mix(col, vec3(0.62, 0.60, 0.58), peb * detail);
	} else if (style == 2) { // Candy: glossy jelly with a deep inner glow.
		float inner = 1.0 - smoothstep(0.15, 0.48, face_edge);
		col = mix(col * 0.82, col * 1.18 + 0.06, inner);
		emit += piece * 0.12 * inner;
		float sprink = step(0.9, hash21(floor(suv * 7.0))) * (top ? 1.0 : 0.0);
		col = mix(col, mix(vec3(1.0, 0.45, 0.6), vec3(0.4, 0.8, 1.0), hash21(floor(suv * 7.0) + 2.0)), sprink);
	} else if (style == 3) { // Ice: translucent blue, frost crackle, sparkles.
		vec2 v = voronoi(suv * 3.2);
		col = mix(col, vec3(0.92, 0.97, 1.0), (1.0 - smoothstep(0.0, 0.05, v.x)) * 0.5 * detail);
		col *= 0.9 + 0.2 * (1.0 - smoothstep(0.1, 0.5, face_edge));
		float sp = step(0.985, hash21(floor(suv * 18.0)));
		emit += vec3(0.8, 0.95, 1.0) * sp * 0.8;
		if (top) col = mix(col, vec3(0.85, 0.94, 1.0), 0.0);
	} else if (style == 4) { // Underwater: deep glass, bubbles, caustic light.
		float caust = fbm(suv * 4.0 + vec2(TIME * 0.05, 0.0));
		col *= 0.75 + 0.5 * caust;
		vec2 cell = floor(suv * 3.0);
		float has = step(0.6, hash21(cell));
		vec2 c = vec2(0.3) + vec2(hash21(cell + 1.0), hash21(cell + 2.0)) * 0.4;
		float r = 0.10 + hash21(cell + 3.0) * 0.1;
		float ring = circle(fract(suv * 3.0), c, r) - circle(fract(suv * 3.0), c, r - 0.04);
		float hi = circle(fract(suv * 3.0), c + vec2(-r, r) * 0.4, r * 0.25);
		col = mix(col, vec3(0.85, 0.95, 1.0), (ring * 0.6 + hi * 0.9) * has * detail);
		emit += accent_color * 0.12 * caust;
	} else if (style == 5) { // Lava: dark basalt plates with glowing cracks.
		vec2 v = voronoi(suv * 1.7);
		float crack = 1.0 - smoothstep(0.04, 0.12, v.x);
		col *= 0.8 + 0.4 * fbm(suv * 5.0);
		col = mix(col * (0.75 + 0.3 * v.y), glow_color, crack);
		emit += glow_color * crack * glow * (0.8 + 0.2 * sin(TIME * 2.0 + seed * 6.28));
		rough = mix(0.85, 0.4, crack);
	} else if (style == 6) { // Forest: bark streaks on the sides, tree rings on top.
		if (top || bottom) {
			float rings = fract(length(uv) * 9.0 + fbm(suv * 2.0) * 0.6);
			col = mix(vec3(0.83, 0.64, 0.42), vec3(0.62, 0.43, 0.26), smoothstep(0.6, 0.9, rings));
		} else {
			float streak = fbm(vec2(suv.x * 9.0, suv.y * 1.2));
			col *= 0.72 + 0.45 * streak;
		}
	} else if (style == 7) { // Crystal cave: stone facets with amethyst flecks.
		vec2 v = voronoi(suv * 3.0);
		col *= 0.8 + 0.3 * v.y;
		col *= mix(0.7, 1.0, smoothstep(0.0, 0.06, v.x));
		float gem = step(0.93, hash21(floor(suv * 6.0))) * circle(fract(suv * 6.0), vec2(0.5), 0.22);
		col = mix(col, accent_color, gem);
		emit += accent_color * gem * glow;
	} else if (style == 8) { // Clockwork: navy panel in a brass frame with rivets.
		float frame = smoothstep(0.33, 0.35, face_edge);
		vec2 q = abs(uv);
		float rivet = circle(q, vec2(0.41), 0.035);
		float inset = smoothstep(0.30, 0.33, face_edge) - frame;
		col = mix(col, accent_color, max(frame, rivet));
		col *= 1.0 - inset * 0.35;
		rough = mix(0.55, 0.22, max(frame, rivet));
		if (top) {
			float r = length(uv);
			float a = atan(uv.y, uv.x);
			float gear = 1.0 - smoothstep(0.17, 0.18, r - 0.03 * step(0.0, sin(a * 8.0))) ;
			gear *= smoothstep(0.05, 0.06, r);
			col = mix(col, accent_color, gear * detail);
		}
	} else if (style == 9) { // Neon: dark glass with glowing circuit traces.
		float border = smoothstep(0.395, 0.405, face_edge) * (1.0 - smoothstep(0.43, 0.44, face_edge));
		vec2 g = fract(suv * 2.0) - 0.5;
		float trace = (1.0 - smoothstep(0.015, 0.03, abs(g.x))) * step(0.5, hash21(floor(suv * 2.0)))
			+ (1.0 - smoothstep(0.015, 0.03, abs(g.y))) * step(0.5, hash21(floor(suv * 2.0) + 5.0));
		float line = clamp(border + trace * detail * step(face_edge, 0.39), 0.0, 1.0);
		col = mix(col * 0.55, glow_color, line);
		emit += glow_color * line * glow;
		rough = 0.25;
	} else if (style == 10) { // Celestial: violet nebula with twinkling stars.
		float neb = fbm(suv * 2.2 + fbm(suv * 1.3) * 1.5);
		col = mix(col * 0.55, accent_color, smoothstep(0.45, 0.85, neb) * 0.7);
		vec2 cell = floor(suv * 5.0);
		float s = step(0.86, hash21(cell)) * star4(fract(suv * 5.0), vec2(0.5), 0.28);
		float tw = 0.6 + 0.4 * sin(TIME * 3.0 + hash21(cell) * 20.0);
		col = mix(col, vec3(1.0, 0.95, 0.75), s);
		emit += vec3(1.0, 0.92, 0.7) * s * glow * tw;
	} else if (style == 11) { // Tumble Fair: pink and cream candy stripes.
		float s = step(0.5, fract((an.y > 0.5 ? (uv.x + uv.y) : uv.x) * 3.0 + 0.25));
		col = mix(accent_color, col, s);
		rough = 0.35;
	} else if (style == 12) { // Dune Bazaar: speckled sandstone with a teal arabesque band.
		col *= 0.9 + 0.2 * fbm(suv * 6.0);
		col = mix(col, col * 0.75, step(0.9, hash21(floor(suv * 14.0))));
		if (!top && !bottom) {
			float band = 1.0 - smoothstep(0.11, 0.13, abs(p.y - 0.05 + sin(uv.x * 18.0) * 0.03));
			float lobe = circle(vec2(fract(uv.x * 2.0 + 0.5), p.y), vec2(0.5, -0.2), 0.12) * (1.0 - band);
			col = mix(col, accent_color, max(band, lobe) * detail);
			col = mix(col, glow_color, (1.0 - smoothstep(0.42, 0.44, -p.y)) * 0.0 + smoothstep(0.43, 0.46, abs(p.y)) * 0.6);
		}
	}

	// Biome cap on the top face and a dripping band down the sides (grass, icing, snow, moss).
	if (cap_depth > 0.0) {
		float wobble = (fbm(vec2((an.x > 0.5 ? p.z : p.x) * 9.0 + seed * 5.0, seed)) - 0.5) * 2.0;
		float along = (an.x > 0.5 ? p.z : p.x);
		float drip = cap_drip * (style == 1 || style == 6 ? abs(sin(along * 16.0 + seed * 9.0)) : 0.5 + 0.5 * sin(along * 11.0 + seed * 9.0));
		float limit = 0.5 - cap_depth - drip - wobble * 0.03;
		float cap = top ? 1.0 : (bottom ? 0.0 : smoothstep(limit - 0.012, limit + 0.012, p.y));
		vec3 cc = cap_color * (0.82 + 0.3 * fbm(suv * 9.0));
		if (style == 1 && top) { // clover/flower dots on grass tops
			float flower = step(0.96, hash21(floor(suv * 5.0))) * circle(fract(suv * 5.0), vec2(0.5), 0.18);
			cc = mix(cc, vec3(1.0, 0.98, 0.9), flower);
		}
		col = mix(col, cc, cap);
		rough = mix(rough, style == 2 ? 0.15 : 0.8, cap);
	}

	// Soft bevel light, darker underside: chunky toy readability.
	col *= mix(0.78, 1.0, smoothstep(-0.5, 0.15, p.y));
	col *= mix(1.0, 0.82, smoothstep(0.44, 0.5, edge) * (1.0 - float(top)) * 0.6);

	float stripe = 0.0;
	int code = int(floor(motif * 16.0 + 0.1));
	if (code == 1) stripe = step(0.8, fract(uv.y * 5.0));
	if (code == 2) stripe = 1.0 - step(0.16, length(fract(uv * 4.0) - vec2(0.5)));
	if (code == 3) stripe = step(0.8, fract(uv.y * 4.0 + sin(uv.x * 12.0) * 0.18));
	if (code == 4) stripe = mod(floor(uv.x * 4.0) + floor(uv.y * 4.0), 2.0);
	if (code == 5) stripe = step(0.8, fract(length(uv) * 8.0));
	if (code == 6) stripe = max(step(0.85, fract(uv.y * 4.0)), step(0.88, fract(uv.x * 4.0 + floor(uv.y * 4.0) * 0.5)));
	if (patterns) col *= 1.0 - stripe * (high_contrast ? 0.58 : 0.26);
	if (stickers > 0) {
		vec2 badge = uv - vec2(0.23, 0.23);
		float mark = 0.0;
		if (stickers % 3 == 0) mark = 1.0 - step(0.055, abs(badge.x) + abs(badge.y));
		if (stickers % 3 == 1) mark = 1.0 - step(0.048, length(badge));
		if (stickers % 3 == 2) mark = (1.0 - step(0.048, abs(badge.x))) * (1.0 - step(0.025, abs(badge.y)));
		col = mix(col, vec3(0.97, 0.92, 0.77), mark * 0.8);
	}

	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	ALBEDO = col * brightness;
	ROUGHNESS = rough;
	SPECULAR = 0.5;
	EMISSION = emit + mix(col, vec3(1.0), 0.5) * fres * rim;
}
