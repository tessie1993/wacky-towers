# Piece Set

> **Status**: In Design
> **Author**: Tessa + agents
> **Last Updated**: 2026-10-09
> **Last Verified**: 2026-10-09
> **Implements Pillar**: The Block Is the Constant; Readable Chaos; Variation Over Depth

## Summary

The Piece Set is the library of every piece shape in the game: 19 starter shapes in three families — Standard (the 8 tetracubes, the default set), Special (bigger 5–8 cube 3D pieces) and Helpers (1–3 cube fillers for early levels or from perks and items) — each with its own hue and face motif. Tags let the same shapes act as bombs, junk or character/biome pieces without changing their silhouettes. Each level picks which shapes it allows, and the set's mean size and longest piece feed the board's pacing and spawn-space math.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None`

## Overview

The Piece Set defines every piece shape the game can drop: which unit cubes it is made of, what it is called, what family it belongs to, its hue and face motif, and its default rotation behaviour. It does not decide *which* pieces appear or how often — that is the Spawner's job, using the subset each level allows (Level Data). The set is organised in **families**: **Standard** (all 8 tetracubes — the 5 flat Tetris shapes plus the 3 true-3D ones), **Special** (bigger 5–8 cube pieces that spread in all three directions), **Helpers** (1-, 2- and 3-cube fillers, only in low levels or when a perk or item grants them), and three tagged groups that reuse the same shape data: **Special-behaviour** pieces (bomb, heavy, sticky and the like), **Junk** pieces (dropped on a player by opponents or twists) and **Character/Biome** pieces (unique to one character, biome or minigame). Every shape gets its own hue (art bible override, see Visual/Audio); the starter library has 19 shapes. The Piece Set is what makes Pillar 1 true — every mode, twist and minigame is built from these same pieces — and its breadth feeds Pillar 4, *Variation Over Depth*. All values are starting defaults.

## Detailed Design

### Core Rules

**What a piece is**
1. A piece is a set of 1–8 unit cubes that together form **one face-connected group** (no edge- or corner-only joins, no separate parts), stored as cube offsets from a **pivot cube**.
2. Every shape has: a unique `shape_id`, a display name, a **family**, a cube count, a **bounding box** (its extent on x, y, z), a **hue**, a **face motif** (art bible §3), and a spawn orientation.
3. A shape's **longest extent** is the largest side of its bounding box. **Default cap: 4**, so the default spawn clearance stays at 4 (Board / Grid F4). A level may allow longer pieces; the board's spawn clearance then grows to match.
4. Shapes are identified up to rotation: two cube sets that are rotations of each other are the same shape. **Mirror images are different shapes** (the two screw tetracubes are separate), because in a grid game a piece cannot be flipped through a mirror.

**Families**

| Family | Cubes | Shapes (default library) | Where they appear by default |
|---|---|---|---|
| **Standard** | 4 | **Flat (5):** I (straight), O (square), T, L, S. **3D (3):** Tripod (corner of three arms), Screw-Left, Screw-Right | Every layer-clearing level |
| **Special** | 5–8 | Starter list, tuned by level design: **Chair** (5), **Big Tripod** (7: a corner cube with a 2-cube arm along each axis; extent 3), **Staircase** (6, steps in 3D), **Twist-Left** and **Twist-Right** (5, mirror pair), **Big Cube** (8: 2 × 2 × 2), **Tall Corner** (6) | Harder tiers, special levels, minigames, items |
| **Helper** | 1–3 | **Mono** (1), **Duo** (2), **Tri-Straight** (3), **Tri-Corner** (3) | Low levels (tutorial / early tiers) or when a perk, potion or item grants them; never in default sets past the early tiers |

The 3D Standard shapes are the main difficulty step from classic Tetris; levels can hold them back early and add them as a tier's "new twist".

**Tags (groups that reuse shapes)**
5. A piece instance may carry **tags** on top of its shape. The Piece Set defines the tag slots; the behaviour belongs to other systems:
   - `behaviour` — a special rule (bomb, heavy, sticky, ghost, wildcard …). Defined in the Rule-Twist Framework / Twist Library / Items.
   - `junk` — sent onto a board by an opponent or twist; usually drawn as junk material, not candy (art bible). Defined in Obstacles / Items.
   - `owner_set` — belongs to a character, biome or minigame's own set. Defined in Characters & Perks, Level Data or Tournament Minigames.
6. Tags never change a shape's cubes. A "bomb T" is still the T shape (art bible Principle 1: silhouette before surface).

**Piece sets per level**
7. A **piece set** is a list of `shape_id`s allowed in a level or mode, plus optional tags. Level Data picks it; if a level gives none, the **default set** is all 8 Standard shapes.
8. The Piece Set validates every level set at load: for every active region, each shape's longest extent must be ≤ the region's smaller footprint side and ≤ the playable height (H_play); the set's L_max sets the board's spawn clearance.

**Rotation**
9. Pieces rotate in 90° steps around the x, y and z axes, around the pivot cube. Each shape lists its **distinct orientations** (out of 24 possible): e.g. O has 3, I has 3, Big Cube has 1, the 3D shapes have 8, 12 or 24 (see Formulas F4). Movement & Rotation uses this list; wall kicks are its job.
10. Each shape has a fixed **spawn orientation**: its smallest extent points up (`+y`), so it shows its widest, flattest side to the default camera. Ties are broken by the orientation listed first in the library.

### States and Transitions

Shapes are static data. A piece **instance** goes: **Queued** (in the Spawner's queue) → **Falling** (active, owned by Movement and Drop/Lock) → **Locked** (its cubes are written to the board as Block contents and the instance ends). Its shape, hue, motif and tags never change between states; a twist that changes a piece replaces it with a new instance.

### Interactions with Other Systems

| System | Direction | What flows |
|---|---|---|
| Level Data & Definition | → Piece Set | The level's allowed shapes and tags |
| Piece Spawner & Queue | Piece Set → | Shape definitions for the allowed set; the Spawner owns weights and randomness |
| Movement & Rotation | Piece Set → | Cube offsets, pivot, orientation list |
| Board / Grid | Piece Set → | `c` (mean cubes) and `L_max` (longest extent) for board formulas and spawn clearance; Block contents carry `shape_id` |
| Rule-Twist Framework, Items, Obstacles | ↔ | Read and set tags; may swap a falling piece for another shape |
| Characters & Perks, Shop | → Piece Set | Perks/potions that add Helper or character shapes to a player's set |
| HUD, Game Feel & VFX | Piece Set → | Hue, motif and shape for the next-piece preview and effects |

## Formulas

All values are starting defaults. Orientation counts use proper rotations only; mirror images are separate shapes.

### F1. Mean cubes per piece (c)

The mean_cubes formula is defined as:

`c = Σ(w_i × n_i) / Σ(w_i)` over shapes i in the level's piece set S

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_i | int | 1–8 | data file | Cube count of shape i |
| w_i | float | > 0 | data file (Spawner) | Spawn weight of shape i; owned by the Spawner; default uniform (w_i = 1) |
| c | float | 1–8 | calculated | Mean cubes per piece; feeds Board / Grid F2 |

**Output Range:** 1.0–8.0, always within [smallest, largest] cube count in S. Empty S or Σw = 0 is a load error.
**Example:** the 8 Standard shapes at w = 1 → c = 32 / 8 = 4.0.

### F2. Longest extent of a set (L_max)

The longest_extent formula is defined as:

`L_max = max over i in S of max(ex_i, ey_i, ez_i)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| ex_i, ey_i, ez_i | int | 1–8 | calculated | Bounding-box sides of shape i (from its cube coordinates) |
| L_max | int | 1–8 | calculated | Longest extent in the set; feeds Board / Grid F4 (spawn clearance C = L_max) |

**Output Range:** 1–8; default cap 4. A set above the cap raises the board's spawn clearance and height, and the loader warns.
**Example:** {I, O, T} → L_max = 4 (from I).

### F3. Fit check

The fits formula is defined as:

`fits = OR over v in {x, y, z} of [ e_v ≤ H_play AND min(e_a, e_b) ≤ w AND max(e_a, e_b) ≤ d ]`, where {a, b} are the other two axes and w ≤ d are the region's footprint sides.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| e_x, e_y, e_z | int | 1–8 | calculated | Bounding-box extents of the shape |
| w, d | int | 4–8 | data file | Smaller and larger footprint side of the active region |
| H_play | int | 6–12 | data file | Playable layers |
| fits | bool | true / false | calculated | Placeable in at least one orientation |

**Output Range:** boolean. Any axis assignment is reachable by a rotation, so only extents matter. Level validation (Core Rule 8) uses the stricter rotation-free check `L_i ≤ min(w, d)`, so a shape fits in every orientation.
**Example:** Tall Corner (2 × 2 × 4) in a 4 × 4 region with H_play 12 → fits; rotation-free check 4 ≤ 4 → passes.

### F4. Distinct orientations

The orientations formula is defined as:

`orient_i = 24 / |G_i|`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| G_i | group | order 1, 2, 3, 8 or 24 | calculated | Rotations that map shape i onto itself |
| orient_i | int | 1–24 | calculated | Distinct orientations Movement & Rotation cycles through |

**Output Range:** 1–24. **Example:** T has |G| = 2 → 12 orientations.

### Starter library (pivot at 0,0,0)

| Shape | Family | Cubes | Cube coordinates | Bounding box | Orientations |
|---|---|---|---|---|---|
| I | Standard (flat) | 4 | (0..3,0,0) | 4×1×1 | 3 |
| O | Standard (flat) | 4 | (0,0,0)(1,0,0)(0,1,0)(1,1,0) | 2×2×1 | 3 |
| T | Standard (flat) | 4 | (0,0,0)(1,0,0)(2,0,0)(1,1,0) | 3×2×1 | 12 |
| L | Standard (flat) | 4 | (0,0,0)(1,0,0)(2,0,0)(2,1,0) | 3×2×1 | 24 |
| S | Standard (flat) | 4 | (0,0,0)(1,0,0)(1,1,0)(2,1,0) | 3×2×1 | 12 |
| Tripod | Standard (3D) | 4 | (0,0,0)(1,0,0)(0,1,0)(0,0,1) | 2×2×2 | 8 |
| Screw-Left | Standard (3D) | 4 | (0,0,0)(1,0,0)(1,1,0)(1,1,1) | 2×2×2 | 12 |
| Screw-Right | Standard (3D) | 4 | (0,0,0)(1,0,0)(1,1,0)(1,1,−1) | 2×2×2 | 12 |
| Chair | Special | 5 | Tripod with a 2-long z-arm: (0,0,0)(1,0,0)(0,1,0)(0,0,1)(0,0,2) | 2×2×3 | 24 |
| Twist-Left | Special | 5 | Path x, y, z, x: (0,0,0)(1,0,0)(1,1,0)(1,1,1)(2,1,1) | 3×2×2 | 12 |
| Twist-Right | Special | 5 | Mirror of Twist-Left: (0,0,0)(1,0,0)(1,1,0)(1,1,−1)(2,1,−1) | 3×2×2 | 12 |
| Staircase | Special | 6 | 3D steps: (0,0,0)(1,0,0)(1,1,0)(1,1,1)(2,1,1)(2,2,1) | 3×3×2 | 12 |
| Tall Corner | Special | 6 | Tripod with a 3-long z-arm: (0,0,0)(1,0,0)(0,1,0)(0,0,1)(0,0,2)(0,0,3) | 2×2×4 | 24 |
| Big Tripod | Special | 7 | Corner with three 2-long arms: (0,0,0)(1,0,0)(2,0,0)(0,1,0)(0,2,0)(0,0,1)(0,0,2) | 3×3×3 | 8 |
| Big Cube | Special | 8 | 2 × 2 × 2 block: (0,0,0)(1,0,0)(0,1,0)(1,1,0)(0,0,1)(1,0,1)(0,1,1)(1,1,1) | 2×2×2 | 1 |
| Mono | Helper | 1 | (0,0,0) | 1×1×1 | 1 |
| Duo | Helper | 2 | (0,0,0)(1,0,0) | 2×1×1 | 3 |
| Tri-Straight | Helper | 3 | (0..2,0,0) | 3×1×1 | 3 |
| Tri-Corner | Helper | 3 | (0,0,0)(1,0,0)(0,1,0) | 2×2×1 | 12 |

In 3D, L/J and S/Z are the same shape (one rotates into the other), so the 5 flat shapes cover all of classic Tetris. Tripod, Chair and Tall Corner are one family (a corner with arms 1-1-k for k = 1, 2, 3). No starter shape exceeds the extent cap of 4; I and Tall Corner sit exactly on it. Every starter shape fits a 4 × 4 footprint.

### Set values (uniform weights)

| Set | Shapes | c | L_max | P_eff on 8 × 8 (η = 0.75) |
|---|---|---|---|---|
| Default: 8 Standard | 8 | 4.00 | 4 | ≈ 21.3 |
| Standard + all 7 Specials | 15 | 74 / 15 ≈ 4.93 | 4 | ≈ 17.3 |
| Specials only | 7 | 42 / 7 = 6.00 | 4 | ≈ 14.2 |

## Edge Cases

- **If a level's piece set is empty**: the level fails validation at load ("piece set empty"); it never falls back silently. A level with no `piece_set` field at all uses the default set (all 8 Standard shapes).
- **If a level's set contains a shape that does not fit the board** (longest extent larger than the smallest active footprint region, or taller than the playable height): validation fails and names the shape and the region.
- **If a level's set has L_max greater than 4**: allowed; the board's spawn clearance grows to L_max (Board / Grid F4) and the board-height readability check (Board F5) must still pass, or validation fails.
- **If a perk, potion or item adds Helper shapes during a level**: they join that player's set from the next queue refill; pieces already queued are not changed.
- **If a twist swaps the falling piece for a different shape that cannot fit where it is**: the new piece is placed at the nearest free position upward (Movement & Rotation); if none exists, it counts as spawn blocked (Board / Grid).
- **If two tags conflict on one instance** (e.g. `junk` and `behaviour: bomb`): the Rule-Twist Framework's priority order decides which applies; the shape is unaffected.
- **If a shape is symmetric** (e.g. Big Cube, Mono): rotation inputs that produce the same orientation still count as a valid rotation (for feedback), but the piece does not visibly change.
- **If a level's set has only one shape**: allowed (e.g. a "straights only" challenge); the Spawner handles repetition.
- **If two shapes in one level share a hue** (hues within 15° of each other): validation warns, not fails; silhouette and face motif must still separate them.
- **If a level uses mirror pairs** (Screw-Left and Screw-Right): both are separate shapes with separate hues and motifs; neither can be rotated into the other.

## Dependencies

**Upstream (this system depends on):** none — Piece Set is a Foundation system. Level Data selects subsets of it (soft: without level data the default set is used).

**Downstream (depend on this system):**

| System | Hard / soft | Interface |
|---|---|---|
| Board / Grid | Hard | `c` and `L_max` feed board formulas F2 and F4; Block contents store `shape_id` |
| Piece Spawner & Queue | Hard | Shape definitions for the allowed set |
| Movement & Rotation | Hard | Cube offsets, pivot, distinct orientations |
| Level Data & Definition | Hard | Selects piece sets and tags by `shape_id` |
| Rule-Twist Framework, Twist Library, Items, Obstacles | Hard | Tags (`behaviour`, `junk`); shape swaps |
| Physics Mode | Hard | Cube offsets used to build physics bodies |
| Characters & Perks, Shop | Soft | Add Helper or character shapes to a player's set |
| Tournament Minigames | Soft | Own piece sets |
| HUD, Game Feel & VFX | Soft | Hue, motif and shape for the preview and effects |

Board / Grid already lists Piece Set as the source of `c` and `L_max`. The other systems have no GDDs yet; each must list Piece Set as a dependency when written.

## Visual/Audio Requirements

> **Art bible §4.7 override (2026-10-09).** The art bible's §4.2 starts with six piece hues, and says to prefer a face motif over a seventh hue. The Piece Set instead gives each of its 19 shapes its own hue (user decision), so the palette expands from 6 to 19. The six existing hues are kept. Thirteen new hues sit at least about 25° from buff cyan (186°) and debuff magenta (322°), and stay away from hazard orange and danger red. Pieces stay pastel (about 45-65% saturation), and Helpers go slightly lower (about 38%). Several pairs fall within about 15° and are not distinguishable for colourblind players, so §4.6 relies on silhouette and face motif as the primary identifiers, with hue as confirmation only. Default: at most 8 shapes active per level (10 in minigames), with no more than 3 from one fixed 60° hue band (0–59°, 60–119°, … 300–359°). Junk uses a neutral matte material and behaviour tags use a parchment sticker, so neither adds a hue. All hex values are starting guesses to tune in-engine with a colour-vision simulator.

| Shape | Family | Hue (°) | Starting hex | Face motif |
|---|---|---|---|---|
| I | Standard | Sky 216 (existing) | `#6EA4F0` | bar |
| O | Standard | Lemon 49 (existing) | `#F5DD6A` | ring |
| T | Standard | Lime 88 (existing) | `#9FD65B` | cross |
| L | Standard | Peach 21 (existing) | `#FFB48C` | half-moon |
| S | Standard | Mint 157 (existing) | `#5DCB9E` | wave |
| Tripod | Standard | Lavender 258 (existing) | `#A78BEB` | triangle |
| Screw-Left | Standard | Fern 125 | `#73F07D` | spiral, counter-clockwise |
| Screw-Right | Standard | Orchid 272 | `#B673F0` | spiral, clockwise |
| Chair | Special | Apricot 35 | `#F0BC73` | diamond |
| Twist-Left | Special | Violet 249 | `#8673F0` | hourglass, tilted left |
| Twist-Right | Special | Plum 288 | `#D773F0` | hourglass, tilted right |
| Staircase | Special | Cornflower 227 | `#738EF0` | step |
| Tall Corner | Special | Jade 137 | `#73F096` | corner bracket |
| Big Tripod | Special | Periwinkle 238 | `#7377F0` | triple chevron |
| Big Cube | Special | Butter 62 | `#ECF073` | square in square |
| Mono | Helper | Pistachio 75 | `#D6ED93` | 1 pip |
| Duo | Helper | Pear 101 | `#AFED93` | 2 pips |
| Tri-Straight | Helper | Sage 113 | `#9EED93` | 3 pips in a row |
| Tri-Corner | Helper | Seafoam 148 | `#93EDBD` | 3 pips in an L |

**Families read apart beyond hue (defaults):**
- **Standard:** the base look — full gloss, bare embossed motif.
- **Special:** motif inside a ring-framed inset, slightly stronger gloss, about 60% saturation; their 5–8 cube size also helps.
- **Helper:** plainer — about 50% gloss, thinner outline, no seam groove on Mono; dice-pip motifs show the cube count. Their hues sit together in a chalky yellow-green band so the family reads as one group.
- **Junk tag:** matte grey-brown "junk material", no gloss, no motif, shape outline kept.
- **Behaviour tag:** keeps the piece's hue, adds a parchment sticker with an ink icon on one top face. Buff and debuff shells still use their accent colours.

**Known collisions** (normal vision, within about 15°): Lavender/Violet, Violet/Periwinkle, Periwinkle/Cornflower, Cornflower/Sky, Fern/Jade, Jade/Seafoam, Seafoam/Mint, Lemon/Butter, Pistachio/Lime, Duo/Sage, Sage/Screw-Left, Lavender/Orchid, Orchid/Plum. Protan and deutan players see the yellow-green range as about 3 hues; tritan players lose the blue-violet chain. Level validation warns when a set breaks the 8-shape / 3-per-band defaults.

No audio is owned by the Piece Set.

## Game Feel

Every piece should read as one chunky toy at a glance, even at about 28 px per cube on the default 8 × 8 board: silhouette first, motif second, hue third (art bible §3). Spawn orientations show the flattest, most recognisable side to the default camera. Special pieces should feel heavy and exciting (bigger, glossier); Helpers should feel like small, friendly fillers.

## UI Requirements

The Piece Set supplies shape, hue and motif for the HUD's next-piece preview, which shows the real 3D piece in its spawn orientation from the gameplay camera angle (art bible §7). No other UI.

## Cross-References

| Referenced | What this GDD uses from it |
|---|---|
| `design/gdd/board-grid.md` F2, F4, Core Rules | `c` and `L_max` feed board formulas; Block contents store `shape_id`; fit checks against footprint and playable height |
| `design/art/art-bible.md` §3, §4.2, §4.6, §4.7 | Silhouette/motif/colour order, original six hues, colourblind backups, the override process used above |
| `design/gdd/game-concept.md` | Pillars 1 and 4; difficulty tiers adding mechanics |
| `design/gdd/systems-index.md` | Downstream systems listed in Dependencies |

## Acceptance Criteria

**[U]** = automated unit test, **[M]** = manual or device check. Library values from Formulas.

**Core rules**
1. [U] **GIVEN** each library shape, **WHEN** it loads, **THEN** its cubes form one face-connected group; **GIVEN** a test shape joined only at an edge or corner, or in two parts, **WHEN** it loads, **THEN** it is rejected.
2. [U] **GIVEN** any shape, **WHEN** each of its 24 rotations is canonicalised, **THEN** all give the same `shape_id`; Screw-Left never matches Screw-Right, and Twist-Left never matches Twist-Right.
3. [U] **GIVEN** the default set, **WHEN** validated, **THEN** L_max = 4 and the board's spawn clearance = 4.
4. [U] **GIVEN** the library, **WHEN** shapes are counted by family, **THEN** there are 8 Standard (4 cubes each), 7 Special (5–8 cubes), 4 Helper (1–3 cubes), 19 total.
5. [U] **GIVEN** a T tagged `behaviour: bomb`, `junk` or `owner_set`, **WHEN** compared with an untagged T, **THEN** `shape_id` and cube offsets are identical.
6. [U] **GIVEN** a level with no `piece_set` field, **WHEN** it loads, **THEN** its set is exactly the 8 Standard shapes.
7. [U] **GIVEN** each shape, **WHEN** its listed orientations are compared, **THEN** they are pairwise distinct and their count equals F4.
8. [U] **GIVEN** each shape, **WHEN** it spawns, **THEN** its spawn orientation is in its orientation list and its smallest extent points up (+y). [M] Lead sign-off that the next-piece preview reads clearly at about 28 px per cube.

**Formulas**
9. [U] F1: the default set gives c = 4.0; Standard + all 7 Specials gives c = 74/15 ≈ 4.933 (±0.001); weights summing to 0 give a load error.
10. [U] F2: {I, O, T} → L_max = 4; {O, Tripod} → L_max = 2.
11. [U] F3: Tall Corner in a 4 × 4 region with H_play 12 → fits = true and passes the rotation-free check.
12. [U] F4: T → 12 orientations, Tripod → 8, Big Cube → 1.

**Edge cases**
13. [U] **GIVEN** `piece_set: []`, **WHEN** the level loads, **THEN** validation fails with "piece set empty" and nothing falls back.
14. [U] **GIVEN** a shape with extent 5 in a 4 × 4 region, **WHEN** validated, **THEN** validation fails naming the shape and region.
15. [U] **GIVEN** a set with L_max = 5, **WHEN** validated, **THEN** it loads with a warning and spawn clearance = 5; if Board / Grid F5 fails, validation fails.
16. [U] *(provisional until the Spawner GDD)* **GIVEN** a perk adds Helpers mid-level, **WHEN** it fires, **THEN** already-queued pieces are unchanged and Helpers are eligible from the next refill.
17. [U] **GIVEN** the set {I}, **WHEN** validated, **THEN** it passes with c = 4, L_max = 4.
18. [U] **GIVEN** two active shapes with hues within 15°, **WHEN** validated, **THEN** it warns and still loads.
19. [U] **GIVEN** 9 active shapes (11 in a minigame), or 4 shapes in one fixed 60° hue band, **WHEN** validated, **THEN** it warns and still loads.
20. [U] **Data integrity:** for every library entry, the bounding box computed from its coordinates, its cube count and its computed orientation count match the stated values.
21. [M] **GIVEN** the default 8-shape set, **WHEN** viewed in a colour-vision simulator (protan, deutan, tritan) at 28 px per cube, **THEN** 3 of 3 reviewers tell 100% of shape pairs apart by silhouette plus motif.

## Open Questions

- **Special library size**: the starter list has 7 shapes. How many more, and which, is a level-design and playtest call.
- **Twist handedness**: both Twist-Left and Twist-Right are in the library for consistency with the screws; drop one if playtests show the pair is confusing.
- **Helper availability**: which early tiers include Helpers by default, and which perks, potions or items grant them (Campaign Structure, Characters & Perks, Items).
- **Active-shape cap**: is 8 shapes per level the right default once all 19 shapes and colourblind testing are in? Validate with a colour-vision simulator.
- **3D shapes on the default 8 × 8 board**: is rotating Tripod/Screw/Twist readable at ~28 px? Prototype with touch controls.
- **Character/biome pieces**: their shapes are defined in their own GDDs but must be added to this library's data and follow its rules (face-connected, extent cap, own hue or a documented shared hue).

