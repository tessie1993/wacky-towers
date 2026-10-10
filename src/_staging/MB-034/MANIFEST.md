# MB-034 (CH-173, CH-174, CH-175) -- staged paths mirror final paths
Needs MB-027 (UiScreen, UiIntents) and MB-028 (theme, ProfileStore, UiFormat, MemorySaveIO) moved in first.

| Final path | Action |
|---|---|
| src/ui/common/orientation_layout.gd | new (minimal ADR-0016 §4 helper: size_changed -> `changed(is_landscape)` + safe-area offsets; no LayoutProfile resources yet) |
| src/ui/common/ui_glyph.gd | new (painted tick/cross/bin/pencil/dice/plus/back/lock + 8 badge silhouettes, colour table) |
| src/ui/common/snapshots/{title,profile_select,profile_edit,delete_profile}_snapshot.gd | new |
| src/ui/screens/title/title_screen.{tscn,gd} | new (CH-173); replaces src/ui/_staging/title/ (delete old) |
| src/ui/dialogs/quit_dialog.{tscn,gd} | new (CH-173) |
| src/ui/screens/profile_select/profile_select.{tscn,gd} | new (CH-174) |
| src/ui/dialogs/delete_profile_dialog.{tscn,gd} | new (CH-174) |
| src/ui/screens/profile_select/profile_edit.{tscn,gd} | new (CH-175) |
| assets/data/ui/ui.json | new (`delete_arm_ms: 600`) |
| assets/i18n/strings.csv | REPLACE (MB-028 file + 48 keys; merge if MB-028 already changed it). Re-import so `tr()` resolves |
| src/dev/ui_mb034_demo.gd | new, DEV ONLY: add a Control root scene with this script and run it (Title -> chip -> list -> create/rename/delete, Esc = back) |

Notes / deviations
- Screen trees are built in `_ready()`; the .tscn only holds root + script + screen_id (one tree for P and L; OrientationLayout flips the grid columns / BoxContainer direction / sheet anchors).
- Snapshots gained fields beyond the tickets: ProfileSelectSnapshot.read_only; ProfileEditSnapshot.slot and error_nonce (so a repeated error shakes again); DeleteProfileSnapshot is new.
- The Edit toggle emits `SET_PREF {key:"profile_edit_mode", value}` (no dedicated intent; screens keep no state). Add to UiIntents: `RANDOM_NAME` (now a const on ProfileEdit).
- Save tick in ProfileEdit emits CREATE_PROFILE / RENAME_PROFILE {name,color,badge[,slot]}; glue must validate via `ProfileStore.clean_name`.
- `reduced_motion` is a plain var on ProfileEdit and DeleteProfileDialog until UiPrefs/apply_prefs exists. Animation timings (shake) are placeholders, not from a UX spec.
- Accessibility names (AccessKit) not set: 4.7.2 property names unverified (ADR-0016 verification item 2). Tooltips only.
- Not editor-checked. Theme variations used: LogoLabel, HeaderLabel, SmallLabel, PrimaryButton, DialogPanel, PanelSheet (all in wt_base.tres).
- Verify: screenshots P (390x844) + L (844x390) into production/qa/evidence/MB-034/ per the CH "How the integrator sees it working".
