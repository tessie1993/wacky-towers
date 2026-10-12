class_name WtMinigameAudio extends RefCounted
## Maps party-minigame (MG22-MG36) sim events and accepted player commands to
## sfx ids in res://assets/audio/sfx/. Pure lookup: no nodes, no playback.
## The caller plays the result with WtAudio.cue(id); &"" means "no sound".
## Source of the cues: tools/asset-pipeline/generate_audio_wave2.py.
## Cue list: design/gdd/audio/sfx-cue-list.md section 9.

## Event kind (WtMinigameSession.emit) or command kind (SimCommand.kind) -> sfx id.
const MAP: Dictionary = {
	# --- outcome events emitted by rules_c.gd / rules_d.gd
	&"mg_bowl_release": &"mg_bowl_roll",
	&"mg_strike": &"mg_strike",
	&"mg_spare": &"mg_pin_knock",
	&"mg_simon_miss": &"mg_wrong",
	&"mg_quick_drop_bonus": &"mg_go",
	&"mg_false_start": &"mg_false_start",
	&"mg_count_correct": &"mg_correct",
	&"mg_count_wrong": &"mg_wrong",
	&"mg_odd_wrong": &"mg_wrong",
	&"mg_dodge_hit": &"mg_dodge_hit",
	&"mg_slide_solved": &"mg_spin_match",
	&"mg_mirror_scored": &"mg_card_match",
	&"mg_plinko_landed": &"mg_plinko_bucket",
	&"mg_tower_toppled": &"mg_topple",
	&"mg_treasure_found": &"mg_treasure",
	&"mg_setup_error": &"",
	# --- shared party plumbing (sends and attacks)
	&"mg_send": &"mg_send",
	&"mg_send_charged": &"mg_send",
	&"mg_attack_warning": &"mg_attack_warning",
	&"mg_receive_attack": &"mg_attack_warning",
	&"mg_attack_applied": &"mg_dodge_hit",
	# --- player commands (play when the rules accept the command)
	&"mg_tap": &"mg_parade_tick",
	&"mg_pick": &"mg_odd_pick",
	&"mg_answer": &"mg_odd_pick",
	&"mg_flip": &"mg_card_flip",
	&"mg_step": &"mg_parade_tick",
	&"mg_slide": &"mg_slide_tile",
	&"mg_paint": &"mg_paint_dab",
	&"mg_whack": &"mg_whack_bonk",
	&"mg_pull": &"mg_jenga_pull",
	&"mg_rotate": &"mg_spin_click",
	&"mg_aim": &"mg_spin_click",
	&"mg_dig": &"mg_dig_shovel",
}

## Simon pads 0..3 are four pitched tones (C5 E5 G5 C6).
const SIMON_PADS: Array[StringName] = [&"mg_simon_0", &"mg_simon_1", &"mg_simon_2", &"mg_simon_3"]

## Whack-a-block pop kinds (state.pops[i].kind) -> sfx id.
const WHACK: Dictionary = {&"block": &"mg_whack_bonk", &"bomb": &"mg_whack_bomb", &"golden": &"mg_whack_golden"}


## Sfx id for an event or command kind; &"" when the kind has no cue.
static func sfx_for(event_kind: StringName) -> StringName:
	return MAP.get(event_kind, &"")


## Payload-aware variant: Simon pad pitch, Plinko jackpot, Pairs match.
## `data` is SimEvent.data or the command's args dictionary.
static func sfx_for_data(event_kind: StringName, data: Dictionary) -> StringName:
	match event_kind:
		&"mg_pad":
			var pad: int = int(data.get("pad", -1))
			return SIMON_PADS[pad] if pad >= 0 and pad < SIMON_PADS.size() else &""
		&"mg_plinko_landed":
			return &"mg_jackpot" if bool(data.get("jackpot", false)) else &"mg_plinko_bucket"
		&"mg_flip":
			return &"mg_card_match" if bool(data.get("matched", false)) else &"mg_card_flip"
	return sfx_for(event_kind)


## Sfx id for a whack hit, given the pop kind the player struck.
static func sfx_for_whack(pop_kind: StringName) -> StringName:
	return WHACK.get(pop_kind, &"mg_whack_bonk")
