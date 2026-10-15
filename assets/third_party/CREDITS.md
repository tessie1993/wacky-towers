# Third-party assets

This folder is `.gdignore`d. Godot never imports these source files.

All previous third-party art (Poly Haven textures, BlendKit models) was removed on
2026-10-13 along with the old art (user decision; see `design/art/art-bible.md` v2).
Any new third-party asset must be CC0 or royalty-free, restyled to the art bible, and
listed here with its author, licence, URL and what it is used for.

| Asset | Author | Licence | URL | Used for |
|---|---|---|---|---|
| (none added 2026-10-14) | n/a | n/a | n/a | Asset Library and GitHub were surveyed for outline, toon, post-process, cloud and particle addons (see docs/architecture/adr-0020-painted-post-process.md). None met the Mobile+Compatibility, depth-aware requirement, so the post-process and sparkle FX are first-party code. |
| leafy_grass, brown_mud_leaves_01, rock_boulder_cracked (1k diffuse), single_root (1k glTF) | Poly Haven | CC0 1.0 | https://polyhaven.com/a/leafy_grass , /brown_mud_leaves_01 , /rock_boulder_cracked , /single_root | meadow_island_round (assets/models/levels/meadow_01): regraded textures; roots decimated. Originals in assets/library/ |
| rock_moss_set_01 (downloaded as colour/shape study only; not in grip_stones.glb) | Poly Haven | CC0 1.0 | https://polyhaven.com/a/rock_moss_set_01 | Original 1k glTF saved unmodified in assets/library/models/polyhaven/rock_moss_set_01/ as mossy-rock reference for assets/models/levels/meadow_01/grip_stones.glb (final stones are first-party procedural, vertex-colour painted) |
| Bark Brown 01 (diffuse 1k) | Rob Tuytel / Poly Haven | CC0 | https://polyhaven.com/a/bark_brown_01 | hearth_stump bark texture (blurred, posterised, palette-mapped); original in assets/library/textures/polyhaven/bark_brown_01/ |
| bark_brown_02 (1k diffuse) | Rob Tuytel | CC0 | https://polyhaven.com/a/bark_brown_02 | grip_roots_bark_1024.png (posterised, warm-remapped, moss band painted); original in assets/library/textures/polyhaven/bark_brown_02 |
| single_root, root_cluster_01 (reference only, no geometry used) | Rico Cilliers / Jenelle van Heerden | CC0 | https://polyhaven.com/a/single_root , https://polyhaven.com/a/root_cluster_01 | surveyed as bases; ground scans (61k/225k tris, flat) unusable for vertical fingers; originals in assets/library/models/polyhaven/ |
