# MB-010 manifest (CH-084 skipped by request)

| Staged | Final path | Action | See it work |
|---|---|---|---|
| CH-048/src/core/sim/active_piece.gd | src/core/sim/active_piece.gd | new | Needs ShapeDef + Orientations. In editor: `var p := ActivePiece.new(bank.get_shape(&"i"), Vector3i(3,5,1)); print(p.cells())`; `apply_rotation(Orientations.Axis.Z, 1)` then `is_undo_of_last(Z, -1)` is true. |
| CH-083/assets/data/content/blocks.json | assets/data/content/blocks.json | replace | Adds mushroom(3,m) sprout(4,s) egg(5,e) chick(6,c), all solid cell + fills_layer, hue 0, mesh "" (CH-112 fills meshes). `ContentTypes.from_entries(json["types"]).errors` must be empty. |
| CH-052/src/core/rules/rule_api.gd | src/core/rules/rule_api.gd | replace (stub) | Read-only facade: `RuleApi.new(board, knob_registry, params)`; call `is_free`, `layer_count`, `knob_int`, `param`. Uses BoardState API as in MB-011 staging (same signatures). |

Notes: knob id for up-kick budget (max_up_kicks_per_piece) is passed in by Movement; it belongs to CH-084 knobs (not staged). RuleApi writes/rng/can() are CH-091.
