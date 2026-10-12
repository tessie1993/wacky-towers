class_name ColourConnectDetector extends ClearDetector
## Maximal same-key face groups pop only when enough separate pieces contributed.
const PLUGIN_ID := &"colour_connect"


func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]:
	var out: Array[ClearGroup] = []
	var visited: Dictionary = {}
	var threshold: int = api.knob_int(&"clear.pop_min")
	var pieces_needed: int = api.knob_int(&"clear.pop_min_pieces")
	threshold = threshold if threshold > 0 else 6
	pieces_needed = pieces_needed if pieces_needed > 0 else 2
	var cleared: Dictionary = {}
	for layer: int in board.layer_count():
		for start: int in board.layer_cells(layer):
			if visited.has(start) or board.get_kind(start) == 0 or board.get_color(start) == 0 or not board.can_remove(start, BoardState.Cause.CLEAR):
				continue
			var group: ClearGroup = ClearGroup.new()
			var key: int = board.get_color(start)
			var queue := PackedInt32Array([start])
			var cursor: int = 0
			var uids: Dictionary = {}
			visited[start] = true
			while cursor < queue.size():
				var i: int = queue[cursor]
				cursor += 1
				group.cells.append(i)
				uids[int(board.get_record(i).get("piece_instance_id", 0))] = true
				for direction_value: Vector3i in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]:
					var c: Vector3i = board.cell(i) + direction_value
					if not board.in_bounds(c):
						continue
					var next: int = board.index(c)
					if not visited.has(next) and board.get_kind(next) != 0 and board.get_color(next) == key and board.can_remove(next, BoardState.Cause.CLEAR):
						visited[next] = true
						queue.append(next)
			if group.cells.size() >= threshold and uids.size() >= pieces_needed:
				group.counts_as_layers = 1
				out.append(group)
				for i: int in group.cells:
					cleared[i] = true
	if api.knob_flag(&"clear.layer_clear_too"):
		for group: ClearGroup in LayerDetector.new().find_clears(board, api):
			var any_new: bool = false
			for i: int in group.cells:
				any_new = any_new or not cleared.has(i)
			if any_new:
				out.append(group)
	return out
