extends Node
## THROWAWAY PROTOTYPE (addon audit 2026-10-14) - not production code, never referenced from src/.
## Question: can phantom_camera improve the portrait (720x1280) gameplay framing so the whole board
## stays inside the HUD-free board rect (which keeps the NEXT-piece / goal HUD clear)?
## BEFORE = stock WtStage camera. AFTER = a PhantomCameraHost on the same Camera3D, driven by a
## PhantomCamera3D whose ortho size/offset come from projecting the board AABB's 8 corners at every
## one of the 12 yaw snaps (stable zoom across rotation) into the HUD board rect.
## Reuses tools/qa/island_capture.gd (_place_pieces fixture, same main-scene boot path).
## Run: timeout 240 xvfb-run -a -s "-screen 0 1280x1280x24" godot --path . --rendering-driver opengl3 \
##   --resolution 720x1280 res://prototypes/camera_pcam/pcam_framing_capture.tscn -- [--biomes=meadow,celestial]
const OUT := "res://production/qa/evidence/playtest-2026-10-14/addons/"
const MARGIN := 0.6  ## world units of island margin around the board footprint

var _report: Array[String] = []

func _ready() -> void:
	_run.call_deferred()

func _frames(n: int) -> void:
	for i: int in n: await get_tree().process_frame

func _run() -> void:
	var biomes: PackedStringArray = PackedStringArray(["meadow", "celestial"])
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--biomes="): biomes = a.trim_prefix("--biomes=").split(",")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var res: String = "%dx%d" % [int(vs.x), int(vs.y)]
	var fixture: Node = load("res://tools/qa/island_capture.gd").new()  # not added to tree: _ready/_run never fire
	var main: Node = load("res://src/app/main.tscn").instantiate()
	add_child(main)
	await _frames(20)
	var store: Object = main.get("_store")
	if store.call("active_profile") == null: store.call("create", "QA Pcam")
	main.set("_smoke", true)
	for b: String in biomes:
		main.call("_start_level", StringName(b + "_01"))
		main.set_physics_process(false)
		fixture.call("_place_pieces", main)
		await _frames(30)
		var stage: Node3D = main.get("_stage")
		var cam: Camera3D = stage.get("_camera")
		_report.append("%s before: size=%.2f h_off=%.2f v_off=%.2f rect=%s" % [b, cam.size, cam.h_offset, cam.v_offset, str(stage.get("_view_rect"))])
		await _snap(OUT + "pcam_before_%s_%s.png" % [b, res])
		_report.append("%s before: board-rect coverage %s" % [b, _coverage(stage, cam)])
		_attach_pcam(stage, cam)
		await _frames(10)
		_report.append("%s after:  size=%.2f h_off=%.2f v_off=%.2f" % [b, cam.size, cam.h_offset, cam.v_offset])
		await _snap(OUT + "pcam_after_%s_%s.png" % [b, res])
		_report.append("%s after:  board-rect coverage %s" % [b, _coverage(stage, cam)])
	for line: String in _report: print("PCAM ", line)
	get_tree().quit()

## Hands the stage camera to phantom_camera: host on the Camera3D, one priority-10 PhantomCamera3D.
func _attach_pcam(stage: Node3D, cam: Camera3D) -> void:
	stage.set_process(false)  # stop WtStage._update_camera() fighting the host every frame
	var host := PhantomCameraHost.new()
	cam.add_child(host)
	var pcam := PhantomCamera3D.new()
	var r := Camera3DResource.new()
	r.projection = Camera3DResource.ProjectionType.ORTHOGONAL
	r.keep_aspect = Camera3DResource.KeepAspect.KEEP_HEIGHT
	r.far = 150.0
	pcam.camera_3d_resource = r
	pcam.priority = 10
	pcam.tween_on_load = false
	stage.add_child(pcam)
	var fit: Dictionary = _fit(stage, cam.global_basis)
	pcam.global_basis = cam.global_basis
	pcam.global_position = fit.center + cam.global_basis.z * 35.0
	r.size = fit.size
	r.h_offset = fit.h_offset
	r.v_offset = fit.v_offset

## Board AABB (footprint + margin, floor .. playable top + 1) as 8 world corners.
func _corners(stage: Node3D) -> Array[Vector3]:
	var size: Vector3i = stage.get("_size")
	var board: Object = stage.get("_board")
	var top: float = float(board.call("h_play")) + 1.0
	var hx: float = size.x * 0.5 + MARGIN
	var hz: float = size.z * 0.5 + MARGIN
	var out: Array[Vector3] = []
	for sx: float in [-hx, hx]:
		for sy: float in [0.0, top]:
			for sz: float in [-hz, hz]:
				out.append(Vector3(sx, sy, sz))
	return out

## Ortho size that fits the projected AABB into the board rect at all 12 yaw snaps, plus the offset that
## centres the current-yaw projection in that rect.
func _fit(stage: Node3D, basis: Basis) -> Dictionary:
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var rect: Rect2 = stage.get("_view_rect")
	var aspect: float = vs.x / vs.y
	var elev: float = -basis.get_euler().x
	var corners: Array[Vector3] = _corners(stage)
	var need: float = 0.0
	for k: int in 12:
		var b := Basis.from_euler(Vector3(-elev, basis.get_euler().y + deg_to_rad(30.0 * k), 0))
		var e: Rect2 = _extent(corners, b)
		need = maxf(need, maxf(e.size.y / rect.size.y, e.size.x / (aspect * rect.size.x)))
	var cur: Rect2 = _extent(corners, basis)
	var mid: Vector2 = cur.get_center()  # x right, y up, in camera plane, world units
	var center: Vector3 = basis.x * mid.x + basis.y * mid.y
	var rc: Vector2 = rect.position + rect.size * 0.5
	return {"size": need, "center": center, "v_offset": (rc.y - 0.5) * need, "h_offset": (0.5 - rc.x) * need * aspect}

func _extent(corners: Array[Vector3], b: Basis) -> Rect2:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for c: Vector3 in corners:
		var p := Vector2(c.dot(b.x), c.dot(b.y))
		lo = lo.min(p)
		hi = hi.max(p)
	return Rect2(lo, hi - lo)

## Observation only: projected board AABB in px vs the HUD board rect in px.
func _coverage(stage: Node3D, cam: Camera3D) -> String:
	var vs: Vector2 = get_viewport().get_visible_rect().size
	var rect: Rect2 = stage.get("_view_rect")
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for c: Vector3 in _corners(stage):
		var p: Vector2 = cam.unproject_position(c)
		lo = lo.min(p)
		hi = hi.max(p)
	var px := Rect2(rect.position * vs, rect.size * vs)
	return "board px %s..%s, board-rect px %s..%s, fill %.0f%% of rect height, inside=%s" % [
		str(lo.round()), str(hi.round()), str(px.position.round()), str(px.end.round()),
		100.0 * (hi.y - lo.y) / px.size.y, str(px.grow(1.0).encloses(Rect2(lo, hi - lo)))]

func _snap(path: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(path)
	print("PCAM_SNAP ", path)
