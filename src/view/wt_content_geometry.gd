class_name WtContentGeometry extends RefCounted
## Original bounded-cell sculptures. One shared mesh per content kind, never one node per cell.
static var _cache: Dictionary={}
static func mesh(kind: int) -> Mesh:
	if _cache.has(kind):return _cache[kind]
	var parts: Array=[]
	var cream:=Color("#E8DDC8");var ink:=Color("#35434B");var pink:=Color("#CA9EAA")
	match kind:
		3:
			parts=[_tube(Vector3(0,-.12,0),.13,.18,.6,cream),_ball(Vector3(0,.19,0),.43,pink,Vector3(1,.65,1))]
		4:
			parts=[_tube(Vector3(0,-.04,0),.04,.06,.75,Color("#91B479")),_ball(Vector3(-.19,.12,0),.26,Color("#A9C38D"),Vector3(1,.33,.6)),_ball(Vector3(.19,.28,0),.25,Color("#91B479"),Vector3(1,.33,.6))]
		5:parts=[_ball(Vector3.ZERO,.38,cream,Vector3(.92,1.25,.92))]
		6:
			parts=[_ball(Vector3(0,-.03,0),.37,Color("#E9CD86"),Vector3(1,1.1,.9)),_ball(Vector3(0,.10,.34),.09,Color("#B39567"),Vector3(1,.6,1.1))]
			parts.append_array(_eyes(.16,.31))
		7:
			parts=[_box(Vector3(0,-.34,0),Vector3(.9,.16,.9),Color("#AAA08B"))]
			for y: float in [-.1,.1,.3]:parts.append(_ring(Vector3(0,y,0),.26,.33,Color("#C7BEA5")))
		8:parts=[_ball(Vector3.ZERO,.43,Color("#E9EEEE"))]
		9,11,20:
			parts=[_ball(Vector3(0,-.05,0),.43,pink if kind==11 else Color("#C6B7D0"),Vector3(1,1 if kind==11 else .72,1))]
		10,16,19,22:
			var color: Color={10:Color("#ADAB91"),16:Color("#B6A8C4"),19:Color("#B99A84"),22:Color("#9C9389")}[kind]
			parts=[_ball(Vector3.ZERO,.38,color,Vector3(1.05,1,.9))];parts.append_array(_eyes(.16,.32))
			for side: float in [-1,1]:parts.append(_ball(Vector3(side*.25,.31,0),.1,color))
		12,13:
			parts=[_box(Vector3(0,-.08,0),Vector3(.84,.72,.84),Color("#D8BEA3")),_box(Vector3(0,.34,0),Vector3(.88,.13,.87),cream)]
			for i: int in (3 if kind==13 else 2):parts.append(_ball(Vector3((i-1)*.18,.41,0),.095,pink,Vector3(1,.7,1)))
		14:parts=[_box(Vector3.ZERO,Vector3(.9,.85,.9),Color("#C7B77E"))]
		15:
			for x: float in [-.24,0,.24]:parts.append(_tube(Vector3(x,0,0),.13,.13,.9,Color("#8E819B")))
		17,18:
			parts=[_ball(Vector3(0,-.03,0),.38,Color("#AA8EAB") if kind==17 else Color("#AC9780")),_tube(Vector3(0,.39,0),.035,.04,.18,ink),_ball(Vector3(.06,.45,0),.06,Color("#D7BD81"))]
		21:parts=[_ball(Vector3.ZERO,.46,Color("#979AA1"),Vector3(1,.85,1))]
		23:
			parts=[_box(Vector3.ZERO,Vector3(.9,.9,.9),Color("#9FADB0")),_ring(Vector3(0,.05,.47),.1,.16,Color("#D7BD81"),Vector3(PI*.5,0,0)),_box(Vector3(0,-.08,.47),Vector3(.25,.22,.06),Color("#D7BD81"))]
		24:parts=[_box(Vector3(0,-.3,0),Vector3(1,.25,1),Color("#B09A7E"))]
		_:parts=[_box(Vector3.ZERO,Vector3.ONE*.9,cream)]
	var surface:=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part: Dictionary in parts:
		var source: Mesh=part.mesh;var arrays: Array=source.surface_get_arrays(0)
		var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
		var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
		var transform: Transform3D=part.transform
		for j: int in (indices.size() if not indices.is_empty() else vertices.size()):
			var index: int=indices[j] if not indices.is_empty() else j
			surface.set_color(part.color);surface.set_normal((transform.basis*normals[index]).normalized())
			surface.add_vertex(transform*vertices[index])
	_cache[kind]=surface.commit();return _cache[kind]
static func _eyes(y: float,z: float) -> Array:
	return [_ball(Vector3(-.13,y,z),.037,Color("#35434B")),_ball(Vector3(.13,y,z),.037,Color("#35434B"))]
static func _ball(position: Vector3,radius: float,color: Color,scale: Vector3=Vector3.ONE) -> Dictionary:
	var shape:=SphereMesh.new();shape.radius=radius;shape.height=radius*2;shape.radial_segments=12;shape.rings=6
	return {"mesh":shape,"color":color,"transform":Transform3D(Basis.from_scale(scale),position)}
static func _box(position: Vector3,size: Vector3,color: Color) -> Dictionary:
	var shape:=BoxMesh.new();shape.size=size;return {"mesh":shape,"color":color,"transform":Transform3D(Basis.IDENTITY,position)}
static func _tube(position: Vector3,top: float,bottom: float,height: float,color: Color) -> Dictionary:
	var shape:=CylinderMesh.new();shape.top_radius=top;shape.bottom_radius=bottom;shape.height=height;shape.radial_segments=10
	return {"mesh":shape,"color":color,"transform":Transform3D(Basis.IDENTITY,position)}
static func _ring(position: Vector3,inner: float,outer: float,color: Color,rotation: Vector3=Vector3.ZERO) -> Dictionary:
	var shape:=TorusMesh.new();shape.inner_radius=inner;shape.outer_radius=outer;shape.rings=16;shape.ring_segments=6
	return {"mesh":shape,"color":color,"transform":Transform3D(Basis.from_euler(rotation),position)}
