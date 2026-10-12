class_name UiMetrics extends RefCounted
## Device-independent size helpers (ADR-0016 §8, ACC-14).

## dp per inch baseline (Android definition).
const BASE_DPI := 160.0
## Smallest in-play button side in dp (decision sheet 2026-10-10).
const MIN_PLAY_DP := 56.0
## Smallest menu target side in dp (interaction-patterns P1).
const MIN_MENU_DP := 48.0


## Pixels per dp: DPI / 160 on mobile, 1.0 on PC. ponytail: ignores the canvas_items stretch factor; add it if buttons measure wrong on device.
static func dp_to_px() -> float:
	if OS.has_feature("mobile"):
		return DisplayServer.screen_get_dpi() / BASE_DPI
	return 1.0


## Minimum touch-target side in px. Example: min_button_px(true) == 56 on PC.
static func min_button_px(in_play: bool) -> float:
	return (MIN_PLAY_DP if in_play else MIN_MENU_DP) * dp_to_px()
