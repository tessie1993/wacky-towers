# Level and minigame plans

There is one plan per level and per minigame. Several teams build each plan in layers:

| Layer | Team (skills to load) | Fills |
|---|---|---|
| 1. Play | level design (`studio-level-design-lead`, `gamedev-level-design`, `godot-genre-puzzle`) | **Play**, **Progression role** |
| 2. World and story | narrative + world-builder (`studio-narrative-content-lead`) | **In the world**, **Story beat** |
| 3. Art | art-director (`godot-3d-world-building`, `godot-ui-theming`) | **Art** |
| 4. Review | Godot experts (`godot-master`, `godot-auditor`, `studio-gameplay-lead`) | **Godot review** (verdict + fixes) |

Quality bar: `.claude/docs/reference-quality-bar.md`. Plans must reach the reference boards
(`assets/art/reference/`) at AAA quality, scoring at least 8/10 from the reviewers.

Standing rules:
- Boards are 8x8 or bigger.
- The next block is random on every attempt, and nothing is a hardcoded sequence.
- Minigames are building blocks used inside levels, and also random tournament rounds.
- No Nintendo IP, no "Tetris" naming, and no beige UI.
- Text in the game is live UI, never baked into the art. Tutorial bubbles are 12 words or fewer.

Files:
- `<biome>.md`, one per biome, with 14 level sections each.
- `minigames.md`, one section per minigame.
- `progression.md`, the whole-campaign arc. Each layer adds to it.

## Level section template (copy exactly; later layers fill their own headings)

```markdown
### <level_id>: <Display Name>  (tier N, <level_type>)

**Play** (layer 1)
- Goal: <goal type + numbers from the JSON, or the proposed change>
- How it plays: <2-4 sentences: what the player does moment to moment, the pressure, the twist>
- Teaches / tests: <the one idea this level introduces or tests>
- Rules and minigame blocks: <rule ids with key params; any module used>
- Board: <size, h_play, starting layout, per-attempt variation>
- Difficulty: <fall.g0, stars t2/t3, where it sits on the biome curve>
- Proposed changes: <concrete JSON edits, or "none">

**Progression role** (layer 1): <why it is here; what comes before and after>

**In the world** (layer 2): <where on the island/biome this happens, what you see, who is there>

**Story beat** (layer 2): <mascot/NPC moment, caption key if any, how it links to story-v2>

**Art** (layer 3): <set pieces, props, palette tokens, lighting, block skin, FX, camera notes, ref board>

**Godot review** (layer 4): <verdict PASS/FIX; implementation risks; nodes/systems; ranked fixes>
```

## Minigame section template

```markdown
### <minigame_id>: <Name>

**Play**: <rules, controls, win/lose, round length, 1-4 players, how it is used as a level block and as a tournament round>
**Modules and data**: <assets/data/modules/*.json, src/core/modules/*, what exists vs. missing>
**In the world**: <where it happens, story reason>
**Art**: <arena, props, UI, ref board 09-12>
**Godot review**: <verdict, implementation plan, risks>
```
