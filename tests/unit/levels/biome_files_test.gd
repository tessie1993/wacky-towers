extends GdUnitTestSuite
## Tests for the biome file and the level JSON files it lists (CH-039). Reads real res:// files.

const BIOME_PATH := "res://assets/data/biomes/meadow.json"


## Reads the meadow biome file and returns its data dictionary.
func _biome() -> Dictionary:
	var r: Dictionary = JsonReader.read_file(BIOME_PATH, JsonReader.DEFAULT_MAX_BYTES)
	assert_bool(r["ok"]).override_failure_message(str(r["error"])).is_true()
	return r["data"]


## Biome file has the required keys, a non-empty levels list, and unique level ids.
func test_meadow_biome_parses() -> void:
	var biome: Dictionary = _biome()
	for key: String in ["id", "art_set", "palette", "levels"]:
		assert_bool(biome.has(key)).override_failure_message("missing key " + key).is_true()
	var levels: Array = biome["levels"]
	assert_array(levels).is_not_empty()
	var seen: Dictionary = {}
	for entry: Variant in levels:
		var level_id: String = (entry as Dictionary)["id"]
		assert_bool(seen.has(level_id)).override_failure_message("duplicate level id " + level_id).is_false()
		seen[level_id] = true


## Every listed level JSON reads OK and its own id equals the id the biome lists.
func test_level_json_exists() -> void:
	for entry: Variant in _biome()["levels"]:
		var listed: Dictionary = entry
		var r: Dictionary = JsonReader.read_file(listed["json"], JsonReader.DEFAULT_MAX_BYTES)
		assert_bool(r["ok"]).override_failure_message(str(r["error"])).is_true()
		assert_str(r["data"].get("id", "")).is_equal(listed["id"])


## The biome's art_set names an existing block model folder.
func test_art_set_dir_exists() -> void:
	var art_set: String = _biome()["art_set"]
	assert_bool(DirAccess.dir_exists_absolute("res://assets/models/blocks/" + art_set)).is_true()
