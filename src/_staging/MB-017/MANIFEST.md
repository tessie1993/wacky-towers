# MB-017 / CH-049 LevelLoader + LoadResult
| Final path | Action |
|---|---|
| src/data/load_result.gd | new |
| src/data/level_loader.gd | new |

Depends on staged CH-084 knobs (spawn.bag_max_size, control.rotation_axes_enabled), CH-037 JsonNum, GameCatalog.
See it work (editor script): `LevelLoader.load_level("res://src/levels/meadow/meadow_01/meadow_01.json", catalog)`; print ok(), level.id, level.boards[0].size, level.pieces (expect true, meadow_01, (4,12,4) = W, h_play+clearance, D, weights all 1). parse_level with `knobs: {nope: 1}` -> ok()==false, one `unknown_knob` issue.

## Review
- Code reviewed against live GameCatalog, KnobDefs.coerce, JsonNum, JsonReader, BoardSpec.parse, BoardLimits, ShapeBank/ShapeDef, LevelData, ValidationIssue and meadow_01.json: no parse, typing or API errors found; no code change.
- MANIFEST expectation fixed: BoardSpec.size is (W, h_play+clearance, D) = (4,12,4) for meadow_01 (not (4,4,12)); `boards[0].size` is a property, not a call.
- Dependencies all LIVE: knobs spawn.bag_max_size and control.rotation_axes_enabled are in assets/data/knobs, JsonNum/GameCatalog/KnobDefs are in src/core. No staging MB must land first.
- Note: level.pieces lacks fixed_list/tags (LevelData doc lists them); none in meadow_01, out of CH-049 scope.
