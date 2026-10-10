# Beehave runtime debugger compatibility patch

The installed Beehave addon is used by live gameplay hook dispatch, 3D toy reaction/ambient trees and the independent Jolt challenge state tree. Its native `BeehaveGlobalMetrics` and `BeehaveGlobalDebugger` autoloads are enabled by the editor addon workflow.

`addons/beehave/debug/debugger_messages.gd` originally sent debugger messages whenever `OS.has_feature("editor")` was true. A game launched from the standard Godot binary on the command line also carries that feature, even when no debugger connection exists. Repeated native `EngineDebugger.send_message` calls then printed `Can't send message. No active debugger` during otherwise working tree ticks.

The message predicate now additionally requires `EngineDebugger.is_active()`. The native global debugger also registers its message capture only when that debugger is active, preventing an absent-capture error at headless shutdown. Connected editor debugging continues to work, while standalone source runs and exports do not send to an absent debugger. No addon tick semantics, status values, licensing notices or rule behavior were changed. Keep this small downstream compatibility patch when updating Beehave, or remove it if upstream introduces the same active-connection guard.

Retained evidence: `tools/godot-ai/jobs/presentation-readability-004.json` and matching results validate the actual addon edit; `production/qa/evidence/build-2026-10-10/physics-tower.godot.log` records real Jolt body settle transitions without the previous message failures. The latest cast and stage captures supersede the initial gallery that exposed missing native autoloads.
