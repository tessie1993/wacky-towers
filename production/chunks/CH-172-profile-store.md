# CH-172 ProfileStore (4 slots, in memory) + MemorySaveIO

**MB task:** MB-029 · **Model:** Sonnet · **Mode:** direct (no tests; the user rule 2026-10-10 is no tests, game code only)
**Depends:** none; ADR-0013 is the spec
**Files:** new `src/save/profile_store.gd`, `src/save/save_io.gd` (abstract), `src/save/memory_save_io.gd`

## API
```gdscript
class_name SaveIO extends RefCounted
func read_text(path: String) -> String       ## "" if missing
func write_text(path: String, text: String) -> Error
func delete(path: String) -> Error
func exists(path: String) -> bool
class_name MemorySaveIO extends SaveIO       ## Dictionary-backed
class_name ProfileStore extends RefCounted   ## ADR-0013 §6
const MAX_SLOTS := 4
signal profile_changed(slot: int)
func _init(io: SaveIO) -> void
func slots() -> Array                        ## 4 entries: {name, color, badge, stars, furthest} or null
func active_profile() -> Variant             ## Dictionary or null
func needs_profile_select() -> bool
func create(name: String, color: String = "", badge: String = "") -> int   ## lowest free slot, -1 if full/invalid name
func rename(slot: int, name: String) -> Error                               ## ERR_ALREADY_EXISTS on duplicate (case-insensitive)
func delete(slot: int) -> Error
func switch_to(slot: int) -> void
static func clean_name(raw: String) -> String   ## trim, strip control chars/emoji, 1..12 chars, letters digits space - '
```

## Behaviour
- Index in `user://save/index.json` (via `io`), slot folders `profile_<n>/`; index is the single source of truth; delete writes the index first, then removes files. Colours and badges are ids from profile-select.md (6 colours, 8 badges); defaults = next unused colour/badge.
- Atomic writes, `.bak`, `SaveIO` real disk class come in Phase 5; the in-memory IO is enough for the screens now. Use plain JSON, never `Resource`.
- Name rules: 1..12 chars, unique case-insensitive across slots.

## How the integrator sees it working
Editor script eval with MemorySaveIO: 4 `create` calls return 0..3, a 5th returns -1; duplicate name rename returns ERR_ALREADY_EXISTS; `delete(1)` frees slot 1 and the next `create` returns 1; `needs_profile_select()` true after deleting the last-used. Print and read via `logs_read`.

**Out of scope: anything not listed above.**
Conventions: `production/chunks/README.md` (static typing, `##` doc on every public method, named consts with source, no global RNG). Ignore its "tests first" lines.
