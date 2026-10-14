# Calibration exemplars (game director, 2026-10-14, revision 3)

Anchors for the panel (`campaign-vision.md` section 9). Written by the game director, not the makers.

**Rules for using this file**
- **Form, not content.** The exemplars teach structure and level of detail. No real level may reuse an
  exemplar's set piece, terrain, mask, ending or character. Exemplar ids carry the `ex_` prefix
  (`ex_forest_05`) so they never collide with real ids; the real levels must still differ from them, and the
  exemplars are included in the U3, U14 and U17 checks.
- **Exemption.** Fields derived from phase 3 formulas (`g0`, stars, goal numbers) are written `by formula`.
  Handbook links point to entries phase 3 will write (`handbook#<rule>`).
- Text shown in play is never sarcastic or mocking, and has no words inside play.
- Only `ex_forest_05` is shown complete. Entries marked **Abridged** show only the fields that teach their
  role; assume every other required field is present and valid.
- The scale: 10 = no change requested; 9.7 = wording or tuning notes only; 9.0 = a structural fix is needed.

## 1. Exemplar beat (9.7)

```yaml
id: ex_forest_05
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

Why: one place, one problem, a reason to stack (P1a). The twist is telegraphed by the imp's rustle (U16, fair).
The objective names a story object (U15). The opening event is distinct and silent (U8).

## 2. Exemplar spec (9.7, complete)

```yaml
id: ex_forest_05
name: Goat Gully
role: twist                      # adds NO new rule; its novelty is the goal-phase twist
headline_objective: Help Nanny Tuft cross the gully
ending_pattern: twist            # written to metadata.ending
metadata.signature: The one where the bridge is finished and the wind arrives.
main_rule: vines                 # taught alone in ex_forest_02; handbook#vines
extras: [gust]                   # handbook#gust (taught in biome 1)
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
corridor_check: the trench is 6 cells wide, above the 4-cell spawn minimum; no dead-end narrower than 3
minigame_block: gap_runner (phase 1 of 2), recall of its Meadow debut
look: { time_of_day: golden, weather: petals, set_piece: rotten_plank_bridge, set_piece_side: back,
        accent: "#7BD36B", camera: low, dressing: lush }
scene:
  terrain: ravine_ledges
  set_piece_action: root_whip    # cosmetic: roots sway the bridge for show; no block moves or is removed
  cast_on_stage: Sif lowers a rope and hauls planks (haul); Nanny Tuft paces and rings her bell (react)
  hud_meter: Sway meter (Balance); fits the gale phase
g0: by formula
stars: by formula
opening_event: goat_bell_rings
world_change: the bridge holds, Nanny Tuft crosses, fireflies light the gully
comic_fail: Nanny Tuft slides down on her bottom, the bell rings once, and Sif covers her eyes; retry in 1.5 s
callback_of: none
level_table_row: ex_forest_05 | span>survive | vines | 8x12:... | ravine_ledges | rotten_plank_bridge | root_whip | haul,react | golden | petals | low | goat_bell_rings | twist | Help Nanny Tuft cross the gully | twist | none
```

Rule budget: this level adds no rule. `vines` debuts in `ex_forest_02` (abridged: a teach level, one rule, an
opening set, `goal_type: [height]`, plain ending). The gale is `gust`, known from biome 1. `root_whip` is cosmetic,
so it needs no handbook entry and the vine entry stays true: a vine-held bridge sways but never loses a block.

## 3. Near-miss sample (about 9.0)

**Abridged for display; assume every other required field is present and valid.**

```yaml
id: ex_forest_06
name: Cliff Crossing
headline_objective: Get the cart across the cliff
ending_pattern: twist
metadata.signature: The one with vines and a gust and a cart.     # names rules, not an event
main_rule: vines
goal_type: [span, survive]
scene: { terrain: cliff, set_piece_action: sways, cast_on_stage: Sif hauls (haul), a villager cheers (cheer) }
look: { time_of_day: golden, weather: petals, set_piece: old_tree, camera: low }   # old_tree is decorative
```

Not a failure: the twist is good and the fields are present. Expected scores: L1 9.3, L2 9.0, L3 9.0, L4 9.3,
L5 9.2, L6 8.5, L7 9.0 (mean about 9.0). The structural fix that keeps it from 9.7: give the scene substance
(a specific terrain id, an action that does something named, a pose set unlike its neighbour's) and rewrite the
signature as an event. `sways` is deliberately not on the closed list (U17); the pose set repeats the neighbour's
and the look fingerprint is close to `ex_forest_05`.

## 4. Weak samples (8.0 or below)

**Weak spec**

```yaml
id: ex_forest_05
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

Defects (each caps the score): a counter goal and mundane (U15, P2c; caps N4, M3, L3 at 8.0); no scene (P1b;
caps L6 at 8.0); fails the swap test (P1a); plain ending and a rule-naming signature (U4, U16); plain square,
default camera, generic set piece (U7, U14); empty opening event and world change (U8, U11); missing
`target_visible`, `comic_fail` and `level_table` row (L7). Expected: L1 8, L2 7, L3 6, L4 8, L5 8, L6 5, L7 6.

**Weak beat (N4 at about 7)**

```yaml
id: ex_forest_05
place: A mossy place.
who: The heroes
problem: There are blocks.
why_stack: The heroes stack blocks to clear four rows.
headline_objective: Clear four rows
ending_pattern: plain
world_change: The level ends.
```

Defects: no named place, no problem, no reason to stack beyond a counter (U15, P2c), a numeral and "clear" in the
headline, an empty `wordless_moment`, `opening_event` and `caption`, and it fails the swap test.

**Weak handbook entry (M7 at about 7)**

```
Vines: uses the vine_tick signal to attach a node to the nearest block every N frames.
```

Defects: engine terms, no "how the player reads it", no worked example, no "what it never does", no debut level.

## 5. Boss exemplar (9.7), tier 10 with a boss triple

**Abridged:** the spec fields that teach the boss role are shown; `metadata.signature`, `target_visible`,
`opening_event` and the full `look` block are present in the real spec.

```yaml
id: ex_pirate_10
name: Crumpet's Deck
role: boss
headline_objective: Win back the last key from Captain Crumpet
ending_pattern: guest            # a rival gull-ship joins in phase 2
main_rule: cannon_volley         # taught alone in ex_pirate_03; handbook#cannon_volley (a rule: balls knock out the top row)
goal_type: [bonk_boss]           # hits by formula; cleared rows load your cannon (the damage route)
mask: "8x8:########/########/########/########/####..../####..../####..../####...."   # a thick L-shaped deck
canonical_mask: "8x8:########/########/########/########/####..../####..../####..../####...."
corridor_check: the deck is 8 wide at the top and 4 wide in the leg, meeting the 4-cell spawn minimum
boss_triple: { arena: l_deck, phases: 3, building_action: wall }   # a wall blocks the volley
phases:
  - p1: Crumpet fires cannon_volley from the bow; the player walls the volley
  - p2: one new idea, a rival gull-ship adds a second firing lane for the same volley (guest)
  - p3: the same volley at higher speed on a rocking deck (tilt_plate, taught in pirate_06); no new idea
scene: { terrain: ship_deck, set_piece_action: cannon_volley, cast_on_stage: Ada braces behind a wall (brace), Bram hauls shot (haul) }
world_change: the key drops into Ada's hands and the ship turns toward the Fair
hook_to_finale: the key is the Carnival's ticket (stakes: "The last key and the way to the Fair")
comic_fail: the captain's hat is blown off and spins on a cannon; retry in 1.5 s
```

Why: the boss combines rules taught earlier, adds one idea per phase, is tied to its chapter, is beaten by
building (U9), has a unique `(arena, phases, building_action)` (U12) and hands over a finale-bound hook.
`ex_pirate_03` (abridged) teaches `cannon_volley` alone on a plain `[height]` level with a single lane.

## 6. Hard-remix exemplar (9.7)

**Abridged:** `metadata.signature`, `target_visible`, `world_change`, `comic_fail` and the mask string are present
in the real spec; the mask is a stepped trench with a different canonical string from `ex_forest_05`.

```yaml
id: ex_forest_h1
name: Gully by Dusk
role: hard
callback_of: ex_forest_05
headline_objective: Help Nanny Tuft cross before the gale
ending_pattern: reveal           # hidden: a kid goat is under the bridge. Telegraph: a bleat and a tail poking out of the left pillar in the first 10 seconds
goal_type: [survive, span, rescue_all]   # differs from ex_forest_05's list (U3)
main_rule: vines
look: { time_of_day: dusk, set_piece: rotten_plank_bridge, camera: wide }   # differs in time of day (U3 remix rule)
scene: { terrain: stepped_ravine, set_piece_action: root_whip, cast_on_stage: Sif braces the rope (brace) }
g0: by formula (faster than forest_10)
```

## 7. Level-01 exemplar (9.7), one rule, an opening set, gentle

**Abridged:** the signature, `look` and comic fail are shown; `target_visible` and the handbook link are too.

```yaml
id: ex_meadow_01
name: Windmill Lookout
role: teach
headline_objective: Raise the lookout so Ada spots sheep      # 7 words
metadata.signature: The one where the windmill sails spin faster as the lookout climbs.
ending_pattern: plain            # level 01 may not hide its goal
main_rule: lookout               # the only rule; handbook#lookout
goal_type: [height]
target_visible: yes, a gold flag line on the windmill from frame 0
mask: "8x8:########/########/########/########/########/########/########/########"   # one of at most 4 plain squares
opening_set: friendly first pieces (by formula)
look: { time_of_day: dawn, weather: clear, set_piece: windmill, camera: default }
scene: { terrain: hilltop_ledge, set_piece_action: sails_turn, cast_on_stage: Ada points (point), the Wizard cheers from a cloud (cheer) }
hud_meter: Altitude, themed purple wood
opening_event: sheep_bleat
comic_fail: the lookout wobbles and Ada sits down with a thump, then waves; retry in 1.5 s
g0: by formula (the gentlest in the campaign)
world_change: Ada sees the sheep and they trot into the pen
```

## 8. Anchors for the non-level rubrics

- **N1-N3, a chapter entry (9.7):** "Chapter 11, Pirate. Problem: Captain Crumpet's crew holds the last key.
  Ally: a gull pilot. Villain: Crumpet, vain and loud, never cruel. Heroes: Ada leads, Bram hauls, Sif scouts.
  Stakes: the way to the Fair. Role: swagger and rising energy, intensity 4. Hook: the key opens the finale."
- **M7, a handbook entry (9.7):** "Vines. What it does: a green strand grows from one side every few seconds and
  ties the nearest block in place. How you read it: the strand glows green before it grows. Example: a vine
  holds your plank so you can add a second one. It never removes or moves a block on its own; in a gale a
  vine-held bridge sways but never loses a block. Debut: forest_02." (Compare the weak entry in section 4.)
- **A (art):** 9.0 = a cost sheet that lists the set pieces but gives no size or owner. 9.7 = a sheet with a
  size, an owner and a reduced-motion pose for each of the 84-96 pieces, totalled against the phase 6 buffer.
- **C (captures):** 9.0 = a contact sheet where two levels in a biome look alike at a glance. 9.7 = a sheet where
  all 14 differ by terrain, set piece and mask, with a note of the U5 score of each pair.
- **S (sound):** 9.0 = a cue list that covers actions but has one music loop for several biomes. 9.7 = a cue list
  with a theme per biome that follows the arc, boss and ending stings, and a comic fail sound.
