shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// spatial_fx_sparkle.gdshader: camera-facing painted sparkle (4-point star + soft core) and
// dust puff for piece lock / line clear. MultiMesh instance data:
//   COLOR = tint, INSTANCE_CUSTOM = (age 0..1, size in world units, kind 0 star / 1 puff, spin).
// Works on Compatibility, Mobile and Forward+ (no screen/depth reads).
varying float v_age;
varying float v_kind;

void vertex() {
	v_age = INSTANCE_CUSTOM.x;
	v_kind = INSTANCE_CUSTOM.z;
	// Billboard: rebuild the model-view with the camera's axes but the instance position.
	float grow = v_kind > 0.5 ? mix(0.5, 1.6, v_age) : 1.0 - 0.6 * v_age;
	float s = INSTANCE_CUSTOM.y * grow;
	float c = cos(INSTANCE_CUSTOM.w), sn = sin(INSTANCE_CUSTOM.w);
	vec2 v = vec2(c * VERTEX.x - sn * VERTEX.y, sn * VERTEX.x + c * VERTEX.y) * s;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	VERTEX = vec3(v, 0.0);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float a;
	vec3 col = COLOR.rgb;
	if (v_kind < 0.5) {
		// Four-point star: thin cross spikes plus a hot core, twinkling with age.
		float spike = max(0.0, 1.0 - 9.0 * min(abs(p.x), abs(p.y))) * (1.0 - r);
		float core = 1.0 - smoothstep(0.0, 0.35, r);
		a = clamp(spike + core, 0.0, 1.0) * (1.0 - smoothstep(0.55, 1.0, v_age));
		col = mix(col, vec3(1.0, 0.97, 0.85), core);
		EMISSION = col * 1.6;
	} else {
		// Dust puff: soft round cloud that expands and thins out.
		a = (1.0 - smoothstep(0.2, 1.0, r)) * 0.55 * (1.0 - v_age);
	}
	ALBEDO = col;
	ALPHA = a;
}
