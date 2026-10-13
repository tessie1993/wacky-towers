// Style R&D prototype: painted sky (3-stop gradient + soft fbm clouds + stars for night).
// Compatibility-safe sky shader (no radiance-dependent tricks). Target: all renderers.
shader_type sky;

uniform vec3 top : source_color = vec3(0.44, 0.66, 0.92);
uniform vec3 horizon : source_color = vec3(0.99, 0.91, 0.80);
uniform vec3 low : source_color = vec3(0.85, 0.89, 0.97);
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.55;
uniform float stars : hint_range(0.0, 1.0) = 0.0;

float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vn(p) * 0.5 + vn(p * 2.1) * 0.3 + vn(p * 4.3) * 0.2; }

void sky() {
	float y = EYEDIR.y;
	vec3 c = y > 0.0 ? mix(horizon, top, smoothstep(0.0, 0.6, y)) : mix(horizon, low, smoothstep(0.0, -0.3, y));
	// Cumulus band near the horizon: puffy because the noise is thresholded softly.
	vec2 uv = EYEDIR.xz / max(abs(y) + 0.25, 0.05) * 1.6;
	float cl = smoothstep(0.45, 0.75, fbm(uv + vec2(3.0, 1.0))) * smoothstep(0.55, 0.02, abs(y + 0.05)) * cloud_amount;
	vec3 cloud_col = mix(vec3(1.0, 0.97, 0.94), horizon, 0.25) * (0.92 + 0.12 * fbm(uv * 3.0));
	c = mix(c, cloud_col, cl);
	float s = step(0.996, h21(floor(EYEDIR.xy * 300.0 + EYEDIR.z * 91.0))) * stars * smoothstep(0.0, 0.3, y);
	COLOR = c + s * 2.0;
}
