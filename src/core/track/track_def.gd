class_name TrackDef extends RefCounted
## Immutable, data-driven description of one moving-platform track (gap G8, docs/architecture/moving-platform.md).
## Pure data: segments, scheduled events, checkpoints, lean and cargo rules, effect tuning, the time limit and a
## view path. Distances are integer millimetres, speeds mm per second, rates per second, so the sim stays exact.
## Every required value must be present: a missing parameter is a validation error, never a silent default.
## Usage: var def: TrackDef = TrackDef.load_file("res://assets/data/tracks/meadow_brook_run.json").

const KIND_BUMP := &"bump"
const KIND_ARCH := &"arch"
const KIND_UPDRAFT := &"updraft"
const KIND_CROSSWIND := &"crosswind"
const KIND_CLOUD_BUMP := &"cloud_bump"
const KIND_GUST := &"gust"
const KINDS: Array[StringName] = [KIND_BUMP, KIND_ARCH, KIND_UPDRAFT, KIND_CROSSWIND, KIND_CLOUD_BUMP, KIND_GUST]
## Direction tokens for events: x is across the platform, z is along the cart's sides.
const DIRS: Dictionary = {"+x": Vector2i(1, 0), "-x": Vector2i(-1, 0), "+z": Vector2i(0, 1), "-z": Vector2i(0, -1)}
## Required per-event parameters and the effect keys each kind needs in `effects`.
const EVENT_PARAMS: Dictionary = {
	&"bump": ["force"], &"cloud_bump": ["force", "dir"], &"arch": ["gap_layers"],
	&"crosswind": ["dir", "strength"], &"gust": ["dir", "strength"], &"updraft": ["duration_ms"]}
const EFFECT_KEYS: Dictionary = {
	&"bump": ["impulse_pm_per_force", "cargo_stress_pm_per_force"],
	&"cloud_bump": ["impulse_pm_per_force", "cargo_stress_pm_per_force"],
	&"arch": [],
	&"crosswind": ["impulse_pm_per_layer_strength", "cargo_stress_pm_per_strength"],
	&"gust": ["impulse_pm_per_100_layer_cells", "cargo_stress_pm_per_strength"],
	&"updraft": ["lift_pct", "height_pct_per_layer", "mass_pct_per_cell"]}
const LEAN_KEYS: Array[String] = ["danger_pm", "limit_pm", "relax_pm_per_s", "spill_cells", "spill_relief_pm", "hysteresis_pm"]
const CARGO_KEYS: Array[String] = ["height_layers", "min_support_cells", "level_tolerance_layers", "wobble_pm", "slip_pm",
	"rise_pm_per_s", "recover_pm_per_s", "lean_stress_pm_per_s", "drop_stress_pm_per_layer", "top_out_stress_pm_per_s"]

var id: StringName = &""
## Fixed sim tick of the platform in milliseconds.
var tick_ms: int = 50
## Win condition: reach the end within this much play time (ms).
var time_limit_ms: int = 0
## Time added to the clock when the platform returns to a post (ms).
var restart_penalty_ms: int = 0
## How far ahead the preview strip looks (mm), and the least warning time it must give at any event (ms).
var preview_window_mm: int = 0
var preview_min_lead_ms: int = 0
## What a lost cargo does: &"checkpoint" or &"fail".
var on_loss: StringName = &"checkpoint"
## Segments: {id, length_mm, speed_mm_s, fall_pct, start_mm}. fall_pct is the piece fall speed in percent.
var segments: Array[Dictionary] = []
## Events sorted by at_mm (ties keep file order): {kind, at_mm, ...params}.
var events: Array[Dictionary] = []
## Checkpoints sorted by at_mm: {id, at_mm}.
var checkpoints: Array[Dictionary] = []
var cargo: Dictionary = {}
var lean: Dictionary = {}
var effects: Dictionary = {}
var path: PackedVector3Array = PackedVector3Array()
var errors: PackedStringArray = PackedStringArray()

var _length_mm: int = 0
var _path_lengths: PackedFloat32Array = PackedFloat32Array()


## Loads a track JSON file. Check is_valid() on the result.
static func load_file(file_path: String) -> TrackDef:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	if not parsed is Dictionary:
		var bad := TrackDef.new()
		bad.errors.append("%s: not a JSON object" % file_path)
		return bad
	return from_dict(parsed as Dictionary)


## Builds a track from parsed JSON. Check is_valid() on the result.
static func from_dict(d: Dictionary) -> TrackDef:
	var def := TrackDef.new()
	def.id = StringName(String(d.get("id", "")))
	def.tick_ms = int(d.get("tick_ms", 50))
	def.time_limit_ms = int(d.get("time_limit_ms", 0))
	def.restart_penalty_ms = int(d.get("restart_penalty_ms", 0))
	def.preview_window_mm = int(d.get("preview_window_mm", 0))
	def.preview_min_lead_ms = int(d.get("preview_min_lead_ms", 0))
	def.on_loss = StringName(String(d.get("on_loss", "checkpoint")))
	def.effects = (d.get("effects", {}) as Dictionary).duplicate(true)
	def.cargo = (d.get("cargo", {}) as Dictionary).duplicate(true)
	def.lean = (d.get("lean", {}) as Dictionary).duplicate(true)
	def._parse_segments(d.get("segments", []) as Array)
	def._parse_marks(d)
	def._parse_path(d.get("path", []) as Array)
	def._validate()
	return def


## True when parsing found no problems.
func is_valid() -> bool:
	return errors.is_empty()


## Total track length in mm.
func length_mm() -> int:
	return _length_mm


## Time to drive the whole track at base speed (no updraft), in ms.
func base_duration_ms() -> int:
	return time_between_ms(0, _length_mm)


## Base-speed travel time between two track distances, integrating segment speeds (ms, rounded down).
func time_between_ms(from_mm: int, to_mm: int) -> int:
	var total_us: int = 0
	for seg: Dictionary in segments:
		var a: int = maxi(from_mm, int(seg["start_mm"]))
		var b: int = mini(to_mm, int(seg["start_mm"]) + int(seg["length_mm"]))
		if b > a:
			total_us += (b - a) * 1000000 / int(seg["speed_mm_s"])
	return total_us / 1000


## The segment covering mm (the last one past the end); {} when there are none.
func segment_at(mm: int) -> Dictionary:
	var found: Dictionary = {}
	for seg: Dictionary in segments:
		if mm < int(seg["start_mm"]) + int(seg["length_mm"]):
			return seg
		found = seg
	return found


## Base platform speed at mm, in mm per second.
func speed_at_mm(mm: int) -> int:
	return int(segment_at(mm).get("speed_mm_s", 0))


## Piece fall speed percent for the segment at mm.
func fall_pct_at(mm: int) -> int:
	return int(segment_at(mm).get("fall_pct", 100))


## Preview strip feed for [from_mm, from_mm + window): events and posts with ahead_mm, ahead_ms, severity and what
## the player can do about it (safe_height_layers for arches, impulse_pm for bumps, lift_pct for updrafts).
## window < 0 uses preview_window_mm. Usage: strip.show(def.preview(runner.position_mm())).
func preview(from_mm: int, window_mm: int = -1) -> Array[Dictionary]:
	var span: int = preview_window_mm if window_mm < 0 else window_mm
	var out: Array[Dictionary] = []
	for e: Dictionary in events:
		var at: int = int(e["at_mm"])
		if at >= from_mm and at < from_mm + span:
			out.append(_preview_row(e, from_mm))
	for cp: Dictionary in checkpoints:
		var at: int = int(cp["at_mm"])
		if at >= from_mm and at < from_mm + span:
			out.append({"kind": &"checkpoint", "id": cp.get("id", ""), "at_mm": at, "ahead_mm": at - from_mm,
				"ahead_ms": time_between_ms(from_mm, at), "severity": 0})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["at_mm"]) < int(b["at_mm"]))
	return out


## The last checkpoint at or before mm; {} before the first (the start is the implicit post).
func checkpoint_before(mm: int) -> Dictionary:
	var found: Dictionary = {}
	for cp: Dictionary in checkpoints:
		if int(cp["at_mm"]) <= mm:
			found = cp
	return found


## View position along the path for track distance mm (clamped).
func path_point(mm: int) -> Vector3:
	if path.is_empty():
		return Vector3.ZERO
	if path.size() == 1 or _length_mm <= 0:
		return path[0]
	var total: float = _path_lengths[_path_lengths.size() - 1]
	var want: float = total * clampf(float(mm) / float(_length_mm), 0.0, 1.0)
	for i: int in range(1, path.size()):
		if want <= _path_lengths[i]:
			var span: float = _path_lengths[i] - _path_lengths[i - 1]
			var t: float = 0.0 if span <= 0.0 else (want - _path_lengths[i - 1]) / span
			return path[i - 1].lerp(path[i], t)
	return path[path.size() - 1]


## Unit heading of the path at mm; Vector3.FORWARD when degenerate.
func path_heading(mm: int) -> Vector3:
	var a: Vector3 = path_point(mm)
	var b: Vector3 = path_point(mm + maxi(1, _length_mm / 100))
	return (b - a).normalized() if b.distance_squared_to(a) > 0.0 else Vector3.FORWARD


func _preview_row(e: Dictionary, from_mm: int) -> Dictionary:
	var row: Dictionary = e.duplicate()
	var at: int = int(e["at_mm"])
	row["ahead_mm"] = at - from_mm
	row["ahead_ms"] = time_between_ms(from_mm, at)
	var cfg: Dictionary = effects.get(String(e["kind"]), {}) as Dictionary
	match e["kind"]:
		KIND_ARCH:
			row["severity"] = 3
			row["safe_height_layers"] = int(e["gap_layers"]) - int(cargo.get("height_layers", 1))
		KIND_BUMP, KIND_CLOUD_BUMP:
			row["severity"] = int(e["force"])
			row["impulse_pm"] = int(cfg.get("impulse_pm_per_force", 0)) * int(e["force"])
		KIND_CROSSWIND:
			row["severity"] = int(e["strength"])
			row["impulse_pm_per_layer"] = int(cfg.get("impulse_pm_per_layer_strength", 0)) * int(e["strength"])
		KIND_GUST:
			row["severity"] = int(e["strength"])
			row["impulse_pm_per_100_layer_cells"] = int(cfg.get("impulse_pm_per_100_layer_cells", 0)) * int(e["strength"])
		KIND_UPDRAFT:
			row["severity"] = 1
			row["lift_pct"] = int(cfg.get("lift_pct", 0))
	return row


func _parse_segments(rows: Array) -> void:
	var at: int = 0
	for row: Variant in rows:
		var seg: Dictionary = (row as Dictionary).duplicate()
		seg["length_mm"] = int(seg.get("length_mm", 0))
		seg["speed_mm_s"] = int(seg.get("speed_mm_s", 0))
		seg["fall_pct"] = int(seg.get("fall_pct", 0))
		seg["start_mm"] = at
		at += int(seg["length_mm"])
		segments.append(seg)
	_length_mm = at


func _parse_marks(d: Dictionary) -> void:
	var seq: int = 0
	for row: Variant in d.get("events", []) as Array:
		var e: Dictionary = (row as Dictionary).duplicate()
		e["kind"] = StringName(String(e.get("kind", "")))
		e["at_mm"] = int(e.get("at_mm", -1))
		e["_seq"] = seq
		seq += 1
		events.append(e)
	for row: Variant in d.get("checkpoints", []) as Array:
		var cp: Dictionary = (row as Dictionary).duplicate()
		cp["at_mm"] = int(cp.get("at_mm", -1))
		cp["_seq"] = seq
		seq += 1
		checkpoints.append(cp)
	var by_pos: Callable = func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["at_mm"]) < int(b["at_mm"]) or (int(a["at_mm"]) == int(b["at_mm"]) and int(a["_seq"]) < int(b["_seq"]))
	events.sort_custom(by_pos)
	checkpoints.sort_custom(by_pos)


func _parse_path(rows: Array) -> void:
	var acc: float = 0.0
	for row: Variant in rows:
		var p: Array = row as Array
		path.append(Vector3(float(p[0]), float(p[1]), float(p[2])))
		if path.size() > 1:
			acc += path[path.size() - 1].distance_to(path[path.size() - 2])
		_path_lengths.append(acc)


func _validate() -> void:
	if id == &"":
		errors.append("track has no id")
	if tick_ms <= 0:
		errors.append("tick_ms must be positive")
	if segments.is_empty() or _length_mm <= 0:
		errors.append("track needs at least one segment with length")
	if on_loss != &"checkpoint" and on_loss != &"fail":
		errors.append("on_loss must be 'checkpoint' or 'fail'")
	for seg: Dictionary in segments:
		if int(seg["speed_mm_s"]) <= 0 or int(seg["length_mm"]) <= 0 or int(seg["fall_pct"]) <= 0:
			errors.append("segment '%s' needs positive length_mm, speed_mm_s and fall_pct" % seg.get("id", "?"))
	_validate_clock()
	_require_keys(lean, LEAN_KEYS, "lean")
	_require_keys(cargo, CARGO_KEYS, "cargo")
	_validate_ranges()
	for e: Dictionary in events:
		_validate_event(e)
	for cp: Dictionary in checkpoints:
		if int(cp["at_mm"]) <= 0 or int(cp["at_mm"]) >= _length_mm:
			errors.append("checkpoint '%s' must lie inside the track" % cp.get("id", "?"))


func _validate_clock() -> void:
	if time_limit_ms <= 0:
		errors.append("time_limit_ms is required")
	elif _length_mm > 0 and not segments.is_empty() and time_limit_ms < base_duration_ms():
		errors.append("time_limit_ms %d is shorter than the base drive time %d" % [time_limit_ms, base_duration_ms()])
	if preview_window_mm <= 0 or preview_min_lead_ms <= 0:
		errors.append("preview_window_mm and preview_min_lead_ms are required")
	for e: Dictionary in events:
		var speed: int = speed_at_mm(int(e["at_mm"]))
		if speed > 0 and preview_window_mm * 1000 / speed < preview_min_lead_ms:
			errors.append("event '%s' at %d is previewed less than %d ms ahead" % [e["kind"], int(e["at_mm"]), preview_min_lead_ms])
			break


func _validate_ranges() -> void:
	if lean.size() < LEAN_KEYS.size() or cargo.size() < CARGO_KEYS.size():
		return
	if not (0 < int(lean["danger_pm"]) and int(lean["danger_pm"]) < int(lean["limit_pm"]) and int(lean["limit_pm"]) <= 1000):
		errors.append("lean needs 0 < danger_pm < limit_pm <= 1000")
	if int(lean["spill_cells"]) < 1:
		errors.append("lean.spill_cells must be at least 1")
	if not (0 < int(cargo["wobble_pm"]) and int(cargo["wobble_pm"]) < int(cargo["slip_pm"]) and int(cargo["slip_pm"]) < 1000):
		errors.append("cargo needs 0 < wobble_pm < slip_pm < 1000")
	if int(cargo["min_support_cells"]) < 1 or int(cargo["min_support_cells"]) > 9 or int(cargo["height_layers"]) < 1:
		errors.append("cargo needs 1 <= min_support_cells <= 9 and height_layers >= 1")


func _require_keys(dict: Dictionary, keys: Array[String], what: String) -> void:
	for key: String in keys:
		if not dict.has(key):
			errors.append("%s is missing '%s'" % [what, key])
		elif not (dict[key] is float or dict[key] is int):
			errors.append("%s.%s must be a number" % [what, key])


func _validate_event(e: Dictionary) -> void:
	var kind: StringName = e["kind"]
	if not KINDS.has(kind):
		errors.append("unknown event kind '%s'" % kind)
		return
	if int(e["at_mm"]) < 0 or int(e["at_mm"]) >= _length_mm:
		errors.append("event '%s' at_mm %d is off the track" % [kind, int(e["at_mm"])])
	for key: String in EVENT_PARAMS[kind] as Array:
		if not e.has(key):
			errors.append("event '%s' at %d is missing '%s'" % [kind, int(e["at_mm"]), key])
		elif key != "dir" and int(e[key]) <= 0:
			errors.append("event '%s' needs %s > 0" % [kind, key])
	if e.has("dir") and not DIRS.has(String(e["dir"])):
		errors.append("event '%s' has bad dir '%s'" % [kind, e["dir"]])
	var cfg: Dictionary = effects.get(String(kind), {}) as Dictionary
	if not effects.has(String(kind)):
		errors.append("no effects entry for event kind '%s'" % kind)
	else:
		_require_keys(cfg, _typed(EFFECT_KEYS[kind] as Array), "effects.%s" % kind)


func _typed(a: Array) -> Array[String]:
	var out: Array[String] = []
	for v: Variant in a:
		out.append(String(v))
	return out
