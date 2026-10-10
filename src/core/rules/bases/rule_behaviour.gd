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
		var value: Variant = get(key)
		if value is RefCounted and value.has_method("restore"):
			value.call("restore", state.get(saved, state))
			continue
		if saved == "unlocked": saved = "unlocked_this_resolution"
		if state.has(saved):
			set(key, state[saved])

## Absolute hook deadlines move with an undo checkpoint; lock/clear counters stay unchanged.
func rebase_time(offset_ms: int) -> void:
	var deadlines: PackedStringArray = ["_due", "_until", "_next_ms", "_reveal_until", "_gust_due", "_start"]
	for property: Dictionary in get_property_list():
		var key: String = String(property["name"])
		var value: Variant = get(key)
		if deadlines.has(key) and value is int and value > 0:
			set(key, value + offset_ms)
		elif value is RefCounted and value.has_method("rebase_time"):
			value.call("rebase_time", offset_ms)
