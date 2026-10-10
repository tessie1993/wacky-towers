# CH-173 Title screen + Quit dialog

**MB task:** MB-034 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-169, CH-171, CH-172; GDD ux/title
**Files:** new `src/ui/screens/title/title_screen.tscn` + `.gd`, `src/ui/common/snapshots/title_snapshot.gd`, `src/ui/dialogs/quit_dialog.tscn` + `.gd`

## API
```gdscript
class_name TitleSnapshot extends RefCounted
var has_profile: bool; var profile_name: String; var profile_badge: StringName; var profile_color: StringName
var continue_level_id: StringName; var continue_stars: int; var read_only_save: bool
class_name TitleScreen extends UiScreen    ## screen_id &"title", back_rule &"quit_dialog"
# intents: PLAY (first run), CONTINUE, OPEN_MAP, OPEN_SETTINGS, OPEN_PROFILES
class_name QuitDialog extends UiScreen     ## screen_id &"quit"; intents BACK (keep), QUIT (confirm); default focus = keep
```

## Behaviour
- States per ux/title: First run (logo + big Play + settings), Returning (profile chip top-left, big Continue with next level thumbnail placeholder and stars, Map, settings). Layouts from the P/L table (primary 72 pt pill, secondary 56, settings 44 top-right).
- Default focus: primary. Back/Esc -> quit dialog (AppFlow). Quit dialog: tick/cross icon buttons, cross default.
- Logo = Label placeholder `UI_TITLE_LOGO`; wizard diorama = empty `Control` slot `Diorama` (art later).
- Keyboard/gamepad can reach Play/Continue, Map, settings, chip.

## How the integrator sees it working
Scratch scene binds a first-run snapshot then a returning snapshot (`Mia`, level meadow_04, 2 stars). ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-034/`: first run shows Play only; returning shows chip + Continue + Map; Esc opens Quit dialog with the cross focused; arrow keys walk Continue -> Map -> settings in both orientations.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
