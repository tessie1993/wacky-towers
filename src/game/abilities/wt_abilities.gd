class_name WtAbilities extends RefCounted
## Pure character ability controller. All effects pass through the simulation facade.
const FULL: int = 1000
var charge: int = 0
var last_message: String = ""
var _character: StringName = &"cloud"
var _mode: StringName = &"campaign"
var _active_until: int = 0
var _stitch_until: int = 0
var _peek_until: int = 0
var _bomb_armed: bool = false
var _spent: bool = false
var _time_ms: int = 0
var _prior_gravity: int = FULL
var _prior_lock: int = 500
var _prior_preview: int = 1
var _prior_hold: bool = false
var _catalog: GameCatalog
var _level: LevelData
var _tuning: Dictionary = {}
var _rng: RandomNumberGenerator
var _combo: int = 0
var _lock_cleared: bool = false
var _charge_rate: int = FULL
var _double_clear_charge: int = 0
var _item_charge: int = 0
var _obstacle_charge: int = 0
var _redraw_locks: int = 0
var _redraw_current_uid: int = 0
var _fit_dirty: bool = true

## Each skill has its own seeded stream, independent of shape bags and twists.
func setup(level: LevelData, catalog: GameCatalog, api: RuleApi, character: StringName = &"cloud", mode: StringName = &"campaign") -> void:
	_level = level
	_catalog = catalog
	_character = character
	_mode = mode
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/meta/abilities_runtime.json"))
	_tuning = parsed if parsed is Dictionary else {}
	_rng = Seeds.make_rng(level.seed if level.seed >= 0 else 20261010, ["skill", character])
	_prior_gravity = api.knob_int(&"fall.gravity_scale")
	_prior_lock = api.knob_int(&"fall.lock_delay_ms")
	charge = 0

## Configure validated equipped charge effects before the first tick.
func set_charge_perks(effects: Dictionary) -> void:
	_charge_rate = roundi(float(effects.get("charge_rate", 1.0)) * FULL)
	_double_clear_charge = roundi(float(effects.get("double_clear_charge", 0.0)) * FULL)
	_item_charge = roundi(float(effects.get("item_charge", 0.0)) * FULL)
	_obstacle_charge = roundi(float(effects.get("obstacle_charge",0.0)) * FULL)

## Snapshot includes all mutable deadlines and random state for LAN replay hashes.
func snapshot() -> Dictionary:
	return {"character": _character, "mode": _mode, "charge": charge, "active": _active_until,
		"stitch": _stitch_until, "peek": _peek_until, "bomb": _bomb_armed, "spent": _spent,
		"time": _time_ms, "gravity": _prior_gravity, "lock": _prior_lock, "preview": _prior_preview,
		"hold": _prior_hold, "rng": _rng.state if _rng != null else 0, "combo": _combo,
		"cleared": _lock_cleared, "charge_rate": _charge_rate, "double_charge": _double_clear_charge,
		"item_charge": _item_charge,"obstacle_charge":_obstacle_charge, "redraw_locks": _redraw_locks, "redraw_current_uid": _redraw_current_uid, "fit_dirty": _fit_dirty}

## Restore the full ability stream and move deadlines with the live simulation clock.
func restore(data: Dictionary, offset_ms: int = 0) -> void:
	var fields: Dictionary = {"character":"_character","mode":"_mode","charge":"charge","bomb":"_bomb_armed",
		"spent":"_spent","gravity":"_prior_gravity","lock":"_prior_lock","preview":"_prior_preview","hold":"_prior_hold",
		"combo":"_combo","cleared":"_lock_cleared","charge_rate":"_charge_rate","double_charge":"_double_clear_charge",
		"item_charge":"_item_charge","obstacle_charge":"_obstacle_charge","redraw_locks":"_redraw_locks","redraw_current_uid":"_redraw_current_uid","fit_dirty":"_fit_dirty"}
	for key: String in fields:
		if data.has(key): set(fields[key],data[key])
	_active_until = int(data.get("active",0))
	_stitch_until = int(data.get("stitch",0))
	_peek_until = int(data.get("peek",0))
	if _active_until > 0: _active_until += offset_ms
	if _stitch_until > 0: _stitch_until += offset_ms
	if _peek_until > 0: _peek_until += offset_ms
	_time_ms = int(data.get("time",0))+offset_ms
	if _rng != null: _rng.state = int(data.get("rng",_rng.state))

## Deadlines use simulation time, so pausing suspends active effects.
func step(api: RuleApi, now_ms: int) -> void:
	_time_ms = now_ms
	if _active_until > 0 and now_ms >= _active_until:
		api.clear_modifiers(&"slow")
		_active_until = 0
		api.emit(&"skill_ended", {"character": _character})
	if _stitch_until > 0 and now_ms >= _stitch_until:
		_stitch_until = 0
		api.emit(&"skill_ended", {"character": _character})
	if _peek_until > 0 and now_ms >= _peek_until:
		api.clear_modifiers(&"peek")
		_peek_until = 0
		api.emit(&"item_ended", {"id": "potion_preview_peek"})
	if _mode == &"tournament" and not _spent and now_ms >= int(_tuning.get("once_ready_ms", 3000)): charge = FULL
	if _redraw_locks > 0 and _fit_dirty and api.piece_cells().size() > 0 and ResourceLoader.exists("res://src/game/abilities/perfect_fit.gd"):
		_fit_dirty = false
		var helper: GDScript = load("res://src/game/abilities/perfect_fit.gd")
		var shape: ShapeDef = api.get_piece_shape() if api.has_method("get_piece_shape") else null
		if shape != null:
			var spots: Array = helper.suggestions(api, shape, 2)
			api.emit(&"fit_spots", {"spots": spots})

## Called by BoardSim exactly once per tick; clear events carry layer-equivalent counts.
func observe(events: Array[SimEvent]) -> void:
	for event: SimEvent in events:
		if event.kind in [SimEvents.PIECE_SPAWNED, SimEvents.CELLS_CHANGED]: _fit_dirty = true
		if event.kind == SimEvents.PIECE_LOCKED:
			if not _lock_cleared: _combo = 0
			_lock_cleared = false
			if _redraw_locks > 0 and (int(event.data.get("uid", 0)) == _redraw_current_uid or not bool(event.data.get("injected", false))):
				_redraw_locks -= 1
				_redraw_current_uid = 0
		elif event.kind == SimEvents.LAYERS_CLEARED:
			if not _lock_cleared: _combo += 1
			_lock_cleared = true
			var count: int = int(event.data.get("n_layers", event.data.get("layers", []).size()))
			if _can_charge():
				var gain: int = int(_tuning.get("charge_layer_milli", 125)) * count + int(_tuning.get("charge_combo_milli", 30)) * maxi(0, _combo - 1)
				charge = mini(FULL, charge + gain * _charge_rate / FULL + (_double_clear_charge if count >= 2 else 0))
		elif event.kind == SimEvents.TOP_OUT_WARNING: _combo = 0
		elif event.kind == &"item_used" and _can_charge():
			charge = mini(FULL, charge + _item_charge)
		elif event.kind in [&"rock_broken",&"obstacle_broken"] and _can_charge():
			charge = mini(FULL,charge+_obstacle_charge)

func _can_charge() -> bool:
	return _mode != &"tournament" and _active_until == 0 and _stitch_until == 0 and _redraw_locks == 0

func ready() -> bool:
	return charge >= FULL and _active_until == 0 and _stitch_until == 0 and _redraw_locks == 0 and not (_mode == &"tournament" and _spent)

## No-effect requests preserve charge and never emit an item debit event.
func command(cmd: SimCommand, api: RuleApi) -> void:
	if cmd.kind == SimEvents.CMD_USE_ITEM:
		_use_potion(cmd, api)
		return
	if cmd.kind != SimEvents.CMD_USE_SKILL or not ready(): return
	var used: bool = false
	match _character:
		&"cloud", &"cloud_wizard":
			used = _slow(api, int(_tuning.get("calm_duration_ms", 8000)), int(_tuning.get("calm_gravity_milli", 250)))
		&"lana":
			_stitch_until = _time_ms + int(_tuning.get("stitch_duration_ms", 10000))
			used = true
		&"boulder": used = _smash(api)
		&"glim": used = _redraw(api)
	if used:
		charge = 0
		_spent = true
		last_message = "Skill used"
		api.emit(&"skill_used", {"character": _character, "until": maxi(_active_until, _stitch_until)})
	else:
		last_message = "No effect — keep your charge"
		api.emit(&"skill_no_effect", {"character": _character})

## Stitch blocks lower-ranked rule writes; base clearing and mechanic rank4 remain legal.
func veto(action: StringName, rank: int) -> bool:
	return _stitch_until > _time_ms and rank <= 3 and action in [&"stack.shift", &"stack.remove", &"structure.change"]

func _slow(api: RuleApi, duration_ms: int, multiplier: int, lock_multiplier: int = 1500) -> bool:
	var modifiers: Array[Dictionary] = [
		{"knob": "fall.gravity_scale", "op": "mul", "value": float(multiplier) / FULL},
		{"knob": "fall.lock_delay_ms", "op": "mul", "value": float(lock_multiplier) / FULL}]
	if not api.modifiers_would_change(modifiers): return false
	if _active_until == 0:
		_prior_gravity = api.knob_int(&"fall.gravity_scale")
		_prior_lock = api.knob_int(&"fall.lock_delay_ms")
	_active_until = _time_ms + duration_ms
	api.request_modifiers(&"slow", modifiers)
	return true

func _smash(api: RuleApi) -> bool:
	var cells: Array[Vector3i] = api.piece_cells()
	if cells.is_empty(): return false
	var drop: int = api.cast(cells, api.down_vector())
	var sum: Vector3 = Vector3.ZERO
	for cell: Vector3i in cells: sum += Vector3(cell + api.down_vector() * drop)
	var mean: Vector3 = sum / cells.size()
	var center: Vector3i = cells[0] + api.down_vector() * drop
	for cell: Vector3i in cells:
		var ghost: Vector3i = cell + api.down_vector() * drop
		if Vector3(ghost).distance_squared_to(mean) < Vector3(center).distance_squared_to(mean): center = ghost
	var down: Vector3i = api.down_vector()
	var axis: int = 0 if down.x != 0 else 1 if down.y != 0 else 2
	var tangents: Array[int] = []
	for a: int in 3:
		if a != axis: tangents.append(a)
	var radius: int = int(_tuning.get("smash_size", 3)) / 2
	var top: int = -1
	var candidates: Array[Vector3i] = []
	var size: Vector3i = api.board_size()
	for x: int in size.x:
		for y: int in size.y:
			for z: int in size.z:
				var cell: Vector3i = Vector3i(x, y, z)
				if abs(cell[tangents[0]] - center[tangents[0]]) > radius or abs(cell[tangents[1]] - center[tangents[1]]) > radius: continue
				if api.kind_at(cell) != 0:
					top = maxi(top, api.layer_of(cell))
					candidates.append(cell)
	var hit: bool = false
	for cell: Vector3i in candidates:
		var record: Dictionary = api.record_at(cell)
		var status: Dictionary = record.get("status",{})
		if api.layer_of(cell) >= top - int(_tuning.get("smash_depth", 3)) + 1 and not bool(status.get("fixed",false)) and not bool(status.get("locked",false)):
			api.clear_cell(cell, BoardState.Cause.DAMAGE)
			if api.kind_at(cell) not in [api.kind_of(&"block"),api.kind_of(&"starter")] and int(status.get("hits_left",status.get("hp",1))) <= 1:
				api.emit(&"obstacle_broken",{"cell":cell})
			hit = true
	return hit

func _redraw(api: RuleApi) -> bool:
	if not api.has_method("replace_stream_preview"): return false
	var fixed: Variant = _level.pieces.get("fixed_list", [])
	if not fixed.is_empty() or not _level.pieces.get("kit",[]).is_empty(): return false
	var pool: PackedStringArray = api.shape_pool()
	var old: PackedStringArray = api.stream_preview_ids(int(_tuning.get("redraw_pieces", 3)))
	if pool.size() <= 1:
		var shape: ShapeDef = api.get_piece_shape()
		if WtPerfectFit.suggestions(api, shape, 2).is_empty(): return false
		_redraw_locks = old.size() + 1
		_redraw_current_uid = api.get_piece_uid()
		_fit_dirty = true
		return true
	var replacements: PackedStringArray = []
	for i: int in old.size():
		var choices: Array[String] = []
		for id: String in pool:
			if i >= old.size() or id != str(old[i]): choices.append(id)
		if choices.is_empty(): return false
		replacements.append(choices[_rng.randi_range(0, choices.size() - 1)])
	if replacements.is_empty(): return false
	api.replace_stream_preview(replacements)
	_redraw_locks = replacements.size() + 1
	_redraw_current_uid = api.get_piece_uid()
	_fit_dirty = true
	api.emit(&"redraw_preview", {"shapes": replacements})
	return true

func _use_potion(cmd: SimCommand, api: RuleApi) -> void:
	if cmd.args.is_empty() or _mode == &"tournament": return
	var id: String = String(cmd.args[0])
	var used: bool = false
	match id:
		"potion_helper_drop":
			var helpers: PackedStringArray = []
			var choices: PackedStringArray = ["mono", "duo", "tri_straight", "tri_corner"]
			for i: int in 3: helpers.append(choices[_rng.randi_range(0, choices.size() - 1)])
			api.inject_front(helpers)
			used = true
		"potion_slow_time":
			if _active_until == 0:
				used = _slow(api, 10000, 500, 1000)
		"potion_preview_peek":
			if _peek_until == 0:
				_prior_preview = api.knob_int(&"spawn.preview_count")
				_prior_hold = api.knob_flag(&"spawn.hold_enabled")
				var modifiers: Array[Dictionary] = [{"knob": "spawn.preview_count", "op": "add", "value": 2},
					{"knob": "spawn.hold_enabled", "op": "set", "value": true}]
				if api.modifiers_would_change(modifiers):
					api.request_modifiers(&"peek", modifiers)
					_peek_until = _time_ms + 20000
					used = true
		"potion_bomb":
			if not _bomb_armed: _bomb_armed = true
			api.emit(&"item_armed", {"id": id})
			return
	if used:
		api.emit(&"item_used", {"id": id})
	else: api.emit(&"item_no_effect", {"id": id})

## Bomb resolves after own cells are locked, before layer detection; damage grants no clear credit.
func on_lock(api: RuleApi, cells: Array[Vector3i]) -> void:
	if not _bomb_armed or cells.is_empty(): return
	_bomb_armed = false
	var sum: Vector3 = Vector3.ZERO
	for cell: Vector3i in cells: sum += Vector3(cell)
	var mean: Vector3 = sum / cells.size()
	var ordered: Array[Vector3i] = cells.duplicate()
	ordered.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
		var da: float = Vector3(a).distance_squared_to(mean)
		var db: float = Vector3(b).distance_squared_to(mean)
		return da < db or (is_equal_approx(da, db) and (a.y < b.y or (a.y == b.y and (a.x < b.x or (a.x == b.x and a.z < b.z))))))
	var center: Vector3i = ordered[0]
	var hit: bool = false
	for x: int in range(center.x - 1, center.x + 2):
		for y: int in range(center.y - 1, center.y + 2):
			for z: int in range(center.z - 1, center.z + 2):
				var cell: Vector3i = Vector3i(x, y, z)
				if api.kind_at(cell) in [api.kind_of(&"block"), api.kind_of(&"starter")]:
					api.clear_cell(cell, BoardState.Cause.DAMAGE)
					hit = true
	api.emit(&"item_used" if hit else &"item_no_effect", {"id": "potion_bomb", "center": center})
