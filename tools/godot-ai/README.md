# Live Godot AI workflow

The project enables `addons/godot_ai` version **4.3.0** in the editor. The matching Python server runs from the installed `godotai-venv`; the editor uses Godot **4.7.2**. The relay connects through the addon's authenticated MCP HTTP transport and editor WebSocket v2. Its source does not write game scripts or scenes itself: it invokes the actual advertised addon tools.

Launch the relay with the matching environment:

```bash
../tools/godotai-venv/bin/python tools/godot-ai/relay.py \
  --project "$PWD" --tool-root ../tools
```

It starts portable Xvfb, the server, Godot editor and MCP client together because the environment isolates network namespaces between command sessions. Optional telemetry and update checks are disabled for this local workflow. Credentials stay in the server's private capability record and never enter jobs, results or transcripts.

Wait for `tools/godot-ai/results/READY.json`, then atomically publish a job:

```json
{
  "id": "example",
  "actions": [
    {
      "tool": "script_create",
      "arguments": {"path": "res://src/example.gd", "content": "extends RefCounted\n"}
    }
  ]
}
```

Write it as `tools/godot-ai/jobs/example.tmp`, then rename to `example.json`. Its result appears under `tools/godot-ai/results/example.json`. Tool metadata is in `reports/godot-ai/tool_catalog.json`; `connection.json` records the authenticated editor session, and `tool_calls.jsonl` records actual calls and results. A failed tool stops that job unless `continue_on_error` is set. Results are immutable per job filename: use a new ID for a deliberate recovery after inspecting the failed outcome.

Use `script_create` for new scripts; `script_patch` for exact anchored changes; `scene_manage(op="create")`, `node_create`, `script_attach`, and `scene_save` for scene authoring. Scene node paths begin with the scene root, for example `/AtomLab/Overlay`, rather than the running game's `/root` path. Start each scene-edit job with `scene_open` when another job could have changed the edited scene. A new `class_name` may need one explicit `filesystem_manage(op="scan")` before a dependent script. The relay separates fresh writes/scans by two seconds to allow Godot's class registration task to finish.

`test_run` runs the addon's `McpTestSuite` tests in the editor. The project's GdUnit suites remain a separate verification path. `prepare_syrup_job.py` queues a real syrup-band rule, a four-case addon test suite and a reusable `AtomLab` scene using this workflow. The first live session exposed an editor scan crash; its crash log is retained and that failed operation is not reported as a passing test.

Finish pending jobs before creating `tools/godot-ai/jobs/STOP`; it stops the running project, quits the editor and terminates the server/display. The addon is inert for normal headless test launches. Its export plugin strips `_mcp_game_helper` from exported packs before project settings are baked, so the development helper does not become a release autoload.
