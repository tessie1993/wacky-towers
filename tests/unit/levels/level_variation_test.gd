extends GdUnitTestSuite
## LevelVariation (per-attempt layout variant) and Spawner bag fairness.
## Pure: fixtures are built by factory functions below, no file I/O.

const NONFILL := "R"


## Variation config fixture mirroring assets/data/variation/variation_rules.json.
func _config() -> Dictionary:
	return {
		"symmetries": ["identity", "mirror_x", "mirror_z", "rot90", "rot180", "rot270", "transpose", "anti_transpose"],
		"square_only": ["rot90", "rot270", "transpose", "anti_transpose"],
		"defaults": {"jitter_radius": 1, "keep_spawn_clear": true, "rule_tiles": true},
		"limits": {"jitter_radius_max": 2, "validator_seed_samples": 4},
		"rule_params": {"rock_obstacle": {"cells": "cells_xyz"}, "quicksand": {"tiles": "tiles_xz"}, "gust": {"wind_dir": "dir"}},
		"positional_rules": ["magnet_pull"],
	}


## 8x8 level with one rock column at (1,1), a quicksand tile at (6,6) and a +x wind.
func _raw(jitter: bool) -> Dictionary:
	var empty_row: String = "........"
	var rock_row: String = ".R......"
	var rows: Array = [empty_row, rock_row, empty_row, empty_row, empty_row, empty_row, empty_row, empty_row]
	var raw: Dictionary = {
		"id": "fixture_variation", "goal": {"type": "clear_n", "n": 2},
		"board": {"width": 8, "depth": 8, "h_play": 6, "starting_contents": {"layers": {"0": rows.duplicate(), "1": rows.duplicate()}}},
		"pieces": {"shapes": ["o"]},
		"rules": [
			{"id": "rock_obstacle", "params": {"cells": [[1, 0, 1], [1, 1, 1]]}},
			{"id": "quicksand", "params": {"tiles": [[6, 6]]}},
			{"id": "gust", "params": {"wind_dir": "+x"}},
		],
		"variation": {"symmetries": ["identity", "rot90", "mirror_x"]},
	}
	if jitter:
		raw.variation["jitter"] = {"glyphs": "R", "radius": 1}
	return raw


func _rock_cells(raw: Dictionary) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for key: String in raw.board.starting_contents.layers:
		var rows: Array = raw.board.starting_contents.layers[key]
		for z: int in rows.size():
			for x: int in str(rows[z]).length():
				if str(rows[z])[x] == "R":
					cells.append(Vector3i(x, int(key), z))
	cells.sort()
	return cells


func _param_cells(raw: Dictionary) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for c: Array in raw.rules[0].params.cells:
		cells.append(Vector3i(int(c[0]), int(c[1]), int(c[2])))
	cells.sort()
	return cells


func test_apply_without_block_returns_identity() -> void:
	var raw: Dictionary = _raw(false)
	raw.erase("variation")
	var out: Dictionary = LevelVariation.apply(raw, 99, _config(), NONFILL)
	assert_str(out.symmetry).is_equal("identity")
	assert_dict(out.raw).is_equal(raw)


func test_apply_same_seed_same_variant() -> void:
	var a: Dictionary = LevelVariation.apply(_raw(true), 4242, _config(), NONFILL)
	var b: Dictionary = LevelVariation.apply(_raw(true), 4242, _config(), NONFILL)
	assert_dict(a.raw).is_equal(b.raw)
	assert_bool(a.raw.has("variation")).is_false()


func test_rot90_moves_layout_rule_cells_and_wind_together() -> void:
	var out: Dictionary = LevelVariation.apply(_raw(false), 1, _config(), NONFILL, "rot90")
	# rot90: (x, z) -> (D-1-z, x); rock (1,1) -> (6,1); tile (6,6) -> (1,6); +x -> +z.
	assert_array(_rock_cells(out.raw)).is_equal([Vector3i(6, 0, 1), Vector3i(6, 1, 1)])
	assert_array(_param_cells(out.raw)).is_equal(_rock_cells(out.raw))
	assert_array(out.raw.rules[1].params.tiles).is_equal([[1, 6]])
	assert_str(out.raw.rules[2].params.wind_dir).is_equal("+z")


func test_mirror_x_flips_wind_direction() -> void:
	var out: Dictionary = LevelVariation.apply(_raw(false), 1, _config(), NONFILL, "mirror_x")
	assert_str(out.raw.rules[2].params.wind_dir).is_equal("-x")


func test_jitter_keeps_rule_cells_on_rocks_for_many_seeds() -> void:
	for attempt_seed: int in 32:
		var out: Dictionary = LevelVariation.apply(_raw(true), attempt_seed, _config(), NONFILL)
		assert_array(_param_cells(out.raw)).is_equal(_rock_cells(out.raw))


func test_jitter_moves_something_for_some_seed() -> void:
	var moved: int = 0
	for attempt_seed: int in 16:
		moved += int(LevelVariation.apply(_raw(true), attempt_seed, _config(), NONFILL).moved)
	assert_int(moved).is_greater(0)


func test_layer_report_flags_full_layer_at_spawn() -> void:
	var full_row: String = "########"
	var board: Dictionary = {"width": 8, "depth": 8, "h_play": 4, "starting_contents": {"layers": {"0": [full_row, full_row, full_row, full_row, full_row, full_row, full_row, full_row]}}}
	var report: Dictionary = LevelVariation.layer_report(board, NONFILL)
	assert_array(Array(report.full)).is_equal([0])
	assert_str(LevelVariation.layout_ok(report, report, 1)).contains("full at spawn")


func test_layer_report_ignores_nonfill_and_requires_open_sky() -> void:
	var raw: Dictionary = _raw(false)
	var report: Dictionary = LevelVariation.layer_report(raw.board, NONFILL)
	# Rocks do not count toward a clear, and nothing covers an empty cell: every layer is clearable.
	assert_array(Array(report.full)).is_empty()
	assert_int(report.clearable.size()).is_equal(6)


func test_check_variants_rejects_positional_rule() -> void:
	var raw: Dictionary = _raw(false)
	raw.rules.append({"id": "magnet_pull", "params": {}})
	assert_array(Array(LevelVariation.check_variants(raw, _config(), "#R", NONFILL))).is_not_empty()


func test_check_variants_accepts_fixture() -> void:
	assert_array(Array(LevelVariation.check_variants(_raw(true), _config(), "#R", NONFILL))).is_empty()


func test_spawner_bag_deals_each_shape_once_per_bag() -> void:
	var shapes: PackedStringArray = PackedStringArray(["i", "o", "t", "l", "s", "z", "j"])
	var spawner: Spawner = Spawner.new({"shapes": shapes, "weights": {}}, 3, 777)
	for bag: int in 4:
		var seen: Dictionary = {}
		for i: int in shapes.size():
			seen[spawner.next()] = true
		assert_int(seen.size()).is_equal(shapes.size())


func test_spawner_weights_become_bag_copies() -> void:
	var shapes: PackedStringArray = PackedStringArray(["i", "o"])
	var spawner: Spawner = Spawner.new({"shapes": shapes, "weights": {"i": 2, "o": 1}}, 1, 5)
	var count_i: int = 0
	for i: int in 9:
		count_i += 1 if spawner.next() == &"i" else 0
	assert_int(count_i).is_equal(6)


func test_spawner_same_seed_replays_sequence() -> void:
	var pieces: Dictionary = {"shapes": PackedStringArray(["i", "o", "t", "l"]), "weights": {}}
	var a: Spawner = Spawner.new(pieces, 3, 31337)
	var b: Spawner = Spawner.new(pieces, 3, 31337)
	for i: int in 20:
		assert_str(String(a.next())).is_equal(String(b.next()))
