class_name GameCatalog extends RefCounted
## Everything trusted, loaded once at boot and injected (implementation-plan 2.1). Immutable after boot by convention.

## Shape bank.
var shapes: ShapeBank
## Content type table.
var content: ContentTypes
## Knob definitions.
var knob_defs: KnobDefs
## Rule definitions by id.
var rule_defs: Dictionary[StringName, RuleDef] = {}
## Rule/plugin class registry.
var plugins: PluginRegistry
## Block colour palette.
var palette: PackedColorArray = PackedColorArray()
## Board size limits.
var limits: BoardLimits
