# Wacky Towers build report

Build date: 2026-10-10. Engine: Godot 4.7.2 stable, standard GDScript build.
This report describes a playable development build and its measured evidence.
It does not certify the full authored game or a polished platform release.

## Result and boundaries

The frozen prototype has been replaced as the entrypoint by a modular
production application. Campaign navigation, profiles, shop, options, arcade,
practice tournaments, direct LAN sessions and a read-only 3D stage are wired
around BoardSim. The existing shape bank contains 67 shapes; the gallery draws
its 395 source-orientation cubes through one MultiMesh.

The campaign catalog includes 118 level records across ten biome identities.
Some represent translated source specifications with unsupported requirements.
Those records preserve the source design and list unavailable gameplay in
`assets/data/campaign/implementation_coverage.json`. The current coverage file,
not the level count, determines whether an island is available. Coverage is
being updated alongside mechanics and must be re-counted for each packaged
build. All 118 records must not be described as fully implemented levels.

## Platform verification

| Target | Export | Launch / play evidence |
|---|---|---|
| Linux source project | Godot editor/runtime downloaded and running | GUI launches observed on Xvfb with Mesa llvmpipe; title, gameplay and presentation captures retained. |
| Linux executable | Packaging verification pending | Pending confirmation of export and independent executable launch. |
| Windows executable | Preset supplied; export planned | Windows runtime not available here; untested. |
| Web | Preset supplied; export planned | Browser runtime and LAN compatibility untested. |
| Android / iOS | No store-ready package supplied | Portrait layout capture is desktop evidence; physical-device and native platform checks remain open. |

The build uses the Compatibility renderer in this environment. llvmpipe is
software rendering, so these captures cannot establish mobile GPU performance,
minimum hardware specifications, battery behaviour or target frame rates.

## Retained runtime evidence

Evidence directory: `production/qa/evidence/build-2026-10-10/`.

| Evidence | What it establishes |
|---|---|
| `title.png` + adjacent Godot log | Production title launched and inspected at desktop landscape size. |
| `stage-landscape.png` + log | Actual bevelled source mesh, palette, active/locked pieces, landing ghost, floating island and original mascots rendered. |
| `stage-portrait.png` + log | The same presentation probe rendered at 720×1280. |
| `all-shapes.png` + log | All 67 bank silhouettes rendered; log records 395 cubes, valid cube mesh and one MultiMesh. |
| `lan/result.json` | ENet UDP transport test passed with four independent processes on localhost. |

`src/view/wt_stage_demo.tscn` is a rendering probe using a real simulation plus
a twelve-block fixture. It is not proof of campaign completion. The fixture
supports camera inspection and explicit mechanic-telegraph injection. A second
scene, `wt_shape_gallery.tscn`, displays bank geometry without gameplay.

Subsystem test reports are kept under `reports/`; the team is running final
integrated checks and will record their final counts beside the packaged build.
The LAN evidence above is actual independent-process transport, not an in-memory
mock. It does not measure play latency over a real phone/Wi-Fi network or prove
the complete application round lifecycle.

## Design gaps and source fidelity

The coverage file names unresolved gameplay, including kit-box arrivals,
solution replay, multi-board arrangements, bespoke bosses and named later-biome
atoms. Unsupported authored rules remain unavailable rather than being
relabelled generic gusts, clears or other mechanics. Neon has a biome identity
and original visual/audio treatment but lacked a detailed source level document.
New implementation-authored content must keep that provenance.

Procedural trees, floating islands, cloud wizard/helper and biome props are
original primitive-mesh placeholders. Final painted block sets, living content
models, four complete character meshes, bosses, hidden ducks, wordless skits
and map-story transitions remain production work. Audio has eleven original
synthesized cues and ten biome loops; the user's final per-level tracks are
absent. Balance, all campaign solutions and long playthroughs remain unverified.

Touch layout and keyboard/gamepad routing exist; separate controller hardware,
OS reduced-motion discovery, phone lifecycle/storage and mobile performance
checks have not been demonstrated. Separate physical-device LAN latency,
network fault/packet-loss behaviour and Internet matchmaking are not included
in the localhost result.

## Reproduction and ownership

See the root README for source launch, controls, test helpers and export
commands. `docs/architecture/as-built-game.md` describes module ownership,
read-only presentation, data validation, saves and transport.
`design/implementation/design-reconciliation.md` records implementation
choices against approved design rather than revising the vision to match gaps.

The original Claude Code Game Studios attribution/license and the vendored
Godot Game Dev Studio notices are retained. Studio tooling is excluded from
exports. The audio generation source is
`tools/asset-pipeline/generate_audio.py`, with provenance in
`assets/audio/README.md`. No external audio samples were introduced.

## Packaging update

The final export sizes, hashes, final test counts and executable launch evidence
will be added here after packaging. Until then the executable rows above remain
pending; export presets and source screenshots are not substitutes for launch
verification.
