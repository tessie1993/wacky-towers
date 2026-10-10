# Toy-Box Trials Blender art pack

Three original decorative stages for the isolated minigame pack. Every stage has
an empty, planar 5×5 centre at **Godot Y=0**, 1 unit per cell. The runtime owns
grid tiles, pieces, lights, collision and mechanic indicators; these models carry
only the diorama body and quiet story props.

| Export | Wordless story props | Surface |
| --- | --- | --- |
| `env_meadow_arcade.glb` | repaired footbridge, wind pennant, rounded postbox, roots | desaturated sage |
| `env_clockwork_arcade.glb` | arched gear support, handwheel, cog repair scroll, underside gears | warm putty |
| `env_celestial_arcade.glb` | telescope, unlit star lamp, astrolabe, stone pendants | muted moon marble |

The silhouette, matte material treatment, neutral rim outline and sparse prop
placement follow `design/art/art-bible.md` §§1, 3, 4, 5 and 8. Props are outside
the central play area; a one-cell quiet margin is preserved for the primary story
props. A few low, decorative foliage accents sit on the exterior island rim.
Brass and star lamps are painted, with no emission, so they do not compete with
reward gold or effect colours.

## Rebuild

Blender **4.5.9 LTS**, build **8bf95cbd38d1**, produced the committed models. From
the repository root:

```sh
blender --background --threads 4 --python assets/source/blender/arcade_pack/build_arcade_pack.py
```

In this environment, replace `blender` with
`/workspace/scratch/49cfa27c5fba/tools/blender/run-blender.sh`. Add
`-- --skip-render` to regenerate the three GLBs and `.blend` without look-check
renders. The builder uses a fixed random seed and applies geometry modifiers and
transforms, recalculates outward normals, verifies no raised vertices enter the
5×5 play square, and exports standard glTF 2.0 Principled materials.

`arcade_pack.blend` stores all three named export collections and a
`PREVIEW_NOT_EXPORTED` light/camera/ground setup. Preview objects are excluded from
the GLBs. The source opens with Meadow visible; enable only one export collection
at a time to inspect the others, because each island deliberately shares the
same top-centre origin.

`manifest.json` records each model's final triangle count, size, Godot bounds and
SHA-256. Nine rendered front/rear/top look checks live in
`production/qa/evidence/arcade_pack/`. These renders verify clear play areas and
readability from opposite views; runtime screenshots verify the Godot handoff.
After rendering, run `python assets/source/blender/arcade_pack/make_contact_sheet.py`
(Pillow required) to arrange the nine views as one contact sheet.

No binary textures or external assets are required. Source and exports follow
the repository's MIT licence; see `LICENCES.md`.
