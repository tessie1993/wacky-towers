# CH-169 ScreenStack (pushdown) + back rules

**MB task:** MB-027 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168
**Files:** new `src/game/screen_stack.gd` (`class_name ScreenStack extends RefCounted`)

## API
```gdscript
class_name ScreenStack extends RefCounted
func push(screen: UiScreen) -> void            ## covered screen kept; exit() NOT called; pushed.enter(false)
func pop() -> UiScreen                         ## never pops the base; uncovered top gets enter(true); returns popped (caller frees overlays)
func top() -> UiScreen
func size() -> int
func back_action() -> StringName               ## top().back_rule, or &"pop"
```

## Behaviour
- ADR-0010 §3: one `back()` per process frame guard lives in AppFlow, not here. Base (index 0, Title) cannot be popped.
- Pure bookkeeping + calling `enter/exit`; no scene tree work.

## How the integrator sees it working
Editor script eval with 3 dummy UiScreens: push A (base), push B, push C; `pop()` returns C and B receives `enter(true)`; pop twice more: second returns B, third returns null (base stays). Print enter/exit order; read via `logs_read`.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
