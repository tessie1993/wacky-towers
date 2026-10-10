extends Node3D
## Every original party prop in WtMinigameArt.THEMES (MG01-MG36) in one retained
## runtime gallery, six per row; no gameplay fixture claims.
func _ready() -> void:
	var environment:=Environment.new();environment.background_mode=Environment.BG_COLOR;environment.background_color=Color("#E5E5E0")
	environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;environment.ambient_light_color=Color.WHITE;environment.ambient_light_energy=.6
	var world:=WorldEnvironment.new();world.environment=environment;add_child(world)
	var key:=DirectionalLight3D.new();key.rotation_degrees=Vector3(-55,-25,0);key.light_energy=.65;add_child(key)
	var i: int=0
	for id: String in WtMinigameArt.THEMES:
		var toy: Node3D=WtMinigameArt.create(id);toy.position=Vector3((i%6-2.5)*4.0,0,(i/6-2.5)*4.8);add_child(toy)
		var label:=Label3D.new();label.text=id+" · "+str(WtMinigameArt.THEMES[id].name);label.position=toy.position+Vector3(0,-.25,1.9);label.font_size=40;label.pixel_size=.007;label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;label.modulate=Color("#304652");add_child(label)
		i+=1
	var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=30;camera.current=true;camera.position=Vector3(0,29,28);add_child(camera);camera.look_at(Vector3(0,0,1))
	print("PARTY_ART_GALLERY: props=",i," original=true no_external_models=true")
