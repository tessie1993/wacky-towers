# Reference quality bar

Set by the user on 2026-10-14: "we want AAA quality in level design, mechanics, art, sound, like the
references; all game must be quality level of reference."

## The bar

> **Pass mark raised to 9.7/10 for every reviewer (user, 2026-10-14).** Any older text saying 8/10 means 9.7.

Every player-visible part of Wacky Towers must match the quality of the reference boards in
`assets/art/reference/` (index: `assets/art/reference/index.md`; art bible: `design/art/art-bible.md`).
"Close" is not done.

| Area | Judged against | Pass |
|---|---|---|
| UI screens | style boards 04, 05, 06, 08, 14, 15, 16 | >= 9.7/10 each, zero beige/parchment panels |
| Levels and worlds | board 15 (islands), 13 (blocks), mockup-alignment.md | >= 9.7/10 per biome |
| Characters and story | turnaround sheets, story boards 01, 02, 07 | >= 9.7/10 each |
| Mechanics and level design | design/levels/*, design/gdd/* | >= 9.7/10 per biome: readable, fair, varied, smooth curve |
| Sound | design/gdd audio docs, the art bible's tone | >= 9.7/10: every action has feedback, music per biome |

Standing rules from the user:
- No beige or parchment interface. Windows are open purple-wood frames over a painted scene
  (board 05). Groups of controls sit on translucent purple or wood planks.
- No Nintendo IP. The Nintendo boards are for layout only.
- No "Tetris" naming. Never copy the board logos.

## Calibration: the user's own score is the anchor

On 2026-10-14 the user said: "No this art gets a 4.5 not a 6.3". **The in-game art as it stands scores 4.5/10.**
Reviewers had scored it higher, which was too lenient.

- Every art reviewer starts from this anchor. Today's game screens are 4.5.
- A higher score must name the exact visible change since this calibration, compared side by side with a reference board.
- When unsure between two scores, give the lower one.
- A reviewer's score that the user later marks down by 1 point or more is a calibration miss. Log it here with the new anchor.
- 9.7 means a screenshot could sit next to the reference boards in `assets/art/reference/` and pass as the same game.
  "Better than before" is not a score.

**Second anchor (user, 2026-10-14):** "Scene variety should not have gotten 9.0 out of 10 but 3. All scenes were square grids. Not varied at all."
**Scene variety as it stands scores 3/10.** The data backs this up: 163 of 168 levels use the same 8×8 square board, and only 9 have a mask.

- A scene variety score above 3 must name what changed: the board footprint (not square), the set pieces and what the camera shows.
- A plan cannot score higher than the build that carries it out. Good writing about variety is not variety.
- Two levels on the same square footprint with only a reskin count as the same scene.

## Stricter marking (user, 2026-10-14: "Make the reviews be stricter with giving good marks")

These rules apply to every reviewer and every area: art, UI, levels, mechanics, story, sound and plans.

1. **Start low and earn each point.** Every item starts at 5/10. Raise it only for strengths you can see
   in a retained screenshot or quote from the file, each set against a named reference board or rule.
   Points with no evidence are not given.
2. **Reaching 9+ needs proof.**
   - A score of 9.0 or higher must cite at least 3 concrete pieces of evidence: a file and line, a
     screenshot path, or a side-by-side with a reference.
   - It must also say why the item is not 10.
   - "Good", "clear", "solid" and "much improved" are not evidence.
3. **Hard caps.**
   - **Any open defect:** an item with an open defect that a player or the user would notice
     scores ≤ 8.5.
   - **Not built:** an item that exists only on paper (a plan, spec or unbuilt mechanic) scores ≤ 7
     for player-facing qualities. A plan cannot score more than the build that carries it out.
   - **No capture:** a missing or stale capture caps the item at 6.
4. **No rounding up, and no credit for effort.**
   - Score the thing as it is now. Improvement since the last round is not a score.
   - When unsure between two scores, give the lower one.
5. **A score cannot rise much between rounds unless the evidence shows it.**
   - A score that rises by more than 1.5 points in one round must list each change that earned it.
   - A different reviewer then spot-checks that rise before it counts.
6. **Score each sub-item separately.** List each sub-item's score and its defects on its own. One strong
   sub-item may not lift a weak one through an average.
7. **Calibration miss.** Any reviewer score that the user later marks down by 1 or more is logged here.
   That reviewer's next 3 reviews are then capped 0.5 lower.
8. **Pass means 9.7 on every item, with no exceptions.** A 9.6 is a fail.
   - A review whose average passes but has any item below the bar is a FAIL.

## How work is judged: reviewers instruct, makers fix

1. Makers (UI, world, blocks, characters, levels, audio agents) change things and capture
   720x1280 screenshots into `production/qa/evidence/`.
2. A strict reviewer panel (art critic, level and mechanics critic, audio critic) scores every item
   against the references. They write `production/qa/quality-review/<date>-<area>.md`, with a
   scoreboard, ranked defects and owner-tagged fixes.
3. The orchestrator sends each fix to its owner. Nothing is called done while any item is
   below 9.7/10.
4. Repeat until every item passes.

## Enforcement

`.claude/hooks/reference-quality-gate.sh` (Stop hook) checks whether player-visible files are newer
than the newest review report. If they are, it blocks the stop once and asks for a review. It reports
what it observes and gives no verdict. The verdicts come from the reviewers.
