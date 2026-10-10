class_name UiFormat extends RefCounted
## The one place UI numbers become text (ADR-0016 §9). Screens never concatenate digits.

const FILLED_STAR := "★"
const EMPTY_STAR := "☆"


## "m:ss" from sim milliseconds (negative -> 0:00). Example: time_ms(65000) == "1:05".
static func time_ms(ms: int) -> String:
	var s: int = maxi(ms, 0) / 1000
	return "%d:%02d" % [s / 60, s % 60]


## Filled/outlined star row. Example: stars(2) == "★★☆".
static func stars(n: int, max_n: int = 3) -> String:
	var c: int = clampi(n, 0, max_n)
	return FILLED_STAR.repeat(c) + EMPTY_STAR.repeat(max_n - c)
