// env_painted.gdshaderinc: the ONE painted light() every environment material shares
// (design/art/style-techniques.md §3.2): wrap + soft 2-tone band + true lambert, purple-tinted
// shade, soft highlight blob, warm fresnel rim on the lit side. LIGHT_COLOR already carries
// energy x PI, so it is divided by PI as the built-in Lambert does.
// Also: per-material aerial haze (FOG write, cookbook §2.4: no global fog) and cheap value noise.

/** Colour of the shade side (multiplied by 0.18). Lilac/blue, never grey. */
uniform vec3 shadow_tint : source_color = vec3(0.42, 0.36, 0.62);
uniform vec3 rim_color : source_color = vec3(1.0, 0.9, 0.75);
uniform float rim_amount : hint_range(0.0, 1.0) = 0.35;
uniform float gloss : hint_range(0.0, 1.0) = 0.1;
/** Aerial perspective for distant props: blend toward the horizon colour (0 = none). */
uniform vec3 haze_color : source_color = vec3(0.84, 0.89, 0.97);
uniform float haze : hint_range(0.0, 1.0) = 0.0;

float wt_h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float wt_vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(wt_h21(i), wt_h21(i + vec2(1, 0)), f.x), mix(wt_h21(i + vec2(0, 1)), wt_h21(i + vec2(1, 1)), f.x), f.y);
}
float wt_fbm(vec2 p) { return wt_vn(p) * 0.5 + wt_vn(p * 2.1) * 0.3 + wt_vn(p * 4.3) * 0.2; }

void light() {
	float ndl = dot(NORMAL, LIGHT);
	float w = (ndl + 0.45) / 1.45;
	float band = smoothstep(0.0, 0.35, w) * 0.5 + clamp(ndl, 0.0, 1.0) * 0.5;
	float lit = band * ATTENUATION;
	vec3 diff = mix(shadow_tint * 0.18, vec3(1.0), lit);
	DIFFUSE_LIGHT += diff * LIGHT_COLOR / PI;
	vec3 h = normalize(LIGHT + VIEW);
	float sp = pow(clamp(dot(NORMAL, h), 0.0, 1.0), mix(8.0, 64.0, gloss)) * gloss * ATTENUATION;
	SPECULAR_LIGHT += smoothstep(0.3, 0.6, sp) * LIGHT_COLOR / PI * 0.5;
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	DIFFUSE_LIGHT += rim * rim_amount * rim_color * clamp(ndl + 0.6, 0.0, 1.0) * LIGHT_COLOR / PI;
}
