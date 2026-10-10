class_name BoardSpec extends RefCounted
## A validated board description; BoardState is only ever built from one (ADR-0002 §6).
## Types, hard limits, down axis, mask, spawn anchor (default or explicit), starting contents.
## Usage: var r := BoardSpec.parse(level["board"], limits, types); if r.errors.is_empty(): use(r.spec)

const KEYS_REQUIRED: Array[String] = ["width", "depth", "h_play"]
const KEYS_OPTIONAL: Array[String] = ["down_axis", "mask", "spawn_anchor", "starting_contents"]
const DEFAULT_DOWN_TOKEN := "-y"  # ADR-0002 §1 default

var size: Vector3i  ## (W, h_play + limits.spawn_clearance, D)
var h_play: int
var down: int  ## BoardState.Down
var mask: PackedByteArray  ## W*D footprint, index x + W*z, 1 = active
var spawn_anchor: Vector2i  ## (x, z)
var contents: Array[Dictionary] = []  ## [{cell: Vector3i, kind: int}] (from starting_contents, parse_layers order)


## Validates an untrusted board dictionary; result.spec is null whenever result.errors is not empty.
## Usage: BoardSpec.parse({"width": 6, "depth": 6, "h_play": 10}, BoardLimits.new(), types)
static func parse(data: Dictionary, limits: BoardLimits, types: ContentTypes, field_prefix: String = "board") -> BoardSpecResult:
	var result: BoardSpecResult = BoardSpecResult.new()
	var e: PackedStringArray = result.errors
	_check_keys(data, limits, field_prefix, e)
	if not e.is_empty():
		return result
	var w: int = JsonNum.whole_int(data["width"])
	var d: int = JsonNum.whole_int(data["depth"])
	var hp: int = JsonNum.whole_int(data["h_play"])
	_check_limits(w, d, hp, limits, field_prefix, e)
	if not e.is_empty():
		return result
	var h: int = hp + limits.spawn_clearance
	var down_axis: int = _check_down(data, limits, field_prefix, e)
	var m: PackedByteArray = _check_mask(data, w, d, h, down_axis, limits, field_prefix, e)
	var anchor: Vector2i = Vector2i((w - 1) / 2, (d - 1) / 2)
	if not data.has("spawn_anchor"):
		_check_default_anchor(m, w, anchor, limits, field_prefix, e)
	var found: Array[Dictionary] = []
	if e.is_empty() and data.has("spawn_anchor"):
		anchor = _check_anchor(data["spawn_anchor"], m, w, d, anchor, limits, field_prefix, e)
	if e.is_empty() and data.has("starting_contents"):
		found = _check_contents(data["starting_contents"], m, Vector3i(w, hp, d), limits, types, field_prefix, e)
	if e.is_empty():
		var spec: BoardSpec = BoardSpec.new()
		spec.size = Vector3i(w, h, d)
		spec.h_play = hp
		spec.down = down_axis
		spec.mask = m
		spec.spawn_anchor = anchor
		spec.contents = found
		result.spec = spec
	return result


## Appends msg unless the error cap is reached.
static func _add(errors: PackedStringArray, limits: BoardLimits, msg: String) -> void:
	if errors.size() < limits.max_errors:
		errors.append(msg)


static func _check_keys(data: Dictionary, limits: BoardLimits, p: String, e: PackedStringArray) -> void:
	for key: Variant in data:
		var k: String = str(key)
		if not (k in KEYS_REQUIRED or k in KEYS_OPTIONAL):
			_add(e, limits, "%s.%s: unknown key" % [p, k])
	for k: String in KEYS_REQUIRED:
		if not data.has(k):
			_add(e, limits, "%s.%s: required" % [p, k])
		elif JsonNum.whole_int(data[k]) == null:
			_add(e, limits, "%s.%s: must be a whole number" % [p, k])
	var optional_types: Dictionary = {"down_axis": [TYPE_STRING, "string"], "mask": [TYPE_ARRAY, "array"],
			"spawn_anchor": [TYPE_ARRAY, "array"], "starting_contents": [TYPE_DICTIONARY, "object"]}
	for k: String in optional_types:
		if data.has(k) and typeof(data[k]) != optional_types[k][0]:
			_add(e, limits, "%s.%s: must be a %s" % [p, k, optional_types[k][1]])


static func _check_limits(w: int, d: int, hp: int, limits: BoardLimits, p: String, e: PackedStringArray) -> void:
	var side_ok: bool = true
	for pair: Array in [["width", w], ["depth", d]]:
		var v: int = pair[1]
		if v < limits.min_side or v > limits.max_side:
			side_ok = false
			_add(e, limits, "%s.%s: %d outside %d..%d" % [p, pair[0], v, limits.min_side, limits.max_side])
	var h: int = hp + limits.spawn_clearance
	var height_ok: bool = hp >= 1 and h >= limits.min_height and h <= limits.max_height
	if not height_ok:
		_add(e, limits, "%s.h_play: board height %d outside %d..%d" % [p, h, limits.min_height, limits.max_height])
	if side_ok and height_ok and w * d * h > limits.max_cells:
		_add(e, limits, "%s: %d cells over the limit %d" % [p, w * d * h, limits.max_cells])


static func _check_down(data: Dictionary, limits: BoardLimits, p: String, e: PackedStringArray) -> int:
	var token: String = data.get("down_axis", DEFAULT_DOWN_TOKEN)
	var axis: int = BoardState.down_from_token(token)
	if axis == -1:
		_add(e, limits, "%s.down_axis: '%s' is not one of -x +x -y +y -z +z" % [p, token])
	return axis


static func _check_mask(data: Dictionary, w: int, d: int, h: int, axis: int, limits: BoardLimits, p: String, e: PackedStringArray) -> PackedByteArray:
	var m: PackedByteArray = PackedByteArray()
	if not data.has("mask"):
		m.resize(w * d)
		m.fill(1)
	else:
		var parsed: Dictionary = AsciiGrid.parse_mask(data["mask"], w, d, p + ".mask")
		for msg: String in parsed["errors"]:
			_add(e, limits, msg)
		m = parsed["mask"]
		if m.is_empty():
			return m
	var active: int = m.count(1)
	if active == 0:
		_add(e, limits, "%s.mask: no active cell" % p)
	elif axis != -1:
		_check_layers(m, w, d, h, axis, limits, p, e)
	return m


static func _check_layers(m: PackedByteArray, w: int, d: int, h: int, axis: int, limits: BoardLimits, p: String, e: PackedStringArray) -> void:
	var need: int = limits.min_active_per_layer
	var name: String = BoardState.DOWN_TOKENS[axis][1]
	var count: int = m.count(1)
	if name == "y":
		if count < need:
			_add(e, limits, "%s.mask: layer at y=* has %d active cells, needs >= %d" % [p, count, need])
		return
	var layers: int = w if name == "x" else d
	for k: int in layers:
		var n: int = 0
		for j: int in (d if name == "x" else w):
			n += m[k + w * j] if name == "x" else m[j + w * k]
		n *= h
		if n < need:
			_add(e, limits, "%s.mask: layer at %s=%d has %d active cells, needs >= %d" % [p, name, k, n, need])
			return


static func _check_default_anchor(m: PackedByteArray, w: int, anchor: Vector2i, limits: BoardLimits, p: String, e: PackedStringArray) -> void:
	if m.is_empty() or m.count(1) == 0:
		return
	if m[anchor.x + w * anchor.y] == 0:
		_add(e, limits, "%s.spawn_anchor: default centre (%d,%d) is masked; set spawn_anchor" % [p, anchor.x, anchor.y])


## Validates an explicit spawn_anchor [x, z]; returns it as Vector2i, or fallback after reporting an error.
static func _check_anchor(raw: Variant, m: PackedByteArray, w: int, d: int, fallback: Vector2i, limits: BoardLimits, p: String, e: PackedStringArray) -> Vector2i:
	var a: Array = raw
	var x: Variant = JsonNum.whole_int(a[0]) if a.size() == 2 else null
	var z: Variant = JsonNum.whole_int(a[1]) if a.size() == 2 else null
	if x == null or z == null:
		_add(e, limits, "%s.spawn_anchor: must be [x, z] whole numbers" % p)
	elif x < 0 or x >= w or z < 0 or z >= d:
		_add(e, limits, "%s.spawn_anchor: (%d,%d) out of bounds (W=%d, D=%d)" % [p, x, z, w, d])
	elif m[x + w * z] == 0:
		_add(e, limits, "%s.spawn_anchor: (%d,%d) is masked" % [p, x, z])
	else:
		return Vector2i(x, z)
	return fallback


## Parses starting_contents through the glyph legend; returns [{cell, kind}] and reports masked footprint cells.
static func _check_contents(section: Dictionary, m: PackedByteArray, size: Vector3i, limits: BoardLimits, types: ContentTypes, p: String, e: PackedStringArray) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var parsed: Dictionary = AsciiGrid.parse_layers(section, size, types.glyphs(), p + ".starting_contents")
	for msg: String in parsed["errors"]:
		_add(e, limits, msg)
	for entry: Dictionary in parsed["cells"]:
		var cell: Vector3i = entry["cell"]
		if m[cell.x + size.x * cell.z] == 0:
			_add(e, limits, "%s.starting_contents: cell (%d,%d,%d) is masked" % [p, cell.x, cell.y, cell.z])
		out.append({"cell": cell, "kind": types.kind_of_glyph(entry["glyph"])})
	return out
