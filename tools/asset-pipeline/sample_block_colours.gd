extends SceneTree
## Samples each candy_toy block's albedo into palettes/candy_toy.json + shapes/shape_hand_fields.json.
## Usage: godot --headless --path . -s tools/asset-pipeline/sample_block_colours.gd

const DIR := "res://assets/models/blocks/candy_toy/"
const PREFIX := "blk_candy_toy_"
const OUT_PALETTE := "res://assets/data/palettes/candy_toy.json"
const OUT_FIELDS := "res://assets/data/shapes/shape_hand_fields.json"
const RESERVED_HUES: Array[float] = [186.0, 322.0] # buff / debuff hues
const RESERVED_TOLERANCE_DEG := 25.0
const MIN_SATURATION := 0.25 # below this the colour is grey-ish, hue is meaningless


func _initialize() -> void:
	var ids: Array[String] = []
	for f: String in DirAccess.get_files_at(DIR):
		if f.begins_with(PREFIX) and f.ends_with(".glb"):
			ids.append(f.trim_prefix(PREFIX).trim_suffix(".glb"))
	ids.sort()
	var hex_to_hue: Dictionary = {}
	var fields: Dictionary = {}
	var cube_hex: String = _hex_of("cube")
	hex_to_hue[cube_hex] = 0
	for id: String in ids:
		if id == "cube":
			continue
		var hex: String = _hex_of(id)
		if not hex_to_hue.has(hex):
			hex_to_hue[hex] = hex_to_hue.size()
			_warn_reserved(id, Color.html(hex))
		fields[id] = {"hue": hex_to_hue[hex], "family": "", "motif": ""}
	var colors: Dictionary = {}
	for hex: String in hex_to_hue:
		colors[str(hex_to_hue[hex])] = hex
	_write(OUT_PALETTE, {"set": "candy_toy", "colors": colors})
	_write(OUT_FIELDS, fields)
	print("sampled %d shapes, %d hues" % [fields.size(), colors.size()])
	quit()


func _hex_of(id: String) -> String:
	var scene: PackedScene = load(DIR + PREFIX + id + ".glb")
	var root: Node = scene.instantiate()
	var mi: MeshInstance3D = _first_mesh(root)
	var mat: BaseMaterial3D = mi.get_active_material(0) as BaseMaterial3D if mi != null else null
	var c: Color = mat.albedo_color if mat != null else Color.MAGENTA
	root.free()
	return "#" + c.to_html(false)


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for ch: Node in n.get_children():
		var m: MeshInstance3D = _first_mesh(ch)
		if m != null:
			return m
	return null


func _warn_reserved(id: String, c: Color) -> void:
	if c.s < MIN_SATURATION:
		return
	for r: float in RESERVED_HUES:
		var d: float = absf(c.h * 360.0 - r)
		d = minf(d, 360.0 - d)
		if d <= RESERVED_TOLERANCE_DEG:
			push_warning("WARNING: %s colour #%s is %.0f deg from reserved hue %.0f" % [id, c.to_html(false), d, r])
			print("WARNING: %s #%s within %.0f deg of reserved hue %.0f" % [id, c.to_html(false), d, r])


func _write(path: String, data: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t", true) + "\n")
	f.close()
