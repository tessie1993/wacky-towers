// spatial_env_prop: rim dressing, hanging dressing and distant landmarks (procedural meshes built
// by WtIslandBuilder, one MultiMesh per kind). Vertex colour contract: RGB = sRGB albedo,
// A >= 0.75 tinted by the instance tint (INSTANCE_CUSTOM.rgb, linear; .a = 1 on MultiMesh)
// or by `tint_color` on plain MeshInstances; 0.25..0.75 fixed colour; < 0.25 fixed + emissive.
// Shared painted light(). Cost: 2 noise taps.
shader_type spatial;
render_mode cull_back;
#include "res://src/view/shaders/env_painted.gdshaderinc"

uniform vec3 tint_color : source_color = vec3(1.0);
/** Emission of tinted regions (crystals, stars). > 1 blooms. */
uniform float glow : hint_range(0.0, 4.0) = 0.0;
/** Emission of the emissive (A < 0.25) regions. */
uniform float hot : hint_range(0.0, 6.0) = 2.2;
uniform float paint : hint_range(0.0, 1.0) = 0.25;
/** Wind sway in metres at 1 m height (trees, shrubs); 0 under reduced motion via `motion`. */
uniform float sway : hint_range(0.0, 0.3) = 0.0;
uniform float motion : hint_range(0.0, 1.0) = 1.0;

varying vec3 tint;
varying vec3 lp;

void vertex() {
	tint = INSTANCE_CUSTOM.a > 0.5 ? INSTANCE_CUSTOM.rgb : tint_color;
	lp = VERTEX;
	if (sway > 0.0) {
		float ph = wt_h21(vec2(float(INSTANCE_ID), 1.7)) * 6.2831;
		float k = sway * max(VERTEX.y, 0.0) * max(VERTEX.y, 0.0) * motion;
		VERTEX.x += sin(TIME * 1.3 + ph) * k;
		VERTEX.z += cos(TIME * 1.05 + ph) * k * 0.6;
	}
}

void fragment() {
	vec3 base = pow(COLOR.rgb, vec3(2.2));
	float tinted = step(0.75, COLOR.a);
	float em = 1.0 - step(0.25, COLOR.a);
	vec3 col = base * mix(vec3(1.0), tint, tinted);
	col *= 1.0 - paint * 0.5 + paint * wt_fbm(lp.xz * 5.0 + lp.y * 3.0);
	ALBEDO = col;
	ROUGHNESS = 0.8;
	EMISSION = col * em * hot + col * tinted * glow;
	FOG = vec4(haze_color, haze);
}
