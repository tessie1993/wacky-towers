class_name LevelStage extends Node3D
## Presentation-only official stage descriptor; gameplay remains in the referenced JSON.
@export_file("*.json") var level_json: String = ""
@export var biome: StringName = &"meadow"
@export var lighting: StringName = &"day"
