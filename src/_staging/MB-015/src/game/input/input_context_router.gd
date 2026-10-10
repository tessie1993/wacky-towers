## Only caller of GUIDE.enable/disable_mapping_context for gameplay and menus
## (ADR-0012 §2). Exactly one context is active at a time (no stacking in MVP).
## Not an autoload; Main owns it.
class_name InputContextRouter
extends Node

## Screens the router can activate. Priority REMAP_CAPTURE > PLAY_PAUSED/MENU > PLAY
## is expressed by the caller choosing the screen; only one is ever enabled.
enum Ctx { PLAY, PLAY_PAUSED, MENU, REMAP_CAPTURE }

## Context for [constant Ctx.PLAY].
@export var play: GUIDEMappingContext = preload("res://src/game/input/contexts/play.tres")
## Context for [constant Ctx.PLAY_PAUSED].
@export var play_paused: GUIDEMappingContext = preload("res://src/game/input/contexts/play_paused.tres")
## Context for [constant Ctx.MENU].
@export var menu: GUIDEMappingContext = preload("res://src/game/input/contexts/menu.tres")
## Context for [constant Ctx.REMAP_CAPTURE].
@export var remap_capture: GUIDEMappingContext = preload("res://src/game/input/contexts/remap_capture.tres")

var _current: Ctx = Ctx.PLAY
var _active: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Disables every other router context and enables [param ctx].
func set_screen(ctx: Ctx) -> void:
	for c: int in Ctx.values():
		if c != ctx:
			var other: GUIDEMappingContext = _context_for(c as Ctx)
			if other:
				GUIDE.disable_mapping_context(other)
	_current = ctx
	_active = true
	reassert()


## Swaps the GUIDE remapping config safely: disable every router context, set the
## config, then re-enable the current one (GUIDE caches mappings per enabled context).
func apply_remapping_config(config: GUIDERemappingConfig) -> void:
	for c: int in Ctx.values():
		var ctx: GUIDEMappingContext = _context_for(c as Ctx)
		if ctx:
			GUIDE.disable_mapping_context(ctx)
	GUIDE.set_remapping_config(config)
	reassert()


## Returns the current screen.
func current() -> Ctx:
	return _current


## Re-enables the current context (after pause/resume). No-op before the first set_screen.
func reassert() -> void:
	if not _active:
		return
	var c: GUIDEMappingContext = _context_for(_current)
	if c:
		GUIDE.enable_mapping_context(c)


func _context_for(ctx: Ctx) -> GUIDEMappingContext:
	match ctx:
		Ctx.PLAY: return play
		Ctx.PLAY_PAUSED: return play_paused
		Ctx.MENU: return menu
		_: return remap_capture
