class_name WtBridgeDashLayout extends RefCounted
## Builds the Bridge Bashers board (module `bridge_dash`): two full-depth pillars with a pit between them, and the
## A3 `span` goal block anchored on the facing pillar edges. Pure; params come resolved from assets/data/modules.
## Spec: design/gdd/modules-framework.md "Bridge Bashers layout".
## Usage: var r: Dictionary = WtBridgeDashLayout.build(8, 8, 10, params, "span")

## ASCII cell used for pillar cubes (BoardSpec starting_contents).
const PILLAR_CHAR := "#"
const EMPTY_CHAR := "."


## Returns {"goal": Dictionary, "starting_contents": Dictionary, "errors": PackedStringArray}.
## Usage: WtBridgeDashLayout.build(width, depth, h_play, {"gap_cells": 6, ...}, "span")
static func build(width: int, depth: int, h_play: int, params: Dictionary, goal_type: String) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	var out: Dictionary = {"goal": {}, "starting_contents": {}, "errors": errors}
	var gap: int = int(params.gap_cells)
	var pillar: int = int(params.pillar_cells)
	var height: int = int(params.pillar_height)
	var span: int = 2 * pillar + gap
	if span > width:
		errors.append("bridge_dash: 2 * pillar_cells + gap_cells = %d exceeds board width %d" % [span, width])
	if height >= h_play:
		errors.append("bridge_dash: pillar_height %d must be below h_play %d" % [height, h_play])
	var lane: int = int(params.lane_z)
	if lane < 0:
		lane = (depth - 1) / 2
	if lane >= depth:
		errors.append("bridge_dash: lane_z %d outside board depth %d" % [lane, depth])
	if not errors.is_empty():
		return out
	var x0: int = (width - span) / 2
	var right: int = x0 + pillar + gap
	var row: String = ""
	for x: int in width:
		var on_pillar: bool = (x >= x0 and x < x0 + pillar) or (x >= right and x < right + pillar)
		row += PILLAR_CHAR if on_pillar else EMPTY_CHAR
	var layers: Dictionary = {}
	for y: int in height:
		var rows: Array = []
		for z: int in depth:
			rows.append(row)
		layers[str(y)] = rows
	out["starting_contents"] = {"layers": layers}
	out["goal"] = {"type": goal_type, "anchor_a": [x0 + pillar - 1, lane], "anchor_b": [right, lane],
		"step_max": int(params.step_max), "walk_layer_min": int(params.walk_layer_min),
		"walk_ms": int(params.walk_ms), "hold_ms": int(params.hold_ms)}
	return out
