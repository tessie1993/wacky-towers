class_name AudioBuses extends RefCounted
## Bus names, slider math and bus lookup for res://default_bus_layout.tres (ADR-0015 section 2).

const MASTER := &"Master"
const MUSIC := &"Music"
const SFX := &"SFX"
const UI := &"UI"
const AMBIENCE := &"Ambience"
const ALL: Array[StringName] = [MASTER, MUSIC, SFX, UI, AMBIENCE]
## dB reported for a 0 % slider; the bus is also muted.
const SILENT_DB := -80.0

## Layout trims remembered the first time a bus is touched (-6 / 0 / -3 / -12 by default).
static var _base_db: Dictionary = {}


## Slider value (0..1, or 0..100) to normalized linear gain.
static func normalize(value: float) -> float:
	return clampf(value / 100.0 if value > 1.0 else value, 0.0, 1.0)


## F1: linear slider gain to dB. 0.5 gives -6.02 dB; 0 gives SILENT_DB.
static func slider_to_db(linear: float) -> float:
	return SILENT_DB if linear <= 0.0 else maxf(SILENT_DB, linear_to_db(linear))


## Index of a bus by name, or -1 (a missing bus is a warning, never a crash).
static func index_of(bus: StringName) -> int:
	var i: int = AudioServer.get_bus_index(bus)
	if i < 0:
		push_warning("AudioBuses: missing bus %s (is default_bus_layout.tres loaded?)" % bus)
	return i


## Layout trim of a bus in dB (read once, before any slider touches it).
static func base_db(bus: StringName) -> float:
	if not _base_db.has(bus):
		var i: int = index_of(bus)
		_base_db[bus] = AudioServer.get_bus_volume_db(i) if i >= 0 else 0.0
	return float(_base_db[bus])


## Sets a bus to layout trim + slider dB. 0 gain mutes only that bus.
static func set_slider(bus: StringName, linear: float) -> void:
	var i: int = index_of(bus)
	if i < 0:
		return
	var base: float = base_db(bus)
	AudioServer.set_bus_mute(i, linear <= 0.0)
	AudioServer.set_bus_volume_db(i, base + slider_to_db(linear) if linear > 0.0 else SILENT_DB)


## First effect of a class on a bus, or null.
static func find_effect(bus: StringName, effect_class: String) -> AudioEffect:
	var i: int = AudioServer.get_bus_index(bus)
	for e: int in AudioServer.get_bus_effect_count(i) if i >= 0 else 0:
		var fx: AudioEffect = AudioServer.get_bus_effect(i, e)
		if fx.is_class(effect_class):
			return fx
	return null


## Enables or disables the first effect of a class on a bus.
static func enable_effect(bus: StringName, effect_class: String, on: bool) -> void:
	var i: int = AudioServer.get_bus_index(bus)
	for e: int in AudioServer.get_bus_effect_count(i) if i >= 0 else 0:
		if AudioServer.get_bus_effect(i, e).is_class(effect_class):
			AudioServer.set_bus_effect_enabled(i, e, on)
			return
