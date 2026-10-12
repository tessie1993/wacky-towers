# ADR-0013: Save, Profile and Settings

## Status

Accepted (2026-10-10, accepted by user)

## Date

2026-10-10

## Last Verified

2026-10-10

## Decision Makers

Tessa (user, Wave 1 decision sheet 2026-10-10), engine-programmer (draft); godot-specialist to validate before Accepted

## Summary

Everything that must survive closing the app lives under `user://save/` as plain JSON, never as Godot resources. Each file has a versioned envelope with a SHA-256 checksum. Old schemas are migrated forward step by step on load and never thrown away. Writes are atomic (temp file, verify, rotate main to backup, rename temp to main), run off the main thread, and a corrupt file falls back to the backup. Each profile has its own progress file and settings file. A third, device-wide file holds audio and display settings. Stars are keyed by level id, stored with the level's content hash, and never go down, even when a level is rebalanced. The MVP has 4 profile slots (0–3) from the start and remembers the last-used profile. Profile select runs at first launch, or whenever the remembered profile is missing. Rename and delete are crash-safe, because the profile index is the single source of truth. Points, perks, potions and skills get reserved inventory fields whose contents stay opaque until they are designed. Cloud save sits behind a backend interface. The MVP backend is a no-op, and Steam Cloud and Google Play saved games plug in later. Android and PC use the same code, and only the `user://` root differs.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core / Persistence (file I/O, threading, platform paths), Accessibility (OS reduced-motion query) |
| **Layer** | Core (framework, `src/game/save/`) |
| **Knowledge Risk** | MEDIUM. `FileAccess`, `DirAccess`, `JSON`, `HashingContext` and `WorkerThreadPool` have been stable since 4.0, but none is covered in `docs/engine-reference/godot/` apart from the 4.4 change where `FileAccess.store_*` returns `bool`. The `DisplayServer.accessibility_*` queries are 4.5+ (post-cutoff) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.4 `FileAccess.store_*` → `bool`), `deprecated-apis.md`, `current-best-practices.md` (Accessibility 4.5+), `modules/audio.md`, `modules/input.md`; ADR-0005 (`level_hash`), ADR-0010 (`app_backgrounded`, WorkerThreadPool save) |
| **Post-Cutoff APIs Used** | `DisplayServer.accessibility_should_reduce_animation()` (4.5+); `FileAccess.store_string()` returning `bool` (4.4+) |
| **Verification Required** | (1) Android: `DirAccess.rename_absolute(tmp, main)` replaces an existing file atomically on internal storage. (2) Android: `DisplayServer.accessibility_should_reduce_animation()` returns `true` when Developer options → "Remove animations" (or Accessibility → "Remove animations") is on, and changes after `NOTIFICATION_APPLICATION_RESUMED`. If not, fall back to a ~20-line Android v2 plugin that reads `Settings.Global.ANIMATOR_DURATION_SCALE == 0`. (3) Android: a save started on `app_backgrounded` finishes before the process is frozen (kill the app from the switcher right after Home, then relaunch and check the record). (4) Windows/Steam: the folder `use_custom_user_dir` produces is the one Steam Auto-Cloud will later point at. **Verified headless on 4.7.2 (Windows, 2026-10-10):** `DisplayServer.accessibility_should_reduce_animation / _increase_contrast / _reduce_transparency / _screen_reader_active` exist; `DirAccess.rename_absolute` over an existing file returns `OK` and replaces its content; `DirAccess.copy_absolute`, `remove_absolute`, `FileAccess.flush`, `Crypto.generate_random_bytes` exist; `JSON.stringify` takes 4 arguments (`sort_keys` included); the project setting `application/config/use_custom_user_dir` exists |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0005 (Accepted): `level_hash` (SHA-256 of canonical level JSON) and level `id`/`version`. ADR-0010 (Accepted): the `app_backgrounded` signal, the `LevelResult` fan-out, and the rule that no save happens during play |
| **Enables** | ADR-0012 (input remap persistence: this ADR stores the bindings it serialises), ADR-0015 (audio bus volumes), ADR-0016 (settings screen, profile select / create / rename / delete screens), ADR-0010 (profile-select hook in the boot flow), Points/Shop/Perks/Potions/Skills designs (reserved inventory fields), campaign unlock gating (TR-campaign-structure-002) |
| **Blocks** | Meadow MVP plan: "stars persist across restart" and the settings overlay; first-run accessibility picker (ACC-02) |
| **Ordering Note** | `relaxed_time_scale` must exist in the knob registry (ADR-0004) before `StarRater` reads it. ADR-0012 must provide `to_dict()/from_dict()` for bindings before remap persistence is wired up. Until then the `controls.remap` section is stored and loaded untouched |

## Context

### Problem Statement

Save & Profile, Scoring & Stars, Settings and the accessibility requirements all assume a store that never loses progress, but there is none yet. `architecture-modular-layout.md` lists `profile_store.gd` as "after first playable" and nothing else. The GDD leaves the storage format and platform APIs to an ADR. The Wave 1 decision sheet narrows the scope: save locally only for now with a versioned format and a cloud seam; 4 profiles in the MVP (user decision 2026-10-10, replacing the sheet's "one profile"); relaxed timing can still earn all 3 stars with scaled times and no badge; reduced motion follows the OS; Android and PC/Steam ship together; no analytics; no monetisation SDKs.

### Constraints

- Saving must be invisible: never during play, never a main-thread stall (Save & Profile Game Feel; ADR-0010 §2).
- Unit tests must not touch the file system (coding standards). File access goes through an injected interface.
- Few autoloads (architecture.md principle 5). `Main` lives for the whole app and owns the store.
- `BoardSim` is deterministic (ADR-0001). Settings that change gameplay (relaxed timing) are applied once at level construction, never mid-level.
- Kids' privacy: names stay on the device, or later in the platform's own cloud. There is no server and no analytics.
- One build for Android (arm64/armv7) and Windows (Steam). GodotSteam is excluded from the Android export through feature tags.

### Requirements

- A versioned schema with forward migrations. Old saves are never discarded (TR-save-profile-003).
- Atomic writes with a backup, and recovery from a corrupt main file (TR-save-profile-002).
- Best stars per level that never go down, including after a level is rebalanced or re-versioned (TR-scoring-stars-003, TR-campaign-structure-004).
- Separate settings for audio, controls/remap, camera and accessibility, persisted on change (TR-touch-controls-007, TR-menus-level-select-006).
- 4 profiles, each with its own progress and settings; a 5th cannot be created (TR-save-profile-001, Save & Profile AC 5). The last-used profile is remembered so a returning player goes straight in (TR-menus-level-select-007).
- Storage for secrets, cosmetics, unlocks, Arcade bests and tournament stats (TR-mechanics-module-010, TR-arcade-mode-006, TR-tournament-flow-008).
- A save within 1 s of a result, settings change or unlock (TR-save-profile-004).

## Decision

### 1. Files and paths

```
user://save/
  index.json     (+ .bak)           # 4 slots, names, last_used          (envelope kind "index")
  device.json    (+ .bak)           # device-wide settings: audio, display (kind "device")
  slot_0/ … slot_3/
    progress.json  (+ .bak)         # records, unlocks, stats, inventory (kind "progress")
    settings.json  (+ .bak)         # per-profile settings                (kind "settings")
```

- Folders are named by **slot** (0–3), so paths stay short and fixed. The stable `profile_id` lives inside the index and each file, and the cloud merge uses it (§8).

- `user://` resolves to app-internal storage on Android (`/data/data/<package>/files`, private, no storage permission needed, included in Android Auto Backup unless that is opted out later). On Windows it resolves to `%APPDATA%/<dir>`. `project.godot` sets `application/config/use_custom_user_dir = true` and `custom_user_dir_name = "WackyTowers"`, so the PC path is `%APPDATA%/WackyTowers/save/`. The path stays stable even if `config/name` changes, and Steam Auto-Cloud can point at it later. No code branches on platform. Only `OS.get_user_data_dir()` differs.
- **JSON only.** Never `ResourceLoader.load()`, `ConfigFile` with objects, or `FileAccess.get_var(true)` on anything under `user://`. A `.tres` file in a writable folder can carry script and run code. Remap bindings and layouts are stored as plain dictionaries too.
- Numbers are integers wherever possible (times in ms). The loader converts the floats `JSON.parse` returns back to `int`, as in ADR-0005.

### 2. Envelope, schema version, checksum

```json
{ "format": "wacky_towers_save", "kind": "progress", "schema": 1,
  "written_at": 1791600000, "app_version": "0.1.0",
  "checksum": "<sha256 hex of JSON.stringify(data, \"\", true)>",
  "data": { ... } }
```

- `schema` is one integer per `kind`, owned by `SaveSchema` (`const PROGRESS_SCHEMA := 1`, `SETTINGS_SCHEMA := 1`, `DEVICE_SCHEMA := 1`, `INDEX_SCHEMA := 1`).
- `checksum` is SHA-256 (`HashingContext`) over the sorted-key serialisation of `data`. A file is **valid** when it parses, `format` and `kind` match, and the checksum matches. Anything else counts as corrupt.
- **Migrations**: `SaveMigrations` holds one pure function per step, `migrate_<kind>_<n>_to_<n+1>(data: Dictionary) -> Dictionary`. On load, steps run in order up to the current schema, and the result is written back at once with a fresh backup. Each migration has a unit test with a frozen fixture of the old version, and fixtures are never edited after a release.
- **Unknown keys are kept.** The loader copies keys it does not know through unchanged, so a field written by a newer build survives a round trip through an older one.
- **A newer schema than the build knows** (a downgrade, or later a cloud copy from an updated device) loads **read-only**. The game plays and shows existing progress, but `SaveStore` refuses to write that file and logs a warning. The newer data is never overwritten.

### 3. Atomic write, backup, recovery

Write sequence for `<f>` (`progress.json`, `settings.json`, `device.json` or `index.json`):

1. Serialise the snapshot to a string, then `store_string()` to `<f>.tmp`. Check the `bool` result (4.4+), `flush()`, `close()`.
2. Read `<f>.tmp` back and validate it (parse + checksum). If that fails, delete it and give up on this write. The old files stay untouched.
3. If `<f>` exists and is valid: `rename_absolute(<f>, <f>.bak)` (replaces the old backup).
4. `rename_absolute(<f>.tmp, <f>)`.

A crash between any two steps always leaves at least one valid copy. Load order: `<f>` if valid → `<f>.bak` if valid → `<f>.tmp` if valid (a crash between steps 3 and 4) → fresh defaults.

- Whenever the loader falls back, it keeps the broken file as `<f>.corrupt-<unix_s>` (at most 2, oldest removed) for bug reports and then rewrites `<f>` from the recovered copy.
- **Both main and backup corrupt**: start fresh and set `SaveStore.last_load_report.recovered = &"fresh"`. The UI then shows one notice ("We couldn't read your saved progress, so you're starting fresh"). With a cloud backend, the cloud copy is offered first (§8).
- **Threading**: the snapshot is a `duplicate(true)` taken on the main thread. Steps 1–4 run in one `WorkerThreadPool` task. `SaveStore` has **one writer**. A request that arrives while a write is in flight replaces the pending snapshot for that file ("latest wins"), so at most one write runs and one waits per file. `flush_blocking()` (used by the quit confirm and `NOTIFICATION_WM_CLOSE_REQUEST`) waits for the in-flight task with `WorkerThreadPool.wait_for_task_completion`.
- **When**: after a `LevelResult` is applied, a settings change (debounced 500 ms so dragging a slider writes once), an unlock, a profile change, and on `AppFlow.app_backgrounded` (flush only if something is dirty). `SaveStore` ignores save requests while `PlaySession` is in `PLAYING`/`WARNING`. They are kept as dirty flags and written at the next allowed point. Settings changed from Pause are allowed because the board is frozen.

### 4. Progress record and the never-decreasing rule

```json
"levels": {
  "meadow_03": { "stars": 2, "best_ms": 400000, "best_score": 1840,
                 "level_hash": "9f2c…", "level_version": 3, "first_cleared_at": 1791600000 }
}
```

- Records are keyed by **level id** (unique across the campaign, TR-level-data-definition-008). They are never keyed by path or hash, so moving a file or rebalancing a level never orphans a record.
- `ProgressRecord.apply(result, level_hash, level_version) -> bool` (pure):
  - `stars = max(old.stars, new_stars)`. **Stars never decrease**, whether on a replay, after a rebalance, after a change to star times, or after a migration.
  - `best_ms` is replaced when the new result has more stars, or equal stars and a lower time. `best_score = max(old, new)` on its own (GDD F1).
  - `level_hash` / `level_version` are updated only when the record improves, so they always describe the level the stored best was earned on.
- **Rebalance**: the save never recomputes stars from stored times. A record whose `level_hash` differs from the loaded level's `level_hash` (ADR-0005) is an **older-version record**. Menus may show a small marker (Level Data rule; how it looks is up to ADR-0016). The stars still count for unlocks and points.
- **Relaxed timing**: `StarRater` scales `t2`/`t3` by the knob `relaxed_time_scale` (ADR-0004; ACC-50) when the profile has relaxed timing on. The record stores the stars and the clock as earned, with **no relaxed flag and no badge** (decision sheet). `best_ms` is still the actual level clock.
- Other progress sections (all keyed by stable ids, all only growing except counters):
  - `unlocks`: `{ "levels": [...], "biomes": [...], "pools": { "twists": [...], "mechanics": [...], "specials": [...] } }`, stored as sorted arrays and treated as sets.
  - `secrets`: `{ "<secret_id>": true }`; `cosmetics`: `{ "<cosmetic_id>": { "owned": true } }`.
  - `arcade`: `{ "<biome_skin_id>": { "best_score": 0 } }`; `tournament`: `{ "played": 0, "won": 0 }`.
  - `first_run`: `{ "accessibility_picker_done": false }` (ACC-02).

### 5. Reserved inventory (design TBD)

```json
"wallet":    { "stars": 0 },
"inventory": { "perks": {}, "potions": {}, "skills": {} }
```

- **Shop currency = stars (amendment 2026-10-10, user decision).** `wallet.stars` is a per-profile *spendable* balance, separate from the earned per-level stars in `levels`. When `ProgressRecord.apply` raises a level's stars, the gain (`new − old`, never negative) is added to `wallet.stars` in the same write. Spending only lowers `wallet.stars` and never touches `levels`, so earned stars (unlocks, star totals) never decrease. The balance is an `int` clamped at ≥ 0; a spend that would go below 0 is refused.
- These exist from schema 1 so the first real design does not need a migration just to add them. Each map is `item_id → Dictionary`. `SaveStore` treats the inner dictionaries as opaque and stores whatever the owning system puts there. The owning system (Points, Perks, Potions, Skills, none designed yet) defines the inner fields and their migration when it lands.
- Rules fixed now, so later designs cannot break the save: ids are stable `StringName`s from data files (never display names). Counts are `int`. Nothing in these maps is computed from wall time. A skill's use rule (charge meter / once per level / consumable, decision sheet) lives in the skill's **data**, and only the player's ownership and count live here.
- **Monetisation seam**: there is none in the save. Any future purchase record would be a new `kind` file with its own schema, so receipts never mix with progress.

### 6. Profiles

- **4 slots from the MVP on** (`max_profiles = 4`, GDD knob; user decision 2026-10-10). `index.json`:
  ```json
  { "last_used": 0,
    "slots": [ { "id": "<profile_id>", "name": "Mia", "created_at": 1791600000, "color": "sky", "badge": "acorn" },
               null, null, null ] }
  ```
  `slots` always has exactly 4 entries, and `null` means empty. `last_used` is a slot number or `null`.
- `profile_id` is 32 hex characters from `Crypto.generate_random_bytes(16)`, not the slot number, so profiles from two devices never collide when merged later (§8).
- **The index is the single source of truth — while it is readable.** A slot folder that a *valid* index does not list is an orphan left by a crash. It is deleted at boot. A slot the index lists whose folder is missing loads fresh defaults. All index changes use the atomic write from §3.
- **Unreadable index = rebuild, never clean up** (amendment 2026-10-10, `design/gdd/ux/loading-and-save-error.md`). When `index.json` loads as `recovered = &"fresh"` (main, `.bak` and `.tmp` all invalid), boot **skips orphan cleanup entirely** and rebuilds the index from the slot folders: each `slot_<n>/` whose `progress.json` (or its `.bak`) is valid becomes an entry with the `profile_id` stored in that file; the name falls back to a translated default (`UI_PROFILE_DEFAULT_NAME`, "Player n+1"), color/badge to defaults; `last_used = null` so profile select shows. The rebuilt index is written atomically, then the normal fresh-start/backup notice rules apply. A slot folder with no valid file is left on disk untouched (kept for bug reports), not deleted.
- **Create**: uses the lowest empty slot. If none is free, the create button is disabled, so a 5th profile can never be made (AC 5). Write order: the slot's `progress.json` and `settings.json` are written first (defaults, with the per-profile settings seeded from the current device's choices), then the index. A crash in between leaves an orphan folder, which boot cleans up.
- **Rename**: changes the index only, in one atomic write. The name is trimmed, control characters are stripped, it must be 1–12 characters (`profile_name_length` knob), and it must not match another slot's name case-insensitively. User-typed names are shown as typed and never pass through translation.
- **Delete**: needs a confirmation that names the profile and what is lost ("Mia: 23 ★ and 9 levels"). It is allowed only from the profile screens, never while a `PlaySession` exists. Order: (1) clear the slot in the index (atomic), (2) remove the slot folder. A crash between the steps leaves an orphan, which boot cleans up, so a deleted profile can never come back half-there. Deleting the `last_used` slot sets `last_used = null`. Deleting the active profile first switches to "no profile", then shows profile select.
- **Switch**: allowed only from menus. `ProfileStore.switch_to(slot)` flushes the current profile's dirty files, loads the target's progress and settings, sets `last_used`, writes the index, then emits `profile_changed(slot)`. Every system re-reads through the stores, and nothing caches profile data across that signal.
- **Profile-select hook (ADR-0010 / ADR-0016)**: `ProfileStore.needs_profile_select() -> bool` is true when `last_used` is `null`, or points at an empty or unreadable slot. At boot `AppFlow` checks it after Title. If it is true, it pushes `&"profile_select"`; with all slots empty that screen opens straight into create, followed by the ACC-02 first-run picker. If it is false, the remembered profile loads with no extra screen (≤10 s launch to play, TR-menus-level-select-007). A "Change profile" entry on Title/Island map pushes the same screen. ADR-0016 owns how the screens look; this ADR owns only the calls.
- **Guests** (local multiplayer, later): `ProfileStore.active_profile()` returns `null`. Every write path checks for it and does nothing, so nothing is saved for a guest (TR-save-profile-008).

### 7. Settings (per-profile file + device-wide file)

Two files. **`slot_<n>/settings.json`** holds what belongs to the player: controls, camera, accessibility. **`device.json`** holds what belongs to the machine: audio and display. Every profile on a device shares the speaker volume and the window mode, while a child's big buttons or relaxed timing stay with that child's profile.

| File | Section | Keys (defaults from `design/gdd/ux/settings.md`, `design/accessibility-requirements.md`) |
|---|---|---|
| device | `audio` | `music: 80`, `sfx: 80`, `ui: 70` (0–100, step 10); `haptics: "light"` |
| device | `display` | PC: `window_mode: "windowed"` (`windowed` / `fullscreen` / `exclusive`), `vsync: true`, `max_fps: 0` (0 = uncapped); Android: `max_fps: 60` (30 / 60 / 120 where the screen supports it) |
| profile | `controls` | `preset: "buttons"`, `mirror: false`, `repeat_delay_ms: 240`, `repeat_interval_ms: 90`, `drag_px_per_cell: 44`, `flick_px: 70`, `layout: { "portrait": {...}, "landscape": {...} }`, `remap: { "keyboard": {...}, "gamepad": {...} }` |
| profile | `camera` | `control: "snap"`, `turn_anim: true`, `occlusion: "level"` |
| profile | `accessibility` | `colorblind: "shapes"`, `reduced_motion: "system"` (`system` / `off` / `on`), `relaxed_timing: false`, `ui_scale: 100` (75–200, buttons never below 56 dp; decision sheet), `button_labels: {menus: true, play: false}`, `rotation_gizmo: "auto"`, `show_clock: "auto"` |
| both | (meta) | `changed_at: <unix_s>` (for the cloud merge's "newest settings"); `device.json` also holds `locale: "en"` (English only for now) |

- `device.json` never syncs to the cloud. The profile `settings.json` syncs except `controls.layout` and `controls.remap`, because a phone thumb layout or a keyboard remap means nothing on another device.
- The Settings screen shows both files as one list. `SettingsStore.set_value(section, …)` routes each section to its file, so callers never pick a file.

- `SettingsStore` validates and clamps every value against the GDD ranges when loading and when setting. A value it does not know falls back to the default and logs one warning. A bad settings file never blocks boot.
- **Apply**: `SettingsStore` emits `changed(section: StringName)`, and each owner applies its own section. Audio (ADR-0015): `AudioServer.set_bus_volume_db(bus, linear_to_db(v / 100.0))`, and `0` mutes the bus. Input (ADR-0012): GUIDE remap from `remap` via ADR-0012's `from_dict()`. Settings never holds GUIDE resources. UI scale (ADR-0016).
- **Reduced motion follows the OS**: the effective value is `on`/`off` as set, or for `system` it is `DisplayServer.accessibility_should_reduce_animation()`. That is read at boot and again on `NOTIFICATION_APPLICATION_RESUMED` / `FOCUS_IN`, and a `changed(&"accessibility")` is emitted if it flips. Everything reads the effective value through `SettingsStore.reduced_motion() -> bool`, never the raw key. ACC-02's first-run picker still offers the toggle.
- **Relaxed timing** is read by `PlaySession.start()` and passed into `BoardSim` construction as knob overrides (ADR-0004). Turning it on from Pause applies **from the next level start**, and the pause menu says so. A running sim never changes mid-level (ADR-0001 determinism).

### 8. Cloud-save seam (not built in MVP)

```gdscript
class_name CloudSaveBackend extends RefCounted      ## src/game/save/cloud/
func is_available() -> bool                         ## signed in + reachable
func push(kind: StringName, profile_id: String, envelope_text: String) -> void
func pull(kind: StringName, profile_id: String) -> String   ## "" if none
signal pulled(kind: StringName, profile_id: String, envelope_text: String)
```

- MVP ships `NullCloudBackend` (`is_available() == false`). `SaveStore` calls the backend after each successful local write, throttled to `sync_min_interval_s` (GDD knob, default 60), and on `app_backgrounded`. A null backend makes all of this a no-op.
- Later backends: **Steam** through Steam Auto-Cloud configured on `%APPDATA%/WackyTowers/save/**` (no code at all), or GodotSteam Remote Storage if conflict control is needed. That code is PC-only behind the `steam` feature tag. **Android** through Google Play Games Services saved games (a Godot Android plugin, picked when it is built). iCloud is dropped because there is no iOS target (a deviation from the GDD).
- Conflicts use `ProgressMerge.merge(a, b) -> Dictionary` (pure, GDD F1): per level, more stars wins, then the faster time, with `best_score` taken as the max on its own; unlock arrays are unioned; counters are maxed; inventory merge is defined by its owning system when designed. Settings: the profile `settings.json` with the newer `changed_at` wins (minus `controls.layout`/`remap`); `device.json` never syncs. Profiles are matched by `profile_id`. An incoming profile takes a free slot, and with all 4 slots full it is kept as a hidden archive (GDD edge case). Because stars and unlocks only grow (§4), the merge is well defined. `ProgressMerge` is written and unit-tested together with the first real backend, not in the MVP.
- Offline is the normal case: local saves never wait on the backend (TR-save-profile-007).

### Architecture Diagram

```
Main (owns, not autoload)
 ├ SaveStore ──── SaveIO (FileSaveIO | MemorySaveIO in tests)
 │    │  envelope + checksum · SaveMigrations · one writer on WorkerThreadPool
 │    │  .tmp → verify → main→.bak → .tmp→main          CloudSaveBackend (Null in MVP)
 │    ├ ProfileStore   index.json · 4 slots · last_used · create/rename/delete/switch · needs_profile_select()
 │    ├ ProgressStore  progress.json · ProgressRecord.apply() (stars = max)
 │    └ SettingsStore  slot settings.json + device.json · clamp · changed(section) · reduced_motion()
 │
AppFlow.app_backgrounded ─▶ SaveStore.flush_dirty()
PlaySession.finished(LevelResult) ─▶ StarRater(level, relaxed?) ─▶ ProgressStore.apply() ─▶ SaveStore.request_write(&"progress")
SettingsStore.changed ─▶ AudioBuses (0015) · GameInput remap (0012) · UI scale (0016) · VFX/camera reduced motion
```

### Key Interfaces

```gdscript
# src/game/save/  (framework layer; core/data/view never import it)
class_name SaveIO extends RefCounted                 ## injected; the only file access
func read_text(path: String) -> String               ## "" if missing
func write_text(path: String, text: String) -> bool
func rename(from: String, to: String) -> Error
func remove(path: String) -> Error
func exists(path: String) -> bool

class_name SaveStore extends RefCounted
func _init(io: SaveIO, cloud: CloudSaveBackend) -> void
func load_all() -> SaveLoadReport                    ## sync at boot; ~18 KB, < 20 ms target
func request_write(kind: StringName) -> void         ## async, coalesced; no-op while playing or guest
func flush_blocking() -> void                        ## quit / close request only
var read_only: bool                                  ## true if any file had a newer schema
## Example:
##   var store := SaveStore.new(FileSaveIO.new(), NullCloudBackend.new())
##   var report := store.load_all()
##   if report.recovered == &"fresh": ui.show_notice(&"SAVE_RESET_NOTICE")

class_name ProgressRecord extends RefCounted         ## pure
static func apply(rec: Dictionary, stars: int, level_ms: int, score: int,
		level_hash: String, level_version: int) -> bool   ## true if improved; stars never drop
static func is_older_version(rec: Dictionary, current_hash: String) -> bool

class_name SaveMigrations extends RefCounted         ## pure, static
static func migrate(kind: StringName, data: Dictionary, from_schema: int) -> Dictionary

class_name ProfileStore extends RefCounted
const MAX_SLOTS := 4                                 ## mirrors knob max_profiles; index always has 4 entries
func slots() -> Array                                ## 4 entries: Dictionary or null
func active_profile() -> Variant                     ## Dictionary, or null for a guest / no profile yet
func needs_profile_select() -> bool                  ## AppFlow (ADR-0010) pushes &"profile_select" when true
func create(name: String) -> int                     ## lowest free slot, or -1 if full / invalid name
func rename(slot: int, name: String) -> Error        ## index-only atomic write; ERR_ALREADY_EXISTS on duplicate
func delete(slot: int) -> Error                      ## index first, then folder; ERR_BUSY while a PlaySession exists
func switch_to(slot: int) -> void                    ## flush, load, set last_used, emit
signal profile_changed(slot: int)
## Example:
##   if profiles.needs_profile_select(): app_flow.push(&"profile_select")

class_name SettingsStore extends RefCounted
func get_value(section: StringName, key: StringName) -> Variant
func set_value(section: StringName, key: StringName, value: Variant) -> void   ## clamps, emits, debounced save
func reduced_motion() -> bool                        ## effective value (OS-following)
func relaxed_timing() -> bool
signal changed(section: StringName)
```

### Implementation Guidelines

- All file access must go through `SaveIO`. No other class may open a file under `user://save/`.
- Never load a `Resource` from `user://`. Parse JSON only.
- Every schema bump must ship a migration step plus a frozen fixture test, and must never edit an older step.
- A record's `stars` must never be lowered by any code path: apply, migration, merge or repair.
- Saves must never run in `PLAYING`/`WARNING` and must never block the main thread outside `flush_blocking()`.
- Gameplay-affecting settings (relaxed timing) must be read only at level construction.
- All user-facing strings (reset notice, default profile name) must be translation keys.
- No analytics, telemetry or network calls in the save code. The cloud backend is the only exit, and it is null in the MVP.

## Alternatives Considered

### Alternative 1: `ConfigFile` / `.tres` resources in `user://`
- **Pros**: built in, typed, editor-inspectable.
- **Cons**: a resource loaded from a writable folder can run embedded script. Resources also give no checksum, no migration hook and no clean diff for cloud merges.
- **Rejection Reason**: security, plus no versioning story.

### Alternative 2: One file for progress and settings
- **Pros**: one atomic write, simpler.
- **Cons**: every slider drag rewrites the stars. A corrupt settings value risks the progress file. Cloud "newest settings" versus "best-of progress" need different merge rules anyway.
- **Rejection Reason**: the decision sheet wants them separate, and keeping them apart limits the damage from a bad write.

### Alternative 3: Recompute stars from stored best time after a rebalance
- **Pros**: stars always match the current star times.
- **Cons**: a player could lose stars they earned, and unlocks gated on those stars could re-lock.
- **Rejection Reason**: the GDD and decision sheet say stars never decrease. Instead the record is marked as from an older version.

### Alternative 4: Binary `store_var` with compression
- **Pros**: smaller and faster.
- **Cons**: opaque, so it can't be diffed for bug reports. `get_var(true)` can decode objects. The whole save is about 18 KB anyway (GDD F2).
- **Rejection Reason**: no size or speed problem to solve.

### Alternative 5: `SaveStore` as an autoload
- **Rejection Reason**: breaks the few-autoloads principle. `Main` lives for the whole app and injects the store, so tests can build it with `MemorySaveIO`.

## Consequences

### Positive
- Progress survives crashes, a kill during a save, downgrades and level rebalances.
- 4 profiles work from the MVP on, and cloud sync and the inventory systems can be added without a disruptive migration.
- Shared audio/display settings stop one family member's volume from surprising the next, while accessibility choices stay personal.
- Unit tests cover the whole save logic without touching the file system.
- The PC save folder is stable and ready for Steam Auto-Cloud.

### Negative
- Up to three files (main, `.bak`, `.tmp`) plus two `.corrupt-*` files per kind on disk. That is only kilobytes.
- Read-only mode after a downgrade means a player on an older build can't save new progress to that file until they update.
- Relaxed timing toggled mid-level waits for the next level. The pause menu has to explain this.
- Reserved inventory maps are opaque, so their validation is deferred to the owning systems.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| Android freezes the process before the background save finishes | Medium | High | Saves already happen on each result, so the background save is only a safety net; verification item 3 |
| `rename` is not atomic over an existing file on some Android storage | Low | High | The load order also accepts a valid `.tmp`; verification item 1 |
| `accessibility_should_reduce_animation()` returns `false` on Android regardless of the setting | Medium | Medium | Android plugin fallback (verification item 2); manual toggle always available |
| A migration bug drops records | Low | High | Frozen fixtures per schema; the migrated file is written with the pre-migration file kept as `.bak` |
| Clock skew makes `changed_at` wrong for the settings merge | Low | Low | Only settings use it, and a wrong pick loses only settings, never progress |

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| save-profile.md (TR-save-profile-001) | Schema: profiles, level records, unlocks, settings, stats | §1 files, §4 progress sections, §6 index, §7 settings. 4 slots in the MVP, last-used remembered, crash-safe create/rename/delete |
| save-profile.md (TR-save-profile-002) | Atomic temp-then-replace; backup fallback | §3 write sequence and load order, `.corrupt-*` retention |
| save-profile.md (TR-save-profile-003) | Schema versions migrated on load, never discarded | §2 envelope `schema`, `SaveMigrations`, unknown keys kept, read-only on newer schema |
| save-profile.md (TR-save-profile-004) | Save on result/settings/unlock only, never during play, within 1 s | §3 "When", single worker writer, play-phase gate, 500 ms settings debounce |
| save-profile.md (TR-save-profile-005, -006) | Cloud sync; conflict merge | §8 seam only (null backend). Steam/Google Play replace iCloud (deviation); `ProgressMerge` per F1 is deferred |
| save-profile.md (TR-save-profile-007) | Offline play and saving work | Local writes never wait on the backend |
| save-profile.md (TR-save-profile-008) | Guests save nothing | `active_profile() == null` → all writes no-op |
| scoring-stars.md (TR-scoring-stars-003), rule 4, AC 4 | Best result never lost; old stars kept and marked on version change | §4 `stars = max`, record keyed by id, `level_hash` comparison marks older-version records |
| campaign-structure.md (TR-campaign-structure-004) | Re-versioned level keeps its earned stars | §4 rebalance rule |
| level-data-definition.md (TR-level-data-definition-008) | Unique level ids | Record key relies on it |
| touch-controls.md (TR-touch-controls-007) | Scheme, mirror, sensitivities, haptics, scale, reduced motion persist | §7 settings sections |
| menus-level-select.md (TR-menus-level-select-006) | Settings screen persists controls/display/audio | §7 + `SettingsStore.set_value` save on change |
| mechanics-module.md (TR-mechanics-module-010) | Secrets, cosmetics, hidden-level unlocks persist | §4 `secrets`, `cosmetics`, `unlocks.levels` |
| arcade-mode.md (TR-arcade-mode-006) | Best score per biome skin | §4 `arcade` |
| tournament-flow.md (TR-tournament-flow-008) | Tournament stats saved | §4 `tournament` |
| accessibility-requirements.md ACC-40, ACC-50, ACC-02 | Reduced motion follows OS; relaxed timing keeps all 3 stars with scaled times; first-run picker persists | §7 `reduced_motion: "system"`, `relaxed_timing` applied at level start, `StarRater` scale with no badge; §4 `first_run` |
| ux/settings.md AC 1–4 | Per-bus volume, persistence across restart, P/L layouts, remap | §7 sections and apply contracts |

## Performance Implications
- **CPU**: a load at boot of about 18 KB of JSON plus SHA-256, under a 20 ms target on a flagship phone. Writes run on a worker thread, and the main thread only pays for `duplicate(true)` of the snapshot (under 1 ms).
- **Memory**: the whole save is held as Dictionaries, under 100 KB.
- **Load Time**: within the ≤10 s launch-to-play budget (TR-menus-level-select-007). The save is a small fraction of it.
- **Network**: none in the MVP.

## Migration Plan

No save code exists yet. This is schema 1. Follow-up edits to other files, not made by this ADR:
- `project.godot`: `application/config/use_custom_user_dir=true`, `application/config/custom_user_dir_name="WackyTowers"`.
- `architecture-modular-layout.md`: replace `profile_store.gd` with `src/game/save/` (`save_store.gd`, `save_io.gd`, `file_save_io.gd`, `progress_record.gd`, `save_migrations.gd`, `settings_store.gd`, `profile_store.gd`, `cloud/null_cloud_backend.gd`) and `tests/unit/save/`.
- `architecture.md` §3: add ADR-0013. `tr-registry.yaml`: point the TRs above at ADR-0013.
- `design/gdd/save-profile.md`: note the per-profile vs device-wide settings split and Steam/Google Play instead of iCloud.
- ADR-0010 boot flow and ADR-0016 screen list: add `&"profile_select"` after Title (hook in §6).
- ADR-0004 knob registry: add `relaxed_time_scale` (value set by the accessibility/scoring designers, ACC-50).

**Rollback plan**: the envelope and `SaveIO` stay. Any later format change is a new schema plus a migration step.

## Validation Criteria

- [ ] [U] `SaveStore` with `MemorySaveIO`: a write leaves a valid main file and the previous one as `.bak`. Corrupting main loads `.bak`. Corrupting both yields `recovered == &"fresh"`. A valid `.tmp` with main missing is recovered.
- [ ] [U] The write sequence interrupted after each of steps 1–4 (fault-injecting `SaveIO`) always reloads the last good or newer data.
- [ ] [U] A checksum mismatch counts as corrupt. Unknown keys round-trip unchanged. A file with `schema` higher than the build's loads read-only and is never written.
- [ ] [U] `SaveMigrations`: each frozen fixture migrates to the current schema with every record kept (Save & Profile AC 4).
- [ ] [U] `ProgressRecord.apply`: ★★ then ★ keeps ★★ (Scoring AC 4). A new `level_hash` with fewer stars keeps the old stars and hash. Equal stars with a faster time updates `best_ms`. `best_score` is the max on its own.
- [ ] [U] `SettingsStore`: out-of-range values clamp. Unknown values fall back to defaults. `reduced_motion: "system"` follows an injected OS query.
- [ ] [U] Guest (`active_profile() == null`): no `SaveIO.write_text` call happens.
- [ ] [U] `ProfileStore`: with `index.json` + `.bak` corrupt and 3 valid slot folders, boot deletes nothing and the rebuilt index lists those 3 `profile_id`s with `last_used = null`.
- [ ] [U] `ProfileStore`: 4 creates fill slots 0–3 and a 5th returns -1. Each slot keeps separate progress and settings (Save & Profile AC 5). A duplicate or empty rename is rejected. Delete interrupted after the index write leaves no profile, and boot removes the orphan folder. `needs_profile_select()` is true on a fresh install and after deleting the last-used slot, and false otherwise.
- [ ] [U] Changing a volume in profile 0 and switching to profile 1 keeps the volume (device-wide). Changing `relaxed_timing` in profile 0 does not affect profile 1.
- [ ] [I] headless: win meadow_01, restart the app, and the stars and settings are restored. A save request during `PLAYING` is deferred to the result.
- [ ] [M] Android (flagship): kill from the app switcher right after a result, relaunch, and the record is present. Toggling the OS "Remove animations" flips the effective reduced motion on resume (screenshot in `production/qa/evidence/`).
- [ ] [M] Windows: the save folder is `%APPDATA%/WackyTowers/save/`. Changing a volume slider writes `device.json` once after release, and no slot file is touched.

## Related
- ADR-0001 (determinism: relaxed timing applied at construction), ADR-0004 (`relaxed_time_scale` knob), ADR-0005 (`level_hash`, level ids), ADR-0010 (`app_backgrounded`, result fan-out, no saves in play), ADR-0012 (remap `to_dict/from_dict`), ADR-0015 (audio buses), ADR-0016 (settings/profile screens, older-version marker)
- `design/gdd/save-profile.md`, `design/gdd/scoring-stars.md`, `design/gdd/ux/settings.md`, `design/gdd/level-data-definition.md`, `design/accessibility-requirements.md` (ACC-02, ACC-40, ACC-50)

## Amendment (2026-10-10)

Status unchanged (Accepted). Cross-doc fixes from `production/session-state/conflicts-open.md`:
- **§6 data-loss fix**: an unreadable `index.json` (recovered fresh) skips orphan cleanup and rebuilds the index from valid slot files (`profile_id` from each file); nothing is deleted (`design/gdd/ux/loading-and-save-error.md`).
- **§5 shop currency = stars**: `wallet.stars` spendable balance per profile, credited with each level's star gain, reduced only by spending; earned per-level stars never decrease.
