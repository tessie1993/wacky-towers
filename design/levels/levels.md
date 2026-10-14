# Levels: Chapter 1 (Meadow) arc frame

Status: FRAME, revision 2. Author: game director. Date: 2026-10-14.
Scope: the first 12 campaign levels in play order: meadow_01 to meadow_10, meadow_bonus, meadow_h1.
Later frames cover meadow_h2 and meadow_h3 and the other chapters.
Revision 2 follows the user's answers: describe each level as a game builder would, no clock on levels that are Tetris variants,
build the real moving platform for the race levels, and make the level 7 reveal a story reveal at the win.

## 1. Purpose and how to read it

This file is the frame. Level designers write each level in full from its description, in the order mechanics, then story, then art.
Each aspect gets three blind experts at 9.7. A designer may change detail. A designer may not change a level's minigame, mechanics,
ending pattern or platform form without sending it back to the game director.

Each level is told the way a game builder would tell it: what game it is, what the blocks are for, what the player watches, how it ends.
Verbs are not forced. Where a level's minigame was better described another way, the description wins and the table follows it.

Rules this frame obeys:
- `level-identity-spec.md`: no "clear N layers" goals, a level is a scene, surprising endings, a platform of its own made from its description.
- `minigame-party-rules.md` rules 1 to 5, and "minigames are the level; the game mechanics will be the base of each level".
- `level-type-mix.md`: levels 01 to 10 hold all six types.
- `reference-quality-bar.md`: references are style, not literal layout.
- **Timer rule (user, 2026-10-14):** a level that is a variation on standard Tetris has no countdown and no set time. The pieces speed up as the level progresses. Only a level whose minigame truly needs a clock may have one. No Meadow level needs a countdown. The two races end at a finish line, not at a timer. Levels that end after a set number of waves end on a story event (the last gust, the empty stone cart), never on a visible clock.
- **Speed ramp:** the fall speed rises by a fixed step on a level event: per release, per wave, per finished patch, per sheep penned, per layer, or per phase. The step is data. Each level names its own event below. `fall.g0` is in cells per second, so 0.6 is about 18 s per piece from the spawn row. Each level's start speed is measured, not guessed (gap G6).

User decisions for level 1 that still stand: free the Hearth Stump, the root and stone cage that releases one grip per full layer, the Stump Grip meter, random pieces from a seeded bag, campaign single player, and soft rescue on top-out.
User decisions for level 1 that are replaced by the timer rule: the sundial countdown, the 2:00 limit and the +30 s retry. "Before sunset" is now the sky turning to sunset as the stump comes free. Nothing can run out.

What the expert reviews of level 1 found, and how this frame answers each:
- Rock walls cannot shrink with the current engine. The cage is masked-off columns (`static_geometry`), switched on by `request_mask(x, z, true)` at each release (gap G1). Rock that counted as stack height would also break the top-out, and masked columns add none.
- The T piece breaks layer parity, and spin-only rotation never gives a J. Level 1 uses O, I and L only. Any level that adds T must pass the tiling solver with a 1-lookahead bot and no hold (gap G5).
- The fall speed made the old timer unfair. The timer is gone, and the start speed is measured (gaps G2, G6).
- Meadow lost its funny level. Meadow_08 is the funny level.
- Also: a rescue wipes the bottom layers and never releases a grip. The grace knob is cut. The `hud` block, meter name and objective key in the JSON must be rewritten. Level 1 needs a camera plan and a wall fade per stage (gap G23). Stars come from the plan formula (gap G5). Each level's acceptance list includes `verify_campaign_biomes`.

## 2. Chapter 1 arc

Wonder and welcome. The world is kind. Gert is a nuisance, never a threat. Her loneliness is only revealed in meadow_10.

- **Teach (01 to 03).**
  - 01 teaches drop, turn and a full layer, and shows that a full layer changes the board.
  - 02 teaches that a wall of blocks can shelter something.
  - 03 teaches that the board can move and the track ahead can be read.
  - *The player can* place a piece on purpose, finish a layer, wall off a thing under attack, and plan for what is coming down the track.
- **Twist (04 to 06).**
  - 04 teaches blocks as fences that steer living things.
  - 05 teaches repair under fire.
  - 06 teaches matching a picture cell for cell.
  - *The player can* steer wandering animals with blocks, patch holes while stones fly, and fill a target shape exactly.
- **Combine (07 to 09).**
  - 07 builds tall without seeing the top.
  - 08 builds a path over a bouncy surface.
  - 09 keeps a stack steady on a tipping plate.
  - *The player can* build blind, plan around chaos, and balance a moving base.
- **Boss (10).** Gert's Whirl recalls 02, 04 and 09 in three phases.
- **After.** The bonus is a kite race against Gert, now a friend. Hard 1 is a fast remix of bridges and rescue.

Speed: every level starts gentle and speeds up by its own event. Meadow's start speeds are lowest in the game. Level 10 and h1 end faster than any Meadow level starts.

---

## 3. The levels

### meadow_01 Stump Day

**Pitch.** Level 1 is a Tetris puzzle where full layers are a lever. An old stump is choked by roots and stones. You stack blocks in the pit on top of it. Every time you finish a layer, the stump shakes and one grip lets go, and your play space gets wider. Free the stump before you stack too high.

**The minigame.** Tetris with a cage that opens: finishing layers breaks the stump free.

**How it plays.**
- The Wizard drops a block from his hat. You slide it, turn it, drop it into the pit.
- The pit starts small: 4 by 4. Roots wrap the left, stones wrap the right.
- Fill every cell of a layer and it clears. The stump shudders and one grip lets go. The pit gets wider: 4x4, then 6x4, then 8x4.
- The third grip lets the whole round stump show. It glows green and rings its bell. That is the win.
- The player watches the pit, the next piece, the Stump Grip meter and the sky.
- What the blocks are for: they are the pull on the stump. Full layers are the only way out.

**Mechanics used.**
- Base game: drop, turn, clear a full layer.
- New: `grip_release`. Walls that open one grip at a time when a layer clears. The cage is masked-off columns, released on all layers at once.
- Soft rescue on top-out: the cloud scoops the lowest blocks away. A rescue never releases a grip.
- Pieces: O, I and L only, from a seeded bag. No fixed list, no fixed opening.

**Win, lose, and how it gets harder.**
- Win: the third grip lets go.
- Lose: stack too high. The first time, the soft rescue. After the warnings run out, the stump yawns and the blocks giggle back into their box. Restart in 2 s or less. There is no clock and no retry timer.
- Harder: the fall speed rises by a step on each release (start about 1.2 cells per second, times 1.25 per release, to be measured). The pit gets wider, so layers need more pieces. The sky moves from dawn to gold and then sunset as the grips go.

**The platform.** A growing pit in a cage. The stump top is a 4x4 pit with roots and stones around it. The cage opens as grips go. The full round 52-cell stump shows at the win. The octagon is a stage prop and a reveal. The playable platform is the pit.

**Story.** The Wizard's spoon pops out, and the choked old Hearth Stump shakes itself free.
HUD objective: "Free the Hearth Stump."

Ending: plain. The surprise is the wall change after each clear.

---

### meadow_02 Windbreak

**Pitch.** Level 2 is a Tetris shelter. Gert's wind blasts a little sprout from one side. You build a wall of blocks between the wind and the sprout. Don't let the wind get through to the sprout.

**The minigame.** Tetris defence: build a wall that shelters something small.

**How it plays.**
- The sprout sits in the inner curve of a hilltop ledge. The wind comes from the open side.
- Before each gust the wind line is shown across the board. A weathervane star sign (the Wizard's gold star) spins to warn which way.
- Place blocks in the wind line. A block takes the hit for the sprout. A gap lets the gust through and the sprout takes a hit.
- Full layers still clear, which opens room to rebuild. Blocks hit by a gust get shaken, not removed.
- Gert's puffs come in waves. The last puff ends the level.
- The player watches the sprout's lean, the wind line and the next piece.

**Mechanics used.**
- Base game.
- New: `defend_core`. A small thing with hit points that attacks aim at. Here it is the sprout (3 hit points).
- Wind attack (`gust` as the attacker, with a wave schedule).

**Win, lose, and how it gets harder.**
- Win: the last gust passes and the sprout still stands.
- Lose: the sprout loses its hit points. It bends flat, the blocks giggle away, restart.
- Harder: waves get closer together and the warning shortens. Speed rises one step per wave. On the fourth wave the wind swings round to the other side (the twist). The weathervane warns first, so it is fair.

**The platform.** A crescent ledge. A curved hilltop ledge hugs the sprout bed. The wind comes from the open, outer side.

**Story.** The Wizard nails a gold star to a sprout stake, a puff bends it flat, and a curved wall saves it.
HUD objective: "Shelter the sprout until the wind drops."

Ending: twist. The wind swings round, and the star sign is a weathervane that warned you.

---

### meadow_03 Brook Run

**Pitch.** Level 3 is a Tetris race. You ride a hay cart down a footpath as the brook rises behind you, and you build the cart from falling blocks as you go. Read the track ahead. Don't lose the picnic basket.

**The minigame.** A moving-platform race: build your cart on the move and read the track ahead.

**How it plays.**
- The board is the cart. It rolls along a plank footpath. The camera follows. The track comes toward you at a steady pace.
- A strip at the top of the screen previews the track ahead: cobble bumps and low hedge arches.
- You build the cart's load with the falling blocks. A bump shakes it and shakes loose any block that is not supported. A low arch sweeps anything taller than the arch gap off the top.
- So you plan: keep the stack tidy for bumps and short enough for arches, and still leave room to clear layers.
- A picnic basket rides on the cart. The goal is to bring it to the lawn.
- Halfway, Biscuit leaps aboard and the flock trots alongside. Biscuit's weight sits on one side of the cart.
- The player watches the track strip, the next piece, the basket and the rising brook behind.

**Mechanics used.**
- Base game.
- New: the moving platform with a track preview. The board travels along a track. Events on the track (bump, arch) are known ahead of time.
- Existing: soft rescue; a checkpoint at the halfway post.

**Win, lose, and how it gets harder.**
- Win: the cart reaches the picnic lawn with the basket aboard.
- Lose: the basket is knocked off. The cart returns to the last post and the blocks giggle away. There is no countdown. The track ends at the lawn.
- Harder: the cart rolls faster each section, and the fall speed rises with it. The events come more often. Biscuit's weight adds a lean to one side.

**The platform.** A moving hay cart on a plank footpath that crosses the brook. The board rides a rail and moves with the player. It is a wheeled cart on a ground track.

**Story.** The brook swallows the footpath, Biscuit barks from the far bank, and the whole flock follows the cart across.
HUD objective: "Bring the picnic basket to the lawn."

Ending: guest. Biscuit jumps aboard and the flock follows.

---

### meadow_04 Sheep on the Run

**Pitch.** Level 4 is a Tetris sheep drive. Gert's whirl has scattered the flock. The sheep wander all over the hill, and you build fences from blocks to steer them into the pen. Don't let a sheep wander off the edge.

**The minigame.** Tetris herding: blocks are fences.

**How it plays.**
- Sheep wander across the hill on their own. A sheep walks until it meets a block, then turns.
- You place blocks to make a lane that leads to the pen gate. Full layers clear and open a gate in the lane for a moment, which lets you reshape the fence.
- Each sheep that goes through the gate is penned and safe.
- The player watches the sheep, the pen count shown as sheep faces, and the next piece.

**Mechanics used.**
- Base game.
- New: `herd`. Wandering animals that turn at blocks and walk toward gaps. A pen gate is the goal.

**Win, lose, and how it gets harder.**
- Win: every sheep is in the pen.
- Lose: a sheep walks off the hill edge. It bounces back with a giggle, a warning is spent, and after the third the level restarts.
- Harder: more sheep and faster wandering. Speed rises one step per sheep penned. A second gate closes off the first lane.

**The platform.** A sheep pen with gates. A pasture lane leads to a pen at its elbow. The pen has two gates.

**Story.** Gert zips past, the flock bounces like popcorn, and the last sheep through the gate is Bram in a fleece.
HUD objective: "Herd the flock into the pen."

Ending: twist. The last sheep is Bram.

---

### meadow_05 Gnome Hedge

**Pitch.** Level 5 is a Tetris hold-the-wall. Gnomes throw stones that knock holes in a hedge wall, and the sheep behind it are pushing to get out. You patch each hole with the block that fits. Keep the hedge shut until the stones run out.

**The minigame.** Tetris repair under fire: a wall that keeps being damaged.

**How it plays.**
- The hedge wall stands on the board from the start. Gnomes throw stones from outside.
- A stone is shown for 2 seconds before it lands, then it knocks a few cells out of the wall.
- You slide in the block that fits the hole. A full layer still clears, which makes the wall shorter and opens space.
- A sheep peers through every open hole. Holes left open too long let the sheep slip out.
- The gnomes' stone cart shows a shrinking pile. When it is empty, the level ends.
- The player watches the pile, the hole warnings and the next piece.

**Mechanics used.**
- Base game.
- New: `storm_bolt` as a stone throw. A timed hazard that removes cells.
- The wall rows are placed at the start. Soft rescue.

**Win, lose, and how it gets harder.**
- Win: the stone pile is empty and the hedge is shut.
- Lose: too many sheep slip out. They are returned with a giggle and the level restarts.
- Harder: stones come closer together and the warning shortens. Speed rises one step per volley. The wall starts two cells thicker, then thinner.

**The platform.** A hedge court. A three-sided U court inside a hedge wall. The open end is the gate. The wall is what is under attack.

**Story.** Gnomes lob stones at the hedge, and the sheep inside are pushing out to see the windmill.
HUD objective: "Keep the hedge shut until the stones run out."

Ending: reveal. The last hole opens from the inside, where a sheep peers at the windmill.

---

### meadow_06 Blanket Patch

**Pitch.** Level 6 is a Tetris jigsaw. The picnic blanket is in shreds and the flower bed has holes. You fit blocks into the pattern until the picture is whole. Don't bury a hole you still need.

**The minigame.** A completing puzzle: fill a picture cell for cell.

**How it plays.**
- A flower bed picture is shown as a faint outline on the board. The outline has gaps.
- You fit blocks into the gaps. A block that lands on a wrong cell stays and blocks the picture, so you plan.
- The bed has three terraces, and each terrace is a separate patch. A patch that is fully filled blooms and unlocks the next terrace.
- The player watches the outline, the bloom progress and the next piece.

**Mechanics used.**
- Base game.
- New: `fill_shape`. A target picture to match exactly.
- T may join the piece set here only if the solver proves every patch can be tiled.

**Win, lose, and how it gets harder.**
- Win: the whole picture is filled.
- Lose: stack too high or a buried gap. Soft rescue clears the lowest blocks first.
- Harder: patches get odder in shape and the picture grows from three patches to five. Speed rises one step per finished patch.

**The platform.** A terraced flower bed. Three stepped terraces. Each layer has a different mask. It reads as a picture from above.

**Story.** The picnic blanket lies in shreds, and mending the flower bed draws an arrow to the windmill.
HUD objective: "Mend the flower bed pattern."

Ending: plain. The arrow is a small payoff, not a surprise.

---

### meadow_07 Fog Frolic

**Pitch.** Level 7 is a Tetris tower in the fog. Fog hides the sheep and the picnic hamper, and the only way to see them is to build a lookout above the mist. You stack the lookout higher while the fog hides the top. Don't build it crooked.

**The minigame.** Tetris height build with a hidden top: build tall and trust the preview.

**How it plays.**
- Fog rises as the tower rises. The top few layers fade into mist.
- You see the layers below the fog and the next piece. You cannot see the top, so you plan from the preview and the landing marker.
- Full layers clear and lower the tower. Clearing keeps the tower safe but costs height, so you balance.
- A lookout flag at the top rises as you build. Biscuit climbs it.
- The player watches the flag, the next piece and the landing marker.

**Mechanics used.**
- Base game; height as the goal.
- New: `fog`. A view blocker that hides the top layers.

**Win, lose, and how it gets harder.**
- Win: the lookout reaches the sunlight above the mist.
- Lose: stack too high without a safe base. Soft rescue wipes the lowest layers.
- Harder: the fog gets thicker with height. The target height is higher than the stack limit, so clearing is forced. Speed rises one step per layer cleared.

**The platform.** A lookout scaffold. A narrow timber scaffold on a hilltop that stands in fog. The camera is tall and the top fades into mist.

**Story.** Fog hides the flock, a lookout lifts Biscuit above the mist, and Ada spots a glow in a bonnet ribbon.
HUD objective: "Raise a lookout above the fog."

Ending: reveal. The reveal is a story moment at the win: the fog parts and the glow in the ribbon is Keystone one. There is no second goal.

---

### meadow_08 Bouncy Lambs

**Pitch.** Level 8 is a silly Tetris bounce-across. Fat dewdrops have turned the lily pads into trampolines. You build a path across the pond so a lamb can bounce all the way to the picnic. Don't let the lamb bounce into the water.

**The minigame.** The funny level: build a path on a bouncy surface and carry a lamb across it.

**How it plays.**
- The pond has scattered lily pads. Some pads bounce.
- A lamb waits on the near bank. Bram holds a huge leaf as a sunshade over it.
- Your blocks fill the gaps between pads. A bouncy pad flings the lamb forward, and your path decides where it lands.
- Bounce pads also fling the falling pieces a cell sideways, so landings are a little wild.
- The player watches the lamb, the pads and the next piece.

**Mechanics used.**
- Base game.
- New: `bounce_pad`. Pads that fling pieces and the lamb.
- A lamb walker on the span goal.

**Win, lose, and how it gets harder.**
- Win: the lamb reaches the picnic blanket.
- Lose: the lamb splashes in. It pops out dry with a giggle, a warning is spent, and after the third the level restarts.
- Harder: more pads and stronger bounces, and a wider pond. Speed rises one step per pad bridged.

**The platform.** Lily-pad stepping stones. Separate pads scattered across a pond. The player builds the path between them.

**Story.** Fat dewdrops turn lily pads into trampolines, Bram shades a lamb with a huge leaf, and the lamb bounces home.
HUD objective: "Bounce the lamb across the pond to the picnic."

Ending: secret. Bounce the lamb through the windmill hoop for an extra star.

---

### meadow_09 Tilting Hill

**Pitch.** Level 9 is a Tetris balancing act. Gert spins the windmill sails backward and the hilltop tips like a tray. You stack counterweights on the high side until it levels. Don't let the sheep slide off.

**The minigame.** Tetris balance: a plate that tips as weight shifts.

**How it plays.**
- The whole platform is a round plate on a pivot. It tips toward the heavier side.
- A tilt gauge shows how far. If it tips past a line, blocks slip toward the low side.
- You place blocks on the high side to level it. Full layers clear and take weight away, so clearing changes the balance too.
- The sails slow down with every cleared layer. When they stop, the hill is level.
- The player watches the tilt gauge, the sails and the next piece.

**Mechanics used.**
- Base game.
- New: `tilt_plate`. A platform that tips with weight and makes loose blocks slip.
- A wind push from the spinning sails.

**Win, lose, and how it gets harder.**
- Win: the sails stop and the hill sits flat.
- Lose: the plate tips past the limit and the blocks slide off. Soft rescue first, then a restart.
- Harder: the slip line gets closer to level, from 0.7 to 0.5. A second block can slip per tip. Speed rises one step per cleared layer.

**The platform.** A tilting hilltop plate. A round plate on a pivot under the windmill. It visibly tips. A rim marks the edge the sheep slide off.

**Story.** Gert spins the windmill sails backward, the hill tips like a tray, and she slides down giggling.
HUD objective: "Level the tipping hilltop."

Ending: guest. Gert slides down the tilt, giggling, and lands in the grass.

---

### meadow_10 Gert's Whirl

**Pitch.** Level 10 is the boss fight, played in Tetris. Gert towers over the windmill with Keystone one caught in her ribbons. You build three things in a row: a windbreak, a pen ramp and a tilt-proof mill tower. Don't let any phase fall apart.

**The minigame.** A three-phase Tetris boss that recalls the first third of the chapter.

**How it plays.**
- Phase 1: Gert whirls round the hill. You build a windbreak to shelter the sheep (recalls 02).
- Phase 2: Gert lifts the flock. You build a fence ramp to steer them back to the pen (recalls 04).
- Phase 3: Gert spins the mill sails. You build the mill tower on a tipping base until her spin tires her out (recalls 09).
- Each phase is a short Tetris puzzle with its own meter. Gert's dizziness grows as each phase is done.
- The player watches Gert's dizziness, the phase meter and the next piece.

**Mechanics used.**
- Base game, with boss phases through the boss goal and `active_after_clears`.
- Recalls: `defend_core` with wind, `herd`, `tilt_plate`.
- No new mechanic.

**Win, lose, and how it gets harder.**
- Win: Gert sits down dizzy and the Keystone drops.
- Lose: a phase fails (sheep lost, tower collapsed). Soft rescue first. The fight restarts from the start of that phase, not the whole fight.
- Harder: each phase is faster than its first level. Speed rises one step per phase. This is the chapter's peak.

**The platform.** A spiral mill ramp. A spiral ramp winds up the windmill hill. Each phase opens the next turn. The mill tower is the last stage.

**Story.** Gert holds Keystone one in her ribbons, three builds tire her out, and she cries a little and joins the picnic.
HUD objective: "Calm Gert and free Keystone one."

Ending: story. Gert was only lonely. She is handed a sandwich.

---

### meadow_bonus Kite Day

**Pitch.** The bonus is a Tetris kite race against Gert. You hang under a kite and build your basket as the wind carries you across the gorge. Gert races beside you on her own kite. Read the wind ahead and keep your basket steady.

**The minigame.** A moving-platform race: build while you fly, read the wind lanes ahead, and beat a rival.

**How it plays.**
- The board is a basket hanging under a kite. It travels along a sky lane across the gorge and the camera follows.
- A strip shows the wind ahead: updrafts, crosswinds and cloud bumps.
- An updraft lifts the basket. A crosswind slides loose blocks sideways. A cloud bump shakes it.
- You build the basket to be tidy and steady. Height lets your kite climb faster, but a tall stack catches more wind.
- Gert's kite is a rival marker on the progress bar. She is a friend, so she cheers as she overtakes.
- The player watches the wind strip, the progress bar and the next piece.

**Mechanics used.**
- Base game; height as the kite's lift.
- New: `race_rival`. A rival with its own pace and a rubber band so the race stays close.
- The moving platform and the track preview from level 3, now in the air.

**Win, lose, and how it gets harder.**
- Win: your kite crosses the gorge first. A second-place finish still passes the level with one star.
- Lose: the basket tips and the hamper spills. The kite returns to the last cloud post.
- Harder: Gert's pace goes up from 0.9 to 1.1 of yours. The wind lanes come in faster combinations. Speed rises one step per section.

**The platform.** A kite basket in a sky lane. It moves along an air route, bobs with the wind and rides with the player. It is a hanging basket, not a ground cart.

**Story.** Gert, now a friend, flies a kite with the picnic hamper tied on, and the Wizard's cloud is towed as the tail.
HUD objective: "Fly the picnic kite over the gorge first."

Ending: plain.

---

### meadow_h1 Beanstalk Rescue

**Pitch.** Hard 1 is a fast Tetris rescue. Gert's last seeds have shot up into beanstalks with lambs stranded on top. You build rope bridges between the stalks to bring each lamb down. Don't let the stalks grow past your reach.

**The minigame.** A fast rescue remix: build bridges between growing stalks.

**How it plays.**
- A row of tall stalks stands apart. A lamb waits on top of each.
- Your blocks make rope bridges between neighbouring stalks. A lamb walks across a finished bridge and down to the ground.
- Sprouts grow new cells on the stalks as you lock pieces, so your landing space keeps changing.
- The player watches the lambs, the sprout growth and the next piece.

**Mechanics used.**
- Base game; the bridge walker from levels 3 and 8; `sprouts`.
- No new mechanic. It is a remix.

**Win, lose, and how it gets harder.**
- Win: every lamb is down.
- Lose: a lamb falls. It bounces back up, a warning is spent, and after the third the level restarts.
- Harder: sprouts grow every two locks, then every lock. It starts faster than meadow_10. Speed rises one step per lamb rescued.

**The platform.** A beanstalk comb. A row of separate tall stalk columns joined by rope bridges the player builds.

**Story.** Gert's last seeds shoot into beanstalks with lambs on top, and rope bridges bring them down.
HUD objective: "Bring the lambs down the beanstalks."

Ending: secret. A golden lamb sits on the tallest stalk.

---

## 4. Summary tables

### Mechanics ladder

All eight verbs appear (destroy, defend, race, rescue, survive, build, carry, balance). No two levels share verb, mechanic and goal. Types in 01 to 10: twist 3, defender 3, race 1, completing 1, funny 1, balance 1. Endings: 3 plain (01, 06, bonus) and 9 not plain, none used more than twice.

| Level | Verb | Core mechanic | New thing | Type | Ending | Speed ramps on | Difficulty trend |
|---|---|---|---|---|---|---|---|
| meadow_01 | destroy | full layers break a cage | `grip_release` | twist | plain | each release | pit 4x4 to 8x4, speed x1.25 per release |
| meadow_02 | defend | wall shelters a sprout | `defend_core` | defender | twist | each wave | waves closer, warning shorter, wind swings |
| meadow_03 | race | build a cart on a moving track | moving platform and track preview | race | guest | each section | track faster, more events, a lean |
| meadow_04 | rescue | blocks fence wandering sheep | `herd` | twist | twist | each sheep penned | more sheep, second gate |
| meadow_05 | survive | patch a hedge under stone fire | `storm_bolt` stones | defender | reveal | each volley | stones closer, thinner wall |
| meadow_06 | build | fill a picture | `fill_shape` | completing | plain | each patch | odder patches, five patches |
| meadow_07 | build | tall tower in fog | `fog` | twist | reveal | each layer cleared | fog thicker, target above limit |
| meadow_08 | carry | path over bouncy pads | `bounce_pad` | funny | secret | each pad bridged | more pads, stronger bounce |
| meadow_09 | balance | stack on a tipping plate | `tilt_plate` | balance | guest | each layer cleared | slip line 0.7 to 0.5 |
| meadow_10 | defend | three-phase boss | none (recall) | defender | story | each phase | peak of the chapter |
| meadow_bonus | race | kite basket race | `race_rival` | race | plain | each section | rival 0.9 to 1.1 |
| meadow_h1 | rescue | bridges between growing stalks | none (remix) | twist | secret | each lamb | sprouts every lock, faster than 10 |

### Platform forms (no two the same)

| Level | Form |
|---|---|
| meadow_01 | growing pit in a cage |
| meadow_02 | crescent ledge |
| meadow_03 | moving hay cart on a plank track |
| meadow_04 | sheep pen with gates |
| meadow_05 | hedge court (U) |
| meadow_06 | terraced flower bed |
| meadow_07 | lookout scaffold in fog |
| meadow_08 | lily-pad stepping stones |
| meadow_09 | tilting hilltop plate |
| meadow_10 | spiral mill ramp |
| meadow_bonus | kite basket in a sky lane |
| meadow_h1 | beanstalk comb |

Twin stages are kept for meadow_h2.

### Story objectives (12 words or fewer, no counts)

| Level | HUD objective |
|---|---|
| meadow_01 | Free the Hearth Stump. |
| meadow_02 | Shelter the sprout until the wind drops. |
| meadow_03 | Bring the picnic basket to the lawn. |
| meadow_04 | Herd the flock into the pen. |
| meadow_05 | Keep the hedge shut until the stones run out. |
| meadow_06 | Mend the flower bed pattern. |
| meadow_07 | Raise a lookout above the fog. |
| meadow_08 | Bounce the lamb across the pond to the picnic. |
| meadow_09 | Level the tipping hilltop. |
| meadow_10 | Calm Gert and free Keystone one. |
| meadow_bonus | Fly the picnic kite over the gorge first. |
| meadow_h1 | Bring the lambs down the beanstalks. |

Stars: no level uses time for stars, except that a race may use progress against the rival. For the others, stars come from rescues used and wasted pieces, using the plan formula (gap G5).

Changes needed in other files (owner: narrative director for the story files, game designer for the mix file):
- `beats/meadow.md` and `campaign-story.md`: meadow_01 is the stump cage. 03 is Brook Run, a cart race. 05 is stone fire, not plug_breach. 08 is Bouncy Lambs, not Leafy Roof. The bonus is a kite race. h1 ends with a secret.
- `level-type-mix.md`: update the Meadow table and summary to this frame.

---

## 5. Shared kit and engine gaps

### Mechanics reused
- Base clearing of full layers: every level.
- `defend_core`: 02, phase 1 of 10. Wind attacks: 02, 09, phase 1 of 10, bonus (as wind lanes).
- Moving platform with track preview: 03, bonus.
- `herd`: 04, phase 2 of 10. `storm_bolt`: 05. `fill_shape`: 06. `fog`: 07. `bounce_pad`: 08.
- `tilt_plate`: 09, phase 3 of 10. `race_rival`: bonus. `sprouts`: h1.
- Bridge walker: 08, h1.
- Speed ramp on a level event: every level.
- Soft rescue: every level.

### Platform and art kit pieces
- Island mask builder (`WtIslandBuilder`) and the per-level masks.
- Plank and rope bridge kit: 03, 08, h1.
- Sheep, lamb and gnome actors: 04, 05, 08, 10, h1.
- Windmill and sails: 07, 09, 10. Wind particles and the weathervane star sign: 02, 09, 10, bonus.
- Water shader: 03, 08. Fog volume: 07.
- Track preview strip and the cart or basket view: 03, bonus.
- Cast poses: Wizard, Ada, Bram, Sif, Biscuit, Gert. Goal plaque and meters from the no-beige HUD kit.
- Sky grade that follows progress (dawn to sunset in 01).
- Closed-list additions: terrain `stump_top` and action `grip_release`; any others from this frame.

### Engine gaps
Sizes are working days, estimates only.

| ID | Gap | Used by | Size | Owner |
|---|---|---|---|---|
| G1 | Cage release as a core board operation: masked-off columns switched on by `request_mask(..., true)` on all layers, layer counters rebuilt, a layout event for the view, replay support. Then the rule `grip_release`. | 01 | 5 to 6 | lead-programmer (core), gameplay-programmer (rule), systems-designer (spec) |
| G2 | Speed ramp on a level event (per release, wave, patch, sheep, pad, layer, section, phase, lamb). The `ramp_per_clear` knob exists. This adds a generic event hook and per-level step data. | all | 1 | gameplay-programmer |
| G3 | Sky and light grade driven by level progress (dawn to sunset in 01, others later). | 01, then all | 1.5 | technical-artist |
| G4 | Story objective on the HUD, pause card, level card and result card. It replaces the `clear_n` "layers" icon and any count. Meter source that publishes no layer count. | all | 3 (shared) | ui-programmer |
| G5 | Tiling solver and bag simulator: parity check of each stage for each shape set, piece counts, and the star model with no clock. No J exists with spin-only rotation. | all, first 01 and 06 | 3 | systems-designer, gameplay-programmer |
| G6 | Measure `fall.g0`: time per piece for a gravity-only, soft-drop and hard-drop bot. Set each level's start speed and step from the result. | all | 0.5 | systems-designer |
| G7 | Herd module: wandering sheep, fences steer, a pen gate is the goal. Handbook entry. | 04, 10, h1 | 6 to 8 | gameplay-programmer, systems-designer |
| G8 | **Moving platform.** The board travels along a track and the camera follows. Track events (bump, arch, updraft, crosswind, cloud bump) are scheduled data. A preview strip shows the track ahead. A cargo item (basket or hamper) can be knocked off. Checkpoints. A cart view and a basket view. | 03, bonus | 12 to 15 (core 6 to 7, track events 3, preview strip 2, views 2) | lead-programmer (core), gameplay-programmer (track events), ui-programmer (preview), technical-artist (views) |
| G9 | Wire and verify unused rules: `defend_core` with a wind attack, `race_rival` with a kite view, `tilt_plate` with a visible tilt. Each needs a unit test and one level run. | 02, 09, bonus | 4 | gameplay-programmer |
| G10 | Lamb walker with bounce pads on the bridge goal. | 08 | 3 | gameplay-programmer |
| G11 | Wave schedule: attacks in waves, the level ends on the last wave, and the wind swings direction at a set wave with a warning. | 02, 10 | 1.5 | gameplay-programmer |
| G12 | Stone skin and a sheep peek view for `storm_bolt`. The stone-cart pile meter that ends the level. A fail rule for open holes, agreed by game designer and systems designer. | 05 | 2.5 | gameplay-programmer, technical-artist |
| G13 | Boss phase hand-over beat (camera and cast) and phase restart. Uses `bonk_boss` and `active_after_clears`. | 10 | 2 | gameplay-programmer |
| G14 | Win-moment story reveal sequence hook (fog parts, ribbon glow). Cosmetic, no goal change. | 07, later chapters | 1 | gameplay-programmer, technical-artist |
| G15 | Secret ending hook: an optional hidden condition gives an extra star. | 08, h1 | 2 | gameplay-programmer, systems-designer |
| G16 | Per-layer masks (terraces) and disconnected cells (stepping stones). Check that the mask loader supports both. | 06, 08 | 1 to verify, 2 to fix | gameplay-programmer |
| G17 | Hints: best-fit outline, slide, drop and turn icons, pulse on the last cells, a 3-second looping preview, hint priority rules. | 01 first, then all | 5 | ui-programmer, gameplay-programmer |
| G18 | Cosmetic giggle on a hanging lock. No board change. | 01 | 1 | gameplay-programmer, technical-artist |
| G19 | Platform art, one per level, and its animated set piece (root snap, hedge hits, tilt, rail, kite). About 3 to 5 days each; 01, 03 and the bonus are bigger. | all | 50 to 65 total | art-director, technical-artist |
| G20 | Closed-list additions for terrain and set-piece action ids. | 01 | 0.5 | technical-artist |
| G21 | Update `level_type` tags and the mix file to this frame. | all | 0.25 | game-designer |
| G22 | Camera preset and near-wall fade per stage, so a pit sunk in walls stays readable at 720x1280 as its aspect changes. A retained screenshot per stage. | 01, then all | 2 | art-director, technical-artist, level-designer |

Removed from rev 1 because of the timer rule: the soft retry (+30 s), the sundial pause, and the rising-water hazard. Removed because the reveal is now cosmetic: goal phases.

Order of work.
1. G6, G5, G1, G2, G3, G4, G17, G22 so level 1 can ship alone. Level 1 total (G1 to G6, G17, G18, G20, G22): about 24 to 26 days of code and UI, plus its platform art.
2. In parallel, the lead programmer starts G8 early, because it is the longest and level 3 depends on it. If it is late, level 3 slips and the rest of the chapter does not.
3. Then G9, G11 for 02 and 09. Then G7 for 04. Then G12, G16, G10, G13, G14, G15.

---

## 6. Open questions for the user

Each has a recommended option first.

1. **How fast does level 1 start, and how big is each speed step?**
   - Start so an undropped first piece lands in about 9 s (about 1.2 cells per second), times 1.25 on each release (Recommended). Measured by G6 before it is fixed.
   - A slower start of about 0.9 cells per second and a smaller step of 1.15. Gentler, but long first pieces.
   - Speed rises by minutes played instead of by release. Simple, but it puts a clock back in.
2. **How do stars work with no clock?**
   - Stars from rescues used and wasted pieces (Recommended): 3 stars for no rescue and few wasted pieces. Races also count the finishing order.
   - Stars from the speed reached before the finish. Rewards risk, but players who play safe get fewer.
   - One star for any win and no more stars in Meadow. Simplest, but there is nothing to replay for.
3. **When does the moving platform ship?**
   - Start it now in parallel and let level 3 be the last of the first 10 to finish (Recommended). The race stays in the teach third.
   - Swap level 3 and level 6 so the cart race comes later. Safer schedule, but the teach third has no race.
   - Make level 3 a fixed bridge and use the moving platform only in the bonus. Lowest risk, but it drops the user's "race levels" wording for level 3.
4. **How does the Stump Grip meter show progress?**
   - Three bark knots (Recommended): you already chose it.
   - A continuous grip ring that loosens as the layer fills, as one reviewer suggested. No visible count of 3, about 1 more day of view work.
   - Both: knots plus a creaking ring between clears.

## 7. User decisions (2026-10-14, after r2)

- **Level 1 speed:** "Speed up over time." The fall speed rises with time played: a smooth ramp per minute, with no
  countdown and no fail clock. The grip releases are the story beats and do not set the speed. Start gentle; tune
  after measuring (G6).
- **Stars, all levels without a clock:** "Neat play." Stars come from clean play: fewer rescues and fewer wasted
  pieces. In races, stars come from the finishing position.
- **Moving platform (G8):** "Start now, in parallel." Engine work begins alongside level 1, and level 3 lands last
  among 01-10 if needed.

## 8. User decisions on the moving platform (2026-10-14, after the G8 r1 panel)

- **Race rule: "Survive to the finish."** The cart or kite moves along the track. You win by reaching the end before
  time runs out with the cargo intact. A race may have a clock (see the level rules). There is no rival speed race in
  this round.
- **Tipping: lean meter plus topple.** The platform leans towards its heavy side, and bumps and wind push the lean
  further. A lean meter shows the danger. Past the limit, the top blocks spill off. Building on the light side
  rights it.
- **Cargo rides on top of your build.** The basket (or picnic hamper) sits on the highest block. You must build a
  stable, level seat for it. It wobbles and warns before it falls, so you get a chance to save it.
