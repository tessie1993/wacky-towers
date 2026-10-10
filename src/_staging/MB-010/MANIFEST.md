# MB-010 manifest (CH-084 skipped by request)

| Staged | Final path | Action | See it work |
|---|---|---|---|
| CH-048/src/core/sim/active_piece.gd | src/core/sim/active_piece.gd | new | Needs ShapeDef + Orientations. In editor: `var p := ActivePiece.new(bank.get_shape(&"i"), Vector3i(3,5,1)); print(p.cells())`; `apply_rotation(Orientations.Axis.Z, 1)` then `is_undo_of_last(Z, -1)` is true. |
| CH-083/assets/data/content/blocks.json | assets/data/content/blocks.json | replace | Adds mushroom(3,m) sprout(4,s) egg(5,e) chick(6,c), all solid cell + fills_layer, hue 0, mesh "" (CH-112 fills meshes). `ContentTypes.from_entries(json["types"]).errors` must be empty. |
| CH-052/src/core/rules/rule_api.gd | src/core/rules/rule_api.gd | replace (stub) | Read-only facade: `RuleApi.new(board, knob_registry, params)`; call `is_free`, `layer_count`, `knob_int`, `param`. Uses BoardState API as in MB-011 staging (same signatures). |

Notes: knob id for up-kick budget (max_up_kicks_per_piece) is passed in by Movement; it belongs to CH-084 knobs (not staged). RuleApi writes/rng/can() are CH-091.

## Review (godot-specialist, 2026-10-10)
- CH-052 rule_api.gd: `_init` board/knobs now default to null. The live test tests/unit/rules/rule_value_types_test.gd:36 calls `RuleApi.new()` with no args and would have failed. `piece_cells()` no longer uses `[] as Array[Vector3i]`; it returns a typed local instead.
- CH-048 active_piece.gd: no fixes. Pure; enum/int mixing is valid.
- CH-083 blocks.json: matches meadow-candidate-atoms §2 (sprout/egg/chick are solid cell + fills_layer) and meadow.md 04 (mushroom fills a cell and clears with its layer). No change.
- CH-084 (folder present despite "skipped" above): the diffs only add ids (the rest is re-sorting); the JSON is valid; all keys are in KnobDefs.ENTRY_KEYS. `item_slots` has no domain prefix (no loader rule needs one); rename it to `item.slots` if the items GDD prefers.
