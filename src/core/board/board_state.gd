class_name BoardState extends RefCounted
## The board: one source of truth for what is where (ADR-0002). This ticket adds only the down-axis helpers.

## Gravity directions (ADR-0002 §1); default Y_NEG.
enum Down { X_NEG, X_POS, Y_NEG, Y_POS, Z_NEG, Z_POS }

## Spec tokens, same order as Down (ADR-0002 §6 check 5).
const DOWN_TOKENS: Array[String] = ["-x", "+x", "-y", "+y", "-z", "+z"]

const _DOWN_VECTORS: Array[Vector3i] = [
	Vector3i(-1, 0, 0), Vector3i(1, 0, 0),
	Vector3i(0, -1, 0), Vector3i(0, 1, 0),
	Vector3i(0, 0, -1), Vector3i(0, 0, 1),
]


## Maps a token to a Down value; -1 if not an exact member of DOWN_TOKENS. Usage: down_from_token("-y").
static func down_from_token(token: String) -> int:
	return DOWN_TOKENS.find(token)


## Unit gravity vector for a Down value; Vector3i.ZERO if d is invalid. Usage: down_vector_of(Down.Y_NEG).
static func down_vector_of(d: int) -> Vector3i:
	if d < 0 or d >= _DOWN_VECTORS.size():
		return Vector3i.ZERO
	return _DOWN_VECTORS[d]
