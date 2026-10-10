# Interaction patterns

> Shared rules every screen in `design/gdd/ux/` uses. Accessibility criteria: `design/accessibility-requirements.md` (wins on conflict).

## P1 Targets and spacing

| Element | Min size | Gap |
|---|---|---|
| Menu button / icon | 44 pt (48 dp Android) | 8 pt |
| In-play button | 56 pt (drop 64 pt) | 8 pt |
| Island hit area | 72 pt (larger than the art) | n/a |
All sizes × control scale (100–150%). Decorative trim never counts toward size.

## P2 Buttons

| State | Look (art-director owns the style) | Non-colour cue |
|---|---|---|
| Idle | Parchment plate, ink outline | n/a |
| Pressed | Squash 92%, 150–250 ms (default 180; ui-theme) | Shape change |
| Focused (keys/pad) | Thick ink ring + slight lift | Ring shape, not just tint |
| Disabled | Hidden in play (Touch rule 9); in menus 50% + lock icon | Lock icon |
Fire on **release** in menus (lets the thumb slide off to cancel); fire on **press** in play (latency < 50 ms).

## P3 Back and confirm

- Back = one screen (Android back, Esc, gamepad B, on-screen ◀ top-left). From Play, back opens Pause; from Title, back asks "Quit?" (icon dialog).
- A confirmation only for **progress-losing** actions (Restart, Quit to map mid-level). Never two in a row. Confirm is an icon dialog: ✔ / ✖, ✔ on the right (L) or bottom (P), and the destructive one is never the default focus.

## P4 Focus and non-touch input (GUIDE)

- Every screen has a focus order (top-left → bottom-right, primary action first). Keyboard: arrows/Tab move, Enter/Space confirm, Esc back. Gamepad: d-pad/stick, A confirm, B back, Start = pause.
- Focus is shown only after a key/pad input; first touch hides it.
- GUIDE input contexts: `menu` and `play` (exists: `play_keyboard.tres`). Remaps are written to the active context and saved per profile (Save & Profile settings).

## P5 Feedback for every action

| Event | Visual | Audio | Haptic |
|---|---|---|---|
| Tap button | Squash | UI click (UI bus) | Light tick (if on) |
| Move / rotate ok | Piece snaps, ghost updates same frame | click / whoosh | tick / pulse |
| Blocked | 80 ms bonk, blocked cubes outlined red + ✖ hatch | bonk | double tick |
| Lock | Thunk dust | thunk | strong pulse |
| Locked island tap | Lock wiggles, "★ N" bubble | dull clunk | n/a |
Reduced motion: shakes and wiggles become a 200 ms static outline.

## P6 Wordless communication

- No sentences anywhere in play or skits. Skits use emote bubbles (icons, `design/gdd/narrative/`).
- Menus use icon + one or two words max (Play, Retry). Every icon-only button has a text label in settings via "Show button labels" (default **on** for menus, **off** for in-play) and an AccessKit name (Godot 4.5+).
- Numbers (stars, times, goal progress) are always shown as digits, never only as bars.

## P7 Orientation

- Both orientations supported everywhere. Layout switches on `size_changed`; in menus instantly (focus kept), in play by pausing (pause.md).
- Implementation: one Control scene per screen with two anchor presets (P, L) swapped by aspect ratio; containers reflow, nothing is hand-positioned twice. Safe-area insets from `DisplayServer.get_display_safe_area()` applied as margins on the root.

## P8 Input mapping (keyboard defaults; GUIDE actions exist in `src/game/input/actions/`)

| Action | GUIDE action | Keys | Touch label |
|---|---|---|---|
| Move | `move` | WASD / arrows | d-pad |
| Turn ◀ / ▶ (axis id `spin`: turntable, world Y) | `rot_spin_left/right` (was `rot_h_*`) | Q / E | Turn ◀ ▶ |
| Flip ◀ / ▶ (axis id `tilt`: horizontal axis nearest screen-horizontal) | `rot_tilt_left/right` (was `rot_v_*`) | R / F | Flip ◀ ▶ |
| Roll ◀ / ▶ (axis id `roll`: the other horizontal axis) | `rot_roll_left/right` (new) | T / G (proposed, pending user) | Roll ◀ ▶ |
| Use skill | `use_skill` | X | Skill button |
| Soft drop (hold) | `soft_drop` | Shift hold (S/↓ are moves) | Soft |
| Hard drop | `hard_drop` | Space | Drop |
| View ◀ / ▶ | `view_l/r` | Z / C | View ◀ ▶ |
| Pause | `pause` | Esc / P | ❚❚ |
| Restart | `restart` | Backspace (confirm) | in Pause only |
Action and axis ids per ADR-0012 (rename `rot_h_*` → `rot_spin_*`, `rot_v_*` → `rot_tilt_*`, add `rot_roll_*`; player-facing names Turn / Flip / Roll are text keys). Gamepad: shoulders = Turn, triggers = Flip, X / Y = Roll, right stick X = View (ADR-0012). Keys are UX defaults; where `play_keyboard.tres` differs, align it to this table (or log the difference). Every row is remappable (settings.md). Rotation buttons show arrow art of the on-screen motion, never x/y/z.
