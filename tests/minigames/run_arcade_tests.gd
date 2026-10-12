extends SceneTree
## Dependency-free deterministic rules runner for the isolated arcade package.

func _initialize() -> void:
	var failures: Array[String] = []
	for mode: String in ["stack", "wall", "shadow"]:
		var path: String = "res://tests/minigames/%s_rules_test.gd" % mode
		var suite: Script = load(path)
		if suite == null or not suite.has_method("run"):
			failures.append("Could not load suite: " + path)
			continue
		var result: Array = suite.run()
		for failure: String in result:
			failures.append(mode + ": " + failure)
		print("ARCADE SUITE ", mode, ": ", "PASS" if result.is_empty() else "FAIL")
	for failure: String in failures:
		push_error(failure)
	print("ARCADE RULES: ", "PASS" if failures.is_empty() else "FAIL", " (", failures.size(), " failures)")
	quit(0 if failures.is_empty() else 1)
