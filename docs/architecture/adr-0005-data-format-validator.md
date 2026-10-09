# ADR-0005: Data Format (Shapes, Levels, Rules, Knobs) and Validator

## Status

Proposed

> Who may move this to `Accepted`: the user, or `technical-director` on the user's explicit confirmation.

## Date

2026-10-09

## Last Verified

2026-10-10

## Decision Makers

Tessa (user: player-made and shared levels planned now; levels in JSON; validator in tests, debug builds, at every player-level load, and an editor panel), godot-specialist (lead architect)

## Summary

All gameplay data is JSON — levels (official and player-made), rule definitions, knob tables and minigame entries — loaded by one schema-checked loader, because player-shared files are untrusted and a `.tres` can carry script. The only `.tres` data is the generated shape bank (ADR-0003). One pure `LevelValidator` checks every level and runs in the test suite, at load in debug builds, at every player-level load in all builds, and later in an editor panel.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Scripting |
| **Layer** | Foundation |
| **Knowledge Risk** | MEDIUM — `JSON`, `FileAccess`, `DirAccess` are stable 4.x; `FileAccess` return types changed in 4.4 |
| **References Consulted** | `docs/engine-reference/godot/breaking-changes.md` (4.4 FileAccess), `deprecated-apis.md`, `current-best-practices.md` |
| **Post-Cutoff APIs Used** | Typed `Dictionary[K, V]` (4.4) for parsed sections |
| **Verification Required** | Verified 2026-10-09 on 4.7.2: JSON numbers arrive as float; a `.tres` can embed GDScript source as a sub-resource (confirms the untrusted-`.tres` risk). Still to verify: `DirAccess` listing of `res://assets/data/**.json` inside an exported `.pck` with the `*.json` export filter |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0003 (shape ids), ADR-0004 (knob and rule schemas the validator checks) |
| **Enables** | Level authoring, campaign, arcade, level sharing, editor panel |
| **Blocks** | Level loading story; meadow levels as files |
| **Ordering Note** | Loader + validator before meadow_01 is authored as a file |

## Context

### Problem Statement

100 campaign levels plus arcade, tournaments and **player-made, shared levels** must be data, not code. A `.tres` file can embed a GDScript resource, so loading a stranger's `.tres` with `ResourceLoader` can run their code. Levels also need a validator (Level Data GDD rules 5–6) that names the level, field and rule on failure.

### Constraints

- Untrusted files must never reach `ResourceLoader.load` or `load()`.
- Every field optional except `id`, `biome`, `tier`; omitted fields use GDD defaults.
- Level files never contain behaviour (Level Data rule 4).
- Shape targets are per-layer ASCII grids in the level file (round-2 decision).

## Decision

### Formats

| Data | Format | Location | Trust |
|---|---|---|---|
| Shape bank | `.tres` (generated, ADR-0003) | `res://assets/data/shapes/` | internal |
| Knob tables | JSON | `res://assets/data/knobs/<system>.json` | internal |
| Rule definitions | JSON | `res://assets/data/rules/<rule_id>.json` | internal |
| Minigame entries | JSON | `res://assets/data/minigames/<id>.json` | internal |
| Content types (blocks, obstacles, objects, overlays, statuses) | JSON | `res://assets/data/content/*.json` (ADR-0002 `ContentTypes`, ADR-0007 looks) | internal |
| Biomes (diorama dressing scenes, palettes of props) | JSON | `res://assets/data/biomes/<biome>.json` | internal |
| Board limits, net and view tunables | JSON knobs | `res://assets/data/knobs/board.json`, `net.json`, `view.json` | internal |
| Palette (art docs' colours as data) | JSON | `res://assets/data/palette.json` | internal |
| Official levels | JSON | `res://assets/data/levels/<biome>/<id>.json` | internal, but loaded through the untrusted path |
| Player levels | JSON | `user://levels/<id>.json`, imported/shared files | untrusted |

Official levels use the same loader and validator as player levels, so the untrusted path is exercised by every campaign test. Internal-only fields (a minigame's `scene` path, a rule's `behaviour` id) are accepted **only** from `res://` data; a level can only name `rule_id`s, `shape_id`s and knob ids that already exist.

### Level file shape

```json
{
  "schema": 1,
  "id": "meadow_06", "biome": "meadow", "tier": 6, "name": "Flower Bed",
  "layout": { "kind": "single" },
  "board": { "width": 8, "depth": 8, "h_play": 12, "down_axis": "-y",
             "mask": ["########", "..."], "starting_contents": [] },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_left","screw_right"], "weights": {} },
  "knobs": { "fall.g0": 1.0, "fall.lock_delay_ms": 500, "clear.collapse": "slice",
             "spawn.arrival": "top", "goal.top_out": "trim" },
  "goal": { "type": "shape", "target_layers": [["..##..", "..."]] },
  "mechanic": { "id": "fill_target_shape", "params": {} },
  "twists": [ { "id": "wind", "params": { "every_ms": 3000 } } ],
  "stars": { "times_ms": [180000, 240000, 300000] },
  "seed": null,
  "recipe": [ {"slot": "arrival", "atom": "side_travel"}, {"slot": "clear", "atom": "colour_connect"} ],
  "story": { "title_key": "LVL_MEADOW_06_TITLE", "text_key": "LVL_MEADOW_06_STORY", "icon": "flower" }
}
```

- **Several boards** (islands, lanes, tracks): `layout.kind` names a `LayoutKind` plugin (ADR-0004) and `boards` replaces `board` with a list, each entry a full board section plus `id`, `transform` (position/yaw in the diorama) and optional `links` (which board a piece or content passes to, e.g. a lane edge leading to the next lane). One-board levels keep the short `board` form. Layout-specific checks live in the `LayoutKind` plugin's `validate()`.
- **`recipe`** (optional): the list of mechanic atoms (`design/gdd/mechanics-module.md`) the level is built from, by slot. It is authoring metadata for the editor panel and the daily "box of tricks" generator: the loader expands it into slot knobs and rule entries, and explicit `knobs`/`twists`/`mechanic` win over it. The validator checks the expanded result, including atom compatibility tags (ADR-0004).
- **`story`** (optional): an intro card (title, text, icon).
- **Text is translation keys.** Every player-visible text field (`name`, `story.*`, goal text, rule names) holds a translation key (`LVL_MEADOW_06_TITLE`), resolved with `tr()` in the UI, never shown raw. Player-made levels may instead carry literal text in a `text` sub-field (no translation); the UI shows it as plain text, escaped.
- **Daily box of tricks**: a generator picks a compatible atom set and parameters from `round_seed` (ADR-0006 stream `["daily", date]`) and produces a `LevelData` through the same `recipe` path, then runs the same validator; an invalid mix is re-rolled up to `daily.max_rerolls` (knob).
- `knobs` is a flat map of knob id → value: the level's base overrides (any knob in `assets/data/knobs/*.json`, rule-adjustable or not, within its range). Named sections (`board`, `pieces`, `goal`) hold structured data that is not a single knob.
- Down axis and arrival travel use the 6 direction tokens `+x -x +y -y +z -z`.
- `schema` integer; the loader upgrades older schemas step by step (`LevelMigrations`), rejects newer ones.

### Loader (`DataLoader`)

- Reads text with `FileAccess.get_file_as_string`, rejects files over `data.max_level_bytes` (knob, default 256 KB), parses with `JSON.parse_string`, requires a top-level Dictionary.
- Converts to typed `LevelData` (RefCounted) field by field against the schema. Typed dictionaries are filled with `typed.assign(parsed)` (verified on 4.7.2: direct assignment of a parsed Dictionary to a typed field fails at runtime). JSON numbers arrive as float (verified); integer fields are converted with a check that the value is whole. Unknown top-level keys are errors (catch typos); unknown keys in `params` are errors.
- Bounds before allocation: board dimensions, ASCII grid sizes, list lengths capped by knob ranges, so a hostile file cannot allocate a huge board.
- Each board section is parsed by ADR-0002's `BoardSpec.parse` (bounds before allocation); this loader calls it rather than duplicating board checks.
- `level_hash` = SHA-256 of the canonical re-serialised JSON (`JSON.stringify` with sorted keys) — the identity for stars, replays (ADR-0001) and sharing. Editing a Locked level changes its hash (Level Data states).

### Validator (`LevelValidator`)

- Pure: `validate(level: LevelData, ctx: ValidationContext) -> Array[ValidationIssue]`; `ValidationIssue {level_id, field, rule, severity (error|warn), message}`. `ValidationContext` carries the shape bank, knob registry definitions, rule catalog and plugin registry (injected; no singletons).
- Checks: all Level Data GDD rule 6 checks; knob ids exist, values typed and in range, `allows_zero`; rule ids exist, params in schema, F3 budget (2 twists + 1 mechanic), `incompatible_with`, every rule has an icon; slot values name registered plugins and are compatible; shape ids in the bank and fit the board; ASCII targets match board size.
- Plugins may add checks: a strategy or behaviour can implement `validate(level, ctx) -> Array[ValidationIssue]` (e.g. conveyor requires an unmasked board), so mechanic-specific checks live with the mechanic, not in the validator.

### Where validation runs

1. **Test suite** (CI gate): `tests/unit/data/level_files_test.gd` validates every file under `res://assets/data/levels/`.
2. **Debug builds**: every level at load; errors stop the load, warnings print.
3. **All builds, player levels**: every player/shared level at load and at import; errors refuse the level with a readable message.
4. **Editor panel** (planned, built when authoring needs it): an `EditorPlugin` dock under `addons/wt_level_tools/` that calls the same validator on the open/selected level file and lists issues. No validator logic in the plugin.

### Key Interfaces

```gdscript
class_name DataLoader extends RefCounted
static func load_level(path: String, migrations: LevelMigrations) -> LoadResult  # {level: LevelData, issues}
static func load_json_dir(res_dir: String) -> Dictionary[StringName, Dictionary]   # internal res:// only

class_name LevelValidator extends RefCounted
func validate(level: LevelData, ctx: ValidationContext) -> Array[ValidationIssue]
```

### Implementation Guidelines

- A test greps `src/` for `load(` / `ResourceLoader.load` with any `user://` path or variable path from level data and fails on a hit.
- **Export presets must include `*.json`** in the non-resource export filter, or all data is missing from the APK (devops; checked by an export smoke test).
- **Asset credits** from day one: `res://assets/data/credits.json` lists every third-party asset (name, author, licence, source URL, files), e.g. Kenney CC0 packs, rFXGen/jsfxr sounds, add-ons. A test fails if a file under `assets/third_party/` or `addons/` has no credits entry. The credits screen reads this file.
- Keep JSON field names snake_case and equal to GDD knob names where one exists.

## Alternatives Considered

### Alternative 1: `.tres` for everything
- **Pros**: Inspector editing, typed fields.
- **Cons**: Untrusted `.tres` can embed scripts; unsafe for sharing.
- **Rejection Reason**: User wants player levels now.

### Alternative 2: `.tres` internal + JSON player levels (two level formats)
- **Rejection Reason**: Two loaders, and official levels would not exercise the untrusted path.

### Alternative 3: Binary or custom format
- **Rejection Reason**: Not diffable or hand-editable; no gain at this size.

## Consequences

### Positive
- Safe sharing, diffable levels, one loader, validator reusable everywhere.

### Negative
- No inspector editing of levels until the editor panel exists; hand-written JSON needs the validator's messages to be good.

### Neutral
- JSON floats need explicit int conversion (handled in the loader).

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Hostile JSON (huge sizes, deep nesting) | Medium | Medium | Size cap, bounds before allocation, schema rejects unknown keys |
| Validator rules drift from GDDs | Medium | Medium | Each GDD acceptance criterion gets a validator test |
| `*.json` missing from Android export | Medium | High | Export filter + device smoke test |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| Load Time | — | parse + validate one level | < 50 ms |
| Memory | — | < 100 KB per level | — |

## Migration Plan

None — new. `design/levels/meadow.md` levels are transcribed into JSON files when built.

**Rollback plan**: `LevelData` is the in-memory type; the source format can change behind `DataLoader`.

## Validation Criteria

- [ ] All 10 meadow level files validate in CI.
- [ ] A level with 3 twists, an unknown knob, an out-of-range value, a fractional int, an unknown key and a 10 MB file each fail with level, field and rule named.
- [ ] Grep test: no `ResourceLoader`/`load()` on `user://` paths.
- [ ] Same file → same `level_hash` on every run.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/level-data-definition.md` | Level Data | Rule 1: storage format is an ADR | JSON, one loader |
| `design/gdd/level-data-definition.md` | Level Data | Rule 2: omitted fields take defaults | Knob registry base values; `knobs` map overrides |
| `design/gdd/level-data-definition.md` | Level Data | Rules 5–6: validator names level, field and rule | `ValidationIssue`; runs in 4 places |
| `design/gdd/level-data-definition.md` | Level Data | Rule 7: seed per attempt or pinned | `seed` field (ADR-0006) |
| `design/gdd/level-data-definition.md` | Level Data | States Draft → Valid → Locked | `level_hash` identity |
| `design/gdd/rule-twist-framework.md` | Rule-Twist | F3 budget, icons, param ranges | Validator checks via rule JSON schema |
