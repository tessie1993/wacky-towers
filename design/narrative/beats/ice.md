# Beats: Chapter 3, The Quiet Floe (Ice)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer.

```yaml
---
id: ice_01
role: teach
place: Frost Harbour Floe, dawn
who: Wizard, Ada, Bram, seal
problem: The party's floe cracks as it drifts toward the harbour.
why_stack: Blocks patch each crack so the floe holds together to shore.
headline_objective: Hold the floe together to shore
ending_pattern: plain
world_change: The floe bumps the pier and ice flowers bloom on it.
wordless_moment: The Wizard's trombone blast startles a seal who nudges the floe in.
opening_event: trombone_blasts_floe_cracks
verb: survive
minigame: "module: floe_footing (debut) + thin ice"
footprint: blob
terrain: ice_floe
set_piece: harbour_floe
set_piece_action: ice_crack
cast_pose: "Wizard:point, Ada:brace"
hud_meter: Floe Integrity
---
id: ice_02
role: teach
place: Glass Jetty, day
who: Bram, Ada
problem: A loaded sled slides too fast along the slick jetty.
why_stack: Rails along the edge guide the sled to a stop at the pier end.
headline_objective: Stop the supply sled at the pier
ending_pattern: plain
world_change: The sled stops neatly and the village unloads.
wordless_moment: Bram slides past on his backside with a grin.
opening_event: bram_slides_jetty_sled
verb: carry
minigame: "base: cart_convoy + ice slide"
footprint: ribbon
terrain: dock_pier
set_piece: glass_jetty
set_piece_action: tide_surge
cast_pose: "Bram:haul, Ada:brace"
hud_meter: Sled Speed
---
id: ice_03
role: teach
place: Sled Slope, golden
who: Lana, Ada, Wizard
problem: Lana's sled has run away down the slope toward the sea.
why_stack: Banked catches built ahead of her stop the sled in time.
headline_objective: Stop Lana's sled before the sea
ending_pattern: guest
world_change: Lana ties two loose golden threads to the sky.
wordless_moment: A woolly alpaca in a lopsided hat waves from the sled.
opening_event: lana_sled_runaway_yarn
verb: race
minigame: "base: outrun_hazard + ice slide"
footprint: funnel
terrain: snow_slope
set_piece: lana_igloo
set_piece_action: boulder_roll
cast_pose: "Lana:haul, Wizard:cheer"
hud_meter: Sled Distance
---
id: ice_04
role: twist
place: Snowball Alley, day
who: Sir Shiver, Lana, Bram
problem: Sir Shiver rolls huge snowballs down the alley at the village.
why_stack: Bumper walls ricochet the snowballs away from the huts.
headline_objective: Shield the village from snowballs
ending_pattern: plain
world_change: The bumpers stand and the snowballs pile into a snowman.
wordless_moment: Sir Shiver never raises his bucket helm.
opening_event: shiver_rolls_snowballs
verb: defend
minigame: "base: hold_the_wall (D1) + snowball roll"
footprint: H_shape
terrain: stepped_ravine
set_piece: snowball_alley
set_piece_action: rock_throw
cast_pose: "Bram:brace, Lana:hide"
hud_meter: Village Wall
---
id: ice_05
role: twist
place: Avalanche Peak, golden
who: Ada, Bram, Sif, Lana
problem: A slab of snow slides toward the huts while the party stands on the slope.
why_stack: Steps built uphill ahead of the slide lift everyone above it.
headline_objective: Climb above the avalanche
ending_pattern: plain
world_change: The slide stops one step below the top and the huts are safe.
wordless_moment: The party scrambles up each new step with snow at their heels.
opening_event: peak_rumbles_slab_slides
verb: race
minigame: "module: foothold_climb (debut) + sliding snow"
footprint: stair
terrain: snow_slope
set_piece: avalanche_peak
set_piece_action: wind_gust
cast_pose: "Ada:build, Sif:point"
hud_meter: Altitude
---
id: ice_06
role: twist
place: Snowman Gallery, golden
who: Lana, Wizard
problem: Lana's ice sculptures froze lopsided and every snowman frowns.
why_stack: Blocks refill each missing curve until the sculpture smiles.
headline_objective: Make the gallery smile
ending_pattern: twist
world_change: Every snowman in the gallery grins.
wordless_moment: The last sculpture is a small twin wearing a bucket helm.
opening_event: frowning_snowmen_gallery
verb: build
minigame: "base: fill_the_shape + frost creep"
footprint: bowtie
terrain: floating_island
set_piece: snowman_gallery
set_piece_action: smoke_puff
cast_pose: "Lana:cheer, Wizard:hide"
hud_meter: Smiles
---
id: ice_07
role: combine
place: Avalanche Peak, dusk
who: Ada, Wizard, Bram
problem: A snowball as big as a house rolls down the mountain at the village.
why_stack: Ramps and walls built ahead of it steer it off the cliff.
headline_objective: Outrun the giant snowball
ending_pattern: reveal
world_change: The snowball rolls off the cliff and breaks apart.
wordless_moment: Inside it lies a crate stamped with the Wizard's star.
opening_event: giant_snowball_down_mountain
verb: race
minigame: "base: outrun_hazard (rolling hazard) + gust"
footprint: zigzag
terrain: stepped_ravine
set_piece: avalanche_peak
set_piece_action: boulder_roll
cast_pose: "Ada:point, Bram:haul"
hud_meter: Hazard Warning
---
id: ice_08
role: combine
place: Frost Lake, dusk
who: Ada, Lana, Bram, Wizard
problem: Ada is stranded on a shrinking floe, frozen with worry.
why_stack: Patches of safe ice under her steps bring her home.
headline_objective: Bring Ada safely home
ending_pattern: story
world_change: Ada reaches the shore wrapped in a scarf far too warm.
wordless_moment: Ada disappears into the scarf and finally lets herself be helped.
opening_event: ada_chases_mitten_ice_splits
verb: survive
minigame: "module: floe_footing + side travel"
footprint: tadpole
terrain: ice_floe
set_piece: frost_lake
set_piece_action: lantern_sway
cast_pose: "Ada:hide, Lana:haul"
hud_meter: Warmth
---
id: ice_09
role: combine
place: Castle Gate Berg, dusk
who: Lana, Bram, Ada
problem: The berg under the castle gate cracks and the gate leans.
why_stack: Braces under the leaning side hold the gate upright.
headline_objective: Keep the castle gate upright
ending_pattern: plain
world_change: The gate stands straight on its braced berg.
wordless_moment: The gate creaks like a sleepy giant.
opening_event: gate_leans_berg_cracks
verb: balance
minigame: "base: tilt + brace"
footprint: arch
terrain: fort_wall
set_piece: castle_gate
set_piece_action: ice_crack
cast_pose: "Bram:brace, Lana:haul"
hud_meter: Gate Tilt
---
id: ice_10
role: boss
place: Castle Gate Berg, golden
who: Sir Shiver, Wizard, Lana, all heroes
problem: Sir Shiver blocks the gate, rolling snowballs and sliding across the rink.
why_stack: Bumpers, stoppers and a stair up to his helm let the Wizard reach him.
headline_objective: Free Sir Shiver from his order
ending_pattern: reveal
world_change: The gate opens and Keystone three lights the harbour.
wordless_moment: The old order was the Wizard's own, forgotten for a hundred years.
opening_event: shiver_blocks_gate_order
verb: destroy
minigame: "module: foothold_climb (recall) + hold_the_wall"
footprint: dumbbell
terrain: summit_ledge
set_piece: castle_gate
set_piece_action: rock_throw
cast_pose: "Wizard:point, Ada:brace, Lana:build"
hud_meter: Shiver's Order
caption: A snow knight has frozen the gate. Nobody knows why.
---
id: ice_bonus
role: bonus
place: Glass Jetty Run, golden
who: Lana, Bram, Sir Shiver
problem: Lana and Bram's sleds need ramps for the village derby.
why_stack: Ramps let both sleds make the jump.
headline_objective: Build ramps for the sled derby
ending_pattern: guest
world_change: Both sleds soar and the crowd cheers.
wordless_moment: Sir Shiver stands at the finish line as the snowman judge.
opening_event: sleds_line_up_crowd_cheers
verb: race
minigame: "base: outrun_hazard + ice slide"
footprint: boomerang
terrain: fort_wall
set_piece: snowman_gallery
set_piece_action: tide_surge
cast_pose: "Lana:cheer, Bram:point"
hud_meter: Jump Height
---
id: ice_h1
role: hard
place: Snowball Alley, dusk
who: Sir Shiver, villagers, Bram
problem: The village wants to throw snowballs at Sir Shiver for fun.
why_stack: A fort lets the villagers lob from behind a strong wall.
headline_objective: Hold the snow fort for the village
ending_pattern: twist
world_change: The fort stands and Sir Shiver tips his helm.
wordless_moment: Shiver is the target this time, not the attacker.
opening_event: shiver_behind_wall_village_throws
verb: defend
minigame: "base: shield_and_strike (D3) + snowball"
footprint: twin_towers
terrain: summit_ledge
set_piece: snowball_alley
set_piece_action: wind_gust
cast_pose: "Bram:cheer, Sir Shiver:brace"
hud_meter: Fort Strength
---
id: ice_h2
role: hard
place: Curling Lake, night
who: Sir Shiver, Lana
problem: Fog hides the rink and Sir Shiver's stones slide everywhere.
why_stack: Stoppers on the rink's edge keep the stones on the ice.
headline_objective: Keep the stones on the ice
ending_pattern: plain
world_change: The stones stop in a neat row.
wordless_moment: Lana keeps score with knitting needles.
opening_event: fog_drops_on_rink
verb: defend
minigame: "base: hold_the_wall + ice slide"
footprint: figure_eight
terrain: floating_island
set_piece: frost_lake
set_piece_action: lantern_sway
cast_pose: "Lana:brace, Sir Shiver:point"
hud_meter: Stones On Ice
---
id: ice_h3
role: hard
place: Frost Harbour Pier, dawn
who: Lana, villagers, Sir Shiver
problem: An early thaw splits the harbour into floes with Lana's yarn stretched across.
why_stack: Floes joined into a raft ferry the village home.
headline_objective: Raft the village home
ending_pattern: plain
world_change: A raft of joined floes carries the village to the pier.
wordless_moment: Lana's yarn is the raft's rope.
opening_event: early_spring_harbour_splits
verb: rescue
minigame: "module: floe_footing (recall) + thaw"
footprint: island_chain
terrain: dock_pier
set_piece: harbour_floe
set_piece_action: smoke_puff
cast_pose: "Lana:haul, villagers:cheer"
hud_meter: Raft Length
```
