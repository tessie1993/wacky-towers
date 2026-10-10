# CH-004 BoardState stub: Down enum + down_from_token + down_vector_of

**Story:** BRD-001 (needed by `BoardSpec.parse`); the rest of `BoardState` is BRD-002 (Wave 2), which extends this file.
**Goal:** the six gravity directions and their token / vector mapping (ADR-0002 §1), nothing else.
**Depends:** none
**Parallel-safe with:** CH-001, CH-002, CH-003, CH-005
**Files:** `src/core/board/board_state.gd` (new), `tests/unit/board_grid/board_state_down_test.gd` (new)

## API (ADR-0002 Key Interfaces + implementation-plan §1.2)

```gdscript
class_name BoardState extends RefCounted
## The board: one source of truth for what is where (ADR-0002). This ticket adds only the down-axis helpers.

enum Down { X_NEG, X_POS, Y_NEG, Y_POS, Z_NEG, Z_POS }   # ADR-0002 §1; default Y_NEG

const DOWN_TOKENS: Array[String] = ["-x", "+x", "-y", "+y", "-z", "+z"]   # ADR-0002 §6 check 5; same order as Down

static func down_from_token(token: String) -> int     ## "-y" -> Down.Y_NEG; -1 if not one of DOWN_TOKENS (exact, case-sensitive)
static func down_vector_of(d: int) -> Vector3i        ## unit vector of gravity; Vector3i.ZERO if d is not a Down value
```

## Behaviour

- `down_vector_of`: X_NEG `(-1,0,0)`, X_POS `(1,0,0)`, Y_NEG `(0,-1,0)`, Y_POS `(0,1,0)`, Z_NEG `(0,0,-1)`, Z_POS `(0,0,1)`.
- No `_init`, no storage yet. Do not add other `BoardState` methods (BRD-002 owns them).

## Tests to write first

1. `test_tokens_map_to_enum` — loop: `down_from_token(DOWN_TOKENS[i]) == i` for i in 0..5; `down_from_token("-y") == Down.Y_NEG`.
2. `test_bad_tokens_are_minus_one` — `"y"`, `"-Y"`, `" -y"`, `""`, `"+w"` -> -1.
3. `test_down_vectors_all_six` — the six vectors above.
4. `test_down_vector_bad_value_is_zero` — `down_vector_of(-1)` and `down_vector_of(6)` == `Vector3i.ZERO`.

## Run
`-a res://tests/unit/board_grid` (README).

## Done when
README "Done when" + 4 tests green.

## Out of scope
Storage, index math, layers, queries, mutations (BRD-002 / BRD-003).
