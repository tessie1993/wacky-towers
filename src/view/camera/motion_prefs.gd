class_name MotionPrefs extends RefCounted
## Reduced-motion value object (ADR-0014 §4). The owner calls refresh() at boot and on NOTIFICATION_APPLICATION_FOCUS_IN.
## Never reads a settings autoload; settings feed set_mode().

enum Mode { SYSTEM, ON, OFF }

var mode: Mode = Mode.SYSTEM
var reduced: bool = false  ## effective value, read by camera, VFX, HUD


## Recomputes `reduced`: ON -> true, OFF -> false, SYSTEM -> OS setting (OFF where unsupported).
func refresh() -> void:
	match mode:
		Mode.ON:
			reduced = true
		Mode.OFF:
			reduced = false
		_:
			reduced = _system_reduced()


## Sets the mode and refreshes.
func set_mode(m: Mode) -> void:
	mode = m
	refresh()


func _system_reduced() -> bool:
	# Not in docs/engine-reference: unverified, guarded so an unsupported build behaves as OFF.
	if not DisplayServer.has_method(&"accessibility_should_reduce_animation"):
		return false
	return DisplayServer.call(&"accessibility_should_reduce_animation")
