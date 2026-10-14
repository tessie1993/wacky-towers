# Anara Godot Analyst Audit - Wacky Towers (Godot 4.7.2) - 2026-10-14

Branch ccr-86d4b3f2-dl6mzv. Requested by: "/godot-analyst look at what we have so far".

**Method note.** The SKILL's Python scripts (score_modernity.py etc.) do not exist. Measurements below were reproduced with grep and Python over `src/**/*.gd` (278 live scripts, 40,210 lines including `_staging`; 365 scripts with `_staging`), shaders, and `.import` files. Counts exclude `src/_staging` unless noted. Category scores are 0-100 judgments mapped from the SKILL's point rubric, not script output. Four rubric items are ambiguous for this project and are listed in "Questions for Godot master"; the scores that depend on them are marked provisional.

## Scores

| Category | Weight | Score | Weighted |
|---|---|---|---|
| Modernity | 20% | 62 | 12.4 |
| Scalability and decoupling (provisional) | 30% | 64 | 19.2 |
| Structural cohesion (provisional) | 20% | 52 | 10.4 |
| Rendering and execution | 30% | 72 | 21.6 |
| **Total** | | **63.6%** | |

**Tier: VISIONARY: STANDARD (50-69%).** Next tier ADVANCED needs 70%. Sensitivity: if the open questions resolve in the project's favour (UI file and vendored assets), the total could reach about 70.

## 1. Modernity (62)

- Typed funcs: 1,875 of 1,881 `func` lines in live code have `->` (src-wide grep). Typed var/const declarations 6,721 vs 12 untyped. Excellent.
- Callable connects: 97 `.connect(callable)` vs 1 legacy string connect at `src/app/main.gd:492` (`_stage.connect("secret_tapped", ...)`). Zero `emit_signal(` strings. `.bind(` 27 uses. Full marks.
- StringName: `&"..."` used heavily (hot keys e.g. `&"view.occlusion_mode"`, `&"anims"`). Full marks.
- Typed collections is the weak spot: 522 typed `var Array[...]/Dictionary[...]` lines vs 1,275 plain `Array`/`Dictionary` vars. Typed Dictionary: 11 uses vs 687 `var x: Dictionary` and ~1,358 plain Dictionary mentions including signatures. Typed Array: 840 `Array[` vs 831 `var x: Array`. Roughly 29% of collection vars are typed. Dictionary-as-snapshot is pervasive (`_hud_snapshot()` at `src/app/main.gd:677`, minigame `state`/`view`/`board` dicts, e.g. `src/physics/wt_crane_tower.gd:166`).
- 4.7-only APIs: none used (0 hits for AreaLight3D, ImageUnit, VirtualJoystick, HDR). No removed 4.7 APIs (`width_in_percent`, `tap_back_pos`) either. Not a defect for a puzzle game, but no points.

## 2. Scalability and decoupling (64, provisional)

- `get_parent()`: 7 hits. `src/ui/game_ui.gd:1859` (`get_parent().get_parent().tooltip_text`), `src/ui/minigame_ui.gd:270` and `:323`, `src/view/wt_stage.gd:782-783` and `:971`, `src/view/wt_island_builder.gd:867` (ancestor walk, legitimate). `"../"` paths: 0. `$`/`get_node` usage low (13), `@onready` only 3, so references are held by code construction rather than scene paths.
- Signals: 31 signal declarations in live code for 97 callable connects and 246 .tscn files (mostly addons/vendor). `game_ui.gd:6` exposes a single `signal intent(id: StringName, args: Dictionary)`: a clean upward channel (signals up). Main drives the UI downward through snapshots (`show_hud`, `update_hud` at `src/app/main.gd:209,501,668`): good observer-plus-snapshot discipline.
- DI vs singletons: the project registers zero autoloads of its own (`project.godot [autoload]` lists only PhantomCamera, GUIDE, Beehave and the MCP helper). Logic is RefCounted-based (`BoardSim`, `WtIslandBuilder.new(_biome)`, `WtPropScatter.new(_biome, builder)`). 18 `static var` lines remain. `src/net/lan_session.gd:2` assumes the `/root/Main/Lan` path.
- God objects (no autoload god-objects, but scene-level ones):
  - `src/ui/game_ui.gd`: 2,619 lines, 98 funcs, `show_tournament` cc=52 (179 lines, `:2260`). One class builds the title, modes, lobby, settings, profiles, map, shop, tools, HUD, pause, results, confirm and items screens.
  - `src/app/main.gd`: 1,170 lines, 75 funcs; `_execute_intent` cc=43 at `:164` (149 lines). Orchestrates sim, stage, UI, rivals, bots, LAN, tournament, minigames, pause.
  - `src/view/wt_stage.gd` 1,309 and `src/view/wt_island_builder.gd` 1,209 lines.
- Logic touching UI: `main.gd` sets no `.text/.visible` directly (0 hits). 14 non-UI files set `.visible/.text`, but they are view/stage/gallery nodes (Node3D visibility), not Control logic. The 59 `.text/.visible` writes in `game_ui.gd` are expected for a UI file; see Q1.

## 3. Structural cohesion (52, provisional)

- Layout: code root is layer-by-type at top (`src/core`, `src/view`, `src/ui`, `src/game`, `src/data`) with feature folders inside `src/mechanics` (114 scripts) and `src/levels`. Layered core/view/ui separation is intentional (ADRs), so partial credit for feature cohesion.
- Monolithic folders: `src/view` 35 scripts flat; `src/mechanics` 114 (feature-grouped, acceptable); `src/ui` root holds `game_ui.gd`, `minigame_ui.gd`, `minigame_ext_c.gd`, `minigame_ext_d.gd` beside subfolders.
- snake_case violations in `res://` (excluding addons/tools/docs/guide_examples):
  - `src/_staging/MB-0xx/`, `MB-010/CH-0xx/` uppercase directory names: 19 staged packs, about 140 files, 73 are `.gd`. Highest risk for Linux/Android export casing issues.
  - `assets/fonts/fredoka/*` (7 files, mixed case / hyphen names).
  - `assets/source/blender/characters/__pycache__/*.pyc` (2 junk files; should not be in the repo).
  - `assets/third_party/kenney_nature_kit/` 3,619 files with camelCase/hyphen names (e.g. `Side/cliff_blockSlopeHalfWalls_rock.png`, `kenney_nature-kit.zip`, `Instructions.url`); vendored, but these ship in the project tree, see Q2.
  - `script_templates/BeehaveNode/default.gd` (addon-derived).
- Staging: `src/_staging` (73 scripts, e.g. a second `MB-031/src/core/sim/board_sim.gd` of 711 lines) duplicates live code and `src/ui/_staging`; stale copies inflate every count.

## 4. Rendering and execution (72)

- MultiMesh: used in 12 live files (`board_view.gd`, `wt_prop_scatter.gd`, `wt_block_toppers.gd`, `wt_island_builder.gd`, `wt_shape_gallery.gd`, `wt_sparkle_fx.gd`, `slot_map.gd`, `wt_block_materials.gd`, `wt_level_look.gd`, `wt_stage.gd`, `wt_physics_challenge.gd:226,261` ghost and landing markers, `dev/board_preview.gd:191`). Locked blocks are one MultiMeshInstance3D with per-instance colour (ADR-0007). Strong.
- Instance shader params: 0 `set_instance_shader_parameter` calls and 0 `instance uniform` in the 12 project shaders (`src/view/shaders/*.gdshader`); per-instance variation is carried by MultiMesh colour/custom data and palette arrays instead. Neutral: no +10, no penalty.
- Runtime `material.duplicate()`: exactly 1, `src/view/wt_stage.gd:1240` (`falling = material.duplicate() as ShaderMaterial`), a fallback branch whose comment at `:1238` says a fresh material is preferred because duplicate drops palette arrays. Other `duplicate` hits are Array/Dictionary copies, not materials. 38 `StandardMaterial3D/ShaderMaterial.new()` sites, mostly builder-time (`wt_block_materials.gd`, `wt_island_builder.gd`); not hot-path.
- `_process`/`_physics_process`: 9 total; all small. `wt_stage.gd:381` `_process` (cc=14, 21 lines) also calls `_update_marks()`, `_update_fx()` and iterates `_ferris.get_children()` per frame with a `has_meta` check (cache the cabins). `main.gd:89` `_physics_process` (cc=18) runs sim tick plus `_refresh_hud()` and rebuilds a `_hud_snapshot()` dictionary every tick (`:111`, `:942`): avoidable allocation churn at 60 Hz. `audio_director.gd:71` `_process` polls a pending list every frame (could be timer-driven). `wt_level_look.gd:151` correctly toggles `set_process` via `_update_process()`; `wt_title_island.gd` also guards with `set_process`.
- await: 62 hits, none inside production loops; loop-adjacent awaits are all in test/preview scripts (`src/ui/tests/*`, `src/dev/board_preview.gd:103`, `block_set_preview.gd:34`). Only runtime await: `game_ui.gd:2069` (3.5 s timer).
- Group queries: 1 (`get_nodes_in_group`/`call_group` hit, not in a loop or `_process`). None found in loops.
- Draw-call risk: `wt_island_builder.gd` and `wt_stage.gd` build islands, props, far-field, and set pieces from many separate MeshInstance3D nodes (about 38 material construction sites); props and blocks are MultiMeshed, but terrain/set-piece pieces are not. Draw calls were not measured at runtime (no headless renderer in this audit). `PhysicsRayQueryParameters3D` ray only on input, fine.
- Orphan patterns: 108 `.new()` for Node-like types vs 39 `queue_free/free` and only 2 `tree_exited/_exit_tree` hooks. Several `remove_child` without free: `src/ui/game_ui.gd:498,1231,2045,2055,2514`, `src/ui/minigame_ui.gd:60,295`, `src/levels/_kit/platform/meadow_platform.gd:38`. Each needs checking that the removed node is re-added or freed; `wt_stage.gd:971` detaches `_character_root` deliberately. No runtime orphan monitor was run.
- Textures: 531 texture `.import` files, all `compress/mode=0` (Lossless); 0 VRAM-compressed. `detect_3d/compress_to=1` is set on 53, so any texture later used in 3D is auto-switched to VRAM. The 3D character textures `assets/models/characters/*` (5) are lossless; the UI sprites `assets/art/ui/*` are correctly lossless. 92 wav files use mode=2 (QOA). The Kenney 3D kit textures are the main VRAM waste if loaded.
- Dependencies (headless `ResourceLoader.get_dependencies`): main.tscn 1, minigame_ui.tscn 1, camera_rig.tscn 3, wt_physics_challenge.tscn 1, wt_stage_demo.tscn 1, atom_lab.tscn 1. No scene near 30+. Scripts return 0 (GDScript preloads are not reported as deps by this call). Circular preloads were not detected by this probe; use a text scan of 29 live `preload(` calls if needed.

## Top 10 largest scripts

1. `src/ui/game_ui.gd` 2,619
2. `src/core/sim/board_sim.gd` 1,612
3. `src/view/wt_stage.gd` 1,309
4. `src/view/wt_island_builder.gd` 1,209
5. `src/app/main.gd` 1,170
6. `src/game/minigames/rules_c.gd` 758
7. `src/core/board/board_state.gd` 753
8. `src/_staging/MB-031/src/core/sim/board_sim.gd` 711 (stale duplicate)
9. `src/physics/wt_physics_challenge.gd` 624
10. `src/game/minigames/rules_d.gd` 597

## Cyclomatic hotspots (regex estimate)

`src/ui/minigame_ui.gd:309 _update_targets` 72 (278 lines); `game_ui.gd:2260 show_tournament` 52; `wt_tournament_randomizer.gd:57 validate_template` 49; `main.gd:164 _execute_intent` 43; `wt_modes.gd:195 record_round` 41. Process-loop functions peak at 18 (`main.gd:89`). 21 of 1,858 functions exceed 80 lines.

## Top 10 fixes ranked by impact

1. Split `game_ui.gd` (2,619 lines) into per-screen scenes/classes behind the existing `intent` signal and a `UiScreen` base (staged `src/_staging/MB-027` already has `ui_screen.gd`); carve `show_tournament` and `_update_targets` first.
2. Delete or relocate `src/_staging` (and `src/ui/_staging`): rename/ship or remove; it carries uppercase `MB-xxx` directories and stale duplicate sims. Fixes casing violations and halves the dup count.
3. Convert snapshot dictionaries (`_hud_snapshot`, minigame `state/view/board`) to typed `Resource`/`RefCounted` classes or typed dictionaries; target 80% typed collections.
4. Break up `main.gd` (`_execute_intent` cc=43): route intents through a command-handler table and move mode orchestration (tournament, LAN, minigame) into mode controllers.
5. Move vendored kit (`assets/third_party/kenney_nature_kit`: 3,619 files, includes a `.zip` and `.url`) out of the project or into an excluded folder; remove `__pycache__`; rename `assets/fonts/fredoka` to snake_case.
6. Stop rebuilding the HUD snapshot every physics tick (`main.gd:111,942`); emit changes via signal only on diff.
7. Import any 3D-used texture (character textures in `assets/models/characters`) with VRAM compression plus mipmaps; keep UI sprites lossless.
8. Cache ferris cabin children and drop per-frame `get_children()` in `wt_stage.gd:381`; make `audio_director.gd:71` timer-driven.
9. Replace the six `get_parent()` hops (`game_ui.gd:1859`, `minigame_ui.gd:270,323`) with direct references stored at build time, and replace string connect `main.gd:492` with `_stage.secret_tapped.connect(...)`.
10. Audit the `remove_child` without `queue_free` sites listed under orphan patterns and add `tree_exited` cleanup; run a Performance orphan-node monitor on a smoke run.

## Blueprint to reach VISIONARY: ADVANCED (70%)

1. Purge and normalize (cohesion 52 to about 75): clear `_staging`, rename fonts, relocate vendored assets. Gains about +4.6 total points.
2. Decompose the god-objects (scalability 64 to about 74): split `game_ui.gd` and `main.gd` along the intent signal. Gains about +3 points.
3. Type the data (modernity 62 to about 80): typed Resources/dictionaries for snapshots and rule state, plus VRAM-compress 3D textures (rendering 72 to about 76). Gains about +4.7 points.

Together these projected gains put the project near 76%.

## Questions for Godot master

1. Is `game_ui.gd` (a large data-driven UI file) judged against the "logic modifying UI nodes" penalty? Options: (a) exempt UI-layer files and score only non-UI code (recommended); (b) penalize its 59 direct `.text/.visible` writes; (c) penalize only size, not UI writes. Scored here as (a) with a size penalty, provisional.
2. Should third-party/vendored folders (`assets/third_party/kenney_nature_kit`, `tools/vendor`, `addons`, `guide_examples`) count toward snake_case compliance? Options: (a) exclude (recommended, the files are not authored here); (b) include; (c) include only the ones shipped in an export preset. Scored here as (a) for count but flagged as a fix.
3. Is a puzzle game required to adopt `instance_shader_parameter`, given per-instance variation rides on MultiMesh colour and palette arrays? Options: (a) neutral, no points or penalty (recommended); (b) penalize absence. Scored as (a).
4. Are dictionary snapshots for minigame rules deliberate for network lockstep/JSON? Options: (a) accept untyped Dictionary at serialization boundaries only (recommended); (b) require typed Resources everywhere. If (a), modernity rises to about 70.

## Files most needing Godot-master review

`src/ui/game_ui.gd`, `src/app/main.gd`, `src/view/wt_stage.gd` (`:381` process, `:1240` material duplicate), `src/view/wt_island_builder.gd`, `src/ui/minigame_ui.gd:309`, `src/_staging` tree, `src/net/lan_session.gd`, `assets/models/characters` imports.
