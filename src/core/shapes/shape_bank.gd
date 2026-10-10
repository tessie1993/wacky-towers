class_name ShapeBank extends Resource
## All piece shapes, loaded once from res://assets/data/shapes/shape_bank.tres (ADR-0003).

@export var shapes: Array[ShapeDef] = []


## The shape with this id, or null if unknown; first match wins. Usage: `bank.get_shape(&"i")`.
func get_shape(id: StringName) -> ShapeDef:
	# ponytail: linear scan of ~67 shapes at spawn/validate time; add a Dictionary index if a profile shows it.
	for def: ShapeDef in shapes:
		if def != null and def.shape_id == id:
			return def
	return null


## True if a shape with this id exists. Usage: `bank.has_shape(&"i")`.
func has_shape(id: StringName) -> bool:
	return get_shape(id) != null


## All shape ids in bank order. Usage: `for id in bank.ids(): ...`.
func ids() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for def: ShapeDef in shapes:
		if def != null:
			out.append(String(def.shape_id))
	return out
