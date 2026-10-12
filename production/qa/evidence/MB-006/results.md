# MB-006 — phantom_camera verification (2026-10-10, live editor 4.7.2, phantom_camera 0.11.0.3)

Scene: `src/dev/pcam_probe.tscn` (Camera3D + PhantomCameraHost, PhantomCamera3D with Camera3DResource projection=ORTHOGONAL size=20, CSG board).
Screenshots: `pcam_probe_editor_cinematic.png`, `pcam_probe_runtime.png`.

- Load: PASS, no phantom_camera errors in editor log or game log.
- Drive ortho Camera3D: PASS, runtime camera projection=1, size=20, position = pcam (10,10,10), host active pcam = PCam.
- Idle cost (2000-call average, in game): host `_process` 5.8 us, host `_physics_process` 1.3 us, pcam `_process` 1.4 us, pcam `_physics_process` 1.2 us -> ~10 us/frame. Profiler panel capture not taken (no MCP access to the editor profiler); numbers are direct timing.
- Not covered: release build, Android export.
