// spatial_block_topper: small instanced topper props on block tops (sprout, heart, crystal, gear...).
// Technical art 2026-10-13. Albedo = vertex colour; vertex alpha < 1 marks emissive parts
// (emission = rgb * (1 - a) * glow). Compatibility/Mobile/Forward+, no textures, shared painted light.
shader_type spatial;
render_mode cull_disabled;

uniform float gloss : hint_range(0.0, 1.0) = 0.5;
uniform float glow : hint_range(0.0, 4.0) = 2.0;
uniform float rim : hint_range(0.0, 1.0) = 0.3;
uniform vec3 rim_color : source_color = vec3(1.0, 0.93, 0.78);
uniform vec3 shadow_tint : source_color = vec3(0.42, 0.36, 0.62);
uniform float wrap : hint_range(0.0, 1.0) = 0.45;
uniform float band_soft : hint_range(0.01, 1.0) = 0.35;

void fragment() {
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 1.0 - gloss;
	EMISSION = COLOR.rgb * (1.0 - COLOR.a) * glow;
}

#include "res://src/view/shaders/painted_light.gdshaderinc"
