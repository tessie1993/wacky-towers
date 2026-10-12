extends Control
## DEV ONLY glue for MB-034: Title + Quit + Profile select/edit/delete over a ProfileStore(MemorySaveIO).
## Use: make a scene with a Control root + this script, run it, resize the window to 390x844 / 844x390.
## Esc = Back (stands in for AppFlow). Not part of the game; delete after integration.

const TITLE := preload("res://src/ui/screens/title/title_screen.tscn")
const SELECT := preload("res://src/ui/screens/profile_select/profile_select.tscn")
const EDIT := preload("res://src/ui/screens/profile_select/profile_edit.tscn")
const QUIT := preload("res://src/ui/dialogs/quit_dialog.tscn")
const DELETE := preload("res://src/ui/dialogs/delete_profile_dialog.tscn")

var _store := ProfileStore.new(MemorySaveIO.new())
var _rng := RandomNumberGenerator.new()
var _stack: Array[UiScreen] = []
var _edit_mode: bool = false
var _edit_snap: ProfileEditSnapshot
var _title: TitleScreen
var _select: ProfileSelect


func _ready() -> void:
	_rng.seed = 34
	_title = _spawn(TITLE)
	_select = _spawn(SELECT)
	_push(_title)
	_refresh()


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel") and _stack.size() > 0:
		_on_intent(UiIntents.BACK, {})


func _spawn(scene: PackedScene) -> UiScreen:
	var s: UiScreen = scene.instantiate()
	add_child(s)
	s.hide()
	s.intent.connect(_on_intent)
	return s


func _push(s: UiScreen) -> void:
	_stack.append(s)
	s.enter(false)


func _pop() -> void:
	var s: UiScreen = _stack.pop_back()
	s.exit()
	if s.screen_id in [&"profile_edit", &"quit", &"delete_profile"]:
		s.queue_free()
	if not _stack.is_empty():
		_stack.back().enter(true)


func _refresh() -> void:
	var t := TitleSnapshot.new()
	var a: Variant = _store.active_profile()
	if a != null:
		t.has_profile = true
		t.profile_name = a["name"]
		t.profile_badge = StringName(a["badge"])
		t.profile_color = StringName(a["color"])
		t.continue_level_id = &"meadow_04"
		t.continue_stars = 2
	_title.bind(t)
	var p := ProfileSelectSnapshot.new()
	p.slots = _store.slots()
	p.active_slot = int(a["slot"]) if a != null else -1
	p.edit_mode = _edit_mode
	_select.bind(p)


func _on_intent(id: StringName, args: Dictionary) -> void:
	match id:
		UiIntents.BACK:
			if _stack.back() == _title:
				_push(_spawn(QUIT))
			else:
				_pop()
		UiIntents.QUIT:
			get_tree().quit()
		UiIntents.PLAY, UiIntents.CREATE_PROFILE when _stack.back() != _edit_screen():
			_open_edit(false, -1)
		UiIntents.PLAY, UiIntents.CONTINUE, UiIntents.OPEN_MAP, UiIntents.OPEN_SETTINGS:
			print("[demo] ", id)
		UiIntents.OPEN_PROFILES:
			_push(_select)
		UiIntents.SELECT_PROFILE:
			_store.switch_to(int(args["slot"]))
			_refresh()
			_pop()
		UiIntents.RENAME_PROFILE when _stack.back() == _select:
			_open_edit(true, int(args["slot"]))
		UiIntents.DELETE_PROFILE when _stack.back() == _select:
			var d := _spawn(DELETE)
			var info: Dictionary = _store.slots()[int(args["slot"])]
			var ds := DeleteProfileSnapshot.new()
			ds.slot = int(args["slot"])
			ds.profile_name = info["name"]
			ds.color = StringName(info["color"])
			ds.badge = StringName(info["badge"])
			ds.stars = info["stars"]
			ds.levels = info["furthest"]
			d.bind(ds)
			_push(d)
		UiIntents.DELETE_PROFILE:
			_store.delete(int(args["slot"]))
			_pop()
			_refresh()
		UiIntents.SET_PREF:
			_on_pref(args)
		ProfileEdit.RANDOM_NAME:
			_edit_snap.name = ProfileEditSnapshot.random_name(_rng)
			_bind_edit()
		UiIntents.CREATE_PROFILE, UiIntents.RENAME_PROFILE:
			_save_edit(id, args)


func _edit_screen() -> UiScreen:
	return _stack.back() if _stack.back().screen_id == &"profile_edit" else null


func _on_pref(args: Dictionary) -> void:
	if args["key"] == ProfileSelect.EDIT_MODE_KEY:
		_edit_mode = args["value"]
		_refresh()
		return
	match args["key"]:
		"name": _edit_snap.name = args["value"]
		"color": _edit_snap.color = StringName(args["value"])
		"badge": _edit_snap.badge = StringName(args["value"])
	_bind_edit()


func _open_edit(rename: bool, slot: int) -> void:
	_edit_snap = ProfileEditSnapshot.new()
	_edit_snap.is_rename = rename
	_edit_snap.slot = slot
	if rename:
		var info: Dictionary = _store.slots()[slot]
		_edit_snap.name = info["name"]
		_edit_snap.color = StringName(info["color"])
		_edit_snap.badge = StringName(info["badge"])
	else:
		_edit_snap.name = ProfileEditSnapshot.random_name(_rng)
		_edit_snap.color = StringName(ProfileStore.COLORS[0])
		_edit_snap.badge = StringName(ProfileStore.BADGES[0])
	var e := _spawn(EDIT)
	_push(e)
	_bind_edit()


func _bind_edit() -> void:
	_stack.back().bind(_edit_snap)


func _save_edit(id: StringName, args: Dictionary) -> void:
	var clean: String = ProfileStore.clean_name(args["name"])
	var ok: bool
	if id == UiIntents.CREATE_PROFILE:
		ok = _store.create(clean, args["color"], args["badge"]) >= 0
	else:
		ok = _store.rename(int(args["slot"]), clean) == OK
	if not ok:
		_edit_snap.error_key = "UI_PROFILE_NAME_EMPTY" if clean.is_empty() else "UI_PROFILE_NAME_TAKEN"
		_edit_snap.error_nonce += 1
		_bind_edit()
		return
	_pop()
	_refresh()
