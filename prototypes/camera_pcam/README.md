# camera_pcam: phantom_camera portrait framing spike

**Status:** concluded (2026-10-14, addon audit)

## Hypothesis

Driving the gameplay camera through `addons/phantom_camera` (PhantomCameraHost + PhantomCamera3D)
improves 720x1280 portrait framing: the whole board stays inside the HUD-free board rect, so it never
runs under the top HUD (score / NEXT / goal chip) or the bottom control tray.

## How to run

```bash
timeout 300 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
  --resolution 720x1280 res://prototypes/camera_pcam/pcam_framing_capture.tscn -- [--biomes=meadow,celestial]
```

It boots the real `src/app/main.tscn`, starts `<biome>_01` the way `tools/qa/island_capture.gd` does
(and reuses that script's `_place_pieces` fixture), saves a BEFORE shot with the stock `WtStage`
camera, then attaches a PhantomCameraHost to the same Camera3D and a priority-10 PhantomCamera3D
whose ortho size and offset come from projecting the board AABB (footprint + 0.6 margin, floor to
playable top + 1) at all 12 yaw snaps into `_view_rect`. Output goes to
`production/qa/evidence/playtest-2026-10-14/addons/pcam_{before,after}_<biome>_720x1280.png`
and the console lines prefixed with `PCAM`.

## Findings

| Level | Camera | Ortho size | Board AABB, y px | Board rect, y px | Inside rect |
|---|---|---|---|---|---|
| meadow_01 | stock WtStage | 23.13 | 143 to 947 | 192 to 1050 | no: 49 px over the top HUD |
| meadow_01 | pcam prototype | 23.13 | 219 to 1023 | 192 to 1050 | yes |
| celestial_01 | stock WtStage | 23.13 | 113 to 964 | 192 to 1050 | no: 79 px over the top HUD |
| celestial_01 | pcam prototype | 23.13 | 196 to 1046 | 192 to 1050 | yes |

- Both cameras are width-bound in portrait, so the ortho size (zoom) is identical. Phantom camera has
  no ortho auto-fit: `auto_follow_distance` changes distance, which does nothing to an orthographic
  camera. The prototype had to compute the size itself.
- The visible gain is centring. `WtStage._update_camera()` aims at `(0, h_play * 0.36, 0)`. That puts
  the top of the playable volume about 50 to 80 px above the board rect, under the goal chip, at the
  height where a top-out stack would be. Centring the projected AABB in the rect fixes it, but the
  same few lines would do it in `WtStage` without the addon.
- Cost: the island floor sits about 75 px lower, closer to the View/Soft button row. It does not
  overlap in either biome.
- Verdict: **do not wire phantom_camera in to fix framing.** Its value here is blending between
  cameras (results or pause shots, tweened yaw), not fitting. A production fix is a story against
  `src/view/wt_stage.gd` (aim at the projected AABB centre). Production code must not import this.
