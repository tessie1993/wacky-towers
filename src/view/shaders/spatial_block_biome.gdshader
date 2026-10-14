// spatial_block_biome: Wacky Towers biome block look (technical art, v3 2026-10-13).
// One procedural shader for every biome cube. Works in Compatibility (opengl3), Mobile and
// Forward+: no texture samples, no screen/depth reads. Style is a uniform (coherent branch).
// Budget: <= 2 Voronoi (3x3) + ~8 value-noise taps per pixel.
// v3: painted light() (wrap, purple-tinted shadow side, soft highlight blob) from the style-R&D
// prototype (prototypes/style_rnd/spatial_proto_painted_block.gdshader); thicker biome caps,
// side motifs matched to ref 13 (clover, snowflake, rings, gear, circuit diamond, arabesque).
// Look law: assets/art/reference/style/13_biome_blocks.png (design/art/art-bible.md section 6).
// Per-biome values come from assets/data/biome_looks.json (biomes.<id>.block) via WtBlockMaterials.
// Piece colour = instance COLOR; body_mix says how much of the biome body colour replaces it.
shader_type spatial;
render_mode cull_back;

// Biome style: 0 plain, 1 meadow, 2 candy, 3 ice, 4 underwater, 5 lava, 6 forest,
// 7 cave, 8 clockwork, 9 neon, 10 celestial, 11 carnival, 12 dune bazaar.
uniform int style = 0;
uniform vec3 cap_color : source_color = vec3(0.45, 0.72, 0.30);
// Cap thickness down the sides (cube units, 0 = no cap).
uniform float cap_depth : hint_range(0.0, 0.6) = 0.0;
// Ragged/drip amplitude of the cap's lower edge.
uniform float cap_drip : hint_range(0.0, 0.3) = 0.08;
// How far the cap overhangs the body (vertex displacement, cube units).
uniform float cap_lip : hint_range(0.0, 0.15) = 0.03;
uniform vec3 body_color : source_color = vec3(0.55, 0.40, 0.27);
// 0 = pure piece colour, 1 = pure biome body colour.
uniform float body_mix : hint_range(0.0, 1.0) = 0.0;
uniform vec3 accent_color : source_color = vec3(1.0);
uniform vec3 glow_color : source_color = vec3(1.0, 0.5, 0.1);
uniform float glow : hint_range(0.0, 4.0) = 0.0;
uniform float gloss : hint_range(0.0, 1.0) = 0.4;
uniform float rim : hint_range(0.0, 1.0) = 0.15;
uniform float detail : hint_range(0.0, 1.0) = 1.0;
uniform float brightness : hint_range(0.5, 1.6) = 1.0;
// Sky tint used for the rim light and the fake reflection (set from the biome sky colours).
uniform vec3 rim_color : source_color = vec3(0.70, 0.85, 1.0);
// Strength of the painted lit bevel along cube edges.
uniform float bevel_light : hint_range(0.0, 1.0) = 0.45;
// How strongly procedural normals sculpt the faces.
uniform float sculpt : hint_range(0.0, 2.0) = 1.0;
// Painted light response (prototype values): shadows go purple, never grey.
uniform vec3 shadow_tint : source_color = vec3(0.42, 0.36, 0.62);
uniform float wrap : hint_range(0.0, 1.0) = 0.3;
uniform float band_soft : hint_range(0.01, 1.0) = 0.35;
// Fake translucency: light glowing through the body (jelly, ice, glass).
uniform float translucency : hint_range(0.0, 1.0) = 0.0;
group_uniforms piece_colour;
// v4 polish (ref 15): the instance COLOR is authored sRGB (palette hex), so it is linearised
// before use; then pushed per biome so every piece reads as its own bright colour.
/** Saturation multiplier on the piece colour (1 = authored). */
uniform float piece_sat : hint_range(0.0, 2.5) = 1.0;
/** Value multiplier on the piece colour (1 = authored). */
uniform float piece_value : hint_range(0.3, 1.6) = 1.0;
/** Hue remap: when x < y the piece hue (0..1) is squeezed into [x, y] (ice: cyan..pink jelly). */
uniform vec2 piece_hue_range = vec2(0.0, 0.0);
/** Albedo multiplier on side faces vs the top: painted key/shade separation (1 = off). */
uniform float side_shade : hint_range(0.3, 1.0) = 1.0;
/** Extra darkening of the side faces turned away from the key light (0 = off). */
uniform float shade_side_extra : hint_range(0.0, 0.6) = 0.0;
/** 1 = treat COLOR as sRGB and linearise it (correct); 0 = legacy raw use (washed out). */
uniform float piece_linear : hint_range(0.0, 1.0) = 1.0;
group_uniforms;
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

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + 1e-10)), d / (q.x + 1e-10), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}
float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float hash31(vec3 p) { return hash21(p.xy + p.z * 17.17); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vnoise(p) * 0.55 + vnoise(p * 2.1) * 0.3 + vnoise(p * 4.3) * 0.15; }
float hnoise(vec2 p) { return vnoise(p) * 0.65 + vnoise(p * 2.3) * 0.35; }
// Distance to the nearest Voronoi border (x), the cell id (y).
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
vec2 facet(float id) { return vec2(hash21(vec2(id, 1.3)), hash21(vec2(id, 7.1))) - 0.5; }
float circle(vec2 uv, vec2 c, float r) { return 1.0 - smoothstep(r - 0.012, r + 0.012, length(uv - c)); }
// Four-point sparkle star.
float star4(vec2 uv, vec2 c, float r) {
	vec2 d = abs(uv - c) / r;
	return 1.0 - smoothstep(0.9, 1.1, pow(d.x, 0.5) + pow(d.y, 0.5));
}
// Five-point star (filled), radius r.
float star5(vec2 q, float r) {
	float a = atan(q.y, q.x) + 1.5708;
	float seg = 1.2566;
	float k = abs(mod(a, seg) - seg * 0.5) / (seg * 0.5);
	float rr = mix(r * 0.45, r, k);
	return 1.0 - smoothstep(rr - 0.01, rr + 0.01, length(q));
}
// Six-arm snowflake line mask, radius r.
float snowflake(vec2 q, float r) {
	float a = atan(q.y, q.x);
	float l = length(q);
	float s = mod(a + 0.5236, 1.0472) - 0.5236;
	vec2 f = vec2(cos(s), abs(sin(s))) * l;
	float arm = (1.0 - smoothstep(0.012, 0.022, f.y)) * step(f.x, r);
	vec2 b = f - vec2(r * 0.55, 0.0);
	float br = (1.0 - smoothstep(0.012, 0.022, abs(b.y - b.x * 0.9))) * step(0.0, b.x) * step(b.x, r * 0.28);
	float hub = circle(q, vec2(0.0), r * 0.16);
	return clamp(arm + br + hub, 0.0, 1.0);
}
float bell(float a, float b, float x) { float t = smoothstep(a, b, x); return 4.0 * t * (1.0 - t); }
vec2 rdir(vec2 q) { return abs(q.x) > abs(q.y) ? vec2(sign(q.x), 0.0) : vec2(0.0, sign(q.y)); }
// Coordinate that wraps continuously around the four sides (for ragged cap edges).
float around(vec3 p) { return abs(p.x) > abs(p.z) ? (p.x > 0.0 ? 1.0 + p.z : 3.0 - p.z) : (p.z > 0.0 ? 2.0 - p.x : p.x); }

void vertex() {
	lp = VERTEX; ln = NORMAL;
	motif = INSTANCE_CUSTOM.r; cell_alpha = use_cell_alpha ? INSTANCE_CUSTOM.a : 1.0;
	center = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	if (cap_depth > 0.0) {
		// Overhanging cap: the top band swells outward with a ragged lip (grass, icing, snow).
		float sd = hash31(floor(center * 1.01 + 0.5));
		float band = smoothstep(0.5 - cap_depth - 0.1, 0.5 - cap_depth * 0.4, VERTEX.y);
		float rag = 0.65 + 0.7 * vnoise(vec2(around(VERTEX) * 7.0 + sd * 9.0, 0.0));
		VERTEX.xz *= 1.0 + band * cap_lip * 2.0 * rag;
		VERTEX.y += band * cap_lip * 0.8;
	}
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
	bool side = !top && !bottom;
	vec2 uv = an.y > 0.5 ? p.xz : (an.x > 0.5 ? vec2(-sign(ln.x) * p.z, p.y) : vec2(sign(ln.z) * p.x, p.y));
	vec3 axu = an.y > 0.5 ? vec3(1.0, 0.0, 0.0) : (an.x > 0.5 ? vec3(0.0, 0.0, -sign(ln.x)) : vec3(sign(ln.z), 0.0, 0.0));
	vec3 axv = an.y > 0.5 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
	vec3 tu = normalize((VIEW_MATRIX * (MODEL_MATRIX * vec4(axu, 0.0))).xyz);
	vec3 tv = normalize((VIEW_MATRIX * (MODEL_MATRIX * vec4(axv, 0.0))).xyz);
	float seed = hash31(floor(center * 1.01 + 0.5));
	// Per-face seed so two faces of one cube do not carry the same motif placement.
	float fseed = hash21(vec2(seed * 31.0, dot(sign(ln) * step(0.5, an), vec3(1.0, 2.0, 3.0))));
	vec2 suv = uv + seed * 7.0 + fseed * 3.0;
	float face_edge = an.y > 0.5 ? max(abs(p.x), abs(p.z)) : (an.x > 0.5 ? max(abs(p.z), abs(p.y)) : max(abs(p.x), abs(p.y)));
	// Rounded-edge mask: second-largest |axis| reaching into the bevel zone.
	vec3 ea = clamp((abs(p) - 0.36) / 0.14, 0.0, 1.0);
	float emx = max(ea.x, max(ea.y, ea.z));
	float bevel = smoothstep(0.15, 1.0, ea.x + ea.y + ea.z - emx - min(ea.x, min(ea.y, ea.z)));
	vec2 vt = vec2(dot(VIEW, tu), dot(VIEW, tv));

	// Piece colour: authored sRGB -> HSV push (hue squeeze, saturation, value) -> linear.
	vec3 phsv = rgb2hsv(clamp(COLOR.rgb, 0.0, 1.0));
	if (piece_hue_range.x < piece_hue_range.y) phsv.x = mix(piece_hue_range.x, piece_hue_range.y, phsv.x);
	phsv.y = clamp(phsv.y * piece_sat, 0.0, 1.0);
	phsv.z = clamp(phsv.z * piece_value, 0.0, 1.0);
	vec3 prgb = hsv2rgb(phsv);
	vec3 piece = mix(prgb, pow(prgb, vec3(2.2)), piece_linear);
	vec3 col = mix(piece, body_color, body_mix);
	vec3 emit = vec3(0.0);
	float rough = 1.0 - gloss;
	vec2 g = vec2(0.0);
	float refl = gloss * 0.3;
	float cavity = 0.0;
	float inner = 1.0 - smoothstep(0.08, 0.5, face_edge);   // face centre -> rim

	if (style == 1) { // Meadow: layered dirt, pebbles, clover leaves on the dirt.
		float paint = fbm(suv * 3.0);
		col *= mix(0.78, 1.08, smoothstep(0.25, 0.75, paint));
		float layer = smoothstep(0.45, 0.55, fract(p.y * 2.6 + paint * 0.5));
		col *= mix(0.88, 1.05, layer);
		float dn = hnoise(suv * 11.0);
		g += vec2(hnoise((suv + vec2(0.03, 0.0)) * 11.0) - dn, hnoise((suv + vec2(0.0, 0.03)) * 11.0) - dn) * 2.0;
		vec2 pc = fract(suv * 2.6) - 0.5;
		float pid = step(0.6, hash21(floor(suv * 2.6)));
		float peb = circle(pc, vec2(0.0), 0.1) * pid * detail;
		vec3 peb_col = mix(vec3(0.5, 0.48, 0.48), vec3(0.86, 0.84, 0.8), clamp(0.5 - pc.y * 3.0 + pc.x * 2.0, 0.0, 1.0));
		col *= 1.0 - (circle(pc, vec2(0.02, -0.02), 0.13) - peb) * pid * 0.35;
		col = mix(col, peb_col, peb);
		g += -pc * 3.0 * peb;
		// Clover on some faces: three round leaves.
		if (side && fseed > 0.55) {
			vec2 cq = uv - vec2(-0.18 + fseed * 0.2, -0.2);
			float cl = max(circle(cq, vec2(0.0, 0.045), 0.045), max(circle(cq, vec2(-0.042, -0.02), 0.045), circle(cq, vec2(0.042, -0.02), 0.045)));
			col = mix(col, vec3(0.32, 0.62, 0.22) * (0.9 + 0.3 * step(0.0, cq.y)), cl * detail);
		}
	} else if (style == 2) { // Candy: translucent jelly with a bright core and a glossy window sheen.
		col = mix(col * 0.82, col * 1.18 + 0.06, inner);
		emit += col * 0.22 * inner;
		float w = vnoise(suv * 2.0);
		g += vec2(vnoise((suv + vec2(0.05, 0.0)) * 2.0) - w, vnoise((suv + vec2(0.0, 0.05)) * 2.0) - w) * 1.2;
		vec2 q = (uv - vec2(-0.16, 0.14)) * vec2(1.0, 1.8);
		float sheen = (1.0 - smoothstep(0.08, 0.14, abs(q.x) + abs(q.y) * 0.5)) * float(side);
		emit += vec3(1.0, 0.96, 0.96) * sheen * 0.22;
		refl = 0.5;
	} else if (style == 3) { // Ice: frosted translucent blue, inner cracks, snowflake emboss, sparkles.
		vec2 v = voronoi(suv * 2.6);
		vec2 v2 = voronoi((suv - vt * 0.16) * 1.8 + 4.0);
		float inner_crack = 1.0 - smoothstep(0.0, 0.05, v2.x);
		col = mix(col * 0.8, col * 1.08 + vec3(0.02, 0.04, 0.08), inner);
		col = mix(col, vec3(0.85, 0.95, 1.0), inner_crack * 0.35 * detail);
		col = mix(col, vec3(0.95, 0.99, 1.0), (1.0 - smoothstep(0.0, 0.035, v.x)) * 0.25 * detail);
		float frost = smoothstep(0.3, 0.48, face_edge) * (0.5 + 0.5 * vnoise(suv * 14.0));
		col = mix(col, vec3(0.9, 0.96, 1.0), frost * 0.35);
		g += facet(v.y) * 0.25;
		if (side && fseed > 0.5) {
			float sf = snowflake(uv - vec2(0.0, -0.04), 0.2) * detail;
			col = mix(col, vec3(0.97, 0.99, 1.0), sf);
			g += normalize(uv + 0.001) * sf * 0.3;
		}
		vec2 sc = fract(suv * 5.0) - 0.5;
		float sp = step(0.88, hash21(floor(suv * 5.0))) * star4(sc, vec2(0.0), 0.16);
		col = mix(col, vec3(1.0), sp);
		emit += vec3(0.8, 0.95, 1.0) * (sp * 0.6 + inner_crack * 0.06);
		refl = 0.55;
	} else if (style == 4) { // Underwater: faceted deep blue/violet glass, bubbles inside, sparkles.
		vec2 fv = voronoi(suv * 2.6 + 11.0);
		col = mix(col, col.r * vec3(2.2, 0.9, 1.0) + col.b * vec3(0.35, 0.1, 0.75), step(0.55, fv.y) * (0.3 + 0.35 * fv.y));
		col = mix(col * 0.65, col * 1.15, inner * 0.6 + fbm(suv * 3.0) * 0.4);
		col *= mix(0.8, 1.08, smoothstep(0.0, 0.08, fv.x));
		col += vec3(0.25, 0.35, 0.6) * (1.0 - smoothstep(0.0, 0.03, fv.x)) * 0.5;
		g += facet(fv.y) * 0.35;
		vec2 bp = suv - vt * 0.08;
		vec2 cell = floor(bp * 3.0);
		float has = step(0.55, hash21(cell));
		vec2 c = vec2(0.3) + vec2(hash21(cell + 1.0), hash21(cell + 2.0)) * 0.4;
		float r = 0.07 + hash21(cell + 3.0) * 0.08;
		vec2 bq = fract(bp * 3.0);
		float ring = circle(bq, c, r) - circle(bq, c, r - 0.03);
		float hi = circle(bq, c + vec2(-r, r) * 0.4, r * 0.28);
		col = mix(col, vec3(0.8, 0.92, 1.0), (ring * 0.55 + hi) * has * detail);
		col = mix(col, col * 1.2, circle(bq, c, r) * has * 0.5);
		float sp = step(0.9, hash21(floor(suv * 7.0))) * star4(fract(suv * 7.0) - 0.5, vec2(0.0), 0.12);
		emit += vec3(0.8, 0.9, 1.0) * sp * 0.6 + accent_color * 0.05;
		refl = 0.55;
	} else if (style == 5) { // Lava: big chunky basalt plates, each a painted bevelled slab, wide glowing seams.
		// Large Voronoi slabs (2-3 per face) with a noise-warped border so seams wander like paint.
		vec2 wq = suv * 1.6 + (vec2(vnoise(suv * 2.5), vnoise(suv * 2.5 + 7.0)) - 0.5) * 0.35;
		vec2 v = voronoi(wq);
		float wobble = vnoise(suv * 6.0) * 0.03;               // uneven seam width (painted stroke)
		float crack = 1.0 - smoothstep(0.035 + wobble, 0.075 + wobble, v.x);
		float hot = 1.0 - smoothstep(0.0, 0.02 + wobble * 0.5, v.x);
		float halo = 1.0 - smoothstep(0.07, 0.2, v.x);
		// Slab paint: flat 2-tone with a lit upper-left rim and a dark lower lip (hand-painted bevel).
		vec2 tilt = facet(v.y);
		float slab_lit = smoothstep(0.08, 0.16, v.x) * (1.0 - smoothstep(0.16, 0.3, v.x));
		col *= 0.78 + 0.3 * v.y;
		col *= 0.9 + 0.18 * smoothstep(0.35, 0.7, fbm(suv * 2.5));
		col = mix(col, col * 1.45 + vec3(0.04, 0.03, 0.03), slab_lit * clamp(0.5 + tilt.y - tilt.x, 0.0, 1.0) * 0.6);
		col *= mix(0.55, 1.0, smoothstep(0.05, 0.13, v.x));
		g += tilt * 0.45 + (rdir(tilt) * 0.0);
		g += (hnoise(suv * 9.0) - 0.5) * 0.12;
		col += glow_color * halo * 0.1;
		vec3 hot_col = mix(glow_color, vec3(1.0, 0.62, 0.25), hot * 0.6);
		col = mix(col, hot_col, crack);
		emit += glow_color * (crack * glow * 0.85 + halo * 0.12 * glow) + vec3(1.0, 0.6, 0.2) * hot * glow * 0.35;
		rough = mix(0.85, 0.4, crack);
		refl = 0.08;
	} else if (style == 6) { // Forest: chunky bark slabs, tree-ring end grain on some faces, moss patches.
		bool rings_face = top || (side && fseed > 0.62);
		if (rings_face) {
			float rr = length(uv * vec2(1.0, 1.08)) * 7.5 + fbm(suv * 1.6) * 0.8;
			float ring_line = smoothstep(0.6, 0.8, fract(rr)) * (1.0 - smoothstep(0.85, 0.98, fract(rr)));
			col = mix(vec3(0.86, 0.66, 0.42), vec3(0.62, 0.42, 0.24), ring_line * 0.85);
			col *= 1.05 - length(uv) * 0.3;
			g += normalize(uv + 0.0001) * (ring_line - 0.5) * 0.12;
			// Thick bark collar with a lit inner lip.
			float collar = smoothstep(0.36, 0.42, face_edge);
			col = mix(col, vec3(0.95, 0.78, 0.52), bell(0.33, 0.39, face_edge) * 0.5);
			col = mix(col, body_color * 0.75 * (0.85 + 0.3 * vnoise(suv * 6.0)), collar);
		} else {
			// Bark slabs: Voronoi stretched vertically = 3-4 long plates per face, separated by deep
			// dark fissures; each plate painted with a lit left edge and a soft shadowed right edge.
			vec2 bq = vec2(suv.x * 4.5, suv.y * 0.75) + vec2(vnoise(suv * 3.0) * 0.35, 0.0);
			vec2 v = voronoi(bq);
			float fissure = 1.0 - smoothstep(0.03, 0.09, v.x);
			vec2 tilt = facet(v.y);
			col *= 0.8 + 0.3 * v.y;
			col *= 0.88 + 0.2 * smoothstep(0.3, 0.7, fbm(vec2(suv.x * 4.0, suv.y * 1.2)));
			float lip = smoothstep(0.1, 0.18, v.x) * (1.0 - smoothstep(0.18, 0.32, v.x));
			col = mix(col, col * 1.35 + vec3(0.04, 0.03, 0.01), lip * clamp(0.4 - tilt.x * 1.5, 0.0, 1.0));
			col = mix(col, col * vec3(0.45, 0.36, 0.32), fissure * 0.85);
			cavity += fissure * 0.15;
			g += vec2(tilt.x * 0.6, tilt.y * 0.2);
		}
		// Moss patches creeping over the bark, from the top edge down.
		float moss = smoothstep(0.66, 0.72, fbm(suv * 2.3 + 5.0) + (p.y - 0.2) * 0.25) * float(side);
		col = mix(col, cap_color * (0.6 + 0.5 * vnoise(suv * 24.0)), moss * detail);
		rough = mix(rough, 0.95, moss);
	} else if (style == 7) { // Crystal cave: chunky stone plates with embedded purple crystals.
		vec2 v = voronoi(suv * 2.4);
		col *= 0.78 + 0.32 * v.y;
		float crease = smoothstep(0.0, 0.07, v.x);
		col *= mix(0.5, 1.0, crease);
		col += vec3(0.07, 0.06, 0.09) * (1.0 - smoothstep(0.07, 0.14, v.x)) * crease;
		g += facet(v.y) * 0.7 * sculpt + (hnoise(suv * 16.0) - 0.5) * 0.15;
		cavity += (1.0 - crease) * 0.25;
		vec2 gc = fract(suv * 3.2) - 0.5;
		float gid = step(0.78, hash21(floor(suv * 3.2)));
		float gem = (1.0 - smoothstep(0.17, 0.2, abs(gc.x) * 1.5 + abs(gc.y) * 0.75)) * gid * detail;
		vec3 gcol = accent_color * (gc.x < 0.0 ? 1.25 : 0.75) + vec3(0.25) * step(0.1, gc.y) * step(gc.x, 0.0);
		col = mix(col, gcol, gem);
		g += vec2(-sign(gc.x), 0.0) * 0.5 * gem;
		emit += accent_color * gem * glow * 0.6;
		refl = 0.08 + 0.4 * gem;
		rough = mix(rough, 0.25, gem);
	} else if (style == 8) { // Clockwork: navy panel in a bevelled brass frame, rivets, gear emboss.
		float frame = smoothstep(0.325, 0.34, face_edge);
		vec2 q = abs(uv);
		float rivet = circle(q, vec2(0.415), 0.035);
		g += rdir(uv) * (bell(0.31, 0.35, face_edge) * 0.9 - bell(0.45, 0.5, face_edge) * 0.4);
		g += (q - vec2(0.415)) * 14.0 * rivet * sign(uv);
		vec3 brass = accent_color * (0.85 + 0.35 * hnoise(suv * 8.0));
		brass = mix(brass, brass * 1.25 + 0.04, bell(0.33, 0.38, face_edge));
		col *= mix(0.7, 1.08, inner);
		col += vec3(0.05, 0.06, 0.1) * smoothstep(0.1, -0.25, uv.x - uv.y);
		col *= 0.92 + 0.12 * fbm(suv * 6.0);
		float metal = max(frame, rivet);
		col = mix(col, brass, metal);
		col *= 1.0 - (smoothstep(0.29, 0.325, face_edge) - frame) * 0.5;
		if ((top && fseed > 0.4) || (side && fseed > 0.7)) {
			float r = length(uv);
			float a = atan(uv.y, uv.x);
			float gear = 1.0 - smoothstep(0.15, 0.16, r - 0.035 * step(0.0, sin(a * 8.0)));
			gear *= smoothstep(0.045, 0.055, r) * (1.0 - (circle(uv, vec2(0.0), 0.11) - circle(uv, vec2(0.0), 0.075)));
			col = mix(col, brass, gear * detail);
			g += normalize(uv + 0.001) * bell(0.1, 0.2, r) * gear * 0.4;
			metal = max(metal, gear);
		}
		rough = mix(0.55, 0.22, metal);
		refl = mix(0.12, 0.6, metal);
	} else if (style == 9) { // Neon: dark glass, bevelled border, glowing circuit traces and a diamond.
		float border = smoothstep(0.36, 0.37, face_edge) * (1.0 - smoothstep(0.395, 0.41, face_edge));
		vec2 pu = suv - vt * 0.04;
		vec2 gq = fract(pu * 1.6) - 0.5;
		float trace = (1.0 - smoothstep(0.012, 0.024, abs(gq.x))) * step(0.5, hash21(floor(pu * 1.6)))
			+ (1.0 - smoothstep(0.012, 0.024, abs(gq.y))) * step(0.5, hash21(floor(pu * 1.6) + 5.0));
		float node = circle(gq, vec2(0.0), 0.05) * step(0.6, hash21(floor(pu * 1.6) + 9.0));
		float diamond = 0.0;
		if (side && fseed > 0.6) {
			float dd = abs(uv.x) + abs(uv.y - 0.02);
			diamond = (1.0 - smoothstep(0.012, 0.024, abs(dd - 0.12)));
		}
		float line = clamp(border * 0.6 + (trace + node) * detail * step(face_edge, 0.34) + diamond, 0.0, 1.0);
		col = mix(col * 0.45, col * 0.95, inner * 0.6 + fbm(suv * 2.0) * 0.3);
		col = mix(col, glow_color, line);
		emit += glow_color * line * glow + glow_color * 0.05 * smoothstep(0.3, 0.45, face_edge);
		g += rdir(uv) * bell(0.33, 0.39, face_edge) * 0.5;
		rough = 0.15;
		refl = 0.55;
	} else if (style == 10) { // Celestial: purple galaxy window with nebula swirl and gold stars.
		vec2 nuv = suv - vt * 0.12;
		float neb = fbm(nuv * 1.8 + fbm(nuv * 1.2) * 1.8);
		col = mix(col * 0.55, accent_color, smoothstep(0.42, 0.8, neb) * 0.85);
		col += vec3(1.0, 0.7, 0.9) * smoothstep(0.68, 0.9, neb) * 0.35;
		vec2 s2uv = suv - vt * 0.2;
		vec2 cell = floor(s2uv * 3.0);
		float s = step(0.72, hash21(cell)) * star4(fract(s2uv * 3.0), vec2(0.5) + (vec2(hash21(cell + 1.0), hash21(cell + 2.0)) - 0.5) * 0.4, 0.16);
		vec2 cell2 = floor((suv - vt * 0.05) * 10.0);
		float s3 = step(0.88, hash21(cell2 + 3.0)) * circle(fract((suv - vt * 0.05) * 10.0), vec2(0.5), 0.09);
		float big = (side && fseed > 0.6) ? star4(uv, vec2(0.05, -0.05), 0.12) : 0.0;
		float sm = max(max(s, big), s3 * 0.8);
		col = mix(col, vec3(1.0, 0.88, 0.6), sm);
		emit += vec3(1.0, 0.88, 0.6) * (max(s, big) * glow * 0.9 + s3 * 0.4) + accent_color * smoothstep(0.6, 0.9, neb) * 0.15 * glow;
		refl = 0.45;
	} else if (style == 11) { // Tumble Fair: pink and cream vertical stripes, puffy, cream skirt on top.
		float sx = (top ? (uv.x + uv.y) * 0.7 : uv.x) * 3.0 + 0.5;
		float fs = fract(sx);
		float s = step(0.5, fs);
		col = mix(accent_color, col, s);
		g += vec2(sin(fs * 6.2832) * -0.12, 0.0);
		col *= 1.0 - (1.0 - smoothstep(0.0, 0.05, min(abs(fs - 0.5), min(fs, 1.0 - fs)))) * 0.12;
		rough = 0.3;
		refl = 0.45;
	} else if (style == 12) { // Dune Bazaar: grainy sandstone, teal scalloped band, fleur inlay.
		float grain = hnoise(suv * 22.0);
		col *= 0.88 + 0.22 * fbm(suv * 6.0);
		vec2 spk = fract(suv * 9.0) - 0.5;
		col = mix(col, glow_color * 0.75, step(0.75, hash21(floor(suv * 9.0))) * circle(spk, vec2(0.0), 0.12 + 0.12 * hash21(floor(suv * 9.0) + 2.0)) * 0.7);
		g += vec2(hnoise((suv + vec2(0.02, 0.0)) * 22.0) - grain, hnoise((suv + vec2(0.0, 0.02)) * 22.0) - grain) * 0.6;
		if (side) {
			float wave = p.y - 0.2 + abs(sin(uv.x * 7.85)) * 0.06;
			float band = 1.0 - smoothstep(0.065, 0.08, abs(wave));
			vec2 fq = uv - vec2(0.0, -0.12);
			float fleur = max(circle(fq, vec2(0.0, 0.03), 0.07), max(circle(fq, vec2(-0.09, -0.04), 0.05), circle(fq, vec2(0.09, -0.04), 0.05)));
			fleur = max(fleur, (1.0 - smoothstep(0.02, 0.03, abs(fq.x))) * step(-0.19, fq.y) * step(fq.y, 0.0));
			float m = max(band, fleur * step(0.35, fseed)) * detail;
			col = mix(col, accent_color * (0.85 + 0.25 * vnoise(suv * 9.0)), m);
			g += vec2(0.0, -sign(wave)) * bell(0.06, 0.09, abs(wave)) * 0.4;
			rough = mix(rough, 0.4, m);
		}
		col = mix(col, glow_color, smoothstep(0.43, 0.47, face_edge) * 0.5);
	}

	// Biome cap: top face plus a ragged band down the sides (grass, frosting, snow).
	if (cap_depth > 0.0) {
		float along = around(p);
		float drip;
		if (style == 3) { // icicles: sharp triangles of random length
			float k = along * 6.0 + seed * 3.0;
			float tri = abs(fract(k) - 0.5) * 2.0;
			float len = 0.3 + 0.9 * hash21(vec2(floor(k), seed));
			drip = cap_drip * 2.4 * len * pow(1.0 - tri, 2.0);
		} else if (style == 1 || style == 6) { // grass: hanging strands
			drip = cap_drip * (0.35 + 0.65 * vnoise(vec2(along * 28.0 + seed * 9.0, 0.0))) + cap_drip * 0.6 * fbm(vec2(along * 5.0 + seed, 1.0));
		} else { // frosting: round blobby drips
			float ph = along * 9.0 + seed * 9.0;
			drip = cap_drip * pow(max(0.0, sin(ph)), 3.0) * (0.6 + 0.6 * hash21(vec2(floor(ph / 6.2832), seed))) * 1.8;
		}
		float limit = 0.5 - cap_depth - drip;
		float sd = (style == 3) ? 0.006 : 0.012;
		float cap = top ? 1.0 : (bottom ? 0.0 : smoothstep(limit - sd, limit + sd, p.y));
		float cap_edge = side ? (1.0 - smoothstep(0.0, 0.06, p.y - limit)) * cap : 0.0;
		float tuft = fbm(p.xz * 9.0 + seed * 5.0) * 0.6 + fbm(vec2(along * 14.0, p.y * 3.0)) * 0.4;
		vec3 cc = cap_color;
		if (style == 1 || style == 6) {
			vec3 dark = cap_color * vec3(0.5, 0.68, 0.5);
			vec3 light = cap_color * vec3(1.25, 1.2, 1.0) + vec3(0.02, 0.03, 0.0);
			cc = mix(dark, cap_color, smoothstep(0.2, 0.6, tuft));
			cc = mix(cc, light, smoothstep(0.55, 0.8, tuft));
			cc = mix(cc, dark, cap_edge * 0.5);
			float blade = vnoise(vec2(along * 60.0, p.y * 4.0));
			if (side) g += vec2(blade - 0.5, 0.0) * 1.2 * cap;
			if (top) {
				g += vec2(hnoise(suv * 22.0 + 1.0) - 0.5, hnoise(suv * 22.0 + 9.0) - 0.5) * 0.8;
				if (style == 1) {
					vec2 fc = fract(suv * 3.0) - 0.5;
					float fl = step(0.85, hash21(floor(suv * 3.0)));
					float petals = 0.0;
					for (int k = 0; k < 5; k++) { float a = float(k) * 1.2566; petals = max(petals, circle(fc, vec2(cos(a), sin(a)) * 0.05, 0.04)); }
					cc = mix(cc, vec3(1.0, 0.98, 0.94), petals * fl * detail);
					cc = mix(cc, vec3(1.0, 0.82, 0.25), circle(fc, vec2(0.0), 0.03) * fl * detail);
					vec2 kc = fract(suv * 2.0 + 0.37) - 0.5;
					float kl = step(0.8, hash21(floor(suv * 2.0 + 0.37) + 4.0));
					float clov = max(circle(kc, vec2(0.0, 0.05), 0.05), max(circle(kc, vec2(-0.045, -0.025), 0.05), circle(kc, vec2(0.045, -0.025), 0.05)));
					cc = mix(cc, cap_color * vec3(0.7, 1.05, 0.7) * (0.85 + 0.3 * step(0.0, kc.y)), clov * kl * detail);
				}
			}
		} else if (style == 2) { // frosting: creamy with soft sheen and sprinkles on top
			cc = cap_color * (0.94 + 0.08 * fbm(suv * 4.0));
			if (top) {
				vec2 sc = suv * 6.0;
				vec2 sq = fract(sc) - 0.5;
				float sh = hash21(floor(sc));
				float spr = step(0.72, sh) * (1.0 - smoothstep(0.06, 0.08, abs(sq.x * cos(sh * 6.0) + sq.y * sin(sh * 6.0)))) * (1.0 - smoothstep(0.12, 0.14, length(sq)));
				vec3 sprc = mix(mix(vec3(1.0, 0.4, 0.55), vec3(0.4, 0.75, 1.0), step(0.85, sh)), vec3(1.0, 0.85, 0.3), step(0.93, sh));
				cc = mix(cc, sprc, spr * detail);
			}
			g += vec2(0.0, 1.0) * cap_edge * 0.6;
		} else if (style == 3) { // snow with blue icicle tips
			cc = mix(cap_color, vec3(0.72, 0.87, 1.0), cap_edge * 0.75) * (0.95 + 0.08 * fbm(suv * 8.0));
			if (top) g += vec2(hnoise(suv * 6.0) - 0.5, hnoise(suv * 6.0 + 3.0) - 0.5) * 0.5;
		}
		float below = (1.0 - cap) * (1.0 - smoothstep(0.0, 0.08, limit - p.y)) * float(side);
		col *= 1.0 - below * 0.45;
		col = mix(col, cc, cap);
		emit *= 1.0 - cap;
		rough = mix(rough, (style == 2 || style == 3) ? 0.3 : 0.9, cap);
		refl = mix(refl, (style == 2 || style == 3) ? 0.35 : 0.0, cap);
		g += vec2(0.0, 1.0) * cap_edge * 0.8;
	}

	g *= sculpt;
	NORMAL = normalize(NORMAL - tu * g.x - tv * g.y);

	// Painted key/shade separation: sides darker than the top, the face turned from the key
	// (world +x / camera-right in the house rig) darker still. Cap keeps its own value.
	if (side) {
		vec3 wn0 = normalize((MODEL_MATRIX * vec4(ln, 0.0)).xyz);
		vec3 vn0 = normalize((VIEW_MATRIX * vec4(wn0, 0.0)).xyz);
		col *= side_shade * (1.0 - shade_side_extra * smoothstep(-0.2, 0.6, vn0.x));
	}
	// Painted AO: dark toward the foot, creases on bevels between neighbours.
	float foot = 1.0 - smoothstep(-0.5, -0.15, p.y);
	float ao = 1.0 - 0.35 * foot - cavity;
	col *= clamp(ao, 0.35, 1.0);

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

	vec3 nw = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up = clamp(nw.y * 0.7 + 0.3, 0.0, 1.0);
	// Painted lit bevel: rounded edges facing up catch a highlight stroke.
	col = mix(col, col * 1.3 + vec3(0.04), bevel * bevel_light * up);
	float ndv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fres = pow(1.0 - ndv, 3.0);
	vec3 R = (INV_VIEW_MATRIX * vec4(reflect(-VIEW, NORMAL), 0.0)).xyz;
	vec3 env = mix(rim_color * 0.3, rim_color * 1.05 + vec3(0.1), smoothstep(-0.2, 0.8, R.y));
	vec3 refl_col = env * refl * mix(0.2, 1.0, fres);
	vec3 rim_col = rim_color * fres * rim * (0.35 + 0.65 * up);
	// Fake translucency: the body glows with its own colour, strongest in the face centre.
	vec3 trans = col * translucency * (0.25 + 0.35 * inner);

	ALBEDO = col * brightness;
	ROUGHNESS = rough;
	SPECULAR = 0.5;
	EMISSION = emit + refl_col * 0.3 + rim_col * 0.35 + trans * brightness;
}

#include "res://src/view/shaders/painted_light.gdshaderinc"
