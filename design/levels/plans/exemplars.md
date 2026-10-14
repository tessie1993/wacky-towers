# Calibration exemplars (game director, 2026-10-14, revision 2)

Anchors for the panel (`campaign-vision.md` section 9). Written by the game director, not the makers.

**Rules for using this file**
- **Form, not content.** The exemplars teach structure and level of detail. No real level may reuse an
  exemplar's set piece, terrain, mask, ending or character. The exemplar ids (`forest_05`, `forest_h1`,
  `pirate_10`, `meadow_01`) are calibration ids: the real levels with those ids must differ from them, and
  the exemplars are included in the U3, U14 and U17 checks.
- **Exemption.** Fields derived from phase 3 formulas (`g0`, stars, goal numbers) are exempt in exemplars and
  written `by formula`. Handbook links point to entries that phase 3 will write (`handbook#<rule>`).
- Text shown during play is never sarcastic or mocking, and has no words inside play (section 4 of the vision).
- Each field below "would pass its rubric line on its own"; the panel scores N4, L1-L7 over the whole set.

## 1. Exemplar beat (9.7)

```yaml
id: forest_05
role: twist
place: Goat Gully, a mossy ravine whose old plank bridge has rotted away
who: Sif on the near ledge, a goat called Nanny Tuft on the far ledge, a gust imp hiding in the roots
problem: Nanny Tuft is stuck across the gully with her bell and cannot get home.
why_stack: The player's blocks become the new bridge and the steps the goat walks on.
headline_objective: Help Nanny Tuft cross the gully      # story noun, no numeral
ending_pattern: twist            # the bridge is done, then a gale arrives and the goat must be held on
world_change: Nanny Tuft trots home across a swaying bridge and the gully fills with fireflies.
wordless_moment: Sif waves a rope while Nanny Tuft shakes her bell and paws at the first gap.
opening_event: goat_bell_rings
caption: Nanny Tuft rings her bell, and everyone builds.
```

Why: one place, one problem, a reason to stack (P1a). The twist is telegraphed by the imp's rustle (U16,
fair). The objective names a story object (U15). The opening event is distinct and silent (U8).

## 2. Exemplar spec (9.7)

```yaml
id: forest_05
name: Goat Gully
role: twist
headline_objective: Help Nanny Tuft cross the gully
ending_pattern: twist            # written to metadata.ending
metadata.signature: The one where the bridge is finished and the wind arrives.
main_rule: vines                 # handbook#vines (new, taught alone here)
extras: [gust]                   # handbook#gust (taught in biome 2, so allowed on the pill)
goal_type: [span, survive]       # play order; U3 compares the whole list
goal_params: by formula          # gap 6 cells, hold time
target_visible: yes, a lit footprint trail on the far ledge from frame 0
mask: |
  ###......###
  ###......###
  ###......###
  ############
  ############
  ############
  ############
  ############
canonical_mask: "8x12:########/########/########/#####.../#####.../#####.../#####.../#####.../#####.../########/########/########"
minigame_block: gap_runner (phase 1 of 2), recall of its Meadow debut
look: { time_of_day: golden, weather: petals, set_piece: rotten_plank_bridge, set_piece_side: back,
        accent: "#7BD36B", camera: low, dressing: lush }
scene:
  terrain: ravine_ledges        # closed-list id (U17)
  set_piece_action: root_whip   # a RULE: phase 2 roots sway the bridge; handbook#root_whip, counts toward U10
  cast_on_stage: Sif lowers a rope and hauls planks (haul); Nanny Tuft paces and rings her bell (point)
  hud_meter: Sway meter (Balance); fits the gale phase
g0: by formula
stars: by formula
opening_event: goat_bell_rings
world_change: the bridge holds, Nanny Tuft crosses, fireflies light the gully
comic_fail: Nanny Tuft slides down on her bottom, the bell rings once, and Sif covers her eyes; retry in 1.5 s
callback_of: none
level_table_row: forest_05 | span>survive | vines | 8x12:... | ravine_ledges | rotten_plank_bridge | root_whip | haul,point | golden | petals | low | goat_bell_rings | twist | Help Nanny Tuft cross the gully | twist | none
```

Rule budget note: `vines` is the level's one new rule; `root_whip` is the same idea acting through the set piece,
so it is one rule with one handbook entry, not two. A cosmetic action would not need this.

## 3. Near-miss sample (about 9.0)

```yaml
id: forest_06
name: Cliff Crossing
headline_objective: Get the cart across the cliff
ending_pattern: twist
metadata.signature: The one with vines and a gust and a cart.     # names rules, not an event
main_rule: vines
goal_type: [span, survive]
scene: { terrain: cliff, set_piece: old_tree (named but decorative), set_piece_action: sways, cast_on_stage: Sif hauls (haul), a villager cheers (cheer) }
cast_pose: haul, cheer           # repeats the neighbouring level's haul and cheer
look: { time_of_day: golden, weather: petals, camera: low }   # fingerprint is close to forest_05
```

All fields are filled and the twist is good, so it is not a failure. Expected panel scores: L1 9.5, L2 9.0,
L3 9.3, L4 9.5, L5 9.5, L6 8.8, L7 9.6. The one structural fix that keeps it from 9.7: give the scene
substance (a specific terrain id, an action that does something named, a distinct pose set) and rewrite the
signature as an event. `sways` is not a closed-list action id (U17), and the pose set repeats the neighbour's.

## 4. Weak sample (8.0 or below)

```yaml
id: forest_05
name: Log Challenge
headline_objective: Clear 4 layers
ending_pattern: plain
metadata.signature: A forest level with some vines and 4 layers to clear.
main_rule: vines
goal_type: [clear_n]
mask: 8x8 full square
look: { time_of_day: day, weather: clear, set_piece: tree, camera: default }
scene: { terrain: floating island, set_piece_action: none, cast_on_stage: none }
opening_event: level_start
world_change: the level ends
```

Defects (each caps the score): a counter goal, mundane (U15, P2c; caps N4, M3, L3 at 8.0); no scene (P1b; caps
L6 at 8.0); fails the swap test (P1a); plain ending and a rule-naming signature (U4, U16); plain square,
default camera, generic set piece (U7, U14); empty opening event and world change (U8, U11); missing
`target_visible`, `comic_fail` and `level_table` row (L7). Expected: L1 8, L2 7, L3 6, L4 8, L5 8, L6 5, L7 6.

## 5. Boss exemplar (9.7): tier 10, with a boss triple

```yaml
id: pirate_10
name: Crumpet's Deck
role: boss
headline_objective: Win back the last key from Captain Crumpet
ending_pattern: guest            # a rival gull-ship joins in phase 2 and swings the cannons round
metadata.signature: The one where the captain's own cannons end up pointing at him.
main_rule: cannon_volley         # handbook#cannon_volley (a RULE: balls knock out the top row)
goal_type: [bonk_boss]           # the number of hits is by formula; the HUD says "Win back the key"
mask: "8x8:########/########/##....../##....../##....../##....../##....../##......"   # an L-shaped deck
canonical_mask: "8x8:########/########/##....../##....../##....../##....../##....../##......"
boss_triple: { arena: l_deck, phases: 3, building_action: wall }   # wall blocks cannonballs; cleared rows load your cannon
phases:
  - p1: Crumpet fires from the bow; the player walls the volley and loads the cannon with cleared rows
  - p2: the rival ship arrives (guest); the arena gains a second firing lane
  - p3: the deck tilts; the last hit knocks the key loose and the finale's invitation is revealed
scene: { terrain: ship_deck, set_piece: pirate_galleon, set_piece_action: cannon_volley, cast_on_stage: Ada braces behind a wall (brace), Bram hauls shot (haul) }
world_change: the key drops into Ada's hands and the ship turns toward the Fair
hook_to_finale: the key is the Carnival's ticket (stakes: "The last key and the way to the Fair")
comic_fail: the captain's hat is blown off and spins on a cannon; retry in 1.5 s
```

Why: the boss is tied to its chapter, beaten by building (wall), changes the arena (U9), has a unique
`(arena, phases, building_action)` (U12), and hands over a finale-bound hook. The goal is not hidden (tier 10).

## 6. Hard-remix exemplar (9.7)

```yaml
id: forest_h1
name: Gully by Dusk
role: hard
callback_of: forest_05
headline_objective: Help Nanny Tuft cross before the gale
ending_pattern: reveal           # the gale comes first; the goat's far ledge is the real destination
goal_type: [survive, span]       # reordered: differs from forest_05's [span, survive] (U3)
main_rule: vines
mask: a stepped trench (different canonical mask from forest_05)
look: { time_of_day: dusk, set_piece: rotten_plank_bridge (different time of day, U3 remix rule), camera: wide }
scene: { terrain: stepped_ravine, set_piece_action: root_whip, cast_on_stage: Sif braces the rope (brace) }
g0: by formula (faster than forest_10)
```

Why: a remix changes the goal list and the mask, and differs in time of day and terrain, so U3 and U14 hold.

## 7. Level-01 exemplar (9.7): one rule, an opening set, gentle

```yaml
id: meadow_01
name: Windmill Lookout
role: teach
headline_objective: Raise the lookout so Ada can see the sheep
ending_pattern: plain            # level 01 may not hide its goal
main_rule: height_lookout        # the only rule; handbook#lookout
goal_type: [height]
mask: "8x8:########/########/########/########/########/########/########/########"   # one of at most 4 plain squares
opening_set: friendly first pieces (by formula)
scene: { terrain: hilltop_ledge, set_piece: windmill, set_piece_action: sails_turn (cosmetic: faster as the lookout rises), cast_on_stage: Ada points (point), the Wizard cheers from a cloud (cheer) }
hud_meter: Altitude, themed purple wood
g0: by formula (the gentlest in the campaign)
world_change: Ada sees the sheep and they trot into the pen
```

## 8. Anchors for the non-level rubrics (short)

- **N1-N3, one chapter entry (9.7):** "Chapter 11, Pirate. Problem: Captain Crumpet's crew holds the last key.
  Ally: a gull pilot. Villain: Crumpet, vain and loud, never cruel. Heroes: Ada leads, Bram hauls, Sif
  scouts. Stakes: the way to the Fair. Role: swagger and rising energy, intensity 4. Hook: the key opens the
  finale." It is one paragraph, within the tone rules, and ties to the arc table.
- **M7, one handbook entry (9.7):** "Vines. What it does: a green strand grows from one side every few
  seconds and ties the nearest block in place. How you read it: the strand glows green before it grows. Example:
  a vine holds your plank so you can add a second one. It never removes or moves a block on its own. Debut:
  forest_05." No engine terms.
- **A, C, S:** a 9.7 item is one with evidence on file for every level (spec cost sheet, retained
  screenshots, or a cue list) and no structural fix pending.
