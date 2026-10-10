class_name CandyCells extends RefCounted
## Deterministic geometry and status helpers for authored Candy rules.
const FACE: Array[Vector3i] = [Vector3i.LEFT,Vector3i.RIGHT,Vector3i.UP,Vector3i.DOWN,Vector3i(0,0,-1),Vector3i(0,0,1)]

static func cells(api: RuleApi, occupied_only: bool = false) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	var size: Vector3i = api.board_size()
	for x: int in size.x:
		for y: int in size.y:
			for z: int in size.z:
				var c := Vector3i(x,y,z)
				if api.is_active(c) and (not occupied_only or api.kind_at(c)!=0): out.append(c)
	return out

static func status(api: RuleApi, c: Vector3i, patch: Dictionary) -> void:
	var rec: Dictionary = api.record_at(c).get("status",{}).duplicate(true)
	rec.merge(patch,true)
	api.set_status(c,rec)

static func tidy(api: RuleApi) -> float:
	var filled: int = 0
	var holes: Dictionary = {}
	for c: Vector3i in cells(api,true):
		filled += 1
		var below: Vector3i = c+api.down_vector()
		while api.is_active(below):
			if api.kind_at(below)==0: holes[below]=true
			below += api.down_vector()
	return clampf(1.0-float(holes.size())/maxi(1,filled),0.0,1.0)

static func surface(api: RuleApi, own: Array[Vector3i] = []) -> Array[Vector3i]:
	var out: Array[Vector3i] = []
	for c: Vector3i in cells(api):
		if api.layer_of(c)>=api.limit_layer(): continue
		var below: Vector3i = c+api.down_vector()
		if (api.kind_at(c)==0 or own.has(c)) and (not api.is_active(below) or (api.kind_at(below)!=0 and not own.has(below))):out.append(c)
	return out

static func target_hue(api: RuleApi, c: Vector3i) -> int:
	var layers: Dictionary = api.goal_config().get("target_shape",{}).get("layers",{})
	var rows: Array = layers.get(str(c.y),[])
	if c.z<0 or c.z>=rows.size() or c.x<0 or c.x>=String(rows[c.z]).length():return 0
	return int({"P":1,"V":2,"M":3}.get(String(rows[c.z])[c.x],0))

static func wrong_target(api: RuleApi,c: Vector3i) -> bool:
	var target: int = target_hue(api,c)
	return target>0 and api.kind_at(c)!=0 and api.color_at(c)!=target and not bool(api.record_at(c).get("status",{}).get("rainbow",false))

static func protect(api: RuleApi,c: Vector3i,anchored: bool = true) -> void:
	status(api,c,{"anchored":anchored,"clear_protected":true,"fixed":true})
