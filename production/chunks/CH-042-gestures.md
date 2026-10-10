# CH-042 Gestures: tap / hold / drag / flick classifier

**Story:** INP-001 · **Model:** Sonnet · **Wave:** W1 · **Mode:** direct
**Goal:** pure classification for the touch drop button (tap = hard drop, hold = soft drop) and Scheme B (drag = move, flick = rotate).
**Depends:** none · **Parallel-safe with:** W1
**Files:** new `src/game/input/gestures.gd`, new `tests/unit/game/gestures_test.gd`.

## API
```gdscript
class_name Gestures extends RefCounted
## Pure touch-gesture maths. Thresholds come from control.* knobs (passed in, never read here).
enum Kind { NONE, TAP, HOLD, DRAG, FLICK }
static func classify(duration_ms: int, travel: Vector2, tap_ms: int, flick_ms: int,
		flick_min_px: float, dead_zone_px: float, cone_deg: float) -> Dictionary
	## {kind: Kind, dir: Vector2i}; dir is (±1,0) or (0,±1) for FLICK (screen-up = (0,-1)), else ZERO.
static func is_hold(elapsed_ms: int, tap_ms: int) -> bool              ## elapsed >= tap_ms (drop button: soft drop on)
static func drag_cells(projected_px: float, px_per_cell: float) -> int ## truncates toward 0; px_per_cell <= 0 -> 0
```

## Rules (in this order)
1. `|travel| <= dead_zone_px`: TAP if `duration_ms < tap_ms`, else HOLD.
2. `duration_ms <= flick_ms` and `|travel| >= flick_min_px`: FLICK if the angle to the nearest of ±x/±y is `<= cone_deg`, else NONE (diagonal flicks ignored, Touch GDD).
3. Otherwise DRAG.

## Tests first (`gestures_test.gd`; consts tap 150, flick 200, flick_min 40, dead 10, cone 30)
1. `test_tap_and_hold` — (100, (3,2)) TAP; (300, (3,2)) HOLD.
2. `test_flick_dirs` — (120, (80,5)) FLICK (1,0); (120, (-2,-90)) FLICK (0,-1).
3. `test_diagonal_flick_ignored` — (120, (60,60)) NONE.
4. `test_slow_long_is_drag` — (400, (90,0)) DRAG.
5. `test_drag_cells` — (130, 48) -> 2; (-50, 48) -> -1; (10, 0) -> 0.
6. `test_is_hold` — (149,150) false; (150,150) true.

## Run / Done when
`--import`, `-a res://tests/unit/game`. README "Done when"; 6 tests green.
**Out of scope:** nodes, hold-to-repeat (CH-095), Scheme B UI (CH-098), GUIDE (PLG tickets).
