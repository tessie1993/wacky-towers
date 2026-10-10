extends GdUnitTestSuite
## WtMinigameRound: host-side stepping, send routing, shared authority and record_round results.

var _content: WtContent

func before() -> void:
	_content = WtContent.new()
	_content.load_catalog()

func _row(id: String) -> Dictionary:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/tournament/templates.json"))
	for row: Dictionary in data.templates:
		if str(row.id) == id: return row
	return {}

func _players(count: int) -> Array:
	var players: Array = []
	for index: int in count: players.append({"name": "P%d" % index, "is_bot": index > 0})
	return players

func _run(round: WtMinigameRound, limit_ticks: int) -> void:
	var ticks: int = 0
	while not round.finished() and ticks < limit_ticks:
		round.step()
		ticks += 1

func test_mg05_is_reported_unsupported() -> void:
	assert_bool(WtMinigameRound.supports(_row("mg05"))).is_false()
	assert_bool(WtMinigameRound.supports(_row("mg09"))).is_true()
	assert_bool(WtMinigameRound.supports(_row("clear_race"))).is_false()

func test_intent_args_keep_insertion_order() -> void:
	assert_array(WtMinigameRound.intent_args({"axis": 2, "dir": -1})).is_equal([2, -1])
	assert_array(WtMinigameRound.intent_args({})).is_empty()

func test_speed_sort_round_finishes_with_one_result_per_player() -> void:
	var round := WtMinigameRound.new()
	assert_bool(round.setup(_row("mg09"), 7, _content.catalog, _players(3))).is_true()
	_run(round, 60 * 70)
	assert_bool(round.finished()).is_true()
	var rows: Array[Dictionary] = round.results()
	assert_int(rows.size()).is_equal(3)
	for row: Dictionary in rows:
		assert_bool(row.has("standing_value")).is_true()
		assert_bool(row.has("score")).is_true()

func test_local_snapshot_lists_opponents_and_template_name() -> void:
	var round := WtMinigameRound.new()
	round.setup(_row("mg16"), 3, _content.catalog, _players(2))
	round.step()
	var snapshot: Dictionary = round.local_snapshot()
	assert_str(str(snapshot.name)).is_equal("Rhythm Blocks")
	assert_int((snapshot.opponents as Array).size()).is_equal(1)

func test_send_request_is_delivered_to_target_session() -> void:
	var round := WtMinigameRound.new()
	round.setup(_row("mg16"), 11, _content.catalog, _players(2))
	round.step()
	var token_event: Dictionary = {"token": "mg16:0:1", "effect": "offbeat", "data": {"duration_ms": 5000}, "sender": 0, "target": 1, "warn_ms": 1000}
	round._route_send(0, token_event)
	for _tick: int in 3: round.step()
	assert_int((round.sessions[1].snapshot().attacks as Array).size()).is_equal(1)
	assert_str(str(round.sessions[1].snapshot().attacks[0].sender_name)).is_equal("P0")

func test_first_claim_wins_and_awards_every_session() -> void:
	var round := WtMinigameRound.new()
	round.setup(_row("mg09"), 5, _content.catalog, _players(2))
	round.step()
	round._resolve_shared(1, {"kind": "gold_gem_claim", "data": {"serial": 1, "player": 1}})
	round._resolve_shared(0, {"kind": "gold_gem_claim", "data": {"serial": 1, "player": 0}})
	for _tick: int in 3: round.step()
	assert_int(round.sessions[1].score()).is_equal(3)
	assert_int(round.sessions[0].score()).is_equal(0)

func test_results_feed_record_round() -> void:
	var modes := WtModes.new(_content)
	assert_bool(modes.start_tournament(["A", "B"], 3, 42, ["mg09"]).ok).is_true()
	var draw: Dictionary = modes.draw_next_round()
	if str(draw.get("phase", "")) == "round_show": draw = modes.lock_round()
	assert_str(str(draw.category)).is_equal("minigame")
	var round := WtMinigameRound.new()
	assert_bool(round.setup(draw.template, int(draw.round_seed), _content.catalog, _players(2))).is_true()
	_run(round, 60 * 70)
	var snapshot: Dictionary = modes.record_round(round.results())
	assert_bool(snapshot.get("ok", false)).is_true()
	assert_int(int(snapshot.round_index)).is_equal(1)

func test_same_seed_same_bots_same_outcome() -> void:
	var a := WtMinigameRound.new()
	var b := WtMinigameRound.new()
	a.setup(_row("mg04"), 99, _content.catalog, _players(2))
	b.setup(_row("mg04"), 99, _content.catalog, _players(2))
	for _tick: int in 600:
		a.step()
		b.step()
	assert_int(a.sessions[1].state_hash()).is_equal(b.sessions[1].state_hash())
