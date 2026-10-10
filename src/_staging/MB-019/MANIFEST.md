# MB-019 staging (CH-156, CH-157, CH-158; CH-159 rig NOT included)
All NEW (no replaces). Final paths mirror this folder:
- src/view/camera/view_snap.gd  (ViewSnap; uses CameraMath, Orientations.Axis)
- src/view/camera/ortho_framing.gd  (OrthoFraming; uses CameraMath.ortho_size)
- src/view/camera/motion_prefs.gd  (MotionPrefs)

Note: CameraMath currently lives at src/view/camera_math.gd (class_name, so path does not matter); CH-159 may move it.
Verify via editor script eval per each CH ticket's "How the integrator sees it working".
Unverified: DisplayServer.accessibility_should_reduce_animation (not in engine-reference; called dynamically, falls back to false).
rotation_for signs: world right-hand rule (ADR-0003); spin right = -1 on Y, tilt away = -(sign of screen-right dir), roll right = +(sign of screen-up dir). Check visually.
