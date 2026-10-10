# Wave 1 decision sheet (user, 2026-10-10) — binding for all architecture writers
- Flow: Orchestrator for menus/level flow (ADR-0010 → Accepted, with an Android-export smoke test first and plain-GDScript fallback). Remove godot_state_charts.
- Beehave: staging/animation only. Anything that changes the board is a RuleRuntime rule inside BoardSim (ADR-0001/0004), so replays stay deterministic.
- Platforms: Android + PC/Steam ship TOGETHER. GodotSteam kept, excluded from Android export via feature tags. MVP input = touch + keyboard/mouse + gamepad.
- Monetization: undecided — design for none, leave a seam (no SDKs now).
- Perks & potions: active everywhere incl. solo campaign. Perks mixed by mode: edge perks in campaign + tournaments; quick versus = sidegrades only.
- Skills: big game-changing abilities; each skill's data declares its own use rule (charge meter from clears / once per level / consumable).
- Rotation: a THIRD rotation pair (3 axes), taught in meadow_02.
- Level maker: dev-team EditorPlugin dock in Godot (addons/wt_level_tools/). Mechanics = atoms picked from the library in a form; official levels may attach beehave trees for STAGING only. Reads/writes existing level JSON, runs LevelValidator live, test-play button, no built-in AI button, sharing = file/share code (future), scene dressing stays in per-level .tscn.
- Target device: FLAGSHIP phones (and PC). Set budgets accordingly; still keep the Mobile renderer.
- Save: local only now; format versioned with a seam for cloud save later.
- Relaxed timing: all 3 stars, star times scaled, no badge.
- UI frames: painted wood, a frame set per biome (Meadow first). Free rounded fonts, custom painted icons.
Defaults: ADR-0004 owns rule/knob schemas, ADR-0005 depends on it (breaks the cycle). Dev/AI autoloads (godot_ai, mcp_toolkit, beehave debug) stripped from release exports. GDScript only; C#/GDExtension only on a profiled hotspot. All UI text via translation keys, English only. No analytics. One profile in MVP. Reduced motion follows OS setting. Button scale 75–200%, min 56 dp.

# ADR number map (use these exact numbers and titles)
- 0010 Level flow & app lifecycle (exists, accept)
- 0011 Mechanic & level-event runtime (rules in sim, beehave staging)
- 0012 Input pipeline: touch + keyboard/mouse + gamepad (GUIDE)
- 0013 Save, profile & settings
- 0014 Camera rig, orientation & safe area (phantom_camera)
- 0015 Audio & feedback pipeline
- 0016 UI architecture (screens, navigation, theming, P/L layouts)
- 0017 Level-maker tooling (EditorPlugin)

# Round 5 (user, 2026-10-10)
- Music: no stems. One track per level, supplied by the user. "Carefree" = placeholder only.
- generate_3d Pip/Miller models = placeholders (to be replaced).
- Meadow lighting: 7 setups (day-to-night journey across the 10 levels).
- Docs in design/gdd/{ux,audio,narrative} + asset/atom lists stay; relax the 8-section check for those subfolders.
- meadow_09/10: the STACK flips (island stays).
- Miller joins the picnic as a Meadow-only exception; never playable/party; rule holds elsewhere.
- UI defaults confirmed: free rounded fonts + painted icons; credits + privacy note only extra screens; reduced motion follows OS; buttons 75–200%, min 56 dp.
- Local multiplayer: each player on their own phone over LOCAL WI-FI (LAN). Already covered by ADR-0009 (one phone per player, ENet LAN). No new ADR.
- Skill use rule depends on MODE (e.g. charge meter in campaign, once per round in tournaments).
- 4 playable characters at launch, each with a perk set + one skill.
- Edge perks capped at ~15%; star times balanced for no perks.
- Camera: free orbit + snap to nearest of 12 × 30° steps on release; 4 corner views as shortcuts.
- Verification: headless Godot allowed ONLY for throwaway scripts in the scratchpad, never on the project. Project verification via godot-ai / godot-mcp-toolkit.
- Rotation pair names (player-facing): Turn / Flip / Roll (code ids spin / tilt / roll).
- Reference phone: a recent Samsung Galaxy S. Flagship perf targets in architecture.md §9 approved as tunable defaults.
- Save profiles: 4 from the start in the MVP (adds profile-select screen to the MVP UI).

# World / story / UI round (user, 2026-10-10)
- Biomes after Meadow include: Candy/bakery, Ice/snow, Lava/volcano, Underwater/reef (designers propose the other 5).
- Biome map: fixed main chain + optional side-island biomes.
- Story: a bigger CONNECTED plot across biomes, still WORDLESS (skits, emotes, map changes).
- Villain: a misunderstood lonely rival wizard who sets off the bosses' pranks; redeemed at the end (Miller tone).
- Level planning now: one-page outline for all 10 biomes; Meadow detailed level-by-level.
- Characters: cloud wizard + 3 new cute builder friends (4 playable).
- Extra UI designed now: character select + perks, shop, tournament lobby (local Wi-Fi), level-maker dock.
- Atoms: all 42 proposals (scratchpad/atoms-puzzle.md + atoms-party.md) go into the library with status Proposed; renumber the 4 clashing party ids (BL17, GO27, EV20, WO12).
- Co-op: short team-up party events (Boss Raid, Truce Pact) allowed in tournaments only; scores stay individual. No co-op mode.
- Turn-based puzzle levels CAN be failed (undo/reset is an optional atom, not default).

# Wave 2 writer rules (all agents)
- User approved wave 2: you may write/edit exactly the files named in your brief. Nothing else.
- Follow design/CLAUDE.md and the format of existing GDDs; workflow sections per project.yaml modes.workflow. Values are tunable defaults, never hard rules.
- design/gdd/{ux,audio,narrative}/ and asset/atom lists are exempt from the 8-section rule.
- Use the architecture ADRs in docs/architecture/ (0001–0017) as the technical truth; don't contradict them — flag conflicts instead.
- No Godot runs except throwaway scratchpad scripts. No commits.
- Reply ≤5 lines: files written, conflicts flagged, open questions.

# /team-narrative round (user, 2026-10-10)
- Run the FULL studio team for this run (narrative-director, world-builder, writer, art-director, level-designer, localization-lead).
- Depth: FULL DETAIL for all 100 levels (supersedes "outline all 10, detail Meadow").
- Output paths: design/gdd/narrative/ (story, lore, biomes), design/levels/<biome>.md (levels). Drafts under production/narrative/.
- Biomes 6–10 + side islands: designers decide and write straight through; user reviews the finished result.
- Story bible (production/narrative/campaign-story/brief.md) approved direction: rival wizard Mizzle; biomes Meadow, Candy, Ice, Underwater, Lava, Forest, Cave, Clockwork, Neon, Celestial; side islands Tumble Fair, Dune Bazaar, Boo Hollow, Drizzle Rock; friends Lana (alpaca, Ice, Stitch), Boulder (pygmy hippo, Lava, Smash), Glim (bat, Cave, Redraw).
- Side islands + Scrapbook kept, built post-MVP. Nine bosses allowed as finale-skit guests only (never playable). Cave low point = SOFTER version. Side-island levels ALSO in full detail.
