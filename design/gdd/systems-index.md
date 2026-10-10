# Systems Index: Wacky Towers

> **Status**: Draft
> **Created**: 2026-10-09
> **Last Updated**: 2026-10-10 (wave 2 rows #30–37, #39; revised core GDDs; dependency notes)
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Wacky Towers is a 3D falling-block puzzle party game for mobile: rotate pieces on three axes, drop them into a 3D grid, clear layers, while every biome, level and mode bends the rules. Its systems fall into three groups. First, a **classic core** (board, pieces, touch controls, camera, movement/rotation, drop/lock, layer clearing, goals) that must feel snappy and readable on a phone (*Readable Chaos*). Second, a **rule-bending layer** built around one Rule-Twist Framework, which lets twists, level-specific mechanics, obstacles, status effects, buffs/debuffs, items and skills all hook into the core without rewriting it (*Variation Over Depth*, *The Block Is the Constant*). Third, the **structure and meta** around it: level data, the 10 × 10 campaign, scoring and stars, points and shop, characters, and tournaments with a mode/minigame randomizer (*Comeback Energy*). Like the art bible, everything here is a starting default that can change as design proceeds.

**Classic core.** *Board/Grid* holds the 3D cell space and height limit; every other system reads it. *Piece Set* defines the shapes and their type IDs. *Touch Controls* and *Camera & Rotate-View* are where the concept's biggest risk lives: 3-axis rotation must feel intuitive on a phone. *Spawner & Queue* needs a fair randomizer. *Movement & Rotation* owns collision and 3D wall kicks. *Fall/Drop/Lock* owns speed, soft/hard drop, lock delay and the landing ghost. *Layer Clearing* detects and collapses full layers. *Level Goals & Fail States* defines what winning and losing mean per mode.

**Rule-bending layer.** The *Rule-Twist Framework* is the plug-in contract every rule change uses. It also owns **conflict resolution**: when a *Level-Specific Mechanic* deliberately contradicts a general rule (e.g. "full layers don't clear here"), the framework's priority order decides which rule wins. The *Twist Library* holds the reusable twists (wind, gravity, invisible blocks, drifting pieces, spawned and colour-loving objects, build-up races, shape-filling). *Obstacles* are non-player blocks or objects on the board, and *Obstacle Clearing* defines how they are removed. *Block Status Effects* (frozen, burning, honey, vines, crumbling, shadow, spiked) give the art bible's shells their gameplay meaning. *Buffs & Debuffs* are effects; *Items* are the pickups that cause them; *Skills* are abilities a player triggers. *Physics Mode* is the wobbly-tower alternative to grid-locked play.

**Structure and meta.** *Level Data* turns each level into data (biome, twists, level mechanic, goal, tier, star times), so 100 levels are content rather than code. *Campaign Structure* orders 10 biomes × 10 tiers. *Scoring & Stars* is in-level score and 3-star time targets; the *Points System* is the meta currency earned from stars and wins, spent in the *Shop* on perks and potions. *Characters & Perks* own passive perks and reference Skills. *Tournament Flow* runs 3/5/7/13-round events, with the *Mode/Minigame Randomizer* picking each round. *Local Multiplayer Setup* (how 2-4 players share devices/screens) is still an open question. *Save & Profile* persists it all. Presentation (HUD, menus, game feel, audio, mascot reactions) and polish (onboarding, accessibility) wrap the rest and follow the art bible.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Board / Grid | Core | MVP | Needs Revision | design/gdd/board-grid.md | — |
| 2 | Piece Set (inferred) | Core | MVP | Needs Revision | design/gdd/piece-set.md | — |
| 3 | Touch Controls | Core | MVP | Designed | design/gdd/touch-controls.md | — |
| 4 | Camera & Rotate-View | Core | MVP | Designed | design/gdd/camera-rotate-view.md | Board / Grid |
| 5 | Piece Spawner & Queue (inferred) | Gameplay | MVP | Designed | design/gdd/piece-spawner-queue.md | Piece Set |
| 6 | Movement & Rotation | Gameplay | MVP | Designed (revised 2026-10-10) | design/gdd/movement-rotation.md | Board / Grid, Piece Set, Touch Controls, Camera & Rotate-View |
| 7 | Fall, Drop & Lock (inferred) | Gameplay | MVP | Designed (revised 2026-10-10) | design/gdd/fall-drop-lock.md | Board / Grid, Movement & Rotation |
| 8 | Layer Clearing | Gameplay | MVP | Designed | design/gdd/layer-clearing.md | Board / Grid, Fall, Drop & Lock |
| 9 | Level Goals & Fail States | Gameplay | MVP | Designed (revised 2026-10-10) | design/gdd/level-goals-fail-states.md | Board / Grid, Layer Clearing |
| 10 | Rule-Twist Framework | Gameplay | MVP | Designed (revised 2026-10-10) | design/gdd/rule-twist-framework.md | Board / Grid, Piece Spawner & Queue, Movement & Rotation, Fall, Drop & Lock, Layer Clearing |
| 11 | Level-Specific Mechanics | Gameplay | MVP | Needs Revision | design/gdd/level-specific-mechanics.md | Rule-Twist Framework |
| 12 | Twist Library | Gameplay | MVP | Designed | design/gdd/twist-library.md | Rule-Twist Framework |
| 13 | Level Data & Definition (inferred) | Gameplay | MVP | Needs Revision | design/gdd/level-data-definition.md | Level Goals & Fail States, Rule-Twist Framework, Level-Specific Mechanics, Twist Library |
| 14 | HUD (inferred) | UI | MVP | Needs Revision | design/gdd/hud.md | Piece Spawner & Queue, Level Goals & Fail States |
| 15 | Obstacles | Gameplay | Vertical Slice | Needs Revision | design/gdd/obstacles.md | Board / Grid, Rule-Twist Framework |
| 16 | Obstacle Clearing | Gameplay | Vertical Slice | Designed | design/gdd/obstacle-clearing.md | Layer Clearing, Obstacles |
| 17 | Scoring & Stars | Progression | Vertical Slice | Needs Revision | design/gdd/scoring-stars.md | Layer Clearing, Level Goals & Fail States |
| 18 | Buffs & Debuffs | Gameplay | Vertical Slice | Needs Revision | design/gdd/buffs-debuffs.md | Rule-Twist Framework |
| 19 | Items | Gameplay | Vertical Slice | Needs Revision | design/gdd/items.md | Buffs & Debuffs |
| 20 | Arcade Mode | Gameplay | Vertical Slice | Designed | design/gdd/arcade-mode.md | Level Goals & Fail States, Scoring & Stars, Twist Library |
| 21 | Campaign Structure | Progression | Vertical Slice | Needs Revision | design/gdd/campaign-structure.md | Level Data & Definition, Scoring & Stars |
| 22 | Mode / Minigame Randomizer | Gameplay | Vertical Slice | Needs Revision | design/gdd/mode-minigame-randomizer.md | Level Goals & Fail States, Level Data & Definition |
| 23 | Tournament Flow | Gameplay | Vertical Slice | Designed | design/gdd/tournament-flow.md | Scoring & Stars, Mode / Minigame Randomizer, Items |
| 24 | Local Multiplayer Setup (inferred) | Core | Vertical Slice | Needs Revision | design/gdd/local-multiplayer-setup.md | Touch Controls, Camera & Rotate-View |
| 25 | Save & Profile (inferred) | Persistence | Vertical Slice | Needs Revision | design/gdd/save-profile.md | Campaign Structure, Scoring & Stars |
| 26 | Menus & Level Select (inferred) | UI | Vertical Slice | Designed | design/gdd/menus-level-select.md | Campaign Structure, Save & Profile |
| 27 | Game Feel & VFX (inferred) | UI | Vertical Slice | Needs Revision | design/gdd/game-feel-vfx.md | Layer Clearing, Buffs & Debuffs, Items |
| 28 | Physics Mode | Gameplay | Alpha | Needs Revision | design/gdd/physics-mode.md | Board / Grid, Piece Set, Fall, Drop & Lock, Rule-Twist Framework |
| 29 | Block Status Effects (inferred) | Gameplay | Alpha | Designed | design/gdd/block-status-effects.md | Board / Grid, Rule-Twist Framework |
| 30 | Skills | Gameplay | Alpha | Designed (Draft; C2–C4 story skills 2026-10-10) | design/gdd/skills.md | Rule-Twist Framework, Buffs & Debuffs, Characters & Perks |
| 31 | Characters & Perks | Progression | Alpha | Designed (Draft) | design/gdd/characters-perks.md | Skills, Buffs & Debuffs, Rule-Twist Framework |
| 32 | Points System (currency: stars) | Economy | Alpha | In Design (Draft; currency rework in progress) | design/gdd/points-system.md | Scoring & Stars, Tournament Flow |
| 33 | Shop | Economy | Alpha | In Design (Draft; currency rework in progress) | design/gdd/shop.md | Points System, Characters & Perks, Buffs & Debuffs |
| 34 | Tournament Minigames | Gameplay | Alpha | Needs Revision | design/gdd/tournament-minigames.md (ideas: design/gdd/mechanics-catalog.md) | Board / Grid, Piece Set, Level Goals & Fail States, Mode / Minigame Randomizer |
| 35 | Mascot Reactions (inferred) | UI | Alpha | Designed (Draft) | design/gdd/mascot-reactions.md | Level Goals & Fail States, Fall, Drop & Lock, Layer Clearing, Mechanics Module |
| 36 | Audio (inferred) | Audio | Alpha | Designed (Draft) | design/gdd/audio.md (+ design/gdd/audio/) | Layer Clearing, Items, Campaign Structure |
| 37 | Onboarding & Accessibility (inferred) | Meta | Alpha | Designed (Draft) | design/gdd/onboarding-accessibility.md | Touch Controls, HUD, Campaign Structure |
| 39 | Level-Maker Dock (dev tool, ADR-0017) | Meta | Vertical Slice | Designed (ADR-0017; UI spec pending) | docs/architecture/adr-0017-level-maker-tooling.md | Level Data & Definition, Rule-Twist Framework, Mechanics Module |
| 38 | Mechanics Module (box of tricks: atoms, recipes, daily generator) | Gameplay | Vertical Slice | Needs Revision | design/gdd/mechanics-module.md (folder: design/mechanics/README.md) | Rule-Twist Framework, Level Data & Definition, Level-Specific Mechanics, Twist Library, Tournament Minigames |

---

## Categories

| Category | Description | Systems here |
|----------|-------------|--------------|
| **Core** | Foundation systems everything depends on | Board/Grid, Piece Set, Touch Controls, Camera, Local Multiplayer Setup |
| **Gameplay** | The systems that make the game fun | Movement, Drop/Lock, Clearing, Goals, Rule-Twist Framework, Level Mechanics, Twists, Obstacles, Status Effects, Buffs/Debuffs, Items, Skills, Physics Mode, Level Data, Modes, Randomizer, Tournament, Minigames |
| **Progression** | How the player grows over time | Scoring & Stars, Campaign Structure, Characters & Perks |
| **Economy** | Resource creation and consumption | Points System, Shop |
| **Persistence** | Save state and continuity | Save & Profile |
| **UI** | Player-facing information displays | HUD, Menus & Level Select, Game Feel & VFX, Mascot Reactions |
| **Audio** | Sound and music systems | Audio |
| **Meta** | Systems outside the core game loop | Onboarding & Accessibility |

No Narrative category: story is an anti-pillar.

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Without these, you can't test "is this fun?" Concept MVP: 3D grid, touch, camera, one biome (~5 levels) with at least 2 twists, plus level-specific mechanics (user decision 2026-10-09) | First playable prototype | Design FIRST |
| **Vertical Slice** | 2-3 biomes, arcade, 4-5 twists, obstacles, local 2-player tournament, basic items, 3-star scoring | Vertical slice / demo | Design SECOND |
| **Alpha** | All 10 biomes and tiers, physics mode, status effects, skills, characters, points and shop, minigames | Alpha milestone | Design THIRD |
| **Full Vision** | No new systems: polish, tuning, longer tournaments (3/5/7/13 rounds), content completion | Beta / Release | Design as needed |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. Board / Grid — the cell space, dimensions and height limit every gameplay system reads.
2. Piece Set — shapes, type IDs and face motifs; spawning, movement and art all key off it.
3. Touch Controls — the input vocabulary (move, 3-axis rotate, drop); the concept's top usability risk.
4. Camera & Rotate-View — depends on: Board / Grid. Defines the view the controls are relative to.

### Core Layer (depends on foundation)

1. Piece Spawner & Queue — depends on: Piece Set
2. Movement & Rotation — depends on: Board / Grid, Piece Set, Touch Controls, Camera
3. Fall, Drop & Lock — depends on: Board / Grid, Movement & Rotation
4. Layer Clearing — depends on: Board / Grid, Fall, Drop & Lock
5. Level Goals & Fail States — depends on: Board / Grid, Layer Clearing
6. Rule-Twist Framework — depends on: Spawner, Movement, Drop/Lock, Layer Clearing (it hooks into each). **Bottleneck**: nearly every Feature-layer mechanic plugs into it, and it owns rule-conflict priority.

### Feature Layer (depends on core)

Mechanics:
1. Level-Specific Mechanics — depends on: Rule-Twist Framework. May contradict general rules; the framework's priority order resolves conflicts.
2. Twist Library — depends on: Rule-Twist Framework
3. Obstacles — depends on: Board / Grid, Rule-Twist Framework
4. Obstacle Clearing — depends on: Layer Clearing, Obstacles
5. Buffs & Debuffs — depends on: Rule-Twist Framework
6. Items — depends on: Buffs & Debuffs (items are pickups that cause effects)
7. Skills — depends on: Rule-Twist Framework, Buffs & Debuffs
8. Block Status Effects — depends on: Board / Grid, Rule-Twist Framework
9. Physics Mode — depends on: Board / Grid, Piece Set, Drop/Lock, Rule-Twist Framework

Structure and meta:
1. Level Data & Definition — depends on: Goals, Rule-Twist Framework, Level-Specific Mechanics, Twist Library
2. Scoring & Stars — depends on: Layer Clearing, Goals
3. Campaign Structure — depends on: Level Data, Scoring & Stars
4. Arcade Mode — depends on: Goals, Scoring & Stars, Twist Library
5. Mode / Minigame Randomizer — depends on: Goals, Level Data
6. Tournament Flow — depends on: Scoring & Stars, Randomizer, Items
7. Tournament Minigames — depends on: Board / Grid, Piece Set, Goals, Randomizer
8. Local Multiplayer Setup — depends on: Touch Controls, Camera
9. Characters & Perks — depends on: Skills, Buffs & Debuffs
10. Points System — depends on: Scoring & Stars, Tournament Flow
11. Shop — depends on: Points System, Characters & Perks, Buffs & Debuffs
12. Save & Profile — depends on: Campaign Structure, Scoring & Stars

### Presentation Layer (depends on features)

1. HUD — depends on: Spawner & Queue (next piece), Goals (MVP basic version; extended for items, buffs and scores in later tiers)
2. Menus & Level Select — depends on: Campaign Structure, Save & Profile
3. Game Feel & VFX — depends on: Layer Clearing, Buffs & Debuffs, Items
4. Mascot Reactions — depends on: Characters & Perks, Goals
5. Audio — depends on: Layer Clearing, Items, Campaign Structure

### Polish Layer (depends on everything)

1. Onboarding & Accessibility — depends on: Touch Controls, HUD, Campaign Structure

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Board / Grid | MVP | Foundation | game-designer | S |
| 2 | Piece Set | MVP | Foundation | game-designer | S |
| 3 | Touch Controls | MVP | Foundation | ux-designer, game-designer | M |
| 4 | Camera & Rotate-View | MVP | Foundation | game-designer, ux-designer | S |
| 5 | Piece Spawner & Queue | MVP | Core | systems-designer | S |
| 6 | Movement & Rotation | MVP | Core | game-designer, systems-designer | M |
| 7 | Fall, Drop & Lock | MVP | Core | systems-designer | S |
| 8 | Layer Clearing | MVP | Core | game-designer | S |
| 9 | Level Goals & Fail States | MVP | Core | game-designer | S |
| 10 | Rule-Twist Framework | MVP | Core | systems-designer, game-designer | L |
| 11 | Level-Specific Mechanics | MVP | Feature | game-designer, level-designer | M |
| 12 | Twist Library (first 2 twists) | MVP | Feature | game-designer | M |
| 13 | Level Data & Definition | MVP | Feature | level-designer, systems-designer | S |
| 14 | HUD (basic) | MVP | Presentation | ux-designer | S |
| 15 | Obstacles | Vertical Slice | Feature | game-designer | S |
| 16 | Obstacle Clearing | Vertical Slice | Feature | game-designer | S |
| 17 | Scoring & Stars | Vertical Slice | Feature | systems-designer | S |
| 18 | Buffs & Debuffs | Vertical Slice | Feature | game-designer, systems-designer | M |
| 19 | Items | Vertical Slice | Feature | game-designer | M |
| 20 | Arcade Mode | Vertical Slice | Feature | game-designer | S |
| 21 | Campaign Structure | Vertical Slice | Feature | level-designer, game-designer | M |
| 22 | Mode / Minigame Randomizer | Vertical Slice | Feature | systems-designer | S |
| 23 | Tournament Flow | Vertical Slice | Feature | game-designer | M |
| 24 | Local Multiplayer Setup | Vertical Slice | Feature | ux-designer, game-designer | M |
| 25 | Save & Profile | Vertical Slice | Feature | systems-designer | S |
| 26 | Menus & Level Select | Vertical Slice | Presentation | ux-designer | M |
| 27 | Game Feel & VFX | Vertical Slice | Presentation | technical-artist, game-designer | M |
| 28 | Block Status Effects | Alpha | Feature | game-designer | M |
| 29 | Physics Mode | Alpha | Feature | game-designer, systems-designer | L |
| 30 | Skills | Alpha | Feature | game-designer | M |
| 31 | Characters & Perks | Alpha | Feature | game-designer | M |
| 32 | Points System | Alpha | Feature | economy-designer | S |
| 33 | Shop | Alpha | Feature | economy-designer | M |
| 34 | Tournament Minigames | Alpha | Feature | game-designer | L |
| 35 | Mascot Reactions | Alpha | Presentation | game-designer | S |
| 36 | Audio | Alpha | Presentation | audio-director, sound-designer | M |
| 37 | Onboarding & Accessibility | Alpha | Polish | ux-designer, accessibility-specialist | M |

---

## Circular Dependencies

None found, after three relationships were directed one way:
- **Level Data ↔ Level-Specific Mechanics**: mechanics define their own parameters; Level Data only references them.
- **Items ↔ Buffs & Debuffs**: items cause effects; effects don't know about items.
- **Characters ↔ Skills**: characters reference skills; skills are defined independently.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Rule-Twist Framework | Design / Technical | Dozens of twists and level mechanics must combine without breaking; level mechanics may deliberately contradict general rules | Define hook points and a conflict-priority order up front; prototype 2 twists + 1 contradicting level mechanic stacked in MVP |
| Touch Controls | Design | 3-axis rotation on a phone is the concept's biggest usability risk | Prototype first (`/prototype 3d-block-placement-touch`) before locking the GDD |
| Movement & Rotation | Design | Rotation and wall kicks in 3D can feel unfair or confusing | Prototype with Touch Controls; playtest early |
| Local Multiplayer Setup | Design / Scope | Up to 4 players on one phone is cramped (art bible §7) | Decide pass-and-play vs device-per-player vs tablet-only before Tournament Flow |
| Physics Mode | Technical | Physics towers must perform on mobile and coexist with grid rules | Keep it isolated behind the framework; profile early in Alpha |
| Tournament Minigames | Scope | Open-ended content that may stray from Pillar 1 | Cap the count; every minigame must be built from the same blocks |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 39 |
| Design docs started | 38 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 14/14 |
| Vertical Slice systems designed | 14/14 |

> Gates: TD-SYSTEM-BOUNDARY, PR-SCOPE and CD-SYSTEMS skipped — lean review mode.

---

## Next Steps

- [ ] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (use `/design-system [system-name]`, or `/map-systems next`)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check technical-setup` when MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
