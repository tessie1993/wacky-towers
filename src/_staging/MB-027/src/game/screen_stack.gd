## Pushdown stack of [UiScreen]s: pure bookkeeping plus enter/exit calls (ADR-0010 §3).
## The once-per-frame back() guard lives in AppFlow, not here.
class_name ScreenStack
extends RefCounted

var _screens: Array[UiScreen] = []


## Pushes [param screen] over the current top; the covered screen is kept and not exited.
func push(screen: UiScreen) -> void:
	_screens.push_back(screen)
	screen.enter(false)


## Pops the top and re-enters the uncovered screen. The base (index 0) is never popped: returns null.
## The caller frees overlays.
func pop() -> UiScreen:
	if _screens.size() <= 1:
		return null
	var popped: UiScreen = _screens.pop_back()
	popped.exit()
	_screens.back().enter(true)
	return popped


## Current top screen, or null when empty.
func top() -> UiScreen:
	return null if _screens.is_empty() else _screens.back()


## Number of screens on the stack.
func size() -> int:
	return _screens.size()


## Back rule of the top screen, or &"pop" when empty.
func back_action() -> StringName:
	return &"pop" if _screens.is_empty() else _screens.back().back_rule
