class_name BoardSpec extends RefCounted
## A validated board description; BoardState is only ever built from one (ADR-0002 §6).

const KEYS_REQUIRED: Array[String] = ["width", "depth", "h_play"]
const KEYS_OPTIONAL: Array[String] = ["down_axis", "mask", "spawn_anchor", "starting_contents"]
const DEFAULT_DOWN_TOKEN: String = "-y"          # ADR-0002 §1 default
const MAX_SAFE_INT: int = 2147483647             # whole-number guard before int()
const _OPTIONAL_TYPES: Dictionary = {
	"down_axis": [TYPE_STRING, "string"],
	"mask": [TYPE_ARRAY, "array"],
	"spawn_anchor": [TYPE_ARRAY, "array"],
	"starting_contents": [TYPE_DICTIONARY, "object"],
}

var size: Vector3i = Vector3i.ZERO   ## (W, h_play + limits.spawn_clearance, D)
var h_play: int = 0
var down: int = BoardState.Down.Y_NEG
var mask: PackedByteArray = PackedByteArray()   ## W*D footprint, index x + W*z, 1 = active
var spawn_anchor: Vector2i = Vector2i.ZERO      ## (x, z)
var contents: Array[Dictionary] = []            ## [{cell: Vector3i, kind: int}] (filled in CH-008)


## Validates an untrusted board dictionary; spec is set only if errors is empty.
## Usage: var r: BoardSpecResult = BoardSpec.parse(d, limits, types, "board")
@warning_ignore("unused_parameter")
static func parse(data: Dictionary, limits: BoardLimits, types: ContentTypes, field_prefix: String = "board") -> BoardSpecResult:
	var result: BoardSpecResult = BoardSpecResult.new()
	var errors: PackedStringArray = result.errors
	var dims: Dictionary = _check_keys(data, limits, field_prefix, errors)
	if not errors.is_empty():
		return result
	var w: int = dims["width"]
	var d: int = dims["depth"]
	var hp: int = dims["h_play"]
	_check_limits(w, d, hp, limits, field_prefix, errors)
	if not errors.is_empty():
		return result
	var spec: BoardSpec = BoardSpec.new()
	spec.size = Vector3i(w, hp + limits.spawn_clearance, d)
	spec.h_play = hp
	spec.down = _check_down(data, limits, field_prefix, errors)
	spec.mask = _check_mask(data, spec, limits, field_prefix, errors)
	if not data.has("spawn_anchor"):
		spec.spawn_anchor = _default_anchor(spec, limits, field_prefix, errors)
	if errors.is_empty():
		result.spec = spec
	return result


## int, or null if v is not a whole number (bool -> null).
static func _whole_int(v: Variant) -> Variant:
	if typeof(v) == TYPE_INT:
		return v
	if typeof(v) == TYPE_FLOAT:
		var f: float = v
		if is_finite(f) and f == floorf(f) and absf(f) <= MAX_SAFE_INT:
			return int(f)
	return null


## No-op once errors.size() >= limits.max_errors.
static func _add(errors: PackedStringArray, limits: BoardLimits, msg: String) -> void:
	if errors.size() < limits.max_errors:
		errors.append(msg)


static func _check_keys(data: Dictionary, limits: BoardLimits, p: String, errors: PackedStringArray) -> Dictionary:
	var dims: Dictionary = {}
	for k: Variant in data.keys():
		var key: String = str(k)
		if not (key in KEYS_REQUIRED or key in KEYS_OPTIONAL):
			_add(errors, limits, "%s.%s: unknown key" % [p, key])
	for key: String in KEYS_REQUIRED:
		if not data.has(key):
			_add(errors, limits, "%s.%s: required" % [p, key])
			continue
		var n: Variant = _whole_int(data[key])
		if n == null:
			_add(errors, limits, "%s.%s: must be a whole number" % [p, key])
		else:
			dims[key] = n
	for key: String in KEYS_OPTIONAL:
		if data.has(key) and typeof(data[key]) != _OPTIONAL_TYPES[key][0]:
			_add(errors, limits, "%s.%s: must be a %s" % [p, key, _OPTIONAL_TYPES[key][1]])
	return dims


static func _check_limits(w: int, d: int, hp: int, limits: BoardLimits, p: String, errors: PackedStringArray) -> void:
	var before: int = errors.size()
	for pair: Array in [["width", w], ["depth", d]]:
		var v: int = pair[1]
		if v < limits.min_side or v > limits.max_side:
			_add(errors, limits, "%s.%s: %d outside %d..%d" % [p, pair[0], v, limits.min_side, limits.max_side])
	var h: int = hp + limits.spawn_clearance
	if hp < 1 or h < limits.min_height or h > limits.max_height:
		_add(errors, limits, "%s.h_play: board height %d outside %d..%d" % [p, h, limits.min_height, limits.max_height])
	if errors.size() == before and w * d * h > limits.max_cells:
		_add(errors, limits, "%s: %d cells over the limit %d" % [p, w * d * h, limits.max_cells])


static func _check_down(data: Dictionary, limits: BoardLimits, p: String, errors: PackedStringArray) -> int:
	var tok: String = data.get("down_axis", DEFAULT_DOWN_TOKEN)
	var down_axis: int = BoardState.down_from_token(tok)
	if down_axis == -1:
		_add(errors, limits, "%s.down_axis: '%s' is not one of -x +x -y +y -z +z" % [p, tok])
		return BoardState.Down.Y_NEG
	return down_axis


static func _check_mask(data: Dictionary, spec: BoardSpec, limits: BoardLimits, p: String, errors: PackedStringArray) -> PackedByteArray:
	var w: int = spec.size.x
	var d: int = spec.size.z
	var grid: PackedByteArray = PackedByteArray()
	if data.has("mask"):
		var parsed: Dictionary = AsciiGrid.parse_mask(data["mask"], w, d, p + ".mask")
		for e: String in parsed["errors"]:
			_add(errors, limits, e)
		grid = parsed["mask"]
		if grid.is_empty():
			return grid
	else:
		grid.resize(w * d)
		grid.fill(1)
	var active: int = 0
	for b: int in grid:
		active += b
	if active == 0:
		_add(errors, limits, "%s.mask: no active cell" % p)
		return grid
	var bad: String = _first_thin_layer(grid, spec, limits.min_active_per_layer)
	if bad != "":
		_add(errors, limits, "%s.mask: %s" % [p, bad])
	return grid


## Message for the first layer on the down axis with too few active cells, or "".
static func _first_thin_layer(grid: PackedByteArray, spec: BoardSpec, min_active: int) -> String:
	var w: int = spec.size.x
	var h: int = spec.size.y
	var d: int = spec.size.z
	var axis: String = "y"
	var counts: PackedInt32Array = PackedInt32Array()
	if spec.down == BoardState.Down.X_NEG or spec.down == BoardState.Down.X_POS:
		axis = "x"
		counts.resize(w)
	elif spec.down == BoardState.Down.Z_NEG or spec.down == BoardState.Down.Z_POS:
		axis = "z"
		counts.resize(d)
	else:
		counts.resize(1)
	for z: int in d:
		for x: int in w:
			if grid[x + w * z] == 0:
				continue
			var idx: int = x if axis == "x" else (z if axis == "z" else 0)
			counts[idx] += 1 if axis == "y" else h
	for k: int in counts.size():
		if counts[k] < min_active:
			return "layer at %s=%s has %d active cells, needs >= %d" % [axis, "*" if axis == "y" else str(k), counts[k], min_active]
	return ""


static func _default_anchor(spec: BoardSpec, limits: BoardLimits, p: String, errors: PackedStringArray) -> Vector2i:
	var w: int = spec.size.x
	var a: Vector2i = Vector2i((w - 1) >> 1, (spec.size.z - 1) >> 1)  # floor halves, lower cell on ties
	if not spec.mask.is_empty() and spec.mask[a.x + w * a.y] == 0:
		_add(errors, limits, "%s.spawn_anchor: default centre (%d,%d) is masked; set spawn_anchor" % [p, a.x, a.y])
	return a
