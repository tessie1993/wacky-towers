class_name Seeds extends RefCounted
## Deterministic seed derivation and RNG helpers (ADR-0006).
## All gameplay randomness comes from here; never use global random functions.

const _FNV_OFFSET: int = 2166136261
const _FNV_PRIME: int = 16777619
const _MASK32: int = 0xFFFFFFFF
const _SEP: int = 0x1F


## 32-bit FNV-1a of raw bytes. Result is unsigned, 0..0xFFFFFFFF.
static func fnv1a(bytes: PackedByteArray) -> int:
	var h: int = _FNV_OFFSET
	for b: int in bytes:
		h = ((h ^ b) * _FNV_PRIME) & _MASK32
	return h


## Derives a 32-bit sub-seed from round_seed and stream parts (int, String or StringName).
## Byte layout: round_seed as 8 LE bytes, then per part 0x1F + (int as 8 LE bytes | UTF-8).
static func derive(round_seed: int, parts: Array) -> int:
	var buf: PackedByteArray = PackedByteArray()
	_append_int(buf, round_seed)
	for part: Variant in parts:
		buf.append(_SEP)
		if part is int:
			_append_int(buf, part)
		elif part is String or part is StringName:
			buf.append_array(String(part).to_utf8_buffer())
		else:
			push_error("Seeds.derive: unsupported part type %d" % typeof(part))
	return fnv1a(buf)


## Fresh RandomNumberGenerator seeded with derive(round_seed, parts).
static func make_rng(round_seed: int, parts: Array) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = derive(round_seed, parts)
	return rng


## In-place Fisher-Yates shuffle from the end: j = rng.randi_range(0, i).
static func shuffle(rng: RandomNumberGenerator, items: Array) -> void:
	var i: int = items.size() - 1
	while i > 0:
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = items[i]
		items[i] = items[j]
		items[j] = tmp
		i -= 1


## Picks an index by integer weights; returns -1 if total weight is 0.
static func weighted_pick(rng: RandomNumberGenerator, weights: PackedInt32Array) -> int:
	var total: int = 0
	for w: int in weights:
		total += w
	if total <= 0:
		return -1
	var r: int = rng.randi_range(0, total - 1)
	var acc: int = 0
	for i: int in weights.size():
		acc += weights[i]
		if r < acc:
			return i
	return weights.size() - 1


static func _append_int(buf: PackedByteArray, v: int) -> void:
	var n: PackedByteArray = PackedByteArray()
	n.resize(8)
	n.encode_s64(0, v)
	buf.append_array(n)
