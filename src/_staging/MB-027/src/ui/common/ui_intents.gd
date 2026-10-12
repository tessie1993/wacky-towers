## Intent ids screens emit via [signal UiScreen.intent]; AppFlow is the only listener (ADR-0016 §3).
class_name UiIntents
extends RefCounted

const BACK: StringName = &"back"
const PLAY: StringName = &"play"
const CONTINUE: StringName = &"continue"
const OPEN_MAP: StringName = &"open_map"
const OPEN_SETTINGS: StringName = &"open_settings"
const OPEN_PROFILES: StringName = &"open_profiles"
const PAUSE: StringName = &"pause"
const RESUME: StringName = &"resume"
const RETRY: StringName = &"retry"
const NEXT: StringName = &"next"
const TO_MAP: StringName = &"to_map"
const SET_PREF: StringName = &"set_pref"
const SELECT_PROFILE: StringName = &"select_profile"
const CREATE_PROFILE: StringName = &"create_profile"
const DELETE_PROFILE: StringName = &"delete_profile"
const RENAME_PROFILE: StringName = &"rename_profile"
const OPEN_LEVEL: StringName = &"open_level"
const QUIT: StringName = &"quit"
