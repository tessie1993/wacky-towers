class_name KnobDefs extends RefCounted
## Knob definitions from assets/data/knobs/*.json (ADR-0004 §3). Scalars are stored as integer milli-units.
## Usage: var defs := KnobDefs.from_tables(tables); if defs.has(&"fall.g0"): defs.def(&"fall.g0")

const FIXED_POINT_SCALE := 1000 # ADR-0004 §3: 1000 = 1.0
const T_SCALAR := &"scalar"
const T_COUNT := &"count"
const T_FLAG := &"flag"
const T_CHOICE := &"choice"
const T_STRUCTURE := &"structure"
const T_SLOT := &"slot"
const ENTRY_KEYS: Array[String] = ["id", "type", "default", "min", "max", "allows_zero", "rule_adjustable", "choices", "source", "note"]
const _TYPES: Array[StringName] = [T_SCALAR, T_COUNT, T_FLAG, T_CHOICE, T_STRUCTURE, T_SLOT]
const _MAX_WHOLE := 9007199254740992.0 # 2^53: largest range where floats are exact integers

var _errors: PackedStringArray = PackedStringArray()
var _defs: Dictionary = {} # StringName -> Dictionary
var _last_error: String = ""


## Builds definitions from parsed tables ({"knobs": [entry, ...]}); problems go to errors().
static func from_tables(tables: Array) -> KnobDefs:
	var out: KnobDefs = KnobDefs.new()
	var seen: Dictionary = {}
	for t: int in tables.size():
		var table: Variant = tables[t]
		if not (table is Dictionary) or not ((table as Dictionary).get("knobs") is Array):
			out._errors.append("knobs[%d]: table must be an object with a 'knobs' array" % t)
			continue
		var entries: Array = (table as Dictionary)["knobs"]
		for i: int in entries.size():
			out._add_entry(entries[i], "knobs[%d][%d]" % [t, i], seen)
	return out


## Problems found while building, one string per bad entry.
func errors() -> PackedStringArray:
	return _errors


## All loaded knob ids, sorted.
func ids() -> Array[StringName]:
	var out: Array[StringName] = []
	for k: StringName in _defs.keys():
		out.append(k)
	out.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return out


## True if the knob id was loaded.
func has(id: StringName) -> bool:
	return _defs.has(id)


## Definition {type, default, min, max, allows_zero, rule_adjustable, choices} (copy); {} if unknown.
func def(id: StringName) -> Dictionary:
	if not _defs.has(id):
		return {}
	return (_defs[id] as Dictionary).duplicate(true)


## Converts a raw JSON value into the knob's typed value, or null with last_error() set (ADR-0004 §3).
## Usage: var v: Variant = defs.coerce(&"fall.g0", 0.6) # -> 600
func coerce(id: StringName, raw: Variant) -> Variant:
	if not _defs.has(id):
		return _reject("unknown knob '%s'" % id)
	var d: Dictionary = _defs[id]
	var label: String = "knob '%s'" % id
	var type: StringName = d["type"]
	match type:
		T_SCALAR:
			if not _is_number(raw):
				return _reject("%s: must be a number" % label)
			return _check_range(label, d, roundi((raw as float) * FIXED_POINT_SCALE), raw, true)
		T_COUNT:
			var w: Variant = _whole_int(raw)
			if w == null:
				return _reject("%s: must be a whole number" % label)
			return _check_range(label, d, w as int, raw, false)
		T_FLAG:
			if typeof(raw) != TYPE_BOOL:
				return _reject("%s: must be true or false" % label)
		T_CHOICE, T_SLOT:
			if raw is String and (d["choices"] as Array).has(StringName(raw as String)):
				_last_error = ""
				return StringName(raw as String)
			return _reject("%s: '%s' is not one of %s" % [label, str(raw), str(d["choices"])])
		T_STRUCTURE:
			if typeof(raw) != typeof(d["default"]):
				return _reject("%s: must be an %s" % [label, "object" if d["default"] is Dictionary else "array"])
			_last_error = ""
			return (raw as Variant).duplicate(true)
	_last_error = ""
	return raw


## Message from the last coerce() call; "" after a successful one.
func last_error() -> String:
	return _last_error


func _reject(message: String) -> Variant:
	_last_error = message
	return null


func _check_range(label: String, d: Dictionary, value: int, raw: Variant, scalar: bool) -> Variant:
	var lo: int = d["min"]
	var hi: int = d["max"]
	if value < lo or value > hi:
		var lo_s: String = str(lo / float(FIXED_POINT_SCALE)) if scalar else str(lo)
		var hi_s: String = str(hi / float(FIXED_POINT_SCALE)) if scalar else str(hi)
		return _reject("%s: %s outside %s..%s" % [label, str(raw), lo_s, hi_s])
	if value == 0 and d["allows_zero"] == false:
		return _reject("%s: zero not allowed" % label)
	_last_error = ""
	return value


# ponytail: third copy of the 5-line whole-number rule (BoardSpec, JsonReader, here); extract one core helper if a fourth appears.
static func _whole_int(v: Variant) -> Variant:
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_FLOAT:
		var f: float = v
		if is_finite(f) and f == floorf(f) and absf(f) <= _MAX_WHOLE:
			return int(f)
	return null


static func _is_number(v: Variant) -> bool:
	return (typeof(v) == TYPE_INT) or (typeof(v) == TYPE_FLOAT and is_finite(v as float))


func _fail(label: String, problem: String) -> void:
	_errors.append("%s: %s" % [label, problem])


func _add_entry(entry: Variant, where: String, seen: Dictionary) -> void:
	if not (entry is Dictionary):
		_fail(where, "entry must be an object")
		return
	var e: Dictionary = entry
	var raw_id: Variant = e.get("id")
	if not (raw_id is String) or not (raw_id as String).contains("."):
		_fail(where, "id must be a string containing '.'")
		return
	var id: String = raw_id
	var label: String = "knob '%s'" % id
	if seen.has(id):
		_fail(label, "duplicate id")
		return
	seen[id] = true
	for key: Variant in e.keys():
		if not (key is String) or not ENTRY_KEYS.has(key):
			_fail(label, "unknown key '%s'" % str(key))
			return
	var type_v: Variant = e.get("type")
	if not (type_v is String) or not _TYPES.has(StringName(type_v as String)):
		_fail(label, "type must be one of scalar, count, flag, choice, structure, slot")
		return
	var type: StringName = StringName(type_v as String)
	var allows_zero: Variant = e.get("allows_zero", true)
	var adjustable: Variant = e.get("rule_adjustable", false)
	if typeof(allows_zero) != TYPE_BOOL or typeof(adjustable) != TYPE_BOOL:
		_fail(label, "allows_zero and rule_adjustable must be booleans")
		return
	var d: Dictionary = {"type": type, "default": null, "min": null, "max": null,
		"allows_zero": allows_zero, "rule_adjustable": adjustable, "choices": []}
	var problem: String = ""
	match type:
		T_SCALAR, T_COUNT:
			problem = _fill_numeric(d, e, type)
		T_FLAG:
			if typeof(e.get("default")) != TYPE_BOOL:
				problem = "flag default must be a boolean"
			elif e.has("min") or e.has("max") or e.has("choices"):
				problem = "flag takes no min/max/choices"
			else:
				d["default"] = e["default"]
		T_CHOICE, T_SLOT:
			problem = _fill_choice(d, e)
		T_STRUCTURE:
			var def_v: Variant = e.get("default")
			if def_v is Dictionary or def_v is Array:
				d["default"] = (def_v as Variant).duplicate(true)
			else:
				problem = "structure default must be an object or array"
	if problem != "":
		_fail(label, problem)
		return
	_defs[StringName(id)] = d


func _fill_numeric(d: Dictionary, e: Dictionary, type: StringName) -> String:
	if e.has("choices"):
		return "%s takes no choices" % String(type)
	var vals: Array[int] = []
	for key: String in ["default", "min", "max"]:
		var v: Variant = e.get(key)
		if not _is_number(v):
			return "%s must be a finite number" % key
		if type == T_COUNT:
			var w: Variant = _whole_int(v)
			if w == null:
				return "%s must be a whole number" % key
			vals.append(w as int)
		else:
			vals.append(roundi((v as float) * FIXED_POINT_SCALE))
	if vals[1] > vals[2]:
		return "min must be <= max"
	if vals[0] < vals[1] or vals[0] > vals[2]:
		return "default must be within min..max"
	if d["allows_zero"] == false and vals[0] == 0:
		return "default is 0 but allows_zero is false"
	d["default"] = vals[0]
	d["min"] = vals[1]
	d["max"] = vals[2]
	return ""


func _fill_choice(d: Dictionary, e: Dictionary) -> String:
	if e.has("min") or e.has("max"):
		return "choice/slot takes no min/max"
	var raw: Variant = e.get("choices")
	if not (raw is Array) or (raw as Array).is_empty():
		return "choices must be a non-empty array"
	var choices: Array[StringName] = []
	for c: Variant in raw as Array:
		if not (c is String):
			return "choices must be strings"
		var sn: StringName = StringName(c as String)
		if choices.has(sn):
			return "choices must be unique"
		choices.append(sn)
	var def_v: Variant = e.get("default")
	if not (def_v is String) or not choices.has(StringName(def_v as String)):
		return "default must be one of choices"
	d["choices"] = choices
	d["default"] = StringName(def_v as String)
	return ""
