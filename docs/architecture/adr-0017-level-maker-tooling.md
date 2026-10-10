# ADR-0017: Level-Maker Tooling (EditorPlugin)

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user: level maker is a dev-team EditorPlugin dock; mechanics are atoms picked from the library in a form; official levels may attach beehave trees for staging only; reads/writes the existing level JSON; live `LevelValidator`; test-play button; no built-in AI button; sharing by file or share code later; scene dressing stays in the per-level `.tscn`, decision sheet 2026-10-10), tools-programmer (author)

## Summary

Levels are hand-written JSON today (ADR-0005), and the Level Data GDD asks for an editor view with live validation and effective values. This ADR adds one `EditorPlugin` dock under `addons/wt_level_tools/`, excluded from every export. It opens and saves the **existing** level JSON with no new format. Its parts are an atom-picker form built from the mechanics library, knob widgets generated from the ADR-0004 schemas, a layer-by-layer ASCII grid editor, live `LevelValidator` issues shown next to each field, a test-play button with quick restart, atomic saves with `EditorUndoRedoManager` undo, and a warning before a Locked level's hash changes. For official levels the dock can also point at a beehave staging tree in the level's `.tscn`. The editing core is pure GDScript with no editor API, so a later in-game player editor can share it. That editor is not built now.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Editor tooling (EditorPlugin, dock UI, undo/redo, file I/O) |
| **Layer** | Tools (never shipped) |
| **Knowledge Risk** | MEDIUM-HIGH: `EditorPlugin`, `EditorUndoRedoManager`, `EditorInterface.play_custom_scene` are stable 4.x. 4.6 added an `EditorDock` class (`breaking-changes.md`, "Plugins"), which is post-cutoff and may replace or deprecate `add_control_to_dock`. The engine reference does not cover it beyond one line |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.6 `EditorDock`), `deprecated-apis.md`, `current-best-practices.md` (Editor workflow 4.6); ADR-0005 (loader, validator, `level_hash`, editor panel location); `architecture-modular-layout.md` §5 (mechanics database), §8 (paths); `src/data/json_reader.gd`; `src/levels/meadow/meadow_01/` (existing JSON + `_staging/meadow_01_events.tscn`) |
| **Post-Cutoff APIs Used** | 4.6 `EditorDock` (preferred if it is the supported dock API on 4.7.2); typed `Dictionary[K, V]` (4.4) in the field model |
| **Verification Required** | (1) On 4.7.2: is `EditorDock` + `EditorPlugin.add_dock()` (or equivalent) the supported dock API, and is `add_control_to_dock` deprecated? Use whichever the 4.7.2 class reference names. Do not guess. (2) `DirAccess.rename_absolute(tmp, target)` replaces an existing file on Windows and on macOS/Linux. If not, use remove-then-rename with a `.bak` copy. (3) `EditorUndoRedoManager.create_action(..., custom_context)` puts actions on a `RefCounted` document into the global history rather than a scene history, and Ctrl+Z works while the dock has focus. (4) `EditorInterface.play_custom_scene()` plus `EditorInterface.stop_playing_scene()` restarts in under 2 s on the dev PC. (5) An export preset with `addons/wt_level_tools/*` in the exclude filter leaves no file of the addon in the `.pck` (Android and PC presets). **None of these is verified yet.** |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0005 (Accepted): level JSON, `DataLoader`, `LevelValidator`, `ValidationIssue`, `level_hash`, editor panel location. ADR-0004 (Accepted): rule/knob/atom schemas (`params` `type/min/max/default`, knob ranges, `atom_tags.json`), `PluginRegistry`. ADR-0002: ASCII layer grids (`BoardSpec.parse`). ADR-0010: `PlaySession.start/restart` for test play. ADR-0011 (Proposed, adr-0011-mechanic-level-event-runtime.md): beehave staging trees, staging only |
| **Enables** | Authoring meadow_02–meadow_10 and later biomes without hand-editing JSON; a future in-game player level editor (shared core); later file/share-code sharing |
| **Blocks** | Nothing on the MVP critical path. Hand-written JSON keeps working, and the tool is a speed-up |
| **Ordering Note** | Build after `DataLoader` + `LevelValidator` exist (ADR-0005) and after the knob registry and rule JSON schemas are on disk (ADR-0004), because the forms are generated from them. The staging-tree picker waits for ADR-0011 to be Accepted |

## Context

### Problem Statement

The Meadow MVP needs ten official levels plus a bonus level, and the campaign plans 100. Every level is a JSON file with ASCII grids, a `recipe` of mechanic atoms, rule `params`, a flat `knobs` map and star times. Hand-editing that is slow and error-prone. Typos are caught only when the validator runs, and nobody can see the effective (default + override) values. The Level Data GDD (rule 5, edge case "if a field is omitted", UI note) asks for an authoring check and an editor view that lists effective values and validation results per field. Its open question "simple in-engine editor or text first?" is now answered by the user: an in-engine EditorPlugin dock for the dev team.

### Constraints

- **No new format.** The tool reads and writes exactly the level JSON in ADR-0005. Fields the tool does not understand (for example a newer `schema`) are kept as they are, never dropped.
- **No validator logic in the plugin** (ADR-0005 "Where validation runs" item 4). The dock calls `LevelValidator` and only displays what it returns.
- **No behaviour in levels** (Level Data rule 4). The dock can pick only atoms, rule ids, knob ids and shape ids that already exist in the catalogues.
- **Beehave is staging only** (decision sheet). Anything that changes the board is a `RuleRuntime` rule inside `BoardSim`. A staging tree may animate, show banners and play cheers, nothing else.
- **Scene dressing stays in the per-level `.tscn`**. The dock does not edit dioramas.
- **No built-in AI button.**
- **Tools are never shipped.** The addon is excluded from all export presets (Android and PC/Steam).
- GDScript only (ADR-0008). Every gameplay value comes from data (`assets/data/knobs/*.json`, `assets/data/mechanics/<id>.json`).
- Tool principles: clear, actionable errors; undoable; never corrupt a file on failure; fast enough not to break flow.

### Requirements

- Open, create, duplicate and save official level files (`res://src/levels/<biome>/<id>/<id>.json`) and dev copies of player levels.
- Pick atoms by slot from the mechanics library, then edit each atom's or rule's params with widgets generated from its schema.
- Edit knob overrides with widgets generated from the knob registry. Show the effective value (default or override) next to each knob.
- Edit board mask, starting contents and target shape one layer at a time.
- Show validator errors and warnings live, attached to the field they name.
- Launch the level from the editor, and restart it fast.
- Make it safe to edit: undo/redo, atomic saves, and a warning before a shipped (Locked) level's identity changes.

## Decision

### 1. Where the code lives

| Part | Path | Ships? | Uses editor API? |
|---|---|---|---|
| Plugin entry, dock UI, widgets | `addons/wt_level_tools/` (`plugin.cfg`, `wt_level_tools_plugin.gd`, `dock/`, `widgets/`) | **No.** Excluded from every export preset | Yes |
| Editing core (document model, field schema, grid ops, catalogue view) | `src/data/authoring/` | Yes, but unused by the game until the player editor exists (small, pure RefCounted) | **Never**: no `EditorInterface`, `EditorPlugin`, `EditorUndoRedoManager`, `Engine.is_editor_hint()` |
| Test-play launcher scene | `src/dev/level_test_play.tscn` + `.gd` | No (`src/dev/` is already export-excluded) | No |

- The addon is enabled in `project.godot` like the other dev addons. Export presets add `addons/wt_level_tools/*` to the exclude filter, next to the other dev/AI addons stripped from release exports (decision sheet defaults).
- The split keeps the in-game player editor seam open (section 8). The dock is a thin editor shell around `src/data/authoring/`, and a grep test fails if `src/data/authoring/` mentions any `Editor*` class.

### 2. File I/O (existing format, atomic save)

- **Open** goes through `DataLoader.load_level()` (ADR-0005), so the tool parses the file exactly as the game does, migrations included. The raw parsed `Dictionary` is kept next to the typed `LevelData` so unknown or future keys round-trip unchanged.
- **Save** writes canonical JSON: sorted keys, tab indent, one ASCII grid row per line, trailing newline. Diffs stay small and `level_hash` is stable (ADR-0005 hashes the canonical form, not the indentation).
- **Atomic write**: write `<id>.json.tmp` next to the target, re-read and re-parse it, then `DirAccess.rename_absolute(tmp, target)`. Any failure leaves the original untouched and shows the error in the dock (path + reason). Before the first overwrite in a session, the previous file is copied to `<id>.json.bak` (gitignored). Verification item 2 confirms rename-over-existing per OS.
- After a save, `EditorInterface.get_resource_filesystem().update_file(path)` refreshes the FileSystem dock.
- **Saving a Draft with errors is allowed.** The Draft state exists for that (Level Data states). The save button shows the error count, and the file stays Draft until it validates.
- Files never reach `ResourceLoader.load()`. The ADR-0005 grep test also covers `addons/wt_level_tools/`.

### 3. The form: atoms, rules and knobs from data

- **Catalogue source**: `assets/data/mechanics/<id>.json` (the mechanics database, modular layout §5), `assets/data/atom_tags.json` and `assets/data/knobs/*.json`, read with `JsonReader.read_dir` and wrapped in a `ValidationContext` built the same way as the game's (ADR-0005), with the shape bank and `PluginRegistry` injected.
- **Atom picker**: one row per slot (Board/Layout, Arrival, Control Verb, Placement, Clear, Collapse, Goal, Fail, Scoring, Interaction, Events, Special pieces, as in `mechanics-module.md`). Each row is a dropdown of that slot's atoms. Only atoms whose status allows use are listed, and Parked atoms are hidden. Each entry shows the atom code, name, icon and `requires`/`provides` tags. Atoms whose `requires` the current board, layout and slots do not provide are greyed out with the missing tag as a tooltip. The validator still makes the final call. The picker writes the `recipe` list (ADR-0005), so the loader's expansion stays the single source of truth for what a recipe means.
- **Rules list**: add/remove/reorder entries in `rules` from the same catalogue. An F3 budget badge (twists `n/2`, mechanic `n/1`) is read from the validator's result, not counted again by the dock.
- **Generated param and knob widgets**: one widget per schema entry, chosen by `type`.

| Schema `type` | Widget | Limits |
|---|---|---|
| `int` | `SpinBox`, step 1 | `min`/`max` from the schema |
| `float` | `SpinBox` with a step from the schema (default 0.01) | `min`/`max` |
| `bool` | `CheckBox` | — |
| enum (`choices`) | `OptionButton` | listed values only |
| `shape_id` / `rule_id` / content id | `OptionButton` filled from the catalogue | ids that exist |
| ms durations (`*_ms`) | `SpinBox` with a seconds read-out | `min`/`max` |

- Every knob row shows the **effective value**: the registry default in grey, or the override in bold with a reset button that removes the key from `knobs`. This answers the GDD edge case "the validator lists the effective values in the editor".
- The schema decides everything. A new knob or param appears in the form when its JSON exists, with no change to the dock. An unknown `type` falls back to a raw JSON text field and a warning.
- Named sections (`board`, `pieces`, `goal`, `stars`, `seed`, `story`) get hand-built panels, because their shape is fixed by ADR-0005 rather than by a schema. Text fields in `story` take translation keys, with a read-out of the English string if the key exists.

### 4. Live validation per field

- Each edit updates the `LevelDocument`, rebuilds `LevelData` in memory and runs `LevelValidator.validate(level, ctx)`, debounced to 150 ms after the last edit. Meadow-sized levels validate in under 50 ms (ADR-0005 budget), so the debounce exists for typing, not for speed.
- Each `ValidationIssue.field` (dotted path, for example `board.mask`, `knobs.fall.g0`, `rules[1].params.every_ms`) is mapped to the widget that owns it. Errors get a red outline and an icon, warnings get amber. The tooltip shows `rule` and `message`.
- An **Issues** list at the bottom of the dock shows every issue. Clicking one focuses its widget. Issues whose field no widget owns are listed with their path.
- A status chip shows Draft / Valid / Locked (section 7).

### 5. Shape grid editor (layer by layer)

- One grid control edits `board.mask`, `board.starting_contents` and `goal.target_shape`, picked by a tab. The layer `y` is chosen with a slider and Page Up/Page Down. Ghost cells show the layer below.
- Cells are painted with the GDD tokens only: mask `#`/`.`, starting contents `#` (starter), `m` (biome object), `.`; target `#`/`.`. Left-drag paints, right-drag erases. Fill, clear-layer, copy layer up/down and mirror X/Z are core ops in `src/data/authoring/grid_ops.gd`.
- Width, depth and `h_play` come from the board panel. Changing the size asks before cropping cells.
- A small 3D preview reuses `src/dev/board_preview.tscn` (exists) in a `SubViewport`, read-only, and refreshes after each edit. It is optional, and the grid works without it.
- The grid writes the same per-layer ASCII rows ADR-0005 and ADR-0002 §6 define. `BoardSpec.parse` is what checks them.

### 6. Test play with quick restart

- **Play** button: if the document is dirty, save it first (atomic). Then the dock writes a small request file `user://dev/test_play.json` (`{level_json, scene, seed, start_phase}`) and calls `EditorInterface.play_custom_scene("res://src/dev/level_test_play.tscn")`.
- `level_test_play.gd` (dev only) reads the request. For an official level it instances the level's own `.tscn`. Otherwise it uses `generic_level.tscn`. Then it calls `PlaySession.start()` (ADR-0010) with the loaded `LevelData`. The seed is pinned from the dock (default: the level's `seed`, or a fixed dev seed), so retries are reproducible (ADR-0006).
- **Quick restart** in the running game: `F5` or `R` in the test-play scene calls `PlaySession.restart()` (new sim, same stage and seed, Intro skit skipped; ADR-0010) with no scene reload. **Restart** in the dock re-runs the scene (stop + play) after the next save, so JSON edits are picked up.
- An on-screen dev strip in the test-play scene shows level id, `level_hash` (first 8 chars), seed and live validator warnings. It is dev scene UI, not game UI.
- **No built-in AI button** (user decision).

### 7. Locked-level hash warning

- Level Data states: Draft → Valid → Locked; a shipped edit needs a `version` bump so saved stars stay meaningful (TR-level-data-definition-006), and `level_hash` is the identity (ADR-0005).
- The dock reads the locked set from a lock manifest. **Proposed location `src/levels/locked_levels.json`** (`{level_id: {version, level_hash}}`), written by the release step that locks a biome. This is a release manifest, not a change to the level format. Final location to be confirmed with devops-engineer.
- When the open level is in the manifest, the status chip shows **Locked**. Any edit shows a banner: "meadow_06 is Locked (shipped). Saving changes its hash; saved stars and replays for it stop matching." Save then requires one explicit choice: **Bump version and save** (sets `version` + 1, updates nothing else) or **Cancel**. There is no silent overwrite.
- A file that differs from its recorded hash on open (edited outside the tool) gets the same banner on open.

### 8. Undo/redo

- Every edit is a command on the `LevelDocument` (`set_field(path, value)`, `paint_cells(layer, cells, token)`, `add_rule`, `remove_rule`, `move_rule`, `set_recipe_slot`). The core owns the do/undo pair (`LevelEdit` objects with `apply()` and `revert()`), so it is testable with no editor and reusable by the player editor.
- The dock registers each `LevelEdit` with `EditorUndoRedoManager` (`create_action` → `add_do_method(edit, "apply")` / `add_undo_method(edit, "revert")` → `commit_action(false)` after applying once). Ctrl+Z and Ctrl+Y and the editor's history panel work the usual way. One paint drag is one action (merged on mouse release). Verification item 3 confirms which history the actions land in.
- Undo never touches the file on disk. Only Save writes.

### 9. Beehave staging tree reference (official levels only)

- Official levels may attach a beehave tree **for staging only**: intro banners, mascot cheers, "one more!" beats. The existing pattern is `src/levels/<biome>/<id>/_staging/<id>_events.tscn` (meadow_01).
- The reference lives in the **level's `.tscn`** (presentation, ADR-0005 file table), never in the level JSON. The JSON format does not change, and player levels can never name a scene or a tree.
- The dock's Staging panel shows which staging scene the open official level's `.tscn` instances, opens it in the editor with one click, and creates a new one from a template if missing. The exact property or child-node contract on `LevelStage` is owned by **ADR-0011**. Until ADR-0011 is Accepted, the panel is read-only (show and open, no write).
- The dock never generates beehave leaves that call `RuleApi` or touch the board. A staging-tree lint (in ADR-0011's tests, not here) enforces that.

### 10. Future seams (not built now)

- **In-game player level editor**: shares `src/data/authoring/` (document, edits, grid ops, field schema from catalogues, validation mapping). It needs its own touch UI in `src/ui/`, runs the same `LevelValidator`, and saves to `user://levels/<id>.json` through the same atomic writer. Nothing in the core may assume the editor exists.
- **Sharing**: file export/import of the same JSON (validated at import in all builds, ADR-0005 item 3) and later a **share code** (compressed canonical JSON, base64url, with `level_hash` as checksum). The encode/decode functions belong in `src/data/` when built. No network, server or format change is planned now.
- **Daily box of tricks**: the generator (ADR-0005) can reuse the catalogue view and compatibility greying for a "preview today's mix" dev button later.

### Architecture Diagram

```
Godot editor
 └ WtLevelToolsPlugin (EditorPlugin, addons/wt_level_tools/ — export-excluded)
     └ LevelDock (EditorDock or add_control_to_dock — verification 1)
         ├ FilePanel ── open/new/duplicate ──▶ DataLoader.load_level (ADR-0005)
         ├ AtomPicker / RulesList ◀── CatalogView ◀── assets/data/mechanics/*.json, atom_tags.json
         ├ KnobForm (generated) ◀── knob registry schemas (ADR-0004)
         ├ GridEditor (mask · starting_contents · target_shape, layer y)
         ├ StagingPanel ──▶ <id>.tscn staging scene (ADR-0011, read-only until Accepted)
         ├ IssuesList ◀── LevelValidator.validate (debounced 150 ms)
         └ Play / Restart ──▶ user://dev/test_play.json ──▶ play_custom_scene(level_test_play.tscn)
                                                            └ PlaySession.start / restart (ADR-0010)
         │ every edit
         ▼
 EditorUndoRedoManager ── apply()/revert() ──▶ LevelEdit ──▶ LevelDocument   (src/data/authoring/, pure)
                                                              │ save
                                                              ▼
                                         AtomicJsonWriter: .tmp → re-parse → rename (+ .bak)
                                                              │ Locked? ── banner + version bump
```

### Key Interfaces

```gdscript
# src/data/authoring/ — pure, no editor API (future in-game editor shares these)
class_name LevelDocument extends RefCounted
signal changed(field_path: String)
var raw: Dictionary                      ## parsed JSON, unknown keys preserved
var dirty: bool
static func from_file(path: String, migrations: LevelMigrations) -> LevelDocument
func to_level_data() -> LevelData        ## same conversion as DataLoader
func to_canonical_json() -> String       ## sorted keys, tab indent
func get_field(path: String) -> Variant  ## dotted path, e.g. "knobs.fall.g0", "rules[1].params.every_ms"

class_name LevelEdit extends RefCounted  ## one undoable change
func apply() -> void
func revert() -> void
static func set_field(doc: LevelDocument, path: String, value: Variant) -> LevelEdit
static func paint_cells(doc: LevelDocument, grid: StringName, layer: int, cells: Array[Vector2i], token: String) -> LevelEdit

class_name FieldSchema extends RefCounted  ## built from knob registry + rule/atom JSON
static func for_knob(def: Dictionary) -> FieldSchema
static func for_param(name: StringName, def: Dictionary) -> FieldSchema
var type: StringName                       ## &"int" | &"float" | &"bool" | &"enum" | &"id" | &"ms"
var min_value: Variant
var max_value: Variant
var default_value: Variant
var choices: Array

class_name CatalogView extends RefCounted
func atoms_for_slot(slot: StringName) -> Array[Dictionary]
func missing_tags(atom_id: StringName, doc: LevelDocument) -> PackedStringArray   ## display hint only

class_name AtomicJsonWriter extends RefCounted
static func write(path: String, text: String, keep_backup: bool) -> Error   ## .tmp → re-parse → rename

class_name LockManifest extends RefCounted
static func load(path: String) -> LockManifest
func is_locked(level_id: StringName) -> bool
func recorded_hash(level_id: StringName) -> String

# addons/wt_level_tools/ — editor only
class_name WtLevelToolsPlugin extends EditorPlugin
# _enter_tree: create LevelDock, register dock; _exit_tree: remove and free it

# Interface needed from runtime (ADR-0010 owner: gameplay-programmer) — already specified there:
#   PlaySession.start(stage, level, catalog, round_seed) / PlaySession.restart()
```

### Implementation Guidelines

- The dock must never hold validator, loader or expansion logic. It calls `DataLoader`, `LevelValidator` and the recipe expansion and displays the result.
- `src/data/authoring/` must never reference an `Editor*` class or `Engine.is_editor_hint()` (grep test).
- Writes must go only through `AtomicJsonWriter`. Never open the target file for writing directly.
- Unknown JSON keys must survive a load → save round trip byte-for-byte in value, though not in key order.
- Widgets must be generated from schemas. A hand-written widget for a schema-driven knob or param is a bug.
- The dock must free every control it created in `_exit_tree()` (plugin disable/reload must not leak docks).
- The addon must be in every export preset's exclude filter. The export smoke test lists the `.pck` and fails on any `wt_level_tools` path.
- Staging-tree writes stay disabled until ADR-0011 is Accepted.
- Every addon file gets a `credits.json` entry as first-party (ADR-0005 credits test covers `addons/`).
- Usage docs: `addons/wt_level_tools/README.md` (open, edit, validate, test-play, lock flow, shortcuts), written with the first build.

## Alternatives Considered

### Alternative 1: Keep hand-written JSON + CLI validator
- **Description**: Edit JSON in a text editor; run the validator from a headless script.
- **Pros**: No tool to build; already works.
- **Cons**: No effective-value view, no grid painting, validation only after the fact; 100 levels of ASCII grids by hand.
- **Rejection Reason**: User chose an in-engine dock. The CLI validator still exists through the test suite.

### Alternative 2: Standalone web or desktop editor
- **Pros**: Usable without Godot; could later become the player editor.
- **Cons**: Duplicates the loader, validator and catalogues in another language, so they drift. No test play.
- **Rejection Reason**: Breaks "one loader, one validator" (ADR-0005).

### Alternative 3: Edit levels as `.tres` in the Inspector
- **Pros**: Inspector widgets for free.
- **Cons**: A second level format; `.tres` is unsafe for shared levels (ADR-0005).
- **Rejection Reason**: No new format (user decision).

### Alternative 4: In-game editor first, used by the dev team too
- **Pros**: One editor for everyone.
- **Cons**: Needs touch UI, save flows and polish before the dev team gets any speed-up. No editor undo, no FileSystem integration.
- **Rejection Reason**: Not now. The shared core in `src/data/authoring/` keeps this path open.

### Alternative 5: Whole editor inside the addon (no `src/` core)
- **Pros**: Everything in one folder, nothing extra shipped.
- **Cons**: The addon is export-excluded, so a later player editor would have to move or copy it.
- **Rejection Reason**: The core is small and pure, so it is cheap to ship unused and expensive to extract later.

## Consequences

### Positive
- Levels are authored faster, with live validation at the field that is wrong, and with the effective values the GDD asks for.
- New knobs, params and atoms show up in the form with no tool change, because the form is generated from data.
- Saves cannot corrupt a file, and a shipped level cannot change identity by accident.
- The in-game player editor and sharing have a clear seam.

### Negative
- Another addon to maintain across Godot point releases (the dock API changed in 4.6).
- `src/data/authoring/` ships unused in the MVP (a few KB of scripts).
- A lock manifest file is added, and its owner and location are not settled yet.

### Neutral
- Hand-editing JSON stays valid. The tool and a text editor produce the same canonical file after one save.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| `EditorDock` / dock API differs on 4.7.2 from what is assumed | Medium | Low | Verification item 1 before the first build; dock registration is ~10 lines in one file |
| Rename-over-existing fails on Windows | Medium | High | Verification item 2; fallback remove-then-rename with `.bak` copy |
| Undo actions land in the wrong history (scene vs global) | Medium | Medium | Verification item 3; the `LevelEdit` model is editor-independent, so only the registration call changes |
| Addon leaks into an export | Low | Medium | Exclude filter + export smoke test listing the `.pck` |
| Generated widgets cannot express a schema (e.g. vectors, lists) | Medium | Low | Raw-JSON fallback widget + warning; add a widget type when it appears |
| Round-trip drops unknown keys and silently loses data | Low | High | Keep `raw`; round-trip unit test over every level file |
| Designers edit a staging tree to change gameplay | Low | High | Staging writes disabled until ADR-0011; ADR-0011 lint |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| level-data-definition.md (TR-level-data-definition-001) | One storage format and loader for official and player levels | Tool reads/writes the ADR-0005 JSON through `DataLoader`; no new format; future player editor shares the same core and file |
| level-data-definition.md (TR-level-data-definition-002) | Omitted fields take owning-system defaults | Knob rows show registry default vs override; reset removes the key |
| level-data-definition.md (TR-level-data-definition-003), rule 5 | Validator names level, field and rule; errors block play, warnings listed; runs at authoring | Live `LevelValidator` per field, Issues list; test play blocked on errors |
| level-data-definition.md (TR-level-data-definition-004) | ASCII grids for mask, starting contents and target shape | Layer-by-layer grid editor writing the same tokens |
| level-data-definition.md (TR-level-data-definition-005) | Seed fresh, pinnable, or from Tournament | Seed field in the form; test play pins a seed for reproducible retries |
| level-data-definition.md (TR-level-data-definition-006) | Draft → Valid → Locked; shipped edit bumps version | Status chip; Locked hash warning; save requires version bump |
| level-data-definition.md (TR-level-data-definition-008) | Duplicate level ids fail validation | New/duplicate level runs the campaign-wide id check through the validator |
| level-data-definition.md, edge case + UI note | Editor lists effective values and validation results per level | Effective-value knob rows; per-field issues |
| level-data-definition.md, Open Question "Level editor" | In-engine editor or text first? | Resolved: in-engine EditorPlugin dock (user, 2026-10-10) |
| mechanics-module.md (TR-mechanics-module-002) | Compatibility tags validated for every level | Picker greys out incompatible atoms as a hint; validator decides |
| mechanics-module.md (TR-mechanics-module-003) | Recipe maps 1:1 onto level JSON fields | Picker writes `recipe`; loader expansion is the single mapping |

## Performance Implications
- **Editor CPU**: one validation per 150 ms debounce window; < 50 ms per Meadow level (ADR-0005 budget).
- **Test play**: save + scene launch target < 2 s; in-game restart without reload < 300 ms.
- **Runtime**: none. The addon is not exported. `src/data/authoring/` is not loaded by the game in the MVP.
- **Disk**: `.bak` per edited level per session (gitignored).

## Migration Plan

Nothing to migrate: `meadow_01.json` is opened as it is. Changes to other files, to be made by their owners when this ADR is Accepted (none made by this ADR):
- `docs/architecture/tr-registry.yaml` / `requirements-traceability.md`: add ADR-0017 to the TR rows listed above.
- `architecture.md` §3 ADR list; `architecture-modular-layout.md`: add `src/data/authoring/` and `addons/wt_level_tools/`.
- `design/gdd/level-data-definition.md` Open Questions: mark "Level editor" resolved.
- Export presets (devops-engineer): exclude `addons/wt_level_tools/*`; `.gitignore`: `*.json.bak`, `*.json.tmp`.
- Lock manifest location: confirm with devops-engineer.

**Rollback plan**: disable the plugin. Level JSON is unchanged, so hand editing continues with no loss.

## Validation Criteria

- [ ] [U] `LevelDocument`: load → save round trip of every file under `src/levels/` gives the same `level_hash`, and an unknown key survives.
- [ ] [U] `LevelEdit`: every edit kind's `apply()` then `revert()` restores the document exactly; a paint drag is one edit.
- [ ] [U] `AtomicJsonWriter`: a failure injected between `.tmp` write and rename leaves the original file byte-identical.
- [ ] [U] `FieldSchema`: int/float/bool/enum/id/ms schemas produce the right widget type and limits; an unknown type falls back to raw JSON.
- [ ] [U] `LockManifest`: a changed hash for a locked id is reported; save without version bump is refused.
- [ ] [U] Grep test: `src/data/authoring/` references no `Editor*` class; no `ResourceLoader.load` on level paths in `addons/wt_level_tools/`.
- [ ] [M] In the editor: open meadow_01, set `fall.g0` out of range → the field turns red within 0.5 s and the Issues list names field and rule; Ctrl+Z restores it.
- [ ] [M] Paint a target shape on layers 0 and 1, save, reopen → identical grids; the file diff shows only the changed rows.
- [ ] [M] Play → meadow_01 runs in under 2 s; `R` restarts without reload; same seed gives the same first pieces (screenshot in `production/qa/evidence/`).
- [ ] [M] Export Android and PC presets → no `wt_level_tools` path in either `.pck`.

## Related
- ADR-0002 (ASCII layer grids, `BoardSpec.parse`), ADR-0004 (knob/param/atom schemas, `PluginRegistry`), ADR-0005 (format, loader, validator, `level_hash`, editor panel), ADR-0006 (pinned seeds), ADR-0008 (GDScript only), ADR-0010 (`PlaySession.start/restart`), ADR-0011 (beehave staging trees)
- `design/gdd/level-data-definition.md`, `design/gdd/mechanics-module.md`, `design/levels/meadow.md`
- `docs/architecture/architecture-modular-layout.md` §5, §8
