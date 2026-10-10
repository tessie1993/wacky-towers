# Settings

> Overlay from Title, Island map and Pause; returns to the screen below. Saved on change (500 ms debounce): **Sound and Screen are device-wide** (`device.json`, shared by all 4 profiles); **Controls, Camera and Access are per profile** (`slot_<n>/settings.json`) (ADR-0013 §7). Requirements and tiers: `design/accessibility-requirements.md` (wins on conflict). Patterns: [interaction-patterns.md](interaction-patterns.md) · Look: [ui-theme.md](ui-theme.md). Updated 2026-10-10 for ADR-0012/0013/0014/0016.

## Tabs and options (defaults in bold)

| Tab | Option | Values |
|---|---|---|
| **Sound** (device) | Music / SFX / UI volume | 0–100, step 10, **80 / 80 / 70**; each slider plays a sample on release; 0 mutes the bus |
| | Haptics | Off / **Light** / Strong |
| **Screen** (device) | Orientation lock | **Auto** / Portrait / Landscape (ACC-71) |
| | Window mode (PC) | **Windowed** / Fullscreen / Exclusive (F11, Alt+Enter also toggle) |
| | V-sync (PC) | **On** / Off |
| | Frame cap | PC: **Uncapped** / 30 / 60 / 120 / 144; Android: 30 / **60** / 120 (where the screen supports it) |
| **Controls** (profile) | Preset | **Buttons** (Scheme A) · Gestures (Scheme B: drag move, flick Turn/Flip, roll arcs) · One-hand (all in one corner cluster) · Simple (Buttons + hold-repeat + soft-drop toggle) |
| | Left-hand mirror | **Off** / On |
| | Edit layout | Opens the layout editor (below) |
| | Remap keys / gamepad | Per action (remap list below); press-to-bind; conflicts swap with a ✔/✖ prompt; Reset per page (ACC-03) |
| | Hold-repeat | **On** / Off (Off = one step per press, ACC-16); delay 180–300 ms (**240**), interval 60–120 ms (**90**) |
| | Soft drop | **Hold** / Toggle (ACC-16) |
| | Gesture sensitivity (Gestures only) | Drag px/cell 36–56 (**44**), flick distance 60–90 (**70**) |
| **Camera** (profile) | Free orbit + snap | Always on: drag the board to orbit freely, release settles to the nearest of 12 × 30° snaps; View ◀ ▶ step one snap; 4 corner views as shortcuts (ADR-0014). No setting to turn it off |
| | Orbit sensitivity | 40–160 px per 30° (**80**) |
| | Invert orbit and View buttons | **Off** / On (ACC-22) |
| | Auto turn | **Off** / On: at most one automatic turn per piece, when gravity changes or the ghost is hidden (ACC-21) |
| | Turn animation | **On** / Instant (reduced motion forces Instant) |
| | Occlusion help | **Level default** / always Fade / always Cutaway |
| **Access** (profile) | Text size | **100%** / 125% / 150% (ACC-33) |
| | Button size | 75–200%, step 25, **100%**. In-play buttons never below **56 dp**, menu targets never below 48 dp; at small sizes spacing shrinks first (ADR-0012 §5, ADR-0016 §8) |
| | Colourblind aid | Off · **Shapes** (piece motifs, hatched ghost, dashed danger line; on by default because it costs nothing) · Shapes + high contrast (ui-theme.md §7) |
| | Reduced motion | **Follow device** / Off / On. Follow device reads the OS "remove animations" setting at launch and on resume (ADR-0013 §7). On: no shake, instant turns, static pulses, no flash > 3/s |
| | Relaxed timing | **Off** / On: slower star times, all 3 stars still earnable, no badge (ACC-50). From Pause it applies from the next level start, and the row says so |
| | Button labels | Menus **On**, In play **Off** |
| | Rotation gizmo | **Auto** (on for meadow 01–03) / Off / Always |
| | Show level clock | **Auto** (Survive / time limit) / Always |
| **ⓘ Info** | Credits · Privacy | Opens [credits.md](credits.md) on that tab |
| | Version | `0.1.0` (text only) |

A small icon after each tab name marks device-wide tabs (speaker/screen) vs. "this profile" tabs (profile badge), so a parent knows which changes affect everyone.

## Remap list (keyboard and gamepad)

Player-facing names are **Turn / Flip / Roll**; code ids `spin` / `tilt` / `roll` (ADR-0012 §3). Keys are UX defaults; final keys are confirmed in the first-playable pass (ADR-0012).

| Action | GUIDE action | Keys (default) | Gamepad (default) | Touch label |
|---|---|---|---|---|
| Move | `move` | WASD / arrows | Left stick / d-pad | d-pad |
| Turn ◀ / ▶ (turntable) | `rot_spin_left/right` | Q / E | LB / RB | Turn ◀ ▶ |
| Flip ◀ / ▶ (toward / away) | `rot_tilt_left/right` | R / F | LT / RT | Flip ◀ ▶ |
| Roll ◀ / ▶ (around the view) | `rot_roll_left/right` | **T / G** (proposed; single keys, no chords, ACC-16) | X / Y | Roll ◀ ▶ |
| Soft drop | `soft_drop` | Shift | Left stick click | Soft |
| Hard drop | `hard_drop` | Space | A | Drop |
| View ◀ / ▶ | `view_l/r` | Z / C | Right stick left/right flick (proposed) | View ◀ ▶ |
| Corner views 1–4 | `view_corner_1..4` | 1 / 2 / 3 / 4 | Unbound (remappable) | Corner chips on the compass |
| Orbit (free drag) | n/a | Mouse drag on the board | Right stick hold | Board drag |
| Pause | `pause` | Esc / P | Start | ❚❚ |
| Restart | `restart` | Backspace (confirm) | n/a (Pause only) | Pause only |

Resolved (ADR-0012/0014 amendment 2026-10-10): shoulders = Turn, gamepad View = right stick X. Still open: `interaction-patterns.md` P8 still lists the old `rot_h/rot_v` ids and no Roll.

## Layout editor (customisation)

Full-screen, live HUD over a sample board, in the current orientation; toggle P/L preview with a button. Drag any control within its thumb zone (never onto the board rect: it snaps back with an outline + ✖), pinch or +/− to resize it **75–200%** (never under 56 dp), **Reset**, **Done**. Layouts are stored per orientation (not synced across devices, ADR-0013). Saves on Done; Back asks ✔/✖ if unsaved.

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Tabs | Row of 6 icon+label tabs at the top, 56 pt | Column on the left, 48 pt rows (6 × 48 + gaps fit 390 pt) |
| Content | Scrolling list, rows ≥ 56 pt, label left, control right | Right 70%, scrolling list |
| Close | ✖ top-right 44 pt (= Back) | Same |
| Preview | Controls/Camera tabs show a small live HUD preview at the top | Preview on the right of the list |

## Interactions

Sliders: drag or tap ◀ ▶ step buttons (no fine-drag required). Toggles: tap anywhere on the row. Keys/pad: ▲ ▼ rows, ◀ ▶ change value, LB/RB or Q/E switch tabs, A/Enter toggle, B/Esc back. Changes apply immediately (except the layout editor, on Done). After each change the row re-binds from the stored value (ADR-0016 §7).

## Edge cases

- **Opened from Pause**: Remap and the layout editor are available; the board stays frozen. Relaxed timing shows "from next level".
- **Button size makes cube edge < 20 px**: inline warning on the row; value still allowed (accessibility over aesthetics).
- **Remap leaves an action unbound**: blocked; Back restores the previous binding.
- **Gestures preset + free orbit**: board drag orbits, side zones move (different zones, no conflict).
- **Orientation change in the editor**: switches to that orientation's layout; unsaved edits kept.
- **Orientation lock set while in the other orientation**: the screen turns at once; in Pause it re-lays out like a rotate-pause.
- **Reduced motion "Follow device" with no OS support**: behaves as Off; the row shows "Device: off".
- **Switching profile**: Sound and Screen keep their values; Controls, Camera and Access switch.

## Acceptance criteria

1. [I] Each volume slider changes only its bus (Music, SFX, UI); 0 mutes it; the value is the same after switching profile.
2. [I] Every Controls/Camera/Access option persists across restart, per profile.
3. [I] Layout editor: a control dragged onto the board rect snaps back; sizes clamp to 75–200% and never under 56 dp; P and L stored separately.
4. [I] Remap: every action in the remap list (incl. Turn, Flip, Roll) rebindable on keyboard and gamepad; no action left unbound.
5. [I] Whole screen operable keyboard-only and gamepad-only; all text ≥ 12 pt at 100% (body 14 pt).
6. [I] Reduced motion "Follow device": an injected OS value of true turns off shake and turn animation without touching the setting.
7. [I] Relaxed timing toggled from Pause does not change the running level's star times.
