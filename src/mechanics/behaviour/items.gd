class_name ItemsRule extends RuleBehaviour
## Item cubes are collected only by a genuine clear. State and randomness belong to this rule.
const PLUGIN_ID := &"items"
const TABLE: Array[Dictionary] = [
	{"id": "slow_time", "weight": 10.0, "bias": 0.0, "debuff": false},
	{"id": "bomb", "weight": 8.0, "bias": 0.5, "debuff": false},
	{"id": "helper_drop", "weight": 10.0, "bias": 0.0, "debuff": false},
	{"id": "preview_peek", "weight": 10.0, "bias": -0.5, "debuff": false},
	{"id": "junk_rain", "weight": 8.0, "bias": 1.0, "debuff": true},
	{"id": "fog", "weight": 6.0, "bias": 0.5, "debuff": true},
	{"id": "speed_up", "weight": 8.0, "bias": 1.0, "debuff": true},
	{"id": "spin_lock", "weight": 6.0, "bias": 0.5, "debuff": true},
]
var _enabled: bool = true
var _slots: Array[Dictionary] = []
var _tag_uid: int = -1
var _tag_index: int = -1
var _tag_shape: StringName = &""
var _tag_token: String = ""
var _collected: Dictionary = {}
var _effects: Dictionary = {}
var _last_tick: int = 0
var _effect_clock: int = 0
var _locked_at: Dictionary = {}
var _fog_started: int = 0
var _fog_key: String = ""
var _bomb_uid: int = -1
var _bomb_next: bool = false
var _use_counter: int = 0

func subscribed_hooks() -> Array[StringName]:
	return [&"on_level_start", &"on_spawn", &"on_lock", &"on_clear", &"on_tick", &"on_command"]

func handle(hook: StringName, ctx: HookContext, api: RuleApi) -> void:
	if hook == &"on_level_start":
		_enabled = bool(api.param(&"enabled", true))
		_last_tick = api.time_ms()
		_sync_capacity(api)
		_slots_event(api)
	elif hook == &"on_spawn":
		_spawn(ctx, api)
	elif hook == &"on_lock":
		_lock(ctx, api)
	elif hook == &"on_clear":
		_collect(ctx, api)
	elif hook == &"on_tick":
		_tick(api)
	elif hook == &"on_command":
		_command(ctx, api)

static func spawn_roll(rng: RandomNumberGenerator, probability: float, cube_count: int, injected: bool = false) -> int:
	if injected or cube_count <= 0:
		return -1
	if rng.randf() >= clampf(probability, 0.0, 0.5):
		return -1
	return rng.randi_range(0, cube_count - 1)

static func weights(rank: int, players: int, solo: bool = false) -> Array[float]:
	var result: Array[float] = []
	var standing: float = float(clampi(rank, 1, maxi(1, players)) - 1) / float(players - 1) if players >= 2 else 0.0
	for item: Dictionary in TABLE:
		result.append(0.0 if solo and item.debuff else float(item.weight) * maxf(0.0, 1.0 + float(item.bias) * standing))
	return result

static func roll(rng: RandomNumberGenerator, rank: int, players: int, solo: bool = false) -> StringName:
	var chances: Array[float] = weights(rank, players, solo)
	var total: float = 0.0
	for chance: float in chances:
		total += chance
	var draw: float = rng.randf() * total
	for index: int in chances.size():
		draw -= chances[index]
		if draw < 0.0:
			return StringName(TABLE[index].id)
	return &"slow_time"

static func is_debuff(id: StringName) -> bool:
	for row: Dictionary in TABLE:
		if StringName(row.id) == id:
			return bool(row.debuff)
	return false

func _sync_capacity(api: RuleApi) -> void:
	var base: int = api.knob_int(&"item.slots")
	if base <= 0:
		base = int(api.param(&"slots", 2))
	var count: int = clampi(base + int(api.param(&"extra_slots", 0)), 1, 3)
	while _slots.size() < count:
		_slots.append({})
	# A capacity reduction never silently deletes a held item; next round resets the hand.

func _spawn(_ctx: HookContext, api: RuleApi) -> void:
	_tag_uid = -1
	_tag_index = -1
	_tag_shape = &""
	_tag_token = ""
	api.set_piece_flag(&"item_cube", {})
	if _bomb_next:
		_bomb_uid = api.get_piece_uid()
		_bomb_next = false
		api.set_piece_flag(&"bomb", true)
	if not _enabled:
		return
	var cells: Array[Vector3i] = api.piece_cells()
	_tag_index = spawn_roll(api.rng(), float(api.param(&"p_item", 0.12)), cells.size(), bool(api.piece_flag(&"injected", false)))
	if _tag_index < 0:
		return
	_tag_uid = api.get_piece_uid()
	var shape: ShapeDef = api.get_piece_shape()
	_tag_shape = shape.shape_id if shape != null else &""
	_tag_token = "%s:%d" % [str(api.item_context().get("owner", 0)), _tag_uid]
	api.set_piece_flag(&"item_cube", {"uid": _tag_uid, "cube_index": _tag_index, "token": _tag_token})
	api.emit(&"item_cube_tagged", {"uid": _tag_uid, "cube_index": _tag_index, "cell": cells[_tag_index]})

func _lock(ctx: HookContext, api: RuleApi) -> void:
	var uid: int = int(ctx.data.get("uid", api.get_piece_uid()))
	_locked_at[uid] = _effect_clock
	var cells: Array[Vector3i] = []
	cells.assign(ctx.data.get("cells", []))
	var shape: ShapeDef = api.get_piece_shape()
	if uid == _tag_uid and _tag_index >= 0 and _tag_index < cells.size() and shape != null and shape.shape_id == _tag_shape:
		var cell: Vector3i = cells[_tag_index]
		var status: Dictionary = api.record_at(cell).get("status", {}).duplicate(true)
		status.merge({"item": true, "item_owner": str(api.item_context().get("owner", 0)), "item_token": _tag_token}, true)
		api.set_status(cell, status)
	if uid == _bomb_uid and not cells.is_empty():
		var center: Vector3i = blast_center(cells)
		var blast: Array[Vector3i] = []
		var radius: int = clampi(int(api.param(&"bomb_radius", 1)), 1, 2)
		for x: int in range(center.x - radius, center.x + radius + 1):
			for y: int in range(center.y - radius, center.y + radius + 1):
				for z: int in range(center.z - radius, center.z + radius + 1):
					var cell := Vector3i(x, y, z)
					if api.is_active(cell):
						blast.append(cell)
		api.request_post_clear_damage(blast, 2)
		api.emit(&"item_bomb_blast", {"center": center, "cells": blast})
		_bomb_uid = -1

static func blast_center(cells: Array[Vector3i]) -> Vector3i:
	var mean := Vector3.ZERO
	for cell: Vector3i in cells:
		mean += Vector3(cell)
	mean /= cells.size()
	var ordered: Array[Vector3i] = cells.duplicate()
	ordered.sort_custom(func(a: Vector3i, b: Vector3i) -> bool:
		var da: float = Vector3(a).distance_squared_to(mean)
		var db: float = Vector3(b).distance_squared_to(mean)
		return da < db or (is_equal_approx(da, db) and (a.y < b.y or (a.y == b.y and (a.x < b.x or (a.x == b.x and a.z < b.z)))))
	return ordered[0]

func _collect(ctx: HookContext, api: RuleApi) -> void:
	if not _enabled or int(ctx.data.get("cause", BoardState.Cause.CLEAR)) != BoardState.Cause.CLEAR:
		return
	var record: Dictionary = ctx.data.get("record", {})
	var status: Dictionary = record.get("status", {})
	if not bool(status.get("item", false)) or str(status.get("item_owner", "")) != str(api.item_context().get("owner", 0)):
		return
	var token: String = str(status.get("item_token", ""))
	if token.is_empty() or _collected.has(token):
		return
	_collected[token] = true
	var context: Dictionary = api.item_context()
	var players: int = maxi(1, int(context.get("players", 1)))
	var item: StringName = roll(api.rng(), int(context.get("rank", 1)), players, players <= 1 or bool(context.get("solo", false)))
	_sync_capacity(api)
	for slot: int in _slots.size():
		if _slots[slot].is_empty():
			_slots[slot] = {"id": item, "refunded": false}
			api.emit(&"item_collected", {"id": item, "slot": slot, "cell": ctx.data.get("cell", Vector3i.ZERO)})
			_slots_event(api)
			return
	api.request_score(clampi(int(api.param(&"full_slot_points", 50)), 0, 200))
	api.emit(&"item_full", {"id": item, "points": int(api.param(&"full_slot_points", 50))})

func _command(ctx: HookContext, api: RuleApi) -> void:
	var kind: StringName = StringName(ctx.data.get("kind", &""))
	var args: Array = ctx.data.get("args", [])
	if args.is_empty():
		return
	if kind == SimEvents.CMD_RECEIVE_ITEM and args[0] is Dictionary:
		var payload: Dictionary = args[0]
		if bool(payload.get("ack", false)):
			_ack(payload, api)
		else:
			var applied: bool = apply_effect(StringName(str(payload.get("effect_id", ""))), api)
			api.emit(&"item_attack_result", {"owner": payload.get("owner", 0), "token": payload.get("token", ""), "applied": applied})
		return
	if kind != SimEvents.CMD_USE_ITEM or (not args[0] is Dictionary and not args[0] is int):
		return
	var slot: int = int(args[0].get("slot", -1)) if args[0] is Dictionary else int(args[0])
	use_slot(slot, api)

func use_slot(slot: int, api: RuleApi) -> void:
	_sync_capacity(api)
	if not _enabled or slot < 0 or slot >= _slots.size() or _slots[slot].is_empty() or bool(_slots[slot].get("pending", false)):
		return
	var item: StringName = StringName(_slots[slot].get("id", &""))
	if is_debuff(item):
		if int(api.item_context().get("players", 1)) <= 1:
			api.emit(&"item_target_unavailable", {"slot": slot, "id": item})
			return
		_use_counter += 1
		var token: String = "%s:%d" % [str(api.item_context().get("owner", 0)), _use_counter]
		_slots[slot]["pending"] = true
		_slots[slot]["token"] = token
		api.emit(&"item_attack", {"effect_id": item, "owner": api.item_context().get("owner", 0), "slot": slot, "token": token})
		_slots_event(api)
		return
	if apply_effect(item, api):
		_slots[slot] = {}
		api.emit(&"item_used", {"id": item, "slot": slot})
	else:
		_refund(slot, api)
	_slots_event(api)

func _ack(payload: Dictionary, api: RuleApi) -> void:
	for slot: int in _slots.size():
		if bool(_slots[slot].get("pending", false)) and str(_slots[slot].get("token", "")) == str(payload.get("token", "")):
			if bool(payload.get("applied", false)):
				var id: StringName = StringName(_slots[slot].get("id", &""))
				_slots[slot] = {}
				api.emit(&"item_used", {"id": id, "slot": slot})
			else:
				_slots[slot].erase("pending")
				_slots[slot].erase("token")
				_refund(slot, api)
			_slots_event(api)
			return

func _refund(slot: int, api: RuleApi) -> void:
	var id: StringName = StringName(_slots[slot].get("id", &""))
	if bool(_slots[slot].get("refunded", false)):
		_slots[slot] = {}
		api.emit(&"item_no_effect", {"id": id, "slot": slot, "consumed": true})
	else:
		_slots[slot]["refunded"] = true
		api.emit(&"item_refunded", {"id": id, "slot": slot})

func apply_effect(id: StringName, api: RuleApi) -> bool:
	var modifiers: Array[Dictionary] = []
	var duration: int = 0
	match id:
		&"slow_time":
			modifiers = [{"knob": "fall.gravity_scale", "op": "mul", "value": 0.5}]
			duration = int(api.param(&"slow_time_ms", 10000))
		&"speed_up":
			modifiers = [{"knob": "fall.gravity_scale", "op": "mul", "value": 1.5}]
			duration = int(api.param(&"speed_up_ms", 15000))
		&"preview_peek":
			modifiers = [{"knob": "spawn.preview_count", "op": "add", "value": 2}, {"knob": "spawn.hold_enabled", "op": "set", "value": true}]
			duration = int(api.param(&"preview_peek_ms", 20000))
		&"spin_lock":
			var axes: Variant = api.knob(&"control.rotation_axes_enabled")
			if axes is Array and not axes.has("tilt") and not axes.has("roll"):
				return false
			duration = int(api.param(&"spin_lock_ms", 10000))
		&"fog":
			if api.rule_active(&"fog"):
				return false
			duration = int(api.param(&"fog_ms", 10000))
			if not _effects.has(id):
				_fog_started = _effect_clock
				_fog_key = ""
		&"helper_drop":
			var choices := PackedStringArray(["mono", "duo", "tri_straight", "tri_corner"])
			var helpers := PackedStringArray()
			for _index: int in clampi(int(api.param(&"helper_drop_count", 3)), 1, 5):
				helpers.append(choices[api.rng().randi_range(0, choices.size() - 1)])
			api.inject_front(helpers)
			api.emit(&"item_effect", {"id": id, "pieces": helpers})
			return true
		&"junk_rain":
			api.request_junk_layers(clampi(int(api.param(&"junk_rain_layers", 1)), 1, 3))
			api.emit(&"item_effect", {"id": id})
			return true
		&"bomb":
			_bomb_next = api.piece_cells().is_empty()
			_bomb_uid = -1 if _bomb_next else api.get_piece_uid()
			api.set_piece_flag(&"bomb", true)
			api.emit(&"item_effect", {"id": id, "uid": _bomb_uid})
			return true
		_:
			return false
	if not modifiers.is_empty():
		if not _effects.has(id) and not api.modifiers_would_change(modifiers):
			return false
		api.request_modifiers(StringName("item_" + String(id)), modifiers)
	_effects[id] = {"remaining_ms": maxi(1, duration), "duration_ms": duration}
	api.emit(&"item_effect", {"id": id, "duration_ms": duration})
	return true

func _tick(api: RuleApi) -> void:
	_sync_capacity(api)
	# Only eligible on_tick hooks advance this clock; resolving and warning gaps contribute one resumed tick.
	var delta: int = clampi(api.time_ms() - _last_tick, 0, 17)
	_last_tick = api.time_ms()
	_effect_clock += delta
	for id: Variant in _effects.keys():
		_effects[id]["remaining_ms"] = int(_effects[id]["remaining_ms"]) - delta
		if int(_effects[id]["remaining_ms"]) <= 0:
			api.clear_modifiers(StringName("item_" + String(id)))
			_effects.erase(id)
			api.emit(&"item_effect_expired", {"id": id})
			if StringName(id) == &"fog":
				api.emit(&"item_fog_visibility", {"hidden_cells": [], "active": false})
	if _effects.has(&"fog"):
		var hidden: Array[Vector3i] = []
		for cell: Vector3i in MechanicsCells.occupied(api):
			var uid: int = int(api.record_at(cell).get("piece_instance_id", 0))
			var born: int = maxi(_fog_started, int(_locked_at.get(uid, _fog_started)))
			if _effect_clock - born >= int(api.param(&"fog_visible_ms", 1000)):
				hidden.append(cell)
		var key: String = str(hidden)
		if key != _fog_key:
			_fog_key = key
			api.emit(&"item_fog_visibility", {"hidden_cells": hidden, "active": true, "alpha": 0.1})

func veto(action: StringName, ctx: HookContext, api: RuleApi) -> bool:
	if action != SimEvents.CMD_ROTATE or not _effects.has(&"spin_lock"):
		return false
	var args: Array = ctx.data.get("args", [])
	if args.is_empty():
		return false
	var down: Vector3i = api.down_vector()
	var spin_axis: int = 0 if down.x != 0 else 1 if down.y != 0 else 2
	return int(args[0]) != spin_axis

func _slots_event(api: RuleApi) -> void:
	api.emit(&"item_slots", {"slots": _slots.duplicate(true), "capacity": _slots.size()})

func snapshot() -> Dictionary:
	return {"enabled": _enabled, "slots": _slots.duplicate(true), "tag_uid": _tag_uid, "tag_index": _tag_index,
		"tag_shape": _tag_shape, "tag_token": _tag_token, "collected": _collected.duplicate(true),
		"effects": _effects.duplicate(true), "last_tick": _last_tick, "effect_clock": _effect_clock,
		"locked_at": _locked_at.duplicate(true), "fog_started": _fog_started, "fog_key": _fog_key,
		"bomb_uid": _bomb_uid, "bomb_next": _bomb_next, "use_counter": _use_counter}
