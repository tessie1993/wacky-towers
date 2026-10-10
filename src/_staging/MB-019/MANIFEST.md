# MB-019 staging (CH-156, CH-157, CH-158; CH-159 rig NOT included)
All NEW (no replaces). Final paths mirror this folder:
- src/view/camera/view_snap.gd  (ViewSnap; uses CameraMath, Orientations.Axis)
- src/view/camera/ortho_framing.gd  (OrthoFraming; uses CameraMath.ortho_size)
- src/view/camera/motion_prefs.gd  (MotionPrefs)

Note: CameraMath currently lives at src/view/camera_math.gd (class_name, so path does not matter); CH-159 may move it.
Verify via editor script eval per each CH ticket's "How the integrator sees it working".
Unverified: DisplayServer.accessibility_should_reduce_animation (not in engine-reference; called dynamically, falls back to false).
rotation_for signs: world right-hand rule (ADR-0003); spin right = -1 on Y, tilt away = -(sign of screen-right dir), roll right = +(sign of screen-up dir). Check visually.

## Review
- view_snap.gd: typed the untyped `for` loop variables (3 loops + direction_map) and parenthesised the mask test `((_allowed >> i) & 1) == 1`.
- Verified rotation_for signs by hand (right-hand rule, viewer on +Z: tilt away = -sign(right), roll right = +sign(up)); lens_offset signs match Camera3D h_offset/v_offset semantics; ortho_height with huge aspect reduces to the height term of live CameraMath.ortho_size (no duplicated math).
- No clash with live camera_math.gd / camera_rig.gd (new files only; CameraRig.world_axis_for stays until CH-159).
- Divergence from ADR-0014 Key Interfaces (follows CH-156..158 tickets instead): ViewSnap.step returns bool (ADR: int), no set_allowed_for_down_axis (mask via set_allowed), OrthoFraming has ortho_height/lens_size/lens_offset (ADR ortho_h/cube_edge_px with elev), MotionPrefs is instance+Mode (ADR static resolve()). ADR should be updated or CH-159 adapted.
- accessibility_should_reduce_animation is named in ADR-0014 but absent from engine-reference; the has_method guard stays.
