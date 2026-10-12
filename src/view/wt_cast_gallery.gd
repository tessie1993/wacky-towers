extends Node3D
## Standalone evidence scene; original geometric cast in one consistent light.

func _ready() -> void:
	var ids: Array[StringName]=[&"cloud",&"mizzle",&"lana",&"boulder",&"glim",&"pip",&"mallow",&"pebble",&"puff",&"cinder",&"chip",&"nugget",&"tock",&"glitch",&"comet",&"miller",&"meringue",&"sniffles",&"crab",&"smolder",&"oak",&"geode",&"cuckoo",&"mirrorball",&"moon"]
	var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color("#E5ECE8")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_energy=.5
	var we:=WorldEnvironment.new();we.environment=env;add_child(we)
	var key:=DirectionalLight3D.new();key.rotation_degrees=Vector3(-45,-28,0);key.light_energy=.6;add_child(key)
	var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.keep_aspect=Camera3D.KEEP_HEIGHT
	camera.size=23;camera.position=Vector3(0,1,40);add_child(camera);camera.look_at(Vector3(0,1,0));camera.current=true
	var layer:=CanvasLayer.new();add_child(layer)
	for i: int in ids.size():
		var actor:=WtToyActor.new();add_child(actor);actor.setup(ids[i]);actor.set_reduced_motion(true)
		actor.position=Vector3((i%5-2)*4.8,(2-floorf(i/5.0))*4.2-.5,0)
		var label:=Label.new();label.text=str(ids[i]);label.size=Vector2(120,24);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",14);label.add_theme_color_override("font_color",Color("#344451"))
		label.position=camera.unproject_position(actor.position-Vector3(0,.35,0))-Vector2(60,0);layer.add_child(label)
	var title:=Label.new();title.text="WACKY TOWERS · 25 ORIGINAL PROCEDURAL TOY FORMS";title.position=Vector2(24,20)
	title.add_theme_font_size_override("font_size",20);title.add_theme_color_override("font_color",Color("#344451"));layer.add_child(title)
	print("CAST_GALLERY: original_forms=25 playable_forms=4 source_geometry=primitive_meshes")
