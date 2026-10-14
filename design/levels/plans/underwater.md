# Underwater plan: Puff's Pearl

> Layer 1 (Play, Progression role) by level design, 2026-10-14. Sources: `src/levels/underwater/*/*.json` (the source of truth for numbers), `assets/data/campaign/catalog.json`, `design/levels/underwater.md`, `design/levels/mockup-alignment.md`, `design/levels/minigame-stages.md`, `assets/data/rules/*.json`, `assets/data/modules/*.json`.
> Star times are shown in seconds (the JSON stores ms). Every "Proposed change" is a proposal for the user and the game-designer. No JSON has been edited.

## Biome intro

**Theme.** A turquoise reef bowl. Blocks sink as a slow bubble drizzle. Puff the pufferfish wants a giant pearl back in its clam before sunset. Admiral Crab, a hoarder in a tiny hat, pranks the reef with currents, ink, a whirlpool and a stealing claw, and is the boss of 10. Quirk: "everything floats": the water leans on the pieces, and the stack is never quite where you left it.

**Mechanics Underwater introduces:**
1. **The crab's claw**: `crab_claw`, a telegraphed claw that steals a cube from the stack, scared off by clears. This is the biome's defender hook and the boss's attack.
2. **Bounce and drift**: `bounce_pad` (jellyfish that bounce a landing piece up and on in its last move direction) and `mushroom_popup` reskinned as drifting jellies.
3. **A board that moves under you**: `tilt_plate` (the shelf tips), `turntable` (Whirlpool, the whole stack rotates 90° on a telegraphed lock count), `conveyor` (Undertow) and `magnet_pull`.
4. **Rising floor**: `rising_silt` (a near-full layer pushes up from below with gaps), and the kit-box packing puzzle on the main path.

### Curve table (as authored in JSON)

| id | tier | type | goal | g0 | stars ★★ / ★★★ |
|---|---|---|---|---|---|
| underwater_01 | 1 | balance | clear_n 2 | 0.75 | 290 / 205 s |
| underwater_02 | 2 | defender | clear_n 3 (2 starter layers) | 0.80 | 265 / 185 s |
| underwater_03 | 3 | balance | clear_n 3 | 0.85 | 435 / 310 s |
| underwater_04 | 4 | funny | clear_n 3 | 0.90 | 430 / 305 s |
| underwater_05 | 5 | race | height 10 (coverage 0.6) | 0.95 | 265 / 185 s |
| underwater_06 | 6 | completing | shape 36 cells, kit of 9 | 0.60 | 210 / 135 s |
| underwater_07 | 7 | twist | clear_n 3 (kelp mask) | 1.00 | 400 / 280 s |
| underwater_08 | 8 | defender | survive 150 s | 1.05 (+0.1/min) | 1 / 2 layers |
| underwater_09 | 9 | twist | clear_n 3 | 1.10 | 435 / 310 s |
| underwater_10 | 10 | defender (boss) | clear_n 3 | 1.15 | 435 / 305 s |
| underwater_bonus | 11 | completing | shape 36 cells, 7 pieces | 0.50 | 75 / 50 s |
| underwater_h1 | 12 | funny | clear_n 4 | 1.05 | 535 / 375 s |
| underwater_h2 | 13 | twist | clear_n 3 | 1.05 | 400 / 285 s |
| underwater_h3 | 14 | defender | clear_n 4 | 1.10 | 535 / 375 s |

### What the curve gets right, and what it gets wrong

- **Right:** a clean speed ramp (0.75 → 1.15) with a deep rest at 06 (0.6, a no-clock kit puzzle). The claw is foreshadowed at 02 and pays off in 10 and h3. The biome has the widest set of "board moves" (tilt, whirlpool, undertow, magnet).
- **Wrong 1, goal monotony:** 10 of 14 levels are `clear_n`. The research note (`design/research/puzzle-party-research-2026-10.md`) already measured about 70% "clear N" across the campaign. This biome is the worst case after Ice.
- **Wrong 2, slot echoes across biomes:** the first four biomes repeat the same template at the same tier: 01 is a gentle clear (Meadow and Underwater both use `balloon`), 02 is a pocket starter (Meadow, Candy, Underwater), 05 is a height race (all four), 07 is fog (Meadow, Ice, Underwater). By biome 4 the player can predict the next level from its number.
- **Wrong 3, the boss has no face:** `underwater_10` is "clear 3" with a conveyor, gust and claw. Admiral Crab is in `story.boss` but nothing on the board is the crab. The rematch (h3) does not include the crab either.
- **Wrong 4, no minigame blocks.** Mockup-alignment gives Underwater Coral Conduit (`route_runner`), **Submarine Salvage** (`dig_down` + pressure), Reef Climb (`summit_climb`) and a Crab King (`boss_hp` + `crab_claw`). Submarine Salvage can be built today with the existing `dig_rescue` goal (used by Cave).
- **Wrong 5, data from the 8x8 amendment:** `underwater_05` keeps 5x5 stars (265 / 185 s for 10 layers of 64 cells). `underwater_02` keeps the 6x6 starter inset in an empty ring. `underwater_bonus` uses `fixed_list`.

**Proposed biome arc after the changes:** teach (01 bubbles, 02 claw) → twist (03 current + tilt, 04 jellies) → build and rest (05 coral spire, 06 necklace kit) → **minigame block: Submarine Salvage** (07, dig to treasure) → pressure (08 silt) → combine (09 whirlpool) → **boss with a target to protect** (10, defend the clam) → puzzle bonus → hard track with three goals: clear (h1), a height race in the whirlpool (h2), the crab rematch with a face (h3).

---

### underwater_01: Bubble Float  (tier 1, balance)

**Play** (layer 1)
- Goal: `clear_n` 2 (2 warnings).
- How it plays: Classic stacking at 0.75. The first two pieces are from {O, I}. One piece per bag rides a balloon-bubble: it sinks at 0.6× speed and drifts for up to 3.5 s, which gives extra aiming time. Puff points at a good cell, and can swallow one bad lock in a bubble and spit the piece back to the spawn. A rubber duck hides in an air bubble under the shelf.
- Teaches / tests: Re-entry: plain clears with the Underwater feel.
- Rules and minigame blocks: `mascot_hint`; `mascot_catch` {mascot_catches 1}; `angle_gem` {cell [3,-1,3], view_snap 150}; `balloon` {balloon_per_bag 1, balloon_g_mult 0.6, balloon_drift_ms 3500}. No module.
- Board: 8x8, h_play 9, empty. Random bag of 8 shapes.
- Difficulty: g0 0.75; ★★ 290 s, ★★★ 205 s. The floor of the biome.
- Proposed changes: (1) **Replace `balloon` with `bubble`** (SP39, the Underwater content rule: a bubble block that floats *up* to the stack's surface along a dotted rise line and pops there), at `bubble_per_bag` 1. `meadow_01` already uses `balloon` with nearly the same params, so the biome's first impression is a copy; the bubble is the Underwater twist on the same "gentle helper" idea, and it matches the biome quirk. (2) Type `balance` → `funny` (nothing here is about balance; `level-type-mix` lists `bubble` as funny).

**Progression role** (layer 1): Biome opener after the Ice sled finale: speed drops back, one gentle, biome-specific oddity. It hands off to 02, where the crab's claw is introduced.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_02: Clam Pockets  (tier 2, defender)

**Play** (layer 1)
- Goal: `clear_n` 3 (rescue, 1 warning).
- How it plays: Two holey starter layers form three clam "beds" sized for the Tripod and the two Screws, and the first three pieces are those shapes in random order. From the start (the starter already reaches 2 layers) Admiral Crab's claw reaches in every 30 s ± 4 s with a 2.5 s warning and steals one cube; a clear scares it off and resets its timer. The player fills the beds quickly and clears before the claw opens new holes.
- Teaches / tests: The claw: a telegraphed theft that clears push back.
- Rules and minigame blocks: `mascot_hint`; `mascot_catch` {1}; `angle_gem` {[4,-1,4], view_snap 210}; `crab_claw` {claw_start_layers 2, claw_every_ms 30000, claw_jitter_ms 4000, claw_warn_ms 2500, claw_grab 1, counter clear}. No module.
- Board: 8x8, h_play 10, 2 starter layers inset in x 1–6, z 1–6 (an empty 1-cell ring). No layout variation.
- Difficulty: g0 0.8; ★★ 265 s, ★★★ 185 s.
- Proposed changes: **Break the "02 = pockets" echo** (this is the third biome in a row to use it). Keep the claw as the one lesson: replace the pocket starter with one starter layer of reef rock that is full except for a random 2-wide trench (with `variation` jitter), so the first clear comes in about 4 pieces and the player meets the claw on a nearly full layer, where its theft is easy to read. Drop the {Tripod, Screws} opening (random bag). If the pockets are kept, fill the empty ring and add a `variation` block, as for `meadow_02`.

**Progression role** (layer 1): Introduces the boss's attack nine levels early, so the finale is a payoff rather than a surprise. It hands off to 03, where the water itself starts pushing.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_03: Current Lane  (tier 3, balance)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: A steady tide current: every 3 s ± 0.5 s (0.6 s warning) the falling piece is pushed one cell along +x, so a slow-falling piece drifts several cells on its way down. The reef shelf is a tilt plate: when the stack's weight is off-centre past 0.65, the top cubes on the low side slip off after 2 resolves. The current pushes everything toward one side and the plate punishes building there, so the player must aim upstream *and* keep the weight central.
- Teaches / tests: A constant current versus balance: drift and weight together.
- Rules and minigame blocks: `gust` {fixed, +x, 3000 ± 500, strength 1, warn 600}; `tilt_plate` {slip_threshold 0.65, slip_count 1, slip_after_resolves 2}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 0.85; ★★ 435 s, ★★★ 310 s.
- Proposed changes: (1) Shorten: `goal.n` 3 → 2, stars about 290 / 205 s. Tier-3 levels in all four biomes run 7–10 minutes; cap tiers 1–4 at about 5 minutes ★★. (2) Add `tilt_plate.warn_at` 0.7 explicitly (the default) and confirm the HUD shows the tilt meter, because two new ideas in one tier-3 level need both to be on screen.

**Progression role** (layer 1): The first "water pushes" level. It turns Meadow's gust into a constant current and adds the plate tilt (taught in Candy 04 if that proposal is adopted). The current returns in 05, 09, 10 and h1.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_04: Jellyfish Garden  (tier 4, funny)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: Three jellyfish bounce pads (`b`) sit on the floor. A piece that lands on one bounces 2 cells up and continues in its last move direction before it settles, so a jelly can launch a piece over a ledge into a far gap, or fling it somewhere silly. Every 8 locks a new jelly drifts onto a free top cell (max 3). The player learns to aim *at* the jellies on purpose.
- Teaches / tests: Bounce pads: a surface that redirects the piece.
- Rules and minigame blocks: `bounce_pad` {bounce_h 2, dir_mode last_move}; `mushroom_popup` {object_id jelly, spawn_every_locks 8, objects_max 3}. No module.
- Board: 8x8, h_play 10, 3 pads. Per-attempt `variation`: 8 symmetries + pad jitter radius 1.
- Difficulty: g0 0.9; ★★ 430 s, ★★★ 305 s. ★PROTO.
- Proposed changes: Stars ×0.85 (about 365 / 260 s): the funny levels should be on the short side, and tier 4 should not be longer than tier 5. Otherwise none: it is the most original level of the biome.

**Progression role** (layer 1): The comic beat before the rest pair. Bounce pads return in h1.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_05: Coral Tower  (tier 5, race)

**Play** (layer 1)
- Goal: `height` 10 with coverage 0.6. Trim (no fail).
- How it plays: A height race toward the sunlight while a -x tide pushes every falling piece one cell every 6 s ± 2 s. Duo pieces (weight 0.5) fill the single-cell gaps that the drift leaves. The player builds the tower up from the downstream wall so the current pushes pieces home.
- Teaches / tests: Build race + current.
- Rules and minigame blocks: `build_race`; `gust` {-x, 6000 ± 2000, warn 1000}. No module.
- Board: 8x8, h_play 12, empty. 8 shapes + Duo.
- Difficulty: g0 0.95; ★★ 265 s, ★★★ 185 s (★★★ no trimmed cube). The first rest.
- Proposed changes: (1) **Rescale the stars**: they are the 5x5 values (about 10 layers × 64 cells now). Set `goal.h_target` 10 → 8 with stars about 520 / 365 s, or mask a round 6x6 reef (stars about 420 / 295 s); align with the `meadow_05` and `ice_05` rescales. (2) **Break the "05 = height race" echo** (the fourth in a row): make it the **Reef Climb** slot from mockup-alignment, with `rising_silt` {silt_every_locks 12, silt_gaps 3, silt_warn_locks 1} below as a gentle `rising_hazard`, and a `vertical_gauge` "Height to Sunlight" HUD (progress, green on top). The verb stays familiar (build up), but the floor chasing you makes it a climb, not a stack. If silt is kept for 08 only, use the Duo-heavy current race as is, but with a coral spire mask (a 6x6 core with a 2-cell overhang shelf) so the tower has a shape to fill.

**Progression role** (layer 1): The rest/build beat between the jellies and the necklace puzzle. As Reef Climb, it previews the silt of 08 safely (trim, no fail).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_06: Pearl Necklace  (tier 6, completing)

**Play** (layer 1)
- Goal: `shape`: a 36-cell necklace (a 6x6 ring with a 2x2 hole on layer 0, plus 4 pearl cells on layer 1 at the corners), with a kit of 9 pieces (Tripod ×4, S ×4, O ×1). Trim; out of pieces = fail.
- How it plays: A no-clock packing puzzle. The player picks any kit piece in any order, rotates it in 3D and drops it, with unlimited undo and one-tap reset. The insight is that each Tripod's raised arm makes one corner pearl, so the four Tripods must sit at the four corners, and the S pieces then thread the sides.
- Teaches / tests: Kit box and undo (the puzzle form of the bonuses, on the main path).
- Rules and minigame blocks: `fill_shape`; `undo_reset`. Knob `spawn.arrival: kit_box`. No module.
- Board: 8x8, h_play 6, target at x 1–6, z 1–6. Kit fixed.
- Difficulty: g0 0.6; ★★ 210 s, ★★★ 135 s. The deepest rest in the biome.
- Proposed changes: As for `ice_bonus`: add `pieces.kit_pool` with 2–3 validated kits (e.g. today's kit; {Tripod ×4, L ×2, S ×2, O}; {Tripod ×4, S ×2, I ×2, O}) and a `variation` block (rot90/rot180/rot270, which keeps the ring symmetric), so a retry is not a memorised solution.

**Progression role** (layer 1): The calm thinking beat before the pressure half. It is the only main-path kit puzzle in the first four biomes, which makes it a good contrast.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_07: Ink Cloud  (tier 7, twist)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: A shy octopus's ink: locked cubes stay visible for 3.5 s, then fade over 1 s to 10% alpha, and a clear reveals the stack for 0.7 s. Four kelp stalks (masked cells at (1,2), (5,2), (1,4), (5,4)) are permanent holes in every layer, so the player has to remember both the stack and where the kelp is.
- Teaches / tests: Memory around fixed obstacles.
- Rules and minigame blocks: `fog` {visible_ms 3500, fade_ms 1000, invisible_alpha 0.1, reveal_ms 700}. No module.
- Board: 8x8, h_play 10, mask with 4 kelp holes (60 active cells). Random bag.
- Difficulty: g0 1.0; ★★ 400 s, ★★★ 280 s.
- Proposed changes: **Replace with the biome's minigame block, Submarine Salvage** (mockup #18), built from the existing `dig_rescue` goal (as `cave` uses it). JSON sketch: `goal: {"type": "dig_rescue", "critters_needed": 3}` with the critters skinned as treasure crates; `starting_contents` layers 0–3 full of sand with 2 gaps per layer (`variation` jitter) and 3 crates buried in layers 0–1; keep the kelp mask as obstacles in the sand; drop `fog` (ink already appears in h3, and fog is the 07 echo in Meadow and Ice). Moment to moment: clear down through the sand layer by layer, aiming clears at the columns above the crates, and each freed crate floats up on a bubble. Type → `completing`; stars about 300 / 210 s. When `dig_down` and A1 `pressure` land, add the pressure gauge (danger, red on top) as the clock. This gives Underwater a mockup minigame on the critical path and a new goal.

**Progression role** (layer 1): The step from the rest pair into the pressure half. As Salvage, it is also the first "dig down" level of the campaign, before Cave makes digging its main verb (mockup-alignment: Cave 03 Digging Frenzy), so it teaches a verb a later biome builds on.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_08: Sunken Ship  (tier 8, defender)

**Play** (layer 1)
- Goal: `survive` 150 s; ramp +0.1 per minute. Stars by layers: ★★ 1, ★★★ 2.
- How it plays: Every 10 locks a layer of silt rises from below with 3 random gaps (1 lock of warning), lifting the whole stack one cell toward the danger line. The player has to keep clearing to stay ahead, and can turn a silt layer into a free clear by filling its 3 gaps, so they watch the warning and leave the gap columns open.
- Teaches / tests: Rising floor: race the silt and use its gaps.
- Rules and minigame blocks: `rising_silt` {silt_every_locks 10, silt_gaps 3, silt_warn_locks 1}. No module.
- Board: 8x8, h_play 8, empty. Random bag.
- Difficulty: g0 1.05 (+0.1 per minute); ★★ 1 layer, ★★★ 2 layers. A short spike.
- Proposed changes: On 8x8, a silt layer is 61 cubes, and 10 locks (about 40 cubes) cannot keep up, so the stack is lifted faster than it can be cleared. Check this in a playtest: if the level is unwinnable at 0.5 percentile skill, set `silt_every_locks` 10 → 14 and `silt_gaps` 3 → 5. Count silt-gap fills as layers for ★★★, since they are the intended skill.

**Progression role** (layer 1): The biome's survive level and short spike between 07 and 09. Silt returns as the boss's floor pressure if the 10 proposal uses it.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_09: Whirlpool  (tier 9, twist)

**Play** (layer 1)
- Goal: `clear_n` 3.
- How it plays: Every 5 locks (1 lock of warning) the whirlpool turns the whole stack 90° clockwise on the shelf, so the gap you were building toward is suddenly on a different side. A +x tide current pushes falling pieces every 8 s ± 2 s. Because the current is world-anchored and the stack turns, the side the current helps changes every 5 locks, so the player re-plans after each turn.
- Teaches / tests: The combine: whirlpool + current, where one rotates and the other does not.
- Rules and minigame blocks: `turntable` {turn_warn_locks 1, turn_locks 5, clockwise}; `gust` {+x, 8000 ± 2000, warn 1000}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 1.1; ★★ 435 s, ★★★ 310 s. ★PROTO.
- Proposed changes: Add the jellyfish from 04 (`bounce_pad`, 2 pads, with `variation`) so 09 combines *three* Underwater ideas (current, jellies, whirlpool) rather than one new idea and Meadow's gust; the pads turn with the stack, which is a satisfying read. Stars unchanged.

**Progression role** (layer 1): The last step before the boss, and the rotation that 10's undertow builds on.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_10: Crab's Pile  (tier 10, defender)

**Play** (layer 1)
- Goal: `clear_n` 3 (each clear topples part of the crab's treasure pile).
- How it plays: The undertow conveyor slides the whole stack +x one cell every 3 locks and wraps it around. A +z tide pushes falling pieces every 8 s. From layer 2, the crab's claw steals a cube every 20 s ± 4 s (2 s warning). The player drops pieces where the gap *will be*, while repairing claw damage between clears. Duo pieces help patch single stolen cells.
- Teaches / tests: The finale: undertow + current + claw.
- Rules and minigame blocks: `conveyor` {conveyor_every 3, conveyor_dir +x, conveyor_wrap true}; `gust` {+z, 8000 ± 2000, warn 1000}; `crab_claw` {claw_start_layers 2, claw_every_ms 20000, claw_jitter_ms 4000, claw_warn_ms 2000, claw_grab 1, counter clear}. `story.boss` admiral_crab. No module.
- Board: 8x8, h_play 12, empty. 8 shapes + Duo (0.5).
- Difficulty: g0 1.15; ★★ 435 s, ★★★ 305 s. The biome peak.
- Proposed changes: **Give the boss a target and a face, differently from Candy's climber.** Add `defend_core` {core: the 2x2 clam at (3,0,3)–(4,0,4) with the pearl, core_hp 3, core_damage 1, attack_every_ms 15000, warn_ms 2000}: the crab's big claw strikes at the clam on a telegraph, and a strike only lands if the clam's column tops are open, so the player protects the pearl by keeping it buried under at least one layer. The claw that steals cubes remains as the small claw. Remove `gust` to stay readable (conveyor + two claws + a core). The goal stays 3 clears, but each clear is shown as a hit on the crab (the bar drops by a third). Losing the clam (HP 0) fails the level. This is mockup-alignment's "Crab King" (`boss_hp` + `crab_claw`) built from existing rules; when `boss_hp` lands, move the hits to `boss_hp` {hp 3, dmg_per_clear 1}. Note that `conveyor` moves the clam with the stack, so the core must be defined as cubes, not cells (confirm with the rule owner).

**Progression role** (layer 1): The payoff of the claw introduced in 02. It opens the hard track and the next biome (Pirate Cove, if flag F1 is adopted, which would continue the sea arc).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_bonus: Treasure Chest  (tier 11, completing)

**Play** (layer 1)
- Goal: `shape`: a 4x4 × 2-layer chest plus a 2x2 lid knob on layer 2 (36 cells), in 7 pieces. Trim.
- How it plays: A packing puzzle with a 3-piece preview: two Big Cubes and four I pieces fill the chest, and the last O caps the lid. The player reads ahead and places each piece so the box fills exactly, with no spare.
- Teaches / tests: Planning a 3-layer packing from the preview.
- Rules and minigame blocks: `fill_shape`. No module.
- Board: 8x8, h_play 6, target at x 2–5, z 2–5 (+ x 3–4, z 3–4 on layer 2). **`fixed_list` [Big Cube, Big Cube, I, I, I, I, O]**.
- Difficulty: g0 0.5; ★★ 75 s, ★★★ 50 s.
- Proposed changes: **Remove `fixed_list`** (standing rule) and use `pieces.deal_pool` as in `meadow_bonus`: each entry is a multiset that packs the 32-cell chest exactly, with I pieces in pairs, **plus one O for the knob**, and the O must not be dealt before the cells below the knob can be filled (the deal order is random, but the validator rejects orders where the O comes first and would land in the chest; or let `fill_shape` trim it and allow one spare O in the budget). Example entries: {BigCube ×2, I ×4, O} (today's), {BigCube ×3, O ×3}, {BigCube ×2, O ×2, I ×2, O}. Unlike Meadow's and Candy's bonuses, there is no clock, so add one (`time_limit_ms` 90000) or keep it calm with `undo_reset`; pick one so the three bonuses do not feel identical.

**Progression role** (layer 1): Unlocks at 20 Underwater stars. The third packing bonus in four biomes; its 3-layer box is what distinguishes it.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_h1: Sinking Sand  (tier 12, funny)

**Play** (layer 1)
- Goal: `clear_n` 4 (1 warning).
- How it plays: Two jellyfish pads bounce landing pieces. A +x current pushes every 9 s. Two quicksand tiles on the floor swallow whatever sits on them one cell every 4 locks, which pulls a column down and opens a gap above it. The player uses the jellies to throw pieces over the sinking columns and refills them before the sand opens holes in a near-complete layer.
- Teaches / tests: Remix: jellies (04) + current (03) + sinking floor tiles.
- Rules and minigame blocks: `bounce_pad` {bounce_h 2, last_move}; `gust` {+x, 9000 ± 2000, strength 1, warn 1000}; `quicksand` {tiles [[2,2],[5,5]], sink_every 4}. No module.
- Board: 8x8, h_play 10, 2 pads. Per-attempt `variation`: 8 symmetries + pad jitter + `rule_tiles` (quicksand moves with the symmetry). A good model for the other levels.
- Difficulty: g0 1.05; ★★ 535 s, ★★★ 375 s.
- Proposed changes: `goal.n` 4 → 3, stars about 400 / 280 s; the sand undoes progress, so 4 clears on 8x8 is about 9 minutes. Otherwise it is a strong remix.

**Progression role** (layer 1): The first remix: the funniest of the three. It should differ in goal from h2 and h3 (see there).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_h2: Riptide Whirl  (tier 13, twist)

**Play** (layer 1)
- Goal: `clear_n` 3 (1 warning).
- How it plays: The whirlpool turns the stack 90° every 6 locks, and a magnet at column (7, 4) pulls the falling piece one cell along x toward it every 3 s (0.6 s warning). Since the magnet is fixed while the stack turns, the "pull side" of the stack changes every turn.
- Teaches / tests: Remix: whirlpool (09) + a fixed point pull.
- Rules and minigame blocks: `turntable` {turn_warn_locks 1, turn_locks 6, clockwise}; `magnet_pull` {magnet_col [7, 4], pull_interval_ms 3000, pull_warn_ms 600, pull_axis x}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 1.05; ★★ 400 s, ★★★ 285 s.
- Proposed changes: **Change the goal: a coral spire in the whirlpool.** Goal → `height` 8 with coverage 0.5 and `build_race` {topout_rule trim}; keep `turntable` and `magnet_pull`. A tower that turns while a magnet tugs at the falling piece is a balance-and-aim race, which is very different from h1 and h3. Type → `race`; stars about 330 / 230 s. This also gives the hard track three different goals.

**Progression role** (layer 1): The middle remix: the hard track's build race.

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_

---

### underwater_h3: Crab's Rematch  (tier 14, defender)

**Play** (layer 1)
- Goal: `clear_n` 4 (1 warning).
- How it plays: The claw comes back sooner (from layer 1, every 25 s ± 4 s, 2 s warning) under ink fog (visible 4 s, fade to 10%). A golden row starts at layer 1: completing it pays +200, as a score bonus, so the player has a reason to clear low layers first while the claw and the ink fight them.
- Teaches / tests: Remix: the claw (02, 10) + ink (07) + a scoring target.
- Rules and minigame blocks: `crab_claw` {claw_start_layers 1, claw_every_ms 25000, claw_jitter_ms 4000, claw_warn_ms 2000, claw_grab 1, counter clear}; `fog` {visible_ms 4000, fade_ms 1000, invisible_alpha 0.1, reveal_ms 700}; `golden_row` {start_layer 1, bonus 200, goal_counter gold}. No module.
- Board: 8x8, h_play 10, empty. Random bag.
- Difficulty: g0 1.1; ★★ 535 s, ★★★ 375 s. The hardest Underwater level.
- Proposed changes: **A rematch needs the crab on the board.** Add `climber_boss` {size [2,2,1], skin admiral_crab} and change the goal to `{"type": "bonk_boss", "bonks_needed": 4}`; keep `crab_claw` (his small claw) and `fog` (his ink); drop `golden_row` (score-only, and a third rule that competes for attention). Moment to moment: the crab scuttles to the top of the stack after each lock and steals cubes; every clear under him bonks him down. If `defend_core` is adopted for 10, h3 can instead reuse the clam core at 2 HP for a harder echo; pick one so 10 and h3 are not identical. Stars about 300 / 210 s.

**Progression role** (layer 1): The last Underwater level and the crab's final defeat, closing the sea arc before Pirate Cove (or Lava).

**In the world** (layer 2): _(layer 2: pending)_

**Story beat** (layer 2): _(layer 2: pending)_

**Art** (layer 3): _(layer 3: pending)_

**Godot review** (layer 4): _(layer 4: pending)_
