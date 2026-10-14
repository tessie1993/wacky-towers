# Beats: Chapter 4, The Shy Giant's Shell (Underwater)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer.

```yaml
---
id: underwater_01
role: teach
place: Lamplighter's Landing, day
who: Finn, Wizard, all heroes
problem: Finn's lantern has no post to stand on in the sand.
why_stack: A sturdy base holds the first lamp-post upright.
headline_objective: Plant the first lamp-post
ending_pattern: plain
world_change: The first lantern glows and bubbles rise round it.
wordless_moment: The Wizard hangs a gold star on the post and Finn quietly sets it aside.
opening_event: teapot_flung_bubble_hats_sink
verb: build
minigame: "base: build_tower + bubble float"
footprint: clover
terrain: seabed_sand
set_piece: lamp_post_landing
set_piece_action: lantern_sway
cast_pose: "Finn:point, Wizard:point"
hud_meter: Lamp Glow
---
id: underwater_02
role: teach
place: Clam Beds, day
who: Sif, Ada, Finn, clams
problem: Snapping clams line the path and one pearl glints in Sif's pocket.
why_stack: A paved walkway lets Sif cross between the clams.
headline_objective: Cross the clam beds
ending_pattern: plain
world_change: A stone walkway lies between the clams.
wordless_moment: Sif tiptoes with her pocket held shut.
opening_event: clams_snap_pearl_glints
verb: race
minigame: "module: gap_runner (recall) + clam snap"
footprint: comb
terrain: stack_ledge
set_piece: clam_beds
set_piece_action: bell_ring
cast_pose: "Sif:hide, Ada:brace"
hud_meter: Clam Snap
---
id: underwater_03
role: teach
place: Reef Lane, dusk
who: Finn, Ada
problem: A strong current blows through the reef lane and rolls the lamps away.
why_stack: A reef wall upstream slows the current so lamps can be lit.
headline_objective: Calm the current for the lamps
ending_pattern: plain
world_change: The water slows and a row of lamps lights up.
wordless_moment: Ada's plume streams sideways in the current.
opening_event: current_ruffles_plume
verb: defend
minigame: "base: hold_the_wall + current"
footprint: arrow
terrain: reef_wall
set_piece: reef_current_wall
set_piece_action: flock_wander
cast_pose: "Finn:haul, Ada:brace"
hud_meter: Current Strength
---
id: underwater_04
role: twist
place: Coral Arch, dusk
who: Finn, Bram, lobster
problem: A bossy lobster blocks the lamp lane with both claws.
why_stack: A wall of blocks bonks him back with each cleared layer.
headline_objective: Bonk the lobster off the lane
ending_pattern: reveal
world_change: The lane opens and the lamps reach the arch.
wordless_moment: The lobster drops a tiny crab hat far too small for him.
opening_event: lobster_blocks_lamp_lane
verb: destroy
minigame: "module: giant_bonk (debut) + claw"
footprint: moat_island
terrain: lagoon_floor
set_piece: coral_tower
set_piece_action: jelly_wobble
cast_pose: "Bram:haul, Finn:point"
hud_meter: Lobster Pressure
---
id: underwater_05
role: twist
place: Coral Lookout, golden
who: Finn, Sif
problem: A huge shy shadow glides behind the reef and nobody has seen its face.
why_stack: A coral lookout lifts the party above the ridge.
headline_objective: Spot the shy shadow
ending_pattern: plain
world_change: A coral tower rises with a view over the ridge.
wordless_moment: The shadow ducks behind a rock just as Sif reaches the top.
opening_event: shy_shadow_glides_behind_reef
verb: build
minigame: "base: raise_lookout + jelly sway"
footprint: pyramid_steps
terrain: stack_ledge
set_piece: coral_tower
set_piece_action: smoke_puff
cast_pose: "Sif:point, Finn:hide"
hud_meter: Lookout Height
---
id: underwater_06
role: twist
place: Pearl Parlour, day
who: Sif, Ada, clam elder
problem: The clam elders want their pearls back and Sif has seven in her pockets.
why_stack: Pearls restrung in the elders' pattern repair the necklace.
headline_objective: Restore the clam elders' necklace
ending_pattern: guest
world_change: The necklace gleams whole on the elders' shell.
wordless_moment: A grumpy old clam elder gives one pearl back to Sif.
opening_event: clams_demand_pearls
verb: build
minigame: "base: fill_the_shape + clam snap"
footprint: ribbon_loop
terrain: seabed_sand
set_piece: clam_beds
set_piece_action: bell_ring
cast_pose: "Sif:cheer, clam elder:react"
hud_meter: Necklace Done
---
id: underwater_07
role: combine
place: Ink Reef, night
who: Finn, Ada, Bram, Sif
problem: A black ink cloud puts out every lamp and the party loses each other.
why_stack: A tall lamp tower acts as a beacon to bring them back.
headline_objective: Raise a beacon for the lost party
ending_pattern: twist
world_change: The beacon shines and the lagoon turns blue again.
wordless_moment: Sif, the last missing hero, is found asleep inside a giant clam.
opening_event: ink_swallows_lamps
verb: rescue
minigame: "base: raise_lookout (beacon) + fog"
footprint: snake
terrain: glass_causeway
set_piece: reef_current_wall
set_piece_action: smoke_puff
cast_pose: "Finn:point, Ada:brace"
hud_meter: Beacon Light
---
id: underwater_08
role: combine
place: Crooked Hull, dusk
who: Finn, Bram, Hugo (claw)
problem: A claw pulls planks off the sunken ship and the hold starts to flood.
why_stack: The piece that fits each gap plugs it before the next pull.
headline_objective: Plug the hull before it floods
ending_pattern: plain
world_change: The hull is whole and the ship stops sliding.
wordless_moment: A bubble squeals out of every gap.
opening_event: plank_pulled_from_hull
verb: defend
minigame: "base: plug_breach (D2) + claw pull"
footprint: ship_hull
terrain: ship_deck
set_piece: crooked_hull
set_piece_action: tentacle_grab
cast_pose: "Bram:haul, Hugo:react"
hud_meter: Hull Integrity
---
id: underwater_09
role: combine
place: Whirlpool Mouth, dawn
who: Finn, Sif, Bram
problem: A whirlpool guarded by a sweeping coral gate blocks the lagoon mouth.
why_stack: A breakwater shaped to fit through the gate's sweep calms the water.
headline_objective: Calm the whirlpool for the tow
ending_pattern: reveal
world_change: The water settles and the lagoon mouth opens.
wordless_moment: The calm water uncovers a huge shell on the seabed.
opening_event: whirlpool_gate_sweeps
verb: build
minigame: "module: gate_squeeze (debut) + current"
footprint: spiral
terrain: reef_wall
set_piece: swirl_gate
set_piece_action: tide_surge
cast_pose: "Finn:build, Sif:haul"
hud_meter: Whirl Strength
---
id: underwater_10
role: boss
place: Lagoon Floor, golden
who: Hugo, Hugo's mother, Finn, all heroes
problem: A frantic house-sized crab thrashes through the lagoon clutching Keystone four.
why_stack: Gate walls, a stair up the silt and a shell house calm him in three phases.
headline_objective: Calm Hugo and free Keystone four
ending_pattern: guest
world_change: Keystone four sits on the lamplighter's tower and the lagoon lights up.
wordless_moment: Hugo's enormous mother arrives with the old shell and carries him home.
opening_event: hugo_thrashes_keystone_pearl
verb: defend
minigame: "module: giant_bonk (soft form) + rising silt"
footprint: keyhole
terrain: lagoon_floor
set_piece: hugo_cove
set_piece_action: tentacle_grab
cast_pose: "Hugo:react, Ada:build, Bram:build"
hud_meter: Hugo's Calm
caption: A shy giant crab has lost his house.
---
id: underwater_bonus
role: bonus
place: Chest Cove, golden
who: Finn, Sif
problem: Pearls roll across the seabed on the current.
why_stack: Ramps steer each pearl into Finn's net.
headline_objective: Net the drifting pearls
ending_pattern: twist
world_change: The net is full and glows like a lantern.
wordless_moment: The last pearl cracks open: a seahorse egg.
opening_event: pearls_roll_net_flung
verb: carry
minigame: "base: collect_run + current"
footprint: L_shape
terrain: glass_causeway
set_piece: lamp_post_landing
set_piece_action: lantern_sway
cast_pose: "Finn:cheer, Sif:point"
hud_meter: Pearls Netted
---
id: underwater_h1
role: hard
place: Lamplighter's Landing, night
who: Hugo, Finn
problem: Hugo's giant claw practice grabs blocks off the lighthouse wall.
why_stack: The player holds and patches the wall while he apologises.
headline_objective: Hold the lighthouse wall
ending_pattern: plain
world_change: The lighthouse wall stands and the lamp shines.
wordless_moment: Hugo blows apologetic bubbles.
opening_event: claw_grabs_lighthouse_blocks
verb: defend
minigame: "base: hold_the_wall + claw grab"
footprint: wedge
terrain: ship_deck
set_piece: crooked_hull
set_piece_action: tide_surge
cast_pose: "Finn:brace, Hugo:react"
hud_meter: Lighthouse Wall
---
id: underwater_h2
role: hard
place: Whirlpool Mouth, dusk
who: Finn, fish
problem: The whirlpool wakes at high tide with a school of fish swirling round it.
why_stack: Breakers fitted through the gate calm it before the tide closes it.
headline_objective: Break the tide before the gate closes
ending_pattern: plain
world_change: The tide subsides and the fish settle.
wordless_moment: A school of fish spins like a ribbon.
opening_event: tide_wakes_whirlpool_fish_swirl
verb: survive
minigame: "module: gate_squeeze (recall) + current"
footprint: pinwheel
terrain: dock_pier
set_piece: swirl_gate
set_piece_action: jelly_wobble
cast_pose: "Finn:haul, fish:react"
hud_meter: Tide Level
---
id: underwater_h3
role: hard
place: Hugo's Cove, golden
who: Hugo, Finn, Lana
problem: Hugo's shy housewarming splashes every guest.
why_stack: A roof of blocks over the seats shelters the guests from each splash.
headline_objective: Shelter the guests from splashes
ending_pattern: story
world_change: The guests sit dry and the party begins.
wordless_moment: Hugo laughs for the first time.
opening_event: hugo_splashes_every_guest
verb: defend
minigame: "base: shelter_guest (D4) + splash"
footprint: horseshoe
terrain: dock_pier
set_piece: hugo_cove
set_piece_action: flock_wander
cast_pose: "Lana:cheer, Hugo:react"
hud_meter: Guests Dry
```
