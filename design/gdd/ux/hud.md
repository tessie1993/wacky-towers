# In-play HUD and touch controls

> Exact layout for `design/gdd/hud.md` + `design/gdd/touch-controls.md` (Scheme A buttons, as built in `src/game/input/touch_input.gd`). Three zones: **top band** (info), **board rect** (no input, no HUD), **thumb zones** (controls). Patterns: [interaction-patterns.md](interaction-patterns.md).

## Controls in the MVP

| Control | Size | Command | Shown |
|---|---|---|---|
| D-pad (4 arms) | 56 pt arms | `move` screen-relative, hold-repeat (Touch F3) | Always |
| **Turn ◀ ▶** | 56 pt | Turntable about world Y (spin) | Always |
| **Flip ◀ ▶** | 56 pt | Screen-plane turn; resolves to the roll world axis (Movement rule 9) | Hidden in meadow_01 (spin only) |
| Drop | 64 pt | Hard drop | Always |
| Soft | 56 pt | Soft drop while held | Always |
| View ◀ ▶ + 12-tick compass | 56 pt | `rotate_view(±1)`, hold-repeat | Camera type = Snap buttons |
| ❚❚ Pause | 44 pt | Pause | Always |
Arrow art shows the on-screen motion; Turn = flat curved arrow, Flip = upright curved arrow (shape differs, not just colour). No hold/items in Meadow; their slots stay reserved and empty. Restart is in Pause only (removed from the HUD: mis-tap risk).

## Layout

| Zone | Portrait (390 × 844) | Landscape (844 × 390) |
|---|---|---|
| Top band (≈ 80 pt + inset) | ❚❚ · goal plate (left) · rule strip (centre) · next-piece plate 64 pt (right) | Same order across the top |
| Board rect | 92% W × 45% H directly under the band | 45% W × 57.5% H, centred |
| Left thumb | D-pad, bottom-left | D-pad, bottom-left side column |
| Right thumb | 2 × 2 rotation grid (Turn row above Flip row), Drop 64 pt + Soft below it | Rotation grid + Drop/Soft column to its right |
| View ◀ compass ▶ | Row between board and thumb zones, right side | Top of the right side column, under the band |
| Reserved (hold/items) | Row above the d-pad | Top of the left side column |
Everything inside safe-area insets; ≥ 8 pt between buttons. **Left-hand mirror** swaps left/right groups (top band and thumbs); rule strip stays centred. **Control scale** 100–150% grows buttons; the board shrinks first, within Board F5 (cube edge ≥ 20 px, warn in Settings).

## Readability

| Element | Spec |
|---|---|
| Plates | Opaque parchment (≥ 90% alpha), dark ink text, contrast ≥ 4.5:1 (7:1 for HUD numbers), dark outer edge |
| Numbers | Fixed-width display digits, ≥ 18 pt (24 pt default) |
| Ghost | Outline + diagonal hatch at the landing cells, plus a soft **landing shadow** on the surface below the falling piece |
| Danger | Line on the board: red **and** dashed + ! icons at its ends; plates get warm edge tint |
| Pieces | Hue **and** motif pattern per shape (Piece Set); colourblind mode strengthens the patterns |

## States

As `design/gdd/hud.md` (Hidden, Countdown, Play, Danger, Paused, Result). Controls are inert in Countdown and Result.

## Camera control types (setting, see settings.md)

| Type | HUD | Behaviour |
|---|---|---|
| **Snap buttons** (default) | View ◀ ▶ + compass | 30° steps; hold repeats |
| **Swipe orbit** | Compass only | One-finger drag on the board rect orbits, snaps to nearest of 12 on release (the only board input allowed) |
| **Auto** | Compass only | Camera picks the corner view that best shows the ghost, turning **only at spawn**, never mid-piece, so mapping never changes under the thumb |

## Edge cases

- **Rule strip > 5 icons**: "+N" chip; tap pauses and lists them (HUD edge case).
- **Fog ghost (meadow_07)**: a context **Solid** button (56 pt) appears in the reserved slot while a ghost piece is active, instead of tapping the board (keeps rule 4: no taps on the board).
- **Rubber duck (01–02)**: the one board tap allowed; a tap (not drag) on the duck's screen area only, only while visible.
- **Two thumbs on one button**: second ignored (Touch AC 4).
- **Notch on one landscape side**: plates and thumbs shift inward; board shrinks only if needed.

## Acceptance criteria

1. [M] Reference phone P and L: no HUD or control overlaps the board rect at any of the 12 yaws; all inside the safe area.
2. [I] meadow_01: Flip ◀ ▶ hidden (not greyed); meadow_02: shown.
3. [I] Mirror: d-pad on the right, rotation/drop on the left, "◀" still moves screen-left.
4. [I] 150% scale: buttons ≥ 56 pt × 1.5 where space allows, never < 56 pt; cube edge warning if < 20 px.
5. [I] Each camera type: Snap shows View buttons; Swipe hides them and board drag orbits; Auto turns only on spawn.
6. [M] Greyscale screenshot: ghost, danger line, Turn vs Flip buttons and piece shapes still distinguishable.
7. [I] Keyboard only and gamepad only can play meadow_01 to a win (GUIDE play context, no touch).
