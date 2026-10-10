class_name RuleDef extends RefCounted
## One rule definition from assets/data/rules/<id>.json (ADR-0004). Plain data.
## Usage: var d := RuleDef.new(); d.layer = &"twist"; d.counts_toward_budget()

const LAYER_TWIST: StringName = &"twist"        # ADR-0004 F3 budget layer
const LAYER_MECHANIC: StringName = &"mechanic"  # ADR-0004 F3 budget layer

var id: StringName = &""
## twist | mechanic | content | mascot
var layer: StringName = &""
var icon: String = ""
var name_key: String = ""
## Param schema.
var params: Dictionary = {}
var modifiers: Array[Dictionary] = []
var vetoes: Array[Dictionary] = []
## RuleBehaviour PLUGIN_ID, &"" for data-only rules.
var behaviour: StringName = &""
var lifetime: Dictionary = {}
var incompatible_with: PackedStringArray = PackedStringArray()
var tags_requires: PackedStringArray = PackedStringArray()
var tags_provides: PackedStringArray = PackedStringArray()


## True when the layer is twist or mechanic (counts toward the ADR-0004 F3 budget).
func counts_toward_budget() -> bool:
	return layer == LAYER_TWIST or layer == LAYER_MECHANIC
