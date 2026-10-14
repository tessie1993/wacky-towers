# Candy plan: Mallow's Birthday Cake

> Layer 1 (Play, Progression role) by level design, 2026-10-14. Sources: `src/levels/candy/*/*.json` (the source of truth for numbers), `assets/data/campaign/catalog.json`, `design/levels/candy.md`, `design/levels/mockup-alignment.md`, `design/levels/minigame-stages.md`, `assets/data/rules/*.json`, `assets/data/modules/*.json`.
> Star times are shown in seconds (the JSON stores ms). Every "Proposed change" is a proposal for the user and the game-designer. No JSON has been edited.

## Biome intro

**Theme.** A bakery and a giant birthday cake. Blocks fall as a gummy drizzle in three flavours: strawberry (P), vanilla (V) and mint (M), each with its own surface pattern so colour is never the only cue. Mallow the marshmallow bunny is a **mood swing**: happy, she helps; grumpy, she plays a telegraphed prank. Madame Meringue watches from the shelf from 05 and is the boss in 10.

**Mechanics Candy introduces:**
1. **Colour matters, in two steps**: `mono_layer` (01–04, a one-flavour layer is a bonus, and colour can be ignored safely), then colour decides stars (05 `tier_frosting`), goals (06 colour picture) and clears (07–10 `colour_pop` with `clear.detector: colour_connect`).
2. **Objects that land on your stack**: `gumdrop_hail` (sticky gumdrops), and later `goo_spread` (chocolate) and `licorice_lock`.
3. **New collapse rules**: `clear.collapse: gummy` (same-flavour blobs fall as one rigid chunk) and `cascade`.
4. **A two-stage boss**: `bake_stage` turns the built cake into sponge, then `climber_boss` + `bonk_boss` (hit the boss with pops).

### Curve table (as authored in JSON)

| id | tier | type | goal | g0 | stars ★★ / ★★★ |
|---|---|---|---|---|---|
| candy_01 | 1 | twist | clear_n 2 | 0.65 | 290 / 210 s |
| candy_02 | 2 | defender | clear_n 2 (2 starter layers) | 0.70 | 215 / 155 s |
| candy_03 | 3 | twist | clear_n 3 | 0.75 | 500 / 350 s |
| candy_04 | 4 | balance | clear_n 3 | 0.80 | 425 / 295 s |
| candy_05 | 5 | race | height 8 (coverage 0.6) | 0.85 | 3 / 4 frosted tiers |
| candy_06 | 6 | completing | colour picture, 38 of 45 correct | 0.85 | 160 / 115 s |
| candy_07 | 7 | defender | clear_n 5 (pops or layers) | 0.93 | 490 / 350 s (+0 worms escaped) |
| candy_08 | 8 | twist | survive 150 s | 0.95 (+0.15/min) | 1 / 2 layers |
| candy_09 | 9 | funny | clear_n 5 (pops or layers) | 1.00 | 565 / 400 s |
| candy_10 | 10 | defender (boss) | bake_oven height 4 → bonk_boss 3 | 1.05 | 340 / 240 s |
| candy_bonus | 11 | completing | colour box 32 cells, 60 s | 0.55 | 45 / 30 s (+no paw) |
| candy_h1 | 12 | funny | clear_n 6 | 1.00 | 505 / 350 s |
| candy_h2 | 13 | twist | rescue_all (peel frosting) | 1.00 | 350 / 245 s |
| candy_h3 | 14 | defender | bonk_boss 4 | 1.05 | 280 / 200 s |

### What the curve gets right, and what it gets wrong

- **Right:** the two-step colour ramp is a textbook teach → test: colour is optional (01–04), then scores (05), then the goal (06), then the clear itself (07–10). Speed rises cleanly from 0.65 to 1.05. All six level types are present. The boss is a genuine two-stage set piece with a face (`climber_boss`), and the rematch (h3) reuses it.
- **Wrong 1, mask artifacts from the 8x8 amendment:** `candy_05` and `candy_07` carry the old 6x6 "round" corners as four **interior holes** (`#.####.#` on rows 1 and 6). `candy_10` and `candy_h3` carry the old 7x7 round corners with a stray extra column and row (`.#####.#`). Neither reads as a round cake any more, and interior holes are unreadable traps.
- **Wrong 2, the axis flip breaks the cube:** `candy_09` was a 6x6x6 cube so that the -x axis flip maps the volume onto itself. On 8x8 with h_play 6 it is not a cube any more.
- **Wrong 3, three colour-pop clear levels in the late game** (07 clear 5, 09 clear 5, h1 clear 6), all about 8–9 minutes long. Same verb, same length.
- **Wrong 4, no minigame blocks.** Mockup-alignment gives Candy Cake Stackers (`balance_plate`), Sugar Siege (`fort_siege`), Candy Dodger (`bridge_dash` + `gumdrop_hail`) and a Gingerbread `boss_hp`. Only `bridge_dash` has a data file today.
- **Wrong 5, hardcoded sequence:** `candy_bonus` uses `fixed_list` + `fixed_hues`.
- **Wrong 6, inset starters:** `candy_02` keeps its 5x5 starter in the corner of an 8x8 board, so the "double clear from the pockets" now needs about 40 extra cells per layer.

**Proposed biome arc after the changes:** teach colour safely (01–03) → twist (04 tilting jelly plate) → build (05 tiers) → picture (06) → colour clears under pressure (07 worms, 08 rush) → combine (09 fountain cube) → **two-stage boss** (10) → puzzle bonus → hard track with **three different verbs**: a bridge race (h1 Candy Dodger), a peel puzzle (h2), the boss rematch (h3).

---

### candy_01: Sugar Cube Start  (tier 1, twist)

**Play** (layer 1)
- Goal: `clear_n` 2 (rescue, 2 warnings).
- How it plays: The Meadow game with flavour. Pieces from {I, O, T, L, S} fall at 0.65, each in one of two flavours, with a 60% chance that the next piece repeats the last flavour. Any clear works, but a layer of one flavour is a "sugar sparkle" that also clears the next layer (`mono_extra_layers` 1). Mallow's mood follows tidiness: happy, she points at a good cell and can catch one bad lock; grumpy, her prank is cosmetic (she bounces off the screen edge). A gummy duck secret hides under the island.
- Teaches / tests: Colour exists and is a bonus, never a penalty.
- Rules and minigame blocks: `mono_layer` {mono_extra_layers 1}; `mascot_mood` {prank bounce}; `mascot_catch` {catches 1, happy_only}; `angle_gem` {skin gummy_duck} (secret). Knobs: `spawn.colour_count` 2, `spawn.colour_streak` 0.6, `goal.t_piece_s` 8. No module.
- Board: 8x8, h_play 8, empty. Opening 2 from {O, I}; random bag and flavours after that.
- Difficulty: g0 0.65; ★★ 290 s, ★★★ 210 s. The floor of the biome.
- Proposed changes: Type `twist` → `funny`: tier 1 should not be the twist slot (the mood mascot is the funny hook; the real twist arrives in 03). With `colour_streak` 0.6 a mono layer of 64 cells needs about 16 same-flavour pieces in a row, which almost never happens on 8x8. Raise `spawn.colour_streak` to 0.8 for this level only, or let a mono layer count at ≥ 85% one flavour (`mono_layer.mono_share` 0.85, NEW param) so players actually see the sparkle in the first level that teaches it.

**Progression role** (layer 1): The Candy opener after the Meadow boss. It brings the speed back down and adds exactly one idea (flavour) on top of the Meadow base. It hands off to 02, where objects start landing on the stack.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_02: Gumdrop Hail  (tier 2, defender)

**Play** (layer 1)
- Goal: `clear_n` 2 (rescue, 1 warning).
- How it plays: Two holey starter layers fill the cake tin. The first three pieces are a random order of {T, L, Tripod}, which fit its pockets. After 6 locks, a sticky gumdrop drops onto a free top cell every 4 locks (max 6), never into a starter hole. A gumdrop fills a cell, so it can complete a layer, but it can also cap a hole the player was saving. The player defends the open pockets by filling them before the hail arrives.
- Teaches / tests: Objects land on the stack; fill what matters before the hail starts.
- Rules and minigame blocks: `mono_layer` {1}; `gumdrop_hail` {object gumdrop, sticky, spawn_every_locks 4, objects_max 6, hail_after_locks 6, avoid_start_holes}; `mascot_mood` {bounce}; `mascot_catch` {1, happy_only}; `angle_gem` {gummy_duck}. No module.
- Board: 8x8, h_play 10, 2 starter layers in a 5x5 block at x 1–5, z 1–5. Opening is a random order of {T, L, Tripod}.
- Difficulty: g0 0.7; ★★ 215 s, ★★★ 155 s.
- Proposed changes: (1) **Re-centre and widen the starter**: the 5x5 starter now covers 25 of 64 cells, so the pocket fills no longer lead to a quick clear. Extend both starter layers to the full 8x8 (keeping the same 3 pockets per layer, re-centred at x 2–6, z 2–6) and leave 4 single-cell gaps per layer on the rim, so the first clear still lands in about 6 pieces. (2) Add a `variation` block (8 symmetries) so the pockets move between attempts.

**Progression role** (layer 1): The Candy version of `meadow_02` (pockets), with the first object-drop hazard of the campaign. Gumdrops return as the 03 callback, and as icing dollops in the boss. It hands off to 03's first true Candy twist.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_03: Syrup River  (tier 3, twist)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning).
- How it plays: Rows z 3–4 are a syrup river. A piece with any cube over the band falls at half speed (more aiming time), and a piece that comes to rest over it glides up to 2 cells along +x before it locks. The player learns to drop *upstream* of the gap they want and let the syrup carry the piece home. Sticky gumdrops (every 8 locks, max 3) do not glide, so they act as fixed dams in the river.
- Teaches / tests: Syrup: slow fall plus a glide you can aim with.
- Rules and minigame blocks: `mono_layer` {1}; `syrup_band` {band_rows [3, 4], syrup_slow 0.5, syrup_dir +x, syrup_glide 2}; `gumdrop_hail` {sticky, every 8, max 3}; `mascot_mood` {hop_nudge}; `mascot_catch` {1, happy_only}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 0.75; ★★ 500 s, ★★★ 350 s. **A length spike** at tier 3 (about 8 minutes), as in `meadow_03`.
- Proposed changes: (1) Widen the river to make the twist central rather than local: `band_rows` [3, 4] → [2, 3, 4, 5] (half the board), so most pieces meet syrup. (2) `goal.n` 3 → 2 and stars ×0.7 (about 350 / 245 s). The level is about the glide, not about volume. (3) Keep `mascot_catch`: it is the last level with it.

**Progression role** (layer 1): Candy's ★PROTO-lite twist and the first rule that moves a *resting* piece (where Meadow's gust moved a *falling* one). The syrup band returns in h2. It hands off to 04, where the collapse rules change.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_04: Jelly Wobble  (tier 4, balance)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning).
- How it plays: One piece per bag is jelly: it bounces once on landing (`jelly_bounce` 1) before it settles, so it can hop over a ledge into a gap. After a clear, `gummy` collapse drops each same-flavour blob as one rigid chunk, which keeps its overhangs, so colour grouping now changes what the stack looks like after a clear. A wobble meter (max 7) punishes overhangs. The bag is weighted toward flat pieces (I, O, L ×1.5).
- Teaches / tests: Jelly bounce + gummy collapse: colour starts to change the physics of the stack.
- Rules and minigame blocks: `mono_layer` {1}; `jelly_piece` {per_bag 1, jelly_bounce 1}; `mascot_mood` {bridge_jump}; `wobble` {wobble_max 7}. Knob `clear.collapse: gummy`. No module.
- Board: 8x8, h_play 9, no mask (the 8x3 jelly bridge of the design is gone). Random bag.
- Difficulty: g0 0.8; ★★ 425 s, ★★★ 295 s.
- Proposed changes: **Make Candy's balance level different from the Meadow's.** Swap `wobble` for `tilt_plate` {slip_threshold 0.6, slip_count 1, warn_at 0.7, slip_after_resolves 1, physics false} (the rule exists, and it is incompatible with `wobble`, so it is a straight swap). The whole jelly plate tips toward the heavy side and the top cubes slip off the low edge, which is what the mockups' Cake Stackers / Tumbling Towers show. Restore the bridge feel with a mask: rows 0–1 and 6–7 off (an 8x4 jelly bridge on an 8x8 board). If the user rules that playable cells must also be 8x8, use rows 0 and 7 off (8x6) instead. This becomes the Candy bind for the `balance_plate` slot until the Jolt module exists (flag F2).

**Progression role** (layer 1): The midpoint of the "colour is optional" half. It introduces the gummy collapse that 09, 10 and h1 rely on, and (as proposed) the plate tilt that later biomes reuse. It hands off to 05, where colour starts to score.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_05: Cake Tiers  (tier 5, race)

**Play** (layer 1)
- Goal: `height` 8 with coverage 0.6. Trim top-out (no fail).
- How it plays: Nothing clears; the cake rises. Every 2 layers form a tier, and a tier is "frosted" when at least half its cubes share one flavour that differs from the tier below. Stars count frosted tiers, so the player races upward while alternating flavours tier by tier, using Big Cubes (two layers at once) to frost a tier fast. Mallow's grumpy prank licks a piece and swaps its flavour.
- Teaches / tests: Colour now scores: plan flavour by height band.
- Rules and minigame blocks: `build_race` {top_out trim}; `tier_frosting` {tier_layers 2, frost_share 0.5}; `mascot_mood` {lick_swap}. Knobs: 3 flavours, `colour_streak` 0.4. No module.
- Board: 8x8, h_play 10, mask with 4 **interior** holes at (1,1), (6,1), (1,6), (6,6). 8 shapes + Big Cube (0.5).
- Difficulty: g0 0.85; ★★ 3 frosted tiers, ★★★ 4 (of 4 possible). A no-fail rest.
- Proposed changes: (1) **Fix the mask**: the holes are the old 6x6 round corners, offset by 1. Use a true round cake: `["..####..", ".######.", "########", "########", "########", "########", ".######.", "..####.."]` (52 cells). (2) Add `turntable` (it exists) at a slow rate for a Cake Stackers feel: the cake turns 90° every N locks, so the frosting has to be planned around the whole cake rather than one face. This is the one new idea the level is missing, and it is the minigame-stages "Cake Stackers" twist. Budget check: build race bundle + tier frosting + turntable = 2 new ideas.

**Progression role** (layer 1): The first rest of the biome, and the "colour scores" step of the ramp. It mirrors `meadow_05` (a height race) but asks a new question (which flavour where). It hands off to 06, where colour becomes the goal.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_06: Icing Picture  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape` with colour targets: pipe a 45-cell bunny picture (vanilla body, strawberry details) in one layer; 38 correct cells win. A cell counts only if covered by its flavour or by a rainbow cube.
- How it plays: A flat painting puzzle on an 8x8 slab with only 3 layers of headroom and spin-only rotation. Each piece arrives in a flavour (70% vanilla, 30% strawberry), and the player places it where *its* colour belongs, using the small pieces (Duo, Tri-Straight, Tri-Corner) for single strawberry dots. One piece per bag is rainbow and counts for any colour. Mallow's grumpy prank smudges a placed cell (max 2, telegraphed), and when happy she licks one cell clean every 6 locks.
- Teaches / tests: Colour as the goal: read piece colour, then place.
- Rules and minigame blocks: `fill_shape` {top_out trim}; `rainbow_piece` {per_bag 1}; `mascot_mood` {smudge, smudge_cap 2, happy_lick_every_locks 6}. No module.
- Board: 8x8, h_play 3, empty; spin only. Target fixed, pieces random.
- Difficulty: g0 0.85; ★★ 160 s, ★★★ 115 s (★★★ needs no trimmed cube). The second rest.
- Proposed changes: Add a `variation` block with `mirror_x` (the bunny is left-right symmetric), so retries differ in piece-to-target fit. Otherwise none: a strong, readable rest beat.

**Progression role** (layer 1): The "colour is the goal" step and the companion of `meadow_06` (picture). It is the last calm beat before 07 makes colour the clear rule.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_07: Gummy Worms  (tier 7, defender)

**Play** (layer 1)
- Goal: `clear_n` 5, where colour pops count as well as layers (rescue, 1 warning).
- How it plays: The clear rule changes: 6 or more face-connected cubes of one flavour from at least 2 pieces **pop**, and full layers still clear too, with a cascade collapse after each. Gummy worms crawl out of two holes in the floor (one per lock, more after 60 s) and head for the rim; a worm that escapes costs ★★★. The player defends the jar by popping colour groups on top of the worms, so the colour plan and the defence are the same action.
- Teaches / tests: Colour pops as a clear rule, under a defender pressure.
- Rules and minigame blocks: `colour_pop` {pop_min 6, pop_min_pieces 2, layer_clear_too}; `pest` {skin gummy_worm, ant_every_locks 1, late_spawn_s 60, rim_escape}; `mascot_mood` {tickle_worm}. Knobs `clear.detector: colour_connect`, `clear.collapse: cascade`, 3 flavours. No module.
- Board: 8x8, h_play 10, the same 4-interior-hole mask as 05, 2 worm holes (`p`). Per-attempt `variation`: 8 symmetries + worm-hole jitter radius 1.
- Difficulty: g0 0.93; ★★ 490 s, ★★★ 350 s and 0 worms escaped. A ★PROTO and the start of the hard half.
- Proposed changes: (1) **Fix the mask** as in 05 (round cake), because interior holes next to worm holes are unreadable. (2) Shorten: `goal.n` 5 → 4 and stars ×0.8 (about 390 / 280 s). Pops are smaller than layers, and the level already teaches; 09 is the long colour exam.

**Progression role** (layer 1): Colour becomes the clear rule. This is the most important teaching level of the biome, and it is ★PROTO. 08 then stresses it with speed, and 09 combines it with goo, licorice and the flip.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_08: Sugar Rush  (tier 8, twist)

**Play** (layer 1)
- Goal: `survive` 150 s (rescue, 1 warning); ramp +0.15 per minute. Stars by layers: ★★ 1, ★★★ 2.
- How it plays: Colour pops are on (6+ same flavour, layers too). Mallow's mood *is* the event: when she turns grumpy, a sugar-rush speed bump adds +10% fall speed per notch every 10 s (max 3 notches, 1 s warning), so a messy board literally speeds the game up. A pop of 7+ cubes earns a candy bomb, which the player can drop to blast out a messy area and calm her down.
- Teaches / tests: A feedback loop: tidiness → mood → speed, with an earned bomb as the pressure valve.
- Rules and minigame blocks: `colour_pop` {pop_min 6, layer_clear_too}; `speed_bump` {bump_trigger mood, notch_every_s 10, notch_max 3, notch_pct 10, warn_ms 1000}; `earned_specials` {bomb_at 7, rocket_at 0, colour_bomb_at 0}; `mascot_mood` {rush}. No module.
- Board: 8x8, h_play 8, empty. Random bag and flavours.
- Difficulty: g0 0.95; ★★ 1 layer, ★★★ 2 layers. A short frantic spike (2.5 min).
- Proposed changes: (1) As in `meadow_08`, the board grew from 5x5 to 8x8 and lost its pressure; restore it with `goal.t_ms` 150000 → 120000 and ramp 0.15 → 0.25 per minute. (2) Make the stars read the level's own verb: count **pops or layers** (`stars.metric: "clears_any"`, NEW) with ★★ 3 and ★★★ 5, matching the design's "2 / 4 clears" intent on the bigger board. Layers alone are rare on an 8x8 colour board.

**Progression role** (layer 1): The short spike between the long 07 and 09 (alternating lengths). It is the only level where the mascot *is* the hazard, which is Candy's signature. It hands off to the 09 combine.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_09: Chocolate Fountain  (tier 9, funny)

**Play** (layer 1)
- Goal: `clear_n` 5, pops or layers (rescue, 1 warning).
- How it plays: The starter has stone, two gumdrops (`g`) and four licorice locks (`l`). Chocolate spreads by one cell per lock onto neighbouring cubes (it has no flavour, so it breaks pops), and a clear cancels the spread. Licorice cubes are locked until a neighbouring pop frees them. Once in the level (after 10 layers or 120 s, 4 s warning), the fountain tilts the cake: the down axis becomes -x, and everything falls sideways onto the new floor. The player races the spread with pops while preparing for one huge sideways tumble.
- Teaches / tests: The combine: colour pops + goo + locks + one axis flip.
- Rules and minigame blocks: `colour_pop` {6, layer_clear_too}; `goo_spread` {skin chocolate, per_lock 1, cancel_on_clear}; `licorice_lock`; `flip` {flip_mode axis, flip_to_axis -x, flip_every_layers 10, flip_every_ms 120000, flip_warn_ms 4000, flip_max 1}; `mascot_mood` {splash}. Knob `clear.collapse: gummy`. No module.
- Board: 8x8, **h_play 6**, starter in x 1–6, z 1–6. Per-attempt `variation`: 8 symmetries.
- Difficulty: g0 1.0; ★★ 565 s, ★★★ 400 s. The longest level of the biome, before the boss.
- Proposed changes: (1) **Restore the cube**: the axis flip needs the play volume to map onto itself (the design was 6x6x6). Set `h_play` 6 → 8 so the volume is 8x8x8 again; otherwise the -x flip sends 8 columns of stack into a 6-high space and trims or tops out unfairly. (2) Extend the starter to the full 8x8 footprint (or move it to x 1–6 with the ring filled) so the volume is consistent after the flip. (3) Shorten: `goal.n` 5 → 4, stars about 450 / 320 s, and make the flip time-only (`flip_every_ms` 90000) so every player sees it once, instead of only those who are slow.

**Progression role** (layer 1): The busiest showpiece before the boss (at the 6-atom showpiece cap). It combines everything Candy taught and adds the only flip of the biome, preparing the player for the stage switch in 10.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_10: Madame Meringue  (tier 10, defender)

**Play** (layer 1)
- Goal: Stage 1 `bake_oven`: build to height 4 with 0.6 coverage (trim). Stage 2 `bonk_boss`: 3 bonks (rescue, 1 warning).
- How it plays: Stage 1 is a short build race on the cake table, while icing dollops drop every 5 locks (max 4). When the cake reaches the oven line, a 2 s oven timer runs, every locked cube becomes sponge (solid, no flavour, never clears) and the dollops become 2-layer frosting. Stage 2 switches to colour pops with gummy collapse: Madame Meringue (a 2x2x1 climber boss) slides to the highest reachable spot after every lock, and a pop touching her is a bonk that tumbles her down. The player builds colour groups *next to where she will climb*.
- Teaches / tests: The finale: build (05) → colour pops (07) → hit a moving target.
- Rules and minigame blocks: `bake_stage` {bake_warn_ms 2000, frost_layers 2, stage2: bonk_boss 3, colour_connect, gummy, rescue, 1 warning}; `climber_boss` {size [2,2,1], skin meringue}; `gumdrop_hail` {icing_dollop, every 5, max 4}; `mascot_mood` {watcher}. No module (it is the closest thing to `boss_hp` in the game today).
- Board: 8x8, h_play 14, mask `.#####.#` on rows 0 and 6 (old 7x7 round corners + a stray column 7 and row 7). Chair added to the pool, S removed.
- Difficulty: g0 1.05; ★★ 340 s, ★★★ 240 s. The biome peak and a ★PROTO.
- Proposed changes: (1) **Fix the mask** to the true 8x8 round cake used in 05 (the stray column and row make the "cake" lopsided and give the boss an unreachable ledge). (2) When `boss_hp` (A6) lands, move to `modules: [{ "id": "build_race", "until": "height_4", "until_role": "stage" }, { "id": "boss_hp", "params": { "hp": 3, "dmg_per_clear": 1 } }]`, so the boss shows an HP bar (HUD `horizontal_bar`, mockup-alignment §1.4) instead of a bonk counter. No other change: this is the best boss in the four biomes.

**Progression role** (layer 1): The payoff. It reuses the build race (05) and colour pops (07–09), and introduces the stage switch and the climber boss, which `candy_h3` remixes and later bosses (Underwater's crab) echo. It unlocks the hard track and opens Ice.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_bonus: Candy Box  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape` with colour targets: a 4x4 × 2-layer chocolate box (32 cells; strawberry, vanilla and mint regions) within 60 s. Trim.
- How it plays: A colour packing puzzle against the clock. The player sees 3 pieces ahead, each with a fixed flavour, and must put each in its flavour's region of the box. Every 15 s Mallow's paw reaches in (2 s warning) and eats a placed cube; losing one costs ★★★.
- Teaches / tests: Shape and colour planning from the preview at once.
- Rules and minigame blocks: `fill_shape`; `mascot_paw` {every_s 15, warn_ms 2000}. No module.
- Board: 8x8, h_play 2, target at x 2–5, z 2–5. **`fixed_list` [Big Cube, Big Cube, I, I, O, O] with `fixed_hues` [1, 2, 3, 3, 1, 3]**: the same pieces and colours on every attempt.
- Difficulty: g0 0.55; ★★ 45 s, ★★★ 30 s and no paw-eaten cube.
- Proposed changes: **Remove `fixed_list` and `fixed_hues`** (standing rule). Use the same `pieces.deal_pool` as `meadow_bonus`, with colours: each entry is a multiset of (shape, flavour) that packs the box exactly, and the **target colours are generated from the dealt multiset** (the region layout is chosen at random among the valid packings), so each attempt is a fresh, solvable picture. Example entries: {BigCube P, BigCube V, I M ×2, O P, O M} (today's), {BigCube M, BigCube P, BigCube V, O V ×2}, {BigCube P, O V ×4, I M ×2}. The validator proves each entry against its generated target.

**Progression role** (layer 1): Unlocks at 20 Candy stars. A short colour-puzzle break, the colour sequel to `meadow_bonus`. It does not count toward the Ice gate.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_h1: Moody Gummies  (tier 12, funny)

**Play** (layer 1)
- Goal: `clear_n` 6, pops or layers (1 warning).
- How it plays: Colour pops with gummy collapse, as in 07–09. One piece per bag is a moody gummy, a cube with a temper (wave-3 `moody_cube`) that reacts to its neighbours, so the player has to place it where it is "happy" or it disrupts nearby groups. Otherwise it is a long colour-pop clear.
- Teaches / tests: Remix: colour pops + a cube with its own behaviour.
- Rules and minigame blocks: `colour_pop` {6, layer_clear_too}; `moody_cube` {per_bag 1}; `mascot_mood` {tickle_gummy}. Knobs `colour_connect`, `gummy`, 3 flavours. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 1.0; ★★ 505 s, ★★★ 350 s.
- Proposed changes: **Replace with Candy's minigame block, Candy Dodger** (mockup-alignment #23): `modules: [{ "id": "bridge_dash", "params": { "gap_cells": 6, "pillar_cells": 1, "pillar_height": 3, "step_max": 1, "hold_ms": 500, "walk_ms": 250 }, "overlays": [{ "id": "pace_mascot" }] }]` with `gumdrop_hail` {sticky, every 3 locks, max 6} as the falling hazard and `moody_cube` kept as the wave-3 rule (a moody gummy in the deck shuffles one cell when grumpy, which can break the path during `hold_ms`). Moment to moment: pave a frosting road across the gap while gumdrops rain; a sticky gumdrop on the path is a free step, one in the wrong place is a bump the walker cannot climb. Type → `race`; stars about 120 / 85 s. This removes the third long colour-pop level in a row and gives Candy its minigame block. **Needs** `gumdrop_hail` added to `bridge_dash.compatible_overlays` (game-designer decision). Fallback without modules: keep h1, with `goal.n` 6 → 4 and stars about 340 / 235 s.

**Progression role** (layer 1): The first Candy remix, after 10. As proposed, it turns the hard track's opener into a race (the Meadow bridge verb in Candy dress), so the three remixes are a race, a puzzle and a boss.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_h2: Frosting Factory  (tier 13, twist)

**Play** (layer 1)
- Goal: `rescue_all` frosting: peel every frosting tile on the starter to 0.
- How it plays: The starter holds stone and frosting tiles with 2 or 3 layers (`2`, `3`). A frosting cell counts as filled for layer fullness but is not removed by its own layer's clear; a clear that removes a cube face-adjacent to it peels it by one. The syrup river (z 3–4) slows and glides pieces along +x, so the player has to land pieces next to the frosting, using the glide to slide them in. Plain layer clears are the tool, and the frosting is the target.
- Teaches / tests: Remix: syrup (03) as an aiming tool for a peel-the-targets puzzle.
- Rules and minigame blocks: `syrup_band` {[3, 4], 0.5, +x, glide 2}; `frosting`; `mascot_mood` {hop_nudge}. 3 flavours (not used by the clear rule). No module.
- Board: 8x8, h_play 10, starter rows z 2–5 only (the 8x4 lane of the design inside an 8x8 board). No layout variation.
- Difficulty: g0 1.0; ★★ 350 s, ★★★ 245 s.
- Proposed changes: (1) Add a `variation` block (mirror_x, mirror_z) on the starter. (2) The starter covers only rows 2–5, so the first clear needs 32 more cells than designed; fill rows 0–1 and 6–7 in layer 0 with stone, leaving 2 gaps per row, so layer 0 is close to clearing and the first peel comes quickly.

**Progression role** (layer 1): The puzzle remix. A target-based goal (like Meadow's picture) in a clear-based biome, and the hard track's breather between the race (h1) and the boss rematch (h3).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### candy_h3: Meringue's Rematch  (tier 14, defender)

**Play** (layer 1)
- Goal: `bonk_boss` 4 (1 warning).
- How it plays: The rematch starts where the boss ended: four layers of baked sponge already fill the cake, so stage 2 starts straight away with a high floor and only colour pops to work with. Madame Meringue climbs to the top after each lock. Every 8 locks she throws a countdown bonbon that ticks down from 8 locks and blasts one layer when it reaches 0, so the player must either pop it in time or keep their colour groups away from it.
- Teaches / tests: Remix: the climber boss with a ticking threat.
- Rules and minigame blocks: `colour_pop` {6}; `climber_boss` {size [2,2,1]}; `countdown_bomb` {thrown_every_locks 8, cd_start 8, blast_layers 1}. Knobs `colour_connect`, `cascade`, 3 flavours. No module.
- Board: 8x8, h_play 14, the same lopsided `.#####.#` mask as 10, 4 sponge layers filling the old 7x7 footprint (column 7 and row 7 left empty, a 1-cell trench).
- Difficulty: g0 1.05; ★★ 280 s, ★★★ 200 s. The hardest Candy level.
- Proposed changes: **Fix the mask and the sponge** together: use the round cake mask from 05 and fill all of its cells in the 4 sponge layers. Today the sponge leaves a 1-cell trench along x 7 and z 7, which is the only place pops can form at the bottom and makes the opening degenerate.

**Progression role** (layer 1): The last Candy level and the boss rematch; it sends the player to Ice with colour, objects and bosses all covered.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
