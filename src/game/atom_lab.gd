extends Node3D
## Reusable single-atom demonstration authored through the Godot AI addon.
const Syrup := preload("res://src/mechanics/behaviour/syrup_band.gd")
var _api: RuleApi
var _piece: ActivePiece
var _rule: RuleBehaviour
var _cube: MeshInstance3D
var _clock: float = 0.0
var _fall: float = 0.0
var _resting: bool = false


func _ready() -> void:
	var catalog: GameCatalog = WtContent.new().load_catalog()
	var spec := BoardSpec.new()
	spec.size = Vector3i(6, 8, 4)
	spec.h_play = 4
	spec.down = BoardState.Down.Y_NEG
	var board := BoardState.new(spec, catalog.content)
	_api = RuleApi.new(board, KnobRegistry.new(catalog.knob_defs, {}), {"band_rows": [1, 2], "syrup_slow": 0.5, "syrup_glide": 2})
	_api.configure(catalog, 25, &"atom_lab")
	for x: int in 6:
		for z: int in 4:
			var tile := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.92, 0.08, 0.92)
			tile.mesh = mesh
			var material := StandardMaterial3D.new()
			material.albedo_color = Color("c98335") if z == 1 or z == 2 else Color("80afba")
			tile.material_override = material
			tile.position = Vector3(x, -0.1, z)
			add_child(tile)
	_cube = MeshInstance3D.new()
	var cube_mesh := BoxMesh.new()
	cube_mesh.size = Vector3.ONE * 0.85
	_cube.mesh = cube_mesh
	var cube_material := StandardMaterial3D.new()
	cube_material.albedo_color = Color("f7dfab")
	_cube.material_override = cube_material
	add_child(_cube)
	var camera: Camera3D = $Camera3D
	camera.position = Vector3(8, 8, 9)
	camera.look_at(Vector3(2.5, 1, 1.5))
	$DirectionalLight3D.rotation_degrees = Vector3(-55, -30, 0)
	$Overlay/Hint.text = "SYRUP ATOM LAB · amber rows slow and glide
WASD move · Space drop · R reset"
	$Overlay/Hint.position = Vector2(24, 24)
	_reset()


func _reset() -> void:
	_piece = ActivePiece.new(ShapeDef.build(&"lab_cube", [Vector3i.ZERO]), Vector3i(0, 6, 1))
	_api.bind_piece(_piece)
	_rule = Syrup.new()
	_rule.handle(&"on_spawn", HookContext.new(), _api)
	_resting = false
	_fall = 0.0


func _physics_process(delta: float) -> void:
	_clock += delta
	while _clock >= 0.1:
		_clock -= 0.1
		if not _resting:
			_rule.handle(&"on_tick", HookContext.new(), _api)
			_fall += float(_rule.snapshot()["gravity_scale"]) / 1000.0 * 0.1
			if _fall >= 0.5:
				_fall -= 0.5
				if int(_api.try_translate(Vector3i.DOWN).get("result")) != Movement.Result.OK:
					_land()
	_cube.position = Vector3(_piece.pivot) + Vector3(0, 0.5, 0)


func _land() -> void:
	_rule.handle(&"on_land", HookContext.new(), _api)
	_resting = true


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_R:
			_reset()
		KEY_SPACE:
			if not _resting:
				_piece.pivot += Vector3i.DOWN * _api.cast(_piece.cells(), Vector3i.DOWN)
				_land()
		KEY_A, KEY_D, KEY_W, KEY_S:
			if not _resting:
				var dir: Vector3i = Vector3i.LEFT if event.physical_keycode == KEY_A else (Vector3i.RIGHT if event.physical_keycode == KEY_D else (Vector3i(0, 0, -1) if event.physical_keycode == KEY_W else Vector3i(0, 0, 1)))
				_api.try_translate(dir)
