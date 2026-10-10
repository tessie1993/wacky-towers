# CH-009 BoardSpec fuzz test (1000 hostile dicts)

**Story:** BRD-001
**Goal:** prove `BoardSpec.parse` never crashes, never returns a spec over the caps, and never exceeds `max_errors` (ADR-0002 Validation Criteria 3). Test only — no production code.
**Depends:** CH-008
**Parallel-safe with:** CH-001 (and anything not touching board_spec*)
**Files:** `tests/unit/board_grid/board_spec_fuzz_test.gd` (new)

## What to write

- Deterministic: `var rng := Seeds.make_rng(20261010, [&"board_fuzz"])` (ADR-0006; never global `randi`).
- Generator `_hostile(rng) -> Dictionary`: pick 0–9 keys from
  `["width","depth","h_play","down_axis","mask","spawn_anchor","starting_contents","widht","",  "x".repeat(200)]`,
  each with a value drawn from a pool:
  `[NAN, INF, -INF, -1.0, 0.0, 3.0, 4.0, 6.0, 6.5, 8.0, 24.0, 25.0, 1e9, 1e18, -1e18, "6", "-y", "+q", true, null, [], {}, [1.0], [0.0, 0.0], [6.0, 6.0],
  ["######"], ["####", "#x##"], {"layers": {}}, {"layers": {"0": ["#"]}}, {"layers": {"99999999": []}}, {"layers": 5}]`
  plus, 1 in 10 times, a mask of `rng.randi_range(0, 30)` rows each `"#".repeat(rng.randi_range(0, 30))`.
- Also three fixed cases first: `{"width": 1e9, "depth": 1e9, "h_play": 1e9}`, `{"width": 24.0, "depth": 24.0, "h_play": 28.0}`, `{}`.

## Tests

1. `test_fuzz_1000_dicts` — for 1000 generated dicts (+ the 3 fixed), with `BoardLimits.new()` and the CH-003 types:
   - `result.errors.size() <= limits.max_errors`
   - `(result.spec == null) == (not result.errors.is_empty())`
   - if spec: `limits.min_side <= size.x, size.z <= limits.max_side`, `size.x * size.y * size.z <= limits.max_cells`,
     `mask.size() == size.x * size.z`, every `contents[i].cell` inside size.
2. `test_fuzz_low_error_cap` — same loop for 200 dicts with `limits.max_errors = 2`: `errors.size() <= 2`.

If a case crashes or fails: **do not change board_spec.gd** — copy the failing dict into the ticket as a comment, set status `blocked (fuzz found: …)`, and stop. The lead writes the fix ticket.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + both tests green; whole `board_grid` folder green.
