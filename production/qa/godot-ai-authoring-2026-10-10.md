# Actual Godot AI editor authoring — 2026-10-10

The installed Godot AI addon **4.3.0** and matching Python server **4.3.0** were connected to the real Godot **4.7.2** editor. The authenticated connection advertised **47 tools**. The local relay started Xvfb, editor, server and MCP client within one process environment because separate command sessions cannot share display/network sockets here. It invokes the addon's actual tools; it does not write game files as a substitute for those calls.

## Measured authoring evidence

| Work | Actual addon tools | Evidence |
|---|---|---|
| All 118 playable campaign scenes, in biome order | 118 `scene_open` calls and 118 `batch_execute` calls using native create-node, attach-script and save-scene commands | All ten `scenes-01-meadow` through `scenes-10-celestial` jobs succeeded. Every scene has its own `World` Node3D attached to `WtStage` and `StoryOrigin` Marker3D. |
| Reusable syrup atom and live editor fixture | `script_create`, `scene_manage`, `node_create`, `script_attach`, `scene_save`, `scene_get_hierarchy` | `src/mechanics/behaviour/syrup_band.gd`, `src/game/atom_lab.gd`, `src/game/atom_lab.tscn` were created by the addon. |
| Syrup semantics inside the addon | `test_run` | Four editor-side `McpTestSuite` cases passed: slowing, exact ghost glide, blocked glide and dry landing. |
| Remaining gameplay, presentation, architecture and proof scripts | `script_create` / anchored `script_patch` plus actual file scans | Candy, Lava/Forest/Underwater, kit/goals, Orchestrator bridge, native Beehave cast, GUIDE/LAN proof, item runtime and unit suites were submitted by their owning agents to the live editor relay. |
| Native Beehave autoload registration | `autoload_manage` add/add/list | Real `BeehaveGlobalMetrics` and `BeehaveGlobalDebugger` autoloads are retained. Plugin enable-array edits were authorized directly because the addon refuses `editor_plugins/*` through `project_manage`. |

`production/qa/godot-ai-authoring-evidence-2026-10-10.json` records compact per-call targets, result status, diagnostics and result-file locations. Regenerate it with `python tools/godot-ai/audit_results.py`. The complete original tool arguments/results and editor logs are under `reports/godot-ai/`; credentials are never copied into these artifacts.

## Failures and their practical limits

The first editor session crashed during a filesystem/class-registration scan. A fresh editor session recovered and completed the authoring queue. Some existing `class_name` rewrites returned fallback reload error43 because the addon creates a temporary uncached script while its global class is already loaded. These diagnostics are retained; fresh-process Godot parsing and gameplay tests establish the final source state.

The first Items create timed out after five seconds but wrote the file. Its source also exposed a missing lambda parenthesis, corrected through an actual addon patch. An ambiguous test patch was refused safely; a more specific addon rewrite corrected it. Early scan calls with the wrong schema were rejected and repeated with the advertised `op`/`params` schema. Failed calls are not counted as passing verification.

The addon's `project_run` launched AtomLab, but the sandboxed embedded game never connected its live-eval helper. The attempt recorded `EVAL_GAME_NOT_READY`, an X11 `BadWindow` and restricted runtime socket failure. The editor-side creation and four addon tests succeeded; live game evaluation did **not** succeed and is not claimed. Normal standalone runtime validation is a separate path.

The Godot AI editor plugin remains enabled as requested. Its export hook removes the development game-helper autoload from exported packs; the relay owner also removes the transient helper entry from source settings after the final editor shutdown. Native Beehave runtime autoloads remain part of the game.
