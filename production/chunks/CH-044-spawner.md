# CH-044 Spawner: weighted bag + opening set + lookahead

**Story:** SIM-002 · **Model:** Sonnet · **Wave:** W2 · **Mode:** direct
**Status:** staged (MB-012)
**Goal:** the deterministic piece sequence for a round (Spawner GDD bag randomizer; meadow_01 opening {o, i}).
**Depends:** CH-028 (ShapeBank ids only, for the test) · **Parallel-safe with:** W2
**Files:** new `src/core/sim/spawner.gd`, `tests/unit/sim/spawner_test.gd`.

## API
```gdscript
class_name Spawner extends RefCounted
## Next-piece sequence from LevelData.pieces. Pure; randomness only via Seeds (ADR-0006).
func _init(pieces: Dictionary, lookahead: int, round_seed: int) -> void
	## pieces = {shapes: PackedStringArray, weights: Dictionary (id -> int copies, missing = 1),
	##           opening_set: PackedStringArray, opening_count: int}; lookahead = spawn.queue_lookahead (>= 1)
func next() -> StringName                  ## pops the head; the queue refills to lookahead
func peek(n: int) -> PackedStringArray     ## first min(n, lookahead) upcoming ids, head first
func drawn_count() -> int
```

## Behaviour
- **Opening:** the first `opening_count` pieces come from `opening_set`, shuffled with `Seeds.make_rng(round_seed, ["spawn_open"])`;
  if count > set size, re-shuffle the set again (next shuffle part index). They are extra: bag 1 is a full bag.
  `# ponytail: opening is not taken out of bag 1; change if the Spawner GDD says otherwise`.
- **Bags:** bag k (0-based) = every shape repeated `weights.get(id, 1)` times, in `shapes` order, then `Seeds.shuffle(Seeds.make_rng(round_seed, ["spawn_bag", k]), bag)`.
- Weights are ints here: LevelLoader (CH-049) converts float weights to copies (G3). Weight 0 = never.
- No global RNG, no `hash()`.

## Tests first (`spawner_test.gd`; pieces for meadow_01: shapes [i,o,t,l,s], opening [o,i], count 2)
1. `test_opening_first` — first 2 ids are {o, i} in some order, for seeds 1..20.
2. `test_bag_contains_each_once` — ids 3..7 are a permutation of [i,o,t,l,s]; same for 8..12.
3. `test_weights_copies` — weights {big_cube: 1, i: 2}, shapes [i, big_cube], no opening: each bag of 3 holds i twice.
4. `test_deterministic` — same seed -> same first 30 ids; seeds 1 and 2 differ somewhere in 30.
5. `test_peek_does_not_consume` — `peek(3)` then `next()` == `peek(3)[0]`; `drawn_count()` 1.
6. `test_opening_count_over_set` — set [o], count 3 -> o, o, o.

## Run / Done when
`--import`, `-a res://tests/unit/sim`. README "Done when"; 6 tests green.
**Out of scope:** per-bag tags (CH-105), hold, history randomizer, fixed_list.
