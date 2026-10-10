extends Control
## Wordless theatre: distinct portraits, silhouette poses, props and emote bubbles.
## The authored beat data owns meaning; this presentation has no gameplay writes.

const INK := Color("243b4d")
const PAPER := Color("fff8e7")
var beat: Dictionary = {}
var beat_index: int = 0
var beat_count: int = 1
var reduced_motion: bool = false
var _elapsed: float = 0.0
var _stage_origin: Vector2 = Vector2.ZERO
var _stage_scale: float = 1.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func set_beat(data: Dictionary, index: int, count: int, reduced: bool) -> void:
	beat = data.duplicate(true)
	beat_index = index
	beat_count = count
	reduced_motion = reduced
	_elapsed = 0.0
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if not reduced_motion: queue_redraw()

func _draw() -> void:
	var scale := minf(size.x / 960.0, size.y / 500.0)
	var origin := (size - Vector2(960, 500) * scale) * .5
	_stage_origin = origin
	_stage_scale = scale
	draw_set_transform(origin, 0, Vector2.ONE * scale)
	draw_circle(Vector2(480, 245), 212, Color("e6eddd"))
	_ellipse(Vector2(480, 390), Vector2(380, 48), Color("cedbbf"))
	var t := clampf(_elapsed / maxf(.1, float(beat.get("duration", 1.0))), 0, 1)
	var left := Vector2(245, 320)
	var right := Vector2(715, 320)
	if not reduced_motion:
		if str(beat.get("pose_left", "")) != "sit": left.y += sin(_elapsed * 4.0) * 4
		if str(beat.get("pose_right", "")) != "sit": right.y += sin(_elapsed * 4.0 + 1.5) * 4
	if str(beat.get("pose_left", "")) in ["approach", "give", "invite"]: left.x += t * 65
	if str(beat.get("pose_right", "")) in ["approach", "give", "invite"]: right.x -= t * 65
	_portrait(str(beat.get("left", "cloud")), left, str(beat.get("emote_left", "")), str(beat.get("pose_left", "idle")), false, t)
	_portrait(str(beat.get("right", "pip")), right, str(beat.get("emote_right", "")), str(beat.get("pose_right", "idle")), true, t)
	var prop := str(beat.get("symbol", ""))
	if not prop.is_empty(): _prop(prop, Vector2(480, 278), 1.15)
	var props: Array = beat.get("props", [])
	for i in props.size(): _prop(str(props[i]), Vector2(480 + (i - (props.size()-1)*.5)*72, 373), .55)
	var guests: Array = beat.get("guests", [])
	for i in guests.size(): _portrait(str(guests[i]), Vector2(480 + (i - (guests.size()-1)*.5)*83, 413), "", "wave", false, t, .34)
	for i in beat_count:
		draw_circle(Vector2(480 + (i - (beat_count - 1) * .5) * 22, 467), 5 if i != beat_index else 7, INK if i == beat_index else Color("bbc7b9"))
	draw_set_transform(Vector2.ZERO)

func _ellipse(at: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 48: points.append(at + Vector2(cos(i * TAU / 48), sin(i * TAU / 48)) * radii)
	draw_colored_polygon(points, color)

func _portrait(id: String, at: Vector2, emote: String, pose: String, mirrored: bool, t: float, portrait_scale: float = 1.0) -> void:
	var lean := 0.0
	var lower := 0.0
	if pose in ["sad", "sigh", "duck", "peek", "sleep"]: lower = 22
	if pose in ["bonk", "dizzy", "lean", "catch"]: lean = .18 * (-1 if mirrored else 1)
	if pose in ["cheer", "celebrate", "hop", "wave"] and not reduced_motion: lower = -absf(sin(t * PI * 2)) * 28
	var mirror := -1.0 if mirrored else 1.0
	draw_set_transform(_stage_origin + (at + Vector2(0, lower) * portrait_scale) * _stage_scale, lean, Vector2(mirror, 1) * _stage_scale * portrait_scale)
	_ellipse(Vector2(0, 69 - lower), Vector2(73, 12), Color(0.1, 0.2, 0.2, .10))
	match id.to_lower():
		"cloud", "cloud_wizard", "wizard", "c1": _wizard(false, pose)
		"mizzle": _wizard(true, pose)
		"lana", "c2": _lana(pose)
		"boulder", "c3": _boulder(pose)
		"glim", "c4": _glim(pose)
		_: _animal(id.to_lower(), pose)
	# Poses stay visible even when all motion is reduced.
	if pose in ["give", "invite", "catch"]:
		draw_line(Vector2(38, -5), Vector2(97, -20), INK, 8, true)
		draw_circle(Vector2(97, -20), 9, PAPER)
	if pose in ["wave", "cheer", "celebrate", "hand_off"]:
		draw_line(Vector2(-34, -4), Vector2(-65, -58), INK, 8, true)
		draw_circle(Vector2(-65, -58), 9, PAPER)
	if pose == "sleep":
		draw_arc(Vector2(-19, -44), 10, .1, PI-.1, 12, INK, 3, true)
		draw_arc(Vector2(19, -44), 10, .1, PI-.1, 12, INK, 3, true)
	draw_set_transform(_stage_origin + (at + Vector2(0, lower - 186) * portrait_scale) * _stage_scale, 0, Vector2.ONE * _stage_scale * portrait_scale)
	if not emote.is_empty(): _bubble(emote)
	draw_set_transform(_stage_origin, 0, Vector2.ONE * _stage_scale)

func _wizard(rival: bool, pose: String) -> void:
	var robe := Color("7e6496") if rival else Color("7893b9")
	if pose == "sit": _prop("chair", Vector2(0, 27), 1.2)
	else:
		for cloud in [Vector3(-43, 43, 30), Vector3(0, 37, 40), Vector3(43, 43, 30)]:
			draw_circle(Vector2(cloud.x, cloud.y), cloud.z + 3, INK)
			draw_circle(Vector2(cloud.x, cloud.y), cloud.z, Color("aaa2b3") if rival else PAPER)
	_ellipse(Vector2(0, -2), Vector2(45 if not rival else 31, 60), robe)
	draw_circle(Vector2(0, -53), 35, Color("f3dbb7"))
	var tip := Vector2(29, -155) if rival else Vector2(0, -158)
	var hat := PackedVector2Array([Vector2(-47, -78), tip, Vector2(45, -78)])
	if rival: hat = PackedVector2Array([Vector2(-37, -78), Vector2(4, -144), Vector2(43, -161), Vector2(25, -119), Vector2(32, -78)])
	draw_colored_polygon(hat, robe)
	draw_polyline(hat, INK, 3, true)
	draw_line(Vector2(-50, -79), Vector2(50, -79), INK, 6, true)
	if rival:
		for x in [-18, 18]: draw_arc(Vector2(x, -53), 14, 0, TAU, 24, Color("e3d3a0"), 4, true)
		draw_line(Vector2(-4, -53), Vector2(4, -53), INK, 2)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-30,-36),Vector2(30,-36),Vector2(0,17)]), PAPER)
	_eyes(Vector2(0, -55), pose)
	draw_line(Vector2(38, 5), Vector2(73, -65), INK, 5, true)
	_star(Vector2(74, -70), 12, Color("e6cb88"))

func _lana(pose: String) -> void:
	_ellipse(Vector2(0, 14), Vector2(64, 43), Color("d8c6a8"))
	draw_rect(Rect2(-18, -85, 35, 105), Color("c9a27e"))
	for at in [Vector2(-16,-104),Vector2(12,-104),Vector2(0,-119)]: draw_circle(at, 28, PAPER)
	_ellipse(Vector2(0,-87), Vector2(25,36), Color("c9a27e"))
	for x in [-22,22]: _ellipse(Vector2(x,-141),Vector2(8,25), Color("c9a27e"))
	draw_line(Vector2(-26,-151),Vector2(22,-183),INK,3,true)
	draw_line(Vector2(24,-152),Vector2(-20,-182),INK,3,true)
	_eyes(Vector2(0,-96),pose)
	draw_circle(Vector2(65,51),22,Color("e38b76"))
	draw_line(Vector2(33,13),Vector2(63,47),Color("e38b76"),3,true)

func _boulder(pose: String) -> void:
	_ellipse(Vector2(0, 0),Vector2(78,56),Color("8e7a82"))
	_ellipse(Vector2(0, 12),Vector2(40,37),Color("d8a8a0"))
	for x in [-47,47]: draw_circle(Vector2(x,-49),16,Color("8e7a82"))
	_ellipse(Vector2(0,-46),Vector2(52,28),Color("ead9a0"))
	draw_line(Vector2(-53,-39),Vector2(53,-39),INK,6,true)
	draw_circle(Vector2(0,-53),10,PAPER)
	_eyes(Vector2(0,-20),pose)
	draw_line(Vector2(63,26),Vector2(91,-93),Color("c8a880"),12,true)
	draw_rect(Rect2(57,-116,75,35),Color("c8a880"))
	draw_rect(Rect2(57,-116,75,35),INK,false,3)

func _glim(pose: String) -> void:
	var spread := 105.0 if pose in ["cheer","celebrate","wave"] else 63.0
	draw_colored_polygon(PackedVector2Array([Vector2(0,32),Vector2(-spread,-59),Vector2(-50,5),Vector2(0,51),Vector2(50,5),Vector2(spread,-59)]),Color("7a6a64"))
	draw_circle(Vector2(0,-35),38,Color("7a6a64"))
	for sign in [-1,1]: draw_colored_polygon(PackedVector2Array([Vector2(sign*17,-58),Vector2(sign*41,-113),Vector2(sign*46,-46)]),Color("e3b49a"))
	_eyes(Vector2(0,-40),pose)
	draw_rect(Rect2(36,11,44,26),Color("2e4470"))
	draw_line(Vector2(41,23),Vector2(73,23),PAPER,2)

func _animal(id: String, pose: String) -> void:
	var colors := {"pip":"c9a27e","miller":"838780","mallow":"f2e8d8","pebble":"526a7a","puff":"d3b273","cinder":"c89476","chip":"b39171","nugget":"b9a07a","tock":"97a797","glitch":"76ada9","comet":"b0a2ba","crumb":"9c93a8","meringue":"ead6bb","sniffles":"dde4df","crab":"c9987f","smolder":"9c8072","oak":"aa9371","geode":"afa9b7","cuckoo":"c9a279","mirrorball":"a8b7be","moon":"d6c9a8"}
	var body := Color(str(colors.get(id,"b0b5a7")))
	var boss := id in ["miller","meringue","madame_meringue","sniffles","big_sniffles","admiral_crab","crab","geode","moon","oak","smolder","cuckoo","mirrorball"]
	var radius := 73.0 if boss else 58.0
	if id in ["mallow","meringue","madame_meringue"]:
		_ellipse(Vector2.ZERO,Vector2(radius,71),body)
		for sign in [-1,1]: _ellipse(Vector2(sign*29,-104),Vector2(14,52),body)
	elif id in ["puff","cinder","comet"]:
		draw_circle(Vector2.ZERO,radius,body)
		for i in 8: draw_line(Vector2.from_angle(i*TAU/8)*radius,Vector2.from_angle(i*TAU/8)*(radius+13),INK,3,true)
	else:
		for sign in [-1,1]:
			draw_circle(Vector2(sign*43,-55),27 if id=="pip" else 19,body)
			draw_circle(Vector2(sign*43,-55),14,Color("e3b49a"))
		_ellipse(Vector2.ZERO,Vector2(radius,radius+6),body)
	if id=="miller":
		draw_colored_polygon(PackedVector2Array([Vector2(-15,-65),Vector2(15,-65),Vector2(31,30),Vector2(-31,30)]),PAPER)
		_ellipse(Vector2(0,-75),Vector2(58,20),Color("75856b"))
	if id=="pebble": _ellipse(Vector2(0,18),Vector2(39,46),PAPER)
	if id=="crab":
		for sign in [-1,1]:
			draw_line(Vector2(sign*50,0),Vector2(sign*95,-38),INK,8,true)
			draw_arc(Vector2(sign*100,-49),22,0,PI,16,body,14,true)
	if id=="oak":
		for sign in [-1,1]:
			draw_line(Vector2(sign*60,0),Vector2(sign*100,-64),body,12,true)
			draw_circle(Vector2(sign*94,-71),28,Color("96a888"))
	if id=="smolder":
		draw_colored_polygon(PackedVector2Array([Vector2(-29,-53),Vector2(-14,-102),Vector2(4,-71),Vector2(30,-106),Vector2(36,-47)]),Color("d8b28b"))
	if id=="cuckoo":
		draw_colored_polygon(PackedVector2Array([Vector2(-12,0),Vector2(20,0),Vector2(0,24)]),Color("dfba7e"))
	if id=="mirrorball":
		for x in [-40,-20,0,20,40]: draw_line(Vector2(x,-50),Vector2(x,50),Color("d8e0da"),2,true)
		for y in [-40,-20,0,20,40]: draw_line(Vector2(-50,y),Vector2(50,y),Color("d8e0da"),2,true)
	if id=="moon": _star(Vector2(48,-65),15,Color("e6cb88"))
	_eyes(Vector2(0,-19),pose)
	if id=="pip": _prop("basket",Vector2(37,58),.60)
	if id in ["tock","glitch"]:
		draw_rect(Rect2(-34,10,68,23),Color("d8c6a8"))
		for x in [-20,0,20]: draw_circle(Vector2(x,21),5,INK)

func _eyes(at: Vector2, pose: String) -> void:
	var sad := pose in ["sad","sigh","sleep","duck"]
	for x in [-17,17]:
		if sad: draw_line(at+Vector2(x-7,0),at+Vector2(x+7,3),INK,3,true)
		else: draw_circle(at+Vector2(x,0),4,INK)
	draw_arc(at+Vector2(0,9),12,0.2,PI-.2,16,INK,3,true)

func _bubble(emote: String) -> void:
	draw_circle(Vector2.ZERO,39,INK)
	draw_circle(Vector2.ZERO,36,PAPER)
	draw_colored_polygon(PackedVector2Array([Vector2(-9,28),Vector2(-2,54),Vector2(14,27)]),PAPER)
	_prop(emote,Vector2.ZERO,.55)

func _prop(id: String, at: Vector2, scale: float) -> void:
	# Reset explicitly after this helper; all following shapes are in theatre coordinates.
	var old_at := at
	match id:
		"heart":
			draw_circle(at+Vector2(-17,-8)*scale,20*scale,Color("d79682"))
			draw_circle(at+Vector2(17,-8)*scale,20*scale,Color("d79682"))
			draw_colored_polygon(PackedVector2Array([at+Vector2(-36,-3)*scale,at+Vector2(36,-3)*scale,at+Vector2(0,38)*scale]),Color("d79682"))
		"question", "exclaim", "dots", "note", "dizzy":
			var glyph: String = {"question":"?","exclaim":"!","dots":"···","note":"♪","dizzy":"@"}[id]
			draw_string(ThemeDB.fallback_font,at+Vector2(-19,18)*scale,glyph,HORIZONTAL_ALIGNMENT_CENTER,50*scale,roundi(58*scale),INK)
		"sleep":
			draw_string(ThemeDB.fallback_font,at+Vector2(-27,18)*scale,"zZ",HORIZONTAL_ALIGNMENT_CENTER,70*scale,roundi(42*scale),INK)
		"tear", "sweat":
			draw_colored_polygon(PackedVector2Array([at+Vector2(0,-34)*scale,at+Vector2(-20,9)*scale,at+Vector2(20,9)*scale]),Color("86b6ca"))
			draw_circle(at+Vector2(0,9)*scale,20*scale,Color("86b6ca"))
		"sparkle", "star": _star(at,34*scale,Color("e6cb88"))
		"idea":
			draw_circle(at+Vector2(0,-11)*scale,24*scale,Color("e6cb88"))
			draw_rect(Rect2(at+Vector2(-13,13)*scale,Vector2(26,15)*scale),INK)
			for i in 5: draw_line(at+Vector2.from_angle(i*PI/4+PI)*33*scale,at+Vector2.from_angle(i*PI/4+PI)*42*scale,INK,3*scale,true)
		"blush":
			for x in [-22,22]: _ellipse(at+Vector2(x,0)*scale,Vector2(13,8)*scale,Color("d79682"))
		"angry":
			for i in 4: draw_arc(at+Vector2.from_angle(i*PI/2)*18*scale,15*scale,i*PI/2+.5,i*PI/2+1.0,8,Color("b77467"),4*scale,true)
		"gloom", "cloud":
			for x in [-22,0,22]: draw_circle(at+Vector2(x,-5)*scale,22*scale,Color("99a4af"))
		"smug":
			for x in [-15,15]: draw_line(at+Vector2(x-7,-7)*scale,at+Vector2(x+7,-7)*scale,INK,3*scale,true)
			draw_arc(at,21*scale,.2,PI-.2,16,INK,3*scale,true)
		"invite":
			draw_rect(Rect2(at+Vector2(-35,-25)*scale,Vector2(70,50)*scale),Color("b8ddc7"))
			draw_line(at+Vector2(-35,-25)*scale,at+Vector2(0,7)*scale,INK,2*scale,true)
			draw_line(at+Vector2(35,-25)*scale,at+Vector2(0,7)*scale,INK,2*scale,true)
		"seed", "acorn":
			_ellipse(at+Vector2(0,7)*scale,Vector2(23,29)*scale,Color("bc9670"))
			draw_arc(at+Vector2(0,-12)*scale,25*scale,PI,TAU,24,INK,8*scale,true)
			draw_line(at+Vector2(0,-19)*scale,at+Vector2(8,-38)*scale,INK,4*scale,true)
			if id=="seed": _ellipse(at+Vector2(22,-31)*scale,Vector2(17,9)*scale,Color("a1bd8a"))
		"bed":
			draw_rect(Rect2(at+Vector2(-41,-5)*scale,Vector2(82,34)*scale),Color("a3bdd0"))
			draw_rect(Rect2(at+Vector2(-37,-21)*scale,Vector2(28,20)*scale),PAPER)
			for x in [-41,41]: draw_line(at+Vector2(x,-28)*scale,at+Vector2(x,39)*scale,INK,6*scale,true)
		"wind":
			for y in [-22,0,22]:
				draw_line(at+Vector2(-37,y)*scale,at+Vector2(17,y)*scale,Color("7d9cab"),4*scale,true)
				draw_arc(at+Vector2(18,y-8)*scale,10*scale,-PI/2,PI/2,18,Color("7d9cab"),4*scale,true)
		"mushroom":
			draw_rect(Rect2(at+Vector2(-9,0)*scale,Vector2(18,36)*scale),PAPER)
			draw_arc(at,37*scale,PI,TAU,24,Color("cfaa80"),32*scale,true)
			for x in [-19,0,19]: draw_circle(at+Vector2(x,-18)*scale,5*scale,PAPER)
		"flower":
			for i in 5: draw_circle(at+Vector2.from_angle(i*TAU/5)*23*scale,16*scale,PAPER)
			draw_circle(at,13*scale,Color("e0be78"))
		"fog":
			for y in [-15,8]:
				for x in [-25,0,25]: draw_circle(at+Vector2(x,y)*scale,21*scale,Color("b5c3c4"))
		"dew", "ember":
			var color := Color("8bb8c4") if id=="dew" else Color("d5a274")
			draw_colored_polygon(PackedVector2Array([at+Vector2(0,-39)*scale,at+Vector2(-23,12)*scale,at+Vector2(23,12)*scale]),color)
			draw_circle(at+Vector2(0,11)*scale,23*scale,color)
		"flip":
			draw_arc(at,30*scale,-PI*.7,PI*.7,24,Color("7d9cab"),6*scale,true)
			draw_colored_polygon(PackedVector2Array([at+Vector2(-13,26)*scale,at+Vector2(-43,20)*scale,at+Vector2(-20,6)*scale]),INK)
		"mill":
			draw_colored_polygon(PackedVector2Array([at+Vector2(-32,40)*scale,at+Vector2(-19,-20)*scale,at+Vector2(19,-20)*scale,at+Vector2(32,40)*scale]),Color("bc9670"))
			for i in 4: draw_line(at,at+Vector2.from_angle(i*PI/2+.6)*46*scale,INK,10*scale,true)
			draw_circle(at,9*scale,Color("e0be78"))
		"ice":
			draw_colored_polygon(PackedVector2Array([at+Vector2(0,-39)*scale,at+Vector2(31,-14)*scale,at+Vector2(23,30)*scale,at+Vector2(-23,30)*scale,at+Vector2(-31,-14)*scale]),Color("a3c6d2"))
			draw_line(at+Vector2(0,-39)*scale,at+Vector2(7,30)*scale,PAPER,3*scale)
		"lantern":
			draw_arc(at+Vector2(0,-24)*scale,17*scale,PI,TAU,18,INK,4*scale,true)
			draw_rect(Rect2(at+Vector2(-26,-21)*scale,Vector2(52,58)*scale),Color("dbc799"))
			draw_rect(Rect2(at+Vector2(-26,-21)*scale,Vector2(52,58)*scale),INK,false,3*scale)
			draw_line(at+Vector2(0,-21)*scale,at+Vector2(0,37)*scale,INK,3*scale)
		"bridge":
			draw_line(at+Vector2(-47,-20)*scale,at+Vector2(47,-20)*scale,INK,4*scale)
			for x in [-36,-18,0,18,36]:
				draw_rect(Rect2(at+Vector2(x-7,0)*scale,Vector2(14,22)*scale),Color("bc9670"))
				draw_line(at+Vector2(x,-20)*scale,at+Vector2(x,22)*scale,INK,2*scale)
		"gear", "clock":
			if id=="gear":
				for i in 8: draw_circle(at+Vector2.from_angle(i*TAU/8)*33*scale,10*scale,Color("b6a989"))
			draw_circle(at,31*scale,Color("b6a989"))
			draw_circle(at,23*scale,PAPER)
			draw_line(at,at+Vector2(0,-16)*scale,INK,4*scale)
			draw_line(at,at+Vector2(14,8)*scale,INK,4*scale)
		"moon":
			draw_circle(at,35*scale,Color("dbc799"))
			draw_circle(at+Vector2(18,-13)*scale,30*scale,Color("e6eddd"))
		"hat":
			draw_colored_polygon(PackedVector2Array([at+Vector2(-36,26)*scale,at+Vector2(7,-44)*scale,at+Vector2(36,26)*scale]),Color("7893b9"))
			draw_line(at+Vector2(-43,26)*scale,at+Vector2(43,26)*scale,INK,5*scale,true)
		"cube":
			var a := at+Vector2(0,-34)*scale
			var b := at+Vector2(34,-17)*scale
			var c := at+Vector2(0,0)*scale
			var d := at+Vector2(-34,-17)*scale
			draw_colored_polygon(PackedVector2Array([a,b,c,d]),Color("a3c6bd"))
			draw_colored_polygon(PackedVector2Array([d,c,c+Vector2(0,40)*scale,d+Vector2(0,40)*scale]),Color("8eaaa2"))
			draw_colored_polygon(PackedVector2Array([c,b,b+Vector2(0,40)*scale,c+Vector2(0,40)*scale]),Color("6e8882"))
		"cup":
			draw_arc(at+Vector2(24,0)*scale,17*scale,-PI/2,PI/2,20,Color("bc9670"),7*scale,true)
			draw_rect(Rect2(at+Vector2(-25,-24)*scale,Vector2(50,50)*scale),Color("dbc799"))
			_ellipse(at+Vector2(0,-24)*scale,Vector2(25,8)*scale,INK)
		"basket", "cake", "tower", "chair", "egg", "pearl", "yarn", "keepsake":
			if id in ["egg","pearl","yarn"]: _ellipse(at,Vector2(30,36)*scale,Color("e6d3a9"))
			elif id=="chair":
				draw_rect(Rect2(at+Vector2(-27,-37)*scale,Vector2(54,40)*scale),Color("c8a880"))
				draw_line(at+Vector2(-28,7)*scale,at+Vector2(28,7)*scale,INK,7*scale,true)
				for x in [-23,23]: draw_line(at+Vector2(x,7)*scale,at+Vector2(x,40)*scale,INK,5*scale,true)
			else:
				var layers := 3 if id=="tower" else 1
				for i in layers: draw_rect(Rect2(at+Vector2(-35,-i*30-5)*scale,Vector2(70,30)*scale),Color("c89476").lightened(i*.08))
				if id=="basket": draw_arc(at+Vector2(0,-7)*scale,34*scale,PI,TAU,24,INK,5*scale,true)
		_: # Ribboned parcel is the campaign's shared visual bridge.
			draw_rect(Rect2(old_at-Vector2(34,28)*scale,Vector2(68,56)*scale),Color("e6d3a9"))
			draw_line(at+Vector2(0,-28)*scale,at+Vector2(0,28)*scale,Color("8a6aae"),8*scale)
			draw_line(at+Vector2(-34,0)*scale,at+Vector2(34,0)*scale,Color("8a6aae"),8*scale)

func _star(at: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 10: points.append(at+Vector2.from_angle(i*TAU/10-PI/2)*(radius if i%2==0 else radius*.42))
	draw_colored_polygon(points,color)
