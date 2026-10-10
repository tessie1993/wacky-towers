# Accessibility Requirements: Wacky Towers (Meadow MVP)

> **Status**: Draft · **Author**: accessibility-specialist + Tessa · **Date**: 2026-10-10
> **Scope**: title/menu, island map, Meadow 01–10 + bonus, settings, pause, results. Android first, phones in portrait **and** landscape; keyboard/gamepad as secondary input.
> **Target**: WCAG 2.1 AA where it maps to games (contrast, colour, timing, flashes, input), plus Game Accessibility Guidelines "basic" tier. AAA items are marked and never block.

**Every number here is a tunable default** (user rule: specs are flexible defaults, never hard rules). The rule each requirement protects is the fixed part; the value can move after playtests.

**Tiers**: **MUST** = MVP gate blocks without it (user decision 2026-10-10 or WCAG AA). **SHOULD** = MVP, may slip with sign-off. **LATER** = after MVP.

**Owner** is the system/GDD that implements it. "Settings" means the Settings screen spec in `design/gdd/ux/` (to be written in Phase 1). Systems-index #37 *Onboarding & Accessibility* is listed as Alpha / Not Started; this document pulls its settings into the MVP (flag for producer).

---

## 1. Global settings rules

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-01 | All accessibility settings live in one **Accessibility** page reachable from title **and** pause; changes apply live, no restart; saved per profile. | Players fix problems mid-level, not only at first run. | Settings · Save & Profile | Change any ACC setting from pause → takes effect on resume; survives app restart. |
| ACC-02 | **First-run prompt**: before level 01, a one-screen picker: hand (R/L), orientation, control preset, reduced motion, colourblind symbols. Skippable; all reachable later. | Players who need these should not have to find them after failing. | Onboarding · Menus | Fresh install shows the picker; skip leaves defaults; choices persist. |
| ACC-03 | Every setting has **Reset to default** (per page). | Customisation must be recoverable. | Settings | After remapping everything, reset restores the preset in one tap. |

## 2. Controls: presets, remap, layout (MUST)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-10 | **Control presets**: *Buttons* (Scheme A Twin Pads, default until the prototype decides), *Gestures* (Scheme B Drag & Flick), *One-handed* (R or L cluster), *Simple* (Buttons with hold-repeat on and soft-drop toggle). | Different hands and grips need different schemes; presets are the quick path. | Touch Controls | Each preset loads a layout that wins meadow_01 by `input_simulate`. |
| ACC-11 | **Action remap (touch)**: any on-screen button can be reassigned to any action: Turn ◀/▶, Flip ◀/▶, Roll ◀/▶, Move ×4, Soft drop, Hard drop, View ◀/▶, Hold, Pause. One action per button; conflicts swap. | Lets players put the action they use most under their strongest finger. | Touch Controls | Swap Hard drop and Turn ▶ → each button sends the new action; conflict prompt offers swap. |
| ACC-12 | **Button layout editor**: drag to move, pinch/slider to resize each button **75–200%** of default, but never below the minimum target (ACC-14) and never over the board rectangle. Separate saved layout per orientation. | Hand size, thumb reach and phone cases vary; portrait and landscape differ. | Touch Controls · HUD | Move/resize in landscape, rotate phone → portrait layout is independent; a button cannot be dropped onto the board. |
| ACC-13 | **Left-hand mirror** swaps touch zones and HUD groups (already specified); available in every preset. | Left-handed and one-arm players. | Touch Controls · HUD | Existing AC (Touch #3, HUD #2) pass in both orientations. |
| ACC-14 | **Minimum targets**: any tappable ≥ 48 dp (Android) / 44 pt (iOS); in-play buttons ≥ 56 dp; ≥ 8 dp gap between in-play buttons; decoration excluded. | Art bible §7; motor accuracy under time pressure. WCAG 2.5.5 is AAA, adopted as a project rule. | Touch Controls · HUD · Menus | Device check at 100% and 150% UI scale on the reference phone and the smallest supported phone: every target measures ≥ the minimum. |
| ACC-15 | **Keyboard + gamepad remap**: every gameplay and menu action has a default binding and is rebindable; menus fully navigable by D-pad/arrows with visible focus. | Bluetooth controllers, Chromebooks, switch/adaptive controllers mapped as gamepad. WCAG 2.1.1. | Input (GUIDE contexts in `src/game/input/`) · Menus | Complete title → 01 win → results with gamepad only, then with keyboard only; rebind Turn ▶ and it holds after restart. |
| ACC-16 | **No chords, no required holds**: no action needs two simultaneous inputs; soft drop has a **toggle** option; hold-to-repeat can be off (tap per step). | Motor: single-finger and switch play. | Touch Controls · Fall, Drop & Lock | With toggle soft drop and repeat off, meadow_01 is winnable with one finger. |
| ACC-17 | **Hard drop safety** option: Off / normal / *double-tap to hard drop*. Default normal. | Accidental hard drops are the costliest mis-tap. | Touch Controls | With double-tap set, a single tap does nothing; double within 300 ms drops. |
| ACC-18 | **Timing sensitivity** sliders exposed: repeat delay, repeat interval, hold threshold, drag px per cell, flick thresholds (ranges already in Touch Controls F1–F3). | Tremor and slow-release users. | Touch Controls | Each slider changes the F-value live; values clamp to the GDD ranges. |

## 3. Camera control types (MUST)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-20 | **Camera control**: *free orbit* (board drag follows the finger, settles to the nearest 30° snap on release) is always on; *snap buttons* (30° steps, hold-repeat) and the four corner shortcuts are always available; *Auto* (see ACC-21) is an optional setting, default off. (Decision 2026-10-10; ADR-0014.) | Some players cannot swipe precisely; some cannot reach extra buttons. | Camera & Rotate-View · Touch Controls | Each mode turns the view and ends on one of the 12 snaps; snap buttons work in all modes. |
| ACC-21 | **Auto** mode (default proposal): the camera never moves on its own during normal play; it auto-snaps only (a) to the nearest allowed snap on gravity change, and (b) when the landing ghost is fully hidden from the current snap, to the nearest snap where it is visible. Max one auto-turn per piece. Optional setting, off by default (decision 2026-10-10). | Removes the need to rotate for players who can't, without surprise motion. | Camera & Rotate-View | Build a stack hiding the ghost → camera turns once to a snap where the ghost is visible; no turn otherwise. |
| ACC-22 | **Invert** for swipe orbit and for View ◀/▶ buttons. | Mental-model differences (turn board vs. turn camera). | Camera | Invert on → same swipe turns the other way. |
| ACC-23 | **Orbit sensitivity**: px of drag per 30° step, 40–160 px, default 80. | Precision vs. reach. | Camera · Touch Controls | Slider changes step distance live. |

## 4. Vision (MUST unless marked)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-30 | **Colourblind symbols on blocks**: a shape symbol on each cube face centre (block art sets keep the centre clean for it). Setting: *Off / Symbols / Symbols + patterns*; default **Symbols**. Symbols also on the ghost, preview and hold plates. | 6 candy hues collide for protan/deutan/tritan (art bible §4.6). WCAG 1.4.1. | Piece Set · Block art sets · HUD | Protan, deutan, tritan simulation screenshots of a full 01–10 stack: every piece type is identifiable without colour. |
| ACC-31 | Colour never the only cue for: danger (chevron line + pulse), buff/debuff (chevron direction + shell), blocked (bonk + outline), target cells (ribbon pattern), gizmo axes (solid/dashed/dotted), stars vs hazards (shape). | Art bible §4.6 backups made mandatory. WCAG 1.4.1. | Game Feel & VFX · HUD · Board | Greyscale screenshot of each cue still reads. |
| ACC-32 | **Contrast**: text ≥ 4.5:1 against its plate; UI icons, button outlines, ghost and height line ≥ 3:1 against what they sit on. | WCAG 1.4.3, 1.4.11. | Art · HUD · Menus | Contrast measured on the screenshot set for title, map, HUD (each Meadow backdrop), results, settings. |
| ACC-33 | **Text and HUD scale** 100 / 125 / 150% (default 100). Minimum text 12 pt body, 18 pt HUD numbers at 100%. Layout reflows (HUD second row) and the board shrinks only within Board F5. | Low vision; small phones. Art bible §7, HUD edge case. | HUD · Menus | At 150% no text clips or overlaps in either orientation; cube edge stays ≥ 20 px or Settings warns. |
| ACC-34 | **Ghost visibility**: landing ghost always on; option *Ghost: normal / bold* (thicker outline + higher alpha). | The ghost is the core readability tool, more so in fog. | Movement & Rotation · Board | Bold ghost ≥ 3:1 against stack in every Meadow backdrop. |
| ACC-35 | **Fog readability (meadow_07)**: the falling piece, its ghost, the height/danger line and the HUD are never fogged; fog VFX never overlay the live piece area; faded cubes keep their symbol at the same alpha. Relaxed timing (ACC-50) raises fog alpha 0.1 → 0.25 and visible time 5 → 8 s. | Fog is a memory challenge, not a vision test. | Level-Specific (EV02) · meadow.md 07 · Game Feel | Screenshot mid-fog: piece, ghost, danger line at ≥ 3:1; with Relaxed on, faded stack alpha 0.25. |
| ACC-36 SHOULD | **High-contrast board** option: darken backdrop/islands, thicken piece ink outlines. | Low vision, glare outdoors. | Art · Camera (environment dim) | Toggle on → backdrop luminance drops, pieces unchanged in hue. |
| ACC-37 LATER | Screen-reader labels on menus via Godot AccessKit (4.5+). | Blind/low-vision menu access; gameplay itself is visual. | Menus · ui-programmer | TalkBack reads every menu control name and state. |

## 5. Motion and photosensitivity (MUST)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-40 | **Reduced motion** (one setting: System / On / Off, default **System** = follows the OS "remove animations" setting; still offered at first run; decision 2026-10-10): no shake, no punch, no confetti bursts, instant view turns, instant piece turns, static danger highlight, pop-ins become fades. Gameplay timing identical. | Vestibular disorders and motion sickness. Already in several GDDs; this makes it one switch. | Game Feel & VFX · Camera · Movement · HUD | Existing ACs (VFX #4, Camera #26, HUD #11, Touch #6) pass from the one toggle. |
| ACC-41 | **Gravity flip under reduced motion (09, 10)**: the hill-turn and stack tumble become a short cross-fade (≤ 300 ms) to the flipped board; warning arrows + countdown ring stay. | The full-board flip is the largest motion in the MVP. | Level-Specific (EV03) · Game Feel | With reduced motion, a flip shows no rotation of the board or camera. |
| ACC-42 | **Skits**: every intro/payoff skit can be skipped with one tap; under reduced motion skits play without camera moves or fast shakes. Intro skits never eat play time (already true). | Motion, cognitive load, replays. | Narrative skits · Level flow | Tap during any skit → skips to Countdown/results; reduced motion → no camera movement in skits. |
| ACC-43 | **Flash limit always on** (not a setting): no element flashes more than 3 times per second; danger pulse ≤ 2 Hz; no full-screen flash; saturated-red flashes ≤ 25% of the screen area; clear/settle flashes are luminance fades ≥ 150 ms. | WCAG 2.3.1 Three Flashes; seizure safety. | Game Feel & VFX · HUD | Frame capture of a 4-layer clear + warning + flip: passes a PEAT/Harding-style check (≤ 3 flashes/s). |
| ACC-44 SHOULD | **Screen flash / effect intensity** slider 0–100% (default 100) scaling confetti and glow. | Photophobia, visual clutter. | Game Feel & VFX | 0% → no particles above priority 2. |

## 6. Audio and haptics (MUST unless marked)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-60 | Separate **Music / SFX / UI** volume sliders (0–100, default 80/100/80), each mutable; **Master** slider SHOULD. | User decision; hearing and sensory sensitivity. | Audio (`design/gdd/audio/`) · Settings | Each bus changes independently; 0 is silent. |
| ACC-61 | **Haptics** toggle (default on) + intensity Low/Med/High (SHOULD). Haptics never carry information alone. | User decision; some find vibration painful or it's unavailable. | Game Feel & VFX | Off → no vibration calls; every haptic event also has a visual. |
| ACC-62 | Every gameplay-relevant sound has a visual twin: gust (bent grass + arrow), flip (arrows + ring), danger heartbeat (pulsing line), clock (ant line in bonus + HUD clock), warning (token break). | Deaf/HoH players, muted phones. | Audio · Game Feel · Level-Specific | Play 03, 07, 09, 10, B muted: every event is anticipated visually. |
| ACC-63 SHOULD | **Mono audio** toggle; no sound louder than the music bus peak by more than 6 dB (no jump-scare stings). | Single-sided hearing; startle sensitivity. | Audio | Mono on → L = R; loudness check on cue list. |

## 7. Time pressure and cognition

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-50 | **Relaxed timing** (one toggle, default off): fall speed × 0.7; lock delay × 1.5; every telegraph (gust 1 s, flip 2 s) × 2; level time limits (bonus 60 s) × 1.5; fog per ACC-35. **Goals unchanged** (same layers/height/shape); Survive T unchanged (08 is easier, not longer). Star times scale by the same factor so stars stay earnable; no badge or penalty; all 3 stars stay earnable (decision 2026-10-10). Formula: `design/gdd/onboarding-accessibility.md` F1. Applied at level start only. | Time pressure is the main barrier in a falling-block game; keeping goals intact keeps the puzzle. WCAG 2.2.1 Timing Adjustable. | Fall, Drop & Lock · Level Goals · Scoring & Stars · Level Data | With Relaxed on, every Meadow level is won by `input_simulate` at the slower speed; goals equal the normal ones; bonus clock reads 1:30. |
| ACC-51 | **Pause anytime** (single-player), including during skits and warnings; auto-pause on app background and on phone turn (already specified). | WCAG 2.2.2; interruptions. | Level Goals · Touch Controls | Pause during a flip warning → clock and flip timer stop. |
| ACC-52 | **Goal always visible**: goal plate shows icon + number; rule icons tappable for name + one-liner (HUD rule 6); pause menu lists all active rules. | Cognitive load; wordless story. | HUD | Existing HUD ACs #1, #8. |
| ACC-53 SHOULD | **Rotation help**: option to show the axis gizmo always; option to limit rotation to Turn only in levels that don't require 3D (01). | 3D rotation is the concept's top usability risk. | Touch Controls · Movement | Gizmo-always shows rings on every piece. |
| ACC-54 SHOULD | **Replay tutorial / first-time hints** from settings; emote bubbles use icons with ≥ 3:1 contrast. | Memory, returning players. | Onboarding · Narrative | Replay hints → next level shows its hints again. |
| ACC-55 LATER | Extra assists: more warnings (rescue +1), extra preview, hold on in all levels. | Wider difficulty range; affects stars, needs design. | Level Goals · Spawner | — |

## 8. Orientation and devices (MUST unless marked)

| ID | Requirement (default) | Rationale | Owner | Acceptance |
|---|---|---|---|---|
| ACC-70 | Portrait **and** landscape fully playable; both meet ACC-14 and ACC-33. | User decision; mounted devices and one-handed use need portrait. WCAG 1.3.4 Orientation. | Touch Controls · HUD · Camera | Every Meadow level won in each orientation; screenshot per orientation. |
| ACC-71 SHOULD | **Orientation lock** in settings (Auto / Portrait / Landscape). | Bed/wheelchair-mounted phones rotate unintentionally; each turn pauses the level. | Settings · platform | Locked portrait → physical turn does nothing. |
| ACC-72 | All UI inside safe-area insets; no essential control in the gesture-nav strip. | Android back/home gestures collide with edge buttons. | HUD · Touch Controls | Reference + smallest phone, gesture nav on: no edge swipe triggers a game action. |

---

## Conflicts flagged for owners

- **Art bible §4.2** says at higher difficulty "identifying blocks by colour alone is an intended skill" and block art sets ask whether hard levels may hide the shape symbol. ACC-30 requires symbols stay when the colourblind setting is on, at every difficulty (owner: art-director / game-designer).
- **Rotation actions**: resolved, three pairs (Turn/Flip/Roll). `src/game/input/actions/` still has only `rot_h_*` / `rot_v_*`; ADR-0012 section 3 renames them and adds `rot_roll_*`.
- **Systems-index #37** Onboarding & Accessibility is Alpha priority; the MVP needs its settings. GDD now exists: `design/gdd/onboarding-accessibility.md` (producer: move to MVP).

## Decisions (former open questions, closed by user 2026-10-10)

1. **Rotation (Q1)**: three rotation pairs, player-facing **Turn / Flip / Roll** (code ids `spin` / `tilt` / `roll`); Roll is taught in meadow_02. ACC-11's "if kept" no longer applies.
2. **Camera (Q2)**: free orbit with snap to the nearest of 12 x 30 degree steps on release; four corner views as shortcuts; **Auto** (ACC-21) is an optional extra setting, off by default. ACC-20's "Swipe orbit" mode is now the base scheme and always on; the mode list is Snap buttons / Free orbit / Auto. (ADR-0014 section 3.)
3. **Relaxed timing (Q3)**: still earns all 3 stars; star times are scaled by `relaxed_time_scale` (formula in `design/gdd/onboarding-accessibility.md` F1); no badge, no flag stored.
4. **Button scale (Q4)**: 75-200%, in-play minimum 56 dp (hit area never drawn smaller, even at 75%).
5. **Reduced motion (Q5)**: follows the OS setting by default (`system` / `on` / `off`, default `system`); the first-run picker still offers it. This replaces "default off" in ACC-40 and in `design/gdd/ux/settings.md`.

Remaining flag for owners: `design/gdd/ux/settings.md` (layout editor range 100-150%, Camera control type, reduced-motion default Off) and `design/gdd/ux/README.md` ("one profile in MVP") predate these decisions; ADR-0013 now has 4 profiles from the start.
