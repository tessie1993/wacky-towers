# Campaign skits: "The Party Nobody Could Ask For"

> **Status**: Draft v1 (writer, 2026-10-10), /team-narrative Phase 2, for narrative-director review.
> **Canon**: `production/narrative/campaign-story/brief.md` (the story bible and its 12 writer rules), `design/gdd/narrative/emote-bubbles.md` (emote ids), `design/gdd/narrative/meadow-story.md` §5 (skit brief format).
> **User rulings applied**: the nine earlier bosses appear as guests **only in the grand finale skit**; Cave low point is the **softer** version (his tower wobbles, he catches it, sheepish sigh); side islands and the Scrapbook are kept.
> **Out of scope**: the per-level intro and payoff skits (written later with the level specs). This file covers campaign-level skits only.
> **Wordless.** "Dialogue" here means beat scripts: pose, prop, camera, emote id. No text, no captions. Every timing, name and beat is a tunable default (brief rule 12).

---

## 0. Skit grammar (read first)

### 0.1 Notation

- `0.0–1.0` = seconds from the start of the skit. Totals are defaults.
- `` `id` `` = emote bubble (see `emote-bubbles.md`). One bubble per character at a time; the pose is always given, so the meaning never rests on the icon alone.
- **CAM** = camera note (dropped under reduced motion; the pose stays).
- **[R]** = beats kept on replays (finales: last 2 beats).
- **[GC]** = grumpy-cloud beat. Optional (brief §6, open question 3). Delete the beat and the skit still reads.
- **Clue** = a Mizzle thread beat (≤ 1.5 s, at the rim or in the backdrop, never over the grid, never during a warning).

### 0.2 Skit types and timing rules

| Type | Where it plays | Max length | Skip | Replay | Source |
|---|---|---|---|---|---|
| **I** Level intro | In the countdown | 3 s, ends on the hand-off | No (it is the countdown) | Same | Brief §6 |
| **P** Level payoff | After the win | 5 s | Tap | Same | Brief §6 |
| **M** Mizzle clue | Inside a P or the backdrop | 1.5 s | With the P | Same | Brief §6 |
| **R** Reaction | Live play | 1 s per bubble | n/a | n/a | Brief §6 |
| **Boss intro** | The I of level 10 | 3 s, ends on the hand-off | No | Same | Brief §6 (I rule) |
| **Finale payoff** | The P of level 10 | 6 s first play | Tap | Last 2 beats [R] | Brief §6 |
| **Friend join** | Right after the finale payoff | 4 s + unlock card | Tap (unlock happens anyway) | Unlock card only | Brief §6 |
| **Bonus payoff** | The P of the bonus level | 5 s | Tap | Same | Brief §6 (P rule) |
| **Biome arrival** | Island map, first time the new island opens | **4 s (new default)** | Tap | Never auto-replays | New, flagged |
| **Map change** | Island map, after the finale (and friend join) | **3 s (new default)** | Tap (the change applies anyway) | Never auto-replays | New, flagged |
| **Postcard** | Scrapbook only | 3 s, loops on tap | Back | Any time | Brief §2.4 |
| **Grand finale** | Celestial level 10 payoff | **14 s first play (exception, flagged)**; 6 s core cut | Tap | Core cut [R] | Brief §1, flagged |

Arrival and map-change skits are new channels (the brief lists map changes but no length). They play on the map, never in a level, so they cost no play time (rule 2).

### 0.3 Recurring beats (use these, do not invent synonyms)

| Beat | What it looks like | Used in |
|---|---|---|
| **Hand-off** | Mascot (or boss in a boss intro) looks up at the wizard; the wand glints; the first piece spawns. Every I ends here | All intros |
| **Wand glint** | A gold glint at the wizard's wand tip. It is always **the player's own act** (the last clear, the first piece). The wizard never acts on Mizzle unprompted (rule 8) | Hand-off, first contact, first reply, finale chair |
| **Bonk** | A failure or defeat lands as a soft comic hit: flour, snow, foam, confetti. Stars circle once (`dizzy`). Nobody is hurt (rule 3) | Every boss defeat |
| **Gift misread** | The boss uses the party gift for their own grievance; the violet ribbon flag flaps on it, unnoticed | Arrivals, boss intros |
| **Parcel drop** | The mail-cloud drifts down, drops a ribboned parcel, puffs off (`gift` over the mail-cloud) | Arrivals 8, 9 |
| **Flag on the gadget** | In a finale the flag stays on the gadget as set dressing. It gets a camera hold **only if it is that payoff's one clue** | Finales |
| **Peek** | Mizzle half behind a prop, one lens glinting. Caught: `sweat`, he ducks | Clues |
| **Glasses push** | One finger pushes his spectacles up. Nervous | Clues |
| **Chair straighten** | He squares a chair for a guest who is not there | Clues 3, 8 |
| **Counting fingers** | He counts guests on his fingers, stops at one | Clues |
| **Doodle** | He traces a block in the air with his wand. The result follows the progression in 0.5 | Clues |
| **Clink** | Everyone raises a cup; a single ring | Grand finale, epilogue |
| **Keepsake pop** | The keepsake flies to the hat brim (`sparkle`), existing growing-hat gag | Finales |

### 0.4 Emote usage by character (campaign)

The `Who` column in `emote-bubbles.md` was written for Meadow. The table below extends it for the campaign and is a **proposal for narrative-director** (see Concerns). `tear` is never extended.

| Character | Uses | Never uses | Notes |
|---|---|---|---|
| **Cloud wizard** | `sweat`, `sparkle`, `idea`, `heart`, `exclaim`, `dizzy`, `note`, `gloom` (loss only) | `tear`, `angry`, `smug` | Reacts to the player's play only (rule 8) |
| **Mizzle** | Surface: `smug` (rare, a cover), `idea`. Real: `dots`, `tear`, `blush`, `sweat`, `gift`, `invite` (violet-star variant). `heart` **finale and epilogue only** | `angry`, `exclaim`, `sleep`, `gloom` | Caught = `sweat` + duck, never `exclaim` |
| **The Miller** | `smug`, `angry`, `gloom`, `dots`, `blush`, `heart`, `note`, `exclaim`, holds `invite` | `tear` after Meadow (his loneliness is resolved) | Post-Meadow he is a friendly rival: wink + fist-shake |
| **Pip** | Meadow canon | | Stays home after Meadow (rule 10) |
| **Mascots (2-10)** | `heart`, `exclaim`, `question`, `sweat`, `note`, `sparkle`, `dizzy`, `idea` | `tear`, `smug` | Flavour: Mallow `heart`; Pebble `dots` (deadpan); Puff `exclaim` (inflates); Cinder `angry` (sulk, sparks); Chip `idea`; Nugget `question`; Tock `sweat` (runs down); Glitch `sparkle`; Comet `note` |
| **Bosses** | `smug`, `angry`, `gloom`, `exclaim`, `dizzy`, `question`, `sleep` (Oak, Geode, Moon); `sweat` and `heart` in the grand finale only | `tear` | Rivals, never cruel (rule 5) |
| **Lana** | `heart`, `note`, `idea`, `blush`, `sweat` | `tear` | Brief §5 |
| **Boulder** | `exclaim`, `sparkle`, `sweat`, `note`, `heart` | `tear` | Brief §5 |
| **Glim** | `idea`, `question`, `exclaim`, `angry`, `sparkle` | `tear` | Brief §5 |
| **Mail-cloud** | `gift`, `invite` (star), `sweat`, `heart` (epilogue) | `tear` | |
| **Grumpy cloud** [GC] | `gloom`, `exclaim` (sees a star-stamped prop), `heart` (finale) | `tear` | Existing loss gag unchanged |
| **Crumb** (Drizzle Rock) | `exclaim`, `sweat`, `dots`, `question`, `heart` (its finale) | `tear` | |

`tear` is used only by Mizzle (clues), the Miller (Meadow clues) and Pip (a lost level). In this file it appears **four times** in levels (Ice 07, Underwater 09, Clockwork 08, grand finale beat 1) plus once in the Scrapbook (postcard 6), so it stays rare. The Cave low point has none (user ruling).

### 0.5 Mizzle's progression (keep consistent across writers)

| Biome | Doodle result | Tower on the map | Posture |
|---|---|---|---|
| 1-3 | Lopsided blob, `sweat` | Speck, then floors 2-3 | Hunched, hides fully |
| 4-5 | Lopsided cube | Floor 3 + balcony, floor 4 + lantern | Peeks |
| 6-7 | Nearly square | Floor 5 straighter; floor 6, leaning on a prop | Steps out, then retreats |
| 8 | Nearly square, corners soft | Table set on top | Sits, waits |
| 9 | **Clean cube** (he stares at it, `blush`) | Nearly straight | Dances |
| 10 | n/a (the topple) | Toppled, then the chair by the wizard | Seen |

### 0.6 Clue placement rules (for the level designers)

- One clue per level at most, slots 03-09; slots 01-02 and 10 carry no extra clue (10's finale holds the biome's thread beat).
- Never two clues in one payoff; the finale's flag is set dressing unless it is the clue.
- Clue strength caps by biome (brief §2.3, rule 7): 1 = silhouette or prop only; 2 = Mizzle partly seen; 3 = Mizzle fully seen, acting. A designer may place a weaker clue than the cap, never a stronger one.
- Each list below has one beat idea per slot. ★ = a beat the brief names (keep it, its slot is movable). The other beats are optional: drop any of them and the thread still reads.
- **Reading of rule 7 (flagged)**: "density 1/2/3" is read as the strength cap above, since the task asks for one idea per slot. If narrative-director meant "number of clue levels per biome", place only the ★ beats plus that many others.

### 0.7 Reduced motion

Bubbles appear without bounce. Skits keep every pose and prop; drop CAM moves, shakes, confetti and the fly-to-brim arc (the keepsake simply appears on the brim). Never cut a pose that carries meaning.

---

## 1. MEADOW: Pip's Picnic (done)

Meadow is canon (`meadow-story.md`). No in-level skit changes here. Additive only:

- **Mizzle clues 03-09**: none. Meadow's thread is the Miller's (already written). The violet bow on the lever (05 spyglass, 10 close-ups) is set dressing, not a clue.
- **Bonus payoff**: unchanged (Picnic Puzzle). Clearing it earns **Postcard 1** in the Scrapbook (no in-level change).
- **Map change** (3 s, after the 10 payoff):
  - 0.0–1.0 The Miller pops onto the map picnic beside Pip, still floury; waves at the camera.
  - 1.0–2.0 A small violet pennant unfurls on the mill roof beside the tiny windmill's empty spot.
  - 2.0–3.0 CAM drifts to the far map edge: a speck of a crooked tower, one floor. Hold, then back.

---

## 2. CANDY: Mallow's Birthday Cake

Cast: Mallow (mascot), Madame Meringue (boss), Granny (Mallow's grandmother, brief §3.2), Mizzle (cuff and hat only, strength 1).

### Arrival (map, 4 s)
- 0.0–1.0 The wizard's cloud drifts over a floating bakery; warm steam curls from the chimney.
- 1.0–2.5 Mallow bounces out of the door holding a birthday candle, sticks to the gumdrop path, peels off (`heart`).
- 2.5–4.0 CAM pans up: on the roof, Madame Meringue squeezes the ribboned piping bag and pipes a little curl onto her own head (`smug`). The flag flaps on the bag, unnoticed.

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 Meringue squeezes the piping bag and builds herself a wobbly icing throne on the cake top.
- 1.0–2.0 She sits, shoos Granny's candles aside (`smug`). Mallow gasps (`exclaim`).
- 2.0–3.0 Hand-off: Mallow looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: the throne slumps; Meringue somersaults off it (`dizzy`).
2. 1.5–3.0 She plops upside-down on the cake top as the topper, stuck, legs kicking (`angry`).
3. 3.0–4.0 Mallow bounces onto the cake, sticks to the icing, peels off (`heart`). Keepsake pop: the cherry.
4. 4.0–5.0 [R] Granny leans in and blows out the candles; a puff of smoke rings Meringue's head.
5. 5.0–6.0 [R] **Clue**: on the bakery sill, a violet cuff sets down a tiny star, which pops (the thank-you). The flag stays on the piping bag, no hold.

### Bonus payoff (Candy Box, 5 s) → Postcard 2
- 0.0–2.0 The last sweet slots in; the box lid shuts with a ribbon.
- 2.0–4.0 Mallow sneaks one piece out of the corner, nibbles, freezes (`sweat`).
- 4.0–5.0 Mallow slots the half-eaten piece back in, pats the lid (`heart`).

### Mizzle clues (cap: strength 1)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A tall droopy hat tip pokes above a gumdrop hedge at the rim, then dips | none |
| 04 | ★ A droopy-hat silhouette in the lit bakery window, watching Granny's party | none |
| 05 | A violet cuff takes one slice of cake from the window sill ★ (the brief's second glimpse) | none |
| 06 | One extra paper plate sits on the party table, untouched | none |
| 07 | A lopsided sugar cube sits on the sill where the slice was | none |
| 08 | The mail-cloud's shadow passes over the cake | none |
| 09 | The window curtain twitches shut as Mallow waves at it | none |

### Map change (3 s)
- 0.0–1.0 The cake appears on the island with a cherry on top (and Meringue upside-down on it, sulking).
- 1.0–2.0 Bunting with flag 2 strings from the bakery sign back to the Meadow mill.
- 2.0–3.0 CAM to the horizon: the crooked tower gets a second floor, one block sticking out.

---

## 3. ICE: Pebble's Egg Escape

Cast: Pebble (mascot), Big Sniffles (boss), Lana (joins), Mizzle (footprints, ring, unseen `tear`; strength 2).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud drifts into slow snowfall over a glacier.
- 1.0–2.5 Pebble waddles out with an egg on its feet, bows to the camera, slips, stays upright (`dots`).
- 2.5–4.0 Up the mountain, Big Sniffles toots the ribboned party horn; glitter fills his nose; his face scrunches (`exclaim`). Fade before the sneeze.

### Boss intro (level 10 I, 3 s)
- 0.0–1.5 Sniffles inhales glitter from the horn, rears back (`exclaim`)...
- 1.5–2.0 ...and sneezes. A wall of snow tumbles toward Pebble's egg.
- 2.0–3.0 Hand-off: Pebble, sled ready, looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: the sled jumps the last ridge with Pebble and the egg aboard.
2. 1.5–3.0 It lands home; Pebble steps off and bows (`dots`). Keepsake pop: the snowflake.
3. 3.0–4.0 The egg wobbles; Pebble pats it (`heart`).
4. 4.0–5.0 [R] On the summit, Sniffles toots the horn again and sneezes himself up and over the horizon (`sparkle`, delighted).
5. 5.0–6.0 [R] Across the glacier, a yarn trail leads into the snowman ring: hand-off to the friend join.

### Friend join: Lana (4 s, then unlock card)
- 0.0–1.0 Lana, bundled in yarn, steps into the snowman ring; each snowman holds a cup; one chair is empty (`sweat`).
- 1.0–2.5 Her needles flash; a scarf lands on each snowman, one by one (`heart`).
- 2.5–3.5 One scarf is left. She looks at the empty chair, then turns and holds the scarf up to the wizard (`idea`).
- 3.5–4.0 The scarf wraps the wizard's cloud; Lana `note`.
- Unlock card: Lana's silhouette fills with colour; a yarn ball rolls to her feet.

### Bonus payoff (Present Puzzle, 5 s) → Postcard 3
- 0.0–2.0 The last present fits; the pile wraps itself in one big bow.
- 2.0–4.0 Pebble stands guard before it, flippers out (`dots`).
- 4.0–5.0 A snowflake lands on its beak; it does not flinch. It sneezes (`dizzy`).

### Mizzle clues (cap: strength 2)
| Slot | Beat | Emote |
|---|---|---|
| 03 | ★ A lone trail of small boot prints leads up into the mountain | none |
| 04 | A snowman at the rim has a mismatched-scrap hat band | none |
| 05 | ★ The snowman ring: each snowman holds a cup, one empty chair | none |
| 06 | A violet cuff straightens the empty chair, slips back behind a snowman | none |
| 07 | ★ First `tear`: the bubble rises from behind a snowman; nobody is seen | `tear` |
| 08 | Small hands count snowmen on fingers above a drift, stop at one | none |
| 09 | A droopy hat in a big scarf hurries off between the ice blocks | `sweat` |

### Map change (3 s, after the friend join)
- 0.0–1.0 The snowman ring appears on the glacier, every snowman scarved.
- 1.0–2.0 Flag 3 unfurls at the summit; Sniffles sneezes in the distance.
- 2.0–3.0 Horizon: the crooked tower gets a third floor.

---

## 4. UNDERWATER: Puff's Pearl

Cast: Puff (mascot), Admiral Crab (boss), Mizzle (spyglass on a far cloud; strength 2).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud hovers over a turquoise reef; bubbles rise.
- 1.0–2.5 Puff swims up to the surface, sees the cloud, inflates in surprise, bumps the surface (`exclaim`).
- 2.5–4.0 Below, Admiral Crab holds the ribboned bottle up to one eye like a spyglass, adds it to a pile of shiny things (`smug`).

### Boss intro (level 10 I, 3 s)
- 0.0–1.5 Crab unrolls the picture from the bottle, holds it upside-down, points: "treasure" (`exclaim`).
- 1.5–2.0 He snaps up Puff's pearl and adds it to the pile (`smug`).
- 2.0–3.0 Hand-off: Puff deflates sadly, looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: the pile topples; the pearl pops free into the clam. Keepsake pop: the pearl.
2. 1.5–3.0 A big bubble swallows Crab and shoots him off, tiny hat spinning (`dizzy`).
3. 3.0–4.0 The bottle bobs up from the wreck; Puff inflates, catches it in its spines (`exclaim`).
4. 4.0–5.0 [R] Puff floats to the surface, offers it up to a small cloud above.
5. 5.0–6.0 [R] **Clue**: a violet cuff snatches the bottle; the cloud zips behind a bigger one. Puff `question`.

### Bonus payoff (Treasure Chest, 5 s) → Postcard 4
- 0.0–2.0 The last coin fits; the chest creaks shut.
- 2.0–4.0 Puff sits on the lid, inflates with pride, the lid pops open again (`exclaim`).
- 4.0–5.0 Puff deflates; the lid closes; Puff `note`.

### Mizzle clues (cap: strength 2)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A parcel's violet ribbon drifts down through the water | none |
| 04 | ★ A spyglass lens glints from a distant cloud above the surface | none |
| 05 | Crab holds the picture invitation; one panel (a long table) is visible for a beat | none |
| 06 | ★ The player's light sweep (last clear's glow) finds the far cloud; a droopy hat ducks | `sweat` |
| 07 | A small grey-violet cloud trails a violet cuff that waves, then stops halfway | `dots` |
| 08 | The far cloud edges a little closer, then backs off | `blush` |
| 09 | At the rim, a violet cuff points the spyglass at the bottle in Crab's pile; it lowers | `tear` |

### Map change (3 s)
- 0.0–1.0 The reef lamp lights up the water.
- 1.0–2.0 Flag 4 bobs on a buoy.
- 2.0–3.0 Horizon: the tower sprouts a small balcony with a spyglass on it.

---

## 5. LAVA: Cinder's Snack (the Rosetta)

Cast: Cinder (mascot), Smolder (boss), the Miller (cameo, see Concerns), Boulder (joins), Mizzle (parcels; strength 3).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud drifts over a red-dusk volcano; ash flakes.
- 1.0–2.5 Cinder holds a marshmallow on a stick over a vent; it drops into the crust and sinks out of reach (`angry`, sparks).
- 2.5–4.0 At the crater, Smolder pushes away a ribboned box of bath bombs with one claw, nose up (`angry`).

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 Smolder kicks a bath bomb into the lava; it fizzes pink foam (`smug`).
- 1.0–2.0 He puffs smoke over the board edge, arms crossed.
- 2.0–3.0 Hand-off: Cinder huffs sparks, looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: a geyser launches the whole bath bomb box; it lands in the crater pool with Smolder.
2. 1.5–3.0 Foam everywhere. Smolder sputters up, bubbles on his horns (`angry`).
3. 3.0–4.0 He sinks back in to the chin, eyes half closed... catches the camera looking, sits up stiffly (`gloom`). Keepsake pop: the ember.
4. 4.0–5.0 [R] Cinder grins (`sparkle`). The flag 5 ribbon hangs over the crater rim as a towel.
5. 5.0–6.0 [R] Cinder points at its sunken marshmallow, sulks (`angry`): hand-off to the friend join.

**Departure from the brief (flagged)**: the brief has Cinder eat the marshmallow in the finale. It moves into Boulder's join skit so her "frees Cinder's snack" beat has its payoff.

### Friend join: Boulder (4 s, then unlock card)
- 0.0–1.0 Boulder trots in, hard-hat lamp on, mallet over her shoulder (`exclaim`).
- 1.0–2.0 One big swing: the crust cracks open, and so does the rock beside it (`sweat`).
- 2.0–3.0 She pats the extra crack shut; the marshmallow bobs up, toasted. Cinder eats it (`heart`).
- 3.0–4.0 Boulder holds the mallet up to the wizard (`sparkle`).
- Unlock card: Boulder's silhouette fills with colour; her lamp switches on.

### Bonus payoff (Forge Puzzle, 5 s) → Postcard 5
- 0.0–2.0 The last ingot fits; the forge glows.
- 2.0–4.0 Cinder holds a new marshmallow stick to the forge door; it chars instantly (`dizzy`).
- 4.0–5.0 Cinder eats it anyway (`note`).

### Mizzle clues (cap: strength 3)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A trail of violet ribbon scraps along the ash path | none |
| 04 | The mail-cloud struggles past, satchel bulging | `sweat` |
| 05 | A droopy hat behind a basalt column; the wand doodles a lopsided cube, which falls | `sweat` |
| 06 | Smolder's box shows a star stamp; a violet cuff peeks to check it arrived | `dots` |
| 07 | ★ Mizzle walks away along the ridge under a towering stack of parcels | none |
| 08 | ★ **The Rosetta**: the Miller at the rim takes flag 5, waves it, taps the leaf card and the star card in his pocket, points at the wizard | Miller `exclaim` |
| 09 | Mizzle on the far ridge sees the Miller pointing; pushes his glasses up, hurries on | `blush` |

The Rosetta's 1.5 s budget: 0.0–0.5 flag wave; 0.5–1.0 pocket tap, leaf card + star card; 1.0–1.5 point at the wizard. The wizard does not respond (rule 8).

### Map change (3 s, after the friend join)
- 0.0–1.0 Fire vents turn into gentle steam vents.
- 1.0–2.0 A small pennant of its own pops up on the Meadow mill; flag 5 hangs as a towel on the crater.
- 2.0–3.0 Horizon: the tower gets a fourth floor and a lantern.

---

## 6. FOREST: Chip's Bridge (first contact)

Cast: Chip (mascot), Grandpa Oak (boss), Mizzle (strength 3).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud floats into green late light; fireflies blink on.
- 1.0–2.5 Chip gnaws a branch bridge clean through; it drops into the stream (`sweat`), then (`idea`).
- 2.5–4.0 Up the bank, the ribboned wind chimes jingle on Grandpa Oak; one eye snaps open (`angry`).

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 The chimes tinkle in the wind; Oak yawns, snaps awake (`angry`).
- 1.0–2.0 He shakes his branches; acorns rain on the stream.
- 2.0–3.0 Hand-off: Chip, holding a plank, looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: Oak gives a huge yawn and stretches across the stream (`sleep`).
2. 1.5–3.0 He bursts into pink blossom and settles as the bridge. Keepsake pop: the acorn.
3. 3.0–4.0 Chip scampers across, gnaws the handrail, stops himself (`sweat`).
4. 4.0–5.0 [R] The chimes hang in the blossoms, ringing softly; Oak snores (`sleep`).
5. 5.0–6.0 [R] The tiny crooked block sits on the bridge post. CAM holds on it 0.5 s (it was given in 09, so it is a callback, not a new clue).

### Bonus payoff (Berry Basket, 5 s) → Postcard 6
- 0.0–2.0 The last berry tops the basket.
- 2.0–4.0 Chip starts gnawing the basket handle (`idea`).
- 4.0–5.0 The handle drops; Chip holds both halves up proudly (`sparkle`).

### Mizzle clues (cap: strength 3)
| Slot | Beat | Emote |
|---|---|---|
| 03 | Fireflies gather around a droopy hat in the dark; it shoos them, they stay | `blush` |
| 04 | Mizzle sits on a far log, doodles a block; nearly square | `idea` |
| 05 | He tiptoes past Oak to retie a chime that clinks | `sweat` |
| 06 | He picks up one of Chip's dropped planks and leans it neatly by the bridge | `dots` |
| 07 | He watches Chip from behind a trunk; counts fingers to two, smiles | `dots` |
| 08 | A small crooked block appears on the stream bank; Mizzle peeks at it, takes it back | `sweat` |
| 09 | ★ **First contact**: last clear shakes an acorn loose; the wand glint and a violet cuff reach it together | `blush` |

First contact (1.5 s): 0.0–0.5 acorn drops; the glint and the cuff touch it. 0.5–1.0 Mizzle sees the wizard, freezes (`blush`). 1.0–1.5 he flees; where he stood sits a tiny crooked block. The glint is the player's last clear (rule 8).

### Map change (3 s)
- 0.0–1.0 Blossom covers the bridge; flag 6 rings as chimes.
- 1.0–2.0 The tiny crooked block pops onto a corner of the hat's map icon (the wizard keeps it).
- 2.0–3.0 Horizon: floor five, noticeably straighter.

---

## 7. CAVE: Nugget's Light (the low point, softer)

Cast: Nugget (mascot), Geode (boss), Glim (joins), Mizzle (strength 3).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud dips into a dark cave mouth; crystals glint.
- 1.0–2.5 Nugget's headlamp flickers; it walks into a stalagmite, rubs its nose (`question`).
- 2.5–4.0 Deep inside, the ribboned lantern chain blinks like a disco; a sleeping rock golem's eyelid twitches (`angry`).

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 The lantern chain flashes in Geode's face; he sits up, squinting (`angry`).
- 1.0–2.0 He stamps; rocks tumble from the ceiling.
- 2.0–3.0 Hand-off: Nugget adjusts its headlamp, looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: Geode cracks down the middle (`dizzy`).
2. 1.5–3.0 Out hatches a vain crystal bird; it preens and lights the whole cave (`smug`). Keepsake pop: the gem.
3. 3.0–4.0 Nugget squints in the light, sneezes at the dust (`dizzy`).
4. 4.0–5.0 [R] The bird sees its reflection is dusty, flaps off offended (`angry`).
5. 5.0–6.0 [R] The new light falls on the cave wall: a chalk blueprint. Something upside-down above it unrolls its ears: hand-off to the friend join.

### Friend join: Glim (4 s, then unlock card)
- 0.0–1.0 Glim drops from the ceiling to hang upside-down by the blueprint, scowls at the mess (`angry`).
- 1.0–2.5 She wipes a crooked line off with her wing, redraws it, and the route out glows on the wall (`idea`).
- 2.5–3.5 Nugget follows the line, bumps into nothing for once (`sparkle`).
- 3.5–4.0 Glim salutes the wizard with the rolled blueprint (`exclaim`).
- Unlock card: Glim's silhouette fills with colour; the blueprint unrolls behind her ear.

### Bonus payoff (Treasure Map, 5 s) → Postcard 7
- 0.0–2.0 The last map piece fits; an X glows.
- 2.0–4.0 Nugget digs at the X; dirt flies (`idea`).
- 4.0–5.0 Nugget pops up wearing the treasure, a crown, over its headlamp (`sparkle`).

### Mizzle clues (cap: strength 3)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A second, droopier shadow walks behind Nugget's shadow on the wall, then stops | none |
| 04 | Mizzle hangs a spare lantern on a hook at the rim, then hides it behind his back | `sweat` |
| 05 | ★ **Shadow puppets**: crystal light casts Mizzle's hands as a little party of friends on the wall | `dots` |
| 06 | He builds a small crooked tower of crystal chips by his lantern | `idea` |
| 07 | A bat flaps past his tower; he steadies it with both hands | `sweat` |
| 08 | He adds a crooked top block and admires it | `dots` |
| 09 | ★ **The low point (softer)**: the bat gag in the payoff makes the group laugh; he thinks it is at him; his tower wobbles; he catches it; sheepish sigh | `dots` |

The low point (1.5 s, inside the 09 payoff, which ends on the bats flapping off and everyone laughing):
- 0.0–0.5 At the rim, Mizzle turns to the laughter; his crooked tower wobbles.
- 0.5–1.0 He catches it with both hands, hugs it still. Shoulders drop; hat tip droops further.
- 1.0–1.5 Sheepish sigh: `dots`. He carries the tower off into the dark, cuff to his eye in one small sleeve wipe.

No `tear` here (user ruling: softer). The sleeve wipe keeps the brief's cuff image; drop it too if it still reads as too sad.

### Map change (3 s, after the friend join)
- 0.0–1.0 The crystals light up across the island.
- 1.0–2.0 Flag 7 ties itself around a stalagmite.
- 2.0–3.0 Horizon: the tower leans but stands, propped on a stick, with one new floor.

**Departure from the brief (flagged)**: the brief's map change has the tower as "a leaning heap (he has to start again)". The softer ruling means he caught it, so it leans and is propped instead.

---

## 8. CLOCKWORK: Tock's Midnight

Cast: Tock (mascot), Cuckoo Prime (boss), Mizzle (strength 2).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud drifts into a sepia, lamp-lit wind-up town; the clock face is the moon.
- 1.0–2.0 Parcel drop: the mail-cloud drops a ribboned box into the clock tower's door (`gift`), puffs off.
- 2.0–4.0 Tock waddles out, winds down mid-step, freezes (`sweat`). A hand from off-screen (a townsperson's key) winds it up again.

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 Cuckoo Prime pops out, stuffs the ribboned clock-stopper into his own gears (`smug`).
- 1.0–2.0 The hands jam at one minute to twelve; the town's gears start to run backwards.
- 2.0–3.0 Hand-off: Tock looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: the clock-stopper pops out of the gears; the hands click to twelve.
2. 1.5–3.0 The bell strikes; Cuckoo is sprung out on his spring, boinging, still ticking smugly (`smug`). Keepsake pop: the gear.
3. 3.0–4.0 Tock gets a full wind and dances (`note`).
4. 4.0–5.0 [R] The clock face swings open: inside, a table set for twelve, every chair empty but one cup missing.
5. 5.0–6.0 [R] The wand glint (the player's last clear) sets one cup in the gap. The cups ring softly.

The open table is the biome's thread beat in the finale (counts as its one clue; the flag stays on the cuckoo door, no hold).

### Bonus payoff (Music Box, 5 s) → Postcard 8
- 0.0–2.0 The last cylinder pin fits; the lid opens and a tiny dancer spins.
- 2.0–4.0 Tock dances along, winds down halfway through a twirl (`sweat`).
- 4.0–5.0 The music box's key winds Tock up; both spin (`note`).

### Mizzle clues (cap: strength 2)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A window across the square shows a long table with twelve chairs | none |
| 04 | ★ The mail-cloud delivers the parcel (alternative slot to the arrival) | `gift` |
| 05 | ★ In the window, one figure sits at the long table, waiting; the clock tries to strike | none |
| 06 | ★ Each time the clock tries to strike, a violet cuff straightens a chair | none |
| 07 | The figure counts fingers to twelve, then to one | `dots` |
| 08 | The window figure's hat droops as the hands jam again | `tear` |
| 09 | The figure pushes his glasses up and sets out one more cup, just in case | `dots` |

### Map change (3 s)
- 0.0–1.0 The clock chimes over the island; the hands move again.
- 1.0–2.0 Flag 8 hangs on the cuckoo door.
- 2.0–3.0 Horizon: on top of the tower, a small table appears, set.

---

## 9. NEON: Glitch's Gig (the first reply)

Cast: Glitch (mascot), DJ Mirrorball (boss), Mizzle (strength 3).

### Arrival (map, 4 s)
- 0.0–1.0 The cloud floats into a city of lit signs; pixel rain; everything pulses.
- 1.0–2.0 Parcel drop: the mail-cloud drops a ribboned mixtape onto the stage (`gift`).
- 2.0–4.0 DJ Mirrorball slots it in, spins, and the crowd starts dancing; Glitch flickers on the side of the stage, unseen (`question`).

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 Mirrorball hits the loop button; the same beat stutters over and over (`smug`).
- 1.0–2.0 The crowd dances, can't stop, sweats.
- 2.0–3.0 Hand-off: Glitch looks up at the wizard; glint; first piece.

### Finale payoff (6 s; [R] = beats 4-5)
1. 0.0–1.5 Last clear: Mirrorball spins too fast, wobbles (`dizzy`).
2. 1.5–3.0 He shatters into confetti; his face stays on one mirror tile, sulking (`gloom`). Keepsake pop: the neon star.
3. 3.0–4.0 Glitch takes centre stage, flickers into a pose; the crowd roars (`sparkle`).
4. 4.0–5.0 [R] The mixtape plays properly, once, all the way through; the crowd sways (`note`).
5. 5.0–6.0 [R] On a speaker at the rim sits a glow-stick hat, left behind. No owner in shot (callback, not a new clue).

### Bonus payoff (Arcade High Score, 5 s) → Postcard 9
- 0.0–2.0 The last block lands; the cabinet flashes a high score (pictogram stars, no digits).
- 2.0–4.0 Glitch poses in front of it, flickers.
- 4.0–5.0 The cabinet glitches, shows Glitch's own face; Glitch `sparkle`.

### Mizzle clues (cap: strength 3)
| Slot | Beat | Emote |
|---|---|---|
| 03 | A droopy hat tip with a glow-stick taped on bobs at the back of the crowd | none |
| 04 | Mizzle copies a dance move from the rim, a beat late | `sweat` |
| 05 | He doodles a block in the air to the beat: a **clean cube**. He stares at it | `blush` |
| 06 | A crowd member bumps him; he bows an apology, keeps dancing | `dots` |
| 07 | He holds the star-stamped `invite` card out at the crowd, then tucks it away | `invite` |
| 08 | The mail-cloud dances above him | `note` (mail-cloud: `gift`) |
| 09 | ★ **The dance and the first reply**: a circle forms round him; he flees, blushing; the last clear's glint sends a star after him | `blush` |

First reply (1.5 s): 0.0–0.5 the crowd forms a circle; Mizzle alone in it, glow-stick hat. 0.5–1.0 he flees (`blush`). 1.0–1.5 the player's last-clear sparkle flies off the wand as a star and lands in his hands as he goes. The wizard reacts with the same `sparkle` it shows on any good clear (rule 8).

### Map change (3 s)
- 0.0–1.0 The city lights up, sign by sign.
- 1.0–2.0 Flag 9 flies as a pennant on the stage.
- 2.0–3.0 Horizon: the tower stands nearly straight; a tiny star blinks at its window.

---

## 10. CELESTIAL: Comet's Bedtime (the Hat Reveal) and the grand finale

Cast: Comet (mascot), the Sleepy Moon (boss), all mascots and the nine earlier bosses (**grand finale guests only**), the three friends, the Miller, Mizzle.

### Arrival (map, 4 s)
- 0.0–1.0 The cloud rises into indigo sky; star stairs lead up.
- 1.0–2.5 Comet trots down the stairs trailing sparkles, yawns (`note`).
- 2.5–4.0 Above, the Sleepy Moon cuddles a ribboned night-light, eyeing the tallest stack in the sky (`sleep`). On the horizon behind it: Mizzle's crooked tower, almost straight.

### Boss intro (level 10 I, 3 s)
- 0.0–1.0 The Moon switches on the night-light, fluffs the clouds into a pillow.
- 1.0–2.0 It drifts toward the wizard's stack, ready to lie down on the top (`sleep`).
- 2.0–3.0 Hand-off: Comet looks up at the wizard; glint; first piece.

### Mizzle clues (cap: strength 3)
| Slot | Beat | Emote |
|---|---|---|
| 03 | Mizzle builds his tower at the rim, one clean cube at a time | `idea` |
| 04 | He watches the wizard's stack, matches his tower's height to it | `dots` |
| 05 | [GC] The grumpy cloud on the wizard's cloud spots his star-stamped card, perks up | grumpy cloud `exclaim` |
| 06 | He sets a tiny chair on his tower's top floor, straightens it | `dots` |
| 07 | He holds out the star-stamped card toward the wizard, loses his nerve, pockets it | `sweat` |
| 08 | A comet streaks by; he and Comet both look up at the same time | `blush` |
| 09 | The Moon drifts past his tower, sniffing at its height; he steadies it | `sweat` |

### Grand finale (level 10 payoff)

**Departure (flagged)**: brief §1's six steps do not fit the 6 s finale cap. Default: **14 s on first play**, tap to skip; the **core cut (6 s)** is beats marked ◆ and is what replays show. If narrative-director keeps the 6 s cap for first play too, ship the core cut only.

1. ◆ 0.0–2.0 **The topple**: last clear. The Moon gives an enormous yawn; the wind of it tips Mizzle's crooked tower into a soft heap with him sitting on top. A small drizzle cloud over his head; `tear`.
2. 2.0–3.5 **The reveal**: the wizard's last clear seats the 10th keepsake (the moon). CAM pulls back: the stack is the wizard's hat. The mascots pop out of the hat one by one (`sparkle`). The Moon curls up on the brim and sleeps (`sleep`).
3. 3.5–6.0 **The flags**: the nine earlier bosses stand on the brim, each holding their gadget. Each unrolls its flag; the Miller's goes up first. The flags join into one bunting; Boulder's mallet knocks the last knot tight (`sweat`, then `sparkle`). The bunting runs above the wizard: ten panels.
4. ◆ 6.0–8.0 **The reading**: CAM slides along the ten panels (see §12). The bosses look at their gadgets, then at Mizzle: `question`, `exclaim`, sheepish `sweat` (spread across the nine, never more than three bubbles on screen at once).
5. ◆ 8.0–9.5 **The wave**: the Miller lifts his paw and waves, full and slow. Mizzle freezes: `dots`, then `blush`.
6. ◆ 9.5–11.0 **The chair**: the wand glints (the player's final clear, held over from beat 2); one block flies to the heap and becomes a chair next to the wizard. Mizzle climbs down and sits.
7. 11.0–12.5 **The clink**: Pip and Mallow pass him a cup; Lana wraps him in a scarf; everyone raises a cup. Clink. Mizzle `heart` (his first).
8. ◆ 12.5–14.0 **The star**: [GC] the grumpy cloud turns pastel and settles beside him (`heart`). His hat-tip star lights, lifts off and flies to the tip of the wizard's hat. Dawn breaks: the first sunrise of the campaign.

Core cut (6 s): beat 1 (1.5 s) → beat 4 (1.5 s) → beat 5 (1.0 s) → beat 6 (1.0 s) → beat 8 (1.0 s).

Reduced motion: no pull-back or bunting slide; cut between held poses; the star appears on the hat tip.

### Bonus payoff (Hat Box, 5 s) → Postcard 10
- 0.0–2.0 The last piece fits; the hat box lid closes.
- 2.0–4.0 Comet curls up on the lid, trailing sparkles (`sleep`).
- 4.0–5.0 The lid lifts a little; a sparkle peeks out (`note`).

### Map change (3 s; the last main-campaign change)
- 0.0–1.0 CAM pulls up: the whole map is the hat's brim.
- 1.0–2.0 The full bunting runs through every island, Meadow to Celestial.
- 2.0–3.0 Mizzle's chair sits by the wizard's cloud, Mizzle in it; [GC] the grumpy cloud is pastel; the hat tip's star glints. Then: a tiny violet mail-cloud sets off from the edge of the map (hand-off to Drizzle Rock).

---

## 11. Side islands

Self-contained gag islands (brief §4): **one Mizzle wink each** (a cuff or a flag in the backdrop, ≤ 1.5 s, one level only), no plot. Default 5 levels + 1 bonus; slot 05 is the finale. Keepsake: a cloud charm. No friend joins; friends cameo only as playable characters. No postcard.

### 11.1 Tumble Fair (unlocks after Candy)

- **Arrival (4 s)**: 0.0–1.5 the cloud drifts over striped tents and a turning ferris wheel. 1.5–3.0 Bounce bounces off a tent roof, too high, waves its trunk on the way down (`exclaim`). 3.0–4.0 Baron Balloon puffs himself bigger over the fair (`smug`).
- **Boss intro (05 I, 3 s)**: 0.0–1.5 Baron inflates until he blots out the ferris wheel. 1.5–2.0 he blows the ring-toss rings across the board (`smug`). 2.0–3.0 hand-off: Bounce looks up; glint; first piece.
- **Finale payoff (6 s; [R] 4-5)**: 1. 0.0–1.5 last clear: a ring lands on Baron's valve; he squeaks. 2. 1.5–3.0 he deflates in loops around the fair (`dizzy`). 3. 3.0–4.0 he lands flat and puffs into a bouncy castle (`gloom`). 4. [R] 4.0–5.0 Bounce bounces on him (`sparkle`). 5. [R] 5.0–6.0 the cloud charm: a balloon ties itself to the wizard's cloud (`heart`).
- **Bonus payoff (5 s)**: 0.0–2.0 the last prize fits the prize shelf. 2.0–4.0 Bounce reaches for the giant teddy, the shelf tips (`sweat`). 4.0–5.0 the teddy lands on Bounce, hugging it (`heart`).
- **Wink (any one slot 02-04)**: a violet cuff hands a ticket to the ticket booth; the booth's flag is violet.
- **Map change (3 s)**: 0.0–1.5 the ferris wheel lights. 1.5–3.0 a bouncy castle appears beside it.

### 11.2 Dune Bazaar (unlocks after Lava)

- **Arrival (4 s)**: 0.0–1.5 the cloud drifts into hot gold light; a mirage shimmers. 1.5–3.0 Tuft pops up from a hole, then another, then another (`question`). 3.0–4.0 Madame Sphinx lounges on an awning, holding up a picture riddle (`smug`).
- **Boss intro (05 I, 3 s)**: 0.0–1.5 Sphinx flips a riddle card: a picture puzzle (no words; e.g. cup + sand = hourglass). 1.5–2.0 Tuft scratches its head (`question`). 2.0–3.0 hand-off: Tuft looks up; glint; first piece.
- **Finale payoff (6 s; [R] 4-5)**: 1. 0.0–1.5 last clear: Sphinx flips her last card, stares at it (`question`). 2. 1.5–3.0 she solves it herself (`idea`), purrs. 3. 3.0–4.0 she stretches across the warm awning (`sleep`). 4. [R] 4.0–5.0 Tuft pops up and steals her riddle cards (`sparkle`). 5. [R] 5.0–6.0 the cloud charm: a lantern hangs from the wizard's cloud (`heart`).
- **Bonus payoff (5 s)**: 0.0–2.0 the last rug unrolls into place. 2.0–4.0 Tuft pops up through the middle of it (`exclaim`). 4.0–5.0 the rug sags; Tuft sinks back, waving.
- **Wink (any one slot 02-04)**: among the market awnings, one has a violet ribbon flag; a droopy hat haggles at a cup stall.
- **Map change (3 s)**: 0.0–1.5 the market lanterns light. 1.5–3.0 Sphinx sleeps on the tallest awning.

### 11.3 Boo Hollow (unlocks after Cave)

Never scary: purple dusk, candles, round shapes, every "boo" ends in a giggle.

- **Arrival (4 s)**: 0.0–1.5 the cloud drifts over smiling pumpkins. 1.5–3.0 Wisp trips over its too-big sheet, pops back up (`sweat`). 3.0–4.0 Sir Sheet-a-lot floats out of the haunted house, arms raised, looks around: nobody watching (`gloom`).
- **Boss intro (05 I, 3 s)**: 0.0–1.5 Sir Sheet-a-lot flickers the candles off and on (`smug`). 1.5–2.0 a pumpkin rolls across the board edge. 2.0–3.0 hand-off: Wisp looks up; glint; first piece.
- **Finale payoff (6 s; [R] 4-5)**: 1. 0.0–1.5 last clear: Sir Sheet-a-lot swoops to scare Wisp (`smug`). 2. 1.5–3.0 Wisp lifts its sheet and goes "boo" (a pose: arms up, mouth wide). 3. 3.0–4.0 Sir Sheet-a-lot shrieks silently and hides in a pumpkin (`exclaim`). 4. [R] 4.0–5.0 his eyes peek out of the pumpkin's mouth; Wisp giggles (`note`). 5. [R] 5.0–6.0 the cloud charm: a small bat clings to the wizard's cloud (`heart`).
- **Bonus payoff (5 s)**: 0.0–2.0 the last candy fits the bucket. 2.0–4.0 Wisp hides inside the bucket under the candy. 4.0–5.0 it pops out, sheet covered in wrappers (`sparkle`).
- **Wink (any one slot 02-04)**: a jack-o'-lantern at the rim is carved crooked; a violet cuff sets a tiny candle in it.
- **Map change (3 s)**: 0.0–1.5 the pumpkins light up, grinning. 1.5–3.0 one pumpkin has two eyes peeking out of it.

### 11.4 Drizzle Rock: the epilogue (unlocks after Celestial)

The only side island with story weight (beat 11). After the grand finale the thread is resolved, so there are **no clues**: Mizzle is openly the host, and his scenes are the island's per-level backdrop.

Guests (rule 10 and the user ruling: bosses are grand-finale guests only, mascots stay home): the wizard, Lana, Boulder, Glim, the Miller (the stated exception), Mizzle, Crumb, the mail-cloud, [GC] the grumpy cloud. The mascots reply **by mail**: the mail-cloud brings a small gift from each biome mascot to set on the empty chairs (see Concerns: option to seat the mascots instead).

- **Arrival (4 s)**: 0.0–1.0 the violet mail-cloud from the last map change drops a parcel on the wizard's cloud (`gift`); it opens into a star-stamped card (`invite`). 1.0–2.5 a lone grey-violet rock rises on the map: a leaning half-tower, a long table set for twelve, dusty. 2.5–4.0 Mizzle stands at the door, glasses push, waves (small, then bigger) (`blush`).
- **Per-level host beats (backdrop, optional, one per slot)**: 01 Mizzle dusts the table, sneezes (`dots`). 02 he straightens a chair, and this time someone sits in it (Lana) (`blush`). 03 he doodles a clean cube and hands it to Glim, who measures it and approves (`sparkle`). 04 Boulder knocks the half-tower straight with one tap (`sweat`, then `note`).
- **Boss intro (05 I, 3 s)**: 0.0–1.5 Crumb the clanking butler whisks the plates off the table and lays them again, faster and faster (`sweat`). 1.5–2.0 a stack of cups wobbles onto the board edge. 2.0–3.0 hand-off: the mail-cloud looks up at the wizard; glint; first piece.
- **Finale payoff, the party (6 s; [R] 4-5)**: 1. 0.0–1.5 last clear: Crumb sets the last cup, reaches for the plates again; Mizzle lays a hand on its arm (`dots`). 2. 1.5–3.0 Crumb looks at the table: every place set. It sits down at last (`question`, then `heart`). 3. 3.0–4.0 the guests take the chairs: the wizard's cloud, Lana, Boulder, Glim, the Miller. The mail-cloud sets a mascot's gift on each remaining chair (a cherry, a scarf, a pearl, a marshmallow...). 4. [R] 4.0–5.0 Mizzle stands at the head of the table, cup up. Clink. Mizzle `heart`. 5. [R] 5.0–6.0 the cloud charm: a violet cup lands on the wizard's cloud; the light warms from dusk violet to gold.
- **Bonus payoff (5 s)**: 0.0–2.0 the last slice fits the party cake. 2.0–4.0 Mizzle cuts it; the cake leans like his old tower (`sweat`). 4.0–5.0 Boulder props it with the mallet; everyone laughs (`note`).
- **Map change (3 s, the last in the game)**: 0.0–1.0 Drizzle Rock's half-tower stands straight. 1.0–2.0 the table on it fills with tiny guests. 2.0–3.0 a violet flag joins the end of the bunting, linking Drizzle Rock to the rest of the map.
- **Epilogue end card (wordless, 4 s, tap to close)**: the whole map at warm dusk; on the wizard's hat brim, two small chairs side by side; the hat-tip star blinks once.

---

## 12. The ten flag panels (the picture invitation)

Read left to right in the grand finale: "**Me / I built a tower / for a party / with a long table / for everyone / with cake / and music / tonight / dancing / and you.**" Pictograms only, no letters or digits. **Proposal for art-director and narrative-director** (the brief only fixes the overall read: a small figure, a tower, a long table, everyone).

| Flag | Boss | Panel pictogram |
|---|---|---|
| 1 | The Miller | A small figure in a droopy hat |
| 2 | Madame Meringue | A crooked tower of blocks |
| 3 | Big Sniffles | A party hat and a horn (a party) |
| 4 | Admiral Crab | A long table |
| 5 | Smolder | Twelve chairs with simple guest shapes |
| 6 | Grandpa Oak | A cake with candles |
| 7 | Geode | Musical notes and a lantern chain |
| 8 | Cuckoo Prime | A moon over a clock at twelve |
| 9 | DJ Mirrorball | A circle of dancing figures |
| 10 | The Sleepy Moon | A small round hat with a beard below it (the cloud wizard) |

---

## 13. The Scrapbook

A wordless gallery on the island map (brief §6). Three icon tabs; no visible text inside (rule 1).

### 13.1 Contents

| Tab | Items | Fills when |
|---|---|---|
| **Flags** | The 10 panels of §12, in a row | Each biome finale is won; empty panels show only the ribbon |
| **Keepsakes** | 10 keepsakes (windmill, cherry, snowflake, pearl, ember, acorn, gem, gear, neon star, moon) + 4 cloud charms (balloon, lantern, bat, violet cup) | Each finale (main or side island) |
| **Postcards** | The 10 Mizzle memory postcards (§13.2) | Each main-biome bonus level is cleared |

Missing items show as a dashed outline of the same shape. Missing all postcards still leaves the story whole (brief §2.4).

### 13.2 Memory postcards (3 s each, in story order)

Each one: a still card that animates for 3 s when tapped. Soft dusk palette, Mizzle alone unless stated. Earned in order: postcard N from biome N's bonus.

| # | Earned in | Vignette (3 s) | Emote |
|---|---|---|---|
| 1 | Meadow bonus | 0.0–1.0 Rain on a grey rock. 1.0–2.0 Mizzle finds one block in a puddle. 2.0–3.0 He holds it up like treasure | `idea` |
| 2 | Candy bonus | 0.0–1.5 He stacks blocks; they lean. 1.5–3.0 He stands back from a small crooked tower, pleased | `idea` |
| 3 | Ice bonus | 0.0–1.5 He sets a long table, chair by chair. 1.5–3.0 He counts on his fingers: twelve | `dots` |
| 4 | Underwater bonus | 0.0–1.5 He sends tiny mail-clouds off with invitations. 1.5–3.0 The wind scatters them over the horizon | `sweat` |
| 5 | Lava bonus | 0.0–1.5 He sits at the head of the set table, chin on hands. 1.5–3.0 The candles burn down | `dots` |
| 6 | Forest bonus | 0.0–1.5 A gust (the first prank, from far off) blows his candles out. 1.5–3.0 He sits in the dark, hat drooping | `tear` |
| 7 | Cave bonus | 0.0–1.5 He draws ten pictures on one long sheet. 1.5–3.0 He holds it up: the full invitation | `idea` |
| 8 | Clockwork bonus | 0.0–1.5 He cuts the sheet into ten flags. 1.5–3.0 He ties each to a ribbon | `dots` |
| 9 | Neon bonus | 0.0–1.5 He wraps ten parcels. 1.5–3.0 He ties a flag to each, stacks them high | `gift` |
| 10 | Celestial bonus | 0.0–1.5 He practises a cast in front of a mirror; the block comes out lopsided. 1.5–3.0 Through the window, far off, he spots the cloud wizard's drizzle | `blush` |

Postcard 6 adds a fifth `tear` (Scrapbook only); it is a Mizzle lonely beat, so it is within rule 6.

### 13.3 String keys (Scrapbook)

The Scrapbook shows no visible text. These keys are **accessibility names only** (screen reader / AccessKit) and the one menu entry. Values are written by the ux-designer and localisation, not here.

| Key | Use | Visible? |
|---|---|---|
| `menu.map.scrapbook` | The map button that opens the Scrapbook (icon: a little book with a violet ribbon) | Icon only by default; text label is a ux-designer call |
| `a11y.scrapbook.title` | Screen name | No |
| `a11y.scrapbook.tab.flags` | Flags tab | No |
| `a11y.scrapbook.tab.keepsakes` | Keepsakes tab | No |
| `a11y.scrapbook.tab.postcards` | Postcards tab | No |
| `a11y.scrapbook.slot.locked` | Any empty slot | No |
| `a11y.scrapbook.flag.{flag_index}` | Each panel, `{flag_index}` = 1-10 | No |
| `a11y.scrapbook.keepsake.{keepsake_id}` | Each keepsake or charm | No |
| `a11y.scrapbook.postcard.{postcard_index}` | Each postcard, `{postcard_index}` = 1-10 | No |
| `a11y.scrapbook.back` | Back button | No |
| `a11y.unlock_card.{friend_id}` | Friend unlock card (`lana`, `boulder`, `glim`) | No |

---

## 14. Hand-off notes

- **Level designers**: place one clue per level from the lists above (respect the cap and the ★ beats). Slot numbers for ★ beats are suggestions; move them with the level's own payoff.
- **narrative-director**: rule on the flagged departures (Concerns below) and the emote `Who` extension (§0.4).
- **art-director**: Mizzle progression (§0.5), the ten panels (§12), the Scrapbook icons, the `gift` icon.
- **ux-designer**: arrival and map-change channels (§0.2), Scrapbook layout and the `menu.map.scrapbook` label decision.

### Concerns (flagged, not resolved)

1. **Miller's Lava Rosetta vs the user ruling** "nine bosses appear as finale-skit guests only": kept the Rosetta because brief rule 10 names the Miller as the exception; if the ruling covers him too, the Rosetta needs a new carrier (suggest: the mail-cloud drops a star card at Cinder's feet).
2. **Celestial boss-rush twist** (brief §3.10, "the nine rivals throw in old tricks"): under the ruling, show only their gadgets falling in, with the bosses never on screen before the finale.
3. **Grand finale length**: 14 s first play exceeds the 6 s finale cap; the 6 s core cut is ready.
4. **`gift` emote and the violet-star `invite` variant** are not yet in `emote-bubbles.md`; the `Who` column there needs the §0.4 extension (bosses, mascots, friends using `smug`, `angry`, `dots`, `gloom`).
5. **Drizzle Rock guests**: mascots reply by mail (rule 10). If the user wants the mascots seated at the epilogue table, it needs a second rule-10 exception.
