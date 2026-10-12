class_name LoadResult extends RefCounted
## Outcome of LevelLoader: the level plus every issue found (ADR-0005).
## Usage: var r: LoadResult = LevelLoader.load_level(path, catalog); if r.ok(): play(r.level)

## The parsed level; null when any error issue exists.
var level: LevelData = null
## Errors and warnings found while loading.
var issues: Array[ValidationIssue] = []


## True when a level was produced and no issue is an error. Usage: if result.ok(): use(result.level)
func ok() -> bool:
	if level == null:
		return false
	for i: ValidationIssue in issues:
		if i.is_error():
			return false
	return true
