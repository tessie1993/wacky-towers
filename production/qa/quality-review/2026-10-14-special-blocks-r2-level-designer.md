# Special Blocks and Objects, round 2: Level Designer review (blind)

Thing reviewed: `design/gdd/special-blocks-and-objects.md` (DRAFT r2), marked as a PLAN (panel rule 1: the paper-only cap does not apply; open defects cap an item at 8.5). Context read: `design/levels/levels.md` (meadow frames, lines 64-130 and the ladder at 453-504). Not read: any other file in this folder. Pass = 9.7. Every item starts at 5 and earns points only with quoted evidence.

## Scoreboard

| # | Item | Score | Pass (9.7)? |
|---|---|---|---|
| 1 | Usefulness for authoring real levels (Meadow 1-10) | 7.0 | FAIL |
| 2 | Placement and density rules | 6.5 | FAIL |
| 3 | Per-level platform and scene support | 5.5 | FAIL |
| 4 | Biome spread and signature specials | 7.5 | FAIL |
| 5 | Coverage of the reference minigames | 7.5 | FAIL |

Overall: FAIL. All five items are below the bar.

---

## 1. Usefulness for authoring Meadow 1-10: 7.0

**Earned.** Section 8.1 (`:1976-1987`) is a per-level table with package, recalled items, rule layers, A/A_max, new count, proposed shapes and a reason for each of meadow_01 to meadow_10. That is the right fixture. The F1 budget with its framework limits (`:1571`, `knobs/rules.json:6-7`) is checkable. Entries follow one fixed field order (`:138`). Engine status is given per entry (`:771`, `:973`, `:1066`). Fairness and telegraph are stated (`:70`, `:770`).

**Why not 10 (defects a maker would hit).**
- A level author needs per-level numbers and gets a catalogue. Nothing says how many sheep in meadow_04, how many pen gates, which `core` cells in meadow_02 (`:764` only says "the level sets `core` to those cells"), how many hedge rows or holes in meadow_05 (`:967`), how many pads or lambs in meadow_08, which stalks in h1. Every Meadow level still needs a second spec that does not exist.
- 4 of the 10 Meadow teach levels are blocked by unbuilt engine work. OB-37 is 5-6 days core work (`:1066`), OB-27/28/BK-39 herd is NEW (`:947-958`), OB-29 hedge wall is NEW (`:973`), OB-30 lamb is NEW (`:984`), moving platform G8 is 13.5 days (`:1553`). The doc does not say which Meadow levels can be authored today and which wait. A maker cannot start meadow_01 to 10 in order without a "buildable now" column.
- The 8.1 shape lists are "proposed unless stated" (`:1972`) and the solver proof is deferred (`:1958`, AC27). The shape lists are not authoring data yet.
- Matrix and GAP detail is large (`:1298-1398`, about 100 lines) but Meadow uses almost none of it. The reader has to dig for what Meadow needs.
- The doc is 265 KB. The two mixed-layer rows (meadow_02 "mechanic defend_core, twist gust" at `A=1/1`, `:1979`) show the package/layer counting is easy to misread: one package spans two layers, so "1 / 1" hides that the level uses 1 mechanic + 1 twist.

**Fixes (ranked).**
1. Add a Meadow authoring sheet: per level, concrete counts, cell lists or ranges, schedule numbers, pass/fail playtest targets, and a "buildable now / blocked by GAP-n" column. Owner: level-designer (numbers), systems-designer (columns).
2. Add a build-order list for Meadow tied to the 3.7 gaps (which level unblocks when). Owner: producer with lead-programmer.
3. Run the solver (G5) for each 8.1 shape list so "proposed" becomes "proven". Owner: gameplay-programmer / level-designer.
4. Add a one-page "What a Meadow author needs" extract at the top of 8.1. Owner: systems-designer.

---

## 2. Placement and density rules: 6.5

**Earned.** F1 gives a clear package budget with A_max (`:1573`). F2 gives hazard interval by level and biome (`:1587`). F3 gives a direction-correct pressure check with a worked example (`:1605`, `:1619`). F9 gives gem count and a height limit derived from `H_play - margin` (`:1727`, `:1738`). AC26 forbids gems/keys in pockets or above `gem_max_layer` (`:1957`). A banned-combination table exists (`:1389-1399`). Top-out and fill behaviour are stated per entry.

**Why not 10.**
- Placement rules exist for gems only (F9). Cargo, critters, cores, pegs, hang points, pens, pads, keyholes and cages have no placement range, no minimum spacing, no keep-out from walls or spawn, no "not reachable on the first piece" rule. The word "placement ranges" is promised to the level designer (`:1501`, "level-designer (placement ranges, F9)") but F9 only covers gems.
- F2 and F3 cover lock-timed hazards. Meadow's own hazards are ms-timed (defend_core shots, stone throws) and F3b is the check; no per-level interval numbers are given for them (`:1871`, `:1867` knobs list "n.a." for `attack_every_ms`).
- Knob table shows "n.a." for `attack_every_ms`, `core_damage`, `rival_rate`, `slip_count` (`:1865-1868`), so Meadow's core hazards have no default.
- Density: F1 limits packages but nothing limits objects per package or cells covered by static objects as a share of the platform (hedge, pen, gate, pegs). F3 `k_free` handles hazards only.
- Safe ranges are documentation, not enforced (`:1893`); the validator that would enforce them is not written.
- Open defect: Matrix A bans pairs of bounce/jelly/ice (`:1393`), but 3.4a lists ice recalling BK-05 pad (`:1411`) alongside OB-20 ice slide. Under the doc's own banned table ice slot 02 plus a recalled pad is rejected until GAP-2 is built (6 days). See item 4.

**Fixes (ranked).**
1. Write a placement table per object class: min and max cells from walls, from spawn, from each other, allowed layers, line-of-sight vs the camera, and "must be reachable by N pieces". Owner: level-designer.
2. Give Meadow defaults for every "n.a." knob and add them to the knob file. Owner: systems-designer.
3. Add a density budget: static object cells as a share of the footprint, cap on simultaneous telegraphs on screen. Owner: systems-designer / level-designer.
4. Wire the enforcing validator (AC23-26) and show the first failing run. Owner: gameplay-programmer.

---

## 3. Per-level platform and scene support: 5.5

**Earned.** The 8.1 table names the rule layer per level, and entries for masks/gates state fill behaviour (`:1060`, `:711`). The doc correctly ties meadow_02 to the crescent's inner curve (`:764`, `levels.md:122`). Footprint-aware entries exist for pegs and holes (`:722`, `:692`). Pit sizes 4x4 to 8x4 for meadow_01 are cited (`:1060`).

**Why not 10.**
- The doc does not own platform shapes; it points to `levels.md` (`:1972`). So the special-blocks plan does not say, per level, which footprint or mask each special needs. levels.md has the shapes (crescent, hedge court U, terraced bed, tilting plate, spiral mill ramp: `levels.md:474-485`) but 8.1 never maps a special to a cell region on them.
- The quality bar rates scene variety at 3/10 on 163 of 168 square 8x8 boards (`reference-quality-bar.md`, Historical note). A plan cannot carry that forward; here the doc gives no footprint column and no mask requirement per special, so a maker would default to the square board. Example: OB-29 hedge wall rows "placed at level start" with no layout (`:967`); OB-28 pen is "a mask-marked group" with no shape (`:956`).
- Scene support (camera, set pieces, lighting) is absent. The see-through rule (`:1501`) is the only camera-aware rule and it is a render pass, not a per-level framing.
- Biome skins: the pirate skin is a DECIDED commission, not a delivered asset (`:76`, AC20c), so pirate levels cannot be scene-checked.
- Edge case 18 (moving platform bump, `:1791`) relies on G8, unbuilt (13.5 days).

**Fixes (ranked).**
1. Add a "platform and scene" column to 8.1 and 3.4a: footprint/mask name, size, camera framing, set piece, the specific cells each special occupies. Owner: level-designer with art-director.
2. Add a footprint-compatibility field to every entry's Fits line (min/max footprint, mask needs, whether it works on non-square boards). Owner: systems-designer.
3. State a rule that two levels on the same footprint with only a reskin count as one scene, and have the validator flag it. Owner: level-designer / gameplay-programmer.
4. Schedule the pirate skin and G8 platform before any level that needs them. Owner: producer, art-director.

---

## 4. Biome spread and signature specials: 7.5

**Earned.** 3.4a lists all 12 biomes from `catalog.json:3-16` with new specials by slot, recalls, bans and skin (`:1407-1420`). One-new-per-slot is stated (`:1424`). Neon, celestial and carnival have named signatures (laser sweep `:1418`, gravity well `:1419`, ring toss/swing ball `:1420`). Item unlock is per biome (`:1428-1439`). Meadow's first-12 rows agree with 8.1.

**Why not 10 (defects).**
- Order error: underwater (biome 4) lists BK-26 balloon as "recalled from earlier" (`:1412`), but balloon is first introduced in pirate (biome 5, `:1413`). A recall cannot precede the first appearance.
- Ban conflict: ice (`:1411`) recalls BK-05 pad next to OB-20 ice slide, which the banned table rejects until GAP-2 (`:1393`). Candy slot 04 jelly (`:1410`) plus recalled BK-05 pad has the same issue if both appear in one level.
- "One new per slot" is broken by item unlocks: candy slot 03 gets OB-21 syrup band plus three new items (`:1410`, `:1431`); slot 05 gets frosting + sponge + bomb item. The table does not count items against F1.
- Uneven spread: candy has 13 new specials in 14 slots, ice 6, underwater 8, pirate 7 with slots 04, 07, 09 empty; neon, celestial and carnival leave 4 slots each blank with no statement of what plays there (recall? plain?). Empty slots are not defined.
- Signatures: candy, lava, forest lack a single named signature; only 3 biomes are labelled "signature". Ice, pirate and cave have no signature that is unmistakable at 0.5 s.
- 3.4a is marked PROPOSED for the level designers to confirm (`:1403`); it is not a ruling.
- The pirate skin does not exist; carnival reuses Tumble Fair (`:1420`), so carnival shares art with an arena skin.
- Many signatures are NEW and unbuilt (OB-40 laser, OB-42 well, OB-41 ball).

**Fixes (ranked).**
1. Fix the balloon recall: move first balloon to underwater or remove it from the underwater recall list. Owner: systems-designer.
2. Resolve ice and candy bans: either schedule GAP-2 before ice, or drop the pad recall from ice. Owner: systems-designer / lead-programmer.
3. Count items in F1, or state items are free of the budget; re-balance candy slots 03 and 05. Owner: systems-designer.
4. Define what blank slots play (named recall plus remix) and add a signature per biome. Owner: level-designer.
5. Level designers confirm or change the PROPOSED assignments. Owner: level-designer.

---

## 5. Coverage of the reference minigames: 7.5

**Earned.** Section 3.5 assigns all 101 ids (M01-M83, M84-M91, M200-M209) a verdict of Covered, Covered in part, Goal or OUT with reasons (`:1445-1497`). Aliases M92-M94 are resolved (`:1443`). I scanned the table and found no id missing. OUT calls follow party rule 3 (one extra verb at most, `:1443`).

**Why not 10.**
- Verdicts are lumped: rows such as M14, M18, M30, M31, M32, M39, M48, M69, M84 -> `OB-04, OB-08, SH-10, BK-31` (`:1458`) give one answer for nine games with no per-game mapping to the exact special or level slot.
- "Covered" is often "Covered by an unbuilt thing": OB-35, OB-38, OB-40, OB-41, OB-42, OB-43, BK-33 to BK-42 are NEW. Coverage on paper is not coverage in the build.
- Many OUT verdicts: runner/carry, projectile, vehicle, ball sport, shooter, rhythm, hex (M01, M05, M21, M53, M58, M04, M06, M15, M43, M50, M24, M64, M81-83, M88, M206). Roughly 25-30 of 101 are OUT or "in part" with the key verb dropped, so the references are not covered, they are excluded.
- The catalogue files unreadable by the catalogue are not covered (`:1497`, `reference-minigames-catalog.md:362-366`).
- No link from a covered M-id to the level/slot that would use it (3.4a). A designer cannot see which reference lands where.
- M81/M82 "OUT until the cards are designed" (`:1489`) is a deferral, not a decision.

**Fixes (ranked).**
1. Split lumped rows into one line per M-id with the entry id and the target biome/slot. Owner: systems-designer.
2. Add a column "first used in (biome, slot)" and a "built? (E/P/N)" column. Owner: level-designer.
3. Report the share of 101 that is Covered-and-built versus Covered-and-NEW versus OUT, so the claim is honest. Owner: systems-designer.
4. Decide M81/M82 and the OUT list with the creative director instead of leaving them open. Owner: creative-director.

---

## Merged ranked fix list (all owners)

1. Meadow authoring sheet with concrete counts, cell lists, schedules and a buildable-now column (level-designer, systems-designer).
2. Per-object placement and spacing rules, not gems only (level-designer).
3. Platform/footprint/mask column per special per level, and a same-scene validator (level-designer, art-director, gameplay-programmer).
4. Fix the balloon recall order and the ice/pad ban conflict; count items in F1 (systems-designer, lead-programmer).
5. Defaults for every "n.a." knob in the Meadow ms hazards (systems-designer).
6. Per-M-id coverage rows with slot and built status (systems-designer).
7. Build order tied to gaps; pirate skin and G8 scheduled (producer, art-director).
8. Run the solver on the 8.1 shape lists (gameplay-programmer).
