class_name KnobRegistry extends RefCounted
## Effective knob values for one board (ADR-0004 §3). Reads are dictionary lookups.
## Usage: var reg := KnobRegistry.new(defs, {&"fall.g0": 0.9}); reg.value(&"fall.g0") # 900

var _base: Dictionary = {} # StringName -> Variant (default, then level override)
var _effective: Dictionary = {} # StringName -> Variant (RUL-003 rebuilds this from rules)
var _errors: PackedStringArray = PackedStringArray()


## Builds base values: defaults, then level overrides (sorted id order). Bad overrides go to errors().
func _init(defs: KnobDefs, level_overrides: Dictionary[StringName, Variant]) -> void:
	for id: StringName in defs.ids():
		_base[id] = (defs.def(id) as Dictionary)["default"]
	var keys: Array[StringName] = level_overrides.keys()
	keys.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	for id: StringName in keys:
		if not defs.has(id):
			_errors.append("level knob '%s': unknown knob" % id)
			continue
		var coerced: Variant = defs.coerce(id, level_overrides[id])
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
