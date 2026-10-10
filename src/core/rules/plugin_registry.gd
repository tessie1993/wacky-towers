class_name PluginRegistry extends RefCounted
## Maps plugin kind -> PLUGIN_ID -> Script, built once from ProjectSettings.get_global_class_list() (ADR-0004 §1).
## Usage: `PluginRegistry.new(ProjectSettings.get_global_class_list()).create(&"ClearDetector", &"line")`.

const BASES_DIR := "res://src/core/rules/bases/"
const ID_CONST := "PLUGIN_ID"

var _scripts: Dictionary = {}  # kind -> {id -> Script}
var _errors: PackedStringArray = PackedStringArray()


func _init(class_list: Array[Dictionary]) -> void:
	var index: Dictionary = {}
	for e: Dictionary in class_list:
		index[e["class"]] = e
	for e: Dictionary in class_list:
		var kind: StringName = _kind_of(e, index)
		if kind != &"":
			_register(kind, String(e["path"]))


## New plugin instance for (kind, plugin_id), or null if unknown. Usage: `reg.create(&"ClearDetector", &"line")`.
func create(kind: StringName, plugin_id: StringName) -> RefCounted:
	var by_id: Dictionary = _scripts.get(kind, {})
	if not by_id.has(plugin_id):
		return null
	return (by_id[plugin_id] as GDScript).new() as RefCounted


## Sorted plugin ids of a kind (empty if unknown). Usage: `reg.ids(&"ClearDetector")`.
func ids(kind: StringName) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for k: StringName in (_scripts.get(kind, {}) as Dictionary):
		out.append(String(k))
	out.sort()
	return out


## Problems found while indexing. Usage: `assert(reg.errors().is_empty())`.
func errors() -> PackedStringArray:
	return _errors


# Kind name if `entry` is a plugin (descends from a class under BASES_DIR, not one itself), else &"".
func _kind_of(entry: Dictionary, index: Dictionary) -> StringName:
	if String(entry["path"]).begins_with(BASES_DIR):
		return &""
	var cur: Dictionary = entry
	while index.has(cur["base"]):
		cur = index[cur["base"]]
		if String(cur["path"]).begins_with(BASES_DIR):
			return cur["class"]
	return &""


func _register(kind: StringName, path: String) -> void:
	var script: GDScript = load(path) as GDScript
	var consts: Dictionary = script.get_script_constant_map() if script != null else {}
	if not consts.has(ID_CONST):
		_errors.append("%s: missing PLUGIN_ID" % path)
		return
	if typeof(consts[ID_CONST]) != TYPE_STRING_NAME:
		_errors.append("%s: PLUGIN_ID must be a StringName" % path)
		return
	var id: StringName = consts[ID_CONST]
	var by_id: Dictionary = _scripts.get_or_add(kind, {})
	if by_id.has(id):
		_errors.append("duplicate PLUGIN_ID '%s' for %s: %s, %s" % [id, kind, (by_id[id] as GDScript).resource_path, path])
		return
	by_id[id] = script
