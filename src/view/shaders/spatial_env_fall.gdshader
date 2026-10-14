// spatial_env_fall: waterfall / lavafall / syrup / light ribbon off the island lip (technical art, 2026-10-13).
// Mesh: a QuadMesh from WtIslandBuilder (UV.y runs down the flow, UV.x across it); vertex alpha
// (or 1 when absent) = edge and end fade. Opaque with alpha scissor (no sorting, no blended overdraw).
// Cost: 2 value-noise octaves + foam bands. Emission > 1 blooms with Environment glow (lava, neon).
shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

group_uniforms look;
uniform vec3 deep : source_color = vec3(0.24, 0.6, 0.84);
uniform vec3 light : source_color = vec3(0.74, 0.92, 1.0);
uniform vec3 foam : source_color = vec3(1.0);
/** Emission multiplier of the flow colour (0 water, ~2.5 lava). */
uniform float emission : hint_range(0.0, 8.0) = 0.0;
/** Flow speed in UV units per second. */
uniform float speed : hint_range(0.0, 3.0) = 0.7;
/** 0 under reduced motion. */
uniform float motion : hint_range(0.0, 1.0) = 1.0;
/** Sparkle density for stardust/neon falls (0 = off). */
uniform float sparkle : hint_range(0.0, 1.0) = 0.0;
/** Aerial haze for distant falls (FOG write; no global fog). */
uniform vec3 haze_color : source_color = vec3(0.84, 0.89, 0.97);
uniform float haze : hint_range(0.0, 1.0) = 0.0;
group_uniforms;

float hash21(vec2 p) { p = fract(p * vec2(123.34, 456.21)); p += dot(p, p + 45.32); return fract(p.x * p.y); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	float t = TIME * speed * motion;
	vec2 uv = UV;
	float n1 = vnoise(vec2(uv.x * 7.0, uv.y * 5.0 - t * 3.0));
	float n2 = vnoise(vec2(uv.x * 15.0 + 3.1, uv.y * 11.0 - t * 5.2));
	float streak = n1 * 0.62 + n2 * 0.38;
	vec3 col = mix(deep, light, smoothstep(0.35, 0.8, streak));
	// Foam: a bright lip where the flow tips over, and churn toward the misty bottom.
	float lip = 1.0 - smoothstep(0.06, 0.16, uv.y);
	float churn = smoothstep(0.65, 0.95, uv.y) * smoothstep(0.45, 0.75, n2);
	float bands = smoothstep(0.72, 0.9, streak);
	col = mix(col, foam, clamp(lip * 0.85 + churn + bands * 0.55, 0.0, 1.0));
	float st = sparkle * step(0.985, hash21(floor(vec2(uv.x * 40.0, uv.y * 60.0 - t * 30.0))));
	col += foam * st * 2.0;
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	ALBEDO = col;
	ROUGHNESS = 0.25;
	EMISSION = col * emission + foam * fres * 0.15 + foam * st * (1.0 + emission);
	// Edge and end dissolve through the noise instead of a hard ribbon edge.
	ALPHA = clamp(COLOR.a * 1.6 - (1.0 - streak) * 0.55, 0.0, 1.0);
	ALPHA_SCISSOR_THRESHOLD = 0.35;
	FOG = vec4(haze_color, haze);
}
