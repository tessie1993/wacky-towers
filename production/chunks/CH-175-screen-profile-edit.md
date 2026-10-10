# CH-175 Profile create/rename panel

**MB task:** MB-034 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-174
**Files:** new `src/ui/screens/profile_select/profile_edit.tscn` + `.gd`, `src/ui/common/snapshots/profile_edit_snapshot.gd`

## API
```gdscript
class_name ProfileEditSnapshot extends RefCounted
var is_rename: bool; var name: String; var color: StringName; var badge: StringName; var error_key: String
class_name ProfileEdit extends UiScreen    ## &"profile_edit"; intents SET_PREF {key, value} for name/color/badge, RANDOM_NAME, SAVE (CREATE_PROFILE or RENAME_PROFILE), BACK
```

## Behaviour
- Name LineEdit pre-filled (random friendly name from `UI_PROFILE_NAME_*` keys), dice button, 6 colour chips, 8 badge chips (painted silhouettes later: use distinct simple icons), tick button full-width 64 pt. Enter = tick.
- Invalid (empty/duplicate name): tick stays enabled, press shakes the field once (outline only with reduced motion), shows `UI_PROFILE_NAME_TAKEN` / `UI_PROFILE_NAME_EMPTY`, writes nothing (the glue/game side validates with `ProfileStore.clean_name`).
- Default focus: the tick (one press accepts the pre-filled name). Gamepad: dice, then colour/badge rows by d-pad.

## How the integrator sees it working
Scratch scene: create flow with the MemorySaveIO store. Screenshots P+L to `production/qa/evidence/MB-034/`: panel is a bottom sheet in P, right panel in L; Enter on the pre-filled name creates the profile; duplicate name shakes and shows the error line.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
