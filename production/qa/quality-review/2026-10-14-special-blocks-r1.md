# Special blocks and objects GDD, round 1: three blind experts (2026-10-14)

Panel: game designer, systems designer and level designer. Each was fresh and blind to the others. **Result: FAIL**
(the lowest scores per expert are 5.0, 6.5 and 5.0).

| Expert | Scores | Lowest |
|---|---|---|
| Game designer (P1-P6) | 7.0, 6.5, 5.5, 6.5, 6.0, 5.0 | 5.0 |
| Systems designer (S1-S7) | 7.0, 6.5, 6.5, 7.5, 7.5, 7.0, 7.0 | 6.5 |
| Level designer (L1-L6) | 6.8, 5.5, 5.0, 6.0, 6.3, 5.8 | 5.0 |

## Merged fixes (deduplicated). Owner: systems designer (the GDD author) unless noted

1. **Integrate Appendix E everywhere.** Raised by all 3 experts.
   - No items in Chapter 1: IT-14, IT-15 and IT-16 come out of the meadow rows, and the 8.1 header and F8 must match.
   - Teach levels keep core objects only: drop the ghost piece and shelf from meadow_07, and the sprout teach.
   - Add meadow_h2 and meadow_h3 rows, each with one remix kind.
   - Change hidden-timer hazards to millisecond schedules with no countdown, and remove `schedule_mode: locks`.
   - Resolve Appendix B so each question records the user's choice.
2. **Match the levels.md decisions.** Raised by the level designer.
   - No rival in the bonus.
   - The cargo rides on the highest block.
   - The defend core sits in the crescent's inner curve, not the board centre.
3. **The F1 budget fails the first-12 mapping.** Raised by all 3 experts.
   - Redefine what counts as "special" and "new".
   - Restate the 8.1 rows so they are within F1, and make the claim at :1552 true.
   - Reconcile `A_cap` with `rules.max_twists` and `max_level_mechanics`.
4. **Anchored semantics.** Raised by the systems designer.
   - `can_remove` blocks clears and rescue for anchored cells, except DAMAGE (`board_state.gd:685-688`).
   - Write a status-by-cause table.
   - Use separate flags for hang and for goal-object protection.
   - Fix SH-05, R-8, AC18/AC19 and edge cases 13 and 18.
5. **Interaction matrix.**
   - Fix the self-contradictions: ANC against MAG and WND, BMB x GHO, and the ICE conflation.
   - Add pest, sprout, honey, belts, tilt, fire and rescue to the grid.
   - Every cell must be backed by code, or flagged as a gap. For example, goo has no veto on bounce, so that cell is a gap.
6. **Formulas.**
   - F3 fairness is inverted.
   - F8 max (60), F9 range, F11 schedule and the AC15 integer maths are wrong.
   - Add a fairness formula for millisecond-scheduled hazards.
   - Size the gaps with stated reasons and a total.
7. **Game design stakes.**
   - Goo must be a real threat. Today its cells fill layers for the player.
   - Ring fit, hook hang and claw grip need goals behind them.
   - Fix the ring pocket contradiction.
   - Fix the claw's teach level and what the claw answers.
   - Avoid the rocket double-tap clashing with hard drop.
8. **Biome spread and introduction order** (level designer and game designer).
   - Add a 12-biome matrix with signature specials for neon, celestial, carnival and the desert or Dune Bazaar biome.
   - Pirate is a biome: confirm it against the project's biome list.
   - Add a per-chapter introduction order, with at most one new special per level.
9. **Readability.**
   - Add an occlusion or see-through rule for low gems, a buried core and thin pegs.
   - Resolve the 17 ART-CHECK tags; several can be answered from the repo now.
   - Fix badge collisions: frozen against the ice cube, vine against the sprout, and the translucent pieces.
10. **Traceability.**
    - Fix the broken cross-ids (OB-14/15/16 to BK-40/41/42, OB-02, BK-24).
    - Make the Appendix D counts reproducible.
    - Fix the EXISTS labels that have gaps.
    - Add a reference minigame (M-id) to GDD coverage table, including connector paths, radial pull and laser sweep.
