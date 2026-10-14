# Calibration exemplars (game director, 2026-10-14)

Anchors for the panel (`campaign-vision.md` section 9). Written by the game director, not the makers. The level
here is invented for calibration only: it is neutral to the high concept, and it is not a binding level. Values
marked TBD come from the phase 3 formulas. Names pass the board-title ban.

## 1. Exemplar beat (target 9.7 on N4)

```yaml
id: forest_05
role: twist                      # function label; the systems designer maps it to a rule
place: Goat Gully, a mossy ravine with a rotten plank bridge, treetop canopy overhead
who: Sif on the near ledge, a goat called Nanny Tuft on the far ledge, a gust imp hiding in the roots
problem: Nanny Tuft is stuck across the gully with her bell, and the old bridge has rotted away.
why_stack: Stacked blocks make the new bridge and the safe steps the goat will walk on.
headline_objective: Help Nanny Tuft cross the gully   # story noun, no numeral
ending_pattern: twist            # the bridge is done, then a gale arrives and the goat must be held on
world_change: Nanny Tuft trots home, the new bridge sways, and the gully glows with fireflies.
wordless_moment: Sif waves a rope; Nanny Tuft shakes her bell and pokes a hoof at the first gap.
opening_event: goat_bell_rings   # unique id, phase 2 list
caption: A bridge, a bell and a very patient goat.   # 9 words
```

Why it scores: one place, one problem, a named reason to stack (P1a). The ending is not predictable from
frame 0 and is telegraphed by the imp's rustle in the roots (U16, fair). The objective names a story object
(U15). The opening event is distinct and silent (U8). The world change is visible (P2a). The caption is short.

## 2. Exemplar spec (target 9.7 on L1-L7)

```yaml
id: forest_05                    # = beat id = level id
name: Goat Gully                 # 2 words, no board title
role: twist
headline_objective: Help Nanny Tuft cross the gully
ending_pattern: twist            # written to metadata.ending
metadata.signature: The one where the bridge is finished and the wind arrives.   # 11 words
main_rule: vines                 # roster id; extras: gust (taught in biome 2, so allowed on the pill)
goal_type: span                  # phase 1: bridge the gap for the walker; phase 2 (twist): survive the gale
goal_params: { gap_cells: 6, hold_seconds: 8 }   # n from the phase 3 formula; hold_seconds TBD
target_visible: yes, a lit footprint trail on the far ledge from frame 0
mask: |                          # 12 x 8, '#' floor, '.' void; a trench between two pillars
  ###......###
  ###......###
  ###......###
  ############
  ############
  ############
  ############
  ############
minigame_block: gap_runner (phase 1 of 2); recall of the Meadow debut, now with vines
look: { time_of_day: golden, weather: petals, set_piece: rotten_plank_bridge, set_piece_side: back,
        accent: "#7BD36B", camera: low, dressing: lush }
scene:
  terrain: a ravine; two mossy ledges, a plank bridge built from the player's own blocks over a stream
  set_piece_action: the old bridge's ropes snap at the start; in phase 2 the roots whip the new bridge in the gale
  cast_on_stage: Sif lowers a rope and hauls planks; Nanny Tuft paces and rings her bell; the gust imp peeks out
  hud_meter: Sway meter (Balance), themed purple wood, no beige
g0: TBD (phase 3 formula, tier 05 of biome 6)
stars: TBD (phase 3 formula)
opening_event: goat_bell_rings
world_change: the bridge holds, Nanny Tuft crosses, fireflies light the gully
comic_fail: Nanny Tuft slides down on her bottom and Sif holds up a "ten out of ten" leaf; retry in 1.5 s
callback_of: none
level_table_row: forest_05 | span | vines | U-trench-12x8 | rotten_plank_bridge | golden | petals | low | goat_bell_rings | twist | Help Nanny Tuft cross the gully | twist | none
```

Why it scores: the scene fields are specific and tied to this level (P1b); the world is a place, not a floating
square; the set piece acts; every required field is present; the ending is a twist with a fair telegraph; the
board is a trench mask with a distinct silhouette (U5, U14); one new idea (vines) alongside a known rule (U10).
Open risk the panel should still ask about: `span` is a phase 3 goal (engine gap, owner and size TBD).

## 3. Weak sample (target 8.0 or below)

```yaml
id: forest_05
name: Log Challenge
role: twist
headline_objective: Clear 4 layers
ending_pattern: plain
metadata.signature: A forest level with some vines and 4 layers to clear.
main_rule: vines
goal_type: clear_n
goal_params: { n: 4 }
mask: 8x8 full square
look: { time_of_day: day, weather: clear, set_piece: tree, camera: default }
scene: { terrain: floating island, set_piece_action: none, cast_on_stage: none }
opening_event: level_start
world_change: the level ends
```

Defects the panel should find (each caps the score):
- **Counter goal and mundane (U15, P2c):** "Clear 4 layers" is a bare counter. Caps N4, M3, L3 at 8.0.
- **No scene (P1b):** terrain is "floating island", the set piece does nothing, nobody is on stage. Caps L6 at 8.0.
- **Swap test fails (P1a):** it works unchanged in any biome.
- **Plain ending and a weak signature (U4, U16):** the signature names rules, not an event; no surprise.
- **Plain square, default camera, generic set piece (U7, U14):** its look fingerprint is a duplicate in the biome.
- **Opening event and world change are empty (U8, U11):** "level_start" and "the level ends".
- **Missing fields:** no `target_visible`, `comic_fail`, `g0`, stars or `level_table` row (L7).
Expected panel scores: L1 8, L2 7, L3 6, L4 8, L5 8, L6 5, L7 6.
