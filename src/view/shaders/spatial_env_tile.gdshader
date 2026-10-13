// spatial_env_tile: rounded stone board tiles, one MultiMesh (use_colors: instance colour =
// sRGB tile tint). Calm painted mottle, a few soft strokes, lit bevel edge, darker sides so the
// grout reads as shadow. Recipe: design/art/style-techniques.md §5.1 "Board". ~4 noise taps.
shader_type spatial;
render_mode cull_back;
#include "res://src/view/shaders/env_painted.gdshaderinc"

/** Half extents and corner radius of the tile mesh. */
uniform vec3 tile_half = vec3(0.48, 0.11, 0.48);
uniform float tile_radius = 0.07;
uniform float edge_light : hint_range(0.0, 1.0) = 0.45;
uniform float mottle : hint_range(0.0, 1.0) = 1.0;
/** Emissive bevel colour for neon-style floors (0 = off). */
uniform vec3 edge_glow_color : source_color = vec3(0.4, 0.9, 1.0);
uniform float edge_glow : hint_range(0.0, 4.0) = 0.0;

varying vec3 lp;
varying vec3 tint;
varying float tseed;

void vertex() {
	lp = VERTEX;
	tint = pow(COLOR.rgb, vec3(2.2));
	tseed = wt_h21(vec2(float(INSTANCE_ID), 3.1));
}

void fragment() {
	vec2 uv = lp.xz * 2.0 + tseed * 13.0;
	float paint = wt_fbm(uv);
	vec3 col = mix(tint * 0.9, tint * 1.04, mix(0.6, smoothstep(0.2, 0.8, paint), mottle));
	float stroke = smoothstep(0.62, 0.7, wt_vn(vec2(uv.x * 0.7 + uv.y * 1.6, 5.0 + tseed * 9.0)));
	col *= 1.0 - stroke * 0.04 * mottle;
	vec3 e3 = clamp((abs(lp) - (tile_half - vec3(tile_radius))) / tile_radius, 0.0, 1.0);
	float edge = max(e3.x, e3.z) * step(0.0, lp.y);
	col = mix(col, col * 1.22 + 0.03, edge * edge_light);
	col *= mix(1.0, smoothstep(-0.12, 0.08, lp.y), 0.45);
	ALBEDO = col;
	ROUGHNESS = 0.8;
	EMISSION = edge_glow_color * edge_glow * edge;
}
