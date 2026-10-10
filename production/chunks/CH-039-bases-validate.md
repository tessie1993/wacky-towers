# CH-039 validate() on the four existing plugin bases

**Story:** RUL-001
**Goal:** every plugin can add its own level checks (ADR-0005 "Plugins may add checks"; gap decision 4).
**Depends:** CH-021, CH-034, CH-037
**Parallel-safe with:** CH-040, CH-041, CH-042 … CH-050, CH-054
**Files:** edit `src/core/rules/bases/rule_behaviour.gd`, `clear_detector.gd`, `collapse_policy.gd`, `arrival_style.gd`;
`tests/unit/rules/plugin_bases_test.gd` (edit: append)

## API (add to each of the four bases, identical)

```gdscript
func validate(level: LevelData, catalog: GameCatalog) -> Array[ValidationIssue]:
	## Extra checks this plugin needs on a level (e.g. "conveyor needs an unmasked board"). Default: none.
	return []
```

Non-abstract, so plugins override only when they need to.

## Tests to write first (append)

1. `test_default_validate_is_empty` — `TestOnlyDetector.new().validate(LevelData.new(), GameCatalog.new()).is_empty()`; same for an inner `RuleBehaviour` subclass.
2. `test_validate_override_returns_issues` — inner test class `extends CollapsePolicy` overriding `validate` to return one `ValidationIssue.error(...)` (and implementing `collapse` as `pass`): result size 1, `is_error()`.

## Run
`-a res://tests/unit/rules` (README).

## Done when
README "Done when" + all rules tests green.
