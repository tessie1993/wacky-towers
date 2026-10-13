// painted_light.gdshaderinc: the shared painted light() of design/art/style-techniques.md 3.2.
// Wrap + soft 2-tone band, purple-tinted shadow side, soft highlight blob, lit-side fresnel rim.
// The including shader must declare: shadow_tint, wrap, band_soft, gloss, rim, rim_color.
// Compatibility/Mobile/Forward+. Every lit block-family material includes this so the game
// lights as one game.
void light() {
	float ndl = dot(NORMAL, LIGHT);
	float w = (ndl + wrap) / (1.0 + wrap);
	float band = smoothstep(0.0, band_soft, w) * 0.5 + clamp(ndl, 0.0, 1.0) * 0.5;
	float lit = band * ATTENUATION;
	vec3 diff = mix(shadow_tint * 0.18, vec3(1.0), lit);
	DIFFUSE_LIGHT += diff * LIGHT_COLOR / PI;
	vec3 hv = normalize(LIGHT + VIEW);
	float sp = pow(clamp(dot(NORMAL, hv), 0.0, 1.0), mix(8.0, 64.0, gloss)) * gloss * ATTENUATION;
	SPECULAR_LIGHT += smoothstep(0.3, 0.6, sp) * LIGHT_COLOR / PI * 0.5;
	float fr = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	DIFFUSE_LIGHT += fr * rim * rim_color * clamp(ndl + 0.6, 0.0, 1.0) * LIGHT_COLOR / PI;
}
