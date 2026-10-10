# CH-059 `top` arrival plugin

**MB task:** MB-016 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-052 (RuleApi read subset), CH-047 (shape bank), CH-150
**Files:** new `src/mechanics/arrival/top_arrival.gd` (`class_name TopArrival`)

## API
```gdscript
class_name TopArrival extends ArrivalStyle
const PLUGIN_ID := &"top"
func plan_arrival(shape: ShapeDef, board: BoardState, api: RuleApi) -> ArrivalPlan
```

## Behaviour
- Spawn centred on the active footprint, in the spawn zone above the play height (layers `h_play .. size.y-1`), travelling along `board.down_vector()`, orientation = `shape.spawn_orient`.
- Origin: x/z so `shape.bbox(o)` is centred on the footprint (use `shape.min_corner(o)`; even sizes round toward -x/-z; masked-board tie rule G7 is a later chunk); y = `board.size().y - shape.bbox(o).y`, so the piece top touches the ceiling of the spawn zone.
- `plan.blocked = true` when `board.can_place(cells)` is false (cells = origin + offsets of the chosen orientation).
- Fields of `ArrivalPlan` already exist: origin, orient, travel_dir, blocked. No randomness.

## How the integrator sees it working
Editor script eval on the 4x4x12 meadow board with shape `i`: print origin, `blocked`, `travel_dir`. Expect `blocked == false`, `travel_dir == (0,-1,0)`, origin y in the spawn zone. Fill the top layer with SOLID and re-run: `blocked == true`. Read results with `logs_read`.

**Out of scope: other arrival styles, spawn-anchor on masked boards.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
