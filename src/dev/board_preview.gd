extends Node3D
## GP-0 "Board preview" (dev only): turns a small ASCII board spec into visible blocks.
## Consumes AsciiGrid, BoardSpec (part 1), BoardLimits, ContentTypes, BoardState, CameraMath.
## Locked blocks = one MultiMeshInstance3D of the set's cube mesh (ADR-0007 §1), per-instance colour.
## Falling piece = a shape GLB instanced directly (ADR-0007 §2). Greybox StandardMaterial3D, no shader.
## Run windowed:
##   godot --path . res://src/dev/board_preview.tscn -- --set=neon_voxel --shot=res://production/qa/evidence/GP-0-board-preview.png

const BLOCKS_DIR := "res://assets/models/blocks/"
const FALLBACK_SET := "candy_toy"
const CONTENT_JSON := "res://assets/data/content/blocks.json"
const CONTENT_MAX_BYTES := 65536

## Dev-only extra content kinds so the preview can show one colour per glyph.
## blocks.json today defines only "#" (starter); these are NOT game data.
const DEV_TYPES: Array[Dictionary] = [
	{"id": "dev_grass", "kind_id": 10, "glyph": "g", "slot": "cell", "solid": true, "fills_layer": true, "hue": 1, "mesh": ""},
	{"id": "dev_stone", "kind_id": 11, "glyph": "s", "slot": "cell", "solid": true, "fills_layer": true, "hue": 2, "mesh": ""},
	{"id": "dev_flower", "kind_id": 12, "glyph": "f", "slot": "cell", "solid": true, "fills_layer": true, "hue": 3, "mesh": ""},
]

## Greybox palette by glyph (dev look only; the real palette is the shader specialist's).
const GLYPH_COLOURS: Dictionary = {
	"#": Color(0.93, 0.62, 0.36),
	"g": Color(0.45, 0.78, 0.38),
	"s": Color(0.55, 0.57, 0.66),
	"f": Color(0.95, 0.45, 0.70),
}
const UNKNOWN_COLOUR := Color(1, 0, 1)
const TILE_A := Color(0.80, 0.86, 0.72)
const TILE_B := Color(0.70, 0.78, 0.62)
const PIECE_COLOUR := Color(0.35, 0.62, 0.95)

## Meadow-like 8x8 board: corners clipped, a low starting stack.
const BOARD: Dictionary = {
	"width": 8, "depth": 8, "h_play": 10,
	"mask": [
		".######.",
		"########",
		"########",
		"########",
		"########",
		"########",
		"########",
		".######.",
	],
}
const STARTING: Dictionary = {"layers": {
	"0": [
		".gggggg.",
		"gg#ggsgg",
		"g##gssgg",
		"gg.gsggg",
		"ggg..ggf",
		"gsgg.ggg",
		"gssggg#g",
		".gggggg.",
	],
	"1": [
		"........",
		".##..s..",
		".#...ss.",
		"....s...",
		"......f.",
		".s......",
		".ss...#.",
		"........",
	],
	"2": [
		"........",
		".#......",
		"......s.",
		"........",
		"........",
		"........",
		".s......",
		"........",
	],
}}

@export_enum("candy_toy", "neon_voxel") var block_set: String = "candy_toy"
@export var piece_shape: String = "l"
@export var yaw_snap: int = 0
@export var elevation_deg: float = 30.0
@export var margin: float = 1.0
@export var camera_distance: float = 60.0

## Set name actually used for the cube mesh (may differ from block_set after fallback).
var used_set: String = ""
var spec: BoardSpec = null


func _ready() -> void:
	var shot: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--set="):
			block_set = arg.trim_prefix("--set=")
		elif arg.begins_with("--shot="):
			shot = arg.trim_prefix("--shot=")
	build()
	if shot != "":
		for i: int in 10:
			await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(shot))
		get_tree().quit()


## Parses the spec and builds floor, blocks, piece and camera. Safe to call again.
func build() -> void:
	for child: Node in get_children():
		if child.is_in_group(&"gp0_built"):
			child.free()
	var types: ContentTypes = _load_types()
	var r: BoardSpecResult = BoardSpec.parse(BOARD, BoardLimits.new(), types)
	if not r.errors.is_empty():
		push_error("GP-0: board spec errors: %s" % ", ".join(r.errors))
		return
	spec = r.spec
	var parsed: Dictionary = AsciiGrid.parse_layers(STARTING, spec.size, types.glyphs(), "board.starting_contents")
	for msg: String in parsed["errors"]:
		push_error("GP-0: " + msg)
	var cube_mesh: Mesh = _cube_mesh(block_set)
	if cube_mesh == null:
		push_error("GP-0: no cube mesh for '%s' or '%s'" % [block_set, FALLBACK_SET])
		return
	_add_floor()
	_add_blocks(parsed["cells"], cube_mesh)
	_add_piece()
	_place_camera()
	print("GP-0: set=%s (mesh from %s) size=%s cells=%d mesh_aabb=%s" % [block_set, used_set, spec.size,
			parsed["cells"].size(), cube_mesh.get_aabb()])


func _load_types() -> ContentTypes:
	var entries: Array = []
	var r: Dictionary = JsonReader.read_file(CONTENT_JSON, CONTENT_MAX_BYTES)
	if r["ok"] and r["data"].get("types") is Array:
		entries.append_array(r["data"]["types"])
	else:
		push_error("GP-0: " + str(r["error"]))
	entries.append_array(DEV_TYPES)
	var t: ContentTypes = ContentTypes.from_entries(entries)
	for msg: String in t.errors:
		push_error("GP-0: content: " + msg)
	return t


## Cube mesh of a set: blk_<set>_cube.glb, else the single-cube blk_<set>_mono.glb, else the fallback set.
func _cube_mesh(set_name: String) -> Mesh:
	for s: String in [set_name, FALLBACK_SET]:
		for stem: String in ["cube", "mono"]:
			var path: String = BLOCKS_DIR.path_join(s).path_join("blk_%s_%s.glb" % [s, stem])
			if not ResourceLoader.exists(path):
				continue
			var mesh: Mesh = _first_mesh(load(path) as PackedScene)
			if mesh != null:
				used_set = s
				if s != set_name or stem != "cube":
					push_warning("GP-0: '%s' has no cube GLB; using %s" % [set_name, path])
				return mesh
	return null


func _first_mesh(scene: PackedScene) -> Mesh:
	if scene == null:
		return null
	var root: Node = scene.instantiate()
	var mi: MeshInstance3D = root as MeshInstance3D
	if mi == null:
		var found: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
		mi = found[0] as MeshInstance3D if not found.is_empty() else null
	var mesh: Mesh = mi.mesh if mi != null else null
	root.free()
	return mesh


func _greybox_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.6
	return m


## Builds a MultiMesh; formats are set while instance_count == 0 (ADR-0007 §1).
func _multimesh(mesh: Mesh, count: int) -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = mesh
	mm.instance_count = count
	return mm


func _add_mmi(node_name: String, mm: MultiMesh) -> void:
	var mmi := MultiMeshInstance3D.new()
	mmi.name = node_name
	mmi.multimesh = mm
	mmi.material_override = _greybox_material()
	mmi.add_to_group(&"gp0_built")
	add_child(mmi)


func _add_floor() -> void:
	var w: int = spec.size.x
	var d: int = spec.size.z
	var tile := BoxMesh.new()
	tile.size = Vector3(0.96, 0.1, 0.96)
	var mm: MultiMesh = _multimesh(tile, spec.mask.count(1))
	var i: int = 0
	for z: int in d:
		for x: int in w:
			if spec.mask[x + w * z] == 0:
				continue
			mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(x + 0.5, -0.05, z + 0.5)))
			mm.set_instance_color(i, TILE_A if (x + z) % 2 == 0 else TILE_B)
			mm.set_instance_custom_data(i, Color(0, 0, 0, 1))
			i += 1
	_add_mmi("Floor", mm)


func _add_blocks(cells: Array, mesh: Mesh) -> void:
	var w: int = spec.size.x
	var drawn: Array[Dictionary] = []
	for c: Dictionary in cells:
		var cell: Vector3i = c["cell"]
		if spec.mask[cell.x + w * cell.z] == 1:
			drawn.append(c)
		else:
			push_warning("GP-0: content at masked cell %s skipped" % cell)
	var mm: MultiMesh = _multimesh(mesh, drawn.size())
	for i: int in drawn.size():
		var cell: Vector3i = drawn[i]["cell"]
		mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, Vector3(cell) + Vector3.ONE * 0.5))
		mm.set_instance_color(i, GLYPH_COLOURS.get(drawn[i]["glyph"], UNKNOWN_COLOUR))
		mm.set_instance_custom_data(i, Color(0, 0, 0, 1))  # motif, status, phase, fade = 1 (ADR-0007 table)
	_add_mmi("LockedBlocks", mm)


## One falling piece above the spawn anchor, instanced straight from the candy_toy shape GLB.
func _add_piece() -> void:
	var path: String = BLOCKS_DIR.path_join(FALLBACK_SET).path_join("blk_%s_%s.glb" % [FALLBACK_SET, piece_shape])
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		push_error("GP-0: cannot load piece " + path)
		return
	var piece: Node3D = scene.instantiate() as Node3D
	piece.name = "FallingPiece"
	var mat := StandardMaterial3D.new()
	mat.albedo_color = PIECE_COLOUR
	mat.roughness = 0.6
	for n: Node in piece.find_children("*", "MeshInstance3D", true, false):
		(n as MeshInstance3D).material_override = mat
	var a: Vector2i = spec.spawn_anchor
	piece.position = Vector3(a.x + 0.5, spec.h_play - 3 + 0.5, a.y + 0.5)
	piece.add_to_group(&"gp0_built")
	add_child(piece)


## Orthographic camera on the yaw convention of CameraRig: right = (sin yaw, 0, cos yaw).
func _place_camera() -> void:
	var cam: Camera3D = $Camera3D
	var yaw: float = deg_to_rad(CameraMath.yaw_degrees(yaw_snap, CameraMath.DEFAULT_BASE_DEG, CameraMath.DEFAULT_STEP_DEG))
	var elev: float = deg_to_rad(elevation_deg)
	var centre: Vector3 = Vector3(spec.size) * 0.5
	var forward_flat := Vector3(cos(yaw), 0.0, -sin(yaw))
	var offset: Vector3 = -forward_flat * cos(elev) * camera_distance + Vector3.UP * sin(elev) * camera_distance
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.far = camera_distance * 3.0
	var vs: Vector2 = get_viewport().get_visible_rect().size
	cam.size = CameraMath.ortho_size(spec.size, elevation_deg, vs.x / vs.y, margin)
	cam.look_at_from_position(centre + offset, centre)
