# Minigame Mockups: Audio Review

> **Author**: audio-director (for Tessa)
> **Date**: 2026-10-13
> **Status**: Review / proposal. Nothing here changes `design/gdd/audio.md` or ADR-0015 until the user decides the open points in §6.
> **Inputs**: `assets/art/reference/minigame_mockups/mockup_01.jpg` to `mockup_10.jpg` (40 minigame panels viewed), `design/gdd/audio.md`, `design/gdd/audio/audio-direction.md`, the contents of `assets/audio/sfx/` and `assets/audio/music/`.
> **User decision this review serves**: minigames are building blocks *inside* levels, reskinned per biome, and also random head-to-head tournament rounds.
> **Caveat**: existing files are matched **by name and intended use only**. None have been auditioned for this review. Every "reuse" below must be checked by ear (sound-designer) before its cue row points at it.

---

## 0. What the mockups tell audio

- **The 40 panels reduce to about 11 mechanic modules.** Most panels are one module shown with a different biome skin (lava, ice, jungle, candy, underwater, space, steampunk, desert). That fits the "building block, reskinned per biome" decision: audio should be built **per module**, with a **biome material layer** swapped on top, the same way the core block family already works (*The Block Is the Constant*).
- **Nearly every panel has a vertical danger meter** (Heat, Lava Rise, Altitude, Balance, Topple Risk, Stability, Pressure, Oxygen, Water Flow, Hull Integrity, Egg Temperature, Grid Heat, Guard Sleep). Audio needs **one shared meter-to-tension system**, not 13 bespoke ones (§2.3).
- **Up to 4 player HUD cards on one screen**, often with a live leaderboard. Today the audio GDD only plans for 2 boards (ADR-0009). §3 is new ground.
- **Boss bars** (Kraken, Jungle Giant, T-rex nest, airship) and **fort HP bars** add hit/damage feedback that the falling-block core does not have.
- Several panels carry a "Next Module" HUD slot (mockup_02, Bridge Dash), which is exactly where the phase-change stinger (§2.1) belongs.

**Biome material layer**: every module cue below is split into a **core** (shape, timing, pitch contour, identical everywhere) and a **material** (wood / stone / ice / candy / metal / bubble / neon). The core carries the information; the material is the reskin. A biome that has not got its material yet plays the core alone, which is valid.

---

## 1. Per-module SFX events

Cue ids follow the existing registry style (`SFX_<AREA>_<THING>`); files follow the existing flat folder style (`mg_<module>_<thing>.wav`). Priority numbers are the GDD rule 4 tiers (1 = highest). "Param" means a continuous 0–1 value the cue reads every frame.

### M1. Rising Hazard Climb
*Panels*: Avalanche Ascent, Summit Scramble, Frenzy Footholds, Pyramid Climber, Ancient Ascenders, Jungle Giant Ascent, Jungle Bridge Rush ("Height to Safety").

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Hazard rising (loop) | `SFX_MG_CLIMB_RISE_LOOP` | 3 | Lava rumble / snow roar / sand hiss by biome. **Param `intensity`** = meter value: gain −18 → −6 dB, low-pass 600 Hz → 3 kHz, bubble-pop density up | `w3_quicksand_sink` (sand skin, temp) |
| Hazard surge (sudden jump) | `SFX_MG_CLIMB_SURGE` | 1 | Telegraph 0.8 s before the jump | `w3_quicksand_warn` (telegraph), `warning` |
| Block placed as foothold | core `lock` | 2 | No new cue: core block family | `lock.wav`, `drop.wav` |
| Player reaches new height band | `SFX_MG_CLIMB_HEIGHT_STEP` | 4 | Rising pentatonic blip, one step per band | `ui_star` (temp) |
| Player caught by hazard | `SFX_MG_CLIMB_CAUGHT` | 1 | Soft "fwump" + puff, never a scream (cozy) | `mg_heart_lost` |
| Falling debris telegraph | `SFX_MG_CLIMB_DEBRIS_WARN` | 3 | Whistle-in, like the anvil | `w3_anvil_whistle` |
| Falling debris lands | `SFX_MG_CLIMB_DEBRIS_HIT` | 3 | | `w3_anvil_clang` (metal), `w3_tile_crumble` (rock) |
| Summit reached | `SFX_MG_CLIMB_SUMMIT` | 2 | | `mg_treasure` / `w3_gold_clear` |

### M2. Bridge Build
*Panels*: Bridge Bashers, Bridge Dash, Jungle Bridge Rush, Chroma Sky Climb.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Plank / block seats into the span | `SFX_MG_BRIDGE_PLANK_THUNK` | 2 | Hollow, resonant version of `lock`: same transient, longer body, pitch up per plank in the span (ripple-step table, F3) | `lock.wav` + pitch (temp) |
| Span completed | `SFX_MG_BRIDGE_SPAN_DONE` | 2 | | `clear.wav` |
| Plank cracks (warning) | `SFX_MG_BRIDGE_CREAK` | 1 | Telegraph before break | `w3_tile_crack`, `w3_hinge_stuck` |
| Plank breaks / falls | `SFX_MG_BRIDGE_BREAK` | 2 | | `w3_tile_crumble` |
| Splash into river (water skins) | `SFX_MG_BRIDGE_SPLASH` | 4 | | NEW |
| Footstep on bridge | `SFX_MG_BRIDGE_STEP` | 5 | Very quiet, wood ticks, max 2 voices | `move.wav` (temp, pitched down) |
| Wind gust (sky skins) | reuse existing gust telegraph | 3 | | `wind.wav` |

### M3. Siege / Catapult
*Panels*: Fort Frenzy, Fort Blast, Shatter Shootout, Airship Scrap Brawl, Kraken Blockade (cannon side).

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Aim / wind-up (loop while held) | `SFX_MG_SIEGE_WINDUP` | 4 | Ratchet clicks, rate rises with power; **param `power`** | `mg_spin_click` (per-click) |
| Catapult launch | `SFX_MG_SIEGE_LAUNCH` | 2 | Wooden "thwack-whoosh" | `mg_send` + `ui_whoosh` layered (temp) |
| Cannon fire | `SFX_MG_SIEGE_CANNON` | 2 | Toy pop-gun "BOMF", not a real gun | NEW |
| Projectile in flight (incoming at you) | `SFX_MG_SIEGE_INCOMING` | 1 | Descending whistle, only for the targeted player's side | `w3_anvil_whistle` |
| Block hit (wall) | `SFX_MG_SIEGE_IMPACT` | 2 | Material layer: stone / ice / candy / wood. **Param `damage`** = gain +0 to +3 dB (as F2) | `mg_pin_knock`, `mg_strike` |
| Block destroyed | `SFX_MG_SIEGE_SHATTER` | 2 | | `w3_tile_crumble` (stone), NEW ice/candy skins |
| Tower topples | `SFX_MG_SIEGE_TOPPLE` | 2 | | `mg_topple` |
| Fort HP threshold crossed (50 %, 25 %) | `SFX_MG_SIEGE_HP_STEP` | 1 | | `warning` |
| Miss (lands in water/ground) | `SFX_MG_SIEGE_MISS` | 4 | Comic "plop" | `mg_wrong` (temp) |

### M4. Boss
*Panels*: Kraken Blockade, Abyssal Kraken Siege, Kraken Keep, Jungle Giant Ascent, Prehistoric Nest Defense.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Boss hit by player | `SFX_MG_BOSS_HIT` | 2 | Rubbery "bonk" + short squeak; cartoony, satisfying | `mg_whack_bonk` |
| Boss big hit / weak spot | `SFX_MG_BOSS_CRIT` | 2 | Bonk + bell | `mg_whack_golden` |
| Boss attack telegraph | `SFX_MG_BOSS_WINDUP` | 1 | **Must differ by timbre from every other telegraph** (GDD rule 6): low rising "whomp" + bubbling for kraken, chest-thump for giant | `mg_attack_warning` (generic, temp) |
| Boss attack lands | `SFX_MG_BOSS_SLAM` | 1 | | `mg_dodge_hit` |
| Player dodged | `SFX_MG_BOSS_DODGE` | 4 | | `ui_whoosh` |
| Boss phase change (bar threshold) | `SFX_MG_BOSS_PHASE` | 2 | Roar replaced by a wordless instrument emote (GDD rule 11: no voices) | NEW |
| Boss defeated | `SFX_MG_BOSS_DEFEAT` | 2 | Deflating balloon + confetti | `w3_confetti` + NEW deflate |
| Boss idle (loop) | `SFX_MG_BOSS_IDLE_LOOP` | 6 | Ambience bus, slow sloshing/breathing | NEW |

### M5. Balance / Topple Stack
*Panels*: Tumbling Towers, Cake Stackers, Sugar Rush Stack, Kraken Keep, Clockwork Chaos.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Stack creak (loop) | `SFX_MG_BALANCE_CREAK_LOOP` | 3 | **Param `tilt`** (= Balance/Topple meter): creak rate and pitch rise, gain −24 → −8 dB | `w3_hinge_stuck` (temp grains) |
| Wobble warning | `SFX_MG_BALANCE_WOBBLE` | 1 | Fires at meter ≥ 0.75, 3 s cooldown | `mg_jenga_pull` |
| Piece removed / pulled | `SFX_MG_BALANCE_PULL` | 3 | | `mg_jenga_pull` |
| Stack collapses | `SFX_MG_BALANCE_COLLAPSE` | 1 | | `mg_topple` |
| Plate / platform tilt shift | `SFX_MG_BALANCE_TILT` | 4 | | `flip.wav` (pitched down) |
| Food-material lands (candy skin) | material layer on `lock` | 2 | Squish / jelly boing | NEW |

### M6. Dig
*Panels*: Rubble Rumble, Digging Frenzy.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Dig crunch | `SFX_MG_DIG_CRUNCH` | 3 | Max 3 voices, random ±2 st (F3) | `mg_dig_shovel` |
| Hard-rock clank (no progress) | `SFX_MG_DIG_CLANK` | 3 | | `w3_anvil_clang` (pitched up, short) |
| Block breaks open | `SFX_MG_DIG_BREAK` | 3 | | `w3_tile_crumble` |
| Gem / crystal revealed | `SFX_MG_DIG_GEM` | 2 | | `w3_coin`, `mg_treasure` (big gem) |
| Lava pocket breached | `SFX_MG_DIG_LAVA_BREACH` | 1 | Hiss + bloop | `w3_pressure_hiss` |
| Depth milestone | `SFX_MG_DIG_DEPTH_STEP` | 4 | Descending blip (mirror of the climb step) | NEW (pitch-flip of climb step) |
| Drill vehicle (loop) | `SFX_MG_DIG_DRILL_LOOP` | 5 | One shared instance, not per cart | NEW |

### M7. Conveyor / Factory
*Panels*: Clockwork Conveyor, Factory Frenzy Assemble, Galactic Grab, Steampunk Gear-Up, Sweet Rush Rails.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Conveyor running (loop) | `SFX_MG_BELT_LOOP` | 6 | Ambience bus. **Param `speed`** (= Conveyor Speed meter) drives playback rate 0.8–1.4 and a clack rate | NEW (existing belt telegraph from Level-Specific Mechanics should be the warn) |
| Belt speed-up | `SFX_MG_BELT_SPEEDUP` | 3 | | `w3_pressure_release` (temp) |
| Claw grab | `SFX_MG_BELT_CLAW_GRAB` | 3 | | `w3_magnet_pull` (temp) |
| Item delivered correctly | `SFX_MG_BELT_DELIVER` | 2 | | `mg_correct` |
| Wrong item / jam | `SFX_MG_BELT_JAM` | 1 | | `mg_wrong`, `w3_hinge_stuck` |
| Gear mesh / turn | `SFX_MG_BELT_GEAR` | 5 | | `mg_spin_click` |
| Furnace / press stamp | `SFX_MG_BELT_STAMP` | 3 | | `w3_anvil_clang` |
| Rail cart (candy skin) | material layer on loop | 6 | | NEW |

### M8. Flow / Pipe / Pressure
*Panels*: Coral Conduit, Deep Sea Bubble Build, Submarine Salvage, Abyssal Kraken Siege (Hull Integrity).

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Water flowing (loop) | `SFX_MG_FLOW_LOOP` | 6 | **Param `flow`** (Water Flow Rate) | NEW |
| Pipe segment connects | `SFX_MG_FLOW_CONNECT` | 2 | Hollow "clunk-glug" | `lock.wav` + NEW glug |
| Circuit completed | `SFX_MG_FLOW_COMPLETE` | 2 | | `clear.wav` + bubble swell |
| Leak / pressure warning | `SFX_MG_FLOW_LEAK` | 1 | | `w3_pressure_hiss` |
| Pressure vented | `SFX_MG_FLOW_VENT` | 3 | | `w3_pressure_release` |
| Oxygen low tick | via meter tick (§2.3) | 1 | | `mg_parade_tick` |
| Bubble pop | `SFX_MG_FLOW_BUBBLE` | 5 | | NEW |
| Salvage winch / crane | `SFX_MG_FLOW_WINCH` | 4 | | `mg_spin_click` (temp) |

### M9. Maze / Heist / Run
*Panels*: Maze Heist, Pirate Plunder Maze, Temple Roller Run, Pyramid Climber (boulder).

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Guard asleep (loop) | `SFX_MG_HEIST_SNORE_LOOP` | 5 | Wordless snore "instrument" (tuba/kazoo), **param `sleep`** = Guard Sleep meter: slower and deeper when asleep | NEW |
| Guard stirring | `SFX_MG_HEIST_STIR` | 1 | Snore breaks + rising kazoo | NEW |
| Guard wakes / alarm | `SFX_MG_HEIST_ALARM` | 1 | | `w3_bolt_warning` |
| Key picked up | `SFX_MG_HEIST_KEY` | 2 | | `ui_unlock` |
| Door / chest unlocked | `SFX_MG_HEIST_UNLOCK` | 2 | | `mg_treasure` |
| Boulder rolling (loop, rolling module) | `SFX_MG_RUN_BOULDER_LOOP` | 3 | | `mg_bowl_roll` |
| Coin collected | `SFX_MG_RUN_COIN` | 4 | | `w3_coin` |
| Trap dart / arrow telegraph | `SFX_MG_RUN_TRAP_WARN` | 1 | | `w3_anvil_whistle` (short) |
| Player squashed / hit | `SFX_MG_RUN_HIT` | 1 | | `mg_dodge_hit` |

### M10. Gravity / Laser Arena
*Panels*: Wormhole Gravity Rush, Magnetic Mash, Nebula Laser Hack, Cosmic Gravity Goal, Galactic Grab lasers.

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Vortex / gravity pull (loop) | `SFX_MG_GRAV_PULL_LOOP` | 3 | **Param `pull`** (Spatial Pull / Grav Force) | `w3_magnet_hum` |
| Block yanked into well | `SFX_MG_GRAV_SUCK` | 3 | | `w3_magnet_pull` |
| Laser telegraph | `SFX_MG_LASER_WARN` | 1 | | `w3_bolt_warning` |
| Laser fires | `SFX_MG_LASER_FIRE` | 1 | | `w3_bolt_strike` |
| Laser blocked | `SFX_MG_LASER_BLOCKED` | 3 | | `w3_bolt_fizzle` |
| Goal scored (ball module) | `SFX_MG_GOAL` | 2 | | `mg_jackpot` |
| Hoverboard boost | `SFX_MG_BOOST` | 4 | | `w3_fever_start` (short, temp) |

### M11. Paint / Claim
*Not seen in mockups 01–10; included because the brief names it.*

| Event | Cue id | Prio | Notes | Reuse |
|---|---|---|---|---|
| Paint splat (claim tile) | `SFX_MG_PAINT_SPLAT` | 3 | Max 4 voices, slot pitch offset (§3) so each player's splats are tellable | `mg_paint_dab` |
| Overpaint (steal a tile) | `SFX_MG_PAINT_STEAL` | 2 | Splat + reversed "zip" | `mg_paint_dab` + NEW |
| Region filled | `SFX_MG_PAINT_FILL` | 2 | | `w3_gold_row` |

### Shared module-level events (every module)

| Event | Cue id | Reuse |
|---|---|---|
| Module intro / ready / go | `SFX_MG_READY`, `SFX_MG_GO` | `mg_count_reveal`, `mg_go` |
| False start | `SFX_MG_FALSE_START` | `mg_false_start` |
| Module objective done | `SFX_MG_OBJECTIVE` | `w3_gold_clear` |
| Score tick (leaderboard change) | `SFX_MG_SCORE_TICK` | `w3_coin` (quiet) |
| Lead change | `SFX_MG_LEAD_CHANGE` | NEW |
| Player eliminated | `SFX_MG_ELIMINATED` | `mg_heart_lost` |
| Comeback (trailing player closes gap) | `SFX_MG_COMEBACK` | NEW (*Comeback Energy*) |
| Win / lose round | core `win` / `lose` | `win.wav`, `lose.wav` |

---

## 2. Music

### 2.0 The constraint this has to live with

The user decided on 2026-10-10: **one full user-supplied track per level, no stems, no layers, no clip-switching**; music adapts only by ducking and filtering (audio GDD rules 8–9, audio-direction §5). This review asks for tournament **layers** and **meter-driven tension**, which pushes against that decision. Below, every music feature is designed to work **without stems first**. The one place where a true layer would add real value (the tournament) is offered as an explicit option in §6 for the user to decide. I have not assumed it is approved.

### 2.1 Phase-change stinger (level switches module)

| Item | Spec |
|---|---|
| Cue | `MUS_STING_PHASE` (Music bus, jingle duck: track to −12 dB over 150 ms, restore over 400 ms; existing knob) |
| Length | 1.2–1.6 s, with a clean tail (no reverb wash past 2 s) |
| Content | Fixed **motif**: glockenspiel + woodblock, rising 4th then 5th ("ta-da-DING"), toybox-folk palette. Unpitched where it overlaps the track's key, so it never clashes with an unknown user track |
| Biome reskin | Optional single **material hit** under the motif (wood knock, ice chime, candy boing, metal clank), the same material set as §1. The motif stays identical everywhere (*The Block Is the Constant*) |
| Module identity | Optional 2-note tail per module (11 tails) so the ear learns "boss is next" before the HUD does. Phase 2; not needed for MVP |
| Timing | Fires on the module-switch **event frame** (GDD rule 2: no beat-waiting). If the switch has a transition cover, the stinger starts on the cover, and the next module's "Go" sits after its tail |
| Music across the switch | **The level track keeps playing** (no restart). Only the duck applies. If a module has its own catalogued track, crossfade 1 s starting under the stinger tail |
| Reuse now | `w3_mystery_reveal` + `ui_whoosh` as a placeholder; `w3_fever_start` is an alternative candidate |

### 2.2 Tournament head-to-head

The tournament round already has an asset to anchor it: `assets/audio/music/party.wav`. Its role should be confirmed in the music catalogue (`music.json`) as `tournament_theme`.

**Structure (stem-free version, recommended for MVP)**

| Round phase | What the player hears | Mechanism |
|---|---|---|
| Matchup reveal (who vs who) | `MUS_STING_VERSUS`: two-hit drum "bom-BOM" + cymbal swell, ~1.5 s | Jingle on Music bus |
| Countdown | `party` track crossfades in over 1 s (existing rule) | Existing |
| Play, calm (tension < 0.5) | Full track, low-passed slightly (8 kHz) so the climax has somewhere to open | Music LowPass (existing effect, new cutoff value) |
| Play, contested (scores within ~10 %, or tension ≥ 0.5) | Filter fully open, +1 dB | Bus tween |
| Final 10 s ("clutch") | **Tension pulse**: an unpitched clock-tick + shaker loop on a separate player, tempo-locked to the track's catalogued BPM | See §6 Q1: this is effectively one extra layer |
| Lead change | `SFX_MG_LEAD_CHANGE` (bright 2-note flip) | SFX bus |
| Round won | Track fades 0.5 s, then `win` jingle, then `MUS_STING_ROUND_WIN` with the winner's slot colour note (§3) | Existing result flow |

**Layered version (only if the user reopens the no-stems decision for the tournament)**

| Layer | Content | Enters when |
|---|---|---|
| L0 Base | Bass, light kit, chords | Always |
| L1 Drive | Busier percussion, ukulele strum | Tension ≥ 0.5 or scores close |
| L2 Clutch | Lead melody / glock hook, shaker 16ths | Final 10 s or any meter ≥ 0.9 |

Layers are fade-in only during a round (never dropped mid-round, so the round only ever "climbs"), 2-bar fades. This needs 3 synced stems of one track, a sync-start player and an ADR-0015 change (technical-director). It is a cleaner result but it reverses a recent user decision, so it is listed as a question, not a recommendation.

### 2.3 How tension scales with the meters

One shared rule for every module meter, so 13 meters need no bespoke audio.

**Input.** Each module reports one normalised danger value per player, `m_i` in 0..1 (1 = about to fail). Meters that fill "good" (e.g. Guard Sleep, Hull Integrity) report `1 − value`.

**Shared tension.** `T = max(m_i)` over players still in the round (one music mix, GDD rule 15). Hysteresis: a band is entered at its threshold and left only at threshold − 0.05, so a jittering meter does not flicker the filter.

| Band | T | Music | Meter tick (SFX bus, prio 1) | Module loop param |
|---|---|---|---|---|
| Calm | < 0.50 | Normal (8 kHz LP in tournament) | none | follows `m` |
| Warm | 0.50–0.75 | LP opens fully / no change in story levels | `mg_parade_tick` at 1 per s | follows `m` |
| Hot | 0.75–0.90 | LP 4 kHz, −2 dB (0.5 s in) | 2 per s, +2 st | follows `m` |
| Critical | ≥ 0.90 | Existing **danger** treatment: LP 2 kHz, −4 dB; `SFX_GOAL_DANGER` once (existing 5 s cooldown) | 4 per s, +4 st | follows `m` |

**Formulas (proposal for the GDD if accepted)**

- Tick rate: `rate_hz = 1 × 2^floor((T − 0.5) / 0.2)` for T ≥ 0.5 (1, 2, 4 per s). Range 0–4 Hz.
- Music cutoff while T ≥ 0.75: log-interpolate `cutoff = 4000 × (2000/4000)^((T − 0.75)/0.15)`, clamped to 2–4 kHz. Example: T = 0.825 → 4000 × 0.5^0.5 ≈ **2 830 Hz**.
- Loop gain from a param p: `gain_db = −18 + 12 × p` (−18 to −6 dB). Example p = 0.5 → −12 dB.

**Whose meter ticks.** Only one tick voice exists, driven by `T`. In story levels that is the solo player's meter. In head-to-head it is the player in most danger, and the tick carries that player's **slot pitch offset** (§3), so the room hears *who* is in trouble without four ticks fighting.

**Cozy guard.** Nothing below 120 Hz rises with tension on phone speakers (rumble lives in 200–800 Hz), no heartbeat sound, no minor-key stinger. "Tense but not scary" (audio GDD Player Fantasy).

**Comeback Energy.** When the trailing player's score closes to within the comeback threshold, fire `SFX_MG_COMEBACK` (rising "whoop" + sparkle) and keep the filter open even if T is high: a comeback should feel like lift, not doom.

---

## 3. Mix rules for 2–4 players

1. **One mix, never N mixes.** All players share the buses and pools (extends GDD rule 15 from 2 boards to 4). Simultaneous identical cues still merge under the 50 ms cooldown.
2. **SFX headroom trim by player count.** `sfx_trim_db = −3 × log2(n / 2)` for n ≥ 2: 2P 0 dB, 3P **−1.75 dB**, 4P **−3 dB**, applied to the SFX bus only (not UI, not priority-1 cues). Keeps 4 players' worth of events from pushing the sidechain into constant ducking.
3. **Pool size by player count.** SFX pool 12 at 1–2P, **16 at 3–4P** (already the top of the safe range). Priority stealing as today: lowest priority, then oldest.
4. **Per-cue voice caps** for high-rate shared cues: dig crunch 3, paint splat 4, footsteps 2, score tick 2, impacts 4. Loops are **one instance per module**, never per player (one belt, one lava, one vortex).
5. **Player identity by pitch, not pan.** Personal-result cues only (hit landed, splat, score, eliminated, meter tick) take a slot offset: P1 0, P2 +2, P3 +4, P4 +7 semitones (major pentatonic, so any mix of players sounds consonant). Core block cues (move, Turn/Flip/Roll, lock, clear) **never** take slot offsets, so the rotation-axis offsets (+5/+2/−1, GDD rule 7) stay unambiguous.
6. **No gameplay-critical panning** (mono-safe rule stands). On a single shared screen with split zones, flavour-only cues (footsteps, ambience one-shots) may pan up to ±20 % toward the player's zone. Nothing a player must react to is panned.
7. **Telegraphs aimed at one player** (incoming projectile, boss windup targeting P3) play once, centre, at full level with that player's slot offset. They are never suppressed by the cooldown of another player's identical telegraph more than 50 ms earlier: telegraph cues use a per-target cooldown, not a global one.
8. **Music duck depth caps** in 3–4P: sidechain release 300 → 450 ms so a busy 4-player arena does not "pump" the track. Tunable within the existing 150–600 ms range.
9. **Haptics are personal.** A player's pad rumbles only for that player's own events (ADR-0012 device id). Shared events (boss slam, module switch) rumble all pads once, still rate-limited at 50 ms each.
10. **Elimination silence.** An eliminated player's personal cues stop; their slot pitch is freed. The meter tick re-targets to the remaining players' max.
11. **Loudness check**: the 4P arena modules (Siege, Gravity/Laser, Paint) get their own −16 LUFS ±2 capture, because they are the densest case (add to GDD acceptance criterion 14 if accepted).

---

## 4. New SFX to synthesize

All mono, 44.1 kHz, peak −3 dBFS, energy in 700 Hz–4 kHz (audio-direction §3), toybox / cartoon, no voices. File names follow the existing `mg_*.wav` flat style. "Core" = biome-neutral; materials listed separately.

| # | File | Use | Synthesis notes |
|---|---|---|---|
| 1 | `mg_climb_rise_loop.wav` | M1 hazard loop (lava skin) | 4 s seamless loop. Brown noise band-passed 200–900 Hz, slow LFO (0.3 Hz) on cutoff; random sine "bloops" 300–700 Hz with fast pitch-up, 3–6 per s. Param drives density in engine, so render it mid-density |
| 2 | `mg_climb_rise_loop_snow.wav` | M1 ice/avalanche skin | Same loop envelope; white noise high-passed 1 kHz, gentle 0.2 Hz swell, no bloops; sparse tiny ice-tinkle sine pings 3–5 kHz |
| 3 | `mg_climb_height_step.wav` | M1 height band | 80 ms sine + 2nd harmonic, pitch 1 step up a major pentatonic; engine raises pitch per band (F3) |
| 4 | `mg_bridge_plank_thunk.wav` | M2 plank seat | Short noise click (2 ms) into a 180 Hz + 540 Hz damped resonator (decay 220 ms), slight pitch drop 5 %. Reads as hollow wood |
| 5 | `mg_bridge_splash.wav` | M2 water | Noise burst LP 3 kHz with fast pitch-down sweep, then 6–10 tiny sine droplets 1–3 kHz over 300 ms |
| 6 | `mg_siege_cannon.wav` | M3 cannon | Toy "BOMF": 120→60 Hz sine kick 150 ms + noise puff BP 800 Hz, plus a cork-pop click (1.5 kHz, 10 ms) on top so it reads on phones |
| 7 | `mg_siege_shatter_ice.wav` | M3/M5 ice material | 8–12 short sine pings 2–6 kHz with random detune, 40 ms each, scattered over 250 ms; tiny noise crackle under |
| 8 | `mg_siege_shatter_candy.wav` | candy material | Hard-candy crack: band-passed noise click 2 kHz + 3 square-wave blips 1–2 kHz, glassy but softer than ice |
| 9 | `mg_boss_phase.wav` | M4 phase change | Wordless "roar" as instrument: detuned saw pair through a vowel formant filter (a→o), pitch 220→160 Hz, tremolo 7 Hz, 700 ms. Comic tuba feel |
| 10 | `mg_boss_deflate.wav` | M4 defeat | Square wave 600→150 Hz over 900 ms with 18 Hz vibrato and noisy "air" layer (balloon squeal) |
| 11 | `mg_boss_idle_loop.wav` | M4 ambience | 6 s loop, slow filtered noise "slosh" (LP 600 Hz, 0.15 Hz LFO) + occasional low bubble bloops; very quiet |
| 12 | `mg_balance_creak_loop.wav` | M5 creak | 3 s loop of granular friction: short noise grains through a narrow resonator (400–900 Hz, random), grain rate ~6 per s; engine raises rate/pitch with `tilt` |
| 13 | `mg_balance_squish.wav` | candy/cake material on lock | Sine 300→180 Hz with fast pitch wobble (spring 12 Hz, 150 ms decay) + wet noise LP 1.5 kHz |
| 14 | `mg_dig_depth_step.wav` | M6 depth | Mirror of #3: same timbre, step **down** the pentatonic |
| 15 | `mg_dig_drill_loop.wav` | M6 drill cart | 2 s loop: saw 110 Hz with 25 Hz AM (chatter), BP 1 kHz, plus a noise layer at 2 kHz; toy-drill not industrial |
| 16 | `mg_belt_loop.wav` | M7 conveyor | 2 s loop at 120 BPM-ish: soft woodblock clack every 250 ms (BP noise 1.2 kHz, 20 ms) over a low 90 Hz motor hum with gentle 2nd harmonic; render clacks evenly so rate scaling stays rhythmic |
| 17 | `mg_belt_rail_candy.wav` | candy rail skin | Same rhythm as #16, clacks replaced by toy-xylophone ticks (sine 2.4 kHz, 30 ms) |
| 18 | `mg_flow_loop.wav` | M8 flow | 4 s loop: pink noise LP 2 kHz with 0.5 Hz modulation, plus random bubble sines (pitch-up 400→900 Hz, 30 ms) |
| 19 | `mg_flow_glug.wav` | M8 connect layer | Two descending bubble sines 700→350 Hz, 60 ms each, 40 ms apart |
| 20 | `mg_flow_bubble.wav` | M8 bubble pop | Single sine pitch-up 600→1400 Hz in 25 ms with a click at the end |
| 21 | `mg_heist_snore_loop.wav` | M9 guard | 4 s loop: inhale = noise BP 900 Hz swell 1.5 s; exhale = buzzy square 90 Hz through formant "o" + kazoo whistle 1.2 kHz. Engine slows it with `sleep` |
| 22 | `mg_heist_stir.wav` | M9 waking | Snore cut short, then rising kazoo glide 400→900 Hz with a "hm?" formant shape, 600 ms |
| 23 | `mg_lead_change.wav` | shared | Two bright marimba-like notes (sine + 4th harmonic, fast decay), a perfect 4th up, 250 ms total |
| 24 | `mg_comeback.wav` | shared, *Comeback Energy* | Rising whoop: triangle 300→1200 Hz over 400 ms + sparkle (random sine pings 3–6 kHz) on the top; reuse `wizard_sparkle` tail if it fits |
| 25 | `mg_paint_steal.wav` | M11 overpaint | Reversed short noise "zip" (BP 1.5–3 kHz, 120 ms) into a `mg_paint_dab` splat |
| 26 | `mus_sting_phase.wav` | §2.1 stinger (Music bus) | Glock (sine + slight FM bell), woodblock on each note: rising 4th then 5th, 1.4 s with natural decay. Render the core plus 4 material-hit variants (wood, ice, candy, metal) |
| 27 | `mus_sting_versus.wav` | §2.2 matchup | Two toms "bom-BOM" (sine 140 and 110 Hz with pitch drop, plus a 1 kHz stick click) + reversed cymbal (noise HP 5 kHz, reversed envelope) leading in, 1.5 s |
| 28 | `mus_tension_pulse_loop.wav` | §2.2 clutch (only if Q1 = yes) | Unpitched: clock-tick (BP noise 3 kHz, 8 ms) on quarter notes + shaker 8ths (HP noise 6 kHz, 30 ms). Render at the `party` track's BPM so it locks; must loop on a bar |

Materials still to cover later, per biome, for the shared impact/lock family: stone (exists via `w3_tile_crumble`), metal (exists via `w3_anvil_clang`), neon/space (zap: short FM blip), bubble/underwater (see #19–20).

---

## 5. Pillar check

| Pillar | What this plan contributes | Gap |
|---|---|---|
| **The Block Is the Constant** | Core block cues unchanged in every module and biome; module cues split into core + material; stinger motif fixed | 11 modules add ~80 new cue rows: the cue list grows from 79 to ~160, which the sound-designer must own |
| **Readable Chaos** | Every module hazard has a telegraph; one shared tension rule; 4P mix trim and slot pitch identity | Boss windups need **distinct timbres per boss**; temp-mapping them all to `mg_attack_warning` breaks GDD rule 6 until replaced |
| **Variation Over Depth** | Module switch stinger, biome material layer and 11 loop beds give variety without new music | Still one music track per level: modules inside a level share it |
| **Comeback Energy** | Comeback cue, lead-change cue, filter stays open on a comeback | First real audio contribution to this pillar; depends on a "trailing player" signal from the tournament system |

## 6. Open decisions for the user

1. **Tournament music layers.** Options:
   - **Stem-free + pulse** (Recommended): `party` track plus bus filtering, plus one unpitched BPM-locked tension pulse in the final 10 s. Smallest step away from the 2026-10-10 decision.
   - **Stem-free only**: filtering and stingers, no pulse at all. Fully inside the decision; the final 10 s rely on the meter tick alone.
   - **True 3-layer stems for tournament only**: best escalation, but reverses the no-stems decision for one mode and needs an ADR-0015 change and a stemmed track from the user.
2. **Meter-driven filtering in story levels.** Today the danger filter applies only on rescue levels. Should the Hot/Critical bands (§2.3) apply to every module meter inside story levels too? (Recommended: yes for Critical only, keeping Warm/Hot to the tick.)
3. **Module identity tails** on the stinger (11 two-note tails): MVP or later? (Recommended: later.)
4. **Player count.** Is 4 the hard maximum for tournament rounds? The pool size and trim formula assume it.

## 7. Hand-offs

- **sound-designer**: add the §1 cue rows to `design/gdd/audio/sfx-cue-list.md`; audition every "reuse" before binding; synthesize §4.
- **lead-programmer / technical-director**: per-cue float params (`intensity`, `power`, `tilt`, `speed`, `flow`, `pull`, `sleep`), per-target telegraph cooldowns, player-count-based pool size and SFX trim, and (only if Q1 is "stems") the ADR-0015 change.
- **game-designer**: each module must emit a normalised danger value `m_i` and the trailing-player / lead-change events.
