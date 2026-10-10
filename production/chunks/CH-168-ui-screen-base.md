# CH-168 UiScreen base, UiLayers, UiIntents

**MB task:** MB-027 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** none (ADR-0016)
**Files:** new `src/ui/common/ui_screen.gd`, `src/ui/common/ui_layers.gd`, `src/ui/common/ui_intents.gd`

## API
```gdscript
class_name UiScreen extends Control
signal intent(id: StringName, args: Dictionary)
@export var screen_id: StringName
@export var back_rule: StringName = &"pop"      ## &"pop" | &"resume" | &"to_map" | &"quit_dialog"
func enter(is_resume: bool) -> void             ## default: show
func exit() -> void
func bind(snapshot: RefCounted) -> void         ## override; idempotent
func apply_prefs(prefs: RefCounted) -> void     ## override later (UiPrefs)
func default_focus() -> Control                 ## override; never a destructive control
class_name UiLayers extends RefCounted          ## consts: HUD=10, SCREENS=20, PAUSE=30, DIALOGS=40, TOASTS=50, COVER=60
class_name UiIntents extends RefCounted         ## StringName consts: BACK, PLAY, CONTINUE, OPEN_MAP, OPEN_SETTINGS, OPEN_PROFILES, PAUSE, RESUME, RETRY, NEXT, TO_MAP, SET_PREF, SELECT_PROFILE, CREATE_PROFILE, DELETE_PROFILE, RENAME_PROFILE, OPEN_LEVEL, QUIT
```

## Behaviour
- ADR-0016 §1-3, §7. Screens never handle `ui_cancel` themselves: Back is routed by AppFlow using `back_rule`. UI owns no state.
- Make `Hud` (CH-062) extend UiScreen once this exists (small follow-up in that file).

## How the integrator sees it working
Editor: create a test scene with a UiScreen subclass overriding `default_focus`; `project_run`; `logs_read` clean; the class shows in the Create Node dialog.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
