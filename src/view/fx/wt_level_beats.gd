class_name WtLevelBeats extends RefCounted
## Presentation consumer for level beats (design/levels/meadow/meadow_01.md sections 2 and 5).
## Reads assets/data/presentation/level_beats.json and turns sim events (grip_released sky_step, layers_cleared,
## piece_locked, rescue_wiped, goal_reached, level_failed) into calls on injected view hooks. Never touches the sim.
## Hooks (Callables, all optional): sky(grade, seconds) camera(preset, seconds) shake(amp, seconds) glow(color, alpha, seconds)
## ring(center_cell, color, radius, seconds, alpha, delay) swoop(seconds, color, layers) burst(color, count) cue(id) lock_input().
## Every call is also appended to `log` so tests can prove an event reached its consumer.
const PATH := "res://assets/data/presentation/level_beats.json"

var cfg: Dictionary = {}
var sky_list: Array = []
var board_size: Vector3i = Vector3i(8, 8, 8)
var log: Array[Dictionary] = []
var _hooks: Dictionary = {}
var _last_layer: int = 0


## Beats block for a level id (empty when the level has none).
static func read(level_id: String) -> Dictionary:
	if not FileAccess.file_exists(PATH): return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		return (parsed as Dictionary).get("levels", {}).get(level_id, {})
	return {}


## Binds config, the level's look.sky list, the board size and the view hooks.
func setup(p_cfg: Dictionary, p_sky: Array, p_size: Vector3i, hooks: Dictionary) -> void:
	cfg = p_cfg
	sky_list = p_sky
	board_size = p_size
	_hooks = hooks


## Applies step 0 (dawn grade, stage-0 camera) without animation.
func start() -> void:
	_step(0, 0.0)


## Routes one sim event. Unknown kinds are ignored.
func handle(ev: SimEvent) -> void:
	match ev.kind:
		&"grip_released": _release(ev.data)
		SimEvents.LAYERS_CLEARED:
			var idx: Array = ev.data.get("indices", [])
			_last_layer = int(idx[0]) if not idx.is_empty() else 0
			var r: Dictionary = cfg.get("layer_clear", {}).get("ring", {})
			if not r.is_empty():
				_do(&"ring", [Vector3i(board_size.x / 2, _last_layer, board_size.z / 2), Color(String(r.color)),
					float(r.radius_per_width) * board_size.x * 0.5, float(r.seconds), float(r.alpha), 0.0])
		SimEvents.PIECE_LOCKED:
			var l: Dictionary = cfg.get("lock", {})
			var cells: Array = ev.data.get("cells", [])
			_cues(l.get("cues", []))
			var rr: Dictionary = l.get("ring", {})
			if not rr.is_empty() and not cells.is_empty():
				_do(&"ring", [cells[0], Color(String(rr.color)), float(rr.radius), float(rr.seconds), float(rr.alpha), 0.0])
		SimEvents.RESCUE_WIPED:
			var s: Dictionary = cfg.get("rescue", {})
			_cues(s.get("cues", []))
			_do(&"swoop", [float(s.get("swoop_seconds", 1.2)), Color(String(s.get("cloud_color", "#d9c8ff"))), int(ev.data.get("k", 3))])
		SimEvents.GOAL_REACHED:
			var w: Dictionary = cfg.get("win", {})
			_do(&"lock_input", [])
			_cues(w.get("cues", []))
			var g: Dictionary = w.get("glow", {})
			if not g.is_empty(): _do(&"glow", [Color(String(g.color)), float(g.alpha), float(g.seconds)])
			var rs: Dictionary = w.get("rings", {})
			for i: int in int(rs.get("count", 0)):
				_do(&"ring", [Vector3i(board_size.x / 2, 0, board_size.z / 2), Color(String(rs.color)), float(rs.radius), float(rs.seconds), float(rs.alpha), float(i) * float(rs.stagger_seconds)])
			var b: Dictionary = w.get("burst", {})
			if not b.is_empty(): _do(&"burst", [Color(String(b.color)), int(b.count)])
		SimEvents.LEVEL_FAILED:
			_cues(cfg.get("lose", {}).get("cues", []))


func _release(data: Dictionary) -> void:
	var r: Dictionary = cfg.get("release", {})
	var step: int = int(data.get("sky_step", 0))
	_step(step, -1.0)
	var sh: Dictionary = r.get("shake", {})
	if not sh.is_empty(): _do(&"shake", [float(sh.amp), float(sh.seconds)])
	var g: Dictionary = r.get("glow", {})
	if not g.is_empty(): _do(&"glow", [Color(String(g.color)), float(g.alpha), float(g.seconds)])
	_cues(r.get("cues", []))
	_cues(r.get("cues_by_stage", {}).get(String(data.get("stage", "")), []))
	var b: Dictionary = r.get("burst", {})
	if not b.is_empty(): _do(&"burst", [Color(String(b.color)), int(b.count)])


func _step(step: int, seconds: float) -> void:
	if not sky_list.is_empty():
		var name: String = String(sky_list[clampi(step, 0, sky_list.size() - 1)])
		var grade: String = String(cfg.get("sky_grades", {}).get(name, name))
		_do(&"sky", [grade, float(cfg.get("sky_seconds", 1.5)) if seconds < 0.0 else seconds])
	var cams: Array = cfg.get("camera_by_step", [])
	if not cams.is_empty():
		_do(&"camera", [String(cams[clampi(step, 0, cams.size() - 1)]), float(cfg.get("camera_seconds", 1.0)) if seconds < 0.0 else seconds])


func _cues(ids: Array) -> void:
	for id: Variant in ids: _do(&"cue", [StringName(String(id))])


func _do(fx: StringName, args: Array) -> void:
	log.append({"fx": fx, "args": args})
	var h: Variant = _hooks.get(fx)
	if h is Callable and (h as Callable).is_valid(): (h as Callable).callv(args)
