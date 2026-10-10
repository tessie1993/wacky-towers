class_name MonoLayerDetector extends ClearDetector
## Base clears remain; an all-one-key layer also clears the next occupied layers.
const PLUGIN_ID := &"mono_layer"


func find_clears(board: BoardState, api: RuleApi) -> Array[ClearGroup]:
	var layers: PackedInt32Array = board.full_layers()
	var extras: int = api.knob_int(&"clear.mono_extra_layers")
	if api.knob(&"clear.mono_extra_layers") == null:
		extras = 1
	var marked: Dictionary = {}
	for layer: int in layers:
		marked[layer] = true
		var colour: int = -1
		var mono: bool = true
		for i: int in board.layer_cells(layer):
			if not board.is_active(i):
				continue
			if board.get_color(i) == 0:
				mono = false
				break
			if colour < 0:
				colour = board.get_color(i)
			elif board.get_color(i) != colour:
				mono = false
				break
		if mono:
			var found: int = 0
			for above: int in range(layer + 1, board.layer_count()):
				var content: bool = false
				for i: int in board.layer_cells(above):
					content = content or board.get_kind(i) != 0
				if content and found < extras:
					marked[above] = true
					found += 1
	var out: Array[ClearGroup] = []
	var keys: Array = marked.keys()
	keys.sort()
	for layer: int in keys:
		var group := ClearGroup.new()
		group.counts_as_layers = 1
		for i: int in board.layer_cells(layer):
			if board.get_kind(i) != 0:
				group.cells.append(i)
		out.append(group)
	return out
