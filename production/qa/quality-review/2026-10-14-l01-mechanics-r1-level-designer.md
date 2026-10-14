# L01 meadow_01 mechanics review, round 1: level designer (blind)

Subject: `design/levels/campaign/l01_meadow_01.md` r3 plus "User decisions" (lines 488-493). Marked as a plan (spec), per
`.claude/docs/reference-quality-bar.md` (Panel rules 1). Stricter marking applied: start 5, any open defect caps at 8.5, pass 9.7.
Visuals not credited. Level design lens: pit layout and camera readability, spawn, fairness, 2-minute pacing, platform from description, Meadow set-up.

## Scoreboard

| Item | Score | Cap reason |
|---|---|---|
| M1 core loop and fun | 8.0 | D5 (count-as-goal), D3 (time budget), D2 (readability) |
| M2 first-time-player teaching | 7.5 | D7, D8, D10 |
| M3 difficulty and pacing | 6.0 | D1 (pacing chart and 120 s limit contradict), D3, D9 |
| M4 goal clarity and feedback | 8.0 | D2 (camera), D5 |
| M5 rules compliance | 7.0 | D6, D5, D11 |
| M6 rule completeness and edge cases | 7.0 | D4, D8, D12 |
| M7 buildability | 7.0 | D13, D14 |

All items FAIL (pass is 9.7). No item reaches 9, so no 3-citation proof is owed for a high score. Strengths that earned points above 5:
- Exact cell lists, summing correctly: 4+6+8+8+8+8+6+4 = 52 (l01:133-143), 16 free + 36 wall columns (l01:147), grips 8+8+20 = 36 (l01:165-167, 351-353).
- Every stage is a plain rectangle with area a multiple of 4 (l01:187).
- Engine facts were checked, and I confirmed `can_remove` lets DAMAGE remove `anchored` but not `fixed` cells (`src/core/board/board_state.gd:685-687`), so the NEW-3 design works.
- Honest list of unverified items (l01:386-391).
- Acceptance list is mostly testable (l01:412-438).

## Ranked defects

**D1 (critical, M3, M1). The spec's own pacing numbers lose the level.**
- The piece fall is "about 7 s to land alone" (l01:94, l01:206). The minimum is 18 pieces (l01:72, l01:480). 18 x 7 s = 126 s, which is over the 120 s limit (l01:54).
- The pacing chart puts grip 2 at 60 to 90 s and the win at 90 to 120 s (l01:116-119). Stars say 2 stars needs 90 s or less, "a calm player gets it" (l01:72). Acceptance 21 says the median finish is 70 to 120 s (l01:437).
- These three cannot all hold. Real runs use 20 to 26 pieces (l01:75). At 4.5 s per piece that is 90 to 117 s, so the median is already on the cliff. The first-time player is expected to need the retry, yet acceptance 21 allows "at most 1 of 5" retries.
- The whole budget depends on `g0` units that are "not confirmed" (l01:207).
- The cause is a 2:00 timer with a 7 s fall in the tutorial, and the only escape is a hard drop that the player must discover (l01:94).

**D2 (high, M4, M1). Camera readability of a sunk pit is never specified.**
- The pit sits inside 12-layer solid walls (l01:147, l01:416) while the stack limit is `h_play` 8 (l01:129). The look block says only `camera: high` (l01:369).
- No wall transparency or cut-away, no camera framing per stage, and no check that the pit floor, the lower layers and the landing marker (l01:92) are visible in portrait 720x1280. The near wall (z 6 and 7) hides the pit in a high-angle view.
- The pit changes from 4x4 to 6x4 to 8x4, an aspect change from 1:1 to 2:1 (l01:165-166). There is no camera move or zoom beat for the new space, although acceptance 22 requires "the player uses it within 5 s" (l01:438).
- The only camera mention is a cosmetic nudge at 3.5 s (l01:91).

**D3 (high, M3). The difficulty curve rises where the pit grows, with no pressure model.**
- Per-layer work is 4, 6, then 8 pieces (l01:165-166), a ramp of 2x, but the clock is fixed. The last layer needs about 8 pieces in about 30 s (l01:119), about 3.75 s per piece, the tightest rate of the whole level.
- Meanwhile, the first 25 s are intensity 1 with "no pressure" (l01:115). Pressure is front-loaded in comfort and back-loaded in time.
- The 3-star target of 60 s (l01:72) is 2.3 to 3.3 s per piece, which is very hard for level 1.
- No target lines the piece count per stage against elapsed time, so the sundial is not tied to the layers.

**D4 (high, M6, M3). The fairness claim is overstated, and the solver metric measures the wrong player.**
- l01:185-193 proves only that the walls leave no pocket. It does not cover player-made covered holes. The spec itself accepts "a block that locks with a hanging cell" (l01:266), so pockets can form from play. A covered hole in layer 1 kills that layer for good. Layer 1 is the one that first widens.
- "Multiple of 4, so it can be filled exactly" (l01:187) is necessary, not sufficient. L has no mirror (spin only, l01:215), and the shapes are O, I, L, T only (l01:199). A 6x4 or 8x4 may not be tileable in the bag order. This is unproven.
- Acceptance 10 asks for a winning line to exist with perfect foresight (l01:424). The human has 1 NEXT and no hold (l01:203). A 98 percent "exists" claim says nothing about a human or a 1-lookahead bot.
- Acceptance 11 ("a bot that only drops, never turns, frees the stump in 120 s in 90 percent of seeds", l01:425) is very likely to fail. On a 4x4 with a fixed orientation, I and L cannot be fitted. It also contradicts the turn hints (l01:96) and "Turning is taught, not required".

**D5 (medium-high, M1, M5). The "story" goal is still a count of 3, and the end is plain.**
- Three knots that drop off (l01:222-228) are a layer counter in a costume. `clear_n` n=3 (l01:54), and the user rule says never "clear so many layers" (`level-identity-spec.md:59-68`). The spec rests on "no number is ever shown" (l01:56), but 3 knots against 3 layers is a visible count.
- The end is obvious from the start (`metadata.ending = plain`, l01:38). The user's "so mundane" worry is only handled by costume, not by structure.
- Pit growth is the real hook. The spec does not state this as the core loop's reward cadence (what changes after each clear besides width). The pit changes only in size. There is no change of piece pressure or goal.

**D6 (medium-high, M5). The Meadow mix target is broken, and stale files conflict.**
- `level-type-mix.md:31` and `:21` count meadow_01 as the only main `funny`. The spec sets `twist` (l01:379) and defers the fix to game-designer (l01:466). Meadow then has no funny main level. This is an open cross-file conflict, not resolved by the spec.
- The beat file still says the old objective, meter and minigame (l01:465).
- The closed lists for terrain and action ids need two change requests that are still open (l01:450, l01:483-486). The spec relies on `stump_top` and `grip_release`, which are not on the lists.
- Stars are custom (l01:67-75), while `level-identity-spec.md:27` says stars come from the plan formula, not copied. Not reconciled.

**D7 (medium, M2). Teaching of the key rule happens only after the fact.**
- The player learns "a full layer shakes a grip loose" only at the first free, at 20 to 30 s (l01:98), with a 3 s looping preview (NEW-8, l01:404) as the only before-hand cue.
- The word "layer" is banned from all player text (l01:293), but nothing tells the player what a "full layer" is. The empty-cell pulse appears only at 8 or fewer empty cells (l01:97), which in a 4x4 is the second half of the layer. The shape of the goal is invisible on the first 2 to 3 pieces.
- "Hard drop" is the most important teaching item for the 2:00 clock (D1), but it is a single icon at 8 s (l01:94).
- The best-fit outline (l01:96) needs a per-frame solver (NEW-4), but the outline logic is not defined for pieces that fit in several ways.

**D8 (medium, M6, M2). Spawn and rotation in a 4-wide pit are not demonstrated.**
- "A piece can rotate in it" (l01:188) is asserted with no check. An I piece (1x4) with a pivot in a pit exactly 4 wide against solid walls may need a wall kick. `src/core/sim/kick_table.gd` exists, but the spec does not say which kicks apply at the wall (rock cells) at spawn height, layers 8 to 11.
- Rocks in the clearance zone are listed as unconfirmed (l01:388).
- Acceptance has no test for "rotate I and L at the spawn in the 4x4 pit".

**D9 (medium, M3, M6). Moments with no rule: timer, animation and input.**
- The free animation is about 3 s (l01:102) and the end beat about 4 s (l01:241). Does the sundial pause? Does a piece spawn during the animation? What if time runs out during the animation, or the third clear lands at 119.9 s?
- What happens to the soft retry if the timeout lands during the third clear? What does the 30 s grace do (l01:65)? 4 pieces cannot reach the ceiling in 30 s, so NEW-2 (0.5 to 1 day) has almost no player value.

**D10 (medium, M2). Hints cost much for an unknown payoff.**
- Adaptive hints are 2 to 3 days (l01:400) plus a 3 s preview, and are conditional on solver output. The "when it helps" logic has two testable cases only (acceptance 17).

**D11 (medium, M5). Platform from description is satisfied only in part.**
- The user rule (`level-identity-spec.md:111-120`) fits the "growing pit". But the platform stored in data is one fixed 52-cell mask plus 36 rock columns (l01:314, l01:372). The playable platform is always a rectangle (l01:187), and the round stump is only revealed (l01:193).
- That is faithful to the user decision (l01:490-492). But the rim rows never take part, and the 52-cell round shape is never played. The identity of the level is the removal rule, not a platform. Fine, but the spec should say in the data that the true platform is "the pit" and the mask only the final reveal.

**D12 (low-medium, M6). Smaller rule gaps.**
- "Trim" (l01:73) is undefined. It seems to mean a rescue scoop. Does a rescue scoop remove cells that count for a layer?
- "Overfilled blocks drop down and count for the next layer" (l01:75) is unclear with flat pieces.
- Rescue and the grace rule: `warnings_max` changes from 2 to 3 (l01:333), with no reasoning.
- Pause during the sun-hold and a resize during release are missing.

**D13 (medium, M7). Buildability gaps in the spec text.**
- The JSON diff contains placeholders: `"base_columns": [ ... 36 columns ... ]` (l01:349), which is not valid JSON, and then says to remove it (l01:372).
- Five load-bearing items are unconfirmed (l01:386-391): the layer counters after rock removal, rocks in the clearance zone, validator keys, what `rescue` does, `g0` units. All of them gate the core loop.
- No rule of how rock columns behave when a layer clears: `clear_protected` blocks CLEAR removal (`board_state.gd:691`), but whether anchored columns stay put while the layers above drop one step is not stated. Acceptance 4 checks emptiness only.
- Total cost is 12 to 14 code days plus 10 to 13 art days (l01:408) for a level 1 that is meant to teach. This is a risk, not a defect.

**D14 (low, M7). Setup for the rest of Meadow is thin.**
- `grip_release` is the Meadow level 1 twist but there is no note on how levels 02 to 10 reuse or avoid it (for example meadow_06 `completing`, meadow_05 `race`). The `twist` count for Meadow (3 in the mix table) now includes this and the unfunny gap (D6).
- There is no handbook entry for the rule yet (l01:399).

## Fixes (each with owner)

| # | Fix | Fixes | Owner |
|---|---|---|---|
| F1 | Re-baseline the clock: measure the true fall time per piece first, then set the limit from a piece budget (for example 1.4 x the 4.5 s median x 20 pieces, rounded) rather than 120 s, or raise `g0` for faster landing. Make the pacing chart, stars and the median in acceptance 21 use one number. Move the hard-drop teaching to the first piece (a down-arrow at 3 s, not 8 s). | D1, D3 | level designer, then game-designer |
| F2 | Add a "Camera and readability" section: per-stage camera framing (4x4, 6x4, 8x4), a cut-away or fade for the near wall (z 6 and 7) and the left and right walls, wall height (reduce to h_play + 1 if rules allow), a landing-marker contrast check, and a retained-screenshot test per stage. | D2 | level designer + art-director |
| F3 | Replace the "exists" solver with a 1-lookahead greedy bot with turn and a no-turn bot, and set the targets from the result. Remove or rewrite acceptance 11. Add a tiling check for 6x4 and 8x4 with O, I, L, T (L only, no J). Define what happens to a covered hole in layer 1 (for example, the grip counts any full layer, already true, plus a rescue scoop that opens it). | D4 | systems-designer + gameplay-programmer |
| F4 | Make the pit-growth cadence part of the pitch. Option: give each stage a distinct pressure (stage 1 calm, stage 2 sunset light). Consider hiding the knot count (a creaking ring that loosens, no three discrete knots) to remove the count. Needs a user decision. | D5 | game-designer + narrative-director |
| F5 | Resolve the mix: either tag meadow_01 `funny` (the cosmetic giggle) with `twist` as a second tag, or add a `funny` main level in 06 or 09. Update the beat file. File the two closed-list change requests. | D6 | game-designer, narrative-director, technical-artist |
| F6 | Teach: show a ghost "full layer" outline of the whole 16-cell floor in the first 10 s (not words), start the empty-cell pulse at 12 empty cells in stage 0, and put the 3 s preview on the start frame. | D7, D10 | ui-programmer + level designer |
| F7 | Add acceptance tests for I and L spawn and spin in the 4x4 pit at layers 8 to 11, and state the kick rule at rock walls. | D8 | gameplay-programmer |
| F8 | Add a "timeline rules" paragraph: pause the sundial during the free animation and end beat, define the order of timeout, third clear and rescue, and drop `goal.grace_ms` (NEW-2) unless a playtest shows an early top-out. | D9 | game-designer + gameplay-programmer |
| F9 | Define "trim", "overfilled blocks" and the rescue interaction with layers in one glossary. | D12 | level designer |
| F10 | Replace the JSON placeholder with the real 36-column list or generate it. Close the five unconfirmed items with the Godot master before approval. Add a test that anchored columns stay put when layers above drop. | D13 | Godot master + gameplay-programmer |
| F11 | State in the data notes that the playable platform is the growing pit (the mask is the reveal). Add a short "How Meadow reuses grip_release" note. | D11, D14 | level designer |

## Why not higher
- No item can pass while D1 stands: the spec's own numbers imply a loss for typical play.
- Without a camera plan (D2), the layout readability (my specialty) is unproven.
- The fairness proof (D4) has not been run, and the metric tests the wrong player.
