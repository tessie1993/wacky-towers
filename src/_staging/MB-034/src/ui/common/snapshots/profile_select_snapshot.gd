class_name ProfileSelectSnapshot extends RefCounted
## Profile list state (ADR-0016 §7). Built from [method ProfileStore.slots].

## 4 entries: Dictionary {name, color, badge, stars, furthest} or null.
var slots: Array = [null, null, null, null]
## Active slot, -1 = none.
var active_slot: int = -1
## True while the Edit toggle is on (rename and bin chips visible).
var edit_mode: bool = false
## True when the save is newer than this build: create, rename and delete are disabled.
var read_only: bool = false
