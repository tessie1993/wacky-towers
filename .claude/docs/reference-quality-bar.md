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

**Correction (user, 2026-10-14): the 3/10 was ONLY the user's score for the previous art renders ("very ugly"). It is
NOT a score for everything and is NOT an anchor.** Let it go. Each aspect is scored on its own merits by its own three
experts, and must reach 9.7. The 4.5 and 3.0 art anchors below are historical notes about old renders, not rules.

**The references are a style guide, not a picture to rebuild (user, 2026-10-14).** Match their style, finish and
quality, never their literal layout or content. **The level decides the art:** each level's mechanics and story set
what the scene shows; the art serves the level.

On 2026-10-14 the user said: "No this art gets a 4.5 not a 6.3". **The in-game art as it stands scores 4.5/10.**
Reviewers had scored it higher, which was too lenient.

- Every art reviewer starts from this anchor. Today's game screens are 4.5.
- A higher score must name the exact visible change since this calibration, compared side by side with a reference board.
- When unsure between two scores, give the lower one.
- A reviewer's score that the user later marks down by 1 point or more is a calibration miss. Log it here with the new anchor.
- 9.7 means a screenshot could sit next to the reference boards in `assets/art/reference/` and pass as the same game.
  "Better than before" is not a score.

**Historical note (user, 2026-10-14, about the old square boards):** "Scene variety should not have gotten 9.0 out of 10 but 3. All scenes were square grids. Not varied at all."
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

## Three blind experts per aspect (user, 2026-10-14)

Each level is made step by step, in this order: **mechanics, then story, then art.** Each aspect is reviewed
separately by its own three blind experts (mechanics: game designer, systems designer, level designer; story:
narrative director, writer, world builder; art: art director, technical artist, world builder or UI designer). An
aspect passes only when all three of its experts give 9.7 or more.

### Panel rules

The user said: "Change the way you mark. Mark each thing for what it is. Mark it by 3 experts in that field. Each time
each agent that don't know each other's opinion."

1. **Mark each thing for what it is.**
   - A plan or spec is marked as a plan: is it clear, complete, testable and consistent, and could a maker build from it?
   - A build is marked as a build, from retained captures, against the reference boards.
   - Caps that belong to one kind do not apply to the other. The "paper-only ≤ 7" cap and screenshot ceilings apply only
     when a build is reviewed, never at a plan gate. A plan also cannot claim credit for qualities the game does not
     show yet.
2. **Three experts in that field.** Each review is done by 3 reviewer agents whose speciality matches the thing being
   reviewed:

   | What is reviewed | The three experts |
   |---|---|
   | Level and campaign plans | level designer, game designer, systems designer |
   | Art and screens | art director, technical artist, UI/UX designer (UI) or world builder (levels) |
   | Story | narrative director, writer, world builder |
   | Mechanics feel | game designer, systems designer, gameplay programmer |
   | Sound | audio director, sound designer, game designer |
   | Code | lead programmer, Godot specialist, the matching language specialist |

3. **Blind and fresh.**
   - The three experts are new agents each round. They are started in parallel, and none sees another's score or notes.
   - None sees an earlier round's scores. They get the thing itself, its brief, the references and these rules. They
     never get a previous review file.
   - The orchestrator only collects the three reports. It never edits or averages a score.
4. **Result.**
   - The review file lists all three experts' scores per item side by side, with the lowest shown.
   - An item passes only when **all three** score it at least 9.7.
   - Fixes from all three are merged and deduplicated, and each fix is tagged with its owner.
5. The strict marking rules above still apply inside each expert's review. Rule 5 (a second reviewer spot-checks big
   rises) is covered by the blind panel.

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
