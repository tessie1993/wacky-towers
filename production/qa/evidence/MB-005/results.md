# MB-005 — GUIDE verification (2026-10-10, live editor 4.7.2, GUIDE 0.14.0)

Probe: `src/dev/input_probe.tscn`, driven via godot-ai `game_eval` / `input_key` / `input_mouse`. Screenshot: `input_probe_runtime.png` (8 extra test virtual buttons at y=400).

| Check | Result |
|---|---|
| V2 rebind | PASS. Remapper item hard_drop/key: Space -> H. Collision query: H none, Q -> rot_h_left. |
| V2 round trip | PASS. Config -> path-keyed JSON Dictionary (`{ctx_path: {action_path: {index: {script, props}}}}`) -> rebuilt config; rebuilt binding `is_same_as` H. |
| V2 apply | CAVEAT. `GUIDE.set_remapping_config` on an active context is ignored (cached mapping reused). Disable ctx -> set config -> enable ctx works: H fires hard_drop, Space does not. |
| V6 GUIDE paused | PASS. GUIDE is PROCESS_MODE_ALWAYS; key H under `paused=true` triggers the action. |
| V6 virtual button paused | FAIL with default TouchInput (pausable): 0 triggers. PASS with TouchInput PROCESS_MODE_ALWAYS: 1 trigger. Unpaused control: 1. |
| V6 side note | GameInput signals still emit while paused (signal callbacks ignore pause) -> GameInput must gate on pause itself. |
| V5 free indices | Play context binds 0,1,4,6,9-14,16-19. Free: 2(X),3(Y),5(GUIDE),7,8,15(MISC1),20(TOUCHPAD),21(MISC2). Virtual buttons on all eight reached `joy_index Any` actions. |
