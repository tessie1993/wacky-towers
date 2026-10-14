# Beats: Chapter 5, The Night Watch (Lava)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. Tension is real but kid-safe: lights, smoke and cracks, never on-screen harm.

```yaml
---
id: lava_01
role: teach
place: Rim Landing, dusk
who: Boulder, Wizard, Ada
problem: Boulder's rock cart tips on a rim that shivers with a deep rumble.
why_stack: A flat basalt platform parks the cart steadily.
headline_objective: Park Boulder's cart safely
ending_pattern: plain
world_change: The cart sits level and the rumble quiets for a moment.
wordless_moment: Boulder sits on the tipping cart to steady it.
opening_event: hippo_sits_on_tipping_cart
verb: carry
minigame: "base: cart_convoy + quake"
footprint: wedge
terrain: rim_ledge
set_piece: rim_landing
set_piece_action: boulder_roll
cast_pose: "Boulder:brace, Ada:point"
hud_meter: Quake Meter
---
id: lava_02
role: teach
place: Egg Nest, night
who: Sif, Boulder, Ada
problem: Embers fall on a nest of glowing eggs as a red glow brightens behind the peak.
why_stack: Obsidian roofs shield the eggs through each ember shower.
headline_objective: Shelter the eggs from the embers
ending_pattern: twist
world_change: The roofed nest cools and the glow fades.
wordless_moment: The nest is empty because the eggs rode in the party's cart.
opening_event: embers_settle_round_nest
verb: defend
minigame: "base: shelter_guest (D4) + embers"
footprint: horseshoe
terrain: fort_wall
set_piece: egg_nest
set_piece_action: smoke_puff
cast_pose: "Sif:brace, Boulder:haul"
hud_meter: Egg Warmth
---
id: lava_03
role: teach
place: Crust Road, golden
who: Boulder, Ada
problem: The road to the forge is a lava river and the crust cracks behind the cart.
why_stack: The player paves new road ahead of the cart so it keeps moving.
headline_objective: Pave a road to the forge
ending_pattern: plain
world_change: A golden road spans the lava to the forge door.
wordless_moment: Crust crumbles into the glow right behind the wheels.
opening_event: lava_river_cracks_behind_cart
verb: race
minigame: "module: paver_rally (debut) + lava rise"
footprint: S_curve
terrain: crust_road
set_piece: crust_road
set_piece_action: lava_rise
cast_pose: "Boulder:haul, Ada:cheer"
hud_meter: Road Ahead
---
id: lava_04
role: twist
place: Vent Field, dusk
who: Boulder, Wizard, Bram
problem: Geysers toss Boulder's rocks and one launches the Wizard's cloud out of sight.
why_stack: A fence round the vents bounces the rocks back into the cart.
headline_objective: Catch the geyser rocks
ending_pattern: plain
world_change: The fenced vents spit rocks into the cart and the Wizard lands.
wordless_moment: The Wizard thumps down on the fence clutching his hat, shaken.
opening_event: geysers_pop_cloud_launches
verb: defend
minigame: "base: hold_the_wall + geyser"
footprint: trident
terrain: stepped_ravine
set_piece: vent_field
set_piece_action: geyser_spout
cast_pose: "Wizard:hide, Bram:brace"
hud_meter: Rocks Caught
---
id: lava_05
role: twist
place: Black Glass Tower, night
who: Bram, Boulder
problem: The forge window is high on a hot glass tower and the Keystone hums inside.
why_stack: Obsidian steps let Bram reach the window.
headline_objective: Reach the forge window
ending_pattern: plain
world_change: Steps wind up the tower to the window.
wordless_moment: Bram sees a silhouette standing guard, gazing back.
opening_event: hot_glass_forge_window_hum
verb: build
minigame: "base: raise_lookout + heat"
footprint: ladder_stair
terrain: mine_shaft
set_piece: glass_tower
set_piece_action: drum_beat
cast_pose: "Bram:build, Boulder:brace"
hud_meter: Window Height
---
id: lava_06
role: twist
place: Toasting Ledge, dusk
who: Boulder, Wizard, Bram
problem: Bram's gaze keeps sliding to the forge while the hum grows louder.
why_stack: A toasting ring of blocks holds the marshmallows over the heat.
headline_objective: Build the marshmallow toasting ring
ending_pattern: reveal
world_change: The ring glows and the toasted marshmallows steam.
wordless_moment: Bram's seat is empty: he has slipped away alone.
opening_event: marshmallow_toast_hum_grows
verb: build
minigame: "base: fill_the_shape + hum"
footprint: L_shape
terrain: stepped_ravine
set_piece: toasting_ledge
set_piece_action: steam_vent
cast_pose: "Boulder:cheer, Wizard:hide"
hud_meter: Hum Level
---
id: lava_07
role: combine
place: Smoke Cavern, night
who: Ada, Sif, Boulder
problem: Black smoke fills the cavern and Bram's call echoes, then stops.
why_stack: A tall vent of blocks draws the smoke off.
headline_objective: Clear the smoke to find Bram
ending_pattern: twist
world_change: The smoke clears and the cavern floor shows.
wordless_moment: Only Bram's helmet sits on a rock for a heartbeat.
opening_event: smoke_fills_cavern_call_stops
verb: rescue
minigame: "base: raise_lookout + fog"
footprint: hourglass
terrain: mine_shaft
set_piece: glass_tower
set_piece_action: smoke_puff
cast_pose: "Ada:point, Sif:hide"
hud_meter: Smoke Level
---
id: lava_08
role: combine
place: Crumbling Crust, dusk
who: Ada, Bram, Boulder, Wizard
problem: Bram stands on a crumbling crust raft far out in the lava, saying he is fine.
why_stack: A crust bridge laid piece by piece lets Ada reach him in time.
headline_objective: Reach Bram before the crust goes
ending_pattern: story
world_change: A glowing bridge links the crust raft to the shore.
wordless_moment: Bram, for once, takes Ada's hand, while the Wizard pulls a boot from his hat.
opening_event: eruption_raft_crumbles_boot
verb: rescue
minigame: "module: floe_footing (recall) + lava rise"
footprint: island_chain
terrain: raft
set_piece: vent_field
set_piece_action: geyser_spout
cast_pose: "Ada:build, Bram:brace"
hud_meter: Crust Left
---
id: lava_09
role: combine
place: Forge Anvil Hall, night
who: Boulder, Bram, Ada, Wizard
problem: The lava rises behind them and the Wizard's star is stamped on the forge anvil.
why_stack: Steps built ahead of the lava lift the party out.
headline_objective: Climb out ahead of the lava
ending_pattern: reveal
world_change: The party stands on a ledge above the glow.
wordless_moment: Nobody looks at the Wizard.
opening_event: boulder_carries_bram_star_glows
verb: survive
minigame: "module: foothold_climb (recall) + lava rise"
footprint: pyramid_steps
terrain: summit_ledge
set_piece: anvil_forge
set_piece_action: lava_rise
cast_pose: "Boulder:haul, Wizard:hide"
hud_meter: Lava Rise
---
id: lava_10
role: boss
place: Forge Anvil Hall, golden
who: Cinderbottom, Boulder, all heroes
problem: A tired basalt watchman stamps the floor and will not stand down.
why_stack: A wall, a cooling road and a stone seat let him rest in three phases.
headline_objective: Relieve the watchman of his post
ending_pattern: story
world_change: Keystone five crowns the forge and the lava cools to a glow.
wordless_moment: Boulder sits in the watchman's chair so the night watch can end.
opening_event: cinderbottom_stamps_floor
verb: defend
minigame: "base: hold_the_wall then module: paver_rally (recall)"
footprint: ring
terrain: crust_road
set_piece: anvil_forge
set_piece_action: rock_throw
cast_pose: "Ada:brace, Bram:haul, Boulder:build"
hud_meter: Watchman's Weariness
caption: The forge watchman woke up grumpy. Bram went in alone.
---
id: lava_bonus
role: bonus
place: Forge Floor, golden
who: Boulder, Cinderbottom, Bram
problem: Boulder's boulder needs rails to knock down a row of anvil pins.
why_stack: Rails built along the lane steer the boulder into the pins.
headline_objective: Knock down the anvil pins
ending_pattern: guest
world_change: Every pin falls with a clang.
wordless_moment: Cinderbottom bowls the last strike himself.
opening_event: boulder_rolls_at_pins
verb: destroy
minigame: "base: bowling (destroy) + boulder roll"
footprint: keyhole
terrain: fort_wall
set_piece: cooling_vat
set_piece_action: gear_grind
cast_pose: "Boulder:cheer, Bram:point"
hud_meter: Pins Down
---
id: lava_h1
role: hard
place: Crust Road, night
who: Cinderbottom, Boulder
problem: Cinderbottom jogs his night lap and the lava rises to the rhythm.
why_stack: A road paved ahead of him keeps his lap safe.
headline_objective: Pave ahead of Cinderbottom's lap
ending_pattern: plain
world_change: The road holds and the lap ends in a tie with Boulder.
wordless_moment: Boulder races him on the next lane.
opening_event: cinderbottom_night_jog
verb: race
minigame: "module: paver_rally (recall) + lava rise"
footprint: zigzag
terrain: summit_ledge
set_piece: crust_road
set_piece_action: boulder_roll
cast_pose: "Cinderbottom:point, Boulder:haul"
hud_meter: Lap Time
---
id: lava_h2
role: hard
place: Cooling Vat Yard, dusk
who: Boulder, Ada
problem: A blanket of ash hides every geyser.
why_stack: Tall blocks mark each hidden vent so the cart avoids it.
headline_objective: Mark the hidden vents
ending_pattern: guest
world_change: Marker blocks stand over every vent.
wordless_moment: The biggest vent opens and a mother lizard returns for her eggs.
opening_event: ash_falls_over_vents
verb: survive
minigame: "base: fog + geyser"
footprint: boomerang
terrain: raft
set_piece: cooling_vat
set_piece_action: steam_vent
cast_pose: "Boulder:point, Ada:brace"
hud_meter: Vents Marked
---
id: lava_h3
role: hard
place: Rim Landing, dawn
who: Boulder, Bram
problem: Boulder smashes the anvil to mend it and pieces fly everywhere.
why_stack: A funnel of blocks catches the flying pieces.
headline_objective: Catch the pieces of the anvil
ending_pattern: plain
world_change: The pieces land in a neat heap.
wordless_moment: Boulder shrugs with a piece on his head.
opening_event: anvil_smashed_bits_fly
verb: carry
minigame: "base: collect_run + rock throw"
footprint: cross
terrain: rim_ledge
set_piece: rim_landing
set_piece_action: rock_throw
cast_pose: "Bram:haul, Boulder:cheer"
hud_meter: Pieces Caught
```
