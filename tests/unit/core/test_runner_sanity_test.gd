# Proves the gdUnit4 runner loads and executes on this Godot version.
# Delete once real system tests exist.
extends GdUnitTestSuite


func test_runner_executes_returns_true() -> void:
	assert_bool(true).is_true()
