# HUD and camera turn, round 1: UX designer review (blind)

Reviewer speciality: information hierarchy, phone-size readability, 44 px targets, focus and controller navigation, safe areas, orientation.
Method: build review from retained captures in `production/qa/evidence/ui-v2/` and `camera-v2/`, plus `src/ui/game_ui.gd`, `wt_meter.gd`, `wt_camera_turn.gd`, `camera_controls.json`. Rules from `.claude/docs/reference-quality-bar.md` (3/10 anchor, start 5, stricter marking). HUD captures use a stand-in stage. Pass mark 9.7. I did not open any earlier review.

## Scoreboard

| Item | Score | Why it is not higher |
|---|---|---|
| H1 Level-1 HUD clarity | 5.0 | Disclosure works and the hierarchy is right, but the text is too small for a phone and the meter is weak. |
| H2 Full HUD clarity | 3.5 | A dense gem bar with cryptic labels, sub-44 px targets, and a disabled "40%" chip with no meaning. |
| H3 HUD visual quality vs references | 3.5 | Plum chips are on-palette and not beige, but they are small, flat and low-contrast against the sky and cloud, nowhere near board 15. |
| H4 Landscape layout | 4.0 | Safe-area insets exist, but the clusters are scattered and the board is tiny. The level-1 layout differs from portrait. |
| H5 Accessibility and input | 3.5 | Play buttons are not focusable, strings are hardcoded, and text is under 10 pt on a phone. |
| C1 Camera turn feel | 4.0 | The data and maths are sound, but stills cannot prove the feel and the overshoot is barely perceptible. |
| C2 Camera framing | 4.0 | The board bleeds off both screen edges and the sky clutter collides with the HUD. |

Nothing exceeds 3 on "named change since the anchor" except where I name it:
- **H1 (+2 over the anchor).** The named change is `after_hud_level1_720.png` vs `before_hud_720.png`. It now shows exactly pause, goal, next, a Hearth Hum meter, Turn and Drop (`game_ui.gd:1569-1576`, `_hud_has`), and the 56 px+ core buttons are large. The hierarchy follows the intended reading order.
- **H3, C1, C2 (+0.5 to +1).** Named change: purple-wood carved plaques with vine corners replace the cream chips (`after_hud_level1_720_vs_ref.png`, left panel against the cream reference plaques). They are not cream, which is correct. The vines are real art, but they are small.
- **No item reaches 9, so no 3-citation test applies.** Every item has open defects, so each is capped at 8.5 in any case.

## Ranked defects

1. **Play controls cannot take focus, so controllers cannot navigate.** `game_ui.gd:1825`: `_play_button` sets `b.focus_mode = Control.FOCUS_NONE`, and only pause and hold override it (`:1275`, `:1464`). Turn, Drop, move, view, flip and fast fall are unreachable by pad or Tab. The gold focus ring (`_focus_ring`, `:299`) is dead code on those buttons. Fails the checklist items "usable with keyboard only" and "gamepad only". Owner: ui-programmer. Escalate to godot-master for the input and focus map.
2. **HUD text is too small at phone size.** The viewport is 720 px wide on a ~390 pt phone, so 1 px is about 0.54 pt.
   - The level name is 14 px (`:1288`), about 7.5 pt.
   - The meter caption is clamped to `size.y*0.34`, about 16 px (`wt_meter.gd:49`).
   - The help line is 13 px (`:1513`).
   - The meter trough is about 16 px tall (`wt_meter.gd:50`), a thin bar, a weak status read.
   - `after_hud_level1_720.png` shows "Meadow · First Sprout" and "Hearth Hum" nearly unreadable against the sky.
   - Fix: minimum 20 px for secondary text and 24 px for captions at 720 wide. Trough at least 28 px, with a numeric or tick value (the goal says 1/2, the meter does not). Owner: ui-programmer, with art-director for the type scale.
3. **Full-HUD gem bar targets are under 44 px and the labels are cryptic.** In `after_hud_full_720.png` the bar buttons are about 36 px tall (y 1062-1100) and 58-70 px wide, which is about 19 pt tall on a phone, against a 44 pt minimum.
   - "Flip ‹", "Roll ‹", "Kit" and "Potion 2" are opaque jargon.
   - "40%" is a greyed button with no caption or meaning.
   - "▼ Fast fall" wraps to two lines.
   - Nine controls sit in one row, which breaks progressive disclosure on the full HUD.
   - Fix: two rows or an icon plus label at 56 px. Replace the arrows with glyphs. Rename or explain the disabled state. Owner: ui-programmer, with game-designer for naming.
4. **The camera frames the board edge to edge.** In `camera-v2/framing_720x1280.png` and in all 8 strip frames, the board's grass and flowers are clipped at x≈10 and x≈710, and a floating island is clipped at the right edge. During a 30° turn the board corners swing further out. The board covers about 100% of the width, with no breathing room for the biome frame and thumb zone.
   - The "Balloon" chip sits under the meter, and a floating castle hides behind the meter (framing y 100-200). Foreground clutter fights the HUD.
   - Fix: fit the bounding circle of the board footprint (turn-safe) inside about 88% of the width (`ortho_framing.gd`). Move the Balloon chip out of the meter column. Keep distant props clear of the HUD safe band. Owner: world builder / camera programmer.
5. **Level-1 landscape differs from portrait.** `after_hud_level1_1280.png` shows a full 4-way d-pad plus "Turn ‹ / Turn ›" plus a keyboard help line. Portrait uses gestures plus one round Turn. The d-pad shows on level 1 (core) but leaves a lot of empty space. The meter floats top-right with its caption in a gap, apart from the goal plaque, so the goal and its progress meter are separated by about 600 px. The board is about 310 px of 1280 wide. The keyboard line is shown on touch devices. Owner: ui-programmer for the layout, art-director for the board scale.
6. **The turn's overshoot is invisible.** `camera_controls.json:36-38`: 200 ms, overshoot 0.8, about 0.7° of 30°. A 0.7° overshoot at 60 fps is under 0.5 px at board edge for a few frames, so there is no "settle". The strip has no timestamps and its 8 frames look near-identical. Cannot prove feel from stills. Owner: gameplay programmer. Add a timestamped strip or a short capture of the turn, and raise the overshoot to about 1.5-2.5°.
7. **Hardcoded English strings.** `game_ui.gd:1501-1513` ("Turn", "Flip", "Roll", "WASD move..."), `:1624-1625` and `:1730`. This breaks `.claude/rules/ui-code.md` (localization). Owner: ui-programmer.
8. **The Drop button is inconsistent.** It is a wide gold lozenge in level-1 landscape and a narrow one beside Fast fall in full landscape (`after_hud_full_1280.png`). The primary action loses prominence when more controls appear. Keep it fixed in size and position. Owner: ui-programmer.
9. **The vs_ref comparison shows a gap.** The reference score and next plaques are large (about 150 px each) with big gold type and three-star rows. Ours are about 110 px, with 14 px captions. Owner: art-director.

## Concrete fixes (with owner)

| # | Fix | Owner |
|---|---|---|
| 1 | Set `focus_mode = FOCUS_ALL` on every play button and add a focus map and neighbours (gem bar, Turn, Drop, pause). Test with pad-only and keyboard-only runs. | ui-programmer (godot-master to confirm) |
| 2 | Type scale: body at least 20 px, captions at least 24 px (at 720 wide). Meter trough at least 28 px with a value label. Check at 1.0, 1.3 and 1.6 text factors. | ui-programmer, art-director |
| 3 | Gem bar: at least 56 px targets, icon plus short label, two rows when over 6 items. Explain or hide the "40%" chip. | ui-programmer, game-designer |
| 4 | Frame the board's bounding circle inside 88% of the width. Add a turn-safe margin. Keep the HUD band (top 22%, bottom 18%) free of scenery. | world builder, camera programmer |
| 5 | One level-1 layout for both orientations (Move, Turn, Drop). Pin the meter under the goal plaque in landscape. Hide the keyboard help on touch. | ui-programmer |
| 6 | Raise the turn overshoot to about 1.5-2.5° and capture a timestamped turn strip (every 16 ms). | gameplay programmer |
| 7 | Move all HUD strings into `tr()` keys. | ui-programmer |
| 8 | Fix Drop to a constant size and anchor. | ui-programmer |
| 9 | Enlarge the plaques and type for parity with the references. Verify no cream anywhere. | art-director |

## Notes and limits

- I did not read `ortho_framing.gd` or `wt_camera_controls.gd`. The framing finding is from captures only.
- Safe-area insets are handled in code (`_safe_insets`, `:1579`) but there is no capture with a notch, so I give no credit for them.
- The stand-in stage means the HUD-over-board interactions (a tall tower colliding with the header) are unverified.
- No beige or parchment found: the plaques are plum wood, the board floor tiles are pale tan, which is the scene and not UI.
