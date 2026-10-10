# MB-017 / CH-049 LevelLoader + LoadResult
| Final path | Action |
|---|---|
| src/data/load_result.gd | new |
| src/data/level_loader.gd | new |

Depends on staged CH-084 knobs (spawn.bag_max_size, control.rotation_axes_enabled), CH-037 JsonNum, GameCatalog.
See it work (editor script): `LevelLoader.load_level("res://src/levels/meadow/meadow_01/meadow_01.json", catalog)`; print ok(), level.id, level.boards[0].size, level.pieces (expect true, meadow_01, (4,4,12), weights all 1). parse_level with `knobs: {nope: 1}` -> ok()==false, one `unknown_knob` issue.
