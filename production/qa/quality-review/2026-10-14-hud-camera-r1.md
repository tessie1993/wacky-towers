# HUD and camera, round 1: three blind experts (2026-10-14)

Panel: UX designer, art director, game designer, each fresh and blind to the others. Full reports:
`2026-10-14-hud-camera-r1-{ux-designer,art-director,game-designer}.md`. Anchor: user 3/10. Pass: all three >= 9.7.

| Item | UX | Art | Game | Lowest | Result |
|---|---|---|---|---|---|
| H1 level-1 HUD clarity | 5.0 | 4.0 | 4.0 | 4.0 | FAIL |
| H2 full HUD clarity | 3.5 | 3.5 | 3.5 | 3.5 | FAIL |
| H3 HUD visual quality vs refs | 3.5 | 3.5 | 4.0 | 3.5 | FAIL |
| H4 landscape layout | 4.0 | 3.0 | 3.5 | 3.0 | FAIL |
| H5 accessibility and input | 3.5 | 3.5 | 3.5 | 3.5 | FAIL |
| C1 camera turn feel | 4.0 | 3.5 | 4.0 | 3.5 | FAIL |
| C2 camera framing | 4.0 | 4.0 | 3.5 | 3.5 | FAIL |

## Merged fixes (deduplicated, owner-tagged)

1. **Text too small** (all 3 experts): secondary text at least 20 px, captions at least 24 px at 720 wide; plaque labels about 3x larger, as on ref 15. Owner: ui-programmer.
2. **Plaques are flat violet slabs** (art, UX): real carved purple-wood with grain, a chunky bevel, highlight and drop weight, and vines with mass; score/next plaques at reference size. Owner: ui-programmer with art-director spec.
3. **Meter is a hairline** (all 3): framed trough at least 28 px, flame/hearth icon, 3 pips for level 1 (one per clear), glow, value shown. Owner: ui-programmer.
4. **Level 1 timer missing; goal text stale** (game): add the themed timer (art-director design pending); goal plaque "Clear 3 layers"; meter 1/3 per clear; remove stale "Balloon" and `clear 2` data from meadow_01.json. Owner: level data + ui-programmer.
5. **Controller and keyboard focus dead** (UX): `game_ui.gd:1825` sets FOCUS_NONE on play buttons; give them a focus map without stealing piece-move keys. Owner: ui-programmer; godot-master decision.
6. **Full HUD dense and cryptic** (all 3): touch targets of 56 px, icon plus short label, two rows, no unlabelled "40%", clear Turn (piece) versus View (camera) icons. Owner: ui-programmer and ux-designer.
7. **Landscape unresolved** (all 3): level 1 landscape must be as minimal as portrait (no d-pad or help line on touch), with the meter beside the goal, controls grouped near the board, and the island bigger. Owner: ui-programmer.
8. **Camera framing clips the board** (all 3): fit the board's bounding circle inside about 88% of the width; keep scenery out of the HUD bands; fix the cloud seam. Owner: camera programmer and technical-artist.
9. **Turn feel unproven** (all 3): overshoot (0.7 deg) too subtle to see; the strip needs labelled yaw per frame with timestamps, or a short video. Owner: camera programmer.
10. **One canonical level-1 capture rig** (game): HUD captures must use the real stage with the designed level, not a stand-in. Owner: tools/QA and the Godot master.
11. **Hardcoded English strings** (UX): move to keys. Owner: ui-programmer.
