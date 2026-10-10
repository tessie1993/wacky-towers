# Arcade pack integration contract

Independent single-player practice implementations of MG4, MG1 and MG10. The
existing tournament designs remain authoritative for future multiplayer work.
No edits to BoardSim, core registries, autoloads, input map or default main scene.

Model scripts extend `res://minigames/arcade_pack/models/round_base.gd` using a
path, without `class_name`. `start(level, seed)`, `advance(delta)`, `act(action)`,
`snapshot()` are the public boundary. Finished models reject all actions.

Snapshot: `blocks` and `markers` are Arrays of dictionaries containing
`position: Vector3` (cell centre), optional `size: Vector3` (default ONE),
`colour: int` (0 lemon, 1 lime, 2 mint, 3 sky, 4 lavender, 5 peach), and optional
`kind: String` (`solid`, `active`, `ghost`, `wall`, `cursor`, `target`, `hazard`). Snapshot
also carries `status: String`, `progress: float` in 0..1, `metric: String`,
`camera_target: Vector3`, `camera_size: float`. Use integer cube positions plus
0.5 height; islands end at Y=0. Render in a roughly 4x4 horizontal footprint.

`primary` (Space / big button), `left/right/up/down` (arrows or WASD),
`rotate_y` (E), `rotate_x` (Q), `undo` (U). Root owns restart, pause and navigation.
Models may ignore actions that do not apply. Each level JSON declares `id`,
`mode` (`stack`, `wall`, `shadow`), `name`, `biome`, `rule`, `controls`,
`time_limit` (seconds), `star_times` ([3-star seconds, 2-star seconds]) and tuning.
Each model owns three JSON levels. Seed must produce identical sequences.

`interaction_requested` exposes a payload for a future tournament adapter;
there is no multiplayer transport or opponent in this package. Keep its data
serializable. Never label a local effect as a successful network send.

Tests: `tests/minigames/<mode>_rules_test.gd` extends RefCounted and exposes
`static func run() -> Array[String]`. Return failures, not assertions that
silently continue. Tests use inline deterministic boundary fixtures. Root
runner executes all suites under Godot and returns nonzero on any failure.
