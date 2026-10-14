# Calibration exemplars (game director, 2026-10-14, revision 6)

Anchors for the panel (`campaign-vision.md` section 9). Written by the game director, not the makers.

**Rules for using this file**
- **Form, not content.** The exemplars teach structure and level of detail. No real level may reuse an
  exemplar's set piece, terrain, footprint, mask, ending or character. Exemplar ids carry the `ex_` prefix
  (`ex_forest_05`) so they never collide with real ids; the real levels must still differ from them. The 9.7
  exemplars (`ex_forest_02`, `ex_forest_05`, `ex_forest_h1`, `ex_pirate_03`, `ex_pirate_10`, `ex_meadow_01`,
  `ex_underwater_09`, `ex_candy_03`) are included in the U3, U14, U17, U18 and U19 checks; each has a `level_table` row in
  section 9. The `ex_near_*` and `ex_weak_*` samples are excluded: they fail on purpose and exist only for human
  scoring. Exemplar ids are not in campaign order (for instance `strike` is shown in `ex_pirate_03` and
  `ex_underwater_09`; in the real campaign it is taught once, in the first biome that uses it).
- **Exemption.** Fields derived from phase 3 formulas (`g0`, stars, goal numbers) are written `by formula`.
  Handbook links point to entries phase 3 will write (`handbook#<rule>`).
- Text shown in play is never sarcastic or mocking, and has no words inside play.
- Only `ex_forest_05` is shown complete. Entries marked **Abridged** show only the fields that teach their
  role; assume every other required field is present and valid.
- Every level starts from its `mechanic` and `verb` (ruling A) and has its own `footprint` (ruling B).
- The scale: 10 = no change requested; 9.7 = wording or tuning notes only; 9.0 = a structural fix is needed.

## 1. Exemplar beat (9.7)

```yaml
id: ex_forest_05
role: twist
verb: build                      # proposed by the narrative lead; the systems designer confirms
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
The objective names a story object (U15). The opening event is distinct and silent (U8). One verb (build).

## 2. Exemplar spec (9.7, complete)

```yaml
mechanic: [gap_runner, vines]    # the bases (ruling A): the module gap_runner (debuted in Meadow) and the rule vines (taught alone in ex_forest_02)
extras: [gust]                   # a rule taught in biome 1; handbook#gust
verb: build
extra_control: none
id: ex_forest_05
tutorial_line: Build a bridge so Nanny Tuft can walk across.      # 9 words
name: Goat Gully
role: twist                      # adds NO new mechanic; its novelty is the goal-phase twist
headline_objective: Help Nanny Tuft cross the gully
goal_type: [span, survive]       # play order; U3 compares the whole list
goal_params: by formula          # gap 4 cells, hold time
target_visible: yes, a lit footprint trail on the far ledge from frame 0
ending_pattern: twist            # written to metadata.ending
metadata.signature: The one where the bridge is finished and the wind arrives.
footprint: bridge span 12x8      # recogniser: a 4-wide gap, 3 rows deep, open at the top, 4-wide pillars, a 5-deep base
mask: |
  ####....####
  ####....####
  ####....####
  ############
  ############
  ############
  ############
  ############
canonical_mask: "8x12:########/########/########/########/#####.../#####.../#####.../#####.../########/########/########/########"
spawn_cols: 0-3                  # the centre 4 columns (4-7) are void in the top rows, so the spec names the left pillar
flavour: none
telegraph: n/a                   # no strike in this level
corridor_check: min_spawn_width 4 (the left pillar, columns 0-3, is a 4-wide floor run); min_dead_end_width n/a
minigame_block: gap_runner (phase 1 of 2), recall of its Meadow debut
look: { time_of_day: golden, weather: petals, set_piece: rotten_plank_bridge, set_piece_side: back,
        accent: "#7BD36B", camera: low, dressing: lush }
scene:
  terrain: ravine_ledges
  set_piece_action: root_whip    # cosmetic: roots sway the bridge for show; no block moves or is removed
  cast_on_stage: Sif lowers a rope and hauls planks (haul); Nanny Tuft paces and rings her bell (react)
  hud_meter: Gust meter, reading the strength of `gust` in the gale phase (a readout of a taught rule)
g0: by formula
stars: by formula
opening_event: goat_bell_rings
world_change: the bridge holds, Nanny Tuft crosses, fireflies light the gully
comic_fail: Nanny Tuft slides down on her bottom, the bell rings once, and Sif covers her eyes; retry in 1.5 s
callback_of: none
```

Mechanic budget: this level adds no mechanic. `vines` debuts in `ex_forest_02` and `gap_runner` in Meadow, so the
two bases are both taught earlier. The gale is `gust`, known from biome 1.
`root_whip` is cosmetic, so it needs no handbook entry and the vine entry stays true: a vine-held bridge sways
but never loses a block. Minigame check (P2d): one goal, one 9-word sentence, a themed meter, a story payoff,
standard controls.

## 3. Near-miss sample (about 9.0)

**Abridged for display; assume every other required field is present and valid.**

```yaml
mechanic: [vines]
verb: build
extra_control: none
id: ex_near_forest_06
name: Cliff Crossing
headline_objective: Get the cart across the cliff
ending_pattern: twist
metadata.signature: The one with vines and a gust and a cart.     # names rules, not an event
goal_type: [span, survive]
footprint: L 8x8
scene: { terrain: summit_ledge, set_piece_action: lantern_sway, cast_on_stage: Sif hauls (haul), a villager cheers (cheer) }
look: { time_of_day: golden, weather: petals, set_piece: old_tree, camera: low }   # old_tree is decorative
```

Not a failure: the twist is good, the fields are present and the footprint is its own. Expected scores: L1 9.3,
L2 9.0, L3 9.0, L4 9.3, L5 9.2, L6 8.5, L7 9.0 (mean about 9.0). The structural fix that keeps it from 9.7: give
the scene substance (a specific terrain id, an action that does something named, a pose set unlike its
neighbour's) and rewrite the signature as an event. Its ids are on the list but generic: `summit_ledge` and
`lantern_sway` do not belong to a forest gully, the pose set repeats the neighbour's, and the look fingerprint is
close to `ex_forest_05`. The defect is "generic", not "unlisted".

## 4. Weak samples (8.0 or below)

**Weak spec**

```yaml
id: ex_weak_forest_05
name: Log Challenge
headline_objective: Clear 4 layers
ending_pattern: plain
metadata.signature: A forest level with some vines and 4 layers to clear.
goal_type: [clear_n]
footprint: plain square 8x8      # a second plain square in the biome
mask: 8x8 full square
look: { time_of_day: day, weather: clear, set_piece: tree, camera: default }
scene: { terrain: floating island, set_piece_action: none, cast_on_stage: none }
opening_event: level_start
world_change: the level ends
```

Defects (each caps the score): no `mechanic` or `verb`, so it is not a minigame (P2d; caps M1, M3, L3 at 8.0); a
counter goal and mundane (U15, P2c; caps N4, M3, L3 at 8.0); a repeated plain square (U18; caps L6 and A1 at
8.0); no scene (P1b; caps L6 at 8.0); fails the swap test (P1a); plain ending and a rule-naming signature (U4,
U16); default camera and generic set piece (U7, U14); empty opening event and world change (U8, U11); missing
`target_visible`, `comic_fail` and `level_table` row (L7). Expected: L1 8, L2 7, L3 6, L4 8, L5 8, L6 4, L7 6.

**Weak beat (N4 at about 7)**

```yaml
id: ex_weak_forest_05
place: A mossy place.
who: The heroes
problem: There are blocks.
why_stack: The heroes stack blocks to clear four rows.
headline_objective: Clear four rows
ending_pattern: plain
world_change: The level ends.
```

Defects: no named place, no problem, no verb, no reason to stack beyond a counter (U15, P2c), a numeral and
"clear" in the headline, an empty `wordless_moment`, `opening_event` and `caption`, and it fails the swap test.

**Weak handbook entry (M7 at about 7)**

```
Vines: uses the vine_tick signal to attach a node to the nearest block every N frames.
```

Defects: engine terms, no "how the player reads it", no worked example, no "what it never does", no debut level.

## 5. Boss exemplar (9.7), tier 10, flavour D3, with a boss triple

**Abridged:** the spec fields that teach the boss role are shown; `metadata.signature`, `target_visible` and the
full `look` block are present in the real spec.

```yaml
mechanic: [strike, row_cannon]   # both taught earlier (strike variant: cannon); the boss adds NO new mechanic
extras: [tilt_plate]             # taught in pirate_06, used in phase 3
verb: destroy
extra_control: fire              # the one extra button: fire the reef... the deck cannon
id: ex_pirate_10
tutorial_line: Wall off the cannons, then fire back with full rows.     # 10 words
name: Crumpet's Deck
role: boss
flavour: D3                      # shield and strike
headline_objective: Win back the last key from Captain Crumpet
ending_pattern: guest            # a rival gull-ship joins in phase 2
goal_type: [bonk_boss]           # hits by formula; cleared rows load your cannon (the damage route)
footprint: L 8x8                 # a thick L-shaped deck
mask: "8x8:########/########/########/########/####..../####..../####..../####...."
canonical_mask: "8x8:########/########/########/########/####..../####..../####..../####...."
corridor_check: min_spawn_width 8 (top rows); min_dead_end_width 4 (the leg), above the 3-cell minimum
telegraph: the cannon's arm cranks back 3 s before every volley (Pirate is intensity 4, so 2 s is the minimum)
boss_triple: { arena: l_deck, phases: 3, building_action: wall }   # a wall blocks the volley
phases:
  - p1: Crumpet fires the cannon `strike` from the bow; the player walls the volley
  - p2: one idea (a variant of a taught rule), a rival gull-ship adds a second firing lane (guest)
  - p3: the same volley at higher speed on a rocking deck (tilt_plate, already an extra); no new idea
scene: { terrain: ship_deck, set_piece_action: cannon_volley, cast_on_stage: Ada braces behind a wall (brace), Bram hauls shot (haul) }
world_change: the key drops into Ada's hands and the ship turns toward the Fair
hook_to_finale: the key is the Carnival's ticket (stakes: "The last key and the way to the Fair")
comic_fail: the captain's hat is blown off and spins on a cannon; retry in 1.5 s
```

Why: the boss combines mechanics taught earlier, adds one idea per phase, is tied to its chapter, is beaten by
building (U9), has a unique `(arena, phases, building_action)` (U12) and hands over a finale-bound hook.
`ex_pirate_03` (section 9) shows the single-lane teach version of the same `strike` variant.

## 6. Hard-remix exemplar (9.7), flavour D4

**Abridged:** `metadata.signature`, `target_visible`, `world_change` and `comic_fail` are present in the real spec.

```yaml
mechanic: [gap_runner, vines]    # the module gap_runner supplies the span goal
extras: [gust]
verb: rescue
extra_control: none
id: ex_forest_h1
tutorial_line: Hold the bridge, then find the kid goat.     # 8 words
name: Gully by Dusk
role: hard
callback_of: ex_forest_05
flavour: D4                      # shelter the guest: the kid goat is the guest, the gale is the hazard
headline_objective: Help Nanny Tuft cross before the gale
ending_pattern: reveal           # hidden: a kid goat is under the bridge. Telegraph: a bleat and a tail poking out of the left pillar in the first 10 seconds
goal_type: [survive, span, rescue_all]   # differs from ex_forest_05's list (U3); rescue_all inside a goal sequence
footprint: stair 12x8            # differs from the source's bridge span 14x8 (U18)
mask: |
  ........####
  ........####
  ....########
  ....########
  ############
  ############
  ############
  ############
canonical_mask: "8x12:########/########/########/########/######../######../######../######../####..../####..../####..../####...."
spawn_cols: 4-7                  # the first floor row across these columns is row index 2 (zero-based), 4 wide
look: { time_of_day: dusk, weather: mist, set_piece: rotten_plank_bridge, camera: wide }   # differs in time of day (U3 remix rule)
scene: { terrain: stepped_ravine, set_piece_action: root_whip, cast_on_stage: Sif braces the rope (brace) }
g0: by formula (faster than forest_10)
```

## 7. Level-01 exemplar (9.7), one mechanic, an opening set, gentle

**Abridged:** the signature, `look` and comic fail are shown; `target_visible` and the handbook link are too.

```yaml
mechanic: [lookout]              # the only mechanic; handbook#lookout
verb: build
extra_control: none
id: ex_meadow_01
tutorial_line: Stack high so Ada can spot the sheep.      # 9 words
name: Windmill Lookout
role: teach
headline_objective: Raise the lookout so Ada spots sheep      # 7 words
metadata.signature: The one where the windmill sails spin faster as the lookout climbs.
ending_pattern: plain            # level 01 may not hide its goal
goal_type: [height]
target_visible: yes, a gold flag line on the windmill from frame 0
footprint: plain square 8x8      # Meadow's one allowed plain square
mask: "8x8:########/########/########/########/########/########/########/########"
opening_set: friendly first pieces (by formula)
look: { time_of_day: dawn, weather: clear, set_piece: windmill, camera: default }
scene: { terrain: hilltop_ledge, set_piece_action: sails_turn, cast_on_stage: Ada points (point), the Wizard cheers from a cloud (cheer), hud_meter: Altitude, themed purple wood }
p2b_note: level 01 is exempt from P2b; the lookout mechanic asks for a tall, steady stack and changes no drop
opening_event: sheep_bleat
comic_fail: the lookout wobbles and Ada sits down with a thump, then waves; retry in 1.5 s
g0: by formula (the gentlest in the campaign)
world_change: Ada sees the sheep and they trot into the pen
```

## 7b. Defence exemplar (9.7), a rehearsal fight (flavour D3)

**Abridged:** the fields that teach the defence flavour are shown; the signature, `look`, `target_visible` and
`comic_fail` are present in the real spec.

```yaml
mechanic: [strike, row_cannon]   # both taught earlier (strike variant: tentacle); the level adds no new mechanic
verb: defend
id: ex_underwater_09
tutorial_line: Plug the wall, then fire back with full rows.     # 9 words
name: Squidge at the Reef        # a working name; it passes the title script
role: combine
flavour: D3                      # shield and strike
headline_objective: Hold the reef wall against Squidge    # the boss is named; no row count
ending_pattern: reveal           # Squidge is reaching for its lost baby behind the wall; telegraph: a small cry and a baby's eye behind the coral
goal_type: [bonk_boss]           # a REHEARSAL: Squidge is driven back but not beaten; the tier-10 boss is its parent, Mother Squidge
footprint: funnel 10x8
mask: |
  ##########
  ##########
  ##########
  ##########
  ##########
  ##########
  .########.
  ..######..
canonical_mask: "8x10:######../#######./########/########/########/########/########/########/#######./######.."
spawn_cols: default (centre 4 columns; the top rows are full floor)
corridor_check: min_spawn_width 10, min_dead_end_width n/a
scene:
  terrain: reef_wall
  set_piece_action: tentacle_grab        # a `strike` variant, a rule, never cosmetic
  cast_on_stage: Bram loads the reef cannon (haul); Sif points at the next lane (point); Squidge looms behind the wall (react)
  hud_meter: Reef HP, themed purple wood, plus a Squidge calm bar
telegraph: a tentacle rises from the water 3 s before every grab (P3e: at least 2 s in an intensity-3 biome)
world_change: Squidge's baby swims out, Squidge calms and swims off to fetch its parent; the reef glows
```

Why: the threat is a character on stage, the thing defended is a landmark wall, the blocks have a name (wall and
ammo), the telegraph is an actor, the meter is named for the fiction, and the headline names the boss. It is a
rehearsal, so the boss is not resolved a level early (U9): the tier-10 finale is a different fight (Mother
Squidge, a different arena, phases and building action).

## 8. Anchors for the non-level rubrics

- **N1-N3, a chapter entry (9.7):** "Chapter 11, Pirate. Problem: Captain Crumpet's crew holds the last key.
  Ally: a gull pilot. Villain: Crumpet, vain and loud, never cruel. Heroes: Ada leads, Bram hauls, Sif scouts.
  Stakes: the way to the Fair. Role: swagger and rising energy, intensity 4. Hook: the key opens the finale."
- **M7, a handbook entry (9.7):** "Vines. What it does: a green strand grows from one side every few seconds and
  ties the nearest block in place. How you read it: the strand glows green before it grows. Example: a vine
  holds your plank so you can add a second one. It never removes or moves a block on its own; in a gale a
  vine-held bridge sways but never loses a block. Verb: build. Debut: forest_02." (Compare the weak entry in
  section 4.)
- **A (art):** 9.0 = a cost sheet that lists the set pieces but gives no size or owner. 9.7 = a sheet with a
  size, an owner and a reduced-motion pose for each of the 84-96 pieces, totalled against the phase 6 buffer.
- **C (captures):** 9.0 = a contact sheet where two levels in a biome look alike at a glance. 9.7 = a sheet where
  all 14 differ by footprint, terrain, set piece and mask, with a note of the U5 score of each pair.
- **S (sound):** 9.0 = a cue list that covers actions but has one music loop for several biomes. 9.7 = a cue list
  with a theme per biome that follows the arc, boss and ending stings, and a comic fail sound.

## 9. `level_table` rows for the 9.7 exemplars (script input)

Columns: id | mechanic | verb | goal_type | footprint | mask | terrain | set_piece | set_piece_action | cast_pose |
time_of_day | weather | camera | opening_event | ending_pattern | headline_objective | role | callback_of | flavour |
telegraph | min_spawn_width | min_dead_end_width

```
ex_forest_02 | vines | build | height | plain square 10x8 | 8x10:########/########/########/########/########/########/########/########/########/######## | treetop_platform | hollow_oak | bell_ring | build,react | day | petals | default | squirrel_scampers | plain | Lift the nest above the vines | teach | none | none | n/a | 10 | n/a
ex_forest_05 | vines | build | span>survive | bridge span 14x8 | 8x14:########/########/########/########/#####.../#####.../#####.../#####.../#####.../#####.../########/########/########/######## | ravine_ledges | rotten_plank_bridge | root_whip | haul,react | golden | petals | low | goat_bell_rings | twist | Help Nanny Tuft cross the gully | twist | none | none | n/a | 4 | n/a
ex_forest_h1 | vines | rescue | survive>span>rescue_all | stair 12x8 | 8x12:########/########/########/########/######../######../######../######../####..../####..../####..../####.... | stepped_ravine | rotten_plank_bridge | root_whip | brace | dusk | mist | wide | kid_goat_bleat | reveal | Help Nanny Tuft cross before the gale | hard | ex_forest_05 | D4 | n/a | 4 | n/a
ex_pirate_03 | strike | defend | survive | plain square 9x9 | 9x9:#########/#########/#########/#########/#########/#########/#########/#########/######### | dock_pier | harbour_cannon | cannon_volley | brace,point | day | clear | low | gull_lands | plain | Hold the dock against the gull gun | teach | none | D1 | 3 | 9 | n/a
ex_pirate_10 | strike,row_cannon | destroy | bonk_boss | L 8x8 | 8x8:########/########/########/########/####..../####..../####..../####.... | ship_deck | pirate_galleon | cannon_volley | brace,haul | dusk | clear | low | crumpet_laughs | guest | Win back the last key from Captain Crumpet | boss | none | D3 | 3 | 8 | 4
ex_meadow_01 | lookout | build | height | plain square 8x8 | 8x8:########/########/########/########/########/########/########/######## | hilltop_ledge | windmill | sails_turn | point,cheer | dawn | clear | default | sheep_bleat | plain | Raise the lookout so Ada spots sheep | teach | none | none | n/a | 8 | n/a
ex_underwater_09 | strike,row_cannon | defend | bonk_boss | funnel 10x8 | 8x10:######../#######./########/########/########/########/########/########/#######./######.. | reef_wall | coral_towers | tentacle_grab | haul,point,react | golden | bubbles | default | baby_eye_blinks | reveal | Hold the reef wall against Squidge | combine | none | D3 | 3 | 10 | n/a
```

Notes for the script: `ex_forest_02` (plain 10x8, Forest's one plain square), `ex_pirate_03` (plain 9x9, Pirate's
one), `ex_meadow_01` (plain 8x8, Meadow's one) each use their biome's single allowed plain square. In `ex_forest_*`
the three footprints are different shapes, so U18 holds. `ex_pirate_10`'s `ship_deck` and `ex_pirate_03`'s
`dock_pier` differ, and the pair `(terrain, set_piece_action)` of the two Pirate levels is the same action with
different terrains, so it is unique.
