class_name VetoResult extends RefCounted
## Outcome of a veto-able hook. Usage: `if result.vetoed: log(result.rule_id)`.

## True when a rule vetoed the action.
var vetoed: bool = false
## Which rule vetoed; &"" when not vetoed.
var rule_id: StringName = &""
