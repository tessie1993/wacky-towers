import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
EXTRA=r'''
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
'''
source=(ROOT/"tools/godot-ai/rules_b_payload.txt").read_text()+EXTRA
source=source.replace('if e.kind == SimEvents.LAYER_CLEARED: layers += 1','if e.kind == SimEvents.LAYERS_CLEARED: layers += int(e.data.get("n_layers",1))')
source=source.replace('e.kind==SimEvents.BLOCK_CLEARED','e.kind==&"cube_cleared"')
source=source.replace('s.state.ghost=true\n\t\t\ts.state.ghost_due','s.state.ghost=true\n\t\t\ts.state["alive_ms"]=s.now_ms()\n\t\t\ts.state["ghost_effect"]="pump"\n\t\t\ts.become_ghost()\n\t\t\ts.state.ghost_due')
source=source.replace('{"width":4,"depth":4,"h_play":20}', '{"width":4,"depth":4,"h_play":20,"starting_contents":{"layers":{"0":["##..","##..","##..","##.."]}}}')
# Height ribbons trigger the same tested inventory/effects, with no fake item cube.
items=(ROOT/"src/mechanics/behaviour/items.gd").read_text()
start=items.index('\tvar context: Dictionary = api.item_context()',items.index('func _collect('))
end=items.index('\nfunc _command(',start)
body=items[start:end]
body=body.replace('"cell": ctx.data.get("cell", Vector3i.ZERO)','"cell": cell')
new='\t_award(api, ctx.data.get("cell", Vector3i.ZERO))\n\nfunc award_trigger(api: RuleApi) -> void:\n\tif _enabled:\n\t\t_award(api, Vector3i.ZERO)\n\nfunc _award(api: RuleApi, cell: Vector3i) -> void:\n'+body
actions=[{"tool":"script_patch","arguments":{"path":"res://src/mechanics/behaviour/items.gd","old_text":items[start:end],"new_text":new}},
{"tool":"script_create","arguments":{"path":"res://src/game/minigames/rules_b.gd","content":source}},
{"tool":"filesystem_manage","arguments":{"op":"scan","params":{}}}]
p=ROOT/"tools/godot-ai/jobs/minigames-rules-b-2.json.tmp"
p.write_text(json.dumps({"id":"minigames-rules-b-2","actions":actions}));p.rename(p.with_suffix(""))
print('queued RulesB bytes',len(source))
