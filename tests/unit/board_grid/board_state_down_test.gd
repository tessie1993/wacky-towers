extends GdUnitTestSuite


func test_tokens_map_to_enum() -> void:
	for i: int in range(6):
		assert_int(BoardState.down_from_token(BoardState.DOWN_TOKENS[i])).is_equal(i)
	assert_int(BoardState.down_from_token("-y")).is_equal(BoardState.Down.Y_NEG)


func test_bad_tokens_are_minus_one() -> void:
	for t: String in ["y", "-Y", " -y", "", "+w"]:
		assert_int(BoardState.down_from_token(t)).is_equal(-1)


func test_down_vectors_all_six() -> void:
	assert_vector(BoardState.down_vector_of(BoardState.Down.X_NEG)).is_equal(Vector3i(-1, 0, 0))
	assert_vector(BoardState.down_vector_of(BoardState.Down.X_POS)).is_equal(Vector3i(1, 0, 0))
	assert_vector(BoardState.down_vector_of(BoardState.Down.Y_NEG)).is_equal(Vector3i(0, -1, 0))
	assert_vector(BoardState.down_vector_of(BoardState.Down.Y_POS)).is_equal(Vector3i(0, 1, 0))
	assert_vector(BoardState.down_vector_of(BoardState.Down.Z_NEG)).is_equal(Vector3i(0, 0, -1))
	assert_vector(BoardState.down_vector_of(BoardState.Down.Z_POS)).is_equal(Vector3i(0, 0, 1))


func test_down_vector_bad_value_is_zero() -> void:
	for d: int in [-1, 6]:
		assert_bool(BoardState.down_vector_of(d) == Vector3i.ZERO).is_true()
