// spatial_block_biome: Wacky Towers biome block look (technical art, v2 2026-10-13).
// One procedural shader for every biome cube; Mobile renderer, phones, no texture samples.
// Style is a uniform (coherent branch). Budget: <= 2 Voronoi (3x3) + ~6 value-noise taps per pixel.
// v2 adds: sculpted normals (procedural bump per biome), lit bevel highlights, sky-tinted rim,
// fake AO, fake environment reflection, lip/overhang displacement for caps, two-tone lava cracks,
// ice frost rim with fake inner refraction.
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
// How far the cap overhangs the body (vertex displacement, cube units).
uniform float cap_lip : hint_range(0.0, 0.15) = 0.05;
uniform vec3 body_color : source_color = vec3(0.55, 0.40, 0.27);
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
// Strength of the lit bevel highlight along cube edges.
uniform float bevel_light : hint_range(0.0, 1.0) = 0.55;
// How strongly procedural normals sculpt the faces.
uniform float sculpt : hint_range(0.0, 2.0) = 1.0;
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
// Two-octave height used for cheap finite-difference bump gradients.
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
// Per-cell facet tilt in [-0.5, 0.5]^2 from a Voronoi id.
vec2 facet(float id) { return vec2(hash21(vec2(id, 1.3)), hash21(vec2(id, 7.1))) - 0.5; }
float circle(vec2 uv, vec2 c, float r) { return 1.0 - smoothstep(r - 0.015, r + 0.015, length(uv - c)); }
float star4(vec2 uv, vec2 c, float r) {
	vec2 d = abs(uv - c);
	return 1.0 - smoothstep(r * 0.15, r * 0.25, d.x * d.y * 40.0 / r + (d.x + d.y) * 0.4 / r - 0.05);
}
// Bell curve peaking at the middle of [a, b]: the slope magnitude of a smoothstep ramp.
float bell(float a, float b, float x) { float t = smoothstep(a, b, x); return 4.0 * t * (1.0 - t); }
// Axis-aligned direction away from the face centre (for bevel normals on rectangular frames).
vec2 rdir(vec2 q) { return abs(q.x) > abs(q.y) ? vec2(sign(q.x), 0.0) : vec2(0.0, sign(q.y)); }

void vertex() {
	lp = VERTEX; ln = NORMAL;
	motif = INSTANCE_CUSTOM.r; cell_alpha = use_cell_alpha ? INSTANCE_CUSTOM.a : 1.0;
	center = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	if (cap_depth > 0.0) {
		// Overhanging cap: the top band of the cube swells outward with a ragged lip (grass tuft,
		// icing, snow). Per-vertex variation keeps the silhouette organic. Neighbours overlap a
		// little, which hides seams between stacked or adjacent cubes.
		float sd = hash31(floor(center * 1.01 + 0.5));
		float band = smoothstep(0.5 - cap_depth * 2.0 - 0.08, 0.5 - cap_depth * 0.5, VERTEX.y);
		float rag = 0.65 + 0.7 * vnoise(VERTEX.xz * 7.0 + VERTEX.y * 3.0 + sd * 9.0);
		VERTEX.xz *= 1.0 + band * cap_lip * 2.0 * rag;
		VERTEX.y += band * cap_lip * 0.25 * (rag - 0.65);
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
	vec2 uv = an.y > 0.5 ? p.xz : (an.x > 0.5 ? p.zy : p.xy);
	// Tangent frame in view space, for the procedural normal perturbation. u/v match uv above.
	vec3 axu = an.y > 0.5 ? vec3(1.0, 0.0, 0.0) : (an.x > 0.5 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0));
	vec3 axv = an.y > 0.5 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
	vec3 tu = normalize((VIEW_MATRIX * (MODEL_MATRIX * vec4(axu, 0.0))).xyz);
	vec3 tv = normalize((VIEW_MATRIX * (MODEL_MATRIX * vec4(axv, 0.0))).xyz);
	// Seed per cube so neighbouring cubes do not repeat the same marks.
	float seed = hash31(floor(center * 1.01 + 0.5));
	vec2 suv = uv + seed * 7.0;
	float edge = max(abs(p.x), max(abs(p.y), abs(p.z)));
	float face_edge = an.y > 0.5 ? max(abs(p.x), abs(p.z)) : (an.x > 0.5 ? max(abs(p.z), abs(p.y)) : max(abs(p.x), abs(p.y)));
	// Tangent-space view direction, used for fake parallax (inner refraction, glass depth).
	vec2 vt = vec2(dot(VIEW, tu), dot(VIEW, tv));

	vec3 piece = COLOR.rgb;
	vec3 col = mix(piece, body_color, body_mix);
	vec3 emit = vec3(0.0);
	float rough = 1.0 - gloss;
	vec2 g = vec2(0.0);        // height gradient: NORMAL -= tu * g.x + tv * g.y
	float refl = gloss * 0.35; // fake environment reflection strength
	float spec_boost = 0.0;
	float cavity = 0.0;        // extra darkening in grooves (fake AO)

	if (style == 1) { // Meadow: layered dirt, bumpy pebbles, clover.
		float layer = step(0.5, fract(p.y * 3.0 + fbm(suv * 3.0) * 0.4));
		float dn = hnoise(suv * 11.0);
		col *= mix(0.9, 1.06, layer) * (0.88 + 0.28 * dn);
		float e = 0.03;
		g += vec2(hnoise((suv + vec2(e, 0.0)) * 11.0) - dn, hnoise((suv + vec2(0.0, e)) * 11.0) - dn) / e * 0.06;
		// Pebbles: domes with a lit top-left and a dark contact ring.
		vec2 pc = fract(suv * 2.3) - 0.5;
		float pid = step(0.55, hash21(floor(suv * 2.3)));
		float dome = circle(pc, vec2(0.0), 0.11) * pid;
		col = mix(col, vec3(0.66, 0.63, 0.60) * (0.8 + 0.4 * (0.5 - pc.x * 2.0 + pc.y * 2.0 + 0.5) * 0.5), dome * detail);
		col *= 1.0 - (circle(pc, vec2(0.0), 0.16) - circle(pc, vec2(0.0), 0.11)) * pid * 0.4;
		g += -pc * 4.0 * dome * detail;
	} else if (style == 2) { // Candy: glossy jelly, deep inner glow, soft wobble highlights.
		float inner = 1.0 - smoothstep(0.12, 0.48, face_edge);
		col = mix(col * 0.78, col * 1.2 + 0.07, inner);
		emit += piece * 0.4 * inner;
		// Wobbly lumps in the jelly surface: broad soft normals that move the highlight.
		float w = vnoise(suv * 2.2);
		g += vec2(vnoise((suv + vec2(0.05, 0.0)) * 2.2) - w, vnoise((suv + vec2(0.0, 0.05)) * 2.2) - w) / 0.05 * 0.05;
		// Window-shaped sheen on each face.
		vec2 q = (uv - vec2(-0.12, 0.1)) * vec2(1.0, 2.2);
		float sheen = (1.0 - smoothstep(0.1, 0.17, abs(q.x) + abs(q.y) * 0.6)) * step(0.2, hash21(floor(seed * 40.0) + vec2(1.0)));
		emit += vec3(1.0, 0.95, 0.95) * sheen * 0.16;
		float sprink = step(0.9, hash21(floor(suv * 7.0))) * (top ? 1.0 : 0.0);
		col = mix(col, mix(vec3(1.0, 0.45, 0.6), vec3(0.4, 0.8, 1.0), hash21(floor(suv * 7.0) + 2.0)), sprink);
		refl = 0.5; spec_boost = 0.25;
	} else if (style == 3) { // Ice: translucent blue, frost rim, interior cracks with fake refraction.
		vec2 v = voronoi(suv * 3.2);
		// Inner layer shifted against the view direction so cracks sit deep inside the cube.
		vec2 v2 = voronoi((suv - vt * 0.16) * 2.1 + 4.0);
		float inner_crack = 1.0 - smoothstep(0.0, 0.06, v2.x);
		float surf_crack = 1.0 - smoothstep(0.0, 0.04, v.x);
		float core = 1.0 - smoothstep(0.1, 0.45, face_edge);
		col = mix(col * 0.88, col * 1.12 + vec3(0.02, 0.05, 0.1), core);
		col = mix(col, vec3(0.8, 0.93, 1.0), inner_crack * 0.4 * detail);
		col = mix(col, vec3(0.95, 0.99, 1.0), surf_crack * 0.35 * detail);
		// Frost band on the rim of each face.
		float frost = smoothstep(0.34, 0.49, face_edge) * (0.55 + 0.45 * vnoise(suv * 14.0));
		col = mix(col, vec3(0.93, 0.98, 1.0), frost * 0.7);
		g += facet(v.y) * 0.18 + facet(v2.y) * 0.1;
		float sp = step(0.985, hash21(floor(suv * 18.0)));
		emit += vec3(0.8, 0.95, 1.0) * (sp * 0.8 + inner_crack * 0.08);
		refl = 0.55; spec_boost = 0.2;
	} else if (style == 4) { // Underwater: faceted deep glass, domed bubbles, caustic light.
		vec2 fv = voronoi(suv * 2.0 + 11.0);
		float caust = fbm(suv * 4.0 + vec2(TIME * 0.05, 0.0));
		col = mix(col, col.bgr * vec3(1.0, 0.7, 1.3), fv.y * 0.35);   // violet/blue facet tint
		col *= 0.7 + 0.55 * caust;
		col *= mix(0.78, 1.1, smoothstep(0.0, 0.1, fv.x));
		g += facet(fv.y) * 0.25;
		vec2 cell = floor(suv * 3.0);
		float has = step(0.6, hash21(cell));
		vec2 c = vec2(0.3) + vec2(hash21(cell + 1.0), hash21(cell + 2.0)) * 0.4;
		float r = 0.10 + hash21(cell + 3.0) * 0.1;
		vec2 bq = fract(suv * 3.0);
		float ring = circle(bq, c, r) - circle(bq, c, r - 0.04);
		float hi = circle(bq, c + vec2(-r, r) * 0.4, r * 0.25);
		col = mix(col, vec3(0.85, 0.95, 1.0), (ring * 0.6 + hi * 0.9) * has * detail);
		g += (bq - c) * 3.0 * circle(bq, c, r) * has * detail;  // bubble dome
		emit += accent_color * (0.1 * caust + 0.12 * (1.0 - smoothstep(0.0, 0.1, fv.x)));
		refl = 0.5; spec_boost = 0.2;
	} else if (style == 5) { // Lava: cracked obsidian plates, two-tone glowing seams.
		vec2 v = voronoi(suv * 1.7);
		float crack = 1.0 - smoothstep(0.03, 0.09, v.x);
		float hot = 1.0 - smoothstep(0.0, 0.03, v.x);              // white-yellow core of the seam
		float halo = 1.0 - smoothstep(0.08, 0.3, v.x);             // faint orange spill onto the plate
		float plate = fbm(suv * 5.0);
		col *= (0.7 + 0.5 * plate) * (0.75 + 0.35 * v.y);
		// Faceted plates: each cell tilts, edges roll off toward the crack.
		g += facet(v.y) * 0.55;
		float lip = smoothstep(0.1, 0.22, v.x);
		col *= mix(0.55, 1.15, lip);
		vec3 hot_col = mix(glow_color, vec3(1.0, 0.92, 0.45), hot);
		col = mix(col, hot_col, crack);
		float pulse = 0.8 + 0.2 * sin(TIME * 2.0 + seed * 6.28);
		emit += glow_color * (crack * glow * pulse + halo * 0.18) + vec3(1.0, 0.85, 0.4) * hot * glow * 0.35;
		rough = mix(0.8, 0.35, crack);
		refl = 0.1 + 0.2 * lip;
	} else if (style == 6) { // Forest: grooved bark, tree-ring end grain, moss.
		bool rings_face = top || bottom || (an.x > 0.5 && seed > 0.45);
		if (rings_face) {
			vec2 ruv = uv;
			float rr = length(ruv) * 9.0 + fbm(suv * 2.0) * 0.6;
			float rings = fract(rr);
			float ring_line = smoothstep(0.6, 0.9, rings);
			col = mix(vec3(0.86, 0.67, 0.44), vec3(0.6, 0.41, 0.24), ring_line);
			col *= 1.08 - length(ruv) * 0.35;
			// Concentric grooves on the cut end.
			g += normalize(ruv + 0.0001) * (rings - 0.5) * 0.12 * (ring_line * 2.0 - 0.6);
			// Bark collar around the cut face.
			float collar = smoothstep(0.37, 0.46, face_edge);
			col = mix(col, vec3(0.38, 0.25, 0.15) * (0.8 + 0.4 * vnoise(suv * 10.0)), collar);
		} else {
			// Vertical grooves: ridged noise along u, long stretch along v.
			vec2 bq = vec2(suv.x * 11.0, suv.y * 1.3);
			float h0 = hnoise(bq);
			float e = 0.08;
			float h1 = hnoise(bq + vec2(e, 0.0));
			g += vec2((h1 - h0) / e, 0.0) * 0.045 * 1.0;
			float groove = smoothstep(0.5, 0.2, h0);
			col *= 0.65 + 0.6 * h0;
			col = mix(col, col * vec3(0.55, 0.45, 0.4), groove * 0.4);
			cavity += groove * 0.2;
			// Horizontal bark plates.
			float plate = smoothstep(0.0, 0.07, abs(fract(suv.y * 2.2 + h0 * 0.3) - 0.5) * 2.0);
			col *= 0.88 + 0.12 * plate;
		}
	} else if (style == 7) { // Crystal cave: faceted stone with creased edges and amethyst clusters.
		vec2 v = voronoi(suv * 3.0);
		col *= 0.75 + 0.35 * v.y;
		float crease = smoothstep(0.0, 0.08, v.x);
		col *= mix(0.55, 1.0, crease);
		col += vec3(0.08, 0.07, 0.1) * (1.0 - smoothstep(0.08, 0.16, v.x)) * crease; // lit facet ridge
		g += facet(v.y) * 0.6 * sculpt + (hnoise(suv * 16.0) - 0.5) * 0.12;
		cavity += (1.0 - crease) * 0.3;
		// Amethyst: a diamond-cut gem with two shaded halves and a bright tip.
		vec2 gc = fract(suv * 4.0) - 0.5;
		float gid = step(0.8, hash21(floor(suv * 4.0)));
		float gem = (1.0 - smoothstep(0.26, 0.3, abs(gc.x) * 1.4 + abs(gc.y) * 0.8)) * gid;
		vec3 gcol = accent_color * (gc.x < 0.0 ? 1.15 : 0.7);
		col = mix(col, gcol, gem);
		g += vec2(-sign(gc.x), 0.0) * 0.5 * gem;
		emit += accent_color * gem * (glow + 0.4 * step(0.0, -gc.y));
		refl = 0.1 + 0.4 * gem;
	} else if (style == 8) { // Clockwork: navy panel in a bevelled brass frame with domed rivets.
		float frame = smoothstep(0.33, 0.35, face_edge);
		vec2 q = abs(uv);
		float rivet = circle(q, vec2(0.41), 0.045);
		float inset = smoothstep(0.30, 0.33, face_edge) - frame;
		// Frame bevel: slopes inward at the inner lip, outward at the outer lip.
		g += rdir(uv) * (bell(0.32, 0.36, face_edge) * 0.9 - bell(0.44, 0.5, face_edge) * 0.7);
		vec2 rq = q - vec2(0.41);
		g += rq * 14.0 * rivet * sign(uv) ;
		vec3 brass = accent_color * (0.9 + 0.3 * hnoise(suv * 8.0));
		// Panel: darker navy near the frame (cavity), soft sheen across it.
		col *= mix(0.65, 1.1, smoothstep(0.1, 0.32, 0.33 - face_edge + 0.2));
		col += vec3(0.04, 0.05, 0.09) * smoothstep(0.1, -0.2, uv.x + uv.y);
		col = mix(col, brass, max(frame, rivet));
		col *= 1.0 - inset * 0.5;
		rough = mix(0.5, 0.2, max(frame, rivet));
		refl = mix(0.15, 0.7, max(frame, rivet));
		spec_boost = max(frame, rivet) * 0.3;
		if (top) {
			float r = length(uv);
			float a = atan(uv.y, uv.x);
			float gear = 1.0 - smoothstep(0.17, 0.18, r - 0.03 * step(0.0, sin(a * 8.0))) ;
			gear *= smoothstep(0.05, 0.06, r);
			col = mix(col, brass, gear * detail);
		}
	} else if (style == 9) { // Neon: dark glass, bevelled border, glowing circuit traces below the surface.
		float border = smoothstep(0.385, 0.395, face_edge) * (1.0 - smoothstep(0.425, 0.44, face_edge));
		vec2 pu = suv - vt * 0.05;  // traces sit slightly under the glass
		vec2 gq = fract(pu * 2.0) - 0.5;
		float trace = (1.0 - smoothstep(0.015, 0.03, abs(gq.x))) * step(0.5, hash21(floor(pu * 2.0)))
			+ (1.0 - smoothstep(0.015, 0.03, abs(gq.y))) * step(0.5, hash21(floor(pu * 2.0) + 5.0));
		float node = circle(gq, vec2(0.0), 0.07) * step(0.7, hash21(floor(pu * 2.0) + 9.0));
		float line = clamp(border + (trace + node) * detail * step(face_edge, 0.39), 0.0, 1.0);
		float glass = smoothstep(0.0, 0.4, 0.45 - face_edge);
		col = mix(col * 0.5, col * 0.85, glass * 0.5);
		col = mix(col, glow_color, line);
		emit += glow_color * line * glow + glow_color * 0.04 * smoothstep(0.3, 0.45, face_edge);
		g += rdir(uv) * (bell(0.36, 0.42, face_edge) * 0.5);
		rough = 0.18;
		refl = 0.6; spec_boost = 0.25;
	} else if (style == 10) { // Celestial: window onto a nebula, two star layers with parallax.
		vec2 nuv = suv * 1.0 - vt * 0.12;
		float neb = fbm(nuv * 2.2 + fbm(nuv * 1.3) * 1.5);
		col = mix(col * 0.5, accent_color, smoothstep(0.42, 0.85, neb) * 0.75);
		col += vec3(1.0, 0.55, 0.8) * smoothstep(0.7, 0.95, neb) * 0.25;   // hot pink/gold ridge
		vec2 suv2 = suv * 1.0 - vt * 0.2;                                    // near star layer
		vec2 cell = floor(suv2 * 5.0);
		float s = step(0.86, hash21(cell)) * star4(fract(suv2 * 5.0), vec2(0.5), 0.28);
		float tw = 0.6 + 0.4 * sin(TIME * 3.0 + hash21(cell) * 20.0);
		vec2 cell2 = floor((suv - vt * 0.05) * 11.0);                        // far fine stars
		float s2 = step(0.9, hash21(cell2 + 3.0)) * circle(fract((suv - vt * 0.05) * 11.0), vec2(0.5), 0.12);
		col = mix(col, vec3(1.0, 0.95, 0.75), max(s, s2 * 0.8));
		emit += vec3(1.0, 0.92, 0.7) * (s * glow * tw + s2 * 0.5);
		g += (hnoise(suv * 5.0) - 0.5) * 0.05;
		refl = 0.5; spec_boost = 0.2;
	} else if (style == 11) { // Tumble Fair: puffy pink and cream candy stripes.
		float sx = (an.y > 0.5 ? (uv.x + uv.y) : uv.x) * 2.0 + 0.25;
		float s = step(0.5, fract(sx));
		col = mix(accent_color, col, s);
		// Each stripe is a soft cushion: normals roll over its width; seams between stripes crease.
		float fs = fract(sx);
		g += vec2(sin(fs * 6.2832) * -0.16, 0.0);
		float seam = 1.0 - smoothstep(0.0, 0.06, min(abs(fs - 0.5), min(fs, 1.0 - fs)));
		col *= 1.0 - seam * 0.12;
		rough = 0.3;
		refl = 0.5; spec_boost = 0.2;
	} else if (style == 12) { // Dune Bazaar: grainy sandstone with a debossed teal arabesque band.
		float grain = hnoise(suv * 22.0);
		col *= 0.88 + 0.22 * fbm(suv * 6.0);
		col = mix(col, col * 0.72, step(0.9, hash21(floor(suv * 14.0))));
		float e = 0.02;
		g += vec2(hnoise((suv + vec2(e, 0.0)) * 22.0) - grain, hnoise((suv + vec2(0.0, e)) * 22.0) - grain) / e * 0.015;
		if (!top && !bottom) {
			float wave = p.y - 0.05 + sin(uv.x * 18.0) * 0.03;
			float band = 1.0 - smoothstep(0.11, 0.13, abs(wave));
			float lobe = circle(vec2(fract(uv.x * 2.0 + 0.5), p.y), vec2(0.5, -0.2), 0.12) * (1.0 - band);
			float motif_m = max(band, lobe) * detail;
			// Gold outline: a thin ring of accent around the teal inlay, with a lit side.
			float outline = (smoothstep(0.1, 0.12, abs(wave)) - smoothstep(0.135, 0.155, abs(wave))) * (1.0 - lobe);
			col = mix(col, accent_color, motif_m);
			col = mix(col, glow_color * 1.3, outline * detail * 0.7);
			g += vec2(0.0, -sign(wave)) * outline * 0.4;
			col = mix(col, glow_color, smoothstep(0.43, 0.46, abs(p.y)) * 0.6);
			rough = mix(rough, 0.35, motif_m);
		}
	}

	// Biome cap on the top face and a dripping band down the sides (grass, icing, snow, moss).
	float cap_mask = 0.0;
	float cap_edge = 0.0;
	if (cap_depth > 0.0) {
		float along = (an.x > 0.5 ? p.z : p.x);
		float wobble = (fbm(vec2(along * 9.0 + seed * 5.0, seed)) - 0.5) * 2.0;
		float drip;
		if (style == 3) { // icicles: sharp triangles of random length
			float tri = abs(fract(along * 5.0 + seed * 3.0) - 0.5) * 2.0;
			float len = 0.4 + 0.9 * hash21(vec2(floor(along * 5.0 + seed * 3.0), seed));
			drip = cap_drip * 2.2 * len * (1.0 - tri) * (1.0 - tri) * (1.0 - tri * 0.4);
		} else if (style == 1 || style == 6) { // grass/moss: ragged tufts with high-frequency blades
			drip = cap_drip * abs(sin(along * 16.0 + seed * 9.0)) + 0.025 * abs(sin(along * 47.0 + seed * 5.0));
		} else { // icing: round blobby drips
			float ph = along * 11.0 + seed * 9.0;
			drip = cap_drip * (0.5 + 0.5 * sin(ph)) * (0.6 + 0.4 * sin(ph * 0.37 + 1.3)) * 1.4;
		}
		float limit = 0.5 - cap_depth - drip - wobble * 0.03;
		float sd = (style == 3) ? 0.006 : 0.014;
		float cap = top ? 1.0 : (bottom ? 0.0 : smoothstep(limit - sd, limit + sd, p.y));
		if (style == 6 && top && seed > 0.5) cap = 0.0;          // some logs show end grain on top
		if (style == 6 && !top && !bottom) cap *= step(0.35, hash21(vec2(floor(along * 4.0 + seed * 9.0), seed))) * 0.9 + 0.0;
		cap_mask = cap;
		cap_edge = !top ? (1.0 - smoothstep(0.0, 0.05, p.y - limit)) * cap : 0.0;
		vec3 cc = cap_color * (0.82 + 0.3 * fbm(suv * 9.0));
		if (style == 1) { // blade streaks: bright tips toward the lip, dark roots under it, flowers on top
			float blade = vnoise(vec2(along * 40.0, seed * 3.0));
			cc *= 0.85 + 0.3 * blade;
			cc = mix(cc, cc * vec3(1.15, 1.15, 0.7), cap_edge * 0.6);
			if (top) {
				float flower = step(0.96, hash21(floor(suv * 5.0))) * circle(fract(suv * 5.0), vec2(0.5), 0.18);
				cc = mix(cc, vec3(1.0, 0.98, 0.9), flower);
				g += vec2(hnoise(suv * 26.0 + 1.0) - 0.5, hnoise(suv * 26.0 + 9.0) - 0.5) * 0.25;
			} else {
				g += vec2(vnoise(vec2(along * 40.0, 1.0)) - 0.5, 0.0) * 0.3;
			}
		}
		if (style == 3) cc = mix(cc, vec3(0.78, 0.9, 1.0), cap_edge * 0.8 + (top ? 0.0 : 0.15));
		if (style == 6) cc *= vec3(0.8, 1.0, 0.7);
		// Dark contact shadow just below the cap lip, so it reads as an overhang.
		float below = (1.0 - cap) * (1.0 - smoothstep(0.0, 0.1, limit - p.y)) * (top ? 0.0 : 1.0);
		col *= 1.0 - below * 0.45;
		col = mix(col, cc, cap);
		rough = mix(rough, style == 2 ? 0.12 : (style == 3 ? 0.2 : 0.8), cap);
		if (style == 2 || style == 3) { refl = mix(refl, 0.6, cap); spec_boost = max(spec_boost, 0.3 * cap); }
		// Rounded lip: the cap edge bulges and rolls toward the body (normal tilts downward).
		g += vec2(0.0, 1.0) * (1.0 - smoothstep(0.0, 0.06, p.y - limit)) * cap * (top ? 0.0 : 1.0) * 0.9;
		// Icing / snow highlight just inside the lip.
		if (style == 2 || style == 3) col += vec3(0.08) * cap_edge;
	}

	// Sculpt the normal: g is a height gradient in the face tangent frame.
	g *= sculpt;
	NORMAL = normalize(NORMAL - tu * g.x - tv * g.y);

	// Fake AO: dark at the foot of each cube and in the creases where it meets its neighbours.
	float foot = 1.0 - smoothstep(-0.5, -0.12, p.y);
	float ao = 1.0 - 0.38 * foot - 0.14 * smoothstep(0.42, 0.5, edge) * (1.0 - float(top)) - cavity;
	if (top) ao = 1.0 - 0.1 * smoothstep(0.42, 0.5, face_edge);
	col *= clamp(ao, 0.3, 1.0);
	col *= mix(0.9, 1.0, smoothstep(-0.5, 0.15, p.y));

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

	// Lighting extras. World-space normal for sky-facing terms.
	vec3 nw = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up = smoothstep(-0.3, 0.8, nw.y);
	float ndv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float fres = pow(1.0 - ndv, 3.0);
	// Lit bevel: the chamfer catches light instead of darkening (brightest on sky-facing edges).
	float bev = smoothstep(0.36, 0.5, face_edge);
	vec3 bev_col = mix(col, vec3(1.0), 0.5) * bev * bevel_light * (0.3 + 0.7 * up);
	// Fake environment reflection: sky-coloured above, darker below; weighted by glossiness.
	vec3 R = (INV_VIEW_MATRIX * vec4(reflect(-VIEW, NORMAL), 0.0)).xyz;
	vec3 env = mix(rim_color * 0.25, rim_color * 1.1 + vec3(0.1), smoothstep(-0.2, 0.8, R.y));
	float fr = mix(0.25, 1.0, fres);
	vec3 refl_col = env * refl * fr * (1.0 - rough * 0.5);
	// Sky-coloured rim, strongest on upward-facing silhouettes.
	vec3 rim_col = rim_color * fres * rim * (0.35 + 0.65 * up) * 1.4;

	ALBEDO = col * brightness;
	ROUGHNESS = rough;
	SPECULAR = 0.5 + spec_boost;
	AO = clamp(ao, 0.3, 1.0);
	AO_LIGHT_AFFECT = 0.4;
	EMISSION = emit + bev_col * 0.45 + refl_col * 0.5 + rim_col;
}
