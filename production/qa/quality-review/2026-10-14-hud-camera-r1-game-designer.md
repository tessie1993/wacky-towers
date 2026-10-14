# HUD and camera turn, round 1: game designer (blind)

Reviewer speciality: game design. Anchor: everything existing scores 3/10. Pass mark 9.7.
Evidence read: ui-v2 after_hud_level1 and after_hud_full at 720 and 1280, after_hud_level1_720_vs_ref, before_hud_720,
camera-v2 turn_strip and framing, src/ui/game_ui.gd (HUD build, lines 1255-1594), src/view/wt_camera_turn.gd,
assets/data/camera_controls.json, design/levels/campaign/l01_meadow_01.md.
Not seen: the camera turn in motion, focus rings, gamepad play, left-hand mode, text scale. Feel claims are capped for that reason.

## Scoreboard

| Item | Score | Change since the 3/10 anchor (named) |
|---|---|---|
| H1 level-1 HUD clarity | 4.0 | before_hud_720 showed score, stars, 0:42, hold tray, 10-pill strip. after_hud_level1_720 shows only pause, plaque, NEXT, Hearth Hum, Turn, Drop. The disclosure is real and the next piece is readable. It loses points for the missing timer and the wrong goal. |
| H2 full HUD clarity | 3.5 | Score, clock and tray are now on carved plaques. The 10-pill strip with 13 px labels, "Fast fall" wrapping and a "40%" dead pill is still a control wall. |
| H3 HUD visual quality vs references | 4.0 | Plaques are purple wood with vines, not beige. Pause is a gem. Against ref 15 (after_hud_level1_720_vs_ref) the plaques are flat dark purple with tiny type, the NEXT icon is small, and the Hearth Hum meter is a plain bar. |
| H4 landscape layout | 3.5 | The d-pad and the right-hand cluster are placed. Level 1 landscape still shows 4 move arrows, Turn left and right, and a keyboard hint line. The board is small in the middle. |
| H5 accessibility and input | 3.5 | Code has focus rings, a left-hand option, a text factor, reduced-motion turn and a gesture pad. Strings are hardcoded. Nothing is captured to prove it. |
| C1 camera turn feel | 4.0 (capped) | The data is sound (200 ms, ease-out-back with 0.7 deg overshoot, 0.45 parallax, instant under reduced motion). Only a static strip exists, so feel is unproven. Cap 6 applies to anything above that. |
| C2 camera framing | 3.5 | The strip shows the scene with floating islands, the Wizard and a mouse, so the backdrop is richer. Framing clips the board at both edges, and the level-1 capture frames a different, much smaller board. |

All seven fail 9.7. No item reaches 5. Pass requires all three experts at 9.7 or higher.

## Ranked defects

1. **Level 1 has no timer, and the timer is the level.** l01_meadow_01.md section 2 sets a 2:00 `clear_n` goal, section 9 puts
   the timer in the plaque, and section 3 makes it visible in the last 30 s. after_hud_level1_720 and _1280 show no clock.
   `clock` is not in the level's `hud.show` list, and `_hud_has("clock")` hides it. The player cannot know the level has a deadline.
   Owner: level-designer (hud.show or sunrise bar contract) and ui-programmer (plaque timer bar, NEW-9).
2. **The goal text and meter do not match the level.** The plaque reads "Plant the first course 1 / 2". The design is
   "Clear 3 layers" (n = 3), with an objective line for 4 s. The Hearth Hum fill (about 35 percent) matches neither 1/2 nor 1/3.
   The camera-v2 captures read "Clear 2 full layers 0 / 2" with a "Balloon" pill, which is the stale `meadow_01.json`.
   Evidence is from two different level configs, and the HUD shows rules the design deleted.
   Owner: level-designer (fix meadow_01.json to the r2 spec) and ui-programmer (meter fill source).
3. **The captured level 1 is not the designed level 1.** The after_hud_level1 board is a plain 8x8 slab. There are no 20 rock
   columns, no 4-wide lane, no stump scene and no Wizard. The HUD cannot be judged against "fill the lane" until the board
   exists. The strip and framing captures use a richer scene than the HUD captures, so the shipped look is unclear.
   Owner: level-designer and gameplay-programmer (rock_obstacle data), producer (one canonical capture rig).
4. **Camera framing clips the board and fights the HUD.** In framing_720x1280 the board spans the full width and is cut at both
   edges, and a floating island with a castle sits behind the Hearth Hum bar and NEXT. In a 30 degree turn the corners swing
   outward and are clipped further. In the HUD captures the same board fills about 64 percent of the width, so framing is
   inconsistent. About 20 percent of the screen below the board is empty cloud. A turn must show the whole lane at every
   snap angle. Owner: technical-artist (camera fit-to-board on turn) and ui-programmer (safe zone).
5. **Control vocabulary is ambiguous.** "Turn" is the piece spin, "View" is the camera, and the camera turn is the feature under
   review. Landscape level 1 shows only Turn left and right and no View, so the camera turn is not reachable by a button.
   In the full HUD, "View", "Turn", "Flip" and "Roll" pills sit side by side with no icons. Whether move arrows stay
   screen-relative after a camera turn is not evidenced. Owner: game-designer and ux-designer (name and icon set,
   input-remap rule), gameplay-programmer (remap during the 200 ms turn).
6. **Full HUD readability.** The portrait strip uses 13 px labels in a pill about 40 px tall. "Fast fall" wraps. A disabled
   "40%" pill has no label and no meaning. "0:42" does not say whether it counts up or down. Landscape full puts 12
   buttons on the right, with Turn above Flip above Roll and no icons, which is too many for a first-time guest.
   Owner: ux-designer and ui-programmer.
7. **HUD text is too small and too faint.** The level name is 14 px and "Hearth Hum" is about 14 px in MUTED on a sky
   gradient. The NEXT frame is 112 px wide with a 72x56 piece. The Hearth Hum meter is a thin bar, not the flame glyph with
   three notes from the design, and it has no pips for the 3 layers. Owner: ui-programmer and art-director.
8. **Landscape level 1 is not minimal.** It shows 4 move arrows, 2 Turn pills, Drop and a keyboard hint line. The design says
   gestures or standard pad buttons, not extra HUD buttons. The Hearth Hum meter drifts to the top right beside NEXT, far
   from the goal plaque, so the player has to look across 800 px. Owner: ui-programmer and ux-designer.
9. **Accessibility is not provable.** Labels such as "Turn ‹", "Pause", "NEXT" and the help line are literal strings, which
   breaks ui-code.md (localization). The help line is keyboard-only with no pad glyphs. There is no capture of the focus
   ring, a 1.5x text scale or the reduced-motion turn. Owner: ui-programmer and qa-lead.
10. **Camera turn evidence is weak.** turn_strip shows 8 frames that look almost identical. There are no yaw labels, no overshoot
    frame marked and no parallax delta, so a reviewer cannot confirm a 30 degree move or the 0.7 degree overshoot. The strip's
    HUD also shows the stale level. Owner: technical-artist (labelled strip with t = 0, 100, 200, 260 ms).
11. **Visible seams in the backdrop.** There is a vertical stripe at about x = 330 in the 720 capture, and hard banding in
    the cloud floor in the 1280 capture. These are open defects that cap H3 and C2 at 8.5 in any case. Owner: technical-artist.

## Fixes by owner

- **level-designer**: bring meadow_01.json to the r2 spec (n = 3, 120000 ms, rocks, no balloon). List `clock` in
  `hud.show`, or move the timer into the plaque. Show the objective line for 4 s.
- **ui-programmer**: add the plaque sunrise timer bar (seconds only in the last 10 s). Build the Hearth Hum flame glyph with 3
  pips, driven by `{done, target}`. Pull all strings through tr(). Raise the minimum text to 16 px at 720 wide. Bring the
  landscape meter next to the plaque. Hide the d-pad and Turn pills on level 1 landscape unless a pad is absent (swipe
  and touch gestures are the core input).
- **ux-designer**: rename and icon the controls (camera "Look", piece "Turn"). Cut the full strip to 6 or fewer visible
  actions with a "more" tray. Label the clock count direction.
- **technical-artist**: fit the camera to the whole board at every snap. Add a safe margin of at least 24 px per side. Move
  distant islands out of the HUD zones. Fix the backdrop seam. Capture a labelled turn strip.
- **gameplay-programmer**: keep move and turn input screen-relative through a camera turn, with input buffered for the 200 ms.
- **qa-lead / producer**: one capture rig for level 1 (real design), at 720 and 1280, with focus ring, 1.5x text and reduced
  motion. Capture a 4-player split layout.
- **game-designer (me)**: playtest the two readings of "Turn" with 5 first-time players. The acceptance target is 4 of 5 turn a
  block by piece 3, which is what l01 section 11 criterion 16 already asks for.

## Open pillar tension for the user

"Minimal HUD" (4 elements) conflicts with "the timer must be seen". The design already resolves it by putting the timer in the
plaque. The build does not do that yet, so the conflict is open.
