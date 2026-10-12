class_name WtToyActor extends Node3D
## Original procedural toy cast. Shared pose grammar; geometry is not gameplay collision.

var actor_id: StringName
var _body: Node3D
var _eyes_nodes: Array[MeshInstance3D] = []
var _bubble: Label3D
var _materials: Dictionary = {}
var _pose: StringName = &"idle"
var _reaction: float = 0.0
var _clock: float = 0.0
var _reduced: bool = false
var _base_scale: Vector3 = Vector3.ONE
var _behaviour: BeehaveTree
var _requests: Array[Dictionary] = []


func setup(id: StringName, accent: Color = Color("#A897BD")) -> void:
	actor_id=id
	_body=Node3D.new();_body.name="ToyPose";add_child(_body)
	match str(id):
		"cloud": _cloud(accent)
		"mizzle": _mizzle()
		"lana": _lana(accent)
		"boulder": _boulder(accent)
		"glim": _glim(accent)
		"pip": _mouse()
		"mallow": _bunny()
		"pebble": _penguin()
		"puff": _fish()
		"cinder", "smolder": _dragon(id==&"smolder")
		"chip": _beaver()
		"nugget": _mole()
		"tock": _duck()
		"glitch": _cat()
		"comet": _fox()
		"miller": _badger()
		"meringue": _meringue()
		"sniffles": _yeti()
		"crab": _crab()
		"oak": _oak()
		"geode": _golem()
		"cuckoo": _clockwork()
		"mirrorball": _disco()
		"moon": _moon()
		_: _cloud(accent)
	_bubble=Label3D.new();_bubble.position=Vector3(0,2.5,0);_bubble.font_size=56
	_bubble.pixel_size=.007;_bubble.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.modulate=Color("#344451");_bubble.outline_modulate=Color("#FBF6E6");_bubble.outline_size=10
	add_child(_bubble)
	_apply_pose(&"idle")
	_build_behaviour()


func _build_behaviour() -> void:
	_behaviour=BeehaveTree.new();_behaviour.name="ToyBehaviour";_behaviour.actor=self
	var selector:=SelectorReactiveComposite.new();selector.name="ReactOrIdle"
	var sequence:=SequenceComposite.new();sequence.name="EventReaction"
	var condition:=WtToyReactionCondition.new();condition.name="HasReaction"
	var action:=WtToyBehaviourAction.new();action.name="React";action.reacting=true
	sequence.add_child(condition);sequence.add_child(action);selector.add_child(sequence)
	var idle:=WtToyBehaviourAction.new();idle.name="QuietAmbientPose";selector.add_child(idle)
	_behaviour.add_child(selector);add_child(_behaviour)


func set_reduced_motion(value: bool) -> void:
	_reduced=value


func set_pose(pose: StringName) -> void:
	_requests.append({"pose":pose})


func _apply_pose(pose: StringName) -> void:
	_pose=pose
	if _body==null:return
	_body.rotation=Vector3.ZERO
	_body.position=Vector3.ZERO
	_body.scale=Vector3.ONE
	match pose:
		&"sleep": _body.rotation.z=PI*.38
		&"peek": _body.rotation.y=-.55;_body.rotation.z=.14
		&"look_up": _body.rotation.x=-.15
		&"give",&"invite",&"cast": _body.rotation.x=-.08;_body.rotation.z=-.12
		&"flee": _body.rotation.y=1.6;_body.rotation.z=.2
		&"bonk",&"dismay": _body.rotation.z=.22;_body.scale=Vector3(1.08,.87,1.08)
		&"sit",&"wait": _body.scale.y=.85
		&"glasses",&"doodle": _body.rotation.x=.08;_body.rotation.z=-.10
		&"inflate": _body.scale=Vector3.ONE*1.18
		&"cheer",&"wave",&"dance": _body.rotation.z=-.12
		_:pass
	_base_scale=_body.scale


func react(emote: StringName, seconds: float = 1.0, reduced: bool = false) -> void:
	_requests.append({"emote":emote,"seconds":seconds,"reduced":reduced})


func behaviour_pending() -> bool:
	return not _requests.is_empty() or _reaction>0.0


func behaviour_pose() -> String:
	return str(_pose)


func behaviour_step(delta: float) -> void:
	_clock+=delta
	while not _requests.is_empty():
		var request: Dictionary=_requests.pop_front()
		if request.has("pose"):
			_apply_pose(request.pose)
		else:
			_reaction=float(request.seconds);_reduced=bool(request.reduced)
			var emote: StringName=request.emote
			var glyphs: Dictionary={"heart":"♥","exclaim":"!","question":"?","dots":"…","sweat":"∿","sparkle":"✦","idea":"!","dizzy":"★","note":"♪","gloom":"☁","angry":"!","smug":"⌣","tear":"•","blush":"♥","gift":"◇","invite":"✉","sleep":"z"}
			if _bubble!=null:_bubble.text=str(glyphs.get(str(emote),""))
			_apply_pose(&"bonk" if emote==&"dizzy" else (&"cheer" if emote in [&"heart",&"sparkle"] else (&"look_up" if emote==&"question" else _pose)))
	if _reaction>0.0:
		_reaction-=delta
		if not _reduced and _body!=null:_body.position.y=absf(sin(_clock*5.0))*.08
		if _reaction<=0.0:
			_bubble.text="";_apply_pose(&"idle")
	elif _body!=null and not _reduced:
		_body.position.y=sin(_clock*1.5)*.025


func _cloud(accent: Color) -> void:
	for i: int in 4:_ball(Vector3((i-1.5)*.35,.12,0),.43,Color("#F4F1E7"),Vector3(1,.6,.9))
	_ball(Vector3(0,.55,0),.43,accent,Vector3(.95,1.2,.9))
	_ball(Vector3(0,1.02,.15),.28,Color("#ECCCAD"))
	_ball(Vector3(0,.82,.34),.27,Color("#F5EBD7"),Vector3(1,.95,.42))
	_tube(Vector3(0,1.43,0),.025,.45,.8,Color("#86769C"),12)
	_tube(Vector3(0,1.04,0),.5,.5,.075,Color("#827093"),12)
	_eyes(Vector3(0,1.06,.415),.085,.036)
	var wand:=_tube(Vector3(-.49,.76,.15),.025,.025,.58,Color("#91785D"),7);wand.rotation.z=-.5
	_ball(Vector3(-.63,1.02,.15),.075,Color("#E8D1A0"))


func _mizzle() -> void:
	_tube(Vector3(0,.72,0),.18,.32,1.18,Color("#7E6496"),10)
	_ball(Vector3(0,1.5,.04),.23,Color("#DECAB8"),Vector3(.9,1.1,.9))
	var hat:=_tube(Vector3(-.06,1.92,0),.035,.27,.77,Color("#78608E"),10);hat.rotation.z=.17
	var hook:=_tube(Vector3(-.28,2.22,0),.025,.13,.5,Color("#78608E"),8);hook.rotation.z=1.35
	_ball(Vector3(-.51,2.22,0),.055,Color("#B8A878"))
	for side: float in [-1,1]:
		var rim:=TorusMesh.new();rim.inner_radius=.091;rim.outer_radius=.117;rim.rings=16;rim.ring_segments=6
		var lens:=_mesh(rim,Vector3(side*.115,1.53,.25),Color("#E3D3A0"));lens.rotation.x=PI*.5
		_ball(Vector3(side*.115,1.53,.256),.075,Color("#788291"),Vector3(1,1,.12))
	_eyes(Vector3(0,1.53,.27),.11,.025)
	_tube(Vector3(0,1.22,.06),.23,.23,.18,Color("#E8DCC4"),10)
	_box(Vector3(.34,.53,.05),Vector3(.33,.39,.22),Color("#97836B"))
	for side: float in [-1,1]:_ball(Vector3(side*.12,.1,.1),.13,Color("#746858"),Vector3(1,.55,1.5))


func _lana(accent: Color) -> void:
	_ball(Vector3(0,.65,0),.48,Color("#F2E8D8"),Vector3(1.1,1.1,.9))
	_tube(Vector3(0,1.34,0),.17,.23,1.1,Color("#D8C6A8"),10)
	_ball(Vector3(0,1.92,.02),.31,Color("#C9A27E"),Vector3(.82,1.1,1))
	_ball(Vector3(0,1.98,.27),.19,Color("#DCC4A8"),Vector3(1,.75,.75))
	for side: float in [-1,1]:
		_ball(Vector3(side*.19,2.2,0),.105,Color("#E7D8C1"),Vector3(.6,1.7,.8))
		_tube(Vector3(side*.27,.26,0),.08,.1,.5,Color("#C9A27E"),8)
		var needle:=_tube(Vector3(side*.07,2.28,.02),.015,.015,.6,Color("#877A65"),6);needle.rotation.z=side*.6
	_tube(Vector3(0,1.15,0),.22,.24,.2,Color("#9AB08A"),10)
	_ball(Vector3(.56,.12,.12),.19,accent)
	_eyes(Vector3(0,2.0,.285),.095,.027)


func _boulder(accent: Color) -> void:
	_ball(Vector3(0,.6,0),.57,Color("#8E7A82"),Vector3(1.35,.85,.92))
	_ball(Vector3(0,.75,.33),.37,Color("#D8A8A0"),Vector3(1.35,.8,.7))
	_ball(Vector3(0,1.05,.05),.39,Color("#95818A"),Vector3(1.15,.8,1))
	for side: float in [-1,1]:
		_ball(Vector3(side*.31,1.28,0),.105,Color("#A08B90"))
		_ball(Vector3(side*.42,.2,.04),.19,Color("#897780"),Vector3(.9,1.1,.9))
	_ball(Vector3(0,1.36,0),.39,Color("#EAD9A0"),Vector3(1,.5,.9))
	_tube(Vector3(0,1.28,0),.39,.39,.08,accent,12)
	_ball(Vector3(0,1.4,.33),.09,Color("#F9F1D7"),Vector3(1,1,.35))
	var handle:=_tube(Vector3(.64,.95,0),.045,.045,1.15,Color("#977554"),8);handle.rotation.z=-.22
	var hammer:=_tube(Vector3(.75,1.47,0),.19,.19,.59,Color("#C8A880"),10);hammer.rotation.z=PI*.5
	_eyes(Vector3(0,1.1,.405),.14,.035)


func _glim(accent: Color) -> void:
	_ball(Vector3(0,1.02,0),.37,Color("#7A6A64"),Vector3(.8,1.15,.85))
	for side: float in [-1,1]:
		var ear:=_tube(Vector3(side*.18,.47,.02),.15,.025,.48,Color("#B48F7C"),7);ear.rotation.z=side*.16
		_ball(Vector3(side*.32,1.0,0),.32,Color("#7A6A64"),Vector3(.64,1.3,.33))
	_box(Vector3(0,1.7,0),Vector3(1.0,.055,.07),Color("#967F69"))
	_tube(Vector3(.44,1.65,0),.04,.04,.35,Color("#967F69"),7)
	var paper:=_tube(Vector3(.3,.71,.2),.075,.075,.44,Color("#2E4470"),10);paper.rotation.z=PI*.5
	_box(Vector3(.31,.71,.26),Vector3(.1,.16,.035),accent)
	_eyes(Vector3(0,.86,.3),.09,.027)


func _mouse() -> void:
	_ball(Vector3(0,.4,0),.3,Color("#B7A17C"),Vector3(.85,1.1,.85))
	for side: float in [-1,1]:
		_ball(Vector3(side*.24,.72,0),.18,Color("#C7B497"),Vector3(1,1,.5))
		_ball(Vector3(side*.24,.72,.065),.105,Color("#DABFB0"),Vector3(1,1,.2))
	_ball(Vector3(0,.42,.26),.07,Color("#987D70"))
	_eyes(Vector3(0,.59,.22),.083,.032)
	_tube(Vector3(.46,.21,.2),.27,.31,.32,Color("#B29B70"),10)
	var handle:=TorusMesh.new();handle.inner_radius=.22;handle.outer_radius=.25;handle.rings=12;handle.ring_segments=6
	var hoop:=_mesh(handle,Vector3(.46,.43,.2),Color("#9D805E"));hoop.rotation.x=PI*.5


func _bunny() -> void:
	_ball(Vector3(0,.48,0),.36,Color("#F4DDD1"),Vector3(1,1.35,.9))
	for side: float in [-1,1]:
		var ear:=_ball(Vector3(side*.17,1.05,0),.13,Color("#EFCBC9"),Vector3(.7,2.2,.6));ear.rotation.z=side*.35
	_eyes(Vector3(0,.66,.3),.1,.032)
	_ball(Vector3(0,.49,.34),.045,Color("#BC8D8B"))


func _penguin() -> void:
	_ball(Vector3(0,.56,0),.4,Color("#687E8B"),Vector3(.95,1.35,.9))
	_ball(Vector3(0,.51,.23),.32,Color("#F2E8D8"),Vector3(.8,1,.35))
	_eyes(Vector3(0,.83,.3),.1,.033)
	var beak:=_tube(Vector3(0,.71,.37),0,.095,.16,Color("#C6AA77"),6);beak.rotation.x=PI*.5
	for side: float in [-1,1]:_ball(Vector3(side*.39,.45,0),.16,Color("#5C7481"),Vector3(.35,1.8,.8))
	_box(Vector3(0,.54,.34),Vector3(.19,.085,.05),Color("#987B70"))


func _fish() -> void:
	_ball(Vector3(0,.63,0),.42,Color("#D3BF8D"))
	for i: int in 9:_ball(Vector3(cos(i*.7)*.4,.65+sin(i*1.9)*.25,sin(i*.7)*.38),.065,Color("#B6A67D"))
	for side: float in [-1,1]:_ball(Vector3(side*.48,.59,0),.17,Color("#C5AE81"),Vector3(.8,.28,1))
	_eyes(Vector3(0,.75,.39),.14,.044)


func _dragon(big: bool) -> void:
	var color:=Color("#926D75") if big else Color("#C18E6D")
	_ball(Vector3(0,.42,0),.4,color,Vector3(1.05,.7,1.35))
	_ball(Vector3(0,.69,.34),.3,color,Vector3(1.1,.9,1))
	for i: int in 5:_ball(Vector3(-.05+i*.1,.26-i*.025,-.44-i*.15),.14-i*.019,color)
	for side: float in [-1,1]:
		_ball(Vector3(side*.36,.17,.1),.12,color,Vector3(.8,.6,1.35))
		if big:_ball(Vector3(side*.42,.55,-.1),.27,Color("#899899"),Vector3(1,.9,.2))
	_eyes(Vector3(0,.8,.59),.12,.036)
	if big:
		for side: float in [-1,1]:_tube(Vector3(side*.2,.98,.24),0,.07,.2,Color("#CDBEA1"),6)


func _beaver() -> void:
	_ball(Vector3(0,.48,0),.37,Color("#A48762"),Vector3(1,1.1,.92))
	_ball(Vector3(0,.58,.27),.2,Color("#C0A583"),Vector3(1.2,.8,.65))
	for side: float in [-1,1]:_ball(Vector3(side*.22,.83,0),.09,Color("#947953"))
	_ball(Vector3(0,.18,-.36),.24,Color("#8C6E53"),Vector3(.7,.25,1.5))
	_box(Vector3(0,.43,.4),Vector3(.14,.13,.055),Color("#E6D5BA"))
	_eyes(Vector3(0,.72,.27),.11,.031)


func _mole() -> void:
	_ball(Vector3(0,.5,0),.37,Color("#9D8B7A"),Vector3(1.1,1.0,.95))
	_ball(Vector3(0,.59,.38),.105,Color("#B08D83"),Vector3(1,.75,1.4))
	_tube(Vector3(0,.77,0),.33,.33,.13,Color("#9FA085"),10)
	_ball(Vector3(0,.81,.3),.09,Color("#EDE4BB"),Vector3(1,1,.4))
	_eyes(Vector3(0,.65,.3),.085,.02)


func _duck() -> void:
	_ball(Vector3(0,.48,0),.32,Color("#CDBE88"),Vector3(1.2,.85,1))
	_ball(Vector3(0,.83,.15),.24,Color("#D9CDA3"))
	_ball(Vector3(0,.75,.39),.15,Color("#B89B64"),Vector3(1.35,.4,1))
	_eyes(Vector3(0,.9,.34),.09,.031)
	_box(Vector3(.35,.48,-.09),Vector3(.28,.065,.07),Color("#8E7C58"))
	_box(Vector3(.44,.48,-.09),Vector3(.075,.23,.09),Color("#8E7C58"))


func _cat() -> void:
	_ball(Vector3(0,.48,0),.31,Color("#7F929B"),Vector3(.9,1.1,.9))
	_ball(Vector3(0,.81,.12),.28,Color("#92A5AC"))
	for side: float in [-1,1]:_tube(Vector3(side*.17,1.05,.1),0,.13,.28,Color("#92A5AC"),5)
	_eyes(Vector3(0,.88,.35),.1,.035)
	var tail:=_tube(Vector3(.33,.39,-.18),.055,.075,.65,Color("#81949D"),8);tail.rotation.z=-.7


func _fox() -> void:
	_ball(Vector3(0,.48,0),.33,Color("#B8B0C5"),Vector3(.8,1.15,.85))
	_ball(Vector3(0,.85,.12),.28,Color("#C9BDD1"),Vector3(1.1,.9,.9))
	for side: float in [-1,1]:_tube(Vector3(side*.19,1.08,.1),0,.13,.3,Color("#B6A7C3"),6)
	_ball(Vector3(0,.75,.36),.15,Color("#F1E8DA"),Vector3(.9,.7,1))
	_ball(Vector3(.33,.32,-.2),.29,Color("#D7CADB"),Vector3(1.5,.6,.8))
	_eyes(Vector3(0,.87,.35),.11,.032)


func _badger() -> void:
	_ball(Vector3(0,.65,0),.52,Color("#7D756B"),Vector3(1.2,1,.9))
	_ball(Vector3(0,1.05,.16),.36,Color("#D4CCB9"),Vector3(1,1,.95))
	for side: float in [-1,1]:_ball(Vector3(side*.14,1.08,.42),.14,Color("#5D605B"),Vector3(.65,1.7,.25))
	_ball(Vector3(0,.94,.5),.105,Color("#585B58"),Vector3(1.25,.7,.8))
	_ball(Vector3(0,1.4,0),.36,Color("#8B7967"),Vector3(1.2,.35,1))
	_eyes(Vector3(0,1.17,.43),.14,.035)


func _meringue() -> void:
	for i: int in 5:_tube(Vector3(0,.22+i*.28,0),maxf(.035,.52-i*.11),.64-i*.11,.34,Color("#E8D9C2"),12)
	var tip:=_tube(Vector3(-.09,1.65,0),0,.15,.4,Color("#DCCCB6"),10);tip.rotation.z=.65
	_eyes(Vector3(0,.85,.48),.13,.041)


func _yeti() -> void:
	_ball(Vector3(0,.85,0),.64,Color("#D7E1E2"),Vector3(.95,1.25,.9))
	_ball(Vector3(0,1.55,.08),.43,Color("#C6D4D8"))
	_ball(Vector3(0,1.45,.49),.14,Color("#B88687"))
	_tube(Vector3(0,1.1,0),.47,.47,.18,Color("#81929D"),10)
	_eyes(Vector3(0,1.66,.43),.14,.044)


func _crab() -> void:
	_ball(Vector3(0,.5,0),.54,Color("#A37768"),Vector3(1.4,.65,1))
	for side: float in [-1,1]:
		_ball(Vector3(side*.87,.65,.1),.29,Color("#B18371"),Vector3(.9,1.2,.8))
		for i: int in 3:_ball(Vector3(side*(.45+i*.12),.18,-.15+i*.17),.11,Color("#9C7569"),Vector3(1.8,.4,.7))
	_tube(Vector3(0,.96,0),0,.21,.28,Color("#5C6F79"),4)
	_eyes(Vector3(0,.86,.28),.2,.052)


func _oak() -> void:
	_tube(Vector3(0,.8,0),.4,.55,1.6,Color("#8B795A"),9)
	for i: int in 5:_ball(Vector3(sin(i*1.25)*.65,1.75+cos(i*.9)*.18,cos(i*1.25)*.25),.57,Color("#8BA179"))
	_eyes(Vector3(0,1.1,.43),.2,.052)


func _golem() -> void:
	_tube(Vector3(0,.74,0),.4,.62,1.3,Color("#8C90A1"),7)
	_ball(Vector3(0,1.48,0),.42,Color("#B4ABBD"))
	for side: float in [-1,1]:_tube(Vector3(side*.53,.66,0),.22,.29,.8,Color("#9B9BAA"),5)
	_tube(Vector3(0,1.93,0),0,.15,.42,Color("#CFC1D7"),5)
	_eyes(Vector3(0,1.55,.38),.14,.048)


func _clockwork() -> void:
	_box(Vector3(0,.85,0),Vector3(1.25,1.55,.55),Color("#A48C68"))
	var roof:=_tube(Vector3(0,1.8,0),0,.84,.55,Color("#8D775E"),4);roof.rotation.y=PI*.25
	_tube(Vector3(0,1.16,.35),.43,.43,.08,Color("#DACBA6"),16).rotation.x=PI*.5
	_box(Vector3(0,1.16,.42),Vector3(.045,.42,.03),Color("#776855"))
	_box(Vector3(.15,1.16,.42),Vector3(.3,.04,.03),Color("#776855"))
	_eyes(Vector3(0,.65,.34),.16,.043)


func _disco() -> void:
	_ball(Vector3(0,.98,0),.7,Color("#9EA9B1"))
	for i: int in 12:
		var a: float=i*TAU/12.0
		_box(Vector3(cos(a)*.64,1.01,sin(a)*.64),Vector3(.14,.14,.025),Color("#C3B7C6")).rotation.y=-a
	_eyes(Vector3(0,1.12,.65),.21,.047)


func _moon() -> void:
	_ball(Vector3(0,1.03,0),.81,Color("#D8CEB6"))
	for i: int in 5:_ball(Vector3(sin(i*1.9)*.47,1.0+cos(i*2.1)*.41,.63),.1,Color("#BEB49E"),Vector3(1,1,.25))
	_eyes(Vector3(0,1.2,.73),.23,.04)


func _eyes(pos: Vector3, spacing: float, radius: float) -> void:
	for side: float in [-1,1]:_eyes_nodes.append(_ball(pos+Vector3(side*spacing,0,0),radius,Color("#38424A"),Vector3(1,1.35,.4)))


func _material(color: Color) -> StandardMaterial3D:
	var key: String=color.to_html()
	if not _materials.has(key):
		var material:=StandardMaterial3D.new();material.albedo_color=color;material.roughness=.9
		_materials[key]=material
	return _materials[key]


func _mesh(mesh: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var node:=MeshInstance3D.new();node.mesh=mesh;node.position=pos;node.material_override=_material(color);_body.add_child(node)
	return node


func _ball(pos: Vector3, radius: float, color: Color, stretch: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh:=SphereMesh.new();mesh.radius=radius;mesh.height=radius*2;mesh.radial_segments=12;mesh.rings=6
	var node:=_mesh(mesh,pos,color);node.scale=stretch;return node


func _tube(pos: Vector3, top: float, bottom: float, height: float, color: Color, sides: int = 10) -> MeshInstance3D:
	var mesh:=CylinderMesh.new();mesh.top_radius=top;mesh.bottom_radius=bottom;mesh.height=height;mesh.radial_segments=sides
	return _mesh(mesh,pos,color)


func _box(pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size;return _mesh(mesh,pos,color)
