// toon_light.gdshaderinc: the shared toon wrap-and-ramp light() for Wacky Towers (blocks v5, 2026-10-14).
// Replaces painted_light.gdshaderinc for the block family; any shader (world, props, toppers) can
// #include it right after shader_type / render_mode (the varyings below must be declared before the
// host writes them) and get the same game-wide light:
//   * half-Lambert wrap -> soft terminator (no hard cel bands)
//   * 3-stop ramp: cool violet shadow -> base -> warm cream lit zone (key warm, shadow cool)
//   * small hard-edged specular blob (smoothstep on pow(N.H)), size from the material gloss
//   * edge glint: a spec line on bevel edges that face the light (mask = toon_edge_v)
//   * back-light transmission for jelly / ice / crystal (amount = toon_trans_v)
// Self-contained: it declares its own `toon_*` uniforms (so it cannot clash with the host shader's
// names) and two varyings the host may write in vertex() or fragment():
//   toon_edge_v   float 0..1  bevel-edge glint mask (0 = none)
//   toon_trans_v  vec3        translucency amount (0 = opaque); multiplied by ALBEDO by the engine
// THE HOST MUST ASSIGN BOTH VARYINGS (in vertex() or fragment()): unassigned varyings render black.
// Gloss comes from the host's ROUGHNESS (gloss = 1 - ROUGHNESS). Compatibility / Mobile / Forward+.
// Budget: ~30 ALU per light, no texture reads, 2 pow().
group_uniforms toon_light;
/** Colour of the unlit side: cool violet, never grey or black. */
uniform vec3 toon_shadow_tint : source_color = vec3(0.50, 0.42, 0.72);
/** How much of the shadow tint is added even where the light does not reach (the cool bounce). */
uniform float toon_shadow_floor : hint_range(0.0, 1.0) = 0.40;
/** Colour multiplier of the fully lit zone: warm cream. */
uniform vec3 toon_warm_tint : source_color = vec3(1.0, 0.93, 0.80);
/** Half-Lambert wrap: 0 = hard Lambert, 1 = fully wrapped. */
uniform float toon_wrap : hint_range(0.0, 1.0) = 0.35;
/** Terminator softness (0.01 = cel edge, 1 = smooth). */
uniform float toon_band_soft : hint_range(0.01, 1.0) = 0.45;
/** Specular blob threshold (higher = smaller blob). */
uniform float toon_spec_size : hint_range(0.0, 1.0) = 0.35;
/** Specular blob strength. */
uniform float toon_spec_strength : hint_range(0.0, 2.0) = 0.55;
/** Edge glint strength (bevel highlight line). */
uniform float toon_glint : hint_range(0.0, 3.0) = 0.4;
group_uniforms;

varying float toon_edge_v;
varying vec3 toon_trans_v;

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float w = clamp((ndl + toon_wrap) / (1.0 + toon_wrap), 0.0, 1.0);
	float lit = smoothstep(0.0, toon_band_soft, w) * ATTENUATION;
	// Ramp: shadow tint (cool violet) -> neutral base -> warm cream.
	vec3 ramp = mix(toon_shadow_tint * toon_shadow_floor, vec3(1.0), smoothstep(0.0, 0.55, lit));
	ramp = mix(ramp, toon_warm_tint * 1.1, smoothstep(0.6, 1.0, lit));
	DIFFUSE_LIGHT += ramp * LIGHT_COLOR / PI;
	// Toon specular blob.
	float gl = 1.0 - ROUGHNESS;
	vec3 hv = normalize(LIGHT + VIEW);
	float sp = pow(clamp(dot(NORMAL, hv), 0.0, 1.0), mix(10.0, 90.0, gl)) * gl * ATTENUATION;
	SPECULAR_LIGHT += smoothstep(toon_spec_size, toon_spec_size + 0.2, sp) * LIGHT_COLOR / PI * toon_spec_strength;
	// Edge glint: bevel edges facing the light catch a bright line.
	float facing = clamp(ndl * 0.5 + 0.5, 0.0, 1.0);
	SPECULAR_LIGHT += toon_edge_v * facing * facing * ATTENUATION * LIGHT_COLOR / PI * toon_glint;
	// Back-light transmission (light travelling toward the viewer through the body).
	vec3 tl = normalize(-(LIGHT + NORMAL * 0.35));
	float back = pow(clamp(dot(VIEW, tl), 0.0, 1.0), 3.0);
	DIFFUSE_LIGHT += toon_trans_v * back * ATTENUATION * LIGHT_COLOR / PI * 2.2;
}
