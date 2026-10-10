class_name WtStoryData extends RefCounted
## Wordless campaign staging, separate from rules, unlocks and save transactions.
const SOURCE: String = "res://assets/data/story/campaign_skits.json"
const MASCOTS := {"meadow":"pip","candy":"mallow","ice":"pebble","underwater":"puff","lava":"cinder","forest":"chip","cave":"nugget","clockwork":"tock","neon":"glitch","celestial":"comet"}
const BOSSES := {"meadow":"miller","candy":"meringue","ice":"sniffles","underwater":"crab","lava":"smolder","forest":"oak","cave":"geode","clockwork":"cuckoo","neon":"mirrorball","celestial":"moon"}
static var _data: Dictionary = {}


static func snapshot(level_id: StringName, phase: String, replay: bool = false) -> Dictionary:
	if _data.is_empty(): _data=JSON.parse_string(FileAccess.get_file_as_string(SOURCE))
	var record: Dictionary = _data.get("stories",{}).get(str(level_id),{})
	if record.is_empty(): return {}
	var key: String = "replay_post" if phase=="post" and replay and record.has("replay_post") else phase
	return {"biome":record.biome,"level_name":record.level_name,"story_key":str(level_id)+"_"+phase,"phase":phase,
		"beats":record.get(key,[]).duplicate(true)}


static func lighting(level_id: StringName) -> Dictionary:
	if not str(level_id).begins_with("meadow_"): return {}
	var slot: int = str(level_id).get_slice("_",1).to_int()
	match slot:
		2: return {"time":"bedtime","sky":"#AEBED2","key":"#D6DBF0","key_energy":.35,"ambient":.36}
		3,4: return {"time":"breezy_day","sky":"#D4E6E6","key":"#FFF2D9","key_energy":.64,"ambient":.32}
		5,6: return {"time":"late_afternoon","sky":"#E1E2D1","key":"#F5D8AF","key_energy":.67,"ambient":.32}
		7: return {"time":"dawn_fog","sky":"#BCCCD1","key":"#DCE4E1","key_energy":.37,"ambient":.40}
		8,9: return {"time":"morning","sky":"#CEDFDF","key":"#F3E8CC","key_energy":.61,"ambient":.34}
		10: return {"time":"golden_picnic","sky":"#E6DCC7","key":"#EFD0A0","key_energy":.70,"ambient":.32}
		_: return {"time":"first_morning","sky":"#CEE5E5","key":"#FFF4DA","key_energy":.65,"ambient":.32}


static func environment(level_id: StringName) -> Dictionary:
	if _data.is_empty():_data=JSON.parse_string(FileAccess.get_file_as_string(SOURCE))
	var record: Dictionary=_data.get("stories",{}).get(str(level_id),{})
	if record.is_empty():return {}
	var number: int=str(level_id).get_slice("_",1).to_int()
	var intro: Array=record.get("pre",[])
	var payoff: Array=record.get("post",[])
	return {"hero":intro[0].get("symbol","gift") if not intro.is_empty() else "gift",
		"clue":payoff[-1].get("symbol","") if not payoff.is_empty() else "",
		"layout_slot":number-1,"biome":record.biome,"source_intent":record.source_intent}
