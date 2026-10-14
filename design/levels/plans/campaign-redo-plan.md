# Campaign redo plan: narrative first, every level unique

User, 2026-10-14: "redo the art, all levels look the same, redo the level design, make each level
not just in art but also different in game play. Use the studio and Godot teams to redo every level,
the campaign game flow and level progression. Make the narrative first and get inspired by the story
to make the levels. Make a plan first. Pass grade must be 9.7, not 8, for all reviewers."

## Goal

Every level in the campaign is memorable for its **story moment**, its **place in the world** and its
**way of playing**. The campaign reads as one adventure from the first island to the finale. Every
reviewer scores the result at least 9.7/10 (`.claude/docs/reference-quality-bar.md`).

## Inputs we keep

- The story so far: `design/gdd/narrative/story-v2.md`, `assets/data/story/captions.json` (S01–S20),
  and `design/decisions/2026-10-14-story-cast-decisions.md`. The cast is the Wizard, Dame Ada,
  Bram and Sif; Pirate Cove is the 11th biome to be added; it sits 5th in catalog order.
- The audit facts: 123/168 levels use `clear_n`, 163/168 are plain 8x8, every biome repeats the
  same tier template, and Pirate copies Underwater.
- The plans layer 1 (`design/levels/plans/<biome>.md`), the minigames (16), progression.md and
  level-identity-spec.md.
- Engine work already running: block hue variation (ref 13), the per-level `look` (time of day,
  weather, set piece, camera), and the no-beige UI (done).

## Phases, owners and gates

Each phase ends with a **review gate**. A strict reviewer scores the phase's output. Below 9.7, the
owner revises and the gate re-runs. No phase starts before the one it depends on passes.

| # | Phase | Owner (studio skill → agent) | Output | Depends on |
|---|---|---|---|---|
| 1 | **Vision brief**: campaign fantasy, 3 pillars, emotional arc, tone, and what "every level unique" means as testable rules | `studio-game-director` → creative-director | `design/levels/plans/campaign-vision.md` | none |
| 2 | **Campaign story**: the adventure across 12 biomes. One chapter per biome with its villain or problem, ally, set pieces and emotional beat. Then one **story beat per level** (14 per biome): what happens, who is there, why the player stacks here | `studio-narrative-content-lead` → narrative-director, world-builder, writer | `design/narrative/campaign-story.md` + `design/narrative/beats/<biome>.md` | 1 |
| 3 | **Mechanics roster and progression**: which mechanic each biome teaches, twists and combines. The minigame blocks and boss systems, each tied to the story beat that motivates it. Difficulty curve formulas (g0, goal n, stars) and unlock flow | `studio-systems-designer` → systems-designer, game-designer | `design/levels/plans/mechanics-roster.md` + `progression.md` v2 | 2 |
| 4 | **Level specs**: all levels rewritten from their story beat. Each has a board shape, goal, rules, minigame block, `look` (set piece, time, weather), camera, signature, and teach/twist role | `studio-level-design-lead` → level-designer (4 biome groups) | `design/levels/plans/<biome>.md` v2 | 2, 3 |
| 5 | **Plan review** at 9.7: narrative, level/mechanics and art critics review the specs *before* any JSON changes | reviewer panel | `production/qa/quality-review/<date>-plan-*.md` | 4 |
| 6 | **Build**: level JSONs from the specs, plus engine gaps the specs need (boss phases, minigame phase runner, new goals, set pieces) | gameplay-programmer + technical-artist (Sonnet) | level JSONs, src | 5 |
| 7 | **Playtest and capture**: every level played by bot plus a start/mid/clear/end screenshot; biome contact sheets | qa-tester, `studio-qa-playtest-lead` | `production/qa/evidence/campaign-v2/` | 6 |
| 8 | **Final review** at 9.7: art, levels/mechanics, narrative and audio | reviewer panel | quality-review reports | 7 |
| — | **Producer**: sequencing, risk, the decisions log and status after every gate | `studio-producer` → producer | `production/campaign-redo-status.md` | all |

## Task breakdown (1–3 day tasks)

1. Vision brief (game director).
2. Campaign story outline: 12 chapters and the campaign arc (narrative lead).
3. Story beats for biomes 1–4, 5–8 and 9–12, in parallel (writer and world-builder).
4. Mechanics roster and progression formulas (systems designer).
5. Level specs, one task per group of 3 biomes, run in parallel (level designers).
6. Plan review at 9.7, then revise and re-review until it passes.
7. Engine gaps: the boss phase system, the minigame phase runner, new goal types, and the shape target overlay.
8. Build JSONs, one task per group of 3 biomes; the verifier must report 0 failures.
9. Per-level look data plus set-piece art.
10. Playtest captures and contact sheets.
11. Final review at 9.7, then fix and re-review.
12. Buffer, 20%: bugs, review loops, rate limits.

## Acceptance criteria

- Every level has a story beat, a `metadata.signature` and a `look`.
- No two levels in the campaign share the same (goal, main rule, board shape).
- At most 4 plain-square boards per biome. **No `clear_n` headline goals** (U15). At least 4 surprise endings per biome (U16).
- Every tier-10 finale is a phased boss tied to its chapter villain. No `fixed_list` anywhere.
- The difficulty curve rises: g0 increases within each biome, and the hard track is faster than tier 10.
- The verifier reports 0 failures, CI is green, and the game boots (`ui_flow_smoke`).
- Every reviewer scores every item at least 9.7/10.

## Risks

- **Scale:** 168 levels at a 9.7 bar is a lot of review loops. Mitigation: review the plan before
  the build, and gate each biome group separately.
- **Engine gaps:** boss phases, the minigame phase runner and the shape overlay don't exist yet, and
  specs that need them block the build. Mitigation: phase 6 builds the engine first.
- **Rate limits:** earlier agents were cut off by the session limit. Mitigation: at most 6 agents at
  once, with one report per phase.
- **Doc conflicts:** tumble-fair.md (a 5-level side island) contradicts the 14-level Carnival biome.
  Phase 2 resolves this.

## Decisions log

- 2026-10-14: the pass mark is 9.7/10 for all reviewers (user).
- 2026-10-14: narrative comes first and levels are inspired by the story (user).
- 2026-10-14: the level-redesign agents were stopped before writing; no level JSON was changed.
- 2026-10-14: the plan was approved and started (user).
- 2026-10-14: keep 168 levels (12 biomes × 14) (user).
- 2026-10-14: **fresh story**. Keep only the cast (the Wizard, Dame Ada, Bram, Sif, plus the NPCs
  Lana, Boulder and Glim). Write a new campaign story from scratch. The 20 old panels (S01–S20) are
  not binding (user).
- 2026-10-14: order confirmed by the user. (1) Research the story and write a chapter per biome,
  making every level a piece of the story. (2) Write out in words how each level is played and how
  each mechanic works. (3) Only then make the level art and the level code. Step 2 has two outputs:
  the per-level specs (phase 4) and a plain-words **mechanics handbook**
  (`design/levels/plans/mechanics-handbook.md`) explaining every rule and goal a player meets.
- 2026-10-14: no "clear N layers" goals, at least 4 non-obvious endings per biome, never mundane
  (user). See level-identity-spec.md § User rules.
- 2026-10-14: **peril tone is real tension** in Lava and Neon. These are darker moments with a real sense
  of loss before the comeback. They stay kid-safe, with no on-screen harm (user).
- 2026-10-14: **the ending** is the Carnival boss plus a bonus celebration. The hard levels (h1–h3) in
  each biome are an optional epilogue, "the villain strikes back" (user).
- 2026-10-14: **Pirate Cove plays 11th** (user). The campaign order becomes: meadow, candy, ice,
  underwater, lava, forest, cave, clockwork, neon, celestial, **pirate**, carnival. The story, the
  emotional arc and the progression use this order. The catalog and unlock order change in phase 6
  (build).
