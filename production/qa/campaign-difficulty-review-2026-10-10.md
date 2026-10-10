# Independent campaign difficulty review — 2026-10-10

**Verdict: CONCERNS.** The 100 main levels and 18 optional levels have distinct gameplay configurations and a deliberate teaching/breather/remix structure. The sideways Ice finale has a concrete geometry/timing mismatch to resolve. Difficulty success rates and first-attempt star medians are **NOT ASSESSED — NO PLAYER DATA**; this report does not call the campaign playtest-balanced.

## Inputs and method

| Input | Availability | Use |
|---|---|---|
| `assets/data/campaign/catalog.json`, all 118 referenced playable JSON files | FOUND | Actual level order, boards, controls, pieces, rules, goals and stars |
| Source specs preserved in `metadata.design_spec`; ten biome design documents | FOUND | Authored intentions and permitted callbacks |
| `assets/data/shapes/shape_bank.tres`, knob/rule definitions, live simulation/goal/behaviour sources | FOUND | Piece volume, physical dimensions, default timing, implemented semantics |
| `design/registry/entities.yaml`, campaign structure, scoring, fall/drop/lock GDDs | FOUND | Named targets, F2 base speed, star formulas and lock budget |
| `balance-check`, studio level design lead, level design skill and pacing/flow reference | FOUND | Evidence discipline and teach → develop → twist → test review |
| Player observations, first-attempt completion rates, median time/collect rate | ABSENT | NOT ASSESSED — NO PLAYER DATA |

Run `python tools/review_campaign_difficulty.py` to regenerate the companion JSON. The audit normalizes knob defaults, excludes presentation/music and unused length estimates from gameplay fingerprints, and includes physical layout, piece supply, goal, controls and rule parameters. A fingerprint demonstrates a distinct configuration; it does not demonstrate a distinct player experience. Reduced rule/goal families identify intentional reuse.

## Measured findings

- 118 of 118 gameplay fingerprints are distinct, including all 100 main levels. No identical gameplay pairs were found.
- There are 88 reduced goal/rule/arrival/clear/control families. Familiar classical starts, tower breaks and picture puzzles recur with different geometry, timing, supply or pressure. This is compatible with teaching and callbacks; it is not 118 unrelated mechanic inventions.
- Sixteen levels have finite piece supply. Fifteen are picture/packing puzzles; the remaining Lava H3 is a finite drilling/clearing challenge. None has an obvious necessary-volume shortfall after accounting for mirror duplication. Necessary volume is weaker evidence than a legal packing witness.
- Every time-star pair has positive `t3 < t2`, and every count-star pair has positive `s2 < s3`. No declared numeric knob falls outside its owning safe range.
- All declared lock-delay defaults are 500 ms, hard-drop grace 150 ms and entry delay 200 ms. Mechanic overrides such as sticky first-touch locking remain relevant and were reviewed separately; these figures are not the effective timing for every atom.
- Neon 08 initially awarded time stars for a fixed 150-second survival goal, making a clean finish automatically meet its 170-second third-star threshold. The content pass changed it to clear-count stars. The current regenerated audit no longer reports that defect.

## Outliers requiring action

| Priority | Level or system | Evidence | Recommendation |
|---|---|---|---|
| High | Ice 10 sideways geometry | Declared width 12, `h_play` 12 and depth 6 become physical 12×18×6 with six spawn-clearance cells. Under −X gravity, the current board contract gives a danger layer of 6 and 108 active cells per clearing plane. Four clears require 432 cubes, or 108 standard pieces on an empty board. At the authored eight-second placement estimate, that is about 864 s, against a 190 s third-star target. | Resolve the intended gravity-frame dimensions and danger line with the core/content owners, then replay a real sideways witness. This is a source/geometry question before it is a speed tuning question. The estimate is not a lower bound: expert hard drops can be faster. |
| Medium | Candy 09 first pressure combination | Goo, licorice locking and axis flip all first appear together in this biome. Axis flip differs from Meadow's stack turn. One warning/recovery allowance does not prove the three new causes are readable. | Give the first goo/lock interaction a protected demonstration before the first flip; keep the remix after that introduction. Measure first-attempt failure causes. |
| Medium | Forest 08 counter pair | Vines and woodpecker first appear together. Their protection/knock interaction is intentional, but players must infer both states under a five-clear objective. | Show one vine-protected cube and one unprotected knock with a complete warning before repeated pressure; validate that players can explain the difference. |
| Medium | Celestial 10 final event deck and lid | Both the event-card scheduler and lava lid first appear in the finale. Cards reuse learned motions, but their schedule and lid deadline are new. | Ensure the opening card and lid change are shown separately; test whether the card preview gives enough preparation time. |
| Review | Later fixed puzzles | Several puzzles lower `g0` well below campaign F2: Underwater 06 0.6, Forest 06 0.6, Cave 07 0.6, Clockwork 06 0.6, Celestial 06 0.6. | Preserve these deliberate planning breaks. F2 is a default and the GDD permits hand tuning; increasing every level to a monotonic speed curve would remove the intended release. |

## Pacing and critical path

| Biome | Main base-speed start → finale | Planning/release goals | Review |
|---|---|---|---|
| Meadow | 0.60 → 1.00 | 05 tower, 06 picture | Controls isolated first; helper catches soften early errors; pressure rises through fog/survival/flip before the mill remix. |
| Candy | 0.65 → 1.05 | 05 frosted tower, 06 colour picture | Colour begins as an optional bonus, becomes planning and later clearing. 09 needs the staged introduction above. |
| Ice | 0.72 → 1.10 | 05 tower, 06 picture | Slide practice precedes snowball/whiteout/thin ice; the finale's new gravity frame needs the geometry correction. |
| Underwater | 0.75 → 1.15 | 05 tower, 06 selectable kit | Pockets and helpers precede drift/bounce/silt. Kit selection and undo provide a distinct low-pressure planning beat. |
| Lava | 0.85 → 1.25 | 05 tower, 06 shape | Ember and rising floor appear before conveyor/rock/finale combinations. Check rock hardness under real drilling commands. |
| Forest | 0.85 → 1.30 | 05 tower, 06 packing | Shelf and squirrel identity precede their remixes; 08's vine/knock pair needs a legible first demonstration. |
| Cave | 0.95 → 1.35 | 05 tower, 07 mirror picture | Mirror duplication supplies the finite puzzles; lantern/fog visibility and rescued critters need gameplay-state checks, not just accepted parameters. |
| Clockwork | 0.97 → 1.40 | 05 tower, 06 packing | Turn, conveyor and pistons are introduced before stop/flip/finale combinations. Exact bonus turn cadence is part of the packing witness. |
| Neon | 0.95 → 1.30 | 05 tower, 06 picture | Deliberately slower callback biome. Survive stars now measure clearing rather than elapsed time. |
| Celestial | 1.14 → 1.50 | 05 balloon tower, 06 packing | Familiar concepts lead into chosen gravity and final deck/lid. Check the distinct new scheduler teaching beat before pressure. |

The critical path is ten ordered main levels per biome. Optional bonus/hard tracks do not supply required learning or stars for the main chain. The 15-of-30 biome gate requires five extra stars beyond ten one-star finishes; the data alone cannot establish the GDD target that at least 70% of first-time Meadow testers reach that gate by the finale. That target remains unmeasured.

## Semantic and validation limits

Accepted rule parameters are not proof that a behaviour reads them. The independent parameter audit identified fields needing code review, including fog's staged activation and lantern radius, mushroom hardness/object aliases, turn warning cadence, and remaining boss/card details. Owners were notified rather than silently classifying unknown parameters as working. Skin/role/per-bag fields may be consumed by presentation or the spawner and need that ownership documented.

The content owner reports real BoardSim packing witnesses for all fifteen finite packing puzzles; this review's independent volume check is intentionally a separate necessary-condition check. Final fresh-process simulation tests must establish cached editor rewrites, exact kits, gravity controls and puzzle turn cadence. Human difficulty evidence still requires a playtest pass: median/first-attempt completion, warnings used, per-piece decision time, star distribution and whether players identify each new cause correctly.

No new empirical success-rate target, arbitrary speed threshold or claim of measured phone performance was invented for this review.
