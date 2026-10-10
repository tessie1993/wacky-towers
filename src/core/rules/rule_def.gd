class_name RuleDef extends RefCounted
## One rule definition from assets/data/rules/<id>.json (ADR-0004). Plain data; parsing lives elsewhere.

## Rule id.
var id: StringName = &""
## twist | mechanic | content | mascot (ADR-0004 F3 budget counts twist/mechanic).
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


## True when the layer is twist or mechanic.
func counts_toward_budget() -> bool:
	return layer == &"twist" or layer == &"mechanic"
