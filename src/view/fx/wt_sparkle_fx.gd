class_name WtSparkleFx extends Node3D
## Pooled sparkle stars and dust puffs for piece lock and line clear (one MultiMesh, one draw call).
## Pure presentation: never touches the simulation. Caller skips it under reduced motion.

const SHADER := "res://src/view/shaders/spatial_fx_sparkle.gdshader"
const POOL := 96
const STAR_LIFE := 0.9
const PUFF_LIFE := 0.7

var _mm: MultiMesh
var _items: Array[Dictionary] = []


func _ready() -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	_mm = MultiMesh.new()
	_mm.transform_format = MultiMesh.TRANSFORM_3D
	_mm.use_colors = true
	_mm.use_custom_data = true
	_mm.mesh = quad
	_mm.instance_count = POOL
	_mm.visible_instance_count = 0
	var node := MultiMeshInstance3D.new()
	node.multimesh = _mm
	var m := ShaderMaterial.new()
	m.shader = load(SHADER) as Shader
	m.render_priority = 10
	node.material_override = m
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.extra_cull_margin = 64.0
	add_child(node)


## Spawns `count` twinkling stars in a spread around `origin` (rising and drifting).
func sparkle(origin: Vector3, tint: Color, count: int = 12, spread: float = 1.6) -> void:
	for i: int in mini(count, POOL - _items.size()):
		var a: float = float(i) * 2.399963
		var r: float = spread * (0.25 + 0.75 * fmod(float(i) * 0.618, 1.0))
		_items.append({"p": origin + Vector3(cos(a) * r, fmod(float(i) * 0.37, 0.6), sin(a) * r),
			"v": Vector3(0, 0.35 + 0.25 * float(i % 4), 0), "t": 0.0, "life": STAR_LIFE * (0.7 + 0.1 * float(i % 4)),
			"size": 0.26 + 0.12 * float(i % 3), "kind": 0.0, "spin": a, "color": tint.lerp(Color.WHITE, 0.25 * float(i % 3))})


## Spawns `count` dust puffs that roll outward at floor level.
func dust(origin: Vector3, tint: Color, count: int = 6, spread: float = 1.0) -> void:
	for i: int in mini(count, POOL - _items.size()):
		var a: float = float(i) * 1.0471976 + 0.4
		_items.append({"p": origin + Vector3(cos(a), 0.05, sin(a)) * 0.2,
			"v": Vector3(cos(a), 0.25, sin(a)) * spread * 0.9, "t": 0.0, "life": PUFF_LIFE,
			"size": 0.55 + 0.1 * float(i % 3), "kind": 1.0, "spin": a, "color": tint})


## Live particle count (tests).
func active_count() -> int:
	return _items.size()


## Advances and uploads the pool.
func step(delta: float) -> void:
	if _mm == null: return
	for i: int in range(_items.size() - 1, -1, -1):
		var it: Dictionary = _items[i]
		it["t"] += delta
		if it["t"] >= it["life"]:
			_items.remove_at(i)
			continue
		it["v"] = it["v"] * (1.0 - minf(delta * 2.5, 1.0)) if it["kind"] > 0.5 else it["v"]
		it["p"] += it["v"] * delta
	for i: int in _items.size():
		var it: Dictionary = _items[i]
		_mm.set_instance_transform(i, Transform3D(Basis.IDENTITY, it["p"]))
		_mm.set_instance_color(i, it["color"])
		_mm.set_instance_custom_data(i, Color(it["t"] / it["life"], it["size"], it["kind"], it["spin"] + it["t"] * 2.0))
	_mm.visible_instance_count = _items.size()
