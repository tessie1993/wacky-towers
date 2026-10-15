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
| cliff_waterfallTop_rock (rim_waterfall lip base) | Kenney | CC0 1.0 | https://kenney.nl/assets/nature-kit | Base mesh for the rim_waterfall rock lip (original saved in assets/library/models/kenney/) |
| aerial_grass_rock diffuse 1k (rim_waterfall rock texture, resized to 512) | Rob Tuytel / Poly Haven | CC0 1.0 | https://polyhaven.com/a/aerial_grass_rock | Rock texture on rim_waterfall lip (original in assets/library/textures/polyhaven/) |
| Qwantani Dawn (Pure Sky) HDRI, 2k | Greg Zaal / Poly Haven | CC0 | https://polyhaven.com/a/qwantani_dawn_puresky | meadow_01 sky step 0 (dawn): assets/textures/sky/meadow_01/dawn.hdr |
| Qwantani Sunset (Pure Sky) HDRI, 2k | Greg Zaal / Poly Haven | CC0 | https://polyhaven.com/a/qwantani_sunset_puresky | meadow_01 sky step 1-2 (golden morning): assets/textures/sky/meadow_01/gold.hdr |
| Qwantani Dusk 2 (Pure Sky) HDRI, 2k | Greg Zaal / Poly Haven | CC0 | https://polyhaven.com/a/qwantani_dusk_2_puresky | meadow_01 sky step 3 (sunset): assets/textures/sky/meadow_01/sunset.hdr |
| Wooden Spoon (model, decimated, thickened, retinted) | Poly Haven | CC0 1.0 | https://polyhaven.com/a/wooden_spoon | meadow_01 wooden_spoon.glb; original kept in assets/library/models/polyhaven/wooden_spoon/ |
| Hessian 230 (texture, 1k, retinted olive-brown) | Colormass (photo), Rico Cilliers (processing) | CC0 1.0 | https://polyhaven.com/a/hessian_230 | meadow_01 wrong_sack.glb burlap |
| rim_cage (meadow_01) | Kenney (Nature Kit rocks) + Poly Haven (single_root, shape study; bark/mossy-rock painted textures reused from env_obstacle_*) | CC0 | https://kenney.nl/assets/nature-kit ; https://polyhaven.com/a/single_root | rim_cage.glb: Kenney rock meshes restyled (grey, moss) as stone stacks; roots are tubes built in Blender, painted bark texture |
| (none, cottage_windmill 2026-10-15) | n/a | n/a | n/a | PolyHaven has no cottage/windmill; BlenderKit CC0 hits (Forest Cabin, Old Farm Windmill) need an account key to download (403). Cottage and windmill are first-party Blender builds. |
