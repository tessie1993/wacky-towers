class_name WtPerfectFit extends RefCounted
## Pure Redraw placement search (Skills F5). The caller caches results until a board write.
## Godot has no nested typed arrays; each returned mark is an Array[Vector3i].


static func suggestions(api: RuleApi, shape: ShapeDef, max_marks: int = 2) -> Array:
	var marks: Array = []
	if api == null or shape == null or shape.cube_count == 0 or max_marks <= 0:
		return marks
	var down: Vector3i = api.down_vector()
	var axis: int = 1 if down.y != 0 else (0 if down.x != 0 else 2)
	var grounds: Array[int] = []
	for coordinate: int in 3:
		if coordinate != axis:
			grounds.append(coordinate)
	var size: Vector3i = api.board_size()
	var candidates: Array[Dictionary] = []
	var seen_orientations: Dictionary = {}
	var seen_targets: Dictionary = {}
	for orientation: int in shape.offsets_by_orient.size():
		var distinct: int = shape.distinct_of[orientation] if orientation < shape.distinct_of.size() else orientation
		if seen_orientations.has(distinct):
			continue
		seen_orientations[distinct] = true
		var box: Vector3i = shape.bbox(orientation)
		if box[axis] > size[axis]:
			continue
		for a: int in maxi(0, size[grounds[0]] - box[grounds[0]] + 1):
			for b: int in maxi(0, size[grounds[1]] - box[grounds[1]] + 1):
				var corner := Vector3i.ZERO
				corner[grounds[0]] = a
				corner[grounds[1]] = b
				corner[axis] = size[axis] - box[axis] if down[axis] < 0 else 0
				var origin: Vector3i = corner - shape.min_corner(orientation)
				var cells: Array[Vector3i] = []
				for offset: Vector3i in shape.offsets(orientation):
					cells.append(origin + offset)
				if not api.can_place(cells):
					continue
				var distance: int = api.cast(cells, down)
				for i: int in cells.size():
					cells[i] += down * distance
				if not api.can_place(cells) or api.new_covered_holes(cells) != 0:
					continue
				cells.sort()
				var key: String = _key(cells)
				if seen_targets.has(key):
					continue
				seen_targets[key] = true
				var lowest: int = api.layer_count()
				var support: int = 0
				for cell: Vector3i in cells:
					lowest = mini(lowest, api.layer_of(cell))
					if cells.has(cell + down) or not api.is_free(cell + down):
						support += 1
				candidates.append({"cells": cells, "clear": _clear_count(api, cells, axis, grounds),
					"support": support, "depth": api.layer_count() - lowest,
					"orientation": orientation, "a": a, "b": b})
	candidates.sort_custom(_better)
	for i: int in mini(clampi(max_marks, 0, 3), candidates.size()):
		marks.append(candidates[i]["cells"])
	return marks


static func _better(left: Dictionary, right: Dictionary) -> bool:
	for criterion: String in ["clear", "support", "depth"]:
		if left[criterion] != right[criterion]:
			return int(left[criterion]) > int(right[criterion])
	for criterion: String in ["orientation", "a", "b"]:
		if left[criterion] != right[criterion]:
			return int(left[criterion]) < int(right[criterion])
	return false


static func _clear_count(api: RuleApi, cells: Array[Vector3i], axis: int, grounds: Array[int]) -> int:
	if not api.would_clear(cells):
		return 0
	# The facade's predictor is boolean; distinguish multiple completed layer planes for F5 ranking.
	var layers: Dictionary = {}
	for cell: Vector3i in cells:
		layers[api.layer_of(cell)] = true
	var count: int = 0
	var size: Vector3i = api.board_size()
	var down: Vector3i = api.down_vector()
	for layer: int in layers:
		var missing: int = 0
		var active: int = 0
		for a: int in size[grounds[0]]:
			for b: int in size[grounds[1]]:
				var cell := Vector3i.ZERO
				cell[axis] = layer if down[axis] < 0 else size[axis] - 1 - layer
				cell[grounds[0]] = a
				cell[grounds[1]] = b
				if api.is_active(cell):
					active += 1
					if not api.fills_layer_at(cell) and not cells.has(cell):
						missing += 1
		if active > 0 and missing == 0:
			count += 1
	return count


static func _key(cells: Array[Vector3i]) -> String:
	var value: String = ""
	for cell: Vector3i in cells:
		value += "%d,%d,%d;" % [cell.x, cell.y, cell.z]
	return value
