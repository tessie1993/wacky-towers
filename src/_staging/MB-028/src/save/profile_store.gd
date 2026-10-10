class_name ProfileStore extends RefCounted
## Four profile slots over a [SaveIO] (ADR-0013 §6). The index file is the single source of truth.
## Example: var ps := ProfileStore.new(MemorySaveIO.new()); var slot := ps.create("Mia").
## ponytail: atomic temp+rename write, .bak and index rebuild belong to the Phase 5 disk SaveIO; an unreadable index loads as empty.
## All storage goes through [SaveIO]; this class never touches FileAccess.

## Slots in the index (GDD knob max_profiles).
const MAX_SLOTS: int = 4
## Name length limits (GDD knob profile_name_length).
const NAME_MIN := 1
const NAME_MAX := 12
const INDEX_PATH := "user://save/index.json"
const SLOT_DIR := "user://save/slot_%d"
const FILE_PROGRESS := "progress.json"
const FILE_SETTINGS := "settings.json"
## Colour and badge ids from profile-select.md.
const COLORS: PackedStringArray = ["lemon", "lime", "mint", "sky", "lavender", "peach"]
const BADGES: PackedStringArray = ["acorn", "mushroom", "snail", "bee", "daisy", "leaf", "cloud", "wizard_hat"]

## Emitted after the active profile changes; [param slot] is -1 when there is none.
signal profile_changed(slot: int)

var _io: SaveIO
# Each entry: {id, name, created_at, color, badge} or null.
var _slots: Array = [null, null, null, null]
var _last_used: int = -1


func _init(io: SaveIO) -> void:
	_io = io
	_load_index()


## Four entries: {name, color, badge, stars, furthest} or null. Stars/furthest come from the slot's progress file (0 if absent).
func slots() -> Array:
	var out: Array = []
	for i in MAX_SLOTS:
		var e: Variant = _slots[i]
		if e == null:
			out.append(null)
			continue
		var pd: Dictionary = _read_json(_slot_file(i, FILE_PROGRESS))
		out.append({"name": e["name"], "color": e["color"], "badge": e["badge"],
			"stars": int(pd.get("stars", 0)), "furthest": int(pd.get("furthest", 0))})
	return out


## The active profile's index entry (plus "slot"), or null for none/guest.
func active_profile() -> Variant:
	if _last_used < 0 or _slots[_last_used] == null:
		return null
	var d: Dictionary = _slots[_last_used].duplicate()
	d["slot"] = _last_used
	return d


## True when AppFlow must show profile select (no active profile).
func needs_profile_select() -> bool:
	return _last_used < 0 or _slots[_last_used] == null


## Creates a profile in the lowest free slot and makes it active. Returns the slot, or -1 if full or the name is invalid/duplicate.
func create(name: String, color: String = "", badge: String = "") -> int:
	var clean: String = clean_name(name)
	if clean.length() < NAME_MIN or _name_taken(clean, -1):
		return -1
	var slot: int = _slots.find(null)
	if slot < 0:
		return -1
	var entry := {
		"id": Crypto.new().generate_random_bytes(16).hex_encode(),
		"name": clean,
		"created_at": int(Time.get_unix_time_from_system()),
		"color": color if color in COLORS else _next_unused("color", COLORS, slot),
		"badge": badge if badge in BADGES else _next_unused("badge", BADGES, slot),
	}
	# Folder files first, then the index (ADR-0013 §6 write order).
	if _io.write_text(_slot_file(slot, FILE_PROGRESS), JSON.stringify({"profile_id": entry["id"]})) != OK:
		return -1
	if _io.write_text(_slot_file(slot, FILE_SETTINGS), "{}") != OK:
		return -1
	var prev_last: int = _last_used
	_slots[slot] = entry
	_last_used = slot
	if _save_index() != OK:
		_slots[slot] = null
		_last_used = prev_last
		return -1
	profile_changed.emit(slot)
	return slot


## Renames a profile. ERR_ALREADY_EXISTS on a case-insensitive duplicate, ERR_INVALID_PARAMETER on a bad slot or name.
func rename(slot: int, name: String) -> Error:
	if not _valid(slot):
		return ERR_INVALID_PARAMETER
	var clean: String = clean_name(name)
	if clean.length() < NAME_MIN:
		return ERR_INVALID_PARAMETER
	if _name_taken(clean, slot):
		return ERR_ALREADY_EXISTS
	var old_name: String = _slots[slot]["name"]
	_slots[slot]["name"] = clean
	var err: Error = _save_index()
	if err != OK:
		_slots[slot]["name"] = old_name
	return err


## Deletes a profile: index first, then its folder. Deleting the active one clears it (profile_changed(-1)).
func delete(slot: int) -> Error:
	if not _valid(slot):
		return ERR_DOES_NOT_EXIST
	var old_entry: Variant = _slots[slot]
	var old_last: int = _last_used
	_slots[slot] = null
	var was_active: bool = slot == _last_used
	if was_active:
		_last_used = -1
	var err: Error = _save_index()
	if err != OK:
		_slots[slot] = old_entry
		_last_used = old_last
		return err
	_io.delete(SLOT_DIR % slot)
	if was_active:
		profile_changed.emit(-1)
	return OK


## Makes [param slot] the active profile (ignored if empty).
func switch_to(slot: int) -> void:
	if not _valid(slot):
		return
	var prev_last: int = _last_used
	_last_used = slot
	if _save_index() != OK:
		_last_used = prev_last
		return
	profile_changed.emit(slot)


## Trims, strips control chars/emoji/symbols; keeps letters, digits, space, hyphen and apostrophe; max 12 chars.
## ponytail: letters = ASCII, Latin-1/Extended, and BMP scripts U+0370..U+1FFF; extend if a locale needs more.
static func clean_name(raw: String) -> String:
	var out: String = ""
	for i in raw.length():
		var c: int = raw.unicode_at(i)
		var ok: bool = (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c <= 122) \
			or c == 32 or c == 45 or c == 39 \
			or (c >= 0xC0 and c <= 0x24F and c != 0xD7 and c != 0xF7) \
			or (c >= 0x370 and c <= 0x1FFF)
		if ok:
			out += char(c)
	return out.strip_edges().left(NAME_MAX).strip_edges()


func _valid(slot: int) -> bool:
	return slot >= 0 and slot < MAX_SLOTS and _slots[slot] != null


func _name_taken(clean: String, except_slot: int) -> bool:
	for i in MAX_SLOTS:
		if i != except_slot and _slots[i] != null and String(_slots[i]["name"]).nocasecmp_to(clean) == 0:
			return true
	return false


func _next_unused(field: String, options: PackedStringArray, slot: int) -> String:
	for o in options:
		var used := false
		for e in _slots:
			if e != null and e[field] == o:
				used = true
				break
		if not used:
			return o
	return options[slot % options.size()]


func _slot_file(slot: int, file: String) -> String:
	return (SLOT_DIR % slot).path_join(file)


func _save_index() -> Error:
	return _io.write_text(INDEX_PATH, JSON.stringify({"last_used": null if _last_used < 0 else _last_used, "slots": _slots}))


## Parsed JSON object at [param path], or {} if missing/invalid. Numbers come back as float; callers int() them.
func _read_json(path: String) -> Dictionary:
	var text: String = _io.read_text(path)
	if text.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


func _load_index() -> void:
	var data: Dictionary = _read_json(INDEX_PATH)
	if data.is_empty():
		return
	var raw: Array = data.get("slots", []) if data.get("slots") is Array else []
	for i in mini(raw.size(), MAX_SLOTS):
		if raw[i] is Dictionary:
			_slots[i] = raw[i]
	var lu: Variant = data.get("last_used")
	_last_used = int(lu) if (lu is float or lu is int) and _valid(int(lu)) else -1
