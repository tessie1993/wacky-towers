# Campaign geometry and finite-puzzle decisions — 2026-10-10

Status: Implemented under the user's direction to build the whole game and make the levels differ; parent integration authorized the data amendments. Original authored JSON remains in each level's `metadata.design_spec`. The JSON amendment ledger is the reproducible input to `tools/author_campaign.py`; official scene dressing is preserved.

## Ice10: gravity-frame sketch versus physical board

The source design explicitly labels its width/depth/height sketch as awaiting the ADR-0002/0005 re-indexing call. Its prose calls for12 travel layers and a6×5 cross-section. The existing ADR/core contract uses physical `size=(width,h_play+C,depth)` and, for−X, `danger=width−C`; the clearing plane is physicalY×Z. Fresh Godot4.7.2 evidence measures standard-pool `C=4`, so the original width12/depth6/h_play12 produces12×16×6, danger8 and96 cells per plane. An earlier static audit assumedC6 and reported108 cells; that estimate is superseded by the actual engine record.

The amended JSON is width16/depth3/h_play6, `down_axis=-x`, `spawn_anchor=[4,1]`. Physical dimensions become16×10×3, danger12 and30 cells per YZ plane. The new cross-section is10×3, preserving area30 while satisfying the existing height/spawn constraints. All16×3 footprint-mask entries are active; no cross mask is introduced. On X gravity, spawn-anchor components address Y/Z, so `[4,1]` centers the ground-plane spawn. Standard shapes fit the10×3 ground plane, with their long axis available in X or Y.

| Contract | Original interpreted JSON | Amendment |
|---|---:|---:|
| Spawn clearance |4 |4 |
| Physical dimensions |12×16×6 |16×10×3 |
| Playable travel layers |8 |12 |
| Cells per full clear plane |96 |30 |
| Four-clear material work |384 cells |120 cells |

No core axis formula or gravity speed changed. The eight standard shapes, four-clear objective, g0=1.10, gust schedule, slide after clear2 and190/270-second stars remain source-authored. Ordered engine verification confirms the amended dimensions, legal spawn and actual locks. A complete unassisted win and human star calibration remain to be measured; material work is not a time lower bound.

## Variety and survival-star changes

Clockwork05 and Forest05 previously shared all structural gameplay inputs. Clockwork05's4×5 footprint/height8 objective keeps its tower breather while changing placement geometry. At0.6 coverage, both have nominal work96 cells; this equality is a planning measure, not a completion-time observation.

Neon had no authored source design. Neon06's proposed sign uses two full4×4 layers and two centered2×2 cap layers, totaling40 cells. `[BigCube,BigCube,I,I,O,O,O,O]` supplies exactly40 cubes and wins in the constructive replay. Neon08's150-second survival goal now rates clears with `s2=1,s3=2`; its previous170-second third-star timer rewarded every clean completion automatically. Neon remains a proposed implementation design awaiting author review and player tuning.

## Finite picture/packing proofs and minimum budgets

The solver checks the actual ShapeBank orientations, exact target/flavour cells, fixed order or kit multiplicities, no occupied overlap, straight ingress and rigid gravity support. It applies mirror overwrite-skip semantics and the Clockwork bonus's authored two-lock turn cadence. The resulting witnesses were replayed through real BoardSim; every row below reachedWIN without trimming.

| Level | Target cells | Original budget | Witness pieces | Minimum volume bound |
|---|---:|---:|---:|---:|
| Meadow bonus |32 |6 |6 |6 |
| Candy bonus |32 |6 |6 |6 |
| Ice bonus |32 |6 |6 |6 |
| Underwater06 |36 |9 |9 |9 |
| Underwater bonus |36 |7 |7 |7 |
| Lava bonus |28 |7 |7 |7 |
| Forest06 |24 |6 |6 |6 |
| Forest bonus |32 |9 |9 |9 |
| Cave07 |24 |3 |3 |3 |
| Cave bonus |32 |6 |4 |4 |
| Clockwork06 |28 |7 |7 |7 |
| Clockwork bonus |28 |7 |7 |7 |
| Neon06 |40 |8 |8 |8 |
| Celestial06 |24 |6 |6 |6 |
| Celestial bonus |24 |5 |5 |5 |

The witness matches the lower bound in every row, proving the minimum piece count for that inventory and volume rule. Cave bonus intentionally leaves two kit choices unused. Mirror supplies the apparent missing Cave material; the eight-cube BigCube supplies the apparent missing Celestial material. No source budget was raised. Source hints/solutions are retained as metadata; these solver witnesses independently establish feasible geometry.

Machine-readable placements are in `assets/data/campaign/puzzle_proofs.json`. Actual replay evidence is in `production/qa/evidence/full-build/biome-level-verification.json`; `tests/integration/gameplay/puzzle_packings_test.gd` repeats the winning assertions. The fixture directly establishes each legal sky orientation/position, so it proves simulation feasibility and inventory sufficiency, not a timed human input sequence or every random picture level.
