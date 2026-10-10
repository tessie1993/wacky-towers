class_name ProfileStore extends WtProfileStore
## Compatibility name for the staged profile picker; uses the complete four-profile implementation.

## Trims names to the profile field’s twelve-character limit.
static func clean_name(raw: String) -> String:
	return raw.strip_edges().left(12)
