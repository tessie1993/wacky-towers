extends SceneTree
## Headless sim-tick timing for the fog levels (review D1 gate: 600 ticks in under 1 s per level).
## Run: godot --headless --path . -s res://tools/qa/perf/fog_tick_timing.gd [-- --ticks=600 --seed=1729 --levels=meadow_07,ice_07 --bot=1]
## Prints one `FOGPERF <id> ticks=<n> ms=<wall> ticks_per_s=<rate> locks=<n>` line per level and `FOGPERF_SUMMARY`.
## Exit code 1 when any level exceeds --budget_ms (default 1000).
const DEFAULT_LEVELS: PackedStringArray = ["meadow_07", "ice_07", "underwater_07", "lava_07", "cave_08", "cave_09",
	"forest_h1", "celestial_07", "carnival_08"]

var _args: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for a: String in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if a.begins_with("--") and "=" in a:
			_args[a.substr(2, a.find("=") - 2)] = a.substr(a.find("=") + 1)
	var ticks: int = int(_args.get("ticks", "600"))
	var seed_value: int = int(_args.get("seed", "1729"))
	var budget_ms: int = int(_args.get("budget_ms", "1000"))
	var use_bot: bool = String(_args.get("bot", "1")) != "0"
	var ids: PackedStringArray = String(_args.get("levels", ",".join(DEFAULT_LEVELS))).split(",", false)
	var content := WtContent.new()
	var catalog: GameCatalog = content.load_catalog()
	var worst: int = 0
	var failures: int = 0
	for id: String in ids:
		var level: LevelData = content.level(id)
		if level == null:
			print("FOGPERF %s LOAD_FAIL" % id)
			failures += 1
			continue
		var sim := BoardSim.new(level, seed_value, catalog)
		var bot := WtBotPlayer.new()
		var t0: int = Time.get_ticks_usec()
		var done: int = 0
		while done < ticks and sim.result() == null:
			if use_bot and sim.get_phase() != BoardSim.Phase.SELECTING:
				bot.update(sim)
			sim.step()
			done += 1
		var ms: int = (Time.get_ticks_usec() - t0) / 1000
		worst = maxi(worst, ms)
		if ms > budget_ms:
			failures += 1
		print("FOGPERF %s ticks=%d ms=%d ticks_per_s=%d locks=%d hash=%d" % [id, done, ms, done * 1000 / maxi(ms, 1), sim.goal_state().locks, sim.state_hash()])
	print("FOGPERF_SUMMARY levels=%d worst_ms=%d over_budget=%d" % [ids.size(), worst, failures])
	quit(1 if failures > 0 else 0)
