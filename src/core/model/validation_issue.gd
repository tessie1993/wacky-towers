class_name ValidationIssue extends RefCounted
## One problem found in level data (ADR-0005). Built by the validator, the loader and plugin validate().

const SEVERITY_ERROR := &"error"
const SEVERITY_WARN := &"warn"

## Level the problem belongs to.
var level_id: StringName = &""
## Dotted path of the offending field, e.g. "board.mask[2]".
var field: String = ""
## Short check id, e.g. &"unknown_key", &"out_of_range".
var rule: StringName = &""
## SEVERITY_ERROR or SEVERITY_WARN.
var severity: StringName = SEVERITY_ERROR
## Human-readable description.
var message: String = ""


## Builds an error issue. Usage: ValidationIssue.error(&"meadow_01", "board.width", &"out_of_range", "3 outside 4..24").
static func error(p_level_id: StringName, p_field: String, p_rule: StringName, p_message: String) -> ValidationIssue:
	return _make(SEVERITY_ERROR, p_level_id, p_field, p_rule, p_message)


## Builds a warning issue. Usage: ValidationIssue.warn(&"meadow_01", "rules[1]", &"unused", "never fires").
static func warn(p_level_id: StringName, p_field: String, p_rule: StringName, p_message: String) -> ValidationIssue:
	return _make(SEVERITY_WARN, p_level_id, p_field, p_rule, p_message)


## True when severity is error. Usage: if issue.is_error(): reject_level().
func is_error() -> bool:
	return severity == SEVERITY_ERROR


func _to_string() -> String:
	return "%s %s: %s [%s]" % [level_id, field, message, rule]


static func _make(p_severity: StringName, p_level_id: StringName, p_field: String, p_rule: StringName, p_message: String) -> ValidationIssue:
	var i: ValidationIssue = ValidationIssue.new()
	i.severity = p_severity
	i.level_id = p_level_id
	i.field = p_field
	i.rule = p_rule
	i.message = p_message
	return i
