// spatial_block_topper: small instanced topper props on block tops (sprout, heart, crystal, gear...).
// Technical art 2026-10-13. Albedo = vertex colour; vertex alpha < 1 marks emissive parts
// (emission = rgb * (1 - a) * glow). Compatibility/Mobile/Forward+, no textures, shared toon_light.gdshaderinc (v5).
shader_type spatial;
render_mode cull_disabled;
#include "res://src/view/shaders/toon_light.gdshaderinc"

uniform float gloss : hint_range(0.0, 1.0) = 0.5;
uniform float glow : hint_range(0.0, 4.0) = 2.0;
uniform float rim : hint_range(0.0, 1.0) = 0.3;
uniform vec3 rim_color : source_color = vec3(1.0, 0.93, 0.78);

// toon_light.gdshaderinc varyings must be written by the host (uninitialised varyings render black).
void vertex() {
	toon_edge_v = 0.0;
	toon_trans_v = vec3(0.0);
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 1.0 - gloss;
	// Lit-side fresnel rim (the old painted light() did this per light; toon_light.gdshaderinc has no rim).
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = COLOR.rgb * (1.0 - COLOR.a) * glow + rim_color * fres * rim * 0.35;
}

