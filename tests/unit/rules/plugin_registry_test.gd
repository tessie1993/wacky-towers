extends GdUnitTestSuite
## CH-022: PluginRegistry lookup by (kind, PLUGIN_ID).

const BASE_PATH := "res://src/core/rules/bases/clear_detector.gd"
const FIXTURE_PATH := "res://tests/unit/rules/fixtures/test_only_detector.gd"
const DUP_PATH := "res://tests/unit/rules/fixtures/dup_detector.gd"


func _entry(cls: String, base: String, path: String) -> Dictionary:
	return {"class": StringName(cls), "base": StringName(base), "path": path}


func _list() -> Array[Dictionary]:
	return [
		_entry("ClearDetector", "RefCounted", BASE_PATH),
		_entry("TestOnlyDetector", "ClearDetector", FIXTURE_PATH),
	]


func test_finds_fixture_by_id() -> void:
	var reg := PluginRegistry.new(_list())
	assert_bool(reg.create(&"ClearDetector", &"test_only") is TestOnlyDetector).is_true()
	assert_that(reg.ids(&"ClearDetector")).is_equal(PackedStringArray(["test_only"]))
	assert_bool(reg.errors().is_empty()).is_true()


func test_unknown_is_null() -> void:
	var reg := PluginRegistry.new(_list())
	assert_object(reg.create(&"ClearDetector", &"nope")).is_null()
	assert_object(reg.create(&"Nope", &"test_only")).is_null()
	assert_bool(reg.ids(&"Nope").is_empty()).is_true()


func test_duplicate_id_is_error() -> void:
	var l := _list()
	l.append(_entry("DupDetector", "ClearDetector", DUP_PATH))
	var reg := PluginRegistry.new(l)
	assert_int(reg.errors().size()).is_equal(1)
	assert_str(reg.errors()[0]).contains("duplicate PLUGIN_ID 'test_only'")
	assert_bool(reg.create(&"ClearDetector", &"test_only") is TestOnlyDetector).is_true()


func test_real_global_class_list() -> void:
	var reg := PluginRegistry.new(ProjectSettings.get_global_class_list())
	assert_object(reg.create(&"ClearDetector", &"test_only")).is_not_null()
	assert_bool(reg.errors().is_empty()).is_true()


func test_base_is_not_a_plugin() -> void:
	var reg := PluginRegistry.new(_list())
	assert_bool(reg.ids(&"ClearDetector").has("ClearDetector")).is_false()
	assert_bool(reg.ids(&"RuleBehaviour").is_empty()).is_true()
