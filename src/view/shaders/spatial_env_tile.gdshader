// spatial_env_tile: bevelled cream stone grid tiles, one MultiMesh (technical art, 2026-10-13).
// Mesh: assets/models/env/env_tile.glb. Vertex colour: R = bevel shade, G = Poly Haven rock_face
// detail per vertex, B = 1 on the top face. INSTANCE_CUSTOM.rgb = linear tile tint (checker), .a = seed.
// One detail-texture sample (shared env_detail.png, G channel), no discard.
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D detail : hint_default_white, repeat_enable, filter_linear_mipmap;
/** How strongly the stone texture breaks up the flat tile colour. */
uniform float detail_strength : hint_range(0.0, 1.0) = 0.35;
/** Brightening of the bevelled top edge that catches the key light (mockup plaza tiles). */
uniform float edge_highlight : hint_range(0.0, 0.6) = 0.22;
/** Emissive grout/edge colour for neon-style floors (0 = off). */
uniform vec3 edge_glow_color : source_color = vec3(0.4, 0.9, 1.0);
uniform float edge_glow : hint_range(0.0, 4.0) = 0.0;

varying vec3 tint;
varying vec3 wpos;
varying float seed;

void vertex() {
	tint = INSTANCE_CUSTOM.rgb;
	seed = INSTANCE_CUSTOM.a;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 wn = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float stone = texture(detail, wpos.xz * 0.37 + vec2(seed * 7.0, seed * 3.0)).g;
	vec3 col = tint * mix(1.0, 0.78 + 0.44 * stone, detail_strength);
	float top = COLOR.b;
	float chamfer = (1.0 - top) * smoothstep(0.2, 0.75, wn.y);
	col *= mix(0.62, 1.0, COLOR.r);
	col *= 1.0 + chamfer * edge_highlight;
	ALBEDO = col;
	ROUGHNESS = 0.82;
	EMISSION = edge_glow_color * edge_glow * chamfer;
}
