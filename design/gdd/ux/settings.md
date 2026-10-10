# Settings

> Overlay from Title, Island map and Pause; returns to the screen below. Saved per profile on change (Save & Profile rule 2). Requirements and tiers: `design/accessibility-requirements.md` (wins on conflict). Patterns: [interaction-patterns.md](interaction-patterns.md).

## Tabs and options (defaults in bold)

| Tab | Option | Values |
|---|---|---|
| **Audio** | Music / SFX / UI volume | 0–100, step 10, **80 / 80 / 70**; each slider plays a sample on release |
| | Haptics | Off / **Light** / Strong |
| **Controls** | Preset | **Buttons** (Scheme A) · Gestures (Scheme B: drag move, flick Turn/Flip) · One-hand (all in one corner cluster) |
| | Left-hand mirror | **Off** / On |
| | Edit layout | Opens the layout editor (below) |
| | Remap keys / gamepad | Per action (interaction-patterns P8); press-to-bind; conflicts swap with a ✔/✖ prompt; Reset |
| | Hold-repeat | Delay 180–300 ms (**240**), interval 60–120 (**90**) |
| | Gesture sensitivity (Gestures only) | Drag px/cell 36–56 (**44**), flick distance 60–90 (**70**) |
| **Camera** | Control type | **Snap buttons** · Swipe orbit · Auto (hud.md) |
| | Turn animation | **On** / Instant |
| | Occlusion help | **Level default** / always Fade / always Cutaway |
| **Accessibility** | Colourblind aid | Off · **Shapes** (piece motifs, hatched ghost, dashed danger line; on by default because it costs nothing) · Shapes + high-contrast palette |
| | Reduced motion | **Off** / On (no shake, instant turns, static pulses, no flash > 3/s) |
| | HUD / control scale | **100%** – 150%, step 10 |
| | Button labels | Menus **On**, In play **Off** |
| | Rotation gizmo | **On for meadow 01–03**, then Off / always On |
| | Show level clock | **Auto** (Survive / time limit) / Always |

## Layout editor (customisation)

Full-screen, live HUD over a sample board, in the current orientation; toggle P/L preview with a button. Drag any control within its thumb zone (never onto the board rect: it snaps back with a red outline), pinch or +/− to resize it 100–150%, **Reset**, **Done**. Layouts are stored per orientation. Saves on Done; Back asks ✔/✖ if unsaved.

## Layout

| Zone | Portrait | Landscape |
|---|---|---|
| Tabs | Row of 4 icon+label tabs at the top, 56 pt | Column on the left, 56 pt rows |
| Content | Scrolling list, rows ≥ 56 pt, label left, control right | Right 70%, scrolling list |
| Close | ✖ top-right 44 pt (= Back) | Same |
| Preview | Controls/Camera tabs show a small live HUD preview at the top | Preview on the right of the list |

## Interactions

Sliders: drag or tap ◀ ▶ step buttons (no fine-drag required). Toggles: tap anywhere on the row. Keys/pad: ▲ ▼ rows, ◀ ▶ change value, A/Enter toggle, B/Esc back. Changes apply immediately (except the layout editor, on Done).

## Edge cases

- **Opened from Pause**: Remap and the layout editor are available; the board stays frozen.
- **Scale makes cube edge < 20 px**: inline warning on the scale row; value still allowed (accessibility over aesthetics).
- **Remap leaves an action unbound**: blocked; Back restores the previous binding.
- **Gestures preset + Swipe orbit camera**: allowed; board drag orbits, side zones move (no conflict, different zones).
- **Orientation change in the editor**: switches to that orientation's layout; unsaved edits kept.

## Acceptance criteria

1. [I] Each volume slider changes only its bus (Music, SFX, UI); 0 mutes it.
2. [I] Every Controls/Camera/Accessibility option persists across restart, per profile.
3. [I] Layout editor: a control dragged onto the board rect snaps back; sizes clamp to 100–150%; P and L stored separately.
4. [I] Remap: every P8 action rebindable on keyboard and gamepad; no action left unbound.
5. [I] Whole screen operable keyboard-only and gamepad-only; all text ≥ 14 pt at 100%.
