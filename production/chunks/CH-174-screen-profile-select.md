# CH-174 Profile select screen (list + delete confirm)

**MB task:** MB-034 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-168, CH-171, CH-172; GDD ux/profile-select
**Files:** new `src/ui/screens/profile_select/profile_select.tscn` + `.gd`, `src/ui/common/snapshots/profile_select_snapshot.gd`, `src/ui/dialogs/delete_profile_dialog.tscn` + `.gd`

## API
```gdscript
class_name ProfileSelectSnapshot extends RefCounted
var slots: Array          ## 4 entries: Dictionary {name, color, badge, stars, furthest} or null
var active_slot: int      ## -1 = none
var edit_mode: bool
class_name ProfileSelect extends UiScreen    ## &"profile_select"; intents SELECT_PROFILE {slot}, CREATE_PROFILE, RENAME_PROFILE {slot}, DELETE_PROFILE {slot}, BACK
```

## Behaviour
- 4 slot cards (2x2 portrait, 1x4 landscape, >= 150 pt). Filled: badge on colour, name, star total, furthest level. Active: ring + tick. Empty: "+" only on the LOWEST empty slot (others dotted, inert). Edit toggle shows rename and bin chips per filled card.
- Delete confirm dialog: names what is lost; default focus = keep; the bin button is inactive for 600 ms (`delete_arm_ms`, from `assets/data/ui/ui.json`, create the file with this value) with a filling ring.
- Default focus: the active card. Delete exists only in edit mode.

## How the integrator sees it working
Scratch scene with a `ProfileStore(MemorySaveIO)` and a small glue script (dev only) that feeds snapshots and applies intents. ADR-0016 rules: root extends `UiScreen`; one node tree for portrait + landscape via `OrientationLayout`; text only as `UI_*` keys added to `assets/i18n/strings.csv`; menu buttons fire on release; all targets >= 48 dp; inside the safe area; no state kept (render from the snapshot). Move/replace the matching file in `src/ui/_staging/` (written before the ux docs: reuse ideas, delete the old file when done).
Resize the window (godot-ai) to 390x844 and 844x390; screenshots to `production/qa/evidence/MB-034/`: 2x2 and 1x4 layouts; creating, switching, deleting through intents updates the cards; bin ignores a tap in the first 600 ms; keyboard-only reaches every card, edit, back.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
