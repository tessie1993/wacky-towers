# Scene vocabulary: closed lists for `scene.terrain`, `scene.set_piece_action` and `cast_pose`

Owner: technical artist. Read by `tools/qa/check_level_uniqueness.gd` (U17). Seeded in phase 3 from the roster
and `exemplars.md`; phase 4 groups add ids only by a change request that the artist approves before the
`level_table` is checked. Rules: `campaign-vision.md` U17. Each biome needs at least 7 terrain ids and 7 action
ids, none used more than twice, so the full lists below must grow to at least 84 terrain and 84 action ids
(7 per biome x 12). The seeds here are the starting point, not the final list.

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
| `cannon_volley` | rule | cannonballs knock out the top row (handbook#cannon_volley) |
| `sails_turn` | cos | windmill sails turn faster as the stack rises |
| `bell_ring` | cos | a bell rings when a layer lands |
| `lantern_sway` | cos | lanterns swing with the wind |
| `smoke_puff` | cos | a chimney or vent puffs on each lock |
| `waterfall_pour` | cos | a waterfall pours louder as time runs down |

## Off-list ids fail the U17 script

For example `sways` (from the near-miss exemplar) is not on the list.
