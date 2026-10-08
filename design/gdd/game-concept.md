# Game Concept: Wacky Towers

*Created: 2026-10-08*
*Status: Draft*

---

## Elevator Pitch

> It's a 3D Tetris party game where you rotate and drop blocks into a grid to clear layers, across a 100-level campaign, an arcade mode and Mario Kart-style multiplayer tournaments, where every biome, level and minigame bends the rules (wind, gravity, hidden blocks, drifting pieces, living objects) but the blocks are always there.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Puzzle / party game (3D falling-block puzzle, rule-variation, versus) |
| **Platform** | Mobile (iOS / Android) |
| **Target Audience** | Competitors and Achievers first; Socializers and Explorers second (see Target Player Profile) |
| **Player Count** | Single-player (campaign, arcade) + local multiplayer (online later) |
| **Session Length** | 3-10 min per level or round; 30-60 min per tournament or biome run |
| **Monetization** | None decided yet. In-game "points" are earned only (levels, wins), not purchased |
| **Estimated Scope** | Large (18-30 months, solo; no deadline) |
| **Comparable Titles** | Tetris Effect, Puyo Puyo Tetris, Tricky Towers, Mario Kart / Mario Party (structure) |

---

## Core Fantasy

"I mastered the basics, and now I adapt on the fly." The player starts with something they already know (falling blocks, full layers vanish) and keeps meeting a new twist on it: a gale, a gravity flip, pieces you can't see, a board that has opinions about your colors. In multiplayer it becomes "I'm losing, then one clutch item or perk flips the whole round."

The promise is variety without losing the satisfaction of the one thing everybody already loves: placing a block perfectly.

---

## Unique Hook

Like Tetris, AND ALSO every level, biome and tournament round is a different rule-twist on the same blocks, from classic layer-clearing to build-up races, gravity physics, shape-filling and freeform minigames, wrapped in Mario Kart-style items, buffs and debuffs.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** | 4 | Chunky toy-like pieces, satisfying lock-in and layer-clear juice, per-biome audio |
| **Fantasy** | N/A | Light: biomes are themed dioramas, no role-play |
| **Narrative** | N/A | No story campaign (anti-pillar) |
| **Challenge** | 1 | Per-level twists, 10 difficulty tiers, 3-star time targets |
| **Fellowship** | 2 | Party tournaments, head-to-head rounds, items, character perks |
| **Discovery** | 3 | Each biome and level reveals a new mechanic; learning its counterplay |
| **Expression** | 5 | Character choice, perk loadouts, shop choices |
| **Submission** | 6 | Calm early levels and arcade can be played in flow |

### Key Dynamics (Emergent player behaviors)

- Players learn each twist's counterplay and share tips ("in the Windy biome, place heavy pieces upwind").
- Players plan around a perk or potion loadout before a hard level.
- In tournaments, players choose between building their own board and sabotaging rivals.
- Trailing players take risks because the item system lets them swing a round.
- Players replay levels for 3 stars (time-based) to earn points.

### Core Mechanics (Systems we build)

1. **Block placement and rotation in a 3D grid** - move, rotate on three axes, drop; a fixed angled camera with a rotate-view button keeps the grid readable.
2. **Layer clearing** - complete layers vanish; clearing is common but not required in every mode.
3. **Rule-twist system** - modular modifiers that change how blocks behave (wind, gravity, hidden blocks, drifting/moving pieces, spawned objects, color-loving objects, build-up races, shape-filling).
4. **Items, buffs and debuffs** - Mario Kart-style pickups and attacks, used in versus play and as board effects in the campaign.
5. **Meta economy** - points from 3-star clears and multiplayer wins buy perks and one-use potions.
6. **Characters with perks** (multiplayer) and **tournament minigames** that stray further from classic Tetris.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** | Where and how to place each piece; item timing; perk, potion and character choices | Core |
| **Competence** | Learning each twist, climbing difficulty tiers, earning 3 stars on time | Core |
| **Relatedness** | Head-to-head tournaments, trash talk, couch play, comeback moments | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** - 3-star time targets, 10x10 campaign completion, shop unlocks.
- [x] **Explorers** - discovering each biome's twist and the interactions between modifiers.
- [x] **Socializers** - party tournaments of 3/5/7/13 rounds.
- [x] **Killers/Competitors** - head-to-head rounds, sabotage items, tournament wins.

### Flow State Design

- **Onboarding curve**: Biome 1 plays close to classic Tetris in 3D; the first levels teach rotation, camera and layer clears before any twist.
- **Difficulty scaling**: 10 biomes introduce new twists; 10 difficulty tiers re-run them with added mechanics, not only speed.
- **Feedback clarity**: Layer clear effects, star time targets, and a clear effect indicator (one accent color per effect type) keep status legible.
- **Recovery from failure**: A failed level restarts in seconds; failure is educational (the twist is the lesson).

---

## Core Loop

### Moment-to-Moment (30 seconds)
Take the falling piece, rotate it in three axes, choose a spot, drop it, and watch layers complete and clear. Snappy and grid-locked by default; physics modes override it (hybrid per mode).

### Short-Term (5-15 minutes)
One level or round. The player reaches a mode goal (clear N layers, build to height H, survive, fill a target shape, outscore an opponent) while the level's twist pushes back. Seeing the next twist drives "one more level."

### Session-Level (30-120 minutes)
- **Campaign**: a biome run of 10 levels, ending on a natural biome-complete moment and unlocks.
- **Arcade**: a score chase with short sessions.
- **Multiplayer**: a full tournament of 3, 5, 7 or 13 rounds of random modes, ending in a winner.

### Long-Term Progression
- **Campaign**: 10 biomes x 10 difficulty tiers (100 levels). Higher tiers add mechanics, not just speed.
- **Economy**: points from 3-star clears (time-based) and multiplayer wins buy perks (persistent edges) and potions (one use) from the shop.
- **Multiplayer**: unlock and master characters, each with their own perks.

### Retention Hooks
- **Curiosity**: the next biome's twist; harder tiers of familiar biomes with extra mechanics.
- **Investment**: shop unlocks, 3-star completion, character mastery.
- **Social**: tournaments with friends; rematches.
- **Mastery**: faster 3-star times, difficulty tiers, arcade scores.

---

## Game Pillars

### Pillar 1: The Block Is the Constant
Blocks are always there. Early levels play close to classic Tetris, later ones stray further (build-up races, shape-filling, physics towers, minigames), but everything is built from the same blocks. Falling and clearing are prevalent, not exclusive.

*Design test*: If a mode has no blocks, cut it. If it has no falling or clearing, it must still be built from the same blocks and be recognizably this game.

### Pillar 2: Readable Chaos
The 3D grid must stay understandable at a glance, even with buffs, debuffs, objects and wind stacked on top, especially on a phone screen.

*Design test*: When a new effect collides with clarity, clarity wins. Cut or redesign the effect.

### Pillar 3: Comeback Energy
In multiplayer, the trailing player should always be able to threaten the leader.

*Design test*: Between an item that locks in a lead and one that lets last place swing the round, choose the swing.

### Pillar 4: Variation Over Depth
Breadth of surprising, distinct rule-twists beats polishing one deep system.

*Design test*: Choosing between a 12th distinct twist and a deeper 3rd one, pick the twist that feels most different, as long as it respects Pillars 1 and 2.

### Anti-Pillars (What This Game Is NOT)

- **NOT an esports-grade competitive ruleset**: strict competitive balance would compromise Comeback Energy.
- **NOT a crafting / free-building / economy game**: the shop exists to support play, not become a second game; non-block building dilutes The Block Is the Constant.
- **NOT a story-driven game**: biomes carry identity through mechanics and visuals, not dialogue.
- **NOT photoreal**: a stylized, readable look serves Readable Chaos and mobile performance.

---

## Visual Identity Anchor

**Direction: "Toy-Box Diorama"**

- **Visual rule**: Every biome is a bright miniature toy-set, and every piece looks like a chunky toy that wants to move.
- **Supporting principles**:
  1. *Silhouette first* - pieces are identifiable by shape alone, even on a small phone screen. *Test: if two pieces look alike in silhouette, change the shape language.*
  2. *One accent color per effect type* - buffs, debuffs and hazards are never ambiguous. *Test: if an effect shares an accent with another, recolor one.*
  3. *Biomes change palette and props, never piece shape language.* *Test: a new biome can reskin the backdrop, but pieces must stay recognizable.*
- **Color philosophy**: saturated pieces on softer, lower-contrast biome backdrops, so the playfield always reads first.

This section seeds the art bible (`/art-bible`).

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Tetris Effect | Satisfying clears, audiovisual flow | 3D grid, rule-twisting levels, versus items | Validates that block-stacking sustains a premium, long-session game |
| Tricky Towers | Physics modes, build-up races, sabotage | Grid-based classic modes beside the physics modes; 100-level campaign | Validates a block-placement party game with magic/sabotage |
| Puyo Puyo Tetris | Head-to-head modes, multi-mode variety | 3D, tournament structure, item economy | Validates mixed-mode competitive puzzle |
| Mario Kart / Mario Party | Items, buffs/debuffs, tournament rounds, minigames | Applied to a block puzzle | Validates comeback mechanics and random-mode party structure |

**Non-game inspirations**: toy-box and diorama miniatures, Lego-style chunky pieces, kids' building-block play.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 10-40 |
| **Gaming experience** | Casual to mid-core |
| **Time availability** | Short mobile sessions; longer party sessions with friends |
| **Platform preference** | Mobile (phone, tablet) |
| **Current games they play** | Tetris, Tricky Towers, Mario Kart, Puyo Puyo Tetris |
| **What they're looking for** | A fresh, varied take on a puzzle they already love, with party play |
| **What would turn them away** | Unreadable boards, fiddly 3D controls, pay-to-win shop, mandatory story |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot (user's choice and existing experience); confirm via `/setup-engine` |
| **Key Technical Challenges** | Intuitive touch control for 3D rotation and a fixed camera; readability of stacked effects; modular rule-twist architecture; local multiplayer on mobile |
| **Art Style** | 3D stylized (toy-box diorama) |
| **Art Pipeline Complexity** | Medium-High (10 biomes of props and backdrops; shared piece set) |
| **Audio Needs** | Moderate: per-biome music, layer-clear and item feedback |
| **Networking** | Local first (same device / local wireless); online later (TBD) |
| **Content Volume** | 10 biomes x 10 difficulty tiers = 100 campaign levels, arcade, tournament minigames, items/buffs/debuffs, perks, potions, characters |
| **Procedural Systems** | Random mode selection in tournaments; random item pickups; possible procedural object spawning |

---

## Risks and Open Questions

### Design Risks
- Twists feel gimmicky rather than deepening the Tetris core.
- Visual clutter when objects, wind, items and debuffs stack (Readable Chaos).
- Item balance: sabotage can feel unfair or lock in a lead.
- Tournament minigames that stray too far may lose the block identity (Pillar 1).
- Shop perks/potions could trivialize the campaign if not tuned.

### Technical Risks
- Touch controls for 3D rotation on a phone are the biggest usability risk.
- Local multiplayer on mobile is cramped on one small screen.
- Modular rule-twist architecture must support ~dozens of combinable modifiers.
- Physics modes (gravity, wind) must perform on mobile hardware.

### Market Risks
- Crowded mobile puzzle market; hooks must show quickly in store assets.
- Party-game appeal on mobile depends on easy local play.

### Scope Risks
- Content breadth: 100 levels, many modes and minigames, 10 biomes of art.
- Large solo scope; no deadline mitigates this but invites creep.

### Open Questions
- How does local multiplayer work on mobile (shared tablet screen, local Wi-Fi/Bluetooth, split-screen on tablets)? Resolve in `/setup-engine` and architecture.
- What exact touch scheme for 3D rotation is best? Prototype first.
- How many twists can combine before readability breaks? Prototype with stacked modifiers.
- What is the economy curve for points vs perk/potion prices?
- Monetization model (premium, free with ads, none)?

---

## MVP Definition

**Core hypothesis**: Placing and rotating blocks in a 3D grid with touch controls on a fixed angled camera is satisfying, and a single rule-twist makes it fresh.

**Required for MVP**:
1. 3D grid, block spawn, move/rotate (3 axes), drop, layer clear, game over.
2. Fixed angled camera with rotate-view button; mobile touch controls.
3. One biome (about 5 levels) with at least 2 distinct twists.

**Explicitly NOT in MVP** (defer to later):
- Multiplayer, tournaments, items and buffs/debuffs.
- Shop, perks, potions, characters.
- Additional biomes and difficulty tiers; arcade mode.

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 biome (~5 levels) | Core loop, touch controls, 2 twists | 2-3 months |
| **Vertical Slice** | 2-3 biomes | + arcade, 4-5 twists, local 2-player tournament, basic items, 3-star scoring | +4-5 months |
| **Alpha** | All 10 biomes, 10 difficulty tiers | + all modes, items/buffs/debuffs, shop, perks, potions, characters, tournament minigames (rough) | +8-10 months |
| **Full Vision** | Complete content | + polish, audio, unlocks, tournaments of 3/5/7/13 rounds, tuning | +4-6 months |

---

## Systems Notes (for `/map-systems`)

Ideas captured here so the systems index starts complete:

- **Campaign structure**: 10 biomes x 10 difficulty tiers; each biome has its own signature mechanic; higher tiers add mechanics.
- **Rule-twist library**: layer-clear (with/without obstacles), build-up race (with hindrances), gravity, wind, invisible blocks, blocks that move after placement, spawned grid objects, objects that prefer certain block types or colors.
- **Game modes**: campaign, arcade, multiplayer tournament (3/5/7/13 rounds, random mode per round, head-to-head).
- **Items**: buffs and debuffs (Mario Kart-style) in versus play.
- **Economy**: points earned from 3-star level clears (time-based) and multiplayer wins; shop sells perks (persistent edge) and potions (one use).
- **Characters** (multiplayer): each with unique perks.
- **Tournament minigames**: freer interpretation, further from normal Tetris, still block-based.

---

## Next Steps

- [ ] Configure Godot via `/setup-engine` (mobile target)
- [ ] Create the art bible from the Visual Identity Anchor (`/art-bible`)
- [ ] **Prototype the core idea** (`/prototype 3d-block-placement-touch`) - validate rotation/camera feel on touch before writing GDDs
- [ ] Decompose the concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`)
- [ ] Create architecture (`/create-architecture`), then ADRs and `/architecture-review`
- [ ] Validate readiness with `/gate-check`
