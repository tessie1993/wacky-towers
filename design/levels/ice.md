# Ice Biome: Pebble's Egg Escape (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10). Written under the `/team-narrative` round ("full detail for all 100 levels").
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format**: copies `design/levels/meadow.md` section for section.
> **Sources**: `production/narrative/campaign-story/brief.md` (§3.3, §5, §7 rules), `dialogue-campaign-skits.md` (§3 Ice, §0 grammar), `lore-world.md` (§3.3, §7), `visual-direction.md` (§1.4, §2.2, §3.2 Ice), `design/gdd/mechanics-module.md` (atoms, F1), `campaign-structure.md`, `level-data-definition.md`, `twist-library.md`, `level-specific-mechanics.md`, `level-goals-fail-states.md`, `scoring-stars.md`, `skills.md` (Stitch), `production/session-state/decisions.md`.
> **Field definitions**: `design/gdd/level-data-definition.md`; defaults from the owning GDDs.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. **Wordless**: no text in skits, cards or bubbles. **Nobody is hurt**: only bonked, floured, snowed on.

---

## 1. Level name and theme

**Pebble's Egg Escape.** Pebble the penguin must carry a snowball egg home to the igloo before the party. Blocks fall as a soft **block flurry** onto a floating glacier broken into floes. Big Sniffles, a yeti with a cold, tooted a party horn full of glitter (a gift he misread as a hanky) and now sneezes avalanches. In the finale the last clear sends Pebble's sled over the final ridge; Sniffles sneezes himself over the horizon, delighted. Keepsake: a snowflake on the wizard's hat. **Lana the alpaca joins at the end of level 10** (friend-join skit, her skill **Stitch** unlocks).

**Quirk: "Glide and quiet."** The campaign's calm, deadpan biome: pale light, slow cloud shadows, one disturbance per level at most (two in 07, 09, 10). Most levels let pieces slide a little, so the player learns to *use* the glide instead of fighting it. Strangeness zig-zags: classic (01) → glide (02) → steer the glide (03) → rolling snow (04) → two calm no-clear breaks (05, 06) → whiteout (07) → short thin-ice sprint (08) → cracked berg (09) → sled finale (10). A small pang sits under the calm: the snowman ring (06) and the first `tear` (07).

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One floe per level (round nest floe, slippery floe, sled lane, snowball field, igloo yard, snow-picture field, blizzard plateau, thin-ice pond, cracked berg, mountain slope), each with an icicle underside (`lore-world.md` §3.3 A) |
| Stage | Busy diorama or clean stage per level, as the story needs; the mountain with Sniffles' cave mouth is the landmark in every backdrop and gets closer (art bible §6) |
| Intro skit | A 3-second wordless mini-scene played during the Countdown (no play time lost). Ends on the hand-off: Pebble looks up, wand glint, first piece |
| Payoff skit | A short skit on every win (≤ 5 s, tap to skip). Biome finale 6 s on first play (replays: last 2 beats). Friend join 4 s + unlock card after the finale |
| Mascot | **Pebble** (Ice only). Tiers 1–2: **helper** (WO06 point half: points at the best cell; no catch, since the catch is Pip's). Tier 3 on: **watcher** (reactions only). Pebble never pranks. Emotes: `dots` (deadpan, signature), `sweat`, `exclaim`, `question`, `heart`, `note`, `sparkle`, `dizzy`, `idea`; never `tear` or `smug` |
| Big Sniffles | Seen on the summit from 03 on (cave mouth, a muffled sneeze that grows louder level by level); boss in 10. His sneezes are the story reason for every glide, roll, whiteout and crack |
| Physics | None (the Meadow's 05 is the only wobble level) |
| Rubber duck | Frozen inside a clear icicle under the floe in 01 and 02 (SE05 angle gem, visible from one low snap angle; tap to collect; no stars attached) |
| Events as Ice events | Wind = **Sneeze Gust** (EV01), Invisible Blocks = **Whiteout** (EV02), Gravity Flip = **Berg Crack** (EV03), Ice = **Slippery Slide** (EV09), Shrinking floor = **Thin Ice** (BL12), Rolling snowball = **Snowball Roll** (SP41, new), Curling flick = **Curling Flick** (CV18) |
| Prototype priority | **03, 04, 08, 10** (★PROTO): the four levels that lean on atoms with no engine proof yet (CV18, SP41, BL12, AR02) |
| Friend | Lana (alpaca knitter). Joins after 10; Stitch is not available in Ice until then; replays of 01–10 offer it (section 8b) |
| Clue (Mizzle) | Strength cap 2 (Mizzle partly seen). One clue per level at most, none in 01, 02, 10 (10 holds the biome flag as set dressing). Beats in section 8a |

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll), `t_piece` 8 s. Speeds are hand-set and match campaign F2 (`0.6 + 0.045 × (tier − 1) + 0.06 × (biome − 1)`, biome 3 → 0.72 to 1.125) within ±0.05. Star times use Scoring & Stars F1 (`t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`) with `t_est = N × t_beat` and `t_beat ≈ 2.67 × A` s (A = active cells per layer; matches the Meadow's 42.7 / 66.7 / 96 s), except where marked "hand-set". Star times are balanced for **no perks and no skills**; Relaxed timing scales them by 1.5 at load.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level (showpiece levels in tiers 7–10: up to 6 non-default). "New" counts only non-default atoms not met earlier in the path. **Assumption**: only Meadow atoms are counted as known, because `design/levels/candy.md` does not exist yet; if Candy teaches any of these first, the "new" counts here only go down. A level mechanic bundle (M1, M2) counts as one idea. Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `m` biome object (snowball), `.` empty; targets `+` / `#` target cell. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Ice atoms (knob defaults used by the levels below)

These are the atoms this biome introduces or leans on. All knobs are tunable defaults. **Status**: D designed, C candidate, Pr proposed (mechanics module), **NEW** = does not exist in the library yet (the writer needed it; section 10).

| Atom | Ice name | Rule as used here | Knobs (default, range) | Status |
|---|---|---|---|---|
| EV09 | **Slippery Slide** (twist `ice_slide`) | When the falling piece first touches down (lock delay starts) it slides `slide_cells` cells along the level's **world-anchored** `slide_dir` (one `try_translate` per cell; blocked = no move). Once per piece. The ghost shows the landing cell and a faint second cell with an arrow, so the player can aim with the slide. It never resets lock delay and never moves locked cubes (so Stitch does not veto it). Counter: **use it** | `slide_dir` per level; `slide_cells` 1 (1–2); `start_after_clears` 0 (0–5; **added param**, used by 10) | C (module says "camera-forward"; see section 10, concern 2) |
| CV18 | **Curling Flick** (`control.verb` add-on) | During lock delay one flick (swipe or key along the slide axis) slides the landed piece along that axis until it is blocked. Over a gap it drops and the flick ends. An arrow ghost shows the end cell | `flick_per_piece` 1 (1–2) | Pr |
| SP41 | **Snowball Roll** (content, living block) | A snowball is a solid, `fills_layer` cube on the top surface. Every `roll_locks` locks it rolls one cell along `slope_dir` if the next column's top is within 1 cell of its height; after each roll it gains one cube on top (up to `snow_max`). Blocked (wall, step of 2 or more, a cube in the way) = it parks and stays as an ordinary block. One lock before each roll a dotted track and a wiggle show where it goes. A clear in its layer pops it (a puff, no hurt). A new ball appears at the high end every `respawn_locks` locks while fewer than `balls_max` exist. Counter: **use it** (free filler) | `roll_locks` 2 (1–4); `snow_max` 3 (1–4); `balls_max` 2 (1–4); `respawn_locks` 8 (0 = never; 0–20); `slope_dir` per level | **NEW** (tags `grid floor stack`; Stitch pauses rolls) |
| BL12 | **Thin Ice** (rule `thin_ice`) | Strips of rim cells crack and are removed in a fixed order. Telegraph: the strip turns blue-white and cracks for `shrink_warn_ms`; then its whole column of cubes pops off with a splash (cubes there are lost, nobody hurt) and the strip leaves the mask. Applied at the next Resolving; a layer that becomes full by shrinking clears normally | `shrink_every_ms` 35 000 (20 000–90 000); `shrink_warn_ms` 3 000 (2 000–5 000); `shrink_steps` 3 (1–4); `shrink_order` [+z, +x, +z]; the footprint never goes under the widest piece (I = 4) | C (knobs defined here; `stack` tag, Stitch holds it) |
| AR02 | **Sled Slope** (M9 Sideways Gravity) | Pieces spawn at the far wall and fall along `travel_dir`; the near wall is the floor. Wind and Slide only on axes perpendicular to `travel_dir` | `travel_dir` −x; length 12; cross-section 6 × 5; `side_view_min_deg` 45 | D (level-specific-mechanics M9) |
| AR13 | Kit box | Pick any kit piece in any order, each once | `kit` 6 | Pr |
| FT12 | Undo and reset | Optional add-on for puzzle levels: unlimited undo, one-tap reset; the level can still be lost | — | Pr |

Meadow atoms reused (all D unless noted): EV01 Wind (`gust`), EV02 Invisible blocks (`fog`), EV03 Gravity flip (`flip`, stack mode), BL05 pre-built tower, M1 build race (GO02 + CL14 + FT02), M2 fill shape (GO03 + CL14), GO04 Survive, BL07 islands, AR09/FT07 (bonus only), SE05 angle gem, WO06 point half, WO09 watcher.

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Pebble | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | ice_01 | Egg Nest | Tuck the egg in | none (classic with the Ice look) | helper | clean, calm | Clear 3 | 5×5, H9 | 8 Std | 0.72 | rescue, 1 | ~3.3 min | 170 / 120 s |
| 02 | ice_02 | Slippery Floe | The egg rolls away | Slide (EV09) | helper | clean, calm | Clear 3 | 6×6, H10 | 8 Std | 0.75 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 03 ★ | ice_03 | Sled Slope | Curling to the nest | Flick (CV18) | watcher | clean | Clear 5 | 4×8 lane, H10 | 8 Std | 0.80 | rescue, 1 | ~7.1 min | 365 / 255 s |
| 04 ★ | ice_04 | Snowball Field | Sniffles' avalanche balls | Snowball Roll (SP41) | watcher | busy | Clear 3 | 7×5, H10 | 8 Std | 0.85 | rescue, 1 | ~4.7 min | 240 / 170 s |
| 05 | ice_05 | Igloo Climb | Build the chimney | build race (M1) + Slide | watcher | clean, tense | Height 9 (cov. 0.6) | 5×5, H12 | 8 Std + Big Cube (w 0.5) | 0.85 | trim | ~4.3 min | 215 / 155 s* |
| 06 | ice_06 | Snowman Picture | Draw the snowman | fill shape (M2) + snowballs | watcher | clean, calm | Shape 39 | 7×8, H8 | I O T L S Tripod Duo Tri-Corner | 0.80 | trim | ~2.4 min | 120 / 85 s* |
| 07 | ice_07 | Whiteout | The squall | Whiteout (EV02) + Slide | watcher | busy, hushed | Clear 4 | 6×6, H10 | 8 Std | 0.95 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 08 ★ | ice_08 | Thin Ice | The pond cracks | Thin Ice (BL12) + Survive | watcher | clean, tense | Survive 140 s | 6×6 → 5×4, H8 | 8 Std | 1.00 (+0.15/min) | rescue, 1 | 2.3 min | 1 / 2 layers |
| 09 | ice_09 | Cracked Berg | The berg flips | Berg Crack (EV03) + Slide, pre-built | watcher | busy | Clear 4 | 6×6, H10 + 2 starter layers | 8 Std | 1.05 | rescue, 1 | ~5 min | 270 / 190 s |
| 10 ★ | ice_10 | Sniffles' Sneeze | Sled escape (boss) | Sled Slope (AR02), Sneeze Gust, Slide | watcher | busiest | Clear 4 | 12 long × 6×5, H12 | 8 Std | 1.10 | rescue, 1 | ~5.3 min | 270 / 190 s |
| B | ice_bonus | Present Puzzle | Wrap the presents | kit box (AR13), undo (FT12) | watcher | clean, calm | Shape 32 | 4×4, H6 | kit: Big Cube ×2, Tripod ×2, Screw-Left ×2 | 0.5 | out of pieces | ≤ 3 min | 120 / 80 s* |
| H1 | ice_h1 | Snowball Fight | Sniffles' sneezes pelt snowballs | Snowball Roll + Sneeze Gust | watcher | busy | Clear 5 | 6×6, H10 | 8 Std | 1.10 | rescue, 1 | ~8 min | 410 / 290 s |
| H2 | ice_h2 | Blind Curling | Curling in a squall | Whiteout + Flick | watcher | clean, tense | Clear 4 | 4×8 lane, H10 | 8 Std | 1.00 | rescue, 1 | ~5.7 min | 290 / 205 s |
| H3 | ice_h3 | Two Floes | One floe is thin | Islands (BL07) + Thin Ice | watcher | clean, tense | Clear 3 per floe | 2 × 4×4, H8 | 8 Std | 0.95 | rescue, 1 shared | ~4.3 min | 220 / 155 s |

★ = prototype priority. \* ★★★ also requires no cube trimmed (Scoring & Stars). Star times use Scoring & Stars F1 except 06, 09, B (hand-set: starter layers or target fill overestimate under F1) and 08 (Survive uses layers, F4). Length notes: 01, 06, 08 and B are short on purpose; the validator's length warning is expected. Long levels (03, 07, 10) never touch each other; the finale follows a medium level.

**Budget table** (F1 count rule; Meadow atoms counted as known):

| Level | Non-default atoms | nd (cap 4; 6 for 07–10) | New (cap 2) |
|---|---|---|---|
| 01 | none | 0 | 0 |
| 02 | EV09 | 1 | 1 (EV09) |
| 03 | CV18 | 1 | 1 (CV18) |
| 04 | SP41 | 1 | 1 (SP41) |
| 05 | M1 bundle, EV09 | 2 | 0 |
| 06 | M2 bundle, SP41 | 2 | 0 |
| 07 | EV02, EV09 | 2 | 0 |
| 08 | BL12, GO04 | 2 | 1 (BL12) |
| 09 | BL05, EV03, EV09 | 3 | 0 |
| 10 | AR02, EV01, EV09 | 3 | 1 (AR02) |
| B | AR13, M2 bundle, FT07, FT12 | 4 | 2 (AR13, FT12) |
| H1 | SP41, EV01 | 2 | 0 |
| H2 | EV02, CV18 | 2 | 0 |
| H3 | BL07, BL12 | 2 | 0 |

**Hard track (decision, same as Meadow).** `ice_bonus` is tier 11 (unlocks at 20 ice stars). The remixes are **tiers 12–14** (`ice_h1`–`h3`); all three open when `ice_10` is finished. Neither the bonus nor the remixes count toward the next biome's star gate. Stars still pay points as usual. The next biome (Underwater) opens with 15 of 30 ice stars after 10.

**Puzzle levels** (campaign rule 15: 1–2 per biome): the Present Puzzle (bonus, a `kit` puzzle) is the main one; 06 Snowman Picture is a calm shape puzzle with no fixed list (it can be failed only by never filling the picture, never by a top-out). No `fixed_list` level on the main path, as in the Meadow.

## 3. Layout overview

```text
01 nest floe   02 slippery floe  03 sled lane    04 snowball field   05 igloo yard
#####          ######            ####            #######             #####
#####          ######            ####            #######             #####
#####          ######            ####            #######             #####
#####          ######            ####            #######             #####
#####          ######            ####            #######             #####
               ######            ####
                                 ####            (balls roll <- )    (slide down)
                                 ####
06 snow-picture field    07 blizzard plateau   08 thin-ice pond (shrinks)   09 cracked berg
.  .  .  #  .  .  .      ######                ######  -> ##### -> #####    ######
.  .  #  #  #  .  .      ######                ######     ##### -> ####     ######
.  .  #  #  #  .  .      ######                ######     #####             ######
.  .  #  #  #  .  .      ######                ######                       ######
.  #  #  #  #  #  .      ######                ######                       ######
.  #  #  #  #  #  .      ######                ######                       ######
#  #  #  #  #  #  #
#  #  #  #  #  #  #
10 mountain slope (sled runs left; pieces fall toward x = 0)
x=11 .............. x=0
     6 x 5 slices, 12 long
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the Ice biome, plays the friend join (Lana, Stitch unlocks), and the next biome opens with 15 of 30 stars.
- **Optional**: ★★★ times on every level; the rubber duck in 01–02; the bonus Present Puzzle (20 stars); hard-track remixes H1–H3 (after 10); replays of any level with Stitch (after Lana joins).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                                  #     #
      |                           #     #  #  # 
  mid |           #     #                  #  #  
      |        #  #  #  #  #  #     #     #  #  #
  low |  #  #  #  #  #  #  #  #  #  #  #  #  #  #
      +-01-02-03-04-05-06-07-08-09-10--B
        learn  verb snow  break  fog  sprint flip  FINALE
```

Zig-zag, not a ramp: classic (01) → glide (02) → steer (03) → rolling snow (04) → two no-clear-fail breaks (05 build, 06 picture) → whiteout (07) → short thin-ice sprint (08) → the flip (09) → sled finale (10). Short and long alternate (campaign rule 12): short 01, 06, 08; long 03, 07, 10. No two pressure peaks in a row before the finale: the Snowman Picture and Thin Ice sit on either side of the longest, foggiest level (07).

---

## 6. Level specs (encounter lists, sketches, beats)

Each level lists: story card, stage, skits (**I** intro ≤ 3 s, **P** payoff ≤ 5 s, **M** Mizzle clue ≤ 1.5 s inside the payoff or the backdrop, **R** live reactions ≤ 1 s each), recipe, encounters, diagram, how it plays and teaches, readability notes, lighting preset, music id, level JSON sketch. Skits are written for the `/team-narrative` skit pass; the beats are wordless poses, props and emote ids (`emote-bubbles.md`).

### 01 Egg Nest

**Story card.** Pebble's snowball egg needs a warm nest before the long walk home. Every clear tucks a layer of snow around it; three layers and it is snug. · **Pebble: helper** (points at the emptiest cell; no catch).
**Stage**: clean, calm; a round nest floe, the mountain small in the far backdrop. **I**: Pebble waddles up with the egg on its feet, bows to the camera, slips, stays upright (`dots`), sets the egg down and looks up. **P**: three rings of snow lift around the egg like a blanket; the egg wobbles and settles; Pebble pats it (`heart`) and bows again. **M**: none (slot 01). **R**: warning, Pebble covers its beak with a flipper (`sweat`); each clear, a small bow (`sparkle`).

```text
Recipe: BL01 (5×5, H9) · AR01 · CV01 (all axes) · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck · WO06 point
One sentence: "Fill a whole layer and it clears."
```
**Encounters**: none (pure classic). Pieces: all 8 Standard. A re-teach, because the Meadow taught the controls; the only novelty is the Ice look and Pebble's pointing. `T_level` 200. Atoms new to the player: none.

```text
top-down 5×5     side (z = 2)
#####            12 . . S . .   spawn zone
#####             9 ==========  danger line
##S##             :
#####             0 . . . . .   the nest floe
#####
```
**How it plays and teaches**: (1) a plain I drifts down; Pebble points at a corner. (2) The first layer clears in about 5 pieces: a snow ring lifts around the egg, a soft chime. (3) 3D pieces arrive; the controls are known, so the level checks the player remembers Turn / Flip / Roll. (4) The third clear closes the nest. It teaches only the biome's *tone*: quiet, slow, deadpan.
**Wacky test**: surprising, a bow after every clear; silly, the egg wobbles when a piece lands near it; funny failure, Pebble flops belly-first into the snow (stays dignified); big moment, the egg disappearing under the snow blanket.
**Readability**: board tiles a step darker and greyer than the pieces (visual-direction §3.2); the egg and nest sit at the rim, never inside the one-cube margin.
**Light**: cool dawn (A, "blue dawn"). **Music id**: `ice_01`.

```json
{ "schema": 1, "id": "ice_01", "biome": "ice", "tier": 1,
  "board": { "width": 5, "depth": 5, "h_play": 9 },
  "knobs": { "fall.g0": 0.72, "goal.warnings_max": 1 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "mascot_hint", "params": {} }, { "id": "angle_gem", "params": { "where": "under_island" } } ],
  "stars": { "t2": 170000, "t3": 120000 }, "music": "ice_01",
  "story": { "title_key": "level.ice_01.title", "premise_key": "level.ice_01.premise", "mascot_role": "helper", "icon": "egg" } }
```

---

### 02 Slippery Floe

**Story card.** The floe is glass. Every piece slides one cell the moment it lands, and Pebble's egg rolls off whenever Pebble's feet slip. Use the slide to park pieces against the bank. · **Pebble: helper** (points at the cell the slid piece ends on).
**Stage**: clean, calm; a bright, glassy floe with a low snow bank on the near edge. **I**: Pebble steps on, its feet fly out, the egg rolls away; Pebble belly-slides after it and stops against the bank (`dots`). **P**: the egg rolls into a snow cup the clears built; Pebble sits on the rim, slides gently to the bottom anyway (`note`). **M**: none (slot 02). **R**: a piece slides, Pebble leans with it; a warning, Pebble wobbles (`sweat`).

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV09 Slippery Slide · SE05 duck · WO06 point
One sentence: "Pieces slide one step when they land."
```
**Encounters**: **Slippery Slide** (new): `slide_dir` +z (toward the viewer's bank), `slide_cells` 1, every piece. The ghost shows the slid cell with a faint arrow. The near edge is the island wall, so pieces stop there: the slide is a free move toward a known wall. Atom new to the player: EV09. Pieces: 8 Standard. `T_level` 288.

```text
top-down 6×6 (slide ↓ to +z)     side (z = 2)
######                           13 . . S S . .   spawn zone
######                           10 ============  danger line
##S###                            :
######                            0 . . . . . .   glass floor (slide →)
######
######  ↓ ↓ ↓  bank
```
**How it plays and teaches**: (1) the first piece lands, slides one cell with a soft squeak, and the ghost already predicted it. (2) The player discovers building from the bank, so pieces slide *into* gaps instead of away. (3) A piece slid onto the edge of a gap is a mistake the ghost warned about. (4) Three layers; the third clear is quieter because the slide is now a habit. It teaches "the ghost shows where the glide ends", the base for 03, 05, 07, 09, 10.
**Wacky test**: surprising, a piece moves after it lands; silly, squeaky slides and Pebble leaning; funny failure, a piece skates off its spot and bonks the bank; big moment, a long slide that fills the last gap.
**Readability**: the slide arrow is world-anchored on the floor and stays correct after rotate-view; the ghost always draws the landing and the slid cell (two tints, never confusable).
**Light**: cool morning (A to B). **Music id**: `ice_02`.

```json
{ "schema": 1, "id": "ice_02", "biome": "ice", "tier": 2,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 0.75 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "ice_slide", "params": { "slide_dir": "+z", "slide_cells": 1 } },
             { "id": "mascot_hint", "params": {} }, { "id": "angle_gem", "params": { "where": "under_island" } } ],
  "stars": { "t2": 245000, "t3": 175000 }, "music": "ice_02",
  "recipe": { "context": "campaign", "atoms": ["BL01","AR01","CV01","CL01","CO01","GO01","FT01","EV09","SE05","WO06"],
              "story": { "premise": "The floe is glass and every piece slides.", "mascot_role": "helper" } } }
```

---

### 03 Sled Slope ★PROTO

**Story card.** A long sled lane runs down to the nest. Slide the landed piece with a flick, like a curling stone, but a gate of two ice posts is in the way. Wide pieces stop in front of it. · **Pebble: watcher** (rides a sled down the side of the lane; cheers).
**Stage**: clean; a long white lane in cut-away, two ice posts, seal pups on a drift. **I**: Pebble sits on a sled at the top, egg on its lap; a seal pup pushes it; it slides, spins once and stops by the gate (`dots`). **P**: the sled glides through the gate into the nest at the end; Pebble sweeps the last bit of snow with a tiny broom (`note`). **M ★ (backdrop, static)**: a lone line of small boot prints leads from the lane up into the mountain (strength 1). **R**: a good flick, Pebble raises both flippers (`sparkle`); a piece blocked by the posts, a gentle "oof".

```text
Recipe: BL01 (4 wide × 8 deep lane, H10, 2 starter posts) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · CV18 Curling Flick
One sentence: "Flick a landed piece to slide it."
```
**Encounters**: no passive slide in this level (EV09 is off), so the flick is the only glide and the one new idea. **Curling Flick** (CV18, Proposed): one flick per piece during lock delay, along ±z, until blocked; over a gap the piece drops and the flick ends. **Gate**: two starter stones at (0,0,5) and (3,0,5) leave a 2-wide gap; a piece wider than 2 in x stops at z 4. The stones are starter blocks in the floor layer (they clear with it). Wall at z = 7 is the lane end. Atom new to the player: CV18. `T_level` 427.

```text
top-down 4×8 (flick ↓ to +z)    starting layer 0         side (x = 0)
####   z0                       ....   z0                13 . . . . S . . .   spawn zone
####   z1                       ....                     10 =================  danger line
####   z2                       ....                      :
##S#   z3  (spawn x1,z3)        ....                      0 . . . . . # . |   post at z5, wall at z7
####   z4                       ....
####   z5  gate: posts x0, x3   #..#
####   z6                       ....
####   z7  lane end             ....
```
**How it plays and teaches**: (1) the first pieces land near the spawn row; a hint arrow shows the flick direction and the player flicks a piece to the wall. (2) A piece tilted wide stops in front of the gate: the lesson is "turn it narrow first". (3) Flicks pack a layer end to end; the gate stones fill their layer cells for free. (4) Five clears; late clears need a flick over a gap, which drops the piece into a hole. It teaches: *you can steer a piece after it lands*. Fallback if CV18 is not accepted: use EV09 with `slide_dir` +z and a 1-cell slide (the Meadow's 03 pattern); the gate and lane stay.
**Wacky test**: surprising, you shove the piece after it lands; silly, the sled and seal pups; funny failure, a flicked piece clinks the post and spins; big moment, a flick that threads the gate and fills the last gap.
**Readability**: the flick arrow ghost ends on the cell the piece will reach; the posts are painted ice-blue stone (not cube-gloss) so they never read as playable pieces.
**Light**: cool morning (A to B). **Music id**: `ice_03`.

```json
{ "schema": 1, "id": "ice_03", "biome": "ice", "tier": 3,
  "board": { "width": 4, "depth": 8, "h_play": 10, "spawn_anchor": { "x": 1, "z": 3 },
             "starting_contents": { "layers": { "0": ["....","....","....","....","....","#..#","....","...."] } } },
  "knobs": { "fall.g0": 0.80, "control.verb": "curling_flick", "control.flick_per_piece": 1 },
  "goal": { "type": "clear", "N": 5 },
  "rules": [],
  "stars": { "t2": 365000, "t3": 255000 }, "music": "ice_03",
  "recipe": { "context": "campaign", "atoms": ["BL01","AR01","CV18","CL01","CO01","GO01","FT01"],
              "story": { "premise": "Flick the stone through the gate to the nest.", "mascot_role": "watcher" } } }
```

---

### 04 Snowball Field ★PROTO

**Story card.** A far sneeze shakes loose snowballs on the slope. They roll down toward the bank, growing as they go. Use them as free filler or leave a gap in their path. · **Pebble: watcher** (hops over each ball).
**Stage**: busy; a wide field, Sniffles' cave mouth on the summit, small trees of snow. **I**: a muffled sneeze; a snowball starts rolling; Pebble hops over it and the egg bobbles (`exclaim`). **P**: the balls roll into a neat ring around the egg: a snow fort; Pebble peeks out of its door (`heart`). **M (backdrop, static)**: a snowman stands at the rim wearing a hat with a mismatched-scrap band (strength 1). **R**: a ball rolls, Pebble hops; a ball lands where the player wanted a gap, a single deadpan blink (`dots`).

```text
Recipe: BL01 (7×5, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SP41 Snowball Roll [new]
One sentence: "Snowballs roll down the slope and fill cells."
```
**Encounters**: **Snowball Roll** (SP41, new): two balls start at (6,0,1) and (6,0,3); `slope_dir` −x; `roll_locks` 2; `snow_max` 3; `balls_max` 2; `respawn_locks` 8. A ball grows one cube on top after every roll. The wall at x = 0 is the drift where balls park. A ball is a free filler (it fills its cell), so it can complete a layer; a tall parked ball (3 cubes) raises a column the player must build around. Atom new to the player: SP41. `T_level` 280.

```text
top-down 7×5 (slope ←)   side (z = 1)
x→ 0123456               13 . . . S S . .   spawn zone
z0 .......               10 ==============  danger line
z1 ......m  <- ball       :
z2 ..S....                1 . . . . . . m   ball stage 1
z3 ......m  <- ball       0 | . . . . . m   drift wall at x = 0
z4 .......
```
**How it plays and teaches**: (1) the track is drawn on the snow; the first ball wiggles, then rolls one cell. (2) The player sees the ball grow and park at the drift, filling a cell for free. (3) A ball rolling toward an unfinished layer is an opportunity; one rolling onto the player's best gap is a mistake the dotted track showed a lock early. (4) Three clears; each clear pops the balls in that layer with a puff. It teaches: *living blocks move on their own; plan around the dotted line*.
**Wacky test**: surprising, things roll on their own; silly, balls with sleepy faces that blink as they grow; funny failure, a ball rolls into the one gap you wanted and sits there; big moment, a three-cube ball parking against the drift with a thump.
**Readability**: the dotted track and a wiggle appear one lock before each roll; balls are matte white with a face, never glossy (so they never read as playable pieces); the rolling rule is the level's only disturbance.
**Light**: glitter morning (B). **Music id**: `ice_04`.

```json
{ "schema": 1, "id": "ice_04", "biome": "ice", "tier": 4,
  "board": { "width": 7, "depth": 5, "h_play": 10,
             "starting_contents": { "layers": { "0": [".......","......m",".......","......m","......."] } } },
  "knobs": { "fall.g0": 0.85 },
  "goal": { "type": "clear", "N": 3 },
  "rules": [ { "id": "snowball", "params": { "slope_dir": "-x", "roll_locks": 2, "snow_max": 3, "balls_max": 2, "respawn_locks": 8 } } ],
  "stars": { "t2": 240000, "t3": 170000 }, "music": "ice_04",
  "recipe": { "context": "campaign", "atoms": ["BL01","AR01","CV01","CL01","CO01","GO01","FT01","SP41"],
              "story": { "premise": "Sniffles' sneeze sends snowballs rolling down.", "mascot_role": "watcher" } } }
```

---

### 05 Igloo Climb

**Story card.** Pebble's igloo needs a chimney so the egg can see the party lights. Stack to the chimney sign; nothing clears, too high pops off, and bricks slip when they land. · **Pebble: watcher** (climbs a ladder beside the stack).
**Stage**: clean, tense; an igloo yard, a big sky. **I**: Pebble holds up the egg to look over the igloo wall; the egg is too short to see the party lights, and Pebble draws a chimney in the snow (`question`). **P**: the last brick tops the chimney; a smoke ring puffs out; Pebble tucks in and shuts the door (`note`). **M ★ (payoff, 1.5 s)**: small hands count on fingers above a snowdrift behind the igloo and stop at one (strength 2). **R**: a slip, Pebble ducks; a Big Cube lands, the stack thunks, Pebble `exclaim`.

```text
Recipe: BL01 (5×5, H12) · AR01 · CV01 · GO02 (H 9, coverage 0.6) + FT02 trim + CL14 [M1 build race] · EV09 Slippery Slide
One sentence: "Build up to the sign; nothing clears."
```
**Encounters**: **Slippery Slide** (known from 02): `slide_dir` +z, 1 cell. Trim: cubes at or above layer 12 pop off; the level never fails. Pieces 8 Standard + Big Cube (w 0.5, an ice block). Atoms new to the player: none. Length from Level-Specific Mechanics F2, scaled from Meadow 05 (Height 10 ≈ 283 s): Height 9 ≈ 255 s.

```text
top-down 5×5 (slide ↓)   side (z = 2)
#####                    15 . . S . .   spawn zone
#####                    12 ===========  danger line (trim)
##S##                     8 - - - - -   sign: layer 8 must be ≥ 60% full (15 of 25)
#####                     :
#####                     0 . . . . .
```
**How it plays and teaches**: (1) the floor fills; full layers glow and stay. (2) The slide pushes bricks toward the near wall; build from the wall and everything lines up. (3) A Big Cube adds two layers in one drop but slides as a block, so the player places it a cell short. (4) Layer 8 reaches 15 cubes. It teaches: *the slide is also a tool for a tall tower*, and gives the player a calm break before the picture.
**Wacky test**: surprising, full layers stay; silly, the Big Cube thunks and slides with a squeak; funny failure, trimmed cubes pop off like popcorn and land in a snowbank; big moment, the smoke ring from the chimney.
**Readability**: the sign and the height meter stay the only gold on screen; the slide arrow stays on the floor. ★★★ also needs no cube trimmed.
**Light**: glitter morning (B). **Music id**: `ice_05`.

```json
{ "schema": 1, "id": "ice_05", "biome": "ice", "tier": 5,
  "board": { "width": 5, "depth": 5, "h_play": 12 },
  "pieces": { "weights": { "big_cube": 0.5 } },
  "knobs": { "fall.g0": 0.85, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 9, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": {} }, { "id": "ice_slide", "params": { "slide_dir": "+z", "slide_cells": 1 } } ],
  "stars": { "t2": 215000, "t3": 155000 }, "music": "ice_05" }
```

---

### 06 Snowman Picture

**Story card.** Pebble draws a snowman on the snowfield and the clears fill it in. Two snowballs roll into the base for free. · **Pebble: watcher** (stamps the picture's outline with its feet).
**Stage**: clean, calm; a flat snowfield and, in the far backdrop, a mid-ground ledge with a ring of snowmen holding cups (ambient). **I**: Pebble waddles in a snowman outline with its flippers, then steps back to admire it (`idea`). **P**: the snowman stands up, scarf and all; Pebble hands it a cup. **M ★ (payoff, last 1.5 s)**: the backdrop ledge lights up: a ring of snowmen, each holding a cup, and one empty chair (strength 2). No bubble. **R**: a petal-like row of snow lights as each outline cell fills (`sparkle`); on a trim, Pebble shrugs.

```text
Recipe: BL01 (7×8, H8) · AR01 · CV01 · GO03 (39 cells) + FT02 trim + CL14 [M2 fill shape] · SP41 Snowball Roll (2 balls, no respawn)
One sentence: "Cover the snowman outline."
```
**Encounters**: two snowballs start at (1,0,0) and (5,0,0), `slope_dir` +z, `roll_locks` 3, `snow_max` 2, `respawn_locks` 0. They roll to the front wall and park on base cells (free filler). Pieces I, O, T, L, S, Tripod, Duo, Tri-Corner. Atoms new to the player: none (SP41 known from 04, M2 from the Meadow). `T_level` hand-set.

```text
layer 0 (34)    layer 1 (5)    start (m = ball)   side (x = 3)
...+...         .......        .m...m.            8 ================  danger line (trim)
..+++..         .......        .......             :
..+++..         .......        .......             1 . . . . + . + +   scarf z3, buttons z5, z6
..+++..         ..+++..        .......             0 + + + + + + +   the base row on the snowfield
.+++++.         .......        .......
.+++++.         ...+...        .......
+++++++         ...+...        .......
+++++++         .......        .......
```
**How it plays and teaches**: (1) outlines glow; the first pieces fill the base row by row. (2) The balls roll toward the front and park on base cells, so the base starts filling itself. (3) Duo and Tri-Corner fill the mid-ball edge; the scarf and buttons are the last raised cells. (4) The final button snaps in and the snowman stands. It teaches *picture building* again (Meadow 06) with snow that helps.
**Wacky test**: surprising, painting, not clearing; silly, snow cells have tiny shining sparkles; funny failure, trimmed cubes roll away down the field; big moment, the whole snowman standing up and tipping its hat.
**Readability**: target cells are tinted pale gold-cream, balls are matte white; the clue ledge sits in the far backdrop, never near the grid.
**Light**: pale noon (B, overcast). **Music id**: `ice_06`.

```json
{ "schema": 1, "id": "ice_06", "biome": "ice", "tier": 6,
  "board": { "width": 7, "depth": 8, "h_play": 8,
             "starting_contents": { "layers": { "0": [".m...m.",".......",".......",".......",".......",".......",".......","......."] } } },
  "knobs": { "fall.g0": 0.80, "goal.top_out": "trim" },
  "goal": { "type": "shape",
            "target_shape": { "layers": {
              "0": ["...+...","..+++..","..+++..","..+++..",".+++++.",".+++++.","+++++++","+++++++"],
              "1": [".......",".......",".......","..+++..",".......","...+...","...+...","......."] } } },
  "pieces": { "shapes": ["I","O","T","L","S","Tripod","Duo","Tri-Corner"] },
  "rules": [ { "id": "fill_shape", "params": {} },
             { "id": "snowball", "params": { "slope_dir": "+z", "roll_locks": 3, "snow_max": 2, "balls_max": 2, "respawn_locks": 0 } } ],
  "stars": { "t2": 120000, "t3": 85000 }, "music": "ice_06" }
```

---

### 07 Whiteout

**Story card.** A squall rolls off the summit and the stack vanishes in white. Clears blow the snow off for a moment; the landing ghost still shows where pieces slide to. · **Pebble: watcher** (peeks out of the white).
**Stage**: busy but hushed; backdrop fog density up, soft snow in the far planes (the board stays crisp). **I**: a wall of white rolls in; the egg disappears; Pebble pats the empty air (`question`). **P**: the squall lifts to reveal the mid-ground ledge; the ring of snowmen with cups. **M ★ (payoff, 1.5 s)**: the first `tear`: a drip falls in the snow next to the empty chair and a `tear` bubble rises from behind a snowman. Nobody is seen. Pebble, in the foreground, looks that way and tilts its head (`question`). **R**: the fog closes, Pebble's flipper tips just show (`dots`); a clear, the fog blows off and Pebble bows (`sparkle`).

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV02 Whiteout · EV09 Slippery Slide
One sentence: "Your stack fades; remember it."
```
**Encounters**: **Whiteout** (EV02 `fog`): `visible_ms` 3 000, `fade_ms` 1 200, `invisible_alpha` 0.12, `reveal_ms` 700 on each clear. **Slippery Slide** (EV09): `slide_dir` +z, 1 cell. The ghost, the height line and the falling piece never fade. Pieces 8 Standard. Atoms new to the player: none. `T_level` 384. Differs from the Meadow's 07: no starter layers and no fog ghost, but the floor slides, so a "remembered" stack also has to be remembered with its glides.

```text
top-down 6×6 (slide ↓)   side (z = 2): stack fading
######                   13 . . S S . .   spawn zone
######                   10 ============  danger line
##S###                    :
######                    2 . . # # . .   fades after 3 s
######                    1 . # # # # .
######                    0 # # # # # #
```
**How it plays and teaches**: (1) the first stack is visible for 3 s, then fades; the player learns the rhythm. (2) Slides make the memory harder; the ghost's two tints give the true landing. (3) A clear blows the snow away for 0.7 s: a window to re-read the stack. (4) The last clear lifts the whole squall. It teaches: *plan across the fade; use clears as a re-read*, the base of 09.
**Wacky test**: surprising, the stack vanishes; silly, Pebble's flipper tips sticking out of the white; funny failure, a piece lands "on nothing" that was something; big moment, the squall lifting off at the last clear.
**Readability**: the board, ghost and height line stay crisp; only locked cubes fade (alpha 0.12, never fully transparent); backdrop fog does not cover the clue ledge until the payoff reveals it.
**Light**: blizzard grey (I). **Music id**: `ice_07`.

```json
{ "schema": 1, "id": "ice_07", "biome": "ice", "tier": 7,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 0.95 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "fog", "params": { "visible_ms": 3000, "fade_ms": 1200, "invisible_alpha": 0.12, "reveal_ms": 700 } },
             { "id": "ice_slide", "params": { "slide_dir": "+z", "slide_cells": 1 } } ],
  "stars": { "t2": 325000, "t3": 230000 }, "music": "ice_07" }
```

---

### 08 Thin Ice ★PROTO

**Story card.** The pond Pebble must cross is thin. Every 35 seconds a strip of ice cracks and falls away, and the floe gets smaller. Hold on until the sun comes out at 2:20. · **Pebble: watcher** (tiptoes in place on the shrinking middle, egg held high).
**Stage**: clean, tense; a pale pond under a low sun, a crack pattern spreading from the edge. **I**: Pebble steps on the pond; a crack zigzags out; Pebble freezes with the egg above its head (`sweat`). **P**: the ice refreezes in a sparkle and the sun comes out; Pebble slides across the new floor on its belly. **M ★ (payoff, 1.5 s)**: a violet cuff straightens the empty chair at the snowman ring in the backdrop, then slips back behind a snowman (strength 2). **R**: a crack warning, Pebble hops (`exclaim`); a clear, a quick bow.

```text
Recipe: BL01 (6×6, H8) · AR01 · CV01 · GO04 (140 s, ramp_per_min 0.15) · FT01 (1) · CL01 + CO01 · BL12 Thin Ice [new]
One sentence: "Rim ice cracks away; the floe shrinks."
```
**Encounters**: **Thin Ice** (BL12): `shrink_every_ms` 35 000, `shrink_warn_ms` 3 000, `shrink_steps` 3, `shrink_order` [+z, +x, +z]: the footprint goes 6×6 → 6×5 → 5×5 → 5×4 (A 36 → 30 → 25 → 20). Cubes on a removed strip pop off with a splash. A layer that becomes full by shrinking clears (a bonus). Stars by layers cleared (Scoring F4): ★★ 1, ★★★ 2 with no warning. Atom new to the player: BL12.

```text
top-down 6×6 (strip order 1, 2, 3)    side (z = 2)
#####1  strip 1 (+z edge, at 35 s)    11 . . S S . .   spawn zone
#####1                                 8 ============  danger line (only 8 layers)
##S##1                                 :
#####1                                 0 # # # # # #   cracks along the rim
#####1
222223  strip 2 (+x edge, at 70 s), strip 3 (+z edge, at 105 s)
```
**How it plays and teaches**: (1) a calm first 30 s on the full floor. (2) The first crack: blue-white strip and a tick; the player moves the stack away from the rim. (3) Later cracks cost fewer cubes if the rim stays low; a full layer when the strip falls clears. (4) The sun dial fills at 140 s. It teaches: *keep your tower in the middle and plan for the floor to shrink*.
**Wacky test**: surprising, the floor shrinks under you; silly, tiny cracking sounds like a glass tapping; funny failure, a perfect edge piece vanishes with a splash; big moment, the refreeze sparkle.
**Readability**: the crack telegraph is a hazard-orange triangle plus stripes on the strip (the only orange on screen); the strip order is shown as one, two and three pale ticks on the rim edge (no digits).
**Light**: pale noon with backdrop haze (B/I-lite). **Music id**: `ice_08`.

```json
{ "schema": 1, "id": "ice_08", "biome": "ice", "tier": 8,
  "board": { "width": 6, "depth": 6, "h_play": 8 },
  "knobs": { "fall.g0": 1.00, "fall.ramp_per_min": 0.15 },
  "goal": { "type": "survive", "T": 140 },
  "rules": [ { "id": "thin_ice", "params": { "shrink_every_ms": 35000, "shrink_warn_ms": 3000, "shrink_steps": 3, "shrink_order": ["+z","+x","+z"] } } ],
  "stars": { "s2": 1, "s3": 2 }, "music": "ice_08" }
```

---

### 09 Cracked Berg

**Story card.** Sniffles' cough cracks the berg, and the whole stack flips over. Hanging icicles become the floor and buried holes pop to the top. · **Pebble: watcher** (clings to an icicle).
**Stage**: busy; a pale blue berg with crack lines that race across it, a cloud bank, Sniffles' cave very close. **I**: a crack zigzags across the berg; Sniffles coughs; the berg tilts and Pebble hangs by one flipper (`exclaim`). **P**: the berg rights itself; Pebble drops on its feet, the egg lands on its head (`dots`). **M ★ (payoff, 1.5 s)**: a droopy hat wrapped in a big scarf hurries off between two ice blocks at the rim (`sweat`). Back view only. (strength 2). **R**: a crack line appears, Pebble grabs its hat; the flip, Pebble tumbles over (`dizzy`).

```text
Recipe: BL05 (6×6, H10, 2 starter layers) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV03 Berg Crack · EV09 Slippery Slide
One sentence: "Down becomes up, and the floor is slippery."
```
**Encounters**: **Berg Crack** (EV03 `flip`, stack mode): `flip_every_layers` 2, `flip_every_ms` 70 000, `flip_warn_ms` 2 000, `flip_max` 2; the stack turns over in place and the island stays (twist-library rule 12). **Slippery Slide** (EV09): `slide_dir` +z. Starter layers have holes that become the top after the first flip. Atoms new to the player: none. Hand-set times, because the starter layers make F1 overestimate.

```text
layer 0     layer 1     side (z = 2), before -> after a flip
######      ##.###      13 . . S S . .   . . S S . .   spawn stays
#.####      ######      10 ============  ============  danger line stays
######      #.####       :                 :
####.#      ######       1 # . # # # #     # # # . # #   old floor is now the top
##.###      ####.#       0 # # # . # #     # . # # # #   old top is now the bottom
######      ######
```
**How it plays and teaches**: (1) the starter holes need filling; the slide helps park pieces at the holes. (2) The crack lines race across; the flip warning shows arrows curling over the stack. (3) After the flip the buried holes are on top: fill them. (4) A second flip arrives around 140 s unless the fourth clear comes first. It teaches: *keep the top flat so the flip doesn't make a mess*; the same lesson as Topsy-Turvy, with the slide on top.
**Wacky test**: surprising, gravity flips; silly, the berg's flip is staged as the cracks racing and the whole stack going "whump"; funny failure, the stack lands on its head and wobbles; big moment, the flip tumble.
**Readability**: only the stack turns (the island, floor, spawn and controls stay put); crack lines are staging on the island body and backdrop, never on the grid. The flip countdown ring and arrows are the level's only hazard orange.
**Light**: pale noon (B to C). **Music id**: `ice_09`.

```json
{ "schema": 1, "id": "ice_09", "biome": "ice", "tier": 9,
  "board": { "width": 6, "depth": 6, "h_play": 10,
             "starting_contents": { "layers": {
               "0": ["######","#.####","######","####.#","##.###","######"],
               "1": ["##.###","######","#.####","######","####.#","######"] } } },
  "knobs": { "fall.g0": 1.05 },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "flip", "params": { "flip_every_layers": 2, "flip_every_ms": 70000, "flip_warn_ms": 2000, "flip_max": 2, "flip_mode": "stack" } },
             { "id": "ice_slide", "params": { "slide_dir": "+z", "slide_cells": 1 } } ],
  "stars": { "t2": 270000, "t3": 190000 }, "music": "ice_09" }
```

---

### 10 Sniffles' Sneeze (boss: Big Sniffles) ★PROTO

**Story card.** Pebble races down the mountain on a sled with the egg while Sniffles sneezes snow at the whole run. Phase 1: sneeze gusts push the pieces sideways. Phase 2: the snow turns slick and pieces slide too. The last clear sends the sled over the final ridge. · **Boss**: Big Sniffles; Pebble cheers from the sled (watcher).
**Stage**: busiest; a mountain slope seen from the side, Sniffles' summit with the horn, a sled track curving below, ridges ahead. Landscape preferred (sideways gravity). **I (boss intro, 3 s)**: 0.0–1.5 Sniffles inhales glitter from the ribboned horn, rears back (`exclaim`)... 1.5–2.0 ...and sneezes: a wall of snow tumbles toward Pebble's egg. 2.0–3.0 Hand-off: Pebble, sled ready, looks up at the wizard; glint; first piece. **P (finale payoff, 6 s; [R] = beats 4–5)**: 0.0–1.5 last clear: the sled jumps the last ridge with Pebble and the egg aboard. 1.5–3.0 it lands home; Pebble steps off and bows (`dots`); keepsake pop: the snowflake. 3.0–4.0 the egg wobbles; Pebble pats it (`heart`). 4.0–5.0 [R] on the summit, Sniffles toots the horn again and sneezes himself up and over the horizon (`sparkle`, delighted). 5.0–6.0 [R] across the glacier a yarn trail leads into the snowman ring: hand-off to the friend join. **M**: none in the payoff (the horn's violet flag is set dressing). **R**: each sneeze wind-up, Pebble holds on to the sled (`exclaim`); a clear, the sled lurches forward one ridge; on a warning Pebble hugs the egg.

```text
Recipe: BL01 + AR02 Sideways Gravity (travel −x; 12 long × 6×5 cross-section, H12) · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV01 Sneeze Gust · EV09 Slippery Slide (after clear 2)
One sentence: "Snow pushes your pieces; then the snow gets slick."
```
**Encounters**:
- **Sled Slope** (AR02, M9): pieces fall along −x toward the near wall (the floor); slices are 6 × 5 planes. New to the player: AR02.
- **Sneeze Gust** (EV01 `gust`): +z (across the slope, perpendicular to `travel_dir`), every 9 s ± 2 s, 1 cell, 1 s warning (Sniffles' head tips back, "ahh").
- **Slippery Slide** (EV09): `slide_dir` +z, 1 cell, `start_after_clears` 2. Phase 2 starts after the 2nd clear: Sniffles' glitter dust turns the snow slick and he sneezes more. No new atom is needed beyond the `start_after_clears` param (EV13 Halftime swap was considered and not used, as the Meadow found).
- **Escape feel**: the danger line is "the avalanche front"; each clear lurches the sled one ridge forward (staging only).
- Sniffles cheers when you use a warning and sulks on each clear. Pieces 8 Standard.

```text
top-down along x (travel ←), cross-section 6 (z) × 5 (y) per slice, 12 long
x=11 (spawn end)                                     x=0 (floor wall)
S S . . . . . . . . . . |   spawn zone at x = 11; danger line = H_play measured from the x = 0 floor
. . . . . . . . . . . . |   gust and slide push along +z (down this page)
. . . . . . . . . . . . |
12 cells long; a clear = a full 6×5 plane perpendicular to x
```
**How it plays and teaches**: (1) pieces slide down the slope to the left; the first sneeze pushes one piece across. (2) Phase 1: use the gust; build from the +z wall so the push helps. (3) The 2nd clear flips the snow slick: pieces now also slide one step after landing. (4) The 4th clear sends the sled over the ridge. It teaches the whole biome in one run: *use the push, use the slide, plan across the gaps*.
**Wacky test**: surprising, pieces come down a slope; silly, Sniffles' huge pre-sneeze "ahh" and the glitter in his nose; funny failure, he dances on the summit when you use a warning; big moment, the last ridge jump and Sniffles' sneeze over the horizon.
**Readability**: camera snaps limited to angles ≥ 45° off `travel_dir` (M9c) so pieces always cross the screen; gust arrows and slide arrows are on the floor (world-anchored); two push sources on one axis are stacked on purpose (same direction) so they never fight. **Fallback** if AR02's camera limits clash with portrait: replace AR02 with an upright board and EV07 junk rise ("Avalanche Rise", a snow layer pushes up every 5 locks) keeping the same two twists.
**Light**: bright noon (C; the sled lands in full sun). **Music id**: `ice_10`.

```json
{ "schema": 1, "id": "ice_10", "biome": "ice", "tier": 10,
  "board": { "down_axis": "-x", "width": 12, "depth": 6, "h_play": 12, "spawn_anchor": { "x": 11, "z": 2 } },
  "knobs": { "fall.g0": 1.10, "spawn.arrival": "side_travel" },
  "goal": { "type": "clear", "N": 4 },
  "rules": [ { "id": "side_travel", "params": { "travel_dir": "-x", "side_view_min_deg": 45 } },
             { "id": "gust", "params": { "wind_dir": "+z", "wind_interval_ms": 9000, "wind_jitter_ms": 2000, "wind_strength": 1, "wind_warn_ms": 1000 } },
             { "id": "ice_slide", "params": { "slide_dir": "+z", "slide_cells": 1, "start_after_clears": 2 } } ],
  "stars": { "t2": 270000, "t3": 190000 }, "music": "ice_10",
  "story": { "mascot_role": "watcher", "icon": "sled" } }
```
*Field mapping of a re-indexed (sideways) board to `width` / `depth` / `h_play` is the ADR-0002 / ADR-0005 call; the sketch shows intent only.*

#### Friend join: Lana (4 s, then unlock card; after the finale payoff)

Skit beats follow `dialogue-campaign-skits.md` §3: 0.0–1.0 Lana, bundled in yarn, steps into the snowman ring; each snowman holds a cup; one chair is empty (`sweat`). 1.0–2.5 her needles flash; a scarf lands on each snowman, one by one (`heart`). 2.5–3.5 one scarf is left; she looks at the empty chair, then turns and holds the scarf up to the wizard (`idea`). 3.5–4.0 the scarf wraps the wizard's cloud; Lana `note`. Unlock card: her silhouette fills with colour; a yarn ball rolls to her feet. **Stitch is unlocked** (campaign use rule: charge meter from clears). The map change that follows (snowman ring scarved, flag 3 on the summit, tower's third floor) is a map skit, not a level.

---

### B Present Puzzle (bonus, tier 11, 20 ice stars)

**Story card.** Pebble wrapped six presents for the party and the pile is a puzzle: fit them into the box in any order before the bow goes on. Six pieces, no spares. · **Pebble: watcher** (guards the pile, flippers out).
**Stage**: clean, calm; an igloo interior, warm lamp. **I**: Pebble tips a sack of presents onto the floor and counts them on its flippers (`question`). **P (skit §3)**: 0.0–2.0 the last present fits; the pile wraps itself in one big bow. 2.0–4.0 Pebble stands guard before it, flippers out (`dots`). 4.0–5.0 a snowflake lands on its beak; it does not flinch; then it sneezes (`dizzy`). Clearing it earns **Postcard 3** in the Scrapbook. **M**: none (bonus). **R**: a wrong fit, Pebble tilts its head; a perfect fit, a tiny bow.

```text
Recipe: BL01 (4×4, H6) · AR13 Kit box [Big Cube ×2, Tripod ×2, Screw-Left ×2] · CV01 · GO03 (32 cells: 4×4 × 2 layers) + CL14 [M2] · FT07 out of pieces · FT12 undo and reset
One sentence: "Fit all six presents into the box, in any order."
```
**Encounters**: preview shows the whole kit tray; used pieces grey out. **Known solution** (the validator replays it): split the 4×4×2 box into four 2×2×2 blocks. Block A (x0–1, z0–1) = Big Cube. Block B (x2–3, z2–3) = Big Cube. Block C (x2–3, z0–1) = Tripod + Tripod (opposite corners). Block D (x0–1, z2–3) = Screw-Left + Screw-Left (two same-hand screws split a cube). Each block fills floor to layer 1, so every placement is supported in any order. Stars: ★★ 120 s, ★★★ 80 s and no cube trimmed (hand-set). The FT12 reset is free; out of pieces without a full box loses the level (retry is instant). Atoms new to the player: AR13, FT12.

```text
targets (both layers)   side (z = 1)
++++                     6 . . . .   spawn zone
++++                     3 ========  danger line
++++                     :
++++                     1 + + + +   layer 1
                         0 + + + +   layer 0
```
**How it plays and teaches**: (1) read the tray; pick any piece. (2) The Big Cubes go anywhere that fits a 2×2 block; the screws and tripods are the puzzle. (3) Undo lets the player try again without a full restart. (4) The last piece closes the lid. It teaches: *order is your choice*.
**Wacky test**: surprising, you choose the order; silly, tiny bows on every piece; funny failure, the presents spill out of the box in a gift tumble; big moment, the lid and the bow.
**Readability**: only the tray's chosen piece is bright; a "stuck" cue (FT13) is not used, to keep it a real puzzle.
**Light**: igloo glow (H). **Music id**: `ice_bonus`.

```json
{ "schema": 1, "id": "ice_bonus", "biome": "ice", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "kit": ["big_cube","big_cube","tripod","tripod","screw_left","screw_left"] },
  "knobs": { "fall.g0": 0.5, "spawn.arrival": "kit_box", "goal.top_out": "piece_budget" },
  "goal": { "type": "shape", "target_shape": { "layers": { "0": ["++++","++++","++++","++++"], "1": ["++++","++++","++++","++++"] } } },
  "rules": [ { "id": "fill_shape", "params": {} }, { "id": "undo_reset", "params": {} } ],
  "stars": { "t2": 120000, "t3": 80000 }, "music": "ice_bonus" }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Snowball Fight

**Story card.** Sniffles caught a sniffle every lock. Snowballs roll down fast and grow, and the sneezes shove your pieces too. Make the balls part of the plan. · **Pebble: watcher** (hides behind a snowbank).
**Stage**: busy, the 04 field with a swarm of snowballs. **I**: a chain of sneezes; the field fills with snowballs; Pebble ducks (`exclaim`). **P**: the balls line up at the drift and Pebble builds a snow fort behind them. **M**: none (a remix has no extra clue).

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · SP41 Snowball Roll (balls_max 4, roll_locks 1, respawn_locks 5) · EV01 Sneeze Gust (every 10 s, callback)
```
```text
top-down (m = start)     side (z = 2)
..m.m.                   10 ============
......                    :
......                    0 . . . . . .   balls roll left, grow to 3
```
`slope_dir` −x. Stars: 410 / 290 s (Clear 5 × 96 s).

### H2 Blind Curling

**Story card.** Curling in a snow squall: flick the stone through the gate while the stack fades. · **Pebble: watcher** (sweeps ahead of the stone).
**Stage**: clean, tense, the 03 lane in a whiteout. **I**: a squall arrives; Pebble sweeps with a tiny broom and the lane fades behind it. **P**: the lane clears; the stones lined up in a perfect row; Pebble bows (`dots`).

```text
Recipe: BL01 (4×8 lane, H10, same posts as 03) · AR01 · CV18 Curling Flick · GO01 (4) · FT01 (1) · CL01 + CO01 · EV02 Whiteout (visible_ms 3 500)
```
Stars: 290 / 205 s (Clear 4 × 85.3 s). No new idea: blind steering.

### H3 Two Floes

**Story card.** Two floes, one flurry. Each piece goes to the floe you pick; the second floe is thin and loses a strip at 60 s. Clear 3 layers on each before either overflows. · **Pebble: watcher** (runs between the floes on an ice bridge).
**Stage**: clean, tense; two small floes joined by a plank. **I**: Pebble tries to carry the egg between the floes; the plank wobbles. **P**: both floes grow a snowman; Pebble hops from one to the other (`heart`).

```text
Recipe: BL07 (2 floes, 4×4 each, H8; tap a floe to send the piece) · AR01 · CV01 · GO01 (3 per floe) · FT01 (1, shared) · CL01 + CO01 · BL12 Thin Ice (floe B only, shrink_steps 1, +x strip at 60 s)
```
```text
floe A     floe B (thin)   side
####       ####            8 =====     =====
####  ==   ####             :           :
####       ####            0 . . . .   . . . .
####       ####
```
Stars: 220 / 155 s (Clear 3 per floe, same as the Meadow's H3).

---

## 8. Narrative beats

### 8a. Story arc and Mizzle clue slots

Wordless (skits doc rules): intro and payoff skits per level, Pebble's reactions, Sniffles in the backdrop from 03. Arc: Pebble tucks the egg in (01), slides on the floe (02), curls to the nest (03), dodges snowballs (04), builds the chimney (05), draws a snowman (06), loses the egg in the whiteout (07), crosses thin ice (08), hangs from the flipping berg (09), races down the mountain (10) and brings the egg home. Lana joins at the end. The bonus and remixes are after-party gags.

**Mizzle clue table** (strength cap 2; one per level; `dialogue-campaign-skits.md` §3 beats re-slotted to fit the level story; movable with the level's own payoff):

| Slot | Beat | Strength | Where | Emote |
|---|---|---|---|---|
| 01 | none | — | — | — |
| 02 | none | — | — | — |
| 03 | ★ A lone trail of small boot prints leads up into the mountain | 1 | backdrop, static | none |
| 04 | A snowman at the rim has a mismatched-scrap hat band | 1 | backdrop, static | none |
| 05 | Small hands count on fingers above a drift, stop at one (adapted from the skits' "count snowmen") | 2 | payoff, 1.5 s | none |
| 06 | ★ The snowman ring: each snowman holds a cup, one empty chair | 1 | payoff end, 1.5 s | none |
| 07 | ★ First `tear`: the bubble rises from behind a snowman; a drip lands by the empty chair; nobody is seen | 2 | payoff, 1.5 s | `tear` |
| 08 | A violet cuff straightens the empty chair, slips back behind a snowman | 2 | payoff, 1.5 s | none |
| 09 | A droopy hat in a big scarf hurries off between the ice blocks | 2 | payoff, 1.5 s | `sweat` |
| 10 | none (flag 3 on the party horn is set dressing, no hold) | — | — | — |

Departure from `lore-world.md` §7 (flagged): the lore table has the ring at 06, glitter at 08, a mail-cloud at 04; this file follows the skits doc beats (the writer's pass is the later authority) and keeps the ring at 06 (the Snowman Picture echo). Clue props live only in their own level; the ring stays as ambient dressing on 07–09 as the thread spot. No clue appears during a warning, over the grid, or twice in one payoff.

### 8b. Lana and Stitch (design notes)

- Lana is not playable in Ice before the join; her skill **Stitch** (`stitch_s` 10 s: stack writes that move or remove locked cubes are vetoed; queued structure changes wait) applies on replays after the join.
- Stitch interactions in Ice (all from `skills.md` rules 14 and the `stack` tag): holds **Berg Crack** in 09 (the flip waits and its telegraph shows "held" with a yarn pin), holds **Thin Ice** strips in 08 (the strip is removed after Stitch ends), pauses **Snowball Roll** in 04, 06 and H1. It does not stop Slippery Slide or Sneeze Gust (they move the falling piece, not locked cubes).
- Star times assume no perks and no skills; a Stitch use does not change any threshold.

---

## 9. Music and audio cues

**One track per level, supplied by the user** (decisions Round 5; no stems). Level `music` ids are placeholders: `ice_01` … `ice_10`, `ice_bonus`, `ice_h1`–`ice_h3`. Until the tracks arrive each plays the biome's `default_music` ("Carefree" is a placeholder only; unknown ids warn and fall back). Within a level, only SFX, ambience and stingers change:

- **Ambience** (under the SFX slider): wind hush and ice creaks; a far muffled sneeze from the summit that grows louder through the biome (silent in 01–02, soft in 03, near by 10); penguin flipper slaps; capped tiny critter sounds.
- **01–02**: quiet; a soft squeak on each slide. **03**: a clink when a flicked piece hits a post; a long glide on a flick. **04**: a soft "whump" per ball roll; a growing "plop" as it grows. **05–06**: no danger stinger (trim cannot lose); a warm chime when a layer glows. **07**: muffled high-cut on the ambience while the fog is up; a clear blows the muffling off. **08**: ice ticks on each crack warning; a bright refreeze chime at 140 s. **09**: a deep crack on the flip warning, a "whump" on the flip. **10**: Sniffles' "ahh" cue before each sneeze, a big sneeze sting, a sled-jump sting on the last clear.
- **Danger stinger** only where `topout_rule` is rescue. Skits use short stingers, never voices. The first `tear` (07) gets a single soft drip sound and nothing else.
- Photosensitivity: no flashes above 3 per second; Whiteout snow stays slow; the crack and flip staging obey reduced motion (no camera shake).

## 10. Open questions and concerns

- **SP41 Snowball Roll does not exist** (needed): a solid, `fills_layer` cube that rolls one cell along `slope_dir` every `roll_locks` locks and gains a cube after each roll up to `snow_max`; parks when blocked. It needs a full rule write-up in an owning GDD (game-designer), a `stack` tag decision, and an entry in the library (suggested ID SP41).
- **EV09 Slippery Slide**: the module says "camera-forward". This file uses a **world-anchored `slide_dir`** so replays stay deterministic without a `cam` tag, and adds a `start_after_clears` param (used in 10) and a two-tint ghost preview. Needs sign-off from game-designer and the camera ADR.
- **CV18 Curling Flick (Proposed)**: needs a flick gesture in Touch Controls, a keyboard and gamepad binding, and a flick-direction hint for the first piece. If rejected, 03 falls back to EV09 (section 6, 03).
- **AR02 / M9 Sideways Gravity** (finale) has camera limits (M9c) and prefers landscape; portrait on a phone may be awkward. Fallback in 10's readability note. Mapping of a re-indexed board to level JSON fields is for ADR-0002 / ADR-0005.
- **BL12 Thin Ice**: its knobs are defined here, not in the module. Removing a strip deletes locked cubes (a `stack` write), so Stitch holds it; a strip that completes a layer clears it. The validator must keep the footprint at least 4 wide for the I piece.
- **Proposed atoms used**: CV18 (03, H2), AR13 and FT12 (bonus). Candidates used: EV09, BL12. FT12 needs two ADR-0001 command kinds (undo, reset).
- **Lighting conflict**: `lore-world.md` §3.3 F gives a level-by-level table (blue dawn, cool morning ×2, glitter morning ×2, pale noon, blizzard grey, pale noon ×2, bright noon, igloo glow) and `visual-direction.md` §3.2 gives bands (cool dawn L1–3, overcast L4–6, whiteout L7–8, noon L9–10, igloo bonus). This file uses the lore names with the visual archetypes; the user's per-biome reference sheets win.
- **Clue slots** differ between `lore-world.md` §7 and the skits doc (section 8a); needs a narrative-director ruling.
- **Candy not written yet**: the "new atom" counts assume only Meadow atoms are known; they can only go down.
- **Pebble has no catch** (WO11 is Pip's). If the user wants a mascot-catch in Ice 01–02, WO11 can be reused as a one-line change.
- **Star times** are formula estimates (`t_beat ≈ 2.67 × A`); replace with playtest medians. 06, 09 and the bonus are hand-set guesses.
- **Bonus kit** solution is hand-verified on paper (four 2×2×2 blocks); the validator replay should confirm before it ships.
