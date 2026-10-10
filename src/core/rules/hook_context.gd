class_name HookContext extends RefCounted
## Payload passed to a rule hook (ADR-0004). Usage: `var c := HookContext.new(); c.hook = &"on_land"`.

## Hook name being run.
var hook: StringName = &""
## Hook-specific payload.
var data: Dictionary = {}
## Chain depth (ADR-0004 hook pipeline; limit is a rules.* knob).
var depth: int = 0
