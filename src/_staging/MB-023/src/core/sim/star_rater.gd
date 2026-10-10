class_name StarRater extends RefCounted
## Time stars (Scoring & Stars rule 1; onboarding-accessibility F1 for relaxed timing). Pure and static.

## No time set for that star.
const NO_TIME := -1
## Relaxed timing multiplier in milli-units (onboarding-accessibility F1 `relaxed_time_scale` 1.5; ADR-0004 knob).
## ponytail: ticket said 2.0, the newer GDD says 1.5; pass the knob value as scale_milli once it is registered.
const DEFAULT_RELAXED_SCALE_MILLI := 1500
const MILLI := 1000
## Relaxed star times are rounded to 5 s (onboarding F1 round5).
const ROUND_MS := 5000


## 0 when lost, else 1 (finish), 2 (level_ms <= t2), 3 (level_ms <= t3 and no warning used).
## Missing t2/t3 -> 1 on a win. Usage: `StarRater.rate(level.stars, result, relaxed)`.
static func rate(stars: Dictionary, result: LevelResult, relaxed: bool, scale_milli: int = DEFAULT_RELAXED_SCALE_MILLI) -> int:
	if not result.is_won():
		return 0
	var t: Vector2i = star_times(stars, relaxed, scale_milli)
	var n: int = 1
	if t.x != NO_TIME and result.level_ms <= t.x:
		n = 2
	if t.y != NO_TIME and result.level_ms <= t.y and result.warnings_used == 0:
		n = 3
	return n


## (t2_ms, t3_ms) from the level's `stars` section; each is NO_TIME when absent. Relaxed: scaled, rounded to 5 s.
## Usage: `StarRater.star_times({"t2": 145000, "t3": 105000}, true)` -> (220000, 160000) at scale 1.5.
static func star_times(stars: Dictionary, relaxed: bool, scale_milli: int = DEFAULT_RELAXED_SCALE_MILLI) -> Vector2i:
	return Vector2i(_one(stars.get("t2"), relaxed, scale_milli), _one(stars.get("t3"), relaxed, scale_milli))


static func _one(v: Variant, relaxed: bool, scale_milli: int) -> int:
	if typeof(v) != TYPE_INT and typeof(v) != TYPE_FLOAT:
		return NO_TIME
	var t: int = int(v)
	if not relaxed:
		return t
	var scaled: int = t * (scale_milli if scale_milli > 0 else DEFAULT_RELAXED_SCALE_MILLI) / MILLI
	return (scaled + ROUND_MS / 2) / ROUND_MS * ROUND_MS
