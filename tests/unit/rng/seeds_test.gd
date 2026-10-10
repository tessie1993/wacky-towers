extends GdUnitTestSuite

const GOLDEN_RANGE_12345: Array[int] = [4, 3, 1, 4, 6, 5, 5, 0, 2, 1]
const GOLDEN_RANDI_12345: Array[int] = [1321476956, 17539747, 3348728241, 2863338820, 85463406, 1024873269, 4179236141, 1040420088, 2363282938, 1603148953]


func test_fnv1a_known_vectors_match_reference() -> void:
	assert_int(Seeds.fnv1a(PackedByteArray())).is_equal(0x811C9DC5)
	assert_int(Seeds.fnv1a("a".to_utf8_buffer())).is_equal(0xE40C292C)
	assert_int(Seeds.fnv1a("foobar".to_utf8_buffer())).is_equal(0xBF9CF968)


func test_derive_same_inputs_same_seed() -> void:
	assert_int(Seeds.derive(12345, ["bag", 0, 3])).is_equal(Seeds.derive(12345, ["bag", 0, 3]))


func test_derive_matches_byte_layout_from_adr() -> void:
	# round_seed LE8, then 0x1F + part: int as LE8, string as UTF-8
	var b: PackedByteArray = PackedByteArray()
	b.resize(8)
	b.encode_s64(0, 7)
	b.append(0x1F)
	b.append_array("rule".to_utf8_buffer())
	b.append(0x1F)
	var n: PackedByteArray = PackedByteArray()
	n.resize(8)
	n.encode_s64(0, 2)
	b.append_array(n)
	assert_int(Seeds.derive(7, ["rule", 2])).is_equal(Seeds.fnv1a(b))


func test_derive_different_streams_differ() -> void:
	var a: int = Seeds.derive(1, ["bag", 0, 0])
	assert_bool(a == Seeds.derive(1, ["pick", 0, 0])).is_false()
	assert_bool(a == Seeds.derive(1, ["bag", 0, 1])).is_false()
	assert_bool(a == Seeds.derive(2, ["bag", 0, 0])).is_false()
	assert_bool(a == Seeds.derive(1, ["bag", 1, 0])).is_false()


func test_derive_stringname_equals_string() -> void:
	assert_int(Seeds.derive(1, [&"slot", 5])).is_equal(Seeds.derive(1, ["slot", 5]))


func test_derive_result_is_32_bit_unsigned() -> void:
	for i: int in 50:
		var s: int = Seeds.derive(i * 7919, ["daily", 20261010 + i])
		assert_bool(s >= 0 and s <= 0xFFFFFFFF).is_true()


func test_derive_daily_stream_depends_on_date() -> void:
	assert_int(Seeds.derive(0, ["daily", 20261010])).is_equal(Seeds.derive(0, ["daily", 20261010]))
	assert_bool(Seeds.derive(0, ["daily", 20261010]) == Seeds.derive(0, ["daily", 20261011])).is_false()


func test_derive_negative_round_seed_is_stable() -> void:
	assert_int(Seeds.derive(-1, ["x"])).is_equal(Seeds.derive(-1, ["x"]))


func test_engine_rng_goldens_for_seed_12345() -> void:
	var r: RandomNumberGenerator = RandomNumberGenerator.new()
	r.seed = 12345
	for want: int in GOLDEN_RANGE_12345:
		assert_int(r.randi_range(0, 7)).is_equal(want)
	r.seed = 12345
	for want: int in GOLDEN_RANDI_12345:
		assert_int(r.randi()).is_equal(want)


func test_make_rng_same_inputs_same_sequence() -> void:
	var a: RandomNumberGenerator = Seeds.make_rng(12345, ["bag", 0, 0])
	var b: RandomNumberGenerator = Seeds.make_rng(12345, ["bag", 0, 0])
	for i: int in 20:
		assert_int(a.randi()).is_equal(b.randi())


func test_shuffle_is_permutation() -> void:
	var items: Array = [0, 1, 2, 3, 4, 5, 6, 7]
	Seeds.shuffle(Seeds.make_rng(99, ["bag", 0, 0]), items)
	var sorted: Array = items.duplicate()
	sorted.sort()
	assert_array(sorted).is_equal([0, 1, 2, 3, 4, 5, 6, 7])


func test_shuffle_fixed_seed_is_deterministic() -> void:
	var a: Array = [0, 1, 2, 3, 4, 5, 6, 7]
	var b: Array = [0, 1, 2, 3, 4, 5, 6, 7]
	Seeds.shuffle(Seeds.make_rng(99, ["bag", 0, 4]), a)
	Seeds.shuffle(Seeds.make_rng(99, ["bag", 0, 4]), b)
	assert_array(a).is_equal(b)


func test_shuffle_matches_fisher_yates_from_end_reference() -> void:
	var expected: Array = [0, 1, 2, 3, 4, 5, 6, 7]
	var r: RandomNumberGenerator = RandomNumberGenerator.new()
	r.seed = 12345
	var i: int = expected.size() - 1
	while i > 0:
		var j: int = r.randi_range(0, i)
		var t: Variant = expected[i]
		expected[i] = expected[j]
		expected[j] = t
		i -= 1
	var actual: Array = [0, 1, 2, 3, 4, 5, 6, 7]
	var r2: RandomNumberGenerator = RandomNumberGenerator.new()
	r2.seed = 12345
	Seeds.shuffle(r2, actual)
	assert_array(actual).is_equal(expected)


func test_shuffle_different_bags_differ_somewhere() -> void:
	var distinct: Dictionary = {}
	for k: int in 10:
		var a: Array = [0, 1, 2, 3, 4, 5, 6, 7]
		Seeds.shuffle(Seeds.make_rng(5, ["bag", 0, k]), a)
		distinct[str(a)] = true
	assert_int(distinct.size()).is_greater(1)


func test_bag_k_computed_directly_equals_dealt_in_order() -> void:
	var dealt: Array = []
	for k: int in 5:
		var a: Array = [0, 1, 2, 3, 4, 5, 6]
		Seeds.shuffle(Seeds.make_rng(42, ["bag", 0, k]), a)
		dealt.append(a)
	var direct: Array = [0, 1, 2, 3, 4, 5, 6]
	Seeds.shuffle(Seeds.make_rng(42, ["bag", 0, 3]), direct)
	assert_array(direct).is_equal(dealt[3])


func test_weighted_pick_respects_zero_weights_and_is_deterministic() -> void:
	var w: PackedInt32Array = PackedInt32Array([0, 3, 0, 1])
	var r: RandomNumberGenerator = Seeds.make_rng(1, ["pick", 0, 0])
	var r2: RandomNumberGenerator = Seeds.make_rng(1, ["pick", 0, 0])
	for i: int in 100:
		var p: int = Seeds.weighted_pick(r, w)
		assert_bool(p == 1 or p == 3).is_true()
		assert_int(Seeds.weighted_pick(r2, w)).is_equal(p)


func test_src_core_and_gameplay_do_not_use_global_rng() -> void:
	# Bare calls only: member calls like rng.randi() are fine.
	var banned: Array[String] = ["randi()", "randf()", "randomize()", "randf_range(", "hash("]
	for dir: String in ["res://src/core", "res://src/gameplay"]:
		for path: String in _gd_files(dir):
			var text: String = FileAccess.get_file_as_string(path)
			for line: String in text.split("\n"):
				var code: String = line.split("#")[0]
				for token: String in banned:
					var idx: int = code.find(token)
					while idx != -1:
						var prev: String = code[idx - 1] if idx > 0 else " "
						var is_member_or_part: bool = prev == "." or prev == "_" or prev.is_valid_identifier()
						assert_bool(is_member_or_part).override_failure_message(
							"%s uses global %s" % [path, token]).is_true()
						idx = code.find(token, idx + 1)


func _gd_files(dir: String) -> Array[String]:
	var out: Array[String] = []
	var d: DirAccess = DirAccess.open(dir)
	if d == null:
		return out
	for f: String in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub: String in d.get_directories():
		out.append_array(_gd_files(dir.path_join(sub)))
	return out
