extends GdUnitTestSuite
## Runtime coverage of campaign data, earned-star gates, economy bounds and crash-safe profiles.

func test_all_official_levels_validate_and_main_path_has_one_hundred() -> void:
	var content: WtContent = WtContent.new()
	content.load_catalog()
	assert_array(content.errors).is_empty()
	var mains: int = 0
	for entry: Dictionary in content.all_levels():
		if int(entry.tier) <= 10: mains += 1
		assert_object(content.level(str(entry.id))).is_not_null()
	assert_int(mains).is_equal(100)

func test_next_biome_requires_finale_and_fifteen_earned_stars() -> void:
	var records: Dictionary = {"meadow_10": {"stars": 1}}
	var order: Array = ["meadow", "candy"]
	assert_bool(WtProgression.biome_open(records, "candy", order)).is_false()
	for i: int in range(1, 8): records["meadow_%02d" % i] = {"stars": 2}
	assert_bool(WtProgression.biome_open(records, "candy", order)).is_true()
	records.erase("meadow_10")
	assert_bool(WtProgression.biome_open(records, "candy", order)).is_false()

func test_profiles_keep_best_stars_and_replay_pays_once() -> void:
	var io: MemorySaveIO = MemorySaveIO.new()
	var store: WtProfileStore = WtProfileStore.new(io)
	assert_int(store.create("Mia")).is_equal(0)
	assert_int(store.record_result("meadow_03", 2, 150000, 100).award).is_equal(2)
	assert_int(store.record_result("meadow_03", 3, 100000, 200).award).is_equal(1)
	assert_int(store.record_result("meadow_03", 2, 200000, 50).award).is_equal(1)
	assert_int(store.record_result("meadow_03", 3, 90000, 250).award).is_equal(0)
	assert_int(store.progress().levels.meadow_03.stars).is_equal(3)
	assert_int(store.progress().levels.meadow_03.best_ms).is_equal(90000)
	assert_int(store.wallet_balance()).is_equal(4)
	var reload: WtProfileStore = WtProfileStore.new(io)
	assert_int(reload.wallet_balance()).is_equal(4)

func test_four_profiles_and_settings_are_isolated() -> void:
	var store: WtProfileStore = WtProfileStore.new(MemorySaveIO.new())
	for i: int in 4: assert_int(store.create("Builder %d" % i)).is_equal(i)
	assert_int(store.create("Fifth")).is_equal(-1)
	store.select(0)
	store.set_setting("relaxed_timing", true)
	store.set_setting("master_volume", 0.2)
	store.select(1)
	assert_bool(store.get_setting("relaxed_timing")).is_false()
	assert_float(store.get_setting("master_volume")).is_equal(0.2)

func test_buying_debits_wallet_without_lowering_earned_stars() -> void:
	var store: WtProfileStore = WtProfileStore.new(MemorySaveIO.new())
	store.create("Mia")
	store.record_result("meadow_03", 3, 100000, 200)
	assert_bool(store.purchase("potion_slow_time").ok).is_true()
	assert_int(store.wallet_balance()).is_equal(1)
	assert_int(store.progress().levels.meadow_03.stars).is_equal(3)
	assert_bool(store.undo_purchase()).is_true()
	assert_int(store.wallet_balance()).is_equal(3)

func test_tournament_majorities_sudden_death_and_award_decay() -> void:
	var modes: WtModes = WtModes.new()
	for pair: Array in [[3, 2], [5, 3], [7, 4], [13, 7]]:
		assert_int(modes.start_tournament(["Mia", "Ari"], pair[0], 42).majority).is_equal(pair[1])
	assert_int(modes.tournament_awards(5, 4, 0).win).is_equal(5)
	assert_int(modes.tournament_awards(5, 4, 0).finish).is_equal(2)
	assert_int(modes.tournament_awards(5, 4, 2).win).is_equal(3)
	assert_int(modes.tournament_awards(5, 4, 2).finish).is_equal(0)
	assert_int(modes.tournament_awards(3, 2, 4).win).is_equal(0)

func test_profile_rename_delete_and_lost_index_recovery_keep_other_progress() -> void:
	var io: MemorySaveIO = MemorySaveIO.new()
	var store: WtProfileStore = WtProfileStore.new(io)
	store.create("Mia")
	store.record_result("meadow_01", 2, 120000, 500)
	store.create("Ari")
	assert_int(store.rename(1, "mia")).is_equal(ERR_ALREADY_EXISTS)
	assert_int(store.delete(1)).is_equal(OK)
	io.write_text("user://save/index.json", "broken")
	var reload: WtProfileStore = WtProfileStore.new(io)
	assert_object(reload.list_profiles()[0]).is_not_null()
	assert_bool(reload.needs_profile_select()).is_true()
	reload.select(0)
	assert_int(int(reload.progress().levels.meadow_01.stars)).is_equal(2)

func test_disk_backup_checksum_and_newer_schema_are_recoverable() -> void:
	var path: String = "user://meta_tests/atomic_progress.json"
	var io: FileSaveIO = FileSaveIO.new()
	io.delete("user://meta_tests")
	assert_int(io.write_text(path, JSON.stringify({"stars": 2}))).is_equal(OK)
	assert_int(io.write_text(path, JSON.stringify({"stars": 3}))).is_equal(OK)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("corrupt")
	file.close()
	assert_int(int(JSON.parse_string(io.read_text(path)).stars)).is_equal(2)
	assert_str(io.recovered[path]).is_equal(".bak")
	var payload: Dictionary = {"stars": 3, "unknown_future_key": [1, 2]}
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema": 999, "payload": payload, "checksum": JSON.stringify(payload, "", true).sha256_text()}))
	file.close()
	assert_int(int(JSON.parse_string(io.read_text(path)).stars)).is_equal(3)
	assert_int(io.write_text(path, "{}")).is_equal(ERR_UNAUTHORIZED)
	io.delete("user://meta_tests")

func test_shared_level_unknown_goal_rule_and_schema_are_refused() -> void:
	var content: WtContent = WtContent.new()
	content.load_catalog()
	var source: Dictionary = content.raw_level("meadow_01")
	source["schema"] = 999
	assert_bool(LevelLoader.parse_level(source, content.catalog).ok()).is_false()
	source["schema"] = 1
	source["goal"] = {"type": "execute_script"}
	assert_bool(LevelLoader.parse_level(source, content.catalog).ok()).is_false()
	source["goal"] = {"type": "clear_n", "n": 1}
	source["rules"] = [{"id": "load_user_resource", "params": {}}]
	assert_bool(LevelLoader.parse_level(source, content.catalog).ok()).is_false()

func test_inventory_consumption_persists_only_after_explicit_commit() -> void:
	var io: MemorySaveIO = MemorySaveIO.new()
	var store: WtProfileStore = WtProfileStore.new(io)
	store.create("Mia")
	store.record_result("meadow_03", 3, 100000, 200)
	assert_bool(store.purchase("potion_slow_time").ok).is_true()
	assert_bool(store.consume_potion("potion_slow_time")).is_true()
	assert_bool(store.consume_potion("potion_slow_time")).is_false()
	store.set_playing(true)
	assert_bool(store.commit_inventory()).is_false()
	store.set_playing(false)
	assert_bool(store.commit_inventory()).is_true()
	var reload: WtProfileStore = WtProfileStore.new(io)
	assert_int(int(reload.progress().inventory.potions.get("potion_slow_time", 0))).is_equal(0)

func test_tournament_uses_selected_supported_round_pool() -> void:
	var content: WtContent = WtContent.new()
	content.load_catalog()
	var modes: WtModes = WtModes.new(content)
	assert_bool(modes.set_round_pool(["height_race"])).is_true()
	assert_bool(modes.set_round_pool(["unimplemented_round"])).is_false()
	assert_bool(modes.start_tournament(["Mia", "Ari"], 13, 42).ok).is_true()
	var level: LevelData = modes.next_round_level()
	assert_object(level).is_not_null()
	assert_str(str(level.goal.type)).is_equal("height")
	assert_str(str(modes.tournament_snapshot().mode)).is_equal("height_race")

func test_structured_goal_selects_the_matching_strategy_slot() -> void:
	var content: WtContent = WtContent.new()
	content.load_catalog()
	for id: String in ["meadow_01", "meadow_05", "meadow_06", "meadow_bonus"]:
		var level: LevelData = content.level(id)
		assert_str(str(level.knobs[&"goal.type"])).is_equal(str(level.goal.type))

func test_failed_attempt_encounters_persist_without_currency_or_duplicate_entries() -> void:
	var io := MemorySaveIO.new()
	var store := WtProfileStore.new(io)
	assert_bool(store.record_encounter("candy_09")).is_false()
	store.create("Mia")
	assert_bool(store.record_encounter("unknown_script")).is_false()
	assert_bool(store.record_encounter("candy_09")).is_true()
	assert_bool(store.record_encounter("candy_09")).is_true()
	store.set_playing(true)
	assert_bool(store.record_encounter("candy_10")).is_false()
	var reload := WtProfileStore.new(io)
	assert_array(reload.progress().encountered_levels).contains_exactly(["candy_09"])
	assert_dict(reload.progress().levels).is_empty()
	assert_int(reload.wallet_balance()).is_equal(0)
	reload.create("Ari")
	assert_array(reload.progress().encountered_levels).is_empty()

func test_user_item_tables_reject_unknown_negative_duplicate_and_zero_weight() -> void:
	var content := WtContent.new()
	content.load_catalog()
	var source: Dictionary = content.raw_level("meadow_01")
	var row: Dictionary = {"id":"bomb","weight":1.0,"bias":0.5,"debuff":false}
	source.rules = [{"id":"items","params":{"table":[row]}}]
	assert_bool(LevelLoader.parse_level(source,content.catalog).ok()).is_true()
	for invalid: Array in [
		[{"id":"execute_script","weight":1,"bias":0,"debuff":false}],
		[{"id":"bomb","weight":-1,"bias":0,"debuff":false}],
		[row,row],
		[{"id":"bomb","weight":0,"bias":0,"debuff":false}]
	]:
		source.rules[0].params.table = invalid
		assert_bool(LevelLoader.parse_level(source,content.catalog).ok()).is_false()
