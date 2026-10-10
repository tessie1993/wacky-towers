extends SceneTree
const UI := preload("res://src/ui/game_ui.gd")
var _seen: Array[Dictionary] = []
var _failed := 0
func _initialize() -> void: call_deferred("_run")
func _check(condition: bool, detail: String) -> void:
	if not condition:
		_failed += 1
		push_error(detail)
func _press(ui: GameUi, text: String) -> void:
	for button: Node in ui._root.find_children("*","Button",true,false):
		if button.text == text and button.is_visible_in_tree():
			_check(not button.disabled,"Requested disabled action: "+text)
			button.pressed.emit()
			return
	_check(false,"Missing action: "+text)
func _data(id: String) -> Dictionary:
	return {"id":id,"phase":"playing","elapsed_ms":1200,"duration_ms":60000,"standing_metric":"score","standing":3,
		"board":{"size":Vector3i(4,8,4),"cells":[{"cell":Vector3i(1,0,1),"kind":1,"hue":0,"status":{}}]},
		"piece":{"shape_id":"corner","cells":[Vector3i(1,3,1),Vector3i(2,3,1),Vector3i(1,3,2)]},
		"view":{"hole":PackedVector2Array([Vector2(0,0),Vector2(1,0)]),"model":[Vector3i(1,0,1)],"show_until":5000,"bins":PackedInt32Array([0,1,2]),"front_target":[Vector2i(1,0)],"side_target":[Vector2i(1,0)],"tray":Vector2i(2,2),"sky_cells":[Vector3i(3,4,3)],"landing_cells":[Vector3i(3,0,3)]},
		"send":{"ready":true,"charge":3,"needed":3,"effect":"fog","target":2},"opponents":[{"id":2,"name":"Lana","active":true}],"attacks":[]}
func _run() -> void:
	var ui := UI.new()
	root.add_child(ui)
	ui.intent.connect(func(id: StringName,args: Dictionary)->void: _seen.append({"id":id,"args":args}))
	await process_frame
	for viewport: Vector2i in [Vector2i(1280,720),Vector2i(720,1280)]:
		root.size=viewport
		for scale: float in [1.0,1.5]:
			ui.apply_prefs({"text_scale":scale,"button_scale":2.0})
			for index: int in 21:
				ui.show_minigame(_data("mg%02d"%(index+1)))
				await process_frame
				await process_frame
				for button: Node in ui._root.find_children("*","Button",true,false):
					if not button.is_visible_in_tree(): continue
					var rect: Rect2=button.get_global_rect()
					_check(Rect2(Vector2.ZERO,Vector2(viewport)).encloses(rect),"Button outside viewport %s mode%d: %s %s"%[viewport,index+1,button.text,rect])
	ui.show_minigame(_data("mg09"))
	await process_frame
	_press(ui,"Bin 3 →")
	_check(_seen[-1].id==&"mg_sort" and _seen[-1].args.bin==2,"Sort maps canonical bin")
	ui.show_minigame(_data("mg01"))
	await process_frame
	_press(ui,"Roll ›")
	_check(_seen[-1].id==&"mg_rotate" and _seen[-1].args.axis==2 and _seen[-1].args.dir==1,"Projected toy rolls")
	ui.show_minigame(_data("mg15"))
	await process_frame
	_press(ui,"↑")
	_check(_seen[-1].id==&"mg_move" and _seen[-1].args.direction==Vector3i(0,0,-1),"Tray direction")
	var gift:=_data("mg08")
	gift.view.gifts=["party_l","hollow_box"]
	ui.show_minigame(gift)
	await process_frame
	_press(ui,"Gift 2 · Hollow Box")
	_check(_seen[-1].id==&"mg_choose_gift" and _seen[-1].args.index==1,"Gift choice")
	_press(ui,"Lana")
	_check(_seen[-1].id==&"mg_target" and _seen[-1].args.player_id==2,"Opponent target")
	gift.phase="ghost"
	gift.ghost=true
	ui.update_minigame(gift)
	_press(ui,"Ghost send →")
	_check(_seen[-1].id==&"mg_send","Ghost can send")
	for button: Button in ui._minigame_view._buttons: _check(button.disabled,"Ghost blocks placement")
	ui.show_round_card({"phase":"reroll","remaining_ms":4500,"local_player_id":"2","reroll_eligible":["2"],"template":{"id":"mg01","name":"Hole in the Wall","rule":"Turn the toy to fit the wall."}})
	await process_frame
	_press(ui,"Another toy box?  ↻")
	_check(_seen[-1].id==&"reroll" and _seen[-1].args.player_id=="2","Qualified reroll")
	ui.update_round_card({"phase":"locked","remaining_ms":0,"local_player_id":"2","template":{"id":"mg01","name":"Hole in the Wall","rule":"Turn the toy to fit the wall."}})
	_press(ui,"Ready  ✓")
	_check(_seen[-1].id==&"round_ready","Ready route")
	ui.show_round_results({"standings":[{"name":"Lana","wins":1}],"history":[{"name":"Hole in the Wall","winners":["2"]}],"awards":[{"name":"Tallest tower","player_name":"Lana"}]})
	await process_frame
	_press(ui,"Next toy box  →")
	_check(_seen[-1].id==&"next_round","Next round route")
	_check(not _seen.any(func(row: Dictionary)->bool:return row.id==&"noop"),"No decorative noop emitted")
	ui.queue_free()
	await process_frame
	print("MINIGAME_UI_SMOKE: 84 layout cases, semantic controls, gift/target/ghost, qualified reroll/ready/results; failures=%d"%_failed)
	quit(0 if _failed==0 else 1)
