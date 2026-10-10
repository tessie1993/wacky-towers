extends GdUnitTestSuite
## Catalog-authoritative tournament admission and detached snapshot contracts.
const LAN := preload("res://src/net/lan_session.gd")

func _lan() -> WtLanSession:
    return auto_free(LAN.new())

func test_legacy_empty_loadout_is_cloud_without_perks() -> void:
    var checked: Dictionary = _lan().validate_loadout({})
    assert_bool(checked.ok).is_true()
    assert_str(checked.loadout.character).is_equal("c1")
    assert_str(checked.loadout.ability_character).is_equal("cloud")
    assert_array(checked.loadout.perks).is_empty()
    assert_that(checked.loadout.effects).is_equal({})

func test_all_tournament_characters_are_valid_and_effects_are_host_derived() -> void:
    var lan: WtLanSession = _lan()
    var rows: Array = [["c1", "breeze_brake", "cloud", {"gravity_scale": 0.92}],
        ["c2", "gentle_landing", "lana", {"drop_grace_scale": 1.5}],
        ["c3", "solid_footing", "boulder", {"lock_resets_add": 3.0}],
        ["c4", "long_look", "glim", {"preview_add": 1.0}]]
    for row: Array in rows:
        var checked: Dictionary = lan.validate_loadout({"character": row[0], "perks": [row[1]],
            "owned_perks": [row[1]], "effects": {"gravity_scale": 0.001}, "edge_milli": -500})
        assert_bool(checked.ok).is_true()
        assert_str(checked.loadout.ability_character).is_equal(row[2])
        assert_that(checked.loadout.effects).is_equal(row[3])
        assert_int(checked.loadout.edge_milli).is_greater(0)

func test_unknown_unowned_wrong_character_duplicate_and_third_perks_are_rejected() -> void:
    var lan: WtLanSession = _lan()
    var invalid: Array = [{"character": "mizzle"}, {"character": 2},
        {"owned_perks": ["potion_bomb"]}, {"owned_perks": ["breeze_brake", "breeze_brake"]},
        {"character": "c1", "perks": ["breeze_brake"], "owned_perks": []},
        {"character": "c2", "perks": ["breeze_brake"], "owned_perks": ["breeze_brake"]},
        {"character": "c1", "perks": ["breeze_brake", "breeze_brake"], "owned_perks": ["breeze_brake"]},
        {"character": "c1", "perks": ["breeze_brake", "patient_hands", "quick_study"],
            "owned_perks": ["breeze_brake", "patient_hands", "quick_study"]},
        {"perks": "breeze_brake"}, {"owned_perks": [100]}]
    for payload: Dictionary in invalid:
        assert_bool(lan.validate_loadout(payload).ok).is_false()
    assert_bool(lan.validate_loadout({"character": "c4", "perks": [], "owned_perks": []}).ok).is_true()

func test_perk_edge_budget_applies_even_if_future_catalog_adds_stronger_entries() -> void:
    var lan: WtLanSession = _lan()
    lan.validate_loadout({})
    # Canonical catalog fixture: current rows max .11 together, so a stronger
    # future balance row must still obey the transport's independent .15 cap.
    var definitions: Dictionary = lan.get("_perk_catalog")
    definitions["future_perk"] = {"character": "c1", "edge": 0.10, "effect": {"preview_add": 1}}
    var excessive: Dictionary = lan.validate_loadout({"character": "c1", "perks": ["breeze_brake", "future_perk"],
        "owned_perks": ["breeze_brake", "future_perk"]})
    assert_bool(excessive.ok).is_false()
    definitions.future_perk.edge = 0.09
    var boundary: Dictionary = lan.validate_loadout({"character": "c1", "perks": ["breeze_brake", "future_perk"],
        "owned_perks": ["breeze_brake", "future_perk"]})
    assert_bool(boundary.ok).is_true()
    assert_int(boundary.loadout.edge_milli).is_equal(150)

func test_snapshot_and_loadout_accessors_do_not_expose_shared_effects() -> void:
    var lan: WtLanSession = _lan()
    var checked: Dictionary = lan.validate_loadout({"character": "c1", "perks": ["breeze_brake", "patient_hands"],
        "owned_perks": ["patient_hands", "breeze_brake", "long_look"]})
    lan.set("_players", {1: "Cloud"})
    lan.set("_loadouts", {1: checked.loadout.duplicate(true)})
    var first: Dictionary = lan.snapshot()
    first.players[0].loadout.effects.gravity_scale = 0.001
    first.players[0].perks.clear()
    var detached: Dictionary = lan.player_loadout(1)
    detached.effects.lock_delay_scale = 500
    var current: Dictionary = lan.player_loadout(1)
    assert_float(current.effects.gravity_scale).is_equal(0.92)
    assert_float(current.effects.lock_delay_scale).is_equal(1.25)
    assert_array(current.perks).is_equal(["breeze_brake", "patient_hands"])
    assert_array(current.owned_perks).is_equal(["breeze_brake", "long_look", "patient_hands"])

func test_invalid_public_host_join_loadout_cannot_replace_live_session() -> void:
    var lan: WtLanSession = _lan()
    lan.active = true
    lan.hosting = true
    var invalid: Dictionary = {"character": "unknown"}
    assert_int(lan.host("Cloud", 24680, 3, invalid)).is_equal(ERR_INVALID_PARAMETER)
    assert_int(lan.join("127.0.0.1", "Cloud", 24680, invalid)).is_equal(ERR_INVALID_PARAMETER)
    assert_bool(lan.active).is_true()
    assert_bool(lan.hosting).is_true()
    assert_bool(lan.validate_loadout({"metadata": "x".repeat(LAN.MAX_LOADOUT_BYTES)}).ok).is_false()
