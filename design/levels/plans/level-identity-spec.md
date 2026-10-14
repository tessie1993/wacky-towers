# Level identity spec: every level different in look and play

User, 2026-10-14: "redo the art, all levels look the same, redo the level design, make each level
not just in art but also different in game play."

Audit (168 levels): 123 use `clear_n`, 163 are plain 8x8 squares, and only 9 use a board mask. Every
biome repeats the same tier template. This spec sets the rules every level must meet.

## Gameplay variety rules (per biome, 14 levels)

- **Board footprint:** at most 4 of the 14 levels are plain squares. The others use `board.mask` shapes
  (8x8 minimum bounding box, up to 12x12). Shapes include cross, ring with a hole, L, twin islands joined
  by a bridge, terraces (masks that differ per layer), diamond, U-bay, and stepping stones. The island
  art follows the mask automatically (WtIslandBuilder.build_island uses the active cells).
- **Goals:** at most 5 `clear_n` levels per biome. Use the full set: `height`, `shape`, `survive`,
  `bonk_boss`, `rescue_all`, `dig_rescue`, `wind_keys`, `bake_oven`, plus any goal in
  assets/data/goals.json.
- **No two levels share the same (goal, main rule, board shape) triple**, across the whole campaign.
- **Each level has one signature idea.** Write it as `metadata.signature`, a single sentence the
  player would use to describe the level ("the one where the Kraken steals your top row").
- **Arc:** teach (01–03), twist (04–06), combine (07–09), boss finale (10, `bonk_boss` with phases
  via `active_after_clears`). Bonus is a playful set piece. h1–h3 remix the biome's best ideas at speed.
- **Fairness:** the next block is random on every attempt. Never use `fixed_list`; puzzles use the
  `kit` + `spawn.arrival: kit_box` pattern. Use per-attempt `variation` where eligible.
- **Difficulty:** `fall.g0` rises across tiers 01→10. The hard track (h1–h3) is faster than tier 10.
  Stars come from the formula in the plan files, not copied.
- All levels must pass `tools/qa/verify_campaign_biomes.gd` with 0 failures.

## Visual identity: the `look` block (level JSON, optional, overrides the biome look)

```json
"look": {
  "time_of_day": "dawn | day | golden | dusk | night",
  "weather": "clear | mist | drizzle | snow | embers | bubbles | petals | stars | confetti",
  "set_piece": "<id from assets/data/set_pieces.json>",
  "set_piece_side": "left | right | back",
  "accent": "#RRGGBB",
  "camera": "default | low | high | wide | close",
  "dressing": "sparse | normal | lush"
}
```

- **time_of_day** sets the sky gradient, sun angle, colour and energy, and fog colour, using presets in
  `assets/data/look_presets.json`.
- **weather** adds a GPUParticles3D or CPUParticles3D layer (Compatibility-safe), and is skipped under
  reduced motion.
- **set_piece** is one big landmark next to the board that makes the level recognisable: windmill,
  castle gate, kraken, volcano vent, clock tower, ferris wheel, crystal geode, treehouse, lighthouse,
  observatory, gingerbread house, shipwreck, and so on. Each biome gets 4–6 set pieces. Use
  `assets/models/env_v3` GLBs or builder primitives, and list them in `assets/data/set_pieces.json`.
- Within a biome, no two consecutive levels share the same `time_of_day` + `set_piece`.

Owners:
- Engine and view (`look` support, presets, set pieces, weather): src/view and the new data files.
- Level data (all `board`, `goal`, `rules`, `look` and `metadata.signature` values): level JSONs.
