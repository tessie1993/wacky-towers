# CH-178 Pause overlay (+ confirm dialogs)

**MB task:** MB-039 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-165, CH-170; GDD ux/pause
**Files:** new `src/ui/screens/pause/pause_menu.tscn` + `.gd`, `src/ui/common/snapshots/pause_snapshot.gd`, `src/ui/dialogs/confirm_dialog.tscn` + `.gd`; delete `src/ui/_staging/pause/`

## API
```gdscript
class_name PauseSnapshot extends RefCounted
var goal_icon: StringName; var goal_done: int; var goal_target: int; var star2_ms: int; var star3_ms: int; var rotated: bool
class_name PauseMenu extends UiScreen    ## &"pause", back_rule &"resume", PROCESS_MODE_WHEN_PAUSED; intents RESUME, RETRY (confirm), TO_MAP (confirm), OPEN_SETTINGS, OPEN_RULES
class_name ConfirmDialog extends UiScreen  ## &"confirm"; intents BACK (cancel), CONFIRM; default focus = cancel
```

## Behaviour
- Bottom sheet (P) / right panel (L); board visible dimmed 60% above/left. Resume 72 pt on top; Restart, Rules, Settings, Map as 56 pt icon+label buttons; goal reminder (icon + digits + both star times) at top. Rotated variant: Resume only highlighted.
- Restart and Map ask exactly one confirmation; Resume none. Back/Esc/Start = Resume (never quits).
- Resume beat (600 ms big "1") is PlaySession's job (later); this screen only emits RESUME.

## How the integrator sees it working
Scratch scene over a dimmed rectangle with `get_tree().paused`: Esc opens the pause menu, Esc again resumes. ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-039/`: P and L; Restart opens one confirm with cancel focused; keyboard/pad reach every button; menu works while the tree is paused.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
