# Biome Bible (gameplay) — Wacky Towers campaign

> **Status**: Draft v1 (world-builder). **Canon Level**: Provisional (everything here awaits narrative-director + user approval; the meadow facts from `design/levels/meadow.md` and `design/gdd/campaign-structure.md` are Established and are not changed).
> **Visible To Player**: Discoverable (stories surface through level intros, mascot reactions and the map).
> **Source**: `production/session-state/active.md` (rounds 1-4), `design/levels/meadow.md`, `design/gdd/mechanics-catalog.md`, `level-specific-mechanics.md`, `twist-library.md`, `tournament-minigames.md`, `campaign-structure.md`.
> **Scope**: gameplay only. No visuals, no player-facing text. Every number is a tunable default.
> **Atom IDs**: `design/gdd/mechanics-module.md` did not exist when this was written. Atoms use catalog IDs (C = clear rule, A = arrival, B = board, G = goal, P = physics, M = level mechanic) and the names of the existing twists/mechanics (Wind, Spawned Objects, Invisible Blocks, Gravity Flip, Conveyor, Sticky Landing, Build Race, Target Shape, Junk Rain). Atoms marked **(new)** are proposed here and must be added to the module. Re-map the names to module IDs when it lands.
> **Contradictions Check**: Consistent with the 10-biome order, the meadow levels, the twist cap (2, finale 3), one callback per level, the wacky test, always-competitive minigames and sabotage everywhere. One catalog hint is re-mapped: the catalog suggests a "Desert" home for M7 Mono Layer and M10 Slide-In; there is no desert biome, so Mono Layer goes to Candy and Slide-In to Forest.

**Flags to game-designer (mechanical implications, not decided here):** Ice Slide, Floaty Cubes, Light Radius, Critter Walker, Rule Cubes, Gravity Wells, Cog Lock and Tidiness Mood all need a rules definition before any level uses them. Flags to level-designer: each ramp row below is a seed, not a spec.

---

## 0. Order and geography

**Order kept: Meadow, Candy, Forest, Underwater, Ice, Cave, Lava, Clockwork, Neon, Celestial.** No change proposed. Reasons it works as a journey:
- It reads as a trip *out of the sunny home island*: a sweet detour (Candy, a sugar-spun neighbour island), then wild nature (Forest), then down into water, cold, rock and fire (the world's cool-to-hot ladder: Ice before Cave before Lava gives "thaw then deeper then hot").
- Underwater sits between Forest (a river runs out of it) and Ice (the sea freezes at its far end).
- Cave and Lava are one descent; Lava's heat is what powers Clockwork (the forge-city above the magma), and Neon is the clockwork city's night side, switched on. Celestial is the only place left to go: up.
- Gameplay check: the two "floaty" biomes (Underwater, Ice) are not adjacent in feel (one sways, one slides); the two dark/descent biomes (Cave, Lava) are split by different verbs (carve vs. melt). No swap needed.

**Block weather, world-wide.** Blocks fall because every biome has its own sky: a weather that "rains" blocks. The weather is also the biome's twist-presentation: every twist is the biome's own named event. Events remix into later biomes (section 4).

---

## 1. Mascot contract (all biomes)

Four temperaments, assigned per level *and* per difficulty. The mascot never changes the rules of a level; it changes the *texture* (and on the hard track, a bit of the pressure).

| Temperament | What it does to the tower | Typical when |
|---|---|---|
| **Helper** | Nudges you: pre-glows the best cell, catches one dropped cube, huddles/shields for a lock | Tiers 1-3, the easy path, first retry after a fail |
| **Prankster** | Swaps a piece's colour, bumps a cube one cell, steals a hat-block, then gives it back; always telegraphed, always funny | Tiers 4-8, normal path |
| **Mood swing** | Mood follows tidiness (section 4): happy mascot = helper actions, grumpy = prankster actions, furious = it throws a cheeky junk cube that you can clear | Tiers 5-9 and any hard-track level |
| **Watcher** | Never touches the board; pure reaction, commentary, and a scoreboard of your silly failures | Tutorials, build races, puzzle levels, bonus levels where precision matters |

**Default by difficulty** (three settings, per biome, same shape): Easy path = Helper + Watcher only. Normal = Helper, Prankster, Watcher mix by tier band (1-3 helper, 4-6 prankster, 7-9 mood swing, 10 the finale boss). Hard track (★★★ target runs, bonus level) = Mood swing + Prankster, Helper off. Every mascot action is a data-driven "event card" so a level just lists which cards are on.

---

## 2. The ten biomes

Each entry: mini story, quirk, block weather, mascot, atoms owned, borrowed/remixed, finale, ramp. Tier rule: **1-2 introduce the quirk, 3-8 complicate (one new idea each, with remixes), 9 hard remix, 10 finale.** Ramp rows are seeds for the level-designer, one line each (every level is a tiny story).

### 2.1 MEADOW (Established; see `design/levels/meadow.md`)

**Mini story: Pip's Picnic** (per `biome-stories.md`). Pip the harvest mouse wants a picnic on the hilltop. The Miller, a flour-dusted badger who likes his mill quiet and his gusts loud, rigs the mill to blow gusts, toss mushrooms, fog the grass and finally flip the hill. The finale bonks him off his roof into a flour cloud; he stomps off vowing a rematch. Keepsake: a tiny windmill.
- **Quirk: "Gentle weather."** One visible disturbance at a time, learned slowly. Plain layer clears are the home base; the biome is the most classic (about 85%), but strangeness zig-zags per level rather than rising in a straight line.
- **Block weather:** block drizzle from a sunny sky.
- **Mascot: Pip** (Meadow only). Small help on tiers 1–3 (points at a good cell, catches one bad drop per level); reactions only from tier 4 on. The Miller is visible on the hill from 03 and is the boss in 10.
- **Islands:** one per level, shaped by the story (seed plot, burrow, hillside lane, pond ring, hilltop, garden bed, foggy hollow, dewy lawn, tree island, mill yard).
- **Atoms owned:** Wind (Dandelion Gust), Spawned Objects (Mushroom Pop-up), Invisible Blocks (Morning Fog), Gravity Flip (Topsy Tumble), Conveyor (Mill Belt), Sticky Landing, Build Race (trim), Target Shape, Survive. Proposed living blocks and special pieces: puff pieces (SP28), wobble (PL03, the Meadow's one physics level), growing sprouts (SP22), fog ghost (SP26), hatching eggs (SP21); hard track adds ants (SP31) and two fields (BL07).
- **Borrows:** nothing.
- **Finale: two-phase boss duel** (the Miller): phase 1 belt + gusts; after two clears he flips the hill for the last clear (Conveyor + Wind + Gravity Flip).
- **Hard track:** bonus Picnic Puzzle (fixed list, the ants arrive in 60 s) and three remixes: Seed Sprouts, Picnic Ants, Two Fields.
- **Ramp and sketches:** `production/levels/meadow/layout.md` (levels 01–10, bonus, H1–H3). Use it as the template for ramps below.

### 2.2 CANDY

**Mini story.** The Gumdrop Gang's sugar-spun island is sticky with spilled syrup, and the great Cake Tower for the festival is half built. Stack it before the sprinkles melt, and do not let the Sugar Rush catch the gang.
- **Quirk: "Colour matters."** Block colour becomes a rule for the first time. Layers still clear, but matching colour groups pop too. Sweet, readable, still Tetris-shaped.
- **Block weather:** Sprinkle Shower (1-cube sprinkle pieces fall between the big blocks; they can be cleared as free bonus).
- **Mascot:** Gumdrop, a gummy-bear-type critter. Temperament: **mood swing** (sugar rush: eats the sprinkles it likes, gets hyper, speeds the fall slightly; calms when the stack is tidy). Helper in 01-03, watcher in puzzle levels.
- **Atoms owned:** Colour Pop (C1), Mono Layer (M7), Jelly Blocker (new: a licorice/jelly cube that only clears when a neighbour pops or clears; the Candy Crush blocker), Syrup Puddle (new: a floor cell where landing takes 1 extra beat, a soft gate on placement), Sugar Rush (new: a timed speed-up burst from the mascot, telegraphed).
- **Borrows:** Sticky Landing (Meadow, as a syrup variant), Wind (as a cotton-candy breeze), Target Shape (jar-filling).
- **Finale: transformation.** The tower becomes the cake: the last clears *decorate* it (colour groups become icing) and the mascot jumps out of the top.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Sugar Cube | Classic layer clear; colours present but unused; syrup puddle teased |
| 2 | Pop! | First Colour Pop on a tiny board (pop 6); layers still work |
| 3 | Licorice Locks | Jelly Blocker: neighbours free it |
| 4 | Mono Monday | Mono Layer bonus; sprinkle weather opens |
| 5 | Taffy Pull | Build Race + Syrup Puddles (no clear; trim) |
| 6 | Jelly Jar | Target Shape: fill the jar with a colour pattern |
| 7 | Sugar Rush | Survive; mascot mood swing speeds the fall in bursts |
| 8 | Gummy Garden | Colour Pop + jelly blockers, ring-shaped board |
| 9 | Chocolate Fountain | Remix: Colour Pop cascade + syrup + cotton-candy breeze |
| 10 | Cake Tower | Transformation finale |

### 2.3 FOREST

**Mini story.** Night is coming to the Great Hollow and the forest folk are stranded on the wrong side of the stream. Build them paths and bridges before dusk; the trees grow whether you want them to or not.
- **Quirk: "Living board."** Things in the forest move and grow on their own: walkers cross your stack, saplings sprout, pieces come in from the side. Clears become *rows*, not just layers.
- **Block weather:** Acorn Rain (heavy acorn pieces that sprout into saplings).
- **Mascot:** a fox kit. Temperament: **prankster-helper** (steals one block and returns it in a worse place, but guards the walkers). Watcher in build races, helper in walker levels.
- **Atoms owned:** Row Clear (M8/C4), Slide-In (M10/A2), Critter Walker (G2 Mascot Path, new as a campaign goal: build a walkable route, a Lemmings-style crossing), Sapling Growth (new: a cube that grows +1 height every N locks until cleared), Hidden Gem (new: a secret gem visible only from certain camera angles; uses the 12 snap angles).
- **Borrows:** Spawned Objects (Mushroom Pop-up to Acorn Pop-up), Invisible Blocks (as canopy shade), Wind (leaf gusts), Target Shape.
- **Finale: escape.** Guide the stranded folk to the treetop before dusk finishes; the owl is the shadow (watcher) that pulses the shade.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Mossy Start | Classic, meadow critter cameo, colours/leaves re-teach |
| 2 | Row, Row | Row Clear on a small board |
| 3 | Branch Slide | Slide-In: timing verb; gentle |
| 4 | Fox Walk | First Critter Walker: one walker, short route |
| 5 | Sapling | Build Race with growing saplings (trim) |
| 6 | Canopy Shade | Row Clear + shade patches hide columns |
| 7 | Gem Hunt | Hidden Gem: rotate the camera to find the clear target |
| 8 | Beaver Dam | Target Shape on a river lane; walkers cross it |
| 9 | Great Hollow | Remix: Row Clear + Slide-In + walkers + saplings |
| 10 | Owl's Dusk | Escape finale |

### 2.4 UNDERWATER

**Mini story.** A storm sank the cuddly Kraken's treasure and its pearl-collecting crew. Rebuild the reef town from the seabed while the tide sloshes everything sideways and blocks drift upward.
- **Quirk: "Nothing falls straight."** Gravity is a current. Pieces arrive from the side and some cubes float up. Colour pops cascade like bubbles.
- **Block weather:** Bubble Rain (blocks fall slowly in bubbles; cubes in bubbles drift sideways).
- **Mascot:** a pufferfish. Temperament: **mood swing** (puffs when stressed, bumps neighbours; deflates and helps when the stack is tidy). Watcher in pearl levels.
- **Atoms owned:** Sideways Gravity (M9/A1), Colour Pop with cascade (C1 + cascade), Floaty Cubes (new: bubble cubes rise one cell per N seconds and pop at the ceiling), Tide (new: a periodic push of the whole board's falling piece; Wind's cousin that reverses direction), Pearl Dig (G4 Dig Out: free the pearl from the seabed).
- **Borrows:** Row Clear (Forest), Gravity Flip (as a Whirlpool), Mono Layer (Candy), Target Shape.
- **Finale: boss duel** with the Kraken: it hugs the tower, swirls the current, and drops treasure chests (spawned objects). The final clear pops it out of the water like a cork.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Shallows | Classic; bubbles float for show |
| 2 | Bubble Pop | Colour Pop cascade on a small board |
| 3 | First Current | Sideways Gravity on a lane |
| 4 | Seaweed Sway | Tide: a periodic push of the falling piece |
| 5 | Pearl Dive | Pearl Dig: free the pearls from shell blocks |
| 6 | Float On | Floaty Cubes with Build Race (no clear; trim) |
| 7 | Whirlpool | Gravity Flip as a whirlpool plus sideways gravity |
| 8 | Sunken Ship | Target Shape: re-fill the hull under currents |
| 9 | Reef Rush | Remix survive: sideways, bubbles, tide |
| 10 | Kraken's Cuddle | Boss duel |

### 2.5 ICE

**Mini story.** The penguin parade is late: the sea froze overnight and the festival float is stuck on a floe. Everything slides. Build a ramp-to-the-parade before the floe cracks.
- **Quirk: "Slippery."** Pieces and cubes slide. The grid is still the grid; the surprise is where a piece *ends up* after it lands.
- **Block weather:** Snowfall (soft snow cubes that pile on the top layer and melt when a clear happens below).
- **Mascot:** a penguin. Temperament: **prankster** (belly-slides into a piece, gives it a shove) with a **helper** huddle that stops one slide per level. Watcher on the build race.
- **Atoms owned:** Ice Slide (new: a landed piece glides along its last move until blocked or 2 cells), Frost Block (new: frozen cube thawed by an adjacent clear; the Candy blocker remixed), Crumbling Edge (B2), Wobble Meter (P2: overhangs slip one cell), Pillar Clear (C5, optional).
- **Borrows:** Colour Pop (Candy), Critter Walker (Forest; penguins), Wind (blizzard), Spawned Objects (as snowdrifts), Target Shape.
- **Finale: race** (the "something else"): a rival penguin builds its own tower on a mirrored floe; both fill the ramp. You see its progress as a ghost silhouette; the first to finish wins; sabotage is the mascot's big slide. A deliberate non-boss finale.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Frosty Start | Classic with one gentle slide |
| 2 | Slip 'n Slide | Ice Slide on a wide board |
| 3 | Snowdrift | Snow cubes that melt when a clear happens |
| 4 | Frozen Cubes | Frost Blocks: free them via adjacent clears |
| 5 | Thin Ice | Crumbling Edge shrinks the board; Survive |
| 6 | Icicle Tower | Build Race with Wobble Meter (overhangs slip) |
| 7 | Snowman Shape | Target Shape snowman while sliding |
| 8 | Penguin Parade | Critter Walker on ice (penguins slide) |
| 9 | Blizzard | Remix: slide, frost, wind, crumble |
| 10 | Floe Race | Race finale vs. the rival penguin |

### 2.6 CAVE

**Mini story.** Pickaxe Pip's mine has collapsed with the miners inside. Light the lamps, dig toward the voices, and build a way across the chasms before the dark closes in.
- **Quirk: "Dark and digging."** You can't always see; you reverse the direction of play (clear *down* to dig someone out). Carve levels turn the game inside out.
- **Block weather:** Rockfall (stalactite pieces drop as 1-cube junk between pieces).
- **Mascot:** a mole (or bat). Temperament: **watcher** by default (a lantern companion); **helper** lights the next landing cell; **prankster** on hard tracks blows the lantern out for 2 seconds (always telegraphed).
- **Atoms owned:** Light Radius (new: only cubes near the lantern are visible), Dig Out / Carve (G4: clear downward to free a buried critter; a reverse-level atom), Rockfall (Junk Rain), Colour Bridge (M6/C2: join two posts over a chasm), Echo Ping (new: a tap lights hidden cubes for 2 s).
- **Borrows:** Invisible Blocks (as darkness), Conveyor (mine cart), Colour Pop (crystals), Target Shape.
- **Finale: escape.** The cave is collapsing behind you; the ceiling lowers (G5 Sinking Ceiling) while you dig *up* through the stack. The mascot lights the exit.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Cave Mouth | Classic by lantern light; full visibility |
| 2 | Lantern | Light Radius intro on a small board |
| 3 | Rockfall | Junk from above (Junk Rain) |
| 4 | Dig Out | First carve level: free the buried miner |
| 5 | Echo | Light Radius + Echo Ping; Survive |
| 6 | Chasm Bridge | Colour Bridge over a gap |
| 7 | Crystal Vein | Target Shape of crystals with Light Radius |
| 8 | Mine Cart | Conveyor in a lane (callback) + carving |
| 9 | Deep Dark | Remix: darkness, rockfall, bridge |
| 10 | The Collapse | Escape finale |

### 2.7 LAVA

**Mini story.** The Forge Foreman's kiln has burst: the magma is rising and the island is cooling into obsidian only where you keep clearing. Build steps up the volcano faster than the floor melts.
- **Quirk: "The floor is going."** A hot floor or heat timer pressures the player to keep the stack *high and tidy*. Clearing is cooling: cleared layers turn to obsidian.
- **Block weather:** Ember Drizzle (glowing ember cubes that settle on the stack and ignite adjacent cubes if left for N locks).
- **Mascot:** a salamander (or lava slug). Temperament: **mood swing** (the hotter the stack, the angrier: grumpy flickers more embers, content cools cubes). Becomes the **boss** in the finale.
- **Atoms owned:** Lava Floor (B4: bottom layer melts every N seconds), Hot Block (new campaign form of MG14: a glowing piece that scorches a layer unless cleared away in time), Obsidian Cool (new: cleared layers harden into permanent safe cubes), Eruption (Junk Rain burst, telegraphed), Stack Trim (P1: overhangs snap off).
- **Borrows:** Survive, Sticky Landing (hot syrup), Gravity Flip (quake), Spawned Objects (embers), Critter Walker (Forest: fireflies hopping lava stones).
- **Finale: boss duel** with the Lava Golem (it throws Hot Blocks, stomps to eruptions; winning clear freezes it into a statue).
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Warm Rocks | Classic, floor stable, sparks only for show |
| 2 | Melting Floor | Lava Floor on a tall board |
| 3 | Hot Potato | Hot Block: clear it before it scorches |
| 4 | Obsidian | Obsidian Cool: clears build safe floor |
| 5 | Eruption | Survive: telegraphed eruptions |
| 6 | Stepping Stones | Critter Walker path across lava (callback) |
| 7 | Overhang | Stack Trim: overhangs snap off |
| 8 | Magma Forge | Build Race on a rising lava floor |
| 9 | Volcano | Remix: floor melt, hot blocks, eruptions |
| 10 | Golem Duel | Boss duel |

### 2.8 CLOCKWORK

**Mini story.** The Great Clock of the sky-city has stopped, its gears scattered across belts and turntables. The clockwork owl needs a perfect, on-time stack to restart the chime.
- **Quirk: "Everything is on a schedule."** The board moves in predictable cycles (belts, turntables, two chutes). Planning ahead matters more than reacting.
- **Block weather:** Cog Rain (gear-shaped pieces fall on a metronome).
- **Mascot:** a clockwork mouse or cuckoo bird. Temperament: **watcher** (counts beats aloud), **helper** on gentle tiers (nudges one cog), **prankster** (runs the belt back a step, telegraphed).
- **Atoms owned:** Turntable (B1: every N locks the stack rotates 90 degrees), Two-Way Meet (M11/A3), Conveyor (multi-belt: two belts, opposite directions), Crane Drop / Pendulum (P3: a swinging piece you release), Cog Lock (new: cubes held by gears release on a beat).
- **Borrows:** Conveyor (Meadow, remixed), Slide-In (Forest, timing), Row Clear, Colour Bridge, Target Shape.
- **Finale: transformation.** The stack *is* the clock: the last clears click the gears into place and the tower becomes the Great Clock; the owl chimes and the tower tilts into the skyline.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Tick | Classic with a metronome beat |
| 2 | Cog Row | Conveyor callback with tidy rows |
| 3 | Turntable | Turntable every N locks |
| 4 | Two Belts | Two Conveyor rows, opposite directions |
| 5 | Pendulum Drop | Crane Drop: release a swinging piece; Build Race |
| 6 | Meet in the Middle | Gentle Two-Way Meet |
| 7 | Cog Lock | Cog Lock: cubes release on a beat |
| 8 | Assembly Line | Target Shape: a gear train |
| 9 | Grand Mechanism | Remix: turntable, belts, meet |
| 10 | Master Clock | Transformation finale |

### 2.9 NEON

**Mini story.** The Arcade at the edge of the clockwork city powered on in the night: glowing rules, glitches and a beat that never stops. A mischievous ghost-cat is rewriting the rules on purpose. Win the DJ duel to bring the lights back to normal.
- **Quirk: "Rules are blocks."** A rule can be placed, broken, or swapped. Beat and rule-bending become the verb.
- **Block weather:** Static Storm (pieces flicker through two colours; the rule card of the moment changes the look).
- **Mascot:** a pixel ghost-cat. Temperament: **mood swing / prankster** (it rewrites a rule on a beat when pleased or irritated; the player can feed it a combo to calm it). Helper in tutorial tiers, watcher in puzzle levels.
- **Atoms owned:** Rule Cubes (new, Baba-style: a special cube carries a rule card, e.g. "red clears like a row", while it stays on the stack), Beat Drop (new: a lock on the beat gives a bonus), Glitch (new: a random rule swap on a 30 s timer, forecast), Twin Drop (A5: two linked pieces), Twin Towers (B3: two small boards, if readable).
- **Borrows:** Colour Pop, Colour Bridge, Turntable, Two-Way Meet, Invisible Blocks (as flicker), Target Shape.
- **Finale: boss duel** (a rhythm duel against the arcade cabinet's rival: both of you build on the beat; sabotage is a rule swap).
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | Boot Screen | Classic with beat pulses |
| 2 | Beat Drop | Lock-on-beat bonus |
| 3 | First Rule | Rule Cube: one visible rule card |
| 4 | Glitch | Timed rule swap with forecast |
| 5 | Twin Drop | Two linked pieces |
| 6 | Pixel Bridge | Colour Bridge with rule cubes |
| 7 | Twin Towers | Two small boards (or the readable fallback) |
| 8 | Power Surge | Survive on beat |
| 9 | Overclock | Remix: rule cubes, glitch, twin |
| 10 | DJ Duel | Boss duel |

### 2.10 CELESTIAL

**Mini story.** The Moon Rabbit's lantern has gone out and the stars have fallen off the sky. Rebuild the constellations; up and down are optional, and every biome's weather has drifted into orbit.
- **Quirk: "No up."** Gravity is an event. Pull, orbit and drift change where "down" is, and the stack is also a picture the sky is trying to read.
- **Block weather:** Meteor Shower (blocks arrive from every side, falling toward a moving centre).
- **Mascot:** the Moon Rabbit. Temperament: **watcher** who becomes **helper** as the player masters earlier biomes (it plays back earlier mascots as guests), **prankster** only on moon-phase tiers.
- **Atoms owned:** Gravity Wells (new: a cell that pulls pieces toward it; uses the 6-direction board), Shadow Match (G1: build so the stack casts the shown silhouettes), Constellation Clear (new: connecting star cubes in a pattern clears them; Colour Bridge's cousin), Meteor Shower (Junk Rain from all sides), Moon Phase (new: rules cycle each phase with a forecast).
- **Borrows:** One callback weather from every earlier biome (the "remix" biome), including Sideways Gravity, Hidden Gem, Rule Cubes, Turntable, Frost, and the Mascot Path.
- **Finale: transformation** (grand remix). The final tower *becomes* a constellation; each earlier weather appears once as a star event, the Moon Rabbit relights the sky.
- **Ramp:**

| T | Seed | What it adds |
|---|---|---|
| 1 | First Star | Classic one last time (a nostalgia level) |
| 2 | Low Gravity | Slow fall and drift |
| 3 | Gravity Well | A single well pulls pieces |
| 4 | Meteor Shower | Junk from all sides |
| 5 | Constellation | Constellation Clear |
| 6 | Shadow Match | Silhouette goal |
| 7 | Moon Phase | Rules cycle by phase, forecast on the HUD |
| 8 | Comet Rider | Sideways + wells, Survive |
| 9 | Eclipse | Remix of all weather with a callback each |
| 10 | Big Bang | Transformation finale |

---

## 3. Campaign variety curve

**Definition.** "Classic share" = the fraction of a biome's play time spent on classic play: falling pieces from the top, one board, whole-layer clears, normal gravity. The meadow is the most Tetris-like (the user's brief); later biomes lose classic share by adding new board shapes, goals, verbs, clear rules and arrival styles. Numbers are targets for design, not measurements.

| Biome | Classic share | Board shapes | Goals | New verbs | Clear rules | Arrival styles |
|---|---|---|---|---|---|---|
| 1 Meadow | **85%** | square, lane, ring, plus | Clear, Height, Shape, Survive | drop, spin, tilt, roll | layer, slice | top |
| 2 Candy | 72% | + jar, ring | + colour | + colour read | + Colour Pop, Mono Layer | top |
| 3 Forest | 60% | + river lane | + route (walker) | + timing, rotate camera to find | + Row Clear | + Slide-In |
| 4 Underwater | 50% | + tall tank | + dig out | + currents, floaty | + cascade | + Sideways |
| 5 Ice | 42% | + shrinking floe | + race (non-boss) | + sliding | + Pillar Clear (opt.) | top, slide |
| 6 Cave | 33% | + chasm gap | + carve down | + dark play, ping | + Colour Bridge | top, side |
| 7 Lava | 26% | + melting floor | + out-pace the floor | + heat management | + obsidian cooling | top, slide |
| 8 Clockwork | 19% | + turntable board | + assemble | + planning on cycles | + schedule-clears | + Two-Way Meet |
| 9 Neon | 12% | + twin boards | + rule play | + rule cubes, beat | + rule-modified clears | + Twin Drop |
| 10 Celestial | 8% | + 6-direction orbit | + silhouette, constellation | + gravity events | + Constellation | all, with moving centre |

```
classic share
 85 |#
 72 |#  #
 60 |#  #  #
 50 |#  #  #  #
 42 |#  #  #  #  #
 33 |#  #  #  #  #  #
 26 |#  #  #  #  #  #  #
 19 |#  #  #  #  #  #  #  #
 12 |#  #  #  #  #  #  #  #  #
  8 |#  #  #  #  #  #  #  #  #  #
     Me Ca Fo Un Ic Ca Lv Cl Ne Ce
```

**Rules of the curve.**
- Every biome's tier 1 is a classic level in the biome's clothes (the classic share never reaches zero; Celestial's tier 1 is a deliberate nostalgia beat).
- A biome adds at most **one** new axis per tier (board, goal, verb, clear rule or arrival).
- A biome may remix older axes (callback, at most one per level by default).
- The classic share falls by about 6-13 points per biome, steeper in the middle where players are warmed up, and shallower at the end so the last biomes feel like a remix, not a wall.
- Failure stays low on the main path: new axes are introduced in short, forgiving levels.

**Per-biome 10-tier pattern.**

| Tiers | Purpose | Shape |
|---|---|---|
| 1-2 | Introduce the quirk | Short (2-4 min), forgiving; tier 1 classic in biome clothes |
| 3-8 | Complicate | One new idea per tier with remixes between; alternate long and short; at least one build/shape/survive breather (like meadow 05, 06, 08) |
| 9 | Hard remix | Longest and hardest of the main path (the one callback weather + two biome atoms) |
| 10 | Finale | Boss duel, transformation, escape, race, or a rhythm duel |
| 11 (bonus) | Wackiest level, hard track | Unlocked at 20 stars; fixed-list or puzzle-like |

**Finale variety (no two neighbours the same):** Meadow boss duel, Candy transformation, Forest escape, Underwater boss duel, Ice race, Cave escape, Lava boss duel, Clockwork transformation, Neon rhythm duel, Celestial grand transformation.

---

## 4. World rules (all biomes)

The four rules below apply in every biome; each biome expresses them differently. These are world-builder definitions of the intent. Mechanics are decided by game-designer.

1. **Tidiness mood.** The biome mascot's mood follows how tidy your tower is (low holes, a flat top). It is mostly expressive (reactions), and becomes mechanical only on the hard track (mood swing). *Fun-only on the easy path.*
2. **Visiting mascots.** Mascots from finished biomes can pop in as guests (a cameo, a one-time helper, a funny interruption). Visiting grows with progress, and Celestial hosts all ten.
3. **Junk comes back.** Junk you clear is recycled by the weather: swept to the island edge and re-thrown by the biome's event, so "cleaning" has a funny consequence rather than permanent victory. Total junk per level is capped so it never snowballs.
4. **Weather forecast.** The next event is announced one piece or one beat ahead (a tiny sky icon), so every event is readable (*Readable Chaos*). A forecast is also a skill: good players use it to set up.

| Biome | Tidiness mood | Visitors (from earlier) | Junk that comes back | Forecast | Event that remixes later |
|---|---|---|---|---|---|
| Meadow | Critter's ears perk or droop | none (it is the host) | Mushrooms regrow at the edge | Arrow + bending grass | Dandelion Gust returns as breeze in Forest and Ice |
| Candy | Gumdrop's sugar level | Meadow critter | Sprinkles re-rain | Tint of the next sprinkle | Sugar Rush returns in Neon as Power Surge |
| Forest | Fox's tail | Gumdrop, critter | Acorns re-sprout | Leaf-fall direction | Walkers return in Ice, Lava and Celestial |
| Underwater | Pufferfish size | Fox, Gumdrop | Bubbles re-float | Bubble trail | Tide returns in Celestial as orbit drift |
| Ice | Penguin posture | Pufferfish, Fox | Snow re-piles | Snow-flurry intensity | Frost returns in Cave and Lava |
| Cave | Mole's lantern glow | Penguin, Pufferfish | Stalactites re-form | Drip rhythm | Light Radius returns in Neon as glitch |
| Lava | Salamander glow | Mole, Penguin | Embers re-settle | Glow pulse | Hot Block returns in Neon and Celestial |
| Clockwork | Mouse winds the key | Salamander, Mole | Spare cogs return to the belt | Ticking hands | Turntable returns in Neon and Celestial |
| Neon | Ghost-cat brightness | Mouse, Salamander | Glitch blocks reappear | Pixel countdown | Rule Cubes return in Celestial |
| Celestial | Moon Rabbit's lantern | All nine | Stars fall back | Moon phase icon | All remix here (finale) |

---

## 5. Minigame zones

Each biome has a **zone**: a tournament arena in the biome's style, separate scenes, always competitive, sabotage in every minigame. Minigames have **freedom**: they may skip layer clears and grid placement entirely, so minigame zones are where the classic share is lowest. Existing minigames from `tournament-minigames.md` are placed (MG numbers); new concepts are proposed in italics.

| Zone | Home MGs (existing) | New minigame concept (proposed) | Sabotage flavour |
|---|---|---|---|
| Meadow Fair | MG4 Perfect Stack, MG11 Memory Tower | *Seed Spitting Stack:* stack by timing a dandelion puff | Gust blows rival's piece |
| Candy Carnival | MG3 Colour Rush, MG9 Speed Sort | *Sprinkle Scramble:* catch the right-coloured sprinkles into your jar | Sticky Syrup on a rival's tray |
| Forest Glade | MG6 Mascot Bridge Race | *Walker Dash:* build a bridge for your own critter; first across wins | Fox steals a bridge block |
| Underwater Lagoon | MG15 Catch Tower | *Bubble Stack:* floaty cubes; keep yours below the ceiling | Current shoves rival's piece |
| Ice Rink | MG1 Hole in the Wall | *Curling Tower:* slide a piece to land on the target | Slippery Floor for a rival |
| Cave Dig | MG7 Box Packers | *Tunnel Race:* dig out your lane first | Rockfall on a rival |
| Lava Arena | MG13 Floor Is Lava, MG14 Hot Block | *Hot Potato Tower:* a Hot Block circulates between players | Eruption splash |
| Clockwork Plaza | MG12 Spin Cycle, MG5 Crane Tower | *Gear Heist:* build to a beat, steal cogs | Belt reversal |
| Neon Arcade | MG2 Copycat, MG10 Shadow Duel | *Rule Roulette:* a shared rule card changes each round; build under it | Rule swap on a rival |
| Celestial Observatory | MG8 Gift Exchange | *Orbit Duel:* both players' towers share a gravity well | Meteor shower on a rival |

Zone unlock follows the biome (a zone opens when its biome is complete). Zones are also themed arenas for seasonal events (takeover reskin).

---

## 6. Open items for approval

- Mascot species and names are working (narrative-director + art-director).
- The "classic share" numbers are targets to tune from playtests.
- All new atoms need a rules definition in the mechanics module before any level uses them.
- Tidiness Mood and Junk Comes Back need game-designer definitions (kept cosmetic on the easy path).
