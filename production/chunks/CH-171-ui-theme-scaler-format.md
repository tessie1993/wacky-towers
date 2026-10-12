# CH-171 ThemeScaler, UiFormat and the string-key lint

**MB task:** MB-028 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168; GDD ux/ui-theme (Designed)
**Files:** new `src/ui/common/theme_scaler.gd`, `src/ui/common/ui_format.gd`, `src/ui/common/ui_metrics.gd`; migrate `src/ui/_staging/theme/wt_theme.tres` to `assets/ui/themes/wt_base.tres` (set as `gui/theme/custom`) and `ui_kit.gd` into `src/ui/common/`; new `assets/ui/themes/biomes/meadow.tres` (StyleBoxFlat placeholders)

## API
```gdscript
class_name ThemeScaler extends RefCounted
static func scaled(base: Theme, factor: float) -> Theme   ## copy with font sizes * factor; floors 12 pt body / 18 pt HUD digits
class_name UiFormat extends RefCounted
static func time_ms(ms: int) -> String       ## "m:ss"
static func stars(n: int, max_n: int = 3) -> String
class_name UiMetrics extends RefCounted
static func dp_to_px() -> float              ## DisplayServer.screen_get_dpi()/160 on mobile, 1.0 on PC
static func min_button_px(in_play: bool) -> float   ## 56 dp in play, 48 dp menus
```

## Behaviour
- Type variations from ADR-0016 §5: PlateFrame, PanelSheet, PrimaryButton, IconButton, InPlayButton, ToastPanel, DialogPanel, GoalDigits. Scenes use `theme_type_variation`, no per-node overrides. Free rounded font placeholder = Godot default until the font is chosen.
- Biome overlay `meadow.tres` holds only frame StyleBoxes for the same variations (flat wood-brown boxes for now).
- Add `tools/lint_ui_strings.gd` (EditorScript-style `@tool`, run from the editor menu): scans `src/ui/**/*.tscn` for `text = "..."` not present as a key in `assets/i18n/strings.csv`, prints the offenders.

## How the integrator sees it working
Editor: run the lint script, `logs_read` lists zero or the known offenders. Open `hud_demo` with the base theme: buttons/plates styled. `ThemeScaler.scaled(base, 1.5)` eval: a Label font size 24 reports 36.

**Out of scope: painted art, colourblind variants, final fonts.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
