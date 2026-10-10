class_name ClearGroup extends RefCounted
## One group of cells a ClearDetector wants cleared. Usage: `g.cells = PackedInt32Array([4, 5])`.

## BoardState cell indices in the group.
var cells: PackedInt32Array = PackedInt32Array()
## How many layers this group counts as for scoring.
var counts_as_layers: int = 0
