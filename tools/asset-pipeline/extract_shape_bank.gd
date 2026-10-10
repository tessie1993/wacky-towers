extends SceneTree
## Shape bank extractor (ADR-0003, CH-047). Reads the cube children of every
## blk_<set>_<shape_id>.glb piece scene and writes res://assets/data/shapes/shape_bank.tres.
## Run after `--import`:
##   godot --headless -s tools/asset-pipeline/extract_shape_bank.gd -- --set=candy_toy
## or from the editor: `load("res://tools/asset-pipeline/extract_shape_bank.gd").extract("candy_toy")`.
## Hand fields (family, hue, motif) come from shape_hand_fields.json; empty ones keep the old bank's.
## Nothing is written if any shape fails a check (connected, no duplicate cubes, no rotation twins).

const BLOCKS_DIR := "res://assets/models/blocks/"
const BANK_PATH := "res://assets/data/shapes/shape_bank.tres"
const HAND_PATH := "res://assets/data/shapes/shape_hand_fields.json"
const DEFAULT_SET := "candy_toy"
const DIRS: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 1, 0),
	Vector3i(0, -1, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]


func _init() -> void:
	var set_name: String = DEFAULT_SET
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--set="):
			set_name = arg.trim_prefix("--set=")
	var errors: Array[String] = extract(set_name)
	for e: String in errors:
		push_error(e)
	quit(1 if not errors.is_empty() else 0)


## Extracts `set_name` and saves the bank. Returns error strings; empty means the file was written.
static func extract(set_name: String = DEFAULT_SET) -> Array[String]:
	var errors: Array[String] = []
	var hand: Dictionary = _read_json(HAND_PATH)
	var old: ShapeBank = null
	if ResourceLoader.exists(BANK_PATH):
		old = load(BANK_PATH) as ShapeBank
	var bank: ShapeBank = ShapeBank.new()
	var seen: Dictionary = {}  # canonical key -> shape_id
	var dir: String = BLOCKS_DIR + set_name + "/"
	var files: PackedStringArray = DirAccess.get_files_at(dir)
	files.sort()
	var prefix: String = "blk_%s_" % set_name
	for file: String in files:
		if file.get_extension() != "glb" or not file.begins_with(prefix):
			continue
		var id: String = file.get_basename().trim_prefix(prefix)
		if id.begins_with("cube"):
			continue
		var raw: Array[Vector3i] = _cube_offsets(dir + file, errors)
		var problem: String = check(raw)
		if problem != "":
			errors.append("%s: %s" % [id, problem])
			continue
		var pivot: Vector3i = pick_pivot(raw)
		var rebased: Array[Vector3i] = []
		for v: Vector3i in raw:
			rebased.append(v - pivot)
		var key: String = ShapeDef.canonical_key(rebased)
		if seen.has(key):
			errors.append("%s: same shape as %s up to rotation" % [id, seen[key]])
			continue
		seen[key] = id
		var def: ShapeDef = ShapeDef.build(StringName(id), rebased, pivot)
		var prev: ShapeDef = null
		if old != null:
			prev = old.get_shape(def.shape_id)
		_apply_hand(def, hand.get(id, {}), prev)
		bank.shapes.append(def)
	if not errors.is_empty():
		return errors
	var err: Error = ResourceSaver.save(bank, BANK_PATH)
	if err != OK:
		errors.append("save %s failed: %s" % [BANK_PATH, error_string(err)])
	return errors


## Pivot rule (audit B2): the cube nearest the bbox centre; ties go to smallest x, then y, then z.
## Usage: `pick_pivot([Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(2,0,0)])` is (1,0,0). Empty gives ZERO.
static func pick_pivot(cubes: Array[Vector3i]) -> Vector3i:
	if cubes.is_empty():
		return Vector3i.ZERO
	var lo: Vector3i = cubes[0]
	var hi: Vector3i = cubes[0]
	for v: Vector3i in cubes:
		lo = Vector3i(mini(lo.x, v.x), mini(lo.y, v.y), mini(lo.z, v.z))
		hi = Vector3i(maxi(hi.x, v.x), maxi(hi.y, v.y), maxi(hi.z, v.z))
	var c2: Vector3i = lo + hi  # twice the centre, stays integer
	var best: Vector3i = cubes[0]
	var best_d: int = -1
	for v: Vector3i in cubes:
		var diff: Vector3i = v * 2 - c2
		var d: int = diff.x * diff.x + diff.y * diff.y + diff.z * diff.z
		if best_d < 0 or d < best_d or (d == best_d and _before(v, best)):
			best = v
			best_d = d
	return best


## "" if the cube set is non-empty, duplicate-free and face-connected; otherwise the reason.
## Usage: `check([Vector3i(0,0,0), Vector3i(2,0,0)])` is "not face-connected".
static func check(cubes: Array[Vector3i]) -> String:
	if cubes.is_empty():
		return "no cubes"
	var present: Dictionary = {}
	for v: Vector3i in cubes:
		if present.has(v):
			return "duplicate cube at %s" % v
		present[v] = true
	var reached: Dictionary = {cubes[0]: true}
	var stack: Array[Vector3i] = [cubes[0]]
	while not stack.is_empty():
		var cur: Vector3i = stack.pop_back()
		for d: Vector3i in DIRS:
			var n: Vector3i = cur + d
			if present.has(n) and not reached.has(n):
				reached[n] = true
				stack.append(n)
	return "" if reached.size() == cubes.size() else "not face-connected"


static func _before(a: Vector3i, b: Vector3i) -> bool:
	if a.x != b.x:
		return a.x < b.x
	if a.y != b.y:
		return a.y < b.y
	return a.z < b.z


static func _cube_offsets(path: String, errors: Array[String]) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		errors.append("%s: failed to load (run --import first)" % path)
		return out
	var root: Node = scene.instantiate()
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			out.append(Vector3i((child as Node3D).position.round()))
	root.free()
	return out


static func _apply_hand(def: ShapeDef, hand: Dictionary, old: ShapeDef) -> void:
	if old != null:
		def.display_name = old.display_name
		def.family = old.family
		def.hue_id = old.hue_id
		def.motif = old.motif
		def.tags = old.tags
	if String(hand.get("family", "")) != "":
		def.family = StringName(hand["family"])
	if int(hand.get("hue", 0)) != 0:
		def.hue_id = int(hand["hue"])
	if String(hand.get("motif", "")) != "":
		def.motif = StringName(hand["motif"])


static func _read_json(path: String) -> Dictionary:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
