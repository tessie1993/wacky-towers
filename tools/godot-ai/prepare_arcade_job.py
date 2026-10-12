#!/usr/bin/env python3
"""Author the Arcade runtime through the live Godot AI editor tools."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DIRECTOR = r'''class_name WtArcadeDirector extends RefCounted
## Fixed-clock Arcade rule scheduling, executed through the same manual Beehave driver as BoardSim.
var _content: WtContent
var _modes: WtModes
var _runtime: RuleRuntime = RuleRuntime.new()
var _seed: int
var _pool: Array[Dictionary] = []
var _specials: PackedStringArray = PackedStringArray()
var _shapes: PackedStringArray = PackedStringArray()
var _active: Array[Dictionary] = []
var _pending: Array[Dictionary] = []
var _pending_at: int = -1
var _last_bucket: int = -1
var _last_signature: String = ""
var _repeats: int = 0
var _special_index: int = 0
var _config: Dictionary = {}

func setup(content: WtContent, modes: WtModes, progress: Dictionary, seed: int) -> void:
	_content = content
	_modes = modes
	_seed = seed
	_config = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/meta/modes.json")).arcade
	_pool = modes.encountered_arcade_rules(progress)
	_specials = modes.encountered_arcade_specials(progress)
	_shapes = PackedStringArray(_config.standard_shapes)

func update(simulation: BoardSim) -> Dictionary:
	return _runtime.execute(self, &"_update", [simulation])

func _update(simulation: BoardSim) -> Dictionary:
	var output: Dictionary = {}
	if simulation == null or simulation.get_phase() in [BoardSim.Phase.COUNTDOWN, BoardSim.Phase.ENDED]:
		return output
	var layers: int = simulation.goal_state().layers_cleared
	var bucket: int = layers / maxi(1, int(_config.get("twist_rotation_layers", 5)))
	if bucket > _last_bucket:
		_last_bucket = bucket
		_pending = _draw(layers, bucket)
		_pending_at = simulation.now_ms() + int(_config.get("announce_ms", 2000))
		var labels: PackedStringArray = PackedStringArray()
		for row: Dictionary in _pending: labels.append(String(row.id).replace("_", " ").capitalize())
		output.warning = "Next twist: " + ", ".join(labels)
	if _pending_at >= 0 and simulation.now_ms() >= _pending_at and simulation.get_phase() == BoardSim.Phase.RESOLVING:
		_active = _pending.duplicate(true)
		simulation.set_rule_definitions(_active)
		_pending_at = -1
		output.twists_changed = _active.duplicate(true)
		if layers >= int(_config.get("specials_after_layers", 10)) and not _specials.is_empty():
			var shape: String = _specials[_special_index % _specials.size()]
			_special_index += 1
			if not _shapes.has(shape):
				while _shapes.size() >= 8: _shapes.remove_at(0)
				_shapes.append(shape)
				simulation.set_shape_pool(_shapes)
				output.specials_changed = _shapes.duplicate()
	return output

func _draw(layers: int, bucket: int) -> Array[Dictionary]:
	var ids: Array = []
	for row: Dictionary in _pool: ids.append(String(row.id))
	var draw: Array = _modes.arcade_twists(layers, ids, _seed)
	var signature: String = _signature(draw)
	# A single available set is allowed to persist. With alternatives, a third repeat is redrawn.
	if signature == _last_signature and _repeats >= 2 and _pool.size() > draw.size():
		for attempt: int in range(1, 17):
			var alternate: Array = _modes.arcade_twists(layers, ids, Seeds.derive(_seed, ["arcade_redraw", bucket, attempt]))
			if _signature(alternate) != signature:
				draw = alternate
				signature = _signature(draw)
				break
	_repeats = _repeats + 1 if signature == _last_signature else 1
	_last_signature = signature
	var rules: Array[Dictionary] = []
	for id: String in draw:
		for row: Dictionary in _pool:
			if String(row.id) == id:
				rules.append(row.duplicate(true))
				break
	return rules

func _signature(ids: Array) -> String:
	var sorted: Array = ids.duplicate()
	sorted.sort()
	return ",".join(sorted)

func snapshot() -> Dictionary:
	return {"rules": _active.duplicate(true), "pending": _pending.duplicate(true), "pending_at": _pending_at,
		"bucket": _last_bucket, "shapes": _shapes.duplicate(), "special_index": _special_index,
		"runtime": _runtime.snapshot()}
'''

MODES_HELPERS = r'''
## An encounter survives losses; old saves also contribute successfully completed levels.
func _encountered_levels(progress: Dictionary) -> Array:
	var ids: Array = progress.get("encountered_levels", []).duplicate()
	for id: Variant in progress.get("levels", {}).keys():
		if int(progress.levels[id].get("stars", 0)) > 0 and not ids.has(str(id)): ids.append(str(id))
	return ids

## Returns trusted twist rows, retaining authored parameter bundles and filtering out level mechanics.
func encountered_arcade_rules(progress: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if _content == null: return result
	var encounters: Array = _encountered_levels(progress)
	var seen: Dictionary = {}
	for entry: Dictionary in _content.all_levels():
		if not encounters.has(str(entry.id)): continue
		for row: Dictionary in _content.raw_level(str(entry.id)).get("rules", []):
			var id: StringName = StringName(str(row.get("id", "")).trim_suffix("*"))
			var definition: RuleDef = _content.catalog.rule_defs.get(id)
			if definition == null or definition.layer != &"twist" or seen.has(id): continue
			seen[id] = true
			result.append({"id": String(id), "params": row.get("params", {}).duplicate(true)})
	# The meadow Wind card is the introductory Arcade twist even on a fresh profile.
	if result.is_empty() and _content.catalog.rule_defs.has(&"gust"):
		result.append({"id": "gust", "params": {"wind_dir": "+x", "wind_interval_ms": 7000, "wind_strength": 1}})
	return result

## Specials are unlocked by an encounter with their piece set; standard shapes are excluded.
func encountered_arcade_specials(progress: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	if _content == null: return result
	var encounters: Array = _encountered_levels(progress)
	var standard: Array = _config.arcade.standard_shapes
	for entry: Dictionary in _content.all_levels():
		if not encounters.has(str(entry.id)): continue
		var pieces: Dictionary = _content.raw_level(str(entry.id)).get("pieces", {})
		for shape: Variant in pieces.get("shapes", []):
			var id: String = str(shape)
			if not standard.has(id) and not result.has(id) and _content.catalog.shapes.has_shape(StringName(id)):
				result.append(id)
	return result

## The trusted item table is loaded from data for real tuning, including standing bias.
func item_rule(extra_slots: int = 0) -> Dictionary:
	return {"id": "items", "params": {"enabled": true, "extra_slots": clampi(extra_slots, 0, 2),
		"table": _read("res://assets/data/items/starter.json").get("items", [])}}
'''

source = (ROOT / "src/game/modes/wt_modes.gd").read_text()
source = source.replace('source.goal = {"type": "endless"}', 'source.goal = {"type": "endless"}\n\tsource.rules = [item_rule()]')
source = source.replace('if definition.incompatible_with.has(old): compatible = false', 'var prior: RuleDef = _content.catalog.rule_defs.get(StringName(old))\n\t\t\tif definition.incompatible_with.has(old) or (prior != null and prior.incompatible_with.has(str(candidate))): compatible = false')
if "func encountered_arcade_rules" not in source:
    source += MODES_HELPERS
job = {"id": "root-arcade-director", "actions": [
    {"tool": "script_create", "arguments": {"path": "res://src/game/modes/wt_modes.gd", "content": source}},
    {"tool": "script_create", "arguments": {"path": "res://src/game/modes/wt_arcade_director.gd", "content": DIRECTOR}},
    {"tool": "filesystem_manage", "arguments": {"op": "scan", "params": {}}},
]}
folder = ROOT / "tools/godot-ai/jobs"
folder.mkdir(parents=True, exist_ok=True)
target = folder / "root-arcade-director.json"
temp = target.with_suffix(".tmp")
temp.write_text(json.dumps(job, indent=2))
temp.replace(target)
print(target)
