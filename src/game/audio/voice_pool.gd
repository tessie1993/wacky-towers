class_name VoicePool extends RefCounted
## Pre-made players with voice stealing (ADR-0015 section 4). Lower priority number = more important.
## Same cue inside its cooldown is dropped; a cue at max_voices restarts its oldest copy; a full pool
## steals the lowest priority, then the oldest; a new cue that is less important than everything is dropped.
## Voice lifetime is judged by the injected clock, so tests are deterministic.

var _players: Array[AudioStreamPlayer]
var _now: Callable
var _voices: Array[Dictionary] = []
var _last_play: Dictionary = {}
var _next_handle: int = 1


## `now_ms` is a Callable returning milliseconds (presentation time only).
func _init(players: Array[AudioStreamPlayer], now_ms: Callable) -> void:
	_players = players
	_now = now_ms
	for i: int in players.size():
		_voices.append({"cue": -1, "prio": 9, "start": 0, "end": 0, "handle": 0})


## Plays a cue. Returns a voice handle, or -1 when dropped.
func play(cue: CueDef, cue_index: int, pitch_scale: float, volume_db: float) -> int:
	var now: int = _now.call()
	if cue.cooldown_ms > 0 and _last_play.has(cue_index) and now - int(_last_play[cue_index]) < cue.cooldown_ms:
		return -1
	var slot: int = -1
	var copies: int = 0
	var oldest_copy: int = -1
	for i: int in _voices.size():
		if _is_active(i, now) and _voices[i]["cue"] == cue_index:
			copies += 1
			if oldest_copy < 0 or _voices[i]["start"] < _voices[oldest_copy]["start"]:
				oldest_copy = i
	if copies >= cue.max_voices:
		slot = oldest_copy
	else:
		for i: int in _voices.size():
			if not _is_active(i, now):
				slot = i
				break
		if slot < 0:
			slot = _victim(cue.priority, now)
	if slot < 0:
		return -1
	var handle: int = _next_handle
	_next_handle += 1
	var length_ms: int = int(cue.length_s * 1000.0 / maxf(pitch_scale, 0.1))
	_voices[slot] = {"cue": cue_index, "prio": cue.priority, "start": now, "end": now + length_ms, "handle": handle}
	_last_play[cue_index] = now
	var p: AudioStreamPlayer = _players[slot]
	p.stream = cue.stream
	p.pitch_scale = pitch_scale
	p.volume_db = volume_db
	if p.is_inside_tree():
		p.play()
	return handle


## Stops a voice by handle; a stale handle is a no-op.
func stop_voice(handle: int) -> void:
	for i: int in _voices.size():
		if _voices[i]["handle"] == handle:
			_voices[i]["end"] = 0
			_voices[i]["handle"] = 0
			_players[i].stop()
			return


## Cue index playing in each slot (-1 when free) at the current clock time.
func active_cues() -> PackedInt32Array:
	var now: int = _now.call()
	var out := PackedInt32Array()
	for i: int in _voices.size():
		out.append(_voices[i]["cue"] if _is_active(i, now) else -1)
	return out


func _is_active(i: int, now: int) -> bool:
	return int(_voices[i]["end"]) > now


func _victim(new_priority: int, now: int) -> int:
	var best: int = -1
	for i: int in _voices.size():
		if best < 0 or _voices[i]["prio"] > _voices[best]["prio"] \
				or (_voices[i]["prio"] == _voices[best]["prio"] and _voices[i]["start"] < _voices[best]["start"]):
			best = i
	if best >= 0 and int(_voices[best]["prio"]) < new_priority:
		return -1
	return best
