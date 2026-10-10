## Base class for every UI screen (ADR-0016 §1-3, §7). Owns no state: it binds a snapshot,
## emits intents, and never handles ui_cancel itself (AppFlow routes Back via [member back_rule]).
class_name UiScreen
extends Control

## Emitted for every user action; args are intent-specific (see [UiIntents]).
signal intent(id: StringName, args: Dictionary)

## Unique id AppFlow uses to find this screen.
@export var screen_id: StringName
## What Back does here: &"pop" | &"resume" | &"to_map" | &"quit_dialog".
@export var back_rule: StringName = &"pop"


## Called when the screen becomes the active top. [param is_resume] is true when uncovered by a pop.
func enter(is_resume: bool) -> void:
	show()
	var target: Control = default_focus()
	if target != null:
		target.grab_focus()


## Called when the screen leaves the stack.
func exit() -> void:
	hide()


## Binds a read-only snapshot to the widgets. Override; must be idempotent.
func bind(_snapshot: RefCounted) -> void:
	pass


## Applies user prefs (UiPrefs). Override later.
func apply_prefs(_prefs: RefCounted) -> void:
	pass


## Control to focus on enter. Override; must never be a destructive control.
func default_focus() -> Control:
	return null
