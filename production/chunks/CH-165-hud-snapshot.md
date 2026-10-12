# CH-165 HudSnapshot value type

**MB task:** MB-033 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-148, GDD hud (Designed)
**Files:** new `src/ui/common/snapshots/hud_snapshot.gd`

## API
```gdscript
class_name HudSnapshot extends RefCounted
enum State { HIDDEN, COUNTDOWN, PLAY, DANGER, PAUSED, RESULT }
var state: State = State.HIDDEN
var goal_icon: StringName = &""          ## &"layers" | &"height" | &"time" | &"shape"
var goal_done: int = 0
var goal_target: int = 0
var level_ms: int = 0
var score: int = 0
var star2_ms: int = 0
var star3_ms: int = 0
var next_shapes: PackedStringArray = PackedStringArray()   ## preview, head first
var rule_icons: Array[StringName] = []
var warnings_left: int = 0
var countdown_n: int = 0                  ## 3,2,1 during COUNTDOWN
static func from_sim(sim: BoardSim, level: LevelData) -> HudSnapshot   ## builds from sim.get_phase(), goal_progress(), preview(), now_ms()
```

## Behaviour
- Plain data only; no Node. `from_sim` is the only place that reads the sim. `DANGER` when the stack is within the warning margin of the limit (`stack_height() >= limit_layer() - 2`, constant with `# ponytail:`).
- Times are sim ms; formatting is a UI concern (`UiFormat`, CH-171).

## How the integrator sees it working
Editor script eval after CH-064: build from a fresh sim (state COUNTDOWN, countdown_n 3, goal_target 4, goal_icon layers, next_shapes size >= 1). Print the fields; read via `logs_read`.

**Out of scope: HUD scene (CH-062).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
