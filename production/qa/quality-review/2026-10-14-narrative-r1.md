# Narrative review r1: phase 2 gate (campaign story, The Twelve Keystones)

Reviewer: strict narrative reviewer. Date: 2026-10-14. Pass mark: 9.7 on every criterion (`.claude/docs/reference-quality-bar.md`).
Read in full: `design/narrative/research.md`, `design/narrative/campaign-story.md` (852 lines, 168 beat rows, 168 scene rows),
`campaign-vision.md`, `exemplars.md`, `scene-vocabulary.md`, `minigame-party-rules.md`, `minigames.md` (summary and naming table),
`reference-study-defence.md`, `reference-study-mockups.md`. I also ran a read-only table parse of the story (objective word counts,
ending patterns per chapter, id uniqueness, cast counts, hook counts). Observations from that parse are cited as "parse".
Governing rulings are taken as decided: premise A with Huffle, Glim a mole, Carnival = Huffle's Birthday Fair with the Great Heap,
Wizard absent in Neon. Nothing was edited in the story files.

## Verdict: FAIL

The story is a strong first draft with a real spine (a lonely baby cloud, a vain Wizard, a promised Ferris wheel). Every criterion is
below 9.7. The shortfalls are structural but fixable in one maker pass. No criterion is below 8.4.

## Score table

| # | Criterion | Score | Pass at 9.7? |
|---|---|---|---|
| N1 | Premise and hook | 9.3 | no |
| N2 | Chapter arcs | 9.0 | no |
| N3 | Beat-to-level fit | 8.7 | no |
| N4 | Endings variety | 8.4 | no |
| N5 | Cast use and character arcs | 9.0 | no |
| N6 | Tone | 9.2 | no |
| N7 | Scene richness | 8.6 | no |
| N8 | Consistency with vision and user rules | 8.8 | no |
| N9 | Minigame hooks vs party rules | 8.8 | no |
| | Mean | 8.9 | |

Caps applied: none from the vision caps (no counter headline goal found: all 168 objectives are 8 words or fewer and contain no
numeral, parse). The script-style U16 cap on N4 is not applied formally, but Lava breaks the "no pattern more than twice" rule (below).

## Scores with evidence and what 9.7 needs

### N1 Premise and hook: 9.3

What works: one absurd, retellable engine (a baby cloud huffed the Wizard's tower apart; stack each island's tower to catch a flying
Keystone). The villain is a toddler, the Wizard's flaw caused it, the finale wheel was promised. "Honest stacks hold" makes stacking
canon. The Pirate-eleventh logic (flung farthest, Huffle points out to sea in celestial_10) is sound.

Defects:
1. The "in two sentences" summary (section 1) is two sentences of about 60 and 40 words. A child cannot retell that. R2 asks for
   one absurd sentence.
2. The finale rests on the Hat Dip and the Wrong Sack, but the gag is staged in only 4 of 168 beats: meadow_01 (spoon), lava_08
   (boot), celestial_08 (rattle), pirate_05 (pan). The sock, trombone, teapot, umbrella, kazoo and alarm clock appear in no beat
   (grep). The ten-object Great Heap in carnival_10 therefore pays off a setup the player never saw. meadow_08 even gives Bram "a found
   umbrella" in chapter 1, before the Wizard's umbrella in chapter 6.
3. Continuity: the Heap holds the rattle and the frying pan, but celestial_08 gives the rattle to Huffle (the gag table calls it "not
   wrong, finally") and pirate_05 gives the pan to Tuppence. The "ten wrong objects" list contradicts its own chapters.
4. The finale twist (the "tower" is Huffle's Ferris wheel) is spent three times before chapter 12: cave_bonus (blueprint),
   celestial_06 (constellation is "the tower the Wizard promised her"), pirate_bonus (map to the Fair). carnival_06 and carnival_08
   then reveal it again. The player is told, then told, then shown.
5. "Blocks remember how they were placed" (world rule) is never visible in a single beat.

9.7 needs: a 25-word-per-sentence summary; the Hat Dip placed in the opening event of one beat per chapter (and the Heap list
reconciled with the rattle and pan); the wheel promise revealed once, in chapter 10 or 12, with the earlier hints kept as unexplained
props only.

### N2 Chapter arcs: 9.0

Each chapter has the same shape: 01-03 setup and ally, 04-06 complications, 07-09 the turn, 10 boss, bonus, h1-h3. Turns that land
well: forest_05 (Sif's treehouse), lava_06 to lava_08 (Bram gone), neon_04, neon_09, celestial_05, pirate_05.

Defects:
1. The boss is resolved by the same beat every time (12 of 12 tier-10 endings are `story`: the villain was lonely, tired or
   misunderstood, you build what they need, they hand over the Keystone). Gert, Jester, Shiver, Hugo, Cinderbottom, Knotty, Gus, Cuckoo,
   Mae and Huffle are all the same character with a different hat.
2. The villain's secret is revealed in beat 09 and then "resolved" in 10, so the boss ending is no surprise: meadow_09 (Gert is
   lonely), ice_09/ice_caption ("still waiting for orders"), forest_09 (the roots wanted guests), candy_09, underwater_05 (Hugo is gentle).
3. Chapter 1 and 2 turns are weak: meadow has no turn before 09; candy's turn (candy_05 decoy) is a joke, not a shift.
4. Chapter 12 promises "every learned idea returns as a game" (research R12, caption) but only carnival_02 and carnival_04 recall a
   named earlier idea, and no row has `callback_of`. The Carnival is not yet a payoff of the campaign's learning.
5. Chapter 9's "sag on the islands we mended" (section 1 stakes) is felt once (neon_04). It is never a level the player plays.

9.7 needs: at least 4 bosses resolved by something other than "the villain was lonely and is given a gift" (a rival, a trick turned back
on the Wizard, a role swap, a bargain); the villain reveal moved out of beat 09 for at least 6 chapters; named callbacks (at least 6) in the
Carnival; one neon level that is the sag, played.

### N3 Beat-to-level fit: 8.7

Strengths: all 168 objectives are 8 words or fewer, story nouns, no numerals, no "clear N" (parse). Most beats have an opening event
in sentence 1 and an act in sentence 2. Good, distinct, playable: ice_08, lava_09, clockwork_08, celestial_09, underwater_07.

Defects:
1. Plain "teach" utility beats read as errands, which the user calls mundane: ice_01 (Get the party ashore), lava_01 (Park Boulder's
   cart), candy_01 (Walk the party to the bakery), forest_02 (Open the log tunnel), forest_03 (Bridge the stream), meadow_03 (Bridge the
   brook), pirate_01 (Follow the parrot aboard), neon_01, neon_02, underwater_03.
2. Nine of twelve bonus levels are one scene: "pack or fit things into a container until the lid closes, and a secret is inside"
   (meadow, candy, ice, underwater, lava, forest, pirate, celestial, cave map). "Fill the old treasure chest" and "Fill the berry baskets"
   are counter goals with a noun. The vision's U15 test ("a bare counter with a story object as dressing") applies.
3. The 36 hard levels are remixes of the same level "but faster": 24 of 36 say double, twice, faster, before or in time (parse).
   35 of 36 are `plain`. The epilogue premise ("the villains strike back") is not played: the villains mostly do the same thing again.
4. Overstuffed rows: neon_09 (five heroes, five acts), lava_08, candy_10, carnival_10 are three or four events in two sentences. They need
   to be playable as one level. Phase 4 will have to cut them.
5. Heavy overlap in the same family: "light a path through darkness" is ice_07, underwater_07 and cave_08 (same objective, same reveal
   that the thing in the dark is gentle). "Patch or prop a leaking, sinking, leaning hull or gate" is underwater_08, ice_09, pirate_06,
   pirate_08, clockwork_09. "Roof or shield from falling things" is candy_02, ice_04, celestial_04, celestial_h1, pirate_h2, neon_h2,
   carnival_09, carnival_h2.
6. Defence flavour from the reference studies is thin: there is no D2 plug-the-breach and no D4 shelter-the-guest level in the 156
   non-boss rows beyond meadow_02. Meadow, Forest, Lava and Cave have no on-stage attacker outside the boss (the defence study asks for
   at least one full defence level per biome, at most two).

9.7 needs: every plain beat given a story twist in its act (not only its ending); the bonus family broken into at least 6 different
scene types; each hard level changing the situation, not only the speed; the overstuffed rows trimmed to one act each.

### N4 Endings variety: 8.4

Quota met on paper: 7 to 9 non-plain endings per chapter, at least 4 of them twist/reveal/guest, level 01 and tier 10 with clear goals
(parse). Nine in the whole campaign are twist, reveal or guest with real surprise (meadow_04, candy_05, candy_06, ice_03, lava_06,
forest_05, cave_05, cave_07, pirate_05, carnival_07).

Defects:
1. Lava has three `twist` endings (lava_04, lava_06, lava_07). The rule is no pattern more than twice per biome. This is a direct U16
   break.
2. The slots are predictable. Position 10 is `story` in 12 of 12 chapters. The bonus is `secret` in 11 of 12 (all but Carnival).
   Beats 01 and 02 are `plain` in every chapter. After two chapters the player knows where the surprise is not.
3. One surprise repeats: "the scary or odd thing is gentle or friendly or a baby". candy_03 (stones are turtles), candy_07, ice_07,
   ice_09, underwater_02, underwater_05, underwater_07, forest_09, neon_05, celestial_05, celestial_07. A second repeat is "a huge
   body part is the scenery": cave_05 (toe), cave_07 (belly), celestial_07 (cheeks), celestial_05 (eyes).
4. Several `story` endings are only the level's event restated, not an ending twist: clockwork_09 ("the spell breaks the clock"),
   neon_09, ice_08, underwater_09 ("the calm water draws Hugo's shell plan", which is obscure and reads as plain).
5. Hard levels: 35 of 36 plain. They could carry the strongest endings because they have no clear goal to protect.

9.7 needs: Lava fixed; the bonus and the boss slots varied across chapters (a boss with a twist, a bonus with a guest or a reveal); at
most 2 "it was friendly" endings across the campaign; the other surprises drawn from the studies (see Fixes, item 8); at least one
non-plain hard level per chapter.

### N5 Cast use and character arcs: 9.0

Strengths: all required counts hold (parse, chapters where on stage): Ada 11, Bram 12, Sif 11 (each of 6+), Wizard 9, Lana 7, Boulder
6, Glim 6. Sif's arc (borrower, returns pearls in underwater_06, learns she belonged in forest_05, gives a treasure away in neon_09,
home in carnival_bonus) is the best in the campaign. The Wizard's lie, confession (forest_07), exile (clockwork_09), absence (neon),
return (celestial_01) is clear.

Defects:
1. Ada's and Bram's Carnival resolutions are only in the cast table: "the final block wobbles and she laughs", "builds the cake tier
   without his hammer". No carnival row shows either (carnival_10 gives them a pose only; there is no cake tier row).
2. The Wizard's flaw "shown by biome 4" (vision section 3) is not in a beat. He is on stage in meadow 5, candy 3, ice 6 beats but
   his vanity (putting his star on every tower) appears in none. Underwater has zero Wizard rows.
3. Boulder and Lana have jobs but no arcs. Lana's defining joke (the too-warm scarf) is not in a beat. She appears out of nowhere in
   neon_09 with no earlier Neon row.
4. The cave Wizard "holding a lantern, kazoo wakes the bats" is told only in the cast table; the Wizard is on stage in zero cave rows.
5. Knotty's backstory has two sources: the chapter text says he fears people leaving "the way the Wizard once did", while forest_05
   shows Sif left. Pick one.
6. Ada's "speaks to Huffle first" (celestial) is not in a beat.

9.7 needs: each hero's resolution as a stated beat in chapters 9 to 12; the Wizard's vanity visible in two of chapters 1 to 4;
a short line of evidence for Lana's and Boulder's small arcs.

### N6 Tone: 9.2

Real tension delivered where asked: lava_06 (Bram's seat is empty), lava_07 (a helmet on a rock for a heartbeat), lava_08, neon_04,
neon_05 (Bram sits silent), neon_09 (Lumen fades, Ada cannot hold the line). Kid-safe throughout; no on-screen harm; a comic fail for
the Wizard in every chapter. Funny and physical (Bram as a sheep, Granny's second moustache, Bea and the Wizard tie).

Defects:
1. The first five Lava beats (cart, embers, road, geysers, steps) are cheerful, so the "danger" chapter takes a third of its length to
   darken. The Neon beats that warm the low point: neon_03 (twist is that they are delivered to Lumen), neon_06 (the smile lights the
   street), neon_07 (paint shower, comic). The low point is real in four beats of fourteen.
2. neon_09's "Lumen's light fades out in Ada's arms" is on the edge for a young child. It must read as a power cut, not a death, with a
   pre-signalled recovery.
3. "Real tension" outside Lava and Neon is thin (the cave dark is the main case). The user said darker moments in general.

9.7 needs: lava_01 to lava_04 each carrying one unsettling note; the Neon middle (06 to 08) staying hollow; one tension beat in chapters 3,
4 and 8.

### N7 Scene richness: 8.6

Strengths: all 168 rows have an opening event (168 distinct ids, parse), terrain, set piece, action and 4+ pose verbs per chapter;
set pieces 7 to 8 per chapter; no terrain, action or set piece used more than twice per chapter.

Defects:
1. Vocabulary mismatch (a hard rule): `scene-vocabulary.md` fixes about 20 to 30 global ids per list, with 7 to 8 distinct ids per
   biome. The story has 140 distinct terrain ids and 163 action ids, and 11 to 13 terrains and 12 to 14 actions in every chapter.
   Section 5b states the vocabulary file does not exist; it does (2.7 KB, with rules and seeds). The story's own check ("at least 7
   terrains") misreads the cap. Only a handful of ids match the seeds (`raft`-style, `mine_shaft`-style, `ship_deck` is absent).
2. Two (terrain, action) pairs repeat across the campaign, which U17 forbids: `cake_plate`/`pie_cannon_fire` (candy_10, candy_h3) and
   `teacup_plate`/`cup_spin` (carnival_04, carnival_h1; same set piece too).
3. `react` is restricted to animals and props, yet it is given to Ada, Bram, Sif, the Wizard, Boulder, Glim, Huffle, Hugo, Mae and the
   other named characters 49 times (parse).
4. Set piece is often not tied to the place (swap test P1a): cave_05 uses `bat_roost` for a stalagmite shaft whose action is a toe;
   cave_08 `gus_cavern` for the pitch-dark gallery; lava_07 `black_glass_tower` for a smoke cavern; neon_08 `cloud_sign` for the
   stampede plaza; celestial_02 `star_dock` at the Constellation Stone; clockwork_09 `great_gear` at the Rewind Works; ice_05 and ice_03
   both `lana_igloo`. These look chosen to hit the 7 to 8 count.
5. No `hud_meter` column. The user rule says a level is "place, cast on stage, set piece that acts, themed meter". The vision makes the
   meter optional, but the reference studies show it carries the staging (Pen Strength, Warmth, Hull Integrity, Guard Sleep).
6. A good number of openings are one flat image ("gifts_overflow_sled", "feast_laid_cast_gathers"), not a moving event.

9.7 needs: map the story ids to the closed lists (or send the artist a change request that adds the missing ones: for example
`cake_plate`, `clock_face`, `rim_ledge`, `tram_track`, `rail_chasm`, `stack_ledge`, `tent_floor` as terrains, and `gear_grind`,
`geyser_spout`, `lava_rise`, `spotlight_sweep`, `heap_stomp` as actions); fix the two pair repeats; restrict `react`; add a meter per
level; re-tie the set pieces listed.

### N8 Consistency with the vision and user rules: 8.8

Holds: fresh story with only the cast; biome order (Pirate 11th); Carnival boss plus bonus ends the campaign, h1 to h3 are the optional
epilogue; Neon low point with the Wizard absent; no board title copied for chapters; no "Tetris"; no Nintendo; species rulings used;
captions 12 words or fewer; no dialogue in play.

Defects:
1. Lava `twist` x3 (U16).
2. Section 5b and the whole scene-table premise disagree with `scene-vocabulary.md` (see N7).
3. Name check. "Star Scramble" (celestial_h3) paraphrases the board title "Summit Scramble" (style board 10). "Balloon Lift"
   (carnival_05) paraphrases "Balloon Race" (mockup 16). "Broadside Bash" echoes "Bridge Bashers". "Fizzy Dash" and "Wobbly Raft" are
   close to "Bridge Dash" and "Wobble Builders". Rename the first two; check the rest in the script.
4. The wide-stakes beat for Neon (islands sagging) and the "built things hold the sky" canon are told, not played (N1, N2).
5. Pirate must not reprise Underwater. pirate_08 (Hugo hauls the listing wreck, claw in the porthole echo) and pirate_06 (patch a hull) plus
   pirate_03 (raft that tips) are three water-and-hull stability beats, and underwater_08 is a crooked wreck with a claw in a porthole.
6. Vision U8 and the brief ask for per-beat YAML (`design/narrative/beats/<biome>.md`). The writer states it was not authorised;
   confirm that is deferred to the next task, not dropped.
7. Beat rows should be two sentences. Many are three or four with semicolons.

### N9 Minigame hooks fit the party rules: 8.8

Strengths: all 16 ideas appear; the good fits are ice_08 floe_footing (mascot Ada), forest_06 and neon_07 splat_claim, clockwork_02
sorting_belt, clockwork_bonus domino_run, underwater_09 and clockwork_06 gate_squeeze, lava_03 paver_rally, cave_07 sneak_route.
Hooks are given as an idea plus a story reason, which the party rules ask for.

Defects:
1. Meadow debuts three modules (gap_runner meadow_03, sneak_route meadow_04, giant_bonk meadow_10). The vision caps debuts at 2 per
   biome. `minigames.md` has giant_bonk debuting in Underwater; the story makes it the Meadow boss and then uses it in 10 of 12 bosses
   with the same sentence ("wall up, patch where he strikes").
2. fuse_rings debuts in a tier-10 boss (neon_10) with no earlier use. A boss adds no new rule (vision U9, handbook brief item 6).
3. Seven modules appear once only (floe_footing, deep_dig, sorting_belt, domino_run, fuse_rings, sky_steps, knockdown_tower). The
   brief asks each to have a debut, a recall and a tournament use. Clockwork has 4 hooks (the limit is 2 or 3).
4. cave_02's hook text is "deep_dig: clear layers to tunnel down", and the module's verb in `minigames.md` is the same. The user rule
   bans "clear N layers" as an objective. The beat objective is fine, but the hook wording must be story language (dig to wake the
   crystals).
5. neon_08 `paver_rally` says "pave the road ahead of the kart", but the beat has no kart (a lamp-bot crowd and Lumen). Lava_03 is
   the right home for it.
6. Carnival has 3 hooks (catapult_keep, wobble_plate, giant_bonk) for "a remix of every earlier idea". It should recall at least 6.
7. Phase length: no hook states a 20 to 90 second phase or its story payoff; the beat text carries the payoff, which is fine, but
   gate_squeeze and knockdown_tower have no payoff stated in the hook.
8. Per party rule 5, each hosting level names the template and its story reason in `scene.*`: the scene tables have no minigame column.

9.7 needs: debut count at most 2 in every chapter (move one of the three Meadow debuts); every module with a recall; fuse_rings
taught before neon_10; story-language hook text; hook-to-beat checks on neon_08; a Carnival that recalls 6 or more.

## Spot-check of 28 beats (2 or more per chapter)

Test per beat: opening event in sentence 1; story objective 8 words or fewer; a reason to stack; ending is a surprise; fits one
playable level; scene row tied to the place. "OK" means the check passes without a defect worth listing.

| Beat | Verdict | Finding |
|---|---|---|
| meadow_03 | 9.0 | Opening and guest ending fine (the flock crosses first). The act is a generic gap; the plain bridge is the whole level. Add a twist to the act. |
| meadow_09 | 8.9 | Strong image (hill tips like a tray). The "Gert is lonely" reveal here pre-empts the boss ending in meadow_10. Move it. |
| meadow_bonus | 8.5 | "Pack the victory picnic" is the container pattern; the hidden crown is the 11-of-12 secret pattern. |
| candy_05 | 9.3 | Decoy tier with a jack-in-the-box is a clean reveal. Objective fine. |
| candy_09 | 9.0 | The wave delivers the stair step: good, but "Hold back the chocolate wave" is a plain defence. `story` label is the event, not an ending twist. |
| candy_10 | 8.8 | Four acts (shields, base, ladder, laugh). Fine for a boss but a copy of the generic "Jester is forgiven" ending. |
| ice_07 | 8.9 | Same objective and reveal as underwater_07 and cave_08 ("light a path", the dark thing is gentle). |
| ice_08 | 9.6 | Best low-key emotional beat in the first half. Ada "lets herself be helped". Keep. |
| ice_10 | 9.0 | Good boss concept (wave him "at ease"). Ending is telegraphed by the chapter caption ("still waiting for orders"). |
| underwater_06 | 9.3 | Sif returns pearls and the elder gives one back: warm, earns the guest slot. |
| underwater_09 | 8.7 | Ending ("calm water draws the shell plan") is obscure, reads as plain. |
| lava_06 | 9.5 | The empty seat is the right sort of tension. But it is the third lava twist (cap). |
| lava_09 | 9.5 | "Nobody looks at the Wizard" is a perfect beat. The reveal is earned. |
| lava_07 | 9.2 | The helmet-on-a-rock heartbeat is exactly on the line: no harm shown. Keep, but cap the twists (lava has three). |
| forest_05 | 9.6 | Best reveal in the draft (Sif's own treehouse). Check the Knotty / Wizard backstory conflict. |
| forest_09 | 8.9 | "Roots only wanted guests" repeats the friendly-creature surprise. |
| cave_05 | 9.0 | Toe as stalagmite is funny, but the set piece (`bat_roost`) belongs to cave_04. |
| cave_08 | 9.1 | Sif leads by ear is the cave's emotional turn. Same family as ice_07. |
| clockwork_05 | 9.2 | The hidden thirteenth slot is good set-up. The caption already says "even the thirteenth". |
| clockwork_09 | 8.9 | Objective ("Prop the shuddering tower") is generic. The Wizard's exit is never a playable beat. |
| neon_03 | 9.1 | The sidewalk delivering them to Lumen is a nice twist, but it warms the low point. |
| neon_09 | 9.3 | Emotional peak; five acts in one level. Needs trimming and a pre-signalled recovery for Lumen. |
| celestial_08 | 9.2 | Sideways dome and rattle: strong. The rattle falling in sentence 1 telegraphs the end. |
| celestial_10 | 9.4 | Best boss: lift her view. Ending ("she keeps twelve, wants a party") sets the finale well. |
| pirate_06 | 9.0 | The patch becomes the crew's flag is good. It is one of three hull/leak beats. |
| pirate_08 | 8.5 | Plain, a hull-stability repeat of underwater_08 and pirate_03. Hugo's cameo is the only fresh part. |
| carnival_06 | 8.8 | "Stock the prize shelf" is a fill goal; the faded promise slip repeats a reveal already made in celestial_06. |
| carnival_10 | 9.4 | Great payoff of flaw and gag. Needs the Heap's ten objects to be seen earlier; rattle/pan contradiction. |

Mean of spot-checks: 9.1. Eight of the 28 are at or above 9.5 in concept; the weaknesses cluster in the plain 01 to 03 beats, bonuses,
hard levels and the repeated reveals.

## Reference-study room check (defence and mockups)

- Defence studies D1 (hold the wall) and D3 (shield and strike) have a home: ice_04, pirate_10, the Heap, celestial_10. D2 (plug the
  breach) and D4 (shelter the guest) have none outside meadow_02. Add at least one D2 and two D4 levels.
- Best non-obvious endings in the studies that the story does not use yet: ice floe that is a sleeping whale (IC3); an avalanche that
  is a stretching snow giant that carries you up (IC1); the snow giant's nose as the last block (IC4); bees that are builders (CA4); sugar
  ants carrying sprinkles home (candy defence); a kraken reaching for its trapped baby, so the boss leaves as an ally (underwater
  defence); a dragon in a party hat at the lava line (LV1); a nest that is empty with the egg under the cart (LV4); a rubble pile that
  was a door opening (CV4); a goblin chief joins the cast (forest D1); a furnace that is a music box (used in clockwork_bonus); steam is
  the tower breathing (CW4); a cloud that is sneezing (CE3); Boulder racing the player (FO3); the white-flag final block (pirate
  Broadside); a prize tower that is the boss's fort (carnival).
- Scenario patterns the story lacks: "outrun the rolling hazard" (boulder or snowball chase), "pull and push field", "collect", "material
  twist", "rising hazard" outside the boss and lava_09.
- Themed meters from the studies would answer the missing `hud_meter` column.

## Ordered fix list (addressed to the narrative writer)

1. **Hat Dip and Wrong Sack (N1, N5).** Put each of the ten wrong objects into the opening event of one beat in its chapter (add to
   candy_01, ice_02, underwater_01, forest_01, cave_04, clockwork_01 and reconcile meadow_08's umbrella). Fix the Heap list: remove the
   rattle and the pan or make them the last thing the Heap stole back. Rewrite section 2.1 to match.
2. **Scene vocabulary (N7, N8).** Read `scene-vocabulary.md` and delete section 5b's claim that it does not exist. Reduce each chapter to
   7 to 8 terrain ids and 7 to 8 action ids; map them to the closed list or file one change request that adds the missing ids. Fix the
   two repeated pairs (candy_h3, carnival_h1). Restrict `react` to animals and props. Re-tie the set pieces listed under N7.
3. **Lava endings (N4, N8).** Change one of lava_04, lava_06, lava_07 to a reveal, guest or plain ending so no pattern is used more than
   twice.
4. **Endings rotation (N4).** Vary the slots: at least 4 chapters with a boss ending that is not `story`; at least 5 bonuses that are
   not `secret` (guest, reveal, twist); each chapter's two plain beats not always 01 and 02; no more than 2 "it was friendly" surprises in
   the campaign; at least one non-plain hard level per chapter. Replace obscure endings (underwater_09, clockwork_09, neon_09).
5. **Boss formula (N2).** Give at least 4 bosses a different resolution than "lonely villain, gift, Keystone": for example Cuckoo set by a
   Wizard trick, Mae by Lumen's recovery, Cinderbottom by Boulder (a peer), Bea by a tie. Move the villain's secret out of beat 09 for six
   chapters.
6. **Bonus and hard levels (N3).** Replace the "pack or fill a container" bonus in at least 6 chapters with distinct scenes (a parade, a
   chase, a guest meal, a reveal). Rewrite the 36 hard levels so each changes the situation (a new place, a twist in the villain's act,
   a role swap), not "twice as fast". Drop the counter feel from "Fill ..." and "Stock ..." objectives.
7. **Carnival payoff (N2, N8, N9).** Add `callback_of` ids to at least 6 Carnival rows (a windmill ring, a lamp-bot stage, a cart on the
   floe, a clock slot, a trellis). Show Ada's laugh and Bram's cake tier in beats. Reveal the wheel promise once; cut carnival_06 or
   carnival_08 to a different reveal and pull the early hints (cave_bonus, celestial_06) back to props.
8. **Adopt studies (N3, N4).** Add D2 and D4 levels to Meadow, Forest, Lava, Cave and Clockwork (no more than two defence levels per
   biome). Pick 10 of the endings listed above for the beats now using "friendly creature". Add a rolling-hazard chase in Ice or Forest.
9. **Cast (N5).** Show the Wizard's vanity (his star stamped on towers) in two of chapters 1 to 4 and one Wizard row in Underwater. State
   Ada's, Bram's and Sif's resolution as beats in chapters 9 to 12. Put Lana's too-warm scarf and Boulder's sit-on-it in one beat each. Settle
   Knotty's backstory.
10. **Tone (N6).** Add one unsettling note to each of lava_01 to lava_04. Keep neon_06 and neon_07 hollow (no warm payoffs). Make neon_09's
    Lumen recovery pre-signalled. Add one tension beat each to chapters 3, 4 and 8.
11. **Minigame hooks (N9).** Move one Meadow debut; teach fuse_rings before neon_10; move paver_rally off neon_08; reword the cave_02 hook
    without "layers"; reduce Clockwork to 3 hooks; give Carnival 6 recalls; give each single-use module a recall row.
12. **Premise text (N1).** Rewrite the two-sentence summary at 25 words per sentence. Show "blocks remember how they were placed" in one
    beat.
13. **Names (N8).** Rename "Star Scramble" and "Balloon Lift"; check "Broadside Bash", "Fizzy Dash" and "Wobbly Raft" against the name
    script. Cut pirate_08 or give it a different act so Pirate does not reprise Underwater.
14. **Row hygiene (N3).** Trim neon_09, lava_08, candy_10 and carnival_10 to one act each; every row to two sentences. Add a `hud_meter`
    column and a `minigame` template column to the scene tables.

## Scene ids proposed for the vocabulary (flag only)

Terrains worth adding because they carry a place: `cake_plate`, `clock_face`, `rim_ledge`, `tram_track`, `rail_chasm`, `stack_ledge`,
`tent_floor`, `wheel_base`, `seabed_sand`, `lagoon_floor`. Actions worth adding: `lava_rise` (rule), `spotlight_sweep` (rule),
`heap_stomp` (rule), `gear_grind` (cos), `geyser_spout` (cos), `snore_gust` (rule). Mark each cosmetic or rule as the vocabulary file
requires.

## Re-review

Send the revised `campaign-story.md` for r2. The reviewer will re-run the table parse, re-check the 28 spot-check beats and check
that each fix above is closed.
