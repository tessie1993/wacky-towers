# Meadow MVP plan (approved by user, 2026-10-10)

**MVP** = title/menu + Meadow 01–10 + bonus, fully playable with art, sound, stars and save. H1–H3 later. All values are tunable defaults.

## Phases (agents in order)
| # | Phase | Agents | Plugins / tools | Done when |
|---|---|---|---|---|
| 0 | Regroup | producer → lead-programmer | chunk README | one task list; stopped work finished or dropped; Track B is the target; `._*.wav` removed |
| 1 | Design gaps | game+systems-designer (7 candidate atoms) · narrative-director → writer · ux-designer + accessibility-specialist · audio-director + sound-designer · art-director (asset list) → creative-director sign-off | /design-review, /ux-design, /asset-spec | every mechanic, screen, sound, asset specced |
| 2 | Assets | creative-director → technical-artist (Blender MCP: Poly Haven, Poly Pizza, BlenderKit add-on, generate_3d for Pip/Miller) → art-director | Blender MCP | GLBs in assets/models/meadow/ + licences in credits.json |
| 3 | Core loop (B1–B5) | lead-programmer → Sonnet gdscript agents (tests first) → Opus integrator | GUIDE, phantom_camera, gdUnit4, godot-ai | meadow_01 won + lost by input_simulate |
| 4 | Menus + flow | ux-designer → ui-programmer → integrator | Orchestrator, godot-ai ui/theme | title → map → level → results → next |
| 5 | Save/stars/unlocks | systems-designer → gameplay-programmer | gdUnit4 | survives restart |
| 6 | Levels 01 → 02,05,09,10 → 03,04,06,07,08 → B | level-designer → gameplay-programmer (beehave) → integrator | beehave, Orchestrator, godot-ai | each level won + lost, screenshot kept |
| 7 | Audio | sound-designer → gameplay-programmer → integrator | godot-ai audio_manage | every cue fires; layered music |
| 8 | Feel/VFX | technical-artist + godot-shader-specialist | particle/material tools | clears, danger, flip, boss land |
| 9 | QA + gate | qa-lead → qa-tester → performance-analyst → accessibility-specialist → producer | /smoke-check, /team-qa, /gate-check | all 11 levels pass; MVP gate |

## Integrator brief (every godot-ai session)
Wait for EDITOR_FREE, take lock → move staged parts, scan, logs_read, fix → build scene from its build sheet → run only that chunk's gdUnit4 test in the editor (no full suite, no headless) → project_run + input_simulate to a win and a loss → editor_screenshot to production/qa/evidence/<level>/ → release lock, report ≤5 lines.

## Decisions (user, 2026-10-10)
- Orientation: **portrait and landscape** (two layouts).
- Menu: **island map** — the cloud wizard floats over the 10 Meadow islands.
- Music: **toybox folk** (ukulele, glockenspiel, pizzicato, light percussion), from a **CC0/CC-BY pack**, credited.
- Story: **wordless skits + emote speech bubbles** (icons, no text).
- Player: **the cloud wizard** drops the blocks; Pip is the friend.
- The Miller: **secretly lonely** — pranks because nobody invites him; small redemption at the end of Meadow.
- Accessibility in MVP: camera-control types + control-scheme customisation, colourblind shapes/patterns, button remap + size, reduced motion, separate volume sliders (+ haptics).
- Defaults pending: Pip/Miller via generate_3d; user logs into BlenderKit; Android first.
