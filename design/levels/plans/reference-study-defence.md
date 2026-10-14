# Reference study: defence boards and story boards

User, 2026-10-14 (`/studio-level-design-lead`): "Investigate the defence images. Look at them closely and study them to get ideas for levels and scenarios."

**Studied by:** the level design lead (main session), with enlarged crops kept in the session scratchpad.
The other 22 mockup boards are covered in `reference-study-mockups.md`.

**Feeds:** the level specs (phase 4) and the mechanics handbook (phase 3) of `campaign-redo-plan.md`.

Note: in this folder, `index.md` lists the wrong titles for style boards 10, 11 and 12. The real contents are:
- 10: Bridge Dash, Fort Blast, Maze Heist, Summit Scramble
- 11: Clockwork Conveyor, Kraken Blockade, Digging Frenzy, Chroma Sky Climb
- 12: Rolling Rumble, Tumbling Towers, Shatter Shootout, Frenzy Footholds

## 1. The five defence panels, close up

| Panel (board) | What attacks | What is defended | What the blocks are | HUD | Camera and staging |
|---|---|---|---|---|---|
| **Kraken Blockade** (11) | A giant kraken. Its tentacles wrap the wall and pull blocks off it. | A sea wall between two round towers on a small grassy island. | The wall itself. New blocks plug the gaps the tentacles open. Cast members fire blocks from a cannon and a wand. | **Boss Health Bar** (top centre), timer, Next block | 3/4 view from the land side, so the threat is *behind* the wall and reads at once. The kraken is huge and fills the back half of the frame. |
| **Fort Blast** (10) | Pirate catapults on the facing cliff. | Your fort on the other side of a sea gap. | **Ammo.** The blocks are lobbed across the gap, and the tile type changes the damage. | **Two Fort HP bars** (yours green, theirs red), a **trajectory preview** box, Next Ammo, a **Block Strength** meter | A split diorama: two cliffs, the sea between them, broken walls in the foreground. |
| **Defend the Fort / Goblins' ambush** (07) | Goblins throwing rocks out of the forest. | A stone tower with a gate. The knight on the top mans a crossbow. | Wooden blocks are **wall patches** on the stone. Each new piece covers a crack. | None (story beat) | Low angle from the attackers' side, so the fort looks under siege. |
| **Fort Frenzy** (09) | The rival team's catapult. | Each team's own castle, made of coloured blocks. | Walls on your side and ammo on theirs. | Per-player scores, timer, Next Block | Symmetrical: two castles face each other across a meadow. |
| **Cyber Defender** (mockup 15) | Virus orbs coming down from space. | A hex reactor with a shield emblem. | Hex cells. A filled cell blocks a shot; holes let damage through to the core. | Lives as hearts, a goal card ("Blast enemies!"), a count "8/15" | Top 3/4 view; enemies hang above the board, so the threat lanes are easy to read. |

### What every defence panel does (the shared grammar)

1. **The threat is a character, not a timer.** The kraken, goblins, catapults and viruses are all visible on stage, with a face or a silhouette. Our `defend_core` rule fires an invisible projectile down a lane.
2. **The thing you defend is a landmark.** A wall between towers, a fort with a gate, a reactor. It is never "the 2×2 centre of the grid".
3. **Blocks have a role you can name**: wall, patch or ammo. The player's choice of *where* to drop is the defence.
4. **Damage shows on the structure itself**: missing blocks, cracks, smoke, rubble falling into the sea. The HP bar backs this up but does not replace it.
5. **The HUD meter is named for the fiction**: Boss Health, Fort HP, Block Strength. It is never "Score".
6. **The cast is working**: manning cannons, holding wands, carrying blocks. Nobody is standing around.
7. **There are two sides of a gap** (sea, chasm, meadow, forest edge), and the camera looks across it.

## 2. What our build lacks against these boards

- `defend_core` has no attacker model and no telegraph *actor*. The warning is a HUD event only.
- The core is abstract grid cells. Nothing on the board looks like a gate, a reactor or a wall.
- There is no ammo role. Blocks can only *be* armour, never *be thrown*.
- There is one HP meter. No enemy-side HP means no counter-attack loop.
- The camera never shows the threat. The scene kit (U17) must place the attacker in the back half of the frame.

## 3. A defence scenario family for falling blocks

These are four play patterns. Each maps to the phase 6 components in `docs/architecture/composition-guide.md`.

| Pattern | Core loop | Win or lose | Components |
|---|---|---|---|
| **D1 Hold the wall** | An attacker strikes a telegraphed lane every N seconds and knocks the top block off. You keep that lane stacked. | You survive K strikes, or the attacker tires and leaves (a story ending). You lose when the wall HP reaches 0. | `defend_core` + `WtSetPieceActor` (attacker) + `WtHudMeter` (Wall HP) |
| **D2 Plug the breach** | Gaps open in a pre-built wall (tentacle pulls, goblin rocks). Only a piece that *exactly* fills the gap seals it. | Seal M breaches before the flood or swarm meter fills. | New rule `breach_plug` (a gap template on the existing wall) |
| **D3 Shield and strike** | Complete rows load the cast's cannon; each full row fires a shot at the attacker. | Bring the Boss HP to 0. Lose when the Fort HP reaches 0. | `BossComponent` + `defend_core` + a row-clear event that triggers the cannon |
| **D4 Shelter the guest** | A guest (kid goat, penguin chick, baby kraken) stands on the board. You must keep a roof of blocks over them through K hazard waves. | The twist ending: the "attacker" was chasing the guest home, and you open a path to let it go. | `GoalSequence` (phase 1 shelter, phase 2 reveal), `WtCastActor` |

**Fairness (U7 corridor rule):**
- Every strike lane is warned at least 2 s ahead with an *actor* telegraph (the tentacle rises, the catapult arm cranks back), and at least 4 s in intensity 1–2 biomes.
- No lane may be a dead-end channel under 3 cells wide.

## 4. Defence ideas per biome (campaign, in story order)

Each idea gives the hook, the scene, how it plays and the non-obvious ending. **Bold** marks the reference panel behind it.

| Biome | Idea | Pattern | Ending twist | Themed meter |
|---|---|---|---|---|
| Meadow | **Goblins' ambush** → *"Fence the Flock"*: crows peck the sheep pen; you stack fence blocks on the lane each crow dives at. | D1 | The crows only want the scarecrow's hat. Build the scarecrow high enough and they leave. | Pen Strength |
| Candy | *"Gumdrop Gate"*: sugar ants march on the cake gate and nibble one block per lane. | D2 | The ants are carrying the lost sprinkles home. Seal everything except the ant-sized path. | Frosting |
| Ice | **Tumbling Towers** + defence → *"Penguin Shelter"*: icicles fall from a cliff onto a penguin chick. | D4 | The chick hatches mid-level; the shelter now has to fit two. | Warmth |
| Underwater | **Kraken Blockade** → *"Reef Wall"*: tentacles pull blocks from the reef wall. Seal breaches. | D2 → D3 | The kraken is reaching for its lost baby trapped behind the wall. You free it, and the boss leaves as an ally. | Reef HP / Kraken calm |
| Lava | **Molten Guardian** + **Fort Blast** → *"Forge Siege"*: the guardian lobs magma at your heat shield; full rows cool and fire the quench cannon. | D3 | Last phase: the shield stones you placed become the guardian's new crown, and it calms. | Heat / Guardian HP |
| Forest | **Defend the Fort** directly → *"Goblin Gate"*: goblins throw rocks at the tower; wooden blocks patch the stone. | D1 | The goblin chief joins the cast after the fort survives three waves. | Fort HP |
| Cave | *"Mine Cart Barricade"*: runaway carts hit a lane; you stack buffers. | D1 | One cart carries Boulder's lost tools. Let it through (an open lane) to win early. | Timbers |
| Clockwork | **Bomb Defuse** + D3 → *"Gearlock Siege"*: rows wind the clock cannon against a rogue automaton. | D3 | The automaton is just running late; finish its clock face and it stands down. | Spring tension |
| Neon | **Cyber Defender** → *"Firewall"*: virus orbs dive at the hex core; you fill the hex cells to block them. | D1 hex-flavoured | Final wave: the virus spells a message. Leave the right holes to answer it. | Firewall % |
| Celestial | *"Comet Shield"*: shards rain from a comet onto the observatory dome. | D4 | The shards are star-seeds. Catch three in cups instead of blocking them all. | Dome integrity |
| Pirate | **Fort Blast** + **Shatter Shootout** → *"Broadside"*: two ships trade volleys; complete rows load your cannons. | D3 | Last volley: both crews run out of ammo, and the final block you place is the white flag. A truce ending. | Hull HP ×2 |
| Carnival | **Fort Frenzy** → *"Coconut Shy Siege"*: the ringmaster's prize stall fires plush balls. | D1 + D3 | The boss's "fort" is a prize tower. Topple it to win the bonus. | Ticket bank |

## 5. Ideas from the story boards (01, 02, 07)

- **The wizard's book as a level frame:** levels can open with the tome page showing the place, then the camera dives in (boards 01 and 07). This is good for the opening event field.
- **The cart convoy (board 01, "Explore the biomes"):** a recurring *carry* level. Stack the cargo on a moving cart and keep it balanced over bumps (balance meter, as in 07 "Balance & physics").
- **The balance plate with wind (board 07):** a tilt platform plus a visible wind spiral. The meter changes from green to red, labelled "Danger". It suits the ice, celestial and pirate tutorials.
- **The Forge Boss (board 02):** a boss level with a thermometer meter (45° to −35°) and a boss bar. Hot and cold blocks change the reading. This is a twin-meter boss.
- **The Cosmic Gateway (board 02):** a glass tower on a hex dais while lasers sweep. Blocks are portals. Good for a late celestial level.
- **Canopy Chaos (board 02):** monkeys throw acorns at a jeep carrying stacked stone blocks. A *moving defence*: protect the cargo, not a fort.
- **The tournament arena (board 01):** rival towers with cannons and crowds. Use it for the carnival finale staging.

## 6. Questions for the level specs (phase 4)

1. Does D3 (row clear loads a cannon) count as a "clear N layers" goal under the user rule? Proposed answer: **no**. The goal is the boss HP, and rows are only ammo. The headline names the boss, never a row count.
2. Which biomes take a full defence level, and which only a defence phase inside a `GoalSequence`? Proposed: **at least 1 full defence level per biome**, with no more than 2 per biome, so defence stays one flavour among many.
