class_name ContentTypes extends RefCounted
## Content-type table: what each board kind id means (ADR-0002 §3). Built from assets/data/content/*.json.
## Usage: var t := ContentTypes.from_entries(entries); t.kind_of_glyph("#")

const SLOT_CELL: int = 0 # ADR-0002 §3
const SLOT_OVERLAY: int = 1 # ADR-0002 §3
const KIND_EMPTY: int = 0 # ADR-0002 §2: kind 0 = empty
const KIND_MAX: int = 255 # ADR-0002 §2: kind is a PackedByteArray entry
const EMPTY_GLYPH: String = "." # implementation-plan §5: '.' is always empty

## Filled by from_entries; empty when the table is valid.
var errors: PackedStringArray = PackedStringArray()

var _by_kind: Dictionary = {} # int -> Dictionary {id, glyph, slot, solid, fills_layer, hue}
var _by_id: Dictionary = {} # StringName -> int
var _by_glyph: Dictionary = {} # String -> int


## Builds the table from entry Dictionaries; problems go to .errors, bad entries are skipped.
## Usage: ContentTypes.from_entries(json["types"])
static func from_entries(entries: Array) -> ContentTypes:
	var t := ContentTypes.new()
	for i: int in entries.size():
		t._add(i, entries[i])
	return t


## Kind for an ASCII glyph; -1 if unknown.
func kind_of_glyph(glyph: String) -> int:
	return _by_glyph.get(glyph, -1)


## Id of a kind; &"" if unknown.
func id_of(kind: int) -> StringName:
	return _field(kind, "id", &"")


## Kind for an id; -1 if unknown.
func kind_of(id: StringName) -> int:
	return _by_id.get(id, -1)


## True if the kind blocks movement; false if unknown.
func is_solid(kind: int) -> bool:
	return _field(kind, "solid", false)


## True if the kind fills its layer; false if unknown.
func fills_layer(kind: int) -> bool:
	return _field(kind, "fills_layer", false)


## SLOT_CELL / SLOT_OVERLAY; -1 if unknown.
func slot(kind: int) -> int:
	return _field(kind, "slot", -1)


## Default hue for non-piece content; 0 if unknown.
func hue(kind: int) -> int:
	return _field(kind, "hue", 0)


## All glyphs concatenated in kind order (the "legal" set for AsciiGrid).
func glyphs() -> String:
	var kinds: Array = _by_kind.keys()
	kinds.sort()
	var s: String = ""
	for k: int in kinds:
		s += _by_kind[k]["glyph"]
	return s


func _field(kind: int, key: String, fallback: Variant) -> Variant:
	return _by_kind[kind][key] if _by_kind.has(kind) else fallback


func _is_whole(v: Variant) -> bool:
	return (v is int) or ((v is float) and v == roundf(v))


func _add(i: int, e: Variant) -> void:
	var p: String = "content[%d]" % i
	if not (e is Dictionary):
		errors.append("%s: not a Dictionary" % p)
		return
	var d: Dictionary = e
	var types: Dictionary = {"id": TYPE_STRING, "glyph": TYPE_STRING, "slot": TYPE_STRING,
			"solid": TYPE_BOOL, "fills_layer": TYPE_BOOL, "mesh": TYPE_STRING}
	for f: String in types:
		if not d.has(f) or typeof(d[f]) != types[f]:
			errors.append("%s.%s: missing or wrong type" % [p, f])
			return
	for f: String in ["kind_id", "hue"]:
		if not d.has(f) or not _is_whole(d[f]):
			errors.append("%s.%s: missing or not a whole number" % [p, f])
			return
	var kind: int = int(d["kind_id"])
	var id: String = d["id"]
	var glyph: String = d["glyph"]
	var slot_s: String = d["slot"]
	if kind < 1 or kind > KIND_MAX:
		errors.append("%s.kind_id: %d out of range 1..%d" % [p, kind, KIND_MAX])
	elif _by_kind.has(kind):
		errors.append("%s.kind_id: duplicate %d" % [p, kind])
	elif _by_id.has(StringName(id)):
		errors.append("%s.id: duplicate %s" % [p, id])
	elif glyph.length() > 1 or glyph == EMPTY_GLYPH:
		errors.append("%s.glyph: must be one char other than dot, or empty" % p)
	elif glyph != "" and _by_glyph.has(glyph):
		errors.append("%s.glyph: duplicate %s" % [p, glyph])
	elif slot_s != "cell" and slot_s != "overlay":
		errors.append("%s.slot: must be cell or overlay" % p)
	elif slot_s == "overlay" and d["solid"]:
		errors.append("%s.solid: overlay cannot be solid" % p)
	elif slot_s == "overlay" and d["fills_layer"]:
		errors.append("%s.fills_layer: overlay cannot fill a layer" % p)
	else:
		_by_kind[kind] = {"id": StringName(id), "glyph": glyph,
				"slot": SLOT_OVERLAY if slot_s == "overlay" else SLOT_CELL,
				"solid": d["solid"], "fills_layer": d["fills_layer"], "hue": int(d["hue"])}
		_by_id[StringName(id)] = kind
		if glyph != "":
			_by_glyph[glyph] = kind
