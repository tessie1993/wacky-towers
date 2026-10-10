@abstract
class_name RuleBehaviour extends RefCounted
## A rule with behaviour: subscribes to hooks, may veto actions (ADR-0004). Plugins declare const PLUGIN_ID: StringName.

## Hooks this rule wants to run on. Usage: `return [&"on_land"]`.
func subscribed_hooks() -> Array[StringName]:
	return []


## Runs when a subscribed hook fires. Usage: override and call `api` methods.
func handle(_hook: StringName, _ctx: HookContext, _api: RuleApi) -> void:
	pass


## Return true to veto `action`. Usage: `if rule.veto(&"move", ctx, api): return`.
func veto(_action: StringName, _ctx: HookContext, _api: RuleApi) -> bool:
	return false


## Compatibility tags (ADR-0004 atoms). Usage: `rule.tags().is_empty()`.
func tags() -> PackedStringArray:
	return PackedStringArray()
