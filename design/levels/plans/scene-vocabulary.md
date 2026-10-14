# Scene vocabulary: closed lists for `scene.terrain`, `scene.set_piece_action` and `cast_pose`

Owner: technical artist. Read by `tools/qa/check_level_uniqueness.gd` (U17). Seeded in phase 3 from the roster
and `exemplars.md`; phase 4 groups add ids only by a change request that the artist approves before the
`level_table` is checked. Rules: `campaign-vision.md` U17. **Ids are global**: one list for terrain and one for
actions, each growing to 20-30 ids (at least 20), with every biome using 7-8 distinct ids of each (none more than
twice) and every `(terrain, action)` pair unique across the campaign. An id may serve several biomes, each as a
biome-skinned build; the art budget counts builds (84-96), the vocabulary counts ids. The seeds here are the
starting point, not the final list. New ids are added only by change request, and each must be a place, not
"floating square".

Action kind: **cos** = cosmetic (never touches the board; has a static reduced-motion pose). **rule** = changes
the board (counts toward U10 and needs a handbook entry).

## cast_pose (closed)

`build`, `haul`, `cheer`, `hide`, `brace`, `point`, and `react` (animals and props only). A biome uses at least 4.

## Terrain seeds (the place the board sits in; not "floating square")

| id | Place | Seed use |
|---|---|---|
| `ravine_ledges` | trench between two mossy ledges | exemplar `ex_forest_05` |
| `stepped_ravine` | terraced trench | exemplar `ex_forest_h1` |
| `ship_deck` | an L-shaped deck | exemplar `ex_pirate_10` |
| `hilltop_ledge` | a grassy hill shoulder | exemplar `ex_meadow_01` |
| `treetop_platform` | a platform in the canopy | exemplar `ex_forest_02` |
| `dock_pier` | a harbour pier | exemplar `ex_pirate_03` |
| `bakery_counter` | a giant bakery counter | exemplar `ex_candy_03` |
| `reef_wall` | a sea wall between two coral towers | exemplar `ex_underwater_09` |
| `plank_bridge` | a bridge deck over water | to be assigned |
| `fort_wall` | a stone wall walk | to be assigned |
| `raft` | a drifting raft | to be assigned |
| `mine_shaft` | a timber shaft | to be assigned |
| `conveyor_deck` | a moving factory deck | to be assigned |
| `summit_ledge` | a mountain ledge | to be assigned |
| `floating_island` | the classic island chunk (one terrain among many) | to be assigned |

## set_piece_action seeds

| id | Kind | What it does |
|---|---|---|
| `root_whip` | cos | roots sway a vine-held bridge for show; it never moves or removes a block |
| `cannon_volley` | rule | `strike` variant: cannonballs knock out the top block of a lane (handbook#strike) |
| `tentacle_grab` | rule | `strike` variant: a tentacle pulls a block off the wall after a telegraph |
| `rock_throw` | rule | `strike` variant: a thrower lobs a rock that knocks out the top block of a lane |
| `catapult_volley` | rule | `strike` variant: a catapult strikes a lane after its arm cranks back |
| `icing_drip` | cos | icing drips down the cake stand as the plate tilts |
| `sails_turn` | cos | windmill sails turn faster as the stack rises |
| `bell_ring` | cos | a bell rings when a layer lands |
| `lantern_sway` | cos | lanterns swing with the wind |
| `smoke_puff` | cos | a chimney or vent puffs on each lock |
| `waterfall_pour` | cos | a waterfall pours louder as time runs down |

## Footprint shapes (closed list, U18; ruling B)

A footprint is `shape WxD` (for example `ring 10x10`); sizes run from 8x8 up to 12x12 (U5 pads to 12x12). Each
biome uses its own shape or size per level; a plain square is allowed once per biome. Every shape keeps the
corridor rule (spawn run 4 wide; every band, arm, tread, tower, link or leg at least 4 wide at the spawn rows
and at least 3 wide elsewhere). The script verifies each declared shape name against its mask with the
recognisers below ("floor" = `#` cells; "component" = a 4-connected floor region; widths are measured across
the thinnest cross-section).

A mask must match **exactly one** recogniser. When two match, the earlier row in this priority order names it:
plain square, ring, moat with centre island, cross, L, stair, bridge span, twin towers, crescent, island chain,
funnel, ship hull. The script rejects a declared name that is not the first match, so one mask never counts as
two shape names toward the U18 quota.

| Shape | Recogniser (all clauses must hold) |
|---|---|
| `plain square` | the mask is a full rectangle: no void cell at all (once per biome) |
| `ring` | one floor component with exactly one enclosed void hole; the outer boundary is a full rectangle (no notches); band width 3+ everywhere |
| `moat with centre island` | exactly two floor components (an outer ring and an inner island of at least 4x4) separated by one closed void band 1-2 wide; the outer ring band is 3+ wide |
| `bridge span` | one floor component with a void gap open on exactly one long side: gap width 3+, gap depth 2-3 rows, floor 4+ wide on both sides of the gap, and a floor base 3+ deep on the closed side |
| `twin towers` | one floor component: a base 3+ deep spanning the full width, plus exactly two towers, each 4+ wide and 4+ rows tall above the base, separated by a void gap 3-4 wide |
| `stair` | the column heights are monotone (all non-decreasing or all non-increasing) across 3+ distinct heights, and each tread (a run of equal height) is 4+ wide |
| `island chain` | 3+ floor components, each at least 4x4, joined in a path by links 3+ wide and 1+ cells long; the links are the only connections |
| `ship hull` | one component, symmetric about its long axis, with a flat stern (the full-width end row) and a **pointed bow**: the rows at the other end narrow to 2 cells or fewer over at least 3 rows; the widest part is 6+ wide. (A funnel's narrow end is 4+ wide, so the two cannot both match.) |
| `L` | the floor equals the bounding rectangle minus one corner rectangle of at least 4x4; both legs are 4+ wide |
| `cross` | the floor equals the bounding rectangle minus four equal corner rectangles of at least 3x3; all four arms are 4+ wide |
| `crescent` | one component forming a C: exactly one bay, bounded by floor on three sides and open on the fourth by 3+ cells, whose width changes by at least 2 across its depth (curved, not rectangular); band 4+ wide |
| `funnel` | one component, symmetric about the vertical axis, row widths non-increasing from top to bottom, narrowing by at least 4 cells in total, top row 8+ wide and bottom row 4+ wide |

More shapes (terraces, diamond, U-bay, stepping stones from the identity spec) are added by change request, each
with a recogniser. The set of shapes across a biome's 14 levels is at least 8 (U18).

## Off-list ids fail the U17 script

For example `sways` is not on the list. Any action that removes or moves a block is a **rule** and cannot be
marked cosmetic (this covers the defence family: `tentacle_grab`, `rock_throw`, `catapult_volley`).
