class_name WtMinigameAudio extends RefCounted
## Maps party-minigame (MG22-MG36) sim events and accepted player commands to
## cue ids. Pure lookup: no nodes, no playback. The table lives in
## assets/data/audio/event_cues.json ("minigame"); AudioDirector.play_minigame plays it.
## &"" means "no sound".
## Source of the cues: tools/asset-pipeline/generate_audio_wave2.py.
## Cue list: design/gdd/audio/sfx-cue-list.md (minigame section still to be written).

## Event or command kind -> cue id from the data table.
static func sfx_for(event_kind: StringName) -> StringName:
	var table: Dictionary = EventCueMap.shared().data.get("minigame", {}).get("events", {})
	return StringName(table.get(String(event_kind), ""))


## Payload-aware variant: Simon pad pitch, Plinko jackpot, Pairs match.
## `data` is SimEvent.data or the command's args dictionary.
static func sfx_for_data(event_kind: StringName, data: Dictionary) -> StringName:
	var mg: Dictionary = EventCueMap.shared().data.get("minigame", {})
	match event_kind:
		&"mg_pad":
			var pads: Array = mg.get("simon_pads", [])
			var pad: int = int(data.get("pad", -1))
			return StringName(pads[pad]) if pad >= 0 and pad < pads.size() else &""
		&"mg_plinko_landed":
			return StringName(mg.get("plinko_jackpot" if bool(data.get("jackpot", false)) else "plinko_bucket", ""))
		&"mg_flip":
			return StringName(mg.get("card_match" if bool(data.get("matched", false)) else "card_flip", ""))
	return sfx_for(event_kind)


## Cue id for a whack hit, given the pop kind the player struck.
static func sfx_for_whack(pop_kind: StringName) -> StringName:
	var whack: Dictionary = EventCueMap.shared().data.get("minigame", {}).get("whack", {})
	return StringName(whack.get(String(pop_kind), whack.get("block", "")))
