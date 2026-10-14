// Style R&D prototype: painted 2D backdrop drawn BEHIND the 3D world (Environment BG_CANVAS).
// Screen-space gradient + puffy fbm cloud sea + optional stars. Works identically on
// Compatibility / Mobile / Forward+ (sky shaders do not: Compatibility samples the sky
// via the radiance cubemap, so SCREEN_UV gradients are lost). Target: all renderers.
shader_type canvas_item;

uniform vec3 top : source_color = vec3(0.31, 0.58, 0.90);
uniform vec3 horizon : source_color = vec3(0.81, 0.90, 0.98);
uniform vec3 low : source_color = vec3(1.0, 0.96, 0.90);
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.8;
uniform float stars : hint_range(0.0, 1.0) = 0.0;
uniform float aspect = 0.5625; // width / height

float h21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vn(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) { return vn(p) * 0.5 + vn(p * 2.1) * 0.3 + vn(p * 4.3) * 0.2; }

void fragment() {
	vec2 uv = UV;
	vec3 c = mix(top, horizon, smoothstep(0.0, 0.7, uv.y));
	c = mix(c, low, smoothstep(0.7, 1.0, uv.y));
	// cloud sea in the lower half + a few wisps up top; billowy = soft threshold on fbm,
	// then a lit top / shaded underside from a vertical offset sample (painted volume).
	vec2 cp = vec2(uv.x * aspect, uv.y) * vec2(5.0, 9.0);
	float n = fbm(cp + vec2(1.7, 0.0));
	float n_up = fbm(cp + vec2(1.7, 0.25));
	float band = smoothstep(0.45, 0.95, uv.y) + 0.35 * smoothstep(0.35, 0.0, uv.y);
	float cl = smoothstep(0.42, 0.62, n) * band * cloud_amount;
	vec3 cloud = mix(vec3(0.86, 0.88, 0.97), vec3(1.0, 0.98, 0.95), smoothstep(-0.05, 0.08, n - n_up));
	c = mix(c, cloud, cl);
	float s = step(0.997, h21(floor(uv * vec2(400.0 * aspect, 400.0)))) * stars * (1.0 - uv.y);
	COLOR = vec4(c + s, 1.0);
}
