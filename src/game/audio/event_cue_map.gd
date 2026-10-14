class_name EventCueMap extends RefCounted
## Explicit event -> cue table (assets/data/audio/event_cues.json). No substring matching anywhere.
## `resolve` is pure: it returns plays as {cue, pitch_st, gain_db, delay_ms}; the director plays them.

const PATH := "res://assets/data/audio/event_cues.json"

var data: Dictionary = {}
var _board: Dictionary = {}
var _sim: Dictionary = {}
var _scale: Dictionary = {}
static var _shared: EventCueMap = null


## Shared instance for static lookups such as WtAudio.board_sfx.
static func shared() -> EventCueMap:
	if _shared == null:
		_shared = EventCueMap.load_default()
	return _shared


## Reads the default table.
static func load_default() -> EventCueMap:
	var m := EventCueMap.new()
	m.setup(JsonReader.read_file(PATH, JsonReader.DEFAULT_MAX_BYTES).get("data", {}))
	return m


## Installs a parsed table.
func setup(table: Dictionary) -> void:
	data = table
	_board = table.get("board_events", {})
	_sim = table.get("sim_events", {})
	_scale = table.get("scaling", {})


## Cue for a board mechanic event (exact kind only), or `fallback`.
func board_cue(kind: StringName, fallback: StringName = &"") -> StringName:
	return StringName(_board.get(String(kind), fallback))


## Turn / Flip / Roll for a world rotation axis. The axis along gravity is Turn, the others are Flip then Roll.
static func rotation_name(axis: int, down: Vector3i) -> StringName:
	if axis < 0 or axis > 2:
		return &"turn"
	if down[axis] != 0:
		return &"turn"
	var ground: Array[int] = []
	for a: int in 3:
		if down[a] == 0:
			ground.append(a)
	return &"flip" if ground.size() > 0 and ground[0] == axis else &"roll"


## Plays for one sim event kind. `ctx` may hold last_axis (int) and down (Vector3i).
func resolve(kind: StringName, event_data: Dictionary, ctx: Dictionary = {}) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var row: Dictionary = _sim.get(String(kind), {})
	if row.is_empty():
		return out
	match String(row.get("handler", "")):
		"rotate":
			var name: StringName = rotation_name(int(ctx.get("last_axis", -1)), ctx.get("down", Vector3i(0, -1, 0)))
			out.append(_play("SFX_ROTATE", float(_scale.get("rotation_st", {}).get(String(name), 0.0))))
			return out
		"clear":
			return _clear(event_data)
	if _matches(row.get("when", {}), event_data):
		for cue: Variant in row.get("cues", []):
			out.append(_play(String(cue)))
	for extra: Variant in row.get("extra", []):
		if _matches(extra.get("when", {}), event_data):
			for cue: Variant in extra.get("cues", []):
				out.append(_play(String(cue)))
	return out


## Layer ripple, tier cues, and combo steps for one layers_cleared event.
func _clear(d: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var layers: int = maxi(1, int(d.get("n_layers", (d.get("layers", []) as Array).size())))
	var ripple: Array = _scale.get("ripple_st", [0])
	var stagger: int = int(_scale.get("clear_stagger_ms", 100))
	for i: int in layers:
		out.append(_play("SFX_CLEAR_LAYER", float(ripple[mini(i, ripple.size() - 1)]), 0.0, i * stagger))
	var tiers: Array = _scale.get("tier_cues", [])
	var gains: Array = _scale.get("tier_gain_db", [0.0])
	var tier: int = clampi(layers, 1, maxi(1, tiers.size()))
	var tier_delay: int = layers * stagger
	if not tiers.is_empty():
		out.append(_play(String(tiers[tier - 1]), 0.0, float(gains[mini(tier - 1, gains.size() - 1)]), tier_delay))
	for extra: Variant in _scale.get("tier_extra", {}).get(str(tier), []):
		out.append(_play(String(extra), 0.0, 0.0, tier_delay))
	var round_no: int = int(d.get("chain_round", 1))
	if round_no >= int(_scale.get("combo_min_round", 2)):
		var step: int = round_no - int(_scale.get("combo_min_round", 2)) + 1
		var st: float = minf(step * float(_scale.get("combo_step_st", 1.0)), float(_scale.get("combo_cap_st", 6.0)))
		out.append(_play(String(_scale.get("combo_cue", "")), st, 0.0, tier_delay + 120))
	return out


func _matches(when: Dictionary, event_data: Dictionary) -> bool:
	for key: Variant in when:
		if String(event_data.get(key, "")) != String(when[key]):
			return false
	return true


func _play(cue: String, pitch_st: float = 0.0, gain_db: float = 0.0, delay_ms: int = 0) -> Dictionary:
	return {"cue": StringName(cue), "pitch_st": pitch_st, "gain_db": gain_db, "delay_ms": delay_ms}
