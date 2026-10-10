class_name WtModes extends RefCounted
## Local competitive round selection and tournament standings; transports belong to the application.

var _content: WtContent
var _config: Dictionary = {}
var _economy: Dictionary = {}
var _state: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _lobby_completed: int = 0
var _round_pool: Array = []

func _init(content: WtContent = null) -> void:
	_content = content
	_config = _read("res://assets/data/meta/modes.json")
	_economy = _read("res://assets/data/meta/economy.json")

## Supported round ids for the lobby's mode checkboxes.
func round_modes() -> Array:
	return _config.tournament.modes.duplicate()

## Applies a nonempty, trusted round pool. Unknown ids leave the existing pool intact.
func set_round_pool(ids: Array) -> bool:
	if ids.is_empty():
		return false
	var accepted: Array = []
	for id: Variant in ids:
		var value: String = str(id)
		if not _config.tournament.modes.has(value):
			return false
		if not accepted.has(value):
			accepted.append(value)
	_round_pool = accepted
	return true

## Makes an endless Arcade level with the selected skin; star currency is never paid by Arcade.
func arcade_level(biome: String = "meadow", seed: int = -1) -> LevelData:
	var cfg: Dictionary = _config.arcade
	var source: Dictionary = _base("arcade_" + biome, biome, seed)
	source.board = {"width": cfg.width, "depth": cfg.depth, "h_play": cfg.h_play}
	source.pieces = {"shapes": cfg.standard_shapes}
	source.goal = {"type": "endless"}
	source.knobs.merge({"fall.g0": cfg.g0, "fall.ramp_per_clear": cfg.ramp_per_clear, "fall.g_max": cfg.g_max, "goal.warnings_max": cfg.warnings_max}, true)
	return _parse(source)

## Deterministic compatible twist draw; only encountered supported twist ids enter the pool.
func arcade_twists(layers: int, pool: Array, seed: int) -> Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = Seeds.derive(seed, ["arcade_twists", layers / int(_config.arcade.twist_rotation_layers)])
	var choices: Array = pool.duplicate()
	var out: Array = []
	var count: int = mini(choices.size(), 1 if layers < int(_config.arcade.two_twists_after) else 2)
	while out.size() < count and not choices.is_empty():
		var candidate: Variant = choices.pop_at(rng.randi_range(0, choices.size() - 1))
		var definition: RuleDef = _content.catalog.rule_defs.get(StringName(str(candidate))) if _content != null else null
		if definition == null or definition.layer != &"twist":
			continue
		var compatible: bool = true
		for old: String in out:
			if definition.incompatible_with.has(old): compatible = false
		if compatible: out.append(candidate)
	return out

## Configures 2–4 real local player entries; never creates simulated network peers.
func start_tournament(players: Array, rounds: int = 3, seed: int = 1, modes: Array = []) -> Dictionary:
	if not modes.is_empty() and not set_round_pool(modes):
		_state = {"ok": false, "error": "invalid_round_pool"}
		return _state.duplicate(true)
	var valid_length: bool = false
	for length: Variant in _config.tournament.lengths:
		if int(length) == rounds: valid_length = true
	if players.size() < 2 or players.size() > 4 or not valid_length:
		_state = {"ok": false, "error": "invalid_tournament_configuration"}
		return _state.duplicate(true)
	_rng.seed = seed
	var rows: Array = []
	for i: int in players.size():
		var source: Dictionary = players[i] if players[i] is Dictionary else {"name": str(players[i])}
		rows.append({"id": str(source.get("id", i)), "name": str(source.get("name", "Builder %d" % (i + 1))), "character": str(source.get("character", "c1")), "wins": 0, "score": 0, "layers": 0, "streak": 0, "active": true})
	_state = {"ok": true, "phase": "round_pick", "rounds": rounds, "majority": rounds / 2 + 1, "round_index": 0, "seed": seed, "players": rows, "history": [], "sudden_death": false, "contenders": [], "winners": [], "mode": ""}
	return tournament_snapshot()

## Stable sorted standings; equal wins are compared by accumulated score for display only.
func standings() -> Array:
	var rows: Array = _state.get("players", []).duplicate(true)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.wins > b.wins or (a.wins == b.wins and a.score > b.score))
	return rows

## Complete tournament snapshot for lobby/standings/results screens.
func tournament_snapshot() -> Dictionary:
	var snapshot: Dictionary = _state.duplicate(true)
	snapshot["standings"] = standings()
	return snapshot

## Generates the next playable round and uses a nonrepeating deterministic mode draw.
func next_round_level() -> LevelData:
	if not _state.get("ok", false) or _state.get("phase") == "finished":
		return null
	var sudden: bool = bool(_state.sudden_death)
	var options: Array = (_round_pool if not _round_pool.is_empty() else _config.tournament.modes).duplicate()
	if options.size() > 1:
		options.erase(_state.mode)
	var mode: String = "clear_race" if sudden else str(options[_rng.randi_range(0, options.size() - 1)])
	_state.mode = mode
	_state.phase = "round_play"
	var source: Dictionary = _base("round_%d" % (_state.round_index + 1), "meadow", Seeds.derive(int(_state.seed), ["round", int(_state.round_index)]))
	source.goal = {"type": "clear_n", "n": int(_config.tournament.sudden_death_layers if sudden else _config.tournament.goal_layers)}
	source.knobs["goal.warnings_max"] = 0
	source.knobs["goal.top_out"] = "lose"
	match mode:
		"height_race": source.goal = {"type": "height", "h_target": 6}
		"gust_race": source.rules = [{"id": "gust", "params": {"wind_dir": "+x", "wind_interval_ms": 7000, "wind_strength": 1}}]
		"conveyor_race": source.rules = [{"id": "mill_belt", "params": {"conveyor_dir": "+x", "conveyor_every": 3, "conveyor_wrap": true}}]
		"ice_race": source.rules = [{"id": "ice_slide", "params": {}}]
		"fog_race": source.rules = [{"id": "fog", "params": {}}]
	return _parse(source)

## Records all player outcomes. Winners first by won/time; time-cap fallback by progress then score.
## Rows: {id, won, ms, progress, score, layers, active}; omitted active defaults true.
func record_round(results: Array) -> Dictionary:
	if _state.get("phase") != "round_play":
		return {"ok": false, "error": "round_not_playing"}
	var eligible: Array = []
	for result: Dictionary in results:
		if bool(result.get("active", true)) and (not _state.sudden_death or _state.contenders.has(str(result.id))):
			eligible.append(result)
	if eligible.is_empty():
		return {"ok": false, "error": "no_results"}
	var earliest: int = 2147483647
	var best_progress: float = -1.0
	var best_score: int = -1
	for row: Dictionary in eligible:
		if bool(row.get("won", false)):
			earliest = mini(earliest, int(row.get("ms", 0)))
		var progress: float = float(row.get("progress", row.get("layers", 0)))
		var score: int = int(row.get("score", 0))
		if progress > best_progress or (is_equal_approx(progress, best_progress) and score > best_score):
			best_progress = progress
			best_score = score
	var winners: Array = []
	for row: Dictionary in eligible:
		if earliest != 2147483647:
			if bool(row.get("won", false)) and int(row.get("ms", 0)) == earliest: winners.append(str(row.id))
		elif is_equal_approx(float(row.get("progress", row.get("layers", 0))), best_progress) and int(row.get("score", 0)) == best_score:
			winners.append(str(row.id))
	for player: Dictionary in _state.players:
		var won: bool = winners.has(str(player.id))
		player.wins += 1 if won else 0
		player.streak = player.streak + 1 if won else 0
		for row: Dictionary in results:
			if str(row.id) == str(player.id):
				player.score += int(row.get("score", 0))
				player.layers += int(row.get("layers", 0))
				player.active = bool(row.get("active", true))
	_state.history.append({"mode": _state.mode, "winners": winners, "results": results.duplicate(true)})
	_state.round_index += 1
	var majority: Array = []
	for player: Dictionary in _state.players:
		if player.wins >= int(_state.majority): majority.append(str(player.id))
	if _state.sudden_death and winners.size() == 1:
		_finish(winners)
	elif not _state.sudden_death and majority.size() == 1:
		_finish(majority)
	elif majority.size() > 1:
		_state.sudden_death = true
		_state.contenders = majority
		_state.phase = "round_pick"
	elif _state.round_index >= _state.rounds:
		var rows: Array = standings()
		var leaders: Array = []
		for row: Dictionary in rows:
			if row.wins == rows[0].wins: leaders.append(str(row.id))
		if leaders.size() == 1:
			_finish(leaders)
		else:
			_state.sudden_death = true
			_state.contenders = leaders
			_state.phase = "round_pick"
	else:
		_state.phase = "round_pick"
	return tournament_snapshot()

## Ends a prematurely closed lobby with no win award; finish awards require majority rounds played.
func abort_tournament() -> Dictionary:
	_state.phase = "finished"
	_state.winners = []
	_state["aborted"] = true
	_state["awards"] = tournament_awards(int(_state.get("rounds", 3)), _state.get("players", []).size(), _lobby_completed)
	_state.awards.win = 0
	if int(_state.get("round_index", 0)) < int(_state.get("majority", 2)): _state.awards.finish = 0
	return tournament_snapshot()

## Formula values from Star Economy; each device credits its own profile from this result.
func tournament_awards(rounds: int, players: int, completed: int = 0) -> Dictionary:
	var majority: int = rounds / 2 + 1
	var base: int = roundi(float(_economy.get("tw_per_M", 1)) * majority * (1.0 + float(_economy.get("tw_player_step", 0.25)) * (players - 2)))
	var finish: int = maxi(int(_economy.get("finish_min", 1)), roundi(float(_economy.get("finish_frac", .3)) * base))
	var multiplier: float = maxf(float(_economy.get("lobby_floor", .4)), 1.0 - float(_economy.get("lobby_step", .15)) * completed)
	return {"win": floori(base * multiplier), "finish": floori(finish * maxf(0, 1.0 - float(_economy.get("finish_step", .5)) * completed))}

## Resets in-memory rematch decay when the real lobby closes.
func close_lobby() -> void:
	_lobby_completed = 0

func _finish(winners: Array) -> void:
	_state.winners = winners
	_state.phase = "finished"
	_state["awards"] = tournament_awards(int(_state.rounds), _state.players.size(), _lobby_completed)
	_lobby_completed += 1

func _base(id: String, biome: String, seed: int) -> Dictionary:
	return {"schema": 1, "id": id, "biome": biome, "tier": 1, "name": "MODE_" + id.to_upper(), "board": {"width": 6, "depth": 6, "h_play": 12}, "pieces": {"shapes": _config.arcade.standard_shapes}, "knobs": {"fall.g0": 1.0, "goal.top_out": "rescue", "goal.warnings_max": 1}, "rules": [], "stars": {}, "seed": seed}

func _parse(source: Dictionary) -> LevelData:
	if _content == null:
		return null
	var result: LoadResult = LevelLoader.parse_level(source, _content.catalog)
	_content.last_issues = result.issues
	return result.level

func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}
