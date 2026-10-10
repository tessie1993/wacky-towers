class_name BoardSpecResult extends RefCounted
## Result of BoardSpec.parse: spec is null whenever errors is not empty.
## Usage: var r := BoardSpec.parse(d, limits, types); if r.errors.is_empty(): use(r.spec)

var spec: BoardSpec = null
var errors: PackedStringArray = PackedStringArray()
