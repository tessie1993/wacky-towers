# Beats: Chapter 10, The Sulking Sky (Celestial)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer.

```yaml
---
id: celestial_01
role: teach
place: Star Dock, night
who: Wizard, Ada, Bram, Sif
problem: The Wizard waits on a small cloud, hatless and ashamed.
why_stack: A landing dock lets his cloud tie up so he can step off.
headline_objective: Dock the Wizard's cloud
ending_pattern: story
world_change: The dock glows and the Wizard steps onto the star.
wordless_moment: Ada puts his hat back on his head without a word.
opening_event: beam_sets_down_hatless_wizard
verb: build
minigame: "base: build_tower + drift"
footprint: star_five
terrain: floating_island
set_piece: star_dock
set_piece_action: firework_pop
cast_pose: "Wizard:hide, Ada:cheer"
hud_meter: Dock Steadiness
---
id: celestial_02
role: teach
place: Constellation Stone, night
who: Glim, Sif, Wizard
problem: One star is missing from Glim's chart and the real sky has a hole.
why_stack: A stone of the right shape plugs the gap.
headline_objective: Fill the missing star
ending_pattern: plain
world_change: The constellation completes and a path lights up.
wordless_moment: Glim checks the chart twice.
opening_event: star_map_missing_star
verb: build
minigame: "base: fill_the_shape + lantern"
footprint: diamond
terrain: hex_deck
set_piece: constellation_stone
set_piece_action: lantern_sway
cast_pose: "Glim:point, Sif:build"
hud_meter: Stars Placed
---
id: celestial_03
role: teach
place: Starlight Causeway, dusk
who: Biscuit, Crumb, Finn, Lana, heroes
problem: The solar wind tugs at a glass causeway and friends wait on the far side.
why_stack: A rising stair of glass steps lets them climb in against the wind.
headline_objective: Raise a stair for the friends
ending_pattern: guest
world_change: A glass stair carries every earlier ally to the party.
wordless_moment: Biscuit, Crumb and Finn run, swim and sail in.
opening_event: friends_appear_far_side
verb: carry
minigame: "module: sky_steps (debut) + gust"
footprint: ladder_stair
terrain: glass_causeway
set_piece: star_causeway
set_piece_action: wind_gust
cast_pose: "Biscuit:cheer, Lana:haul"
hud_meter: Stair Height
---
id: celestial_04
role: twist
place: Starlight Causeway, night
who: Ada, Boulder, Glim
problem: Football-sized shards bounce across the causeway from above.
why_stack: A roof of blocks shelters the friends from each shard.
headline_objective: Shield the causeway from the shards
ending_pattern: twist
world_change: The roof holds and the shards pile up around it.
wordless_moment: The last shard splits to show a glowing seed: they are star-seeds tossed like toys.
opening_event: shards_bounce_across_causeway
verb: defend
minigame: "base: hold_the_wall + meteor fall"
footprint: ribbon
terrain: glass_causeway
set_piece: star_causeway
set_piece_action: meteor_fall
cast_pose: "Ada:brace, Boulder:brace"
hud_meter: Roof Strength
---
id: celestial_05
role: twist
place: Peek-a-Boo Tower, night
who: Ada, Wizard, Huffle (eyes)
problem: A huge sulking shadow sits above a curl of cloud and nobody can see its face.
why_stack: A tower raised above the blanket lets them look.
headline_objective: Raise the tower to see Huffle
ending_pattern: reveal
world_change: A tower stands above the blanket and a pair of eyes peeks out.
wordless_moment: Ada steps up first and waves, and the giant turns out to be a baby.
opening_event: shadow_above_blanket
verb: build
minigame: "base: raise_lookout + sway"
footprint: pyramid_steps
terrain: summit_ledge
set_piece: peek_tower
set_piece_action: meteor_fall
cast_pose: "Ada:point, Wizard:hide"
hud_meter: Tower Height
---
id: celestial_06
role: twist
place: Star Dome, night
who: Glim, Sif, Wizard
problem: A dome holds half a star picture with spark points scattered about.
why_stack: Blocks fill each missing spark.
headline_objective: Complete the constellation
ending_pattern: secret
world_change: The dome shines with a finished star picture.
wordless_moment: The picture is a ring with spokes that nobody recognises.
opening_event: dome_half_picture
verb: build
minigame: "base: fill_the_shape + sparks"
footprint: ring
terrain: hex_deck
set_piece: star_dome
set_piece_action: bell_ring
cast_pose: "Glim:build, Wizard:point"
hud_meter: Sparks Lit
---
id: celestial_07
role: combine
place: Peek-a-Boo Tower, dawn
who: Wizard, Lana, Ada
problem: A vast quilted blanket drifts over the lookout and everyone loses sight of each other.
why_stack: A steady lookout with glow-lamps keeps its balance through the dark.
headline_objective: Keep the lookout steady in the dark
ending_pattern: twist
world_change: Glow-lamps light the lookout and the dark lifts.
wordless_moment: The blanket's edge is hand-knitted: Lana's own stitches.
opening_event: quilted_blanket_drifts_dark
verb: balance
minigame: "module: wobble_plate (recall) + dark"
footprint: crescent
terrain: cloud_deck
set_piece: peek_tower
set_piece_action: wind_gust
cast_pose: "Wizard:brace, Lana:point"
hud_meter: Lookout Lean
---
id: celestial_08
role: combine
place: Star Dome, night
who: Wizard, Sif, Huffle, Boulder
problem: Gravity tilts so blocks fall sideways and the friends have no footing.
why_stack: Blocks built on every wall of the dome give them somewhere to stand.
headline_objective: Give everyone footing in the dome
ending_pattern: plain
world_change: Footholds cover every wall and everyone stands.
wordless_moment: A baby rattle falls from the Wizard's hat and Sif tosses it up to Huffle, who hushes.
opening_event: gravity_tilts_rattle_drops
verb: survive
minigame: "base: pull_push_field + gravity"
footprint: pinwheel
terrain: cloud_deck
set_piece: star_dome
set_piece_action: rock_throw
cast_pose: "Sif:haul, Boulder:brace"
hud_meter: Gravity Tilt
---
id: celestial_09
role: combine
place: Cloud Steps, dusk
who: Lana, Boulder, all allies
problem: Huffle's blanket rises over the causeway like milk.
why_stack: Steps built ahead of the cloud carry everyone up.
headline_objective: Climb above the rising cloud
ending_pattern: guest
world_change: Every friend stands above the cloud.
wordless_moment: Boulder braces the last step.
opening_event: blanket_rises_like_milk
verb: survive
minigame: "module: foothold_climb (recall) + cloud flood"
footprint: spiral_terraces
terrain: plank_bridge
set_piece: cloud_steps
set_piece_action: tide_surge
cast_pose: "Lana:haul, Boulder:brace"
hud_meter: Cloud Level
---
id: celestial_10
role: boss
place: Spire Top, night
who: Huffle, Wizard, all heroes, all allies
problem: Huffle sulks above everything with Keystone ten in her blanket and twelve in her fist.
why_stack: A gust wall, shields and a tall cradle lookout lift her view in three phases.
headline_objective: Lift Huffle above her blanket
ending_pattern: story
world_change: Keystone ten crowns the spire and the sky hums.
wordless_moment: Huffle sees the whole sky, stops crying, and keeps Keystone twelve for a party.
opening_event: huffle_face_fills_sky
verb: build
minigame: "base: hold_the_wall + raise_lookout"
footprint: cloud_blob
terrain: summit_ledge
set_piece: spire_top
set_piece_action: tide_surge
cast_pose: "Huffle:hide, Ada:build, Wizard:build"
hud_meter: Huffle's Sulk
caption: At the top of the sky, someone small is sulking.
---
id: celestial_bonus
role: bonus
place: Star Slide, night
who: Wizard, Glim, Sif
problem: A gust snatches the Wizard's hat and it tumbles across the starfield.
why_stack: Glass ramps steer the hat back.
headline_objective: Steer the Wizard's hat home
ending_pattern: reveal
world_change: The hat lands back on the Wizard.
wordless_moment: Under the brim is a folded faded ribbon.
opening_event: gust_snatches_hat
verb: race
minigame: "base: outrun_hazard + gust"
footprint: S_curve
terrain: dock_pier
set_piece: star_slide
set_piece_action: lantern_sway
cast_pose: "Wizard:point, Glim:haul"
hud_meter: Hat Distance
---
id: celestial_h1
role: hard
place: Star Dock, night
who: Huffle, Biscuit, Crumb, Finn, Nutmeg
problem: Huffle's hiccups make the star where four friends stand wobble.
why_stack: Steps built ahead of the wobble bring them down.
headline_objective: Bring the stranded friends down
ending_pattern: plain
world_change: A stair of blocks carries the friends to the dock.
wordless_moment: Each hic makes the star bounce.
opening_event: star_wobbles_with_each_hic
verb: rescue
minigame: "module: foothold_climb (recall) + hiccup"
footprint: island_chain
terrain: dock_pier
set_piece: star_dock
set_piece_action: bell_ring
cast_pose: "Huffle:cheer, Biscuit:react"
hud_meter: Hiccup Gap
---
id: celestial_h2
role: hard
place: Spire Top, dawn
who: Huffle, Sif
problem: Huffle's wishes spin upward and the stars wobble.
why_stack: A steady lookout rides out each wish.
headline_objective: Steady the lookout for the wishes
ending_pattern: secret
world_change: The lookout stands steady and the stars calm.
wordless_moment: The last wish writes itself across the sky: COME TO MY FAIR.
opening_event: wishes_spin_upward
verb: balance
minigame: "base: tilt + wish spin"
footprint: boomerang
terrain: plank_bridge
set_piece: spire_top
set_piece_action: firework_pop
cast_pose: "Sif:point, Huffle:cheer"
hud_meter: Wish Spin
---
id: celestial_h3
role: hard
place: Cloud Steps, dawn
who: Huffle, Glim
problem: Huffle shuffles the star picture for fun and every spark swaps place.
why_stack: Blocks refill the picture faster than she shuffles it.
headline_objective: Refill the star picture
ending_pattern: plain
world_change: The star picture shines whole.
wordless_moment: Huffle giggles at each shuffle.
opening_event: huffle_shuffles_stars
verb: build
minigame: "base: fill_the_shape + shuffle"
footprint: clover
terrain: floating_island
set_piece: cloud_steps
set_piece_action: rock_throw
cast_pose: "Glim:haul, Huffle:hide"
hud_meter: Sparks Lit
```
