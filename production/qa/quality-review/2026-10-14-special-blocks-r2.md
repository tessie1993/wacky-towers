# Special Blocks and Objects, round 2: merged 3-expert blind plan review

Date: 2026-10-14. Thing reviewed: `design/gdd/special-blocks-and-objects.md` (DRAFT r2), reviewed as a PLAN.
Rule: `.claude/docs/reference-quality-bar.md`, "Three blind experts". Scores are copied from the three
expert files unedited and unaveraged. An item passes only if all three experts score it >= 9.7.

Inputs (only these three were read):
- `production/qa/quality-review/2026-10-14-special-blocks-r2-level-designer.md`
- `production/qa/quality-review/2026-10-14-special-blocks-r2-game-designer.md`
- `production/qa/quality-review/2026-10-14-special-blocks-r2-systems-designer.md`

## Result: FAIL

All 15 items from the three experts are below 9.7. Not one item passes.
Lowest score: **5.5** (Level Designer, item 3, Per-level platform and scene support).
Highest score: 7.5 (eight items). Nothing is within 2.0 of the bar.

Note: the three experts scored different item sets (each expert's own checklist). The items do not line
up one to one, so there is no cross-expert per-item verdict. Every item fails on its own.

## Scores side by side

Lowest score in each expert's column is marked with `<- low`. Overall lowest is marked `<- LOWEST`.

### Level Designer

| # | Item | Score | Pass (all 3 >= 9.7)? |
|---|---|---|---|
| 1 | Usefulness for authoring Meadow 1-10 | 7.0 | FAIL |
| 2 | Placement and density rules | 6.5 | FAIL |
| 3 | Per-level platform and scene support | 5.5 <- LOWEST | FAIL |
| 4 | Biome spread and signature specials | 7.5 | FAIL |
| 5 | Coverage of the reference minigames | 7.5 | FAIL |

### Game Designer

| # | Item | Score | Pass (all 3 >= 9.7)? |
|---|---|---|---|
| 1 | Player fantasy and fun of the specials | 7.3 | FAIL |
| 2 | Teaching curve and pacing, Meadow and chapters | 6.5 <- low | FAIL |
| 3 | Variety and biome identity | 7.0 | FAIL |
| 4 | Clarity and readability to the player | 6.8 | FAIL |
| 5 | Fit with level rules | 7.0 | FAIL |

### Systems Designer

| # | Item | Score | Pass (all 3 >= 9.7)? |
|---|---|---|---|
| 1 | Rule unambiguity and completeness | 7.5 | FAIL |
| 2 | Formulas and tuning knobs | 7.5 | FAIL |
| 3 | Interaction matrices and edge cases | 7.5 | FAIL |
| 4 | Data model and flags (hung, blast_safe, rescue_safe, goal_object) | 6.5 <- low | FAIL |
| 5 | Testable acceptance criteria | 7.5 | FAIL |

Lowest per expert: Level Designer 5.5, Game Designer 6.5, Systems Designer 6.5.

## User decision recorded today (2026-10-14)

The bounce pad (meadow_08) and fog (meadow_07) move to the Meadow hard levels. Meadow 01-10 keep
core objects only. This answers the Game Designer's open question (Appendix E vs 3.4a slot 08).
Follow-ups the doc must absorb:
- 3.4a slot 08 (BK-05 pad) and the fog slot, and the 8.1 meadow_07 and meadow_08 rows, must be rewritten.
  The Meadow 01-10 table then shows core objects only, and the Level Designer's "buildable now" column
  gets simpler for those ten levels.
- GAP-8 (preview/ghost UI), which meadow_08 hop ghost depends on, moves with the pad to the hard levels.
- The Game Designer's Chapter 1 fantasy tension remains: with only core objects in 01-10, "every block has
  a personality" is delivered only by h2 mushroom and h3 egg. Not resolved by this decision; see fix 11.

## Merged and deduped fix list (ranked, with owner)

Ranking: engine-correctness blockers first (they invalidate other work), then internal contradictions,
then missing authoring data, then player-facing clarity, then polish. Source in brackets:
LD = level designer, GD = game designer, SD = systems designer.

1. **Rescue path broken: `rescue_safe` does not protect goal objects.** `wipe_bottom` calls RESCUE, then
   `shift_layers` CLEARs the same cells. Re-spec, re-size GAP-3 (2.5 days is low), and rewrite AC18 and
   AC29 to assert survival through the whole pipeline. [SD] Owner: lead-programmer + systems-designer.
2. **Status-record merge contract.** `set_status` overwrites the record, so shells wipe `hung`,
   `blast_safe`, `rescue_safe` and counters. Specify the merge (or a separate flags field), add to GAP-3,
   add an AC. [SD] Owner: lead-programmer.
3. **Define `hung` under slice collapse** (chamber-bottom behaviour, ragged layer, cells above). Name its
   fields, unify `hung_locks` and `hang_locks` (per-shape map), reconcile edge 9 vs edge 32 vs 3.1b rule 3,
   add an AC. [SD] Owner: systems-designer, co-sign lead-programmer.
4. **Slot budget breaks F1 `new <= 1`.** Candy 03 and 05, Ice 04 and Clockwork 05 add several new things
   per slot (items count as specials per F1). Count items in F1 or split the packages, then add those rows
   to AC24. Also settle gem first appearance (Cave 01 vs cave 02 vs underwater 06). [LD, GD, SD]
   Owner: game-designer + systems-designer + level-designer.
5. **Meadow authoring sheet.** Per level: counts, cell lists or ranges, schedule numbers, playtest targets,
   a "buildable now / blocked by GAP-n" column. Rewrite the 07 and 08 rows per the decision above. Add the
   h2 and h3 base-level frames, or mark them BLOCKED. [LD, GD] Owner: level-designer (numbers),
   systems-designer (columns).
6. **Platform, footprint and mask column** per special per level in 8.1 and 3.4a, plus a Fits-line
   footprint field and a same-scene (reskin) validator flag. Biggest single gap (the 5.5 score).
   [LD, GD] Owner: level-designer + art-director; validator by gameplay-programmer.
7. **Formula and knob consistency.** One source for countdown defaults (8/8 vs 12/10), drop or define
   `k_fair`, clamp ms-warning and `spawn_every_locks` safe ranges to F3/F3b minima, reconcile F3 with
   `goo_max` x `cells_blocked`, fix F5, F6, F9 ranges (F9 at H_play 6), F2 biome label, merge the two
   `p_item` rows, give Meadow defaults for the "n.a." knobs. [SD, LD] Owner: systems-designer.
8. **Goal-object exposure and `goal_object` definition.** Cube critters are deletable via DISPLACED/TRIM.
   Decide `displace_safe` or a level rule. Make `goal_object` a real flag or a data macro. Declare
   `arch_safe`, add combined-flag rows, add the snapshot/version note. [SD]
   Owner: systems-designer + lead-programmer.
9. **Placement and density rules for every object class,** not gems only: spacing, wall and spawn
   keep-out, reachable-by-N-pieces, static-cell share, cap on simultaneous telegraphs. [LD]
   Owner: level-designer, systems-designer.
10. **Pacing table for all 12 biomes.** Fill every empty slot (ice 07-10, underwater 05 and 08, pirate 04,
    07, 09, neon, celestial, carnival). Add a chapter-aware cap and sawtooth. Replace "mid-chapter" and
    "tier N" teach lines with slot ids, and reconcile entry Fits against 3.4a (goo, pest, BK-08). Define or
    delete "tier". [GD, LD] Owner: level-designer, game-designer, systems-designer.
11. **Player Fantasy expansion** per group, chapter and biome, with an aesthetic target each. Add a
    one-line fantasy and shape-bag identity per biome. Settle how Chapter 1 delivers personality with
    core-only 01-10 (a named teaser). Give at least 4 hazards a second answer. [GD]
    Owner: game-designer (user decides the Chapter 1 teaser).
12. **Ban and recall conflicts.** Balloon recalled in underwater before pirate introduces it. Ice recalls
    the pad while Matrix A bans the pad and ice slide pair until GAP-2 (6 days). Add a "blocked on GAP-2"
    column. Fix the 3.1b cause map for CLEAR-as-removal hooks (pest shoo, countdown defuse). [LD, SD]
    Owner: systems-designer + lead-programmer.
13. **Readability defects.** Replace badges BK-35 (snowflake) and BK-33 (diamond), which collide with biome
    hero ornaments. Split gold between reward and see-through outline. Differentiate the three flame
    badges and the near-duplicate silhouettes. Redraw complex badges at 28 px. Fix the goo hint (the wash
    needs the neighbour layer) and strip layer words from player-facing hints. Add sound-off visual tells
    to AC23. [GD] Owner: art-director, ux-designer, technical-artist, audio-director.
14. **Scene-first scheduling for chapters 2-12.** Flip 3.4a to scene first, then the special it needs. Add a
    HUD story objective (12 words or fewer) per level. Mark non-Meadow rows BLOCKED until the identity-spec
    scene exists. Give item drops a story reason. [GD] Owner: level-designer + narrative-director.
15. **Acceptance-criteria gaps.** Add ACs for F2, F6b, F9 bound, F10, F11, hung + collapse, status merge.
    Give every [V] gate a NOT ASSESSED outcome. Define [M] sampling and rubric. Renumber ACs and edge
    cases. Fix stale edges 12, 13, 16 and edge 35 hook order. [SD] Owner: systems-designer + qa-lead.
16. **Coverage honesty (reference minigames).** Split lumped rows per M-id with the entry id, target
    biome/slot and built status (E/P/N). Report the Covered-and-built vs Covered-and-NEW vs OUT share.
    Decide M81/M82 and the OUT list. [LD] Owner: systems-designer, creative-director.
17. **Build order and schedule.** Tie Meadow and hard-level order to the 3.7 gaps. Commission the pirate
    skin (GAP-9) and schedule G8 before dependent levels. Sequence GAP-8 (preview/ghost UI) before the
    hard levels that host the pad. Run the solver (G5) so the 8.1 shape lists become "proven". [LD, GD]
    Owner: producer + lead-programmer + art-director + gameplay-programmer.

## Next step

Revise the GDD against fixes 1-8 first (engine correctness and data), re-run the three-expert panel as
round 3, and keep every score as the experts write it. No item can reach PASS before all three experts
score it >= 9.7.
