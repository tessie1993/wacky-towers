class_name TitleSnapshot extends RefCounted
## Everything the title screen shows (ADR-0016 §7). Built by AppFlow; the screen keeps no state.

var has_profile: bool = false
var profile_name: String = ""
var profile_badge: StringName = &""
var profile_color: StringName = &""
## Next level to play (Continue target), e.g. &"meadow_04".
var continue_level_id: StringName = &""
## Stars earned on that level (0-3).
var continue_stars: int = 0
## True when the save is newer than this build (shows the lock badge).
var read_only_save: bool = false
