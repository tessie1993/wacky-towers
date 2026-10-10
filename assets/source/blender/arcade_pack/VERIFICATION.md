# Blender asset verification — 2026-10-10

Blender 4.5.9 LTS, build 8bf95cbd38d1. All original geometry and materials.
The builder recalculates outward normals and asserts zero raised decoration
vertices in the 5×5 play area, plus zero primary story-prop vertices in its
one-cell quiet margin. Central deck is planar at Blender Z=0 / Godot Y=0.

The exported binary files were read independently as glTF 2.0. Header sizes,
triangle counts and SHA-256 values match the manifest. No texture images,
animations, cameras or lights are embedded. Every material is non-metallic,
has roughness ≥0.9, and has no emissive colour. The runtime owns collisions.

| Model | Triangles | Materials | Bytes | Binary format/hash/material checks |
| --- | ---: | ---: | ---: | --- |
| env_meadow_arcade | 15,354 | 11 | 538,272 | PASS |
| env_clockwork_arcade | 16,600 | 10 | 481,028 | PASS |
| env_celestial_arcade | 13,926 | 8 | 396,020 | PASS |

Front, rear and overhead Blender look checks were visually inspected. Sparse
rounded story props leave the board clear, the island body remains quiet, and
flat painted brass and the star lamp do not use emission. These images are
art checks, not a substitute for Godot runtime or device performance testing.

Final file hashes and precise Godot bounds are in manifest.json.
