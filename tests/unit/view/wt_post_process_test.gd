extends GdUnitTestSuite
## Post-process data contract: every biome resolves a complete, shader-valid value set.

func test_every_biome_has_complete_post_values() -> void:
	for biome: StringName in [&"meadow", &"candy", &"ice", &"underwater", &"lava", &"forest", &"cave", &"clockwork", &"neon", &"celestial", &"carnival", &"pirate", &"dune"]:
		var v: Dictionary = WtPostProcess.values_for(biome)
		for key: String in WtPostProcess.DEFAULTS:
			assert_bool(v.has(key)).is_true()
		assert_float(float(v.vignette_strength)).is_between(0.0, 1.0)

func test_sparkle_pool_is_bounded() -> void:
	var fx: WtSparkleFx = auto_free(WtSparkleFx.new())
	add_child(fx)
	fx.sparkle(Vector3.ZERO, Color.WHITE, 500)
	assert_int(fx.active_count()).is_equal(WtSparkleFx.POOL)
	fx.step(5.0)
	assert_int(fx.active_count()).is_equal(0)
