# Beats: Chapter 12, Huffle's Birthday Fair (Carnival)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. `callback_of` names the earlier level whose idea returns as a fair game. The wheel promise is revealed once, in carnival_08.

```yaml
---
id: carnival_01
role: teach
place: Fair Gate, golden
who: Huffle, Wizard, Lana, all heroes
problem: The ring-toss stall has no counter for the first hoops.
why_stack: A stall counter of blocks lets the hoops land.
headline_objective: Open the ring-toss stall
ending_pattern: plain
world_change: The stall opens and bunting flies.
wordless_moment: Huffle claps so hard the bunting flutters.
opening_event: bunting_snaps_huffle_hat
verb: build
minigame: "base: build_tower + toss"
footprint: arch
terrain: stack_ledge
set_piece: fair_gate
set_piece_action: confetti_burst
cast_pose: "Huffle:cheer, Wizard:point"
hud_meter: Hoops Landed
callback_of: none
---
id: carnival_02
role: teach
place: Coconut Booth, day
who: Boulder, Bram, Huffle
problem: Boulder's strongman booth rattles as a coconut rolls off its shelf.
why_stack: A keep protects the player's stand while lobs knock the rival stack down.
headline_objective: Win the coconut contest
ending_pattern: plain
world_change: The rival stack falls and Boulder wins a plush hippo.
wordless_moment: Boulder hugs the plush hippo.
opening_event: coconut_rolls_booth_rattles
verb: destroy
minigame: "module: catapult_keep (recall) + wall"
footprint: U_bay
terrain: conveyor_deck
set_piece: coconut_booth
set_piece_action: catapult_volley
cast_pose: "Boulder:brace, Bram:haul"
hud_meter: Coconut Stack
callback_of: candy_10
---
id: carnival_03
role: teach
place: Mirror Tent, dusk
who: Ada, Gert, Jester
problem: Twin mirrors reflect every move a heartbeat late.
why_stack: Matching sides built on both mirrors make them agree.
headline_objective: Match both sides of the mirror
ending_pattern: guest
world_change: The mirrors agree and the tent glows.
wordless_moment: Gert and Jester stroll in and add reflections of their own.
opening_event: mirrors_lag_reflections
verb: build
minigame: "base: mirror twin + path"
footprint: twin_towers
terrain: tent_floor
set_piece: mirror_tent
set_piece_action: pendulum_swing
cast_pose: "Gert:cheer, Jester:hide"
hud_meter: Mirror Match
callback_of: cave_06
---
id: carnival_04
role: twist
place: Teacup Ring, golden
who: Bram, Crumb, Sif
problem: A giant cake plate tilts and the top tier slides toward the edge.
why_stack: A steady stack on the tilting plate holds the cake in place.
headline_objective: Hold the cake tier steady
ending_pattern: plain
world_change: The cake tier sits steady on the plate.
wordless_moment: Bram reaches for his hammer, puts it down, and holds the last layer by hand.
opening_event: cake_plate_tilts_hammer_down
verb: balance
minigame: "module: wobble_plate (recall) + tilt"
footprint: ring
terrain: cake_plate
set_piece: teacup_ring
set_piece_action: pendulum_swing
cast_pose: "Bram:build, Crumb:react"
hud_meter: Cake Steadiness
callback_of: candy_04
---
id: carnival_05
role: twist
place: Sail Ring, day
who: Gert, Biscuit, Sif
problem: A ring of windmill sails spins above the prize stall, driven by a friendly gust.
why_stack: A frame of blocks keeps the ring turning to lift the basket.
headline_objective: Lift the prize basket by sail
ending_pattern: plain
world_change: The prize basket reaches the stall roof.
wordless_moment: Biscuit barks the beat.
opening_event: windmill_ring_lifts_basket
verb: carry
minigame: "base: cart_convoy + wind"
footprint: pinwheel
terrain: raft
set_piece: sail_ring
set_piece_action: firework_pop
cast_pose: "Gert:cheer, Biscuit:react"
hud_meter: Sail Speed
callback_of: meadow_10
---
id: carnival_06
role: twist
place: Ticket Booth, golden
who: Glim, Sif, Wizard
problem: Glim's ticket booth has a jammed drawer and a shelf of blueprints.
why_stack: Each blueprint goes on its place on the shelf in order.
headline_objective: Shelve each ally's blueprint
ending_pattern: reveal
world_change: The shelf stands full and the drawer opens.
wordless_moment: The Wizard's star is on none of the blueprints.
opening_event: drawer_jammed_blueprints
verb: build
minigame: "base: fill_the_shape + sort"
footprint: keyhole
terrain: tent_floor
set_piece: ticket_booth
set_piece_action: bell_ring
cast_pose: "Glim:point, Wizard:hide"
hud_meter: Blueprints Shelved
callback_of: cave_bonus
---
id: carnival_07
role: combine
place: Bumper Arena, dusk
who: Cinderbottom, Sir Shiver, Madame Cuckoo, Bram
problem: Old villains drive tiny bumper cars across an icy floor.
why_stack: Floe bumpers built round the arena keep the cars from crashing.
headline_objective: Keep the guest cars on the ice
ending_pattern: guest
world_change: The cars bump gently and the arena glows.
wordless_moment: All three villains wave and cheer the heroes.
opening_event: bumper_cars_villains_wave
verb: survive
minigame: "module: floe_footing (recall) + ice"
footprint: bullseye
terrain: conveyor_deck
set_piece: bumper_arena
set_piece_action: bell_ring
cast_pose: "Cinderbottom:cheer, Bram:brace"
hud_meter: Bumper Calm
callback_of: ice_08
---
id: carnival_08
role: combine
place: Big Wheel Base, dusk
who: Wizard, Huffle, Ada
problem: The half-built wheel has an empty hub exactly the size of a Keystone.
why_stack: Spokes raised ring by ring let the wheel hold its hub.
headline_objective: Raise the Big Wheel's spokes
ending_pattern: reveal
world_change: The wheel's spokes stand and the hub waits.
wordless_moment: A faded ticket stub in the Wizard's hand shows the promise he made her long ago.
opening_event: half_wheel_empty_hub
verb: race
minigame: "module: sky_steps (recall) + spokes"
footprint: spiral_terraces
terrain: wheel_base
set_piece: big_wheel
set_piece_action: drum_beat
cast_pose: "Huffle:hide, Wizard:point"
hud_meter: Wheel Height
callback_of: celestial_03
---
id: carnival_09
role: combine
place: Fair Gate, night
who: Ada, Huffle, Wizard, Tuppence
problem: Huffle's giggle fit fires confetti cannons in every direction.
why_stack: Ada's wall of blocks shields the stalls.
headline_objective: Shield the stalls from confetti
ending_pattern: twist
world_change: The stalls stand under a snow of confetti.
wordless_moment: Ada's tower wobbles and she laughs out loud while the Wrong Sack starts to rattle.
opening_event: giggle_fires_cannons
verb: defend
minigame: "base: hold_the_wall + cannon"
footprint: cross
terrain: fort_wall
set_piece: fair_gate
set_piece_action: firework_pop
cast_pose: "Ada:brace, Tuppence:react"
hud_meter: Confetti Shield
callback_of: pirate_08
---
id: carnival_10
role: boss
place: Big Wheel Base, night
who: Great Heap, Wizard, Huffle, all heroes, all allies
problem: The Wizard zaps the wheel and the Wrong Sack bursts into a rattling heap of eight wrong things.
why_stack: Walls, shields and a hub and spokes round it turn the Heap into the wheel's cars.
headline_objective: Turn the Heap into the wheel
ending_pattern: story
world_change: The wheel turns with Keystone twelve on its hub and twelve notes hum.
wordless_moment: The Wizard dips his hat and finds the star-carved block in its faded ribbon at last.
opening_event: wizard_zaps_sack_bursts
verb: build
minigame: "module: giant_bonk (recall) + sky_steps (recall)"
footprint: moat_island
terrain: wheel_base
set_piece: big_wheel
set_piece_action: heap_stomp
cast_pose: "Ada:build, Bram:build, Sif:build, Wizard:build"
hud_meter: Heap Wobble
callback_of: neon_10, forest_10
caption: The Fair opens! Every game is one you have won.
---
id: carnival_bonus
role: bonus
place: Ticket Booth, night
who: all heroes, all allies, all former villains
problem: The birthday feast needs a table long enough for everyone.
why_stack: A long table of blocks gives every friend a seat.
headline_objective: Build the long party table
ending_pattern: story
world_change: A long table glows under the fireworks.
wordless_moment: Sif sets out every borrowed trinket for a friend and Huffle hands her the first ticket.
opening_event: feast_laid_cast_gathers
verb: build
minigame: "base: build_tower + feast"
footprint: star_five
terrain: stack_ledge
set_piece: ticket_booth
set_piece_action: catapult_volley
cast_pose: "Sif:cheer, Huffle:cheer"
hud_meter: Table Length
callback_of: none
---
id: carnival_h1
role: hard
place: Teacup Ring, dusk
who: Gert, Biscuit
problem: Gert returns in a ringmaster's bonnet with a spinning ride at double speed.
why_stack: A steady stack on the spinning platform keeps it upright.
headline_objective: Steady the spinning platform
ending_pattern: plain
world_change: The platform spins steady and the riders cheer.
wordless_moment: Gert whirls with her bonnet streaming.
opening_event: gert_rides_back_double_speed
verb: balance
minigame: "module: wobble_plate (recall) + spin"
footprint: crescent
terrain: cake_plate
set_piece: teacup_ring
set_piece_action: confetti_burst
cast_pose: "Gert:point, Biscuit:react"
hud_meter: Ride Balance
callback_of: meadow_09
---
id: carnival_h2
role: hard
place: Coconut Booth, night
who: Jester, Crumb
problem: Jester sets up a pie-throwing stall and swears it is his best prank yet.
why_stack: A shield wall stops each volley of pies.
headline_objective: Shield the stalls from pies
ending_pattern: twist
world_change: The shielded stalls stand under a drift of confetti.
wordless_moment: Every pie turns out to be full of confetti.
opening_event: jester_pie_stall
verb: defend
minigame: "base: hold_the_wall + pie volley"
footprint: zigzag
terrain: raft
set_piece: coconut_booth
set_piece_action: drum_beat
cast_pose: "Jester:cheer, Crumb:hide"
hud_meter: Pie Shield
callback_of: candy_h3
---
id: carnival_h3
role: hard
place: Bumper Arena, dawn
who: Sir Shiver, Lana
problem: Sir Shiver freezes the fairground into a rink for an encore skate.
why_stack: Rails and stoppers keep the skaters from the stalls.
headline_objective: Rail the fair's ice rink
ending_pattern: plain
world_change: Rails line the rink and the skaters glide.
wordless_moment: Lana knits a scarf for the ice.
opening_event: shiver_freezes_fair
verb: defend
minigame: "base: hold_the_wall + ice slide"
footprint: figure_eight
terrain: fort_wall
set_piece: bumper_arena
set_piece_action: heap_stomp
cast_pose: "Sir Shiver:brace, Lana:haul"
hud_meter: Rink Rails
callback_of: ice_04
```
