# Design reconciliation: Wacky Towers

Updated 2026-10-10. The user's request authorizes implementation and design
documentation. This record makes the running game's decisions and remaining
authored-content work explicit.

## Source order

1. The current build request and decisions in the active conversation.
2. Later approved design decisions in
   `production/orchestration/decisions-2026-10-10.md`.
3. Approved biome specifications, especially `design/levels/meadow.md`.
4. Accepted ADRs 0001–0017 for architecture and extension boundaries.
5. System GDDs, source-level drafts and the implementation plans.
6. The frozen `prototypes/first_playable/` reference.

The repository's studio workflows informed the work: `dev-story` for module
contracts and integration, `team-ui` for snapshot-only UI and responsive
screens, `asset-spec` plus the art bible for silhouettes/materials/source
provenance, `team-polish` for feedback and reduced motion, and `smoke-check`
for retained runtime evidence. Their local sources are under `.claude/skills/`.
The vendored Godot Game Dev Studio `godot-3d-lighting` and
`gamedev-game-feel` skills informed the single shadowed key, non-shadowed fill,
event-layered feedback and presentation/simulation separation. Its source and
notices remain under `tools/vendor/godot-game-dev-studio/`. `reverse-document`
provided the as-built provenance convention; observed behaviour is not new
authored design intent.
The explicit request to build authorizes necessary file writes; no commit or
push is implied.

## Implemented reconciliations

| Source conflict or gap | Production treatment |
|---|---|
| Prototype is the project entrypoint | Production starts `src/app/main.tscn`; prototype remains a reference. |
| Meadow 01 draft changed to 8×8 | Approved 4×4 board, H8, goal four clears restored. |
| Prototype offers only Turn/Flip | Production input vocabulary includes Turn/Flip/Roll and world-axis mapping. |
| Prototype has four camera views | Production stage has twelve snaps and free mouse orbit. |
| Sprout data uses `^`, old content table uses `s` | Canonical content glyph is reconciled by the content loader/table; malformed source data remains a named issue. |
| Candy block palette and shape metadata originally all neutral | Family colours use the shared Meadow palette; the active piece and board share its authoritative hue. |
| Proposed Orchestrator requires Android-native smoke proof | Plain GDScript application flow uses the ADR's fallback seam. No unverified OScript graph is described as working. |
| Latest economy uses spendable stars rather than original points | Earned campaign stars and the spendable wallet remain distinct; spending does not remove map stars. |
| Early save plan has one profile | Four local profiles have independent progress and settings. |
| Source audio direction mentions stems, later decision says no stems | One original looping track per biome is the current default; the user's final level tracks are replaceable resources. |
| Blender-generated mascot models are unavailable | Original procedural cloud wizard/helper and biome props are visibly labelled as placeholders in technical documentation. |
| Native physics look was suggested for Meadow 05 | Grid wobble remains a deterministic mechanic; no rigid-body simulation is substituted under that name. |

## Content fidelity

The campaign catalog exposes all ten planned biome identities: Meadow, Candy,
Ice, Underwater, Lava, Forest, Cave, Clockwork, Neon and Celestial. Nine biome
design files existed at checkout. Neon lacked a level-by-level source document;
any new Neon content is implementation-authored and must retain that provenance.
Side islands and Scrapbook were explicitly post-MVP in the source decisions.

For every generated level, `metadata.design_spec` preserves the authored source
where available, and `assets/data/campaign/implementation_coverage.json`
lists implemented rules and unsupported fields. A playable subset is not proof
that every source atom, skit and puzzle constraint has been completed. The
coverage file is the machine-readable source of truth and should be regenerated
when additional atoms or goals land.

Unresolved examples in authored source content include kit-box arrivals and
solution replay, multi-board layouts, bespoke boss goals/attacks, certain rock
and shelf definitions, and named Proposed/Candidate atoms. These must be built
as their own mechanics or remain explicitly unavailable; a generic gust or
clear goal must not silently claim their names. Level balance needs authored
solution runs or playtest evidence rather than automatically inferred targets.

## Presentation differences requiring final art work

The stage follows the art bible's hierarchy: bright bevelled blocks, a quiet
matte world, flat grid, organic silhouettes and a cloud wizard outside the
playfield. One repository block mesh and shared family palette currently serve
all biomes. Final per-biome block materials, painted textures, modelled living
contents, all four player-character meshes, nine bosses, hidden ducks, wordless
skits and connected map-story changes are separate production work.

Original synthesized cues and music can ship as authored placeholders. They do
not claim to be the user-provided per-level tracks or a sourced folk pack.
The synthesis source is retained so sounds can be regenerated and reviewed.

## Acceptance evidence boundaries

A valid level JSON establishes data consistency. A deterministic scripted win
establishes rules for that scenario. A retained screenshot establishes observed
appearance at its viewport. None replaces the other two.

The presentation probe and title have been launched and inspected in the
desktop software-rendered environment. Their retained files are under
`production/qa/evidence/build-2026-10-10/`. Android/iOS hardware controls,
OS reduced-motion discovery, phone performance, the final per-level audio and
LAN latency on separate physical devices remain separate evidence items.

Update this file when a difference is resolved; keep the approved design as the
reference and record the actual result rather than rewriting the source vision
to fit an incomplete implementation.
