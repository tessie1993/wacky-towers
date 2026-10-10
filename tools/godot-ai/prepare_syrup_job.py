"""Prepare exact source payloads; the relay/addon creates the game files."""
import json
from pathlib import Path

rule = '''class_name SyrupBandRule extends RuleBehaviour
## EV25: slow above authored rows, glide once on landing, then lock.
const PLUGIN_ID := &"syrup_band"
var _glided: bool = false
var _gravity_scale: int = -1
var _preview: String = ""


func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_tick", &"on_land"]


func handle(hook: StringName, _ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		api.emit(&"syrup_band", {"rows": api.param(&"band_rows", [1, 2]), "direction": _direction(api)})
		return
	if hook == &"on_spawn":
		_glided = false
		_preview = ""
	if hook == &"on_spawn" or hook == &"on_tick":
		var cells: Array[Vector3i] = api.piece_cells()
		if cells.is_empty():
			return
		var scale_value: int = int(roundf(clampf(float(api.param(&"syrup_slow", 0.5)), 0.1, 1.0) * 1000.0)) if _over_band(cells, api) else 1000
		if scale_value != _gravity_scale:
			_gravity_scale = scale_value
			api.request_slot(&"fall.gravity_scale", scale_value)
		var predicted: Array[Vector3i] = _landing(cells, api)
		var key: String = str(predicted)
		if key != _preview:
			_preview = key
			api.emit(&"syrup_preview", {"cells": predicted, "glides": _over_band(predicted, api)})
		return
	if _glided or not _over_band(api.piece_cells(), api):
		return
	_glided = true
	var moved: int = 0
	for _step: int in clampi(int(api.param(&"syrup_glide", 2)), 0, 2):
		var result: Dictionary = api.try_translate(_direction(api))
		if int(result.get("result", Movement.Result.BLOCKED)) != Movement.Result.OK:
			break
		moved += 1
	api.set_piece_flag(&"lock_now", true)
	api.emit(&"syrup_glide", {"direction": _direction(api), "steps": moved, "cells": api.piece_cells()})


func _over_band(cells: Array[Vector3i], api: RuleApi) -> bool:
	var rows: Array = api.param(&"band_rows", [1, 2])
	for cell: Vector3i in cells:
		if rows.has(cell.z):
			return true
	return false


func _direction(api: RuleApi) -> Vector3i:
	return MechanicsCells.direction(String(api.param(&"syrup_dir", "+x")))


func _landing(cells: Array[Vector3i], api: RuleApi) -> Array[Vector3i]:
	var result: Array[Vector3i] = MechanicsCells.translated(cells, api.down_vector() * api.cast(cells, api.down_vector()))
	if _glided or not _over_band(result, api):
		return result
	for _step: int in clampi(int(api.param(&"syrup_glide", 2)), 0, 2):
		var next: Array[Vector3i] = MechanicsCells.translated(result, _direction(api))
		if not api.can_place(next):
			break
		result = next
	return result


func snapshot() -> Dictionary:
	return {"glided": _glided, "gravity_scale": _gravity_scale, "preview": _preview}
'''

tests = '''@tool
extends "res://addons/godot_ai/testing/test_suite.gd"
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Syrup := preload("res://src/mechanics/behaviour/syrup_band.gd")


func suite_name() -> String:
	return "syrup_band"


func _piece(pivot: Vector3i) -> ActivePiece:
	return ActivePiece.new(ShapeDef.build(&"lab_cube", [Vector3i.ZERO]), pivot)


func test_syrup_slows_only_authored_rows() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1, 2], "syrup_slow": 0.5})
	var piece: ActivePiece = _piece(Vector3i(0, 2, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	F.handle(rule, &"on_spawn", api)
	assert_eq(rule.snapshot()["gravity_scale"], 500)
	piece.pivot.z = 0
	F.handle(rule, &"on_tick", api)
	assert_eq(rule.snapshot()["gravity_scale"], 1000)


func test_glide_matches_preview_and_runs_once_then_requests_lock() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1], "syrup_glide": 2})
	var piece: ActivePiece = _piece(Vector3i(0, 3, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	var rng_before: int = api.rng().state
	F.handle(rule, &"on_spawn", api)
	var predicted: Array[Vector3i] = rule._landing(piece.cells(), api)
	piece.pivot += api.down_vector() * api.cast(piece.cells(), api.down_vector())
	F.handle(rule, &"on_land", api)
	assert_eq(piece.cells(), predicted)
	assert_eq(piece.pivot, Vector3i(2, 0, 1))
	F.handle(rule, &"on_land", api)
	assert_eq(piece.pivot, Vector3i(2, 0, 1))
	var lock_requested: bool = false
	for request: Dictionary in api.take_requests():
		if request.get("op") == &"piece_flag" and request.get("flag") == &"lock_now":
			lock_requested = true
	assert_true(lock_requested)
	assert_eq(api.rng().state, rng_before)


func test_blocked_glide_stops_at_first_legal_cell() -> void:
	var board: BoardState = F.board(5, 4, 4)
	F.write(board, [Vector3i(2, 0, 1)])
	var api: RuleApi = F.api(board, {"band_rows": [1], "syrup_glide": 2})
	var piece: ActivePiece = _piece(Vector3i(0, 0, 1))
	api.bind_piece(piece)
	var rule := Syrup.new()
	F.handle(rule, &"on_spawn", api)
	F.handle(rule, &"on_land", api)
	assert_eq(piece.pivot, Vector3i(1, 0, 1))


func test_dry_row_never_glides() -> void:
	var api: RuleApi = F.api(F.board(5, 4, 4), {"band_rows": [1]})
	var piece: ActivePiece = _piece(Vector3i(0, 0, 0))
	api.bind_piece(piece)
	F.handle(Syrup.new(), &"on_land", api)
	assert_eq(piece.pivot, Vector3i(0, 0, 0))
'''

lab = '''extends Node3D
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
	$Overlay/Hint.text = "SYRUP ATOM LAB · amber rows slow and glide\nWASD move · Space drop · R reset"
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
'''

actions = [
    {"tool": "script_create", "arguments": {"path": "res://src/mechanics/behaviour/syrup_band.gd", "content": rule}},
    {"tool": "filesystem_manage", "arguments": {"op": "scan", "params": {}}},
    {"tool": "script_create", "arguments": {"path": "res://tests/test_syrup_band.gd", "content": tests}},
    {"tool": "script_create", "arguments": {"path": "res://src/game/atom_lab.gd", "content": lab}},
    {"tool": "filesystem_manage", "arguments": {"op": "scan", "params": {}}},
    {"tool": "scene_manage", "arguments": {"op": "create", "params": {"path": "res://src/game/atom_lab.tscn", "root_type": "Node3D", "root_name": "AtomLab"}}},
    {"tool": "scene_open", "arguments": {"path": "res://src/game/atom_lab.tscn"}},
    {"tool": "node_create", "arguments": {"type": "Camera3D", "name": "Camera3D", "parent_path": "/AtomLab"}},
    {"tool": "node_create", "arguments": {"type": "DirectionalLight3D", "name": "DirectionalLight3D", "parent_path": "/AtomLab"}},
    {"tool": "node_create", "arguments": {"type": "CanvasLayer", "name": "Overlay", "parent_path": "/AtomLab"}},
    {"tool": "node_create", "arguments": {"type": "Label", "name": "Hint", "parent_path": "/AtomLab/Overlay"}},
    {"tool": "script_attach", "arguments": {"path": "/AtomLab", "script_path": "res://src/game/atom_lab.gd"}},
    {"tool": "scene_save", "arguments": {}},
    {"tool": "scene_get_hierarchy", "arguments": {"depth": 3}},
    {"tool": "test_run", "arguments": {"suite": "syrup_band", "verbose": True}},
]
directory = Path(__file__).resolve().parent / "jobs"
directory.mkdir(parents=True, exist_ok=True)
target = directory / "mechanics-syrup.json"
temporary = target.with_suffix(".tmp")
temporary.write_text(json.dumps({"id": "mechanics-syrup", "actions": actions}, indent=2))
temporary.replace(target)
print(target)
