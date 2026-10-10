# Level Data & Definition

> **Status**: Designed
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-10
> **Last Verified**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; Readable Chaos

## Summary

Every level is a JSON data file, not code: it names the board, the pieces, the goal, its knob overrides and its rules (twists, mechanic, living content, mascot), and leaves everything else at the defaults set by the other GDDs. A validator checks every level against all the rules those GDDs define before it can be played. The MVP ships one full biome — ten grass / meadow levels that introduce each twist and mechanic once and end with a full stack.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Level Goals & Fail States, Rule-Twist Framework, Level-Specific Mechanics, Twist Library` · ADRs: 0004 (knob/rule schemas), 0005 (format, loader, validator), 0011 (staging), 0013 (relaxed timing), 0015 (music), 0017 (level maker)

## Overview

With 100 campaign levels plus arcade and tournament rounds, levels must be content rather than code. Level Data & Definition owns the **level file**: one JSON record per level (ADR-0005) that names its biome and tier, its board (size, height, mask, starting contents), its piece set, a flat map of **knob overrides**, its goal, and one **`rules` list** (up to two twists and one level mechanic, plus any mascot or living-content rules, which do not count toward the cap). Any field left out takes the default from the knob registry or the GDD that owns it, so a minimal level is a few lines. Level values set the **base** for that level; rules are layered on top through the Rule-Twist Framework. Before a level can load, a **validator** runs every check the other GDDs define and names the level, the field and the rule that failed. Official levels also have a **level scene** (`.tscn`) that holds everything presentational — the diorama, the camera default and any beehave staging tree — and never a rule value. The dev team authors levels in the **level maker**, an editor dock (ADR-0017). This GDD also defines the **MVP biome**: ten meadow levels that teach the controls, then introduce each twist and mechanic, ending with a level that stacks two twists and a mechanic. This serves *Variation Over Depth* (new levels are cheap) and *Readable Chaos* (the validator enforces the readability rules). All values are starting defaults.

## Detailed Design

### Core Rules

**The level file**
1. Each level is one JSON file (ADR-0005; official and player levels share one format, loader and validator) with `schema` (format version, integer), `id` (e.g. `meadow_03`), `version` (content version, set by the tools), a display `name` (translation key), a `biome`, a `tier` (1–10; 11 = the biome's bonus level; 12+ = hard-track remixes; Campaign Structure rule 17) and the fields in rule 3.
2. **Every field is optional except `id`, `biome` and `tier`.** An omitted knob takes its registry default (`assets/data/knobs/*.json`, ADR-0004 §3); an omitted section takes the default from the GDD that owns it. Level values replace those defaults as the level's base; they are not framework rules and have no priority.
3. Fields and owners:

| Field | Contents | Owner |
|---|---|---|
| `layout` | `{kind}`: `single` (default) or a `LayoutKind` plugin id (`islands`, `lanes`, `meet`, …) | Board / Grid, ADR-0004 |
| `board` / `boards` | One board: `width`, `depth`, `h_play`, `down_axis`, `mask`, `spawn_anchor`, `starting_contents`. Several boards: a list of the same, each with `id`, `transform`, optional `links` | Board / Grid, ADR-0002 |
| `pieces` | `shapes`, `weights`, `tags`, `opening_set`, `opening_count`, `fixed_list` (puzzle levels) | Piece Set, Spawner |
| `knobs` | Flat map of knob id → value, for any registry knob within its range: e.g. `fall.g0`, `fall.lock_delay_ms`, `spawn.preview_count`, `clear.collapse`, `spawn.arrival`, `goal.top_out`, `goal.warnings_max` | Every core GDD (ids from ADR-0004 knob files) |
| `goal` | `type` (copied into the `goal.type` slot) and its target: `N`, `H_target`, `T` or `target_shape`; extra fail conditions | Level Goals & Fail States |
| `rules` | List of `{id, params}`. Each rule's layer comes from its rule JSON. Budget: ≤ 2 `twist`, ≤ 1 `mechanic`; `mascot` and `content` rules do not count (ADR-0004 §2, ADR-0011 §2) | Rule-Twist Framework, Twist Library, Level-Specific Mechanics |
| `recipe` | Optional authoring metadata: mechanic atoms by slot; the loader expands it into knobs and rules, and explicit `knobs`/`rules` win | Mechanics Module |
| `stars` | `{t2, t3}` in ms (timed goals) or `{s2, s3}` in layers (Survive) | Scoring & Stars |
| `seed` | `null` (fresh per attempt) or a pinned integer | rule 7 |
| `story` | `title_key`, `premise_key`, `mascot_role`, `icon` | Narrative, Mechanics Module |
| `music` | Optional track id from the music catalogue; absent = the biome's `default_music` | Audio (ADR-0015) |

4. A level never contains behaviour or presentation code; new behaviour is a new rule (twist, mechanic or content) in its own GDD. A level can only name rule ids, shape ids, knob ids and track ids that already exist.
4a. **Grid fields use ASCII rows** per layer (one string per row; row 0 = `z = 0`, character 0 = `x = 0`), so levels are readable and diff cleanly:
   - `board.mask`: `#` active, `.` off (Board / Grid rule 4). Omitted = all active.
   - `board.starting_contents`: `{layers: {y: [rows]}}` with `#` = starter block (`shape_id: starter`, drawn in the biome's stone style), `m` = the biome object, `.` = empty.
   - `goal.target_shape`: `{layers: {y: [rows]}}` with `#` = target cell. This is the Shape goal's `M`.
4b. `board.spawn_anchor` `{x, z}` sets where pieces spawn (Board / Grid rule 11a); default the footprint centre (lower cell on ties).
4c. Schema sketch (ADR-0005 is the authority; every field optional except `id`, `biome`, `tier`):

```
schema, id, version, name, biome, tier
layout:  {kind}
board:   width, depth, h_play, down_axis, mask, spawn_anchor, starting_contents   # or boards: [...]
pieces:  shapes[], weights{}, tags{}, opening_set[], opening_count, fixed_list[]
knobs:   { "<system>.<knob>": value, ... }          # flat, registry ids
goal:    type, N | H_target | T | target_shape
rules:   [ {id, params} ]                            # ≤ 2 twist + ≤ 1 mechanic count
recipe:  [ {slot, atom} ]                            # optional, authoring
stars:   t2, t3 | s2, s3
seed, music, story
```

**Presentation lives in the level scene**
4d. An official level also has a level scene (`.tscn`, inheriting the shared level stage; ADR-0005 file table) that holds only presentation: the diorama dressing, the board anchor, mascot spots, the camera default, skits, and any **beehave staging tree** (ADR-0011 §8). The scene references its level JSON, not the other way round; **the JSON never names a scene or a tree.** Staging trees animate sim events and never change the game (ADR-0011), so a level plays the same with or without its scene. Player-made levels have no scene and play on the generic level stage with default presenters.
4e. **Music** (ADR-0015 §5): one full track per level. `music` holds a catalogue id, never a path. An unknown id is a validator *warning* and falls back to the biome's `default_music`, so it never blocks play. Meadow levels reuse the Meadow track until the user's per-level tracks arrive ("Carefree" is a placeholder).

**Biome records**
4f. A level's `biome` names a biome record (`assets/data/biomes/<biome>.json`, ADR-0005) that holds the biome's `default_music`, its dressing palette and a **`side_island`** flag (default `false`). The campaign map is a fixed main chain of biomes plus optional **side-island** biomes; `side_island: true` marks a biome whose levels are optional and never gate the main chain. Gating and unlock order belong to Campaign Structure; levels carry no flag of their own.

**Validation**
5. The validator (`LevelValidator`, ADR-0005) runs: in the test suite for every official file, at load in debug builds, at every player-level load and import in all builds, and live in the level maker dock while authoring (ADR-0017). A failing level cannot be played; the error names the level, the field and the rule. Warnings allow play but are listed.
6. Checks (failures unless marked *warn*):
   - **Format**: `schema` known (older ones migrate, newer ones fail); unknown keys fail; knob ids exist, values typed and in range; integer fields are whole numbers.
   - **Board**: footprint and height within Board / Grid ranges (≤ 24 per side, ≤ 8 192 cells, ADR-0002); at least `min_active_cells_per_layer` active cells per layer; readability F5 cube edge ≥ 20 px on the reference phone (*warn* below 28 px).
   - **Pieces**: set not empty; every shape fits each active region of every board (Piece Set rule 8); at most 8 shapes (10 in minigames) and at most 3 in one 60° hue band (*warn* on hues within 15°); spawn clearance = `L_max` (Board F4).
   - **Spawner**: `preview_count ≤ queue_lookahead ≤` cap; bag size ≤ `bag_max_size` (*warn* and scale); every `opening_set` shape is in the level's set and `1 ≤ opening_count ≤ 10`.
   - **Spawn**: `spawn_anchor` is an active cell, and every shape's spawn cells around it are active (Board / Grid rule 11a).
   - **Grids**: every ASCII grid has `depth` rows of `width` characters and only its legal characters; no starting content or target cell on an inactive cell or at or above `h_play`.
   - **Goal**: valid target (Level Goals edge cases); Shape cells active and below the limit; Height target below the limit.
   - **Rules**: rule ids exist; at most 2 `twist` and 1 `mechanic` (framework F3, counted by layer); no incompatible pairs (`incompatible_with`, atom tags); every param within its schema range; every rule has an icon; *warn* when two rules set one knob. Rule-specific checks (Conveyor only on unmasked boards; Gravity Flip not with Build Race, Target Shape, Sideways Gravity or pillars) live in each rule's own `validate()` (ADR-0005).
   - **Music**: `music` is a catalogue id (*warn* and fall back otherwise); a path fails.
   - **Length**: estimated length (F1) within 5–15 min (*warn* outside).

**Seeds**
7. A level has no fixed seed by default; each attempt gets a new `round_seed`. A level may pin a seed (puzzle-style levels, daily challenges, test play in the level maker). Versus rounds take the seed from Tournament Flow.

**Star times and relaxed timing**
7a. `stars` are authored for play **with no perks** (edge perks are capped at about 15%; decision 2026-10-10). With **Relaxed timing** on (Onboarding & Accessibility F1, ADR-0013), `t2` and `t3` are scaled by `relaxed_time_scale` (default 1.5) when the level starts, and level time limits by the same scale. All 3 stars stay earnable, the save stores no relaxed flag and there is no badge. The level file is never changed by the setting, so `level_hash` stays the same.

**Authoring: the level maker**
7b. Levels are authored in the dev-team **level maker** dock (ADR-0017): it opens and saves this JSON with no new format, picks atoms and rules from the mechanics library in a form, builds knob and param widgets from their schemas (showing each knob's effective value), paints ASCII grids layer by layer, shows validator issues next to each field, and test-plays with a pinned seed. Hand-written JSON stays valid. Staging trees are attached in the official `.tscn` by the dev team, never in the JSON (4d).

**The MVP biome: grass / meadow (tier 1–10)**
8. The MVP ships **10 meadow levels** plus a bonus level and three hard-track remixes: two control tutorials, then the twists and mechanics introduced one idea at a time, ending with a full stack. Rotation axes follow Touch Controls' progressive disclosure. Board size is picked per level for fun (user decision 2026-10-09). **The full level specs (recipes, masks, starting contents, target shapes, star times) live in `design/levels/meadow.md`, which wins over this summary.** All values are tunable defaults.

| # | id | Name | Board (W×D, H) | Goal | Mechanic | Twists | Other rules (no F3 cost) | g0 |
|---|---|---|---|---|---|---|---|---|
| 1 | meadow_01 | First Sprout | 4×4, 8 | Clear 4 | — | — | Pip catch | 0.6 |
| 2 | meadow_02 | Tilt & Roll | 6×6, 10 + 2 starter layers | Clear 3 | — | — | Pip catch | 0.6 |
| 3 | meadow_03 | Breezy Hill | 8×4 lane, 10 | Clear 5 | — | Wind | Pip catch, puff pieces | 0.7 |
| 4 | meadow_04 | Mushroom Ring | 7×7 ring, 10 | Clear 3 | — | Spawned Objects | — | 0.75 |
| 5 | meadow_05 | Tall Tower | 5×5, 12 | Height 10 (cov. 0.6) | No-Clear Build Race (trim) | Wobble | — | 0.8 |
| 6 | meadow_06 | Flower Bed | 8×8, 8 | Shape 50 | Fill the Target Shape (trim) | — | sprouts | 0.7 |
| 7 | meadow_07 | Hide & Seek | 6×6, 10 + 2 starter layers | Clear 4 | — | Invisible Blocks | fog ghost | 0.85 |
| 8 | meadow_08 | Dewdrop | 5×5, 8 | Survive 150 s | Sticky Landing | — | — | 0.9 |
| 9 | meadow_09 | Topsy-Turvy | 6×6, 10 | Clear 4 | — | Gravity Flip (stack flips) | hatching eggs | 0.95 |
| 10 | meadow_10 | Meadow Mill | 8×6, 12 | Clear 3 | Conveyor Floor (Mill Belt) | Wind, Gravity Flip (`flip_max` 1) | — | 1.0 |
| B | meadow_bonus | Picnic Puzzle | 4×4, 6 | Shape 32 in 60 s | Fill the Target Shape | — | — | 0.5 |

9. Level 10 is the systems index's risk test: two twists and a mechanic stacked. Level 1 has no twist so the first playtest measures the controls alone. Speeds are hand-set per level and agree with Campaign Structure F2 (`0.6 + 0.045 × (tier − 1)`) within ±0.05; a level's own `fall.g0` always wins.

### States and Transitions

A level file has: **Draft** (authored, may fail validation; the level maker may save it) → **Valid** (passes; warnings listed) → **Locked** (shipped; changes need a version bump so saved stars stay meaningful; the level maker warns before a Locked level's `level_hash` changes, ADR-0017 §7). At runtime a loaded level is read-only.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Board / Grid, Piece Set, Spawner, Movement & Rotation, Touch Controls, Fall Drop & Lock, Layer Clearing, Camera | Level Data → | Base values for their knobs (`knobs` map) and structured sections |
| Level Goals & Fail States | Level Data → | Goal, targets, extra fails |
| Rule-Twist Framework, Level-Specific Mechanics, Twist Library | Level Data → | `rules` list and params; validation of caps and pairs |
| Scoring & Stars, Onboarding & Accessibility | ↔ | Star times per level; relaxed scaling at level start |
| Campaign Structure | → Level Data | Order of levels by biome and tier; side-island gating |
| Audio (ADR-0015) | Level Data → | `music` track id |
| Level scene / staging (ADR-0011) | scene → Level Data | The scene points at its JSON; never the reverse |
| Level maker (ADR-0017) | ↔ | Reads and writes the file; shows validator results |
| Mode / Minigame Randomizer, Tournament Flow, Arcade Mode | → Level Data | Picks levels or templates; supplies seeds |
| Save & Profile | Level Data → | Level ids and versions for saved results |

## Formulas

### F1. Level length estimate

The level_length_estimate formula is defined as:

`t_est = N × t_beat` (Clear); `build_race_time` (Height, Level-Specific Mechanics F2); `shape_fill_time` (Shape, Level-Specific Mechanics F3); `T` (Survive)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N | int | ≥ 1 | level file (suggested by Level Goals F1) | Clears to make |
| t_beat | float | 5–340 s | calculated (Board F6) | Seconds between clears for this board, clear rule, piece set and `t_piece` (layer clears: `P_eff × t_piece`) |
| t_piece | float | 4–12 s | knob `goal.t_piece_s` | Average time per piece, inside t_beat; default 8 s |
| T | float | > 0 | level file | Survive time |

**Output Range:** used only for *warn* checks (length 5–15 min, plus t_beat, hidden share and survive pressure inside the level type's bands, Board / Grid "Recommended board per level type"). It is an authoring estimate, not sim math. **Example:** meadow_01: 4 × 4, layer, c = 4, η 0.75 → `t_beat ≈ 42.7 s`; N = 4 → `t_est ≈ 171 s` (short on purpose; warns). meadow_05: Height 10, coverage 0.6, A = 25, c ≈ 4.24 → 35 pieces ≈ 283 s. meadow_03: 8 × 4 lane, `t_beat ≈ 85 s`, N = 5 → ≈ 427 s ≈ 7 min. meadow_10: 8 × 6 (A 48), c ≈ 4.1 → `t_beat ≈ 125 s`; N = 3 → ≈ 375 s. A default 6 × 6 level: `t_beat = 96 s`, N = 5 → 480 s. F1 ignores `starting_contents`, so levels with pre-built layers set their star times by hand.

### F2. Relaxed star times

`t2_relaxed = round5(t2 × relaxed_time_scale)`, `t3_relaxed = round5(t3 × relaxed_time_scale)` (Onboarding & Accessibility F1; `round5` rounds to the nearest 5 s).

**Variables:** `t2`, `t3` (int ms, level file); `relaxed_time_scale` (scalar knob, 1.0–2.0, default 1.5).

**Example:** meadow_09 ★★ 325 s / ★★★ 230 s → relaxed 490 s / 345 s.

## Edge Cases

- **If a field is omitted**: the registry or owning-GDD default is used; the level maker shows the effective value next to each knob.
- **If a field or knob id is unknown** (typo or removed knob): validation fails, naming the field.
- **If a value is outside its safe range or a whole-number field holds a fraction**: validation fails, naming the range.
- **If `schema` is older than the game's**: the loader migrates it step by step; if newer, the level is refused with a message.
- **If a level changes after it shipped**: its version increments; saved stars for the old version stay but are marked as an older version (Save & Profile decides display).
- **If a rule id doesn't exist**: validation fails.
- **If `rules` holds 3 twists or 2 mechanics**: validation fails; any number of `mascot` / `content` rules is allowed.
- **If a level has a pinned seed and `spawn.sequence_mode = independent`** (versus): each player's stream still mixes in the player id (Spawner).
- **If two levels share an id**: validation fails for the campaign as a whole.
- **If `starting_contents` places content in inactive cells or over the limit**: validation fails.
- **If the length estimate is outside 5–15 min**: warning only; tutorials and minigames may be short on purpose.
- **If a Shape level has an empty or missing `target_shape`**: the level stays Draft (fails validation for an empty M).
- **If the footprint centre is inactive and no `spawn_anchor` is given**: validation fails, naming the field.
- **If `opening_count` is larger than the number of pieces the level deals before ending**: allowed; the rest of the opening is never used.
- **If `music` names an unknown track or is absent**: the biome's `default_music` plays; unknown ids also warn.
- **If an official level's scene is missing or has no staging tree**: the level still plays on the generic stage with default presenters (ADR-0011 §8).
- **If a player level tries to name a scene, tree or file path**: the unknown key fails validation; player levels can only name catalogue ids.
- **If relaxed timing is switched on mid-level**: it applies from the next level start; the running level keeps its star times.

## Dependencies

**Upstream:** Level Goals & Fail States, Rule-Twist Framework, Level-Specific Mechanics, Twist Library (Hard); every core GDD whose knobs it sets (Board / Grid, Piece Set, Spawner, Touch Controls, Camera, Movement & Rotation, Fall Drop & Lock, Layer Clearing) (Hard: field definitions, defaults and ranges); Onboarding & Accessibility (Soft: relaxed scaling). Architecture: ADR-0002, ADR-0004, ADR-0005 (format authority), ADR-0011, ADR-0013, ADR-0015, ADR-0017.

**Downstream:**

| System | Hard / soft | Interface |
|---|---|---|
| Campaign Structure | Hard | Levels by biome and tier; biome `side_island` flag |
| Scoring & Stars | Hard | Star times per level |
| Mode / Minigame Randomizer, Tournament Flow, Arcade Mode, Tournament Minigames | Hard | Level and template selection |
| Audio | Soft | `music` id |
| Save & Profile, Menus & Level Select | Soft | Ids, names, versions |

## Tuning Knobs

| Knob | Range | Default | Category | Affects |
|---|---|---|---|---|
| length warn range | 3–20 min | 5–15 min | gate | Validator warning (F1) |
| `relaxed_time_scale` | 1.0–2.0 | 1.5 | curve | Relaxed star times and limits (F2; owned by Onboarding & Accessibility) |
| per-level `knobs` and rule params | as in owning GDDs | registry defaults | — | Everything about a level |

## Visual/Audio Requirements

None at runtime beyond what the systems it configures draw and the level's music track. The level maker shows errors and warnings next to fields (ADR-0017).

## Game Feel

Level difficulty should rise smoothly through a biome: one new idea per level, and the last level of the biome combines them. The meadow sequence raises base speed from 0.6 to 1.0 cells/s (very slow early, user decision) and adds one idea per level; the build-race and shape levels (5, 6) are a low-pressure break before the second half.

## UI Requirements

Player-facing: none (Menus & Level Select shows names). Designer-facing: the level maker dock (ADR-0017), which lists effective values and validation results per field.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `docs/architecture/adr-0005-data-format-validator.md` | JSON format, `schema`, flat `knobs`, `rules`, `recipe`, loader, validator, `level_hash` |
| `docs/architecture/adr-0004-rule-twist-runtime.md` §2–4 | Knob ids, rule JSON, F3 by layer, slots |
| `docs/architecture/adr-0011-mechanic-level-event-runtime.md` §2, §8 | `mascot`/`content` layers; staging trees in the level scene |
| `docs/architecture/adr-0015-audio-feedback-pipeline.md` §5 | `music` field, biome `default_music` |
| `docs/architecture/adr-0017-level-maker-tooling.md` | Level maker dock, live validation, Locked warning |
| `docs/architecture/adr-0013-save-profile-settings.md`; `design/gdd/onboarding-accessibility.md` F1 | Relaxed timing |
| `design/gdd/board-grid.md` F1, F2, F4, F5; Core Rules 2, 4 | Board fields, readability and capacity checks |
| `design/gdd/piece-set.md` Core Rules 7–8; Visual/Audio | Piece-set fields and validation; hue bands |
| `design/gdd/piece-spawner-queue.md` Tuning Knobs; F4 | Spawner fields and checks |
| `design/gdd/touch-controls.md` Core Rule 9 | Progressive disclosure of axes |
| `design/gdd/level-goals-fail-states.md` F1; Edge Cases | Goals, default N, validation |
| `design/gdd/rule-twist-framework.md` F3; Core Rules 15–17 | Rule caps and checks |
| `design/gdd/level-specific-mechanics.md` F2, F3 | Length estimates; mechanic rules |
| `design/gdd/twist-library.md` Core Rule 3 | Twist parameters and incompatibilities |
| `design/levels/meadow.md` | Full Meadow level specs |
| `design/gdd/game-concept.md` | 10 biomes × 10 tiers; MVP biome |

## Acceptance Criteria

**[U]** unit, **[I]** integration, **[M]** manual or device.

1. [U] **GIVEN** a level with only `id`, `biome` and `tier`, **THEN** it validates and plays with every default (6 × 6 footprint, `h_play` 10, 8 Standard shapes, Clear with N from Level Goals F1 for that board).
2. [U] **GIVEN** an unknown field or knob id, an out-of-range value or a fractional integer, **THEN** validation fails naming the field and range.
3. [U] **GIVEN** a shape that doesn't fit a masked region, 9 shapes, or 4 shapes in one hue band, **THEN** validation fails.
4. [U] **GIVEN** 3 twists, 2 mechanics, Gravity Flip with Build Race, or Conveyor on a masked board, **THEN** validation fails; **GIVEN** 2 twists, 1 mechanic and 2 `content` rules, **THEN** it passes the budget check.
5. [U] **GIVEN** a board whose cube edge would be 18 px, **THEN** validation fails; 25 px → warning.
6. [U] F1: meadow_01 → about 171 s (warning, still playable); meadow_05 → about 283 s; meadow_03 → about 427 s.
7. [I] **GIVEN** each of the 10 meadow levels, **THEN** all validate and load.
8. [I] **GIVEN** meadow_01, **THEN** only spin is enabled, only the 5 flat shapes appear, and the first 2 pieces are O or I.
8a. [U] **GIVEN** a mask with the footprint centre off and no `spawn_anchor`, an anchor on an inactive cell, an ASCII grid with the wrong row count, or an `opening_set` shape outside the level's set, **THEN** validation fails naming the field.
9. [I] **GIVEN** meadow_10, **THEN** Conveyor Floor, Wind and Gravity Flip are all active and shown on the Intro card, and exactly one flip happens.
10. [U] **GIVEN** a shipped level edited, **THEN** its version increments.
11. [U] **GIVEN** `music` with an unknown id, **THEN** a warning is listed and the biome's `default_music` is used; **GIVEN** a file path in `music`, **THEN** validation fails.
12. [U] **GIVEN** a level JSON with a key naming a scene or staging tree, **THEN** validation fails (unknown key); the same level played with and without its `.tscn` gives the same sim result.
13. [U] F2: with relaxed timing on, meadow_09's star times are 490 s / 345 s, the file's `level_hash` is unchanged, and the saved record has no relaxed marker.
14. [U] **GIVEN** a biome record with `side_island: true`, **THEN** Campaign Structure does not require its levels to open the next main-chain biome.
15. [M] **GIVEN** a playtest of the 10 meadow levels, **THEN** each level's median length is 5–15 min and testers report that difficulty rises without a sudden spike.

## Open Questions

- ~~**Storage format**~~: JSON (ADR-0005).
- ~~**meadow_06 shape**~~: authored in `design/levels/meadow.md` (50-cell flower, 2 layers).
- ~~**Level editor**~~: in-engine EditorPlugin dock for the dev team (ADR-0017, user 2026-10-10).
- ~~**Star times**~~: in `design/levels/meadow.md`, balanced for no perks; relaxed scaling in F2.
- **Tier meaning**: in the campaign, tiers re-run biomes with added mechanics; the MVP uses tier = level number in one biome. Confirm in Campaign Structure.
- **Side-island biomes**: which of the 10 biomes are side islands, and do their stars count toward any gate? Campaign Structure.
