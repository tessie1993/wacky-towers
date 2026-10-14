# Beats: Chapter 1, The Windy Picnic (Meadow)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level. Field limit: one sentence of 20 words or fewer. `headline_objective` is 8 words or fewer and
names a story object. Scene ids are the proposals in story section 5b. Wordless in play: the `wordless_moment` is an animation or sound, never a line of text.

```yaml
---
id: meadow_01
role: teach
place: Hearth Stump, dawn
who: Wizard, Ada
problem: The island has a bare stump and nothing to hold on to.
why_stack: The first course of blocks becomes the Hearth Tower's foundation.
headline_objective: Plant the Hearth Tower's first course
ending_pattern: plain
world_change: The first block hums and the stump glows green.
wordless_moment: A careless block wobbles and giggles beside the humming one.
opening_event: spoon_pops_block_hums
verb: build
minigame: "base: build_tower + sticky landing"
footprint: octagon
terrain: floating_island
set_piece: hearth_stump
set_piece_action: bell_ring
cast_pose: "Wizard:point, Ada:cheer"
hud_meter: Hearth Hum
---
id: meadow_02
role: teach
place: Hill Shoulder, day
who: Wizard, Ada, Bram
problem: Gert's puffs bend a new sprout flat.
why_stack: A curved wall of blocks breaks the wind around the sprout.
headline_objective: Shelter the sprout from the wind
ending_pattern: twist
world_change: The sprout stands tall behind a curved hedge-wall.
wordless_moment: The Wizard's star sign spins on top as a weathervane.
opening_event: star_sign_nailed_sprout_bends
verb: defend
minigame: "base: hold_the_wall + gust"
footprint: crescent
terrain: hilltop_ledge
set_piece: hearth_stump
set_piece_action: wind_gust
cast_pose: "Ada:brace, Bram:point"
hud_meter: Sprout Lean
---
id: meadow_03
role: teach
place: Brook Footbridge, day
who: Biscuit, Ada, sheep
problem: A rising brook has swallowed the footpath to the picnic lawn.
why_stack: The player builds the span before the water rises over it.
headline_objective: Bridge the brook before it rises
ending_pattern: guest
world_change: A plank bridge arches over the brook and the flock crosses.
wordless_moment: Biscuit trots over early and the whole flock follows in a woolly parade.
opening_event: brook_swallows_path_biscuit_barks
verb: race
minigame: "module: gap_runner (debut) + rising water"
footprint: bridge_span
terrain: plank_bridge
set_piece: footbridge
set_piece_action: waterfall_pour
cast_pose: "Biscuit:react, Ada:point"
hud_meter: Brook Height
---
id: meadow_04
role: twist
place: Hillside Pen, golden
who: Gert, Biscuit, Bram, sheep
problem: Gert's whirl has scattered the flock across the hill.
why_stack: Fence blocks steer the sheep into the pen.
headline_objective: Herd the flock into the pen
ending_pattern: twist
world_change: The pen gate closes on a calm flock.
wordless_moment: The last sheep through the gate is Bram in a borrowed fleece.
opening_event: gert_zips_flock_bounces
verb: rescue
minigame: "module: sneak_route herd form (debut) + wander"
footprint: L_shape
terrain: floating_island
set_piece: sheep_pen
set_piece_action: flock_wander
cast_pose: "Bram:hide, Biscuit:react"
hud_meter: Flock Safe
---
id: meadow_05
role: twist
place: Hedge Gate, day
who: Bram, Sif, gnomes, sheep
problem: Gnomes' stones keep opening holes in the hedge.
why_stack: Only the piece that fits each hole seals it before the next throw.
headline_objective: Plug the hedge before sheep slip out
ending_pattern: reveal
world_change: The hedge is whole again and thick with new leaves.
wordless_moment: The last hole opens from the inside, where a sheep is peering at the windmill.
opening_event: hedge_stone_thuds_hole_opens
verb: defend
minigame: "base: plug_breach (D2) + stone throw"
footprint: U_bay
terrain: fort_wall
set_piece: hedge_gate
set_piece_action: rock_throw
cast_pose: "Bram:brace, Sif:point"
hud_meter: Hedge Health
---
id: meadow_06
role: twist
place: Picnic Lawn, day
who: Ada, Sif, Wizard
problem: The picnic blanket lies in shreds and the flower bed has holes.
why_stack: Coloured blocks patch the pattern square by square.
headline_objective: Restore the flower-bed pattern
ending_pattern: plain
world_change: A bright checkered blanket spreads over the lawn.
wordless_moment: Ada smooths the last corner with her gauntlet.
opening_event: blanket_shreds_flutter
verb: build
minigame: "base: fill_the_shape + sheep trample"
footprint: diamond
terrain: stepped_ravine
set_piece: picnic_blanket
set_piece_action: flock_wander
cast_pose: "Ada:build, Sif:haul"
hud_meter: Pattern Done
---
id: meadow_07
role: combine
place: Windmill Foot, dawn
who: Biscuit, Ada, Gert (distant)
problem: Fog hides the sheep and the picnic hamper.
why_stack: A tall lookout lifts Biscuit above the mist to spot them.
headline_objective: Raise a lookout above the fog
ending_pattern: reveal
world_change: The fog thins and the flock's ears pop up in a line.
wordless_moment: Ada points at a glow caught in a bonnet ribbon: Keystone one.
opening_event: fog_rolls_ears_show
verb: build
minigame: "base: raise_lookout + fog"
footprint: T_shape
terrain: hilltop_ledge
set_piece: windmill
set_piece_action: sails_turn
cast_pose: "Ada:point, Biscuit:react"
hud_meter: Lookout Height
---
id: meadow_08
role: combine
place: Lily Pond Bank, golden
who: Bram, Biscuit, lamb
problem: Dewdrops shaken from Gert's bonnet soak a lamb under a basket.
why_stack: A block roof keeps the lamb dry through each shower.
headline_objective: Shelter the lamb from the dew
ending_pattern: plain
world_change: The lamb trots out dry onto the lawn.
wordless_moment: Bram holds up a huge leaf like an umbrella and grins.
opening_event: dewdrops_shake_lamb_bleats
verb: defend
minigame: "base: shelter_guest (D4) + dew drops"
footprint: ring
terrain: raft
set_piece: picnic_blanket
set_piece_action: waterfall_pour
cast_pose: "Bram:brace, lamb:react"
hud_meter: Lamb Dryness
---
id: meadow_09
role: combine
place: Windmill Hill, dusk
who: Gert, Ada, Wizard, sheep
problem: The hilltop tips like a tray and the sheep slide.
why_stack: Counterweights on the high side level the hill.
headline_objective: Level the tipping hilltop
ending_pattern: guest
world_change: The hill sits flat again and the sails slow.
wordless_moment: Gert slides down the tilt giggling and lands in the grass.
opening_event: sails_spin_backward_hill_tips
verb: balance
minigame: "base: tilt (topsy tumble) + counterweight"
footprint: hourglass
terrain: ravine_ledges
set_piece: windmill
set_piece_action: sails_turn
cast_pose: "Ada:brace, Wizard:hide"
hud_meter: Hill Tilt
---
id: meadow_10
role: boss
place: Windmill Hill, golden
who: Gert, Biscuit, all heroes
problem: Gert holds Keystone one in her ribbons and whirls round the mill.
why_stack: A windbreak, a pen-ramp and a mill tower tire her out in three phases.
headline_objective: Calm Gert and free Keystone one
ending_pattern: story
world_change: Keystone one settles on the Hearth Tower and the island lights up.
wordless_moment: Gert sits down dizzy, wipes a tear, and is handed a sandwich.
opening_event: gert_towers_ribbons_fly
verb: defend
minigame: "base: hold_the_wall then module: sneak_route (recall)"
footprint: spiral_terraces
terrain: stepped_ravine
set_piece: mill_tower
set_piece_action: wind_gust
cast_pose: "Ada:brace, Bram:haul, Sif:build"
hud_meter: Gert's Dizziness
caption: A bonnet-wearing whirlwind has scattered the picnic sheep.
---
id: meadow_bonus
role: bonus
place: Footbridge Gorge, golden
who: Gert, Biscuit, Wizard
problem: A kite carries the picnic hamper toward the gorge.
why_stack: A launch tower lets the kite carry the hamper over the bridge.
headline_objective: Carry the picnic hamper by kite
ending_pattern: plain
world_change: The hamper lands safely on the far lawn.
wordless_moment: The Wizard's cloud gets towed along as the kite's tail.
opening_event: gust_lifts_kite_hamper
verb: carry
minigame: "base: cart_convoy + balloon lift"
footprint: arrow
terrain: ravine_ledges
set_piece: footbridge
set_piece_action: bell_ring
cast_pose: "Gert:cheer, Biscuit:point"
hud_meter: Kite Height
---
id: meadow_h1
role: hard
place: Beanstalk Row, night
who: Gert, Biscuit
problem: Overnight beanstalks leave lambs stranded on top.
why_stack: Rope bridges from stalk to stalk bring each lamb down.
headline_objective: Bring the lambs down the beanstalks
ending_pattern: plain
world_change: The stalks bow gently and the lambs bounce to the ground.
wordless_moment: A lamb waves from the highest leaf.
opening_event: seeds_burst_beanstalks_night
verb: rescue
minigame: "module: gap_runner (recall) + sprouts"
footprint: comb
terrain: fort_wall
set_piece: sheep_pen
set_piece_action: root_whip
cast_pose: "Gert:cheer, Biscuit:hide"
hud_meter: Lambs Rescued
---
id: meadow_h2
role: hard
place: Pond Stage, dusk
who: Gert, Sif, Biscuit
problem: Gert tries building a dance stage and her whirl spits out the blocks.
why_stack: The player races Gert's tower with a stage of their own.
headline_objective: Out-build Gert's dance stage
ending_pattern: story
world_change: The two stages join into one giant dance floor.
wordless_moment: Gert and Sif take a bow on the joined stage.
opening_event: gert_spits_blocks_rival_stage
verb: build
minigame: "base: race_rival + gust"
footprint: island_chain
terrain: raft
set_piece: mill_tower
set_piece_action: root_whip
cast_pose: "Gert:build, Sif:cheer"
hud_meter: Stage Height
---
id: meadow_h3
role: hard
place: Hedge Gate, night
who: Gert, Ada, gnomes
problem: The gnomes return with Gert riding their wheelbarrow, throwing stones in a new rhythm.
why_stack: A thick wall holds until the barrow runs out of stones.
headline_objective: Hold the hedge against the barrow
ending_pattern: plain
world_change: The barrow tips over and spills only turnips.
wordless_moment: Ada raises her shield and a turnip bounces off it.
opening_event: barrow_rolls_in_stones_fly
verb: defend
minigame: "base: hold_the_wall + stone throw"
footprint: twin_towers
terrain: plank_bridge
set_piece: hedge_gate
set_piece_action: rock_throw
cast_pose: "Ada:brace, gnomes:haul"
hud_meter: Hedge Health
```
