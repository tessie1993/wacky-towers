# ADR-0006: RNG and Seeds

## Status

Proposed

> Who may move this to `Accepted`: the user, or `technical-director` on the user's explicit confirmation.

## Date

2026-10-09

## Last Verified

2026-10-10

## Decision Makers

Tessa (user: same seed = same pieces on every phone; input replay on one device), godot-specialist (lead architect)

## Summary

Every random choice comes from a named stream derived from one `round_seed` by 32-bit FNV-1a sub-seeding, and each piece bag gets a freshly seeded `RandomNumberGenerator`, so the piece sequence is a pure function of `(round_seed, scope, bag index)` and identical on every phone. Rules, items and the spawner never share a stream, so no gameplay event can shift the pieces.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core |
| **Layer** | Foundation |
| **Knowledge Risk** | LOW — `RandomNumberGenerator` (PCG32) and 64-bit `int` are stable 4.x |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `deprecated-apis.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Golden values verified 2026-10-09 on 4.7.2 desktop (below); re-check on an Android device |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-0001 (replay), ADR-0004 (rule streams), ADR-0009 (shared tournament seed) |
| **Blocks** | Spawner & Queue |
| **Ordering Note** | First in build order |

## Context

### Problem Statement

The Spawner GDD makes the piece stream a pure function of `(round_seed, player scope, config, index)` (rule 1), with its own generator untouched by gameplay (rule 2), injected pieces outside the stream (rule 5), shared or independent mode (rule 13), and per-player extras on a separate sub-stream (rule 14). Rules need their own seeded streams (Rule-Twist rule 13). In versus, every phone must deal the same pieces from the host's seed.

### Constraints

- Godot's `hash()` is not documented as stable across versions, so it cannot feed seeds that must match across devices and builds.
- GDScript `int` is 64-bit signed; multiplication overflow must not be relied on.
- No floats in the piece sequence.

## Decision

### Seed derivation

`Seeds.derive(round_seed: int, parts: Array) -> int` = FNV-1a 32-bit over a byte stream:
- `round_seed` as 8 little-endian bytes, then for each part a `0x1F` separator byte, then the part: an `int` as 8 little-endian bytes, a `String`/`StringName` as UTF-8 bytes.
- Each step: `h = ((h ^ byte) * 16777619) & 0xFFFFFFFF`, starting from `2166136261`. Values stay below 2^56 before masking, so no overflow.
- Result is a 32-bit unsigned int used as a `RandomNumberGenerator.seed`.

### Streams

| Stream | Derivation parts | Use |
|---|---|---|
| Piece bag k | `["bag", scope, k]` | Fresh RNG per bag; Fisher–Yates shuffle with `randi_range` |
| Piece history/pure modes | `["pick", scope, n]` | Fresh RNG per piece n |
| Extras (shared mode) | `["extra", player_id, k]` | Per-player additions to bag k (Spawner rule 14) |
| Rule instance | `["rule", rule_id, instance_n]` | One stateful RNG per active rule (`RuleApi.rng()`) |
| Strategy | `["slot", slot_id]` | Stateful RNG for a strategy that needs randomness |
| Daily box of tricks | `["daily", yyyymmdd]` | Same daily mini-levels on every phone (ADR-0005) |
| Attack | `["attack", instance_id]` | Randomness of a received attack (e.g. Junk Rain's gap), so it replays on the target (ADR-0009 requirement 5) |
| Minigame / mode picks | `["round", round_index]`, `["minigame", id]` | Host-side picks (Randomizer, Tournament) |

- `scope` = `0` in `shared` sequence mode (everyone), `player_id` in `independent` mode.
- A fresh RNG per bag (not one long stream) makes bag k computable without dealing bags 0…k−1: peeking ahead and bots never change live state (Spawner edge case).
- Injected pieces, hold swaps and rule effects never draw from bag streams.

### Where `round_seed` comes from

- Single player: a new value per attempt from a non-deterministic source (`randi()` on a fresh, randomized RNG at the app layer, outside the sim) unless the level pins `seed` (ADR-0005).
- Tournament: the host draws one `tournament_seed` and sends it; `round_seed = derive(tournament_seed, ["round", i])` on every device (ADR-0009).
- Debug replay: `round_seed` is stored in the replay log (ADR-0001).

### Rules

- **No float noise in the sim.** `FastNoiseLite`, `randf*`, `Noise`-based textures or any float-producing generator must never feed gameplay state (positions, timers, choices, spawns). They are allowed only in the view (wobble, VFX, dressing). Gameplay needing "noise" (e.g. wind gusts) derives integers from a rule stream. Grep test over `src/core/` and `src/gameplay/`.
- `randi()`, `randf()`, `randomize()` and global RNG functions are banned in `src/core/`, `src/gameplay/` and plugins (grep test). Only `Seeds` creates gameplay RNGs.
- Shuffle: Fisher–Yates from the end, `j = rng.randi_range(0, i)`.
- Weighted pick: integer weights, `r = rng.randi_range(0, total - 1)`, walk the cumulative sum.
- **Write the FNV step with explicit parentheses.** In GDScript `*` binds tighter than `&`, and `&` tighter than `^`: unparenthesised `h ^ b * P & M` gives a wrong hash (verified: `E01C0576` instead of `E40C292C` for "a").

### Golden values (Godot 4.7.2, verified headless 2026-10-09)

| Call after `rng.seed = 12345` | First 10 values |
|---|---|
| `randi_range(0, 7)` | 4, 3, 1, 4, 6, 5, 5, 0, 2, 1 |
| `randi()` | 1321476956, 17539747, 3348728241, 2863338820, 85463406, 1024873269, 4179236141, 1040420088, 2363282938, 1603148953 |

Reseeding with the same seed repeats the sequence exactly. These go into `tests/unit/rng/` as pinned goldens; an engine upgrade that changes them fails loudly.

### Key Interfaces

```gdscript
class_name Seeds extends RefCounted
static func derive(round_seed: int, parts: Array) -> int          # 32-bit FNV-1a
static func make_rng(round_seed: int, parts: Array) -> RandomNumberGenerator
static func shuffle(rng: RandomNumberGenerator, items: Array) -> void
static func weighted_pick(rng: RandomNumberGenerator, weights: PackedInt32Array) -> int
```

## Alternatives Considered

### Alternative 1: One global RNG
- **Rejection Reason**: Any extra draw (a twist, an item) shifts every later piece; breaks Spawner rule 2.

### Alternative 2: Godot `hash()` for sub-seeds
- **Rejection Reason**: Not guaranteed stable across engine versions or platforms.

### Alternative 3: 64-bit FNV-1a
- **Rejection Reason**: The 64-bit prime multiply overflows signed `int`; relying on wraparound is fragile. 32 bits of seed is plenty for a bag.

### Alternative 4: One long stream per player, advanced to index n
- **Rejection Reason**: Peeking ahead costs O(n) and couples bags; per-bag seeding is O(1) per bag.

## Consequences

### Positive
- Same pieces on every phone; replays and bug reports reproduce; rules cannot disturb the sequence.

### Negative
- Golden-value tests must be re-checked on an engine upgrade (PCG32 or `randi_range` changes would be caught).

### Neutral
- Seeds are 32-bit; collisions between bags are harmless.

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|
| `randi_range` differs across platforms | Low | High | Golden test on desktop and Android |
| Engine upgrade changes RNG | Low | Medium | Golden test fails loudly; implement PCG32 in GDScript if needed |
| Someone uses `randi()` in gameplay | Medium | Medium | Grep test |

## Performance Implications

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | — | one FNV + shuffle per bag (~8 items) | negligible |

## Migration Plan

None — new code.

**Rollback plan**: `Seeds` is the only entry point; its internals can change behind it (with new golden values).

## Validation Criteria

- [x] FNV-1a of `"a"` = `0xE40C292C` with explicit parentheses (verified on 4.7.2); keep as a unit test.
- [ ] Golden test: `Seeds.make_rng(12345, ["bag", 0, 0])` deals a pinned sequence on 4.7.2 desktop and Android.
- [ ] Same seed → same first 100 pieces; adding a twist that draws random numbers does not change them.
- [ ] Bag k computed directly equals bag k reached by dealing.

## GDD Requirements Addressed

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| `design/gdd/piece-spawner-queue.md` | Spawner | Rules 1–2: pure-function stream, own generator | Per-bag derived seeds |
| `design/gdd/piece-spawner-queue.md` | Spawner | Rule 3: Fisher–Yates weighted bag | `Seeds.shuffle` over F1 copies |
| `design/gdd/piece-spawner-queue.md` | Spawner | Rules 5, 13, 14: injects outside stream; shared/independent; extras sub-stream | Scope part; `extra` stream |
| `design/gdd/rule-twist-framework.md` | Rule-Twist | Rule 13: each rule its own seeded stream from round seed + `rule_id` | `rule` stream |
| `design/gdd/level-data-definition.md` | Level Data | Rule 7: fresh seed per attempt, pinnable, versus from Tournament | `round_seed` sources |
| `design/gdd/tournament-flow.md` | Tournament | Rounds use different seeds | `derive(tournament_seed, ["round", i])` |
