# Beats: Chapter 11, The Tallest Nest (Pirate)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. Pirates are unnamed one-off crew; the boss terrain is the mast crown, not a ship deck.

```yaml
---
id: pirate_01
role: teach
place: Dock and Gangplank, day
who: Tuppence, Ada, Sif
problem: A parrot flaps off over a swaying dock while the tide starts to rise.
why_stack: A gangplank built across the dock's gaps beats the tide.
headline_objective: Race the gangplank ahead of the tide
ending_pattern: plain
world_change: A gangplank links the dock to the longboat.
wordless_moment: The parrot drops a rolled map on Ada's helmet.
opening_event: parrot_drops_map_tide_rises
verb: race
minigame: "module: gap_runner (recall) + tide"
footprint: ribbon
terrain: dock_pier
set_piece: dock_gangplank
set_piece_action: sails_turn
cast_pose: "Tuppence:react, Ada:cheer"
hud_meter: Tide Gap
---
id: pirate_02
role: teach
place: Cannon Beach, day
who: Sloppy Gulls (crew), Bram
problem: Gulls dive-bomb the boardwalk, dropping clam shells along the party's path.
why_stack: Covered walkway sections shelter the dash between volleys.
headline_objective: Dash the boardwalk between volleys
ending_pattern: plain
world_change: A covered boardwalk crosses the beach.
wordless_moment: A shell bounces off Bram's helmet.
opening_event: gulls_dive_bomb_boardwalk
verb: survive
minigame: "base: outrun_hazard + wind"
footprint: bridge_span
terrain: plank_bridge
set_piece: cannon_beach
set_piece_action: wind_gust
cast_pose: "Bram:brace, Gulls:react"
hud_meter: Dash Cover
---
id: pirate_03
role: teach
place: Buoy Raft, dusk
who: Wizard, Ada, Sif, Boulder
problem: The only way to Bea's fort is a raft that tips like a seesaw.
why_stack: Barrels loaded evenly keep it flat across the waves.
headline_objective: Cross to the fort on the raft
ending_pattern: plain
world_change: The raft sits level and glides to the fort.
wordless_moment: The Wizard sneezes for real and nearly sinks it.
opening_event: raft_tips_boulder_sits
verb: balance
minigame: "module: wobble_plate (recall) + tide"
footprint: cross
terrain: raft
set_piece: buoy_raft
set_piece_action: tide_surge
cast_pose: "Boulder:brace, Wizard:hide"
hud_meter: Raft Level
---
id: pirate_04
role: twist
place: Dockside Slope, golden
who: Sloppy Gulls (crew), Bea, Bram
problem: The crew rolls barrels downhill at the dock, cackling and missing.
why_stack: A barricade bounces the barrels like skittles.
headline_objective: Stop the barrel raid
ending_pattern: guest
world_change: The barricade stands and the barrels pile up.
wordless_moment: Bea strolls in to see why the barrels stopped.
opening_event: barrels_roll_dock
verb: defend
minigame: "base: hold_the_wall + barrel roll"
footprint: wedge
terrain: dock_pier
set_piece: dock_gangplank
set_piece_action: boulder_roll
cast_pose: "Bram:cheer, Bea:point"
hud_meter: Barrel Wall
---
id: pirate_05
role: twist
place: Crow's Nest Mast, dusk
who: Bea, Wizard, Ada, Tuppence
problem: Bea and the Wizard each claim their lookout is tallest.
why_stack: The player raises a lookout against Bea's.
headline_objective: Out-build Bea's lookout
ending_pattern: plain
world_change: A lookout stands beside Bea's on the mast.
wordless_moment: The Wizard pulls a frying pan from his hat, hands it to Tuppence, and tips his hat to Bea.
opening_event: bea_wizard_declare_tallest_pan
verb: race
minigame: "base: race_rival + height"
footprint: T_shape
terrain: summit_ledge
set_piece: crows_nest_mast
set_piece_action: sails_turn
cast_pose: "Wizard:build, Bea:build"
hud_meter: Nest Height
---
id: pirate_06
role: twist
place: Flagship Deck, night
who: Bea, Sloppy Gulls (crew), Lana
problem: A cannonball tears the mainsail and the wind whips the crew's flag away.
why_stack: A frame of blocks holds the patch while Lana knits it.
headline_objective: Hold the patch frame in the wind
ending_pattern: story
world_change: The patched sail flies a new flag.
wordless_moment: The patch spells a skull-and-star badge.
opening_event: cannonball_tears_mainsail
verb: build
minigame: "base: fill_the_shape + wind"
footprint: ship_hull
terrain: ship_deck
set_piece: flagship_hull
set_piece_action: bell_ring
cast_pose: "Lana:build, crew:haul"
hud_meter: Patch Frame
---
id: pirate_07
role: combine
place: Rigging, golden
who: Sif, Tuppence, Glim
problem: Tuppence snatches Sif's lockpick and flits through the rigging.
why_stack: Rope-ladder runs built up the mast let Sif catch up.
headline_objective: Catch the thieving parrot
ending_pattern: reveal
world_change: A web of rope ladders crosses the rigging.
wordless_moment: The parrot only wanted to lead Sif to Keystone eleven's hiding spot.
opening_event: tuppence_snatches_lockpick
verb: race
minigame: "module: sneak_route (recall) + chase"
footprint: snake
terrain: ship_deck
set_piece: flagship_hull
set_piece_action: flock_wander
cast_pose: "Sif:haul, Tuppence:react"
hud_meter: Chase Gap
---
id: pirate_08
role: combine
place: Cannon Crew Deck, dusk
who: Ada, Bram, Bea, Hugo
problem: A rival ship drifts into range with its cannons run out.
why_stack: Rows built to load Ada's cannons fire back until the sails drop.
headline_objective: Fire the broadside at the rival
ending_pattern: plain
world_change: The rival's sails drop and its guns fall silent.
wordless_moment: Ada takes the captain's wheel with a grin.
opening_event: ada_takes_wheel_rival_ship
verb: destroy
minigame: "module: catapult_keep (recall) + cannon"
footprint: L_shape
terrain: fort_wall
set_piece: sea_stack_fort
set_piece_action: wind_gust
cast_pose: "Ada:point, Bram:haul"
hud_meter: Rival Sails
---
id: pirate_09
role: combine
place: Sea Stack Fort, golden
who: Bea, Ada, Sloppy Gulls (crew)
problem: Two crews fire at a tall stack of coloured blocks, each trying to knock off the other's colour.
why_stack: A bulwark behind the player's colour makes only the rivals' blocks fall.
headline_objective: Knock the rival blocks off the stack
ending_pattern: twist
world_change: The rival colour tumbles into the sea.
wordless_moment: The stack's top block is Bea's own lost hat.
opening_event: crews_fire_at_stack
verb: destroy
minigame: "module: knockdown_tower (debut) + cannon"
footprint: pyramid_steps
terrain: stack_ledge
set_piece: sea_stack_fort
set_piece_action: cannon_volley
cast_pose: "Bea:point, Ada:haul"
hud_meter: Rival Blocks
---
id: pirate_10
role: boss
place: Crow's Nest Mast, golden
who: Bea, Wizard, Tuppence, all heroes
problem: Bea fires broadsides from her mast with Keystone eleven as her lantern.
why_stack: Shields, a balanced raft and a taller nest with room for the crew win in three phases.
headline_objective: Out-build Bea and make room
ending_pattern: twist
world_change: One merged nest carries Keystone eleven as the island's light.
wordless_moment: The two nests tie in height, so Bea merges them and hangs the lantern on top.
opening_event: bea_laughs_broadsides
verb: build
minigame: "module: knockdown_tower then catapult_keep (recalls)"
footprint: star_five
terrain: summit_ledge
set_piece: crows_nest_mast
set_piece_action: cannon_volley
cast_pose: "Ada:build, Wizard:build, Bea:cheer"
hud_meter: Bea's Pride
caption: Captain Bea wants the tallest crow's nest. So does the Wizard.
---
id: pirate_bonus
role: bonus
place: Captain's Cabin Roof, golden
who: Tuppence, Sif, crew
problem: Tuppence's bird derby needs perches for every racer.
why_stack: Perch ramps let each bird reach the finish ribbon.
headline_objective: Build perch ramps for the derby
ending_pattern: secret
world_change: Every bird crosses the finish.
wordless_moment: The finish ribbon unrolls into a map with an X on Huffle's fair.
opening_event: birds_line_up_for_derby
verb: race
minigame: "base: race + wind"
footprint: dumbbell
terrain: fort_wall
set_piece: captain_cabin
set_piece_action: flock_wander
cast_pose: "Tuppence:react, Sif:cheer"
hud_meter: Derby Progress
---
id: pirate_h1
role: hard
place: Buoy Raft, dawn
who: Bea, Wizard, Hugo
problem: Bea builds her new nest on a wobbly raft and needs it kept steady.
why_stack: Counterweights keep her tower from tipping.
headline_objective: Steady Bea's new tower
ending_pattern: guest
world_change: The tower stands tall on the raft.
wordless_moment: Hugo surfaces to wave.
opening_event: bea_sails_back_rope_hauled
verb: balance
minigame: "base: tilt + gust"
footprint: island_chain
terrain: raft
set_piece: buoy_raft
set_piece_action: lantern_sway
cast_pose: "Bea:build, Hugo:react"
hud_meter: Tower Tilt
---
id: pirate_h2
role: hard
place: Cannon Beach, dusk
who: Sloppy Gulls (crew), Tuppence
problem: A hundred seagulls drop clam shells on the dock as a joke.
why_stack: A roof built over the dock stops the shells.
headline_objective: Roof the dock against shells
ending_pattern: plain
world_change: The roofed dock stands under a pile of shells.
wordless_moment: Tuppence ducks under a wing.
opening_event: seagulls_drop_shells_joke
verb: defend
minigame: "base: hold_the_wall + falling shells"
footprint: comb
terrain: plank_bridge
set_piece: cannon_beach
set_piece_action: boulder_roll
cast_pose: "Gulls:react, Tuppence:hide"
hud_meter: Dock Roof
---
id: pirate_h3
role: hard
place: Captain's Cabin, golden
who: Tuppence, crew
problem: Tuppence conducts a parade with a barrel float that needs building.
why_stack: A float frame of blocks keeps the parade moving.
headline_objective: Build the parade float
ending_pattern: plain
world_change: The float rolls through the cove.
wordless_moment: Tuppence waves a tiny baton.
opening_event: tuppence_conducts_parade
verb: carry
minigame: "base: cart_convoy + barrels"
footprint: heart
terrain: stack_ledge
set_piece: captain_cabin
set_piece_action: tide_surge
cast_pose: "Tuppence:cheer, crew:haul"
hud_meter: Float Length
```
