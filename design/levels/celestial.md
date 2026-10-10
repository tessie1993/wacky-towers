# Celestial Biome: Comet's Bedtime, the Hat Reveal (levels 01–10, bonus, hard track)

> **Status**: Draft v1 for user review (level-designer, 2026-10-10)
> **Author**: Tessa + level-designer
> **Last Updated**: 2026-10-10
> **Implements Pillar**: Variation Over Depth; The Block Is the Constant; Readable Chaos
> **Format**: copies `design/levels/meadow.md` section for section. Biome number 10 in the main chain (after Neon); the campaign's grand finale. Drizzle Rock (side island, the epilogue) opens after `celestial_10`.
> **Sources**: `production/narrative/campaign-story/brief.md` (§1 finale, §3.10, §2.3, §7), `dialogue-campaign-skits.md` §10 (clue slots, boss intro, grand finale), `visual-direction.md` §2.2, §2.4, §3.2 (Celestial), §4.3, `lore-world.md` §3.10, `design/gdd/mechanics-module.md` (atoms, F1), `design/gdd/campaign-structure.md`, `design/gdd/twist-library.md`, `design/gdd/level-specific-mechanics.md`, `design/gdd/level-goals-fail-states.md`, `design/gdd/scoring-stars.md`, `design/gdd/level-data-definition.md`, `production/session-state/decisions.md`.

**Every number, name and beat in this file is a tunable default**, a starting point for the prototype and playtests. The validator enforces only the safe ranges in the owning GDDs. Rule ids marked `*` are provisional.

---

## 1. Level name and theme

**Comet's Bedtime.** Comet the fox wants to sleep on the tallest thing in the sky, and so does the Sleepy Moon. Blocks fall as a slow **star drizzle** down the marble star stairs above Neon's skyline. The Moon's gift is Mizzle's last parcel, a **lullaby night-light** with flag 10 on its cord: the only parcel he carried up the stairs himself. The Moon hugs it like a teddy and goes looking for the tallest bed in the sky. The two tallest things are the wizard's tower and Mizzle's crooked tower. In the finale the Moon's yawn topples Mizzle's tower into a soft heap, the last clear seats the 10th keepsake, the camera pulls back, and the tower is **the wizard's hat**. Dawn breaks: the only sunrise in the campaign since the Lava dusk. Keepsake: the moon.

**Quirk: "Up is optional."** The Celestial is the campaign's *absurd twist* biome (brief §7). It brings the only zero-gravity puffs, the only level where you choose which way down is, and a boss-rush finale where the nine earlier rivals' **gadgets** (never the bosses) tumble in with their old tricks. It still zig-zags: two near-classic teaching levels, one no-fail climb, one quiet puzzle.

**Thread (Mizzle, strength 3).** He is building his tower on a far marble step all biome long, matching the wizard's height, setting a chair on top, almost handing over the card. One clue per level in slots 03–09 (`dialogue-campaign-skits.md` §10), none in 01, 02 and 10 (10's grand finale holds the whole payoff). Missing every clue still gives a clean, happy story.

### Biome rules (decisions)

| Rule | Default |
|---|---|
| Islands | One per level: first-star plinth (01), constellation pocket stone (02), solar-wind causeway (03), meteor field (04), orbit tower (05), constellation dome (06), eclipse disc (07), the six-faced cube islet (08), the drift islet that slowly turns (09), the top of the sky (10). Bonus: the wizard's old hat box |
| Stage | Calm and clean by default; "busy" only where the disturbance needs it (03, 04, 09, 10). Landmark in every backdrop: the Sleepy Moon on its pillow, lower and drowsier each level; Mizzle's crooked tower on a far marble step |
| Intro skit | A wordless mini-scene of 3 s or less in which Comet shows the problem, played during the Countdown; it ends on the hand-off (Comet looks up, the wand glints, the first piece spawns) |
| Payoff skit | 5 s or less on every win, tap to skip. **Exception: the grand finale (10) runs 14 s on first play, skippable, and the 6 s core cut on replays** (skits doc §0.2, §10) |
| Mascot | **Comet** (Celestial only). Tiers 1–2: helper by **pointing only** (`mascot_hint`, the WO06 point half; no catch, WO11 is Pip-only). Tier 3 on: watcher (WO09, reactions only). Comet never pranks. Emote flavour `note`; drifts off mid-gesture |
| Boss | **The Sleepy Moon** (a huge cream-silver crescent `#E6E0C8` with a nightcap and a pillow). In the backdrop from 01, drifting closer; boss in 10. Never hurt: it yawns, sulks, falls asleep |
| Bosses 1–9 | **Grand-finale skit guests only** (user ruling). Before that skit no earlier boss is ever on screen. The finale's boss rush shows only their **gadgets** (lever, piping bag, party horn, bottle, bath bombs, wind chimes, lantern chain, clock-stopper, mixtape), each with its violet flag, falling in from the sky |
| Friends | All four are playable: the cloud wizard, **Lana** (Stitch), **Boulder** (Smash), **Glim** (Redraw). No level is tuned around a skill; star times are balanced for no perks and no skills. Stitch vetoes `stack` writes (09 turntable, 10 Moon's Pillow pops), a valid counter. In the fixed-list and kit puzzles (06, B) Redraw has nothing to re-roll (flag, §10) |
| Physics | None in the Celestial |
| Rubber duck | A **duck constellation** under the 01 and 02 islets: stars that join into a duck from one low snap angle (SE05; tap to collect; no stars attached) |
| Celestial events | Wind = **Solar Wind** (EV01); Spawned Objects = **Meteor Drizzle** (EV04 + SP19 skinned as star-rocks); Invisible Blocks = **Eclipse** (EV02); Balloon = **Zero-G Puff** (EV10); Turntable = **Drifting Islet** (BL11); Choose your down = **Every Way Down** (CV19); Lava and lid = **Moon's Pillow** (EV06, lid mode); Mystery event card = **Gadget Parade** (EV15) |
| Callbacks | Meadow's gust, spawned objects and fog; Underwater's turntable; Lava's EV06 (as a lid); Ice's slide (inside the parade). One idea per level is the new one; the rest are known |
| Dressing | Block set purple cosmic (Cosmic Dust / Starry Glow / Nebula Swirls), gold accents muted. Frame: midnight-blue painted wood, muted gold-leaf filigree, tiny sun-and-moon corner ornaments (`visual-direction.md` §3.2). Nebula leans blue-indigo so Mizzle's violet and the flags stay the brightest violets on screen |
| Prototype priority | **05, 08, 09, 10** (★PROTO): EV10 float, CV19 every-way-down, the turntable remix, and the boss-rush finale plus the 14 s grand-finale skit |

**Lighting (decision: `visual-direction.md` §3.2, six presets from the eight shared archetypes).** Used as written in each level below.

| L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10 | B |
|---|---|---|---|---|---|---|---|---|---|---|
| indigo night (G) | indigo night (G) | indigo night (G) | nebula (I) | nebula (I) | eclipse (I dark, board rim light) | eclipse | pre-dawn (A cool) | pre-dawn | **first sunrise** (A to E warm; dawn breaks in the payoff) | hat-box interior (H) |

`lore-world.md` §3.10 F lists a different eight-preset split (indigo dusk, star night, drift, lamplight); this file follows the visual direction as the brief asked (§10).

**Common defaults** (unless a level says otherwise): weighted bag, `queue_lookahead` 3, `preview_count` 1, no hold, `collapse_mode` slice, `ramp_per_clear` 0.05, `topout_rule` rescue, `warnings_max` 1, `countdown_ms` 3 000, all rotation axes (Turn / Flip / Roll), `t_piece` 8 s. **Pieces**: "8 Std" = I, O, T, L, S, Tripod, Screw-Left, Screw-Right. **Speeds** are hand-set within ±0.05 of campaign F2 (`0.6 + 0.045 × (tier − 1) + 0.06 × (10 − 1)` = 1.14 at tier 1 up to 1.545 at tier 10); puzzle levels (06, B) set a slow `g0` 0.6; 08 is deliberately slower (§10). **Star times** use Scoring & Stars F1 (`t2 = round5(0.85 × t_est)`, `t3 = round5(0.6 × t_est)`) with `t_est = N × A × 2.667 s` for Clear-N (A = active cells per layer). Levels with starter blocks, a new verb, puzzles and the bonus hand-set their times. Stars are for play with no perks and no skills.

**Budget (mechanics module F1).** At most 2 atoms new to the player and 4 non-default atoms per level; tiers 7–10 showpiece levels may use up to 6. "New" means *not used in an earlier biome file or an earlier Celestial level*; the Meadow, Candy, Ice, Underwater, Lava and Forest files are counted; Cave, Clockwork and Neon were not on disk when this was written (recount in §10). Bundles count 1 (M1 = GO02 + CL14 + FT02, M2 = GO03 + CL14). Slot defaults: BL01, AR01, CV01, CL01, CO01, GO01, FT01. Secrets (SE05) and the mascot field count 0.

**Grids**: one string per row, row 0 = `z = 0` (back), character 0 = `x = 0` (left). Mask `#` active, `.` off; starting layers `#` starter block, `.` empty; targets `#` target cell. Side views are a slice at one `z` row seen from the front; `=====` is the danger line at `H_play`, `S` the spawn zone, `:` skips empty rows.

### Celestial rule notes (new and changed rules; owners named in §10)

| Rule | Definition (all values tunable) |
|---|---|
| **EV10 Zero-G Puff** (Candidate, layer `twist`, tags `fall absurd daily`, counter: **use it**) | `balloon_per_bag` (1; 0–2) piece in each bag wears a star-puff. It falls at `balloon_g_mult` (0.5) of the level's gravity. Once per piece, `balloon_drift_ms` (3 000) after it spawns, it **drifts up 1 cell** if the cell above is free (a 500 ms bob is the telegraph). Hard drop works as usual and cancels the drift. Soft drop pulls it at normal soft-drop speed. It never drifts above the spawn zone. Use it: the slow fall gives aim time for a hard 3D fit |
| **CV19 Every Way Down** (Proposed, `control.verb`, tags `grid fall axis`, cost L) | Board is a **6×6×6 cube**. While the piece is in the spawn zone a swipe (or a d-pad hold + drop key) picks its **travel direction**: down (default), +x, −x, +z or −z; a big arrow on the piece and a glow on the target wall show it, and the ghost is drawn where it will stop. The piece then travels that way at the fall speed until blocked by a wall or a cube, and locks there (lock delay as usual). Clears stay **CL01 layers** (full horizontal layers of the cube) with **CO01 slice** collapse along y, so a piece parked on a side wall drops one row when a layer under it clears. Spawn is top centre only; spawn blocked = top-out. Only the active piece's direction changes; the board's down axis never does |
| **BL11 Drifting Islet** (Designed, MG12; known from Underwater 09) | The whole stack turns 90° about the vertical centre axis every `turn_every_locks`; `turn_warn_locks` 1 (stars swirl round the rim one lock ahead). Square footprint only |
| **EV06 Moon's Pillow** (lid mode of EV06; known from Lava as Rising Lava) | The Moon lowers its pillow onto the stack. `lid_first_s` (60) after the level starts, then every `lid_every_s` (40), the danger line drops 1 layer, up to `lid_max` (2) steps, after a `lid_warn_ms` (3 000) telegraph (the pillow's shadow darkens the top row and a soft countdown ring fills). Cubes in a row the pillow takes are **popped softly** (trim, never a top-out on that step). **Each clear lifts the pillow back up 1 step** (`lid_push_per_clear` 1), never above the level's `h_play`. Counter: **clear to cancel** |
| **EV15 Gadget Parade** (Candidate, layer `twist`, tags `absurd daily`) | Every `event_card_locks` (6) locks, one **gadget card** flips (chosen from the rule's seeded stream, no repeat until the pool is used). The gadget falls in from the sky at the board rim, flag fluttering, one lock before its effect (the gadget pose + gadget glint + hazard marker on the board, `visual-direction.md` §2.1). Each card plays **one** instance of a known event: **Gust** (EV01, 1 cell, 1 000 ms warning): the Miller's lever, Big Sniffles' party horn, Grandpa Oak's wind chimes. **Drop** (EV04 + SP19, one star-object, cell marked one lock ahead): Madame Meringue's piping bag, Admiral Crab's bottle, Cuckoo Prime's clock-stopper. **Slide** (EV09, the next landed piece slides 1 cell along camera-forward): Smolder's bath bombs, Geode's lantern chain, DJ Mirrorball's mixtape. The bosses themselves never appear |
| **Meteor Drizzle** (EV04 + SP19 skinned as a star-rock) | Twist-library T4 as written; the staging drops the star-rock down a little trail onto the marked cell |
| **Solar Wind** (EV01) | Twist-library T1 as written; the arrow is a ribbon of sun-gold dust (muted, not reward gold) |
| **Eclipse** (EV02) | Twist-library T2 as written; faded cubes keep a faint starry outline, the board rim light stays on |

## 2. Estimated play time and summary

| # | id | Name | Story beat | New idea (atoms) | Comet | Stage | Goal | Board | Pieces | g0 | Top-out | Length | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 01 | celestial_01 | First Star | Light the first star | none (classic, star look) | helper (points) | clean, calm | Clear 3 | 5×5, H9 | 8 Std; first 2 from {O, I} | 1.14 | rescue, 2 | ~3.3 min | 170 / 120 s |
| 02 | celestial_02 | Constellation Stone | Beds for three star-sheep | pockets (BL05) | helper (points) | clean, calm | Clear 3 | 6×6, H10 + 2 starter layers | 8 Std; first 3 a bag of {Tripod, Screw-L, Screw-R} | 1.15 | rescue, 1 | ~2.5 min | 150 / 105 s |
| 03 | celestial_03 | Solar Wind Causeway | Sheep blown down the causeway | Solar Wind (EV01) | watcher | busy | Clear 5 | 8×4 lane, H10 | 8 Std | 1.23 | rescue, 1 | ~7.1 min | 365 / 255 s |
| 04 | celestial_04 | Meteor Field | Star-rocks drizzle | Meteor Drizzle (EV04 + SP19) | watcher | busy | Clear 3 | 6×6, H10 | 8 Std | 1.25 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 05 ★ | celestial_05 | Orbit Tower | Climb to the Moon's height | **Zero-G Puff (EV10)**, build race (M1) | watcher | clean, tense | Height 10 (cov. 0.6) | 5×5, H12 | 8 Std + Big Cube (w 0.5) | 1.30 | trim | ~4.7 min | 240 / 170 s* |
| 06 | celestial_06 | Constellation Dome | Draw Comet's tail | fixed list (AR09), budget (FT07), fill shape (M2) | watcher | clean, hushed | Shape 24 | 4×4, H6 | fixed: I O O I I O | 0.60 | out of pieces | ~1.5 min | 75 / 50 s |
| 07 | celestial_07 | Eclipse | The sky goes dark | Eclipse (EV02) + Zero-G callback | watcher | busy, hushed | Clear 4 | 6×6, H10 | 8 Std | 1.40 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 08 ★ | celestial_08 | Every Way Down | A rock with six floors | **Every Way Down (CV19)** | watcher | clean, tense | Clear 3 | 6×6×6 cube, H6 | 8 Std | 1.30 | rescue, 1 | ~4.8 min | 245 / 175 s |
| 09 ★ | celestial_09 | Drift Islet | The islet turns in its sleep | Drifting Islet (BL11) + Zero-G (remix) | watcher | busy | Clear 4 | 6×6, H10 | 8 Std | 1.50 | rescue, 1 | ~6.4 min | 325 / 230 s |
| 10 ★ | celestial_10 | The Top of the Sky | Boss: the Sleepy Moon; the Hat Reveal | **Gadget Parade (EV15)** + Moon's Pillow (EV06 lid) | boss | busiest | Clear 3 | 7×7, H12 | I O T L Tripod Screws Chair | 1.50 | rescue, 1 | ~6.5 min | 335 / 235 s |
| B | celestial_bonus | Hat Box | Pack the old hat | kit box (AR13), fill shape (M2), budget (FT07), undo (FT12) | watcher | clean, calm | Shape 24 | 4×4, H6 | kit: I, I, O, O, Big Cube | 0.60 | out of pieces | ≤ 2 min | 90 / 60 s* |
| H1 | celestial_h1 | Meteor Storm | The meteors and the wind together | Meteor Drizzle + Solar Wind (rotating) | watcher | busy | Clear 5 | 6×6, H10 | 8 Std | 1.45 | rescue, 1 | ~8 min | 410 / 290 s |
| H2 | celestial_h2 | Dark Side | Every way down, in the dark | Every Way Down + Eclipse | watcher | clean, tense | Clear 3 | 6×6×6 cube, H6 | 8 Std | 1.35 | rescue, 1 | ~5 min | 260 / 185 s |
| H3 | celestial_h3 | Twin Moons | Two islets, puffs drifting | Islands (BL07) + Zero-G | watcher | clean, tense | Clear 3 per islet | 2 × 4×4, H8 | 8 Std | 1.40 | rescue, 1 shared | ~4.3 min | 220 / 155 s |

★ = prototype priority. \* 05 ★★★ also requires no cube trimmed; B ★★★ also requires no undo used (hand-set). Hand-set times: 02 (starter layers), 06 and B (piece lists), 08 and H2 (a new verb: the F1 estimate is kept but not trusted), 10 (rounded from F1 for a 37-cell feel; see 10). Length notes: 01, 02, 06, B are short on purpose; the validator's 5–15 min warning is expected on them.

**F1 budget table** (nd = non-default atoms, new = new to the player):

| Level | Non-default atoms | nd | new |
|---|---|---|---|
| 01 | none | 0 | 0 |
| 02 | BL05 | 1 | 0 (Meadow 02) |
| 03 | EV01 | 1 | 0 |
| 04 | EV04, SP19 | 2 | 0 |
| 05 | M1 bundle, EV10 | 2 | 1 (EV10) |
| 06 | AR09, M2 bundle, FT07 | 3 | 0 (Meadow bonus, Forest 06) |
| 07 | EV02, EV10 | 2 | 0 |
| 08 | CV19 | 1 | 1 (CV19) |
| 09 | BL11, EV10 | 2 | 0 (BL11 Underwater 09) |
| 10 | EV15, EV06, EV01, EV04, SP19, EV09 | 6 (showpiece cap 6) | 1 (EV15) |
| B | AR13, M2 bundle, FT07, FT12 | 4 | 0 (Forest B, Ice B) |
| H1 | EV04, SP19, EV01 | 3 | 0 |
| H2 | CV19, EV02 | 2 | 0 |
| H3 | BL07, EV10 | 2 | 0 |

Twists per level never exceed 2 (10: Gadget Parade + Moon's Pillow; the parade's pool events play inside the one EV15 rule, but each pool atom counts toward nd, which is why 10 sits exactly at 6). The finale's third-twist allowance is unused.

**Hard track (decision).** `celestial_bonus` is tier 11 (unlocks at 20 celestial stars). The remixes are **tiers 12–14** (`celestial_h1`–`h3`); all three open when `celestial_10` is finished. Neither counts toward any gate (and nothing follows the Celestial on the main chain). Stars still pay points as usual.

## 3. Layout overview

```text
01 first-star plinth  02 pocket stone  03 causeway (wind →)  04 meteor field  05 orbit tower
#####                 ######           ########              ######          #####
#####                 ######           ########              ######          #####
#####                 ######           ########              ######          #####
#####                 ######           ########              ######          #####
#####                 ######                                 ######          #####  (12 tall)
                      ######                                 ######
06 constellation  07 eclipse disc  08 cube islet (6 tall)  09 drift islet (turns)  10 top of the sky
####              ######           ######  every face        ######                #######
####              ######           ######  can be a floor    ######                #######
####              ######           ######                    ######                #######
####              ######           ######                    ######                #######
(6 tall)          ######           ######                    ######                #######
                  ######           ######                    ######                #######
                                                                                   #######
```

## 4. Critical path and optional paths

- **Critical path**: 01 → 10 in order (linear inside a biome). Finishing 10 completes the main campaign: the grand finale, the last map change, and Drizzle Rock (the epilogue side island) opens. The 15-star gate has nothing after it on the main chain; it is kept so the Mastered state reads the same.
- **Optional**: ★★★ times on every level; the duck constellation in 01–02; the bonus Hat Box (20 stars, earns Postcard 10); hard-track remixes H1–H3 (after 10).

## 5. Pacing chart

```text
strangeness (how far from classic)
 high |                             #        #  #
      |                 #           #  #     #  #
  mid |        #  #     #     #     #  #     #  #
      |     #  #  #     #     #  #  #  #     #  #
  low |  #  #  #  #  #  #  #  #  #  #  #  #  #  #
      +-01-02-03-04-05-06-07-08-09-10----B
        learn  wind meteor float puzzle dark every-way drift FINALE
```

Zig-zag, not a ramp: two teaching levels (01 classic, 02 pockets) → two callbacks dressed for the sky (03 wind, 04 meteors) → the first float in a no-fail climb (05) → a quiet puzzle (06) → the dark (07) → the strangest verb on a calm, clean stage (08) → the hardest remix (09) → the boss rush (10). Short and long alternate (campaign rule 12): short (01, 02), long (03), mid (04, 05), short (06), long (07), mid (08), long (09), long finale. Energy runs "peak to calm" (brief §7): the busiest is 10, and its payoff ends in the stillest moment of the game, at dawn.

---

## 6. Level specs (encounter lists, sketches, beats)

### 01 First Star

**Story card.** Comet wants to light the first star of the night. Fill a whole layer and it clears; three clears and the star on the plinth lights. · **Comet: helper** (points at the emptiest cell; no catch).
**Stage**: clean, calm; a pale marble plinth in indigo sky, the Moon tiny and far. **Light**: indigo night. **Intro skit** (3 s): Comet trots up the star stairs trailing sparkles, sits by a dark star socket and yawns (`note`); hand-off. **Payoff skit** (4 s): the star lights in the socket; Comet curls up beside it, then the star floats off into the sky and Comet trots after it (`sparkle`). **Mizzle clue**: none (slots 01–02 carry none). **Reactions (R)**: clear `sparkle`; warning `sweat`.

```text
Recipe: BL01 (5×5, H9) · AR01 · CV01 · GO01 (3) · FT01 (2 warnings) · CL01 + CO01 · SE05 duck constellation · mascot_hint (Comet points)
One sentence: "Fill a whole layer and it clears."
New to the player: nothing. Tier 1 re-teaches the controls in the Celestial look.
```
**Encounters**: none (pure classic). Pieces 8 Std; `opening_set` [O, I], count 2. `T_level` 200. Control: CV01, all three rotation pairs.

```text
top-down 5×5   side (z = 2)
#####          12 . . S . .   spawn zone
#####           9 ==========  danger line
##S##           :
#####           0 . . . . .   the star plinth
#####
```
**How it plays**: (1) an O drifts down; Comet points at a corner. (2) The first layer clears in about 6 pieces: the plinth sinks, a little star puff rises. (3) 3D pieces arrive at a speed faster than the Meadow's but forgiving on a 5×5. (4) The third clear lights the star.
**Teaches**: re-teach of the controls and the base speed of the last biome.
**Readability**: the plinth top is pale marble against indigo, the pieces' purple cosmic set has a clear value gap from it; the danger line is a thin star cord.
**Wacky test**: surprising, the star socket is the goal; silly, Comet yawning at the start of its own bedtime story; funny failure, Comet covers its eyes with its tail; big moment, the star floating up into the sky.

```json
{ "schema": 1, "id": "celestial_01", "biome": "celestial", "tier": 1,
  "board": { "width": 5, "depth": 5, "h_play": 9 },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["o","i"], "opening_count": 2 },
  "knobs": { "fall.g0": 1.14, "goal.warnings_max": 2, "goal.top_out": "rescue" },
  "goal": { "type": "clear_n", "N": 3, "T_level": 200 },
  "rules": [ { "id": "mascot_hint", "params": {} }, { "id": "angle_gem", "params": { "skin": "duck_constellation" } } ],
  "stars": { "t2": 170000, "t3": 120000 },
  "music": "celestial_01_tbd", "story": { "mascot_role": "helper", "icon": "star" } }
```

---

### 02 Constellation Stone

**Story card.** Three star-sheep need beds in the constellation stone before they can be counted. Turn, Flip and Roll each piece to fit its bed. · **Comet: helper** (points at the pocket the current piece fits; no catch).
**Stage**: clean, calm; a pocked stone, three fluffy star-sheep waiting. **Light**: indigo night. **Intro skit** (3 s): three star-sheep in a row stare at three odd holes; one tries to lie in a hole and sticks out at both ends (`question`); hand-off. **Payoff skit** (4 s): each sheep flops into its bed; Comet counts them with a paw and falls asleep at three (`sleep` would be the Moon's: Comet uses `note`). **Mizzle clue**: none. **Reactions (R)**: pocket filled `sparkle`; wrong fit `sweat`.

```text
Recipe: BL05 (6×6, H10, 2 starter layers) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · SE05 duck constellation · mascot_hint
One sentence: "Turn the piece to fit its bed."
New to the player: nothing (BL05 pockets from Meadow 02).
```
**Encounters**: three pockets, each exactly fillable by one 3D piece (the validated Meadow 02 geometry): A the Tripod, B and C the two screws. Pieces 8 Std; `opening_set` [Tripod, Screw-Left, Screw-Right], count 3 (a bag, random order).

```text
layer 0     layer 1     side (z = 1)
######      ######      10 ==============
#.###.      #..#..       :
######      #.##.#       1  # . . # . .   pockets A (x1–2), B (x4–5)
######      ###.##       0  # . # # # .
####.#      ###..#
######      ######
```
**How it plays**: (1) a Tripod spawns; Comet points at bed A. (2) A screw fits only one of the two remaining beds. (3) The third bed fills and both starter layers clear together (a double). (4) One free clear on the open board.
**Teaches**: a 3D-fit warm-up at the last biome's speed; the double clear.
**Readability**: pocket rims glow faint star-white; the ghost shows the fit.
**Wacky test**: surprising, the board starts half built; silly, sheep sticking out of a hole; funny failure, a sheep bonks on a misfit piece; big moment, the double clear.

```json
{ "schema": 1, "id": "celestial_02", "biome": "celestial", "tier": 2,
  "board": { "width": 6, "depth": 6, "h_play": 10,
             "starting_contents": { "layers": {
               "0": ["######","#.###.","######","######","####.#","######"],
               "1": ["######","#..#..","#.##.#","###.##","###..#","######"] } } },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r"], "opening_set": ["tripod","screw_l","screw_r"], "opening_count": 3 },
  "knobs": { "fall.g0": 1.15, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "mascot_hint", "params": {} }, { "id": "angle_gem", "params": { "skin": "duck_constellation" } } ],
  "stars": { "t2": 150000, "t3": 105000 },
  "music": "celestial_02_tbd" }
```

---

### 03 Solar Wind Causeway

**Story card.** A solar wind streams along the causeway and blows the star-sheep off their stepping stones. Build with the wind, against the far wall. · **Comet: watcher** (its tail streams in the wind).
**Stage**: busy; a long marble causeway, sun-gold dust streaming, sheep tumbling. **Light**: indigo night. **Intro skit** (3 s): a gust bowls three star-sheep along the causeway like puffballs; Comet's tail blows over its face (`question`); hand-off. **Payoff skit** (4 s): the wind dies; the sheep land in a neat row on the finished causeway and Comet hops across their backs. **Mizzle clue (M, 1.5 s, far marble step)**: Mizzle builds his tower, one clean cube at a time (`idea`). **Reactions (R)**: gust warning `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (8 wide × 4 deep, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV01 Solar Wind (fixed +x) · WO09
One sentence: "The solar wind pushes your piece along the causeway."
New to the player: nothing (EV01, Meadow 03), at the last biome's speed.
```
**Encounters**: Solar Wind +x toward the x = 7 wall, every 7 s ± 2 s, 1 cell, 1 000 ms warning (a ribbon of gold dust, world-anchored). Pieces 8 Std.

```text
top-down 8×4 (wind →)   side (z = 1)
########                13 . . . S S . . .   spawn zone
###S####  → → →         10 ================  danger line
########                 :
########                 0 . . . . . . . . |  wall at x = 7 = the brace
```
**How it plays**: (1) the first pieces fall calm; dust starts to stream. (2) A gust shoves the piece one cell right. (3) The player builds from the downwind wall so gusts push pieces home. (4) Five clears and the sheep are home.
**Teaches**: a re-read of the wind at high speed: with less fall time, fewer gusts land per piece, but each one matters more.
**Readability**: the arrow is the only moving gold on screen; dust never crosses the board's footprint.
**Wacky test**: surprising, the wind carries your piece; silly, sheep as puffballs; funny failure, a gust drops a piece in the wrong slot and a sheep sits on it; big moment, a long gust that drives a piece into a perfect gap.

```json
{ "schema": 1, "id": "celestial_03", "biome": "celestial", "tier": 3,
  "board": { "width": 8, "depth": 4, "h_play": 10 },
  "knobs": { "fall.g0": 1.23, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 5 },
  "rules": [ { "id": "gust", "params": { "wind_mode": "fixed", "wind_dir": "+x", "wind_interval_ms": 7000, "wind_jitter_ms": 2000, "wind_strength": 1, "wind_warn_ms": 1000 } } ],
  "stars": { "t2": 365000, "t3": 255000 },
  "music": "celestial_03_tbd" }
```

---

### 04 Meteor Field

**Story card.** A drizzle of little star-rocks falls through the meteor field. Each one lands on your stack and fills a cell for free, if you plan for it. · **Comet: watcher** (catches one on its nose).
**Stage**: busy; drifting rocks, tiny shooting-star trails. **Light**: nebula. **Intro skit** (3 s): a star-rock bonks Comet's head, bounces, and lands neatly on the board edge; Comet stares (`exclaim`); hand-off. **Payoff skit** (4 s): the star-rocks rise off the cleared stack like fireflies and arrange into a little constellation of Comet; Comet poses next to it (`sparkle`). **Mizzle clue (M, 1.5 s)**: he watches the wizard's stack and adds a cube to his own tower to match its height (`dots`). **Reactions (R)**: star-rock lands `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV04 Meteor Drizzle + SP19 (star-rock skin) · WO09
One sentence: "Star-rocks land on your stack and fill a cell."
New to the player: nothing (EV04 + SP19 from Meadow 04).
```
**Encounters**: a star-rock every 4 locks (max 4), its cell marked one lock ahead by a twinkle; it clears with its layer. Pieces 8 Std.

```text
top-down 6×6   side (z = 2)
######         13 . . S . . .   spawn zone
######         10 ============  danger line
##S###          :
######          1 # r . # # .   r = star-rock
######          0 # # # . # #
######
```
**How it plays**: (1) normal stacking; the first twinkle appears after the 3rd lock. (2) A rock lands with a soft "tink". (3) The player leaves the twinkled cell for the rock. (4) Three clears.
**Teaches**: planning around a free filler at speed; the twinkle is the same promise as the mushroom sparkle.
**Readability**: star-rocks are pale silver with an outline, never a piece hue; the twinkle is one lock ahead.
**Wacky test**: surprising, the sky delivers cubes; silly, a rock on Comet's nose; funny failure, a rock fills the cell your I needed and Comet shrugs; big moment, the Comet constellation.

```json
{ "schema": 1, "id": "celestial_04", "biome": "celestial", "tier": 4,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.25, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "mushroom_popup", "params": { "spawn_every_locks": 4, "objects_max": 4, "skin": "star_rock" } } ],
  "stars": { "t2": 245000, "t3": 175000 },
  "music": "celestial_04_tbd" }
```

---

### 05 Orbit Tower ★PROTO

**Story card.** Comet wants to see the Moon's pillow up close. Stack to the ribbon; nothing clears, too high pops off, and you cannot lose. Some pieces wear a star-puff: up here they float, and drift up a little. · **Comet: watcher** (climbs as the tower grows).
**Stage**: clean, tense; an orbit tower in open nebula, the Moon's pillow above. **Light**: nebula. **Intro skit** (3 s): Comet jumps for the pillow and floats up a little, then drifts back down (`note`); hand-off. **Payoff skit** (4 s): Comet reaches the top and peeks over: the Moon is fluffing its pillow on a cloud, cuddling a ribboned night-light (the flag is set dressing, not the clue); Comet ducks back down (`exclaim`). **Mizzle clue (M, 1.5 s) [GC]**: the grumpy cloud on the wizard's cloud spots a star-stamped card on Mizzle's far step and perks up (grumpy cloud `exclaim`). If the grumpy-cloud twist is dropped, this level has no clue. **Reactions (R)**: puff drift `exclaim`; layer 5 `sparkle`; trimmed cubes `sweat`.

```text
Recipe: BL01 (5×5, H12) · AR01 · CV01 · M1 build race (GO02 height 10, coverage 0.6 + CL14 + FT02 trim) · EV10 Zero-G Puff · WO09
One sentence: "Puff pieces float slowly and drift up a little."
New to the player: EV10 (1), on a level that cannot be lost.
```
**Encounters**: **Zero-G Puff** (rule notes in §1): 1 piece per bag, half gravity, drifts up 1 cell 3 s after spawn unless hard-dropped. Trim at layer 12. Pieces 8 Std + Big Cube (w 0.5).

```text
top-down 5×5   side (z = 2)
#####          15 . . S . .   spawn zone (puffs never drift above it)
#####          12 ===========  danger line (trim)
##S##          10 - - - - -   ribbon: layer 10 ≥ 60% full (15 of 25)
#####           :
#####           0 . . . . .
```
**How it plays**: (1) the floor fills; a full layer glows and stays. (2) The first puff piece floats down slowly and bobs up a cell; the player learns to hard-drop it or to use the slow fall for a careful 3D fit. (3) A Big Cube adds two layers at once. (4) Layer 10 reaches 15 cubes; Comet peeks at the Moon.
**Teaches**: EV10 with no fail pressure; "use it" (slow aim) versus "skip it" (hard drop).
**Readability**: the puff is a soft star-cloud on the piece, the bob is a 500 ms telegraph, the ghost always shows the landing.
**Wacky test**: surprising, a piece that floats up; silly, Comet floating too; funny failure, a puff drifts over the trim line and pops like a soap bubble; big moment, the peek at the Moon.

```json
{ "schema": 1, "id": "celestial_05", "biome": "celestial", "tier": 5,
  "board": { "width": 5, "depth": 5, "h_play": 12 },
  "pieces": { "shapes": ["i","o","t","l","s","tripod","screw_l","screw_r","big_cube"], "weights": { "big_cube": 0.5 } },
  "knobs": { "fall.g0": 1.30, "goal.top_out": "trim" },
  "goal": { "type": "height", "H_target": 10, "height_coverage": 0.6 },
  "rules": [ { "id": "build_race", "params": {} },
             { "id": "balloon*", "params": { "balloon_per_bag": 1, "balloon_g_mult": 0.5, "balloon_drift_ms": 3000 } } ],
  "stars": { "t2": 240000, "t3": 170000 },
  "music": "celestial_05_tbd" }
```

---

### 06 Constellation Dome (puzzle)

**Story card.** Under the dome the constellations are drawn in pieces. Comet's tail is missing: six pieces, no spares, fill the glowing outline. · **Comet: watcher** (holds still so its tail can be traced).
**Stage**: clean, hushed; a dark dome with faint constellations of earlier mascots (outlines only, never the mascots themselves). **Light**: eclipse (dark, board rim light). **Intro skit** (3 s): Comet looks up at a constellation of itself with no tail, then at its own tail (`question`); hand-off. **Payoff skit** (4 s): the outline lights up; the constellation-fox's tail swishes once, and Comet's own tail swishes back (`sparkle`). **Mizzle clue (M, 1.5 s)**: on his far step he sets a tiny chair on his tower's top floor and straightens it (`dots`). **Reactions (R)**: good fit `sparkle`; wrong lock `sweat`.

```text
Recipe: BL01 (4×4, H6) · AR09 fixed list [I, O, O, I, I, O] · CV01 · M2 fill shape (GO03 24 cells + CL14) · FT07 piece budget (6) · WO09
One sentence: "Six pieces, no spares: draw the tail."
New to the player: nothing (AR09, FT07, M2 all known). Retry is free and instant.
```
**Encounters**: none. Preview 3. Target: a full 4×4 base (16) and on layer 1 a centre 2×2 plus the back row (z = 0), a "tail" shape of 8 cells (they share no cells: back row x0–3, centre x1–2 z1–2). Known solution (the validator's `solution` list): 1 I along z0 on layer 0; 2 O at x0–1 z1–2; 3 O at x2–3 z1–2; 4 I along z3 on layer 0 (layer 0 full; clears are off); 5 I along z0 on layer 1; 6 O at x1–2 z1–2 on layer 1. Dealt in list order every placement is supported; an I placed on layer 1 too early starves the base. Stars: ★★ 75 s, ★★★ 50 s (no timer on screen).

```text
target layer 0 (16)   layer 1 (8)   side (z = 1)
####                  ####          6 ======   danger line
####                  .##.          :
####                  .##.          1 . # # .   the tail on layer 1
####                  ....          0 # # # #   the base
```
**How it plays**: (1) read the preview (I, O, O) and the outline. (2) Slow drops (g0 0.6), no clock. (3) The base fills; the fourth piece must close it, not start the tail. (4) The last two pieces draw the tail and the dome lights.
**Teaches**: a breather; order matters even with a known list.
**Readability**: target cells are star dots that join with lines as they fill; filled cells go solid.
**Wacky test**: surprising, drawing a constellation with blocks; silly, two tails swishing; funny failure, the stars fizz out and Comet sighs; big moment, the outline lighting up.

```json
{ "schema": 1, "id": "celestial_06", "biome": "celestial", "tier": 6,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "fixed_list": ["i","o","o","i","i","o"] },
  "knobs": { "fall.g0": 0.60, "spawn.preview_count": 3, "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 6,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["####",".##.",".##.","...."] } } },
  "stars": { "t2": 75000, "t3": 50000 },
  "solution": "see level notes",
  "music": "celestial_06_tbd" }
```

---

### 07 Eclipse

**Story card.** The Moon rolls over in its sleep and covers the stars: an eclipse. Your stack fades into the dark; each clear lights it again. Puff pieces still float. · **Comet: watcher** (its sparkle tail is the only light by the rim).
**Stage**: busy but hushed; an eclipse disc, the board rim lit softly. **Light**: eclipse. **Intro skit** (3 s): the Moon turns over with a sleepy sigh and its shadow sweeps over the islet; Comet waves its glowing tail like a torch (`note`); hand-off. **Payoff skit** (4 s): the eclipse slides away; the whole stack is revealed, and Comet is curled on top of it, asleep. **Mizzle clue (M, 1.5 s)**: he holds the star-stamped card out toward the wizard from his far step, loses his nerve and pockets it (`sweat`). **Reactions (R)**: fade `question`; clear `sparkle`.

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV02 Eclipse · EV10 Zero-G Puff (callback) · WO09
One sentence: "Your stack fades in the eclipse: remember it."
New to the player: nothing (EV02 Meadow 07, EV10 from 05).
```
**Encounters**: **Eclipse** (fog): `visible_ms` 4 000, `fade_ms` 1 000, `invisible_alpha` 0.12, `reveal_ms` 600 on each clear. **Zero-G Puff**: 1 per bag. The puff's slow fall is the counter: it gives time to remember what is under it. The ghost, the falling piece and the danger line never fade. Pieces 8 Std.

```text
top-down 6×6   side (z = 2)
######         13 . . S . . .   spawn zone
######         10 ============  danger line (never fades)
##S###          :
######          1 ~ # . ~ ~ .   ~ = faded, starry outline
######          0 # # . # # #
######
```
**How it plays**: (1) the first locks stay visible; then they fade to faint star outlines. (2) The player relies on the ghost and memory. (3) Puff pieces float in slowly, a moment to think. (4) Four clears, each a flash of light.
**Teaches**: memory plus a known helper; a quiet, dark beat before the strangest level.
**Readability**: faded cubes keep a faint outline (alpha 0.12, the Ice whiteout floor), so the dark never reads as an empty board.
**Wacky test**: surprising, the stack vanishes; silly, Comet's tail as a torch; funny failure, a piece lands "on nothing" and the eclipse giggles off; big moment, the reveal flash on each clear.

```json
{ "schema": 1, "id": "celestial_07", "biome": "celestial", "tier": 7,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.40, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "fog", "params": { "visible_ms": 4000, "fade_ms": 1000, "invisible_alpha": 0.12, "reveal_ms": 600, "skin": "eclipse" } },
             { "id": "balloon*", "params": { "balloon_per_bag": 1, "balloon_g_mult": 0.5, "balloon_drift_ms": 3000 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "celestial_07_tbd" }
```

---

### 08 Every Way Down ★PROTO

**Story card.** A little cube-shaped rock floats in the pre-dawn sky, with steps on every face. Up here any wall can be a floor: swipe to choose which way your piece falls. Layers still clear across the cube. · **Comet: watcher** (sits on whichever face is "up" for it, upside down if need be).
**Stage**: clean, tense; one small cube islet, steps on every face, nothing else. **Light**: pre-dawn (cool, the horizon just brightening). **Intro skit** (3 s): Comet walks round the cube, down a side face and onto the bottom, upside down, unbothered (`note`); hand-off. **Payoff skit** (4 s): the cube's faces light one by one; Comet hops from face to face, lands on top and bows (`sparkle`). **Mizzle clue (M, 1.5 s)**: a comet streaks past; he and Comet both look up at the same moment, and he blushes (`blush`). **Reactions (R)**: sideways lock `exclaim`; clear `sparkle`.

```text
Recipe: BL01 (6×6, H6: a 6×6×6 cube) · AR01 · CV19 Every Way Down · GO01 (3) · FT01 (1) · CL01 + CO01 · WO09
One sentence: "Swipe to choose which way your piece falls."
New to the player: CV19 (1).
```
**Encounters**: no twists. **Every Way Down** (rule notes in §1): five travel directions (down, ±x, ±z) picked in the spawn zone; the piece travels until blocked, then locks. Layers are the cube's horizontal slices (A = 36); CO01 drops everything above a cleared layer one row, including pieces parked on side walls. Pieces 8 Std. Speed is set 0.155 below F2 (§10) because travel is now in five directions.

```text
top-down 6×6 (arrows = chosen travel)   side (z = 2)
######   ← piece travels to −x wall      9 . . S . . .   spawn zone (top centre)
######                                   6 ============  danger line = cube top
##S###   → or +x wall                    :
######                                   3 # . . . . #   pieces parked on both walls
######   ↑ ↓ the ±z walls                0 # # # . # #   the floor
######
```
**How it plays**: (1) the first piece falls straight down (the default); the arrow hint pulses. (2) The player swipes once: the piece shoots to the left wall and sticks there, halfway up. (3) Filling a layer from the walls inward shows the trick: side walls fill the edge columns of high layers before the middle is built. (4) A clear under parked pieces drops them one row; three clears and the cube glows.
**Teaches**: the new verb on a calm board with nothing else going on; reading the arrow and the ghost.
**Readability**: one big arrow on the piece and a glow on the target wall; the ghost is drawn at the stop cell. The camera keeps its 12 snaps; the cube is small, so every face reads from a corner view. Pieces parked high on a wall get a soft shadow on the floor below.
**Wacky test**: surprising, the floor is wherever you say; silly, Comet strolling upside down; funny failure, a piece shot the wrong way sticks to the ceiling-side of a wall and Comet tilts its head; big moment, a layer filled from four walls at once.

```json
{ "schema": 1, "id": "celestial_08", "biome": "celestial", "tier": 8,
  "board": { "width": 6, "depth": 6, "h_play": 6 },
  "knobs": { "fall.g0": 1.30, "goal.warnings_max": 1, "control.verb": "choose_down*",
             "control.travel_dirs": ["down","+x","-x","+z","-z"] },
  "goal": { "type": "clear_n", "N": 3 },
  "stars": { "t2": 245000, "t3": 175000 },
  "music": "celestial_08_tbd" }
```

---

### 09 Drift Islet ★PROTO (remix)

**Story card.** The islet turns slowly in its sleep, the whole stack with it, and puff pieces float down in the drift. Build so any side is a good side. · **Comet: watcher** (rides the turn, dizzy).
**Stage**: busy; a slow-turning islet in a pre-dawn star field, the Moon drifting very close now. **Light**: pre-dawn. **Intro skit** (3 s): the islet turns under Comet's paws and it trots in place to keep up (`question`); hand-off. **Payoff skit** (4 s): the islet stops; Comet takes one step and falls over, dizzy (`dizzy`), then gets up and points at the horizon, a little lighter. **Mizzle clue (M, 1.5 s)**: the Moon drifts past his tower, sniffing at its height like a bed; he steadies the tower with both hands (`sweat`). **Reactions (R)**: turn warning `exclaim`; puff drift `exclaim`; clear `sparkle`.

```text
Recipe: BL11 Drifting Islet (6×6, H10) · AR01 · CV01 · GO01 (4) · FT01 (1) · CL01 + CO01 · EV10 Zero-G Puff · WO09
One sentence: "The islet turns your stack; puff pieces float."
New to the player: nothing (BL11 Underwater 09, EV10 from 05).
```
**Encounters**: **Drifting Islet** (turntable): `turn_every_locks` 5, `turn_dir` cw, `turn_warn_locks` 1 (stars swirl round the rim). **Zero-G Puff**: 1 per bag. A puff that drifts during the warning lock lands on the turned stack, so the ghost is redrawn after each turn. Stitch vetoes a turn (valid counter). Pieces 8 Std.

```text
top-down 6×6 (turns 90° cw every 5 locks)   side (z = 2)
######  ↻                                   13 . . S . . .   spawn zone stays
######                                      10 ============  danger line stays
##S###                                       :
######                                       1 # . # # . #   the stack turns about the centre
######                                       0 # # . # # #
######
```
**How it plays**: (1) normal stacking; on lock 4 the stars swirl. (2) After the 5th lock the stack turns a quarter; the gap you left on the left is now at the back. (3) The player keeps the top flat so the turn never matters, and uses puffs for careful fits. (4) Four clears; the islet stops.
**Teaches**: the hardest combination in the biome, built from known parts at the second-fastest speed.
**Readability**: the turn and the puff drift are separate beats: the turn happens at Resolving, the drift during a fall; the board never turns while a piece is in the air.
**Wacky test**: surprising, the whole stack turns; silly, dizzy Comet; funny failure, a perfect gap turns away just as the piece arrives; big moment, a clear right after a turn.

```json
{ "schema": 1, "id": "celestial_09", "biome": "celestial", "tier": 9,
  "board": { "width": 6, "depth": 6, "h_play": 10 },
  "knobs": { "fall.g0": 1.50, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 4 },
  "rules": [ { "id": "turntable", "params": { "turn_every_locks": 5, "turn_dir": "cw", "turn_warn_locks": 1 } },
             { "id": "balloon*", "params": { "balloon_per_bag": 1, "balloon_g_mult": 0.5, "balloon_drift_ms": 3000 } } ],
  "stars": { "t2": 325000, "t3": 230000 },
  "music": "celestial_09_tbd" }
```

---

### 10 The Top of the Sky (boss: the Sleepy Moon; the Hat Reveal) ★PROTO

**Story card.** The wizard's tower is the tallest thing in the sky, and the Sleepy Moon wants to sleep on it. Phase 1: gadgets from every old rival tumble out of the sky one after another (a gust, a drop, a slide). Phase 2: the Moon lowers its pillow onto your tower; every clear lifts it off again. The third clear makes it yawn, and the grand finale begins. · **Boss**: the Sleepy Moon; Comet watches from the rim.
**Stage**: busiest, yet soft; the top of the sky, the wizard's tower in the centre, Mizzle's crooked tower poking up from far below, the Moon on its pillow cloud right above. **Light**: first sunrise (pre-dawn blue warming to gold through the level; full dawn breaks in the payoff).
**Boss intro** (3 s, skits doc §10): 0.0–1.0 the Moon switches on the night-light and fluffs the clouds into a pillow; 1.0–2.0 it drifts toward the wizard's stack, ready to lie down on the top (`sleep`); 2.0–3.0 hand-off: Comet looks up at the wizard; glint; first piece.
**Payoff: the grand finale** (**14 s on first play, tap to skip; the 6 s core cut ◆ on replays**; skits doc §10, staging `visual-direction.md` §4.3):
1. ◆ 0.0–2.0 **The topple**: last clear. The Moon gives an enormous yawn; its wind tips Mizzle's crooked tower into a soft heap with him on top. A small drizzle cloud over his head; `tear`.
2. 2.0–3.5 **The reveal**: the last clear seats the 10th keepsake (the moon). The one big pull-back of the campaign: the stack is the wizard's hat. The mascots pop out of the hat one by one (`sparkle`). The Moon curls up on the brim and sleeps (`sleep`).
3. 3.5–6.0 **The flags**: the nine earlier bosses stand on the brim (curtain-call scale, biome order left to right, the Miller nearest the wizard and Mizzle), each holding its gadget. Each unrolls its flag; the Miller's goes up first. The flags join into one bunting; Boulder's mallet knocks the last knot tight (`sweat`, then `sparkle`).
4. ◆ 6.0–8.0 **The reading**: the camera slides along the ten panels. The bosses look at their gadgets, then at Mizzle: `question`, `exclaim`, sheepish `sweat` (never more than three bubbles at once).
5. ◆ 8.0–9.5 **The wave**: the Miller lifts his paw and waves, full and slow. Mizzle freezes: `dots`, then `blush`.
6. ◆ 9.5–11.0 **The chair**: the wand glints (the player's final clear, held over); one block flies to the heap and becomes a chair next to the wizard. Mizzle climbs down and sits.
7. 11.0–12.5 **The clink**: Pip and Mallow pass him a cup; Lana wraps him in a scarf; everyone raises a cup. Clink. Mizzle `heart` (his first).
8. ◆ 12.5–14.0 **The star**: [GC] the grumpy cloud turns pastel and settles beside him (`heart`). His hat-tip star lights, lifts off and flies to the tip of the wizard's hat. Dawn breaks.

Core cut (6 s): beat 1 (1.5 s) → beat 4 (1.5 s) → beat 5 (1.0 s) → beat 6 (1.0 s) → beat 8 (1.0 s). Reduced motion: no pull-back or bunting slide; cuts between held poses; the full bunting is shown at once for 2 s; the star simply appears on the hat tip. **Mizzle clue**: none extra (the finale is the thread's payoff). **Reactions (R)**: gadget lands `exclaim` (Comet); pillow warning: the Moon `sleep`; each clear: the Moon `gloom` and the pillow bobs up.

```text
Recipe: BL01 (7×7, H12) · AR01 · CV01 · GO01 (3) · FT01 (1) · CL01 + CO01 · EV15 Gadget Parade [pool: EV01 gust, EV04 + SP19 drop, EV09 slide] · EV06 Moon's Pillow (lid mode) · WO09
One sentence: "Old rivals' gadgets fall in; then the Moon lowers its pillow."
New to the player: EV15 (1). Every pool effect is known.
```
**Encounters**:
- **Gadget Parade** (rule notes in §1): a card every 6 locks, from a pool of nine gadget cards (three each of gust, drop, slide), no repeat until all nine have played. The first card is drawn at lock 5 and plays at lock 6. The gadget falls in at the rim with its flag, one lock ahead: the story telegraph; the hazard marker on the board is the gameplay truth.
- **Moon's Pillow** (EV06 lid mode): `lid_first_s` 90, `lid_every_s` 40, `lid_max` 2, `lid_warn_ms` 3 000, each clear lifts it 1 step. The pillow arrives about the time a steady player has made the first clear, so the two phases overlap only lightly. Fallback with no phase atom (as the Meadow and Lava did): the first-trigger delay is the phase switch.
- **Phase feel (decision)**: phase 1 is about clears 1–2 under the parade; phase 2 adds the pillow, which presses toward the third clear. Never two telegraphs on the same beat: a pillow step is delayed until the gadget's effect has resolved (validator check on the shared S4 order; §10).
- Pieces: I, O, T, L, Tripod, Screw-L, Screw-R, Chair (the finale set). A = 49 on a 7×7: F1 gives 392 s for Clear 3 → 335 / 235.
- The Moon is the face of the pillow only. The parade has no face: the gadgets come out of the sky, as if the rivals were throwing in their old tricks from off-screen, and in the payoff they turn out to be on the brim.

```text
top-down 7×7   side (z = 3)
#######        15 . . . S . . .   spawn zone
#######        12 ===============  danger line (the pillow lowers it to 11, then 10)
#######        11 - - - - - - -   pillow shadow on the top row (3 s warning)
###S###         :
#######         1 # # . . # # #   g = gadget marker (gust arrow / drop twinkle / slide arrow)
#######         0 # # # . # # #
#######
```
**How it plays**: (1) the first locks are calm; at lock 5 a party horn tumbles in at the rim with its flag. (2) Lock 6: a single gust pushes the piece. Six locks later a piping bag drops a gumdrop-star onto a twinkled cell; later a bath bomb makes the next piece slide. (3) About 90 s in, the pillow's shadow darkens the top row and the danger line drops a layer; a clear lifts it. (4) The third clear: the yawn, the topple, the hat, the flags, the wave, the chair, the dawn.
**Teaches**: nothing new to build with: the final exam of wind, drops, slides and pressure, wrapped in one new card rule.
**Readability**: one gadget at a time, one effect per card, three effect types with three different markers (arrow, twinkle, slide arrow). The pillow is the only thing that touches the danger line. If playtests find it too busy, lengthen `event_card_locks` to 8 or drop the slide cards (§10).
**Wacky test**: surprising, every old trick at once, but politely, one at a time; silly, a mixtape bouncing off the board edge; funny failure, the Moon snuggles down on the pillow when you use a warning; big moment, the pull-back to the hat and the first sunrise.

```json
{ "schema": 1, "id": "celestial_10", "biome": "celestial", "tier": 10,
  "board": { "width": 7, "depth": 7, "h_play": 12 },
  "pieces": { "shapes": ["i","o","t","l","tripod","screw_l","screw_r","chair"] },
  "knobs": { "fall.g0": 1.50, "goal.warnings_max": 1 },
  "goal": { "type": "clear_n", "N": 3 },
  "rules": [ { "id": "event_card*", "params": { "event_card_locks": 6, "no_repeat": true,
               "pool": [ { "card": "miller_lever", "event": "gust" }, { "card": "sniffles_horn", "event": "gust" }, { "card": "oak_chimes", "event": "gust" },
                         { "card": "meringue_bag", "event": "drop" }, { "card": "crab_bottle", "event": "drop" }, { "card": "cuckoo_stopper", "event": "drop" },
                         { "card": "smolder_bathbomb", "event": "slide" }, { "card": "geode_lanterns", "event": "slide" }, { "card": "mirrorball_mixtape", "event": "slide" } ],
               "gust": { "wind_strength": 1, "wind_warn_ms": 1000 }, "drop": { "skin": "star_rock" }, "slide": { "slide_cells": 1 } } },
             { "id": "lava_lid*", "params": { "mode": "lid", "lid_first_s": 90, "lid_every_s": 40, "lid_max": 2, "lid_warn_ms": 3000, "lid_push_per_clear": 1 } } ],
  "stars": { "t2": 335000, "t3": 235000 },
  "music": "celestial_10_tbd", "story": { "mascot_role": "boss", "icon": "moon" } }
```

---

### B Hat Box (bonus, tier 11, 20 celestial stars)

**Story card.** The wizard's old plain hat box is open, and the hat needs packing before bedtime. Pick the pieces from the kit in any order; undo is free. Five pieces, no spares. · **Comet: watcher** (wants to sleep in the box).
**Stage**: clean, calm; the inside of a round hat box, tissue paper, a lamp glow. **Light**: hat-box interior. **Intro skit** (3 s): Comet climbs into the empty box, turns three circles and lies down; the wizard's glint shoos it out gently (`note`); hand-off. **Payoff skit** (5 s, skits doc §10): 0.0–2.0 the last piece fits; the hat box lid closes. 2.0–4.0 Comet curls up on the lid, trailing sparkles (`sleep` is the Moon's in canon: the skits doc gives Comet `sleep` here, kept as written, flagged §10). 4.0–5.0 the lid lifts a little; a sparkle peeks out (`note`). **Postcard 10** (Scrapbook only): he practises a cast in a mirror; far off he spots the cloud wizard's drizzle. **Reactions (R)**: good pick `sparkle`; undo `question`.

```text
Recipe: BL01 (4×4, H6) · AR13 kit box [I, I, O, O, Big Cube] · CV01 · M2 fill shape (GO03 24 cells + CL14) · FT07 piece budget (5) · FT12 undo & reset · WO09
One sentence: "Pick the pieces in any order: pack the hat."
New to the player: nothing (AR13 Forest B, FT12 Ice B).
```
**Encounters**: none. The kit box shows all five pieces. Target: a 4×4 brim (16) and a 2×2×2 crown in the centre (layers 1–2, 8 cells) = 24 cells. Known solution: I along z0, I along z3, O at x0–1 z1–2, O at x2–3 z1–2 (the brim, any order), then the Big Cube on x1–2 z1–2 (the crown). The only trap: the Big Cube first lands in the brim. Stars: ★★ 90 s; ★★★ 60 s and no undo used.

```text
layer 0 (16)   layers 1–2 (4 each)   side (z = 1)
####           ....                  6 ======
####           .##.                  :
####           .##.                  2 . # # .   crown
####           ....                  1 . # # .   crown
                                     0 # # # #   brim
```
**How it plays**: (1) read the kit and the hat. (2) Pick the brim pieces first. (3) The Big Cube drops onto the brim and makes the crown. (4) The lid closes; Comet climbs on top.
**Teaches**: nothing new; it is the biome's wackiest gag (the hat inside the hat box is the hat the whole campaign was building).
**Readability**: target cells glow soft cream; used pieces grey out in the kit; undo rewinds with a little tissue rustle.
**Wacky test**: surprising, the "boss" is a sleepy fox in a box; silly, Comet's three circles; funny failure, the Big Cube flattens the brim and the box sneezes tissue; big moment, the lid closing.

```json
{ "schema": 1, "id": "celestial_bonus", "biome": "celestial", "tier": 11,
  "board": { "width": 4, "depth": 4, "h_play": 6 },
  "pieces": { "kit": ["i","i","o","o","big_cube"] },
  "knobs": { "fall.g0": 0.60, "spawn.arrival": "kit_box", "goal.top_out": "out_of_pieces" },
  "goal": { "type": "shape", "piece_budget": 5,
            "target_shape": { "layers": { "0": ["####","####","####","####"], "1": ["....",".##.",".##.","...."], "2": ["....",".##.",".##.","...."] } } },
  "rules": [ { "id": "undo_reset*", "params": {} } ],
  "stars": { "t2": 90000, "t3": 60000 },
  "solution": "see level notes",
  "music": "celestial_bonus_tbd" }
```

---

## 7. Hard-track remixes (tiers 12–14; open after 10)

### H1 Meteor Storm

**Story card.** The meteor drizzle turns into a storm, and the solar wind changes direction every gust. · **Comet: watcher** (an umbrella of a leaf, upside down). **Light**: nebula. **Intro skit**: Comet opens a tiny umbrella; a star-rock lands in it and turns it inside out (`exclaim`). **Payoff skit**: the rocks settle into a crown on Comet's head; it admires itself in the Moon's reflection (`sparkle`).

```text
Recipe: BL01 (6×6, H10) · AR01 · CV01 · GO01 (5) · FT01 (1) · CL01 + CO01 · EV04 Meteor Drizzle + SP19 (every 5 locks, max 4) · EV01 Solar Wind (rotating, 9 s ± 2.5 s)
```
```text
top-down 6×6       side (z = 2)
######  ↑          10 ============
######             :
##S###  ← →        1 # r . # # r   r = star-rock
######             0 # # . # # #
######
######
```
Pieces 8 Std; `g0` 1.45; Clear 5; ★★ 410 s, ★★★ 290 s (~8 min).

### H2 Dark Side

**Story card.** The cube islet drifts into the Moon's shadow: choose which way down, and remember where you put it. · **Comet: watcher** (sleeps on the bottom face, upside down). **Light**: eclipse. **Intro skit**: Comet walks round the cube into the dark and only its sparkle tail is seen (`note`). **Payoff skit**: the cube turns back into the light, every face lit; Comet is still asleep on the bottom.

```text
Recipe: BL01 (6×6, H6 cube) · AR01 · CV19 Every Way Down · GO01 (3) · FT01 (1) · CL01 + CO01 · EV02 Eclipse (visible 4 000 ms, fade 1 000, alpha 0.15, reveal 700)
```
```text
top-down 6×6     side (z = 2)
######           6 ============
######           :
##S###           3 ~ . . . . ~   ~ = faded pieces parked on walls
######           0 ~ # # . # #
######
######
```
Pieces 8 Std; `g0` 1.35; Clear 3; hand-set ★★ 260 s, ★★★ 185 s (~5 min). Alpha raised to 0.15 because wall-parked cubes are harder to keep in mind than floor cubes.

### H3 Twin Moons

**Story card.** Two little islets, each with a puff of zero-g; one star drizzle. Send each piece to the islet you pick, and clear 3 layers on each before either overflows. · **Comet: watcher** (jumps between the islets, floating). **Light**: pre-dawn. **Intro skit**: Comet floats from one islet to the other and back, and gets stuck halfway (`question`). **Payoff skit**: two tiny moons rise from the islets and Comet balances one on its nose.

```text
Recipe: BL07 (2 islands, 4×4 each, H8; tap an islet to send the piece) · AR01 · CV01 · GO01 (3 per islet) · FT01 (1, shared) · CL01 + CO01 · EV10 Zero-G Puff (1 per bag)
```
```text
islet A    islet B      side
####       ####         8 =====      =====
####  ~~   ####           :            :
####       ####         0 . . . .    . . . .
####       ####
```
Pieces 8 Std; `g0` 1.40; Clear 3 per islet; ★★ 220 s, ★★★ 155 s (~4.3 min). The puff's slow fall gives time to pick an islet.

---

## 8. Narrative beats

Wordless (campaign story rules): intro and payoff skits per level, Comet's reactions, the Moon in the backdrop from 01 (lower and drowsier each level), Mizzle's tower on a far marble step, and one Mizzle clue per level in slots 03–09 (at most 1.5 s, at the rim, never over the grid, never during a warning, lit by a soft spotlight pool with no camera move). Arc: Comet lights the first star (01), beds the star-sheep (02), chases them down the causeway (03), dodges meteors (04), climbs to the Moon's height (05), draws its own tail (06), lights the eclipse (07), walks every face of a cube (08), rides the drifting islet (09), and helps the wizard win the top of the sky (10), where everything lands. The bonus and remixes are after-party gags.

| Level | Mizzle clue (strength cap 3; `dialogue-campaign-skits.md` §10) | Emote |
|---|---|---|
| 03 | He builds his tower at the rim, one clean cube at a time | `idea` |
| 04 | He watches the wizard's stack and matches his tower's height to it | `dots` |
| 05 | [GC] The grumpy cloud on the wizard's cloud spots his star-stamped card, perks up (delete the beat and 05 has no clue) | grumpy cloud `exclaim` |
| 06 | He sets a tiny chair on his tower's top floor, straightens it | `dots` |
| 07 | He holds the star-stamped card out toward the wizard, loses his nerve, pockets it | `sweat` |
| 08 | A comet streaks by; he and Comet both look up at the same time | `blush` |
| 09 | The Moon drifts past his tower, sniffing at its height; he steadies it | `sweat` |
| 10 | ★ The grand finale (§6, 10), the thread's payoff | `tear` → `heart` |

**Arrival** (map, 4 s, skits doc §10): the cloud rises into indigo sky up the star stairs; Comet trots down trailing sparkles and yawns (`note`); above, the Moon cuddles the ribboned night-light, eyeing the tallest stack; on the horizon, Mizzle's crooked tower, almost straight.

**Map change** (3 s; the last main-campaign change): the camera pulls up and the whole map is the hat's brim; the full bunting runs through every island, Meadow to Celestial; Mizzle's chair sits by the wizard's cloud with Mizzle in it, [GC] the grumpy cloud is pastel, the hat tip's star glints; a tiny violet mail-cloud sets off from the map's edge (the hand-off to Drizzle Rock).

**Friend cameos** (backdrop only, no gameplay): Lana's yarn on the star stairs' rail (03), Boulder's hard-hat lamp on a far step (07), Glim's blueprint of the hat pinned to the orbit tower (05; brief §5: her blueprint is the plan for the Celestial hat). Each is static dressing and never a clue.

## 9. Music and audio cues

One track per level, supplied by the user; ids are placeholders (`celestial_01_tbd` … `celestial_10_tbd`, `celestial_bonus_tbd`; H1–H3 reuse `celestial_04_tbd`, `celestial_08_tbd` and `celestial_05_tbd` until the user provides new ones). Until the tracks arrive, every Celestial level plays the biome `default_music` ("Carefree" is a placeholder only). No stems and no layered mixes. Authoring notes for the user's tracks: 01–02 a soft lullaby; 03–04 a little brighter with the wind and the meteors; 05 floaty (no danger music, the level cannot be lost); 06 near-silent music box; 07 hushed; 08 sparse and curious; 09 a slow waltz; 10 the biggest track of the campaign, ending on the dawn; the bonus a tiny lamp-lit tune. The grand-finale skit uses the level's own track (or a user-supplied finale track id) with no voices. A **danger stinger** only where `topout_rule` is rescue. Skits use short stingers, never voices.

SFX cues (one-shots): a soft "tink" when a star-rock lands; a puff "fwoop" when a Zero-G piece drifts; a whoosh plus a little "thock" when a piece travels to a wall in 08; a slow star swirl one lock before a turn (09); each gadget card has its own biome's signature one-shot (the mill creak, a squeaky piping bag, a party horn, a bottle clink, a bath fizz, a chime, a lantern clink, a cuckoo, a record scratch); the Moon's slow breathing in the backdrop, with a yawn before the pillow lowers; the clink and the dawn chime in the finale. The SFX pack (MB-003) provides the base sounds.

## 10. Open questions

- **New atoms used, still Candidate / Proposed**: EV10 Zero-G Puff (Candidate; full rule in §1, rule id `balloon*`), CV19 Every Way Down (Proposed, L cost; here with CL01 layers and CO01 only, so CL15 and CO09 are not needed), EV15 Gadget Parade (Candidate; the pool-of-known-events form), EV06 lid mode (EV06 is Designed only as MG13; the Lava file's campaign form and this lid form need a GDD entry). All move into owning GDDs before build. Owner: game-designer.
- **CV19 needs**: the `control.verb` plugin with `set_travel_dir`, the ghost and arrow for five directions, a top-out rule for the cube, and confirmation that CO01 slice collapse drops wall-parked cubes (a cube with an empty cell below it may legally float on a wall). Owner: game-designer / ADR-0002, ADR-0012 (the swipe gesture and its keyboard/gamepad mapping).
- **08 speed** is 1.30, 0.155 below F2's 1.455 (outside ±0.05) on purpose: a new five-way verb at the second-fastest speed of the game would read as unfair. Confirm or raise after the prototype.
- **EV15 pool atoms and F1**: counting each pool event (EV01, EV04, SP19, EV09) toward nd puts 10 exactly at the showpiece cap of 6. If the validator counts the parade as one rule, 10 drops to 3. The module may want "Mystery card + its pool" as a bundle. Owner: game-designer.
- **Phase 2 overlap (10)**: the pillow's `lid_first_s` 90 is the phase switch (no activation atom; Lava proposed `active_after_clears`). The rule "a pillow step waits for a gadget effect to resolve" needs a shared order check (S4 order, ADR-0011 §3). If 10 is too busy, `event_card_locks` 8 or drop the slide cards.
- **Lore vs skits conflicts (flagged, skits doc followed as briefed)**: `lore-world.md` §7 puts clues at 01 (sleepy mail-cloud), 03, 05, 06, 08 (night-light parcel in zero-g) and **09 "the nine bosses gathering at the edge"**, which breaks the user ruling (bosses appear only as grand-finale guests). This file uses the skits doc slots 03–09. Lore's island order (zero-g drift at L6–8, gravity-everywhere at L9) is also swapped here: every-way-down sits at 08 so 09 can be the remix. Owner: narrative-director.
- **Lighting**: `visual-direction.md` §3.2 (six presets) is followed; `lore-world.md` §3.10 F (eight presets) differs. Owner: art-director.
- **"First sunrise"**: lore X3 rewords it as "the first sunrise since the Lava dusk" (Meadow 08 has a sunrise). Used that way in §1.
- **Comet `sleep` in the bonus payoff**: the skits doc gives Comet `sleep`, but §0.4 lists `sleep` for Oak, Geode and the Moon only. Kept as written; narrative-director to confirm.
- **Grand finale length**: 14 s first play exceeds the 6 s finale cap (user default, still "to confirm" on the decision sheet). The 6 s core cut is ready.
- **Skills in puzzles**: Redraw (Glim) re-rolls the next pieces, which has no meaning in a fixed list (06) or a kit box (B). Suggest the skill rule is `off` there (WO14, mode data, not a level atom). Owner: characters-perks / systems.
- **F1 recount**: "new to the player" assumes the Meadow, Candy, Ice, Underwater, Lava and Forest files; Cave, Clockwork and Neon were not written yet. If any of them uses EV10, CV19 or EV15 first, the counts here only go down; if they teach none of the parade's events differently, nothing else changes.
- **06 and B `solution` lists**: the validator should replay the known solutions in §6.
- **Star times** are formula estimates (hand-set where noted); replace with playtest medians.

---

## Hard-track remixes (tiers 12–14)

> **Wave-3 revision (level-designer, 2026-10-10). Supersedes the §7 drafts** (Meteor Storm, Dark Side, Twin Moons) per Campaign Structure rule 17: each remix recombines 1–2 Celestial rules **plus exactly one wave-3 mechanic** (`design/gdd/mechanics-wave3.md`). Twin Moons is dropped because islands (BL07) are not in the runtime rule catalog; Dark Side's Every Way Down is left out to keep one new verb per level. Twist cap held: 2 twists, no level mechanic. Runtime files: `src/levels/celestial/celestial_h1..h3/`.
>
> **Hard-track star rule:** `t2 = round5(0.80 × t_est)`, `t3 = round5(0.55 × t_est)` (F1 uses 0.85 / 0.60), with `t_est = N × A × 2.667 s`. Tier 10 is 335 / 235 s; these are tighter per unit of work and run at `g0` 1.45–1.50.

| # | id | Name | Recombines | Wave-3 (biome event) | Goal | Board | g0 | ★★ / ★★★ |
|---|---|---|---|---|---|---|---|---|
| H1 | celestial_h1 | Meteor Storm | Solar Wind (03), rotating | `storm_bolt` (**Meteor**) | Clear 5 | 6×6, H10 | 1.45 | 385 / 265 s |
| H2 | celestial_h2 | Wishing Eclipse | Eclipse (07) | `mystery_piece` (**Wishing Star**) | Clear 4 | 6×6, H10 | 1.45 | 305 / 210 s |
| H3 | celestial_h3 | Constellation Shuffle | Drifting Islet (09) | `jumbled_queue` (**Constellation Shuffle**) | Clear 5 | 6×6, H10, preview 3 | 1.50 | 385 / 265 s |

### H1 Meteor Storm

**Story card.** The solar wind swings round the sky and meteors start falling with it. A meteor marks a column, then knocks the top cube off it. · **Comet: watcher** (a leaf umbrella, turned inside out).
**Idea recombined**: Solar Wind (`gust`, `wind_mode` rotating, 9000 ± 2500 ms, strength 1, warn 1000).
**Wave-3**: `storm_bolt` as the **Meteor**: `bolt_interval_ms` 8000, `bolt_warn_ms` 1500. A glowing trail marks the column 1.5 s ahead; the strike removes that column's highest cube. Meteors never hit the falling piece.
**Goal**: Clear 5 on 6×6, H10, 8 Std, `g0` 1.45.
**Wacky test**: surprising, the hazard that eats cubes can also dig out your own mistake; silly, the knocked-off cube bonks the Moon's nightcap in the backdrop; funny failure, a meteor knocks the last cube off a nearly-full layer and a gust blows the replacement piece past the gap; big moment, a meteor deleting a single overhang so the next I fills a buried hole.
**Counterplay**: keep the top of every column flat and full (a bolt only removes one top cube); park bad overhangs where the trail is about to land; drop during the 1 s wind warning, not after.
**Star rationale**: t_est = 5 × 36 × 2.667 = 480 s → 385 / 265 s.

### H2 Wishing Eclipse

**Story card.** The islet slips into the Moon's shadow and the stack fades. Every fourth star in the queue is a wishing star: it shows as "?" and you only learn what it is when it falls. · **Comet: watcher** (makes a wish with eyes shut, every "?").
**Idea recombined**: Eclipse (`fog`, skin eclipse, visible 4000, fade 1000, alpha 0.15, reveal 700; alpha raised from 07's 0.12 because the "?" already removes planning).
**Wave-3**: `mystery_piece` as the **Wishing Star**: `every` 4; pool is the level's 8 Std shapes, never the shape it replaced.
**Goal**: Clear 4 on 6×6, H10, 8 Std, `g0` 1.45.
**Wacky test**: surprising, you do not know your piece and you cannot see your stack; silly, the "?" twinkles and Comet crosses its paws; funny failure, the wish reveals a Tripod over a hole you forgot was there; big moment, the reveal lands an I into a faded four-long gap you remembered.
**Counterplay**: keep one flat "any shape" landing zone for each "?"; the reveal is at spawn, so there is still full fall time to aim; a clear re-lights the stack (fog reveal) and gives you back your memory.
**Star rationale**: t_est = 4 × 36 × 2.667 = 384 s → 305 / 210 s.

### H3 Constellation Shuffle

**Story card.** The drifting islet turns in its sleep, and every time it turns the stars in your queue swap places like a shuffled constellation. · **Comet: watcher** (counting stars, losing count on each shuffle).
**Idea recombined**: Drifting Islet (`turntable`, every 5 locks, clockwise, wind-up 1 lock ahead).
**Wave-3**: `jumbled_queue` as the **Constellation Shuffle**: `every` 5, with `spawn.preview_count` 3 so the shuffle is visible (the rule needs ≥ 2). Both rules count 5 locks, so they share **one beat**: lock 4 shows the star swirl on the rim and the queue's jumble warning together; lock 5 turns the islet and shuffles the queue. One telegraph, two effects on different channels (board vs preview).
**Goal**: Clear 5 on 6×6, H10, 8 Std, `g0` 1.50 (the biome's top speed).
**Wacky test**: surprising, your plan for the turned board is made with pieces that are about to swap; silly, the queue's stars draw a quick constellation (a fox) as they shuffle; funny failure, you leave the turned gap for the I and the shuffle sends it to the back of the queue; big moment, a shuffle that brings the I to the front just as the turn rotates its gap under the spawn.
**Counterplay**: plan for shapes, not order: on the warning lock, build a surface that takes any of the three previews; the shuffle never changes which pieces come, only when.
**Star rationale**: t_est = 5 × 36 × 2.667 = 480 s → 385 / 265 s.

**Audio**: one-shots only: a rising whistle and a soft "tink-crack" for a meteor; a twinkle chime on each "?" reveal; a harp glissando on the shuffle (paired with the turn's star swirl). Tracks `celestial_h1_tbd`…`celestial_h3_tbd` are placeholders (play `celestial_04_tbd`, `celestial_07_tbd`, `celestial_09_tbd` until supplied).
