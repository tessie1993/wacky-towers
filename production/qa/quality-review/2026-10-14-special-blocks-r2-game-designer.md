# Special Blocks and Objects, round 2: Game Designer review (blind, fresh)

Reviewed: `design/gdd/special-blocks-and-objects.md` (DRAFT r2). Marked as a PLAN (panel rule 1): is it clear, complete, testable, consistent, and could a maker build from it. No paper-only cap applied. Context read: `levels.md` (objective table, lines 489-506), `reference-quality-bar.md`. I did not open `level-identity-spec.md` or `reference-minigames-catalog.md`; I did not open any file in `production/qa/quality-review/`. Every item starts at 5 and earns points only for quoted evidence. Pass is 9.7 on every item.

## Scoreboard

| # | Item | Score | Pass (9.7) |
|---|---|---|---|
| 1 | Player fantasy and fun of the specials | 7.3 | FAIL |
| 2 | Teaching curve and pacing across Meadow and the chapters | 6.5 | FAIL |
| 3 | Variety and biome identity | 7.0 | FAIL |
| 4 | Clarity and readability to the player | 6.8 | FAIL |
| 5 | Fit with level rules | 7.0 | FAIL |

Verdict: FAIL on all five. No cross-item averaging.

---

## 1. Player fantasy and fun of the specials: 7.3

**Evidence for the score**
- Fantasy line is clear and tied to pillars: "Every block has a personality... a toy-box builder, not an accountant" (:41), pillars named (:50). +
- Hazards "naughty, not cruel", warn first (:47), enforced as a rule: telegraph rule (:70), clear rule (:71). +
- r2 fixed the worst fun defect: goo was free fill, now a sticky blocker with a wash (:349-363), so it has a threat and an answer. +
- Every entry carries a Fairness line with a counterplay (e.g. pest :373). +
- Per-special feeling beats exist: bomb "grin then plan", bounce "the whole board giggle" (:44-45). +

**Why not 10**
- Section 2 is 11 lines for 120 ids (:40-50). There is no emotional arc across a level, a chapter or the campaign, and no per-biome fantasy. Shapes (SH), skills and most objects have no stated feeling. Nothing says what the player FEELS at the 14 shapes or 43 objects.
- The fantasy "every block has a personality" is not delivered in Chapter 1. By the user's own decision, teach levels 01-10 keep core objects only (:1970, :2070); h2 mushroom and h3 egg are the only block personalities in 14 meadow levels (:1990-1991). The doc never flags this as a tension between the fantasy and the decision. Open question for the user.
- Goo still has four jobs: block, stick, spread, wash (:352-356). The doc says "one job" (:352) but lists four mechanics, and the wash needs a clear in layer k-1 or k+1, not its own layer (:354). That is a hard idea to enjoy.
- Items: "a tap-for-a-surprise jackpot" (:48) but `p_item` is 0.06 in Candy (:1431). No rule says how often a player actually sees one in a 10-level chapter. Reward feel is unmodelled.
- No expression/creativity beat (SDT autonomy): few specials offer more than one good answer; many are "clear next to it" (:372, :361, :398, :464, :499).
- Fun is asserted by tags, not by a playtest-facing target. AC30 (:1965) is the only fun test.

**Ranked fixes**
1. Expand section 2 into per-group and per-chapter fantasy with an MDA aesthetic target for each (Discovery, Challenge, Expression), and write the feeling for shapes, objects and items. Owner: game-designer.
2. Raise the Chapter-1 tension to the user as an explicit decision: the fantasy line versus "core objects only". Offer one safe personality block (for example the bounce pad, already at meadow_08 :1409) as a named teaser. Owner: game-designer, decision by user.
3. Cut "clear next to it" repetition: give at least 4 hazards a second answer (placement-based or item-based) so autonomy exists. Owner: game-designer with systems-designer.
4. Replace "one job" wording for goo with the true list, or move the wash/stick to separate shell kinds. Owner: systems-designer.
5. Add an items-per-chapter expectation (drops seen per level at `p_item`). Owner: economy-designer.

---

## 2. Teaching curve and pacing across Meadow and the chapters: 6.5

**Evidence for the score**
- One-new-package-per-level rule with a formula: `new(n) <= 1`, `A_max(n) = min(A_cap, 1 + floor(n/6))` (:1573). +
- The Meadow table (8.1, :1976-1991) names new/recalled/layers/A-over-A_max per level and checks against framework knobs (`rules.max_level_mechanics` 1, `max_twists` 2, :1571). Meadow_06 is a rest level; meadow_10 recalls only; bonus recalls (:1409). Scaffolded, one idea per level. +
- Hints are under 12 words and teach by sight (:157, :333, :344). +
- Acceptance 30 (:1965) and AC24 (:1953) make the curve testable. +

**Why not 10 (defects)**
- The F1 rule is broken by the doc's own tables. Candy slot 03 adds OB-21 syrup band AND three items (IT-01, IT-03, IT-04) (:1410, :1431). F1 counts "one item class that the player must plan around" as a special (:1569). That is 4 new things in one level against `new <= 1`. Candy slot 05 adds frosting + sponge + the bomb item (:1410, :1431). Clockwork slot 05 adds turntable AND piston plus the grip item (:1417, :1438). Ice slot 04 adds thin ice plus hammer (:1411, :1432). AC24 (:1953) is only run against the 12 Meadow levels, so these breaches pass unnoticed.
- The curve is front-loaded and then flat. Candy lists 12+ new specials (:1410), Meadow 12, but Ice 6, Cave 7, Carnival 6 (:1411, :1416, :1420). `A_max` depends on the level index n only, not on the chapter (:1579), so chapter 12 slot 1 is capped like chapter 1 slot 1 and nothing tracks that the player already knows 11 chapters of rules. No sawtooth across chapters is defined.
- Gaps in the ladder: ice slots 07-10, underwater 05 and 08, pirate 04, 07, 09 have no stated content (:1411-1413). The reader cannot tell whether they are rest, recall or an omission. No chapter-level pacing statement exists.
- Teach lines are not tied to slots. Pest: "Mid-chapter" (:372) versus forest slot 05 (:1415). Goo: "One biome level after the player knows clears" (:361) versus candy slot 08 (:1410). Rainbow: "Candy tier 2 where colours matter" (:600 region) versus slot 07. Shell: "after tier 3" (:530 region). "Tier" is never defined in the doc.
- Entry Fits disagree with the schedule: BK-08 pest "Forest and candy" (:371) but the candy row has no BK-08 (:1410); goo "candy, forest, underwater, lava" (:360) but only candy is scheduled and ice, pirate, clockwork, celestial ban it (:1411, :1413, :1417, :1419) while forest, underwater and lava rows do not list it at all.
- h2 and h3 have no written base levels: "assume at most 2" (:1990-1991). The two levels that host the only Chapter-1 personality blocks cannot be checked.
- No difficulty curve statement for hazards across the 14-level chapter, only F2 interval decay (:1587). Item `p_item` rises 0.06 to 0.12 and stops at chapter 8 (:1431-1439), so chapters 9-12 have no item growth.

**Ranked fixes**
1. Make F1 count items and sub-packages, and add the Candy 03/05, Ice 04 and Clockwork 05 rows to AC24; re-slot items so no level adds more than one new thing. Owner: game-designer.
2. Add a per-chapter pacing table (rest, recall, new, boss) for all 12 biomes and fill every empty slot. Owner: level-designer.
3. Replace every "mid-chapter / tier N / early" teach line with its 3.4a slot id; reconcile all Fits against 3.4a. Owner: game-designer.
4. Define a chapter-aware cap (A_max by chapter and slot) and a sawtooth target. Owner: systems-designer.
5. Write the h2/h3 base-level frames or mark the rows BLOCKED. Owner: level-designer.
6. Define "tier" or delete it. Owner: game-designer.

---

## 3. Variety and biome identity: 7.0

**Evidence for the score**
- Every biome has a named signature: lava rise/ember, neon laser sweep, celestial gravity well, carnival swing ball (:1414, :1418, :1419, :1420, :1422). +
- Banned-per-biome column protects identity (ice no goo/fire, :1411). +
- A kind keeps one silhouette/badge and only changes material per biome (:76), with skin examples per entry (goo :358, pest :369). +
- 101 minigames are all mapped, with OUT verdicts and reasons (:1445-1497). +
- Pirate skin is decided as a commission (:76, :1413). +

**Why not 10**
- Pirate has no block skin (the sheet shows 12 skins and none for pirate, :76); AC20c (:1945) makes it NOT ASSESSED, so the biome identity is unproven and cannot score above that.
- Signatures are mostly recycled mechanics: pirate's new set is balloon, anvil, spiked, golden row, squirrel, tentacle (:1413) and slots 04/07/09 are empty; pirate recalls tilt and core from Meadow (:1413). Carnival is "many" recalls with "none" banned (:1420). Cave and Ice have 6-7 items. Identity per biome is uneven: Candy has twice the personality of Ice.
- Same item across biomes by skin only: pest, goo, balloon, bubble reappear as "ant/beetle/crab-lice/worm" (:369). The doc's own scene-variety rule (reference-quality-bar.md: "reskin counts as the same scene") applies: skins alone do not add variety.
- Three flame-like hazard badges (BK-23c flame, BK-28 ember spark, BK-36 floor flame, :1510, :1518, :1527) and two spring badges (BK-05 coil spring, BK-31 squash spring, :1508, :1515) blur identity inside one chapter (lava slots 02, 06 and h1; candy slot 04).
- No per-biome emotional identity (Aesthetic) line; identity is stated as lists of ids.
- 11 of 14 shape ids appear in biomes 2-12 only through one-line mentions (:1997); no biome has a stated shape-bag identity.

**Ranked fixes**
1. Add a one-line fantasy and a shape-bag identity per biome to 3.4a. Owner: game-designer with level-designer.
2. Fill every empty slot with a biome-specific recall or twist; raise Ice, Cave and Carnival to at least one signature per 3 levels. Owner: level-designer.
3. Commission the pirate skin now and gate the plan item on its capture (GAP-9). Owner: art-director, technical-artist.
4. Differentiate the three flame hazards by function (one burns, one grows, one is a floor tile) and by silhouette. Owner: art-director.
5. Where a reskin is the only difference, say so and do not count it as variety. Owner: game-designer.

---

## 4. Clarity and readability to the player: 6.8

**Evidence for the score**
- 0.5 s read test with three signals (silhouette, loop, rim colour) and a colour-role scheme (:69). +
- Telegraph rule for every hazard (:70) and a fairness formula for hidden timers: `T_warn_min` = 1110 ms (:1625, :1638). +
- See-through rule for goal objects, with render-layer detail (:1501). +
- Badge sheet with one badge per special (:1505-1531) and reduced-motion/colour-blind acceptance (:1966-1967). +
- Hints are short and visual (:157, :333). +

**Why not 10**
- The badge sheet breaks its own rule. The doc says "None reuses a biome hero ornament (... snowflake ... diamond circuit ...)" (:1503), then assigns BK-35 "six-arm snowflake" (:1517) and BK-33 "diamond" (:1515). The ice biome ornament is a snowflake and neon's is a diamond circuit (:2006). Verified collision, an open defect.
- Colour overload: gold ("reward") is shared by egg, gem, key, mole nose, gift box, peg, hook loop, and candy bomb's rim (:1509-1524), and the see-through outline is also gold (:1501). Hazard orange covers about 14 badges. With the 3.1 rule "colour never alone", the remaining discrimination is the badge, at 28-60 px (:69). Complex badges (crowned bear BK-17, ball-on-chain, ice-shell crack with padlock tab BK-23a, :1521, :1526) cannot read at 28 px.
- Near-duplicate silhouettes inside one biome: BK-22 thorned tendril and BK-23f spike fan; BK-20 padlock and BK-23a padlock tab; BK-37 ring pit and BK-40 post and ring; SH-05 hook and BK-42 hook loop (:1524-1528).
- Hints that say too little or the wrong thing: goo hint "A clear next to goo washes it off" (:361) is false for a goo cell's own layer; the wash needs layer k-1/k+1 (:354). A new player cannot infer which layer.
- The hidden-timer rule (:2071, :1952) removes the HUD countdown. The only cues are an actor tell and a sound (:1951). No accessible visual cue is set for deaf players; AC31-32 test motion and colour but not sound-off.
- Preview/ghost UI is 8 days of NEW work (GAP-8, :1548); two of the first 12 levels depend on it (meadow_08 hop ghost, meadow_09 tilt preview). Without it, clarity fails in Chapter 1.
- Measurable read thresholds exist (AC4, AC30) but no pass number for badge recognition in a real stack with fog or translucent pieces beyond the banned-combination row.

**Ranked fixes**
1. Replace the BK-35 snowflake and BK-33 diamond badges, and re-check all 47 badges against the hero-ornament list. Owner: art-director.
2. Split gold: reward gold for collectibles, a different outline colour for see-through goal objects. Owner: art-director, ui-designer.
3. Fix the goo hint and add a wash preview (highlight the neighbour layer). Owner: ux-designer, game-designer.
4. Add a sound-off equivalent visual tell for every ms hazard to AC23. Owner: ux-designer, audio-director.
5. Redraw the complex badges at 28 px and record a retained capture per special. Owner: technical-artist.
6. Move the preview/ghost UI (GAP-8) ahead of meadow_08/09 in the order of work (:1559). Owner: producer, ui-programmer.

---

## 5. Fit with level rules: 7.0

**Evidence for the score**
- The doc states "no 'clear N layers' goal" as a rule it obeys (:38) and uses the `levels.md` ladder as the source of truth (:1972). +
- 8.1 lists per-level shapes with reasons, as `level-identity-spec.md:141` requires (:1972). +
- Meadow hints and goals read as scene actions: "Drop the ring over the post!" (:157), `ring_toss`/`tiles_owned` goal evaluators (:2095), none a layer count. +
- `levels.md` objectives (:491-504) are used in the meadow table names (Stump Day, Brook Run, ...). +
- Pillar and decision traceability (Appendix B, E). +

**Why not 10**
- The doc never reproduces or checks the HUD objectives (12 words or fewer, no counts, `levels.md:489`) for any special. No special carries a story objective line; no check ties a special to the objective it serves.
- For chapters 2-12 the schedule is special-first: 3.4a lists "new specials by slot" and the levels are "PROPOSED for the level designers to confirm" (:1403). Names come from legacy `catalog.json` "that predate the identity spec" (:1403). Under the rule "a level is a scene" the scene should decide the special, not the other way round. The doc inverts the order that `levels.md` (and reference-quality-bar.md: "the level decides the art") sets for chapters 2-12.
- Legacy goal text survives: "`clear_n` goals" in the older meadow JSONs (:1999) and ACs written in layer terms (AC6, AC11, AC29c: "layer_full false while goo is present", :1926, :1931, :1962). They are rule tests, not goals, but several hints expose layer language to the player ("layer cannot be full", :353).
- Surprising endings and a "platform of its own" per level are not addressed: every special is placed on a standard board, and Matrix C targets cells in layers. There is no per-special platform note.
- F1 `n` indexes by slot (:1577), so the budget ignores scene-specific needs; boss levels count per phase (:1583), a convention not in `levels.md`.
- Items drop at random by `p_item` (:1426), which has no scene or story reason.

**Ranked fixes**
1. Add a column to 3.4a and 8.1 with the HUD story objective for each level (12 words or fewer, no counts) and check each special serves it. Owner: level-designer with narrative-director.
2. Flip 3.4a from "specials by slot" to "scene first, then the special it needs"; mark every non-Meadow row BLOCKED until the identity-spec scene exists. Owner: level-designer, game-designer.
3. Strip layer words from player-facing hints; keep them only in rule tests. Owner: ux-designer.
4. Give story reasons for item drops (a pickup in the scene) or limit them to bonus levels. Owner: game-designer, narrative-director.
5. Add a platform/footprint note per signature special (the board it needs). Owner: level-designer.

---

## Merged top fixes (all items)

1. Break the F1 rule: Candy 03 and 05, Ice 04, Clockwork 05 (items + packages in one slot). Game-designer.
2. Fix the badge collisions (BK-35, BK-33) and the gold overload. Art-director.
3. Chapter-aware pacing table with every empty slot filled and teach lines mapped to slot ids. Level-designer, game-designer.
4. Expand Player Fantasy to per-group and per-chapter, and raise the Chapter-1 personality tension to the user. Game-designer.
5. Scene-first 3.4a with story objectives. Level-designer, narrative-director.
6. Reconcile entry Fits with 3.4a (goo, pest). Game-designer.
7. Pirate skin and GAP-8 preview UI sequenced before dependent levels. Producer, art-director.

## Open question for the user

Does "Remix in hard levels" (Appendix E) mean no block-kind personality at all in Meadow 01-10, or are the pad (08) and fog (07) counted as core? The doc is ambiguous: Appendix E says core objects only, 3.4a schedules BK-05 at slot 08.
