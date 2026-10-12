class_name WtMinigameRulesB extends RefCounted
## Stateless dispatcher: mutable rule data lives in the authoritative session snapshot.
const STANDARD: Array[String] = ["i","o","t","l","tripod","screw_l","screw_r","chair"]
const HELPERS: Array[String] = ["mono","duo","tri_straight","tri_corner"]

func start(s: Variant) -> void:
	s.state.clear()
	s.view.clear()
	match s.id:
		&"mg06":
			s.set_board({"width":8,"depth":3,"h_play":6,"starting_contents":{"layers":{"0":["#......#","#......#","#......#"]}}},{"shapes":STANDARD},{"clear.enabled":false,"goal.top_out":"trim"},{"type":"endless"})
			s.state.merge({"mascot":Vector3i(0,0,1),"walk_due":250,"bird_due":_timed_charge(s,int(s.params.get("bird_charge_ms",25000)))})
			s.view["mascot"] = s.state.mascot
		&"mg07":
			s.set_board({"width":4,"depth":4,"h_play":3},{"shapes":STANDARD},{"clear.enabled":false,"spawn.hold_enabled":true,"goal.top_out":"trim"},{"type":"endless"})
			s.state["sent_layers"] = {}
		&"mg08":
			s.set_board({"width":5,"depth":5,"h_play":8},{"shapes":STANDARD},{},{"type":"clear_n","n":int(s.params.get("clear_target",4))})
			s.state.merge({"gifts":[],"offers":[],"offer_serial":0})
		&"mg10":
			s.state.merge({"puzzle":0,"solved":{},"flicker_until":0})
			_shadow_board(s)
		&"mg11":
			var table: Array[Dictionary] = []
			for row: Dictionary in ItemsRule.TABLE:
				if str(row.id) in ["fog","speed_up","spin_lock","slow_time","preview_peek"]: table.append(row.duplicate(true))
			s.set_board({"width":5,"depth":5,"h_play":6},{"shapes":STANDARD},{"clear.enabled":false,"goal.top_out":"trim"},{"type":"endless"},[{"id":"fog","params":{"visible_ms":int(s.params.get("visible_ms",2000))}},{"id":"items","params":{"p_item":0.0,"table":table}}])
			s.state["ribbon"] = 0
		&"mg12":
			var extra := RuleDef.new()
			extra.id = &"mg_extra_spin"
			extra.layer = &"item_buff"
			extra.behaviour = &"turntable"
			s.catalog.rule_defs[extra.id] = extra
			s.set_board({"width":5,"depth":5,"h_play":8},{"shapes":STANDARD},{},{"type":"endless"},[{"id":"turntable","params":{"turn_locks":int(s.params.get("turn_locks",3))}},{"id":"mg_extra_spin","params":{"turn_locks":1000000}},{"id":"items"}])
		&"mg13":
			s.set_board({"width":4,"depth":4,"h_play":20,"starting_contents":{"layers":{"0":["##..","##..","##..","##.."]}}},{"shapes":STANDARD},{"clear.enabled":false,"goal.top_out":"trim"},{"type":"endless"})
			s.state.merge({"lava":-1,"rise":0,"lava_due":int(s.params.get("lava_start_ms",12000)),"unsafe_since":-1,"ghost":false,"ghost_due":0,"before_safe":0})
		&"mg14":
			s.set_board({"width":5,"depth":5,"h_play":10},{"shapes":STANDARD},{},{"type":"clear_n","n":int(s.params.get("clear_target",5))})
			s.state.merge({"hot_owner":-1,"hot_serial":-1,"hot_uid":0,"hot_due":0,"hot_waiting":false,"hot_requested":false})
			s.request_shared(&"hot_start", {"player":s.player_id})
		&"mg19": _gem_start(s)
		&"mg20": _paint_start(s)
		&"mg21": _balance_start(s)

func tick(s: Variant, events: Array[SimEvent]) -> void:
	match s.id:
		&"mg06": _bridge_tick(s)
		&"mg07":
			var fill: Dictionary = WtMinigameGeometry.box_fill(s.sim.board())
			s.progress = int(roundf(float(fill.progress)*1000))
			s.view["box"] = fill
			for layer: int in fill.layers:
				if not s.state.sent_layers.has(layer):
					s.state.sent_layers[layer] = true
					var pool: PackedStringArray = _pool(s, ["hollow","party"])
					s.request_send(&"awkward_piece", {"piece":pool[s.rng.randi_range(0,pool.size()-1)]})
			if s.progress == 1000: s.finish()
		&"mg08": _gift_tick(s,events)
		&"mg10": _shadow_tick(s)
		&"mg11":
			var height: int = maxi(0,s.top_height())
			s.points = height
			s.progress = mini(1000,height*1000/6)
			if height > int(s.state.ribbon):
				for _ribbon: int in range(int(s.state.ribbon),height):
					var row: Dictionary = _rule(s,&"items")
					if not row.is_empty():
						(row.behaviour as ItemsRule).award_trigger(row.api)
						s.sim._collect_api(row.api,true,2)
				s.state.ribbon = height
			s.view["height_ribbons"] = height
		&"mg12":
			var layers: int = 0
			for e: SimEvent in events:
				if e.kind == SimEvents.LAYERS_CLEARED: layers += int(e.data.get("n_layers",1))
			if layers >= int(s.params.get("extra_spin_min_layers",2)): s.request_send(&"extra_spin",{})
			s.points = s.sim.goal_state().score
			s.progress = mini(1000,s.sim.goal_state().layers_cleared*100)
		&"mg13": _lava_tick(s,events)
		&"mg14": _hot_tick(s,events)
		&"mg19": _gem_tick(s)
		&"mg20": _paint_score(s)
		&"mg21": _balance_view(s)

func command(s: Variant, cmd: SimCommand) -> bool:
	if cmd.kind == &"mg_authority" and not cmd.args.is_empty() and cmd.args[0] is Dictionary:
		_authority(s,cmd.args[0])
		return true
	match s.id:
		&"mg08":
			if cmd.kind == &"mg_gift_choose" or cmd.kind == &"mg_choose":
				if cmd.args.is_empty(): return true
				var index: int = int(cmd.args[0].get("index",-1)) if cmd.args[0] is Dictionary else int(cmd.args[0])
				if index >= 0 and index < s.state.offers.size():
					var data: Dictionary = {"piece":s.state.offers[index]}
					if cmd.args[0] is Dictionary and cmd.args[0].has("target"): data["target"] = cmd.args[0].target
					s.request_send(&"gift",data)
					s.state.offers = []
					s.view["gift_offers"] = []
				return true
		&"mg19":
			if cmd.kind == &"mg_move": _gem_move(s,cmd.args); return true
			if cmd.kind == &"mg_deposit": _gem_deposit(s); return true
			if cmd.kind == &"mg_collect": _gem_collect(s); return true
		&"mg20":
			if cmd.kind == &"mg_move": _paint_move(s,cmd.args); return true
			if cmd.kind == &"mg_paint": _paint(s,cmd.args); return true
		&"mg21":
			if cmd.kind == &"mg_choose":
				s.state.selected = clampi(int(cmd.args[0]) if not cmd.args.is_empty() else 0,0,s.state.offers.size()-1)
				_balance_view(s); return true
			if cmd.kind == &"mg_pan": _balance_pan(s,cmd.args); return true
			if cmd.kind == &"mg_release": _balance_release(s); return true
	return false

func preview_attack(s: Variant, effect: StringName, data: Dictionary) -> Dictionary:
	var out: Dictionary = data.duplicate(true)
	if effect == &"bird" and s.sim != null:
		var target: Dictionary = WtMinigameGeometry.bird_cell(s.sim.board(),s.state.mascot)
		if not target.is_empty():
			out["cell"] = target.cell
			out["uid"] = s.sim.board().get_record(s.sim.board().index(target.cell)).piece_instance_id
		out["warn_ms"] = 1500
	return out

func attack(s: Variant, effect: StringName, data: Dictionary) -> void:
	match effect:
		&"bird":
			var target: Dictionary = data if data.has("cell") else WtMinigameGeometry.bird_cell(s.sim.board(),s.state.mascot)
			if target.is_empty(): return
			var cell: Vector3i = target.cell
			var mascot: Vector3i = s.state.mascot
			if cell.x == mascot.x and cell.z == mascot.z:
				target = WtMinigameGeometry.bird_cell(s.sim.board(),mascot)
				if target.is_empty(): return
				cell = target.cell
			elif data.has("uid") and int(s.sim.board().get_record(s.sim.board().index(cell)).piece_instance_id) != int(data.uid): return
			_remove(s,[cell])
			s.emit(&"bird_peck",{"cell":cell})
		&"awkward_piece":
			var piece: StringName = StringName(data.get("piece",&"ring"))
			var shape: ShapeDef = s.catalog.shapes.get_shape(piece)
			if shape != null and str(shape.family) in ["hollow","party"]:
				s.inject_piece(piece)
				s.emit(&"awkward_preview",{"piece":piece,"bow":true})
		&"gift":
			if s.state.gifts.size() >= int(s.params.get("gift_cap",2)):
				s.emit(&"gift_full",{}); return
			var piece: StringName = StringName(data.get("piece",&"ring"))
			if not _pool(s,["hollow","party","pento_3d","giant"]).has(String(piece)): return
			s.state.gifts.append(piece)
			s.inject_piece(piece,int(s.params.get("gift_delay_pieces",1)))
			s.view["pending_gifts"] = s.state.gifts.duplicate()
		&"flicker":
			s.state.flicker_until = s.now_ms()+int(data.get("duration_ms",3000))
			s.view["flicker_until_ms"] = s.state.flicker_until
		&"extra_spin":
			var extra: Dictionary = _rule(s,&"mg_extra_spin")
			if not extra.is_empty(): (extra.behaviour as TurntableRule)._locks = 999999
			s.emit(&"extra_spin_queued",{})
		&"pump":
			s.state.lava_due = maxi(s.now_ms()+1,int(s.state.lava_due)-int(data.get("amount",data.get("early_ms",s.params.get("pump_advance_ms",4000)))))
			s.emit(&"lava_pump",{"rise_at_ms":s.state.lava_due})
		&"sticky_tiles":
			s.state.sticky_until = s.now_ms()+int(data.get("duration_ms",5000))
			s.view["sticky_until_ms"] = s.state.sticky_until
		&"wet_paint": _wet_paint(s,data)
		&"surprise_weight":
			s.state.surprise = int(data.get("extra_mass",s.params.get("weight_surprise",2)))
			s.emit(&"surprise_weight_mark",{"extra_mass":s.state.surprise})
			_balance_view(s)

func _bridge_tick(s: Variant) -> void:
	if s.now_ms() >= int(s.state.walk_due):
		var path: Array[Vector3i] = WtMinigameGeometry.bridge_path(s.sim.board(),s.state.mascot)
		if path.size()>1: s.state.mascot = path[1]
		s.state.walk_due = s.now_ms()+250
		s.view["mascot"] = s.state.mascot
		s.view["walkway"] = path
		s.progress = int(s.state.mascot.x)*1000/7
		if int(s.state.mascot.x)>=7: s.finish()
	if s.now_ms() >= int(s.state.bird_due):
		s.charge_send(&"bird",{},1)
		s.state.bird_due = s.now_ms()+_timed_charge(s,int(s.params.get("bird_charge_ms",25000)))
		s.view["bird_ready_at_ms"] = s.state.bird_due

func _gift_tick(s: Variant, events: Array[SimEvent]) -> void:
	for e: SimEvent in events:
		if e.kind == SimEvents.PIECE_SPAWNED and not s.state.gifts.is_empty() and str(e.data.get("shape_id","")) == str(s.state.gifts[0]): s.state.gifts.pop_front()
		if e.kind == SimEvents.PIECE_LOCKED:
			var pool: PackedStringArray = _pool(s,["hollow","party","pento_3d","giant"])
			var nastier: bool = s.rank()>1
			var half: int = maxi(1,pool.size()/2)
			var start_index: int = half if nastier else 0
			var end_index: int = pool.size()-1 if nastier else half-1
			s.state.offers = [pool[s.rng.randi_range(start_index,end_index)],pool[s.rng.randi_range(start_index,end_index)]]
			s.state.offer_serial += 1
			s.view["gift_offers"] = s.state.offers.duplicate()
			s.view["gift_pick_deadline_ms"] = s.now_ms()+int(s.params.get("pick_window_ms",1500))
	s.view["pending_gifts"] = s.state.gifts.duplicate()
	s.progress = mini(1000,s.sim.goal_state().layers_cleared*1000/maxi(1,int(s.params.get("clear_target",4))))
	if s.progress>=1000: s.finish()

func _shadow_board(s: Variant) -> void:
	s.set_board({"width":4,"depth":4,"h_play":4},{"shapes":HELPERS},{"clear.enabled":false,"goal.top_out":"trim"},{"type":"endless"})
	var model: Array[Vector3i] = []
	var puzzle: int = int(s.state.puzzle)
	var seed_rng := Seeds.make_rng(s.rng.seed,["shadow",puzzle])
	for _column: int in 6+puzzle:
		var x: int = seed_rng.randi_range(0,3)
		var z: int = seed_rng.randi_range(0,3)
		var y: int = 0
		while model.has(Vector3i(x,y,z)): y+=1
		if y<4:model.append(Vector3i(x,y,z))
	s.state["front"] = WtMinigameGeometry.front(model)
	s.state["side"] = WtMinigameGeometry.side(model)
	s.view["front_silhouette"] = s.state.front.duplicate()
	s.view["side_silhouette"] = s.state.side.duplicate()
	s.view["puzzle_index"] = puzzle

func _shadow_tick(s: Variant) -> void:
	var result: Dictionary = WtMinigameGeometry.silhouettes(s.board_cells(),s.state.front,s.state.side)
	s.progress = int(roundf(float(result.progress)*1000))
	s.view["silhouette_progress"] = s.progress
	s.view["flicker_until_ms"] = s.state.flicker_until
	if result.match and not s.state.solved.has(s.state.puzzle):
		s.state.solved[s.state.puzzle] = true
		s.request_shared(&"shadow_solved",{"player":s.player_id,"puzzle":s.state.puzzle})

func _lava_tick(s: Variant, events: Array[SimEvent]) -> void:
	if bool(s.state.ghost):
		if s.now_ms()>=int(s.state.ghost_due):
			s.charge_send(&"pump",{"early_ms":int(s.params.get("pump_advance_ms",4000)),"amount":int(s.params.get("pump_advance_ms",4000)),"ghost":true},1)
			s.state.ghost_due=s.now_ms()+int(s.params.get("ghost_send_ms",15000))
		return
	for e: SimEvent in events:
		if e.kind==SimEvents.PIECE_LOCKED:s.charge_send(&"pump",{"early_ms":int(s.params.get("pump_advance_ms",4000)),"amount":int(s.params.get("pump_advance_ms",4000))},int(s.params.get("pump_charge",4)))
	var safe: Array[int] = WtMinigameGeometry.safe_layers(s.sim.board(),int(s.state.lava),float(s.params.get("lava_cover",0.5)))
	s.state.before_safe=safe.size()
	if s.now_ms()>=int(s.state.lava_due):
		s.state.lava+=1
		var melt: Array[Vector3i] = []
		for cell:Vector3i in s.board_cells():
			if cell.y<=int(s.state.lava):melt.append(cell)
		_remove(s,melt)
		s.state.rise+=1
		s.state.lava_due+=WtMinigameGeometry.lava_interval(int(s.state.rise),int(s.params.get("lava_start_ms",12000)),int(s.params.get("lava_min_ms",7000)),int(s.params.get("lava_step_ms",500)))
		s.emit(&"lava_rise",{"layer":s.state.lava,"next_ms":s.state.lava_due,"safe_before":s.state.before_safe})
		safe=WtMinigameGeometry.safe_layers(s.sim.board(),int(s.state.lava),float(s.params.get("lava_cover",0.5)))
	if safe.is_empty():
		if int(s.state.unsafe_since)<0:s.state.unsafe_since=s.now_ms()
		if s.now_ms()-int(s.state.unsafe_since)>=int(s.params.get("unsafe_loss_ms",2000)):
			s.state.ghost=true
			s.state["alive_ms"]=s.now_ms()
			s.state["ghost_effect"]="pump"
			s.become_ghost()
			s.state.ghost_due=s.now_ms()+int(s.params.get("ghost_send_ms",15000))
			s.emit(&"mg_ghost",{"safe_before":s.state.before_safe,"alive_ms":s.now_ms()})
	else:s.state.unsafe_since=-1
	s.points=safe.size()
	s.progress=mini(1000,safe.size()*100)
	s.view.merge({"lava_layer":s.state.lava,"safe_layers":safe,"mascot_layer":safe[-1] if not safe.is_empty() else -1,"ghost":s.state.ghost,"rise_at_ms":s.state.lava_due},true)

func _hot_tick(s: Variant, events: Array[SimEvent]) -> void:
	for e:SimEvent in events:
		if e.kind==SimEvents.PIECE_SPAWNED and bool(s.state.hot_waiting) and str(e.data.get("shape_id",""))=="big_cube":
			s.state.hot_uid=int(e.data.uid)
			s.state.hot_waiting=false
		if e.kind==&"cube_cleared" and int(e.data.get("record",{}).get("piece_instance_id",0))==int(s.state.hot_uid) and int(s.state.hot_uid)>0 and not bool(s.state.hot_requested):
			s.state.hot_requested=true
			s.request_shared(&"hot_pass",{"owner":s.player_id,"serial":s.state.hot_serial})
	if int(s.state.hot_owner)==s.player_id and s.players()>1 and s.now_ms()>=int(s.state.hot_due) and not bool(s.state.hot_requested):
		s.state.hot_requested=true
		s.request_shared(&"hot_explode",{"owner":s.player_id,"serial":s.state.hot_serial})
	s.view.merge({"hot_owner":s.state.hot_owner,"hot_uid":s.state.hot_uid,"hot_fuse_at_ms":s.state.hot_due,"hot_serial":s.state.hot_serial},true)
	s.progress=mini(1000,s.sim.goal_state().layers_cleared*1000/maxi(1,int(s.params.get("clear_target",5))))
	if s.progress>=1000:s.finish()

func _authority(s:Variant,data:Dictionary)->void:
	var kind:StringName=StringName(data.get("kind",&""))
	if kind==&"shadow_next" and s.id==&"mg10":
		if int(data.get("puzzle",0))!=int(s.state.puzzle):return
		if int(data.get("winner",-1))==s.player_id:
			s.add_score(1)
			s.request_send(&"flicker",{"duration_ms":int(s.params.get("flicker_ms",3000))})
		s.state.puzzle+=1
		if int(s.state.puzzle)>=int(s.params.get("puzzles_target",3)):s.finish(&"won" if s.points>0 else &"done")
		else:_shadow_board(s)
	elif kind in [&"hot_holder",&"hot_exploded"] and s.id==&"mg14":
		var serial:int=int(data.get("serial",0))
		if serial<=int(s.state.hot_serial):return
		if int(s.state.hot_owner)==s.player_id:
			_remove_hot(s)
			if kind==&"hot_exploded":
				s.sim.get_api().request_junk_layers(int(s.params.get("blast_junk",2)))
				s.sim._collect_api(s.sim.get_api(),true,2)
				s.emit(&"hot_block_boom",{"layers":int(s.params.get("blast_junk",2))})
		s.state.hot_serial=serial
		s.state.hot_owner=int(data.get("next_owner",data.get("owner",-1)))
		s.state.hot_due=s.now_ms()+int(data.get("fuse_ms",s.params.get("fuse_ms",20000)))
		s.state.hot_requested=false
		s.state.hot_uid=0
		s.state.hot_waiting=int(s.state.hot_owner)==s.player_id
		if s.state.hot_waiting:s.inject_piece(&"big_cube")
	elif kind==&"hot_cancel" and s.id==&"mg14":
		s.state.hot_due=2147483647
	elif kind==&"gold_gem_awarded" and s.id==&"mg19":
		if int(data.get("serial",-1))!=int(s.state.gold_serial):return
		s.state.gold_claimed=true
		if int(data.get("winner",-1))==s.player_id:s.add_score(1+int(data.get("steal",2)))
		elif int(data.get("leader",-1))==s.player_id:s.points=maxi(0,s.points-int(data.get("steal",2)))

func _remove_hot(s:Variant)->void:
	var cells:Array[Vector3i]=[]
	for cell:Vector3i in s.board_cells():
		if int(s.sim.board().get_record(s.sim.board().index(cell)).piece_instance_id)==int(s.state.hot_uid):cells.append(cell)
	_remove(s,cells)

func _remove(s:Variant,cells:Array[Vector3i])->void:
	var api:RuleApi=s.sim.get_api()
	for cell:Vector3i in cells:api.remove_cell(cell,BoardState.Cause.DISPLACED)
	s.sim._collect_api(api,true,2)

func _rule(s:Variant,id:StringName)->Dictionary:
	for row:Dictionary in s.sim._rules:
		if StringName(row.id)==id:return row
	return {}

func _pool(s:Variant,families:Array[String])->PackedStringArray:
	var shapes:Array[ShapeDef]=[]
	for shape:ShapeDef in s.catalog.shapes.shapes:
		if str(shape.family) in families and shape.cube_count<=9:shapes.append(shape)
	shapes.sort_custom(func(a:ShapeDef,b:ShapeDef)->bool:return a.cube_count<b.cube_count or (a.cube_count==b.cube_count and str(a.shape_id)<str(b.shape_id)))
	var result:=PackedStringArray()
	for shape:ShapeDef in shapes:result.append(String(shape.shape_id))
	return result

func _timed_charge(s:Variant,base:int)->int:
	var scale:float=1.0+float(s.params.get("k_cb",0.5))*float(s.rank()-1)/maxi(1,s.players()-1)
	return int(roundf(float(base)/scale))

func _gem_start(s:Variant)->void:
	s.state.merge({"cursor":Vector2i.ZERO,"bag":[],"gems":{},"deposit_count":0,"gold_serial":0,"gold_claimed":false,"gold_requested":false,"move_due":0,"sticky_until":0})
	var positions:Array[Vector2i]=[]
	for x:int in 7:
		for z:int in 7:
			if Vector2i(x,z)!=Vector2i.ZERO:positions.append(Vector2i(x,z))
	for serial:int in int(s.params.get("gem_count",6)):
		var at:int=s.rng.randi_range(0,positions.size()-1)
		s.state.gems[positions[at]]={"shape":&"mono","serial":serial}
		positions.remove_at(at)
	s.view.merge({"island_size":Vector2i(7,7),"base":Vector2i.ZERO,"cursor":Vector2i.ZERO,"gem_cells":s.state.gems.keys(),"bag_count":0,"bag_capacity":int(s.params.get("bag_capacity",5))})
	_gem_gold(s,0)

func _gem_gold(s:Variant,serial:int)->void:
	var shared:=Seeds.make_rng(s.rng.seed,["gold_gem",serial])
	s.state.gold_serial=serial
	s.state.gold_cell=Vector2i(shared.randi_range(1,6),shared.randi_range(1,6))
	s.state.gold_claimed=false
	s.state.gold_requested=false
	s.view["gold_gem"]={"serial":serial,"cell":s.state.gold_cell,"available":true}
	s.emit(&"gold_gem",s.view.gold_gem)

func _gem_tick(s:Variant)->void:
	var serial:int=s.now_ms()/maxi(1,int(s.params.get("golden_every_ms",10000)))
	if serial!=int(s.state.gold_serial):_gem_gold(s,serial)
	s.view.merge({"cursor":s.state.cursor,"gem_cells":s.state.gems.keys(),"bag_count":s.state.bag.size(),"gold_gem":{"serial":s.state.gold_serial,"cell":s.state.gold_cell,"available":not bool(s.state.gold_claimed)},"score":s.points},true)
	s.progress=mini(1000,s.points*50)

func _direction(args:Array)->Vector2i:
	if args.is_empty():return Vector2i.ZERO
	if args[0] is Vector3i:return Vector2i(args[0].x,args[0].z)
	if args[0] is Vector2i:return args[0]
	if args[0] is Dictionary:
		var raw:Variant=args[0].get("direction",Vector2i.ZERO)
		if raw is Vector2i:return raw
		if raw is Vector3i:return Vector2i(raw.x,raw.z)
		if raw is Array and raw.size()>=2:return Vector2i(int(raw[0]),int(raw[1]))
	return Vector2i.ZERO

func _gem_move(s:Variant,args:Array)->void:
	if s.now_ms()<int(s.state.move_due):return
	var dir:Vector2i=_direction(args)
	if absi(dir.x)+absi(dir.y)!=1:return
	var cursor:Vector2i=s.state.cursor+dir
	if cursor.x<0 or cursor.y<0 or cursor.x>=7 or cursor.y>=7:return
	s.state.cursor=cursor
	s.state.move_due=s.now_ms()+(400 if s.now_ms()<int(s.state.sticky_until) else 100)
	_gem_collect(s)
	if cursor==Vector2i.ZERO:_gem_deposit(s)
	_gem_tick(s)

func _gem_collect(s:Variant)->void:
	var cursor:Vector2i=s.state.cursor
	if s.state.gems.has(cursor) and s.state.bag.size()<int(s.params.get("bag_capacity",5)):
		s.state.bag.append(s.state.gems[cursor])
		s.state.gems.erase(cursor)
		s.emit(&"gem_collected",{"cell":cursor,"bag_count":s.state.bag.size()})
	if cursor==s.state.gold_cell and not bool(s.state.gold_claimed) and not bool(s.state.gold_requested):
		s.state.gold_requested=true
		s.request_shared(&"gold_gem_claim",{"serial":s.state.gold_serial,"player":s.player_id})

func _gem_deposit(s:Variant)->void:
	if s.state.cursor!=Vector2i.ZERO or s.state.bag.is_empty():return
	var count:int=s.state.bag.size()
	s.add_score(count)
	s.state.bag=[]
	s.state.deposit_count+=1
	s.charge_send(&"sticky_tiles",{"duration_ms":int(s.params.get("sticky_ms",5000))},2)
	# A new shared challenge index gives the same replenishment positions on all devices.
	var refill:=Seeds.make_rng(s.rng.seed,["gem_refill",s.state.deposit_count])
	for serial:int in count:
		var cell:=Vector2i(refill.randi_range(1,6),refill.randi_range(1,6))
		var tries:int=0
		while s.state.gems.has(cell) and tries<49:
			cell=Vector2i((cell.x+1)%7,cell.y)
			tries+=1
		if cell!=Vector2i.ZERO:s.state.gems[cell]={"shape":&"mono","serial":int(s.state.deposit_count)*100+serial}
	s.emit(&"gem_deposited",{"count":count,"score":s.points})
	_gem_tick(s)

func _paint_start(s:Variant)->void:
	s.state.merge({"cursor":Vector2i.ZERO,"painted":{},"wet":{},"move_due":0})
	var faces:Array[Dictionary]=[]
	var voxels:Array[Vector3i]=[]
	for x:int in 7:
		for z:int in 7:
			voxels.append(Vector3i(x,0,z))
			faces.append({"key":"%d:0:%d:up"%[x,z],"cell":Vector3i(x,0,z),"normal":Vector3i.UP})
	var stencil:Dictionary={}
	for _face:int in mini(faces.size(),int(s.params.get("stencil_faces",12))):
		var index:int=s.rng.randi_range(0,faces.size()-1)
		stencil[faces[index].key]=faces[index]
		faces.remove_at(index)
	s.state.stencil=stencil
	s.view.merge({"island_size":Vector2i(7,7),"island_voxels":voxels,"stencil_faces":stencil.values(),"cursor":Vector2i.ZERO,"painted_faces":[]})
	_paint_score(s)

func _paint_move(s:Variant,args:Array)->void:
	if s.now_ms()<int(s.state.move_due):return
	var dir:Vector2i=_direction(args)
	if absi(dir.x)+absi(dir.y)!=1:return
	var cursor:Vector2i=s.state.cursor+dir
	if cursor.x<0 or cursor.y<0 or cursor.x>=7 or cursor.y>=7:return
	s.state.cursor=cursor
	s.state.move_due=s.now_ms()+100
	s.view["cursor"]=cursor
	_paint(s,[])

func _paint(s:Variant,_args:Array)->void:
	var cursor:Vector2i=s.state.cursor
	var key:String="%d:0:%d:up"%[cursor.x,cursor.y]
	if s.state.wet.has(key) and int(s.state.wet[key])>s.now_ms():return
	if not s.state.painted.has(key):
		s.state.painted[key]={"key":key,"cell":Vector3i(cursor.x,0,cursor.y),"normal":Vector3i.UP}
		s.charge_send(&"wet_paint",{"count":int(s.params.get("wet_faces",2)),"duration_ms":int(s.params.get("wet_ms",5000))},5)
		s.emit(&"voxel_face_painted",s.state.painted[key])
	_paint_score(s)

func _paint_score(s:Variant)->void:
	var correct:int=0
	for key:Variant in s.state.painted:
		if s.state.stencil.has(key):correct+=1
	var union:int=s.state.painted.size()+s.state.stencil.size()-correct
	var coverage:float=float(correct)/maxi(1,s.state.stencil.size())
	var accuracy:float=float(correct)/maxi(1,union)
	s.points=int(roundf(100.0*accuracy+50.0*coverage))
	s.progress=int(roundf(coverage*1000))
	s.view.merge({"painted_faces":s.state.painted.values(),"wet_faces":s.state.wet.duplicate(true),"accuracy":accuracy,"coverage":coverage,"score":s.points},true)
	if coverage>=1.0 and accuracy>=1.0:s.finish()

func _wet_paint(s:Variant,data:Dictionary)->void:
	var keys:Array=s.state.painted.keys()
	keys.sort()
	# At most ten percent of painted progress disappears from one send.
	var count:int=mini(int(data.get("count",s.params.get("wet_faces",2))),int(floorf(keys.size()*0.1)))
	var removed:Array=[]
	for index:int in count:
		s.state.painted.erase(keys[index])
		s.state.wet[keys[index]]=s.now_ms()+int(data.get("duration_ms",s.params.get("wet_ms",5000)))
		removed.append(keys[index])
	s.emit(&"wet_paint_removed",{"faces":removed,"until_ms":s.now_ms()+int(s.params.get("wet_ms",5000))})
	_paint_score(s)

func _balance_start(s:Variant)->void:
	s.state.merge({"offers":[],"selected":0,"left":[],"right":[],"left_mass":0,"right_mass":0,"surprise":0,"rack":0})
	_balance_offers(s)

func _balance_offers(s:Variant)->void:
	var pool:PackedStringArray=_pool(s,["standard","helper","chunky"])
	s.state.offers=[]
	for _offer:int in int(s.params.get("offer_count",3)):
		var piece:StringName=StringName(pool[s.rng.randi_range(0,pool.size()-1)])
		s.state.offers.append({"id":piece,"mass":s.catalog.shapes.get_shape(piece).cube_count})
	s.state.selected=0
	_balance_view(s)

func _balance_pan(s:Variant,args:Array)->void:
	if args.is_empty() or s.state.left.size()+s.state.right.size()>=int(s.params.get("rack_limit",8)):return
	var side:String=str(args[0])
	if not side in ["left","right"]:return
	var entry:Dictionary=s.state.offers[int(s.state.selected)].duplicate(true)
	entry["extra_mass"]=int(s.state.surprise)
	entry["mass"]=int(entry.mass)+int(s.state.surprise)
	s.state.surprise=0
	s.state[side].append(entry)
	s.state[side+"_mass"]=int(s.state[side+"_mass"])+int(entry.mass)
	s.emit(&"balance_piece_placed",{"pan":side,"piece":entry})
	_balance_offers(s)

func _balance_release(s:Variant)->void:
	var left:int=int(s.state.left_mass)
	var right:int=int(s.state.right_mass)
	if left<=0 or left!=right:
		s.emit(&"balance_unbalanced",{"left_mass":left,"right_mass":right});return
	s.add_score(1)
	s.state.rack+=1
	s.charge_send(&"surprise_weight",{"extra_mass":int(s.params.get("weight_surprise",2))},2)
	s.emit(&"balanced_rack",{"mass":left,"rack":s.state.rack})
	s.state.left=[];s.state.right=[];s.state.left_mass=0;s.state.right_mass=0
	s.progress=mini(1000,int(s.state.rack)*1000/maxi(1,int(s.params.get("balanced_goal",3))))
	if s.progress>=1000:s.finish()
	_balance_view(s)

func _balance_view(s:Variant)->void:
	var offers:Array=[]
	for entry:Dictionary in s.state.offers:
		var shown:Dictionary=entry.duplicate(true)
		shown["mass"]=int(shown.mass)+int(s.state.surprise)
		shown["surprise_mass"]=s.state.surprise
		offers.append(shown)
	s.view.merge({"piece_offers":offers,"selected_offer":s.state.selected,"left_pan":s.state.left.duplicate(true),"right_pan":s.state.right.duplicate(true),"left_mass":s.state.left_mass,"right_mass":s.state.right_mass,"racks":s.state.rack,"surprise_mass":s.state.surprise},true)
