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
