# HUD and camera turn, round 1: Art Director (blind)

Method: judged from retained captures in `production/qa/evidence/ui-v2/` and `camera-v2/` against `assets/art/reference/style/15_title_and_hud.png` and `biome_screens_ref.jpg`. Anchor is 3/10 (reference-quality-bar.md). The HUD captures use a stand-in stage, so I judged the HUD chrome and not the scenery. Pass mark is 9.7.

## Scoreboard

| Item | Score | Why it is not higher |
|---|---|---|
| H1 level-1 HUD clarity | 4.0 | Four elements only, so the hierarchy is clean. The text is far too small and the meter is a hairline. |
| H2 full HUD clarity | 3.5 | A ten-button strip with 9 px labels, and floating score and timer plaques. |
| H3 HUD visual quality vs references | 3.5 | The plaques are flat purple slabs, not carved purple-wood. The reference has chunky, rounded, glossy frames. |
| H4 landscape layout | 3.0 | The island is tiny, the controls are scattered, and there is large dead space. |
| H5 accessibility and input | 3.5 | The tap targets are plausible, but the type is small and the labels are not iconic. |
| C1 camera turn feel (strip) | 3.5 | All eight frames are almost identical, so the turn is barely legible. |
| C2 camera framing | 4.0 | The island fills the portrait frame and is clipped at the edges. |

Each item rises at most 1 point above the anchor. The visible changes since the anchor are listed under "Changes that earn points" below. Several open defects remain. All items FAIL against 9.7.

## Changes that earn points

- Level-1 HUD (`after_hud_level1_720.png` against `before_hud_720.png`): the HUD is reduced to pause, goal, next and meter. The reference `15_title_and_hud.png` also shows a sparse top row of pause, score and next.
- The plaques are now purple with small vine sprigs on the corners, where the earlier build had flat UI. This is a direction match to the board-05 rule of purple-wood, but the execution is not there.
- `camera-v2/framing_720x1280.png`: the island is large and fills the frame, which is closer to the reference. The reference island sits at about 45% of the screen height.

## Ranked defects

1. **Type scale is far too small.** `after_hud_level1_720.png` and `framing_720x1280.png`: the "Meadow · First Sprout" and "Hearth Hum" labels are about 9 to 11 px at 720 wide. The NEXT label is about 10 px. The reference SCORE and NEXT labels are about 3 times larger, with chunky cream-on-dark lettering. This fails readability on a phone.
2. **Plaque material is not carved wood.** In `after_hud_full_720.png` and `after_hud_level1_1280.png`, every plaque is a flat violet fill with a thin bevel and a dark inset slot. There is no grain, no knots, no rounded-wood chunkiness, no highlight rim and no drop weight. Vines are 1 px sprigs at the corners. Reference 15 has thick rounded frames with leaf clusters and soft glow.
3. **Hearth Hum meter is a hairline.** The `after_hud_level1_720.png` meter is about 6 px tall and 130 px wide. It sits floating under the goal plaque with no frame and no icon. In `framing_720x1280.png` the empty bar reads as a dark line. It needs a carved trough, a fill with a glow and an icon.
4. **Landscape layout is unresolved.** `after_hud_level1_1280.png` and `after_hud_full_1280.png`: the island is about 30% of the width, and the move D-pad is on the far left, away from the action. In the full HUD, the 2x4 grid of View/Turn/Flip/Roll buttons is on the right. The text hints at the bottom are tiny. Hearth Hum is placed at top-right, away from the goal, with a floating label and no plaque. Large empty sky and cloud areas are left.
5. **Full-HUD control strip is crowded.** `after_hud_full_720.png`: ten pills ("View", "Flip", "Roll", "Fast fall", "Kit", "40%", "Potion 2") in one row. The labels wrap ("Fast fall"), the text is about 11 px, and the disabled "40%" is low-contrast. They are text-only, with no iconography. The Hold/Then tray is dark with tiny pieces, where the reference tray has 3 large lit slots.
6. **Score and timer plaques float mid-screen.** In `after_hud_full_720.png` they are placed at 40% width with no alignment to the top row, and the timer pill is a different green-olive style. The reference puts score in the top row beside pause and next.
7. **Pale tiles read as beige.** The board tiles in `framing_720x1280.png` are cream and tan. This is scene art, not UI, but it is near the no-beige user rule and clashes with the purple chrome. The reference board is cool grey stone.
8. **Camera turn strip barely shows a turn.** In `camera-v2/turn_strip_720x1280.png`, frames 1 to 8 show a rotation of about 10 degrees of drift and the island silhouette hardly changes. I cannot see an ease, an overshoot or a settle. The weight of a "turn" is not communicated. The strip should show at least 45 to 90 degrees with the island's key landmarks (wizard, windmill) moving through.
9. **Framing clips and crowds.** In `framing_720x1280.png`, the island overruns the left and right edges (flowers and the windmill are cut off). The "Balloon" chip collides with the distant floating island and the Hearth Hum label sits over it. The bottom third is empty cloud. Compose the island lower and keep a 24 px safe margin.
10. **Background seams.** In `after_hud_level1_1280.png` and `after_hud_full_720.png`, vertical seams and banding show in the cloud layer and the hills. This is a stand-in, but it is visible polish debt.
11. **Frame border is flat olive-green.** All captures: the screen border is a plain green stroke. The reference frames are textured, per-biome, with vine detail.
12. **Turn and Drop buttons are small.** In the portrait captures, Turn is about 55 px and Drop about 55 x 45 px, and both are tucked in the bottom corners. The reference PLAY button is huge and glossy. The Drop button also uses a different yellow-orange gloss from the purple language.

## Fixes with owners

| # | Fix | Owner |
|---|---|---|
| 1 | Raise the type scale: labels at least 18 px, the goal at 26 px, and a 2 px outline with a light stroke. Test at 720 wide. | ui-programmer, ux-designer |
| 2 | Re-author the plaque 9-slice as carved purple-wood: grain, a rounded chunky bevel, an inner highlight, a drop shadow and layered vine and leaf clusters at 2 corners. Provide a spec in the art bible. | art-director spec, technical-artist, UI maker |
| 3 | Build the Hearth Hum meter as a framed wood trough, 20 px or more tall, with an icon, a glowing fill and a tick for the goal. | UI maker |
| 4 | Landscape: anchor the goal and next top-left and top-right in a row, put the meter under the goal, use a tray bottom-centre, group controls into two thumb clusters (move and turn) and scale the island to about 50% of the height. | ux-designer, ui-programmer |
| 5 | Collapse the full-HUD actions into an icon row with 48 px targets and a tray of 3 large slots (Hold and Then). | ux-designer, UI maker |
| 6 | Align the score and timer into the top row with the same plaque style. | UI maker |
| 7 | Retint the tiles to cool grey-violet stone, as in biome_screens_ref. | world builder, technical-artist |
| 8 | Re-record the turn strip as a full 90 degree turn with ease-in-out and a small overshoot, 8 frames at even intervals. | gameplay programmer, technical-artist |
| 9 | Add a framing pass with safe margins and move the Balloon chip clear of the meter. | gameplay programmer, UI maker |
| 10 | Re-capture with the final scene, not the stand-in. | QA, builder |
| 11 | Replace the flat green border with a per-biome vine-and-wood frame. | UI maker |
| 12 | Enlarge Turn and Drop to at least 80 px, and restyle Drop in the purple-wood and gold family. | UI maker |
