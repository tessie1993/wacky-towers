# CH-170 AppFlow node: screens, Back, pause request, level open

**MB task:** MB-027 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-169, CH-155 (router); MB-014 deferred (Android smoke test moved to the end, desktop first)
**Files:** new `src/game/app_flow.gd` (`class_name AppFlow extends Node`, PROCESS_MODE_ALWAYS), `src/game/app_flow.tscn` with CanvasLayers Screens(20), Dialogs(40), Toasts(50), Cover(60)

## API
```gdscript
class_name AppFlow extends Node
signal screen_changed(screen_id: StringName)
func register_screen(id: StringName, scene: PackedScene) -> void
func push_screen(id: StringName, snapshot: RefCounted = null) -> void
func back() -> void                         ## at most once per process frame; ScreenStack.back_action(): pop / resume / to_map / quit_dialog
func request_pause(reason: StringName) -> void   ## emits pause_requested; PlaySession handles it (later)
signal pause_requested(reason: StringName)
func open_level(scene_path: String) -> void       ## ResourceLoader.load_threaded_request; polls in _process; failure -> toast, stay on map
```

## Behaviour
- Plain GDScript now (the documented fallback of ADR-0010 §5); a thin Orchestrator graph can wrap these same methods after the Android smoke test (CH-180). No gameplay logic here.
- Back sources: `ui_cancel` (Esc, pad B) and `NOTIFICATION_WM_GO_BACK_REQUEST`; `application/config/quit_on_go_back = false` in project settings (integrator checks).
- After every push/pop: tell `InputContextRouter.set_screen(MENU)` (or PLAY_PAUSED for pause rules) and `grab_focus()` on `default_focus()` only in keyboard/gamepad mode.
- Title is the base screen; Back on Title pushes the Quit dialog (CH-173).

## How the integrator sees it working
Run a scratch scene with two dummy screens: Esc on the top screen pops it, focus returns to the lower screen's focused button, two Esc in the same frame pop once. `logs_read` clean.

**Out of scope: level loading cover visuals, PlaySession, save.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
