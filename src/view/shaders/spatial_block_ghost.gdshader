// spatial_block_ghost: Wacky Towers landing ghost (technical art, 2026-10-13).
// Glassy translucent cube with a glowing edge in the piece colour (instance COLOR); refs 01/14.
// Compatibility/Mobile/Forward+. Object-space edge mask, so it works on WtBlockMesh and BoxMesh.
// Budget: alpha-blended, no texture samples, ~20 ALU ops.
shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, unshaded;

// Base glass opacity in the face centre.
uniform float body_alpha : hint_range(0.0, 1.0) = 0.26;
// Edge glow strength (HDR, > 1 blooms with the stage glow).
uniform float edge_glow : hint_range(0.0, 4.0) = 1.6;
// Width of the glowing edge band in cube units.
uniform float edge_width : hint_range(0.01, 0.3) = 0.16;

varying vec3 lp;

void vertex() { lp = VERTEX; }

void fragment() {
	// Edge band: second-largest |axis| close to the cube surface = along an edge.
	vec3 a = abs(lp);
	float mx = max(a.x, max(a.y, a.z));
	float mid = a.x + a.y + a.z - mx - min(a.x, min(a.y, a.z));
	float edge = smoothstep(0.5 - edge_width, 0.5 - edge_width * 0.3, mid / max(mx, 0.001) * 0.5);
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	vec3 tint = COLOR.rgb;
	// Diagonal glass sheen streak.
	float sheen = smoothstep(0.06, 0.0, abs(fract((lp.x + lp.y) * 1.2 + 0.2) - 0.5) - 0.12) * 0.25;
	ALBEDO = mix(tint * 0.85 + 0.1, vec3(1.0), sheen) + (tint + 0.25) * edge * edge_glow;
	ALPHA = clamp(body_alpha + fres * 0.3 + sheen * 0.3 + edge * 0.85, 0.0, 1.0);
}
