class_name KnobRegistry extends RefCounted
## Effective knob values for one board (ADR-0004 §3). Reads are dictionary lookups.
## Usage: var reg := KnobRegistry.new(defs, {&"fall.g0": 0.9}); reg.value(&"fall.g0") # 900

var _defs: KnobDefs
var _base: Dictionary = {} # StringName -> Variant (default, then level override)
var _effective: Dictionary = {} # StringName -> Variant (RUL-003 rebuilds this from rules)
var _errors: PackedStringArray = PackedStringArray()


## Builds base values: defaults, then level overrides (sorted id order). Bad overrides go to errors().
func _init(defs: KnobDefs, level_overrides: Dictionary[StringName, Variant], values_are_fixed: bool = false) -> void:
	_defs = defs
	for id: StringName in defs.ids():
		_base[id] = (defs.def(id) as Dictionary)["default"]
	var keys: Array[StringName] = level_overrides.keys()
	keys.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	for id: StringName in keys:
		if not defs.has(id):
			_errors.append("level knob '%s': unknown knob" % id)
			continue
		var raw: Variant = level_overrides[id]
		var definition: Dictionary = defs.def(id)
		var coerced: Variant = null
		if values_are_fixed and definition["type"] == KnobDefs.T_SCALAR:
			if raw is int and raw >= definition["min"] and raw <= definition["max"] and (raw != 0 or definition["allows_zero"]):
				coerced = raw
		else:
			coerced = defs.coerce(id, String(raw) if raw is StringName else raw)
		if coerced == null:
			_errors.append("level knob '%s': %s" % [id, defs.last_error()])
		else:
			_base[id] = coerced
	_effective = _base.duplicate()


## Effective value; null if the id is unknown. Usage: reg.value(&"fall.g0")
func value(id: StringName) -> Variant:
	return _effective.get(id)


## Value as int (scalars are milli-units); 0 if unknown or not a number. Usage: reg.int_value(&"fall.lock_delay_ms")
func int_value(id: StringName) -> int:
	var v: Variant = _effective.get(id)
	return v if typeof(v) == TYPE_INT else 0


## Value as bool; false if unknown or not a bool. Usage: reg.flag(&"fall.hard_drop")
func flag(id: StringName) -> bool:
	var v: Variant = _effective.get(id)
	return v if typeof(v) == TYPE_BOOL else false


## Rejected overrides from _init, one string each. Usage: assert(reg.errors().is_empty())
func errors() -> PackedStringArray:
	return _errors

## Restores cached fixed-unit values during optional puzzle undo.
func restore(values: Dictionary) -> void:
	_effective = values.duplicate(true)


## Rebuilds active modifiers in ascending rule priority order; set wins before adds/multipliers.
## Values in trusted RuleDefs are JSON numbers; scalar set/add values convert to milli-units.
## Example: reg.apply_modifiers([{"knob": "fall.gravity_scale", "op": "mul", "value": 0.8}]).
func apply_modifiers(modifiers: Array[Dictionary]) -> Array[Dictionary]:
	_effective = _base.duplicate()
	var clamps: Array[Dictionary] = []
	var grouped: Dictionary = {}
	for modifier: Dictionary in modifiers:
		var id: StringName = StringName(modifier.get("knob", modifier.get("id", "")))
		if not _defs.has(id) or not bool(_defs.def(id).get("rule_adjustable", false)):
			continue
		var group: Array = grouped.get_or_add(id, [])
		group.append(modifier)
	for id: StringName in grouped:
		var definition: Dictionary = _defs.def(id)
		var v: Variant = _base[id]
		for modifier: Dictionary in grouped[id]:
			if modifier.get("op", "set") == "set":
				var raw: Variant = modifier.get("value", modifier.get("v"))
				var coerced: Variant = _defs.coerce(id, raw)
				if coerced != null:
					v = coerced
		for modifier: Dictionary in grouped[id]:
			var op: String = modifier.get("op", "set")
			var amount: Variant = modifier.get("value", modifier.get("v", 0))
			if not (v is int) or not (amount is int or amount is float):
				continue
			if op == "add":
				v += roundi(float(amount) * 1000) if definition["type"] == KnobDefs.T_SCALAR else int(amount)
			elif op in ["mul", "multiply"]:
				v = int(v) * roundi(float(amount) * 1000) / 1000
		if v is int and definition.has("min"):
			var bounded: int = clampi(v, definition["min"], definition["max"])
			if bounded != v:
				clamps.append({"knob": id, "before": v, "after": bounded})
			v = bounded
		_effective[id] = v
	return clamps

## Swaps a validated slot at the resolving boundary. Example: reg.set_slot(&"goal.top_out", &"trim").
func set_slot(id: StringName, value: Variant) -> bool:
	if not _defs.has(id) or _defs.def(id)["type"] != KnobDefs.T_SLOT:
		return false
	var converted: Variant = _defs.coerce(id, String(value))
	if converted == null:
		return false
	_base[id] = converted
	_effective[id] = converted
	return true

## Cached values for scoring and replay diagnostics. Example: ScoreKeeper.new(reg.snapshot()).
func snapshot() -> Dictionary:
	return _effective.duplicate(true)

## Evaluate candidate effects without changing the live registry.
func preview_modifiers(modifiers: Array[Dictionary]) -> Dictionary:
	var probe: KnobRegistry = KnobRegistry.new(_defs, {})
	probe._base = _base.duplicate(true)
	probe.apply_modifiers(modifiers)
	return probe.snapshot()

## Changes an effective numeric value using fixed-point runtime units. Example: reg.set_effective(&"fall.gravity_scale", 250).
func set_effective(id: StringName, value: Variant) -> bool:
	if not _defs.has(id):
		return false
	var definition: Dictionary = _defs.def(id)
	if not bool(definition.get("rule_adjustable", false)):
		return false
	if value is int and definition.has("min"):
		_effective[id] = clampi(value, definition["min"], definition["max"])
		return true
	if typeof(value) == typeof(_effective[id]):
		_effective[id] = value
		return true
	return false
