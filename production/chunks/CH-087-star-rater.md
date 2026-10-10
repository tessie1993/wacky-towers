# CH-087 StarRater (time stars, relaxed scaling)

**MB task:** MB-023 · **Model:** Haiku · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-148, GDD scoring-stars (in revision: take values from the file at start time)
**Files:** new `src/core/sim/star_rater.gd`

## API
```gdscript
class_name StarRater extends RefCounted
static func rate(stars: Dictionary, result: LevelResult, relaxed: bool) -> int   ## 0 lost, 1..3
static func star_times(stars: Dictionary, relaxed: bool) -> Vector2i             ## (t2_ms, t3_ms), scaled when relaxed
```

## Behaviour
- meadow_01 data: `stars: {t2: 145000, t3: 105000}` ms. Win = 1 star; `level_ms <= t2` = 2; `level_ms <= t3` AND `warnings_used == 0` = 3 (ux/results: shield+clock condition).
- Relaxed timing (decision sheet): all 3 stars reachable, times scaled by the knob/constant (`RELAXED_SCALE = 2.0`, `# ponytail:` tune), no badge.
- Lost = 0. Missing t2/t3 -> fall back to 1 star on a win.

## How the integrator sees it working
Editor script eval: result won at 100000 ms, 0 warnings -> 3; at 100000 ms with 1 warning -> 2; at 200000 -> 1; lost -> 0; relaxed at 200000 ms/0 warnings -> 3 or 2 as the scale dictates (print). `logs_read`.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
