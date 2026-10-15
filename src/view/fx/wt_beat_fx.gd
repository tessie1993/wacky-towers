class_name WtBeatFx extends Node3D
## Visual helpers for WtLevelBeats: full-screen glow flash, expanding light rings and the Wizard's cloud swoop.
## Presentation only. `reduced` skips flashes and travel (reduced motion / flashing preference).
var reduced: bool = false
var board_size: Vector3i = Vector3i(8, 8, 8)
var _overlay: ColorRect
var _cloud: Node3D


func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 1
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_overlay.material = m
	_overlay.color = Color(0, 0, 0, 0)
	layer.add_child(_overlay)


## Brief full-screen tint that fades out.
func glow(color: Color, alpha: float, seconds: float) -> void:
	if reduced or _overlay == null: return
	_overlay.color = Color(color, alpha)
	var tw := create_tween()
	tw.tween_property(_overlay, "color:a", 0.0, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Expanding flat light ring at a board cell.
func ring(cell: Vector3i, color: Color, radius: float, seconds: float, alpha: float, delay: float) -> void:
	var torus := TorusMesh.new()
	torus.inner_radius = 0.93
	torus.outer_radius = 1.0
	torus.rings = 32
	torus.ring_segments = 6
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(color, 0.0)
	mat.no_depth_test = true
	var mi := MeshInstance3D.new()
	mi.mesh = torus
	mi.material_override = mat
	mi.position = BoardGeom.cell_center(cell, board_size) + Vector3.UP * 0.02
	mi.scale = Vector3(0.2, 0.3, 0.2)
	add_child(mi)
	var tw := create_tween()
	if delay > 0.0: tw.tween_interval(delay)
	tw.tween_property(mat, "albedo_color:a", alpha, 0.01)
	tw.set_parallel(true)
	tw.tween_property(mi, "scale", Vector3(radius, 0.3, radius), seconds).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(mat, "albedo_color:a", 0.0, seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(mi.queue_free)


## Puffy cloud that sweeps in, dips over the lowest `layers` and leaves. Reduced motion: fades in place.
func swoop(seconds: float, color: Color, layers: int) -> void:
	if _cloud != null and is_instance_valid(_cloud): _cloud.queue_free()
	_cloud = Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 0.5
	for p: Vector4 in [Vector4(0, 0, 0, 1.3), Vector4(-1.2, -0.2, 0.2, 1.0), Vector4(1.2, -0.2, -0.1, 1.0), Vector4(0.5, 0.5, 0.2, 0.9), Vector4(-0.6, 0.45, -0.2, 0.8)]:
		var s := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = p.w
		sm.height = p.w * 1.7
		s.mesh = sm
		s.material_override = mat
		s.position = Vector3(p.x, p.y, p.z)
		_cloud.add_child(s)
	add_child(_cloud)
	var w: float = float(board_size.x)
	var low: float = maxf(1.0, float(layers)) * 0.5
	var start := Vector3(w * 1.3, board_size.y + 3.0, 0.0)
	var mid := Vector3(0.0, low + 1.0, 0.0)
	var out := Vector3(-w * 1.3, board_size.y + 4.0, 0.0)
	_cloud.position = mid if reduced else start
	var tw := create_tween()
	if reduced:
		_cloud.scale = Vector3.ONE * 0.01
		tw.tween_property(_cloud, "scale", Vector3.ONE, seconds * 0.4)
		tw.tween_interval(seconds * 0.3)
		tw.tween_property(_cloud, "scale", Vector3.ONE * 0.01, seconds * 0.3)
	else:
		tw.tween_property(_cloud, "position", mid, seconds * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_interval(seconds * 0.1)
		tw.tween_property(_cloud, "position", out, seconds * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(_cloud.queue_free)
