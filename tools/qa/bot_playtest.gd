extends SceneTree
## Automated bot playtest: drives each campaign level with WtBotPlayer (no rendering) and records outcomes.
## Run: godot --headless --path . -s res://tools/qa/bot_playtest.gd [-- --biome=meadow --level=meadow_03 --attempts=3 --out=res://production/qa/bot-playtest-2026-10-13.json]
## The bot is weaker than a human: a level it never finishes needs review; that does not prove it is impossible.
const SEEDS: Array[int] = [1729, 4242, 90001]
const HARD_CAP_MS := 600000          ## 10 simulated minutes
const STALL_TICKS := 60 * 30         ## 30 s of ticks with no level-clock progress = stall
const ASSESSED_GOALS := ["clear_n", "height", "survive"]
const ASSESSED_VERBS := ["piece"]
var _content := WtContent.new()
var _catalog: GameCatalog
var _args: Dictionary = {}

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	for a: String in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a.begins_with("--") and "=" in a:
			_args[a.substr(2, a.find("=") - 2)] = a.substr(a.find("=") + 1)
	var attempts: int = clampi(int(_args.get("attempts", "3")), 1, SEEDS.size())
	var out_path: String = String(_args.get("out", "res://production/qa/bot-playtest-2026-10-13.json"))
	_catalog = _content.load_catalog()
	var t0: int = Time.get_ticks_msec()
	var rows: Array = []
	for entry: Dictionary in _content.all_levels():
		if _args.has("biome") and String(entry.biome) != _args.biome: continue
		if _args.has("level") and String(entry.id) != _args.level: continue
		var lt: int = Time.get_ticks_msec()
		var row: Dictionary = _play_level(entry, attempts)
		row.wall_ms = Time.get_ticks_msec() - lt
		rows.append(row)
		print("LEVEL %s %s wins=%d/%d wall=%dms %s" % [row.id, row.status, row.wins, row.attempts.size(), row.wall_ms,
			", ".join(row.attempts.map(func(r: Dictionary) -> String: return "%s@%ds/L%d%s" % [r.outcome, r.level_ms / 1000, r.locks, ("(" + r.reason + ")") if r.reason != "" else ""]))])
	var report: Dictionary = {"schema": 1, "date": "2026-10-13", "engine": Engine.get_version_info().string,
		"seeds": SEEDS.slice(0, attempts), "hard_cap_ms": HARD_CAP_MS, "assessed_goals": ASSESSED_GOALS, "assessed_verbs": ASSESSED_VERBS,
		"runtime_ms": Time.get_ticks_msec() - t0, "catalog_errors": Array(_content.errors), "filters": _args, "levels": rows,
		"caveat": "WtBotPlayer is a deterministic practice opponent, weaker than a human. 'Never finished' means review, not proof of impossibility."}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path.get_base_dir()))
	var f := FileAccess.open(out_path, FileAccess.WRITE); f.store_string(JSON.stringify(report, "\t")); f.close()
	print("BOT_PLAYTEST levels=%d runtime=%ds path=%s" % [rows.size(), report.runtime_ms / 1000, out_path])
	quit(0)

func _play_level(entry: Dictionary, attempts: int) -> Dictionary:
	var row: Dictionary = {"id": String(entry.id), "biome": String(entry.biome), "tier": int(entry.tier), "attempts": [], "wins": 0}
	var level: LevelData = _content.level(entry.id)
	if level == null:
		row.status = "LOAD_FAIL"; row.not_assessed_reason = "level failed to load: " + str(_content.last_issues); return row
	var goal_type: String = String(level.goal.get("type", "?"))
	row.goal = level.goal.duplicate(true); row.stars_def = level.stars.duplicate(true)
	row.fixed_level_seed = level.seed if level.seed != LevelData.NO_SEED else null
	var t3: int = int(level.stars.get("t3", -1)) if level.stars.has("t3") else -1
	row.t3_ms = t3
	var cap: int = HARD_CAP_MS if (t3 <= 0 or goal_type == "survive") else mini(t3 * 2, HARD_CAP_MS)
	row.cap_ms = cap
	var verb: String = ""
	var reasons: Array = []
	for i: int in attempts:
		var seed: int = SEEDS[i]
		var sim := BoardSim.new(level, seed, _catalog)
		verb = String(sim.knobs().value(&"control.verb"))
		var bot := WtBotPlayer.new()
		var rng := RandomNumberGenerator.new(); rng.seed = seed
		var used_kit_pick: bool = false
		var last_ms: int = -1; var still: int = 0; var ticks: int = 0
		var outcome: String = "timeout"; var reason: String = ""
		var tick_cap: int = int(cap / 1000.0 * BoardSim.SIM_HZ * 2.0) + 60 * 60
		while ticks < tick_cap:
			if sim.result() != null: break
			if sim.get_phase() == BoardSim.Phase.SELECTING:
				var choices: Array[Dictionary] = sim.kit_choices()
				if not choices.is_empty():
					used_kit_pick = true
					sim.queue_command(SimCommand.make(SimEvents.CMD_PICK_SHAPE, [choices[rng.randi_range(0, choices.size() - 1)].shape_id]))
			else:
				bot.update(sim)
			sim.step(); ticks += 1
			var ms: int = sim.goal_state().level_ms
			if ms >= cap: break
			if ms == last_ms: still += 1
			else: still = 0; last_ms = ms
			if still > STALL_TICKS and sim.get_phase() != BoardSim.Phase.COUNTDOWN:
				reason = "stall: level clock frozen in phase %s" % BoardSim.Phase.keys()[sim.get_phase()]; break
		var res: LevelResult = sim.result()
		var stars: int = 0
		if res != null:
			outcome = "won" if res.is_won() else "lost"
			stars = res.stars
			if not res.is_won(): reason = _loss_reason(sim)
		elif ticks >= tick_cap and reason == "":
			reason = "tick cap reached before level clock cap"
		var gs: GoalState = sim.goal_state()
		var att: Dictionary = {"seed": seed, "outcome": outcome, "level_ms": gs.level_ms, "locks": gs.locks, "stars": stars,
			"layers_cleared": gs.layers_cleared, "warnings_used": gs.warnings_used, "cells_trimmed": gs.cells_trimmed,
			"reason": reason, "ticks": ticks, "kit_pick_by_harness": used_kit_pick, "metrics": gs.metrics.duplicate(true)}
		row.attempts.append(att)
		if outcome == "won": row.wins += 1
	row.verb = verb
	if goal_type not in ASSESSED_GOALS: reasons.append("goal type '%s' is not targeted by WtBotPlayer" % goal_type)
	if verb not in ASSESSED_VERBS: reasons.append("control verb '%s' is not used by WtBotPlayer (no choose_down/flick)" % verb)
	if row.wins > 0: row.status = "WON"
	elif not reasons.is_empty(): row.status = "NOT_ASSESSED"
	elif row.attempts.any(func(a: Dictionary) -> bool: return a.outcome == "lost"): row.status = "LOST"
	else: row.status = "TIMEOUT"
	if not reasons.is_empty(): row.not_assessed_reason = "; ".join(reasons)
	row.bot_capable = reasons.is_empty()
	return row

func _loss_reason(sim: BoardSim) -> String:
	var gs: GoalState = sim.goal_state()
	var r: String = ""
	# _finish stores the reason only in the emitted event; reconstruct from state.
	if sim._timed_out(): r = "time_limit"
	elif int(sim._level.goal.get("piece_budget", 0)) > 0 and gs.locks >= int(sim._level.goal.get("piece_budget", 0)): r = "out_of_pieces"
	elif sim._spawner != null and sim._spawner.is_kit() and sim.selection_remaining() == 0: r = "out_of_pieces"
	else: r = "top_out_or_goal_fail"
	return r
