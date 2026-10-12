# MB-027 (CH-168, CH-169) -- new files, no replacements
| Final path | Action |
|---|---|
| src/ui/common/ui_screen.gd | new |
| src/ui/common/ui_layers.gd | new |
| src/ui/common/ui_intents.gd | new |
| src/game/screen_stack.gd | new |

Verify: CH-168/169 "How the integrator sees it working" (3 dummy UiScreens, push/pop order, base never popped).
Follow-up: make Hud (CH-062) extend UiScreen.

## Review
- ui_screen.gd: removed grab_focus() from enter(); AppFlow grabs default_focus() only in keyboard/gamepad mode (ADR-0016 §6, CH-170), avoids double grab.
- Checked, no change: no class_name collisions (UiScreen/UiLayers/UiIntents/ScreenStack unique across src/); ScreenStack does not call InputContextRouter (AppFlow does, CH-170), so no enum mismatch with MB-015 (Ctx.PLAY/PLAY_PAUSED/MENU/REMAP_CAPTURE).
