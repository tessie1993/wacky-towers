# Plan review: phase 1 campaign vision (strict, pass mark 9.7 on every criterion)

Reviewed: `design/levels/plans/campaign-vision.md` (the phase 1 output of `campaign-redo-plan.md`).
Read against: `campaign-redo-plan.md`, `.claude/docs/reference-quality-bar.md`, `design/art/art-bible.md`,
`design/levels/plans/level-identity-spec.md`. Cross-checked: `progression.md`, `minigames.md`,
`design/decisions/2026-10-14-story-cast-decisions.md`, `design/gdd/narrative/story-v2.md` (cast rows only),
`assets/data/campaign/catalog.json` (biome order), `2026-10-14-levels-mechanics.md` (4.8/10 and the 11-of-12 figure).

Inputs: FOUND = all of the above, `assets/data/look_presets.json`, `assets/data/biome_looks.json`.
ABSENT = `assets/data/set_pieces.json`, `assets/data/goals.json` (both are referenced as existing data by the
identity spec and the vision; the glob found neither). This is a document review, so nothing was left unassessed.

## Scores

| # | Criterion | Score | Pass (>= 9.7) |
|---|---|---|---|
| V1 | Clarity of the campaign fantasy | 8.8 | NO |
| V2 | Pillars: distinct, each with an applicable test | 8.2 | NO |
| V3 | Emotional arc: escalation, variety, satisfying ending | 8.5 | NO |
| V4 | "Every level unique" rules: complete, measurable, not contradictory | 7.6 | NO |
| V5 | Briefs: actionable for narrative, systems and level teams | 8.0 | NO |
| V6 | Rubric quality: would it catch mediocre work | 8.0 | NO |
| V7 | Consistency with user decisions and project constraints | 7.8 | NO |

## Verdict: FAIL

Every score is below 9.7. The vision is a strong draft with good instincts (swap test, the structured briefs,
the callback marker, the text budget). It is not yet a gate document, because the uniqueness rules contradict
each other in two places, one explicit user decision (the mechanics handbook) is missing, and the rubric cannot
reliably separate a 9.7 from an 8.5.

## What is good (keep)

- The biome order matches `catalog.json` (meadow, candy, ice, underwater, pirate, lava, forest, cave, clockwork,
  neon, celestial, carnival). 12 x 14 = 168 is stated.
- The swap test (P1), the 14-word caption and 12-word bubble limits, and the `callback_of` marker are concrete.
- The "no dialogue during a drop" rule and the cast-discipline paragraph match the user's cast decision.
- It fixes the review faults by number (g0 rising, hard track beats tier 10, no `fixed_list`).

## Defects by criterion

### V4 Uniqueness rules (7.6): the weakest section

1. **U12 contradicts U9.** U9 makes every tier-10 level a phased boss. The identity spec makes that `bonk_boss`.
   That puts one goal type in tier 10 in 12 of 12 biomes. U12 says the same tier may share a goal type in at most
   4 of 12 biomes. As written, the vision cannot be satisfied. Neon is a further conflict: `progression.md` plans a
   no-boss "show" finale, and U9 says every finale is a boss. The vision never says it overrides that.
2. **U3 cannot be measured.** "Main rule" has no field. "Board shape" compares "mask topology" with no method.
   "Mirrored or rotated counts as the same" is right but needs a canonical form. "Plain square" is undefined
   (does a full 10x10 count?). "Rule identity" is undefined (does `gust` at speed 2 equal `gust` at speed 3?).
   A maker can pass U3 by changing a parameter.
3. **U3 vs hard remixes and U13 callbacks.** Section 6 asks for hard levels that are "same place, sillier or
   faster", and U13 allows echoes. Both suggest reusing the triple, and U3 forbids it. Nothing says callbacks and
   remixes are exempt, or which triple element must change.
4. **The user's "every level different in LOOK" has no campaign-wide rule.** U5 and U6 only test pairs inside one
   biome. U6 allows the same set piece in 3 of 14 levels with only the time of day changed, and a set piece can recur
   in every biome. Nothing forces a unique look fingerprint per level. "Tell two levels apart" has no pass
   threshold, sample size or tool.
5. **U6 contradicts the art bible.** U6 demands at least 4 of 5 `time_of_day` values in every biome. The art bible says
   "Ice is cool. Celestial is night", and Neon is a dark-glass night biome. The identity spec offers "4-6 set pieces per
   biome" while U6 needs at least 5.
6. **Rule-budget numbers disagree in three places.** U10 says one new rule per level, with two on the pill in levels
   01-03 ("pill" is never defined). Section 7.2 says one new rule per biome. `progression.md` fix 4 says two new rules
   plus two minigames per biome. P3(c) says at most one new rule per level, which contradicts the two-rule allowance
   in U10.
7. **Unmeasurable items.** U8 ("recognisable on mute") has no taxonomy of opening events. U1's `<biome>_<nn>` beat id
   does not say how it maps to existing level ids (`_01`..`_10`, `_bonus`, `_h1`..`_h3`). The cited "11 of 12"
   (tier 05) disagrees with `progression.md` ("12 of 12"); the figure comes from the level review, so name the source.
8. Cave is described as "small boards", but the identity spec sets an 8x8 minimum bounding box and a cap on plain squares.

### V7 Consistency (7.8)

1. **The user's ordered decision is missing.** Plan decisions log, 2026-10-14: step 2 must produce a plain-words
   `design/levels/plans/mechanics-handbook.md` before any art or code. The vision's briefs (sections 6-8) never name
   this deliverable, an owner, or a rubric line. The word "handbook" does not appear in the vision.
2. **The board-title ban was dropped (flagged as asked, and it matters).** `minigames.md` line 19 says "No board title
   is used as a minigame or level name". `progression.md` fix 9 lists pirate_03, 09, 10, h1, h2 and the `bridge_dash`
   title. The vision's Hard rules keep Nintendo IP, "Tetris" and logos, but drop board titles. This matters because
   (a) the art bible, the plan and the user decision still use board names ("Kraken Blockade", "Fort Blast", "Tumbling
   Towers", "Molten Guardian"), so a narrative lead reading only the vision will reuse them; (b) the boards 09-12 are
   a Nintendo-adjacent layout reference, so their titles are the likeliest route for third-party IP into 168 new names;
   (c) the pun-style naming rule gives no counter-pressure. This is a regression against the user's standing IP rule.
3. **Cast.** Heroes are named, but Lana, Boulder and Glim get no species, silhouette or colour key. The old story-v2
   made them NPCs (Lana an alpaca, Boulder a hippo) and the cast decision says the heroes keep their perks (Stitch,
   Smash, Redraw). The vision never mentions hero perks, and the sentence "You never swing a sword" plus "heroes react"
   reads as if heroes have no play role. The art bible section 5 has Knight, Dwarf and Elf rows but no rows for
   Lana, Boulder or Glim, and no mapping from Ada, Bram and Sif to those rows.
4. **Biome set vs art bible.** The art bible's 12 blocks include Dune Bazaar and exclude Pirate. The vision has Pirate
   and no Dune Bazaar. The user decided Pirate has its own block skin. The vision does not record that Dune Bazaar is
   dropped, or that the art bible and ref 13 need a Pirate block.
5. **The plan says Pirate is the 11th biome.** The vision (and the catalog) place it 5th. The plan sentence is stale.
   The vision should say so.
6. **Pre-empting phase 2.** The plan says phase 2 resolves `tumble-fair.md`. The vision decides it ("gives way") without
   a user decision, and recommends concept A before the user has chosen. The narrative lead "may replace" it, which
   mitigates this, but the tumble-fair verdict should be marked as a proposal.
7. No parchment guard on captions: the "storybook" tone plus "title ribbon over a painted panel" invites paper scrolls.
   The art bible wants a purple-wood or gold ribbon.

### V2 Pillars (8.2)

1. **The tests cannot be applied at phase 5.** Section 2 says the test uses "one level from its JSON and two screenshots".
   Phase 5 reviews specs before any JSON or screenshot exists (phase 6 builds, phase 7 captures). Section 5 says
   "checked from specs (phase 5) and captures (phase 8)". These conflict.
2. **P2 bundles two tests and its definition fights the goal list.** "The goal is something the player builds or
   reveals" does not describe `survive`, `bonk_boss`, `rescue_all` or `clear_n`. The change test needs a "rule or shape
   that changes how the player drops pieces", which many `clear_n` levels will not have. P3 bundles three tests.
   A reviewer cannot score "partially".
3. **P3 tests are partly subjective.** "A first-time player can say what to do from the start frame" has no protocol
   (how many people, what pass rate). "Never spawns an unwinnable piece run" has no verification (a bot over N seeds
   would work). "Never needs a sentence" sits beside the 12-word tutorial bubble.
4. **Unflagged pillar tension.** P3 "nothing is mean" vs the arc's Lava ("we might lose this") and Neon ("doubt").
   This is fine if stated; it should be recorded as an open decision for the user: how scary is a "comic peril" level?

### V3 Emotional arc (8.5)

1. The table has feelings but no **stakes escalation** (what is lost if the player fails, chapter by chapter) and no
   numeric intensity curve. "Rising stair" is not testable.
2. **No definition of the ending.** Carnival is "triumph", but each biome ends tier 10, bonus, then h1-h3 (hard
   remixes). The final played level could be a remix, which makes the last beat a speed-up instead of a payoff.
   The wizard's payoff and the hero resolutions are not stated as arc beats.
3. The recovery after the Neon low is two biomes. Four of the twelve moods are calm/quiet (3, 7, 8, 11). Candy is "the
   first real boss", but U9 makes all twelve bosses.
4. Hero presence minimum (3+ biomes of 12) is too weak to carry an arc per hero.

### V5 Briefs (8.0)

1. **The narrative brief is internally tense.** Beats are "mechanics-neutral" but are also organised by function
   (teach/twist/combine), which presupposes a rule. The brief should say who owns the function-to-rule mapping.
2. **Overlapping fields.** The beat's "wordless moment" and the level's "first-10-seconds event" are not related.
3. **No data format.** No front matter or table schema for the 168 beats, so phase 4 and the checkers cannot parse
   them. No length limits for the beat entries.
4. **Set pieces.** `set_pieces.json` was not found. The vision wants at least 5 per biome (60+ landmarks) without an
   owner, a count budget or an art-cost note.
5. **The systems brief omits** hero perks, the 15/30 star gate definition, tournament use of the minigames, and the
   handbook. The level brief names fields but not the ASCII mask glyphs or the target-visibility check.
6. Concept A's strength statement should borrow nothing from the old Ice level "Sniffles' Sneeze" (freshness check).

### V6 Rubric (8.0)

1. Anchors are subjective ("a stranger could not improve it", "nitpicks only" with no definition).
2. No calibration: no exemplar beat or exemplar level spec at 10 and at 8.
3. No sampling or coverage rule for 168 levels, no minimum evidence count, no tie-break for 9.6 vs 9.7.
4. No hard caps: a U-rule violation should cap the matching criterion (for example L2 at 8.0).
5. No automated precondition (a script that checks U3, U6, U7, U12 mechanically before a human scores).
6. The rubric does not contain the pillar tests, so a reviewer can pass a phase without applying P1-P3.
7. Missing rubrics: phase 1 itself, phase 5 art critic (the plan sends art critics in), and phases 6-8 (build, captures,
   audio). The plan says every phase has a gate.
8. Several criteria bundle many checks (N4 covers 168 beats x 5 elements), so one 9.7 is not diagnostic.

### V1 Fantasy (8.8)

Clear and warm. Gaps: no one-line pitch; "looked after" is vague; the verbs for clearing lines, using minigames,
the hard track and the stars are not in the fantasy; "tower-builder" and "pair of steady hands" mix two fantasies.

## Ranked fixes (owner: studio game director unless noted)

### 1. Resolve the U9 / U12 contradiction (V4)

Replace U12 with:

> **U12 No cookie-cutter slots.** For tiers 01-09 and 11, the same tier number may not share a goal type in more
> than 4 of 12 biomes. Tier 10 is exempt because U9 fixes it as a boss; instead, the 12 bosses must differ in arena
> mask, phase count and the building action that damages them (the "boss triple"), and no two bosses may share all
> three. Neon's finale is a boss like every other biome; `progression.md`'s no-boss "show" finale is withdrawn.

### 2. Add the mechanics handbook to the plan (V7, V5)

Add to section 7 outputs: "`design/levels/plans/mechanics-handbook.md`: a plain-words explanation of every rule
and every goal a player meets, written before any level art or code (user order, plan decisions log, 2026-10-14).
Owner: systems designer. It is a phase 3 deliverable." Add rubric line:

> **M7 Handbook.** Every rule and goal in the roster has a plain-words entry (what it does, how the player reads it, a
> worked example, what it never does); no entry uses engine terms; each entry names the debut level.

Add to section 8: "Each level spec links each rule it uses to its handbook entry."

### 3. Make uniqueness measurable (V4)

Append to section 5:

> **Definitions.** `main_rule` is a required string field in each spec, one id from the roster; two rules are the same
> rule if they have the same id, whatever their parameters. A **plain square** is a full rectangle mask with no holes
> and no notches, at any size. **Shape identity** is the mask normalised under the 8 rotations and reflections, compared
> as a canonical string (smallest of the 8). **The pill** is the rule list shown on the level card.
> **U3** is checked by script over `(goal_type, main_rule, canonical_mask)`.
> Hard remixes and `callback_of` levels are not exempt from U3: a remix must change at least one of the three, and
> must also differ in `set_piece` or `time_of_day` from its source.
> **U14 Look fingerprint.** Every level has a unique `(canonical_mask, set_piece, time_of_day, weather)` 4-tuple
> across the campaign; within a biome no `set_piece` repeats more than twice and no `canonical_mask` repeats.
> **U5 protocol.** A scripted check computes pairwise silhouette distance of the start frame (grid mask plus set piece
> only, HUD and skin removed) and rejects pairs below a threshold set in phase 5; the reviewer then hand-checks 12
> random pairs per biome and none may be confused.
> **U8 taxonomy.** Phase 4 lists opening-event ids; no id repeats within a biome and no id appears in more than 2 biomes.

Edit U6 to: "...at least 3 of 5 `time_of_day` values (night biomes such as Celestial and Neon may use 2 plus
dawn/dusk), at least 3 `weather` values, and at least 5 set pieces"; and set the identity spec to "5-8 set pieces per
biome".

### 4. Fix the pillar tests so they are appliable and single-purpose (V2)

Replace "a test a reviewer can apply to one level from its JSON and two screenshots" with:

> Each pillar has a test applied to the level's **spec in phases 4-5** (the fields of section 8.2) and to its **JSON
> plus start and clear screenshots in phases 7-8**. A test scores 0 (fail), 1 (partial) or 2 (pass); a level passes a
> pillar at 2. P2 is split: **P2a** names the world change on win (every level, including bonus and minigame levels);
> **P2b** applies only to levels whose goal is `height`, `shape` or a boss, and asks for the rule or shape that
> changes how pieces are dropped. P2 text becomes: "The goal is something the player builds, protects or reveals." P3(a)
> gets a protocol: "5 first-time players, at least 4 say what to do from the start frame in under 10 seconds."
> P3 "never unwinnable" is tested by a bot run: "at least 98% of 500 seeded runs are winnable."

Add under section 2: "**Open tension for the user:** P3 (nothing is mean) vs the Lava reversal and Neon low. Proposed
resolution: peril is always comic and reversible, a hero is never shown hurt; the user confirms."

Reconcile the rule budget in one place: "A level introduces at most one new rule. Levels 01-03 may show two rules on
the pill only if one was taught in an earlier biome. A biome introduces at most 2 new rules (this replaces 'one' in
7.2 and agrees with `progression.md` fix 4)."

### 5. Restore the board-title ban (V7)

Add to Hard rules:

> - **No board titles as names.** No level, boss, chapter, minigame or module name may equal or paraphrase a title on the
>   reference boards or in the `minigames.md` Naming fixes table (for example Bridge Bashers, Tumbling Towers, Fort
>   Blast, Kraken Blockade, Molten Guardian, Maze Heist). A script compares every name to `assets/art/reference/index.md`
>   and to that table. The old names in pirate_03, 09, 10, h1, h2 and the `bridge_dash` title are renamed in phase 4.
> - No third-party IP of any kind (not only Nintendo).

Also add rubric item N5/L1: "names pass the title script".

### 6. Strengthen the rubric (V6)

Add to section 9:

> - **Preconditions.** Before human scoring, the scripts for U3, U6, U7, U12, U14 and the name check must pass; a
>   script failure caps the matching criterion at 8.0.
> - **Coverage.** Reviewers read every beat and spec of one biome in full and at least 5 levels of each other biome,
>   across teach, boss and hard roles, and cite at least 10 level ids per criterion.
> - **Anchors.** 10 = no change you would request; 9.7 = only wording or tuning notes, no structural change; 9.6 or
>   lower = a structural fix is needed. Scores are to one decimal and are not rounded up.
> - **Calibration.** Phase 2 and 4 makers must write one exemplar beat and one exemplar spec first; the panel scores them
>   as anchors (target 9.7) before reviewing the rest.
> - **Pillars.** Every rubric includes "P1-P3 tests applied to 5 sampled levels".
> - Add rubric A (art: look block, set pieces, palette, no beige), rubric B (build: verifier 0 failures, boot), rubric C
>   (captures) and rubric S (sound, music per biome) for phases 5-8.

### 7. Cast and art dependencies (V7, V5)

Add to section 4 (Cast discipline):

> Ada = the art bible Knight (silver and red), Bram = the Dwarf (ginger and steel), Sif = the Elf (green and tan).
> Their perks (Stitch, Smash, Redraw) stay in the game; the systems brief must say how they appear. Lana, Boulder and
> Glim keep the species they had in story-v2 unless the narrative lead changes them with a reason, and need art-bible
> section 5 rows (silhouette, colour key, prop) before phase 6. Each hero appears in at least 6 of the 12 chapters;
> Pirates, robots, explorers, and similar archetypes in the art bible may be used as unnamed one-offs.

Add under section 3: "Art-bible changes needed: a Pirate block and a Pirate row in the block table (user decision); Dune
Bazaar is dropped from the 12 (record this)." Fix the stale plan line "Pirate Cove is the 11th biome" to "5th, per catalog".

### 8. Strengthen the arc (V3)

Add a column "Stakes" and a line:

> The campaign ends on the Carnival boss (tier 10) and bonus; h1-h3 are an optional epilogue and not counted as the
> ending. Intensity target (1-5 per biome, tier 10 peak): 2, 3, 2, 3, 3, 5, 2, 3, 4, 5, 4, 5 with the Neon boss the
> lowest-morale, highest-stakes. Each hero has a stated resolution beat in biomes 10-12. Replace "the first real boss"
> in Candy with "the first boss" (all biomes have one).

### 9. Fantasy and briefs (V1, V5)

Add a one-line pitch at the top of section 1: "A cosy tower-building puzzler where every island has a problem that
only a stack can fix, and the world answers back." Add hero perks, minigames and the hard track in one sentence.
In section 6 add: "Beat file schema: YAML front matter per beat (`id`, `level_id`, `role`, `place`, `who`, `problem`,
`why_stack`, `world_change`, `wordless_moment`, `opening_event`, `caption`); the `opening_event` field is the same as
the level's first-10-seconds event." Add a mapping: "beat ids `<biome>_01`..`<biome>_10`, `_bonus`, `_h1`..`_h3`
match level ids exactly." Say who owns `set_pieces.json` (technical artist) and a count budget.
Mark the Tumble Fair and concept A recommendations "proposed; pending user choice".

### 10. Minor edits

- Captions: "Title ribbons are purple wood or gold plaques with cream caps text, never paper, scroll or parchment."
- Add an accessibility line: "Every cue is shape plus colour plus sound; the level reads with reduced motion on."
- Cave: change "small boards" to "tight boards (narrow masks inside the 8x8 minimum box)".
- Replace the example "Mushroom Ring" with a name not near a Nintendo setting (for example "Toadstool" would be worse;
  choose "Clover Circle").
- Source or correct the "11 of 12" tier-05 figure (progression.md says 12 of 12).

## Addendum: new user criterion (no "clear N layers", endings not always obvious)

Source: `level-identity-spec.md` "User rules, 2026-10-14 (later)". Result: the vision does NOT enforce it, and
four of its rules contradict it. This lowers V4 and V7. Revised scores: **V4 6.8, V7 6.9** (both FAIL).

Contradictions:
1. **U7** still allows "at most 5 `clear_n` goals" per biome, and section 7.3 repeats it ("`clear_n` at most 5 per
   biome"), as does the plan's acceptance list. The user rule makes `clear_n` never a headline goal.
2. **P3(a)** requires that a first-time player "can say what to do from the start frame alone", and **P1** requires the
   problem "visible in the first 3 seconds". The user rule requires at least 4 of 14 levels per biome whose ending
   cannot be predicted from frame 0 (twist, reveal, surprise guest, secret ending, story-resolved end).
   Nothing says how the two coexist (the opening objective must be clear; the ending may change).
3. **U8** ("recognisable on mute") and **U11** (world change on win) do not mention the hidden-ending patterns, and the
   section 8.2 spec fields have no "ending pattern" or "headline story objective" field.
4. The rubrics (N, M, L) have no line that penalises a mundane or layer-count level; "mundane" is not defined.

Fixes (rank them just under fix 1, as they are a user rule):

> **U15 No counter goals.** No level's headline goal is `clear_n` or any "fill a counter" goal. The HUD shows a story
> objective (for example "Reach the lookout"), never "Clear N layers". `clear_n` may only be a means (charge, drain,
> bonk). Replace the U7 and 7.3 text "at most 5 `clear_n` goals" with "no `clear_n` headline goals", and update the
> plan acceptance line the same way.
> **U16 Surprise quota.** In each biome at least 4 of the 14 levels use an ending pattern from the identity spec
> (twist, reveal, surprise guest, secret ending, story-resolved end), recorded in a required spec field
> `ending_pattern`. No pattern is used in more than 2 levels per biome. Every one is telegraphed (fair), carries a
> comic fail reaction, and keeps a clear opening objective: P3(a) is amended to "a first-time player can say what to
> do first from the start frame; the ending may change". Tier 10 bosses and level 01 of each biome may not hide
> their goal.
> **Mundane test (add to P2):** "Describe the level without the words clear, fill, or reach N. If the sentence is
> 'do the generic thing in a different skin', it fails."
> **Briefs:** section 6 beat schema gains `ending_pattern` and `headline_objective` (story wording, 8 words or fewer);
> section 7.3 lists the allowed goals as story objectives; section 8.2 adds both fields; rubrics N4, M3 and L3 each add
> "no mundane or counter-based levels; at least 4 surprise endings per biome".

## Re-review

After fixes 1-6, re-run this review. V7 and V4 are the criteria most likely to reach 9.7 on the first revision;
V6 needs the exemplar work, so it may need a second pass.
