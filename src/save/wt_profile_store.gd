class_name WtProfileStore extends RefCounted
## Four isolated local profiles; earned stars, inventory and wallet land in one atomic progress write.

signal profile_changed(slot: int)
signal changed
const MAX_SLOTS := 4
const INDEX_PATH := "user://save/index.json"
var last_error: String = ""
var _io: SaveIO
var _slots: Array = [null, null, null, null]
var _active: int = -1
var _progress: Dictionary = {}
var _settings: Dictionary = {}
var _device: Dictionary = {}
var _defaults: Dictionary = {}
var _economy: Dictionary = {}
var _shop: Array = []
var _playing: bool = false
var _undo: Dictionary = {}

func _init(io: SaveIO = null) -> void:
	_io = io if io != null else FileSaveIO.new()
	_defaults = _resource_json("res://assets/data/meta/settings.json")
	_economy = _resource_json("res://assets/data/meta/economy.json")
	_shop = _resource_json("res://assets/data/shop/catalog.json").get("items", [])
	_device = _defaults.get("device", {}).duplicate(true)
	_device.merge(_read("user://save/device.json"), true)
	var index: Dictionary = _read(INDEX_PATH)
	var entries: Variant = index.get("slots", [])
	if entries is Array:
		for i: int in mini(MAX_SLOTS, entries.size()):
			if entries[i] is Dictionary:
				_slots[i] = entries[i]
	# Recover lost index from independently valid progress files without deleting any saves.
	if index.is_empty():
		for i: int in MAX_SLOTS:
			var recovered: Dictionary = _read(_path(i, "progress"))
			if recovered.has("profile_id"):
				_slots[i] = recovered.get("profile", {"id": recovered.profile_id, "name": "Builder %d" % (i + 1), "color": "sky", "badge": "cloud"})
		if _slots.count(null) < MAX_SLOTS:
			_save_index()
	var last: Variant = index.get("last_used", -1)
	if last != null and _valid(int(last)):
		select(int(last))

## Lists four slots, including each saved earned-star total and wallet balance.
func list_profiles() -> Array:
	var out: Array = []
	for i: int in MAX_SLOTS:
		if _slots[i] == null:
			out.append(null)
			continue
		var row: Dictionary = _slots[i].duplicate(true)
		var saved: Dictionary = _progress if i == _active else _read(_path(i, "progress"))
		row["slot"] = i
		row["stars"] = _total_stars(saved.get("levels", {}))
		row["wallet"] = int(saved.get("wallet", {}).get("star_balance", 0))
		out.append(row)
	return out

## Alias for profile-select snapshots.
func slots() -> Array:
	return list_profiles()

## Creates the lowest free slot; invalid or duplicate names return -1.
func create(name: String, color: String = "sky", badge: String = "cloud") -> int:
	var clean: String = name.strip_edges().left(12)
	if clean.is_empty():
		return -1
	for entry: Variant in _slots:
		if entry is Dictionary and str(entry.name).nocasecmp_to(clean) == 0:
			return -1
	var slot: int = _slots.find(null)
	if slot < 0:
		return -1
	var entry: Dictionary = {"id": Crypto.new().generate_random_bytes(16).hex_encode(), "name": clean, "color": color, "badge": badge}
	var saved: Dictionary = _fresh(entry)
	if _write(_path(slot, "progress"), saved) != OK:
		return -1
	if _write(_path(slot, "settings"), _defaults.get("profile", {})) != OK:
		return -1
	_slots[slot] = entry
	var previous: int = _active
	_active = slot
	if _save_index() != OK:
		_slots[slot] = null
		_active = previous
		return -1
	select(slot)
	return slot

## Renames an existing profile; names stay unique ignoring case.
func rename(slot: int, name: String) -> Error:
	if not _valid(slot) or _playing:
		return ERR_INVALID_PARAMETER
	var clean: String = name.strip_edges().left(12)
	if clean.is_empty():
		return ERR_INVALID_PARAMETER
	for i: int in MAX_SLOTS:
		if i != slot and _slots[i] != null and str(_slots[i].name).nocasecmp_to(clean) == 0:
			return ERR_ALREADY_EXISTS
	var previous: String = _slots[slot].name
	_slots[slot]["name"] = clean
	var error: Error = _save_index()
	if error != OK:
		_slots[slot]["name"] = previous
	return error

## Deletes the selected slot, index first; cannot run while a level is active.
func delete(slot: int) -> Error:
	if _playing: return ERR_BUSY
	if not _valid(slot): return ERR_DOES_NOT_EXIST
	var previous: Variant = _slots[slot]
	var previous_active: int = _active
	_slots[slot] = null
	if _active == slot: _active = -1
	var error: Error = _save_index()
	if error != OK:
		_slots[slot] = previous
		_active = previous_active
		return error
	_io.delete("user://save/slot_%d" % slot)
	if previous_active == slot:
		_progress.clear()
		_settings.clear()
		profile_changed.emit(-1)
	return OK

## Selects a profile and loads its independent progress/accessibility preferences.
func select(slot: int) -> bool:
	if not _valid(slot) or _playing:
		return false
	_active = slot
	_progress = _fresh(_slots[slot])
	_progress.merge(_read(_path(slot, "progress")), true)
	_settings = _defaults.get("profile", {}).duplicate(true)
	_settings.merge(_read(_path(slot, "settings")), true)
	var wallet: Dictionary = _progress.wallet
	wallet["star_balance"] = clampi(int(wallet.get("earned_total", 0)) - int(wallet.get("spent_total", 0)), 0, int(_economy.get("jar_cap", 9999)))
	_save_index()
	profile_changed.emit(slot)
	changed.emit()
	return true

## Staging-compatible selection alias.
func switch_to(slot: int) -> void:
	select(slot)

## Current index entry plus slot; null means guest and suppresses every save.
func active_profile() -> Variant:
	if not _valid(_active):
		return null
	var entry: Dictionary = _slots[_active].duplicate(true)
	entry["slot"] = _active
	return entry

## Whether the application must show its profile picker.
func needs_profile_select() -> bool:
	return not _valid(_active)

## Returns a safe progress snapshot.
func progress() -> Dictionary:
	return _progress.duplicate(true)

## Prevents menu purchases/profile changes during a live level. Result recording exits this gate.
func set_playing(playing: bool) -> void:
	_playing = playing

## Best stars never decrease; independent minimum time and maximum score survive rebalances.
func record_result(id: String, stars: int, ms: int, score: int, hash: String = "") -> Dictionary:
	_playing = false
	if not _valid(_active) or stars <= 0:
		return {"ok": false, "star_gain": 0, "award": 0, "first_clear": false}
	var before: Dictionary = _progress.duplicate(true)
	var levels: Dictionary = _progress.levels
	var old: Dictionary = levels.get(id, {})
	var best: int = int(old.get("stars", 0))
	var gain: int = maxi(0, clampi(stars, 0, 3) - best)
	var replay: int = 0
	var paid: Dictionary = _progress.wallet.replays_paid
	if gain == 0 and stars >= int(_economy.get("replay_min_stars", 2)) and int(paid.get(id, 0)) < int(_economy.get("replay_cap", 1)):
		replay = int(_economy.get("replay_pay", 1))
		paid[id] = int(paid.get(id, 0)) + 1
	var record: Dictionary = old.duplicate(true)
	record["stars"] = maxi(best, clampi(stars, 0, 3))
	record["best_ms"] = ms if int(old.get("best_ms", 0)) <= 0 else mini(ms, int(old.best_ms))
	record["best_score"] = maxi(score, int(old.get("best_score", 0)))
	record["attempts"] = int(old.get("attempts", 0)) + 1
	if gain > 0 or not record.has("level_hash"):
		record["level_hash"] = hash
	record["current_hash"] = hash
	levels[id] = record
	var award: int = _credit(gain + replay)
	_update_characters()
	if _save_progress() != OK:
		_progress = before
		return {"ok": false, "star_gain": 0, "award": 0, "error": last_error}
	changed.emit()
	return {"ok": true, "star_gain": gain, "award": award, "replay_award": replay, "first_clear": best == 0, "stars": record.stars, "wallet": wallet_balance()}

## Arcade saves score per skin and grants no jar currency.
func record_arcade(biome: String, score: int, layers: int, ms: int) -> void:
	_playing = false
	if not _valid(_active):
		return
	var old: Dictionary = _progress.arcade.get(biome, {})
	_progress.arcade[biome] = {"best_score": maxi(score, int(old.get("best_score", 0))), "best_layers": maxi(layers, int(old.get("best_layers", 0))), "longest_ms": maxi(ms, int(old.get("longest_ms", 0)))}
	_save_progress()

## Pays a normal tournament result using supplied authoritative award; guests receive nothing.
func record_tournament(won: bool, award: int) -> void:
	_playing = false
	if not _valid(_active):
		return
	_progress.tournament["played"] = int(_progress.tournament.get("played", 0)) + 1
	_progress.tournament["won"] = int(_progress.tournament.get("won", 0)) + (1 if won else 0)
	_credit(maxi(0, award))
	_save_progress()

## Current spendable stars; does not count toward campaign gates.
func wallet_balance() -> int:
	return int(_progress.get("wallet", {}).get("star_balance", 0))

## Earned stars in the main ten levels of a biome.
func biome_stars(biome: String) -> int:
	return WtProgression.biome_stars(_progress.get("levels", {}), biome)

## Whether the preceding biome's finale and 15-star gate are satisfied.
func biome_open(biome: String) -> bool:
	return WtProgression.biome_open(_progress.get("levels", {}), biome, _economy.get("biomes", []), int(_economy.get("biome_star_gate", 15)))

## Whether a catalog level has unlocked.
func level_open(entry: Dictionary) -> bool:
	return WtProgression.level_open(_progress.get("levels", {}), entry, _economy.get("biomes", []), int(_economy.get("biome_star_gate", 15)), int(_economy.get("bonus_star_gate", 20)))

## Character ids available in context; all four start unlocked for party play.
func characters(mode: String = "campaign") -> Array:
	if mode in ["tournament", "versus"]:
		return ["c1", "c2", "c3", "c4"]
	return _progress.get("characters", ["c1"]).duplicate()

## Shop becomes available after Meadow 03 or one tournament.
func shop_open() -> bool:
	return int(_progress.get("levels", {}).get(str(_economy.get("shop_unlock_level", "meadow_03")), {}).get("stars", 0)) > 0 or int(_progress.get("tournament", {}).get("played", 0)) > 0

## Shop rows with fixed price, ownership, stock and unlock state.
func shop_snapshot() -> Array:
	var out: Array = []
	for source: Dictionary in _shop:
		var row: Dictionary = source.duplicate(true)
		var kind: String = str(row.kind)
		row["unlocked"] = shop_open() and _requires(row.get("requires", {}))
		row["owned"] = _owned(str(row.id), kind)
		row["count"] = int(_progress.get("inventory", {}).get("potions", {}).get(row.id, 0))
		row["affordable"] = wallet_balance() >= int(row.price.amount)
		out.append(row)
	return out

## Purchases wallet and grant in one progress write; reject unavailable/duplicate/capped items.
func purchase(item_id: String) -> Dictionary:
	if _playing or not _valid(_active):
		return {"ok": false, "error": "busy_or_guest"}
	for item: Dictionary in shop_snapshot():
		if str(item.id) != item_id:
			continue
		if not item.unlocked:
			return {"ok": false, "error": "locked"}
		if item.owned and str(item.kind) != "potion":
			return {"ok": false, "error": "owned"}
		if int(item.count) >= int(_economy.get("potion_stack_max", 5)):
			return {"ok": false, "error": "stock_full"}
		var price: int = int(item.price.amount)
		if wallet_balance() < price:
			return {"ok": false, "error": "not_enough_stars"}
		var before: Dictionary = _progress.duplicate(true)
		_progress.wallet["star_balance"] -= price
		_progress.wallet["spent_total"] += price
		match str(item.kind):
			"potion": _progress.inventory.potions[item_id] = int(item.count) + 1
			"perk": _progress.inventory.perks[item_id] = {"owned": true, "equipped": false}
			"cosmetic": _progress.cosmetics[item_id] = {"owned": true}
		if _save_progress() != OK:
			_progress = before
			return {"ok": false, "error": "write_failed"}
		_undo = {"before": before, "id": item_id}
		changed.emit()
		return {"ok": true, "wallet": wallet_balance()}
	return {"ok": false, "error": "unknown_item"}

## Undoes the latest unused purchase while its shop window remains open.
func undo_purchase() -> bool:
	if _undo.is_empty() or _playing:
		return false
	_progress = _undo.before
	_undo.clear()
	return _save_progress() == OK

## Ends the undo window when leaving the shop.
func close_shop() -> void:
	_undo.clear()

## Debits a used potion only at result time; a no-effect/unused potion must not call this method.
func consume_potion(id: String) -> bool:
	var stock: Dictionary = _progress.get("inventory", {}).get("potions", {})
	if int(stock.get(id, 0)) <= 0:
		return false
	stock[id] = int(stock[id]) - 1
	_undo.clear()
	return true

## Persists actual potion uses at results or an abandoned session; never writes during play.
func commit_inventory() -> bool:
	if not _valid(_active) or _playing:
		return false
	return _save_progress() == OK

## Validates owned per-character edge loadout with the conservative 15% cap.
func equip_perks(character: String, ids: Array, mode: String = "campaign") -> bool:
	if _playing or ids.size() > int(_economy.get("edge_slots", 2)):
		return false
	var edge: float = 0.0
	var seen: Dictionary = {}
	for id: Variant in ids:
		if seen.has(str(id)):
			return false
		seen[str(id)] = true
		var found: bool = false
		for item: Dictionary in _shop:
			if str(item.id) == str(id) and str(item.get("character", "")) == character and _owned(str(id), "perk"):
				edge += float(item.get("edge", 0))
				found = true
		if not found:
			return false
	if edge > float(_economy.get("edge_cap", 0.15)) or (mode == "versus" and not ids.is_empty()):
		return false
	var previous: Dictionary = _settings.duplicate(true)
	_settings["equipped_perks"] = ids.duplicate()
	_settings["character"] = character
	_undo.clear()
	if _write(_path(_active, "settings"), _settings) != OK:
		_settings = previous
		return false
	return true

## Combined device and personal preferences.
func settings() -> Dictionary:
	var out: Dictionary = _device.duplicate(true)
	out.merge(_settings, true)
	return out

## Returns a preference or supplied default.
func get_setting(key: String, fallback: Variant = null) -> Variant:
	return settings().get(key, fallback)

## Clamps supported preferences and writes only its own settings file.
func set_setting(key: String, value: Variant) -> bool:
	if _playing:
		return false
	if key.ends_with("_volume"):
		value = clampf(float(value), 0.0, 1.0)
	elif key == "button_scale":
		value = clampf(float(value), 0.75, 2.0)
	elif key == "reduced_motion" and value not in ["system", "on", "off", true, false]:
		return false
	elif key in ["relaxed_timing", "ghost", "haptics", "fullscreen"] and not value is bool:
		return false
	var device: bool = _defaults.get("device", {}).has(key)
	if not device and not _defaults.get("profile", {}).has(key):
		return false
	if not device and not _valid(_active):
		return false
	if device:
		_device[key] = value
	else:
		_settings[key] = value
	var error: Error = _write("user://save/device.json" if device else _path(_active, "settings"), _device if device else _settings)
	changed.emit()
	return error == OK

func _valid(slot: int) -> bool:
	return slot >= 0 and slot < MAX_SLOTS and _slots[slot] != null

func _path(slot: int, kind: String) -> String:
	return "user://save/slot_%d/%s.json" % [slot, kind]

func _resource_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else {}
	return parsed if parsed is Dictionary else {}

func _read(path: String) -> Dictionary:
	var text: String = _io.read_text(path)
	if text.is_empty():
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK:
		return {}
	return parser.data if parser.data is Dictionary else {}

func _write(path: String, data: Dictionary) -> Error:
	var error: Error = _io.write_text(path, JSON.stringify(data, "", true))
	last_error = "" if error == OK else "save_failed_%d" % error
	return error

func _save_index() -> Error:
	return _write(INDEX_PATH, {"slots": _slots, "last_used": _active})

func _save_progress() -> Error:
	if not _valid(_active) or _playing:
		return ERR_BUSY
	return _write(_path(_active, "progress"), _progress)

func _fresh(profile: Dictionary) -> Dictionary:
	return {"schema": 1, "profile_id": profile.id, "profile": profile.duplicate(true), "levels": {}, "wallet": {"star_balance": 0, "earned_total": 0, "spent_total": 0, "replays_paid": {}}, "inventory": {"perks": {}, "potions": {}}, "cosmetics": {}, "characters": ["c1"], "arcade": {}, "tournament": {"played": 0, "won": 0}}

func _total_stars(records: Dictionary) -> int:
	var total: int = 0
	for record: Dictionary in records.values():
		total += int(record.get("stars", 0))
	return total

func _credit(amount: int) -> int:
	var kept: int = mini(amount, int(_economy.get("jar_cap", 9999)) - wallet_balance())
	_progress.wallet["star_balance"] += kept
	_progress.wallet["earned_total"] += kept
	return kept

func _update_characters() -> void:
	for pair: Array in [["ice_10", "c2"], ["lava_10", "c3"], ["cave_10", "c4"]]:
		if int(_progress.levels.get(pair[0], {}).get("stars", 0)) > 0 and not _progress.characters.has(pair[1]):
			_progress.characters.append(pair[1])

func _owned(id: String, kind: String) -> bool:
	if kind == "perk":
		return bool(_progress.get("inventory", {}).get("perks", {}).get(id, {}).get("owned", false))
	if kind == "cosmetic":
		return bool(_progress.get("cosmetics", {}).get(id, {}).get("owned", false))
	return false

func _requires(requirement: Variant) -> bool:
	if requirement is Array:
		for part: Variant in requirement:
			if not _requires(part):
				return false
		return true
	if not requirement is Dictionary:
		return false
	for key: String in requirement:
		match key:
			"any_of":
				var any: bool = false
				for part: Variant in requirement[key]:
					any = any or _requires(part)
				if not any: return false
			"biome_open":
				var biome: String = str(requirement[key])
				if requirement[key] is float or requirement[key] is int:
					biome = str(_economy.biomes[int(requirement[key]) - 1])
				if not biome_open(biome): return false
			"tournaments_played":
				if int(_progress.get("tournament", {}).get("played", 0)) < int(requirement[key]): return false
			"character":
				if not characters().has(str(requirement[key])): return false
			_: return false
	return true
