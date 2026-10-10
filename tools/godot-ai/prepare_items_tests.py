"""Queue real editor-addon writes for deterministic item acceptance tests."""
import json
from pathlib import Path

SOURCE = r'''extends GdUnitTestSuite
const F := preload("res://tests/unit/mechanics/mechanics_fixture.gd")
const Items := preload("res://src/mechanics/behaviour/items.gd")

func _api(params: Dictionary = {}, players: int = 1) -> RuleApi:
	var api: RuleApi = F.api(F.board(), params, 78231)
	api.bind_item_context({"owner": 7, "players": players, "rank": 1})
	return api

func _tag(token: String = "7:10") -> Dictionary:
	return {"record": {"status": {"item": true, "item_owner": "7", "item_token": token}}, "cause": BoardState.Cause.CLEAR}

func test_spawn_frequency_one_real_cube_and_injected_stream_is_untouched() -> void:
	var rng := Seeds.make_rng(8371, ["items"])
	var tagged: int = 0
	var seen: Dictionary = {}
	for _spawn: int in 10000:
		var index: int = Items.spawn_roll(rng, 0.12, 4)
		if index >= 0:
			tagged += 1
			seen[index] = true
	assert_bool(tagged >= 1100 and tagged <= 1300).is_true()
	assert_int(seen.size()).is_equal(4)
	var before: int = rng.state
	for _spawn: int in 10000:
		assert_int(Items.spawn_roll(rng, 0.5, 4, true)).is_equal(-1)
	assert_int(rng.state).is_equal(before)

func test_f2_leader_and_trailing_debuff_shares_match_documented_table() -> void:
	for rank: int in [1, 2]:
		var rng := Seeds.make_rng(7181, ["standing", rank])
		var debuffs: int = 0
		for _roll: int in 10000:
			if Items.is_debuff(Items.roll(rng, rank, 2)):
				debuffs += 1
		var share: float = float(debuffs) / 10000.0
		assert_bool(absf(share - (0.42 if rank == 1 else 0.57)) <= 0.02).is_true()

func test_solo_never_receives_attack_items() -> void:
	var rng := Seeds.make_rng(33, ["solo"])
	for _roll: int in 10000:
		assert_bool(Items.is_debuff(Items.roll(rng, 1, 1, true))).is_false()

func test_only_clear_awards_owned_item_once_damage_rescue_and_edge_are_lost() -> void:
	var api: RuleApi = _api()
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	for cause: int in [BoardState.Cause.DAMAGE, BoardState.Cause.RESCUE, BoardState.Cause.DISPLACED]:
		var data: Dictionary = _tag()
		data.cause = cause
		F.handle(rule, &"on_clear", api, data)
	assert_bool(rule.snapshot().slots[0].is_empty()).is_true()
	F.handle(rule, &"on_clear", api, _tag())
	assert_bool(rule.snapshot().slots[0].is_empty()).is_false()
	var after: int = api.rng().state
	F.handle(rule, &"on_clear", api, _tag())
	assert_bool(rule.snapshot().slots[1].is_empty()).is_true()
	assert_int(api.rng().state).is_equal(after)

func test_collect_uses_current_standing_and_rejects_other_owner() -> void:
	var api: RuleApi = _api({}, 2)
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	var foreign: Dictionary = _tag()
	foreign.record.status.item_owner = "8"
	F.handle(rule, &"on_clear", api, foreign)
	assert_bool(rule.snapshot().slots[0].is_empty()).is_true()
	api.bind_item_context({"owner": 7, "players": 2, "rank": 2})
	var copy := RandomNumberGenerator.new()
	copy.state = api.rng().state
	var expected: StringName = Items.roll(copy, 2, 2)
	F.handle(rule, &"on_clear", api, _tag())
	assert_str(str(rule.snapshot().slots[0].id)).is_equal(str(expected))

func test_full_slots_award_fifty_points_without_replacing_inventory() -> void:
	var api: RuleApi = _api()
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	rule._slots = [{"id": &"bomb"}, {"id": &"slow_time"}]
	api.take_requests()
	F.handle(rule, &"on_clear", api, _tag())
	var requests: Array[Dictionary] = api.take_requests()
	assert_int(requests.size()).is_equal(1)
	assert_str(str(requests[0].op)).is_equal("score")
	assert_int(int(requests[0].points)).is_equal(50)
	assert_str(str(rule.snapshot().slots[0].id)).is_equal("bomb")
	assert_str(str(rule.snapshot().slots[1].id)).is_equal("slow_time")

func test_no_effect_refunds_once_and_second_attempt_consumes() -> void:
	var api: RuleApi = _api()
	api.bind_modifier_probe(func(_mods: Array[Dictionary]) -> bool: return false, PackedStringArray())
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	rule._slots[0] = {"id": &"slow_time", "refunded": false}
	rule.use_slot(0, api)
	assert_bool(rule.snapshot().slots[0].refunded).is_true()
	assert_bool(rule.snapshot().effects.is_empty()).is_true()
	rule.use_slot(0, api)
	assert_bool(rule.snapshot().slots[0].is_empty()).is_true()

func test_slot_perk_adds_capacity_immediately_and_caps_at_three() -> void:
	var api: RuleApi = _api({"slots": 1, "extra_slots": 1})
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	assert_int(rule.snapshot().slots.size()).is_equal(2)
	api._params.extra_slots = 9
	F.handle(rule, &"on_tick", api)
	assert_int(rule.snapshot().slots.size()).is_equal(3)

func test_tag_follows_one_cube_through_rotation_and_persists_on_lock() -> void:
	var api: RuleApi = _api({"p_item": 0.5})
	var shape := ShapeDef.build(&"duo", [Vector3i.ZERO, Vector3i.RIGHT])
	var piece := ActivePiece.new(shape, Vector3i(1, 0, 1), 0)
	api.bind_piece(piece)
	api.bind_piece_uid(40)
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	for _try: int in 20:
		F.handle(rule, &"on_spawn", api)
		if int(rule.snapshot().tag_index) >= 0:
			break
	assert_bool(int(rule.snapshot().tag_index) >= 0).is_true()
	piece.apply_rotation(Orientations.Axis.Y, 1)
	var cells: Array[Vector3i] = piece.cells()
	for cell: Vector3i in cells:
		api.set_cell(cell, api.kind_of(&"block"), 1, 40)
	api.flush_writes()
	F.handle(rule, &"on_lock", api, {"uid": 40, "cells": cells})
	var tagged: int = 0
	for cell: Vector3i in cells:
		if bool(api.record_at(cell).status.get("item", false)):
			tagged += 1
	assert_int(tagged).is_equal(1)

func test_swapped_shape_loses_tag_and_injected_spawn_never_tags() -> void:
	var api: RuleApi = _api({"p_item": 0.5})
	api.bind_piece(ActivePiece.new(ShapeDef.build(&"mono", [Vector3i.ZERO]), Vector3i(1, 0, 1)))
	api.bind_piece_uid(40)
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	for _try: int in 20:
		F.handle(rule, &"on_spawn", api)
		if int(rule.snapshot().tag_index) >= 0: break
	api.bind_piece(ActivePiece.new(ShapeDef.build(&"replacement", [Vector3i.ZERO]), Vector3i(1, 0, 1)))
	api.set_cell(Vector3i(1, 0, 1), api.kind_of(&"block"), 1, 40)
	api.flush_writes()
	F.handle(rule, &"on_lock", api, {"uid": 40, "cells": [Vector3i(1, 0, 1)]})
	assert_bool(api.record_at(Vector3i(1, 0, 1)).status.get("item", false)).is_false()
	api.bind_piece_flags({"injected": true})
	var before: int = api.rng().state
	F.handle(rule, &"on_spawn", api)
	assert_int(int(rule.snapshot().tag_index)).is_equal(-1)
	assert_int(api.rng().state).is_equal(before)

func test_timer_refreshes_without_stacking_and_warning_gap_does_not_expire() -> void:
	var api: RuleApi = _api({"slow_time_ms": 100})
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	assert_bool(rule.apply_effect(&"slow_time", api)).is_true()
	api.set_time(17)
	F.handle(rule, &"on_tick", api)
	assert_int(int(rule.snapshot().effects[&"slow_time"].remaining_ms)).is_equal(83)
	api.set_time(10017)
	F.handle(rule, &"on_tick", api)
	assert_int(int(rule.snapshot().effects[&"slow_time"].remaining_ms)).is_equal(66)
	rule.apply_effect(&"slow_time", api)
	assert_int(int(rule.snapshot().effects.size())).is_equal(1)
	assert_int(int(rule.snapshot().effects[&"slow_time"].remaining_ms)).is_equal(100)
	for step: int in 6:
		api.set_time(10034 + step * 17)
		F.handle(rule, &"on_tick", api)
	assert_bool(rule.snapshot().effects.is_empty()).is_true()

func test_spin_lock_allows_spin_and_vetoes_tilt_and_roll() -> void:
	var api: RuleApi = _api()
	var rule := Items.new()
	rule.apply_effect(&"spin_lock", api)
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, F.context({"args": [1, 1]}), api)).is_false()
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, F.context({"args": [0, 1]}), api)).is_true()
	assert_bool(rule.veto(SimEvents.CMD_ROTATE, F.context({"args": [2, -1]}), api)).is_true()

func test_bomb_queues_post_clear_damage_two_and_uses_canonical_real_cube_center() -> void:
	var api: RuleApi = _api()
	var piece := ActivePiece.new(ShapeDef.build(&"duo", [Vector3i.ZERO, Vector3i.RIGHT]), Vector3i(1, 1, 1), 0)
	api.bind_piece(piece)
	api.bind_piece_uid(41)
	var rule := Items.new()
	rule.apply_effect(&"bomb", api)
	api.take_requests()
	F.handle(rule, &"on_lock", api, {"uid": 41, "cells": piece.cells()})
	var requests: Array[Dictionary] = api.take_requests()
	assert_int(requests.size()).is_equal(1)
	assert_str(str(requests[0].op)).is_equal("damage")
	assert_int(int(requests[0].hits)).is_equal(2)
	assert_int(requests[0].cells.size()).is_equal(27)
	assert_vector(Items.blast_center([Vector3i(2, 1, 1), Vector3i(1, 1, 1)])).is_equal(Vector3i(1, 1, 1))

func test_attack_waits_for_host_ack_and_no_effect_refund_is_exactly_once() -> void:
	var api: RuleApi = _api({}, 2)
	var rule := Items.new()
	F.handle(rule, &"on_level_start", api)
	rule._slots[0] = {"id": &"fog", "refunded": false}
	rule.use_slot(0, api)
	var token: String = str(rule.snapshot().slots[0].token)
	assert_bool(rule.snapshot().slots[0].pending).is_true()
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_RECEIVE_ITEM, "args": [{"ack": true, "token": token, "applied": false}]})
	assert_bool(rule.snapshot().slots[0].refunded).is_true()
	rule.use_slot(0, api)
	token = str(rule.snapshot().slots[0].token)
	F.handle(rule, &"on_command", api, {"kind": SimEvents.CMD_RECEIVE_ITEM, "args": [{"ack": true, "token": token, "applied": false}]})
	assert_bool(rule.snapshot().slots[0].is_empty()).is_true()
'''

root = Path(__file__).resolve().parent
job = {"id": "mechanics-items-tests-1", "actions": [
    {"tool": "script_create", "arguments": {"path": "res://tests/unit/mechanics/items_test.gd", "content": SOURCE}},
    {"tool": "filesystem_manage", "arguments": {"operation": "scan"}},
]}
path = root / "jobs" / "mechanics-items-tests-1.json.tmp"
path.write_text(json.dumps(job))
path.rename(path.with_suffix(""))
