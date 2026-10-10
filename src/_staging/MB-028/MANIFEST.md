# MB-028 (CH-171, CH-165, CH-172) -- staged paths mirror final paths
| Final path | Action | CH |
|---|---|---|
| assets/ui/themes/wt_base.tres | new (migrates src/ui/_staging/theme/wt_theme.tres; set `gui/theme/custom`) | 171 |
| assets/ui/themes/biomes/meadow.tres | new (StyleBoxFlat placeholders, frames only) | 171 |
| src/ui/common/theme_scaler.gd, ui_format.gd, ui_metrics.gd | new | 171 |
| src/ui/common/ui_kit.gd | new (moved from _staging/theme; GoldButton -> PrimaryButton) | 171 |
| tools/lint_ui_strings.gd | new (open in editor, File > Run) | 171 |
| assets/i18n/strings.csv | REPLACE (adds UI_BACK, UI_START, UI_SETTINGS, UI_TITLE_LOGO, UI_PROFILE_DEFAULT_NAME) | 171 |
| src/ui/common/snapshots/hud_snapshot.gd | new | 165 |
| src/save/save_io.gd, memory_save_io.gd, profile_store.gd | new | 172 |

Delete after move: src/ui/_staging/theme/{wt_theme.tres,ui_kit.gd}; repoint staged scenes to the new theme/kit paths.
Verify: see each CH "How the integrator sees it working".
Notes:
- Themes not editor-checked: open wt_base.tres and meadow.tres once to confirm they parse. InPlayButton press-action is a node property (ACTION_MODE_BUTTON_PRESS) set by the button script, not the theme.
- Not added: TabButton/ProfileCard/ToggleRow variations (ui-theme open question), fonts, colourblind variants. Base font sizes follow ui-theme.md pt table (14 body); prototype screens will look smaller than before.
- HudSnapshot.from_sim needs BoardSim.goal_progress() -> GoalState (not in board_sim.gd yet) and preview(n) (CH-064); danger check needs a BoardSim.board() -> BoardState accessor, else stays PLAY. Score is 0 until a score source exists. COUNTDOWN_MS mirrors knob goal.countdown_ms.
- ProfileStore uses ADR-0013 folder name `slot_<n>` (ticket said `profile_<n>`). create() also makes the new profile active (profile-select.md). stars/furthest read optional keys from slot progress.json.
