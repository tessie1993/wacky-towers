# CH-155 InputContextRouter + play / play_paused / menu / remap_capture contexts

**MB task:** MB-015 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-153, CH-154
**Files:** new `src/game/input/input_context_router.gd`; new `src/game/input/contexts/play_paused.tres`, `menu.tres`, `remap_capture.tres`

## API
```gdscript
class_name InputContextRouter extends Node
## Only caller of GUIDE.enable/disable_mapping_context for gameplay and menus (ADR-0012 §2).
enum Ctx { PLAY, PLAY_PAUSED, MENU, REMAP_CAPTURE }
func set_screen(ctx: Ctx) -> void      ## disables every other router context, enables ctx
func current() -> Ctx
func reassert() -> void                ## re-enable the current context (after pause/resume)
```

## Behaviour
- Priority REMAP_CAPTURE > PLAY_PAUSED/MENU > PLAY: `set_screen` activates exactly one context at a time (simple rule, no stacking in MVP).
- `play.tres` = CH-153 file. `play_paused`: resume (Start/Esc/P), restart, back (B/Esc); no piece actions. `menu`: wraps `ui_up/down/left/right/accept/cancel/focus_next/focus_prev` (arrows, WASD, d-pad, A/B, Tab, LB/RB). `remap_capture`: empty context (the detector arrives with the remap UI).
- `GameInput.enable()/disable()` call `router.set_screen(PLAY)` / nothing; GameInput gets an exported `router: InputContextRouter` (null = old direct GUIDE call, keeps `input_probe` working).
- Node is `PROCESS_MODE_ALWAYS`. Not an autoload; `Main` owns it later.

## How the integrator sees it working
Add the router to `src/dev/input_probe.tscn`. Run it. Call `set_screen(Ctx.PLAY_PAUSED)` from a key: Q/E print nothing, Esc prints resume. `set_screen(Ctx.MENU)`: arrow keys move UI focus on a Button in the scene. `logs_read` clean.

**Out of scope: remap UI, GUIDE.set_remapping_config (settings task).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
