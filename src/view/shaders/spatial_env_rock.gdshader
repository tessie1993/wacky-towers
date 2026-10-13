// spatial_env_rock: floating-island underside, lip ring segments and hanging roots (technical art, 2026-10-13).
// Meshes: assets/models/env/env_island_underside.glb, env_lip_*.glb, env_roots.glb
// (built by assets/source/blender/env/build_env_kit.py).
// Vertex colour contract: R = baked ray-cast AO, G = Poly Haven cliff_side detail baked per vertex,
// B = cover mask (1 = grass/snow/moss lip colour, 0 = soil or rock).
// Colours come from biome_looks.json via WtIslandBuilder, so one mesh serves every biome.
// Cost: 3 detail-texture samples (triplanar) + a few ALU ops. No discard, back faces culled.
// DEVIATION (flagged in design/reviews/mockups/tech-art.md 2.4): samples the shared 256² detail map.
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms look;
/** Lip/moss cover colour (grass, snow, icing, sand). */
uniform vec3 cover_color : source_color = vec3(0.45, 0.68, 0.3);
/** Rock colour near the top of the mass. */
uniform vec3 cliff : source_color = vec3(0.55, 0.42, 0.29);
/** Rock colour at the tip. */
uniform vec3 cliff_dark : source_color = vec3(0.37, 0.27, 0.19);
/** 1 = darken with local depth (underside, unit height mesh), 0 = no gradient (lip, roots). */
uniform float depth_gradient : hint_range(0.0, 1.0) = 1.0;
/** Biome style id (same table as spatial_block_biome). 5 lava veins, 7/9/10 glinting specks. */
uniform int style = 1;
uniform vec3 accent : source_color = vec3(1.0, 0.9, 0.4);
/** Emissive vein colour (lava) and strength; > 1 blooms with Environment glow. */
uniform vec3 glow_color : source_color = vec3(1.0, 0.42, 0.08);
uniform float glow = 0.0;
/** Shared Poly Haven detail map (R cliff, G stone, B grass, A cliff displacement). */
uniform sampler2D detail : hint_default_white, repeat_enable, filter_linear_mipmap;
uniform float detail_strength : hint_range(0.0, 1.0) = 0.45;
/** Top-light on upward faces (fake sky bounce). */
uniform float sky_lift : hint_range(0.0, 0.5) = 0.12;
group_uniforms;

varying vec3 wpos;
varying vec3 wnrm;
varying float lheight;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize(mat3(MODEL_MATRIX) * NORMAL);
	lheight = VERTEX.y;
}

vec4 tri(vec3 p, vec3 n) {
	vec3 w = pow(abs(n), vec3(4.0));
	w /= (w.x + w.y + w.z);
	return texture(detail, p.zy * 0.33) * w.x + texture(detail, p.xz * 0.33) * w.y + texture(detail, p.xy * 0.33) * w.z;
}

void fragment() {
	float ao = COLOR.r;
	float vary = COLOR.g;
	float cover = COLOR.b;
	vec3 n = normalize(wnrm);
	vec4 d = tri(wpos, n);
	float depth = clamp(-lheight * depth_gradient, 0.0, 1.0);
	vec3 rock = mix(cliff, cliff_dark, smoothstep(0.0, 0.9, depth));
	rock *= 0.78 + 0.44 * vary;
	rock *= mix(1.0, 0.6 + 0.8 * d.r, detail_strength);
	// Strata bands: horizontal layers broken by the displacement channel.
	rock *= 0.9 + 0.12 * step(0.5, fract(wpos.y * 1.25 + d.a * 0.5));
	float up = clamp(n.y, 0.0, 1.0);
	vec3 cov = cover_color * mix(1.0, 0.72 + 0.56 * d.b, detail_strength * 0.8);
	cov *= 0.88 + 0.22 * up;
	vec3 col = mix(rock, cov, cover);
	col *= mix(0.38, 1.0, ao);
	col *= 1.0 + sky_lift * up;
	ALBEDO = col;
	ROUGHNESS = mix(0.92, 0.8, cover);
	vec3 em = vec3(0.0);
	if (style == 5) {
		// Lava: glowing veins in rock crevices, hotter toward the tip.
		float vein = 1.0 - smoothstep(0.0, 0.07, abs(d.a - 0.52));
		vein *= (1.0 - cover) * smoothstep(0.15, 0.6, 1.0 - ao + depth * 0.6);
		float core = 1.0 - smoothstep(0.0, 0.03, abs(d.a - 0.52));
		em = mix(glow_color, vec3(1.0, 0.85, 0.4), core) * vein * glow * (0.5 + depth);
		ALBEDO = mix(col, glow_color, vein * 0.6);
	} else if (style == 7 || style == 9 || style == 10) {
		float speck = step(0.93, d.g) * step(0.6, d.r) * (1.0 - cover);
		em = accent * speck * max(glow, 0.6);
	}
	EMISSION = em;
}
