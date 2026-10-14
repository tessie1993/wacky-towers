# Beats: Chapter 6, The Treehouse Secret (Forest)

Derived from `design/narrative/campaign-story.md` (revision 2). One YAML document per level; fields are one sentence of 20 words or fewer.

```yaml
---
id: forest_01
role: teach
place: Winter Pantry, dawn
who: Nutmeg, Wizard, Ada
problem: The squirrels' winter acorns sit under creeping vines in the drizzle.
why_stack: A shelf above the vines keeps the acorns dry.
headline_objective: Shelve the squirrels' winter acorns
ending_pattern: plain
world_change: A neat shelf of acorns sits dry above the vines.
wordless_moment: The Wizard flings an umbrella from his hat into the sack.
opening_event: umbrella_flung_cloud_snags
verb: build
minigame: "base: build_tower + vines"
footprint: fork
terrain: treetop_platform
set_piece: winter_pantry
set_piece_action: vine_creep
cast_pose: "Nutmeg:react, Wizard:hide"
hud_meter: Pantry Dryness
---
id: forest_02
role: teach
place: Hollow Log, day
who: Nutmeg, Bram
problem: Roots wriggle shut across the log tunnel to Nutmeg's den.
why_stack: A ramp through the log lets the acorn cart roll through.
headline_objective: Roll the acorn cart through
ending_pattern: plain
world_change: The tunnel stays open and the cart reaches the den.
wordless_moment: Each root retreats when a block lands.
opening_event: roots_wriggle_shut_tunnel
verb: carry
minigame: "base: cart_convoy + root creep"
footprint: ribbon
terrain: plank_bridge
set_piece: log_span
set_piece_action: root_whip
cast_pose: "Bram:haul, Nutmeg:point"
hud_meter: Tunnel Open
---
id: forest_03
role: teach
place: Mossy Brook, golden
who: Sif, Bram, Nutmeg
problem: Vines yank the stepping stones out of the brook one by one.
why_stack: A footbridge built across the banks beats the vines.
headline_objective: Bridge the brook before the vines pull it
ending_pattern: plain
world_change: A moss-covered footbridge spans the brook.
wordless_moment: Sif crosses first with a grin.
opening_event: vines_yank_stones
verb: race
minigame: "module: gap_runner (recall) + vines"
footprint: island_chain
terrain: ravine_ledges
set_piece: log_span
set_piece_action: wind_gust
cast_pose: "Sif:haul, Nutmeg:point"
hud_meter: Bridge Progress
---
id: forest_04
role: twist
place: Root Bank, dusk
who: Sif, Nutmeg, squirrels
problem: Acorns pelt the clearing in a mock battle with a squirrel kit in the middle.
why_stack: A shell of blocks over the kit shelters it through each volley.
headline_objective: Shelter the squirrel kit
ending_pattern: twist
world_change: The kit is safe under a block shell and the battle ends in a truce.
wordless_moment: Sif trades the scouts her best trinket.
opening_event: scouts_pelt_acorns_kit_squeaks
verb: defend
minigame: "base: shelter_guest (D4) + acorn throw"
footprint: boomerang
terrain: hilltop_ledge
set_piece: root_bank
set_piece_action: rock_throw
cast_pose: "Sif:cheer, Nutmeg:react"
hud_meter: Kit Safe
---
id: forest_05
role: twist
place: Old Treehouse, golden
who: Sif, Ada, Old Knotty (watching)
problem: A tiny weathered treehouse sits high on the trunk and Sif goes quiet.
why_stack: A limb ladder built up the trunk lets her reach it.
headline_objective: Climb to the old treehouse
ending_pattern: reveal
world_change: A ladder of blocks winds up the trunk to the treehouse door.
wordless_moment: Inside are her carved initials and a drawing of an oak hugging an elf.
opening_event: sif_sees_treehouse
verb: race
minigame: "base: build_stair + sway"
footprint: ladder_stair
terrain: treetop_platform
set_piece: old_treehouse
set_piece_action: lantern_sway
cast_pose: "Sif:point, Ada:build"
hud_meter: Treehouse Height
---
id: forest_06
role: twist
place: Dim Glade, night
who: Nutmeg, Sif, fireflies
problem: A creeping grey fungus dims the glade and the fireflies flicker out.
why_stack: Painting the floor with moss claims it back from the fungus.
headline_objective: Reclaim the glade with moss
ending_pattern: plain
world_change: The glade floor glows green and the fireflies return.
wordless_moment: The fireflies relight in the shape of a small elf.
opening_event: fungus_dims_glade
verb: build
minigame: "module: splat_claim (debut) + fungus spread"
footprint: clover
terrain: stepped_ravine
set_piece: dim_glade
set_piece_action: vine_creep
cast_pose: "Nutmeg:point, Sif:build"
hud_meter: Moss Share
---
id: forest_07
role: combine
place: Campfire Log, dusk
who: Wizard, Ada, Bram, Sif
problem: Wind whips leaves off a swaying log where the party wants to camp.
why_stack: A balanced platform of blocks steadies the campfire.
headline_objective: Steady the campfire platform
ending_pattern: story
world_change: A steady campfire glows and the heroes sit round it.
wordless_moment: The Wizard tells the whole truth by firelight and nobody leaves.
opening_event: wind_whips_leaves_camp
verb: balance
minigame: "module: wobble_plate (recall) + gust"
footprint: T_shape
terrain: raft
set_piece: campfire_branch
set_piece_action: wind_gust
cast_pose: "Wizard:hide, Ada:brace, Bram:cheer"
hud_meter: Campfire Steadiness
---
id: forest_08
role: combine
place: Drumming Trunk, day
who: Lana, Bram, Nutmeg
problem: Woodpeckers drum the oak and each knock pops a hole in the bark wall.
why_stack: The piece that fits each hole plugs it before the next drum roll.
headline_objective: Plug the trunk's holes
ending_pattern: guest
world_change: The bark wall is whole and the knocking slows.
wordless_moment: Lana swings in on a vine with a knitted net.
opening_event: woodpeckers_drum_holes_pop
verb: defend
minigame: "base: plug_breach (D2) + woodpecker knock"
footprint: bowtie
terrain: fort_wall
set_piece: drumming_trunk
set_piece_action: drum_beat
cast_pose: "Lana:haul, Bram:brace"
hud_meter: Trunk Holes
---
id: forest_09
role: combine
place: Root Bank, golden
who: Old Knotty, Ada, Sif
problem: Roots slide like belts and sweep everyone toward the oak's hollow.
why_stack: A stair built above the roots lets the party ride over them.
headline_objective: Climb above the sweeping roots
ending_pattern: reveal
world_change: A stair crosses the roots and the belts slow.
wordless_moment: The belts load a basket with Sif's lost childhood things that Knotty has kept.
opening_event: roots_slide_toward_hollow
verb: survive
minigame: "base: material twist (roots as belts) + stair"
footprint: snake
terrain: hilltop_ledge
set_piece: root_bank
set_piece_action: root_whip
cast_pose: "Knotty:react, Sif:cheer"
hud_meter: Root Speed
---
id: forest_10
role: boss
place: Great Oak Crown, golden
who: Old Knotty, Nutmeg, all heroes
problem: Old Knotty ties everyone in with vines because everyone he loves leaves.
why_stack: Trellis walls, a platform and a stair up to his crown win him over in three phases.
headline_objective: Show Knotty they will come back
ending_pattern: story
world_change: Keystone six glows in the crown and the vines open like arms.
wordless_moment: The heroes walk away down the stair and walk back up.
opening_event: knotty_rises_vines_flail
verb: defend
minigame: "base: hold_the_wall + vines then stair"
footprint: pinwheel
terrain: ravine_ledges
set_piece: oak_crown
set_piece_action: drum_beat
cast_pose: "Ada:build, Bram:build, Sif:build"
hud_meter: Knotty's Grip
caption: The treehouse holds a secret. So do the vines.
---
id: forest_bonus
role: bonus
place: Winter Pantry, golden
who: Nutmeg, Sif, squirrels
problem: Nutmeg's berry baskets must travel down the trunk without spilling.
why_stack: Relay ramps pass each basket down the trunk.
headline_objective: Pass the berry baskets down
ending_pattern: plain
world_change: Every basket reaches the bottom full.
wordless_moment: The last scout carries Sif's first bead.
opening_event: berry_relay_whistle
verb: carry
minigame: "base: cart_convoy + wobble"
footprint: heart
terrain: fort_wall
set_piece: winter_pantry
set_piece_action: bell_ring
cast_pose: "Nutmeg:react, Sif:cheer"
hud_meter: Berries Spilled
---
id: forest_h1
role: hard
place: Old Treehouse, night
who: Nutmeg, Old Knotty
problem: Fireflies throw a night party that spirals faster than before.
why_stack: Lantern perches raised for them keep the spiral going.
headline_objective: Raise perches for the firefly party
ending_pattern: twist
world_change: The perches glow in a long spiral round the trunk.
wordless_moment: The spiral of light draws a map with an X.
opening_event: fireflies_spiral_party_night
verb: build
minigame: "base: raise_lookout + wander"
footprint: cross
terrain: plank_bridge
set_piece: old_treehouse
set_piece_action: lantern_sway
cast_pose: "Nutmeg:cheer, Knotty:react"
hud_meter: Firefly Cheer
---
id: forest_h2
role: hard
place: Drumming Trunk, dusk
who: Nutmeg, Old Knotty
problem: The squirrels roll out a catapult and aim acorns at Knotty's crown.
why_stack: A wall in front of the crown stops the acorns.
headline_objective: Wall the crown against the acorns
ending_pattern: plain
world_change: The wall stands and acorns pile at its foot.
wordless_moment: Knotty tilts his crown like a hat.
opening_event: squirrels_roll_out_catapult
verb: defend
minigame: "base: hold_the_wall + acorn throw"
footprint: wedge
terrain: raft
set_piece: drumming_trunk
set_piece_action: rock_throw
cast_pose: "Nutmeg:point, Bram:brace"
hud_meter: Crown Wall
---
id: forest_h3
role: hard
place: Dim Glade, dawn
who: Sif, Nutmeg
problem: The squirrels swap everyone's packs and Sif's pack disappears up the trunk.
why_stack: Chase ramps built up the trunk let Sif catch the pack.
headline_objective: Chase the stolen pack up the trunk
ending_pattern: plain
world_change: The pack is back on Sif's shoulders.
wordless_moment: Nutmeg wears Sif's hood.
opening_event: packs_swapped_sif_pack_gone
verb: rescue
minigame: "base: outrun_hazard + vines"
footprint: diamond
terrain: stepped_ravine
set_piece: dim_glade
set_piece_action: bell_ring
cast_pose: "Sif:haul, Nutmeg:hide"
hud_meter: Pack Chase
```
