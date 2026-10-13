// Style R&D prototype: "painted" rounded block with an overhanging biome cap.
// Works in Compatibility (opengl3), Mobile and Forward+. No textures: all paint is procedural,
// so the look survives any resolution. Production would swap the fbm "paint" for a baked
// 512px painted albedo atlas (see design/art/style-techniques.md §3).
shader_type spatial;
render_mode cull_back;

// --- paint ---
uniform vec3 body_color : source_color = vec3(0.60, 0.43, 0.29);   // dirt #9a6e4a
uniform vec3 body_dark : source_color = vec3(0.42, 0.29, 0.20);    // #6b4a33
uniform vec3 cap_color : source_color = vec3(0.36, 0.62, 0.22);    // grass
uniform vec3 cap_light : source_color = vec3(0.62, 0.86, 0.36);    // #8fd05a-ish
uniform vec3 cap_dark : source_color = vec3(0.18, 0.42, 0.14);
uniform float cap_y : hint_range(-0.6, 2.0) = 0.18;  // local Y where the cap starts (>0.5 = no cap)
uniform float cap_drip : hint_range(0.0, 0.3) = 0.10; // ragged hanging edge amplitude
uniform float cap_lip : hint_range(0.0, 0.1) = 0.035; // outward swell of the cap (vertex)
uniform float pebbles : hint_range(0.0, 1.0) = 1.0;
uniform float strata : hint_range(0.0, 1.0) = 0.6;
uniform float paint_scale = 3.0;
uniform float seed = 0.0;
// --- light response ---
uniform vec3 shadow_tint : source_color = vec3(0.42, 0.36, 0.62); // shadows go purple, never grey
uniform float wrap : hint_range(0.0, 1.0) = 0.45;                 // half-lambert-ish wrap
uniform float band_soft : hint_range(0.01, 1.0) = 0.35;           // soft 2-tone ramp edge
uniform vec3 rim_color : source_color = vec3(1.0, 0.93, 0.78);
uniform float rim_power = 3.0;
uniform float rim_strength = 0.45;
uniform float edge_light = 0.3;   // painted lit bevel on rounded edges
uniform float gloss = 0.35;
uniform float ao_strength = 0.45;
// aerial perspective for far props (global fog is off, see style_kit.gd)
uniform vec3 haze_color : source_color = vec3(0.87, 0.90, 0.96);
uniform float haze : hint_range(0.0, 1.0) = 0.0;  // painted contact darkening at the bottom

varying vec3 lp;
uniform vec3 half_size = vec3(0.5);
uniform float edge_width = 0.13; // = rounding radius of the mesh // mesh half extents (edge mask in fragment, no tri artifacts)

float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vn(p) * 0.55 + vn(p * 2.03) * 0.3 + vn(p * 4.1) * 0.15; }

// Coordinate that wraps around the four sides, so the ragged cap edge is continuous.
float around(vec3 p) { return p.x + p.z + (abs(p.x) > abs(p.z) ? 0.0 : 3.0); }

void vertex() {
	lp = VERTEX;
	// edge = how close the vertex is to a rounded edge (second-largest |axis| -> 0.5)
	if (cap_y < 0.5) {
		float band = smoothstep(cap_y - 0.06, cap_y + 0.10, VERTEX.y);
		float rag = 0.6 + 0.8 * vn(vec2(around(VERTEX) * 6.0 + seed, 0.0));
		VERTEX.xz *= 1.0 + band * cap_lip * 2.0 * rag;
		VERTEX.y += band * cap_lip * 0.6;
	}
}

void fragment() {
	vec3 p = lp;
	// rounded-edge mask per pixel: second-largest normalised axis approaching the box surface
	// per axis: 0 inside the flat face, 1 at the end of the rounded zone (edge_width wide)
	vec3 a = clamp((abs(p) - (half_size - edge_width)) / edge_width, 0.0, 1.0);
	float amx = max(a.x, max(a.y, a.z));
	float amid = a.x + a.y + a.z - amx - min(a.x, min(a.y, a.z));
	float edge = smoothstep(0.2, 1.0, amid);
	vec2 side_uv = vec2(around(p), p.y);
	vec3 wn = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	// ---- body: dirt with painted strata and pebbles
	float paint = fbm(side_uv * paint_scale + seed);
	vec3 col = mix(body_dark, body_color, smoothstep(0.25, 0.75, paint));
	float layer = smoothstep(0.45, 0.55, fract(p.y * 2.6 + paint * 0.5));
	col *= mix(1.0, mix(0.86, 1.06, layer), strata);
	vec2 pc = fract(side_uv * 2.6 + seed) - 0.5;
	float pid = step(0.6, h21(floor(side_uv * 2.6 + seed)));
	float peb = (1.0 - smoothstep(0.09, 0.13, length(pc))) * pid * pebbles;
	vec3 peb_col = mix(vec3(0.55, 0.52, 0.52), vec3(0.85, 0.83, 0.80), clamp(0.5 - pc.y * 3.0 + pc.x, 0.0, 1.0));
	col = mix(col, peb_col, peb);
	// ---- cap: grass with hanging strands, lighter tufts on top
	if (cap_y < 0.5) {
		float strands = vn(vec2(around(p) * 28.0 + seed, 0.0));
		float drip = cap_drip * (0.35 + 0.65 * strands) + cap_drip * 0.6 * fbm(vec2(around(p) * 5.0 + seed, 1.0));
		float cap = smoothstep(cap_y - drip - 0.012, cap_y - drip + 0.012, p.y);
		float tuft = fbm(p.xz * 9.0 + seed) * 0.6 + fbm(vec2(around(p) * 14.0, p.y * 3.0)) * 0.4;
		vec3 grass = mix(cap_dark, cap_color, smoothstep(0.2, 0.6, tuft));
		grass = mix(grass, cap_light, smoothstep(0.55, 0.8, tuft) * (0.4 + 0.6 * clamp(wn.y, 0.0, 1.0)));
		// dark contact line under the overhang (painted AO)
		float under = smoothstep(0.06, 0.0, abs(p.y - (cap_y - drip - 0.03))) * (1.0 - cap);
		col *= 1.0 - under * 0.45;
		col = mix(col, grass, cap);
	}
	// painted lit bevel: edges facing up/key get lighter, like a highlight stroke
	col = mix(col, col * 1.25 + vec3(0.03), edge * edge_light * clamp(wn.y * 0.7 + 0.3, 0.0, 1.0));
	// painted AO toward the bottom (contact) - not physical, art-directed
	col *= mix(1.0, smoothstep(-0.55, -0.15, p.y), ao_strength);
	ALBEDO = col;
	ROUGHNESS = 1.0 - gloss;
	SPECULAR = 0.3;
	FOG = vec4(haze_color, haze);
}

void light() {
	float ndl = dot(NORMAL, LIGHT);
	// wrap + soft 2-tone band = painted form shading
	float w = (ndl + wrap) / (1.0 + wrap);
	// half soft 2-tone band (painted plane change) + half true lambert (keeps faces distinct)
	float band = smoothstep(0.0, band_soft, w) * 0.5 + clamp(ndl, 0.0, 1.0) * 0.5;
	float lit = band * ATTENUATION;
	// shadow side is tinted (cool purple), lit side keeps light colour
	vec3 diff = mix(shadow_tint * 0.18, vec3(1.0), lit);
	DIFFUSE_LIGHT += diff * LIGHT_COLOR / PI;
	// soft painted highlight blob
	vec3 hv = normalize(LIGHT + VIEW);
	float sp = pow(clamp(dot(NORMAL, hv), 0.0, 1.0), mix(8.0, 64.0, gloss)) * gloss * ATTENUATION;
	SPECULAR_LIGHT += smoothstep(0.3, 0.6, sp) * LIGHT_COLOR / PI * 0.5;
	// fresnel rim, only on the lit hemisphere so it reads as a backlight edge
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	DIFFUSE_LIGHT += rim * rim_strength * rim_color * clamp(ndl + 0.6, 0.0, 1.0) * LIGHT_COLOR / PI;
}
