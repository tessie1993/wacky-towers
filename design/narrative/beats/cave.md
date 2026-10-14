# Beats: Chapter 7, The Lullaby Below (Cave)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. The party is split: Sif and Glim on the near side, the others dig from the far side.

```yaml
---
id: cave_01
role: teach
place: Sealed Entrance, night
who: Sif, Glim
problem: A rockfall seals the entrance and the first chamber is pitch dark.
why_stack: A lamp-post lets the lantern mole light the chamber.
headline_objective: Plant a lamp-post for the mole
ending_pattern: guest
world_change: The first chamber glows warm and gold.
wordless_moment: A tiny glowing nose appears in the dark and bows.
opening_event: rockfall_seals_entrance_nose
verb: build
minigame: "base: build_tower + lantern"
footprint: funnel
terrain: mine_shaft
set_piece: sealed_mouth
set_piece_action: lantern_sway
cast_pose: "Sif:point, Glim:cheer"
hud_meter: Lantern Oil
---
id: cave_02
role: teach
place: Crystal Wall, night
who: Sif, Glim
problem: The crystal pockets in the wall are dark and the way is hidden.
why_stack: Digging down through the packed earth wakes each crystal.
headline_objective: Wake the crystal vein
ending_pattern: plain
world_change: A chain of crystals lights up and shows the way.
wordless_moment: Glim trips over his own scrolls.
opening_event: crystal_pockets_dark_scrolls_trip
verb: race
minigame: "module: deep_dig (debut) + crystal glow"
footprint: comb
terrain: mine_shaft
set_piece: crystal_wall
set_piece_action: gear_grind
cast_pose: "Glim:point, Sif:build"
hud_meter: Crystals Lit
---
id: cave_03
role: teach
place: Rail Ledge, dusk
who: Sif, Glim
problem: Old rails end in thin air over a chasm.
why_stack: A ledge carries the rails across the gap.
headline_objective: Carry the rails across the chasm
ending_pattern: reveal
world_change: Rails run across the chasm on a stone ledge.
wordless_moment: A tiny tunnel opens and shows the far party's lantern light.
opening_event: rails_end_in_air_scrape
verb: carry
minigame: "module: gap_runner (recall) + rails"
footprint: bridge_span
terrain: rail_chasm
set_piece: rail_ledge
set_piece_action: gear_grind
cast_pose: "Sif:haul, Glim:brace"
hud_meter: Rail Length
---
id: cave_04
role: twist
place: Bat Roost, night
who: Sif, Glim, bats, Wizard (through a crack)
problem: Bats startled by a kazoo toot send pebbles onto a baby bat's roost.
why_stack: A roof of blocks shelters the roost through each flutter.
headline_objective: Shelter the baby bat
ending_pattern: plain
world_change: The baby bat sleeps under a block roof.
wordless_moment: Through a crack the Wizard pulls a kazoo from his hat and drops it in the sack.
opening_event: bats_whirl_kazoo_toot
verb: defend
minigame: "base: shelter_guest (D4) + bat swirl"
footprint: arch
terrain: stack_ledge
set_piece: bat_roost
set_piece_action: flock_wander
cast_pose: "Glim:hide, Wizard:hide"
hud_meter: Baby Bat Safe
---
id: cave_05
role: twist
place: Stalagmite Shaft, night
who: Sif, Glim
problem: A cold draught whistles down the shaft with every snore from above.
why_stack: A climb of stalagmites lifts the party above the draught.
headline_objective: Climb above the snore draught
ending_pattern: twist
world_change: The party stands above the draught on a ledge.
wordless_moment: The last stalagmite wiggles: it is Gus's big toe.
opening_event: snore_draught_shaft
verb: race
minigame: "module: foothold_climb (recall) + gust"
footprint: ladder_stair
terrain: ravine_ledges
set_piece: stalagmite_shaft
set_piece_action: snore_gust
cast_pose: "Sif:build, Glim:brace"
hud_meter: Climb Height
---
id: cave_06
role: twist
place: Crystal Wall, dusk
who: Sif, Glim
problem: Mirrored crystals show Sif many small copies of herself and she hesitates.
why_stack: A path built through the reflections matches each mirrored twin.
headline_objective: Find the path through the mirrors
ending_pattern: plain
world_change: A path crosses the mirror room to the far door.
wordless_moment: Glim takes Sif's hand.
opening_event: crystals_copy_sif
verb: build
minigame: "base: mirror twin + path"
footprint: diamond
terrain: fort_wall
set_piece: crystal_wall
set_piece_action: lantern_sway
cast_pose: "Sif:hide, Glim:cheer"
hud_meter: Path Matched
---
id: cave_07
role: combine
place: Tiptoe Gallery, night
who: Sif, Glim, Gus (asleep)
problem: A huge hand lies beside the path and the ceiling rises and falls.
why_stack: Moss walls muffle each footstep so the guardian does not wake.
headline_objective: Sneak past the sleeping guardian
ending_pattern: plain
world_change: Moss walls line the path and the gallery goes quiet.
wordless_moment: Sif and Glim tiptoe under a ceiling that breathes.
opening_event: huge_hand_beside_path
verb: survive
minigame: "module: sneak_route (recall) + silence"
footprint: snake
terrain: plank_bridge
set_piece: gus_gallery
set_piece_action: snore_gust
cast_pose: "Sif:brace, Glim:hide"
hud_meter: Guard Sleep
---
id: cave_08
role: combine
place: Blackout Gallery, night
who: Sif, Glim
problem: Glim's lantern puffs out and the cave goes black.
why_stack: Crystal lights built one by one carry the light through.
headline_objective: Carry the light through the dark
ending_pattern: story
world_change: A trail of lit crystals stretches through the gallery.
wordless_moment: Sif leads by ear while Glim holds her cloak.
opening_event: lantern_puffs_out_black
verb: carry
minigame: "base: light_the_way + dark"
footprint: ring
terrain: lagoon_floor
set_piece: gus_bed
set_piece_action: waterfall_pour
cast_pose: "Sif:point, Glim:haul"
hud_meter: Light Left
---
id: cave_09
role: combine
place: Cart Barricade, dusk
who: Sif, Glim, Bram (through the crack)
problem: Runaway mine carts rumble toward the diggers' camp.
why_stack: Buffers of blocks stop each cart.
headline_objective: Stop the runaway carts
ending_pattern: twist
world_change: Buffers stand across the gallery and the carts stop.
wordless_moment: The last cart carries Glim's lost toolbox, so a lane opens for it.
opening_event: runaway_carts_rumble_down
verb: defend
minigame: "base: hold_the_wall (D1) + cart roll"
footprint: H_shape
terrain: fort_wall
set_piece: cart_barricade
set_piece_action: boulder_roll
cast_pose: "Sif:brace, Glim:haul"
hud_meter: Barricade Strength
---
id: cave_10
role: boss
place: Gus's Cavern, night
who: Gus, Sif, Glim, all heroes
problem: A giant stone guardian stirs and the whole cave shivers.
why_stack: Baffles, a path and a chime tower to his ear lull him in three phases.
headline_objective: Lull the guardian back to sleep
ending_pattern: reveal
world_change: Keystone seven rolls out and the cave stops shaking.
wordless_moment: Gus hums the missing note of the Sky Lullaby.
opening_event: gus_stirs_cave_shivers
verb: defend
minigame: "base: hold_the_wall + chime tower"
footprint: dumbbell
terrain: lagoon_floor
set_piece: gus_bed
set_piece_action: bell_ring
cast_pose: "Sif:build, Ada:build, Bram:build"
hud_meter: Gus's Sleep
caption: Tiptoe now. The stone guardian is sleeping.
---
id: cave_bonus
role: bonus
place: Mapmaker's Nook, golden
who: Glim, Sif
problem: Glim's blueprint pages blow away down the shaft.
why_stack: Ledges built along the shaft catch each page.
headline_objective: Catch the blown blueprint pages
ending_pattern: secret
world_change: The pages stack neatly in Glim's arms.
wordless_moment: The last page shows something big and round stamped with the Wizard's star.
opening_event: pages_blow_down_shaft
verb: carry
minigame: "base: collect_run + draught"
footprint: L_shape
terrain: ravine_ledges
set_piece: sealed_mouth
set_piece_action: waterfall_pour
cast_pose: "Glim:haul, Sif:point"
hud_meter: Pages Caught
---
id: cave_h1
role: hard
place: Rail Ledge, dawn
who: Glim, Sif
problem: A cart rolls off carrying Glim's scrolls with the chasm ahead.
why_stack: A track loop built in time catches the cart.
headline_objective: Catch Glim's runaway cart
ending_pattern: plain
world_change: The cart circles the loop and stops.
wordless_moment: Glim chases it with his arms out.
opening_event: cart_rolls_with_scrolls
verb: race
minigame: "base: outrun_hazard + rails"
footprint: figure_eight
terrain: rail_chasm
set_piece: rail_ledge
set_piece_action: boulder_roll
cast_pose: "Glim:haul, Sif:brace"
hud_meter: Cart Distance
---
id: cave_h2
role: hard
place: Bat Roost, dusk
who: Bram, Boulder, Glim
problem: A second rockfall buries the shaft while Bram and Boulder dig from above.
why_stack: Props hold the roof as they dig through.
headline_objective: Prop the roof for the diggers
ending_pattern: guest
world_change: A tunnel opens and the diggers climb through.
wordless_moment: Boulder bursts out sitting on the last boulder.
opening_event: second_rockfall_buries_shaft
verb: survive
minigame: "base: hold_the_wall + falling rock"
footprint: twin_towers
terrain: stack_ledge
set_piece: bat_roost
set_piece_action: steam_vent
cast_pose: "Bram:build, Boulder:brace"
hud_meter: Roof Strength
---
id: cave_h3
role: hard
place: Tiptoe Gallery, night
who: Glim, Sif
problem: Glim has wandered into a dead end and his headlamp blinks from far down.
why_stack: A ladder dug down to him reaches him before the lamp fades.
headline_objective: Dig a ladder to Glim
ending_pattern: plain
world_change: A ladder of blocks lifts Glim out.
wordless_moment: His headlamp blinks like a small star.
opening_event: headlamp_blinks_far_down
verb: rescue
minigame: "module: deep_dig (recall) + lamp"
footprint: tadpole
terrain: plank_bridge
set_piece: gus_gallery
set_piece_action: steam_vent
cast_pose: "Sif:haul, Glim:react"
hud_meter: Ladder Length
```
