# MB-013 — batch-1 integration (2026-10-10, live editor 4.7.2)

Moved from `src/_staging/` to final paths:
- MB-008: `src/core/model/goal_state.gd`, `validation_issue.gd` (new); deleted `src/core/sim/sim_command.gd`, `sim_event.gd` (+ `.uid`); field doc comments copied into `src/core/model/sim_command.gd` / `sim_event.gd`.
- MB-009: `src/core/shapes/shape_def.gd` (replace), `tools/asset-pipeline/extract_shape_bank.gd` (new).
- MB-010: `src/core/sim/active_piece.gd` (new), `src/core/rules/rule_api.gd` (replace), `assets/data/content/blocks.json` (replace), `assets/data/knobs/{controls,goals,rules,view}.json` (replace; pre-copy backup in session scratchpad).
- MB-011: `src/core/board/board_state.gd` (replace).
- MB-012: `src/core/sim/spawner.gd` (new).

Checks:
- Filesystem scan + script check: all moved files and their dependents (board_sim, replay, shape_bank, board_spec, game_catalog, board_preview) parse clean. The toolkit `script_check` flags the `@abstract` rule bases as errors; that is a checker artefact (it compiles a stripped copy), the editor itself logs no error for them.
- Shape bank: extractor run in-game, `shape_bank.tres` written: 67 shapes, `t`=12, `i`=3, `o`=3, `big_cube`=1, `i.source_pivot`=(1,0,0). Sum of distinct_count = 863.
- Smoke run `src/dev/board_preview.tscn`: boots, board renders (`board_preview_runtime.png`), log clean after fix below.

Fix made: `src/dev/board_preview.gd` dev-only glyph `s` (dev_stone) clashed with CH-083's `sprout` glyph `s` ("content[7].glyph: duplicate s"); dev_stone now uses `k`.
