# CH-179 Results screen (win / loss)

**MB task:** MB-039 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-171, CH-087; GDD ux/results
**Files:** new `src/ui/screens/results/results_screen.tscn` + `.gd`, `src/ui/common/snapshots/result_snapshot.gd`; delete `src/ui/_staging/result/` (and fold `result_panel` from CH-062)

## API
```gdscript
class_name ResultSnapshot extends RefCounted
var won: bool; var stars: int; var star_conditions: Array[StringName]   ## per star: &"finished" | &"time" | &"no_warning"
var level_ms: int; var best_ms: int; var best_stars: int; var new_best: bool; var unlock_note: StringName; var is_last_level: bool
class_name ResultsScreen extends UiScreen    ## &"results", back_rule &"to_map"; intents NEXT, RETRY, TO_MAP
```

## Behaviour
- Sequence: win banner 0.8 s -> payoff skit slot (empty placeholder, tap skips) -> star stamp 0.4 s per star with condition icon -> buttons (Next primary, Retry, Map). Loss: loss beat 1.5 s -> Retry primary, Map. Any tap skips to the next state; reduced motion = no bounce, same order and timing.
- Buttons ignore input for 300 ms after they appear (screen-local gate). Default focus: primary.
- "New best" chip; replays with fewer stars show the kept best as small outlined stars; meadow_10 Next -> Map.
- Save-before-buttons is the game side's job (the snapshot arrives after it).

## How the integrator sees it working
Scratch scene: bind a win (2 stars, time 2:10) and a loss. ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-039/`: stars stamp in order; a tap during the first 300 ms of the button state does nothing; P and L layouts; keyboard/pad reach all buttons.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
