# Deterministic Beehave gameplay execution

Implemented 2026-10-10 with the installed Beehave addon. This is the production gameplay driver, alongside separate scene-owned Beehave trees for toy reactions and Jolt challenges.

Each `BoardSim` owns one detached native `BeehaveTree`, one native `Blackboard`, a `Node` actor and a `RuleActionLeaf` extending the addon's `ActionLeaf`. The tree uses `ProcessThread.MANUAL`, never enters the SceneTree and never processes itself. `RuleRuntime.execute` supplies an object, method and typed arguments through a scoped blackboard frame, calls the native tree's `tick()`, and retrieves the action result. Nested operations save and restore the outer frame.

The fixed-tick pipeline and all gameplay handler invocations pass through this native tree: rule handle/veto, arrival, clear detection, collapse, top-out, goal lifecycle/evaluation and ability step/command/on-lock/observe/veto. Rule ordering remains `(layer_rank, activated_at, rule_id)`; Beehave supplies execution and status semantics without replacing the documented per-lock order. Pure metadata, progress and snapshot reads are direct, so inspecting the HUD or hash never advances behavior state.

The driver snapshot contains execution/failure counters and native status/last-tick counters. Blackboard references, node/instance ids, wall-clock profiling values and debugger state are excluded. Command replay therefore produces the same state hash on independent simulations. Undo restores primitive counters along with the simulation checkpoint; no active asynchronous task exists to cancel.

Detached nodes are owned by the runtime. Explicit `dispose` frees them for focused tests. RefCounted pre-delete frees the actor directly without calling another method on the already-zero-reference object; Godot rejects such self-resurrection and would leak the tree. The regression suite verifies native Beehave class identities, manual ticking, action results, replay equality and zero GdUnit orphans.

`tests/unit/sim/turn_controls_test.gd` is the executable contract. `reports/report_15/results.xml` records the first complete 53-test simulation pass covering this driver plus the control/randomizer/effect wave. Final build evidence supersedes that intermediate report after integration checks finish.
