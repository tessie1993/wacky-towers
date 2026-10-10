class_name ShapeGoal extends GoalEvaluator
## Targets are exact cells; extra cubes are permitted and never replace targets.

const PLUGIN_ID := &"shape"
var _targets: Array[Vector3i] = []
var _colours: Dictionary = {}
var _done: int = 0
var _required: int = 0


func configure(goal: Dictionary) -> void:
	_targets.clear()
	_colours.clear()
	var target: Dictionary = goal.get("target_shape", {})
	var layers: Dictionary = target.get("layers", {})
	for key: Variant in layers:
		var rows: Array = layers[key]
		for z: int in rows.size():
			var row: String = String(rows[z])
			for x: int in row.length():
				var glyph: String = row[x]
				if glyph in ["+", "#", "P", "V", "M"]:
					var c := Vector3i(x, int(key), z)
					_targets.append(c)
					if glyph in ["P", "V", "M"]:
						_colours[c] = {"P": 1, "V": 2, "M": 3}[glyph]
	for raw: Variant in goal.get("targets", []):
		if raw is Vector3i:
			_targets.append(raw)
		elif raw is Array and raw.size() == 3:
			_targets.append(Vector3i(int(raw[0]), int(raw[1]), int(raw[2])))
	_required = clampi(int(goal.get("win_correct", _targets.size())), 1, maxi(1, _targets.size()))


func evaluate(_state: GoalState, api: RuleApi) -> int:
	_done = 0
	for c: Vector3i in _targets:
		var colour_matches: bool = not _colours.has(c) or api.color_at(c) == int(_colours[c]) or bool(api.record_at(c).get("status", {}).get("rainbow", false))
		if api.is_active(c) and api.fills_layer_at(c) and colour_matches:
			_done += 1
	return WON if not _targets.is_empty() and _done >= _required else RUNNING


func progress(_state: GoalState) -> Dictionary:
	return {"done": _done, "target": _required, "cells": _targets.duplicate(), "colours": _colours.duplicate(), "total_targets": _targets.size()}


func target_cells() -> Array[Vector3i]:
	return _targets.duplicate()
