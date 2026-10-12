"""Submit semantic fixes via the live Godot AI editor, never direct game-file writes."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
actions = []

def replace(path, old, new):
    actions.append({"tool": "script_patch", "arguments": {"path": "res://" + path, "old_text": old, "new_text": new}})

replace("src/mechanics/behaviour/mascot_catch.gd", '\tif not api.spawn_cells_free():', '\tif bool(api.param(&"happy_only", false)) and CandyCells.tidy(api) < 0.9:\n\t\treturn false\n\tif not api.spawn_cells_free():')
replace("src/mechanics/behaviour/angle_gem.gd", '\t\tvar args: Dictionary = ctx.data.get("args", {})\n\t\tif String(args.get("secret_id", "")) == id:', '\t\tvar raw_args: Variant = ctx.data.get("args", [])\n\t\tvar args: Dictionary = raw_args[0] if raw_args is Array and not raw_args.is_empty() and raw_args[0] is Dictionary else raw_args if raw_args is Dictionary else {}\n\t\tif String(args.get("secret_id", "")) == id:')
replace("src/mechanics/behaviour/angle_gem.gd", 'api.emit(&"secret_placed", {"id": id, "angle": api.param(&"angle", "low"), "location": api.param(&"location", "under_island")})', 'api.emit(&"secret_placed", {"id": id, "angle": api.param(&"angle", "low"), "location": api.param(&"location", "under_island"), "cell": api.param(&"cell", []), "skin": api.param(&"skin", "gem"), "view_snap": api.param(&"view_snap", 0), "where": api.param(&"where", "under_island")})')

path = "src/mechanics/behaviour/items.gd"
source = (root / path).read_text()
start = source.index('func _spawn(')
end = source.index('\nfunc _lock(', start)
new_spawn = r'''func _spawn(_ctx: HookContext, api: RuleApi) -> void:
	_tag_uid = -1
	_tag_index = -1
	_tag_shape = &""
	_tag_token = ""
	var carried: Dictionary = api.piece_flag(&"item_cube", {})
	var checked: bool = bool(api.piece_flag(&"item_checked", false))
	if _bomb_next or bool(api.piece_flag(&"bomb", false)):
		_bomb_uid = api.get_piece_uid()
		_bomb_next = false
		api.set_piece_flag(&"bomb", true)
	if not _enabled:
		return
	var cells: Array[Vector3i] = api.piece_cells()
	var shape: ShapeDef = api.get_piece_shape()
	if checked:
		# Holding retains the original one-time roll and cube token, even with a new instance uid.
		if shape != null and str(carried.get("shape", "")) == str(shape.shape_id):
			_tag_index = int(carried.get("cube_index", -1))
			_tag_token = str(carried.get("token", ""))
	else:
		_tag_index = spawn_roll(api.rng(), float(api.param(&"p_item", 0.12)), cells.size(), bool(api.piece_flag(&"injected", false)))
		_tag_token = "%s:%d" % [str(api.item_context().get("owner", 0)), api.get_piece_uid()]
	api.set_piece_flag(&"item_checked", true)
	if _tag_index < 0 or _tag_index >= cells.size() or shape == null:
		api.set_piece_flag(&"item_cube", {})
		return
	_tag_uid = api.get_piece_uid()
	_tag_shape = shape.shape_id
	api.set_piece_flag(&"item_cube", {"uid": _tag_uid, "cube_index": _tag_index, "token": _tag_token, "shape": _tag_shape})
	api.emit(&"item_cube_tagged", {"uid": _tag_uid, "cube_index": _tag_index, "cell": cells[_tag_index]})
'''
replace(path, source[start:end], new_spawn)

FOG = r'''class_name FogRule extends RuleBehaviour
## Per-lock fade and deterministic ghost-footprint lantern light; collision remains untouched.
const PLUGIN_ID := &"fog"
var _started: int = -1
var _reveal_until: int = -1
var _alpha_milli: int = 1000
var _locked_at: Dictionary = {}
var _clear_count: int = 0
var _visibility_key: String = ""

func subscribed_hooks() -> Array[StringName]:
	return [&"on_spawn", &"on_tick", &"on_lock", &"on_clear"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	var now: int = api.time_ms()
	if hook == &"on_lock":
		_locked_at[int(ctx.data.get("uid", api.get_piece_uid()))] = now
	elif hook == &"on_clear":
		_clear_count = int(ctx.data.get("clear_count", _clear_count + 1))
		_reveal_until = now + maxi(1, int(api.param(&"reveal_ms", 600)))
	if _clear_count < int(api.param(&"active_after_clears", 0)):
		return
	if _started < 0:
		_started = now
	var radius: int = maxi(0, int(api.param(&"lantern_radius", 0)))
	var ghost: Array[Vector3i] = []
	if radius > 0 and not api.piece_cells().is_empty():
		var shift: Vector3i = api.down_vector() * api.cast(api.piece_cells(), api.down_vector())
		for cell: Vector3i in api.piece_cells():
			ghost.append(cell + shift)
		if api.rule_active(&"mirror"):
			var axis: int = 0 if str(api.knob(&"clear.mirror_axis")) != "z" else 2
			# Mirror's configured axis is shared by the runtime via mirror_twins / its rule params.
			axis = 2 if str(api.param(&"mirror_axis", "x")) == "z" else axis
			var size: Vector3i = api.board_size()
			for cell: Vector3i in ghost.duplicate():
				var twin: Vector3i = cell
				twin[axis] = size[axis] - 1 - cell[axis]
				ghost.append(twin)
	var visible_ms: int = maxi(0, int(api.param(&"visible_ms", 5000)))
	var fade_ms: int = maxi(1, int(api.param(&"fade_ms", 1000)))
	var minimum: float = clampf(float(api.param(&"invisible_alpha", 0.1)), 0.0, 1.0)
	var alphas: Array[Dictionary] = []
	var lantern: Array[Vector3i] = []
	var dimmest: float = 1.0
	for cell: Vector3i in MechanicsCells.occupied(api):
		var uid: int = int(api.record_at(cell).get("piece_instance_id", 0))
		var born: int = int(_locked_at.get(uid, _started))
		var fade: float = clampf(float(now - born - visible_ms) / float(fade_ms), 0.0, 1.0)
		var alpha: float = 1.0 if now < _reveal_until else lerpf(1.0, minimum, fade)
		for target: Vector3i in ghost:
			if maxi(absi(cell.x - target.x), absi(cell.z - target.z)) <= radius:
				alpha = 1.0
				lantern.append(cell)
				break
		dimmest = minf(dimmest, alpha)
		alphas.append({"cell": cell, "alpha": alpha})
	_alpha_milli = int(roundf(dimmest * 1000.0))
	var key: String = str(alphas)
	if key != _visibility_key:
		_visibility_key = key
		api.emit(&"fog_visibility", {"alpha_milli": _alpha_milli, "alpha": dimmest, "cell_alphas": alphas, "lantern_cells": lantern})

func snapshot() -> Dictionary:
	return {"started": _started, "reveal_until": _reveal_until, "alpha_milli": _alpha_milli,
		"locked_at": _locked_at.duplicate(true), "clear_count": _clear_count, "visibility_key": _visibility_key}
'''
actions.append({"tool":"script_create", "arguments":{"path":"res://src/mechanics/behaviour/fog.gd", "content":FOG}})
actions.append({"tool":"filesystem_manage", "arguments":{"op":"scan", "params":{}}})
job={"id":"mechanics-final-semantics-1", "actions":actions}
path=root / "tools/godot-ai/jobs/mechanics-final-semantics-1.json.tmp"
path.write_text(json.dumps(job));path.rename(path.with_suffix(""))
