# Candy Layout Sketches: Mallow's Birthday Cake (levels 01–10 + bonus + hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10). Sketch only; `design/levels/candy.md` is written after the user answers the open creative questions.
> **Sources**: `production/levels/campaign/biome-stories.md` §2 (story, 10-beat arc), `production/levels/campaign/biome-bible.md` §2.2 (quirk "colour matters"), `design/gdd/mechanics-module.md` (atom IDs, F1 budget), `design/gdd/level-specific-mechanics.md` M5/M7 (colour pop, mono layer), `design/levels/meadow.md` (template), `docs/architecture/implementation-plan.md` §3 (extension recipes).
> **Every number, name and beat is a tunable default.** Where the bible (§2.2, older draft: "Gumdrop" mascot, festival story) and the stories file disagree, this file follows `biome-stories.md` (Mallow, Granny's cake, Madame Meringue) and the user's Candy decisions of round 5/6.

## How to read this

**User decisions this file is built on (binding)**
- **Colour**: a **bonus** first (01–04), then a **rule / goal** (05 on).
- **Sticky, all four**: syrup slows pieces (03), gumdrops stick where they land (02), jelly bounces (04), touching same-colour pieces glue into one big piece (04 on).
- **Mallow** is a **mood swing**: helpful while the tower is tidy, a sugar-rush prankster when it is messy.
- **Finale**: the whole stack **bakes into a giant cake mid-level** and the rules change; Madame Meringue stays a smug rival.
- **Blockers, all four**: frosting tiles, licorice locks, chocolate spread, countdown bonbons.
- **Specials, all four**: rainbow sprinkle pieces, jelly pieces, earned candy bombs, moody gummies.
- **Bonus Candy Box**: against the clock.
- **Failing** (every Candy level): the cake slumps into a gooey heap and Mallow faceplants into the icing.

**Biome rules for Candy**
- **Quirk: "Colour matters", in two steps.** 01–04: the Mono layer (CL07) is on, so a one-colour layer gives a free bonus blast ("sugar sparkle"); nothing is lost if you ignore colour. 05–10: colour decides stars (05), goals (06), clears (07–10) and the finale.
- **Drift zig-zags.** 01 is classic in candy clothes; 03 and 04 drift (syrup glide, jelly settle); 05–06 are no-fail breathers; 07 is the big step (colour pop); 08 snaps back to a short, tight survive; 09 is the wildest; 10 changes the rules mid-level.
- **Block weather: gumdrop hail.** Normal pieces fall as usual; from 02 on, single gumdrop cubes also hail down between pieces in some levels (forecast one lock ahead by a shadow).
- **Mallow, mood swing (WO08 driven by WO01 tidiness, F10).** Three bands, the same in every level; only the *prank card* changes per level:
  - **Happy** (tidy ≥ 0.9): helper. Mallow points at a good cell. In 01–03 she also has **one catch per level** (WO11, as Pip's catch): she sticks the bad piece to her ears and hands it back at the spawn.
  - **Neutral** (≥ 0.7): watcher. Licks a lollipop, reacts.
  - **Grumpy** (< 0.7): **sugar-rush prankster** (WO07). She gobbles a sweet, vibrates, and plays the level's prank card, always telegraphed 1 s ahead. In 01–02 the prank is cosmetic only (she bounces off the screen edge and back), so the tutorials never punish.
- **Madame Meringue** is seen from 05 on: on the bakery shelf in the backdrop, looking down her nose at the cake. She causes the events of 09 and is the boss of 10. She never helps.
- **Failure gag (all levels)**: the cake slumps into a gooey heap; Mallow, mid-hop, faceplants into the icing and comes up with a frosting beard. From 05 on Madame Meringue gives a slow, smug clap.
- **Rubber duck**: a gummy duck under the island in 01 and 02 (SE05, one low snap angle; tap to collect; no stars).
- **One island per level, shaped by the story**: sugar-cube tin, cake-tin cupcake, lollipop lane, jelly bridge, cake stand, cake top, gummy jar, candy-pile counter, chocolate fountain plaza, Granny's oven table; bonus: a heart-shaped chocolate box.

**Colour key (flag for game-designer + godot-specialist, not a user question).** Colour rules read `colour_key` = the piece's **family** (level-specific-mechanics A3). Candy needs several colours *within* the Standard family, or every T, L and S is the same flavour. Default proposed here: a level knob **`colour_source: seeded`** ("flavour"): each spawned piece gets one of `colour_count` flavours from the level's seeded stream, and `family` stays the default for other biomes. Cost S–M (spawner + block record; the record already has `tags`). Fallback if refused: pick each level's pool so that each flavour is one family (Standard = strawberry, Helper = vanilla, Pento Flat = mint), which works but makes shape and colour the same clue.

**Recipe notes**
- Slot defaults (not counted): BL01, AR01, CV01, CL01, CO01, GO01, FT01. Mascot atoms (WO01, WO06–WO09, WO11) are biome-wide and not counted, as in the Meadow; SE05 is counted.
- Budget (F1): ≤ 2 atoms new to the player, ≤ 4 non-default; showpiece levels on tiers 7–10 ≤ 6. A bundle (M1 build race = GO02 + CL14 + FT02; M2 = GO03 + CL14; "earned candy bomb" = SP04 + SP01) counts as one idea.
- Events as Candy events: Spawned Objects (EV04) = **Gumdrop Hail** / **Meringue Dollop**; Speed-up bump (EV17) = **Sugar Rush**; Goo spread (EV11) = **Chocolate Spread**; Gravity flip (EV03, sideways) = **Fountain Tilt**.

**New atoms this biome needs** (marked **NEW** in recipes; each is one plugin or one data entry per implementation-plan §3)

| Proposed ID | Name | One line | Hook (impl-plan §3 row) | Cost | Used in |
|---|---|---|---|---|---|
| **EV20** | Syrup band | A set of (x, z) columns is syrup. A falling piece with any cube over syrup falls at × `syrup_slow` (0.4); if it lands in syrup it glides `syrup_glide` (≤ 2) cells along `syrup_dir` until blocked, then locks | Twist (`RuleBehaviour`) | M | 03, H2 |
| **CO09** | Gummy cascade (colour glue) | After a clear, unsupported cubes fall, but every face-connected same-colour blob falls **as one rigid chunk** and holds on to its own overhangs | Collapse rule (`CollapsePolicy`) | M | 04, 07, 09, 10, H1 |
| **SC12** | Tier frosting | Every `tier_layers` (2) layers form a tier; a tier is **frosted** when ≥ `frost_share` (0.6) of its cubes share one colour that differs from the tier below. Stars count frosted tiers | Scoring rule (`RuleBehaviour` on `on_lock`) | S | 05 |
| GO03 param | Colour targets | Target cells carry a colour glyph; a cell counts only if covered by that colour (or a rainbow cube) | Goal plugin param (target glyph legend) | S | 06, Candy Box |
| PL01 param | Sticky tag | `sticky_tags`: only pieces with the tag lock on first touch (gumdrops) | Data only (`rules/sticky.json` param) | S | 02, 03, H2 |
| SP25 param | Jelly bounce | `jelly_bounce` 1: a jelly piece hops 1 cell up and 1 cell on along its last move, then squishes (SP25 slump) | Data only | S | 04 |
| EV17 param | Mood trigger | `bump_trigger: mood`: a notch is added while Mallow is grumpy, removed when she is happy | Data only + WO01 read | S | 08 |
| **BL17** | Bake (stage swap) | BL15 stage medley with a transform: on the stage goal every locked cube becomes `sponge` (no colour, never clears, solid); dollop cubes become frosting (SP29, 2 layers) | Mechanic atom with behaviour | M | 10, H3 |
| **SP38** | Climber boss | A 2×2×1 boss object on the top surface. After each lock it slides to the highest reachable 2×2 spot (it wants the top). A colour pop touching it = 1 bonk (it tumbles to the lowest neighbour spot) | Mechanic atom + content type | M | 10, H3 |
| **GO27** | Bonk the boss | Win at `bonks_needed` (3) bonks on SP38 | Goal plugin | S | 10, H3 |

Everything else is an existing module atom: CL07 (D), CL05 (D), CO02 (D), SP01 (D), SP04, SP20, SP25, SP27, SP29, SP30, SP31, SP32, EV11, EV17 (all C: need their Candidate rules written, no new framework).

**Sketch legend**: as in the Meadow. Top-down: `#` active, `.` off, `+` target, `S` spawn anchor. Starting contents: `g` gumdrop, `l` licorice lock, `c` chocolate, `w` gummy worm, `~` syrup column. Colour targets: `P` pink (strawberry), `V` vanilla, `M` mint. Side view: `=====` danger line at `H_play`, `:` skips empty rows.

## Summary

| # | Level | Story beat | New idea (atoms new to player) | Mallow prank card (grumpy) | Stage | Goal | Board | g0 | Top-out | Colours | Non-default |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | Sugar Cube Start | Lay the cake base | Mono layer bonus (CL07) | cosmetic bounce | clean, calm | Clear 4 | 4×4, H8 | 0.65 | rescue, 2 | 2 | 2 (CL07, SE05) |
| 02 | Gumdrop Hail | Gumdrops stick in the tin | Gumdrop Hail (EV04 + sticky tag) | cosmetic bounce | busy | Clear 3 | 5×5, H10 + pockets | 0.65 | rescue, 1 | 2 | 4 |
| 03 | Syrup River | Sail the lolly lane home | Syrup band (**EV20**) | hops on the piece: nudge 1 cell | busy | Clear 4 | 8×4 lane, H10 | 0.75 | rescue, 1 | 2 | 3 |
| 04 ★ | Jelly Wobble | The jelly bridge jiggles | jelly pieces (SP25 + bounce), gummy cascade (**CO09**) | jumps on the bridge: next piece bounces | busy | Clear 4 | 8×3 bridge, H9 | 0.8 | rescue, 1 | 2 | 3 |
| 05 | Cake Tiers | Stack tiers to the candles | tier frosting (**SC12**), colour = stars | licks the next piece: flavour swap | clean, tense | Height 10 | 6×6 round, H12 | 0.85 | trim | 3 | 4 |
| 06 | Icing Picture | Pipe Granny's picture | colour targets (GO03 param), rainbow sprinkles (SP27) | licks a cell: smudge (happy: licks a smudge away) | clean, calm | Picture 44 of 52 | 8×8 flat, H3 | 0.75 | trim | 2 + rainbow | 4 |
| 07 ★ | Gummy Worms | Worms raid the jar | Colour Pop (CL05), gummy worms (SP31) | tickles a worm awake: it moves twice | busy | Clear 6 (pops or layers) | 6×6 jar, H10 | 0.9 | rescue, 1 | 3 | 3 |
| 08 | Sugar Rush | Mallow ate too much | Sugar Rush (EV17, mood trigger), candy bombs (SP04 + SP01) | the rush itself (speed notch) | clean, frantic | Survive 150 s | 5×5, H8 | 0.95 | rescue, 1 | 3 | 4 |
| 09 | Chocolate Fountain | The fountain tips the cake | Chocolate Spread (EV11), licorice locks (SP30) + Fountain Tilt callback (EV03) | splashes chocolate: +1 spread | busiest | Clear 6 | 6×6, H10 + starter | 1.0 | rescue, 1 | 3 | 6 (showpiece) |
| 10 ★ | Madame Meringue | Bake, then bonk the topper | Bake (**BL17**), climber boss (**SP38** + **GO27**) | Mallow cheers; boss acts | busiest | Stage 1 height 6 → Stage 2 bonk 3 | 7×7 round, H14 | 1.0 | trim → rescue, 1 | 3 | 6 (showpiece) |
| B | Candy Box | Pack Granny's chocolates | fixed list + colour compartments, 60 s | paw steals misplaced sweets | clean, hurried | Box 32 in 60 s | 4×4, H2 | 0.55 | budget / 60 s | 3 + rainbow | 4 |
| H1 | Moody Gummies | The gummies sulk | moody gummies (SP20) | tickles a gummy grumpy | busy | Clear 8 | 6×6, H10 | 1.0 | rescue, 1 | 3 | 4 |
| H2 | Frosting Factory | Frosting jammed the lane | frosting tiles (SP29) + syrup + hail | nudge | busy | Peel all frosting | 8×4 lane, H10 | 1.0 | rescue, 1 | 3 | 4 |
| H3 | Meringue's Rematch | She wants a do-over | countdown bonbons (SP32) on the finale | cheers | busiest | as 10, bonk 4 | 7×7 round, H14 | 1.05 | rescue, 1 | 3 | 6 |

★ = proposed prototype priority (user to confirm): **04** (gummy cascade is the one new collapse; it also proves colour glue), **07** (colour pop is the heart of the biome), **10** (the bake transform and the climber boss are the riskiest new code), plus **03** as the cheap fourth (one new twist, tests the "slow + glide" feel).

g0 is hand-set (0.65–1.0). Whether Candy's tiers continue campaign F2 from the Meadow (tier 11–20 → 1.05–1.4) is open with game-designer; this draft deliberately restarts a bit lower so Candy 01 feels like a fresh start.

Pacing: short tutorial (01–02) → two longer "sticky" levels (03–04) → no-fail breathers (05 tower, 06 picture) → the colour-pop step (07, long) → a short, frantic sprint (08) → the long hard remix (09) → the two-stage finale (10).

```text
strangeness (how far from classic)
 high |                             #        #   #
      |               #             #     #  #   #
  mid |            #  #  #  #       #     #  #   #
      |      #     #  #  #  #       #  #  #  #   #
  low |  #   #     #  #  #  #       #  #  #  #   #
      +-01--02----03-04--05-06-----07-08-09-10--B
        learn     sticky  breathers pop sprint remix FINALE
```

---

## 01 Sugar Cube Start

**Story card.** Mallow needs a foundation for Granny's cake. Lay sugar-cube layers; a layer all in one flavour sparkles and pops an extra layer for free. · **Mallow: mood swing** (happy = points at the emptiest cell, 1 catch; grumpy = cosmetic bounce only).

**Island**: a sugar-cube tin on a lace-doily island; clean stage, calm. **Intro skit (3 s)**: Mallow drags a giant recipe card, points at the empty tin, then up at the gumdrop clouds. **Payoff skit**: the base sets with a "ding"; Mallow hops on it to test it and sticks to the top, feet first.

```text
Name:          Sugar Cube Start
Board:         BL01 (4×4, H_play 8)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (2 warnings, rescue)
Optional:      CL07 Mono layer (bonus blast, mono_extra_layers 1) + CO01 · SE05 gummy duck · WO08 + WO11 (1 catch)
Colours:       2 (strawberry, vanilla)
One sentence:  "Fill a layer to clear it; one flavour = sparkle."
```

**Pieces**: I, O, T, L, S; first 2 from {O, I}. **Stars**: ★★ 150 s, ★★★ 110 s (a sparkle saves about 25 s, so colour helps but is never needed).

**Wacky test.** Surprising: one-flavour layers explode into sugar sparkle and take the next layer with them. Silly: the sugar cubes squeak like marshmallows when they lock. Funny failure: the base slumps into goo and Mallow faceplants. Big moment: the first sparkle, a sugar firework over the tin.

```text
top-down 4×4      side (z = 1)
####              11 . S S .   spawn zone
#S##               8 ========  danger line
####               :
####               0 . . . .   the tin floor (lace doily)
```

**How it plays**: (1) An O drifts down; Mallow points at a corner. (2) First clear in about 4 pieces: the tin sinks a step, a "ding". (3) Two pink pieces in a row: Mallow wiggles her ears at the half-pink layer (hint). (4) Fourth clear sets the base.

---

## 02 Gumdrop Hail

**Story card.** It hails gumdrops, and they stick wherever they land. Granny's cake tin has three pockets shaped like pieces; fill them, and use the gumdrops as free plugs. · **Mallow: mood swing** (happy = points at the pocket the piece fits, 1 catch; grumpy = cosmetic bounce).

**Island**: a cake tin set into a giant cupcake; gumdrop clouds overhead; busy. **Intro skit (3 s)**: Mallow holds out an umbrella; a gumdrop bonks through it and sticks to her nose. **Payoff skit**: the tin pops the layer out like a cake mould; Mallow peels the gumdrop off her nose and eats it.

```text
Name:          Gumdrop Hail
Board:         BL05 (5×5, H_play 10, 2 starter layers with 3 pockets)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (3 layers)
Fail:          FT01 (1 warning)
Optional:      CL07 + CO01 · EV04 Gumdrop Hail (every 4 locks, 1 gumdrop cube, forecast shadow 1 lock ahead, max 6)
               · PL01 with sticky_tags ["gumdrop"] (gumdrops lock on first touch) · SE05 gummy duck
Colours:       2
One sentence:  "Gumdrops stick where they land; use them as plugs."
```

**Pieces**: 8 Standard; first 3 are a bag of {T, L, Tripod} (the pocket shapes). Gumdrops carry a flavour, so they can complete a sparkle layer. **Stars**: ★★ 140 s, ★★★ 100 s. Counter: *use it* (park a 1-cell gap under the shadow).

**Wacky test.** Surprising: blocks fall that you do not steer. Silly: gumdrops boing and wobble when they land. Funny failure: a gumdrop lands smack in a pocket meant for a T, and Mallow facepalms. Big moment: filling the last pocket pops the tin like a jelly mould.

```text
top-down, layer 0   layer 1          side (z = 2)
#####               #####            10 ==========
##.##               #..##             :
#####               #.###   T pocket  1 # . . # #
#####               ###.#             0 # # . # #
#####               ##..#   L pocket  g = gumdrop shadow: lands 1 lock later
```

**How it plays**: (1) A T spawns; Mallow points at its pocket. (2) After the 4th lock a shadow appears; a gumdrop hails onto it and sticks. (3) The player leaves a 1-cell gap under the next shadow and gets a free plug. (4) Third clear; the gumdrop clouds part.

---

## 03 Syrup River

**Story card.** Mallow sails a lollipop raft down a syrup river to fetch the cake's cream. Syrup slows the falling piece and glides it downstream on landing; build from the dock end. · **Mallow: mood swing** (happy = helper + 1 catch; grumpy = hops onto the falling piece and nudges it 1 cell, telegraphed by a crouch).

**Island**: a long lollipop lane with a syrup river along the middle and a candy dock at the downstream end; busy. **Intro skit (3 s)**: Mallow pushes off on a lollipop raft, gets stuck in the syrup, and paddles in slow motion. **Payoff skit**: the raft reaches the dock; Mallow lifts a cream jug, slips, and the syrup slowly carries her back.

```text
Name:          Syrup River
Board:         BL01 (8 wide × 4 deep, H_play 10)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (1 warning)
Optional:      CL07 + CO01 · EV20 Syrup band NEW (columns z = 1–2, syrup_slow 0.4, syrup_dir +x, syrup_glide 2)
               · EV04 Gumdrop Hail callback (every 8 locks)
Colours:       2
One sentence:  "Syrup slows your piece and glides it downstream."
```

**Pieces**: 8 Standard. **Stars**: ★★ 330 s, ★★★ 235 s.

**Wacky test.** Surprising: a landed piece keeps moving. Silly: the piece glides with a long sticky stretch-sound and syrup strings behind it. Funny failure: a piece glides past the gap you wanted, and Mallow paddles after it. Big moment: a clear makes the whole river shimmer and the raft lurches forward.

```text
top-down 8×4 (syrup ~ glides →)    side (z = 1)
########                           13 . . . S S . . .   spawn
~~~S~~~~   → → → glide             10 ================
~~~~~~~~   → → →                    :
########                            0 . . . . . . . |   dock wall at x = 7
the dock wall at x = 7 stops the glide (the brace, as in Meadow 03)
```

**How it plays**: (1) A piece over the river drops to a crawl: lots of aim time. (2) It lands and glides 2 cells toward the dock. (3) The player learns to build up from the dock wall, so glides end flush. The dry rows (z = 0, 3) fall at normal speed: a choice between fast and careful. (4) Fourth clear; the raft docks.

---

## 04 Jelly Wobble ★PROTO

**Story card.** A jelly bridge carries the cake to the party table. Jelly pieces bounce once and squish into gaps; after every clear the whole bridge jiggles and the stack settles down, same-flavour blobs sticking together. · **Mallow: mood swing** (happy = helper; grumpy = jumps on the bridge so the next piece bounces one extra cell).

**Island**: a wobbling jelly bridge between two cupcake cliffs; busy; this is Candy's one physics-silly level. **Intro skit (3 s)**: Mallow steps onto the bridge, it wobbles, she bounces twice and lands on her bottom. **Payoff skit**: Mallow trampolines across the finished bridge carrying the cake and lands it on the table, perfectly.

```text
Name:          Jelly Wobble
Board:         BL01 (8 wide × 3 deep, H_play 9)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (4 layers)
Fail:          FT01 (1 warning)
Optional:      CL07 · CO09 Gummy cascade NEW (same-colour blobs fall as rigid chunks)
               · SP25 Jelly piece, 1 per bag, with jelly_bounce 1
Colours:       2
One sentence:  "Jelly bounces and settles; same flavours stick together."
```

**Pieces**: 8 Standard (flat-heavy weights: I, O, L ×1.5, because the bridge is shallow). **Stars**: ★★ 300 s, ★★★ 210 s.

**Wacky test.** Surprising: holes fill themselves after a clear. Silly: jelly pieces boing and wobble for a second after they lock. Funny failure: a jelly piece bounces off the end of the bridge, and Mallow tries to catch it with her ears. Big moment: a clear makes the whole bridge jiggle, and pink and white blobs drop as chunks.

```text
top-down 8×3           side (z = 1), before → after a clear
########               y   before              after (gummy cascade)
###S####               3   P P . . V V . .     . . . . . . . .
########               2   # # # # # # # #  →  P P . . V V . .   blobs drop as chunks
                       1   # . # . # # . #     # . # . # # . #
cliffs at x = 0 and 7  0   # # # # # # # #     # # # # # # # #
```

**How it plays**: (1) A jelly piece lands, hops one cell along its last move, and one cube slumps into the gap below. (2) First clear: everything above jiggles down; a pink blob drops whole and keeps its overhang. (3) The player learns to build same-flavour blobs on purpose, because blobs hold their shape. (4) Fourth clear; the bridge settles.

---

## 05 Cake Tiers

**Story card.** Build the cake up to the candles, one frosted tier at a time. A tier is frosted when most of it is one flavour, a different one from the tier below. Nothing clears; too high pops off. · **Mallow: mood swing** (happy = sits on top and points at the tier's flavour; grumpy = licks the next piece in the preview and swaps its flavour, telegraphed by a tongue). **Madame Meringue** first appears on the bakery shelf, sniffing.

**Island**: a cake stand on a pastry hill, a candle sign floating above; clean, tense. **Intro skit (3 s)**: Mallow stacks two tiny cakes, they topple; she looks at the candles high above and gulps. **Payoff skit**: the candles light themselves; Mallow blows them out by accident and relights them with a sheepish grin. Meringue rolls her eyes.

```text
Name:          Cake Tiers
Board:         BL02 (6×6 round: corners off, 32 cells, H_play 12)
Arrival:       AR01
Verb:          CV01
Goal:          GO02 (height 10, coverage 0.6)    ┐ M1 build race (one idea)
Fail:          FT02 (trim)                        │
Optional:      CL14                               ┘ · SC12 Tier frosting NEW (tier_layers 2, frost_share 0.6)
Colours:       3
One sentence:  "Each tier: mostly one flavour, a new one each time."
```

**Pieces**: 8 Standard + Big Cube (w 0.5). **Stars (colour is the rule here)**: ★ reach the candles; ★★ 3 of 5 tiers frosted; ★★★ 5 of 5 frosted and no cube trimmed.

**Wacky test.** Surprising: stars come from colour, not time. Silly: each frosted tier squirts a frosting rim and a cherry plops on top. Funny failure: an unfrosted tier sags like a sad sponge; a trimmed cube bounces off and Meringue catches it and eats it. Big moment: the fifth tier frosts and the candles burst alight.

```text
top-down 6×6 round   side (z = 2)
.####.               15 . . S . . .   spawn
######               12 ============  danger line (trim)
######                9 - - - - - -   candle sign (layer 9, 60%)
######                :   tier 4 (layers 6–7), tier 3 (4–5) …
######                1   tier 1 (layers 0–1): mostly pink?
.####.                0
```

**How it plays**: (1) The first tier glows pink as pink pieces land. (2) A vanilla piece arrives; the player tucks it at the edge (40% may be other flavours). (3) Tier 2 must be a new flavour; the HUD shows the tier's leading flavour as icing. (4) Messy stacking makes Mallow lick the preview, so tidiness now protects your colours.

---

## 06 Icing Picture

**Story card.** Pipe a picture of Granny on top of the cake in two icings. Every cell wants its own icing; rainbow sprinkles fit anywhere. · **Mallow: mood swing** (happy = licks one smudged cell clean every 6 locks; grumpy = licks a cell into a smudge, telegraphed). This is where Mallow's mood becomes real help or harm.

**Island**: a flat cake top on a turntable, piping bags around; clean, calm. **Intro skit (3 s)**: Mallow holds up a crayon drawing of Granny, then looks at the bare white cake top. **Payoff skit**: the picture finishes; Granny's portrait winks; Mallow licks the piping bag clean, cross-eyed.

```text
Name:          Icing Picture
Board:         BL01 (8×8, H_play 3)
Arrival:       AR01
Verb:          CV02 (spin only: icing lies flat)
Goal:          GO03 with colour targets (52 target cells on layer 0; win at 44 correct)  ┐ M2
Fail:          FT02 (trim: anything above layer 0 pops off)                             │
Optional:      CL14                                                                     ┘ · SP27 Rainbow sprinkle piece, 1 per bag
Colours:       2 (pink, vanilla) + rainbow
One sentence:  "Match each cell's icing colour."
```

**Pieces**: flat set: I, O, T, L, S, Duo, Tri-Straight, Tri-Corner. A wrong-colour cube on a target cell is a **smudge**: it stays and does not count. **Stars**: ★★ 44 correct in 170 s, ★★★ all 52 correct (no smudge left).

**Wacky test.** Surprising: the right shape in the wrong colour does not count. Silly: Granny's face appears cell by cell and changes expression as it fills. Funny failure: smudges give Granny a moustache, and Mallow giggles. Big moment: the last cell completes the portrait, and it winks.

```text
colour targets, layer 0 (P pink, V vanilla, . plate)   side (z = 3)
..VVVV..                                              3 ==========  trim line
.VPPPPV.                                              :
VPPVVPPV   (eyes)                                     0 V P P V V P P V
VPPPPPPV
VPVPPVPV   (smile)
.VPVVPV.
..VVVV..
...VV...
```

**How it plays**: (1) A pink L arrives; the player finds a pink patch it fits. (2) A vanilla piece has nowhere tidy to go; the player learns to park it on the rim. (3) A rainbow sprinkle piece fixes an awkward mixed corner. (4) Keeping the board tidy keeps Mallow happy, and she licks smudges away.

---

## 07 Gummy Worms ★PROTO

**Story card.** Cheeky gummy worms crawl out of the jar and nibble the stack. Pop same-flavour groups to send them packing before they wriggle off with a cube. **Colour now clears**: 6 or more touching cubes of one flavour pop, and full layers still clear. · **Mallow: mood swing** (happy = points at a group 1 cube short; grumpy = tickles a worm awake, so it moves twice next lock).

**Island**: a giant candy jar tipped on its side, the lid off, gummy worms peeking out; busy. Meringue on the shelf, amused. **Intro skit (3 s)**: Mallow reaches into the jar; a worm pops out, steals her lollipop and wriggles off. **Payoff skit**: the last worm is popped; the three worms sulk back into the jar; Mallow screws the lid on and sits on it.

```text
Name:          Gummy Worms
Board:         BL02 (6×6 jar: corners off, H_play 10)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (6 clears: pops or layers)
Fail:          FT01 (1 warning)
Optional:      CL05 Colour pop (pop_min 6, pop_min_pieces 2, layer_clear_too true) · CO09 Gummy cascade (callback)
               · SP31 Gummy worm (2 at start, 1 more at 60 s; each lock eats one neighbour cube;
                 a pop or clear next to it pops the worm; a worm on the rim with a cube leaves with it)
Colours:       3
One sentence:  "Six of one flavour pop; pops chase the worms."
```

**Pieces**: 8 Standard. **Stars**: ★★ 330 s, ★★★ 235 s and no worm escaped. Counter for worms: *clear to cancel*.

**Wacky test.** Surprising: colour now clears, not just layers. Silly: worms chew with cartoon crunches and wear a crumb moustache. Funny failure: a worm reaches the rim and waves goodbye carrying your cube like a trophy. Big moment: a pop next to a worm launches it out of the jar in a "boing".

```text
top-down, layer 0 (w worm)   side (z = 2)
.####.                       10 ============
#w####                        :
######                        1 . . . . . .
####w#                        0 # # # # w #   starter layer, mixed flavours
######
.####.
```

**How it plays**: (1) A pink piece lands on a pink starter patch: 1 short, it glows (the M5 telegraph). (2) The next pink piece pops the group; the worm next to it boings away. (3) The player learns to build flavour groups near worms. (4) At 60 s a third worm crawls in from the jar mouth; the last clears are a chase.

---

## 08 Sugar Rush

**Story card.** Mallow ate the whole candy bowl. While the tower is messy she is on a sugar rush and everything speeds up; tidy it and she calms down. Hang on for 2:30 until she crashes into a nap. Big pops leave candy bombs. · **Mallow: mood swing, and her mood IS the event.**

**Island**: Granny's kitchen counter, an empty candy bowl, wrappers everywhere; clean, frantic. **Intro skit (3 s)**: Mallow eats one candy, then the bowl, then the wrapper; her eyes spin. **Payoff skit**: at 2:30 Mallow crashes mid-hop into a nap on top of the stack, snoring; the speed drops; a wrapper floats down onto her like a blanket.

```text
Name:          Sugar Rush
Board:         BL01 (5×5, H_play 8)
Arrival:       AR01
Verb:          CV01
Goal:          GO04 (survive 150 s, ramp 0.15 cells/s per min)
Fail:          FT01 (1 warning)
Optional:      CL05 (pop_min 6, layer_clear_too true) + CO01
               · EV17 Sugar Rush with bump_trigger mood (grumpy: +1 notch every 10 s, max 3; happy: −1 notch; 1 s jitter warning)
               · SP04 earned candy bombs (only the bomb branch: a pop of ≥ 7 leaves an SP01 candy bomb, 3×3×3)
Colours:       3
One sentence:  "Messy tower, hyper Mallow, faster drops."
```

**Pieces**: 8 Standard. **Stars** (by clears, like Meadow 08): ★★ 3 clears, ★★★ 6 clears and no warning used.

**Wacky test.** Surprising: your tidiness controls the speed. Silly: Mallow's ears spin like propellers at max rush. Funny failure: the gooey slump while Mallow vibrates on top. Big moment: a candy bomb blast that clears the mess and snaps Mallow out of the rush mid-air.

```text
top-down 5×5      side (z = 2)
#####             11 . . S . .   spawn
#####              8 ==========   danger line (8 layers: tight)
##S##              :
#####              0 . . . . .
#####             HUD: Mallow's sugar meter (0–3 notches)
```

**How it plays**: (1) Calm start; Mallow happy. (2) A messy drop leaves a hole; Mallow gobbles, shakes, and the fall speeds up a notch. (3) The player learns that a pop or a clear calms her. (4) A 7-pop leaves a candy bomb; clearing it blasts a 3×3×3 hole in the mess. (5) 2:30: nap.

---

## 09 Chocolate Fountain

**Story card.** Madame Meringue nudges the chocolate fountain; it tips the whole cake sideways and chocolate spreads over everything it touches. Licorice ties some cubes down. Pop next to the chocolate to stop it; clear next to the licorice to untie it. · **Mallow: mood swing** (happy = points at the cube the chocolate will take next; grumpy = splashes in the fountain, +1 spread step). **Meringue** is on the fountain's rim, pushing.

**Island**: a plaza around a three-tier chocolate fountain; busiest. **Intro skit (3 s)**: Meringue leans on the fountain, it tips, and a chocolate wave washes Mallow off her feet. **Payoff skit**: the fountain rights itself; Mallow comes up chocolate-coated and licks herself clean, delighted; Meringue huffs.

```text
Name:          Chocolate Fountain
Board:         BL05 (6×6, H_play 10, 1 starter layer: 2 chocolate cubes, 4 licorice locks)
Arrival:       AR01
Verb:          CV01
Goal:          GO01 (6 clears: pops or layers)
Fail:          FT01 (1 warning)
Optional:      CL05 (pop_min 6, layer_clear_too true) · CO09 Gummy cascade
               · EV11 Chocolate Spread (each lock, coats 1 neighbour cube unless a pop or clear touched chocolate that lock;
                 coated cubes have no flavour)
               · SP30 Licorice lock (cannot clear or move until a clear next to it)
               · EV03 Fountain Tilt callback (down axis turns 90° to −x and back; every 2 clears or 50 s; 2 s warning)
Colours:       3
One sentence:  "Stop the chocolate with pops; the cake tips sideways."
```

**Pieces**: 8 Standard. **Stars**: ★★ 380 s, ★★★ 270 s. Showpiece (6 non-default: BL05, CL05, CO09, EV11, SP30, EV03).

**Wacky test.** Surprising: the cake tips over sideways and keeps going. Silly: chocolate drips upward after the tilt, then remembers gravity. Funny failure: the whole stack ends up chocolate-brown and Mallow licks it anyway. Big moment: the tilt, with a chocolate wave sloshing across the cake.

```text
top-down, layer 0 (c chocolate, l licorice)   side (z = 2), tilt ← to −x
######                                        10 ============
#c#l##                                         :
###l##                                         1 . . . . . .
##l###                                         0 # c # l # #   chocolate side = fountain side (x = 0)
#c##l#
######
```

**How it plays**: (1) The chocolate creeps one cube per lock; a pop beside it stops the creep for that lock. (2) A layer clear next to a licorice lock unties it. (3) After 2 clears the fountain tilts: the stack falls toward x = 0 as gummy chunks. (4) The player learns to pop on the chocolate side, which becomes the floor after a tilt.

---

## 10 Madame Meringue (finale: transformation) ★PROTO

**Story card.** **Stage 1, Batter**: fill the tin up to the oven line. Madame Meringue "helps" by dropping meringue dollops, which is secretly sabotage. **BAKE!** The oven slams shut, and the whole stack bakes into one giant sponge cake; her dollops bake into frosting. **Stage 2, Decorate**: Meringue hops on top of the cake. She always climbs to the highest spot (she wants to be the topper). Pop flavour groups right next to her to bonk her down; three bonks and she plops on top as the cake topper, upside down and furious. · **Mallow** cheers from the table (watcher); Granny dozes in her chair.

**Island**: Granny's birthday table with a giant oven hood hanging over a round cake tin; busiest. **Intro skit (3 s)**: Mallow cracks an egg into the tin; Meringue rolls in, inspects the tin and plants a dollop of herself in it. **Payoff skit**: Meringue lands upside-down on top; Granny wakes, claps, and blows out the candles, blowing frosting all over Meringue, who fumes and swears revenge. Keepsake: a cherry (Mallow puts it on the wizard's hat).

```text
Name:          Madame Meringue
Board:         BL02 (7×7 round: corners off, H_play 14)
Arrival:       AR01
Verb:          CV01
Stage 1:       GO02 (height 6, coverage 0.6) · CL14 · FT02 (trim) · EV04 Meringue Dollop (every 5 locks, 1 cube, forecast)
Bake:          BL17 Bake NEW (all cubes → sponge; dollops → SP29 frosting, 2 layers; 3 s oven cut-in)
Stage 2:       GO27 Bonk the boss NEW (3 bonks) · CL05 (pop_min 6) · CO09 · FT01 (1 warning)
               · SP38 Climber boss NEW (Meringue, 2×2×1; slides to the highest 2×2 spot after each lock)
Colours:       3
One sentence:  "Fill the tin; then bonk Meringue off the top."
```

**Pieces**: I, O, T, L, Tripod, Screw-Left, Screw-Right, Chair. **Stars**: ★★ 360 s, ★★★ 255 s. Non-default (showpiece ≤ 6): BL02, BL17 (stage bundle), GO02 → GO27 (goal per stage), CL05 + CO09 (counted as 2), SP38 boss bundle (incl. dollops and frosting). Count = 6 if the stage goals count as one goal slot; flagged for the module owner.

**Boss play.**
- *Stage 1*: no clears, no fail. Each dollop takes a cell: free height now, frosting later. Clever players bury dollops low, where frosting will not matter.
- *Bake*: the sponge is solid floor, never clears. Frosting (old dollops) on the top surface peels one layer per adjacent pop and blocks groups meanwhile.
- *Stage 2*: Meringue always moves to the highest spot she can reach. The player builds a tall pillar of one flavour, lets her climb onto it, then pops the group under her: bonk, she tumbles to the lowest neighbouring spot, then climbs again. During her climb wind-up she throws a dollop (counter: *clear to cancel*, a pop during the 1 s wind-up cancels it).
- *Fail* (stage 2 only): the cake slumps, Mallow faceplants, Meringue sits on the heap like a crown.

**Wacky test.** Surprising: the stack you built becomes a single baked cake and the rules change. Silly: Meringue's dramatic climbs and her little "hmph" on each bonk. Funny failure: the cake collapses and she rides it down, smug. Big moment: the bake (the oven slams, steam, the cake rises a notch with a "puff"), then the final bonk flipping her upside down on top.

```text
top-down 7×7 round     side (z = 3)
.#####.                y    stage 1                     stage 2 (after BAKE)
#######                17   . . . S . . .               . . . S . . .
#######                14   =============               =============
###S###                 :                               . . M M . . .   Meringue on the highest spot
#######                 6   - - oven line - -           P P P # . . .   pink pillar under her
#######                 :   dollops d land here         s s f s s s s   f = frosting (an old dollop)
.#####.                 0   # # d # # # #               s s s s s s s   s = sponge (baked, solid)
```

---

## B Candy Box (bonus, unlocks at 20 Candy stars)

**Story card.** Granny is at the door in 60 seconds. Pack her chocolate box: each compartment is one flavour. Mallow's paw sneaks in and eats any sweet in the wrong compartment. · **Mallow: prankster with a heart** (she only eats mistakes).

**Island**: a heart-shaped chocolate box on a doily; clean, hurried; a door with a shadow behind it. **Intro skit (3 s)**: the doorbell rings; Mallow panics, grabs the empty box, and licks her lips at the sweets. **Payoff skit**: the lid closes as the door opens; Granny takes the box; Mallow, cheeks bulging, smiles with her mouth closed.

```text
Name:          Candy Box
Context:       campaign (hard track, tier 11)
Board:         BL01 (4×4, H_play 2)
Arrival:       AR09 fixed list (8 pieces + 1 rainbow sprinkle spare): O pink, O pink, I mint, I mint, L vanilla, L vanilla, Duo pink, Duo mint, rainbow T
Verb:          CV01
Goal:          GO03 with colour targets (32 cells: 2 layers × 16)
Fail:          FT07 (out of pieces) + 60 s limit
Optional:      CL14 · paw rule: every 15 s, the most recent piece not touching its own target colour is eaten (removed; telegraph 2 s)
Colours:       3 + rainbow
One sentence:  "Right flavour, right compartment, before the doorbell."
```

**Stars**: ★★ 45 s; ★★★ 30 s and the paw ate nothing. The paw rule is a level param of the goal (`mistake_eater`), or SE07-style scripted event; it does not need a new slot.

**Wacky test.** Surprising: misplaced sweets vanish. Silly: Mallow's paw sneaking in with a napkin tucked in. Funny failure: time runs out, Granny opens the door to Mallow with her face in the box. Big moment: the lid slams on the bell.

```text
colour targets, both layers   side (z = 1)
PPMM                          2 ========
PPMM                          1 P P M M
VVMM                          0 P P M M
VVPP
```

---

## Hard-track remixes (tiers 12–14, open after 10)

### H1 Moody Gummies

**Story card.** The gummies are in a mood: a gummy that does not touch its own flavour sulks and refuses to pop. Cheer them up by finding them friends. · **Mallow: mood swing** (grumpy prank: tickles a happy gummy grumpy).

```text
Board: BL01 (6×6, H_play 10) · AR01 · CV01 · GO01 (8 clears) · FT01 (1)
Optional: CL05 (pop_min 6) · CO09 · SP20 Moody gummy (1 per bag: grumpy until it touches its own colour; grumpy cubes do not count for pops or layers)
Colours: 3 · g0 1.0 · ★★ 420 s, ★★★ 300 s
Remix of: 07 Gummy Worms. Wacky: sulking gummies with crossed arms; a pop of 3 cheered-up gummies does a conga.
```

### H2 Frosting Factory

**Story card.** The syrup river jammed with frosting. Each frosting tile peels one layer per clear next to it; peel them all. · **Mallow: mood swing** (grumpy: nudge).

```text
Board: BL05 (8×4 lane, H_play 10, starter layer with 6 frosting tiles: 3 of 2 layers, 3 of 3 layers)
AR01 · CV01 · GO07 Rescue all (every frosting tile gone) · FT01 (1)
Optional: CL05 + layer clears · EV20 Syrup band (callback) · EV04 Gumdrop Hail · SP29 Frosting
Colours: 3 · g0 1.0 · ★★ 380 s, ★★★ 270 s
Remix of: 03 Syrup River. Wacky: frosting tiles squish and splat a little cream with each peel.
```

### H3 Meringue's Rematch

**Story card.** Madame Meringue demands a do-over, and this time she throws countdown bonbons: each one ticks down per lock and splats a junk layer at zero unless you clear next to it. · **Mallow: watcher**, Meringue: boss.

```text
As 10, plus: SP32 Countdown bonbon (thrown in stage 2 every 8 locks, cd_start 8; blast 1 junk layer) · bonks_needed 4
Colours: 3 · g0 1.05 · ★★ 420 s, ★★★ 300 s
Rival return (biome-stories "hard-track rematch with one extra trick"). Wacky: bonbons with tiny ticking faces that sweat at 1.
```

---

## Open items (for designers, not the user)

- **Colour source**: `colour_source: seeded` vs family-as-colour (top of file). Blocks 05–10, B, H1–H3.
- **New atoms to add to the module**: EV20, CO09, SC12, BL17, SP38, GO27, and params on GO03, PL01, SP25, EV17. Candidate rules to write before build: CL07 bonus value, SP04 (bomb branch only), SP20, SP25, SP27, SP29, SP30, SP31, SP32, EV11, EV17, WO01/WO07/WO08.
- **Budget reading**: stage goals in 10 counted as one goal slot; "earned candy bomb" as one bundle. Confirm with the module owner.
- **g0 for biome 2**: hand-set 0.65–1.05 here; reconcile with campaign F2.
- **Countdown bonbons and moody gummies** are hard-track only in this draft (the main path was at budget). If the user wants them on the main path: bonbons can replace candy bombs in 08 (Mallow drops bonbons while on the rush), moody gummies can join 07 instead of the third worm.
- **Bible drift**: `biome-bible.md` §2.2 still has the older Candy story ("Gumdrop" mascot, Taffy Pull, Mono Monday); this file follows `biome-stories.md`.
- **Star numbers** are estimates; replace with playtest medians.
