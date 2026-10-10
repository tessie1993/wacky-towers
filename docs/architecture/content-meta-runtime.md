# Campaign data, progression and persistence API

Implemented 2026-10-10. The approved requirements remain in ADRs 0005/0013, the GDDs and `production/orchestration/decisions-2026-10-10.md`. This page documents production classes, including remaining limitations.

## Trusted content

`WtContent.load_catalog()` returns `GameCatalog`: shape-bank Resources, content definitions, typed knob definitions, trusted rule definitions, plugin registry, board limits and the family palette. Runtime data uses `RefCounted` containers. User JSON never names a script or Resource. Callers treat cached `LevelData` as immutable and make an attempt copy before applying loadout modifiers.

| Call | Return and contract |
|---|---|
| `all_levels()` | Deep-copied manifest `Array[Dictionary]`, ordered by biome/tier. |
| `level(id)` | Cached `LevelData`, or `null` with `last_issues`. |
| `raw_level(id)` | Deep-copied complete JSON, including retained source intent. |
| `metadata(id)` | Deep-copied manifest entry, or `{}`. |
| `errors` / `last_issues` | Catalog errors / most recent structured loader diagnostics. |

`LevelLoader.load_level(path,catalog)` bounds JSON reads to 256 KiB by default; `parse_level(raw,catalog)` returns a `LoadResult`. Schema 1, required fields, known shapes/knobs/rules, integers, fixed-point scalar coercion, board/mask/content bounds, target grids, rule budgets and star ordering are validated before returning a level. The structured `goal.type` selects the runtime strategy. Fixed piece sequences, their colour sequence, opening bags and per-bag tags survive parsing. P/V/M targets map to hue ids 1/2/3; rainbow-tagged cubes satisfy each flavour.

Rule definitions preserve parameters, modifiers, vetoes, lifetimes, required/provided tags and incompatibilities. The trusted catalog has 65 behavior definitions, including the optional item system. This is a finite supported subset of the wider atom library; a known behavior id alone does not prove every proposed parameter variation exists. Item tables validate known ids, finite nonnegative weights, standing bias, booleans and duplicate entries before simulation.

## Authored campaign and coverage

The manifest contains 100 main levels and 18 authored bonuses/remixes, with matching JSON and scene paths. Ten Meadow mains use the approved production JSON (including the 4×4 opening board). Other source JSON is extracted from the existing level design documents. No Neon design existed, so `design/levels/neon.md` records ten explicit new proposals and labels them awaiting author review.

| Biome | Authored entries | No recorded gameplay blocker | Blocked |
|---|---:|---:|---:|
| Meadow | 11 | 11 | 0 |
| Candy | 14 | 14 | 0 |
| Ice | 11 | 11 | 0 |
| Underwater | 11 | 11 | 0 |
| Lava | 14 | 14 | 0 |
| Forest | 11 | 11 | 0 |
| Cave | 14 | 14 | 0 |
| Clockwork | 11 | 11 | 0 |
| Neon | 10 | 10 | 0 |
| Celestial | 11 | 11 | 0 |
| Total | 118 | 118 | 0 |

All 100 mains and 18 extras have no recorded missing gameplay atom. Every level retains its unmodified author source under `metadata.design_spec`. Explicit canonical mappings record semantically equivalent ids/parameter names. Approved geometry/star amendments are separate under `metadata.design_amendments` and `assets/data/campaign/design_amendments.json`. This coverage status establishes implemented contracts; it does not establish a complete playthrough or tuned difficulty.

`blocking_gameplay` controls release availability. `unsupported` additionally includes nonblocking source notes such as retained recipes, authored solutions, optional secret props and purely cosmetic mascot behavior. The definitive per-level list is `assets/data/campaign/implementation_coverage.json`. Pure author metadata is preserved even when it does not participate in simulation. Fifteen finite packing puzzles now have constructive exact-cover witnesses and actual BoardSim wins. Cave07's mirror supplies 24 cubes from three four-cube pieces; Cave bonus uses four of its six mirrored kit pieces; Celestial bonus includes the eight-cube Big Cube. Their original budgets are sufficient. Earlier volume-only shortfall claims were incorrect and are superseded by `assets/data/campaign/puzzle_proofs.json`.

The source designs mention additional table-only hard tracks without authored JSON. Those entries are not invented or counted. Star thresholds are source values or explicitly proposed initial estimates; there are no playtest medians. All live biome art-set references use the existing Candy Toy block models; final biome-specific art remains a presentation task.

Rebuild deterministically from the repository root with `python tools/author_campaign.py`, then `python tools/refresh_rule_catalog.py`. The generated manifest is explicit; runtime does not scan arbitrary user folders into the official campaign.

## Profiles and transactional progress

`WtProfileStore.new(io)` accepts a `SaveIO`; omitting it uses `FileSaveIO`. `MemorySaveIO` supplies deterministic tests. Four isolated slots use the lowest free index. A guest has no active profile and receives no saved currency.

| Call | Return and contract |
|---|---|
| `list_profiles()` / `slots()` | Four entries or `null`; entry has `id,name,color,badge,slot,stars,wallet`. |
| `create(name,color="sky",badge="cloud")` | Slot integer, or -1; trimmed 12-character unique name. |
| `select(slot)` | Boolean; loads independent records/settings. |
| `rename(slot,name)` / `delete(slot)` | Godot `Error`; menu-only, unique names, explicit deletion. |
| `active_profile()` / `progress()` | Current index entry or null / deep-copied progress. |
| `set_playing(bool)` | Gates purchases, profile changes and writes during live play. |
| `record_result(id,stars,ms,score,hash="")` | `{ok,star_gain,award,replay_award,first_clear,stars,wallet}` on success. |
| `record_encounter(level_id)` | Persists a deduplicated official level id before actual play, including later failures; no currency. Call before `set_playing(true)`. |
| `record_arcade(biome,score,layers,ms)` | Per-skin bests; grants no currency. |
| `record_tournament(won,award)` | Local profile result and supplied authoritative award. |
| `wallet_balance()`, `biome_stars(id)`, `biome_open(id)`, `level_open(entry)` | Earned-star progression is independent of spending. |
| `characters(mode="campaign")` | c1 plus joins after Ice10/Lava10/Cave10; party exposes all four. |
| `settings()`, `get_setting(key,fallback)`, `set_setting(key,value)` | Combined preferences / read / supported-key write. |

A result keeps maximum stars and score and minimum successful time independently. Each newly earned star credits one jar star. A non-improving win at two or more stars pays one replay star once per level. Failures pay nothing. A changed level hash preserves earned stars and their earning hash while recording the current hash. Star record, wallet and inventory share one progress snapshot; a failed result or purchase write restores the in-memory snapshot.

`WtProgression` requires both the previous biome finale and 15 earned main-path stars to open the next biome. Main levels unlock sequentially; bonus unlocks at 20 biome stars; remixes unlock after the finale. Purchased items never reduce earned-star gate totals.

### Shop and actual potion use

`shop_snapshot()` is an **Array**. Rows contain `id,kind,price:{currency,amount},unlocked,owned,count,affordable,effect`. Perk effects are dictionaries; potion effects are strings. `purchase(id)` atomically debits and grants with stock cap five; `undo_purchase()` reverses the latest purchase until the shop closes. `equip_perks(character,ids,mode)` validates owned distinct character perks, at most two and combined edge ≤0.15. Quick Versus rejects edges. The application exposes only effects it actually applies; planned cosmetics and unimplemented perks remain catalog design data.

`consume_potion(id)` decrements only in memory after the simulation emits an actual `item_used` event. A tap or `item_no_effect` does not consume stock. `commit_inventory()` persists that state after `set_playing(false)` on loss/abandon. Successful results persist it with the result snapshot. This avoids losing consumed stock when no successful level record is written.

### Disk layout and recovery

```
user://save/index.json
user://save/device.json
user://save/slot_0/progress.json
user://save/slot_0/settings.json
... slot_1 through slot_3
```

Disk JSON uses `{schema:1,payload:{...},checksum:sha256(canonical_payload)}`. Writes create `.tmp`, flush, verify the checksum, retain the valid main as `.bak`, and rename the temp into place. Invalid main files are retained in two `.corrupt-*` slots. Reads prefer a valid main, then backup, then interrupted temp. Lost indexes rebuild from independently valid progress files without deleting records. A checksum-valid newer envelope is read-only and its unknown payload fields remain available. Legacy raw JSON dictionaries remain readable.

Device preferences include audio/window/vsync/frame cap. Accessibility, character, equipped perks, selected potion, encountered campaign levels and input bindings are per profile. `progress().encountered_levels` records actual attempts; Arcade can merge successful legacy level keys to migrate its learned mechanic pool. Writes are synchronous menu/start/result boundary operations; background serialization, debounce workers and a complete migration framework are not implemented. File flush/rename recovery is tested on this filesystem; mobile power-loss durability and storage exhaustion still need device QA.

## Local mode definitions

`WtModes.arcade_level(biome,seed)` constructs endless 8×8 H12 play, g0=1, ramp 0.08 per clear, cap6, one warning, standard eight shapes. `arcade_twists(layers,pool,seed)` deterministically picks compatible registered twists, one initially and two from ten layers. The application still needs the announced two-second transition and live five-layer twist replacement director; the selection helper is not an active rotation loop.

| Call | Contract |
|---|---|
| `round_modes()` | `clear_race,height_race,gust_race,conveyor_race,ice_race,fog_race`. |
| `set_round_pool(ids)` | Nonempty trusted ids; rejects unknown ids without changing the old pool. |
| `start_tournament(players,rounds=3,seed=1,modes=[])` | 2–4 entries; 3/5/7/13 rounds; config snapshot or explicit error. |
| `next_round_level()` | Deterministic nonrepeating mode; clear3/height6; sudden death clear1, no twists. |
| `record_round(results)` | Rows `{id,won,ms,progress,score,layers,active}`; standings/results snapshot. |
| `tournament_snapshot()` / `standings()` | Deep-copied lobby state / wins-first ordering. |
| `tournament_awards(rounds,players,completed=0)` | GDD majority/player-count/rematch-decay formula. |
| `abort_tournament()` / `close_lobby()` | No win credit on abort; finish qualification / reset rematch decay. |

Win-time ties share the round win. A single player reaching majority wins; tied majority or equal wins at the scheduled end enters sudden death among contenders. Score breaks display ordering, not the final winner. The caller must enforce the configured 240-second round cap, submit real outcomes and supply authoritative awards. This class provides no network transport and creates no simulated peers; application bot practice and LAN transport are separate systems.

## Verification

`tests/unit/meta/content_meta_test.gd` covers all118 parses/100 mains, exact goal routing, earned-star gates, four-profile settings, replay awards, purchase/undo, index recovery, checksum backup/future read-only protection, rejected user-data ids, selected tournament pools, explicit potion commit and encounters without successful results. Candy's focused real-board suite passed15/15. Ordered real-engine verification instantiated all118 GodotAI-authored scenes with their embedded World, checked legal first spawns and completed locks, exercised the special controls and won all15 finite packing puzzles. The per-level record is `production/qa/evidence/full-build/biome-level-verification.json`. These checks establish concrete engine behavior and puzzle feasibility; human success rates, star medians, complete non-puzzle objective playthroughs and perceived fairness remain unmeasured.
