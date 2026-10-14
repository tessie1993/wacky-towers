class_name TrackDef extends RefCounted
## Immutable, data-driven description of one moving-platform track (gap G8, docs/architecture/moving-platform.md).
## Pure data: segments, scheduled events, checkpoints, the cargo rules, effect tuning and a view path.
## Distances are integer millimetres of track, speeds are mm per second, so the sim stays exact.
## Usage: var def: TrackDef = TrackDef.load_file("res://assets/data/tracks/meadow_brook_run.json").

## Event kinds a track may schedule.
const KIND_BUMP := &"bump"
const KIND_ARCH := &"arch"
const KIND_UPDRAFT := &"updraft"
const KIND_CROSSWIND := &"crosswind"
const KIND_CLOUD_BUMP := &"cloud_bump"
const KINDS: Array[StringName] = [KIND_BUMP, KIND_ARCH, KIND_UPDRAFT, KIND_CROSSWIND, KIND_CLOUD_BUMP]

## Track id, e.g. &"meadow_brook_run".
var id: StringName = &""
## Fixed sim tick of the platform in milliseconds.
var tick_ms: int = 50
## How far ahead the preview strip looks, in mm.
var preview_window_mm: int = 0
## What a lost cargo does: &"checkpoint" (return to the last post) or &"fail" (end the run).
var on_loss: StringName = &"checkpoint"
## Segments in order: {id, length_mm, speed_mm_s, start_mm}.
var segments: Array[Dictionary] = []
## Scheduled events sorted by at_mm: {kind, at_mm, ...kind params}.
var events: Array[Dictionary] = []
## Checkpoints sorted by at_mm: {id, at_mm}.
var checkpoints: Array[Dictionary] = []
## Cargo rules: {id, x, z, height_layers, max_drop_layers}.
var cargo: Dictionary = {}
## Per-kind effect tuning, see assets/data/tracks/*.json.
var effects: Dictionary = {}
## View polyline the platform rides, in world units.
var path: PackedVector3Array = PackedVector3Array()
## Problems found while parsing; empty when the track is usable.
var errors: PackedStringArray = PackedStringArray()

var _length_mm: int = 0
var _path_lengths: PackedFloat32Array = PackedFloat32Array()


## Loads a track JSON file. Check is_valid() on the result. Usage: TrackDef.load_file("res://assets/data/tracks/x.json").
static func load_file(file_path: String) -> TrackDef:
	var text: String = FileAccess.get_file_as_string(file_path)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		var bad := TrackDef.new()
		bad.errors.append("%s: not a JSON object" % file_path)
		return bad
	return from_dict(parsed as Dictionary)


## Builds a track from parsed JSON. Check is_valid() on the result. Usage: TrackDef.from_dict({"id": "t", ...}).
static func from_dict(d: Dictionary) -> TrackDef:
	var def := TrackDef.new()
	def.id = StringName(String(d.get("id", "")))
	def.tick_ms = int(d.get("tick_ms", 50))
	def.preview_window_mm = int(d.get("preview_window_mm", 0))
	def.on_loss = StringName(String(d.get("on_loss", "checkpoint")))
	def.effects = (d.get("effects", {}) as Dictionary).duplicate(true)
	def.cargo = (d.get("cargo", {}) as Dictionary).duplicate(true)
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


## The preview strip feed: events within [from_mm, from_mm + window), each with "ahead_mm". window < 0 uses preview_window_mm.
## Usage: strip.show(def.preview(runner.position_mm())).
func preview(from_mm: int, window_mm: int = -1) -> Array[Dictionary]:
	var span: int = preview_window_mm if window_mm < 0 else window_mm
	var out: Array[Dictionary] = []
	for e: Dictionary in events:
		var at: int = int(e["at_mm"])
		if at >= from_mm and at < from_mm + span:
			var row: Dictionary = e.duplicate()
			row["ahead_mm"] = at - from_mm
			out.append(row)
	return out


## The last checkpoint at or before mm; {} before the first (the start counts as the implicit post).
func checkpoint_before(mm: int) -> Dictionary:
	var found: Dictionary = {}
	for cp: Dictionary in checkpoints:
		if int(cp["at_mm"]) <= mm:
			found = cp
	return found


## View position along the path for track distance mm (clamped). Pure maths, shared by the stage and tests.
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


## Unit heading of the path at mm, for the cart to face; Vector3.FORWARD when degenerate.
func path_heading(mm: int) -> Vector3:
	var a: Vector3 = path_point(mm)
	var b: Vector3 = path_point(mm + maxi(1, _length_mm / 100))
	return (b - a).normalized() if b.distance_squared_to(a) > 0.0 else Vector3.FORWARD


func _parse_segments(rows: Array) -> void:
	var at: int = 0
	for row: Variant in rows:
		var seg: Dictionary = (row as Dictionary).duplicate()
		seg["length_mm"] = int(seg.get("length_mm", 0))
		seg["speed_mm_s"] = int(seg.get("speed_mm_s", 0))
		seg["start_mm"] = at
		at += int(seg["length_mm"])
		segments.append(seg)
	_length_mm = at


func _parse_marks(d: Dictionary) -> void:
	for row: Variant in d.get("events", []) as Array:
		var e: Dictionary = (row as Dictionary).duplicate()
		e["kind"] = StringName(String(e.get("kind", "")))
		e["at_mm"] = int(e.get("at_mm", -1))
		events.append(e)
	for row: Variant in d.get("checkpoints", []) as Array:
		var cp: Dictionary = (row as Dictionary).duplicate()
		cp["at_mm"] = int(cp.get("at_mm", -1))
		checkpoints.append(cp)
	events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["at_mm"]) < int(b["at_mm"]))
	checkpoints.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["at_mm"]) < int(b["at_mm"]))


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
	for seg: Dictionary in segments:
		if int(seg["speed_mm_s"]) <= 0 or int(seg["length_mm"]) <= 0:
			errors.append("segment '%s' needs positive length_mm and speed_mm_s" % seg.get("id", "?"))
	for e: Dictionary in events:
		if not KINDS.has(e["kind"]):
			errors.append("unknown event kind '%s'" % e["kind"])
		if int(e["at_mm"]) < 0 or int(e["at_mm"]) > _length_mm:
			errors.append("event '%s' at_mm %d is off the track" % [e["kind"], int(e["at_mm"])])
		elif not effects.has(String(e["kind"])):
			errors.append("no effects entry for event kind '%s'" % e["kind"])
	for cp: Dictionary in checkpoints:
		if int(cp["at_mm"]) < 0 or int(cp["at_mm"]) > _length_mm:
			errors.append("checkpoint '%s' is off the track" % cp.get("id", "?"))
	if on_loss != &"checkpoint" and on_loss != &"fail":
		errors.append("on_loss must be 'checkpoint' or 'fail'")
