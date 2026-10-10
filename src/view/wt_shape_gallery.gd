extends Node3D
## Evidence scene: every source-bank silhouette, drawn with one cube MultiMesh.
## This is never the production entrypoint.

func _ready() -> void:
	var bank: ShapeBank = load("res://assets/data/shapes/shape_bank.tres")
	var art := ArtSet.new(&"candy_toy")
	var palette := PaletteTable.from_dict(JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/palettes/meadow.json")))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = art.cube_mesh()
	var cube_count: int = 0
	for shape: ShapeDef in bank.shapes:
		cube_count += shape.cube_count
	mm.instance_count = cube_count
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = BoardView.make_material(Color.WHITE, Color("#30434C"), .018, true)
	add_child(mmi)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#E5EFED")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#E6ECFF")
	env.ambient_light_energy = .45
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-30,-35,0)
	light.light_energy = .65
	add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 74.0
	camera.position = Vector3(0,0,100)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	var layer := CanvasLayer.new()
	add_child(layer)
	var index: int = 0
	var slot: int = 0
	var visual_basis := Basis.from_euler(Vector3(.38,.58,0.0))
	for shape: ShapeDef in bank.shapes:
		var anchor := Vector3((index%8-3.5)*9.1,(4.0-floorf(index/8.0))*7.05-1.3,0)
		var bbox: Vector3i = shape.bbox(shape.spawn_orient)
		var center: Vector3 = Vector3(shape.min_corner(shape.spawn_orient))+(Vector3(bbox)-Vector3.ONE)*.5
		var scale: float = minf(.85, 3.5/maxf(bbox.x,maxf(bbox.y,bbox.z)))
		for offset: Vector3i in shape.offsets(shape.spawn_orient):
			mm.set_instance_transform(slot,Transform3D(visual_basis.scaled(Vector3.ONE*scale),anchor+visual_basis*((Vector3(offset)-center)*scale)))
			mm.set_instance_color(slot,palette.color(shape.hue_id))
			slot += 1
		var label := Label.new()
		label.text = str(shape.shape_id)
		label.add_theme_color_override("font_color",Color("#30434C"))
		label.add_theme_font_size_override("font_size",11)
		label.size = Vector2(90,22)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = camera.unproject_position(anchor+Vector3(0,-2.4,0))-Vector2(45,0)
		layer.add_child(label)
		index += 1
	var title := Label.new()
	title.text = "WACKY TOWERS · ALL %d SOURCE SHAPES · %d CUBES · ONE MULTIMESH" % [bank.shapes.size(),cube_count]
	title.position = Vector2(28,20)
	title.add_theme_color_override("font_color",Color("#30434C"))
	title.add_theme_font_size_override("font_size",18)
	layer.add_child(title)
	print("SHAPE_GALLERY: shapes=",bank.shapes.size()," cubes=",cube_count," cube_mesh=",mm.mesh!=null," multimeshes=1")
