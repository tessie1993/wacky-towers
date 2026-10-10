# MB-009 / CH-047 Shape bank extractor + ShapeDef.source_pivot
| Final path | Action | See it working |
|---|---|---|
| src/core/shapes/shape_def.gd | replace | Adds `source_pivot: Vector3i` and optional 3rd arg `build(id, offsets, pivot)`. Also drops the duplicated `canonical_key/_rotated/_normalise/_serialise` in the current file (a parse error as it stands). `ShapeDef.build(&"i", [Vector3i.ZERO, Vector3i.RIGHT], Vector3i(1,0,0)).source_pivot` prints (1, 0, 0). |
| tools/asset-pipeline/extract_shape_bank.gd | new | After reimport, in the editor: `load("res://tools/asset-pipeline/extract_shape_bank.gd").extract("candy_toy")` returns `[]` and writes the bank; or headless `-s tools/asset-pipeline/extract_shape_bank.gd -- --set=candy_toy`. Pivot = cube nearest bbox centre (ties: smallest x, y, z) via `pick_pivot`. Writes nothing if a shape is disconnected, has duplicate cubes, or is a rotation twin of another. |
| assets/data/shapes/shape_bank.tres | GENERATED, integrator runs the extractor (not staged) | `ShapeBank.shapes.size()` is 67 (the `cube` file is skipped); `get_shape(&"t").distinct_count == 12`, `i` 3, `o` 3, `big_cube` 1. |

Notes: the 24 orientations (spin = Y, tilt = X, roll = Z, +/-90 each) already come from `Orientations`; the extractor needs nothing extra. Hand fields come from `shape_hand_fields.json` (currently all empty/0), else the old bank. Only the `candy_toy` set is read (ADR-0003 default). No tests (user rule).
