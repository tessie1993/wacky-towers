class_name GummyCascadeCollapse extends CollapsePolicy
## Every face-connected same-flavour blob falls as a rigid group, retaining overhangs.
const PLUGIN_ID := &"gummy_cascade"


func collapse(board: BoardState, cleared: Array[ClearGroup], api: RuleApi) -> void:
	for group: ClearGroup in cleared:
		for i: int in group.cells:
			board.remove(i, BoardState.Cause.CLEAR)
	# Repeat bottom-first passes: groups newly connected after falling merge next pass.
	for _pass: int in board.layer_count():
		var visited: Dictionary = {}
		var moved: bool = false
		for layer: int in board.layer_count():
			for start: int in board.layer_cells(layer):
				if visited.has(start) or board.get_kind(start) == 0:
					continue
				var colour: int = board.get_color(start)
				var cells: Array[Vector3i] = []
				var queue := PackedInt32Array([start])
				var cursor: int = 0
				visited[start] = true
				while cursor < queue.size():
					var i: int = queue[cursor]
					cursor += 1
					cells.append(board.cell(i))
					if colour == 0:
						continue # colourless content drops as a single cube
					for direction_value: Vector3i in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i(0, 0, -1), Vector3i(0, 0, 1)]:
						var c: Vector3i = board.cell(i) + direction_value
						if not board.in_bounds(c):
								continue
						var next: int = board.index(c)
						if not visited.has(next) and board.get_kind(next) != 0 and board.get_color(next) == colour:
								visited[next] = true
								queue.append(next)
				var distance: int = MechanicsCells.rigid_distance(api, cells, board.down_vector())
				if distance > 0:
					board.move_batch(cells, MechanicsCells.translated(cells, board.down_vector() * distance))
					moved = true
		if not moved:
			break
