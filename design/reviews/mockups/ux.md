# UX review: minigame mockups → HUD pattern library, phase rule, tournament flow

> **Author**: ux-designer (agent) for Tessa · **Date**: 2026-10-13 · **Status**: Review / proposal (not yet a `/ux-design` spec)
> **Decision this serves**: minigames are **building blocks inside levels** (Campaign Minigames: modules in phases + overlays) and **random head-to-head tournament rounds** (Tournament Flow + Randomizer).
> **Sources viewed**: `assets/art/reference/minigame_mockups/mockup_01`–`20` (all 20), `screens_flow_ref.png`, `tournament_flow_ref.png`, `party_modes_ref.jpg`, `title_variants_ref.jpg`; current build `production/qa/evidence/solo-ui-storybook/01-title.png`, `02-hud.png`, `03-map.png`; `src/ui/game_ui.gd` (skimmed); `design/gdd/hud.md`, `design/gdd/ux/hud.md`, `design/gdd/campaign-minigames.md`, `design/gdd/tournament-flow.md`, `design/gdd/mode-minigame-randomizer.md`, `design/gdd/local-multiplayer-setup.md`, `design/accessibility-requirements.md`.
> **Feeds**: `design/gdd/ux/hud.md` (next revision), a new tournament screens spec, `campaign-minigames.md` HUD/UX row ("phase banner, phase progress pips, per-module meters").

---

## 0. Units and the frame

The project's canvas is **720 px on the short side** (`project.godot`: `viewport_width=720`, `stretch canvas_items / expand`). In portrait the design frame is **720 × 1280 px** (16:9, the shortest phone). Taller phones (19.5:9 → 720 × 1560) get extra height. The extra goes to the board and the thumb zone; the top band stays the same size in px.

The GDDs give sizes in pt and dp. On the canvas:

| Use | Conversion | Why |
|---|---|---|
| Layout and text | **1 pt ≈ 1.85 px** | 390 pt reference phone ÷ 720 px |
| Touch targets | **1 dp = 2 px** | Worst case: 360 dp-wide Android. A target sized this way passes on every phone. |

So, against ACC-14 and ACC-33:

| Minimum | px on the 720 canvas |
|---|---|
| Any tappable control (48 dp / 44 pt) | **96 px** (pause may use 88 px = 44 pt, as `ux/hud.md` already allows) |
| In-play button (56 dp) | **112 px** |
| Gap between in-play buttons (8 dp) | **16 px** |
| HUD numbers (18 pt minimum, 24 pt default) | **34 px minimum, 44 px default** |
| Body and label text (12 pt) | **22 px** |

> **Finding: the current build is about half-size on device.** `02-hud.png` is a 720-wide capture. Measured against the targets above:
> - Pause is 64 px (≈ 32 dp).
> - The View / Soft / 0% / Potion dock buttons are 44 px tall (≈ 22 dp).
> - Turn and Drop are 84 px (≈ 42 dp; the spec is 56 / 64 pt).
> - `_label()` clamps text to 12 **px** (≈ 6.5 pt).
> - The "L, I, S" caption, the "First Sprout" level name and the "SCORE" label are all under 22 px.
>
> This probably comes from treating canvas px as pt. ui-programmer should confirm on a device. Every size in this document is in **canvas px**, so the numbers can be built as written.

---

## 1. HUD pattern library

### 1.1 Portrait frame (720 × 1280, right-handed; mirror swaps left and right)

`S` = top safe-area inset in canvas px (0–100; assume 48 for the numbers below).

```
x: 0        104                      584      720
   ┌────────┬─────────────────────────┬────────┐  y = S+8
   │ PAUSE  │  ROW 1: score plate      │  NEXT  │  Row 1 (104 px tall)
   │ 88×88  │  or player cards 2–4     │ 120×120│
   │        │                          │        │  y = S+112
   ├────────┴──────────────────────────┤        │  y = S+128 (Next ends)
   │ ROW 2: GOAL RIBBON (544×64)  ●◉○ │ TIMER  │  y = S+136 … S+200
   │  phase pips · goal · n/N · ♥♥♡   │ 132×64 │
   ├──┬──────────────────────────────┬──┴────────┤  y = S+216  (band ends)
   │L │                              │R │
   │R │        BOARD RECT            │R │  rails 48 px wide, inset 8 px
   │A │   (no HUD, no input)         │A │  board 592 px wide when any rail
   │I │                              │I │  is reserved, otherwise 662 (92%)
   │L │                              │L │
   ├──┴──────────────────────────────┴──┤  y ≈ S+792
   │ [POWER-UP 112]   reserved row / View ◀ ▶ (Touch Controls)  │
   │ d-pad (left thumb)              rotation grid + Drop (right) │
   └──────────────────────────────────────────────┘  y = 1280 − 24 gesture margin
```

**Top band at 100% text: `S + 208` px** (256 px at S = 48, which is 20% of 1280). Row 2 starts at S+136 because the Next slot reaches down to S+128.

**Fixed-slot rule.** Pause, Next, Timer and the Goal ribbon never move during a level or a round. Only their contents change. This lets players rely on spatial memory: in a chaotic level, the eye can go to a place without first reading a label (Readable Chaos).

### 1.2 Components

| # | Component | Mockup source | Shows when | Placement (720 × 1280) | Touch target |
|---|---|---|---|---|---|
| 1 | **Player score cards** (2–4) | 01–11 side stacks; 10 round portrait chips; 12–15 P-tagged cards; 19 head-to-head plates | **Tournament / party only.** Solo campaign shows the single **score plate** (as built) in the same Row 1 slot. Shown from Countdown to Result. | Row 1, x 116–572 (456 px). **2 players**: 2 × 220 × 96 (portrait 72, name, score). **3**: 3 × 146 × 96 (portrait 56, score, short name). **4**: 4 × 108 × 96 **chips** (round 64 px portrait ring, score below, no name; the mockup 10 pattern). Each card has a **colour strip and shape badge** (P1 red ●, P2 blue ▲, P3 green ■, P4 purple ★, as in `tournament_flow_ref`), a rank numeral 1–4 in the corner, and a 6 px progress bar. **Device-per-player tournaments**: your own card is dropped, because your progress is already in the ribbon. Each opponent card then carries their **mini-board silhouette** (72 × 72) instead of the portrait (LMS rule 12). | **Display only, no taps.** Exception: tap-to-pick targeting (Tournament Minigames rule 6). While the pick window is open, each opponent card becomes a 146 × 104 target with a pulsing outline. This is only allowed with ≤ 3 opponents. 4-player chips at 108 px still pass 96 px. |
| 2 | **Timer** | Every mockup: top-centre pill | Clock goal, time-limited level, Survive, player toggle (HUD rule 2), or a tournament round (counts to `round_time_cap_s`). | Row 2 right, x 572–704, 132 × 64. Uses ⏱ icon + fixed-width digits at 44 px. Moved from the mockups' top-centre so it sits next to the goal it times (proximity). **Last 10 s**: digits go bold, the plate takes the danger edge tint and a tick sound plays each second. The change is never colour only. | Display only. |
| 3 | **Next slot**: Next Block / Next Item / Next Ammo / Next Hazard | 01–11 "Next Block" plates; 02 "Next Ammo / Next Key"; 03 "Next Hazard"; 07 "Preview" stack; 12–14 "Next Item / Ammo / Ramp / Connector" | Whenever the module has a queue (`preview_count ≥ 1`). | Top-right, x 584–704, y S+8, **120 × 120** (64 pt per HUD F1). The label word comes from the module (`NEXT`, `AMMO`, `ITEM`), sits above the art, and is ≥ 22 px. Blocks and ammo are drawn as the **real 3D piece** from the current camera yaw (HUD rule 9). A **secondary queue** (Next Hazard, Next Key) stacks as an 88 px plate directly below. The ribbon then shortens to 456 px. At most one secondary queue. | Display only. **Hold**, when enabled, is a separate plate to the left of Next. It is the one top-band tap target: 96 × 96, sends `hold`. |
| 4 | **Vertical meters**: heat, stability, oxygen, lava rise, altitude | 02 Heat; 03 Balance; 04 Stability; 05 Cargo, Water Flow; 06 Pressure; 07 Egg Temp; 10 Oxygen; 11 Heighty with portraits | Only while the module or overlay that owns the meter is active (see §2). | **Rails** beside the board. Left rail x 8–56, right rail x 664–712. Each rail is 48 wide, with a 24 px track. Height = board rect height − 32, top-aligned 16 px below the board's top. The **cap** above the track holds a 40 px icon that says what the meter is. The **kind** is coded by cap shape (§4.1). **Meter kinds:** **Rising threat** (heat, lava rise, topple risk): the fill climbs toward a **hatched danger band + ⚠ at the top**. **Draining resource** (oxygen, stability): the fill falls toward a hatched band + ⚠ at the **bottom**. **Progress** (altitude, height-to-idol): the fill climbs to a **flag** at the top, with no danger band. In races, each player's **badge/portrait marker** rides the track (mockup 11). **Merge rule**: altitude + lava rise on the same level share **one** rail. The lava fills from below and the mascot marker rides above it, so the gap between them *is* the danger. | **Not tappable.** A rail is 48 px, too narrow for a target, and sits next to the board where mis-taps are likely. The meter's name is given by the phase banner (§2) and the pause rules list. |
| 5 | **Boss HP bar** | 04 "Boss Health Bar"; 07 "Hull Integrity / Ship Health"; 11 "Castle Health"; 02 "Fort HP" (two bars) | `boss_hp` phase; `fort_siege` (rival fort %) | **Replaces the ribbon's contents** (same slot, same 544 × 64). Layout: boss icon 48 + segmented bar 360 × 24 + number `7 / 10` at 34 px. The bar has one **segment per `dmg_per_clear`**, so each clear visibly breaks one segment. In `fort_siege`, two stacked 12 px bars: **your fort** (shield icon, solid fill) and **rival fort** (crossed-swords icon, hatched fill). This matches mockup 02 but is told apart by icon and pattern, not by green vs red. | Display only. |
| 6 | **Goal ribbon** | 12–15 parchment goal plates "GOAL: BRIDGE THE GAP!"; `02-hud.png` "Clear 2 full layers 0/2"; `tournament_flow_ref` "Mode: Clear Race" card | From Countdown to Result. | Row 2 left, x 16–560, 544 × 64. Left to right: **phase pips** (§2), the module's **verb + target** at ≥ 22 px (e.g. "Bridge the gap"), **progress** `4 / 6` at 34–44 px, then **lives hearts** at the right end. Goal text is authored at ≤ 28 characters so it never truncates (see the 150% rule, §4.3). | Display only. |
| 7 | **Lives hearts** | 12–15 "LIVES ♥♥♡" | When `warnings_max > 0`. Hearts **are** the Level Goals warning tokens (HUD rule 2), restyled. | Inside the ribbon, right end, 32 px each, 4 px gap, max 5. Above 5 it shows `♥ × 6`. Remaining = **filled heart**; lost = **cracked outline heart**. Shape and fill differ, not just red vs black. Losing one: the heart breaks with a 200 ms pop (HUD rule 8); reduced motion swaps instantly. | Display only. |
| 8 | **Power-up slot** | 13–14 "POWER-UP / ITEM / TOOL / WEAPON"; 03 "Hold Item" | When items are on (tournament setting) or a module grants one. | **Bottom, not top.** It goes in the reserved item row above the d-pad (left thumb; right with the mirror), 112 × 112, with its top edge ≥ 16 px below the board rect. The mockups put it top-right. In portrait that corner is the farthest point from both thumbs (Fitts's law) and blocks the Next slot. The slot shows the item icon, a **charge ring** that fills clockwise, and **READY** text + glow when usable. Empty state: dashed outline, no icon. | **Tap = use.** 112 px (56 dp). Gamepad: Y / △; keyboard: E. Under hard-drop safety (ACC-17), double-tap is offered for items too. |

### 1.3 Things in the mockups not to copy

These are AI-concept artefacts. They are flagged so nobody builds them by accident:

- **Wrong titles.** "Tetro Party Dimensions" (06, 10) and "Wacky Party Quest" (11) are not the game's name.
- **Misspelt labels.** "Astronay", "5lf", "Nest Block", "Next Black", "Height to Satkty", "Destructien", "Castress Health", "Stability Nazard".
- **Mislabelled slot.** Mockup 15 labels a **star counter** as "NEXT BLOCK". A slot's label must describe its contents.
- **Red→green gradient meters** (01, 04, 08, 09, 11). They are not readable with deutan or protan colour-blindness (see §4.1).
- **Unlabelled twin meters** (09 Jungle Giant).
- **Upside-down tick labels.** 10% at the top and 30% or 80% at the bottom (02, 04, 05, 06).
- **Duplicate player tags.** In 12–15, P1 and P2 both have **red** tags, so colour cannot identify the player.
- **Side-stacked cards.** Up to three cards per side in landscape. They would eat the board's side margins in portrait.
- **Party-HUD title art.** A logo or title banner inside the play HUD (12–14, 19–20) spends top-band space on decoration.

---

## 2. Rule: how a multi-module level changes the HUD between phases

Grounded in Campaign Minigames rules 3–7: primary modules run in phases; ≤ 2 overlays per phase; `carry` is keep / clear / shift; a `phase_banner_ms` banner (default 1 500) plays with spawning paused and the clock running.

**P1. Slots stay, contents swap.** Across a phase change these never move: Pause, Next, Timer, the Goal ribbon, the power-up slot and the rails. Only their contents change: ribbon text and progress, Next label, which meters sit in the rails, and boss bar vs. goal.

**P2. Rails are reserved at level load.** The level loader counts the most rails any phase needs (0, 1 or 2). It reserves them for the whole level, so the **board rect never resizes mid-level**: 662 px wide with no rails, 592 px with any. The validator rejects a level whose phases would need a third rail.

**P3. Rail assignment.**
- The **left rail** holds the **primary module's** meter, the one that answers "how am I doing at the goal?".
- The **right rail** holds the **overlay** meter, the one that answers "what is coming for me?".
- With a second overlay, check the merge rule (altitude + lava) first. If they can't merge, the second overlay shows only as a rule-strip icon with a duration ring (HUD rule 2).
- The mirror swaps the rails.

**P4. Phase pips.** At the left end of the ribbon:
- `●` done (filled + ✔)
- `◉` current (ring around a dot)
- `○` upcoming (outline)

Shape carries the state, so it reads in greyscale. A single-phase level shows no pips.

**P5. The phase-change sequence.**

| t | Event | HUD |
|---|---|---|
| 0 | Phase `until` met; the piece in the air lands (GDD 3.1) | The ribbon progress fills; a ✔ stamp shows on the ribbon (250 ms); the current pip becomes `●`. Outgoing meters freeze at their final value. |
| +250 ms | **Transition banner** in (GDD 3.2) | A parchment banner **640 × 220 px**, centred horizontally, over the **upper third of the board rect**. This is the only HUD element allowed over the board, because spawning is paused and there is nothing to read underneath. Contents: `Phase 2 / 3`; module icon + verb in 44–56 px display type ("Climb!"); one goal line in 26 px ("Stack footholds to height 9"); then one line per **incoming meter**, each with its icon, name and a ◀ or ▶ arrow pointing to its rail ("◀ Altitude · Lava ▶"). |
| during the banner | **Meter swap** | Outgoing meters slide out to the screen edge (200 ms), then incoming meters slide in (200 ms) while the banner names them. The player sees each new meter at the moment its name is said, at the place it will live. `carry: clear` plays its confetti pop and `shift` scrolls the board in this window. Meters and ribbon show the new values only **after** the carry animation, never stale data. |
| +`phase_banner_ms` | Banner out (150 ms fade) | The new ribbon text, progress `0 / N`, the Next label (e.g. NEXT → AMMO) and the boss bar take over the ribbon slot if the new phase is `boss_hp`. Spawning resumes. |

**P6. First appearance is longer.** Scaffolding rule 12 says a module's first appearance is solo. On that appearance the banner adds a one-line **tip** and stays until tapped (min 1.5 s, max 5 s). Repeat appearances use the default 1 500 ms. *Needs a decision (see the end): the GDD keeps the clock running during the banner. A tap-to-dismiss banner would then cost star time, so I recommend pausing the clock for first-appearance banners only.*

**P7. Nothing appears mid-phase except danger.** Overlays start and stop with their phase, so new HUD elements arrive only through the banner. Within a phase, a meter can only enter or leave its **danger state** (§4.1). This uses the same warm edge tint as the HUD danger state, plus ⚠.

**P8. Fail cause is named.** If a level fails on a module condition (fuse 0, mascot touches lava, topples > max), the result screen names the module and highlights its meter in a frozen HUD snapshot. The player knows *what* failed, not just that it did.

---

## 3. Head-to-head tournament screen flow (portrait phone)

Mapped from `tournament_flow_ref.png` (5 panels) onto Tournament Flow states: **Setup → Round Pick → Countdown → Round Play → Round Result → (Pick | Sudden Death | Tournament Result)**. Each player is on their own device (Local Multiplayer Setup rules 1–7). The shared-tablet 2-player split uses the same screens per half, rotated 180°.

**Common chrome on every screen:**
- **Leave** (top-left, 96 px; asks ✔/✖ to confirm). Leaving drops that player for the round (TF edge case). If the host leaves, the tournament ends.
- **Round counter** "Round 2 of 5 · first to 3" (top-centre, display).
- Primary actions sit in the bottom 320 px (thumb zone).
- Every player reference uses **colour + shape badge + name**, never colour alone.

### T1. Setup & Lobby (`tournament_flow_ref` panel 1)

- Path: title → **Party** → **Tournament** → Host or Join (a nearby-host list).
- **Seats**: a 2 × 2 grid of 336 × 260 cards. Each card has an avatar, badge (●▲■★ + colour), name and status. Status uses **text + icon**: "✔ Ready" / "… Waiting". The mockup's green-vs-grey pills are not enough on their own.
- **Empty seat**: "+ Add bot" (96 px) for the host; "Waiting for player…" for everyone else.
- **Settings** (host edits; joiners see them read-only, with a lock icon):
  - Rounds: segmented control `3 · 5 · 7 · 13`, 4 × 132 × 96.
  - **Match rule: shown, not set.** "First to 3 wins" is derived from F1 `M = floor(R/2)+1`, so it is displayed. The mockup draws it like a control; it shouldn't be one.
  - Game mode: `Normal · Mixed`.
  - Items: `On · Off`.
- **Ready** button: 640 × 112 at the bottom. For the host it becomes **Start** once all seats are ready (bots are always ready).
- Gamepad/keyboard: D-pad moves between rows; A/Enter = Ready.

### T2. Round Pick wheel (panel 2)

- **The wheel shows the real candidate pool.** 3–6 slices, each with an icon + 1–2 words (Clear Race, Highest Tower, Bridge Dash…). Slice size follows the Randomizer F1 weights. Decorative slices would mislead the trailing player about what a re-roll can land on.
- Spin ≤ 3 s (Randomizer: Drawing → Showing). It lands on a **pick card** (560 × 240): mode icon, name, one-line goal (as in panel 3's "Mode: Clear Race / Be the first to clear the highlighted blocks"), and twist icons.
- **Re-roll** (Randomizer rule 6; window 5 s):
  - It appears **only on the device(s) of eligible trailing players**: 112 px, bottom-right, "↻ Re-roll · 1 left", with a 5 s countdown ring.
  - Everyone else sees "P3 ■ may re-roll…" with the same ring.
  - **Hidden in round 1** (nobody trails yet). The mockup shows "Reroll (1)" to everyone. That contradicts the GDD and would confuse the leader.
- "Starting in 3·2·1" then hands straight into Round Play. No extra tap.

### T3. Round Play (panel 3)

- **Your device**: your full board + the HUD from §1.
  - Row 1 = **opponent cards with mini-board silhouettes** and `6 / 12` progress bars, in fixed seat order (rank numeral in the corner).
  - Ribbon = the round goal.
  - Timer = round cap.
- **Panel 3's 2 × 2 four-board grid is the spectator view, not the play view.** Four 3D boards on one phone fail Board F5 (art bible §7, LMS overview). The grid is used for:
  - players who **topped out / are out** this round,
  - **sudden-death watchers**,
  - an optional host "TV view" on a tablet.

  Each cell shows the badge + name tag, the `n / N` bar (badge colour **and** the numeric value) and a danger outline.
- **Round end**: a stamp across everyone's screen, "P2 ▲ wins the round!", for 1.5 s. Then the screen auto-advances to T4.

### T4. Standings (panel 4)

- **Rows**: rank, badge + avatar + name, **wins as pips toward M** (`🏆🏆○` for M = 3), and status. Pips show the distance to victory, where a bare "2" does not.
- **Status chips (icon + text)**:
  - 🔥 "Match point!" for M − 1 wins (with the `match_point` audio cue)
  - "Streak ×2"
  - "Out" / "Rejoining"
- The last round's winner row gets a 300 ms highlight; under reduced motion it is static.
- **Next round**:
  - Each player taps **Ready** (640 × 112). It shows "2 / 4 ready".
  - The flow auto-advances after `between_round_ms` (12 s), with a countdown ring **on** the button, so nobody is stuck waiting on an AFK friend.
- When the flow loops to T2, re-roll eligibility is recomputed from these standings.
- **Sudden death** (TF rule 6): a full-width banner "Sudden death: P1 ● vs P3 ■, Clear Race" (2 s). Tied players go to T3; the others go to the spectator grid.

### T5. Tournament Win / Trophy (panel 5)

- Winner avatar with trophy, plus "**Tessa ● wins the tournament!**" (name, then badge; not just "P1").
- **Round history**: one chip per **round actually played**, each with that round's winner badge.
  - Fix: the mockup shows P1 winning R1–R3 and then R4–R5 being played. With R = 5, M = 3, the tournament ends after R3 (TF rule 5). Copying the mockup would teach the wrong rule.
- **MVP moments** (TF rule 8): 2 lines, e.g. "Biggest clear: P2 ▲ 4 layers".
- Buttons: **Play again** (host: back to T1 with the same settings and seats; joiners: Ready) and **Home**. Each is 312 × 112.
- Celebration: confetti ≤ 3 s, kept within ACC-43. Under reduced motion it is a static trophy pose.

---

## 4. Accessibility

### 4.1 Colour-blind-safe meters (ACC-30/31/32)

1. **No red→green or rainbow ramps.**
   - Every meter uses **one hue per meter kind** with a light→dark luminance ramp: threat = warm orange, resource = cyan, progress = gold.
   - "Getting worse" is shown by **position relative to a hatched danger band**, not by a hue change.
2. **Redundant cues on every meter:**
   - a **cap icon** naming it (flame, lungs/bubble, scales, flag, lava wave);
   - a **cap shape** for its kind (threat = ⚠ triangle, resource = round drop, progress = pennant);
   - **ticks** every 25%;
   - a **danger band** with a 45° hatch and ⚠ at its end.
3. **Danger state.**
   - What changes: the outline thickens 2 → 4 px, the ⚠ cap pulses at ≤ 2 Hz (ACC-43), and a soft tick plays.
   - Under reduced motion the pulse becomes a static double outline.
4. **Contrast.**
   - Meter fill ≥ 3:1 against the track; track ≥ 3:1 against the backdrop (ACC-32).
   - The rail gets a parchment backing plate (≥ 90% alpha), so it holds up against lava, sky or space backdrops. The mockups' meters float straight on busy art.
5. **Player identity.**
   - Colours: red / blue / green / purple. Red and green collide for deutan players, so the **shape badge** (●▲■★) must appear on:
     - every card,
     - every altitude marker,
     - every mini-board tag,
     - every standings row,
     - every history chip.
   - Two players must never share a tag colour (mockups 12–15 break this).
6. **Test.** Greyscale + protan/deutan/tritan simulations of each meter kind in each state (normal, danger, merged altitude+lava), and of the standings screen. Every state must still read.

### 4.2 Reduced motion (follows the OS by default; ACC-40/41/42)

| Moving thing | Default | Reduced motion |
|---|---|---|
| Phase banner | Slide + 150 ms fade | 150 ms fade only |
| Meter swap | Slide out / slide in, 200 ms each | 150 ms cross-fade in place |
| Heart loss, card rank change | Pop / slide | Instant swap; rank change shown by the numeral only (cards never reorder anyway) |
| Round Pick wheel | ≤ 3 s spin | No spin: the slices show as a static list, and the pick card highlights its slice after 600 ms (the "random" reveal beat is kept, the motion isn't) |
| Timer last 10 s | Digit bump | Bold digits + tint only |
| Trophy / round-win stamp | Confetti, bounce | Static pose, no particles |
| Danger pulses | ≤ 2 Hz | Static double outline |

### 4.3 Text size (ACC-33: 100 / 125 / 150%)

- **Minimums at 100%:** HUD numbers 34 px (default 44), labels 22 px. Button labels in tournament screens 30 px.
- **At 125%:** Row 1 cards drop names at 3 players (portrait + score); 4-player chips are unchanged.
- **At 150%:**
  - The ribbon wraps to **two lines** (64 → 96 px).
  - The timer moves into Row 1's centre if no cards are shown. Otherwise the timer stays and the hearts move to the ribbon's second line.
  - The board shrinks within Board F5 (cube edge ≥ 20 px, or Settings warns).
  - The banner grows to 640 × 300; its text never truncates.
  - Meter caps stay icon-only; their names live in the banner and pause list.
- **Authoring limits for localisation headroom:** goal text ≤ 28 characters, banner verb ≤ 12, banner goal line ≤ 40.
- **Banner reading time** at 150% text: recommend `max(phase_banner_ms, 250 ms × words)` so a longer line isn't gone before it's read (game-designer to confirm).

### 4.4 Checklist against the tournament flow

- **Keyboard only and gamepad only:** every T1–T5 control is D-pad navigable with visible focus. Default bindings: re-roll = Y / R, item = Y / E (in-round only, so no conflict), Ready = A / Enter.
- **Colour:** no meaning carried by colour alone (badges, icons, text states throughout).
- **Flashes:** stamps, wheel and confetti all within ACC-43. No full-screen flash on round win.
- **Subtitles:** announcer barks ("Match point!", "Sudden death!") always appear as the on-screen chip or banner text.
- **Timing:** auto-advance on standings (12 s) and the re-roll window (5 s) both show countdown rings. Relaxed timing (ACC-50) should stretch the standings timer, but not the re-roll window, which is shared and host-authoritative.

---

## 5. Decisions for Tessa

1. **Clock during first-time phase banners.** The GDD keeps the clock running. With P6's tap-to-dismiss tip, that costs star time.
   - **Pause clock on first** *(Recommended)*: the clock stops only on a module's first-appearance banner. Fair, but adds a special case.
   - **Always running**: simplest. The tip must then auto-dismiss at 1.5 s.
2. **Opponent card order in a round.**
   - **Fixed seat order** *(Recommended)*: cards never move. Rank is shown by numeral, so spatial memory holds.
   - **Live rank order**: the leader is always first, but cards jump mid-round.
3. **Power-up slot position.**
   - **Bottom thumb row** *(Recommended)*: reachable mid-drop, but different from the mockups.
   - **Top-right like the mockups**: matches the concept art, but is the hardest reach on a portrait phone.
4. **Meters tappable for a name?**
   - **Not tappable** *(Recommended)*: the banner and pause list explain them, with no mis-taps beside the board.
   - **Tap shows the name**: consistent with rule icons, but a 48 px rail is under the 96 px target.

**Hand-offs:**
- **ui-programmer**: the §0 sizing finding (px vs pt) before any new HUD work.
- **art-director**: meter cap icons and one-hue ramps, and fixing the duplicate red player tags in the party concept set.
- **game-designer**: P6, banner reading time, and the round-history fix.
- **accessibility-specialist**: audit §4 against `design/accessibility-requirements.md`.
