# Beats: Chapter 2, The Great Sugar Prank (Candy)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer. Scene ids are the proposals in story section 5b.

```yaml
---
id: candy_01
role: teach
place: Sugar-Cube Pier, golden
who: Crumb, Wizard, Ada
problem: Everything is sticky and the bun cart cannot cross the puddle.
why_stack: A dry road of sugar cubes carries the cart over the glue.
headline_objective: Roll the bun cart to the bakery
ending_pattern: plain
world_change: The cart rolls along a clean cube road to the bakery door.
wordless_moment: The Wizard flings a sock from his hat into the sack and boots stick.
opening_event: sock_flung_boots_stick
verb: carry
minigame: "base: cart_convoy + sticky floor"
footprint: zigzag
terrain: raft
set_piece: sugar_pier
set_piece_action: bell_ring
cast_pose: "Crumb:haul, Wizard:point"
hud_meter: Stickiness
---
id: candy_02
role: teach
place: Baker's Doorway, day
who: Crumb, Bram
problem: Giant gumdrops bounce off the bakery sign and threaten the buns.
why_stack: A block awning over the door takes each hit.
headline_objective: Shelter the bakery door
ending_pattern: plain
world_change: Gumdrops pile harmlessly on the awning like a sweet roof.
wordless_moment: Bram catches a gumdrop in his helmet with a clang.
opening_event: gumdrops_bounce_off_sign
verb: defend
minigame: "base: hold_the_wall + gumdrop hail"
footprint: arch
terrain: fort_wall
set_piece: bakery_door
set_piece_action: confetti_burst
cast_pose: "Bram:brace, Crumb:hide"
hud_meter: Awning Strength
---
id: candy_03
role: teach
place: Syrup River, day
who: Crumb, Sif, gummy turtles
problem: A syrup river cuts the village from the fountain square.
why_stack: Stepping stones carry the bread cart across the syrup.
headline_objective: Get the bread cart across
ending_pattern: twist
world_change: The cart reaches the square and the village cheers.
wordless_moment: The stepping stones yawn: they are gummy turtles paddling the cart across.
opening_event: syrup_river_cuts_village
verb: carry
minigame: "module: gap_runner (recall) + syrup glide"
footprint: island_chain
terrain: plank_bridge
set_piece: syrup_river
set_piece_action: flock_wander
cast_pose: "Crumb:haul, Sif:point"
hud_meter: Cart Progress
---
id: candy_04
role: twist
place: Jelly Plaza, golden
who: Wizard, Crumb, Ada
problem: The jelly floor wobbles and the shop sign will not stand.
why_stack: A tall base on the jelly plate keeps the sign upright.
headline_objective: Hold the shop sign steady
ending_pattern: plain
world_change: The sign stands straight and the jelly settles.
wordless_moment: The Wizard pins a gold star above the sign and Crumb quietly takes it down.
opening_event: jelly_floor_shivers_star_pinned
verb: balance
minigame: "module: wobble_plate (debut) + jelly floor"
footprint: cross
terrain: cake_plate
set_piece: jelly_plaza
set_piece_action: jelly_wobble
cast_pose: "Wizard:point, Crumb:hide"
hud_meter: Quiver
---
id: candy_05
role: twist
place: Cake Stand Spire, day
who: Crumb, Jester
problem: Jester has stolen the top tier of the cake stand.
why_stack: A stair of tiers lets Crumb climb up to fetch it.
headline_objective: Climb to the stolen top tier
ending_pattern: reveal
world_change: The stair stands against the spire like a wedding cake.
wordless_moment: The tier Crumb opens rattles: a jack-in-the-box decoy.
opening_event: top_tier_stolen_cackle
verb: race
minigame: "base: build_stair + sprinkle bursts"
footprint: ladder_stair
terrain: summit_ledge
set_piece: cake_spire
set_piece_action: confetti_burst
cast_pose: "Crumb:haul, Jester:hide"
hud_meter: Tier Height
---
id: candy_06
role: twist
place: Gingerbread Wall, dusk
who: Crumb, Sif, Granny Gumdrop
problem: Someone has scribbled a moustache on Granny Gumdrop's iced mural.
why_stack: Coloured blocks repaint the face before she wakes.
headline_objective: Repaint Granny's mural
ending_pattern: guest
world_change: The mural shows Granny's smiling face again.
wordless_moment: Granny waddles in and adds a second moustache herself.
opening_event: moustache_on_mural
verb: build
minigame: "base: fill_the_shape + wobble"
footprint: keyhole
terrain: fort_wall
set_piece: iced_mural
set_piece_action: jelly_wobble
cast_pose: "Granny:cheer, Sif:hide"
hud_meter: Mural Done
---
id: candy_07
role: combine
place: Gummy Pasture, day
who: Bram, Crumb, worms
problem: The pet gummy worms have wriggled free all over the pasture.
why_stack: A fence ring of blocks herds them back in.
headline_objective: Round up the gummy worms
ending_pattern: plain
world_change: The worms curl up asleep inside the fence.
wordless_moment: Bram keeps his hammer behind his back.
opening_event: gummy_worms_escape
verb: rescue
minigame: "module: sneak_route herd form (recall) + wander"
footprint: horseshoe
terrain: raft
set_piece: gummy_pasture
set_piece_action: flock_wander
cast_pose: "Bram:hide, worms:react"
hud_meter: Worms Home
---
id: candy_08
role: combine
place: Syrup Cove, golden
who: Crumb, Ada, Bram
problem: The village pie contest needs a fort and a catapult.
why_stack: A solid keep protects the player while cleared rows load the pie catapult.
headline_objective: Win the village pie contest
ending_pattern: reveal
world_change: The rival marzipan fort crumbles in a rain of cream.
wordless_moment: The last pie sails into a high window where a jester's bell jingles.
opening_event: marzipan_forts_catapult_handed
verb: destroy
minigame: "module: catapult_keep (debut) + wall"
footprint: trident
terrain: conveyor_deck
set_piece: sugar_pier
set_piece_action: steam_vent
cast_pose: "Crumb:point, Ada:haul, Bram:build"
hud_meter: Fort Frosting
---
id: candy_09
role: combine
place: Fountain Plaza, dusk
who: Crumb, Wizard
problem: A brown wave rolls toward Crumb's tarts across the plaza.
why_stack: A levee turns the wave aside.
headline_objective: Hold back the cocoa wave
ending_pattern: plain
world_change: The wave leaves a first step of the cake stair behind.
wordless_moment: Crumb holds a tart tray above her head.
opening_event: fountain_gurgles_wave_behind
verb: defend
minigame: "base: hold_the_wall + conveyor current"
footprint: moat_island
terrain: conveyor_deck
set_piece: cocoa_fountain
set_piece_action: waterfall_pour
cast_pose: "Crumb:brace, Wizard:hide"
hud_meter: Levee Strength
---
id: candy_10
role: boss
place: Cake Stand Spire, golden
who: Jester, Crumb, all heroes
problem: Jester flings pies from a pudding cannon and hides Keystone two in one.
why_stack: Shields, a wide base and a ladder let the player turn the pies back.
headline_objective: Catch the pie with Keystone two
ending_pattern: twist
world_change: The village laughs and Keystone two crowns the cake spire.
wordless_moment: The pies bounce back onto Jester, who laughs so hard he drops the right one.
opening_event: jester_pie_cannon
verb: destroy
minigame: "module: catapult_keep then wobble_plate (recalls)"
footprint: bullseye
terrain: summit_ledge
set_piece: cake_spire
set_piece_action: catapult_volley
cast_pose: "Ada:brace, Bram:haul, Crumb:build"
hud_meter: Pie Cannon Heat
caption: Someone swapped the frosting for glue. Sticky business!
---
id: candy_bonus
role: bonus
place: Birthday Lane, golden
who: Crumb, Granny Gumdrop, Bram
problem: A wobbly float of cakes must reach Granny's birthday party.
why_stack: A strong frame keeps the float together down the lane.
headline_objective: Carry the birthday float to Granny
ending_pattern: guest
world_change: Granny's party begins with sprinkles in the air.
wordless_moment: Granny hops aboard and rides the float.
opening_event: float_wobbles_sprinkles_fly
verb: carry
minigame: "base: cart_convoy + wobble"
footprint: heart
terrain: plank_bridge
set_piece: bakery_door
set_piece_action: bell_ring
cast_pose: "Crumb:haul, Granny:cheer"
hud_meter: Float Steadiness
---
id: candy_h1
role: hard
place: Gummy Pasture, night
who: Jester, Crumb
problem: A giant gumball starts rolling toward the bakery.
why_stack: Barriers steer it away faster than it rolls.
headline_objective: Steer the gumball past the bakery
ending_pattern: plain
world_change: The gumball rolls harmlessly into the pasture pond.
wordless_moment: Jester pushes it, grinning, then runs.
opening_event: giant_gumball_starts_to_roll
verb: race
minigame: "base: outrun_hazard (rolling hazard) + syrup"
footprint: S_curve
terrain: floating_island
set_piece: gummy_pasture
set_piece_action: waterfall_pour
cast_pose: "Jester:point, Crumb:hide"
hud_meter: Gumball Speed
---
id: candy_h2
role: hard
place: Frosting Works, dusk
who: Jester, Crumb
problem: Jester hijacks the frosting pipes and splats the walls pink.
why_stack: Belts and chutes steer the frosting back to the bakery.
headline_objective: Steer the frosting to the bakery
ending_pattern: plain
world_change: The walls drip clean white and the bakery gets its frosting.
wordless_moment: Jester wears a pink-splattered hat.
opening_event: pipes_splat_pink_word
verb: carry
minigame: "base: cart_convoy + conveyor"
footprint: pinwheel
terrain: cake_plate
set_piece: cocoa_fountain
set_piece_action: steam_vent
cast_pose: "Crumb:haul, Bram:build"
hud_meter: Frosting Flow
---
id: candy_h3
role: hard
place: Syrup Raft, night
who: Jester, Crumb
problem: Jester returns with a bigger cannon and a crown, firing pies from a syrup raft.
why_stack: A shield wall stops each volley.
headline_objective: Shield the village from pies
ending_pattern: story
world_change: The village makes Jester its court jester.
wordless_moment: Crumb hands him a tiny crown and he bows.
opening_event: jester_returns_syrup_raft
verb: defend
minigame: "base: hold_the_wall + pie volley"
footprint: funnel
terrain: floating_island
set_piece: jelly_plaza
set_piece_action: catapult_volley
cast_pose: "Jester:point, Crumb:brace"
hud_meter: Village Cheer
```
