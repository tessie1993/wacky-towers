# CH-163 BoardStage: floor, grid and back-wall guides (readability)

**MB task:** MB-025 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** CH-041
**Files:** new `src/view/board_stage.gd` (`class_name BoardStage extends Node3D`)

## API
```gdscript
class_name BoardStage extends Node3D
func build(board_size: Vector3i, h_play: int, mask: PackedByteArray) -> void   ## floor slab, grid lines, two back walls, danger line at h_play
func set_danger(on: bool) -> void     ## dashed/red danger line pulses (static when reduced motion is on)
```

## Behaviour
- Block-rendering plan RND-06/08 and the HUD readability table: slate/meadow-green floor slab under active cells only (mask aware), thin grid lines on the floor, a faint grid on the two back walls (the walls away from the camera at the default yaw), a danger line at layer `h_play` drawn as dashes AND red with an exclamation mark at each end (not colour alone).
- Use simple `ImmediateMesh`/`MeshInstance3D` lines or a small quad with a grid shader; <= 10 nodes total. Colours are exported vars with `# ponytail:` defaults; art direction may retint later.

## How the integrator sees it working
Run the BoardView demo with the stage added: screenshot shows green floor, grid, back walls, dashed red danger line at layer 8 with exclamation-mark ends. Greyscale check still shows the dashes and the grid.

**Out of scope: biome-specific diorama (level scene).**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
