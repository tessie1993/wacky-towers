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


## Extra checks this plugin needs on a level (e.g. "conveyor needs an unmasked board"). Default: none.
## Usage: override and return `ValidationIssue.error(...)` entries.
func validate(_level: LevelData, _catalog: GameCatalog) -> Array[ValidationIssue]:
	return []


## All mutable behaviour state for replay hashes. Usage: return {"counter": _counter}.
func snapshot() -> Dictionary:
	return {}

## Restore mutable counters for optional turn-level undo. Plugins may override aliases.
func restore(state: Dictionary) -> void:
	for property: Dictionary in get_property_list():
		var key: String = String(property["name"])
		var saved: String = key.trim_prefix("_")
		if state.has(saved):
			set(key, state[saved])
