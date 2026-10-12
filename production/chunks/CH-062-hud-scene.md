# CH-062 Greybox HUD + result panel bound from HudSnapshot

**MB task:** MB-033 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-165; GDD hud + ux/hud (Designed)
**Files:** new `src/ui/hud/hud.tscn`, `src/ui/hud/hud.gd` (`class_name Hud extends UiScreen`-compatible Control until CH-168 lands; make it extend `Control` and switch the base later), `src/ui/hud/result_panel.tscn`; demo `src/dev/hud_demo.tscn`. Delete `src/ui/_staging/hud/hud.tscn` and `result/result_panel.tscn` once moved (keep layout ideas)

## API
```gdscript
class_name Hud extends Control
signal intent(id: StringName, args: Dictionary)      ## &"pause"
func bind(snapshot: HudSnapshot) -> void            ## full re-render, idempotent
func on_sim_event(e: SimEvent) -> void              ## pop-in cues for goal_progress / layers_cleared
func board_rect() -> Rect2                          ## for BoardCameraRig.set_board_rect
```

## Behaviour
- Layout from `design/gdd/ux/hud.md`: top band (pause button, goal plate, rule strip, next-piece plate); board rect under it (92% W x 45% H portrait; 45% W x 57.5% H landscape); thumb zones reserved (TouchInput lives separately). Everything inside the safe area (use a root MarginContainer; insets from ScreenLayout later, 0 for now).
- Goal plate: icon + `done / target` digits. Clock: `m:ss` from `level_ms`. Next-piece plate: shape name text placeholder (ids) until previews exist. Rule strip: icons; > 5 -> "+N" chip.
- DANGER state tints plate edges warm. Opaque parchment plates, >= 18 pt digits; placeholder StyleBoxes are fine.
- Result panel: stars (3 slots), time, score, buttons Next / Retry / Map emitting `intent` `&"next"`, `&"retry"`, `&"to_map"`. Final skin is MB-039.
- No state owned: all text/numbers come from the snapshot.

## How the integrator sees it working
Run `src/dev/hud_demo.tscn` (feeds a hand-made HudSnapshot, buttons cycle states COUNTDOWN / PLAY / DANGER / PAUSED / RESULT). Screenshots (portrait 390x844 and landscape 844x390 by resizing the window via godot-ai) go to `production/qa/evidence/MB-033/` for each state in P and L show: goal `1 / 4`, clock, next plate, rule icons, no overlap with the board rect. Pause button press logs `intent pause`.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
