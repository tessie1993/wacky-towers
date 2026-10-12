class_name WtMinigameArt extends RefCounted
## Original static toy landmarks for the reusable party library, not gameplay authority.
## Every model is generated here from primitive meshes; no outside character/logo assets.
const THEMES := {
	"mg01":{"name":"Hole in the Wall","verb":"rotate to fit","prop":"wall_gate","color":"#95B7BB"},
	"mg02":{"name":"Copycat","verb":"remember and rebuild","prop":"copy_frames","color":"#A799BB"},
	"mg03":{"name":"Colour Rush","verb":"match colours","prop":"colour_bubbles","color":"#D4A5B9"},
	"mg04":{"name":"Perfect Stack","verb":"time the drop","prop":"slide_rail","color":"#B3C68E"},
	"mg05":{"name":"Crane Tower","verb":"release the swinging piece","prop":"crane_hook","color":"#CAB68A"},
	"mg06":{"name":"Mascot Bridge Race","verb":"build a walkway","prop":"bridge_cliffs","color":"#B0C797"},
	"mg07":{"name":"Box Packers","verb":"pack without holes","prop":"open_crate","color":"#C4A781"},
	"mg08":{"name":"Gift Exchange","verb":"choose a gift","prop":"gift_boxes","color":"#CDA0AE"},
	"mg09":{"name":"Speed Sort","verb":"sort into three chutes","prop":"sorting_chutes","color":"#94B8C0"},
	"mg10":{"name":"Shadow Duel","verb":"match two silhouettes","prop":"shadow_panels","color":"#A69DB8"},
	"mg11":{"name":"Memory Tower","verb":"remember the hidden stack","prop":"memory_book","color":"#9EB3C2"},
	"mg12":{"name":"Spin Cycle","verb":"clear on a turntable","prop":"turntable_dial","color":"#B7AD87"},
	"mg13":{"name":"Floor Is Lava","verb":"outbuild the rising heat","prop":"ember_pool","color":"#C59B85"},
	"mg14":{"name":"Hot Block","verb":"pass the ticking cube","prop":"fused_chunk","color":"#BA99AF"},
	"mg15":{"name":"Catch Tower","verb":"catch on the moving tray","prop":"catch_tray","color":"#A8BD9C"},
	"mg16":{"name":"Rhythm","verb":"tap to the beat","prop":"rhythm_bells","color":"#B6A5C4"},
	"mg17":{"name":"Magnet","verb":"aim the magnetic pull","prop":"horseshoe_magnet","color":"#98B6C6"},
	"mg18":{"name":"Balloon","verb":"steer the floating blocks","prop":"balloon_bundle","color":"#D4B39E"},
	"mg19":{"name":"Gem Grab","verb":"collect the gems","prop":"gem_cluster","color":"#99BBB0"},
	"mg20":{"name":"Paint Dash","verb":"paint the target cells","prop":"brush_palette","color":"#C5B38A"},
	"mg21":{"name":"Balance Budget","verb":"balance the load","prop":"balance_scales","color":"#A4B49C"},
	"mg22":{"name":"Block Bowling","verb":"aim and spin","prop":"bowling_lane","color":"#B3A3C2"},
	"mg23":{"name":"Simon Stack","verb":"repeat the sequence","prop":"simon_pads","color":"#9FBFB4"},
	"mg24":{"name":"Quick Drop","verb":"react to the signal","prop":"signal_block","color":"#C9AE8F"},
	"mg25":{"name":"Cube Count","verb":"estimate the tower","prop":"counting_tower","color":"#A3B3C9"},
	"mg26":{"name":"Odd Block Out","verb":"spot the mirror twin","prop":"mirror_twins","color":"#C6A3A8"},
	"mg27":{"name":"Toy Pairs","verb":"match hidden pairs","prop":"pair_cards","color":"#B8BE93"},
	"mg28":{"name":"Block Dodge","verb":"dodge the rain","prop":"dodge_lanes","color":"#9DB0BF"},
	"mg29":{"name":"Slide Shuffle","verb":"solve the slide puzzle","prop":"slide_tray","color":"#C2B39A"},
	"mg30":{"name":"Mirror Mirror","verb":"paint the reflection","prop":"mirror_easel","color":"#A8A2C2"},
	"mg31":{"name":"Colour Count","verb":"tally the parade","prop":"parade_float","color":"#CFA89A"},
	"mg32":{"name":"Whack-a-Block","verb":"tap the pop-ups","prop":"whack_holes","color":"#A6C0A2"},
	"mg33":{"name":"Tower Pull","verb":"pull without toppling","prop":"pull_tower","color":"#C4AC8C"},
	"mg34":{"name":"Spin Match","verb":"orient in few turns","prop":"spin_turntable","color":"#9EB9C6"},
	"mg35":{"name":"Plinko Drop","verb":"drop for the buckets","prop":"plinko_board","color":"#C7A7BC"},
	"mg36":{"name":"Treasure Dig","verb":"deduce the dig site","prop":"dig_patch","color":"#B9A98A"}}
static var _materials: Dictionary={}

static func normalize(id: String) -> String:
	var value: String=id.to_lower().replace("_","").replace("-","")
	if value.begins_with("mg") and value.trim_prefix("mg").is_valid_int():
		var numbered: String="mg%02d"%int(value.trim_prefix("mg"))
		return numbered if THEMES.has(numbered) else "mg01"
	if value=="cranetower":return "mg05"
	value=value.replace(" ","")
	for key: String in THEMES:
		if str(THEMES[key].name).to_lower().replace(" ","").replace("-","").replace("_","")==value:return key
	return "mg01"

static func themes() -> Dictionary:
	return THEMES.duplicate(true)

static func create(id: String) -> Node3D:
	var key: String=normalize(id);var theme: Dictionary=THEMES[key]
	var root:=Node3D.new();root.name="OriginalPartyToy_"+key
	root.set_meta("minigame_id",key);root.set_meta("asset_id","party_"+key+"_"+str(theme.prop));root.set_meta("provenance","Original primitive-mesh source in WtMinigameArt")
	var color:=Color(theme.color);var cream:=Color("#ECE1CB");var wood:=Color("#B29B7D");var ink:=Color("#52606A")
	_cylinder(root,Vector3(0,-.09,0),1.7,1.5,.18,color.darkened(.08),16)
	match key:
		"mg01":
			for x: int in 4:
				for y: int in 4:
					if (x in [1,2] and y in [1,2]):continue
					_box(root,Vector3((x-1.5)*.55,.31+y*.55,0),Vector3.ONE*.5,color)
			_box(root,Vector3(0,1.14,.46),Vector3(.47,.98,.47),cream)
			_box(root,Vector3(.47,.9,.46),Vector3(.47,.47,.47),cream)
		"mg02":
			for side: float in [-1,1]:
				_frame(root,Vector3(side*.87,.95,0),Vector2(1.25,1.8),wood)
				for i: int in 3:_box(root,Vector3(side*.87+(i%2)*.36-.18,.3+(i/2)*.52,.15),Vector3.ONE*.46,color if side<0 else cream)
		"mg03":
			for i: int in 5:_ball(root,Vector3((i%3-1)*.68,.45+(i/3)*.7,0),.38,[color,Color("#D3B37D"),Color("#99C2B0"),Color("#A2B5CE"),color][i])
		"mg04":
			for side: float in [-1,1]:_box(root,Vector3(0,.2,side*.65),Vector3(2.8,.08,.08),wood)
			for i: int in 4:_box(root,Vector3(sin(i)*.15,.4+i*.42,0),Vector3(1.35,.36,1.1),color.lightened(i*.05))
		"mg05":
			_box(root,Vector3(-1.05,1.45,0),Vector3(.14,2.9,.14),wood);_box(root,Vector3(0,2.83,0),Vector3(2.45,.14,.14),wood)
			_cylinder(root,Vector3(.5,2.18,0),.025,.025,1.2,wood,7);_ring(root,Vector3(.5,1.58,0),.1,.17,ink,Vector3(PI*.5,0,0))
			_box(root,Vector3(.5,1.18,0),Vector3(.7,.6,.6),color)
		"mg06":
			for side: float in [-1,1]:_box(root,Vector3(side*1.15,.36,0),Vector3(.75,.7,1.3),color)
			for i: int in 7:_box(root,Vector3((i-3)*.3,.8,0),Vector3(.27,.12,.7),wood)
			for z: float in [-.42,.42]:_box(root,Vector3(0,1.23,z),Vector3(2.65,.045,.045),cream)
		"mg07":
			_box(root,Vector3(0,.12,0),Vector3(1.9,.24,1.7),wood)
			for side: float in [-1,1]:
				_box(root,Vector3(side*.89,.68,0),Vector3(.12,1.2,1.7),wood);_box(root,Vector3(0,.68,side*.79),Vector3(1.7,1.2,.12),wood)
			for i: int in 3:_box(root,Vector3((i-1)*.52,.46,0),Vector3.ONE*.49,color)
		"mg08":
			for i: int in 3:
				var p:=Vector3((i-1)*.8,.5,(i%2)*.2)
				_box(root,p,Vector3(.7,.85,.7),color.lightened(i*.06));_box(root,p,Vector3(.09,.91,.73),cream)
				_ring(root,p+Vector3(.1,.54,0),.1,.16,cream,Vector3(0,0,.4))
		"mg09":
			for i: int in 3:
				var c: Color=[Color("#CB9CAA"),Color("#ADA0C3"),Color("#99BFA7")][i]
				_box(root,Vector3((i-1)*.84,.35,0),Vector3(.68,.7,.75),c);_box(root,Vector3((i-1)*.84,1.26,0),Vector3(.13,1.1,.5),cream)
			_box(root,Vector3(0,1.92,0),Vector3(.55,.55,.5),Color("#D4BB80"))
		"mg10":
			for side: float in [-1,1]:
				_frame(root,Vector3(side*.82,1.2,-.25),Vector2(1.2,2.0),wood)
				for i: int in 3:_box(root,Vector3(side*.82+(i%2)*.35-.18,.6+(i/2)*.36,-.23),Vector3(.32,.32,.035),ink)
			_box(root,Vector3(0,.45,.5),Vector3(.43,.83,.43),color)
		"mg11":
			for side: float in [-1,1]:
				var leaf: MeshInstance3D=_box(root,Vector3(side*.5,.36,0),Vector3(.95,.1,1.3),cream);leaf.rotation.z=side*.16
			for i: int in 3:_box(root,Vector3(0,.6+i*.47,0),Vector3.ONE*.42,color.lightened(i*.14))
			_ball(root,Vector3(-.5,2.08,0),.29,cream);_ball(root,Vector3(0,2.15,0),.35,cream);_ball(root,Vector3(.48,2.08,0),.28,cream)
		"mg12":
			_cylinder(root,Vector3(0,.23,0),1.1,1.2,.38,wood,16);_ring(root,Vector3(0,.46,0),.92,1.1,color)
			for i: int in 4:_box(root,Vector3((i%2-.5)*.6,.73,(i/2-.5)*.6),Vector3.ONE*.53,color.lightened(i*.05))
			_box(root,Vector3(0,.55,1.07),Vector3(.18,.09,.38),cream)
		"mg13":
			_cylinder(root,Vector3(0,.14,0),1.28,1.45,.22,Color("#C59677"),16)
			for i: int in 4:_box(root,Vector3((i%2-.5)*.55,.57+(i/2)*.45,0),Vector3.ONE*.5,Color("#969889"))
			for i: int in 6:_ball(root,Vector3(cos(i)*1.1,.27,sin(i)*1.1),.12,cream)
		"mg14":
			for x: int in 2:
				for y: int in 2:
					for z: int in 2:_box(root,Vector3((x-.5)*.56,.45+y*.56,(z-.5)*.56),Vector3.ONE*.5,color)
			_cylinder(root,Vector3(0,1.45,0),.04,.045,.6,wood,7);_ball(root,Vector3(.08,1.74,0),.12,Color("#D9B575"))
		"mg15":
			_box(root,Vector3(0,.22,0),Vector3(2.4,.2,1.2),wood)
			for side: float in [-1,1]:_box(root,Vector3(side*1.12,.5,0),Vector3(.12,.4,1.2),color)
			_box(root,Vector3(0,1.8,0),Vector3(.6,.6,.6),color);_box(root,Vector3(.6,1.5,0),Vector3(.6,.6,.6),color)
		"mg16":
			for i: int in 3:
				_cylinder(root,Vector3((i-1)*.7,.48,0),.23,.34,.64,color.lightened(i*.1),12)
				_ball(root,Vector3((i-1)*.7,.9,0),.085,wood)
			_box(root,Vector3(0,1.7,0),Vector3(.035,1.2,.035),wood);_ball(root,Vector3(.3,2.2,0),.12,cream)
		"mg17":
			for i: int in 12:
				var a: float=PI+i*PI/11
				_ball(root,Vector3(cos(a)*.78,1.4+sin(a)*.78,0),.22,color)
			for side: float in [-1,1]:_box(root,Vector3(side*.78,1.68,0),Vector3(.4,.6,.45),Color("#C49AAA") if side<0 else Color("#9DAFCB"))
		"mg18":
			for i: int in 3:
				var p:=Vector3((i-1)*.55,1.7+(i%2)*.42,0)
				_ball(root,p,.4,color.lightened(i*.07),Vector3(1,1.17,1));_cylinder(root,p-Vector3(0,.68,0),.017,.017,.9,wood,6)
			_box(root,Vector3(0,.35,0),Vector3(.8,.55,.65),cream)
		"mg19":
			for i: int in 4:
				var p:=Vector3((i%2-.5)*.88,.53+(i/2)*.6,(i/2-.5)*.5)
				_cylinder(root,p+Vector3(0,.16,0),0,.3,.4,color.lightened(i*.07),5)
				_cylinder(root,p-Vector3(0,.19,0),.3,0,.32,color.darkened(.05),5)
		"mg20":
			var palette: MeshInstance3D=_ball(root,Vector3(0,.23,0),1.08,wood,Vector3(1,.16,.75))
			for i: int in 4:_ball(root,Vector3((i-1.5)*.45,.38,0),.18,[color,Color("#B499C0"),Color("#9EBDB0"),Color("#CDA0AF")][i],Vector3(1,.28,1))
			var brush: Node3D=Node3D.new();root.add_child(brush);brush.position=Vector3(.65,1.05,0);brush.rotation.z=-.55
			_cylinder(brush,Vector3.ZERO,.07,.09,1.3,wood,8);_box(brush,Vector3(0,.69,0),Vector3(.34,.42,.18),color)
		"mg21":
			_cylinder(root,Vector3(0,.8,0),.07,.1,1.6,wood,9);_box(root,Vector3(0,1.58,0),Vector3(2.4,.08,.08),wood)
			for side: float in [-1,1]:
				_cylinder(root,Vector3(side*1.0,1.18,0),.02,.02,.8,cream,6);_cylinder(root,Vector3(side*1.0,.76,0),.5,.36,.14,color,12)
				for i: int in (2 if side<0 else 1):_box(root,Vector3(side*1.0,.96+i*.26,0),Vector3(.33,.24,.33),cream)
		"mg22":
			_box(root,Vector3(0,.06,0),Vector3(1.05,.12,2.9),wood.lightened(.12))
			for side: float in [-1,1]:_box(root,Vector3(side*.62,.1,0),Vector3(.16,.2,2.9),color.darkened(.12))
			for row: int in 4:
				for k: int in row+1:
					var pin:=Vector3((k-row*.5)*.24,.27,-.55-row*.24)
					_box(root,pin,Vector3(.17,.3,.17),cream);_box(root,pin+Vector3(0,.05,0),Vector3(.18,.05,.18),color)
			var bowl: MeshInstance3D=_box(root,Vector3(.12,.35,1.0),Vector3.ONE*.42,color);bowl.rotation.y=.45
			for i: int in 4:_ball(root,Vector3(.12-sin(i*.5)*.2,.16,.6-i*.3),.05,cream)
		"mg23":
			var hues: Array[Color]=[Color("#CF9F9F"),Color("#9DB4CF"),Color("#A2C6A4"),Color("#D7C488")]
			_cylinder(root,Vector3(0,.12,0),1.35,1.4,.24,cream,16)
			for i: int in 4:
				var lit: bool=i==2;var p:=Vector3((i%2-.5)*1.15,.3+(.1 if lit else 0.0),(i/2-.5)*1.15)
				_cylinder(root,p,.46,.5,.14,hues[i].lightened(.25) if lit else hues[i],14)
				if lit:_ring(root,p+Vector3(0,.04,0),.5,.6,cream)
				for h: int in (2 if lit else 1):_box(root,p+Vector3(0,.25+h*.3,0),Vector3.ONE*.28,hues[i].darkened(.1))
			_cylinder(root,Vector3(0,.42,0),.12,.16,.28,wood,10);_ball(root,Vector3(0,.62,0),.14,color)
		"mg24":
			_box(root,Vector3(0,1.05,-.1),Vector3(.86,1.9,.6),ink.lightened(.15))
			var lamps: Array[Color]=[Color("#B78E8E"),Color("#C8B07E"),Color("#9FE0A8")]
			for i: int in 3:
				var y: float=1.65-i*.58
				_ball(root,Vector3(0,y,.2),.24 if i==2 else .2,lamps[i].lightened(.2) if i==2 else lamps[i].darkened(.15),Vector3(1,1,.55))
				_box(root,Vector3(0,y+.26,.3),Vector3(.5,.05,.22),ink)
			_box(root,Vector3(0,2.21,-.1),Vector3.ONE*.42,color)
			_cylinder(root,Vector3(.72,.12,.6),.26,.3,.16,color,14);_cylinder(root,Vector3(.72,.24,.6),.18,.2,.1,Color("#D7B07E"),14)
		"mg25":
			_box(root,Vector3(0,.05,0),Vector3(1.85,.1,1.85),cream)
			var heights: Array[int]=[3,2,2,1,2,2,1,0,1,1,0,0,1,0,0,0]
			for c: int in 16:
				for h: int in heights[c]:_box(root,Vector3((c%4-1.5)*.42,.31+h*.42,(c/4-1.5)*.42),Vector3.ONE*.4,color.lightened(h*.1))
			_box(root,Vector3(1.15,.6,.95),Vector3(.06,1.2,.06),wood);_box(root,Vector3(1.15,1.2,.95),Vector3(.3,.06,.06),wood)
			for i: int in 4:_ball(root,Vector3(1.15,.25+i*.2,.95),.09,[color,cream,color,cream][i],Vector3(1.3,.8,1.3))
		"mg26":
			var cells: Array[Vector3]=[Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0),Vector3(1,1,1)]
			for i: int in 4:
				var odd: bool=i==3;var copy:=Node3D.new();root.add_child(copy)
				copy.position=Vector3((i%2-.5)*1.25,.2+(.27 if odd else 0.0),(i/2-.5)*1.25);copy.rotation.y=i*PI*.5
				if odd:
					_cylinder(root,copy.position-Vector3(0,.22,0),.48,.52,.2,cream,14);_ring(root,copy.position-Vector3(0,.1,0),.46,.56,Color("#D7B07E"))
				for c: Vector3 in cells:
					var v:=Vector3(c.x-.5,c.y,c.z-.5)
					if odd:v.x=-v.x
					_box(copy,v*.33,Vector3.ONE*.31,color.lightened(.2) if odd else color)
		"mg27":
			_box(root,Vector3(0,.06,0),Vector3(2.1,.12,2.1),wood)
			for i: int in 16:
				if i==7:continue
				var p:=Vector3((i%4-1.5)*.5,.15,(i/4-1.5)*.5);var up: bool=i in [5,10]
				_box(root,p,Vector3(.4,.05,.44),cream if up else color)
				if up:_box(root,p+Vector3(0,.15,0),Vector3.ONE*.2,Color("#C49AAA"))
				else:_box(root,p+Vector3(0,.03,0),Vector3(.12,.01,.12),color.lightened(.25))
			var flip: MeshInstance3D=_box(root,Vector3(.75,.6,-.25),Vector3(.4,.05,.44),color);flip.rotation=Vector3(.2,0,1.1)
		"mg28":
			for lane: int in 5:_box(root,Vector3((lane-2)*.5,.05,0),Vector3(.47,.1,2.4),cream if lane%2==0 else color.lightened(.25))
			for drop: Vector3 in [Vector3(-1,1.5,-.3),Vector3(.5,2.05,.35)]:
				_ball(root,Vector3(drop.x,.11,drop.z),.22,ink,Vector3(1,.05,1));_box(root,drop,Vector3.ONE*.4,color)
			_cylinder(root,Vector3(0,.32,.7),.16,.2,.42,Color("#D7B07E"),12);_ball(root,Vector3(0,.66,.7),.16,cream)
		"mg29":
			var tray:=Node3D.new();root.add_child(tray);tray.position=Vector3(0,1.0,0);tray.rotation.x=1.05
			_box(tray,Vector3.ZERO,Vector3(1.85,.12,1.85),wood)
			for side: float in [-1,1]:
				_box(tray,Vector3(side*.95,.1,0),Vector3(.08,.16,1.95),wood.darkened(.15));_box(tray,Vector3(0,.1,side*.95),Vector3(1.95,.16,.08),wood.darkened(.15))
			for t: int in 8:
				var tile: MeshInstance3D=_box(tray,Vector3((t%3-1)*.56+(.14 if t==7 else 0.0),.12,(t/3-1)*.56),Vector3(.52,.12,.52),color.lightened((t%2)*.18))
				if t in [1,3,4,5]:_box(tray,tile.position+Vector3(0,.08,0),Vector3(.24,.04,.24),cream)
			var strut: MeshInstance3D=_box(root,Vector3(0,.55,-.32),Vector3(.12,1.1,.1),wood);strut.rotation.x=.3
		"mg30":
			for leg: Vector3 in [Vector3(-.7,0,.25),Vector3(.7,0,.25),Vector3(0,0,-.5)]:
				var stick: MeshInstance3D=_cylinder(root,Vector3(leg.x,1.0,leg.z),.04,.05,2.0,wood,7);stick.rotation=Vector3(-leg.z*.25,0,leg.x*.12)
			var easel:=Node3D.new();root.add_child(easel);easel.position=Vector3(0,1.35,.12);easel.rotation.x=-.15
			_box(easel,Vector3.ZERO,Vector3(1.9,1.25,.08),cream);_box(easel,Vector3(0,0,.06),Vector3(.04,1.25,.04),ink)
			var half: Array[Vector2i]=[Vector2i(0,0),Vector2i(1,1),Vector2i(2,1),Vector2i(1,2),Vector2i(0,3),Vector2i(2,4)]
			for cell: Vector2i in half:
				for side: float in [-1,1]:_box(easel,Vector3(side*(.12+(2-cell.x)*.19),.4-cell.y*.2,.06),Vector3(.17,.17,.03),color if side<0 else color.darkened(.18))
			_box(root,Vector3(0,.7,.32),Vector3(1.7,.05,.18),wood)
		"mg31":
			_box(root,Vector3(0,.45,0),Vector3(2.0,.18,1.0),wood)
			for wx: float in [-.7,.7]:
				for wz: float in [-.52,.52]:
					var wheel: MeshInstance3D=_cylinder(root,Vector3(wx,.22,wz),.22,.22,.09,ink,12);wheel.rotation.x=PI*.5
			var parade: Array[Color]=[color,Color("#9DB4CF"),color,Color("#A2C6A4"),Color("#D7C488")]
			for i: int in 5:_box(root,Vector3((i-2)*.38,.72+(i%2)*.1,0),Vector3.ONE*.34,parade[i])
			_cylinder(root,Vector3(-.85,1.25,.3),.025,.025,1.4,wood,6);_box(root,Vector3(-.65,1.75,.3),Vector3(.38,.24,.03),color.lightened(.2))
			for i: int in 7:_ball(root,Vector3((i-3)*.3,.58,.52),.06,[cream,color][i%2])
		"mg32":
			_box(root,Vector3(0,.2,0),Vector3(2.2,.4,2.2),wood)
			for i: int in 9:
				var p:=Vector3((i%3-1)*.66,.41,(i/3-1)*.66)
				_cylinder(root,p,.24,.24,.02,ink,14);_ring(root,p,.22,.3,wood.lightened(.15))
				if i==4:_box(root,p+Vector3(0,.25,0),Vector3(.36,.46,.36),color)
				if i==2:_box(root,p+Vector3(0,.08,0),Vector3(.32,.16,.32),Color("#D7B575"))
			var mallet:=Node3D.new();root.add_child(mallet);mallet.position=Vector3(.45,1.35,.1);mallet.rotation.z=.75
			_cylinder(mallet,Vector3.ZERO,.05,.06,1.0,wood,8);var head: MeshInstance3D=_cylinder(mallet,Vector3(0,.55,0),.2,.2,.5,cream,12);head.rotation.z=PI*.5
		"mg33":
			for layer: int in 9:
				for slot: int in 3:
					var offset: float=(slot-1)*.32;var p:=Vector3(offset,.14+layer*.29,0) if layer%2==0 else Vector3(0,.14+layer*.29,offset)
					if layer==4 and slot==2:p.z+=.38
					_box(root,p,Vector3(.3,.27,.94) if layer%2==0 else Vector3(.94,.27,.3),wood.lightened(.08) if (layer+slot)%2==0 else color)
		"mg34":
			_cylinder(root,Vector3(0,.18,0),1.25,1.3,.3,wood,18);_ring(root,Vector3(0,.34,0),1.08,1.25,color.darkened(.05))
			var tri: Array[Vector3]=[Vector3(0,0,0),Vector3(1,0,0),Vector3(0,1,0)]
			for side: float in [-1,1]:
				var shape:=Node3D.new();root.add_child(shape);shape.position=Vector3(side*.55,.55 if side<0 else .75,0);shape.rotation=Vector3.ZERO if side<0 else Vector3(0,PI*.5,PI*.5)
				for c: Vector3 in tri:_box(shape,c*.34-Vector3(.17,0,0),Vector3.ONE*.32,cream if side<0 else color)
			for i: int in 5:_ball(root,Vector3(.55+cos(i*.55)*.62,.42,sin(i*.55)*.62),.06,cream)
		"mg35":
			_box(root,Vector3(0,1.3,-.1),Vector3(2.3,2.4,.12),cream)
			for side: float in [-1,1]:_box(root,Vector3(side*1.18,1.3,0),Vector3(.1,2.5,.32),wood)
			for row: int in 6:
				for col: int in (7 if row%2==0 else 6):
					var peg: MeshInstance3D=_cylinder(root,Vector3((col-(3.0 if row%2==0 else 2.5))*.3,2.15-row*.27,.02),.035,.035,.14,ink,6);peg.rotation.x=PI*.5
			for b: int in 8:_box(root,Vector3((b-3.5)*.3,.37,.03),Vector3(.04,.42,.16),wood)
			for b: int in 7:_box(root,Vector3((b-3)*.3,.19,.03),Vector3(.26,.06,.14),Color("#D7B575") if b==3 else color.lightened(absi(b-3)*.08))
			_box(root,Vector3(.3,2.62,.04),Vector3.ONE*.24,color)
		"mg36":
			var dirt:=Color("#A88B6E")
			_cylinder(root,Vector3(0,.12,0),1.3,1.45,.24,dirt,16)
			for i: int in 6:_ball(root,Vector3(cos(i*1.1)*.75,.26,sin(i*1.1)*.75),.18,dirt.lightened(.08),Vector3(1,.45,1))
			_cylinder(root,Vector3(-.35,.24,.35),.22,.22,.02,ink,12);_cylinder(root,Vector3(.25,.24,.6),.18,.18,.02,ink,12)
			for x: float in [-.25,.07]:_box(root,Vector3(x,.3,-.25),Vector3(.3,.18,.3),Color("#D7B575"))
			for peg: Vector3 in [Vector3(-.75,.4,.1),Vector3(.75,.4,-.3)]:
				_cylinder(root,peg,.03,.03,.36,wood,6);_ball(root,peg+Vector3(0,.2,0),.07,color if peg.x<0 else Color("#9DB4CF"))
			var shovel:=Node3D.new();root.add_child(shovel);shovel.position=Vector3(.55,.75,.15);shovel.rotation=Vector3(.2,0,-.45)
			_cylinder(shovel,Vector3(0,.25,0),.04,.05,1.1,wood,8);_box(shovel,Vector3(0,.88,0),Vector3(.28,.06,.06),wood)
			_box(shovel,Vector3(0,-.42,0),Vector3(.36,.4,.05),Color("#A2ABB2"))
	return root

static func asset_manifest() -> Array[Dictionary]:
	var assets: Array[Dictionary]=[]
	for id: String in THEMES:
		assets.append({"id":"party_"+id+"_"+str(THEMES[id].prop),"minigame":id,"role":"Original toy landmark and verb cue","factory":"res://src/view/wt_minigame_art.gd::create("+id+")","geometry":"Primitive-mesh source; no external GLB or painted texture","remaining":"Final painted/rigged art and manual phone readability polish"})
	return assets

static func _material(color: Color) -> Material:
	if not _materials.has(color):
		var material:=StandardMaterial3D.new();material.albedo_color=color;material.roughness=.9;_materials[color]=material
	return _materials[color]
static func _mesh(parent: Node3D, mesh: Mesh,position: Vector3,color: Color) -> MeshInstance3D:
	var node:=MeshInstance3D.new();node.mesh=mesh;node.position=position;node.material_override=_material(color);node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(node);return node
static func _box(parent: Node3D,p: Vector3,size: Vector3,color: Color) -> MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size;return _mesh(parent,mesh,p,color)
static func _ball(parent: Node3D,p: Vector3,radius: float,color: Color,scale: Vector3=Vector3.ONE) -> MeshInstance3D:
	var mesh:=SphereMesh.new();mesh.radius=radius;mesh.height=radius*2;mesh.radial_segments=12;mesh.rings=6
	var node:=_mesh(parent,mesh,p,color);node.scale=scale;return node
static func _cylinder(parent: Node3D,p: Vector3,top: float,bottom: float,height: float,color: Color,sides: int) -> MeshInstance3D:
	var mesh:=CylinderMesh.new();mesh.top_radius=top;mesh.bottom_radius=bottom;mesh.height=height;mesh.radial_segments=sides;return _mesh(parent,mesh,p,color)
static func _ring(parent: Node3D,p: Vector3,inner: float,outer: float,color: Color,rotation: Vector3=Vector3.ZERO) -> MeshInstance3D:
	var mesh:=TorusMesh.new();mesh.inner_radius=inner;mesh.outer_radius=outer;mesh.rings=16;mesh.ring_segments=6
	var node:=_mesh(parent,mesh,p,color);node.rotation=rotation;return node
static func _frame(parent: Node3D,p: Vector3,size: Vector2,color: Color) -> void:
	for side: float in [-1,1]:_box(parent,p+Vector3(side*size.x*.5,0,0),Vector3(.07,size.y,.07),color)
	for side: float in [-1,1]:_box(parent,p+Vector3(0,side*size.y*.5,0),Vector3(size.x,.07,.07),color)
