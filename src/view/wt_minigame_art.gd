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
	"mg21":{"name":"Balance Budget","verb":"balance the load","prop":"balance_scales","color":"#A4B49C"}}
static var _materials: Dictionary={}

static func normalize(id: String) -> String:
	var value: String=id.to_lower().replace("_","").replace("-","")
	if value.begins_with("mg") and value.trim_prefix("mg").is_valid_int():return "mg%02d"%int(value.trim_prefix("mg"))
	if value=="cranetower":return "mg05"
	for key: String in THEMES:
		if str(THEMES[key].name).to_lower().replace(" ","")==value:return key
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
