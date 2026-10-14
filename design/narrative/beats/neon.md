# Beats: Chapter 9, The Brightest Silence (Neon)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. The low point: beats 06 to 08 stay hollow (no warm payoffs). Kid-safe: lights go out and come back.

```yaml
---
id: neon_01
role: teach
place: Tram Platform, night
who: Ada, Bram, Sif
problem: The platform is empty and blazing, and the Wizard's hat lies on the seat.
why_stack: A stair to the lit map lets the party read where the thread points.
headline_objective: Read the map above the platform
ending_pattern: plain
world_change: The map lights up and the thread points into darkness.
wordless_moment: Ada picks up the battered hat.
opening_event: tram_doors_close_hat_on_seat
verb: build
minigame: "base: raise_lookout + glow"
footprint: arrow
terrain: tram_track
set_piece: tram_platform
set_piece_action: lamp_flicker
cast_pose: "Ada:point, Sif:hide"
hud_meter: Map Lit
---
id: neon_02
role: teach
place: Frozen Junction, dusk
who: Ada, Sif, Lana (far off)
problem: Every light is stuck red and hover-cars hang frozen over the junction.
why_stack: Crossing towers carry the party over the frozen cars.
headline_objective: Cross the frozen junction
ending_pattern: plain
world_change: A line of towers spans the junction.
wordless_moment: A woolly alpaca knitting a dark thread is gone when they arrive.
opening_event: lights_stuck_red_cars_frozen
verb: race
minigame: "module: gap_runner (recall) + frozen traffic"
footprint: cross
terrain: stack_ledge
set_piece: crossing_towers
set_piece_action: firework_pop
cast_pose: "Sif:build, Lana:haul"
hud_meter: Junction Cleared
---
id: neon_03
role: teach
place: Moving Walkway, night
who: Ada, Bram, Sif, Lumen
problem: A moving walkway carries the heroes apart.
why_stack: Rails of blocks keep them together on the belt.
headline_objective: Rail the walkway to stay together
ending_pattern: twist
world_change: The heroes ride together to a small lit workshop.
wordless_moment: A tiny lamp on legs rolls alongside Sif.
opening_event: walkway_carries_apart_lamp_rolls
verb: carry
minigame: "base: cart_convoy + conveyor"
footprint: ribbon
terrain: conveyor_deck
set_piece: moving_walkway
set_piece_action: spotlight_sweep
cast_pose: "Bram:brace, Lumen:point"
hud_meter: Walkway Drift
---
id: neon_04
role: twist
place: Screen Arcade, night
who: Ada, Sif, Lumen
problem: Every screen replays the heroes' old pratfalls on a loop.
why_stack: A pixel wall built over the screens covers the loop.
headline_objective: Cover the looping screens
ending_pattern: reveal
world_change: The loops go dark behind a wall of pixels.
wordless_moment: One screen shows Meadow's windmill stopping and Biscuit looking up.
opening_event: screens_replay_pratfalls
verb: build
minigame: "base: fill_the_shape + loop"
footprint: zigzag
terrain: glass_causeway
set_piece: screen_arcade
set_piece_action: lamp_flicker
cast_pose: "Ada:hide, Sif:point"
hud_meter: Screens Covered
---
id: neon_05
role: twist
place: Rooftop, dusk
who: Bram, Ada, Sif
problem: A cloud-shaped sign makes Bram hope the Wizard is up there.
why_stack: A stair of blocks climbs the sign to look.
headline_objective: Climb to the cloud sign
ending_pattern: twist
world_change: A stair stands against the sign.
wordless_moment: Ada dips the hat and finds nothing, and Bram sits down in silence.
opening_event: cloud_sign_hat_dipped_empty
verb: race
minigame: "base: build_stair + blink"
footprint: cloud_blob
terrain: summit_ledge
set_piece: rooftop_stage
set_piece_action: firework_pop
cast_pose: "Bram:build, Ada:hide"
hud_meter: Sign Height
---
id: neon_06
role: twist
place: Arcade Plaza, night
who: Ada, Sif, Lumen
problem: A fireworks rig starts a countdown with nobody to cheer.
why_stack: Filling each launch ring before its fuse burns down stops the launch.
headline_objective: Defuse the fireworks rings
ending_pattern: plain
world_change: The rig stands cold and the rockets sparkle sadly.
wordless_moment: Nobody claps.
opening_event: fireworks_rig_countdown
verb: survive
minigame: "module: fuse_rings (debut) + countdown"
footprint: star_five
terrain: hex_deck
set_piece: screen_arcade
set_piece_action: confetti_burst
cast_pose: "Sif:build, Ada:brace"
hud_meter: Fuse Burn
---
id: neon_07
role: combine
place: Moving Walkway, golden
who: Ada, Glim, Lumen
problem: Neon paint rains on the empty street and stains Ada's armour pink.
why_stack: Claiming the floor in the player's colour keeps the street from being painted over.
headline_objective: Claim the street in your colour
ending_pattern: guest
world_change: The street floor shows the player's colour.
wordless_moment: Glim arrives with his lantern, and nobody laughs.
opening_event: neon_paint_rains_ada_pink
verb: build
minigame: "module: splat_claim (recall) + paint"
footprint: S_curve
terrain: hex_deck
set_piece: moving_walkway
set_piece_action: waterfall_pour
cast_pose: "Ada:point, Glim:haul"
hud_meter: Paint Share
---
id: neon_08
role: combine
place: Relay Mast, dusk
who: Ada, Bram, Lumen
problem: A relay mast shows Meadow's windmill sagging with its thread drooping.
why_stack: Counterweights on the mast keep the thread level and hold the sky up.
headline_objective: Hold the sagging thread level
ending_pattern: plain
world_change: On the far screen the windmill steadies.
wordless_moment: Lumen's glow dims a notch.
opening_event: relay_mast_screen_sag
verb: balance
minigame: "module: wobble_plate (recall) + sag"
footprint: twin_towers
terrain: fort_wall
set_piece: sag_relay
set_piece_action: cannon_volley
cast_pose: "Bram:build, Lumen:point"
hud_meter: Thread Sag
---
id: neon_09
role: combine
place: Rooftop Stage, night
who: Ada, Bram, Sif, Lumen
problem: A surge blacks out the city and Lumen's light fades while Ada sinks onto the curb.
why_stack: A lightning tower grounds the surge and restarts the lamps.
headline_objective: Ground the surge and wake Lumen
ending_pattern: story
world_change: The city's lights flicker back on and Lumen blinks awake.
wordless_moment: Sif sets her best treasure on top and Bram builds gently beside her.
opening_event: city_blackout_lumen_fades
verb: build
minigame: "base: raise_lookout + surge"
footprint: ring
terrain: summit_ledge
set_piece: rooftop_stage
set_piece_action: drum_beat
cast_pose: "Ada:hide, Bram:build, Sif:haul"
hud_meter: Lumen Charge
---
id: neon_10
role: boss
place: Billboard Stage, night
who: Marquee Mae, Lumen, all heroes
problem: A lonely billboard sweeps spotlights over an empty plaza with Keystone nine as her light.
why_stack: Screens, fuse rings and a lit stage give her an audience in three phases.
headline_objective: Give Mae an audience
ending_pattern: guest
world_change: Keystone nine crowns the billboard and the plaza fills with light.
wordless_moment: Lumen's hundred lamp-bot friends arrive, real and cheering.
opening_event: mae_blazes_spotlights
verb: defend
minigame: "module: fuse_rings (recall) + hold_the_wall"
footprint: crescent
terrain: stack_ledge
set_piece: billboard_face
set_piece_action: spotlight_sweep
cast_pose: "Mae:point, Lumen:cheer, Ada:build"
hud_meter: Mae's Crowd
caption: The brightest town is the loneliest. The cloud is gone.
---
id: neon_bonus
role: bonus
place: Workshop Roof, night
who: Lumen, lamp-bots, heroes
problem: Lumen's tiny party needs a dance floor.
why_stack: A tower of blocks makes a dance floor for the lamps.
headline_objective: Build the party's dance-floor tower
ending_pattern: secret
world_change: The lamps dance on a lit tower.
wordless_moment: The dance spells "come up" in the sky.
opening_event: lumen_throws_party
verb: build
minigame: "base: raise_lookout + beats"
footprint: clover
terrain: glass_causeway
set_piece: lamp_workshop
set_piece_action: confetti_burst
cast_pose: "Lumen:cheer, Sif:point"
hud_meter: Dance Height
---
id: neon_h1
role: hard
place: Tram Platform, dusk
who: Mae, Lumen
problem: Mae speeds up the street's rush hour with lamp-bots whooshing past.
why_stack: A paved lane keeps Lumen's cart ahead of the whoosh.
headline_objective: Pave a lane for Lumen's cart
ending_pattern: plain
world_change: The lane holds and the cart rolls home.
wordless_moment: Mae cheers each bot that passes.
opening_event: rush_hour_whooshes
verb: race
minigame: "module: paver_rally (recall) + rush"
footprint: bridge_span
terrain: tram_track
set_piece: tram_platform
set_piece_action: drum_beat
cast_pose: "Mae:point, Lumen:haul"
hud_meter: Lane Length
---
id: neon_h2
role: hard
place: Billboard Stage, night
who: Mae, Lumen
problem: Spotlights sweep faster as Mae rehearses a new act.
why_stack: Screens built in time shield the crowd.
headline_objective: Shield the crowd from spotlights
ending_pattern: reveal
world_change: The screens stand and the crowd stays lit.
wordless_moment: The beams draw a staircase into the clouds.
opening_event: spotlights_speed_up_stairs
verb: defend
minigame: "base: hold_the_wall + spotlight"
footprint: comb
terrain: conveyor_deck
set_piece: billboard_face
set_piece_action: cannon_volley
cast_pose: "Lumen:brace, Mae:point"
hud_meter: Spotlight Speed
---
id: neon_h3
role: hard
place: Workshop Roof, dawn
who: Mae, Lumen, Glim
problem: The street's colours swap every second as Mae tries a new look.
why_stack: Claiming the floor before each swap keeps the colour.
headline_objective: Claim the floor before the swap
ending_pattern: plain
world_change: The floor shows the player's colour.
wordless_moment: Mae flashes a new look every second.
opening_event: colours_swap_every_second
verb: build
minigame: "module: splat_claim (recall) + colour swap"
footprint: heart
terrain: fort_wall
set_piece: lamp_workshop
set_piece_action: waterfall_pour
cast_pose: "Glim:point, Lumen:hide"
hud_meter: Colour Share
```
