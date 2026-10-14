# Beats: Chapter 8, Midnight Strikes Thirteen (Clockwork)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer.

```yaml
---
id: clockwork_01
role: teach
place: Plaza of Gears, dawn
who: Tock, Wizard, Ada
problem: The plaza's great gear has ground to a halt.
why_stack: Blocks seat the great gear back on its axle.
headline_objective: Seat the plaza's great gear
ending_pattern: plain
world_change: The plaza clock ticks again.
wordless_moment: The Wizard's alarm clock rings deafeningly before it goes in the sack.
opening_event: alarm_clock_rings_gear_stops
verb: build
minigame: "base: build_tower + gear"
footprint: pinwheel
terrain: clock_face
set_piece: great_gear
set_piece_action: gear_grind
cast_pose: "Tock:react, Wizard:point"
hud_meter: Gear Speed
---
id: clockwork_02
role: teach
place: Sorting Floor, day
who: Tock, Glim, Bram
problem: Gears spill along belts and nobody knows which goes where.
why_stack: Gears dropped on the right belt reach the right bin.
headline_objective: Sort the gears for the lift
ending_pattern: plain
world_change: The lift to the tower hums to life.
wordless_moment: Glim unrolls a sorting diagram and trips on it.
opening_event: gears_spill_belts
verb: carry
minigame: "module: sorting_belt (debut) + conveyor"
footprint: zigzag
terrain: conveyor_deck
set_piece: sorting_floor
set_piece_action: gear_grind
cast_pose: "Glim:point, Bram:haul"
hud_meter: Gears Sorted
---
id: clockwork_03
role: teach
place: Tram Stop, golden
who: Tock, citizens
problem: The tram's track ends in mid-air.
why_stack: Track laid across the gap reaches the depot.
headline_objective: Extend the tram to the depot
ending_pattern: twist
world_change: The track meets the depot and the bell rings.
wordless_moment: The tram that rolls in is full of cheering late-comers who waited since yesterday.
opening_event: tram_track_ends_in_air
verb: race
minigame: "module: gap_runner (recall) + tram"
footprint: bridge_span
terrain: tram_track
set_piece: tram_stop
set_piece_action: bell_ring
cast_pose: "citizens:cheer, Tock:hide"
hud_meter: Track Length
---
id: clockwork_04
role: twist
place: Spring Yard, day
who: Bram, Tock
problem: Springs boing across the yard and bounce a bell past Bram's ears.
why_stack: Stops raised at the gate keep the springs in the yard.
headline_objective: Keep the springs in the yard
ending_pattern: plain
world_change: The springs bounce in place behind the stops.
wordless_moment: The bell dings off Bram's helmet.
opening_event: springs_boing_bell
verb: defend
minigame: "base: hold_the_wall (D1) + bounce"
footprint: comb
terrain: stack_ledge
set_piece: spring_yard
set_piece_action: drum_beat
cast_pose: "Bram:brace, Tock:hide"
hud_meter: Springs Inside
---
id: clockwork_05
role: twist
place: Tower Stairs, dusk
who: Ada, Tock
problem: The tower stairs are missing steps and a cuckoo door sits high above.
why_stack: Steps built up to the door let the party climb.
headline_objective: Climb to the cuckoo door
ending_pattern: reveal
world_change: A staircase of blocks reaches the cuckoo door.
wordless_moment: Beside the door is a small blank slot between twelve and one.
opening_event: stairs_missing_steps
verb: race
minigame: "module: foothold_climb (recall) + stairs"
footprint: spiral_terraces
terrain: summit_ledge
set_piece: tower_stairs
set_piece_action: bell_ring
cast_pose: "Ada:build, Tock:haul"
hud_meter: Stair Height
---
id: clockwork_06
role: twist
place: Shutter Hall, night
who: Ada, Boulder
problem: A great pendulum swings and shutters slam on a loose beat.
why_stack: A stack shaped to fit through each swinging shutter lets the party pass.
headline_objective: Slip through the swinging shutters
ending_pattern: plain
world_change: The shutter hall stands open and the pendulum steadies.
wordless_moment: Ada learns to move with the beat instead of against it.
opening_event: pendulum_shutters_slam
verb: survive
minigame: "module: gate_squeeze (recall) + pendulum"
footprint: H_shape
terrain: fort_wall
set_piece: shutter_hall
set_piece_action: pendulum_swing
cast_pose: "Ada:brace, Boulder:haul"
hud_meter: Beat Match
---
id: clockwork_07
role: combine
place: Spring Yard, golden
who: Boulder, Tock, Bram
problem: A giant stopwatch counts down the square's last minute.
why_stack: A flag mast raised before the bell needs a steady base.
headline_objective: Raise the flag before the bell
ending_pattern: guest
world_change: The flag flies as the stopwatch rings.
wordless_moment: Boulder sits on the mast base as a living counterweight.
opening_event: stopwatch_one_minute_boulder_rolls
verb: balance
minigame: "base: tilt + stopwatch"
footprint: ring
terrain: stack_ledge
set_piece: spring_yard
set_piece_action: lamp_flicker
cast_pose: "Boulder:brace, Bram:haul"
hud_meter: Seconds Left
---
id: clockwork_08
role: combine
place: Key Row, dusk
who: Bram, Tock, Glim
problem: Three giant winding keys stand at the plaza's edge and need exact sockets.
why_stack: Key-shaped sockets built one precise piece at a time let the keys turn.
headline_objective: Wind the town's great keys
ending_pattern: story
world_change: The great keys turn and the town winds up.
wordless_moment: For once Bram waits for the last turn instead of swinging his hammer.
opening_event: three_keys_bram_hammer
verb: build
minigame: "base: wind_keys + patience"
footprint: key_shape
terrain: plank_bridge
set_piece: key_row
set_piece_action: drum_beat
cast_pose: "Bram:build, Glim:point"
hud_meter: Keys Wound
---
id: clockwork_09
role: combine
place: Steam Valves, night
who: Wizard, Ada, Glim
problem: The Wizard's rewind spell cracks the steam pipes and the tower shudders.
why_stack: The piece that fits each cracked pipe plugs it before the tower shakes apart.
headline_objective: Plug the cracked steam pipes
ending_pattern: story
world_change: The pipes hold and the tower stops shaking.
wordless_moment: The Wizard's cloud slips quietly away while everyone is busy.
opening_event: rewind_snaps_square_back
verb: defend
minigame: "base: plug_breach (D2) + steam"
footprint: cross
terrain: tram_track
set_piece: steam_valves
set_piece_action: steam_vent
cast_pose: "Wizard:hide, Ada:brace"
hud_meter: Steam Pressure
---
id: clockwork_10
role: boss
place: Tower Stairs, night
who: Madame Cuckoo, Tock, all heroes
problem: The clock spins out of control with Keystone eight turning inside it.
why_stack: Sorted gears, fitted shutters and a thirteenth slot stop it in three phases.
headline_objective: Build the thirteenth hour
ending_pattern: twist
world_change: The clock strikes thirteen and Keystone eight crowns the tower.
wordless_moment: The thirteenth slot opens into a nest box where Cuckoo finally sits.
opening_event: cuckoo_pops_clock_spins
verb: build
minigame: "module: sorting_belt then gate_squeeze (recalls)"
footprint: bullseye
terrain: clock_face
set_piece: tower_stairs
set_piece_action: catapult_volley
cast_pose: "Ada:build, Bram:build, Tock:haul"
hud_meter: Cuckoo's Stress
caption: Every cog must strike the hour. Even the thirteenth.
---
id: clockwork_bonus
role: bonus
place: Clockmaker's Bench, golden
who: Tock, Glim
problem: Tock's music box plays one note short.
why_stack: A chain of tiny dominoes rings the last chime.
headline_objective: Ring the music box's last chime
ending_pattern: reveal
world_change: The music box plays its whole tune.
wordless_moment: The tune is Huffle's lullaby.
opening_event: music_box_one_note_short
verb: build
minigame: "module: domino_run (debut) + chain"
footprint: L_shape
terrain: conveyor_deck
set_piece: sorting_floor
set_piece_action: lamp_flicker
cast_pose: "Tock:cheer, Glim:point"
hud_meter: Chimes Rung
---
id: clockwork_h1
role: hard
place: Steam Valves, dawn
who: Madame Cuckoo, Bram
problem: The boiler builds steam with every tick and Cuckoo calls it within schedule.
why_stack: Vents built in time keep the pressure from ringing the tower.
headline_objective: Vent the steam before it rings
ending_pattern: plain
world_change: The boiler sighs out a cloud of steam.
wordless_moment: Cuckoo checks her watch and shrugs.
opening_event: boiler_builds_steam_overtime
verb: survive
minigame: "base: pressure + vent"
footprint: wedge
terrain: summit_ledge
set_piece: steam_valves
set_piece_action: steam_vent
cast_pose: "Cuckoo:point, Bram:brace"
hud_meter: Steam Pressure
---
id: clockwork_h2
role: hard
place: Shutter Hall, dusk
who: Madame Cuckoo, her mate, Tock
problem: Madame Cuckoo wheels out a cannon that fires wind-up chicks at the shutters.
why_stack: A keep and a return cannon win the duel.
headline_objective: Win the chick-cannon duel
ending_pattern: guest
world_change: The chicks bounce back and the cannon falls silent.
wordless_moment: Her old mate arrives and loads the cannon for her.
opening_event: cannon_fires_windup_chicks
verb: destroy
minigame: "module: catapult_keep (recall) + wall"
footprint: hourglass
terrain: fort_wall
set_piece: shutter_hall
set_piece_action: catapult_volley
cast_pose: "Cuckoo:point, Tock:brace"
hud_meter: Cannon Duel
---
id: clockwork_h3
role: hard
place: Key Row, dawn
who: Tock, Glim
problem: A magnet pulls the giant keys off their sockets mid-turn.
why_stack: Guides of blocks keep the keys aligned.
headline_objective: Guide the wandering keys
ending_pattern: plain
world_change: The keys stay in their sockets and turn.
wordless_moment: Tock chases a key at tortoise speed.
opening_event: magnet_pulls_keys_off_sockets
verb: balance
minigame: "base: tilt + magnet"
footprint: trident
terrain: plank_bridge
set_piece: key_row
set_piece_action: pendulum_swing
cast_pose: "Glim:haul, Tock:hide"
hud_meter: Key Alignment
```
