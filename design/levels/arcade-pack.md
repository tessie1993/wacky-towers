# Toy-Box Trials: nine practice dioramas

> **Status:** authored level and story intent, 2026-10-10.
> **Rules:** `design/gdd/arcade-pack.md`; external tuning in `minigames/arcade_pack/levels/*.json`.
> **Scope:** standalone single-player trials; no campaign replacement, new unlock, keepsake or multiplayer claim.

## Level Names and Themes

Three tiny sets let the cloud wizard practise familiar block magic. Meadow makes a useful toy for Pip's picnic; Clockwork turns it into a delivery job for Tock; Celestial makes an absurdly cosy bedtime toy for Comet. Each mascot remains in its own biome. No recurring rival cameo or hat reveal is added. Every vignette can stand alone: its goal is visible, its surprise is mechanical, its payoff comes from the player's final action.

| Mode | Meadow — lesson | Clockwork — mix | Celestial — mastery |
|---|---|---|---|
| Perfect Stack | **Picnic Beacon** — build a lookout | **Clockwork Lift** — raise the gear platform | **Moon's Pillow** — build a tall sleeping perch |
| Hole in the Wall | **Basket Gate** — turn a toy picnic parcel through hedge gaps | **Gear Courier** — route the last gear through workshop shutters | **Star Thread** — turn a constellation through sky windows |
| Shadow Workshop | **Picnic Lantern** — make a two-sided picnic sign | **Clockwork Sign** — build two useful directions from one toy | **Comet's Constellation** — draw stars around cloud gaps |

These names are narrative metaphors for the implemented toys. A gear parcel is still the same cube-built Piece Set shape; a lantern/sign is still a cube sculpture. Every goal stays recognisably about the blocks.

## Estimated Play Time

| Stable ID | Main challenge | Target visit | Cap / 3-star / 2-star |
|---|---|---|---|
| `stack_meadow` | 8 slabs, steady alternating slides, 3 magnets | 25–60 s | 80 / 24 / 44 s |
| `stack_clockwork` | 10 slabs, alternating axes + smooth pulse, 2 magnets | 30–65 s | 85 / 27 / 48 s |
| `stack_celestial` | 12 slabs, pulse + starwind cadence, 1 magnet | 35–70 s | 90 / 30 / 52 s |
| `wall_basket_gate` | 5 passes, front gates, 2 slack cells, 4 misses | 40–90 s | 100 / 38 / 68 s |
| `wall_gear_courier` | 6 passes, alternating front/side, 1→0 slack, 3 misses | 50–100 s | 110 / 65 / 82 s |
| `wall_star_thread` | 7 passes, exact mixed-axis holes, 2 focus charges, 3 misses | 60–110 s | 115 / 55 / 88 s |
| `shadow_picnic_lantern` | 3 blueprints, 3³ grid, budgets 4/5/6, no forbidden cells | 3–5 min | 300 / 180 / 240 s |
| `shadow_clockwork_sign` | 3 blueprints, 3³ grid, budgets 5/6/6, forbidden counts 1/3/3 | 4–6 min | 360 / 240 / 300 s |
| `shadow_comets_constellation` | 3 blueprints, 4³ grid, budgets 6/9/10, forbidden counts 2/4/5 | 5.5–8 min | 480 / 330 / 420 s |

Visits include reading the action and a possible retry. These are authored targets, not measured completion times. Star goals remain optional speed challenges; first completion should favour understanding.

## Layout Diagram and Sightlines

| Set | Play space | Primary sightline | Quiet story space |
|---|---|---|---|
| Stack | Roughly 4×4 support footprint, height expanding upward | Moving slab → fixed landing ghost → supported top | Mascot/goal prop on island rim, behind and below the stack |
| Wall | Bounded 5-cell frame, one piece, front or side approaching wall | Piece silhouette → hole core → incoming direction marker | Parcel destination beyond frame; hedge, clock or skylight trim outside hole |
| Shadow | Small voxel pad with a depth cursor | Cursor/build → front panel → side panel | Lantern post, direction sign or cloud motif outside target panels |

The camera fits the full decision space. Stack can grow its framing as height rises; wall keeps the approaching side readable; shadow keeps both panels visible together. Foreground props never overlap the piece, open-hole cells, magnet guide or projection errors. A new wall axis is announced by a direction cue and a slow first arrival.

## Critical Path

1. Choose a trial in the hub, see its rule, objective and controls, then start with the common round seed.
2. Make the first meaningful action within five seconds: lock a slab, rotate a parcel, or toggle a cube.
3. Read the resulting success/error feedback and adjust. Recovery is an active option: magnet, Celestial wall focus, or removal/undo.
4. Meet the stage goal. The win is caused by the final supported slab, passed wall, or exact two-panel match on the third blueprint.
5. See a results card with stars and elapsed time, then replay or choose another trial.

All nine stages are selectable. The lesson → mix → mastery order is recommended presentation, never an artificial lock. There is no maze, collectible route or compulsory story sequence.

## Optional Paths

Optional mastery comes from resource choices: finish Stack with magnets left or with a Perfect streak, clear Wall with fewer focus uses or exact core fits, and solve Shadow with a different legal arrangement. These are expressive replay goals, not implemented extra rewards or hidden achievements. Star times offer the only shared speed challenge. Skip/replay must leave story timing and the main campaign untouched.

## Encounter List

### Perfect Stack

| Stage / position | Encounter and lesson | Mechanic mix | Failure and recovery |
|---|---|---|---|
| Picnic Beacon, first 2 slabs | X then Z teaches the two viewing directions | Constant speed + clear support | Trim explains overlap; three magnet charges allow recovery |
| Picnic Beacon, middle/top | Preserve enough width to reach slab 8 | Alternating axis + narrowing support | A partial miss changes next decision; complete miss restarts immediately |
| Clockwork Lift, first 2 slabs | Familiar placement with visible pulse | X/Z timing + smooth pendulum rhythm | Two magnets preserve a useful landing platform |
| Clockwork Lift, final 4 slabs | Keep width while cadence grows | Learned timing + speed ramp + mild speed wave | Observing a full sweep remains allowed; no forced drop deadline beyond cap |
| Moon's Pillow, lower half | Read seeded starwind cadence | Two axes + pulse + speed variation | One magnet is a meaningful choice rather than random rescue |
| Moon's Pillow, final 4 slabs | Land on the width the player preserved | Mixed cadence + accumulated support decisions | Goal remains height; a Perfect streak is optional precision expression |

Stack tuning: Meadow speed 2→3 cells/s, Perfect ±0.18 cells, magnet ±0.9; Clockwork 2.1→3.6, Perfect ±0.14, magnet ±0.8, wind 0.2 at 3.8 s, pulse 0.16 at 2.2 s; Celestial 2.2→4, Perfect ±0.11, magnet ±0.7, wind 0.45 at 3.1 s, pulse 0.26 at 1.8 s. The wind/pulse modulates speed smoothly; it is not an unannounced push. Long observation is safe until the visible round timer expires.

### Hole in the Wall

| Stage / position | Encounter and lesson | Mechanic mix | Fairness guard |
|---|---|---|---|
| Basket Gate, first wall | Turn a planar parcel into the indicated gap | Projection fit + generous slack | Front approach, slow interval, reachable witness |
| Basket Gate, later walls | Place as well as rotate | Rotation + bounded translation | Empty slack cells are clearly distinct from core |
| Gear Courier, first asymmetric parcel | A gear-shaped toy has different front/side faces | Multiple rotation axes + translation | First exposure stays slow enough to inspect |
| Gear Courier, later walls | Choose early delivery for speed or a closing-beat send for score | Precision + scheduled contact + optional rhythm bonus | Waiting for the bonus is optional; it never changes the pass goal |
| Star Thread, first walls | Inspect an exact sky window with a familiar approach | Previously learned rotation/translation + exact masks | First front and first side arrivals both use 12 s introduction |
| Star Thread, later walls | Compare the correct silhouette, spend focus if needed, choose delivery time | Mixed front/side approaches + exact holes + focus + optional beat bonus | Every wall validates a rotated/translated witness pose |

Use `frame_size`, `pass_target`, `miss_limit`, `wall_interval`, `wall_interval_min`, `wall_ramp`, `hole_slack`, `slack_step_every`, `shape_pool`, `target_turns_y`, `target_turns_x`, `wall_axes`, `axis_intro_interval`, `rhythm_window`, `rhythm_bonus`, `focus_charges`, `focus_seconds`, `focus_rate`, `stun_seconds`, and `tight_charge` from the stage JSON. No level is tuned by inventing a different collision rule.

Wall cadence: Basket Gate interval 10→8 s, first front 12 s, ramp 0.35 s/gate; Gear Courier 9→6.5 s, first axes 13 s, ramp 0.4 s/gate, final-second +1 manual-send bonus; Star Thread 8.5→5.5 s, first axes 12 s, ramp 0.45 s/gate, `[Z,X,X,Z]` pattern, final-1.2-second +1 bonus and two 2.5-second focus charges at 35% wall speed. Space sends immediately; waiting lets contact judge the fit automatically. The full round timer advances while focus slows a wall.

### Shadow Workshop

| Stage / position | Encounter and lesson | Mechanic mix | Fairness guard |
|---|---|---|---|
| Picnic Lantern, first cube | One cube lights a cell in both panels | Toggle placement + two projections | Tiny target; panels stay visible |
| Picnic Lantern, depth discovery | Two depth cells can look like one from the front | Depth navigation + front/side agreement | Reversible construction, no hidden model copying |
| Clockwork Sign, first socket | Front success does not guarantee side success | Two silhouettes + efficient cube budget + one forbidden socket | First blocked placement has one stable crossed marker |
| Clockwork Sign, final correction | Reuse a cube to satisfy both signs | Budget + removal/undo | Cube removal refunds capacity |
| Comet's Constellation, cloud gap | A tempting cell is forbidden | Two silhouettes + budget + legal-cell mask | Forbidden cells have stable visible markers |
| Comet's Constellation, completion | Find any sculpture that draws both star shapes | Spatial reasoning across all learned constraints | Authored valid witness; any equivalent legal solution wins |

The witness sculpture is test evidence. It is never a secret exact construction criterion. A puzzle that can only be solved through a forbidden cell, or that needs more cubes than its budget, is invalid authored content.

Blueprint sequence and layouts are explicit data: Meadow `lantern_post` → `picnic_arrow` → `firefly_roof`; Clockwork `gear_lever` → `chime_bridge` → `double_sign`; Celestial `star_window` → `comet_kite` → `moon_beacon`. Silhouette rows are authored bottom-to-top, matching Godot Y-up. All cubes may float, so the puzzle concerns projections and legal sockets rather than physical support. E/Q changes height; up/down changes depth. Every stage's timer spans all three blueprints, with a fresh build and undo history after each success.

## Pacing Chart

Intensity is an authored 1–5 target, not an observed score. Story poses occupy the rim and never change a simulation deadline.

| Stage group | First action | Middle decisions | Final goal | Results / retry |
|---|---:|---:|---:|---:|
| Meadow lessons | 1 — safe introduction | 2 — repeat the action | 3 — complete a useful toy | 1 — immediate relief |
| Clockwork remixes | 2 — familiar action with a beat | 3 — combine learnt choices | 4 — deliberate precision | 1 — clean release |
| Celestial mastery | 2 — inspect the announced constraint | 4 — compare two facts at once | 5 — small clutch finish | 1 — calm, cosy payoff |

A failure should teach one cause at a time: support missed, silhouette outside the hole, or projection mismatch. Do not bury it beneath a story reaction. The cap remains visible, and players can spend the available recovery resource before the next decision.

## Narrative Beats

The following are wordless staging briefs, not claims that complete mascot animations are already implemented. Each intro is at most 3 seconds, lives before simulation and is skippable. Each payoff is at most 5 seconds and follows success. Human-readable JSON story strings preserve these briefs for later presentation; use objective/twist fields for functional help.

| Stage | Intro problem / hand-off | Goal-matched payoff | Gentle failure gag |
|---|---|---|---|
| Picnic Beacon | Pip's basket hides the hill; Pip points up, then at the wizard | Completed block lookout raises a tiny picnic pennant | Pennant flops onto Pip's basket |
| Clockwork Lift | Tock stretches toward a gear shelf, runs down, looks up | Highest slab puts the gear beside the clock mechanism | Tock's winding key slowly stops; toy gear rolls into a tray |
| Moon's Pillow | Comet curls on a low block, looks toward a higher pillow | Top slab supports a tiny pillow; Comet's tail makes a sparkle curl | Pillow lands softly over Comet's eyes |
| Basket Gate | Pip compares the block parcel with a hedge opening | Last passed wall brings the parcel beside the picnic blanket | Toy parcel bonks the hedge and wobbles |
| Gear Courier | Tock points from a cube-built gear parcel to a delivery shutter | Final fit opens the shutter and reveals a clock-hand icon | Cuckoo-shaped shutter springs shut harmlessly |
| Star Thread | Comet follows a star outline through a sky-window frame | The last passing silhouette threads a ribbon of stars | A star toy catches on the frame, then gently spins |
| Picnic Lantern | Pip holds up two lantern panels that show different incomplete signs | Both correct shadows reveal the same picnic pennant | The sign turns sideways; Pip tilts its ears |
| Clockwork Sign | Tock rotates a sign, finds its second face blank, looks up | Correct front and side signs both point toward the clock | Tock follows the wrong arrow in a tiny circle |
| Comet's Constellation | Comet draws a star tail but clouds leave gaps | Matching projections join the stars into a cosy curl | Tail drawing becomes a question curl; no stars are lost |

Story-mechanic test: removing the rule from any row would also remove its payoff. The lookout needs height; the parcel needs silhouette fit; the sign needs both projections. None requires dialogue to explain why the goal matters. A player who skips every beat still understands and plays the complete challenge.

## Music and Audio Cues

Audio is an integration brief, not a new copyrighted music dependency. Reuse each biome's configured default track until user-supplied music is available. No new voice lines, stems or required external downloads.

| Event | Cue intent | Readability rule |
|---|---|---|
| Stack ordinary lock / Perfect | Wood-like toy tap / brighter two-note tap | Precision cue must sound different from loss of support |
| Magnet / focus use | Soft charged chime | Feedback only on a charge actually spent |
| Clockwork pulse | Light mechanical tick | Follows visible cadence; distinct from the round countdown |
| Wall approach / new axis | Short directional whoosh | Never masks contact/fail sound |
| Wall pass / bonk | Click into place / soft rubber bump | Failure remains comic and concrete |
| Shadow place / remove | Separate small taps | Distinguishable without looking at the cube count |
| Exact projection match | Paired panel chime | Win only after both panels and legal-build constraints agree |
| Time cap / results | Short neutral timeout / warm toy-box flourish | No punishment stinger; retry remains inviting |

## Creative Review and Remaining Validation

The chosen arc meets the user request for variety through distinct verbs and mixed mechanics while keeping the block vocabulary consistent. Story stakes fit each verb without adding a story-driven campaign dependency. The practical review sent to implementers requires reachable wall witnesses, replay-safe deterministic timing, meaningful recovery, exact two-panel equality and alternatives accepted as valid sculpture solutions.

Before final balance, observe new players completing one lesson and one mastery stage per mode. Record misunderstanding cause, first-action delay, completion time and retry count. Widen a confusing arrival or recovery window before stacking another effect. Mobile controls, final mascot animation, definitive star targets and multiplayer adapters remain separate validation work; this document records authored intent and must not be cited as evidence those tests already passed.
