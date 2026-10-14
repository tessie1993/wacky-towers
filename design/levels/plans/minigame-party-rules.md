# Minigame and party rules (godot-genre-party)

User, 2026-10-14: "help with making the minigames and levels, and let agents ask you questions."
These rules apply `.claude/skills/godot-genre-party/SKILL.md` to Wacky Towers. Minigames are **building
blocks inside campaign levels** (phases run by `ModulePhaseRunner`) and **random tournament rounds**
(`assets/data/tournament/templates.json`: 36 minigame and 4 versus templates, run by
`WtMinigameRound`). The phase 3 mechanics handbook and the phase 4 specs follow these rules. Agents
ask the Godot master (see `.claude/docs/godot-master-consult.md`) when a rule doesn't fit.

## Design rules

1. **Short and intense.** A tournament round lasts 30 s to 2 min. A minigame phase inside a level
   lasts 20 s to 90 s and ends with a story payoff (the bridge is done, the fort falls).
2. **Teach in 3 seconds.** A looping preview plus one live-UI sentence of 12 words or fewer
   ("Stack the planks before the river rises!"). No text tutorials.
3. **Standard controls in every minigame.** The same move, rotate and drop as the core game. Accept
   or Action is always the same button, and Back is always the same button. A minigame may add at
   most **one** extra verb (dash, fire or grab), shown as a single gem button.
4. **Built on stacking.** Every minigame is still about placing falling blocks; the twist is what the
   stack does (bridge, fort wall, ammo, foothold, dam). This is pillar P2, "the stack is the answer".
5. **A scene, not a grid.** The arena is a diorama (chasm, cliffs, mine, machine). The cast is on
   stage, the set piece acts, and the HUD meter is themed (Heat, Fort HP, Altitude, Lava Rise,
   Balance), as in refs 09–12, using only original names.
6. **Asymmetric 1v3 needs balance.** The "one" gets more HP, an extra verb or a faster drop. Write
   the offset as numbers in the template data, never "TBD".
7. **Handicaps keep it social.** There is an optional per-player assist (slower gravity, a ghost
   column, a longer preview), and rubber-banding uses the existing `rubber_band` params. It can be
   turned off in competitive mode.
8. **Fair randomness.** The piece order comes from a seeded bag that is shared by all players in a
   round, so nobody gets a luckier queue. The seed is logged for replay.
9. **Variety across a tournament.** A round draw never repeats the same template in a row, and it
   rotates verbs (race, defend, build, destroy, survive).
10. **Readability.** Each player's colour and portrait is on their stack. The NEXT preview is visible
    for every player. Results show who did what in 3 seconds.

## Architecture rules (see `docs/architecture/composition-guide.md`)

- **Templates are data:** `templates.json` holds rules, params, verbs, the 1v3 offsets, the meter and
  the scene id. No minigame-specific code paths in `main.gd`.
- **Tournament state** (scores, round, players, devices) lives outside the minigame, in the existing
  tournament or modes model. A minigame only emits `round_finished(results)`.
- **Input:** players map to devices at runtime. No hard-coded joypad 0 or 1, and no "p1_*" actions
  baked into the project. Handle `joy_connection_changed` by pausing.
- **Loading:** load the next arena in the background while the 3-second preview plays. Keep arenas
  light, and reuse the stage components (terrain, set-piece actor, cast actor).
- **Shared screen first:** one camera fits all stacks (portrait 720x1280 first). Split-screen only
  where a template needs it, with a per-viewport HUD.
- **Feedback:** a global impact signal drives camera shake, the sparkle FX and audio cues, never
  direct calls from the rules.

## What the teams produce

- **Phase 3 (systems designer):** a handbook entry for each minigame (verb, rules, params, 1v3
  offsets, meter, round length, which campaign beats can host it, and which modules are missing).
- **Phase 4 (level design):** each level that hosts a minigame phase names the template and its story
  reason in `scene.*`.
- **Phase 6 (builder):** the `ModulePhaseRunner`, the per-template arena scenes from the scene kit,
  the input router and the background loader.
