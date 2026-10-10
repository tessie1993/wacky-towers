extends GdUnitTestSuite
## WtMinigameArt: every party theme (MG01-MG36) builds a toy, and normalize() maps ids and names.

const Art := preload("res://src/view/wt_minigame_art.gd")


func test_every_theme_builds_a_toy_with_meshes() -> void:
	assert_int(Art.THEMES.size()).is_equal(36)
	for id: String in Art.THEMES:
		var toy: Node3D = Art.create(id)
		assert_str(str(toy.get_meta("minigame_id"))).is_equal(id)
		assert_str(str(toy.get_meta("asset_id"))).is_equal("party_%s_%s" % [id, Art.THEMES[id].prop])
		# The base plate alone is one mesh; each toy must add its own geometry on top.
		assert_int(toy.find_children("*", "MeshInstance3D", true, false).size()).is_greater(5)
		toy.free()


func test_normalize_ids_and_names() -> void:
	assert_str(Art.normalize("MG_22")).is_equal("mg22")
	assert_str(Art.normalize("mg36")).is_equal("mg36")
	assert_str(Art.normalize("mg5")).is_equal("mg05")
	assert_str(Art.normalize("crane_tower")).is_equal("mg05")
	assert_str(Art.normalize("Whack-a-Block")).is_equal("mg32")
	assert_str(Art.normalize("Mirror Mirror")).is_equal("mg30")
	assert_str(Art.normalize("mg99")).is_equal("mg01")
	assert_str(Art.normalize("unknown")).is_equal("mg01")


func test_wave2_manifest_lists_every_new_toy() -> void:
	var ids: Array[String] = []
	for entry: Dictionary in Art.asset_manifest():
		ids.append(str(entry.minigame))
	for n: int in range(22, 37):
		assert_bool(ids.has("mg%02d" % n)).is_true()
