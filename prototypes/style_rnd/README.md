# Style R&D prototypes (`prototypes/style_rnd/`)

**Status:** concluded (2026-10-13). Findings live in `design/art/style-techniques.md`.
Throwaway code. Nothing in `src/` may import from here; rewrite to production standards.

## Hypotheses
- (a) A procedural "painted" spatial shader (wrap + 2-tone ramp + tinted shadows + fresnel rim +
  painted edge light + cap mask) makes a rounded block read like ref 13 **under Compatibility**.
- (b) A purple-wood frame modelled and lit in Blender (Cycles CPU, procedural wood, baked-in
  edge highlight + AO) can be used as a Godot `NinePatchRect` at several sizes, like refs 05/08.
- (c) One shared Environment preset + one 3-light rig gives the warm ref-15 look and can be
  swapped per biome (meadow, ice) without per-scene tweaking.

## Run
```
B=/tmp/claude-0/blender/blender-5.2.2-linux-x64/blender
$B -b -P prototypes/style_rnd/blender_frame_ninepatch.py                       # panel frame
WT_VARIANT=chip   $B -b -P prototypes/style_rnd/blender_frame_ninepatch.py     # thin HUD chip frame
WT_VARIANT=screen $B -b -P prototypes/style_rnd/blender_frame_ninepatch.py     # no parchment (screen border)
G='timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3'
eval $G --resolution 1280x720 -s res://prototypes/style_rnd/block_demo.gd
eval $G --resolution 1280x720 -s res://prototypes/style_rnd/ui_demo.gd
eval $G --resolution 720x1280 -s res://prototypes/style_rnd/island_demo.gd -- biome=meadow   # or biome=ice
python3 prototypes/style_rnd/make_side_by_side.py   # labelled ref-vs-prototype images
```
Screenshots: `production/qa/evidence/style-rnd/`.

## Files
| File | What |
|---|---|
| `style_kit.gd` | Shared Environment preset, 3-light rig, painted backdrop, rounded-box mesh, nine-patch + multicolour title helpers |
| `spatial_proto_painted_block.gdshader` | Painted block / prop shader (custom `light()`) |
| `canvas_proto_backdrop.gdshader` | Painted 2D sky backdrop drawn behind 3D via `BG_CANVAS` |
| `blender_frame_ninepatch.py` | Procedural purple-wood frame, vines, blossoms, iron caps, gold stars |
| `renders/` | Frame renders (1024 px, 2x) + nine-patch margin JSON |
| `fonts/` | Lilita One (OFL), Titan One (OFL), Luckiest Guy (**Apache-2.0**) + licence texts |

## Findings (short)
- (a) PASS with gaps: shape, cap, palette and light response match ref 13; grass lacks tuft geometry.
- (b) PASS: nine-patch works if size >= 2x margin; needs one render per size class (panel / chip / screen).
- (c) PASS for lighting; FAIL for Godot `Sky` + global fog under Compatibility -> use `BG_CANVAS`
  backdrop + per-material haze instead. Backdrop scenery (distant islands, mountains) is the largest gap.
